
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	93013103          	ld	sp,-1744(sp) # 80008930 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	f5478793          	addi	a5,a5,-172 # 80005fb0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77df>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e1878793          	addi	a5,a5,-488 # 80000ebe <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b04080e7          	jalr	-1276(ra) # 80000c10 <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	742080e7          	jalr	1858(ra) # 80002868 <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	7aa080e7          	jalr	1962(ra) # 800008e0 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	b76080e7          	jalr	-1162(ra) # 80000cc4 <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7119                	addi	sp,sp,-128
    80000170:	fc86                	sd	ra,120(sp)
    80000172:	f8a2                	sd	s0,112(sp)
    80000174:	f4a6                	sd	s1,104(sp)
    80000176:	f0ca                	sd	s2,96(sp)
    80000178:	ecce                	sd	s3,88(sp)
    8000017a:	e8d2                	sd	s4,80(sp)
    8000017c:	e4d6                	sd	s5,72(sp)
    8000017e:	e0da                	sd	s6,64(sp)
    80000180:	fc5e                	sd	s7,56(sp)
    80000182:	f862                	sd	s8,48(sp)
    80000184:	f466                	sd	s9,40(sp)
    80000186:	f06a                	sd	s10,32(sp)
    80000188:	ec6e                	sd	s11,24(sp)
    8000018a:	0100                	addi	s0,sp,128
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8aae                	mv	s5,a1
    80000190:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	a72080e7          	jalr	-1422(ra) # 80000c10 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	89a6                	mv	s3,s1
    800001b0:	00011917          	auipc	s2,0x11
    800001b4:	71890913          	addi	s2,s2,1816 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ba:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001bc:	4da9                	li	s11,10
  while(n > 0){
    800001be:	07405863          	blez	s4,8000022e <consoleread+0xc0>
    while(cons.r == cons.w){
    800001c2:	0984a783          	lw	a5,152(s1)
    800001c6:	09c4a703          	lw	a4,156(s1)
    800001ca:	02f71463          	bne	a4,a5,800001f2 <consoleread+0x84>
      if(myproc()->killed){
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	a02080e7          	jalr	-1534(ra) # 80001bd0 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	3d2080e7          	jalr	978(ra) # 800025b0 <sleep>
    while(cons.r == cons.w){
    800001e6:	0984a783          	lw	a5,152(s1)
    800001ea:	09c4a703          	lw	a4,156(s1)
    800001ee:	fef700e3          	beq	a4,a5,800001ce <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f2:	0017871b          	addiw	a4,a5,1
    800001f6:	08e4ac23          	sw	a4,152(s1)
    800001fa:	07f7f713          	andi	a4,a5,127
    800001fe:	9726                	add	a4,a4,s1
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000208:	079c0663          	beq	s8,s9,80000274 <consoleread+0x106>
    cbuf = c;
    8000020c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	f8f40613          	addi	a2,s0,-113
    80000216:	85d6                	mv	a1,s5
    80000218:	855a                	mv	a0,s6
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	5f8080e7          	jalr	1528(ra) # 80002812 <either_copyout>
    80000222:	01a50663          	beq	a0,s10,8000022e <consoleread+0xc0>
    dst++;
    80000226:	0a85                	addi	s5,s5,1
    --n;
    80000228:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022a:	f9bc1ae3          	bne	s8,s11,800001be <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022e:	00011517          	auipc	a0,0x11
    80000232:	60250513          	addi	a0,a0,1538 # 80011830 <cons>
    80000236:	00001097          	auipc	ra,0x1
    8000023a:	a8e080e7          	jalr	-1394(ra) # 80000cc4 <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	a78080e7          	jalr	-1416(ra) # 80000cc4 <release>
        return -1;
    80000254:	557d                	li	a0,-1
}
    80000256:	70e6                	ld	ra,120(sp)
    80000258:	7446                	ld	s0,112(sp)
    8000025a:	74a6                	ld	s1,104(sp)
    8000025c:	7906                	ld	s2,96(sp)
    8000025e:	69e6                	ld	s3,88(sp)
    80000260:	6a46                	ld	s4,80(sp)
    80000262:	6aa6                	ld	s5,72(sp)
    80000264:	6b06                	ld	s6,64(sp)
    80000266:	7be2                	ld	s7,56(sp)
    80000268:	7c42                	ld	s8,48(sp)
    8000026a:	7ca2                	ld	s9,40(sp)
    8000026c:	7d02                	ld	s10,32(sp)
    8000026e:	6de2                	ld	s11,24(sp)
    80000270:	6109                	addi	sp,sp,128
    80000272:	8082                	ret
      if(n < target){
    80000274:	000a071b          	sext.w	a4,s4
    80000278:	fb777be3          	bgeu	a4,s7,8000022e <consoleread+0xc0>
        cons.r--;
    8000027c:	00011717          	auipc	a4,0x11
    80000280:	64f72623          	sw	a5,1612(a4) # 800118c8 <cons+0x98>
    80000284:	b76d                	j	8000022e <consoleread+0xc0>

0000000080000286 <consputc>:
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e406                	sd	ra,8(sp)
    8000028a:	e022                	sd	s0,0(sp)
    8000028c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028e:	10000793          	li	a5,256
    80000292:	00f50a63          	beq	a0,a5,800002a6 <consputc+0x20>
    uartputc_sync(c);
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	564080e7          	jalr	1380(ra) # 800007fa <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	552080e7          	jalr	1362(ra) # 800007fa <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	546080e7          	jalr	1350(ra) # 800007fa <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	53c080e7          	jalr	1340(ra) # 800007fa <uartputc_sync>
    800002c6:	bfe1                	j	8000029e <consputc+0x18>

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	55a50513          	addi	a0,a0,1370 # 80011830 <cons>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	932080e7          	jalr	-1742(ra) # 80000c10 <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	5c2080e7          	jalr	1474(ra) # 800028be <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	9b8080e7          	jalr	-1608(ra) # 80000cc4 <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	50870713          	addi	a4,a4,1288 # 80011830 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	f3c080e7          	jalr	-196(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4de78793          	addi	a5,a5,1246 # 80011830 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5487a783          	lw	a5,1352(a5) # 800118c8 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	49c70713          	addi	a4,a4,1180 # 80011830 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	48c48493          	addi	s1,s1,1164 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	ebc080e7          	jalr	-324(ra) # 80000286 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	45070713          	addi	a4,a4,1104 # 80011830 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4cf72d23          	sw	a5,1242(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e84080e7          	jalr	-380(ra) # 80000286 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	e72080e7          	jalr	-398(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	41478793          	addi	a5,a5,1044 # 80011830 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	48c7a623          	sw	a2,1164(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	48050513          	addi	a0,a0,1152 # 800118c8 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	2e6080e7          	jalr	742(ra) # 80002736 <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00008597          	auipc	a1,0x8
    80000466:	b9e58593          	addi	a1,a1,-1122 # 80008000 <etext>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	3c650513          	addi	a0,a0,966 # 80011830 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	70e080e7          	jalr	1806(ra) # 80000b80 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00021797          	auipc	a5,0x21
    80000486:	72e78793          	addi	a5,a5,1838 # 80021bb0 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	ce470713          	addi	a4,a4,-796 # 8000016e <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	c5870713          	addi	a4,a4,-936 # 800000ec <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	b6c60613          	addi	a2,a2,-1172 # 80008030 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d60080e7          	jalr	-672(ra) # 80000286 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3807ae23          	sw	zero,924(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	aac50513          	addi	a0,a0,-1364 # 80008008 <etext+0x8>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b4250513          	addi	a0,a0,-1214 # 800080b8 <digits+0x88>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	32cdad83          	lw	s11,812(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	16050263          	beqz	a0,80000744 <printf+0x1b2>
    800005e4:	4481                	li	s1,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b13          	li	s6,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00008b97          	auipc	s7,0x8
    800005f4:	a40b8b93          	addi	s7,s7,-1472 # 80008030 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2d650513          	addi	a0,a0,726 # 800118d8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	606080e7          	jalr	1542(ra) # 80000c10 <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	a0450513          	addi	a0,a0,-1532 # 80008018 <etext+0x18>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	c62080e7          	jalr	-926(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2485                	addiw	s1,s1,1
    8000062e:	009a07b3          	add	a5,s4,s1
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050763          	beqz	a0,80000744 <printf+0x1b2>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2485                	addiw	s1,s1,1
    80000640:	009a07b3          	add	a5,s4,s1
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000064c:	cfe5                	beqz	a5,80000744 <printf+0x1b2>
    switch(c){
    8000064e:	05678a63          	beq	a5,s6,800006a2 <printf+0x110>
    80000652:	02fb7663          	bgeu	s6,a5,8000067e <printf+0xec>
    80000656:	09978963          	beq	a5,s9,800006e8 <printf+0x156>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79863          	bne	a5,a4,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	0b578263          	beq	a5,s5,80000722 <printf+0x190>
    80000682:	0b879663          	bne	a5,s8,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bd0080e7          	jalr	-1072(ra) # 80000286 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	bc4080e7          	jalr	-1084(ra) # 80000286 <consputc>
    800006ca:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c9d793          	srli	a5,s3,0x3c
    800006d0:	97de                	add	a5,a5,s7
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	bb0080e7          	jalr	-1104(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0992                	slli	s3,s3,0x4
    800006e0:	397d                	addiw	s2,s2,-1
    800006e2:	fe0915e3          	bnez	s2,800006cc <printf+0x13a>
    800006e6:	b799                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	0007b903          	ld	s2,0(a5)
    800006f8:	00090e63          	beqz	s2,80000714 <printf+0x182>
      for(; *s; s++)
    800006fc:	00094503          	lbu	a0,0(s2)
    80000700:	d515                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b84080e7          	jalr	-1148(ra) # 80000286 <consputc>
      for(; *s; s++)
    8000070a:	0905                	addi	s2,s2,1
    8000070c:	00094503          	lbu	a0,0(s2)
    80000710:	f96d                	bnez	a0,80000702 <printf+0x170>
    80000712:	bf29                	j	8000062c <printf+0x9a>
        s = "(null)";
    80000714:	00008917          	auipc	s2,0x8
    80000718:	8fc90913          	addi	s2,s2,-1796 # 80008010 <etext+0x10>
      for(; *s; s++)
    8000071c:	02800513          	li	a0,40
    80000720:	b7cd                	j	80000702 <printf+0x170>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b62080e7          	jalr	-1182(ra) # 80000286 <consputc>
      break;
    8000072c:	b701                	j	8000062c <printf+0x9a>
      consputc('%');
    8000072e:	8556                	mv	a0,s5
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b56080e7          	jalr	-1194(ra) # 80000286 <consputc>
      consputc(c);
    80000738:	854a                	mv	a0,s2
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b4c080e7          	jalr	-1204(ra) # 80000286 <consputc>
      break;
    80000742:	b5ed                	j	8000062c <printf+0x9a>
  if(locking)
    80000744:	020d9163          	bnez	s11,80000766 <printf+0x1d4>
}
    80000748:	70e6                	ld	ra,120(sp)
    8000074a:	7446                	ld	s0,112(sp)
    8000074c:	74a6                	ld	s1,104(sp)
    8000074e:	7906                	ld	s2,96(sp)
    80000750:	69e6                	ld	s3,88(sp)
    80000752:	6a46                	ld	s4,80(sp)
    80000754:	6aa6                	ld	s5,72(sp)
    80000756:	6b06                	ld	s6,64(sp)
    80000758:	7be2                	ld	s7,56(sp)
    8000075a:	7c42                	ld	s8,48(sp)
    8000075c:	7ca2                	ld	s9,40(sp)
    8000075e:	7d02                	ld	s10,32(sp)
    80000760:	6de2                	ld	s11,24(sp)
    80000762:	6129                	addi	sp,sp,192
    80000764:	8082                	ret
    release(&pr.lock);
    80000766:	00011517          	auipc	a0,0x11
    8000076a:	17250513          	addi	a0,a0,370 # 800118d8 <pr>
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	556080e7          	jalr	1366(ra) # 80000cc4 <release>
}
    80000776:	bfc9                	j	80000748 <printf+0x1b6>

0000000080000778 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000778:	1101                	addi	sp,sp,-32
    8000077a:	ec06                	sd	ra,24(sp)
    8000077c:	e822                	sd	s0,16(sp)
    8000077e:	e426                	sd	s1,8(sp)
    80000780:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000782:	00011497          	auipc	s1,0x11
    80000786:	15648493          	addi	s1,s1,342 # 800118d8 <pr>
    8000078a:	00008597          	auipc	a1,0x8
    8000078e:	89e58593          	addi	a1,a1,-1890 # 80008028 <etext+0x28>
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	3ec080e7          	jalr	1004(ra) # 80000b80 <initlock>
  pr.locking = 1;
    8000079c:	4785                	li	a5,1
    8000079e:	cc9c                	sw	a5,24(s1)
}
    800007a0:	60e2                	ld	ra,24(sp)
    800007a2:	6442                	ld	s0,16(sp)
    800007a4:	64a2                	ld	s1,8(sp)
    800007a6:	6105                	addi	sp,sp,32
    800007a8:	8082                	ret

00000000800007aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b2:	100007b7          	lui	a5,0x10000
    800007b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ba:	f8000713          	li	a4,-128
    800007be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c2:	470d                	li	a4,3
    800007c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d0:	469d                	li	a3,7
    800007d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007da:	00008597          	auipc	a1,0x8
    800007de:	86e58593          	addi	a1,a1,-1938 # 80008048 <digits+0x18>
    800007e2:	00011517          	auipc	a0,0x11
    800007e6:	11650513          	addi	a0,a0,278 # 800118f8 <uart_tx_lock>
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	396080e7          	jalr	918(ra) # 80000b80 <initlock>
}
    800007f2:	60a2                	ld	ra,8(sp)
    800007f4:	6402                	ld	s0,0(sp)
    800007f6:	0141                	addi	sp,sp,16
    800007f8:	8082                	ret

00000000800007fa <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
    80000804:	84aa                	mv	s1,a0
  push_off();
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	3be080e7          	jalr	958(ra) # 80000bc4 <push_off>

  if(panicked){
    8000080e:	00008797          	auipc	a5,0x8
    80000812:	7f27a783          	lw	a5,2034(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081a:	c391                	beqz	a5,8000081e <uartputc_sync+0x24>
    for(;;)
    8000081c:	a001                	j	8000081c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000822:	0ff7f793          	andi	a5,a5,255
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dbf5                	beqz	a5,8000081e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f793          	andi	a5,s1,255
    80000830:	10000737          	lui	a4,0x10000
    80000834:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	42c080e7          	jalr	1068(ra) # 80000c64 <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	7ba7a783          	lw	a5,1978(a5) # 80009004 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	7b672703          	lw	a4,1974(a4) # 80009008 <uart_tx_w>
    8000085a:	08f70263          	beq	a4,a5,800008de <uartstart+0x94>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000874:	00011a17          	auipc	s4,0x11
    80000878:	084a0a13          	addi	s4,s4,132 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	78848493          	addi	s1,s1,1928 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	78498993          	addi	s3,s3,1924 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	0ff77713          	andi	a4,a4,255
    80000894:	02077713          	andi	a4,a4,32
    80000898:	cb15                	beqz	a4,800008cc <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    8000089a:	00fa0733          	add	a4,s4,a5
    8000089e:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008a2:	2785                	addiw	a5,a5,1
    800008a4:	41f7d71b          	sraiw	a4,a5,0x1f
    800008a8:	01b7571b          	srliw	a4,a4,0x1b
    800008ac:	9fb9                	addw	a5,a5,a4
    800008ae:	8bfd                	andi	a5,a5,31
    800008b0:	9f99                	subw	a5,a5,a4
    800008b2:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008b4:	8526                	mv	a0,s1
    800008b6:	00002097          	auipc	ra,0x2
    800008ba:	e80080e7          	jalr	-384(ra) # 80002736 <wakeup>
    
    WriteReg(THR, c);
    800008be:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008c2:	409c                	lw	a5,0(s1)
    800008c4:	0009a703          	lw	a4,0(s3)
    800008c8:	fcf712e3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008cc:	70e2                	ld	ra,56(sp)
    800008ce:	7442                	ld	s0,48(sp)
    800008d0:	74a2                	ld	s1,40(sp)
    800008d2:	7902                	ld	s2,32(sp)
    800008d4:	69e2                	ld	s3,24(sp)
    800008d6:	6a42                	ld	s4,16(sp)
    800008d8:	6aa2                	ld	s5,8(sp)
    800008da:	6121                	addi	sp,sp,64
    800008dc:	8082                	ret
    800008de:	8082                	ret

00000000800008e0 <uartputc>:
{
    800008e0:	7179                	addi	sp,sp,-48
    800008e2:	f406                	sd	ra,40(sp)
    800008e4:	f022                	sd	s0,32(sp)
    800008e6:	ec26                	sd	s1,24(sp)
    800008e8:	e84a                	sd	s2,16(sp)
    800008ea:	e44e                	sd	s3,8(sp)
    800008ec:	e052                	sd	s4,0(sp)
    800008ee:	1800                	addi	s0,sp,48
    800008f0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008f2:	00011517          	auipc	a0,0x11
    800008f6:	00650513          	addi	a0,a0,6 # 800118f8 <uart_tx_lock>
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	316080e7          	jalr	790(ra) # 80000c10 <acquire>
  if(panicked){
    80000902:	00008797          	auipc	a5,0x8
    80000906:	6fe7a783          	lw	a5,1790(a5) # 80009000 <panicked>
    8000090a:	c391                	beqz	a5,8000090e <uartputc+0x2e>
    for(;;)
    8000090c:	a001                	j	8000090c <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000090e:	00008717          	auipc	a4,0x8
    80000912:	6fa72703          	lw	a4,1786(a4) # 80009008 <uart_tx_w>
    80000916:	0017079b          	addiw	a5,a4,1
    8000091a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000091e:	01b6d69b          	srliw	a3,a3,0x1b
    80000922:	9fb5                	addw	a5,a5,a3
    80000924:	8bfd                	andi	a5,a5,31
    80000926:	9f95                	subw	a5,a5,a3
    80000928:	00008697          	auipc	a3,0x8
    8000092c:	6dc6a683          	lw	a3,1756(a3) # 80009004 <uart_tx_r>
    80000930:	04f69263          	bne	a3,a5,80000974 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000934:	00011a17          	auipc	s4,0x11
    80000938:	fc4a0a13          	addi	s4,s4,-60 # 800118f8 <uart_tx_lock>
    8000093c:	00008497          	auipc	s1,0x8
    80000940:	6c848493          	addi	s1,s1,1736 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	00008917          	auipc	s2,0x8
    80000948:	6c490913          	addi	s2,s2,1732 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000094c:	85d2                	mv	a1,s4
    8000094e:	8526                	mv	a0,s1
    80000950:	00002097          	auipc	ra,0x2
    80000954:	c60080e7          	jalr	-928(ra) # 800025b0 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00092703          	lw	a4,0(s2)
    8000095c:	0017079b          	addiw	a5,a4,1
    80000960:	41f7d69b          	sraiw	a3,a5,0x1f
    80000964:	01b6d69b          	srliw	a3,a3,0x1b
    80000968:	9fb5                	addw	a5,a5,a3
    8000096a:	8bfd                	andi	a5,a5,31
    8000096c:	9f95                	subw	a5,a5,a3
    8000096e:	4094                	lw	a3,0(s1)
    80000970:	fcf68ee3          	beq	a3,a5,8000094c <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000974:	00011497          	auipc	s1,0x11
    80000978:	f8448493          	addi	s1,s1,-124 # 800118f8 <uart_tx_lock>
    8000097c:	9726                	add	a4,a4,s1
    8000097e:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000982:	00008717          	auipc	a4,0x8
    80000986:	68f72323          	sw	a5,1670(a4) # 80009008 <uart_tx_w>
      uartstart();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	ec0080e7          	jalr	-320(ra) # 8000084a <uartstart>
      release(&uart_tx_lock);
    80000992:	8526                	mv	a0,s1
    80000994:	00000097          	auipc	ra,0x0
    80000998:	330080e7          	jalr	816(ra) # 80000cc4 <release>
}
    8000099c:	70a2                	ld	ra,40(sp)
    8000099e:	7402                	ld	s0,32(sp)
    800009a0:	64e2                	ld	s1,24(sp)
    800009a2:	6942                	ld	s2,16(sp)
    800009a4:	69a2                	ld	s3,8(sp)
    800009a6:	6a02                	ld	s4,0(sp)
    800009a8:	6145                	addi	sp,sp,48
    800009aa:	8082                	ret

00000000800009ac <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ac:	1141                	addi	sp,sp,-16
    800009ae:	e422                	sd	s0,8(sp)
    800009b0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009b2:	100007b7          	lui	a5,0x10000
    800009b6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ba:	8b85                	andi	a5,a5,1
    800009bc:	cb91                	beqz	a5,800009d0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009be:	100007b7          	lui	a5,0x10000
    800009c2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009ca:	6422                	ld	s0,8(sp)
    800009cc:	0141                	addi	sp,sp,16
    800009ce:	8082                	ret
    return -1;
    800009d0:	557d                	li	a0,-1
    800009d2:	bfe5                	j	800009ca <uartgetc+0x1e>

00000000800009d4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009d4:	1101                	addi	sp,sp,-32
    800009d6:	ec06                	sd	ra,24(sp)
    800009d8:	e822                	sd	s0,16(sp)
    800009da:	e426                	sd	s1,8(sp)
    800009dc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009de:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e0:	00000097          	auipc	ra,0x0
    800009e4:	fcc080e7          	jalr	-52(ra) # 800009ac <uartgetc>
    if(c == -1)
    800009e8:	00950763          	beq	a0,s1,800009f6 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	8dc080e7          	jalr	-1828(ra) # 800002c8 <consoleintr>
  while(1){
    800009f4:	b7f5                	j	800009e0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f6:	00011497          	auipc	s1,0x11
    800009fa:	f0248493          	addi	s1,s1,-254 # 800118f8 <uart_tx_lock>
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	210080e7          	jalr	528(ra) # 80000c10 <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	2b2080e7          	jalr	690(ra) # 80000cc4 <release>
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a24:	1101                	addi	sp,sp,-32
    80000a26:	ec06                	sd	ra,24(sp)
    80000a28:	e822                	sd	s0,16(sp)
    80000a2a:	e426                	sd	s1,8(sp)
    80000a2c:	e04a                	sd	s2,0(sp)
    80000a2e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a30:	03451793          	slli	a5,a0,0x34
    80000a34:	ebb9                	bnez	a5,80000a8a <kfree+0x66>
    80000a36:	84aa                	mv	s1,a0
    80000a38:	00026797          	auipc	a5,0x26
    80000a3c:	5e878793          	addi	a5,a5,1512 # 80027020 <end>
    80000a40:	04f56563          	bltu	a0,a5,80000a8a <kfree+0x66>
    80000a44:	47c5                	li	a5,17
    80000a46:	07ee                	slli	a5,a5,0x1b
    80000a48:	04f57163          	bgeu	a0,a5,80000a8a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a4c:	6605                	lui	a2,0x1
    80000a4e:	4585                	li	a1,1
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	2bc080e7          	jalr	700(ra) # 80000d0c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a58:	00011917          	auipc	s2,0x11
    80000a5c:	ed890913          	addi	s2,s2,-296 # 80011930 <kmem>
    80000a60:	854a                	mv	a0,s2
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	1ae080e7          	jalr	430(ra) # 80000c10 <acquire>
  r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	24e080e7          	jalr	590(ra) # 80000cc4 <release>
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6902                	ld	s2,0(sp)
    80000a86:	6105                	addi	sp,sp,32
    80000a88:	8082                	ret
    panic("kfree");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	5c650513          	addi	a0,a0,1478 # 80008050 <digits+0x20>
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	ab6080e7          	jalr	-1354(ra) # 80000548 <panic>

0000000080000a9a <freerange>:
{
    80000a9a:	7179                	addi	sp,sp,-48
    80000a9c:	f406                	sd	ra,40(sp)
    80000a9e:	f022                	sd	s0,32(sp)
    80000aa0:	ec26                	sd	s1,24(sp)
    80000aa2:	e84a                	sd	s2,16(sp)
    80000aa4:	e44e                	sd	s3,8(sp)
    80000aa6:	e052                	sd	s4,0(sp)
    80000aa8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aaa:	6785                	lui	a5,0x1
    80000aac:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ab0:	94aa                	add	s1,s1,a0
    80000ab2:	757d                	lui	a0,0xfffff
    80000ab4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab6:	94be                	add	s1,s1,a5
    80000ab8:	0095ee63          	bltu	a1,s1,80000ad4 <freerange+0x3a>
    80000abc:	892e                	mv	s2,a1
    kfree(p);
    80000abe:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	6985                	lui	s3,0x1
    kfree(p);
    80000ac2:	01448533          	add	a0,s1,s4
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f5e080e7          	jalr	-162(ra) # 80000a24 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ace:	94ce                	add	s1,s1,s3
    80000ad0:	fe9979e3          	bgeu	s2,s1,80000ac2 <freerange+0x28>
}
    80000ad4:	70a2                	ld	ra,40(sp)
    80000ad6:	7402                	ld	s0,32(sp)
    80000ad8:	64e2                	ld	s1,24(sp)
    80000ada:	6942                	ld	s2,16(sp)
    80000adc:	69a2                	ld	s3,8(sp)
    80000ade:	6a02                	ld	s4,0(sp)
    80000ae0:	6145                	addi	sp,sp,48
    80000ae2:	8082                	ret

0000000080000ae4 <kinit>:
{
    80000ae4:	1141                	addi	sp,sp,-16
    80000ae6:	e406                	sd	ra,8(sp)
    80000ae8:	e022                	sd	s0,0(sp)
    80000aea:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aec:	00007597          	auipc	a1,0x7
    80000af0:	56c58593          	addi	a1,a1,1388 # 80008058 <digits+0x28>
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	e3c50513          	addi	a0,a0,-452 # 80011930 <kmem>
    80000afc:	00000097          	auipc	ra,0x0
    80000b00:	084080e7          	jalr	132(ra) # 80000b80 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b04:	45c5                	li	a1,17
    80000b06:	05ee                	slli	a1,a1,0x1b
    80000b08:	00026517          	auipc	a0,0x26
    80000b0c:	51850513          	addi	a0,a0,1304 # 80027020 <end>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	f8a080e7          	jalr	-118(ra) # 80000a9a <freerange>
}
    80000b18:	60a2                	ld	ra,8(sp)
    80000b1a:	6402                	ld	s0,0(sp)
    80000b1c:	0141                	addi	sp,sp,16
    80000b1e:	8082                	ret

0000000080000b20 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b20:	1101                	addi	sp,sp,-32
    80000b22:	ec06                	sd	ra,24(sp)
    80000b24:	e822                	sd	s0,16(sp)
    80000b26:	e426                	sd	s1,8(sp)
    80000b28:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2a:	00011497          	auipc	s1,0x11
    80000b2e:	e0648493          	addi	s1,s1,-506 # 80011930 <kmem>
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	0dc080e7          	jalr	220(ra) # 80000c10 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c885                	beqz	s1,80000b6e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00011517          	auipc	a0,0x11
    80000b46:	dee50513          	addi	a0,a0,-530 # 80011930 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	178080e7          	jalr	376(ra) # 80000cc4 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b54:	6605                	lui	a2,0x1
    80000b56:	4595                	li	a1,5
    80000b58:	8526                	mv	a0,s1
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	1b2080e7          	jalr	434(ra) # 80000d0c <memset>
  return (void*)r;
}
    80000b62:	8526                	mv	a0,s1
    80000b64:	60e2                	ld	ra,24(sp)
    80000b66:	6442                	ld	s0,16(sp)
    80000b68:	64a2                	ld	s1,8(sp)
    80000b6a:	6105                	addi	sp,sp,32
    80000b6c:	8082                	ret
  release(&kmem.lock);
    80000b6e:	00011517          	auipc	a0,0x11
    80000b72:	dc250513          	addi	a0,a0,-574 # 80011930 <kmem>
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	14e080e7          	jalr	334(ra) # 80000cc4 <release>
  if(r)
    80000b7e:	b7d5                	j	80000b62 <kalloc+0x42>

0000000080000b80 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b80:	1141                	addi	sp,sp,-16
    80000b82:	e422                	sd	s0,8(sp)
    80000b84:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b86:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b88:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b8c:	00053823          	sd	zero,16(a0)
}
    80000b90:	6422                	ld	s0,8(sp)
    80000b92:	0141                	addi	sp,sp,16
    80000b94:	8082                	ret

0000000080000b96 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b96:	411c                	lw	a5,0(a0)
    80000b98:	e399                	bnez	a5,80000b9e <holding+0x8>
    80000b9a:	4501                	li	a0,0
  return r;
}
    80000b9c:	8082                	ret
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba8:	6904                	ld	s1,16(a0)
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	00a080e7          	jalr	10(ra) # 80001bb4 <mycpu>
    80000bb2:	40a48533          	sub	a0,s1,a0
    80000bb6:	00153513          	seqz	a0,a0
}
    80000bba:	60e2                	ld	ra,24(sp)
    80000bbc:	6442                	ld	s0,16(sp)
    80000bbe:	64a2                	ld	s1,8(sp)
    80000bc0:	6105                	addi	sp,sp,32
    80000bc2:	8082                	ret

0000000080000bc4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bc4:	1101                	addi	sp,sp,-32
    80000bc6:	ec06                	sd	ra,24(sp)
    80000bc8:	e822                	sd	s0,16(sp)
    80000bca:	e426                	sd	s1,8(sp)
    80000bcc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bce:	100024f3          	csrr	s1,sstatus
    80000bd2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bdc:	00001097          	auipc	ra,0x1
    80000be0:	fd8080e7          	jalr	-40(ra) # 80001bb4 <mycpu>
    80000be4:	5d3c                	lw	a5,120(a0)
    80000be6:	cf89                	beqz	a5,80000c00 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be8:	00001097          	auipc	ra,0x1
    80000bec:	fcc080e7          	jalr	-52(ra) # 80001bb4 <mycpu>
    80000bf0:	5d3c                	lw	a5,120(a0)
    80000bf2:	2785                	addiw	a5,a5,1
    80000bf4:	dd3c                	sw	a5,120(a0)
}
    80000bf6:	60e2                	ld	ra,24(sp)
    80000bf8:	6442                	ld	s0,16(sp)
    80000bfa:	64a2                	ld	s1,8(sp)
    80000bfc:	6105                	addi	sp,sp,32
    80000bfe:	8082                	ret
    mycpu()->intena = old;
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	fb4080e7          	jalr	-76(ra) # 80001bb4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c08:	8085                	srli	s1,s1,0x1
    80000c0a:	8885                	andi	s1,s1,1
    80000c0c:	dd64                	sw	s1,124(a0)
    80000c0e:	bfe9                	j	80000be8 <push_off+0x24>

0000000080000c10 <acquire>:
{
    80000c10:	1101                	addi	sp,sp,-32
    80000c12:	ec06                	sd	ra,24(sp)
    80000c14:	e822                	sd	s0,16(sp)
    80000c16:	e426                	sd	s1,8(sp)
    80000c18:	1000                	addi	s0,sp,32
    80000c1a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	fa8080e7          	jalr	-88(ra) # 80000bc4 <push_off>
  if(holding(lk))
    80000c24:	8526                	mv	a0,s1
    80000c26:	00000097          	auipc	ra,0x0
    80000c2a:	f70080e7          	jalr	-144(ra) # 80000b96 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c2e:	4705                	li	a4,1
  if(holding(lk))
    80000c30:	e115                	bnez	a0,80000c54 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c32:	87ba                	mv	a5,a4
    80000c34:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c38:	2781                	sext.w	a5,a5
    80000c3a:	ffe5                	bnez	a5,80000c32 <acquire+0x22>
  __sync_synchronize();
    80000c3c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	f74080e7          	jalr	-140(ra) # 80001bb4 <mycpu>
    80000c48:	e888                	sd	a0,16(s1)
}
    80000c4a:	60e2                	ld	ra,24(sp)
    80000c4c:	6442                	ld	s0,16(sp)
    80000c4e:	64a2                	ld	s1,8(sp)
    80000c50:	6105                	addi	sp,sp,32
    80000c52:	8082                	ret
    panic("acquire");
    80000c54:	00007517          	auipc	a0,0x7
    80000c58:	40c50513          	addi	a0,a0,1036 # 80008060 <digits+0x30>
    80000c5c:	00000097          	auipc	ra,0x0
    80000c60:	8ec080e7          	jalr	-1812(ra) # 80000548 <panic>

0000000080000c64 <pop_off>:

void
pop_off(void)
{
    80000c64:	1141                	addi	sp,sp,-16
    80000c66:	e406                	sd	ra,8(sp)
    80000c68:	e022                	sd	s0,0(sp)
    80000c6a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c6c:	00001097          	auipc	ra,0x1
    80000c70:	f48080e7          	jalr	-184(ra) # 80001bb4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c74:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c78:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7a:	e78d                	bnez	a5,80000ca4 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	02f05b63          	blez	a5,80000cb4 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c82:	37fd                	addiw	a5,a5,-1
    80000c84:	0007871b          	sext.w	a4,a5
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb09                	bnez	a4,80000c9c <pop_off+0x38>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00007517          	auipc	a0,0x7
    80000ca8:	3c450513          	addi	a0,a0,964 # 80008068 <digits+0x38>
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	89c080e7          	jalr	-1892(ra) # 80000548 <panic>
    panic("pop_off");
    80000cb4:	00007517          	auipc	a0,0x7
    80000cb8:	3cc50513          	addi	a0,a0,972 # 80008080 <digits+0x50>
    80000cbc:	00000097          	auipc	ra,0x0
    80000cc0:	88c080e7          	jalr	-1908(ra) # 80000548 <panic>

0000000080000cc4 <release>:
{
    80000cc4:	1101                	addi	sp,sp,-32
    80000cc6:	ec06                	sd	ra,24(sp)
    80000cc8:	e822                	sd	s0,16(sp)
    80000cca:	e426                	sd	s1,8(sp)
    80000ccc:	1000                	addi	s0,sp,32
    80000cce:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cd0:	00000097          	auipc	ra,0x0
    80000cd4:	ec6080e7          	jalr	-314(ra) # 80000b96 <holding>
    80000cd8:	c115                	beqz	a0,80000cfc <release+0x38>
  lk->cpu = 0;
    80000cda:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cde:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ce2:	0f50000f          	fence	iorw,ow
    80000ce6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	f7a080e7          	jalr	-134(ra) # 80000c64 <pop_off>
}
    80000cf2:	60e2                	ld	ra,24(sp)
    80000cf4:	6442                	ld	s0,16(sp)
    80000cf6:	64a2                	ld	s1,8(sp)
    80000cf8:	6105                	addi	sp,sp,32
    80000cfa:	8082                	ret
    panic("release");
    80000cfc:	00007517          	auipc	a0,0x7
    80000d00:	38c50513          	addi	a0,a0,908 # 80008088 <digits+0x58>
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	844080e7          	jalr	-1980(ra) # 80000548 <panic>

0000000080000d0c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d12:	ce09                	beqz	a2,80000d2c <memset+0x20>
    80000d14:	87aa                	mv	a5,a0
    80000d16:	fff6071b          	addiw	a4,a2,-1
    80000d1a:	1702                	slli	a4,a4,0x20
    80000d1c:	9301                	srli	a4,a4,0x20
    80000d1e:	0705                	addi	a4,a4,1
    80000d20:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d22:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d26:	0785                	addi	a5,a5,1
    80000d28:	fee79de3          	bne	a5,a4,80000d22 <memset+0x16>
  }
  return dst;
}
    80000d2c:	6422                	ld	s0,8(sp)
    80000d2e:	0141                	addi	sp,sp,16
    80000d30:	8082                	ret

0000000080000d32 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e422                	sd	s0,8(sp)
    80000d36:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d38:	ca05                	beqz	a2,80000d68 <memcmp+0x36>
    80000d3a:	fff6069b          	addiw	a3,a2,-1
    80000d3e:	1682                	slli	a3,a3,0x20
    80000d40:	9281                	srli	a3,a3,0x20
    80000d42:	0685                	addi	a3,a3,1
    80000d44:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d46:	00054783          	lbu	a5,0(a0)
    80000d4a:	0005c703          	lbu	a4,0(a1)
    80000d4e:	00e79863          	bne	a5,a4,80000d5e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d52:	0505                	addi	a0,a0,1
    80000d54:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d56:	fed518e3          	bne	a0,a3,80000d46 <memcmp+0x14>
  }

  return 0;
    80000d5a:	4501                	li	a0,0
    80000d5c:	a019                	j	80000d62 <memcmp+0x30>
      return *s1 - *s2;
    80000d5e:	40e7853b          	subw	a0,a5,a4
}
    80000d62:	6422                	ld	s0,8(sp)
    80000d64:	0141                	addi	sp,sp,16
    80000d66:	8082                	ret
  return 0;
    80000d68:	4501                	li	a0,0
    80000d6a:	bfe5                	j	80000d62 <memcmp+0x30>

0000000080000d6c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d6c:	1141                	addi	sp,sp,-16
    80000d6e:	e422                	sd	s0,8(sp)
    80000d70:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d72:	00a5f963          	bgeu	a1,a0,80000d84 <memmove+0x18>
    80000d76:	02061713          	slli	a4,a2,0x20
    80000d7a:	9301                	srli	a4,a4,0x20
    80000d7c:	00e587b3          	add	a5,a1,a4
    80000d80:	02f56563          	bltu	a0,a5,80000daa <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d84:	fff6069b          	addiw	a3,a2,-1
    80000d88:	ce11                	beqz	a2,80000da4 <memmove+0x38>
    80000d8a:	1682                	slli	a3,a3,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	0685                	addi	a3,a3,1
    80000d90:	96ae                	add	a3,a3,a1
    80000d92:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d94:	0585                	addi	a1,a1,1
    80000d96:	0785                	addi	a5,a5,1
    80000d98:	fff5c703          	lbu	a4,-1(a1)
    80000d9c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000da0:	fed59ae3          	bne	a1,a3,80000d94 <memmove+0x28>

  return dst;
}
    80000da4:	6422                	ld	s0,8(sp)
    80000da6:	0141                	addi	sp,sp,16
    80000da8:	8082                	ret
    d += n;
    80000daa:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000dac:	fff6069b          	addiw	a3,a2,-1
    80000db0:	da75                	beqz	a2,80000da4 <memmove+0x38>
    80000db2:	02069613          	slli	a2,a3,0x20
    80000db6:	9201                	srli	a2,a2,0x20
    80000db8:	fff64613          	not	a2,a2
    80000dbc:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000dbe:	17fd                	addi	a5,a5,-1
    80000dc0:	177d                	addi	a4,a4,-1
    80000dc2:	0007c683          	lbu	a3,0(a5)
    80000dc6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000dca:	fec79ae3          	bne	a5,a2,80000dbe <memmove+0x52>
    80000dce:	bfd9                	j	80000da4 <memmove+0x38>

0000000080000dd0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dd0:	1141                	addi	sp,sp,-16
    80000dd2:	e406                	sd	ra,8(sp)
    80000dd4:	e022                	sd	s0,0(sp)
    80000dd6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd8:	00000097          	auipc	ra,0x0
    80000ddc:	f94080e7          	jalr	-108(ra) # 80000d6c <memmove>
}
    80000de0:	60a2                	ld	ra,8(sp)
    80000de2:	6402                	ld	s0,0(sp)
    80000de4:	0141                	addi	sp,sp,16
    80000de6:	8082                	ret

0000000080000de8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000de8:	1141                	addi	sp,sp,-16
    80000dea:	e422                	sd	s0,8(sp)
    80000dec:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dee:	ce11                	beqz	a2,80000e0a <strncmp+0x22>
    80000df0:	00054783          	lbu	a5,0(a0)
    80000df4:	cf89                	beqz	a5,80000e0e <strncmp+0x26>
    80000df6:	0005c703          	lbu	a4,0(a1)
    80000dfa:	00f71a63          	bne	a4,a5,80000e0e <strncmp+0x26>
    n--, p++, q++;
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	0505                	addi	a0,a0,1
    80000e02:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e04:	f675                	bnez	a2,80000df0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e06:	4501                	li	a0,0
    80000e08:	a809                	j	80000e1a <strncmp+0x32>
    80000e0a:	4501                	li	a0,0
    80000e0c:	a039                	j	80000e1a <strncmp+0x32>
  if(n == 0)
    80000e0e:	ca09                	beqz	a2,80000e20 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e10:	00054503          	lbu	a0,0(a0)
    80000e14:	0005c783          	lbu	a5,0(a1)
    80000e18:	9d1d                	subw	a0,a0,a5
}
    80000e1a:	6422                	ld	s0,8(sp)
    80000e1c:	0141                	addi	sp,sp,16
    80000e1e:	8082                	ret
    return 0;
    80000e20:	4501                	li	a0,0
    80000e22:	bfe5                	j	80000e1a <strncmp+0x32>

0000000080000e24 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e422                	sd	s0,8(sp)
    80000e28:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e2a:	872a                	mv	a4,a0
    80000e2c:	8832                	mv	a6,a2
    80000e2e:	367d                	addiw	a2,a2,-1
    80000e30:	01005963          	blez	a6,80000e42 <strncpy+0x1e>
    80000e34:	0705                	addi	a4,a4,1
    80000e36:	0005c783          	lbu	a5,0(a1)
    80000e3a:	fef70fa3          	sb	a5,-1(a4)
    80000e3e:	0585                	addi	a1,a1,1
    80000e40:	f7f5                	bnez	a5,80000e2c <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e42:	00c05d63          	blez	a2,80000e5c <strncpy+0x38>
    80000e46:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e48:	0685                	addi	a3,a3,1
    80000e4a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e4e:	fff6c793          	not	a5,a3
    80000e52:	9fb9                	addw	a5,a5,a4
    80000e54:	010787bb          	addw	a5,a5,a6
    80000e58:	fef048e3          	bgtz	a5,80000e48 <strncpy+0x24>
  return os;
}
    80000e5c:	6422                	ld	s0,8(sp)
    80000e5e:	0141                	addi	sp,sp,16
    80000e60:	8082                	ret

0000000080000e62 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e422                	sd	s0,8(sp)
    80000e66:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e68:	02c05363          	blez	a2,80000e8e <safestrcpy+0x2c>
    80000e6c:	fff6069b          	addiw	a3,a2,-1
    80000e70:	1682                	slli	a3,a3,0x20
    80000e72:	9281                	srli	a3,a3,0x20
    80000e74:	96ae                	add	a3,a3,a1
    80000e76:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e78:	00d58963          	beq	a1,a3,80000e8a <safestrcpy+0x28>
    80000e7c:	0585                	addi	a1,a1,1
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	fff5c703          	lbu	a4,-1(a1)
    80000e84:	fee78fa3          	sb	a4,-1(a5)
    80000e88:	fb65                	bnez	a4,80000e78 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e8a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e8e:	6422                	ld	s0,8(sp)
    80000e90:	0141                	addi	sp,sp,16
    80000e92:	8082                	ret

0000000080000e94 <strlen>:

int
strlen(const char *s)
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e422                	sd	s0,8(sp)
    80000e98:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e9a:	00054783          	lbu	a5,0(a0)
    80000e9e:	cf91                	beqz	a5,80000eba <strlen+0x26>
    80000ea0:	0505                	addi	a0,a0,1
    80000ea2:	87aa                	mv	a5,a0
    80000ea4:	4685                	li	a3,1
    80000ea6:	9e89                	subw	a3,a3,a0
    80000ea8:	00f6853b          	addw	a0,a3,a5
    80000eac:	0785                	addi	a5,a5,1
    80000eae:	fff7c703          	lbu	a4,-1(a5)
    80000eb2:	fb7d                	bnez	a4,80000ea8 <strlen+0x14>
    ;
  return n;
}
    80000eb4:	6422                	ld	s0,8(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eba:	4501                	li	a0,0
    80000ebc:	bfe5                	j	80000eb4 <strlen+0x20>

0000000080000ebe <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ebe:	1141                	addi	sp,sp,-16
    80000ec0:	e406                	sd	ra,8(sp)
    80000ec2:	e022                	sd	s0,0(sp)
    80000ec4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ec6:	00001097          	auipc	ra,0x1
    80000eca:	cde080e7          	jalr	-802(ra) # 80001ba4 <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ece:	00008717          	auipc	a4,0x8
    80000ed2:	13e70713          	addi	a4,a4,318 # 8000900c <started>
  if(cpuid() == 0){
    80000ed6:	c139                	beqz	a0,80000f1c <main+0x5e>
    while(started == 0)
    80000ed8:	431c                	lw	a5,0(a4)
    80000eda:	2781                	sext.w	a5,a5
    80000edc:	dff5                	beqz	a5,80000ed8 <main+0x1a>
      ;
    __sync_synchronize();
    80000ede:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ee2:	00001097          	auipc	ra,0x1
    80000ee6:	cc2080e7          	jalr	-830(ra) # 80001ba4 <cpuid>
    80000eea:	85aa                	mv	a1,a0
    80000eec:	00007517          	auipc	a0,0x7
    80000ef0:	1bc50513          	addi	a0,a0,444 # 800080a8 <digits+0x78>
    80000ef4:	fffff097          	auipc	ra,0xfffff
    80000ef8:	69e080e7          	jalr	1694(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	0e0080e7          	jalr	224(ra) # 80000fdc <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f04:	00002097          	auipc	ra,0x2
    80000f08:	afa080e7          	jalr	-1286(ra) # 800029fe <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f0c:	00005097          	auipc	ra,0x5
    80000f10:	0e4080e7          	jalr	228(ra) # 80005ff0 <plicinithart>
  }

  scheduler();        
    80000f14:	00001097          	auipc	ra,0x1
    80000f18:	3b4080e7          	jalr	948(ra) # 800022c8 <scheduler>
    consoleinit();
    80000f1c:	fffff097          	auipc	ra,0xfffff
    80000f20:	53e080e7          	jalr	1342(ra) # 8000045a <consoleinit>
    statsinit();
    80000f24:	00006097          	auipc	ra,0x6
    80000f28:	89a080e7          	jalr	-1894(ra) # 800067be <statsinit>
    printfinit();
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	84c080e7          	jalr	-1972(ra) # 80000778 <printfinit>
    printf("\n");
    80000f34:	00007517          	auipc	a0,0x7
    80000f38:	18450513          	addi	a0,a0,388 # 800080b8 <digits+0x88>
    80000f3c:	fffff097          	auipc	ra,0xfffff
    80000f40:	656080e7          	jalr	1622(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000f44:	00007517          	auipc	a0,0x7
    80000f48:	14c50513          	addi	a0,a0,332 # 80008090 <digits+0x60>
    80000f4c:	fffff097          	auipc	ra,0xfffff
    80000f50:	646080e7          	jalr	1606(ra) # 80000592 <printf>
    printf("\n");
    80000f54:	00007517          	auipc	a0,0x7
    80000f58:	16450513          	addi	a0,a0,356 # 800080b8 <digits+0x88>
    80000f5c:	fffff097          	auipc	ra,0xfffff
    80000f60:	636080e7          	jalr	1590(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	b80080e7          	jalr	-1152(ra) # 80000ae4 <kinit>
    kvminit();       // create kernel page table
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	312080e7          	jalr	786(ra) # 8000127e <kvminit>
    kvminithart();   // turn on paging
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	068080e7          	jalr	104(ra) # 80000fdc <kvminithart>
    procinit();      // process table
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	bc0080e7          	jalr	-1088(ra) # 80001b3c <procinit>
    trapinit();      // trap vectors
    80000f84:	00002097          	auipc	ra,0x2
    80000f88:	a52080e7          	jalr	-1454(ra) # 800029d6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f8c:	00002097          	auipc	ra,0x2
    80000f90:	a72080e7          	jalr	-1422(ra) # 800029fe <trapinithart>
    plicinit();      // set up interrupt controller
    80000f94:	00005097          	auipc	ra,0x5
    80000f98:	046080e7          	jalr	70(ra) # 80005fda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f9c:	00005097          	auipc	ra,0x5
    80000fa0:	054080e7          	jalr	84(ra) # 80005ff0 <plicinithart>
    binit();         // buffer cache
    80000fa4:	00002097          	auipc	ra,0x2
    80000fa8:	19c080e7          	jalr	412(ra) # 80003140 <binit>
    iinit();         // inode cache
    80000fac:	00003097          	auipc	ra,0x3
    80000fb0:	82c080e7          	jalr	-2004(ra) # 800037d8 <iinit>
    fileinit();      // file table
    80000fb4:	00003097          	auipc	ra,0x3
    80000fb8:	7c6080e7          	jalr	1990(ra) # 8000477a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fbc:	00005097          	auipc	ra,0x5
    80000fc0:	13c080e7          	jalr	316(ra) # 800060f8 <virtio_disk_init>
    userinit();      // first user process
    80000fc4:	00001097          	auipc	ra,0x1
    80000fc8:	ff6080e7          	jalr	-10(ra) # 80001fba <userinit>
    __sync_synchronize();
    80000fcc:	0ff0000f          	fence
    started = 1;
    80000fd0:	4785                	li	a5,1
    80000fd2:	00008717          	auipc	a4,0x8
    80000fd6:	02f72d23          	sw	a5,58(a4) # 8000900c <started>
    80000fda:	bf2d                	j	80000f14 <main+0x56>

0000000080000fdc <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fdc:	1141                	addi	sp,sp,-16
    80000fde:	e422                	sd	s0,8(sp)
    80000fe0:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fe2:	00008797          	auipc	a5,0x8
    80000fe6:	02e7b783          	ld	a5,46(a5) # 80009010 <kernel_pagetable>
    80000fea:	83b1                	srli	a5,a5,0xc
    80000fec:	577d                	li	a4,-1
    80000fee:	177e                	slli	a4,a4,0x3f
    80000ff0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000ff2:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ff6:	12000073          	sfence.vma
  sfence_vma();
}
    80000ffa:	6422                	ld	s0,8(sp)
    80000ffc:	0141                	addi	sp,sp,16
    80000ffe:	8082                	ret

0000000080001000 <vminithart>:

void 
vminithart(pagetable_t pagetable)
{
    80001000:	1141                	addi	sp,sp,-16
    80001002:	e422                	sd	s0,8(sp)
    80001004:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(pagetable));
    80001006:	8131                	srli	a0,a0,0xc
    80001008:	57fd                	li	a5,-1
    8000100a:	17fe                	slli	a5,a5,0x3f
    8000100c:	8d5d                	or	a0,a0,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000100e:	18051073          	csrw	satp,a0
  asm volatile("sfence.vma zero, zero");
    80001012:	12000073          	sfence.vma
  sfence_vma();
}
    80001016:	6422                	ld	s0,8(sp)
    80001018:	0141                	addi	sp,sp,16
    8000101a:	8082                	ret

000000008000101c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000101c:	7139                	addi	sp,sp,-64
    8000101e:	fc06                	sd	ra,56(sp)
    80001020:	f822                	sd	s0,48(sp)
    80001022:	f426                	sd	s1,40(sp)
    80001024:	f04a                	sd	s2,32(sp)
    80001026:	ec4e                	sd	s3,24(sp)
    80001028:	e852                	sd	s4,16(sp)
    8000102a:	e456                	sd	s5,8(sp)
    8000102c:	e05a                	sd	s6,0(sp)
    8000102e:	0080                	addi	s0,sp,64
    80001030:	84aa                	mv	s1,a0
    80001032:	89ae                	mv	s3,a1
    80001034:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001036:	57fd                	li	a5,-1
    80001038:	83e9                	srli	a5,a5,0x1a
    8000103a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000103c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000103e:	04b7f263          	bgeu	a5,a1,80001082 <walk+0x66>
    panic("walk");
    80001042:	00007517          	auipc	a0,0x7
    80001046:	07e50513          	addi	a0,a0,126 # 800080c0 <digits+0x90>
    8000104a:	fffff097          	auipc	ra,0xfffff
    8000104e:	4fe080e7          	jalr	1278(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001052:	060a8663          	beqz	s5,800010be <walk+0xa2>
    80001056:	00000097          	auipc	ra,0x0
    8000105a:	aca080e7          	jalr	-1334(ra) # 80000b20 <kalloc>
    8000105e:	84aa                	mv	s1,a0
    80001060:	c529                	beqz	a0,800010aa <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001062:	6605                	lui	a2,0x1
    80001064:	4581                	li	a1,0
    80001066:	00000097          	auipc	ra,0x0
    8000106a:	ca6080e7          	jalr	-858(ra) # 80000d0c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000106e:	00c4d793          	srli	a5,s1,0xc
    80001072:	07aa                	slli	a5,a5,0xa
    80001074:	0017e793          	ori	a5,a5,1
    80001078:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000107c:	3a5d                	addiw	s4,s4,-9
    8000107e:	036a0063          	beq	s4,s6,8000109e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001082:	0149d933          	srl	s2,s3,s4
    80001086:	1ff97913          	andi	s2,s2,511
    8000108a:	090e                	slli	s2,s2,0x3
    8000108c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000108e:	00093483          	ld	s1,0(s2)
    80001092:	0014f793          	andi	a5,s1,1
    80001096:	dfd5                	beqz	a5,80001052 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001098:	80a9                	srli	s1,s1,0xa
    8000109a:	04b2                	slli	s1,s1,0xc
    8000109c:	b7c5                	j	8000107c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000109e:	00c9d513          	srli	a0,s3,0xc
    800010a2:	1ff57513          	andi	a0,a0,511
    800010a6:	050e                	slli	a0,a0,0x3
    800010a8:	9526                	add	a0,a0,s1
}
    800010aa:	70e2                	ld	ra,56(sp)
    800010ac:	7442                	ld	s0,48(sp)
    800010ae:	74a2                	ld	s1,40(sp)
    800010b0:	7902                	ld	s2,32(sp)
    800010b2:	69e2                	ld	s3,24(sp)
    800010b4:	6a42                	ld	s4,16(sp)
    800010b6:	6aa2                	ld	s5,8(sp)
    800010b8:	6b02                	ld	s6,0(sp)
    800010ba:	6121                	addi	sp,sp,64
    800010bc:	8082                	ret
        return 0;
    800010be:	4501                	li	a0,0
    800010c0:	b7ed                	j	800010aa <walk+0x8e>

00000000800010c2 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010c2:	57fd                	li	a5,-1
    800010c4:	83e9                	srli	a5,a5,0x1a
    800010c6:	00b7f463          	bgeu	a5,a1,800010ce <walkaddr+0xc>
    return 0;
    800010ca:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010cc:	8082                	ret
{
    800010ce:	1141                	addi	sp,sp,-16
    800010d0:	e406                	sd	ra,8(sp)
    800010d2:	e022                	sd	s0,0(sp)
    800010d4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010d6:	4601                	li	a2,0
    800010d8:	00000097          	auipc	ra,0x0
    800010dc:	f44080e7          	jalr	-188(ra) # 8000101c <walk>
  if(pte == 0)
    800010e0:	c105                	beqz	a0,80001100 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010e2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010e4:	0117f693          	andi	a3,a5,17
    800010e8:	4745                	li	a4,17
    return 0;
    800010ea:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010ec:	00e68663          	beq	a3,a4,800010f8 <walkaddr+0x36>
}
    800010f0:	60a2                	ld	ra,8(sp)
    800010f2:	6402                	ld	s0,0(sp)
    800010f4:	0141                	addi	sp,sp,16
    800010f6:	8082                	ret
  pa = PTE2PA(*pte);
    800010f8:	00a7d513          	srli	a0,a5,0xa
    800010fc:	0532                	slli	a0,a0,0xc
  return pa;
    800010fe:	bfcd                	j	800010f0 <walkaddr+0x2e>
    return 0;
    80001100:	4501                	li	a0,0
    80001102:	b7fd                	j	800010f0 <walkaddr+0x2e>

0000000080001104 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001104:	1101                	addi	sp,sp,-32
    80001106:	ec06                	sd	ra,24(sp)
    80001108:	e822                	sd	s0,16(sp)
    8000110a:	e426                	sd	s1,8(sp)
    8000110c:	1000                	addi	s0,sp,32
    8000110e:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001110:	1552                	slli	a0,a0,0x34
    80001112:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001116:	4601                	li	a2,0
    80001118:	00008517          	auipc	a0,0x8
    8000111c:	ef853503          	ld	a0,-264(a0) # 80009010 <kernel_pagetable>
    80001120:	00000097          	auipc	ra,0x0
    80001124:	efc080e7          	jalr	-260(ra) # 8000101c <walk>
  if(pte == 0)
    80001128:	cd09                	beqz	a0,80001142 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000112a:	6108                	ld	a0,0(a0)
    8000112c:	00157793          	andi	a5,a0,1
    80001130:	c38d                	beqz	a5,80001152 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001132:	8129                	srli	a0,a0,0xa
    80001134:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001136:	9526                	add	a0,a0,s1
    80001138:	60e2                	ld	ra,24(sp)
    8000113a:	6442                	ld	s0,16(sp)
    8000113c:	64a2                	ld	s1,8(sp)
    8000113e:	6105                	addi	sp,sp,32
    80001140:	8082                	ret
    panic("kvmpa");
    80001142:	00007517          	auipc	a0,0x7
    80001146:	f8650513          	addi	a0,a0,-122 # 800080c8 <digits+0x98>
    8000114a:	fffff097          	auipc	ra,0xfffff
    8000114e:	3fe080e7          	jalr	1022(ra) # 80000548 <panic>
    panic("kvmpa");
    80001152:	00007517          	auipc	a0,0x7
    80001156:	f7650513          	addi	a0,a0,-138 # 800080c8 <digits+0x98>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	3ee080e7          	jalr	1006(ra) # 80000548 <panic>

0000000080001162 <vmpa>:

uint64
vmpa(pagetable_t pagetable, uint64 va)
{
    80001162:	1101                	addi	sp,sp,-32
    80001164:	ec06                	sd	ra,24(sp)
    80001166:	e822                	sd	s0,16(sp)
    80001168:	e426                	sd	s1,8(sp)
    8000116a:	1000                	addi	s0,sp,32
  uint64 off = va % PGSIZE;
    8000116c:	03459793          	slli	a5,a1,0x34
    80001170:	0347d493          	srli	s1,a5,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(pagetable, va, 0);
    80001174:	4601                	li	a2,0
    80001176:	00000097          	auipc	ra,0x0
    8000117a:	ea6080e7          	jalr	-346(ra) # 8000101c <walk>
  if(pte == 0)
    8000117e:	cd09                	beqz	a0,80001198 <vmpa+0x36>
    panic("vmpa");
  if((*pte & PTE_V) == 0)
    80001180:	6108                	ld	a0,0(a0)
    80001182:	00157793          	andi	a5,a0,1
    80001186:	c38d                	beqz	a5,800011a8 <vmpa+0x46>
    panic("vmpa");
  pa = PTE2PA(*pte);
    80001188:	8129                	srli	a0,a0,0xa
    8000118a:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000118c:	9526                	add	a0,a0,s1
    8000118e:	60e2                	ld	ra,24(sp)
    80001190:	6442                	ld	s0,16(sp)
    80001192:	64a2                	ld	s1,8(sp)
    80001194:	6105                	addi	sp,sp,32
    80001196:	8082                	ret
    panic("vmpa");
    80001198:	00007517          	auipc	a0,0x7
    8000119c:	f3850513          	addi	a0,a0,-200 # 800080d0 <digits+0xa0>
    800011a0:	fffff097          	auipc	ra,0xfffff
    800011a4:	3a8080e7          	jalr	936(ra) # 80000548 <panic>
    panic("vmpa");
    800011a8:	00007517          	auipc	a0,0x7
    800011ac:	f2850513          	addi	a0,a0,-216 # 800080d0 <digits+0xa0>
    800011b0:	fffff097          	auipc	ra,0xfffff
    800011b4:	398080e7          	jalr	920(ra) # 80000548 <panic>

00000000800011b8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011b8:	715d                	addi	sp,sp,-80
    800011ba:	e486                	sd	ra,72(sp)
    800011bc:	e0a2                	sd	s0,64(sp)
    800011be:	fc26                	sd	s1,56(sp)
    800011c0:	f84a                	sd	s2,48(sp)
    800011c2:	f44e                	sd	s3,40(sp)
    800011c4:	f052                	sd	s4,32(sp)
    800011c6:	ec56                	sd	s5,24(sp)
    800011c8:	e85a                	sd	s6,16(sp)
    800011ca:	e45e                	sd	s7,8(sp)
    800011cc:	0880                	addi	s0,sp,80
    800011ce:	8aaa                	mv	s5,a0
    800011d0:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011d2:	777d                	lui	a4,0xfffff
    800011d4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011d8:	167d                	addi	a2,a2,-1
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011e2:	893e                	mv	s2,a5
    800011e4:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011e8:	6b85                	lui	s7,0x1
    800011ea:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011ee:	4605                	li	a2,1
    800011f0:	85ca                	mv	a1,s2
    800011f2:	8556                	mv	a0,s5
    800011f4:	00000097          	auipc	ra,0x0
    800011f8:	e28080e7          	jalr	-472(ra) # 8000101c <walk>
    800011fc:	c51d                	beqz	a0,8000122a <mappages+0x72>
    if(*pte & PTE_V)
    800011fe:	611c                	ld	a5,0(a0)
    80001200:	8b85                	andi	a5,a5,1
    80001202:	ef81                	bnez	a5,8000121a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001204:	80b1                	srli	s1,s1,0xc
    80001206:	04aa                	slli	s1,s1,0xa
    80001208:	0164e4b3          	or	s1,s1,s6
    8000120c:	0014e493          	ori	s1,s1,1
    80001210:	e104                	sd	s1,0(a0)
    if(a == last)
    80001212:	03390863          	beq	s2,s3,80001242 <mappages+0x8a>
    a += PGSIZE;
    80001216:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001218:	bfc9                	j	800011ea <mappages+0x32>
      panic("remap");
    8000121a:	00007517          	auipc	a0,0x7
    8000121e:	ebe50513          	addi	a0,a0,-322 # 800080d8 <digits+0xa8>
    80001222:	fffff097          	auipc	ra,0xfffff
    80001226:	326080e7          	jalr	806(ra) # 80000548 <panic>
      return -1;
    8000122a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000122c:	60a6                	ld	ra,72(sp)
    8000122e:	6406                	ld	s0,64(sp)
    80001230:	74e2                	ld	s1,56(sp)
    80001232:	7942                	ld	s2,48(sp)
    80001234:	79a2                	ld	s3,40(sp)
    80001236:	7a02                	ld	s4,32(sp)
    80001238:	6ae2                	ld	s5,24(sp)
    8000123a:	6b42                	ld	s6,16(sp)
    8000123c:	6ba2                	ld	s7,8(sp)
    8000123e:	6161                	addi	sp,sp,80
    80001240:	8082                	ret
  return 0;
    80001242:	4501                	li	a0,0
    80001244:	b7e5                	j	8000122c <mappages+0x74>

0000000080001246 <kvmmap>:
{
    80001246:	1141                	addi	sp,sp,-16
    80001248:	e406                	sd	ra,8(sp)
    8000124a:	e022                	sd	s0,0(sp)
    8000124c:	0800                	addi	s0,sp,16
    8000124e:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001250:	86ae                	mv	a3,a1
    80001252:	85aa                	mv	a1,a0
    80001254:	00008517          	auipc	a0,0x8
    80001258:	dbc53503          	ld	a0,-580(a0) # 80009010 <kernel_pagetable>
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	f5c080e7          	jalr	-164(ra) # 800011b8 <mappages>
    80001264:	e509                	bnez	a0,8000126e <kvmmap+0x28>
}
    80001266:	60a2                	ld	ra,8(sp)
    80001268:	6402                	ld	s0,0(sp)
    8000126a:	0141                	addi	sp,sp,16
    8000126c:	8082                	ret
    panic("kvmmap");
    8000126e:	00007517          	auipc	a0,0x7
    80001272:	e7250513          	addi	a0,a0,-398 # 800080e0 <digits+0xb0>
    80001276:	fffff097          	auipc	ra,0xfffff
    8000127a:	2d2080e7          	jalr	722(ra) # 80000548 <panic>

000000008000127e <kvminit>:
{
    8000127e:	1101                	addi	sp,sp,-32
    80001280:	ec06                	sd	ra,24(sp)
    80001282:	e822                	sd	s0,16(sp)
    80001284:	e426                	sd	s1,8(sp)
    80001286:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	898080e7          	jalr	-1896(ra) # 80000b20 <kalloc>
    80001290:	00008797          	auipc	a5,0x8
    80001294:	d8a7b023          	sd	a0,-640(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001298:	6605                	lui	a2,0x1
    8000129a:	4581                	li	a1,0
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	a70080e7          	jalr	-1424(ra) # 80000d0c <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012a4:	4699                	li	a3,6
    800012a6:	6605                	lui	a2,0x1
    800012a8:	100005b7          	lui	a1,0x10000
    800012ac:	10000537          	lui	a0,0x10000
    800012b0:	00000097          	auipc	ra,0x0
    800012b4:	f96080e7          	jalr	-106(ra) # 80001246 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012b8:	4699                	li	a3,6
    800012ba:	6605                	lui	a2,0x1
    800012bc:	100015b7          	lui	a1,0x10001
    800012c0:	10001537          	lui	a0,0x10001
    800012c4:	00000097          	auipc	ra,0x0
    800012c8:	f82080e7          	jalr	-126(ra) # 80001246 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800012cc:	4699                	li	a3,6
    800012ce:	6641                	lui	a2,0x10
    800012d0:	020005b7          	lui	a1,0x2000
    800012d4:	02000537          	lui	a0,0x2000
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	f6e080e7          	jalr	-146(ra) # 80001246 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012e0:	4699                	li	a3,6
    800012e2:	00400637          	lui	a2,0x400
    800012e6:	0c0005b7          	lui	a1,0xc000
    800012ea:	0c000537          	lui	a0,0xc000
    800012ee:	00000097          	auipc	ra,0x0
    800012f2:	f58080e7          	jalr	-168(ra) # 80001246 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012f6:	00007497          	auipc	s1,0x7
    800012fa:	d0a48493          	addi	s1,s1,-758 # 80008000 <etext>
    800012fe:	46a9                	li	a3,10
    80001300:	80007617          	auipc	a2,0x80007
    80001304:	d0060613          	addi	a2,a2,-768 # 8000 <_entry-0x7fff8000>
    80001308:	4585                	li	a1,1
    8000130a:	05fe                	slli	a1,a1,0x1f
    8000130c:	852e                	mv	a0,a1
    8000130e:	00000097          	auipc	ra,0x0
    80001312:	f38080e7          	jalr	-200(ra) # 80001246 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001316:	4699                	li	a3,6
    80001318:	4645                	li	a2,17
    8000131a:	066e                	slli	a2,a2,0x1b
    8000131c:	8e05                	sub	a2,a2,s1
    8000131e:	85a6                	mv	a1,s1
    80001320:	8526                	mv	a0,s1
    80001322:	00000097          	auipc	ra,0x0
    80001326:	f24080e7          	jalr	-220(ra) # 80001246 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000132a:	46a9                	li	a3,10
    8000132c:	6605                	lui	a2,0x1
    8000132e:	00006597          	auipc	a1,0x6
    80001332:	cd258593          	addi	a1,a1,-814 # 80007000 <_trampoline>
    80001336:	04000537          	lui	a0,0x4000
    8000133a:	157d                	addi	a0,a0,-1
    8000133c:	0532                	slli	a0,a0,0xc
    8000133e:	00000097          	auipc	ra,0x0
    80001342:	f08080e7          	jalr	-248(ra) # 80001246 <kvmmap>
}
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	addi	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <vmmap>:
{
    80001350:	1141                	addi	sp,sp,-16
    80001352:	e406                	sd	ra,8(sp)
    80001354:	e022                	sd	s0,0(sp)
    80001356:	0800                	addi	s0,sp,16
    80001358:	87b6                	mv	a5,a3
  if(mappages(pagetable, va, sz, pa, perm) != 0) 
    8000135a:	86b2                	mv	a3,a2
    8000135c:	863e                	mv	a2,a5
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	e5a080e7          	jalr	-422(ra) # 800011b8 <mappages>
    80001366:	e509                	bnez	a0,80001370 <vmmap+0x20>
}
    80001368:	60a2                	ld	ra,8(sp)
    8000136a:	6402                	ld	s0,0(sp)
    8000136c:	0141                	addi	sp,sp,16
    8000136e:	8082                	ret
    panic("vmmap");
    80001370:	00007517          	auipc	a0,0x7
    80001374:	d7850513          	addi	a0,a0,-648 # 800080e8 <digits+0xb8>
    80001378:	fffff097          	auipc	ra,0xfffff
    8000137c:	1d0080e7          	jalr	464(ra) # 80000548 <panic>

0000000080001380 <vminit>:
{
    80001380:	1101                	addi	sp,sp,-32
    80001382:	ec06                	sd	ra,24(sp)
    80001384:	e822                	sd	s0,16(sp)
    80001386:	e426                	sd	s1,8(sp)
    80001388:	e04a                	sd	s2,0(sp)
    8000138a:	1000                	addi	s0,sp,32
    8000138c:	84aa                	mv	s1,a0
  vmmap(pagetable, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000138e:	4719                	li	a4,6
    80001390:	6685                	lui	a3,0x1
    80001392:	10000637          	lui	a2,0x10000
    80001396:	100005b7          	lui	a1,0x10000
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	fb6080e7          	jalr	-74(ra) # 80001350 <vmmap>
  vmmap(pagetable, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013a2:	4719                	li	a4,6
    800013a4:	6685                	lui	a3,0x1
    800013a6:	10001637          	lui	a2,0x10001
    800013aa:	100015b7          	lui	a1,0x10001
    800013ae:	8526                	mv	a0,s1
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	fa0080e7          	jalr	-96(ra) # 80001350 <vmmap>
  vmmap(pagetable, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013b8:	4719                	li	a4,6
    800013ba:	004006b7          	lui	a3,0x400
    800013be:	0c000637          	lui	a2,0xc000
    800013c2:	0c0005b7          	lui	a1,0xc000
    800013c6:	8526                	mv	a0,s1
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	f88080e7          	jalr	-120(ra) # 80001350 <vmmap>
  vmmap(pagetable, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013d0:	00007917          	auipc	s2,0x7
    800013d4:	c3090913          	addi	s2,s2,-976 # 80008000 <etext>
    800013d8:	4729                	li	a4,10
    800013da:	80007697          	auipc	a3,0x80007
    800013de:	c2668693          	addi	a3,a3,-986 # 8000 <_entry-0x7fff8000>
    800013e2:	4605                	li	a2,1
    800013e4:	067e                	slli	a2,a2,0x1f
    800013e6:	85b2                	mv	a1,a2
    800013e8:	8526                	mv	a0,s1
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	f66080e7          	jalr	-154(ra) # 80001350 <vmmap>
  vmmap(pagetable, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800013f2:	4719                	li	a4,6
    800013f4:	46c5                	li	a3,17
    800013f6:	06ee                	slli	a3,a3,0x1b
    800013f8:	412686b3          	sub	a3,a3,s2
    800013fc:	864a                	mv	a2,s2
    800013fe:	85ca                	mv	a1,s2
    80001400:	8526                	mv	a0,s1
    80001402:	00000097          	auipc	ra,0x0
    80001406:	f4e080e7          	jalr	-178(ra) # 80001350 <vmmap>
  vmmap(pagetable, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000140a:	4729                	li	a4,10
    8000140c:	6685                	lui	a3,0x1
    8000140e:	00006617          	auipc	a2,0x6
    80001412:	bf260613          	addi	a2,a2,-1038 # 80007000 <_trampoline>
    80001416:	040005b7          	lui	a1,0x4000
    8000141a:	15fd                	addi	a1,a1,-1
    8000141c:	05b2                	slli	a1,a1,0xc
    8000141e:	8526                	mv	a0,s1
    80001420:	00000097          	auipc	ra,0x0
    80001424:	f30080e7          	jalr	-208(ra) # 80001350 <vmmap>
}
    80001428:	60e2                	ld	ra,24(sp)
    8000142a:	6442                	ld	s0,16(sp)
    8000142c:	64a2                	ld	s1,8(sp)
    8000142e:	6902                	ld	s2,0(sp)
    80001430:	6105                	addi	sp,sp,32
    80001432:	8082                	ret

0000000080001434 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001434:	715d                	addi	sp,sp,-80
    80001436:	e486                	sd	ra,72(sp)
    80001438:	e0a2                	sd	s0,64(sp)
    8000143a:	fc26                	sd	s1,56(sp)
    8000143c:	f84a                	sd	s2,48(sp)
    8000143e:	f44e                	sd	s3,40(sp)
    80001440:	f052                	sd	s4,32(sp)
    80001442:	ec56                	sd	s5,24(sp)
    80001444:	e85a                	sd	s6,16(sp)
    80001446:	e45e                	sd	s7,8(sp)
    80001448:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000144a:	03459793          	slli	a5,a1,0x34
    8000144e:	e795                	bnez	a5,8000147a <uvmunmap+0x46>
    80001450:	8a2a                	mv	s4,a0
    80001452:	892e                	mv	s2,a1
    80001454:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001456:	0632                	slli	a2,a2,0xc
    80001458:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000145c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000145e:	6b05                	lui	s6,0x1
    80001460:	0735e863          	bltu	a1,s3,800014d0 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001464:	60a6                	ld	ra,72(sp)
    80001466:	6406                	ld	s0,64(sp)
    80001468:	74e2                	ld	s1,56(sp)
    8000146a:	7942                	ld	s2,48(sp)
    8000146c:	79a2                	ld	s3,40(sp)
    8000146e:	7a02                	ld	s4,32(sp)
    80001470:	6ae2                	ld	s5,24(sp)
    80001472:	6b42                	ld	s6,16(sp)
    80001474:	6ba2                	ld	s7,8(sp)
    80001476:	6161                	addi	sp,sp,80
    80001478:	8082                	ret
    panic("uvmunmap: not aligned");
    8000147a:	00007517          	auipc	a0,0x7
    8000147e:	c7650513          	addi	a0,a0,-906 # 800080f0 <digits+0xc0>
    80001482:	fffff097          	auipc	ra,0xfffff
    80001486:	0c6080e7          	jalr	198(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    8000148a:	00007517          	auipc	a0,0x7
    8000148e:	c7e50513          	addi	a0,a0,-898 # 80008108 <digits+0xd8>
    80001492:	fffff097          	auipc	ra,0xfffff
    80001496:	0b6080e7          	jalr	182(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    8000149a:	00007517          	auipc	a0,0x7
    8000149e:	c7e50513          	addi	a0,a0,-898 # 80008118 <digits+0xe8>
    800014a2:	fffff097          	auipc	ra,0xfffff
    800014a6:	0a6080e7          	jalr	166(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800014aa:	00007517          	auipc	a0,0x7
    800014ae:	c8650513          	addi	a0,a0,-890 # 80008130 <digits+0x100>
    800014b2:	fffff097          	auipc	ra,0xfffff
    800014b6:	096080e7          	jalr	150(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    800014ba:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800014bc:	0532                	slli	a0,a0,0xc
    800014be:	fffff097          	auipc	ra,0xfffff
    800014c2:	566080e7          	jalr	1382(ra) # 80000a24 <kfree>
    *pte = 0;
    800014c6:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014ca:	995a                	add	s2,s2,s6
    800014cc:	f9397ce3          	bgeu	s2,s3,80001464 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800014d0:	4601                	li	a2,0
    800014d2:	85ca                	mv	a1,s2
    800014d4:	8552                	mv	a0,s4
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	b46080e7          	jalr	-1210(ra) # 8000101c <walk>
    800014de:	84aa                	mv	s1,a0
    800014e0:	d54d                	beqz	a0,8000148a <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800014e2:	6108                	ld	a0,0(a0)
    800014e4:	00157793          	andi	a5,a0,1
    800014e8:	dbcd                	beqz	a5,8000149a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800014ea:	3ff57793          	andi	a5,a0,1023
    800014ee:	fb778ee3          	beq	a5,s7,800014aa <uvmunmap+0x76>
    if(do_free){
    800014f2:	fc0a8ae3          	beqz	s5,800014c6 <uvmunmap+0x92>
    800014f6:	b7d1                	j	800014ba <uvmunmap+0x86>

00000000800014f8 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800014f8:	1101                	addi	sp,sp,-32
    800014fa:	ec06                	sd	ra,24(sp)
    800014fc:	e822                	sd	s0,16(sp)
    800014fe:	e426                	sd	s1,8(sp)
    80001500:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	61e080e7          	jalr	1566(ra) # 80000b20 <kalloc>
    8000150a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000150c:	c519                	beqz	a0,8000151a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000150e:	6605                	lui	a2,0x1
    80001510:	4581                	li	a1,0
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	7fa080e7          	jalr	2042(ra) # 80000d0c <memset>
  return pagetable;
}
    8000151a:	8526                	mv	a0,s1
    8000151c:	60e2                	ld	ra,24(sp)
    8000151e:	6442                	ld	s0,16(sp)
    80001520:	64a2                	ld	s1,8(sp)
    80001522:	6105                	addi	sp,sp,32
    80001524:	8082                	ret

0000000080001526 <kvmcreate>:

pagetable_t
kvmcreate()
{
    80001526:	1141                	addi	sp,sp,-16
    80001528:	e406                	sd	ra,8(sp)
    8000152a:	e022                	sd	s0,0(sp)
    8000152c:	0800                	addi	s0,sp,16
  return uvmcreate();
    8000152e:	00000097          	auipc	ra,0x0
    80001532:	fca080e7          	jalr	-54(ra) # 800014f8 <uvmcreate>
}
    80001536:	60a2                	ld	ra,8(sp)
    80001538:	6402                	ld	s0,0(sp)
    8000153a:	0141                	addi	sp,sp,16
    8000153c:	8082                	ret

000000008000153e <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000153e:	7179                	addi	sp,sp,-48
    80001540:	f406                	sd	ra,40(sp)
    80001542:	f022                	sd	s0,32(sp)
    80001544:	ec26                	sd	s1,24(sp)
    80001546:	e84a                	sd	s2,16(sp)
    80001548:	e44e                	sd	s3,8(sp)
    8000154a:	e052                	sd	s4,0(sp)
    8000154c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000154e:	6785                	lui	a5,0x1
    80001550:	04f67863          	bgeu	a2,a5,800015a0 <uvminit+0x62>
    80001554:	8a2a                	mv	s4,a0
    80001556:	89ae                	mv	s3,a1
    80001558:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000155a:	fffff097          	auipc	ra,0xfffff
    8000155e:	5c6080e7          	jalr	1478(ra) # 80000b20 <kalloc>
    80001562:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001564:	6605                	lui	a2,0x1
    80001566:	4581                	li	a1,0
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	7a4080e7          	jalr	1956(ra) # 80000d0c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001570:	4779                	li	a4,30
    80001572:	86ca                	mv	a3,s2
    80001574:	6605                	lui	a2,0x1
    80001576:	4581                	li	a1,0
    80001578:	8552                	mv	a0,s4
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	c3e080e7          	jalr	-962(ra) # 800011b8 <mappages>
  memmove(mem, src, sz);
    80001582:	8626                	mv	a2,s1
    80001584:	85ce                	mv	a1,s3
    80001586:	854a                	mv	a0,s2
    80001588:	fffff097          	auipc	ra,0xfffff
    8000158c:	7e4080e7          	jalr	2020(ra) # 80000d6c <memmove>
}
    80001590:	70a2                	ld	ra,40(sp)
    80001592:	7402                	ld	s0,32(sp)
    80001594:	64e2                	ld	s1,24(sp)
    80001596:	6942                	ld	s2,16(sp)
    80001598:	69a2                	ld	s3,8(sp)
    8000159a:	6a02                	ld	s4,0(sp)
    8000159c:	6145                	addi	sp,sp,48
    8000159e:	8082                	ret
    panic("inituvm: more than a page");
    800015a0:	00007517          	auipc	a0,0x7
    800015a4:	ba850513          	addi	a0,a0,-1112 # 80008148 <digits+0x118>
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	fa0080e7          	jalr	-96(ra) # 80000548 <panic>

00000000800015b0 <vmdealloc>:
  return newsz;
}

uint64
vmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz, int do_free)
{
    800015b0:	1101                	addi	sp,sp,-32
    800015b2:	ec06                	sd	ra,24(sp)
    800015b4:	e822                	sd	s0,16(sp)
    800015b6:	e426                	sd	s1,8(sp)
    800015b8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800015ba:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015bc:	00b67d63          	bgeu	a2,a1,800015d6 <vmdealloc+0x26>
    800015c0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800015c2:	6785                	lui	a5,0x1
    800015c4:	17fd                	addi	a5,a5,-1
    800015c6:	00f60733          	add	a4,a2,a5
    800015ca:	767d                	lui	a2,0xfffff
    800015cc:	8f71                	and	a4,a4,a2
    800015ce:	97ae                	add	a5,a5,a1
    800015d0:	8ff1                	and	a5,a5,a2
    800015d2:	00f76863          	bltu	a4,a5,800015e2 <vmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, do_free);
  }

  return newsz;
}
    800015d6:	8526                	mv	a0,s1
    800015d8:	60e2                	ld	ra,24(sp)
    800015da:	6442                	ld	s0,16(sp)
    800015dc:	64a2                	ld	s1,8(sp)
    800015de:	6105                	addi	sp,sp,32
    800015e0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800015e2:	8f99                	sub	a5,a5,a4
    800015e4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, do_free);
    800015e6:	0007861b          	sext.w	a2,a5
    800015ea:	85ba                	mv	a1,a4
    800015ec:	00000097          	auipc	ra,0x0
    800015f0:	e48080e7          	jalr	-440(ra) # 80001434 <uvmunmap>
    800015f4:	b7cd                	j	800015d6 <vmdealloc+0x26>

00000000800015f6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800015f6:	1141                	addi	sp,sp,-16
    800015f8:	e406                	sd	ra,8(sp)
    800015fa:	e022                	sd	s0,0(sp)
    800015fc:	0800                	addi	s0,sp,16
  //   uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  // }

  // return newsz;

  return vmdealloc(pagetable, oldsz, newsz, 1);
    800015fe:	4685                	li	a3,1
    80001600:	00000097          	auipc	ra,0x0
    80001604:	fb0080e7          	jalr	-80(ra) # 800015b0 <vmdealloc>
}
    80001608:	60a2                	ld	ra,8(sp)
    8000160a:	6402                	ld	s0,0(sp)
    8000160c:	0141                	addi	sp,sp,16
    8000160e:	8082                	ret

0000000080001610 <uvmalloc>:
  if(newsz < oldsz)
    80001610:	0ab66163          	bltu	a2,a1,800016b2 <uvmalloc+0xa2>
{
    80001614:	7139                	addi	sp,sp,-64
    80001616:	fc06                	sd	ra,56(sp)
    80001618:	f822                	sd	s0,48(sp)
    8000161a:	f426                	sd	s1,40(sp)
    8000161c:	f04a                	sd	s2,32(sp)
    8000161e:	ec4e                	sd	s3,24(sp)
    80001620:	e852                	sd	s4,16(sp)
    80001622:	e456                	sd	s5,8(sp)
    80001624:	0080                	addi	s0,sp,64
    80001626:	8aaa                	mv	s5,a0
    80001628:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000162a:	6985                	lui	s3,0x1
    8000162c:	19fd                	addi	s3,s3,-1
    8000162e:	95ce                	add	a1,a1,s3
    80001630:	79fd                	lui	s3,0xfffff
    80001632:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001636:	08c9f063          	bgeu	s3,a2,800016b6 <uvmalloc+0xa6>
    8000163a:	894e                	mv	s2,s3
    mem = kalloc();
    8000163c:	fffff097          	auipc	ra,0xfffff
    80001640:	4e4080e7          	jalr	1252(ra) # 80000b20 <kalloc>
    80001644:	84aa                	mv	s1,a0
    if(mem == 0){
    80001646:	c51d                	beqz	a0,80001674 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001648:	6605                	lui	a2,0x1
    8000164a:	4581                	li	a1,0
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	6c0080e7          	jalr	1728(ra) # 80000d0c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001654:	4779                	li	a4,30
    80001656:	86a6                	mv	a3,s1
    80001658:	6605                	lui	a2,0x1
    8000165a:	85ca                	mv	a1,s2
    8000165c:	8556                	mv	a0,s5
    8000165e:	00000097          	auipc	ra,0x0
    80001662:	b5a080e7          	jalr	-1190(ra) # 800011b8 <mappages>
    80001666:	e905                	bnez	a0,80001696 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001668:	6785                	lui	a5,0x1
    8000166a:	993e                	add	s2,s2,a5
    8000166c:	fd4968e3          	bltu	s2,s4,8000163c <uvmalloc+0x2c>
  return newsz;
    80001670:	8552                	mv	a0,s4
    80001672:	a809                	j	80001684 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001674:	864e                	mv	a2,s3
    80001676:	85ca                	mv	a1,s2
    80001678:	8556                	mv	a0,s5
    8000167a:	00000097          	auipc	ra,0x0
    8000167e:	f7c080e7          	jalr	-132(ra) # 800015f6 <uvmdealloc>
      return 0;
    80001682:	4501                	li	a0,0
}
    80001684:	70e2                	ld	ra,56(sp)
    80001686:	7442                	ld	s0,48(sp)
    80001688:	74a2                	ld	s1,40(sp)
    8000168a:	7902                	ld	s2,32(sp)
    8000168c:	69e2                	ld	s3,24(sp)
    8000168e:	6a42                	ld	s4,16(sp)
    80001690:	6aa2                	ld	s5,8(sp)
    80001692:	6121                	addi	sp,sp,64
    80001694:	8082                	ret
      kfree(mem);
    80001696:	8526                	mv	a0,s1
    80001698:	fffff097          	auipc	ra,0xfffff
    8000169c:	38c080e7          	jalr	908(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016a0:	864e                	mv	a2,s3
    800016a2:	85ca                	mv	a1,s2
    800016a4:	8556                	mv	a0,s5
    800016a6:	00000097          	auipc	ra,0x0
    800016aa:	f50080e7          	jalr	-176(ra) # 800015f6 <uvmdealloc>
      return 0;
    800016ae:	4501                	li	a0,0
    800016b0:	bfd1                	j	80001684 <uvmalloc+0x74>
    return oldsz;
    800016b2:	852e                	mv	a0,a1
}
    800016b4:	8082                	ret
  return newsz;
    800016b6:	8532                	mv	a0,a2
    800016b8:	b7f1                	j	80001684 <uvmalloc+0x74>

00000000800016ba <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800016ba:	7179                	addi	sp,sp,-48
    800016bc:	f406                	sd	ra,40(sp)
    800016be:	f022                	sd	s0,32(sp)
    800016c0:	ec26                	sd	s1,24(sp)
    800016c2:	e84a                	sd	s2,16(sp)
    800016c4:	e44e                	sd	s3,8(sp)
    800016c6:	e052                	sd	s4,0(sp)
    800016c8:	1800                	addi	s0,sp,48
    800016ca:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016cc:	84aa                	mv	s1,a0
    800016ce:	6905                	lui	s2,0x1
    800016d0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016d2:	4985                	li	s3,1
    800016d4:	a821                	j	800016ec <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016d6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800016d8:	0532                	slli	a0,a0,0xc
    800016da:	00000097          	auipc	ra,0x0
    800016de:	fe0080e7          	jalr	-32(ra) # 800016ba <freewalk>
      pagetable[i] = 0;
    800016e2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800016e6:	04a1                	addi	s1,s1,8
    800016e8:	03248163          	beq	s1,s2,8000170a <freewalk+0x50>
    pte_t pte = pagetable[i];
    800016ec:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016ee:	00f57793          	andi	a5,a0,15
    800016f2:	ff3782e3          	beq	a5,s3,800016d6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800016f6:	8905                	andi	a0,a0,1
    800016f8:	d57d                	beqz	a0,800016e6 <freewalk+0x2c>
      panic("freewalk: leaf");
    800016fa:	00007517          	auipc	a0,0x7
    800016fe:	a6e50513          	addi	a0,a0,-1426 # 80008168 <digits+0x138>
    80001702:	fffff097          	auipc	ra,0xfffff
    80001706:	e46080e7          	jalr	-442(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    8000170a:	8552                	mv	a0,s4
    8000170c:	fffff097          	auipc	ra,0xfffff
    80001710:	318080e7          	jalr	792(ra) # 80000a24 <kfree>
}
    80001714:	70a2                	ld	ra,40(sp)
    80001716:	7402                	ld	s0,32(sp)
    80001718:	64e2                	ld	s1,24(sp)
    8000171a:	6942                	ld	s2,16(sp)
    8000171c:	69a2                	ld	s3,8(sp)
    8000171e:	6a02                	ld	s4,0(sp)
    80001720:	6145                	addi	sp,sp,48
    80001722:	8082                	ret

0000000080001724 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001724:	1101                	addi	sp,sp,-32
    80001726:	ec06                	sd	ra,24(sp)
    80001728:	e822                	sd	s0,16(sp)
    8000172a:	e426                	sd	s1,8(sp)
    8000172c:	1000                	addi	s0,sp,32
    8000172e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001730:	e999                	bnez	a1,80001746 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001732:	8526                	mv	a0,s1
    80001734:	00000097          	auipc	ra,0x0
    80001738:	f86080e7          	jalr	-122(ra) # 800016ba <freewalk>
}
    8000173c:	60e2                	ld	ra,24(sp)
    8000173e:	6442                	ld	s0,16(sp)
    80001740:	64a2                	ld	s1,8(sp)
    80001742:	6105                	addi	sp,sp,32
    80001744:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001746:	6605                	lui	a2,0x1
    80001748:	167d                	addi	a2,a2,-1
    8000174a:	962e                	add	a2,a2,a1
    8000174c:	4685                	li	a3,1
    8000174e:	8231                	srli	a2,a2,0xc
    80001750:	4581                	li	a1,0
    80001752:	00000097          	auipc	ra,0x0
    80001756:	ce2080e7          	jalr	-798(ra) # 80001434 <uvmunmap>
    8000175a:	bfe1                	j	80001732 <uvmfree+0xe>

000000008000175c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000175c:	c679                	beqz	a2,8000182a <uvmcopy+0xce>
{
    8000175e:	715d                	addi	sp,sp,-80
    80001760:	e486                	sd	ra,72(sp)
    80001762:	e0a2                	sd	s0,64(sp)
    80001764:	fc26                	sd	s1,56(sp)
    80001766:	f84a                	sd	s2,48(sp)
    80001768:	f44e                	sd	s3,40(sp)
    8000176a:	f052                	sd	s4,32(sp)
    8000176c:	ec56                	sd	s5,24(sp)
    8000176e:	e85a                	sd	s6,16(sp)
    80001770:	e45e                	sd	s7,8(sp)
    80001772:	0880                	addi	s0,sp,80
    80001774:	8b2a                	mv	s6,a0
    80001776:	8aae                	mv	s5,a1
    80001778:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000177a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000177c:	4601                	li	a2,0
    8000177e:	85ce                	mv	a1,s3
    80001780:	855a                	mv	a0,s6
    80001782:	00000097          	auipc	ra,0x0
    80001786:	89a080e7          	jalr	-1894(ra) # 8000101c <walk>
    8000178a:	c531                	beqz	a0,800017d6 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000178c:	6118                	ld	a4,0(a0)
    8000178e:	00177793          	andi	a5,a4,1
    80001792:	cbb1                	beqz	a5,800017e6 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001794:	00a75593          	srli	a1,a4,0xa
    80001798:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000179c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800017a0:	fffff097          	auipc	ra,0xfffff
    800017a4:	380080e7          	jalr	896(ra) # 80000b20 <kalloc>
    800017a8:	892a                	mv	s2,a0
    800017aa:	c939                	beqz	a0,80001800 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800017ac:	6605                	lui	a2,0x1
    800017ae:	85de                	mv	a1,s7
    800017b0:	fffff097          	auipc	ra,0xfffff
    800017b4:	5bc080e7          	jalr	1468(ra) # 80000d6c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800017b8:	8726                	mv	a4,s1
    800017ba:	86ca                	mv	a3,s2
    800017bc:	6605                	lui	a2,0x1
    800017be:	85ce                	mv	a1,s3
    800017c0:	8556                	mv	a0,s5
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	9f6080e7          	jalr	-1546(ra) # 800011b8 <mappages>
    800017ca:	e515                	bnez	a0,800017f6 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800017cc:	6785                	lui	a5,0x1
    800017ce:	99be                	add	s3,s3,a5
    800017d0:	fb49e6e3          	bltu	s3,s4,8000177c <uvmcopy+0x20>
    800017d4:	a081                	j	80001814 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800017d6:	00007517          	auipc	a0,0x7
    800017da:	9a250513          	addi	a0,a0,-1630 # 80008178 <digits+0x148>
    800017de:	fffff097          	auipc	ra,0xfffff
    800017e2:	d6a080e7          	jalr	-662(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800017e6:	00007517          	auipc	a0,0x7
    800017ea:	9b250513          	addi	a0,a0,-1614 # 80008198 <digits+0x168>
    800017ee:	fffff097          	auipc	ra,0xfffff
    800017f2:	d5a080e7          	jalr	-678(ra) # 80000548 <panic>
      kfree(mem);
    800017f6:	854a                	mv	a0,s2
    800017f8:	fffff097          	auipc	ra,0xfffff
    800017fc:	22c080e7          	jalr	556(ra) # 80000a24 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001800:	4685                	li	a3,1
    80001802:	00c9d613          	srli	a2,s3,0xc
    80001806:	4581                	li	a1,0
    80001808:	8556                	mv	a0,s5
    8000180a:	00000097          	auipc	ra,0x0
    8000180e:	c2a080e7          	jalr	-982(ra) # 80001434 <uvmunmap>
  return -1;
    80001812:	557d                	li	a0,-1
}
    80001814:	60a6                	ld	ra,72(sp)
    80001816:	6406                	ld	s0,64(sp)
    80001818:	74e2                	ld	s1,56(sp)
    8000181a:	7942                	ld	s2,48(sp)
    8000181c:	79a2                	ld	s3,40(sp)
    8000181e:	7a02                	ld	s4,32(sp)
    80001820:	6ae2                	ld	s5,24(sp)
    80001822:	6b42                	ld	s6,16(sp)
    80001824:	6ba2                	ld	s7,8(sp)
    80001826:	6161                	addi	sp,sp,80
    80001828:	8082                	ret
  return 0;
    8000182a:	4501                	li	a0,0
}
    8000182c:	8082                	ret

000000008000182e <u2kvmcopy>:

/** 将用户态页表塞到内核页表中 */
int
u2kvmcopy(pagetable_t old, pagetable_t new, uint64 start, uint64 end)
{
    8000182e:	7139                	addi	sp,sp,-64
    80001830:	fc06                	sd	ra,56(sp)
    80001832:	f822                	sd	s0,48(sp)
    80001834:	f426                	sd	s1,40(sp)
    80001836:	f04a                	sd	s2,32(sp)
    80001838:	ec4e                	sd	s3,24(sp)
    8000183a:	e852                	sd	s4,16(sp)
    8000183c:	e456                	sd	s5,8(sp)
    8000183e:	0080                	addi	s0,sp,64
    80001840:	8aaa                	mv	s5,a0
    80001842:	89ae                	mv	s3,a1
    80001844:	8a32                	mv	s4,a2
    80001846:	8936                	mv	s2,a3
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i=PGROUNDUP(start); i<end; i+=PGSIZE){
    80001848:	6485                	lui	s1,0x1
    8000184a:	14fd                	addi	s1,s1,-1
    8000184c:	94b2                	add	s1,s1,a2
    8000184e:	767d                	lui	a2,0xfffff
    80001850:	8cf1                	and	s1,s1,a2
    80001852:	08d4f563          	bgeu	s1,a3,800018dc <u2kvmcopy+0xae>
    if((pte = walk(old, i, 0)) == 0)
    80001856:	4601                	li	a2,0
    80001858:	85a6                	mv	a1,s1
    8000185a:	8556                	mv	a0,s5
    8000185c:	fffff097          	auipc	ra,0xfffff
    80001860:	7c0080e7          	jalr	1984(ra) # 8000101c <walk>
    80001864:	c51d                	beqz	a0,80001892 <u2kvmcopy+0x64>
      panic("u2kvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001866:	6118                	ld	a4,0(a0)
    80001868:	00177793          	andi	a5,a4,1
    8000186c:	cb9d                	beqz	a5,800018a2 <u2kvmcopy+0x74>
      panic("u2kvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000186e:	00a75693          	srli	a3,a4,0xa
    /** 需要将PTE_U标记位置0，内核才能访问用户态页表 */
    flags = PTE_FLAGS(*pte) & (~PTE_U);

    if(mappages(new, i, PGSIZE, pa, flags) != 0)
    80001872:	3ef77713          	andi	a4,a4,1007
    80001876:	06b2                	slli	a3,a3,0xc
    80001878:	6605                	lui	a2,0x1
    8000187a:	85a6                	mv	a1,s1
    8000187c:	854e                	mv	a0,s3
    8000187e:	00000097          	auipc	ra,0x0
    80001882:	93a080e7          	jalr	-1734(ra) # 800011b8 <mappages>
    80001886:	e515                	bnez	a0,800018b2 <u2kvmcopy+0x84>
  for(i=PGROUNDUP(start); i<end; i+=PGSIZE){
    80001888:	6785                	lui	a5,0x1
    8000188a:	94be                	add	s1,s1,a5
    8000188c:	fd24e5e3          	bltu	s1,s2,80001856 <u2kvmcopy+0x28>
    80001890:	a82d                	j	800018ca <u2kvmcopy+0x9c>
      panic("u2kvmcopy: pte should exist");
    80001892:	00007517          	auipc	a0,0x7
    80001896:	92650513          	addi	a0,a0,-1754 # 800081b8 <digits+0x188>
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	cae080e7          	jalr	-850(ra) # 80000548 <panic>
      panic("u2kvmcopy: page not present");
    800018a2:	00007517          	auipc	a0,0x7
    800018a6:	93650513          	addi	a0,a0,-1738 # 800081d8 <digits+0x1a8>
    800018aa:	fffff097          	auipc	ra,0xfffff
    800018ae:	c9e080e7          	jalr	-866(ra) # 80000548 <panic>
  }
  return 0;

 err:
  /** 注意不要释放用户态页表物理空间 */
  uvmunmap(new, start, (i-start)/PGSIZE, 0);
    800018b2:	414484b3          	sub	s1,s1,s4
    800018b6:	4681                	li	a3,0
    800018b8:	00c4d613          	srli	a2,s1,0xc
    800018bc:	85d2                	mv	a1,s4
    800018be:	854e                	mv	a0,s3
    800018c0:	00000097          	auipc	ra,0x0
    800018c4:	b74080e7          	jalr	-1164(ra) # 80001434 <uvmunmap>
  return -1;
    800018c8:	557d                	li	a0,-1
}
    800018ca:	70e2                	ld	ra,56(sp)
    800018cc:	7442                	ld	s0,48(sp)
    800018ce:	74a2                	ld	s1,40(sp)
    800018d0:	7902                	ld	s2,32(sp)
    800018d2:	69e2                	ld	s3,24(sp)
    800018d4:	6a42                	ld	s4,16(sp)
    800018d6:	6aa2                	ld	s5,8(sp)
    800018d8:	6121                	addi	sp,sp,64
    800018da:	8082                	ret
  return 0;
    800018dc:	4501                	li	a0,0
    800018de:	b7f5                	j	800018ca <u2kvmcopy+0x9c>

00000000800018e0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800018e0:	1141                	addi	sp,sp,-16
    800018e2:	e406                	sd	ra,8(sp)
    800018e4:	e022                	sd	s0,0(sp)
    800018e6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800018e8:	4601                	li	a2,0
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	732080e7          	jalr	1842(ra) # 8000101c <walk>
  if(pte == 0)
    800018f2:	c901                	beqz	a0,80001902 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800018f4:	611c                	ld	a5,0(a0)
    800018f6:	9bbd                	andi	a5,a5,-17
    800018f8:	e11c                	sd	a5,0(a0)
}
    800018fa:	60a2                	ld	ra,8(sp)
    800018fc:	6402                	ld	s0,0(sp)
    800018fe:	0141                	addi	sp,sp,16
    80001900:	8082                	ret
    panic("uvmclear");
    80001902:	00007517          	auipc	a0,0x7
    80001906:	8f650513          	addi	a0,a0,-1802 # 800081f8 <digits+0x1c8>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	c3e080e7          	jalr	-962(ra) # 80000548 <panic>

0000000080001912 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001912:	c6bd                	beqz	a3,80001980 <copyout+0x6e>
{
    80001914:	715d                	addi	sp,sp,-80
    80001916:	e486                	sd	ra,72(sp)
    80001918:	e0a2                	sd	s0,64(sp)
    8000191a:	fc26                	sd	s1,56(sp)
    8000191c:	f84a                	sd	s2,48(sp)
    8000191e:	f44e                	sd	s3,40(sp)
    80001920:	f052                	sd	s4,32(sp)
    80001922:	ec56                	sd	s5,24(sp)
    80001924:	e85a                	sd	s6,16(sp)
    80001926:	e45e                	sd	s7,8(sp)
    80001928:	e062                	sd	s8,0(sp)
    8000192a:	0880                	addi	s0,sp,80
    8000192c:	8b2a                	mv	s6,a0
    8000192e:	8c2e                	mv	s8,a1
    80001930:	8a32                	mv	s4,a2
    80001932:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001934:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001936:	6a85                	lui	s5,0x1
    80001938:	a015                	j	8000195c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000193a:	9562                	add	a0,a0,s8
    8000193c:	0004861b          	sext.w	a2,s1
    80001940:	85d2                	mv	a1,s4
    80001942:	41250533          	sub	a0,a0,s2
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	426080e7          	jalr	1062(ra) # 80000d6c <memmove>

    len -= n;
    8000194e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001952:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001954:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001958:	02098263          	beqz	s3,8000197c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000195c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001960:	85ca                	mv	a1,s2
    80001962:	855a                	mv	a0,s6
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	75e080e7          	jalr	1886(ra) # 800010c2 <walkaddr>
    if(pa0 == 0)
    8000196c:	cd01                	beqz	a0,80001984 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000196e:	418904b3          	sub	s1,s2,s8
    80001972:	94d6                	add	s1,s1,s5
    if(n > len)
    80001974:	fc99f3e3          	bgeu	s3,s1,8000193a <copyout+0x28>
    80001978:	84ce                	mv	s1,s3
    8000197a:	b7c1                	j	8000193a <copyout+0x28>
  }
  return 0;
    8000197c:	4501                	li	a0,0
    8000197e:	a021                	j	80001986 <copyout+0x74>
    80001980:	4501                	li	a0,0
}
    80001982:	8082                	ret
      return -1;
    80001984:	557d                	li	a0,-1
}
    80001986:	60a6                	ld	ra,72(sp)
    80001988:	6406                	ld	s0,64(sp)
    8000198a:	74e2                	ld	s1,56(sp)
    8000198c:	7942                	ld	s2,48(sp)
    8000198e:	79a2                	ld	s3,40(sp)
    80001990:	7a02                	ld	s4,32(sp)
    80001992:	6ae2                	ld	s5,24(sp)
    80001994:	6b42                	ld	s6,16(sp)
    80001996:	6ba2                	ld	s7,8(sp)
    80001998:	6c02                	ld	s8,0(sp)
    8000199a:	6161                	addi	sp,sp,80
    8000199c:	8082                	ret

000000008000199e <copyin>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    8000199e:	1141                	addi	sp,sp,-16
    800019a0:	e406                	sd	ra,8(sp)
    800019a2:	e022                	sd	s0,0(sp)
    800019a4:	0800                	addi	s0,sp,16
  //   srcva = va0 + PGSIZE;
  // }
  // return 0;

  /*************************新修订的copyin***************************/
  return copyin_new(pagetable, dst, srcva, len);
    800019a6:	00005097          	auipc	ra,0x5
    800019aa:	c66080e7          	jalr	-922(ra) # 8000660c <copyin_new>
}
    800019ae:	60a2                	ld	ra,8(sp)
    800019b0:	6402                	ld	s0,0(sp)
    800019b2:	0141                	addi	sp,sp,16
    800019b4:	8082                	ret

00000000800019b6 <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800019b6:	1141                	addi	sp,sp,-16
    800019b8:	e406                	sd	ra,8(sp)
    800019ba:	e022                	sd	s0,0(sp)
    800019bc:	0800                	addi	s0,sp,16
  // } else {
  //   return -1;
  // }

  /*************************新修订的copyinstr***************************/
  return copyinstr_new(pagetable, dst, srcva, max);
    800019be:	00005097          	auipc	ra,0x5
    800019c2:	cb6080e7          	jalr	-842(ra) # 80006674 <copyinstr_new>
}
    800019c6:	60a2                	ld	ra,8(sp)
    800019c8:	6402                	ld	s0,0(sp)
    800019ca:	0141                	addi	sp,sp,16
    800019cc:	8082                	ret

00000000800019ce <_vmprint>:

void 
_vmprint(pagetable_t pagetable, int level)
{
    800019ce:	7175                	addi	sp,sp,-144
    800019d0:	e506                	sd	ra,136(sp)
    800019d2:	e122                	sd	s0,128(sp)
    800019d4:	fca6                	sd	s1,120(sp)
    800019d6:	f8ca                	sd	s2,112(sp)
    800019d8:	f4ce                	sd	s3,104(sp)
    800019da:	f0d2                	sd	s4,96(sp)
    800019dc:	ecd6                	sd	s5,88(sp)
    800019de:	e8da                	sd	s6,80(sp)
    800019e0:	e4de                	sd	s7,72(sp)
    800019e2:	e0e2                	sd	s8,64(sp)
    800019e4:	fc66                	sd	s9,56(sp)
    800019e6:	f86a                	sd	s10,48(sp)
    800019e8:	f46e                	sd	s11,40(sp)
    800019ea:	0900                	addi	s0,sp,144
    800019ec:	8aae                	mv	s5,a1
  // there are 2^9 = 512 PTEs in a page table.
  for(int i=0; i<512; i++) {
    800019ee:	89aa                	mv	s3,a0
    800019f0:	4901                	li	s2,0
    }
    if(level == 2) {
      snprintf(prefix, 32, ".. .. ..%d:", i);
    }

    printf("%s pte %p pa %p\n", prefix, pte, PTE2PA(pte));
    800019f2:	00007b17          	auipc	s6,0x7
    800019f6:	83eb0b13          	addi	s6,s6,-1986 # 80008230 <digits+0x200>
    if((pte & (PTE_R|PTE_W|PTE_X)) == 0) {
      uint64 child = PTE2PA(pte);
      _vmprint((pagetable_t)child, level+1);
    800019fa:	00158c9b          	addiw	s9,a1,1
    if(level == 1) {
    800019fe:	4b85                	li	s7,1
    if(level == 2) {
    80001a00:	4c09                	li	s8,2
      snprintf(prefix, 32, ".. .. ..%d:", i);
    80001a02:	00007d97          	auipc	s11,0x7
    80001a06:	81ed8d93          	addi	s11,s11,-2018 # 80008220 <digits+0x1f0>
      snprintf(prefix, 32, ".. ..%d:", i);
    80001a0a:	00007d17          	auipc	s10,0x7
    80001a0e:	806d0d13          	addi	s10,s10,-2042 # 80008210 <digits+0x1e0>
    80001a12:	a091                	j	80001a56 <_vmprint+0x88>
      snprintf(prefix, 32, "..%d:", i);
    80001a14:	86ca                	mv	a3,s2
    80001a16:	00006617          	auipc	a2,0x6
    80001a1a:	7f260613          	addi	a2,a2,2034 # 80008208 <digits+0x1d8>
    80001a1e:	02000593          	li	a1,32
    80001a22:	f7040513          	addi	a0,s0,-144
    80001a26:	00005097          	auipc	ra,0x5
    80001a2a:	e74080e7          	jalr	-396(ra) # 8000689a <snprintf>
    printf("%s pte %p pa %p\n", prefix, pte, PTE2PA(pte));
    80001a2e:	00a4da13          	srli	s4,s1,0xa
    80001a32:	0a32                	slli	s4,s4,0xc
    80001a34:	86d2                	mv	a3,s4
    80001a36:	8626                	mv	a2,s1
    80001a38:	f7040593          	addi	a1,s0,-144
    80001a3c:	855a                	mv	a0,s6
    80001a3e:	fffff097          	auipc	ra,0xfffff
    80001a42:	b54080e7          	jalr	-1196(ra) # 80000592 <printf>
    if((pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    80001a46:	88b9                	andi	s1,s1,14
    80001a48:	c8a1                	beqz	s1,80001a98 <_vmprint+0xca>
  for(int i=0; i<512; i++) {
    80001a4a:	2905                	addiw	s2,s2,1
    80001a4c:	09a1                	addi	s3,s3,8
    80001a4e:	20000793          	li	a5,512
    80001a52:	04f90a63          	beq	s2,a5,80001aa6 <_vmprint+0xd8>
    pte_t pte = pagetable[i];
    80001a56:	0009b483          	ld	s1,0(s3) # fffffffffffff000 <end+0xffffffff7ffd7fe0>
    if((pte & PTE_V) == 0) 
    80001a5a:	0014f793          	andi	a5,s1,1
    80001a5e:	d7f5                	beqz	a5,80001a4a <_vmprint+0x7c>
    if(level == 0) {
    80001a60:	fa0a8ae3          	beqz	s5,80001a14 <_vmprint+0x46>
    if(level == 1) {
    80001a64:	017a8f63          	beq	s5,s7,80001a82 <_vmprint+0xb4>
    if(level == 2) {
    80001a68:	fd8a93e3          	bne	s5,s8,80001a2e <_vmprint+0x60>
      snprintf(prefix, 32, ".. .. ..%d:", i);
    80001a6c:	86ca                	mv	a3,s2
    80001a6e:	866e                	mv	a2,s11
    80001a70:	02000593          	li	a1,32
    80001a74:	f7040513          	addi	a0,s0,-144
    80001a78:	00005097          	auipc	ra,0x5
    80001a7c:	e22080e7          	jalr	-478(ra) # 8000689a <snprintf>
    80001a80:	b77d                	j	80001a2e <_vmprint+0x60>
      snprintf(prefix, 32, ".. ..%d:", i);
    80001a82:	86ca                	mv	a3,s2
    80001a84:	866a                	mv	a2,s10
    80001a86:	02000593          	li	a1,32
    80001a8a:	f7040513          	addi	a0,s0,-144
    80001a8e:	00005097          	auipc	ra,0x5
    80001a92:	e0c080e7          	jalr	-500(ra) # 8000689a <snprintf>
    if(level == 2) {
    80001a96:	bf61                	j	80001a2e <_vmprint+0x60>
      _vmprint((pagetable_t)child, level+1);
    80001a98:	85e6                	mv	a1,s9
    80001a9a:	8552                	mv	a0,s4
    80001a9c:	00000097          	auipc	ra,0x0
    80001aa0:	f32080e7          	jalr	-206(ra) # 800019ce <_vmprint>
    80001aa4:	b75d                	j	80001a4a <_vmprint+0x7c>
    } 
  }
}
    80001aa6:	60aa                	ld	ra,136(sp)
    80001aa8:	640a                	ld	s0,128(sp)
    80001aaa:	74e6                	ld	s1,120(sp)
    80001aac:	7946                	ld	s2,112(sp)
    80001aae:	79a6                	ld	s3,104(sp)
    80001ab0:	7a06                	ld	s4,96(sp)
    80001ab2:	6ae6                	ld	s5,88(sp)
    80001ab4:	6b46                	ld	s6,80(sp)
    80001ab6:	6ba6                	ld	s7,72(sp)
    80001ab8:	6c06                	ld	s8,64(sp)
    80001aba:	7ce2                	ld	s9,56(sp)
    80001abc:	7d42                	ld	s10,48(sp)
    80001abe:	7da2                	ld	s11,40(sp)
    80001ac0:	6149                	addi	sp,sp,144
    80001ac2:	8082                	ret

0000000080001ac4 <vmprint>:

void 
vmprint(pagetable_t pagetable)
{
    80001ac4:	1101                	addi	sp,sp,-32
    80001ac6:	ec06                	sd	ra,24(sp)
    80001ac8:	e822                	sd	s0,16(sp)
    80001aca:	e426                	sd	s1,8(sp)
    80001acc:	1000                	addi	s0,sp,32
    80001ace:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80001ad0:	85aa                	mv	a1,a0
    80001ad2:	00006517          	auipc	a0,0x6
    80001ad6:	77650513          	addi	a0,a0,1910 # 80008248 <digits+0x218>
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	ab8080e7          	jalr	-1352(ra) # 80000592 <printf>
  _vmprint(pagetable, 0);
    80001ae2:	4581                	li	a1,0
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	00000097          	auipc	ra,0x0
    80001aea:	ee8080e7          	jalr	-280(ra) # 800019ce <_vmprint>
    80001aee:	60e2                	ld	ra,24(sp)
    80001af0:	6442                	ld	s0,16(sp)
    80001af2:	64a2                	ld	s1,8(sp)
    80001af4:	6105                	addi	sp,sp,32
    80001af6:	8082                	ret

0000000080001af8 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001af8:	1101                	addi	sp,sp,-32
    80001afa:	ec06                	sd	ra,24(sp)
    80001afc:	e822                	sd	s0,16(sp)
    80001afe:	e426                	sd	s1,8(sp)
    80001b00:	1000                	addi	s0,sp,32
    80001b02:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	092080e7          	jalr	146(ra) # 80000b96 <holding>
    80001b0c:	c909                	beqz	a0,80001b1e <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001b0e:	749c                	ld	a5,40(s1)
    80001b10:	00978f63          	beq	a5,s1,80001b2e <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001b14:	60e2                	ld	ra,24(sp)
    80001b16:	6442                	ld	s0,16(sp)
    80001b18:	64a2                	ld	s1,8(sp)
    80001b1a:	6105                	addi	sp,sp,32
    80001b1c:	8082                	ret
    panic("wakeup1");
    80001b1e:	00006517          	auipc	a0,0x6
    80001b22:	73a50513          	addi	a0,a0,1850 # 80008258 <digits+0x228>
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	a22080e7          	jalr	-1502(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001b2e:	4c98                	lw	a4,24(s1)
    80001b30:	4785                	li	a5,1
    80001b32:	fef711e3          	bne	a4,a5,80001b14 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001b36:	4789                	li	a5,2
    80001b38:	cc9c                	sw	a5,24(s1)
}
    80001b3a:	bfe9                	j	80001b14 <wakeup1+0x1c>

0000000080001b3c <procinit>:
{
    80001b3c:	7179                	addi	sp,sp,-48
    80001b3e:	f406                	sd	ra,40(sp)
    80001b40:	f022                	sd	s0,32(sp)
    80001b42:	ec26                	sd	s1,24(sp)
    80001b44:	e84a                	sd	s2,16(sp)
    80001b46:	e44e                	sd	s3,8(sp)
    80001b48:	1800                	addi	s0,sp,48
  initlock(&pid_lock, "nextpid");
    80001b4a:	00006597          	auipc	a1,0x6
    80001b4e:	71658593          	addi	a1,a1,1814 # 80008260 <digits+0x230>
    80001b52:	00010517          	auipc	a0,0x10
    80001b56:	dfe50513          	addi	a0,a0,-514 # 80011950 <pid_lock>
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	026080e7          	jalr	38(ra) # 80000b80 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b62:	00010497          	auipc	s1,0x10
    80001b66:	20648493          	addi	s1,s1,518 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001b6a:	00006997          	auipc	s3,0x6
    80001b6e:	6fe98993          	addi	s3,s3,1790 # 80008268 <digits+0x238>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b72:	00016917          	auipc	s2,0x16
    80001b76:	df690913          	addi	s2,s2,-522 # 80017968 <tickslock>
      initlock(&p->lock, "proc");
    80001b7a:	85ce                	mv	a1,s3
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	fffff097          	auipc	ra,0xfffff
    80001b82:	002080e7          	jalr	2(ra) # 80000b80 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b86:	17048493          	addi	s1,s1,368
    80001b8a:	ff2498e3          	bne	s1,s2,80001b7a <procinit+0x3e>
  kvminithart();
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	44e080e7          	jalr	1102(ra) # 80000fdc <kvminithart>
}
    80001b96:	70a2                	ld	ra,40(sp)
    80001b98:	7402                	ld	s0,32(sp)
    80001b9a:	64e2                	ld	s1,24(sp)
    80001b9c:	6942                	ld	s2,16(sp)
    80001b9e:	69a2                	ld	s3,8(sp)
    80001ba0:	6145                	addi	sp,sp,48
    80001ba2:	8082                	ret

0000000080001ba4 <cpuid>:
{
    80001ba4:	1141                	addi	sp,sp,-16
    80001ba6:	e422                	sd	s0,8(sp)
    80001ba8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001baa:	8512                	mv	a0,tp
}
    80001bac:	2501                	sext.w	a0,a0
    80001bae:	6422                	ld	s0,8(sp)
    80001bb0:	0141                	addi	sp,sp,16
    80001bb2:	8082                	ret

0000000080001bb4 <mycpu>:
mycpu(void) {
    80001bb4:	1141                	addi	sp,sp,-16
    80001bb6:	e422                	sd	s0,8(sp)
    80001bb8:	0800                	addi	s0,sp,16
    80001bba:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001bbc:	2781                	sext.w	a5,a5
    80001bbe:	079e                	slli	a5,a5,0x7
}
    80001bc0:	00010517          	auipc	a0,0x10
    80001bc4:	da850513          	addi	a0,a0,-600 # 80011968 <cpus>
    80001bc8:	953e                	add	a0,a0,a5
    80001bca:	6422                	ld	s0,8(sp)
    80001bcc:	0141                	addi	sp,sp,16
    80001bce:	8082                	ret

0000000080001bd0 <myproc>:
myproc(void) {
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	1000                	addi	s0,sp,32
  push_off();
    80001bda:	fffff097          	auipc	ra,0xfffff
    80001bde:	fea080e7          	jalr	-22(ra) # 80000bc4 <push_off>
    80001be2:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001be4:	2781                	sext.w	a5,a5
    80001be6:	079e                	slli	a5,a5,0x7
    80001be8:	00010717          	auipc	a4,0x10
    80001bec:	d6870713          	addi	a4,a4,-664 # 80011950 <pid_lock>
    80001bf0:	97ba                	add	a5,a5,a4
    80001bf2:	6f84                	ld	s1,24(a5)
  pop_off();
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	070080e7          	jalr	112(ra) # 80000c64 <pop_off>
}
    80001bfc:	8526                	mv	a0,s1
    80001bfe:	60e2                	ld	ra,24(sp)
    80001c00:	6442                	ld	s0,16(sp)
    80001c02:	64a2                	ld	s1,8(sp)
    80001c04:	6105                	addi	sp,sp,32
    80001c06:	8082                	ret

0000000080001c08 <forkret>:
{
    80001c08:	1141                	addi	sp,sp,-16
    80001c0a:	e406                	sd	ra,8(sp)
    80001c0c:	e022                	sd	s0,0(sp)
    80001c0e:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	fc0080e7          	jalr	-64(ra) # 80001bd0 <myproc>
    80001c18:	fffff097          	auipc	ra,0xfffff
    80001c1c:	0ac080e7          	jalr	172(ra) # 80000cc4 <release>
  if (first) {
    80001c20:	00007797          	auipc	a5,0x7
    80001c24:	cc07a783          	lw	a5,-832(a5) # 800088e0 <first.1732>
    80001c28:	eb89                	bnez	a5,80001c3a <forkret+0x32>
  usertrapret();
    80001c2a:	00001097          	auipc	ra,0x1
    80001c2e:	dec080e7          	jalr	-532(ra) # 80002a16 <usertrapret>
}
    80001c32:	60a2                	ld	ra,8(sp)
    80001c34:	6402                	ld	s0,0(sp)
    80001c36:	0141                	addi	sp,sp,16
    80001c38:	8082                	ret
    first = 0;
    80001c3a:	00007797          	auipc	a5,0x7
    80001c3e:	ca07a323          	sw	zero,-858(a5) # 800088e0 <first.1732>
    fsinit(ROOTDEV);
    80001c42:	4505                	li	a0,1
    80001c44:	00002097          	auipc	ra,0x2
    80001c48:	b14080e7          	jalr	-1260(ra) # 80003758 <fsinit>
    80001c4c:	bff9                	j	80001c2a <forkret+0x22>

0000000080001c4e <allocpid>:
allocpid() {
    80001c4e:	1101                	addi	sp,sp,-32
    80001c50:	ec06                	sd	ra,24(sp)
    80001c52:	e822                	sd	s0,16(sp)
    80001c54:	e426                	sd	s1,8(sp)
    80001c56:	e04a                	sd	s2,0(sp)
    80001c58:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c5a:	00010917          	auipc	s2,0x10
    80001c5e:	cf690913          	addi	s2,s2,-778 # 80011950 <pid_lock>
    80001c62:	854a                	mv	a0,s2
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	fac080e7          	jalr	-84(ra) # 80000c10 <acquire>
  pid = nextpid;
    80001c6c:	00007797          	auipc	a5,0x7
    80001c70:	c7878793          	addi	a5,a5,-904 # 800088e4 <nextpid>
    80001c74:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c76:	0014871b          	addiw	a4,s1,1
    80001c7a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c7c:	854a                	mv	a0,s2
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	046080e7          	jalr	70(ra) # 80000cc4 <release>
}
    80001c86:	8526                	mv	a0,s1
    80001c88:	60e2                	ld	ra,24(sp)
    80001c8a:	6442                	ld	s0,16(sp)
    80001c8c:	64a2                	ld	s1,8(sp)
    80001c8e:	6902                	ld	s2,0(sp)
    80001c90:	6105                	addi	sp,sp,32
    80001c92:	8082                	ret

0000000080001c94 <proc_pagetable>:
{
    80001c94:	1101                	addi	sp,sp,-32
    80001c96:	ec06                	sd	ra,24(sp)
    80001c98:	e822                	sd	s0,16(sp)
    80001c9a:	e426                	sd	s1,8(sp)
    80001c9c:	e04a                	sd	s2,0(sp)
    80001c9e:	1000                	addi	s0,sp,32
    80001ca0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ca2:	00000097          	auipc	ra,0x0
    80001ca6:	856080e7          	jalr	-1962(ra) # 800014f8 <uvmcreate>
    80001caa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001cac:	c121                	beqz	a0,80001cec <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cae:	4729                	li	a4,10
    80001cb0:	00005697          	auipc	a3,0x5
    80001cb4:	35068693          	addi	a3,a3,848 # 80007000 <_trampoline>
    80001cb8:	6605                	lui	a2,0x1
    80001cba:	040005b7          	lui	a1,0x4000
    80001cbe:	15fd                	addi	a1,a1,-1
    80001cc0:	05b2                	slli	a1,a1,0xc
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	4f6080e7          	jalr	1270(ra) # 800011b8 <mappages>
    80001cca:	02054863          	bltz	a0,80001cfa <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cce:	4719                	li	a4,6
    80001cd0:	05893683          	ld	a3,88(s2)
    80001cd4:	6605                	lui	a2,0x1
    80001cd6:	020005b7          	lui	a1,0x2000
    80001cda:	15fd                	addi	a1,a1,-1
    80001cdc:	05b6                	slli	a1,a1,0xd
    80001cde:	8526                	mv	a0,s1
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	4d8080e7          	jalr	1240(ra) # 800011b8 <mappages>
    80001ce8:	02054163          	bltz	a0,80001d0a <proc_pagetable+0x76>
}
    80001cec:	8526                	mv	a0,s1
    80001cee:	60e2                	ld	ra,24(sp)
    80001cf0:	6442                	ld	s0,16(sp)
    80001cf2:	64a2                	ld	s1,8(sp)
    80001cf4:	6902                	ld	s2,0(sp)
    80001cf6:	6105                	addi	sp,sp,32
    80001cf8:	8082                	ret
    uvmfree(pagetable, 0);
    80001cfa:	4581                	li	a1,0
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	a26080e7          	jalr	-1498(ra) # 80001724 <uvmfree>
    return 0;
    80001d06:	4481                	li	s1,0
    80001d08:	b7d5                	j	80001cec <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d0a:	4681                	li	a3,0
    80001d0c:	4605                	li	a2,1
    80001d0e:	040005b7          	lui	a1,0x4000
    80001d12:	15fd                	addi	a1,a1,-1
    80001d14:	05b2                	slli	a1,a1,0xc
    80001d16:	8526                	mv	a0,s1
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	71c080e7          	jalr	1820(ra) # 80001434 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d20:	4581                	li	a1,0
    80001d22:	8526                	mv	a0,s1
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	a00080e7          	jalr	-1536(ra) # 80001724 <uvmfree>
    return 0;
    80001d2c:	4481                	li	s1,0
    80001d2e:	bf7d                	j	80001cec <proc_pagetable+0x58>

0000000080001d30 <proc_kpagetable>:
{
    80001d30:	1101                	addi	sp,sp,-32
    80001d32:	ec06                	sd	ra,24(sp)
    80001d34:	e822                	sd	s0,16(sp)
    80001d36:	e426                	sd	s1,8(sp)
    80001d38:	1000                	addi	s0,sp,32
  kpagetable = kvmcreate();
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	7ec080e7          	jalr	2028(ra) # 80001526 <kvmcreate>
    80001d42:	84aa                	mv	s1,a0
  if(kpagetable == 0)
    80001d44:	c509                	beqz	a0,80001d4e <proc_kpagetable+0x1e>
  vminit(kpagetable);
    80001d46:	fffff097          	auipc	ra,0xfffff
    80001d4a:	63a080e7          	jalr	1594(ra) # 80001380 <vminit>
}
    80001d4e:	8526                	mv	a0,s1
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6105                	addi	sp,sp,32
    80001d58:	8082                	ret

0000000080001d5a <proc_freepagetable>:
{
    80001d5a:	1101                	addi	sp,sp,-32
    80001d5c:	ec06                	sd	ra,24(sp)
    80001d5e:	e822                	sd	s0,16(sp)
    80001d60:	e426                	sd	s1,8(sp)
    80001d62:	e04a                	sd	s2,0(sp)
    80001d64:	1000                	addi	s0,sp,32
    80001d66:	84aa                	mv	s1,a0
    80001d68:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d6a:	4681                	li	a3,0
    80001d6c:	4605                	li	a2,1
    80001d6e:	040005b7          	lui	a1,0x4000
    80001d72:	15fd                	addi	a1,a1,-1
    80001d74:	05b2                	slli	a1,a1,0xc
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	6be080e7          	jalr	1726(ra) # 80001434 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d7e:	4681                	li	a3,0
    80001d80:	4605                	li	a2,1
    80001d82:	020005b7          	lui	a1,0x2000
    80001d86:	15fd                	addi	a1,a1,-1
    80001d88:	05b6                	slli	a1,a1,0xd
    80001d8a:	8526                	mv	a0,s1
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	6a8080e7          	jalr	1704(ra) # 80001434 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d94:	85ca                	mv	a1,s2
    80001d96:	8526                	mv	a0,s1
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	98c080e7          	jalr	-1652(ra) # 80001724 <uvmfree>
}
    80001da0:	60e2                	ld	ra,24(sp)
    80001da2:	6442                	ld	s0,16(sp)
    80001da4:	64a2                	ld	s1,8(sp)
    80001da6:	6902                	ld	s2,0(sp)
    80001da8:	6105                	addi	sp,sp,32
    80001daa:	8082                	ret

0000000080001dac <proc_freekpagetable>:
{
    80001dac:	7139                	addi	sp,sp,-64
    80001dae:	fc06                	sd	ra,56(sp)
    80001db0:	f822                	sd	s0,48(sp)
    80001db2:	f426                	sd	s1,40(sp)
    80001db4:	f04a                	sd	s2,32(sp)
    80001db6:	ec4e                	sd	s3,24(sp)
    80001db8:	e852                	sd	s4,16(sp)
    80001dba:	e456                	sd	s5,8(sp)
    80001dbc:	0080                	addi	s0,sp,64
    80001dbe:	8aaa                	mv	s5,a0
    80001dc0:	8a2e                	mv	s4,a1
  for(int i=0; i<512; i++) {
    80001dc2:	84aa                	mv	s1,a0
    80001dc4:	6985                	lui	s3,0x1
    80001dc6:	99aa                	add	s3,s3,a0
    80001dc8:	a829                	j	80001de2 <proc_freekpagetable+0x36>
      uint64 child = PTE2PA(pte);
    80001dca:	8129                	srli	a0,a0,0xa
      proc_freekpagetable((pagetable_t)child, sz);
    80001dcc:	85d2                	mv	a1,s4
    80001dce:	0532                	slli	a0,a0,0xc
    80001dd0:	00000097          	auipc	ra,0x0
    80001dd4:	fdc080e7          	jalr	-36(ra) # 80001dac <proc_freekpagetable>
      kpagetable[i] = 0;
    80001dd8:	0004b023          	sd	zero,0(s1)
  for(int i=0; i<512; i++) {
    80001ddc:	04a1                	addi	s1,s1,8
    80001dde:	01348a63          	beq	s1,s3,80001df2 <proc_freekpagetable+0x46>
    pte_t pte = kpagetable[i];
    80001de2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) == 0) 
    80001de4:	00157793          	andi	a5,a0,1
    80001de8:	dbf5                	beqz	a5,80001ddc <proc_freekpagetable+0x30>
    if((pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    80001dea:	00e57793          	andi	a5,a0,14
    80001dee:	f7fd                	bnez	a5,80001ddc <proc_freekpagetable+0x30>
    80001df0:	bfe9                	j	80001dca <proc_freekpagetable+0x1e>
  kfree((void*)kpagetable);
    80001df2:	8556                	mv	a0,s5
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	c30080e7          	jalr	-976(ra) # 80000a24 <kfree>
}
    80001dfc:	70e2                	ld	ra,56(sp)
    80001dfe:	7442                	ld	s0,48(sp)
    80001e00:	74a2                	ld	s1,40(sp)
    80001e02:	7902                	ld	s2,32(sp)
    80001e04:	69e2                	ld	s3,24(sp)
    80001e06:	6a42                	ld	s4,16(sp)
    80001e08:	6aa2                	ld	s5,8(sp)
    80001e0a:	6121                	addi	sp,sp,64
    80001e0c:	8082                	ret

0000000080001e0e <freeproc>:
{
    80001e0e:	1101                	addi	sp,sp,-32
    80001e10:	ec06                	sd	ra,24(sp)
    80001e12:	e822                	sd	s0,16(sp)
    80001e14:	e426                	sd	s1,8(sp)
    80001e16:	1000                	addi	s0,sp,32
    80001e18:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e1a:	6d28                	ld	a0,88(a0)
    80001e1c:	c509                	beqz	a0,80001e26 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	c06080e7          	jalr	-1018(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001e26:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001e2a:	68a8                	ld	a0,80(s1)
    80001e2c:	c511                	beqz	a0,80001e38 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e2e:	64ac                	ld	a1,72(s1)
    80001e30:	00000097          	auipc	ra,0x0
    80001e34:	f2a080e7          	jalr	-214(ra) # 80001d5a <proc_freepagetable>
  p->pagetable = 0;
    80001e38:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e3c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e40:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001e44:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001e48:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e4c:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001e50:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001e54:	0204aa23          	sw	zero,52(s1)
  if(p->kstack)
    80001e58:	60ac                	ld	a1,64(s1)
    80001e5a:	e585                	bnez	a1,80001e82 <freeproc+0x74>
  p->kstack = 0;
    80001e5c:	0404b023          	sd	zero,64(s1)
  if(p->kpagetable)
    80001e60:	1684b503          	ld	a0,360(s1)
    80001e64:	c511                	beqz	a0,80001e70 <freeproc+0x62>
    proc_freekpagetable(p->kpagetable, p->sz);
    80001e66:	64ac                	ld	a1,72(s1)
    80001e68:	00000097          	auipc	ra,0x0
    80001e6c:	f44080e7          	jalr	-188(ra) # 80001dac <proc_freekpagetable>
  p->kpagetable = 0;
    80001e70:	1604b423          	sd	zero,360(s1)
  p->state = UNUSED;
    80001e74:	0004ac23          	sw	zero,24(s1)
}
    80001e78:	60e2                	ld	ra,24(sp)
    80001e7a:	6442                	ld	s0,16(sp)
    80001e7c:	64a2                	ld	s1,8(sp)
    80001e7e:	6105                	addi	sp,sp,32
    80001e80:	8082                	ret
    uvmunmap(p->kpagetable, p->kstack, 1, 1);
    80001e82:	4685                	li	a3,1
    80001e84:	4605                	li	a2,1
    80001e86:	1684b503          	ld	a0,360(s1)
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	5aa080e7          	jalr	1450(ra) # 80001434 <uvmunmap>
    80001e92:	b7e9                	j	80001e5c <freeproc+0x4e>

0000000080001e94 <allocproc>:
{
    80001e94:	1101                	addi	sp,sp,-32
    80001e96:	ec06                	sd	ra,24(sp)
    80001e98:	e822                	sd	s0,16(sp)
    80001e9a:	e426                	sd	s1,8(sp)
    80001e9c:	e04a                	sd	s2,0(sp)
    80001e9e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ea0:	00010497          	auipc	s1,0x10
    80001ea4:	ec848493          	addi	s1,s1,-312 # 80011d68 <proc>
    80001ea8:	00016917          	auipc	s2,0x16
    80001eac:	ac090913          	addi	s2,s2,-1344 # 80017968 <tickslock>
    acquire(&p->lock);
    80001eb0:	8526                	mv	a0,s1
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	d5e080e7          	jalr	-674(ra) # 80000c10 <acquire>
    if(p->state == UNUSED) {
    80001eba:	4c9c                	lw	a5,24(s1)
    80001ebc:	cf81                	beqz	a5,80001ed4 <allocproc+0x40>
      release(&p->lock);
    80001ebe:	8526                	mv	a0,s1
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	e04080e7          	jalr	-508(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ec8:	17048493          	addi	s1,s1,368
    80001ecc:	ff2492e3          	bne	s1,s2,80001eb0 <allocproc+0x1c>
  return 0;
    80001ed0:	4481                	li	s1,0
    80001ed2:	a071                	j	80001f5e <allocproc+0xca>
  p->pid = allocpid();
    80001ed4:	00000097          	auipc	ra,0x0
    80001ed8:	d7a080e7          	jalr	-646(ra) # 80001c4e <allocpid>
    80001edc:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	c42080e7          	jalr	-958(ra) # 80000b20 <kalloc>
    80001ee6:	892a                	mv	s2,a0
    80001ee8:	eca8                	sd	a0,88(s1)
    80001eea:	c149                	beqz	a0,80001f6c <allocproc+0xd8>
  p->pagetable = proc_pagetable(p);
    80001eec:	8526                	mv	a0,s1
    80001eee:	00000097          	auipc	ra,0x0
    80001ef2:	da6080e7          	jalr	-602(ra) # 80001c94 <proc_pagetable>
    80001ef6:	892a                	mv	s2,a0
    80001ef8:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001efa:	c141                	beqz	a0,80001f7a <allocproc+0xe6>
  p->kpagetable = proc_kpagetable(p);
    80001efc:	8526                	mv	a0,s1
    80001efe:	00000097          	auipc	ra,0x0
    80001f02:	e32080e7          	jalr	-462(ra) # 80001d30 <proc_kpagetable>
    80001f06:	892a                	mv	s2,a0
    80001f08:	16a4b423          	sd	a0,360(s1)
  if(p->kpagetable == 0){
    80001f0c:	c159                	beqz	a0,80001f92 <allocproc+0xfe>
  char *pa = kalloc();
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	c12080e7          	jalr	-1006(ra) # 80000b20 <kalloc>
    80001f16:	862a                	mv	a2,a0
  if(pa == 0)
    80001f18:	c949                	beqz	a0,80001faa <allocproc+0x116>
  vmmap(p->kpagetable, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001f1a:	4719                	li	a4,6
    80001f1c:	6685                	lui	a3,0x1
    80001f1e:	04000937          	lui	s2,0x4000
    80001f22:	1975                	addi	s2,s2,-3
    80001f24:	00c91593          	slli	a1,s2,0xc
    80001f28:	1684b503          	ld	a0,360(s1)
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	424080e7          	jalr	1060(ra) # 80001350 <vmmap>
  p->kstack = va;
    80001f34:	0932                	slli	s2,s2,0xc
    80001f36:	0524b023          	sd	s2,64(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001f3a:	07000613          	li	a2,112
    80001f3e:	4581                	li	a1,0
    80001f40:	06048513          	addi	a0,s1,96
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	dc8080e7          	jalr	-568(ra) # 80000d0c <memset>
  p->context.ra = (uint64)forkret;
    80001f4c:	00000797          	auipc	a5,0x0
    80001f50:	cbc78793          	addi	a5,a5,-836 # 80001c08 <forkret>
    80001f54:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f56:	60bc                	ld	a5,64(s1)
    80001f58:	6705                	lui	a4,0x1
    80001f5a:	97ba                	add	a5,a5,a4
    80001f5c:	f4bc                	sd	a5,104(s1)
}
    80001f5e:	8526                	mv	a0,s1
    80001f60:	60e2                	ld	ra,24(sp)
    80001f62:	6442                	ld	s0,16(sp)
    80001f64:	64a2                	ld	s1,8(sp)
    80001f66:	6902                	ld	s2,0(sp)
    80001f68:	6105                	addi	sp,sp,32
    80001f6a:	8082                	ret
    release(&p->lock);
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	d56080e7          	jalr	-682(ra) # 80000cc4 <release>
    return 0;
    80001f76:	84ca                	mv	s1,s2
    80001f78:	b7dd                	j	80001f5e <allocproc+0xca>
    freeproc(p);
    80001f7a:	8526                	mv	a0,s1
    80001f7c:	00000097          	auipc	ra,0x0
    80001f80:	e92080e7          	jalr	-366(ra) # 80001e0e <freeproc>
    release(&p->lock);
    80001f84:	8526                	mv	a0,s1
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	d3e080e7          	jalr	-706(ra) # 80000cc4 <release>
    return 0;
    80001f8e:	84ca                	mv	s1,s2
    80001f90:	b7f9                	j	80001f5e <allocproc+0xca>
    freeproc(p);
    80001f92:	8526                	mv	a0,s1
    80001f94:	00000097          	auipc	ra,0x0
    80001f98:	e7a080e7          	jalr	-390(ra) # 80001e0e <freeproc>
    release(&p->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	d26080e7          	jalr	-730(ra) # 80000cc4 <release>
    return 0;
    80001fa6:	84ca                	mv	s1,s2
    80001fa8:	bf5d                	j	80001f5e <allocproc+0xca>
    panic("kalloc");
    80001faa:	00006517          	auipc	a0,0x6
    80001fae:	2c650513          	addi	a0,a0,710 # 80008270 <digits+0x240>
    80001fb2:	ffffe097          	auipc	ra,0xffffe
    80001fb6:	596080e7          	jalr	1430(ra) # 80000548 <panic>

0000000080001fba <userinit>:
{
    80001fba:	1101                	addi	sp,sp,-32
    80001fbc:	ec06                	sd	ra,24(sp)
    80001fbe:	e822                	sd	s0,16(sp)
    80001fc0:	e426                	sd	s1,8(sp)
    80001fc2:	e04a                	sd	s2,0(sp)
    80001fc4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001fc6:	00000097          	auipc	ra,0x0
    80001fca:	ece080e7          	jalr	-306(ra) # 80001e94 <allocproc>
    80001fce:	84aa                	mv	s1,a0
  initproc = p;
    80001fd0:	00007797          	auipc	a5,0x7
    80001fd4:	04a7b423          	sd	a0,72(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001fd8:	03400613          	li	a2,52
    80001fdc:	00007597          	auipc	a1,0x7
    80001fe0:	91458593          	addi	a1,a1,-1772 # 800088f0 <initcode>
    80001fe4:	6928                	ld	a0,80(a0)
    80001fe6:	fffff097          	auipc	ra,0xfffff
    80001fea:	558080e7          	jalr	1368(ra) # 8000153e <uvminit>
  p->sz = PGSIZE;
    80001fee:	6905                	lui	s2,0x1
    80001ff0:	0524b423          	sd	s2,72(s1)
  u2kvmcopy(p->pagetable, p->kpagetable, 0, p->sz);
    80001ff4:	6685                	lui	a3,0x1
    80001ff6:	4601                	li	a2,0
    80001ff8:	1684b583          	ld	a1,360(s1)
    80001ffc:	68a8                	ld	a0,80(s1)
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	830080e7          	jalr	-2000(ra) # 8000182e <u2kvmcopy>
  p->trapframe->epc = 0;      // user program counter
    80002006:	6cbc                	ld	a5,88(s1)
    80002008:	0007bc23          	sd	zero,24(a5)
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000200c:	6cbc                	ld	a5,88(s1)
    8000200e:	0327b823          	sd	s2,48(a5)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002012:	4641                	li	a2,16
    80002014:	00006597          	auipc	a1,0x6
    80002018:	26458593          	addi	a1,a1,612 # 80008278 <digits+0x248>
    8000201c:	15848513          	addi	a0,s1,344
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	e42080e7          	jalr	-446(ra) # 80000e62 <safestrcpy>
  p->cwd = namei("/");
    80002028:	00006517          	auipc	a0,0x6
    8000202c:	26050513          	addi	a0,a0,608 # 80008288 <digits+0x258>
    80002030:	00002097          	auipc	ra,0x2
    80002034:	150080e7          	jalr	336(ra) # 80004180 <namei>
    80002038:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000203c:	4789                	li	a5,2
    8000203e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002040:	8526                	mv	a0,s1
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	c82080e7          	jalr	-894(ra) # 80000cc4 <release>
}
    8000204a:	60e2                	ld	ra,24(sp)
    8000204c:	6442                	ld	s0,16(sp)
    8000204e:	64a2                	ld	s1,8(sp)
    80002050:	6902                	ld	s2,0(sp)
    80002052:	6105                	addi	sp,sp,32
    80002054:	8082                	ret

0000000080002056 <growproc>:
{
    80002056:	7179                	addi	sp,sp,-48
    80002058:	f406                	sd	ra,40(sp)
    8000205a:	f022                	sd	s0,32(sp)
    8000205c:	ec26                	sd	s1,24(sp)
    8000205e:	e84a                	sd	s2,16(sp)
    80002060:	e44e                	sd	s3,8(sp)
    80002062:	1800                	addi	s0,sp,48
    80002064:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002066:	00000097          	auipc	ra,0x0
    8000206a:	b6a080e7          	jalr	-1174(ra) # 80001bd0 <myproc>
    8000206e:	84aa                	mv	s1,a0
  sz = p->sz;
    80002070:	652c                	ld	a1,72(a0)
    80002072:	0005899b          	sext.w	s3,a1
  if(n > 0){
    80002076:	07205663          	blez	s2,800020e2 <growproc+0x8c>
    if(PGROUNDUP(sz+n) >= PLIC)
    8000207a:	0139093b          	addw	s2,s2,s3
    8000207e:	6785                	lui	a5,0x1
    80002080:	37fd                	addiw	a5,a5,-1
    80002082:	00f907bb          	addw	a5,s2,a5
    80002086:	777d                	lui	a4,0xfffff
    80002088:	8ff9                	and	a5,a5,a4
    8000208a:	2781                	sext.w	a5,a5
    8000208c:	0c000737          	lui	a4,0xc000
    80002090:	08e7f663          	bgeu	a5,a4,8000211c <growproc+0xc6>
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) 
    80002094:	02091613          	slli	a2,s2,0x20
    80002098:	9201                	srli	a2,a2,0x20
    8000209a:	1582                	slli	a1,a1,0x20
    8000209c:	9181                	srli	a1,a1,0x20
    8000209e:	6928                	ld	a0,80(a0)
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	570080e7          	jalr	1392(ra) # 80001610 <uvmalloc>
    800020a8:	0005099b          	sext.w	s3,a0
    800020ac:	06098a63          	beqz	s3,80002120 <growproc+0xca>
    if(u2kvmcopy(p->pagetable, p->kpagetable, p->sz, sz) < 0)
    800020b0:	02051693          	slli	a3,a0,0x20
    800020b4:	9281                	srli	a3,a3,0x20
    800020b6:	64b0                	ld	a2,72(s1)
    800020b8:	1684b583          	ld	a1,360(s1)
    800020bc:	68a8                	ld	a0,80(s1)
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	770080e7          	jalr	1904(ra) # 8000182e <u2kvmcopy>
    800020c6:	04054f63          	bltz	a0,80002124 <growproc+0xce>
  p->sz = sz;
    800020ca:	02099613          	slli	a2,s3,0x20
    800020ce:	9201                	srli	a2,a2,0x20
    800020d0:	e4b0                	sd	a2,72(s1)
  return 0;
    800020d2:	4501                	li	a0,0
}
    800020d4:	70a2                	ld	ra,40(sp)
    800020d6:	7402                	ld	s0,32(sp)
    800020d8:	64e2                	ld	s1,24(sp)
    800020da:	6942                	ld	s2,16(sp)
    800020dc:	69a2                	ld	s3,8(sp)
    800020de:	6145                	addi	sp,sp,48
    800020e0:	8082                	ret
  } else if(n < 0){
    800020e2:	fe0954e3          	bgez	s2,800020ca <growproc+0x74>
    sz = uvmdealloc(p->pagetable, sz, sz + n);  /** sz已变小，sz <- sz-|n|，此时p->sz > sz */
    800020e6:	0139063b          	addw	a2,s2,s3
    800020ea:	597d                	li	s2,-1
    800020ec:	02095913          	srli	s2,s2,0x20
    800020f0:	1602                	slli	a2,a2,0x20
    800020f2:	9201                	srli	a2,a2,0x20
    800020f4:	0125f5b3          	and	a1,a1,s2
    800020f8:	6928                	ld	a0,80(a0)
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	4fc080e7          	jalr	1276(ra) # 800015f6 <uvmdealloc>
    sz = vmdealloc(p->kpagetable, p->sz, sz, 0);
    80002102:	4681                	li	a3,0
    80002104:	01257633          	and	a2,a0,s2
    80002108:	64ac                	ld	a1,72(s1)
    8000210a:	1684b503          	ld	a0,360(s1)
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	4a2080e7          	jalr	1186(ra) # 800015b0 <vmdealloc>
    80002116:	0005099b          	sext.w	s3,a0
    8000211a:	bf45                	j	800020ca <growproc+0x74>
      return -1;
    8000211c:	557d                	li	a0,-1
    8000211e:	bf5d                	j	800020d4 <growproc+0x7e>
      return -1;
    80002120:	557d                	li	a0,-1
    80002122:	bf4d                	j	800020d4 <growproc+0x7e>
      return -1;
    80002124:	557d                	li	a0,-1
    80002126:	b77d                	j	800020d4 <growproc+0x7e>

0000000080002128 <fork>:
{
    80002128:	7179                	addi	sp,sp,-48
    8000212a:	f406                	sd	ra,40(sp)
    8000212c:	f022                	sd	s0,32(sp)
    8000212e:	ec26                	sd	s1,24(sp)
    80002130:	e84a                	sd	s2,16(sp)
    80002132:	e44e                	sd	s3,8(sp)
    80002134:	e052                	sd	s4,0(sp)
    80002136:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002138:	00000097          	auipc	ra,0x0
    8000213c:	a98080e7          	jalr	-1384(ra) # 80001bd0 <myproc>
    80002140:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002142:	00000097          	auipc	ra,0x0
    80002146:	d52080e7          	jalr	-686(ra) # 80001e94 <allocproc>
    8000214a:	10050a63          	beqz	a0,8000225e <fork+0x136>
    8000214e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002150:	04893603          	ld	a2,72(s2) # 1048 <_entry-0x7fffefb8>
    80002154:	692c                	ld	a1,80(a0)
    80002156:	05093503          	ld	a0,80(s2)
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	602080e7          	jalr	1538(ra) # 8000175c <uvmcopy>
    80002162:	06054363          	bltz	a0,800021c8 <fork+0xa0>
  np->sz = p->sz;
    80002166:	04893683          	ld	a3,72(s2)
    8000216a:	04d9b423          	sd	a3,72(s3) # 1048 <_entry-0x7fffefb8>
  if(u2kvmcopy(np->pagetable, np->kpagetable, 0, np->sz) < 0) {
    8000216e:	4601                	li	a2,0
    80002170:	1689b583          	ld	a1,360(s3)
    80002174:	0509b503          	ld	a0,80(s3)
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	6b6080e7          	jalr	1718(ra) # 8000182e <u2kvmcopy>
    80002180:	06054063          	bltz	a0,800021e0 <fork+0xb8>
  np->parent = p;
    80002184:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80002188:	05893683          	ld	a3,88(s2)
    8000218c:	87b6                	mv	a5,a3
    8000218e:	0589b703          	ld	a4,88(s3)
    80002192:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002196:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000219a:	6788                	ld	a0,8(a5)
    8000219c:	6b8c                	ld	a1,16(a5)
    8000219e:	6f90                	ld	a2,24(a5)
    800021a0:	01073023          	sd	a6,0(a4) # c000000 <_entry-0x74000000>
    800021a4:	e708                	sd	a0,8(a4)
    800021a6:	eb0c                	sd	a1,16(a4)
    800021a8:	ef10                	sd	a2,24(a4)
    800021aa:	02078793          	addi	a5,a5,32
    800021ae:	02070713          	addi	a4,a4,32
    800021b2:	fed792e3          	bne	a5,a3,80002196 <fork+0x6e>
  np->trapframe->a0 = 0;
    800021b6:	0589b783          	ld	a5,88(s3)
    800021ba:	0607b823          	sd	zero,112(a5)
    800021be:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    800021c2:	15000a13          	li	s4,336
    800021c6:	a099                	j	8000220c <fork+0xe4>
    freeproc(np);
    800021c8:	854e                	mv	a0,s3
    800021ca:	00000097          	auipc	ra,0x0
    800021ce:	c44080e7          	jalr	-956(ra) # 80001e0e <freeproc>
    release(&np->lock);
    800021d2:	854e                	mv	a0,s3
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	af0080e7          	jalr	-1296(ra) # 80000cc4 <release>
    return -1;
    800021dc:	54fd                	li	s1,-1
    800021de:	a0bd                	j	8000224c <fork+0x124>
    freeproc(np);
    800021e0:	854e                	mv	a0,s3
    800021e2:	00000097          	auipc	ra,0x0
    800021e6:	c2c080e7          	jalr	-980(ra) # 80001e0e <freeproc>
    release(&np->lock);
    800021ea:	854e                	mv	a0,s3
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	ad8080e7          	jalr	-1320(ra) # 80000cc4 <release>
    return -1;
    800021f4:	54fd                	li	s1,-1
    800021f6:	a899                	j	8000224c <fork+0x124>
      np->ofile[i] = filedup(p->ofile[i]);
    800021f8:	00002097          	auipc	ra,0x2
    800021fc:	614080e7          	jalr	1556(ra) # 8000480c <filedup>
    80002200:	009987b3          	add	a5,s3,s1
    80002204:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002206:	04a1                	addi	s1,s1,8
    80002208:	01448763          	beq	s1,s4,80002216 <fork+0xee>
    if(p->ofile[i])
    8000220c:	009907b3          	add	a5,s2,s1
    80002210:	6388                	ld	a0,0(a5)
    80002212:	f17d                	bnez	a0,800021f8 <fork+0xd0>
    80002214:	bfcd                	j	80002206 <fork+0xde>
  np->cwd = idup(p->cwd);
    80002216:	15093503          	ld	a0,336(s2)
    8000221a:	00001097          	auipc	ra,0x1
    8000221e:	778080e7          	jalr	1912(ra) # 80003992 <idup>
    80002222:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002226:	4641                	li	a2,16
    80002228:	15890593          	addi	a1,s2,344
    8000222c:	15898513          	addi	a0,s3,344
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	c32080e7          	jalr	-974(ra) # 80000e62 <safestrcpy>
  pid = np->pid;
    80002238:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    8000223c:	4789                	li	a5,2
    8000223e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002242:	854e                	mv	a0,s3
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	a80080e7          	jalr	-1408(ra) # 80000cc4 <release>
}
    8000224c:	8526                	mv	a0,s1
    8000224e:	70a2                	ld	ra,40(sp)
    80002250:	7402                	ld	s0,32(sp)
    80002252:	64e2                	ld	s1,24(sp)
    80002254:	6942                	ld	s2,16(sp)
    80002256:	69a2                	ld	s3,8(sp)
    80002258:	6a02                	ld	s4,0(sp)
    8000225a:	6145                	addi	sp,sp,48
    8000225c:	8082                	ret
    return -1;
    8000225e:	54fd                	li	s1,-1
    80002260:	b7f5                	j	8000224c <fork+0x124>

0000000080002262 <reparent>:
{
    80002262:	7179                	addi	sp,sp,-48
    80002264:	f406                	sd	ra,40(sp)
    80002266:	f022                	sd	s0,32(sp)
    80002268:	ec26                	sd	s1,24(sp)
    8000226a:	e84a                	sd	s2,16(sp)
    8000226c:	e44e                	sd	s3,8(sp)
    8000226e:	e052                	sd	s4,0(sp)
    80002270:	1800                	addi	s0,sp,48
    80002272:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002274:	00010497          	auipc	s1,0x10
    80002278:	af448493          	addi	s1,s1,-1292 # 80011d68 <proc>
      pp->parent = initproc;
    8000227c:	00007a17          	auipc	s4,0x7
    80002280:	d9ca0a13          	addi	s4,s4,-612 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002284:	00015997          	auipc	s3,0x15
    80002288:	6e498993          	addi	s3,s3,1764 # 80017968 <tickslock>
    8000228c:	a029                	j	80002296 <reparent+0x34>
    8000228e:	17048493          	addi	s1,s1,368
    80002292:	03348363          	beq	s1,s3,800022b8 <reparent+0x56>
    if(pp->parent == p){
    80002296:	709c                	ld	a5,32(s1)
    80002298:	ff279be3          	bne	a5,s2,8000228e <reparent+0x2c>
      acquire(&pp->lock);
    8000229c:	8526                	mv	a0,s1
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	972080e7          	jalr	-1678(ra) # 80000c10 <acquire>
      pp->parent = initproc;
    800022a6:	000a3783          	ld	a5,0(s4)
    800022aa:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    800022ac:	8526                	mv	a0,s1
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	a16080e7          	jalr	-1514(ra) # 80000cc4 <release>
    800022b6:	bfe1                	j	8000228e <reparent+0x2c>
}
    800022b8:	70a2                	ld	ra,40(sp)
    800022ba:	7402                	ld	s0,32(sp)
    800022bc:	64e2                	ld	s1,24(sp)
    800022be:	6942                	ld	s2,16(sp)
    800022c0:	69a2                	ld	s3,8(sp)
    800022c2:	6a02                	ld	s4,0(sp)
    800022c4:	6145                	addi	sp,sp,48
    800022c6:	8082                	ret

00000000800022c8 <scheduler>:
{
    800022c8:	715d                	addi	sp,sp,-80
    800022ca:	e486                	sd	ra,72(sp)
    800022cc:	e0a2                	sd	s0,64(sp)
    800022ce:	fc26                	sd	s1,56(sp)
    800022d0:	f84a                	sd	s2,48(sp)
    800022d2:	f44e                	sd	s3,40(sp)
    800022d4:	f052                	sd	s4,32(sp)
    800022d6:	ec56                	sd	s5,24(sp)
    800022d8:	e85a                	sd	s6,16(sp)
    800022da:	e45e                	sd	s7,8(sp)
    800022dc:	e062                	sd	s8,0(sp)
    800022de:	0880                	addi	s0,sp,80
    800022e0:	8792                	mv	a5,tp
  int id = r_tp();
    800022e2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800022e4:	00779b13          	slli	s6,a5,0x7
    800022e8:	0000f717          	auipc	a4,0xf
    800022ec:	66870713          	addi	a4,a4,1640 # 80011950 <pid_lock>
    800022f0:	975a                	add	a4,a4,s6
    800022f2:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    800022f6:	0000f717          	auipc	a4,0xf
    800022fa:	67a70713          	addi	a4,a4,1658 # 80011970 <cpus+0x8>
    800022fe:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002300:	4c0d                	li	s8,3
        c->proc = p;
    80002302:	079e                	slli	a5,a5,0x7
    80002304:	0000fa17          	auipc	s4,0xf
    80002308:	64ca0a13          	addi	s4,s4,1612 # 80011950 <pid_lock>
    8000230c:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000230e:	00015997          	auipc	s3,0x15
    80002312:	65a98993          	addi	s3,s3,1626 # 80017968 <tickslock>
        found = 1;
    80002316:	4b85                	li	s7,1
    80002318:	a08d                	j	8000237a <scheduler+0xb2>
        p->state = RUNNING;
    8000231a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000231e:	009a3c23          	sd	s1,24(s4)
        vminithart(p->kpagetable);
    80002322:	1684b503          	ld	a0,360(s1)
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	cda080e7          	jalr	-806(ra) # 80001000 <vminithart>
        swtch(&c->context, &p->context);
    8000232e:	06048593          	addi	a1,s1,96
    80002332:	855a                	mv	a0,s6
    80002334:	00000097          	auipc	ra,0x0
    80002338:	638080e7          	jalr	1592(ra) # 8000296c <swtch>
        c->proc = 0;
    8000233c:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80002340:	8ade                	mv	s5,s7
      release(&p->lock);
    80002342:	8526                	mv	a0,s1
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	980080e7          	jalr	-1664(ra) # 80000cc4 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000234c:	17048493          	addi	s1,s1,368
    80002350:	01348b63          	beq	s1,s3,80002366 <scheduler+0x9e>
      acquire(&p->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	8ba080e7          	jalr	-1862(ra) # 80000c10 <acquire>
      if(p->state == RUNNABLE) {
    8000235e:	4c9c                	lw	a5,24(s1)
    80002360:	ff2791e3          	bne	a5,s2,80002342 <scheduler+0x7a>
    80002364:	bf5d                	j	8000231a <scheduler+0x52>
    if(found == 0) {
    80002366:	000a9a63          	bnez	s5,8000237a <scheduler+0xb2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000236a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000236e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002372:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002376:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000237a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000237e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002382:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002386:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002388:	00010497          	auipc	s1,0x10
    8000238c:	9e048493          	addi	s1,s1,-1568 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002390:	4909                	li	s2,2
    80002392:	b7c9                	j	80002354 <scheduler+0x8c>

0000000080002394 <sched>:
{
    80002394:	7179                	addi	sp,sp,-48
    80002396:	f406                	sd	ra,40(sp)
    80002398:	f022                	sd	s0,32(sp)
    8000239a:	ec26                	sd	s1,24(sp)
    8000239c:	e84a                	sd	s2,16(sp)
    8000239e:	e44e                	sd	s3,8(sp)
    800023a0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	82e080e7          	jalr	-2002(ra) # 80001bd0 <myproc>
    800023aa:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023ac:	ffffe097          	auipc	ra,0xffffe
    800023b0:	7ea080e7          	jalr	2026(ra) # 80000b96 <holding>
    800023b4:	c93d                	beqz	a0,8000242a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023b6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023b8:	2781                	sext.w	a5,a5
    800023ba:	079e                	slli	a5,a5,0x7
    800023bc:	0000f717          	auipc	a4,0xf
    800023c0:	59470713          	addi	a4,a4,1428 # 80011950 <pid_lock>
    800023c4:	97ba                	add	a5,a5,a4
    800023c6:	0907a703          	lw	a4,144(a5)
    800023ca:	4785                	li	a5,1
    800023cc:	06f71763          	bne	a4,a5,8000243a <sched+0xa6>
  if(p->state == RUNNING)
    800023d0:	4c98                	lw	a4,24(s1)
    800023d2:	478d                	li	a5,3
    800023d4:	06f70b63          	beq	a4,a5,8000244a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023d8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023dc:	8b89                	andi	a5,a5,2
  if(intr_get())
    800023de:	efb5                	bnez	a5,8000245a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023e0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023e2:	0000f917          	auipc	s2,0xf
    800023e6:	56e90913          	addi	s2,s2,1390 # 80011950 <pid_lock>
    800023ea:	2781                	sext.w	a5,a5
    800023ec:	079e                	slli	a5,a5,0x7
    800023ee:	97ca                	add	a5,a5,s2
    800023f0:	0947a983          	lw	s3,148(a5)
    800023f4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023f6:	2781                	sext.w	a5,a5
    800023f8:	079e                	slli	a5,a5,0x7
    800023fa:	0000f597          	auipc	a1,0xf
    800023fe:	57658593          	addi	a1,a1,1398 # 80011970 <cpus+0x8>
    80002402:	95be                	add	a1,a1,a5
    80002404:	06048513          	addi	a0,s1,96
    80002408:	00000097          	auipc	ra,0x0
    8000240c:	564080e7          	jalr	1380(ra) # 8000296c <swtch>
    80002410:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002412:	2781                	sext.w	a5,a5
    80002414:	079e                	slli	a5,a5,0x7
    80002416:	97ca                	add	a5,a5,s2
    80002418:	0937aa23          	sw	s3,148(a5)
}
    8000241c:	70a2                	ld	ra,40(sp)
    8000241e:	7402                	ld	s0,32(sp)
    80002420:	64e2                	ld	s1,24(sp)
    80002422:	6942                	ld	s2,16(sp)
    80002424:	69a2                	ld	s3,8(sp)
    80002426:	6145                	addi	sp,sp,48
    80002428:	8082                	ret
    panic("sched p->lock");
    8000242a:	00006517          	auipc	a0,0x6
    8000242e:	e6650513          	addi	a0,a0,-410 # 80008290 <digits+0x260>
    80002432:	ffffe097          	auipc	ra,0xffffe
    80002436:	116080e7          	jalr	278(ra) # 80000548 <panic>
    panic("sched locks");
    8000243a:	00006517          	auipc	a0,0x6
    8000243e:	e6650513          	addi	a0,a0,-410 # 800082a0 <digits+0x270>
    80002442:	ffffe097          	auipc	ra,0xffffe
    80002446:	106080e7          	jalr	262(ra) # 80000548 <panic>
    panic("sched running");
    8000244a:	00006517          	auipc	a0,0x6
    8000244e:	e6650513          	addi	a0,a0,-410 # 800082b0 <digits+0x280>
    80002452:	ffffe097          	auipc	ra,0xffffe
    80002456:	0f6080e7          	jalr	246(ra) # 80000548 <panic>
    panic("sched interruptible");
    8000245a:	00006517          	auipc	a0,0x6
    8000245e:	e6650513          	addi	a0,a0,-410 # 800082c0 <digits+0x290>
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	0e6080e7          	jalr	230(ra) # 80000548 <panic>

000000008000246a <exit>:
{
    8000246a:	7179                	addi	sp,sp,-48
    8000246c:	f406                	sd	ra,40(sp)
    8000246e:	f022                	sd	s0,32(sp)
    80002470:	ec26                	sd	s1,24(sp)
    80002472:	e84a                	sd	s2,16(sp)
    80002474:	e44e                	sd	s3,8(sp)
    80002476:	e052                	sd	s4,0(sp)
    80002478:	1800                	addi	s0,sp,48
    8000247a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	754080e7          	jalr	1876(ra) # 80001bd0 <myproc>
    80002484:	89aa                	mv	s3,a0
  if(p == initproc)
    80002486:	00007797          	auipc	a5,0x7
    8000248a:	b927b783          	ld	a5,-1134(a5) # 80009018 <initproc>
    8000248e:	0d050493          	addi	s1,a0,208
    80002492:	15050913          	addi	s2,a0,336
    80002496:	02a79363          	bne	a5,a0,800024bc <exit+0x52>
    panic("init exiting");
    8000249a:	00006517          	auipc	a0,0x6
    8000249e:	e3e50513          	addi	a0,a0,-450 # 800082d8 <digits+0x2a8>
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	0a6080e7          	jalr	166(ra) # 80000548 <panic>
      fileclose(f);
    800024aa:	00002097          	auipc	ra,0x2
    800024ae:	3b4080e7          	jalr	948(ra) # 8000485e <fileclose>
      p->ofile[fd] = 0;
    800024b2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800024b6:	04a1                	addi	s1,s1,8
    800024b8:	01248563          	beq	s1,s2,800024c2 <exit+0x58>
    if(p->ofile[fd]){
    800024bc:	6088                	ld	a0,0(s1)
    800024be:	f575                	bnez	a0,800024aa <exit+0x40>
    800024c0:	bfdd                	j	800024b6 <exit+0x4c>
  begin_op();
    800024c2:	00002097          	auipc	ra,0x2
    800024c6:	eca080e7          	jalr	-310(ra) # 8000438c <begin_op>
  iput(p->cwd);
    800024ca:	1509b503          	ld	a0,336(s3)
    800024ce:	00001097          	auipc	ra,0x1
    800024d2:	6bc080e7          	jalr	1724(ra) # 80003b8a <iput>
  end_op();
    800024d6:	00002097          	auipc	ra,0x2
    800024da:	f36080e7          	jalr	-202(ra) # 8000440c <end_op>
  p->cwd = 0;
    800024de:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800024e2:	00007497          	auipc	s1,0x7
    800024e6:	b3648493          	addi	s1,s1,-1226 # 80009018 <initproc>
    800024ea:	6088                	ld	a0,0(s1)
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	724080e7          	jalr	1828(ra) # 80000c10 <acquire>
  wakeup1(initproc);
    800024f4:	6088                	ld	a0,0(s1)
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	602080e7          	jalr	1538(ra) # 80001af8 <wakeup1>
  release(&initproc->lock);
    800024fe:	6088                	ld	a0,0(s1)
    80002500:	ffffe097          	auipc	ra,0xffffe
    80002504:	7c4080e7          	jalr	1988(ra) # 80000cc4 <release>
  acquire(&p->lock);
    80002508:	854e                	mv	a0,s3
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	706080e7          	jalr	1798(ra) # 80000c10 <acquire>
  struct proc *original_parent = p->parent;
    80002512:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002516:	854e                	mv	a0,s3
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	7ac080e7          	jalr	1964(ra) # 80000cc4 <release>
  acquire(&original_parent->lock);
    80002520:	8526                	mv	a0,s1
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	6ee080e7          	jalr	1774(ra) # 80000c10 <acquire>
  acquire(&p->lock);
    8000252a:	854e                	mv	a0,s3
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	6e4080e7          	jalr	1764(ra) # 80000c10 <acquire>
  reparent(p);
    80002534:	854e                	mv	a0,s3
    80002536:	00000097          	auipc	ra,0x0
    8000253a:	d2c080e7          	jalr	-724(ra) # 80002262 <reparent>
  wakeup1(original_parent);
    8000253e:	8526                	mv	a0,s1
    80002540:	fffff097          	auipc	ra,0xfffff
    80002544:	5b8080e7          	jalr	1464(ra) # 80001af8 <wakeup1>
  p->xstate = status;
    80002548:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    8000254c:	4791                	li	a5,4
    8000254e:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002552:	8526                	mv	a0,s1
    80002554:	ffffe097          	auipc	ra,0xffffe
    80002558:	770080e7          	jalr	1904(ra) # 80000cc4 <release>
  sched();
    8000255c:	00000097          	auipc	ra,0x0
    80002560:	e38080e7          	jalr	-456(ra) # 80002394 <sched>
  panic("zombie exit");
    80002564:	00006517          	auipc	a0,0x6
    80002568:	d8450513          	addi	a0,a0,-636 # 800082e8 <digits+0x2b8>
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	fdc080e7          	jalr	-36(ra) # 80000548 <panic>

0000000080002574 <yield>:
{
    80002574:	1101                	addi	sp,sp,-32
    80002576:	ec06                	sd	ra,24(sp)
    80002578:	e822                	sd	s0,16(sp)
    8000257a:	e426                	sd	s1,8(sp)
    8000257c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000257e:	fffff097          	auipc	ra,0xfffff
    80002582:	652080e7          	jalr	1618(ra) # 80001bd0 <myproc>
    80002586:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	688080e7          	jalr	1672(ra) # 80000c10 <acquire>
  p->state = RUNNABLE;
    80002590:	4789                	li	a5,2
    80002592:	cc9c                	sw	a5,24(s1)
  sched();
    80002594:	00000097          	auipc	ra,0x0
    80002598:	e00080e7          	jalr	-512(ra) # 80002394 <sched>
  release(&p->lock);
    8000259c:	8526                	mv	a0,s1
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	726080e7          	jalr	1830(ra) # 80000cc4 <release>
}
    800025a6:	60e2                	ld	ra,24(sp)
    800025a8:	6442                	ld	s0,16(sp)
    800025aa:	64a2                	ld	s1,8(sp)
    800025ac:	6105                	addi	sp,sp,32
    800025ae:	8082                	ret

00000000800025b0 <sleep>:
{
    800025b0:	7179                	addi	sp,sp,-48
    800025b2:	f406                	sd	ra,40(sp)
    800025b4:	f022                	sd	s0,32(sp)
    800025b6:	ec26                	sd	s1,24(sp)
    800025b8:	e84a                	sd	s2,16(sp)
    800025ba:	e44e                	sd	s3,8(sp)
    800025bc:	1800                	addi	s0,sp,48
    800025be:	89aa                	mv	s3,a0
    800025c0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800025c2:	fffff097          	auipc	ra,0xfffff
    800025c6:	60e080e7          	jalr	1550(ra) # 80001bd0 <myproc>
    800025ca:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800025cc:	05250663          	beq	a0,s2,80002618 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	640080e7          	jalr	1600(ra) # 80000c10 <acquire>
    release(lk);
    800025d8:	854a                	mv	a0,s2
    800025da:	ffffe097          	auipc	ra,0xffffe
    800025de:	6ea080e7          	jalr	1770(ra) # 80000cc4 <release>
  p->chan = chan;
    800025e2:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800025e6:	4785                	li	a5,1
    800025e8:	cc9c                	sw	a5,24(s1)
  sched();
    800025ea:	00000097          	auipc	ra,0x0
    800025ee:	daa080e7          	jalr	-598(ra) # 80002394 <sched>
  p->chan = 0;
    800025f2:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800025f6:	8526                	mv	a0,s1
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	6cc080e7          	jalr	1740(ra) # 80000cc4 <release>
    acquire(lk);
    80002600:	854a                	mv	a0,s2
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	60e080e7          	jalr	1550(ra) # 80000c10 <acquire>
}
    8000260a:	70a2                	ld	ra,40(sp)
    8000260c:	7402                	ld	s0,32(sp)
    8000260e:	64e2                	ld	s1,24(sp)
    80002610:	6942                	ld	s2,16(sp)
    80002612:	69a2                	ld	s3,8(sp)
    80002614:	6145                	addi	sp,sp,48
    80002616:	8082                	ret
  p->chan = chan;
    80002618:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000261c:	4785                	li	a5,1
    8000261e:	cd1c                	sw	a5,24(a0)
  sched();
    80002620:	00000097          	auipc	ra,0x0
    80002624:	d74080e7          	jalr	-652(ra) # 80002394 <sched>
  p->chan = 0;
    80002628:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    8000262c:	bff9                	j	8000260a <sleep+0x5a>

000000008000262e <wait>:
{
    8000262e:	715d                	addi	sp,sp,-80
    80002630:	e486                	sd	ra,72(sp)
    80002632:	e0a2                	sd	s0,64(sp)
    80002634:	fc26                	sd	s1,56(sp)
    80002636:	f84a                	sd	s2,48(sp)
    80002638:	f44e                	sd	s3,40(sp)
    8000263a:	f052                	sd	s4,32(sp)
    8000263c:	ec56                	sd	s5,24(sp)
    8000263e:	e85a                	sd	s6,16(sp)
    80002640:	e45e                	sd	s7,8(sp)
    80002642:	e062                	sd	s8,0(sp)
    80002644:	0880                	addi	s0,sp,80
    80002646:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002648:	fffff097          	auipc	ra,0xfffff
    8000264c:	588080e7          	jalr	1416(ra) # 80001bd0 <myproc>
    80002650:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002652:	8c2a                	mv	s8,a0
    80002654:	ffffe097          	auipc	ra,0xffffe
    80002658:	5bc080e7          	jalr	1468(ra) # 80000c10 <acquire>
    havekids = 0;
    8000265c:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000265e:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002660:	00015997          	auipc	s3,0x15
    80002664:	30898993          	addi	s3,s3,776 # 80017968 <tickslock>
        havekids = 1;
    80002668:	4a85                	li	s5,1
    havekids = 0;
    8000266a:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000266c:	0000f497          	auipc	s1,0xf
    80002670:	6fc48493          	addi	s1,s1,1788 # 80011d68 <proc>
    80002674:	a08d                	j	800026d6 <wait+0xa8>
          pid = np->pid;
    80002676:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000267a:	000b0e63          	beqz	s6,80002696 <wait+0x68>
    8000267e:	4691                	li	a3,4
    80002680:	03448613          	addi	a2,s1,52
    80002684:	85da                	mv	a1,s6
    80002686:	05093503          	ld	a0,80(s2)
    8000268a:	fffff097          	auipc	ra,0xfffff
    8000268e:	288080e7          	jalr	648(ra) # 80001912 <copyout>
    80002692:	02054263          	bltz	a0,800026b6 <wait+0x88>
          freeproc(np);
    80002696:	8526                	mv	a0,s1
    80002698:	fffff097          	auipc	ra,0xfffff
    8000269c:	776080e7          	jalr	1910(ra) # 80001e0e <freeproc>
          release(&np->lock);
    800026a0:	8526                	mv	a0,s1
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	622080e7          	jalr	1570(ra) # 80000cc4 <release>
          release(&p->lock);
    800026aa:	854a                	mv	a0,s2
    800026ac:	ffffe097          	auipc	ra,0xffffe
    800026b0:	618080e7          	jalr	1560(ra) # 80000cc4 <release>
          return pid;
    800026b4:	a8a9                	j	8000270e <wait+0xe0>
            release(&np->lock);
    800026b6:	8526                	mv	a0,s1
    800026b8:	ffffe097          	auipc	ra,0xffffe
    800026bc:	60c080e7          	jalr	1548(ra) # 80000cc4 <release>
            release(&p->lock);
    800026c0:	854a                	mv	a0,s2
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	602080e7          	jalr	1538(ra) # 80000cc4 <release>
            return -1;
    800026ca:	59fd                	li	s3,-1
    800026cc:	a089                	j	8000270e <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800026ce:	17048493          	addi	s1,s1,368
    800026d2:	03348463          	beq	s1,s3,800026fa <wait+0xcc>
      if(np->parent == p){
    800026d6:	709c                	ld	a5,32(s1)
    800026d8:	ff279be3          	bne	a5,s2,800026ce <wait+0xa0>
        acquire(&np->lock);
    800026dc:	8526                	mv	a0,s1
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	532080e7          	jalr	1330(ra) # 80000c10 <acquire>
        if(np->state == ZOMBIE){
    800026e6:	4c9c                	lw	a5,24(s1)
    800026e8:	f94787e3          	beq	a5,s4,80002676 <wait+0x48>
        release(&np->lock);
    800026ec:	8526                	mv	a0,s1
    800026ee:	ffffe097          	auipc	ra,0xffffe
    800026f2:	5d6080e7          	jalr	1494(ra) # 80000cc4 <release>
        havekids = 1;
    800026f6:	8756                	mv	a4,s5
    800026f8:	bfd9                	j	800026ce <wait+0xa0>
    if(!havekids || p->killed){
    800026fa:	c701                	beqz	a4,80002702 <wait+0xd4>
    800026fc:	03092783          	lw	a5,48(s2)
    80002700:	c785                	beqz	a5,80002728 <wait+0xfa>
      release(&p->lock);
    80002702:	854a                	mv	a0,s2
    80002704:	ffffe097          	auipc	ra,0xffffe
    80002708:	5c0080e7          	jalr	1472(ra) # 80000cc4 <release>
      return -1;
    8000270c:	59fd                	li	s3,-1
}
    8000270e:	854e                	mv	a0,s3
    80002710:	60a6                	ld	ra,72(sp)
    80002712:	6406                	ld	s0,64(sp)
    80002714:	74e2                	ld	s1,56(sp)
    80002716:	7942                	ld	s2,48(sp)
    80002718:	79a2                	ld	s3,40(sp)
    8000271a:	7a02                	ld	s4,32(sp)
    8000271c:	6ae2                	ld	s5,24(sp)
    8000271e:	6b42                	ld	s6,16(sp)
    80002720:	6ba2                	ld	s7,8(sp)
    80002722:	6c02                	ld	s8,0(sp)
    80002724:	6161                	addi	sp,sp,80
    80002726:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002728:	85e2                	mv	a1,s8
    8000272a:	854a                	mv	a0,s2
    8000272c:	00000097          	auipc	ra,0x0
    80002730:	e84080e7          	jalr	-380(ra) # 800025b0 <sleep>
    havekids = 0;
    80002734:	bf1d                	j	8000266a <wait+0x3c>

0000000080002736 <wakeup>:
{
    80002736:	7139                	addi	sp,sp,-64
    80002738:	fc06                	sd	ra,56(sp)
    8000273a:	f822                	sd	s0,48(sp)
    8000273c:	f426                	sd	s1,40(sp)
    8000273e:	f04a                	sd	s2,32(sp)
    80002740:	ec4e                	sd	s3,24(sp)
    80002742:	e852                	sd	s4,16(sp)
    80002744:	e456                	sd	s5,8(sp)
    80002746:	0080                	addi	s0,sp,64
    80002748:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000274a:	0000f497          	auipc	s1,0xf
    8000274e:	61e48493          	addi	s1,s1,1566 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002752:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002754:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002756:	00015917          	auipc	s2,0x15
    8000275a:	21290913          	addi	s2,s2,530 # 80017968 <tickslock>
    8000275e:	a821                	j	80002776 <wakeup+0x40>
      p->state = RUNNABLE;
    80002760:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    80002764:	8526                	mv	a0,s1
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	55e080e7          	jalr	1374(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000276e:	17048493          	addi	s1,s1,368
    80002772:	01248e63          	beq	s1,s2,8000278e <wakeup+0x58>
    acquire(&p->lock);
    80002776:	8526                	mv	a0,s1
    80002778:	ffffe097          	auipc	ra,0xffffe
    8000277c:	498080e7          	jalr	1176(ra) # 80000c10 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002780:	4c9c                	lw	a5,24(s1)
    80002782:	ff3791e3          	bne	a5,s3,80002764 <wakeup+0x2e>
    80002786:	749c                	ld	a5,40(s1)
    80002788:	fd479ee3          	bne	a5,s4,80002764 <wakeup+0x2e>
    8000278c:	bfd1                	j	80002760 <wakeup+0x2a>
}
    8000278e:	70e2                	ld	ra,56(sp)
    80002790:	7442                	ld	s0,48(sp)
    80002792:	74a2                	ld	s1,40(sp)
    80002794:	7902                	ld	s2,32(sp)
    80002796:	69e2                	ld	s3,24(sp)
    80002798:	6a42                	ld	s4,16(sp)
    8000279a:	6aa2                	ld	s5,8(sp)
    8000279c:	6121                	addi	sp,sp,64
    8000279e:	8082                	ret

00000000800027a0 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800027a0:	7179                	addi	sp,sp,-48
    800027a2:	f406                	sd	ra,40(sp)
    800027a4:	f022                	sd	s0,32(sp)
    800027a6:	ec26                	sd	s1,24(sp)
    800027a8:	e84a                	sd	s2,16(sp)
    800027aa:	e44e                	sd	s3,8(sp)
    800027ac:	1800                	addi	s0,sp,48
    800027ae:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800027b0:	0000f497          	auipc	s1,0xf
    800027b4:	5b848493          	addi	s1,s1,1464 # 80011d68 <proc>
    800027b8:	00015997          	auipc	s3,0x15
    800027bc:	1b098993          	addi	s3,s3,432 # 80017968 <tickslock>
    acquire(&p->lock);
    800027c0:	8526                	mv	a0,s1
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	44e080e7          	jalr	1102(ra) # 80000c10 <acquire>
    if(p->pid == pid){
    800027ca:	5c9c                	lw	a5,56(s1)
    800027cc:	01278d63          	beq	a5,s2,800027e6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800027d0:	8526                	mv	a0,s1
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	4f2080e7          	jalr	1266(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800027da:	17048493          	addi	s1,s1,368
    800027de:	ff3491e3          	bne	s1,s3,800027c0 <kill+0x20>
  }
  return -1;
    800027e2:	557d                	li	a0,-1
    800027e4:	a829                	j	800027fe <kill+0x5e>
      p->killed = 1;
    800027e6:	4785                	li	a5,1
    800027e8:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800027ea:	4c98                	lw	a4,24(s1)
    800027ec:	4785                	li	a5,1
    800027ee:	00f70f63          	beq	a4,a5,8000280c <kill+0x6c>
      release(&p->lock);
    800027f2:	8526                	mv	a0,s1
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	4d0080e7          	jalr	1232(ra) # 80000cc4 <release>
      return 0;
    800027fc:	4501                	li	a0,0
}
    800027fe:	70a2                	ld	ra,40(sp)
    80002800:	7402                	ld	s0,32(sp)
    80002802:	64e2                	ld	s1,24(sp)
    80002804:	6942                	ld	s2,16(sp)
    80002806:	69a2                	ld	s3,8(sp)
    80002808:	6145                	addi	sp,sp,48
    8000280a:	8082                	ret
        p->state = RUNNABLE;
    8000280c:	4789                	li	a5,2
    8000280e:	cc9c                	sw	a5,24(s1)
    80002810:	b7cd                	j	800027f2 <kill+0x52>

0000000080002812 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002812:	7179                	addi	sp,sp,-48
    80002814:	f406                	sd	ra,40(sp)
    80002816:	f022                	sd	s0,32(sp)
    80002818:	ec26                	sd	s1,24(sp)
    8000281a:	e84a                	sd	s2,16(sp)
    8000281c:	e44e                	sd	s3,8(sp)
    8000281e:	e052                	sd	s4,0(sp)
    80002820:	1800                	addi	s0,sp,48
    80002822:	84aa                	mv	s1,a0
    80002824:	892e                	mv	s2,a1
    80002826:	89b2                	mv	s3,a2
    80002828:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000282a:	fffff097          	auipc	ra,0xfffff
    8000282e:	3a6080e7          	jalr	934(ra) # 80001bd0 <myproc>
  if(user_dst){
    80002832:	c08d                	beqz	s1,80002854 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002834:	86d2                	mv	a3,s4
    80002836:	864e                	mv	a2,s3
    80002838:	85ca                	mv	a1,s2
    8000283a:	6928                	ld	a0,80(a0)
    8000283c:	fffff097          	auipc	ra,0xfffff
    80002840:	0d6080e7          	jalr	214(ra) # 80001912 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002844:	70a2                	ld	ra,40(sp)
    80002846:	7402                	ld	s0,32(sp)
    80002848:	64e2                	ld	s1,24(sp)
    8000284a:	6942                	ld	s2,16(sp)
    8000284c:	69a2                	ld	s3,8(sp)
    8000284e:	6a02                	ld	s4,0(sp)
    80002850:	6145                	addi	sp,sp,48
    80002852:	8082                	ret
    memmove((char *)dst, src, len);
    80002854:	000a061b          	sext.w	a2,s4
    80002858:	85ce                	mv	a1,s3
    8000285a:	854a                	mv	a0,s2
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	510080e7          	jalr	1296(ra) # 80000d6c <memmove>
    return 0;
    80002864:	8526                	mv	a0,s1
    80002866:	bff9                	j	80002844 <either_copyout+0x32>

0000000080002868 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002868:	7179                	addi	sp,sp,-48
    8000286a:	f406                	sd	ra,40(sp)
    8000286c:	f022                	sd	s0,32(sp)
    8000286e:	ec26                	sd	s1,24(sp)
    80002870:	e84a                	sd	s2,16(sp)
    80002872:	e44e                	sd	s3,8(sp)
    80002874:	e052                	sd	s4,0(sp)
    80002876:	1800                	addi	s0,sp,48
    80002878:	892a                	mv	s2,a0
    8000287a:	84ae                	mv	s1,a1
    8000287c:	89b2                	mv	s3,a2
    8000287e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002880:	fffff097          	auipc	ra,0xfffff
    80002884:	350080e7          	jalr	848(ra) # 80001bd0 <myproc>
  if(user_src){
    80002888:	c08d                	beqz	s1,800028aa <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000288a:	86d2                	mv	a3,s4
    8000288c:	864e                	mv	a2,s3
    8000288e:	85ca                	mv	a1,s2
    80002890:	6928                	ld	a0,80(a0)
    80002892:	fffff097          	auipc	ra,0xfffff
    80002896:	10c080e7          	jalr	268(ra) # 8000199e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000289a:	70a2                	ld	ra,40(sp)
    8000289c:	7402                	ld	s0,32(sp)
    8000289e:	64e2                	ld	s1,24(sp)
    800028a0:	6942                	ld	s2,16(sp)
    800028a2:	69a2                	ld	s3,8(sp)
    800028a4:	6a02                	ld	s4,0(sp)
    800028a6:	6145                	addi	sp,sp,48
    800028a8:	8082                	ret
    memmove(dst, (char*)src, len);
    800028aa:	000a061b          	sext.w	a2,s4
    800028ae:	85ce                	mv	a1,s3
    800028b0:	854a                	mv	a0,s2
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	4ba080e7          	jalr	1210(ra) # 80000d6c <memmove>
    return 0;
    800028ba:	8526                	mv	a0,s1
    800028bc:	bff9                	j	8000289a <either_copyin+0x32>

00000000800028be <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800028be:	715d                	addi	sp,sp,-80
    800028c0:	e486                	sd	ra,72(sp)
    800028c2:	e0a2                	sd	s0,64(sp)
    800028c4:	fc26                	sd	s1,56(sp)
    800028c6:	f84a                	sd	s2,48(sp)
    800028c8:	f44e                	sd	s3,40(sp)
    800028ca:	f052                	sd	s4,32(sp)
    800028cc:	ec56                	sd	s5,24(sp)
    800028ce:	e85a                	sd	s6,16(sp)
    800028d0:	e45e                	sd	s7,8(sp)
    800028d2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800028d4:	00005517          	auipc	a0,0x5
    800028d8:	7e450513          	addi	a0,a0,2020 # 800080b8 <digits+0x88>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	cb6080e7          	jalr	-842(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028e4:	0000f497          	auipc	s1,0xf
    800028e8:	5dc48493          	addi	s1,s1,1500 # 80011ec0 <proc+0x158>
    800028ec:	00015917          	auipc	s2,0x15
    800028f0:	1d490913          	addi	s2,s2,468 # 80017ac0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028f4:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800028f6:	00006997          	auipc	s3,0x6
    800028fa:	a0298993          	addi	s3,s3,-1534 # 800082f8 <digits+0x2c8>
    printf("%d %s %s", p->pid, state, p->name);
    800028fe:	00006a97          	auipc	s5,0x6
    80002902:	a02a8a93          	addi	s5,s5,-1534 # 80008300 <digits+0x2d0>
    printf("\n");
    80002906:	00005a17          	auipc	s4,0x5
    8000290a:	7b2a0a13          	addi	s4,s4,1970 # 800080b8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000290e:	00006b97          	auipc	s7,0x6
    80002912:	a2ab8b93          	addi	s7,s7,-1494 # 80008338 <states.1772>
    80002916:	a00d                	j	80002938 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002918:	ee06a583          	lw	a1,-288(a3)
    8000291c:	8556                	mv	a0,s5
    8000291e:	ffffe097          	auipc	ra,0xffffe
    80002922:	c74080e7          	jalr	-908(ra) # 80000592 <printf>
    printf("\n");
    80002926:	8552                	mv	a0,s4
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	c6a080e7          	jalr	-918(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002930:	17048493          	addi	s1,s1,368
    80002934:	03248163          	beq	s1,s2,80002956 <procdump+0x98>
    if(p->state == UNUSED)
    80002938:	86a6                	mv	a3,s1
    8000293a:	ec04a783          	lw	a5,-320(s1)
    8000293e:	dbed                	beqz	a5,80002930 <procdump+0x72>
      state = "???";
    80002940:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002942:	fcfb6be3          	bltu	s6,a5,80002918 <procdump+0x5a>
    80002946:	1782                	slli	a5,a5,0x20
    80002948:	9381                	srli	a5,a5,0x20
    8000294a:	078e                	slli	a5,a5,0x3
    8000294c:	97de                	add	a5,a5,s7
    8000294e:	6390                	ld	a2,0(a5)
    80002950:	f661                	bnez	a2,80002918 <procdump+0x5a>
      state = "???";
    80002952:	864e                	mv	a2,s3
    80002954:	b7d1                	j	80002918 <procdump+0x5a>
  }
}
    80002956:	60a6                	ld	ra,72(sp)
    80002958:	6406                	ld	s0,64(sp)
    8000295a:	74e2                	ld	s1,56(sp)
    8000295c:	7942                	ld	s2,48(sp)
    8000295e:	79a2                	ld	s3,40(sp)
    80002960:	7a02                	ld	s4,32(sp)
    80002962:	6ae2                	ld	s5,24(sp)
    80002964:	6b42                	ld	s6,16(sp)
    80002966:	6ba2                	ld	s7,8(sp)
    80002968:	6161                	addi	sp,sp,80
    8000296a:	8082                	ret

000000008000296c <swtch>:
    8000296c:	00153023          	sd	ra,0(a0)
    80002970:	00253423          	sd	sp,8(a0)
    80002974:	e900                	sd	s0,16(a0)
    80002976:	ed04                	sd	s1,24(a0)
    80002978:	03253023          	sd	s2,32(a0)
    8000297c:	03353423          	sd	s3,40(a0)
    80002980:	03453823          	sd	s4,48(a0)
    80002984:	03553c23          	sd	s5,56(a0)
    80002988:	05653023          	sd	s6,64(a0)
    8000298c:	05753423          	sd	s7,72(a0)
    80002990:	05853823          	sd	s8,80(a0)
    80002994:	05953c23          	sd	s9,88(a0)
    80002998:	07a53023          	sd	s10,96(a0)
    8000299c:	07b53423          	sd	s11,104(a0)
    800029a0:	0005b083          	ld	ra,0(a1)
    800029a4:	0085b103          	ld	sp,8(a1)
    800029a8:	6980                	ld	s0,16(a1)
    800029aa:	6d84                	ld	s1,24(a1)
    800029ac:	0205b903          	ld	s2,32(a1)
    800029b0:	0285b983          	ld	s3,40(a1)
    800029b4:	0305ba03          	ld	s4,48(a1)
    800029b8:	0385ba83          	ld	s5,56(a1)
    800029bc:	0405bb03          	ld	s6,64(a1)
    800029c0:	0485bb83          	ld	s7,72(a1)
    800029c4:	0505bc03          	ld	s8,80(a1)
    800029c8:	0585bc83          	ld	s9,88(a1)
    800029cc:	0605bd03          	ld	s10,96(a1)
    800029d0:	0685bd83          	ld	s11,104(a1)
    800029d4:	8082                	ret

00000000800029d6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800029d6:	1141                	addi	sp,sp,-16
    800029d8:	e406                	sd	ra,8(sp)
    800029da:	e022                	sd	s0,0(sp)
    800029dc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029de:	00006597          	auipc	a1,0x6
    800029e2:	98258593          	addi	a1,a1,-1662 # 80008360 <states.1772+0x28>
    800029e6:	00015517          	auipc	a0,0x15
    800029ea:	f8250513          	addi	a0,a0,-126 # 80017968 <tickslock>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	192080e7          	jalr	402(ra) # 80000b80 <initlock>
}
    800029f6:	60a2                	ld	ra,8(sp)
    800029f8:	6402                	ld	s0,0(sp)
    800029fa:	0141                	addi	sp,sp,16
    800029fc:	8082                	ret

00000000800029fe <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029fe:	1141                	addi	sp,sp,-16
    80002a00:	e422                	sd	s0,8(sp)
    80002a02:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a04:	00003797          	auipc	a5,0x3
    80002a08:	51c78793          	addi	a5,a5,1308 # 80005f20 <kernelvec>
    80002a0c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a10:	6422                	ld	s0,8(sp)
    80002a12:	0141                	addi	sp,sp,16
    80002a14:	8082                	ret

0000000080002a16 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a16:	1141                	addi	sp,sp,-16
    80002a18:	e406                	sd	ra,8(sp)
    80002a1a:	e022                	sd	s0,0(sp)
    80002a1c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a1e:	fffff097          	auipc	ra,0xfffff
    80002a22:	1b2080e7          	jalr	434(ra) # 80001bd0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a26:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a2a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a2c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002a30:	00004617          	auipc	a2,0x4
    80002a34:	5d060613          	addi	a2,a2,1488 # 80007000 <_trampoline>
    80002a38:	00004697          	auipc	a3,0x4
    80002a3c:	5c868693          	addi	a3,a3,1480 # 80007000 <_trampoline>
    80002a40:	8e91                	sub	a3,a3,a2
    80002a42:	040007b7          	lui	a5,0x4000
    80002a46:	17fd                	addi	a5,a5,-1
    80002a48:	07b2                	slli	a5,a5,0xc
    80002a4a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a4c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a50:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a52:	180026f3          	csrr	a3,satp
    80002a56:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a58:	6d38                	ld	a4,88(a0)
    80002a5a:	6134                	ld	a3,64(a0)
    80002a5c:	6585                	lui	a1,0x1
    80002a5e:	96ae                	add	a3,a3,a1
    80002a60:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a62:	6d38                	ld	a4,88(a0)
    80002a64:	00000697          	auipc	a3,0x0
    80002a68:	13868693          	addi	a3,a3,312 # 80002b9c <usertrap>
    80002a6c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a6e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a70:	8692                	mv	a3,tp
    80002a72:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a74:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a78:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a7c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a80:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a84:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a86:	6f18                	ld	a4,24(a4)
    80002a88:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a8c:	692c                	ld	a1,80(a0)
    80002a8e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a90:	00004717          	auipc	a4,0x4
    80002a94:	60070713          	addi	a4,a4,1536 # 80007090 <userret>
    80002a98:	8f11                	sub	a4,a4,a2
    80002a9a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002a9c:	577d                	li	a4,-1
    80002a9e:	177e                	slli	a4,a4,0x3f
    80002aa0:	8dd9                	or	a1,a1,a4
    80002aa2:	02000537          	lui	a0,0x2000
    80002aa6:	157d                	addi	a0,a0,-1
    80002aa8:	0536                	slli	a0,a0,0xd
    80002aaa:	9782                	jalr	a5
}
    80002aac:	60a2                	ld	ra,8(sp)
    80002aae:	6402                	ld	s0,0(sp)
    80002ab0:	0141                	addi	sp,sp,16
    80002ab2:	8082                	ret

0000000080002ab4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002ab4:	1101                	addi	sp,sp,-32
    80002ab6:	ec06                	sd	ra,24(sp)
    80002ab8:	e822                	sd	s0,16(sp)
    80002aba:	e426                	sd	s1,8(sp)
    80002abc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002abe:	00015497          	auipc	s1,0x15
    80002ac2:	eaa48493          	addi	s1,s1,-342 # 80017968 <tickslock>
    80002ac6:	8526                	mv	a0,s1
    80002ac8:	ffffe097          	auipc	ra,0xffffe
    80002acc:	148080e7          	jalr	328(ra) # 80000c10 <acquire>
  ticks++;
    80002ad0:	00006517          	auipc	a0,0x6
    80002ad4:	55050513          	addi	a0,a0,1360 # 80009020 <ticks>
    80002ad8:	411c                	lw	a5,0(a0)
    80002ada:	2785                	addiw	a5,a5,1
    80002adc:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ade:	00000097          	auipc	ra,0x0
    80002ae2:	c58080e7          	jalr	-936(ra) # 80002736 <wakeup>
  release(&tickslock);
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	1dc080e7          	jalr	476(ra) # 80000cc4 <release>
}
    80002af0:	60e2                	ld	ra,24(sp)
    80002af2:	6442                	ld	s0,16(sp)
    80002af4:	64a2                	ld	s1,8(sp)
    80002af6:	6105                	addi	sp,sp,32
    80002af8:	8082                	ret

0000000080002afa <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002afa:	1101                	addi	sp,sp,-32
    80002afc:	ec06                	sd	ra,24(sp)
    80002afe:	e822                	sd	s0,16(sp)
    80002b00:	e426                	sd	s1,8(sp)
    80002b02:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b04:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b08:	00074d63          	bltz	a4,80002b22 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b0c:	57fd                	li	a5,-1
    80002b0e:	17fe                	slli	a5,a5,0x3f
    80002b10:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b12:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b14:	06f70363          	beq	a4,a5,80002b7a <devintr+0x80>
  }
}
    80002b18:	60e2                	ld	ra,24(sp)
    80002b1a:	6442                	ld	s0,16(sp)
    80002b1c:	64a2                	ld	s1,8(sp)
    80002b1e:	6105                	addi	sp,sp,32
    80002b20:	8082                	ret
     (scause & 0xff) == 9){
    80002b22:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b26:	46a5                	li	a3,9
    80002b28:	fed792e3          	bne	a5,a3,80002b0c <devintr+0x12>
    int irq = plic_claim();
    80002b2c:	00003097          	auipc	ra,0x3
    80002b30:	4fc080e7          	jalr	1276(ra) # 80006028 <plic_claim>
    80002b34:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b36:	47a9                	li	a5,10
    80002b38:	02f50763          	beq	a0,a5,80002b66 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b3c:	4785                	li	a5,1
    80002b3e:	02f50963          	beq	a0,a5,80002b70 <devintr+0x76>
    return 1;
    80002b42:	4505                	li	a0,1
    } else if(irq){
    80002b44:	d8f1                	beqz	s1,80002b18 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b46:	85a6                	mv	a1,s1
    80002b48:	00006517          	auipc	a0,0x6
    80002b4c:	82050513          	addi	a0,a0,-2016 # 80008368 <states.1772+0x30>
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	a42080e7          	jalr	-1470(ra) # 80000592 <printf>
      plic_complete(irq);
    80002b58:	8526                	mv	a0,s1
    80002b5a:	00003097          	auipc	ra,0x3
    80002b5e:	4f2080e7          	jalr	1266(ra) # 8000604c <plic_complete>
    return 1;
    80002b62:	4505                	li	a0,1
    80002b64:	bf55                	j	80002b18 <devintr+0x1e>
      uartintr();
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	e6e080e7          	jalr	-402(ra) # 800009d4 <uartintr>
    80002b6e:	b7ed                	j	80002b58 <devintr+0x5e>
      virtio_disk_intr();
    80002b70:	00004097          	auipc	ra,0x4
    80002b74:	982080e7          	jalr	-1662(ra) # 800064f2 <virtio_disk_intr>
    80002b78:	b7c5                	j	80002b58 <devintr+0x5e>
    if(cpuid() == 0){
    80002b7a:	fffff097          	auipc	ra,0xfffff
    80002b7e:	02a080e7          	jalr	42(ra) # 80001ba4 <cpuid>
    80002b82:	c901                	beqz	a0,80002b92 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b84:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b8a:	14479073          	csrw	sip,a5
    return 2;
    80002b8e:	4509                	li	a0,2
    80002b90:	b761                	j	80002b18 <devintr+0x1e>
      clockintr();
    80002b92:	00000097          	auipc	ra,0x0
    80002b96:	f22080e7          	jalr	-222(ra) # 80002ab4 <clockintr>
    80002b9a:	b7ed                	j	80002b84 <devintr+0x8a>

0000000080002b9c <usertrap>:
{
    80002b9c:	1101                	addi	sp,sp,-32
    80002b9e:	ec06                	sd	ra,24(sp)
    80002ba0:	e822                	sd	s0,16(sp)
    80002ba2:	e426                	sd	s1,8(sp)
    80002ba4:	e04a                	sd	s2,0(sp)
    80002ba6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bac:	1007f793          	andi	a5,a5,256
    80002bb0:	e3ad                	bnez	a5,80002c12 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bb2:	00003797          	auipc	a5,0x3
    80002bb6:	36e78793          	addi	a5,a5,878 # 80005f20 <kernelvec>
    80002bba:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	012080e7          	jalr	18(ra) # 80001bd0 <myproc>
    80002bc6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bc8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bca:	14102773          	csrr	a4,sepc
    80002bce:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bd4:	47a1                	li	a5,8
    80002bd6:	04f71c63          	bne	a4,a5,80002c2e <usertrap+0x92>
    if(p->killed)
    80002bda:	591c                	lw	a5,48(a0)
    80002bdc:	e3b9                	bnez	a5,80002c22 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002bde:	6cb8                	ld	a4,88(s1)
    80002be0:	6f1c                	ld	a5,24(a4)
    80002be2:	0791                	addi	a5,a5,4
    80002be4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002be6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bee:	10079073          	csrw	sstatus,a5
    syscall();
    80002bf2:	00000097          	auipc	ra,0x0
    80002bf6:	2e0080e7          	jalr	736(ra) # 80002ed2 <syscall>
  if(p->killed)
    80002bfa:	589c                	lw	a5,48(s1)
    80002bfc:	ebc1                	bnez	a5,80002c8c <usertrap+0xf0>
  usertrapret();
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	e18080e7          	jalr	-488(ra) # 80002a16 <usertrapret>
}
    80002c06:	60e2                	ld	ra,24(sp)
    80002c08:	6442                	ld	s0,16(sp)
    80002c0a:	64a2                	ld	s1,8(sp)
    80002c0c:	6902                	ld	s2,0(sp)
    80002c0e:	6105                	addi	sp,sp,32
    80002c10:	8082                	ret
    panic("usertrap: not from user mode");
    80002c12:	00005517          	auipc	a0,0x5
    80002c16:	77650513          	addi	a0,a0,1910 # 80008388 <states.1772+0x50>
    80002c1a:	ffffe097          	auipc	ra,0xffffe
    80002c1e:	92e080e7          	jalr	-1746(ra) # 80000548 <panic>
      exit(-1);
    80002c22:	557d                	li	a0,-1
    80002c24:	00000097          	auipc	ra,0x0
    80002c28:	846080e7          	jalr	-1978(ra) # 8000246a <exit>
    80002c2c:	bf4d                	j	80002bde <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002c2e:	00000097          	auipc	ra,0x0
    80002c32:	ecc080e7          	jalr	-308(ra) # 80002afa <devintr>
    80002c36:	892a                	mv	s2,a0
    80002c38:	c501                	beqz	a0,80002c40 <usertrap+0xa4>
  if(p->killed)
    80002c3a:	589c                	lw	a5,48(s1)
    80002c3c:	c3a1                	beqz	a5,80002c7c <usertrap+0xe0>
    80002c3e:	a815                	j	80002c72 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c40:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c44:	5c90                	lw	a2,56(s1)
    80002c46:	00005517          	auipc	a0,0x5
    80002c4a:	76250513          	addi	a0,a0,1890 # 800083a8 <states.1772+0x70>
    80002c4e:	ffffe097          	auipc	ra,0xffffe
    80002c52:	944080e7          	jalr	-1724(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c56:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c5a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c5e:	00005517          	auipc	a0,0x5
    80002c62:	77a50513          	addi	a0,a0,1914 # 800083d8 <states.1772+0xa0>
    80002c66:	ffffe097          	auipc	ra,0xffffe
    80002c6a:	92c080e7          	jalr	-1748(ra) # 80000592 <printf>
    p->killed = 1;
    80002c6e:	4785                	li	a5,1
    80002c70:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002c72:	557d                	li	a0,-1
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	7f6080e7          	jalr	2038(ra) # 8000246a <exit>
  if(which_dev == 2)
    80002c7c:	4789                	li	a5,2
    80002c7e:	f8f910e3          	bne	s2,a5,80002bfe <usertrap+0x62>
    yield();
    80002c82:	00000097          	auipc	ra,0x0
    80002c86:	8f2080e7          	jalr	-1806(ra) # 80002574 <yield>
    80002c8a:	bf95                	j	80002bfe <usertrap+0x62>
  int which_dev = 0;
    80002c8c:	4901                	li	s2,0
    80002c8e:	b7d5                	j	80002c72 <usertrap+0xd6>

0000000080002c90 <kerneltrap>:
{
    80002c90:	7179                	addi	sp,sp,-48
    80002c92:	f406                	sd	ra,40(sp)
    80002c94:	f022                	sd	s0,32(sp)
    80002c96:	ec26                	sd	s1,24(sp)
    80002c98:	e84a                	sd	s2,16(sp)
    80002c9a:	e44e                	sd	s3,8(sp)
    80002c9c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c9e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ca2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002caa:	1004f793          	andi	a5,s1,256
    80002cae:	cb85                	beqz	a5,80002cde <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cb0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cb4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cb6:	ef85                	bnez	a5,80002cee <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cb8:	00000097          	auipc	ra,0x0
    80002cbc:	e42080e7          	jalr	-446(ra) # 80002afa <devintr>
    80002cc0:	cd1d                	beqz	a0,80002cfe <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cc2:	4789                	li	a5,2
    80002cc4:	06f50a63          	beq	a0,a5,80002d38 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cc8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ccc:	10049073          	csrw	sstatus,s1
}
    80002cd0:	70a2                	ld	ra,40(sp)
    80002cd2:	7402                	ld	s0,32(sp)
    80002cd4:	64e2                	ld	s1,24(sp)
    80002cd6:	6942                	ld	s2,16(sp)
    80002cd8:	69a2                	ld	s3,8(sp)
    80002cda:	6145                	addi	sp,sp,48
    80002cdc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cde:	00005517          	auipc	a0,0x5
    80002ce2:	71a50513          	addi	a0,a0,1818 # 800083f8 <states.1772+0xc0>
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	862080e7          	jalr	-1950(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002cee:	00005517          	auipc	a0,0x5
    80002cf2:	73250513          	addi	a0,a0,1842 # 80008420 <states.1772+0xe8>
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	852080e7          	jalr	-1966(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002cfe:	85ce                	mv	a1,s3
    80002d00:	00005517          	auipc	a0,0x5
    80002d04:	74050513          	addi	a0,a0,1856 # 80008440 <states.1772+0x108>
    80002d08:	ffffe097          	auipc	ra,0xffffe
    80002d0c:	88a080e7          	jalr	-1910(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d10:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d14:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d18:	00005517          	auipc	a0,0x5
    80002d1c:	73850513          	addi	a0,a0,1848 # 80008450 <states.1772+0x118>
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	872080e7          	jalr	-1934(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002d28:	00005517          	auipc	a0,0x5
    80002d2c:	74050513          	addi	a0,a0,1856 # 80008468 <states.1772+0x130>
    80002d30:	ffffe097          	auipc	ra,0xffffe
    80002d34:	818080e7          	jalr	-2024(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d38:	fffff097          	auipc	ra,0xfffff
    80002d3c:	e98080e7          	jalr	-360(ra) # 80001bd0 <myproc>
    80002d40:	d541                	beqz	a0,80002cc8 <kerneltrap+0x38>
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	e8e080e7          	jalr	-370(ra) # 80001bd0 <myproc>
    80002d4a:	4d18                	lw	a4,24(a0)
    80002d4c:	478d                	li	a5,3
    80002d4e:	f6f71de3          	bne	a4,a5,80002cc8 <kerneltrap+0x38>
    yield();
    80002d52:	00000097          	auipc	ra,0x0
    80002d56:	822080e7          	jalr	-2014(ra) # 80002574 <yield>
    80002d5a:	b7bd                	j	80002cc8 <kerneltrap+0x38>

0000000080002d5c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	e426                	sd	s1,8(sp)
    80002d64:	1000                	addi	s0,sp,32
    80002d66:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d68:	fffff097          	auipc	ra,0xfffff
    80002d6c:	e68080e7          	jalr	-408(ra) # 80001bd0 <myproc>
  switch (n) {
    80002d70:	4795                	li	a5,5
    80002d72:	0497e163          	bltu	a5,s1,80002db4 <argraw+0x58>
    80002d76:	048a                	slli	s1,s1,0x2
    80002d78:	00005717          	auipc	a4,0x5
    80002d7c:	72870713          	addi	a4,a4,1832 # 800084a0 <states.1772+0x168>
    80002d80:	94ba                	add	s1,s1,a4
    80002d82:	409c                	lw	a5,0(s1)
    80002d84:	97ba                	add	a5,a5,a4
    80002d86:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d88:	6d3c                	ld	a5,88(a0)
    80002d8a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d8c:	60e2                	ld	ra,24(sp)
    80002d8e:	6442                	ld	s0,16(sp)
    80002d90:	64a2                	ld	s1,8(sp)
    80002d92:	6105                	addi	sp,sp,32
    80002d94:	8082                	ret
    return p->trapframe->a1;
    80002d96:	6d3c                	ld	a5,88(a0)
    80002d98:	7fa8                	ld	a0,120(a5)
    80002d9a:	bfcd                	j	80002d8c <argraw+0x30>
    return p->trapframe->a2;
    80002d9c:	6d3c                	ld	a5,88(a0)
    80002d9e:	63c8                	ld	a0,128(a5)
    80002da0:	b7f5                	j	80002d8c <argraw+0x30>
    return p->trapframe->a3;
    80002da2:	6d3c                	ld	a5,88(a0)
    80002da4:	67c8                	ld	a0,136(a5)
    80002da6:	b7dd                	j	80002d8c <argraw+0x30>
    return p->trapframe->a4;
    80002da8:	6d3c                	ld	a5,88(a0)
    80002daa:	6bc8                	ld	a0,144(a5)
    80002dac:	b7c5                	j	80002d8c <argraw+0x30>
    return p->trapframe->a5;
    80002dae:	6d3c                	ld	a5,88(a0)
    80002db0:	6fc8                	ld	a0,152(a5)
    80002db2:	bfe9                	j	80002d8c <argraw+0x30>
  panic("argraw");
    80002db4:	00005517          	auipc	a0,0x5
    80002db8:	6c450513          	addi	a0,a0,1732 # 80008478 <states.1772+0x140>
    80002dbc:	ffffd097          	auipc	ra,0xffffd
    80002dc0:	78c080e7          	jalr	1932(ra) # 80000548 <panic>

0000000080002dc4 <fetchaddr>:
{
    80002dc4:	1101                	addi	sp,sp,-32
    80002dc6:	ec06                	sd	ra,24(sp)
    80002dc8:	e822                	sd	s0,16(sp)
    80002dca:	e426                	sd	s1,8(sp)
    80002dcc:	e04a                	sd	s2,0(sp)
    80002dce:	1000                	addi	s0,sp,32
    80002dd0:	84aa                	mv	s1,a0
    80002dd2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	dfc080e7          	jalr	-516(ra) # 80001bd0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002ddc:	653c                	ld	a5,72(a0)
    80002dde:	02f4f863          	bgeu	s1,a5,80002e0e <fetchaddr+0x4a>
    80002de2:	00848713          	addi	a4,s1,8
    80002de6:	02e7e663          	bltu	a5,a4,80002e12 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002dea:	46a1                	li	a3,8
    80002dec:	8626                	mv	a2,s1
    80002dee:	85ca                	mv	a1,s2
    80002df0:	6928                	ld	a0,80(a0)
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	bac080e7          	jalr	-1108(ra) # 8000199e <copyin>
    80002dfa:	00a03533          	snez	a0,a0
    80002dfe:	40a00533          	neg	a0,a0
}
    80002e02:	60e2                	ld	ra,24(sp)
    80002e04:	6442                	ld	s0,16(sp)
    80002e06:	64a2                	ld	s1,8(sp)
    80002e08:	6902                	ld	s2,0(sp)
    80002e0a:	6105                	addi	sp,sp,32
    80002e0c:	8082                	ret
    return -1;
    80002e0e:	557d                	li	a0,-1
    80002e10:	bfcd                	j	80002e02 <fetchaddr+0x3e>
    80002e12:	557d                	li	a0,-1
    80002e14:	b7fd                	j	80002e02 <fetchaddr+0x3e>

0000000080002e16 <fetchstr>:
{
    80002e16:	7179                	addi	sp,sp,-48
    80002e18:	f406                	sd	ra,40(sp)
    80002e1a:	f022                	sd	s0,32(sp)
    80002e1c:	ec26                	sd	s1,24(sp)
    80002e1e:	e84a                	sd	s2,16(sp)
    80002e20:	e44e                	sd	s3,8(sp)
    80002e22:	1800                	addi	s0,sp,48
    80002e24:	892a                	mv	s2,a0
    80002e26:	84ae                	mv	s1,a1
    80002e28:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e2a:	fffff097          	auipc	ra,0xfffff
    80002e2e:	da6080e7          	jalr	-602(ra) # 80001bd0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002e32:	86ce                	mv	a3,s3
    80002e34:	864a                	mv	a2,s2
    80002e36:	85a6                	mv	a1,s1
    80002e38:	6928                	ld	a0,80(a0)
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	b7c080e7          	jalr	-1156(ra) # 800019b6 <copyinstr>
  if(err < 0)
    80002e42:	00054763          	bltz	a0,80002e50 <fetchstr+0x3a>
  return strlen(buf);
    80002e46:	8526                	mv	a0,s1
    80002e48:	ffffe097          	auipc	ra,0xffffe
    80002e4c:	04c080e7          	jalr	76(ra) # 80000e94 <strlen>
}
    80002e50:	70a2                	ld	ra,40(sp)
    80002e52:	7402                	ld	s0,32(sp)
    80002e54:	64e2                	ld	s1,24(sp)
    80002e56:	6942                	ld	s2,16(sp)
    80002e58:	69a2                	ld	s3,8(sp)
    80002e5a:	6145                	addi	sp,sp,48
    80002e5c:	8082                	ret

0000000080002e5e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e5e:	1101                	addi	sp,sp,-32
    80002e60:	ec06                	sd	ra,24(sp)
    80002e62:	e822                	sd	s0,16(sp)
    80002e64:	e426                	sd	s1,8(sp)
    80002e66:	1000                	addi	s0,sp,32
    80002e68:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e6a:	00000097          	auipc	ra,0x0
    80002e6e:	ef2080e7          	jalr	-270(ra) # 80002d5c <argraw>
    80002e72:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e74:	4501                	li	a0,0
    80002e76:	60e2                	ld	ra,24(sp)
    80002e78:	6442                	ld	s0,16(sp)
    80002e7a:	64a2                	ld	s1,8(sp)
    80002e7c:	6105                	addi	sp,sp,32
    80002e7e:	8082                	ret

0000000080002e80 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e80:	1101                	addi	sp,sp,-32
    80002e82:	ec06                	sd	ra,24(sp)
    80002e84:	e822                	sd	s0,16(sp)
    80002e86:	e426                	sd	s1,8(sp)
    80002e88:	1000                	addi	s0,sp,32
    80002e8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e8c:	00000097          	auipc	ra,0x0
    80002e90:	ed0080e7          	jalr	-304(ra) # 80002d5c <argraw>
    80002e94:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e96:	4501                	li	a0,0
    80002e98:	60e2                	ld	ra,24(sp)
    80002e9a:	6442                	ld	s0,16(sp)
    80002e9c:	64a2                	ld	s1,8(sp)
    80002e9e:	6105                	addi	sp,sp,32
    80002ea0:	8082                	ret

0000000080002ea2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ea2:	1101                	addi	sp,sp,-32
    80002ea4:	ec06                	sd	ra,24(sp)
    80002ea6:	e822                	sd	s0,16(sp)
    80002ea8:	e426                	sd	s1,8(sp)
    80002eaa:	e04a                	sd	s2,0(sp)
    80002eac:	1000                	addi	s0,sp,32
    80002eae:	84ae                	mv	s1,a1
    80002eb0:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002eb2:	00000097          	auipc	ra,0x0
    80002eb6:	eaa080e7          	jalr	-342(ra) # 80002d5c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002eba:	864a                	mv	a2,s2
    80002ebc:	85a6                	mv	a1,s1
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	f58080e7          	jalr	-168(ra) # 80002e16 <fetchstr>
}
    80002ec6:	60e2                	ld	ra,24(sp)
    80002ec8:	6442                	ld	s0,16(sp)
    80002eca:	64a2                	ld	s1,8(sp)
    80002ecc:	6902                	ld	s2,0(sp)
    80002ece:	6105                	addi	sp,sp,32
    80002ed0:	8082                	ret

0000000080002ed2 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002ed2:	1101                	addi	sp,sp,-32
    80002ed4:	ec06                	sd	ra,24(sp)
    80002ed6:	e822                	sd	s0,16(sp)
    80002ed8:	e426                	sd	s1,8(sp)
    80002eda:	e04a                	sd	s2,0(sp)
    80002edc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ede:	fffff097          	auipc	ra,0xfffff
    80002ee2:	cf2080e7          	jalr	-782(ra) # 80001bd0 <myproc>
    80002ee6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ee8:	05853903          	ld	s2,88(a0)
    80002eec:	0a893783          	ld	a5,168(s2)
    80002ef0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ef4:	37fd                	addiw	a5,a5,-1
    80002ef6:	4751                	li	a4,20
    80002ef8:	00f76f63          	bltu	a4,a5,80002f16 <syscall+0x44>
    80002efc:	00369713          	slli	a4,a3,0x3
    80002f00:	00005797          	auipc	a5,0x5
    80002f04:	5b878793          	addi	a5,a5,1464 # 800084b8 <syscalls>
    80002f08:	97ba                	add	a5,a5,a4
    80002f0a:	639c                	ld	a5,0(a5)
    80002f0c:	c789                	beqz	a5,80002f16 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002f0e:	9782                	jalr	a5
    80002f10:	06a93823          	sd	a0,112(s2)
    80002f14:	a839                	j	80002f32 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f16:	15848613          	addi	a2,s1,344
    80002f1a:	5c8c                	lw	a1,56(s1)
    80002f1c:	00005517          	auipc	a0,0x5
    80002f20:	56450513          	addi	a0,a0,1380 # 80008480 <states.1772+0x148>
    80002f24:	ffffd097          	auipc	ra,0xffffd
    80002f28:	66e080e7          	jalr	1646(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f2c:	6cbc                	ld	a5,88(s1)
    80002f2e:	577d                	li	a4,-1
    80002f30:	fbb8                	sd	a4,112(a5)
  }
}
    80002f32:	60e2                	ld	ra,24(sp)
    80002f34:	6442                	ld	s0,16(sp)
    80002f36:	64a2                	ld	s1,8(sp)
    80002f38:	6902                	ld	s2,0(sp)
    80002f3a:	6105                	addi	sp,sp,32
    80002f3c:	8082                	ret

0000000080002f3e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f3e:	1101                	addi	sp,sp,-32
    80002f40:	ec06                	sd	ra,24(sp)
    80002f42:	e822                	sd	s0,16(sp)
    80002f44:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f46:	fec40593          	addi	a1,s0,-20
    80002f4a:	4501                	li	a0,0
    80002f4c:	00000097          	auipc	ra,0x0
    80002f50:	f12080e7          	jalr	-238(ra) # 80002e5e <argint>
    return -1;
    80002f54:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f56:	00054963          	bltz	a0,80002f68 <sys_exit+0x2a>
  exit(n);
    80002f5a:	fec42503          	lw	a0,-20(s0)
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	50c080e7          	jalr	1292(ra) # 8000246a <exit>
  return 0;  // not reached
    80002f66:	4781                	li	a5,0
}
    80002f68:	853e                	mv	a0,a5
    80002f6a:	60e2                	ld	ra,24(sp)
    80002f6c:	6442                	ld	s0,16(sp)
    80002f6e:	6105                	addi	sp,sp,32
    80002f70:	8082                	ret

0000000080002f72 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f72:	1141                	addi	sp,sp,-16
    80002f74:	e406                	sd	ra,8(sp)
    80002f76:	e022                	sd	s0,0(sp)
    80002f78:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	c56080e7          	jalr	-938(ra) # 80001bd0 <myproc>
}
    80002f82:	5d08                	lw	a0,56(a0)
    80002f84:	60a2                	ld	ra,8(sp)
    80002f86:	6402                	ld	s0,0(sp)
    80002f88:	0141                	addi	sp,sp,16
    80002f8a:	8082                	ret

0000000080002f8c <sys_fork>:

uint64
sys_fork(void)
{
    80002f8c:	1141                	addi	sp,sp,-16
    80002f8e:	e406                	sd	ra,8(sp)
    80002f90:	e022                	sd	s0,0(sp)
    80002f92:	0800                	addi	s0,sp,16
  return fork();
    80002f94:	fffff097          	auipc	ra,0xfffff
    80002f98:	194080e7          	jalr	404(ra) # 80002128 <fork>
}
    80002f9c:	60a2                	ld	ra,8(sp)
    80002f9e:	6402                	ld	s0,0(sp)
    80002fa0:	0141                	addi	sp,sp,16
    80002fa2:	8082                	ret

0000000080002fa4 <sys_wait>:

uint64
sys_wait(void)
{
    80002fa4:	1101                	addi	sp,sp,-32
    80002fa6:	ec06                	sd	ra,24(sp)
    80002fa8:	e822                	sd	s0,16(sp)
    80002faa:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002fac:	fe840593          	addi	a1,s0,-24
    80002fb0:	4501                	li	a0,0
    80002fb2:	00000097          	auipc	ra,0x0
    80002fb6:	ece080e7          	jalr	-306(ra) # 80002e80 <argaddr>
    80002fba:	87aa                	mv	a5,a0
    return -1;
    80002fbc:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002fbe:	0007c863          	bltz	a5,80002fce <sys_wait+0x2a>
  return wait(p);
    80002fc2:	fe843503          	ld	a0,-24(s0)
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	668080e7          	jalr	1640(ra) # 8000262e <wait>
}
    80002fce:	60e2                	ld	ra,24(sp)
    80002fd0:	6442                	ld	s0,16(sp)
    80002fd2:	6105                	addi	sp,sp,32
    80002fd4:	8082                	ret

0000000080002fd6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fd6:	7179                	addi	sp,sp,-48
    80002fd8:	f406                	sd	ra,40(sp)
    80002fda:	f022                	sd	s0,32(sp)
    80002fdc:	ec26                	sd	s1,24(sp)
    80002fde:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002fe0:	fdc40593          	addi	a1,s0,-36
    80002fe4:	4501                	li	a0,0
    80002fe6:	00000097          	auipc	ra,0x0
    80002fea:	e78080e7          	jalr	-392(ra) # 80002e5e <argint>
    80002fee:	87aa                	mv	a5,a0
    return -1;
    80002ff0:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002ff2:	0207c063          	bltz	a5,80003012 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002ff6:	fffff097          	auipc	ra,0xfffff
    80002ffa:	bda080e7          	jalr	-1062(ra) # 80001bd0 <myproc>
    80002ffe:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003000:	fdc42503          	lw	a0,-36(s0)
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	052080e7          	jalr	82(ra) # 80002056 <growproc>
    8000300c:	00054863          	bltz	a0,8000301c <sys_sbrk+0x46>
    return -1;
  return addr;
    80003010:	8526                	mv	a0,s1
}
    80003012:	70a2                	ld	ra,40(sp)
    80003014:	7402                	ld	s0,32(sp)
    80003016:	64e2                	ld	s1,24(sp)
    80003018:	6145                	addi	sp,sp,48
    8000301a:	8082                	ret
    return -1;
    8000301c:	557d                	li	a0,-1
    8000301e:	bfd5                	j	80003012 <sys_sbrk+0x3c>

0000000080003020 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003020:	7139                	addi	sp,sp,-64
    80003022:	fc06                	sd	ra,56(sp)
    80003024:	f822                	sd	s0,48(sp)
    80003026:	f426                	sd	s1,40(sp)
    80003028:	f04a                	sd	s2,32(sp)
    8000302a:	ec4e                	sd	s3,24(sp)
    8000302c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000302e:	fcc40593          	addi	a1,s0,-52
    80003032:	4501                	li	a0,0
    80003034:	00000097          	auipc	ra,0x0
    80003038:	e2a080e7          	jalr	-470(ra) # 80002e5e <argint>
    return -1;
    8000303c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000303e:	06054563          	bltz	a0,800030a8 <sys_sleep+0x88>
  acquire(&tickslock);
    80003042:	00015517          	auipc	a0,0x15
    80003046:	92650513          	addi	a0,a0,-1754 # 80017968 <tickslock>
    8000304a:	ffffe097          	auipc	ra,0xffffe
    8000304e:	bc6080e7          	jalr	-1082(ra) # 80000c10 <acquire>
  ticks0 = ticks;
    80003052:	00006917          	auipc	s2,0x6
    80003056:	fce92903          	lw	s2,-50(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    8000305a:	fcc42783          	lw	a5,-52(s0)
    8000305e:	cf85                	beqz	a5,80003096 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003060:	00015997          	auipc	s3,0x15
    80003064:	90898993          	addi	s3,s3,-1784 # 80017968 <tickslock>
    80003068:	00006497          	auipc	s1,0x6
    8000306c:	fb848493          	addi	s1,s1,-72 # 80009020 <ticks>
    if(myproc()->killed){
    80003070:	fffff097          	auipc	ra,0xfffff
    80003074:	b60080e7          	jalr	-1184(ra) # 80001bd0 <myproc>
    80003078:	591c                	lw	a5,48(a0)
    8000307a:	ef9d                	bnez	a5,800030b8 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000307c:	85ce                	mv	a1,s3
    8000307e:	8526                	mv	a0,s1
    80003080:	fffff097          	auipc	ra,0xfffff
    80003084:	530080e7          	jalr	1328(ra) # 800025b0 <sleep>
  while(ticks - ticks0 < n){
    80003088:	409c                	lw	a5,0(s1)
    8000308a:	412787bb          	subw	a5,a5,s2
    8000308e:	fcc42703          	lw	a4,-52(s0)
    80003092:	fce7efe3          	bltu	a5,a4,80003070 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003096:	00015517          	auipc	a0,0x15
    8000309a:	8d250513          	addi	a0,a0,-1838 # 80017968 <tickslock>
    8000309e:	ffffe097          	auipc	ra,0xffffe
    800030a2:	c26080e7          	jalr	-986(ra) # 80000cc4 <release>
  return 0;
    800030a6:	4781                	li	a5,0
}
    800030a8:	853e                	mv	a0,a5
    800030aa:	70e2                	ld	ra,56(sp)
    800030ac:	7442                	ld	s0,48(sp)
    800030ae:	74a2                	ld	s1,40(sp)
    800030b0:	7902                	ld	s2,32(sp)
    800030b2:	69e2                	ld	s3,24(sp)
    800030b4:	6121                	addi	sp,sp,64
    800030b6:	8082                	ret
      release(&tickslock);
    800030b8:	00015517          	auipc	a0,0x15
    800030bc:	8b050513          	addi	a0,a0,-1872 # 80017968 <tickslock>
    800030c0:	ffffe097          	auipc	ra,0xffffe
    800030c4:	c04080e7          	jalr	-1020(ra) # 80000cc4 <release>
      return -1;
    800030c8:	57fd                	li	a5,-1
    800030ca:	bff9                	j	800030a8 <sys_sleep+0x88>

00000000800030cc <sys_kill>:

uint64
sys_kill(void)
{
    800030cc:	1101                	addi	sp,sp,-32
    800030ce:	ec06                	sd	ra,24(sp)
    800030d0:	e822                	sd	s0,16(sp)
    800030d2:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800030d4:	fec40593          	addi	a1,s0,-20
    800030d8:	4501                	li	a0,0
    800030da:	00000097          	auipc	ra,0x0
    800030de:	d84080e7          	jalr	-636(ra) # 80002e5e <argint>
    800030e2:	87aa                	mv	a5,a0
    return -1;
    800030e4:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800030e6:	0007c863          	bltz	a5,800030f6 <sys_kill+0x2a>
  return kill(pid);
    800030ea:	fec42503          	lw	a0,-20(s0)
    800030ee:	fffff097          	auipc	ra,0xfffff
    800030f2:	6b2080e7          	jalr	1714(ra) # 800027a0 <kill>
}
    800030f6:	60e2                	ld	ra,24(sp)
    800030f8:	6442                	ld	s0,16(sp)
    800030fa:	6105                	addi	sp,sp,32
    800030fc:	8082                	ret

00000000800030fe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030fe:	1101                	addi	sp,sp,-32
    80003100:	ec06                	sd	ra,24(sp)
    80003102:	e822                	sd	s0,16(sp)
    80003104:	e426                	sd	s1,8(sp)
    80003106:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003108:	00015517          	auipc	a0,0x15
    8000310c:	86050513          	addi	a0,a0,-1952 # 80017968 <tickslock>
    80003110:	ffffe097          	auipc	ra,0xffffe
    80003114:	b00080e7          	jalr	-1280(ra) # 80000c10 <acquire>
  xticks = ticks;
    80003118:	00006497          	auipc	s1,0x6
    8000311c:	f084a483          	lw	s1,-248(s1) # 80009020 <ticks>
  release(&tickslock);
    80003120:	00015517          	auipc	a0,0x15
    80003124:	84850513          	addi	a0,a0,-1976 # 80017968 <tickslock>
    80003128:	ffffe097          	auipc	ra,0xffffe
    8000312c:	b9c080e7          	jalr	-1124(ra) # 80000cc4 <release>
  return xticks;
}
    80003130:	02049513          	slli	a0,s1,0x20
    80003134:	9101                	srli	a0,a0,0x20
    80003136:	60e2                	ld	ra,24(sp)
    80003138:	6442                	ld	s0,16(sp)
    8000313a:	64a2                	ld	s1,8(sp)
    8000313c:	6105                	addi	sp,sp,32
    8000313e:	8082                	ret

0000000080003140 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003140:	7179                	addi	sp,sp,-48
    80003142:	f406                	sd	ra,40(sp)
    80003144:	f022                	sd	s0,32(sp)
    80003146:	ec26                	sd	s1,24(sp)
    80003148:	e84a                	sd	s2,16(sp)
    8000314a:	e44e                	sd	s3,8(sp)
    8000314c:	e052                	sd	s4,0(sp)
    8000314e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003150:	00005597          	auipc	a1,0x5
    80003154:	41858593          	addi	a1,a1,1048 # 80008568 <syscalls+0xb0>
    80003158:	00015517          	auipc	a0,0x15
    8000315c:	82850513          	addi	a0,a0,-2008 # 80017980 <bcache>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	a20080e7          	jalr	-1504(ra) # 80000b80 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003168:	0001d797          	auipc	a5,0x1d
    8000316c:	81878793          	addi	a5,a5,-2024 # 8001f980 <bcache+0x8000>
    80003170:	0001d717          	auipc	a4,0x1d
    80003174:	a7870713          	addi	a4,a4,-1416 # 8001fbe8 <bcache+0x8268>
    80003178:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000317c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003180:	00015497          	auipc	s1,0x15
    80003184:	81848493          	addi	s1,s1,-2024 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    80003188:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000318a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000318c:	00005a17          	auipc	s4,0x5
    80003190:	3e4a0a13          	addi	s4,s4,996 # 80008570 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003194:	2b893783          	ld	a5,696(s2)
    80003198:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000319a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000319e:	85d2                	mv	a1,s4
    800031a0:	01048513          	addi	a0,s1,16
    800031a4:	00001097          	auipc	ra,0x1
    800031a8:	4ac080e7          	jalr	1196(ra) # 80004650 <initsleeplock>
    bcache.head.next->prev = b;
    800031ac:	2b893783          	ld	a5,696(s2)
    800031b0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031b2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031b6:	45848493          	addi	s1,s1,1112
    800031ba:	fd349de3          	bne	s1,s3,80003194 <binit+0x54>
  }
}
    800031be:	70a2                	ld	ra,40(sp)
    800031c0:	7402                	ld	s0,32(sp)
    800031c2:	64e2                	ld	s1,24(sp)
    800031c4:	6942                	ld	s2,16(sp)
    800031c6:	69a2                	ld	s3,8(sp)
    800031c8:	6a02                	ld	s4,0(sp)
    800031ca:	6145                	addi	sp,sp,48
    800031cc:	8082                	ret

00000000800031ce <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031ce:	7179                	addi	sp,sp,-48
    800031d0:	f406                	sd	ra,40(sp)
    800031d2:	f022                	sd	s0,32(sp)
    800031d4:	ec26                	sd	s1,24(sp)
    800031d6:	e84a                	sd	s2,16(sp)
    800031d8:	e44e                	sd	s3,8(sp)
    800031da:	1800                	addi	s0,sp,48
    800031dc:	89aa                	mv	s3,a0
    800031de:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800031e0:	00014517          	auipc	a0,0x14
    800031e4:	7a050513          	addi	a0,a0,1952 # 80017980 <bcache>
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	a28080e7          	jalr	-1496(ra) # 80000c10 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031f0:	0001d497          	auipc	s1,0x1d
    800031f4:	a484b483          	ld	s1,-1464(s1) # 8001fc38 <bcache+0x82b8>
    800031f8:	0001d797          	auipc	a5,0x1d
    800031fc:	9f078793          	addi	a5,a5,-1552 # 8001fbe8 <bcache+0x8268>
    80003200:	02f48f63          	beq	s1,a5,8000323e <bread+0x70>
    80003204:	873e                	mv	a4,a5
    80003206:	a021                	j	8000320e <bread+0x40>
    80003208:	68a4                	ld	s1,80(s1)
    8000320a:	02e48a63          	beq	s1,a4,8000323e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000320e:	449c                	lw	a5,8(s1)
    80003210:	ff379ce3          	bne	a5,s3,80003208 <bread+0x3a>
    80003214:	44dc                	lw	a5,12(s1)
    80003216:	ff2799e3          	bne	a5,s2,80003208 <bread+0x3a>
      b->refcnt++;
    8000321a:	40bc                	lw	a5,64(s1)
    8000321c:	2785                	addiw	a5,a5,1
    8000321e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003220:	00014517          	auipc	a0,0x14
    80003224:	76050513          	addi	a0,a0,1888 # 80017980 <bcache>
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	a9c080e7          	jalr	-1380(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    80003230:	01048513          	addi	a0,s1,16
    80003234:	00001097          	auipc	ra,0x1
    80003238:	456080e7          	jalr	1110(ra) # 8000468a <acquiresleep>
      return b;
    8000323c:	a8b9                	j	8000329a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000323e:	0001d497          	auipc	s1,0x1d
    80003242:	9f24b483          	ld	s1,-1550(s1) # 8001fc30 <bcache+0x82b0>
    80003246:	0001d797          	auipc	a5,0x1d
    8000324a:	9a278793          	addi	a5,a5,-1630 # 8001fbe8 <bcache+0x8268>
    8000324e:	00f48863          	beq	s1,a5,8000325e <bread+0x90>
    80003252:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003254:	40bc                	lw	a5,64(s1)
    80003256:	cf81                	beqz	a5,8000326e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003258:	64a4                	ld	s1,72(s1)
    8000325a:	fee49de3          	bne	s1,a4,80003254 <bread+0x86>
  panic("bget: no buffers");
    8000325e:	00005517          	auipc	a0,0x5
    80003262:	31a50513          	addi	a0,a0,794 # 80008578 <syscalls+0xc0>
    80003266:	ffffd097          	auipc	ra,0xffffd
    8000326a:	2e2080e7          	jalr	738(ra) # 80000548 <panic>
      b->dev = dev;
    8000326e:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003272:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003276:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000327a:	4785                	li	a5,1
    8000327c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000327e:	00014517          	auipc	a0,0x14
    80003282:	70250513          	addi	a0,a0,1794 # 80017980 <bcache>
    80003286:	ffffe097          	auipc	ra,0xffffe
    8000328a:	a3e080e7          	jalr	-1474(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    8000328e:	01048513          	addi	a0,s1,16
    80003292:	00001097          	auipc	ra,0x1
    80003296:	3f8080e7          	jalr	1016(ra) # 8000468a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000329a:	409c                	lw	a5,0(s1)
    8000329c:	cb89                	beqz	a5,800032ae <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000329e:	8526                	mv	a0,s1
    800032a0:	70a2                	ld	ra,40(sp)
    800032a2:	7402                	ld	s0,32(sp)
    800032a4:	64e2                	ld	s1,24(sp)
    800032a6:	6942                	ld	s2,16(sp)
    800032a8:	69a2                	ld	s3,8(sp)
    800032aa:	6145                	addi	sp,sp,48
    800032ac:	8082                	ret
    virtio_disk_rw(b, 0);
    800032ae:	4581                	li	a1,0
    800032b0:	8526                	mv	a0,s1
    800032b2:	00003097          	auipc	ra,0x3
    800032b6:	f8a080e7          	jalr	-118(ra) # 8000623c <virtio_disk_rw>
    b->valid = 1;
    800032ba:	4785                	li	a5,1
    800032bc:	c09c                	sw	a5,0(s1)
  return b;
    800032be:	b7c5                	j	8000329e <bread+0xd0>

00000000800032c0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032c0:	1101                	addi	sp,sp,-32
    800032c2:	ec06                	sd	ra,24(sp)
    800032c4:	e822                	sd	s0,16(sp)
    800032c6:	e426                	sd	s1,8(sp)
    800032c8:	1000                	addi	s0,sp,32
    800032ca:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032cc:	0541                	addi	a0,a0,16
    800032ce:	00001097          	auipc	ra,0x1
    800032d2:	456080e7          	jalr	1110(ra) # 80004724 <holdingsleep>
    800032d6:	cd01                	beqz	a0,800032ee <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032d8:	4585                	li	a1,1
    800032da:	8526                	mv	a0,s1
    800032dc:	00003097          	auipc	ra,0x3
    800032e0:	f60080e7          	jalr	-160(ra) # 8000623c <virtio_disk_rw>
}
    800032e4:	60e2                	ld	ra,24(sp)
    800032e6:	6442                	ld	s0,16(sp)
    800032e8:	64a2                	ld	s1,8(sp)
    800032ea:	6105                	addi	sp,sp,32
    800032ec:	8082                	ret
    panic("bwrite");
    800032ee:	00005517          	auipc	a0,0x5
    800032f2:	2a250513          	addi	a0,a0,674 # 80008590 <syscalls+0xd8>
    800032f6:	ffffd097          	auipc	ra,0xffffd
    800032fa:	252080e7          	jalr	594(ra) # 80000548 <panic>

00000000800032fe <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032fe:	1101                	addi	sp,sp,-32
    80003300:	ec06                	sd	ra,24(sp)
    80003302:	e822                	sd	s0,16(sp)
    80003304:	e426                	sd	s1,8(sp)
    80003306:	e04a                	sd	s2,0(sp)
    80003308:	1000                	addi	s0,sp,32
    8000330a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000330c:	01050913          	addi	s2,a0,16
    80003310:	854a                	mv	a0,s2
    80003312:	00001097          	auipc	ra,0x1
    80003316:	412080e7          	jalr	1042(ra) # 80004724 <holdingsleep>
    8000331a:	c92d                	beqz	a0,8000338c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000331c:	854a                	mv	a0,s2
    8000331e:	00001097          	auipc	ra,0x1
    80003322:	3c2080e7          	jalr	962(ra) # 800046e0 <releasesleep>

  acquire(&bcache.lock);
    80003326:	00014517          	auipc	a0,0x14
    8000332a:	65a50513          	addi	a0,a0,1626 # 80017980 <bcache>
    8000332e:	ffffe097          	auipc	ra,0xffffe
    80003332:	8e2080e7          	jalr	-1822(ra) # 80000c10 <acquire>
  b->refcnt--;
    80003336:	40bc                	lw	a5,64(s1)
    80003338:	37fd                	addiw	a5,a5,-1
    8000333a:	0007871b          	sext.w	a4,a5
    8000333e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003340:	eb05                	bnez	a4,80003370 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003342:	68bc                	ld	a5,80(s1)
    80003344:	64b8                	ld	a4,72(s1)
    80003346:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003348:	64bc                	ld	a5,72(s1)
    8000334a:	68b8                	ld	a4,80(s1)
    8000334c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000334e:	0001c797          	auipc	a5,0x1c
    80003352:	63278793          	addi	a5,a5,1586 # 8001f980 <bcache+0x8000>
    80003356:	2b87b703          	ld	a4,696(a5)
    8000335a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000335c:	0001d717          	auipc	a4,0x1d
    80003360:	88c70713          	addi	a4,a4,-1908 # 8001fbe8 <bcache+0x8268>
    80003364:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003366:	2b87b703          	ld	a4,696(a5)
    8000336a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000336c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003370:	00014517          	auipc	a0,0x14
    80003374:	61050513          	addi	a0,a0,1552 # 80017980 <bcache>
    80003378:	ffffe097          	auipc	ra,0xffffe
    8000337c:	94c080e7          	jalr	-1716(ra) # 80000cc4 <release>
}
    80003380:	60e2                	ld	ra,24(sp)
    80003382:	6442                	ld	s0,16(sp)
    80003384:	64a2                	ld	s1,8(sp)
    80003386:	6902                	ld	s2,0(sp)
    80003388:	6105                	addi	sp,sp,32
    8000338a:	8082                	ret
    panic("brelse");
    8000338c:	00005517          	auipc	a0,0x5
    80003390:	20c50513          	addi	a0,a0,524 # 80008598 <syscalls+0xe0>
    80003394:	ffffd097          	auipc	ra,0xffffd
    80003398:	1b4080e7          	jalr	436(ra) # 80000548 <panic>

000000008000339c <bpin>:

void
bpin(struct buf *b) {
    8000339c:	1101                	addi	sp,sp,-32
    8000339e:	ec06                	sd	ra,24(sp)
    800033a0:	e822                	sd	s0,16(sp)
    800033a2:	e426                	sd	s1,8(sp)
    800033a4:	1000                	addi	s0,sp,32
    800033a6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033a8:	00014517          	auipc	a0,0x14
    800033ac:	5d850513          	addi	a0,a0,1496 # 80017980 <bcache>
    800033b0:	ffffe097          	auipc	ra,0xffffe
    800033b4:	860080e7          	jalr	-1952(ra) # 80000c10 <acquire>
  b->refcnt++;
    800033b8:	40bc                	lw	a5,64(s1)
    800033ba:	2785                	addiw	a5,a5,1
    800033bc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033be:	00014517          	auipc	a0,0x14
    800033c2:	5c250513          	addi	a0,a0,1474 # 80017980 <bcache>
    800033c6:	ffffe097          	auipc	ra,0xffffe
    800033ca:	8fe080e7          	jalr	-1794(ra) # 80000cc4 <release>
}
    800033ce:	60e2                	ld	ra,24(sp)
    800033d0:	6442                	ld	s0,16(sp)
    800033d2:	64a2                	ld	s1,8(sp)
    800033d4:	6105                	addi	sp,sp,32
    800033d6:	8082                	ret

00000000800033d8 <bunpin>:

void
bunpin(struct buf *b) {
    800033d8:	1101                	addi	sp,sp,-32
    800033da:	ec06                	sd	ra,24(sp)
    800033dc:	e822                	sd	s0,16(sp)
    800033de:	e426                	sd	s1,8(sp)
    800033e0:	1000                	addi	s0,sp,32
    800033e2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033e4:	00014517          	auipc	a0,0x14
    800033e8:	59c50513          	addi	a0,a0,1436 # 80017980 <bcache>
    800033ec:	ffffe097          	auipc	ra,0xffffe
    800033f0:	824080e7          	jalr	-2012(ra) # 80000c10 <acquire>
  b->refcnt--;
    800033f4:	40bc                	lw	a5,64(s1)
    800033f6:	37fd                	addiw	a5,a5,-1
    800033f8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033fa:	00014517          	auipc	a0,0x14
    800033fe:	58650513          	addi	a0,a0,1414 # 80017980 <bcache>
    80003402:	ffffe097          	auipc	ra,0xffffe
    80003406:	8c2080e7          	jalr	-1854(ra) # 80000cc4 <release>
}
    8000340a:	60e2                	ld	ra,24(sp)
    8000340c:	6442                	ld	s0,16(sp)
    8000340e:	64a2                	ld	s1,8(sp)
    80003410:	6105                	addi	sp,sp,32
    80003412:	8082                	ret

0000000080003414 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003414:	1101                	addi	sp,sp,-32
    80003416:	ec06                	sd	ra,24(sp)
    80003418:	e822                	sd	s0,16(sp)
    8000341a:	e426                	sd	s1,8(sp)
    8000341c:	e04a                	sd	s2,0(sp)
    8000341e:	1000                	addi	s0,sp,32
    80003420:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003422:	00d5d59b          	srliw	a1,a1,0xd
    80003426:	0001d797          	auipc	a5,0x1d
    8000342a:	c367a783          	lw	a5,-970(a5) # 8002005c <sb+0x1c>
    8000342e:	9dbd                	addw	a1,a1,a5
    80003430:	00000097          	auipc	ra,0x0
    80003434:	d9e080e7          	jalr	-610(ra) # 800031ce <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003438:	0074f713          	andi	a4,s1,7
    8000343c:	4785                	li	a5,1
    8000343e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003442:	14ce                	slli	s1,s1,0x33
    80003444:	90d9                	srli	s1,s1,0x36
    80003446:	00950733          	add	a4,a0,s1
    8000344a:	05874703          	lbu	a4,88(a4)
    8000344e:	00e7f6b3          	and	a3,a5,a4
    80003452:	c69d                	beqz	a3,80003480 <bfree+0x6c>
    80003454:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003456:	94aa                	add	s1,s1,a0
    80003458:	fff7c793          	not	a5,a5
    8000345c:	8ff9                	and	a5,a5,a4
    8000345e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003462:	00001097          	auipc	ra,0x1
    80003466:	100080e7          	jalr	256(ra) # 80004562 <log_write>
  brelse(bp);
    8000346a:	854a                	mv	a0,s2
    8000346c:	00000097          	auipc	ra,0x0
    80003470:	e92080e7          	jalr	-366(ra) # 800032fe <brelse>
}
    80003474:	60e2                	ld	ra,24(sp)
    80003476:	6442                	ld	s0,16(sp)
    80003478:	64a2                	ld	s1,8(sp)
    8000347a:	6902                	ld	s2,0(sp)
    8000347c:	6105                	addi	sp,sp,32
    8000347e:	8082                	ret
    panic("freeing free block");
    80003480:	00005517          	auipc	a0,0x5
    80003484:	12050513          	addi	a0,a0,288 # 800085a0 <syscalls+0xe8>
    80003488:	ffffd097          	auipc	ra,0xffffd
    8000348c:	0c0080e7          	jalr	192(ra) # 80000548 <panic>

0000000080003490 <balloc>:
{
    80003490:	711d                	addi	sp,sp,-96
    80003492:	ec86                	sd	ra,88(sp)
    80003494:	e8a2                	sd	s0,80(sp)
    80003496:	e4a6                	sd	s1,72(sp)
    80003498:	e0ca                	sd	s2,64(sp)
    8000349a:	fc4e                	sd	s3,56(sp)
    8000349c:	f852                	sd	s4,48(sp)
    8000349e:	f456                	sd	s5,40(sp)
    800034a0:	f05a                	sd	s6,32(sp)
    800034a2:	ec5e                	sd	s7,24(sp)
    800034a4:	e862                	sd	s8,16(sp)
    800034a6:	e466                	sd	s9,8(sp)
    800034a8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034aa:	0001d797          	auipc	a5,0x1d
    800034ae:	b9a7a783          	lw	a5,-1126(a5) # 80020044 <sb+0x4>
    800034b2:	cbd1                	beqz	a5,80003546 <balloc+0xb6>
    800034b4:	8baa                	mv	s7,a0
    800034b6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034b8:	0001db17          	auipc	s6,0x1d
    800034bc:	b88b0b13          	addi	s6,s6,-1144 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034c0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034c2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034c4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034c6:	6c89                	lui	s9,0x2
    800034c8:	a831                	j	800034e4 <balloc+0x54>
    brelse(bp);
    800034ca:	854a                	mv	a0,s2
    800034cc:	00000097          	auipc	ra,0x0
    800034d0:	e32080e7          	jalr	-462(ra) # 800032fe <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034d4:	015c87bb          	addw	a5,s9,s5
    800034d8:	00078a9b          	sext.w	s5,a5
    800034dc:	004b2703          	lw	a4,4(s6)
    800034e0:	06eaf363          	bgeu	s5,a4,80003546 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800034e4:	41fad79b          	sraiw	a5,s5,0x1f
    800034e8:	0137d79b          	srliw	a5,a5,0x13
    800034ec:	015787bb          	addw	a5,a5,s5
    800034f0:	40d7d79b          	sraiw	a5,a5,0xd
    800034f4:	01cb2583          	lw	a1,28(s6)
    800034f8:	9dbd                	addw	a1,a1,a5
    800034fa:	855e                	mv	a0,s7
    800034fc:	00000097          	auipc	ra,0x0
    80003500:	cd2080e7          	jalr	-814(ra) # 800031ce <bread>
    80003504:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003506:	004b2503          	lw	a0,4(s6)
    8000350a:	000a849b          	sext.w	s1,s5
    8000350e:	8662                	mv	a2,s8
    80003510:	faa4fde3          	bgeu	s1,a0,800034ca <balloc+0x3a>
      m = 1 << (bi % 8);
    80003514:	41f6579b          	sraiw	a5,a2,0x1f
    80003518:	01d7d69b          	srliw	a3,a5,0x1d
    8000351c:	00c6873b          	addw	a4,a3,a2
    80003520:	00777793          	andi	a5,a4,7
    80003524:	9f95                	subw	a5,a5,a3
    80003526:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000352a:	4037571b          	sraiw	a4,a4,0x3
    8000352e:	00e906b3          	add	a3,s2,a4
    80003532:	0586c683          	lbu	a3,88(a3)
    80003536:	00d7f5b3          	and	a1,a5,a3
    8000353a:	cd91                	beqz	a1,80003556 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000353c:	2605                	addiw	a2,a2,1
    8000353e:	2485                	addiw	s1,s1,1
    80003540:	fd4618e3          	bne	a2,s4,80003510 <balloc+0x80>
    80003544:	b759                	j	800034ca <balloc+0x3a>
  panic("balloc: out of blocks");
    80003546:	00005517          	auipc	a0,0x5
    8000354a:	07250513          	addi	a0,a0,114 # 800085b8 <syscalls+0x100>
    8000354e:	ffffd097          	auipc	ra,0xffffd
    80003552:	ffa080e7          	jalr	-6(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003556:	974a                	add	a4,a4,s2
    80003558:	8fd5                	or	a5,a5,a3
    8000355a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000355e:	854a                	mv	a0,s2
    80003560:	00001097          	auipc	ra,0x1
    80003564:	002080e7          	jalr	2(ra) # 80004562 <log_write>
        brelse(bp);
    80003568:	854a                	mv	a0,s2
    8000356a:	00000097          	auipc	ra,0x0
    8000356e:	d94080e7          	jalr	-620(ra) # 800032fe <brelse>
  bp = bread(dev, bno);
    80003572:	85a6                	mv	a1,s1
    80003574:	855e                	mv	a0,s7
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	c58080e7          	jalr	-936(ra) # 800031ce <bread>
    8000357e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003580:	40000613          	li	a2,1024
    80003584:	4581                	li	a1,0
    80003586:	05850513          	addi	a0,a0,88
    8000358a:	ffffd097          	auipc	ra,0xffffd
    8000358e:	782080e7          	jalr	1922(ra) # 80000d0c <memset>
  log_write(bp);
    80003592:	854a                	mv	a0,s2
    80003594:	00001097          	auipc	ra,0x1
    80003598:	fce080e7          	jalr	-50(ra) # 80004562 <log_write>
  brelse(bp);
    8000359c:	854a                	mv	a0,s2
    8000359e:	00000097          	auipc	ra,0x0
    800035a2:	d60080e7          	jalr	-672(ra) # 800032fe <brelse>
}
    800035a6:	8526                	mv	a0,s1
    800035a8:	60e6                	ld	ra,88(sp)
    800035aa:	6446                	ld	s0,80(sp)
    800035ac:	64a6                	ld	s1,72(sp)
    800035ae:	6906                	ld	s2,64(sp)
    800035b0:	79e2                	ld	s3,56(sp)
    800035b2:	7a42                	ld	s4,48(sp)
    800035b4:	7aa2                	ld	s5,40(sp)
    800035b6:	7b02                	ld	s6,32(sp)
    800035b8:	6be2                	ld	s7,24(sp)
    800035ba:	6c42                	ld	s8,16(sp)
    800035bc:	6ca2                	ld	s9,8(sp)
    800035be:	6125                	addi	sp,sp,96
    800035c0:	8082                	ret

00000000800035c2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800035c2:	7179                	addi	sp,sp,-48
    800035c4:	f406                	sd	ra,40(sp)
    800035c6:	f022                	sd	s0,32(sp)
    800035c8:	ec26                	sd	s1,24(sp)
    800035ca:	e84a                	sd	s2,16(sp)
    800035cc:	e44e                	sd	s3,8(sp)
    800035ce:	e052                	sd	s4,0(sp)
    800035d0:	1800                	addi	s0,sp,48
    800035d2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035d4:	47ad                	li	a5,11
    800035d6:	04b7fe63          	bgeu	a5,a1,80003632 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800035da:	ff45849b          	addiw	s1,a1,-12
    800035de:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035e2:	0ff00793          	li	a5,255
    800035e6:	0ae7e363          	bltu	a5,a4,8000368c <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800035ea:	08052583          	lw	a1,128(a0)
    800035ee:	c5ad                	beqz	a1,80003658 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800035f0:	00092503          	lw	a0,0(s2)
    800035f4:	00000097          	auipc	ra,0x0
    800035f8:	bda080e7          	jalr	-1062(ra) # 800031ce <bread>
    800035fc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035fe:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003602:	02049593          	slli	a1,s1,0x20
    80003606:	9181                	srli	a1,a1,0x20
    80003608:	058a                	slli	a1,a1,0x2
    8000360a:	00b784b3          	add	s1,a5,a1
    8000360e:	0004a983          	lw	s3,0(s1)
    80003612:	04098d63          	beqz	s3,8000366c <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003616:	8552                	mv	a0,s4
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	ce6080e7          	jalr	-794(ra) # 800032fe <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003620:	854e                	mv	a0,s3
    80003622:	70a2                	ld	ra,40(sp)
    80003624:	7402                	ld	s0,32(sp)
    80003626:	64e2                	ld	s1,24(sp)
    80003628:	6942                	ld	s2,16(sp)
    8000362a:	69a2                	ld	s3,8(sp)
    8000362c:	6a02                	ld	s4,0(sp)
    8000362e:	6145                	addi	sp,sp,48
    80003630:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003632:	02059493          	slli	s1,a1,0x20
    80003636:	9081                	srli	s1,s1,0x20
    80003638:	048a                	slli	s1,s1,0x2
    8000363a:	94aa                	add	s1,s1,a0
    8000363c:	0504a983          	lw	s3,80(s1)
    80003640:	fe0990e3          	bnez	s3,80003620 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003644:	4108                	lw	a0,0(a0)
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	e4a080e7          	jalr	-438(ra) # 80003490 <balloc>
    8000364e:	0005099b          	sext.w	s3,a0
    80003652:	0534a823          	sw	s3,80(s1)
    80003656:	b7e9                	j	80003620 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003658:	4108                	lw	a0,0(a0)
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	e36080e7          	jalr	-458(ra) # 80003490 <balloc>
    80003662:	0005059b          	sext.w	a1,a0
    80003666:	08b92023          	sw	a1,128(s2)
    8000366a:	b759                	j	800035f0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000366c:	00092503          	lw	a0,0(s2)
    80003670:	00000097          	auipc	ra,0x0
    80003674:	e20080e7          	jalr	-480(ra) # 80003490 <balloc>
    80003678:	0005099b          	sext.w	s3,a0
    8000367c:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003680:	8552                	mv	a0,s4
    80003682:	00001097          	auipc	ra,0x1
    80003686:	ee0080e7          	jalr	-288(ra) # 80004562 <log_write>
    8000368a:	b771                	j	80003616 <bmap+0x54>
  panic("bmap: out of range");
    8000368c:	00005517          	auipc	a0,0x5
    80003690:	f4450513          	addi	a0,a0,-188 # 800085d0 <syscalls+0x118>
    80003694:	ffffd097          	auipc	ra,0xffffd
    80003698:	eb4080e7          	jalr	-332(ra) # 80000548 <panic>

000000008000369c <iget>:
{
    8000369c:	7179                	addi	sp,sp,-48
    8000369e:	f406                	sd	ra,40(sp)
    800036a0:	f022                	sd	s0,32(sp)
    800036a2:	ec26                	sd	s1,24(sp)
    800036a4:	e84a                	sd	s2,16(sp)
    800036a6:	e44e                	sd	s3,8(sp)
    800036a8:	e052                	sd	s4,0(sp)
    800036aa:	1800                	addi	s0,sp,48
    800036ac:	89aa                	mv	s3,a0
    800036ae:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800036b0:	0001d517          	auipc	a0,0x1d
    800036b4:	9b050513          	addi	a0,a0,-1616 # 80020060 <icache>
    800036b8:	ffffd097          	auipc	ra,0xffffd
    800036bc:	558080e7          	jalr	1368(ra) # 80000c10 <acquire>
  empty = 0;
    800036c0:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036c2:	0001d497          	auipc	s1,0x1d
    800036c6:	9b648493          	addi	s1,s1,-1610 # 80020078 <icache+0x18>
    800036ca:	0001e697          	auipc	a3,0x1e
    800036ce:	43e68693          	addi	a3,a3,1086 # 80021b08 <log>
    800036d2:	a039                	j	800036e0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036d4:	02090b63          	beqz	s2,8000370a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036d8:	08848493          	addi	s1,s1,136
    800036dc:	02d48a63          	beq	s1,a3,80003710 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036e0:	449c                	lw	a5,8(s1)
    800036e2:	fef059e3          	blez	a5,800036d4 <iget+0x38>
    800036e6:	4098                	lw	a4,0(s1)
    800036e8:	ff3716e3          	bne	a4,s3,800036d4 <iget+0x38>
    800036ec:	40d8                	lw	a4,4(s1)
    800036ee:	ff4713e3          	bne	a4,s4,800036d4 <iget+0x38>
      ip->ref++;
    800036f2:	2785                	addiw	a5,a5,1
    800036f4:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800036f6:	0001d517          	auipc	a0,0x1d
    800036fa:	96a50513          	addi	a0,a0,-1686 # 80020060 <icache>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	5c6080e7          	jalr	1478(ra) # 80000cc4 <release>
      return ip;
    80003706:	8926                	mv	s2,s1
    80003708:	a03d                	j	80003736 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000370a:	f7f9                	bnez	a5,800036d8 <iget+0x3c>
    8000370c:	8926                	mv	s2,s1
    8000370e:	b7e9                	j	800036d8 <iget+0x3c>
  if(empty == 0)
    80003710:	02090c63          	beqz	s2,80003748 <iget+0xac>
  ip->dev = dev;
    80003714:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003718:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000371c:	4785                	li	a5,1
    8000371e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003722:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003726:	0001d517          	auipc	a0,0x1d
    8000372a:	93a50513          	addi	a0,a0,-1734 # 80020060 <icache>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	596080e7          	jalr	1430(ra) # 80000cc4 <release>
}
    80003736:	854a                	mv	a0,s2
    80003738:	70a2                	ld	ra,40(sp)
    8000373a:	7402                	ld	s0,32(sp)
    8000373c:	64e2                	ld	s1,24(sp)
    8000373e:	6942                	ld	s2,16(sp)
    80003740:	69a2                	ld	s3,8(sp)
    80003742:	6a02                	ld	s4,0(sp)
    80003744:	6145                	addi	sp,sp,48
    80003746:	8082                	ret
    panic("iget: no inodes");
    80003748:	00005517          	auipc	a0,0x5
    8000374c:	ea050513          	addi	a0,a0,-352 # 800085e8 <syscalls+0x130>
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	df8080e7          	jalr	-520(ra) # 80000548 <panic>

0000000080003758 <fsinit>:
fsinit(int dev) {
    80003758:	7179                	addi	sp,sp,-48
    8000375a:	f406                	sd	ra,40(sp)
    8000375c:	f022                	sd	s0,32(sp)
    8000375e:	ec26                	sd	s1,24(sp)
    80003760:	e84a                	sd	s2,16(sp)
    80003762:	e44e                	sd	s3,8(sp)
    80003764:	1800                	addi	s0,sp,48
    80003766:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003768:	4585                	li	a1,1
    8000376a:	00000097          	auipc	ra,0x0
    8000376e:	a64080e7          	jalr	-1436(ra) # 800031ce <bread>
    80003772:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003774:	0001d997          	auipc	s3,0x1d
    80003778:	8cc98993          	addi	s3,s3,-1844 # 80020040 <sb>
    8000377c:	02000613          	li	a2,32
    80003780:	05850593          	addi	a1,a0,88
    80003784:	854e                	mv	a0,s3
    80003786:	ffffd097          	auipc	ra,0xffffd
    8000378a:	5e6080e7          	jalr	1510(ra) # 80000d6c <memmove>
  brelse(bp);
    8000378e:	8526                	mv	a0,s1
    80003790:	00000097          	auipc	ra,0x0
    80003794:	b6e080e7          	jalr	-1170(ra) # 800032fe <brelse>
  if(sb.magic != FSMAGIC)
    80003798:	0009a703          	lw	a4,0(s3)
    8000379c:	102037b7          	lui	a5,0x10203
    800037a0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037a4:	02f71263          	bne	a4,a5,800037c8 <fsinit+0x70>
  initlog(dev, &sb);
    800037a8:	0001d597          	auipc	a1,0x1d
    800037ac:	89858593          	addi	a1,a1,-1896 # 80020040 <sb>
    800037b0:	854a                	mv	a0,s2
    800037b2:	00001097          	auipc	ra,0x1
    800037b6:	b38080e7          	jalr	-1224(ra) # 800042ea <initlog>
}
    800037ba:	70a2                	ld	ra,40(sp)
    800037bc:	7402                	ld	s0,32(sp)
    800037be:	64e2                	ld	s1,24(sp)
    800037c0:	6942                	ld	s2,16(sp)
    800037c2:	69a2                	ld	s3,8(sp)
    800037c4:	6145                	addi	sp,sp,48
    800037c6:	8082                	ret
    panic("invalid file system");
    800037c8:	00005517          	auipc	a0,0x5
    800037cc:	e3050513          	addi	a0,a0,-464 # 800085f8 <syscalls+0x140>
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	d78080e7          	jalr	-648(ra) # 80000548 <panic>

00000000800037d8 <iinit>:
{
    800037d8:	7179                	addi	sp,sp,-48
    800037da:	f406                	sd	ra,40(sp)
    800037dc:	f022                	sd	s0,32(sp)
    800037de:	ec26                	sd	s1,24(sp)
    800037e0:	e84a                	sd	s2,16(sp)
    800037e2:	e44e                	sd	s3,8(sp)
    800037e4:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800037e6:	00005597          	auipc	a1,0x5
    800037ea:	e2a58593          	addi	a1,a1,-470 # 80008610 <syscalls+0x158>
    800037ee:	0001d517          	auipc	a0,0x1d
    800037f2:	87250513          	addi	a0,a0,-1934 # 80020060 <icache>
    800037f6:	ffffd097          	auipc	ra,0xffffd
    800037fa:	38a080e7          	jalr	906(ra) # 80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037fe:	0001d497          	auipc	s1,0x1d
    80003802:	88a48493          	addi	s1,s1,-1910 # 80020088 <icache+0x28>
    80003806:	0001e997          	auipc	s3,0x1e
    8000380a:	31298993          	addi	s3,s3,786 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000380e:	00005917          	auipc	s2,0x5
    80003812:	e0a90913          	addi	s2,s2,-502 # 80008618 <syscalls+0x160>
    80003816:	85ca                	mv	a1,s2
    80003818:	8526                	mv	a0,s1
    8000381a:	00001097          	auipc	ra,0x1
    8000381e:	e36080e7          	jalr	-458(ra) # 80004650 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003822:	08848493          	addi	s1,s1,136
    80003826:	ff3498e3          	bne	s1,s3,80003816 <iinit+0x3e>
}
    8000382a:	70a2                	ld	ra,40(sp)
    8000382c:	7402                	ld	s0,32(sp)
    8000382e:	64e2                	ld	s1,24(sp)
    80003830:	6942                	ld	s2,16(sp)
    80003832:	69a2                	ld	s3,8(sp)
    80003834:	6145                	addi	sp,sp,48
    80003836:	8082                	ret

0000000080003838 <ialloc>:
{
    80003838:	715d                	addi	sp,sp,-80
    8000383a:	e486                	sd	ra,72(sp)
    8000383c:	e0a2                	sd	s0,64(sp)
    8000383e:	fc26                	sd	s1,56(sp)
    80003840:	f84a                	sd	s2,48(sp)
    80003842:	f44e                	sd	s3,40(sp)
    80003844:	f052                	sd	s4,32(sp)
    80003846:	ec56                	sd	s5,24(sp)
    80003848:	e85a                	sd	s6,16(sp)
    8000384a:	e45e                	sd	s7,8(sp)
    8000384c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000384e:	0001c717          	auipc	a4,0x1c
    80003852:	7fe72703          	lw	a4,2046(a4) # 8002004c <sb+0xc>
    80003856:	4785                	li	a5,1
    80003858:	04e7fa63          	bgeu	a5,a4,800038ac <ialloc+0x74>
    8000385c:	8aaa                	mv	s5,a0
    8000385e:	8bae                	mv	s7,a1
    80003860:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003862:	0001ca17          	auipc	s4,0x1c
    80003866:	7dea0a13          	addi	s4,s4,2014 # 80020040 <sb>
    8000386a:	00048b1b          	sext.w	s6,s1
    8000386e:	0044d593          	srli	a1,s1,0x4
    80003872:	018a2783          	lw	a5,24(s4)
    80003876:	9dbd                	addw	a1,a1,a5
    80003878:	8556                	mv	a0,s5
    8000387a:	00000097          	auipc	ra,0x0
    8000387e:	954080e7          	jalr	-1708(ra) # 800031ce <bread>
    80003882:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003884:	05850993          	addi	s3,a0,88
    80003888:	00f4f793          	andi	a5,s1,15
    8000388c:	079a                	slli	a5,a5,0x6
    8000388e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003890:	00099783          	lh	a5,0(s3)
    80003894:	c785                	beqz	a5,800038bc <ialloc+0x84>
    brelse(bp);
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	a68080e7          	jalr	-1432(ra) # 800032fe <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000389e:	0485                	addi	s1,s1,1
    800038a0:	00ca2703          	lw	a4,12(s4)
    800038a4:	0004879b          	sext.w	a5,s1
    800038a8:	fce7e1e3          	bltu	a5,a4,8000386a <ialloc+0x32>
  panic("ialloc: no inodes");
    800038ac:	00005517          	auipc	a0,0x5
    800038b0:	d7450513          	addi	a0,a0,-652 # 80008620 <syscalls+0x168>
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	c94080e7          	jalr	-876(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    800038bc:	04000613          	li	a2,64
    800038c0:	4581                	li	a1,0
    800038c2:	854e                	mv	a0,s3
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	448080e7          	jalr	1096(ra) # 80000d0c <memset>
      dip->type = type;
    800038cc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038d0:	854a                	mv	a0,s2
    800038d2:	00001097          	auipc	ra,0x1
    800038d6:	c90080e7          	jalr	-880(ra) # 80004562 <log_write>
      brelse(bp);
    800038da:	854a                	mv	a0,s2
    800038dc:	00000097          	auipc	ra,0x0
    800038e0:	a22080e7          	jalr	-1502(ra) # 800032fe <brelse>
      return iget(dev, inum);
    800038e4:	85da                	mv	a1,s6
    800038e6:	8556                	mv	a0,s5
    800038e8:	00000097          	auipc	ra,0x0
    800038ec:	db4080e7          	jalr	-588(ra) # 8000369c <iget>
}
    800038f0:	60a6                	ld	ra,72(sp)
    800038f2:	6406                	ld	s0,64(sp)
    800038f4:	74e2                	ld	s1,56(sp)
    800038f6:	7942                	ld	s2,48(sp)
    800038f8:	79a2                	ld	s3,40(sp)
    800038fa:	7a02                	ld	s4,32(sp)
    800038fc:	6ae2                	ld	s5,24(sp)
    800038fe:	6b42                	ld	s6,16(sp)
    80003900:	6ba2                	ld	s7,8(sp)
    80003902:	6161                	addi	sp,sp,80
    80003904:	8082                	ret

0000000080003906 <iupdate>:
{
    80003906:	1101                	addi	sp,sp,-32
    80003908:	ec06                	sd	ra,24(sp)
    8000390a:	e822                	sd	s0,16(sp)
    8000390c:	e426                	sd	s1,8(sp)
    8000390e:	e04a                	sd	s2,0(sp)
    80003910:	1000                	addi	s0,sp,32
    80003912:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003914:	415c                	lw	a5,4(a0)
    80003916:	0047d79b          	srliw	a5,a5,0x4
    8000391a:	0001c597          	auipc	a1,0x1c
    8000391e:	73e5a583          	lw	a1,1854(a1) # 80020058 <sb+0x18>
    80003922:	9dbd                	addw	a1,a1,a5
    80003924:	4108                	lw	a0,0(a0)
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	8a8080e7          	jalr	-1880(ra) # 800031ce <bread>
    8000392e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003930:	05850793          	addi	a5,a0,88
    80003934:	40c8                	lw	a0,4(s1)
    80003936:	893d                	andi	a0,a0,15
    80003938:	051a                	slli	a0,a0,0x6
    8000393a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000393c:	04449703          	lh	a4,68(s1)
    80003940:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003944:	04649703          	lh	a4,70(s1)
    80003948:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000394c:	04849703          	lh	a4,72(s1)
    80003950:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003954:	04a49703          	lh	a4,74(s1)
    80003958:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000395c:	44f8                	lw	a4,76(s1)
    8000395e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003960:	03400613          	li	a2,52
    80003964:	05048593          	addi	a1,s1,80
    80003968:	0531                	addi	a0,a0,12
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	402080e7          	jalr	1026(ra) # 80000d6c <memmove>
  log_write(bp);
    80003972:	854a                	mv	a0,s2
    80003974:	00001097          	auipc	ra,0x1
    80003978:	bee080e7          	jalr	-1042(ra) # 80004562 <log_write>
  brelse(bp);
    8000397c:	854a                	mv	a0,s2
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	980080e7          	jalr	-1664(ra) # 800032fe <brelse>
}
    80003986:	60e2                	ld	ra,24(sp)
    80003988:	6442                	ld	s0,16(sp)
    8000398a:	64a2                	ld	s1,8(sp)
    8000398c:	6902                	ld	s2,0(sp)
    8000398e:	6105                	addi	sp,sp,32
    80003990:	8082                	ret

0000000080003992 <idup>:
{
    80003992:	1101                	addi	sp,sp,-32
    80003994:	ec06                	sd	ra,24(sp)
    80003996:	e822                	sd	s0,16(sp)
    80003998:	e426                	sd	s1,8(sp)
    8000399a:	1000                	addi	s0,sp,32
    8000399c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000399e:	0001c517          	auipc	a0,0x1c
    800039a2:	6c250513          	addi	a0,a0,1730 # 80020060 <icache>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	26a080e7          	jalr	618(ra) # 80000c10 <acquire>
  ip->ref++;
    800039ae:	449c                	lw	a5,8(s1)
    800039b0:	2785                	addiw	a5,a5,1
    800039b2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039b4:	0001c517          	auipc	a0,0x1c
    800039b8:	6ac50513          	addi	a0,a0,1708 # 80020060 <icache>
    800039bc:	ffffd097          	auipc	ra,0xffffd
    800039c0:	308080e7          	jalr	776(ra) # 80000cc4 <release>
}
    800039c4:	8526                	mv	a0,s1
    800039c6:	60e2                	ld	ra,24(sp)
    800039c8:	6442                	ld	s0,16(sp)
    800039ca:	64a2                	ld	s1,8(sp)
    800039cc:	6105                	addi	sp,sp,32
    800039ce:	8082                	ret

00000000800039d0 <ilock>:
{
    800039d0:	1101                	addi	sp,sp,-32
    800039d2:	ec06                	sd	ra,24(sp)
    800039d4:	e822                	sd	s0,16(sp)
    800039d6:	e426                	sd	s1,8(sp)
    800039d8:	e04a                	sd	s2,0(sp)
    800039da:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039dc:	c115                	beqz	a0,80003a00 <ilock+0x30>
    800039de:	84aa                	mv	s1,a0
    800039e0:	451c                	lw	a5,8(a0)
    800039e2:	00f05f63          	blez	a5,80003a00 <ilock+0x30>
  acquiresleep(&ip->lock);
    800039e6:	0541                	addi	a0,a0,16
    800039e8:	00001097          	auipc	ra,0x1
    800039ec:	ca2080e7          	jalr	-862(ra) # 8000468a <acquiresleep>
  if(ip->valid == 0){
    800039f0:	40bc                	lw	a5,64(s1)
    800039f2:	cf99                	beqz	a5,80003a10 <ilock+0x40>
}
    800039f4:	60e2                	ld	ra,24(sp)
    800039f6:	6442                	ld	s0,16(sp)
    800039f8:	64a2                	ld	s1,8(sp)
    800039fa:	6902                	ld	s2,0(sp)
    800039fc:	6105                	addi	sp,sp,32
    800039fe:	8082                	ret
    panic("ilock");
    80003a00:	00005517          	auipc	a0,0x5
    80003a04:	c3850513          	addi	a0,a0,-968 # 80008638 <syscalls+0x180>
    80003a08:	ffffd097          	auipc	ra,0xffffd
    80003a0c:	b40080e7          	jalr	-1216(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a10:	40dc                	lw	a5,4(s1)
    80003a12:	0047d79b          	srliw	a5,a5,0x4
    80003a16:	0001c597          	auipc	a1,0x1c
    80003a1a:	6425a583          	lw	a1,1602(a1) # 80020058 <sb+0x18>
    80003a1e:	9dbd                	addw	a1,a1,a5
    80003a20:	4088                	lw	a0,0(s1)
    80003a22:	fffff097          	auipc	ra,0xfffff
    80003a26:	7ac080e7          	jalr	1964(ra) # 800031ce <bread>
    80003a2a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a2c:	05850593          	addi	a1,a0,88
    80003a30:	40dc                	lw	a5,4(s1)
    80003a32:	8bbd                	andi	a5,a5,15
    80003a34:	079a                	slli	a5,a5,0x6
    80003a36:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a38:	00059783          	lh	a5,0(a1)
    80003a3c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a40:	00259783          	lh	a5,2(a1)
    80003a44:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a48:	00459783          	lh	a5,4(a1)
    80003a4c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a50:	00659783          	lh	a5,6(a1)
    80003a54:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a58:	459c                	lw	a5,8(a1)
    80003a5a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a5c:	03400613          	li	a2,52
    80003a60:	05b1                	addi	a1,a1,12
    80003a62:	05048513          	addi	a0,s1,80
    80003a66:	ffffd097          	auipc	ra,0xffffd
    80003a6a:	306080e7          	jalr	774(ra) # 80000d6c <memmove>
    brelse(bp);
    80003a6e:	854a                	mv	a0,s2
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	88e080e7          	jalr	-1906(ra) # 800032fe <brelse>
    ip->valid = 1;
    80003a78:	4785                	li	a5,1
    80003a7a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a7c:	04449783          	lh	a5,68(s1)
    80003a80:	fbb5                	bnez	a5,800039f4 <ilock+0x24>
      panic("ilock: no type");
    80003a82:	00005517          	auipc	a0,0x5
    80003a86:	bbe50513          	addi	a0,a0,-1090 # 80008640 <syscalls+0x188>
    80003a8a:	ffffd097          	auipc	ra,0xffffd
    80003a8e:	abe080e7          	jalr	-1346(ra) # 80000548 <panic>

0000000080003a92 <iunlock>:
{
    80003a92:	1101                	addi	sp,sp,-32
    80003a94:	ec06                	sd	ra,24(sp)
    80003a96:	e822                	sd	s0,16(sp)
    80003a98:	e426                	sd	s1,8(sp)
    80003a9a:	e04a                	sd	s2,0(sp)
    80003a9c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a9e:	c905                	beqz	a0,80003ace <iunlock+0x3c>
    80003aa0:	84aa                	mv	s1,a0
    80003aa2:	01050913          	addi	s2,a0,16
    80003aa6:	854a                	mv	a0,s2
    80003aa8:	00001097          	auipc	ra,0x1
    80003aac:	c7c080e7          	jalr	-900(ra) # 80004724 <holdingsleep>
    80003ab0:	cd19                	beqz	a0,80003ace <iunlock+0x3c>
    80003ab2:	449c                	lw	a5,8(s1)
    80003ab4:	00f05d63          	blez	a5,80003ace <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ab8:	854a                	mv	a0,s2
    80003aba:	00001097          	auipc	ra,0x1
    80003abe:	c26080e7          	jalr	-986(ra) # 800046e0 <releasesleep>
}
    80003ac2:	60e2                	ld	ra,24(sp)
    80003ac4:	6442                	ld	s0,16(sp)
    80003ac6:	64a2                	ld	s1,8(sp)
    80003ac8:	6902                	ld	s2,0(sp)
    80003aca:	6105                	addi	sp,sp,32
    80003acc:	8082                	ret
    panic("iunlock");
    80003ace:	00005517          	auipc	a0,0x5
    80003ad2:	b8250513          	addi	a0,a0,-1150 # 80008650 <syscalls+0x198>
    80003ad6:	ffffd097          	auipc	ra,0xffffd
    80003ada:	a72080e7          	jalr	-1422(ra) # 80000548 <panic>

0000000080003ade <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ade:	7179                	addi	sp,sp,-48
    80003ae0:	f406                	sd	ra,40(sp)
    80003ae2:	f022                	sd	s0,32(sp)
    80003ae4:	ec26                	sd	s1,24(sp)
    80003ae6:	e84a                	sd	s2,16(sp)
    80003ae8:	e44e                	sd	s3,8(sp)
    80003aea:	e052                	sd	s4,0(sp)
    80003aec:	1800                	addi	s0,sp,48
    80003aee:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003af0:	05050493          	addi	s1,a0,80
    80003af4:	08050913          	addi	s2,a0,128
    80003af8:	a021                	j	80003b00 <itrunc+0x22>
    80003afa:	0491                	addi	s1,s1,4
    80003afc:	01248d63          	beq	s1,s2,80003b16 <itrunc+0x38>
    if(ip->addrs[i]){
    80003b00:	408c                	lw	a1,0(s1)
    80003b02:	dde5                	beqz	a1,80003afa <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b04:	0009a503          	lw	a0,0(s3)
    80003b08:	00000097          	auipc	ra,0x0
    80003b0c:	90c080e7          	jalr	-1780(ra) # 80003414 <bfree>
      ip->addrs[i] = 0;
    80003b10:	0004a023          	sw	zero,0(s1)
    80003b14:	b7dd                	j	80003afa <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b16:	0809a583          	lw	a1,128(s3)
    80003b1a:	e185                	bnez	a1,80003b3a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b1c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b20:	854e                	mv	a0,s3
    80003b22:	00000097          	auipc	ra,0x0
    80003b26:	de4080e7          	jalr	-540(ra) # 80003906 <iupdate>
}
    80003b2a:	70a2                	ld	ra,40(sp)
    80003b2c:	7402                	ld	s0,32(sp)
    80003b2e:	64e2                	ld	s1,24(sp)
    80003b30:	6942                	ld	s2,16(sp)
    80003b32:	69a2                	ld	s3,8(sp)
    80003b34:	6a02                	ld	s4,0(sp)
    80003b36:	6145                	addi	sp,sp,48
    80003b38:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b3a:	0009a503          	lw	a0,0(s3)
    80003b3e:	fffff097          	auipc	ra,0xfffff
    80003b42:	690080e7          	jalr	1680(ra) # 800031ce <bread>
    80003b46:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b48:	05850493          	addi	s1,a0,88
    80003b4c:	45850913          	addi	s2,a0,1112
    80003b50:	a811                	j	80003b64 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003b52:	0009a503          	lw	a0,0(s3)
    80003b56:	00000097          	auipc	ra,0x0
    80003b5a:	8be080e7          	jalr	-1858(ra) # 80003414 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003b5e:	0491                	addi	s1,s1,4
    80003b60:	01248563          	beq	s1,s2,80003b6a <itrunc+0x8c>
      if(a[j])
    80003b64:	408c                	lw	a1,0(s1)
    80003b66:	dde5                	beqz	a1,80003b5e <itrunc+0x80>
    80003b68:	b7ed                	j	80003b52 <itrunc+0x74>
    brelse(bp);
    80003b6a:	8552                	mv	a0,s4
    80003b6c:	fffff097          	auipc	ra,0xfffff
    80003b70:	792080e7          	jalr	1938(ra) # 800032fe <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b74:	0809a583          	lw	a1,128(s3)
    80003b78:	0009a503          	lw	a0,0(s3)
    80003b7c:	00000097          	auipc	ra,0x0
    80003b80:	898080e7          	jalr	-1896(ra) # 80003414 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b84:	0809a023          	sw	zero,128(s3)
    80003b88:	bf51                	j	80003b1c <itrunc+0x3e>

0000000080003b8a <iput>:
{
    80003b8a:	1101                	addi	sp,sp,-32
    80003b8c:	ec06                	sd	ra,24(sp)
    80003b8e:	e822                	sd	s0,16(sp)
    80003b90:	e426                	sd	s1,8(sp)
    80003b92:	e04a                	sd	s2,0(sp)
    80003b94:	1000                	addi	s0,sp,32
    80003b96:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b98:	0001c517          	auipc	a0,0x1c
    80003b9c:	4c850513          	addi	a0,a0,1224 # 80020060 <icache>
    80003ba0:	ffffd097          	auipc	ra,0xffffd
    80003ba4:	070080e7          	jalr	112(ra) # 80000c10 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ba8:	4498                	lw	a4,8(s1)
    80003baa:	4785                	li	a5,1
    80003bac:	02f70363          	beq	a4,a5,80003bd2 <iput+0x48>
  ip->ref--;
    80003bb0:	449c                	lw	a5,8(s1)
    80003bb2:	37fd                	addiw	a5,a5,-1
    80003bb4:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003bb6:	0001c517          	auipc	a0,0x1c
    80003bba:	4aa50513          	addi	a0,a0,1194 # 80020060 <icache>
    80003bbe:	ffffd097          	auipc	ra,0xffffd
    80003bc2:	106080e7          	jalr	262(ra) # 80000cc4 <release>
}
    80003bc6:	60e2                	ld	ra,24(sp)
    80003bc8:	6442                	ld	s0,16(sp)
    80003bca:	64a2                	ld	s1,8(sp)
    80003bcc:	6902                	ld	s2,0(sp)
    80003bce:	6105                	addi	sp,sp,32
    80003bd0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bd2:	40bc                	lw	a5,64(s1)
    80003bd4:	dff1                	beqz	a5,80003bb0 <iput+0x26>
    80003bd6:	04a49783          	lh	a5,74(s1)
    80003bda:	fbf9                	bnez	a5,80003bb0 <iput+0x26>
    acquiresleep(&ip->lock);
    80003bdc:	01048913          	addi	s2,s1,16
    80003be0:	854a                	mv	a0,s2
    80003be2:	00001097          	auipc	ra,0x1
    80003be6:	aa8080e7          	jalr	-1368(ra) # 8000468a <acquiresleep>
    release(&icache.lock);
    80003bea:	0001c517          	auipc	a0,0x1c
    80003bee:	47650513          	addi	a0,a0,1142 # 80020060 <icache>
    80003bf2:	ffffd097          	auipc	ra,0xffffd
    80003bf6:	0d2080e7          	jalr	210(ra) # 80000cc4 <release>
    itrunc(ip);
    80003bfa:	8526                	mv	a0,s1
    80003bfc:	00000097          	auipc	ra,0x0
    80003c00:	ee2080e7          	jalr	-286(ra) # 80003ade <itrunc>
    ip->type = 0;
    80003c04:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	cfc080e7          	jalr	-772(ra) # 80003906 <iupdate>
    ip->valid = 0;
    80003c12:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c16:	854a                	mv	a0,s2
    80003c18:	00001097          	auipc	ra,0x1
    80003c1c:	ac8080e7          	jalr	-1336(ra) # 800046e0 <releasesleep>
    acquire(&icache.lock);
    80003c20:	0001c517          	auipc	a0,0x1c
    80003c24:	44050513          	addi	a0,a0,1088 # 80020060 <icache>
    80003c28:	ffffd097          	auipc	ra,0xffffd
    80003c2c:	fe8080e7          	jalr	-24(ra) # 80000c10 <acquire>
    80003c30:	b741                	j	80003bb0 <iput+0x26>

0000000080003c32 <iunlockput>:
{
    80003c32:	1101                	addi	sp,sp,-32
    80003c34:	ec06                	sd	ra,24(sp)
    80003c36:	e822                	sd	s0,16(sp)
    80003c38:	e426                	sd	s1,8(sp)
    80003c3a:	1000                	addi	s0,sp,32
    80003c3c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c3e:	00000097          	auipc	ra,0x0
    80003c42:	e54080e7          	jalr	-428(ra) # 80003a92 <iunlock>
  iput(ip);
    80003c46:	8526                	mv	a0,s1
    80003c48:	00000097          	auipc	ra,0x0
    80003c4c:	f42080e7          	jalr	-190(ra) # 80003b8a <iput>
}
    80003c50:	60e2                	ld	ra,24(sp)
    80003c52:	6442                	ld	s0,16(sp)
    80003c54:	64a2                	ld	s1,8(sp)
    80003c56:	6105                	addi	sp,sp,32
    80003c58:	8082                	ret

0000000080003c5a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c5a:	1141                	addi	sp,sp,-16
    80003c5c:	e422                	sd	s0,8(sp)
    80003c5e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c60:	411c                	lw	a5,0(a0)
    80003c62:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c64:	415c                	lw	a5,4(a0)
    80003c66:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c68:	04451783          	lh	a5,68(a0)
    80003c6c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c70:	04a51783          	lh	a5,74(a0)
    80003c74:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c78:	04c56783          	lwu	a5,76(a0)
    80003c7c:	e99c                	sd	a5,16(a1)
}
    80003c7e:	6422                	ld	s0,8(sp)
    80003c80:	0141                	addi	sp,sp,16
    80003c82:	8082                	ret

0000000080003c84 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c84:	457c                	lw	a5,76(a0)
    80003c86:	0ed7e863          	bltu	a5,a3,80003d76 <readi+0xf2>
{
    80003c8a:	7159                	addi	sp,sp,-112
    80003c8c:	f486                	sd	ra,104(sp)
    80003c8e:	f0a2                	sd	s0,96(sp)
    80003c90:	eca6                	sd	s1,88(sp)
    80003c92:	e8ca                	sd	s2,80(sp)
    80003c94:	e4ce                	sd	s3,72(sp)
    80003c96:	e0d2                	sd	s4,64(sp)
    80003c98:	fc56                	sd	s5,56(sp)
    80003c9a:	f85a                	sd	s6,48(sp)
    80003c9c:	f45e                	sd	s7,40(sp)
    80003c9e:	f062                	sd	s8,32(sp)
    80003ca0:	ec66                	sd	s9,24(sp)
    80003ca2:	e86a                	sd	s10,16(sp)
    80003ca4:	e46e                	sd	s11,8(sp)
    80003ca6:	1880                	addi	s0,sp,112
    80003ca8:	8baa                	mv	s7,a0
    80003caa:	8c2e                	mv	s8,a1
    80003cac:	8ab2                	mv	s5,a2
    80003cae:	84b6                	mv	s1,a3
    80003cb0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cb2:	9f35                	addw	a4,a4,a3
    return 0;
    80003cb4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cb6:	08d76f63          	bltu	a4,a3,80003d54 <readi+0xd0>
  if(off + n > ip->size)
    80003cba:	00e7f463          	bgeu	a5,a4,80003cc2 <readi+0x3e>
    n = ip->size - off;
    80003cbe:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc2:	0a0b0863          	beqz	s6,80003d72 <readi+0xee>
    80003cc6:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cc8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ccc:	5cfd                	li	s9,-1
    80003cce:	a82d                	j	80003d08 <readi+0x84>
    80003cd0:	020a1d93          	slli	s11,s4,0x20
    80003cd4:	020ddd93          	srli	s11,s11,0x20
    80003cd8:	05890613          	addi	a2,s2,88
    80003cdc:	86ee                	mv	a3,s11
    80003cde:	963a                	add	a2,a2,a4
    80003ce0:	85d6                	mv	a1,s5
    80003ce2:	8562                	mv	a0,s8
    80003ce4:	fffff097          	auipc	ra,0xfffff
    80003ce8:	b2e080e7          	jalr	-1234(ra) # 80002812 <either_copyout>
    80003cec:	05950d63          	beq	a0,s9,80003d46 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003cf0:	854a                	mv	a0,s2
    80003cf2:	fffff097          	auipc	ra,0xfffff
    80003cf6:	60c080e7          	jalr	1548(ra) # 800032fe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cfa:	013a09bb          	addw	s3,s4,s3
    80003cfe:	009a04bb          	addw	s1,s4,s1
    80003d02:	9aee                	add	s5,s5,s11
    80003d04:	0569f663          	bgeu	s3,s6,80003d50 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d08:	000ba903          	lw	s2,0(s7)
    80003d0c:	00a4d59b          	srliw	a1,s1,0xa
    80003d10:	855e                	mv	a0,s7
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	8b0080e7          	jalr	-1872(ra) # 800035c2 <bmap>
    80003d1a:	0005059b          	sext.w	a1,a0
    80003d1e:	854a                	mv	a0,s2
    80003d20:	fffff097          	auipc	ra,0xfffff
    80003d24:	4ae080e7          	jalr	1198(ra) # 800031ce <bread>
    80003d28:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d2a:	3ff4f713          	andi	a4,s1,1023
    80003d2e:	40ed07bb          	subw	a5,s10,a4
    80003d32:	413b06bb          	subw	a3,s6,s3
    80003d36:	8a3e                	mv	s4,a5
    80003d38:	2781                	sext.w	a5,a5
    80003d3a:	0006861b          	sext.w	a2,a3
    80003d3e:	f8f679e3          	bgeu	a2,a5,80003cd0 <readi+0x4c>
    80003d42:	8a36                	mv	s4,a3
    80003d44:	b771                	j	80003cd0 <readi+0x4c>
      brelse(bp);
    80003d46:	854a                	mv	a0,s2
    80003d48:	fffff097          	auipc	ra,0xfffff
    80003d4c:	5b6080e7          	jalr	1462(ra) # 800032fe <brelse>
  }
  return tot;
    80003d50:	0009851b          	sext.w	a0,s3
}
    80003d54:	70a6                	ld	ra,104(sp)
    80003d56:	7406                	ld	s0,96(sp)
    80003d58:	64e6                	ld	s1,88(sp)
    80003d5a:	6946                	ld	s2,80(sp)
    80003d5c:	69a6                	ld	s3,72(sp)
    80003d5e:	6a06                	ld	s4,64(sp)
    80003d60:	7ae2                	ld	s5,56(sp)
    80003d62:	7b42                	ld	s6,48(sp)
    80003d64:	7ba2                	ld	s7,40(sp)
    80003d66:	7c02                	ld	s8,32(sp)
    80003d68:	6ce2                	ld	s9,24(sp)
    80003d6a:	6d42                	ld	s10,16(sp)
    80003d6c:	6da2                	ld	s11,8(sp)
    80003d6e:	6165                	addi	sp,sp,112
    80003d70:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d72:	89da                	mv	s3,s6
    80003d74:	bff1                	j	80003d50 <readi+0xcc>
    return 0;
    80003d76:	4501                	li	a0,0
}
    80003d78:	8082                	ret

0000000080003d7a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d7a:	457c                	lw	a5,76(a0)
    80003d7c:	10d7e663          	bltu	a5,a3,80003e88 <writei+0x10e>
{
    80003d80:	7159                	addi	sp,sp,-112
    80003d82:	f486                	sd	ra,104(sp)
    80003d84:	f0a2                	sd	s0,96(sp)
    80003d86:	eca6                	sd	s1,88(sp)
    80003d88:	e8ca                	sd	s2,80(sp)
    80003d8a:	e4ce                	sd	s3,72(sp)
    80003d8c:	e0d2                	sd	s4,64(sp)
    80003d8e:	fc56                	sd	s5,56(sp)
    80003d90:	f85a                	sd	s6,48(sp)
    80003d92:	f45e                	sd	s7,40(sp)
    80003d94:	f062                	sd	s8,32(sp)
    80003d96:	ec66                	sd	s9,24(sp)
    80003d98:	e86a                	sd	s10,16(sp)
    80003d9a:	e46e                	sd	s11,8(sp)
    80003d9c:	1880                	addi	s0,sp,112
    80003d9e:	8baa                	mv	s7,a0
    80003da0:	8c2e                	mv	s8,a1
    80003da2:	8ab2                	mv	s5,a2
    80003da4:	8936                	mv	s2,a3
    80003da6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003da8:	00e687bb          	addw	a5,a3,a4
    80003dac:	0ed7e063          	bltu	a5,a3,80003e8c <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003db0:	00043737          	lui	a4,0x43
    80003db4:	0cf76e63          	bltu	a4,a5,80003e90 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003db8:	0a0b0763          	beqz	s6,80003e66 <writei+0xec>
    80003dbc:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dbe:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dc2:	5cfd                	li	s9,-1
    80003dc4:	a091                	j	80003e08 <writei+0x8e>
    80003dc6:	02099d93          	slli	s11,s3,0x20
    80003dca:	020ddd93          	srli	s11,s11,0x20
    80003dce:	05848513          	addi	a0,s1,88
    80003dd2:	86ee                	mv	a3,s11
    80003dd4:	8656                	mv	a2,s5
    80003dd6:	85e2                	mv	a1,s8
    80003dd8:	953a                	add	a0,a0,a4
    80003dda:	fffff097          	auipc	ra,0xfffff
    80003dde:	a8e080e7          	jalr	-1394(ra) # 80002868 <either_copyin>
    80003de2:	07950263          	beq	a0,s9,80003e46 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003de6:	8526                	mv	a0,s1
    80003de8:	00000097          	auipc	ra,0x0
    80003dec:	77a080e7          	jalr	1914(ra) # 80004562 <log_write>
    brelse(bp);
    80003df0:	8526                	mv	a0,s1
    80003df2:	fffff097          	auipc	ra,0xfffff
    80003df6:	50c080e7          	jalr	1292(ra) # 800032fe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dfa:	01498a3b          	addw	s4,s3,s4
    80003dfe:	0129893b          	addw	s2,s3,s2
    80003e02:	9aee                	add	s5,s5,s11
    80003e04:	056a7663          	bgeu	s4,s6,80003e50 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e08:	000ba483          	lw	s1,0(s7)
    80003e0c:	00a9559b          	srliw	a1,s2,0xa
    80003e10:	855e                	mv	a0,s7
    80003e12:	fffff097          	auipc	ra,0xfffff
    80003e16:	7b0080e7          	jalr	1968(ra) # 800035c2 <bmap>
    80003e1a:	0005059b          	sext.w	a1,a0
    80003e1e:	8526                	mv	a0,s1
    80003e20:	fffff097          	auipc	ra,0xfffff
    80003e24:	3ae080e7          	jalr	942(ra) # 800031ce <bread>
    80003e28:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e2a:	3ff97713          	andi	a4,s2,1023
    80003e2e:	40ed07bb          	subw	a5,s10,a4
    80003e32:	414b06bb          	subw	a3,s6,s4
    80003e36:	89be                	mv	s3,a5
    80003e38:	2781                	sext.w	a5,a5
    80003e3a:	0006861b          	sext.w	a2,a3
    80003e3e:	f8f674e3          	bgeu	a2,a5,80003dc6 <writei+0x4c>
    80003e42:	89b6                	mv	s3,a3
    80003e44:	b749                	j	80003dc6 <writei+0x4c>
      brelse(bp);
    80003e46:	8526                	mv	a0,s1
    80003e48:	fffff097          	auipc	ra,0xfffff
    80003e4c:	4b6080e7          	jalr	1206(ra) # 800032fe <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003e50:	04cba783          	lw	a5,76(s7)
    80003e54:	0127f463          	bgeu	a5,s2,80003e5c <writei+0xe2>
      ip->size = off;
    80003e58:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003e5c:	855e                	mv	a0,s7
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	aa8080e7          	jalr	-1368(ra) # 80003906 <iupdate>
  }

  return n;
    80003e66:	000b051b          	sext.w	a0,s6
}
    80003e6a:	70a6                	ld	ra,104(sp)
    80003e6c:	7406                	ld	s0,96(sp)
    80003e6e:	64e6                	ld	s1,88(sp)
    80003e70:	6946                	ld	s2,80(sp)
    80003e72:	69a6                	ld	s3,72(sp)
    80003e74:	6a06                	ld	s4,64(sp)
    80003e76:	7ae2                	ld	s5,56(sp)
    80003e78:	7b42                	ld	s6,48(sp)
    80003e7a:	7ba2                	ld	s7,40(sp)
    80003e7c:	7c02                	ld	s8,32(sp)
    80003e7e:	6ce2                	ld	s9,24(sp)
    80003e80:	6d42                	ld	s10,16(sp)
    80003e82:	6da2                	ld	s11,8(sp)
    80003e84:	6165                	addi	sp,sp,112
    80003e86:	8082                	ret
    return -1;
    80003e88:	557d                	li	a0,-1
}
    80003e8a:	8082                	ret
    return -1;
    80003e8c:	557d                	li	a0,-1
    80003e8e:	bff1                	j	80003e6a <writei+0xf0>
    return -1;
    80003e90:	557d                	li	a0,-1
    80003e92:	bfe1                	j	80003e6a <writei+0xf0>

0000000080003e94 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e94:	1141                	addi	sp,sp,-16
    80003e96:	e406                	sd	ra,8(sp)
    80003e98:	e022                	sd	s0,0(sp)
    80003e9a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e9c:	4639                	li	a2,14
    80003e9e:	ffffd097          	auipc	ra,0xffffd
    80003ea2:	f4a080e7          	jalr	-182(ra) # 80000de8 <strncmp>
}
    80003ea6:	60a2                	ld	ra,8(sp)
    80003ea8:	6402                	ld	s0,0(sp)
    80003eaa:	0141                	addi	sp,sp,16
    80003eac:	8082                	ret

0000000080003eae <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003eae:	7139                	addi	sp,sp,-64
    80003eb0:	fc06                	sd	ra,56(sp)
    80003eb2:	f822                	sd	s0,48(sp)
    80003eb4:	f426                	sd	s1,40(sp)
    80003eb6:	f04a                	sd	s2,32(sp)
    80003eb8:	ec4e                	sd	s3,24(sp)
    80003eba:	e852                	sd	s4,16(sp)
    80003ebc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ebe:	04451703          	lh	a4,68(a0)
    80003ec2:	4785                	li	a5,1
    80003ec4:	00f71a63          	bne	a4,a5,80003ed8 <dirlookup+0x2a>
    80003ec8:	892a                	mv	s2,a0
    80003eca:	89ae                	mv	s3,a1
    80003ecc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ece:	457c                	lw	a5,76(a0)
    80003ed0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ed2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ed4:	e79d                	bnez	a5,80003f02 <dirlookup+0x54>
    80003ed6:	a8a5                	j	80003f4e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ed8:	00004517          	auipc	a0,0x4
    80003edc:	78050513          	addi	a0,a0,1920 # 80008658 <syscalls+0x1a0>
    80003ee0:	ffffc097          	auipc	ra,0xffffc
    80003ee4:	668080e7          	jalr	1640(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003ee8:	00004517          	auipc	a0,0x4
    80003eec:	78850513          	addi	a0,a0,1928 # 80008670 <syscalls+0x1b8>
    80003ef0:	ffffc097          	auipc	ra,0xffffc
    80003ef4:	658080e7          	jalr	1624(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ef8:	24c1                	addiw	s1,s1,16
    80003efa:	04c92783          	lw	a5,76(s2)
    80003efe:	04f4f763          	bgeu	s1,a5,80003f4c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f02:	4741                	li	a4,16
    80003f04:	86a6                	mv	a3,s1
    80003f06:	fc040613          	addi	a2,s0,-64
    80003f0a:	4581                	li	a1,0
    80003f0c:	854a                	mv	a0,s2
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	d76080e7          	jalr	-650(ra) # 80003c84 <readi>
    80003f16:	47c1                	li	a5,16
    80003f18:	fcf518e3          	bne	a0,a5,80003ee8 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f1c:	fc045783          	lhu	a5,-64(s0)
    80003f20:	dfe1                	beqz	a5,80003ef8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f22:	fc240593          	addi	a1,s0,-62
    80003f26:	854e                	mv	a0,s3
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	f6c080e7          	jalr	-148(ra) # 80003e94 <namecmp>
    80003f30:	f561                	bnez	a0,80003ef8 <dirlookup+0x4a>
      if(poff)
    80003f32:	000a0463          	beqz	s4,80003f3a <dirlookup+0x8c>
        *poff = off;
    80003f36:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f3a:	fc045583          	lhu	a1,-64(s0)
    80003f3e:	00092503          	lw	a0,0(s2)
    80003f42:	fffff097          	auipc	ra,0xfffff
    80003f46:	75a080e7          	jalr	1882(ra) # 8000369c <iget>
    80003f4a:	a011                	j	80003f4e <dirlookup+0xa0>
  return 0;
    80003f4c:	4501                	li	a0,0
}
    80003f4e:	70e2                	ld	ra,56(sp)
    80003f50:	7442                	ld	s0,48(sp)
    80003f52:	74a2                	ld	s1,40(sp)
    80003f54:	7902                	ld	s2,32(sp)
    80003f56:	69e2                	ld	s3,24(sp)
    80003f58:	6a42                	ld	s4,16(sp)
    80003f5a:	6121                	addi	sp,sp,64
    80003f5c:	8082                	ret

0000000080003f5e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f5e:	711d                	addi	sp,sp,-96
    80003f60:	ec86                	sd	ra,88(sp)
    80003f62:	e8a2                	sd	s0,80(sp)
    80003f64:	e4a6                	sd	s1,72(sp)
    80003f66:	e0ca                	sd	s2,64(sp)
    80003f68:	fc4e                	sd	s3,56(sp)
    80003f6a:	f852                	sd	s4,48(sp)
    80003f6c:	f456                	sd	s5,40(sp)
    80003f6e:	f05a                	sd	s6,32(sp)
    80003f70:	ec5e                	sd	s7,24(sp)
    80003f72:	e862                	sd	s8,16(sp)
    80003f74:	e466                	sd	s9,8(sp)
    80003f76:	1080                	addi	s0,sp,96
    80003f78:	84aa                	mv	s1,a0
    80003f7a:	8b2e                	mv	s6,a1
    80003f7c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f7e:	00054703          	lbu	a4,0(a0)
    80003f82:	02f00793          	li	a5,47
    80003f86:	02f70363          	beq	a4,a5,80003fac <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f8a:	ffffe097          	auipc	ra,0xffffe
    80003f8e:	c46080e7          	jalr	-954(ra) # 80001bd0 <myproc>
    80003f92:	15053503          	ld	a0,336(a0)
    80003f96:	00000097          	auipc	ra,0x0
    80003f9a:	9fc080e7          	jalr	-1540(ra) # 80003992 <idup>
    80003f9e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003fa0:	02f00913          	li	s2,47
  len = path - s;
    80003fa4:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003fa6:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fa8:	4c05                	li	s8,1
    80003faa:	a865                	j	80004062 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fac:	4585                	li	a1,1
    80003fae:	4505                	li	a0,1
    80003fb0:	fffff097          	auipc	ra,0xfffff
    80003fb4:	6ec080e7          	jalr	1772(ra) # 8000369c <iget>
    80003fb8:	89aa                	mv	s3,a0
    80003fba:	b7dd                	j	80003fa0 <namex+0x42>
      iunlockput(ip);
    80003fbc:	854e                	mv	a0,s3
    80003fbe:	00000097          	auipc	ra,0x0
    80003fc2:	c74080e7          	jalr	-908(ra) # 80003c32 <iunlockput>
      return 0;
    80003fc6:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fc8:	854e                	mv	a0,s3
    80003fca:	60e6                	ld	ra,88(sp)
    80003fcc:	6446                	ld	s0,80(sp)
    80003fce:	64a6                	ld	s1,72(sp)
    80003fd0:	6906                	ld	s2,64(sp)
    80003fd2:	79e2                	ld	s3,56(sp)
    80003fd4:	7a42                	ld	s4,48(sp)
    80003fd6:	7aa2                	ld	s5,40(sp)
    80003fd8:	7b02                	ld	s6,32(sp)
    80003fda:	6be2                	ld	s7,24(sp)
    80003fdc:	6c42                	ld	s8,16(sp)
    80003fde:	6ca2                	ld	s9,8(sp)
    80003fe0:	6125                	addi	sp,sp,96
    80003fe2:	8082                	ret
      iunlock(ip);
    80003fe4:	854e                	mv	a0,s3
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	aac080e7          	jalr	-1364(ra) # 80003a92 <iunlock>
      return ip;
    80003fee:	bfe9                	j	80003fc8 <namex+0x6a>
      iunlockput(ip);
    80003ff0:	854e                	mv	a0,s3
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	c40080e7          	jalr	-960(ra) # 80003c32 <iunlockput>
      return 0;
    80003ffa:	89d2                	mv	s3,s4
    80003ffc:	b7f1                	j	80003fc8 <namex+0x6a>
  len = path - s;
    80003ffe:	40b48633          	sub	a2,s1,a1
    80004002:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004006:	094cd463          	bge	s9,s4,8000408e <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000400a:	4639                	li	a2,14
    8000400c:	8556                	mv	a0,s5
    8000400e:	ffffd097          	auipc	ra,0xffffd
    80004012:	d5e080e7          	jalr	-674(ra) # 80000d6c <memmove>
  while(*path == '/')
    80004016:	0004c783          	lbu	a5,0(s1)
    8000401a:	01279763          	bne	a5,s2,80004028 <namex+0xca>
    path++;
    8000401e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004020:	0004c783          	lbu	a5,0(s1)
    80004024:	ff278de3          	beq	a5,s2,8000401e <namex+0xc0>
    ilock(ip);
    80004028:	854e                	mv	a0,s3
    8000402a:	00000097          	auipc	ra,0x0
    8000402e:	9a6080e7          	jalr	-1626(ra) # 800039d0 <ilock>
    if(ip->type != T_DIR){
    80004032:	04499783          	lh	a5,68(s3)
    80004036:	f98793e3          	bne	a5,s8,80003fbc <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000403a:	000b0563          	beqz	s6,80004044 <namex+0xe6>
    8000403e:	0004c783          	lbu	a5,0(s1)
    80004042:	d3cd                	beqz	a5,80003fe4 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004044:	865e                	mv	a2,s7
    80004046:	85d6                	mv	a1,s5
    80004048:	854e                	mv	a0,s3
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	e64080e7          	jalr	-412(ra) # 80003eae <dirlookup>
    80004052:	8a2a                	mv	s4,a0
    80004054:	dd51                	beqz	a0,80003ff0 <namex+0x92>
    iunlockput(ip);
    80004056:	854e                	mv	a0,s3
    80004058:	00000097          	auipc	ra,0x0
    8000405c:	bda080e7          	jalr	-1062(ra) # 80003c32 <iunlockput>
    ip = next;
    80004060:	89d2                	mv	s3,s4
  while(*path == '/')
    80004062:	0004c783          	lbu	a5,0(s1)
    80004066:	05279763          	bne	a5,s2,800040b4 <namex+0x156>
    path++;
    8000406a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000406c:	0004c783          	lbu	a5,0(s1)
    80004070:	ff278de3          	beq	a5,s2,8000406a <namex+0x10c>
  if(*path == 0)
    80004074:	c79d                	beqz	a5,800040a2 <namex+0x144>
    path++;
    80004076:	85a6                	mv	a1,s1
  len = path - s;
    80004078:	8a5e                	mv	s4,s7
    8000407a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000407c:	01278963          	beq	a5,s2,8000408e <namex+0x130>
    80004080:	dfbd                	beqz	a5,80003ffe <namex+0xa0>
    path++;
    80004082:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004084:	0004c783          	lbu	a5,0(s1)
    80004088:	ff279ce3          	bne	a5,s2,80004080 <namex+0x122>
    8000408c:	bf8d                	j	80003ffe <namex+0xa0>
    memmove(name, s, len);
    8000408e:	2601                	sext.w	a2,a2
    80004090:	8556                	mv	a0,s5
    80004092:	ffffd097          	auipc	ra,0xffffd
    80004096:	cda080e7          	jalr	-806(ra) # 80000d6c <memmove>
    name[len] = 0;
    8000409a:	9a56                	add	s4,s4,s5
    8000409c:	000a0023          	sb	zero,0(s4)
    800040a0:	bf9d                	j	80004016 <namex+0xb8>
  if(nameiparent){
    800040a2:	f20b03e3          	beqz	s6,80003fc8 <namex+0x6a>
    iput(ip);
    800040a6:	854e                	mv	a0,s3
    800040a8:	00000097          	auipc	ra,0x0
    800040ac:	ae2080e7          	jalr	-1310(ra) # 80003b8a <iput>
    return 0;
    800040b0:	4981                	li	s3,0
    800040b2:	bf19                	j	80003fc8 <namex+0x6a>
  if(*path == 0)
    800040b4:	d7fd                	beqz	a5,800040a2 <namex+0x144>
  while(*path != '/' && *path != 0)
    800040b6:	0004c783          	lbu	a5,0(s1)
    800040ba:	85a6                	mv	a1,s1
    800040bc:	b7d1                	j	80004080 <namex+0x122>

00000000800040be <dirlink>:
{
    800040be:	7139                	addi	sp,sp,-64
    800040c0:	fc06                	sd	ra,56(sp)
    800040c2:	f822                	sd	s0,48(sp)
    800040c4:	f426                	sd	s1,40(sp)
    800040c6:	f04a                	sd	s2,32(sp)
    800040c8:	ec4e                	sd	s3,24(sp)
    800040ca:	e852                	sd	s4,16(sp)
    800040cc:	0080                	addi	s0,sp,64
    800040ce:	892a                	mv	s2,a0
    800040d0:	8a2e                	mv	s4,a1
    800040d2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040d4:	4601                	li	a2,0
    800040d6:	00000097          	auipc	ra,0x0
    800040da:	dd8080e7          	jalr	-552(ra) # 80003eae <dirlookup>
    800040de:	e93d                	bnez	a0,80004154 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e0:	04c92483          	lw	s1,76(s2)
    800040e4:	c49d                	beqz	s1,80004112 <dirlink+0x54>
    800040e6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040e8:	4741                	li	a4,16
    800040ea:	86a6                	mv	a3,s1
    800040ec:	fc040613          	addi	a2,s0,-64
    800040f0:	4581                	li	a1,0
    800040f2:	854a                	mv	a0,s2
    800040f4:	00000097          	auipc	ra,0x0
    800040f8:	b90080e7          	jalr	-1136(ra) # 80003c84 <readi>
    800040fc:	47c1                	li	a5,16
    800040fe:	06f51163          	bne	a0,a5,80004160 <dirlink+0xa2>
    if(de.inum == 0)
    80004102:	fc045783          	lhu	a5,-64(s0)
    80004106:	c791                	beqz	a5,80004112 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004108:	24c1                	addiw	s1,s1,16
    8000410a:	04c92783          	lw	a5,76(s2)
    8000410e:	fcf4ede3          	bltu	s1,a5,800040e8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004112:	4639                	li	a2,14
    80004114:	85d2                	mv	a1,s4
    80004116:	fc240513          	addi	a0,s0,-62
    8000411a:	ffffd097          	auipc	ra,0xffffd
    8000411e:	d0a080e7          	jalr	-758(ra) # 80000e24 <strncpy>
  de.inum = inum;
    80004122:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004126:	4741                	li	a4,16
    80004128:	86a6                	mv	a3,s1
    8000412a:	fc040613          	addi	a2,s0,-64
    8000412e:	4581                	li	a1,0
    80004130:	854a                	mv	a0,s2
    80004132:	00000097          	auipc	ra,0x0
    80004136:	c48080e7          	jalr	-952(ra) # 80003d7a <writei>
    8000413a:	872a                	mv	a4,a0
    8000413c:	47c1                	li	a5,16
  return 0;
    8000413e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004140:	02f71863          	bne	a4,a5,80004170 <dirlink+0xb2>
}
    80004144:	70e2                	ld	ra,56(sp)
    80004146:	7442                	ld	s0,48(sp)
    80004148:	74a2                	ld	s1,40(sp)
    8000414a:	7902                	ld	s2,32(sp)
    8000414c:	69e2                	ld	s3,24(sp)
    8000414e:	6a42                	ld	s4,16(sp)
    80004150:	6121                	addi	sp,sp,64
    80004152:	8082                	ret
    iput(ip);
    80004154:	00000097          	auipc	ra,0x0
    80004158:	a36080e7          	jalr	-1482(ra) # 80003b8a <iput>
    return -1;
    8000415c:	557d                	li	a0,-1
    8000415e:	b7dd                	j	80004144 <dirlink+0x86>
      panic("dirlink read");
    80004160:	00004517          	auipc	a0,0x4
    80004164:	52050513          	addi	a0,a0,1312 # 80008680 <syscalls+0x1c8>
    80004168:	ffffc097          	auipc	ra,0xffffc
    8000416c:	3e0080e7          	jalr	992(ra) # 80000548 <panic>
    panic("dirlink");
    80004170:	00004517          	auipc	a0,0x4
    80004174:	63050513          	addi	a0,a0,1584 # 800087a0 <syscalls+0x2e8>
    80004178:	ffffc097          	auipc	ra,0xffffc
    8000417c:	3d0080e7          	jalr	976(ra) # 80000548 <panic>

0000000080004180 <namei>:

struct inode*
namei(char *path)
{
    80004180:	1101                	addi	sp,sp,-32
    80004182:	ec06                	sd	ra,24(sp)
    80004184:	e822                	sd	s0,16(sp)
    80004186:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004188:	fe040613          	addi	a2,s0,-32
    8000418c:	4581                	li	a1,0
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	dd0080e7          	jalr	-560(ra) # 80003f5e <namex>
}
    80004196:	60e2                	ld	ra,24(sp)
    80004198:	6442                	ld	s0,16(sp)
    8000419a:	6105                	addi	sp,sp,32
    8000419c:	8082                	ret

000000008000419e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000419e:	1141                	addi	sp,sp,-16
    800041a0:	e406                	sd	ra,8(sp)
    800041a2:	e022                	sd	s0,0(sp)
    800041a4:	0800                	addi	s0,sp,16
    800041a6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041a8:	4585                	li	a1,1
    800041aa:	00000097          	auipc	ra,0x0
    800041ae:	db4080e7          	jalr	-588(ra) # 80003f5e <namex>
}
    800041b2:	60a2                	ld	ra,8(sp)
    800041b4:	6402                	ld	s0,0(sp)
    800041b6:	0141                	addi	sp,sp,16
    800041b8:	8082                	ret

00000000800041ba <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041ba:	1101                	addi	sp,sp,-32
    800041bc:	ec06                	sd	ra,24(sp)
    800041be:	e822                	sd	s0,16(sp)
    800041c0:	e426                	sd	s1,8(sp)
    800041c2:	e04a                	sd	s2,0(sp)
    800041c4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041c6:	0001e917          	auipc	s2,0x1e
    800041ca:	94290913          	addi	s2,s2,-1726 # 80021b08 <log>
    800041ce:	01892583          	lw	a1,24(s2)
    800041d2:	02892503          	lw	a0,40(s2)
    800041d6:	fffff097          	auipc	ra,0xfffff
    800041da:	ff8080e7          	jalr	-8(ra) # 800031ce <bread>
    800041de:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041e0:	02c92683          	lw	a3,44(s2)
    800041e4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041e6:	02d05763          	blez	a3,80004214 <write_head+0x5a>
    800041ea:	0001e797          	auipc	a5,0x1e
    800041ee:	94e78793          	addi	a5,a5,-1714 # 80021b38 <log+0x30>
    800041f2:	05c50713          	addi	a4,a0,92
    800041f6:	36fd                	addiw	a3,a3,-1
    800041f8:	1682                	slli	a3,a3,0x20
    800041fa:	9281                	srli	a3,a3,0x20
    800041fc:	068a                	slli	a3,a3,0x2
    800041fe:	0001e617          	auipc	a2,0x1e
    80004202:	93e60613          	addi	a2,a2,-1730 # 80021b3c <log+0x34>
    80004206:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004208:	4390                	lw	a2,0(a5)
    8000420a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000420c:	0791                	addi	a5,a5,4
    8000420e:	0711                	addi	a4,a4,4
    80004210:	fed79ce3          	bne	a5,a3,80004208 <write_head+0x4e>
  }
  bwrite(buf);
    80004214:	8526                	mv	a0,s1
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	0aa080e7          	jalr	170(ra) # 800032c0 <bwrite>
  brelse(buf);
    8000421e:	8526                	mv	a0,s1
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	0de080e7          	jalr	222(ra) # 800032fe <brelse>
}
    80004228:	60e2                	ld	ra,24(sp)
    8000422a:	6442                	ld	s0,16(sp)
    8000422c:	64a2                	ld	s1,8(sp)
    8000422e:	6902                	ld	s2,0(sp)
    80004230:	6105                	addi	sp,sp,32
    80004232:	8082                	ret

0000000080004234 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004234:	0001e797          	auipc	a5,0x1e
    80004238:	9007a783          	lw	a5,-1792(a5) # 80021b34 <log+0x2c>
    8000423c:	0af05663          	blez	a5,800042e8 <install_trans+0xb4>
{
    80004240:	7139                	addi	sp,sp,-64
    80004242:	fc06                	sd	ra,56(sp)
    80004244:	f822                	sd	s0,48(sp)
    80004246:	f426                	sd	s1,40(sp)
    80004248:	f04a                	sd	s2,32(sp)
    8000424a:	ec4e                	sd	s3,24(sp)
    8000424c:	e852                	sd	s4,16(sp)
    8000424e:	e456                	sd	s5,8(sp)
    80004250:	0080                	addi	s0,sp,64
    80004252:	0001ea97          	auipc	s5,0x1e
    80004256:	8e6a8a93          	addi	s5,s5,-1818 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000425c:	0001e997          	auipc	s3,0x1e
    80004260:	8ac98993          	addi	s3,s3,-1876 # 80021b08 <log>
    80004264:	0189a583          	lw	a1,24(s3)
    80004268:	014585bb          	addw	a1,a1,s4
    8000426c:	2585                	addiw	a1,a1,1
    8000426e:	0289a503          	lw	a0,40(s3)
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	f5c080e7          	jalr	-164(ra) # 800031ce <bread>
    8000427a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000427c:	000aa583          	lw	a1,0(s5)
    80004280:	0289a503          	lw	a0,40(s3)
    80004284:	fffff097          	auipc	ra,0xfffff
    80004288:	f4a080e7          	jalr	-182(ra) # 800031ce <bread>
    8000428c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000428e:	40000613          	li	a2,1024
    80004292:	05890593          	addi	a1,s2,88
    80004296:	05850513          	addi	a0,a0,88
    8000429a:	ffffd097          	auipc	ra,0xffffd
    8000429e:	ad2080e7          	jalr	-1326(ra) # 80000d6c <memmove>
    bwrite(dbuf);  // write dst to disk
    800042a2:	8526                	mv	a0,s1
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	01c080e7          	jalr	28(ra) # 800032c0 <bwrite>
    bunpin(dbuf);
    800042ac:	8526                	mv	a0,s1
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	12a080e7          	jalr	298(ra) # 800033d8 <bunpin>
    brelse(lbuf);
    800042b6:	854a                	mv	a0,s2
    800042b8:	fffff097          	auipc	ra,0xfffff
    800042bc:	046080e7          	jalr	70(ra) # 800032fe <brelse>
    brelse(dbuf);
    800042c0:	8526                	mv	a0,s1
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	03c080e7          	jalr	60(ra) # 800032fe <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ca:	2a05                	addiw	s4,s4,1
    800042cc:	0a91                	addi	s5,s5,4
    800042ce:	02c9a783          	lw	a5,44(s3)
    800042d2:	f8fa49e3          	blt	s4,a5,80004264 <install_trans+0x30>
}
    800042d6:	70e2                	ld	ra,56(sp)
    800042d8:	7442                	ld	s0,48(sp)
    800042da:	74a2                	ld	s1,40(sp)
    800042dc:	7902                	ld	s2,32(sp)
    800042de:	69e2                	ld	s3,24(sp)
    800042e0:	6a42                	ld	s4,16(sp)
    800042e2:	6aa2                	ld	s5,8(sp)
    800042e4:	6121                	addi	sp,sp,64
    800042e6:	8082                	ret
    800042e8:	8082                	ret

00000000800042ea <initlog>:
{
    800042ea:	7179                	addi	sp,sp,-48
    800042ec:	f406                	sd	ra,40(sp)
    800042ee:	f022                	sd	s0,32(sp)
    800042f0:	ec26                	sd	s1,24(sp)
    800042f2:	e84a                	sd	s2,16(sp)
    800042f4:	e44e                	sd	s3,8(sp)
    800042f6:	1800                	addi	s0,sp,48
    800042f8:	892a                	mv	s2,a0
    800042fa:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042fc:	0001e497          	auipc	s1,0x1e
    80004300:	80c48493          	addi	s1,s1,-2036 # 80021b08 <log>
    80004304:	00004597          	auipc	a1,0x4
    80004308:	38c58593          	addi	a1,a1,908 # 80008690 <syscalls+0x1d8>
    8000430c:	8526                	mv	a0,s1
    8000430e:	ffffd097          	auipc	ra,0xffffd
    80004312:	872080e7          	jalr	-1934(ra) # 80000b80 <initlock>
  log.start = sb->logstart;
    80004316:	0149a583          	lw	a1,20(s3)
    8000431a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000431c:	0109a783          	lw	a5,16(s3)
    80004320:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004322:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004326:	854a                	mv	a0,s2
    80004328:	fffff097          	auipc	ra,0xfffff
    8000432c:	ea6080e7          	jalr	-346(ra) # 800031ce <bread>
  log.lh.n = lh->n;
    80004330:	4d3c                	lw	a5,88(a0)
    80004332:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004334:	02f05563          	blez	a5,8000435e <initlog+0x74>
    80004338:	05c50713          	addi	a4,a0,92
    8000433c:	0001d697          	auipc	a3,0x1d
    80004340:	7fc68693          	addi	a3,a3,2044 # 80021b38 <log+0x30>
    80004344:	37fd                	addiw	a5,a5,-1
    80004346:	1782                	slli	a5,a5,0x20
    80004348:	9381                	srli	a5,a5,0x20
    8000434a:	078a                	slli	a5,a5,0x2
    8000434c:	06050613          	addi	a2,a0,96
    80004350:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004352:	4310                	lw	a2,0(a4)
    80004354:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004356:	0711                	addi	a4,a4,4
    80004358:	0691                	addi	a3,a3,4
    8000435a:	fef71ce3          	bne	a4,a5,80004352 <initlog+0x68>
  brelse(buf);
    8000435e:	fffff097          	auipc	ra,0xfffff
    80004362:	fa0080e7          	jalr	-96(ra) # 800032fe <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004366:	00000097          	auipc	ra,0x0
    8000436a:	ece080e7          	jalr	-306(ra) # 80004234 <install_trans>
  log.lh.n = 0;
    8000436e:	0001d797          	auipc	a5,0x1d
    80004372:	7c07a323          	sw	zero,1990(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    80004376:	00000097          	auipc	ra,0x0
    8000437a:	e44080e7          	jalr	-444(ra) # 800041ba <write_head>
}
    8000437e:	70a2                	ld	ra,40(sp)
    80004380:	7402                	ld	s0,32(sp)
    80004382:	64e2                	ld	s1,24(sp)
    80004384:	6942                	ld	s2,16(sp)
    80004386:	69a2                	ld	s3,8(sp)
    80004388:	6145                	addi	sp,sp,48
    8000438a:	8082                	ret

000000008000438c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000438c:	1101                	addi	sp,sp,-32
    8000438e:	ec06                	sd	ra,24(sp)
    80004390:	e822                	sd	s0,16(sp)
    80004392:	e426                	sd	s1,8(sp)
    80004394:	e04a                	sd	s2,0(sp)
    80004396:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004398:	0001d517          	auipc	a0,0x1d
    8000439c:	77050513          	addi	a0,a0,1904 # 80021b08 <log>
    800043a0:	ffffd097          	auipc	ra,0xffffd
    800043a4:	870080e7          	jalr	-1936(ra) # 80000c10 <acquire>
  while(1){
    if(log.committing){
    800043a8:	0001d497          	auipc	s1,0x1d
    800043ac:	76048493          	addi	s1,s1,1888 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043b0:	4979                	li	s2,30
    800043b2:	a039                	j	800043c0 <begin_op+0x34>
      sleep(&log, &log.lock);
    800043b4:	85a6                	mv	a1,s1
    800043b6:	8526                	mv	a0,s1
    800043b8:	ffffe097          	auipc	ra,0xffffe
    800043bc:	1f8080e7          	jalr	504(ra) # 800025b0 <sleep>
    if(log.committing){
    800043c0:	50dc                	lw	a5,36(s1)
    800043c2:	fbed                	bnez	a5,800043b4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043c4:	509c                	lw	a5,32(s1)
    800043c6:	0017871b          	addiw	a4,a5,1
    800043ca:	0007069b          	sext.w	a3,a4
    800043ce:	0027179b          	slliw	a5,a4,0x2
    800043d2:	9fb9                	addw	a5,a5,a4
    800043d4:	0017979b          	slliw	a5,a5,0x1
    800043d8:	54d8                	lw	a4,44(s1)
    800043da:	9fb9                	addw	a5,a5,a4
    800043dc:	00f95963          	bge	s2,a5,800043ee <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043e0:	85a6                	mv	a1,s1
    800043e2:	8526                	mv	a0,s1
    800043e4:	ffffe097          	auipc	ra,0xffffe
    800043e8:	1cc080e7          	jalr	460(ra) # 800025b0 <sleep>
    800043ec:	bfd1                	j	800043c0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043ee:	0001d517          	auipc	a0,0x1d
    800043f2:	71a50513          	addi	a0,a0,1818 # 80021b08 <log>
    800043f6:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043f8:	ffffd097          	auipc	ra,0xffffd
    800043fc:	8cc080e7          	jalr	-1844(ra) # 80000cc4 <release>
      break;
    }
  }
}
    80004400:	60e2                	ld	ra,24(sp)
    80004402:	6442                	ld	s0,16(sp)
    80004404:	64a2                	ld	s1,8(sp)
    80004406:	6902                	ld	s2,0(sp)
    80004408:	6105                	addi	sp,sp,32
    8000440a:	8082                	ret

000000008000440c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000440c:	7139                	addi	sp,sp,-64
    8000440e:	fc06                	sd	ra,56(sp)
    80004410:	f822                	sd	s0,48(sp)
    80004412:	f426                	sd	s1,40(sp)
    80004414:	f04a                	sd	s2,32(sp)
    80004416:	ec4e                	sd	s3,24(sp)
    80004418:	e852                	sd	s4,16(sp)
    8000441a:	e456                	sd	s5,8(sp)
    8000441c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000441e:	0001d497          	auipc	s1,0x1d
    80004422:	6ea48493          	addi	s1,s1,1770 # 80021b08 <log>
    80004426:	8526                	mv	a0,s1
    80004428:	ffffc097          	auipc	ra,0xffffc
    8000442c:	7e8080e7          	jalr	2024(ra) # 80000c10 <acquire>
  log.outstanding -= 1;
    80004430:	509c                	lw	a5,32(s1)
    80004432:	37fd                	addiw	a5,a5,-1
    80004434:	0007891b          	sext.w	s2,a5
    80004438:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000443a:	50dc                	lw	a5,36(s1)
    8000443c:	efb9                	bnez	a5,8000449a <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000443e:	06091663          	bnez	s2,800044aa <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004442:	0001d497          	auipc	s1,0x1d
    80004446:	6c648493          	addi	s1,s1,1734 # 80021b08 <log>
    8000444a:	4785                	li	a5,1
    8000444c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000444e:	8526                	mv	a0,s1
    80004450:	ffffd097          	auipc	ra,0xffffd
    80004454:	874080e7          	jalr	-1932(ra) # 80000cc4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004458:	54dc                	lw	a5,44(s1)
    8000445a:	06f04763          	bgtz	a5,800044c8 <end_op+0xbc>
    acquire(&log.lock);
    8000445e:	0001d497          	auipc	s1,0x1d
    80004462:	6aa48493          	addi	s1,s1,1706 # 80021b08 <log>
    80004466:	8526                	mv	a0,s1
    80004468:	ffffc097          	auipc	ra,0xffffc
    8000446c:	7a8080e7          	jalr	1960(ra) # 80000c10 <acquire>
    log.committing = 0;
    80004470:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004474:	8526                	mv	a0,s1
    80004476:	ffffe097          	auipc	ra,0xffffe
    8000447a:	2c0080e7          	jalr	704(ra) # 80002736 <wakeup>
    release(&log.lock);
    8000447e:	8526                	mv	a0,s1
    80004480:	ffffd097          	auipc	ra,0xffffd
    80004484:	844080e7          	jalr	-1980(ra) # 80000cc4 <release>
}
    80004488:	70e2                	ld	ra,56(sp)
    8000448a:	7442                	ld	s0,48(sp)
    8000448c:	74a2                	ld	s1,40(sp)
    8000448e:	7902                	ld	s2,32(sp)
    80004490:	69e2                	ld	s3,24(sp)
    80004492:	6a42                	ld	s4,16(sp)
    80004494:	6aa2                	ld	s5,8(sp)
    80004496:	6121                	addi	sp,sp,64
    80004498:	8082                	ret
    panic("log.committing");
    8000449a:	00004517          	auipc	a0,0x4
    8000449e:	1fe50513          	addi	a0,a0,510 # 80008698 <syscalls+0x1e0>
    800044a2:	ffffc097          	auipc	ra,0xffffc
    800044a6:	0a6080e7          	jalr	166(ra) # 80000548 <panic>
    wakeup(&log);
    800044aa:	0001d497          	auipc	s1,0x1d
    800044ae:	65e48493          	addi	s1,s1,1630 # 80021b08 <log>
    800044b2:	8526                	mv	a0,s1
    800044b4:	ffffe097          	auipc	ra,0xffffe
    800044b8:	282080e7          	jalr	642(ra) # 80002736 <wakeup>
  release(&log.lock);
    800044bc:	8526                	mv	a0,s1
    800044be:	ffffd097          	auipc	ra,0xffffd
    800044c2:	806080e7          	jalr	-2042(ra) # 80000cc4 <release>
  if(do_commit){
    800044c6:	b7c9                	j	80004488 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044c8:	0001da97          	auipc	s5,0x1d
    800044cc:	670a8a93          	addi	s5,s5,1648 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044d0:	0001da17          	auipc	s4,0x1d
    800044d4:	638a0a13          	addi	s4,s4,1592 # 80021b08 <log>
    800044d8:	018a2583          	lw	a1,24(s4)
    800044dc:	012585bb          	addw	a1,a1,s2
    800044e0:	2585                	addiw	a1,a1,1
    800044e2:	028a2503          	lw	a0,40(s4)
    800044e6:	fffff097          	auipc	ra,0xfffff
    800044ea:	ce8080e7          	jalr	-792(ra) # 800031ce <bread>
    800044ee:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044f0:	000aa583          	lw	a1,0(s5)
    800044f4:	028a2503          	lw	a0,40(s4)
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	cd6080e7          	jalr	-810(ra) # 800031ce <bread>
    80004500:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004502:	40000613          	li	a2,1024
    80004506:	05850593          	addi	a1,a0,88
    8000450a:	05848513          	addi	a0,s1,88
    8000450e:	ffffd097          	auipc	ra,0xffffd
    80004512:	85e080e7          	jalr	-1954(ra) # 80000d6c <memmove>
    bwrite(to);  // write the log
    80004516:	8526                	mv	a0,s1
    80004518:	fffff097          	auipc	ra,0xfffff
    8000451c:	da8080e7          	jalr	-600(ra) # 800032c0 <bwrite>
    brelse(from);
    80004520:	854e                	mv	a0,s3
    80004522:	fffff097          	auipc	ra,0xfffff
    80004526:	ddc080e7          	jalr	-548(ra) # 800032fe <brelse>
    brelse(to);
    8000452a:	8526                	mv	a0,s1
    8000452c:	fffff097          	auipc	ra,0xfffff
    80004530:	dd2080e7          	jalr	-558(ra) # 800032fe <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004534:	2905                	addiw	s2,s2,1
    80004536:	0a91                	addi	s5,s5,4
    80004538:	02ca2783          	lw	a5,44(s4)
    8000453c:	f8f94ee3          	blt	s2,a5,800044d8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004540:	00000097          	auipc	ra,0x0
    80004544:	c7a080e7          	jalr	-902(ra) # 800041ba <write_head>
    install_trans(); // Now install writes to home locations
    80004548:	00000097          	auipc	ra,0x0
    8000454c:	cec080e7          	jalr	-788(ra) # 80004234 <install_trans>
    log.lh.n = 0;
    80004550:	0001d797          	auipc	a5,0x1d
    80004554:	5e07a223          	sw	zero,1508(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004558:	00000097          	auipc	ra,0x0
    8000455c:	c62080e7          	jalr	-926(ra) # 800041ba <write_head>
    80004560:	bdfd                	j	8000445e <end_op+0x52>

0000000080004562 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004562:	1101                	addi	sp,sp,-32
    80004564:	ec06                	sd	ra,24(sp)
    80004566:	e822                	sd	s0,16(sp)
    80004568:	e426                	sd	s1,8(sp)
    8000456a:	e04a                	sd	s2,0(sp)
    8000456c:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000456e:	0001d717          	auipc	a4,0x1d
    80004572:	5c672703          	lw	a4,1478(a4) # 80021b34 <log+0x2c>
    80004576:	47f5                	li	a5,29
    80004578:	08e7c063          	blt	a5,a4,800045f8 <log_write+0x96>
    8000457c:	84aa                	mv	s1,a0
    8000457e:	0001d797          	auipc	a5,0x1d
    80004582:	5a67a783          	lw	a5,1446(a5) # 80021b24 <log+0x1c>
    80004586:	37fd                	addiw	a5,a5,-1
    80004588:	06f75863          	bge	a4,a5,800045f8 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000458c:	0001d797          	auipc	a5,0x1d
    80004590:	59c7a783          	lw	a5,1436(a5) # 80021b28 <log+0x20>
    80004594:	06f05a63          	blez	a5,80004608 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004598:	0001d917          	auipc	s2,0x1d
    8000459c:	57090913          	addi	s2,s2,1392 # 80021b08 <log>
    800045a0:	854a                	mv	a0,s2
    800045a2:	ffffc097          	auipc	ra,0xffffc
    800045a6:	66e080e7          	jalr	1646(ra) # 80000c10 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800045aa:	02c92603          	lw	a2,44(s2)
    800045ae:	06c05563          	blez	a2,80004618 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800045b2:	44cc                	lw	a1,12(s1)
    800045b4:	0001d717          	auipc	a4,0x1d
    800045b8:	58470713          	addi	a4,a4,1412 # 80021b38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045bc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800045be:	4314                	lw	a3,0(a4)
    800045c0:	04b68d63          	beq	a3,a1,8000461a <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800045c4:	2785                	addiw	a5,a5,1
    800045c6:	0711                	addi	a4,a4,4
    800045c8:	fec79be3          	bne	a5,a2,800045be <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045cc:	0621                	addi	a2,a2,8
    800045ce:	060a                	slli	a2,a2,0x2
    800045d0:	0001d797          	auipc	a5,0x1d
    800045d4:	53878793          	addi	a5,a5,1336 # 80021b08 <log>
    800045d8:	963e                	add	a2,a2,a5
    800045da:	44dc                	lw	a5,12(s1)
    800045dc:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045de:	8526                	mv	a0,s1
    800045e0:	fffff097          	auipc	ra,0xfffff
    800045e4:	dbc080e7          	jalr	-580(ra) # 8000339c <bpin>
    log.lh.n++;
    800045e8:	0001d717          	auipc	a4,0x1d
    800045ec:	52070713          	addi	a4,a4,1312 # 80021b08 <log>
    800045f0:	575c                	lw	a5,44(a4)
    800045f2:	2785                	addiw	a5,a5,1
    800045f4:	d75c                	sw	a5,44(a4)
    800045f6:	a83d                	j	80004634 <log_write+0xd2>
    panic("too big a transaction");
    800045f8:	00004517          	auipc	a0,0x4
    800045fc:	0b050513          	addi	a0,a0,176 # 800086a8 <syscalls+0x1f0>
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	f48080e7          	jalr	-184(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004608:	00004517          	auipc	a0,0x4
    8000460c:	0b850513          	addi	a0,a0,184 # 800086c0 <syscalls+0x208>
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	f38080e7          	jalr	-200(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004618:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000461a:	00878713          	addi	a4,a5,8
    8000461e:	00271693          	slli	a3,a4,0x2
    80004622:	0001d717          	auipc	a4,0x1d
    80004626:	4e670713          	addi	a4,a4,1254 # 80021b08 <log>
    8000462a:	9736                	add	a4,a4,a3
    8000462c:	44d4                	lw	a3,12(s1)
    8000462e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004630:	faf607e3          	beq	a2,a5,800045de <log_write+0x7c>
  }
  release(&log.lock);
    80004634:	0001d517          	auipc	a0,0x1d
    80004638:	4d450513          	addi	a0,a0,1236 # 80021b08 <log>
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	688080e7          	jalr	1672(ra) # 80000cc4 <release>
}
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6902                	ld	s2,0(sp)
    8000464c:	6105                	addi	sp,sp,32
    8000464e:	8082                	ret

0000000080004650 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004650:	1101                	addi	sp,sp,-32
    80004652:	ec06                	sd	ra,24(sp)
    80004654:	e822                	sd	s0,16(sp)
    80004656:	e426                	sd	s1,8(sp)
    80004658:	e04a                	sd	s2,0(sp)
    8000465a:	1000                	addi	s0,sp,32
    8000465c:	84aa                	mv	s1,a0
    8000465e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004660:	00004597          	auipc	a1,0x4
    80004664:	08058593          	addi	a1,a1,128 # 800086e0 <syscalls+0x228>
    80004668:	0521                	addi	a0,a0,8
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	516080e7          	jalr	1302(ra) # 80000b80 <initlock>
  lk->name = name;
    80004672:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004676:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000467a:	0204a423          	sw	zero,40(s1)
}
    8000467e:	60e2                	ld	ra,24(sp)
    80004680:	6442                	ld	s0,16(sp)
    80004682:	64a2                	ld	s1,8(sp)
    80004684:	6902                	ld	s2,0(sp)
    80004686:	6105                	addi	sp,sp,32
    80004688:	8082                	ret

000000008000468a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000468a:	1101                	addi	sp,sp,-32
    8000468c:	ec06                	sd	ra,24(sp)
    8000468e:	e822                	sd	s0,16(sp)
    80004690:	e426                	sd	s1,8(sp)
    80004692:	e04a                	sd	s2,0(sp)
    80004694:	1000                	addi	s0,sp,32
    80004696:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004698:	00850913          	addi	s2,a0,8
    8000469c:	854a                	mv	a0,s2
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	572080e7          	jalr	1394(ra) # 80000c10 <acquire>
  while (lk->locked) {
    800046a6:	409c                	lw	a5,0(s1)
    800046a8:	cb89                	beqz	a5,800046ba <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046aa:	85ca                	mv	a1,s2
    800046ac:	8526                	mv	a0,s1
    800046ae:	ffffe097          	auipc	ra,0xffffe
    800046b2:	f02080e7          	jalr	-254(ra) # 800025b0 <sleep>
  while (lk->locked) {
    800046b6:	409c                	lw	a5,0(s1)
    800046b8:	fbed                	bnez	a5,800046aa <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046ba:	4785                	li	a5,1
    800046bc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046be:	ffffd097          	auipc	ra,0xffffd
    800046c2:	512080e7          	jalr	1298(ra) # 80001bd0 <myproc>
    800046c6:	5d1c                	lw	a5,56(a0)
    800046c8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046ca:	854a                	mv	a0,s2
    800046cc:	ffffc097          	auipc	ra,0xffffc
    800046d0:	5f8080e7          	jalr	1528(ra) # 80000cc4 <release>
}
    800046d4:	60e2                	ld	ra,24(sp)
    800046d6:	6442                	ld	s0,16(sp)
    800046d8:	64a2                	ld	s1,8(sp)
    800046da:	6902                	ld	s2,0(sp)
    800046dc:	6105                	addi	sp,sp,32
    800046de:	8082                	ret

00000000800046e0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046e0:	1101                	addi	sp,sp,-32
    800046e2:	ec06                	sd	ra,24(sp)
    800046e4:	e822                	sd	s0,16(sp)
    800046e6:	e426                	sd	s1,8(sp)
    800046e8:	e04a                	sd	s2,0(sp)
    800046ea:	1000                	addi	s0,sp,32
    800046ec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ee:	00850913          	addi	s2,a0,8
    800046f2:	854a                	mv	a0,s2
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	51c080e7          	jalr	1308(ra) # 80000c10 <acquire>
  lk->locked = 0;
    800046fc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004700:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004704:	8526                	mv	a0,s1
    80004706:	ffffe097          	auipc	ra,0xffffe
    8000470a:	030080e7          	jalr	48(ra) # 80002736 <wakeup>
  release(&lk->lk);
    8000470e:	854a                	mv	a0,s2
    80004710:	ffffc097          	auipc	ra,0xffffc
    80004714:	5b4080e7          	jalr	1460(ra) # 80000cc4 <release>
}
    80004718:	60e2                	ld	ra,24(sp)
    8000471a:	6442                	ld	s0,16(sp)
    8000471c:	64a2                	ld	s1,8(sp)
    8000471e:	6902                	ld	s2,0(sp)
    80004720:	6105                	addi	sp,sp,32
    80004722:	8082                	ret

0000000080004724 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004724:	7179                	addi	sp,sp,-48
    80004726:	f406                	sd	ra,40(sp)
    80004728:	f022                	sd	s0,32(sp)
    8000472a:	ec26                	sd	s1,24(sp)
    8000472c:	e84a                	sd	s2,16(sp)
    8000472e:	e44e                	sd	s3,8(sp)
    80004730:	1800                	addi	s0,sp,48
    80004732:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004734:	00850913          	addi	s2,a0,8
    80004738:	854a                	mv	a0,s2
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	4d6080e7          	jalr	1238(ra) # 80000c10 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004742:	409c                	lw	a5,0(s1)
    80004744:	ef99                	bnez	a5,80004762 <holdingsleep+0x3e>
    80004746:	4481                	li	s1,0
  release(&lk->lk);
    80004748:	854a                	mv	a0,s2
    8000474a:	ffffc097          	auipc	ra,0xffffc
    8000474e:	57a080e7          	jalr	1402(ra) # 80000cc4 <release>
  return r;
}
    80004752:	8526                	mv	a0,s1
    80004754:	70a2                	ld	ra,40(sp)
    80004756:	7402                	ld	s0,32(sp)
    80004758:	64e2                	ld	s1,24(sp)
    8000475a:	6942                	ld	s2,16(sp)
    8000475c:	69a2                	ld	s3,8(sp)
    8000475e:	6145                	addi	sp,sp,48
    80004760:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004762:	0284a983          	lw	s3,40(s1)
    80004766:	ffffd097          	auipc	ra,0xffffd
    8000476a:	46a080e7          	jalr	1130(ra) # 80001bd0 <myproc>
    8000476e:	5d04                	lw	s1,56(a0)
    80004770:	413484b3          	sub	s1,s1,s3
    80004774:	0014b493          	seqz	s1,s1
    80004778:	bfc1                	j	80004748 <holdingsleep+0x24>

000000008000477a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000477a:	1141                	addi	sp,sp,-16
    8000477c:	e406                	sd	ra,8(sp)
    8000477e:	e022                	sd	s0,0(sp)
    80004780:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004782:	00004597          	auipc	a1,0x4
    80004786:	f6e58593          	addi	a1,a1,-146 # 800086f0 <syscalls+0x238>
    8000478a:	0001d517          	auipc	a0,0x1d
    8000478e:	4c650513          	addi	a0,a0,1222 # 80021c50 <ftable>
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	3ee080e7          	jalr	1006(ra) # 80000b80 <initlock>
}
    8000479a:	60a2                	ld	ra,8(sp)
    8000479c:	6402                	ld	s0,0(sp)
    8000479e:	0141                	addi	sp,sp,16
    800047a0:	8082                	ret

00000000800047a2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047a2:	1101                	addi	sp,sp,-32
    800047a4:	ec06                	sd	ra,24(sp)
    800047a6:	e822                	sd	s0,16(sp)
    800047a8:	e426                	sd	s1,8(sp)
    800047aa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047ac:	0001d517          	auipc	a0,0x1d
    800047b0:	4a450513          	addi	a0,a0,1188 # 80021c50 <ftable>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	45c080e7          	jalr	1116(ra) # 80000c10 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047bc:	0001d497          	auipc	s1,0x1d
    800047c0:	4ac48493          	addi	s1,s1,1196 # 80021c68 <ftable+0x18>
    800047c4:	0001e717          	auipc	a4,0x1e
    800047c8:	44470713          	addi	a4,a4,1092 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    800047cc:	40dc                	lw	a5,4(s1)
    800047ce:	cf99                	beqz	a5,800047ec <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047d0:	02848493          	addi	s1,s1,40
    800047d4:	fee49ce3          	bne	s1,a4,800047cc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047d8:	0001d517          	auipc	a0,0x1d
    800047dc:	47850513          	addi	a0,a0,1144 # 80021c50 <ftable>
    800047e0:	ffffc097          	auipc	ra,0xffffc
    800047e4:	4e4080e7          	jalr	1252(ra) # 80000cc4 <release>
  return 0;
    800047e8:	4481                	li	s1,0
    800047ea:	a819                	j	80004800 <filealloc+0x5e>
      f->ref = 1;
    800047ec:	4785                	li	a5,1
    800047ee:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047f0:	0001d517          	auipc	a0,0x1d
    800047f4:	46050513          	addi	a0,a0,1120 # 80021c50 <ftable>
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	4cc080e7          	jalr	1228(ra) # 80000cc4 <release>
}
    80004800:	8526                	mv	a0,s1
    80004802:	60e2                	ld	ra,24(sp)
    80004804:	6442                	ld	s0,16(sp)
    80004806:	64a2                	ld	s1,8(sp)
    80004808:	6105                	addi	sp,sp,32
    8000480a:	8082                	ret

000000008000480c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000480c:	1101                	addi	sp,sp,-32
    8000480e:	ec06                	sd	ra,24(sp)
    80004810:	e822                	sd	s0,16(sp)
    80004812:	e426                	sd	s1,8(sp)
    80004814:	1000                	addi	s0,sp,32
    80004816:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004818:	0001d517          	auipc	a0,0x1d
    8000481c:	43850513          	addi	a0,a0,1080 # 80021c50 <ftable>
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	3f0080e7          	jalr	1008(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    80004828:	40dc                	lw	a5,4(s1)
    8000482a:	02f05263          	blez	a5,8000484e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000482e:	2785                	addiw	a5,a5,1
    80004830:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004832:	0001d517          	auipc	a0,0x1d
    80004836:	41e50513          	addi	a0,a0,1054 # 80021c50 <ftable>
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	48a080e7          	jalr	1162(ra) # 80000cc4 <release>
  return f;
}
    80004842:	8526                	mv	a0,s1
    80004844:	60e2                	ld	ra,24(sp)
    80004846:	6442                	ld	s0,16(sp)
    80004848:	64a2                	ld	s1,8(sp)
    8000484a:	6105                	addi	sp,sp,32
    8000484c:	8082                	ret
    panic("filedup");
    8000484e:	00004517          	auipc	a0,0x4
    80004852:	eaa50513          	addi	a0,a0,-342 # 800086f8 <syscalls+0x240>
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	cf2080e7          	jalr	-782(ra) # 80000548 <panic>

000000008000485e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000485e:	7139                	addi	sp,sp,-64
    80004860:	fc06                	sd	ra,56(sp)
    80004862:	f822                	sd	s0,48(sp)
    80004864:	f426                	sd	s1,40(sp)
    80004866:	f04a                	sd	s2,32(sp)
    80004868:	ec4e                	sd	s3,24(sp)
    8000486a:	e852                	sd	s4,16(sp)
    8000486c:	e456                	sd	s5,8(sp)
    8000486e:	0080                	addi	s0,sp,64
    80004870:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004872:	0001d517          	auipc	a0,0x1d
    80004876:	3de50513          	addi	a0,a0,990 # 80021c50 <ftable>
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	396080e7          	jalr	918(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    80004882:	40dc                	lw	a5,4(s1)
    80004884:	06f05163          	blez	a5,800048e6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004888:	37fd                	addiw	a5,a5,-1
    8000488a:	0007871b          	sext.w	a4,a5
    8000488e:	c0dc                	sw	a5,4(s1)
    80004890:	06e04363          	bgtz	a4,800048f6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004894:	0004a903          	lw	s2,0(s1)
    80004898:	0094ca83          	lbu	s5,9(s1)
    8000489c:	0104ba03          	ld	s4,16(s1)
    800048a0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048a4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048a8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048ac:	0001d517          	auipc	a0,0x1d
    800048b0:	3a450513          	addi	a0,a0,932 # 80021c50 <ftable>
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	410080e7          	jalr	1040(ra) # 80000cc4 <release>

  if(ff.type == FD_PIPE){
    800048bc:	4785                	li	a5,1
    800048be:	04f90d63          	beq	s2,a5,80004918 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048c2:	3979                	addiw	s2,s2,-2
    800048c4:	4785                	li	a5,1
    800048c6:	0527e063          	bltu	a5,s2,80004906 <fileclose+0xa8>
    begin_op();
    800048ca:	00000097          	auipc	ra,0x0
    800048ce:	ac2080e7          	jalr	-1342(ra) # 8000438c <begin_op>
    iput(ff.ip);
    800048d2:	854e                	mv	a0,s3
    800048d4:	fffff097          	auipc	ra,0xfffff
    800048d8:	2b6080e7          	jalr	694(ra) # 80003b8a <iput>
    end_op();
    800048dc:	00000097          	auipc	ra,0x0
    800048e0:	b30080e7          	jalr	-1232(ra) # 8000440c <end_op>
    800048e4:	a00d                	j	80004906 <fileclose+0xa8>
    panic("fileclose");
    800048e6:	00004517          	auipc	a0,0x4
    800048ea:	e1a50513          	addi	a0,a0,-486 # 80008700 <syscalls+0x248>
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	c5a080e7          	jalr	-934(ra) # 80000548 <panic>
    release(&ftable.lock);
    800048f6:	0001d517          	auipc	a0,0x1d
    800048fa:	35a50513          	addi	a0,a0,858 # 80021c50 <ftable>
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	3c6080e7          	jalr	966(ra) # 80000cc4 <release>
  }
}
    80004906:	70e2                	ld	ra,56(sp)
    80004908:	7442                	ld	s0,48(sp)
    8000490a:	74a2                	ld	s1,40(sp)
    8000490c:	7902                	ld	s2,32(sp)
    8000490e:	69e2                	ld	s3,24(sp)
    80004910:	6a42                	ld	s4,16(sp)
    80004912:	6aa2                	ld	s5,8(sp)
    80004914:	6121                	addi	sp,sp,64
    80004916:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004918:	85d6                	mv	a1,s5
    8000491a:	8552                	mv	a0,s4
    8000491c:	00000097          	auipc	ra,0x0
    80004920:	372080e7          	jalr	882(ra) # 80004c8e <pipeclose>
    80004924:	b7cd                	j	80004906 <fileclose+0xa8>

0000000080004926 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004926:	715d                	addi	sp,sp,-80
    80004928:	e486                	sd	ra,72(sp)
    8000492a:	e0a2                	sd	s0,64(sp)
    8000492c:	fc26                	sd	s1,56(sp)
    8000492e:	f84a                	sd	s2,48(sp)
    80004930:	f44e                	sd	s3,40(sp)
    80004932:	0880                	addi	s0,sp,80
    80004934:	84aa                	mv	s1,a0
    80004936:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004938:	ffffd097          	auipc	ra,0xffffd
    8000493c:	298080e7          	jalr	664(ra) # 80001bd0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004940:	409c                	lw	a5,0(s1)
    80004942:	37f9                	addiw	a5,a5,-2
    80004944:	4705                	li	a4,1
    80004946:	04f76763          	bltu	a4,a5,80004994 <filestat+0x6e>
    8000494a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000494c:	6c88                	ld	a0,24(s1)
    8000494e:	fffff097          	auipc	ra,0xfffff
    80004952:	082080e7          	jalr	130(ra) # 800039d0 <ilock>
    stati(f->ip, &st);
    80004956:	fb840593          	addi	a1,s0,-72
    8000495a:	6c88                	ld	a0,24(s1)
    8000495c:	fffff097          	auipc	ra,0xfffff
    80004960:	2fe080e7          	jalr	766(ra) # 80003c5a <stati>
    iunlock(f->ip);
    80004964:	6c88                	ld	a0,24(s1)
    80004966:	fffff097          	auipc	ra,0xfffff
    8000496a:	12c080e7          	jalr	300(ra) # 80003a92 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000496e:	46e1                	li	a3,24
    80004970:	fb840613          	addi	a2,s0,-72
    80004974:	85ce                	mv	a1,s3
    80004976:	05093503          	ld	a0,80(s2)
    8000497a:	ffffd097          	auipc	ra,0xffffd
    8000497e:	f98080e7          	jalr	-104(ra) # 80001912 <copyout>
    80004982:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004986:	60a6                	ld	ra,72(sp)
    80004988:	6406                	ld	s0,64(sp)
    8000498a:	74e2                	ld	s1,56(sp)
    8000498c:	7942                	ld	s2,48(sp)
    8000498e:	79a2                	ld	s3,40(sp)
    80004990:	6161                	addi	sp,sp,80
    80004992:	8082                	ret
  return -1;
    80004994:	557d                	li	a0,-1
    80004996:	bfc5                	j	80004986 <filestat+0x60>

0000000080004998 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004998:	7179                	addi	sp,sp,-48
    8000499a:	f406                	sd	ra,40(sp)
    8000499c:	f022                	sd	s0,32(sp)
    8000499e:	ec26                	sd	s1,24(sp)
    800049a0:	e84a                	sd	s2,16(sp)
    800049a2:	e44e                	sd	s3,8(sp)
    800049a4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049a6:	00854783          	lbu	a5,8(a0)
    800049aa:	c3d5                	beqz	a5,80004a4e <fileread+0xb6>
    800049ac:	84aa                	mv	s1,a0
    800049ae:	89ae                	mv	s3,a1
    800049b0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049b2:	411c                	lw	a5,0(a0)
    800049b4:	4705                	li	a4,1
    800049b6:	04e78963          	beq	a5,a4,80004a08 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049ba:	470d                	li	a4,3
    800049bc:	04e78d63          	beq	a5,a4,80004a16 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800049c0:	4709                	li	a4,2
    800049c2:	06e79e63          	bne	a5,a4,80004a3e <fileread+0xa6>
    ilock(f->ip);
    800049c6:	6d08                	ld	a0,24(a0)
    800049c8:	fffff097          	auipc	ra,0xfffff
    800049cc:	008080e7          	jalr	8(ra) # 800039d0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049d0:	874a                	mv	a4,s2
    800049d2:	5094                	lw	a3,32(s1)
    800049d4:	864e                	mv	a2,s3
    800049d6:	4585                	li	a1,1
    800049d8:	6c88                	ld	a0,24(s1)
    800049da:	fffff097          	auipc	ra,0xfffff
    800049de:	2aa080e7          	jalr	682(ra) # 80003c84 <readi>
    800049e2:	892a                	mv	s2,a0
    800049e4:	00a05563          	blez	a0,800049ee <fileread+0x56>
      f->off += r;
    800049e8:	509c                	lw	a5,32(s1)
    800049ea:	9fa9                	addw	a5,a5,a0
    800049ec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049ee:	6c88                	ld	a0,24(s1)
    800049f0:	fffff097          	auipc	ra,0xfffff
    800049f4:	0a2080e7          	jalr	162(ra) # 80003a92 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049f8:	854a                	mv	a0,s2
    800049fa:	70a2                	ld	ra,40(sp)
    800049fc:	7402                	ld	s0,32(sp)
    800049fe:	64e2                	ld	s1,24(sp)
    80004a00:	6942                	ld	s2,16(sp)
    80004a02:	69a2                	ld	s3,8(sp)
    80004a04:	6145                	addi	sp,sp,48
    80004a06:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a08:	6908                	ld	a0,16(a0)
    80004a0a:	00000097          	auipc	ra,0x0
    80004a0e:	418080e7          	jalr	1048(ra) # 80004e22 <piperead>
    80004a12:	892a                	mv	s2,a0
    80004a14:	b7d5                	j	800049f8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a16:	02451783          	lh	a5,36(a0)
    80004a1a:	03079693          	slli	a3,a5,0x30
    80004a1e:	92c1                	srli	a3,a3,0x30
    80004a20:	4725                	li	a4,9
    80004a22:	02d76863          	bltu	a4,a3,80004a52 <fileread+0xba>
    80004a26:	0792                	slli	a5,a5,0x4
    80004a28:	0001d717          	auipc	a4,0x1d
    80004a2c:	18870713          	addi	a4,a4,392 # 80021bb0 <devsw>
    80004a30:	97ba                	add	a5,a5,a4
    80004a32:	639c                	ld	a5,0(a5)
    80004a34:	c38d                	beqz	a5,80004a56 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a36:	4505                	li	a0,1
    80004a38:	9782                	jalr	a5
    80004a3a:	892a                	mv	s2,a0
    80004a3c:	bf75                	j	800049f8 <fileread+0x60>
    panic("fileread");
    80004a3e:	00004517          	auipc	a0,0x4
    80004a42:	cd250513          	addi	a0,a0,-814 # 80008710 <syscalls+0x258>
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	b02080e7          	jalr	-1278(ra) # 80000548 <panic>
    return -1;
    80004a4e:	597d                	li	s2,-1
    80004a50:	b765                	j	800049f8 <fileread+0x60>
      return -1;
    80004a52:	597d                	li	s2,-1
    80004a54:	b755                	j	800049f8 <fileread+0x60>
    80004a56:	597d                	li	s2,-1
    80004a58:	b745                	j	800049f8 <fileread+0x60>

0000000080004a5a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a5a:	00954783          	lbu	a5,9(a0)
    80004a5e:	14078563          	beqz	a5,80004ba8 <filewrite+0x14e>
{
    80004a62:	715d                	addi	sp,sp,-80
    80004a64:	e486                	sd	ra,72(sp)
    80004a66:	e0a2                	sd	s0,64(sp)
    80004a68:	fc26                	sd	s1,56(sp)
    80004a6a:	f84a                	sd	s2,48(sp)
    80004a6c:	f44e                	sd	s3,40(sp)
    80004a6e:	f052                	sd	s4,32(sp)
    80004a70:	ec56                	sd	s5,24(sp)
    80004a72:	e85a                	sd	s6,16(sp)
    80004a74:	e45e                	sd	s7,8(sp)
    80004a76:	e062                	sd	s8,0(sp)
    80004a78:	0880                	addi	s0,sp,80
    80004a7a:	892a                	mv	s2,a0
    80004a7c:	8aae                	mv	s5,a1
    80004a7e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a80:	411c                	lw	a5,0(a0)
    80004a82:	4705                	li	a4,1
    80004a84:	02e78263          	beq	a5,a4,80004aa8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a88:	470d                	li	a4,3
    80004a8a:	02e78563          	beq	a5,a4,80004ab4 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a8e:	4709                	li	a4,2
    80004a90:	10e79463          	bne	a5,a4,80004b98 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a94:	0ec05e63          	blez	a2,80004b90 <filewrite+0x136>
    int i = 0;
    80004a98:	4981                	li	s3,0
    80004a9a:	6b05                	lui	s6,0x1
    80004a9c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004aa0:	6b85                	lui	s7,0x1
    80004aa2:	c00b8b9b          	addiw	s7,s7,-1024
    80004aa6:	a851                	j	80004b3a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004aa8:	6908                	ld	a0,16(a0)
    80004aaa:	00000097          	auipc	ra,0x0
    80004aae:	254080e7          	jalr	596(ra) # 80004cfe <pipewrite>
    80004ab2:	a85d                	j	80004b68 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ab4:	02451783          	lh	a5,36(a0)
    80004ab8:	03079693          	slli	a3,a5,0x30
    80004abc:	92c1                	srli	a3,a3,0x30
    80004abe:	4725                	li	a4,9
    80004ac0:	0ed76663          	bltu	a4,a3,80004bac <filewrite+0x152>
    80004ac4:	0792                	slli	a5,a5,0x4
    80004ac6:	0001d717          	auipc	a4,0x1d
    80004aca:	0ea70713          	addi	a4,a4,234 # 80021bb0 <devsw>
    80004ace:	97ba                	add	a5,a5,a4
    80004ad0:	679c                	ld	a5,8(a5)
    80004ad2:	cff9                	beqz	a5,80004bb0 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004ad4:	4505                	li	a0,1
    80004ad6:	9782                	jalr	a5
    80004ad8:	a841                	j	80004b68 <filewrite+0x10e>
    80004ada:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004ade:	00000097          	auipc	ra,0x0
    80004ae2:	8ae080e7          	jalr	-1874(ra) # 8000438c <begin_op>
      ilock(f->ip);
    80004ae6:	01893503          	ld	a0,24(s2)
    80004aea:	fffff097          	auipc	ra,0xfffff
    80004aee:	ee6080e7          	jalr	-282(ra) # 800039d0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004af2:	8762                	mv	a4,s8
    80004af4:	02092683          	lw	a3,32(s2)
    80004af8:	01598633          	add	a2,s3,s5
    80004afc:	4585                	li	a1,1
    80004afe:	01893503          	ld	a0,24(s2)
    80004b02:	fffff097          	auipc	ra,0xfffff
    80004b06:	278080e7          	jalr	632(ra) # 80003d7a <writei>
    80004b0a:	84aa                	mv	s1,a0
    80004b0c:	02a05f63          	blez	a0,80004b4a <filewrite+0xf0>
        f->off += r;
    80004b10:	02092783          	lw	a5,32(s2)
    80004b14:	9fa9                	addw	a5,a5,a0
    80004b16:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b1a:	01893503          	ld	a0,24(s2)
    80004b1e:	fffff097          	auipc	ra,0xfffff
    80004b22:	f74080e7          	jalr	-140(ra) # 80003a92 <iunlock>
      end_op();
    80004b26:	00000097          	auipc	ra,0x0
    80004b2a:	8e6080e7          	jalr	-1818(ra) # 8000440c <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004b2e:	049c1963          	bne	s8,s1,80004b80 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004b32:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b36:	0349d663          	bge	s3,s4,80004b62 <filewrite+0x108>
      int n1 = n - i;
    80004b3a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b3e:	84be                	mv	s1,a5
    80004b40:	2781                	sext.w	a5,a5
    80004b42:	f8fb5ce3          	bge	s6,a5,80004ada <filewrite+0x80>
    80004b46:	84de                	mv	s1,s7
    80004b48:	bf49                	j	80004ada <filewrite+0x80>
      iunlock(f->ip);
    80004b4a:	01893503          	ld	a0,24(s2)
    80004b4e:	fffff097          	auipc	ra,0xfffff
    80004b52:	f44080e7          	jalr	-188(ra) # 80003a92 <iunlock>
      end_op();
    80004b56:	00000097          	auipc	ra,0x0
    80004b5a:	8b6080e7          	jalr	-1866(ra) # 8000440c <end_op>
      if(r < 0)
    80004b5e:	fc04d8e3          	bgez	s1,80004b2e <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004b62:	8552                	mv	a0,s4
    80004b64:	033a1863          	bne	s4,s3,80004b94 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b68:	60a6                	ld	ra,72(sp)
    80004b6a:	6406                	ld	s0,64(sp)
    80004b6c:	74e2                	ld	s1,56(sp)
    80004b6e:	7942                	ld	s2,48(sp)
    80004b70:	79a2                	ld	s3,40(sp)
    80004b72:	7a02                	ld	s4,32(sp)
    80004b74:	6ae2                	ld	s5,24(sp)
    80004b76:	6b42                	ld	s6,16(sp)
    80004b78:	6ba2                	ld	s7,8(sp)
    80004b7a:	6c02                	ld	s8,0(sp)
    80004b7c:	6161                	addi	sp,sp,80
    80004b7e:	8082                	ret
        panic("short filewrite");
    80004b80:	00004517          	auipc	a0,0x4
    80004b84:	ba050513          	addi	a0,a0,-1120 # 80008720 <syscalls+0x268>
    80004b88:	ffffc097          	auipc	ra,0xffffc
    80004b8c:	9c0080e7          	jalr	-1600(ra) # 80000548 <panic>
    int i = 0;
    80004b90:	4981                	li	s3,0
    80004b92:	bfc1                	j	80004b62 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004b94:	557d                	li	a0,-1
    80004b96:	bfc9                	j	80004b68 <filewrite+0x10e>
    panic("filewrite");
    80004b98:	00004517          	auipc	a0,0x4
    80004b9c:	b9850513          	addi	a0,a0,-1128 # 80008730 <syscalls+0x278>
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	9a8080e7          	jalr	-1624(ra) # 80000548 <panic>
    return -1;
    80004ba8:	557d                	li	a0,-1
}
    80004baa:	8082                	ret
      return -1;
    80004bac:	557d                	li	a0,-1
    80004bae:	bf6d                	j	80004b68 <filewrite+0x10e>
    80004bb0:	557d                	li	a0,-1
    80004bb2:	bf5d                	j	80004b68 <filewrite+0x10e>

0000000080004bb4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bb4:	7179                	addi	sp,sp,-48
    80004bb6:	f406                	sd	ra,40(sp)
    80004bb8:	f022                	sd	s0,32(sp)
    80004bba:	ec26                	sd	s1,24(sp)
    80004bbc:	e84a                	sd	s2,16(sp)
    80004bbe:	e44e                	sd	s3,8(sp)
    80004bc0:	e052                	sd	s4,0(sp)
    80004bc2:	1800                	addi	s0,sp,48
    80004bc4:	84aa                	mv	s1,a0
    80004bc6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004bc8:	0005b023          	sd	zero,0(a1)
    80004bcc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bd0:	00000097          	auipc	ra,0x0
    80004bd4:	bd2080e7          	jalr	-1070(ra) # 800047a2 <filealloc>
    80004bd8:	e088                	sd	a0,0(s1)
    80004bda:	c551                	beqz	a0,80004c66 <pipealloc+0xb2>
    80004bdc:	00000097          	auipc	ra,0x0
    80004be0:	bc6080e7          	jalr	-1082(ra) # 800047a2 <filealloc>
    80004be4:	00aa3023          	sd	a0,0(s4)
    80004be8:	c92d                	beqz	a0,80004c5a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004bea:	ffffc097          	auipc	ra,0xffffc
    80004bee:	f36080e7          	jalr	-202(ra) # 80000b20 <kalloc>
    80004bf2:	892a                	mv	s2,a0
    80004bf4:	c125                	beqz	a0,80004c54 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004bf6:	4985                	li	s3,1
    80004bf8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004bfc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c00:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c04:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c08:	00004597          	auipc	a1,0x4
    80004c0c:	b3858593          	addi	a1,a1,-1224 # 80008740 <syscalls+0x288>
    80004c10:	ffffc097          	auipc	ra,0xffffc
    80004c14:	f70080e7          	jalr	-144(ra) # 80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    80004c18:	609c                	ld	a5,0(s1)
    80004c1a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c1e:	609c                	ld	a5,0(s1)
    80004c20:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c24:	609c                	ld	a5,0(s1)
    80004c26:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c2a:	609c                	ld	a5,0(s1)
    80004c2c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c30:	000a3783          	ld	a5,0(s4)
    80004c34:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c38:	000a3783          	ld	a5,0(s4)
    80004c3c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c40:	000a3783          	ld	a5,0(s4)
    80004c44:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c48:	000a3783          	ld	a5,0(s4)
    80004c4c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c50:	4501                	li	a0,0
    80004c52:	a025                	j	80004c7a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c54:	6088                	ld	a0,0(s1)
    80004c56:	e501                	bnez	a0,80004c5e <pipealloc+0xaa>
    80004c58:	a039                	j	80004c66 <pipealloc+0xb2>
    80004c5a:	6088                	ld	a0,0(s1)
    80004c5c:	c51d                	beqz	a0,80004c8a <pipealloc+0xd6>
    fileclose(*f0);
    80004c5e:	00000097          	auipc	ra,0x0
    80004c62:	c00080e7          	jalr	-1024(ra) # 8000485e <fileclose>
  if(*f1)
    80004c66:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c6a:	557d                	li	a0,-1
  if(*f1)
    80004c6c:	c799                	beqz	a5,80004c7a <pipealloc+0xc6>
    fileclose(*f1);
    80004c6e:	853e                	mv	a0,a5
    80004c70:	00000097          	auipc	ra,0x0
    80004c74:	bee080e7          	jalr	-1042(ra) # 8000485e <fileclose>
  return -1;
    80004c78:	557d                	li	a0,-1
}
    80004c7a:	70a2                	ld	ra,40(sp)
    80004c7c:	7402                	ld	s0,32(sp)
    80004c7e:	64e2                	ld	s1,24(sp)
    80004c80:	6942                	ld	s2,16(sp)
    80004c82:	69a2                	ld	s3,8(sp)
    80004c84:	6a02                	ld	s4,0(sp)
    80004c86:	6145                	addi	sp,sp,48
    80004c88:	8082                	ret
  return -1;
    80004c8a:	557d                	li	a0,-1
    80004c8c:	b7fd                	j	80004c7a <pipealloc+0xc6>

0000000080004c8e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c8e:	1101                	addi	sp,sp,-32
    80004c90:	ec06                	sd	ra,24(sp)
    80004c92:	e822                	sd	s0,16(sp)
    80004c94:	e426                	sd	s1,8(sp)
    80004c96:	e04a                	sd	s2,0(sp)
    80004c98:	1000                	addi	s0,sp,32
    80004c9a:	84aa                	mv	s1,a0
    80004c9c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c9e:	ffffc097          	auipc	ra,0xffffc
    80004ca2:	f72080e7          	jalr	-142(ra) # 80000c10 <acquire>
  if(writable){
    80004ca6:	02090d63          	beqz	s2,80004ce0 <pipeclose+0x52>
    pi->writeopen = 0;
    80004caa:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004cae:	21848513          	addi	a0,s1,536
    80004cb2:	ffffe097          	auipc	ra,0xffffe
    80004cb6:	a84080e7          	jalr	-1404(ra) # 80002736 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cba:	2204b783          	ld	a5,544(s1)
    80004cbe:	eb95                	bnez	a5,80004cf2 <pipeclose+0x64>
    release(&pi->lock);
    80004cc0:	8526                	mv	a0,s1
    80004cc2:	ffffc097          	auipc	ra,0xffffc
    80004cc6:	002080e7          	jalr	2(ra) # 80000cc4 <release>
    kfree((char*)pi);
    80004cca:	8526                	mv	a0,s1
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	d58080e7          	jalr	-680(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    80004cd4:	60e2                	ld	ra,24(sp)
    80004cd6:	6442                	ld	s0,16(sp)
    80004cd8:	64a2                	ld	s1,8(sp)
    80004cda:	6902                	ld	s2,0(sp)
    80004cdc:	6105                	addi	sp,sp,32
    80004cde:	8082                	ret
    pi->readopen = 0;
    80004ce0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ce4:	21c48513          	addi	a0,s1,540
    80004ce8:	ffffe097          	auipc	ra,0xffffe
    80004cec:	a4e080e7          	jalr	-1458(ra) # 80002736 <wakeup>
    80004cf0:	b7e9                	j	80004cba <pipeclose+0x2c>
    release(&pi->lock);
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	fd0080e7          	jalr	-48(ra) # 80000cc4 <release>
}
    80004cfc:	bfe1                	j	80004cd4 <pipeclose+0x46>

0000000080004cfe <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cfe:	7119                	addi	sp,sp,-128
    80004d00:	fc86                	sd	ra,120(sp)
    80004d02:	f8a2                	sd	s0,112(sp)
    80004d04:	f4a6                	sd	s1,104(sp)
    80004d06:	f0ca                	sd	s2,96(sp)
    80004d08:	ecce                	sd	s3,88(sp)
    80004d0a:	e8d2                	sd	s4,80(sp)
    80004d0c:	e4d6                	sd	s5,72(sp)
    80004d0e:	e0da                	sd	s6,64(sp)
    80004d10:	fc5e                	sd	s7,56(sp)
    80004d12:	f862                	sd	s8,48(sp)
    80004d14:	f466                	sd	s9,40(sp)
    80004d16:	f06a                	sd	s10,32(sp)
    80004d18:	ec6e                	sd	s11,24(sp)
    80004d1a:	0100                	addi	s0,sp,128
    80004d1c:	84aa                	mv	s1,a0
    80004d1e:	8cae                	mv	s9,a1
    80004d20:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004d22:	ffffd097          	auipc	ra,0xffffd
    80004d26:	eae080e7          	jalr	-338(ra) # 80001bd0 <myproc>
    80004d2a:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004d2c:	8526                	mv	a0,s1
    80004d2e:	ffffc097          	auipc	ra,0xffffc
    80004d32:	ee2080e7          	jalr	-286(ra) # 80000c10 <acquire>
  for(i = 0; i < n; i++){
    80004d36:	0d605963          	blez	s6,80004e08 <pipewrite+0x10a>
    80004d3a:	89a6                	mv	s3,s1
    80004d3c:	3b7d                	addiw	s6,s6,-1
    80004d3e:	1b02                	slli	s6,s6,0x20
    80004d40:	020b5b13          	srli	s6,s6,0x20
    80004d44:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004d46:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d4a:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d4e:	5dfd                	li	s11,-1
    80004d50:	000b8d1b          	sext.w	s10,s7
    80004d54:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004d56:	2184a783          	lw	a5,536(s1)
    80004d5a:	21c4a703          	lw	a4,540(s1)
    80004d5e:	2007879b          	addiw	a5,a5,512
    80004d62:	02f71b63          	bne	a4,a5,80004d98 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004d66:	2204a783          	lw	a5,544(s1)
    80004d6a:	cbad                	beqz	a5,80004ddc <pipewrite+0xde>
    80004d6c:	03092783          	lw	a5,48(s2)
    80004d70:	e7b5                	bnez	a5,80004ddc <pipewrite+0xde>
      wakeup(&pi->nread);
    80004d72:	8556                	mv	a0,s5
    80004d74:	ffffe097          	auipc	ra,0xffffe
    80004d78:	9c2080e7          	jalr	-1598(ra) # 80002736 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d7c:	85ce                	mv	a1,s3
    80004d7e:	8552                	mv	a0,s4
    80004d80:	ffffe097          	auipc	ra,0xffffe
    80004d84:	830080e7          	jalr	-2000(ra) # 800025b0 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004d88:	2184a783          	lw	a5,536(s1)
    80004d8c:	21c4a703          	lw	a4,540(s1)
    80004d90:	2007879b          	addiw	a5,a5,512
    80004d94:	fcf709e3          	beq	a4,a5,80004d66 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d98:	4685                	li	a3,1
    80004d9a:	019b8633          	add	a2,s7,s9
    80004d9e:	f8f40593          	addi	a1,s0,-113
    80004da2:	05093503          	ld	a0,80(s2)
    80004da6:	ffffd097          	auipc	ra,0xffffd
    80004daa:	bf8080e7          	jalr	-1032(ra) # 8000199e <copyin>
    80004dae:	05b50e63          	beq	a0,s11,80004e0a <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004db2:	21c4a783          	lw	a5,540(s1)
    80004db6:	0017871b          	addiw	a4,a5,1
    80004dba:	20e4ae23          	sw	a4,540(s1)
    80004dbe:	1ff7f793          	andi	a5,a5,511
    80004dc2:	97a6                	add	a5,a5,s1
    80004dc4:	f8f44703          	lbu	a4,-113(s0)
    80004dc8:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004dcc:	001d0c1b          	addiw	s8,s10,1
    80004dd0:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004dd4:	036b8b63          	beq	s7,s6,80004e0a <pipewrite+0x10c>
    80004dd8:	8bbe                	mv	s7,a5
    80004dda:	bf9d                	j	80004d50 <pipewrite+0x52>
        release(&pi->lock);
    80004ddc:	8526                	mv	a0,s1
    80004dde:	ffffc097          	auipc	ra,0xffffc
    80004de2:	ee6080e7          	jalr	-282(ra) # 80000cc4 <release>
        return -1;
    80004de6:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004de8:	8562                	mv	a0,s8
    80004dea:	70e6                	ld	ra,120(sp)
    80004dec:	7446                	ld	s0,112(sp)
    80004dee:	74a6                	ld	s1,104(sp)
    80004df0:	7906                	ld	s2,96(sp)
    80004df2:	69e6                	ld	s3,88(sp)
    80004df4:	6a46                	ld	s4,80(sp)
    80004df6:	6aa6                	ld	s5,72(sp)
    80004df8:	6b06                	ld	s6,64(sp)
    80004dfa:	7be2                	ld	s7,56(sp)
    80004dfc:	7c42                	ld	s8,48(sp)
    80004dfe:	7ca2                	ld	s9,40(sp)
    80004e00:	7d02                	ld	s10,32(sp)
    80004e02:	6de2                	ld	s11,24(sp)
    80004e04:	6109                	addi	sp,sp,128
    80004e06:	8082                	ret
  for(i = 0; i < n; i++){
    80004e08:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004e0a:	21848513          	addi	a0,s1,536
    80004e0e:	ffffe097          	auipc	ra,0xffffe
    80004e12:	928080e7          	jalr	-1752(ra) # 80002736 <wakeup>
  release(&pi->lock);
    80004e16:	8526                	mv	a0,s1
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	eac080e7          	jalr	-340(ra) # 80000cc4 <release>
  return i;
    80004e20:	b7e1                	j	80004de8 <pipewrite+0xea>

0000000080004e22 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e22:	715d                	addi	sp,sp,-80
    80004e24:	e486                	sd	ra,72(sp)
    80004e26:	e0a2                	sd	s0,64(sp)
    80004e28:	fc26                	sd	s1,56(sp)
    80004e2a:	f84a                	sd	s2,48(sp)
    80004e2c:	f44e                	sd	s3,40(sp)
    80004e2e:	f052                	sd	s4,32(sp)
    80004e30:	ec56                	sd	s5,24(sp)
    80004e32:	e85a                	sd	s6,16(sp)
    80004e34:	0880                	addi	s0,sp,80
    80004e36:	84aa                	mv	s1,a0
    80004e38:	892e                	mv	s2,a1
    80004e3a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e3c:	ffffd097          	auipc	ra,0xffffd
    80004e40:	d94080e7          	jalr	-620(ra) # 80001bd0 <myproc>
    80004e44:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e46:	8b26                	mv	s6,s1
    80004e48:	8526                	mv	a0,s1
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	dc6080e7          	jalr	-570(ra) # 80000c10 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e52:	2184a703          	lw	a4,536(s1)
    80004e56:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e5a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e5e:	02f71463          	bne	a4,a5,80004e86 <piperead+0x64>
    80004e62:	2244a783          	lw	a5,548(s1)
    80004e66:	c385                	beqz	a5,80004e86 <piperead+0x64>
    if(pr->killed){
    80004e68:	030a2783          	lw	a5,48(s4)
    80004e6c:	ebc1                	bnez	a5,80004efc <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e6e:	85da                	mv	a1,s6
    80004e70:	854e                	mv	a0,s3
    80004e72:	ffffd097          	auipc	ra,0xffffd
    80004e76:	73e080e7          	jalr	1854(ra) # 800025b0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e7a:	2184a703          	lw	a4,536(s1)
    80004e7e:	21c4a783          	lw	a5,540(s1)
    80004e82:	fef700e3          	beq	a4,a5,80004e62 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e86:	09505263          	blez	s5,80004f0a <piperead+0xe8>
    80004e8a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e8c:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004e8e:	2184a783          	lw	a5,536(s1)
    80004e92:	21c4a703          	lw	a4,540(s1)
    80004e96:	02f70d63          	beq	a4,a5,80004ed0 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e9a:	0017871b          	addiw	a4,a5,1
    80004e9e:	20e4ac23          	sw	a4,536(s1)
    80004ea2:	1ff7f793          	andi	a5,a5,511
    80004ea6:	97a6                	add	a5,a5,s1
    80004ea8:	0187c783          	lbu	a5,24(a5)
    80004eac:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eb0:	4685                	li	a3,1
    80004eb2:	fbf40613          	addi	a2,s0,-65
    80004eb6:	85ca                	mv	a1,s2
    80004eb8:	050a3503          	ld	a0,80(s4)
    80004ebc:	ffffd097          	auipc	ra,0xffffd
    80004ec0:	a56080e7          	jalr	-1450(ra) # 80001912 <copyout>
    80004ec4:	01650663          	beq	a0,s6,80004ed0 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ec8:	2985                	addiw	s3,s3,1
    80004eca:	0905                	addi	s2,s2,1
    80004ecc:	fd3a91e3          	bne	s5,s3,80004e8e <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ed0:	21c48513          	addi	a0,s1,540
    80004ed4:	ffffe097          	auipc	ra,0xffffe
    80004ed8:	862080e7          	jalr	-1950(ra) # 80002736 <wakeup>
  release(&pi->lock);
    80004edc:	8526                	mv	a0,s1
    80004ede:	ffffc097          	auipc	ra,0xffffc
    80004ee2:	de6080e7          	jalr	-538(ra) # 80000cc4 <release>
  return i;
}
    80004ee6:	854e                	mv	a0,s3
    80004ee8:	60a6                	ld	ra,72(sp)
    80004eea:	6406                	ld	s0,64(sp)
    80004eec:	74e2                	ld	s1,56(sp)
    80004eee:	7942                	ld	s2,48(sp)
    80004ef0:	79a2                	ld	s3,40(sp)
    80004ef2:	7a02                	ld	s4,32(sp)
    80004ef4:	6ae2                	ld	s5,24(sp)
    80004ef6:	6b42                	ld	s6,16(sp)
    80004ef8:	6161                	addi	sp,sp,80
    80004efa:	8082                	ret
      release(&pi->lock);
    80004efc:	8526                	mv	a0,s1
    80004efe:	ffffc097          	auipc	ra,0xffffc
    80004f02:	dc6080e7          	jalr	-570(ra) # 80000cc4 <release>
      return -1;
    80004f06:	59fd                	li	s3,-1
    80004f08:	bff9                	j	80004ee6 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f0a:	4981                	li	s3,0
    80004f0c:	b7d1                	j	80004ed0 <piperead+0xae>

0000000080004f0e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004f0e:	df010113          	addi	sp,sp,-528
    80004f12:	20113423          	sd	ra,520(sp)
    80004f16:	20813023          	sd	s0,512(sp)
    80004f1a:	ffa6                	sd	s1,504(sp)
    80004f1c:	fbca                	sd	s2,496(sp)
    80004f1e:	f7ce                	sd	s3,488(sp)
    80004f20:	f3d2                	sd	s4,480(sp)
    80004f22:	efd6                	sd	s5,472(sp)
    80004f24:	ebda                	sd	s6,464(sp)
    80004f26:	e7de                	sd	s7,456(sp)
    80004f28:	e3e2                	sd	s8,448(sp)
    80004f2a:	ff66                	sd	s9,440(sp)
    80004f2c:	fb6a                	sd	s10,432(sp)
    80004f2e:	f76e                	sd	s11,424(sp)
    80004f30:	0c00                	addi	s0,sp,528
    80004f32:	84aa                	mv	s1,a0
    80004f34:	dea43c23          	sd	a0,-520(s0)
    80004f38:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f3c:	ffffd097          	auipc	ra,0xffffd
    80004f40:	c94080e7          	jalr	-876(ra) # 80001bd0 <myproc>
    80004f44:	892a                	mv	s2,a0

  begin_op();
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	446080e7          	jalr	1094(ra) # 8000438c <begin_op>

  if((ip = namei(path)) == 0){
    80004f4e:	8526                	mv	a0,s1
    80004f50:	fffff097          	auipc	ra,0xfffff
    80004f54:	230080e7          	jalr	560(ra) # 80004180 <namei>
    80004f58:	c92d                	beqz	a0,80004fca <exec+0xbc>
    80004f5a:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f5c:	fffff097          	auipc	ra,0xfffff
    80004f60:	a74080e7          	jalr	-1420(ra) # 800039d0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f64:	04000713          	li	a4,64
    80004f68:	4681                	li	a3,0
    80004f6a:	e4840613          	addi	a2,s0,-440
    80004f6e:	4581                	li	a1,0
    80004f70:	8526                	mv	a0,s1
    80004f72:	fffff097          	auipc	ra,0xfffff
    80004f76:	d12080e7          	jalr	-750(ra) # 80003c84 <readi>
    80004f7a:	04000793          	li	a5,64
    80004f7e:	00f51a63          	bne	a0,a5,80004f92 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004f82:	e4842703          	lw	a4,-440(s0)
    80004f86:	464c47b7          	lui	a5,0x464c4
    80004f8a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f8e:	04f70463          	beq	a4,a5,80004fd6 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f92:	8526                	mv	a0,s1
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	c9e080e7          	jalr	-866(ra) # 80003c32 <iunlockput>
    end_op();
    80004f9c:	fffff097          	auipc	ra,0xfffff
    80004fa0:	470080e7          	jalr	1136(ra) # 8000440c <end_op>
  }
  return -1;
    80004fa4:	557d                	li	a0,-1
}
    80004fa6:	20813083          	ld	ra,520(sp)
    80004faa:	20013403          	ld	s0,512(sp)
    80004fae:	74fe                	ld	s1,504(sp)
    80004fb0:	795e                	ld	s2,496(sp)
    80004fb2:	79be                	ld	s3,488(sp)
    80004fb4:	7a1e                	ld	s4,480(sp)
    80004fb6:	6afe                	ld	s5,472(sp)
    80004fb8:	6b5e                	ld	s6,464(sp)
    80004fba:	6bbe                	ld	s7,456(sp)
    80004fbc:	6c1e                	ld	s8,448(sp)
    80004fbe:	7cfa                	ld	s9,440(sp)
    80004fc0:	7d5a                	ld	s10,432(sp)
    80004fc2:	7dba                	ld	s11,424(sp)
    80004fc4:	21010113          	addi	sp,sp,528
    80004fc8:	8082                	ret
    end_op();
    80004fca:	fffff097          	auipc	ra,0xfffff
    80004fce:	442080e7          	jalr	1090(ra) # 8000440c <end_op>
    return -1;
    80004fd2:	557d                	li	a0,-1
    80004fd4:	bfc9                	j	80004fa6 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004fd6:	854a                	mv	a0,s2
    80004fd8:	ffffd097          	auipc	ra,0xffffd
    80004fdc:	cbc080e7          	jalr	-836(ra) # 80001c94 <proc_pagetable>
    80004fe0:	8baa                	mv	s7,a0
    80004fe2:	d945                	beqz	a0,80004f92 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fe4:	e6842983          	lw	s3,-408(s0)
    80004fe8:	e8045783          	lhu	a5,-384(s0)
    80004fec:	c7ad                	beqz	a5,80005056 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004fee:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ff0:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004ff2:	6c85                	lui	s9,0x1
    80004ff4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ff8:	def43823          	sd	a5,-528(s0)
    80004ffc:	acb5                	j	80005278 <exec+0x36a>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ffe:	00003517          	auipc	a0,0x3
    80005002:	74a50513          	addi	a0,a0,1866 # 80008748 <syscalls+0x290>
    80005006:	ffffb097          	auipc	ra,0xffffb
    8000500a:	542080e7          	jalr	1346(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000500e:	8756                	mv	a4,s5
    80005010:	012d86bb          	addw	a3,s11,s2
    80005014:	4581                	li	a1,0
    80005016:	8526                	mv	a0,s1
    80005018:	fffff097          	auipc	ra,0xfffff
    8000501c:	c6c080e7          	jalr	-916(ra) # 80003c84 <readi>
    80005020:	2501                	sext.w	a0,a0
    80005022:	1eaa9e63          	bne	s5,a0,8000521e <exec+0x310>
  for(i = 0; i < sz; i += PGSIZE){
    80005026:	6785                	lui	a5,0x1
    80005028:	0127893b          	addw	s2,a5,s2
    8000502c:	77fd                	lui	a5,0xfffff
    8000502e:	01478a3b          	addw	s4,a5,s4
    80005032:	23897a63          	bgeu	s2,s8,80005266 <exec+0x358>
    pa = walkaddr(pagetable, va + i);
    80005036:	02091593          	slli	a1,s2,0x20
    8000503a:	9181                	srli	a1,a1,0x20
    8000503c:	95ea                	add	a1,a1,s10
    8000503e:	855e                	mv	a0,s7
    80005040:	ffffc097          	auipc	ra,0xffffc
    80005044:	082080e7          	jalr	130(ra) # 800010c2 <walkaddr>
    80005048:	862a                	mv	a2,a0
    if(pa == 0)
    8000504a:	d955                	beqz	a0,80004ffe <exec+0xf0>
      n = PGSIZE;
    8000504c:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000504e:	fd9a70e3          	bgeu	s4,s9,8000500e <exec+0x100>
      n = sz - i;
    80005052:	8ad2                	mv	s5,s4
    80005054:	bf6d                	j	8000500e <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005056:	4901                	li	s2,0
  iunlockput(ip);
    80005058:	8526                	mv	a0,s1
    8000505a:	fffff097          	auipc	ra,0xfffff
    8000505e:	bd8080e7          	jalr	-1064(ra) # 80003c32 <iunlockput>
  end_op();
    80005062:	fffff097          	auipc	ra,0xfffff
    80005066:	3aa080e7          	jalr	938(ra) # 8000440c <end_op>
  p = myproc();
    8000506a:	ffffd097          	auipc	ra,0xffffd
    8000506e:	b66080e7          	jalr	-1178(ra) # 80001bd0 <myproc>
    80005072:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005074:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005078:	6785                	lui	a5,0x1
    8000507a:	17fd                	addi	a5,a5,-1
    8000507c:	993e                	add	s2,s2,a5
    8000507e:	757d                	lui	a0,0xfffff
    80005080:	00a977b3          	and	a5,s2,a0
    80005084:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005088:	6609                	lui	a2,0x2
    8000508a:	963e                	add	a2,a2,a5
    8000508c:	85be                	mv	a1,a5
    8000508e:	855e                	mv	a0,s7
    80005090:	ffffc097          	auipc	ra,0xffffc
    80005094:	580080e7          	jalr	1408(ra) # 80001610 <uvmalloc>
    80005098:	8b2a                	mv	s6,a0
  ip = 0;
    8000509a:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000509c:	18050163          	beqz	a0,8000521e <exec+0x310>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050a0:	75f9                	lui	a1,0xffffe
    800050a2:	95aa                	add	a1,a1,a0
    800050a4:	855e                	mv	a0,s7
    800050a6:	ffffd097          	auipc	ra,0xffffd
    800050aa:	83a080e7          	jalr	-1990(ra) # 800018e0 <uvmclear>
  stackbase = sp - PGSIZE;
    800050ae:	7c7d                	lui	s8,0xfffff
    800050b0:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800050b2:	e0043783          	ld	a5,-512(s0)
    800050b6:	6388                	ld	a0,0(a5)
    800050b8:	c535                	beqz	a0,80005124 <exec+0x216>
    800050ba:	e8840993          	addi	s3,s0,-376
    800050be:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    800050c2:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800050c4:	ffffc097          	auipc	ra,0xffffc
    800050c8:	dd0080e7          	jalr	-560(ra) # 80000e94 <strlen>
    800050cc:	2505                	addiw	a0,a0,1
    800050ce:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050d2:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050d6:	17896863          	bltu	s2,s8,80005246 <exec+0x338>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050da:	e0043d83          	ld	s11,-512(s0)
    800050de:	000dba03          	ld	s4,0(s11)
    800050e2:	8552                	mv	a0,s4
    800050e4:	ffffc097          	auipc	ra,0xffffc
    800050e8:	db0080e7          	jalr	-592(ra) # 80000e94 <strlen>
    800050ec:	0015069b          	addiw	a3,a0,1
    800050f0:	8652                	mv	a2,s4
    800050f2:	85ca                	mv	a1,s2
    800050f4:	855e                	mv	a0,s7
    800050f6:	ffffd097          	auipc	ra,0xffffd
    800050fa:	81c080e7          	jalr	-2020(ra) # 80001912 <copyout>
    800050fe:	14054863          	bltz	a0,8000524e <exec+0x340>
    ustack[argc] = sp;
    80005102:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005106:	0485                	addi	s1,s1,1
    80005108:	008d8793          	addi	a5,s11,8
    8000510c:	e0f43023          	sd	a5,-512(s0)
    80005110:	008db503          	ld	a0,8(s11)
    80005114:	c911                	beqz	a0,80005128 <exec+0x21a>
    if(argc >= MAXARG)
    80005116:	09a1                	addi	s3,s3,8
    80005118:	fb3c96e3          	bne	s9,s3,800050c4 <exec+0x1b6>
  sz = sz1;
    8000511c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005120:	4481                	li	s1,0
    80005122:	a8f5                	j	8000521e <exec+0x310>
  sp = sz;
    80005124:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005126:	4481                	li	s1,0
  ustack[argc] = 0;
    80005128:	00349793          	slli	a5,s1,0x3
    8000512c:	f9040713          	addi	a4,s0,-112
    80005130:	97ba                	add	a5,a5,a4
    80005132:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80005136:	00148693          	addi	a3,s1,1
    8000513a:	068e                	slli	a3,a3,0x3
    8000513c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005140:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005144:	01897663          	bgeu	s2,s8,80005150 <exec+0x242>
  sz = sz1;
    80005148:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000514c:	4481                	li	s1,0
    8000514e:	a8c1                	j	8000521e <exec+0x310>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005150:	e8840613          	addi	a2,s0,-376
    80005154:	85ca                	mv	a1,s2
    80005156:	855e                	mv	a0,s7
    80005158:	ffffc097          	auipc	ra,0xffffc
    8000515c:	7ba080e7          	jalr	1978(ra) # 80001912 <copyout>
    80005160:	0e054b63          	bltz	a0,80005256 <exec+0x348>
  p->trapframe->a1 = sp;
    80005164:	058ab783          	ld	a5,88(s5)
    80005168:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000516c:	df843783          	ld	a5,-520(s0)
    80005170:	0007c703          	lbu	a4,0(a5)
    80005174:	cf11                	beqz	a4,80005190 <exec+0x282>
    80005176:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005178:	02f00693          	li	a3,47
    8000517c:	a029                	j	80005186 <exec+0x278>
  for(last=s=path; *s; s++)
    8000517e:	0785                	addi	a5,a5,1
    80005180:	fff7c703          	lbu	a4,-1(a5)
    80005184:	c711                	beqz	a4,80005190 <exec+0x282>
    if(*s == '/')
    80005186:	fed71ce3          	bne	a4,a3,8000517e <exec+0x270>
      last = s+1;
    8000518a:	def43c23          	sd	a5,-520(s0)
    8000518e:	bfc5                	j	8000517e <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80005190:	4641                	li	a2,16
    80005192:	df843583          	ld	a1,-520(s0)
    80005196:	158a8513          	addi	a0,s5,344
    8000519a:	ffffc097          	auipc	ra,0xffffc
    8000519e:	cc8080e7          	jalr	-824(ra) # 80000e62 <safestrcpy>
  oldpagetable = p->pagetable;
    800051a2:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800051a6:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800051aa:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051ae:	058ab783          	ld	a5,88(s5)
    800051b2:	e6043703          	ld	a4,-416(s0)
    800051b6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051b8:	058ab783          	ld	a5,88(s5)
    800051bc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051c0:	85ea                	mv	a1,s10
    800051c2:	ffffd097          	auipc	ra,0xffffd
    800051c6:	b98080e7          	jalr	-1128(ra) # 80001d5a <proc_freepagetable>
  uvmunmap(p->kpagetable, 0, PGROUNDUP(oldsz)/PGSIZE, 0);
    800051ca:	6605                	lui	a2,0x1
    800051cc:	167d                	addi	a2,a2,-1
    800051ce:	966a                	add	a2,a2,s10
    800051d0:	4681                	li	a3,0
    800051d2:	8231                	srli	a2,a2,0xc
    800051d4:	4581                	li	a1,0
    800051d6:	168ab503          	ld	a0,360(s5)
    800051da:	ffffc097          	auipc	ra,0xffffc
    800051de:	25a080e7          	jalr	602(ra) # 80001434 <uvmunmap>
  if(u2kvmcopy(p->pagetable, p->kpagetable, 0, p->sz) < 0) 
    800051e2:	048ab683          	ld	a3,72(s5)
    800051e6:	4601                	li	a2,0
    800051e8:	168ab583          	ld	a1,360(s5)
    800051ec:	050ab503          	ld	a0,80(s5)
    800051f0:	ffffc097          	auipc	ra,0xffffc
    800051f4:	63e080e7          	jalr	1598(ra) # 8000182e <u2kvmcopy>
    800051f8:	06054363          	bltz	a0,8000525e <exec+0x350>
  if(p->pid == 1)
    800051fc:	038aa703          	lw	a4,56(s5)
    80005200:	4785                	li	a5,1
    80005202:	00f70563          	beq	a4,a5,8000520c <exec+0x2fe>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005206:	0004851b          	sext.w	a0,s1
    8000520a:	bb71                	j	80004fa6 <exec+0x98>
    vmprint(p->pagetable);
    8000520c:	050ab503          	ld	a0,80(s5)
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	8b4080e7          	jalr	-1868(ra) # 80001ac4 <vmprint>
    80005218:	b7fd                	j	80005206 <exec+0x2f8>
    8000521a:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000521e:	e0843583          	ld	a1,-504(s0)
    80005222:	855e                	mv	a0,s7
    80005224:	ffffd097          	auipc	ra,0xffffd
    80005228:	b36080e7          	jalr	-1226(ra) # 80001d5a <proc_freepagetable>
  if(ip){
    8000522c:	d60493e3          	bnez	s1,80004f92 <exec+0x84>
  return -1;
    80005230:	557d                	li	a0,-1
    80005232:	bb95                	j	80004fa6 <exec+0x98>
    80005234:	e1243423          	sd	s2,-504(s0)
    80005238:	b7dd                	j	8000521e <exec+0x310>
    8000523a:	e1243423          	sd	s2,-504(s0)
    8000523e:	b7c5                	j	8000521e <exec+0x310>
    80005240:	e1243423          	sd	s2,-504(s0)
    80005244:	bfe9                	j	8000521e <exec+0x310>
  sz = sz1;
    80005246:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000524a:	4481                	li	s1,0
    8000524c:	bfc9                	j	8000521e <exec+0x310>
  sz = sz1;
    8000524e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005252:	4481                	li	s1,0
    80005254:	b7e9                	j	8000521e <exec+0x310>
  sz = sz1;
    80005256:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000525a:	4481                	li	s1,0
    8000525c:	b7c9                	j	8000521e <exec+0x310>
  sz = sz1;
    8000525e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005262:	4481                	li	s1,0
    80005264:	bf6d                	j	8000521e <exec+0x310>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005266:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000526a:	2b05                	addiw	s6,s6,1
    8000526c:	0389899b          	addiw	s3,s3,56
    80005270:	e8045783          	lhu	a5,-384(s0)
    80005274:	defb52e3          	bge	s6,a5,80005058 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005278:	2981                	sext.w	s3,s3
    8000527a:	03800713          	li	a4,56
    8000527e:	86ce                	mv	a3,s3
    80005280:	e1040613          	addi	a2,s0,-496
    80005284:	4581                	li	a1,0
    80005286:	8526                	mv	a0,s1
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	9fc080e7          	jalr	-1540(ra) # 80003c84 <readi>
    80005290:	03800793          	li	a5,56
    80005294:	f8f513e3          	bne	a0,a5,8000521a <exec+0x30c>
    if(ph.type != ELF_PROG_LOAD)
    80005298:	e1042783          	lw	a5,-496(s0)
    8000529c:	4705                	li	a4,1
    8000529e:	fce796e3          	bne	a5,a4,8000526a <exec+0x35c>
    if(ph.memsz < ph.filesz)
    800052a2:	e3843603          	ld	a2,-456(s0)
    800052a6:	e3043783          	ld	a5,-464(s0)
    800052aa:	f8f665e3          	bltu	a2,a5,80005234 <exec+0x326>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800052ae:	e2043783          	ld	a5,-480(s0)
    800052b2:	963e                	add	a2,a2,a5
    800052b4:	f8f663e3          	bltu	a2,a5,8000523a <exec+0x32c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052b8:	85ca                	mv	a1,s2
    800052ba:	855e                	mv	a0,s7
    800052bc:	ffffc097          	auipc	ra,0xffffc
    800052c0:	354080e7          	jalr	852(ra) # 80001610 <uvmalloc>
    800052c4:	e0a43423          	sd	a0,-504(s0)
    800052c8:	dd25                	beqz	a0,80005240 <exec+0x332>
    if(ph.vaddr % PGSIZE != 0)
    800052ca:	e2043d03          	ld	s10,-480(s0)
    800052ce:	df043783          	ld	a5,-528(s0)
    800052d2:	00fd77b3          	and	a5,s10,a5
    800052d6:	f7a1                	bnez	a5,8000521e <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052d8:	e1842d83          	lw	s11,-488(s0)
    800052dc:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052e0:	f80c03e3          	beqz	s8,80005266 <exec+0x358>
    800052e4:	8a62                	mv	s4,s8
    800052e6:	4901                	li	s2,0
    800052e8:	b3b9                	j	80005036 <exec+0x128>

00000000800052ea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052ea:	7179                	addi	sp,sp,-48
    800052ec:	f406                	sd	ra,40(sp)
    800052ee:	f022                	sd	s0,32(sp)
    800052f0:	ec26                	sd	s1,24(sp)
    800052f2:	e84a                	sd	s2,16(sp)
    800052f4:	1800                	addi	s0,sp,48
    800052f6:	892e                	mv	s2,a1
    800052f8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800052fa:	fdc40593          	addi	a1,s0,-36
    800052fe:	ffffe097          	auipc	ra,0xffffe
    80005302:	b60080e7          	jalr	-1184(ra) # 80002e5e <argint>
    80005306:	04054063          	bltz	a0,80005346 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000530a:	fdc42703          	lw	a4,-36(s0)
    8000530e:	47bd                	li	a5,15
    80005310:	02e7ed63          	bltu	a5,a4,8000534a <argfd+0x60>
    80005314:	ffffd097          	auipc	ra,0xffffd
    80005318:	8bc080e7          	jalr	-1860(ra) # 80001bd0 <myproc>
    8000531c:	fdc42703          	lw	a4,-36(s0)
    80005320:	01a70793          	addi	a5,a4,26
    80005324:	078e                	slli	a5,a5,0x3
    80005326:	953e                	add	a0,a0,a5
    80005328:	611c                	ld	a5,0(a0)
    8000532a:	c395                	beqz	a5,8000534e <argfd+0x64>
    return -1;
  if(pfd)
    8000532c:	00090463          	beqz	s2,80005334 <argfd+0x4a>
    *pfd = fd;
    80005330:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005334:	4501                	li	a0,0
  if(pf)
    80005336:	c091                	beqz	s1,8000533a <argfd+0x50>
    *pf = f;
    80005338:	e09c                	sd	a5,0(s1)
}
    8000533a:	70a2                	ld	ra,40(sp)
    8000533c:	7402                	ld	s0,32(sp)
    8000533e:	64e2                	ld	s1,24(sp)
    80005340:	6942                	ld	s2,16(sp)
    80005342:	6145                	addi	sp,sp,48
    80005344:	8082                	ret
    return -1;
    80005346:	557d                	li	a0,-1
    80005348:	bfcd                	j	8000533a <argfd+0x50>
    return -1;
    8000534a:	557d                	li	a0,-1
    8000534c:	b7fd                	j	8000533a <argfd+0x50>
    8000534e:	557d                	li	a0,-1
    80005350:	b7ed                	j	8000533a <argfd+0x50>

0000000080005352 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005352:	1101                	addi	sp,sp,-32
    80005354:	ec06                	sd	ra,24(sp)
    80005356:	e822                	sd	s0,16(sp)
    80005358:	e426                	sd	s1,8(sp)
    8000535a:	1000                	addi	s0,sp,32
    8000535c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000535e:	ffffd097          	auipc	ra,0xffffd
    80005362:	872080e7          	jalr	-1934(ra) # 80001bd0 <myproc>
    80005366:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005368:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd80b0>
    8000536c:	4501                	li	a0,0
    8000536e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005370:	6398                	ld	a4,0(a5)
    80005372:	cb19                	beqz	a4,80005388 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005374:	2505                	addiw	a0,a0,1
    80005376:	07a1                	addi	a5,a5,8
    80005378:	fed51ce3          	bne	a0,a3,80005370 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000537c:	557d                	li	a0,-1
}
    8000537e:	60e2                	ld	ra,24(sp)
    80005380:	6442                	ld	s0,16(sp)
    80005382:	64a2                	ld	s1,8(sp)
    80005384:	6105                	addi	sp,sp,32
    80005386:	8082                	ret
      p->ofile[fd] = f;
    80005388:	01a50793          	addi	a5,a0,26
    8000538c:	078e                	slli	a5,a5,0x3
    8000538e:	963e                	add	a2,a2,a5
    80005390:	e204                	sd	s1,0(a2)
      return fd;
    80005392:	b7f5                	j	8000537e <fdalloc+0x2c>

0000000080005394 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005394:	715d                	addi	sp,sp,-80
    80005396:	e486                	sd	ra,72(sp)
    80005398:	e0a2                	sd	s0,64(sp)
    8000539a:	fc26                	sd	s1,56(sp)
    8000539c:	f84a                	sd	s2,48(sp)
    8000539e:	f44e                	sd	s3,40(sp)
    800053a0:	f052                	sd	s4,32(sp)
    800053a2:	ec56                	sd	s5,24(sp)
    800053a4:	0880                	addi	s0,sp,80
    800053a6:	89ae                	mv	s3,a1
    800053a8:	8ab2                	mv	s5,a2
    800053aa:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800053ac:	fb040593          	addi	a1,s0,-80
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	dee080e7          	jalr	-530(ra) # 8000419e <nameiparent>
    800053b8:	892a                	mv	s2,a0
    800053ba:	12050f63          	beqz	a0,800054f8 <create+0x164>
    return 0;

  ilock(dp);
    800053be:	ffffe097          	auipc	ra,0xffffe
    800053c2:	612080e7          	jalr	1554(ra) # 800039d0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800053c6:	4601                	li	a2,0
    800053c8:	fb040593          	addi	a1,s0,-80
    800053cc:	854a                	mv	a0,s2
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	ae0080e7          	jalr	-1312(ra) # 80003eae <dirlookup>
    800053d6:	84aa                	mv	s1,a0
    800053d8:	c921                	beqz	a0,80005428 <create+0x94>
    iunlockput(dp);
    800053da:	854a                	mv	a0,s2
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	856080e7          	jalr	-1962(ra) # 80003c32 <iunlockput>
    ilock(ip);
    800053e4:	8526                	mv	a0,s1
    800053e6:	ffffe097          	auipc	ra,0xffffe
    800053ea:	5ea080e7          	jalr	1514(ra) # 800039d0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053ee:	2981                	sext.w	s3,s3
    800053f0:	4789                	li	a5,2
    800053f2:	02f99463          	bne	s3,a5,8000541a <create+0x86>
    800053f6:	0444d783          	lhu	a5,68(s1)
    800053fa:	37f9                	addiw	a5,a5,-2
    800053fc:	17c2                	slli	a5,a5,0x30
    800053fe:	93c1                	srli	a5,a5,0x30
    80005400:	4705                	li	a4,1
    80005402:	00f76c63          	bltu	a4,a5,8000541a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005406:	8526                	mv	a0,s1
    80005408:	60a6                	ld	ra,72(sp)
    8000540a:	6406                	ld	s0,64(sp)
    8000540c:	74e2                	ld	s1,56(sp)
    8000540e:	7942                	ld	s2,48(sp)
    80005410:	79a2                	ld	s3,40(sp)
    80005412:	7a02                	ld	s4,32(sp)
    80005414:	6ae2                	ld	s5,24(sp)
    80005416:	6161                	addi	sp,sp,80
    80005418:	8082                	ret
    iunlockput(ip);
    8000541a:	8526                	mv	a0,s1
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	816080e7          	jalr	-2026(ra) # 80003c32 <iunlockput>
    return 0;
    80005424:	4481                	li	s1,0
    80005426:	b7c5                	j	80005406 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005428:	85ce                	mv	a1,s3
    8000542a:	00092503          	lw	a0,0(s2)
    8000542e:	ffffe097          	auipc	ra,0xffffe
    80005432:	40a080e7          	jalr	1034(ra) # 80003838 <ialloc>
    80005436:	84aa                	mv	s1,a0
    80005438:	c529                	beqz	a0,80005482 <create+0xee>
  ilock(ip);
    8000543a:	ffffe097          	auipc	ra,0xffffe
    8000543e:	596080e7          	jalr	1430(ra) # 800039d0 <ilock>
  ip->major = major;
    80005442:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005446:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000544a:	4785                	li	a5,1
    8000544c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005450:	8526                	mv	a0,s1
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	4b4080e7          	jalr	1204(ra) # 80003906 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000545a:	2981                	sext.w	s3,s3
    8000545c:	4785                	li	a5,1
    8000545e:	02f98a63          	beq	s3,a5,80005492 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005462:	40d0                	lw	a2,4(s1)
    80005464:	fb040593          	addi	a1,s0,-80
    80005468:	854a                	mv	a0,s2
    8000546a:	fffff097          	auipc	ra,0xfffff
    8000546e:	c54080e7          	jalr	-940(ra) # 800040be <dirlink>
    80005472:	06054b63          	bltz	a0,800054e8 <create+0x154>
  iunlockput(dp);
    80005476:	854a                	mv	a0,s2
    80005478:	ffffe097          	auipc	ra,0xffffe
    8000547c:	7ba080e7          	jalr	1978(ra) # 80003c32 <iunlockput>
  return ip;
    80005480:	b759                	j	80005406 <create+0x72>
    panic("create: ialloc");
    80005482:	00003517          	auipc	a0,0x3
    80005486:	2e650513          	addi	a0,a0,742 # 80008768 <syscalls+0x2b0>
    8000548a:	ffffb097          	auipc	ra,0xffffb
    8000548e:	0be080e7          	jalr	190(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    80005492:	04a95783          	lhu	a5,74(s2)
    80005496:	2785                	addiw	a5,a5,1
    80005498:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000549c:	854a                	mv	a0,s2
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	468080e7          	jalr	1128(ra) # 80003906 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054a6:	40d0                	lw	a2,4(s1)
    800054a8:	00003597          	auipc	a1,0x3
    800054ac:	2d058593          	addi	a1,a1,720 # 80008778 <syscalls+0x2c0>
    800054b0:	8526                	mv	a0,s1
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	c0c080e7          	jalr	-1012(ra) # 800040be <dirlink>
    800054ba:	00054f63          	bltz	a0,800054d8 <create+0x144>
    800054be:	00492603          	lw	a2,4(s2)
    800054c2:	00003597          	auipc	a1,0x3
    800054c6:	2be58593          	addi	a1,a1,702 # 80008780 <syscalls+0x2c8>
    800054ca:	8526                	mv	a0,s1
    800054cc:	fffff097          	auipc	ra,0xfffff
    800054d0:	bf2080e7          	jalr	-1038(ra) # 800040be <dirlink>
    800054d4:	f80557e3          	bgez	a0,80005462 <create+0xce>
      panic("create dots");
    800054d8:	00003517          	auipc	a0,0x3
    800054dc:	2b050513          	addi	a0,a0,688 # 80008788 <syscalls+0x2d0>
    800054e0:	ffffb097          	auipc	ra,0xffffb
    800054e4:	068080e7          	jalr	104(ra) # 80000548 <panic>
    panic("create: dirlink");
    800054e8:	00003517          	auipc	a0,0x3
    800054ec:	2b050513          	addi	a0,a0,688 # 80008798 <syscalls+0x2e0>
    800054f0:	ffffb097          	auipc	ra,0xffffb
    800054f4:	058080e7          	jalr	88(ra) # 80000548 <panic>
    return 0;
    800054f8:	84aa                	mv	s1,a0
    800054fa:	b731                	j	80005406 <create+0x72>

00000000800054fc <sys_dup>:
{
    800054fc:	7179                	addi	sp,sp,-48
    800054fe:	f406                	sd	ra,40(sp)
    80005500:	f022                	sd	s0,32(sp)
    80005502:	ec26                	sd	s1,24(sp)
    80005504:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005506:	fd840613          	addi	a2,s0,-40
    8000550a:	4581                	li	a1,0
    8000550c:	4501                	li	a0,0
    8000550e:	00000097          	auipc	ra,0x0
    80005512:	ddc080e7          	jalr	-548(ra) # 800052ea <argfd>
    return -1;
    80005516:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005518:	02054363          	bltz	a0,8000553e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000551c:	fd843503          	ld	a0,-40(s0)
    80005520:	00000097          	auipc	ra,0x0
    80005524:	e32080e7          	jalr	-462(ra) # 80005352 <fdalloc>
    80005528:	84aa                	mv	s1,a0
    return -1;
    8000552a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000552c:	00054963          	bltz	a0,8000553e <sys_dup+0x42>
  filedup(f);
    80005530:	fd843503          	ld	a0,-40(s0)
    80005534:	fffff097          	auipc	ra,0xfffff
    80005538:	2d8080e7          	jalr	728(ra) # 8000480c <filedup>
  return fd;
    8000553c:	87a6                	mv	a5,s1
}
    8000553e:	853e                	mv	a0,a5
    80005540:	70a2                	ld	ra,40(sp)
    80005542:	7402                	ld	s0,32(sp)
    80005544:	64e2                	ld	s1,24(sp)
    80005546:	6145                	addi	sp,sp,48
    80005548:	8082                	ret

000000008000554a <sys_read>:
{
    8000554a:	7179                	addi	sp,sp,-48
    8000554c:	f406                	sd	ra,40(sp)
    8000554e:	f022                	sd	s0,32(sp)
    80005550:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005552:	fe840613          	addi	a2,s0,-24
    80005556:	4581                	li	a1,0
    80005558:	4501                	li	a0,0
    8000555a:	00000097          	auipc	ra,0x0
    8000555e:	d90080e7          	jalr	-624(ra) # 800052ea <argfd>
    return -1;
    80005562:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005564:	04054163          	bltz	a0,800055a6 <sys_read+0x5c>
    80005568:	fe440593          	addi	a1,s0,-28
    8000556c:	4509                	li	a0,2
    8000556e:	ffffe097          	auipc	ra,0xffffe
    80005572:	8f0080e7          	jalr	-1808(ra) # 80002e5e <argint>
    return -1;
    80005576:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005578:	02054763          	bltz	a0,800055a6 <sys_read+0x5c>
    8000557c:	fd840593          	addi	a1,s0,-40
    80005580:	4505                	li	a0,1
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	8fe080e7          	jalr	-1794(ra) # 80002e80 <argaddr>
    return -1;
    8000558a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000558c:	00054d63          	bltz	a0,800055a6 <sys_read+0x5c>
  return fileread(f, p, n);
    80005590:	fe442603          	lw	a2,-28(s0)
    80005594:	fd843583          	ld	a1,-40(s0)
    80005598:	fe843503          	ld	a0,-24(s0)
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	3fc080e7          	jalr	1020(ra) # 80004998 <fileread>
    800055a4:	87aa                	mv	a5,a0
}
    800055a6:	853e                	mv	a0,a5
    800055a8:	70a2                	ld	ra,40(sp)
    800055aa:	7402                	ld	s0,32(sp)
    800055ac:	6145                	addi	sp,sp,48
    800055ae:	8082                	ret

00000000800055b0 <sys_write>:
{
    800055b0:	7179                	addi	sp,sp,-48
    800055b2:	f406                	sd	ra,40(sp)
    800055b4:	f022                	sd	s0,32(sp)
    800055b6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055b8:	fe840613          	addi	a2,s0,-24
    800055bc:	4581                	li	a1,0
    800055be:	4501                	li	a0,0
    800055c0:	00000097          	auipc	ra,0x0
    800055c4:	d2a080e7          	jalr	-726(ra) # 800052ea <argfd>
    return -1;
    800055c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055ca:	04054163          	bltz	a0,8000560c <sys_write+0x5c>
    800055ce:	fe440593          	addi	a1,s0,-28
    800055d2:	4509                	li	a0,2
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	88a080e7          	jalr	-1910(ra) # 80002e5e <argint>
    return -1;
    800055dc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055de:	02054763          	bltz	a0,8000560c <sys_write+0x5c>
    800055e2:	fd840593          	addi	a1,s0,-40
    800055e6:	4505                	li	a0,1
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	898080e7          	jalr	-1896(ra) # 80002e80 <argaddr>
    return -1;
    800055f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055f2:	00054d63          	bltz	a0,8000560c <sys_write+0x5c>
  return filewrite(f, p, n);
    800055f6:	fe442603          	lw	a2,-28(s0)
    800055fa:	fd843583          	ld	a1,-40(s0)
    800055fe:	fe843503          	ld	a0,-24(s0)
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	458080e7          	jalr	1112(ra) # 80004a5a <filewrite>
    8000560a:	87aa                	mv	a5,a0
}
    8000560c:	853e                	mv	a0,a5
    8000560e:	70a2                	ld	ra,40(sp)
    80005610:	7402                	ld	s0,32(sp)
    80005612:	6145                	addi	sp,sp,48
    80005614:	8082                	ret

0000000080005616 <sys_close>:
{
    80005616:	1101                	addi	sp,sp,-32
    80005618:	ec06                	sd	ra,24(sp)
    8000561a:	e822                	sd	s0,16(sp)
    8000561c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000561e:	fe040613          	addi	a2,s0,-32
    80005622:	fec40593          	addi	a1,s0,-20
    80005626:	4501                	li	a0,0
    80005628:	00000097          	auipc	ra,0x0
    8000562c:	cc2080e7          	jalr	-830(ra) # 800052ea <argfd>
    return -1;
    80005630:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005632:	02054463          	bltz	a0,8000565a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005636:	ffffc097          	auipc	ra,0xffffc
    8000563a:	59a080e7          	jalr	1434(ra) # 80001bd0 <myproc>
    8000563e:	fec42783          	lw	a5,-20(s0)
    80005642:	07e9                	addi	a5,a5,26
    80005644:	078e                	slli	a5,a5,0x3
    80005646:	97aa                	add	a5,a5,a0
    80005648:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000564c:	fe043503          	ld	a0,-32(s0)
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	20e080e7          	jalr	526(ra) # 8000485e <fileclose>
  return 0;
    80005658:	4781                	li	a5,0
}
    8000565a:	853e                	mv	a0,a5
    8000565c:	60e2                	ld	ra,24(sp)
    8000565e:	6442                	ld	s0,16(sp)
    80005660:	6105                	addi	sp,sp,32
    80005662:	8082                	ret

0000000080005664 <sys_fstat>:
{
    80005664:	1101                	addi	sp,sp,-32
    80005666:	ec06                	sd	ra,24(sp)
    80005668:	e822                	sd	s0,16(sp)
    8000566a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000566c:	fe840613          	addi	a2,s0,-24
    80005670:	4581                	li	a1,0
    80005672:	4501                	li	a0,0
    80005674:	00000097          	auipc	ra,0x0
    80005678:	c76080e7          	jalr	-906(ra) # 800052ea <argfd>
    return -1;
    8000567c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000567e:	02054563          	bltz	a0,800056a8 <sys_fstat+0x44>
    80005682:	fe040593          	addi	a1,s0,-32
    80005686:	4505                	li	a0,1
    80005688:	ffffd097          	auipc	ra,0xffffd
    8000568c:	7f8080e7          	jalr	2040(ra) # 80002e80 <argaddr>
    return -1;
    80005690:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005692:	00054b63          	bltz	a0,800056a8 <sys_fstat+0x44>
  return filestat(f, st);
    80005696:	fe043583          	ld	a1,-32(s0)
    8000569a:	fe843503          	ld	a0,-24(s0)
    8000569e:	fffff097          	auipc	ra,0xfffff
    800056a2:	288080e7          	jalr	648(ra) # 80004926 <filestat>
    800056a6:	87aa                	mv	a5,a0
}
    800056a8:	853e                	mv	a0,a5
    800056aa:	60e2                	ld	ra,24(sp)
    800056ac:	6442                	ld	s0,16(sp)
    800056ae:	6105                	addi	sp,sp,32
    800056b0:	8082                	ret

00000000800056b2 <sys_link>:
{
    800056b2:	7169                	addi	sp,sp,-304
    800056b4:	f606                	sd	ra,296(sp)
    800056b6:	f222                	sd	s0,288(sp)
    800056b8:	ee26                	sd	s1,280(sp)
    800056ba:	ea4a                	sd	s2,272(sp)
    800056bc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056be:	08000613          	li	a2,128
    800056c2:	ed040593          	addi	a1,s0,-304
    800056c6:	4501                	li	a0,0
    800056c8:	ffffd097          	auipc	ra,0xffffd
    800056cc:	7da080e7          	jalr	2010(ra) # 80002ea2 <argstr>
    return -1;
    800056d0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056d2:	10054e63          	bltz	a0,800057ee <sys_link+0x13c>
    800056d6:	08000613          	li	a2,128
    800056da:	f5040593          	addi	a1,s0,-176
    800056de:	4505                	li	a0,1
    800056e0:	ffffd097          	auipc	ra,0xffffd
    800056e4:	7c2080e7          	jalr	1986(ra) # 80002ea2 <argstr>
    return -1;
    800056e8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056ea:	10054263          	bltz	a0,800057ee <sys_link+0x13c>
  begin_op();
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	c9e080e7          	jalr	-866(ra) # 8000438c <begin_op>
  if((ip = namei(old)) == 0){
    800056f6:	ed040513          	addi	a0,s0,-304
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	a86080e7          	jalr	-1402(ra) # 80004180 <namei>
    80005702:	84aa                	mv	s1,a0
    80005704:	c551                	beqz	a0,80005790 <sys_link+0xde>
  ilock(ip);
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	2ca080e7          	jalr	714(ra) # 800039d0 <ilock>
  if(ip->type == T_DIR){
    8000570e:	04449703          	lh	a4,68(s1)
    80005712:	4785                	li	a5,1
    80005714:	08f70463          	beq	a4,a5,8000579c <sys_link+0xea>
  ip->nlink++;
    80005718:	04a4d783          	lhu	a5,74(s1)
    8000571c:	2785                	addiw	a5,a5,1
    8000571e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005722:	8526                	mv	a0,s1
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	1e2080e7          	jalr	482(ra) # 80003906 <iupdate>
  iunlock(ip);
    8000572c:	8526                	mv	a0,s1
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	364080e7          	jalr	868(ra) # 80003a92 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005736:	fd040593          	addi	a1,s0,-48
    8000573a:	f5040513          	addi	a0,s0,-176
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	a60080e7          	jalr	-1440(ra) # 8000419e <nameiparent>
    80005746:	892a                	mv	s2,a0
    80005748:	c935                	beqz	a0,800057bc <sys_link+0x10a>
  ilock(dp);
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	286080e7          	jalr	646(ra) # 800039d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005752:	00092703          	lw	a4,0(s2)
    80005756:	409c                	lw	a5,0(s1)
    80005758:	04f71d63          	bne	a4,a5,800057b2 <sys_link+0x100>
    8000575c:	40d0                	lw	a2,4(s1)
    8000575e:	fd040593          	addi	a1,s0,-48
    80005762:	854a                	mv	a0,s2
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	95a080e7          	jalr	-1702(ra) # 800040be <dirlink>
    8000576c:	04054363          	bltz	a0,800057b2 <sys_link+0x100>
  iunlockput(dp);
    80005770:	854a                	mv	a0,s2
    80005772:	ffffe097          	auipc	ra,0xffffe
    80005776:	4c0080e7          	jalr	1216(ra) # 80003c32 <iunlockput>
  iput(ip);
    8000577a:	8526                	mv	a0,s1
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	40e080e7          	jalr	1038(ra) # 80003b8a <iput>
  end_op();
    80005784:	fffff097          	auipc	ra,0xfffff
    80005788:	c88080e7          	jalr	-888(ra) # 8000440c <end_op>
  return 0;
    8000578c:	4781                	li	a5,0
    8000578e:	a085                	j	800057ee <sys_link+0x13c>
    end_op();
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	c7c080e7          	jalr	-900(ra) # 8000440c <end_op>
    return -1;
    80005798:	57fd                	li	a5,-1
    8000579a:	a891                	j	800057ee <sys_link+0x13c>
    iunlockput(ip);
    8000579c:	8526                	mv	a0,s1
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	494080e7          	jalr	1172(ra) # 80003c32 <iunlockput>
    end_op();
    800057a6:	fffff097          	auipc	ra,0xfffff
    800057aa:	c66080e7          	jalr	-922(ra) # 8000440c <end_op>
    return -1;
    800057ae:	57fd                	li	a5,-1
    800057b0:	a83d                	j	800057ee <sys_link+0x13c>
    iunlockput(dp);
    800057b2:	854a                	mv	a0,s2
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	47e080e7          	jalr	1150(ra) # 80003c32 <iunlockput>
  ilock(ip);
    800057bc:	8526                	mv	a0,s1
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	212080e7          	jalr	530(ra) # 800039d0 <ilock>
  ip->nlink--;
    800057c6:	04a4d783          	lhu	a5,74(s1)
    800057ca:	37fd                	addiw	a5,a5,-1
    800057cc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057d0:	8526                	mv	a0,s1
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	134080e7          	jalr	308(ra) # 80003906 <iupdate>
  iunlockput(ip);
    800057da:	8526                	mv	a0,s1
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	456080e7          	jalr	1110(ra) # 80003c32 <iunlockput>
  end_op();
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	c28080e7          	jalr	-984(ra) # 8000440c <end_op>
  return -1;
    800057ec:	57fd                	li	a5,-1
}
    800057ee:	853e                	mv	a0,a5
    800057f0:	70b2                	ld	ra,296(sp)
    800057f2:	7412                	ld	s0,288(sp)
    800057f4:	64f2                	ld	s1,280(sp)
    800057f6:	6952                	ld	s2,272(sp)
    800057f8:	6155                	addi	sp,sp,304
    800057fa:	8082                	ret

00000000800057fc <sys_unlink>:
{
    800057fc:	7151                	addi	sp,sp,-240
    800057fe:	f586                	sd	ra,232(sp)
    80005800:	f1a2                	sd	s0,224(sp)
    80005802:	eda6                	sd	s1,216(sp)
    80005804:	e9ca                	sd	s2,208(sp)
    80005806:	e5ce                	sd	s3,200(sp)
    80005808:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000580a:	08000613          	li	a2,128
    8000580e:	f3040593          	addi	a1,s0,-208
    80005812:	4501                	li	a0,0
    80005814:	ffffd097          	auipc	ra,0xffffd
    80005818:	68e080e7          	jalr	1678(ra) # 80002ea2 <argstr>
    8000581c:	18054163          	bltz	a0,8000599e <sys_unlink+0x1a2>
  begin_op();
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	b6c080e7          	jalr	-1172(ra) # 8000438c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005828:	fb040593          	addi	a1,s0,-80
    8000582c:	f3040513          	addi	a0,s0,-208
    80005830:	fffff097          	auipc	ra,0xfffff
    80005834:	96e080e7          	jalr	-1682(ra) # 8000419e <nameiparent>
    80005838:	84aa                	mv	s1,a0
    8000583a:	c979                	beqz	a0,80005910 <sys_unlink+0x114>
  ilock(dp);
    8000583c:	ffffe097          	auipc	ra,0xffffe
    80005840:	194080e7          	jalr	404(ra) # 800039d0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005844:	00003597          	auipc	a1,0x3
    80005848:	f3458593          	addi	a1,a1,-204 # 80008778 <syscalls+0x2c0>
    8000584c:	fb040513          	addi	a0,s0,-80
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	644080e7          	jalr	1604(ra) # 80003e94 <namecmp>
    80005858:	14050a63          	beqz	a0,800059ac <sys_unlink+0x1b0>
    8000585c:	00003597          	auipc	a1,0x3
    80005860:	f2458593          	addi	a1,a1,-220 # 80008780 <syscalls+0x2c8>
    80005864:	fb040513          	addi	a0,s0,-80
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	62c080e7          	jalr	1580(ra) # 80003e94 <namecmp>
    80005870:	12050e63          	beqz	a0,800059ac <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005874:	f2c40613          	addi	a2,s0,-212
    80005878:	fb040593          	addi	a1,s0,-80
    8000587c:	8526                	mv	a0,s1
    8000587e:	ffffe097          	auipc	ra,0xffffe
    80005882:	630080e7          	jalr	1584(ra) # 80003eae <dirlookup>
    80005886:	892a                	mv	s2,a0
    80005888:	12050263          	beqz	a0,800059ac <sys_unlink+0x1b0>
  ilock(ip);
    8000588c:	ffffe097          	auipc	ra,0xffffe
    80005890:	144080e7          	jalr	324(ra) # 800039d0 <ilock>
  if(ip->nlink < 1)
    80005894:	04a91783          	lh	a5,74(s2)
    80005898:	08f05263          	blez	a5,8000591c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000589c:	04491703          	lh	a4,68(s2)
    800058a0:	4785                	li	a5,1
    800058a2:	08f70563          	beq	a4,a5,8000592c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800058a6:	4641                	li	a2,16
    800058a8:	4581                	li	a1,0
    800058aa:	fc040513          	addi	a0,s0,-64
    800058ae:	ffffb097          	auipc	ra,0xffffb
    800058b2:	45e080e7          	jalr	1118(ra) # 80000d0c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058b6:	4741                	li	a4,16
    800058b8:	f2c42683          	lw	a3,-212(s0)
    800058bc:	fc040613          	addi	a2,s0,-64
    800058c0:	4581                	li	a1,0
    800058c2:	8526                	mv	a0,s1
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	4b6080e7          	jalr	1206(ra) # 80003d7a <writei>
    800058cc:	47c1                	li	a5,16
    800058ce:	0af51563          	bne	a0,a5,80005978 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800058d2:	04491703          	lh	a4,68(s2)
    800058d6:	4785                	li	a5,1
    800058d8:	0af70863          	beq	a4,a5,80005988 <sys_unlink+0x18c>
  iunlockput(dp);
    800058dc:	8526                	mv	a0,s1
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	354080e7          	jalr	852(ra) # 80003c32 <iunlockput>
  ip->nlink--;
    800058e6:	04a95783          	lhu	a5,74(s2)
    800058ea:	37fd                	addiw	a5,a5,-1
    800058ec:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058f0:	854a                	mv	a0,s2
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	014080e7          	jalr	20(ra) # 80003906 <iupdate>
  iunlockput(ip);
    800058fa:	854a                	mv	a0,s2
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	336080e7          	jalr	822(ra) # 80003c32 <iunlockput>
  end_op();
    80005904:	fffff097          	auipc	ra,0xfffff
    80005908:	b08080e7          	jalr	-1272(ra) # 8000440c <end_op>
  return 0;
    8000590c:	4501                	li	a0,0
    8000590e:	a84d                	j	800059c0 <sys_unlink+0x1c4>
    end_op();
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	afc080e7          	jalr	-1284(ra) # 8000440c <end_op>
    return -1;
    80005918:	557d                	li	a0,-1
    8000591a:	a05d                	j	800059c0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000591c:	00003517          	auipc	a0,0x3
    80005920:	e8c50513          	addi	a0,a0,-372 # 800087a8 <syscalls+0x2f0>
    80005924:	ffffb097          	auipc	ra,0xffffb
    80005928:	c24080e7          	jalr	-988(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000592c:	04c92703          	lw	a4,76(s2)
    80005930:	02000793          	li	a5,32
    80005934:	f6e7f9e3          	bgeu	a5,a4,800058a6 <sys_unlink+0xaa>
    80005938:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000593c:	4741                	li	a4,16
    8000593e:	86ce                	mv	a3,s3
    80005940:	f1840613          	addi	a2,s0,-232
    80005944:	4581                	li	a1,0
    80005946:	854a                	mv	a0,s2
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	33c080e7          	jalr	828(ra) # 80003c84 <readi>
    80005950:	47c1                	li	a5,16
    80005952:	00f51b63          	bne	a0,a5,80005968 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005956:	f1845783          	lhu	a5,-232(s0)
    8000595a:	e7a1                	bnez	a5,800059a2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000595c:	29c1                	addiw	s3,s3,16
    8000595e:	04c92783          	lw	a5,76(s2)
    80005962:	fcf9ede3          	bltu	s3,a5,8000593c <sys_unlink+0x140>
    80005966:	b781                	j	800058a6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005968:	00003517          	auipc	a0,0x3
    8000596c:	e5850513          	addi	a0,a0,-424 # 800087c0 <syscalls+0x308>
    80005970:	ffffb097          	auipc	ra,0xffffb
    80005974:	bd8080e7          	jalr	-1064(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005978:	00003517          	auipc	a0,0x3
    8000597c:	e6050513          	addi	a0,a0,-416 # 800087d8 <syscalls+0x320>
    80005980:	ffffb097          	auipc	ra,0xffffb
    80005984:	bc8080e7          	jalr	-1080(ra) # 80000548 <panic>
    dp->nlink--;
    80005988:	04a4d783          	lhu	a5,74(s1)
    8000598c:	37fd                	addiw	a5,a5,-1
    8000598e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005992:	8526                	mv	a0,s1
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	f72080e7          	jalr	-142(ra) # 80003906 <iupdate>
    8000599c:	b781                	j	800058dc <sys_unlink+0xe0>
    return -1;
    8000599e:	557d                	li	a0,-1
    800059a0:	a005                	j	800059c0 <sys_unlink+0x1c4>
    iunlockput(ip);
    800059a2:	854a                	mv	a0,s2
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	28e080e7          	jalr	654(ra) # 80003c32 <iunlockput>
  iunlockput(dp);
    800059ac:	8526                	mv	a0,s1
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	284080e7          	jalr	644(ra) # 80003c32 <iunlockput>
  end_op();
    800059b6:	fffff097          	auipc	ra,0xfffff
    800059ba:	a56080e7          	jalr	-1450(ra) # 8000440c <end_op>
  return -1;
    800059be:	557d                	li	a0,-1
}
    800059c0:	70ae                	ld	ra,232(sp)
    800059c2:	740e                	ld	s0,224(sp)
    800059c4:	64ee                	ld	s1,216(sp)
    800059c6:	694e                	ld	s2,208(sp)
    800059c8:	69ae                	ld	s3,200(sp)
    800059ca:	616d                	addi	sp,sp,240
    800059cc:	8082                	ret

00000000800059ce <sys_open>:

uint64
sys_open(void)
{
    800059ce:	7131                	addi	sp,sp,-192
    800059d0:	fd06                	sd	ra,184(sp)
    800059d2:	f922                	sd	s0,176(sp)
    800059d4:	f526                	sd	s1,168(sp)
    800059d6:	f14a                	sd	s2,160(sp)
    800059d8:	ed4e                	sd	s3,152(sp)
    800059da:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059dc:	08000613          	li	a2,128
    800059e0:	f5040593          	addi	a1,s0,-176
    800059e4:	4501                	li	a0,0
    800059e6:	ffffd097          	auipc	ra,0xffffd
    800059ea:	4bc080e7          	jalr	1212(ra) # 80002ea2 <argstr>
    return -1;
    800059ee:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059f0:	0c054163          	bltz	a0,80005ab2 <sys_open+0xe4>
    800059f4:	f4c40593          	addi	a1,s0,-180
    800059f8:	4505                	li	a0,1
    800059fa:	ffffd097          	auipc	ra,0xffffd
    800059fe:	464080e7          	jalr	1124(ra) # 80002e5e <argint>
    80005a02:	0a054863          	bltz	a0,80005ab2 <sys_open+0xe4>

  begin_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	986080e7          	jalr	-1658(ra) # 8000438c <begin_op>

  if(omode & O_CREATE){
    80005a0e:	f4c42783          	lw	a5,-180(s0)
    80005a12:	2007f793          	andi	a5,a5,512
    80005a16:	cbdd                	beqz	a5,80005acc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a18:	4681                	li	a3,0
    80005a1a:	4601                	li	a2,0
    80005a1c:	4589                	li	a1,2
    80005a1e:	f5040513          	addi	a0,s0,-176
    80005a22:	00000097          	auipc	ra,0x0
    80005a26:	972080e7          	jalr	-1678(ra) # 80005394 <create>
    80005a2a:	892a                	mv	s2,a0
    if(ip == 0){
    80005a2c:	c959                	beqz	a0,80005ac2 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a2e:	04491703          	lh	a4,68(s2)
    80005a32:	478d                	li	a5,3
    80005a34:	00f71763          	bne	a4,a5,80005a42 <sys_open+0x74>
    80005a38:	04695703          	lhu	a4,70(s2)
    80005a3c:	47a5                	li	a5,9
    80005a3e:	0ce7ec63          	bltu	a5,a4,80005b16 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	d60080e7          	jalr	-672(ra) # 800047a2 <filealloc>
    80005a4a:	89aa                	mv	s3,a0
    80005a4c:	10050263          	beqz	a0,80005b50 <sys_open+0x182>
    80005a50:	00000097          	auipc	ra,0x0
    80005a54:	902080e7          	jalr	-1790(ra) # 80005352 <fdalloc>
    80005a58:	84aa                	mv	s1,a0
    80005a5a:	0e054663          	bltz	a0,80005b46 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a5e:	04491703          	lh	a4,68(s2)
    80005a62:	478d                	li	a5,3
    80005a64:	0cf70463          	beq	a4,a5,80005b2c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a68:	4789                	li	a5,2
    80005a6a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a6e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a72:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a76:	f4c42783          	lw	a5,-180(s0)
    80005a7a:	0017c713          	xori	a4,a5,1
    80005a7e:	8b05                	andi	a4,a4,1
    80005a80:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a84:	0037f713          	andi	a4,a5,3
    80005a88:	00e03733          	snez	a4,a4
    80005a8c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a90:	4007f793          	andi	a5,a5,1024
    80005a94:	c791                	beqz	a5,80005aa0 <sys_open+0xd2>
    80005a96:	04491703          	lh	a4,68(s2)
    80005a9a:	4789                	li	a5,2
    80005a9c:	08f70f63          	beq	a4,a5,80005b3a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005aa0:	854a                	mv	a0,s2
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	ff0080e7          	jalr	-16(ra) # 80003a92 <iunlock>
  end_op();
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	962080e7          	jalr	-1694(ra) # 8000440c <end_op>

  return fd;
}
    80005ab2:	8526                	mv	a0,s1
    80005ab4:	70ea                	ld	ra,184(sp)
    80005ab6:	744a                	ld	s0,176(sp)
    80005ab8:	74aa                	ld	s1,168(sp)
    80005aba:	790a                	ld	s2,160(sp)
    80005abc:	69ea                	ld	s3,152(sp)
    80005abe:	6129                	addi	sp,sp,192
    80005ac0:	8082                	ret
      end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	94a080e7          	jalr	-1718(ra) # 8000440c <end_op>
      return -1;
    80005aca:	b7e5                	j	80005ab2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005acc:	f5040513          	addi	a0,s0,-176
    80005ad0:	ffffe097          	auipc	ra,0xffffe
    80005ad4:	6b0080e7          	jalr	1712(ra) # 80004180 <namei>
    80005ad8:	892a                	mv	s2,a0
    80005ada:	c905                	beqz	a0,80005b0a <sys_open+0x13c>
    ilock(ip);
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	ef4080e7          	jalr	-268(ra) # 800039d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ae4:	04491703          	lh	a4,68(s2)
    80005ae8:	4785                	li	a5,1
    80005aea:	f4f712e3          	bne	a4,a5,80005a2e <sys_open+0x60>
    80005aee:	f4c42783          	lw	a5,-180(s0)
    80005af2:	dba1                	beqz	a5,80005a42 <sys_open+0x74>
      iunlockput(ip);
    80005af4:	854a                	mv	a0,s2
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	13c080e7          	jalr	316(ra) # 80003c32 <iunlockput>
      end_op();
    80005afe:	fffff097          	auipc	ra,0xfffff
    80005b02:	90e080e7          	jalr	-1778(ra) # 8000440c <end_op>
      return -1;
    80005b06:	54fd                	li	s1,-1
    80005b08:	b76d                	j	80005ab2 <sys_open+0xe4>
      end_op();
    80005b0a:	fffff097          	auipc	ra,0xfffff
    80005b0e:	902080e7          	jalr	-1790(ra) # 8000440c <end_op>
      return -1;
    80005b12:	54fd                	li	s1,-1
    80005b14:	bf79                	j	80005ab2 <sys_open+0xe4>
    iunlockput(ip);
    80005b16:	854a                	mv	a0,s2
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	11a080e7          	jalr	282(ra) # 80003c32 <iunlockput>
    end_op();
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	8ec080e7          	jalr	-1812(ra) # 8000440c <end_op>
    return -1;
    80005b28:	54fd                	li	s1,-1
    80005b2a:	b761                	j	80005ab2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b2c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b30:	04691783          	lh	a5,70(s2)
    80005b34:	02f99223          	sh	a5,36(s3)
    80005b38:	bf2d                	j	80005a72 <sys_open+0xa4>
    itrunc(ip);
    80005b3a:	854a                	mv	a0,s2
    80005b3c:	ffffe097          	auipc	ra,0xffffe
    80005b40:	fa2080e7          	jalr	-94(ra) # 80003ade <itrunc>
    80005b44:	bfb1                	j	80005aa0 <sys_open+0xd2>
      fileclose(f);
    80005b46:	854e                	mv	a0,s3
    80005b48:	fffff097          	auipc	ra,0xfffff
    80005b4c:	d16080e7          	jalr	-746(ra) # 8000485e <fileclose>
    iunlockput(ip);
    80005b50:	854a                	mv	a0,s2
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	0e0080e7          	jalr	224(ra) # 80003c32 <iunlockput>
    end_op();
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	8b2080e7          	jalr	-1870(ra) # 8000440c <end_op>
    return -1;
    80005b62:	54fd                	li	s1,-1
    80005b64:	b7b9                	j	80005ab2 <sys_open+0xe4>

0000000080005b66 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b66:	7175                	addi	sp,sp,-144
    80005b68:	e506                	sd	ra,136(sp)
    80005b6a:	e122                	sd	s0,128(sp)
    80005b6c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	81e080e7          	jalr	-2018(ra) # 8000438c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b76:	08000613          	li	a2,128
    80005b7a:	f7040593          	addi	a1,s0,-144
    80005b7e:	4501                	li	a0,0
    80005b80:	ffffd097          	auipc	ra,0xffffd
    80005b84:	322080e7          	jalr	802(ra) # 80002ea2 <argstr>
    80005b88:	02054963          	bltz	a0,80005bba <sys_mkdir+0x54>
    80005b8c:	4681                	li	a3,0
    80005b8e:	4601                	li	a2,0
    80005b90:	4585                	li	a1,1
    80005b92:	f7040513          	addi	a0,s0,-144
    80005b96:	fffff097          	auipc	ra,0xfffff
    80005b9a:	7fe080e7          	jalr	2046(ra) # 80005394 <create>
    80005b9e:	cd11                	beqz	a0,80005bba <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ba0:	ffffe097          	auipc	ra,0xffffe
    80005ba4:	092080e7          	jalr	146(ra) # 80003c32 <iunlockput>
  end_op();
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	864080e7          	jalr	-1948(ra) # 8000440c <end_op>
  return 0;
    80005bb0:	4501                	li	a0,0
}
    80005bb2:	60aa                	ld	ra,136(sp)
    80005bb4:	640a                	ld	s0,128(sp)
    80005bb6:	6149                	addi	sp,sp,144
    80005bb8:	8082                	ret
    end_op();
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	852080e7          	jalr	-1966(ra) # 8000440c <end_op>
    return -1;
    80005bc2:	557d                	li	a0,-1
    80005bc4:	b7fd                	j	80005bb2 <sys_mkdir+0x4c>

0000000080005bc6 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005bc6:	7135                	addi	sp,sp,-160
    80005bc8:	ed06                	sd	ra,152(sp)
    80005bca:	e922                	sd	s0,144(sp)
    80005bcc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	7be080e7          	jalr	1982(ra) # 8000438c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bd6:	08000613          	li	a2,128
    80005bda:	f7040593          	addi	a1,s0,-144
    80005bde:	4501                	li	a0,0
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	2c2080e7          	jalr	706(ra) # 80002ea2 <argstr>
    80005be8:	04054a63          	bltz	a0,80005c3c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005bec:	f6c40593          	addi	a1,s0,-148
    80005bf0:	4505                	li	a0,1
    80005bf2:	ffffd097          	auipc	ra,0xffffd
    80005bf6:	26c080e7          	jalr	620(ra) # 80002e5e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bfa:	04054163          	bltz	a0,80005c3c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005bfe:	f6840593          	addi	a1,s0,-152
    80005c02:	4509                	li	a0,2
    80005c04:	ffffd097          	auipc	ra,0xffffd
    80005c08:	25a080e7          	jalr	602(ra) # 80002e5e <argint>
     argint(1, &major) < 0 ||
    80005c0c:	02054863          	bltz	a0,80005c3c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c10:	f6841683          	lh	a3,-152(s0)
    80005c14:	f6c41603          	lh	a2,-148(s0)
    80005c18:	458d                	li	a1,3
    80005c1a:	f7040513          	addi	a0,s0,-144
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	776080e7          	jalr	1910(ra) # 80005394 <create>
     argint(2, &minor) < 0 ||
    80005c26:	c919                	beqz	a0,80005c3c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c28:	ffffe097          	auipc	ra,0xffffe
    80005c2c:	00a080e7          	jalr	10(ra) # 80003c32 <iunlockput>
  end_op();
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	7dc080e7          	jalr	2012(ra) # 8000440c <end_op>
  return 0;
    80005c38:	4501                	li	a0,0
    80005c3a:	a031                	j	80005c46 <sys_mknod+0x80>
    end_op();
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	7d0080e7          	jalr	2000(ra) # 8000440c <end_op>
    return -1;
    80005c44:	557d                	li	a0,-1
}
    80005c46:	60ea                	ld	ra,152(sp)
    80005c48:	644a                	ld	s0,144(sp)
    80005c4a:	610d                	addi	sp,sp,160
    80005c4c:	8082                	ret

0000000080005c4e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c4e:	7135                	addi	sp,sp,-160
    80005c50:	ed06                	sd	ra,152(sp)
    80005c52:	e922                	sd	s0,144(sp)
    80005c54:	e526                	sd	s1,136(sp)
    80005c56:	e14a                	sd	s2,128(sp)
    80005c58:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c5a:	ffffc097          	auipc	ra,0xffffc
    80005c5e:	f76080e7          	jalr	-138(ra) # 80001bd0 <myproc>
    80005c62:	892a                	mv	s2,a0
  
  begin_op();
    80005c64:	ffffe097          	auipc	ra,0xffffe
    80005c68:	728080e7          	jalr	1832(ra) # 8000438c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c6c:	08000613          	li	a2,128
    80005c70:	f6040593          	addi	a1,s0,-160
    80005c74:	4501                	li	a0,0
    80005c76:	ffffd097          	auipc	ra,0xffffd
    80005c7a:	22c080e7          	jalr	556(ra) # 80002ea2 <argstr>
    80005c7e:	04054b63          	bltz	a0,80005cd4 <sys_chdir+0x86>
    80005c82:	f6040513          	addi	a0,s0,-160
    80005c86:	ffffe097          	auipc	ra,0xffffe
    80005c8a:	4fa080e7          	jalr	1274(ra) # 80004180 <namei>
    80005c8e:	84aa                	mv	s1,a0
    80005c90:	c131                	beqz	a0,80005cd4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	d3e080e7          	jalr	-706(ra) # 800039d0 <ilock>
  if(ip->type != T_DIR){
    80005c9a:	04449703          	lh	a4,68(s1)
    80005c9e:	4785                	li	a5,1
    80005ca0:	04f71063          	bne	a4,a5,80005ce0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ca4:	8526                	mv	a0,s1
    80005ca6:	ffffe097          	auipc	ra,0xffffe
    80005caa:	dec080e7          	jalr	-532(ra) # 80003a92 <iunlock>
  iput(p->cwd);
    80005cae:	15093503          	ld	a0,336(s2)
    80005cb2:	ffffe097          	auipc	ra,0xffffe
    80005cb6:	ed8080e7          	jalr	-296(ra) # 80003b8a <iput>
  end_op();
    80005cba:	ffffe097          	auipc	ra,0xffffe
    80005cbe:	752080e7          	jalr	1874(ra) # 8000440c <end_op>
  p->cwd = ip;
    80005cc2:	14993823          	sd	s1,336(s2)
  return 0;
    80005cc6:	4501                	li	a0,0
}
    80005cc8:	60ea                	ld	ra,152(sp)
    80005cca:	644a                	ld	s0,144(sp)
    80005ccc:	64aa                	ld	s1,136(sp)
    80005cce:	690a                	ld	s2,128(sp)
    80005cd0:	610d                	addi	sp,sp,160
    80005cd2:	8082                	ret
    end_op();
    80005cd4:	ffffe097          	auipc	ra,0xffffe
    80005cd8:	738080e7          	jalr	1848(ra) # 8000440c <end_op>
    return -1;
    80005cdc:	557d                	li	a0,-1
    80005cde:	b7ed                	j	80005cc8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005ce0:	8526                	mv	a0,s1
    80005ce2:	ffffe097          	auipc	ra,0xffffe
    80005ce6:	f50080e7          	jalr	-176(ra) # 80003c32 <iunlockput>
    end_op();
    80005cea:	ffffe097          	auipc	ra,0xffffe
    80005cee:	722080e7          	jalr	1826(ra) # 8000440c <end_op>
    return -1;
    80005cf2:	557d                	li	a0,-1
    80005cf4:	bfd1                	j	80005cc8 <sys_chdir+0x7a>

0000000080005cf6 <sys_exec>:

uint64
sys_exec(void)
{
    80005cf6:	7145                	addi	sp,sp,-464
    80005cf8:	e786                	sd	ra,456(sp)
    80005cfa:	e3a2                	sd	s0,448(sp)
    80005cfc:	ff26                	sd	s1,440(sp)
    80005cfe:	fb4a                	sd	s2,432(sp)
    80005d00:	f74e                	sd	s3,424(sp)
    80005d02:	f352                	sd	s4,416(sp)
    80005d04:	ef56                	sd	s5,408(sp)
    80005d06:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d08:	08000613          	li	a2,128
    80005d0c:	f4040593          	addi	a1,s0,-192
    80005d10:	4501                	li	a0,0
    80005d12:	ffffd097          	auipc	ra,0xffffd
    80005d16:	190080e7          	jalr	400(ra) # 80002ea2 <argstr>
    return -1;
    80005d1a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d1c:	0c054a63          	bltz	a0,80005df0 <sys_exec+0xfa>
    80005d20:	e3840593          	addi	a1,s0,-456
    80005d24:	4505                	li	a0,1
    80005d26:	ffffd097          	auipc	ra,0xffffd
    80005d2a:	15a080e7          	jalr	346(ra) # 80002e80 <argaddr>
    80005d2e:	0c054163          	bltz	a0,80005df0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005d32:	10000613          	li	a2,256
    80005d36:	4581                	li	a1,0
    80005d38:	e4040513          	addi	a0,s0,-448
    80005d3c:	ffffb097          	auipc	ra,0xffffb
    80005d40:	fd0080e7          	jalr	-48(ra) # 80000d0c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d44:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d48:	89a6                	mv	s3,s1
    80005d4a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d4c:	02000a13          	li	s4,32
    80005d50:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d54:	00391513          	slli	a0,s2,0x3
    80005d58:	e3040593          	addi	a1,s0,-464
    80005d5c:	e3843783          	ld	a5,-456(s0)
    80005d60:	953e                	add	a0,a0,a5
    80005d62:	ffffd097          	auipc	ra,0xffffd
    80005d66:	062080e7          	jalr	98(ra) # 80002dc4 <fetchaddr>
    80005d6a:	02054a63          	bltz	a0,80005d9e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005d6e:	e3043783          	ld	a5,-464(s0)
    80005d72:	c3b9                	beqz	a5,80005db8 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d74:	ffffb097          	auipc	ra,0xffffb
    80005d78:	dac080e7          	jalr	-596(ra) # 80000b20 <kalloc>
    80005d7c:	85aa                	mv	a1,a0
    80005d7e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d82:	cd11                	beqz	a0,80005d9e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d84:	6605                	lui	a2,0x1
    80005d86:	e3043503          	ld	a0,-464(s0)
    80005d8a:	ffffd097          	auipc	ra,0xffffd
    80005d8e:	08c080e7          	jalr	140(ra) # 80002e16 <fetchstr>
    80005d92:	00054663          	bltz	a0,80005d9e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005d96:	0905                	addi	s2,s2,1
    80005d98:	09a1                	addi	s3,s3,8
    80005d9a:	fb491be3          	bne	s2,s4,80005d50 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d9e:	10048913          	addi	s2,s1,256
    80005da2:	6088                	ld	a0,0(s1)
    80005da4:	c529                	beqz	a0,80005dee <sys_exec+0xf8>
    kfree(argv[i]);
    80005da6:	ffffb097          	auipc	ra,0xffffb
    80005daa:	c7e080e7          	jalr	-898(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dae:	04a1                	addi	s1,s1,8
    80005db0:	ff2499e3          	bne	s1,s2,80005da2 <sys_exec+0xac>
  return -1;
    80005db4:	597d                	li	s2,-1
    80005db6:	a82d                	j	80005df0 <sys_exec+0xfa>
      argv[i] = 0;
    80005db8:	0a8e                	slli	s5,s5,0x3
    80005dba:	fc040793          	addi	a5,s0,-64
    80005dbe:	9abe                	add	s5,s5,a5
    80005dc0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005dc4:	e4040593          	addi	a1,s0,-448
    80005dc8:	f4040513          	addi	a0,s0,-192
    80005dcc:	fffff097          	auipc	ra,0xfffff
    80005dd0:	142080e7          	jalr	322(ra) # 80004f0e <exec>
    80005dd4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dd6:	10048993          	addi	s3,s1,256
    80005dda:	6088                	ld	a0,0(s1)
    80005ddc:	c911                	beqz	a0,80005df0 <sys_exec+0xfa>
    kfree(argv[i]);
    80005dde:	ffffb097          	auipc	ra,0xffffb
    80005de2:	c46080e7          	jalr	-954(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005de6:	04a1                	addi	s1,s1,8
    80005de8:	ff3499e3          	bne	s1,s3,80005dda <sys_exec+0xe4>
    80005dec:	a011                	j	80005df0 <sys_exec+0xfa>
  return -1;
    80005dee:	597d                	li	s2,-1
}
    80005df0:	854a                	mv	a0,s2
    80005df2:	60be                	ld	ra,456(sp)
    80005df4:	641e                	ld	s0,448(sp)
    80005df6:	74fa                	ld	s1,440(sp)
    80005df8:	795a                	ld	s2,432(sp)
    80005dfa:	79ba                	ld	s3,424(sp)
    80005dfc:	7a1a                	ld	s4,416(sp)
    80005dfe:	6afa                	ld	s5,408(sp)
    80005e00:	6179                	addi	sp,sp,464
    80005e02:	8082                	ret

0000000080005e04 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e04:	7139                	addi	sp,sp,-64
    80005e06:	fc06                	sd	ra,56(sp)
    80005e08:	f822                	sd	s0,48(sp)
    80005e0a:	f426                	sd	s1,40(sp)
    80005e0c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e0e:	ffffc097          	auipc	ra,0xffffc
    80005e12:	dc2080e7          	jalr	-574(ra) # 80001bd0 <myproc>
    80005e16:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e18:	fd840593          	addi	a1,s0,-40
    80005e1c:	4501                	li	a0,0
    80005e1e:	ffffd097          	auipc	ra,0xffffd
    80005e22:	062080e7          	jalr	98(ra) # 80002e80 <argaddr>
    return -1;
    80005e26:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005e28:	0e054063          	bltz	a0,80005f08 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005e2c:	fc840593          	addi	a1,s0,-56
    80005e30:	fd040513          	addi	a0,s0,-48
    80005e34:	fffff097          	auipc	ra,0xfffff
    80005e38:	d80080e7          	jalr	-640(ra) # 80004bb4 <pipealloc>
    return -1;
    80005e3c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e3e:	0c054563          	bltz	a0,80005f08 <sys_pipe+0x104>
  fd0 = -1;
    80005e42:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e46:	fd043503          	ld	a0,-48(s0)
    80005e4a:	fffff097          	auipc	ra,0xfffff
    80005e4e:	508080e7          	jalr	1288(ra) # 80005352 <fdalloc>
    80005e52:	fca42223          	sw	a0,-60(s0)
    80005e56:	08054c63          	bltz	a0,80005eee <sys_pipe+0xea>
    80005e5a:	fc843503          	ld	a0,-56(s0)
    80005e5e:	fffff097          	auipc	ra,0xfffff
    80005e62:	4f4080e7          	jalr	1268(ra) # 80005352 <fdalloc>
    80005e66:	fca42023          	sw	a0,-64(s0)
    80005e6a:	06054863          	bltz	a0,80005eda <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e6e:	4691                	li	a3,4
    80005e70:	fc440613          	addi	a2,s0,-60
    80005e74:	fd843583          	ld	a1,-40(s0)
    80005e78:	68a8                	ld	a0,80(s1)
    80005e7a:	ffffc097          	auipc	ra,0xffffc
    80005e7e:	a98080e7          	jalr	-1384(ra) # 80001912 <copyout>
    80005e82:	02054063          	bltz	a0,80005ea2 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e86:	4691                	li	a3,4
    80005e88:	fc040613          	addi	a2,s0,-64
    80005e8c:	fd843583          	ld	a1,-40(s0)
    80005e90:	0591                	addi	a1,a1,4
    80005e92:	68a8                	ld	a0,80(s1)
    80005e94:	ffffc097          	auipc	ra,0xffffc
    80005e98:	a7e080e7          	jalr	-1410(ra) # 80001912 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e9c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e9e:	06055563          	bgez	a0,80005f08 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005ea2:	fc442783          	lw	a5,-60(s0)
    80005ea6:	07e9                	addi	a5,a5,26
    80005ea8:	078e                	slli	a5,a5,0x3
    80005eaa:	97a6                	add	a5,a5,s1
    80005eac:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005eb0:	fc042503          	lw	a0,-64(s0)
    80005eb4:	0569                	addi	a0,a0,26
    80005eb6:	050e                	slli	a0,a0,0x3
    80005eb8:	9526                	add	a0,a0,s1
    80005eba:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005ebe:	fd043503          	ld	a0,-48(s0)
    80005ec2:	fffff097          	auipc	ra,0xfffff
    80005ec6:	99c080e7          	jalr	-1636(ra) # 8000485e <fileclose>
    fileclose(wf);
    80005eca:	fc843503          	ld	a0,-56(s0)
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	990080e7          	jalr	-1648(ra) # 8000485e <fileclose>
    return -1;
    80005ed6:	57fd                	li	a5,-1
    80005ed8:	a805                	j	80005f08 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005eda:	fc442783          	lw	a5,-60(s0)
    80005ede:	0007c863          	bltz	a5,80005eee <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005ee2:	01a78513          	addi	a0,a5,26
    80005ee6:	050e                	slli	a0,a0,0x3
    80005ee8:	9526                	add	a0,a0,s1
    80005eea:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005eee:	fd043503          	ld	a0,-48(s0)
    80005ef2:	fffff097          	auipc	ra,0xfffff
    80005ef6:	96c080e7          	jalr	-1684(ra) # 8000485e <fileclose>
    fileclose(wf);
    80005efa:	fc843503          	ld	a0,-56(s0)
    80005efe:	fffff097          	auipc	ra,0xfffff
    80005f02:	960080e7          	jalr	-1696(ra) # 8000485e <fileclose>
    return -1;
    80005f06:	57fd                	li	a5,-1
}
    80005f08:	853e                	mv	a0,a5
    80005f0a:	70e2                	ld	ra,56(sp)
    80005f0c:	7442                	ld	s0,48(sp)
    80005f0e:	74a2                	ld	s1,40(sp)
    80005f10:	6121                	addi	sp,sp,64
    80005f12:	8082                	ret
	...

0000000080005f20 <kernelvec>:
    80005f20:	7111                	addi	sp,sp,-256
    80005f22:	e006                	sd	ra,0(sp)
    80005f24:	e40a                	sd	sp,8(sp)
    80005f26:	e80e                	sd	gp,16(sp)
    80005f28:	ec12                	sd	tp,24(sp)
    80005f2a:	f016                	sd	t0,32(sp)
    80005f2c:	f41a                	sd	t1,40(sp)
    80005f2e:	f81e                	sd	t2,48(sp)
    80005f30:	fc22                	sd	s0,56(sp)
    80005f32:	e0a6                	sd	s1,64(sp)
    80005f34:	e4aa                	sd	a0,72(sp)
    80005f36:	e8ae                	sd	a1,80(sp)
    80005f38:	ecb2                	sd	a2,88(sp)
    80005f3a:	f0b6                	sd	a3,96(sp)
    80005f3c:	f4ba                	sd	a4,104(sp)
    80005f3e:	f8be                	sd	a5,112(sp)
    80005f40:	fcc2                	sd	a6,120(sp)
    80005f42:	e146                	sd	a7,128(sp)
    80005f44:	e54a                	sd	s2,136(sp)
    80005f46:	e94e                	sd	s3,144(sp)
    80005f48:	ed52                	sd	s4,152(sp)
    80005f4a:	f156                	sd	s5,160(sp)
    80005f4c:	f55a                	sd	s6,168(sp)
    80005f4e:	f95e                	sd	s7,176(sp)
    80005f50:	fd62                	sd	s8,184(sp)
    80005f52:	e1e6                	sd	s9,192(sp)
    80005f54:	e5ea                	sd	s10,200(sp)
    80005f56:	e9ee                	sd	s11,208(sp)
    80005f58:	edf2                	sd	t3,216(sp)
    80005f5a:	f1f6                	sd	t4,224(sp)
    80005f5c:	f5fa                	sd	t5,232(sp)
    80005f5e:	f9fe                	sd	t6,240(sp)
    80005f60:	d31fc0ef          	jal	ra,80002c90 <kerneltrap>
    80005f64:	6082                	ld	ra,0(sp)
    80005f66:	6122                	ld	sp,8(sp)
    80005f68:	61c2                	ld	gp,16(sp)
    80005f6a:	7282                	ld	t0,32(sp)
    80005f6c:	7322                	ld	t1,40(sp)
    80005f6e:	73c2                	ld	t2,48(sp)
    80005f70:	7462                	ld	s0,56(sp)
    80005f72:	6486                	ld	s1,64(sp)
    80005f74:	6526                	ld	a0,72(sp)
    80005f76:	65c6                	ld	a1,80(sp)
    80005f78:	6666                	ld	a2,88(sp)
    80005f7a:	7686                	ld	a3,96(sp)
    80005f7c:	7726                	ld	a4,104(sp)
    80005f7e:	77c6                	ld	a5,112(sp)
    80005f80:	7866                	ld	a6,120(sp)
    80005f82:	688a                	ld	a7,128(sp)
    80005f84:	692a                	ld	s2,136(sp)
    80005f86:	69ca                	ld	s3,144(sp)
    80005f88:	6a6a                	ld	s4,152(sp)
    80005f8a:	7a8a                	ld	s5,160(sp)
    80005f8c:	7b2a                	ld	s6,168(sp)
    80005f8e:	7bca                	ld	s7,176(sp)
    80005f90:	7c6a                	ld	s8,184(sp)
    80005f92:	6c8e                	ld	s9,192(sp)
    80005f94:	6d2e                	ld	s10,200(sp)
    80005f96:	6dce                	ld	s11,208(sp)
    80005f98:	6e6e                	ld	t3,216(sp)
    80005f9a:	7e8e                	ld	t4,224(sp)
    80005f9c:	7f2e                	ld	t5,232(sp)
    80005f9e:	7fce                	ld	t6,240(sp)
    80005fa0:	6111                	addi	sp,sp,256
    80005fa2:	10200073          	sret
    80005fa6:	00000013          	nop
    80005faa:	00000013          	nop
    80005fae:	0001                	nop

0000000080005fb0 <timervec>:
    80005fb0:	34051573          	csrrw	a0,mscratch,a0
    80005fb4:	e10c                	sd	a1,0(a0)
    80005fb6:	e510                	sd	a2,8(a0)
    80005fb8:	e914                	sd	a3,16(a0)
    80005fba:	710c                	ld	a1,32(a0)
    80005fbc:	7510                	ld	a2,40(a0)
    80005fbe:	6194                	ld	a3,0(a1)
    80005fc0:	96b2                	add	a3,a3,a2
    80005fc2:	e194                	sd	a3,0(a1)
    80005fc4:	4589                	li	a1,2
    80005fc6:	14459073          	csrw	sip,a1
    80005fca:	6914                	ld	a3,16(a0)
    80005fcc:	6510                	ld	a2,8(a0)
    80005fce:	610c                	ld	a1,0(a0)
    80005fd0:	34051573          	csrrw	a0,mscratch,a0
    80005fd4:	30200073          	mret
	...

0000000080005fda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005fda:	1141                	addi	sp,sp,-16
    80005fdc:	e422                	sd	s0,8(sp)
    80005fde:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fe0:	0c0007b7          	lui	a5,0xc000
    80005fe4:	4705                	li	a4,1
    80005fe6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fe8:	c3d8                	sw	a4,4(a5)
}
    80005fea:	6422                	ld	s0,8(sp)
    80005fec:	0141                	addi	sp,sp,16
    80005fee:	8082                	ret

0000000080005ff0 <plicinithart>:

void
plicinithart(void)
{
    80005ff0:	1141                	addi	sp,sp,-16
    80005ff2:	e406                	sd	ra,8(sp)
    80005ff4:	e022                	sd	s0,0(sp)
    80005ff6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ff8:	ffffc097          	auipc	ra,0xffffc
    80005ffc:	bac080e7          	jalr	-1108(ra) # 80001ba4 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006000:	0085171b          	slliw	a4,a0,0x8
    80006004:	0c0027b7          	lui	a5,0xc002
    80006008:	97ba                	add	a5,a5,a4
    8000600a:	40200713          	li	a4,1026
    8000600e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006012:	00d5151b          	slliw	a0,a0,0xd
    80006016:	0c2017b7          	lui	a5,0xc201
    8000601a:	953e                	add	a0,a0,a5
    8000601c:	00052023          	sw	zero,0(a0)
}
    80006020:	60a2                	ld	ra,8(sp)
    80006022:	6402                	ld	s0,0(sp)
    80006024:	0141                	addi	sp,sp,16
    80006026:	8082                	ret

0000000080006028 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006028:	1141                	addi	sp,sp,-16
    8000602a:	e406                	sd	ra,8(sp)
    8000602c:	e022                	sd	s0,0(sp)
    8000602e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006030:	ffffc097          	auipc	ra,0xffffc
    80006034:	b74080e7          	jalr	-1164(ra) # 80001ba4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006038:	00d5179b          	slliw	a5,a0,0xd
    8000603c:	0c201537          	lui	a0,0xc201
    80006040:	953e                	add	a0,a0,a5
  return irq;
}
    80006042:	4148                	lw	a0,4(a0)
    80006044:	60a2                	ld	ra,8(sp)
    80006046:	6402                	ld	s0,0(sp)
    80006048:	0141                	addi	sp,sp,16
    8000604a:	8082                	ret

000000008000604c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000604c:	1101                	addi	sp,sp,-32
    8000604e:	ec06                	sd	ra,24(sp)
    80006050:	e822                	sd	s0,16(sp)
    80006052:	e426                	sd	s1,8(sp)
    80006054:	1000                	addi	s0,sp,32
    80006056:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	b4c080e7          	jalr	-1204(ra) # 80001ba4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006060:	00d5151b          	slliw	a0,a0,0xd
    80006064:	0c2017b7          	lui	a5,0xc201
    80006068:	97aa                	add	a5,a5,a0
    8000606a:	c3c4                	sw	s1,4(a5)
}
    8000606c:	60e2                	ld	ra,24(sp)
    8000606e:	6442                	ld	s0,16(sp)
    80006070:	64a2                	ld	s1,8(sp)
    80006072:	6105                	addi	sp,sp,32
    80006074:	8082                	ret

0000000080006076 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006076:	1141                	addi	sp,sp,-16
    80006078:	e406                	sd	ra,8(sp)
    8000607a:	e022                	sd	s0,0(sp)
    8000607c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000607e:	479d                	li	a5,7
    80006080:	04a7cc63          	blt	a5,a0,800060d8 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80006084:	0001d797          	auipc	a5,0x1d
    80006088:	f7c78793          	addi	a5,a5,-132 # 80023000 <disk>
    8000608c:	00a78733          	add	a4,a5,a0
    80006090:	6789                	lui	a5,0x2
    80006092:	97ba                	add	a5,a5,a4
    80006094:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006098:	eba1                	bnez	a5,800060e8 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    8000609a:	00451713          	slli	a4,a0,0x4
    8000609e:	0001f797          	auipc	a5,0x1f
    800060a2:	f627b783          	ld	a5,-158(a5) # 80025000 <disk+0x2000>
    800060a6:	97ba                	add	a5,a5,a4
    800060a8:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    800060ac:	0001d797          	auipc	a5,0x1d
    800060b0:	f5478793          	addi	a5,a5,-172 # 80023000 <disk>
    800060b4:	97aa                	add	a5,a5,a0
    800060b6:	6509                	lui	a0,0x2
    800060b8:	953e                	add	a0,a0,a5
    800060ba:	4785                	li	a5,1
    800060bc:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800060c0:	0001f517          	auipc	a0,0x1f
    800060c4:	f5850513          	addi	a0,a0,-168 # 80025018 <disk+0x2018>
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	66e080e7          	jalr	1646(ra) # 80002736 <wakeup>
}
    800060d0:	60a2                	ld	ra,8(sp)
    800060d2:	6402                	ld	s0,0(sp)
    800060d4:	0141                	addi	sp,sp,16
    800060d6:	8082                	ret
    panic("virtio_disk_intr 1");
    800060d8:	00002517          	auipc	a0,0x2
    800060dc:	71050513          	addi	a0,a0,1808 # 800087e8 <syscalls+0x330>
    800060e0:	ffffa097          	auipc	ra,0xffffa
    800060e4:	468080e7          	jalr	1128(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	71850513          	addi	a0,a0,1816 # 80008800 <syscalls+0x348>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	458080e7          	jalr	1112(ra) # 80000548 <panic>

00000000800060f8 <virtio_disk_init>:
{
    800060f8:	1101                	addi	sp,sp,-32
    800060fa:	ec06                	sd	ra,24(sp)
    800060fc:	e822                	sd	s0,16(sp)
    800060fe:	e426                	sd	s1,8(sp)
    80006100:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006102:	00002597          	auipc	a1,0x2
    80006106:	71658593          	addi	a1,a1,1814 # 80008818 <syscalls+0x360>
    8000610a:	0001f517          	auipc	a0,0x1f
    8000610e:	f9e50513          	addi	a0,a0,-98 # 800250a8 <disk+0x20a8>
    80006112:	ffffb097          	auipc	ra,0xffffb
    80006116:	a6e080e7          	jalr	-1426(ra) # 80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000611a:	100017b7          	lui	a5,0x10001
    8000611e:	4398                	lw	a4,0(a5)
    80006120:	2701                	sext.w	a4,a4
    80006122:	747277b7          	lui	a5,0x74727
    80006126:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000612a:	0ef71163          	bne	a4,a5,8000620c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000612e:	100017b7          	lui	a5,0x10001
    80006132:	43dc                	lw	a5,4(a5)
    80006134:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006136:	4705                	li	a4,1
    80006138:	0ce79a63          	bne	a5,a4,8000620c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000613c:	100017b7          	lui	a5,0x10001
    80006140:	479c                	lw	a5,8(a5)
    80006142:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006144:	4709                	li	a4,2
    80006146:	0ce79363          	bne	a5,a4,8000620c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000614a:	100017b7          	lui	a5,0x10001
    8000614e:	47d8                	lw	a4,12(a5)
    80006150:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006152:	554d47b7          	lui	a5,0x554d4
    80006156:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000615a:	0af71963          	bne	a4,a5,8000620c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000615e:	100017b7          	lui	a5,0x10001
    80006162:	4705                	li	a4,1
    80006164:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006166:	470d                	li	a4,3
    80006168:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000616a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000616c:	c7ffe737          	lui	a4,0xc7ffe
    80006170:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd773f>
    80006174:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006176:	2701                	sext.w	a4,a4
    80006178:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000617a:	472d                	li	a4,11
    8000617c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000617e:	473d                	li	a4,15
    80006180:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006182:	6705                	lui	a4,0x1
    80006184:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006186:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000618a:	5bdc                	lw	a5,52(a5)
    8000618c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000618e:	c7d9                	beqz	a5,8000621c <virtio_disk_init+0x124>
  if(max < NUM)
    80006190:	471d                	li	a4,7
    80006192:	08f77d63          	bgeu	a4,a5,8000622c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006196:	100014b7          	lui	s1,0x10001
    8000619a:	47a1                	li	a5,8
    8000619c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000619e:	6609                	lui	a2,0x2
    800061a0:	4581                	li	a1,0
    800061a2:	0001d517          	auipc	a0,0x1d
    800061a6:	e5e50513          	addi	a0,a0,-418 # 80023000 <disk>
    800061aa:	ffffb097          	auipc	ra,0xffffb
    800061ae:	b62080e7          	jalr	-1182(ra) # 80000d0c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800061b2:	0001d717          	auipc	a4,0x1d
    800061b6:	e4e70713          	addi	a4,a4,-434 # 80023000 <disk>
    800061ba:	00c75793          	srli	a5,a4,0xc
    800061be:	2781                	sext.w	a5,a5
    800061c0:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    800061c2:	0001f797          	auipc	a5,0x1f
    800061c6:	e3e78793          	addi	a5,a5,-450 # 80025000 <disk+0x2000>
    800061ca:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    800061cc:	0001d717          	auipc	a4,0x1d
    800061d0:	eb470713          	addi	a4,a4,-332 # 80023080 <disk+0x80>
    800061d4:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800061d6:	0001e717          	auipc	a4,0x1e
    800061da:	e2a70713          	addi	a4,a4,-470 # 80024000 <disk+0x1000>
    800061de:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800061e0:	4705                	li	a4,1
    800061e2:	00e78c23          	sb	a4,24(a5)
    800061e6:	00e78ca3          	sb	a4,25(a5)
    800061ea:	00e78d23          	sb	a4,26(a5)
    800061ee:	00e78da3          	sb	a4,27(a5)
    800061f2:	00e78e23          	sb	a4,28(a5)
    800061f6:	00e78ea3          	sb	a4,29(a5)
    800061fa:	00e78f23          	sb	a4,30(a5)
    800061fe:	00e78fa3          	sb	a4,31(a5)
}
    80006202:	60e2                	ld	ra,24(sp)
    80006204:	6442                	ld	s0,16(sp)
    80006206:	64a2                	ld	s1,8(sp)
    80006208:	6105                	addi	sp,sp,32
    8000620a:	8082                	ret
    panic("could not find virtio disk");
    8000620c:	00002517          	auipc	a0,0x2
    80006210:	61c50513          	addi	a0,a0,1564 # 80008828 <syscalls+0x370>
    80006214:	ffffa097          	auipc	ra,0xffffa
    80006218:	334080e7          	jalr	820(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    8000621c:	00002517          	auipc	a0,0x2
    80006220:	62c50513          	addi	a0,a0,1580 # 80008848 <syscalls+0x390>
    80006224:	ffffa097          	auipc	ra,0xffffa
    80006228:	324080e7          	jalr	804(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    8000622c:	00002517          	auipc	a0,0x2
    80006230:	63c50513          	addi	a0,a0,1596 # 80008868 <syscalls+0x3b0>
    80006234:	ffffa097          	auipc	ra,0xffffa
    80006238:	314080e7          	jalr	788(ra) # 80000548 <panic>

000000008000623c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000623c:	7119                	addi	sp,sp,-128
    8000623e:	fc86                	sd	ra,120(sp)
    80006240:	f8a2                	sd	s0,112(sp)
    80006242:	f4a6                	sd	s1,104(sp)
    80006244:	f0ca                	sd	s2,96(sp)
    80006246:	ecce                	sd	s3,88(sp)
    80006248:	e8d2                	sd	s4,80(sp)
    8000624a:	e4d6                	sd	s5,72(sp)
    8000624c:	e0da                	sd	s6,64(sp)
    8000624e:	fc5e                	sd	s7,56(sp)
    80006250:	f862                	sd	s8,48(sp)
    80006252:	f466                	sd	s9,40(sp)
    80006254:	f06a                	sd	s10,32(sp)
    80006256:	0100                	addi	s0,sp,128
    80006258:	892a                	mv	s2,a0
    8000625a:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000625c:	00c52c83          	lw	s9,12(a0)
    80006260:	001c9c9b          	slliw	s9,s9,0x1
    80006264:	1c82                	slli	s9,s9,0x20
    80006266:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000626a:	0001f517          	auipc	a0,0x1f
    8000626e:	e3e50513          	addi	a0,a0,-450 # 800250a8 <disk+0x20a8>
    80006272:	ffffb097          	auipc	ra,0xffffb
    80006276:	99e080e7          	jalr	-1634(ra) # 80000c10 <acquire>
  for(int i = 0; i < 3; i++){
    8000627a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000627c:	4c21                	li	s8,8
      disk.free[i] = 0;
    8000627e:	0001db97          	auipc	s7,0x1d
    80006282:	d82b8b93          	addi	s7,s7,-638 # 80023000 <disk>
    80006286:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006288:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    8000628a:	8a4e                	mv	s4,s3
    8000628c:	a051                	j	80006310 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    8000628e:	00fb86b3          	add	a3,s7,a5
    80006292:	96da                	add	a3,a3,s6
    80006294:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006298:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000629a:	0207c563          	bltz	a5,800062c4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000629e:	2485                	addiw	s1,s1,1
    800062a0:	0711                	addi	a4,a4,4
    800062a2:	25548363          	beq	s1,s5,800064e8 <virtio_disk_rw+0x2ac>
    idx[i] = alloc_desc();
    800062a6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800062a8:	0001f697          	auipc	a3,0x1f
    800062ac:	d7068693          	addi	a3,a3,-656 # 80025018 <disk+0x2018>
    800062b0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800062b2:	0006c583          	lbu	a1,0(a3)
    800062b6:	fde1                	bnez	a1,8000628e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800062b8:	2785                	addiw	a5,a5,1
    800062ba:	0685                	addi	a3,a3,1
    800062bc:	ff879be3          	bne	a5,s8,800062b2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800062c0:	57fd                	li	a5,-1
    800062c2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800062c4:	02905a63          	blez	s1,800062f8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800062c8:	f9042503          	lw	a0,-112(s0)
    800062cc:	00000097          	auipc	ra,0x0
    800062d0:	daa080e7          	jalr	-598(ra) # 80006076 <free_desc>
      for(int j = 0; j < i; j++)
    800062d4:	4785                	li	a5,1
    800062d6:	0297d163          	bge	a5,s1,800062f8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800062da:	f9442503          	lw	a0,-108(s0)
    800062de:	00000097          	auipc	ra,0x0
    800062e2:	d98080e7          	jalr	-616(ra) # 80006076 <free_desc>
      for(int j = 0; j < i; j++)
    800062e6:	4789                	li	a5,2
    800062e8:	0097d863          	bge	a5,s1,800062f8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800062ec:	f9842503          	lw	a0,-104(s0)
    800062f0:	00000097          	auipc	ra,0x0
    800062f4:	d86080e7          	jalr	-634(ra) # 80006076 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062f8:	0001f597          	auipc	a1,0x1f
    800062fc:	db058593          	addi	a1,a1,-592 # 800250a8 <disk+0x20a8>
    80006300:	0001f517          	auipc	a0,0x1f
    80006304:	d1850513          	addi	a0,a0,-744 # 80025018 <disk+0x2018>
    80006308:	ffffc097          	auipc	ra,0xffffc
    8000630c:	2a8080e7          	jalr	680(ra) # 800025b0 <sleep>
  for(int i = 0; i < 3; i++){
    80006310:	f9040713          	addi	a4,s0,-112
    80006314:	84ce                	mv	s1,s3
    80006316:	bf41                	j	800062a6 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006318:	4785                	li	a5,1
    8000631a:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000631e:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80006322:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) vmpa(myproc()->kpagetable, (uint64) &buf0);
    80006326:	ffffc097          	auipc	ra,0xffffc
    8000632a:	8aa080e7          	jalr	-1878(ra) # 80001bd0 <myproc>
    8000632e:	f9042983          	lw	s3,-112(s0)
    80006332:	00499493          	slli	s1,s3,0x4
    80006336:	0001fa17          	auipc	s4,0x1f
    8000633a:	ccaa0a13          	addi	s4,s4,-822 # 80025000 <disk+0x2000>
    8000633e:	000a3a83          	ld	s5,0(s4)
    80006342:	9aa6                	add	s5,s5,s1
    80006344:	f8040593          	addi	a1,s0,-128
    80006348:	16853503          	ld	a0,360(a0)
    8000634c:	ffffb097          	auipc	ra,0xffffb
    80006350:	e16080e7          	jalr	-490(ra) # 80001162 <vmpa>
    80006354:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    80006358:	000a3783          	ld	a5,0(s4)
    8000635c:	97a6                	add	a5,a5,s1
    8000635e:	4741                	li	a4,16
    80006360:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006362:	000a3783          	ld	a5,0(s4)
    80006366:	97a6                	add	a5,a5,s1
    80006368:	4705                	li	a4,1
    8000636a:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    8000636e:	f9442703          	lw	a4,-108(s0)
    80006372:	000a3783          	ld	a5,0(s4)
    80006376:	97a6                	add	a5,a5,s1
    80006378:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000637c:	0712                	slli	a4,a4,0x4
    8000637e:	000a3783          	ld	a5,0(s4)
    80006382:	97ba                	add	a5,a5,a4
    80006384:	05890693          	addi	a3,s2,88
    80006388:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000638a:	000a3783          	ld	a5,0(s4)
    8000638e:	97ba                	add	a5,a5,a4
    80006390:	40000693          	li	a3,1024
    80006394:	c794                	sw	a3,8(a5)
  if(write)
    80006396:	100d0a63          	beqz	s10,800064aa <virtio_disk_rw+0x26e>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000639a:	0001f797          	auipc	a5,0x1f
    8000639e:	c667b783          	ld	a5,-922(a5) # 80025000 <disk+0x2000>
    800063a2:	97ba                	add	a5,a5,a4
    800063a4:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063a8:	0001d517          	auipc	a0,0x1d
    800063ac:	c5850513          	addi	a0,a0,-936 # 80023000 <disk>
    800063b0:	0001f797          	auipc	a5,0x1f
    800063b4:	c5078793          	addi	a5,a5,-944 # 80025000 <disk+0x2000>
    800063b8:	6394                	ld	a3,0(a5)
    800063ba:	96ba                	add	a3,a3,a4
    800063bc:	00c6d603          	lhu	a2,12(a3)
    800063c0:	00166613          	ori	a2,a2,1
    800063c4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800063c8:	f9842683          	lw	a3,-104(s0)
    800063cc:	6390                	ld	a2,0(a5)
    800063ce:	9732                	add	a4,a4,a2
    800063d0:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    800063d4:	20098613          	addi	a2,s3,512
    800063d8:	0612                	slli	a2,a2,0x4
    800063da:	962a                	add	a2,a2,a0
    800063dc:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063e0:	00469713          	slli	a4,a3,0x4
    800063e4:	6394                	ld	a3,0(a5)
    800063e6:	96ba                	add	a3,a3,a4
    800063e8:	6589                	lui	a1,0x2
    800063ea:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    800063ee:	94ae                	add	s1,s1,a1
    800063f0:	94aa                	add	s1,s1,a0
    800063f2:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    800063f4:	6394                	ld	a3,0(a5)
    800063f6:	96ba                	add	a3,a3,a4
    800063f8:	4585                	li	a1,1
    800063fa:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063fc:	6394                	ld	a3,0(a5)
    800063fe:	96ba                	add	a3,a3,a4
    80006400:	4509                	li	a0,2
    80006402:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    80006406:	6394                	ld	a3,0(a5)
    80006408:	9736                	add	a4,a4,a3
    8000640a:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000640e:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006412:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80006416:	6794                	ld	a3,8(a5)
    80006418:	0026d703          	lhu	a4,2(a3)
    8000641c:	8b1d                	andi	a4,a4,7
    8000641e:	2709                	addiw	a4,a4,2
    80006420:	0706                	slli	a4,a4,0x1
    80006422:	9736                	add	a4,a4,a3
    80006424:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    80006428:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    8000642c:	6798                	ld	a4,8(a5)
    8000642e:	00275783          	lhu	a5,2(a4)
    80006432:	2785                	addiw	a5,a5,1
    80006434:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006438:	100017b7          	lui	a5,0x10001
    8000643c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006440:	00492703          	lw	a4,4(s2)
    80006444:	4785                	li	a5,1
    80006446:	02f71163          	bne	a4,a5,80006468 <virtio_disk_rw+0x22c>
    sleep(b, &disk.vdisk_lock);
    8000644a:	0001f997          	auipc	s3,0x1f
    8000644e:	c5e98993          	addi	s3,s3,-930 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006452:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006454:	85ce                	mv	a1,s3
    80006456:	854a                	mv	a0,s2
    80006458:	ffffc097          	auipc	ra,0xffffc
    8000645c:	158080e7          	jalr	344(ra) # 800025b0 <sleep>
  while(b->disk == 1) {
    80006460:	00492783          	lw	a5,4(s2)
    80006464:	fe9788e3          	beq	a5,s1,80006454 <virtio_disk_rw+0x218>
  }

  disk.info[idx[0]].b = 0;
    80006468:	f9042483          	lw	s1,-112(s0)
    8000646c:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80006470:	00479713          	slli	a4,a5,0x4
    80006474:	0001d797          	auipc	a5,0x1d
    80006478:	b8c78793          	addi	a5,a5,-1140 # 80023000 <disk>
    8000647c:	97ba                	add	a5,a5,a4
    8000647e:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006482:	0001f917          	auipc	s2,0x1f
    80006486:	b7e90913          	addi	s2,s2,-1154 # 80025000 <disk+0x2000>
    free_desc(i);
    8000648a:	8526                	mv	a0,s1
    8000648c:	00000097          	auipc	ra,0x0
    80006490:	bea080e7          	jalr	-1046(ra) # 80006076 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006494:	0492                	slli	s1,s1,0x4
    80006496:	00093783          	ld	a5,0(s2)
    8000649a:	94be                	add	s1,s1,a5
    8000649c:	00c4d783          	lhu	a5,12(s1)
    800064a0:	8b85                	andi	a5,a5,1
    800064a2:	cf89                	beqz	a5,800064bc <virtio_disk_rw+0x280>
      i = disk.desc[i].next;
    800064a4:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800064a8:	b7cd                	j	8000648a <virtio_disk_rw+0x24e>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800064aa:	0001f797          	auipc	a5,0x1f
    800064ae:	b567b783          	ld	a5,-1194(a5) # 80025000 <disk+0x2000>
    800064b2:	97ba                	add	a5,a5,a4
    800064b4:	4689                	li	a3,2
    800064b6:	00d79623          	sh	a3,12(a5)
    800064ba:	b5fd                	j	800063a8 <virtio_disk_rw+0x16c>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064bc:	0001f517          	auipc	a0,0x1f
    800064c0:	bec50513          	addi	a0,a0,-1044 # 800250a8 <disk+0x20a8>
    800064c4:	ffffb097          	auipc	ra,0xffffb
    800064c8:	800080e7          	jalr	-2048(ra) # 80000cc4 <release>
}
    800064cc:	70e6                	ld	ra,120(sp)
    800064ce:	7446                	ld	s0,112(sp)
    800064d0:	74a6                	ld	s1,104(sp)
    800064d2:	7906                	ld	s2,96(sp)
    800064d4:	69e6                	ld	s3,88(sp)
    800064d6:	6a46                	ld	s4,80(sp)
    800064d8:	6aa6                	ld	s5,72(sp)
    800064da:	6b06                	ld	s6,64(sp)
    800064dc:	7be2                	ld	s7,56(sp)
    800064de:	7c42                	ld	s8,48(sp)
    800064e0:	7ca2                	ld	s9,40(sp)
    800064e2:	7d02                	ld	s10,32(sp)
    800064e4:	6109                	addi	sp,sp,128
    800064e6:	8082                	ret
  if(write)
    800064e8:	e20d18e3          	bnez	s10,80006318 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    800064ec:	f8042023          	sw	zero,-128(s0)
    800064f0:	b53d                	j	8000631e <virtio_disk_rw+0xe2>

00000000800064f2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064f2:	1101                	addi	sp,sp,-32
    800064f4:	ec06                	sd	ra,24(sp)
    800064f6:	e822                	sd	s0,16(sp)
    800064f8:	e426                	sd	s1,8(sp)
    800064fa:	e04a                	sd	s2,0(sp)
    800064fc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064fe:	0001f517          	auipc	a0,0x1f
    80006502:	baa50513          	addi	a0,a0,-1110 # 800250a8 <disk+0x20a8>
    80006506:	ffffa097          	auipc	ra,0xffffa
    8000650a:	70a080e7          	jalr	1802(ra) # 80000c10 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    8000650e:	0001f717          	auipc	a4,0x1f
    80006512:	af270713          	addi	a4,a4,-1294 # 80025000 <disk+0x2000>
    80006516:	02075783          	lhu	a5,32(a4)
    8000651a:	6b18                	ld	a4,16(a4)
    8000651c:	00275683          	lhu	a3,2(a4)
    80006520:	8ebd                	xor	a3,a3,a5
    80006522:	8a9d                	andi	a3,a3,7
    80006524:	cab9                	beqz	a3,8000657a <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    80006526:	0001d917          	auipc	s2,0x1d
    8000652a:	ada90913          	addi	s2,s2,-1318 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    8000652e:	0001f497          	auipc	s1,0x1f
    80006532:	ad248493          	addi	s1,s1,-1326 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    80006536:	078e                	slli	a5,a5,0x3
    80006538:	97ba                	add	a5,a5,a4
    8000653a:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    8000653c:	20078713          	addi	a4,a5,512
    80006540:	0712                	slli	a4,a4,0x4
    80006542:	974a                	add	a4,a4,s2
    80006544:	03074703          	lbu	a4,48(a4)
    80006548:	ef21                	bnez	a4,800065a0 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000654a:	20078793          	addi	a5,a5,512
    8000654e:	0792                	slli	a5,a5,0x4
    80006550:	97ca                	add	a5,a5,s2
    80006552:	7798                	ld	a4,40(a5)
    80006554:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006558:	7788                	ld	a0,40(a5)
    8000655a:	ffffc097          	auipc	ra,0xffffc
    8000655e:	1dc080e7          	jalr	476(ra) # 80002736 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006562:	0204d783          	lhu	a5,32(s1)
    80006566:	2785                	addiw	a5,a5,1
    80006568:	8b9d                	andi	a5,a5,7
    8000656a:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    8000656e:	6898                	ld	a4,16(s1)
    80006570:	00275683          	lhu	a3,2(a4)
    80006574:	8a9d                	andi	a3,a3,7
    80006576:	fcf690e3          	bne	a3,a5,80006536 <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000657a:	10001737          	lui	a4,0x10001
    8000657e:	533c                	lw	a5,96(a4)
    80006580:	8b8d                	andi	a5,a5,3
    80006582:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006584:	0001f517          	auipc	a0,0x1f
    80006588:	b2450513          	addi	a0,a0,-1244 # 800250a8 <disk+0x20a8>
    8000658c:	ffffa097          	auipc	ra,0xffffa
    80006590:	738080e7          	jalr	1848(ra) # 80000cc4 <release>
}
    80006594:	60e2                	ld	ra,24(sp)
    80006596:	6442                	ld	s0,16(sp)
    80006598:	64a2                	ld	s1,8(sp)
    8000659a:	6902                	ld	s2,0(sp)
    8000659c:	6105                	addi	sp,sp,32
    8000659e:	8082                	ret
      panic("virtio_disk_intr status");
    800065a0:	00002517          	auipc	a0,0x2
    800065a4:	2e850513          	addi	a0,a0,744 # 80008888 <syscalls+0x3d0>
    800065a8:	ffffa097          	auipc	ra,0xffffa
    800065ac:	fa0080e7          	jalr	-96(ra) # 80000548 <panic>

00000000800065b0 <statscopyin>:
  int ncopyin;
  int ncopyinstr;
} stats;

int
statscopyin(char *buf, int sz) {
    800065b0:	7179                	addi	sp,sp,-48
    800065b2:	f406                	sd	ra,40(sp)
    800065b4:	f022                	sd	s0,32(sp)
    800065b6:	ec26                	sd	s1,24(sp)
    800065b8:	e84a                	sd	s2,16(sp)
    800065ba:	e44e                	sd	s3,8(sp)
    800065bc:	e052                	sd	s4,0(sp)
    800065be:	1800                	addi	s0,sp,48
    800065c0:	892a                	mv	s2,a0
    800065c2:	89ae                	mv	s3,a1
  int n;
  n = snprintf(buf, sz, "copyin: %d\n", stats.ncopyin);
    800065c4:	00003a17          	auipc	s4,0x3
    800065c8:	a64a0a13          	addi	s4,s4,-1436 # 80009028 <stats>
    800065cc:	000a2683          	lw	a3,0(s4)
    800065d0:	00002617          	auipc	a2,0x2
    800065d4:	2d060613          	addi	a2,a2,720 # 800088a0 <syscalls+0x3e8>
    800065d8:	00000097          	auipc	ra,0x0
    800065dc:	2c2080e7          	jalr	706(ra) # 8000689a <snprintf>
    800065e0:	84aa                	mv	s1,a0
  n += snprintf(buf+n, sz, "copyinstr: %d\n", stats.ncopyinstr);
    800065e2:	004a2683          	lw	a3,4(s4)
    800065e6:	00002617          	auipc	a2,0x2
    800065ea:	2ca60613          	addi	a2,a2,714 # 800088b0 <syscalls+0x3f8>
    800065ee:	85ce                	mv	a1,s3
    800065f0:	954a                	add	a0,a0,s2
    800065f2:	00000097          	auipc	ra,0x0
    800065f6:	2a8080e7          	jalr	680(ra) # 8000689a <snprintf>
  return n;
}
    800065fa:	9d25                	addw	a0,a0,s1
    800065fc:	70a2                	ld	ra,40(sp)
    800065fe:	7402                	ld	s0,32(sp)
    80006600:	64e2                	ld	s1,24(sp)
    80006602:	6942                	ld	s2,16(sp)
    80006604:	69a2                	ld	s3,8(sp)
    80006606:	6a02                	ld	s4,0(sp)
    80006608:	6145                	addi	sp,sp,48
    8000660a:	8082                	ret

000000008000660c <copyin_new>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    8000660c:	7179                	addi	sp,sp,-48
    8000660e:	f406                	sd	ra,40(sp)
    80006610:	f022                	sd	s0,32(sp)
    80006612:	ec26                	sd	s1,24(sp)
    80006614:	e84a                	sd	s2,16(sp)
    80006616:	e44e                	sd	s3,8(sp)
    80006618:	1800                	addi	s0,sp,48
    8000661a:	89ae                	mv	s3,a1
    8000661c:	84b2                	mv	s1,a2
    8000661e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80006620:	ffffb097          	auipc	ra,0xffffb
    80006624:	5b0080e7          	jalr	1456(ra) # 80001bd0 <myproc>

  if (srcva >= p->sz || srcva+len >= p->sz || srcva+len < srcva)
    80006628:	653c                	ld	a5,72(a0)
    8000662a:	02f4ff63          	bgeu	s1,a5,80006668 <copyin_new+0x5c>
    8000662e:	01248733          	add	a4,s1,s2
    80006632:	02f77d63          	bgeu	a4,a5,8000666c <copyin_new+0x60>
    80006636:	02976d63          	bltu	a4,s1,80006670 <copyin_new+0x64>
    return -1;
  memmove((void *) dst, (void *)srcva, len);
    8000663a:	0009061b          	sext.w	a2,s2
    8000663e:	85a6                	mv	a1,s1
    80006640:	854e                	mv	a0,s3
    80006642:	ffffa097          	auipc	ra,0xffffa
    80006646:	72a080e7          	jalr	1834(ra) # 80000d6c <memmove>
  stats.ncopyin++;   // XXX lock
    8000664a:	00003717          	auipc	a4,0x3
    8000664e:	9de70713          	addi	a4,a4,-1570 # 80009028 <stats>
    80006652:	431c                	lw	a5,0(a4)
    80006654:	2785                	addiw	a5,a5,1
    80006656:	c31c                	sw	a5,0(a4)
  return 0;
    80006658:	4501                	li	a0,0
}
    8000665a:	70a2                	ld	ra,40(sp)
    8000665c:	7402                	ld	s0,32(sp)
    8000665e:	64e2                	ld	s1,24(sp)
    80006660:	6942                	ld	s2,16(sp)
    80006662:	69a2                	ld	s3,8(sp)
    80006664:	6145                	addi	sp,sp,48
    80006666:	8082                	ret
    return -1;
    80006668:	557d                	li	a0,-1
    8000666a:	bfc5                	j	8000665a <copyin_new+0x4e>
    8000666c:	557d                	li	a0,-1
    8000666e:	b7f5                	j	8000665a <copyin_new+0x4e>
    80006670:	557d                	li	a0,-1
    80006672:	b7e5                	j	8000665a <copyin_new+0x4e>

0000000080006674 <copyinstr_new>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    80006674:	7179                	addi	sp,sp,-48
    80006676:	f406                	sd	ra,40(sp)
    80006678:	f022                	sd	s0,32(sp)
    8000667a:	ec26                	sd	s1,24(sp)
    8000667c:	e84a                	sd	s2,16(sp)
    8000667e:	e44e                	sd	s3,8(sp)
    80006680:	1800                	addi	s0,sp,48
    80006682:	89ae                	mv	s3,a1
    80006684:	8932                	mv	s2,a2
    80006686:	84b6                	mv	s1,a3
  struct proc *p = myproc();
    80006688:	ffffb097          	auipc	ra,0xffffb
    8000668c:	548080e7          	jalr	1352(ra) # 80001bd0 <myproc>
  char *s = (char *) srcva;
  
  stats.ncopyinstr++;   // XXX lock
    80006690:	00003717          	auipc	a4,0x3
    80006694:	99870713          	addi	a4,a4,-1640 # 80009028 <stats>
    80006698:	435c                	lw	a5,4(a4)
    8000669a:	2785                	addiw	a5,a5,1
    8000669c:	c35c                	sw	a5,4(a4)
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    8000669e:	cc85                	beqz	s1,800066d6 <copyinstr_new+0x62>
    800066a0:	00990833          	add	a6,s2,s1
    800066a4:	87ca                	mv	a5,s2
    800066a6:	6538                	ld	a4,72(a0)
    800066a8:	00e7ff63          	bgeu	a5,a4,800066c6 <copyinstr_new+0x52>
    dst[i] = s[i];
    800066ac:	0007c683          	lbu	a3,0(a5)
    800066b0:	41278733          	sub	a4,a5,s2
    800066b4:	974e                	add	a4,a4,s3
    800066b6:	00d70023          	sb	a3,0(a4)
    if(s[i] == '\0')
    800066ba:	c285                	beqz	a3,800066da <copyinstr_new+0x66>
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    800066bc:	0785                	addi	a5,a5,1
    800066be:	ff0794e3          	bne	a5,a6,800066a6 <copyinstr_new+0x32>
      return 0;
  }
  return -1;
    800066c2:	557d                	li	a0,-1
    800066c4:	a011                	j	800066c8 <copyinstr_new+0x54>
    800066c6:	557d                	li	a0,-1
}
    800066c8:	70a2                	ld	ra,40(sp)
    800066ca:	7402                	ld	s0,32(sp)
    800066cc:	64e2                	ld	s1,24(sp)
    800066ce:	6942                	ld	s2,16(sp)
    800066d0:	69a2                	ld	s3,8(sp)
    800066d2:	6145                	addi	sp,sp,48
    800066d4:	8082                	ret
  return -1;
    800066d6:	557d                	li	a0,-1
    800066d8:	bfc5                	j	800066c8 <copyinstr_new+0x54>
      return 0;
    800066da:	4501                	li	a0,0
    800066dc:	b7f5                	j	800066c8 <copyinstr_new+0x54>

00000000800066de <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    800066de:	1141                	addi	sp,sp,-16
    800066e0:	e422                	sd	s0,8(sp)
    800066e2:	0800                	addi	s0,sp,16
  return -1;
}
    800066e4:	557d                	li	a0,-1
    800066e6:	6422                	ld	s0,8(sp)
    800066e8:	0141                	addi	sp,sp,16
    800066ea:	8082                	ret

00000000800066ec <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    800066ec:	7179                	addi	sp,sp,-48
    800066ee:	f406                	sd	ra,40(sp)
    800066f0:	f022                	sd	s0,32(sp)
    800066f2:	ec26                	sd	s1,24(sp)
    800066f4:	e84a                	sd	s2,16(sp)
    800066f6:	e44e                	sd	s3,8(sp)
    800066f8:	e052                	sd	s4,0(sp)
    800066fa:	1800                	addi	s0,sp,48
    800066fc:	892a                	mv	s2,a0
    800066fe:	89ae                	mv	s3,a1
    80006700:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    80006702:	00020517          	auipc	a0,0x20
    80006706:	8fe50513          	addi	a0,a0,-1794 # 80026000 <stats>
    8000670a:	ffffa097          	auipc	ra,0xffffa
    8000670e:	506080e7          	jalr	1286(ra) # 80000c10 <acquire>

  if(stats.sz == 0) {
    80006712:	00021797          	auipc	a5,0x21
    80006716:	9067a783          	lw	a5,-1786(a5) # 80027018 <stats+0x1018>
    8000671a:	cbb5                	beqz	a5,8000678e <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    8000671c:	00021797          	auipc	a5,0x21
    80006720:	8e478793          	addi	a5,a5,-1820 # 80027000 <stats+0x1000>
    80006724:	4fd8                	lw	a4,28(a5)
    80006726:	4f9c                	lw	a5,24(a5)
    80006728:	9f99                	subw	a5,a5,a4
    8000672a:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    8000672e:	06d05e63          	blez	a3,800067aa <statsread+0xbe>
    if(m > n)
    80006732:	8a3e                	mv	s4,a5
    80006734:	00d4d363          	bge	s1,a3,8000673a <statsread+0x4e>
    80006738:	8a26                	mv	s4,s1
    8000673a:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    8000673e:	86a6                	mv	a3,s1
    80006740:	00020617          	auipc	a2,0x20
    80006744:	8d860613          	addi	a2,a2,-1832 # 80026018 <stats+0x18>
    80006748:	963a                	add	a2,a2,a4
    8000674a:	85ce                	mv	a1,s3
    8000674c:	854a                	mv	a0,s2
    8000674e:	ffffc097          	auipc	ra,0xffffc
    80006752:	0c4080e7          	jalr	196(ra) # 80002812 <either_copyout>
    80006756:	57fd                	li	a5,-1
    80006758:	00f50a63          	beq	a0,a5,8000676c <statsread+0x80>
      stats.off += m;
    8000675c:	00021717          	auipc	a4,0x21
    80006760:	8a470713          	addi	a4,a4,-1884 # 80027000 <stats+0x1000>
    80006764:	4f5c                	lw	a5,28(a4)
    80006766:	014787bb          	addw	a5,a5,s4
    8000676a:	cf5c                	sw	a5,28(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    8000676c:	00020517          	auipc	a0,0x20
    80006770:	89450513          	addi	a0,a0,-1900 # 80026000 <stats>
    80006774:	ffffa097          	auipc	ra,0xffffa
    80006778:	550080e7          	jalr	1360(ra) # 80000cc4 <release>
  return m;
}
    8000677c:	8526                	mv	a0,s1
    8000677e:	70a2                	ld	ra,40(sp)
    80006780:	7402                	ld	s0,32(sp)
    80006782:	64e2                	ld	s1,24(sp)
    80006784:	6942                	ld	s2,16(sp)
    80006786:	69a2                	ld	s3,8(sp)
    80006788:	6a02                	ld	s4,0(sp)
    8000678a:	6145                	addi	sp,sp,48
    8000678c:	8082                	ret
    stats.sz = statscopyin(stats.buf, BUFSZ);
    8000678e:	6585                	lui	a1,0x1
    80006790:	00020517          	auipc	a0,0x20
    80006794:	88850513          	addi	a0,a0,-1912 # 80026018 <stats+0x18>
    80006798:	00000097          	auipc	ra,0x0
    8000679c:	e18080e7          	jalr	-488(ra) # 800065b0 <statscopyin>
    800067a0:	00021797          	auipc	a5,0x21
    800067a4:	86a7ac23          	sw	a0,-1928(a5) # 80027018 <stats+0x1018>
    800067a8:	bf95                	j	8000671c <statsread+0x30>
    stats.sz = 0;
    800067aa:	00021797          	auipc	a5,0x21
    800067ae:	85678793          	addi	a5,a5,-1962 # 80027000 <stats+0x1000>
    800067b2:	0007ac23          	sw	zero,24(a5)
    stats.off = 0;
    800067b6:	0007ae23          	sw	zero,28(a5)
    m = -1;
    800067ba:	54fd                	li	s1,-1
    800067bc:	bf45                	j	8000676c <statsread+0x80>

00000000800067be <statsinit>:

void
statsinit(void)
{
    800067be:	1141                	addi	sp,sp,-16
    800067c0:	e406                	sd	ra,8(sp)
    800067c2:	e022                	sd	s0,0(sp)
    800067c4:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    800067c6:	00002597          	auipc	a1,0x2
    800067ca:	0fa58593          	addi	a1,a1,250 # 800088c0 <syscalls+0x408>
    800067ce:	00020517          	auipc	a0,0x20
    800067d2:	83250513          	addi	a0,a0,-1998 # 80026000 <stats>
    800067d6:	ffffa097          	auipc	ra,0xffffa
    800067da:	3aa080e7          	jalr	938(ra) # 80000b80 <initlock>

  devsw[STATS].read = statsread;
    800067de:	0001b797          	auipc	a5,0x1b
    800067e2:	3d278793          	addi	a5,a5,978 # 80021bb0 <devsw>
    800067e6:	00000717          	auipc	a4,0x0
    800067ea:	f0670713          	addi	a4,a4,-250 # 800066ec <statsread>
    800067ee:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    800067f0:	00000717          	auipc	a4,0x0
    800067f4:	eee70713          	addi	a4,a4,-274 # 800066de <statswrite>
    800067f8:	f798                	sd	a4,40(a5)
}
    800067fa:	60a2                	ld	ra,8(sp)
    800067fc:	6402                	ld	s0,0(sp)
    800067fe:	0141                	addi	sp,sp,16
    80006800:	8082                	ret

0000000080006802 <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    80006802:	1101                	addi	sp,sp,-32
    80006804:	ec22                	sd	s0,24(sp)
    80006806:	1000                	addi	s0,sp,32
    80006808:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    8000680a:	c299                	beqz	a3,80006810 <sprintint+0xe>
    8000680c:	0805c163          	bltz	a1,8000688e <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    80006810:	2581                	sext.w	a1,a1
    80006812:	4301                	li	t1,0

  i = 0;
    80006814:	fe040713          	addi	a4,s0,-32
    80006818:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    8000681a:	2601                	sext.w	a2,a2
    8000681c:	00002697          	auipc	a3,0x2
    80006820:	0ac68693          	addi	a3,a3,172 # 800088c8 <digits>
    80006824:	88aa                	mv	a7,a0
    80006826:	2505                	addiw	a0,a0,1
    80006828:	02c5f7bb          	remuw	a5,a1,a2
    8000682c:	1782                	slli	a5,a5,0x20
    8000682e:	9381                	srli	a5,a5,0x20
    80006830:	97b6                	add	a5,a5,a3
    80006832:	0007c783          	lbu	a5,0(a5)
    80006836:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    8000683a:	0005879b          	sext.w	a5,a1
    8000683e:	02c5d5bb          	divuw	a1,a1,a2
    80006842:	0705                	addi	a4,a4,1
    80006844:	fec7f0e3          	bgeu	a5,a2,80006824 <sprintint+0x22>

  if(sign)
    80006848:	00030b63          	beqz	t1,8000685e <sprintint+0x5c>
    buf[i++] = '-';
    8000684c:	ff040793          	addi	a5,s0,-16
    80006850:	97aa                	add	a5,a5,a0
    80006852:	02d00713          	li	a4,45
    80006856:	fee78823          	sb	a4,-16(a5)
    8000685a:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    8000685e:	02a05c63          	blez	a0,80006896 <sprintint+0x94>
    80006862:	fe040793          	addi	a5,s0,-32
    80006866:	00a78733          	add	a4,a5,a0
    8000686a:	87c2                	mv	a5,a6
    8000686c:	0805                	addi	a6,a6,1
    8000686e:	fff5061b          	addiw	a2,a0,-1
    80006872:	1602                	slli	a2,a2,0x20
    80006874:	9201                	srli	a2,a2,0x20
    80006876:	9642                	add	a2,a2,a6
  *s = c;
    80006878:	fff74683          	lbu	a3,-1(a4)
    8000687c:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    80006880:	177d                	addi	a4,a4,-1
    80006882:	0785                	addi	a5,a5,1
    80006884:	fec79ae3          	bne	a5,a2,80006878 <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    80006888:	6462                	ld	s0,24(sp)
    8000688a:	6105                	addi	sp,sp,32
    8000688c:	8082                	ret
    x = -xx;
    8000688e:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    80006892:	4305                	li	t1,1
    x = -xx;
    80006894:	b741                	j	80006814 <sprintint+0x12>
  while(--i >= 0)
    80006896:	4501                	li	a0,0
    80006898:	bfc5                	j	80006888 <sprintint+0x86>

000000008000689a <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    8000689a:	7171                	addi	sp,sp,-176
    8000689c:	fc86                	sd	ra,120(sp)
    8000689e:	f8a2                	sd	s0,112(sp)
    800068a0:	f4a6                	sd	s1,104(sp)
    800068a2:	f0ca                	sd	s2,96(sp)
    800068a4:	ecce                	sd	s3,88(sp)
    800068a6:	e8d2                	sd	s4,80(sp)
    800068a8:	e4d6                	sd	s5,72(sp)
    800068aa:	e0da                	sd	s6,64(sp)
    800068ac:	fc5e                	sd	s7,56(sp)
    800068ae:	f862                	sd	s8,48(sp)
    800068b0:	f466                	sd	s9,40(sp)
    800068b2:	f06a                	sd	s10,32(sp)
    800068b4:	ec6e                	sd	s11,24(sp)
    800068b6:	0100                	addi	s0,sp,128
    800068b8:	e414                	sd	a3,8(s0)
    800068ba:	e818                	sd	a4,16(s0)
    800068bc:	ec1c                	sd	a5,24(s0)
    800068be:	03043023          	sd	a6,32(s0)
    800068c2:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    800068c6:	ca0d                	beqz	a2,800068f8 <snprintf+0x5e>
    800068c8:	8baa                	mv	s7,a0
    800068ca:	89ae                	mv	s3,a1
    800068cc:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    800068ce:	00840793          	addi	a5,s0,8
    800068d2:	f8f43423          	sd	a5,-120(s0)
  int off = 0;
    800068d6:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    800068d8:	4901                	li	s2,0
    800068da:	02b05763          	blez	a1,80006908 <snprintf+0x6e>
    if(c != '%'){
    800068de:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    800068e2:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    800068e6:	02800d93          	li	s11,40
  *s = c;
    800068ea:	02500d13          	li	s10,37
    switch(c){
    800068ee:	07800c93          	li	s9,120
    800068f2:	06400c13          	li	s8,100
    800068f6:	a01d                	j	8000691c <snprintf+0x82>
    panic("null fmt");
    800068f8:	00001517          	auipc	a0,0x1
    800068fc:	72050513          	addi	a0,a0,1824 # 80008018 <etext+0x18>
    80006900:	ffffa097          	auipc	ra,0xffffa
    80006904:	c48080e7          	jalr	-952(ra) # 80000548 <panic>
  int off = 0;
    80006908:	4481                	li	s1,0
    8000690a:	a86d                	j	800069c4 <snprintf+0x12a>
  *s = c;
    8000690c:	009b8733          	add	a4,s7,s1
    80006910:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006914:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006916:	2905                	addiw	s2,s2,1
    80006918:	0b34d663          	bge	s1,s3,800069c4 <snprintf+0x12a>
    8000691c:	012a07b3          	add	a5,s4,s2
    80006920:	0007c783          	lbu	a5,0(a5)
    80006924:	0007871b          	sext.w	a4,a5
    80006928:	cfd1                	beqz	a5,800069c4 <snprintf+0x12a>
    if(c != '%'){
    8000692a:	ff5711e3          	bne	a4,s5,8000690c <snprintf+0x72>
    c = fmt[++i] & 0xff;
    8000692e:	2905                	addiw	s2,s2,1
    80006930:	012a07b3          	add	a5,s4,s2
    80006934:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    80006938:	c7d1                	beqz	a5,800069c4 <snprintf+0x12a>
    switch(c){
    8000693a:	05678c63          	beq	a5,s6,80006992 <snprintf+0xf8>
    8000693e:	02fb6763          	bltu	s6,a5,8000696c <snprintf+0xd2>
    80006942:	0b578763          	beq	a5,s5,800069f0 <snprintf+0x156>
    80006946:	0b879b63          	bne	a5,s8,800069fc <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    8000694a:	f8843783          	ld	a5,-120(s0)
    8000694e:	00878713          	addi	a4,a5,8
    80006952:	f8e43423          	sd	a4,-120(s0)
    80006956:	4685                	li	a3,1
    80006958:	4629                	li	a2,10
    8000695a:	438c                	lw	a1,0(a5)
    8000695c:	009b8533          	add	a0,s7,s1
    80006960:	00000097          	auipc	ra,0x0
    80006964:	ea2080e7          	jalr	-350(ra) # 80006802 <sprintint>
    80006968:	9ca9                	addw	s1,s1,a0
      break;
    8000696a:	b775                	j	80006916 <snprintf+0x7c>
    switch(c){
    8000696c:	09979863          	bne	a5,s9,800069fc <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    80006970:	f8843783          	ld	a5,-120(s0)
    80006974:	00878713          	addi	a4,a5,8
    80006978:	f8e43423          	sd	a4,-120(s0)
    8000697c:	4685                	li	a3,1
    8000697e:	4641                	li	a2,16
    80006980:	438c                	lw	a1,0(a5)
    80006982:	009b8533          	add	a0,s7,s1
    80006986:	00000097          	auipc	ra,0x0
    8000698a:	e7c080e7          	jalr	-388(ra) # 80006802 <sprintint>
    8000698e:	9ca9                	addw	s1,s1,a0
      break;
    80006990:	b759                	j	80006916 <snprintf+0x7c>
      if((s = va_arg(ap, char*)) == 0)
    80006992:	f8843783          	ld	a5,-120(s0)
    80006996:	00878713          	addi	a4,a5,8
    8000699a:	f8e43423          	sd	a4,-120(s0)
    8000699e:	639c                	ld	a5,0(a5)
    800069a0:	c3b1                	beqz	a5,800069e4 <snprintf+0x14a>
      for(; *s && off < sz; s++)
    800069a2:	0007c703          	lbu	a4,0(a5)
    800069a6:	db25                	beqz	a4,80006916 <snprintf+0x7c>
    800069a8:	0134de63          	bge	s1,s3,800069c4 <snprintf+0x12a>
    800069ac:	009b86b3          	add	a3,s7,s1
  *s = c;
    800069b0:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    800069b4:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    800069b6:	0785                	addi	a5,a5,1
    800069b8:	0007c703          	lbu	a4,0(a5)
    800069bc:	df29                	beqz	a4,80006916 <snprintf+0x7c>
    800069be:	0685                	addi	a3,a3,1
    800069c0:	fe9998e3          	bne	s3,s1,800069b0 <snprintf+0x116>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    800069c4:	8526                	mv	a0,s1
    800069c6:	70e6                	ld	ra,120(sp)
    800069c8:	7446                	ld	s0,112(sp)
    800069ca:	74a6                	ld	s1,104(sp)
    800069cc:	7906                	ld	s2,96(sp)
    800069ce:	69e6                	ld	s3,88(sp)
    800069d0:	6a46                	ld	s4,80(sp)
    800069d2:	6aa6                	ld	s5,72(sp)
    800069d4:	6b06                	ld	s6,64(sp)
    800069d6:	7be2                	ld	s7,56(sp)
    800069d8:	7c42                	ld	s8,48(sp)
    800069da:	7ca2                	ld	s9,40(sp)
    800069dc:	7d02                	ld	s10,32(sp)
    800069de:	6de2                	ld	s11,24(sp)
    800069e0:	614d                	addi	sp,sp,176
    800069e2:	8082                	ret
        s = "(null)";
    800069e4:	00001797          	auipc	a5,0x1
    800069e8:	62c78793          	addi	a5,a5,1580 # 80008010 <etext+0x10>
      for(; *s && off < sz; s++)
    800069ec:	876e                	mv	a4,s11
    800069ee:	bf6d                	j	800069a8 <snprintf+0x10e>
  *s = c;
    800069f0:	009b87b3          	add	a5,s7,s1
    800069f4:	01a78023          	sb	s10,0(a5)
      off += sputc(buf+off, '%');
    800069f8:	2485                	addiw	s1,s1,1
      break;
    800069fa:	bf31                	j	80006916 <snprintf+0x7c>
  *s = c;
    800069fc:	009b8733          	add	a4,s7,s1
    80006a00:	01a70023          	sb	s10,0(a4)
      off += sputc(buf+off, c);
    80006a04:	0014871b          	addiw	a4,s1,1
  *s = c;
    80006a08:	975e                	add	a4,a4,s7
    80006a0a:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006a0e:	2489                	addiw	s1,s1,2
      break;
    80006a10:	b719                	j	80006916 <snprintf+0x7c>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
