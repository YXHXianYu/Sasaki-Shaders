/*
final.fsh

Bloom, Tone Mapping, Water Reflection
*/

/* ----- includes ----- */
#include "/include/config.glsl"

/* ----- Basic ----- */
uniform sampler2D gcolor;
uniform sampler2D gnormal;

in vec4 texcoord;

/* ----- Bloom ----- */
uniform sampler2D colortex1;
vec3 Bloom(vec3 color, float coefficient) {
    vec3 hightlight = texture(colortex1, texcoord.st).rgb;
    return color + hightlight * clamp(coefficient, 0.0, 1.0);
}

/* ----- Tone Mapping ----- */
float A = 0.15;
float B = 0.50;
float C = 0.10;
float D = 0.20;
float E = 0.02;
float F = 0.30;
float W = 13.134;
 
vec3 uncharted2Tonemap(vec3 x) {
    return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

vec3 ToneMapping(vec3 color) {
    color = pow(color, vec3(1.4));
    color *= 6.0;
    vec3 curr = uncharted2Tonemap(color);
    vec3 whiteScale = 1.0f/uncharted2Tonemap(vec3(W));
    return curr*whiteScale;
}

/* ----- Water Reflection ----- */
uniform float near;
uniform float far;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;
vec3 NormalDecode(vec2 enc) {
    vec4 nn = vec4(2.0 * enc - 1.0, 1.0, -1.0);
    float l = dot(nn.xyz,-nn.xyw);
    nn.z = l;
    nn.xy *= sqrt(l);
    return nn.xyz * 2.0 + vec3(0.0, 0.0, -1.0);
}
vec3 MultipleGBufferProjection(vec4 p) {
    p = gbufferProjection * p;
    return p.xyz / p.w;
}
vec3 MultipleGBufferProjectionInverse(vec4 p) {
    p = gbufferProjectionInverse * p;
    return p.xyz / p.w;
}

vec2 GetScreenCoordByViewPosition(vec3 view_position) { // 将view坐标转化为屏幕坐标
    vec3 p = MultipleGBufferProjection(vec4(view_position, 1.0));
    if(p.z < -1 || p.z > 1) return vec2(-1.0);
    else return p.xy * 0.5 + 0.5;
}
float LinearizeDepth(float depth) { // 将视锥深度线性化
    return (2.0 * near) / (far + near - depth * (far - near)); // 可以把视锥画出来，推一下公式
}
float GetLinearDepthOfViewPosition(vec3 view_position) { // 将view坐标下的深度转化为屏幕深度
    vec3 p = MultipleGBufferProjection(vec4(view_position, 1.0));
    return LinearizeDepth(p.z * 0.5 + 0.5);
}

vec3 WaterRayTracing(vec3 color, vec3 start_point, vec3 direction, float jitter, float fresnel) {
    const float step_base = 0.025; // 步长基数（或许叫系数更合理）

    vec3 test_point = start_point;
    vec3 last_point = test_point;
    direction *= step_base; // 步长
    vec2 uv;

    bool is_hit = false;
    vec4 hit_color = vec4(0.0);
    for(int i = 0; i < 32; i++) {
        test_point += direction * pow(float(i + 1 + jitter), 1.46); // 经验公式
        uv = GetScreenCoordByViewPosition(test_point);
        if(uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
            is_hit = true;
            break;
        }

        float sample_depth = LinearizeDepth(textureLod(depthtex0, uv, 0.0).x);
        float test_depth = GetLinearDepthOfViewPosition(test_point);
        // 经验公式2：为了处理有遮挡物的情况
        if(sample_depth < test_depth && test_depth - sample_depth < (1.0 / 2048.0) * (1.0 + test_depth * 200.0 + float(i))) {
            // 二分：在一个水面处接近目标点的采样点 和 一个远离水面处接近目标点的采样点 之间，二分趋近目标点
            vec3 final_point = last_point;

            float bisearch_sign = 1.0;
            for(int i = 1; i <= 4; i++) {
                direction *= 0.5;
                final_point += direction * bisearch_sign;
                
                uv = GetScreenCoordByViewPosition(final_point);
                sample_depth = LinearizeDepth(textureLod(depthtex0, uv, 0.0).x);
                test_depth = GetLinearDepthOfViewPosition(test_point);

                bisearch_sign = sign(sample_depth - test_depth);
            }
            uv = GetScreenCoordByViewPosition(final_point); // useless

            is_hit = true;
            hit_color = vec4(textureLod(gcolor, uv, 0.0).rgb, 1.0);
            hit_color.a = clamp(1.0 - pow(distance(uv, vec2(0.5))*2.0, 2.0), 0.0, 1.0);
            break;
        }
        last_point = test_point;
    }
    if(!is_hit) {
        uv = GetScreenCoordByViewPosition(last_point);
        float sample_depth = LinearizeDepth(textureLod(depthtex0, uv, 0.0).x);
        float test_depth = GetLinearDepthOfViewPosition(last_point);
        if(test_depth - sample_depth < 0.5) {
            hit_color = vec4(textureLod(gcolor, uv, 0.0).rgb, 1.0);
            hit_color.a = clamp(1.0 - pow(distance(uv, vec2(0.5))*2.0, 2.0), 0.0, 1.0);
            hit_color.a *= 0.3; // 让大片海的天空反射不那么突兀
        }
    }
    return mix(color, hit_color.rgb, hit_color.a * fresnel);
}

vec3 WaterReflection(vec3 color) {
    if(!ENABLE_WATER_REFLECTION) return color;
    
    vec2 uv = texcoord.st;
    float depth = texture(depthtex0, uv).r;
    vec3 view_position = MultipleGBufferProjectionInverse(vec4(texcoord.s * 2.0 - 1.0, texcoord.t * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0)); // some of szszss'codes may be redundant
    float attr = texture(colortex4, uv).r * 255.0;
    if(attr == 1.0) {
        vec3 normal = NormalDecode(texture(gnormal, texcoord.st).rg);
        vec3 reflect_direction = reflect(normalize(view_position), normal);

        // 抖动jitter：去除水面反射的封层，但出现锯齿。
        float jitter = 0.0;
        if(ENABLE_JITTER) {
            vec2 uv2 = texcoord.st * vec2(viewWidth, viewHeight);
            jitter = mod((uv2.x + uv2.y) * 0.25, 1.0);
        }

        // Schlick's approximation
        float fresnel = 0.02 + 0.98 * pow(1.0 - dot(reflect_direction, normal), 3.0);

        color = WaterRayTracing(color, view_position + normal * (-view_position.z / far * 0.2 + 0.05), reflect_direction, jitter, fresnel);
        // 不用color = WaterRayTracing(color, view_position, reflect_direction)的原因：避免撞到出发点

    }
    return color;
}

/* ----- Main ----- */
void main() {
    if(RENDER_Z_BUFFER) {
        float depth_color = 20.0 * (1.0 - texture(depthtex0, texcoord.st).r); // depth_color = 20 * depth
        depth_color = pow(depth_color, 1.0 / 1.5); // Mapping! Power of Mathmatic!
        gl_FragColor = vec4(vec3(depth_color), 1.0);
    } else {
        vec3 color =  texture(gcolor, texcoord.st).rgb;
        color = WaterReflection(color);
        color = Bloom(color, BLOOM_STRENGTH);
        color = ToneMapping(color);
        gl_FragColor = vec4(color, 1.0);
    }
}