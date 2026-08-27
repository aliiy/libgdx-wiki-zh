---
title: Bullet 封装设置
---
Bullet 封装（`gdx-bullet` 扩展）目前支持桌面、Android 和 iOS。Bullet 封装暂不支持 GWT。

设置项目以使用 Bullet 封装的最简单方法是使用[设置工具](/wiki/start/project-generation)，其中提供了包含 gdx-bullet 扩展的选项。

手动将 Bullet 封装添加到 Gradle 项目的说明见[此处](/wiki/articles/dependency-management-with-gradle#bullet-gradle)。

如果不使用 Gradle，可以手动添加：
* 要在项目中使用 Bullet 物理，需要将 gdx-bullet.jar 添加到核心项目。也可以将 gdx-bullet 项目添加到主项目构建路径的项目中。
* 对于桌面项目，需要将 gdx-bullet-natives.jar 添加到库中。
* 对于 Android 项目，需要将 armeabi/libgdx-bullet.so 和 armeabi-v7a/libgdx-bullet.so 文件复制到 Android 项目的 libs 文件夹。
