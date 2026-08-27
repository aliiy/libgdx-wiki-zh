---
title: 使用 Python 编写 libGDX
---
Python 是一种动态且强类型的语言，支持过程式、面向对象和函数式等多种编程范式。

Python 有多种实现方式：使用 C 编写的标准解释器（CPython）、使用 Python 自身编写的实现（PyPy）、运行于 .Net 动态语言运行时（C#）的实现（IronPython），以及运行在 Java 虚拟机上的 Java 实现（Jython）。Jython 提供 Java 互操作能力，因此可以利用 libGDX 等强大的 Java 库，同时保留 Python 的简洁性和可读性。

本文使用 Jython 2.7b1，其目标是兼容 CPython 2.7。本文中的代码使用 Python 2.7 语法。当前版本和旧版本可在[这里](https://www.jython.org/download.html)获取。

**注意：**本文撰写时，Jython 与 libGDX 只能在桌面端一起使用。

## 设置

Jython 可以使用任意文本编辑器进行开发，包括 Vim 或 Emacs。Eclipse 用户可以选择 [PyDev](http://pydev.org/)。环境设置好后，创建一个新的 Jython 项目，并将所有 libGDX 依赖添加到 `PYTHONPATH`。使用桌面端 LWJGL3 后端时，这些依赖包括 `gdx.jar`、`gdx-backend-lwjgl3.jar`、`gdx-platform-natives-desktop.jar` 和 `gdx-sources.jar`。

## 使用 Python 编程

整个 [Drop 教程](/wiki/start/a-simple-game)都可以放在一个 Python 文件中。

```python
from com.badlogic.gdx.backends.lwjgl import Lwjgl3Application, Lwjgl3ApplicationConfiguration
from com.badlogic.gdx.utils import TimeUtils, Array
from com.badlogic.gdx.math import MathUtils, Rectangle, Vector3
from com.badlogic.gdx import ApplicationListener, Gdx, Input
from com.badlogic.gdx.graphics.g2d import SpriteBatch
from com.badlogic.gdx.graphics import Texture, OrthographicCamera, GL20

class PyGdx(ApplicationListener):
    def __init__(self):
        self.camera = None
        self.batch = None
        self.texture = None
        self.bucketimg = None
        self.dropsound = None
        self.rainmusic = None
        self.bucket = None
        self.raindrops = None
        
        self.lastdrop = 0
        self.width = 800
        self.height = 480
    
    def spawndrop(self):
        raindrop = Rectangle()
        raindrop.x = MathUtils.random(0, self.width - 64)
        raindrop.y = self.height
        raindrop.width = 64
        raindrop.height = 64
        self.raindrops.add(raindrop)
        self.lastdrop = TimeUtils.nanoTime()
        
    def create(self):        
        self.camera = OrthographicCamera()
        self.camera.setToOrtho(False, self.width, self.height)
        self.batch = SpriteBatch()
        
        self.dropimg = Texture("assets/droplet.png")
        self.bucketimg = Texture("assets/bucket.png")
        self.dropsound = Gdx.audio.newSound(Gdx.files.internal("assets/drop.wav"))
        self.rainmusic = Gdx.audio.newSound(Gdx.files.internal("assets/rain.mp3"))
        
        self.bucket = Rectangle()
        self.bucket.x = (self.width / 2) - (64 / 2)
        self.bucket.y = 20
        self.bucket.width = 64
        self.bucket.height = 64
        
        self.raindrops = Array()
        self.spawndrop()
        
        self.rainmusic.setLooping(True, True)
        self.rainmusic.play()
    
    def render(self):
        Gdx.gl.glClearColor(0,0,0.2,0)
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)
        
        self.camera.update()
        
        self.batch.setProjectionMatrix(self.camera.combined)
        self.batch.begin()
        self.batch.draw(self.bucketimg, self.bucket.x, self.bucket.y)
        for drop in self.raindrops:
            self.batch.draw(self.dropimg, drop.x, drop.y)
        self.batch.end()
        
        if Gdx.input.isTouched():
            touchpos = Vector3()
            touchpos.set(Gdx.input.getX(), Gdx.input.getY(), 0)
            self.camera.unproject(touchpos)
            self.bucket.x = touchpos.x - (64 / 2)
        if Gdx.input.isKeyPressed(Input.Keys.LEFT): self.bucket.x -= 200 * Gdx.graphics.getDeltaTime()
        if Gdx.input.isKeyPressed(Input.Keys.RIGHT): self.bucket.x += 200 * Gdx.graphics.getDeltaTime()
        
        if self.bucket.x < 0: self.bucket.x = 0
        if self.bucket.x > (self.width - 64): self.bucket.x = self.width - 64
        
        if (TimeUtils.nanoTime() - self.lastdrop) > 1000000000: self.spawndrop()
                        
        iterator = self.raindrops.iterator()
        while iterator.hasNext():
            raindrop = iterator.next()
            raindrop.y -= 200 * Gdx.graphics.getDeltaTime();
            if (raindrop.y + 64) < 0: iterator.remove()
            if raindrop.overlaps(self.bucket):
                self.dropsound.play()
                iterator.remove()
        
    def resize(self, width, height):
        pass

    def pause(self):
        pass

    def resume(self):
        pass
    
    def dispose(self):
        self.batch.dispose()
        self.dropimg.dispose()
        self.bucketimg.dispose()
        self.dropsound.dispose()
        self.rainmusic.dispose()


def main():

    cfg = Lwjgl3ApplicationConfiguration()
    cfg.setTitle("PyGdx")
    cfg.setWindowedMode(800, 480)
    
    Lwjgl3Application(PyGdx(), cfg)
        
if __name__ == '__main__':
    main()
```

**注意，在创建资源时需要指定 `assets/` 文件夹。不使用 Android 时，必须指定所使用的文件夹结构；而在 Android 上，所有内部资源都默认位于 `assets/` 目录中。**

## 使用 Python 和 libGDX 编写的游戏

* [Bubbles: PyGDX Edition](https://github.com/XyperCode/bubbles-pygdx)
