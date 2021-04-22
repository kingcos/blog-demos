//
//  KVNotificationCenter.m
//  NSNotification-Demo
//
//  Created by kingcos on 2021/4/23.
//

#import "KVNotificationCenter.h"
#import "KVNotification.h"
#import "KVStructure.h"

/**
 * Concrete class implementing NSNotification.
 */
@interface    _KVNotification : KVNotification
{
@public
  NSString    *_name;
  id        _object;
  NSDictionary    *_info;
}
@end

@implementation _KVNotification

static Class concrete = 0;

+ (void) initialize
{
  if (concrete == 0)
    {
      concrete = [_KVNotification class];
    }
}

+ (KVNotification*) notificationWithName: (NSString*)name
                  object: (id)object
                    userInfo: (NSDictionary*)info
{
    _KVNotification    *n;

    n = [[_KVNotification alloc] init];
    n->_name = [name copy];
    n->_object = object;
    n->_info = info;
    
    return nil;
}

- (NSString*) name
{
  return _name;
}

- (id) object
{
  return _object;
}

- (NSDictionary*) userInfo
{
  return _info;
}

@end

/*
 * Garbage collection considerations -
 * The notification center is not supposed to retain any notification
 * observers or notification objects.  To achieve this when using garbage
 * collection, we must hide all references to observers and objects.
 * Within an Observation structure, this is not a problem, we simply
 * allocate the structure using 'atomic' allocation to tell the gc
 * system to ignore pointers inside it.
 * Elsewhere, we store the pointers with a bit added, to hide them from
 * the garbage collector.
 */

struct    NCTbl;        /* Notification Center Table structure    */

/*
 * Observation structure - One of these objects is created for
 * each -addObserver... request.  It holds the requested selector,
 * name and object.  Each struct is placed in one LinkedList,
 * as keyed by the NAME/OBJECT parameters.
 * If 'next' is 0 then the observation is unused (ie it has been
 * removed from, or not yet added to  any list).  The end of a
 * list is marked by 'next' being set to 'ENDOBS'.
 *
 * This is normally a structure which handles memory management using a fast
 * reference count mechanism, but when built with clang for GC, a structure
 * can't hold a zeroing weak pointer to an observer so it's implemented as a
 * trivial class instead ... and gets managed by the garbage collector.
 */

typedef    struct    Obs {
  id        observer;    /* Object to receive message.    */
  SEL        selector;    /* Method selector.        */
  struct Obs    *next;        /* Next item in linked list.    */
  int        retained;    /* Retain count for structure.    */
  struct NCTbl    *link;        /* Pointer back to chunk table    */
} Observation;

#define    ENDOBS    ((Observation*)-1)

#define    CHUNKSIZE    128
#define    CACHESIZE    16

typedef struct NCTbl {
  Observation        *wildcard;    /* Get ALL messages.        */
  GSIMapTable        nameless;    /* Get messages for any name.    */
  GSIMapTable        named;        /* Getting named messages only.    */
  unsigned        lockCount;    /* Count recursive operations.    */
  NSRecursiveLock    *_lock;        /* Lock out other threads.    */
  Observation        *freeList;
  Observation        **chunks;
  unsigned        numChunks;
  GSIMapTable        cache[CACHESIZE];
  unsigned short    chunkIndex;
  unsigned short    cacheIndex;
} NCTable;

#define    TABLE        ((NCTable*)_table)
#define    WILDCARD    (TABLE->wildcard)
#define    NAMELESS    (TABLE->nameless)
#define    NAMED        (TABLE->named)
#define    LOCKCOUNT    (TABLE->lockCount)

static Observation *
obsNew(NCTable *t, SEL s, id o)
{
  Observation    *obs;
  // ...
  return obs;
}

static GSIMapTable    mapNew(NCTable *t)
{
  GSIMapTable    m;
  // ...
  return m;
}

static NCTable *newNCTable(void)
{
  NCTable    *t;
  // ...
  return t;
}

static inline void lockNCTable(NCTable* t)
{
  [t->_lock lock];
  t->lockCount++;
}

static inline void unlockNCTable(NCTable* t)
{
  t->lockCount--;
  [t->_lock unlock];
}

@implementation KVNotificationCenter

