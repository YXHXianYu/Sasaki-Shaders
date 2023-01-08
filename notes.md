# Notes

### 1. 关于GLSL140升级到GLSL450

* 版本混乱是GLSL的一大特点，由于szszss的教程是以GLSL140版本为主，而现在的Optifine已经支持更新版本的GLSL；同时为了更好地掌握GLSL，所以我对代码的所有旧接口进行替换
* 而国内这方便的资源教程远远不足，所以只能自己查GLSL的文档了
  * [The OpenGL Shading Language 4.5 Document](https://registry.khronos.org/OpenGL/specs/gl/GLSLangSpec.4.50.pdf)
* 接下来是接口替换的记录

#### 1.1 纹理采样接口

* ~~texture2D~~, shadow2D 替换为 texture
  * 新版的glsl支持函数重载了
  * ~~直接用vscode的文本替换就行了，这里无脑替换即可~~
  * Optifine内置的uniform变量和新版接口重名了···所以没法替换，这里只替换一部分
* attribute, varying 替换为 in/out
* built-in variables不替换了，因为看起来要改好多东西
  * 保留gl_Vertex, gl_Normal等内置变量

### 2. 关于视角朝正下水面变黑问题的总结

* 问题描述：当玩家视角朝向正下方时，水面会变成全黑，并且任何阴影都会消失
* 版本：v0.2.3及之前
* 原因：法线没有归一化
* 详细原因
  * 法线和顶点一样，从world坐标系转换到viewing坐标系中，都需要进行变换。但因为缩放矩阵的原因，所以法线不能直接使用顶点变换的MV矩阵，需要使用[法线矩阵](https://zhuanlan.zhihu.com/p/72734738)或者[其他方法](https://lxjk.github.io/2017/10/01/Stop-Using-Normal-Matrix.html)。
  * 法线矩阵是一个正交矩阵。法线经过法线矩阵变换后，并没有归一化的性质，而法线只表示方向，所以需要归一化。这里，我参考的教程和我的代码都没有对变换后的法线进行归一化。
  * 接着，法线经过压缩和解压的过程，再传入着色器中。在水面反射时，未归一化的法线，和反射光方向做点积，结果炸成了负数，导致fresnel项变成大正数，最终使得水面变黑。
    * 这里，有意思的是，为什么只有在视角朝向正下方，y值等于-90°时，出现问题？目前我还没弄清楚。
* 解决方案：在法线变换后，对法线归一化即可。