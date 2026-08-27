---
title: ProGuard、DexGuard 与 libGDX
---

[ProGuard](https://www.guardsquare.com/proguard) 和较新的 [R8](https://developer.android.com/studio/build/shrink-code) 是用于 Java 和 Android 应用的优化与混淆工具。你可以在 libGDX 应用中使用这些工具，提高第三方反编译应用的难度、减小应用体积，甚至通过内联等提前优化来提升运行速度。

更新：GDX-Liftoff 已在所有新项目中内置 ProGuard 配置。请查看 Android 子项目中的 proguard-rules.pro 和 project.properties。否则，请继续按照以下说明操作。

以下配置文件可以让 libGDX 应用与 ProGuard/R8 配合工作：

```
# To enable ProGuard in your project, edit project.properties
# to define the proguard.config property as described in that file.
#
# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in ${sdk.dir}/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the ProGuard
# include property in project.properties.
#
# For more details, see
#   https://developer.android.com/studio/build/shrink-code

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

-verbose

-dontwarn com.badlogic.gdx.backends.android.AndroidFragmentApplication

# Required if using Gdx-Controllers extension
-keep class com.badlogic.gdx.controllers.android.AndroidControllers

# Required if using Box2D extension
-keepclassmembers class com.badlogic.gdx.physics.box2d.World {
   boolean contactFilter(long, long);
   void    beginContact(long);
   void    endContact(long);
   boolean getUseDefaultContactFilter();
   void    preSolve(long, long);
   void    postSolve(long, long);
   boolean reportFixture(long);
   float   reportRayFixture(long, float, float, float, float, float);
}
```

请注意，你还必须自行保留通过反射访问的所有类！更多详情请参阅 [ProGuard/R8 文档](https://developer.android.com/studio/build/shrink-code)。

要在 Release 构建中对 Android 项目应用 ProGuard/R8，需要将以下配置添加到 `build.gradle` 文件（即项目 `android/` 文件夹中的文件，而不是根目录的 `build.gradle`）：


```gradle
buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
```
