---
permalink: /history/
title: "历史"
classes: wide2
header:
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: /assets/images/history.jpeg
  caption: "图片来源：[**Mr Cup / Fabien Barral**](https://unsplash.com/photos/Fo5dTm6ID1Y)"
excerpt: "libGDX 项目自 10 多年前启动以来，libGDX 及其社区已日趋成熟：如今，libGDX 是一个久经考验、稳定可靠的框架，拥有扎实的基础和完善的文档。"
---

<style>
/* https://www.w3schools.com/howto/howto_css_timeline.asp */
* {
  box-sizing: border-box;
}

/* The actual timeline (the vertical ruler) */
.timeline {
  position: relative;
  max-width: 1200px;
  margin: 0 auto;
}

/* The actual timeline (the vertical ruler) */
.timeline::after {
  content: '';
  position: absolute;
  width: 6px;
  background-color: #e8e8e8;
  top: 0;
  bottom: 0;
  left: 50%;
  margin-left: -3px;
  z-index: -1;
}

/* Container around content */
.container {
  padding: 10px 40px;
  position: relative;
  background-color: inherit;
  width: 50%;
}

/* The circles on the timeline */
.container::after {
  content: '';
  position: absolute;
  width: 25px;
  height: 25px;
  right: -17px;
  background-color: #e8e8e8;
  border: 4px solid #f5370c;
  top: 15px;
  border-radius: 50%;
  z-index: 1;
}

/* Place the container to the left */
.left {
  left: 0;
}

/* Place the container to the right */
.right {
  left: 50%;
}

/* Add arrows to the left container (pointing right) */
.left::before {
  content: " ";
  height: 0;
  position: absolute;
  top: 22px;
  width: 0;
  z-index: 1;
  right: 30px;
  border: medium solid #9da3a8;
  border-width: 10px 0 10px 10px;
  border-color: transparent transparent transparent #9da3a8;
}

/* Add arrows to the right container (pointing left) */
.right::before {
  content: " ";
  height: 0;
  position: absolute;
  top: 22px;
  width: 0;
  z-index: 1;
  left: 30px;
  border: medium solid #9da3a8;
  border-width: 10px 10px 10px 0;
  border-color: transparent #9da3a8 transparent transparent;
}

/* Fix the circle for containers on the right side */
.right::after {
  left: -16px;
}

/* The actual content */
.content {
  padding:  1px 18px;
  background-color: #9da3a8;
  position: relative;
  border-radius: 6px;
  color: white;
  font-size: 18px;
}

/* Media queries - Responsive timeline on screens less than 600px wide */
@media screen and (max-width: 600px) {
  /* Place the timelime to the left */
  .timeline::after {
  left: 31px;
  }

  /* Full-width containers */
  .container {
  width: 100%;
  padding-left: 70px;
  padding-right: 25px;
  }

  /* Make sure that all arrows are pointing leftwards */
  .container::before {
  left: 60px;
  border: medium solid #9da3a8;
  border-width: 10px 10px 10px 0;
  border-color: transparent #9da3a8 transparent transparent;
  }

  /* Make sure all circles are at the same spot */
  .left::after, .right::after {
  left: 15px;
  }

  /* Make all right containers behave like the left ones */
  .right {
  left: 0%;
  }
}

p a {
  color: #e83107;
}
p a:visited {
  color: #e83107;
}
p a:hover {
  color: #ff4c24;
}
p a:active {
  color: #ff4c24;
}
</style>

<link rel="stylesheet" href="/assets/css/aos.css" />

