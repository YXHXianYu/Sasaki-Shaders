# Sasaki-Shaders

* A fundamental Minecraft shaderspack.

* This shader is made for fun.

### Features

* Waving Grass and Leaves
* Bloom
* Shadow
  * Using shadow mapping and percentage closer filter
* Clouds
  * Based on [iq's clouds](https://www.shadertoy.com/view/XslGRr) and using Ray Marching
  * A lot of improvements are needed...
* Water Reflection
  * Using 3D Screen Space Reflection (Ray Tracing)
* Dynamic & Transparent Water

### TODO

* 阴影算法优化
  * 目前阴影是采用GLSL自带的2*2 PCF，可以看作残缺的PCSS，软阴影效果不足。
  * 可以将阴影算法替换为VSSM或MSM，效果将大大提升。
* 雨天适配
  * 云
  * 雨滴
  * 雾气
* 地狱适配

### Preview

![2023-01-01_15.35.02](README/2023-01-01_15.35.02.png)

### Minecraft versions

* Suggestion version: 1.18.2

### Reference

- I made this shader according to [szszss's article](http://blog.hakugyokurou.net/?page_id=1655) and it is really well written.
  - This article is using minecraft 1.7.10, so I adjust shader's code and let it run in 1.18.2.

### Sasaki！

* This shader's name comes from my favorite galgame [Flowers](https://zh.moegirl.org.cn/FLOWERS(Innocent_Grey)#) o(\*￣▽￣\*)o. 