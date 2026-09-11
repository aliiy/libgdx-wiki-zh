---
permalink: /dev/from-source/
redirect_from:
  - /dev/from_source/
title: "从源码构建"
classes: wide
header:
  overlay_color: "#000"
  overlay_filter: "0.3"
  overlay_image: /assets/images/dev/dev.jpeg
  caption: "图片来源：[**Florian Olivo**](https://unsplash.com/photos/Ek9Znm8lQ1U)"

sidebar:
  nav: "dev"
---

{% include breadcrumbs.html %}

# 搭建项目
如果你想研究 libGDX 本身的代码，或者想试用某个 PR，就需要在本地机器上配置好 libGDX 代码库。如果你打算进行任何修改，我们强烈推荐使用 IntelliJ IDEA 或 Android Studio 作为 IDE，因为它们更适合配合 Gradle 和 Android 使用。

如果你想向项目提交代码，也请花一点时间看看我们的[贡献指南](/dev/contributing/)。
{: .notice--info}

1. 把 libGDX fork 到你自己的 GitHub 账号下。
2. 通过 IDE 或命令行把项目 clone 到你的机器上：
   ```
   git clone git://github.com/libgdx/libgdx.git
   cd libgdx
   ```
   如果你想减小下载体积，可以做浅克隆（例如 `git clone --depth 1 https://github.com/libgdx/libgdx`）。要自动初始化并更新仓库中的子模块（例如 FreeType），请传入 `--recurse-submodules` 参数。请注意，一些生成的文件名相当长，如果你的仓库嵌套在过多的子目录中，可能会出问题（例如 `error: unable to create file [...]: Filename too long`）。

3. 拉取原生二进制文件，它们是在快照构建服务器上构建的。即使你打算以后自己构建原生库，也建议先把这些文件下载下来，这样你就可以在进入下一步之前验证开发环境是否配置正确。
   ```
   ./gradlew fetchNatives
   ```

   请注意，`fetchNatives` 和 `build` 任务[需要分别调用](https://github.com/libgdx/libgdx/pull/7246#issuecomment-1807271546)。
   {: .notice--warning}
5. 如果你想修改代码，请把它导入你喜欢的 IDE：

    a) **使用 IntelliJ IDEA/Android Studio：**

     - File -> Open -> libGDX 根目录的 `build.gradle`
     - 导入所有项目
     - 等待所有内容同步并完成索引
     - View -> Tool Windows -> Gradle，点击 Gradle 同步按钮
     - 确保 Gradle 同步成功，如果不成功，先解决手头的问题。
     - 进入偏好设置，关闭 configure on demand

    b) **Eclipse：** 依次选择 File -> Import -> Gradle -> Gradle project

     如果你不想在 Eclipse 中使用 Gradle，执行 `./gradlew cleanEclipse eclipse` 会生成所需的项目文件。

你可以选择把 IntelliJ IDEA 的 Gradle 配置中的 `Build and run` 改为使用 IntelliJ IDEA 而不是 Gradle。这能显著缩短启动测试所需的时间。

![](/assets/images/dev/source/1.png)

如果你在为 libGDX 搭建开发环境时遇到任何问题，请加入 [Discord](/community/discord/) 上的社区寻求帮助。

<br/>

# 测试
如果一切配置正确，你可以试着跑一跑 libGDX 的测试。

**LWJGL/LWJGL3：** 右键点击并运行位于 tests/gdx-tests-lwjgl/src（或对应的 tests/gdx-tests-lwjgl3/src）中的 `LwjglTestStarter` 类。尝试运行测试时你应该会遇到 _assets not found_ 的情况，这时请编辑运行配置，把它指向正确的资源文件夹（`tests/gdx-tests-android/assets`）。IntelliJ IDEA 中的配置如下：

![](/assets/images/dev/source/0.png)

你可以通过设置程序参数 `[options] [Test class name]` 直接运行单个测试和/或配置测试启动器，可用的选项有：

