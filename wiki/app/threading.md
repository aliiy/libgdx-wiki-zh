---
title: 多线程
---
所有 `ApplicationListener` 方法都在同一个线程上调用。该线程是渲染线程，可以在其上执行 OpenGL 调用。对大多数游戏而言，只需在 `ApplicationListener.render()` 方法和渲染线程中同时实现逻辑更新与渲染即可。

任何直接涉及 OpenGL 的图形操作都必须在渲染线程上执行。在其他线程执行会导致未定义行为，因为 OpenGL 上下文只在渲染线程上处于活动状态。在另一线程上激活该上下文会在许多 Android 设备上产生问题，因此不受支持。

要从其他线程向渲染线程传递数据，建议使用 [`Application.postRunnable()`](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/Application.java#L188)。它会在下一帧、调用 `ApplicationListener.render()` 之前，在渲染线程上运行 Runnable 中的代码。

```java
new Thread(new Runnable() {
   @Override
   public void run() {
       // do something important here, asynchronously to the rendering thread
      final Result result = createResult();
       // post a Runnable to the rendering thread that processes the result
      Gdx.app.postRunnable(new Runnable() {
         @Override
         public void run() {
             // process the result, e.g. add it to an Array<Result> field of the ApplicationListener.
            results.add(result);
         }
      });
   }
}).start();
```

## 哪些 libGDX 类是线程安全的？
除非类文档中**明确标记**为线程安全，否则 libGDX 中没有任何类是线程安全的！

尤其不要对任何图形或音频相关对象执行多线程操作，例如从多个线程使用 scene2D 组件。

## HTML5
JavaScript 天生是单线程的。因此，[HTML 5 后端的限制](/wiki/html5-backend-and-gwt-specifics#differences-between-gwt-and-desktop-java)之一是无法使用多线程。[Web Workers](https://html.spec.whatwg.org/multipage/workers.html) 将来或许可以作为一种选择，不过线程之间需要通过消息传递数据。Java 使用不同的线程原语和机制，将多线程代码移植到 Web Workers 并不简单。
