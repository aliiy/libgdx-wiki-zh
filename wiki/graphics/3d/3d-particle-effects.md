---
title: 3D 粒子效果
---
由于透视和深度方面的问题，2D 粒子效果不适合 3D 应用。此外，3D 粒子效果可以充分利用 3D 空间中的运动，实现各种动态图形效果。

![images/flamedemo.gif](/assets/wiki/images/flamedemo.gif)

### Flame - 3D 粒子编辑器
与 2D 粒子效果类似，3D 粒子效果可以使用 libGDX 附带的 GUI 编辑器编辑。
该编辑器名为 Flame，可从[这里](https://libgdx-nightlies.s3.eu-central-1.amazonaws.com/libgdx-runnables/runnable-3D-particles.jar)下载。

### 粒子效果类型
3D 粒子效果有三种不同类型：
* Billboards
* PointSprites
* ModelInstance

**Billboard** 是始终面向摄像机的精灵（libGDX 中的 Decal 类本质上就是 billboard）。

**PointSprites** 将精灵绘制到单个 3D 点上。它比 billboard 更简单，但效率更高。有关 OpenGL 点精灵的更多信息：[https://www.informit.com/articles/article.aspx?p=770639&seqNum=7](https://www.informit.com/articles/article.aspx?p=770639&seqNum=7)

如果使用过 libGDX 的 3D 功能，就会熟悉 **ModelInstance**。它们是 3D 模型的实例。不出所料，从性能角度看，这是开销最大的粒子效果类型。

由于这些差异，每种粒子效果类型都有专用的批处理渲染器：[BillboardParticleBatch](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/particles/batches/BillboardParticleBatch.html)、[PointSpriteParticleBatch](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/particles/batches/PointSpriteParticleBatch.html) 和 [ModelInstanceParticleBatch](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/particles/batches/ModelInstanceParticleBatch.html)。

-----------------

# 使用 3D 粒子效果
使用 3D 粒子效果最简单的方式是借助 ParticleSystem 类，由它抽象并管理各种细节。首先创建所需类型的批处理器，然后创建 ParticleSystem。本例使用 PointSprites。

有关以编程方式使用 3D 粒子的深入介绍，请参阅[测试类](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/g3d/ParticleControllerTest.java)。

**重要：** 在 IDE 中导入 **ParticleEffect** 类时，请注意不要误导入 2D 效果的 ParticleEffect 类。两者名称相同，但导入路径不同。需要导入的是：**com.badlogic.gdx.graphics.g3d.particles.ParticleEffect**

### 步骤 1：创建批处理器和 ParticleSystem
```java
ParticleSystem particleSystem = new ParticleSystem();
// Since our particle effects are PointSprites, we create a PointSpriteParticleBatch
PointSpriteParticleBatch pointSpriteBatch = new PointSpriteParticleBatch();
pointSpriteBatch.setCamera(cam);
particleSystem.add(pointSpriteBatch);
```

### 步骤 2：使用 AssetManager 加载效果
现在需要加载使用 Flame GUI 编辑器创建的粒子效果。
首先创建 ParticleEffectLoadParameter，在加载时传递给资源管理器。
然后即可加载资源。
```java
AssetManager assets = new AssetManager();
ParticleEffectLoader.ParticleEffectLoadParameter loadParam = new ParticleEffectLoader.ParticleEffectLoadParameter(particleSystem.getBatches());
assets.load("particle/effect.pfx", ParticleEffect.class, loadParam);
assets.finishLoading()
```

### 步骤 3：将已加载的 ParticleEffect 添加到 ParticleSystem
```java
ParticleEffect originalEffect = assets.get("particle/effect.pfx");
// we cannot use the originalEffect, we must make a copy each time we create new particle effect
ParticleEffect effect = originalEffect.copy();
effect.init();
effect.start();  // optional: particle will begin playing immediately
particleSystem.add(effect);
```

游戏中很可能会同时存在或随时间产生许多粒子效果。每次创建需要粒子效果的对象或图形效果时，都不应重新复制粒子效果。应将效果放入对象池，以避免创建新对象。有关对象池的更多信息，请参阅[本 Wiki](/wiki/articles/memory-management#object-pooling)或 libGDX Pool 类文档。

下面是一个 Pool 示例：
```java
private static class PFXPool extends Pool<ParticleEffect> {
	private ParticleEffect sourceEffect;

	public PFXPool(ParticleEffect sourceEffect) {
		this.sourceEffect = sourceEffect;
	}

	@Override
	public void free(ParticleEffect pfx) {
		pfx.reset();
		super.free(pfx);
	}

	@Override
	protected ParticleEffect newObject() {
		return sourceEffect.copy();
	}
}
```
注意，我们是在释放粒子时重置它，而不是在 obtain 时重置。这样可以避免因 ParticleSystem 的工作方式而产生的 NullPointerException。

### 步骤 4：使用 ParticleSystem 渲染 3D 粒子
ParticleSystem 必须更新并绘制自身组件，然后传递给 ModelBatch 实例，渲染到场景中。
```java
private void renderParticleEffects() {
	particleSystem.update(); // technically not necessary for rendering
	particleSystem.begin();
	particleSystem.draw();
	particleSystem.end();
	modelBatch.render(particleSystem);
}
```

也可以平移和旋转效果。根据引擎的工作方式，可以使用在变更时重置为单位矩阵的特定矩阵，也可以只添加增量变换或旋转。

```java
private void renderParticleEffects() {
	targetMatrix.idt();
	targetMatrix.translate(targetPos);
	effect.setTransform(targetMatrix);
	particleSystem.update(); // technically not necessary for rendering
	particleSystem.begin();
	particleSystem.draw();
	particleSystem.end();
	modelBatch.render(particleSystem);
}
```

或者

```java
private void renderParticleEffects() {
	effect.translate(deltaPos);
	particleSystem.update(); // technically not necessary for rendering
	particleSystem.begin();
	particleSystem.draw();
	particleSystem.end();
	modelBatch.render(particleSystem);
}
```

### 停止发射新粒子，但让现有粒子播放完毕
在 3D 粒子系统中实现这一点稍微复杂一些：

```java
Emitter emitter = pfx.getControllers().first().emitter;
		if (emitter instanceof RegularEmitter) {
			RegularEmitter reg = (RegularEmitter) emitter;
			reg.setEmissionMode(RegularEmitter.EmissionMode.EnabledUntilCycleEnd);
		}
```

### 简单示例
上面 GdxTest.java 的简化示例见[这里](https://github.com/SeanFelipe/SimpleParticles3d/blob/master/java/core/src/sbourges/game/gdxtest/GdxTest.java)。


### 自定义纹理
要创建新的粒子图像，必须将其保存为每通道恰好 8 位的 RGBA PNG，否则无法正确渲染。

GIMP 设置：

![gimp](https://user-images.githubusercontent.com/1824878/177935714-039f11df-d022-487c-9dc6-a372e1f02110.png)
