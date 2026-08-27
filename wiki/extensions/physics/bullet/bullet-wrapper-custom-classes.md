---
title: Bullet 封装：自定义类
---
有时无法将 C++ Bullet 类或方法封装为 Java 类或方法，此时会使用自定义类或方法连接两者。下面列出了这些情况。请注意，此列表可能并不完整。

### btCollisionObject

btCollisionObject 经修改后会复用 Java 对象，而不是每次都创建新对象。这通过静态的 `btCollisionObject.instances` 映射实现。要从映射中移除对象并删除本机对象，请使用 `dispose` 方法。

除了复用实例，Bullet 封装还允许提供唯一数字来标识实例，例如实体系统中实体的索引或 ID。一些常用方法允许使用该值代替实例本身，从而完全消除映射 C++ 和 Java 实例的开销。可以使用 `setUserValue(int);` 设置该值，并使用 `getUserValue();` 获取它。

```java
public class MyGameObject {
  public btCollisionObject body;
}
...
Array<MyGameObject> gameObjects;
...
gameObjects.add(myGameObject);
myGameObject.body.setUserValue(gameObjects.size-1);
```

可以使用 `userData` 字段添加其他数据。例如：
```java
btCollisionObject obj = new btCollisionObject();
obj.userData = myGameObject;
...
if (obj.userData instanceof MyGameObject)
  myGameObject = (MyGameObject)obj.userData;
```

`btCollisionObject` 增加了 `takeOwnership` 和 `releaseOwnership` 方法。它们可用于移除封装的所有权，或让封装负责在 Java 对象被垃圾回收器销毁时销毁本机对象。

`btCollisionObject` 还增加了以下方法：
 * `getAnisotropicFriction(Vector3)`
 * `getWorldTransform(Matrix4)`
 * `getInterpolationWorldTransform(Matrix4)`
 * `getInterpolationLinearVelocity(Vector3)`
 * `getInterpolationAngularVelocity(Vector3)`
  * `getContactCallbackFlag()` 和 `setContactCallbackFlag(int)`
  * `getContactCallbackFilter()` 和 `setContactCallbackFilter(int)`

### ClosestNotMeConvexResultCallback
`ClosestNotMeConvexResultCallback` 类是自定义的 `ClosestConvexResultCallback` 实现，可用于对除指定对象外的所有对象执行 `convexSweepTest`。

### ClosestNotMeRayResultCallback

`ClosestNotMeRayResultCallback` 类是自定义的 `ClosestRayResultCallback` 实现，可用于对除指定对象外的所有对象执行 `rayTest`。

### InternalTickCallback

`InternalTickCallback` 用于将 `btDynamicsWorld#setInternalTickCallback` 所需的回调桥接到 Java 类。可以继承该类并重写 `onInternalTick` 方法，也可以使用 `attach` 和 `detach` 方法开始或停止接收 tick 回调。

### btDefaultMotionState

有时使用 `btDefaultMotionState` 比继承 `btMotionState` 更方便。`btDefaultMotionState` 提供以下自定义方法：
 * `getGraphicsWorldTrans(Matrix4)`
 * `getCenterOfMassOffset(Matrix4)`
 * `getStartWorldTrans(Matrix4)`
注意，推荐的方式是自行实现并继承 `btMotionState`。

### btCompoundShape

`btCompoundShape` 类可以保存对子形状的引用，因此无需自行保存。使用时，将 `addChildShape` 的第三个参数 `managed` 设为 true。注意，删除复合形状时也会删除受管理的子形状，因此受管理的形状应专属于该复合形状。

### btIndexedMesh

`btIndexedMesh` 类增加了以下构造函数：
 * `btIndexedMesh(Mesh)`
以及以下方法：
 * `setTriangleIndexBase(ShortBuffer)`
 * `setVertexBase(FloatBuffer)`
 * `set(Mesh)`
这些方法便于根据 `Mesh` 实例或顶点和索引缓冲区构造或设置 `btIndexedMesh`。封装不会管理这些缓冲区，它们的生命周期应长于该对象。

### btTriangleIndexVertexArray

`btTriangleIndexVertexArray` 类能够保存所包含 Java `btIndexedMesh` 类的引用。使用时调用 `addIndexedMesh`，并将最后一个参数 `managed` 设为 true。销毁 `btTriangleIndexVertexArray` 时，也会销毁其受管理的 `btIndexedMesh` 子对象。

此外，`btTriangleIndexVertexArray` 类还增加了 `addMesh` 和 `addModel` 方法及相应构造函数，便于构造和设置该类。

### btBvhTriangleMeshShape

`btBvhTriangleMeshShape` 类能够保存 Java `btStridingMeshInterface` 类的引用。使用时将构造函数中的 `managed` 参数设为 true。销毁 `btBvhTriangleMeshShape` 时，也会销毁受管理的 `btStridingMeshInterface`。

此外，`btBvhTriangleMeshShape` 类还增加了便于构造一个或多个 `Mesh` 或 `Model` 实例的构造函数。

### btConvexHullShape

`btConvexHullShape` 类增加了便捷构造函数 `btConvexHullShape(btShapeHull)`。

### btBroadphasePairArray

`btBroadphasePairArray` 类增加了可一次获取其中所有碰撞对象的方法：
```java
btBroadphasePairArray.getCollisionObjects(Array<btCollisionObject> out, btCollisionObject other, int[] tempArray)
btBroadphasePairArray.getCollisionObjectsValue(int[] out, btCollisionObject other)
```
### FilterableVehicleRaycaster

`FilterableVehicleRaycaster` 类继承 `btDefaultVehicleRaycaster`，并增加了使用组和掩码进行碰撞过滤的支持：
```java
FilterableVehicleRaycaster raycaster = new FilterableVehicleRaycaster(dynamicsWorld);
raycaster.setCollisionFilterGroup(FILTER_GROUP);
raycaster.setCollisionFilterMask(FILTER_MASK);
btRaycastVehicle vehicle = new btRaycastVehicle(vehicleTuning, chassis, raycaster);
```
