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