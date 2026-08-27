---
title: 捕获返回键和菜单键
---
用户按下 Android 设备上的返回键时，通常会结束当前运行的 activity。游戏可能希望在允许用户退出前显示确认对话框。要实现这一点，需要捕获返回键，使其不会传递给操作系统：

```java
Gdx.input.setCatchKey(Input.Keys.BACK, true);
```

即使注册了 [InputProcessor](/wiki/input/event-handling)，仍然会收到按键事件，但操作系统不会关闭应用程序。

```   
@Override
public boolean keyDown(int keycode) {
    if(keycode == Keys.BACK){
       // Respond to the back button click here
       return true;
    }
    return false;
}
```

请注意，Android 的通用范式是使用返回键关闭当前 activity。偏离这一范式通常被视为不良实践。

另一个可能需要捕获的按键是菜单键。如果不捕获，长按后会弹出屏幕键盘。可以按如下方式捕获该键：

```java
Gdx.input.setCatchKey(Input.Keys.MENU, true);
```

可能还有其他需要捕获的按键。应该捕获所有用于控制游戏的按键，告知操作系统不要触发应用外部的行为。这可能影响 Android TV 上的媒体控制键，以及面向 HTML5 时的一些通用按键（更多信息请参阅 [HTML 5 特性文章](/wiki/html5-backend-and-gwt-specifics#preventing-keys-from-triggering-scrolling-and-other-browser-functions)）。
