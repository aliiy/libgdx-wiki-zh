---
title: 使用 ScissorStack 进行裁剪
---
# 裁剪

```java
Rectangle scissors = new Rectangle();
Rectangle clipBounds = new Rectangle(x,y,w,h);
ScissorStack.calculateScissors(camera, spriteBatch.getTransformMatrix(), clipBounds, scissors);
if (ScissorStack.pushScissors(scissors)) {
    spriteBatch.draw(...);
    spriteBatch.flush();
    ScissorStack.popScissors();
}
```

这会将渲染限制在矩形 `clipBounds` 的范围内。实际绘制被放在 if 语句中，是因为在某些无法将 scissor 压入栈的情况下程序会崩溃（例如桌面窗口最小化时）；此时不绘制是可以接受的。
在开始激活 scissor 区域前（也就是调用 `ScissorStack.pushScissors` 前），可能还需要 flush 或结束 `spriteBatch`，以防 scissor 开始前已排队的绘制调用被刷新到激活的 scissor 区域内。

也可以压入多个矩形。只有位于<b>所有</b>矩形内部的精灵像素才会被渲染。
