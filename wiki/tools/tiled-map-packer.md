---
title: "Tiled 地图打包器"
---

# TiledMapPacker

> **注意：** 最新的 TiledMapPacker 可执行版本现已发布，使用它创建的地图需要 libGDX 1.13.5 或更高版本才能加载。
可以[在此处](https://libgdx-nightlies.s3.eu-central-1.amazonaws.com/libgdx-runnables/runnable-tiledmappacker.jar)下载 **TiledMapPacker** 的可执行 JAR 版本。

*用于准备 Tiled 地图（`.tmx` 或 `.tmj`）的离线工具。它通过合并图块集、图像层和单独图像，让 libGDX 使用单个经过优化的 `TextureAtlas` 进行渲染。设计用于配合 `AtlasTmxMapLoader` 或 `AtlasTmjMapLoader` 使用。*

## 为什么使用 TiledMapPacker？

TiledMapPacker 旨在优化 Tiled 地图，以获得更好的运行时性能：

- **更少的绘制调用**：将多个图块集、图像和图层合并到单个优化的 `TextureAtlas` 中，游戏就能以更少的纹理切换更快地渲染整个地图。这对使用图像层制作的视差背景，以及使用多种图块集的地图尤其有帮助。
- **可选的图块剔除**：可以省略未使用的图块，以减少文件大小和内存占用。


## 运行 TiledMapPacker

### 独立 JAR

```
# 在 INPUTDIR 旁创建名为 "output" 的输出目录
java -jar runnable-tiledmappacker.jar ./maps

# 指定输出目录
java -jar runnable-tiledmappacker.jar ./maps ./maps-packed

# 指定输出目录，并加载需要 .tiled-project 文件的地图
java -jar runnable-tiledmappacker.jar ./maps ./maps-packed ./customClass.tiled-project

# 还可以使用详细日志和剔除未使用图块等选项
java -jar runnable-tiledmappacker.jar ./maps ./maps-packed -v --strip-unused
```

> **注意：** TiledMapPacker 内部使用 `TmxMapLoader` 和 `TmjMapLoader`，它们需要有效的 OpenGL 上下文。可执行 JAR 会自动创建一个打开小窗口的最小 LwjglApplication。

## 位置参数

| 参数           | 描述 |
|------------------- |-------------|
| **INPUTDIR**       | 包含地图的文件夹，会递归搜索 `.tmx` 和 `.tmj` 文件。|
| **OUTPUTDIR**      | *（可选）* 写入处理后地图和图集的目录。默认为名为 **output** 的同级目录。|
| **PROJECTFILEPATH** | *（可选）* 当地图依赖*自定义类*时，Tiled `.tiled-project` 文件的路径。|

## 标志

| 标志                 | 作用                                                                        |
| -------------------- |-------------------------------------------------------------------------------|
| `--strip-unused`     | 省略从未出现在任何图层中的图块。                                    |
| `--combine-tilesets` | 将所有地图中的图块集合并为一个超大图集（不推荐）。 |
| `--ignore-coi`       | 跳过“*collection-of-images*”图块集。                                       |
| `-v`                 | 详细输出（列出每个被打包/剔除的图块或图像）。           |


## 默认的按地图图集与合并图集

- **按地图**（默认）：每张地图都有自己的图集。

  *Command*: `java -jar tiledmappacker.jar ./maps`.

- **合并**：所有地图中的图块集都打包到一个超大图集中，因此所有地图只需一个图集。此选项从 TiledMapPacker 诞生起就存在，但仍然*不推荐*使用，因为嵌套文件夹和绝对图块集路径可能导致它失效。

  *Option*: `--combine-tilesets`.


## 典型工作流

1. 像往常一样在 Tiled 中设计地图。
2. 每当美术资源或地图文件发生变化时，运行 **TiledMapPacker**。
3. 打包器会创建更新后的地图文件（`.tmx` 或 `.tmj`）以及 `tileset/` 目录，其中包含生成的 `.atlas` 和图像。
4. 保留原始图块集定义（`.tsx` 或 `.tsj`），并将它们放在新生成的地图和图集文件旁边。
5. 然后像加载普通地图一样加载地图：
   ```java
   TiledMap map = new AtlasTmxMapLoader().load("maps/testLevel.tmx");
   ```
    也可以像其他地图一样通过 AssetManager 类加载。
   ```java
   assetManager.setLoader(TiledMap.class, new AtlasTmxMapLoader(new InternalFileHandleResolver()));
   assetManager.load("maps/testLevel.tmx", TiledMap.class);
   ```

## 处理 ImageLayer

系统会自动检测图像层。每个图像都会被重命名为安全的区域 ID（前缀为 `atlas_imagelayer_`），打包到图集中，并重写地图文件。修改后的图集地图加载器会自动解析这些名称。


## 限制

- 不支持 **XML 图层编码**，请使用 CSV 或 Base64 图层。
- 同一文件夹中存在**相同基本名称**的 `.tmx` 和 `.tmj`（例如 `level1.tmx` 和 `level1.tmj`）会导致区域名称冲突，打包器将中止。
- **Collection-of-images** 图块集会自动打包，但如果它们未用于图块层且不需要渲染，可以使用 `--ignore-coi` 排除。
- `--combine-tilesets` 仍属实验功能。复杂的文件夹层级或绝对图块集路径可能无法正确解析。

## 结果

在最坏情况下，一张地图可能使用三个不同的图块集，其中包括一个 “collection-of-images” 图块集，并包含八个用于视差背景效果的图像层。

![TiledMap UI Layers](/assets/wiki/images/tiledmappacker1.png)

可以看到，如果通过 `TmxMapLoader` 加载该地图，会浪费多少绘制调用。以下示例中的绘制调用数量会根据屏幕位置在 12 到 14 之间变化。

![Unoptimized TMX Map](/assets/wiki/images/tiledmappacker2.gif)

但使用 TiledMapPacker 和 AtlasTmxMapLoader 可以显著减少绘制调用，在此示例中可降至 1 次。

![Optimized Atlas TMX Map](/assets/wiki/images/tiledmappacker3.gif)

## 示例测试
* [运行 TiledMapPacker](https://github.com/libgdx/libgdx/blob/master/extensions/gdx-tools/src/com/badlogic/gdx/tiledmappacker/TiledMapPackerTest.java)
* [渲染打包后的图集 Tiled 地图](https://github.com/libgdx/libgdx/blob/master/extensions/gdx-tools/src/com/badlogic/gdx/tiledmappacker/TiledMapPackerTestRender.java)

## 资源致谢
* 示例 .gif 使用了[**SunnyLand Tileset**](https://ansimuz.itch.io/sunny-land-pixel-game-art)中的免费资源。
