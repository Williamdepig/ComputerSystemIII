//arch/riscv/kernel/proc.c
#include "proc.h"
#include "printk.h"
#include "rand.h"
#include "defs.h"
#include "mm.h"

extern void __dummy();
extern void __switch_to(struct task_struct* prev, struct task_struct* next);

struct task_struct* idle;           // idle process
struct task_struct* current;        // 指向当前运行线程的 `task_struct`
struct task_struct* task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init(){
    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
    // 3. 由于 idle 不参与调度 可以将其 counter / priority 设置为 0
    idle->counter = 0;
    idle->priority = 0;
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
    task[0] = idle;
    /* YOUR CODE HERE */

    // 1. 参考 idle 的设置, 为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, counter 为 0, priority 使用 rand() 来设置, pid 为该线程在线程数组中的下标。
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 `thread_struct` 中的 `ra` 和 `sp`, 
    // 4. 其中 `ra` 设置为 __dummy （见 4.3.2）的地址， `sp` 设置为 该线程申请的物理页的高地址
    for(int i = 1; i < NR_TASKS; i++){
        struct task_struct* task_i = (struct task_struct*)kalloc();
        task_i->state = TASK_RUNNING;
        task_i->counter = 0;
        task_i->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
        task_i->pid = i;
        task_i->thread.ra = (uint64)__dummy;
        task_i->thread.sp = (uint64)task_i + PGSIZE;
        task[i] = task_i;
    }
    /* YOUR CODE HERE */

    Log("...proc_init done!\n");
    // printk("proc\n");
    return;
}

void dummy()
{
    uint64 MOD = 1000000007;
    uint64 auto_inc_local_var = 0;
    int last_counter = -1; // 记录上一个counter
    int last_last_counter = -1; // 记录上上个counter
    while(1){
        if (last_counter == -1 || current->counter != last_counter){
            last_last_counter = last_counter;
            last_counter = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            printk("[PID = %d] is running. auto_inc_local_var = %d. Thread space begin at %lx \n", current->pid, auto_inc_local_var, current); 
            // printk("%d is running. var = %d\n", current->pid, auto_inc_local_var);
        } 
        else if((last_last_counter == 0 || last_last_counter == -1) && last_counter == 1){ // counter恒为1的情况
            // 这里比较 tricky，不要求理解。
            last_counter = 0; 
            current->counter = 0;
        }
    }
}

void switch_to(struct task_struct* next) 
{
    /* YOUR CODE HERE */
    if(next != current){
        printk("switch to [PID = %d, PRIORITY = %d, COUNTER = %d]\n", next->pid, next->priority, next->counter);
        // printk("switch to %d\n", next->pid);
        struct task_struct* previous = current;
        current = next;
        __switch_to(previous, next);
    }
}

void do_timer(void) 
{
    /* 1. 将当前进程的counter--，如果结果大于零则直接返回*/
    /* 2. 否则进行进程调度 */
    if(current == idle || current->counter == 0){
        schedule();
    }
    else{
        current->counter--;
        if(!current->counter) schedule();
    }
    /* YOUR CODE HERE */
}

void schedule(void) 
{
    /* YOUR CODE HERE */
    struct task_struct* next = idle;
    while(1){
        uint64 counter_min = UINT64_MAX;
        for(int i = 1; i < NR_TASKS; i++){
            if(task[i]->state == TASK_RUNNING){
                if(task[i]->counter && task[i]->counter < counter_min){
                    counter_min = task[i]->counter;
                    next = task[i];
                }
            }
        }
        if(next != idle) break;
        for(int i = 1; i < NR_TASKS; i++){
            task[i]->counter = task[i]->priority;
            printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
        }
    }
    switch_to(next);
}