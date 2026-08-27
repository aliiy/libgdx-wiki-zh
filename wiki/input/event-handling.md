---
title: 事件处理
---
事件处理可以获得更细粒度、尤其是按时间顺序排列的用户输入信息。它提供了实现用户界面交互的方式，因为特定输入序列很重要，例如按钮上的触摸按下和抬起表示用户点击了按钮。使用轮询很难实现这类交互。

## 输入处理器
事件处理使用常见的[观察者模式](https://en.wikipedia.org/wiki/Observer_pattern)。首先需要实现名为 InputProcessor 的监听器接口：

```java
public class MyInputProcessor implements InputProcessor {
   public boolean keyDown (int keycode) {
      return false;
   }

   public boolean keyUp (int keycode) {
      return false;
   }

   public boolean keyTyped (char character) {
      return false;
   }

   public boolean touchDown (int x, int y, int pointer, int button) {
      return false;
   }

   public boolean touchUp (int x, int y, int pointer, int button) {
      return false;
   }

   public boolean touchDragged (int x, int y, int pointer) {
      return false;
   }

   public boolean mouseMoved (int x, int y) {
      return false;
   }

   public boolean scrolled (float amountX, float amountY) {
      return false;
   }
}
```

前三个方法用于监听键盘事件：

   * *keyDown()*：按下键时调用。报告按键代码，代码定义在 [Keys](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Input.Keys.html) 中。
   * *keyUp()*：释放键时调用。报告上述按键代码。
   * *keyTyped()*：键盘输入生成 Unicode 字符时调用。可用于实现文本框及类似的用户界面元素。

接下来的五个方法报告鼠标/触摸事件：
  
   * *touchDown()*：手指触摸屏幕或鼠标按键按下时调用。报告坐标、指针索引和鼠标按键（触摸屏始终为 [Buttons.LEFT](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Input.Buttons.html)）。
   * *touchUp()*：手指离开屏幕或鼠标按键释放时调用。报告最后已知的坐标、指针索引和鼠标按键（触摸屏始终为 `Buttons.Left`）。
   * *touchDragged()*：手指在屏幕上拖动，或按住鼠标按键拖动鼠标时调用。报告坐标和指针索引。由于拖动鼠标时可能同时按下多个按键，因此不会报告具体按键。可以使用 `Gdx.input.isButtonPressed()` 检查指定按键。
   * *mouseMoved()*：鼠标移动且没有按下鼠标按键时调用。此事件仅适用于桌面端；触摸屏设备不会触发该事件，只会获得 `touchDragged()` 事件。
   * *scrolled()*：鼠标滚轮滚动时调用。根据滚动方向报告正值、负值或零。触摸屏设备不会调用此方法。

每个方法都会返回一个 `boolean`。下面的 InputMultiplexer 部分会解释这样设计的原因。

实现 `InputProcessor` 后，需要将其告知 libGDX，这样新输入事件到达时才能调用它：

```java
MyInputProcessor inputProcessor = new MyInputProcessor();
Gdx.input.setInputProcessor(inputProcessor);
```

从此以后，所有新的输入事件都会发送给 `MyInputProcessor` 实例。事件会在渲染线程上、调用 `ApplicationListener.render()` 之前分发。

## InputAdapter

`InputAdapter` 实现了所有 `InputProcessor` 方法，并从每个方法返回 false。可以继承 `InputAdapter`，只实现需要的方法，也可以使用匿名内部类。

```java
Gdx.input.setInputProcessor(new InputAdapter () {
   @Override
   public boolean touchDown (int x, int y, int pointer, int button) {
      // your touch down code here
      return true; // return true to indicate the event was handled
   }

   @Override
   public boolean touchUp (int x, int y, int pointer, int button) {
      // your touch up code here
      return true; // return true to indicate the event was handled
   }
});
```

## InputMultiplexer
有时需要串联多个 `InputProcessor`，例如先调用处理 UI 的处理器，再调用处理游戏世界输入事件的处理器。可以使用 [InputMultiplexer](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/InputMultiplexer.html) 类实现：

```java
InputMultiplexer multiplexer = new InputMultiplexer();
multiplexer.addProcessor(new MyUiInputProcessor());
multiplexer.addProcessor(new MyGameInputProcessor());
Gdx.input.setInputProcessor(multiplexer);
```

`InputMultiplexer` 会将新事件交给最先添加的 `InputProcessor`。如果该处理器的事件处理方法返回 false，表示事件未被处理，多路复用器就会将事件交给链中的下一个处理器。通过这种机制，`MyUiInputProcessor` 可以处理落在其某个控件内的事件，并将其他事件传递给 `MyGameInputProcessor`。

## 连续输入处理示例
如果使用 Input Processor 移动 actor，会发现它只在按键输入（或触发 keydown）时移动。
要持续处理输入或移动精灵，可以像下面这样为 actor 添加标志：
```java
public class Bob
{
    boolean leftMove;
    boolean rightMove;
    ...
    updateMotion()
    {
	    if (leftMove)
	    {
		    x -= 5 * Gdx.graphics.getDeltaTime();
	    }
	    if (rightMove)
	    {
		    x += 5 * Gdx.graphics.getDeltaTime();
	    }
    }
    ...
    public void setLeftMove(boolean t)
    {
	    if(rightMove && t) rightMove = false;
	    leftMove = t;
    }
    public void setRightMove(boolean t)
    {
	    if(leftMove && t) leftMove = false;
	    rightMove = t;
    }
```
然后，在 Input processor 中：

```java
...
    @Override
    public boolean keyDown(int keycode)
    {
	    switch (keycode)
	    {
		case Keys.LEFT:
			bob.setLeftMove(true);
			break;
		case Keys.RIGHT:
			bob.setRightMove(true);
			break;
	    }
	    return true;
    }
    @Override
    public boolean keyUp(int keycode)
    {
	    switch (keycode)
	    {
		case Keys.LEFT:
			bob.setLeftMove(false);
			break;
		case Keys.RIGHT:
			bob.setRightMove(false);
			break;
	    }
	    return true;
    }
```
