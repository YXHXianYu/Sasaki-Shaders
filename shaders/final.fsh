#version 120
 
uniform sampler2D gcolor;
 
varying vec4 texcoord;

/* Bloom - Begin */
uniform sampler2D colortex1;
vec3 Bloom(vec3 color, float coefficient) {
    vec3 hightlight = texture2D(colortex1, texcoord.st).rgb;
    return color + hightlight * clamp(coefficient, 0.0, 1.0);
}
/* Bloom - End */

/* Tone Mapping - Begin*/
float A = 0.15;
float B = 0.50;
float C = 0.10;
float D = 0.20;
float E = 0.02;
float F = 0.30;
float W = 13.134;
 
vec3 uncharted2Tonemap(vec3 x) {
    return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

vec3 ToneMapping(vec3 color) {
    color = pow(color, vec3(1.4));
    color *= 6.0;
    vec3 curr = uncharted2Tonemap(color);
    vec3 whiteScale = 1.0f/uncharted2Tonemap(vec3(W));
    return curr*whiteScale;
}
/* Ton Mapping - End */


void main() {
    vec3 color =  texture2D(gcolor, texcoord.st).rgb;
    color = Bloom(color, 0.2);
    color = ToneMapping(color);
    gl_FragColor = vec4(color, 1.0);
}