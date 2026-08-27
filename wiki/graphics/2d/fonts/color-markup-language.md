---
title: 颜色标记语言
---
`BitmapFontCache` 类通过一种简单的标记语言支持字符串内的彩色文本。

标记默认处于禁用状态。使用公共成员 [font.getData().markupEnabled](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/BitmapFont.BitmapFontData.html#markupEnabled) 可以启用或禁用它。

标记语法非常简单，但仍然很灵活：
- **[name]** 按名称设置颜色。预定义颜色有一些，完整列表请参阅 [Colors.reset()](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/Colors.java) 方法。用户可以通过 [Colors](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Colors.html) 类的方法定义自己的颜色。
- **[#xxxxxxxx]** 使用十六进制值 `xxxxxxxx` 设置颜色，格式为 `RRGGBBAA`，其中 AA 可省略，默认值为 0xFF。
- **[]** 将颜色恢复为前一个颜色（类似可选的结束标签）。
- **[[** 对左方括号进行转义。

注意，颜色名称区分大小写，不能为空，不能以 `#` 或 `[` 开头，也不能包含 `]`。此外，颜色名称中的任何 `[` 都不能被转义。

未知颜色、非法十六进制代码和未闭合标签会被静默忽略，并作为普通文本处理。

示例代码请参阅测试类 [BitmapFontTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/BitmapFontTest.java)。

**注意：** 与 Scene2D 一起使用时，必须从 **skin.json** 文件中的 **LabelStyle** 定义移除 **fontColor** 属性，标记着色才能对 Label 生效。
