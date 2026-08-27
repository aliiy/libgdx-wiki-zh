---
title: 瓦片地图
---
# 地图

libGDX 提供通用的地图 API。所有与地图相关的类都位于 [com.badlogic.gdx.maps](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/package-use.html) [（代码）](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/maps) 包中。根包包含基础类，子包则包含瓦片地图和其他地图形式的专用实现。

## 基础类
这些基础类设计得足够通用，因此不仅支持瓦片地图，也支持任意 2D 地图格式。

地图由一组图层组成，图层包含一组对象。地图、图层和对象拥有的属性取决于其加载来源的格式。某些格式提供了专用的地图、图层和对象实现，后文将详细介绍。基础类的类层级如下：

![images/maps-api.png](/assets/wiki/images/maps-api.png)

### 属性

地图、图层或对象的属性由
[MapProperties](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/MapProperties.html)
[(源码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/MapProperties.java) 表示。这个类本质上是一个哈希映射，键为字符串，值可以是任意类型。

地图、图层或对象可用的键值对取决于其加载来源的格式。访问属性非常简单：

```java
map.getProperties().get("custom-property", String.class);
layer.getProperties().get("another-property", Float.class);
object.getProperties().get("foo", Boolean.class);
```

许多受支持的编辑器都允许为地图、图层和对象指定此类属性。这些属性的具体类型取决于格式。如果不确定，可以在 libGDX 应用中使用某个地图加载器加载地图，然后检查目标对象的属性。

### 地图图层

地图中的图层按顺序排列，索引从 0 开始。可以这样访问地图图层：

```java
MapLayer layer = map.getLayers().get(0);
```

也可以按名称搜索图层：

```java
MapLayer layer = map.getLayers().get("my-layer");
```

这些 getter 方法始终返回 MapLayer。某些图层可能是专用类型并提供更多功能，此时可以直接进行类型转换：

```java
TiledMapTileLayer tiledLayer = (TiledMapTileLayer)map.getLayers().get(0);
```

对于每种受支持的地图格式，我们都会尽量统一图层的以下属性：

```java
String name = layer.getName();
float opacity = layer.getOpacity();
boolean isVisible = layer.isVisible();
```

也可以修改这些属性，这可能会影响图层的渲染方式。

除了这些统一属性之外，还可以访问上文所述的通用属性。

要获取图层中的对象，只需调用：

```java
MapObjects objects = layer.getObjects();
```

通过 [MapObjects](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/MapObjects.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/MapObjects.java) 实例，可以按名称、索引或类型获取对象，也可以动态插入和移除对象。

### 地图对象

该 API 已提供一些专用地图对象，例如
[CircleMapObject](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/objects/CircleMapObject.html) [(code)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/objects/CircleMapObject.java),
[PolygonMapObject](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/objects/PolygonMapObject.html) [(code)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/objects/PolygonMapObject.java) 
，等等。

地图格式的加载器会解析这些对象，并将它们放入对应的
[MapLayer](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/MapLayer.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/MapLayer.java) 中。

对于所有受支持的格式，我们都会尽量为每个对象提取以下统一属性：

```java
String name = object.getName();
float opacity = object.getOpacity();
boolean isVisible = object.isVisible();
Color color = object.getColor();
```

`PolygonMapObject` 等专用地图对象还可能拥有其他属性，例如：

```java
Polygon poly = polyObject.getPolygon();
```

修改这些属性可能会影响对象的渲染方式。

与地图和图层一样，还可以访问上文所述的通用属性。

*注意：* 瓦片地图中的瓦片不会作为地图对象存储。下面介绍的专用图层实现会更高效地存储这类对象。上文所述的对象通常用于定义触发区域、出生点、碰撞形状等。

### 地图渲染器

[`MapRenderer`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/MapRenderer.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/MapRenderer.java) 接口定义了用于渲染地图图层和对象的方法。

开始渲染前，必须为地图设置视图。可以把视图理解为观察地图的窗口。最简单的方式是告知地图渲染器要使用的 OrthographicCamera：

```java
mapRenderer.setView(camera);
```

也可以手动指定投影矩阵和视图边界：

```java
mapRenderer.setView(projectionMatrix, startX, startY, endX, endY);
```

视图边界在 x/y 平面中给出，y 轴朝上。所使用的单位取决于地图及其加载来源的格式。

随后只需调用以下方法即可渲染地图的所有图层：

```java
mapRenderer.render();
```

如果需要更精确地控制要渲染的图层，可以指定要渲染的图层索引。假设有 3 个图层，其中两个是背景图层、一个是前景图层，并且希望在前景图层和背景图层之间渲染自定义精灵，可以这样做：

```java
int[] backgroundLayers = { 0, 1 }; // don't allocate every frame!
int[] foregroundLayers = { 2 };    // don't allocate every frame!
mapRenderer.render(backgroundLayers);
renderMyCustomSprites();
mapRenderer.render(foregroundLayers);
```

分别渲染每个图层，并为每个图层修改视图，还可以实现视差效果。

## Tiled 地图
包含瓦片图层的地图由 [com.badlogic.gdx.maps.tiled](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/maps/tiled) 包中的类处理。该包包含不同格式的加载器。

瓦片地图会加载为
[TiledMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/tiled/TiledMap.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/tiled/TiledMap.java) 实例。TiledMap 是通用 Map 类的子类，并提供额外的方法和属性。

### Tiled 地图图层
包含瓦片的图层存储在
[TiledMapTileLayer](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/tiled/TiledMapTileLayer.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/tiled/TiledMapTileLayer.java) 实例中。要访问瓦片，必须进行类型转换：

```java
TiledMap tiledMap = loadMap(); // see below for this
TiledMapTileLayer layer = (TiledMapTileLayer)tiledMap.getLayers().get(0); // assuming the layer at index 0 contains tiles
```

TiledMapTileLayer 拥有与通用 MapLayer 相同的所有属性，例如属性、对象等。

除此之外，TiledMapTileLayer 还包含一个二维的 [TiledMapTileLayer.Cell](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/tiled/TiledMapTileLayer.Cell.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/tiled/TiledMapTileLayer.java#L89) 实例数组。

要访问单元格，可以这样从瓦片图层中获取：

```java
Cell cell = tileLayer.getCell(column, row);
```

其中 column 和 row 指定单元格的位置，均为整数索引。瓦片采用 y 轴向上的坐标系。因此，地图左下角的瓦片位于 (0,0)，右上角的瓦片位于 (tileLayer.getWidth()-1, tileLayer.getHeight()-1)。

如果该位置没有瓦片，或 column/row 参数越界，则返回 null。

可以通过以下方式查询图层中水平方向和垂直方向的瓦片数量：

```java
int columns = tileLayer.getWidth();
int rows = tileLayer.getHeight();
```

### 单元格
单元格是以下对象的容器：
[TiledMapTile](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/tiled/TiledMapTile.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/tiled/TiledMapTile.java)。单元格本身除了存储瓦片引用，还存储用于指定渲染瓦片时是否旋转或翻转的属性。

多个单元格通常会共享瓦片。

### 瓦片集与瓦片
TiledMap 包含一个或多个
[TiledMapTileSet](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/tiled/TiledMapTileSet.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/tiled/TiledMapTileSet.java) 实例。瓦片集包含多个 [TiledMapTile](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/tiled/TiledMapTile.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/tiled/TiledMapTile.java) 实例。瓦片有[多种实现](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/maps/tiled/tiles)，例如静态瓦片、动画瓦片等。也可以针对特殊用途创建自己的实现。

瓦片图层中的单元格引用这些瓦片。同一图层中的单元格可以引用多个瓦片集，但建议每个图层固定使用一个瓦片集，以减少纹理切换。

### 渲染 Tiled 地图
要渲染 TiledMap 及其图层，需要使用某个[专用 MapRenderer 实现](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/maps/tiled/renderers)。对于正交或俯视地图，使用
[OrthogonalTiledMapRenderer](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/tiled/renderers/OrthogonalTiledMapRenderer.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/tiled/renderers/OrthogonalTiledMapRenderer.java)；对于等距地图，使用
[IsometricTiledMapRenderer](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/maps/tiled/renderers/IsometricTiledMapRenderer.html)
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/maps/tiled/renderers/IsometricTiledMapRenderer.java)。该包中的其他渲染器仍处于实验阶段，目前不建议使用。

创建此类渲染器的方式如下：

```java
float unitScale = 1 / 16f;
OrthogonalTiledMapRenderer renderer = new OrthogonalTiledMapRenderer(map, unitScale);
```

该渲染器只能渲染在构造函数中传入的地图。这种绑定关系允许渲染器针对该特定地图执行优化并缓存结果。

单位缩放告诉渲染器多少像素对应一个世界单位。上例中 16 个像素对应一个单位。如果希望一个像素对应一个单位，则 unitScale 应为 1，以此类推。

单位缩放用于关联渲染坐标系与逻辑坐标系或世界坐标系。

举个简单例子：假设瓦片地图中的瓦片大小为 32x32 像素，并且希望在世界的逻辑表示中将其映射为 1x1 单位的方格。应将单位缩放指定为 1/32f。现在可以让摄像机也使用该单位缩放。假设希望在屏幕上查看地图中的 30x20 个瓦片，可以这样创建摄像机：

```java
OrthographicCamera camera = new OrthographicCamera();
camera.setToOrtho(false, 30, 20);
```

处理等距地图的方式类似，只需创建一个 IsometricTiledMapRenderer：

```
renderer = new IsometricTiledMapRenderer(isoMap, 1 / 32f);
```

同样，必须指定地图（应为等距瓦片地图）和单位缩放。

*注意：* 等距渲染器处于实验阶段，请自行承担使用风险，并报告发现的问题。从性能角度看，在移动设备上渲染等距地图的开销很大，因为每个瓦片都必须启用混合。

### 加载 TMX/Tiled 地图
![images/tile-maps2.png](/assets/wiki/images/tile-maps2.png)

[Tiled](https://www.mapeditor.org/) 是一款适用于 Windows/Linux/Mac OS X 的通用瓦片地图编辑器，允许创建瓦片图层和对象图层，对象图层可包含用于触发区域及其他用途的任意形状。libGDX 提供了用于读取 Tiled 生成文件的加载器。

加载 Tiled 地图有两种方式：直接加载，或通过 AssetManager 加载。直接加载的方式如下：

```java
TiledMap map = new TmxMapLoader().load("level1.tmx");
```

这会从内部文件存储（assets 目录）加载名为 `level1.tmx` 的文件。如果要从其他文件类型的位置加载文件，必须在 TmxMapLoader 的构造函数中提供 FileHandleResolver。

```java
TiledMap map = new TmxMapLoader(new ExternalFileHandleResolver()).load("level1.tmx");
```

之所以采用这种机制，是因为 TmxMapLoader 也可以与 AssetManager 类配合使用，而 FileHandleResolver 在其中负责解析文件。要通过 AssetManager 加载 TMX 地图，可以这样做：

```java
// only needed once
assetManager.setLoader(TiledMap.class, new TmxMapLoader(new InternalFileHandleResolver()));
assetManager.load("level1.tmx", TiledMap.class);

// once the asset manager is done loading
TiledMap map = assetManager.get("level1.tmx");
```

加载完成后，可以像处理其他 TiledMap 一样处理该地图。

*注意：* 如果直接加载 TMX 地图，不再需要时必须负责调用 `TiledMap#dispose()`。此调用会释放为地图加载的所有纹理。
*注意：* 如果要在 GWT 后端中使用 TMX 地图，必须确保地图以纯 base64 编码保存。由于 GWT 的限制，压缩的 TMX 格式无法使用。
*注意：* libGDX 不支持无限尺寸的 TMX 地图（参见 [#5764](https://github.com/libgdx/libgdx/issues/5764)）。只能使用尺寸有限的 TMX 地图。

### 加载 TiledMapPacker Atlas TMX/TMJ Tiled 地图
libGDX 的 TiledMapPacker 和 AtlasTmxMapLoader 已存在多年，但最近的更新为它们加入了更多功能，并改善了使用文档。

经过 TiledMapPacker 处理的地图必须使用 AtlasTmxMapLoader 或 AtlasTmjMapLoader 类加载，而不能使用标准地图加载器。
这些专用加载器能够识别嵌入地图文件中的额外 atlas 属性，确保从生成的 TextureAtlas 正确加载瓦片集、图像图层和图像集合瓦片集。

使用这些加载器可以减少绘制调用和纹理绑定，提高渲染效率，尤其适用于大量依赖图像图层和多个瓦片集的地图。

有关使用说明，请参阅完整的 [TiledMapPacker 文档](/wiki/tools/tiled-map-packer)。

### 加载 Tide 地图
![images/tile-maps3.png](/assets/wiki/images/tile-maps3.png)

[Tide](https://colinvella.github.io/tIDE/) 是另一款通用瓦片地图编辑器，仅适用于 Windows。libGDX 提供了用于加载 Tide 输出格式的加载器。

与 TMX 文件一样，可以直接加载 Tide 地图，也可以通过资源管理器加载：

```java
// direct loading
map = new TideMapLoader().load("level1.tide");

// asset manager loading
assetManager.setLoader(TiledMap.class, new TideMapLoader(new InternalFileHandleResolver()));
assetManager.load("level1.tide", TiledMap.class);
```

*注意：* 如果直接加载 Tide 地图，不再需要时必须负责调用 TiledMap#dispose()。此调用会释放为地图加载的所有纹理。

## 性能注意事项
虽然我们尽量让渲染器保持高性能，但仍有一些事项可以帮助提升渲染性能。

   * 每个图层只使用单个瓦片集中的瓦片，这会减少纹理绑定。
   * 将不需要混合的瓦片标记为不透明。目前只能通过代码完成此操作，今后会提供在编辑器中设置或自动设置的方式。
   * 不要使用过多图层。

## 示例
   * [使用 TMX 地图的简单平台游戏](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/superkoalio/SuperKoalio.java)
   * [以编程方式创建 TiledMap](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/bench/TiledMapBench.java)
   * [瓦片地图的资源管理器加载与渲染](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/TiledMapAssetManagerTest.java)
   * [瓦片地图的直接加载与渲染](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/TiledMapDirectLoaderTest.java)
   * [Tide 地图的资源管理器加载与渲染](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/TideMapAssetManagerTest.java)
   * [Tide 地图的直接加载与渲染](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/TideMapDirectLoaderTest.java)
