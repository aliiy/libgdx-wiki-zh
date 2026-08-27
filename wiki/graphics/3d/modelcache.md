---
title: ModelCache
---
使用 [ModelBatch](/wiki/graphics/3d/modelbatch) 渲染大量 [Model](/wiki/graphics/3d/models) 时，可能会发现性能受到影响。这通常是因为模型的每个 [part](/wiki/graphics/3d/models#nodepart) 都会导致一次[渲染调用](/wiki/graphics/3d/modelbatch#what-are-render-calls)。每次渲染调用都需要 GPU 和 CPU 同步，这是相对昂贵的操作。因此通常应尽量减少渲染调用次数。

减少渲染调用有多种方式，例如使用*视锥体剔除*（不渲染本来就不可见的内容）、*优化模型*以减少部件数量，或*合并模型*以减少模型数量。[ModelCache](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/ModelCache.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/ModelCache.java)）可以在运行时完成后两种操作。

> **注意** 在*运行时*合并和优化模型通常仍然是相对昂贵的操作，操作不当甚至会使性能变差。请始终同时实现其他减少渲染调用的方案，例如视锥体剔除或优化资源。

ModelCache 与用于 2D 渲染的 [SpriteCache](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/SpriteCache.html) 和 [SpriteBatch](/wiki/graphics/2d/spritebatch-textureregions-and-sprites) 有些类似。不过，与精灵相比，模型通常更复杂，例如拥有更多顶点、顶点属性和材质。

ModelCache 不会合并蒙皮网格。添加蒙皮网格时，它不会被合并，而是保持原样。因此可以安全地将蒙皮网格加入缓存，但这不会减少渲染调用次数（因为蒙皮是在渲染调用内部应用的）。

## 使用 ModelCache

使用 ModelCache 的方式与使用 [ModelBatch](/wiki/graphics/3d/modelbatch) 类似。要开始合并和优化模型，必须调用 `begin()` 方法。然后可以 `add()` 一个或多个 [ModelInstance](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/ModelInstance.html) 或其他 [RenderableProvider](/wiki/graphics/3d/modelbatch#renderableprovider)。之后调用 `end()` 方法执行实际的合并。

缓存创建完成后（调用 `end()` 之后），可以在 `ModelBatch.render` 调用中使用它。

ModelCache 拥有多个本地资源。因此不再需要缓存时，应调用其 `dispose()` 方法。

```java
ModelBatch batch;
ModelCache cache;
public void create() {
    //...
    Array<ModelInstance> instances = createTheInstanceYouWantToMerge();
    cache = new ModelCache();
    cache.begin();
    cache.add(instances);
    cache.end();
    //... create the batch and such
}
public void render() {
    //... call glClear and such
    batch.begin();
    batch.render(cache, environment);
    batch.end();
}
public void dispose() {
    // dispose models and such
    cache.dispose();
    batch.dispose();
}
```

ModelCache 也可以用于动态模型，例如每帧都会移动的对象。这种情况下，可以在每次渲染调用时重新创建缓存。

```java
ModelBatch batch;
ModelCache cache;
Array<ModelInstance> instances;
public void create() {
    //...
    instances = createTheInstanceYouWantToMerge();
    cache = new ModelCache();
    //... create the batch and such
}
public void render() {
    //... call glClear and such
    cache.begin();
    cache.add(instances);
    cache.end();

    batch.begin();
    batch.render(cache, environment);
    batch.end();
}
public void dispose() {
    // dispose models and such
    cache.dispose();
    batch.dispose();
}
```
