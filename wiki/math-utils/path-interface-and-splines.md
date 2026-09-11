---
title: Path 接口和样条
---
# 简介

﻿[Path 接口](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Path.html) [(代码)](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Path.html) 的实现允许你平滑地经过一组定义的点（某些情况下还包括切线）。

Path 可以定义为二维或三维，因为它是接受 Vector 派生类的模板，因此可以配合一组 Vector2 或 Vector3 使用。

在数学上，它定义为 F(t)，其中 t 的范围是 [0, 1]，0 表示路径起点，1 表示路径终点。

# 类型

从 v0.9.9 起，Path 接口有 3 个实现（即样条）：
* [Bezier](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Bezier.html) [(code)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/Bezier.java)
* [BSpline](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/BSpline.html) [(code)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/BSpline.java)
* [CatmullRomSpline](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/CatmullRomSpline.html) [(code)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/CatmullRomSpline.java)

# 使用

样条可以像这样以静态方式使用：

```java
    Vector2 out = new Vector2();
    Vector2 tmp = new Vector2();
    Vector2[] dataSet = new Vector2[size];
    /* fill dataSet with path points */
    CatmullRomSpline.calculate(out, t, dataSet, continuous, tmp);// stores in the vector out the point of the catmullRom path of the dataSet in the time t. Uses tmp as a temporary vector. if continuous is true, the path is a loop.
    CatmullRomSpline.derivative(out, t, dataSet, continuous, tmp); // the same as above, but stores the derivative of the time t in the vector out
```

也可以像这样保存：

```java
    CatmullRomSpline<Vector2> myCatmull = new CatmullRomSpline<Vector2>(dataSet, true);
    Vector2 out = new Vector2();
    myCatmull.valueAt(out, t);
    myCatmull.derivativeAt(out, t);
```

推荐使用第二种方式，因为这是 Path 接口唯一保证支持的方式。

# 代码片段

### 缓存样条

这通常在加载时完成：加载数据集、计算样条并保存计算出的点，这样只需计算一次样条，以内存换取 CPU 时间。（绘制静态物体时通常应始终缓存。）

```java
/*members*/
    int k = 100; //increase k for more fidelity to the spline
    Vector2[] points = new Vector2[k];
/*init()*/
    CatmullRomSpline<Vector2> myCatmull = new CatmullRomSpline<Vector2>(dataSet, true);
    for(int i = 0; i < k; ++i)
    {
        points[i] = new Vector2();
        myCatmull.valueAt(points[i], ((float)i)/((float)k-1));
    }
```

### 渲染缓存的样条

如何渲染之前缓存的样条：

```java
/*members*/
    int k = 100; //increase k for more fidelity to the spline
    Vector2[] points = new Vector2[k];
    ShapeRenderer shapeRenderer;
/*render()*/
    shapeRenderer.begin(ShapeType.Line);
    for(int i = 0; i < k-1; ++i)
    {
        shapeRenderer.line(points[i], points[i+1]);
    }
    shapeRenderer.end();
```

### 即时计算

在渲染阶段完成所有计算：

```java
/*members*/
    int k = 100; //increase k for more fidelity to the spline
    CatmullRomSpline<Vector2> myCatmull = new CatmullRomSpline<Vector2>(dataSet, true);
    Vector2 out = new Vector2();
    ShapeRenderer shapeRenderer;
/*render()*/
    shapeRenderer.begin(ShapeType.Line);
    for(int i = 0; i < k-1; ++i)
    {
        shapeRenderer.line(myCatmull.valueAt(points[i], ((float)i)/((float)k-1)), myCatmull.valueAt(points[i+1], ((float)(i+1))/((float)k-1)));
    }
    shapeRenderer.end();
```

### 让精灵沿缓存的路径移动

这种方式使用缓存点进行 LERP。有时外观较粗糙，但速度很快。

```java
/*members*/
    float speed = 0.15f;
    float current = 0;
    int k = 100; //increase k for more fidelity to the spline
    Vector2[] points = new Vector2[k];

/*render()*/
    current += Gdx.graphics.getDeltaTime() * speed;
    if(current >= 1)
        current -= 1;
    float place = current * k;
    Vector2 first = points[(int)place];
    Vector2 second;
    if(((int)place+1) < k)
    {
        second = points[(int)place+1];
    }
    else
    {
        second = points[0]; //or finish, in case it does not loop.
    }
    float t = place - ((int)place); //the decimal part of place
    batch.draw(sprite, first.x + (second.x - first.x) * t, first.y + (second.y - first.y) * t);
```

### 让精灵沿即时计算的路径移动

每帧计算精灵在路径上的位置，因此效果更加平滑。（绘制动态物体时通常应始终即时计算。）

```java
/*members*/
    float speed = 0.15f;
    float current = 0;
    Vector2 out = new Vector2();
/*render()*/
    current += Gdx.graphics.getDeltaTime() * speed;
    if(current >= 1)
        current -= 1;
    myCatmull.valueAt(out, current);
    batch.draw(sprite, out.x, out.y);
```

### 让精灵朝向样条方向

将 atan2 函数应用于曲线的归一化切线（导数）即可得到角度。

```java
    myCatmull.derivativeAt(out, current);
    float angle = out.angle();
```

### 让精灵以恒定速度移动

由于经过 dataSet 点的样条弧长并不恒定，从 0 移动到 1 时，精灵可能会因各种因素时快时慢。为消除这一现象，我们需要改变时间变量的变化率。
只需将速度除以变化率的长度即可。
原本的写法：

```java
    current += Gdx.graphics.getDeltaTime() * speed;
```

改为：

```java
    myCatmull.derivativeAt(out, current);
    current += (Gdx.graphics.getDeltaTime() * speed / myCatmull.spanCount) / out.len();
```

还应修改 speed 变量，因为它不再表示“每秒百分比”，而是表示“每秒米数（或像素？）”。由于 derivativeAt 方法只考虑当前跨度，因此必须使用 spanCount。
