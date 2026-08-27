---
title: 材质与环境
---
实际渲染时，需要指定渲染什么（形状）以及如何渲染（材质）。形状通过 Mesh（更常见的是 MeshPart）指定，它定义着色器所需的顶点属性。材质通常用于指定着色器的 uniform 值。

Uniform 可以分为模型相关 uniform（例如应用的纹理或是否使用混合）和环境 uniform（例如使用的光源或环境立方体贴图）。同样，3D API 允许指定材质和环境。

## 材质

材质属于特定模型（或模型实例）。可以通过索引 `model.materials.get(0)`、名称 `model.getMaterial("material3")` 或节点部件 `model.nodes.get(0).parts(0).material` 访问它们。创建 ModelInstance 时会复制材质，因此修改某个 ModelInstance 的材质不会影响原始 Model 或其他 ModelInstance。

Material 类继承 Attributes 类，关于 Attributes 的更多信息见下文。

## 环境

Environment 包含某个位置专用的 uniform 值，例如光源就属于 Environment。简单应用可能只使用一个 Environment，而复杂应用可以根据 ModelInstance 所在位置使用多个 Environment。不过，一个 ModelInstance（或 Renderable）只能包含一个 Environment。

Environment 类继承 Attributes 类，关于 Attributes 的更多信息见下文。

### 光源

