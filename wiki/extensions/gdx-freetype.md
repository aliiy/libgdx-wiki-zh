---
title: Gdx freetype 扩展
---
## 简介

如果想在游戏中绘制文本，通常会使用 [BitmapFont](/wiki/graphics/2d/fonts/bitmap-fonts)。
但它存在一个缺点：

* **BitmapFont 依赖图像，因此如果需要不同大小就必须缩放，效果可能很难看。**

你也可以保存游戏所需最大尺寸的 BitmapFont，这样就不必放大，只需缩小，对吧？确实如此，但大幅缩小时，根据是否使用 mipmap，结果可能出现锯齿或略微模糊。[距离场字体](https://libgdx.com/wiki/graphics/2d/fonts/distance-field-fonts)旨在解决这个问题，但本文不讨论它！

BitmapFont 占用的存储空间也可能比对应的 TrueType 字体（.ttf）更多，不过这些字体是否比 gdx-freetype 本身占用更多空间，取决于你的游戏和目标平台。

解决方案是使用 `gdx-freetype` 扩展：
  * 游戏只需携带轻量的 .ttf 文件
  * 在运行时生成所需大小的 BitmapFont
  * 允许用户将自己的字体放入游戏

教程见 [https://libgdxinfo.wordpress.com](https://libgdxinfo.wordpress.com/basic-label/)。

## 详细信息

由于这是一个扩展，默认不会包含在 libGDX 项目中。添加扩展的方式取决于项目的设置方式。

### 如何将 gdx-freetype 加入项目

#### 对于使用 Gradle 的项目

对于新项目，只需在[设置界面](https://libgdx.com/dev/project-generation/)的扩展选项中选择 Freetype。

要添加到现有 Gradle 项目，请参阅 [使用 Gradle 管理依赖](/wiki/articles/dependency-management-with-gradle#freetypefont-gradle)。

#### HTML5

gdx-freetype 与 HTML5 不兼容。不过，可以使用 Intrigus 提供的 [gdx-freetype-gwt](https://github.com/intrigus/gdx-freetype-gwt) 库来启用 HTML5 功能。1.9.10.1 版本仍与包括 1.10.0 在内的较新 libGDX 版本兼容。

### 如何在代码中使用 gdx-freetype

在代码中使用 gdx-freetype 扩展非常简单。

```java
FreeTypeFontGenerator generator = new FreeTypeFontGenerator(Gdx.files.internal("fonts/myfont.ttf"));
FreeTypeFontParameter parameter = new FreeTypeFontParameter();
parameter.size = 12;
BitmapFont font12 = generator.generateFont(parameter); // font size 12 pixels
generator.dispose(); // don't forget to dispose to avoid memory leaks!
```
显示字体的更简单方法是将字体文件放入项目的 assets 文件夹。你只需修改上面代码的第一行，并在参数中写入字体文件名。

[FreeTypeFontParameter](https://github.com/libgdx/libgdx/blob/master/extensions/gdx-freetype/src/com/badlogic/gdx/graphics/g2d/freetype/FreeTypeFontGenerator.java) 的默认值：
```java
/** The size in pixels */
public int size = 16;
/** Foreground color (required for non-black borders) */
public Color color = Color.WHITE;
/** Border width in pixels, 0 to disable */
public float borderWidth = 0;
/** Border color; only used if borderWidth > 0 */
public Color borderColor = Color.BLACK;
/** true for straight (mitered), false for rounded borders */
public boolean borderStraight = false;
/** Offset of text shadow on X axis in pixels, 0 to disable */
public int shadowOffsetX = 0;
/** Offset of text shadow on Y axis in pixels, 0 to disable */
public int shadowOffsetY = 0;
/** Shadow color; only used if shadowOffset > 0 */
public Color shadowColor = new Color(0, 0, 0, 0.75f);
/** The characters the font should contain */
public String characters = DEFAULT_CHARS;
/** Whether the font should include kerning */
public boolean kerning = true;
/** The optional PixmapPacker to use */
public PixmapPacker packer = null;
/** Whether to flip the font vertically */
public boolean flip = false;
/** Whether or not to generate mip maps for the resulting texture */
public boolean genMipMaps = false;
/** Minification filter */
public TextureFilter minFilter = TextureFilter.Nearest;
/** Magnification filter */
public TextureFilter magFilter = TextureFilter.Nearest;
```

如果要渲染大字体，默认的 PixmapPacker 页面尺寸可能太小。你可以提供自己的 PixmapPacker，或使用 `FreeTypeFontGenerator.setMaxTextureSize` 设置默认页面尺寸。

你可能希望在游戏的 `resize ()` 事件中生成字体，以便在不缩放的情况下适应不同窗口分辨率，同时记得销毁旧的 BitmapFont。字体大小应限制在页面尺寸能够容纳的范围内，尤其是在 gdx-freetype-gwt 上，以避免字体出现异常和程序崩溃。

### 示例

```java
parameter.borderColor = Color.BLACK;
parameter.borderWidth = 3;
```
![images/border.png](/assets/wiki/images/border.png)

```java
parameter.shadowColor = Color.BLACK;
parameter.shadowOffsetX = 3;
parameter.shadowOffsetY = 3;
```
![images/shadow.png](/assets/wiki/images/shadow.png)

你也可以使用 AssetManager 加载通过 FreeType 扩展生成的 `BitmapFont`。参见 [FreeTypeFontLoaderTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/extensions/FreeTypeFontLoaderTest.java)。

### 注意事项

引用自 [https://web.archive.org/web/20201128081723/https://www.badlogicgames.com/wordpress/?p=2300](https://web.archive.org/web/20201128081723/https://www.badlogicgames.com/wordpress/?p=2300)：
  * 亚洲文字“可能”可以使用，但仍请注意上面的限制。它们包含的字形太多了，我正在考虑解决方法。
  * 阿拉伯语等从右向左书写的文字不可用。BitmapFont 和 BitmapFontCache 的布局“算法”完全不知道如何处理这种文字。
  * 随便将字体交给 FreeType 并不是好主意。实际存在的一些字体质量很差，字距调整信息不完善甚至没有，渲染效果会非常糟糕。

----

下载一个[示例](https://hg.sr.ht/~dermetfan/somelibgdxtests)
