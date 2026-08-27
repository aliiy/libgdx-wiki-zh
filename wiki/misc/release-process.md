---
title: 发布流程
# 不列入目录，但通过 /dev/contributing/ 链接
---
1. 按照[此提交](https://github.com/libgdx/libgdx/commit/6b14c4b3fc76171dadbdeb60d45efc3da88fd5e)中的示例，将 Java 文件中的版本字符串更新为下一个发布版本。
2. 在 [GitHub 上创建新发布](https://github.com/libgdx/libgdx/releases)。
3. GitHub 会启动事件为 "release" 的 "Build and publish" 工作流，构建并将所有内容发布到 Sonatype 和 AWS。等待构建完成。
4. 登录 http://oss.sonatype.com（向 Mario 索取用户名和密码），并按[此处](https://central.sonatype.org/publish/publish-guide/#SonatypeOSSMavenRepositoryUsageGuide-8a.ReleaseIt)的说明操作。
   
    Sonatype 的凭据可向 Mario Zechner（badlogicgames@gmail.com）获取。
   {: .notice--info}

之后需要创建一篇新的更新日志文章。更多信息请参阅[此页面](https://github.com/libgdx/libgdx.github.io/wiki/Posts#changelogs)！
