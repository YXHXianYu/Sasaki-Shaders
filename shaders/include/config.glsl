#ifndef _CONFIG_GLSL_
#define _CONFIG_GLSL_

/* ----- ----- ----- Shaders Config ----- ----- ----- */

/* Optifine Version*/
// #define OPTIFINE_OLD_VERSION_ENABLE // 如果水面随着你的移动而抖动，那么就启用这个选项

/* Special Rendering Mode */
#define RENDER_Z_BUFFER false // [true false] render z-buffer (depth buffer) 
#define RENDER_VERTEX_POSITION false // [true false] render vertex position 

/* Brightness */
#define BRIGHTNESS_MULTIPLE_DAY 1.1 // [1.0 1.1 1.2]
#define BRIGHTNESS_MULTIPLE_NIGHT 0.9 // [0.8 0.9 1.0]

/* Bloom */
#define BLOOM_STRENGTH 0.2 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0] Bloom

/* Cloud */
#define ENABLE_CLOUD true // [true or false]
#define CLOUD_MIN 400.0 // [0.0, CLOUD_MAX)
#define CLOUD_MAX 460.0 // (CLOUD_MIN, inf)
#define RAY_MARCHING_TIMES 64 // [32 64 128]
#define RAY_MARCHING_DIRECTION_Y_LIMIT 0.05 // [0.01 0.05 0.1 0.5]

/* Water Reflection */
#define ENABLE_WATER_REFLECTION true // [true false]
#define ENABLE_JITTER true // [true false]

/* Dynamic Water */
#define DYNAMIC_WATER_STRENGTH 0.1 // [0.0 0.1 0.2 0.3 0.4 0.5]

/* Transparent Water */
#define WATER_TRANSPARENT_STRENGTH 0.7 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0] bigger => not transparent
#define WATER_BLUE_STRENGTH 0.4 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

/* ----- ----- ----- Shaders Constants ----- ----- ----- */

/* Time of a Day */
const int SUNRISE = 23200;
const int SUNSET = 12800;
const int FADE_START = 500;
const int FADE_END = 250;

const float SUNSET_START = 11500.0;
const float SUNSET_MID1 = 12500.0;
const float SUNSET_MID2 = 13000.0;
const float SUNSET_MID3 = 14000.0;
const float SUNSET_END = 14500.0;
const float SUNRISE_START = 21000.0;
const float SUNRISE_MID1 = 22000.0;
const float SUNRISE_MID2 = 22500.0;
const float SUNRISE_MID3 = 23500.0;
const float SUNRISE_END = 24000.0;

/* ----- ----- ----- System Config ----- ----- ----- */
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

/* Shadow Mapping */
const bool shadowHardwareFiltering = true; // [true] 如果想关闭此选项，则需要同时修改一部分代码
const int shadowMapResolution = 2048; // Hardware PCF Resolution set to 2048 [512 1024 2048 4096]
// 注：MC的软阴影，使用了GLSL自带的2*2 filter size的PCF，所以效果不好。
// 注：如果手动实现PCSS算法，那么阴影的效果会大大提升！
#define SHADOW_MAP_BIAS 0.85 // Dome Projection Coefficient [0.6, 0.8, 0.85, 0.9, etc]

/* Set Noise Texture Resolution */
const int noiseTextureResolution = 256;

#endif // _CONFIG_GLSL_