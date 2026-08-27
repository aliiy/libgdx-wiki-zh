---
title: 轮询
---
轮询是指检查输入设备的当前状态，例如某个按键是否按下、第一根手指在屏幕上的位置等。这是处理用户输入的快捷方式，足以应对大多数街机游戏。

*注意：* 如果依赖轮询，可能会错过事件，例如快速发生的按键按下/抬起。如果需要确保特定输入动作序列已完成，请改用[事件处理](/wiki/input/event-handling)。

## 轮询键盘

轮询键盘输入只需一行简单代码，如下所示。

```java
boolean isAPressed = Gdx.input.isKeyPressed(Keys.A);
```

传给该方法的参数是键码。无需记忆这些编码，`Input` 接口中提供了一个包含可用编码的静态类。编码详见[此处](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Input.Keys.html)。

## 轮询触摸屏/鼠标

有许多用于轮询触摸屏/鼠标的方法。要检查当前是否有一根或多根手指在屏幕上（等同于鼠标按钮被按下），可以这样做：

```java
boolean isTouched = Gdx.input.isTouched();
```

对于多点触控输入，可能需要知道特定手指（指针）是否在屏幕上：

```java
// 返回屏幕当前是否被触摸
boolean firstFingerTouching = Gdx.input.isTouched(0);
boolean secondFingerTouching = Gdx.input.isTouched(1);
boolean thirdFingerTouching = Gdx.input.isTouched(2);
```

每根按下屏幕的手指都会获得一个指针索引。第一根手指的索引为 0，下一根为 1，依此类推。如果某根手指抬起后再次按下，而其他手指仍在屏幕上，它会获得第一个空闲索引。示例：


1. 第一根手指按下 -> 0
2. 第二根手指按下 -> 1
3. 第三根手指按下 -> 2
4. 第二根手指抬起 -> 1 变为空闲
5. 第一根手指抬起 -> 0 变为空闲，此时只有 2 正在使用
6. 另一根手指按下 -> 0，因为这是第一个空闲索引


在桌面端或浏览器中，严格来说始终只有一根“手指”。


如果要检查用户是否刚刚按下并释放了任意手指，可以使用以下方法：

```java
// 返回屏幕是否刚刚被触摸
boolean justTouched = Gdx.input.justTouched();
```

这适用于需要快速检查触摸按下/抬起序列的场景，例如显示“触摸屏幕继续”的屏幕。请注意，这不是可靠方法，因为它基于轮询。

要获取特定手指的坐标，可以使用以下方法：

```java
int firstX = Gdx.input.getX();
int firstY = Gdx.input.getY();
int secondX = Gdx.input.getX(1);
int secondY = Gdx.input.getY(1);
```

这里获取的是指针索引 0（0 为默认值）和指针索引 1 处的触摸坐标。坐标以相对于屏幕的坐标系报告。原点（0, 0）位于屏幕左上角，x 轴指向右方，y 轴指向*下方*。


### 压力

可以使用以下方法获取施加在指针上的压力：

`Gdx.input.getPressure()`

该方法返回 0 到 1 之间的值。

## 鼠标按钮
在桌面端还可以检查当前按下了哪些鼠标按钮：

```java
boolean leftPressed = Gdx.input.isButtonPressed(Input.Buttons.LEFT);
boolean rightPressed = Gdx.input.isButtonPressed(Input.Buttons.RIGHT);
```

更多常量请参阅 [Buttons](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Input.Buttons.html) 类。

请注意，在 Android 上我们只模拟鼠标左键。所有触摸事件都会被解释为鼠标左键按下。触摸屏显然没有左键、右键和中键的概念。
