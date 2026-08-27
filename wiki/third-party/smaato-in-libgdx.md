---
title: 在 libGDX 中使用 Smaato
---
# 摘要

  * [简介](#introduction)
  * [配置](#configuration)
  * [回顾](#recap)
 * [Banner](#banner)
 * [Interstitial](#interstitial)
 * [Rewarded](#rewarded)
 * [Test Ads](#test-ads)

# 简介

本文介绍如何将 Smaato 广告添加到 libGDX Android 项目。你将能够通过横幅、插屏和激励广告实现游戏变现。本教程假设你已经熟悉 libGDX 基础知识和 Android View 的处理方式，但仍会简要回顾相关内容。

仅供参考，最新文档可在 Smaato 官方[网站](https://developers.smaato.com/publishers/nextgen-sdk-android-integration)查看。

你需要：
1. 一个 libGDX Android 游戏项目
2. 你的 [Smaato](https://spx.smaato.com) 账户

# 配置
将以下仓库配置添加到项目的主 `build.gradle` 文件中：
```java

buildscript {
    repositories {
        mavenCentral()
        google()
        jcenter()
        maven { url "https://s3.amazonaws.com/smaato-sdk-releases/" }
    }
}
...
allprojects {
    repositories {
        google()
        jcenter()
        maven {
            url "https://s3.amazonaws.com/smaato-sdk-releases/"
        }
    }
}
```
在 android 模块的 `build.gradle` 文件中，将编译选项设为 Java 8，并将 minSdkVersion 设为至少 16：
```java
android {
    defaultConfig {
        minSdkVersion 16
        ...
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

在 project(":android") 的 dependencies 下，将所需依赖添加到应用模块的 `build.gradle` 文件中。

`implementation 'com.smaato.android.sdk:smaato-sdk:21.5.3`

如果项目使用 Proguard，请将以下行添加到 Proguard 配置文件中：
```java
-keep public class com.smaato.sdk.** { *; }
-keep public interface com.smaato.sdk.** { *; }
```

将以下权限添加到应用的 AndroidManifest.xml 文件中：
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

如果应用目标为 Android 5.0（API level 21）或更高版本，则需要将以下行添加到应用的 AndroidManifest.xml 文件中：
```xml
<uses-feature android:name="android.hardware.location.network" />
```

最新版 Smaato NextGenSDK 已针对 `com.android.tools.build:gradle:3.5.4` 和 gradle-wrapper `gradle-5.6.3-bin` 完成验证。

主 build.gradle：
```java
buildscript {
    ...
    dependencies {
        classpath 'com.android.tools.build:gradle:3.5.4'
    }
}
```

gradle-wrapper.properties：
```xml
distributionUrl=https\://services.gradle.org/distributions/gradle-5.6.3-bin.zip
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStorePath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
```

# 回顾
libGDX Android 游戏会创建为一个 [View](https://developer.android.com/reference/android/view/View)。要添加持续显示的广告（例如横幅），应使用另一个 View 承载它。换句话说，需要创建一个同时包含这两个 View 的 Relative Layout。
以下代码片段展示了这种做法：

```java
public class AndroidLauncher extends AndroidApplication {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        RelativeLayout layout = new RelativeLayout(this);
        layout.setLayoutParams(new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        layout.addView(createGameView());
        createAdView(layout);
        setContentView(layout);
    }

    private View createGameView() {
        View gameView = initializeForView(new MyGame(this), new AndroidApplicationConfiguration());
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT);
        params.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
        params.addRule(RelativeLayout.CENTER_HORIZONTAL, RelativeLayout.TRUE);
        gameView.setLayoutParams(params);
        return gameView;
    }
}
```
这里唯一缺少的是将在下一节创建的 `createAdView` 方法。

# 横幅广告
为了添加横幅广告，我们将使用 `com.smaato.sdk.banner.widget.BannerView`。如前所述，横幅 View 将与游戏 View 位于同一个 Relative Layout 中。
```java
public class AndroidLauncher extends AndroidApplication {
    private static final String PUBLISHER_ID = "1100042525";
    private static final String BANNER_AD_SPACE_ID = "130635694";

    private BannerView smaatoBanner;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        RelativeLayout layout = new RelativeLayout(this);
        layout.setLayoutParams(new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        layout.addView(createGameView());
        createAdView(layout);
        setContentView(layout);
    }

    private void createAdView(RelativeLayout layout) {
        SmaatoSdk.init(getApplication(), PUBLISHER_ID);
        createSmaatoBanner();
        layout.addView(smaatoBanner);
    }

    private void createSmaatoBanner() {
        smaatoBanner = new BannerView(this);

        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT);
        params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE);
        params.addRule(RelativeLayout.CENTER_HORIZONTAL, RelativeLayout.TRUE);
        smaatoBanner.setLayoutParams(params);
        smaatoBanner.setBackgroundColor(Color.TRANSPARENT);
        smaatoBanner.setVisibility(View.INVISIBLE);
    }

    @Override
    public void onDestroy() {
        if (smaatoBanner != null) smaatoBanner.destroy();
        super.onDestroy();
    }

    public void showBannerAds() {
        runOnUiThread(() -> {
            smaatoBanner.setVisibility(View.VISIBLE);
            smaatoBanner.setEnabled(true);
            smaatoBanner.loadAd(BANNER_AD_SPACE_ID, BannerAdSize.XX_LARGE_320x50);
        });
    }

    public void hideBannerAds() {
        runOnUiThread(() -> {
            smaatoBanner.setVisibility(View.GONE);
            smaatoBanner.setEnabled(false);
        });
    }
}
```
下面逐项说明这段代码：
* `BannerView smaatoBanner` 保存在实例变量中，因此可以根据游戏生命周期显示和隐藏广告。
* 应始终销毁 `BannerView`，以便正确释放资源。
* 横幅将根据 `RelativeLayout.LayoutParams` 规则放置。
* 应根据游戏生命周期调用 `showBannerAds`/`hideBannerAds`。
* `PUBLISHER_ID` 和 `BANNER_AD_SPACE_ID` 可用于测试。所有可用测试广告配置请参阅[测试广告](#test-ads)章节。

# 插屏广告
与横幅广告不同，插屏广告不会持续显示在屏幕上。这类广告应只在应用流程的自然过渡点显示，例如关卡完成/失败或切换屏幕时。因此不需要为插屏广告创建额外 View，因为它通常会占据整个屏幕，并在关闭时销毁。

```java
public class AndroidLauncher extends AndroidApplication {
    private static final String PUBLISHER_ID = "1100042525";
    private static final String INTERSTITIAL_AD_SPACE_ID = "130626426";

    private InterstitialAd smaatoInterstitial;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        RelativeLayout layout = new RelativeLayout(this);
        layout.setLayoutParams(new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        layout.addView(createGameView());
        createAd();
        setContentView(layout);
    }

    private void createAd() {
        SmaatoSdk.init(getApplication(), PUBLISHER_ID);
        requestSmaatoInterstitialAd();
    }

    public void showInterstitial() {
        runOnUiThread(() -> {
            if (smaatoInterstitial == null) {
                requestSmaatoInterstitialAd();
                return;
            }
            smaatoInterstitial.showAd(AndroidLauncher.this);
            requestSmaatoInterstitialAd();
        });
    }

    private void requestSmaatoInterstitialAd() {
        Interstitial.loadAd(INTERSTITIAL_AD_SPACE_ID, new EventListener() {
            @Override
            public void onAdLoaded(@NonNull InterstitialAd interstitialAd) {
                smaatoInterstitial = interstitialAd;
            }

            @Override
            public void onAdFailedToLoad(@NonNull InterstitialRequestError interstitialRequestError) {
                log(AndroidLauncher.class.getName(), "Smaato Interstitial failed to load; error: " + interstitialRequestError.getInterstitialError());
            }

            @Override
            public void onAdError(@NonNull InterstitialAd interstitialAd, @NonNull InterstitialError interstitialError) {
            }

            @Override
            public void onAdOpened(@NonNull InterstitialAd interstitialAd) {
            }

            @Override
            public void onAdClosed(@NonNull InterstitialAd interstitialAd) {
            }

            @Override
            public void onAdClicked(@NonNull InterstitialAd interstitialAd) {
            }

            @Override
            public void onAdImpression(@NonNull InterstitialAd interstitialAd) {
            }

            @Override
            public void onAdTTLExpired(@NonNull InterstitialAd interstitialAd) {
            }
        });
    }
}
```
下面逐项说明这段代码：
* `InterstitialAd smaatoInterstitial` 保存在实例变量中，因此可以根据游戏生命周期显示广告。
* 建议在游戏加载时调用 `requestSmaatoInterstitialAd`，以便从一开始就预加载广告。
* `Interstitial.loadAd` 提供多个有用的回调，可根据使用场景选择。
* 应根据游戏生命周期调用 `showInterstitial`。

# 激励广告
激励广告在视觉上类似插屏广告，通常会占据整个屏幕。
但在流程上完全不同：这类广告鼓励用户与广告内容互动，以换取应用内奖励，例如额外生命、免费金币或能量。

```java
public class AndroidLauncher extends AndroidApplication {
    private static final String PUBLISHER_ID = "1100042525";
    private static final String REWARDED_INTERSTITIAL_AD_SPACE_ID = "130626428";

    private RewardedInterstitialAd smaatoRewardedInterstitial;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        RelativeLayout layout = new RelativeLayout(this);
        layout.setLayoutParams(new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        layout.addView(createGameView());
        createAd();
        setContentView(layout);
    }

    private void createAd() {
        SmaatoSdk.init(getApplication(), PUBLISHER_ID);
        requestSmaatoRewardedInterstitialAd();
    }

    public void showRewarded() {
        runOnUiThread(() -> {
            if (smaatoRewardedInterstitial == null) {
                requestSmaatoRewardedInterstitialAd();
                return;
            }
            smaatoRewardedInterstitial.showAd();
            requestSmaatoRewardedInterstitialAd();
        });
    }

    private void requestSmaatoRewardedInterstitialAd() {
        RewardedInterstitial.loadAd(REWARDED_INTERSTITIAL_AD_SPACE_ID, new EventListener() {
            @Override
            public void onAdLoaded(@NonNull RewardedInterstitialAd rewardedInterstitialAd) {
                smaatoRewardedInterstitial = rewardedInterstitialAd;
            }

            @Override
            public void onAdFailedToLoad(@NonNull RewardedRequestError rewardedRequestError) {
            }

            @Override
            public void onAdError(@NonNull RewardedInterstitialAd rewardedInterstitialAd, @NonNull RewardedError rewardedError) {
            }

            @Override
            public void onAdClosed(@NonNull RewardedInterstitialAd rewardedInterstitialAd) {
            }

            @Override
            public void onAdClicked(@NonNull RewardedInterstitialAd rewardedInterstitialAd) {
            }

            @Override
            public void onAdStarted(@NonNull RewardedInterstitialAd rewardedInterstitialAd) {
            }

            @Override
            public void onAdReward(@NonNull RewardedInterstitialAd rewardedInterstitialAd) {
            }

            @Override
            public void onAdTTLExpired(@NonNull RewardedInterstitialAd rewardedInterstitialAd) {
            }
        });
    }
}
```
再次逐项说明这段代码：
* `RewardedInterstitialAd smaatoRewardedInterstitial` 保存在实例变量中，因此用户在游戏中发起激励广告流程时可以显示广告。
* 建议在游戏加载时调用 `requestSmaatoRewardedInterstitialAd`，以便从一开始就预加载广告。
* `RewardedInterstitial.loadAd` 提供多个有用的回调，可根据使用场景选择。
* 用户在游戏中发起激励广告流程时应调用 `showRewarded`。

# 测试广告

| Adspace ID    | Type               |
| ------------- | ------------------ |
| 130626424     | Rich Media         |
| 130635694     | Static Image       |
| 130635706     | MRAID              |
| 130626426     | Rich Media / Video |
| 130626427     | Video              |
| 130626428     | Rewarded           |

请将 Publisher Id 1100042525 与上述每个广告位配合使用。

发布前别忘了将这些值改为生产环境的值！
