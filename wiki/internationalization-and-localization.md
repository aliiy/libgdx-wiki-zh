---
title: 国际化与本地化
---
## 概览

严格来说，_国际化_ 是设计软件的过程，使其无需工程改动即可适配不同语言和地区。
_本地化_ 则是通过添加特定于地区的组件并翻译文本，使国际化软件适配特定地区或语言的过程。
由于术语较长，国际化和本地化通常分别缩写为 i18n 和 l10n，其中 18 和 10 表示相应单词首尾字母之间的字母数量。

在 LibGDX 中，使用 [`I18NBundle` 类](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/I18NBundle.html)存储和获取与区域设置相关的字符串。Bundle 可以让你轻松为应用提供不同翻译。


## 创建 Properties 文件

每个 bundle 都是一组共享相同基本名称的 properties 文件，下面示例中的基本名称是 `MyBundle`。基本名称之后的字符表示 Locale 的_语言代码_、_国家代码_和_变体_，例如：

* `MyBundle.properties`
* `MyBundle_de.properties`
* `MyBundle_en_GB.properties`
* `MyBundle_fr_CA_VAR1.properties`

例如，`MyBundle_en_GB` 匹配语言代码为英语（`en`）、国家代码为英国（`GB`）的 Locale。

你应始终创建一个不带语言代码、国家代码或变体的_默认 properties 文件_。本例中 `MyBundle.properties` 的内容如下：
```properties
game=My Super Cool Game
newMission={0}, you have a new mission. Reach level {1}.
coveredPath=You covered {0,number}% of the path
highScoreTime=High score achieved on {0,date} at {0,time}
```

要支持其他 Locale，本地化人员会创建包含翻译值的_附加 properties 文件_。无需修改源代码，因为程序引用的是键，而不是值。

例如，要添加意大利语支持，本地化人员会翻译 `MyBundle.properties` 中的值，并将其放入名为 `MyBundle_it.properties` 的文件中。该文件内容如下：

```properties
newMission={0}, hai una nuova missione. Raggiungi il livello {1}.
coveredPath=Hai coperto il {0,number}% del percorso
highScoreTime=High score ottenuto il {0,date} alle ore {0,time}
```
注意，意大利语 properties 文件中缺少名为 `game` 的键，因为我们希望游戏名称不随 Locale 改变。如果找不到某个键，系统会按具体程度从高到低在 properties 文件中查找，直到找到为止；例如，如果在 `MyBundle_en_GB.properties` 中找不到，就会查找 `MyBundle_en.properties`，如果仍找不到，则查找默认的 `MyBundle.properties`。



## 创建 Bundle

`I18NBundle` 类的实例会将适当的 properties 文件加载到内存，并管理某个 Locale 的命名字符串。
调用工厂方法 `createBundle` 获取所需 bundle 的新实例：
```java
FileHandle baseFileHandle = Gdx.files.internal("i18n/MyBundle");
Locale locale = new Locale("fr", "CA", "VAR1");
I18NBundle myBundle = I18NBundle.createBundle(baseFileHandle, locale);
```

这里的路径 "i18n/MyBundle" 指向 _i18n_ 文件夹（更准确地说是 "assets/i18n"）中名称以 _MyBundle_ 开头的文件。不需要再创建 _MyBundle_ 子文件夹。

或者，如果你使用 [`AssetManager`](/wiki/managing-your-assets)：
```java
assetManager.load("i18n/MyBundle", I18NBundle.class);
// ... after loading ...
I18NBundle myBundle = assetManager.get("i18n/MyBundle", I18NBundle.class);
```
调用 `createBundle` 时如果不指定 Locale，则使用默认 Locale。这通常正是你想要的行为。

请注意，这两种情况下都必须省略 `.properties` 文件扩展名。如果指定 Locale 的 properties 文件不存在，`createBundle` 会尝试查找最接近的匹配项。例如，如果请求的 Locale 是 `fr_CA_VAR1`，而默认 Locale 是 `en_US`，`createBundle` 会按以下顺序查找文件：
  * `MyBundle_fr_CA_VAR1.properties`
  * `MyBundle_fr_CA.properties`
  * `MyBundle_fr.properties`
  * `MyBundle_en_US.properties`
  * `MyBundle_en.properties`
  * `MyBundle.properties`

请注意，`createBundle` 会先根据默认 Locale 查找文件，然后才选择基础文件 `MyBundle.properties`。如果 `createBundle` 找不到匹配项，就会抛出 `MissingResourceException`。为避免抛出此异常，应始终提供不带后缀的基础文件。



## 获取本地化字符串

要从 bundle 获取翻译后的值，请调用 `get` 方法：
```java
String value = myBundle.get(key);
```
`get` 方法返回与指定键对应的字符串。如果指定 Locale 存在相应的 properties 文件，字符串就会使用正确语言。如果 `get` 方法（或其带参数形式 `format`）找不到指定键的字符串，则抛出 `MissingResourceException`。

翻译字符串可以包含格式化参数。要替换这些参数的值，请调用 `format` 方法：
```java
String value = myBundle.format(key, arg1, arg2, ...);
```