- `--angle` 启用 Angle 模拟（默认禁用）
- `--gl30` 启用 GLES 3.0，core profile 为 4.3（macOS 上为 3.2）
- `--gl31` 启用 GLES 3.1，core profile 为 4.5（仅限 LWJGL3）
- `--gl32` 启用 GLES 3.2，core profile 为 4.6（仅限 LWJGL3）
- `--glErrors` 启用 GLProfiler 并记录任何 GL 错误（默认禁用）
- 注意 `--gl30`、`--gl31` 和 `--gl32` 这几个选项互斥；如果一个都不指定，则使用 [GLES 2.0](/wiki/graphics/opengl-es-support#desktop-windows-mac-linux)。

**Android：** 使用以下命令把测试安装到测试设备上：
```
./gradlew tests:gdx-tests-android:installDebug
```

**GWT：** 要通过 [`http://localhost:8080/index.html`](http://localhost:8080/index.html) 访问测试，请按如下方式启动本地服务器：
```
./gradlew tests:gdx-tests-gwt:superDev
```

GL30 模拟（WebGL 2.0）可以通过 URL 参数启用：[`http://localhost:8080/index.html?useGL30=true`](http://localhost:8080/index.html?useGL30=true)

<br/>

# 构建与发布
要在另一个项目中使用你对 libGDX 的本地修改，需要把它安装到私有仓库中。

## 版本号
建议的第一步是修改 `gradle.properties` 中的版本号，以避免与官方发布版本冲突。
一种做法是在当前版本号后追加一个数字，例如把 `version=1.12.0` 改成 `version=1.12.0.1`。

## 发布快照版本

你可以运行以下命令，把 libGDX 快照版本安装到本地 Maven 仓库：
```
./gradlew publishToMavenLocal
```
这会构建 libGDX 及所有核心组件，并把它们安装到本地 Maven 仓库，版本号为 gradle.properties 文件中声明的当前版本加上 SNAPSHOT 限定符（在我们的示例中是 `1.12.0.1-SNAPSHOT`）。要在你的项目中使用这个版本，请确保项目的 build.gradle 文件在顶部的 `repositories` 部分包含 `mavenLocal()`。

## 发布正式版本

发布相关的属性定义在 `publish.gradle` 文件中。要把正式版本（即不带 `-SNAPSHOT` 后缀的版本）安装到本地 Maven，你可以在根目录下创建一个名为 `override.gradle` 的文件来覆盖默认仓库，其内容如下
```
configure([
        project(":gdx"),
        project(":backends:gdx-backend-android"),
        project(":backends:gdx-backend-headless"),
        project(":backends:gdx-backend-lwjgl"),
        project(":backends:gdx-backend-lwjgl3"),
        project(":backends:gdx-backend-robovm"),
        project(":backends:gdx-backend-robovm-metalangle"),
        project(":backends:gdx-backend-gwt"),
        project(":extensions:gdx-box2d-parent"),
        project(":extensions:gdx-box2d-parent:gdx-box2d"),
        project(":extensions:gdx-box2d-parent:gdx-box2d-gwt"),
        project(":extensions:gdx-bullet"),
        project(":extensions:gdx-freetype"),
        project(":extensions:gdx-lwjgl3-angle"),
        project(":extensions:gdx-lwjgl3-glfw-awt-macos"),
        project(":extensions:gdx-tools")
]) {
    afterEvaluate { project ->
        publishing.repositories {
            // Add your repositories
        }

        gradle.taskGraph.whenReady {
            tasks.withType(Sign) {
                onlyIf { false }
            }
        }
    }
}
```

你可以运行以下命令，按照 `gradle.properties` 中声明的当前版本，构建 libGDX 正式版本并安装到本地 Maven 仓库（或你配置的任何私有仓库）：
```
gradlew.bat -PRELEASE publishToMavenLocal
```

## 本地项目依赖

如果你想把本地 libGDX 项目作为依赖引入，而又不必在每次修改后都重新发布，可以在你另一个项目的 `settings.gradle` 文件中添加 `includeBuild "<path-to-libgdx-repo>"`。

<br/>

# 原生库
如果你想自己构建 libGDX 的原生库，可以在[这里](/dev/natives/)找到说明。
