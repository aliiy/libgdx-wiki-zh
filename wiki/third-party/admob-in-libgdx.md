---
title: 在 libGDX 中使用 Admob
---
 * [简介](#introduction)
 * [背景](#background)
 * [设置](#setup)
 * [初始化](#initialization)
 * [控制](#control)
 * [代码](#code)
 * [iOS 设置（RoboVM）](#ios-setup-robovm)


# 简介

本文介绍如何在 libGDX 应用中设置 AdMob。本文内容大致对应 AdMob 4.0.4 和 libGDX 0.9.1。同样的说明也适用于 Mobclix（可能也适用于其他服务），唯一需要改变的是 AdMob 与 Mobclix API 之间的差异。为简洁起见，代码片段省略 package 和 import 行。如果使用 Eclipse，在显示错误的行上按 Ctrl-1 会自动填充所需的 import。

需要说明的是，这不是唯一可行的方法，但这是对我有效的一种方案，因此分享出来，希望也能对其他人有所帮助。

请注意，Google 已弃用 6.4.1 及更早版本的 SDK。有关如何使用新版 Google Mobile Ads 方案，请参阅 [Google Mobile Ads](/wiki/third-party/google-mobile-ads-in-libgdx)。幸运的是，从开发者和实现角度看，改动非常少。


# 背景

下面看看 libGDX 的 HelloWorld 示例，了解它的工作方式。有一个负责所有 libGDX 工作的 HelloWorld 类（位于 HelloWorld.java），一个在桌面端创建并运行 HelloWorld 的 HelloWorldDesktop 类，以及一个在 Android 上创建并运行 HelloWorld 的 HelloWorldAndroid 类。它们如下所示：

HelloWorldDesktop:

```java
public class HelloWorldDesktop {
    public static void main (String[] argv) {
        new LwjglApplication(new HelloWorld(), "Hello World", 480, 320, false);
    }
}
```

HelloWorldAndroid:

```java
public class HelloWorldAndroid extends AndroidApplication {
    @Override public void onCreate (Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initialize(new HelloWorld(), false);		
    }
}
```

HelloWorldIOS:

```java
public class HelloWorldIOS extends Delegate {
	@Override
	protected IOSApplication createApplication() {
		final IOSApplicationConfiguration config = new IOSApplicationConfiguration();
		config.orientationLandscape = false;
		config.orientationPortrait = true;

		return new IOSApplication(new HelloWorld(), config);
	}
}
```

它们非常相似：都会创建一个 `new HelloWorld()`，并将其传递给负责设置应用的对象。桌面端使用 LwjglApplication，Android 使用 `initialize()` 方法，iOS 使用 `IOSApplication()`。之后由 HelloWorld 类完成应用的全部工作。

下面仔细看看 `initialize()` 方法。它有两种形式，其中一种会调用另一种。跟踪代码可以看到，Android 应用的设置过程如下：

```java
    public void initialize(ApplicationListener listener, AndroidApplicationConfiguration config) {
   	 graphics = new AndroidGraphics(this, ...

...

       requestWindowFeature(Window.FEATURE_NO_TITLE);
       getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
       getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
       setContentView(graphics.getView(), createLayoutParams());

...
```

下面看看它做了什么：

 * 使用一些参数创建 AndroidGraphics 对象。
 * 指定窗口无标题。
 * 指定窗口全屏显示。
 * 使用 AndroidGraphics 对象中的 View 和一些布局参数调用 `setContentView()`。

最后一步会将所有内容连接起来，并设置 Activity 使用 libGDX view 作为其主 View（也是唯一的 View）。本文不解释 Android Activity 和 View 的概念，搜索即可轻松找到相关信息。

了解这些背景后，下面看看将 AdMob 添加到应用需要进行哪些修改。

# 设置

首先按通常方式遵循 AdMob 设置说明：注册、获取应用 key、在网站上配置广告颜色和刷新频率，并在 AndroidManifest.xml 中添加权限、activity 等所需内容。

# 初始化

需要理解的重点是，AdMob 使用自己的 View，而 libGDX 也会创建一个 View。如果使用 libGDX View 调用 `setContentView()`，它就会成为应用的内容视图，没有位置再添加 AdMob View。因此需要这样做：

 * 创建一个可以包含多个 View 的 Layout。
 * 创建 libGDX View，并将其添加到 Layout。
 * 创建 AdMob View，并同样添加到 Layout。
 * 使用该 Layout 调用 `setContentView()`。

下面进入代码。本例使用 RelativeLayout，因为它很容易让多个 View 在屏幕上重叠。这里假设 libGDX View 全屏显示，AdMob View 覆盖在其上方。如果需要其他布局，例如让 AdMob View 位于非全屏 libGDX View 旁边，可能需要使用其他 Layout 并进行相应设置。

首先创建一个 RelativeLayout：

```java
        RelativeLayout layout = new RelativeLayout(this);
```

很简单。接下来需要创建 libGDX View。可以使用另一个初始化函数 `initializeForView()` 完成此操作。它类似于 `initialize()`，但不会使用 libGDX View 调用 `setContentView()`，而是返回 View 供你使用。调用方式与 `initialize()` 完全相同：

```java
        View gameView = initializeForView(new HelloWorld(), false);
```

下面进一步看看 `initializeForView()` 的内部实现。同样，它有两个版本，主要工作在这里完成：

```java
    public View initializeForView(ApplicationListener listener, AndroidApplicationConfiguration config) {
   	 graphics = new AndroidGraphics(this, ...

...

       return graphics.getView();
    }
```

注意，这次函数没有设置 Activity 全屏、移除标题等内容。你很可能仍然需要这些设置，因此请在 AndroidActivity 中调用它们：

```java
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
        		WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);

        View gameView = initializeForView(new HelloWorld(), false);
```

至此完成了 libGDX View 的设置。接下来创建 AdMob View，并调用 `loadAd()` 启动它。这里假设希望立即开始获取广告；如果需要更定制化的行为，则要相应配置 AdView，本文不展开说明。

```java
        AdView adView = new AdView(this);
        adView.setAdSize(AdSize.BANNER);
        adView.setAdUnitId("xxxxxxxx"); // Put in your secret key here

        AdRequest adRequest = new AdRequest.Builder().build();
        adView.loadAd(adRequest);
```

现在已经有了一个 Layout 和两个 View。剩下的工作是将两个 View 都添加到 Layout，并告诉 Android 将 Layout 作为 Activity 要显示的内容。

View 会按照添加顺序叠放，因此务必先添加 libGDX View，因为它应位于 AdMob View 下方。如果顺序相反，全屏 libGDX View 会遮住 AdMob View，你就会困惑于广告为何没有显示。

添加 libGDX View。由于 libGDX View 是全屏的，不需要位置信息，因此可以使用更简单形式的 `addView()`。

```java
        layout.addView(gameView);
```

现在需要添加 AdMob View。这里通常需要更精细的控制，因为广告要放置在屏幕的特定区域。另一个 `addView()` 接受布局参数，因此使用它。本例告诉 Android，AdMob View 应足够大以显示完整广告，并与屏幕右上角对齐（严格来说是与父元素右上角对齐，但父元素是充满屏幕的 Layout，因此效果等同于与屏幕对齐）：

```java
        RelativeLayout.LayoutParams adParams = 
        	new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, 
        			RelativeLayout.LayoutParams.WRAP_CONTENT);
        adParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        adParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
```

然后使用这些布局参数添加 AdMob View：

```java
        layout.addView(adView, adParams);
```

最后只需告诉 Android 使用这个 Layout：

```java
        setContentView(layout);
```

将以上内容组合起来如下：

```java
public class HelloWorldAndroid extends AndroidApplication {
    @Override public void onCreate (Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Create the layout
        RelativeLayout layout = new RelativeLayout(this);

        // Do the stuff that initialize() would do for you
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
        		WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);

        // Create the libGDX View
        View gameView = initializeForView(new HelloWorld(), false);

        // Create and setup the AdMob view
        AdView adView = new AdView(this);
        adView.setAdSize(AdSize.BANNER);
        adView.setAdUnitId("xxxxxxxx"); // Put in your secret key here

        AdRequest adRequest = new AdRequest.Builder().build();
        adView.loadAd(adRequest);

        // Add the libGDX view
        layout.addView(gameView);

        // Add the AdMob view
        RelativeLayout.LayoutParams adParams = 
        	new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, 
        			RelativeLayout.LayoutParams.WRAP_CONTENT);
        adParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        adParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);

        layout.addView(adView, adParams);

        // Hook it all up
        setContentView(layout);
    }
```

就是这样。现在广告应该会显示在 libGDX 应用上方。如果希望广告始终可见，这些步骤就够了；如果希望在 libGDX 应用内部控制广告的显示时机，还需要进行一些额外工作。

# 控制

本例展示如何在 libGDX 应用内部切换 AdMob View 的可见性。注意，这可能不是控制 AdMob 的最佳方式。如果广告 View 不可见却仍在后台获取广告，就会浪费广告展示次数，并对广告收入产生负面影响。控制 AdMob View 的最佳方式因应用而异，本文不作讨论；网站端和应用端也分别有可执行的操作，请查阅 AdMob 文档了解更多信息。

首先需要将 AdView 设为 AndroidApplication 的成员，因为之后还要引用它。

```java
public class HelloWorldAndroid extends AndroidApplication {
    protected AdView adView;

    @Override public void onCreate (Bundle savedInstanceState) {

...

      adView = new AdView(this, AdSize.BANNER, "xxxxxxxx"); // Put in your secret key here
```

接下来需要理解 Handler。这是 Android 提供的线程间消息传递机制。HelloWorld 应用运行在自己的线程（称为“游戏线程”）中，该线程不同于创建 AdView 的线程（“UI 线程”）。如果从 UI 线程之外的线程操作 AdView，AdMob（以及许多其他库）可能会出错。因此，可以从另一个线程向 UI 线程发送消息；UI 线程下次获得运行机会时会取出消息并执行操作。整个过程由 Handler 处理。下面看看如何设置：

```java
public class HelloWorldAndroid extends AndroidApplication {

    private final int SHOW_ADS = 1;
    private final int HIDE_ADS = 0;

    protected Handler handler = new Handler()
    {
        @Override
        public void handleMessage(Message msg) {
            switch(msg.what) {
                case SHOW_ADS:
                {
                    adView.setVisibility(View.VISIBLE);
                    break;
                }
                case HIDE_ADS:
                {
                    adView.setVisibility(View.GONE);
                    break;
                }
            }
        }
    };
```

这部分代码负责处理消息。你定义了两个常量：`SHOW_ADS` 和 `HIDE_ADS`。如果消息包含其中一个常量，代码就会按要求显示或隐藏 AdView。

还剩两件事：

 * 发送包含 `SHOW_ADS` 或 `HIDE_ADS` 命令的代码。
 * 让 libGDX 应用的游戏线程调用这段代码的方法。

解决这个问题有多种方法。一种方法是使用接口定义 AndroidApplication 可以提供的功能，例如显示和隐藏广告。下面是该接口的定义。注意，它应放在单独的 Java 文件中：

IActivityRequestHandler.java:

```
public interface IActivityRequestHandler {
   public void showAds(boolean show);
}
```

该接口只定义了一个函数 `showAds()`。如果以后还需要从游戏线程调用其他功能，并让它在 UI 线程运行，可以在这里添加更多方法。

现在有了接口，AndroidApplication 必须实现该接口：

```java
public class HelloWorldAndroid extends AndroidApplication implements IActivityRequestHandler  {

...

    // This is the callback that posts a message for the handler
    @Override
    public void showAds(boolean show) {
       handler.sendEmptyMessage(show ? SHOW_ADS : HIDE_ADS);
    }
```

这就是 `showAds()` 函数的实现。它很简单：向 Handler 发送消息。当消息只需包含一个代码时（如本例），`sendEmptyMessage` 非常方便。如果消息需要传递更多信息，就必须发送更复杂的消息，并相应修改 Handler 的处理代码。

现在已经有了向 UI 线程发送消息、让 UI 线程处理消息的机制。接下来需要让游戏线程调用此功能。为此，HelloWorld 对象需要知道 HelloWorldAndroid 对象，以便调用 `showAds()` 函数。一种方法是为 HelloWorld 定义一个接受参数的构造函数：

```java
public class HelloWorld implements ApplicationListener {
    private IActivityRequestHandler myRequestHandler;

    public HelloWorld(IActivityRequestHandler handler) {
        myRequestHandler = handler;
    }
```

这样就能保存调用者传入的 IActivityRequestHandler 引用。现在可以从该对象的任何位置访问 myRequestHandler，因此要显示广告时只需：

```java
    myRequestHandler.showAds(true);
```

回到 HelloWorldAndroid 类，需要使用这个新构造函数创建 HelloWorld：

```java
        View gameView = initializeForView(new HelloWorld(this), false);
```

注意 HelloWorld 构造函数中的 `this` 参数，它就是将 HelloWorldAndroid 对象引用传递给 HelloWorld 对象的方式。

还剩一件事。记得桌面版本也需要更新，以调用新构造函数。为此，HelloWorldDesktop 也必须实现 IActivityRequestHandler 接口，这样 HelloWorld 才能在其上调用 `showAds()`。不过桌面端没有广告需要显示，因此这里的实现可以为空。由于 `main()` 是静态函数，其中没有 `this`，所以需要稍微变通一下。下面的方案可行，但可能还有更好的处理方式：

```java
public class HelloWorldDesktop implements IActivityRequestHandler {
    private static HelloWorldDesktop application;
    public static void main (String[] argv) {
        if (application == null) {
            application = new HelloWorldDesktop();
        }
		
        new LwjglApplication(new HelloWorld(application), "Hello World", 480, 320, false);
    }

    @Override
    public void showAds(boolean show) {
        // TODO Auto-generated method stub
	
    }
}
```

就是这样。现在可以在 libGDX 应用内部显示和隐藏 AdMob 广告。

# 代码

为完整起见，下面给出各个类的完整代码：

HelloWorldAndroid.java:

```java
/*******************************************************************************
 * Copyright 2011 See AUTHORS file.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
/*
 * Copyright 2010 Mario Zechner (contact@badlogicgames.com), Nathan Sweet (admin@esotericsoftware.com)
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS"
 * BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 */

package com.badlogic.gdx;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import com.badlogic.gdx.backends.android.AndroidApplication;
import com.badlogic.gdx.helloworld.HelloWorld;
import com.badlogic.gdx.helloworld.IActivityRequestHandler;
import com.mobclix.android.sdk.MobclixMMABannerXLAdView;

public class HelloWorldAndroid extends AndroidApplication implements IActivityRequestHandler  {

    protected AdView adView;

    private final int SHOW_ADS = 1;
    private final int HIDE_ADS = 0;

    protected Handler handler = new Handler()
    {
        @Override
        public void handleMessage(Message msg) {
            switch(msg.what) {
                case SHOW_ADS:
                {
                    adView.setVisibility(View.VISIBLE);
                    break;
                }
                case HIDE_ADS:
                {
                    adView.setVisibility(View.GONE);
                    break;
                }
            }
        }
    };

    @Override public void onCreate (Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Create the layout
        RelativeLayout layout = new RelativeLayout(this);

        // Do the stuff that initialize() would do for you
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
        		WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);

        // Create the libGDX View
        View gameView = initializeForView(new HelloWorld(this), false);

        // Create and setup the AdMob view
        AdView adView = new AdView(this);
        adView.setAdSize(AdSize.BANNER);
        adView.setAdUnitId("xxxxxxxx"); // Put in your secret key here

        AdRequest adRequest = new AdRequest.Builder().build();
        adView.loadAd(adRequest);

        // Add the libGDX view
        layout.addView(gameView);

        // Add the AdMob view
        RelativeLayout.LayoutParams adParams = 
        	new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, 
        			RelativeLayout.LayoutParams.WRAP_CONTENT);
        adParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        adParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);

        layout.addView(adView, adParams);

        // Hook it all up
        setContentView(layout);
    }

    // This is the callback that posts a message for the handler
    @Override
    public void showAds(boolean show) {
       handler.sendEmptyMessage(show ? SHOW_ADS : HIDE_ADS);
    }
}
```

HelloWorldDesktop.java:

```java
/*******************************************************************************
 * Copyright 2011 See AUTHORS file.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package com.badlogic.gdx.helloworld;

import com.badlogic.gdx.backends.lwjgl.LwjglApplication;

public class HelloWorldDesktop implements IActivityRequestHandler {
    private static HelloWorldDesktop application;
    public static void main (String[] argv) {
        if (application == null) {
            application = new HelloWorldDesktop();
        }
		
        new LwjglApplication(new HelloWorld(application), "Hello World", 480, 320, false);
    }

    @Override
    public void showAds(boolean show) {
        // TODO Auto-generated method stub
	
    }
}
```

HelloWorld.java:

```java
/*******************************************************************************
 * Copyright 2011 See AUTHORS file.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package com.badlogic.gdx.helloworld;

import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Files.FileType;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.Texture.TextureFilter;
import com.badlogic.gdx.graphics.Texture.TextureWrap;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;

public class HelloWorld implements ApplicationListener {
	SpriteBatch spriteBatch;
	Texture texture;
	BitmapFont font;
	Vector2 textPosition = new Vector2(100, 100);
	Vector2 textDirection = new Vector2(1, 1);

    private IActivityRequestHandler myRequestHandler;

    public HelloWorld(IActivityRequestHandler handler) {
        myRequestHandler = handler;
    }
    
    @Override public void create () {
		font = new BitmapFont();
		font.setColor(Color.RED);
		texture = new Texture(Gdx.files.internal("data/badlogic.jpg"));
		spriteBatch = new SpriteBatch();
	}

	@Override public void render () {
		int centerX = Gdx.graphics.getWidth() / 2;
		int centerY = Gdx.graphics.getHeight() / 2;

		Gdx.graphics.getGL10().glClear(GL10.GL_COLOR_BUFFER_BIT);
		
		// more fun but confusing :)
		//textPosition.add(textDirection.tmp().mul(Gdx.graphics.getDeltaTime()).mul(60));
		textPosition.x += textDirection.x * Gdx.graphics.getDeltaTime() * 60;
		textPosition.y += textDirection.y * Gdx.graphics.getDeltaTime() * 60;

		if (textPosition.x < 0 ) {
			textDirection.x = -textDirection.x;
			textPosition.x = 0;
		}
		if(textPosition.x > Gdx.graphics.getWidth()) {
			textDirection.x = -textDirection.x;
			textPosition.x = Gdx.graphics.getWidth();
		}
		if (textPosition.y < 0) {
			textDirection.y = -textDirection.y;
			textPosition.y = 0;			
		}
		if (textPosition.y > Gdx.graphics.getHeight()) {
			textDirection.y = -textDirection.y;
			textPosition.y = Gdx.graphics.getHeight();			
		}

		spriteBatch.begin();
		spriteBatch.setColor(Color.WHITE);
		spriteBatch.draw(texture, 
							  centerX - texture.getWidth() / 2, 
							  centerY - texture.getHeight() / 2, 
							  0, 0, texture.getWidth(), texture.getHeight());		
		font.draw(spriteBatch, "Hello World!", (int)textPosition.x, (int)textPosition.y);
		spriteBatch.end();
	}

	@Override public void resize (int width, int height) {
		spriteBatch.getProjectionMatrix().setToOrtho2D(0, 0, width, height);
		textPosition.set(0, 0);
	}

	@Override public void pause () {

	}

	@Override public void resume () {

	}
	
	@Override public void dispose () {

	}
	
}
```

# iOS 设置（RoboVM）

要让 AdMob 在 iOS 上运行，最好确保完成以下事项：

* 确保项目使用最新版本的 libGDX。

* 确保使用最新版本的 RoboVM。

* 确保使用这里提供的最新 admob 绑定：[robovm-ios-bindings - admob](https://github.com/MobiVM/robovm-robopods/tree/master/google-mobile-ads)。

* Admob 需要为 iOS 使用独立的广告单元，因此请创建一个新应用；其 key 将不同于 Android 使用的 key。


***

1. 按照 [AdMob RoboPod 安装说明](https://github.com/MobiVM/robovm-robopods/tree/master/google-mobile-ads/ios)操作。

2. 配置完成后，就可以从 Java 调用 AdMob API，并按需配置广告。下面是一个在屏幕顶部集成横幅广告的示例：


_警告：以下代码对于最新 RoboPod 版本可能略有过时，请仅将其作为参考。_


```java
package com.badlogic.gdx;

import org.robovm.apple.coregraphics.CGRect;
import org.robovm.apple.coregraphics.CGSize;
import org.robovm.apple.foundation.NSArray;
import org.robovm.apple.foundation.NSAutoreleasePool;
import org.robovm.apple.foundation.NSObject;
import org.robovm.apple.foundation.NSString;
import org.robovm.apple.uikit.UIApplication;
import org.robovm.apple.uikit.UIScreen;
import org.robovm.bindings.admob.GADAdSizeManager;
import org.robovm.bindings.admob.GADBannerView;
import org.robovm.bindings.admob.GADBannerViewDelegateAdapter;
import org.robovm.bindings.admob.GADRequest;
import org.robovm.bindings.admob.GADRequestError;

import com.badlogic.gdx.Application;
import com.badlogic.gdx.backends.iosrobovm.IOSApplication;
import com.badlogic.gdx.backends.iosrobovm.IOSApplication.Delegate;
import com.badlogic.gdx.backends.iosrobovm.IOSApplicationConfiguration;
import com.badlogic.gdx.utils.Logger;

public class HelloWorldIOS extends Delegate implements IActivityRequestHandler {
	private static final Logger log = new Logger(HelloWorldIOS.class.getName(), Application.LOG_DEBUG);
	private static final boolean USE_TEST_DEVICES = true;
	private GADBannerView adview;
	private boolean adsInitialized = false;
	private IOSApplication iosApplication;

	@Override
	protected IOSApplication createApplication() {
		final IOSApplicationConfiguration config = new IOSApplicationConfiguration();
		config.orientationLandscape = false;
		config.orientationPortrait = true;

		iosApplication = new IOSApplication(new HelloWorld(this), config);
		return iosApplication;
	}

	public static void main(String[] argv) {
		NSAutoreleasePool pool = new NSAutoreleasePool();
		UIApplication.main(argv, null, HelloWorldIOS.class);
		pool.close();
	}

	@Override
	public void hide() {
		initializeAds();

		final CGSize screenSize = UIScreen.getMainScreen().getBounds().size();
		double screenWidth = screenSize.width();

		final CGSize adSize = adview.getBounds().size();
		double adWidth = adSize.width();
		double adHeight = adSize.height();

		log.debug(String.format("Hidding ad. size[%s, %s]", adWidth, adHeight));

		float bannerWidth = (float) screenWidth;
		float bannerHeight = (float) (bannerWidth / adWidth * adHeight);

		adview.setFrame(new CGRect(0, -bannerHeight, bannerWidth, bannerHeight));
	}

	@Override
	public void show() {
		initializeAds();

		final CGSize screenSize = UIScreen.getMainScreen().getBounds().size();
		double screenWidth = screenSize.width();

		final CGSize adSize = adview.getBounds().size();
		double adWidth = adSize.width();
		double adHeight = adSize.height();

		log.debug(String.format("Showing ad. size[%s, %s]", adWidth, adHeight));

		float bannerWidth = (float) screenWidth;
		float bannerHeight = (float) (bannerWidth / adWidth * adHeight);

		adview.setFrame(new CGRect((screenWidth / 2) - adWidth / 2, 0, bannerWidth, bannerHeight));
	}

	public void initializeAds() {
		if (!adsInitialized) {
			log.debug("Initalizing ads...");

			adsInitialized = true;

			adview = new GADBannerView(GADAdSizeManager.smartBannerPortrait());
			adview.setAdUnitID("xxxxxxxx"); //put your secret key here
			adview.setRootViewController(iosApplication.getUIViewController());
			iosApplication.getUIViewController().getView().addSubview(adview);

			final GADRequest request = GADRequest.request();
			if (USE_TEST_DEVICES) {
				final NSArray<?> testDevices = new NSArray<NSObject>(
						new NSString(GADRequest.GAD_SIMULATOR_ID));
				request.setTestDevices(testDevices);
				log.debug("Test devices: " + request.getTestDevices());
			}

			adview.setDelegate(new GADBannerViewDelegateAdapter() {
				@Override
				public void didReceiveAd(GADBannerView view) {
					super.didReceiveAd(view);
					log.debug("didReceiveAd");
				}

				@Override
				public void didFailToReceiveAd(GADBannerView view,
						GADRequestError error) {
					super.didFailToReceiveAd(view, error);
					log.debug("didFailToReceiveAd:" + error);
				}
			});

			adview.loadRequest(request);

			log.debug("Initalizing ads complete.");
		}
	}

    @Override
    public void showAds(boolean show) {
    	initializeAds();

       	final CGSize screenSize = UIScreen.getMainScreen().getBounds().size();
		double screenWidth = screenSize.width();

		final CGSize adSize = adview.getBounds().size();
		double adWidth = adSize.width();
		double adHeight = adSize.height();

		log.debug(String.format("Hidding ad. size[%s, %s]", adWidth, adHeight));

		float bannerWidth = (float) screenWidth;
		float bannerHeight = (float) (bannerWidth / adWidth * adHeight);

		if(show) {
			adview.setFrame(new CGRect((screenWidth / 2) - adWidth / 2, 0, bannerWidth, bannerHeight));
		} else {
			adview.setFrame(new CGRect(0, -bannerHeight, bannerWidth, bannerHeight));
		}
    }
}
```
