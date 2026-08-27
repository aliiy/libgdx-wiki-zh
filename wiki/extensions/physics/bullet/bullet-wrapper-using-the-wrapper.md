---
title: Bullet 封装：使用封装
---
## 初始化 Bullet

使用 Bullet 前，需要加载相关库。可以在 create 方法中加入以下代码：
```java
Bullet.init();
```

注意，在初始化完成前不要使用 Bullet。例如，下面的代码会出错，因为 `btGhostPairCallback` 在库加载前就被创建了。
```java
public class InvokeRuntimeExceptionTest {
  final static btGhostPairCallback ghostPairCallback = new btGhostPairCallback();
}
```

## 使用 Bullet 封装
封装通常遵循原始 Bullet 的类名，也就是说大多数类都以 “bt” 开头。少数例外主要是嵌套结构体，它们直接在 `com.badlogic.gdx.physics.bullet` 包中自定义实现。不幸的是，某些嵌套结构体和基类不适合一对一转换，详情请参阅自定义类部分。如果发现缺少某个类，可以在论坛或 issue tracker（https://github.com/libgdx/libgdx/issues）中提出，以便将其加入封装。

## 回调

回调需要特别注意。默认情况下，封装只支持单向交互（从 Java 到 C++）。需要由 C++ 调用 Java 代码的回调接口都是自定义实现的。如果发现尚未实现的回调接口，可以在论坛中提出，以便将其加入封装。

回调接口列表（可能不完整）：
 * `LocalShapeInfo`
 * `LocalRayResult`
 * `RayResultCallback`
 * `ClosestRayResultCallback`
 * `AllHitsRayResultCallback`
 * `LocalConvexResult`
 * `ConvexResultCallback`
 * `ClosestConvexResultCallback`
 * `ContactResultCallback`
 * `btMotionState`
 * `btIDebugDraw`
 * `InternalTickCallback`
 * `ContactListener`
 * `ContactCache`

## 属性
属性通过 getter 和 setter 方法封装。getter 和 setter 方法的名称会省略 `m_` 前缀。例如，本机类 `btCollisionObjectWrapper` 的 `m_collisionObject` 成员实现为 `getCollisionObject()` 和 `setCollisionObject(...)`。

## 创建和销毁对象
每次在 Java 中创建 Bullet 类时，也会在 C++ 中创建对应的类。Java 对象由垃圾回收器维护，而 C++ 对象不会。为避免孤立的 C++ 对象造成内存泄漏，默认情况下，当垃圾回收器销毁 Java 对象时，也会自动销毁 C++ 对象。

虽然这在某些情况下有用，但它只是故障保护机制，不应依赖它。由于无法控制垃圾回收器，也就无法控制对象是否销毁、何时销毁以及销毁顺序。因此，当对象被垃圾回收器自动销毁时，封装会记录错误。可以使用 `Bullet.init()` 方法的第二个参数禁用此错误日志，但更推荐使用下一段介绍的方法。

为确保正确的垃圾回收，应一直保留所创建对象的引用，直到不再需要它，然后自行销毁。可以对 Java 对象调用 `.dispose()` 方法销毁 C++ 对象；之后应移除对该 Java 对象的所有引用，因为它已不可用。

上述规则只适用于由你负责的对象，即使用 `new` 关键字创建的所有 Bullet 类，以及通过辅助方法创建的类。不需要销毁普通方法返回的对象，也不需要销毁回调方法提供给你的对象。

## 引用对象
如上所述，应保留每个 Bullet 类的引用，并在不再需要时调用 dispose 方法。应用变得复杂、对象被多个其他对象共享后，跟踪引用可能会变得困难。因此 Bullet 封装支持引用计数。

默认禁用引用计数。要启用它，请将 `Bullet.init();` 的第一个参数设为 true：
```java
Bullet.init(true);
```

使用引用计数时，必须对每个需要引用的对象调用 `obtain()` 方法。不再需要引用对象时，必须调用 `release()` 方法。如果对象没有其他引用，release 方法会销毁它。

