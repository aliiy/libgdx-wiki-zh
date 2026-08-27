---
title: 3D 动画与蒙皮
---
Model（以及 ModelInstance）可以包含一个或多个动画。动画是一系列应用于模型一个或多个节点的变换（关键帧）。每个动画由名称（id）标识，该名称在模型中必须唯一。例如，角色可能包含名为 "walk" 和 "attack" 的动画。本文介绍如何在应用中加载和使用动画。

蒙皮可以根据一个或多个节点的变换使模型（网格）发生形变，通常与动画结合使用。本文也介绍如何在应用中使用蒙皮。

# 加载动画
使用 fbx-conv 将模型从 FBX 转换为 G3DB/G3DJ 时，动画也会自动转换。与 FBX 一样，G3DB/G3DJ 文件可以在单个文件中与其他模型数据一起包含多个动画。应用于源 FBX 文件中不存在的节点的动画不会被转换。因此导出 FBX 时，请确保选中所有节点和动画。

可以将文件转换为 G3DJ 格式，并在喜欢的文本编辑器中打开结果文件，以检查转换后的动画。动画位于文件底部。请注意，动画（关键帧）可能使文件膨胀，因此生产环境建议使用更小的 G3DB 文件格式。

libGDX 不支持关键帧之间的自定义插值。如果使用线性插值以外的方式，fbx-conv 会生成额外关键帧进行补偿。补偿依据目标 FPS 完成。虽然可以在 FBX 中自定义目标 FPS，但并非所有建模应用都允许修改此值（默认值为 30 FPS）。为避免额外关键帧使文件膨胀，请尽可能使用线性插值。

使用 G3dModelLoader 或 AssetManager 在应用中加载 G3DB/G3DJ 文件时，动画也会一并加载。从 Model 创建 ModelInstance 时，动画也会复制到 ModelInstance。如果创建 ModelInstance 时指定了特定节点，则只有应用于这些节点（及其子节点）的动画会复制到新的 ModelInstance。

# 使用动画
## 应用单个动画
要将动画应用于 ModelInstance，可以创建 AnimationController。一个 AnimationController 专用于一个 ModelInstance，且 ModelInstance 的生命周期必须长于 AnimationController。AnimationController 一次可以将单个动画应用于 ModelInstance，也支持多个动画之间的混合（过渡）。如果要将多个动画应用于同一个 ModelInstance，可以使用多个 AnimationController，只要它们互不干扰（不影响相同节点）即可。

设置动画后（如下所述），需要在每帧更新 AnimationController。可以使用 `AnimationController.update(float delta)` 方法完成。`delta` 参数用于告知 AnimationController 自上次调用 update 以来经过了多少时间，通常使用 `Gdx.graphics.getDeltaTime()` 作为该参数。

要设置当前动画，请使用 `setAnimation(String id)` 方法。该方法会立即播放动画（如果存在当前动画则移除它）。`id` 参数必须是 ModelInstance 中已有动画的名称（区分大小写）。
```java
ModelInstance instance;
AnimationController controller;
public void create() {
    ...
    instance = new ModelInstance(model);
    controller = new AnimationController(instance);
    controller.setAnimation("walk");
}
public void render() {
    ...
    controller.update(Gdx.graphics.getDeltaTime());
    ...
}
```

`setAnimation(String id)` 方法会以正常速度播放动画一次，然后停止（动画冻结在最后一帧）。要移除动画（使节点恢复原始变换），请调用 `setAnimation(null)`。

### 循环
如果想多次执行动画，可以使用 `setAnimation(String id, int loopCount)` 方法。`loopCount` 参数用于指定动画播放次数（不能为零）。要持续循环动画，请使用值 `-1`。

## AnimationDesc
每个动画方法（如 `setAnimation(...)`）都会返回一个 AnimationDesc 实例，该实例在动画播放期间（或排队等待播放期间，见下文）有效。AnimationDesc 包含动画的全部信息，例如当前动画时间和剩余循环次数。可以修改这些值来控制动画执行。动画结束后，必须移除对 AnimationDesc 的所有引用，因为它可能会被复用（池化）给下一个动画。

## AnimationListener
要在动画循环或结束时收到通知，可以实现 `AnimationListener` 接口。动画循环或结束时，该接口会收到通知，并接收已循环或结束动画的 AnimationDesc。可以在每个动画方法中传入 AnimationListener，例如 `setAnimation(String id, int loopCount, AnimationListener listener)`。

## 混合动画
使用 `setAnimation` 切换动画时，之前的动画会突然停止。可以将之前的动画混合到新动画中，使动画之间平滑过渡。为此可以使用 `animate(...)`。animate 方法接受与 setAnimation 相同的参数，并额外接受 `transitionTime` 参数。在这段时间内，新动画会在线性插值后叠加到旧动画上，从而实现平滑过渡。如果不存在之前的动画，新动画会立即开始。

