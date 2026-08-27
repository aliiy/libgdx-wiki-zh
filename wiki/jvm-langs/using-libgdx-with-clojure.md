---
title: 使用 libGDX 与 Clojure
---
Clojure 是一种 Lisp 方言，面向 JVM 编写，并以函数式编程为核心。Clojure 原生支持 Java 互操作，因此可以利用 Java 生态中强大的现有库。[YouTube 上的 ClojureTV](https://www.youtube.com/user/ClojureTV) 有许多优质视频，尤其推荐 [Clojure for Java Programmers](https://www.youtube.com/watch?v=P76Vbsk_3J0) [（第二部分）](https://www.youtube.com/watch?v=hb3rurFxrZ8)。

## 项目设置

项目的目录结构应类似于：
```
demo
- android
- desktop
  - resources
  - src
    - demo
      - core
        - desktop_launcher.clj
  - src-common
    - demo
      - core.clj
  - project.clj
```

### project.clj
```clj
(defproject demo "0.0.1-SNAPSHOT"
  :description "FIXME: write description"
  :dependencies [[com.badlogicgames.gdx/gdx "1.9.3"]
                 [com.badlogicgames.gdx/gdx-backend-lwjgl "1.9.3"]
                 [com.badlogicgames.gdx/gdx-box2d "1.9.3"]
                 [com.badlogicgames.gdx/gdx-box2d-platform "1.9.3"
                  :classifier "natives-desktop"]
                 [com.badlogicgames.gdx/gdx-bullet "1.9.3"]
                 [com.badlogicgames.gdx/gdx-bullet-platform "1.9.3"
                  :classifier "natives-desktop"]
                 [com.badlogicgames.gdx/gdx-platform "1.9.3"
                  :classifier "natives-desktop"]
                 [org.clojure/clojure "1.7.0"]]
  :source-paths ["src" "src-common"]
  :javac-options ["-target" "1.6" "-source" "1.6" "-Xlint:-options"]
  :aot [demo.core.desktop-launcher]
  :main demo.core.desktop-launcher)
```

### desktop_launcher.clj
```clj
(ns demo.core.desktop-launcher
  (:require [demo.core :refer :all])
  (:import [com.badlogic.gdx.backends.lwjgl LwjglApplication]
           [org.lwjgl.input Keyboard])
  (:gen-class))

(defn -main []
  (LwjglApplication. (demo.core.Game.) "demo" 800 600)
  (Keyboard/enableRepeatEvents true))
```

### core.clj
```clj
(ns demo.core
  (:import [com.badlogic.gdx Game Gdx Graphics Screen]
           [com.badlogic.gdx.graphics Color GL20]
           [com.badlogic.gdx.graphics.g2d BitmapFont]
           [com.badlogic.gdx.scenes.scene2d Stage]
           [com.badlogic.gdx.scenes.scene2d.ui Label Label$LabelStyle]))

(gen-class
  :name demo.core.Game
  :extends com.badlogic.gdx.Game)

(def main-screen
  (let [stage (atom nil)]
    (proxy [Screen] []
      (show []
        (reset! stage (Stage.))
        (let [style (Label$LabelStyle. (BitmapFont.) (Color. 1 1 1 1))
              label (Label. "Hello world!" style)]
          (.addActor @stage label)))
      (render [delta]
        (.glClearColor (Gdx/gl) 0 0 0 0)
        (.glClear (Gdx/gl) GL20/GL_COLOR_BUFFER_BIT)
        (doto @stage
          (.act delta)
          (.draw)))
      (dispose[])
      (hide [])
      (pause [])
      (resize [w h])
      (resume []))))

(defn -create [^Game this]
  (.setScreen this main-screen))
```

在 `project.clj` 所在目录运行 `lein run` 可以启动窗口，也可以调用 `(demo.core.desktop-launcher/-main)` 启动你选择的 REPL。

如果使用基于 REPL 的开发方式，让 `main-screen` 为每个需要重新求值的生命周期方法调用 `fn`。


## play-clj

[play-clj](https://github.com/oakes/play-clj) 库为 libGDX 提供了 Clojure 封装。开始使用前，请安装 [Leiningen](http://leiningen.org/)，然后运行以下命令：

    lein new play-clj hello-world

此时应会出现名为 `hello-world` 的目录，其中包含 `android` 和 `desktop` 目录。在 `desktop` 目录中可以找到 `src-common` 目录，它包含两个项目都会读取的游戏代码。进入该目录即可找到 `core.clj`，内容如下：

```clojure
(ns hello-world.core
  (:require [play-clj.core :refer :all]
            [play-clj.ui :refer :all]))

(defscreen main-screen
  :on-show
  (fn [screen entities]
    (update! screen :renderer (stage))
    (label "Hello world!" (color :white)))

  :on-render
  (fn [screen entities]
    (clear!)
    (render! screen entities)))

(defgame hello-world
  :on-create
  (fn [this]
    (set-screen! this main-screen)))
```

运行 `lein run`，即可在 `desktop` 目录中看到左下角显示的标签。要生成可分发给他人的 JAR 文件，请运行 `lein uberjar`，然后取出 `target` 目录中名称包含“standalone”的文件。

## 链接

* [play-clj 教程](https://github.com/oakes/play-clj/blob/master/TUTORIAL.md) 更深入地介绍了如何使用该库。
* [Nightmod](https://sekao.net/nightmod/) 游戏工具将游戏和文本编辑器集成在一起，让你在保存代码时立即看到结果，从而更方便地使用 play-clj。
