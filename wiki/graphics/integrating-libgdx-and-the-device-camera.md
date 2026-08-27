---
title: 集成 libGDX 与设备相机
---
本文介绍如何将 Android 设备相机集成到 libGDX 应用中。
此功能可以让用户在游戏过程中、甚至行走在街上时看到设备后方的景象，也可以实现游戏与现实世界之间的交互（例如使用人脸检测机制的 FPS 游戏）。


# 简要概述
  * 创建带 alpha 通道的 libGDX 视图（默认不带），使相机预览显示在其后方。
  * 创建负责相机预览绘制表面的 DeviceCameraController 对象。
  * 在应用代码中与 DeviceCameraController 交互，大多数相机功能会按照[此处](https://code.google.com/p/libgdx-users/wiki/IntegratingAndroidNativeUiElements3TierProjectSetup)的方式异步调用。
  * 拍照
    * Camera 拍照时有必须遵循的特定状态机。
    * 获取相机图像数据后，将其与 libGDX 屏幕截图合并并写入结果；这个过程较慢，可以放到单独线程中执行。
  * 继续预览（拍摄的图像会冻结在屏幕上，直到显式重启预览），或完全隐藏 CameraSurface。

示例应用执行以下操作：
   * 使用 libGDX 启动画面作为各个面的纹理绘制一个立方体
   * 用户触摸屏幕后启动 Camera 预览，并将其绘制在立方体后方
   * 用户松开屏幕后：
     * Camera 开始自动对焦；
     * 对焦成功后拍照；
     * 按照[此处](https://libgdx.com/wiki/graphics/taking-a-screenshot)的方式截取 libGDX 场景；
     * 将合并后的图像保存到存储中；
     * 移除预览。

# 详细实现

## 创建 libGDX 应用
在 Android 项目的 !MainActivity 类中初始化 Application，但在将 AndroidApplicationConfiguration 对象传给 initialize 方法之前先对其进行修改：
```java
        AndroidApplicationConfiguration cfg = new AndroidApplicationConfiguration();
        cfg.useGL20 = false;
        // we need to change the default pixel format - since it does not include an alpha channel 
        // we need the alpha channel so the camera preview will be seen behind the GL scene
        cfg.r = 8;
        cfg.g = 8;
        cfg.b = 8;
        cfg.a = 8;
```
初始化后，确保将 OpenGL 表面格式定义为 TRANSLUCENT。
```java
        if (graphics.getView() instanceof SurfaceView) {
        	SurfaceView glView = (SurfaceView) graphics.getView();
			// force alpha channel - I'm not sure we need this as the GL surface is already using alpha channel
			glView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
		}
	}
```
我们还在 !MainActivity 类中创建一个新方法，以便调用异步函数：
```java
	public void post(Runnable r) {
		handler.post(r);
	}
```

## 在 render() 方法中绘制帧
这里的关键是在希望 Camera 预览显示于场景后方时，使用 alpha 通道为 0 的颜色调用 `glClearColor()` 清除屏幕。
```java	
	Gdx.gl10.glClearColor(0.0f, 0.0f, 0.0f, 0.0f); 
```
清除屏幕后即可像往常一样绘制其他内容。注意，使用透明颜色绘制的对象会透出 Camera 预览（即使其后方有不透明对象，只是由于 Z 顺序没有被绘制）。

## Camera 状态机
Android 相机有必须遵循的特定状态机。应用可以通过回调管理该状态机。状态机由 AndroidDeviceCameraController 管理（该类实现了基础项目中定义的抽象接口；桌面应用中则使用空类实现该接口，仅用于保证编译兼容性）。

Camera 状态机如下：
Ready -> Preview -> autoFocusing -> ShutterCalled -> Raw PictureData -> Postview PictureData -> Jpeg PictureData -> Ready

示例代码只实现了其中的以下路径：
Ready -> Preview -> autoFocusing -> Jpeg PictureData -> Ready

因此，AndroidDeviceCameraController 还实现了两个 Camera 接口：Camera.PictureCallback 和 Camera.AutoFocusCallback。
```
public class AndroidDeviceCameraController implements DeviceCameraControl, Camera.PictureCallback, Camera.AutoFocusCallback {
.
.
.
}
```

## 准备 Camera
我们创建 CameraSurface 对象来持有 Camera 对象，并管理 Camera 绘制预览图像的 Surface。
```java
	public class CameraSurface extends SurfaceView implements SurfaceHolder.Callback {
		private Camera camera;

		public CameraSurface( Context context ) {
			super( context );
			// We're implementing the Callback interface and want to get notified
			// about certain surface events.
			getHolder().addCallback( this );
			// We're changing the surface to a PUSH surface, meaning we're receiving
			// all buffer data from another component - the camera, in this case.
			getHolder().setType( SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS );
		}

		public void surfaceCreated( SurfaceHolder holder ) {
			// Once the surface is created, simply open a handle to the camera hardware.
			camera = Camera.open();
		}

		public void surfaceChanged( SurfaceHolder holder, int format, int width, int height ) {
			// This method is called when the surface changes, e.g. when it's size is set.
			// We use the opportunity to initialize the camera preview display dimensions.
			Camera.Parameters p = camera.getParameters();
			p.setPreviewSize( width, height );
			camera.setParameters( p );

			// We also assign the preview display to this surface...
			try {
			    camera.setPreviewDisplay( holder );
			} catch( IOException e ) {
			    e.printStackTrace();
			}
		}

		public void surfaceDestroyed( SurfaceHolder holder ) {
			// Once the surface gets destroyed, we stop the preview mode and release
			// the whole camera since we no longer need it.
			camera.stopPreview();
			camera.release();
			camera = null;
		}

		public Camera getCamera() {
			return camera;
		}
	}
```

只有在调用 `surfaceCreated()` 回调后，通过静态 Camera.open() 方法才能创建相机对象。在此之前相机尚未就绪，不能使用。

## 显示 Camera 预览
调用 `surfaceChanged()` 回调时，我们设置相机预览尺寸，并将 CameraSurface 对象设为 Camera 的预览显示表面。

回到 AndroidDeviceCameraController 类。下面的方法通过创建 CameraSurface 对象（仅在需要时创建）并将其作为 !ContentView 添加到 activity 中来准备 Camera：
```java
	@Override
	public void prepareCamera() {
		if (cameraSurface == null) {
			cameraSurface = new CameraSurface(activity);
		}
		activity.addContentView( cameraSurface, new LayoutParams( LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT ) );
	}
```
该方法应从 libGDX 渲染线程异步调用，因此实际调用 `prepareCameraAsync()` 方法。
```java
	@Override
	public void prepareCameraAsync() {
		Runnable r = new Runnable() {
			public void run() {
				prepareCamera();
			}
		};
		activity.post(r);
	}
```

当 !CameraSurface 和 camera 对象准备就绪时（通过检查 !CameraSurface 和 Camera 对象是否存在），就可以从准备状态进入预览状态：
```java
	@Override
	public boolean isReady() {
		if (cameraSurface!=null && cameraSurface.getCamera() != null) {
			return true;
		}
		return false;
	}
```

通过调用 startPreview 方法对应的异步版本来完成：
```java
	@Override
	public synchronized void startPreviewAsync() {
		Runnable r = new Runnable() {
			public void run() {
				startPreview();
			}
		};
		activity.post(r);
	}
	@Override
	public synchronized void startPreview() {
		// ...and start previewing. From now on, the camera keeps pushing preview
		// images to the surface.
		if (cameraSurface != null && cameraSurface.getCamera() != null) {
			cameraSurface.getCamera().startPreview();
		}
	}
```

在此状态下，用户应该能看到 Camera 预览画面（前提是使用 alpha 分量为 0 的颜色清除了屏幕）。

## 拍照
需要拍照时，先设置合适的 Camera 参数（可以在实际拍照前的任意阶段设置）：
```java
	public void setCameraParametersForPicture(Camera camera) {
		// Before we take the picture - we make sure all camera parameters are as we like them
		// Use max resolution and auto focus
		Camera.Parameters p = camera.getParameters();
		List<Camera.Size> supportedSizes = p.getSupportedPictureSizes();
		int maxSupportedWidth = -1;
		int maxSupportedHeight = -1;
		for (Camera.Size size : supportedSizes) {
			if (size.width > maxSupportedWidth) {
				maxSupportedWidth = size.width;
				maxSupportedHeight = size.height;
			}
		}
		p.setPictureSize(maxSupportedWidth, maxSupportedHeight);
		p.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
		camera.setParameters( p );    	
	}
```

本例使用 Camera 可用的最大分辨率拍照，并将对焦模式设为 AutoFocus。设置相机参数后，调用 camera 的 autoFocus 方法并传入适当的回调。当相机完成对焦或超时后，会调用此回调。
```java
	@Override
	public synchronized void takePicture() {
		// the user request to take a picture - start the process by requesting focus
	    	setCameraParametersForPicture(cameraSurface.getCamera());
	    	cameraSurface.getCamera().autoFocus(this);
	}
```
完成对焦后，调用实际的 Camera takePicture() 方法，并只设置 onJpegPicture 回调。
```java
	@Override
	public synchronized void onAutoFocus(boolean success, Camera camera) {
		// Focus process finished, we now have focus (or not)
		if (success) {
			if (camera != null) {
				camera.stopPreview();
				// We now have focus take the actual picture
				camera.takePicture(null, null, null, this);
			}
		}
	}

	@Override
	public synchronized void onPictureTaken(byte[] pictureData, Camera camera) {
		this.pictureData = pictureData;
	}
```

## 截取 libGDX 屏幕截图
在 render() 方法中，等待 pictureData 对象包含 Jpeg 图像后，再根据数据创建 Pixmap 对象：
```java
	if (deviceCameraControl.getPictureData() != null) { // camera picture was actually taken
		Pixmap cameraPixmap = new Pixmap(deviceCameraControl.getPictureData(), 0, deviceCameraControl.getPictureData().length);
	}
```
然后截取屏幕截图：
```java
	public Pixmap getScreenshot(int x, int y, int w, int h, boolean flipY) {
		Gdx.gl.glPixelStorei(GL10.GL_PACK_ALIGNMENT, 1);

		final Pixmap pixmap = new Pixmap(w, h, Format.RGBA8888);
		ByteBuffer pixels = pixmap.getPixels();
		Gdx.gl.glReadPixels(x, y, w, h, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE, pixels);

		final int numBytes = w * h * 4;
		byte[] lines = new byte[numBytes];
		if (flipY) {
			final int numBytesPerLine = w * 4;
			for (int i = 0; i < h; i++) {
				pixels.position((h - i - 1) * numBytesPerLine);
				pixels.get(lines, i * numBytesPerLine, numBytesPerLine);
			}
			pixels.clear();
			pixels.put(lines);
		} else {
			pixels.clear();
			pixels.get(lines);
		}

		return pixmap;
	}
```

接下来的两个操作会占用 CPU 且耗时，因此最好放到单独线程中，并配合某种进度条。示例代码直接在渲染线程中执行它们，所以处理期间屏幕会冻结。

## 合并屏幕截图与 Camera 图像
现在需要合并两个 Pixmap 对象。libGDX 的 Pixmap 可以完成此操作，但由于相机图像的宽高比可能不同，首先需要手动修正。
```java
	private void merge2Pixmaps(Pixmap mainPixmap, Pixmap overlayedPixmap) {
		// merge to data and Gdx screen shot - but fix Aspect Ratio issues between the screen and the camera
		Pixmap.setFilter(Filter.BiLinear);
		float mainPixmapAR = (float)mainPixmap.getWidth() / mainPixmap.getHeight();
		float overlayedPixmapAR = (float)overlayedPixmap.getWidth() / overlayedPixmap.getHeight();
		if (overlayedPixmapAR < mainPixmapAR) {
			int overlayNewWidth = (int)(((float)mainPixmap.getHeight() / overlayedPixmap.getHeight()) * overlayedPixmap.getWidth());
			int overlayStartX = (mainPixmap.getWidth() - overlayNewWidth)/2;
			mainPixmap.drawPixmap(overlayedPixmap, 
						0, 
						0, 
						overlayedPixmap.getWidth(), 
						overlayedPixmap.getHeight(), 
						overlayStartX, 
						0, 
						overlayNewWidth, 
						mainPixmap.getHeight());
		} else {
			int overlayNewHeight = (int)(((float)mainPixmap.getWidth() / overlayedPixmap.getWidth()) * overlayedPixmap.getHeight());
			int overlayStartY = (mainPixmap.getHeight() - overlayNewHeight)/2;
			mainPixmap.drawPixmap(overlayedPixmap, 
						0, 
						0, 
						overlayedPixmap.getWidth(), 
						overlayedPixmap.getHeight(), 
						0, 
						overlayStartY, 
						mainPixmap.getWidth(), 
						overlayNewHeight);					
		}
	}
```

## 将结果图像保存为 Jpeg
要保存结果图像，可以使用 PixmapIO 类将其写入存储。但 CIM 格式不具备互操作性，而 PNG 格式可能生成非常大的文件。
一种方法是使用 Android Bitmap 类将结果图像保存为 Jpeg。由于这是 Android 专用功能，该方法在 AndroidDeviceCameraController 中实现。
不过，libGDX 的像素格式是 RGBA，而 Bitmap 的像素格式是 ARGB，因此需要调整一些位才能得到正确颜色。
```java
	@Override
	public void saveAsJpeg(FileHandle jpgfile, Pixmap pixmap) {
		FileOutputStream fos;
		int x=0,y=0;
		int xl=0,yl=0;
		try {
			Bitmap bmp = Bitmap.createBitmap(pixmap.getWidth(), pixmap.getHeight(), Bitmap.Config.ARGB_8888);
			// we need to switch between libGDX RGBA format to Android ARGB format
			for (x=0,xl=pixmap.getWidth(); x<xl;x++) {
				for (y=0,yl=pixmap.getHeight(); y<yl;y++) {
					int color = pixmap.getPixel(x, y);
					// RGBA => ARGB
					int RGB = color >> 8;
					int A = (color & 0x000000ff) << 24;
					int ARGB = A | RGB;
					bmp.setPixel(x, y, ARGB);
				}
			}
			// Finished Color format conversion
			fos = new FileOutputStream(jpgfile.file());
			bmp.compress(CompressFormat.JPEG, 90, fos);
			// Finished Comression to JPEG file
			fos.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();			
		}
	}
```

## 停止预览
保存图像后，停止预览并从 Activity 视图中移除 !CameraSurface，同时停止相机向相机表面发送预览。同样，这些操作需要异步执行。
```java
	@Override
	public synchronized void stopPreviewAsync() {
		Runnable r = new Runnable() {
			public void run() {
				stopPreview();
			}
		};
		activity.post(r);
	}

	@Override
	public synchronized void stopPreview() {
        // stop previewing.
		if (cameraSurface != null) {
			if (cameraSurface.getCamera() != null) {
				cameraSurface.getCamera().stopPreview();
			}
			ViewParent parentView = cameraSurface.getParent();
			if (parentView instanceof ViewGroup) {
				ViewGroup viewGroup = (ViewGroup) parentView;
				viewGroup.removeView(cameraSurface);
			}
		}
	}
```

## 修正屏幕与 Camera 分辨率差异
Pixmaps 合并过程仍有一个问题：Camera 和屏幕截图的分辨率可能差异很大（例如我在 Samsung Galaxy Ace 上测试时，将 480x320 的截图拉伸到了 2560x1920 的图像）。一种解决方法是将 libGDX 视图尺寸扩大到大于设备实际物理屏幕尺寸。
这可以通过 setFixedSize() 函数完成。实际可设置的屏幕尺寸取决于分配给 GPU 的内存，具体效果也会因设备而异。
我发现，如果在初始化期间执行一次，就可以将虚拟屏幕尺寸设为 1920x1280，但这样会导致渲染变慢。
另一种方法是仅在 takingPicture 过程中调用 setFixedSize() 函数，之后再恢复原尺寸。不过在这种情况下，我只能将虚拟屏幕尺寸设为 960x640（可能是因为部分 GPU 内存已经分配给原尺寸的屏幕）。

```java
	public void setFixedSize(int width, int height) {
		if (graphics.getView() instanceof SurfaceView) {
			SurfaceView glView = (SurfaceView) graphics.getView();
			glView.getHolder().setFixedSize(width, height);
			glView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
		}
	}

	public void restoreFixedSize() {
		if (graphics.getView() instanceof SurfaceView) {
			SurfaceView glView = (SurfaceView) graphics.getView();
			glView.getHolder().setFixedSize(origWidth, origHeight);
			glView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
		}
	}
```

## 说明

### 注意
此代码专用于 Android，无法与通用跨平台代码一起工作；不过至少对于桌面应用，应该可以提供类似功能。

### 另一条说明
由于 libGDX 颜色方案（RGBA）与此处使用的 Bitmap 类（ARGB）格式不匹配，合并图像并写入存储的过程相当耗时。如果有人找到更快的方法，我很乐意听到。

### 最后一条说明
我只在少数 Android 设备上测试过，可能由于 GPU 实现不同而遇到了不同表现。Samsung GSIII 甚至会将白色元素与相机图像执行 XOR，而不是简单叠加（其他颜色没有出现这种现象）。因此，实际效果可能因所用手机而异。

# 代码

下面是项目中各类的完整代码：

## Android 项目

MainActivity.java:
```java
/*
 * Copyright 2012 Johnny Lish (johnnyoneeyed@gmail.com)
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

package com.johnny.camerademo;

import android.graphics.PixelFormat;
import android.os.Bundle;
import android.view.SurfaceView;

import com.badlogic.gdx.backends.android.AndroidApplication;
import com.badlogic.gdx.backends.android.AndroidApplicationConfiguration;

public class MainActivity extends AndroidApplication {
    private int origWidth;
	private int origHeight;

	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        AndroidApplicationConfiguration cfg = new AndroidApplicationConfiguration();
        cfg.useGL20 = false;
        // we need to change the default pixel format - since it does not include an alpha channel 
        // we need the alpha channel so the camera preview will be seen behind the GL scene
        cfg.r = 8;
        cfg.g = 8;
        cfg.b = 8;
        cfg.a = 8;
        
        DeviceCameraControl cameraControl = new AndroidDeviceCameraController(this);
        initialize(new CameraDemo(cameraControl), cfg);

        if (graphics.getView() instanceof SurfaceView) {
        	SurfaceView glView = (SurfaceView) graphics.getView();
			// force alpha channel - I'm not sure we need this as the GL surface is already using alpha channel
			glView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
		}
        // we don't want the screen to turn off during the long image saving process 
        graphics.getView().setKeepScreenOn(true);
        // keep the original screen size  
    	origWidth = graphics.getWidth();
    	origHeight = graphics.getHeight();
    }
    
    public void post(Runnable r) {
    	handler.post(r);
    }
    
    public void setFixedSize(int width, int height) {
        if (graphics.getView() instanceof SurfaceView) {
        	SurfaceView glView = (SurfaceView) graphics.getView();
			glView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
        	glView.getHolder().setFixedSize(width, height);
        }
    }

    public void restoreFixedSize() {
        if (graphics.getView() instanceof SurfaceView) {
        	SurfaceView glView = (SurfaceView) graphics.getView();
			glView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
        	glView.getHolder().setFixedSize(origWidth, origHeight);
        }
    }
}
```

CameraSurface.java:
```java
/*
 * Copyright 2012 Johnny Lish (johnnyoneeyed@gmail.com)
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

package com.johnny.camerademo;

import java.io.IOException;

import android.content.Context;
import android.hardware.Camera;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

public class CameraSurface extends SurfaceView implements SurfaceHolder.Callback {
    private Camera camera;
 
    public CameraSurface( Context context ) {
        super( context );
        // We're implementing the Callback interface and want to get notified
        // about certain surface events.
        getHolder().addCallback( this );
        // We're changing the surface to a PUSH surface, meaning we're receiving
        // all buffer data from another component - the camera, in this case.
        getHolder().setType( SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS );
    }
 
    public void surfaceCreated( SurfaceHolder holder ) {
        // Once the surface is created, simply open a handle to the camera hardware.
        camera = Camera.open();
    }
 
    public void surfaceChanged( SurfaceHolder holder, int format, int width, int height ) {
        // This method is called when the surface changes, e.g. when it's size is set.
        // We use the opportunity to initialize the camera preview display dimensions.
        Camera.Parameters p = camera.getParameters();
        p.setPreviewSize( width, height );
        camera.setParameters( p );
 
        // We also assign the preview display to this surface...
        try {
            camera.setPreviewDisplay( holder );
        } catch( IOException e ) {
            e.printStackTrace();
        }
    }
 
    public void surfaceDestroyed( SurfaceHolder holder ) {
        // Once the surface gets destroyed, we stop the preview mode and release
        // the whole camera since we no longer need it.
        camera.stopPreview();
        camera.release();
        camera = null;
    }

	public Camera getCamera() {
		return camera;
	}

}
```

AndroidDeviceCameraController.java
```java
/*
 * Copyright 2012 Johnny Lish (johnnyoneeyed@gmail.com)
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

package com.johnny.camerademo;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import com.badlogic.gdx.files.FileHandle;
import com.badlogic.gdx.graphics.Pixmap;

import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.hardware.Camera;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.ViewGroup.LayoutParams;

public class AndroidDeviceCameraController implements DeviceCameraControl, Camera.PictureCallback, Camera.AutoFocusCallback {

	private static final int ONE_SECOND_IN_MILI = 1000;
	private final MainActivity activity;
    private CameraSurface cameraSurface;
	private byte[] pictureData;

	public AndroidDeviceCameraController(MainActivity activity) {
		this.activity = activity;
	}

	@Override
	public synchronized void prepareCamera() {
		activity.setFixedSize(960,640);
		if (cameraSurface == null) {
			cameraSurface = new CameraSurface(activity);
		}
		activity.addContentView( cameraSurface, new LayoutParams( LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT ) );
	}

	@Override
	public synchronized void startPreview() {
		// ...and start previewing. From now on, the camera keeps pushing preview
		// images to the surface.
		if (cameraSurface != null && cameraSurface.getCamera() != null) {
			cameraSurface.getCamera().startPreview();
		}
	}

	@Override
	public synchronized void stopPreview() {
        // stop previewing.
        if (cameraSurface != null) {
			ViewParent parentView = cameraSurface.getParent();
			if (parentView instanceof ViewGroup) {
				ViewGroup viewGroup = (ViewGroup) parentView;
				viewGroup.removeView(cameraSurface);
			}
			if (cameraSurface.getCamera() != null) {
				cameraSurface.getCamera().stopPreview();
			}
        }
		activity.restoreFixedSize();
	}

    public void setCameraParametersForPicture(Camera camera) {
        // Before we take the picture - we make sure all camera parameters are as we like them
    	// Use max resolution and auto focus
        Camera.Parameters p = camera.getParameters();
        List<Camera.Size> supportedSizes = p.getSupportedPictureSizes();
        int maxSupportedWidth = -1;
        int maxSupportedHeight = -1;
        for (Camera.Size size : supportedSizes) {
        	if (size.width > maxSupportedWidth) {
        		maxSupportedWidth = size.width;
        		maxSupportedHeight = size.height;
        	}
        }
    	p.setPictureSize(maxSupportedWidth, maxSupportedHeight);
    	p.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
        camera.setParameters( p );    	
    }

	@Override
	public synchronized void takePicture() {
		// the user request to take a picture - start the process by requesting focus
    		setCameraParametersForPicture(cameraSurface.getCamera());
    		cameraSurface.getCamera().autoFocus(this);
	}

	@Override
	public synchronized void onAutoFocus(boolean success, Camera camera) {
		// Focus process finished, we now have focus (or not)
		if (success) {
			if (camera != null) {
				camera.stopPreview();
				// We now have focus take the actual picture
				camera.takePicture(null, null, null, this);
			}
		}
	}

	@Override
	public synchronized void onPictureTaken(byte[] pictureData, Camera camera) {
		// We got the picture data - keep it
		this.pictureData = pictureData;
	}

	@Override
	public synchronized byte[] getPictureData() {
		// Give to picture data to whom ever requested it
		return pictureData;
	}

	@Override
	public void prepareCameraAsync() {
		Runnable r = new Runnable() {
			public void run() {
				prepareCamera();
			}
		};
		activity.post(r);
	}

	@Override
	public synchronized void startPreviewAsync() {
		Runnable r = new Runnable() {
			public void run() {
				startPreview();
			}
		};
		activity.post(r);
	}

	@Override
	public synchronized void stopPreviewAsync() {
		Runnable r = new Runnable() {
			public void run() {
				stopPreview();
			}
		};
		activity.post(r);
	}

	@Override
	public synchronized byte[] takePictureAsync(long timeout) {
		timeout *= ONE_SECOND_IN_MILI;
		pictureData = null;
		Runnable r = new Runnable() {
			public void run() {
				takePicture();
			}
		};
		activity.post(r);
		while (pictureData == null && timeout > 0) {
			try {
				Thread.sleep(ONE_SECOND_IN_MILI);
				timeout -= ONE_SECOND_IN_MILI;
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		if (pictureData == null) {
			cameraSurface.getCamera().cancelAutoFocus();
		}
		return pictureData;
	}

	@Override
	public void saveAsJpeg(FileHandle jpgfile, Pixmap pixmap) {
		FileOutputStream fos;
		int x=0,y=0;
		int xl=0,yl=0;
		try {
			Bitmap bmp = Bitmap.createBitmap(pixmap.getWidth(), pixmap.getHeight(), Bitmap.Config.ARGB_8888);
			// we need to switch between libGDX RGBA format to Android ARGB format
			for (x=0,xl=pixmap.getWidth(); x<xl;x++) {
				for (y=0,yl=pixmap.getHeight(); y<yl;y++) {
					int color = pixmap.getPixel(x, y);
					// RGBA => ARGB
					int RGB = color >> 8;
					int A = (color & 0x000000ff) << 24;
					int ARGB = A | RGB;
					bmp.setPixel(x, y, ARGB);
				}
			}
			fos = new FileOutputStream(jpgfile.file());
			bmp.compress(CompressFormat.JPEG, 90, fos);
			fos.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();			
		}
	}

	@Override
	public boolean isReady() {
		if (cameraSurface!=null && cameraSurface.getCamera() != null) {
			return true;
		}
		return false;
	}
}
```

## 基础项目
DeviceCameraControl.java
```java
/*
 * Copyright 2012 Johnny Lish (johnnyoneeyed@gmail.com)
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

package com.johnny.camerademo;

import com.badlogic.gdx.files.FileHandle;
import com.badlogic.gdx.graphics.Pixmap;

public interface DeviceCameraControl {

	// Synchronous interface
	void prepareCamera();

	void startPreview();

	void stopPreview();

	void takePicture();

	byte[] getPictureData();

	// Asynchronous interface - need when called from a non platform thread (GDX OpenGl thread)
	void startPreviewAsync();

	void stopPreviewAsync();

	byte[] takePictureAsync(long timeout);

	void saveAsJpeg(FileHandle jpgfile, Pixmap cameraPixmap);

	boolean isReady();

	void prepareCameraAsync();
}
```

CameraDemo.java:

```java
/*
 * Copyright 2012 Johnny Lish (johnnyoneeyed@gmail.com)
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

package com.johnny.camerademo;

import java.nio.ByteBuffer;

import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.files.FileHandle;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Mesh;
import com.badlogic.gdx.graphics.PerspectiveCamera;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.Texture.TextureFilter;
import com.badlogic.gdx.graphics.VertexAttribute;
import com.badlogic.gdx.graphics.Pixmap.Filter;
import com.badlogic.gdx.graphics.Pixmap.Format;
import com.badlogic.gdx.graphics.VertexAttributes.Usage;

public class CameraDemo implements ApplicationListener {

	public enum Mode {
		normal,
		prepare,
		preview,
		takePicture, 
		waitForPictureReady, 
	}

	public static final float vertexData[] = {   
		1.0f,  1.0f,  1.0f, Color.toFloatBits(255,255,255,255),  0.0f, 0.0f, // quad/face 0/Vertex 0 
		0.0f,  1.0f,  1.0f, Color.toFloatBits(255,255,255,255),  0.0f, 1.0f, // quad/face 0/Vertex 1
		0.0f,  0.0f,  1.0f, Color.toFloatBits(255,255,255,255),  1.0f, 1.0f, // quad/face 0/Vertex 2
		1.0f,  0.0f,  1.0f, Color.toFloatBits(255,255,255,255),  1.0f, 0.0f, // quad/face 0/Vertex 3

		1.0f,  1.0f,  1.0f, Color.toFloatBits(255,255,255,255),  1.0f, 1.0f, // quad/face 1/Vertex 4
		1.0f,  0.0f,  1.0f, Color.toFloatBits(255,255,255,255),  0.0f, 1.0f, // quad/face 1/Vertex 5
		1.0f,  0.0f,  0.0f, Color.toFloatBits(255,255,255,255),  0.0f, 0.0f, // quad/face 1/Vertex 6
		1.0f,  1.0f,  0.0f, Color.toFloatBits(255,255,255,255),  1.0f, 0.0f, // quad/face 1/Vertex 7
		
		1.0f,  1.0f,  1.0f, Color.toFloatBits(255,255,255,255),  0.0f, 0.0f, // quad/face 2/Vertex 8
		1.0f,  1.0f,  0.0f, Color.toFloatBits(255,255,255,255),  0.0f, 1.0f, // quad/face 2/Vertex 9
		0.0f,  1.0f,  0.0f, Color.toFloatBits(255,255,255,255),  1.0f, 1.0f, // quad/face 2/Vertex 10
		0.0f,  1.0f,  1.0f, Color.toFloatBits(255,255,255,255),  1.0f, 0.0f, // quad/face 2/Vertex 11
		
		1.0f,  0.0f,  0.0f, Color.toFloatBits(255,255,255,255),  1.0f, 1.0f, // quad/face 3/Vertex 12
		0.0f,  0.0f,  0.0f, Color.toFloatBits(255,255,255,255),  0.0f, 1.0f, // quad/face 3/Vertex 13
		0.0f,  1.0f,  0.0f, Color.toFloatBits(255,255,255,255),  0.0f, 0.0f, // quad/face 3/Vertex 14
		1.0f,  1.0f,  0.0f, Color.toFloatBits(255,255,255,255),  1.0f, 0.0f, // quad/face 3/Vertex 15

		0.0f,  1.0f,  1.0f, Color.toFloatBits(255,255,255,255),  1.0f, 1.0f, // quad/face 4/Vertex 16
		0.0f,  1.0f,  0.0f, Color.toFloatBits(255,255,255,255),  0.0f, 1.0f, // quad/face 4/Vertex 17
		0.0f,  0.0f,  0.0f, Color.toFloatBits(255,255,255,255),  0.0f, 0.0f, // quad/face 4/Vertex 18
		0.0f,  0.0f,  1.0f, Color.toFloatBits(255,255,255,255),  1.0f, 0.0f, // quad/face 4/Vertex 19
		
		0.0f,  0.0f,  0.0f, Color.toFloatBits(255,255,255,255),  1.0f, 1.0f, // quad/face 5/Vertex 20
		1.0f,  0.0f,  0.0f, Color.toFloatBits(255,255,255,255),  0.0f, 1.0f, // quad/face 5/Vertex 21
		1.0f,  0.0f,  1.0f, Color.toFloatBits(255,255,255,255),  0.0f, 0.0f, // quad/face 5/Vertex 22
		0.0f,  0.0f,  1.0f, Color.toFloatBits(255,255,255,255),  1.0f, 0.0f, // quad/face 5/Vertex 23
	};


	public static final short facesVerticesIndex[][] = {
		{ 0, 1, 2, 3 },
		{ 4, 5, 6, 7 },
		{ 8, 9, 10, 11 },
		{ 12, 13, 14, 15 },
		{ 16, 17, 18, 19 },
		{ 20, 21, 22, 23 }
	};

	private final static VertexAttribute verticesAttributes[] = new VertexAttribute[] { 
		new VertexAttribute(Usage.Position, 3, "a_position"), 
		new VertexAttribute(Usage.ColorPacked, 4, "a_color"),
		new VertexAttribute(Usage.TextureCoordinates, 2, "a_texCoords"),
	};


	private Texture texture;


	private Mesh[] mesh = new Mesh[6];


	private PerspectiveCamera camera;


	private Mode mode = Mode.normal;


	private final DeviceCameraControl deviceCameraControl;


	public CameraDemo(DeviceCameraControl cameraControl) {
		this.deviceCameraControl = cameraControl;
	}

	@Override
	public void create() {		
		
		// Load the libGDX splash screen texture
		texture = new Texture(Gdx.files.internal("data/libgdx.png"));
		texture.setFilter(TextureFilter.Linear, TextureFilter.Linear);
	
		// Create the 6 faces of the Cube
		for (int i=0;i<6;i++) {
			mesh[i] = new Mesh(true, 24, 4, verticesAttributes);
			mesh[i].setVertices(vertexData);
			mesh[i].setIndices(facesVerticesIndex[i]);
		}
		
		// Create the OpenGL Camera
		camera = new PerspectiveCamera(67.0f, 2.0f * Gdx.graphics.getWidth() / Gdx.graphics.getHeight(), 2.0f);
		camera.far = 100.0f;
		camera.near = 0.1f;
		camera.position.set(2.0f,2.0f,2.0f);
        camera.lookAt(0.0f, 0.0f, 0.0f);

	}

	@Override
	public void dispose() {
		texture.dispose();
		for (int i=0;i<6;i++) {
			mesh[i].dispose();
			mesh[i] = null;
		}
		texture = null;
	}

	@Override
	public void render() {		
		if (Gdx.input.isTouched()) {
			if (mode == Mode.normal) {
				mode = Mode.prepare;
				if (deviceCameraControl != null) {
					deviceCameraControl.prepareCameraAsync();
				}
			}
		} else { // touch removed
			if (mode == Mode.preview) {
				mode = Mode.takePicture;
			}
		}

		Gdx.gl10.glHint(GL10.GL_PERSPECTIVE_CORRECTION_HINT, GL10.GL_NICEST);
		if (mode == Mode.takePicture) {
			Gdx.gl10.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
			if (deviceCameraControl != null) {
				deviceCameraControl.takePicture();
			}
			mode = Mode.waitForPictureReady;
		} else if (mode == Mode.waitForPictureReady) {
			Gdx.gl10.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);			
		} else if (mode == Mode.prepare) {
			Gdx.gl10.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
			if (deviceCameraControl != null) {
				if (deviceCameraControl.isReady()) {
					deviceCameraControl.startPreviewAsync();
					mode = Mode.preview;
				}
			}
		} else if (mode == Mode.preview) {
			Gdx.gl10.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		} else { // mode = normal
			Gdx.gl10.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		}
		Gdx.gl10.glClear(GL10.GL_COLOR_BUFFER_BIT | GL10.GL_DEPTH_BUFFER_BIT);
		Gdx.gl10.glEnable(GL10.GL_DEPTH_TEST);
		Gdx.gl10.glEnable(GL10.GL_TEXTURE);			
		Gdx.gl10.glEnable(GL10.GL_TEXTURE_2D);			
		Gdx.gl10.glEnable(GL10.GL_LINE_SMOOTH);
		Gdx.gl10.glDepthFunc(GL10.GL_LEQUAL);
		Gdx.gl10.glClearDepthf(1.0F);
		camera.update(true);
		camera.apply(Gdx.gl10);
		texture.bind();
		for (int i=0;i<6;i++) {
			mesh[i].render(GL10.GL_TRIANGLE_FAN, 0 ,4);
		}
		if (mode == Mode.waitForPictureReady) {
			if (deviceCameraControl.getPictureData() != null) { // camera picture was actually taken
				// take Gdx Screenshot
				Pixmap screenshotPixmap = getScreenshot(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight(), true);
				Pixmap cameraPixmap = new Pixmap(deviceCameraControl.getPictureData(), 0, deviceCameraControl.getPictureData().length);
				merge2Pixmaps(cameraPixmap, screenshotPixmap);
				// we could call PixmapIO.writePNG(pngfile, cameraPixmap);
				FileHandle jpgfile = Gdx.files.external("libGdxSnapshot.jpg");
				deviceCameraControl.saveAsJpeg(jpgfile, cameraPixmap);
				deviceCameraControl.stopPreviewAsync();
				mode = Mode.normal;
			}
		}
	}
	
	private Pixmap merge2Pixmaps(Pixmap mainPixmap, Pixmap overlayedPixmap) {
		// merge to data and Gdx screen shot - but fix Aspect Ratio issues between the screen and the camera
		Pixmap.setFilter(Filter.BiLinear);
		float mainPixmapAR = (float)mainPixmap.getWidth() / mainPixmap.getHeight();
		float overlayedPixmapAR = (float)overlayedPixmap.getWidth() / overlayedPixmap.getHeight();
		if (overlayedPixmapAR < mainPixmapAR) {
			int overlayNewWidth = (int)(((float)mainPixmap.getHeight() / overlayedPixmap.getHeight()) * overlayedPixmap.getWidth());
			int overlayStartX = (mainPixmap.getWidth() - overlayNewWidth)/2;
			// Overlaying pixmaps
			mainPixmap.drawPixmap(overlayedPixmap, 0, 0, overlayedPixmap.getWidth(), overlayedPixmap.getHeight(), overlayStartX, 0, overlayNewWidth, mainPixmap.getHeight());
		} else {
			int overlayNewHeight = (int)(((float)mainPixmap.getWidth() / overlayedPixmap.getWidth()) * overlayedPixmap.getHeight());
			int overlayStartY = (mainPixmap.getHeight() - overlayNewHeight)/2;
			// Overlaying pixmaps
			mainPixmap.drawPixmap(overlayedPixmap, 0, 0, overlayedPixmap.getWidth(), overlayedPixmap.getHeight(), 0, overlayStartY, mainPixmap.getWidth(), overlayNewHeight);					
		}
		return mainPixmap;
	}

	public Pixmap getScreenshot(int x, int y, int w, int h, boolean flipY) {
		Gdx.gl.glPixelStorei(GL10.GL_PACK_ALIGNMENT, 1);

		final Pixmap pixmap = new Pixmap(w, h, Format.RGBA8888);
		ByteBuffer pixels = pixmap.getPixels();
		Gdx.gl.glReadPixels(x, y, w, h, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE, pixels);

		final int numBytes = w * h * 4;
		byte[] lines = new byte[numBytes];
		if (flipY) {
			final int numBytesPerLine = w * 4;
			for (int i = 0; i < h; i++) {
				pixels.position((h - i - 1) * numBytesPerLine);
				pixels.get(lines, i * numBytesPerLine, numBytesPerLine);
			}
			pixels.clear();
			pixels.put(lines);
		} else {
			pixels.clear();
			pixels.get(lines);
		}

		return pixmap;
	}

	@Override
	public void resize(int width, int height) {
		camera = new PerspectiveCamera(67.0f, 2.0f * width / height, 2.0f);
		camera.far = 100.0f;
		camera.near = 0.1f;
		camera.position.set(2.0f,2.0f,2.0f);
        camera.lookAt(0.0f, 0.0f, 0.0f);

	}

	@Override
	public void pause() {
	}

	@Override
	public void resume() {
	}
}
```