<div class="timeline">
  <div class="container right" data-aos="zoom-in-right" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2023</h2>
      <p>2023 年，我们不仅发布了 libGDX 的 <a href="/news/2023/07/gdx-1-12">1.12.0</a> 和 <a href="/news/2023/11/gdx-1-12-1">1.12.1</a> 版本，raeleus 还彻底<a href="/news/2023/11/devlog-9-new-particle-editor">重制了我们的粒子编辑器</a>。</p>
    </div>
  </div>
  <div class="container left" data-aos="zoom-in-left" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2022</h2>
      <p>2022 年为大家带来了 libGDX 的 <a href="/news/2022/05/gdx-1-11">1.11</a> 版本。随着该版本发布，<a href="/news/2021/07/devlog-7-lwjgl3">LWJGL 3</a> 成为默认的桌面后端——这项工作从 2015 年就开始酝酿了。我们还非常自豪地宣布了<a href="/news/2022/02/jam-march-2022">第 20 届 libGDX 游戏 Jam</a>。此外，年初时我们把<a href="/news/2022/01/devlog-8-wiki-migration">wiki 迁移</a>到了本网站。</p>
    </div>
  </div>
  <div class="container right" data-aos="zoom-in-right" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2021</h2>
      <p>2021 年，我们发布了 <a href="/news/2021/01/gdx_1_9_13">1.9.13</a>、<a href="/news/2021/02/gdx-1-9-14">1.9.14</a>，以及最引人注目的 <a href="/news/2021/04/gdx-1-10">1.10</a> 版本。在此过程中，我们还将整个构建体系迁移到了 GitHub Actions，使其更加健壮、更面向未来。我们还在网站上推出了<a href="/news/2021/01/devlog_5_community_showcases">社区展示</a>，让一些围绕 libGDX 的有趣社区项目有机会向更广泛的受众展示自己。</p>
    </div>
  </div>
  <div class="container left" data-aos="zoom-in-left" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2020 - 新的开始</h2>
      <p>2020 年为 libGDX 带来了大量的修复和改进。8 月，我们的<a href="/news/2020/08/welcome_to_the_new_website">新网站</a>正式上线。从那时起，开发节奏再次加快：贡献者团队显著壮大，我们对<a href="/roadmap/">规划中</a>的特性和改进充满期待。</p>
    </div>
  </div>
  <div class="container right" data-aos="zoom-in-right" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2019</h2>
      <p>2019 年，libGDX 继续向前迈进：发布了包含大量修复和改进的 <a href="/news/2019/07/gdx_1_9_10">1.9.10 版本</a>。如今，libGDX 生态中的大部分工作都在主仓库之外进行：libGDX 作为框架已经足够成熟，不再需要大刀阔斧的改动，而围绕 libGDX 的<a href="/dev/#tools--libraries">工具集和框架</a>则由社区不断改进。</p>
    </div>
  </div>
  <div class="container left" data-aos="zoom-in-left" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2018</h2>
      <p>2018 年，框架发布了 1.9.9 版本。此外，自 2018 年 2 月起，libGDX 社区开始定期举办 <a href="/community/jams/">libGDX 游戏 Jam</a>。</p>
    </div>
  </div>
  <div class="container right" data-aos="zoom-in-right" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2017 - 分道扬镳</h2>
      <p>到 2017 年，libGDX 已经相当成熟，因此不再像早年那样频繁需要重大改动。尽管如此，这一年仍发布了 1.9.6 和 1.9.7 版本（后者首次不是由 Mario Zechner 亲自发布——这在 libGDX 历史上还是头一回），并且在 <a href="https://github.com/badlogic/gdx-vr">VR</a> 领域进行了一些实验。</p>
    </div>
  </div>
  <div class="container left" data-aos="zoom-in-left" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2016</h2>
      <p>除了 1.8 和 1.9 版本之外，2016 年还带来了基于 Intel Multi-OS Engine 的新 iOS 后端。发布它是为了取代 RoboVM 后端，因为 RoboVM 本身已停止维护。</p>
    </div>
  </div>
  <div class="container right" data-aos="zoom-in-right" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2015</h2>
      <p>2015 年又是一个改进之年：1.6 和 1.7 版本相继问世。2015 年 12 月 18 日至 2016 年 1 月 18 日，与 RoboVM、itch.io 和 Robotality 联合举办了大型 <a href="/wiki/misc/getting-ready-for-libgdxjam">libGDX 游戏 Jam</a>。活动从最初的 180 个主题提案中选中了“太空生活”（Life in space），整个比赛期间共诞生了 83 款游戏。</p>
    </div>
  </div>
  <div class="container left" data-aos="zoom-in-left" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2014 - libGDX 1.0</h2>
      <p>万事俱备之后，2014 年的第一季度被用来打磨 libGDX 的用户体验和文档，为 1.0 发布做准备。经过 4 年的开发，libGDX 终于在 2014 年 4 月 20 日迎来了 <a href="http://web.archive.org/web/20210213212631/https://www.badlogicgames.com/wordpress/?p=3412">1.0 版本</a>。2014 年余下的时间里，libGDX 迭代频繁：先后发布了 1.1（5 月）、1.2（6 月）、1.3（8 月）、1.4（10 月）和 1.5（12 月）版本。</p>
    </div>
  </div>
  <div class="container right" data-aos="zoom-in-right" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2013 – 精雕细琢</h2>
      <p>2013 年上半年，我们清理了 libGDX 的许多部分，从构建系统到瓦片地图支持。基于 MonoTouch 的脆弱的 iOS 后端被 libGDX RoboVM 后端取代。6 月，我们如今看来已显老旧、但在当时<a href="http://web.archive.org/web/20170622002445/http://www.badlogicgames.com/wordpress/?p=3093">焕然一新的网站</a>（由许多了不起的志愿者共同打造）正式上线。借助新网站，人们可以把游戏提交到展示画廊。此外，我们还把此前一直托管在 Google Code 上的 wiki 和 issue 迁移了过来，过程<a href="http://web.archive.org/web/20201111200443/https://www.badlogicgames.com/wordpress/?p=3176">多少有些磕磕绊绊</a>。2013 年底，我们开始研究 Gradle，把它视为新的救星。在此之前，libGDX 只能搭配 Eclipse 使用，依赖管理必须手动完成（也就是把 jar X 复制到文件夹 y 里）。</p>
    </div>
  </div>
  <div class="container left" data-aos="zoom-in-left" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2012 - 新世界</h2>
      <p>2012 年，<a href="http://web.archive.org/web/20170608015410/http://www.badlogicgames.com/wordpress/?p=2254">gdx-jnigen</a> 诞生了。它成为 libGDX 原生代码开发中不可或缺的一部分，大大简化了将 C/C++ 库集成到框架中的工作。除此之外，2012 年成了探索新世界的一年：HTML5/WebGL、iOS、GitHub 和 Maven。在 Google 的 <a href="https://github.com/playn/playn">PlayN</a> 的启发下，Mario 开始着手开发 GWT 后端，它至今仍是 libGDX 不可或缺的组成部分。下一个重大变化出现在 6 月，团队<a href="http://web.archive.org/web/20200928225224/https://www.badlogicgames.com/wordpress/?p=2450">开始调研 iOS</a>，这次同样是基于 PlayN 阵营的成果。8 月，大家开始讨论<a href="http://web.archive.org/web/20200928230258/https://www.badlogicgames.com/wordpress/?p=2551">迁移到 GitHub 并增加完善的 Maven 支持</a>。</p>
    </div>
  </div>
  <div class="container right" data-aos="zoom-in-right" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2011 - 循序渐进的改进</h2>
      <p>2011 年 2 月底，<a href="http://web.archive.org/web/20170621234149/http://www.badlogicgames.com/wordpress/?p=1596">0.9 版本发布</a>。在那段时间里，libGDX 内部发生了太多变化，让人很难跟得上进展。但这一切都是值得的：libGDX 0.9 获得了广泛采用，这不仅归功于密集的新特性，也归功于我们开始制作视频教程，并大幅简化了安装配置流程。</p>
    </div>
  </div>
  <div class="container left" data-aos="zoom-in-left" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2010 - 走向开源</h2>
      <p>2010 年 3 月，Zechner 决定将 AFX 开源，以 GNU 宽通用公共许可证（LGPL）托管在 Google Code 上。2010 年 3 月 6 日，世界第一次看到了 <a href="http://web.archive.org/web/20200928222604/https://www.badlogicgames.com/wordpress/?p=267">libGDX 的代码</a>。2010 年 4 月初，libGDX 迎来了它的第一位贡献者 Christoph Widulle。他帮忙处理了各种琐碎事务，也是一块可以碰撞想法的好“回音壁”。他的参与向其他人传递了一个信号：为 libGDX 做贡献是切实可行的。从那时起，libGDX 的贡献者名单开始缓慢而稳定地增长。</p>
    </div>
  </div>
  <div class="container right" data-aos="zoom-in-right" data-aos-anchor-placement="top-bottom">
    <div class="content">
      <h2>2009 – 一切的开端</h2>
      <p>一切始于 2009 年年中，libGDX 的创造者 <a href="https://twitter.com/badlogicgames">Mario Zechner</a> 开始开发一个名为 AFX（Android Effects）的框架，用于制作 Android 游戏。当他发现每次把改动部署到 Android 设备上非常繁琐时，他修改了 AFX，让它也能在桌面上运行，从而更方便地测试程序。</p>
    </div>
  </div>
</div>

<script src="/assets/js/aos.js"></script>
<script>
  AOS.init({
    disable: window.matchMedia('(prefers-reduced-motion: reduce)').matches,
    once: true
  });
</script>
