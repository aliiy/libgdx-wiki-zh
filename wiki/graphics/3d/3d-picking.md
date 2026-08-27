---
title: 3D 拾取
---
1. 使用起点和方向构造拾取射线：

```java
float viewportX = (2.0f * getMousePosX()) / viewportWidth - 1.0f;
float viewportY = (2.0f * (viewportHeight - getMousePosY())) / viewportHeight - 1.0f;

Vector3 gdxOrigin = new Vector3();
gdxOrigin.set(viewportX, viewportY, -1.0f);
gdxOrigin.prj(camera.invProjectionView);

Vector3 gdxDirection = new Vector3();
gdxDirection.set(viewportX, viewportY, 1.0f);
gdxDirection.prj(camera.invProjectionView);
gdxDirection.sub(gdxOrigin).nor();

// collide geometries
```

一种拾取方式是在 CPU 上使用[Euclid](https://github.com/ihmcrobotics/euclid)执行碰撞计算。Euclid 是一个高性能且完整的向量数学和几何库。
