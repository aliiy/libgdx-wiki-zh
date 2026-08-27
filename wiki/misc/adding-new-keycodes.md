---
title: 添加新的键码
# 不列入目录，但通过 /dev/contributing/ 链接
---
## 添加新键码的简要说明：

- 将键码添加到 `Input.Keys`（不要忘记为新代码定义 `Input.Keys.toString()`）。

- **Android：**如果 Android 中存在对应键码，请使用 Android `KeyEvent` 类中的相同代码。如果不存在，请定义一个不与 Android 代码冲突的键码，并用注释说明。由于 Android 的键码与 libGDX 相同，无需修改 Android 后端。
- **GWT：**需要修改 `DefaultGwtInput.keyForCode()`。GWT 的 KeyCode.java 不完整。请使用各种浏览器和操作系统进行检查（结果可能略有不同），可参考 [keycode.info](https://keycode.info/)。
- **RoboVM：**需要修改 `DefaultIOSInput.getGdxKeyCode()`。请检查 `UIKeyboardHIDUsage` 枚举（在任何操作系统上都可以完成）。
- **Lwjgl：**在 `DefaultLwjglInput.getGdxKeyCode()` 和 `getLwjglKeyCode()` 中使用 Keyboard 常量，Lwjgl3 类似。不要忘记 `LwjglAwtInput`。
- **CHANGES：**记录新增键码，并说明它们是全新的（之前没有映射）还是修改了原有映射。

如果遵循这些步骤，合并通过的可能性会很高。

如有控制器相关问题，请查看 [gdx-controllers 仓库](https://github.com/libgdx/gdx-controllers)。

[MrStahlfelge](https://github.com/MrStahlfelge) 在 [#5389](https://github.com/libgdx/libgdx/issues/5389) 中的[评论](https://github.com/libgdx/libgdx/issues/5389#issuecomment-730477319)。
