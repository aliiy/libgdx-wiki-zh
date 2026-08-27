---
title: 读取和写入 JSON
---
  * [概述](#overview)
  * [写入对象图](#writing-object-graphs)
  * [读取对象图](#reading-object-graphs)
  * [自定义序列化](#customizing-serialization)
  * [序列化方法](#serialization-methods)
  * [基于事件的解析](#event-based-parsing)
  * [支持的类](#supported-classes)

## 概述

libGDX 可以自动将对象序列化为 JSON，也可以将 JSON 反序列化为对象。该 API 由四个小型类组成：

  * `JsonWriter`：用于输出 JSON 的构建器风格 API。
  * `JsonReader`：解析 JSON 并构建由 `JsonValue` 对象组成的 DOM。
  * `JsonValue`：描述 JSON 对象、数组、字符串、浮点数、长整数、布尔值或 null。
  * `Json`：使用 `JsonReader` 和 `JsonWriter` 读写任意对象图。

要在 libGDX 之外使用这些类，请参阅 [JsonBeans](https://github.com/EsotericSoftware/jsonbeans/) 项目。

## 写入对象图

`Json` 类使用反射自动将对象序列化为 JSON。以下是两个类的示例（省略 getter/setter 和构造函数）：

```java
public class Person {
   private String name;
   private int age;
   private ArrayList numbers;
}

public class PhoneNumber {
   private String name;
   private String number;
}
```

使用这些类的对象图示例：

```java
Person person = new Person();
person.setName("Nate");
person.setAge(31);
ArrayList numbers = new ArrayList();
numbers.add(new PhoneNumber("Home", "206-555-1234"));
numbers.add(new PhoneNumber("Work", "425-555-4321"));
person.setNumbers(numbers);
```

序列化该对象图的代码：

```java
Json json = new Json();
System.out.println(json.toJson(person));

{numbers:[{class:com.example.PhoneNumber,number:"206-555-1234",name:Home},{class:com.example.PhoneNumber,number:"425-555-4321",name:Work}],name:Nate,age:31}
```

这种格式很紧凑，但几乎无法阅读。可以使用 `prettyPrint` 方法：

```java
Json json = new Json();
System.out.println(json.prettyPrint(person));

{
numbers: [
	{
		class: com.example.PhoneNumber,
		number: "206-555-1234",
		name: Home
	},
	{
		class: com.example.PhoneNumber,
		number: "425-555-4321",
		name: Work
	}
],
name: Nate,
age: 31
}
```

注意，JSON 中出现了 `ArrayList numbers` 字段中 `PhoneNumber` 对象的类名。由于 `ArrayList` 可以保存任意类型的对象，因此从 JSON 重建对象图时需要这些信息。只有反序列化需要时才会输出类名。如果字段是 `ArrayList<PhoneNumber> numbers`，则只有列表中的项目继承 `PhoneNumber` 时才会出现类名。如果知道具体类型或不使用泛型，可以通过告知 `Json` 类相关类型来避免写入类名：

```java
Json json = new Json();
json.setElementType(Person.class, "numbers", PhoneNumber.class);
System.out.println(json.prettyPrint(person));

{
numbers: [
	{
		number: "206-555-1234",
		name: Home
	},
	{
		number: "425-555-4321",
		name: Work
	}
],
name: Nate,
age: 31
}
```

如果无法避免写入类名，可以为其指定别名：

```java
Json json = new Json();
json.addClassTag("phoneNumber", PhoneNumber.class);
System.out.println(json.prettyPrint(person));

{
numbers: [
	{
		class: phoneNumber,
		number: "206-555-1234",
		name: Home
	},
	{
		class: phoneNumber,
		number: "425-555-4321",
		name: Work
	}
],
name: Nate,
age: 31
}
```

`Json` 类可以读写 JSON 以及几种类似 JSON 的格式。它支持 “JavaScript” 格式，仅在必要时为对象属性名加引号；也支持“minimal”格式（默认），仅在必要时为对象属性名和值加引号。

```java
Json json = new Json();
json.setOutputType(OutputType.json);
json.setElementType(Person.class, "numbers", PhoneNumber.class);
System.out.println(json.prettyPrint(person));

{
"numbers": [
	{
		"number": "206-555-1234",
		"name": "Home"
	},
	{
		"number": "425-555-4321",
		"name": "Work"
	}
],
"name": "Nate",
"age": 31
}
```

注意：默认情况下，Json 类不会写入值与新构造实例相同的字段。如果希望禁用此行为并包含所有字段，请调用 `json.setUsePrototypes(false);`。

## 读取对象图

`Json` 类使用反射自动从 JSON 反序列化对象。以下是将前面示例中的 JSON 反序列化的方法：

```java
Json json = new Json();
String text = json.toJson(person);
Person person2 = json.fromJson(Person.class, text);
```

传给 `fromJson` 的类型是对象图根节点的类型。根据该类型，`Json` 类会递归确定所有字段及遇到的其他对象的类型。根节点的 “knownType” 和 “elementType” 可以传给 `toJson`。当根对象类型未知时，这很有用：

```java
Json json = new Json();
json.setOutputType(OutputType.minimal);
String text = json.toJson(person, Object.class);
System.out.println(json.prettyPrint(text));
Object person2 = json.fromJson(Object.class, text);

{
class: com.example.Person,
numbers: [
	{
		class: com.example.PhoneNumber,
		number: "206-555-1234",
		name: Home
	},
	{
		class: com.example.PhoneNumber,
		number: "425-555-4321",
		name: Work
	}
],
name: Nate,
age: 31
}
```

要将 JSON 读取为由映射、数组和值组成的 DOM，可以使用 `JsonReader` 类：

```java
Json json = new Json();
String text = json.toJson(person, Object.class);
JsonValue root = new JsonReader().parse(text);
```

`JsonValue` 描述 JSON 对象、数组、字符串、浮点数、长整数、布尔值或 null。

## 自定义序列化

通常自动序列化已经足够，但有些类无法自动序列化，或者需要自定义序列化。可以让类实现 `Json.Serializable` 接口，或向 `Json` 实例注册 `Json.Serializer`，从而自定义序列化。

此示例使用 `Json.Serializable` 将电话号码写成只有一个字段的对象：

```java
static public class PhoneNumber implements Json.Serializable {
   private String name;
   private String number;

   public void write (Json json) {
      json.writeValue(name, number);
   }

   public void read (Json json, JsonValue jsonMap) {
      name = jsonMap.child().name();
      number = jsonMap.child().asString();
   }
}

Json json = new Json();
json.setElementType(Person.class, "numbers", PhoneNumber.class);
String text = json.prettyPrint(person);
System.out.println(text);
Person person2 = json.fromJson(Person.class, text);

{
numbers: [
	{
		Home: "206-555-1234"
	},
	{
		Work: "425-555-4321"
	}
],
name: Nate,
age: 31
}
```

实现 `Json.Serializable` 的类必须有无参数构造函数，因为对象由框架代为构造。在 `write` 方法中，外层 JSON 对象已经写入；`read` 方法始终接收一个表示该 JSON 对象的 `JsonValue`。

`Json.Serializer` 可以更精细地控制输出。如果要输出类似 `Json.Serializable` 的 JSON 对象，就需要调用 `writeObjectStart` 和 `writeObjectEnd`。此外，也可以输出 JSON 数组或简单值（字符串、int、boolean）而不是对象。`Json.Serializer` 还允许自定义对象创建过程：

```java
Json json = new Json();
json.setSerializer(PhoneNumber.class, new Json.Serializer<PhoneNumber>() {
   public void write (Json json, PhoneNumber number, Class knownType) {
      json.writeObjectStart();
      json.writeValue(number.name, number.number);
      json.writeObjectEnd();
   }

   public PhoneNumber read (Json json, JsonValue jsonData, Class type) {
      PhoneNumber number = new PhoneNumber();
      number.setName(jsonData.child().name());
      number.setNumber(jsonData.child().asString());
      return number;
   }
});
json.setElementType(Person.class, "numbers", PhoneNumber.class);
String text = json.prettyPrint(person);
System.out.println(text);
Person person2 = json.fromJson(Person.class, text);
```

## 序列化方法

`Json` 提供许多向 JSON 读写数据的方法。不带名称字符串的写入方法用于写入不是 JSON 对象字段的值（例如字符串或 JSON 数组中的对象）；带名称字符串的写入方法用于为 JSON 对象写入字段名和值。

使用 `writeObjectStart` 开始写入 JSON 对象，然后可以使用带名称字符串的写入方法写入值。对象写完后必须调用 `writeObjectEnd`：

```java
json.writeObjectStart();
json.writeValue("name", "value");
json.writeObjectEnd();
```

带有 actualType 和 knownType 的 `writeObjectStart` 方法会在两种类型不同时向 JSON 写入 class 字段。这样反序列化时就能知道实际类型。例如，已知类型可能是 java.util.Map，但实际类型是 java.util.LinkedHashMap（继承自 HashMap），因此反序列化时需要知道要创建的实际类型。

写入数组的方式类似，但应使用不带名称字符串的 write 方法写入值：

```java
json.writeArrayStart();
json.writeValue("value1");
json.writeValue("value2");
json.writeArrayEnd();
```

`Json` 类可以自动写入 Java 对象的字段和值。`writeFields` 会将指定 Java 对象的所有字段和值写入当前 JSON 对象：

```java
json.writeObjectStart();
json.writeFields(someObject);
json.writeObjectEnd();
```

`writeField` 方法写入单个 Java 对象字段的值：

```java
json.writeObjectStart();
json.writeField(someObject, "javaFieldName", "jsonFieldName");
json.writeObjectEnd();
```

许多写入方法都接受 “element type” 参数，用于指定集合中对象的已知类型。例如，对于列表：

```java
ArrayList list = new ArrayList();
list.add(someObject1);
list.add(someObject2);
list.add(someObject3);
list.add(someOtherObject);
...
json.writeObjectStart();
json.writeValue("items", list);
json.writeObjectEnd();

{
	items: [
		{ class: com.example.SomeObject, value: 1 },
		{ class: com.example.SomeObject, value: 2 },
		{ class: com.example.SomeObject, value: 3 },
		{ class: com.example.SomeOtherObject, value: four }
	]
}
```

这里列表中对象的已知类型是 Object，因此 “items” 的 JSON 中每个对象都有一个 class 字段，用于指定 Integer 或 String。通过指定元素类型并使用 Integer 作为已知类型，只有 “items” 的 JSON 中最后一个条目带有 class 字段：

```java
json.writeObjectStart();
json.writeValue("items", list, ArrayList.class, Integer.class);
json.writeObjectEnd();

{
	items: [
		{ value: 1 },
		{ value: 2 },
		{ value: 3 },
		{ class: com.example.SomeOtherObject, value: four }
	]
}
```

对于映射，element type 用于指定值的类型。映射的键始终是字符串，这是使用 JSON 描述对象字段所带来的限制。

注意，在可能的情况下，`Json` 类会使用 Java 字段声明中的泛型确定元素类型。

## 支持的类

注意，使用 GWT 时并非所有类都可序列化。`Json` 支持以下类型：
* POJOs
* OrderedMap（不包括 ArrayMap）
* Array
* String
* Float
* Boolean

请务必为不支持的类型提供自己的序列化器/反序列化器，或使用 `transient` 关键字标记不打算序列化的对象。

## 手动和基于事件的解析

`JsonReader` 类读取 JSON，并提供一些 protected 方法，在遇到 JSON 对象、数组、字符串、浮点数、长整数和布尔值时调用。默认情况下，这些方法使用 `JsonValue` 对象构建 DOM。可以重写这些方法，以便自行进行基于事件的 JSON 处理。

```java
// read something 
JsonValue fromJson = new JsonReader().parse(jsonAsString);
nickName = fromJson.getString("nickName");
// ...

// write something
JsonValue toJson = new JsonValue(JsonValue.ValueType.object);
toJson.addChild("name", new JsonValue("some name");
toJson.addChild("age", 12);
// ...
toJson.toJson(JsonWriter.OutputType.json);
```
