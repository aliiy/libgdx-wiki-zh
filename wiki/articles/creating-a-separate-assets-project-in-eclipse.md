---
title: 在 Eclipse 中创建独立资源项目
---
本文将逐步介绍如何在 Eclipse 中设置独立项目来管理资源。如果你希望将资源与代码项目分开，这是一个很好的方案。这样可以对资源使用不同的源代码管理方式，甚至完全不纳入源代码管理。此外，如果游戏规模足够大，还可以为资源项目设置一个整洁、独立的构建器。\*

我发现的唯一缺点是，除非修改每个项目的构建器以检查资源项目的更新，否则在点击运行前必须刷新（F5）项目，因为 Eclipse 不会自动检测独立资源项目中大多数文件的变化。这不是什么大问题。

**给 Gradle 构建用户的注意事项：**除非修改 Gradle 脚本以引入资源，否则此方案可能无法用于你的构建。


假设你有一个名为 MyGame 的项目，该项目由设置工具创建，项目结构与 Eclipse 最基本的默认场景一致。


1. 在 Eclipse 中创建新的 General Project。（File > New > Project...）
2. 将项目命名为 MyGame-Assets，或使用其他有意义的名称。
3. 进入 MyGame-Assets 项目，创建名为“assets”的新文件夹。
4. 在 assets 中创建名为“data”的子文件夹。
5. 建议在 data 文件夹中按需创建 graphics、sounds 等子文件夹。
6. 找到并展开设置工具创建的 MyGame-Android 项目。
7. 找到“assets”文件夹，将其中资源临时备份到其他位置，或移动到 MyGame-Assets/assets/data。如果项目受源代码管理，建议右键并使用 Export...。
8. 删除 MyGame-Android 项目中的“assets”文件夹。
9. 在 MyGame-Android 项目顶层右键，选择 New > Folder。
10. 在“New Folder”对话框底部点击“Advanced >>”按钮。
11. 选择“Link to Alternate Location”单选按钮。
12. 在空白文件夹路径中复制并粘贴（不含引号）：“WORKSPACE_LOC”。
13. 继续输入新建 assets 文件夹的路径。例如：/MyGame-Assets/assets
14. 点击“OK”前，确认对话框中间的“Folder Name”为“assets”。
15. 再次检查完整路径，然后点击 OK。
16. 进入并展开新链接的 assets 文件夹。此处应显示“data”及其所有子文件夹。如果没有，删除它并返回前面更仔细地重新操作。
17. 右键 MyGame-Android 项目，选择 Properties。
18. 进入“Java Build Path”，选择“Source”选项卡。
19. 点击对话框右侧的“Add Folder...”按钮。
20. 在出现的树中应能看到新的“assets”子文件夹，勾选它并点击“OK”。
21. 选择“Order and Export”选项卡，确认新的 assets 文件夹已勾选。
22. 在 Properties 窗口中点击“OK”。此时 assets 子文件夹的图标应从普通文件夹图标变为 Java 包图标。
23. 检查 MyGame-Assets 项目中的资源是否处于正确的文件夹结构中。
24. 点击 MyGame-Android 项目并按 F5，或者执行清理操作。
25. 运行 MyGame-Android 项目，确认能够构建并显示游戏美术资源。
26. 如果设置了 Desktop 或 iOS 项目，重复这些步骤，让每个项目都使用名为“assets”的链接文件夹。
27. 享受新的组织方式，并期待设置工具将来能自动完成这些工作。


我的 MyGame-Assets 项目通常类似下面的树形结构，每个目录下再根据具体游戏的需要组织子文件夹。如果你设置了构建器，或为不同设备准备了不同美术资源，也没有问题：整理好 MyGame-Assets 项目后重新创建链接文件夹即可。

/assets（实际存放优化后游戏二进制文件的位置）
     /data`
          /graphics`
          /maps
          /screens
          /shaders
          /sounds
/assets-workfiles（存放源文件/未优化文件的位置，目录结构与 assets 相同）


\* 在确实有必要之前，我不建议仅为资源设置构建器，这通常要等到游戏开发周期的后期。接近可发布状态前应保持简单务实；确认确实需要构建器后，找出最适合的方案，最后再单独处理资源打包优化。这样才能衡量效果，并最大化投入产出比。
