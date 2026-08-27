---
title: 在 libGDX 中使用 Firebase
---
如果你有兴趣在 libGDX 中使用 [Firebase](https://firebase.google.com)，可以参考 mk-5 的 [gdx-fireapp](https://github.com/mk-5/gdx-fireapp)。


## 设置
将以下依赖添加到 `build.gradle` 文件中对应的位置。更多信息请参阅项目的完整 wiki：[Android 指南](https://github.com/mk-5/gdx-fireapp/wiki/Android-guide)、[iOS 指南](https://github.com/mk-5/gdx-fireapp/wiki/iOS-Guide)、[GWT 指南](https://github.com/mk-5/gdx-fireapp/wiki/GWT-guide)。

**Core:**
```
implementation "pl.mk5.gdx-fireapp:gdx-fireapp-core:$gdxFireappVersion"
```

**Android:**
```
implementation "pl.mk5.gdx-fireapp:gdx-fireapp-android:$gdxFireappVersion"
```

**iOS:**
```
implementation "pl.mk5.gdx-fireapp:gdx-fireapp-ios:$gdxFireappVersion"
```

**GWT:**
```
implementation "pl.mk5.gdx-fireapp:gdx-fireapp-html:$gdxFireappVersion"
```

## 基础
Gdx-firebase 是 libGDX 应用与 Firebase SDK 之间的桥梁，涵盖了 Firebase 的功能。因此，如果你了解 Firebase SDK，使用 gdx-firebase 的 API 应该会很直观。

要初始化该库，只需在应用的初始化代码中加入这一行：

```java
GdxFIRApp.inst().configure();
```

完成这一步后，Firebase Analytics 应该就会开始工作。


## 示例
项目 wiki 提供了各种示例，可在[这里](https://github.com/mk-5/gdx-fireapp/wiki/Examples)查看。
