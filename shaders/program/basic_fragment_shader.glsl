/*
basic fragment shader (all gbuffers shaders can use this)

draw buffers are tex0(gcolor), tex2(gnormal), tex4(waterTag)

use:
#version 450 compatibility

#define COLOR
#define NORMAL
#define TEXCOORD
#define LMCOORD
#define FOG

// #include "/program/basic_fragment_shader.glsl"

extra:
#define HIGHTLIGHT_THIS         // used to hightlight some block
#define DISCARD_WHEN_CLOUD      // used in gbuffers_textured.fsh
#define GBUFFERS_TERRAIN_SHADER
#define GBUFFERS_ENTITIES_SHADER
#define GBUFFERS_WATER_SHADER
*/

/* ----- includes ----- */
#include "/block.properties"
#include "/include/config.glsl"

/* ----- main ----- */
#ifdef COLOR
    in vec4 color;
#endif // COLOR

#ifdef NORMAL
    in vec2 normal;
#endif // NORMAL

#ifdef TEXCOORD
    in vec4 texcoord;
    uniform sampler2D texture; // 纹理
#endif // TEXCOORD

#ifdef LMCOORD
    in vec4 lmcoord;
    uniform sampler2D lightmap; // 光强图
    uniform int worldTime;      // 一天中的时间 [0, 24000]
#endif // LMCOORD

#ifdef FOG
    uniform int fogMode; // 雾模式 [2048, 9729]
#endif // FOG

#ifdef DISCARD_WHEN_CLOUD
    uniform int blockEntityId;
#endif // DISCARD_WHEN_CLOUD

#ifdef GBUFFERS_TERRAIN_SHADER
    in vec3 loop_position;
#endif // GBUFFERS_TERRAIN_SHADER

#ifdef GBUFFERS_ENTITIES_SHADER
    uniform vec4 entityColor; // 实体颜色（比如受击反馈）
#endif // GBUFFERS_ENTITIES_SHADER

#ifdef GBUFFERS_WATER_SHADER
    in float waterTag;
    in float blockId;
#endif // GBUFFERS_WATER_SHADER

void main() {
/* DRAWBUFFERS:024 */

    #ifdef DISCARD_WHEN_CLOUD
        if(blockEntityId == 0 && ENABLE_CLOUD) {
            discard;
        }
    #endif // DISCARD_WHRN_CLOUD

    vec4 current_color = vec4(1.0);

    #ifdef COLOR
        current_color *= color;
    #endif // COLOR;

    #ifdef TEXCOORD
        current_color *= texture2D(texture, texcoord.st);
    #endif // TEXCOORD

    #ifdef LMCOORD
        float brightness_multiple;
        float fTime = float(worldTime);
        if(fTime <= SUNSET_START) brightness_multiple = BRIGHTNESS_MULTIPLE_DAY;
        else if(fTime <= SUNSET_END) {
            brightness_multiple = mix(BRIGHTNESS_MULTIPLE_DAY, BRIGHTNESS_MULTIPLE_NIGHT, smoothstep(SUNSET_START, SUNSET_END, fTime));
        } else if(fTime <= SUNRISE_START) {
            brightness_multiple = BRIGHTNESS_MULTIPLE_NIGHT;
        } else if(fTime <= SUNRISE_END) {
            brightness_multiple = mix(BRIGHTNESS_MULTIPLE_NIGHT, BRIGHTNESS_MULTIPLE_DAY, smoothstep(SUNRISE_START, SUNRISE_END, fTime));
        }
        current_color *= texture2D(lightmap, lmcoord.st) * brightness_multiple;
    #endif // LMCOORD

    #ifdef FOG
        if(fogMode == 9729)
            current_color.rgb = mix(gl_Fog.color.rgb, current_color.rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
        else if(fogMode == 2048)
            current_color.rgb = mix(gl_Fog.color.rgb, current_color.rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
    #endif // FOG

    #ifdef HIGHTLIGHT_THIS
        current_color = vec4(1.0);
    #endif // HIGHTLIGHT_THIS

    #ifdef GBUFFERS_TERRAIN_SHADER
        if(RENDER_VERTEX_POSITION)
            current_color = vec4(loop_position, 1.0);
    #endif // GBUFFERS_TERRAIN_SHADER

    #ifdef GBUFFERS_ENTITIES_SHADER
        current_color.rgb = mix(current_color.rgb, entityColor.rgb, entityColor.a);
    #endif // GBUFFERS_ENTITIES_SHADER

    #ifdef GBUFFERS_WATER_SHADER
        if(int(blockId) == BLOCK_WATER) {
            current_color = vec4(vec3(0.5), WATER_TRANSPARENT_STRENGTH) * texture2D(lightmap, lmcoord.st) * mix(vec4(1.0), color, WATER_BLUE_STRENGTH);
        }
        gl_FragData[2] = vec4(waterTag, 0.0, 0.0, 1.0);
    #endif // GBUFFERS_WATER_SHADER

    gl_FragData[0] = current_color;

    #ifdef NORMAL
        gl_FragData[1] = vec4(normal, 0.0, 1.0);
    #endif // NORMAL
}