
../../vmlinux：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
.extern start_kernel
.extern _srodata
  .section .text.init
  .globl _start
_start:
  la sp, stack_top
ffffffe000200000:	00004117          	auipc	sp,0x4
ffffffe000200004:	04813103          	ld	sp,72(sp) # ffffffe000204048 <_GLOBAL_OFFSET_TABLE_+0x38>
  li t0, 0xffffffdf80000000
ffffffe000200008:	fbf0029b          	addiw	t0,zero,-65
ffffffe00020000c:	01f29293          	slli	t0,t0,0x1f
  sub sp, sp, t0
ffffffe000200010:	40510133          	sub	sp,sp,t0

  call setup_vm
ffffffe000200014:	389000ef          	jal	ra,ffffffe000200b9c <setup_vm>
  call relocate
ffffffe000200018:	040000ef          	jal	ra,ffffffe000200058 <relocate>

  call mm_init
ffffffe00020001c:	3f0000ef          	jal	ra,ffffffe00020040c <mm_init>
  call setup_vm_final
ffffffe000200020:	419000ef          	jal	ra,ffffffe000200c38 <setup_vm_final>
  call task_init
ffffffe000200024:	440000ef          	jal	ra,ffffffe000200464 <task_init>

  la a0, _traps
ffffffe000200028:	00004517          	auipc	a0,0x4
ffffffe00020002c:	03853503          	ld	a0,56(a0) # ffffffe000204060 <_GLOBAL_OFFSET_TABLE_+0x50>
  csrw stvec, a0
ffffffe000200030:	10551073          	csrw	stvec,a0

  li a0, 32  #0b100000
ffffffe000200034:	02000513          	li	a0,32
  csrs sie, a0
ffffffe000200038:	10452073          	csrs	sie,a0
  # xor a5, a5, a5
  # xor a6, a6, a6
  # xor a7, a7, a7
  # ecall

  rdtime a0
ffffffe00020003c:	c0102573          	rdtime	a0
  li t0, 0x30000
ffffffe000200040:	000302b7          	lui	t0,0x30
  add a0, a0, t0
ffffffe000200044:	00550533          	add	a0,a0,t0
  call sbi_set_timer
ffffffe000200048:	285000ef          	jal	ra,ffffffe000200acc <sbi_set_timer>

  li a0, 2
ffffffe00020004c:	00200513          	li	a0,2
  csrs sstatus, a0
ffffffe000200050:	10052073          	csrs	sstatus,a0
  # jal _srodata
  jal start_kernel
ffffffe000200054:	004010ef          	jal	ra,ffffffe000201058 <start_kernel>

ffffffe000200058 <relocate>:

relocate:
  li t0, 0xffffffdf80000000 # PA2VA_OFFSET
ffffffe000200058:	fbf0029b          	addiw	t0,zero,-65
ffffffe00020005c:	01f29293          	slli	t0,t0,0x1f
  add ra, ra, t0
ffffffe000200060:	005080b3          	add	ra,ra,t0
  add sp, sp, t0
ffffffe000200064:	00510133          	add	sp,sp,t0

  la t0, _after_satp
ffffffe000200068:	00004297          	auipc	t0,0x4
ffffffe00020006c:	fb02b283          	ld	t0,-80(t0) # ffffffe000204018 <_GLOBAL_OFFSET_TABLE_+0x8>
  csrw stvec, t0
ffffffe000200070:	10529073          	csrw	stvec,t0


  # set satp with early_pgtbl‘s physical address

  la t0, early_pgtbl
ffffffe000200074:	00004297          	auipc	t0,0x4
ffffffe000200078:	fcc2b283          	ld	t0,-52(t0) # ffffffe000204040 <_GLOBAL_OFFSET_TABLE_+0x30>
  li t1, 0xffffffdf80000000
ffffffe00020007c:	fbf0031b          	addiw	t1,zero,-65
ffffffe000200080:	01f31313          	slli	t1,t1,0x1f
  sub t0, t0, t1
ffffffe000200084:	406282b3          	sub	t0,t0,t1
  li t1, 8
ffffffe000200088:	00800313          	li	t1,8
  slli t1, t1, 60     # mode 部分设置为 8
ffffffe00020008c:	03c31313          	slli	t1,t1,0x3c
  srli t0, t0, 12     # PPN 部分设置为页表物理地址右移 12 位
ffffffe000200090:	00c2d293          	srli	t0,t0,0xc
  or t0, t0, t1
ffffffe000200094:	0062e2b3          	or	t0,t0,t1
  csrw satp, t0
ffffffe000200098:	18029073          	csrw	satp,t0

ffffffe00020009c <_after_satp>:

  # flush tlb
_after_satp:
  sfence.vma zero, zero
ffffffe00020009c:	12000073          	sfence.vma
  fence.i
ffffffe0002000a0:	0000100f          	fence.i

  ret
ffffffe0002000a4:	00008067          	ret

ffffffe0002000a8 <_traps>:
    .globl __switch_to
_traps:
    # YOUR CODE HERE
    # -----------
        # 1. save 32 registers and sepc to stack
        sd sp, -8(sp)
ffffffe0002000a8:	fe213c23          	sd	sp,-8(sp)
        sd ra, -16(sp)
ffffffe0002000ac:	fe113823          	sd	ra,-16(sp)
        sd gp, -24(sp)
ffffffe0002000b0:	fe313423          	sd	gp,-24(sp)
        sd tp, -32(sp)
ffffffe0002000b4:	fe413023          	sd	tp,-32(sp)
        sd t0, -40(sp)
ffffffe0002000b8:	fc513c23          	sd	t0,-40(sp)
        sd t1, -48(sp)
ffffffe0002000bc:	fc613823          	sd	t1,-48(sp)
        sd t2, -56(sp)
ffffffe0002000c0:	fc713423          	sd	t2,-56(sp)
        sd fp, -64(sp)
ffffffe0002000c4:	fc813023          	sd	s0,-64(sp)
        sd s1, -72(sp)
ffffffe0002000c8:	fa913c23          	sd	s1,-72(sp)
        sd a0, -80(sp)
ffffffe0002000cc:	faa13823          	sd	a0,-80(sp)
        sd a1, -88(sp)
ffffffe0002000d0:	fab13423          	sd	a1,-88(sp)
        sd a2, -96(sp)
ffffffe0002000d4:	fac13023          	sd	a2,-96(sp)
        sd a3, -104(sp)
ffffffe0002000d8:	f8d13c23          	sd	a3,-104(sp)
        sd a4, -112(sp)
ffffffe0002000dc:	f8e13823          	sd	a4,-112(sp)
        sd a5, -120(sp)
ffffffe0002000e0:	f8f13423          	sd	a5,-120(sp)
        sd a6, -128(sp)
ffffffe0002000e4:	f9013023          	sd	a6,-128(sp)
        sd a7, -136(sp)
ffffffe0002000e8:	f7113c23          	sd	a7,-136(sp)
        sd s2, -144(sp)
ffffffe0002000ec:	f7213823          	sd	s2,-144(sp)
        sd s3, -152(sp)
ffffffe0002000f0:	f7313423          	sd	s3,-152(sp)
        sd s4, -160(sp)
ffffffe0002000f4:	f7413023          	sd	s4,-160(sp)
        sd s5, -168(sp)
ffffffe0002000f8:	f5513c23          	sd	s5,-168(sp)
        sd s6, -176(sp)
ffffffe0002000fc:	f5613823          	sd	s6,-176(sp)
        sd s7, -184(sp)
ffffffe000200100:	f5713423          	sd	s7,-184(sp)
        sd s8, -192(sp)
ffffffe000200104:	f5813023          	sd	s8,-192(sp)
        sd s9, -200(sp)
ffffffe000200108:	f3913c23          	sd	s9,-200(sp)
        sd s10, -208(sp)
ffffffe00020010c:	f3a13823          	sd	s10,-208(sp)
        sd s11, -216(sp)
ffffffe000200110:	f3b13423          	sd	s11,-216(sp)
        sd t3, -224(sp)
ffffffe000200114:	f3c13023          	sd	t3,-224(sp)
        sd t4, -232(sp)
ffffffe000200118:	f1d13c23          	sd	t4,-232(sp)
        sd t5, -240(sp)
ffffffe00020011c:	f1e13823          	sd	t5,-240(sp)
        sd t6, -248(sp)
ffffffe000200120:	f1f13423          	sd	t6,-248(sp)
        addi sp, sp, -248
ffffffe000200124:	f0810113          	addi	sp,sp,-248
    # -----------
        # 2. call trap_handler
        csrr a0, scause
ffffffe000200128:	14202573          	csrr	a0,scause
        csrr a1, sepc
ffffffe00020012c:	141025f3          	csrr	a1,sepc
        call trap_handler
ffffffe000200130:	1e9000ef          	jal	ra,ffffffe000200b18 <trap_handler>
    # -----------
        # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
        csrr t0, sepc
ffffffe000200134:	141022f3          	csrr	t0,sepc

        # temporarily add 4 to sepc manually
        li t1, 0x8000000000000005
ffffffe000200138:	fff0031b          	addiw	t1,zero,-1
ffffffe00020013c:	03f31313          	slli	t1,t1,0x3f
ffffffe000200140:	00530313          	addi	t1,t1,5
        csrr a0, scause
ffffffe000200144:	14202573          	csrr	a0,scause
        beq a0, t1, _restore
ffffffe000200148:	00650663          	beq	a0,t1,ffffffe000200154 <_restore>
        addi t0, t0, 4
ffffffe00020014c:	00428293          	addi	t0,t0,4
        csrw sepc, t0
ffffffe000200150:	14129073          	csrw	sepc,t0

ffffffe000200154 <_restore>:
_restore:
        
        ld t6, 0(sp)
ffffffe000200154:	00013f83          	ld	t6,0(sp)
        ld t5, 8(sp)
ffffffe000200158:	00813f03          	ld	t5,8(sp)
        ld t4, 16(sp)
ffffffe00020015c:	01013e83          	ld	t4,16(sp)
        ld t3, 24(sp)
ffffffe000200160:	01813e03          	ld	t3,24(sp)
        ld s11, 32(sp)
ffffffe000200164:	02013d83          	ld	s11,32(sp)
        ld s10, 40(sp)
ffffffe000200168:	02813d03          	ld	s10,40(sp)
        ld s9, 48(sp)
ffffffe00020016c:	03013c83          	ld	s9,48(sp)
        ld s8, 56(sp)
ffffffe000200170:	03813c03          	ld	s8,56(sp)
        ld s7, 64(sp)
ffffffe000200174:	04013b83          	ld	s7,64(sp)
        ld s6, 72(sp)
ffffffe000200178:	04813b03          	ld	s6,72(sp)
        ld s5, 80(sp)
ffffffe00020017c:	05013a83          	ld	s5,80(sp)
        ld s4, 88(sp)
ffffffe000200180:	05813a03          	ld	s4,88(sp)
        ld s3, 96(sp)
ffffffe000200184:	06013983          	ld	s3,96(sp)
        ld s2, 104(sp)
ffffffe000200188:	06813903          	ld	s2,104(sp)
        ld a7, 112(sp)
ffffffe00020018c:	07013883          	ld	a7,112(sp)
        ld a6, 120(sp)
ffffffe000200190:	07813803          	ld	a6,120(sp)
        ld a5, 128(sp)
ffffffe000200194:	08013783          	ld	a5,128(sp)
        ld a4, 136(sp)
ffffffe000200198:	08813703          	ld	a4,136(sp)
        ld a3, 144(sp)
ffffffe00020019c:	09013683          	ld	a3,144(sp)
        ld a2, 152(sp)
ffffffe0002001a0:	09813603          	ld	a2,152(sp)
        ld a1, 160(sp)
ffffffe0002001a4:	0a013583          	ld	a1,160(sp)
        ld a0, 168(sp)
ffffffe0002001a8:	0a813503          	ld	a0,168(sp)
        ld s1, 176(sp)
ffffffe0002001ac:	0b013483          	ld	s1,176(sp)
        ld fp, 184(sp)
ffffffe0002001b0:	0b813403          	ld	s0,184(sp)
        ld t2, 192(sp)
ffffffe0002001b4:	0c013383          	ld	t2,192(sp)
        ld t1, 200(sp)
ffffffe0002001b8:	0c813303          	ld	t1,200(sp)
        ld t0, 208(sp)
ffffffe0002001bc:	0d013283          	ld	t0,208(sp)
        ld tp, 216(sp)
ffffffe0002001c0:	0d813203          	ld	tp,216(sp)
        ld gp, 224(sp)
ffffffe0002001c4:	0e013183          	ld	gp,224(sp)
        ld ra, 232(sp)
ffffffe0002001c8:	0e813083          	ld	ra,232(sp)
        ld sp, 240(sp)
ffffffe0002001cc:	0f013103          	ld	sp,240(sp)
    # -----------
        # 4. return from trap
        sret
ffffffe0002001d0:	10200073          	sret

ffffffe0002001d4 <__dummy>:
    # -----------

__dummy:
    # YOUR CODE HERE
    la a0, dummy
ffffffe0002001d4:	00004517          	auipc	a0,0x4
ffffffe0002001d8:	e7c53503          	ld	a0,-388(a0) # ffffffe000204050 <_GLOBAL_OFFSET_TABLE_+0x40>
    csrw sepc, a0
ffffffe0002001dc:	14151073          	csrw	sepc,a0
    sret
ffffffe0002001e0:	10200073          	sret

ffffffe0002001e4 <__switch_to>:

__switch_to:
    # save state to prev process
    # a0 store the prev process address
    # YOUR CODE HERE
    sd ra, 40(a0)
ffffffe0002001e4:	02153423          	sd	ra,40(a0)
    sd sp, 48(a0)
ffffffe0002001e8:	02253823          	sd	sp,48(a0)
    sd s0, 56(a0)
ffffffe0002001ec:	02853c23          	sd	s0,56(a0)
    sd s1, 64(a0)
ffffffe0002001f0:	04953023          	sd	s1,64(a0)
    sd s2, 72(a0)
ffffffe0002001f4:	05253423          	sd	s2,72(a0)
    sd s3, 80(a0)
ffffffe0002001f8:	05353823          	sd	s3,80(a0)
    sd s4, 88(a0)
ffffffe0002001fc:	05453c23          	sd	s4,88(a0)
    sd s5, 96(a0)
ffffffe000200200:	07553023          	sd	s5,96(a0)
    sd s6, 104(a0)
ffffffe000200204:	07653423          	sd	s6,104(a0)
    sd s7, 112(a0)
ffffffe000200208:	07753823          	sd	s7,112(a0)
    sd s8, 120(a0)
ffffffe00020020c:	07853c23          	sd	s8,120(a0)
    sd s9, 128(a0)
ffffffe000200210:	09953023          	sd	s9,128(a0)
    sd s10, 136(a0)
ffffffe000200214:	09a53423          	sd	s10,136(a0)
    sd s11,144(a0)
ffffffe000200218:	09b53823          	sd	s11,144(a0)
    # restore state from next process
    # a1 store the next process address
    # YOUR CODE HERE
    ld ra,40(a1)
ffffffe00020021c:	0285b083          	ld	ra,40(a1)
    ld sp,48(a1)
ffffffe000200220:	0305b103          	ld	sp,48(a1)
    ld s0,56(a1)
ffffffe000200224:	0385b403          	ld	s0,56(a1)
    ld s1, 64(a1)
ffffffe000200228:	0405b483          	ld	s1,64(a1)
    ld s2, 72(a1)
ffffffe00020022c:	0485b903          	ld	s2,72(a1)
    ld s3, 80(a1)
ffffffe000200230:	0505b983          	ld	s3,80(a1)
    ld s4, 88(a1)
ffffffe000200234:	0585ba03          	ld	s4,88(a1)
    ld s5, 96(a1)
ffffffe000200238:	0605ba83          	ld	s5,96(a1)
    ld s6, 104(a1)
ffffffe00020023c:	0685bb03          	ld	s6,104(a1)
    ld s7, 112(a1)
ffffffe000200240:	0705bb83          	ld	s7,112(a1)
    ld s8, 120(a1)
ffffffe000200244:	0785bc03          	ld	s8,120(a1)
    ld s9, 128(a1)
ffffffe000200248:	0805bc83          	ld	s9,128(a1)
    ld s10, 136(a1)
ffffffe00020024c:	0885bd03          	ld	s10,136(a1)
    ld s11,144(a1)
ffffffe000200250:	0905bd83          	ld	s11,144(a1)

ffffffe000200254:	00008067          	ret

ffffffe000200258 <get_cycles>:

#include "sbi.h"
#include "clock.h"
unsigned long TIMECLOCK = 0x30000;

unsigned long get_cycles() {
ffffffe000200258:	fe010113          	addi	sp,sp,-32
ffffffe00020025c:	00813c23          	sd	s0,24(sp)
ffffffe000200260:	02010413          	addi	s0,sp,32
    unsigned long time;
    asm volatile (
ffffffe000200264:	c01027f3          	rdtime	a5
ffffffe000200268:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        : [time] "=r" (time)
        : : "memory"
    );
    return time;
ffffffe00020026c:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200270:	00078513          	mv	a0,a5
ffffffe000200274:	01813403          	ld	s0,24(sp)
ffffffe000200278:	02010113          	addi	sp,sp,32
ffffffe00020027c:	00008067          	ret

ffffffe000200280 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200280:	fe010113          	addi	sp,sp,-32
ffffffe000200284:	00113c23          	sd	ra,24(sp)
ffffffe000200288:	00813823          	sd	s0,16(sp)
ffffffe00020028c:	02010413          	addi	s0,sp,32
    unsigned long next_time = get_cycles() + TIMECLOCK;
ffffffe000200290:	fc9ff0ef          	jal	ra,ffffffe000200258 <get_cycles>
ffffffe000200294:	00050713          	mv	a4,a0
ffffffe000200298:	00004797          	auipc	a5,0x4
ffffffe00020029c:	d6878793          	addi	a5,a5,-664 # ffffffe000204000 <TIMECLOCK>
ffffffe0002002a0:	0007b783          	ld	a5,0(a5)
ffffffe0002002a4:	00f707b3          	add	a5,a4,a5
ffffffe0002002a8:	fef43423          	sd	a5,-24(s0)
    sbi_set_timer(next_time);
ffffffe0002002ac:	fe843503          	ld	a0,-24(s0)
ffffffe0002002b0:	01d000ef          	jal	ra,ffffffe000200acc <sbi_set_timer>
ffffffe0002002b4:	00000013          	nop
ffffffe0002002b8:	01813083          	ld	ra,24(sp)
ffffffe0002002bc:	01013403          	ld	s0,16(sp)
ffffffe0002002c0:	02010113          	addi	sp,sp,32
ffffffe0002002c4:	00008067          	ret

ffffffe0002002c8 <kalloc>:

struct {
    struct run *freelist;
} kmem;

uint64 kalloc() {
ffffffe0002002c8:	fe010113          	addi	sp,sp,-32
ffffffe0002002cc:	00113c23          	sd	ra,24(sp)
ffffffe0002002d0:	00813823          	sd	s0,16(sp)
ffffffe0002002d4:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
ffffffe0002002d8:	00005797          	auipc	a5,0x5
ffffffe0002002dc:	d2878793          	addi	a5,a5,-728 # ffffffe000205000 <kmem>
ffffffe0002002e0:	0007b783          	ld	a5,0(a5)
ffffffe0002002e4:	fef43423          	sd	a5,-24(s0)

    if(r != NULL){
ffffffe0002002e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002002ec:	00078e63          	beqz	a5,ffffffe000200308 <kalloc+0x40>
        kmem.freelist = r->next;
ffffffe0002002f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002002f4:	0007b703          	ld	a4,0(a5)
ffffffe0002002f8:	00005797          	auipc	a5,0x5
ffffffe0002002fc:	d0878793          	addi	a5,a5,-760 # ffffffe000205000 <kmem>
ffffffe000200300:	00e7b023          	sd	a4,0(a5)
ffffffe000200304:	0140006f          	j	ffffffe000200318 <kalloc+0x50>
    }else{
        printk("kalloc: out of memory\n");
ffffffe000200308:	00003517          	auipc	a0,0x3
ffffffe00020030c:	cf850513          	addi	a0,a0,-776 # ffffffe000203000 <_srodata>
ffffffe000200310:	56d010ef          	jal	ra,ffffffe00020207c <printk>
        while (1);
ffffffe000200314:	0000006f          	j	ffffffe000200314 <kalloc+0x4c>
    }
    // memset((void *)r, 0x0, PGSIZE);
    // 为了加快仿真速度，可以不执行清零步骤
    return (uint64) r;
ffffffe000200318:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020031c:	00078513          	mv	a0,a5
ffffffe000200320:	01813083          	ld	ra,24(sp)
ffffffe000200324:	01013403          	ld	s0,16(sp)
ffffffe000200328:	02010113          	addi	sp,sp,32
ffffffe00020032c:	00008067          	ret

ffffffe000200330 <kfree>:

void kfree(uint64 addr) {
ffffffe000200330:	fd010113          	addi	sp,sp,-48
ffffffe000200334:	02813423          	sd	s0,40(sp)
ffffffe000200338:	03010413          	addi	s0,sp,48
ffffffe00020033c:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    addr = addr & ~(PGSIZE - 1);
ffffffe000200340:	fd843703          	ld	a4,-40(s0)
ffffffe000200344:	fffff7b7          	lui	a5,0xfffff
ffffffe000200348:	00f777b3          	and	a5,a4,a5
ffffffe00020034c:	fcf43c23          	sd	a5,-40(s0)

    // memset((void *)addr, 0x0, (uint64)PGSIZE);

    r = (struct run *)addr;
ffffffe000200350:	fd843783          	ld	a5,-40(s0)
ffffffe000200354:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
ffffffe000200358:	00005797          	auipc	a5,0x5
ffffffe00020035c:	ca878793          	addi	a5,a5,-856 # ffffffe000205000 <kmem>
ffffffe000200360:	0007b703          	ld	a4,0(a5)
ffffffe000200364:	fe843783          	ld	a5,-24(s0)
ffffffe000200368:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
ffffffe00020036c:	00005797          	auipc	a5,0x5
ffffffe000200370:	c9478793          	addi	a5,a5,-876 # ffffffe000205000 <kmem>
ffffffe000200374:	fe843703          	ld	a4,-24(s0)
ffffffe000200378:	00e7b023          	sd	a4,0(a5)

    return ;
ffffffe00020037c:	00000013          	nop
}
ffffffe000200380:	02813403          	ld	s0,40(sp)
ffffffe000200384:	03010113          	addi	sp,sp,48
ffffffe000200388:	00008067          	ret

ffffffe00020038c <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe00020038c:	fd010113          	addi	sp,sp,-48
ffffffe000200390:	02113423          	sd	ra,40(sp)
ffffffe000200394:	02813023          	sd	s0,32(sp)
ffffffe000200398:	03010413          	addi	s0,sp,48
ffffffe00020039c:	fca43c23          	sd	a0,-40(s0)
ffffffe0002003a0:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uint64)start);
ffffffe0002003a4:	fd843703          	ld	a4,-40(s0)
ffffffe0002003a8:	000017b7          	lui	a5,0x1
ffffffe0002003ac:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0xffffffe0001ff001>
ffffffe0002003b0:	00f70733          	add	a4,a4,a5
ffffffe0002003b4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002003b8:	00f777b3          	and	a5,a4,a5
ffffffe0002003bc:	fef43423          	sd	a5,-24(s0)
    for (; (uint64)(addr) + PGSIZE <= (uint64)end; addr += PGSIZE) {
ffffffe0002003c0:	0200006f          	j	ffffffe0002003e0 <kfreerange+0x54>
        kfree((uint64)addr);
ffffffe0002003c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002003c8:	00078513          	mv	a0,a5
ffffffe0002003cc:	f65ff0ef          	jal	ra,ffffffe000200330 <kfree>
    for (; (uint64)(addr) + PGSIZE <= (uint64)end; addr += PGSIZE) {
ffffffe0002003d0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003d4:	000017b7          	lui	a5,0x1
ffffffe0002003d8:	00f707b3          	add	a5,a4,a5
ffffffe0002003dc:	fef43423          	sd	a5,-24(s0)
ffffffe0002003e0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003e4:	000017b7          	lui	a5,0x1
ffffffe0002003e8:	00f70733          	add	a4,a4,a5
ffffffe0002003ec:	fd043783          	ld	a5,-48(s0)
ffffffe0002003f0:	fce7fae3          	bgeu	a5,a4,ffffffe0002003c4 <kfreerange+0x38>
    }
}
ffffffe0002003f4:	00000013          	nop
ffffffe0002003f8:	00000013          	nop
ffffffe0002003fc:	02813083          	ld	ra,40(sp)
ffffffe000200400:	02013403          	ld	s0,32(sp)
ffffffe000200404:	03010113          	addi	sp,sp,48
ffffffe000200408:	00008067          	ret

