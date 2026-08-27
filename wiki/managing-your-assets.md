---
title: 管理资源
---
### 为什么要使用 AssetManager

[AssetManager](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/AssetManager.html) [(code)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/AssetManager.java) 可以帮助你加载和管理资源。由于具备以下优点，推荐使用它加载资源：

  * 大多数资源会异步加载，因此可以在加载过程中显示响应式加载画面
  * 资源使用引用计数。如果资源 A 和 B 都依赖资源 C，那么只有在 A 和 B 都被释放后，C 才会被释放。这也意味着多次加载同一资源时，资源实际上会被共享，只占用一份内存！
  * 在一个地方统一存放所有资源。
  * 可以透明地实现缓存等功能（见下文的 FileHandleResolver）

还在继续阅读吗？那就接着往下看。

### 创建 AssetManager

这部分很简单：

```java
AssetManager manager = new AssetManager();
```

这会创建一个标准的 AssetManager，并包含当前 libGDX 提供的所有加载器。下面看看加载机制如何工作。

**注意：**除非能够妥善管理，否则不要将 `AssetManager` 或其他资源（例如 `Texture`）声明为 `static`。例如，下面的代码会导致问题：

```java
public static AssetManager assets = new AssetManager();
```

这会在 Android 上造成问题，因为静态变量的生命周期不一定与应用生命周期相同。因此，前一个应用实例的 `AssetManager` 可能被下一个实例使用，但其中的资源已经失效，通常会导致纹理变黑、缺失或资源错误。

