/*
utility

contains several useful utility functions
*/

float sqrt1(float x) { // x must in [0.0, 1.0]
    return x * (2.0 - x);
}

float length2(vec3 vec) {
    return vec.x * vec.x + vec.y * vec.y + vec.z * vec.z;
}

void normalLimitInout(inout vec3 normal) {
    normal.y = clamp(normal.y, -89.0, 89.0);
}

vec2 normalEncode(vec3 normal) {
    vec2 enc = normalize(normal.xy) * (sqrt(-normal.z*0.5+0.5));
    enc = enc*0.5+0.5;
    return enc;
}

vec3 normalDecode(vec2 enc) {
    vec4 nn = vec4(2.0 * enc - 1.0, 1.0, -1.0);
    float l = dot(nn.xyz,-nn.xyw);
    nn.z = l;
    nn.xy *= sqrt(l);
    return nn.xyz * 2.0 + vec3(0.0, 0.0, -1.0);
}

