#ifndef _CONFIG_GLSL_
#define _CONFIG_GLSL_
// Shaders Config

/* Shadow Mapping */
const bool shadowHardwareFiltering = true; // [true]
const int shadowMapResolution = 2048; // Hardware PCF Resolution set to 2048 [1024, 2048, 4096, etc]

const float SHADOW_MAP_BIAS = 0.85; // Dome Projection Coefficient [0.6, 0.8, 0.85, 0.9, etc]

/* Bloom */
const float BLOOM_STRENGTH = 0.5; // [0.0 ~ 1.0]

/* Cloud */
const bool ENABLE_CLOUD = true; // [true or false]
const float CLOUD_MIN = 400.0;
const float CLOUD_MAX = 460.0;
const float RAY_MARCHING_TIMES = 64;
const float RAY_MARCHING_DIRECTION_Y_LIMIT = 0.05;

/* Water Reflection */
const bool ENABLE_WATER_REFLECTION = true; // [true or false]
const bool ENABLE_JITTER = true; // [true or false]

/* Dynamic Water */
const float DYNAMIC_WATER_STRENGTH = 0.1; // [0.0 ~ 0.5]

/* Transparent Water */
const float WATER_TRANSPARENT_STRENGTH = 0.5; // [0.0 ~ 1.0] bigger => not transparent
const float WATER_BLUE_STRENGTH = 0.4; // [0.0 ~ 1.0]

/* Some Special Mode */
const bool RENDER_Z_BUFFER = false; // render z-buffer (depth buffer) [true of false]
const bool RENDER_VERTEX_POSITION = false; // render vertex position [true of false]

/* Enable Color Texture */
// This code used to set in final.fsh
// If you don't know what you are doing, do not modify the following content.
const int RG16 = 0;
const int gnormalFormat = RG16; // normal
const int RGB8 = 0;
const int colortex1Format = RGB8; // bloom
const int colortex3Format = RGB8; // bloom cache
const int R8 = 0;
const int colortex4Format = R8; // water tag

#endif // _CONFIG_GLSL_