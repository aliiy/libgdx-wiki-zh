---
title: Wiki 风格指南
# Not listed in ToC
---
本页介绍如何编辑 libGDX wiki 页面。**为 libGDX wiki 做贡献前请先阅读本文！**如有任何（额外）问题，请随时提问！更多信息请参阅我们的 [Discord](/community/)。

## 如何操作？
每个 wiki 页面顶部都有“Edit on GitHub”按钮，会将你带到 wiki 仓库的 GitHub Web 界面。小型修复或错字修改可使用此方式。如果要进行较大范围的修改，应 fork [仓库](https://github.com/libgdx/libgdx.github.io)。我们网站仓库的 [wiki](https://github.com/libgdx/libgdx.github.io/wiki) 也提供了一些指引。

## 第一段
通常，每个 wiki 页面都应以介绍性段落开头。这能提升 wiki 的可用性，并允许将开头几句用于元描述和搜索结果。

## 风格
本 wiki 使用 Markdown 排版。要了解 Markdown 的使用方法，可以查看 GitHub 简明的 [Markdown 速查表](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)。由于 wiki 托管在 GitHub Pages 上，也可以使用 HTML、JS、CSS 以及 Jekyll 的 Liquid 标签。更多可用选项请查看[这里](https://github.com/libgdx/libgdx.github.io/wiki)。

### 重要语法

* Wiki 链接的写法如下：
   `[link text to networking](/wiki/networking)` 会渲染为：[link text to networking](/wiki/networking)

## 链接到代码/文档
代码/文档链接应采用以下形式：`[ClassName](文档链接) [(code)](代码链接)`。例如：
```
[Texture](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Texture.html)
[(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/Texture.java)
```

渲染结果如下：

[Texture](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Texture.html)
[(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/Texture.java)

不要在 Wiki 页面名称中使用非字母字符，因为并非所有操作系统在将 Wiki 克隆为 Git 仓库时都能处理它们（例如 Windows 不支持“:”）。

{% capture docs-notice %}
- 请注意，`ClassName (Code)` 格式中间应有一个空格，以便区分二者。
- 请使用包含 `Code` 一词的 `ClassName (Code)` 格式，不要使用 `Source` 或其任何变体。保持一致非常重要！
- 如果文档链接以右括号 `)` 结尾，就会破坏 Markdown。请看下面的例子：
   ```
   https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Texture.html#getWidth()
   ```
   使用 `[]()` Markdown 格式时，末尾的右括号会破坏链接，因此请记得转义末尾的右括号（`)`）。上面的例子应写成：
   ```markdown
   [Link to Texture#getWidth](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Texture.html#getWidth(\))
   ```
   如果不转义这个右括号，就很可能得到 404！
{% endcapture %}

<div class="notice notice--primary">{{ docs-notice | markdownify }}</div>

## 主目录

如果创建新页面，你很可能希望它显示在 libGDX wiki 的主[目录](https://github.com/libgdx/libgdx.github.io/blob/dev/_includes/wiki_index.md)和[侧边栏目录](https://github.com/libgdx/libgdx.github.io/blob/dev/_includes/wiki_sidebar.md)中。因此，请在 PR 中同时修改这两个目录，并将文章放在适当的位置。

有些页面不会列入目录，尤其是位于 `/wiki/misc` 文件夹中的页面。这些页面应在 frontmatter 中包含注释 `# Not listed in ToC`，以明确说明这一点。

## 页面目录

每个页面的目录都必须手动创建。若要查看本节之外的示例，请参考我们的 [Box2d](/wiki/extensions/physics/box2d) 文章。

在 Markdown 中创建标题时，我们使用若干井号（`#`）来定义标题级别。如果在名为 `Help Me` 的文章中创建标题 `## Comments and Questions/Concerns`，对应的链接就是 `help-me#comments-and-questionsconcerns`。因此，制作目录时，应将这些页面片段链接放入无序列表。

## 添加图片

图片存储在 libGDX wiki 的 [`assets/wiki/` 目录](https://github.com/libgdx/libgdx.github.io/blob/dev/assets/wiki/)中。要添加图片，必须先 fork 并[克隆仓库](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/cloning-a-repository)。然后按照命名规则 `my-page-name#` 将图片添加到图片文件夹，其中 `#` 表示图片在页面上的显示顺序（如果页面只有一张图片，可以省略，但建议保留）。假设图片存储在 `/assets/wiki/images/` 目录中，可使用以下语法链接图片：`![image name](/assets/wiki/images/flamedemo.gif)`，渲染结果如下：

![image name](/assets/wiki/images/flamedemo.gif){: style="width: 300px;" }

如果要设置图片样式，可以使用类似这样的写法：`![image name](/assets/wiki/images/flamedemo.gif){: style="width: 300px;" }`

## 视频

可以按如下方式嵌入视频：

```markdown
{% raw %}{% include video id="3kPK_O6Q4wA" provider="youtube" %}{% endraw %}
```

## 添加 GWT 示例

实际的 libGDX 示例可以通过 GWT 以 iframe 的形式嵌入。要实现这一点，请在 wiki 页面中使用 `embed-gwt` 元素：
```yml
{% raw %}{% include embed-gwt.html dir='viewport-example' width="800" height="500" %}{% endraw %}
```

`dir` 指向 [libgdx-wiki-examples](https://github.com/libgdx/libgdx-wiki-examples) repo 中存放示例源代码的目录。更具体地说，它表示示例 Gradle 项目根目录的路径（不带开头和结尾的斜杠；在本例中，`viewport-example` 指向包含 `/html/build.gradle` 的 `/viewport-example/` 文件夹）。示例会通过 GH Actions（调用 `./gradlew html:dist`）自动构建，然后通过 GH Pages 部署。

如果同时设置了 `width` 和 `height`，它们会用作容器尺寸。二者表示像素尺寸，必须以不带单位的纯数字填写。

要设置嵌入内容的样式，请使用 `containerstyle` 和 `iframestyle` 属性。

## 重命名页面

如果要移动或重命名页面，并希望保留旧链接，请在 frontmatter 中使用 `redirect_from`：
```yml
redirect_from:
  - /dev/setup/ # this page is now available via https://libgdx.com/dev/setup/ as well
```
