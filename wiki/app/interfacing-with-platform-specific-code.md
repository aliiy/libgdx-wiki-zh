---
title: 与平台特定代码交互
---
很多时候需要访问平台特定的 API，例如仅 Android/iOS/桌面端提供的广告服务或排行榜功能。可以通过公共 API 接口定义特定实现来完成这一点。

以下示例尝试使用一个仅 Android 提供的简单排行榜 API。对于其他目标平台，我们只需记录调用或提供模拟返回值。

## 公共接口

第一步是在**核心项目**中以接口的形式创建 API 抽象：

```java
public interface Leaderboard {
   public void submitScore(String user, int score);
}
```

接下来为每个平台创建具体实现，并将其放入相应项目中。

## Android 实现

在 Android 上，我们希望代码调用 Google Play API，它提供 `LeaderboardsClient#submitScore(String leaderboardId, long score);` 方法。

因此，在**Android 项目**中，需要实现 `Leaderboard` 接口，并按如下方式调用平台特定代码：

```java
/** Android implementation, can access PlayGames directly **/
public class AndroidLeaderboard implements Leaderboard {

   public void submitScore(String user, int score) {
      // Ignore the user name, because Google Play reports the score for the currently signed-in player
      // See https://developers.google.com/games/services/android/signin for more information on this
      PlayGames.getLeaderboardsClient(activity).submitScore(getString(R.string.leaderboard_id), score);
   }
}
```

## 桌面端实现

以下代码应放入**桌面 lwjgl3 项目**：

```java
/** Desktop implementation, we simply log invocations **/
public class Lwjgl3Leaderboard implements Leaderboard {
   public void submitScore(String user, int score) {
      Gdx.app.log("Lwjgl3Leaderboard", "would have submitted score for user " + user + ": " + score);
   }
}
```

## GWT 实现
以下代码应放入**HTML5 项目**：

```java
/** Html5 implementation, same as Lwjgl3Leaderboard **/
public class Html5Leaderboard implements Leaderboard {
   public void submitScore(String user, int score) {
      Gdx.app.log("Html5Leaderboard", "would have submitted score for user " + user + ": " + score);
   }
}
```

## 在核心项目中获取平台特定实现
接下来，为 `ApplicationListener` 添加一个构造函数，以便传入具体的 Leaderboard 实现：

```java
public class MyGame implements ApplicationListener {
   private final Leaderboard leaderboard;

   public MyGame(Leaderboard leaderboardImpl) {
      this.leaderboard = leaderboardImpl;
   }

   // rest omitted for clarity
}
```

然后在每个[启动类](/wiki/app/starter-classes-and-configuration)中实例化 `MyGame`，并将相应的 Leaderboard 实现作为参数传入，例如桌面端：

```java
public static void main(String[] argv) {
   Lwjgl3ApplicationConfiguration config = new Lwjgl3ApplicationConfiguration();
   new Lwjgl3Application(new MyGame(new Lwjgl3Leaderboard()), config);
}
```

或者，也可以通过反射获取平台特定实现：

```java
if (Gdx.app.getType() == ApplicationType.Desktop || Gdx.app.getType() == ApplicationType.HeadlessDesktop) {
    try {
		    this.leaderboard = (Leaderboard) ClassReflection.newInstance(ClassReflection.forName("com.mygame.lwjgl3.Lwjgl3Leaderboard"));
		} catch (ReflectionException e) {
		    e.printStackTrace();
		}
}
```
