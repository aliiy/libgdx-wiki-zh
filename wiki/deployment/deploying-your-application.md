---
title: 部署应用
---
游戏的部署方式因平台而异。本文说明将游戏部署到 libGDX 官方支持的各个平台所需的步骤：

* [部署到 Windows/Linux/Mac](#deploy-to-windowslinuxmac-os-x)
* [部署到 Android](#deploy-to-android)
* [部署到 iOS](#deploy-to-ios)
* [部署到 Web](#deploy-web)

# 部署到 Windows/Linux/Mac OS X
### 作为 JAR 文件
部署到 Windows/Linux/Mac 的最简单方式是创建可运行的 JAR 文件。可以使用以下控制台命令完成：
`./gradlew lwjgl3:dist`

如果遇到类似 `Unsupported class file major version 60` 的错误，说明你的 Java 版本（版本列表见[此处](https://stackoverflow.com/q/9170832)）不受当前 Gradle 版本支持。请安装较旧的 JDK 解决此问题。

生成的 JAR 文件位于 `lwjgl3/build/libs/` 文件夹中。它包含所有必要代码以及 android/assets 文件夹中的全部美术资源，可以双击运行，也可以在命令行中通过 `java -jar jar-file-name.jar` 运行。用户必须安装 JVM 才能运行。该 JAR 可在 Windows、Linux 和 Mac OS X 上运行！

### 其他（现代）部署方式
以 JAR 文件分发 Java 应用可能很不方便，也容易出现问题，因为不能假定每位用户都安装了正确的 JRE（甚至安装了任何 JRE）。其他部署方式例如：

* 分发 Java 应用的一种非常方便的方式是直接捆绑 JRE。如何操作请参阅[这篇文章](/wiki/deployment/bundling-a-jre)。（**这是推荐的应用分发方式！**）
* 通过 electron 可以将 HTML5 应用部署到桌面端，参见[这里](https://medium.com/@bschulte19e/how-to-deploy-a-libgdx-game-with-electron-3f1b37f0c26e)。
* GWT 应用也可以打包为 UWP 应用，参见[这里](https://web.archive.org/web/20200428040905/https://www.badlogicgames.com/forum/viewtopic.php?f=17&t=14766)。

# 部署到 Android
`gradlew android:assembleRelease`

这会在 `android/build/outputs/apk` 文件夹中创建未签名的 APK 文件。安装或发布此 APK 前，必须[对其签名](https://developer.android.com/studio/publish/app-signing)。上述命令构建的 APK 已经是 release 模式，只需按照 keytool 和 jarsigner 的步骤操作即可。可以在任何允许[从未知来源安装](https://developer.android.com/distribute/marketing-tools/alternative-distribution#unknown-sources)的 Android 设备上安装该 APK。

# 部署到 iOS
*本节假设你熟悉 iOS 应用的基本部署步骤。*

### 前置条件
要将 IPA 上传到应用商店，必须使用分发签名对其签名，并关联配置描述文件。
可以按照 Apple 的[应用商店分发指南](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/Introduction/Introduction.html)创建配置描述文件和证书。
完成后，必须在 iOS 项目的根 build.gradle 文件中定义它们。

```
project(":ios") {
    apply plugin: "java"
    apply plugin: "robovm"

    dependencies {
        // ...
    }

    robovm {
        iosSignIdentity = "[Signing identity name]"
        iosProvisioningProfile = "[provisioning profile name]"
        iosSkipSigning = false
        archs = "thumbv7:arm64"
    }
 }
```

- 配置描述文件名称可以在创建配置描述文件的开发者门户中找到。
- 签名身份名称可以在钥匙串的 “My Certificates” 下找到。

### 打包
要创建 IPA，请运行：

`gradlew ios:createIPA`

这会在 `ios/build/robovm` 文件夹中创建 IPA，你可以将它分发到 Apple App Store。
要上传应用，需要在 Mac App Store 使用 [Transporter](https://apps.apple.com/us/app/transporter/id1450874784)。

注意：从 iOS 11 开始，不能再简单地将图标放入 iOS 项目的 data 文件夹，而必须包含资源目录。
如果不包含资源目录，仍然可以提交应用，但之后会收到关于 `Missing Info.plist value - A value for the Info.plist key CFBundleIconName is missing in the bundle '...'. Apps that provide icons in the asset catalog must also provide this Info.plist key.` 的提示。要修复此问题，请按照[包含资源目录的说明](https://github.com/MobiVM/robovm/wiki/Howto-Create-an-Asset-Catalog-for-XCode-9-Appstore-Submission%3F)操作。

### 其他指南

部署到 iOS 相对直接，如果遇到困难，请参阅[这篇文章](https://medium.com/@bschulte19e/deploying-your-libgdx-game-to-ios-in-2020-4ddce8fff26c)。如果希望将 iOS 应用部署到 TestFlight，请查看[这篇文章](https://medium.com/dev-genius/deploying-your-libgdx-game-to-ios-testflight-163cada0696b)。

# 部署到 Web
`gradlew html:dist`

这会将应用编译为 Javascript，并将生成的 Javascript、HTML 和资源文件放入 `html/build/dist/` 文件夹。该文件夹的内容必须由 Web 服务器提供，例如 Apache 或 Nginx。可以像处理其他静态 HTML/Javascript 网站一样处理这些内容，不涉及 Java 或 Java Applet！

运行结果时，可能会遇到类似 `Couldn't find Type for class ...` 的错误。要修复此问题，请参阅 Wiki 页面[反射](/wiki/utils/reflection)，并包含所需的类/包。

有关 HTML5/GWT 的更多细节，请观看[这个视频](https://youtu.be/I_85usDvJvQ)。

安装 Python 后，可以在 `html/build/dist` 文件夹中执行以下命令测试分发结果：

**Python 2.x**

`python -m SimpleHTTPServer`

**Python 3.x**

`python -m http.server 8000`

然后可以在浏览器中打开 [http://localhost:8000](http://localhost:8000)，查看项目运行效果。

使用 Node.js 时，执行 `npm install http-server -g`，然后运行 `http-server html/build/dist`，并在 <http://localhost:8080> 浏览。[文档](https://github.com/indexzero/http-server)

使用 PHP 时，可以执行 `php -S localhost:8000`，并在 <http://localhost:8080> 浏览。[文档](http://php.net/manual/en/features.commandline.webserver.php)
