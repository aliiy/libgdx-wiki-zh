---
title: 反射
---
为了以跨平台方式使用反射，libGDX 为 Java 反射 API 提供了一个小型封装。该封装主要由两个包含反射操作静态方法的类组成：

  * `ArrayReflection` - 封装对 java.lang.reflect.Array 的访问
  * `ClassReflection` - 封装对 java.lang.Class 的访问

封装中的其他类用于访问构造函数、字段和方法。这些类在很大程度上对应 java.lang.reflect 中的同名类，用法也相同。

# 用法

一般来说，反射封装的用法与 Java 反射 API 相同，只是需要通过相应的封装类调用，而不是直接调用方法。

示例：

| *操作* | *Java* | *封装类* |
| ----------- | ------ | --------- |
| 创建指定组件类型数组的新实例 | `Array.newInstance(clazz, size)` | `ArrayReflection.newInstance(clazz, size)` |
| 根据类名获取类的 Class 对象 | `Class.forName("java.lang.Object")` | `ClassReflection.forName("java.lang.Object")` |
| 创建类的新实例 | `clazz.newInstance()` | `ClassReflection.newInstance(clazz)` |
| 获取类的字段 | `clazz.getFields()` | `ClassReflection.getFields(clazz)` |

# GWT

由于 GWT 不允许像 Java 那样使用反射，因此需要额外步骤才能让 GWT 应用使用反射信息。简而言之，必须指定计划通过反射使用的类。编译 HTML 项目时，libGDX 会根据这些信息生成反射缓存，其中包含指定类的构造函数、字段和方法信息，并提供对它们的访问。随后 libGDX 使用该缓存实现反射 API。

通过在 GWT 模块定义（`*`.gwt.xml）中加入特殊配置属性来指定类。

包含单个类：
```xml
<extend-configuration-property name="gdx.reflect.include" value="com.me.reflected.ReflectedClass" />
```

包含整个包：
```xml
<extend-configuration-property name="gdx.reflect.include" value="com.me.reflected" />
```

也可以排除包中的类（例如包含一个包，但不希望包含该包中的所有类或子包）：
```xml
<extend-configuration-property name="gdx.reflect.exclude" value="com.me.reflected.NotReflectedClass" />
```

## 注意事项
  * 必须指定类或包的完全限定名。
  * 每个类或包都必须使用单独的 `extend-configuration-property` 元素指定。
  * 这些类引用的任何类都会自动包含，因此只需包含自己的类。
  * 不能直接包含嵌套类。例如，如果希望通过反射使用 `CustomActor$CustomActorStyle`（可能用于 uiskin.json），只需包含父类（本例中为 CustomActor）。
  * 可见性限制可能导致编译器不将类包含在 IReflectionCache 中，因此建议使用 public 可见性。
  * 不能直接通过 `field.get(Example.class);` 访问 `static` 字段，必须将实例作为参数传入：`field.get(new Example());`
