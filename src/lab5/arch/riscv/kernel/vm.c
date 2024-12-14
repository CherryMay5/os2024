#include "vm.h"

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() 
{
    /* 
     * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表 
     * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/

    // 初始化页表
    memset(early_pgtbl, 0x0,PGSIZE);

    uint64_t PA,VA;
    // 第一次等值映射
    PA = PHY_START;
    VA = PA;
    // 取index
    uint64_t VPN = (VA >> 30) & 0x1ff;          // 9bit
    uint64_t PPN = (PA >> 30) & 0x3ffffff;      // 26bit
    early_pgtbl[VPN] = (PPN << 28) | 0b1111;    // 9+9+10 设置权限位1111

    // 第二次等值映射
    VA = VM_START;
    VPN = (VA >> 30) & 0x1ff;                   // 9bit
    early_pgtbl[VPN] = (PPN << 28) | 0b1111;    // 设置权限为1111
    
    // no等值映射
    // uint64_t PA,VA;
    // PA = PHY_START;
    // VA = VM_START;
    // // 取index
    // uint64_t VPN = (VA >> 30) & 0x1ff;//9bit
    // uint64_t PPN = (PA >> 30) & 0x3ffffff;//26bit
    // early_pgtbl[VPN] = (PPN << 28) | 0b1111;//设置权限为1111
    printk("...setup_vm done!\n");
}


/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern char _stext[];
extern char _srodata[];
extern char _sdata[];
extern char _edata[];
extern char _erodata[];
extern char _etext[];

// 完成对所有物理内存 (128M) 的映射，并设置正确的权限
void setup_vm_final() 
{
    
    memset(swapper_pg_dir, 0x0, PGSIZE);

    // No OpenSBI mapping required
    uint64_t V = VM_START+OPENSBI_SIZE;
    uint64_t P = PHY_START+OPENSBI_SIZE;
    
    // mapping kernel text X|-|R|V
    uint64_t size=(uint64_t)_srodata-(uint64_t)_stext;
    create_mapping(swapper_pg_dir,V,P,size,PERM_KERNEL_TEXT);
    
    // mapping kernel rodata -|-|R|V
    uint64_t size1=(uint64_t)_sdata-(uint64_t)_srodata;
    create_mapping(swapper_pg_dir,V+size,P+size,size1,PERM_KERNEL_RODATA);
    
    // mapping other memory -|W|R|V
    uint64_t size2=PHY_SIZE-((uint64_t)_sdata-(uint64_t)_stext)-OPENSBI_SIZE;
    create_mapping(swapper_pg_dir,V+size+size1,P+size+size1,size2,PERM_KERNEL_DATA);

    // set satp with swapper_pg_dir
    // YOUR CODE HERE
    // 设置 satp 寄存器，启用分页
    uint64_t satp_value = ((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12;
    satp_value |= (8UL << 60); // Sv39 模式
    csr_write(satp, satp_value);
    
    // flush TLB
    asm volatile("sfence.vma zero, zero");

    // flush icache
    // asm volatile("fence.i");

    printk("...setup_vm_final done!\n");

    return;
}


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) 
{
    /*
     * pgtbl 为根页表的基地址
     * va, pa 为需要映射的虚拟地址、物理地址
     * sz 为映射的大小，单位为字节
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    
    uint64_t offset = 0; 

    while(offset < sz)
    {
        uint64_t va_current = va + offset;
        uint64_t pa_current = pa + offset;
        uint64_t *pg_now = pgtbl;
        uint64_t VPN[3] = {
            (va_current >> 12) & 0x1ff, // VPN[0]
            (va_current >> 21) & 0x1ff, // VPN[1]
            (va_current >> 30) & 0x1ff  // VPN[2]
        };

        // 处理三级页表 (Sv39)
        for (int level = 2; level > 0; level--) 
        {
            uint64_t PTE = pg_now[VPN[level]];
            if ((PTE & 1) == 0) 
            { // 如果页表项无效
                uint64_t *new_pg = (uint64_t *)kalloc(); // 分配一页
                // 计算新的页表物理地址，设置有效位
                PTE = (((uint64_t)new_pg - PA2VA_OFFSET) >> 12) << 10 | 1;
                pg_now[VPN[level]] = PTE; // 更新页表项
            }

            // 通过当前 PTE 获取下一层页表的地址
            pg_now = (uint64_t *)(((PTE >> 10) << 12) + PA2VA_OFFSET);
        }

        // 处理一级页表
        pg_now[VPN[0]] = ((pa_current >> 12) << 10) | perm; // 设置物理地址和权限

        offset += PGSIZE;
    }

    printk(BLUE"[vm.c,create_mapping] --- [%lx, %lx) -> [%lx, %lx), perm: %lx\n"CLEAR,pa,pa+sz,va,va+sz,perm);
}