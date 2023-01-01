#version 450
/* DRAWBUFFERS:02 */

/* includes */
#include "/include/config.glsl"

// noise
const int noiseTextureResolution = 256;

uniform sampler2D texture;
uniform sampler2D lightmap;

uniform int fogMode;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec2 normal;

varying vec3 vertex_position; // for render vertex position mode

void main() {
    if(RENDER_VERTEX_POSITION) {
        gl_FragData[0] = vec4(vertex_position, 1.0);
    } else {
        gl_FragData[0] = texture2D(texture, texcoord.st) * texture2D(lightmap, lmcoord.st) * color;

        if(fogMode == 9729)
            gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
        else if(fogMode == 2048)
            gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
    }

    gl_FragData[1] = vec4(normal, 0.0, 1.0);
}