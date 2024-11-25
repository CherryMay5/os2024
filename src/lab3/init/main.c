#include "printk.h"
#include "stdint.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk("2024");
    printk(" ZJU Operating System\n");

    // lab 1 test output
    // 用 csr_read 宏读取 sstatus 寄存器的值
    // uint64_t sstatus_val1 = csr_read(sstatus);
    // printk("sstatus: %lx\n", sstatus_val1);

    // 用 csr_write 宏向 sscratch 寄存器写入数据
    // csr_write(sscratch, 0x12345678);
    // uint64_t sstatus_val2 = csr_read(sscratch);
    // printk("sscratch: %lx\n", sstatus_val2);


    // lab 3 test output
    extern char _stext[];
    extern char _srodata[];

    // asm volatile("jal _srodata");    //test X

    printk("stext: %x\n", *_stext);     //test R
    printk("srodata: %x\n", *_srodata); //test R
    // *_stext=0;
    // *_srodata=0;
    // printk("stext: %x\n", *_stext);  //test W
    // printk("srodata: %x\n", *_srodata);  //test W

    test();
    return 0;
}
