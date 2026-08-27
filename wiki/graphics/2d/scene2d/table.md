---
title: Table
---
## 概述

Table 是一个 WidgetGroup，使用类似 HTML 表格的逻辑表格设置子项的位置和大小。Table 适合在 scene2d.ui 中广泛用于布局控件，因为它易于使用，而且比手动设置控件大小和位置强大得多。基于 Table 的布局不依赖绝对定位，因此会自动适应不同的控件尺寸和屏幕分辨率。

Table 是同一作者为 libGDX 创建的 [TableLayout](https://github.com/EsotericSoftware/tablelayout) 分支。TableLayout 为其他 UI 工具包（Swing、Android 等）提供与 Table 相同的功能。

- [Quickstart](#quickstart)
- [Root table](#root-table)
- [Debugging](#debugging)
- [Adding cells](#adding-cells)
- [Logical table](#logical-table)
- [Cell properties](#cell-properties)
	- [Expand](#expand)
	- [Alignment](#alignment)
	- [Fill](#fill)
	- [Widget size](#widget-size)
	- [Padding](#padding)
	- [Spacing](#spacing)
	- [Colspan](#colspan)
	- [Uniform](#uniform)
- [Defaults](#defaults)
	- [Cell defaults](#cell-defaults)
	- [Column defaults](#column-defaults)
	- [Row defaults](#row-defaults)
- [Values](#values)
- [Overlapping widgets](#overlapping-widgets)
- [Inserting cells](#inserting-cells)
- [Notes](#notes)

## 快速入门

```java
    Label nameLabel = new Label("Name:", skin);
    TextField nameText = new TextField("", skin);
    Label addressLabel = new Label("Address:", skin);
    TextField addressText = new TextField("", skin);
    
    Table table = new Table();
    table.add(nameLabel);
    table.add(nameText).width(100);
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100);
```

![images/quickstart.png](/assets/wiki/images/quickstart.png)

这段代码向 Table 添加了 4 个单元格，排列为两列两行。`add` 方法返回一个 Cell，Cell 提供用于控制布局的方法。Table 会设置子项的大小和位置，因此将文本框宽度设为 100 应该在表格单元格上完成，而不是直接设置文本框。

## 根表格

进行 UI 布局时，UI 控件不会设置自身大小，而是提供最小、首选和最大尺寸。控件的父对象会结合自身大小和这些提示来设置控件尺寸。许多布局会在根部使用一个固定大小的 Table，通常覆盖整个屏幕。将控件和嵌套 Table 添加到根 Table 后，就能得到不依赖固定位置或固定尺寸的响应式布局。

在 libgdx 中，可以使用 `setFillParent` 方法轻松将根 Table 调整为 Stage 大小（但通常只应在根 Table 上使用）：

```java
    Table table = new Table();
    table.setFillParent(true);
    stage.addActor(table);
```

## 调试

Table 可以绘制调试线来直观显示布局情况，启用方式如下：
```java
table.setDebug(true); // turn on all debug lines (table, cell, and widget)
```

## 添加单元格

使用 `add` 方法将控件添加到 Table，这会向当前行添加一个单元格。要移动到下一行，请调用 `row` 方法。

```java
    table.add(nameLabel);
    table.add(nameText);
    table.row();
    table.add(addressLabel);
    table.add(addressText);
```

`add` 方法返回一个 Cell，Cell 的属性可以控制布局。Cell 上的每个方法都会返回该 Cell，因此可以链式调用。

```java
    table.add(nameText).padLeft(10).width(100);
```

## 逻辑表格

这些单元格组成一个逻辑表格，但其大小不一定等于 Table 控件的大小。

![images/logicaltable.png](/assets/wiki/images/logicaltable.png)

外部蓝色矩形表示 Table 控件的大小，内部蓝色矩形表示逻辑表格的大小，默认居中对齐。可以使用 Table 上的方法更改对齐方式。Table 方法会返回 Table，因此和 Cell 方法一样可以链式调用。

```java
    table.right().bottom();
```

![images/tablealign.png](/assets/wiki/images/tablealign.png)

## Cell 属性

### 扩展

要让逻辑表格占据整个 Table 控件，需要告诉 TableLayout 哪些**单元格接收额外空间**。

```java
    table.add(nameLabel).expandX();
    table.add(nameText).width(100);
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100);
```

![images/expand.png](/assets/wiki/images/expand.png)

红线表示单元格边界，绿线表示控件边界。注意，左列获得了 x 方向的全部额外空间。只需一个单元格设置 expand，整列或整行就会扩展。如果多列扩展，额外空间会平均分配。

```java
    table.add(nameLabel).expandX();
    table.add(nameText).width(100).expandX();
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100);
```

![images/expandmultiple.png](/assets/wiki/images/expandmultiple.png)

通过 `expandY` 方法也可以在 y 方向扩展。`expand` 方法会同时在两个方向扩展。

```java
    table.add(nameLabel).expand();
    table.add(nameText).width(100);
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100);
```

![images/expandboth.png](/assets/wiki/images/expandboth.png)

### 对齐

与逻辑表格对齐类似，也可以在单元格内对齐控件。

```java
    table.add(nameLabel).expand().bottom().right();
    table.add(nameText).width(100).top();
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100);
```

![images/align.png](/assets/wiki/images/align.png)

### 填充

`fill` 方法会使**控件调整为单元格大小**。与 expand 一样，还提供 `fillX` 和 `fillY` 方法。

```java
    table.add(nameLabel).expand().bottom().fillX();
    table.add(nameText).width(100).top();
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100);
```

![images/fill.png](/assets/wiki/images/fill.png)

注意，红色单元格线绘制在绿色控件线之上。

## 控件尺寸

默认情况下，Table 会尝试将控件调整为首选尺寸。如果控件放不下，就在首选尺寸和最小尺寸之间调整，首选尺寸较大的控件会获得更多空间。如果控件连最小尺寸也放不下，布局就会失效，控件可能重叠。`fill` 方法不会让控件超过其最大尺寸。

初学者常犯的错误是直接设置控件尺寸，试图以此调整控件在 Table 中的大小或位置。Table 会根据控件的首选、最小或最大尺寸设置子项的大小和位置，因此会覆盖之前设置的尺寸或位置。

控件没有用于设置首选、最小或最大尺寸的 setter。这些值通常由控件计算，如果也能显式设置会造成混淆。不建议通过继承控件来改变这些值。应在包含控件的单元格上设置**首选、最小或最大尺寸**，这样会使用你设置的值，而不是控件自身的值。

```java
    table.add(nameLabel);
    table.add(nameText).minWidth(100);
    table.row();
    table.add(addressLabel);
    table.add(addressText).prefWidth(999);
```

![images/size.png](/assets/wiki/images/size.png)

这里 `prefWidth` 为 999，大于 Table 的宽度，因此会缩小以适应 Table。

`width` 是将 `minWidth`、`prefWidth` 和 `maxWidth` 设置为同一值的快捷方法。`height` 是将 `minHeight`、`prefHeight` 和 `maxHeight` 设置为同一值的快捷方法。`size` 方法接收宽度和高度，并设置全部六个属性。

### 内边距

Padding 是单元格边缘周围的**额外空间**。

```java
    table.add(nameLabel);
    table.add(nameText).width(100).padBottom(10);
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100).pad(10);
```

![images/pad.png](/assets/wiki/images/pad.png)

注意，单元格之间的 padding 会叠加，因此文本框之间有 20 像素。调试线不一定能显示 padding 来自哪个单元格，因为这对 Table 布局并不重要。

Padding 也可以应用于 Table 的边缘。

```java
    table.pad(10);
```

### 间距

与 padding 一样，spacing 是单元格边缘周围的额外空间。不过，**单元格之间的 spacing 不会叠加**，而是取两者中较大的值。此外，Table 边缘不会应用 spacing。使用 spacing 可以轻松保持单元格之间的间距一致，例如表单布局。

```java
    table.add(nameLabel);
    table.add(nameText).width(100).spaceBottom(10);
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100).space(10);
```

![images/space.png](/assets/wiki/images/space.png)

注意，单元格之间的 spacing 不会叠加，因此文本框之间有 10 像素。还要注意，底部文本框下方没有 spacing，因为 Table 边缘不会应用 spacing。

### 跨列

**一个单元格可以跨越多列**。

```java
    table.add(nameLabel);
    table.add(nameText).width(100).spaceBottom(10);
    table.row();
    table.add(addressLabel).colspan(2);
```

![images/colspan.png](/assets/wiki/images/colspan.png)

注意，这里没有 rowspan。要实现类似效果，请使用嵌套 Table。

### 统一尺寸

将 `uniform` 设为 true 的单元格会具有相同大小。

```java
    table.add(nameLabel).uniform();
    table.add(nameText).width(100).uniform();
    table.row();
    table.add(addressLabel);
    table.add(addressText).width(100);
```

![images/uniform.png](/assets/wiki/images/uniform.png)

## 默认值

### 单元格默认值

许多单元格通常具有相同属性，因此为所有单元格设置默认属性可以大幅减少布局代码。Table 的 `defaults` 方法返回一个 Cell，其属性是**所有单元格的默认值**。

```java
    table.defaults().width(100);
    table.add(nameLabel);
    table.add(nameText);
    table.row();
    table.add(addressLabel);
    table.add(addressText);
```

![images/defaults.png](/assets/wiki/images/defaults.png)

### 列默认值

Table 的 `columnDefaults` 方法返回一个 Cell，其属性是**该列所有单元格的默认值**。在这里设置的属性会覆盖单元格默认属性。列索引从 0 开始。

```java
    table.columnDefaults(1).width(150);
    table.add(nameLabel);
    table.add(nameText);
    table.row();
    table.add(addressLabel);
    table.add(addressText);
```

![images/columndefaults.png](/assets/wiki/images/columndefaults.png)

### 行默认值

调用 `row` 方法时，它会返回一个 Cell，其属性是该行所有单元格的默认值。在这里设置的属性会同时覆盖单元格默认属性和列默认属性。注意，可以在添加任何单元格前调用 `row`，从而为第一行设置行默认属性。

```java
    table.row().height(50);
    table.add(nameLabel);
    table.add(nameText);
    table.row().height(100);
    table.add(addressLabel);
    table.add(addressText);
```

![images/rowdefaults.png](/assets/wiki/images/rowdefaults.png)

## Value

尺寸、padding 等所有值实际上都是 `Value` 实例。使用数值时采用 `Value.Fixed`。`Value` 提供更大的灵活性，例如可以根据另一个控件设置尺寸或 padding。

```java
    table.add(nameLabel);
    table.add(nameText).pad(new Value.Fixed(10));
    table.row();
    table.add(addressLabel).width(Value.percentWidth(0.33f));
    table.add(addressText);
```

## 重叠控件

Table 擅长设置不重叠控件的大小和位置。要将控件彼此叠放，可以使用 [Stack](/wiki/graphics/2d/scene2d/scene2d-ui#stack)。

## 插入单元格

Table 允许更换或移除单元格中的控件（将其设为 null），但目前不允许在中间插入或移除单元格。要实现这一点，需要重建 Table：调用 `clearChildren` 移除所有子项和单元格，然后重新将它们添加到 Table。

如果需要插入或移除单元格，可以使用 [VerticalGroup](/wiki/graphics/2d/scene2d/scene2d-ui#verticalgroup) 或 [HorizontalGroup](/wiki/graphics/2d/scene2d/scene2d-ui#horizontalgroup)。

# 注意事项

* 默认情况下，位置和尺寸会四舍五入为整数。使用较小值时可能因此产生问题。
  使用 [Table#setRound(false)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Table.java#L669) 可以更改此行为。