static KVNotificationCenter *default_center = nil;

/**
 * Returns the default notification center being used for this task (process).
 * This is used for all notifications posted by the Base library unless
 * otherwise noted.
 */
+ (KVNotificationCenter*) defaultCenter
{
  return default_center;
}

/* Initializing. */

- (id) init
{
  if ((self = [super init]) != nil)
    {
      _table = newNCTable();
    }
  return self;
}

/* Adding new observers. */

/**
 * <p>Registers observer to receive notifications with the name
 * notificationName and/or containing object (one or both of these two must be
 * non-nil; nil acts like a wildcard).  When a notification of name name
 * containing object is posted, observer receives a selector message with this
 * notification as the argument.  The notification center waits for the
 * observer to finish processing the message, then informs the next registree
 * matching the notification, and after all of this is done, control returns
 * to the poster of the notification.  Therefore the processing in the
 * selector implementation should be short.</p>
 *
 * <p>The notification center does not retain observer or object. Therefore,
 * you should always send removeObserver: or removeObserver:name:object: to
 * the notification center before releasing these objects.<br />
 * As a convenience, when built with garbage collection, you do not need to
 * remove any garbage collected observer as the system will do it implicitly.
 * </p>
 *
 * <p>NB. For MacOS-X compatibility, adding an observer multiple times will
 * register it to receive multiple copies of any matching notification, however
 * removing an observer will remove <em>all</em> of the multiple registrations.
 * </p>
 */
- (void) addObserver: (id)observer
        selector: (SEL)selector
                name: (NSString*)name
          object: (id)object
{
  Observation    *list;
  Observation    *o;
  GSIMapTable    m;
  GSIMapNode    n;

  if (observer == nil)
    [NSException raise: NSInvalidArgumentException
        format: @"Nil observer passed to addObserver ..."];

  if (selector == 0)
    [NSException raise: NSInvalidArgumentException
        format: @"Null selector passed to addObserver ..."];

  if ([observer respondsToSelector: selector] == NO)
    {
      [NSException raise: NSInvalidArgumentException
        format: @"[%@-%@] Observer '%@' does not respond to selector '%@'",
        NSStringFromClass([self class]), NSStringFromSelector(_cmd),
        observer, NSStringFromSelector(selector)];
    }

  lockNCTable(TABLE);

  o = obsNew(TABLE, selector, observer);

  /*
   * Record the Observation in one of the linked lists.
   *
   * NB. It is possible to register an observer for a notification more than
   * once - in which case, the observer will receive multiple messages when
   * the notification is posted... odd, but the MacOS-X docs specify this.
   */

  if (name)
    {
      /*
       * Locate the map table for this name - create it if not present.
       */
      n = GSIMapNodeForKey(NAMED, (GSIMapKey)(id)name);
      if (n == 0)
    {
      m = mapNew(TABLE);
      /*
       * As this is the first observation for the given name, we take a
       * copy of the name so it cannot be mutated while in the map.
       */
      name = [name copyWithZone: NSDefaultMallocZone()];
//      GSIMapAddPair(NAMED, (GSIMapKey)(id)name, (GSIMapVal)(void*)m);
//      GS_CONSUMED(name)
    }
      else
    {
//      m = (GSIMapTable)n->value.ptr;
    }

      /*
       * Add the observation to the list for the correct object.
       */
      n = GSIMapNodeForSimpleKey(m, (GSIMapKey)object);
      if (n == 0)
    {
      o->next = ENDOBS;
//      GSIMapAddPair(m, (GSIMapKey)object, (GSIMapVal)o);
    }
      else
    {
//      list = (Observation*)n->value.ptr;
      o->next = list->next;
      list->next = o;
    }
    }
  else if (object)
    {
      n = GSIMapNodeForSimpleKey(NAMELESS, (GSIMapKey)object);
      if (n == 0)
    {
      o->next = ENDOBS;
//      GSIMapAddPair(NAMELESS, (GSIMapKey)object, (GSIMapVal)o);
    }
      else
    {
//      list = (Observation*)n->value.ptr;
      o->next = list->next;
      list->next = o;
    }
    }
  else
    {
      o->next = WILDCARD;
      WILDCARD = o;
    }

  unlockNCTable(TABLE);
}


@end
