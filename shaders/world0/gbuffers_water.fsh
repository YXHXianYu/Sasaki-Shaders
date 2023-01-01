#version 450
/* DRAWBUFFERS:024 */

/* includes */
#include "/include/config.glsl"

uniform int fogMode;
uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec2 normal;
varying float attr;

varying vec3 origin_normal;
varying vec3 origin_position;

void main() {
    // first term: remove the texture of water
    // third term: make the water less blue
    gl_FragData[0] = vec4(vec3(0.5), WATER_TRANSPARENT_STRENGTH) * texture2D(lightmap, lmcoord.st) * mix(vec4(1.0), color, WATER_BLUE_STRENGTH);

    if(fogMode == 9729)
        gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
    else if(fogMode == 2048)
        gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));

    gl_FragData[1] = vec4(normal, 0.0, 1.0);
    gl_FragData[2] = vec4(attr, 0.0, 0.0, 1.0);
}