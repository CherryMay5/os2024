#include "fs.h"
#include "vfs.h"
#include "sbi.h"
#include "defs.h"
#include "printk.h"

char uart_getchar() {
    char ret;
    while (1) {
        struct sbiret sbi_result = sbi_debug_console_read(1, ((uint64_t)&ret - PA2VA_OFFSET), 0);
        if (sbi_result.error == 0 && sbi_result.value == 1) {
            break;
        }
    }
    return ret;
}

int64_t stdin_read(struct file *file, void *buf, uint64_t len) {
    // todo: use uart_getchar() to get `len` chars
    char *buffer = (char *)buf;  // 将 void* 转为 char*，方便操作
    for (uint64_t i = 0; i < len; i++) {
        buffer[i] = uart_getchar();  // 使用 uart_getchar 获取字符
    }
    return len;  // 返回读取的字符数
}

int64_t stdout_write(struct file *file, const void *buf, uint64_t len) {
    char to_print[len + 1];
    for (int i = 0; i < len; i++) {
        to_print[i] = ((const char *)buf)[i];
    }
    to_print[len] = 0;
    return printk(to_print);
}

int64_t stderr_write(struct file *file, const void *buf, uint64_t len) {
    // todo
    char to_print[len + 1];
    for (int i = 0; i < len; i++) {
        to_print[i] = ((const char *)buf)[i];
    }
    to_print[len] = 0;
    
    // 添加前缀以区分 stderr 输出
    printk("[stderr] %s", to_print);
    return len;  // 返回成功写入的字节数
}
