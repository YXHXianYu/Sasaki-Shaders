#version 450 compatibility

out vec4 color;
out vec4 texcoord;
out vec4 lmcoord;
out vec2 normal;
 
vec2 normalEncode(vec3 n) {
    vec2 enc = normalize(n.xy) * (sqrt(-n.z*0.5+0.5));
    enc = enc*0.5+0.5;
    return enc;
}

void main() {
    vec4 position = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = gl_ProjectionMatrix * position;
    gl_FogFragCoord = length(position.xyz);

    color = gl_Color;
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    normal = normalEncode(gl_NormalMatrix * gl_Normal);
}