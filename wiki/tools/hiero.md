---
title: Hiero
---
Hiero 是一个位图字体打包工具。它以 [Angel Code 字体](https://www.angelcode.com/products/bmfont/)格式保存，libGDX 应用中的 [BitmapFont](/wiki/graphics/2d/fonts/bitmap-fonts) 可以使用该格式。

![](/assets/wiki/images/hiero01.png)

## 运行 Hiero

可以[在此处](https://libgdx-nightlies.s3.eu-central-1.amazonaws.com/libgdx-runnables/runnable-hiero.jar)下载 .jar 文件。将其设为可执行文件（如果使用类 UNIX 操作系统），然后运行。

由于 Hiero 仍运行在 LWJGL 2 后端上，使用较新的 Java 版本可能会遇到问题。为稳妥起见，请使用 [Adoptium 的 OpenJDK 8](https://adoptium.net/index.html)。
{: .notice--warning}

如果使用 Gradle 并将 “Tools” 扩展添加到项目中，就可以直接从 IDE 运行 Hiero；否则请参阅“下载 Hiero”。

以 IntelliJ IDEA 为例：找到 Hiero 类，右键并选择 `Run Hiero.main()`。在随后出现的 `Run configurations` 弹窗中选择 `Desktop` 模块，然后点击 `Run`。

## 光栅化

Hiero 提供多种字体光栅化选项：

* FreeType 通常能提供最高质量。它充分利用字形微调，因此小字体也能良好渲染。`gamma` 设置控制抗锯齿程度，`mono` 设置禁用所有字体平滑。它不支持其他效果，不过可以为字形增加内边距，或使用 Photoshop 等工具应用效果。Hiero 使用 gdx-freetype，因此生成的位图字体会与 gdx-freetype 运行时生成的字体完全一致。
* Java 字体渲染会提供字形的矢量轮廓，因此可以应用投影、描边等各种效果。小尺寸输出通常较模糊，但大尺寸质量很好。
* 操作系统原生渲染最为简单。它不会提供紧密贴合的边界，因此字形会占用更多图集空间。

对于包含字偶距条目的字体，Hiero 会输出字偶距信息。

## 命令行参数

Hiero 支持 4 个命令行参数：

* `--input <file>` 或 `-i <file>`：启动时加载指定的 `.hiero` 配置文件。
* `--output <file>` 或 `-o <file>`：将输出 `.fnt` 文件设置为指定值。
* `--batch` 或 `-b`：让 hiero 自动生成输出并关闭，无需人工干预。
* `--scale <scale>` 或 `-s <scale>`：按指定倍率缩放字体。

## 替代方案

### BitmapFontWriter

BitmapFontWriter 是 gdx-tools 中的一个类，可以根据 BitmapFontData 实例写出 BMFont 文件。它允许使用 FreeTypeFontGenerator 生成字体，然后写入字体文件和 PNG 文件。BitmapFontWriter 更容易从脚本运行，也可以利用 FreeTypeFontGenerator 的阴影和边框。除此之外，它的输出与 Hiero 非常相似，不过当不同字符代码渲染出相同字形时，Hiero 会避免重复写入字形图像。

用法示例：

```java
new LwjglApplication(new ApplicationAdapter() {
	public void create () {
		FontInfo info = new FontInfo();
		info.padding = new Padding(1, 1, 1, 1);

		FreeTypeFontParameter param = new FreeTypeFontParameter();
		param.size = 13;
		param.gamma = 2f;
		param.shadowOffsetY = 1;
		param.renderCount = 3;
		param.shadowColor = new Color(0, 0, 0, 0.45f);
		param.characters = Hiero.EXTENDED_CHARS;
		param.packer = new PixmapPacker(512, 512, Format.RGBA8888, 2, false, new SkylineStrategy());

		FreeTypeFontGenerator generator = new FreeTypeFontGenerator(Gdx.files.absolute("some-font.ttf"));
		FreeTypeBitmapFontData data = generator.generateData(param);

		BitmapFontWriter.writeFont(data, new String[] {"font.png"},
			Gdx.files.absolute("font.fnt"), info, 512, 512);
		BitmapFontWriter.writePixmaps(param.packer.getPages(), Gdx.files.absolute("imageDir"), name);

		System.exit(0);
	}
});
```

### Skin Composer

[Skin Composer](/wiki/tools/skin-composer) 包含 BitmapFont 编辑器和图像字体生成器。

### BMFont

[BMFont](https://www.angelcode.com/products/bmfont/) 工具使用 FreeType，并提供额外的超采样功能，使字形更加平滑。BMFont 不支持投影或描边等效果，但可以输出带内边距的字形，再使用 Paint.NET、Photoshop 等工具应用效果。

BMFont 仅支持 Windows，但可以使用 [Wine](https://www.winehq.org/) 运行。据报道，导出空格字符时程序可能会挂起。可以手动添加空格字符，例如：
```
char id=32   x=0   y=0    width=0     height=0     xoffset=0    yoffset=0    xadvance=3     page=0  chnl=15
```
根据需要修改 xadvance，它表示空格字符的像素数。

### bmGlyph

[bmGlyph](https://www.bmglyph.com/) 工具仅支持 macOS，并支持将自定义图像嵌入字体。

### fontwriter

[fontwriter](https://github.com/tommyettinger/fontwriter) 是一个命令行工具，用于生成供 [TextraTypist](https://github.com/tommyettinger/textratypist) 或 [BitmapFontBridge](https://github.com/tommyettinger/BitmapFontBridge) 库使用的字体。它支持创建 MSDF 字体，并能获得比 Hiero 更准确的字体度量。