ffffffe00020040c <mm_init>:

void mm_init(void) {
ffffffe00020040c:	ff010113          	addi	sp,sp,-16
ffffffe000200410:	00113423          	sd	ra,8(sp)
ffffffe000200414:	00813023          	sd	s0,0(sp)
ffffffe000200418:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END);
    // printk("...mm_init done!\n");
    kfreerange(_ekernel, (char *)(PHY_END+PA2VA_OFFSET));
ffffffe00020041c:	c0100793          	li	a5,-1023
ffffffe000200420:	01b79593          	slli	a1,a5,0x1b
ffffffe000200424:	00004517          	auipc	a0,0x4
ffffffe000200428:	bfc53503          	ld	a0,-1028(a0) # ffffffe000204020 <_GLOBAL_OFFSET_TABLE_+0x10>
ffffffe00020042c:	f61ff0ef          	jal	ra,ffffffe00020038c <kfreerange>
    Log("...mm_init done!");
ffffffe000200430:	00003697          	auipc	a3,0x3
ffffffe000200434:	c1868693          	addi	a3,a3,-1000 # ffffffe000203048 <__func__.0>
ffffffe000200438:	03700613          	li	a2,55
ffffffe00020043c:	00003597          	auipc	a1,0x3
ffffffe000200440:	bdc58593          	addi	a1,a1,-1060 # ffffffe000203018 <_srodata+0x18>
ffffffe000200444:	00003517          	auipc	a0,0x3
ffffffe000200448:	bdc50513          	addi	a0,a0,-1060 # ffffffe000203020 <_srodata+0x20>
ffffffe00020044c:	431010ef          	jal	ra,ffffffe00020207c <printk>
    return;
ffffffe000200450:	00000013          	nop
}
ffffffe000200454:	00813083          	ld	ra,8(sp)
ffffffe000200458:	00013403          	ld	s0,0(sp)
ffffffe00020045c:	01010113          	addi	sp,sp,16
ffffffe000200460:	00008067          	ret

ffffffe000200464 <task_init>:

