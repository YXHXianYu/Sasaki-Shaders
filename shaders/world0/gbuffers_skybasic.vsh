#version 450

varying vec4 color;
varying vec2 normal;
 
vec2 normalEncode(vec3 n) {
    vec2 enc = normalize(n.xy) * (sqrt(-n.z*0.5+0.5));
    enc = enc*0.5+0.5;
    return enc;
}

void main() {
    gl_Position = ftransform();
    color = gl_Color;
    normal = normalEncode(gl_NormalMatrix * gl_Normal);
}