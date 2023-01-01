#version 450
/* DRAWBUFFERS:02 */

varying vec4 color;
varying vec2 normal;

void main() {
    gl_FragData[0] = color;
    
    gl_FragData[1] = vec4(normal, 0.0, 1.0);
}