struct task_struct* idle;           // idle process
struct task_struct* current;        // 指向当前运行线程的 `task_struct`
struct task_struct* task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init(){
ffffffe000200464:	fe010113          	addi	sp,sp,-32
ffffffe000200468:	00113c23          	sd	ra,24(sp)
ffffffe00020046c:	00813823          	sd	s0,16(sp)
ffffffe000200470:	02010413          	addi	s0,sp,32
    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
ffffffe000200474:	e55ff0ef          	jal	ra,ffffffe0002002c8 <kalloc>
ffffffe000200478:	00050793          	mv	a5,a0
ffffffe00020047c:	00078713          	mv	a4,a5
ffffffe000200480:	00005797          	auipc	a5,0x5
ffffffe000200484:	b8878793          	addi	a5,a5,-1144 # ffffffe000205008 <idle>
ffffffe000200488:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe00020048c:	00005797          	auipc	a5,0x5
ffffffe000200490:	b7c78793          	addi	a5,a5,-1156 # ffffffe000205008 <idle>
ffffffe000200494:	0007b783          	ld	a5,0(a5)
ffffffe000200498:	0007b423          	sd	zero,8(a5)
    // 3. 由于 idle 不参与调度 可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe00020049c:	00005797          	auipc	a5,0x5
ffffffe0002004a0:	b6c78793          	addi	a5,a5,-1172 # ffffffe000205008 <idle>
ffffffe0002004a4:	0007b783          	ld	a5,0(a5)
ffffffe0002004a8:	0007b823          	sd	zero,16(a5)
    idle->priority = 0;
ffffffe0002004ac:	00005797          	auipc	a5,0x5
ffffffe0002004b0:	b5c78793          	addi	a5,a5,-1188 # ffffffe000205008 <idle>
ffffffe0002004b4:	0007b783          	ld	a5,0(a5)
ffffffe0002004b8:	0007bc23          	sd	zero,24(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe0002004bc:	00005797          	auipc	a5,0x5
ffffffe0002004c0:	b4c78793          	addi	a5,a5,-1204 # ffffffe000205008 <idle>
ffffffe0002004c4:	0007b783          	ld	a5,0(a5)
ffffffe0002004c8:	0207b023          	sd	zero,32(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe0002004cc:	00005797          	auipc	a5,0x5
ffffffe0002004d0:	b3c78793          	addi	a5,a5,-1220 # ffffffe000205008 <idle>
ffffffe0002004d4:	0007b703          	ld	a4,0(a5)
ffffffe0002004d8:	00005797          	auipc	a5,0x5
ffffffe0002004dc:	b3878793          	addi	a5,a5,-1224 # ffffffe000205010 <current>
ffffffe0002004e0:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe0002004e4:	00005797          	auipc	a5,0x5
ffffffe0002004e8:	b2478793          	addi	a5,a5,-1244 # ffffffe000205008 <idle>
ffffffe0002004ec:	0007b703          	ld	a4,0(a5)
ffffffe0002004f0:	00005797          	auipc	a5,0x5
ffffffe0002004f4:	b2878793          	addi	a5,a5,-1240 # ffffffe000205018 <task>
ffffffe0002004f8:	00e7b023          	sd	a4,0(a5)

    // 1. 参考 idle 的设置, 为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, counter 为 0, priority 使用 rand() 来设置, pid 为该线程在线程数组中的下标。
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 `thread_struct` 中的 `ra` 和 `sp`, 
    // 4. 其中 `ra` 设置为 __dummy （见 4.3.2）的地址， `sp` 设置为 该线程申请的物理页的高地址
    for(int i = 1; i < NR_TASKS; i++){
ffffffe0002004fc:	00100793          	li	a5,1
ffffffe000200500:	fef42623          	sw	a5,-20(s0)
ffffffe000200504:	0900006f          	j	ffffffe000200594 <task_init+0x130>
        struct task_struct* task_i = (struct task_struct*)kalloc();
ffffffe000200508:	dc1ff0ef          	jal	ra,ffffffe0002002c8 <kalloc>
ffffffe00020050c:	00050793          	mv	a5,a0
ffffffe000200510:	fef43023          	sd	a5,-32(s0)
        task_i->state = TASK_RUNNING;
ffffffe000200514:	fe043783          	ld	a5,-32(s0)
ffffffe000200518:	0007b423          	sd	zero,8(a5)
        task_i->counter = 0;
ffffffe00020051c:	fe043783          	ld	a5,-32(s0)
ffffffe000200520:	0007b823          	sd	zero,16(a5)
        task_i->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
ffffffe000200524:	3d9010ef          	jal	ra,ffffffe0002020fc <rand>
ffffffe000200528:	00050793          	mv	a5,a0
ffffffe00020052c:	0077f793          	andi	a5,a5,7
ffffffe000200530:	00178713          	addi	a4,a5,1
ffffffe000200534:	fe043783          	ld	a5,-32(s0)
ffffffe000200538:	00e7bc23          	sd	a4,24(a5)
        task_i->pid = i;
ffffffe00020053c:	fec42703          	lw	a4,-20(s0)
ffffffe000200540:	fe043783          	ld	a5,-32(s0)
ffffffe000200544:	02e7b023          	sd	a4,32(a5)
        task_i->thread.ra = (uint64)__dummy;
ffffffe000200548:	00004717          	auipc	a4,0x4
ffffffe00020054c:	ae873703          	ld	a4,-1304(a4) # ffffffe000204030 <_GLOBAL_OFFSET_TABLE_+0x20>
ffffffe000200550:	fe043783          	ld	a5,-32(s0)
ffffffe000200554:	02e7b423          	sd	a4,40(a5)
        task_i->thread.sp = (uint64)task_i + PGSIZE;
ffffffe000200558:	fe043703          	ld	a4,-32(s0)
ffffffe00020055c:	000017b7          	lui	a5,0x1
ffffffe000200560:	00f70733          	add	a4,a4,a5
ffffffe000200564:	fe043783          	ld	a5,-32(s0)
ffffffe000200568:	02e7b823          	sd	a4,48(a5) # 1030 <_skernel-0xffffffe0001fefd0>
        task[i] = task_i;
ffffffe00020056c:	00005717          	auipc	a4,0x5
ffffffe000200570:	aac70713          	addi	a4,a4,-1364 # ffffffe000205018 <task>
ffffffe000200574:	fec42783          	lw	a5,-20(s0)
ffffffe000200578:	00379793          	slli	a5,a5,0x3
ffffffe00020057c:	00f707b3          	add	a5,a4,a5
ffffffe000200580:	fe043703          	ld	a4,-32(s0)
ffffffe000200584:	00e7b023          	sd	a4,0(a5)
    for(int i = 1; i < NR_TASKS; i++){
ffffffe000200588:	fec42783          	lw	a5,-20(s0)
ffffffe00020058c:	0017879b          	addiw	a5,a5,1
ffffffe000200590:	fef42623          	sw	a5,-20(s0)
ffffffe000200594:	fec42783          	lw	a5,-20(s0)
ffffffe000200598:	0007871b          	sext.w	a4,a5
ffffffe00020059c:	00700793          	li	a5,7
ffffffe0002005a0:	f6e7d4e3          	bge	a5,a4,ffffffe000200508 <task_init+0xa4>
    }
    /* YOUR CODE HERE */

    Log("...proc_init done!\n");
ffffffe0002005a4:	00003697          	auipc	a3,0x3
ffffffe0002005a8:	b9c68693          	addi	a3,a3,-1124 # ffffffe000203140 <__func__.0>
ffffffe0002005ac:	02e00613          	li	a2,46
ffffffe0002005b0:	00003597          	auipc	a1,0x3
ffffffe0002005b4:	aa058593          	addi	a1,a1,-1376 # ffffffe000203050 <__func__.0+0x8>
ffffffe0002005b8:	00003517          	auipc	a0,0x3
ffffffe0002005bc:	aa050513          	addi	a0,a0,-1376 # ffffffe000203058 <__func__.0+0x10>
ffffffe0002005c0:	2bd010ef          	jal	ra,ffffffe00020207c <printk>
    // printk("proc\n");
    return;
ffffffe0002005c4:	00000013          	nop
}
ffffffe0002005c8:	01813083          	ld	ra,24(sp)
ffffffe0002005cc:	01013403          	ld	s0,16(sp)
ffffffe0002005d0:	02010113          	addi	sp,sp,32
ffffffe0002005d4:	00008067          	ret

ffffffe0002005d8 <dummy>:

void dummy()
{
ffffffe0002005d8:	fd010113          	addi	sp,sp,-48
ffffffe0002005dc:	02113423          	sd	ra,40(sp)
ffffffe0002005e0:	02813023          	sd	s0,32(sp)
ffffffe0002005e4:	03010413          	addi	s0,sp,48
    uint64 MOD = 1000000007;
ffffffe0002005e8:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe0002005ec:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0xffffffdfc48535f9>
ffffffe0002005f0:	fcf43c23          	sd	a5,-40(s0)
    uint64 auto_inc_local_var = 0;
ffffffe0002005f4:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1; // 记录上一个counter
ffffffe0002005f8:	fff00793          	li	a5,-1
ffffffe0002005fc:	fef42223          	sw	a5,-28(s0)
    int last_last_counter = -1; // 记录上上个counter
ffffffe000200600:	fff00793          	li	a5,-1
ffffffe000200604:	fef42023          	sw	a5,-32(s0)
    while(1){
        if (last_counter == -1 || current->counter != last_counter){
ffffffe000200608:	fe442783          	lw	a5,-28(s0)
ffffffe00020060c:	0007871b          	sext.w	a4,a5
ffffffe000200610:	fff00793          	li	a5,-1
ffffffe000200614:	00f70e63          	beq	a4,a5,ffffffe000200630 <dummy+0x58>
ffffffe000200618:	00005797          	auipc	a5,0x5
ffffffe00020061c:	9f878793          	addi	a5,a5,-1544 # ffffffe000205010 <current>
ffffffe000200620:	0007b783          	ld	a5,0(a5)
ffffffe000200624:	0107b703          	ld	a4,16(a5)
ffffffe000200628:	fe442783          	lw	a5,-28(s0)
ffffffe00020062c:	06f70663          	beq	a4,a5,ffffffe000200698 <dummy+0xc0>
            last_last_counter = last_counter;
ffffffe000200630:	fe442783          	lw	a5,-28(s0)
ffffffe000200634:	fef42023          	sw	a5,-32(s0)
            last_counter = current->counter;
ffffffe000200638:	00005797          	auipc	a5,0x5
ffffffe00020063c:	9d878793          	addi	a5,a5,-1576 # ffffffe000205010 <current>
ffffffe000200640:	0007b783          	ld	a5,0(a5)
ffffffe000200644:	0107b783          	ld	a5,16(a5)
ffffffe000200648:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe00020064c:	fe843783          	ld	a5,-24(s0)
ffffffe000200650:	00178713          	addi	a4,a5,1
ffffffe000200654:	fd843783          	ld	a5,-40(s0)
ffffffe000200658:	02f777b3          	remu	a5,a4,a5
ffffffe00020065c:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d. Thread space begin at %lx \n", current->pid, auto_inc_local_var, current); 
ffffffe000200660:	00005797          	auipc	a5,0x5
ffffffe000200664:	9b078793          	addi	a5,a5,-1616 # ffffffe000205010 <current>
ffffffe000200668:	0007b783          	ld	a5,0(a5)
ffffffe00020066c:	0207b703          	ld	a4,32(a5)
ffffffe000200670:	00005797          	auipc	a5,0x5
ffffffe000200674:	9a078793          	addi	a5,a5,-1632 # ffffffe000205010 <current>
ffffffe000200678:	0007b783          	ld	a5,0(a5)
ffffffe00020067c:	00078693          	mv	a3,a5
ffffffe000200680:	fe843603          	ld	a2,-24(s0)
ffffffe000200684:	00070593          	mv	a1,a4
ffffffe000200688:	00003517          	auipc	a0,0x3
ffffffe00020068c:	a0050513          	addi	a0,a0,-1536 # ffffffe000203088 <__func__.0+0x40>
ffffffe000200690:	1ed010ef          	jal	ra,ffffffe00020207c <printk>
ffffffe000200694:	0440006f          	j	ffffffe0002006d8 <dummy+0x100>
            // printk("%d is running. var = %d\n", current->pid, auto_inc_local_var);
        } 
        else if((last_last_counter == 0 || last_last_counter == -1) && last_counter == 1){ // counter恒为1的情况
ffffffe000200698:	fe042783          	lw	a5,-32(s0)
ffffffe00020069c:	0007879b          	sext.w	a5,a5
ffffffe0002006a0:	00078a63          	beqz	a5,ffffffe0002006b4 <dummy+0xdc>
ffffffe0002006a4:	fe042783          	lw	a5,-32(s0)
ffffffe0002006a8:	0007871b          	sext.w	a4,a5
ffffffe0002006ac:	fff00793          	li	a5,-1
ffffffe0002006b0:	f4f71ce3          	bne	a4,a5,ffffffe000200608 <dummy+0x30>
ffffffe0002006b4:	fe442783          	lw	a5,-28(s0)
ffffffe0002006b8:	0007871b          	sext.w	a4,a5
ffffffe0002006bc:	00100793          	li	a5,1
ffffffe0002006c0:	f4f714e3          	bne	a4,a5,ffffffe000200608 <dummy+0x30>
            // 这里比较 tricky，不要求理解。
            last_counter = 0; 
ffffffe0002006c4:	fe042223          	sw	zero,-28(s0)
            current->counter = 0;
ffffffe0002006c8:	00005797          	auipc	a5,0x5
ffffffe0002006cc:	94878793          	addi	a5,a5,-1720 # ffffffe000205010 <current>
ffffffe0002006d0:	0007b783          	ld	a5,0(a5)
ffffffe0002006d4:	0007b823          	sd	zero,16(a5)
        if (last_counter == -1 || current->counter != last_counter){
ffffffe0002006d8:	f31ff06f          	j	ffffffe000200608 <dummy+0x30>

ffffffe0002006dc <switch_to>:
        }
    }
}

void switch_to(struct task_struct* next) 
{
ffffffe0002006dc:	fd010113          	addi	sp,sp,-48
ffffffe0002006e0:	02113423          	sd	ra,40(sp)
ffffffe0002006e4:	02813023          	sd	s0,32(sp)
ffffffe0002006e8:	03010413          	addi	s0,sp,48
ffffffe0002006ec:	fca43c23          	sd	a0,-40(s0)
    /* YOUR CODE HERE */
    if(next != current){
ffffffe0002006f0:	00005797          	auipc	a5,0x5
ffffffe0002006f4:	92078793          	addi	a5,a5,-1760 # ffffffe000205010 <current>
ffffffe0002006f8:	0007b783          	ld	a5,0(a5)
ffffffe0002006fc:	fd843703          	ld	a4,-40(s0)
ffffffe000200700:	04f70e63          	beq	a4,a5,ffffffe00020075c <switch_to+0x80>
        printk("switch to [PID = %d, PRIORITY = %d, COUNTER = %d]\n", next->pid, next->priority, next->counter);
ffffffe000200704:	fd843783          	ld	a5,-40(s0)
ffffffe000200708:	0207b703          	ld	a4,32(a5)
ffffffe00020070c:	fd843783          	ld	a5,-40(s0)
ffffffe000200710:	0187b603          	ld	a2,24(a5)
ffffffe000200714:	fd843783          	ld	a5,-40(s0)
ffffffe000200718:	0107b783          	ld	a5,16(a5)
ffffffe00020071c:	00078693          	mv	a3,a5
ffffffe000200720:	00070593          	mv	a1,a4
ffffffe000200724:	00003517          	auipc	a0,0x3
ffffffe000200728:	9b450513          	addi	a0,a0,-1612 # ffffffe0002030d8 <__func__.0+0x90>
ffffffe00020072c:	151010ef          	jal	ra,ffffffe00020207c <printk>
        // printk("switch to %d\n", next->pid);
        struct task_struct* previous = current;
ffffffe000200730:	00005797          	auipc	a5,0x5
ffffffe000200734:	8e078793          	addi	a5,a5,-1824 # ffffffe000205010 <current>
ffffffe000200738:	0007b783          	ld	a5,0(a5)
ffffffe00020073c:	fef43423          	sd	a5,-24(s0)
        current = next;
ffffffe000200740:	00005797          	auipc	a5,0x5
ffffffe000200744:	8d078793          	addi	a5,a5,-1840 # ffffffe000205010 <current>
ffffffe000200748:	fd843703          	ld	a4,-40(s0)
ffffffe00020074c:	00e7b023          	sd	a4,0(a5)
        __switch_to(previous, next);
ffffffe000200750:	fd843583          	ld	a1,-40(s0)
ffffffe000200754:	fe843503          	ld	a0,-24(s0)
ffffffe000200758:	a8dff0ef          	jal	ra,ffffffe0002001e4 <__switch_to>
    }
}
ffffffe00020075c:	00000013          	nop
ffffffe000200760:	02813083          	ld	ra,40(sp)
ffffffe000200764:	02013403          	ld	s0,32(sp)
ffffffe000200768:	03010113          	addi	sp,sp,48
ffffffe00020076c:	00008067          	ret

ffffffe000200770 <do_timer>:

void do_timer(void) 
{
ffffffe000200770:	ff010113          	addi	sp,sp,-16
ffffffe000200774:	00113423          	sd	ra,8(sp)
ffffffe000200778:	00813023          	sd	s0,0(sp)
ffffffe00020077c:	01010413          	addi	s0,sp,16
    /* 1. 将当前进程的counter--，如果结果大于零则直接返回*/
    /* 2. 否则进行进程调度 */
    if(current == idle || current->counter == 0){
ffffffe000200780:	00005797          	auipc	a5,0x5
ffffffe000200784:	89078793          	addi	a5,a5,-1904 # ffffffe000205010 <current>
ffffffe000200788:	0007b703          	ld	a4,0(a5)
ffffffe00020078c:	00005797          	auipc	a5,0x5
ffffffe000200790:	87c78793          	addi	a5,a5,-1924 # ffffffe000205008 <idle>
ffffffe000200794:	0007b783          	ld	a5,0(a5)
ffffffe000200798:	00f70c63          	beq	a4,a5,ffffffe0002007b0 <do_timer+0x40>
ffffffe00020079c:	00005797          	auipc	a5,0x5
ffffffe0002007a0:	87478793          	addi	a5,a5,-1932 # ffffffe000205010 <current>
ffffffe0002007a4:	0007b783          	ld	a5,0(a5)
ffffffe0002007a8:	0107b783          	ld	a5,16(a5)
ffffffe0002007ac:	00079663          	bnez	a5,ffffffe0002007b8 <do_timer+0x48>
        schedule();
ffffffe0002007b0:	04c000ef          	jal	ra,ffffffe0002007fc <schedule>
    else{
        current->counter--;
        if(!current->counter) schedule();
    }
    /* YOUR CODE HERE */
}
ffffffe0002007b4:	0340006f          	j	ffffffe0002007e8 <do_timer+0x78>
        current->counter--;
ffffffe0002007b8:	00005797          	auipc	a5,0x5
ffffffe0002007bc:	85878793          	addi	a5,a5,-1960 # ffffffe000205010 <current>
ffffffe0002007c0:	0007b783          	ld	a5,0(a5)
ffffffe0002007c4:	0107b703          	ld	a4,16(a5)
ffffffe0002007c8:	fff70713          	addi	a4,a4,-1
ffffffe0002007cc:	00e7b823          	sd	a4,16(a5)
        if(!current->counter) schedule();
ffffffe0002007d0:	00005797          	auipc	a5,0x5
ffffffe0002007d4:	84078793          	addi	a5,a5,-1984 # ffffffe000205010 <current>
ffffffe0002007d8:	0007b783          	ld	a5,0(a5)
ffffffe0002007dc:	0107b783          	ld	a5,16(a5)
ffffffe0002007e0:	00079463          	bnez	a5,ffffffe0002007e8 <do_timer+0x78>
ffffffe0002007e4:	018000ef          	jal	ra,ffffffe0002007fc <schedule>
}
ffffffe0002007e8:	00000013          	nop
ffffffe0002007ec:	00813083          	ld	ra,8(sp)
ffffffe0002007f0:	00013403          	ld	s0,0(sp)
ffffffe0002007f4:	01010113          	addi	sp,sp,16
ffffffe0002007f8:	00008067          	ret

ffffffe0002007fc <schedule>:

void schedule(void) 
{
ffffffe0002007fc:	fd010113          	addi	sp,sp,-48
ffffffe000200800:	02113423          	sd	ra,40(sp)
ffffffe000200804:	02813023          	sd	s0,32(sp)
ffffffe000200808:	03010413          	addi	s0,sp,48
    /* YOUR CODE HERE */
    struct task_struct* next = idle;
ffffffe00020080c:	00004797          	auipc	a5,0x4
ffffffe000200810:	7fc78793          	addi	a5,a5,2044 # ffffffe000205008 <idle>
ffffffe000200814:	0007b783          	ld	a5,0(a5)
ffffffe000200818:	fef43423          	sd	a5,-24(s0)
    while(1){
        uint64 counter_min = UINT64_MAX;
ffffffe00020081c:	fff00793          	li	a5,-1
ffffffe000200820:	fef43023          	sd	a5,-32(s0)
        for(int i = 1; i < NR_TASKS; i++){
ffffffe000200824:	00100793          	li	a5,1
ffffffe000200828:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020082c:	0b00006f          	j	ffffffe0002008dc <schedule+0xe0>
            if(task[i]->state == TASK_RUNNING){
ffffffe000200830:	00004717          	auipc	a4,0x4
ffffffe000200834:	7e870713          	addi	a4,a4,2024 # ffffffe000205018 <task>
ffffffe000200838:	fdc42783          	lw	a5,-36(s0)
ffffffe00020083c:	00379793          	slli	a5,a5,0x3
ffffffe000200840:	00f707b3          	add	a5,a4,a5
ffffffe000200844:	0007b783          	ld	a5,0(a5)
ffffffe000200848:	0087b783          	ld	a5,8(a5)
ffffffe00020084c:	08079263          	bnez	a5,ffffffe0002008d0 <schedule+0xd4>
                if(task[i]->counter && task[i]->counter < counter_min){
ffffffe000200850:	00004717          	auipc	a4,0x4
ffffffe000200854:	7c870713          	addi	a4,a4,1992 # ffffffe000205018 <task>
ffffffe000200858:	fdc42783          	lw	a5,-36(s0)
ffffffe00020085c:	00379793          	slli	a5,a5,0x3
ffffffe000200860:	00f707b3          	add	a5,a4,a5
ffffffe000200864:	0007b783          	ld	a5,0(a5)
ffffffe000200868:	0107b783          	ld	a5,16(a5)
ffffffe00020086c:	06078263          	beqz	a5,ffffffe0002008d0 <schedule+0xd4>
ffffffe000200870:	00004717          	auipc	a4,0x4
ffffffe000200874:	7a870713          	addi	a4,a4,1960 # ffffffe000205018 <task>
ffffffe000200878:	fdc42783          	lw	a5,-36(s0)
ffffffe00020087c:	00379793          	slli	a5,a5,0x3
ffffffe000200880:	00f707b3          	add	a5,a4,a5
ffffffe000200884:	0007b783          	ld	a5,0(a5)
ffffffe000200888:	0107b783          	ld	a5,16(a5)
ffffffe00020088c:	fe043703          	ld	a4,-32(s0)
ffffffe000200890:	04e7f063          	bgeu	a5,a4,ffffffe0002008d0 <schedule+0xd4>
                    counter_min = task[i]->counter;
ffffffe000200894:	00004717          	auipc	a4,0x4
ffffffe000200898:	78470713          	addi	a4,a4,1924 # ffffffe000205018 <task>
ffffffe00020089c:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008a0:	00379793          	slli	a5,a5,0x3
ffffffe0002008a4:	00f707b3          	add	a5,a4,a5
ffffffe0002008a8:	0007b783          	ld	a5,0(a5)
ffffffe0002008ac:	0107b783          	ld	a5,16(a5)
ffffffe0002008b0:	fef43023          	sd	a5,-32(s0)
                    next = task[i];
ffffffe0002008b4:	00004717          	auipc	a4,0x4
ffffffe0002008b8:	76470713          	addi	a4,a4,1892 # ffffffe000205018 <task>
ffffffe0002008bc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008c0:	00379793          	slli	a5,a5,0x3
ffffffe0002008c4:	00f707b3          	add	a5,a4,a5
ffffffe0002008c8:	0007b783          	ld	a5,0(a5)
ffffffe0002008cc:	fef43423          	sd	a5,-24(s0)
        for(int i = 1; i < NR_TASKS; i++){
ffffffe0002008d0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008d4:	0017879b          	addiw	a5,a5,1
ffffffe0002008d8:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002008dc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008e0:	0007871b          	sext.w	a4,a5
ffffffe0002008e4:	00700793          	li	a5,7
ffffffe0002008e8:	f4e7d4e3          	bge	a5,a4,ffffffe000200830 <schedule+0x34>
                }
            }
        }
        if(next != idle) break;
ffffffe0002008ec:	00004797          	auipc	a5,0x4
ffffffe0002008f0:	71c78793          	addi	a5,a5,1820 # ffffffe000205008 <idle>
ffffffe0002008f4:	0007b783          	ld	a5,0(a5)
ffffffe0002008f8:	fe843703          	ld	a4,-24(s0)
ffffffe0002008fc:	0cf71663          	bne	a4,a5,ffffffe0002009c8 <schedule+0x1cc>
        for(int i = 1; i < NR_TASKS; i++){
ffffffe000200900:	00100793          	li	a5,1
ffffffe000200904:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200908:	0ac0006f          	j	ffffffe0002009b4 <schedule+0x1b8>
            task[i]->counter = task[i]->priority;
ffffffe00020090c:	00004717          	auipc	a4,0x4
ffffffe000200910:	70c70713          	addi	a4,a4,1804 # ffffffe000205018 <task>
ffffffe000200914:	fd842783          	lw	a5,-40(s0)
ffffffe000200918:	00379793          	slli	a5,a5,0x3
ffffffe00020091c:	00f707b3          	add	a5,a4,a5
ffffffe000200920:	0007b703          	ld	a4,0(a5)
ffffffe000200924:	00004697          	auipc	a3,0x4
ffffffe000200928:	6f468693          	addi	a3,a3,1780 # ffffffe000205018 <task>
ffffffe00020092c:	fd842783          	lw	a5,-40(s0)
ffffffe000200930:	00379793          	slli	a5,a5,0x3
ffffffe000200934:	00f687b3          	add	a5,a3,a5
ffffffe000200938:	0007b783          	ld	a5,0(a5)
ffffffe00020093c:	01873703          	ld	a4,24(a4)
ffffffe000200940:	00e7b823          	sd	a4,16(a5)
            printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
ffffffe000200944:	00004717          	auipc	a4,0x4
ffffffe000200948:	6d470713          	addi	a4,a4,1748 # ffffffe000205018 <task>
ffffffe00020094c:	fd842783          	lw	a5,-40(s0)
ffffffe000200950:	00379793          	slli	a5,a5,0x3
ffffffe000200954:	00f707b3          	add	a5,a4,a5
ffffffe000200958:	0007b783          	ld	a5,0(a5)
ffffffe00020095c:	0207b583          	ld	a1,32(a5)
ffffffe000200960:	00004717          	auipc	a4,0x4
ffffffe000200964:	6b870713          	addi	a4,a4,1720 # ffffffe000205018 <task>
ffffffe000200968:	fd842783          	lw	a5,-40(s0)
ffffffe00020096c:	00379793          	slli	a5,a5,0x3
ffffffe000200970:	00f707b3          	add	a5,a4,a5
ffffffe000200974:	0007b783          	ld	a5,0(a5)
ffffffe000200978:	0187b603          	ld	a2,24(a5)
ffffffe00020097c:	00004717          	auipc	a4,0x4
ffffffe000200980:	69c70713          	addi	a4,a4,1692 # ffffffe000205018 <task>
ffffffe000200984:	fd842783          	lw	a5,-40(s0)
ffffffe000200988:	00379793          	slli	a5,a5,0x3
ffffffe00020098c:	00f707b3          	add	a5,a4,a5
ffffffe000200990:	0007b783          	ld	a5,0(a5)
ffffffe000200994:	0107b783          	ld	a5,16(a5)
ffffffe000200998:	00078693          	mv	a3,a5
ffffffe00020099c:	00002517          	auipc	a0,0x2
ffffffe0002009a0:	77450513          	addi	a0,a0,1908 # ffffffe000203110 <__func__.0+0xc8>
ffffffe0002009a4:	6d8010ef          	jal	ra,ffffffe00020207c <printk>
        for(int i = 1; i < NR_TASKS; i++){
ffffffe0002009a8:	fd842783          	lw	a5,-40(s0)
ffffffe0002009ac:	0017879b          	addiw	a5,a5,1
ffffffe0002009b0:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002009b4:	fd842783          	lw	a5,-40(s0)
ffffffe0002009b8:	0007871b          	sext.w	a4,a5
ffffffe0002009bc:	00700793          	li	a5,7
ffffffe0002009c0:	f4e7d6e3          	bge	a5,a4,ffffffe00020090c <schedule+0x110>
    while(1){
ffffffe0002009c4:	e59ff06f          	j	ffffffe00020081c <schedule+0x20>
        if(next != idle) break;
ffffffe0002009c8:	00000013          	nop
        }
    }
    switch_to(next);
ffffffe0002009cc:	fe843503          	ld	a0,-24(s0)
ffffffe0002009d0:	d0dff0ef          	jal	ra,ffffffe0002006dc <switch_to>
ffffffe0002009d4:	00000013          	nop
ffffffe0002009d8:	02813083          	ld	ra,40(sp)
ffffffe0002009dc:	02013403          	ld	s0,32(sp)
ffffffe0002009e0:	03010113          	addi	sp,sp,48
ffffffe0002009e4:	00008067          	ret

ffffffe0002009e8 <sbi_ecall>:

struct sbiret sbi_ecall(int ext, int fid, uint64 arg0,
                        uint64 arg1, uint64 arg2,
                        uint64 arg3, uint64 arg4,
                        uint64 arg5)
{
ffffffe0002009e8:	f8010113          	addi	sp,sp,-128
ffffffe0002009ec:	06813c23          	sd	s0,120(sp)
ffffffe0002009f0:	06913823          	sd	s1,112(sp)
ffffffe0002009f4:	07213423          	sd	s2,104(sp)
ffffffe0002009f8:	07313023          	sd	s3,96(sp)
ffffffe0002009fc:	08010413          	addi	s0,sp,128
ffffffe000200a00:	fac43823          	sd	a2,-80(s0)
ffffffe000200a04:	fad43423          	sd	a3,-88(s0)
ffffffe000200a08:	fae43023          	sd	a4,-96(s0)
ffffffe000200a0c:	f8f43c23          	sd	a5,-104(s0)
ffffffe000200a10:	f9043823          	sd	a6,-112(s0)
ffffffe000200a14:	f9143423          	sd	a7,-120(s0)
ffffffe000200a18:	00050793          	mv	a5,a0
ffffffe000200a1c:	faf42e23          	sw	a5,-68(s0)
ffffffe000200a20:	00058793          	mv	a5,a1
ffffffe000200a24:	faf42c23          	sw	a5,-72(s0)
  // #error "Still have unfilled code!"
  // unimplemented
  struct sbiret ecall_ret;
  __asm__ volatile(
ffffffe000200a28:	fbc42783          	lw	a5,-68(s0)
ffffffe000200a2c:	00078913          	mv	s2,a5
ffffffe000200a30:	fb842783          	lw	a5,-72(s0)
ffffffe000200a34:	00078993          	mv	s3,a5
ffffffe000200a38:	fb043e03          	ld	t3,-80(s0)
ffffffe000200a3c:	fa843e83          	ld	t4,-88(s0)
ffffffe000200a40:	fa043f03          	ld	t5,-96(s0)
ffffffe000200a44:	f9843f83          	ld	t6,-104(s0)
ffffffe000200a48:	f9043283          	ld	t0,-112(s0)
ffffffe000200a4c:	f8843483          	ld	s1,-120(s0)
ffffffe000200a50:	00090893          	mv	a7,s2
ffffffe000200a54:	00098813          	mv	a6,s3
ffffffe000200a58:	000e0513          	mv	a0,t3
ffffffe000200a5c:	000e8593          	mv	a1,t4
ffffffe000200a60:	000f0613          	mv	a2,t5
ffffffe000200a64:	000f8693          	mv	a3,t6
ffffffe000200a68:	00028713          	mv	a4,t0
ffffffe000200a6c:	00048793          	mv	a5,s1
ffffffe000200a70:	00000073          	ecall
ffffffe000200a74:	00050e93          	mv	t4,a0
ffffffe000200a78:	00058e13          	mv	t3,a1
ffffffe000200a7c:	fdd43023          	sd	t4,-64(s0)
ffffffe000200a80:	fdc43423          	sd	t3,-56(s0)
    "mv %[ecall_ret_value], a1 "
    : [ecall_ret_error] "=r" (ecall_ret.error), [ecall_ret_value] "=r" (ecall_ret.value)
    : [ext] "r" (ext), [fid] "r" (fid), [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2), [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
    : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "memory"
  );
  return ecall_ret;
ffffffe000200a84:	fc043783          	ld	a5,-64(s0)
ffffffe000200a88:	fcf43823          	sd	a5,-48(s0)
ffffffe000200a8c:	fc843783          	ld	a5,-56(s0)
ffffffe000200a90:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200a94:	fd043703          	ld	a4,-48(s0)
ffffffe000200a98:	fd843783          	ld	a5,-40(s0)
ffffffe000200a9c:	00070313          	mv	t1,a4
ffffffe000200aa0:	00078393          	mv	t2,a5
ffffffe000200aa4:	00030713          	mv	a4,t1
ffffffe000200aa8:	00038793          	mv	a5,t2
}
ffffffe000200aac:	00070513          	mv	a0,a4
ffffffe000200ab0:	00078593          	mv	a1,a5
ffffffe000200ab4:	07813403          	ld	s0,120(sp)
ffffffe000200ab8:	07013483          	ld	s1,112(sp)
ffffffe000200abc:	06813903          	ld	s2,104(sp)
ffffffe000200ac0:	06013983          	ld	s3,96(sp)
ffffffe000200ac4:	08010113          	addi	sp,sp,128
ffffffe000200ac8:	00008067          	ret

ffffffe000200acc <sbi_set_timer>:

void sbi_set_timer(uint64 set_time_value){
ffffffe000200acc:	fe010113          	addi	sp,sp,-32
ffffffe000200ad0:	00113c23          	sd	ra,24(sp)
ffffffe000200ad4:	00813823          	sd	s0,16(sp)
ffffffe000200ad8:	02010413          	addi	s0,sp,32
ffffffe000200adc:	fea43423          	sd	a0,-24(s0)
    sbi_ecall(0x00, 0, set_time_value, 0, 0, 0, 0, 0);
ffffffe000200ae0:	00000893          	li	a7,0
ffffffe000200ae4:	00000813          	li	a6,0
ffffffe000200ae8:	00000793          	li	a5,0
ffffffe000200aec:	00000713          	li	a4,0
ffffffe000200af0:	00000693          	li	a3,0
ffffffe000200af4:	fe843603          	ld	a2,-24(s0)
ffffffe000200af8:	00000593          	li	a1,0
ffffffe000200afc:	00000513          	li	a0,0
ffffffe000200b00:	ee9ff0ef          	jal	ra,ffffffe0002009e8 <sbi_ecall>
}
ffffffe000200b04:	00000013          	nop
ffffffe000200b08:	01813083          	ld	ra,24(sp)
ffffffe000200b0c:	01013403          	ld	s0,16(sp)
ffffffe000200b10:	02010113          	addi	sp,sp,32
ffffffe000200b14:	00008067          	ret

ffffffe000200b18 <trap_handler>:
#include "printk.h"
#include "proc.h"
#include "sbi.h"
#include "defs.h"
// unsigned long TIMECLOCK = 0x1000000;
void trap_handler(unsigned long scause, unsigned long sepc) {
ffffffe000200b18:	fe010113          	addi	sp,sp,-32
ffffffe000200b1c:	00113c23          	sd	ra,24(sp)
ffffffe000200b20:	00813823          	sd	s0,16(sp)
ffffffe000200b24:	02010413          	addi	s0,sp,32
ffffffe000200b28:	fea43423          	sd	a0,-24(s0)
ffffffe000200b2c:	feb43023          	sd	a1,-32(s0)
    if ((scause >> 63 == 1) && (scause & 0x7FFFFFFFFFFFFFFF) == 5) {
ffffffe000200b30:	fe843783          	ld	a5,-24(s0)
ffffffe000200b34:	03f7d713          	srli	a4,a5,0x3f
ffffffe000200b38:	00100793          	li	a5,1
ffffffe000200b3c:	02f71463          	bne	a4,a5,ffffffe000200b64 <trap_handler+0x4c>
ffffffe000200b40:	fe843703          	ld	a4,-24(s0)
ffffffe000200b44:	fff00793          	li	a5,-1
ffffffe000200b48:	0017d793          	srli	a5,a5,0x1
ffffffe000200b4c:	00f77733          	and	a4,a4,a5
ffffffe000200b50:	00500793          	li	a5,5
ffffffe000200b54:	00f71863          	bne	a4,a5,ffffffe000200b64 <trap_handler+0x4c>
        // printk("[S] Supervisor Mode Timer Interrupt\n");
        // printk("[S]Timer Interrupt\n");
        // sbi_ecall(0x00, 0, TIMECLOCK, 0, 0, 0, 0, 0);
        clock_set_next_event();
ffffffe000200b58:	f28ff0ef          	jal	ra,ffffffe000200280 <clock_set_next_event>
        do_timer();
ffffffe000200b5c:	c15ff0ef          	jal	ra,ffffffe000200770 <do_timer>
        return;
ffffffe000200b60:	02c0006f          	j	ffffffe000200b8c <trap_handler+0x74>
    }
    Log("scause: %lx, sepc: %lx\n", scause, sepc);
ffffffe000200b64:	fe043783          	ld	a5,-32(s0)
ffffffe000200b68:	fe843703          	ld	a4,-24(s0)
ffffffe000200b6c:	00002697          	auipc	a3,0x2
ffffffe000200b70:	61c68693          	addi	a3,a3,1564 # ffffffe000203188 <__func__.0>
ffffffe000200b74:	01100613          	li	a2,17
ffffffe000200b78:	00002597          	auipc	a1,0x2
ffffffe000200b7c:	5d858593          	addi	a1,a1,1496 # ffffffe000203150 <__func__.0+0x10>
ffffffe000200b80:	00002517          	auipc	a0,0x2
ffffffe000200b84:	5d850513          	addi	a0,a0,1496 # ffffffe000203158 <__func__.0+0x18>
ffffffe000200b88:	4f4010ef          	jal	ra,ffffffe00020207c <printk>
}
ffffffe000200b8c:	01813083          	ld	ra,24(sp)
ffffffe000200b90:	01013403          	ld	s0,16(sp)
ffffffe000200b94:	02010113          	addi	sp,sp,32
ffffffe000200b98:	00008067          	ret

ffffffe000200b9c <setup_vm>:
extern char _srodata[];
extern char _sdata[];
extern char _sbss[];

void setup_vm(void)
{
ffffffe000200b9c:	fd010113          	addi	sp,sp,-48
ffffffe000200ba0:	02113423          	sd	ra,40(sp)
ffffffe000200ba4:	02813023          	sd	s0,32(sp)
ffffffe000200ba8:	03010413          	addi	s0,sp,48
        high bit 可以忽略
        中间9 bit 作为 early_pgtbl 的 index
        低 30 bit 作为 页内偏移 这里注意到 30 = 9 + 9 + 12， 即我们只使用根页表， 根页表的每个 entry 都对应 1GB 的区域。
    3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    */
    memset(early_pgtbl, 0x0, PGSIZE);
ffffffe000200bac:	00001637          	lui	a2,0x1
ffffffe000200bb0:	00000593          	li	a1,0
ffffffe000200bb4:	00005517          	auipc	a0,0x5
ffffffe000200bb8:	44c50513          	addi	a0,a0,1100 # ffffffe000206000 <early_pgtbl>
ffffffe000200bbc:	584010ef          	jal	ra,ffffffe000202140 <memset>
    uint64 pa = PHY_START, va = VM_START;
ffffffe000200bc0:	00100793          	li	a5,1
ffffffe000200bc4:	01f79793          	slli	a5,a5,0x1f
ffffffe000200bc8:	fef43423          	sd	a5,-24(s0)
ffffffe000200bcc:	fff00793          	li	a5,-1
ffffffe000200bd0:	02579793          	slli	a5,a5,0x25
ffffffe000200bd4:	fef43023          	sd	a5,-32(s0)
    int index = VPN2(va);
ffffffe000200bd8:	fe043783          	ld	a5,-32(s0)
ffffffe000200bdc:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200be0:	0007879b          	sext.w	a5,a5
ffffffe000200be4:	1ff7f793          	andi	a5,a5,511
ffffffe000200be8:	fcf42e23          	sw	a5,-36(s0)
    early_pgtbl[index] = (((pa >> 30) & 0x3ffffff) << 28) | PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D;
ffffffe000200bec:	fe843783          	ld	a5,-24(s0)
ffffffe000200bf0:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200bf4:	01c79713          	slli	a4,a5,0x1c
ffffffe000200bf8:	040007b7          	lui	a5,0x4000
ffffffe000200bfc:	fff78793          	addi	a5,a5,-1 # 3ffffff <_skernel-0xffffffdffc200001>
ffffffe000200c00:	01c79793          	slli	a5,a5,0x1c
ffffffe000200c04:	00f777b3          	and	a5,a4,a5
ffffffe000200c08:	0cf7e713          	ori	a4,a5,207
ffffffe000200c0c:	00005697          	auipc	a3,0x5
ffffffe000200c10:	3f468693          	addi	a3,a3,1012 # ffffffe000206000 <early_pgtbl>
ffffffe000200c14:	fdc42783          	lw	a5,-36(s0)
ffffffe000200c18:	00379793          	slli	a5,a5,0x3
ffffffe000200c1c:	00f687b3          	add	a5,a3,a5
ffffffe000200c20:	00e7b023          	sd	a4,0(a5)
    // va = PHY_START;
    // index = VPN2(va);
    // early_pgtbl[index] = (((pa >> 30) & 0x3ffffff) << 28) | PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D;
}
ffffffe000200c24:	00000013          	nop
ffffffe000200c28:	02813083          	ld	ra,40(sp)
ffffffe000200c2c:	02013403          	ld	s0,32(sp)
ffffffe000200c30:	03010113          	addi	sp,sp,48
ffffffe000200c34:	00008067          	ret

ffffffe000200c38 <setup_vm_final>:

void setup_vm_final(void) {
ffffffe000200c38:	fd010113          	addi	sp,sp,-48
ffffffe000200c3c:	02113423          	sd	ra,40(sp)
ffffffe000200c40:	02813023          	sd	s0,32(sp)
ffffffe000200c44:	03010413          	addi	s0,sp,48
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000200c48:	00001637          	lui	a2,0x1
ffffffe000200c4c:	00000593          	li	a1,0
ffffffe000200c50:	00006517          	auipc	a0,0x6
ffffffe000200c54:	3b050513          	addi	a0,a0,944 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200c58:	4e8010ef          	jal	ra,ffffffe000202140 <memset>

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    uint64 va = VM_START + OPENSBI_SIZE;
ffffffe000200c5c:	f00017b7          	lui	a5,0xf0001
ffffffe000200c60:	00979793          	slli	a5,a5,0x9
ffffffe000200c64:	fef43423          	sd	a5,-24(s0)
    uint64 pa = PHY_START + OPENSBI_SIZE;
ffffffe000200c68:	40100793          	li	a5,1025
ffffffe000200c6c:	01579793          	slli	a5,a5,0x15
ffffffe000200c70:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, _srodata - _stext, PTE_X | PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000200c74:	00003717          	auipc	a4,0x3
ffffffe000200c78:	3b473703          	ld	a4,948(a4) # ffffffe000204028 <_GLOBAL_OFFSET_TABLE_+0x18>
ffffffe000200c7c:	00003797          	auipc	a5,0x3
ffffffe000200c80:	3dc7b783          	ld	a5,988(a5) # ffffffe000204058 <_GLOBAL_OFFSET_TABLE_+0x48>
ffffffe000200c84:	40f707b3          	sub	a5,a4,a5
ffffffe000200c88:	0cb00713          	li	a4,203
ffffffe000200c8c:	00078693          	mv	a3,a5
ffffffe000200c90:	fe043603          	ld	a2,-32(s0)
ffffffe000200c94:	fe843583          	ld	a1,-24(s0)
ffffffe000200c98:	00006517          	auipc	a0,0x6
ffffffe000200c9c:	36850513          	addi	a0,a0,872 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200ca0:	174000ef          	jal	ra,ffffffe000200e14 <create_mapping>

    // mapping kernel rodata -|-|R|V
    va += _srodata - _stext;
ffffffe000200ca4:	00003717          	auipc	a4,0x3
ffffffe000200ca8:	38473703          	ld	a4,900(a4) # ffffffe000204028 <_GLOBAL_OFFSET_TABLE_+0x18>
ffffffe000200cac:	00003797          	auipc	a5,0x3
ffffffe000200cb0:	3ac7b783          	ld	a5,940(a5) # ffffffe000204058 <_GLOBAL_OFFSET_TABLE_+0x48>
ffffffe000200cb4:	40f707b3          	sub	a5,a4,a5
ffffffe000200cb8:	00078713          	mv	a4,a5
ffffffe000200cbc:	fe843783          	ld	a5,-24(s0)
ffffffe000200cc0:	00e787b3          	add	a5,a5,a4
ffffffe000200cc4:	fef43423          	sd	a5,-24(s0)
    pa += _srodata - _stext;
ffffffe000200cc8:	00003717          	auipc	a4,0x3
ffffffe000200ccc:	36073703          	ld	a4,864(a4) # ffffffe000204028 <_GLOBAL_OFFSET_TABLE_+0x18>
ffffffe000200cd0:	00003797          	auipc	a5,0x3
ffffffe000200cd4:	3887b783          	ld	a5,904(a5) # ffffffe000204058 <_GLOBAL_OFFSET_TABLE_+0x48>
ffffffe000200cd8:	40f707b3          	sub	a5,a4,a5
ffffffe000200cdc:	00078713          	mv	a4,a5
ffffffe000200ce0:	fe043783          	ld	a5,-32(s0)
ffffffe000200ce4:	00e787b3          	add	a5,a5,a4
ffffffe000200ce8:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, _sdata - _srodata, PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000200cec:	00003717          	auipc	a4,0x3
ffffffe000200cf0:	34c73703          	ld	a4,844(a4) # ffffffe000204038 <_GLOBAL_OFFSET_TABLE_+0x28>
ffffffe000200cf4:	00003797          	auipc	a5,0x3
ffffffe000200cf8:	3347b783          	ld	a5,820(a5) # ffffffe000204028 <_GLOBAL_OFFSET_TABLE_+0x18>
ffffffe000200cfc:	40f707b3          	sub	a5,a4,a5
ffffffe000200d00:	0c300713          	li	a4,195
ffffffe000200d04:	00078693          	mv	a3,a5
ffffffe000200d08:	fe043603          	ld	a2,-32(s0)
ffffffe000200d0c:	fe843583          	ld	a1,-24(s0)
ffffffe000200d10:	00006517          	auipc	a0,0x6
ffffffe000200d14:	2f050513          	addi	a0,a0,752 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200d18:	0fc000ef          	jal	ra,ffffffe000200e14 <create_mapping>

  
    // mapping other memory -|W|R|V
    va += _sdata - _srodata;
ffffffe000200d1c:	00003717          	auipc	a4,0x3
ffffffe000200d20:	31c73703          	ld	a4,796(a4) # ffffffe000204038 <_GLOBAL_OFFSET_TABLE_+0x28>
ffffffe000200d24:	00003797          	auipc	a5,0x3
ffffffe000200d28:	3047b783          	ld	a5,772(a5) # ffffffe000204028 <_GLOBAL_OFFSET_TABLE_+0x18>
ffffffe000200d2c:	40f707b3          	sub	a5,a4,a5
ffffffe000200d30:	00078713          	mv	a4,a5
ffffffe000200d34:	fe843783          	ld	a5,-24(s0)
ffffffe000200d38:	00e787b3          	add	a5,a5,a4
ffffffe000200d3c:	fef43423          	sd	a5,-24(s0)
    pa += _sdata - _srodata;
ffffffe000200d40:	00003717          	auipc	a4,0x3
ffffffe000200d44:	2f873703          	ld	a4,760(a4) # ffffffe000204038 <_GLOBAL_OFFSET_TABLE_+0x28>
ffffffe000200d48:	00003797          	auipc	a5,0x3
ffffffe000200d4c:	2e07b783          	ld	a5,736(a5) # ffffffe000204028 <_GLOBAL_OFFSET_TABLE_+0x18>
ffffffe000200d50:	40f707b3          	sub	a5,a4,a5
ffffffe000200d54:	00078713          	mv	a4,a5
ffffffe000200d58:	fe043783          	ld	a5,-32(s0)
ffffffe000200d5c:	00e787b3          	add	a5,a5,a4
ffffffe000200d60:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000200d64:	00003717          	auipc	a4,0x3
ffffffe000200d68:	2d473703          	ld	a4,724(a4) # ffffffe000204038 <_GLOBAL_OFFSET_TABLE_+0x28>
ffffffe000200d6c:	00003797          	auipc	a5,0x3
ffffffe000200d70:	2ec7b783          	ld	a5,748(a5) # ffffffe000204058 <_GLOBAL_OFFSET_TABLE_+0x48>
ffffffe000200d74:	40f707b3          	sub	a5,a4,a5
ffffffe000200d78:	08000737          	lui	a4,0x8000
ffffffe000200d7c:	40f707b3          	sub	a5,a4,a5
ffffffe000200d80:	0c700713          	li	a4,199
ffffffe000200d84:	00078693          	mv	a3,a5
ffffffe000200d88:	fe043603          	ld	a2,-32(s0)
ffffffe000200d8c:	fe843583          	ld	a1,-24(s0)
ffffffe000200d90:	00006517          	auipc	a0,0x6
ffffffe000200d94:	27050513          	addi	a0,a0,624 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200d98:	07c000ef          	jal	ra,ffffffe000200e14 <create_mapping>

  
    // set satp with swapper_pg_dir
    uint64 _satp = (((uint64)(swapper_pg_dir) - PA2VA_OFFSET) >> 12) | (8L << 60);
ffffffe000200d9c:	00006717          	auipc	a4,0x6
ffffffe000200da0:	26470713          	addi	a4,a4,612 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200da4:	04100793          	li	a5,65
ffffffe000200da8:	01f79793          	slli	a5,a5,0x1f
ffffffe000200dac:	00f707b3          	add	a5,a4,a5
ffffffe000200db0:	00c7d713          	srli	a4,a5,0xc
ffffffe000200db4:	fff00793          	li	a5,-1
ffffffe000200db8:	03f79793          	slli	a5,a5,0x3f
ffffffe000200dbc:	00f767b3          	or	a5,a4,a5
ffffffe000200dc0:	fcf43c23          	sd	a5,-40(s0)
    csr_write(satp, _satp);
ffffffe000200dc4:	fd843783          	ld	a5,-40(s0)
ffffffe000200dc8:	fcf43823          	sd	a5,-48(s0)
ffffffe000200dcc:	fd043783          	ld	a5,-48(s0)
ffffffe000200dd0:	18079073          	csrw	satp,a5


    Log("set satp to %lx", _satp);
ffffffe000200dd4:	fd843703          	ld	a4,-40(s0)
ffffffe000200dd8:	00002697          	auipc	a3,0x2
ffffffe000200ddc:	43868693          	addi	a3,a3,1080 # ffffffe000203210 <__func__.1>
ffffffe000200de0:	03f00613          	li	a2,63
ffffffe000200de4:	00002597          	auipc	a1,0x2
ffffffe000200de8:	3b458593          	addi	a1,a1,948 # ffffffe000203198 <__func__.0+0x10>
ffffffe000200dec:	00002517          	auipc	a0,0x2
ffffffe000200df0:	3b450513          	addi	a0,a0,948 # ffffffe0002031a0 <__func__.0+0x18>
ffffffe000200df4:	288010ef          	jal	ra,ffffffe00020207c <printk>

    //YOUR CODE HERE

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000200df8:	12000073          	sfence.vma

    // flush icache
    asm volatile("fence.i");
ffffffe000200dfc:	0000100f          	fence.i
    return;
ffffffe000200e00:	00000013          	nop
}
ffffffe000200e04:	02813083          	ld	ra,40(sp)
ffffffe000200e08:	02013403          	ld	s0,32(sp)
ffffffe000200e0c:	03010113          	addi	sp,sp,48
ffffffe000200e10:	00008067          	ret

ffffffe000200e14 <create_mapping>:


/* 创建多级页表映射关系 */
void create_mapping(uint64 *pgtbl, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
ffffffe000200e14:	f8010113          	addi	sp,sp,-128
ffffffe000200e18:	06113c23          	sd	ra,120(sp)
ffffffe000200e1c:	06813823          	sd	s0,112(sp)
ffffffe000200e20:	08010413          	addi	s0,sp,128
ffffffe000200e24:	faa43c23          	sd	a0,-72(s0)
ffffffe000200e28:	fab43823          	sd	a1,-80(s0)
ffffffe000200e2c:	fac43423          	sd	a2,-88(s0)
ffffffe000200e30:	fad43023          	sd	a3,-96(s0)
ffffffe000200e34:	f8e43c23          	sd	a4,-104(s0)
    将给定的一段虚拟内存映射到物理内存上
    物理内存需要分页
    创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
    可以使用 V bit 来判断页表项是否存在
    */
    Log("root: %lx, [%lx, %lx) -> [%lx, %lx), perm: %x", pgtbl, pa, pa+sz, va, va+sz, perm);
ffffffe000200e38:	fa843703          	ld	a4,-88(s0)
ffffffe000200e3c:	fa043783          	ld	a5,-96(s0)
ffffffe000200e40:	00f706b3          	add	a3,a4,a5
ffffffe000200e44:	fb043703          	ld	a4,-80(s0)
ffffffe000200e48:	fa043783          	ld	a5,-96(s0)
ffffffe000200e4c:	00f707b3          	add	a5,a4,a5
ffffffe000200e50:	f9843703          	ld	a4,-104(s0)
ffffffe000200e54:	00e13423          	sd	a4,8(sp)
ffffffe000200e58:	00f13023          	sd	a5,0(sp)
ffffffe000200e5c:	fb043883          	ld	a7,-80(s0)
ffffffe000200e60:	00068813          	mv	a6,a3
ffffffe000200e64:	fa843783          	ld	a5,-88(s0)
ffffffe000200e68:	fb843703          	ld	a4,-72(s0)
ffffffe000200e6c:	00002697          	auipc	a3,0x2
ffffffe000200e70:	3b468693          	addi	a3,a3,948 # ffffffe000203220 <__func__.0>
ffffffe000200e74:	05900613          	li	a2,89
ffffffe000200e78:	00002597          	auipc	a1,0x2
ffffffe000200e7c:	32058593          	addi	a1,a1,800 # ffffffe000203198 <__func__.0+0x10>
ffffffe000200e80:	00002517          	auipc	a0,0x2
ffffffe000200e84:	34850513          	addi	a0,a0,840 # ffffffe0002031c8 <__func__.0+0x40>
ffffffe000200e88:	1f4010ef          	jal	ra,ffffffe00020207c <printk>
    uint64 va_end = va + sz;
ffffffe000200e8c:	fb043703          	ld	a4,-80(s0)
ffffffe000200e90:	fa043783          	ld	a5,-96(s0)
ffffffe000200e94:	00f707b3          	add	a5,a4,a5
ffffffe000200e98:	fef43023          	sd	a5,-32(s0)
    uint64 *now_tbl, now_vpn, now_pte;
    while (va < va_end) {
ffffffe000200e9c:	1980006f          	j	ffffffe000201034 <create_mapping+0x220>
        now_tbl = pgtbl;
ffffffe000200ea0:	fb843783          	ld	a5,-72(s0)
ffffffe000200ea4:	fcf43c23          	sd	a5,-40(s0)
        now_vpn = VPN2(va);
ffffffe000200ea8:	fb043783          	ld	a5,-80(s0)
ffffffe000200eac:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200eb0:	1ff7f793          	andi	a5,a5,511
ffffffe000200eb4:	fcf43823          	sd	a5,-48(s0)
        now_pte = *(now_tbl + now_vpn);
ffffffe000200eb8:	fd043783          	ld	a5,-48(s0)
ffffffe000200ebc:	00379793          	slli	a5,a5,0x3
ffffffe000200ec0:	fd843703          	ld	a4,-40(s0)
ffffffe000200ec4:	00f707b3          	add	a5,a4,a5
ffffffe000200ec8:	0007b783          	ld	a5,0(a5)
ffffffe000200ecc:	fef43423          	sd	a5,-24(s0)
        if ((now_pte & PTE_V) == 0) {
ffffffe000200ed0:	fe843783          	ld	a5,-24(s0)
ffffffe000200ed4:	0017f793          	andi	a5,a5,1
ffffffe000200ed8:	04079463          	bnez	a5,ffffffe000200f20 <create_mapping+0x10c>
            uint64 new_page_phy = (uint64)kalloc() - PA2VA_OFFSET;
ffffffe000200edc:	becff0ef          	jal	ra,ffffffe0002002c8 <kalloc>
ffffffe000200ee0:	00050713          	mv	a4,a0
ffffffe000200ee4:	04100793          	li	a5,65
ffffffe000200ee8:	01f79793          	slli	a5,a5,0x1f
ffffffe000200eec:	00f707b3          	add	a5,a4,a5
ffffffe000200ef0:	fcf43423          	sd	a5,-56(s0)
            now_pte = ((uint64)new_page_phy >> 12) << 10 | PTE_V;
ffffffe000200ef4:	fc843783          	ld	a5,-56(s0)
ffffffe000200ef8:	00c7d793          	srli	a5,a5,0xc
ffffffe000200efc:	00a79793          	slli	a5,a5,0xa
ffffffe000200f00:	0017e793          	ori	a5,a5,1
ffffffe000200f04:	fef43423          	sd	a5,-24(s0)
            *(now_tbl + now_vpn) = now_pte;
ffffffe000200f08:	fd043783          	ld	a5,-48(s0)
ffffffe000200f0c:	00379793          	slli	a5,a5,0x3
ffffffe000200f10:	fd843703          	ld	a4,-40(s0)
ffffffe000200f14:	00f707b3          	add	a5,a4,a5
ffffffe000200f18:	fe843703          	ld	a4,-24(s0)
ffffffe000200f1c:	00e7b023          	sd	a4,0(a5)
        }

        now_tbl = (uint64*)(((now_pte >> 10) << 12) + PA2VA_OFFSET);
ffffffe000200f20:	fe843783          	ld	a5,-24(s0)
ffffffe000200f24:	00a7d793          	srli	a5,a5,0xa
ffffffe000200f28:	00c79713          	slli	a4,a5,0xc
ffffffe000200f2c:	fbf00793          	li	a5,-65
ffffffe000200f30:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f34:	00f707b3          	add	a5,a4,a5
ffffffe000200f38:	fcf43c23          	sd	a5,-40(s0)
        now_vpn = VPN1(va);
ffffffe000200f3c:	fb043783          	ld	a5,-80(s0)
ffffffe000200f40:	0157d793          	srli	a5,a5,0x15
ffffffe000200f44:	1ff7f793          	andi	a5,a5,511
ffffffe000200f48:	fcf43823          	sd	a5,-48(s0)
        now_pte = *(now_tbl + now_vpn);
ffffffe000200f4c:	fd043783          	ld	a5,-48(s0)
ffffffe000200f50:	00379793          	slli	a5,a5,0x3
ffffffe000200f54:	fd843703          	ld	a4,-40(s0)
ffffffe000200f58:	00f707b3          	add	a5,a4,a5
ffffffe000200f5c:	0007b783          	ld	a5,0(a5)
ffffffe000200f60:	fef43423          	sd	a5,-24(s0)
        if ((now_pte & PTE_V) == 0) {
ffffffe000200f64:	fe843783          	ld	a5,-24(s0)
ffffffe000200f68:	0017f793          	andi	a5,a5,1
ffffffe000200f6c:	04079463          	bnez	a5,ffffffe000200fb4 <create_mapping+0x1a0>
            uint64 new_page_phy = (uint64)kalloc() - PA2VA_OFFSET;
ffffffe000200f70:	b58ff0ef          	jal	ra,ffffffe0002002c8 <kalloc>
ffffffe000200f74:	00050713          	mv	a4,a0
ffffffe000200f78:	04100793          	li	a5,65
ffffffe000200f7c:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f80:	00f707b3          	add	a5,a4,a5
ffffffe000200f84:	fcf43023          	sd	a5,-64(s0)
            now_pte = ((uint64)new_page_phy >> 12) << 10 | PTE_V;
ffffffe000200f88:	fc043783          	ld	a5,-64(s0)
ffffffe000200f8c:	00c7d793          	srli	a5,a5,0xc
ffffffe000200f90:	00a79793          	slli	a5,a5,0xa
ffffffe000200f94:	0017e793          	ori	a5,a5,1
ffffffe000200f98:	fef43423          	sd	a5,-24(s0)
            *(now_tbl + now_vpn) = now_pte;
ffffffe000200f9c:	fd043783          	ld	a5,-48(s0)
ffffffe000200fa0:	00379793          	slli	a5,a5,0x3
ffffffe000200fa4:	fd843703          	ld	a4,-40(s0)
ffffffe000200fa8:	00f707b3          	add	a5,a4,a5
ffffffe000200fac:	fe843703          	ld	a4,-24(s0)
ffffffe000200fb0:	00e7b023          	sd	a4,0(a5)
        }

        now_tbl = (uint64*)(((now_pte >> 10) << 12) + PA2VA_OFFSET);
ffffffe000200fb4:	fe843783          	ld	a5,-24(s0)
ffffffe000200fb8:	00a7d793          	srli	a5,a5,0xa
ffffffe000200fbc:	00c79713          	slli	a4,a5,0xc
ffffffe000200fc0:	fbf00793          	li	a5,-65
ffffffe000200fc4:	01f79793          	slli	a5,a5,0x1f
ffffffe000200fc8:	00f707b3          	add	a5,a4,a5
ffffffe000200fcc:	fcf43c23          	sd	a5,-40(s0)
        now_vpn = VPN0(va);
ffffffe000200fd0:	fb043783          	ld	a5,-80(s0)
ffffffe000200fd4:	00c7d793          	srli	a5,a5,0xc
ffffffe000200fd8:	1ff7f793          	andi	a5,a5,511
ffffffe000200fdc:	fcf43823          	sd	a5,-48(s0)
        now_pte = ((pa >> 12) << 10) | perm | PTE_V;
ffffffe000200fe0:	fa843783          	ld	a5,-88(s0)
ffffffe000200fe4:	00c7d793          	srli	a5,a5,0xc
ffffffe000200fe8:	00a79713          	slli	a4,a5,0xa
ffffffe000200fec:	f9843783          	ld	a5,-104(s0)
ffffffe000200ff0:	00f767b3          	or	a5,a4,a5
ffffffe000200ff4:	0017e793          	ori	a5,a5,1
ffffffe000200ff8:	fef43423          	sd	a5,-24(s0)
        *(now_tbl + now_vpn) = now_pte;
ffffffe000200ffc:	fd043783          	ld	a5,-48(s0)
ffffffe000201000:	00379793          	slli	a5,a5,0x3
ffffffe000201004:	fd843703          	ld	a4,-40(s0)
ffffffe000201008:	00f707b3          	add	a5,a4,a5
ffffffe00020100c:	fe843703          	ld	a4,-24(s0)
ffffffe000201010:	00e7b023          	sd	a4,0(a5)

        va += PGSIZE;
ffffffe000201014:	fb043703          	ld	a4,-80(s0)
ffffffe000201018:	000017b7          	lui	a5,0x1
ffffffe00020101c:	00f707b3          	add	a5,a4,a5
ffffffe000201020:	faf43823          	sd	a5,-80(s0)
        pa += PGSIZE;
ffffffe000201024:	fa843703          	ld	a4,-88(s0)
ffffffe000201028:	000017b7          	lui	a5,0x1
ffffffe00020102c:	00f707b3          	add	a5,a4,a5
ffffffe000201030:	faf43423          	sd	a5,-88(s0)
    while (va < va_end) {
ffffffe000201034:	fb043703          	ld	a4,-80(s0)
ffffffe000201038:	fe043783          	ld	a5,-32(s0)
ffffffe00020103c:	e6f762e3          	bltu	a4,a5,ffffffe000200ea0 <create_mapping+0x8c>
    }
}
ffffffe000201040:	00000013          	nop
ffffffe000201044:	00000013          	nop
ffffffe000201048:	07813083          	ld	ra,120(sp)
ffffffe00020104c:	07013403          	ld	s0,112(sp)
ffffffe000201050:	08010113          	addi	sp,sp,128
ffffffe000201054:	00008067          	ret

ffffffe000201058 <start_kernel>:
#include "proc.h"

extern void test();
extern char _stext[];
extern char _srodata[];
int start_kernel() {
ffffffe000201058:	ff010113          	addi	sp,sp,-16
ffffffe00020105c:	00113423          	sd	ra,8(sp)
ffffffe000201060:	00813023          	sd	s0,0(sp)
ffffffe000201064:	01010413          	addi	s0,sp,16
    // printk("%d ZJU Computer System II\n", 2023);
    printk("%dSystemIII\n", 2024);
ffffffe000201068:	7e800593          	li	a1,2024
ffffffe00020106c:	00002517          	auipc	a0,0x2
ffffffe000201070:	1c450513          	addi	a0,a0,452 # ffffffe000203230 <__func__.0+0x10>
ffffffe000201074:	008010ef          	jal	ra,ffffffe00020207c <printk>
    // printk("_srodata = %x\n", *_srodata);
    // *_stext = 0;                            // 写
    // *_srodata = 0;
    // printk("_stext = %x\n", *_stext);
    // printk("_srodata = %x\n", *_srodata);
    test(); // DO NOT DELETE !!!
ffffffe000201078:	01c000ef          	jal	ra,ffffffe000201094 <test>
	return 0;
ffffffe00020107c:	00000793          	li	a5,0
}
ffffffe000201080:	00078513          	mv	a0,a5
ffffffe000201084:	00813083          	ld	ra,8(sp)
ffffffe000201088:	00013403          	ld	s0,0(sp)
ffffffe00020108c:	01010113          	addi	sp,sp,16
ffffffe000201090:	00008067          	ret

ffffffe000201094 <test>:
#include "printk.h"
#include "defs.h"
// Please do not modify

void test() {
ffffffe000201094:	ff010113          	addi	sp,sp,-16
ffffffe000201098:	00813423          	sd	s0,8(sp)
ffffffe00020109c:	01010413          	addi	s0,sp,16
    // unsigned long record_time = 0; 
    // int i = 0;
    while (1) {
ffffffe0002010a0:	0000006f          	j	ffffffe0002010a0 <test+0xc>

ffffffe0002010a4 <__udivsi3>:
# define __divdi3 __divsi3
# define __moddi3 __modsi3
#else
FUNC_BEGIN (__udivsi3)
  /* Compute __udivdi3(a0 << 32, a1 << 32); cast result to uint32_t.  */
  sll    a0, a0, 32
ffffffe0002010a4:	02051513          	slli	a0,a0,0x20
  sll    a1, a1, 32
ffffffe0002010a8:	02059593          	slli	a1,a1,0x20
  move   t0, ra
ffffffe0002010ac:	00008293          	mv	t0,ra
  jal    HIDDEN_JUMPTARGET(__udivdi3)
ffffffe0002010b0:	03c000ef          	jal	ra,ffffffe0002010ec <__hidden___udivdi3>
  sext.w a0, a0
ffffffe0002010b4:	0005051b          	sext.w	a0,a0
  jr     t0
ffffffe0002010b8:	00028067          	jr	t0

ffffffe0002010bc <__umodsi3>:
FUNC_END (__udivsi3)

FUNC_BEGIN (__umodsi3)
  /* Compute __udivdi3((uint32_t)a0, (uint32_t)a1); cast a1 to uint32_t.  */
  sll    a0, a0, 32
ffffffe0002010bc:	02051513          	slli	a0,a0,0x20
  sll    a1, a1, 32
ffffffe0002010c0:	02059593          	slli	a1,a1,0x20
  srl    a0, a0, 32
ffffffe0002010c4:	02055513          	srli	a0,a0,0x20
  srl    a1, a1, 32
ffffffe0002010c8:	0205d593          	srli	a1,a1,0x20
  move   t0, ra
ffffffe0002010cc:	00008293          	mv	t0,ra
  jal    HIDDEN_JUMPTARGET(__udivdi3)
ffffffe0002010d0:	01c000ef          	jal	ra,ffffffe0002010ec <__hidden___udivdi3>
  sext.w a0, a1
ffffffe0002010d4:	0005851b          	sext.w	a0,a1
  jr     t0
ffffffe0002010d8:	00028067          	jr	t0

ffffffe0002010dc <__divsi3>:

FUNC_ALIAS (__modsi3, __moddi3)

FUNC_BEGIN( __divsi3)
  /* Check for special case of INT_MIN/-1. Otherwise, fall into __divdi3.  */
  li    t0, -1
ffffffe0002010dc:	fff00293          	li	t0,-1
  beq   a1, t0, .L20
ffffffe0002010e0:	0a558c63          	beq	a1,t0,ffffffe000201198 <__moddi3+0x30>

ffffffe0002010e4 <__divdi3>:
#endif

FUNC_BEGIN (__divdi3)
  bltz  a0, .L10
ffffffe0002010e4:	06054063          	bltz	a0,ffffffe000201144 <__umoddi3+0x10>
  bltz  a1, .L11
ffffffe0002010e8:	0605c663          	bltz	a1,ffffffe000201154 <__umoddi3+0x20>

ffffffe0002010ec <__hidden___udivdi3>:
  /* Since the quotient is positive, fall into __udivdi3.  */

FUNC_BEGIN (__udivdi3)
  mv    a2, a1
ffffffe0002010ec:	00058613          	mv	a2,a1
  mv    a1, a0
ffffffe0002010f0:	00050593          	mv	a1,a0
  li    a0, -1
ffffffe0002010f4:	fff00513          	li	a0,-1
  beqz  a2, .L5
ffffffe0002010f8:	02060c63          	beqz	a2,ffffffe000201130 <__hidden___udivdi3+0x44>
  li    a3, 1
ffffffe0002010fc:	00100693          	li	a3,1
  bgeu  a2, a1, .L2
ffffffe000201100:	00b67a63          	bgeu	a2,a1,ffffffe000201114 <__hidden___udivdi3+0x28>
.L1:
  blez  a2, .L2
ffffffe000201104:	00c05863          	blez	a2,ffffffe000201114 <__hidden___udivdi3+0x28>
  slli  a2, a2, 1
ffffffe000201108:	00161613          	slli	a2,a2,0x1
  slli  a3, a3, 1
ffffffe00020110c:	00169693          	slli	a3,a3,0x1
  bgtu  a1, a2, .L1
ffffffe000201110:	feb66ae3          	bltu	a2,a1,ffffffe000201104 <__hidden___udivdi3+0x18>
.L2:
  li    a0, 0
ffffffe000201114:	00000513          	li	a0,0
.L3:
  bltu  a1, a2, .L4
ffffffe000201118:	00c5e663          	bltu	a1,a2,ffffffe000201124 <__hidden___udivdi3+0x38>
  sub   a1, a1, a2
ffffffe00020111c:	40c585b3          	sub	a1,a1,a2
  or    a0, a0, a3
ffffffe000201120:	00d56533          	or	a0,a0,a3
.L4:
  srli  a3, a3, 1
ffffffe000201124:	0016d693          	srli	a3,a3,0x1
  srli  a2, a2, 1
ffffffe000201128:	00165613          	srli	a2,a2,0x1
  bnez  a3, .L3
ffffffe00020112c:	fe0696e3          	bnez	a3,ffffffe000201118 <__hidden___udivdi3+0x2c>
.L5:
  ret
ffffffe000201130:	00008067          	ret

ffffffe000201134 <__umoddi3>:
FUNC_END (__udivdi3)
HIDDEN_DEF (__udivdi3)

FUNC_BEGIN (__umoddi3)
  /* Call __udivdi3(a0, a1), then return the remainder, which is in a1.  */
  move  t0, ra
ffffffe000201134:	00008293          	mv	t0,ra
  jal   HIDDEN_JUMPTARGET(__udivdi3)
ffffffe000201138:	fb5ff0ef          	jal	ra,ffffffe0002010ec <__hidden___udivdi3>
  move  a0, a1
ffffffe00020113c:	00058513          	mv	a0,a1
  jr    t0
ffffffe000201140:	00028067          	jr	t0
FUNC_END (__umoddi3)

  /* Handle negative arguments to __divdi3.  */
.L10:
  neg   a0, a0
ffffffe000201144:	40a00533          	neg	a0,a0
  /* Zero is handled as a negative so that the result will not be inverted.  */
  bgtz  a1, .L12     /* Compute __udivdi3(-a0, a1), then negate the result.  */
ffffffe000201148:	00b04863          	bgtz	a1,ffffffe000201158 <__umoddi3+0x24>

  neg   a1, a1
ffffffe00020114c:	40b005b3          	neg	a1,a1
  j     HIDDEN_JUMPTARGET(__udivdi3)     /* Compute __udivdi3(-a0, -a1).  */
ffffffe000201150:	f9dff06f          	j	ffffffe0002010ec <__hidden___udivdi3>
.L11:                /* Compute __udivdi3(a0, -a1), then negate the result.  */
  neg   a1, a1
ffffffe000201154:	40b005b3          	neg	a1,a1
.L12:
  move  t0, ra
ffffffe000201158:	00008293          	mv	t0,ra
  jal   HIDDEN_JUMPTARGET(__udivdi3)
ffffffe00020115c:	f91ff0ef          	jal	ra,ffffffe0002010ec <__hidden___udivdi3>
  neg   a0, a0
ffffffe000201160:	40a00533          	neg	a0,a0
  jr    t0
ffffffe000201164:	00028067          	jr	t0

ffffffe000201168 <__moddi3>:
FUNC_END (__divdi3)

FUNC_BEGIN (__moddi3)
  move   t0, ra
ffffffe000201168:	00008293          	mv	t0,ra
  bltz   a1, .L31
ffffffe00020116c:	0005ca63          	bltz	a1,ffffffe000201180 <__moddi3+0x18>
  bltz   a0, .L32
ffffffe000201170:	00054c63          	bltz	a0,ffffffe000201188 <__moddi3+0x20>
.L30:
  jal    HIDDEN_JUMPTARGET(__udivdi3)    /* The dividend is not negative.  */
ffffffe000201174:	f79ff0ef          	jal	ra,ffffffe0002010ec <__hidden___udivdi3>
  move   a0, a1
ffffffe000201178:	00058513          	mv	a0,a1
  jr     t0
ffffffe00020117c:	00028067          	jr	t0
.L31:
  neg    a1, a1
ffffffe000201180:	40b005b3          	neg	a1,a1
  bgez   a0, .L30
ffffffe000201184:	fe0558e3          	bgez	a0,ffffffe000201174 <__moddi3+0xc>
.L32:
  neg    a0, a0
ffffffe000201188:	40a00533          	neg	a0,a0
  jal    HIDDEN_JUMPTARGET(__udivdi3)    /* The dividend is hella negative.  */
ffffffe00020118c:	f61ff0ef          	jal	ra,ffffffe0002010ec <__hidden___udivdi3>
  neg    a0, a1
ffffffe000201190:	40b00533          	neg	a0,a1
  jr     t0
ffffffe000201194:	00028067          	jr	t0
FUNC_END (__moddi3)

#if __riscv_xlen == 64
  /* continuation of __divsi3 */
.L20:
  sll   t0, t0, 31
ffffffe000201198:	01f29293          	slli	t0,t0,0x1f
  bne   a0, t0, __divdi3
ffffffe00020119c:	f45514e3          	bne	a0,t0,ffffffe0002010e4 <__divdi3>
  ret
ffffffe0002011a0:	00008067          	ret

ffffffe0002011a4 <__muldi3>:
/* Our RV64 64-bit routine is equivalent to our RV32 32-bit routine.  */
# define __muldi3 __mulsi3
#endif

FUNC_BEGIN (__muldi3)
  mv     a2, a0
ffffffe0002011a4:	00050613          	mv	a2,a0
  li     a0, 0
ffffffe0002011a8:	00000513          	li	a0,0
.L1:
  andi   a3, a1, 1
ffffffe0002011ac:	0015f693          	andi	a3,a1,1
  beqz   a3, .L2
ffffffe0002011b0:	00068463          	beqz	a3,ffffffe0002011b8 <__muldi3+0x14>
  add    a0, a0, a2
ffffffe0002011b4:	00c50533          	add	a0,a0,a2
.L2:
  srli   a1, a1, 1
ffffffe0002011b8:	0015d593          	srli	a1,a1,0x1
  slli   a2, a2, 1
ffffffe0002011bc:	00161613          	slli	a2,a2,0x1
  bnez   a1, .L1
ffffffe0002011c0:	fe0596e3          	bnez	a1,ffffffe0002011ac <__muldi3+0x8>
  ret
ffffffe0002011c4:	00008067          	ret

ffffffe0002011c8 <putchar>:
  bool sign;
  int width;
  int prec;
};

void putchar(char c) {
ffffffe0002011c8:	fe010113          	addi	sp,sp,-32
ffffffe0002011cc:	00113c23          	sd	ra,24(sp)
ffffffe0002011d0:	00813823          	sd	s0,16(sp)
ffffffe0002011d4:	02010413          	addi	s0,sp,32
ffffffe0002011d8:	00050793          	mv	a5,a0
ffffffe0002011dc:	fef407a3          	sb	a5,-17(s0)
  sbi_ecall(SBI_PUTCHAR, 0, c, 0, 0, 0, 0, 0);
ffffffe0002011e0:	fef44603          	lbu	a2,-17(s0)
ffffffe0002011e4:	00000893          	li	a7,0
ffffffe0002011e8:	00000813          	li	a6,0
ffffffe0002011ec:	00000793          	li	a5,0
ffffffe0002011f0:	00000713          	li	a4,0
ffffffe0002011f4:	00000693          	li	a3,0
ffffffe0002011f8:	00000593          	li	a1,0
ffffffe0002011fc:	00100513          	li	a0,1
ffffffe000201200:	fe8ff0ef          	jal	ra,ffffffe0002009e8 <sbi_ecall>
}
ffffffe000201204:	00000013          	nop
ffffffe000201208:	01813083          	ld	ra,24(sp)
ffffffe00020120c:	01013403          	ld	s0,16(sp)
ffffffe000201210:	02010113          	addi	sp,sp,32
ffffffe000201214:	00008067          	ret

ffffffe000201218 <isspace>:

int isspace(int c) {
ffffffe000201218:	fe010113          	addi	sp,sp,-32
ffffffe00020121c:	00813c23          	sd	s0,24(sp)
ffffffe000201220:	02010413          	addi	s0,sp,32
ffffffe000201224:	00050793          	mv	a5,a0
ffffffe000201228:	fef42623          	sw	a5,-20(s0)
  return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe00020122c:	fec42783          	lw	a5,-20(s0)
ffffffe000201230:	0007871b          	sext.w	a4,a5
ffffffe000201234:	02000793          	li	a5,32
ffffffe000201238:	02f70263          	beq	a4,a5,ffffffe00020125c <isspace+0x44>
ffffffe00020123c:	fec42783          	lw	a5,-20(s0)
ffffffe000201240:	0007871b          	sext.w	a4,a5
ffffffe000201244:	00800793          	li	a5,8
ffffffe000201248:	00e7de63          	bge	a5,a4,ffffffe000201264 <isspace+0x4c>
ffffffe00020124c:	fec42783          	lw	a5,-20(s0)
ffffffe000201250:	0007871b          	sext.w	a4,a5
ffffffe000201254:	00d00793          	li	a5,13
ffffffe000201258:	00e7c663          	blt	a5,a4,ffffffe000201264 <isspace+0x4c>
ffffffe00020125c:	00100793          	li	a5,1
ffffffe000201260:	0080006f          	j	ffffffe000201268 <isspace+0x50>
ffffffe000201264:	00000793          	li	a5,0
}
ffffffe000201268:	00078513          	mv	a0,a5
ffffffe00020126c:	01813403          	ld	s0,24(sp)
ffffffe000201270:	02010113          	addi	sp,sp,32
ffffffe000201274:	00008067          	ret

ffffffe000201278 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000201278:	fb010113          	addi	sp,sp,-80
ffffffe00020127c:	04113423          	sd	ra,72(sp)
ffffffe000201280:	04813023          	sd	s0,64(sp)
ffffffe000201284:	05010413          	addi	s0,sp,80
ffffffe000201288:	fca43423          	sd	a0,-56(s0)
ffffffe00020128c:	fcb43023          	sd	a1,-64(s0)
ffffffe000201290:	00060793          	mv	a5,a2
ffffffe000201294:	faf42e23          	sw	a5,-68(s0)
  long ret = 0;
ffffffe000201298:	fe043423          	sd	zero,-24(s0)
  bool neg = false;
ffffffe00020129c:	fe0403a3          	sb	zero,-25(s0)
  const char *p = nptr;
ffffffe0002012a0:	fc843783          	ld	a5,-56(s0)
ffffffe0002012a4:	fcf43c23          	sd	a5,-40(s0)

  while (isspace(*p)) {
ffffffe0002012a8:	0100006f          	j	ffffffe0002012b8 <strtol+0x40>
    p++;
ffffffe0002012ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002012b0:	00178793          	addi	a5,a5,1 # 1001 <_skernel-0xffffffe0001fefff>
ffffffe0002012b4:	fcf43c23          	sd	a5,-40(s0)
  while (isspace(*p)) {
ffffffe0002012b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002012bc:	0007c783          	lbu	a5,0(a5)
ffffffe0002012c0:	0007879b          	sext.w	a5,a5
ffffffe0002012c4:	00078513          	mv	a0,a5
ffffffe0002012c8:	f51ff0ef          	jal	ra,ffffffe000201218 <isspace>
ffffffe0002012cc:	00050793          	mv	a5,a0
ffffffe0002012d0:	fc079ee3          	bnez	a5,ffffffe0002012ac <strtol+0x34>
  }

  if (*p == '-') {
ffffffe0002012d4:	fd843783          	ld	a5,-40(s0)
ffffffe0002012d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002012dc:	00078713          	mv	a4,a5
ffffffe0002012e0:	02d00793          	li	a5,45
ffffffe0002012e4:	00f71e63          	bne	a4,a5,ffffffe000201300 <strtol+0x88>
    neg = true;
ffffffe0002012e8:	00100793          	li	a5,1
ffffffe0002012ec:	fef403a3          	sb	a5,-25(s0)
    p++;
ffffffe0002012f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002012f4:	00178793          	addi	a5,a5,1
ffffffe0002012f8:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002012fc:	0240006f          	j	ffffffe000201320 <strtol+0xa8>
  } else if (*p == '+') {
ffffffe000201300:	fd843783          	ld	a5,-40(s0)
ffffffe000201304:	0007c783          	lbu	a5,0(a5)
ffffffe000201308:	00078713          	mv	a4,a5
ffffffe00020130c:	02b00793          	li	a5,43
ffffffe000201310:	00f71863          	bne	a4,a5,ffffffe000201320 <strtol+0xa8>
    p++;
ffffffe000201314:	fd843783          	ld	a5,-40(s0)
ffffffe000201318:	00178793          	addi	a5,a5,1
ffffffe00020131c:	fcf43c23          	sd	a5,-40(s0)
  }

  if (base == 0) {
ffffffe000201320:	fbc42783          	lw	a5,-68(s0)
ffffffe000201324:	0007879b          	sext.w	a5,a5
ffffffe000201328:	06079c63          	bnez	a5,ffffffe0002013a0 <strtol+0x128>
    if (*p == '0') {
ffffffe00020132c:	fd843783          	ld	a5,-40(s0)
ffffffe000201330:	0007c783          	lbu	a5,0(a5)
ffffffe000201334:	00078713          	mv	a4,a5
ffffffe000201338:	03000793          	li	a5,48
ffffffe00020133c:	04f71e63          	bne	a4,a5,ffffffe000201398 <strtol+0x120>
      p++;
ffffffe000201340:	fd843783          	ld	a5,-40(s0)
ffffffe000201344:	00178793          	addi	a5,a5,1
ffffffe000201348:	fcf43c23          	sd	a5,-40(s0)
      if (*p == 'x' || *p == 'X') {
ffffffe00020134c:	fd843783          	ld	a5,-40(s0)
ffffffe000201350:	0007c783          	lbu	a5,0(a5)
ffffffe000201354:	00078713          	mv	a4,a5
ffffffe000201358:	07800793          	li	a5,120
ffffffe00020135c:	00f70c63          	beq	a4,a5,ffffffe000201374 <strtol+0xfc>
ffffffe000201360:	fd843783          	ld	a5,-40(s0)
ffffffe000201364:	0007c783          	lbu	a5,0(a5)
ffffffe000201368:	00078713          	mv	a4,a5
ffffffe00020136c:	05800793          	li	a5,88
ffffffe000201370:	00f71e63          	bne	a4,a5,ffffffe00020138c <strtol+0x114>
        base = 16;
ffffffe000201374:	01000793          	li	a5,16
ffffffe000201378:	faf42e23          	sw	a5,-68(s0)
        p++;
ffffffe00020137c:	fd843783          	ld	a5,-40(s0)
ffffffe000201380:	00178793          	addi	a5,a5,1
ffffffe000201384:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201388:	0180006f          	j	ffffffe0002013a0 <strtol+0x128>
      } else {
        base = 8;
ffffffe00020138c:	00800793          	li	a5,8
ffffffe000201390:	faf42e23          	sw	a5,-68(s0)
ffffffe000201394:	00c0006f          	j	ffffffe0002013a0 <strtol+0x128>
      }
    } else {
      base = 10;
ffffffe000201398:	00a00793          	li	a5,10
ffffffe00020139c:	faf42e23          	sw	a5,-68(s0)
    }
  }

  while (1) {
    int digit;
    if (*p >= '0' && *p <= '9') {
ffffffe0002013a0:	fd843783          	ld	a5,-40(s0)
ffffffe0002013a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002013a8:	00078713          	mv	a4,a5
ffffffe0002013ac:	02f00793          	li	a5,47
ffffffe0002013b0:	02e7f863          	bgeu	a5,a4,ffffffe0002013e0 <strtol+0x168>
ffffffe0002013b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002013b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002013bc:	00078713          	mv	a4,a5
ffffffe0002013c0:	03900793          	li	a5,57
ffffffe0002013c4:	00e7ee63          	bltu	a5,a4,ffffffe0002013e0 <strtol+0x168>
      digit = *p - '0';
ffffffe0002013c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002013cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002013d0:	0007879b          	sext.w	a5,a5
ffffffe0002013d4:	fd07879b          	addiw	a5,a5,-48
ffffffe0002013d8:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002013dc:	0800006f          	j	ffffffe00020145c <strtol+0x1e4>
    } else if (*p >= 'a' && *p <= 'z') {
ffffffe0002013e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002013e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002013e8:	00078713          	mv	a4,a5
ffffffe0002013ec:	06000793          	li	a5,96
ffffffe0002013f0:	02e7f863          	bgeu	a5,a4,ffffffe000201420 <strtol+0x1a8>
ffffffe0002013f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002013f8:	0007c783          	lbu	a5,0(a5)
ffffffe0002013fc:	00078713          	mv	a4,a5
ffffffe000201400:	07a00793          	li	a5,122
ffffffe000201404:	00e7ee63          	bltu	a5,a4,ffffffe000201420 <strtol+0x1a8>
      digit = *p - ('a' - 10);
ffffffe000201408:	fd843783          	ld	a5,-40(s0)
ffffffe00020140c:	0007c783          	lbu	a5,0(a5)
ffffffe000201410:	0007879b          	sext.w	a5,a5
ffffffe000201414:	fa97879b          	addiw	a5,a5,-87
ffffffe000201418:	fcf42a23          	sw	a5,-44(s0)
ffffffe00020141c:	0400006f          	j	ffffffe00020145c <strtol+0x1e4>
    } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000201420:	fd843783          	ld	a5,-40(s0)
ffffffe000201424:	0007c783          	lbu	a5,0(a5)
ffffffe000201428:	00078713          	mv	a4,a5
ffffffe00020142c:	04000793          	li	a5,64
ffffffe000201430:	06e7f863          	bgeu	a5,a4,ffffffe0002014a0 <strtol+0x228>
ffffffe000201434:	fd843783          	ld	a5,-40(s0)
ffffffe000201438:	0007c783          	lbu	a5,0(a5)
ffffffe00020143c:	00078713          	mv	a4,a5
ffffffe000201440:	05a00793          	li	a5,90
ffffffe000201444:	04e7ee63          	bltu	a5,a4,ffffffe0002014a0 <strtol+0x228>
      digit = *p - ('A' - 10);
ffffffe000201448:	fd843783          	ld	a5,-40(s0)
ffffffe00020144c:	0007c783          	lbu	a5,0(a5)
ffffffe000201450:	0007879b          	sext.w	a5,a5
ffffffe000201454:	fc97879b          	addiw	a5,a5,-55
ffffffe000201458:	fcf42a23          	sw	a5,-44(s0)
    } else {
      break;
    }

    if (digit >= base) {
ffffffe00020145c:	fd442783          	lw	a5,-44(s0)
ffffffe000201460:	00078713          	mv	a4,a5
ffffffe000201464:	fbc42783          	lw	a5,-68(s0)
ffffffe000201468:	0007071b          	sext.w	a4,a4
ffffffe00020146c:	0007879b          	sext.w	a5,a5
ffffffe000201470:	02f75663          	bge	a4,a5,ffffffe00020149c <strtol+0x224>
      break;
    }

    ret = ret * base + digit;
ffffffe000201474:	fbc42703          	lw	a4,-68(s0)
ffffffe000201478:	fe843783          	ld	a5,-24(s0)
ffffffe00020147c:	02f70733          	mul	a4,a4,a5
ffffffe000201480:	fd442783          	lw	a5,-44(s0)
ffffffe000201484:	00f707b3          	add	a5,a4,a5
ffffffe000201488:	fef43423          	sd	a5,-24(s0)
    p++;
ffffffe00020148c:	fd843783          	ld	a5,-40(s0)
ffffffe000201490:	00178793          	addi	a5,a5,1
ffffffe000201494:	fcf43c23          	sd	a5,-40(s0)
  while (1) {
ffffffe000201498:	f09ff06f          	j	ffffffe0002013a0 <strtol+0x128>
      break;
ffffffe00020149c:	00000013          	nop
  }

  if (endptr) {
ffffffe0002014a0:	fc043783          	ld	a5,-64(s0)
ffffffe0002014a4:	00078863          	beqz	a5,ffffffe0002014b4 <strtol+0x23c>
    *endptr = (char *)p;
ffffffe0002014a8:	fc043783          	ld	a5,-64(s0)
ffffffe0002014ac:	fd843703          	ld	a4,-40(s0)
ffffffe0002014b0:	00e7b023          	sd	a4,0(a5)
  }

  return neg ? -ret : ret;
ffffffe0002014b4:	fe744783          	lbu	a5,-25(s0)
ffffffe0002014b8:	0ff7f793          	zext.b	a5,a5
ffffffe0002014bc:	00078863          	beqz	a5,ffffffe0002014cc <strtol+0x254>
ffffffe0002014c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002014c4:	40f007b3          	neg	a5,a5
ffffffe0002014c8:	0080006f          	j	ffffffe0002014d0 <strtol+0x258>
ffffffe0002014cc:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002014d0:	00078513          	mv	a0,a5
ffffffe0002014d4:	04813083          	ld	ra,72(sp)
ffffffe0002014d8:	04013403          	ld	s0,64(sp)
ffffffe0002014dc:	05010113          	addi	sp,sp,80
ffffffe0002014e0:	00008067          	ret

ffffffe0002014e4 <puts_wo_nl>:

// puts without newline
int puts_wo_nl(void (*putch)(char), const char *s) {
ffffffe0002014e4:	fd010113          	addi	sp,sp,-48
ffffffe0002014e8:	02113423          	sd	ra,40(sp)
ffffffe0002014ec:	02813023          	sd	s0,32(sp)
ffffffe0002014f0:	03010413          	addi	s0,sp,48
ffffffe0002014f4:	fca43c23          	sd	a0,-40(s0)
ffffffe0002014f8:	fcb43823          	sd	a1,-48(s0)
  if (!s) {
ffffffe0002014fc:	fd043783          	ld	a5,-48(s0)
ffffffe000201500:	00079e63          	bnez	a5,ffffffe00020151c <puts_wo_nl+0x38>
    return puts_wo_nl(putch, "(null)");
ffffffe000201504:	00002597          	auipc	a1,0x2
ffffffe000201508:	d3c58593          	addi	a1,a1,-708 # ffffffe000203240 <__func__.0+0x20>
ffffffe00020150c:	fd843503          	ld	a0,-40(s0)
ffffffe000201510:	fd5ff0ef          	jal	ra,ffffffe0002014e4 <puts_wo_nl>
ffffffe000201514:	00050793          	mv	a5,a0
ffffffe000201518:	0480006f          	j	ffffffe000201560 <puts_wo_nl+0x7c>
  }
  const char *p = s;
ffffffe00020151c:	fd043783          	ld	a5,-48(s0)
ffffffe000201520:	fef43423          	sd	a5,-24(s0)
  while (*p) {
ffffffe000201524:	0200006f          	j	ffffffe000201544 <puts_wo_nl+0x60>
    putch(*p++);
ffffffe000201528:	fe843783          	ld	a5,-24(s0)
ffffffe00020152c:	00178713          	addi	a4,a5,1
ffffffe000201530:	fee43423          	sd	a4,-24(s0)
ffffffe000201534:	0007c703          	lbu	a4,0(a5)
ffffffe000201538:	fd843783          	ld	a5,-40(s0)
ffffffe00020153c:	00070513          	mv	a0,a4
ffffffe000201540:	000780e7          	jalr	a5
  while (*p) {
ffffffe000201544:	fe843783          	ld	a5,-24(s0)
ffffffe000201548:	0007c783          	lbu	a5,0(a5)
ffffffe00020154c:	fc079ee3          	bnez	a5,ffffffe000201528 <puts_wo_nl+0x44>
  }
  return p - s;
ffffffe000201550:	fe843703          	ld	a4,-24(s0)
ffffffe000201554:	fd043783          	ld	a5,-48(s0)
ffffffe000201558:	40f707b3          	sub	a5,a4,a5
ffffffe00020155c:	0007879b          	sext.w	a5,a5
}
ffffffe000201560:	00078513          	mv	a0,a5
ffffffe000201564:	02813083          	ld	ra,40(sp)
ffffffe000201568:	02013403          	ld	s0,32(sp)
ffffffe00020156c:	03010113          	addi	sp,sp,48
ffffffe000201570:	00008067          	ret

ffffffe000201574 <puts>:

int puts(const char *s) {
ffffffe000201574:	fe010113          	addi	sp,sp,-32
ffffffe000201578:	00113c23          	sd	ra,24(sp)
ffffffe00020157c:	00813823          	sd	s0,16(sp)
ffffffe000201580:	02010413          	addi	s0,sp,32
ffffffe000201584:	fea43423          	sd	a0,-24(s0)
  puts_wo_nl(putchar, s);
ffffffe000201588:	fe843583          	ld	a1,-24(s0)
ffffffe00020158c:	00000517          	auipc	a0,0x0
ffffffe000201590:	c3c50513          	addi	a0,a0,-964 # ffffffe0002011c8 <putchar>
ffffffe000201594:	f51ff0ef          	jal	ra,ffffffe0002014e4 <puts_wo_nl>
  putchar('\n');
ffffffe000201598:	00a00513          	li	a0,10
ffffffe00020159c:	c2dff0ef          	jal	ra,ffffffe0002011c8 <putchar>
  return 0;
ffffffe0002015a0:	00000793          	li	a5,0
}
ffffffe0002015a4:	00078513          	mv	a0,a5
ffffffe0002015a8:	01813083          	ld	ra,24(sp)
ffffffe0002015ac:	01013403          	ld	s0,16(sp)
ffffffe0002015b0:	02010113          	addi	sp,sp,32
ffffffe0002015b4:	00008067          	ret

ffffffe0002015b8 <print_dec_int>:

static int print_dec_int(void (*putch)(char), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe0002015b8:	f9010113          	addi	sp,sp,-112
ffffffe0002015bc:	06113423          	sd	ra,104(sp)
ffffffe0002015c0:	06813023          	sd	s0,96(sp)
ffffffe0002015c4:	07010413          	addi	s0,sp,112
ffffffe0002015c8:	faa43423          	sd	a0,-88(s0)
ffffffe0002015cc:	fab43023          	sd	a1,-96(s0)
ffffffe0002015d0:	00060793          	mv	a5,a2
ffffffe0002015d4:	f8d43823          	sd	a3,-112(s0)
ffffffe0002015d8:	f8f40fa3          	sb	a5,-97(s0)
  if (is_signed && ((long)num == -(long)num)) {
ffffffe0002015dc:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002015e0:	0ff7f793          	zext.b	a5,a5
ffffffe0002015e4:	02078663          	beqz	a5,ffffffe000201610 <print_dec_int+0x58>
ffffffe0002015e8:	fa043783          	ld	a5,-96(s0)
ffffffe0002015ec:	40f00733          	neg	a4,a5
ffffffe0002015f0:	fa043783          	ld	a5,-96(s0)
ffffffe0002015f4:	00f71e63          	bne	a4,a5,ffffffe000201610 <print_dec_int+0x58>
    // special case for 0x8000000000000000
    return puts_wo_nl(putch, "-9223372036854775808");
ffffffe0002015f8:	00002597          	auipc	a1,0x2
ffffffe0002015fc:	c5058593          	addi	a1,a1,-944 # ffffffe000203248 <__func__.0+0x28>
ffffffe000201600:	fa843503          	ld	a0,-88(s0)
ffffffe000201604:	ee1ff0ef          	jal	ra,ffffffe0002014e4 <puts_wo_nl>
ffffffe000201608:	00050793          	mv	a5,a0
ffffffe00020160c:	29c0006f          	j	ffffffe0002018a8 <print_dec_int+0x2f0>
  }

  if (flags->prec == 0 && num == 0) {
ffffffe000201610:	f9043783          	ld	a5,-112(s0)
ffffffe000201614:	00c7a783          	lw	a5,12(a5)
ffffffe000201618:	00079a63          	bnez	a5,ffffffe00020162c <print_dec_int+0x74>
ffffffe00020161c:	fa043783          	ld	a5,-96(s0)
ffffffe000201620:	00079663          	bnez	a5,ffffffe00020162c <print_dec_int+0x74>
    return 0;
ffffffe000201624:	00000793          	li	a5,0
ffffffe000201628:	2800006f          	j	ffffffe0002018a8 <print_dec_int+0x2f0>
  }

  bool neg = false;
ffffffe00020162c:	fe0407a3          	sb	zero,-17(s0)

  if (is_signed && (long)num < 0) {
ffffffe000201630:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201634:	0ff7f793          	zext.b	a5,a5
ffffffe000201638:	02078063          	beqz	a5,ffffffe000201658 <print_dec_int+0xa0>
ffffffe00020163c:	fa043783          	ld	a5,-96(s0)
ffffffe000201640:	0007dc63          	bgez	a5,ffffffe000201658 <print_dec_int+0xa0>
    neg = true;
ffffffe000201644:	00100793          	li	a5,1
ffffffe000201648:	fef407a3          	sb	a5,-17(s0)
    num = -num;
ffffffe00020164c:	fa043783          	ld	a5,-96(s0)
ffffffe000201650:	40f007b3          	neg	a5,a5
ffffffe000201654:	faf43023          	sd	a5,-96(s0)
  }

  char buf[20];
  int decdigits = 0;
ffffffe000201658:	fe042423          	sw	zero,-24(s0)

  bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe00020165c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201660:	0ff7f793          	zext.b	a5,a5
ffffffe000201664:	02078863          	beqz	a5,ffffffe000201694 <print_dec_int+0xdc>
ffffffe000201668:	fef44783          	lbu	a5,-17(s0)
ffffffe00020166c:	0ff7f793          	zext.b	a5,a5
ffffffe000201670:	00079e63          	bnez	a5,ffffffe00020168c <print_dec_int+0xd4>
ffffffe000201674:	f9043783          	ld	a5,-112(s0)
ffffffe000201678:	0057c783          	lbu	a5,5(a5)
ffffffe00020167c:	00079863          	bnez	a5,ffffffe00020168c <print_dec_int+0xd4>
ffffffe000201680:	f9043783          	ld	a5,-112(s0)
ffffffe000201684:	0047c783          	lbu	a5,4(a5)
ffffffe000201688:	00078663          	beqz	a5,ffffffe000201694 <print_dec_int+0xdc>
ffffffe00020168c:	00100793          	li	a5,1
ffffffe000201690:	0080006f          	j	ffffffe000201698 <print_dec_int+0xe0>
ffffffe000201694:	00000793          	li	a5,0
ffffffe000201698:	fcf40ba3          	sb	a5,-41(s0)
ffffffe00020169c:	fd744783          	lbu	a5,-41(s0)
ffffffe0002016a0:	0017f793          	andi	a5,a5,1
ffffffe0002016a4:	fcf40ba3          	sb	a5,-41(s0)

  do {
    buf[decdigits++] = num % 10 + '0';
ffffffe0002016a8:	fa043703          	ld	a4,-96(s0)
ffffffe0002016ac:	00a00793          	li	a5,10
ffffffe0002016b0:	02f777b3          	remu	a5,a4,a5
ffffffe0002016b4:	0ff7f713          	zext.b	a4,a5
ffffffe0002016b8:	fe842783          	lw	a5,-24(s0)
ffffffe0002016bc:	0017869b          	addiw	a3,a5,1
ffffffe0002016c0:	fed42423          	sw	a3,-24(s0)
ffffffe0002016c4:	0307071b          	addiw	a4,a4,48
ffffffe0002016c8:	0ff77713          	zext.b	a4,a4
ffffffe0002016cc:	ff078793          	addi	a5,a5,-16
ffffffe0002016d0:	008787b3          	add	a5,a5,s0
ffffffe0002016d4:	fce78423          	sb	a4,-56(a5)
    num /= 10;
ffffffe0002016d8:	fa043703          	ld	a4,-96(s0)
ffffffe0002016dc:	00a00793          	li	a5,10
ffffffe0002016e0:	02f757b3          	divu	a5,a4,a5
ffffffe0002016e4:	faf43023          	sd	a5,-96(s0)
  } while (num);
ffffffe0002016e8:	fa043783          	ld	a5,-96(s0)
ffffffe0002016ec:	fa079ee3          	bnez	a5,ffffffe0002016a8 <print_dec_int+0xf0>

  if (flags->prec == -1 && flags->zeroflag) {
ffffffe0002016f0:	f9043783          	ld	a5,-112(s0)
ffffffe0002016f4:	00c7a783          	lw	a5,12(a5)
ffffffe0002016f8:	00078713          	mv	a4,a5
ffffffe0002016fc:	fff00793          	li	a5,-1
ffffffe000201700:	02f71063          	bne	a4,a5,ffffffe000201720 <print_dec_int+0x168>
ffffffe000201704:	f9043783          	ld	a5,-112(s0)
ffffffe000201708:	0037c783          	lbu	a5,3(a5)
ffffffe00020170c:	00078a63          	beqz	a5,ffffffe000201720 <print_dec_int+0x168>
    flags->prec = flags->width;
ffffffe000201710:	f9043783          	ld	a5,-112(s0)
ffffffe000201714:	0087a703          	lw	a4,8(a5)
ffffffe000201718:	f9043783          	ld	a5,-112(s0)
ffffffe00020171c:	00e7a623          	sw	a4,12(a5)
  }

  int written = 0;
ffffffe000201720:	fe042223          	sw	zero,-28(s0)

  for (int i = flags->width - max(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201724:	f9043783          	ld	a5,-112(s0)
ffffffe000201728:	0087a703          	lw	a4,8(a5)
ffffffe00020172c:	fe842783          	lw	a5,-24(s0)
ffffffe000201730:	fcf42823          	sw	a5,-48(s0)
ffffffe000201734:	f9043783          	ld	a5,-112(s0)
ffffffe000201738:	00c7a783          	lw	a5,12(a5)
ffffffe00020173c:	fcf42623          	sw	a5,-52(s0)
ffffffe000201740:	fd042783          	lw	a5,-48(s0)
ffffffe000201744:	00078593          	mv	a1,a5
ffffffe000201748:	fcc42783          	lw	a5,-52(s0)
ffffffe00020174c:	00078613          	mv	a2,a5
ffffffe000201750:	0006069b          	sext.w	a3,a2
ffffffe000201754:	0005879b          	sext.w	a5,a1
ffffffe000201758:	00f6d463          	bge	a3,a5,ffffffe000201760 <print_dec_int+0x1a8>
ffffffe00020175c:	00058613          	mv	a2,a1
ffffffe000201760:	0006079b          	sext.w	a5,a2
ffffffe000201764:	40f707bb          	subw	a5,a4,a5
ffffffe000201768:	0007871b          	sext.w	a4,a5
ffffffe00020176c:	fd744783          	lbu	a5,-41(s0)
ffffffe000201770:	0007879b          	sext.w	a5,a5
ffffffe000201774:	40f707bb          	subw	a5,a4,a5
ffffffe000201778:	fef42023          	sw	a5,-32(s0)
ffffffe00020177c:	0280006f          	j	ffffffe0002017a4 <print_dec_int+0x1ec>
    putch(' ');
ffffffe000201780:	fa843783          	ld	a5,-88(s0)
ffffffe000201784:	02000513          	li	a0,32
ffffffe000201788:	000780e7          	jalr	a5
    ++written;
ffffffe00020178c:	fe442783          	lw	a5,-28(s0)
ffffffe000201790:	0017879b          	addiw	a5,a5,1
ffffffe000201794:	fef42223          	sw	a5,-28(s0)
  for (int i = flags->width - max(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201798:	fe042783          	lw	a5,-32(s0)
ffffffe00020179c:	fff7879b          	addiw	a5,a5,-1
ffffffe0002017a0:	fef42023          	sw	a5,-32(s0)
ffffffe0002017a4:	fe042783          	lw	a5,-32(s0)
ffffffe0002017a8:	0007879b          	sext.w	a5,a5
ffffffe0002017ac:	fcf04ae3          	bgtz	a5,ffffffe000201780 <print_dec_int+0x1c8>
  }

  if (has_sign_char) {
ffffffe0002017b0:	fd744783          	lbu	a5,-41(s0)
ffffffe0002017b4:	0ff7f793          	zext.b	a5,a5
ffffffe0002017b8:	04078463          	beqz	a5,ffffffe000201800 <print_dec_int+0x248>
    putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe0002017bc:	fef44783          	lbu	a5,-17(s0)
ffffffe0002017c0:	0ff7f793          	zext.b	a5,a5
ffffffe0002017c4:	00078663          	beqz	a5,ffffffe0002017d0 <print_dec_int+0x218>
ffffffe0002017c8:	02d00793          	li	a5,45
ffffffe0002017cc:	01c0006f          	j	ffffffe0002017e8 <print_dec_int+0x230>
ffffffe0002017d0:	f9043783          	ld	a5,-112(s0)
ffffffe0002017d4:	0057c783          	lbu	a5,5(a5)
ffffffe0002017d8:	00078663          	beqz	a5,ffffffe0002017e4 <print_dec_int+0x22c>
ffffffe0002017dc:	02b00793          	li	a5,43
ffffffe0002017e0:	0080006f          	j	ffffffe0002017e8 <print_dec_int+0x230>
ffffffe0002017e4:	02000793          	li	a5,32
ffffffe0002017e8:	fa843703          	ld	a4,-88(s0)
ffffffe0002017ec:	00078513          	mv	a0,a5
ffffffe0002017f0:	000700e7          	jalr	a4
    ++written;
ffffffe0002017f4:	fe442783          	lw	a5,-28(s0)
ffffffe0002017f8:	0017879b          	addiw	a5,a5,1
ffffffe0002017fc:	fef42223          	sw	a5,-28(s0)
  }

  for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000201800:	fe842783          	lw	a5,-24(s0)
ffffffe000201804:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201808:	0280006f          	j	ffffffe000201830 <print_dec_int+0x278>
    putch('0');
ffffffe00020180c:	fa843783          	ld	a5,-88(s0)
ffffffe000201810:	03000513          	li	a0,48
ffffffe000201814:	000780e7          	jalr	a5
    ++written;
ffffffe000201818:	fe442783          	lw	a5,-28(s0)
ffffffe00020181c:	0017879b          	addiw	a5,a5,1
ffffffe000201820:	fef42223          	sw	a5,-28(s0)
  for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000201824:	fdc42783          	lw	a5,-36(s0)
ffffffe000201828:	0017879b          	addiw	a5,a5,1
ffffffe00020182c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201830:	f9043783          	ld	a5,-112(s0)
ffffffe000201834:	00c7a703          	lw	a4,12(a5)
ffffffe000201838:	fd744783          	lbu	a5,-41(s0)
ffffffe00020183c:	0007879b          	sext.w	a5,a5
ffffffe000201840:	40f707bb          	subw	a5,a4,a5
ffffffe000201844:	0007871b          	sext.w	a4,a5
ffffffe000201848:	fdc42783          	lw	a5,-36(s0)
ffffffe00020184c:	0007879b          	sext.w	a5,a5
ffffffe000201850:	fae7cee3          	blt	a5,a4,ffffffe00020180c <print_dec_int+0x254>
  }

  for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000201854:	fe842783          	lw	a5,-24(s0)
ffffffe000201858:	fff7879b          	addiw	a5,a5,-1
ffffffe00020185c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201860:	0380006f          	j	ffffffe000201898 <print_dec_int+0x2e0>
    putch(buf[i]);
ffffffe000201864:	fd842783          	lw	a5,-40(s0)
ffffffe000201868:	ff078793          	addi	a5,a5,-16
ffffffe00020186c:	008787b3          	add	a5,a5,s0
ffffffe000201870:	fc87c703          	lbu	a4,-56(a5)
ffffffe000201874:	fa843783          	ld	a5,-88(s0)
ffffffe000201878:	00070513          	mv	a0,a4
ffffffe00020187c:	000780e7          	jalr	a5
    ++written;
ffffffe000201880:	fe442783          	lw	a5,-28(s0)
ffffffe000201884:	0017879b          	addiw	a5,a5,1
ffffffe000201888:	fef42223          	sw	a5,-28(s0)
  for (int i = decdigits - 1; i >= 0; i--) {
ffffffe00020188c:	fd842783          	lw	a5,-40(s0)
ffffffe000201890:	fff7879b          	addiw	a5,a5,-1
ffffffe000201894:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201898:	fd842783          	lw	a5,-40(s0)
ffffffe00020189c:	0007879b          	sext.w	a5,a5
ffffffe0002018a0:	fc07d2e3          	bgez	a5,ffffffe000201864 <print_dec_int+0x2ac>
  }

  return written;
ffffffe0002018a4:	fe442783          	lw	a5,-28(s0)
}
ffffffe0002018a8:	00078513          	mv	a0,a5
ffffffe0002018ac:	06813083          	ld	ra,104(sp)
ffffffe0002018b0:	06013403          	ld	s0,96(sp)
ffffffe0002018b4:	07010113          	addi	sp,sp,112
ffffffe0002018b8:	00008067          	ret

ffffffe0002018bc <vprintfmt>:

static int vprintfmt(void (*putch)(char), const char *fmt, va_list vl) {
ffffffe0002018bc:	f3010113          	addi	sp,sp,-208
ffffffe0002018c0:	0c113423          	sd	ra,200(sp)
ffffffe0002018c4:	0c813023          	sd	s0,192(sp)
ffffffe0002018c8:	0d010413          	addi	s0,sp,208
ffffffe0002018cc:	f4a43423          	sd	a0,-184(s0)
ffffffe0002018d0:	f4b43023          	sd	a1,-192(s0)
ffffffe0002018d4:	f2c43c23          	sd	a2,-200(s0)
  struct fmt_flags flags;
  flags.in_format = false;
ffffffe0002018d8:	f6040c23          	sb	zero,-136(s0)
  static const char lowerxdigits[] = "0123456789abcdef";
  static const char upperxdigits[] = "0123456789ABCDEF";

  int written = 0;
ffffffe0002018dc:	fe042623          	sw	zero,-20(s0)

  for (; *fmt; fmt++) {
ffffffe0002018e0:	7780006f          	j	ffffffe000202058 <vprintfmt+0x79c>
    if (flags.in_format) {
ffffffe0002018e4:	f7844783          	lbu	a5,-136(s0)
ffffffe0002018e8:	70078a63          	beqz	a5,ffffffe000201ffc <vprintfmt+0x740>
      if (*fmt == '#') {
ffffffe0002018ec:	f4043783          	ld	a5,-192(s0)
ffffffe0002018f0:	0007c783          	lbu	a5,0(a5)
ffffffe0002018f4:	00078713          	mv	a4,a5
ffffffe0002018f8:	02300793          	li	a5,35
ffffffe0002018fc:	00f71863          	bne	a4,a5,ffffffe00020190c <vprintfmt+0x50>
        flags.sharpflag = true;
ffffffe000201900:	00100793          	li	a5,1
ffffffe000201904:	f6f40d23          	sb	a5,-134(s0)
ffffffe000201908:	7440006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == '0') {
ffffffe00020190c:	f4043783          	ld	a5,-192(s0)
ffffffe000201910:	0007c783          	lbu	a5,0(a5)
ffffffe000201914:	00078713          	mv	a4,a5
ffffffe000201918:	03000793          	li	a5,48
ffffffe00020191c:	00f71863          	bne	a4,a5,ffffffe00020192c <vprintfmt+0x70>
        flags.zeroflag = true;
ffffffe000201920:	00100793          	li	a5,1
ffffffe000201924:	f6f40da3          	sb	a5,-133(s0)
ffffffe000201928:	7240006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe00020192c:	f4043783          	ld	a5,-192(s0)
ffffffe000201930:	0007c783          	lbu	a5,0(a5)
ffffffe000201934:	00078713          	mv	a4,a5
ffffffe000201938:	06c00793          	li	a5,108
ffffffe00020193c:	04f70063          	beq	a4,a5,ffffffe00020197c <vprintfmt+0xc0>
ffffffe000201940:	f4043783          	ld	a5,-192(s0)
ffffffe000201944:	0007c783          	lbu	a5,0(a5)
ffffffe000201948:	00078713          	mv	a4,a5
ffffffe00020194c:	07a00793          	li	a5,122
ffffffe000201950:	02f70663          	beq	a4,a5,ffffffe00020197c <vprintfmt+0xc0>
ffffffe000201954:	f4043783          	ld	a5,-192(s0)
ffffffe000201958:	0007c783          	lbu	a5,0(a5)
ffffffe00020195c:	00078713          	mv	a4,a5
ffffffe000201960:	07400793          	li	a5,116
ffffffe000201964:	00f70c63          	beq	a4,a5,ffffffe00020197c <vprintfmt+0xc0>
ffffffe000201968:	f4043783          	ld	a5,-192(s0)
ffffffe00020196c:	0007c783          	lbu	a5,0(a5)
ffffffe000201970:	00078713          	mv	a4,a5
ffffffe000201974:	06a00793          	li	a5,106
ffffffe000201978:	00f71863          	bne	a4,a5,ffffffe000201988 <vprintfmt+0xcc>
        // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
        flags.longflag = true;
ffffffe00020197c:	00100793          	li	a5,1
ffffffe000201980:	f6f40ca3          	sb	a5,-135(s0)
ffffffe000201984:	6c80006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == '+') {
ffffffe000201988:	f4043783          	ld	a5,-192(s0)
ffffffe00020198c:	0007c783          	lbu	a5,0(a5)
ffffffe000201990:	00078713          	mv	a4,a5
ffffffe000201994:	02b00793          	li	a5,43
ffffffe000201998:	00f71863          	bne	a4,a5,ffffffe0002019a8 <vprintfmt+0xec>
        flags.sign = true;
ffffffe00020199c:	00100793          	li	a5,1
ffffffe0002019a0:	f6f40ea3          	sb	a5,-131(s0)
ffffffe0002019a4:	6a80006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == ' ') {
ffffffe0002019a8:	f4043783          	ld	a5,-192(s0)
ffffffe0002019ac:	0007c783          	lbu	a5,0(a5)
ffffffe0002019b0:	00078713          	mv	a4,a5
ffffffe0002019b4:	02000793          	li	a5,32
ffffffe0002019b8:	00f71863          	bne	a4,a5,ffffffe0002019c8 <vprintfmt+0x10c>
        flags.spaceflag = true;
ffffffe0002019bc:	00100793          	li	a5,1
ffffffe0002019c0:	f6f40e23          	sb	a5,-132(s0)
ffffffe0002019c4:	6880006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe0002019c8:	f4043783          	ld	a5,-192(s0)
ffffffe0002019cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002019d0:	00078713          	mv	a4,a5
ffffffe0002019d4:	03000793          	li	a5,48
ffffffe0002019d8:	04e7f663          	bgeu	a5,a4,ffffffe000201a24 <vprintfmt+0x168>
ffffffe0002019dc:	f4043783          	ld	a5,-192(s0)
ffffffe0002019e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002019e4:	00078713          	mv	a4,a5
ffffffe0002019e8:	03900793          	li	a5,57
ffffffe0002019ec:	02e7ec63          	bltu	a5,a4,ffffffe000201a24 <vprintfmt+0x168>
        flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe0002019f0:	f4043783          	ld	a5,-192(s0)
ffffffe0002019f4:	f4040713          	addi	a4,s0,-192
ffffffe0002019f8:	00a00613          	li	a2,10
ffffffe0002019fc:	00070593          	mv	a1,a4
ffffffe000201a00:	00078513          	mv	a0,a5
ffffffe000201a04:	875ff0ef          	jal	ra,ffffffe000201278 <strtol>
ffffffe000201a08:	00050793          	mv	a5,a0
ffffffe000201a0c:	0007879b          	sext.w	a5,a5
ffffffe000201a10:	f8f42023          	sw	a5,-128(s0)
        fmt--;
ffffffe000201a14:	f4043783          	ld	a5,-192(s0)
ffffffe000201a18:	fff78793          	addi	a5,a5,-1
ffffffe000201a1c:	f4f43023          	sd	a5,-192(s0)
ffffffe000201a20:	62c0006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == '.') {
ffffffe000201a24:	f4043783          	ld	a5,-192(s0)
ffffffe000201a28:	0007c783          	lbu	a5,0(a5)
ffffffe000201a2c:	00078713          	mv	a4,a5
ffffffe000201a30:	02e00793          	li	a5,46
ffffffe000201a34:	02f71e63          	bne	a4,a5,ffffffe000201a70 <vprintfmt+0x1b4>
        flags.prec = strtol(fmt + 1, (char **)&fmt, 10);
ffffffe000201a38:	f4043783          	ld	a5,-192(s0)
ffffffe000201a3c:	00178793          	addi	a5,a5,1
ffffffe000201a40:	f4040713          	addi	a4,s0,-192
ffffffe000201a44:	00a00613          	li	a2,10
ffffffe000201a48:	00070593          	mv	a1,a4
ffffffe000201a4c:	00078513          	mv	a0,a5
ffffffe000201a50:	829ff0ef          	jal	ra,ffffffe000201278 <strtol>
ffffffe000201a54:	00050793          	mv	a5,a0
ffffffe000201a58:	0007879b          	sext.w	a5,a5
ffffffe000201a5c:	f8f42223          	sw	a5,-124(s0)
        fmt--;
ffffffe000201a60:	f4043783          	ld	a5,-192(s0)
ffffffe000201a64:	fff78793          	addi	a5,a5,-1
ffffffe000201a68:	f4f43023          	sd	a5,-192(s0)
ffffffe000201a6c:	5e00006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000201a70:	f4043783          	ld	a5,-192(s0)
ffffffe000201a74:	0007c783          	lbu	a5,0(a5)
ffffffe000201a78:	00078713          	mv	a4,a5
ffffffe000201a7c:	07800793          	li	a5,120
ffffffe000201a80:	02f70663          	beq	a4,a5,ffffffe000201aac <vprintfmt+0x1f0>
ffffffe000201a84:	f4043783          	ld	a5,-192(s0)
ffffffe000201a88:	0007c783          	lbu	a5,0(a5)
ffffffe000201a8c:	00078713          	mv	a4,a5
ffffffe000201a90:	05800793          	li	a5,88
ffffffe000201a94:	00f70c63          	beq	a4,a5,ffffffe000201aac <vprintfmt+0x1f0>
ffffffe000201a98:	f4043783          	ld	a5,-192(s0)
ffffffe000201a9c:	0007c783          	lbu	a5,0(a5)
ffffffe000201aa0:	00078713          	mv	a4,a5
ffffffe000201aa4:	07000793          	li	a5,112
ffffffe000201aa8:	30f71063          	bne	a4,a5,ffffffe000201da8 <vprintfmt+0x4ec>
        bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000201aac:	f4043783          	ld	a5,-192(s0)
ffffffe000201ab0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ab4:	00078713          	mv	a4,a5
ffffffe000201ab8:	07000793          	li	a5,112
ffffffe000201abc:	00f70663          	beq	a4,a5,ffffffe000201ac8 <vprintfmt+0x20c>
ffffffe000201ac0:	f7944783          	lbu	a5,-135(s0)
ffffffe000201ac4:	00078663          	beqz	a5,ffffffe000201ad0 <vprintfmt+0x214>
ffffffe000201ac8:	00100793          	li	a5,1
ffffffe000201acc:	0080006f          	j	ffffffe000201ad4 <vprintfmt+0x218>
ffffffe000201ad0:	00000793          	li	a5,0
ffffffe000201ad4:	f8f40fa3          	sb	a5,-97(s0)
ffffffe000201ad8:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201adc:	0017f793          	andi	a5,a5,1
ffffffe000201ae0:	f8f40fa3          	sb	a5,-97(s0)

        unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000201ae4:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201ae8:	0ff7f793          	zext.b	a5,a5
ffffffe000201aec:	00078c63          	beqz	a5,ffffffe000201b04 <vprintfmt+0x248>
ffffffe000201af0:	f3843783          	ld	a5,-200(s0)
ffffffe000201af4:	00878713          	addi	a4,a5,8
ffffffe000201af8:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201afc:	0007b783          	ld	a5,0(a5)
ffffffe000201b00:	01c0006f          	j	ffffffe000201b1c <vprintfmt+0x260>
ffffffe000201b04:	f3843783          	ld	a5,-200(s0)
ffffffe000201b08:	00878713          	addi	a4,a5,8
ffffffe000201b0c:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201b10:	0007a783          	lw	a5,0(a5)
ffffffe000201b14:	02079793          	slli	a5,a5,0x20
ffffffe000201b18:	0207d793          	srli	a5,a5,0x20
ffffffe000201b1c:	fef43023          	sd	a5,-32(s0)

        if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000201b20:	f8442783          	lw	a5,-124(s0)
ffffffe000201b24:	02079463          	bnez	a5,ffffffe000201b4c <vprintfmt+0x290>
ffffffe000201b28:	fe043783          	ld	a5,-32(s0)
ffffffe000201b2c:	02079063          	bnez	a5,ffffffe000201b4c <vprintfmt+0x290>
ffffffe000201b30:	f4043783          	ld	a5,-192(s0)
ffffffe000201b34:	0007c783          	lbu	a5,0(a5)
ffffffe000201b38:	00078713          	mv	a4,a5
ffffffe000201b3c:	07000793          	li	a5,112
ffffffe000201b40:	00f70663          	beq	a4,a5,ffffffe000201b4c <vprintfmt+0x290>
          flags.in_format = false;
ffffffe000201b44:	f6040c23          	sb	zero,-136(s0)
ffffffe000201b48:	5040006f          	j	ffffffe00020204c <vprintfmt+0x790>
          continue;
        }

        // 0x prefix for pointers, or, if # flag is set and non-zero
        bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000201b4c:	f4043783          	ld	a5,-192(s0)
ffffffe000201b50:	0007c783          	lbu	a5,0(a5)
ffffffe000201b54:	00078713          	mv	a4,a5
ffffffe000201b58:	07000793          	li	a5,112
ffffffe000201b5c:	00f70a63          	beq	a4,a5,ffffffe000201b70 <vprintfmt+0x2b4>
ffffffe000201b60:	f7a44783          	lbu	a5,-134(s0)
ffffffe000201b64:	00078a63          	beqz	a5,ffffffe000201b78 <vprintfmt+0x2bc>
ffffffe000201b68:	fe043783          	ld	a5,-32(s0)
ffffffe000201b6c:	00078663          	beqz	a5,ffffffe000201b78 <vprintfmt+0x2bc>
ffffffe000201b70:	00100793          	li	a5,1
ffffffe000201b74:	0080006f          	j	ffffffe000201b7c <vprintfmt+0x2c0>
ffffffe000201b78:	00000793          	li	a5,0
ffffffe000201b7c:	f8f40f23          	sb	a5,-98(s0)
ffffffe000201b80:	f9e44783          	lbu	a5,-98(s0)
ffffffe000201b84:	0017f793          	andi	a5,a5,1
ffffffe000201b88:	f8f40f23          	sb	a5,-98(s0)

        int hexdigits = 0;
ffffffe000201b8c:	fc042e23          	sw	zero,-36(s0)
        const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000201b90:	f4043783          	ld	a5,-192(s0)
ffffffe000201b94:	0007c783          	lbu	a5,0(a5)
ffffffe000201b98:	00078713          	mv	a4,a5
ffffffe000201b9c:	05800793          	li	a5,88
ffffffe000201ba0:	00f71863          	bne	a4,a5,ffffffe000201bb0 <vprintfmt+0x2f4>
ffffffe000201ba4:	00001797          	auipc	a5,0x1
ffffffe000201ba8:	6bc78793          	addi	a5,a5,1724 # ffffffe000203260 <upperxdigits.1>
ffffffe000201bac:	00c0006f          	j	ffffffe000201bb8 <vprintfmt+0x2fc>
ffffffe000201bb0:	00001797          	auipc	a5,0x1
ffffffe000201bb4:	6c878793          	addi	a5,a5,1736 # ffffffe000203278 <lowerxdigits.0>
ffffffe000201bb8:	f8f43823          	sd	a5,-112(s0)
        char buf[2 * sizeof(unsigned long)];

        do {
          buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000201bbc:	fe043783          	ld	a5,-32(s0)
ffffffe000201bc0:	00f7f793          	andi	a5,a5,15
ffffffe000201bc4:	f9043703          	ld	a4,-112(s0)
ffffffe000201bc8:	00f70733          	add	a4,a4,a5
ffffffe000201bcc:	fdc42783          	lw	a5,-36(s0)
ffffffe000201bd0:	0017869b          	addiw	a3,a5,1
ffffffe000201bd4:	fcd42e23          	sw	a3,-36(s0)
ffffffe000201bd8:	00074703          	lbu	a4,0(a4)
ffffffe000201bdc:	ff078793          	addi	a5,a5,-16
ffffffe000201be0:	008787b3          	add	a5,a5,s0
ffffffe000201be4:	f6e78c23          	sb	a4,-136(a5)
          num >>= 4;
ffffffe000201be8:	fe043783          	ld	a5,-32(s0)
ffffffe000201bec:	0047d793          	srli	a5,a5,0x4
ffffffe000201bf0:	fef43023          	sd	a5,-32(s0)
        } while (num);
ffffffe000201bf4:	fe043783          	ld	a5,-32(s0)
ffffffe000201bf8:	fc0792e3          	bnez	a5,ffffffe000201bbc <vprintfmt+0x300>

        if (flags.prec == -1 && flags.zeroflag) {
ffffffe000201bfc:	f8442783          	lw	a5,-124(s0)
ffffffe000201c00:	00078713          	mv	a4,a5
ffffffe000201c04:	fff00793          	li	a5,-1
ffffffe000201c08:	02f71663          	bne	a4,a5,ffffffe000201c34 <vprintfmt+0x378>
ffffffe000201c0c:	f7b44783          	lbu	a5,-133(s0)
ffffffe000201c10:	02078263          	beqz	a5,ffffffe000201c34 <vprintfmt+0x378>
          flags.prec = flags.width - 2 * prefix;
ffffffe000201c14:	f8042703          	lw	a4,-128(s0)
ffffffe000201c18:	f9e44783          	lbu	a5,-98(s0)
ffffffe000201c1c:	0007879b          	sext.w	a5,a5
ffffffe000201c20:	0017979b          	slliw	a5,a5,0x1
ffffffe000201c24:	0007879b          	sext.w	a5,a5
ffffffe000201c28:	40f707bb          	subw	a5,a4,a5
ffffffe000201c2c:	0007879b          	sext.w	a5,a5
ffffffe000201c30:	f8f42223          	sw	a5,-124(s0)
        }

        for (int i = flags.width - 2 * prefix - max(hexdigits, flags.prec); i > 0; i--) {
ffffffe000201c34:	f8042703          	lw	a4,-128(s0)
ffffffe000201c38:	f9e44783          	lbu	a5,-98(s0)
ffffffe000201c3c:	0007879b          	sext.w	a5,a5
ffffffe000201c40:	0017979b          	slliw	a5,a5,0x1
ffffffe000201c44:	0007879b          	sext.w	a5,a5
ffffffe000201c48:	40f707bb          	subw	a5,a4,a5
ffffffe000201c4c:	0007871b          	sext.w	a4,a5
ffffffe000201c50:	fdc42783          	lw	a5,-36(s0)
ffffffe000201c54:	f8f42623          	sw	a5,-116(s0)
ffffffe000201c58:	f8442783          	lw	a5,-124(s0)
ffffffe000201c5c:	f8f42423          	sw	a5,-120(s0)
ffffffe000201c60:	f8c42783          	lw	a5,-116(s0)
ffffffe000201c64:	00078593          	mv	a1,a5
ffffffe000201c68:	f8842783          	lw	a5,-120(s0)
ffffffe000201c6c:	00078613          	mv	a2,a5
ffffffe000201c70:	0006069b          	sext.w	a3,a2
ffffffe000201c74:	0005879b          	sext.w	a5,a1
ffffffe000201c78:	00f6d463          	bge	a3,a5,ffffffe000201c80 <vprintfmt+0x3c4>
ffffffe000201c7c:	00058613          	mv	a2,a1
ffffffe000201c80:	0006079b          	sext.w	a5,a2
ffffffe000201c84:	40f707bb          	subw	a5,a4,a5
ffffffe000201c88:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201c8c:	0280006f          	j	ffffffe000201cb4 <vprintfmt+0x3f8>
          putch(' ');
ffffffe000201c90:	f4843783          	ld	a5,-184(s0)
ffffffe000201c94:	02000513          	li	a0,32
ffffffe000201c98:	000780e7          	jalr	a5
          ++written;
ffffffe000201c9c:	fec42783          	lw	a5,-20(s0)
ffffffe000201ca0:	0017879b          	addiw	a5,a5,1
ffffffe000201ca4:	fef42623          	sw	a5,-20(s0)
        for (int i = flags.width - 2 * prefix - max(hexdigits, flags.prec); i > 0; i--) {
ffffffe000201ca8:	fd842783          	lw	a5,-40(s0)
ffffffe000201cac:	fff7879b          	addiw	a5,a5,-1
ffffffe000201cb0:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201cb4:	fd842783          	lw	a5,-40(s0)
ffffffe000201cb8:	0007879b          	sext.w	a5,a5
ffffffe000201cbc:	fcf04ae3          	bgtz	a5,ffffffe000201c90 <vprintfmt+0x3d4>
        }

        if (prefix) {
ffffffe000201cc0:	f9e44783          	lbu	a5,-98(s0)
ffffffe000201cc4:	0ff7f793          	zext.b	a5,a5
ffffffe000201cc8:	04078463          	beqz	a5,ffffffe000201d10 <vprintfmt+0x454>
          putch('0');
ffffffe000201ccc:	f4843783          	ld	a5,-184(s0)
ffffffe000201cd0:	03000513          	li	a0,48
ffffffe000201cd4:	000780e7          	jalr	a5
          putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000201cd8:	f4043783          	ld	a5,-192(s0)
ffffffe000201cdc:	0007c783          	lbu	a5,0(a5)
ffffffe000201ce0:	00078713          	mv	a4,a5
ffffffe000201ce4:	05800793          	li	a5,88
ffffffe000201ce8:	00f71663          	bne	a4,a5,ffffffe000201cf4 <vprintfmt+0x438>
ffffffe000201cec:	05800793          	li	a5,88
ffffffe000201cf0:	0080006f          	j	ffffffe000201cf8 <vprintfmt+0x43c>
ffffffe000201cf4:	07800793          	li	a5,120
ffffffe000201cf8:	f4843703          	ld	a4,-184(s0)
ffffffe000201cfc:	00078513          	mv	a0,a5
ffffffe000201d00:	000700e7          	jalr	a4
          written += 2;
ffffffe000201d04:	fec42783          	lw	a5,-20(s0)
ffffffe000201d08:	0027879b          	addiw	a5,a5,2
ffffffe000201d0c:	fef42623          	sw	a5,-20(s0)
        }

        for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000201d10:	fdc42783          	lw	a5,-36(s0)
ffffffe000201d14:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201d18:	0280006f          	j	ffffffe000201d40 <vprintfmt+0x484>
          putch('0');
ffffffe000201d1c:	f4843783          	ld	a5,-184(s0)
ffffffe000201d20:	03000513          	li	a0,48
ffffffe000201d24:	000780e7          	jalr	a5
          ++written;
ffffffe000201d28:	fec42783          	lw	a5,-20(s0)
ffffffe000201d2c:	0017879b          	addiw	a5,a5,1
ffffffe000201d30:	fef42623          	sw	a5,-20(s0)
        for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000201d34:	fd442783          	lw	a5,-44(s0)
ffffffe000201d38:	0017879b          	addiw	a5,a5,1
ffffffe000201d3c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201d40:	f8442703          	lw	a4,-124(s0)
ffffffe000201d44:	fd442783          	lw	a5,-44(s0)
ffffffe000201d48:	0007879b          	sext.w	a5,a5
ffffffe000201d4c:	fce7c8e3          	blt	a5,a4,ffffffe000201d1c <vprintfmt+0x460>
        }

        for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000201d50:	fdc42783          	lw	a5,-36(s0)
ffffffe000201d54:	fff7879b          	addiw	a5,a5,-1
ffffffe000201d58:	fcf42823          	sw	a5,-48(s0)
ffffffe000201d5c:	0380006f          	j	ffffffe000201d94 <vprintfmt+0x4d8>
          putch(buf[i]);
ffffffe000201d60:	fd042783          	lw	a5,-48(s0)
ffffffe000201d64:	ff078793          	addi	a5,a5,-16
ffffffe000201d68:	008787b3          	add	a5,a5,s0
ffffffe000201d6c:	f787c703          	lbu	a4,-136(a5)
ffffffe000201d70:	f4843783          	ld	a5,-184(s0)
ffffffe000201d74:	00070513          	mv	a0,a4
ffffffe000201d78:	000780e7          	jalr	a5
          ++written;
ffffffe000201d7c:	fec42783          	lw	a5,-20(s0)
ffffffe000201d80:	0017879b          	addiw	a5,a5,1
ffffffe000201d84:	fef42623          	sw	a5,-20(s0)
        for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000201d88:	fd042783          	lw	a5,-48(s0)
ffffffe000201d8c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201d90:	fcf42823          	sw	a5,-48(s0)
ffffffe000201d94:	fd042783          	lw	a5,-48(s0)
ffffffe000201d98:	0007879b          	sext.w	a5,a5
ffffffe000201d9c:	fc07d2e3          	bgez	a5,ffffffe000201d60 <vprintfmt+0x4a4>
        }

        flags.in_format = false;
ffffffe000201da0:	f6040c23          	sb	zero,-136(s0)
      } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000201da4:	2a80006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == 'd') {
ffffffe000201da8:	f4043783          	ld	a5,-192(s0)
ffffffe000201dac:	0007c783          	lbu	a5,0(a5)
ffffffe000201db0:	00078713          	mv	a4,a5
ffffffe000201db4:	06400793          	li	a5,100
ffffffe000201db8:	06f71463          	bne	a4,a5,ffffffe000201e20 <vprintfmt+0x564>
        long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201dbc:	f7944783          	lbu	a5,-135(s0)
ffffffe000201dc0:	00078c63          	beqz	a5,ffffffe000201dd8 <vprintfmt+0x51c>
ffffffe000201dc4:	f3843783          	ld	a5,-200(s0)
ffffffe000201dc8:	00878713          	addi	a4,a5,8
ffffffe000201dcc:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201dd0:	0007b783          	ld	a5,0(a5)
ffffffe000201dd4:	0140006f          	j	ffffffe000201de8 <vprintfmt+0x52c>
ffffffe000201dd8:	f3843783          	ld	a5,-200(s0)
ffffffe000201ddc:	00878713          	addi	a4,a5,8
ffffffe000201de0:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201de4:	0007a783          	lw	a5,0(a5)
ffffffe000201de8:	faf43023          	sd	a5,-96(s0)

        written += print_dec_int(putch, num, true, &flags);
ffffffe000201dec:	fa043783          	ld	a5,-96(s0)
ffffffe000201df0:	f7840713          	addi	a4,s0,-136
ffffffe000201df4:	00070693          	mv	a3,a4
ffffffe000201df8:	00100613          	li	a2,1
ffffffe000201dfc:	00078593          	mv	a1,a5
ffffffe000201e00:	f4843503          	ld	a0,-184(s0)
ffffffe000201e04:	fb4ff0ef          	jal	ra,ffffffe0002015b8 <print_dec_int>
ffffffe000201e08:	00050793          	mv	a5,a0
ffffffe000201e0c:	fec42703          	lw	a4,-20(s0)
ffffffe000201e10:	00f707bb          	addw	a5,a4,a5
ffffffe000201e14:	fef42623          	sw	a5,-20(s0)
        flags.in_format = false;
ffffffe000201e18:	f6040c23          	sb	zero,-136(s0)
ffffffe000201e1c:	2300006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == 'u') {
ffffffe000201e20:	f4043783          	ld	a5,-192(s0)
ffffffe000201e24:	0007c783          	lbu	a5,0(a5)
ffffffe000201e28:	00078713          	mv	a4,a5
ffffffe000201e2c:	07500793          	li	a5,117
ffffffe000201e30:	06f71663          	bne	a4,a5,ffffffe000201e9c <vprintfmt+0x5e0>
        unsigned long num = flags.longflag ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000201e34:	f7944783          	lbu	a5,-135(s0)
ffffffe000201e38:	00078c63          	beqz	a5,ffffffe000201e50 <vprintfmt+0x594>
ffffffe000201e3c:	f3843783          	ld	a5,-200(s0)
ffffffe000201e40:	00878713          	addi	a4,a5,8
ffffffe000201e44:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201e48:	0007b783          	ld	a5,0(a5)
ffffffe000201e4c:	01c0006f          	j	ffffffe000201e68 <vprintfmt+0x5ac>
ffffffe000201e50:	f3843783          	ld	a5,-200(s0)
ffffffe000201e54:	00878713          	addi	a4,a5,8
ffffffe000201e58:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201e5c:	0007a783          	lw	a5,0(a5)
ffffffe000201e60:	02079793          	slli	a5,a5,0x20
ffffffe000201e64:	0207d793          	srli	a5,a5,0x20
ffffffe000201e68:	faf43423          	sd	a5,-88(s0)

        written += print_dec_int(putch, num, false, &flags);
ffffffe000201e6c:	f7840793          	addi	a5,s0,-136
ffffffe000201e70:	00078693          	mv	a3,a5
ffffffe000201e74:	00000613          	li	a2,0
ffffffe000201e78:	fa843583          	ld	a1,-88(s0)
ffffffe000201e7c:	f4843503          	ld	a0,-184(s0)
ffffffe000201e80:	f38ff0ef          	jal	ra,ffffffe0002015b8 <print_dec_int>
ffffffe000201e84:	00050793          	mv	a5,a0
ffffffe000201e88:	fec42703          	lw	a4,-20(s0)
ffffffe000201e8c:	00f707bb          	addw	a5,a4,a5
ffffffe000201e90:	fef42623          	sw	a5,-20(s0)
        flags.in_format = false;
ffffffe000201e94:	f6040c23          	sb	zero,-136(s0)
ffffffe000201e98:	1b40006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == 'n') {
ffffffe000201e9c:	f4043783          	ld	a5,-192(s0)
ffffffe000201ea0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ea4:	00078713          	mv	a4,a5
ffffffe000201ea8:	06e00793          	li	a5,110
ffffffe000201eac:	04f71c63          	bne	a4,a5,ffffffe000201f04 <vprintfmt+0x648>
        if (flags.longflag) {
ffffffe000201eb0:	f7944783          	lbu	a5,-135(s0)
ffffffe000201eb4:	02078463          	beqz	a5,ffffffe000201edc <vprintfmt+0x620>
          long *n = va_arg(vl, long *);
ffffffe000201eb8:	f3843783          	ld	a5,-200(s0)
ffffffe000201ebc:	00878713          	addi	a4,a5,8
ffffffe000201ec0:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201ec4:	0007b783          	ld	a5,0(a5)
ffffffe000201ec8:	faf43823          	sd	a5,-80(s0)
          *n = written;
ffffffe000201ecc:	fec42703          	lw	a4,-20(s0)
ffffffe000201ed0:	fb043783          	ld	a5,-80(s0)
ffffffe000201ed4:	00e7b023          	sd	a4,0(a5)
ffffffe000201ed8:	0240006f          	j	ffffffe000201efc <vprintfmt+0x640>
        } else {
          int *n = va_arg(vl, int *);
ffffffe000201edc:	f3843783          	ld	a5,-200(s0)
ffffffe000201ee0:	00878713          	addi	a4,a5,8
ffffffe000201ee4:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201ee8:	0007b783          	ld	a5,0(a5)
ffffffe000201eec:	faf43c23          	sd	a5,-72(s0)
          *n = written;
ffffffe000201ef0:	fb843783          	ld	a5,-72(s0)
ffffffe000201ef4:	fec42703          	lw	a4,-20(s0)
ffffffe000201ef8:	00e7a023          	sw	a4,0(a5)
        }
        flags.in_format = false;
ffffffe000201efc:	f6040c23          	sb	zero,-136(s0)
ffffffe000201f00:	14c0006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == 's') {
ffffffe000201f04:	f4043783          	ld	a5,-192(s0)
ffffffe000201f08:	0007c783          	lbu	a5,0(a5)
ffffffe000201f0c:	00078713          	mv	a4,a5
ffffffe000201f10:	07300793          	li	a5,115
ffffffe000201f14:	02f71e63          	bne	a4,a5,ffffffe000201f50 <vprintfmt+0x694>
        const char *s = va_arg(vl, const char *);
ffffffe000201f18:	f3843783          	ld	a5,-200(s0)
ffffffe000201f1c:	00878713          	addi	a4,a5,8
ffffffe000201f20:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201f24:	0007b783          	ld	a5,0(a5)
ffffffe000201f28:	fcf43023          	sd	a5,-64(s0)
        written += puts_wo_nl(putch, s);
ffffffe000201f2c:	fc043583          	ld	a1,-64(s0)
ffffffe000201f30:	f4843503          	ld	a0,-184(s0)
ffffffe000201f34:	db0ff0ef          	jal	ra,ffffffe0002014e4 <puts_wo_nl>
ffffffe000201f38:	00050793          	mv	a5,a0
ffffffe000201f3c:	fec42703          	lw	a4,-20(s0)
ffffffe000201f40:	00f707bb          	addw	a5,a4,a5
ffffffe000201f44:	fef42623          	sw	a5,-20(s0)
        flags.in_format = false;
ffffffe000201f48:	f6040c23          	sb	zero,-136(s0)
ffffffe000201f4c:	1000006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == 'c') {
ffffffe000201f50:	f4043783          	ld	a5,-192(s0)
ffffffe000201f54:	0007c783          	lbu	a5,0(a5)
ffffffe000201f58:	00078713          	mv	a4,a5
ffffffe000201f5c:	06300793          	li	a5,99
ffffffe000201f60:	04f71063          	bne	a4,a5,ffffffe000201fa0 <vprintfmt+0x6e4>
        int ch = va_arg(vl, int);
ffffffe000201f64:	f3843783          	ld	a5,-200(s0)
ffffffe000201f68:	00878713          	addi	a4,a5,8
ffffffe000201f6c:	f2e43c23          	sd	a4,-200(s0)
ffffffe000201f70:	0007a783          	lw	a5,0(a5)
ffffffe000201f74:	fcf42623          	sw	a5,-52(s0)
        putch(ch);
ffffffe000201f78:	fcc42783          	lw	a5,-52(s0)
ffffffe000201f7c:	0ff7f713          	zext.b	a4,a5
ffffffe000201f80:	f4843783          	ld	a5,-184(s0)
ffffffe000201f84:	00070513          	mv	a0,a4
ffffffe000201f88:	000780e7          	jalr	a5
        ++written;
ffffffe000201f8c:	fec42783          	lw	a5,-20(s0)
ffffffe000201f90:	0017879b          	addiw	a5,a5,1
ffffffe000201f94:	fef42623          	sw	a5,-20(s0)
        flags.in_format = false;
ffffffe000201f98:	f6040c23          	sb	zero,-136(s0)
ffffffe000201f9c:	0b00006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else if (*fmt == '%') {
ffffffe000201fa0:	f4043783          	ld	a5,-192(s0)
ffffffe000201fa4:	0007c783          	lbu	a5,0(a5)
ffffffe000201fa8:	00078713          	mv	a4,a5
ffffffe000201fac:	02500793          	li	a5,37
ffffffe000201fb0:	02f71263          	bne	a4,a5,ffffffe000201fd4 <vprintfmt+0x718>
        putch('%');
ffffffe000201fb4:	f4843783          	ld	a5,-184(s0)
ffffffe000201fb8:	02500513          	li	a0,37
ffffffe000201fbc:	000780e7          	jalr	a5
        ++written;
ffffffe000201fc0:	fec42783          	lw	a5,-20(s0)
ffffffe000201fc4:	0017879b          	addiw	a5,a5,1
ffffffe000201fc8:	fef42623          	sw	a5,-20(s0)
        flags.in_format = false;
ffffffe000201fcc:	f6040c23          	sb	zero,-136(s0)
ffffffe000201fd0:	07c0006f          	j	ffffffe00020204c <vprintfmt+0x790>
      } else {
        putch(*fmt);
ffffffe000201fd4:	f4043783          	ld	a5,-192(s0)
ffffffe000201fd8:	0007c703          	lbu	a4,0(a5)
ffffffe000201fdc:	f4843783          	ld	a5,-184(s0)
ffffffe000201fe0:	00070513          	mv	a0,a4
ffffffe000201fe4:	000780e7          	jalr	a5
        ++written;
ffffffe000201fe8:	fec42783          	lw	a5,-20(s0)
ffffffe000201fec:	0017879b          	addiw	a5,a5,1
ffffffe000201ff0:	fef42623          	sw	a5,-20(s0)
        flags.in_format = false;
ffffffe000201ff4:	f6040c23          	sb	zero,-136(s0)
ffffffe000201ff8:	0540006f          	j	ffffffe00020204c <vprintfmt+0x790>
      }
    } else if (*fmt == '%') {
ffffffe000201ffc:	f4043783          	ld	a5,-192(s0)
ffffffe000202000:	0007c783          	lbu	a5,0(a5)
ffffffe000202004:	00078713          	mv	a4,a5
ffffffe000202008:	02500793          	li	a5,37
ffffffe00020200c:	02f71063          	bne	a4,a5,ffffffe00020202c <vprintfmt+0x770>
      flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202010:	f6043c23          	sd	zero,-136(s0)
ffffffe000202014:	f8043023          	sd	zero,-128(s0)
ffffffe000202018:	00100793          	li	a5,1
ffffffe00020201c:	f6f40c23          	sb	a5,-136(s0)
ffffffe000202020:	fff00793          	li	a5,-1
ffffffe000202024:	f8f42223          	sw	a5,-124(s0)
ffffffe000202028:	0240006f          	j	ffffffe00020204c <vprintfmt+0x790>
    } else {
      putch(*fmt);
ffffffe00020202c:	f4043783          	ld	a5,-192(s0)
ffffffe000202030:	0007c703          	lbu	a4,0(a5)
ffffffe000202034:	f4843783          	ld	a5,-184(s0)
ffffffe000202038:	00070513          	mv	a0,a4
ffffffe00020203c:	000780e7          	jalr	a5
      ++written;
ffffffe000202040:	fec42783          	lw	a5,-20(s0)
ffffffe000202044:	0017879b          	addiw	a5,a5,1
ffffffe000202048:	fef42623          	sw	a5,-20(s0)
  for (; *fmt; fmt++) {
ffffffe00020204c:	f4043783          	ld	a5,-192(s0)
ffffffe000202050:	00178793          	addi	a5,a5,1
ffffffe000202054:	f4f43023          	sd	a5,-192(s0)
ffffffe000202058:	f4043783          	ld	a5,-192(s0)
ffffffe00020205c:	0007c783          	lbu	a5,0(a5)
ffffffe000202060:	880792e3          	bnez	a5,ffffffe0002018e4 <vprintfmt+0x28>
    }
  }

  return written;
ffffffe000202064:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202068:	00078513          	mv	a0,a5
ffffffe00020206c:	0c813083          	ld	ra,200(sp)
ffffffe000202070:	0c013403          	ld	s0,192(sp)
ffffffe000202074:	0d010113          	addi	sp,sp,208
ffffffe000202078:	00008067          	ret

ffffffe00020207c <printk>:

int printk(const char *s, ...) {
ffffffe00020207c:	f9010113          	addi	sp,sp,-112
ffffffe000202080:	02113423          	sd	ra,40(sp)
ffffffe000202084:	02813023          	sd	s0,32(sp)
ffffffe000202088:	03010413          	addi	s0,sp,48
ffffffe00020208c:	fca43c23          	sd	a0,-40(s0)
ffffffe000202090:	00b43423          	sd	a1,8(s0)
ffffffe000202094:	00c43823          	sd	a2,16(s0)
ffffffe000202098:	00d43c23          	sd	a3,24(s0)
ffffffe00020209c:	02e43023          	sd	a4,32(s0)
ffffffe0002020a0:	02f43423          	sd	a5,40(s0)
ffffffe0002020a4:	03043823          	sd	a6,48(s0)
ffffffe0002020a8:	03143c23          	sd	a7,56(s0)
  int res = 0;
ffffffe0002020ac:	fe042623          	sw	zero,-20(s0)
  va_list vl;
  va_start(vl, s);
ffffffe0002020b0:	04040793          	addi	a5,s0,64
ffffffe0002020b4:	fcf43823          	sd	a5,-48(s0)
ffffffe0002020b8:	fd043783          	ld	a5,-48(s0)
ffffffe0002020bc:	fc878793          	addi	a5,a5,-56
ffffffe0002020c0:	fef43023          	sd	a5,-32(s0)
  res = vprintfmt(putchar, s, vl);
ffffffe0002020c4:	fe043783          	ld	a5,-32(s0)
ffffffe0002020c8:	00078613          	mv	a2,a5
ffffffe0002020cc:	fd843583          	ld	a1,-40(s0)
ffffffe0002020d0:	fffff517          	auipc	a0,0xfffff
ffffffe0002020d4:	0f850513          	addi	a0,a0,248 # ffffffe0002011c8 <putchar>
ffffffe0002020d8:	fe4ff0ef          	jal	ra,ffffffe0002018bc <vprintfmt>
ffffffe0002020dc:	00050793          	mv	a5,a0
ffffffe0002020e0:	fef42623          	sw	a5,-20(s0)
  va_end(vl);
  return res;
ffffffe0002020e4:	fec42783          	lw	a5,-20(s0)
}
ffffffe0002020e8:	00078513          	mv	a0,a5
ffffffe0002020ec:	02813083          	ld	ra,40(sp)
ffffffe0002020f0:	02013403          	ld	s0,32(sp)
ffffffe0002020f4:	07010113          	addi	sp,sp,112
ffffffe0002020f8:	00008067          	ret

ffffffe0002020fc <rand>:

// int initialize = 0;
// int r[1000];
long t=1;

uint64 rand() {
ffffffe0002020fc:	ff010113          	addi	sp,sp,-16
ffffffe000202100:	00813423          	sd	s0,8(sp)
ffffffe000202104:	01010413          	addi	s0,sp,16
    t++;
ffffffe000202108:	00002797          	auipc	a5,0x2
ffffffe00020210c:	f0078793          	addi	a5,a5,-256 # ffffffe000204008 <t>
ffffffe000202110:	0007b783          	ld	a5,0(a5)
ffffffe000202114:	00178713          	addi	a4,a5,1
ffffffe000202118:	00002797          	auipc	a5,0x2
ffffffe00020211c:	ef078793          	addi	a5,a5,-272 # ffffffe000204008 <t>
ffffffe000202120:	00e7b023          	sd	a4,0(a5)
    return t;
ffffffe000202124:	00002797          	auipc	a5,0x2
ffffffe000202128:	ee478793          	addi	a5,a5,-284 # ffffffe000204008 <t>
ffffffe00020212c:	0007b783          	ld	a5,0(a5)
    // r[t + 344] = r[t + 344 - 31] + r[t + 344 - 3];
    
	// t++;

    // return (uint64)r[t - 1 + 344];
}
ffffffe000202130:	00078513          	mv	a0,a5
ffffffe000202134:	00813403          	ld	s0,8(sp)
ffffffe000202138:	01010113          	addi	sp,sp,16
ffffffe00020213c:	00008067          	ret

ffffffe000202140 <memset>:
#include "string.h"
#include "types.h"

void *memset(void *dst, int c, uint64 n) {
ffffffe000202140:	fc010113          	addi	sp,sp,-64
ffffffe000202144:	02813c23          	sd	s0,56(sp)
ffffffe000202148:	04010413          	addi	s0,sp,64
ffffffe00020214c:	fca43c23          	sd	a0,-40(s0)
ffffffe000202150:	00058793          	mv	a5,a1
ffffffe000202154:	fcc43423          	sd	a2,-56(s0)
ffffffe000202158:	fcf42a23          	sw	a5,-44(s0)
    char *cdst = (char *)dst;
ffffffe00020215c:	fd843783          	ld	a5,-40(s0)
ffffffe000202160:	fef43023          	sd	a5,-32(s0)
    for (uint64 i = 0; i < n; ++i)
ffffffe000202164:	fe043423          	sd	zero,-24(s0)
ffffffe000202168:	0280006f          	j	ffffffe000202190 <memset+0x50>
        cdst[i] = c;
ffffffe00020216c:	fe043703          	ld	a4,-32(s0)
ffffffe000202170:	fe843783          	ld	a5,-24(s0)
ffffffe000202174:	00f707b3          	add	a5,a4,a5
ffffffe000202178:	fd442703          	lw	a4,-44(s0)
ffffffe00020217c:	0ff77713          	zext.b	a4,a4
ffffffe000202180:	00e78023          	sb	a4,0(a5)
    for (uint64 i = 0; i < n; ++i)
ffffffe000202184:	fe843783          	ld	a5,-24(s0)
ffffffe000202188:	00178793          	addi	a5,a5,1
ffffffe00020218c:	fef43423          	sd	a5,-24(s0)
ffffffe000202190:	fe843703          	ld	a4,-24(s0)
ffffffe000202194:	fc843783          	ld	a5,-56(s0)
ffffffe000202198:	fcf76ae3          	bltu	a4,a5,ffffffe00020216c <memset+0x2c>

    return dst;
ffffffe00020219c:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002021a0:	00078513          	mv	a0,a5
ffffffe0002021a4:	03813403          	ld	s0,56(sp)
ffffffe0002021a8:	04010113          	addi	sp,sp,64
ffffffe0002021ac:	00008067          	ret
