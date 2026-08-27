---
title: ModelBuilder、MeshBuilder 与 MeshPartBuilder
---
# ModelBuilder
[ModelBuilder](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/ModelBuilder.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/ModelBuilder.java)）是一个用于通过代码创建一个或多个[模型](/wiki/graphics/3d/models)的工具类。它允许包含一个或多个[节点](/wiki/graphics/3d/models#nodes)，每个节点由一个或多个[部件](/wiki/graphics/3d/models#nodepart)组成。但它不支持构建节点层级（子节点）。请注意，通过代码构建模型可能开销较大，并可能触发垃圾回收。
## 构建一个或多个模型
使用 `begin()` 方法开始构建模型，完成后必须调用 `end()`。`end()` 方法会返回新创建的模型。可以使用同一个 ModelBuilder 构建多个模型，但不能同时构建。例如：
```java
ModelBuilder modelBuilder = new ModelBuilder();

modelBuilder.begin();
... //build one or more nodes
Model model1 = modelBuilder.end();

modelBuilder.begin();
... //build one or more nodes
Model model2 = modelBuilder.end();
```
## 管理资源
请记住，模型包含一个或多个网格，因此[需要释放](/wiki/graphics/3d/models#managing-resources)。通过 ModelBuilder 构建的模型始终负责释放其包含的所有网格，即使 Mesh 是由你自行提供的。不要在多个 Model 之间共享 Mesh。

通过 ModelBuilder 构建的 Model 不会负责释放[材质](/wiki/graphics/3d/material-and-environment)中包含的纹理或其他资源。不过，可以使用 `manage(disposable)` 方法让模型负责释放这些资源。例如：
```java
ModelBuilder modelBuilder = new ModelBuilder();
modelBuilder.begin();
Texture texture = new Texture(...);
modelBuilder.manage(texture);
... //build one or more nodes
Model model = modelBuilder.end();
... //use the model and when done:
model.dispose(); // this will dispose the texture as well
```
## 创建节点
Model 由一个或多个[节点](/wiki/graphics/3d/models#nodes)组成。要开始在模型中构建新节点，可以使用 `node()` 方法。该方法会添加一个新节点并将其设为当前构建节点，同时返回 [`Node`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/model/Node.html)，以便稍后引用或设置其 `id`。
```java
ModelBuilder modelBuilder = new ModelBuilder();
modelBuilder.begin();
Node node1 = modelBuilder.node();
node1.id = "node1";
node1.translation.set(1, 2, 3);
...//build node1
Node node2 = modelBuilder.node();
node2.id = "node2";
...//build node2
Model model = modelBuilder.end();
```
请注意，节点 id 在模型中应保持唯一。典型用法如下：
```java
ModelBuilder modelBuilder = new ModelBuilder();
modelBuilder.begin();
modelBuilder.node().id = "node1";
...//build node1
modelBuilder.node().id = "node2";
...//build node2
Model model = modelBuilder.end();
```
第一个节点可以不调用 `node()` 方法。例如，对于只包含单个节点的模型，可以直接开始创建节点部件。

同一时间只能有一个 `Node` 处于构建状态。调用 `node()` 方法会停止构建之前的节点（如果有），并开始构建新创建的节点。不过，只有 Model 完成构建（调用 `end()`）后，节点才有效（完整）。

## 创建节点部件
一个 `Node` 可以包含一个或多个[部件](/wiki/graphics/3d/models#nodepart)。节点的每个部件都会在同一位置（[节点变换](/wiki/graphics/3d/models#node-transformation)）渲染，但可以使用不同的[材质](/wiki/graphics/3d/material-and-environment)（例如着色器 uniform）和/或网格（例如着色器顶点属性）。

> NodePart 是 Model 中最小的可渲染部件。每个可见的 NodePart 都意味着一次渲染调用（也可以称为“绘制调用”）。减少渲染调用次数有助于缩短模型的渲染时间。因此，在可行时，建议尽量将多个部件合并为一个部件。

要向当前节点添加 [`NodePart`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/model/NodePart.html)，可以使用某个 `part(...)` 方法。NodePart 本质上是 [`MeshPart`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/model/MeshPart.html) 与 [`Material`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/Material.html) 的组合。调用 `part(...)` 方法时必须提供材质；而对于 `MeshPart`，`ModelBuilder` 既允许自行指定网格（的一部分），也允许使用 `MeshPartBuilder` 开始构建 `MeshPart`。

> 请注意，无论使用哪种方法创建部件，`Model` 始终会负责释放 `Mesh`。

`MeshPartBuilder` 是一个接口（由下文的 `MeshBuilder` 实现），包含用于创建网格的各种辅助方法。如果使用 `part(...)` 方法通过 MeshPartBuilder 构建 MeshPart，ModelBuilder 会尝试将多个部件合并到同一个 Mesh 中。这样通常可以减少 Mesh 绑定次数。只有部件使用相同顶点属性时才能进行合并。例如：
```java
ModelBuilder modelBuilder = new ModelBuilder();
modelBuilder.begin();
MeshPartBuilder meshBuilder;
meshBuilder = modelBuilder.part("part1", GL20.GL_TRIANGLES, Usage.Position | Usage.Normal, new Material());
meshBuilder.cone(5, 5, 5, 10);
Node node = modelBuilder.node();
node.translation.set(10,0,0);
meshBuilder = modelBuilder.part("part2", GL20.GL_TRIANGLES, Usage.Position | Usage.Normal, new Material());
meshBuilder.sphere(5, 5, 5, 10, 10);
Model model = modelBuilder.end();
```
这会创建一个包含两个节点的模型，每个节点包含一个部件。两个部件共享 Mesh，因此该 Model 只创建一个 Mesh。注意，本例使用位掩码指定顶点属性，这会让 `ModelBuilder` 创建默认的（3D）`VertexAttributes`。也可以自行指定 [`VertexAttributes`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/VertexAttributes.html)。

> 由于 `ModelBuilder` 会为多个部件复用 `MeshPartBuilder` 实例，因此不能同时构建多个部件。每个 `ModelBuilder` 在任意时刻只能构建一个 `Model`、`Node` 和 `MeshPart`。**调用 `part(...)` 方法会使之前的 `MeshPartBuilder` 失效。**

有关如何使用 `MeshPartBuilder` 创建部件形状的更多信息，请参阅下面的 MeshPartBuilder 一节。
# MeshBuilder
[MeshBuilder](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/MeshBuilder.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/MeshBuilder.java) 是用于创建一个或多个[网格](/wiki/graphics/opengl-utils/meshes)的工具类，也可以选择包含一个或多个 [MeshPart](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/model/MeshPart.html)。通常，ModelBuilder 会通过 `ModelBuilder#part(...)` 方法构建并维护 `MeshBuilder`，但也可以脱离 ModelBuilder 单独使用 MeshBuilder。此时可以使用 `begin(...)` 方法开始构建网格，完成后必须调用 `end()`。begin 方法接受各种参数，用于指定顶点属性和可选的图元类型（不创建 mesh part 时必须指定）。`end()` 方法会返回新创建的 [`Mesh`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Mesh.html)。可以使用同一个 `MeshBuilder` 实例构建多个网格，但不能同时构建：
```java
MeshBuilder meshBuilder = new MeshBuilder();
meshBuilder.begin(Usage.Position | Usage.Normal, GL20.GL_TRIANGLES);
...//build the first mesh
Mesh mesh1 = meshBuilder.end();

meshBuilder.begin(Usage.Position | Usage.Normal | Usage.ColorPacked, GL20.GL_TRIANGLES);
...//build the second mesh
Mesh mesh2 = meshBuilder.end();
```

> 请记住，不再需要 `Mesh` 时必须将其释放。

使用 `part(...)` 方法可以创建由多个部件组成的 Mesh。该方法会创建一个新的 `MeshPart` 并将其设为当前构建部件。
```java
MeshBuilder meshBuilder = new MeshBuilder();
meshBuilder.begin(Usage.Position | Usage.Normal);
MeshPart part1 = meshBuilder.part("part1", GL20.GL_TRIANGLES);
... // build the first part
MeshPart part2 = meshBuilder.part("part2", GL20.GL_TRIANGLES);
... // build the second part
Mesh mesh = meshBuilder.end();
```
虽然 `part(...)` 方法会返回 `MeshPart` 以便稍后引用，但在调用 `end()` 方法之前它并不有效。同一时间只能创建一个 `MeshPart`；调用 `part(...)` 方法会停止构建之前的部件，并开始构建新部件。

同一个 `Mesh` 的所有部件共享相同的 `VertexAttributes`，但各部件的图元类型可以不同。例如，下面的代码片段创建了两个图元类型不同、但共享同一网格的部件：
```java
meshBuilder.begin(Usage.Position | Usage.Normal);
MeshPart part1 = meshBuilder.part("part1", GL20.GL_TRIANGLES);
... // build the first part
MeshPart part2 = meshBuilder.part("part2", GL20.GL_TRIANGLE_STRIP);
... // build the second part
Mesh mesh = meshBuilder.end();
```

`MeshBuilder` 实现了 `MeshPartBuilder`。如何创建网格（或网格部件）的实际形状，将在 MeshPartBuilder 一节介绍。

# MeshPartBuilder
[MeshPartBuilder](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/MeshPartBuilder.html) ([代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/MeshPartBuilder.java)) 是一个工具接口，提供用于创建网格（或网格部件）的各种方法。可以使用 `ModelBuilder.part(...)` 或构造 MeshBuilder 来获取 MeshPartBuilder。只有在构建 `MeshPart` 期间才能调用 MeshPartBuilder 接口的方法（通常是在调用 `part(...)` 方法之后、调用 ModelBuilder 或 MeshBuilder 的下一个 `part(...)` 或 `end()` 方法之前）。

使用 `getMeshPart()` 方法获取当前正在构建的 `MeshPart`。
使用 `getAttributes()` 方法获取当前正在构建的 `Mesh` 的 `VertexAttributes`。

必须包含 `Usage.Position` 的 `VertexAttribute`（2D 或 3D 均可）。对指定的其他顶点属性没有更多限制。不过，大多数方法（尤其是高级方法）只针对位置、法线、颜色（打包或未打包）和纹理坐标属性实现。如果还使用其他属性，则会使用默认值（通常为零）。

大多数方法提供了多种签名，用于指定顶点属性的值。辅助类 [`VertexInfo`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/MeshPartBuilder.VertexInfo.html) 用于逐顶点指定这些值。例如，`rect(...)` 方法为每个角点接受一个 `VertexInfo`，而不是提供包含所有可能组合或参数的单一方法。请注意，`VertexInfo` 会跟踪特定值是否已设置，因此应始终使用 setXXX 方法。要取消设置某个值，请使用 `null`。

使用 `setColor(...)` 方法可以指定默认颜色：当 `VertexAttributes` 包含颜色 `VertexAttribute`，但例如 `VertexInfo` 中未设置颜色时，就会使用该默认颜色。例如：
```java
meshPartBuilder.setColor(Color.RED);
VertexInfo v1 = new VertexInfo().setPos(0, 0, 0).setNor(0, 0, 1).setCol(null).setUV(0.5f, 0.0f);
VertexInfo v2 = new VertexInfo().setPos(3, 0, 0).setNor(0, 0, 1).setCol(null).setUV(0.0f, 0.0f);
VertexInfo v3 = new VertexInfo().setPos(3, 3, 0).setNor(0, 0, 1).setCol(null).setUV(0.0f, 0.5f);
VertexInfo v4 = new VertexInfo().setPos(0, 3, 0).setNor(0, 0, 1).setCol(null).setUV(0.5f, 0.5f);
meshPartBuilder.rect(v1, v2, v3, v4);
```
在此例中，由于 `VertexInfo` 未设置颜色（`setCol(null)`），因此会使用设为红色的默认颜色。

使用 `setUVRange` 可以指定未设置纹理坐标时使用的默认纹理坐标范围。结合默认颜色，这对只需要位置、其他顶点信息可以从形状推导出的简单形状尤其有用。例如：
```java
meshPartBuilder.setColor(Color.RED);
meshPartBuilder.setUVRange(0.5f, 0f, 0f, 0.5f);
meshPartBuilder.rect(0,0,0, 3,0,0, 3,3,0, 0,3,0, 0,0,1); // the last three arguments specify the normal
```
使用 `setVertexTransform(...)` 方法可以提供一个变换矩阵，该矩阵会应用于此调用之后的所有顶点。
