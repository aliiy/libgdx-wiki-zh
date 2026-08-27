---
title: 手势检测
---
# 手势检测
触摸屏非常适合基于手势的输入。手势可以是用两根手指捏合表示缩放意图，也可以是点击、双击、长按等。

libGDX 提供了 [GestureDetector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/input/GestureDetector.html) [(源码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/input/GestureDetector.java)，可以检测以下手势：

  * **touchDown**：用户触摸屏幕。
  * **longPress**：用户触摸屏幕一段时间。
  * **tap**：用户触摸屏幕后再次抬起手指。要被识别为点击，手指不能移出初始触摸位置周围指定的方形区域。如果用户在指定时间间隔内连续点击，还会检测到多次点击。
  * **pan**：用户用手指拖过屏幕。检测器会报告当前触摸坐标，以及当前触摸位置与上一次触摸位置之间的差值。适合实现 2D 摄像机平移。
  * **panStop**：不再平移时调用。
  * **fling**：用户在屏幕上拖动手指后抬起。适合实现滑动手势。
  * **zoom**：用户将两根手指放在屏幕上并使其相互靠拢或分开。检测器会以像素为单位报告手指之间的初始距离和当前距离。适合实现摄像机缩放。
  * **pinch**：与缩放类似。检测器报告的是手指的初始位置和当前位置，而不是距离。适合实现摄像机缩放以及旋转等更复杂的手势。

`GestureDetector` 本质上是一个[事件处理器](/wiki/input/event-handling)。要监听手势，需要实现 [GestureListener](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/input/GestureDetector.GestureListener.html) 接口，并将其传给 `GestureDetector` 的构造函数。然后将检测器设置为 InputProcessor，可以设置到 InputMultiplexer 中，也可以将其作为主 InputProcessor：

```java
public class MyGestureListener implements GestureListener{

   	@Override
   	public boolean touchDown(float x, float y, int pointer, int button) {
		   	
	   	return false;
   	}
	   	
	@Override
	public boolean tap(float x, float y, int count, int button) {
			
		return false;
	}
		
	@Override
	public boolean longPress(float x, float y) {
			
		return false;
	}
		
	@Override
	public boolean fling(float velocityX, float velocityY, int button) {
			
		return false;
	}
		
	@Override
	public boolean pan(float x, float y, float deltaX, float deltaY) {
			
		return false;
	}
		
	@Override
	public boolean panStop(float x, float y, int pointer, int button) {
			
		return false;
	}
		
   	@Override
   	public boolean zoom (float originalDistance, float currentDistance){
	   		
	   return false;
   	}

   	@Override
   	public boolean pinch (Vector2 initialFirstPointer, Vector2 initialSecondPointer, Vector2 firstPointer, Vector2 secondPointer){
	   		
	   return false;
   	}
   	@Override
	public void pinchStop () {
	}
}
```

```java
Gdx.input.setInputProcessor(new GestureDetector(new MyGestureListener()));
```

`GestureListener` 可以通过方法返回 true 或 false，表示是否消费了事件，或是否希望将事件传递给下一个 InputProcessor。

与普通 `InputProcessor` 报告的事件一样，相应方法会在渲染线程上、调用 `ApplicationListener.render()` 之前调用。

`GestureDetector` 还提供了第二个构造函数，可用于指定手势检测的各种参数。更多信息请参阅 [Javadocs](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/input/GestureDetector.html#GestureDetector(float,%20float,%20float,%20float,%20com.badlogicgames.gdx.input.GestureDetector.GestureListener))。
