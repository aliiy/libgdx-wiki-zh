---
permalink: /dev/issues/
title: "报告 Issue"
classes: wide
header:
  overlay_color: "#000"
  overlay_filter: "0.3"
  overlay_image: /assets/images/dev/dev.jpeg
  caption: "图片来源：[**Florian Olivo**](https://unsplash.com/photos/Ek9Znm8lQ1U)"

sidebar:
  nav: "dev"
---

{% include breadcrumbs.html %}

请注意，issue tracker 不是用来寻求个人帮助的。如果你遇到的问题不是核心框架中可复现的 bug，请到我们的 [Discord](/community/discord/) 服务器上提问。
{: .notice--info}

在我们的 [issue tracker](https://github.com/libgdx/libgdx/issues) 上报告 issue 之前，请你先做几件事：
- 确认这个问题还没有人在 tracker 上报告过。如果已经有人报告，请在已有的 issue 下补充你自己的信息，而不要新建一个 issue。添加一个 [reaction](https://github.blog/2016-03-10-add-reactions-to-pull-requests-issues-and-comments/) 也有助于表明某个问题影响的不止一位用户。
- 确认这个 bug 还没有被修复。请使用 libGDX 的最新快照（snapshot）尝试复现你的 issue。
- 创建一个简洁、自包含的示例来演示这个问题。如果我们无法复现你的 issue，就无法修复它。

完成之后，在项目中[新建一个 issue](https://github.com/libgdx/libgdx/issues/new)，并按照所显示模板中的指引填写，帮助我们分流处理你的 issue。
