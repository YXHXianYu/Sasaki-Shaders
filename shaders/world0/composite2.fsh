#version 450
/* DRAWBUFFERS:1 */
 
uniform sampler2D colortex3;
uniform float viewWidth;
uniform float viewHeight;
 
varying vec4 texcoord;
 
const float offset[9] = float[] (0.0, 1.4896, 3.4757, 5.4619, 7.4482, 9.4345, 11.421, 13.4075, 15.3941);
const float weight[9] = float[] (0.066812, 0.129101, 0.112504, 0.08782, 0.061406, 0.03846, 0.021577, 0.010843, 0.004881);
 
vec3 blur(sampler2D image, vec2 uv, vec2 direction) {
    vec3 color = texture2D(image, uv).rgb * weight[0];
    for(int i = 1; i < 9; i++)
    {
        color += texture2D(image, uv + direction * offset[i]).rgb * weight[i];
        color += texture2D(image, uv - direction * offset[i]).rgb * weight[i];
    }
    return color;
}
 
void main() {
    gl_FragData[0] = vec4(blur(colortex3, texcoord.st, vec2(0.0, 1.0) / vec2(viewWidth, viewHeight)), 1.0);
}