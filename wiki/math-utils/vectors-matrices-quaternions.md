---
title: 向量、矩阵和四元数
---
# 简介

libGDX 提供了多个线性代数类，用于处理物理学和应用数学中的常见任务，包括：

  * *[Vector](https://en.wikipedia.org/wiki/Euclidean_vector)*
  * *[Matrix](https://en.wikipedia.org/wiki/Matrix_%28mathematics%29)*
  * *[Quaternion](https://en.wikipedia.org/wiki/Quaternion)*

完整解释这些概念超出了本文范围，但上面的链接可以作为进一步了解的起点。下面概述它们在 LibGDX 中的用法和实现。

----

# 向量

向量是由数字组成的数组，用于描述具有方向和大小的概念，例如位置、速度或加速度。libGDX 为二维和三维空间提供向量类，包含加法、减法、归一化、叉积和点积等常见操作，也提供两个向量之间的线性和球面线性插值方法。

## 方法链

libGDX 的其他地方也使用方法链模式，以提高便利性并减少输入。每个修改向量的操作都会返回该向量的引用，从而可以在同一行继续链接操作。下面的示例创建从点 _(x1, y1, z1)_ 指向点 _(x2, y2, z2)_ 的单位向量：

```java
Vector3 vec = new Vector3( x2, y2, z2 ).sub( x1, y1, z1 ).nor();
```

示例先使用第二个点的坐标实例化 Vector3，再减去第一个点，最后将结果归一化。这等价于：

```java
Vector3 vec = new Vector3( x2, y2, z2 );  // new vector at (x2, y2, z2)
vec.sub( x1, y1, z1 );                    // subtract point (x1, y1, z1)
vec.nor();                                // normalize result
```

----

# 矩阵

矩阵是二维数字数组。在图形处理中，矩阵用于变换三维空间中的顶点并进行投影，以便显示在二维屏幕上。与 OpenGL 一样，libGDX 按列主序存储矩阵。矩阵有
[3x3 (Matrix3)](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Matrix3.html) 
[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/Matrix3.java) 和 [4x4 (Matrix4)](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Matrix4.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/math/Matrix4.java) 两种矩阵，并提供了在二者之间移动值的便捷方法。libGDX 还包含许多常见的矩阵操作，例如构建平移和缩放变换，根据欧拉角、轴角对或四元数构建旋转，构建投影，以及与其他矩阵和向量相乘。

libGDX 中矩阵最常见的用途，可能就是通过 [Camera](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Camera.html)[(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/Camera.java) 类的视图矩阵和投影矩阵控制几何体在屏幕上的渲染方式。Camera 分为 [OrthographicCamera](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/OrthographicCamera.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/OrthographicCamera.java) 和 [PerspectiveCamera](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/PerspectiveCamera.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/PerspectiveCamera.java)，可以通过位置和观察方向，以便捷直观的方式控制渲染场景中的视图；但在底层，它们只是用于告知 OpenGL 如何处理待渲染几何体的一组 4x4 矩阵。

## 方法链

与向量一样，LibGDX 中的矩阵操作会返回被修改矩阵的引用，以便在一行调用中链接操作。下面为位置为 _(x, y, z)_、旋转由轴角对描述的对象创建新的 4x4 模型视图矩阵：

```java
Matrix4 mat = new Matrix4().setToRotation( axis, angle ).trn( x, y, z );
```

这等价于：

```java
Matrix4 mat = new Matrix4();       // new identity matrix
mat.setToRotation( axis, angle );  // set rotation from axis-angle pair
mat.trn( x, y, z );                // translate by x, y, z
```

## 本机方法

矩阵类的一些操作以静态方法提供，并由快速本机代码支持。在关注性能的地方应使用这些静态方法。下面的示例执行两个 4x4 矩阵的乘法：

```java
Matrix4 matA;
Matrix4 matB;
Matrix4.mul( matA.val, matB.val );     // the result is stored in matA
```

注意使用 `.val` 访问支撑每个矩阵的底层 `float` 数组。本机方法直接操作这些数组。上面的代码在功能上等价于成员方法语法：
```java
matA.mul( matB );
```

----

# 四元数

四元数是复数的四维扩展数系，在高等数学和数论中有许多专门用途。在 LibGDX 中，单位四元数可用于描述三维空间中的旋转，因为它们组合简单、数值稳定并能避免[万向节锁](https://en.wikipedia.org/wiki/Gimbal_lock)，因此通常优于其他旋转表示方法。

四元数可以显式提供四个分量构造，也可以通过传入轴角对构造。请注意，虽然四元数通常被描述为向量与标量的组合，**_但它并不只是一个轴角对。_** LibGDX 还提供了四元数与其他旋转表示之间的转换方法，例如欧拉角、旋转矩阵和轴角对。
