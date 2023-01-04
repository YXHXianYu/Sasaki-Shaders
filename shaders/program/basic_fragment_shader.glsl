/*
basic fragment shader

draw buffers are tex0(gcolor), tex2(gnormal)

use:
#version 450 compatibility

#define COLOR
#define NORMAL
#define TEXCOORD
#define LMCOORD
#define FOG

// #include "/program/basic_fragment_shader.glsl"

extra:
#define HIGHTLIGHT_THIS       // used to hightlight some block
#define DISCARD_WHEN_CLOUD // used in gbuffers_textured.fsh
#define GBUFFERS_TERRAIN_SHADER
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

void main() {
/* DRAWBUFFERS:02 */

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
        current_color *= texture2D(lightmap, lmcoord.st) * BRIGHTNESS_MULTIPLE;
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

    gl_FragData[0] = current_color;

    #ifdef NORMAL
        gl_FragData[1] = vec4(normal, 0.0, 1.0);
    #endif // NORMAL
}