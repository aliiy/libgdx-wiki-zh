---
title: 输入处理
---
不同平台提供的输入设备各不相同。在桌面端，用户可以通过键盘和鼠标与应用程序交互，基于浏览器的游戏也是如此。在 Android 上，鼠标由（电容式）触摸屏取代，硬件键盘通常也不存在。所有（兼容的）Android 设备都配有加速度计，有时还配有指南针（磁场传感器）。

libGDX 抽象了所有这些不同的输入设备。鼠标和触摸屏会被视为同一种设备：鼠标不支持多点触控（只会报告一个“手指”），而触摸屏不支持鼠标按键（只会报告“左键”按下）。

根据输入设备的不同，可以定期[轮询](https://en.wikipedia.org/wiki/Polling_(computer_science))设备状态，也可以[注册监听器](/wiki/input/event-handling)，按时间顺序接收输入事件。前者足以应对许多街机游戏（例如模拟摇杆控制）；如果涉及按钮等 UI 元素，则必须使用后者，因为这些元素依赖触摸按下/抬起等事件序列。

所有输入功能都通过 [Input](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/Input.java) 模块访问。

```java
   // Check if the A key is pressed
   boolean isPressed = Gdx.input.isKeyPressed(Keys.A);
```
