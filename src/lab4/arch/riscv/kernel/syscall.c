#include "syscall.h"

// 将用户态传递的字符串打印到屏幕上
// fd 为标准输出即 1，buf 为用户需要打印的起始地址，count 为字符串长度，返回打印的字符数；
void sys_write(unsigned int fd, const char* buf, size_t count, struct pt_regs *regs)  
{
    if(fd == 1)
    {
        uint64_t result;
        for(size_t i=0;i<count;i++)
        {
            printk("%c", buf[i]);
            result++;
        }
        regs->x[10] = result;
    }
}

// 从 current 中获取当前的 pid 放入 a0 中返回，无参数
void sys_getpid(struct pt_regs *regs)   
{
    regs->x[10] = current->pid;
}