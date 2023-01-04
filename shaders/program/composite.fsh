/*
composite.fsh
*/

/* includes */
#include "/include/config.glsl"

// basic
uniform sampler2D gcolor;
in vec4 texcoord;

// some uniform vars
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

/* ----- Shadow Mapping - Begin ----- */
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform sampler2DShadow shadow;
uniform sampler2D depthtex0;

uniform float far; // projection matrix the far face

// sun and moon
in float extShadow;
in vec3 lightPosition;

// 水面不渲染阴影
uniform sampler2D colortex4;

float shadowMapping(vec4 worldPosition, float dist, vec3 normal, float alpha) {
    if(dist > 0.9) //距离过远(比如远景和天空)的地方就不渲染阴影了
        return extShadow;
    
    float shade = 0;
    float angle = dot(lightPosition, normal); // 计算法线和光线夹角

    if(angle <= 0.1 && alpha > 0.99) { // 如果角度太小，直接涂黑
        shade = 1.0;
    } else {
        vec4 shadowposition = shadowModelView * worldPosition;
        shadowposition = shadowProjection * shadowposition;
        float edgeX = abs(shadowposition.x) - 0.9;
        float edgeY = abs(shadowposition.y) - 0.9;
        float distb = sqrt(shadowposition.x * shadowposition.x + shadowposition.y * shadowposition.y);
        float distortFactor = (1.0 - SHADOW_MAP_BIAS) + distb * SHADOW_MAP_BIAS;
        shadowposition.xy /= distortFactor;
        shadowposition /= shadowposition.w;
        shadowposition = shadowposition * 0.5 + 0.5;
        shade = 1.0 - texture(shadow, vec3(shadowposition.st, shadowposition.z - 0.0001));
        if(angle < 0.2 && angle > 0.99)
            shade = max(shade, 1.0 - (angle - 0.1) * 10.0);
            shade -= max(0.0, edgeX * 10.0);
        shade -= max(0.0, edgeY * 10.0);
    }
    shade -= clamp((dist - 0.7) * 5.0, 0.0, 1.0);//在l处于0.7~0.9的地方进行渐变过渡
    shade = clamp(shade, 0.0, 1.0); //避免出现过大或过小
    
    if(texture(colortex4, texcoord.st).x * 255.0 == 1.0) // 水面不渲染阴影
        return max(shade, extShadow) * 0.05;

    return max(shade, extShadow);
}
/* ----- Shadow Mapping - End ----- */

uniform sampler2D gnormal;
uniform vec3 sunPosition;

vec3 normalDecode(vec2 enc) {
    vec4 nn = vec4(2.0 * enc - 1.0, 1.0, -1.0);
    float l = dot(nn.xyz,-nn.xyw);
    nn.z = l;
    nn.xy *= sqrt(l);
    return nn.xyz * 2.0 + vec3(0.0, 0.0, -1.0);
}

/* ----- Cloud - Begin ----- */
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform sampler2D noisetex; // 噪声图
in vec3 worldSunPosition;   // 太阳向量
uniform float rainStrength; // 雨强度

in vec3 cloudBase1;
in vec3 cloudBase2;
in vec3 cloudLight1;
in vec3 cloudLight2;
vec4 cloudLighting(vec4 sum, float density, float diff) {  
    vec4 color = vec4(mix(cloudBase1, cloudBase2, density ), density );
    vec3 lighting = mix(cloudLight1, cloudLight2, diff);
    color.xyz *= lighting;
    color.a *= 0.4;
    color.rgb *= color.a;
    return sum + color*(1.0-sum.a);
}

