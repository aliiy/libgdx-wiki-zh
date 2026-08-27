---
title: Skin
---
  * [概述](#overview)
  * [资源](#resources)
  * [便捷方法](#convenience-methods)
  * [转换](#conversions)
  * [修改资源](#modifying-resources)
  * [控件样式](#widget-styles)
  * [Skin JSON](#skin-json)
   * [Color](#color)
   * [BitmapFont](#bitmapfont)
   * [TintedDrawable](#tinteddrawable)

 ## 概述

Skin 类存储 UI 控件使用的资源，是存放纹理区域、九宫格、字体、颜色等内容的便捷容器。Skin 还提供方便的转换功能，例如将纹理区域作为九宫格、精灵或 Drawable 获取。

可以将 [libGDX 测试](https://github.com/libgdx/libgdx/tree/master/tests/gdx-tests-android/assets/data) 中的 Skin 文件作为起点。需要准备：`uiskin.png`、`uiskin.atlas`、`uiskin.json` 和 `default.fnt`。这样即可快速开始使用 `scene2d.ui`，之后再替换 Skin 资源。

Skin 中的资源通常来自[纹理图集](/wiki/tools/texture-packer#textureatlas)、通过 JSON 定义的控件样式和其他对象，以及通过代码添加到 Skin 的对象。即使不使用 JSON，也建议将 Skin 与纹理图集及通过代码添加的对象配合使用。这样获取 Drawable 实例更加方便，也能作为集中获取 UI 资源的位置。

有用的资源：
* [Ready to use skins.](https://github.com/czyzby/gdx-skins)
* [Skin Composer](https://ray3k.wordpress.com/software/skin-composer-for-libgdx/) 是用于创建和编辑 Skin 的 UI 工具。
* [Basic skin Label tutorial ](https://libgdxinfo.wordpress.com/basic-label/)

## 资源

Skin 中每个资源都有名称和类型。[纹理图集](/wiki/tools/texture-packer#textureatlas)中的区域可以作为 Skin 资源使用。纹理区域可以作为九宫格、精灵、平铺 Drawable 或 Drawable 获取。

```java
TextureAtlas atlas = ...
Skin skin = new Skin();
skin.addRegions(atlas);
...
TextureRegion hero = skin.get("hero", TextureRegion.class);
```

也可以使用 JSON（[见下文](#skin-json)）为 Skin 定义资源，或通过代码添加：

```java
Skin skin = new Skin();
skin.add("logo", new Texture("logo.png"));
...
Texture logo = skin.get("logo", Texture.class);
```

## 便捷方法

对于常见类型，Skin 提供了获取资源的便捷方法。

```java
Skin skin = ...
Color red = skin.getColor("red");
BitmapFont font = skin.getFont("large");
TextureRegion region = skin.getRegion("hero");
NinePatch patch = skin.getPatch("header");
Sprite sprite = skin.getSprite("footer");
TiledDrawable tiled = skin.getTiledDrawable("pattern");
Drawable drawable = skin.getDrawable("enemy");
```

这些方法与传入相应类相同，但代码略加简洁。

## 转换

UI 控件的所有样式需要图像时都使用 [Drawable](https://github.com/sinistersnare/libgdx/wiki/Scene2d.ui#drawable)。因此可以在 UI 的任意位置使用纹理区域、九宫格、精灵等。Skin 可以方便地将纹理和纹理区域转换为 Drawable 及其他类型：

```java
Skin skin = new Skin();
skin.add("logo", new Texture("logo.png"));
...
Texture texture = skin.get("logo", Texture.class);
TextureRegion region = skin.getRegion("logo");
NinePatch patch = skin.getPatch("logo");
Sprite sprite = skin.getSprite("logo");
TiledDrawable tiled = skin.getTiledDrawable("logo");
Drawable drawable = skin.getDrawable("logo");
```

纹理区域可以作为九宫格、精灵、平铺 Drawable 或 Drawable 获取。首次转换时会分配新对象并存储在 Skin 中，之后的获取会返回已存储的对象。

将纹理区域转换为 Drawable 时，Skin 会为该区域选择最合适的 Drawable。如果区域是带九宫格分割信息的 AtlasRegion，则返回 NinePatchDrawable；如果区域是经过旋转或去除空白的 AtlasRegion，则返回 SpriteDrawable，以确保正确绘制；否则返回 TextureRegionDrawable。

## 修改资源

从 Skin 获取的资源不是新实例，每次都会返回同一个对象。如果修改对象，修改会反映到整个应用中。如果不希望这样，应创建对象副本。

`newDrawable` 方法会复制 Drawable。可以修改新 Drawable 的尺寸信息而不影响原对象，也可以使用该方法为 Drawable 着色。

```java
Skin skin = ...
...
Drawable redDrawable = skin.newDrawable("whiteRegion", Color.RED);
```

注意，新 Drawable 不会存储在 Skin 中。若要存储它，必须像其他资源一样显式添加名称。

## 控件样式

Skin 是提供 UI 控件所需纹理区域和其他资源的实用容器，也可以存储定义控件外观的 UI 控件样式。

```java
TextButtonStyle buttonStyle = skin.get("bigButton", TextButtonStyle.class);
TextButton button = new TextButton("Click me!", buttonStyle);
```

所有控件都有用于传入 Skin 和样式名称的便捷方法：

```java
TextButton button = new TextButton("Click me!", skin, "bigButton");
```

如果省略样式名称，则使用 “default”：

```java
TextButton button = new TextButton("Click me!", skin);
```

## Skin JSON

Skin 可以[通过程序填充](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/UISimpleTest.java#L37)。也可以使用 JSON 描述 Skin 中的命名对象，这便于定义 UI 控件样式。注意，JSON 不描述纹理区域、九宫格分割或来自[纹理图集](/wiki/tools/texture-packer)的其他信息，但可以按名称引用 Skin 中的区域、九宫格和其他资源。JSON 如下：

```
{
	className: {
		name: resource,
		...
	},
	className: {
		name: resource,
		...
	},
	...
}
```

`className` 是对象的 Java 完全限定类名，`name` 是每个资源的名称，`resource` 是实际资源对象的 JSON。JSON 中的字段名称与资源类中的字段名称完全对应。下面是一个实际示例：

```
{
	com.badlogic.gdx.graphics.Color: {
		white: { r: 1, g: 1, b: 1, a: 1 },
		red: { r: 1, g: 0, b: 0, a: 1 },
		yellow: { r: 0.5, g: 0.5, b: 0, a: 1 }
	},
	com.badlogic.gdx.graphics.g2d.BitmapFont: {
		medium: { file: medium.fnt }
	},
	com.badlogic.gdx.scenes.scene2d.ui.TextButton$TextButtonStyle: {
		default: {
			down: round-down, up: round,
			font: medium, fontColor: white
		},
		toggle: {
			down: round-down, up: round, checked: round-down,
			font: medium, fontColor: white, checkedFontColor: red
		},
		green: {
			down: round-down, up: round,
			font: medium, fontColor: { r: 0, g: 1, b: 0, a: 1 }
		}
	}
}
```

首先定义一些颜色和字体，然后定义若干文本按钮样式。`down`、`up` 和 `checked` 字段的类型是 Drawable。虽然这里需要对象，但 JSON 中提供的是字符串，因此该字符串会作为名称，用于在 Skin 中查找 Drawable。字体和颜色也遵循相同规则，但 “green” 文本按钮样式例外，它在 JSON 中直接定义了新颜色。

注意，顺序很重要。资源必须在 JSON 中先于引用它的位置声明。还要注意，libGDX 使用的 JSON 与标准格式不同，定义键和值时不使用引号。

可以将 [libGDX 测试](https://github.com/libgdx/libgdx/tree/master/tests/gdx-tests-android/assets/data) 中的 Skin 文件作为起点：uiskin.png、uiskin.atlas、uiskin.json 和 default.fnt。

通过 Skin JSON 文件加载和配置 freetype 字体需要一些额外步骤。[Scene Composer](https://github.com/raeleus/skin-composer/wiki/Creating-FreeType-Fonts#using-a-custom-serializer) 可以提供帮助。

### 颜色

颜色在 JSON 中按上面的方式定义。如果省略 `r`、`g` 或 `b` 属性，则使用 0；如果省略 `a`，则使用 1。

也可以使用十六进制值指定颜色：
```
com.badlogic.gdx.graphics.Color: {
	skyblue: { hex: 489affff }
}
```

### BitmapFont

位图字体在 JSON 中声明如下：

```
{
	com.badlogic.gdx.graphics.g2d.BitmapFont: {
		medium: { file: medium.fnt,
                  scaledSize: -1, //integer height of capital letters, default -1 for unscaled
                  markupEnabled: false,
                  flip : false}
	}
}
```

查找字体的 BMFont 文件时，Skin 首先搜索 Skin 文件所在目录。如果找不到，则将指定路径作为内部路径使用。

查找字体图像文件时，Skin 首先查找与字体文件同名但不含扩展名的纹理区域。如果找不到，则在字体文件所在目录中查找同名且扩展名为 “png” 的图像。

### TintedDrawable

为区域着色非常有用。例如，可以为白色按钮的区域着色，从而得到任意颜色的按钮。可以在代码中使用 `newDrawable` 方法为 Drawable 着色。Skin.TintedDrawable 类提供了在 JSON 中为 Drawable 着色的方式：

```
{
	com.badlogic.gdx.graphics.Color: {
		green: { r: 0, g: 1, b: 0, a: 1 }
	},
	com.badlogic.gdx.scenes.scene2d.ui.Skin$TintedDrawable: {
		round-green: { name: round, color: green }
	}
}
```

这会复制名为 “round” 的 Drawable，将其染成绿色，并以 “round-green” 为名称作为 Drawable 添加到 Skin 中。
