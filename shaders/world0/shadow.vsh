#version 450
 
/* includes */
#include "/include/config.glsl"

varying vec4 texcoord;
 
void main() {
    gl_Position = ftransform();
    float dist = length(gl_Position.xy);
    float distortFactor = (1.0 - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS ;
    gl_Position.xy /= distortFactor;
    texcoord = gl_MultiTexCoord0;
}