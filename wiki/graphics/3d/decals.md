---
title: Decal
---
`Decal` 本质上是可以在 3D 空间中操作和渲染的 `Sprite`。借助 `DecalBatch`，可以非常高效地在 3D 世界中绘制 2D 纹理，其 API 与 `Sprite` 和 `SpriteBatch` 类似。

## [Decal](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/decals/Decal.html)

`Decal` 表示 3D 空间中的精灵，并支持平移、旋转和缩放等常见 3D 变换。

### 创建
`Decal` 需要 `DecalMaterial` 才能执行有意义的操作。虽然可以直接实例化 DecalMaterial，但使用 `Decal` 类提供的 `newDecal` 方法要简单得多。例如，已有一个 `TextureRegion` 时：

	Decal decal = Decal.newDecal(textureRegion);

如果纹理包含透明度，可以使用另一个方法：

	Decal decal = Decal.newDecal(textureRegion, true);

还可以使用其他[方法](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/decals/Decal.html)进一步指定区域的大小和混合属性。

### 操作
有许多方法可以变换 3D 空间中的 `Decal`，例如：

- 平移：`translate(x, y, z)`、`translateX(x)` 等
- 旋转：`rotate(x, y, z)`、`rotateX()` 等
- 缩放：`setScale(x, y)`、`setScale(x)` 等
- 位置：`setPosition(x, y, z)`、`setPosition(Vector3)` 等

完整的方法列表请参阅[这里](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/decals/Decal.html)。

### 广告牌
如果希望 decal 始终朝向 PerspectiveCamera，可以使用 `lookAt` 方法轻松实现。
	
	// For perspective camera
	decal.lookAt(camera.position, camera.up);

## [DecalBatch](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/decals/DecalBatch.html)
与 `SpriteBatch` 类似，可以使用 `DecalBatch` 将许多 `Decal` 批量处理，以实现高效渲染。`DecalBatch` 允许在向图形管线提交大块几何体之前，先将任意数量的 Decal 加入队列。应只创建一次 DecalBatch，而不是每个游戏循环都创建。

    // e.g. called at start of scene
    DecalBatch decalBatch = new DecalBatch(groupStrategy);

### 分组策略
批处理的处理方式取决于 GroupStrategy。可以使用不同策略自定义着色器、状态、剔除等行为。GroupStrategy 的本质是判断精灵所属的分组，并在渲染分组前后调整设置。

为方便使用，已有以下 GroupStrategy 实现：

- [SimpleOrthoGroupStrategy](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/decals/SimpleOrthoGroupStrategy.java)
- [CameraGroupStrategy](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/decals/CameraGroupStrategy.java)

CameraGroupStrategy 通常最合适。传入一个 Camera 实例后，它会处理其余工作。

	decalBatch = new DecalBatch(new CameraGroupStrategy(camera));

### 添加 Decal
与 SpriteBatch 不同，无需调用 begin 方法，只需将 decal 添加到批处理中。

	decalBatch.add(decal);

通常无需关心将 decal 添加到批处理的顺序，因为 GroupStrategy 和深度缓冲会处理重叠的 decal。

### 渲染
添加完所有 decal 后，应通知 DecalBatch 将它们刷新到图形管线。

	decalBatch.flush();

DecalBatch 随后会处理队列中的所有 decal 并进行渲染。

### 性能调节
默认 decal 池大小为 1000。一次添加超过此数量的 decal 时，DecalBatch 会提交一个批次。如果事先知道平均所需 decal 数量较少，可以缩小批处理大小以节省内存。

可以在构造函数中设置池大小：

    DecalBatch decalBatch = new DecalBatch(500, groupStrategy);

## 完整示例

这里有一个展示 Decal 正确用法的可运行示例：

[https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/SimpleDecalTest.java](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/SimpleDecalTest.java)
