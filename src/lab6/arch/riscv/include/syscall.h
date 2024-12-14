#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "stdint.h"
#include "stddef.h"
#include "printk.h"
#include "proc.h"

#define SYS_WRITE 64
#define SYS_GETPID 172
#define SYS_CLONE 220

extern struct task_struct *current;

struct pt_regs
{
    uint64_t x[32];     //x0-x31    x10-a0  x17-a7
    uint64_t sepc;      //sepc
    uint64_t sstatus;   //sstatus
    uint64_t stval;     //stval
};

void sys_write(unsigned int fd, const char* buf, size_t count, struct pt_regs *regs);
void sys_getpid(struct pt_regs *regs);

uint64_t do_fork(struct pt_regs *regs);

#endif

