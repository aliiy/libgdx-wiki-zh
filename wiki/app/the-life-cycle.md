---
title: 生命周期
---
libGDX 应用程序具有定义明确的生命周期，用于管理创建、暂停与恢复、渲染以及销毁等状态。

## ApplicationListener
应用开发者通过实现 [ApplicationListener](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/ApplicationListener.html) 接口，并将该实现的实例传递给特定后端的 `Application` 实现，来接入这些生命周期事件（见[应用程序框架](/wiki/app/the-application-framework)）。之后，每当发生应用程序级事件时，`Application` 都会调用 `ApplicationListener`。一个最简的 `ApplicationListener` 实现如下：

```java
public class MyGame implements ApplicationListener {
   public void create () {
   }

   public void render () {        
   }

   public void resize (int width, int height) {
   }

   public void pause () {
   }

   public void resume () {
   }

   public void dispose () {
   }
}
```

也可以继承 [ApplicationAdapter](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/ApplicationAdapter.html) 类，它为这些方法提供空的默认实现。

传递给 `Application` 后，`ApplicationListener` 的方法将按如下方式调用：

| 方法签名 | 描述 |
| ---------------- | ----------- |
| `create ()` | 应用程序创建时调用一次。|
| `resize (int width, int height)` | 每当游戏屏幕调整大小且游戏未处于暂停状态时调用。它还会在 `create()` 方法之后立即调用一次。<br/>参数是调整后屏幕的新宽度和高度，单位为像素。|
| `render ()` | 每次需要执行渲染时由应用程序的游戏循环调用。游戏逻辑更新通常也在此方法中执行。|
| `pause ()` | 在 Android 上，按下 Home 键或收到来电时调用。在桌面端，窗口最小化时调用，并在退出应用程序前、`dispose()` 之前调用。<br/>这是保存游戏状态的好时机。|
| `resume ()` | 在 Android 上应用程序从暂停状态恢复时调用；在桌面端窗口取消最小化时调用。|
| `dispose ()` | 应用程序销毁时调用。调用前会先调用 `pause()`。|

下图以可视化方式展示了生命周期：

![images/70efff32-dd28-11e3-9fc4-1eb57143aee6.png](/assets/wiki/images/70efff32-dd28-11e3-9fc4-1eb57143aee6.png)

## 主循环在哪里？
libGDX 本质上是事件驱动的，这主要源于 Android 和 JavaScript 的工作方式。虽然不存在显式的主循环，但可以将 `ApplicationListener.render()` 方法视为这种主循环的主体。

## 另请参阅
如果目标平台是 Android，请参阅 [libGDX and Android lifecycle](https://bitiotic.com/blog/2013/05/23/libgdx-and-android-application-lifecycle/)。文章还解释了不应使用静态变量的原因。
