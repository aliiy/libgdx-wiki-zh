---
title: ModelBatch
---
[ModelBatch](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/ModelBatch.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/ModelBatch.java)）用于管理渲染调用。它通常用于渲染[模型](/wiki/graphics/3d/models)的实例，但并不局限于模型。ModelBatch 抽象了全部渲染代码，在其上提供一层封装，让你可以专注于更具体的游戏逻辑。ModelBatch 的每一部分功能都可以按设计进行自定义。

**注意：**由于 ModelBatch 管理渲染调用，也就管理渲染上下文，因此不应在 `ModelBatch.begin()` 和 `ModelBatch.end()` 之间手动修改渲染上下文（例如绑定着色器、纹理或网格，或调用任何以 `gl` 开头的函数）。这样做不会生效，还可能导致不可预测的行为。应改用 ModelBatch 提供的自定义选项。

* [常见误解](#common-misconceptions)
* [概述](#overview)
* [使用 ModelBatch](#using-modelbatch)
* [收集渲染调用](#gather-render-calls)
  * [什么是渲染调用？](#what-are-render-calls)
  * [RenderableProvider](#renderableprovider)
* [收集着色器](#gather-shaders)
  * [什么是着色器？](#what-is-a-shader)
  * [ShaderProvider](#shaderprovider)
  * [默认着色器](#default-shader)
* [排序渲染调用](#sorting-render-calls)
* [管理渲染上下文](#managing-the-render-context)
  * [RenderContext](#rendercontext)
  * [TextureBinder](#texturebinder)
    * [TextureDescriptor](#texturedescriptor)

# 常见误解
* ModelBatch 经常被拿来与 [SpriteBatch](/wiki/graphics/2d/spritebatch-textureregions-and-sprites) 比较。虽然从 API 角度看这可以理解，但二者存在很大差异，因此并不适合直接比较。主要区别是 SpriteBatch 会将多个精灵合并为一次绘制调用，而 ModelBatch 不会合并渲染调用。这会影响性能，因此应在将渲染调用交给 ModelBatch 前先合并它们。
* ModelBatch 不会执行（视锥体）剔除，因为它没有足够信息以最佳性能完成这项工作。默认情况下，每次调用 `ModelBatch.render()` 至少会产生一次实际渲染调用。不过可以自定义 ModelBatch，在实际渲染前执行视锥体剔除。通常应在调用 `ModelBatch.render()` 之前完成剔除。

# 概述
那么 ModelBatch 到底做什么？

1. 收集渲染调用
2. 为每个渲染调用收集着色器
3. 对渲染调用排序
4. 管理渲染上下文
5. 执行渲染调用

仅此而已，不多不少。上述每一部分都可以自定义。请注意，由于这种设计，完成同一基本任务可能有多种方式。

# 使用 ModelBatch
ModelBatch 是相对重量级的对象，因为它可能创建着色器。应尽可能复用它。通常在 `create()` 方法中创建 ModelBatch。由于它包含原生资源（例如使用的着色器），不再需要时必须调用 `dispose()` 方法。

通常应在每一帧渲染，一般是在 `render()` 方法中完成。开始渲染时调用 `modelBatch.begin(camera);`，然后使用 `modelBatch.render(...);` 方法添加一个或多个渲染调用。添加完成后，必须调用 `modelBatch.end();` 才会真正执行这些渲染调用。
```java
    ModelBatch modelBatch;
    ...

    @Override
    public void create () {
        modelBatch = new ModelBatch();
        ...
    }

    @Override
    public void render () {
        ... // call glClear etc.
        modelBatch.begin(camera);
        modelBatch.render(...);
        ... // add other render calls
        modelBatch.end();
        ...
    }

    @Override
    public void dispose () {
        modelBatch.dispose();
        ...
    }
```
只有在 `modelBatch.begin(camera)` 和 `modelBatch.end()` 之间才能调用 `modelBatch.render(...)`。实际渲染在调用 `end();` 时执行。如果希望在中间强制渲染，可以使用 `modelBatch.flush();` 方法。

传入的 [`Camera`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Camera.html) 按引用保存，因此在 begin 和 end 调用之间不能更改它。如果需要在两者之间切换摄像机，可以调用 `modelBatch.setCamera(camera);`，必要时该方法会对批处理执行 `flush()`。

# 收集渲染调用
## 什么是渲染调用？
ModelBatch 的作用是管理渲染调用。那么渲染调用究竟是什么，又该如何指定？

“渲染调用”（也常称为“绘制调用”）本质上是让 GPU 渲染（显示）某个内容的指令。简单来说，每次渲染调用都会显示带有某些属性（例如位置、图像、颜色等）的形状。更准确地说，它会指示 GPU 在给定上下文中使用给定着色器渲染网格的指定部分。后文会进一步介绍。

> 对于基本用法，无需了解渲染调用的确切细节，因为 ModelBatch 已将其抽象出来。不过，渲染调用会影响性能。通常每次渲染调用都在 GPU 上执行，与 CPU 代码并行；每执行一次新的渲染调用，都可能需要同步 GPU 和 CPU。换句话说，少量大型渲染调用通常比大量小型调用性能更好。

为了指定渲染调用，libGDX 提供 [Renderable](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/Renderable.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/Renderable.java)）类，其中包含执行一次渲染调用所需的几乎全部信息（摄像机除外）。它描述了使用什么方式（着色器）、在什么位置（变换）、以什么上下文（环境和材质）渲染形状（网格部件）。

`ModelBatch` 的 `render(...)` 方法有多种签名（方法参数不同的变体），其中一个是 `ModelBatch.render(Renderable);`。使用它可以直接指定要添加到 ModelBatch 的渲染调用。其他 `render(...)` 方法允许通过 `RenderableProvider` 指定一个或多个渲染调用，并通过其他参数为这些调用提供默认值。例如，使用 `ModelBatch#render(RenderableProvider, Environment, Shader)` 时，会设置（覆盖）RenderableProvider 提供的每个 `Renderable` 的 `environment` 和 `shader` 成员。

## RenderableProvider
[`RenderableProvider`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/RenderableProvider.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/RenderableProvider.java)）是一个可实现的接口，用于提供一个或多个 `Renderable` 实例。最常见的实现可能是 [`ModelInstance`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/ModelInstance.html)，它会遍历所有[节点](/wiki/graphics/3d/models#nodes)（[部件](/wiki/graphics/3d/models#nodepart)），并将它们转换为 `Renderable` 实例。不过，也可以按需要使用 `RenderableProvider`。例如，创建体素引擎时，可以为每个区块创建一个 `Renderable`；使用实体组件系统时，则可以将 `RenderableProvider` 作为组件。

`RenderableProvider` 只有一个方法：
```java
public void getRenderables (Array<Renderable> renderables, Pool<Renderable> pool);
```
这是一个非常开放的 API（例如可以访问包含所有已添加 `Renderable` 的 `Array`），但应限制自己只向数组添加元素。对象池可以选择性地用于避免分配。可以忽略对象池，也可以用它获取所需的动态 `Renderable`。从对象池 `obtain()` 的任何 `Renderable` 都会由 ModelBatch 自动释放，无需自行处理。

# 收集着色器
## 什么是着色器？
A [`Shader`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/Shader.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/Shader.java)）是一个接口，用于抽象实际执行渲染调用的实现。它通常使用 [`ShaderProgram`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/glutils/ShaderProgram.html)，这是执行渲染调用所需的 GPU 程序（例如 _vertex shader_ 和 _fragment shader_）。`Shader` 实现还包含使用该 `ShaderProgram` 所需的全部内容，例如设置 _uniform_ 值。

## ShaderProvider
无论实际如何渲染，ModelBatch 都需要为每个 `Renderable` 准备一个 `Shader`。为此，它使用 [`ShaderProvider`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/ShaderProvider.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/ShaderProvider.java)）接口。对于添加到批处理中的每个 `Renderable`（即使它已经包含着色器），都会调用 ShaderProvider 的 `getShader` 来获取用于渲染它的着色器。

```java
public Shader getShader (Renderable renderable);
```

默认使用 [DefaultShaderProvider](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/DefaultShaderProvider.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/DefaultShaderProvider.java)）。当之前创建的着色器无法复用时，它会创建 [DefaultShader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/shaders/DefaultShader.html)。不过，也可以提供自己的 `ShaderProvider` 或扩展 `DefaultShaderProvider` 来自定义行为。

`ModelBatch` 将 `Shader` 的管理委托给 `ShaderProvider`。由于 `Shader` 通常使用 `ShaderProgram`，因此需要释放它们。调用 `modelBatch.dispose();` 时，`ModelBatch` 会调用 `ShaderProvider` 的 `dispose()` 方法。

为了帮助管理和复用着色器，libGDX 提供了抽象类 [`BaseShaderProvider`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/BaseShaderProvider.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/BaseShaderProvider.java)）。该类会跟踪创建的所有着色器，在可能时复用它们，并在不再需要时释放它们。如果扩展此类，当没有可复用的着色器时，它会调用 `createShader(Renderable)` 方法。`Shader` 是否可以复用由 [`shader.canRender(Renderable)`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/Shader.html#canRender-com.badlogic.gdx.graphics.g3d.Renderable-) 的调用结果决定。

一种常见用法是扩展 `DefaultShaderProvider`（它扩展了 BaseShaderProvider），在需要时提供自定义着色器；无法使用自定义着色器时，则回退到 DefaultShader。
```java
public static class MyShaderProvider extends DefaultShaderProvider {
	@Override
	protected Shader createShader (Renderable renderable) {
		if (renderable.material.has(CustomColorTypes.AlbedoColor))
			return new MyShader(renderable);
		else
			return super.createShader(renderable);
	}
}
```
这里使用 [Material](/wiki/graphics/3d/material-and-environment) 来决定是否使用自定义着色器。这是推荐且最简单的方法。不过，也可以使用任意值（包括通用的 [`renderable.userData`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/Renderable.html#userData)）来决定使用哪个着色器，只要其 `shader.canRender(renderable)` 方法对给定的 renderable 返回 true 即可。

## 默认着色器
如果没有指定自定义 `ShaderProvider`，`ModelBatch` 就会使用 `DefaultShaderProvider`。需要时，该提供器会创建新的 [`DefaultShader`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/shaders/DefaultShader.html) 实例。

`DefaultShader` 类为大多数标准的[材质和环境属性](/wiki/graphics/3d/material-and-environment)提供默认实现，包括光照、法线贴图、反射立方体贴图等。也就是说，它会将属性值绑定到对应的 `uniform`。 [这里可以找到 uniform 名称列表](https://github.com/libgdx/libgdx/blob/1.7.0/gdx/src/com/badlogic/gdx/graphics/g3d/shaders/DefaultShader.java#L81-L120)。

> **注意：默认情况下，着色器程序（glsl 文件）使用逐顶点光照（[Gouraud 着色](https://en.wikipedia.org/wiki/Gouraud_shading)）。默认不会应用法线贴图、反射等效果。**

向 `DefaultShaderProvider` 提供 [`DefaultShader.Config`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/shaders/DefaultShader.Config.html) 实例，可以配置此类的行为。

```java
DefaultShader.Config config = new DefaultShader.Config();
config.numDirectionalLights = 1;
config.numPointLights = 0;
config.numBones = 16;
modelBatch = new ModelBatch(new DefaultShaderProvider(config));
```

> **注意：**默认配置很少能针对每种使用场景达到最优。例如，即使只使用 1 个方向光和 1 个点光源，它也会使用 5 个点光源和 2 个方向光。请根据具体场景调整配置，以充分发挥其效果。[如果使用蒙皮，骨骼数量必须与创建模型时使用的骨骼数量一致。](/wiki/graphics/3d/3d-animations-and-skinning)

要使用的 [GPU 着色器](/wiki/graphics/opengl-utils/shaders)（顶点着色器和片段着色器）也可以通过此配置进行设置。由于该着色器可用于各种属性组合，因此通常称为 *ubershader*。它是一段 GLSL 着色器代码，会使用[预处理器宏指令](https://www.opengl.org/wiki/Core_Language_(GLSL)#Preprocessor_directives)，根据 `Renderable` 启用或禁用其中的部分代码。例如：

```glsl
#ifdef blendedFlag
	gl_FragColor.a = diffuse.a * v_opacity;
	#ifdef alphaTestFlag
		if (gl_FragColor.a <= v_alphaTest)
			discard;
	#endif
#else
	gl_FragColor.a = 1.0;
#endif
```

在此代码片段中，着色器实际使用的代码取决于是否定义了 `blendedFlag` 和/或 `alphaTestFlag`。[`DefaultShader` 类会根据 `Renderable` 的值定义这些标志。](https://github.com/libgdx/libgdx/blob/1.7.0/gdx/src/com/badlogic/gdx/graphics/g3d/shaders/DefaultShader.java#L631-L702)

如果没有指定自定义 ubershader，则会使用默认 ubershader（参见[顶点着色器](https://github.com/libgdx/libgdx/blob/1.7.0/gdx/src/com/badlogic/gdx/graphics/g3d/shaders/default.vertex.glsl)和[片段着色器](https://github.com/libgdx/libgdx/blob/1.7.0/gdx/src/com/badlogic/gdx/graphics/g3d/shaders/default.fragment.glsl)的源代码）。虽然该着色器支持大多数基本属性（例如蒙皮、逐顶点漫反射和镜面反射光照等），但它非常通用，无法支持所有可能的属性组合。

> 如果需要逐片段光照、法线贴图和反射，可以使用[这个“非官方”着色器](https://gist.github.com/xoppa/9766698)。但请注意，该着色器是以限制为单个方向光等代价来增加这些功能的。

如果查看默认 ubershader 的源代码，可能会注意到它非常庞大，几乎难以阅读，更不用说维护了。幸运的是，不必支持所有可能的属性组合；如上一段所述，可以扩展 `DefaultShaderProvider`，将其拆分为多个着色器以便维护。例如：

```java
public static class MyShaderProvider extends DefaultShaderProvider {
	DefaultShader.Config albedoConfig;

	public MyShaderProvider(DefaultShader.Config defaultConfig) {
		super(defaultConfig);
		albedoConfig = new DefaultShader.Config();
		albedoConfig.vertexShader = Gdx.files.internal("albedo.vertex.glsl").readString();
		albedoConfig.fragmentShader = Gdx.files.internal("albedo.fragment.glsl").readString();
	}
	@Override
	protected Shader createShader (Renderable renderable) {
		if (renderable.material.has(CustomColorTypes.AlbedoColor))
			return new DefaultShader(renderable, albedoConfig);
		else
			return super.createShader(renderable);
	}
}
```

# 排序渲染调用
如果以随机顺序执行渲染调用，可能会产生奇怪且性能较差的结果。例如，如果透明对象在其后方的对象之前渲染，就看不到后方对象。这是因为深度缓冲会阻止更远处的对象被渲染。对渲染调用排序有助于解决这个问题。

默认情况下，`ModelBatch` 使用 [DefaultRenderableSorter](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/DefaultRenderableSorter.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/DefaultRenderableSorter.java)）对渲染调用排序。该实现会先从前到后渲染不透明对象，再从后到前渲染透明对象。默认实现通过检查 [BlendingAttribute#blended](/wiki/graphics/3d/material-and-environment) 值来判断对象是否透明。

自定义排序有助于提升性能。例如，根据着色器、网格或所用纹理进行排序，可能有助于减少着色器、网格或纹理切换。这类优化高度依赖具体应用。构造 `ModelBatch` 时，可以指定自己的 [`RenderableSorter`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/RenderableSorter.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/RenderableSorter.java)）实现来自定义排序。该接口只有一个方法：
```java
public void sort (Camera camera, Array<Renderable> renderables);
```
该方法会在实际渲染前提供 `ModelBatch` 的全部信息。它也是一个非常开放的 API，允许按需修改数组。因此可以在此接口中执行任何最后时刻的操作（甚至不一定与排序有关，例如视锥体剔除）。该方法完成后，`renderables` 的顺序就是实际执行渲染调用的顺序。

# 管理渲染上下文
`ModelBatch` 可以在多个 `Shader` 实现之间避免冗余的 OpenGL 调用，包括纹理绑定。例如，当一个 `Shader` 要求进行背面剔除，而前一个着色器已经启用背面剔除时，就可以避免冗余调用 `glEnable` 和 `glCullFace`。

## RenderContext
[`RenderContext`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/RenderContext.html) 类会尝试避免这些不必要的调用。该类是 OpenGL ES 之上的薄封装层，会跟踪之前的调用，从而避免发出冗余调用。目前只实现了少量 GL 调用，但可以扩展它以添加其他调用。如果没有在构造函数中指定，`ModelBatch` 会为你创建并管理 `RenderContext`。

**注意：**显然，只有所有 `Shader` 实现都使用 `RenderContext` 而不是直接进行 GL 调用时，这种方式才有效。如果可能，应始终使用 `RenderContext`，而不是直接调用相应的 GL 函数。

例如：使用 RenderContext 启用深度测试时，它会代为启用深度测试。如果此时使用 SpriteBatch，而 SpriteBatch 禁用了深度测试却没有更新 RenderContext，就会导致意外结果。为避免这种情况，默认情况下（未自行指定 RenderContext 时），ModelBatch 会在 `begin()` 和 `end()` 方法中调用 RenderContext 的同名方法，从而_重置_ RenderContext。这可以确保 ModelBatch 外部的上下文切换不会干扰渲染。

不过，如果指定自己的 `RenderContext`（不一定要是自定义实现），就需要负责调用 `context.begin()` 和 `context.end()` 方法。这样可以让多个 ModelBatch 实例使用同一个上下文，甚至完全避免重置上下文。

> 如果在构造时指定 RenderContext，那么该 RenderContext 由你负责，并应在需要时重置（调用其 begin() 和 end() 方法）。可以调用 [modelBatch.ownsRenderContext](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/ModelBatch.html#ownsRenderContext--) 方法检查 RenderContext 是否由 ModelBatch 拥有和管理。

## TextureBinder
为了跟踪当前绑定的纹理，RenderContext 包含一个 [textureBinder](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/RenderContext.html#textureBinder) 成员。[`TextureBinder`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/TextureBinder.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/TextureBinder.java)）是用于跟踪纹理绑定及纹理上下文（例如缩小/放大过滤器）的接口。默认使用 [`DefaultTextureBinder`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/utils/DefaultTextureBinder.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g3d/utils/DefaultTextureBinder.java)）。虽然可以指定自己的实现，但通常不需要这样做。

DefaultTextureBinder 会使用所有可用的纹理单元（在指定范围内），以避免不必要的纹理绑定。典型的现代移动 GPU 提供约 16 或 32 个可绑定纹理的纹理单元。OpenGL ES 将纹理单元数量限制为 32。构造 DefaultTextureBinder 时，可以使用 `offset` 和 `count` 参数指定使用范围。如果未指定 offset，则假定为 0；如果未指定 count，则使用剩余的所有可用单元。默认情况下，ModelBatch 会将纹理单元 0 排除在范围之外，因为它通常用于 GUI。因此默认使用纹理单元 `1` 到 `31`，除非 GPU 支持的纹理单元更少。

`DefaultTextureBinder` supports two methods:
* **ROUNDROBIN：**如果纹理已经绑定，则会复用它。否则，将第一张纹理绑定到第一个可用单元，下一张纹理绑定到下一个可用单元，以此类推。当所有可用单元都已使用后，会从第一个可用单元重新开始绑定，并覆盖之前绑定的纹理。
* **WEIGHTED：**通过统计纹理是否以及被使用的次数来为纹理加权。经常复用的纹理不太可能被覆盖，而较少复用的纹理更可能被覆盖。

ModelBatch 默认使用 _WEIGHTED_ 方法。

可以通过调用 `bind(...)` 方法使用 `TextureBinder` 绑定纹理。该方法会返回纹理所绑定的单元。因此，实际上可以在 `Shader` 中像下面这样将纹理绑定到一个 _uniform_：
```java
program.setUniformi(uniformLocation, context.textureBinder.bind(texture));
```

### TextureDescriptor
指定纹理时，API 经常使用 `TextureDescriptor`。这是因为除了纹理本身，还可能需要指定上下文属性。目前这些属性包括缩小和放大过滤器，以及水平和垂直环绕方式。因此，[TextureAttribute](/wiki/graphics/3d/material-and-environment#textureattribute) 和 [CubemapAttribute](/wiki/graphics/3d/material-and-environment#cubemapattribute) 等也会使用 TextureDescriptor。为方便起见，TextureBinder 允许直接指定 TextureDescriptor：
```java
program.setUniformi(uniformLocation, context.textureBinder.bind(
    (TextureAttribute)(renderable.material.get(TextureAttribute.Diffuse)))
        .textureDescription));
```
