---
title: SpriteBatch、TextureRegion 与 Sprite
---
本页简要介绍如何使用 OpenGL 绘制图像，以及 libGDX 如何通过 `SpriteBatch` 类简化并优化这一任务。

## 绘制图像

从原始格式（例如 PNG）解码并上传到 GPU 的图像称为纹理。要绘制纹理，需要描述几何体，并指定几何体中每个顶点在纹理上的对应位置来应用纹理。例如，几何体可以是一个矩形，并将纹理映射为矩形的每个角对应纹理的一个角。纹理中的矩形子区域称为纹理区域。

实际绘制时，首先绑定纹理（即将其设为当前纹理），然后将几何体交给 OpenGL 绘制。纹理在屏幕上的尺寸和位置由几何体以及 [OpenGL 视口](https://web.archive.org/web/20200427232345/https://www.badlogicgames.com/wordpress/?p=1550)的配置共同决定。许多 2D 游戏会将视口配置为匹配屏幕分辨率，因此几何体以像素指定，可以方便地以合适的尺寸和位置绘制纹理。

将纹理映射到矩形几何体上进行绘制非常常见，也经常需要多次绘制同一纹理或其不同区域。逐个将矩形发送到 GPU 绘制效率很低；可以描述同一纹理的多个矩形并一次性发送给 GPU，这正是 `SpriteBatch` 类所做的事情。

向 `SpriteBatch` 提供要绘制的每个矩形的纹理和坐标后，它会收集几何体，但不会立即提交到 GPU。如果提供的纹理与上一个纹理不同，它会绑定上一个纹理，提交已收集的几何体进行绘制，然后开始为新纹理收集几何体。

每绘制几个矩形就切换纹理，会阻碍 `SpriteBatch` 批处理大量几何体。此外，绑定纹理也有一定开销。因此，通常会将许多小图像存储到一张大图中，再绘制大图的各个区域，以最大化几何体批处理并避免纹理切换。更多信息请参阅 [TexturePacker](/wiki/tools/texture-packer)。

## SpriteBatch

在应用中使用 [`SpriteBatch`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/SpriteBatch.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g2d/SpriteBatch.java)）如下：

```java
public class Game implements ApplicationAdapter {
	private SpriteBatch batch;

	public void create () {
		batch = new SpriteBatch();
	}

	public void render () {
		ScreenUtils.clear(Color.DARK_GRAY);
		batch.begin();
		// Drawing goes here!
		batch.end();
	}
}
```

所有 `SpriteBatch` 绘制调用都必须位于 `begin` 和 `end` 方法之间。`begin` 和 `end` 之间不能进行非 `SpriteBatch` 绘制。

`SpriteBatch` 假设当前活动纹理单元为 0。使用自定义着色器并自行绑定纹理时，可以使用以下代码重置：

```java
Gdx.gl.glActiveTexture(GL20.GL_TEXTURE0);
```

## Texture

`Texture` 类解码图像文件并将其加载到 GPU 内存。图像文件应放在 "assets" 文件夹中。出于兼容性和性能考虑，图像尺寸应为 2 的幂（16x16、64x256 等）。

```java
private Texture texture;
...
texture = new Texture(Gdx.files.internal("image.png"));
...
batch.begin();
batch.draw(texture, 10, 10);
batch.end();
```

这里创建纹理并将其传给 `SpriteBatch` 绘制。纹理会绘制在位置为 10,10 的矩形中，矩形宽高等于纹理尺寸。`SpriteBatch` 提供了许多绘制纹理的方法：

<table>
	<thead>
	<tr>
		<th style="width: 50%">方法签名</th>
		<th style="width: 50%">描述</th>
	</tr>
	</thead>
	<tbody>
	<tr>
		<td><code>draw (Texture texture, float x, float y)</code></td>
		<td>使用纹理自身的宽度和高度绘制纹理。</td>
	</tr>
	<tr>
		<td><code>draw (Texture texture, float x, float y, int srcX, int srcY, int srcWidth, int srcHeight)</code></td>
		<td>绘制纹理的一部分。</td>
	</tr>
	<tr>
		<td><code>draw (Texture texture, float x, float y, float width, float height, int srcX, int srcY, int srcWidth, int srcHeight, boolean flipX, boolean flipY)</code></td>
		<td>绘制纹理的一部分，将其拉伸到 <var>width</var> 和 <var>height</var>，并可选择翻转。</td>
	</tr>
	<tr>
		<td><code>draw (Texture texture, float x, float y, float originX, float originY, float width, float height, float scaleX, float scaleY, float rotation, int srcX, int srcY, int srcWidth, int srcHeight, boolean flipX, boolean flipY)</code></td>
		<td>这个复杂的方法绘制纹理的一部分，将其拉伸到 <var>width</var> 和 <var>height</var>，围绕原点缩放和旋转，并可选择翻转。</td>
	</tr>
	<tr>
		<td><code>draw (Texture texture, float x, float y, float width, float height, float u, float v, float u2, float v2)</code></td>
		<td>绘制纹理的一部分，并将其拉伸到 <var>width</var> 和 <var>height</var>。这是较高级的方法，因为它使用 0-1 的纹理坐标，而不是像素坐标。</td>
	</tr>
	<tr>
		<td><code>draw (Texture texture, float[] spriteVertices, int offset, int length)</code></td>
		<td>这是传入原始几何体、纹理坐标和颜色信息的高级方法。它可以绘制任意四边形，而不仅是矩形。</td>
	</tr>
	</tbody>
</table>

## TextureRegion

[`TextureRegion` 类](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/TextureRegion.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g2d/TextureRegion.java)）描述纹理内部的一个矩形，适合只绘制纹理的一部分。

```java
private TextureRegion region;
...
Texture texture = new Texture(Gdx.files.internal("image.png"));
region = new TextureRegion(texture, 20, 20, 50, 50);
...
batch.begin();
batch.draw(region, 10, 10);
batch.end();
```

这里的 `20, 20, 50, 50` 描述纹理的一部分，该部分随后绘制在 10,10 处。也可以向 `SpriteBatch` 传入 `Texture` 和其他参数实现相同效果，但 `TextureRegion` 将两者封装在一个对象中，使用更加方便。

`SpriteBatch` 提供了许多绘制纹理区域的方法：

<table>
	<thead>
	<tr>
		<th style="width: 50%">方法签名</th>
		<th style="width: 50%">描述</th>
	</tr>
	</thead>
	<tbody>
	<tr>
		<td><code>draw (TextureRegion region, float x, float y)</code></td>
		<td>使用纹理区域自身的宽度和高度绘制区域。</td>
	</tr>
	<tr>
		<td><code>draw (TextureRegion region, float x, float y, float width, float height)</code></td>
		<td>绘制纹理区域，并将其拉伸到 <var>width</var> 和 <var>height</var>。</td>
	</tr>
	<tr>
		<td><code>draw (TextureRegion region, float x, float y, float originX, float originY, float width, float height, float scaleX, float scaleY, float rotation)</code></td>
		<td>绘制纹理区域，将其拉伸到 <var>width</var> 和 <var>height</var>，并围绕原点缩放和旋转。</td>
	</tr>
	</tbody>
</table>

## Sprite

[`Sprite` 类](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/Sprite.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g2d/Sprite.java)）同时描述纹理区域、绘制位置的几何体以及绘制颜色。

```java
private Sprite sprite;
...
Texture texture = new Texture(Gdx.files.internal("image.png"));
sprite = new Sprite(texture, 20, 20, 50, 50);
sprite.setPosition(10, 10);
sprite.setRotation(45);
...
batch.begin();
sprite.draw(batch);
batch.end();
```

这里的 `20, 20, 50, 50` 描述纹理的一部分，该部分旋转 45 度后绘制在 10,10 处。也可以向 `SpriteBatch` 传入 `Texture` 或 `TextureRegion` 及其他参数实现相同效果，但 `Sprite` 将所有信息封装在一个对象中，更加方便。此外，由于 `Sprite` 会存储几何体，只在必要时重新计算，因此当帧间缩放、旋转或其他属性不变时，效率会略高。

注意，`Sprite` 将模型信息（位置、旋转等）与视图信息（要绘制的纹理）混合在一起。因此，如果采用要求严格分离模型和视图的设计模式，`Sprite` 就不合适，此时使用 `Texture` 或 `TextureRegion` 可能更合理。

还要注意，没有与位置相关的 `Sprite` 构造函数。调用 `Sprite(Texture, int, int, int, int)` **不会**修改位置。必须调用 `Sprite#setPosition(float, float)`，否则精灵会绘制在默认位置 0,0。

## Tinting

绘制纹理时，可以为其添加颜色着色：

```java
private Texture texture;
private TextureRegion region;
private Sprite sprite;
...
texture = new Texture(Gdx.files.internal("image.png"));
region = new TextureRegion(texture, 20, 20, 50, 50);
sprite = new Sprite(texture, 20, 20, 50, 50);
sprite.setPosition(100, 10);
sprite.setColor(0, 0, 1, 1);
...
batch.begin();
batch.setColor(1, 0, 0, 1);
batch.draw(texture, 10, 10);
batch.setColor(0, 1, 0, 1);
batch.draw(region, 50, 10);
sprite.draw(batch);
batch.end();
```

此示例展示了如何使用着色颜色绘制纹理、纹理区域和精灵。这里的颜色值使用 0 到 1 之间的 RGBA 值表示。禁用混合时会忽略 Alpha。

## Blending

默认启用混合。这意味着绘制纹理时，纹理的半透明部分会与屏幕该位置已有的像素合并。

禁用混合时，屏幕该位置已有的内容会被纹理替换。这样效率更高，因此除非确有需要，否则应始终禁用混合。例如，绘制覆盖整个屏幕的大型背景图像时，可以先禁用混合以提升性能：

```java
ScreenUtils.clear(Color.DARK_GRAY);
batch.begin();
batch.disableBlending();
backgroundSprite.draw(batch);
batch.enableBlending();
// Other drawing here.
batch.end();
```

_注意：务必每帧清屏。如果不清屏，带 alpha 的纹理可能在自身上重复绘制数百次，从而看起来变得不透明。此外，即使整个屏幕都会被不透明图像覆盖，一些 GPU 架构在每帧清屏时性能也更好。_

## Viewport

`SpriteBatch` 管理自己的投影矩阵和变换矩阵。创建 `SpriteBatch` 时，它使用当前应用程序尺寸，以 y 轴向上的坐标系建立正交投影。调用 `begin` 时，它会设置 [viewport](/wiki/graphics/viewports)。

## 性能调优

`SpriteBatch` 有一个构造函数，用于设置提交到 GPU 前可以缓冲的最大精灵数量。数值过低会导致额外的 GPU 调用，过高则会让 `SpriteBatch` 使用不必要的更多内存。默认值为 1000，最大值为 8191。

`SpriteBatch` 有一个名为 `maxSpritesInBatch` 的 public int 字段，表示该 `SpriteBatch` 生命周期内一次发送到 GPU 的最大精灵数量。将 `SpriteBatch` 尺寸设得很大，再检查此字段，可以帮助确定最佳 `SpriteBatch` 尺寸。尺寸应设为等于或略大于 `maxSpritesInBatch`。此字段可以随时设为 0 以重置。

`SpriteBatch` 有一个名为 `renderCalls` 的 public int 字段。调用 `end` 后，该字段表示最近一次 `begin` 和 `end` 之间，一批几何体发送到 GPU 的次数。当必须绑定不同纹理，或 `SpriteBatch` 缓存的精灵数量达到容量时，就会发生发送。如果 `SpriteBatch` 尺寸合适但 `renderCalls` 仍然很大（可能超过 15-20），说明发生了许多纹理绑定。

`SpriteBatch` 还有一个接收尺寸和缓冲区数量的构造函数。这是一个高级功能，会使用顶点缓冲对象（VBO），而不是通常的顶点数组（VA）。它维护一个缓冲区列表，每次渲染调用使用列表中的下一个缓冲区（循环使用）。当 `maxSpritesInBatch` 较低而 `renderCalls` 较大时，这可能带来小幅性能提升。

有关此主题的更多信息，请参阅[性能分析](/wiki/graphics/profiling)。
