---
title: 捆绑 JRE
---
Java 应用需要 Java 运行时环境才能运行。通常由用户安装，并且希望他们运行应用时已经可用。不幸的是，用户可能没有安装 Java，而不同 JRE 之间的差异也可能导致应用出现问题。这些问题用户很难描述，更难自行修复。此外，你可能至少要求某个特定版本的 JRE。

解决方案是将 JRE 与应用一起捆绑。这样你能确切知道用户运行的环境，用户遇到的问题也会更少，并且无需自行安装 JVM。

## 打包
有许多工具可以用来捆绑 JRE：

### [Construo](https://github.com/fourlastor-alexandria/construo?tab=readme-ov-file#construo)
这是在 Windows、Linux 和 Mac 上最小化并打包 libGDX 应用以进行部署的现代方式。只需调用目标平台对应的 Gradle 命令即可。这些命令可以在任意操作系统上调用：

**Mac M1** lwjgl3:packageMacM1<br>
**Mac OSX** lwjgl3:packageMacX64<br>
**Linux** lwjgl3:packageLinuxX64<br>
**Windows** lwjgl3:packageWinX64<br>

这会在 `lwjgl3/build/construo/dist` 中创建一个 zip 文件，其中包含游戏和目标平台的最小化 JRE。参见 GDX-Liftoff 视频中的[这一节](https://www.youtube.com/watch?v=VF6N_X_oWr0&t=1088s)。

### [Graal Native Image](https://www.graalvm.org/latest/reference-manual/native-image/)
Graal Native Image 可以提前编译 Java 代码，生成本机可执行文件。这不同于必须随游戏捆绑 Java JRE 的其他技术。本机可执行文件更小、运行所需资源更少，几乎可以瞬间启动。启用它需要在 gradle.properties 文件中设置：

```
enableGraalNative=true
```

还必须安装 Graal JDK。请注意，反射和资源使用方面的要求更高，通常不能开箱即用。更多信息请参阅[官方文档](https://graalvm.github.io/native-build-tools/latest/gradle-plugin.html)。

### [Packr](https://github.com/libgdx/packr)
由 libGDX 团队创建和维护的打包工具。如果想使用它，请查看[仓库](https://github.com/libgdx/packr#usage)。

### [Parcl](https://github.com/mini2Dx/parcl)
执行类似 launch4j 操作的 Gradle 插件。使用说明请参阅其 [README](https://github.com/mini2Dx/parcl#how-to-use)。

### [jpackage](https://docs.oracle.com/en/java/javase/14/jpackage/packaging-overview.html#GUID-C1027043-587D-418D-8188-EF8F44A4C06A)

jpackage 是由 [JEP-343](https://openjdk.java.net/jeps/343) 引入的工具，可在 Windows、MacOS 和 Linux 上提供本机打包选项。它可以创建通过内置 JRE 启动捆绑应用的 EXE。一个明显缺点是，必须直接在目标平台（Windows、Linux、Mac）上运行它，才能创建适用于该平台用户的可执行文件。

有关使用方法，请参阅[这份指南](https://github.com/raeleus/skin-composer/wiki/libGDX-and-JPackage)。视频版本见[此处](https://www.youtube.com/watch?v=R7CMXeQ11GM)。请注意，这些指南已经过时，不再推荐。

### [Jpackage Gradle Plugin](https://github.com/petr-panteleyev/jpackage-gradle-plugin)
按照现代 Gradle 标准方便地封装 jpackage 的 Gradle 插件。使用说明请参阅其 [README](https://github.com/petr-panteleyev/jpackage-gradle-plugin/blob/master/README.md)。

### [launch4j](http://launch4j.sourceforge.net/)
_-- 似乎已不再维护 --_

## MacOS 特性

如果也计划部署到 MacOS，[公证](https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution)（MacOS 10.15+）可能会成为问题。有关如何为 libGDX 应用进行公证，请参阅[此处](https://www.joelotter.com/2020/08/14/macos-java-notarization.html)。

## 减小体积

可以从 JRE 中删除一些文件和类来减小体积。下面列出的是 Windows JRE 中可以删除的文件。其他平台非常相似，但某些平台可能需要而另一些平台不需要某些类（例如，在 Linux 上使用 java.util.preferences 需要 XML 类）。此列表保留了 Swing；如果不需要 Swing，还可以进一步减小体积。

```
**.diz
**.exe except javaw.exe
bin\client\
lib\applet\
lib\charsets.jar
lib\ext\localedata.jar
lib\management\
lib\management-agent.jar
lib\zi\
lib\rt.jar\com\sun\org\
lib\rt.jar\com\sun\xml\
lib\rt.jar\com\sun\corba\
lib\rt.jar\com\sun\media\
lib\rt.jar\com\sun\jndi\
lib\rt.jar\com\sun\imageio\
lib\rt.jar\com\sun\jmx\
lib\rt.jar\com\sun\rowset\
lib\rt.jar\com\sun\java\util\
lib\rt.jar\javax\imageio\
lib\rt.jar\javax\management\
lib\rt.jar\javax\print\
lib\rt.jar\javax\naming\
lib\rt.jar\javax\sound\
lib\rt.jar\javax\sql\
lib\rt.jar\javax\xml\
lib\rt.jar\javax\swing\plaf\nimbus\
lib\rt.jar\javax\swing\text\html\
lib\rt.jar\org\
lib\rt.jar\sun\applet\
lib\rt.jar\sun\management\
lib\rt.jar\sun\rmi\
lib\rt.jar\sun\security\jgss\
lib\rt.jar\sun\security\krb5\
lib\rt.jar\sun\security\tools\
lib\resources.jar\com\sun\corba\
lib\resources.jar\com\sun\imageio\
lib\resources.jar\com\sun\jndi\
lib\resources.jar\com\sun\org\
lib\resources.jar\com\sun\rowset\
lib\resources.jar\com\sun\servicetag\
lib\resources.jar\com\sun\xml\
lib\jsse.jar\sun\security\ssl\
```

制作此列表时，我按大小从大到小检查了文件和 JAR，然后删除看起来不需要的最大文件，并运行应用以确保一切仍然正常。

此列表可将 JRE 体积减小到约 36MB。请注意，为了更快启动，JRE JAR 未压缩。将整个 JRE 压缩后，体积约为 13.5MB。如果还从 rt.jar 中删除 Swing 包，压缩后的体积可降至约 9.8MB。
