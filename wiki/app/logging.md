---
title: 日志记录
---
`Application` 接口提供简单的日志功能，可以细粒度地控制要记录哪些消息。

消息可以是普通的**信息消息**、带可选异常的**错误消息**或**调试消息**：

```java
Gdx.app.log("MyTag", "my informative message");
Gdx.app.error("MyTag", "my error message", exception);
Gdx.app.debug("MyTag", "my debug message");
```

在桌面端，消息会记录到控制台；在 Android 上记录到 LogCat；在 GWT 上则记录到浏览器控制台，或记录到 `GwtApplicationConfiguration` 提供的 `TextArea`。

可以将日志限制为特定级别：

```java
Gdx.app.setLogLevel(logLevel);
```

其中 `logLevel` 可以是以下值之一：

  * `Application.LOG_DEBUG`：记录所有消息。
  * `Application.LOG_INFO`：记录错误消息和普通消息。
  * `Application.LOG_ERROR`：仅记录错误消息。
  * `Application.LOG_NONE`：禁用所有日志。
