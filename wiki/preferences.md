---
title: 偏好设置
---
偏好设置是为应用程序存储少量数据的简单方式，例如用户设置、小型游戏状态存档等。偏好设置类似哈希映射，以字符串作为键，以各种基本类型作为值。*目前，当应用程序在浏览器中运行时，Preferences 也是写入持久数据的唯一方式*。


## 获取 Preferences 实例
可以通过以下代码片段获取 Preferences：

```java
Preferences prefs = Gdx.app.getPreferences("My Preferences");
```

请注意，应用程序可以拥有多个偏好设置，只需为它们指定不同名称即可。

## 写入和读取值
修改偏好设置就像修改 Java Map 一样简单：

```java
prefs.putString("name", "Donald Duck");
String name = prefs.getString("name", "No name stored");

prefs.putBoolean("soundOn", true);
prefs.putInteger("highscore", 10);
```

请注意，getter 方法有带默认值和不带默认值两种形式。如果偏好设置中不存在指定键的值，就会返回默认值。

## 刷新
只有显式调用 `flush()` 方法，对 Preferences 实例的修改才会持久化。

```java
// 批量更新偏好设置
prefs.flush();
```

## 存储

在 Windows、Linux 和 OS X 上，偏好设置存储在用户主目录中的 xml 文件内。

| 操作系统    |      偏好设置存储位置    |
|:-----:|:------------------------------------:|
| Windows | `%UserProfile%/.prefs/My Preferences`|
| Linux 和 OS X | `~/.prefs/My Preferences`|

文件名就是传递给 `Gdx.app.getPreferences()` 的名称。

如果要为了测试而手动修改或删除它们，了解这一点会很有用。

在 Android 上使用系统的 [SharedPreferences](https://developer.android.com/reference/android/content/SharedPreferences) 类。这意味着应用更新后偏好设置仍会保留，但卸载应用时会被删除。

在 iOS 上，NSMutableDictionary 会写入指定文件。[参见 [javadocs](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Preferences.html)]