float noise(vec3 x) { // noise function
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = smoothstep(0.0, 1.0, f);
    vec2 uv = (p.xy+vec2(37.0, 17.0)*p.z) + f.xy;
    float v1 = texture(noisetex, (uv) / 256.0, -100.0).x;
    float v2 = texture(noisetex, (uv + vec2(37.0, 17.0)) / 256.0, -100.0).x;
    return mix(v1, v2, f.z);
}
float getCloudNoise(vec3 worldPos) { // use noise function to make cloud noise
    vec3 coord = worldPos;
    float density = 1.0;
    if(coord.y < CLOUD_MIN) {
        density = 1.0 - smoothstep(0.0, 1.0, min(CLOUD_MIN - coord.y, 1.0));
    } else if(coord.y > CLOUD_MAX) {
        density = 1.0 - smoothstep(0.0, 1.0, min(coord.y - CLOUD_MAX, 1.0));
    }
    coord.x += frameTimeCounter * 10.0;
    coord *= 0.002;
    float n  = noise(coord) * 0.5;   coord *= 3.0;
          n += noise(coord) * 0.25;  coord *= 3.01;
          n += noise(coord) * 0.125; coord *= 3.02;
          n += noise(coord) * 0.0625;
    n *= density;
    return smoothstep(0.0, 1.0, pow(max(n - 0.5, 0.0) * (1.0 / (1.0 - 0.5)), 0.5));
}
float distance2(vec3 p1, vec3 p2) { // calculate distance^2 between two points
    return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y) + (p1.z - p2.z) * (p1.z - p2.z);
}
vec3 cloudRayMarching(vec3 cameraPosition, vec4 viewPosition, vec3 originColor, float maxDistance) { // calculate cloud
    if(!ENABLE_CLOUD) return originColor;

    vec3 direction = normalize(gbufferModelViewInverse * viewPosition).xyz;
    if(direction.y <= RAY_MARCHING_DIRECTION_Y_LIMIT) return originColor;

    vec3 testPoint = cameraPosition;
    
    float cloudMin = cameraPosition.y + CLOUD_MIN * (exp(-cameraPosition.y / CLOUD_MIN) + 0.001);
    testPoint += direction * ((cloudMin - cameraPosition.y) / direction.y); // 快速接近云层
    if(distance2(testPoint, cameraPosition) > maxDistance * maxDistance) return originColor; // 目标太远
    
    float cloudMax = cloudMin + (CLOUD_MAX - CLOUD_MIN);
    direction *= 1.0 / direction.y; // why use 1.0 / direction.y ?
    
    vec4 final = vec4(0.0);
    float fadeout = (1.0 - clamp(length(testPoint) / (far * 100.0) * 6.0, 0.0, 1.0));

    for(int i = 0; i < RAY_MARCHING_TIMES; i++) {

        // if(cloudMin < testPoint.y && testPoint.y < cloudMax) final.xyz += 0.1;

        // if(final.a > 0.99 || testPoint.y > cloudMax) break;

        testPoint += direction; // make a step

        vec3 samplePoint = vec3(testPoint.x, testPoint.y - cloudMin + CLOUD_MIN, testPoint.z);
        float density = getCloudNoise(samplePoint) * fadeout;
        if(density > 0.0) {
            float diff = clamp((density - getCloudNoise(samplePoint + worldSunPosition * 10.0)) * 10.0, 0.0, 1.0);
            final = cloudLighting(final, density, diff);
        }
    }
    final = clamp(final, 0.0, 1.0);
    return mix(originColor, originColor * (1.0 - final.a) + final.rgb, 1.0 - rainStrength);
}
/* ----- Cloud - End ----- */

void main() {
/* DRAWBUFFERS:01 */

    vec4 color = texture(gcolor, texcoord.st);
    vec3 normal = normalDecode(texture(gnormal, texcoord.st).rg);

    float depth = texture(depthtex0, texcoord.st).x;
    vec4 viewPosition = gbufferProjectionInverse * vec4(texcoord.s * 2.0 - 1.0, texcoord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0f);
    viewPosition /= viewPosition.w;
    vec4 worldPosition = gbufferModelViewInverse * (viewPosition + vec4(normal * 0.05 * sqrt(abs(viewPosition.z)), 0.0));

    float dist = length(worldPosition.xyz);
    float shade = shadowMapping(worldPosition, dist / far, normal, color.a);

    color.rgb *= 1.0 - shade * 0.5;
    
    color.rgb = cloudRayMarching(cameraPosition, viewPosition, color.rgb, ((dist / far > 0.9999) ? (100.0 * far) : (dist)));

    float brightness = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 highlight = color.rgb * max(brightness - 0.25, 0.0);
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(highlight, 1.0);

    // gl_FragData[0] = vec4(normal, 1.0); // A Normal World
}