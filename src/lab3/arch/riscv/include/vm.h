#ifndef __VM_H__
#define __VM_H__

#include "stdint.h"
#include "string.h"
#include "printk.h"
#include "defs.h"
#include "mm.h"

void setup_vm();
void setup_vm_final();
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm);

// 权限掩码
#define PERM_KERNEL_TEXT 0b1011 // X|R|V
#define PERM_KERNEL_RODATA 0b0011 // R|V
#define PERM_KERNEL_DATA 0b0111 // W|R|V

#endif