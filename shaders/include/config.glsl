#ifndef _CONFIG_GLSL_
#define _CONFIG_GLSL_

/* ----- Shaders Config ----- */

/* Basic Config */
const float BRIGHTNESS_MULTIPLE_DAY = 1.2;
const float BRIGHTNESS_MULTIPLE_NIGHT = 0.9;

/* Shadow Mapping */
const bool shadowHardwareFiltering = true; // [true] 如果想关闭此选项，则需要同时修改一部分代码
const int shadowMapResolution = 2048; // Hardware PCF Resolution set to 2048 [1024, 2048, 4096, etc]

const float SHADOW_MAP_BIAS = 0.85; // Dome Projection Coefficient [0.6, 0.8, 0.85, 0.9, etc]

/* Bloom */
const float BLOOM_STRENGTH = 0.5; // [0.0 ~ 1.0]

/* Cloud */
const bool ENABLE_CLOUD = true; // [true or false]
const float CLOUD_MIN = 400.0; // [0.0, CLOUD_MAX)
const float CLOUD_MAX = 460.0; // (CLOUD_MIN, inf)
const float RAY_MARCHING_TIMES = 64; // [32, 64, 128, etc]
const float RAY_MARCHING_DIRECTION_Y_LIMIT = 0.05; // [0.01, 0.05, 0.1, 0.5]

/* Water Reflection */
const bool ENABLE_WATER_REFLECTION = true; // [true or false]
const bool ENABLE_JITTER = true; // [true or false]

/* Dynamic Water */
const float DYNAMIC_WATER_STRENGTH = 0.1; // [0.0 ~ 0.5]

/* Transparent Water */
const float WATER_TRANSPARENT_STRENGTH = 0.5; // [0.0 ~ 1.0] bigger => not transparent
const float WATER_BLUE_STRENGTH = 0.4; // [0.0 ~ 1.0]

/* Time of a Day */
const int SUNRISE = 23200;
const int SUNSET = 12800;
const int FADE_START = 500;
const int FADE_END = 250;

const float SUNSET_START = 11500.0;
const float SUNSET_MID1 = 12300.0;
const float SUNSET_MID2 = 13600.0 - 600.0;
const float SUNSET_MID3 = 14200.0 - 300.0;
const float SUNSET_END = 14500.0;
const float SUNRISE_START = 21000.0;
const float SUNRISE_MID1 = 22000.0;
const float SUNRISE_MID2 = 22500.0;
const float SUNRISE_MID3 = 23500.0;
const float SUNRISE_END = 24000.0;

/* Some Special Rendering Mode */
const bool RENDER_Z_BUFFER = false; // render z-buffer (depth buffer) [true of false]
const bool RENDER_VERTEX_POSITION = false; // render vertex position [true of false]

/* ----- System Config ----- */
// This code used to set in final.fsh
// Do not change the following codes if you don't know what you are doing.

/* Enable Color Texture */
const int RG16 = 0;
const int gnormalFormat = RG16; // normal
const int RGB8 = 0;
const int colortex1Format = RGB8; // bloom
const int colortex3Format = RGB8; // bloom cache
const int R8 = 0;
const int colortex4Format = R8; // water tag
/* Set Noise Texture Resolution */
const int noiseTextureResolution = 256;

#endif // _CONFIG_GLSL_