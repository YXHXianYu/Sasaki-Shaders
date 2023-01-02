/*
basic vertex shader

use:
#version 450 compatibility

#define COLOR
#define NORMAL
#define TEXCOORD
#define LMCOORD
#define FOG

// #include "/program/basic_vertex_shader.glsl"

extra:
#define SHADOW_SHADER
#define GBUFFERS_TERRAIN_SHADER
*/

/* ----- includes ----- */
#include "/block.properties"
#include "/include/config.glsl"

/* ----- main ----- */
#ifdef COLOR
    out vec4 color;
#endif // COLOR

#ifdef NORMAL
    out vec2 normal;
    
    vec2 normalEncode(vec3 n) {
        vec2 enc = normalize(n.xy) * (sqrt(-n.z*0.5+0.5));
        enc = enc*0.5+0.5;
        return enc;
    }
#endif // NORMAL

#ifdef TEXCOORD
    out vec4 texcoord;
#endif // TEXCOORD

#ifdef LMCOORD
    out vec4 lmcoord;
#endif // LMCOORD

#ifdef GBUFFERS_TERRAIN_SHADER      // Waving Plants
    uniform sampler2D noisetex;     // noise texture
    uniform float frameTimeCounter; // time
    uniform vec3 cameraPosition;    // camera position
    uniform float rainStrength;     // when it's raining, grass will move stronger
    in vec4 mc_Entity;
    in vec4 mc_midTexCoord;
    out vec3 loop_position;       // for render vertex position mode
#endif // GBUFFERS_TERRAIN_SHADER

void main() {

    #ifdef COLOR
        color = gl_Color;
    #endif // COLOR

    #ifdef NORMAL
        normal = normalEncode(gl_NormalMatrix * gl_Normal);
    #endif // NORMAL

    #ifdef TEXCOORD
        texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    #endif // TEXCOORD

    #ifdef LMCOORD
        lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    #endif // LMCOORD

    #ifdef FOG
        gl_FogFragCoord = length((gl_ModelViewMatrix * gl_Vertex).xyz);
    #endif // FOG    

    // position
    vec4 position = gl_Vertex;

    #ifdef GBUFFERS_TERRAIN_SHADER
        loop_position = mod(gl_Vertex.xyz + cameraPosition, 16.0); // for 1.18.2
        int blockId = int(mc_Entity.x + 0.5);

        if((blockId == BLOCK_SMALL_PLANTS || blockId == BLOCK_PLANTS || blockId == BLOCK_DOUBLE_PLANTS_UPPER) && gl_MultiTexCoord0.t < mc_midTexCoord.t) {
            vec3 noise = texture(noisetex, loop_position.xz / 16.0).rgb; // 16 * 16 * 16; repeat (loop)
            float maxStrength = 1.0 + rainStrength * 0.5;
            float time = frameTimeCounter * 2.0;
            float reset = cos(noise.z * 10.0 + time * 0.1);
            reset = max( reset * reset, max(rainStrength, 0.1));
            position.x += sin(noise.x * 10.0 + time) * 0.2 * reset * maxStrength;
            position.z += sin(noise.y * 10.0 + time) * 0.2 * reset * maxStrength;
        } else if(blockId == BLOCK_LEAVES)  {
            vec3 noise = texture(noisetex, (loop_position.xz + 0.5) / 16.0).rgb; // 16 * 16 * 16; repeat (loop)
            float maxStrength = 1.0 + rainStrength * 0.5;
            float time = frameTimeCounter * 3.0;
            float reset = cos(noise.z * 10.0 + time * 0.1);
            reset = max( reset * reset, max(rainStrength, 0.1));
            position.x += sin(noise.x * 10.0 + time) * 0.07 * reset * maxStrength;
            position.z += sin(noise.y * 10.0 + time) * 0.07 * reset * maxStrength;
        }
    #endif // GBUFFERS_TERRAIN_SHADER

    gl_Position = gl_ModelViewProjectionMatrix * position;

    #ifdef SHADOW_SHADER
        gl_Position.xy /= (1.0 - SHADOW_MAP_BIAS) + length(gl_Position.xy) * SHADOW_MAP_BIAS;
    #endif // SHADOW_SHADER
}