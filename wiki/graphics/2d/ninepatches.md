---
title: 九宫格
---
本文介绍 NinePatch 图像、创建方式以及它们在 libGDX 中的使用方式。

## 开始之前

本指南针对旧版 scene2d 和 skinpacker（0.9.6 之前的版本）。如果你使用的是 nightly 版本，本指南仍可提供一些提示，但不能作为逐步操作指南。主要区别在于 skinpacker 和 texturepacker 已统一为 texturepacker2，且 skin 的加载方式也有所不同。

## 简介

NinePatch 图像是一种定义了“可拉伸”区域的图像。利用此属性，可以将图像重复到很小的区域，或缩放到很大的区域。由于区域是预先定义的，图像不会显得被拉伸（前提是创建图像时已考虑缩放）。libGDX 中对应的 NinePatch 类位于[这里](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/NinePatch.html)
[(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/g2d/NinePatch.java)。

NinePatch 用于 LibGDX 的多种 Scene2d 组件，包括按钮、滚动窗格和文本框。

libGDX 提供多种资源加载方式，NinePatch 也不例外。手动创建和实例化 NinePatch 时，需要在代码中指定补丁区域；使用 Skin（并通过 SkinPacker 创建它们）加载 NinePatch 时，流程略有不同。本页也会介绍这种方式。

## 手动创建和实例化 NinePatch

下面简要介绍如何在代码中手动实例化 NinePatch 图像。基本步骤是创建图像、确定要拉伸的区域，并记录这些区域的像素范围。

### 创建可缩放图像

请记住，图像的某些区域需要容纳内容（文本、其他图像等），因此不能包含任何“特殊效果”（因为该区域会被缩放）。这里将创建一个“按钮”。我的美术能力有限，请包容这个示例。

![images/ninepatches1.png](/assets/wiki/images/ninepatches1.png)

可以看出，这个“按钮”相当圆。NinePatch 的妙处之一是它会围绕我们提供的内容进行扩展，因此加入文本后会沿水平方向伸长。按钮的四角是普通的半透明像素。注意，我们没有在图像中定义可拉伸区域，而是在代码中完成这件事。

### 实例化 NinePatch

实例化新 NinePatch 的最简单方式如下：
```java
NinePatch patch = new NinePatch(new Texture(Gdx.files.internal("knob.png")), 12, 12, 12, 12);
```
四个 _整数_ 参数指定允许图像拉伸的区域（以像素为单位）。

将 NinePatch 应用于 Scene2D 元素时，才能真正体现它的作用。下面使用刚创建的图像实例化一个按钮。
```java
// Create a new TextButtonStyle
TextButtonStyle style = new TextButtonStyle(patch, patch, patch, 0, 0, 0, 0, new BitmapFont(), new Color(0.3f, 0.2f, 0.8f, 1f), new Color(0, 0, 0, 1f), new Color(0, 0, 0, 1f));
// Instantiate the Button itself.
TextButton button = new TextButton("hello world", style);
```

将这个 TextButton 添加到舞台后的结果如下：

![images/ninepatches2.png](/assets/wiki/images/ninepatches2.png)

现在，圆形图像会随内容长度（文本）缩放。按钮使用标准 BitmapFont 和一些不太美观的颜色。

### 在代码中实例化的限制

直接实例化 NinePatch（使用 libGDX）的限制是所有固定区域都必须是相同的正方形。下面的图像说明了 NinePatch 中四个整数参数实际定义的区域。未被青色覆盖的灰色区域就是可缩放区域。

![images/ninepatches3.png](/assets/wiki/images/ninepatches3.png)

## 使用 SkinPacker 创建和实例化 NinePatch

*注意：* _为了让 SkinPacker 正确识别/解析 NinePatch 图像，文件名必须以 .9.png 结尾_（如果文件扩展名为 .png）。

NinePatch 图像本身需要包含一些特殊属性，才能作为 NinePatch 使用。这些属性通过在图像周围添加 1 像素边框来定义。下面介绍创建 NinePatch 的步骤。

### 定义可拉伸区域

现在需要修改图像，在允许图像拉伸的位置添加黑色边框。这可以在任意图像编辑器中完成，也有一些专用编辑器可以简化流程。

#### GitHub AndroidAssetStudio 生成器
这是我个人最喜欢的工具。不需要额外准备工作，只需打开网站并指定图像，它就会自动估算区域（以我的经验通常很准确），然后点击下载按钮。它甚至会为 Android 打包成方便的 zip 文件（如果你不使用 Android，可以忽略这一点并选择最小的文件，因为 NinePatch 可以按需缩放到任意大小）。
https://romannurik.github.io/AndroidAssetStudio/nine-patches.html

#### WebLaF ninepatch-editor
这是一个比下面 Android SDK 工具更新、功能更完善的工具。它正是由于 draw9patch 的不足而创建的，可以在 [weblaf 项目](https://github.com/mgarin/weblaf)中找到。向下滚动即可找到可下载的 ninepatch-editor 独立 jar 发布包。

#### Android SDK draw9patch
Android SDK 包含一个专门用于此目的的优秀工具，位于 `_android-sdk/tools/draw9patch_`。该工具可以预览缩放后的图像。下面是将图像加载到 *draw9patch* 工具中的效果。注意左侧的“预览”以及图像糟糕的缩放效果。

![images/ninepatches4.png](/assets/wiki/images/ninepatches4.png)

在下图中，我定义了内容放置的区域（也就是会被缩放的区域）以及不希望缩放的区域。同样，这是通过在图像周围添加 1 像素边框实现的。可以看到，工具会预览内容（粉色区域），而且预览效果明显更好（截图右侧）。

![images/ninepatches5.png](/assets/wiki/images/ninepatches5.png)

现在将图像保存为 _image.9.png_。这一点非常重要，否则 libGDX 不会将文件识别为 NinePatch。下面就是完成后的 NinePatch 图像，可以直接在代码中使用。

![images/ninepatches6.png](/assets/wiki/images/ninepatches6.png)

## 以编程方式定义 NinePatch

请参阅 NinePatch 的[此构造函数](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/NinePatch.html#NinePatch%28com.badlogic.gdx.graphics.Texture,%20int,%20int,%20int,%20int%29)。

![images/ninepatches7.png](/assets/wiki/images/ninepatches7.png)

### 使用 SkinPacker 打包图像

这一步本应在本 Wiki 的其他部分（最好是 SkinPacker 专题）中介绍。由于图像文件名以 _.9.png_ 结尾，SkinPacker 会分析我们上一步定义的 1 像素外边框区域。

当这是 _export_ 文件夹中唯一的图像并运行 SkinPacker 后，结果如下：

```json
"resources": {
        "com.badlogic.gdx.graphics.g2d.NinePatch": {
                "knob": [
                        { "x": 2, "y": 2, "width": 13, "height": 11 },
                        { "x": 15, "y": 2, "width": 7, "height": 11 },
                        { "x": 22, "y": 2, "width": 12, "height": 11 },
                        { "x": 2, "y": 13, "width": 13, "height": 9 },
                        { "x": 15, "y": 13, "width": 7, "height": 9 },
                        { "x": 22, "y": 13, "width": 12, "height": 9 },
                        { "x": 2, "y": 22, "width": 13, "height": 12 },
                        { "x": 15, "y": 22, "width": 7, "height": 12 },
                        { "x": 22, "y": 22, "width": 12, "height": 12 }
                ]
        }
}
```

可以看到，打包器实际上定义了九个补丁（现在应该已经让人印象深刻了！）。这样做的一个巨大优势是，不再受手动实例化 NinePatch 时每个区域必须为 1 个正方形的限制，可以定义更细致的九宫格区域。此外，直接修改图像并重新运行打包器也更加方便，区域会自动被定义。
