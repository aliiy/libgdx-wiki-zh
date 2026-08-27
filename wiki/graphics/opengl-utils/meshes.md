---
title: 网格
---
[网格](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Mesh.html)是一组顶点（也可以包含索引），用于描述要渲染的一批几何体。顶点可以以顶点缓冲对象（VBO）的形式存放在 VRAM 中，也可以以顶点数组的形式存放在 RAM 中。如果硬件支持，默认会使用速度更快的 VBO。与[纹理](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Texture.html)一样，网格由框架管理，在上下文丢失时会自动重新加载。

libGDX 的许多核心图形类都会使用网格，例如 [SpriteBatch](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/SpriteBatch.html)、[DecalBatch](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g3d/decals/DecalBatch.html) 以及各种 3D 格式加载器。libGDX 的一个重要设计原则是将几何体存储在网格中，以便一次批量上传所有顶点信息进行渲染。尤其在移动平台上，减少单独绘制调用的开销可以显著提升批处理性能。

## 创建网格

有时，与其使用从 3D 建模应用导入的模型，不如使用程序化网格。下面的代码创建了一个简单的全屏四边形，常用于基于帧的着色器效果：

```java
public Mesh createFullScreenQuad() {

  float[] verts = new float[20];
  int i = 0;

  verts[i++] = -1; // x1
  verts[i++] = -1; // y1
  verts[i++] = 0;
  verts[i++] = 0f; // u1
  verts[i++] = 0f; // v1

  verts[i++] = 1f; // x2
  verts[i++] = -1; // y2
  verts[i++] = 0;
  verts[i++] = 1f; // u2
  verts[i++] = 0f; // v2

  verts[i++] = 1f; // x3
  verts[i++] = 1f; // y3
  verts[i++] = 0;
  verts[i++] = 1f; // u3
  verts[i++] = 1f; // v3

  verts[i++] = -1; // x4
  verts[i++] = 1f; // y4
  verts[i++] = 0;
  verts[i++] = 0f; // u4
  verts[i++] = 1f; // v4

  Mesh mesh = new Mesh( true, 4, 0,  // static mesh with 4 vertices and no indices
    new VertexAttribute( Usage.Position, 3, ShaderProgram.POSITION_ATTRIBUTE ),
    new VertexAttribute( Usage.TextureCoordinates, 2, ShaderProgram.TEXCOORD_ATTRIBUTE+"0" ) );

  mesh.setVertices( verts );
  return mesh;
}
// original code by kalle_h
```

注意这里使用简单的 `float` 数组来构建基本顶点信息。我们定义了四个顶点，每个顶点包含窗口坐标中的位置和纹理坐标。然后告知网格构造函数这是一个包含 4 个顶点且没有索引的静态网格。我们定义两个顶点属性，声明它们各自的大小，并使用 libGDX 内置的常见属性类型常量描述其属性。使用常量告诉 libGDX 如何解释每个浮点值，以便渲染时将正确数据交给 OpenGL。在 OpenGL ES2 中，使用[着色器](/wiki/graphics/opengl-utils/shaders)后，还可以在顶点中加入其他类型的属性（例如烘焙顶点光照中的顶点照明值，甚至是用于简单风驱动顶点动画的网格柔性等物理属性）。最后，我们使用之前构建的 `float` 数组设置网格顶点。

还要注意这里使用 ShaderProgram 常量为属性命名。虽然不是必须的，但为顶点位置、法线或纹理坐标等常见属性使用统一的着色器属性名称很有帮助，因为这些名称在常见 libGDX 着色器中通用。统一命名便于在同一网格上替换着色器。更多信息请参阅[着色器](/wiki/graphics/opengl-utils/shaders)。

## 渲染

要渲染网格，只需设置好环境，然后使用所需的图元类型调用 render。要渲染上面的全屏四边形，我们使用三角形扇（因为顶点位置就是按这种方式组织的）：

```java
mesh.render( GL10.GL_TRIANGLE_FAN );
```

更常见的是使用其他图元进行渲染：

```java
mesh.render( GL10.GL_TRIANGLES );           // OpenGL ES1.0/1.1

mesh.render( shader, GL20.GL_TRIANGLES );   // OpenGL ES2 requires a shader

mesh.render( shader, GL20.GL_LINES );       // renders lines instead
```

默认情况下，调用 `render()` 时网格会自动绑定其数据。在调用 `render()` 之前，需要绑定纹理并设置模型变换；如果使用 OpenGL ES2，还需要绑定合适的[着色器](/wiki/graphics/opengl-utils/shaders)，并传入它所需的 uniform。
