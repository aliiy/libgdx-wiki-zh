---
title: 位图字体
---
libGDX 使用位图文件（PNG）渲染字体。字体中的每个字形都有对应的 TextureRegion。

[BitmapFont class](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/BitmapFont.html) [(code)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g2d/BitmapFont.java)

BitmapFont 在 libGDX 1.5.6 版本中进行了重构。[这篇博客文章](https://web.archive.org/web/20200928220256/https://www.badlogicgames.com/wordpress/?p=3658)详细介绍了这些变更，并提供了一个将 1.5.6 之前的代码迁移到新 API 的小示例。

关于 BitmapFont 的使用教程见 [https://libgdxinfo.wordpress.com](https://libgdxinfo.wordpress.com/basic-label/)。

## 字体文件格式规范

资料显示，bmFont 最初由 Andreas Jönsson 在 [AngelCode](https://www.angelcode.com/) 创建。

[BMFont](https://www.angelcode.com/products/bmfont/doc/file_format.html) - 文件格式的原始规范。

## 创建位图的工具

* [Hiero](/wiki/tools/hiero) - 将系统字体转换为位图的工具
* [Skin Composer](/wiki/tools/skin-composer) - 包含 BitmapFont 编辑器和图像字体生成器
* [BMFont](https://www.angelcode.com/products/bmfont/) - 支持超采样、可生成更平滑字形的 Windows 工具
* [bmGlyph](https://www.bmglyph.com/) - 支持自定义图像的 macOS 工具
* [fontwriter](https://github.com/tommyettinger/fontwriter) - 用于生成字体的命令行工具，可配合 [TextraTypist](https://github.com/tommyettinger/textratypist) 或 [BitmapFontBridge](https://github.com/tommyettinger/BitmapFontBridge) 库使用

## 其他工具

[FreeTypeFontGenerator](https://web.archive.org/web/20200423064636/ttp://www.badlogicgames.com/wordpress/?p=2300) - 为字体生成位图，而不是提供由 Hiero 等工具预先渲染的位图

示例
: [(more)](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/extensions/InternationalFontsTest.java)

```java
FreeTypeFontGenerator generator = new FreeTypeFontGenerator(Gdx.files.internal("unbom.ttf"));
parameter.size = 18;
parameter.characters = "한국어/조선말";
BitmapFont koreanFont = generator.generateFont(parameter);
generator.dispose();
```

[距离场字体](/wiki/graphics/2d/fonts/distance-field-fonts) - 可在缩放或旋转字体时避免难看的失真

## 3D 空间中的字体
虽然 libGDX 不直接支持将文本放置在 3D 空间中，但仍然可以相对轻松地实现。示例请参阅[此 gist](https://gist.github.com/Darkyenus/e9427b0655816d2a521227cb9313d303)。注意，由于 `SpriteBatch` 使用固定的 `z` 进行绘制，这类文本不会被前方的对象遮挡；不过使用自定义着色器并从 uniform 设置适当的 `z` 并不困难。

## 等宽字体
需要让每个字形以相同宽度显示的字体会遇到一个特殊问题。默认情况下，`|` 等窄字符左侧原本的空白不会显示，窄字符会紧贴在前一个字符之后，而不是保留预期的空白。这还可能导致该字符的宽度更小，使多行文本彼此无法对齐。现有的 `BitmapFont#setFixedWidthGlyphs(CharSequence)` 方法可以为给定 `CharSequence`（通常是 String）中的字符解决这些问题。但需要列出字体中所有需要具有相同宽度的字形，大字体这样做会相当麻烦。如果只使用 ASCII 或其小幅扩展，Hiero 提供 ASCII 和 NeHe 按钮，可将常用的小字符集填入文本框，然后将文本复制到传给 `setFixedWidthGlyphs()` 的 String 中。如果等宽字体可使用的字符列表非常大或未知，可以使用下面的代码将每个字形设为等宽，并对所有字形使用最大的字形宽度：

```java
public static void setAllFixedWidth(BitmapFont font) {
    BitmapFont.BitmapFontData data = font.getData();
    int maxAdvance = 0;
    for (int index = 0, end = 65536; index < end; index++) {
        BitmapFont.Glyph g = data.getGlyph((char) index);
        if (g != null && g.xadvance > maxAdvance) maxAdvance = g.xadvance;
    }
    for (int index = 0, end = 65536; index < end; index++) {
        BitmapFont.Glyph g = data.getGlyph((char) index);
        if (g == null) continue;
        g.xoffset += (maxAdvance - g.xadvance) / 2;
        g.xadvance = maxAdvance;
        g.kerning = null;
        g.fixedWidth = true;
    }
}
```
