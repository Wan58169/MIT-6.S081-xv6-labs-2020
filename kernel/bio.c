// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

// struct {
//   struct spinlock lock;
//   struct buf buf[NBUF];

//   // Linked list of all buffers, through prev/next.
//   // Sorted by how recently the buffer was used.
//   // head.next is most recent, head.prev is least.
//   struct buf head;
// } bcache;

struct {
  struct buf buf[NBUF];

  // Linked list of all buffers, through prev/next.
  // Sorted by how recently the buffer was used.
  // head.next is most recent, head.prev is least.
  struct buf buckets[NBUCKET];
  struct spinlock lks[NBUCKET];
} bcache;

extern uint ticks;

static int
myhash(int x)
{
  return x%NBUCKET;
}

/** 版本0 */
// void
// binit(void)
// {
//   struct buf *b;

//   initlock(&bcache.lock, "bcache");

//   // Create linked list of buffers
//   bcache.head.prev = &bcache.head;
//   bcache.head.next = &bcache.head;
//   for(b = bcache.buf; b < bcache.buf+NBUF; b++){
//     b->next = bcache.head.next;
//     b->prev = &bcache.head;
//     initsleeplock(&b->lock, "buffer");
//     bcache.head.next->prev = b;
//     bcache.head.next = b;
//   }
// }

/** 版本1 */
void
binit(void)
{
  struct buf *b;

  for(int i=0; i<NBUCKET; i++) 
    initlock(&bcache.lks[i], "bcache");

  // Create linked list of buffers
  for(int i=0; i<NBUCKET; i++) {
    bcache.buckets[i].prev = &bcache.buckets[i];
    bcache.buckets[i].next = &bcache.buckets[i];
  }

  /**
   * buf一开始全部挂载至0号哈希桶，
   * 这样方便后续接济其他哈希桶，因为
   * 有的哈希桶里可能没有buf 
   * */
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.buckets[0].next;
    b->prev = &bcache.buckets[0];
    initsleeplock(&b->lock, "buffer");
    bcache.buckets[0].next->prev = b;
    bcache.buckets[0].next = b;
  }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.

/** 版本0 */
// static struct buf*
// bget(uint dev, uint blockno)
// {
//   struct buf *b;

//   acquire(&bcache.lock);

//   // Is the block already cached?
//   for(b = bcache.head.next; b != &bcache.head; b = b->next){
//     if(b->dev == dev && b->blockno == blockno){
//       b->refcnt++;
//       release(&bcache.lock);
//       acquiresleep(&b->lock);
//       return b;
//     }
//   }

//   // Not cached.
//   // Recycle the least recently used (LRU) unused buffer.
//   /** 
//    * 在bcache中，尝试寻找目前没有被使用的buf
//    * 将其换下，为新的数据腾出空间 
//    * */
//   for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
//     if(b->refcnt == 0) {
//       /** 直接覆盖待淘汰的buf，无需再将其中的旧内容写回至disk中 */
//       b->dev = dev;
//       b->blockno = blockno;
//       /** 标记位valid置0，为了保证能够读取到最新的数据 */
//       b->valid = 0;
//       b->refcnt = 1;
//       release(&bcache.lock);
//       acquiresleep(&b->lock);
//       return b;
//     }
//   }
//   panic("bget: no buffers");
// }

/** 版本1 */
// static struct buf*
// bget(uint dev, uint blockno)
// {
//   struct buf *b;

//   int id = myhash(blockno);

//   acquire(&bcache.lks[id]);
//   // Is the block already cached?
//   for(b = bcache.buckets[id].next; b != &bcache.buckets[id]; b = b->next){
//     if(b->dev == dev && b->blockno == blockno) {
//       b->refcnt++;
//       release(&bcache.lks[id]);
//       acquiresleep(&b->lock);
//       return b;
//     }
//   }
//   release(&bcache.lks[id]);
  
