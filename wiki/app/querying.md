---
title: 查询
---
`Application` 接口提供多种方法，用于查询运行时环境的属性。

### 获取应用程序类型
有时需要根据运行平台以不同方式实现某些功能。`Application.getType()` 方法返回应用程序当前运行的平台：

```java
switch (Gdx.app.getType()) {
    case Android:
        // android specific code
        break;
    case Desktop:
        // desktop specific code
        break;
    case WebGl:
        // HTML5 specific code
        break;
    default:
        // Other platforms specific code
}
```

在 Android 和 iOS 上，还可以查询应用程序当前运行的操作系统版本：

```java
int androidVersion = Gdx.app.getVersion();
```

在 Android 上，它返回当前设备支持的 SDK 级别，例如 Android 1.5 对应 3；在 iOS 上，它返回当前操作系统的主版本号。

### 内存占用
出于调试和性能分析的需要，经常需要了解 Java 堆和本地堆的内存占用：

```java
long javaHeap = Gdx.app.getJavaHeap();
long nativeHeap = Gdx.app.getNativeHeap();
```

两个方法都返回相应堆当前使用的字节数。
