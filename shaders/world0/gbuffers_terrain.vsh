#version 450 compatibility

/* ----- include ----- */
#include "/block.properties"

// noise
uniform sampler2D noisetex;

// moving grass
uniform float frameTimeCounter;
uniform vec3 cameraPosition;
in vec4 mc_Entity;
in vec4 mc_midTexCoord;
uniform float rainStrength; // when it's raining, grass will move strengly

out vec4 color;
out vec4 texcoord;
out vec4 lmcoord;
out vec2 normal;

out vec3 vertex_position; // for render vertex position mode
 
vec2 normalEncode(vec3 n) {
    vec2 enc = normalize(n.xy) * (sqrt(-n.z*0.5+0.5));
    enc = enc*0.5+0.5;
    return enc;
}

uniform mat4 gbufferModelView;

void main() {
    vec4 position = gl_Vertex;
    vec3 sample_position = mod(gl_Vertex.xyz + cameraPosition, 16.0); // for 1.18.2

    int blockId = int(mc_Entity.x + 0.5);
    if((blockId == BLOCK_SMALL_PLANTS || blockId == BLOCK_PLANTS || blockId == BLOCK_DOUBLE_PLANTS_UPPER) && gl_MultiTexCoord0.t < mc_midTexCoord.t) {
        vec3 noise = texture(noisetex, sample_position.xz / 256.0).rgb; // 16 * 16 * 16; repeat (loop)
        float maxStrength = 1.0 + rainStrength * 0.5;
        float time = frameTimeCounter * 2.0;
        float reset = cos(noise.z * 10.0 + time * 0.1);
        reset = max( reset * reset, max(rainStrength, 0.1));
        position.x += sin(noise.x * 10.0 + time) * 0.2 * reset * maxStrength;
        position.z += sin(noise.y * 10.0 + time) * 0.2 * reset * maxStrength;
    } else if(mc_Entity.x == BLOCK_LEAVES)  {
        vec3 noise = texture(noisetex, (sample_position.xz + 0.5) / 16.0).rgb; // 16 * 16 * 16; repeat (loop)
        float maxStrength = 1.0 + rainStrength * 0.5;
        float time = frameTimeCounter * 3.0;
        float reset = cos(noise.z * 10.0 + time * 0.1);
        reset = max( reset * reset, max(rainStrength, 0.1));
        position.x += sin(noise.x * 10.0 + time) * 0.07 * reset * maxStrength;
        position.z += sin(noise.y * 10.0 + time) * 0.07 * reset * maxStrength;
    }

    gl_Position = gl_ModelViewProjectionMatrix * position;
    gl_FogFragCoord = length(position.xyz);

    color = gl_Color;
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    normal = normalEncode(gl_NormalMatrix * gl_Normal);

    vertex_position = mod(gl_Vertex.xyz + cameraPosition, 16.0);
}