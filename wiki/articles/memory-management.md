---
title: 内存管理
---
游戏是资源密集型应用，尤其是图像和音效可能占用大量 RAM。libGDX 中有多个类表示这类资源，它们都实现通用的 [Disposable](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/Disposable.html) 接口，这表示必须在实例生命周期结束时手动释放它们。这是因为大多数资源由本机驱动管理，而不是由 Java 垃圾回收器管理。**不释放资源会导致严重的内存泄漏！**

以下类需要手动释放（列表可能不完整，完整列表请参见[这里](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/Disposable.html)）：

  * AssetManager
  * Bitmap
  * BitmapFont
  * BitmapFontCache
  * CameraGroupStrategy
  * DecalBatch
  * ETC1Data
  * FrameBuffer
  * Mesh
  * Model
  * ModelBatch
  * ParticleEffect
  * Pixmap
  * PixmapPacker
  * Shader
  * ShaderProgram
  * Shape
  * Skin
  * SpriteBatch
  * SpriteCache
  * Stage
  * Texture
  * TextureAtlas
  * TileAtlas
  * TileMapRenderer
  * com.badlogic.gdx.physics.box2d.World
  * all bullet classes

资源一旦不再需要就应立即释放，以回收其占用的内存。访问已释放的资源会产生未定义错误，因此务必清除对已释放资源的所有引用。

如果不确定某个类是否需要释放，请检查它是否具有实现自 `com.badlogic.gdx.utils` 的 `Disposable` 接口的 `dispose()` 方法。如果有，则说明你正在处理本机资源。

### 对象池

对象池的原则是复用未激活或“死亡”的对象，而不是每次都创建新对象。具体做法是创建对象池，需要新对象时从池中获取。如果池中有可用（空闲）对象，就返回该对象；如果池为空或没有空闲对象，则创建并返回新实例。不再需要对象时，将其“释放”，也就是放回对象池。
这样可以复用对象分配的内存，也能减轻垃圾回收器的压力。

对于频繁生成子弹、障碍物、怪物等对象的游戏，这对内存管理非常重要。

libGDX 提供了几个便于使用对象池的工具。

  * [Poolable](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/Pool.Poolable.html) 接口
  * [Pool](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/Pool.html)
  * [Pools](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/Pools.html)

实现 `Poolable` 接口意味着对象中会有一个 `reset()` 方法，在释放对象时会自动调用该方法。

下面是一个使用对象池管理子弹对象的最小示例。

```java
public class Bullet implements Pool.Poolable {

    public Vector2 position;
    public boolean alive;

    /**
     * Bullet constructor. Just initialize variables.
     */
    public Bullet() {
        this.position = new Vector2();
        this.alive = false;
    }
    
    /**
     * Initialize the bullet. Call this method after getting a bullet from the pool.
     */
    public void init(float posX, float posY) {
    	position.set(posX,  posY);
    	alive = true;
    }

    /**
     * Callback method when the object is freed. It is automatically called by Pool.free()
     * Must reset every meaningful field of this bullet.
     */
    @Override
    public void reset() {
        position.set(0,0);
        alive = false;
    }

    /**
     * Method called each frame, which updates the bullet.
     */
    public void update (float delta) {
    	
    	// update bullet position
    	position.add(1*delta*60, 1*delta*60);
    	
    	// if bullet is out of screen, set it to dead
    	if (isOutOfScreen()) alive = false;
    }
}
```

在你的游戏世界类中：
```java
public class World {

    // array containing the active bullets.
    private final Array<Bullet> activeBullets = new Array<Bullet>();

    // bullet pool.
    private final Pool<Bullet> bulletPool = new Pool<Bullet>() {
	@Override
	protected Bullet newObject() {
		return new Bullet();
	}
    };

    public void update(float delta) {
	
        // if you want to spawn a new bullet:
        Bullet item = bulletPool.obtain();
        item.init(2, 2);
        activeBullets.add(item);

        // if you want to free dead bullets, returning them to the pool:
    	Bullet item;
    	int len = activeBullets.size;
    	for (int i = len; --i >= 0;) {
    	    item = activeBullets.get(i);
    	    if (item.alive == false) {
    	        activeBullets.removeIndex(i);
    	        bulletPool.free(item);
    	    }
    	}
    }
}
```

[Pools](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/Pools.html) 类提供了静态方法，可以动态创建任意对象的对象池（使用 [ReflectionPool](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/ReflectionPool.html) 和一些“黑魔法”）。在上面的示例中，可以这样使用：
```java
private final Pool<Bullet> bulletPool = Pools.get(Bullet.class);
```

### 如何使用 Pool

`Pool<>` 管理一种对象，因此需要使用该类型进行参数化。通过调用 `obtain` 从指定的 `Pool` 实例中获取对象，然后应通过调用 `free` 将对象归还给 Pool。池中的对象可以选择实现 [`Pool.Poolable`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/Pool.Poolable.html) 接口（该接口只要求提供 `reset()` 方法）；如果实现了，`Pool` 会在对象归还时自动重置对象。默认情况下，对象按需分配（因此如果从未调用 `obtain`，Pool 中就没有对象）。实例化后调用 `fill()` 可以强制 `Pool` 分配指定数量的对象。预先分配有助于控制首次分配发生的时间。

由于 `newObject` 方法是抽象方法，因此必须自行实现 `Pool<>` 的子类。

### Pool 的注意事项

注意不要泄漏对池中对象的引用。调用 Pool 的 `free` 并不会使仍然存在的引用失效；如果不小心，就会导致难以发现的 bug。如果对象放回对象池时没有完全重置其状态，也可能产生难以发现的 bug。

### 分析内存泄漏

如果遇到内存泄漏，[VisualVM](https://visualvm.github.io/)（免费）和 [JProfiler](https://www.ej-technologies.com/products/jprofiler/overview.html)（试用/付费）等工具有助于定位问题。这些内存分析器会告诉你是哪种对象占用了内存，你可以据此继续追踪泄漏来源。

[LeakCanary](https://square.github.io/leakcanary/) 是一个免费工具，最初用于自动检测 Android 应用中的泄漏，但也可以[配置为在 JVM 上运行](https://square.github.io/leakcanary/recipes/#detecting-leaks-in-jvm-applications)。
