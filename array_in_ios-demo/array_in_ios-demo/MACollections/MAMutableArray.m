
#import "MAMutableArray.h"


@implementation MAMutableArray {
    NSUInteger _count;    // 数量
    NSUInteger _capacity; // 容量
    id *_objs;            // 数组
}

- (id)initWithCapacity: (NSUInteger)capacity
{
    return [super init];
}

- (void)dealloc
{
    [self removeAllObjects];
    free(_objs);             // 释放数组
    [super dealloc];
}

- (NSUInteger)count
{
    return _count;
}

- (id)objectAtIndex: (NSUInteger)index
{
    // 此处忽略了 index 检查
    return _objs[index];
}

- (void)addObject:(id)anObject
{
    [self insertObject: anObject atIndex: [self count]];
}

- (void)insertObject: (id)anObject atIndex: (NSUInteger)index
{
    // 保证有插入新元素的空间
    if(_count >= _capacity) // 容量不足
    {
        NSUInteger newCapacity = MAX(_capacity * 2, 16);      // 翻倍容量（最低为 16）
        id *newObjs = malloc(newCapacity * sizeof(*newObjs)); // 初始化
        
        // memcpy 不允许挪动的范围重叠
        // memcpy(void *__dst, const void *__src, size_t __n)
        memcpy(newObjs, _objs, _count * sizeof(*_objs));      // 放置旧数组
        
        free(_objs);                                          // 释放旧数组
        _objs = newObjs;
        _capacity = newCapacity;
    }
    
    // 挪动插入处后面的值（将 __src 移动到其本身后面一位，即 __dst）
    // memmove 允许挪动的范围重叠
    //  memmove(void *__dst, const void *__src, size_t __len)
    memmove(_objs + index + 1, _objs + index, ([self count] - index) * sizeof(*_objs));
    // 放置值
    _objs[index] = [anObject retain];
    
    // 数量增加
    _count++;
}

- (void)removeLastObject
{
    [self removeObjectAtIndex: [self count] - 1];
}

- (void)removeObjectAtIndex: (NSUInteger)index
{
    // 此处忽略了 index 检查
    [_objs[index] release];                                                                 // 释放
    memmove(_objs + index, _objs + index + 1, ([self count] - index - 1) * sizeof(*_objs)); // 挪动
    
    _count--;
}

- (void)replaceObjectAtIndex: (NSUInteger)index withObject: (id)anObject
{
    [anObject retain];       // 保留新对象
    [_objs[index] release];  // 释放旧对象
    _objs[index] = anObject; // 保存
}

@end

void MAMutableArrayTest(void)
{
    NSMutableArray *referenceArray = [NSMutableArray array];
    MAMutableArray *testArray = [MAMutableArray array];
    
    struct seed_t { unsigned short v[3]; };
    __block struct seed_t seed = { { 0, 0, 0 } };
    
    __block NSMutableArray *array;
    
    void (^blocks[])(void) = {
        ^{
            [array addObject: [NSNumber numberWithInt: nrand48(seed.v)]];
        },
        ^{
            id obj = [NSNumber numberWithInt: nrand48(seed.v)];
            NSUInteger index = nrand48(seed.v) % ([array count] + 1);
            [array insertObject: obj atIndex: index];
        },
        ^{
            if([array count] > 0)
                [array removeLastObject];
        },
        ^{
            if([array count] > 0)
                [array removeObjectAtIndex: nrand48(seed.v) % [array count]];
        },
        ^{
            if([array count] > 0)
            {
                id obj = [NSNumber numberWithInt: nrand48(seed.v)];
                NSUInteger index = nrand48(seed.v) % [array count];
                [array replaceObjectAtIndex: index withObject: obj];
            }
        }
    };
    
    NSMutableArray *operations = [NSMutableArray array];
    
    for(int i = 0; i < 100000; i++)
    {
        NSUInteger index = nrand48(seed.v) % (sizeof(blocks) / sizeof(*blocks));
        void (^block)(void) = blocks[index];
        [operations addObject: [NSNumber numberWithInteger: index]];
        
        struct seed_t oldSeed = seed;
        array = testArray;
        block();
        seed = oldSeed;
        array = referenceArray;
        block();
        
        if(![referenceArray isEqual: testArray])
        {
            int one = nrand48(oldSeed.v);
            int two = nrand48(oldSeed.v);
            NSLog(@"Next two random numbers are %d %d", one, two);
            NSLog(@"Arrays are not equal after %@: %@ %@", operations, referenceArray, testArray);
            exit(1);
        }
    }
}
