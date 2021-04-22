//
//  KVStructure.h
//  NSNotification-Demo
//
//  Created by kingcos on 2021/4/22.
//

#ifndef KVStructure_h
#define KVStructure_h

#define GSI_MAP_EXTRA uintptr_t

typedef id GSIMapKey;
typedef id GSIMapVal;

typedef struct _GSIMapNode GSIMapNode_t;
typedef GSIMapNode_t *GSIMapNode;

struct _GSIMapNode { // GSIMap 节点
  GSIMapNode    nextInBucket;    /* Linked list of bucket. 桶的链表 */
  GSIMapKey    key;
  GSIMapVal    value;
};

typedef struct _GSIMapBucket GSIMapBucket_t;
typedef GSIMapBucket_t *GSIMapBucket;

struct _GSIMapBucket { // GSIMap 桶
  uintptr_t    nodeCount;    /* Number of nodes in bucket. 桶中的节点数 */
  GSIMapNode    firstNode;    /* The linked list of nodes. 头节点 */
};

typedef struct _GSIMapTable GSIMapTable_t;
typedef GSIMapTable_t *GSIMapTable;

struct _GSIMapTable { // GSIMap 表
  NSZone    *zone;
  uintptr_t    nodeCount;    /* Number of used nodes in map. Map 中已使用的节点数 */
  uintptr_t    bucketCount;    /* Number of buckets in map. Map 中的桶数 */
  GSIMapBucket    buckets;    /* Array of buckets. 桶的数组 */
  GSIMapNode    freeNodes;    /* List of unused nodes. 空闲节点 */
  uintptr_t    chunkCount;    /* Number of chunks in array. 数组块数 */
  GSIMapNode    *nodeChunks;    /* Chunks of allocated memory. 已分配内存的块数 */
  uintptr_t    increment;
#ifdef    GSI_MAP_EXTRA
  GSI_MAP_EXTRA    extra;
#endif
};

#endif /* KVStructure_h */

