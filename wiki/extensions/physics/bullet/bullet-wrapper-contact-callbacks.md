---
title: Bullet 封装：接触回调
---
接触回调允许你在两个对象发生接触或碰撞时收到通知（参见[更多信息及性能警告](https://web.archive.org/web/20180906172418/http://bulletphysics.org/mediawiki-1.5.8/index.php/Collision_Callbacks_and_Triggers)）。

默认提供三个回调：[`onContactAdded`](https://web.archive.org/web/20180906172418/http://bulletphysics.org/mediawiki-1.5.8/index.php/Collision_Callbacks_and_Triggers#gContactAddedCallback)、[`onContactProcessed`](https://web.archive.org/web/20180906172418/http://bulletphysics.org/mediawiki-1.5.8/index.php/Collision_Callbacks_and_Triggers#gContactProcessedCallback) 和 [`onContactDestroyed`](https://web.archive.org/web/20180906172418/http://bulletphysics.org/mediawiki-1.5.8/index.php/Collision_Callbacks_and_Triggers#gContactDestroyedCallback)。封装还增加了两个回调：`onContactStarted` 和 `onContactEnded`（参见[更多信息](https://pybullet.org/Bullet/phpBB3/viewtopic.php?t=7739&p=32470)）。回调是全局的（例如独立于碰撞世界），任意时刻每个回调只能有一个实现处于活动状态。

### 接触监听器
你可以扩展 ContactListener 类来实现一个或多个回调：
```java
public class MyContactListener extends ContactListener {
	@Override
	public void onContactStarted (btCollisionObject colObj0, btCollisionObject colObj1) {
		// implementation
	}
	@Override
	public void onContactProcessed (int userValue0, int userValue1) {
		// implementation
	}
}
```

请注意，每个回调同时只能启用一个监听器。可以使用 `enable();` 方法激活监听器，这会停用该回调的其他监听器；使用 `disable();` 方法停止接收该回调的通知。实例化监听器会自动启用对应回调，而销毁监听器（调用 `dispose();` 方法）会自动停用它。

ContactListener 类为每个回调提供了一个或多个可供重写的方法签名。例如，可以使用以下签名重写 `onContactAdded` 回调：

```java
boolean onContactAdded(btManifoldPoint cp, btCollisionObjectWrapper colObj0Wrap, int partId0, int index0, btCollisionObjectWrapper colObj1Wrap, int partId1, int index1);

boolean onContactAdded(btManifoldPoint cp, btCollisionObject colObj0, int partId0, int index0, btCollisionObject colObj1, int partId1, int index1);

boolean onContactAdded(btManifoldPoint cp, int userValue0, int partId0, int index0, int userValue1, int partId1, int index1);

boolean onContactAdded(btCollisionObjectWrapper colObj0Wrap, int partId0, int index0, btCollisionObjectWrapper colObj1Wrap, int partId1, int index1);

boolean onContactAdded(btCollisionObject colObj0, int partId0, int index0, btCollisionObject colObj1, int partId1, int index1);

boolean onContactAdded(int userValue0, int partId0, int index0, int userValue1, int partId1, int index1);
```

可以看到，其中三个方法提供 `btManifoldPoint`，另外三个不提供。要获取实际碰撞对象，可以选择 `btCollisionObjectWrapper`、`btCollisionObject` 或 `userValue`。

请重写只提供你实际需要的参数的方法。例如，如果不使用 `btManifoldPoint`，那么每次调用回调都为该参数创建对象就没有意义。同样，使用 `btCollisionObject` 的性能优于 `btCollisionObjectWrapper`，因为前者会被复用。使用 `userValue` 的性能更好，因为完全不需要映射对象（关于如何使用 userValue，请参阅 [#btCollisionObject btCollisionObject]）。

只有当两个碰撞刚体中至少有一个设置了 `CF_CUSTOM_MATERIAL_CALLBACK` 时，才会触发 `onContactAdded` 回调：
```java
body.setCollisionFlags(e.body.getCollisionFlags() | btCollisionObject.CollisionFlags.CF_CUSTOM_MATERIAL_CALLBACK);
```

要在 added、processed 和 destroyed 回调之间识别同一个接触，可以使用回调提供的 `btManifoldPoint` 实例的 `setUserValue(int);` 和 `getUserValue();`。这也是传给 ContactListener 类 `onContactDestroyed(int)` 方法的值。注意，只有 user value 非零时才会触发 `onContactDestroyed` 回调。

### 接触过滤

接触回调会被频繁调用。每次调用都在 C++ 与 Java 之间进行 JNI 桥接，会产生相当大的开销并降低性能。因此，Bullet 封装允许你指定希望接收哪些对象的接触通知，这通过接触过滤实现。

与碰撞过滤类似，可以为每个 `btCollisionObject` 使用 `setContactCallbackFlag(int);` 设置标志，并使用 `setContactCallbackFilter(int);` 设置过滤器。当 `A.filter & B.flag == B.flag` 时，对象 A 的过滤器与对象 B 匹配。只有一个或两个过滤器匹配时，接触才会传递给监听器。

```java
static int PLAYER_FLAG = 2; // second bit
static int COIN_FLAG = 4; // third bit
btCollisionObject player;
btCollisionObject coin;
...
player.setContactCallbackFlag(PLAYER_FLAG);
coin.setContactCallbackFilter(PLAYER_FLAG);
// The listener will only be called if a coin collides with player
```

默认情况下，`btCollisionObject` 的 `contactCallbackFlag` 为 1，`contactCallbackFilter` 为 0。注意，将标志设为零会导致该对象始终触发回调（因为 `x & 0 == 0`）。

是否使用接触过滤取决于你重写的方法签名。对于支持接触过滤的每个回调，ContactListener 类都提供带有 `boolean match0` 和 `boolean match1` 参数的方法签名。重写这类方法时，该方法会使用接触过滤；如果重写不带 `boolean match` 参数的方法，则该方法不会使用接触过滤。

可以使用 `boolean match0` 和 `boolean match1` 的值检查两个过滤器中的哪一个匹配。
```java
public class MyContactListener extends ContactListener {
	@Override
	public void onContactEnded (int userValue0, boolean match0, int userValue1, boolean match1) {
		if (match0) {
			// collision object 0 (userValue0) matches
		}
		if (match1) {
			// collision object 1 (userValue1) matches
		}
	}
}
```

即使使用接触过滤，碰撞时仍可能频繁调用回调。要避免这种情况，可以在处理后将过滤器设为零。例如对于玩家和硬币，最好让硬币与玩家发生一次碰撞，然后在首次接触时将硬币的过滤器设为零，而不是让玩家持续与硬币碰撞。
