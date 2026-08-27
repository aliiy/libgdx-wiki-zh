---
title: Bullet 封装：使用模型
---
## 使用模型
[`Model`](/wiki/graphics/3d/models) 和 `ModelInstance` 通常用于表示对象的视觉效果。`btCollisionObject` 或 `btRigidBody` 用于表示这些对象的物理效果。

### 使用运动状态
为了同步 `ModelInstance` 和 `btRigidBody` 的位置与方向，Bullet 提供了可供扩展的 `btMotionState` 类。下面是一个非常基础的同步示例：
```java
static class MyMotionState extends btMotionState {
    Matrix4 transform;
    @Override
    public void getWorldTransform (Matrix4 worldTrans) {
        worldTrans.set(transform);
    }
    @Override
    public void setWorldTransform (Matrix4 worldTrans) {
        transform.set(worldTrans);
    }
}
```
用法如下：
```java
btRigidBody body;
ModelInstance instance;
MyMotionState motionState;
...
motionState = new MyMotionState();
motionState.transform = instance.transform;
body.setMotionState(motionState);
```
现在每当 `btRigidBody` 移动时，`ModelInstance` 的位置和方向都会由 Bullet 更新。这种方法不限于 `ModelInstance`，任何包含 `Matrix4` 变换的对象都可以使用，例如 `Renderable`。此外，还可以在运动状态中加入简单逻辑，例如：
```java
static class PlayerMotionState extends btMotionState {
    final static Vector3 position = new Vector3();
    Player player;
    @Override
    public void getWorldTransform (Matrix4 worldTrans) {
        worldTrans.set(player.transform);
    }
    @Override
    public void setWorldTransform (Matrix4 worldTrans) {
        player.transform.set(worldTrans);
        player.transform.getTranslation(position);
        if (position.y < 0)
            player.die();
    }
}
```
注意，`btRigidBody` 的变换（位置和旋转）通常是相对于质心的（最常见的是形状中心）。必要时，可以使用 `btCompoundShape` 移动质心。建议让视觉模型的原点与物理对象的原点保持一致。如果无法做到，可以相应地修改运动状态中的变换。

> 请记住，Bullet 的变换只支持平移（位置）和旋转（方向），不支持缩放等其他变换。

不再需要运动状态时必须销毁它：`motionState.dispose();`。

### 从模型创建碰撞对象
Model 本质上是一组带有属性的三角形，并通过特定变换进行渲染。它针对渲染而非物理进行了优化。因此，Model 很少适合高效表示物理形状。

要理解原因，可以考虑一个简单的盒子模型。盒子的物理形状只需包含八个角，而视觉模型会包含 24 个角（顶点）。这是因为盒子的每个面都要分别指定顶点，并且每个顶点包含该面的“法线”；否则就无法实现光照等视觉效果。因此，视觉模型并不是一个实体盒子，而是由六个相互独立的矩形组成。这些矩形（或组成它们的三角形）无限薄、没有体积，所以不适合动态物理。

还有其他问题，例如模型通常包含超出物理计算所需的细节。事实上，对于某些形状，使用比模型顶点更廉价的碰撞检测算法是可行的。例如对于盒子形状，可以只进行一次盒子碰撞检测，而不必检测组成它的 12 个三角形。

解决这些问题的方法有很多，从使用基本形状近似模型，到使用专用模型，或让视觉模型与物理形状共享顶点。[Bullet 手册](https://github.com/bulletphysics/bullet3/blob/master/docs/Bullet_User_Manual.pdf?raw=true)提供了一张决策图，帮助你选择合适的方法：
![images/bullet_shape_decision.png](/assets/wiki/images/bullet_shape_decision.png)

对于静态模型，Bullet 封装提供了一个方便的碰撞形状创建方法：
```java
btCollisionShape shape = Bullet.obtainStaticNodeShape(model.nodes);
```
在这种情况下，碰撞形状会与模型共享相同的数据（顶点）。必要时，它还会通过 `btCompoundShape` 包含[节点变换](/wiki/graphics/3d/models#node-transformation)，但不会包含应用于节点的缩放。
