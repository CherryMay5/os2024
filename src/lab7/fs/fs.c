#include "fs.h"
#include "vfs.h"
#include "mm.h"
#include "string.h"
#include "printk.h"
#include "fat32.h"

#include <stddef.h>

// 自定义 memcmp 实现
int memcmp(const void *s1, const void *s2, size_t n) {
    const unsigned char *p1 = (const unsigned char *)s1;
    const unsigned char *p2 = (const unsigned char *)s2;

    for (size_t i = 0; i < n; i++) {
        if (p1[i] != p2[i]) {
            return p1[i] - p2[i];
        }
    }
    return 0;
}

// 自定义 strlen 实现
size_t strlen(const char *s) {
    size_t len = 0;
    while (s[len] != '\0') {
        len++;
    }
    return len;
}


struct files_struct *file_init() {
    // todo: alloc pages for files_struct, and initialize stdin, stdout, stderr
    // 根据files_struct的大小分配页空间；
    struct files_struct *ret = (struct files_struct *)alloc_page();
    if(!ret)
    {
        return NULL;    // 分配失败
    }

    // 为stdin、stdout、stderr赋值
    // 初始化stdin
    ret->fd_array[0].opened = 1;
    ret->fd_array[0].perms = FILE_READABLE;
    ret->fd_array[0].cfo = 0;
    // ret->fd_array[0].fs_type = FS_TYPE_STDIN;
    ret->fd_array[0].lseek = NULL;
    ret->fd_array[0].write = NULL;
    ret->fd_array[0].read = stdin_read;
    memcpy(ret->fd_array[0].path , "stdin",6);

    // 初始化stdout
    ret->fd_array[1].opened = 1;
    ret->fd_array[1].perms = FILE_WRITABLE;
    ret->fd_array[1].cfo = 0;
    // ret->fd_array[1].fs_type = FS_TYPE_STDOUT;
    ret->fd_array[1].lseek = NULL;
    ret->fd_array[1].write = stdout_write;
    ret->fd_array[1].read = NULL;
    memcpy(ret->fd_array[1].path , "stdout",7);

    // 初始化stderr
    ret->fd_array[2].opened = 1;
    ret->fd_array[2].perms = FILE_WRITABLE;
    ret->fd_array[2].cfo = 0;
    // ret->fd_array[2].fs_type = FS_TYPE_STDERR;
    ret->fd_array[2].lseek = NULL;
    ret->fd_array[2].write = stderr_write;
    ret->fd_array[2].read = NULL;
    memcpy(ret->fd_array[2].path , "stderr",7);

    // 初始化文件数组,保证其他未使用的文件的opened字段为0
    for(int i = 3; i < MAX_FILE_NUMBER; i++)
    {
        ret->fd_array[i].opened = 0;
        ret->fd_array[i].perms = 0;
        ret->fd_array[i].cfo = 0;
        ret->fd_array[i].lseek = NULL;
        ret->fd_array[i].write = NULL;
        ret->fd_array[i].read = NULL;
        memset(ret->fd_array[i].path,0,MAX_PATH_LENGTH);
    }
    
    return ret;
}

uint32_t get_fs_type(const char *filename) {
    uint32_t ret;
    if (memcmp(filename, "/fat32/", 7) == 0) {
        ret = FS_TYPE_FAT32;
    } else if (memcmp(filename, "/ext2/", 6) == 0) {
        ret = FS_TYPE_EXT2;
    } else {
        ret = -1;
    }
    return ret;
}

int32_t file_open(struct file* file, const char* path, int flags) {
    file->opened = 1;
    file->perms = flags;
    file->cfo = 0;
    file->fs_type = get_fs_type(path);
    memcpy(file->path, path, strlen(path) + 1);

    if (file->fs_type == FS_TYPE_FAT32) {
        file->lseek = fat32_lseek;
        file->write = fat32_write;
        file->read = fat32_read;
        file->fat32_file = fat32_open_file(path);
        // todo: check if fat32_file is valid (i.e. successfully opened) and return
    } else if (file->fs_type == FS_TYPE_EXT2) {
        printk(RED "Unsupport ext2\n" CLEAR);
        return -1;
    } else {
        printk(RED "Unknown fs type: %s\n" CLEAR, path);
        return -1;
    }
}