/*
 *  Description of the datastructure
 *  数据结构描述
 *  --------------------------------
 *  The complete GSIMap implementation can be viewed in two different ways,
 *  GSIMap 的完整实现可以从两种不同的角度来解析，
 *
 *  (1) viewed as a structure to add and retrieve elements
 *      作为一个添加和取回元素的结构（bucket，桶）
 *  (2) viewed as a memory management structure to facilitate (1)
 *      作为一个内存管理结构，以促进 (1)（chunk，块）
 *
 *  The first view is best described as follows:
 *  第一个角度描述如下：
 *
 *   _GSIMapTable   ----->  C-array of buckets 桶的 C 数组
 *
 *  Where each bucket contains a count (nodeCount), describing the number
 *  of nodes in the bucket and a pointer (firstNode) to a single linked
 *  list of nodes.
 *  其中每个桶包含一个计数（nodeCount），描述了桶中的节点数，
 *  以及一个指向单链表的指针（firstNode）。
 *
 *  The second view is slightly more complicated.
 *  The individual nodes are allocated and deallocated in chunks.
 *  In order to keep track of this we have:
 *  第二个角度稍微复杂一些。
 *  单个节点是以块为单位分配和取消分配的。为了跟踪这一点，我们有：
 *
 *   _GSIMapTable   ----->  C-array of chunks 桶的 C 数组
 *
 *  Where each chunk points to a C-array of nodes.
 *  Also the _GSIMapTable contains a pointer to the free nodes
 *  其中每个块都指向一个 C-array 的节点。
 *  同时 _GSIMapTable 包含一个指向空闲节点的指针
 *
 *   _GSIMapTable   ----->  single linked list of free nodes 空闲节点的单链表
 *
 *  Consequence of this is that EVERY node is part of a single linked list.
 *  Either it is in use and reachable from a bucket, or it is part of the
 *  freeNodes linked list.
 *  Also EVERY node is part of chunk, due to the way the nodes are allocated.
 *  这样做的后果是，**每个**节点都是单链表的一部分。
 *  要么它被使用且可以通过一个桶访问，要么是 freeNodes 链表的一部分。
 *  由于节点被分配的方式，**每个**节点都是块的一部分。
 *
 *  A rough picture is include below:
 *  下面是一个粗略的图片：
 *
 *
 *   This is the map                C - array of the buckets
 *   +---------------+             +---------------+
 *   | _GSIMapTable  |      /----->| nodeCount     |
 *   |---------------|     /       | firstNode ----+--\
 *   | buckets    ---+----/        | ..........    |  |
 *   | bucketCount  =| size of --> | nodeCount     |  |
 *   | nodeChunks ---+--\          | firstNode     |  |
 *   | chunkCount  =-+\ |          |     .         |  |
 *   |   ....        || |          |     .         |  |
 *   +---------------+| |          | nodeCount     |  |
 *                    | |          | fistNode      |  |
 *                    / |          +---------------+  |
 *         ----------   v                             v
 *       /       +----------+      +---------------------------+
 *       |       |  * ------+----->| Node1 | Node2 | Node3 ... | a chunk
 *   chunkCount  |  * ------+--\   +---------------------------+
 *  is size of = |  .       |   \  +-------------------------------+
 *               |  .       |    ->| Node n | Node n + 1 | ...     | another
 *               +----------+      +-------------------------------+
 *               array pointing
 *               to the chunks
 *
 *
 *  NOTES on the way chunks are allocated
 *  关于块的分配方式的说明
 *  -------------------------------------
 *  Chunks are allocated when needed, that is a new chunk is allocated
 *  whenever the freeNodes list is empty and a new node is required.
 *  块是在需要的时候分配的，也就是说，只要 freeNodes 列表是空的，需要一个新的节点，就会分配一个新的块。
 *  In gnustep-base-1.9.0 the size of the new chunk is calculated as
 *  roughly 3/4 of the number of nodes in use.
 *  在 gnustep-base-1.9.0 中，新块的大小被计算为使用中的节点数量的大约 3/4。
 *  The problem with this approach is that it can lead to unnecessary
 *  address space fragmentation.  So in this version the algorithm we
 *  will use the 3/4 rule until the nodeCount reaches the "increment"
 *  member variable.
 *  这种方法的问题是，它可能导致不必要的地址空间碎片化。
 *  所以在这个版本的算法中，我们将使用 3/4 规则，直到 nodeCount 达到 "increment" 成员变量。
 *  If nodeCount is bigger than the "increment" it will allocate chunks
 *  of size "increment".
 *  如果 nodeCount 大于 "increment"，它将分配大小为 "increment" 的块。
 */

/* To easily un-inline functions for debugging */
#ifndef GS_STATIC_INLINE
#define GS_STATIC_INLINE static inline
#endif

GS_STATIC_INLINE void
GSIMapRightSizeMap(GSIMapTable map, uintptr_t capacity) {};

GS_STATIC_INLINE void
GSIMapMoreNodes(GSIMapTable map, unsigned required) {};

GS_STATIC_INLINE GSIMapNode
GSIMapNodeForKey(GSIMapTable map, GSIMapKey key)
{
  GSIMapNode    node;
  // ...
  return node;
}

GS_STATIC_INLINE GSIMapNode
GSIMapAddPair(GSIMapTable map, GSIMapKey key, GSIMapVal value)
{
  GSIMapNode    node = map->freeNodes;
  // ....
  return node;
}

GS_STATIC_INLINE GSIMapNode
GSIMapNodeForSimpleKey(GSIMapTable map, GSIMapKey key)
{
  GSIMapNode    node;
  // ...
  return node;
}

GS_STATIC_INLINE void
GSIMapInitWithZoneAndCapacity(GSIMapTable map, uintptr_t capacity)
{
//  map->zone = zone;
  map->nodeCount = 0;
  map->bucketCount = 0;
  map->buckets = 0;
  map->nodeChunks = 0;
  map->freeNodes = 0;
  map->chunkCount = 0;
  map->increment = 300000;   // choosen so the chunksize will be less than 4Mb
  GSIMapRightSizeMap(map, capacity);
  GSIMapMoreNodes(map, capacity);
}
