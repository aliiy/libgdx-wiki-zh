---
title: 集合
---
# 列表

## [Array](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/Array.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/Array.java)

一种可调整大小、有序或无序的对象数组，通常用来替代 ArrayList。它可以直接访问底层数组，而且底层数组可以是特定类型，而不仅是 Object[]。它也可以是无序的，表现得像一个[包/多重集](https://en.wikipedia.org/wiki/Set_%28computer_science%29#Multiset)。此时删除元素无需复制内存（最后一个元素会移动到被删除元素的位置）。

`iterator()` 返回的迭代器始终是同一个实例，因此 Array 可以在增强 for-each（`for( : )`）语法中使用而不会产生垃圾。但请注意，这与大多数可迭代集合不同！它不能用于嵌套循环，否则会产生难以查找的错误。

## 基本类型列表


  * [IntArray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/IntArray.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/IntArray.java)
  * [FloatArray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/FloatArray.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/FloatArray.java)
  * [BooleanArray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/BooleanArray.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/BooleanArray.java)
  * [CharArray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/CharArray.html)
[（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/CharArray.java)
  * [LongArray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/LongArray.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/LongArray.java)
  * [ByteArray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/ByteArray.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/ByteArray.java)

它们与 Array 相同，但使用基本类型而非对象，从而避免装箱和拆箱。

## 专用列表


### [SnapshotArray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/SnapshotArray.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/SnapshotArray.java)

它与 Array 相同，但保证从 `begin()` 返回的数组条目（索引 0 到调用 `begin` 时的 size）在调用 `end()` 前不会被修改。这可用于避免并发修改。迭代必须采用特定方式：

```java
SnapshotArray array = new SnapshotArray();
// ...
Object[] items = array.begin();
for (int i = 0, n = array.size; i < n; i++) {
	Object item = items[i];
	// ...
}
array.end();
```

如果 `begin()` 和 `end()` 之间的代码会修改 SnapshotArray，就会复制内部数组，从而避免正在迭代的数组被修改。发生这种情况时创建的额外备份数组会被保留，以便将来再次发生并发修改时复用。

### [DelayedRemovalArray](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/DelayedRemovalArray.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/DelayedRemovalArray.java)

它与 Array 相同，但在调用 `begin()` 后执行的删除会排队，直到调用 `end()` 才真正发生。这可用于避免并发修改。请注意，使用此列表的代码必须意识到，被删除的项目不会立即移除。因此，SnapshotArray 通常更易于使用。


### [PooledLinkedList](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/PooledLinkedList.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/PooledLinkedList.java)

一个会复用节点的简单链表。

### [SortedIntList](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/SortedIntList.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/SortedIntList.java)

一个使用 int 作为索引的有序双向链表。

# 映射


## [ObjectMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/ObjectMap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/ObjectMap.java)

一种无序映射。该实现是使用三个哈希、随机探查和小型暂存区处理问题键的布谷鸟哈希映射。不允许空键，但允许空值。除非扩大表大小，否则不会分配内存。

键只能位于备份数组的三个位置之一，因此该映射可以非常快速地执行 get、containsKey 和 remove。Put 的速度可能稍慢，具体取决于哈希冲突。负载因子大于 0.91 时，映射重新哈希到下一个更大的 POT 备份数组的概率会大幅增加。

## 基本类型映射

  * [IntMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/IntMap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/IntMap.java)
  * [LongMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/LongMap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/LongMap.java)
  * [ObjectIntMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/ObjectIntMap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/ObjectIntMap.java)
  * [ObjectFloatMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/ObjectFloatMap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/ObjectFloatMap.java)

这些映射与 ObjectMap 相同，但键使用基本类型；ObjectIntMap 和 ObjectFloatMap 则使用基本类型值。这样可以避免装箱和拆箱。

## 专用映射

###  [OrderedMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/OrderedMap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/OrderedMap.java)

该映射与 ObjectMap 相同，但还会将键存储在 Array 中。这会增加 put 和 remove 的开销，但能提供有序迭代。可以直接对键 Array 排序来改变迭代顺序。

### [IdentityMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/IdentityMap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/IdentityMap.java)

该映射与 ObjectMap 相同，但键使用身份比较（`==` 而不是 `.equals()`）。

### [ArrayMap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/ArrayMap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/ArrayMap.java)        

该映射同时使用数组存储键和值。这意味着 get 会比较映射中的每个键，但可以提供快速、有序的迭代，并可按索引查找条目。

# 集合

## [ObjectSet](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/ObjectSet.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/ObjectSet.java)

与 ObjectMap 完全相同，但只存储键，不为每个键存储值。

## 基本类型集合

  * [IntSet](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/IntSet.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/IntSet.java)

这些集合与 ObjectSet 相同，但键使用基本类型，从而避免装箱和拆箱。

# 其他集合

### [BinaryHeap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/BinaryHeap.html) [（代码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/BinaryHeap.java)

一个[二叉堆](https://en.wikipedia.org/wiki/Binary_heap)，可以是最小堆或最大堆。

# 基准测试
下面的基准测试展示了使用 libGDX 集合方法进行数组和哈希表查找（`.contains()` 或 `.get()`）的差异。
如果列表少于 1024 个元素，不必纠结使用数组还是哈希表（Map 或 Set）。请注意，哈希表的迭代速度明显慢于数组，并且无法排序。

```
                  array.size         GdxArray.contains()     GdxObjectSet.contains()
                           2                         0ms                         0ms
                           4                         0ms                         0ms
                           8                         0ms                         1ms
                          16                         0ms                         1ms
                          32                         0ms                         0ms
                          64                         0ms                         0ms
                         128                         0ms                         0ms
                         256                         1ms                         0ms
                         512                         1ms                         0ms
                        1024                         2ms                         0ms
                        2048                         4ms                         0ms
                        4096                        11ms                         0ms
                        8192                        22ms                         0ms
                       16384                        80ms                         0ms
                       32768                       112ms                         0ms
                       65536                       403ms                         0ms
                      131072                       615ms                         1ms
```
