---
permalink: /dev/tools/
title: "工具"
classes: wide
header:
  overlay_color: "#000"
  overlay_filter: "0.4"
  overlay_image: /assets/images/dev/tools.jpeg
  caption: "图片来源：[**Marvin Meyer**](https://unsplash.com/photos/SYTO3xs06fU)"

excerpt: "有许多工具——既有官方的，也有社区制作的——能让 libGDX 的开发过程轻松许多。"

feature_row:
  - image_path: /assets/images/dev/tools/spine.jpg
    title: "Spine"
    excerpt: '专注于 2D 游戏动画的动画工具'
    url: "http://en.esotericsoftware.com/"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Paid"]
  - image_path: /assets/images/dev/tools/talos.jpg
    title: "Talos"
    excerpt: '基于节点的开源 VFX 编辑器，界面功能强大'
    url: "https://talosvfx.com"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
  - image_path: /assets/images/dev/tools/hyperlap.gif
    title: "HyperLap2D"
    excerpt: '面向复杂 2D 世界与场景的可视化编辑器'
    url: "https://github.com/rednblackgames/HyperLap2D"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]

feature_row2:
  - image_path: /assets/images/dev/tools/gdx-liftoff.png
    title: "gdx-liftoff"
    excerpt: '官方的 libGDX 项目生成器'
    url: "/wiki/start/project-generation"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
  - image_path: /assets/images/dev/tools/skin_composer.png
    title: "Skin Composer"
    excerpt: "为 libGDX 的 scene2d.ui 创建皮肤的工具"
    url: "https://github.com/raeleus/skin-composer/wiki"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
  - image_path: /assets/images/dev/tools/particle_editor.png
    title: "Particle Editor"
    excerpt: '制作 2D 粒子效果的强大工具'
    url: "/wiki/tools/2d-particle-editor"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]

feature_row3:
  - image_path: /assets/images/dev/tools/flame.gif
    title: "Flame"
    excerpt: 'libGDX 的强大 3D 粒子编辑器'
    url: "/wiki/graphics/3d/3d-particle-effects"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
  - image_path: /assets/images/dev/tools/hiero.png
    title: "Hiero"
    excerpt: '与 libGDX 兼容的位图字体打包工具'
    url: "/wiki/tools/hiero"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
  - image_path: /assets/images/dev/tools/fbx_conv.gif
    title: "fbx-conv"
    excerpt: '将 3D 模型转换为 libGDX 友好格式的工具'
    url: "https://github.com/libgdx/fbx-conv"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]

feature_row4:
  - image_path: /assets/images/dev/tools/tiled.png
    title: "Tiled"
    excerpt: '为你的游戏打造的灵活 2D 关卡编辑器'
    url: "https://www.mapeditor.org"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
  - image_path: /assets/images/dev/tools/texture_packer.jpeg
    title: "Texture Packer"
    excerpt: '将图片打包成图集的工具'
    url: "/wiki/tools/texture-packer"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
  - image_path: /assets/images/dev/tools/texture_packer_pro.png
    title: "Texture Packer Pro"
    excerpt: '创建精灵图（sprite sheet），优化你的游戏图形'
    url: "https://www.codeandweb.com/texturepacker"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free", "Paid"]
    
feature_row5:
  - image_path: /assets/images/dev/tools/tiled_map_packer.gif
    title: "Tiled Map Packer"
    excerpt: '将 TiledMap tileset 打包成图集的工具'
    url: "/wiki/tools/tiled-map-packer"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
  - image_path: /assets/images/dev/tools/pixscape.gif
    title: "Pixscape"
    excerpt: '基于 LibGDX 的可视化 2D 与 2.5D 游戏引擎'
    url: "https://pixscape.games/"
    btn_label: "文档与下载"
    btn_class: "btn--primary"
    tags: ["Free"]
    
sidebar:
  nav: "dev"

---

{% include breadcrumbs.html %}

{% include feature_row.html %}

{% include feature_row.html id="feature_row2" %}

{% include feature_row.html id="feature_row3" %}

{% include feature_row.html id="feature_row4" %}

{% include feature_row.html id="feature_row5" %}