一些封装类可以帮助管理引用。例如，`btCompoundShape` 类会获取所有子形状的引用，并在销毁时释放它们。

## 扩展类
可以扩展 Bullet 类，但除回调类外不建议这样做（扩展回调类时也只能重写预期的方法）。添加到类中的信息在 C++ 中不可用。此外，Bullet 封装中返回被扩展类的方法，其结果不会实现该扩展类。例如：
```java
btCollisionShape shape = collisionObjectA.getCollisionShape();
```

这会创建一个新的 Java btCollisionShape 类，它不会实现任何扩展类。

btCollisionObject 是一个例外，封装会尝试复用同一个 Java 类。此外，btCollisionObject 的 Java 实现增加了 `userData` 成员，可用于向对象附加额外数据。为此，封装维护了一个包含所有 btCollisionObject 实例引用的数组。可以通过静态字段 `btCollisionObject.instances` 访问该数组。详情请参阅 btCollisionObject 的 `./Bullet Wrapper: Custom classes#btcollisionobject` 部分。

由于存在一个[问题](https://code.google.com/archive/p/libgdx/issues/1453)，这里没有 upcast 方法。对于在 Java 中创建的类不需要这些方法，可以直接进行类型转换。

## 比较类
可以使用 `equals()` 方法比较封装类，它会检查两个类是否封装了同一个本机类。要获取底层 C++ 类的指针，可以使用具体对象的 `getCPointer` 方法。也可以比较这些指针，以检查 Java 类是否封装了同一个 C++ 类。

## 常用类
Bullet 使用了一些 libGDX 核心库中也提供的类。虽然这些 Bullet 类也可以使用，但封装会尽可能使用 libGDX 类。目前包括：

| *Bullet* | *Libgdx* |
|:--------:|:--------:|
| btVector3 | Vector3 |
| btQuaternion | Quaternion |
| btMatrix3x3 | Matrix3 |
| btTransform | Matrix4 |
| btScalar | float |

<sub>注意，从 Matrix4 转换为 btTransform 可能会丢失一些信息，因为 btTransform 只包含原点和旋转。另外，btScalar 是基本类型 float 的同义类型。</sub>

为避免为这些常用类创建对象，封装会复用同一个实例。因此请注意以下两种情况：

  1. 返回这类对象的封装方法，其结果会被下一个返回相同类型的方法覆盖：
```java
// Wrong method:
Matrix4 transformA = collisionObjectA.getWorldTransform();
// transformA now holds the worldTransform of collisionObjectA
Matrix4 transformB = collisionObjectB.getWorldTransform();
// transformA and transformB are the same object and now holds the worldTransform of collsionObjectB

// Correct method:
transformA.set(collisionObjectA.getWorldTransform());
transformB.set(collisionObjectB.getWorldTransform());
```
  2. 接口回调中这类对象的参数在调用结束后不可使用：
```java
// Wrong method:
@Override
public void setWorldTransform (final Matrix4 worldTrans) {
	transform = worldTrans;
}
// Correct method:
@Override
public void setWorldTransform (final Matrix4 worldTrans) {
	transform.set(worldTrans);
}
```

## 使用数组
在可能的情况下，封装使用直接 ByteBuffer 对象将数组从 Java 传递到 C++。这样可以避免调用时复制数组，并允许 OpenGL ES 和 Bullet 共享同一个字节缓冲区。如有需要，可以使用 `BufferUtils.newUnsafeByteBuffer` 创建新的 ByteBuffer，并使用 `BufferUtils.disposeUnsafeByteBuffer` 手动删除它。

无法或不希望使用 ByteBuffer 时，会使用普通数组。默认情况下，这意味着方法开始时通过迭代将数组从 Java 复制到 C++，方法结束时再复制回来。为避免此开销，封装会在可能时通过 critical array 直接在 C++ 中使用 Java 数组。此类方法执行期间会阻止 Java 垃圾回收。`btBroadphasePairArray.getCollisionObjects` 就是一个示例。
