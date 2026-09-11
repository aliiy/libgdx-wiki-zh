---
title: "导入并运行项目"
description: "将 libGDX 项目导入所选 IDE 需要完成几个步骤。"
redirect_from:
  - /dev/import-and-running/
  - /dev/import_and_running/
---

接下来需要将项目导入 IDE。

{% include setup_flowchart.html current='2' %}


# 导入项目
如果刚刚在 gdx-liftoff 中生成项目，可以点击“Open in IntelliJ Idea”立即开始。否则，请继续以下步骤：

1. 在 **IntelliJ IDEA 或 Android Studio** 中，可以打开 `build.gradle` 文件并选择“Open as Project”开始。

   在 **Eclipse** 中，选择 `File -> Import... -> Gradle -> Existing Gradle Project`（确保刚生成的项目不在工作区内，且工作区中没有同名项目）。

   在 **NetBeans** 中，选择 `File -> Open Project`。

2. 初次导入后，如果部分依赖尚未下载，可能需要刷新 Gradle 项目。

   在 **IntelliJ IDEA/Android Studio** 中，`Reimport all Gradle projects` 按钮是 Gradle 工具窗口左上角的循环箭头图标；可以通过 `View -> Tool Windows -> Gradle` 打开该窗口。

   在 **Eclipse** 中右键点击项目，选择 `Gradle -> Refresh Gradle Project`。

<br/>

# 运行项目
如果要运行刚导入的项目，需要根据 IDE 和目标平台执行不同步骤。
## 桌面平台
### IDEA/Android Studio：
1. 展开窗口右侧的 Gradle 选项卡。<br/>
2. 展开项目任务，然后选择：`lwjgl3 -> Tasks -> application -> run`：<br/>
  ![](/assets/images/dev/idea/3.png)

    **在 Android Studio 4.2 中**，任务默认不再显示。进入 `Settings -> Experimental`，勾选 `Configure all Gradle tasks during Gradle Sync`，然后通过 `File -> Sync Project with Gradle Files` 同步项目：<br/>
  ![](/assets/images/dev/idea/4.png)
   {: .notice--primary}

<b>或者</b>，可以创建运行配置：
1. 右键点击 Lwjgl3Launcher 类。
2. 选择“Run Lwjgl3Launcher.main()”。这应该会因缺少资源而失败，因为需要先连接 assets 文件夹：<br/>
  ![](/assets/images/dev/idea/5.png)
3. 打开 Run Configurations：<br/>
  ![](/assets/images/dev/idea/0.png)
