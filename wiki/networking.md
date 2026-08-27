---
title: 网络
---
libGDX 包含一些用于跨平台网络操作的类。这些类通常称为 [Gdx.net](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Net.html) [(源码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/Net.java)

# 功能

* 跨平台 HTTP 请求
* 多平台 TCP 客户端和服务器套接字支持（不包括 GWT），并提供可配置设置
* 面向低延迟优化的 TCP 客户端和服务器设置
* 跨平台浏览器访问。（例如：可以在游戏中创建指向网站的链接，并在所有平台上打开浏览器。）

## 实现
类说明：
* [Net.java](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/Net.java) 是用于跨平台网络操作的接口，可从中获取与网络通信所需的对象。
* [Socket.java](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/net/Socket.java) 是一个接口，提供远程套接字地址、连接状态，以及用于操作套接字的 java.io.InputStream 和 java.io.OutputStream。
* [SocketHints.java](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/net/SocketHints.java) 是用于配置 TCP 客户端套接字的类。
* [ServerSocket.java](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/net/ServerSocket.java) 是用于创建 TCP 服务器套接字的接口，提供标准的 accept() 方法来获取已连接的 TCP 客户端。
* [ServerSocketHints.java](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/net/ServerSocketHints.java) 是用于配置 TCP 服务器套接字的类。
* [HttpStatus.java](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/net/HttpStatus.java) 是用于方便查看返回状态码的类。
* [HttpParameterUtils.java](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/net/HttpParametersUtils.java) 是为 HTTP 请求提供实用方法的类。
* [HttpRequestBuilder](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/net/HttpRequestBuilder.java) 是用于创建 `HttpRequests` 的类。

要创建 TCP 客户端套接字，请使用以下代码：
```java
Socket socket = Gdx.net.newClientSocket(Protocol protocol, String host, int port, SocketHints hints);
```

要创建 TCP 服务器套接字，请使用：
```
ServerSocket server = Gdx.net.newServerSocket(Protocol protocol, int port, ServerSocketHints hints);
```

要发送 HTTP 请求，请使用：
```java
HttpRequestBuilder requestBuilder = new HttpRequestBuilder();
HttpRequest httpRequest = requestBuilder.newRequest().method(HttpMethods.GET).url("https://www.google.de").build();
Gdx.net.sendHttpRequest(httpRequest, httpResponseListener);
```

要发送带参数的 GET HTTP 请求，请使用：
```java
HttpRequestBuilder requestBuilder = new HttpRequestBuilder();
HttpRequest httpRequest = requestBuilder.newRequest().method(HttpMethods.GET).url("https://www.google.de").content("q=libgdx&example=example").build();
Gdx.net.sendHttpRequest(httpRequest, httpResponseListener);
```
要打开系统浏览器，请使用：
```java
Gdx.net.openURI(String URI)
```

## 接收响应

有多种方式可以灵活地接收上述 HTTP 请求的响应。以下是 Kotlin 示例。

1. 通过实现 [HttpResponseListener](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Net.HttpResponseListener.html) 的类

   为此，需要创建一个实现 `HTTPResponseListener` 的类，然后将该类的实例作为方法参数传入。

   ```kotlin
   class MyReceiverOfResult : HttpResponseListener {
      override fun cancelled() {
       // 请求取消时执行某些操作
      }

      override fun failed(t: Throwable?) {
           // 请求失败时执行某些操作
      }

      override fun handleHttpResponse(httpResponse: Net.HttpResponse) {
           // 收到结果时执行某些操作
      }
   }

   ...

    // 假设你将此类的实例保存为名为 `receiver` 的变量。
    // 然后只需将其传给 `sendHttpRequest()` 方法
   Gdx.net.sendHttpRequest(req, receiver)
   ```
2. 匿名对象
   ```kotlin
   Gdx.net.sendHttpRequest(req, object: Net.HttpResponseListener {
         override fun cancelled() {
              // 请求取消时执行某些操作
         }

         override fun failed(t: Throwable?) {
              // 请求失败时执行某些操作
         }

         override fun handleHttpResponse(httpResponse: Net.HttpResponse) {
              // 收到结果时执行某些操作
         }
      })
   ```
具体采用哪种方式取决于用例以及你认为哪种方式更灵活。

### 注意事项
在不同平台上使用网络功能时需要注意以下事项。

1. TCP 客户端和服务器套接字在 GWT 上**无法工作**。这是因为 GWT 不支持 java.net，目前除 WebSocket 外没有可行替代方案。
2. 无头后端、Android Daydream 和 Android 动态壁纸不支持打开浏览器。这是实现和/或平台限制所致。
3. 在 Android 上：要访问网络，必须在 AndroidManifest.xml 文件中声明以下权限：`<uses-permission android:name="android.permission.INTERNET" /> `
4. 在 Android 上：如果不禁用 strict mode，**不能**在主线程访问网络。这是为了防止网络操作阻塞主线程。请参阅[此处](https://developer.android.com/reference/android/os/StrictMode)。
5. 面向移动设备时：请谨慎实现网络功能。无线电模块开启时本身会大量耗电；对于 1G/2G/3G/4G LTE 网络可能存在的数据流量限制也要加以注意。libGDX 已进行了配置优化，使其能够实现低延迟，同时保留 TCP 的优势。
6. 支持的网络配置因后端和 Java 实现而异。
7. 由于无线电模块需要耗电，发送和接收数据时更容易消耗电池。
8. 请务必为 `POST` 请求设置 `Content-Type` 标头。由于底层实现存在差异，不同后端的默认值可能并不相同。该标头最常见的值是 `application/x-www-form-urlencoded`；不过，根据发送数据的类型，可能需要使用其他值（例如 `application/xml` 或 `application/json`）。

**另请参阅**

关于移动数据与电池效率的优秀文章请参阅[此处](https://developer.android.com/training/efficient-downloads/index.html)。

Gdx.net 类的源代码请参阅[此处](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/net)。
