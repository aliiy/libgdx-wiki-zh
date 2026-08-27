---
title: 圆、平面、射线等
---
# 简介

libGDX 提供了多个用于处理形状、区域和体积的几何类，包括：

  * *[Circle](https://en.wikipedia.org/wiki/Circle)*
  * *[Frustum](https://en.wikipedia.org/wiki/Frustum)*（有时也写作 _frustrum_）
  * *[Plane](https://en.wikipedia.org/wiki/Plane_%28geometry%29)*
  * *[Spline](https://en.wikipedia.org/wiki/Catmull-Rom_spline#Catmull.E2.80.93Rom_spline)*
  * *[Polygon](https://en.wikipedia.org/wiki/Polygon)*
  * *[Ray](https://en.wikipedia.org/wiki/Ray_%28geometry%29#Ray)*
  * *[Rectangle](https://en.wikipedia.org/wiki/Rectangle)*

完整解释这些概念超出了本文范围，但上面的链接可以作为进一步了解的起点。下面概述它们在 libGDX 中的用法和实现。

----

# [包围盒](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/BoundingBox.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/BoundingBox.java)

轴对齐包围盒可用于简单的体积相交测试。它由描述矩形范围的最小点和最大点定义。可以测试点是否位于盒内，也可以调整盒的大小以包含指定点。还可以使用 [Intersector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Intersector.java) 类测试它与 [Frustum](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Frustum.html) 或 [Ray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/Ray.html) 的相交。

----

# [圆](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Circle.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Circle.java)

用于描述具有中心点和半径的圆的简单类。可以测试点是否位于圆内，也可以使用 [Intersector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Intersector.java) 类测试它与另一个圆、线段或 [Rectangle](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Rectangle.html) 的相交。

----

# [视锥体](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Frustum.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Frustum.java)

视锥体是顶部被截去的四棱锥，可用于描述透视投影下矩形视口可见的空间体积，例如将 3D 场景投影到 2D 显示器。

视锥体可以通过剔除不与其体积相交、因而位于用户视野之外的对象来简化场景。只需将摄像机的视图投影组合矩阵传递给视锥体实例，即可创建描述屏幕可见体积的视锥体。随后，libGDX 提供了针对视锥体体积测试点和简单碰撞体积的方法，例如测试[包围盒](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/BoundingBox.html) [(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/BoundingBox.java)和[Spheres](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/Sphere.html) [(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/Sphere.java)是否可见。这称为“视锥体剔除”，是非常常见的场景优化技术。

----

# [平面](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Plane.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Plane.java)

平面是三维空间中的无限二维表面，由表面上的点和表面法线描述。平面可用于划分空间并确定物体所在区域。可以使用 [Intersector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html) 类测试其与[射线](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/Ray.html)或线段的相交。

----

# [多边形](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Polygon.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Polygon.java)

一个根据点列表定义二维多边形的简单类。它可以轻松进行平移、旋转和缩放，也可以测试某个点是否位于多边形内。假设多边形是凸多边形，则可以使用 [Intersector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html) [(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Intersector.java) 类测试多边形之间的相交。

----

# [射线](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/Ray.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/Ray.java)

射线是一条沿一个方向无限延伸的线段，由原点和单位长度的方向定义。可以使用 [Intersector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html) [(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Intersector.java) 类测试射线与[包围盒](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/BoundingBox.html) [(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/BoundingBox.java)、[平面](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Plane.html) [(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Plane.java)、[球体](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/Sphere.html) [(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/Sphere.java)和三角形的相交。

射线对于拾取操作尤其有用。摄像机可以提供一条射线，从摄像机的视点出发投射到场景中，用于描述窗口中当前鼠标或触摸点的位置。

----

# [矩形](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Rectangle.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Rectangle.java)

用于描述二维轴对齐矩形的简单类。矩形由左下角坐标、宽度和高度定义。它可以检查某个点是否位于矩形内，也可以通过 [Intersector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Intersector.java) 检查矩形与其他矩形或[圆形](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Circle.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Circle.java) 是否相交。

----

# [线段](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/Segment.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/Segment.java)

用于描述三维空间中线段的简单类，由两个端点定义。可以通过 [Intersector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Intersector.java) 检查线段与其他线段、[圆形](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Circle.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Circle.java) 和[平面](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Plane.html)[(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Plane.java) 是否相交。这个类主要用于方便地将两个端点组合起来，因为上述测试方法可以直接接收端点作为参数。

----

# [球体](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/Sphere.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/Sphere.java)

用于描述三维球体的简单类，由中心点和半径定义。可以通过 [Intersector](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Intersector.java) 检查球体与 [Frustum](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Frustum.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/Frustum.java) 或[射线](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/collision/Ray.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/math/collision/Ray.java) 是否相交。