4. 编辑刚才通过运行 lwjgl3 项目创建的 Run Configuration，将工作目录设置为 `assets` 文件夹：<br/>
  ![](/assets/images/dev/idea/1.png)

    在 **macOS** 上，LWJGL3 项目还需要额外执行一步：在 Run Configuration 中将 VM Options 设置为 `-XstartOnFirstThread`，或者在 `main()` 方法开头添加以下实验性代码：`Lwjgl3ApplicationConfiguration.useGlfwAsync();` 更多信息请查看[这里](/news/2021/07/devlog-7-lwjgl3#do-i-need-to-do-anything-else)。
    {: .notice--warning}
5. 使用运行按钮运行应用程序。

### Eclipse：

1. 双击 `Gradle Tasks` 下的 `projectname-lwjgl3 -> application -> run` 任务。
  ![](/assets/images/dev/eclipse/4.png)

    如果看不到该窗口，请通过 `Window -> Show View -> Other -> Gradle -> Gradle Tasks` 显示它。
    {: .notice--warning}

<b>或者</b>，可以创建运行配置：
1. 右键点击 lwjgl3 项目 -> Run as -> Run Configurations...
2. 在右侧选择 Java Application：<br/>
  ![](/assets/images/dev/eclipse/3.png)
3. 点击左上角图标创建新的运行配置：
  ![](/assets/images/dev/eclipse/0.png)
4. 在 Main class 中选择 `Lwjgl3Launcher` 类。
5. 然后点击 Arguments 选项卡。
6. 在底部的“Working directory”下选择“Other” -> Workspace...
  ![](/assets/images/dev/eclipse/1.png)

   在 **macOS** 上，LWJGL3 项目还需要额外执行一步：在 Run Configuration 中将 VM Options 设置为 `-XstartOnFirstThread`，或者在 `main()` 方法中添加以下实验性代码：`Lwjgl3ApplicationConfiguration.useGlfwAsync();` 更多信息请查看[这里](/news/2021/07/devlog-7-lwjgl3#do-i-need-to-do-anything-else)。
   {: .notice--warning}

7. 然后选择位于 `assets` 中的资源文件夹。

### NetBeans：
右键点击 lwjgl3 项目 -> Run

<br/>

## Android 平台
- **IDEA/Android Studio：**右键点击 AndroidLauncher -> Run AndroidLauncher
- **Eclipse：**右键点击 Android 项目 -> Run As -> AndroidApplication
- **NetBeans：**右键点击 Android 项目 -> Run As -> AndroidApplication

<br/>

## iOS 平台
### IDEA/Android Studio
1. 打开 Run/Debug Configurations。
2. 为 RoboVM iOS 应用创建新的运行配置。

    ![](/assets/images/dev/idea/2.png)

3. 选择 provisioning profile 和模拟器/设备目标。

   注意：arm64 模拟器默认无法工作。请使用 x86_64，或改用 MetalANGLE RoboVM 后端（"com.badlogicgames.gdx:gdx-backend-robovm-metalangle:$gdxVersion"）。
   {: .notice--warning}
4. 运行创建的运行配置。

有关 RoboVM IntelliJ IDEA plugin 的使用和配置，请参阅[文档](https://mobivm.github.io)。

### Eclipse
- 右键点击 iOS RoboVM 项目 > Run As > 选择所需的 RoboVM runner

![](/assets/images/dev/eclipse/2.png)

有关 RoboVM IntelliJ IDEA plugin 的使用和配置，请参阅[文档](https://mobivm.github.io)。

<br/>

## HTML 平台
HTML 最适合通过命令行运行。如果熟悉 GWT，也可以在喜欢的 IDE 中手动设置；但推荐使用终端或命令提示符。

HTML 目标可以在 **Super Dev** 模式下运行，从而即时重新编译，并在浏览器中调试应用程序。

为此，请打开喜欢的 shell 或终端，切换到项目目录，然后调用相应的 gradle 任务：

```
./gradlew html:superDev
```

**在 Unix 上：**如果出现 permission denied 错误，请为 gradlew 文件设置执行标志：`chmod +x gradlew`
{: .notice--primary}

你应该会看到大量文本滚过；如果一切顺利，末尾会出现以下内容：

![](/assets/images/dev/html/0.png)

随后可以访问 [`http://localhost:8080/index.html`](http://localhost:8080/index.html)，查看正在运行的应用程序，其中包含重新编译按钮。

有关使用 SuperDev 进行配置和调试的更多信息，请查看 [GWT documentation](http://www.gwtproject.org/articles/superdevmode.html)。

<br/>

## 命令行
所有目标都可以通过命令行界面运行和部署。

**桌面：**
```
./gradlew lwjgl3:run
```

**Android:**
```
./gradlew android:installDebug android:run
```

在通过命令行执行 Android 操作前，`ANDROID_HOME` 环境变量必须指向有效的 Android SDK。Windows 使用：`set ANDROID_HOME=​C:/Path/To/Your/Android/Sdk`；Linux 和 macOS 使用：`export ANDROID_HOME=​/Path/To/Your/Android/Sdk`。也可以创建名为“local.properties”的文件，内容如下：`sdk.dir /Path/To/Your/Android/Sdk`。

**iOS:**
```
./gradlew ios:launchIPhoneSimulator
```

**HTML:**
```
./gradlew html:superDev
```

然后访问 [`http://localhost:8080/index.html`](http://localhost:8080/index.html)。

### Gradle 任务失败怎么办？
如果每次调用 Gradle 时构建或刷新都会失败，可以再次运行相同命令，并添加 `--debug` 参数，例如：

```
./gradlew lwjgl3:run --debug
```

这样会提供 stacktrace，帮助你更好地了解 Gradle 失败的原因。


<br/>

# 接下来做什么？
完成设置后，就可以开始真正编写代码了。请阅读[一个简单的游戏](/wiki/start/a-simple-game)，按照步骤完成第一个游戏。
