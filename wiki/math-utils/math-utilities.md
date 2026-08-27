---
title: 数学工具
---
# 简介

﻿[math](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math) 包含用于处理几何、线性代数、碰撞检测、插值以及常见单位换算问题的各种实用类。


## 数学工具

[MathUtils](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/MathUtils.html)  [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/MathUtils.java) 类涵盖许多实用的小功能。它提供了一个方便的静态 `Random` 成员，避免你在自己的代码中创建实例。在代码中始终使用同一个随机实例，并保存所用的种子值，还可以确保行为始终具有确定性。类中包含弧度与角度互转的常量，以及正弦和余弦函数的查找表；还提供常用 `java.lang.Math` 函数的 `float` 版本，避免从 `double` 向下转换。

## Catmull-Rom 样条

[Catmull-Rom 样条](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/CatmullRomSpline.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/CatmullRomSpline.java) 可以根据离散的控制点列表生成连续曲线。样条可用于描述物体或摄像机在空间中的平滑运动路径。Catmull-Rom 样条尤其适合此用途，因为它易于计算，并且能保证生成的路径经过每个控制点（首尾点用于控制样条形状，但不属于路径的一部分）。与 Bezier 样条不同，它的控制切线是隐式的，以路径定义的简便性换取了对样条形状的控制。只需提供一组期望路径必须经过的点即可。

## 耳切法三角剖分器

对简单多边形进行三角剖分的一种方法基于以下事实：任何至少有四个顶点且没有孔洞的简单多边形，至少有两个所谓的“耳朵”。耳朵是这样的三角形：其中两条边是多边形的边，第三条边完全位于多边形内部。[Ear-Clipping Triangulator](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/EarClippingTriangulator.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/EarClippingTriangulator.java) 类实现了这一思想，根据表示二维多边形的点列表生成三角形列表。输入多边形可以是凹多边形，生成的三角形按顺时针排列。

## 窗口均值

[Windowed Mean](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/WindowedMean.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/WindowedMean.java) 类用于跟踪浮点值连续流在指定窗口内的均值。这可用于基本统计分析，例如测量平均网络速度、评估用户反应时间以动态调整难度，或在音乐可视化中进行基于能量的节拍检测。