//   /** 
//    * 这里我们需要再一次检查第 id 号哈希桶是否已缓冲 block ，因为 
//    * 第一遍的检查，上锁放锁都是小锁（哈希桶的锁），而不是 bcache 的。
//    * 试想，针对第 id 号哈希桶，进程 AB 都进入了 bget 中。进程 A 此时就是
//    * 在做哈希桶检查，它拿的是小锁（ lks[id] ），那么大锁（ bcache.lock ）就是空闲的。
//    * 若此时进程 B 拿了大锁，待进程 A 放了小锁之后，进程 B 立刻再拿小锁，
//    * 顺利执行数据追加操作（向第 id 号哈希桶插入数据），在此过程中，进程 A 拿不到大锁，只能干瞪眼。完事后，
//    * 进程 A 若不再次遍历第 id 号哈希桶，将会错过一个成功捕捉 cache 的机会。另外，
//    * 上大锁的目的，主要是为了提高 cache 的命中率，进程 B 淘汰 or 偷别人的 buf 都会移至第 id 号哈希桶中，
//    * 这个结果是与进程 A 共享的。上大锁，就是阻止进程 A 也去偷。你想想，反正都是去劳动（成果共享），
//    * 不如让一个人去，这样还能省出一双干净的手（进程 A ），少做一次重复劳动。都去劳动 or 偷，反而更容易造成竞争
//    * 偷的过程中进程 AB 发生碰撞（一起抢同一个哈希桶）
//    * */
//   acquire(&bcache.lock);
//   acquire(&bcache.lks[id]);
//   // Is the block already cached?
//   for(b = bcache.buckets[id].next; b != &bcache.buckets[id]; b = b->next){
//     if(b->dev == dev && b->blockno == blockno){
//       b->refcnt++;
//       release(&bcache.lks[id]);
//       release(&bcache.lock);
//       acquiresleep(&b->lock);
//       return b;
//     }
//   }

//   /**
//    * 第二遍检查也没有发现cached的buf，那么就根据 ticks LRU 策略
//    * 选择第 id 号哈希桶中 ticks 最小的淘汰，ticks 最小意味着
//    * 该 buf 在众多未被使用到（ b->refcnt==0 ）的 buf 中是距今最远的
//    * */
//   // Not cached.
//   // Recycle the least recently used (LRU) unused buffer.
//   struct buf *victm = 0;
//   uint minticks = ticks;
//   for(b = bcache.buckets[id].next; b != &bcache.buckets[id]; b = b->next){
//     if(b->refcnt==0 && b->lastuse<=minticks) {
//       minticks = b->lastuse;
//       victm = b;
//     }
//   }

//   if(!victm) 
//     goto steal;

//   /** 直接覆盖待淘汰的buf，无需再将其中的旧内容写回至disk中 */
//   victm->dev = dev;
//   victm->blockno = blockno;
//   /** 标记位valid置0，为了保证能够读取到最新的数据 */
//   victm->valid = 0;
//   victm->refcnt = 1;
//   release(&bcache.lks[id]);
//   release(&bcache.lock);
//   acquiresleep(&victm->lock);
//   return victm;

// steal:
//   /** 到别的哈希桶挖buf */
//   for(int i=0; i<NBUCKET; i++) {
//     if(i == id)
//       continue;

//     acquire(&bcache.lks[i]);
//     minticks = ticks;
//     for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
//       if(b->refcnt==0 && b->lastuse<=minticks) {
//         minticks = b->lastuse;
//         victm = b;
//       }
//     }

//     if(!victm) {
//       release(&bcache.lks[i]);
//       continue;
//     }

//     victm->dev =dev;
//     victm->blockno = blockno;
//     victm->valid = 0;
//     victm->refcnt = 1;
//     /** 将 victm 从第 i 号哈希桶中取出来，接入第 id 号中 */
//     victm->next->prev = victm->prev;
//     victm->prev->next = victm->next;
//     release(&bcache.lks[i]);
//     victm->next = bcache.buckets[id].next;
//     bcache.buckets[id].next->prev = victm;
//     bcache.buckets[id].next = victm;
//     victm->prev = &bcache.buckets[id];
//     release(&bcache.lks[id]);
//     release(&bcache.lock);  
//     acquiresleep(&victm->lock);
//     return victm;
//   }

//   release(&bcache.lks[id]);
//   release(&bcache.lock);
//   panic("bget: no buf");
// }

static void
bufinit(struct buf* b, uint dev, uint blockno)
{
  b->dev = dev;
  b->blockno = blockno;
  b->valid = 0;
  b->refcnt = 1;
}

