---
title: 将 Blender 模型导入 LibGDX
---
LibGDX 原生提供一种名为 **G3D** 的 3D 格式（g3dj 和 g3db 文件），本文介绍如何使用该格式将 Blender 内容导入游戏。**OBJ** 格式仅得到部分支持，不建议用于生产环境。也可以通过第三方库 [gdx-gltf](https://github.com/mgsx-dev/gdx-gltf) 使用 **glTF** 格式，该库还提供 PBR 渲染等高级功能。

**注意：**_虽然本页使用 Blender 作为实践示例，但其中大部分内容同样适用于**其他建模应用**。_

Blender 是一个开源建模应用，可用于创建 3D 模型、场景和动画。可以从 [blender.org](https://www.blender.org/) 获取 Blender。如果刚开始使用 Blender 创建 3D 模型，可以查看 [Blender 教程](https://www.blender.org/support/tutorials/)。本页提供将 Blender 模型准备并转换为 libGDX 可用格式的实用建议。

### Blender 注意事项
Blender 是多用途工具，某些操作陷阱会让模型不适合游戏开发。例如使用 Rigify 插件为模型制作动画时，会添加大量内容，使模型大小至少增长到 3 MB（每个动画模型），甚至更多，因此务必谨慎使用。

另一个影响文件大小的因素是关键帧插值方式（具体取决于动画类型和数量）。可以将默认的 bezier 插值改为 linear，这可能会大幅减小 g3db 文件大小（但也可能改变动画效果，因此保存前请先检查）。要在 Blender 中修改关键帧插值，切换到动画视图，在 Dope Sheet 中按 A 选中所有关键帧节点，按 T 并选择 “Linear”。

### Blender 动画
请使用 Action Editor 制作模型动画。在 Blender 中为动画轨道指定的名称就是代码中使用的动画 ID。下图中名称应为 CubeAction。别忘了点击小 F，以确保 action 已保存！
![images/800px-Doc26-actionEditor.png](/assets/wiki/images/800px-Doc26-actionEditor.png)

### 导出为 FBX 并转换为 G3DB
**注意：**_可以查看[这个项目](https://github.com/haz00/blender-g3d-exporter)，它可以直接从 .blend 文件转换。*对于低于 2.8 的旧版 Blender，请查看[这个项目](https://github.com/Dancovich/libgdx_blender_g3d_exporter)。_

默认（推荐）方法是导出为 FBX。请只选择确实需要包含的选项（例如节点和动画），不要包含摄像机、灯光等内容。然后下载最新版本的 [fbx-conv](https://github.com/libgdx/fbx-conv)，将 FBX 文件转换为 G3DB。需要使用 `-f` 命令行选项翻转纹理坐标。
`fbx-conv -f file.fbx`

也可以将文件转换为 G3DJ 格式。G3DJ 是 JSON 格式，用普通文本编辑器即可查看。`fbx-conv -f -o G3DJ file.fbx` 请注意，G3DJ 不是二进制格式，因此应用运行时加载时间会更长。

请注意，Blender 的 FBX 导出存在一个已知限制：当前导出器只支持 texface 纹理（即分配给 UV map 的纹理）。

还要注意，Blender 导出时 1 单位等于 1 米，而 libGDX 导入时 1 单位等于 1 厘米，因此导入模型会大 100 倍。将导出选项从默认值 1.00 改为 0.01 即可修复。

![正在更改 Blender 的 fbx 导出选项。](/assets/wiki/images/importing-blender-models-in-libgdx1.png)

### 设置坐标系（上轴）
Blender 使用的坐标系（z-up）不同于游戏中最常见的坐标系（y-up）。Blender FBX 导出器提供将坐标系改为 y-up 的选项（甚至可能是导出器默认值），不要使用此选项，而应保持 Blender 的默认设置（z-up）。

Fbx-conv 会通过旋转模型（转为 y-up）来补偿坐标系。但只有在 fbx 文件自身包含正确信息时才能这样做。Blender FBX 导出器的选项不会修改模型，只会让模型表现得像是 y-up，从而导致 fbx-conv 无法进行补偿。

当 fbx-conv 需要补偿坐标系时，会将模型的所有根节点绕 X 轴旋转 90 度，并相应修改动画。但几何体（顶点）本身保持不变。

不过，如果希望在应用中使用 z-up，可以将 Blender FBX 导出的坐标系选项设为 y-up。这样 fbx-conv 就不会旋转模型和动画，最终仍会使用 z-up。

### 排查纹理缺失

如果面没有被绘制，请尝试禁用背面剔除。面可能因为背向摄像机而不可见。`DefaultShader.defaultCullFace = 0;`
此外，Blender 导出的材质经常会将不透明度设为 0。如果模型没有渲染，请在 Blender 中打开材质，在 “Transparency” 下将 Alpha 设置为所需值（通常为 1，表示完全不透明）。

### 排查黑色纹理

请确保纹理文件使用 POT（power of two，宽高均为 2 的幂）尺寸，并且通常为正方形（例如 32x32、64x64 等）。为获得广泛支持，建议最大尺寸为 1024x1024；不过具体设备可能仍支持更大尺寸。非 POT 纹理经常能在桌面设备上正确渲染，却无法在移动设备上渲染。这是所用 GPU 的限制，不同设备对非 POT 的支持会有所不同。

还要检查灯光和颜色配置是否能照亮模型实例。一个简单的测试方法是向 Model Batch 传入 null environment，这会禁用灯光效果。

如果使用了 Blender 的 FBX 导出脚本，请确保纹理已分配给 UV map，因为导出脚本只支持 texface 纹理。进入编辑模式，在 UV/Texture 编辑器中选择要随对象导出的纹理/图像。

### RrSs 警告
使用 Blender FBX 导出器时，转换 FBX 文件可能会收到 RrSs 警告。这是因为 Blender FBX 导出器错误地导出了变换。fbx-conv 工具会自动修正，可以安全忽略该警告。

### 最大顶点数
模型（g3dj 或 g3db 文件）可以包含多个网格。这些网格使用索引。libGDX 使用 `short` 类型的索引，而 Java 的 `short` 最大值为 32,767。换句话说，单个网格实际不能使用超过 32767 个顶点。因此应确保网格不超过这一限制。

默认情况下，当尝试转换包含超过 32767 个_索引_的网格时，`fbx-conv` 会发出警告。虽然这不一定意味着顶点也超过 32767 个，但通常说明网格“[高模](https://en.wikipedia.org/wiki/Low_poly)”程度过高，可能引发问题。此时应考虑降低多边形数量，或将网格拆分为多个部件。

如果模型包含多个顶点少于 32767 的相似网格，`fbx-conv` 会尝试将它们合并为一个网格。合并网格时，顶点数不会超过 32767 的最大值。可以使用 `-m` 命令行选项修改该最大值。

**警告：**增加 `fbx-conv` 使用的最大顶点数**不会**增加 Java 的 `short` 最大值。

**`fbx-conv` 永远不会拆分网格**，除非网格带蒙皮且超过指定的最大骨骼数。原因很简单：它没有足够的信息完成拆分。

> 注意，与 Java 不同，fbx-conv 和 OpenGL 都支持 `unsigned` 索引。因此在某些情况下、某些设备上，32767 到 65535 个顶点之间可能不会出现问题。但不应依赖这一点。

### 使用模型预览工具

可以使用 [https://github.com/ASneakyFox/libgdx-fbxconv-gui](https://github.com/ASneakyFox/libgdx-fbxconv-gui) 中的模型预览工具预览模型。请从[发布区](https://github.com/ASneakyFox/libgdx-fbxconv-gui/releases)下载预编译版本。

![](https://user-images.githubusercontent.com/7131566/35468742-9a5dd6ac-02f2-11e8-8988-d32ba45b03a2.PNG)

### 将 G3DJ 文件加载到 libGDX 并实例化

将 G3DJ 文件加载到 libGDX 的最简单方式如下：

```java
Model model = new G3dModelLoader(new JsonReader()).loadModel(Gdx.files.internal(modelFileName));
```
这会导入 G3DJ 文件。要实际创建它的运行时实例，可以结合使用 `ModelBuilder` 和 `ModelBatch`：
```java
ModelBuilder modelBuilder = new ModelBuilder();
Model model = new G3dModelLoader(new JsonReader()).loadModel(Gdx.files.internal(modelFileName));
ModelInstance instance = new ModelInstance(model);
```

#### 加载并渲染 G3DJ 文件的示例
```java
import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.PerspectiveCamera;
import com.badlogic.gdx.graphics.VertexAttributes.Usage;
import com.badlogic.gdx.graphics.g3d.Environment;
import com.badlogic.gdx.graphics.g3d.Model;
import com.badlogic.gdx.graphics.g3d.ModelBatch;
import com.badlogic.gdx.graphics.g3d.ModelInstance;
import com.badlogic.gdx.graphics.g3d.attributes.ColorAttribute;
import com.badlogic.gdx.graphics.g3d.environment.DirectionalLight;
import com.badlogic.gdx.graphics.g3d.Material;
import com.badlogic.gdx.graphics.g3d.loader.G3dModelLoader;
import com.badlogic.gdx.graphics.g3d.utils.CameraInputController;
import com.badlogic.gdx.graphics.g3d.utils.ModelBuilder;
import com.badlogic.gdx.utils.JsonReader;

/**
 * Example program that imports "myModel.g3dj" from the assets folder and renders it onto the screen.
 */
public class ImportG3DJ implements ApplicationListener {
    private Environment environment;
    private PerspectiveCamera camera;
    private CameraInputController cameraController;
    private ModelBatch modelBatch;
    private Model model;
    private ModelInstance instance;

    @Override
    public void create() {
        // Create an environment so we have some lighting
        environment = new Environment();
        environment.set(new ColorAttribute(ColorAttribute.AmbientLight, 0.4f, 0.4f, 0.4f, 1f));
        environment.add(new DirectionalLight().set(0.8f, 0.8f, 0.8f, -1f, -0.8f, -0.2f));

        modelBatch = new ModelBatch();

        // Create a perspective camera with some sensible defaults
        camera = new PerspectiveCamera(67, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());
        camera.position.set(10f, 10f, 10f);
        camera.lookAt(0, 0, 0);
        camera.near = 1f;
        camera.far = 300f;
        camera.update();

        // Import and instantiate our model (called "myModel.g3dj")
        ModelBuilder modelBuilder = new ModelBuilder();
        model = new G3dModelLoader(new JsonReader()).loadModel(Gdx.files.internal("myModel.g3dj"));
        instance = new ModelInstance(model);

        cameraController = new CameraInputController(camera);
        Gdx.input.setInputProcessor(cameraController);
    }

    @Override
    public void render() {
        cameraController.update();

        // Clear the stuff that is left over from the previous render cycle
        Gdx.gl.glViewport(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT | GL20.GL_DEPTH_BUFFER_BIT);

        // Let our ModelBatch take care of efficient rendering of our ModelInstance
        modelBatch.begin(camera);
        modelBatch.render(instance, environment);
        modelBatch.end();
    }

    @Override
    public void dispose() {
        modelBatch.dispose();
        model.dispose();
    }

    @Override
    public void resize(int width, int height) { }

    @Override
    public void pause() { }

    @Override
    public void resume() { }
}
```