例如，要获取上述 properties 文件中的字符串，代码可能如下所示：
```java
String game = myBundle.format("game");
String mission = myBundle.format("newMission", player.getName(), nextLevel.getName());
String coveredPath = myBundle.format("coveredPath", path.getPerc());
String highScoreTime = myBundle.format("highScoreTime", highScore.getDate());
```

当字符串不含参数时，你可能会认为 `get` 和 `format` 方法是等价的，但事实并非完全如此。`get` 方法会原样返回 properties 文件中指定的字符串，而 `format` 方法即使没有参数，也可能替换转义内容。因此，`get` 稍快一些；但除非确定翻译中不包含任何转义内容，否则最好始终使用 `format`。



## 消息格式

如前所述，properties 文件中的字符串可以包含参数。这些字符串通常称为模式，并遵循 `java.text.MessageFormat` API 规定的语法。简而言之，模式可以包含零个或多个 `{index, type, style}` 形式的格式，其中 type 和 style 是可选的。要了解全部功能，请参阅 [`MessageFormat` 类的官方 JavaDoc](https://docs.oracle.com/javase/7/docs/api/java/text/MessageFormat.html)。

**重要**：由于默认转义规则对本地化人员来说有些令人困惑，libGDX 对 `MessageFormat` 的语法做了一项修改。如果要在字符串中使用字面量 `{`，通常需要用单引号（`'`）转义。但在 libGDX 中，只需将其加倍；例如，{% raw %}`{{0}`{% endraw %} 会被解释为字面量字符串 `{0}`，不包含任何格式元素。因此，单引号永远不需要转义！

请注意，格式可以本地化。这意味着数字、日期和时间等带类型数据会自动使用特定 Locale 的典型形式表示。例如，浮点数 `3.14` 在意大利语 Locale 中会变为 `3,14`；请注意这里用逗号替代了小数点。（如果使用 GWT，则存在[一些限制](#gwt-limitations-and-compatibility)。）

与 `java.util.Properties` 不同，默认编码是 `UTF-8`。如果出于任何原因不想使用 UTF-8 编码，请调用 `createBundle` 方法中允许指定所需编码的重载形式。



## 复数形式

复数形式通过 `MessageFormat` 提供的标准 `choice` 格式支持。
请参阅 [`java.text.ChoiceFormat` 类的官方文档](https://docs.oracle.com/javase/7/docs/api/java/text/ChoiceFormat.html)。
下面仅展示一个例子。考虑以下 property：
```properties
collectedCoins=You collected {0,choice,0#no coins|1#one coin|1<{0,number,integer} coins|100<hundreds of coins} along the path.
```
你可以像往常一样获取本地化字符串：
```java
System.out.println(myBundle.format("collectedCoins", 0));
System.out.println(myBundle.format("collectedCoins", 1));
System.out.println(myBundle.format("collectedCoins", 32));
System.out.println(myBundle.format("collectedCoins", 117));
```
输出结果如下：
```
You collected no coins along the path.
You collected one coin along the path.
You collected 32 coins along the path.
You collected hundreds of coins along the path.
```

值得注意的是，choice 格式可以正确处理嵌套格式，例如在 `{0,choice,...}` 中使用 `{0,number,integer}`。


## GWT 限制和兼容性

如前所述，libGDX 提供的 I18N 系统是跨平台的。不过，在 GWT 后端上存在一些限制。
具体来说：
- **简单格式：**不完全支持 `java.text.MessageFormat` 的格式语法。必须使用简化语法，即格式只能由索引组成，例如 `{index}`。
不支持也不能使用格式的 type 和 style，否则会抛出 `IllegalArgumentException`。
- **参数不可本地化：**格式永远不会本地化，也就是说，传递给 `format` 方法的参数会通过 `toString` 方法转换为字符串，不会考虑 bundle 的 Locale。

如果应用程序可以同时运行在 GWT 和非 GWT 后端上，应在应用启动时调用 [I18NBundle.setSimpleFormat(true)](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/I18NBundle.html#setSimpleFormatter%28boolean%29)。这样，之后所有对工厂方法 `createBundle` 的调用都会在所有后端上创建行为一致的 bundle。
如果不这样做，在非 GWT 后端上，意大利语 Locale 会得到本地化字符串 `3,14`（请注意逗号和舍入）；而在 GWT 后端上，同一 Locale 会得到未本地化的字符串 `3.1415927`。
相反，如果将 `simpleFormat` 设置为 `true`，任何后端上的任何 Locale 都会得到未本地化的字符串 `3.1415927`。


## 多个 Bundle

当然可以在应用程序中使用多个 bundle。例如，可以为游戏的每个关卡使用不同的 bundle。使用多个 bundle 有以下优点：
   * 代码更易于阅读和维护。
   * 可以避免使用过大的 bundle，因为加载到内存可能需要较长时间。
   * 只在需要时加载每个 bundle，从而减少内存占用。


## iOS
对于 iOS，需要在 `Info.plist.xml` 文件中指定支持的语言。要支持英语、西班牙语和德语，请添加以下内容：

    <key>CFBundleLocalizations</key>
    <array>
        <string>en</string>
        <string>es</string>
        <string>de</string>
    </array>
