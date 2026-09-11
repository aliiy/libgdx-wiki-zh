---
title: 2D 粒子效果
---
* [ParticleEffect 基本用法](#basic-particleeffect-usage)
* [高效使用 ParticleEffect](#efficiency)
* [示例](#examples)
  * [对象池效果示例](#pooled-effect-example)
  * [批处理效果示例](#batched-effect-example)
* [视频示例](#video-example)

# ParticleEffect 基本用法
使用粒子效果很简单，只需加载在 [ParticleEditor](/wiki/tools/2d-particle-editor) 中生成的粒子效果。
```java
TextureAtlas particleAtlas; //<-load some atlas with your particle assets in
ParticleEffect effect = new ParticleEffect();
effect.load(Gdx.files.internal("myparticle.p"), particleAtlas);
effect.start();

//Setting the position of the ParticleEffect
effect.setPosition(x, y);

//Updating and Drawing the particle effect
//Delta being the time to progress the particle effect by, usually you pass in Gdx.graphics.getDeltaTime();
effect.draw(batch, delta);

```

# 效率
渲染粒子很棒，渲染大量粒子更棒。下面介绍如何在不让用户设备不堪重负的情况下做到这一点。

ParticleEffect 与 Sprite 没有区别，事实上它们[就是](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g2d/ParticleEmitter.java#L98)精灵。关于高效渲染精灵的知识同样适用于这里。

  * 使用图集！

 如果粒子效果精灵与其他游戏资源（至少是会一起批处理的资源）共享纹理，就不必切换纹理，也就不会导致 Batch 刷新。Batch 刷新开销很大，不应过于频繁，否则无法充分发挥 Batch 的性能。

  * 将效果放入对象池

 随意创建新的 ParticleEffect？请停止这样做，改用 Pool！垃圾回收会降低游戏性能，在移动平台上尤其明显，因此应尽量避免产生垃圾。使用 `ParticleEffectPool` 可以完全避免这类垃圾：使用完 `ParticleEffect` 后将其复用。不再浪费内存，也不再频繁垃圾回收。

 简单来说，就是从 Pool 获取对象，使用完后归还，以便再次使用。

 实现对象池请参阅[下面的示例](#pooled-effect-example)。

  * 批处理效果
   将使用相同纹理或混合模式的 ParticleEffect 一起绘制。不要打断 Batch，也就是不要切换纹理或混合状态。这样可以充分发挥 Batch 的性能，减轻设备负担。

   如果 ParticleEffect 使用不同的混合方式，例如有些使用 Additive 而有些不使用，请在绘制时分别分组，以便每种混合模式只切换一次。

   这同样适用于包含 `Sprite` 的 ParticleEffect：如果它们使用的 `Texture` 不同，应先绘制使用同一 Texture 的所有实例，再绘制其余实例。如果交错绘制使用不同 Texture 的 ParticleEffect，就会产生大量绘制调用。批处理实现方式请参阅[下面的示例](#batched-effect-example)。

* 自行清理混合模式
   使用 Additive Blending 的粒子会改变 `Batch` 的状态。默认情况下，ParticleEffect 会将 Batch 恢复到原始状态，因此后续绘制不会受其混合模式影响。这在绘制单个效果时很好，但如果要绘制多个 ParticleEffect 实例，每个实例绘制后都会切换混合模式，导致额外的绘制调用。

  ```java
  //original blendstate
  additiveParticleEffect.draw(batch, delta); //set the blend state to additive, (flushes the batch)
  //additiveParticleEffect will then reset the batch to the original blend state (flushes the batch)
  //repeat
  //original blendstate
  additiveParticleEffect.draw(batch, delta); //set the blend state to additive, (flushes the batch)
  //additiveParticleEffect will then reset the batch to the original blend state (flushes the batch)
  //repeat
  ```

   为避免这种情况，可以使用 ParticleEffect 的 `setEmittersCleanUpBlendFunction` 方法并将其设为 false。这样 ParticleEffect 不会将混合模式恢复为原始状态，也就避免了 Batch 的额外刷新。

  ```java
  //original blendstate
  additiveParticleEffect.draw(batch, delta); //set the blend state to additive, (flushes the batch)
  //blendstate is now additive
  //repeat
  //additive blendstate
  additiveParticleEffect.draw(batch, delta); //already additive, no state change (no flush)
  //repeat
  ```

   这样就能高效绘制大量具有相同混合状态的 ParticleEffect！使用此方法时要小心：现在需要自行将 Batch 的混合状态恢复为原始状态，因此绘制完所有粒子后必须执行恢复操作。

# 示例

LibGDX 社区制作的粒子效果合集请参阅 [Particle Park](https://github.com/raeleus/Particle-Park)<br/>
代码示例见 [https://libgdxinfo.wordpress.com](https://libgdxinfo.wordpress.com/particleeffect/)

## 对象池效果示例：
```java
ParticleEffectPool bombEffectPool;
Array<PooledEffect> effects = new Array();

//...

//Set up the particle effect that will act as the pool's template
ParticleEffect bombEffect = new ParticleEffect();
bombEffect.load(Gdx.files.internal("particles/bomb.p"), atlas);

//If your particle effect includes additive or pre-multiplied particle emitters
//you can turn off blend function clean-up to save a lot of draw calls, but
//remember to switch the Batch back to GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
//before drawing "regular" sprites or your Stage.
bombEffect.setEmittersCleanUpBlendFunction(false);

bombEffectPool = new ParticleEffectPool(bombEffect, 1, 2);

// Create effect:
PooledEffect effect = bombEffectPool.obtain();
effect.setPosition(x, y);
effects.add(effect);


// Update and draw effects:
for (int i = effects.size - 1; i >= 0; i--) {
	PooledEffect effect = effects.get(i);
	effect.draw(batch, delta);
	if (effect.isComplete()) {
		effect.free();
		effects.removeIndex(i);
	}
}

//...

// Reset all effects:
for (int i = effects.size - 1; i >= 0; i--)
    effects.get(i).free(); //free all the effects back to the pool
effects.clear(); //clear the current effects array
```

## 批处理效果示例：
```java
Array<PooledEffect> additiveEffects;
Array<PooledEffect> normalEffects;

ParticleEffect additiveEffect = new ParticleEffect();
additiveEffect.load(//...);
additiveEffect.setEmittersCleanUpBlendFunction(false); //Stop the additive effect restting the blend state

batch.begin();
//draw all additive blended effects
for (PooledEffect additiveEffect : additiveEffects) {
  additiveEffect.draw(batch, delta);
}

//We need to reset the batch to the original blend state as we have setEmittersCleanUpBlendFunction as false in additiveEffect
batch.setBlendFunction(GL20.GL_SRC_ALPHA, GL20.GL_ONE_MINUS_SRC_ALPHA);
//draw all 'normal alpha' blended effects
for (PooledEffect normalEffect : normalEffects) {
  normalEffect.draw(batch, delta);
}

batch.end();
```

## 视频示例


  * [LibGDX.info 上的粒子效果示例](https://libgdxinfo.wordpress.com/particleeffect/)
  * 该视频的[源代码](https://hg.sr.ht/~dermetfan/somelibgdxtests/browse/core/src/net/dermetfan/someLibgdxTests/screens/ParticleEffectsTutorial.java)
  * 该视频使用[对象池](https://www.youtube.com/watch?v=3OwIiELYa70)的[源代码](https://hg.sr.ht/~dermetfan/somelibgdxtests/browse/core/src/net/dermetfan/someLibgdxTests/screens/PoolingTutorial.java)

<a href="https://www.youtube.com/watch?feature=player_embedded&v=LCLa-rgR_MA
" target="_blank"><img src="http://img.youtube.com/vi/LCLa-rgR_MA/0.jpg"
alt="libgdx 2D Particle Effects" width="480" height="360" border="10" /></a>
