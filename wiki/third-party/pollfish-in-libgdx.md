---
title: 在 libGDX 中使用 Pollfish
---
# **简介**

本教程将帮助你把 Pollfish 调查集成到 libGDX Android 应用中。

在 Android 应用中集成 Pollfish 很简单，官方指南对此有详细说明：[Pollfish Android 文档](https://www.pollfish.com/docs/android)

## 步骤摘要

1. 在 Pollfish 网站[注册](https://www.pollfish.com/login/publisher)为 Publisher，创建新应用并从控制面板获取 API key。
2. [下载](https://www.pollfish.com/docs/android) Pollfish SDK（Google Play 版或 Universal 版），或在 Gradle 文件中通过 jcenter() 引用。
3. 按[文档](https://www.pollfish.com/docs/android)将相应的 Pollfish aar 或 jar 文件加入项目，导入相关类，并在应用 manifest 中添加所需权限。
4. 在 AndroidLauncher 的 onResume 中调用 Pollfish 初始化函数。

```java

package com.mygdx.game.android;

import android.os.Bundle;
import com.badlogic.gdx.backends.android.AndroidApplication;
import com.badlogic.gdx.backends.android.AndroidApplicationConfiguration;
import com.mygdx.game.MyGdxGame;

import com.pollfish.main.PollFish;
import com.pollfish.constants.Position;

public class AndroidLauncher extends AndroidApplication{

 @Override
 protected void onCreate (Bundle savedInstanceState) {
   super.onCreate(savedInstanceState);
   
   AndroidApplicationConfiguration config = new AndroidApplicationConfiguration();
   initialize(MyGdxGame(), config);
 }

 @Override
 public void onResume() {
     super.onResume();
 
     PollFish.initWith(this, new ParamsBuilder("YOUR_API_KEY").build());
 }

}
```

完成这个简单实现后，几分钟内就应该能在应用中看到 Pollfish 调查。

## 可选步骤


### 1. 监听 Pollfish listener（可选）

例如，可以在 AndroidLauncher 中实现 Pollfish listener 来监听相关事件：

```java
import com.pollfish.interfaces.PollfishSurveyCompletedListener;
```
```java
public class AndroidLauncher extends AndroidApplication implements PollfishSurveyCompletedListener{
```

```java
@Override
public void onPollfishSurveyCompleted(boolean playfulSurveys , int surveyPrice) {
 
  Log.d("Pollfish", "Pollfish survey completed - Playful survey: " + playfulSurveys + " with price: " + surveyPrice);
 
}
```

### 2. 手动显示或隐藏 Pollfish（可选）

可以通过如下简单实现，在 Android 应用中手动显示或隐藏 Pollfish：

在你的 `AndroidLauncher.java` 文件中：

```java

package com.mygdx.game.android;

import android.os.Bundle;
import com.badlogic.gdx.backends.android.AndroidApplication;
import com.badlogic.gdx.backends.android.AndroidApplicationConfiguration;
import com.mygdx.game.MyGdxGame;

import com.pollfish.main.PollFish;
import com.pollfish.constants.Position;

public class AndroidLauncher extends AndroidApplication implements MyGdxGame.MyPollfishCallbacks {
 
 protected MyGdxGame myGdxGame;
 
 @Override
 protected void onCreate (Bundle savedInstanceState) {
   super.onCreate(savedInstanceState);
   
   AndroidApplicationConfiguration config = new AndroidApplicationConfiguration();
   
   myGdxGame=new MyGdxGame();
   myGdxGame.setMyPollfishCallbacks(this);

   initialize(myGdxGame, config);
 }

 @Override
 public void onResume() {  
    super.onResume();
    
    PollFish.initWith(this, new ParamsBuilder("YOUR_API_KEY")
            .customMode(true)
            .build());
            
    PollFish.hide();  
 }

 @Override
 public void onShowPollfish() {
     PollFish.show();
 }

 @Override
 public void hidePollfish() {
     PollFish.hide();
 }

}
```

在你的 `MyGdxGame.java` 文件中：

```java
package com.mygdx.game;

import com.badlogic.gdx.ApplicationAdapter;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

public class MyGdxGame extends ApplicationAdapter {
    
    private SpriteBatch batch;
    private Skin skin;
    private Stage stage;

    // Define an interface for your various callbacks to the android launcher
    public interface MyPollfishCallbacks {
        public void showPollfish();
        public void hidePollfish();
    }

    // Local variable to hold the callback implementation
    private MyPollfishCallbacks myPollfishCallbacks;

    // ** Additional **
    // Setter for the callback
    public void setMyPollfishCallbacks(MyPollfishCallbacks callback) {
        myPollfishCallbacks = callback;
    }

    @Override
    public void create() {

        batch = new SpriteBatch();
        skin = new Skin(Gdx.files.internal("uiskin.json"));
        stage = new Stage();

        final TextButton showBtn = new TextButton("Show", skin, "default");

        showBtn.setWidth(400f);
        showBtn.setHeight(100f);
        showBtn.setPosition(Gdx.graphics.getWidth() /2 - 600f, Gdx.graphics.getHeight()/2 - 10f);

        showBtn.addListener(new ClickListener(){
            @Override
            public void clicked(InputEvent event, float x, float y){
                   if(myPollfishCallbacks!=null){
                         myPollfishCallbacks.showPollfish();
                   }
            }
        });

        final TextButton hideBtn = new TextButton("Hide", skin, "default");

        hideBtn.setWidth(400f);
        hideBtn.setHeight(100f);
        hideBtn.setPosition(Gdx.graphics.getWidth() /2 + 300f, Gdx.graphics.getHeight()/2 - 10f);

        hideBtn.addListener(new ClickListener(){
            @Override
            public void clicked(InputEvent event, float x, float y){
                   if(myPollfishCallbacks!=null){
                         myPollfishCallbacks.hidePollfish();
                   }
            }
        });

        stage.addActor(showBtn);
        stage.addActor(hideBtn);

        Gdx.input.setInputProcessor(stage);
    }

    @Override
    public void dispose() {
        batch.dispose();
    }

    @Override
    public void render() {
        Gdx.gl.glClearColor(1, 0, 1, 1);
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

        batch.begin();
        stage.draw();
        batch.end();
    }

    @Override
    public void resize(int width, int height) {
    }

    @Override
    public void pause() {
    }

    @Override
    public void resume() {
    }
}
```

### 3. 检查设备上是否仍有 Pollfish 调查

初始化 Pollfish 并收到调查后，可能已经过去了一段时间。如果想检查设备上的调查是否仍然可用且尚未过期，可以调用：

```
PollFish.isPollfishPresent();
```
