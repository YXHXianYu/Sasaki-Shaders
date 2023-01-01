#version 450

/* includes */
#include "/block.properties"
#include "/include/config.glsl"

/* basic */
varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec2 normal;

vec2 normalEncode(vec3 n) {
    return normalize(n.xy) * (sqrt(-n.z * 0.5 + 0.5)) * 0.5 + 0.5;
}

/* blockId */
attribute vec4 mc_Entity;
varying float attr;

/* dynamic water */
uniform sampler2D noisetex; // noise
uniform float frameTimeCounter; // time
uniform vec3 cameraPosition;

void DynamicWater(inout vec4 position, vec3 sample_position) {
    float noise = texture2D(noisetex, sample_position.xz / 16.0).r;
    float time = frameTimeCounter * 2.0;
    
    position.y += (sin(noise * 10.0 + time) - 1.0) * DYNAMIC_WATER_STRENGTH;
}

void main() {
    // water tag
    int blockId = int(mc_Entity.x + 0.5);
    if(blockId == BLOCK_WATER && gl_Normal.y > -0.9)
        attr = 1.0 / 255.0;
    else
        attr = 0.0;
    
    // dynamic water
    vec4 position = gl_Vertex;
    vec3 sample_position = mod(gl_Vertex.xyz + cameraPosition, 16.0);

    DynamicWater(position, sample_position);

    // result
    gl_Position = gl_ModelViewProjectionMatrix * position;
    gl_FogFragCoord = length(position.xyz);

    color = gl_Color;
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    normal = normalEncode(gl_NormalMatrix * gl_Normal);
}