---
title: 连续与非连续渲染
---
默认情况下，libGDX 的渲染线程会持续调用 ApplicationListener 类的 `render()` 方法，调用频率取决于硬件（每秒 30、50 或 80 次）。

如果游戏中有许多静止画面（例如卡牌游戏），可以禁用连续渲染，只在确实需要时调用它，从而节省宝贵的电量。

只需将下面几行放入 ApplicationListener 的 create() 方法中：

```java
Gdx.graphics.setContinuousRendering(false);
Gdx.graphics.requestRendering();
```

第一行让游戏停止自动调用 render() 方法，第二行触发一次 render() 方法。每当需要调用 render() 方法时，都必须使用第二行。

如果将连续渲染设为 false，只有发生以下情况时才会调用 render() 方法：

  * 触发输入事件
  * 调用 Gdx.graphics.requestRendering()
  * 调用 Gdx.app.postRunnable()

**UI Actions**：许多 Action（例如对话框默认的淡入和淡出）都有持续时间，需要在此期间进行渲染，因此会代你调用 `Gdx.graphics.requestRendering()`。此功能默认启用。如需禁用，可以调用：

```java
Stage.setActionsRequestRendering(false);
```
----

关于此主题的好文章：[https://bitiotic.com/blog/2012/10/01/enabling-non-continuous-rendering-in-libgdx/](https://bitiotic.com/blog/2012/10/01/enabling-non-continuous-rendering-in-libgdx/)

libGDX 官方博客文章：[https://web.archive.org/web/20201028180041/https://www.badlogicgames.com/wordpress/?p=2289](https://web.archive.org/web/20201028180041/https://www.badlogicgames.com/wordpress/?p=2289)
