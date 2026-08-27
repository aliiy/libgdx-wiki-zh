---
title: 清除屏幕
---
渲染新屏幕时，应先清除旧屏幕，也就是清除颜色缓冲区等当前保存的数据。下面的示例会同时清除颜色缓冲区和深度缓冲区，并将颜色缓冲区设置为纯红色（r：`1`、g：`0`、b：`0`、a：`1`）。之后就可以在红色背景上开始渲染内容：

```java
@Override
public void render() {
  ScreenUtils.clear(1, 0, 0, 1, true);

  // Rendering stuff...
}
```

只需将所需的清除颜色传给 `ScreenUtils#clear`，并将 `clearDepth` 设为 `true`，即可同时清除深度缓冲区。然后就可以渲染带有新场景图形的帧。此方法内部会调用 `Gdx.gl.glClearColor( 1, 0, 0, 1 )` 和 `Gdx.gl.glClear( GL20.GL_COLOR_BUFFER_BIT | GL20.GL_DEPTH_BUFFER_BIT )`。如果需要更细粒度的清除控制，例如还要清除模板缓冲区（`GL20.GL_STENCIL_BUFFER_BIT`），可以直接使用这些底层调用。
