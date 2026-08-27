---
title: 模型
---
模型表示一个由节点层级组成的 3D 资源，其中每个节点由几何体（网格）和材质组合而成。模型还可以选择包含[动画和/或蒙皮](/wiki/graphics/3d/3d-animations-and-skinning)信息。

模型不用于直接渲染。相反，应为 Model 创建一个或多个 ModelInstance，并使用它们进行实际渲染。ModelInstance 的结构与 Model 大致相同。

## 节点
模型是节点的层级表示。实际而言，这意味着模型包含一个节点数组，而每个节点也包含一个节点数组。可以通过公开的 `nodes` 数组或某个 `getNode(...)` 方法访问节点。每个节点在模型中都有唯一的 `id`。

每个 Node 同时只能属于一个 Model 或一个 ModelInstance，绝不会在多个 Model 或 ModelInstance 之间共享。因此，修改 ModelInstance 的 Node 只会影响该 ModelInstance。修改 Model 的 Node 会影响该 Model 以及修改后从它创建的所有 ModelInstance，但此前从该 Model 创建的 ModelInstance 不会改变。

### 节点变换
可以对节点进行变换（平移、旋转和/或缩放），这也会变换所有子节点。可以在加载模型时设置变换，也可以通过代码修改。节点通过 `translation` 和 `scale` 向量以及 `rotation` 四元数表示变换。修改这些值后，必须更新变换（包括所有子节点）以反映变化。可以使用 `model.calculateTransforms();` 方法完成更新（ModelInstance 类也提供此方法）。

计算或重新计算 Node 的变换时，结果会存储在 `localTransform` 和 `globalTransform` 矩阵中。`localTransform` 矩阵表示节点相对于父节点的变换。`globalTransform` 矩阵表示节点相对于模型或模型实例的变换。换句话说，Node 的 `globalTransform` 等于其父节点的 `globalTransform` 乘以该节点的 `localTransform`。

对 ModelInstance 应用动画时，`isAnimated` 值会设为 true。这会导致重新计算变换时不使用 `translation`、`scale` 和 `rotation` 值。

### NodePart
节点可以选择拥有可视化表示。因此，Node 类包含一个 NodeParts 数组。每个 NodePart 由 MeshPart 和 Material 组成，分别指定形状（MeshPart）的渲染方式（材质）和位置（节点变换）。它还可以选择包含网格变形（用于蒙皮）和 UV 映射（用于多组纹理坐标）信息。

## 管理资源
模型由一个或多个网格组成，通常还包含一个或多个纹理。Mesh 和 Texture 类（以及可能存在的其他资源）不再需要时都必须正确释放。模型负责释放其包含的所有资源。不再需要模型时，应使用其 `dispose();` 方法释放，这会释放所有底层资源，并使依赖对象（如 `ModelInstance`）失效。

要获取模型负责管理的 Disposables 列表，请使用 `getManagedDisposables()` 方法。要通过代码让模型负责管理某个资源，请使用 `manageDisposable(Disposable)` 方法。例如，更换模型纹理并希望在释放模型时一并释放该纹理时，就可以使用此方法。

由于模型负责管理自身资源，因此建议将资源分开管理。例如，不建议在多个模型之间共享资源。多数情况下，可以在加载或构建模型之前将模型完全合并，或者在 ModelInstance 之间共享资源，而不是在 Model 之间共享。