/** 版本2 */
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  int id = myhash(blockno);
  
  acquire(&bcache.lks[id]);
  // Is the block already cached?
  for(b = bcache.buckets[id].next; b != &bcache.buckets[id]; b = b->next){
    if(b->dev == dev && b->blockno == blockno){
      b->refcnt++;
      release(&bcache.lks[id]);
      acquiresleep(&b->lock);
      return b;
    }
  }

  /**
   * 检查没有发现cached的 buf，那么就根据 ticks LRU 策略
   * 选择第 id 号哈希桶中 ticks 最小的淘汰，ticks 最小意味着
   * 该 buf 在众多未被使用到（ b->refcnt==0 ）的 buf 中是距今最远的
   * */
  // Not cached.
  // Recycle the least recently used (LRU) unused buffer.
  struct buf *victm = 0;
  uint minticks = ticks;
  for(b = bcache.buckets[id].next; b != &bcache.buckets[id]; b = b->next){
    if(b->refcnt==0 && b->lastuse<=minticks) {
      minticks = b->lastuse;
      victm = b;
    }
  }

  if(!victm) 
    goto steal;

  /** 
   * 直接覆盖待淘汰的buf，无需再将其中的旧内容写回至disk中 
   * 标记位valid置0，为了保证能够读取到最新的数据 
   * */
  bufinit(victm, dev, blockno);

  release(&bcache.lks[id]);
  acquiresleep(&victm->lock);
  return victm;

steal:
  /** 到别的哈希桶挖 buf */
  for(int i=0; i<NBUCKET; i++) {
    if(i == id)
      continue;

    acquire(&bcache.lks[i]);
    minticks = ticks;
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
      if(b->refcnt==0 && b->lastuse<=minticks) {
        minticks = b->lastuse;
        victm = b;
      }
    }

    if(!victm) {
      release(&bcache.lks[i]);
      continue;
    }

    bufinit(victm, dev, blockno);

    /** 将 victm 从第 i 号哈希桶中取出来 */
    victm->next->prev = victm->prev;
    victm->prev->next = victm->next;
    release(&bcache.lks[i]);

    /** 将 victm 接入第 id 号中 */
    victm->next = bcache.buckets[id].next;
    bcache.buckets[id].next->prev = victm;
    bcache.buckets[id].next = victm;
    victm->prev = &bcache.buckets[id];

    release(&bcache.lks[id]);
    acquiresleep(&victm->lock);
    return victm;
  }

  release(&bcache.lks[id]);
  panic("bget: no buf");
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  
  /** 如果buf中的数据过时了，那么需要重新读取 */
  if(!b->valid) {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b, 1);
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.

/** 版本0 */
// void
// brelse(struct buf *b)
// {
//   if(!holdingsleep(&b->lock))
//     panic("brelse");

//   releasesleep(&b->lock);

//   acquire(&bcache.lock);
//   b->refcnt--;
//   if (b->refcnt == 0) {
//     // no one is waiting for it.
//     /** 
//      * 将buf移至bcache.head之后，意味着
//      * 该buf是least recently used，是可以被淘汰的
//      * 将可淘汰的buf放在bcache队首的好处，就是
//      * bget时可以快速定位到未被使用的buf
//      * */
//     b->next->prev = b->prev;
//     b->prev->next = b->next;
//     b->next = bcache.head.next;
//     b->prev = &bcache.head;
//     bcache.head.next->prev = b;
//     bcache.head.next = b;
//   }
  
//   release(&bcache.lock);
// }

/** 版本1 */
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);

  /** 
   * 新的LRU算法是基于时间戳的，具体就是引用 kernel/trap.c:ticks
   * 不是原始的LRU算法，所以无需再将可淘汰的buf提到bcache队首 
   * 只需记录最后一次使用的时间戳即可
   * */
  int id = myhash(b->blockno);

  acquire(&bcache.lks[id]);
  b->refcnt--;
  if(b->refcnt == 0)
    b->lastuse = ticks;
  release(&bcache.lks[id]);
}

/** 版本0 */
// void
// bpin(struct buf *b) {
//   acquire(&bcache.lock);
//   b->refcnt++;
//   release(&bcache.lock);
// }

/** 版本1 */
void
bpin(struct buf *b) 
{
  int id = myhash(b->blockno);

  acquire(&bcache.lks[id]);
  b->refcnt++;
  release(&bcache.lks[id]);
}

/** 版本0 */
// void
// bunpin(struct buf *b) {
//   acquire(&bcache.lock);
//   b->refcnt--;
//   release(&bcache.lock);
// }

/** 版本1 */
void
bunpin(struct buf *b) 
{
  int id = myhash(b->blockno);

  acquire(&bcache.lks[id]);
  b->refcnt--;
  release(&bcache.lks[id]);
}


