#version 450 compatibility
 
uniform sampler2D texture;
 
in vec4 texcoord;
 
void main() {
    gl_FragData[0] = texture2D(texture, texcoord.st);
}