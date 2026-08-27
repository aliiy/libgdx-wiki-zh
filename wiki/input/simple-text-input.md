---
title: 简单文本输入
---
如果应用程序需要用户输入字符串，例如用户名或密码，可以使用具有一定可定制性的简单对话框。

在桌面端会打开 Swing 对话框，提示用户输入字符串。（⚠ LWJGL3 后端中此方法[尚未实现](https://github.com/libgdx/libgdx/blob/master/backends/gdx-backend-lwjgl3/src/com/badlogic/gdx/backends/lwjgl3/DefaultLwjgl3Input.java#L306)。）

在 Android 上会打开标准 Android 对话框，同样提示用户输入内容。

要接收输入或用户取消输入的通知，需要实现 `TextInputListener` 接口：

```java
public class MyTextInputListener implements TextInputListener {
   @Override
   public void input (String text) {
   }

   @Override
   public void canceled () {
   }
}
```

用户输入文本字符串时会调用 `input()` 方法。用户在桌面端关闭对话框或在 Android 上按下返回键时，会调用 `canceled()` 方法。

要显示对话框，只需将监听器传给以下方法：

```java
MyTextInputListener listener = new MyTextInputListener();
Gdx.input.getTextInput(listener, "Dialog Title", "Initial Textfield Value", "Hint Value");
```

监听器的方法会在渲染线程上、调用 `ApplicationListener.render()` 方法之前调用。
