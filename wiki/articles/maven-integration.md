---
title: Maven 集成
---

可以使用 Maven 设置项目，但跨平台支持受到很大限制，目前已知只有桌面端可用。libGDX 社区尚未进一步测试或使用此方案，出现问题时也没有官方支持。
{: .notice--warning}


## 简介

当前自动化 LibGDX 设置工具会创建 Gradle 项目。如果只想为桌面端设置 Maven 项目，只需将以下依赖添加到项目的 pom.xml：

```xml
  <dependency>
          <groupId>com.badlogicgames.gdx</groupId>
          <artifactId>gdx</artifactId>
          <version>1.12.1</version>
      </dependency>
        <dependency>
          <groupId>com.badlogicgames.gdx</groupId>
          <artifactId>gdx-backend-lwjgl3</artifactId>
          <version>1.12.1</version>
      </dependency>
      <dependency>
          <groupId>com.badlogicgames.gdx</groupId>
          <artifactId>gdx-platform</artifactId>
          <version>1.12.1</version>
          <classifier>natives-desktop</classifier>
      </dependency>
```

这样就具备了启动 Lwjgl3Application 所需的一切，只需提供自己的 ApplicationAdapter 实现。

下面介绍的旧方法可能提供一些跨平台能力，但此时改用 Gradle 构建系统可能更顺利。

## 使用 Archetype

通常，设置 libGDX 并不简单，因为它：

   * 包含原生库
   * 部署到 GWT
   * 部署到 Android

