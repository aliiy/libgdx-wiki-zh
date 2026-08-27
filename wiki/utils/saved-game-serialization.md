---
title: 已保存游戏的序列化
---
对于简单数据类型的保存，libGDX 提供了 [Preferences](/wiki/preferences)。但如果想保存自定义对象，尤其是整个游戏状态（通常需要保存到磁盘以便稍后恢复），就必须先将其序列化。有几种不同的实现方式。

# JSON 序列化

libGDX 的 [JSON](/wiki/utils/reading-and-writing-json) 类可以自动将 Java 对象转换为 JSON，或从 JSON 转换回来。详情请参阅对应的 wiki 文章。

# 二进制序列化

另一种[高效](https://github.com/eishay/jvm-serializers/wiki)序列化 Java 对象的方案是使用 [Kryo](https://github.com/EsotericSoftware/kryo) 库。Kryo 可以处理大多数 POJO 和其他类，但某些类需要特殊处理。下面是一些适用于 libGDX 类的自定义序列化器。

请注意，大多数情况下不应序列化 `Texture` 之类的类。在对象图中使用 String 代替 Texture 对象会更好。序列化后，可以处理对象，并通过字符串路径查找纹理。
{: .notice--warning}

```java
// Register a custom Array serializer
kryo.register(Array.class, new Serializer<Array>() {
	{
		setAcceptsNull(true);
	}

	private Class genericType;

	public void setGenerics (Kryo kryo, Class[] generics) {
		if (generics != null && kryo.isFinal(generics[0])) genericType = generics[0];
		else genericType = null;
	}

	public void write (Kryo kryo, Output output, Array array) {
		int length = array.size;
		output.writeInt(length, true);
		if (length == 0) {
			genericType = null;
			return;
		}
		if (genericType != null) {
			Serializer serializer = kryo.getSerializer(genericType);
			genericType = null;
			for (Object element : array)
				kryo.writeObjectOrNull(output, element, serializer);
		} else {
			for (Object element : array)
				kryo.writeClassAndObject(output, element);
		}
	}

	public Array read (Kryo kryo, Input input, Class<Array> type) {
		Array array = new Array();
		kryo.reference(array);
		int length = input.readInt(true);
		array.ensureCapacity(length);
		if (genericType != null) {
			Class elementClass = genericType;
			Serializer serializer = kryo.getSerializer(genericType);
			genericType = null;
			for (int i = 0; i < length; i++)
				array.add(kryo.readObjectOrNull(input, elementClass, serializer));
		} else {
			for (int i = 0; i < length; i++)
				array.add(kryo.readClassAndObject(input));
		}
		return array;
	}
});

// Register a custom IntArray serializer
kryo.register(IntArray.class, new Serializer<IntArray>() {
	{
		setAcceptsNull(true);
	}

	public void write (Kryo kryo, Output output, IntArray array) {
		int length = array.size;
		output.writeInt(length, true);
		if (length == 0) return;
		for (int i = 0, n = array.size; i < n; i++)
			output.writeInt(array.get(i), true);
	}

	public IntArray read (Kryo kryo, Input input, Class<IntArray> type) {
		IntArray array = new IntArray();
		kryo.reference(array);
		int length = input.readInt(true);
		array.ensureCapacity(length);
		for (int i = 0; i < length; i++)
			array.add(input.readInt(true));
		return array;
	}
});

// Register a custom FloatArray serializer
kryo.register(FloatArray.class, new Serializer<FloatArray>() {
	{
		setAcceptsNull(true);
	}

	public void write (Kryo kryo, Output output, FloatArray array) {
		int length = array.size;
		output.writeInt(length, true);
		if (length == 0) return;
		for (int i = 0, n = array.size; i < n; i++)
			output.writeFloat(array.get(i));
	}

	public FloatArray read (Kryo kryo, Input input, Class<FloatArray> type) {
		FloatArray array = new FloatArray();
		kryo.reference(array);
		int length = input.readInt(true);
		array.ensureCapacity(length);
		for (int i = 0; i < length; i++)
			array.add(input.readFloat());
		return array;
	}
});

// Register a custom Color serializer
kryo.register(Color.class, new Serializer<Color>() {
	public Color read (Kryo kryo, Input input, Class<Color> type) {
		Color color = new Color();
		Color.rgba8888ToColor(color, input.readInt());
		return color;
	}

	public void write (Kryo kryo, Output output, Color color) {
		output.writeInt(Color.rgba8888(color));
	}
});
```
