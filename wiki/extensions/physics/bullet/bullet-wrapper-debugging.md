---
title: Bullet 封装调试
---
> 请确保使用最新 nightly（而非 stable），或直接使用最新的 libGDX 代码（后一种情况下也要记得手动更新 natives）。你遇到的问题可能已经得到解决。

使用 Bullet 封装时遇到问题，有时很难找到原因。例如，可能会看到类似以下的错误：
```
# A fatal error has been detected by the Java Runtime Environment:
#
#  EXCEPTION_ACCESS_VIOLATION (0xc0000005) at pc=0x000000006a49a450, pid=4040, tid=3912
#
# JRE version: Java(TM) SE Runtime Environment (8.0_05-b13) (build 1.8.0_05-b13)
# Java VM: Java HotSpot(TM) 64-Bit Server VM (25.5-b02 mixed mode windows-amd64 compressed oops)
# Problematic frame:
# C  [gdx-bullet64.dll+0x19a450]
#
# Failed to write core dump. Minidumps are not enabled by default on client versions of Windows
#
# An error report file with more information is saved as:
# C:\Xoppa\code\libgdx\tests\gdx-tests-lwjgl\hs_err_pid4040.log
#
# If you would like to submit a bug report, please visit:
#   http://bugreport.sun.com/bugreport/crash.jsp
# The crash happened outside the Java Virtual Machine in native code.
# See problematic frame for where to report the bug.
#
AL lib: (EE) alc_cleanup: 1 device not closed
```
查看它生成的日志文件，会发现其中包含更多信息，例如 Java 调用的堆栈跟踪。但它不会提供太多关于 Bullet 封装内部实际出错原因的有用信息。这是因为封装会将 Java 调用委托给本机（C++）库。默认情况下，该库（例如 Windows 上的 `.dll` 文件）不包含调试信息。

可以带调试信息编译 Bullet 封装，甚至跟踪进入 C++ 封装和 Bullet 代码。不过，对大多数问题来说并不需要这样做。检查 Java 代码通常就能找到常见问题的原因。

> Bullet 封装最常见的问题是对象仍然需要使用时没有正确维护引用。这会导致垃圾回收器销毁本机（C++）对象，使应用崩溃。由于无法控制垃圾回收器，这个问题在不同设备上出现的频率可能不同。更多信息请参阅[创建和销毁对象](/wiki/extensions/physics/bullet/bullet-wrapper-using-the-wrapper#creating-and-destroying-objects)部分。

在 Windows 上调试
-----
要调试本机 C++ 代码，必须构建带调试信息的 bullet.dll。

### 获取源代码
为此需要 Bullet 封装的源代码。请前往 [libGDX github 仓库](https://github.com/libgdx/libgdx)，将整个仓库下载为 .zip 文件，或通过 git 克隆（`git clone https://github.com/libgdx/libgdx.git`）。请记住，正在调试的 Java 项目必须使用与编译 gdx-bullet 完全相同的 libGDX 版本（最好是最新的 SNAPSHOT 版本），否则可能由于导出不匹配等原因到处抛出令人头疼的底层 Java 异常。

### 获取编译器/IDE
此外还需要用于调试的 IDE，以及用于构建 dll 的编译器。*Microsoft Visual Studio Express 2013* 同时提供了这两者。可以[在此处](https://visualstudio.microsoft.com/downloads/)下载安装镜像。下载后，需要将镜像刻录到 CD，或通过虚拟 CD 驱动器挂载（例如使用 Daemon Tools）。*以下步骤只有在 VS Express 2013 上才能开箱即用。*例如，要在 VS 2010 SP1 上构建，需要在所有项目文件中将 `ToolsVersion="12.0"` 改为 `ToolsVersion="4.0"`，并将 `<PlatformToolset>v120</PlatformToolset>` 改为 `<PlatformToolset>v100</PlatformToolset>`。代码*应该*能在任何较新的构建工具集中无错误编译（截至 2014 年 11 月已在 VS 2010 SP1 上验证），但具体情况可能有所不同。

### 构建调试 .dll
这很简单，因为源代码中包含一个应该能够开箱即用的 Visual Studio 项目（.sln“解决方案”）。它位于 libGDX 仓库的 `libgdx\extensions\gdx-bullet\jni\vs\gdxBullet\gdxBullet.sln`。

![images/Iqyi9kf.png](/assets/wiki/images/Iqyi9kf.png)

使用 Visual Studio 打开解决方案后，应能看到 6 个项目。最重要的是 `gdxBullet`。需要在顶部工具栏选择正确的构建配置。请确保选择 `Debug` 以及 `Win32` 或 `x64`。平台取决于运行应用所使用的 JVM 版本，而不是 Windows 版本。在 64 位 Windows 系统上运行 32 位 Java 仍然可行，而且很常见。

现在在解决方案资源管理器中右键点击 `gdxBullet` 项目并选择“Build”。这会构建 `gdxBullet.dll`，可能需要几分钟。

![images/jdxPRUJ.png](/assets/wiki/images/jdxPRUJ.png)

### 加载正确的 DLL
通常需要调用 `Bullet.init()` 加载运行 Bullet 所需的本机库。由于不希望加载不含调试信息的默认本机库，因此必须手动加载新创建的 `gdxBullet.dll`。可以使用以下代码片段完成此操作，只需将 `customDesktopLib` 字符串替换为实际路径，然后在通常调用 `Bullet.init()` 的位置（例如 `create` 方法中）调用 `initBullet()`。

	// 设置为库文件路径，以便桌面端使用它而非默认库。
	private final static String customDesktopLib = "C:\\......\\libgdx\\extensions\\gdx-bullet\\jni\\vs\\gdxBullet\\x64\\Debug\\gdxBullet.dll";
	private final static boolean debugBullet = true;

	static void initBullet() {
		// 使用 Bullet 前需要先初始化。
		if (Gdx.app.getType() == ApplicationType.Desktop && debugBullet) {
			System.load(customDesktopLib);
		} else {
			Bullet.init();
		}
		Gdx.app.log("Bullet", "Version = " + LinearMath.btGetVersion());
	}

### 附加调试器
现在可以启动应用并附加 C++ 调试器了。首先启动 Java 应用。可以在应用启动位置设置断点，然后以调试模式运行，这样会有足够时间附加 C++ 调试器。具体做法是切换到 Visual Studio，选择 `Debug -> Attach to Process...`。

![images/MrB0AYF.png](/assets/wiki/images/MrB0AYF.png)

然后在可用进程列表中选择应用对应的 `javaw.exe` 进程，并点击“Attach”按钮附加调试器。

*注意：使用 MS VC++ 2010 Express 时，必须先启用 Tools->Settings->Expert Settings，才能看到附加进程的选项。*

### 调试
要测试设置是否生效，可以在 `btDiscreteDynamicsWorld.stepSimulation` 处添加断点。包含该代码的文件位于 `gdxBullet -> Source Files -> BulletDynamics -> Dynamics -> btDiscreteDynamicsWorld.cpp`。

![images/Z5sAvDh.png](/assets/wiki/images/Z5sAvDh.png)

搜索 `int btDiscreteDynamicsWorld::stepSimulation( btScalar timeStep,int maxSubSteps, btScalar fixedTimeStep)`，然后双击该方法中任意代码左侧的区域添加断点。

![images/uzMOe53.png](/assets/wiki/images/uzMOe53.png)

如果应用在 Java 侧断点处暂停，现在可以移除该断点并继续进程。当 Java 代码调用 `btDiscreteDynamicsWorld.stepSimulation` 时，切换到 Visual Studio，应该就能看到调试器已中断，并可以逐步执行代码。