为处理这些问题，libGDX 使用以下 Maven 插件：

  * [GWT Maven plugin，版本 2.5.0](https://gwt-maven-plugin.github.io/gwt-maven-plugin/)，用于编译和打包 GWT 项目。
  * [Maven native dependencies plugin](https://code.google.com/p/mavennatives/)，用于将原生库复制到适当位置。
  * [Maven Android plugin](https://code.google.com/p/maven-android-plugin/)，用于编译和打包 Android 项目。

为简化这些工作，我们提供了一个 Maven archetype，用于生成多模块 Maven 项目。

## Maven Archetype
目前任何仓库中都找不到该 Maven archetype。你可以从 [https://github.com/libgdx/libgdx-maven-archetype](https://github.com/libgdx/libgdx-maven-archetype) 获取，然后在 shell 中自行编译并安装到本地 Maven 仓库：

```
git clone git://github.com/libgdx/libgdx-maven-archetype.git
cd libgdx-maven-archetype
mvn install
```

要调用 archetype，请执行：

```
mvn archetype:generate -DarchetypeGroupId=com.badlogic.gdx -DarchetypeArtifactId=gdx-archetype -DarchetypeVersion=1.2.0 -DgroupId=com.badlogic.test -DartifactId=test -Dversion=1.0-SNAPSHOT -Dpackage=com.badlogic.test -DJavaGameClassName=Test
```

前三个参数指定 archetype，包括 group id com.badlogic.gdx、artifact id gdx-archetype 和版本（当前为 1.0-SNAPSHOT）。

接下来的参数指定项目属性。

   * groupId：项目的 group id
   * artifactId：项目的 artifact id
   * version：项目的版本
   * package：项目的主 package
  * JavaGameClassName：ApplicationListener 类的名称，也是各平台启动类的前缀，例如 MyClassDesktop、MyClassAndroid 等。

使用上述参数后，会得到以下项目结构（后续章节将使用此示例）：

```
    test/       <-- 基础目录
       core/    <-- 包含应用核心代码
       desktop/ <-- 桌面启动类和 assets
       android/ <-- Android 启动类
       html/    <-- HTML 启动类
       ios/     <- 存根，目前无法工作
```

core 项目包含应用代码。desktop 项目包含所有其他项目共享的 assets 文件夹以及桌面启动类。Android 项目包含 Android 启动代码，并依赖 core 项目。HTML 项目也是如此。iOS 项目目前只是存根，尚不能工作。

## 构建与部署
使用 Maven 为各种后端构建和部署应用很简单。

### 桌面端
要为桌面端创建可运行的 jar 文件，请运行：

```
mvn -Pdesktop package
```

这会在 test/desktop/target 文件夹中创建名为 test-desktop-1.0-SNAPSHOT-jar-with-dependencies.jar 的文件，其中包含所有必要的依赖、资源以及指定主类的 manifest 文件。可以通过以下命令运行该文件：

```
java -jar test-desktop-1.0-SNAPSHOT-jar-with-dependencies.jar
```

### Android
要为 Android 创建未签名 APK，请运行：

```
mvn -Pandroid package
```

这会在 test/android/target 文件夹中创建名为 test-android-1.0-SNAPSHOT.apk 的文件。要将 apk 安装到已连接的设备或模拟器，请运行：

```
mvn -Pandroid install
```

有关 Android goal 的更多信息，请参阅 [Maven Android plugin](https://code.google.com/p/maven-android-plugin/)。

### HTML5/GWT
要将 HTML5 项目编译为 JavaScript，请运行：

```
mvn -Phtml package
```

最终结果位于 target/ 文件夹中。你可以使用生成的 .war 文件并将其部署到 Jetty/Tomcat，也可以将 HTML/target/test-html-1.0-SNAPSHOT/ 文件夹的内容复制到 Web 服务器可提供服务的位置（如果操作系统支持，创建符号链接会更好）。war 文件或文件夹包含所有编译后的 JavaScript 代码、index HTML 文件和资源。

要运行和测试 HTML5 项目，请运行：
```
mvn -Phtml install
```

然后在浏览器中打开 [http://127.0.0.1:8080/index.html](http://127.0.0.1:8080/index.html)。

## IDE 集成
Eclipse、IntelliJ IDEA 和 NetBeans 都以某种形式支持 Maven 项目。该 archetype 做了大量工作，让 libGDX 项目可以在 Eclipse 和 IntelliJ IDEA 中使用。本文撰写时尚不支持 NetBeans。

Maven 与 IDE 无关，但 GWT 和 Android 插件并非如此。Eclipse 插件解释 GWT 和 Android 项目 Maven 配置的方式不同于 IntelliJ IDEA。以下章节介绍如何使用 libGDX archetype 创建项目后，将项目导入这两种 IDE。

### Eclipse
导入项目之前，需要安装以下 Eclipse 插件：

   * [m2e](https://www.eclipse.org/m2e/)，在全新安装的 Eclipse（Java 和 Java EE 版本）中通常已经提供。它为 Eclipse 提供基本的 Maven 支持。
   * [m2e-android](https://rgladwell.github.io/m2e-android/) 为 Eclipse 中的 Android 项目提供 Maven 集成。
   * [Google Web Toolkit](https://developers.google.com/web-toolkit)，允许你开发 GWT 项目的 Eclipse 插件。

安装插件后，可以通过 *File -> Import... -> Maven -> Existing Maven Projects* 导入 Maven libGDX 项目。这会将父 pom 以及 core、desktop、android 和 html 项目作为项目导入。

*注意*，Eclipse 可能无法将 HTML 项目识别为 GWT 项目。要修复此问题，请右键点击项目，进入 *Properties -> Google -> Web Toolkit*，勾选“Use Google Web Toolkit”。然后进入 *Properties -> Google -> Web Application*，勾选“This project has a WAR directory”，指定 `target/webapp`，最后勾选“Launch and deploy from this directory”。

从此以后，就可以像通过 gdx-setup-ui 设置项目那样运行和调试。

如果修改了 assets 中的任何内容，需要再次运行 "mvn -Phtml package"，并在 Eclipse 中刷新 html 项目。

### IntelliJ IDEA
开始前，请确保 IntelliJ IDEA 知道 Maven 的安装位置。转到 *File -> Settings*，在对话框的树形菜单中选择 Maven，并指定 Maven 安装目录。

通过 archetype 创建项目后，可以将其导入 IntelliJ IDEA。转到 *File -> Open Project*，然后导航到项目根目录。

项目加载后，需要启用配置文件。打开 Maven Project 视图并勾选 desktop、android 和 HTML 这三个配置文件。

![images/maven1.png](/assets/wiki/images/maven1.png)

要运行桌面项目，请通过 *Run -> Edit Configurations* 创建新配置。点击左上角的 + 按钮创建配置并选择 Application，将 Main class 设为桌面启动类，并选择 desktop 模块。

![images/maven2.png](/assets/wiki/images/maven2.png)

启动此配置即可在桌面端运行应用。

要运行 android 项目，请创建新配置，这次在创建配置时选择 Android Application。选择 Android 模块，勾选 *Run Maven Goal*，然后点击右侧的 *...* 按钮。在对话框中选择 Android 项目，再选择 Lifecycle，并从 goal 列表中选择 *package*。还可以将 *Target Device* 设为 *Show chooser dialog*，这样系统会询问你要部署到设备还是模拟器。

![images/maven3.png](/assets/wiki/images/maven3.png)

启动此配置即可在 Android 设备或模拟器上运行应用。
