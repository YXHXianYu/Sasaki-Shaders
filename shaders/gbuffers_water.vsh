#version 120

#include "./block.properties"

attribute vec4 mc_Entity;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec2 normal;
varying float attr;

vec2 normalEncode(vec3 n) {
    return normalize(n.xy) * (sqrt(-n.z * 0.5 + 0.5)) * 0.5 + 0.5;
}

void main() {
    vec4 position = gl_ModelViewMatrix * gl_Vertex;
    int blockId = int(mc_Entity.x);
    if(blockId == BLOCK_WATER && gl_Normal.y > -0.9)
        attr = 1.0 / 255.0;
    else
        attr = 0.0;
    
    gl_Position = gl_ProjectionMatrix * position;
    gl_FogFragCoord = length(position.xyz);

    color = gl_Color;
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    normal = normalEncode(gl_NormalMatrix * gl_Normal);
}