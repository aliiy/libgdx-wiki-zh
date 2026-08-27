---
title: 距离场字体
---
## 渲染极其平滑且可缩放的位图字体

有符号距离场渲染技术曾用于 Team Fortress 2，Valve 的 Chris Green 在 SIGGRAPH 2007 论文[《Improved Alpha-Tested Magniﬁcation for Vector Textures and Special Effects》](https://steamcdn-a.akamaihd.net/apps/valve/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf)中对其进行了介绍。它可以让位图字体即使在高倍放大时也没有锯齿边缘。本文介绍如何在 libGDX 中实现这一技术。

# 简介

传统位图字体在字体图像像素与屏幕像素一一对应时效果很好。但旋转后效果较差，放大后会更糟：要么能看到单个像素，要么开启线性插值后得到模糊的图像。

使用距离场字体可以渲染在旋转和其他任意变换下仍保持清晰的文字，即使大幅放大也不会产生明显的额外运行时开销。差异如下：

![images/distance-field-fonts.png](/assets/wiki/images/distance-field-fonts.png)

同样的技术也可以用于绘制符号、标志等任何内容。主要缺点是它只能用于单色图像，无法用于任意颜色的图像。

libGDX 源码中提供了渲染示例。请查看 `gdx-tests` 项目中的 `com.badlogic.gdx.tests.BitmapFontDistanceFieldTest`，上面的截图就是由它生成的。如果想直接查看用法，还可以参考 [`com.badlogic.gdx.graphics.g2d.DistanceFieldFont.java`](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/BitmapFontDistanceFieldTest.java) 类。

# 工作原理

原理很简单。我们不直接提供一张（可能经过抗锯齿的）黑白字体图像，而是先对它进行预处理，生成一个_有符号距离场_。上方截图最右侧一列展示了字体图像预处理后的样子。

预处理器以黑白图像作为输入，背景为黑色，字形为白色。对于每个白色像素，它会计算到最近黑色像素的距离，反之亦然。黑色像素的距离随后取反，并将结果归一化到 0-1 范围。这样就得到一个平滑、连续的场：原字形边缘处正好是 0.5，向外移动时降至 0.0，向内部移动时升至 1.0。

然后设置 alpha 测试，仅在 alpha 大于 0.5 时输出像素。使用最近邻插值的纹理时，结果看起来会与输入图像完全一致。不过，与传统字体图像相比，距离场图像更适合线性插值：请对比上图的第三列和第四列。

# 生成字体

这个过程与普通[位图字体](/wiki/graphics/2d/fonts/bitmap-fonts)基本相同，只是设置不同。

  * [启动 Hiero](/wiki/tools/hiero)，像平常一样选择字体和属性。
   * 在右侧的 “Effects” 列表中双击 “Distance field”。（如果没有名为 “Distance field” 的过滤器，说明 Hiero 版本过旧。请按照 [Hiero](/wiki/tools/hiero) 页面中的说明尝试 nightly 构建。）
   * 点击 X 移除默认的 “Color” 效果。
   * 根据需要设置距离场颜色。最好保留白色，因为可以在渲染时更改颜色。
   * 将 “Spread” 设置为合适的值。它应约为字体最粗笔画宽度的一半，以像素计。最亮的白色区域应很小，不要损失太多对比度。
   * 在右下角，将四边的 “Padding” 设置为与 spread 相同。此时字形应不再被裁剪。
   * 将 “X” 和 “Y” 设置为 spread 的两倍负值。如果 spread 为 4，则 X 和 Y 都设为 -8。这是因为 padding 会在渲染时增大字形之间的间距。
   * 选择 “Glyph cache” 单选按钮，并设置页面大小，使所有字形尽量无浪费地放在一页中。这样更便于加载。
   * 将 “Scale” 设置为大于 1 的值。之所以最后设置，是因为比例越大，字体生成越慢。32 是一个不错的值。现在应该能得到类似下面的结果：

![images/distance-field-fonts-hiero.png](/assets/wiki/images/distance-field-fonts-hiero.png)

  * 像平常一样将字体保存到 assets 目录。

# 加载字体

将字体加载到游戏中没有什么特殊之处，只需确保为纹理启用线性过滤：
```java
Texture texture = new Texture(Gdx.files.internal("myfont.png"));
texture.setFilter(TextureFilter.Linear, TextureFilter.Linear);
```

为了让字体缩小时（小于 1:1 尺寸）看起来更好，也可以启用 mipmap：
```java
Texture texture = new Texture(Gdx.files.internal("myfont.png"), true); // true enables mipmaps
texture.setFilter(TextureFilter.MipMapLinearNearest, TextureFilter.Linear); // linear filtering in nearest mipmap image
```
可以使用 `MipMapLinearNearest`，也可以使用速度较慢但更平滑的 `MipMapLinearLinear`。

然后创建字体：
```java
BitmapFont font = new BitmapFont(Gdx.files.internal("myfont.fnt"), new TextureRegion(texture), false);
```

*注意*：在 LibGDX 1.6.0（2015 年 5 月）之前，如果用距离场字体替换“普通”字体，请注意两者的字体度量并不相同。特别是额外的 padding 会使基线下移，因此需要将文本绘制得更高来补偿。自 [commit c976f463](https://github.com/libgdx/libgdx/commit/c976f463c3686f6a3a615f2358dc31c25f60ce0d) 起，padding 应会自动补偿。

# 使用着色器渲染

假设你已经熟悉 libGDX 中的着色器；如果还不熟悉，请阅读[着色器页面](/wiki/graphics/opengl-utils/shaders)。

顶点着色器没有特殊之处，可以直接复制 SpriteBatch 默认使用的版本。只需注意按照 `SpriteBatch` 要求的方式命名变量：
```cpp
uniform mat4 u_projTrans;

attribute vec4 a_position;
attribute vec2 a_texCoord0;
attribute vec4 a_color;

varying vec4 v_color;
varying vec2 v_texCoord;

void main() {
    gl_Position = u_projTrans * a_position;
    v_texCoord = a_texCoord0;
    v_color = a_color;
}
```

关键在片段着色器中，但它同样并不复杂：
```cpp
#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;

varying vec4 v_color;
varying vec2 v_texCoord;

const float smoothing = 1.0/16.0;

void main() {
    float distance = texture2D(u_texture, v_texCoord).a;
    float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
    gl_FragColor = vec4(v_color.rgb, v_color.a * alpha);
}
```

假设已将它们分别保存为 assets 目录中的 `font.vert` 和 `font.frag`，就可以像平常一样加载着色器：
```java
ShaderProgram fontShader = new ShaderProgram(Gdx.files.internal("font.vert"), Gdx.files.internal("font.frag"));
if (!fontShader.isCompiled()) {
    Gdx.app.error("fontShader", "compilation failed:\n" + fontShader.getLog());
}
```

要使用此着色器渲染字体，假设已有一个 `SpriteBatch` 且当前位于 `begin()` 和 `end()` 调用之间，过程非常简单：
```java
spriteBatch.setShader(fontShader);
font.draw(spriteBatch, "Hello smooth world!", 10, 10);
spriteBatch.setShader(null);
```

# 自定义着色器

请记住，`distance` 的取值范围是 0 到 1：0 表示远离字母，0.5 表示恰好在边缘，1 表示完全位于字母内部。上面着色器中的 `smoothstep` 函数会将远小于 0.5 的值映射为 0，将远大于 0.5 的值映射为 1，并在 0.5 附近平滑过渡以实现抗锯齿。过渡的柔和程度由 `smoothing` 常量控制，应根据字体和缩放比例进行调整。

清晰字体的正确 `smoothing` 值为 `0.25f / (spread * scale)`，其中 `spread` 是生成字体时使用的值，`scale` 是绘制字体时的缩放比例（距离场字体中的像素如何映射到屏幕像素）。如果缩放比例不固定，可以通过 `uniform` 变量传入。

还可以基于着色器中的 `distance` 变量实现各种其他技巧，下面是一些可能性。这些方法我都没有测试；如果发现问题，请更新此 wiki 页面！

## 添加描边

思路是：当 `distance` 位于 `outlineDistance` 和 `0.5` 之间时输出另一种颜色。

```cpp
...
const float outlineDistance; // Between 0 and 0.5, 0 = thick outline, 0.5 = no outline
const vec4 outlineColor;
...
void main() {
    float distance = texture2D(u_texture, v_texCoord).a;
    float outlineFactor = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
    vec4 color = mix(outlineColor, v_color, outlineFactor);
    float alpha = smoothstep(outlineDistance - smoothing, outlineDistance + smoothing, distance);
    gl_FragColor = vec4(color.rgb, color.a * alpha);
}
```

## 添加投影

这里会再次采样纹理，采样位置相对第一次略有偏移。第二次采样会应用更多平滑处理，并渲染在实际文字的“后方”。

```cpp
...
const vec2 shadowOffset; // Between 0 and spread / textureSize
const float shadowSmoothing; // Between 0 and 0.5
const vec4 shadowColor;
...
void main() {
    float distance = texture2D(u_texture, v_texCoord).a;
    float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
    vec4 text = vec4(v_color.rgb, v_color.a * alpha);

    float shadowDistance = texture2D(u_texture, v_texCoord - shadowOffset).a;
    float shadowAlpha = smoothstep(0.5 - shadowSmoothing, 0.5 + shadowSmoothing, shadowDistance);
    vec4 shadow = vec4(shadowColor.rgb, shadowColor.a * shadowAlpha);

    gl_FragColor = mix(shadow, text, text.a);
}
```

# 对任意图像使用距离场

Hiero 使用的生成器也可以作为独立命令行工具，处理已有的黑白图像。从解压后的 libGDX 发行版目录运行：

Windows:
```shell
java -cp gdx.jar;gdx-natives.jar;gdx-backend-lwjgl.jar;gdx-backend-lwjgl-natives.jar;extensions\gdx-tools\gdx-tools.jar com.badlogic.gdx.tools.distancefield.DistanceFieldGenerator
```

Linux:
```shell
java -cp gdx.jar:gdx-natives.jar:gdx-backend-lwjgl.jar:gdx-backend-lwjgl-natives.jar:extensions/gdx-tools/gdx-tools.jar com.badlogic.gdx.tools.distancefield.DistanceFieldGenerator
```

这会打印用法说明：
```
Generates a distance field image from a black and white input image.
The distance field image contains a solid color and stores the distance
in the alpha channel.

The output file format is inferred from the file name.

Command line arguments: INFILE OUTFILE [OPTION...]

Possible options:
  --color rrggbb    color of output image (default: ffffff)
  --downscale n     downscale by factor of n (default: 1)
  --spread n        edge scan distance (default: 1)
```

选项与上文介绍的 Hiero 选项类似，但 `spread` 以_输入_图像中的像素为单位，而不是缩小后的输出图像。要获得相同结果，应将其乘以 `downscale`。还要注意，默认值可能并不理想，最好同时指定 `--downscale` 和 `--spread`：
```
java -cp extensions/gdx-tools.jar:gdx.jar com.badlogic.gdx.tools.distancefield.DistanceFieldGenerator
     --downscale 32
     --spread 128
     logo.png logo-df.png
```