在 Android 上，甚至可能同时存在多个 Activity 实例，因此即使正确处理了生命周期方法，也不要以为这样就安全了！（详情请参阅[这个 StackOverflow 问题](https://stackoverflow.com/questions/4341600/how-to-prevent-multiple-instances-of-an-activity-when-it-is-launched-with-differ)。）

### 将资源加入队列

要加载资源，AssetManager 需要知道如何加载特定类型的资源。这通过 AssetLoader 实现。AssetLoader 有两种：SynchronousAssetLoader 和 AsynchronousAssetLoader。前者在渲染线程上加载所有内容，后者在其他线程上加载资源的一部分（例如 Texture 所需的 Pixmap），然后在渲染线程上加载依赖 OpenGL 的部分。使用上面创建的 AssetManager，可以直接加载以下资源。


  * Pixmaps，通过 [PixmapLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/PixmapLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/PixmapLoader.java)
  * Textures，通过 [TextureLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/TextureLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/TextureLoader.java)
  * BitmapFonts，通过 [BitmapFontLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/BitmapFontLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/BitmapFontLoader.java)
  * FreeTypeFonts，通过 [FreeTypeFontLoader](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/extensions/FreeTypeFontLoaderTest.java)
  * TextureAtlases，通过 [TextureAtlasLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/TextureAtlasLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/TextureAtlasLoader.java)
  * Music 实例，通过 [MusicLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/MusicLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/MusicLoader.java)
  * Sound 实例，通过 [SoundLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/SoundLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/SoundLoader.java)
  * Skins，通过 [SkinLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/SkinLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/SkinLoader.java)
  * Particle Effects，通过 [ParticleEffectLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/ParticleEffectLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/ParticleEffectLoader.java)
  * I18NBundles，通过 [I18NBundleLoader](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/I18NBundleLoader.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/assets/loaders/I18NBundleLoader.java)
  * FreeTypeFontGenerator，通过 FreeTypeFontGeneratorLoader [(代码)](https://github.com/libgdx/libgdx/blob/master/extensions/gdx-freetype/src/com/badlogic/gdx/graphics/g2d/freetype/FreeTypeFontGeneratorLoader.java)

加载特定资源很简单：

```java
manager.load("mytexture.png", Texture.class);
manager.load("myfont.fnt", BitmapFont.class);
manager.load("mymusic.ogg", Music.class);
```

这些调用会将资源加入加载队列。资源会按照调用 [AssetManager.load()](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/AssetManager.html#load-java.lang.String-java.lang.Class-) 的顺序加载。某些加载器还允许通过 AssetManager.load() 传入参数。假设我们希望为纹理加载指定非默认过滤器和 mipmapping 设置：

```java
TextureParameter param = new TextureParameter();
param.minFilter = TextureFilter.Linear;
param.genMipMaps = true;
manager.load("mytexture.png", Texture.class, param);
```

请查看上面提到的加载器，了解它们的参数。

### 实际加载资源
到目前为止，我们只是将资源加入加载队列，AssetManager 还没有真正加载任何内容。要开始加载，必须持续调用 AssetManager.update()，例如在 ApplicationListener.render() 方法中调用：

```java
public MyAppListener implements ApplicationListener {

   public void render() {
      if(manager.update()) {
         // we are done loading, let's move to another screen!
      }

      // display loading information
      float progress = manager.getProgress()
      ... left to the reader ...
   }
}
```

只要 AssetManager.update() 返回 false，就说明资源仍在加载。可以使用 AssetManager.getProgress() 查询具体进度，它会返回 0 到 1 之间的数字，表示当前已加载资源的百分比。AssetManager 中还有其他提供类似信息的方法，例如 AssetManager.getLoadedAssets() 和 AssetManager.getQueuedAssets()。<b>必须调用 AssetManager.update() 才能继续加载！</b>

如果希望阻塞并确保所有资源都已加载，可以调用：

```java
manager.finishLoading();
```

这会一直阻塞，直到队列中的所有资源完成加载。这在一定程度上违背了异步加载的目的，但有时确实需要这样做（例如加载显示加载画面所需的资源）。

### 优化加载
为了在保持一定 FPS 的同时尽可能高效、快速地加载资源，应为 AssetManager.update() 传入参数。<br>**例如：AssetManager.update(17)** —— 此时 AssetManager 至少阻塞 17 毫秒（只有在所有资源都已加载时才会少于此时间），并尽可能多地加载资源，然后将控制权交还给渲染方法。阻塞 16 或 17 毫秒可以达到约 60FPS，因为 1/60*1000 = 16.66667。请注意，根据当前加载的资源，阻塞时间可能更长，因此**不要**将目标 FPS 视为保证值。

### 使用 AssetHandler 加载 TTF

通过 AssetHandler 加载 TrueType 文件只需进行少量额外配置。在加载 TTF 前，需要设置 FreeType 字体使用的加载器类型，方法如下：

```java
FileHandleResolver resolver = new InternalFileHandleResolver();
manager.setLoader(FreeTypeFontGenerator.class, new FreeTypeFontGeneratorLoader(resolver));
manager.setLoader(BitmapFont.class, ".ttf", new FreetypeFontLoader(resolver));
```

接下来创建 `FreeTypeFontLoaderParameter`，用于定义 1）实际字体文件，2）字体大小。这里还可以定义其他参数，具体可进一步了解。

假设我们要创建两种不同的字体：一种较小的无衬线字体，用于某类正文；另一种较大的衬线字体，用于标题和其他内容。我决定分别使用 Arial 和 Georgia。下面是使用 AssetManager 加载它们的方法：

```java
// First, let's define the params and then load our smaller font
FreeTypeFontLoaderParameter mySmallFont = new FreeTypeFontLoaderParameter();
mySmallFont.fontFileName = "arial.ttf";
mySmallFont.fontParameters.size = 10;
manager.load("arial.ttf", BitmapFont.class, mySmallFont);

// Next, let's define the params and then load our bigger font
FreeTypeFontLoaderParameter myBigFont = new FreeTypeFontLoaderParameter();
myBigFont.fontFileName = "georgia.ttf";
myBigFont.fontParameters.size = 20;
manager.load("georgia.ttf", BitmapFont.class, myBigFont);
```

这样就得到了两种不同的字体 `mySmallFont` 和 `myBigFont`，可以用来显示不同文本。

现在还没有完全结束。字体已经通过 `.load` 加载，但我们还需要获取它们。可以这样做：

```java
BitmapFont mySmallFont = manager.get("arial.ttf", BitmapFont.class);
BitmapFont myBigFont = manager.get("georgia.ttf", BitmapFont.class);
```

传给管理器的名称不必与字体名称一致，就像上面的例子一样。如果想使用同一字体的不同大小，只需确保加载字体时传给资源管理器的名称唯一。例如，下面展示了如何加载 10pt 和 20pt 大小的 Arial 字体：

```java
FreeTypeFontLoaderParameter arial10 = new FreeTypeFontLoaderParameter();

// This is the file that needs to exist in the assets directory.
arial10.fontFileName = "arial.ttf";
arial10.fontParameters.size = 10;

// There is no file named arial10.ttf. This is just an identifier for the asset manager.
// The .ttf extension is important, because it tells the asset manager which loader to use.
manager.load("arial10.ttf", BitmapFont.class, arial10);

// Now just change the font size, but use the same font.
FreeTypeFontLoaderParameter arial20 = new FreeTypeFontLoaderParameter();
arial20.fontFileName = "arial.ttf";
arial20.fontParameters.size = 20;

// And create a new BitmapFont in 20pt.
manager.load("arial20.ttf", BitmapFont.class, arial20);
```

### 获取资源
这同样很简单：

```java
Texture tex = manager.get("mytexture.png", Texture.class);
BitmapFont font = manager.get("myfont.fnt", BitmapFont.class);
```

当然，这假设这些资源已经成功加载。如果要查询某个资源是否已加载，可以这样做：

```java
if(manager.isLoaded("mytexture.png")) {
   // texture is available, let's fetch it and do something interesting
   Texture tex = manager.get("mytexture.png", Texture.class);
}
```

### 释放资源
这同样很简单，下面可以看到 AssetManager 的真正优势：

```java
manager.unload("myfont.fnt");
```

如果该字体引用了之前手动加载的 Texture，纹理不会被销毁！它会使用引用计数：位图字体提供一个引用，纹理自身再提供一个引用。只要计数不为零，纹理就不会被释放。

* 由 AssetManager 管理的资源不应手动释放，应调用 AssetManager.unload()！

如果希望一次释放所有资源，可以调用：

```java
manager.clear();
```

或者

```java
manager.dispose();
```

这两种方法都会释放当前已加载的所有资源，并移除队列中尚未加载的资源。AssetManager.dispose() 方法还会销毁 AssetManager 自身。调用此方法后不应再使用该管理器。

以上就是基本用法。下面介绍更细节的部分。

### 我只提供了字符串，AssetManager 从哪里加载资源？
每个加载器都持有一个 FileHandleResolver 引用。这是一个简单的接口：

```java
public interface FileHandleResolver {
   public FileHandle resolve(String file);
}
```

默认情况下，每个加载器都使用 InternalFileHandleResolver。它会返回指向内部文件的 FileHandle（就像 Gdx.files.internal("mytexture.png") 一样）。你也可以编写自己的解析器！可以查看 assets/loaders/resolvers 包中的其他 FileHandleResolver 实现。一个应用场景是缓存系统：先检查外部存储中是否有已下载的新版本，如果没有，再回退到内部存储。应用方式不受限制。

可以通过 AssetManager 的第二个构造函数设置要使用的 FileHandleResolver：

```java
AssetManager manager = new AssetManager(new ExternalFileHandleResolver());
```

这样可以确保上面列出的所有默认加载器都使用该解析器。

### 编写自己的加载器
我无法预知你还想加载哪些其他类型的资源，因此你可能会需要编写自己的加载器。你可以实现 SynchronousAssetLoader 和 AsynchronousAssetLoader 这两个接口。如果资源类型加载很快，可以使用前者；如果希望加载画面保持响应，则使用后者。建议参考上面列出的某个加载器的代码来编写。MusicLoader 是简单的 SynchronousAssetLoader 示例，PixmapLoader 是简单的 AsynchronousAssetLoader 示例。BitmapFontLoader 则是一个很好的异步加载器示例，它还有一些必须先于实际资源加载的依赖（这里指存储字形的纹理）。总之，你可以用这种方式实现很多功能。

此外，`loadAsync` 函数_可以_用于加载能够交给其他线程处理的资源部分（这是实现响应式加载画面的要求）。如果资源的某些部分必须在主渲染线程上加载，则_必须_使用 `loadSync` 函数。例如，OpenGL API 函数调用必须在主渲染线程上执行，因此资源中任何涉及 OpenGL 调用的部分都必须在 `loadSync` 中处理。

`loadAsync` 会先被调用，之后才会调用 `loadSync`。借助自定义资源加载器类的属性，可以将信息从 `loadASync` 传递给 `loadSync`。**务必在每个独立资源开始加载时将这些临时变量初始化为 null，否则可能会多次加载同一个资源！**最简单的做法是在 `loadASync` 实现的开头将临时变量设为 null。`PixmapLoader` 类展示了正确使用临时变量的简单方式，而 `TextureLoader` 则展示了在 `loadAsync` 和 `loadSync` 之间传递信息的更复杂方式。

完成加载器后，将它告知 AssetManager：

```java
manager.setLoader(MyAssetClass.class, new MyAssetLoader(new InternalFileHandleResolver()));
manager.load("myasset.mas", MyAssetClass.class);
```

### 使用加载画面恢复
在 Android 上，应用可能会暂停和恢复。此时，Texture 等受管理的 OpenGL 资源需要重新加载，这可能需要一些时间。如果希望在恢复时显示加载画面，可以在创建 AssetManager 后执行以下操作。

```java
Texture.setAssetManager(manager);
```

随后，可以在 ApplicationListener.resume() 方法中切换到加载画面，并再次调用 AssetManager.update()，直到一切恢复正常。

如果没有像上一个代码片段那样设置 AssetManager，通常的受管理纹理机制会自动生效，因此无需进行其他处理。

至此，期待已久的 AssetManager 文章就结束了。
