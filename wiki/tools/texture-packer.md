---
title: TexturePacker
redirect_from:
  - /wiki/graphics/2d/packing-atlases-offline
  - /wiki/graphics/2d/using-textureatlases
---
 * [TexturePacker](#texturepacker)
  * [运行 TexturePacker](#running-texturepacker)
  * [目录结构](#directory-structure)
  * [配置](#configuration)
  * [设置](#settings)
  * [纹理过滤选项](#texture-filter-options)
  * [NinePatch](#ninepatches)
  * [图像索引](#image-indexes)
  * [打包](#packing)
  * [自动打包](#automatic-packing)
 * [TextureAtlas](#textureatlas)

# TexturePacker

在 OpenGL 中，需要绑定纹理、执行绘制，再绑定另一张纹理并继续绘制。绑定纹理的开销相对较高，因此最好将许多小图像存储到一张大图像中，只绑定一次大纹理，然后多次绘制其中的区域。libGDX 提供了 `TexturePacker` 类，这是一个将许多小图像打包到大图像中的命令行应用。它会保存小图像的位置，应用即可通过 `TextureAtlas` 类按名称方便地引用它们。

TexturePacker 使用多种打包算法，其中最重要的算法基于[最大矩形算法](https://web.archive.org/web/20180913014826/http://clb.demon.fi/projects/even-more-rectangle-bin-packing)。它还会使用蛮力算法，根据各种启发式规则和尺寸进行多次打包，然后选择效率最高的结果。

## 运行 TexturePacker

### 图形界面

如果希望使用 GUI 打包纹理，可以使用 [Texture Packer GUI](https://github.com/crashinvaders/gdx-texture-packer-gui)。如果使用 Scene2d Skin，可能已经在使用 [Skin Composer](https://github.com/raeleus/skin-composer)，也可以通过其友好的界面将纹理添加到 Skin 的图集中。

### 从源代码运行
`TexturePacker` 类位于 gdx-tools 项目中，可以通过 Eclipse 从源代码运行：

```java
import com.badlogic.gdx.tools.texturepacker.TexturePacker;
public class MyPacker {
	public static void main (String[] args) throws Exception {
		TexturePacker.process(inputDir, outputDir, packFileName);
	}
}
```

如果使用 Gradle 时找不到 `TexturePacker` 类，请将 gdx-tools 添加到 [build.gradle](/wiki/articles/dependency-management-with-gradle#tools-gradle) 文件。


如果按以下方式更新 Gradle 文件，也可以将 `texturePacker` 作为 Gradle 任务运行。首先更新“main”build.gradle：

```gradle
buildscript {
  dependencies {
    // ... other dependencies trimmed ...
    classpath "com.badlogicgames.gdx:gdx-tools:$gdxVersion"
    }
}
```

如果要使用特定版本，只需将 $gdxVersion 变量替换为所需版本。

```gradle
// Store the parameters you want to pass the texturePacker here...
project.ext.texturePacker = [ "android/assets/input/path/", "android/assets/output/path/", "atlas_name" ]

// Import the texture packer
import com.badlogic.gdx.tools.texturepacker.TexturePacker

// Add a new task that packs the textures for you
task texturePacker {
  doLast {
    if (project.ext.has('texturePacker')) {
      logger.info "Calling TexturePacker: "+texturePacker
      TexturePacker.process(texturePacker[0], texturePacker[1], texturePacker[2])
    }
  }
}
```

这样，运行 `./gradlew texturePacker lwjgl3:run` 会在启动 lwjgl3:run 任务前执行纹理打包。如果纹理没有变化，只需省略 texturePacker 参数即可。


也可以从[独立 nightly](https://libgdx-nightlies.s3.amazonaws.com/libgdx-runnables/runnable-texturepacker.jar)运行 TexturePacker：

```
// OS X / Linux
java -cp runnable-texturepacker.jar com.badlogic.gdx.tools.texturepacker.TexturePacker inputDir [outputDir] [packFileName]

// WINDOWS
java -cp runnable-texturepacker.jar com.badlogic.gdx.tools.texturepacker.TexturePacker inputDir [outputDir] [packFileName]
```

注意，TexturePacker 使用 Java 1.7 或更高版本时运行速度会明显更快，尤其是在打包数百张输入图像时。

## 目录结构

TexturePacker 可以一次性打包应用的所有图像。给定一个目录后，它会递归扫描图像文件。对于遇到的每个图像目录，TexturePacker 会将图像打包到称为 page 的大纹理中。如果目录中的图像无法放入单个页面的最大尺寸，就会使用多个页面。

同一目录中的图像会放到同一组页面中。如果所有图像都能放入单个页面，就不应使用子目录，因为只有一个页面时，应用只需绑定一次纹理。否则可以使用子目录隔离相关图像，以减少纹理绑定。例如，可以将所有“游戏”图像与“暂停菜单”图像放在不同目录中，因为这两组图像按顺序绘制：先绘制所有游戏图像（一次绑定），再在上层绘制暂停菜单（另一次绑定）。如果图像放在同一目录并产生多个页面，每个页面可能混合游戏和暂停菜单图像，从而需要多次纹理绑定，而不是各绑定一次。

子目录也适合分组使用相关纹理设置的图像。运行时内存格式（RGBA、RGB 等）和过滤方式（nearest、linear 等）等设置是针对每张纹理的。需要不同纹理设置的图像必须放在不同页面中，因此应置于不同子目录。

如果希望使用子目录进行组织，但不希望 TexturePacker 为每个子目录输出一组页面，请参阅 `combineSubdirectories` 设置。

如果不希望图集文件中的图像名称包含子目录路径，请参阅 `flattenPaths` 设置。

## 配置

每个目录都可以包含一个 “pack.json” 文件，它是 TexturePacker.Settings 类的 JSON 表示。每个子目录都会继承父目录的所有设置。子目录中设置的值会覆盖父目录中的对应设置。

下面是包含所有可用设置及其默认值的 JSON 示例。无需指定全部设置，可以省略任意设置。如果目录及其所有父目录都未指定某个设置，则使用默认值。

```
{
	pot: true,
	paddingX: 2,
	paddingY: 2,
	bleed: true,
	bleedIterations: 2,
	edgePadding: true,
	duplicatePadding: false,
	rotation: false,
	minWidth: 16,
	minHeight: 16,
	maxWidth: 1024,
	maxHeight: 1024,
	square: false,
	stripWhitespaceX: false,
	stripWhitespaceY: false,
	alphaThreshold: 0,
	filterMin: Nearest,
	filterMag: Nearest,
	wrapX: ClampToEdge,
	wrapY: ClampToEdge,
	format: RGBA8888,
	alias: true,
	outputFormat: png,
	jpegQuality: 0.9,
	ignoreBlankImages: true,
	fast: false,
	debug: false,
	combineSubdirectories: false,
	flattenPaths: false,
	premultiplyAlpha: false,
	useIndexes: true,
	limitMemory: true,
	grid: false,
	scale: [ 1 ],
	scaleSuffix: [ "" ],
	scaleResampling: [ bicubic ],
	atlasExtension: .atlas,
	prettyPrint: true,
	legacyOutput: true
}
```

注意，这是 libGDX 的“minimal”JSON 格式，因此大多数情况下可以省略双引号。

## 设置

| *字段* | *描述* | *默认值* |
|:-------:|:------------- |:---------:|
| `pot` | 为 true 时，输出页面的尺寸为 2 的幂。 | true |
| `paddingX` | 打包图像在 x 轴方向之间的像素数。 | 2 |
| `paddingY` | 打包图像在 y 轴方向之间的像素数。 | 2 |
| `bleed` | 为 true 时，根据最近非透明像素的 RGB 值设置透明像素的 RGB 值，防止采样透明像素 RGB 值时出现过滤伪影。 | true |
| `bleedIterations` | 执行 bleed 的迭代次数。纹理缩小时出现伪影时，可以使用 4 或 8 等更大的值。 | 2 |
| `edgePadding` | 为 true 时，打包纹理边缘使用 `paddingX` 和 `paddingY` 的一半作为边距。 | true |
| `duplicatePadding` | 为 true 时，将边缘像素复制到边距中。`paddingX/Y` 应大于等于 2。 | false |
| `rotation` | 为 true 时，TexturePacker 会尝试将图像旋转 90 度以提高打包效率。应用必须特别注意正确绘制这些区域。 | false |
| `minWidth` | 输出页面的最小宽度。 | 16 |
| `minHeight` | 输出页面的最小高度。 | 16 |
| `maxWidth` | 输出页面的最大宽度。1024 对所有设备都安全，极老设备在超过 512 时性能可能下降。 | 1024 |
| `maxHeight` | 输出页面的最大高度。1024 对所有设备都安全，极老设备在超过 512 时性能可能下降。 | 1024 |
| `square` | 为 true 时，强制输出页面的宽度和高度相同。 | false |
| `stripWhitespaceX` | 为 true 时，移除输入图像左右边缘的空白像素。应用必须特别注意正确绘制这些区域。 | false |
| `stripWhitespaceY` | 为 true 时，移除输入图像上下边缘的空白像素。应用必须特别注意正确绘制这些区域。 | false |
| `alphaThreshold` | 范围为 0 到 255。剔除空白时，低于该值的 Alpha 会被视为零。 | 0 |
| `filterMin` | 纹理的缩小过滤器。 | Nearest |
| `filterMag` | 纹理的放大过滤器。 | Nearest |
| `wrapX` | 纹理 x 方向的环绕设置。 | ClampToEdge |
| `wrapY` | 纹理 y 方向的环绕设置。 | ClampToEdge |
| `format` | 纹理在内存中使用的格式。 | RGBA8888 |
| `alias` | 为 true 时，逐像素相同的两张图像只会打包一次。 | true |
| `outputFormat` | 输出页面的图像类型，“png” 或 “jpg”。 | png |
| `jpegQuality` | 范围为 0 到 1。当 `outputFormat` 为 “jpg” 时使用的质量设置。 | 0.9 |
| `ignoreBlankImages` | 为 true 时，纹理打包器不会为完全空白的图像添加区域。 | true |
| `fast` | 为 true 时，打包效率较低，但执行速度更快。 | false |
| `debug` | 为 true 时，在输出页面上绘制线条显示打包图像边界。 | false |
| `combineSubdirectories` | 为 true 时，将包含设置文件的目录及所有子目录视为同一目录进行打包。子目录中的设置文件会被忽略。 | false |
| `flattenPaths` | 为 true 时，从图像文件名中移除子目录前缀。图像文件名应保持唯一。 | false |
| `premultiplyAlpha` | 为 true 时，RGB 会乘以 Alpha。更多信息参见[这里](https://web.archive.org/web/20160311211957/http://blogs.msdn.com/b/shawnhar/archive/2009/11/06/premultiplied-alpha.aspx)。 | false |
| `useIndexes` | 为 false 时，图像名称不会移除图像索引后缀。 | true |
| `limitMemory` | 为 true 时，任意时刻内存中只有一张图像，但每张图像会读取两次；为 false 时，打包期间所有图像都保留在内存中，但每张只读取一次。 | true |
| `grid` | 为 true 时，图像按顺序打包到均匀网格中。 | false |
| `scale` | 对每个缩放比例缩放图像，并输出完整图集。 | `[ 1 ]` |
| `scaleSuffix` | 对每个缩放比例用于输出文件的后缀。如果省略，多种缩放比例的文件会使用相同名称，输出到各自的子目录。 | `[ "" ]` |
| `scaleResampling` | 对每个缩放比例，将源图像重采样到缩放尺寸时使用的插值类型。可选 `nearest`、`bilinear` 或 `bicubic`。 | `[ bicubic ]` |
| `atlasExtension` | 附加到图集文件名的文件扩展名。 | .atlas |
| `prettyPrint` | 为 true 时，移除除换行外的所有空白。 | true |
| `legacyOutput` | 为 true 时，图集使用效率较低的输出格式。保留它是为了向后兼容。 | true |

## 纹理过滤选项

纹理打包器使用 [Texture.TextureFilter](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Texture.TextureFilter.html) 枚举中指定的过滤器。filterMin 和 filterMag 的选项如下：<br/>
Nearest：不进行过滤，不使用 mipmap<br/>
Linear：进行过滤，不使用 mipmap<br/>
MipMap 和 MipMapLinearLinear：进行过滤，在 mipmap 之间平滑过渡<br/>
MipMapNearestNearest：不进行过滤，在 mipmap 之间清晰切换<br/>
MipMapLinearNearest：进行过滤，在 mipmap 之间清晰切换<br/>
MipMapNearestLinear：不进行过滤，在 mipmap 之间平滑过渡<br/>


## NinePatch

如果图像文件名在扩展名前以“.9”结尾，就会被视为 ninepatch。参见 [ninepatches](/wiki/graphics/2d/ninepatches)。图像必须有 1px 的透明边框。上边和左边可以有一条连续的黑色像素线，用于表示拉伸区域；下边和右边可以有一条连续的黑色像素线，用于表示内容在 NinePatch 中的内边距。打包图像时会移除 1px 边框，并将分割和内边距信息存入 pack 文件。`TextureAtlas` 可以使用分割信息为该区域创建 NinePatch 实例。

## 图像索引

如果图像文件名以下划线加数字结尾（如 animation_23.png），该数字会被视为“索引”并单独存储。图像名称会去掉下划线和索引。`TextureAtlas` 可以按索引顺序获取所有同名图像列表，因此能够轻松打包动画而不丢失帧顺序。

## 打包

TexturePacker 类位于 `gdx-tools.jar` 中，而该文件位于 nightlies/releases 压缩包的 extensions 目录。TexturePacker 只作为处理应用图像文件的工具使用，不需要作为运行应用的依赖。运行打包器需要同时拥有 `gdx.jar` 和 `gdx-tools.jar`。**注意：必须将 gdx.jar 与 gdx-tools.jar 放在同一目录中，否则运行时会抛出异常。**

```
//*NIX (OS X/Linux)
java -cp gdx.jar:gdx-tools.jar com.badlogic.gdx.tools.texturepacker.TexturePacker inputDir outputDir packFileName

//WINDOWS
java -cp gdx.jar;gdx-tools.jar com.badlogic.gdx.tools.texturepacker.TexturePacker inputDir outputDir packFileName
```

也可以从[独立 nightly](https://libgdx-nightlies.s3.amazonaws.com/libgdx-runnables/runnable-texturepacker.jar)运行 TexturePacker，而无需 gdx.jar（也就是完全不需要 libGDX 的其他部分），只需将上面命令中的 `gdx.jar;gdx-tools.jar` 替换为 `runnable-texturepacker.jar`。

`inputDir` 是包含图像的根目录。`outputDir` 是放置打包图像的输出目录。`packFileName` 是 pack 文件的名称，也是输出打包图像文件使用的前缀。

如果省略 `outputDir`，文件会放入 `inputDir` 的同级新目录中，目录后缀为 “-packed”。如果省略 `packFileName`，则使用 “pack”。

虽然纹理打包本意是完全自动化的过程，但 Obli 也贡献了一个不错的界面（略有过时）：[TexturePacker GUI](https://code.google.com/p/libgdx-texturepacker-gui/)（请查看[其最新继任者](https://github.com/crashinvaders/gdx-texture-packer-gui)）。另有一个商业产品 [texturepacker.com](http://www.codeandweb.com/texturepacker)，它与 libGDX 的纹理打包器完全无关，但提供界面、许多功能和完善文档。

## 自动打包

开发期间，可以让桌面应用在启动游戏前运行 TexturePacker，这非常方便：

```java
public class DesktopGame {
	public static void main (String[] args) throws IOException {
		Settings settings = new Settings();
		settings.maxWidth = 512;
		settings.maxHeight = 512;
		TexturePacker.process(settings, "../images", "../game-android/assets", "game");

		new LwjglApplication(new Game(), "Game", 320, 480, false);
	}
}
```

每次运行游戏时，都会打包所有图像。这在将构建版本交给美术人员时尤其方便，因为他们可以尝试新图像，而无需知道游戏使用的是打包图像。如果图像很多，可以使用 `fast` 设置避免等待。

_注意：从类路径加载文件时，Eclipse 通常不会反映外部更新文件的变化。必须在 Eclipse 中手动刷新包含变更文件的项目。开发期间也可以从文件系统加载文件，这样就不会有此问题。_

# TextureAtlas

TexturePacker 的输出是一个页面图像目录，以及一个描述页面上所有已打包图像的文本文件。下面展示如何在应用中使用这些图像：

```java
TextureAtlas atlas;
atlas = new TextureAtlas(Gdx.files.internal("packedimages/pack.atlas"));
AtlasRegion region = atlas.findRegion("imagename");
Sprite sprite = atlas.createSprite("otherimagename");
NinePatch patch = atlas.createPatch("patchimagename");
```

TextureAtlas 会读取 pack 文件并加载所有页面图像。可以获取 TextureAtlas.AtlasRegions，它们是包含打包图像额外信息的 TextureRegions，例如帧索引或被剔除的空白。也可以创建 Sprite 和 NinePatch。如果剔除了空白，创建的 Sprite 实际上会是 TextureAtlas.AtlasSprite，从而基本可以像未剔除空白时一样使用。

注意，`findRegion` 速度不是很快，因此应保存返回值，而不是每帧调用该方法。另外，createSprite 和 createNinePatch 会分配新实例。

TextureAtlas 会持有所有页面纹理，销毁 TextureAtlas 时也会销毁所有页面纹理。
