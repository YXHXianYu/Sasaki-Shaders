#version 450 compatibility
/* DRAWBUFFERS:02 */

uniform sampler2D texture;

in vec4 color;
in vec4 texcoord;
in vec2 normal;

void main() {
    gl_FragData[0] = texture2D(texture, texcoord.st) * color;
    
    gl_FragData[1] = vec4(normal, 0.0, 1.0);
}