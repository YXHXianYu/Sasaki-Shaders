#version 450 compatibility
/* DRAWBUFFERS:02 */

in vec4 color;
in vec2 normal;

void main() {
    gl_FragData[0] = color;
    
    gl_FragData[1] = vec4(normal, 0.0, 1.0);
}