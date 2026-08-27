---
title: 着色器
---
如果要使用 OpenGL ES 2.0，就应该了解一些着色器基础。libGDX 自带标准着色器，可负责通过 `SpriteBatch` 渲染内容。不过，如果想在 OpenGL ES 2.0 中渲染 `Mesh`，就必须自行提供有效的着色器。基本上，OpenGL ES 2.0 中的一切都通过着色器渲染，因此称为可编程管线。

接触着色器的想法可能会让一些人不愿使用 ES 2.0，但学习它非常值得，因为着色器可以实现相当惊人的效果。而且理解基础知识其实并不困难。

## 什么是着色器？

OpenGL 中的着色器是使用类似 C 的 **GLSL**（OpenGL Shading Language）编写的小程序，在 GPU 上运行并处理渲染所需的数据。可以将着色器简单理解为 GPU 上的一个处理阶段。它接收一组输入，对其执行一系列操作，最后输出结果，可以类比为函数参数和返回值。

通常，在 OpenGL ES 2.0 中渲染内容时，数据会先经过**顶点**着色器，再经过**片段**着色器。

## 顶点着色器

顾名思义，顶点着色器负责对顶点执行操作。更具体地说，程序的每次执行只处理恰好 _一个_ 顶点。这是一个重要概念：在顶点着色器中执行的所有操作都只发生在 _一个_ 顶点上。

下面是一个简单的顶点着色器：

```cpp
attribute vec4 a_position;

uniform mat4 u_projectionViewMatrix;

void main()
{
    gl_Position =  u_projectionViewMatrix * a_position;
} 
```

这并不复杂。首先，有一个名为 `a_position` 的顶点属性。该属性是 `vec4`，即四维向量。在此示例中，它保存顶点的位置信息。

接下来是 `u_projectionViewMatrix`。这是一个保存视图和投影变换数据的 4x4 矩阵。如果对这些术语不熟悉，建议[在这里阅读相关主题](https://web.archive.org/web/20210330141121/http://blog.db-in.com/cameras-on-opengl-es-2-x/)，理解它们非常有帮助。

在 main 方法中，对顶点执行操作。本例中，着色器只将顶点位置与矩阵相乘，并将结果赋给 `gl_Position`。`gl_Position` 是 OpenGL 预定义的关键字，只能用于传递处理后的顶点。

## 片段着色器
片段着色器的工作方式与顶点着色器非常相似，但它不是处理顶点，而是为每个片段执行一次。简单起见，可以将片段理解为一个像素。这是一个非常重要的区别。

假设一个三角形覆盖 300 个像素。该三角形的顶点着色器执行 3 次，而片段着色器会执行 300 次。因此编写着色器时要牢记这一点：片段着色器中的所有操作都要昂贵得多！

下面是一个非常基础的片段着色器：

```cpp
void main()
{
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
```

该片段着色器会将每个片段渲染为纯红色。gl_FragColor 是另一个预定义关键字，用于输出片段的最终颜色。注意我们如何使用 `vec4(x, y, z, w)` 在着色器中定义向量；本例中该向量用于定义片段颜色。

## 简单的 ShaderProgram

现在我们已经了解了着色器的作用和工作方式，接下来在 libGDX 中创建一个着色器。这通过 `ShaderProgram` 类完成。一个 `ShaderProgram` 由顶点着色器和片段着色器组成。可以从文件加载，也可以直接传入字符串，将着色器代码保存在 Java 文件中。

下面是本文使用的着色器配置：

```java
String vertexShader = "attribute vec4 a_position;\n" +
                      "attribute vec4 a_color;\n" +
                      "attribute vec2 a_texCoord0;\n" +
                      "uniform mat4 u_projTrans;\n" +
                      "varying vec4 v_color;\n" +
                      "varying vec2 v_texCoords;\n" +
                      "void main() {\n" +
                          "v_color = vec4(1, 1, 1, 1);\n" +
                          "v_texCoords = a_texCoord0;\n" +
                          "gl_Position =  u_projTrans * a_position;\n" +
                      "}";
String fragmentShader = "#ifdef GL_ES\n" +
                        "precision mediump float;\n" +
                        "#endif\n" +
                        "varying vec4 v_color;\n" +
                        "varying vec2 v_texCoords;\n" +
                        "uniform sampler2D u_texture;\n" +
                        "void main() {\n" +
                            "gl_FragColor = v_color * texture2D(u_texture, v_texCoords);\n" +
                        "}";
```

这是使用位置属性、颜色属性和纹理坐标属性的着色器的常见配置。注意其中的两个 `varying`，它们是要传递给片段着色器的输出。

片段着色器中有一个 `sampler2D`，这是用于纹理的特殊 uniform。正如 main 函数所示，我们将顶点颜色与纹理采样得到的颜色相乘，以生成最终输出颜色。

下面列出 libGDX 自带的属性，便于将着色器附加到 `SpriteBatch` 和 libGDX 的其他部分：
* `a_position`
* `a_normal`
* `a_color`
* `a_texCoord`，末尾需要一个数字，例如 `a_texCoord0`、`a_texCoord1` 等。
* `a_tangent`
* `a_binormal`

创建 `ShaderProgram` 的代码如下：

```java
ShaderProgram shader = new ShaderProgram(vertexShader, fragmentShader);
```

可以通过 `shader.isCompiled()` 确认着色器是否编译成功，也可以使用 `shader.getLog()` 输出编译日志。

接下来创建匹配的网格并加载纹理：

```java
mesh = new Mesh(true, 4, 6, VertexAttribute.Position(), VertexAttribute.ColorUnpacked(), VertexAttribute.TexCoords(0));
mesh.setVertices(new float[] {
    -0.5f, -0.5f, 0, 1, 1, 1, 1, 0, 1,
    0.5f, -0.5f, 0, 1, 1, 1, 1, 1, 1,
    0.5f, 0.5f, 0, 1, 1, 1, 1, 1, 0,
    -0.5f, 0.5f, 0, 1, 1, 1, 1, 0, 0
});
mesh.setIndices(new short[] {0, 1, 2, 2, 3, 0});
texture = new Texture(Gdx.files.internal("bobrgb888-32x32.png"));
```

在 render 方法中，只需调用 `shader.bind()`，传入 uniform，然后使用该着色器渲染网格：

```java
texture.bind();
shader.bind();
shader.setUniformMatrix("u_projTrans", matrix);
shader.setUniformi("u_texture", 0);
mesh.render(shader, GL20.GL_TRIANGLES);
```

就这么简单！

OpenGL ES 2.0 中使用着色器的好处是，你可以利用数量庞大的着色器资源。WebGL 中几乎所有效果都可以轻松移植到移动设备上运行。去尝试吧！

在[这里](https://libgdxinfo.wordpress.com/shaders/)可以找到一个使用 libGDX 实现冲击波效果着色器的简单示例。
