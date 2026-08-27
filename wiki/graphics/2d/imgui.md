---
title: ImGui
---
[Dear ImGui](https://github.com/ocornut/imgui) 是一个流行的 C++ GUI 库。如果想在 libGDX 应用中将它作为 Scene2D 的替代方案，有多种实现方式。可以使用 [ice1000/jimgui](https://github.com/ice1000/jimgui)、[SpaiR/imgui-java](https://github.com/SpaiR/imgui-java) 或 [xpenatan/gdx-imgui](https://github.com/xpenatan/gdx-imgui) 提供的 Java 绑定，也可以使用 [kotlin-graphics/imgui](https://github.com/kotlin-graphics/imgui) 的 Kotlin 移植版。下面给出几个示例。

# 一般信息

Dear ImGui 旨在支持快速迭代，帮助程序员创建内容制作工具以及可视化/调试工具（而不是面向普通最终用户的 UI）。为此它偏向简单和高生产力，因此缺少一些高级库通常具备的功能。

_一个常见误解是认为即时模式 GUI 等同于即时模式渲染，后者通常意味着 GUI 函数被用户调用时向驱动程序/GPU 发送大量低效绘制调用并频繁改变状态。Dear ImGui 并不是这样工作的。Dear ImGui 输出顶点缓冲区和少量绘制调用批次，从不直接操作 GPU。绘制调用批次已经相当优化，可以稍后在应用中甚至远程渲染。_

下面的示例展示了 ImGui 的能力：

<br/>

![Sample](/assets/wiki/images/imgui1.png)

<br/>

# 方案 1：[SpaiR 的绑定](https://github.com/SpaiR/imgui-java)

在 libGDX 中使用 ImGui 的第一种方案是 [github.com/SpaiR/imgui-java](https://github.com/SpaiR/imgui-java) 提供的 Java 绑定。

### LWJGL 3 子项目所需依赖
```gradle
api "io.github.spair:imgui-java-binding:<version>"
api "io.github.spair:imgui-java-lwjgl3:<version>"
api "io.github.spair:imgui-java-natives-linux:<version>"
api "io.github.spair:imgui-java-natives-macos:<version>"
api "io.github.spair:imgui-java-natives-windows:<version>"
```

将 `<version>` 替换为 [README 文件顶部](https://github.com/SpaiR/imgui-java#readme)显示的最新版本。

### 最小用法示例
下面的步骤详细说明如何在 libGDX 游戏中使用 ImGui。为便于使用，可以将大部分方法放入专用类，例如 `ImGuiRenderer`。

1. 初始化 ImGui。每个应用只需执行一次，例如在 `Game#create()` 中：

   ```java
   private static ImGuiImplGlfw imGuiGlfw;
   private static ImGuiImplGl3 imGuiGl3;

   public static void initImGui() {
      imGuiGlfw = new ImGuiImplGlfw();
      imGuiGl3 = new ImGuiImplGl3();
      long windowHandle = ((Lwjgl3Graphics) Gdx.graphics).getWindow().getWindowHandle();
      ImGui.createContext();
      ImGuiIO io = ImGui.getIO();
      io.setIniFilename(null); //Optional. Disables saving window layouts between sessions
      io.getFonts().addFontDefault();
      io.getFonts().build();
      imGuiGlfw.init(windowHandle, true);
      imGuiGl3.init("#version 150");
   }
   ```

2. 在屏幕的 `render()` 方法中使用 ImGui 方法前，需要开始新帧：

   ```java
   private static InputProcessor tmpProcessor;

   public static void startImGui() {
      if (tmpProcessor != null) { // Restore the input processor after ImGui caught all inputs, see #end()
         Gdx.input.setInputProcessor(tmpProcessor);
         tmpProcessor = null;
      }
      
      imGuiGl3.newFrame();
      imGuiGlfw.newFrame();
      ImGui.newFrame();
   }
   ```

3. 然后可以渲染所需的任意 UI 内容，例如：

   ```java
   ImGui.button("I'm a Button!");
   ```

3. 之后需要实际渲染 ImGui 帧：

   ```java
   public static void endImGui() {
      ImGui.render();
      imGuiGl3.renderDrawData(ImGui.getDrawData());

      // If ImGui wants to capture the input, disable libGDX's input processor
      if (ImGui.getIO().getWantCaptureKeyboard() || ImGui.getIO().getWantCaptureMouse()) {
         tmpProcessor = Gdx.input.getInputProcessor();
         Gdx.input.setInputProcessor(null);
      }
   }
   ```

    因此，`render()` 方法应类似这样：

   ```java
   public void render() {
      startImGui();
      ImGui.button("I'm a Button!");
      endImGui();
   }
   ```

4. 不再需要 ImGui 时务必释放它：

   ```java
   public static void disposeImGui() {
      imGuiGl3.dispose();
      imGuiGl3 = null;
      imGuiGlfw.dispose();
      imGuiGlfw = null;
      ImGui.destroyContext();
   }
   ```

5. 结果可能如下所示：

   <img src="/assets/wiki/images/imgui2.png" alt="Screenshot of ImGui in libGDX" width="500"/>

# 方案 2：[kotlin-graphics 的绑定](https://github.com/kotlin-graphics/imgui)

Kotlin-graphics 仓库中有一篇详细的 Wiki 文章，介绍如何将 ImGui 与 libGDX 一起使用：[https://github.com/kotlin-graphics/imgui/wiki/Using-libGDX](https://github.com/kotlin-graphics/imgui/wiki/Using-libGDX)

下面是一些非常简单的用法示例：

### Kotlin
```kotlin
var f = 0f
with(ImGui) {
    text("Hello, world %d", 123)
    button("OK"){
        // react
    }
    inputText("string", buf)
    sliderFloat("float", ::f, 0f, 1f)
}
```

### Java
```java
ImGui imgui = ImGui.INSTANCE;
imgui.text("Hello, world %d", 123);
if(imgui.button("OK")) {
     // react
}
imgui.inputText("string", buf);
float[] f = {0f};
imgui.sliderFloat("float", f, 0f, 1f);
```

 ImGui 也支持其他语言，例如日语，初始化方式见[这里](https://github.com/pakoito/imgui/blob/master/src/test/kotlin/imgui/gl/test%20lwjgl.kt#L79)：

```kotlin
IO.fonts.addFontFromFileTTF("extraFonts/ArialUni.ttf", 18f, glyphRanges = IO.fonts.glyphRangesJapanese)!!
```
