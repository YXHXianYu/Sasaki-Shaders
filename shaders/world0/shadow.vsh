#version 450 compatibility
 
/* includes */
#include "/include/config.glsl"

out vec4 texcoord;
 
void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    float dist = length(gl_Position.xy);
    float distortFactor = (1.0 - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS ;
    gl_Position.xy /= distortFactor;
    texcoord = gl_MultiTexCoord0;
}