## 动画排队
要在当前动画完成后开始另一个动画，可以使用 `queue(...)` 方法。如果当前动画持续循环，排队的动画会在当前循环完成时执行；否则会在当前动画结束（包括所有剩余循环）时执行。如果没有当前动画，排队的动画会立即执行。指定大于零的过渡时间时，排队的动画会进行混合。

## 动作动画
动作动画是叠加在当前动画之上执行的（通常较短的）动画。实际效果相当于对动作动画调用 `animate(...)`，再对之前的动画调用 `queue(...)`。

## 动画速度
每个动画方法（如 `setAnimation`、`animate`、`queue` 和 `action`）都允许设置该动画的速度。速度定义为“每秒多少秒”。值为 `1` 时以正常速度播放；大于 1 时播放更快（例如值为 `2` 时以两倍原速执行）；小于 1 时播放更慢（例如值为 `0.5` 时以一半原速执行）。速度可以为负数，表示反向执行动画。

虽然可以控制单个动画的速度，也可以通过修改 AnimationController 的 `update(float delta)` 方法的 delta 值来控制所有动画的整体速度。例如，调用 `controller.update(0.5f * Gdx.graphics.getDeltaTime());` 会使整体速度变为原来的一半。delta 值也可以为负数，这意味着所有动画都会反向播放。

## 节点变换
动画执行期间，所有受影响节点的 `isAnimated` 成员都会设为 true。这会导致 Node 的 translation、rotation 和 scale 值不再使用。因此在动画播放时，不能自行变换受影响的节点。

# 蒙皮
蒙皮用于根据一个或多个节点（也称为骨骼或关节）的变换来改变模型。使用蒙皮时，通常使用不可见节点（未附加 NodeParts 的节点）使模型发生形变。这些节点通常组成层级结构，也称为骨架或骨骼系统。

实际使用蒙皮时，模型包含不可见的骨架部分（一个或多个节点）和可见部分（一个或多个节点）。可见节点本身保持不变，而骨架会发生变换（例如通过动画），从而影响可见网格顶点的位置。

这是通过混合权重（也称为骨骼权重）实现的，它们是可见节点的顶点属性。每个混合权重都有一个索引（指向特定骨骼/节点）和一个权重值（表示该顶点受该骨骼/节点影响的程度）。每个可见节点（NodePart）都引用其骨骼（骨架中的节点）。

## 加载蒙皮
libGDX 仅支持着色器蒙皮，这至少需要 Open GL ES 2.0。如果使用建模应用创建蒙皮模型，将其导出为 FBX 并转换为 G3DB/G3DJ，那么蒙皮应该可以无缝工作。请注意，需要将可见节点和不可见的骨架节点连同动画一起导出。

要获得最佳效果，蒙皮可能需要进行一些调整。默认情况下，fbx-conv 会为每个顶点包含 4 个骨骼权重（每个顶点最多受 4 个节点影响）。同样默认情况下，当影响顶点的骨骼总数超过 12 个时，fbx-conv 会将使用相同骨骼的顶点分组，并将网格拆分为多个部件。

拆分网格是因为着色器可使用的变量数量有限。不过，这会产生多个[渲染调用](/wiki/graphics/3d/modelbatch#what-are-render-calls)，可能影响性能。有关更多信息，请参阅[这篇文章](https://web.archive.org/web/20200429023316/https://badlogicgames.com/forum/viewtopic.php?f=11&t=12910&p=57297#p57250)。

可以使用命令行选项 `-w` 和 `-b` 更改 fbx-conv 的默认值。`-w` 命令用于指定一个顶点最多可受多少个骨骼影响，其值必须在 1 到 8 之间（默认着色器不支持超过 8 个骨骼权重）。通常应尽量使用较小的值。
```
fbx-conv -w 3 inputfile.fbx
```

`-b` 命令用于指定 fbx-conv 开始拆分网格前允许的骨骼总数。该值必须大于零，没有硬性上限。通常不应将它设为小于 `-w` 命令指定数量三倍的值。可以增大该值以避免拆分网格，但代价是占用更多着色器 uniform。
```
fbx-conv -b 16 inputfile.fbx
```

如果使用 `-b` 命令行选项更改最大骨骼数，也应将着色器修改为使用相同的数量。创建 ModelBatch 的 [ShaderProvider](/wiki/graphics/3d/modelbatch#shaderprovider) 时，可以使用 [`Config#numBones`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/shaders/DefaultShader.Config.html#numBones) 成员完成此设置。例如：
```java
DefaultShader.Config config = new DefaultShader.Config();
config.numBones = 16;
modelBatch = new ModelBatch(new DefaultShaderProvider(config));
```