光源同样使用属性，因此可以将光源附加到环境或材质。可以使用 [`environment.add(light)`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/Environment.html#add-com.badlogic.gdx.graphics.g3d.environment.BaseLight-) 方法向环境添加光源。也可以使用下文的 `DirectionalLightsAttribute`、`PointLightsAttribute` 和 `SpotLightsAttribute` 属性。这些属性各自包含一个数组，可用于附加一个或多个光源。但通常只能二选一：如果向环境的 `PointLightsAttribute` 添加光源，再向材质的 `PointLightsAttribute` 添加另一个光源，`DefaultShader` 就会忽略环境中的点光源。光源始终按引用使用。

光源应按重要性排序，通常意味着按距离排序。例如，`DefaultShader` 默认只使用前五个点光源进行着色器光照（可[配置](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/shaders/DefaultShader.Config.html#numPointLights)），其余光源会被忽略。

## 属性

Environment 和 Material 类都继承 Attributes 类。Attributes 最常用于指定 uniform 值，例如 TextureAttribute 可用于指定要绑定到着色器的纹理。不过，属性不一定是 uniform；例如 DepthTestAttribute 用于修改 OpenGL 状态，而不会设置 uniform。

Attributes 类最类似于 Set。每个属性最多只能包含一个值，就像一个 uniform 只能设置为一个值。理论上 Material 和 Environment 可以包含同一属性；这种情况下的实际行为取决于所使用的着色器，但大多数情况下会使用 Material 的属性，而不是 Environment 的属性。

### 属性类型

每个属性都有一个 `type` long 值，它是用于识别属性的位掩码。因此，完整的材质或环境可以用一个 long 表示，其中每一位代表一个属性。有些属性类专用于单一 type 值（位），其他类可用于多个 type 值（位），此时必须在构造时指定 type。例如：

```java
Attribute attribute = new ColorAttribute(ColorAttribute.Diffuse, Color.RED);
```

注意，ColorAttribute 类包含一个完成同样操作的便捷方法：

```java
Attribute attribute = ColorAttribute.createDiffuse(Color.RED);
```

### 使用属性

属性最常用的操作是 `set`、`has`、`remove` 和 `get`。

可以使用 `set` 方法添加或修改属性。如果已存在相同类型的属性，会先移除旧属性，再添加新属性。例如：`material.set(FloatAttribute.createAlphaTest(0.25f));`

使用 `has` 方法可以检查是否设置了特定类型的属性，例如：`material.has(FloatAttribute.AlphaTest);`。也可以检查多个属性，例如：`material.has(FloatAttribute.AlphaTest | ColorAttribute.Diffuse);`，此时只有所有属性都已设置，`has` 方法才会返回 `true`。由于 `has` 使用位运算检查，因此速度很快，可以在调用 `remove` 等方法前使用它确认属性确实存在。

使用 `remove` 方法可以移除指定类型的属性，例如：
`material.remove(FloatAttribute.AlphaTest);`。也可以一次移除多个属性，例如：`material.remove(FloatAttribute.AlphaTest | ColorAttribute.Diffuse);`。

可以使用 `get` 方法获取指定类型的属性。例如：`material.get(FloatAttribute.AlphaTest);`。如果未设置该属性，`get` 方法会返回 `null`。由于 type 已隐含对应的类，因此可以安全地直接转换结果，无需检查：`(FloatAttribute)material.get(FloatAttribute.AlphaTest);`。此外还提供了便捷的模板方法：`material.get(FloatAttribute.class, FloatAttribute.AlphaTest);`。

除此之外，还可以使用 `clear`（移除所有属性）、遍历（实现了 `Iterable<Attribute>`）以及比较（实现了 `Comparator<Attribute>`，不过 `same` 方法提供了更多选项）属性。`getMask()` 方法可以访问包含所有属性的掩码。例如，`material.getMask() & FloatAttribute.AlphaTest == FloatAttribute.AlphaTest` 与 `material.has(FloatAttribute.AlphaTest)` 等价。

### 自定义属性类型

可以将标准属性类用于新的自定义类型，例如使用 ColorAttribute 类指定自定义颜色类型。此时需要考虑三件事：

1. 命名属性类型。每种属性类型都必须有唯一的别名（名称）。可以使用 uniform 名称作为别名，但不是必须的。别名还会用于调试，例如调用 `attribute.toString()` 时。
2. 注册属性类型。这是为了确保每一位只有一种属性类型。只能在 Attribute 类或其子类中完成注册。
3. 让 ColorAttribute 接受自定义类型。ColorAttribute 类和大多数其他属性类会在构造时检查类型，因此只需检查类型即可转换属性。例如，`(ColorAttribute)material.get(ColorAttribute.Diffuse)` 始终有效，因为 ColorAttribute 是唯一接受 `ColorAttribute.Diffuse` 类型的属性。

由于第 2、3 步的要求，必须扩展 Attribute 类才能添加自定义属性类型：

```java
public class CustomColorTypes extends ColorAttribute {
    public final static String AlbedoColorAlias = "AlbedoColor"; // step 1: name the type
    public final static long AlbedoColor = register(AlbedoColorAlias); // step 2: register the type
    static {
        Mask |= AlbedoColor; // step 3: Make ColorAttribute accept the type
    }
    /** Prevent instantiating this class */
    private CustomColorTypes() {
        super(0);
    }
}
```

然后可以使用以下方式创建自定义属性类型：

```java
Attribute attribute = new ColorAttribute(CustomColorTypes.AlbedoColor, Color.RED);
```

### 自定义属性
也可以创建自定义属性，流程与上面没有太大区别。必须扩展 Attribute 类、至少注册一种类型，并添加要传递给着色器的数据。例如，添加一个向着色器传递 double 值的属性：

```java
public class DoubleAttribute extends Attribute {
    public final static String MyDouble1Alias = "myDouble1";
    public final static long MyDouble1 = register(MyDouble1Alias);
    public final static String MyDouble2Alias = "myDouble2";
    public final static long MyDouble2 = register(MyDouble2Alias);
    protected static long Mask = MyDouble1 | MyDouble2;
    /** Method to check whether the specified type is a valid DoubleAttribute type */
    public static Boolean is(final long type) {
        return (type & Mask) != 0;
    }

    public double value;

    public DoubleAttribute (final long type) {
        super(type);
        if (!is(type))
            throw new GdxRuntimeException("Invalid type specified");
    }

    public DoubleAttribute (final long type, final double value) {
        this(type);
        this.value = value;
    }

    /** copy constructor */
    public DoubleAttribute (DoubleAttribute other) {
        this(other.type, other.value);
    }

    @Override
    public Attribute copy () {
        return new DoubleAttribute(this);
    }

    @Override
    public int hashCode () {
        final int prime = /* pick a prime number and use it here */;
        final long v = NumberUtils.doubleToLongBits(value);
        return prime * super.hashCode() + (int)(v^(v>>>32));
    }

    @Override
    public int compareTo (Attribute o) {
        if (type != o.type) return type < o.type ? -1 : 1;
        double otherValue = ((DoubleAttribute)o).value;
        return value == otherValue ? 0 : (value < otherValue ? -1 : 1);
    }
}
```
当然，应将 `MyDouble1Alias`、`MyDouble1`、`"myDouble1"`、`MyDouble2Alias`、`MyDouble2` 和 `"myDouble2"` 替换为更有意义的描述。

注意，创建 Model 的 `ModelInstance` 时会调用 `copy()` 方法。它应返回一个与原属性相同、但可以独立修改的属性实例。虽然不是必需的，但实现一个*复制构造函数*通常是不错的做法。

应实现 `hashCode()` 方法，因为它用于比较属性和材质。例如，两个材质包含相同属性（类型），且每对属性类型的 `equals()` 方法都返回 true 时，会被视为相同。默认情况下，Attribute 类的 `equals()` 方法会比较两个属性的 `hashCode()`。

必须实现 `compareTo(Attribute)` 方法，以便根据材质对渲染调用排序。该实现通常应始终以以下代码行开头：
`if (type != o.type) return type < o.type ? -1 : 1;`，以确保比较的是相同类型的属性。

> 属性类应保持小巧且自包含，因此最好始终直接扩展 `Attribute` 类。尽量不要通过扩展 Attribute 的子类来添加额外信息。

## 可用属性
如上所述，可以创建自定义属性。不过，libGDX 已内置了一些属性，下面将列出它们。

### BlendingAttribute

默认情况下，3D API 假定所有内容都是不透明的。`BlendingAttribute` 最常用于材质（用于环境时会改变默认行为），可用于指定材质是否混合。构造 `BlendingAttribute` 时无需指定类型，其类型始终为 `BlendingAttribute.Type`，除非对其进行扩展。它包含四个可设置的属性：
* `blended` 指示材质是否应视为混合材质，主要用于排序，例如先绘制不透明对象，再绘制透明对象。
* `sourceFunction` OpenGL 枚举，指定如何计算（传入的）红、绿、蓝和 alpha 源混合因子，默认值为 GL_SRC_ALPHA。
* `destFunction` OpenGL 枚举，指定如何计算（已有的）红、绿、蓝和 alpha 目标混合因子，默认值为 GL_ONE_MINUS_SRC_ALPHA。对于加法混合，可以将其设为 GL_ONE。
* `opacity` 不透明度（源 alpha 值），范围为 0（完全透明）到 1（完全不透明）。

### ColorAttribute

`ColorAttribute` 允许向着色器传递颜色，因此只包含一个属性：`.color`。可以在构造时设置颜色（按值设置），也可以使用 `.color.set(...)` 方法设置。`ColorAttribute` 需要指定属性类型，默认提供以下类型：
* `ColorAttribute.Diffuse`
* `ColorAttribute.Specular`
* `ColorAttribute.Ambient`
* `ColorAttribute.Emissive`
* `ColorAttribute.Reflection`
* `ColorAttribute.AmbientLight`
* `ColorAttribute.Fog`

其中后两种通常用于 Environment，其余类型通常用于 Material。

### CubemapAttribute
要向着色器传递 `Cubemap`，可以使用 `CubemapAttribute`。它的值是 `textureDescription` 成员，可与其他纹理相关值一起指定 cubemap。`CubemapAttribute` 需要指定属性类型，默认只有 `CubemapAttribute.EnvironmentMap` 有效。

### DepthTestAttribute
与 `BlendingAttribute` 一样，`DepthTestAttribute` 不需要属性类型，其类型始终为 `DepthTestAttribute.Type`。`DepthTestAttribute` 可用于通过以下属性指定深度测试和深度写入：
* `depthFunc` 深度测试函数；设为 0（或 GL_NONE）可禁用深度测试，默认值为 GL20.GL_LEQUAL。
* `depthRangeNear` 将近裁剪面映射到窗口坐标，默认值为 0.0。
* `depthRangeFar` 将远裁剪面映射到窗口坐标，默认值为 1.0。
* `depthMask` 是否写入深度缓冲，默认启用。

### DirectionalLightsAttribute
DirectionalLightsAttribute 不需要属性类型，其类型始终为 `DirectionalLightsAttribute.Type`。`DirectionalLightsAttribute` 可使用以下属性指定 [`DirectionalLight`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/environment/DirectionalLight.html) 实例数组：
* `lights` 光源数组，应按重要性排序。

### FloatAttribute
要向着色器传递单个浮点值，可以使用 `FloatAttribute`。可以在构造时指定该值，也可以使用 `.value` 成员设置。`FloatAttribute` 需要属性类型，默认可使用：
* `FloatAttribute.Shininess` 用于镜面反射光照。
* `FloatAttribute.AlphaTest` 当 alpha 值等于或低于指定值时丢弃像素。

### IntAttribute
与 `FloatAttribute` 类类似，`IntAttribute` 允许向着色器传递整数值。同样，可以使用 `.value` 成员，也可以在构造时设置该值。`IntAttribute` 需要属性类型，默认可使用：
* `IntAttribute.CullFace` 用于指定面剔除的 OpenGL 枚举，可以是 GL_NONE（不剔除）、GL_FRONT（仅渲染背面）或 GL_BACK（仅渲染正面）。默认值取决于着色器，默认着色器使用 GL_BACK。

### PointLightsAttribute
PointLightsAttribute 不需要属性类型，其类型始终为 `PointLightsAttribute.Type`。`PointLightsAttribute` 可使用以下属性指定 [`PointLight`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/environment/PointLight.html) 实例数组：
* `lights` 光源数组，应按重要性排序。

### SpotLightsAttribute
默认着色器不支持。SpotLightsAttribute 不需要属性类型，其类型始终为 `SpotLightsAttribute.Type`。`SpotLightsAttribute` 可使用以下属性指定 [`SpotLight`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/environment/SpotLight.html) 实例数组：
* `lights` 光源数组，应按重要性排序。

### TextureAttribute
`TextureAttribute` 可用于向着色器传递 `Texture`。与 `CubemapAttribute` 一样，它包含 `textureDescription` 成员，可以在设置 `Texture` 的同时指定重复和过滤等纹理相关值。此外还包含 `offsetU`、`offsetV`、`scaleU` 和 `scaleY` 成员，用于指定要使用的纹理区域（纹理坐标变换）。它还包含 `uvIndex` 成员（默认为 0），用于指定应使用哪组纹理坐标。请注意，默认着色器目前会忽略 uvIndex 成员，始终使用第一组纹理坐标。

`TextureAttribute` 需要属性类型，默认可使用以下类型之一：
* `TextureAttribute.Diffuse`
* `TextureAttribute.Specular`
* `TextureAttribute.Bump`
* `TextureAttribute.Normal`
