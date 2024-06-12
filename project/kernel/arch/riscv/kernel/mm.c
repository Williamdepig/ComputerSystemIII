#include "defs.h"
#include "string.h"
#include "mm.h"

#include "kio.h"

extern uint8_t _ekernel[];

// fine, write buddy system here

#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) (((index) + 1) / 2 - 1)

#define IS_POWER_OF_2(x) (!((x) & ((x) - 1)))

#define __MAX(a, b)       \
  ({                    \
    typeof(a) _a = (a); \
    typeof(b) _b = (b); \
    _a > _b ? _a : _b;  \
  })

struct buddy {
  uint64_t size;
  uint64_t *bitmap;
  uint64_t *ref_cnt;
};

static void *free_page_start = &_ekernel;
static struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
  size--;
  size |= size >> 1;
  size |= size >> 2;
  size |= size >> 4;
  size |= size >> 8;
  size |= size >> 16;
  size |= size >> 32;
  return size + 1;
}

void buddy_free(uint64_t pfn) {
  // if ref_cnt is not zero, do nothing
  if (buddy.ref_cnt[pfn]) {
    return;
  }

  uint64_t node_size, index = 0;
  uint64_t left_longest, right_longest;

  node_size = 1;
  index = pfn + buddy.size - 1;

  for (; buddy.bitmap[index]; index = PARENT(index)) {
    node_size *= 2;
    if (index == 0)
      break;
  }

  buddy.bitmap[index] = node_size;

  while (index) {
    index = PARENT(index);
    node_size *= 2;

    left_longest = buddy.bitmap[LEFT_LEAF(index)];
    right_longest = buddy.bitmap[RIGHT_LEAF(index)];

    if (left_longest + right_longest == node_size)
      buddy.bitmap[index] = node_size;
    else
      buddy.bitmap[index] = __MAX(left_longest, right_longest);
  }
}

void page_ref_inc(uint64_t pfn) {
  buddy.ref_cnt[pfn]++;
}

void page_ref_dec(uint64_t pfn) {
  if (buddy.ref_cnt[pfn] > 0 && --buddy.ref_cnt[pfn] == 0) {
    buddy_free(pfn);
  }
}

uint64_t buddy_alloc(uint64_t nrpages) {
  uint64_t index = 0;
  uint64_t node_size;
  uint64_t pfn = 0;

  if (nrpages == 0)
    nrpages = 1;
  else if (!IS_POWER_OF_2(nrpages))
    nrpages = fixsize(nrpages);

  if (buddy.bitmap[index] < nrpages)
    return 0;

  for (node_size = buddy.size; node_size != nrpages; node_size /= 2) {
    if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
      index = LEFT_LEAF(index);
    else
      index = RIGHT_LEAF(index);
  }

  buddy.bitmap[index] = 0;
  pfn = (index + 1) * node_size - buddy.size;
  // set ref_cnt to 1
  buddy.ref_cnt[pfn] = 1;

  while (index) {
    index = PARENT(index);
    buddy.bitmap[index] = __MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
  }

  return pfn;
}

void buddy_init(void) {
  uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;

  if (!IS_POWER_OF_2(buddy_size))
    buddy_size = fixsize(buddy_size);

  buddy.size = buddy_size;
  buddy.bitmap = free_page_start;
  free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
  memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
  // alloc space for ref_cnt
  buddy.ref_cnt = free_page_start;
  free_page_start += buddy.size * sizeof(*buddy.ref_cnt);
  memset(buddy.ref_cnt, 0, buddy.size * sizeof(*buddy.ref_cnt));

  uint64_t node_size = buddy.size * 2;
  for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
    if (IS_POWER_OF_2(i + 1))
      node_size /= 2;
    buddy.bitmap[i] = node_size;
  }

  for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); pfn++) {
    buddy_alloc(1);
  }

  sys_puts("...buddy_init done!");
  return;
}

uint64_t alloc_pages(uint64_t nrpages) {
  uint64_t pfn = buddy_alloc(nrpages);
  if (pfn == 0) {
    return 0;
  }
  return PA2VA(PFN2PHYS(pfn));
}

uint64_t alloc_page(void) {
  return alloc_pages(1);
}

void free_pages(uint64_t va) {
  buddy_free(PHYS2PFN(VA2PA(va)));
}

uint64_t get_page(uint64_t va) {
  uint64_t pfn = PHYS2PFN(VA2PA(va));
  // check if the page is already allocated
  if (buddy.ref_cnt[pfn] == 0) {
    return 1;
  }
  page_ref_inc(pfn);
  return 0;
}

void put_page(uint64_t va) {
  uint64_t pfn = PHYS2PFN(VA2PA(va));
  page_ref_dec(pfn);
}

void mm_init(void) __attribute__((alias("buddy_init")));
uint64_t kalloc(void) __attribute__((alias("alloc_page")));
void kfree(uint64_t) __attribute__((alias("free_pages")));
