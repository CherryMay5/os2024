#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    struct sbiret result;   //用 sbiret 来接受两个返回值
    
    __asm__ volatile ( 
        "mv a7, %[eid]\n"   //将 eid（Extension ID）放入寄存器 a7 中
        "mv a6, %[fid]\n"   //fid（Function ID）放入寄存器 a6 中
        "mv a5, %[arg5]\n"  //将 arg[0-5] 放入寄存器 a[0-5] 中
        "mv a4, %[arg4]\n"
        "mv a3, %[arg3]\n"
        "mv a2, %[arg2]\n"
        "mv a1, %[arg1]\n"
        "mv a0, %[arg0]\n"
        "ecall\n"           //使用 ecall 指令
        //OpenSBI 的返回结果会存放在寄存器 a0，a1 中
        "mv %[error], a0\n" //a0 为 error code
        "mv %[value], a1\n" //a1 为返回值
        
        :[error]"=r"(result.error),[value]"=r"(result.value)
        :[eid]"r"(eid),[fid]"r"(fid),[arg5]"r"(arg5),[arg4]"r"(arg4),[arg3]"r"(arg3),[arg2]"r"(arg2),[arg1]"r"(arg1),[arg0]"r"(arg0)
        :"a0","a1","a2","a3","a4","a5","a6","a7"
    );

    return result;
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    struct sbiret result=sbi_ecall(SBI_EID_DEBUG_CONSOLE_WRITE_BYTE,SBI_FID_DEBUG_CONSOLE_WRITE_BYTE,byte,0,0,0,0,0);
    return result;
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    struct sbiret result=sbi_ecall(SBI_EID_RESET_TYPE_SHUTDOWN,SBI_SRST_RESET_REASON_NONE,reset_type,reset_reason,0,0,0,0);
    return result;
}

struct sbiret sbi_set_timer(uint64_t stime_value)
{
    unsigned long time_final;
    __asm__ volatile(
        "rdtime t0 \n"      // 使用 rdtime 命令，将time寄存器的值读入 t0
        "li t1,10000000 \n" // 10000000个时钟周期相当于 1s
        "add t0,t0,t1 \n"
        "mv %[time_final],t0 \n"
        : [time_final]"=r"(time_final)
    );

    struct sbiret result=sbi_ecall(SBI_EID_SET_TIMER,SBI_FID_SET_TIMER,time_final,0,0,0,0,0);
    //struct sbiret result=sbi_ecall(SBI_EID_SET_TIMER,SBI_FID_SET_TIMER,stime_value,0,0,0,0,0);
    return result;
}