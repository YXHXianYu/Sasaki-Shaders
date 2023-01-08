/*
basic vertex shader (all gbuffers shaders can use this)

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
#define GBUFFERS_TEXTURED_SHADER
#define GBUFFERS_TERRAIN_SHADER
#define GBUFFERS_WATER_SHADER
*/

/* ----- includes ----- */
#include "/block.properties"
#include "/include/config.glsl"
#include "/include/utility.glsl"

/* ----- preprocess ----- */
#ifdef GBUFFERS_WATER_SHADER
    #define NORMAL
#endif

/* ----- main ----- */
#ifdef COLOR
    out vec4 color;
#endif // COLOR

#ifdef NORMAL
    out vec2 normal_vec2;
#endif // NORMAL

#ifdef TEXCOORD
    out vec4 texcoord;
#endif // TEXCOORD

#ifdef LMCOORD
    out vec4 lmcoord;
#endif // LMCOORD

#ifdef GBUFFERS_TEXTURED_SHADER
    #ifdef OPTIFINE_OLD_VERSION_ENABLE
        attribute vec4 mc_Entity;
    #else  // OPTIFINE_OLD_VERSION_ENABLE
        in vec4 mc_Entity;
    #endif // OPTIFINE_OLD_VERSION_ENABLE
    out float blockId;
#endif // GBUFFERS_TEXTURED_SHADER

#ifdef GBUFFERS_TERRAIN_SHADER      // Waving Plants
    uniform sampler2D noisetex;     // noise texture
    uniform float frameTimeCounter; // time
    uniform vec3 cameraPosition;    // camera position
    uniform float rainStrength;     // when it's raining, grass will move stronger
    #ifdef OPTIFINE_OLD_VERSION_ENABLE
        attribute vec4 mc_Entity;
        attribute vec4 mc_midTexCoord;
    #else  // OPTIFINE_OLD_VERSION_ENABLE
        in vec4 mc_Entity;
        in vec4 mc_midTexCoord;
    #endif // OPTIFINE_OLD_VERSION_ENABLE
    out vec3 loop_position;       // for render vertex position mode
#endif // GBUFFERS_TERRAIN_SHADER

#ifdef GBUFFERS_WATER_SHADER
    /* blockId */
    uniform int blockEntityId;
    #ifdef OPTIFINE_OLD_VERSION_ENABLE
        attribute vec4 mc_Entity;
    #else  // OPTIFINE_OLD_VERSION_ENABLE
        in vec4 mc_Entity;
    #endif // OPTIFINE_OLD_VERSION_ENABLE
    out float blockId;
    /* dynamic water */
    uniform sampler2D noisetex;     // noise
    uniform float frameTimeCounter; // time
    uniform vec3 cameraPosition;    // camera position
    void DynamicWater(inout vec4 position, vec3 sample_position) {
        float noise = texture(noisetex, sample_position.xz / 16.0).r;
        float time = frameTimeCounter * 2.0;
        position.y += (sin(noise * 10.0 + time) - 1.0) * DYNAMIC_WATER_STRENGTH;
    }
    /* others */
    out float waterTag;
    out vec3 normal;
    out vec3 fragPosition;
#endif // GBUFFERS_WATER_SHADER

void main() {

    #ifdef COLOR
        color = gl_Color;
    #endif // COLOR

    #ifdef NORMAL
        mat4 matrix4 = transpose(gl_ModelViewMatrixInverse);
        mat3 matrix3;
        matrix3[0][0] = matrix4[0][0];
        matrix3[0][1] = matrix4[0][1];
        matrix3[0][2] = matrix4[0][2];
        
        matrix3[1][0] = matrix4[1][0];
        matrix3[1][1] = matrix4[1][1];
        matrix3[1][2] = matrix4[1][2];
        
        matrix3[2][0] = matrix4[2][0];
        matrix3[2][1] = matrix4[2][1];
        matrix3[2][2] = matrix4[2][2];
        
        normal_vec2 = normalEncode((matrix3 * gl_Normal));
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

    #ifdef GBUFFERS_TEXTURED_SHADER
        blockId = mc_Entity.x + 0.5;
    #endif // GBUFFERS_TEXTURED_SHADER

    // end

    // position
    vec4 position = gl_Vertex;

    #ifdef GBUFFERS_TERRAIN_SHADER
        loop_position = mod(gl_Vertex.xyz + cameraPosition, 16.0); // for 1.18.2
        #ifdef OPTIFINE_OLD_VERSION_ENABLE
            loop_position = gl_Vertex.xyz;
        #endif // OPTIFINE_OLD_VERSION_ENABLE

        int tBlockId = int(mc_Entity.x + 0.5);
        if((tBlockId == BLOCK_SMALL_PLANTS || tBlockId == BLOCK_PLANTS || tBlockId == BLOCK_DOUBLE_PLANTS_UPPER) && gl_MultiTexCoord0.t < mc_midTexCoord.t) {
            vec3 noise = texture(noisetex, loop_position.xz / 16.0).rgb; // 16 * 16 * 16; repeat (loop)
            float maxStrength = 1.0 + rainStrength * 0.5;
            float time = frameTimeCounter * 2.0;
            float reset = cos(noise.z * 10.0 + time * 0.1);
            reset = max(reset * reset, max(rainStrength, 0.1));
            position.x += sin(noise.x * 10.0 + time) * 0.2 * reset * maxStrength;
            position.z += sin(noise.y * 10.0 + time) * 0.2 * reset * maxStrength;
        } else if(tBlockId == BLOCK_LEAVES)  {
            vec3 noise = texture(noisetex, (loop_position.xz + 0.5) / 16.0).rgb; // 16 * 16 * 16; repeat (loop)
            float maxStrength = 1.0 + rainStrength * 0.5;
            float time = frameTimeCounter * 3.0;
            float reset = cos(noise.z * 10.0 + time * 0.1);
            reset = max( reset * reset, max(rainStrength, 0.1));
            position.x += sin(noise.x * 10.0 + time) * 0.07 * reset * maxStrength;
            position.z += sin(noise.y * 10.0 + time) * 0.07 * reset * maxStrength;
        }
    #endif // GBUFFERS_TERRAIN_SHADER

    #ifdef GBUFFERS_WATER_SHADER
        // blockId
        blockId = mc_Entity.x + 0.5;
        // waterTag
        if((int(blockId) == BLOCK_WATER || (mc_Entity.x == 8 || mc_Entity.x == 9)) && gl_Normal.y > -0.5) {
            waterTag = 1.0 / 255.0;
        } else {
            waterTag = 0.0;
        }
        // dynamic water
        if(int(blockId) == BLOCK_WATER || (mc_Entity.x == 8 || mc_Entity.x == 9)) {
            vec3 samplePosition = mod(gl_Vertex.xyz + cameraPosition, 16.0);
            #ifdef OPTIFINE_OLD_VERSION_ENABLE
                samplePosition = gl_Vertex.xyz;
            #endif // OPTIFINE_OLD_VERSION_ENABLE
            DynamicWater(position, samplePosition);
        }
        // sun reflection
        normal = gl_Normal;
        fragPosition = gl_Vertex.xyz + cameraPosition;
    #endif // GBUFFERS_WATER_SHADER

    gl_Position = gl_ModelViewProjectionMatrix * position;

    #ifdef SHADOW_SHADER
        gl_Position.xy /= (1.0 - SHADOW_MAP_BIAS) + length(gl_Position.xy) * SHADOW_MAP_BIAS;
    #endif // SHADOW_SHADER
}