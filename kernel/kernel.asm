
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	7f013103          	ld	sp,2032(sp) # 800087f0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000060:	bd478793          	addi	a5,a5,-1068 # 80005c30 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
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
    8000012a:	39e080e7          	jalr	926(ra) # 800024c4 <either_copyin>
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
    800001d2:	82e080e7          	jalr	-2002(ra) # 800019fc <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	02e080e7          	jalr	46(ra) # 8000220c <sleep>
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
    8000021e:	254080e7          	jalr	596(ra) # 8000246e <either_copyout>
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
    80000300:	21e080e7          	jalr	542(ra) # 8000251a <procdump>
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
    80000454:	f42080e7          	jalr	-190(ra) # 80002392 <wakeup>
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
    80000466:	bae58593          	addi	a1,a1,-1106 # 80008010 <etext+0x10>
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
    80000486:	52e78793          	addi	a5,a5,1326 # 800219b0 <devsw>
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
    800004c8:	b7c60613          	addi	a2,a2,-1156 # 80008040 <digits>
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
    80000560:	abc50513          	addi	a0,a0,-1348 # 80008018 <etext+0x18>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5250513          	addi	a0,a0,-1198 # 800080c8 <digits+0x88>
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
    800005f4:	a50b8b93          	addi	s7,s7,-1456 # 80008040 <digits>
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
    80000618:	a1450513          	addi	a0,a0,-1516 # 80008028 <etext+0x28>
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
    80000718:	90c90913          	addi	s2,s2,-1780 # 80008020 <etext+0x20>
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
    8000078e:	8ae58593          	addi	a1,a1,-1874 # 80008038 <etext+0x38>
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
    800007de:	87e58593          	addi	a1,a1,-1922 # 80008058 <digits+0x18>
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
    800008ba:	adc080e7          	jalr	-1316(ra) # 80002392 <wakeup>
    
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
    80000954:	8bc080e7          	jalr	-1860(ra) # 8000220c <sleep>
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
    80000a38:	00025797          	auipc	a5,0x25
    80000a3c:	5c878793          	addi	a5,a5,1480 # 80026000 <end>
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
    80000a8e:	5d650513          	addi	a0,a0,1494 # 80008060 <digits+0x20>
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
    80000af0:	57c58593          	addi	a1,a1,1404 # 80008068 <digits+0x28>
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	e3c50513          	addi	a0,a0,-452 # 80011930 <kmem>
    80000afc:	00000097          	auipc	ra,0x0
    80000b00:	084080e7          	jalr	132(ra) # 80000b80 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b04:	45c5                	li	a1,17
    80000b06:	05ee                	slli	a1,a1,0x1b
    80000b08:	00025517          	auipc	a0,0x25
    80000b0c:	4f850513          	addi	a0,a0,1272 # 80026000 <end>
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
    80000bae:	e36080e7          	jalr	-458(ra) # 800019e0 <mycpu>
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
    80000be0:	e04080e7          	jalr	-508(ra) # 800019e0 <mycpu>
    80000be4:	5d3c                	lw	a5,120(a0)
    80000be6:	cf89                	beqz	a5,80000c00 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be8:	00001097          	auipc	ra,0x1
    80000bec:	df8080e7          	jalr	-520(ra) # 800019e0 <mycpu>
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
    80000c04:	de0080e7          	jalr	-544(ra) # 800019e0 <mycpu>
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
    80000c44:	da0080e7          	jalr	-608(ra) # 800019e0 <mycpu>
    80000c48:	e888                	sd	a0,16(s1)
}
    80000c4a:	60e2                	ld	ra,24(sp)
    80000c4c:	6442                	ld	s0,16(sp)
    80000c4e:	64a2                	ld	s1,8(sp)
    80000c50:	6105                	addi	sp,sp,32
    80000c52:	8082                	ret
    panic("acquire");
    80000c54:	00007517          	auipc	a0,0x7
    80000c58:	41c50513          	addi	a0,a0,1052 # 80008070 <digits+0x30>
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
    80000c70:	d74080e7          	jalr	-652(ra) # 800019e0 <mycpu>
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
    80000ca8:	3d450513          	addi	a0,a0,980 # 80008078 <digits+0x38>
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	89c080e7          	jalr	-1892(ra) # 80000548 <panic>
    panic("pop_off");
    80000cb4:	00007517          	auipc	a0,0x7
    80000cb8:	3dc50513          	addi	a0,a0,988 # 80008090 <digits+0x50>
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
    80000d00:	39c50513          	addi	a0,a0,924 # 80008098 <digits+0x58>
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
    80000eca:	b0a080e7          	jalr	-1270(ra) # 800019d0 <cpuid>
    virtio_disk_init(); // emulated hard disk
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
    80000ee6:	aee080e7          	jalr	-1298(ra) # 800019d0 <cpuid>
    80000eea:	85aa                	mv	a1,a0
    80000eec:	00007517          	auipc	a0,0x7
    80000ef0:	1cc50513          	addi	a0,a0,460 # 800080b8 <digits+0x78>
    80000ef4:	fffff097          	auipc	ra,0xfffff
    80000ef8:	69e080e7          	jalr	1694(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	0d8080e7          	jalr	216(ra) # 80000fd4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f04:	00001097          	auipc	ra,0x1
    80000f08:	756080e7          	jalr	1878(ra) # 8000265a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f0c:	00005097          	auipc	ra,0x5
    80000f10:	d64080e7          	jalr	-668(ra) # 80005c70 <plicinithart>
  }

  scheduler();        
    80000f14:	00001097          	auipc	ra,0x1
    80000f18:	018080e7          	jalr	24(ra) # 80001f2c <scheduler>
    consoleinit();
    80000f1c:	fffff097          	auipc	ra,0xfffff
    80000f20:	53e080e7          	jalr	1342(ra) # 8000045a <consoleinit>
    printfinit();
    80000f24:	00000097          	auipc	ra,0x0
    80000f28:	854080e7          	jalr	-1964(ra) # 80000778 <printfinit>
    printf("\n");
    80000f2c:	00007517          	auipc	a0,0x7
    80000f30:	19c50513          	addi	a0,a0,412 # 800080c8 <digits+0x88>
    80000f34:	fffff097          	auipc	ra,0xfffff
    80000f38:	65e080e7          	jalr	1630(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	16450513          	addi	a0,a0,356 # 800080a0 <digits+0x60>
    80000f44:	fffff097          	auipc	ra,0xfffff
    80000f48:	64e080e7          	jalr	1614(ra) # 80000592 <printf>
    printf("\n");
    80000f4c:	00007517          	auipc	a0,0x7
    80000f50:	17c50513          	addi	a0,a0,380 # 800080c8 <digits+0x88>
    80000f54:	fffff097          	auipc	ra,0xfffff
    80000f58:	63e080e7          	jalr	1598(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000f5c:	00000097          	auipc	ra,0x0
    80000f60:	b88080e7          	jalr	-1144(ra) # 80000ae4 <kinit>
    kvminit();       // create kernel page table
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	30a080e7          	jalr	778(ra) # 8000126e <kvminit>
    kvminithart();   // turn on paging
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	068080e7          	jalr	104(ra) # 80000fd4 <kvminithart>
    procinit();      // process table
    80000f74:	00001097          	auipc	ra,0x1
    80000f78:	98c080e7          	jalr	-1652(ra) # 80001900 <procinit>
    trapinit();      // trap vectors
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	6b6080e7          	jalr	1718(ra) # 80002632 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	6d6080e7          	jalr	1750(ra) # 8000265a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f8c:	00005097          	auipc	ra,0x5
    80000f90:	cce080e7          	jalr	-818(ra) # 80005c5a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f94:	00005097          	auipc	ra,0x5
    80000f98:	cdc080e7          	jalr	-804(ra) # 80005c70 <plicinithart>
    binit();         // buffer cache
    80000f9c:	00002097          	auipc	ra,0x2
    80000fa0:	e72080e7          	jalr	-398(ra) # 80002e0e <binit>
    iinit();         // inode cache
    80000fa4:	00002097          	auipc	ra,0x2
    80000fa8:	502080e7          	jalr	1282(ra) # 800034a6 <iinit>
    fileinit();      // file table
    80000fac:	00003097          	auipc	ra,0x3
    80000fb0:	4a0080e7          	jalr	1184(ra) # 8000444c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb4:	00005097          	auipc	ra,0x5
    80000fb8:	dc4080e7          	jalr	-572(ra) # 80005d78 <virtio_disk_init>
    userinit();      // first user process
    80000fbc:	00001097          	auipc	ra,0x1
    80000fc0:	d0a080e7          	jalr	-758(ra) # 80001cc6 <userinit>
    __sync_synchronize();
    80000fc4:	0ff0000f          	fence
    started = 1;
    80000fc8:	4785                	li	a5,1
    80000fca:	00008717          	auipc	a4,0x8
    80000fce:	04f72123          	sw	a5,66(a4) # 8000900c <started>
    80000fd2:	b789                	j	80000f14 <main+0x56>

0000000080000fd4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fd4:	1141                	addi	sp,sp,-16
    80000fd6:	e422                	sd	s0,8(sp)
    80000fd8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fda:	00008797          	auipc	a5,0x8
    80000fde:	0367b783          	ld	a5,54(a5) # 80009010 <kernel_pagetable>
    80000fe2:	83b1                	srli	a5,a5,0xc
    80000fe4:	577d                	li	a4,-1
    80000fe6:	177e                	slli	a4,a4,0x3f
    80000fe8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fea:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  sfence_vma();
}
    80000ff2:	6422                	ld	s0,8(sp)
    80000ff4:	0141                	addi	sp,sp,16
    80000ff6:	8082                	ret

0000000080000ff8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ff8:	7139                	addi	sp,sp,-64
    80000ffa:	fc06                	sd	ra,56(sp)
    80000ffc:	f822                	sd	s0,48(sp)
    80000ffe:	f426                	sd	s1,40(sp)
    80001000:	f04a                	sd	s2,32(sp)
    80001002:	ec4e                	sd	s3,24(sp)
    80001004:	e852                	sd	s4,16(sp)
    80001006:	e456                	sd	s5,8(sp)
    80001008:	e05a                	sd	s6,0(sp)
    8000100a:	0080                	addi	s0,sp,64
    8000100c:	84aa                	mv	s1,a0
    8000100e:	89ae                	mv	s3,a1
    80001010:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001012:	57fd                	li	a5,-1
    80001014:	83e9                	srli	a5,a5,0x1a
    80001016:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001018:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000101a:	04b7f263          	bgeu	a5,a1,8000105e <walk+0x66>
    panic("walk");
    8000101e:	00007517          	auipc	a0,0x7
    80001022:	0b250513          	addi	a0,a0,178 # 800080d0 <digits+0x90>
    80001026:	fffff097          	auipc	ra,0xfffff
    8000102a:	522080e7          	jalr	1314(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000102e:	060a8663          	beqz	s5,8000109a <walk+0xa2>
    80001032:	00000097          	auipc	ra,0x0
    80001036:	aee080e7          	jalr	-1298(ra) # 80000b20 <kalloc>
    8000103a:	84aa                	mv	s1,a0
    8000103c:	c529                	beqz	a0,80001086 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000103e:	6605                	lui	a2,0x1
    80001040:	4581                	li	a1,0
    80001042:	00000097          	auipc	ra,0x0
    80001046:	cca080e7          	jalr	-822(ra) # 80000d0c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000104a:	00c4d793          	srli	a5,s1,0xc
    8000104e:	07aa                	slli	a5,a5,0xa
    80001050:	0017e793          	ori	a5,a5,1
    80001054:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001058:	3a5d                	addiw	s4,s4,-9
    8000105a:	036a0063          	beq	s4,s6,8000107a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000105e:	0149d933          	srl	s2,s3,s4
    80001062:	1ff97913          	andi	s2,s2,511
    80001066:	090e                	slli	s2,s2,0x3
    80001068:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000106a:	00093483          	ld	s1,0(s2)
    8000106e:	0014f793          	andi	a5,s1,1
    80001072:	dfd5                	beqz	a5,8000102e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001074:	80a9                	srli	s1,s1,0xa
    80001076:	04b2                	slli	s1,s1,0xc
    80001078:	b7c5                	j	80001058 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000107a:	00c9d513          	srli	a0,s3,0xc
    8000107e:	1ff57513          	andi	a0,a0,511
    80001082:	050e                	slli	a0,a0,0x3
    80001084:	9526                	add	a0,a0,s1
}
    80001086:	70e2                	ld	ra,56(sp)
    80001088:	7442                	ld	s0,48(sp)
    8000108a:	74a2                	ld	s1,40(sp)
    8000108c:	7902                	ld	s2,32(sp)
    8000108e:	69e2                	ld	s3,24(sp)
    80001090:	6a42                	ld	s4,16(sp)
    80001092:	6aa2                	ld	s5,8(sp)
    80001094:	6b02                	ld	s6,0(sp)
    80001096:	6121                	addi	sp,sp,64
    80001098:	8082                	ret
        return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7ed                	j	80001086 <walk+0x8e>

000000008000109e <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    8000109e:	1101                	addi	sp,sp,-32
    800010a0:	ec06                	sd	ra,24(sp)
    800010a2:	e822                	sd	s0,16(sp)
    800010a4:	e426                	sd	s1,8(sp)
    800010a6:	1000                	addi	s0,sp,32
    800010a8:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800010aa:	1552                	slli	a0,a0,0x34
    800010ac:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800010b0:	4601                	li	a2,0
    800010b2:	00008517          	auipc	a0,0x8
    800010b6:	f5e53503          	ld	a0,-162(a0) # 80009010 <kernel_pagetable>
    800010ba:	00000097          	auipc	ra,0x0
    800010be:	f3e080e7          	jalr	-194(ra) # 80000ff8 <walk>
  if(pte == 0)
    800010c2:	cd09                	beqz	a0,800010dc <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800010c4:	6108                	ld	a0,0(a0)
    800010c6:	00157793          	andi	a5,a0,1
    800010ca:	c38d                	beqz	a5,800010ec <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800010cc:	8129                	srli	a0,a0,0xa
    800010ce:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    800010d0:	9526                	add	a0,a0,s1
    800010d2:	60e2                	ld	ra,24(sp)
    800010d4:	6442                	ld	s0,16(sp)
    800010d6:	64a2                	ld	s1,8(sp)
    800010d8:	6105                	addi	sp,sp,32
    800010da:	8082                	ret
    panic("kvmpa");
    800010dc:	00007517          	auipc	a0,0x7
    800010e0:	ffc50513          	addi	a0,a0,-4 # 800080d8 <digits+0x98>
    800010e4:	fffff097          	auipc	ra,0xfffff
    800010e8:	464080e7          	jalr	1124(ra) # 80000548 <panic>
    panic("kvmpa");
    800010ec:	00007517          	auipc	a0,0x7
    800010f0:	fec50513          	addi	a0,a0,-20 # 800080d8 <digits+0x98>
    800010f4:	fffff097          	auipc	ra,0xfffff
    800010f8:	454080e7          	jalr	1108(ra) # 80000548 <panic>

00000000800010fc <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010fc:	715d                	addi	sp,sp,-80
    800010fe:	e486                	sd	ra,72(sp)
    80001100:	e0a2                	sd	s0,64(sp)
    80001102:	fc26                	sd	s1,56(sp)
    80001104:	f84a                	sd	s2,48(sp)
    80001106:	f44e                	sd	s3,40(sp)
    80001108:	f052                	sd	s4,32(sp)
    8000110a:	ec56                	sd	s5,24(sp)
    8000110c:	e85a                	sd	s6,16(sp)
    8000110e:	e45e                	sd	s7,8(sp)
    80001110:	0880                	addi	s0,sp,80
    80001112:	8aaa                	mv	s5,a0
    80001114:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001116:	777d                	lui	a4,0xfffff
    80001118:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111c:	167d                	addi	a2,a2,-1
    8000111e:	00b609b3          	add	s3,a2,a1
    80001122:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001126:	893e                	mv	s2,a5
    80001128:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112c:	6b85                	lui	s7,0x1
    8000112e:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001132:	4605                	li	a2,1
    80001134:	85ca                	mv	a1,s2
    80001136:	8556                	mv	a0,s5
    80001138:	00000097          	auipc	ra,0x0
    8000113c:	ec0080e7          	jalr	-320(ra) # 80000ff8 <walk>
    80001140:	c51d                	beqz	a0,8000116e <mappages+0x72>
    if(*pte & PTE_V)
    80001142:	611c                	ld	a5,0(a0)
    80001144:	8b85                	andi	a5,a5,1
    80001146:	ef81                	bnez	a5,8000115e <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001148:	80b1                	srli	s1,s1,0xc
    8000114a:	04aa                	slli	s1,s1,0xa
    8000114c:	0164e4b3          	or	s1,s1,s6
    80001150:	0014e493          	ori	s1,s1,1
    80001154:	e104                	sd	s1,0(a0)
    if(a == last)
    80001156:	03390863          	beq	s2,s3,80001186 <mappages+0x8a>
    a += PGSIZE;
    8000115a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115c:	bfc9                	j	8000112e <mappages+0x32>
      panic("remap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f8250513          	addi	a0,a0,-126 # 800080e0 <digits+0xa0>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3e2080e7          	jalr	994(ra) # 80000548 <panic>
      return -1;
    8000116e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001170:	60a6                	ld	ra,72(sp)
    80001172:	6406                	ld	s0,64(sp)
    80001174:	74e2                	ld	s1,56(sp)
    80001176:	7942                	ld	s2,48(sp)
    80001178:	79a2                	ld	s3,40(sp)
    8000117a:	7a02                	ld	s4,32(sp)
    8000117c:	6ae2                	ld	s5,24(sp)
    8000117e:	6b42                	ld	s6,16(sp)
    80001180:	6ba2                	ld	s7,8(sp)
    80001182:	6161                	addi	sp,sp,80
    80001184:	8082                	ret
  return 0;
    80001186:	4501                	li	a0,0
    80001188:	b7e5                	j	80001170 <mappages+0x74>

000000008000118a <walkaddr>:
{
    8000118a:	7179                	addi	sp,sp,-48
    8000118c:	f406                	sd	ra,40(sp)
    8000118e:	f022                	sd	s0,32(sp)
    80001190:	ec26                	sd	s1,24(sp)
    80001192:	e84a                	sd	s2,16(sp)
    80001194:	e44e                	sd	s3,8(sp)
    80001196:	e052                	sd	s4,0(sp)
    80001198:	1800                	addi	s0,sp,48
  if(va >= MAXVA)
    8000119a:	57fd                	li	a5,-1
    8000119c:	83e9                	srli	a5,a5,0x1a
    return 0;
    8000119e:	4901                	li	s2,0
  if(va >= MAXVA)
    800011a0:	00b7fb63          	bgeu	a5,a1,800011b6 <walkaddr+0x2c>
}
    800011a4:	854a                	mv	a0,s2
    800011a6:	70a2                	ld	ra,40(sp)
    800011a8:	7402                	ld	s0,32(sp)
    800011aa:	64e2                	ld	s1,24(sp)
    800011ac:	6942                	ld	s2,16(sp)
    800011ae:	69a2                	ld	s3,8(sp)
    800011b0:	6a02                	ld	s4,0(sp)
    800011b2:	6145                	addi	sp,sp,48
    800011b4:	8082                	ret
    800011b6:	84ae                	mv	s1,a1
  pte = walk(pagetable, va, 0);
    800011b8:	4601                	li	a2,0
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	e3e080e7          	jalr	-450(ra) # 80000ff8 <walk>
  if(pte==0 || (*pte & PTE_V)==0) {
    800011c2:	c509                	beqz	a0,800011cc <walkaddr+0x42>
    800011c4:	611c                	ld	a5,0(a0)
    800011c6:	0017f713          	andi	a4,a5,1
    800011ca:	ef31                	bnez	a4,80001226 <walkaddr+0x9c>
    struct proc* p = myproc();
    800011cc:	00001097          	auipc	ra,0x1
    800011d0:	830080e7          	jalr	-2000(ra) # 800019fc <myproc>
    800011d4:	89aa                	mv	s3,a0
    if(va>=p->sz || va<=p->trapframe->sp)
    800011d6:	653c                	ld	a5,72(a0)
      return 0;
    800011d8:	4901                	li	s2,0
    if(va>=p->sz || va<=p->trapframe->sp)
    800011da:	fcf4f5e3          	bgeu	s1,a5,800011a4 <walkaddr+0x1a>
    800011de:	6d3c                	ld	a5,88(a0)
    800011e0:	7b9c                	ld	a5,48(a5)
    800011e2:	fc97f1e3          	bgeu	a5,s1,800011a4 <walkaddr+0x1a>
    char* mem = kalloc();
    800011e6:	00000097          	auipc	ra,0x0
    800011ea:	93a080e7          	jalr	-1734(ra) # 80000b20 <kalloc>
    800011ee:	8a2a                	mv	s4,a0
    if(mem == 0)
    800011f0:	d955                	beqz	a0,800011a4 <walkaddr+0x1a>
    memset(mem, 0, PGSIZE);
    800011f2:	6605                	lui	a2,0x1
    800011f4:	4581                	li	a1,0
    800011f6:	00000097          	auipc	ra,0x0
    800011fa:	b16080e7          	jalr	-1258(ra) # 80000d0c <memset>
    if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0) {
    800011fe:	8952                	mv	s2,s4
    80001200:	4779                	li	a4,30
    80001202:	86d2                	mv	a3,s4
    80001204:	6605                	lui	a2,0x1
    80001206:	75fd                	lui	a1,0xfffff
    80001208:	8de5                	and	a1,a1,s1
    8000120a:	0509b503          	ld	a0,80(s3) # 1050 <_entry-0x7fffefb0>
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	eee080e7          	jalr	-274(ra) # 800010fc <mappages>
    80001216:	d559                	beqz	a0,800011a4 <walkaddr+0x1a>
      kfree(mem);
    80001218:	8552                	mv	a0,s4
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	80a080e7          	jalr	-2038(ra) # 80000a24 <kfree>
      return 0;
    80001222:	4901                	li	s2,0
    80001224:	b741                	j	800011a4 <walkaddr+0x1a>
  if((*pte & PTE_U) == 0) 
    80001226:	0107f913          	andi	s2,a5,16
    8000122a:	f6090de3          	beqz	s2,800011a4 <walkaddr+0x1a>
  pa = PTE2PA(*pte);
    8000122e:	00a7d913          	srli	s2,a5,0xa
    80001232:	0932                	slli	s2,s2,0xc
  return pa;
    80001234:	bf85                	j	800011a4 <walkaddr+0x1a>

0000000080001236 <kvmmap>:
{
    80001236:	1141                	addi	sp,sp,-16
    80001238:	e406                	sd	ra,8(sp)
    8000123a:	e022                	sd	s0,0(sp)
    8000123c:	0800                	addi	s0,sp,16
    8000123e:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001240:	86ae                	mv	a3,a1
    80001242:	85aa                	mv	a1,a0
    80001244:	00008517          	auipc	a0,0x8
    80001248:	dcc53503          	ld	a0,-564(a0) # 80009010 <kernel_pagetable>
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	eb0080e7          	jalr	-336(ra) # 800010fc <mappages>
    80001254:	e509                	bnez	a0,8000125e <kvmmap+0x28>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret
    panic("kvmmap");
    8000125e:	00007517          	auipc	a0,0x7
    80001262:	e8a50513          	addi	a0,a0,-374 # 800080e8 <digits+0xa8>
    80001266:	fffff097          	auipc	ra,0xfffff
    8000126a:	2e2080e7          	jalr	738(ra) # 80000548 <panic>

000000008000126e <kvminit>:
{
    8000126e:	1101                	addi	sp,sp,-32
    80001270:	ec06                	sd	ra,24(sp)
    80001272:	e822                	sd	s0,16(sp)
    80001274:	e426                	sd	s1,8(sp)
    80001276:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001278:	00000097          	auipc	ra,0x0
    8000127c:	8a8080e7          	jalr	-1880(ra) # 80000b20 <kalloc>
    80001280:	00008797          	auipc	a5,0x8
    80001284:	d8a7b823          	sd	a0,-624(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	a80080e7          	jalr	-1408(ra) # 80000d0c <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001294:	4699                	li	a3,6
    80001296:	6605                	lui	a2,0x1
    80001298:	100005b7          	lui	a1,0x10000
    8000129c:	10000537          	lui	a0,0x10000
    800012a0:	00000097          	auipc	ra,0x0
    800012a4:	f96080e7          	jalr	-106(ra) # 80001236 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012a8:	4699                	li	a3,6
    800012aa:	6605                	lui	a2,0x1
    800012ac:	100015b7          	lui	a1,0x10001
    800012b0:	10001537          	lui	a0,0x10001
    800012b4:	00000097          	auipc	ra,0x0
    800012b8:	f82080e7          	jalr	-126(ra) # 80001236 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800012bc:	4699                	li	a3,6
    800012be:	6641                	lui	a2,0x10
    800012c0:	020005b7          	lui	a1,0x2000
    800012c4:	02000537          	lui	a0,0x2000
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	f6e080e7          	jalr	-146(ra) # 80001236 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012d0:	4699                	li	a3,6
    800012d2:	00400637          	lui	a2,0x400
    800012d6:	0c0005b7          	lui	a1,0xc000
    800012da:	0c000537          	lui	a0,0xc000
    800012de:	00000097          	auipc	ra,0x0
    800012e2:	f58080e7          	jalr	-168(ra) # 80001236 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012e6:	00007497          	auipc	s1,0x7
    800012ea:	d1a48493          	addi	s1,s1,-742 # 80008000 <etext>
    800012ee:	46a9                	li	a3,10
    800012f0:	80007617          	auipc	a2,0x80007
    800012f4:	d1060613          	addi	a2,a2,-752 # 8000 <_entry-0x7fff8000>
    800012f8:	4585                	li	a1,1
    800012fa:	05fe                	slli	a1,a1,0x1f
    800012fc:	852e                	mv	a0,a1
    800012fe:	00000097          	auipc	ra,0x0
    80001302:	f38080e7          	jalr	-200(ra) # 80001236 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001306:	4699                	li	a3,6
    80001308:	4645                	li	a2,17
    8000130a:	066e                	slli	a2,a2,0x1b
    8000130c:	8e05                	sub	a2,a2,s1
    8000130e:	85a6                	mv	a1,s1
    80001310:	8526                	mv	a0,s1
    80001312:	00000097          	auipc	ra,0x0
    80001316:	f24080e7          	jalr	-220(ra) # 80001236 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000131a:	46a9                	li	a3,10
    8000131c:	6605                	lui	a2,0x1
    8000131e:	00006597          	auipc	a1,0x6
    80001322:	ce258593          	addi	a1,a1,-798 # 80007000 <_trampoline>
    80001326:	04000537          	lui	a0,0x4000
    8000132a:	157d                	addi	a0,a0,-1
    8000132c:	0532                	slli	a0,a0,0xc
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	f08080e7          	jalr	-248(ra) # 80001236 <kvmmap>
}
    80001336:	60e2                	ld	ra,24(sp)
    80001338:	6442                	ld	s0,16(sp)
    8000133a:	64a2                	ld	s1,8(sp)
    8000133c:	6105                	addi	sp,sp,32
    8000133e:	8082                	ret

0000000080001340 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001340:	715d                	addi	sp,sp,-80
    80001342:	e486                	sd	ra,72(sp)
    80001344:	e0a2                	sd	s0,64(sp)
    80001346:	fc26                	sd	s1,56(sp)
    80001348:	f84a                	sd	s2,48(sp)
    8000134a:	f44e                	sd	s3,40(sp)
    8000134c:	f052                	sd	s4,32(sp)
    8000134e:	ec56                	sd	s5,24(sp)
    80001350:	e85a                	sd	s6,16(sp)
    80001352:	e45e                	sd	s7,8(sp)
    80001354:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001356:	03459793          	slli	a5,a1,0x34
    8000135a:	e795                	bnez	a5,80001386 <uvmunmap+0x46>
    8000135c:	8a2a                	mv	s4,a0
    8000135e:	892e                	mv	s2,a1
    80001360:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001362:	0632                	slli	a2,a2,0xc
    80001364:	00b609b3          	add	s3,a2,a1
      continue;
      // panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      continue;
      // panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001368:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000136a:	6a85                	lui	s5,0x1
    8000136c:	0535e963          	bltu	a1,s3,800013be <uvmunmap+0x7e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001370:	60a6                	ld	ra,72(sp)
    80001372:	6406                	ld	s0,64(sp)
    80001374:	74e2                	ld	s1,56(sp)
    80001376:	7942                	ld	s2,48(sp)
    80001378:	79a2                	ld	s3,40(sp)
    8000137a:	7a02                	ld	s4,32(sp)
    8000137c:	6ae2                	ld	s5,24(sp)
    8000137e:	6b42                	ld	s6,16(sp)
    80001380:	6ba2                	ld	s7,8(sp)
    80001382:	6161                	addi	sp,sp,80
    80001384:	8082                	ret
    panic("uvmunmap: not aligned");
    80001386:	00007517          	auipc	a0,0x7
    8000138a:	d6a50513          	addi	a0,a0,-662 # 800080f0 <digits+0xb0>
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	1ba080e7          	jalr	442(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	d7250513          	addi	a0,a0,-654 # 80008108 <digits+0xc8>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	1aa080e7          	jalr	426(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    800013a6:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800013a8:	00c79513          	slli	a0,a5,0xc
    800013ac:	fffff097          	auipc	ra,0xfffff
    800013b0:	678080e7          	jalr	1656(ra) # 80000a24 <kfree>
    *pte = 0;
    800013b4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013b8:	9956                	add	s2,s2,s5
    800013ba:	fb397be3          	bgeu	s2,s3,80001370 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013be:	4601                	li	a2,0
    800013c0:	85ca                	mv	a1,s2
    800013c2:	8552                	mv	a0,s4
    800013c4:	00000097          	auipc	ra,0x0
    800013c8:	c34080e7          	jalr	-972(ra) # 80000ff8 <walk>
    800013cc:	84aa                	mv	s1,a0
    800013ce:	d56d                	beqz	a0,800013b8 <uvmunmap+0x78>
    if((*pte & PTE_V) == 0)
    800013d0:	611c                	ld	a5,0(a0)
    800013d2:	0017f713          	andi	a4,a5,1
    800013d6:	d36d                	beqz	a4,800013b8 <uvmunmap+0x78>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013d8:	3ff7f713          	andi	a4,a5,1023
    800013dc:	fb770de3          	beq	a4,s7,80001396 <uvmunmap+0x56>
    if(do_free){
    800013e0:	fc0b0ae3          	beqz	s6,800013b4 <uvmunmap+0x74>
    800013e4:	b7c9                	j	800013a6 <uvmunmap+0x66>

00000000800013e6 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013e6:	1101                	addi	sp,sp,-32
    800013e8:	ec06                	sd	ra,24(sp)
    800013ea:	e822                	sd	s0,16(sp)
    800013ec:	e426                	sd	s1,8(sp)
    800013ee:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013f0:	fffff097          	auipc	ra,0xfffff
    800013f4:	730080e7          	jalr	1840(ra) # 80000b20 <kalloc>
    800013f8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013fa:	c519                	beqz	a0,80001408 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013fc:	6605                	lui	a2,0x1
    800013fe:	4581                	li	a1,0
    80001400:	00000097          	auipc	ra,0x0
    80001404:	90c080e7          	jalr	-1780(ra) # 80000d0c <memset>
  return pagetable;
}
    80001408:	8526                	mv	a0,s1
    8000140a:	60e2                	ld	ra,24(sp)
    8000140c:	6442                	ld	s0,16(sp)
    8000140e:	64a2                	ld	s1,8(sp)
    80001410:	6105                	addi	sp,sp,32
    80001412:	8082                	ret

0000000080001414 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001414:	7179                	addi	sp,sp,-48
    80001416:	f406                	sd	ra,40(sp)
    80001418:	f022                	sd	s0,32(sp)
    8000141a:	ec26                	sd	s1,24(sp)
    8000141c:	e84a                	sd	s2,16(sp)
    8000141e:	e44e                	sd	s3,8(sp)
    80001420:	e052                	sd	s4,0(sp)
    80001422:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001424:	6785                	lui	a5,0x1
    80001426:	04f67863          	bgeu	a2,a5,80001476 <uvminit+0x62>
    8000142a:	8a2a                	mv	s4,a0
    8000142c:	89ae                	mv	s3,a1
    8000142e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001430:	fffff097          	auipc	ra,0xfffff
    80001434:	6f0080e7          	jalr	1776(ra) # 80000b20 <kalloc>
    80001438:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000143a:	6605                	lui	a2,0x1
    8000143c:	4581                	li	a1,0
    8000143e:	00000097          	auipc	ra,0x0
    80001442:	8ce080e7          	jalr	-1842(ra) # 80000d0c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001446:	4779                	li	a4,30
    80001448:	86ca                	mv	a3,s2
    8000144a:	6605                	lui	a2,0x1
    8000144c:	4581                	li	a1,0
    8000144e:	8552                	mv	a0,s4
    80001450:	00000097          	auipc	ra,0x0
    80001454:	cac080e7          	jalr	-852(ra) # 800010fc <mappages>
  memmove(mem, src, sz);
    80001458:	8626                	mv	a2,s1
    8000145a:	85ce                	mv	a1,s3
    8000145c:	854a                	mv	a0,s2
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	90e080e7          	jalr	-1778(ra) # 80000d6c <memmove>
}
    80001466:	70a2                	ld	ra,40(sp)
    80001468:	7402                	ld	s0,32(sp)
    8000146a:	64e2                	ld	s1,24(sp)
    8000146c:	6942                	ld	s2,16(sp)
    8000146e:	69a2                	ld	s3,8(sp)
    80001470:	6a02                	ld	s4,0(sp)
    80001472:	6145                	addi	sp,sp,48
    80001474:	8082                	ret
    panic("inituvm: more than a page");
    80001476:	00007517          	auipc	a0,0x7
    8000147a:	caa50513          	addi	a0,a0,-854 # 80008120 <digits+0xe0>
    8000147e:	fffff097          	auipc	ra,0xfffff
    80001482:	0ca080e7          	jalr	202(ra) # 80000548 <panic>

0000000080001486 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001486:	1101                	addi	sp,sp,-32
    80001488:	ec06                	sd	ra,24(sp)
    8000148a:	e822                	sd	s0,16(sp)
    8000148c:	e426                	sd	s1,8(sp)
    8000148e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001490:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001492:	00b67d63          	bgeu	a2,a1,800014ac <uvmdealloc+0x26>
    80001496:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001498:	6785                	lui	a5,0x1
    8000149a:	17fd                	addi	a5,a5,-1
    8000149c:	00f60733          	add	a4,a2,a5
    800014a0:	767d                	lui	a2,0xfffff
    800014a2:	8f71                	and	a4,a4,a2
    800014a4:	97ae                	add	a5,a5,a1
    800014a6:	8ff1                	and	a5,a5,a2
    800014a8:	00f76863          	bltu	a4,a5,800014b8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014ac:	8526                	mv	a0,s1
    800014ae:	60e2                	ld	ra,24(sp)
    800014b0:	6442                	ld	s0,16(sp)
    800014b2:	64a2                	ld	s1,8(sp)
    800014b4:	6105                	addi	sp,sp,32
    800014b6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014b8:	8f99                	sub	a5,a5,a4
    800014ba:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014bc:	4685                	li	a3,1
    800014be:	0007861b          	sext.w	a2,a5
    800014c2:	85ba                	mv	a1,a4
    800014c4:	00000097          	auipc	ra,0x0
    800014c8:	e7c080e7          	jalr	-388(ra) # 80001340 <uvmunmap>
    800014cc:	b7c5                	j	800014ac <uvmdealloc+0x26>

00000000800014ce <uvmalloc>:
  if(newsz < oldsz)
    800014ce:	0ab66163          	bltu	a2,a1,80001570 <uvmalloc+0xa2>
{
    800014d2:	7139                	addi	sp,sp,-64
    800014d4:	fc06                	sd	ra,56(sp)
    800014d6:	f822                	sd	s0,48(sp)
    800014d8:	f426                	sd	s1,40(sp)
    800014da:	f04a                	sd	s2,32(sp)
    800014dc:	ec4e                	sd	s3,24(sp)
    800014de:	e852                	sd	s4,16(sp)
    800014e0:	e456                	sd	s5,8(sp)
    800014e2:	0080                	addi	s0,sp,64
    800014e4:	8aaa                	mv	s5,a0
    800014e6:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014e8:	6985                	lui	s3,0x1
    800014ea:	19fd                	addi	s3,s3,-1
    800014ec:	95ce                	add	a1,a1,s3
    800014ee:	79fd                	lui	s3,0xfffff
    800014f0:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014f4:	08c9f063          	bgeu	s3,a2,80001574 <uvmalloc+0xa6>
    800014f8:	894e                	mv	s2,s3
    mem = kalloc();
    800014fa:	fffff097          	auipc	ra,0xfffff
    800014fe:	626080e7          	jalr	1574(ra) # 80000b20 <kalloc>
    80001502:	84aa                	mv	s1,a0
    if(mem == 0){
    80001504:	c51d                	beqz	a0,80001532 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001506:	6605                	lui	a2,0x1
    80001508:	4581                	li	a1,0
    8000150a:	00000097          	auipc	ra,0x0
    8000150e:	802080e7          	jalr	-2046(ra) # 80000d0c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001512:	4779                	li	a4,30
    80001514:	86a6                	mv	a3,s1
    80001516:	6605                	lui	a2,0x1
    80001518:	85ca                	mv	a1,s2
    8000151a:	8556                	mv	a0,s5
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	be0080e7          	jalr	-1056(ra) # 800010fc <mappages>
    80001524:	e905                	bnez	a0,80001554 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001526:	6785                	lui	a5,0x1
    80001528:	993e                	add	s2,s2,a5
    8000152a:	fd4968e3          	bltu	s2,s4,800014fa <uvmalloc+0x2c>
  return newsz;
    8000152e:	8552                	mv	a0,s4
    80001530:	a809                	j	80001542 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001532:	864e                	mv	a2,s3
    80001534:	85ca                	mv	a1,s2
    80001536:	8556                	mv	a0,s5
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f4e080e7          	jalr	-178(ra) # 80001486 <uvmdealloc>
      return 0;
    80001540:	4501                	li	a0,0
}
    80001542:	70e2                	ld	ra,56(sp)
    80001544:	7442                	ld	s0,48(sp)
    80001546:	74a2                	ld	s1,40(sp)
    80001548:	7902                	ld	s2,32(sp)
    8000154a:	69e2                	ld	s3,24(sp)
    8000154c:	6a42                	ld	s4,16(sp)
    8000154e:	6aa2                	ld	s5,8(sp)
    80001550:	6121                	addi	sp,sp,64
    80001552:	8082                	ret
      kfree(mem);
    80001554:	8526                	mv	a0,s1
    80001556:	fffff097          	auipc	ra,0xfffff
    8000155a:	4ce080e7          	jalr	1230(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000155e:	864e                	mv	a2,s3
    80001560:	85ca                	mv	a1,s2
    80001562:	8556                	mv	a0,s5
    80001564:	00000097          	auipc	ra,0x0
    80001568:	f22080e7          	jalr	-222(ra) # 80001486 <uvmdealloc>
      return 0;
    8000156c:	4501                	li	a0,0
    8000156e:	bfd1                	j	80001542 <uvmalloc+0x74>
    return oldsz;
    80001570:	852e                	mv	a0,a1
}
    80001572:	8082                	ret
  return newsz;
    80001574:	8532                	mv	a0,a2
    80001576:	b7f1                	j	80001542 <uvmalloc+0x74>

0000000080001578 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001578:	7179                	addi	sp,sp,-48
    8000157a:	f406                	sd	ra,40(sp)
    8000157c:	f022                	sd	s0,32(sp)
    8000157e:	ec26                	sd	s1,24(sp)
    80001580:	e84a                	sd	s2,16(sp)
    80001582:	e44e                	sd	s3,8(sp)
    80001584:	e052                	sd	s4,0(sp)
    80001586:	1800                	addi	s0,sp,48
    80001588:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000158a:	84aa                	mv	s1,a0
    8000158c:	6905                	lui	s2,0x1
    8000158e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001590:	4985                	li	s3,1
    80001592:	a821                	j	800015aa <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001594:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001596:	0532                	slli	a0,a0,0xc
    80001598:	00000097          	auipc	ra,0x0
    8000159c:	fe0080e7          	jalr	-32(ra) # 80001578 <freewalk>
      pagetable[i] = 0;
    800015a0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015a4:	04a1                	addi	s1,s1,8
    800015a6:	01248863          	beq	s1,s2,800015b6 <freewalk+0x3e>
    pte_t pte = pagetable[i];
    800015aa:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015ac:	00f57793          	andi	a5,a0,15
    800015b0:	ff379ae3          	bne	a5,s3,800015a4 <freewalk+0x2c>
    800015b4:	b7c5                	j	80001594 <freewalk+0x1c>
    } else if(pte & PTE_V){
      // panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
    800015b6:	8552                	mv	a0,s4
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	46c080e7          	jalr	1132(ra) # 80000a24 <kfree>
}
    800015c0:	70a2                	ld	ra,40(sp)
    800015c2:	7402                	ld	s0,32(sp)
    800015c4:	64e2                	ld	s1,24(sp)
    800015c6:	6942                	ld	s2,16(sp)
    800015c8:	69a2                	ld	s3,8(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	6145                	addi	sp,sp,48
    800015ce:	8082                	ret

00000000800015d0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015d0:	1101                	addi	sp,sp,-32
    800015d2:	ec06                	sd	ra,24(sp)
    800015d4:	e822                	sd	s0,16(sp)
    800015d6:	e426                	sd	s1,8(sp)
    800015d8:	1000                	addi	s0,sp,32
    800015da:	84aa                	mv	s1,a0
  if(sz > 0)
    800015dc:	e999                	bnez	a1,800015f2 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015de:	8526                	mv	a0,s1
    800015e0:	00000097          	auipc	ra,0x0
    800015e4:	f98080e7          	jalr	-104(ra) # 80001578 <freewalk>
}
    800015e8:	60e2                	ld	ra,24(sp)
    800015ea:	6442                	ld	s0,16(sp)
    800015ec:	64a2                	ld	s1,8(sp)
    800015ee:	6105                	addi	sp,sp,32
    800015f0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015f2:	6605                	lui	a2,0x1
    800015f4:	167d                	addi	a2,a2,-1
    800015f6:	962e                	add	a2,a2,a1
    800015f8:	4685                	li	a3,1
    800015fa:	8231                	srli	a2,a2,0xc
    800015fc:	4581                	li	a1,0
    800015fe:	00000097          	auipc	ra,0x0
    80001602:	d42080e7          	jalr	-702(ra) # 80001340 <uvmunmap>
    80001606:	bfe1                	j	800015de <uvmfree+0xe>

0000000080001608 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001608:	ca4d                	beqz	a2,800016ba <uvmcopy+0xb2>
{
    8000160a:	715d                	addi	sp,sp,-80
    8000160c:	e486                	sd	ra,72(sp)
    8000160e:	e0a2                	sd	s0,64(sp)
    80001610:	fc26                	sd	s1,56(sp)
    80001612:	f84a                	sd	s2,48(sp)
    80001614:	f44e                	sd	s3,40(sp)
    80001616:	f052                	sd	s4,32(sp)
    80001618:	ec56                	sd	s5,24(sp)
    8000161a:	e85a                	sd	s6,16(sp)
    8000161c:	e45e                	sd	s7,8(sp)
    8000161e:	0880                	addi	s0,sp,80
    80001620:	8aaa                	mv	s5,a0
    80001622:	8b2e                	mv	s6,a1
    80001624:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001626:	4481                	li	s1,0
    80001628:	a029                	j	80001632 <uvmcopy+0x2a>
    8000162a:	6785                	lui	a5,0x1
    8000162c:	94be                	add	s1,s1,a5
    8000162e:	0744fa63          	bgeu	s1,s4,800016a2 <uvmcopy+0x9a>
    if((pte = walk(old, i, 0)) == 0)
    80001632:	4601                	li	a2,0
    80001634:	85a6                	mv	a1,s1
    80001636:	8556                	mv	a0,s5
    80001638:	00000097          	auipc	ra,0x0
    8000163c:	9c0080e7          	jalr	-1600(ra) # 80000ff8 <walk>
    80001640:	d56d                	beqz	a0,8000162a <uvmcopy+0x22>
      continue;
      // panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001642:	6118                	ld	a4,0(a0)
    80001644:	00177793          	andi	a5,a4,1
    80001648:	d3ed                	beqz	a5,8000162a <uvmcopy+0x22>
      continue;
      // panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000164a:	00a75593          	srli	a1,a4,0xa
    8000164e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001652:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001656:	fffff097          	auipc	ra,0xfffff
    8000165a:	4ca080e7          	jalr	1226(ra) # 80000b20 <kalloc>
    8000165e:	89aa                	mv	s3,a0
    80001660:	c515                	beqz	a0,8000168c <uvmcopy+0x84>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001662:	6605                	lui	a2,0x1
    80001664:	85de                	mv	a1,s7
    80001666:	fffff097          	auipc	ra,0xfffff
    8000166a:	706080e7          	jalr	1798(ra) # 80000d6c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000166e:	874a                	mv	a4,s2
    80001670:	86ce                	mv	a3,s3
    80001672:	6605                	lui	a2,0x1
    80001674:	85a6                	mv	a1,s1
    80001676:	855a                	mv	a0,s6
    80001678:	00000097          	auipc	ra,0x0
    8000167c:	a84080e7          	jalr	-1404(ra) # 800010fc <mappages>
    80001680:	d54d                	beqz	a0,8000162a <uvmcopy+0x22>
      kfree(mem);
    80001682:	854e                	mv	a0,s3
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	3a0080e7          	jalr	928(ra) # 80000a24 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000168c:	4685                	li	a3,1
    8000168e:	00c4d613          	srli	a2,s1,0xc
    80001692:	4581                	li	a1,0
    80001694:	855a                	mv	a0,s6
    80001696:	00000097          	auipc	ra,0x0
    8000169a:	caa080e7          	jalr	-854(ra) # 80001340 <uvmunmap>
  return -1;
    8000169e:	557d                	li	a0,-1
    800016a0:	a011                	j	800016a4 <uvmcopy+0x9c>
  return 0;
    800016a2:	4501                	li	a0,0
}
    800016a4:	60a6                	ld	ra,72(sp)
    800016a6:	6406                	ld	s0,64(sp)
    800016a8:	74e2                	ld	s1,56(sp)
    800016aa:	7942                	ld	s2,48(sp)
    800016ac:	79a2                	ld	s3,40(sp)
    800016ae:	7a02                	ld	s4,32(sp)
    800016b0:	6ae2                	ld	s5,24(sp)
    800016b2:	6b42                	ld	s6,16(sp)
    800016b4:	6ba2                	ld	s7,8(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret
  return 0;
    800016ba:	4501                	li	a0,0
}
    800016bc:	8082                	ret

00000000800016be <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016be:	1141                	addi	sp,sp,-16
    800016c0:	e406                	sd	ra,8(sp)
    800016c2:	e022                	sd	s0,0(sp)
    800016c4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	00000097          	auipc	ra,0x0
    800016cc:	930080e7          	jalr	-1744(ra) # 80000ff8 <walk>
  if(pte == 0)
    800016d0:	c901                	beqz	a0,800016e0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016d2:	611c                	ld	a5,0(a0)
    800016d4:	9bbd                	andi	a5,a5,-17
    800016d6:	e11c                	sd	a5,0(a0)
}
    800016d8:	60a2                	ld	ra,8(sp)
    800016da:	6402                	ld	s0,0(sp)
    800016dc:	0141                	addi	sp,sp,16
    800016de:	8082                	ret
    panic("uvmclear");
    800016e0:	00007517          	auipc	a0,0x7
    800016e4:	a6050513          	addi	a0,a0,-1440 # 80008140 <digits+0x100>
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	e60080e7          	jalr	-416(ra) # 80000548 <panic>

00000000800016f0 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f0:	c6bd                	beqz	a3,8000175e <copyout+0x6e>
{
    800016f2:	715d                	addi	sp,sp,-80
    800016f4:	e486                	sd	ra,72(sp)
    800016f6:	e0a2                	sd	s0,64(sp)
    800016f8:	fc26                	sd	s1,56(sp)
    800016fa:	f84a                	sd	s2,48(sp)
    800016fc:	f44e                	sd	s3,40(sp)
    800016fe:	f052                	sd	s4,32(sp)
    80001700:	ec56                	sd	s5,24(sp)
    80001702:	e85a                	sd	s6,16(sp)
    80001704:	e45e                	sd	s7,8(sp)
    80001706:	e062                	sd	s8,0(sp)
    80001708:	0880                	addi	s0,sp,80
    8000170a:	8b2a                	mv	s6,a0
    8000170c:	8c2e                	mv	s8,a1
    8000170e:	8a32                	mv	s4,a2
    80001710:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001712:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0); 
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001714:	6a85                	lui	s5,0x1
    80001716:	a015                	j	8000173a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001718:	9562                	add	a0,a0,s8
    8000171a:	0004861b          	sext.w	a2,s1
    8000171e:	85d2                	mv	a1,s4
    80001720:	41250533          	sub	a0,a0,s2
    80001724:	fffff097          	auipc	ra,0xfffff
    80001728:	648080e7          	jalr	1608(ra) # 80000d6c <memmove>

    len -= n;
    8000172c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001730:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001732:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001736:	02098263          	beqz	s3,8000175a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000173a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0); 
    8000173e:	85ca                	mv	a1,s2
    80001740:	855a                	mv	a0,s6
    80001742:	00000097          	auipc	ra,0x0
    80001746:	a48080e7          	jalr	-1464(ra) # 8000118a <walkaddr>
    if(pa0 == 0)
    8000174a:	cd01                	beqz	a0,80001762 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000174c:	418904b3          	sub	s1,s2,s8
    80001750:	94d6                	add	s1,s1,s5
    if(n > len)
    80001752:	fc99f3e3          	bgeu	s3,s1,80001718 <copyout+0x28>
    80001756:	84ce                	mv	s1,s3
    80001758:	b7c1                	j	80001718 <copyout+0x28>
  }
  return 0;
    8000175a:	4501                	li	a0,0
    8000175c:	a021                	j	80001764 <copyout+0x74>
    8000175e:	4501                	li	a0,0
}
    80001760:	8082                	ret
      return -1;
    80001762:	557d                	li	a0,-1
}
    80001764:	60a6                	ld	ra,72(sp)
    80001766:	6406                	ld	s0,64(sp)
    80001768:	74e2                	ld	s1,56(sp)
    8000176a:	7942                	ld	s2,48(sp)
    8000176c:	79a2                	ld	s3,40(sp)
    8000176e:	7a02                	ld	s4,32(sp)
    80001770:	6ae2                	ld	s5,24(sp)
    80001772:	6b42                	ld	s6,16(sp)
    80001774:	6ba2                	ld	s7,8(sp)
    80001776:	6c02                	ld	s8,0(sp)
    80001778:	6161                	addi	sp,sp,80
    8000177a:	8082                	ret

000000008000177c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000177c:	c6bd                	beqz	a3,800017ea <copyin+0x6e>
{
    8000177e:	715d                	addi	sp,sp,-80
    80001780:	e486                	sd	ra,72(sp)
    80001782:	e0a2                	sd	s0,64(sp)
    80001784:	fc26                	sd	s1,56(sp)
    80001786:	f84a                	sd	s2,48(sp)
    80001788:	f44e                	sd	s3,40(sp)
    8000178a:	f052                	sd	s4,32(sp)
    8000178c:	ec56                	sd	s5,24(sp)
    8000178e:	e85a                	sd	s6,16(sp)
    80001790:	e45e                	sd	s7,8(sp)
    80001792:	e062                	sd	s8,0(sp)
    80001794:	0880                	addi	s0,sp,80
    80001796:	8b2a                	mv	s6,a0
    80001798:	8a2e                	mv	s4,a1
    8000179a:	8c32                	mv	s8,a2
    8000179c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000179e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a0:	6a85                	lui	s5,0x1
    800017a2:	a015                	j	800017c6 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017a4:	9562                	add	a0,a0,s8
    800017a6:	0004861b          	sext.w	a2,s1
    800017aa:	412505b3          	sub	a1,a0,s2
    800017ae:	8552                	mv	a0,s4
    800017b0:	fffff097          	auipc	ra,0xfffff
    800017b4:	5bc080e7          	jalr	1468(ra) # 80000d6c <memmove>

    len -= n;
    800017b8:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017bc:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017be:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017c2:	02098263          	beqz	s3,800017e6 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    800017c6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017ca:	85ca                	mv	a1,s2
    800017cc:	855a                	mv	a0,s6
    800017ce:	00000097          	auipc	ra,0x0
    800017d2:	9bc080e7          	jalr	-1604(ra) # 8000118a <walkaddr>
    if(pa0 == 0)
    800017d6:	cd01                	beqz	a0,800017ee <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    800017d8:	418904b3          	sub	s1,s2,s8
    800017dc:	94d6                	add	s1,s1,s5
    if(n > len)
    800017de:	fc99f3e3          	bgeu	s3,s1,800017a4 <copyin+0x28>
    800017e2:	84ce                	mv	s1,s3
    800017e4:	b7c1                	j	800017a4 <copyin+0x28>
  }
  return 0;
    800017e6:	4501                	li	a0,0
    800017e8:	a021                	j	800017f0 <copyin+0x74>
    800017ea:	4501                	li	a0,0
}
    800017ec:	8082                	ret
      return -1;
    800017ee:	557d                	li	a0,-1
}
    800017f0:	60a6                	ld	ra,72(sp)
    800017f2:	6406                	ld	s0,64(sp)
    800017f4:	74e2                	ld	s1,56(sp)
    800017f6:	7942                	ld	s2,48(sp)
    800017f8:	79a2                	ld	s3,40(sp)
    800017fa:	7a02                	ld	s4,32(sp)
    800017fc:	6ae2                	ld	s5,24(sp)
    800017fe:	6b42                	ld	s6,16(sp)
    80001800:	6ba2                	ld	s7,8(sp)
    80001802:	6c02                	ld	s8,0(sp)
    80001804:	6161                	addi	sp,sp,80
    80001806:	8082                	ret

0000000080001808 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001808:	c6c5                	beqz	a3,800018b0 <copyinstr+0xa8>
{
    8000180a:	715d                	addi	sp,sp,-80
    8000180c:	e486                	sd	ra,72(sp)
    8000180e:	e0a2                	sd	s0,64(sp)
    80001810:	fc26                	sd	s1,56(sp)
    80001812:	f84a                	sd	s2,48(sp)
    80001814:	f44e                	sd	s3,40(sp)
    80001816:	f052                	sd	s4,32(sp)
    80001818:	ec56                	sd	s5,24(sp)
    8000181a:	e85a                	sd	s6,16(sp)
    8000181c:	e45e                	sd	s7,8(sp)
    8000181e:	0880                	addi	s0,sp,80
    80001820:	8a2a                	mv	s4,a0
    80001822:	8b2e                	mv	s6,a1
    80001824:	8bb2                	mv	s7,a2
    80001826:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001828:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000182a:	6985                	lui	s3,0x1
    8000182c:	a035                	j	80001858 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000182e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001832:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000183c:	60a6                	ld	ra,72(sp)
    8000183e:	6406                	ld	s0,64(sp)
    80001840:	74e2                	ld	s1,56(sp)
    80001842:	7942                	ld	s2,48(sp)
    80001844:	79a2                	ld	s3,40(sp)
    80001846:	7a02                	ld	s4,32(sp)
    80001848:	6ae2                	ld	s5,24(sp)
    8000184a:	6b42                	ld	s6,16(sp)
    8000184c:	6ba2                	ld	s7,8(sp)
    8000184e:	6161                	addi	sp,sp,80
    80001850:	8082                	ret
    srcva = va0 + PGSIZE;
    80001852:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001856:	c8a9                	beqz	s1,800018a8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001858:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185c:	85ca                	mv	a1,s2
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	92a080e7          	jalr	-1750(ra) # 8000118a <walkaddr>
    if(pa0 == 0)
    80001868:	c131                	beqz	a0,800018ac <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000186a:	41790833          	sub	a6,s2,s7
    8000186e:	984e                	add	a6,a6,s3
    if(n > max)
    80001870:	0104f363          	bgeu	s1,a6,80001876 <copyinstr+0x6e>
    80001874:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001876:	955e                	add	a0,a0,s7
    80001878:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000187c:	fc080be3          	beqz	a6,80001852 <copyinstr+0x4a>
    80001880:	985a                	add	a6,a6,s6
    80001882:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001884:	41650633          	sub	a2,a0,s6
    80001888:	14fd                	addi	s1,s1,-1
    8000188a:	9b26                	add	s6,s6,s1
    8000188c:	00f60733          	add	a4,a2,a5
    80001890:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80001894:	df49                	beqz	a4,8000182e <copyinstr+0x26>
        *dst = *p;
    80001896:	00e78023          	sb	a4,0(a5)
      --max;
    8000189a:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000189e:	0785                	addi	a5,a5,1
    while(n > 0){
    800018a0:	ff0796e3          	bne	a5,a6,8000188c <copyinstr+0x84>
      dst++;
    800018a4:	8b42                	mv	s6,a6
    800018a6:	b775                	j	80001852 <copyinstr+0x4a>
    800018a8:	4781                	li	a5,0
    800018aa:	b769                	j	80001834 <copyinstr+0x2c>
      return -1;
    800018ac:	557d                	li	a0,-1
    800018ae:	b779                	j	8000183c <copyinstr+0x34>
  int got_null = 0;
    800018b0:	4781                	li	a5,0
  if(got_null){
    800018b2:	0017b793          	seqz	a5,a5
    800018b6:	40f00533          	neg	a0,a5
}
    800018ba:	8082                	ret

00000000800018bc <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018bc:	1101                	addi	sp,sp,-32
    800018be:	ec06                	sd	ra,24(sp)
    800018c0:	e822                	sd	s0,16(sp)
    800018c2:	e426                	sd	s1,8(sp)
    800018c4:	1000                	addi	s0,sp,32
    800018c6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018c8:	fffff097          	auipc	ra,0xfffff
    800018cc:	2ce080e7          	jalr	718(ra) # 80000b96 <holding>
    800018d0:	c909                	beqz	a0,800018e2 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018d2:	749c                	ld	a5,40(s1)
    800018d4:	00978f63          	beq	a5,s1,800018f2 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018d8:	60e2                	ld	ra,24(sp)
    800018da:	6442                	ld	s0,16(sp)
    800018dc:	64a2                	ld	s1,8(sp)
    800018de:	6105                	addi	sp,sp,32
    800018e0:	8082                	ret
    panic("wakeup1");
    800018e2:	00007517          	auipc	a0,0x7
    800018e6:	86e50513          	addi	a0,a0,-1938 # 80008150 <digits+0x110>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	c5e080e7          	jalr	-930(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800018f2:	4c98                	lw	a4,24(s1)
    800018f4:	4785                	li	a5,1
    800018f6:	fef711e3          	bne	a4,a5,800018d8 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800018fa:	4789                	li	a5,2
    800018fc:	cc9c                	sw	a5,24(s1)
}
    800018fe:	bfe9                	j	800018d8 <wakeup1+0x1c>

0000000080001900 <procinit>:
{
    80001900:	715d                	addi	sp,sp,-80
    80001902:	e486                	sd	ra,72(sp)
    80001904:	e0a2                	sd	s0,64(sp)
    80001906:	fc26                	sd	s1,56(sp)
    80001908:	f84a                	sd	s2,48(sp)
    8000190a:	f44e                	sd	s3,40(sp)
    8000190c:	f052                	sd	s4,32(sp)
    8000190e:	ec56                	sd	s5,24(sp)
    80001910:	e85a                	sd	s6,16(sp)
    80001912:	e45e                	sd	s7,8(sp)
    80001914:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001916:	00007597          	auipc	a1,0x7
    8000191a:	84258593          	addi	a1,a1,-1982 # 80008158 <digits+0x118>
    8000191e:	00010517          	auipc	a0,0x10
    80001922:	03250513          	addi	a0,a0,50 # 80011950 <pid_lock>
    80001926:	fffff097          	auipc	ra,0xfffff
    8000192a:	25a080e7          	jalr	602(ra) # 80000b80 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192e:	00010917          	auipc	s2,0x10
    80001932:	43a90913          	addi	s2,s2,1082 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001936:	00007b97          	auipc	s7,0x7
    8000193a:	82ab8b93          	addi	s7,s7,-2006 # 80008160 <digits+0x120>
      uint64 va = KSTACK((int) (p - proc));
    8000193e:	8b4a                	mv	s6,s2
    80001940:	00006a97          	auipc	s5,0x6
    80001944:	6c0a8a93          	addi	s5,s5,1728 # 80008000 <etext>
    80001948:	040009b7          	lui	s3,0x4000
    8000194c:	19fd                	addi	s3,s3,-1
    8000194e:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001950:	00016a17          	auipc	s4,0x16
    80001954:	e18a0a13          	addi	s4,s4,-488 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    80001958:	85de                	mv	a1,s7
    8000195a:	854a                	mv	a0,s2
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	224080e7          	jalr	548(ra) # 80000b80 <initlock>
      char *pa = kalloc();
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	1bc080e7          	jalr	444(ra) # 80000b20 <kalloc>
    8000196c:	85aa                	mv	a1,a0
      if(pa == 0)
    8000196e:	c929                	beqz	a0,800019c0 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001970:	416904b3          	sub	s1,s2,s6
    80001974:	848d                	srai	s1,s1,0x3
    80001976:	000ab783          	ld	a5,0(s5)
    8000197a:	02f484b3          	mul	s1,s1,a5
    8000197e:	2485                	addiw	s1,s1,1
    80001980:	00d4949b          	slliw	s1,s1,0xd
    80001984:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001988:	4699                	li	a3,6
    8000198a:	6605                	lui	a2,0x1
    8000198c:	8526                	mv	a0,s1
    8000198e:	00000097          	auipc	ra,0x0
    80001992:	8a8080e7          	jalr	-1880(ra) # 80001236 <kvmmap>
      p->kstack = va;
    80001996:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000199a:	16890913          	addi	s2,s2,360
    8000199e:	fb491de3          	bne	s2,s4,80001958 <procinit+0x58>
  kvminithart();
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	632080e7          	jalr	1586(ra) # 80000fd4 <kvminithart>
}
    800019aa:	60a6                	ld	ra,72(sp)
    800019ac:	6406                	ld	s0,64(sp)
    800019ae:	74e2                	ld	s1,56(sp)
    800019b0:	7942                	ld	s2,48(sp)
    800019b2:	79a2                	ld	s3,40(sp)
    800019b4:	7a02                	ld	s4,32(sp)
    800019b6:	6ae2                	ld	s5,24(sp)
    800019b8:	6b42                	ld	s6,16(sp)
    800019ba:	6ba2                	ld	s7,8(sp)
    800019bc:	6161                	addi	sp,sp,80
    800019be:	8082                	ret
        panic("kalloc");
    800019c0:	00006517          	auipc	a0,0x6
    800019c4:	7a850513          	addi	a0,a0,1960 # 80008168 <digits+0x128>
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	b80080e7          	jalr	-1152(ra) # 80000548 <panic>

00000000800019d0 <cpuid>:
{
    800019d0:	1141                	addi	sp,sp,-16
    800019d2:	e422                	sd	s0,8(sp)
    800019d4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019d6:	8512                	mv	a0,tp
}
    800019d8:	2501                	sext.w	a0,a0
    800019da:	6422                	ld	s0,8(sp)
    800019dc:	0141                	addi	sp,sp,16
    800019de:	8082                	ret

00000000800019e0 <mycpu>:
mycpu(void) {
    800019e0:	1141                	addi	sp,sp,-16
    800019e2:	e422                	sd	s0,8(sp)
    800019e4:	0800                	addi	s0,sp,16
    800019e6:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    800019e8:	2781                	sext.w	a5,a5
    800019ea:	079e                	slli	a5,a5,0x7
}
    800019ec:	00010517          	auipc	a0,0x10
    800019f0:	f7c50513          	addi	a0,a0,-132 # 80011968 <cpus>
    800019f4:	953e                	add	a0,a0,a5
    800019f6:	6422                	ld	s0,8(sp)
    800019f8:	0141                	addi	sp,sp,16
    800019fa:	8082                	ret

00000000800019fc <myproc>:
myproc(void) {
    800019fc:	1101                	addi	sp,sp,-32
    800019fe:	ec06                	sd	ra,24(sp)
    80001a00:	e822                	sd	s0,16(sp)
    80001a02:	e426                	sd	s1,8(sp)
    80001a04:	1000                	addi	s0,sp,32
  push_off();
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	1be080e7          	jalr	446(ra) # 80000bc4 <push_off>
    80001a0e:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a10:	2781                	sext.w	a5,a5
    80001a12:	079e                	slli	a5,a5,0x7
    80001a14:	00010717          	auipc	a4,0x10
    80001a18:	f3c70713          	addi	a4,a4,-196 # 80011950 <pid_lock>
    80001a1c:	97ba                	add	a5,a5,a4
    80001a1e:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a20:	fffff097          	auipc	ra,0xfffff
    80001a24:	244080e7          	jalr	580(ra) # 80000c64 <pop_off>
}
    80001a28:	8526                	mv	a0,s1
    80001a2a:	60e2                	ld	ra,24(sp)
    80001a2c:	6442                	ld	s0,16(sp)
    80001a2e:	64a2                	ld	s1,8(sp)
    80001a30:	6105                	addi	sp,sp,32
    80001a32:	8082                	ret

0000000080001a34 <forkret>:
{
    80001a34:	1141                	addi	sp,sp,-16
    80001a36:	e406                	sd	ra,8(sp)
    80001a38:	e022                	sd	s0,0(sp)
    80001a3a:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a3c:	00000097          	auipc	ra,0x0
    80001a40:	fc0080e7          	jalr	-64(ra) # 800019fc <myproc>
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	280080e7          	jalr	640(ra) # 80000cc4 <release>
  if (first) {
    80001a4c:	00007797          	auipc	a5,0x7
    80001a50:	d547a783          	lw	a5,-684(a5) # 800087a0 <first.1662>
    80001a54:	eb89                	bnez	a5,80001a66 <forkret+0x32>
  usertrapret();
    80001a56:	00001097          	auipc	ra,0x1
    80001a5a:	c1c080e7          	jalr	-996(ra) # 80002672 <usertrapret>
}
    80001a5e:	60a2                	ld	ra,8(sp)
    80001a60:	6402                	ld	s0,0(sp)
    80001a62:	0141                	addi	sp,sp,16
    80001a64:	8082                	ret
    first = 0;
    80001a66:	00007797          	auipc	a5,0x7
    80001a6a:	d207ad23          	sw	zero,-710(a5) # 800087a0 <first.1662>
    fsinit(ROOTDEV);
    80001a6e:	4505                	li	a0,1
    80001a70:	00002097          	auipc	ra,0x2
    80001a74:	9b6080e7          	jalr	-1610(ra) # 80003426 <fsinit>
    80001a78:	bff9                	j	80001a56 <forkret+0x22>

0000000080001a7a <allocpid>:
allocpid() {
    80001a7a:	1101                	addi	sp,sp,-32
    80001a7c:	ec06                	sd	ra,24(sp)
    80001a7e:	e822                	sd	s0,16(sp)
    80001a80:	e426                	sd	s1,8(sp)
    80001a82:	e04a                	sd	s2,0(sp)
    80001a84:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a86:	00010917          	auipc	s2,0x10
    80001a8a:	eca90913          	addi	s2,s2,-310 # 80011950 <pid_lock>
    80001a8e:	854a                	mv	a0,s2
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	180080e7          	jalr	384(ra) # 80000c10 <acquire>
  pid = nextpid;
    80001a98:	00007797          	auipc	a5,0x7
    80001a9c:	d0c78793          	addi	a5,a5,-756 # 800087a4 <nextpid>
    80001aa0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001aa2:	0014871b          	addiw	a4,s1,1
    80001aa6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aa8:	854a                	mv	a0,s2
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	21a080e7          	jalr	538(ra) # 80000cc4 <release>
}
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	60e2                	ld	ra,24(sp)
    80001ab6:	6442                	ld	s0,16(sp)
    80001ab8:	64a2                	ld	s1,8(sp)
    80001aba:	6902                	ld	s2,0(sp)
    80001abc:	6105                	addi	sp,sp,32
    80001abe:	8082                	ret

0000000080001ac0 <proc_pagetable>:
{
    80001ac0:	1101                	addi	sp,sp,-32
    80001ac2:	ec06                	sd	ra,24(sp)
    80001ac4:	e822                	sd	s0,16(sp)
    80001ac6:	e426                	sd	s1,8(sp)
    80001ac8:	e04a                	sd	s2,0(sp)
    80001aca:	1000                	addi	s0,sp,32
    80001acc:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ace:	00000097          	auipc	ra,0x0
    80001ad2:	918080e7          	jalr	-1768(ra) # 800013e6 <uvmcreate>
    80001ad6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ad8:	c121                	beqz	a0,80001b18 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ada:	4729                	li	a4,10
    80001adc:	00005697          	auipc	a3,0x5
    80001ae0:	52468693          	addi	a3,a3,1316 # 80007000 <_trampoline>
    80001ae4:	6605                	lui	a2,0x1
    80001ae6:	040005b7          	lui	a1,0x4000
    80001aea:	15fd                	addi	a1,a1,-1
    80001aec:	05b2                	slli	a1,a1,0xc
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	60e080e7          	jalr	1550(ra) # 800010fc <mappages>
    80001af6:	02054863          	bltz	a0,80001b26 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001afa:	4719                	li	a4,6
    80001afc:	05893683          	ld	a3,88(s2)
    80001b00:	6605                	lui	a2,0x1
    80001b02:	020005b7          	lui	a1,0x2000
    80001b06:	15fd                	addi	a1,a1,-1
    80001b08:	05b6                	slli	a1,a1,0xd
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	5f0080e7          	jalr	1520(ra) # 800010fc <mappages>
    80001b14:	02054163          	bltz	a0,80001b36 <proc_pagetable+0x76>
}
    80001b18:	8526                	mv	a0,s1
    80001b1a:	60e2                	ld	ra,24(sp)
    80001b1c:	6442                	ld	s0,16(sp)
    80001b1e:	64a2                	ld	s1,8(sp)
    80001b20:	6902                	ld	s2,0(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret
    uvmfree(pagetable, 0);
    80001b26:	4581                	li	a1,0
    80001b28:	8526                	mv	a0,s1
    80001b2a:	00000097          	auipc	ra,0x0
    80001b2e:	aa6080e7          	jalr	-1370(ra) # 800015d0 <uvmfree>
    return 0;
    80001b32:	4481                	li	s1,0
    80001b34:	b7d5                	j	80001b18 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b36:	4681                	li	a3,0
    80001b38:	4605                	li	a2,1
    80001b3a:	040005b7          	lui	a1,0x4000
    80001b3e:	15fd                	addi	a1,a1,-1
    80001b40:	05b2                	slli	a1,a1,0xc
    80001b42:	8526                	mv	a0,s1
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	7fc080e7          	jalr	2044(ra) # 80001340 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b4c:	4581                	li	a1,0
    80001b4e:	8526                	mv	a0,s1
    80001b50:	00000097          	auipc	ra,0x0
    80001b54:	a80080e7          	jalr	-1408(ra) # 800015d0 <uvmfree>
    return 0;
    80001b58:	4481                	li	s1,0
    80001b5a:	bf7d                	j	80001b18 <proc_pagetable+0x58>

0000000080001b5c <proc_freepagetable>:
{
    80001b5c:	1101                	addi	sp,sp,-32
    80001b5e:	ec06                	sd	ra,24(sp)
    80001b60:	e822                	sd	s0,16(sp)
    80001b62:	e426                	sd	s1,8(sp)
    80001b64:	e04a                	sd	s2,0(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
    80001b6a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b6c:	4681                	li	a3,0
    80001b6e:	4605                	li	a2,1
    80001b70:	040005b7          	lui	a1,0x4000
    80001b74:	15fd                	addi	a1,a1,-1
    80001b76:	05b2                	slli	a1,a1,0xc
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	7c8080e7          	jalr	1992(ra) # 80001340 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b80:	4681                	li	a3,0
    80001b82:	4605                	li	a2,1
    80001b84:	020005b7          	lui	a1,0x2000
    80001b88:	15fd                	addi	a1,a1,-1
    80001b8a:	05b6                	slli	a1,a1,0xd
    80001b8c:	8526                	mv	a0,s1
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	7b2080e7          	jalr	1970(ra) # 80001340 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b96:	85ca                	mv	a1,s2
    80001b98:	8526                	mv	a0,s1
    80001b9a:	00000097          	auipc	ra,0x0
    80001b9e:	a36080e7          	jalr	-1482(ra) # 800015d0 <uvmfree>
}
    80001ba2:	60e2                	ld	ra,24(sp)
    80001ba4:	6442                	ld	s0,16(sp)
    80001ba6:	64a2                	ld	s1,8(sp)
    80001ba8:	6902                	ld	s2,0(sp)
    80001baa:	6105                	addi	sp,sp,32
    80001bac:	8082                	ret

0000000080001bae <freeproc>:
{
    80001bae:	1101                	addi	sp,sp,-32
    80001bb0:	ec06                	sd	ra,24(sp)
    80001bb2:	e822                	sd	s0,16(sp)
    80001bb4:	e426                	sd	s1,8(sp)
    80001bb6:	1000                	addi	s0,sp,32
    80001bb8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bba:	6d28                	ld	a0,88(a0)
    80001bbc:	c509                	beqz	a0,80001bc6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	e66080e7          	jalr	-410(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001bc6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bca:	68a8                	ld	a0,80(s1)
    80001bcc:	c511                	beqz	a0,80001bd8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bce:	64ac                	ld	a1,72(s1)
    80001bd0:	00000097          	auipc	ra,0x0
    80001bd4:	f8c080e7          	jalr	-116(ra) # 80001b5c <proc_freepagetable>
  p->pagetable = 0;
    80001bd8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bdc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001be0:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001be4:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001be8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bec:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001bf0:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001bf4:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001bf8:	0004ac23          	sw	zero,24(s1)
}
    80001bfc:	60e2                	ld	ra,24(sp)
    80001bfe:	6442                	ld	s0,16(sp)
    80001c00:	64a2                	ld	s1,8(sp)
    80001c02:	6105                	addi	sp,sp,32
    80001c04:	8082                	ret

0000000080001c06 <allocproc>:
{
    80001c06:	1101                	addi	sp,sp,-32
    80001c08:	ec06                	sd	ra,24(sp)
    80001c0a:	e822                	sd	s0,16(sp)
    80001c0c:	e426                	sd	s1,8(sp)
    80001c0e:	e04a                	sd	s2,0(sp)
    80001c10:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c12:	00010497          	auipc	s1,0x10
    80001c16:	15648493          	addi	s1,s1,342 # 80011d68 <proc>
    80001c1a:	00016917          	auipc	s2,0x16
    80001c1e:	b4e90913          	addi	s2,s2,-1202 # 80017768 <tickslock>
    acquire(&p->lock);
    80001c22:	8526                	mv	a0,s1
    80001c24:	fffff097          	auipc	ra,0xfffff
    80001c28:	fec080e7          	jalr	-20(ra) # 80000c10 <acquire>
    if(p->state == UNUSED) {
    80001c2c:	4c9c                	lw	a5,24(s1)
    80001c2e:	cf81                	beqz	a5,80001c46 <allocproc+0x40>
      release(&p->lock);
    80001c30:	8526                	mv	a0,s1
    80001c32:	fffff097          	auipc	ra,0xfffff
    80001c36:	092080e7          	jalr	146(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c3a:	16848493          	addi	s1,s1,360
    80001c3e:	ff2492e3          	bne	s1,s2,80001c22 <allocproc+0x1c>
  return 0;
    80001c42:	4481                	li	s1,0
    80001c44:	a0b9                	j	80001c92 <allocproc+0x8c>
  p->pid = allocpid();
    80001c46:	00000097          	auipc	ra,0x0
    80001c4a:	e34080e7          	jalr	-460(ra) # 80001a7a <allocpid>
    80001c4e:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	ed0080e7          	jalr	-304(ra) # 80000b20 <kalloc>
    80001c58:	892a                	mv	s2,a0
    80001c5a:	eca8                	sd	a0,88(s1)
    80001c5c:	c131                	beqz	a0,80001ca0 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	e60080e7          	jalr	-416(ra) # 80001ac0 <proc_pagetable>
    80001c68:	892a                	mv	s2,a0
    80001c6a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c6c:	c129                	beqz	a0,80001cae <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001c6e:	07000613          	li	a2,112
    80001c72:	4581                	li	a1,0
    80001c74:	06048513          	addi	a0,s1,96
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	094080e7          	jalr	148(ra) # 80000d0c <memset>
  p->context.ra = (uint64)forkret;
    80001c80:	00000797          	auipc	a5,0x0
    80001c84:	db478793          	addi	a5,a5,-588 # 80001a34 <forkret>
    80001c88:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c8a:	60bc                	ld	a5,64(s1)
    80001c8c:	6705                	lui	a4,0x1
    80001c8e:	97ba                	add	a5,a5,a4
    80001c90:	f4bc                	sd	a5,104(s1)
}
    80001c92:	8526                	mv	a0,s1
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6902                	ld	s2,0(sp)
    80001c9c:	6105                	addi	sp,sp,32
    80001c9e:	8082                	ret
    release(&p->lock);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	022080e7          	jalr	34(ra) # 80000cc4 <release>
    return 0;
    80001caa:	84ca                	mv	s1,s2
    80001cac:	b7dd                	j	80001c92 <allocproc+0x8c>
    freeproc(p);
    80001cae:	8526                	mv	a0,s1
    80001cb0:	00000097          	auipc	ra,0x0
    80001cb4:	efe080e7          	jalr	-258(ra) # 80001bae <freeproc>
    release(&p->lock);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	00a080e7          	jalr	10(ra) # 80000cc4 <release>
    return 0;
    80001cc2:	84ca                	mv	s1,s2
    80001cc4:	b7f9                	j	80001c92 <allocproc+0x8c>

0000000080001cc6 <userinit>:
{
    80001cc6:	1101                	addi	sp,sp,-32
    80001cc8:	ec06                	sd	ra,24(sp)
    80001cca:	e822                	sd	s0,16(sp)
    80001ccc:	e426                	sd	s1,8(sp)
    80001cce:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cd0:	00000097          	auipc	ra,0x0
    80001cd4:	f36080e7          	jalr	-202(ra) # 80001c06 <allocproc>
    80001cd8:	84aa                	mv	s1,a0
  initproc = p;
    80001cda:	00007797          	auipc	a5,0x7
    80001cde:	32a7bf23          	sd	a0,830(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ce2:	03400613          	li	a2,52
    80001ce6:	00007597          	auipc	a1,0x7
    80001cea:	aca58593          	addi	a1,a1,-1334 # 800087b0 <initcode>
    80001cee:	6928                	ld	a0,80(a0)
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	724080e7          	jalr	1828(ra) # 80001414 <uvminit>
  p->sz = PGSIZE;
    80001cf8:	6785                	lui	a5,0x1
    80001cfa:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cfc:	6cb8                	ld	a4,88(s1)
    80001cfe:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d02:	6cb8                	ld	a4,88(s1)
    80001d04:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d06:	4641                	li	a2,16
    80001d08:	00006597          	auipc	a1,0x6
    80001d0c:	46858593          	addi	a1,a1,1128 # 80008170 <digits+0x130>
    80001d10:	15848513          	addi	a0,s1,344
    80001d14:	fffff097          	auipc	ra,0xfffff
    80001d18:	14e080e7          	jalr	334(ra) # 80000e62 <safestrcpy>
  p->cwd = namei("/");
    80001d1c:	00006517          	auipc	a0,0x6
    80001d20:	46450513          	addi	a0,a0,1124 # 80008180 <digits+0x140>
    80001d24:	00002097          	auipc	ra,0x2
    80001d28:	12e080e7          	jalr	302(ra) # 80003e52 <namei>
    80001d2c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d30:	4789                	li	a5,2
    80001d32:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d34:	8526                	mv	a0,s1
    80001d36:	fffff097          	auipc	ra,0xfffff
    80001d3a:	f8e080e7          	jalr	-114(ra) # 80000cc4 <release>
}
    80001d3e:	60e2                	ld	ra,24(sp)
    80001d40:	6442                	ld	s0,16(sp)
    80001d42:	64a2                	ld	s1,8(sp)
    80001d44:	6105                	addi	sp,sp,32
    80001d46:	8082                	ret

0000000080001d48 <growproc>:
{
    80001d48:	1101                	addi	sp,sp,-32
    80001d4a:	ec06                	sd	ra,24(sp)
    80001d4c:	e822                	sd	s0,16(sp)
    80001d4e:	e426                	sd	s1,8(sp)
    80001d50:	e04a                	sd	s2,0(sp)
    80001d52:	1000                	addi	s0,sp,32
    80001d54:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d56:	00000097          	auipc	ra,0x0
    80001d5a:	ca6080e7          	jalr	-858(ra) # 800019fc <myproc>
    80001d5e:	892a                	mv	s2,a0
  sz = p->sz;
    80001d60:	652c                	ld	a1,72(a0)
    80001d62:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d66:	00904f63          	bgtz	s1,80001d84 <growproc+0x3c>
  } else if(n < 0){
    80001d6a:	0204cc63          	bltz	s1,80001da2 <growproc+0x5a>
  p->sz = sz;
    80001d6e:	1602                	slli	a2,a2,0x20
    80001d70:	9201                	srli	a2,a2,0x20
    80001d72:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d76:	4501                	li	a0,0
}
    80001d78:	60e2                	ld	ra,24(sp)
    80001d7a:	6442                	ld	s0,16(sp)
    80001d7c:	64a2                	ld	s1,8(sp)
    80001d7e:	6902                	ld	s2,0(sp)
    80001d80:	6105                	addi	sp,sp,32
    80001d82:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d84:	9e25                	addw	a2,a2,s1
    80001d86:	1602                	slli	a2,a2,0x20
    80001d88:	9201                	srli	a2,a2,0x20
    80001d8a:	1582                	slli	a1,a1,0x20
    80001d8c:	9181                	srli	a1,a1,0x20
    80001d8e:	6928                	ld	a0,80(a0)
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	73e080e7          	jalr	1854(ra) # 800014ce <uvmalloc>
    80001d98:	0005061b          	sext.w	a2,a0
    80001d9c:	fa69                	bnez	a2,80001d6e <growproc+0x26>
      return -1;
    80001d9e:	557d                	li	a0,-1
    80001da0:	bfe1                	j	80001d78 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001da2:	9e25                	addw	a2,a2,s1
    80001da4:	1602                	slli	a2,a2,0x20
    80001da6:	9201                	srli	a2,a2,0x20
    80001da8:	1582                	slli	a1,a1,0x20
    80001daa:	9181                	srli	a1,a1,0x20
    80001dac:	6928                	ld	a0,80(a0)
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	6d8080e7          	jalr	1752(ra) # 80001486 <uvmdealloc>
    80001db6:	0005061b          	sext.w	a2,a0
    80001dba:	bf55                	j	80001d6e <growproc+0x26>

0000000080001dbc <fork>:
{
    80001dbc:	7179                	addi	sp,sp,-48
    80001dbe:	f406                	sd	ra,40(sp)
    80001dc0:	f022                	sd	s0,32(sp)
    80001dc2:	ec26                	sd	s1,24(sp)
    80001dc4:	e84a                	sd	s2,16(sp)
    80001dc6:	e44e                	sd	s3,8(sp)
    80001dc8:	e052                	sd	s4,0(sp)
    80001dca:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dcc:	00000097          	auipc	ra,0x0
    80001dd0:	c30080e7          	jalr	-976(ra) # 800019fc <myproc>
    80001dd4:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001dd6:	00000097          	auipc	ra,0x0
    80001dda:	e30080e7          	jalr	-464(ra) # 80001c06 <allocproc>
    80001dde:	c175                	beqz	a0,80001ec2 <fork+0x106>
    80001de0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001de2:	04893603          	ld	a2,72(s2)
    80001de6:	692c                	ld	a1,80(a0)
    80001de8:	05093503          	ld	a0,80(s2)
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	81c080e7          	jalr	-2020(ra) # 80001608 <uvmcopy>
    80001df4:	04054863          	bltz	a0,80001e44 <fork+0x88>
  np->sz = p->sz;
    80001df8:	04893783          	ld	a5,72(s2)
    80001dfc:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001e00:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e04:	05893683          	ld	a3,88(s2)
    80001e08:	87b6                	mv	a5,a3
    80001e0a:	0589b703          	ld	a4,88(s3)
    80001e0e:	12068693          	addi	a3,a3,288
    80001e12:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e16:	6788                	ld	a0,8(a5)
    80001e18:	6b8c                	ld	a1,16(a5)
    80001e1a:	6f90                	ld	a2,24(a5)
    80001e1c:	01073023          	sd	a6,0(a4)
    80001e20:	e708                	sd	a0,8(a4)
    80001e22:	eb0c                	sd	a1,16(a4)
    80001e24:	ef10                	sd	a2,24(a4)
    80001e26:	02078793          	addi	a5,a5,32
    80001e2a:	02070713          	addi	a4,a4,32
    80001e2e:	fed792e3          	bne	a5,a3,80001e12 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e32:	0589b783          	ld	a5,88(s3)
    80001e36:	0607b823          	sd	zero,112(a5)
    80001e3a:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e3e:	15000a13          	li	s4,336
    80001e42:	a03d                	j	80001e70 <fork+0xb4>
    freeproc(np);
    80001e44:	854e                	mv	a0,s3
    80001e46:	00000097          	auipc	ra,0x0
    80001e4a:	d68080e7          	jalr	-664(ra) # 80001bae <freeproc>
    release(&np->lock);
    80001e4e:	854e                	mv	a0,s3
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	e74080e7          	jalr	-396(ra) # 80000cc4 <release>
    return -1;
    80001e58:	54fd                	li	s1,-1
    80001e5a:	a899                	j	80001eb0 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e5c:	00002097          	auipc	ra,0x2
    80001e60:	682080e7          	jalr	1666(ra) # 800044de <filedup>
    80001e64:	009987b3          	add	a5,s3,s1
    80001e68:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e6a:	04a1                	addi	s1,s1,8
    80001e6c:	01448763          	beq	s1,s4,80001e7a <fork+0xbe>
    if(p->ofile[i])
    80001e70:	009907b3          	add	a5,s2,s1
    80001e74:	6388                	ld	a0,0(a5)
    80001e76:	f17d                	bnez	a0,80001e5c <fork+0xa0>
    80001e78:	bfcd                	j	80001e6a <fork+0xae>
  np->cwd = idup(p->cwd);
    80001e7a:	15093503          	ld	a0,336(s2)
    80001e7e:	00001097          	auipc	ra,0x1
    80001e82:	7e2080e7          	jalr	2018(ra) # 80003660 <idup>
    80001e86:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e8a:	4641                	li	a2,16
    80001e8c:	15890593          	addi	a1,s2,344
    80001e90:	15898513          	addi	a0,s3,344
    80001e94:	fffff097          	auipc	ra,0xfffff
    80001e98:	fce080e7          	jalr	-50(ra) # 80000e62 <safestrcpy>
  pid = np->pid;
    80001e9c:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001ea0:	4789                	li	a5,2
    80001ea2:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ea6:	854e                	mv	a0,s3
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	e1c080e7          	jalr	-484(ra) # 80000cc4 <release>
}
    80001eb0:	8526                	mv	a0,s1
    80001eb2:	70a2                	ld	ra,40(sp)
    80001eb4:	7402                	ld	s0,32(sp)
    80001eb6:	64e2                	ld	s1,24(sp)
    80001eb8:	6942                	ld	s2,16(sp)
    80001eba:	69a2                	ld	s3,8(sp)
    80001ebc:	6a02                	ld	s4,0(sp)
    80001ebe:	6145                	addi	sp,sp,48
    80001ec0:	8082                	ret
    return -1;
    80001ec2:	54fd                	li	s1,-1
    80001ec4:	b7f5                	j	80001eb0 <fork+0xf4>

0000000080001ec6 <reparent>:
{
    80001ec6:	7179                	addi	sp,sp,-48
    80001ec8:	f406                	sd	ra,40(sp)
    80001eca:	f022                	sd	s0,32(sp)
    80001ecc:	ec26                	sd	s1,24(sp)
    80001ece:	e84a                	sd	s2,16(sp)
    80001ed0:	e44e                	sd	s3,8(sp)
    80001ed2:	e052                	sd	s4,0(sp)
    80001ed4:	1800                	addi	s0,sp,48
    80001ed6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ed8:	00010497          	auipc	s1,0x10
    80001edc:	e9048493          	addi	s1,s1,-368 # 80011d68 <proc>
      pp->parent = initproc;
    80001ee0:	00007a17          	auipc	s4,0x7
    80001ee4:	138a0a13          	addi	s4,s4,312 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ee8:	00016997          	auipc	s3,0x16
    80001eec:	88098993          	addi	s3,s3,-1920 # 80017768 <tickslock>
    80001ef0:	a029                	j	80001efa <reparent+0x34>
    80001ef2:	16848493          	addi	s1,s1,360
    80001ef6:	03348363          	beq	s1,s3,80001f1c <reparent+0x56>
    if(pp->parent == p){
    80001efa:	709c                	ld	a5,32(s1)
    80001efc:	ff279be3          	bne	a5,s2,80001ef2 <reparent+0x2c>
      acquire(&pp->lock);
    80001f00:	8526                	mv	a0,s1
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	d0e080e7          	jalr	-754(ra) # 80000c10 <acquire>
      pp->parent = initproc;
    80001f0a:	000a3783          	ld	a5,0(s4)
    80001f0e:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f10:	8526                	mv	a0,s1
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	db2080e7          	jalr	-590(ra) # 80000cc4 <release>
    80001f1a:	bfe1                	j	80001ef2 <reparent+0x2c>
}
    80001f1c:	70a2                	ld	ra,40(sp)
    80001f1e:	7402                	ld	s0,32(sp)
    80001f20:	64e2                	ld	s1,24(sp)
    80001f22:	6942                	ld	s2,16(sp)
    80001f24:	69a2                	ld	s3,8(sp)
    80001f26:	6a02                	ld	s4,0(sp)
    80001f28:	6145                	addi	sp,sp,48
    80001f2a:	8082                	ret

0000000080001f2c <scheduler>:
{
    80001f2c:	711d                	addi	sp,sp,-96
    80001f2e:	ec86                	sd	ra,88(sp)
    80001f30:	e8a2                	sd	s0,80(sp)
    80001f32:	e4a6                	sd	s1,72(sp)
    80001f34:	e0ca                	sd	s2,64(sp)
    80001f36:	fc4e                	sd	s3,56(sp)
    80001f38:	f852                	sd	s4,48(sp)
    80001f3a:	f456                	sd	s5,40(sp)
    80001f3c:	f05a                	sd	s6,32(sp)
    80001f3e:	ec5e                	sd	s7,24(sp)
    80001f40:	e862                	sd	s8,16(sp)
    80001f42:	e466                	sd	s9,8(sp)
    80001f44:	1080                	addi	s0,sp,96
    80001f46:	8792                	mv	a5,tp
  int id = r_tp();
    80001f48:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f4a:	00779c13          	slli	s8,a5,0x7
    80001f4e:	00010717          	auipc	a4,0x10
    80001f52:	a0270713          	addi	a4,a4,-1534 # 80011950 <pid_lock>
    80001f56:	9762                	add	a4,a4,s8
    80001f58:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f5c:	00010717          	auipc	a4,0x10
    80001f60:	a1470713          	addi	a4,a4,-1516 # 80011970 <cpus+0x8>
    80001f64:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80001f66:	4a89                	li	s5,2
        c->proc = p;
    80001f68:	079e                	slli	a5,a5,0x7
    80001f6a:	00010b17          	auipc	s6,0x10
    80001f6e:	9e6b0b13          	addi	s6,s6,-1562 # 80011950 <pid_lock>
    80001f72:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f74:	00015a17          	auipc	s4,0x15
    80001f78:	7f4a0a13          	addi	s4,s4,2036 # 80017768 <tickslock>
    int nproc = 0;
    80001f7c:	4c81                	li	s9,0
    80001f7e:	a8a1                	j	80001fd6 <scheduler+0xaa>
        p->state = RUNNING;
    80001f80:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001f84:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80001f88:	06048593          	addi	a1,s1,96
    80001f8c:	8562                	mv	a0,s8
    80001f8e:	00000097          	auipc	ra,0x0
    80001f92:	63a080e7          	jalr	1594(ra) # 800025c8 <swtch>
        c->proc = 0;
    80001f96:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	d28080e7          	jalr	-728(ra) # 80000cc4 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fa4:	16848493          	addi	s1,s1,360
    80001fa8:	01448d63          	beq	s1,s4,80001fc2 <scheduler+0x96>
      acquire(&p->lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	c62080e7          	jalr	-926(ra) # 80000c10 <acquire>
      if(p->state != UNUSED) {
    80001fb6:	4c9c                	lw	a5,24(s1)
    80001fb8:	d3ed                	beqz	a5,80001f9a <scheduler+0x6e>
        nproc++;
    80001fba:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    80001fbc:	fd579fe3          	bne	a5,s5,80001f9a <scheduler+0x6e>
    80001fc0:	b7c1                	j	80001f80 <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    80001fc2:	013aca63          	blt	s5,s3,80001fd6 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fca:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fce:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001fd2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fda:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fde:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80001fe2:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fe4:	00010497          	auipc	s1,0x10
    80001fe8:	d8448493          	addi	s1,s1,-636 # 80011d68 <proc>
        p->state = RUNNING;
    80001fec:	4b8d                	li	s7,3
    80001fee:	bf7d                	j	80001fac <scheduler+0x80>

0000000080001ff0 <sched>:
{
    80001ff0:	7179                	addi	sp,sp,-48
    80001ff2:	f406                	sd	ra,40(sp)
    80001ff4:	f022                	sd	s0,32(sp)
    80001ff6:	ec26                	sd	s1,24(sp)
    80001ff8:	e84a                	sd	s2,16(sp)
    80001ffa:	e44e                	sd	s3,8(sp)
    80001ffc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	9fe080e7          	jalr	-1538(ra) # 800019fc <myproc>
    80002006:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	b8e080e7          	jalr	-1138(ra) # 80000b96 <holding>
    80002010:	c93d                	beqz	a0,80002086 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002012:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002014:	2781                	sext.w	a5,a5
    80002016:	079e                	slli	a5,a5,0x7
    80002018:	00010717          	auipc	a4,0x10
    8000201c:	93870713          	addi	a4,a4,-1736 # 80011950 <pid_lock>
    80002020:	97ba                	add	a5,a5,a4
    80002022:	0907a703          	lw	a4,144(a5)
    80002026:	4785                	li	a5,1
    80002028:	06f71763          	bne	a4,a5,80002096 <sched+0xa6>
  if(p->state == RUNNING)
    8000202c:	4c98                	lw	a4,24(s1)
    8000202e:	478d                	li	a5,3
    80002030:	06f70b63          	beq	a4,a5,800020a6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002034:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002038:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000203a:	efb5                	bnez	a5,800020b6 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000203c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000203e:	00010917          	auipc	s2,0x10
    80002042:	91290913          	addi	s2,s2,-1774 # 80011950 <pid_lock>
    80002046:	2781                	sext.w	a5,a5
    80002048:	079e                	slli	a5,a5,0x7
    8000204a:	97ca                	add	a5,a5,s2
    8000204c:	0947a983          	lw	s3,148(a5)
    80002050:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002052:	2781                	sext.w	a5,a5
    80002054:	079e                	slli	a5,a5,0x7
    80002056:	00010597          	auipc	a1,0x10
    8000205a:	91a58593          	addi	a1,a1,-1766 # 80011970 <cpus+0x8>
    8000205e:	95be                	add	a1,a1,a5
    80002060:	06048513          	addi	a0,s1,96
    80002064:	00000097          	auipc	ra,0x0
    80002068:	564080e7          	jalr	1380(ra) # 800025c8 <swtch>
    8000206c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000206e:	2781                	sext.w	a5,a5
    80002070:	079e                	slli	a5,a5,0x7
    80002072:	97ca                	add	a5,a5,s2
    80002074:	0937aa23          	sw	s3,148(a5)
}
    80002078:	70a2                	ld	ra,40(sp)
    8000207a:	7402                	ld	s0,32(sp)
    8000207c:	64e2                	ld	s1,24(sp)
    8000207e:	6942                	ld	s2,16(sp)
    80002080:	69a2                	ld	s3,8(sp)
    80002082:	6145                	addi	sp,sp,48
    80002084:	8082                	ret
    panic("sched p->lock");
    80002086:	00006517          	auipc	a0,0x6
    8000208a:	10250513          	addi	a0,a0,258 # 80008188 <digits+0x148>
    8000208e:	ffffe097          	auipc	ra,0xffffe
    80002092:	4ba080e7          	jalr	1210(ra) # 80000548 <panic>
    panic("sched locks");
    80002096:	00006517          	auipc	a0,0x6
    8000209a:	10250513          	addi	a0,a0,258 # 80008198 <digits+0x158>
    8000209e:	ffffe097          	auipc	ra,0xffffe
    800020a2:	4aa080e7          	jalr	1194(ra) # 80000548 <panic>
    panic("sched running");
    800020a6:	00006517          	auipc	a0,0x6
    800020aa:	10250513          	addi	a0,a0,258 # 800081a8 <digits+0x168>
    800020ae:	ffffe097          	auipc	ra,0xffffe
    800020b2:	49a080e7          	jalr	1178(ra) # 80000548 <panic>
    panic("sched interruptible");
    800020b6:	00006517          	auipc	a0,0x6
    800020ba:	10250513          	addi	a0,a0,258 # 800081b8 <digits+0x178>
    800020be:	ffffe097          	auipc	ra,0xffffe
    800020c2:	48a080e7          	jalr	1162(ra) # 80000548 <panic>

00000000800020c6 <exit>:
{
    800020c6:	7179                	addi	sp,sp,-48
    800020c8:	f406                	sd	ra,40(sp)
    800020ca:	f022                	sd	s0,32(sp)
    800020cc:	ec26                	sd	s1,24(sp)
    800020ce:	e84a                	sd	s2,16(sp)
    800020d0:	e44e                	sd	s3,8(sp)
    800020d2:	e052                	sd	s4,0(sp)
    800020d4:	1800                	addi	s0,sp,48
    800020d6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020d8:	00000097          	auipc	ra,0x0
    800020dc:	924080e7          	jalr	-1756(ra) # 800019fc <myproc>
    800020e0:	89aa                	mv	s3,a0
  if(p == initproc)
    800020e2:	00007797          	auipc	a5,0x7
    800020e6:	f367b783          	ld	a5,-202(a5) # 80009018 <initproc>
    800020ea:	0d050493          	addi	s1,a0,208
    800020ee:	15050913          	addi	s2,a0,336
    800020f2:	02a79363          	bne	a5,a0,80002118 <exit+0x52>
    panic("init exiting");
    800020f6:	00006517          	auipc	a0,0x6
    800020fa:	0da50513          	addi	a0,a0,218 # 800081d0 <digits+0x190>
    800020fe:	ffffe097          	auipc	ra,0xffffe
    80002102:	44a080e7          	jalr	1098(ra) # 80000548 <panic>
      fileclose(f);
    80002106:	00002097          	auipc	ra,0x2
    8000210a:	42a080e7          	jalr	1066(ra) # 80004530 <fileclose>
      p->ofile[fd] = 0;
    8000210e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002112:	04a1                	addi	s1,s1,8
    80002114:	01248563          	beq	s1,s2,8000211e <exit+0x58>
    if(p->ofile[fd]){
    80002118:	6088                	ld	a0,0(s1)
    8000211a:	f575                	bnez	a0,80002106 <exit+0x40>
    8000211c:	bfdd                	j	80002112 <exit+0x4c>
  begin_op();
    8000211e:	00002097          	auipc	ra,0x2
    80002122:	f40080e7          	jalr	-192(ra) # 8000405e <begin_op>
  iput(p->cwd);
    80002126:	1509b503          	ld	a0,336(s3)
    8000212a:	00001097          	auipc	ra,0x1
    8000212e:	72e080e7          	jalr	1838(ra) # 80003858 <iput>
  end_op();
    80002132:	00002097          	auipc	ra,0x2
    80002136:	fac080e7          	jalr	-84(ra) # 800040de <end_op>
  p->cwd = 0;
    8000213a:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000213e:	00007497          	auipc	s1,0x7
    80002142:	eda48493          	addi	s1,s1,-294 # 80009018 <initproc>
    80002146:	6088                	ld	a0,0(s1)
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	ac8080e7          	jalr	-1336(ra) # 80000c10 <acquire>
  wakeup1(initproc);
    80002150:	6088                	ld	a0,0(s1)
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	76a080e7          	jalr	1898(ra) # 800018bc <wakeup1>
  release(&initproc->lock);
    8000215a:	6088                	ld	a0,0(s1)
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	b68080e7          	jalr	-1176(ra) # 80000cc4 <release>
  acquire(&p->lock);
    80002164:	854e                	mv	a0,s3
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	aaa080e7          	jalr	-1366(ra) # 80000c10 <acquire>
  struct proc *original_parent = p->parent;
    8000216e:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002172:	854e                	mv	a0,s3
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	b50080e7          	jalr	-1200(ra) # 80000cc4 <release>
  acquire(&original_parent->lock);
    8000217c:	8526                	mv	a0,s1
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	a92080e7          	jalr	-1390(ra) # 80000c10 <acquire>
  acquire(&p->lock);
    80002186:	854e                	mv	a0,s3
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	a88080e7          	jalr	-1400(ra) # 80000c10 <acquire>
  reparent(p);
    80002190:	854e                	mv	a0,s3
    80002192:	00000097          	auipc	ra,0x0
    80002196:	d34080e7          	jalr	-716(ra) # 80001ec6 <reparent>
  wakeup1(original_parent);
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	720080e7          	jalr	1824(ra) # 800018bc <wakeup1>
  p->xstate = status;
    800021a4:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021a8:	4791                	li	a5,4
    800021aa:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021ae:	8526                	mv	a0,s1
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	b14080e7          	jalr	-1260(ra) # 80000cc4 <release>
  sched();
    800021b8:	00000097          	auipc	ra,0x0
    800021bc:	e38080e7          	jalr	-456(ra) # 80001ff0 <sched>
  panic("zombie exit");
    800021c0:	00006517          	auipc	a0,0x6
    800021c4:	02050513          	addi	a0,a0,32 # 800081e0 <digits+0x1a0>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	380080e7          	jalr	896(ra) # 80000548 <panic>

00000000800021d0 <yield>:
{
    800021d0:	1101                	addi	sp,sp,-32
    800021d2:	ec06                	sd	ra,24(sp)
    800021d4:	e822                	sd	s0,16(sp)
    800021d6:	e426                	sd	s1,8(sp)
    800021d8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021da:	00000097          	auipc	ra,0x0
    800021de:	822080e7          	jalr	-2014(ra) # 800019fc <myproc>
    800021e2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	a2c080e7          	jalr	-1492(ra) # 80000c10 <acquire>
  p->state = RUNNABLE;
    800021ec:	4789                	li	a5,2
    800021ee:	cc9c                	sw	a5,24(s1)
  sched();
    800021f0:	00000097          	auipc	ra,0x0
    800021f4:	e00080e7          	jalr	-512(ra) # 80001ff0 <sched>
  release(&p->lock);
    800021f8:	8526                	mv	a0,s1
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	aca080e7          	jalr	-1334(ra) # 80000cc4 <release>
}
    80002202:	60e2                	ld	ra,24(sp)
    80002204:	6442                	ld	s0,16(sp)
    80002206:	64a2                	ld	s1,8(sp)
    80002208:	6105                	addi	sp,sp,32
    8000220a:	8082                	ret

000000008000220c <sleep>:
{
    8000220c:	7179                	addi	sp,sp,-48
    8000220e:	f406                	sd	ra,40(sp)
    80002210:	f022                	sd	s0,32(sp)
    80002212:	ec26                	sd	s1,24(sp)
    80002214:	e84a                	sd	s2,16(sp)
    80002216:	e44e                	sd	s3,8(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	89aa                	mv	s3,a0
    8000221c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	7de080e7          	jalr	2014(ra) # 800019fc <myproc>
    80002226:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002228:	05250663          	beq	a0,s2,80002274 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	9e4080e7          	jalr	-1564(ra) # 80000c10 <acquire>
    release(lk);
    80002234:	854a                	mv	a0,s2
    80002236:	fffff097          	auipc	ra,0xfffff
    8000223a:	a8e080e7          	jalr	-1394(ra) # 80000cc4 <release>
  p->chan = chan;
    8000223e:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002242:	4785                	li	a5,1
    80002244:	cc9c                	sw	a5,24(s1)
  sched();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	daa080e7          	jalr	-598(ra) # 80001ff0 <sched>
  p->chan = 0;
    8000224e:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002252:	8526                	mv	a0,s1
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	a70080e7          	jalr	-1424(ra) # 80000cc4 <release>
    acquire(lk);
    8000225c:	854a                	mv	a0,s2
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	9b2080e7          	jalr	-1614(ra) # 80000c10 <acquire>
}
    80002266:	70a2                	ld	ra,40(sp)
    80002268:	7402                	ld	s0,32(sp)
    8000226a:	64e2                	ld	s1,24(sp)
    8000226c:	6942                	ld	s2,16(sp)
    8000226e:	69a2                	ld	s3,8(sp)
    80002270:	6145                	addi	sp,sp,48
    80002272:	8082                	ret
  p->chan = chan;
    80002274:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002278:	4785                	li	a5,1
    8000227a:	cd1c                	sw	a5,24(a0)
  sched();
    8000227c:	00000097          	auipc	ra,0x0
    80002280:	d74080e7          	jalr	-652(ra) # 80001ff0 <sched>
  p->chan = 0;
    80002284:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002288:	bff9                	j	80002266 <sleep+0x5a>

000000008000228a <wait>:
{
    8000228a:	715d                	addi	sp,sp,-80
    8000228c:	e486                	sd	ra,72(sp)
    8000228e:	e0a2                	sd	s0,64(sp)
    80002290:	fc26                	sd	s1,56(sp)
    80002292:	f84a                	sd	s2,48(sp)
    80002294:	f44e                	sd	s3,40(sp)
    80002296:	f052                	sd	s4,32(sp)
    80002298:	ec56                	sd	s5,24(sp)
    8000229a:	e85a                	sd	s6,16(sp)
    8000229c:	e45e                	sd	s7,8(sp)
    8000229e:	e062                	sd	s8,0(sp)
    800022a0:	0880                	addi	s0,sp,80
    800022a2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	758080e7          	jalr	1880(ra) # 800019fc <myproc>
    800022ac:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022ae:	8c2a                	mv	s8,a0
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	960080e7          	jalr	-1696(ra) # 80000c10 <acquire>
    havekids = 0;
    800022b8:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022ba:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800022bc:	00015997          	auipc	s3,0x15
    800022c0:	4ac98993          	addi	s3,s3,1196 # 80017768 <tickslock>
        havekids = 1;
    800022c4:	4a85                	li	s5,1
    havekids = 0;
    800022c6:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022c8:	00010497          	auipc	s1,0x10
    800022cc:	aa048493          	addi	s1,s1,-1376 # 80011d68 <proc>
    800022d0:	a08d                	j	80002332 <wait+0xa8>
          pid = np->pid;
    800022d2:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022d6:	000b0e63          	beqz	s6,800022f2 <wait+0x68>
    800022da:	4691                	li	a3,4
    800022dc:	03448613          	addi	a2,s1,52
    800022e0:	85da                	mv	a1,s6
    800022e2:	05093503          	ld	a0,80(s2)
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	40a080e7          	jalr	1034(ra) # 800016f0 <copyout>
    800022ee:	02054263          	bltz	a0,80002312 <wait+0x88>
          freeproc(np);
    800022f2:	8526                	mv	a0,s1
    800022f4:	00000097          	auipc	ra,0x0
    800022f8:	8ba080e7          	jalr	-1862(ra) # 80001bae <freeproc>
          release(&np->lock);
    800022fc:	8526                	mv	a0,s1
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	9c6080e7          	jalr	-1594(ra) # 80000cc4 <release>
          release(&p->lock);
    80002306:	854a                	mv	a0,s2
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	9bc080e7          	jalr	-1604(ra) # 80000cc4 <release>
          return pid;
    80002310:	a8a9                	j	8000236a <wait+0xe0>
            release(&np->lock);
    80002312:	8526                	mv	a0,s1
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	9b0080e7          	jalr	-1616(ra) # 80000cc4 <release>
            release(&p->lock);
    8000231c:	854a                	mv	a0,s2
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	9a6080e7          	jalr	-1626(ra) # 80000cc4 <release>
            return -1;
    80002326:	59fd                	li	s3,-1
    80002328:	a089                	j	8000236a <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    8000232a:	16848493          	addi	s1,s1,360
    8000232e:	03348463          	beq	s1,s3,80002356 <wait+0xcc>
      if(np->parent == p){
    80002332:	709c                	ld	a5,32(s1)
    80002334:	ff279be3          	bne	a5,s2,8000232a <wait+0xa0>
        acquire(&np->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	8d6080e7          	jalr	-1834(ra) # 80000c10 <acquire>
        if(np->state == ZOMBIE){
    80002342:	4c9c                	lw	a5,24(s1)
    80002344:	f94787e3          	beq	a5,s4,800022d2 <wait+0x48>
        release(&np->lock);
    80002348:	8526                	mv	a0,s1
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	97a080e7          	jalr	-1670(ra) # 80000cc4 <release>
        havekids = 1;
    80002352:	8756                	mv	a4,s5
    80002354:	bfd9                	j	8000232a <wait+0xa0>
    if(!havekids || p->killed){
    80002356:	c701                	beqz	a4,8000235e <wait+0xd4>
    80002358:	03092783          	lw	a5,48(s2)
    8000235c:	c785                	beqz	a5,80002384 <wait+0xfa>
      release(&p->lock);
    8000235e:	854a                	mv	a0,s2
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	964080e7          	jalr	-1692(ra) # 80000cc4 <release>
      return -1;
    80002368:	59fd                	li	s3,-1
}
    8000236a:	854e                	mv	a0,s3
    8000236c:	60a6                	ld	ra,72(sp)
    8000236e:	6406                	ld	s0,64(sp)
    80002370:	74e2                	ld	s1,56(sp)
    80002372:	7942                	ld	s2,48(sp)
    80002374:	79a2                	ld	s3,40(sp)
    80002376:	7a02                	ld	s4,32(sp)
    80002378:	6ae2                	ld	s5,24(sp)
    8000237a:	6b42                	ld	s6,16(sp)
    8000237c:	6ba2                	ld	s7,8(sp)
    8000237e:	6c02                	ld	s8,0(sp)
    80002380:	6161                	addi	sp,sp,80
    80002382:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002384:	85e2                	mv	a1,s8
    80002386:	854a                	mv	a0,s2
    80002388:	00000097          	auipc	ra,0x0
    8000238c:	e84080e7          	jalr	-380(ra) # 8000220c <sleep>
    havekids = 0;
    80002390:	bf1d                	j	800022c6 <wait+0x3c>

0000000080002392 <wakeup>:
{
    80002392:	7139                	addi	sp,sp,-64
    80002394:	fc06                	sd	ra,56(sp)
    80002396:	f822                	sd	s0,48(sp)
    80002398:	f426                	sd	s1,40(sp)
    8000239a:	f04a                	sd	s2,32(sp)
    8000239c:	ec4e                	sd	s3,24(sp)
    8000239e:	e852                	sd	s4,16(sp)
    800023a0:	e456                	sd	s5,8(sp)
    800023a2:	0080                	addi	s0,sp,64
    800023a4:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023a6:	00010497          	auipc	s1,0x10
    800023aa:	9c248493          	addi	s1,s1,-1598 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023ae:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023b0:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023b2:	00015917          	auipc	s2,0x15
    800023b6:	3b690913          	addi	s2,s2,950 # 80017768 <tickslock>
    800023ba:	a821                	j	800023d2 <wakeup+0x40>
      p->state = RUNNABLE;
    800023bc:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800023c0:	8526                	mv	a0,s1
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	902080e7          	jalr	-1790(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023ca:	16848493          	addi	s1,s1,360
    800023ce:	01248e63          	beq	s1,s2,800023ea <wakeup+0x58>
    acquire(&p->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	83c080e7          	jalr	-1988(ra) # 80000c10 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023dc:	4c9c                	lw	a5,24(s1)
    800023de:	ff3791e3          	bne	a5,s3,800023c0 <wakeup+0x2e>
    800023e2:	749c                	ld	a5,40(s1)
    800023e4:	fd479ee3          	bne	a5,s4,800023c0 <wakeup+0x2e>
    800023e8:	bfd1                	j	800023bc <wakeup+0x2a>
}
    800023ea:	70e2                	ld	ra,56(sp)
    800023ec:	7442                	ld	s0,48(sp)
    800023ee:	74a2                	ld	s1,40(sp)
    800023f0:	7902                	ld	s2,32(sp)
    800023f2:	69e2                	ld	s3,24(sp)
    800023f4:	6a42                	ld	s4,16(sp)
    800023f6:	6aa2                	ld	s5,8(sp)
    800023f8:	6121                	addi	sp,sp,64
    800023fa:	8082                	ret

00000000800023fc <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023fc:	7179                	addi	sp,sp,-48
    800023fe:	f406                	sd	ra,40(sp)
    80002400:	f022                	sd	s0,32(sp)
    80002402:	ec26                	sd	s1,24(sp)
    80002404:	e84a                	sd	s2,16(sp)
    80002406:	e44e                	sd	s3,8(sp)
    80002408:	1800                	addi	s0,sp,48
    8000240a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000240c:	00010497          	auipc	s1,0x10
    80002410:	95c48493          	addi	s1,s1,-1700 # 80011d68 <proc>
    80002414:	00015997          	auipc	s3,0x15
    80002418:	35498993          	addi	s3,s3,852 # 80017768 <tickslock>
    acquire(&p->lock);
    8000241c:	8526                	mv	a0,s1
    8000241e:	ffffe097          	auipc	ra,0xffffe
    80002422:	7f2080e7          	jalr	2034(ra) # 80000c10 <acquire>
    if(p->pid == pid){
    80002426:	5c9c                	lw	a5,56(s1)
    80002428:	01278d63          	beq	a5,s2,80002442 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000242c:	8526                	mv	a0,s1
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	896080e7          	jalr	-1898(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002436:	16848493          	addi	s1,s1,360
    8000243a:	ff3491e3          	bne	s1,s3,8000241c <kill+0x20>
  }
  return -1;
    8000243e:	557d                	li	a0,-1
    80002440:	a829                	j	8000245a <kill+0x5e>
      p->killed = 1;
    80002442:	4785                	li	a5,1
    80002444:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002446:	4c98                	lw	a4,24(s1)
    80002448:	4785                	li	a5,1
    8000244a:	00f70f63          	beq	a4,a5,80002468 <kill+0x6c>
      release(&p->lock);
    8000244e:	8526                	mv	a0,s1
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	874080e7          	jalr	-1932(ra) # 80000cc4 <release>
      return 0;
    80002458:	4501                	li	a0,0
}
    8000245a:	70a2                	ld	ra,40(sp)
    8000245c:	7402                	ld	s0,32(sp)
    8000245e:	64e2                	ld	s1,24(sp)
    80002460:	6942                	ld	s2,16(sp)
    80002462:	69a2                	ld	s3,8(sp)
    80002464:	6145                	addi	sp,sp,48
    80002466:	8082                	ret
        p->state = RUNNABLE;
    80002468:	4789                	li	a5,2
    8000246a:	cc9c                	sw	a5,24(s1)
    8000246c:	b7cd                	j	8000244e <kill+0x52>

000000008000246e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000246e:	7179                	addi	sp,sp,-48
    80002470:	f406                	sd	ra,40(sp)
    80002472:	f022                	sd	s0,32(sp)
    80002474:	ec26                	sd	s1,24(sp)
    80002476:	e84a                	sd	s2,16(sp)
    80002478:	e44e                	sd	s3,8(sp)
    8000247a:	e052                	sd	s4,0(sp)
    8000247c:	1800                	addi	s0,sp,48
    8000247e:	84aa                	mv	s1,a0
    80002480:	892e                	mv	s2,a1
    80002482:	89b2                	mv	s3,a2
    80002484:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	576080e7          	jalr	1398(ra) # 800019fc <myproc>
  if(user_dst){
    8000248e:	c08d                	beqz	s1,800024b0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002490:	86d2                	mv	a3,s4
    80002492:	864e                	mv	a2,s3
    80002494:	85ca                	mv	a1,s2
    80002496:	6928                	ld	a0,80(a0)
    80002498:	fffff097          	auipc	ra,0xfffff
    8000249c:	258080e7          	jalr	600(ra) # 800016f0 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024a0:	70a2                	ld	ra,40(sp)
    800024a2:	7402                	ld	s0,32(sp)
    800024a4:	64e2                	ld	s1,24(sp)
    800024a6:	6942                	ld	s2,16(sp)
    800024a8:	69a2                	ld	s3,8(sp)
    800024aa:	6a02                	ld	s4,0(sp)
    800024ac:	6145                	addi	sp,sp,48
    800024ae:	8082                	ret
    memmove((char *)dst, src, len);
    800024b0:	000a061b          	sext.w	a2,s4
    800024b4:	85ce                	mv	a1,s3
    800024b6:	854a                	mv	a0,s2
    800024b8:	fffff097          	auipc	ra,0xfffff
    800024bc:	8b4080e7          	jalr	-1868(ra) # 80000d6c <memmove>
    return 0;
    800024c0:	8526                	mv	a0,s1
    800024c2:	bff9                	j	800024a0 <either_copyout+0x32>

00000000800024c4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024c4:	7179                	addi	sp,sp,-48
    800024c6:	f406                	sd	ra,40(sp)
    800024c8:	f022                	sd	s0,32(sp)
    800024ca:	ec26                	sd	s1,24(sp)
    800024cc:	e84a                	sd	s2,16(sp)
    800024ce:	e44e                	sd	s3,8(sp)
    800024d0:	e052                	sd	s4,0(sp)
    800024d2:	1800                	addi	s0,sp,48
    800024d4:	892a                	mv	s2,a0
    800024d6:	84ae                	mv	s1,a1
    800024d8:	89b2                	mv	s3,a2
    800024da:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	520080e7          	jalr	1312(ra) # 800019fc <myproc>
  if(user_src){
    800024e4:	c08d                	beqz	s1,80002506 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024e6:	86d2                	mv	a3,s4
    800024e8:	864e                	mv	a2,s3
    800024ea:	85ca                	mv	a1,s2
    800024ec:	6928                	ld	a0,80(a0)
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	28e080e7          	jalr	654(ra) # 8000177c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024f6:	70a2                	ld	ra,40(sp)
    800024f8:	7402                	ld	s0,32(sp)
    800024fa:	64e2                	ld	s1,24(sp)
    800024fc:	6942                	ld	s2,16(sp)
    800024fe:	69a2                	ld	s3,8(sp)
    80002500:	6a02                	ld	s4,0(sp)
    80002502:	6145                	addi	sp,sp,48
    80002504:	8082                	ret
    memmove(dst, (char*)src, len);
    80002506:	000a061b          	sext.w	a2,s4
    8000250a:	85ce                	mv	a1,s3
    8000250c:	854a                	mv	a0,s2
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	85e080e7          	jalr	-1954(ra) # 80000d6c <memmove>
    return 0;
    80002516:	8526                	mv	a0,s1
    80002518:	bff9                	j	800024f6 <either_copyin+0x32>

000000008000251a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000251a:	715d                	addi	sp,sp,-80
    8000251c:	e486                	sd	ra,72(sp)
    8000251e:	e0a2                	sd	s0,64(sp)
    80002520:	fc26                	sd	s1,56(sp)
    80002522:	f84a                	sd	s2,48(sp)
    80002524:	f44e                	sd	s3,40(sp)
    80002526:	f052                	sd	s4,32(sp)
    80002528:	ec56                	sd	s5,24(sp)
    8000252a:	e85a                	sd	s6,16(sp)
    8000252c:	e45e                	sd	s7,8(sp)
    8000252e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002530:	00006517          	auipc	a0,0x6
    80002534:	b9850513          	addi	a0,a0,-1128 # 800080c8 <digits+0x88>
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	05a080e7          	jalr	90(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002540:	00010497          	auipc	s1,0x10
    80002544:	98048493          	addi	s1,s1,-1664 # 80011ec0 <proc+0x158>
    80002548:	00015917          	auipc	s2,0x15
    8000254c:	37890913          	addi	s2,s2,888 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002550:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002552:	00006997          	auipc	s3,0x6
    80002556:	c9e98993          	addi	s3,s3,-866 # 800081f0 <digits+0x1b0>
    printf("%d %s %s", p->pid, state, p->name);
    8000255a:	00006a97          	auipc	s5,0x6
    8000255e:	c9ea8a93          	addi	s5,s5,-866 # 800081f8 <digits+0x1b8>
    printf("\n");
    80002562:	00006a17          	auipc	s4,0x6
    80002566:	b66a0a13          	addi	s4,s4,-1178 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000256a:	00006b97          	auipc	s7,0x6
    8000256e:	cc6b8b93          	addi	s7,s7,-826 # 80008230 <states.1702>
    80002572:	a00d                	j	80002594 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002574:	ee06a583          	lw	a1,-288(a3)
    80002578:	8556                	mv	a0,s5
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	018080e7          	jalr	24(ra) # 80000592 <printf>
    printf("\n");
    80002582:	8552                	mv	a0,s4
    80002584:	ffffe097          	auipc	ra,0xffffe
    80002588:	00e080e7          	jalr	14(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000258c:	16848493          	addi	s1,s1,360
    80002590:	03248163          	beq	s1,s2,800025b2 <procdump+0x98>
    if(p->state == UNUSED)
    80002594:	86a6                	mv	a3,s1
    80002596:	ec04a783          	lw	a5,-320(s1)
    8000259a:	dbed                	beqz	a5,8000258c <procdump+0x72>
      state = "???";
    8000259c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000259e:	fcfb6be3          	bltu	s6,a5,80002574 <procdump+0x5a>
    800025a2:	1782                	slli	a5,a5,0x20
    800025a4:	9381                	srli	a5,a5,0x20
    800025a6:	078e                	slli	a5,a5,0x3
    800025a8:	97de                	add	a5,a5,s7
    800025aa:	6390                	ld	a2,0(a5)
    800025ac:	f661                	bnez	a2,80002574 <procdump+0x5a>
      state = "???";
    800025ae:	864e                	mv	a2,s3
    800025b0:	b7d1                	j	80002574 <procdump+0x5a>
  }
}
    800025b2:	60a6                	ld	ra,72(sp)
    800025b4:	6406                	ld	s0,64(sp)
    800025b6:	74e2                	ld	s1,56(sp)
    800025b8:	7942                	ld	s2,48(sp)
    800025ba:	79a2                	ld	s3,40(sp)
    800025bc:	7a02                	ld	s4,32(sp)
    800025be:	6ae2                	ld	s5,24(sp)
    800025c0:	6b42                	ld	s6,16(sp)
    800025c2:	6ba2                	ld	s7,8(sp)
    800025c4:	6161                	addi	sp,sp,80
    800025c6:	8082                	ret

00000000800025c8 <swtch>:
    800025c8:	00153023          	sd	ra,0(a0)
    800025cc:	00253423          	sd	sp,8(a0)
    800025d0:	e900                	sd	s0,16(a0)
    800025d2:	ed04                	sd	s1,24(a0)
    800025d4:	03253023          	sd	s2,32(a0)
    800025d8:	03353423          	sd	s3,40(a0)
    800025dc:	03453823          	sd	s4,48(a0)
    800025e0:	03553c23          	sd	s5,56(a0)
    800025e4:	05653023          	sd	s6,64(a0)
    800025e8:	05753423          	sd	s7,72(a0)
    800025ec:	05853823          	sd	s8,80(a0)
    800025f0:	05953c23          	sd	s9,88(a0)
    800025f4:	07a53023          	sd	s10,96(a0)
    800025f8:	07b53423          	sd	s11,104(a0)
    800025fc:	0005b083          	ld	ra,0(a1)
    80002600:	0085b103          	ld	sp,8(a1)
    80002604:	6980                	ld	s0,16(a1)
    80002606:	6d84                	ld	s1,24(a1)
    80002608:	0205b903          	ld	s2,32(a1)
    8000260c:	0285b983          	ld	s3,40(a1)
    80002610:	0305ba03          	ld	s4,48(a1)
    80002614:	0385ba83          	ld	s5,56(a1)
    80002618:	0405bb03          	ld	s6,64(a1)
    8000261c:	0485bb83          	ld	s7,72(a1)
    80002620:	0505bc03          	ld	s8,80(a1)
    80002624:	0585bc83          	ld	s9,88(a1)
    80002628:	0605bd03          	ld	s10,96(a1)
    8000262c:	0685bd83          	ld	s11,104(a1)
    80002630:	8082                	ret

0000000080002632 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002632:	1141                	addi	sp,sp,-16
    80002634:	e406                	sd	ra,8(sp)
    80002636:	e022                	sd	s0,0(sp)
    80002638:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000263a:	00006597          	auipc	a1,0x6
    8000263e:	c1e58593          	addi	a1,a1,-994 # 80008258 <states.1702+0x28>
    80002642:	00015517          	auipc	a0,0x15
    80002646:	12650513          	addi	a0,a0,294 # 80017768 <tickslock>
    8000264a:	ffffe097          	auipc	ra,0xffffe
    8000264e:	536080e7          	jalr	1334(ra) # 80000b80 <initlock>
}
    80002652:	60a2                	ld	ra,8(sp)
    80002654:	6402                	ld	s0,0(sp)
    80002656:	0141                	addi	sp,sp,16
    80002658:	8082                	ret

000000008000265a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000265a:	1141                	addi	sp,sp,-16
    8000265c:	e422                	sd	s0,8(sp)
    8000265e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002660:	00003797          	auipc	a5,0x3
    80002664:	54078793          	addi	a5,a5,1344 # 80005ba0 <kernelvec>
    80002668:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000266c:	6422                	ld	s0,8(sp)
    8000266e:	0141                	addi	sp,sp,16
    80002670:	8082                	ret

0000000080002672 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002672:	1141                	addi	sp,sp,-16
    80002674:	e406                	sd	ra,8(sp)
    80002676:	e022                	sd	s0,0(sp)
    80002678:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000267a:	fffff097          	auipc	ra,0xfffff
    8000267e:	382080e7          	jalr	898(ra) # 800019fc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002682:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002686:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002688:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000268c:	00005617          	auipc	a2,0x5
    80002690:	97460613          	addi	a2,a2,-1676 # 80007000 <_trampoline>
    80002694:	00005697          	auipc	a3,0x5
    80002698:	96c68693          	addi	a3,a3,-1684 # 80007000 <_trampoline>
    8000269c:	8e91                	sub	a3,a3,a2
    8000269e:	040007b7          	lui	a5,0x4000
    800026a2:	17fd                	addi	a5,a5,-1
    800026a4:	07b2                	slli	a5,a5,0xc
    800026a6:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026a8:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026ac:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026ae:	180026f3          	csrr	a3,satp
    800026b2:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026b4:	6d38                	ld	a4,88(a0)
    800026b6:	6134                	ld	a3,64(a0)
    800026b8:	6585                	lui	a1,0x1
    800026ba:	96ae                	add	a3,a3,a1
    800026bc:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026be:	6d38                	ld	a4,88(a0)
    800026c0:	00000697          	auipc	a3,0x0
    800026c4:	13868693          	addi	a3,a3,312 # 800027f8 <usertrap>
    800026c8:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026ca:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026cc:	8692                	mv	a3,tp
    800026ce:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026d0:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026d4:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026d8:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026dc:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026e0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026e2:	6f18                	ld	a4,24(a4)
    800026e4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026e8:	692c                	ld	a1,80(a0)
    800026ea:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800026ec:	00005717          	auipc	a4,0x5
    800026f0:	9a470713          	addi	a4,a4,-1628 # 80007090 <userret>
    800026f4:	8f11                	sub	a4,a4,a2
    800026f6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800026f8:	577d                	li	a4,-1
    800026fa:	177e                	slli	a4,a4,0x3f
    800026fc:	8dd9                	or	a1,a1,a4
    800026fe:	02000537          	lui	a0,0x2000
    80002702:	157d                	addi	a0,a0,-1
    80002704:	0536                	slli	a0,a0,0xd
    80002706:	9782                	jalr	a5
}
    80002708:	60a2                	ld	ra,8(sp)
    8000270a:	6402                	ld	s0,0(sp)
    8000270c:	0141                	addi	sp,sp,16
    8000270e:	8082                	ret

0000000080002710 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002710:	1101                	addi	sp,sp,-32
    80002712:	ec06                	sd	ra,24(sp)
    80002714:	e822                	sd	s0,16(sp)
    80002716:	e426                	sd	s1,8(sp)
    80002718:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000271a:	00015497          	auipc	s1,0x15
    8000271e:	04e48493          	addi	s1,s1,78 # 80017768 <tickslock>
    80002722:	8526                	mv	a0,s1
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	4ec080e7          	jalr	1260(ra) # 80000c10 <acquire>
  ticks++;
    8000272c:	00007517          	auipc	a0,0x7
    80002730:	8f450513          	addi	a0,a0,-1804 # 80009020 <ticks>
    80002734:	411c                	lw	a5,0(a0)
    80002736:	2785                	addiw	a5,a5,1
    80002738:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000273a:	00000097          	auipc	ra,0x0
    8000273e:	c58080e7          	jalr	-936(ra) # 80002392 <wakeup>
  release(&tickslock);
    80002742:	8526                	mv	a0,s1
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	580080e7          	jalr	1408(ra) # 80000cc4 <release>
}
    8000274c:	60e2                	ld	ra,24(sp)
    8000274e:	6442                	ld	s0,16(sp)
    80002750:	64a2                	ld	s1,8(sp)
    80002752:	6105                	addi	sp,sp,32
    80002754:	8082                	ret

0000000080002756 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002756:	1101                	addi	sp,sp,-32
    80002758:	ec06                	sd	ra,24(sp)
    8000275a:	e822                	sd	s0,16(sp)
    8000275c:	e426                	sd	s1,8(sp)
    8000275e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002760:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002764:	00074d63          	bltz	a4,8000277e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002768:	57fd                	li	a5,-1
    8000276a:	17fe                	slli	a5,a5,0x3f
    8000276c:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000276e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002770:	06f70363          	beq	a4,a5,800027d6 <devintr+0x80>
  }
}
    80002774:	60e2                	ld	ra,24(sp)
    80002776:	6442                	ld	s0,16(sp)
    80002778:	64a2                	ld	s1,8(sp)
    8000277a:	6105                	addi	sp,sp,32
    8000277c:	8082                	ret
     (scause & 0xff) == 9){
    8000277e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002782:	46a5                	li	a3,9
    80002784:	fed792e3          	bne	a5,a3,80002768 <devintr+0x12>
    int irq = plic_claim();
    80002788:	00003097          	auipc	ra,0x3
    8000278c:	520080e7          	jalr	1312(ra) # 80005ca8 <plic_claim>
    80002790:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002792:	47a9                	li	a5,10
    80002794:	02f50763          	beq	a0,a5,800027c2 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002798:	4785                	li	a5,1
    8000279a:	02f50963          	beq	a0,a5,800027cc <devintr+0x76>
    return 1;
    8000279e:	4505                	li	a0,1
    } else if(irq){
    800027a0:	d8f1                	beqz	s1,80002774 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027a2:	85a6                	mv	a1,s1
    800027a4:	00006517          	auipc	a0,0x6
    800027a8:	abc50513          	addi	a0,a0,-1348 # 80008260 <states.1702+0x30>
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	de6080e7          	jalr	-538(ra) # 80000592 <printf>
      plic_complete(irq);
    800027b4:	8526                	mv	a0,s1
    800027b6:	00003097          	auipc	ra,0x3
    800027ba:	516080e7          	jalr	1302(ra) # 80005ccc <plic_complete>
    return 1;
    800027be:	4505                	li	a0,1
    800027c0:	bf55                	j	80002774 <devintr+0x1e>
      uartintr();
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	212080e7          	jalr	530(ra) # 800009d4 <uartintr>
    800027ca:	b7ed                	j	800027b4 <devintr+0x5e>
      virtio_disk_intr();
    800027cc:	00004097          	auipc	ra,0x4
    800027d0:	99a080e7          	jalr	-1638(ra) # 80006166 <virtio_disk_intr>
    800027d4:	b7c5                	j	800027b4 <devintr+0x5e>
    if(cpuid() == 0){
    800027d6:	fffff097          	auipc	ra,0xfffff
    800027da:	1fa080e7          	jalr	506(ra) # 800019d0 <cpuid>
    800027de:	c901                	beqz	a0,800027ee <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027e0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027e4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027e6:	14479073          	csrw	sip,a5
    return 2;
    800027ea:	4509                	li	a0,2
    800027ec:	b761                	j	80002774 <devintr+0x1e>
      clockintr();
    800027ee:	00000097          	auipc	ra,0x0
    800027f2:	f22080e7          	jalr	-222(ra) # 80002710 <clockintr>
    800027f6:	b7ed                	j	800027e0 <devintr+0x8a>

00000000800027f8 <usertrap>:
{
    800027f8:	7179                	addi	sp,sp,-48
    800027fa:	f406                	sd	ra,40(sp)
    800027fc:	f022                	sd	s0,32(sp)
    800027fe:	ec26                	sd	s1,24(sp)
    80002800:	e84a                	sd	s2,16(sp)
    80002802:	e44e                	sd	s3,8(sp)
    80002804:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002806:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000280a:	1007f793          	andi	a5,a5,256
    8000280e:	e3b1                	bnez	a5,80002852 <usertrap+0x5a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002810:	00003797          	auipc	a5,0x3
    80002814:	39078793          	addi	a5,a5,912 # 80005ba0 <kernelvec>
    80002818:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000281c:	fffff097          	auipc	ra,0xfffff
    80002820:	1e0080e7          	jalr	480(ra) # 800019fc <myproc>
    80002824:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002826:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002828:	14102773          	csrr	a4,sepc
    8000282c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000282e:	142027f3          	csrr	a5,scause
  if(scause == 8){
    80002832:	4721                	li	a4,8
    80002834:	02e78763          	beq	a5,a4,80002862 <usertrap+0x6a>
  } else if(scause==13 || scause==15) { 
    80002838:	9bf5                	andi	a5,a5,-3
    8000283a:	4735                	li	a4,13
    8000283c:	06e78663          	beq	a5,a4,800028a8 <usertrap+0xb0>
  } else if((which_dev = devintr()) != 0){
    80002840:	00000097          	auipc	ra,0x0
    80002844:	f16080e7          	jalr	-234(ra) # 80002756 <devintr>
    80002848:	892a                	mv	s2,a0
    8000284a:	c571                	beqz	a0,80002916 <usertrap+0x11e>
  if(p->killed)
    8000284c:	589c                	lw	a5,48(s1)
    8000284e:	cfb5                	beqz	a5,800028ca <usertrap+0xd2>
    80002850:	a885                	j	800028c0 <usertrap+0xc8>
    panic("usertrap: not from user mode");
    80002852:	00006517          	auipc	a0,0x6
    80002856:	a2e50513          	addi	a0,a0,-1490 # 80008280 <states.1702+0x50>
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	cee080e7          	jalr	-786(ra) # 80000548 <panic>
    if(p->killed)
    80002862:	591c                	lw	a5,48(a0)
    80002864:	ef85                	bnez	a5,8000289c <usertrap+0xa4>
    p->trapframe->epc += 4;
    80002866:	6cb8                	ld	a4,88(s1)
    80002868:	6f1c                	ld	a5,24(a4)
    8000286a:	0791                	addi	a5,a5,4
    8000286c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000286e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002872:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002876:	10079073          	csrw	sstatus,a5
    syscall();
    8000287a:	00000097          	auipc	ra,0x0
    8000287e:	316080e7          	jalr	790(ra) # 80002b90 <syscall>
  if(p->killed)
    80002882:	589c                	lw	a5,48(s1)
    80002884:	e3f9                	bnez	a5,8000294a <usertrap+0x152>
  usertrapret();
    80002886:	00000097          	auipc	ra,0x0
    8000288a:	dec080e7          	jalr	-532(ra) # 80002672 <usertrapret>
}
    8000288e:	70a2                	ld	ra,40(sp)
    80002890:	7402                	ld	s0,32(sp)
    80002892:	64e2                	ld	s1,24(sp)
    80002894:	6942                	ld	s2,16(sp)
    80002896:	69a2                	ld	s3,8(sp)
    80002898:	6145                	addi	sp,sp,48
    8000289a:	8082                	ret
      exit(-1);
    8000289c:	557d                	li	a0,-1
    8000289e:	00000097          	auipc	ra,0x0
    800028a2:	828080e7          	jalr	-2008(ra) # 800020c6 <exit>
    800028a6:	b7c1                	j	80002866 <usertrap+0x6e>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028a8:	14302973          	csrr	s2,stval
    if(va>=p->sz || va<=p->trapframe->sp)
    800028ac:	653c                	ld	a5,72(a0)
    800028ae:	00f97663          	bgeu	s2,a5,800028ba <usertrap+0xc2>
    800028b2:	6d3c                	ld	a5,88(a0)
    800028b4:	7b9c                	ld	a5,48(a5)
    800028b6:	0327e263          	bltu	a5,s2,800028da <usertrap+0xe2>
    p->killed = 1;
    800028ba:	4785                	li	a5,1
    800028bc:	d89c                	sw	a5,48(s1)
{
    800028be:	4901                	li	s2,0
    exit(-1);
    800028c0:	557d                	li	a0,-1
    800028c2:	00000097          	auipc	ra,0x0
    800028c6:	804080e7          	jalr	-2044(ra) # 800020c6 <exit>
  if(which_dev == 2)
    800028ca:	4789                	li	a5,2
    800028cc:	faf91de3          	bne	s2,a5,80002886 <usertrap+0x8e>
    yield();
    800028d0:	00000097          	auipc	ra,0x0
    800028d4:	900080e7          	jalr	-1792(ra) # 800021d0 <yield>
    800028d8:	b77d                	j	80002886 <usertrap+0x8e>
    char* mem = kalloc();
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	246080e7          	jalr	582(ra) # 80000b20 <kalloc>
    800028e2:	89aa                	mv	s3,a0
    if(mem == 0)
    800028e4:	d979                	beqz	a0,800028ba <usertrap+0xc2>
    memset(mem, 0, PGSIZE);
    800028e6:	6605                	lui	a2,0x1
    800028e8:	4581                	li	a1,0
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	422080e7          	jalr	1058(ra) # 80000d0c <memset>
    if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0) 
    800028f2:	4779                	li	a4,30
    800028f4:	86ce                	mv	a3,s3
    800028f6:	6605                	lui	a2,0x1
    800028f8:	75fd                	lui	a1,0xfffff
    800028fa:	00b975b3          	and	a1,s2,a1
    800028fe:	68a8                	ld	a0,80(s1)
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	7fc080e7          	jalr	2044(ra) # 800010fc <mappages>
    80002908:	dd2d                	beqz	a0,80002882 <usertrap+0x8a>
    kfree(mem);
    8000290a:	854e                	mv	a0,s3
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	118080e7          	jalr	280(ra) # 80000a24 <kfree>
    80002914:	b75d                	j	800028ba <usertrap+0xc2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002916:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000291a:	5c90                	lw	a2,56(s1)
    8000291c:	00006517          	auipc	a0,0x6
    80002920:	98450513          	addi	a0,a0,-1660 # 800082a0 <states.1702+0x70>
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	c6e080e7          	jalr	-914(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000292c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002930:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002934:	00006517          	auipc	a0,0x6
    80002938:	99c50513          	addi	a0,a0,-1636 # 800082d0 <states.1702+0xa0>
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	c56080e7          	jalr	-938(ra) # 80000592 <printf>
    p->killed = 1;
    80002944:	4785                	li	a5,1
    80002946:	d89c                	sw	a5,48(s1)
    80002948:	bf9d                	j	800028be <usertrap+0xc6>
  if(p->killed)
    8000294a:	4901                	li	s2,0
    8000294c:	bf95                	j	800028c0 <usertrap+0xc8>

000000008000294e <kerneltrap>:
{
    8000294e:	7179                	addi	sp,sp,-48
    80002950:	f406                	sd	ra,40(sp)
    80002952:	f022                	sd	s0,32(sp)
    80002954:	ec26                	sd	s1,24(sp)
    80002956:	e84a                	sd	s2,16(sp)
    80002958:	e44e                	sd	s3,8(sp)
    8000295a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000295c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002960:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002964:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002968:	1004f793          	andi	a5,s1,256
    8000296c:	cb85                	beqz	a5,8000299c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002972:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002974:	ef85                	bnez	a5,800029ac <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002976:	00000097          	auipc	ra,0x0
    8000297a:	de0080e7          	jalr	-544(ra) # 80002756 <devintr>
    8000297e:	cd1d                	beqz	a0,800029bc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002980:	4789                	li	a5,2
    80002982:	06f50a63          	beq	a0,a5,800029f6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002986:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000298a:	10049073          	csrw	sstatus,s1
}
    8000298e:	70a2                	ld	ra,40(sp)
    80002990:	7402                	ld	s0,32(sp)
    80002992:	64e2                	ld	s1,24(sp)
    80002994:	6942                	ld	s2,16(sp)
    80002996:	69a2                	ld	s3,8(sp)
    80002998:	6145                	addi	sp,sp,48
    8000299a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000299c:	00006517          	auipc	a0,0x6
    800029a0:	95450513          	addi	a0,a0,-1708 # 800082f0 <states.1702+0xc0>
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	ba4080e7          	jalr	-1116(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    800029ac:	00006517          	auipc	a0,0x6
    800029b0:	96c50513          	addi	a0,a0,-1684 # 80008318 <states.1702+0xe8>
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	b94080e7          	jalr	-1132(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    800029bc:	85ce                	mv	a1,s3
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	97a50513          	addi	a0,a0,-1670 # 80008338 <states.1702+0x108>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	bcc080e7          	jalr	-1076(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029d2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029d6:	00006517          	auipc	a0,0x6
    800029da:	97250513          	addi	a0,a0,-1678 # 80008348 <states.1702+0x118>
    800029de:	ffffe097          	auipc	ra,0xffffe
    800029e2:	bb4080e7          	jalr	-1100(ra) # 80000592 <printf>
    panic("kerneltrap");
    800029e6:	00006517          	auipc	a0,0x6
    800029ea:	97a50513          	addi	a0,a0,-1670 # 80008360 <states.1702+0x130>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	b5a080e7          	jalr	-1190(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029f6:	fffff097          	auipc	ra,0xfffff
    800029fa:	006080e7          	jalr	6(ra) # 800019fc <myproc>
    800029fe:	d541                	beqz	a0,80002986 <kerneltrap+0x38>
    80002a00:	fffff097          	auipc	ra,0xfffff
    80002a04:	ffc080e7          	jalr	-4(ra) # 800019fc <myproc>
    80002a08:	4d18                	lw	a4,24(a0)
    80002a0a:	478d                	li	a5,3
    80002a0c:	f6f71de3          	bne	a4,a5,80002986 <kerneltrap+0x38>
    yield();
    80002a10:	fffff097          	auipc	ra,0xfffff
    80002a14:	7c0080e7          	jalr	1984(ra) # 800021d0 <yield>
    80002a18:	b7bd                	j	80002986 <kerneltrap+0x38>

0000000080002a1a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a1a:	1101                	addi	sp,sp,-32
    80002a1c:	ec06                	sd	ra,24(sp)
    80002a1e:	e822                	sd	s0,16(sp)
    80002a20:	e426                	sd	s1,8(sp)
    80002a22:	1000                	addi	s0,sp,32
    80002a24:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	fd6080e7          	jalr	-42(ra) # 800019fc <myproc>
  switch (n) {
    80002a2e:	4795                	li	a5,5
    80002a30:	0497e163          	bltu	a5,s1,80002a72 <argraw+0x58>
    80002a34:	048a                	slli	s1,s1,0x2
    80002a36:	00006717          	auipc	a4,0x6
    80002a3a:	96270713          	addi	a4,a4,-1694 # 80008398 <states.1702+0x168>
    80002a3e:	94ba                	add	s1,s1,a4
    80002a40:	409c                	lw	a5,0(s1)
    80002a42:	97ba                	add	a5,a5,a4
    80002a44:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a46:	6d3c                	ld	a5,88(a0)
    80002a48:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a4a:	60e2                	ld	ra,24(sp)
    80002a4c:	6442                	ld	s0,16(sp)
    80002a4e:	64a2                	ld	s1,8(sp)
    80002a50:	6105                	addi	sp,sp,32
    80002a52:	8082                	ret
    return p->trapframe->a1;
    80002a54:	6d3c                	ld	a5,88(a0)
    80002a56:	7fa8                	ld	a0,120(a5)
    80002a58:	bfcd                	j	80002a4a <argraw+0x30>
    return p->trapframe->a2;
    80002a5a:	6d3c                	ld	a5,88(a0)
    80002a5c:	63c8                	ld	a0,128(a5)
    80002a5e:	b7f5                	j	80002a4a <argraw+0x30>
    return p->trapframe->a3;
    80002a60:	6d3c                	ld	a5,88(a0)
    80002a62:	67c8                	ld	a0,136(a5)
    80002a64:	b7dd                	j	80002a4a <argraw+0x30>
    return p->trapframe->a4;
    80002a66:	6d3c                	ld	a5,88(a0)
    80002a68:	6bc8                	ld	a0,144(a5)
    80002a6a:	b7c5                	j	80002a4a <argraw+0x30>
    return p->trapframe->a5;
    80002a6c:	6d3c                	ld	a5,88(a0)
    80002a6e:	6fc8                	ld	a0,152(a5)
    80002a70:	bfe9                	j	80002a4a <argraw+0x30>
  panic("argraw");
    80002a72:	00006517          	auipc	a0,0x6
    80002a76:	8fe50513          	addi	a0,a0,-1794 # 80008370 <states.1702+0x140>
    80002a7a:	ffffe097          	auipc	ra,0xffffe
    80002a7e:	ace080e7          	jalr	-1330(ra) # 80000548 <panic>

0000000080002a82 <fetchaddr>:
{
    80002a82:	1101                	addi	sp,sp,-32
    80002a84:	ec06                	sd	ra,24(sp)
    80002a86:	e822                	sd	s0,16(sp)
    80002a88:	e426                	sd	s1,8(sp)
    80002a8a:	e04a                	sd	s2,0(sp)
    80002a8c:	1000                	addi	s0,sp,32
    80002a8e:	84aa                	mv	s1,a0
    80002a90:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	f6a080e7          	jalr	-150(ra) # 800019fc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a9a:	653c                	ld	a5,72(a0)
    80002a9c:	02f4f863          	bgeu	s1,a5,80002acc <fetchaddr+0x4a>
    80002aa0:	00848713          	addi	a4,s1,8
    80002aa4:	02e7e663          	bltu	a5,a4,80002ad0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002aa8:	46a1                	li	a3,8
    80002aaa:	8626                	mv	a2,s1
    80002aac:	85ca                	mv	a1,s2
    80002aae:	6928                	ld	a0,80(a0)
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	ccc080e7          	jalr	-820(ra) # 8000177c <copyin>
    80002ab8:	00a03533          	snez	a0,a0
    80002abc:	40a00533          	neg	a0,a0
}
    80002ac0:	60e2                	ld	ra,24(sp)
    80002ac2:	6442                	ld	s0,16(sp)
    80002ac4:	64a2                	ld	s1,8(sp)
    80002ac6:	6902                	ld	s2,0(sp)
    80002ac8:	6105                	addi	sp,sp,32
    80002aca:	8082                	ret
    return -1;
    80002acc:	557d                	li	a0,-1
    80002ace:	bfcd                	j	80002ac0 <fetchaddr+0x3e>
    80002ad0:	557d                	li	a0,-1
    80002ad2:	b7fd                	j	80002ac0 <fetchaddr+0x3e>

0000000080002ad4 <fetchstr>:
{
    80002ad4:	7179                	addi	sp,sp,-48
    80002ad6:	f406                	sd	ra,40(sp)
    80002ad8:	f022                	sd	s0,32(sp)
    80002ada:	ec26                	sd	s1,24(sp)
    80002adc:	e84a                	sd	s2,16(sp)
    80002ade:	e44e                	sd	s3,8(sp)
    80002ae0:	1800                	addi	s0,sp,48
    80002ae2:	892a                	mv	s2,a0
    80002ae4:	84ae                	mv	s1,a1
    80002ae6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ae8:	fffff097          	auipc	ra,0xfffff
    80002aec:	f14080e7          	jalr	-236(ra) # 800019fc <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002af0:	86ce                	mv	a3,s3
    80002af2:	864a                	mv	a2,s2
    80002af4:	85a6                	mv	a1,s1
    80002af6:	6928                	ld	a0,80(a0)
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	d10080e7          	jalr	-752(ra) # 80001808 <copyinstr>
  if(err < 0)
    80002b00:	00054763          	bltz	a0,80002b0e <fetchstr+0x3a>
  return strlen(buf);
    80002b04:	8526                	mv	a0,s1
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	38e080e7          	jalr	910(ra) # 80000e94 <strlen>
}
    80002b0e:	70a2                	ld	ra,40(sp)
    80002b10:	7402                	ld	s0,32(sp)
    80002b12:	64e2                	ld	s1,24(sp)
    80002b14:	6942                	ld	s2,16(sp)
    80002b16:	69a2                	ld	s3,8(sp)
    80002b18:	6145                	addi	sp,sp,48
    80002b1a:	8082                	ret

0000000080002b1c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b1c:	1101                	addi	sp,sp,-32
    80002b1e:	ec06                	sd	ra,24(sp)
    80002b20:	e822                	sd	s0,16(sp)
    80002b22:	e426                	sd	s1,8(sp)
    80002b24:	1000                	addi	s0,sp,32
    80002b26:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b28:	00000097          	auipc	ra,0x0
    80002b2c:	ef2080e7          	jalr	-270(ra) # 80002a1a <argraw>
    80002b30:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b32:	4501                	li	a0,0
    80002b34:	60e2                	ld	ra,24(sp)
    80002b36:	6442                	ld	s0,16(sp)
    80002b38:	64a2                	ld	s1,8(sp)
    80002b3a:	6105                	addi	sp,sp,32
    80002b3c:	8082                	ret

0000000080002b3e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b3e:	1101                	addi	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	e426                	sd	s1,8(sp)
    80002b46:	1000                	addi	s0,sp,32
    80002b48:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b4a:	00000097          	auipc	ra,0x0
    80002b4e:	ed0080e7          	jalr	-304(ra) # 80002a1a <argraw>
    80002b52:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b54:	4501                	li	a0,0
    80002b56:	60e2                	ld	ra,24(sp)
    80002b58:	6442                	ld	s0,16(sp)
    80002b5a:	64a2                	ld	s1,8(sp)
    80002b5c:	6105                	addi	sp,sp,32
    80002b5e:	8082                	ret

0000000080002b60 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b60:	1101                	addi	sp,sp,-32
    80002b62:	ec06                	sd	ra,24(sp)
    80002b64:	e822                	sd	s0,16(sp)
    80002b66:	e426                	sd	s1,8(sp)
    80002b68:	e04a                	sd	s2,0(sp)
    80002b6a:	1000                	addi	s0,sp,32
    80002b6c:	84ae                	mv	s1,a1
    80002b6e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b70:	00000097          	auipc	ra,0x0
    80002b74:	eaa080e7          	jalr	-342(ra) # 80002a1a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b78:	864a                	mv	a2,s2
    80002b7a:	85a6                	mv	a1,s1
    80002b7c:	00000097          	auipc	ra,0x0
    80002b80:	f58080e7          	jalr	-168(ra) # 80002ad4 <fetchstr>
}
    80002b84:	60e2                	ld	ra,24(sp)
    80002b86:	6442                	ld	s0,16(sp)
    80002b88:	64a2                	ld	s1,8(sp)
    80002b8a:	6902                	ld	s2,0(sp)
    80002b8c:	6105                	addi	sp,sp,32
    80002b8e:	8082                	ret

0000000080002b90 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002b90:	1101                	addi	sp,sp,-32
    80002b92:	ec06                	sd	ra,24(sp)
    80002b94:	e822                	sd	s0,16(sp)
    80002b96:	e426                	sd	s1,8(sp)
    80002b98:	e04a                	sd	s2,0(sp)
    80002b9a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b9c:	fffff097          	auipc	ra,0xfffff
    80002ba0:	e60080e7          	jalr	-416(ra) # 800019fc <myproc>
    80002ba4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ba6:	05853903          	ld	s2,88(a0)
    80002baa:	0a893783          	ld	a5,168(s2)
    80002bae:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bb2:	37fd                	addiw	a5,a5,-1
    80002bb4:	4751                	li	a4,20
    80002bb6:	00f76f63          	bltu	a4,a5,80002bd4 <syscall+0x44>
    80002bba:	00369713          	slli	a4,a3,0x3
    80002bbe:	00005797          	auipc	a5,0x5
    80002bc2:	7f278793          	addi	a5,a5,2034 # 800083b0 <syscalls>
    80002bc6:	97ba                	add	a5,a5,a4
    80002bc8:	639c                	ld	a5,0(a5)
    80002bca:	c789                	beqz	a5,80002bd4 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002bcc:	9782                	jalr	a5
    80002bce:	06a93823          	sd	a0,112(s2)
    80002bd2:	a839                	j	80002bf0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bd4:	15848613          	addi	a2,s1,344
    80002bd8:	5c8c                	lw	a1,56(s1)
    80002bda:	00005517          	auipc	a0,0x5
    80002bde:	79e50513          	addi	a0,a0,1950 # 80008378 <states.1702+0x148>
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	9b0080e7          	jalr	-1616(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bea:	6cbc                	ld	a5,88(s1)
    80002bec:	577d                	li	a4,-1
    80002bee:	fbb8                	sd	a4,112(a5)
  }
}
    80002bf0:	60e2                	ld	ra,24(sp)
    80002bf2:	6442                	ld	s0,16(sp)
    80002bf4:	64a2                	ld	s1,8(sp)
    80002bf6:	6902                	ld	s2,0(sp)
    80002bf8:	6105                	addi	sp,sp,32
    80002bfa:	8082                	ret

0000000080002bfc <sys_exit>:
#include "spinlock.h"
#include "proc.h"
                   
uint64
sys_exit(void)
{
    80002bfc:	1101                	addi	sp,sp,-32
    80002bfe:	ec06                	sd	ra,24(sp)
    80002c00:	e822                	sd	s0,16(sp)
    80002c02:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c04:	fec40593          	addi	a1,s0,-20
    80002c08:	4501                	li	a0,0
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	f12080e7          	jalr	-238(ra) # 80002b1c <argint>
    return -1;
    80002c12:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c14:	00054963          	bltz	a0,80002c26 <sys_exit+0x2a>
  exit(n);
    80002c18:	fec42503          	lw	a0,-20(s0)
    80002c1c:	fffff097          	auipc	ra,0xfffff
    80002c20:	4aa080e7          	jalr	1194(ra) # 800020c6 <exit>
  return 0;  // not reached
    80002c24:	4781                	li	a5,0
}
    80002c26:	853e                	mv	a0,a5
    80002c28:	60e2                	ld	ra,24(sp)
    80002c2a:	6442                	ld	s0,16(sp)
    80002c2c:	6105                	addi	sp,sp,32
    80002c2e:	8082                	ret

0000000080002c30 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c30:	1141                	addi	sp,sp,-16
    80002c32:	e406                	sd	ra,8(sp)
    80002c34:	e022                	sd	s0,0(sp)
    80002c36:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c38:	fffff097          	auipc	ra,0xfffff
    80002c3c:	dc4080e7          	jalr	-572(ra) # 800019fc <myproc>
}
    80002c40:	5d08                	lw	a0,56(a0)
    80002c42:	60a2                	ld	ra,8(sp)
    80002c44:	6402                	ld	s0,0(sp)
    80002c46:	0141                	addi	sp,sp,16
    80002c48:	8082                	ret

0000000080002c4a <sys_fork>:

uint64
sys_fork(void)
{
    80002c4a:	1141                	addi	sp,sp,-16
    80002c4c:	e406                	sd	ra,8(sp)
    80002c4e:	e022                	sd	s0,0(sp)
    80002c50:	0800                	addi	s0,sp,16
  return fork();
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	16a080e7          	jalr	362(ra) # 80001dbc <fork>
}
    80002c5a:	60a2                	ld	ra,8(sp)
    80002c5c:	6402                	ld	s0,0(sp)
    80002c5e:	0141                	addi	sp,sp,16
    80002c60:	8082                	ret

0000000080002c62 <sys_wait>:

uint64
sys_wait(void)
{
    80002c62:	1101                	addi	sp,sp,-32
    80002c64:	ec06                	sd	ra,24(sp)
    80002c66:	e822                	sd	s0,16(sp)
    80002c68:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c6a:	fe840593          	addi	a1,s0,-24
    80002c6e:	4501                	li	a0,0
    80002c70:	00000097          	auipc	ra,0x0
    80002c74:	ece080e7          	jalr	-306(ra) # 80002b3e <argaddr>
    80002c78:	87aa                	mv	a5,a0
    return -1;
    80002c7a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c7c:	0007c863          	bltz	a5,80002c8c <sys_wait+0x2a>
  return wait(p);
    80002c80:	fe843503          	ld	a0,-24(s0)
    80002c84:	fffff097          	auipc	ra,0xfffff
    80002c88:	606080e7          	jalr	1542(ra) # 8000228a <wait>
}
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret

0000000080002c94 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c94:	7179                	addi	sp,sp,-48
    80002c96:	f406                	sd	ra,40(sp)
    80002c98:	f022                	sd	s0,32(sp)
    80002c9a:	ec26                	sd	s1,24(sp)
    80002c9c:	1800                	addi	s0,sp,48
  int addr;
  int n;
  struct proc* p;

  if(argint(0, &n) < 0)
    80002c9e:	fdc40593          	addi	a1,s0,-36
    80002ca2:	4501                	li	a0,0
    80002ca4:	00000097          	auipc	ra,0x0
    80002ca8:	e78080e7          	jalr	-392(ra) # 80002b1c <argint>
    return -1;
    80002cac:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002cae:	02054363          	bltz	a0,80002cd4 <sys_sbrk+0x40>

  p = myproc();
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	d4a080e7          	jalr	-694(ra) # 800019fc <myproc>
  addr = p->sz;
    80002cba:	6530                	ld	a2,72(a0)
    80002cbc:	0006049b          	sext.w	s1,a2

  /** sbrk越界处理 */
  if(addr+n>=TRAPFRAME || addr+n<=0)
    80002cc0:	fdc42783          	lw	a5,-36(s0)
    80002cc4:	00c7873b          	addw	a4,a5,a2
    80002cc8:	00e05663          	blez	a4,80002cd4 <sys_sbrk+0x40>
    return addr;

  p->sz += n;
    80002ccc:	963e                	add	a2,a2,a5
    80002cce:	e530                	sd	a2,72(a0)

  /** 堆空间负增长 */
  if(n < 0)
    80002cd0:	0007c863          	bltz	a5,80002ce0 <sys_sbrk+0x4c>
    uvmdealloc(p->pagetable, addr, p->sz);
  
  return addr;
}
    80002cd4:	8526                	mv	a0,s1
    80002cd6:	70a2                	ld	ra,40(sp)
    80002cd8:	7402                	ld	s0,32(sp)
    80002cda:	64e2                	ld	s1,24(sp)
    80002cdc:	6145                	addi	sp,sp,48
    80002cde:	8082                	ret
    uvmdealloc(p->pagetable, addr, p->sz);
    80002ce0:	85a6                	mv	a1,s1
    80002ce2:	6928                	ld	a0,80(a0)
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	7a2080e7          	jalr	1954(ra) # 80001486 <uvmdealloc>
  return addr;
    80002cec:	b7e5                	j	80002cd4 <sys_sbrk+0x40>

0000000080002cee <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cee:	7139                	addi	sp,sp,-64
    80002cf0:	fc06                	sd	ra,56(sp)
    80002cf2:	f822                	sd	s0,48(sp)
    80002cf4:	f426                	sd	s1,40(sp)
    80002cf6:	f04a                	sd	s2,32(sp)
    80002cf8:	ec4e                	sd	s3,24(sp)
    80002cfa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002cfc:	fcc40593          	addi	a1,s0,-52
    80002d00:	4501                	li	a0,0
    80002d02:	00000097          	auipc	ra,0x0
    80002d06:	e1a080e7          	jalr	-486(ra) # 80002b1c <argint>
    return -1;
    80002d0a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d0c:	06054563          	bltz	a0,80002d76 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d10:	00015517          	auipc	a0,0x15
    80002d14:	a5850513          	addi	a0,a0,-1448 # 80017768 <tickslock>
    80002d18:	ffffe097          	auipc	ra,0xffffe
    80002d1c:	ef8080e7          	jalr	-264(ra) # 80000c10 <acquire>
  ticks0 = ticks;
    80002d20:	00006917          	auipc	s2,0x6
    80002d24:	30092903          	lw	s2,768(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002d28:	fcc42783          	lw	a5,-52(s0)
    80002d2c:	cf85                	beqz	a5,80002d64 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d2e:	00015997          	auipc	s3,0x15
    80002d32:	a3a98993          	addi	s3,s3,-1478 # 80017768 <tickslock>
    80002d36:	00006497          	auipc	s1,0x6
    80002d3a:	2ea48493          	addi	s1,s1,746 # 80009020 <ticks>
    if(myproc()->killed){
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	cbe080e7          	jalr	-834(ra) # 800019fc <myproc>
    80002d46:	591c                	lw	a5,48(a0)
    80002d48:	ef9d                	bnez	a5,80002d86 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d4a:	85ce                	mv	a1,s3
    80002d4c:	8526                	mv	a0,s1
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	4be080e7          	jalr	1214(ra) # 8000220c <sleep>
  while(ticks - ticks0 < n){
    80002d56:	409c                	lw	a5,0(s1)
    80002d58:	412787bb          	subw	a5,a5,s2
    80002d5c:	fcc42703          	lw	a4,-52(s0)
    80002d60:	fce7efe3          	bltu	a5,a4,80002d3e <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d64:	00015517          	auipc	a0,0x15
    80002d68:	a0450513          	addi	a0,a0,-1532 # 80017768 <tickslock>
    80002d6c:	ffffe097          	auipc	ra,0xffffe
    80002d70:	f58080e7          	jalr	-168(ra) # 80000cc4 <release>
  return 0;
    80002d74:	4781                	li	a5,0
}
    80002d76:	853e                	mv	a0,a5
    80002d78:	70e2                	ld	ra,56(sp)
    80002d7a:	7442                	ld	s0,48(sp)
    80002d7c:	74a2                	ld	s1,40(sp)
    80002d7e:	7902                	ld	s2,32(sp)
    80002d80:	69e2                	ld	s3,24(sp)
    80002d82:	6121                	addi	sp,sp,64
    80002d84:	8082                	ret
      release(&tickslock);
    80002d86:	00015517          	auipc	a0,0x15
    80002d8a:	9e250513          	addi	a0,a0,-1566 # 80017768 <tickslock>
    80002d8e:	ffffe097          	auipc	ra,0xffffe
    80002d92:	f36080e7          	jalr	-202(ra) # 80000cc4 <release>
      return -1;
    80002d96:	57fd                	li	a5,-1
    80002d98:	bff9                	j	80002d76 <sys_sleep+0x88>

0000000080002d9a <sys_kill>:

uint64
sys_kill(void)
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002da2:	fec40593          	addi	a1,s0,-20
    80002da6:	4501                	li	a0,0
    80002da8:	00000097          	auipc	ra,0x0
    80002dac:	d74080e7          	jalr	-652(ra) # 80002b1c <argint>
    80002db0:	87aa                	mv	a5,a0
    return -1;
    80002db2:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002db4:	0007c863          	bltz	a5,80002dc4 <sys_kill+0x2a>
  return kill(pid);
    80002db8:	fec42503          	lw	a0,-20(s0)
    80002dbc:	fffff097          	auipc	ra,0xfffff
    80002dc0:	640080e7          	jalr	1600(ra) # 800023fc <kill>
}
    80002dc4:	60e2                	ld	ra,24(sp)
    80002dc6:	6442                	ld	s0,16(sp)
    80002dc8:	6105                	addi	sp,sp,32
    80002dca:	8082                	ret

0000000080002dcc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dcc:	1101                	addi	sp,sp,-32
    80002dce:	ec06                	sd	ra,24(sp)
    80002dd0:	e822                	sd	s0,16(sp)
    80002dd2:	e426                	sd	s1,8(sp)
    80002dd4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dd6:	00015517          	auipc	a0,0x15
    80002dda:	99250513          	addi	a0,a0,-1646 # 80017768 <tickslock>
    80002dde:	ffffe097          	auipc	ra,0xffffe
    80002de2:	e32080e7          	jalr	-462(ra) # 80000c10 <acquire>
  xticks = ticks;
    80002de6:	00006497          	auipc	s1,0x6
    80002dea:	23a4a483          	lw	s1,570(s1) # 80009020 <ticks>
  release(&tickslock);
    80002dee:	00015517          	auipc	a0,0x15
    80002df2:	97a50513          	addi	a0,a0,-1670 # 80017768 <tickslock>
    80002df6:	ffffe097          	auipc	ra,0xffffe
    80002dfa:	ece080e7          	jalr	-306(ra) # 80000cc4 <release>
  return xticks;
}
    80002dfe:	02049513          	slli	a0,s1,0x20
    80002e02:	9101                	srli	a0,a0,0x20
    80002e04:	60e2                	ld	ra,24(sp)
    80002e06:	6442                	ld	s0,16(sp)
    80002e08:	64a2                	ld	s1,8(sp)
    80002e0a:	6105                	addi	sp,sp,32
    80002e0c:	8082                	ret

0000000080002e0e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e0e:	7179                	addi	sp,sp,-48
    80002e10:	f406                	sd	ra,40(sp)
    80002e12:	f022                	sd	s0,32(sp)
    80002e14:	ec26                	sd	s1,24(sp)
    80002e16:	e84a                	sd	s2,16(sp)
    80002e18:	e44e                	sd	s3,8(sp)
    80002e1a:	e052                	sd	s4,0(sp)
    80002e1c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e1e:	00005597          	auipc	a1,0x5
    80002e22:	64258593          	addi	a1,a1,1602 # 80008460 <syscalls+0xb0>
    80002e26:	00015517          	auipc	a0,0x15
    80002e2a:	95a50513          	addi	a0,a0,-1702 # 80017780 <bcache>
    80002e2e:	ffffe097          	auipc	ra,0xffffe
    80002e32:	d52080e7          	jalr	-686(ra) # 80000b80 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e36:	0001d797          	auipc	a5,0x1d
    80002e3a:	94a78793          	addi	a5,a5,-1718 # 8001f780 <bcache+0x8000>
    80002e3e:	0001d717          	auipc	a4,0x1d
    80002e42:	baa70713          	addi	a4,a4,-1110 # 8001f9e8 <bcache+0x8268>
    80002e46:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e4a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e4e:	00015497          	auipc	s1,0x15
    80002e52:	94a48493          	addi	s1,s1,-1718 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002e56:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e58:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e5a:	00005a17          	auipc	s4,0x5
    80002e5e:	60ea0a13          	addi	s4,s4,1550 # 80008468 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002e62:	2b893783          	ld	a5,696(s2)
    80002e66:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e68:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e6c:	85d2                	mv	a1,s4
    80002e6e:	01048513          	addi	a0,s1,16
    80002e72:	00001097          	auipc	ra,0x1
    80002e76:	4b0080e7          	jalr	1200(ra) # 80004322 <initsleeplock>
    bcache.head.next->prev = b;
    80002e7a:	2b893783          	ld	a5,696(s2)
    80002e7e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e80:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e84:	45848493          	addi	s1,s1,1112
    80002e88:	fd349de3          	bne	s1,s3,80002e62 <binit+0x54>
  }
}
    80002e8c:	70a2                	ld	ra,40(sp)
    80002e8e:	7402                	ld	s0,32(sp)
    80002e90:	64e2                	ld	s1,24(sp)
    80002e92:	6942                	ld	s2,16(sp)
    80002e94:	69a2                	ld	s3,8(sp)
    80002e96:	6a02                	ld	s4,0(sp)
    80002e98:	6145                	addi	sp,sp,48
    80002e9a:	8082                	ret

0000000080002e9c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e9c:	7179                	addi	sp,sp,-48
    80002e9e:	f406                	sd	ra,40(sp)
    80002ea0:	f022                	sd	s0,32(sp)
    80002ea2:	ec26                	sd	s1,24(sp)
    80002ea4:	e84a                	sd	s2,16(sp)
    80002ea6:	e44e                	sd	s3,8(sp)
    80002ea8:	1800                	addi	s0,sp,48
    80002eaa:	89aa                	mv	s3,a0
    80002eac:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002eae:	00015517          	auipc	a0,0x15
    80002eb2:	8d250513          	addi	a0,a0,-1838 # 80017780 <bcache>
    80002eb6:	ffffe097          	auipc	ra,0xffffe
    80002eba:	d5a080e7          	jalr	-678(ra) # 80000c10 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ebe:	0001d497          	auipc	s1,0x1d
    80002ec2:	b7a4b483          	ld	s1,-1158(s1) # 8001fa38 <bcache+0x82b8>
    80002ec6:	0001d797          	auipc	a5,0x1d
    80002eca:	b2278793          	addi	a5,a5,-1246 # 8001f9e8 <bcache+0x8268>
    80002ece:	02f48f63          	beq	s1,a5,80002f0c <bread+0x70>
    80002ed2:	873e                	mv	a4,a5
    80002ed4:	a021                	j	80002edc <bread+0x40>
    80002ed6:	68a4                	ld	s1,80(s1)
    80002ed8:	02e48a63          	beq	s1,a4,80002f0c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002edc:	449c                	lw	a5,8(s1)
    80002ede:	ff379ce3          	bne	a5,s3,80002ed6 <bread+0x3a>
    80002ee2:	44dc                	lw	a5,12(s1)
    80002ee4:	ff2799e3          	bne	a5,s2,80002ed6 <bread+0x3a>
      b->refcnt++;
    80002ee8:	40bc                	lw	a5,64(s1)
    80002eea:	2785                	addiw	a5,a5,1
    80002eec:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002eee:	00015517          	auipc	a0,0x15
    80002ef2:	89250513          	addi	a0,a0,-1902 # 80017780 <bcache>
    80002ef6:	ffffe097          	auipc	ra,0xffffe
    80002efa:	dce080e7          	jalr	-562(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    80002efe:	01048513          	addi	a0,s1,16
    80002f02:	00001097          	auipc	ra,0x1
    80002f06:	45a080e7          	jalr	1114(ra) # 8000435c <acquiresleep>
      return b;
    80002f0a:	a8b9                	j	80002f68 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f0c:	0001d497          	auipc	s1,0x1d
    80002f10:	b244b483          	ld	s1,-1244(s1) # 8001fa30 <bcache+0x82b0>
    80002f14:	0001d797          	auipc	a5,0x1d
    80002f18:	ad478793          	addi	a5,a5,-1324 # 8001f9e8 <bcache+0x8268>
    80002f1c:	00f48863          	beq	s1,a5,80002f2c <bread+0x90>
    80002f20:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f22:	40bc                	lw	a5,64(s1)
    80002f24:	cf81                	beqz	a5,80002f3c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f26:	64a4                	ld	s1,72(s1)
    80002f28:	fee49de3          	bne	s1,a4,80002f22 <bread+0x86>
  panic("bget: no buffers");
    80002f2c:	00005517          	auipc	a0,0x5
    80002f30:	54450513          	addi	a0,a0,1348 # 80008470 <syscalls+0xc0>
    80002f34:	ffffd097          	auipc	ra,0xffffd
    80002f38:	614080e7          	jalr	1556(ra) # 80000548 <panic>
      b->dev = dev;
    80002f3c:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002f40:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002f44:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f48:	4785                	li	a5,1
    80002f4a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f4c:	00015517          	auipc	a0,0x15
    80002f50:	83450513          	addi	a0,a0,-1996 # 80017780 <bcache>
    80002f54:	ffffe097          	auipc	ra,0xffffe
    80002f58:	d70080e7          	jalr	-656(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    80002f5c:	01048513          	addi	a0,s1,16
    80002f60:	00001097          	auipc	ra,0x1
    80002f64:	3fc080e7          	jalr	1020(ra) # 8000435c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f68:	409c                	lw	a5,0(s1)
    80002f6a:	cb89                	beqz	a5,80002f7c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f6c:	8526                	mv	a0,s1
    80002f6e:	70a2                	ld	ra,40(sp)
    80002f70:	7402                	ld	s0,32(sp)
    80002f72:	64e2                	ld	s1,24(sp)
    80002f74:	6942                	ld	s2,16(sp)
    80002f76:	69a2                	ld	s3,8(sp)
    80002f78:	6145                	addi	sp,sp,48
    80002f7a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f7c:	4581                	li	a1,0
    80002f7e:	8526                	mv	a0,s1
    80002f80:	00003097          	auipc	ra,0x3
    80002f84:	f3c080e7          	jalr	-196(ra) # 80005ebc <virtio_disk_rw>
    b->valid = 1;
    80002f88:	4785                	li	a5,1
    80002f8a:	c09c                	sw	a5,0(s1)
  return b;
    80002f8c:	b7c5                	j	80002f6c <bread+0xd0>

0000000080002f8e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f8e:	1101                	addi	sp,sp,-32
    80002f90:	ec06                	sd	ra,24(sp)
    80002f92:	e822                	sd	s0,16(sp)
    80002f94:	e426                	sd	s1,8(sp)
    80002f96:	1000                	addi	s0,sp,32
    80002f98:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f9a:	0541                	addi	a0,a0,16
    80002f9c:	00001097          	auipc	ra,0x1
    80002fa0:	45a080e7          	jalr	1114(ra) # 800043f6 <holdingsleep>
    80002fa4:	cd01                	beqz	a0,80002fbc <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fa6:	4585                	li	a1,1
    80002fa8:	8526                	mv	a0,s1
    80002faa:	00003097          	auipc	ra,0x3
    80002fae:	f12080e7          	jalr	-238(ra) # 80005ebc <virtio_disk_rw>
}
    80002fb2:	60e2                	ld	ra,24(sp)
    80002fb4:	6442                	ld	s0,16(sp)
    80002fb6:	64a2                	ld	s1,8(sp)
    80002fb8:	6105                	addi	sp,sp,32
    80002fba:	8082                	ret
    panic("bwrite");
    80002fbc:	00005517          	auipc	a0,0x5
    80002fc0:	4cc50513          	addi	a0,a0,1228 # 80008488 <syscalls+0xd8>
    80002fc4:	ffffd097          	auipc	ra,0xffffd
    80002fc8:	584080e7          	jalr	1412(ra) # 80000548 <panic>

0000000080002fcc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fcc:	1101                	addi	sp,sp,-32
    80002fce:	ec06                	sd	ra,24(sp)
    80002fd0:	e822                	sd	s0,16(sp)
    80002fd2:	e426                	sd	s1,8(sp)
    80002fd4:	e04a                	sd	s2,0(sp)
    80002fd6:	1000                	addi	s0,sp,32
    80002fd8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fda:	01050913          	addi	s2,a0,16
    80002fde:	854a                	mv	a0,s2
    80002fe0:	00001097          	auipc	ra,0x1
    80002fe4:	416080e7          	jalr	1046(ra) # 800043f6 <holdingsleep>
    80002fe8:	c92d                	beqz	a0,8000305a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fea:	854a                	mv	a0,s2
    80002fec:	00001097          	auipc	ra,0x1
    80002ff0:	3c6080e7          	jalr	966(ra) # 800043b2 <releasesleep>

  acquire(&bcache.lock);
    80002ff4:	00014517          	auipc	a0,0x14
    80002ff8:	78c50513          	addi	a0,a0,1932 # 80017780 <bcache>
    80002ffc:	ffffe097          	auipc	ra,0xffffe
    80003000:	c14080e7          	jalr	-1004(ra) # 80000c10 <acquire>
  b->refcnt--;
    80003004:	40bc                	lw	a5,64(s1)
    80003006:	37fd                	addiw	a5,a5,-1
    80003008:	0007871b          	sext.w	a4,a5
    8000300c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000300e:	eb05                	bnez	a4,8000303e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003010:	68bc                	ld	a5,80(s1)
    80003012:	64b8                	ld	a4,72(s1)
    80003014:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003016:	64bc                	ld	a5,72(s1)
    80003018:	68b8                	ld	a4,80(s1)
    8000301a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000301c:	0001c797          	auipc	a5,0x1c
    80003020:	76478793          	addi	a5,a5,1892 # 8001f780 <bcache+0x8000>
    80003024:	2b87b703          	ld	a4,696(a5)
    80003028:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000302a:	0001d717          	auipc	a4,0x1d
    8000302e:	9be70713          	addi	a4,a4,-1602 # 8001f9e8 <bcache+0x8268>
    80003032:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003034:	2b87b703          	ld	a4,696(a5)
    80003038:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000303a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000303e:	00014517          	auipc	a0,0x14
    80003042:	74250513          	addi	a0,a0,1858 # 80017780 <bcache>
    80003046:	ffffe097          	auipc	ra,0xffffe
    8000304a:	c7e080e7          	jalr	-898(ra) # 80000cc4 <release>
}
    8000304e:	60e2                	ld	ra,24(sp)
    80003050:	6442                	ld	s0,16(sp)
    80003052:	64a2                	ld	s1,8(sp)
    80003054:	6902                	ld	s2,0(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret
    panic("brelse");
    8000305a:	00005517          	auipc	a0,0x5
    8000305e:	43650513          	addi	a0,a0,1078 # 80008490 <syscalls+0xe0>
    80003062:	ffffd097          	auipc	ra,0xffffd
    80003066:	4e6080e7          	jalr	1254(ra) # 80000548 <panic>

000000008000306a <bpin>:

void
bpin(struct buf *b) {
    8000306a:	1101                	addi	sp,sp,-32
    8000306c:	ec06                	sd	ra,24(sp)
    8000306e:	e822                	sd	s0,16(sp)
    80003070:	e426                	sd	s1,8(sp)
    80003072:	1000                	addi	s0,sp,32
    80003074:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003076:	00014517          	auipc	a0,0x14
    8000307a:	70a50513          	addi	a0,a0,1802 # 80017780 <bcache>
    8000307e:	ffffe097          	auipc	ra,0xffffe
    80003082:	b92080e7          	jalr	-1134(ra) # 80000c10 <acquire>
  b->refcnt++;
    80003086:	40bc                	lw	a5,64(s1)
    80003088:	2785                	addiw	a5,a5,1
    8000308a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000308c:	00014517          	auipc	a0,0x14
    80003090:	6f450513          	addi	a0,a0,1780 # 80017780 <bcache>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	c30080e7          	jalr	-976(ra) # 80000cc4 <release>
}
    8000309c:	60e2                	ld	ra,24(sp)
    8000309e:	6442                	ld	s0,16(sp)
    800030a0:	64a2                	ld	s1,8(sp)
    800030a2:	6105                	addi	sp,sp,32
    800030a4:	8082                	ret

00000000800030a6 <bunpin>:

void
bunpin(struct buf *b) {
    800030a6:	1101                	addi	sp,sp,-32
    800030a8:	ec06                	sd	ra,24(sp)
    800030aa:	e822                	sd	s0,16(sp)
    800030ac:	e426                	sd	s1,8(sp)
    800030ae:	1000                	addi	s0,sp,32
    800030b0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030b2:	00014517          	auipc	a0,0x14
    800030b6:	6ce50513          	addi	a0,a0,1742 # 80017780 <bcache>
    800030ba:	ffffe097          	auipc	ra,0xffffe
    800030be:	b56080e7          	jalr	-1194(ra) # 80000c10 <acquire>
  b->refcnt--;
    800030c2:	40bc                	lw	a5,64(s1)
    800030c4:	37fd                	addiw	a5,a5,-1
    800030c6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c8:	00014517          	auipc	a0,0x14
    800030cc:	6b850513          	addi	a0,a0,1720 # 80017780 <bcache>
    800030d0:	ffffe097          	auipc	ra,0xffffe
    800030d4:	bf4080e7          	jalr	-1036(ra) # 80000cc4 <release>
}
    800030d8:	60e2                	ld	ra,24(sp)
    800030da:	6442                	ld	s0,16(sp)
    800030dc:	64a2                	ld	s1,8(sp)
    800030de:	6105                	addi	sp,sp,32
    800030e0:	8082                	ret

00000000800030e2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030e2:	1101                	addi	sp,sp,-32
    800030e4:	ec06                	sd	ra,24(sp)
    800030e6:	e822                	sd	s0,16(sp)
    800030e8:	e426                	sd	s1,8(sp)
    800030ea:	e04a                	sd	s2,0(sp)
    800030ec:	1000                	addi	s0,sp,32
    800030ee:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030f0:	00d5d59b          	srliw	a1,a1,0xd
    800030f4:	0001d797          	auipc	a5,0x1d
    800030f8:	d687a783          	lw	a5,-664(a5) # 8001fe5c <sb+0x1c>
    800030fc:	9dbd                	addw	a1,a1,a5
    800030fe:	00000097          	auipc	ra,0x0
    80003102:	d9e080e7          	jalr	-610(ra) # 80002e9c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003106:	0074f713          	andi	a4,s1,7
    8000310a:	4785                	li	a5,1
    8000310c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003110:	14ce                	slli	s1,s1,0x33
    80003112:	90d9                	srli	s1,s1,0x36
    80003114:	00950733          	add	a4,a0,s1
    80003118:	05874703          	lbu	a4,88(a4)
    8000311c:	00e7f6b3          	and	a3,a5,a4
    80003120:	c69d                	beqz	a3,8000314e <bfree+0x6c>
    80003122:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003124:	94aa                	add	s1,s1,a0
    80003126:	fff7c793          	not	a5,a5
    8000312a:	8ff9                	and	a5,a5,a4
    8000312c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003130:	00001097          	auipc	ra,0x1
    80003134:	104080e7          	jalr	260(ra) # 80004234 <log_write>
  brelse(bp);
    80003138:	854a                	mv	a0,s2
    8000313a:	00000097          	auipc	ra,0x0
    8000313e:	e92080e7          	jalr	-366(ra) # 80002fcc <brelse>
}
    80003142:	60e2                	ld	ra,24(sp)
    80003144:	6442                	ld	s0,16(sp)
    80003146:	64a2                	ld	s1,8(sp)
    80003148:	6902                	ld	s2,0(sp)
    8000314a:	6105                	addi	sp,sp,32
    8000314c:	8082                	ret
    panic("freeing free block");
    8000314e:	00005517          	auipc	a0,0x5
    80003152:	34a50513          	addi	a0,a0,842 # 80008498 <syscalls+0xe8>
    80003156:	ffffd097          	auipc	ra,0xffffd
    8000315a:	3f2080e7          	jalr	1010(ra) # 80000548 <panic>

000000008000315e <balloc>:
{
    8000315e:	711d                	addi	sp,sp,-96
    80003160:	ec86                	sd	ra,88(sp)
    80003162:	e8a2                	sd	s0,80(sp)
    80003164:	e4a6                	sd	s1,72(sp)
    80003166:	e0ca                	sd	s2,64(sp)
    80003168:	fc4e                	sd	s3,56(sp)
    8000316a:	f852                	sd	s4,48(sp)
    8000316c:	f456                	sd	s5,40(sp)
    8000316e:	f05a                	sd	s6,32(sp)
    80003170:	ec5e                	sd	s7,24(sp)
    80003172:	e862                	sd	s8,16(sp)
    80003174:	e466                	sd	s9,8(sp)
    80003176:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003178:	0001d797          	auipc	a5,0x1d
    8000317c:	ccc7a783          	lw	a5,-820(a5) # 8001fe44 <sb+0x4>
    80003180:	cbd1                	beqz	a5,80003214 <balloc+0xb6>
    80003182:	8baa                	mv	s7,a0
    80003184:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003186:	0001db17          	auipc	s6,0x1d
    8000318a:	cbab0b13          	addi	s6,s6,-838 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000318e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003190:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003192:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003194:	6c89                	lui	s9,0x2
    80003196:	a831                	j	800031b2 <balloc+0x54>
    brelse(bp);
    80003198:	854a                	mv	a0,s2
    8000319a:	00000097          	auipc	ra,0x0
    8000319e:	e32080e7          	jalr	-462(ra) # 80002fcc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031a2:	015c87bb          	addw	a5,s9,s5
    800031a6:	00078a9b          	sext.w	s5,a5
    800031aa:	004b2703          	lw	a4,4(s6)
    800031ae:	06eaf363          	bgeu	s5,a4,80003214 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800031b2:	41fad79b          	sraiw	a5,s5,0x1f
    800031b6:	0137d79b          	srliw	a5,a5,0x13
    800031ba:	015787bb          	addw	a5,a5,s5
    800031be:	40d7d79b          	sraiw	a5,a5,0xd
    800031c2:	01cb2583          	lw	a1,28(s6)
    800031c6:	9dbd                	addw	a1,a1,a5
    800031c8:	855e                	mv	a0,s7
    800031ca:	00000097          	auipc	ra,0x0
    800031ce:	cd2080e7          	jalr	-814(ra) # 80002e9c <bread>
    800031d2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d4:	004b2503          	lw	a0,4(s6)
    800031d8:	000a849b          	sext.w	s1,s5
    800031dc:	8662                	mv	a2,s8
    800031de:	faa4fde3          	bgeu	s1,a0,80003198 <balloc+0x3a>
      m = 1 << (bi % 8);
    800031e2:	41f6579b          	sraiw	a5,a2,0x1f
    800031e6:	01d7d69b          	srliw	a3,a5,0x1d
    800031ea:	00c6873b          	addw	a4,a3,a2
    800031ee:	00777793          	andi	a5,a4,7
    800031f2:	9f95                	subw	a5,a5,a3
    800031f4:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031f8:	4037571b          	sraiw	a4,a4,0x3
    800031fc:	00e906b3          	add	a3,s2,a4
    80003200:	0586c683          	lbu	a3,88(a3)
    80003204:	00d7f5b3          	and	a1,a5,a3
    80003208:	cd91                	beqz	a1,80003224 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000320a:	2605                	addiw	a2,a2,1
    8000320c:	2485                	addiw	s1,s1,1
    8000320e:	fd4618e3          	bne	a2,s4,800031de <balloc+0x80>
    80003212:	b759                	j	80003198 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003214:	00005517          	auipc	a0,0x5
    80003218:	29c50513          	addi	a0,a0,668 # 800084b0 <syscalls+0x100>
    8000321c:	ffffd097          	auipc	ra,0xffffd
    80003220:	32c080e7          	jalr	812(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003224:	974a                	add	a4,a4,s2
    80003226:	8fd5                	or	a5,a5,a3
    80003228:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000322c:	854a                	mv	a0,s2
    8000322e:	00001097          	auipc	ra,0x1
    80003232:	006080e7          	jalr	6(ra) # 80004234 <log_write>
        brelse(bp);
    80003236:	854a                	mv	a0,s2
    80003238:	00000097          	auipc	ra,0x0
    8000323c:	d94080e7          	jalr	-620(ra) # 80002fcc <brelse>
  bp = bread(dev, bno);
    80003240:	85a6                	mv	a1,s1
    80003242:	855e                	mv	a0,s7
    80003244:	00000097          	auipc	ra,0x0
    80003248:	c58080e7          	jalr	-936(ra) # 80002e9c <bread>
    8000324c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000324e:	40000613          	li	a2,1024
    80003252:	4581                	li	a1,0
    80003254:	05850513          	addi	a0,a0,88
    80003258:	ffffe097          	auipc	ra,0xffffe
    8000325c:	ab4080e7          	jalr	-1356(ra) # 80000d0c <memset>
  log_write(bp);
    80003260:	854a                	mv	a0,s2
    80003262:	00001097          	auipc	ra,0x1
    80003266:	fd2080e7          	jalr	-46(ra) # 80004234 <log_write>
  brelse(bp);
    8000326a:	854a                	mv	a0,s2
    8000326c:	00000097          	auipc	ra,0x0
    80003270:	d60080e7          	jalr	-672(ra) # 80002fcc <brelse>
}
    80003274:	8526                	mv	a0,s1
    80003276:	60e6                	ld	ra,88(sp)
    80003278:	6446                	ld	s0,80(sp)
    8000327a:	64a6                	ld	s1,72(sp)
    8000327c:	6906                	ld	s2,64(sp)
    8000327e:	79e2                	ld	s3,56(sp)
    80003280:	7a42                	ld	s4,48(sp)
    80003282:	7aa2                	ld	s5,40(sp)
    80003284:	7b02                	ld	s6,32(sp)
    80003286:	6be2                	ld	s7,24(sp)
    80003288:	6c42                	ld	s8,16(sp)
    8000328a:	6ca2                	ld	s9,8(sp)
    8000328c:	6125                	addi	sp,sp,96
    8000328e:	8082                	ret

0000000080003290 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003290:	7179                	addi	sp,sp,-48
    80003292:	f406                	sd	ra,40(sp)
    80003294:	f022                	sd	s0,32(sp)
    80003296:	ec26                	sd	s1,24(sp)
    80003298:	e84a                	sd	s2,16(sp)
    8000329a:	e44e                	sd	s3,8(sp)
    8000329c:	e052                	sd	s4,0(sp)
    8000329e:	1800                	addi	s0,sp,48
    800032a0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032a2:	47ad                	li	a5,11
    800032a4:	04b7fe63          	bgeu	a5,a1,80003300 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800032a8:	ff45849b          	addiw	s1,a1,-12
    800032ac:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032b0:	0ff00793          	li	a5,255
    800032b4:	0ae7e363          	bltu	a5,a4,8000335a <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800032b8:	08052583          	lw	a1,128(a0)
    800032bc:	c5ad                	beqz	a1,80003326 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800032be:	00092503          	lw	a0,0(s2)
    800032c2:	00000097          	auipc	ra,0x0
    800032c6:	bda080e7          	jalr	-1062(ra) # 80002e9c <bread>
    800032ca:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032cc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032d0:	02049593          	slli	a1,s1,0x20
    800032d4:	9181                	srli	a1,a1,0x20
    800032d6:	058a                	slli	a1,a1,0x2
    800032d8:	00b784b3          	add	s1,a5,a1
    800032dc:	0004a983          	lw	s3,0(s1)
    800032e0:	04098d63          	beqz	s3,8000333a <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032e4:	8552                	mv	a0,s4
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	ce6080e7          	jalr	-794(ra) # 80002fcc <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032ee:	854e                	mv	a0,s3
    800032f0:	70a2                	ld	ra,40(sp)
    800032f2:	7402                	ld	s0,32(sp)
    800032f4:	64e2                	ld	s1,24(sp)
    800032f6:	6942                	ld	s2,16(sp)
    800032f8:	69a2                	ld	s3,8(sp)
    800032fa:	6a02                	ld	s4,0(sp)
    800032fc:	6145                	addi	sp,sp,48
    800032fe:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003300:	02059493          	slli	s1,a1,0x20
    80003304:	9081                	srli	s1,s1,0x20
    80003306:	048a                	slli	s1,s1,0x2
    80003308:	94aa                	add	s1,s1,a0
    8000330a:	0504a983          	lw	s3,80(s1)
    8000330e:	fe0990e3          	bnez	s3,800032ee <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003312:	4108                	lw	a0,0(a0)
    80003314:	00000097          	auipc	ra,0x0
    80003318:	e4a080e7          	jalr	-438(ra) # 8000315e <balloc>
    8000331c:	0005099b          	sext.w	s3,a0
    80003320:	0534a823          	sw	s3,80(s1)
    80003324:	b7e9                	j	800032ee <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003326:	4108                	lw	a0,0(a0)
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	e36080e7          	jalr	-458(ra) # 8000315e <balloc>
    80003330:	0005059b          	sext.w	a1,a0
    80003334:	08b92023          	sw	a1,128(s2)
    80003338:	b759                	j	800032be <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000333a:	00092503          	lw	a0,0(s2)
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	e20080e7          	jalr	-480(ra) # 8000315e <balloc>
    80003346:	0005099b          	sext.w	s3,a0
    8000334a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000334e:	8552                	mv	a0,s4
    80003350:	00001097          	auipc	ra,0x1
    80003354:	ee4080e7          	jalr	-284(ra) # 80004234 <log_write>
    80003358:	b771                	j	800032e4 <bmap+0x54>
  panic("bmap: out of range");
    8000335a:	00005517          	auipc	a0,0x5
    8000335e:	16e50513          	addi	a0,a0,366 # 800084c8 <syscalls+0x118>
    80003362:	ffffd097          	auipc	ra,0xffffd
    80003366:	1e6080e7          	jalr	486(ra) # 80000548 <panic>

000000008000336a <iget>:
{
    8000336a:	7179                	addi	sp,sp,-48
    8000336c:	f406                	sd	ra,40(sp)
    8000336e:	f022                	sd	s0,32(sp)
    80003370:	ec26                	sd	s1,24(sp)
    80003372:	e84a                	sd	s2,16(sp)
    80003374:	e44e                	sd	s3,8(sp)
    80003376:	e052                	sd	s4,0(sp)
    80003378:	1800                	addi	s0,sp,48
    8000337a:	89aa                	mv	s3,a0
    8000337c:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000337e:	0001d517          	auipc	a0,0x1d
    80003382:	ae250513          	addi	a0,a0,-1310 # 8001fe60 <icache>
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	88a080e7          	jalr	-1910(ra) # 80000c10 <acquire>
  empty = 0;
    8000338e:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003390:	0001d497          	auipc	s1,0x1d
    80003394:	ae848493          	addi	s1,s1,-1304 # 8001fe78 <icache+0x18>
    80003398:	0001e697          	auipc	a3,0x1e
    8000339c:	57068693          	addi	a3,a3,1392 # 80021908 <log>
    800033a0:	a039                	j	800033ae <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033a2:	02090b63          	beqz	s2,800033d8 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800033a6:	08848493          	addi	s1,s1,136
    800033aa:	02d48a63          	beq	s1,a3,800033de <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033ae:	449c                	lw	a5,8(s1)
    800033b0:	fef059e3          	blez	a5,800033a2 <iget+0x38>
    800033b4:	4098                	lw	a4,0(s1)
    800033b6:	ff3716e3          	bne	a4,s3,800033a2 <iget+0x38>
    800033ba:	40d8                	lw	a4,4(s1)
    800033bc:	ff4713e3          	bne	a4,s4,800033a2 <iget+0x38>
      ip->ref++;
    800033c0:	2785                	addiw	a5,a5,1
    800033c2:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800033c4:	0001d517          	auipc	a0,0x1d
    800033c8:	a9c50513          	addi	a0,a0,-1380 # 8001fe60 <icache>
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	8f8080e7          	jalr	-1800(ra) # 80000cc4 <release>
      return ip;
    800033d4:	8926                	mv	s2,s1
    800033d6:	a03d                	j	80003404 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033d8:	f7f9                	bnez	a5,800033a6 <iget+0x3c>
    800033da:	8926                	mv	s2,s1
    800033dc:	b7e9                	j	800033a6 <iget+0x3c>
  if(empty == 0)
    800033de:	02090c63          	beqz	s2,80003416 <iget+0xac>
  ip->dev = dev;
    800033e2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033e6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033ea:	4785                	li	a5,1
    800033ec:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033f0:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800033f4:	0001d517          	auipc	a0,0x1d
    800033f8:	a6c50513          	addi	a0,a0,-1428 # 8001fe60 <icache>
    800033fc:	ffffe097          	auipc	ra,0xffffe
    80003400:	8c8080e7          	jalr	-1848(ra) # 80000cc4 <release>
}
    80003404:	854a                	mv	a0,s2
    80003406:	70a2                	ld	ra,40(sp)
    80003408:	7402                	ld	s0,32(sp)
    8000340a:	64e2                	ld	s1,24(sp)
    8000340c:	6942                	ld	s2,16(sp)
    8000340e:	69a2                	ld	s3,8(sp)
    80003410:	6a02                	ld	s4,0(sp)
    80003412:	6145                	addi	sp,sp,48
    80003414:	8082                	ret
    panic("iget: no inodes");
    80003416:	00005517          	auipc	a0,0x5
    8000341a:	0ca50513          	addi	a0,a0,202 # 800084e0 <syscalls+0x130>
    8000341e:	ffffd097          	auipc	ra,0xffffd
    80003422:	12a080e7          	jalr	298(ra) # 80000548 <panic>

0000000080003426 <fsinit>:
fsinit(int dev) {
    80003426:	7179                	addi	sp,sp,-48
    80003428:	f406                	sd	ra,40(sp)
    8000342a:	f022                	sd	s0,32(sp)
    8000342c:	ec26                	sd	s1,24(sp)
    8000342e:	e84a                	sd	s2,16(sp)
    80003430:	e44e                	sd	s3,8(sp)
    80003432:	1800                	addi	s0,sp,48
    80003434:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003436:	4585                	li	a1,1
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	a64080e7          	jalr	-1436(ra) # 80002e9c <bread>
    80003440:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003442:	0001d997          	auipc	s3,0x1d
    80003446:	9fe98993          	addi	s3,s3,-1538 # 8001fe40 <sb>
    8000344a:	02000613          	li	a2,32
    8000344e:	05850593          	addi	a1,a0,88
    80003452:	854e                	mv	a0,s3
    80003454:	ffffe097          	auipc	ra,0xffffe
    80003458:	918080e7          	jalr	-1768(ra) # 80000d6c <memmove>
  brelse(bp);
    8000345c:	8526                	mv	a0,s1
    8000345e:	00000097          	auipc	ra,0x0
    80003462:	b6e080e7          	jalr	-1170(ra) # 80002fcc <brelse>
  if(sb.magic != FSMAGIC)
    80003466:	0009a703          	lw	a4,0(s3)
    8000346a:	102037b7          	lui	a5,0x10203
    8000346e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003472:	02f71263          	bne	a4,a5,80003496 <fsinit+0x70>
  initlog(dev, &sb);
    80003476:	0001d597          	auipc	a1,0x1d
    8000347a:	9ca58593          	addi	a1,a1,-1590 # 8001fe40 <sb>
    8000347e:	854a                	mv	a0,s2
    80003480:	00001097          	auipc	ra,0x1
    80003484:	b3c080e7          	jalr	-1220(ra) # 80003fbc <initlog>
}
    80003488:	70a2                	ld	ra,40(sp)
    8000348a:	7402                	ld	s0,32(sp)
    8000348c:	64e2                	ld	s1,24(sp)
    8000348e:	6942                	ld	s2,16(sp)
    80003490:	69a2                	ld	s3,8(sp)
    80003492:	6145                	addi	sp,sp,48
    80003494:	8082                	ret
    panic("invalid file system");
    80003496:	00005517          	auipc	a0,0x5
    8000349a:	05a50513          	addi	a0,a0,90 # 800084f0 <syscalls+0x140>
    8000349e:	ffffd097          	auipc	ra,0xffffd
    800034a2:	0aa080e7          	jalr	170(ra) # 80000548 <panic>

00000000800034a6 <iinit>:
{
    800034a6:	7179                	addi	sp,sp,-48
    800034a8:	f406                	sd	ra,40(sp)
    800034aa:	f022                	sd	s0,32(sp)
    800034ac:	ec26                	sd	s1,24(sp)
    800034ae:	e84a                	sd	s2,16(sp)
    800034b0:	e44e                	sd	s3,8(sp)
    800034b2:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800034b4:	00005597          	auipc	a1,0x5
    800034b8:	05458593          	addi	a1,a1,84 # 80008508 <syscalls+0x158>
    800034bc:	0001d517          	auipc	a0,0x1d
    800034c0:	9a450513          	addi	a0,a0,-1628 # 8001fe60 <icache>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	6bc080e7          	jalr	1724(ra) # 80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034cc:	0001d497          	auipc	s1,0x1d
    800034d0:	9bc48493          	addi	s1,s1,-1604 # 8001fe88 <icache+0x28>
    800034d4:	0001e997          	auipc	s3,0x1e
    800034d8:	44498993          	addi	s3,s3,1092 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800034dc:	00005917          	auipc	s2,0x5
    800034e0:	03490913          	addi	s2,s2,52 # 80008510 <syscalls+0x160>
    800034e4:	85ca                	mv	a1,s2
    800034e6:	8526                	mv	a0,s1
    800034e8:	00001097          	auipc	ra,0x1
    800034ec:	e3a080e7          	jalr	-454(ra) # 80004322 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034f0:	08848493          	addi	s1,s1,136
    800034f4:	ff3498e3          	bne	s1,s3,800034e4 <iinit+0x3e>
}
    800034f8:	70a2                	ld	ra,40(sp)
    800034fa:	7402                	ld	s0,32(sp)
    800034fc:	64e2                	ld	s1,24(sp)
    800034fe:	6942                	ld	s2,16(sp)
    80003500:	69a2                	ld	s3,8(sp)
    80003502:	6145                	addi	sp,sp,48
    80003504:	8082                	ret

0000000080003506 <ialloc>:
{
    80003506:	715d                	addi	sp,sp,-80
    80003508:	e486                	sd	ra,72(sp)
    8000350a:	e0a2                	sd	s0,64(sp)
    8000350c:	fc26                	sd	s1,56(sp)
    8000350e:	f84a                	sd	s2,48(sp)
    80003510:	f44e                	sd	s3,40(sp)
    80003512:	f052                	sd	s4,32(sp)
    80003514:	ec56                	sd	s5,24(sp)
    80003516:	e85a                	sd	s6,16(sp)
    80003518:	e45e                	sd	s7,8(sp)
    8000351a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000351c:	0001d717          	auipc	a4,0x1d
    80003520:	93072703          	lw	a4,-1744(a4) # 8001fe4c <sb+0xc>
    80003524:	4785                	li	a5,1
    80003526:	04e7fa63          	bgeu	a5,a4,8000357a <ialloc+0x74>
    8000352a:	8aaa                	mv	s5,a0
    8000352c:	8bae                	mv	s7,a1
    8000352e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003530:	0001da17          	auipc	s4,0x1d
    80003534:	910a0a13          	addi	s4,s4,-1776 # 8001fe40 <sb>
    80003538:	00048b1b          	sext.w	s6,s1
    8000353c:	0044d593          	srli	a1,s1,0x4
    80003540:	018a2783          	lw	a5,24(s4)
    80003544:	9dbd                	addw	a1,a1,a5
    80003546:	8556                	mv	a0,s5
    80003548:	00000097          	auipc	ra,0x0
    8000354c:	954080e7          	jalr	-1708(ra) # 80002e9c <bread>
    80003550:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003552:	05850993          	addi	s3,a0,88
    80003556:	00f4f793          	andi	a5,s1,15
    8000355a:	079a                	slli	a5,a5,0x6
    8000355c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000355e:	00099783          	lh	a5,0(s3)
    80003562:	c785                	beqz	a5,8000358a <ialloc+0x84>
    brelse(bp);
    80003564:	00000097          	auipc	ra,0x0
    80003568:	a68080e7          	jalr	-1432(ra) # 80002fcc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000356c:	0485                	addi	s1,s1,1
    8000356e:	00ca2703          	lw	a4,12(s4)
    80003572:	0004879b          	sext.w	a5,s1
    80003576:	fce7e1e3          	bltu	a5,a4,80003538 <ialloc+0x32>
  panic("ialloc: no inodes");
    8000357a:	00005517          	auipc	a0,0x5
    8000357e:	f9e50513          	addi	a0,a0,-98 # 80008518 <syscalls+0x168>
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	fc6080e7          	jalr	-58(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    8000358a:	04000613          	li	a2,64
    8000358e:	4581                	li	a1,0
    80003590:	854e                	mv	a0,s3
    80003592:	ffffd097          	auipc	ra,0xffffd
    80003596:	77a080e7          	jalr	1914(ra) # 80000d0c <memset>
      dip->type = type;
    8000359a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000359e:	854a                	mv	a0,s2
    800035a0:	00001097          	auipc	ra,0x1
    800035a4:	c94080e7          	jalr	-876(ra) # 80004234 <log_write>
      brelse(bp);
    800035a8:	854a                	mv	a0,s2
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	a22080e7          	jalr	-1502(ra) # 80002fcc <brelse>
      return iget(dev, inum);
    800035b2:	85da                	mv	a1,s6
    800035b4:	8556                	mv	a0,s5
    800035b6:	00000097          	auipc	ra,0x0
    800035ba:	db4080e7          	jalr	-588(ra) # 8000336a <iget>
}
    800035be:	60a6                	ld	ra,72(sp)
    800035c0:	6406                	ld	s0,64(sp)
    800035c2:	74e2                	ld	s1,56(sp)
    800035c4:	7942                	ld	s2,48(sp)
    800035c6:	79a2                	ld	s3,40(sp)
    800035c8:	7a02                	ld	s4,32(sp)
    800035ca:	6ae2                	ld	s5,24(sp)
    800035cc:	6b42                	ld	s6,16(sp)
    800035ce:	6ba2                	ld	s7,8(sp)
    800035d0:	6161                	addi	sp,sp,80
    800035d2:	8082                	ret

00000000800035d4 <iupdate>:
{
    800035d4:	1101                	addi	sp,sp,-32
    800035d6:	ec06                	sd	ra,24(sp)
    800035d8:	e822                	sd	s0,16(sp)
    800035da:	e426                	sd	s1,8(sp)
    800035dc:	e04a                	sd	s2,0(sp)
    800035de:	1000                	addi	s0,sp,32
    800035e0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035e2:	415c                	lw	a5,4(a0)
    800035e4:	0047d79b          	srliw	a5,a5,0x4
    800035e8:	0001d597          	auipc	a1,0x1d
    800035ec:	8705a583          	lw	a1,-1936(a1) # 8001fe58 <sb+0x18>
    800035f0:	9dbd                	addw	a1,a1,a5
    800035f2:	4108                	lw	a0,0(a0)
    800035f4:	00000097          	auipc	ra,0x0
    800035f8:	8a8080e7          	jalr	-1880(ra) # 80002e9c <bread>
    800035fc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035fe:	05850793          	addi	a5,a0,88
    80003602:	40c8                	lw	a0,4(s1)
    80003604:	893d                	andi	a0,a0,15
    80003606:	051a                	slli	a0,a0,0x6
    80003608:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000360a:	04449703          	lh	a4,68(s1)
    8000360e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003612:	04649703          	lh	a4,70(s1)
    80003616:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000361a:	04849703          	lh	a4,72(s1)
    8000361e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003622:	04a49703          	lh	a4,74(s1)
    80003626:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000362a:	44f8                	lw	a4,76(s1)
    8000362c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000362e:	03400613          	li	a2,52
    80003632:	05048593          	addi	a1,s1,80
    80003636:	0531                	addi	a0,a0,12
    80003638:	ffffd097          	auipc	ra,0xffffd
    8000363c:	734080e7          	jalr	1844(ra) # 80000d6c <memmove>
  log_write(bp);
    80003640:	854a                	mv	a0,s2
    80003642:	00001097          	auipc	ra,0x1
    80003646:	bf2080e7          	jalr	-1038(ra) # 80004234 <log_write>
  brelse(bp);
    8000364a:	854a                	mv	a0,s2
    8000364c:	00000097          	auipc	ra,0x0
    80003650:	980080e7          	jalr	-1664(ra) # 80002fcc <brelse>
}
    80003654:	60e2                	ld	ra,24(sp)
    80003656:	6442                	ld	s0,16(sp)
    80003658:	64a2                	ld	s1,8(sp)
    8000365a:	6902                	ld	s2,0(sp)
    8000365c:	6105                	addi	sp,sp,32
    8000365e:	8082                	ret

0000000080003660 <idup>:
{
    80003660:	1101                	addi	sp,sp,-32
    80003662:	ec06                	sd	ra,24(sp)
    80003664:	e822                	sd	s0,16(sp)
    80003666:	e426                	sd	s1,8(sp)
    80003668:	1000                	addi	s0,sp,32
    8000366a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000366c:	0001c517          	auipc	a0,0x1c
    80003670:	7f450513          	addi	a0,a0,2036 # 8001fe60 <icache>
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	59c080e7          	jalr	1436(ra) # 80000c10 <acquire>
  ip->ref++;
    8000367c:	449c                	lw	a5,8(s1)
    8000367e:	2785                	addiw	a5,a5,1
    80003680:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003682:	0001c517          	auipc	a0,0x1c
    80003686:	7de50513          	addi	a0,a0,2014 # 8001fe60 <icache>
    8000368a:	ffffd097          	auipc	ra,0xffffd
    8000368e:	63a080e7          	jalr	1594(ra) # 80000cc4 <release>
}
    80003692:	8526                	mv	a0,s1
    80003694:	60e2                	ld	ra,24(sp)
    80003696:	6442                	ld	s0,16(sp)
    80003698:	64a2                	ld	s1,8(sp)
    8000369a:	6105                	addi	sp,sp,32
    8000369c:	8082                	ret

000000008000369e <ilock>:
{
    8000369e:	1101                	addi	sp,sp,-32
    800036a0:	ec06                	sd	ra,24(sp)
    800036a2:	e822                	sd	s0,16(sp)
    800036a4:	e426                	sd	s1,8(sp)
    800036a6:	e04a                	sd	s2,0(sp)
    800036a8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036aa:	c115                	beqz	a0,800036ce <ilock+0x30>
    800036ac:	84aa                	mv	s1,a0
    800036ae:	451c                	lw	a5,8(a0)
    800036b0:	00f05f63          	blez	a5,800036ce <ilock+0x30>
  acquiresleep(&ip->lock);
    800036b4:	0541                	addi	a0,a0,16
    800036b6:	00001097          	auipc	ra,0x1
    800036ba:	ca6080e7          	jalr	-858(ra) # 8000435c <acquiresleep>
  if(ip->valid == 0){
    800036be:	40bc                	lw	a5,64(s1)
    800036c0:	cf99                	beqz	a5,800036de <ilock+0x40>
}
    800036c2:	60e2                	ld	ra,24(sp)
    800036c4:	6442                	ld	s0,16(sp)
    800036c6:	64a2                	ld	s1,8(sp)
    800036c8:	6902                	ld	s2,0(sp)
    800036ca:	6105                	addi	sp,sp,32
    800036cc:	8082                	ret
    panic("ilock");
    800036ce:	00005517          	auipc	a0,0x5
    800036d2:	e6250513          	addi	a0,a0,-414 # 80008530 <syscalls+0x180>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	e72080e7          	jalr	-398(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036de:	40dc                	lw	a5,4(s1)
    800036e0:	0047d79b          	srliw	a5,a5,0x4
    800036e4:	0001c597          	auipc	a1,0x1c
    800036e8:	7745a583          	lw	a1,1908(a1) # 8001fe58 <sb+0x18>
    800036ec:	9dbd                	addw	a1,a1,a5
    800036ee:	4088                	lw	a0,0(s1)
    800036f0:	fffff097          	auipc	ra,0xfffff
    800036f4:	7ac080e7          	jalr	1964(ra) # 80002e9c <bread>
    800036f8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036fa:	05850593          	addi	a1,a0,88
    800036fe:	40dc                	lw	a5,4(s1)
    80003700:	8bbd                	andi	a5,a5,15
    80003702:	079a                	slli	a5,a5,0x6
    80003704:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003706:	00059783          	lh	a5,0(a1)
    8000370a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000370e:	00259783          	lh	a5,2(a1)
    80003712:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003716:	00459783          	lh	a5,4(a1)
    8000371a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000371e:	00659783          	lh	a5,6(a1)
    80003722:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003726:	459c                	lw	a5,8(a1)
    80003728:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000372a:	03400613          	li	a2,52
    8000372e:	05b1                	addi	a1,a1,12
    80003730:	05048513          	addi	a0,s1,80
    80003734:	ffffd097          	auipc	ra,0xffffd
    80003738:	638080e7          	jalr	1592(ra) # 80000d6c <memmove>
    brelse(bp);
    8000373c:	854a                	mv	a0,s2
    8000373e:	00000097          	auipc	ra,0x0
    80003742:	88e080e7          	jalr	-1906(ra) # 80002fcc <brelse>
    ip->valid = 1;
    80003746:	4785                	li	a5,1
    80003748:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000374a:	04449783          	lh	a5,68(s1)
    8000374e:	fbb5                	bnez	a5,800036c2 <ilock+0x24>
      panic("ilock: no type");
    80003750:	00005517          	auipc	a0,0x5
    80003754:	de850513          	addi	a0,a0,-536 # 80008538 <syscalls+0x188>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	df0080e7          	jalr	-528(ra) # 80000548 <panic>

0000000080003760 <iunlock>:
{
    80003760:	1101                	addi	sp,sp,-32
    80003762:	ec06                	sd	ra,24(sp)
    80003764:	e822                	sd	s0,16(sp)
    80003766:	e426                	sd	s1,8(sp)
    80003768:	e04a                	sd	s2,0(sp)
    8000376a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000376c:	c905                	beqz	a0,8000379c <iunlock+0x3c>
    8000376e:	84aa                	mv	s1,a0
    80003770:	01050913          	addi	s2,a0,16
    80003774:	854a                	mv	a0,s2
    80003776:	00001097          	auipc	ra,0x1
    8000377a:	c80080e7          	jalr	-896(ra) # 800043f6 <holdingsleep>
    8000377e:	cd19                	beqz	a0,8000379c <iunlock+0x3c>
    80003780:	449c                	lw	a5,8(s1)
    80003782:	00f05d63          	blez	a5,8000379c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003786:	854a                	mv	a0,s2
    80003788:	00001097          	auipc	ra,0x1
    8000378c:	c2a080e7          	jalr	-982(ra) # 800043b2 <releasesleep>
}
    80003790:	60e2                	ld	ra,24(sp)
    80003792:	6442                	ld	s0,16(sp)
    80003794:	64a2                	ld	s1,8(sp)
    80003796:	6902                	ld	s2,0(sp)
    80003798:	6105                	addi	sp,sp,32
    8000379a:	8082                	ret
    panic("iunlock");
    8000379c:	00005517          	auipc	a0,0x5
    800037a0:	dac50513          	addi	a0,a0,-596 # 80008548 <syscalls+0x198>
    800037a4:	ffffd097          	auipc	ra,0xffffd
    800037a8:	da4080e7          	jalr	-604(ra) # 80000548 <panic>

00000000800037ac <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037ac:	7179                	addi	sp,sp,-48
    800037ae:	f406                	sd	ra,40(sp)
    800037b0:	f022                	sd	s0,32(sp)
    800037b2:	ec26                	sd	s1,24(sp)
    800037b4:	e84a                	sd	s2,16(sp)
    800037b6:	e44e                	sd	s3,8(sp)
    800037b8:	e052                	sd	s4,0(sp)
    800037ba:	1800                	addi	s0,sp,48
    800037bc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037be:	05050493          	addi	s1,a0,80
    800037c2:	08050913          	addi	s2,a0,128
    800037c6:	a021                	j	800037ce <itrunc+0x22>
    800037c8:	0491                	addi	s1,s1,4
    800037ca:	01248d63          	beq	s1,s2,800037e4 <itrunc+0x38>
    if(ip->addrs[i]){
    800037ce:	408c                	lw	a1,0(s1)
    800037d0:	dde5                	beqz	a1,800037c8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037d2:	0009a503          	lw	a0,0(s3)
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	90c080e7          	jalr	-1780(ra) # 800030e2 <bfree>
      ip->addrs[i] = 0;
    800037de:	0004a023          	sw	zero,0(s1)
    800037e2:	b7dd                	j	800037c8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037e4:	0809a583          	lw	a1,128(s3)
    800037e8:	e185                	bnez	a1,80003808 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037ea:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037ee:	854e                	mv	a0,s3
    800037f0:	00000097          	auipc	ra,0x0
    800037f4:	de4080e7          	jalr	-540(ra) # 800035d4 <iupdate>
}
    800037f8:	70a2                	ld	ra,40(sp)
    800037fa:	7402                	ld	s0,32(sp)
    800037fc:	64e2                	ld	s1,24(sp)
    800037fe:	6942                	ld	s2,16(sp)
    80003800:	69a2                	ld	s3,8(sp)
    80003802:	6a02                	ld	s4,0(sp)
    80003804:	6145                	addi	sp,sp,48
    80003806:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003808:	0009a503          	lw	a0,0(s3)
    8000380c:	fffff097          	auipc	ra,0xfffff
    80003810:	690080e7          	jalr	1680(ra) # 80002e9c <bread>
    80003814:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003816:	05850493          	addi	s1,a0,88
    8000381a:	45850913          	addi	s2,a0,1112
    8000381e:	a811                	j	80003832 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003820:	0009a503          	lw	a0,0(s3)
    80003824:	00000097          	auipc	ra,0x0
    80003828:	8be080e7          	jalr	-1858(ra) # 800030e2 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000382c:	0491                	addi	s1,s1,4
    8000382e:	01248563          	beq	s1,s2,80003838 <itrunc+0x8c>
      if(a[j])
    80003832:	408c                	lw	a1,0(s1)
    80003834:	dde5                	beqz	a1,8000382c <itrunc+0x80>
    80003836:	b7ed                	j	80003820 <itrunc+0x74>
    brelse(bp);
    80003838:	8552                	mv	a0,s4
    8000383a:	fffff097          	auipc	ra,0xfffff
    8000383e:	792080e7          	jalr	1938(ra) # 80002fcc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003842:	0809a583          	lw	a1,128(s3)
    80003846:	0009a503          	lw	a0,0(s3)
    8000384a:	00000097          	auipc	ra,0x0
    8000384e:	898080e7          	jalr	-1896(ra) # 800030e2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003852:	0809a023          	sw	zero,128(s3)
    80003856:	bf51                	j	800037ea <itrunc+0x3e>

0000000080003858 <iput>:
{
    80003858:	1101                	addi	sp,sp,-32
    8000385a:	ec06                	sd	ra,24(sp)
    8000385c:	e822                	sd	s0,16(sp)
    8000385e:	e426                	sd	s1,8(sp)
    80003860:	e04a                	sd	s2,0(sp)
    80003862:	1000                	addi	s0,sp,32
    80003864:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003866:	0001c517          	auipc	a0,0x1c
    8000386a:	5fa50513          	addi	a0,a0,1530 # 8001fe60 <icache>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	3a2080e7          	jalr	930(ra) # 80000c10 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003876:	4498                	lw	a4,8(s1)
    80003878:	4785                	li	a5,1
    8000387a:	02f70363          	beq	a4,a5,800038a0 <iput+0x48>
  ip->ref--;
    8000387e:	449c                	lw	a5,8(s1)
    80003880:	37fd                	addiw	a5,a5,-1
    80003882:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003884:	0001c517          	auipc	a0,0x1c
    80003888:	5dc50513          	addi	a0,a0,1500 # 8001fe60 <icache>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	438080e7          	jalr	1080(ra) # 80000cc4 <release>
}
    80003894:	60e2                	ld	ra,24(sp)
    80003896:	6442                	ld	s0,16(sp)
    80003898:	64a2                	ld	s1,8(sp)
    8000389a:	6902                	ld	s2,0(sp)
    8000389c:	6105                	addi	sp,sp,32
    8000389e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038a0:	40bc                	lw	a5,64(s1)
    800038a2:	dff1                	beqz	a5,8000387e <iput+0x26>
    800038a4:	04a49783          	lh	a5,74(s1)
    800038a8:	fbf9                	bnez	a5,8000387e <iput+0x26>
    acquiresleep(&ip->lock);
    800038aa:	01048913          	addi	s2,s1,16
    800038ae:	854a                	mv	a0,s2
    800038b0:	00001097          	auipc	ra,0x1
    800038b4:	aac080e7          	jalr	-1364(ra) # 8000435c <acquiresleep>
    release(&icache.lock);
    800038b8:	0001c517          	auipc	a0,0x1c
    800038bc:	5a850513          	addi	a0,a0,1448 # 8001fe60 <icache>
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	404080e7          	jalr	1028(ra) # 80000cc4 <release>
    itrunc(ip);
    800038c8:	8526                	mv	a0,s1
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	ee2080e7          	jalr	-286(ra) # 800037ac <itrunc>
    ip->type = 0;
    800038d2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038d6:	8526                	mv	a0,s1
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	cfc080e7          	jalr	-772(ra) # 800035d4 <iupdate>
    ip->valid = 0;
    800038e0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038e4:	854a                	mv	a0,s2
    800038e6:	00001097          	auipc	ra,0x1
    800038ea:	acc080e7          	jalr	-1332(ra) # 800043b2 <releasesleep>
    acquire(&icache.lock);
    800038ee:	0001c517          	auipc	a0,0x1c
    800038f2:	57250513          	addi	a0,a0,1394 # 8001fe60 <icache>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	31a080e7          	jalr	794(ra) # 80000c10 <acquire>
    800038fe:	b741                	j	8000387e <iput+0x26>

0000000080003900 <iunlockput>:
{
    80003900:	1101                	addi	sp,sp,-32
    80003902:	ec06                	sd	ra,24(sp)
    80003904:	e822                	sd	s0,16(sp)
    80003906:	e426                	sd	s1,8(sp)
    80003908:	1000                	addi	s0,sp,32
    8000390a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000390c:	00000097          	auipc	ra,0x0
    80003910:	e54080e7          	jalr	-428(ra) # 80003760 <iunlock>
  iput(ip);
    80003914:	8526                	mv	a0,s1
    80003916:	00000097          	auipc	ra,0x0
    8000391a:	f42080e7          	jalr	-190(ra) # 80003858 <iput>
}
    8000391e:	60e2                	ld	ra,24(sp)
    80003920:	6442                	ld	s0,16(sp)
    80003922:	64a2                	ld	s1,8(sp)
    80003924:	6105                	addi	sp,sp,32
    80003926:	8082                	ret

0000000080003928 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003928:	1141                	addi	sp,sp,-16
    8000392a:	e422                	sd	s0,8(sp)
    8000392c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000392e:	411c                	lw	a5,0(a0)
    80003930:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003932:	415c                	lw	a5,4(a0)
    80003934:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003936:	04451783          	lh	a5,68(a0)
    8000393a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000393e:	04a51783          	lh	a5,74(a0)
    80003942:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003946:	04c56783          	lwu	a5,76(a0)
    8000394a:	e99c                	sd	a5,16(a1)
}
    8000394c:	6422                	ld	s0,8(sp)
    8000394e:	0141                	addi	sp,sp,16
    80003950:	8082                	ret

0000000080003952 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003952:	457c                	lw	a5,76(a0)
    80003954:	0ed7e963          	bltu	a5,a3,80003a46 <readi+0xf4>
{
    80003958:	7159                	addi	sp,sp,-112
    8000395a:	f486                	sd	ra,104(sp)
    8000395c:	f0a2                	sd	s0,96(sp)
    8000395e:	eca6                	sd	s1,88(sp)
    80003960:	e8ca                	sd	s2,80(sp)
    80003962:	e4ce                	sd	s3,72(sp)
    80003964:	e0d2                	sd	s4,64(sp)
    80003966:	fc56                	sd	s5,56(sp)
    80003968:	f85a                	sd	s6,48(sp)
    8000396a:	f45e                	sd	s7,40(sp)
    8000396c:	f062                	sd	s8,32(sp)
    8000396e:	ec66                	sd	s9,24(sp)
    80003970:	e86a                	sd	s10,16(sp)
    80003972:	e46e                	sd	s11,8(sp)
    80003974:	1880                	addi	s0,sp,112
    80003976:	8baa                	mv	s7,a0
    80003978:	8c2e                	mv	s8,a1
    8000397a:	8ab2                	mv	s5,a2
    8000397c:	84b6                	mv	s1,a3
    8000397e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003980:	9f35                	addw	a4,a4,a3
    return 0;
    80003982:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003984:	0ad76063          	bltu	a4,a3,80003a24 <readi+0xd2>
  if(off + n > ip->size)
    80003988:	00e7f463          	bgeu	a5,a4,80003990 <readi+0x3e>
    n = ip->size - off;
    8000398c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003990:	0a0b0963          	beqz	s6,80003a42 <readi+0xf0>
    80003994:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003996:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000399a:	5cfd                	li	s9,-1
    8000399c:	a82d                	j	800039d6 <readi+0x84>
    8000399e:	020a1d93          	slli	s11,s4,0x20
    800039a2:	020ddd93          	srli	s11,s11,0x20
    800039a6:	05890613          	addi	a2,s2,88
    800039aa:	86ee                	mv	a3,s11
    800039ac:	963a                	add	a2,a2,a4
    800039ae:	85d6                	mv	a1,s5
    800039b0:	8562                	mv	a0,s8
    800039b2:	fffff097          	auipc	ra,0xfffff
    800039b6:	abc080e7          	jalr	-1348(ra) # 8000246e <either_copyout>
    800039ba:	05950d63          	beq	a0,s9,80003a14 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039be:	854a                	mv	a0,s2
    800039c0:	fffff097          	auipc	ra,0xfffff
    800039c4:	60c080e7          	jalr	1548(ra) # 80002fcc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039c8:	013a09bb          	addw	s3,s4,s3
    800039cc:	009a04bb          	addw	s1,s4,s1
    800039d0:	9aee                	add	s5,s5,s11
    800039d2:	0569f763          	bgeu	s3,s6,80003a20 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039d6:	000ba903          	lw	s2,0(s7)
    800039da:	00a4d59b          	srliw	a1,s1,0xa
    800039de:	855e                	mv	a0,s7
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	8b0080e7          	jalr	-1872(ra) # 80003290 <bmap>
    800039e8:	0005059b          	sext.w	a1,a0
    800039ec:	854a                	mv	a0,s2
    800039ee:	fffff097          	auipc	ra,0xfffff
    800039f2:	4ae080e7          	jalr	1198(ra) # 80002e9c <bread>
    800039f6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f8:	3ff4f713          	andi	a4,s1,1023
    800039fc:	40ed07bb          	subw	a5,s10,a4
    80003a00:	413b06bb          	subw	a3,s6,s3
    80003a04:	8a3e                	mv	s4,a5
    80003a06:	2781                	sext.w	a5,a5
    80003a08:	0006861b          	sext.w	a2,a3
    80003a0c:	f8f679e3          	bgeu	a2,a5,8000399e <readi+0x4c>
    80003a10:	8a36                	mv	s4,a3
    80003a12:	b771                	j	8000399e <readi+0x4c>
      brelse(bp);
    80003a14:	854a                	mv	a0,s2
    80003a16:	fffff097          	auipc	ra,0xfffff
    80003a1a:	5b6080e7          	jalr	1462(ra) # 80002fcc <brelse>
      tot = -1;
    80003a1e:	59fd                	li	s3,-1
  }
  return tot;
    80003a20:	0009851b          	sext.w	a0,s3
}
    80003a24:	70a6                	ld	ra,104(sp)
    80003a26:	7406                	ld	s0,96(sp)
    80003a28:	64e6                	ld	s1,88(sp)
    80003a2a:	6946                	ld	s2,80(sp)
    80003a2c:	69a6                	ld	s3,72(sp)
    80003a2e:	6a06                	ld	s4,64(sp)
    80003a30:	7ae2                	ld	s5,56(sp)
    80003a32:	7b42                	ld	s6,48(sp)
    80003a34:	7ba2                	ld	s7,40(sp)
    80003a36:	7c02                	ld	s8,32(sp)
    80003a38:	6ce2                	ld	s9,24(sp)
    80003a3a:	6d42                	ld	s10,16(sp)
    80003a3c:	6da2                	ld	s11,8(sp)
    80003a3e:	6165                	addi	sp,sp,112
    80003a40:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a42:	89da                	mv	s3,s6
    80003a44:	bff1                	j	80003a20 <readi+0xce>
    return 0;
    80003a46:	4501                	li	a0,0
}
    80003a48:	8082                	ret

0000000080003a4a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a4a:	457c                	lw	a5,76(a0)
    80003a4c:	10d7e763          	bltu	a5,a3,80003b5a <writei+0x110>
{
    80003a50:	7159                	addi	sp,sp,-112
    80003a52:	f486                	sd	ra,104(sp)
    80003a54:	f0a2                	sd	s0,96(sp)
    80003a56:	eca6                	sd	s1,88(sp)
    80003a58:	e8ca                	sd	s2,80(sp)
    80003a5a:	e4ce                	sd	s3,72(sp)
    80003a5c:	e0d2                	sd	s4,64(sp)
    80003a5e:	fc56                	sd	s5,56(sp)
    80003a60:	f85a                	sd	s6,48(sp)
    80003a62:	f45e                	sd	s7,40(sp)
    80003a64:	f062                	sd	s8,32(sp)
    80003a66:	ec66                	sd	s9,24(sp)
    80003a68:	e86a                	sd	s10,16(sp)
    80003a6a:	e46e                	sd	s11,8(sp)
    80003a6c:	1880                	addi	s0,sp,112
    80003a6e:	8baa                	mv	s7,a0
    80003a70:	8c2e                	mv	s8,a1
    80003a72:	8ab2                	mv	s5,a2
    80003a74:	8936                	mv	s2,a3
    80003a76:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a78:	00e687bb          	addw	a5,a3,a4
    80003a7c:	0ed7e163          	bltu	a5,a3,80003b5e <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a80:	00043737          	lui	a4,0x43
    80003a84:	0cf76f63          	bltu	a4,a5,80003b62 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a88:	0a0b0863          	beqz	s6,80003b38 <writei+0xee>
    80003a8c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a8e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a92:	5cfd                	li	s9,-1
    80003a94:	a091                	j	80003ad8 <writei+0x8e>
    80003a96:	02099d93          	slli	s11,s3,0x20
    80003a9a:	020ddd93          	srli	s11,s11,0x20
    80003a9e:	05848513          	addi	a0,s1,88
    80003aa2:	86ee                	mv	a3,s11
    80003aa4:	8656                	mv	a2,s5
    80003aa6:	85e2                	mv	a1,s8
    80003aa8:	953a                	add	a0,a0,a4
    80003aaa:	fffff097          	auipc	ra,0xfffff
    80003aae:	a1a080e7          	jalr	-1510(ra) # 800024c4 <either_copyin>
    80003ab2:	07950263          	beq	a0,s9,80003b16 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003ab6:	8526                	mv	a0,s1
    80003ab8:	00000097          	auipc	ra,0x0
    80003abc:	77c080e7          	jalr	1916(ra) # 80004234 <log_write>
    brelse(bp);
    80003ac0:	8526                	mv	a0,s1
    80003ac2:	fffff097          	auipc	ra,0xfffff
    80003ac6:	50a080e7          	jalr	1290(ra) # 80002fcc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aca:	01498a3b          	addw	s4,s3,s4
    80003ace:	0129893b          	addw	s2,s3,s2
    80003ad2:	9aee                	add	s5,s5,s11
    80003ad4:	056a7763          	bgeu	s4,s6,80003b22 <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ad8:	000ba483          	lw	s1,0(s7)
    80003adc:	00a9559b          	srliw	a1,s2,0xa
    80003ae0:	855e                	mv	a0,s7
    80003ae2:	fffff097          	auipc	ra,0xfffff
    80003ae6:	7ae080e7          	jalr	1966(ra) # 80003290 <bmap>
    80003aea:	0005059b          	sext.w	a1,a0
    80003aee:	8526                	mv	a0,s1
    80003af0:	fffff097          	auipc	ra,0xfffff
    80003af4:	3ac080e7          	jalr	940(ra) # 80002e9c <bread>
    80003af8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003afa:	3ff97713          	andi	a4,s2,1023
    80003afe:	40ed07bb          	subw	a5,s10,a4
    80003b02:	414b06bb          	subw	a3,s6,s4
    80003b06:	89be                	mv	s3,a5
    80003b08:	2781                	sext.w	a5,a5
    80003b0a:	0006861b          	sext.w	a2,a3
    80003b0e:	f8f674e3          	bgeu	a2,a5,80003a96 <writei+0x4c>
    80003b12:	89b6                	mv	s3,a3
    80003b14:	b749                	j	80003a96 <writei+0x4c>
      brelse(bp);
    80003b16:	8526                	mv	a0,s1
    80003b18:	fffff097          	auipc	ra,0xfffff
    80003b1c:	4b4080e7          	jalr	1204(ra) # 80002fcc <brelse>
      n = -1;
    80003b20:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003b22:	04cba783          	lw	a5,76(s7)
    80003b26:	0127f463          	bgeu	a5,s2,80003b2e <writei+0xe4>
      ip->size = off;
    80003b2a:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003b2e:	855e                	mv	a0,s7
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	aa4080e7          	jalr	-1372(ra) # 800035d4 <iupdate>
  }

  return n;
    80003b38:	000b051b          	sext.w	a0,s6
}
    80003b3c:	70a6                	ld	ra,104(sp)
    80003b3e:	7406                	ld	s0,96(sp)
    80003b40:	64e6                	ld	s1,88(sp)
    80003b42:	6946                	ld	s2,80(sp)
    80003b44:	69a6                	ld	s3,72(sp)
    80003b46:	6a06                	ld	s4,64(sp)
    80003b48:	7ae2                	ld	s5,56(sp)
    80003b4a:	7b42                	ld	s6,48(sp)
    80003b4c:	7ba2                	ld	s7,40(sp)
    80003b4e:	7c02                	ld	s8,32(sp)
    80003b50:	6ce2                	ld	s9,24(sp)
    80003b52:	6d42                	ld	s10,16(sp)
    80003b54:	6da2                	ld	s11,8(sp)
    80003b56:	6165                	addi	sp,sp,112
    80003b58:	8082                	ret
    return -1;
    80003b5a:	557d                	li	a0,-1
}
    80003b5c:	8082                	ret
    return -1;
    80003b5e:	557d                	li	a0,-1
    80003b60:	bff1                	j	80003b3c <writei+0xf2>
    return -1;
    80003b62:	557d                	li	a0,-1
    80003b64:	bfe1                	j	80003b3c <writei+0xf2>

0000000080003b66 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b66:	1141                	addi	sp,sp,-16
    80003b68:	e406                	sd	ra,8(sp)
    80003b6a:	e022                	sd	s0,0(sp)
    80003b6c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b6e:	4639                	li	a2,14
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	278080e7          	jalr	632(ra) # 80000de8 <strncmp>
}
    80003b78:	60a2                	ld	ra,8(sp)
    80003b7a:	6402                	ld	s0,0(sp)
    80003b7c:	0141                	addi	sp,sp,16
    80003b7e:	8082                	ret

0000000080003b80 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b80:	7139                	addi	sp,sp,-64
    80003b82:	fc06                	sd	ra,56(sp)
    80003b84:	f822                	sd	s0,48(sp)
    80003b86:	f426                	sd	s1,40(sp)
    80003b88:	f04a                	sd	s2,32(sp)
    80003b8a:	ec4e                	sd	s3,24(sp)
    80003b8c:	e852                	sd	s4,16(sp)
    80003b8e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b90:	04451703          	lh	a4,68(a0)
    80003b94:	4785                	li	a5,1
    80003b96:	00f71a63          	bne	a4,a5,80003baa <dirlookup+0x2a>
    80003b9a:	892a                	mv	s2,a0
    80003b9c:	89ae                	mv	s3,a1
    80003b9e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ba0:	457c                	lw	a5,76(a0)
    80003ba2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ba4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ba6:	e79d                	bnez	a5,80003bd4 <dirlookup+0x54>
    80003ba8:	a8a5                	j	80003c20 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003baa:	00005517          	auipc	a0,0x5
    80003bae:	9a650513          	addi	a0,a0,-1626 # 80008550 <syscalls+0x1a0>
    80003bb2:	ffffd097          	auipc	ra,0xffffd
    80003bb6:	996080e7          	jalr	-1642(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003bba:	00005517          	auipc	a0,0x5
    80003bbe:	9ae50513          	addi	a0,a0,-1618 # 80008568 <syscalls+0x1b8>
    80003bc2:	ffffd097          	auipc	ra,0xffffd
    80003bc6:	986080e7          	jalr	-1658(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bca:	24c1                	addiw	s1,s1,16
    80003bcc:	04c92783          	lw	a5,76(s2)
    80003bd0:	04f4f763          	bgeu	s1,a5,80003c1e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bd4:	4741                	li	a4,16
    80003bd6:	86a6                	mv	a3,s1
    80003bd8:	fc040613          	addi	a2,s0,-64
    80003bdc:	4581                	li	a1,0
    80003bde:	854a                	mv	a0,s2
    80003be0:	00000097          	auipc	ra,0x0
    80003be4:	d72080e7          	jalr	-654(ra) # 80003952 <readi>
    80003be8:	47c1                	li	a5,16
    80003bea:	fcf518e3          	bne	a0,a5,80003bba <dirlookup+0x3a>
    if(de.inum == 0)
    80003bee:	fc045783          	lhu	a5,-64(s0)
    80003bf2:	dfe1                	beqz	a5,80003bca <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bf4:	fc240593          	addi	a1,s0,-62
    80003bf8:	854e                	mv	a0,s3
    80003bfa:	00000097          	auipc	ra,0x0
    80003bfe:	f6c080e7          	jalr	-148(ra) # 80003b66 <namecmp>
    80003c02:	f561                	bnez	a0,80003bca <dirlookup+0x4a>
      if(poff)
    80003c04:	000a0463          	beqz	s4,80003c0c <dirlookup+0x8c>
        *poff = off;
    80003c08:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c0c:	fc045583          	lhu	a1,-64(s0)
    80003c10:	00092503          	lw	a0,0(s2)
    80003c14:	fffff097          	auipc	ra,0xfffff
    80003c18:	756080e7          	jalr	1878(ra) # 8000336a <iget>
    80003c1c:	a011                	j	80003c20 <dirlookup+0xa0>
  return 0;
    80003c1e:	4501                	li	a0,0
}
    80003c20:	70e2                	ld	ra,56(sp)
    80003c22:	7442                	ld	s0,48(sp)
    80003c24:	74a2                	ld	s1,40(sp)
    80003c26:	7902                	ld	s2,32(sp)
    80003c28:	69e2                	ld	s3,24(sp)
    80003c2a:	6a42                	ld	s4,16(sp)
    80003c2c:	6121                	addi	sp,sp,64
    80003c2e:	8082                	ret

0000000080003c30 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c30:	711d                	addi	sp,sp,-96
    80003c32:	ec86                	sd	ra,88(sp)
    80003c34:	e8a2                	sd	s0,80(sp)
    80003c36:	e4a6                	sd	s1,72(sp)
    80003c38:	e0ca                	sd	s2,64(sp)
    80003c3a:	fc4e                	sd	s3,56(sp)
    80003c3c:	f852                	sd	s4,48(sp)
    80003c3e:	f456                	sd	s5,40(sp)
    80003c40:	f05a                	sd	s6,32(sp)
    80003c42:	ec5e                	sd	s7,24(sp)
    80003c44:	e862                	sd	s8,16(sp)
    80003c46:	e466                	sd	s9,8(sp)
    80003c48:	1080                	addi	s0,sp,96
    80003c4a:	84aa                	mv	s1,a0
    80003c4c:	8b2e                	mv	s6,a1
    80003c4e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c50:	00054703          	lbu	a4,0(a0)
    80003c54:	02f00793          	li	a5,47
    80003c58:	02f70363          	beq	a4,a5,80003c7e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c5c:	ffffe097          	auipc	ra,0xffffe
    80003c60:	da0080e7          	jalr	-608(ra) # 800019fc <myproc>
    80003c64:	15053503          	ld	a0,336(a0)
    80003c68:	00000097          	auipc	ra,0x0
    80003c6c:	9f8080e7          	jalr	-1544(ra) # 80003660 <idup>
    80003c70:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c72:	02f00913          	li	s2,47
  len = path - s;
    80003c76:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003c78:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c7a:	4c05                	li	s8,1
    80003c7c:	a865                	j	80003d34 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c7e:	4585                	li	a1,1
    80003c80:	4505                	li	a0,1
    80003c82:	fffff097          	auipc	ra,0xfffff
    80003c86:	6e8080e7          	jalr	1768(ra) # 8000336a <iget>
    80003c8a:	89aa                	mv	s3,a0
    80003c8c:	b7dd                	j	80003c72 <namex+0x42>
      iunlockput(ip);
    80003c8e:	854e                	mv	a0,s3
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	c70080e7          	jalr	-912(ra) # 80003900 <iunlockput>
      return 0;
    80003c98:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c9a:	854e                	mv	a0,s3
    80003c9c:	60e6                	ld	ra,88(sp)
    80003c9e:	6446                	ld	s0,80(sp)
    80003ca0:	64a6                	ld	s1,72(sp)
    80003ca2:	6906                	ld	s2,64(sp)
    80003ca4:	79e2                	ld	s3,56(sp)
    80003ca6:	7a42                	ld	s4,48(sp)
    80003ca8:	7aa2                	ld	s5,40(sp)
    80003caa:	7b02                	ld	s6,32(sp)
    80003cac:	6be2                	ld	s7,24(sp)
    80003cae:	6c42                	ld	s8,16(sp)
    80003cb0:	6ca2                	ld	s9,8(sp)
    80003cb2:	6125                	addi	sp,sp,96
    80003cb4:	8082                	ret
      iunlock(ip);
    80003cb6:	854e                	mv	a0,s3
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	aa8080e7          	jalr	-1368(ra) # 80003760 <iunlock>
      return ip;
    80003cc0:	bfe9                	j	80003c9a <namex+0x6a>
      iunlockput(ip);
    80003cc2:	854e                	mv	a0,s3
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	c3c080e7          	jalr	-964(ra) # 80003900 <iunlockput>
      return 0;
    80003ccc:	89d2                	mv	s3,s4
    80003cce:	b7f1                	j	80003c9a <namex+0x6a>
  len = path - s;
    80003cd0:	40b48633          	sub	a2,s1,a1
    80003cd4:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003cd8:	094cd463          	bge	s9,s4,80003d60 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003cdc:	4639                	li	a2,14
    80003cde:	8556                	mv	a0,s5
    80003ce0:	ffffd097          	auipc	ra,0xffffd
    80003ce4:	08c080e7          	jalr	140(ra) # 80000d6c <memmove>
  while(*path == '/')
    80003ce8:	0004c783          	lbu	a5,0(s1)
    80003cec:	01279763          	bne	a5,s2,80003cfa <namex+0xca>
    path++;
    80003cf0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cf2:	0004c783          	lbu	a5,0(s1)
    80003cf6:	ff278de3          	beq	a5,s2,80003cf0 <namex+0xc0>
    ilock(ip);
    80003cfa:	854e                	mv	a0,s3
    80003cfc:	00000097          	auipc	ra,0x0
    80003d00:	9a2080e7          	jalr	-1630(ra) # 8000369e <ilock>
    if(ip->type != T_DIR){
    80003d04:	04499783          	lh	a5,68(s3)
    80003d08:	f98793e3          	bne	a5,s8,80003c8e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d0c:	000b0563          	beqz	s6,80003d16 <namex+0xe6>
    80003d10:	0004c783          	lbu	a5,0(s1)
    80003d14:	d3cd                	beqz	a5,80003cb6 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d16:	865e                	mv	a2,s7
    80003d18:	85d6                	mv	a1,s5
    80003d1a:	854e                	mv	a0,s3
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	e64080e7          	jalr	-412(ra) # 80003b80 <dirlookup>
    80003d24:	8a2a                	mv	s4,a0
    80003d26:	dd51                	beqz	a0,80003cc2 <namex+0x92>
    iunlockput(ip);
    80003d28:	854e                	mv	a0,s3
    80003d2a:	00000097          	auipc	ra,0x0
    80003d2e:	bd6080e7          	jalr	-1066(ra) # 80003900 <iunlockput>
    ip = next;
    80003d32:	89d2                	mv	s3,s4
  while(*path == '/')
    80003d34:	0004c783          	lbu	a5,0(s1)
    80003d38:	05279763          	bne	a5,s2,80003d86 <namex+0x156>
    path++;
    80003d3c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d3e:	0004c783          	lbu	a5,0(s1)
    80003d42:	ff278de3          	beq	a5,s2,80003d3c <namex+0x10c>
  if(*path == 0)
    80003d46:	c79d                	beqz	a5,80003d74 <namex+0x144>
    path++;
    80003d48:	85a6                	mv	a1,s1
  len = path - s;
    80003d4a:	8a5e                	mv	s4,s7
    80003d4c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d4e:	01278963          	beq	a5,s2,80003d60 <namex+0x130>
    80003d52:	dfbd                	beqz	a5,80003cd0 <namex+0xa0>
    path++;
    80003d54:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d56:	0004c783          	lbu	a5,0(s1)
    80003d5a:	ff279ce3          	bne	a5,s2,80003d52 <namex+0x122>
    80003d5e:	bf8d                	j	80003cd0 <namex+0xa0>
    memmove(name, s, len);
    80003d60:	2601                	sext.w	a2,a2
    80003d62:	8556                	mv	a0,s5
    80003d64:	ffffd097          	auipc	ra,0xffffd
    80003d68:	008080e7          	jalr	8(ra) # 80000d6c <memmove>
    name[len] = 0;
    80003d6c:	9a56                	add	s4,s4,s5
    80003d6e:	000a0023          	sb	zero,0(s4)
    80003d72:	bf9d                	j	80003ce8 <namex+0xb8>
  if(nameiparent){
    80003d74:	f20b03e3          	beqz	s6,80003c9a <namex+0x6a>
    iput(ip);
    80003d78:	854e                	mv	a0,s3
    80003d7a:	00000097          	auipc	ra,0x0
    80003d7e:	ade080e7          	jalr	-1314(ra) # 80003858 <iput>
    return 0;
    80003d82:	4981                	li	s3,0
    80003d84:	bf19                	j	80003c9a <namex+0x6a>
  if(*path == 0)
    80003d86:	d7fd                	beqz	a5,80003d74 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003d88:	0004c783          	lbu	a5,0(s1)
    80003d8c:	85a6                	mv	a1,s1
    80003d8e:	b7d1                	j	80003d52 <namex+0x122>

0000000080003d90 <dirlink>:
{
    80003d90:	7139                	addi	sp,sp,-64
    80003d92:	fc06                	sd	ra,56(sp)
    80003d94:	f822                	sd	s0,48(sp)
    80003d96:	f426                	sd	s1,40(sp)
    80003d98:	f04a                	sd	s2,32(sp)
    80003d9a:	ec4e                	sd	s3,24(sp)
    80003d9c:	e852                	sd	s4,16(sp)
    80003d9e:	0080                	addi	s0,sp,64
    80003da0:	892a                	mv	s2,a0
    80003da2:	8a2e                	mv	s4,a1
    80003da4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003da6:	4601                	li	a2,0
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	dd8080e7          	jalr	-552(ra) # 80003b80 <dirlookup>
    80003db0:	e93d                	bnez	a0,80003e26 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003db2:	04c92483          	lw	s1,76(s2)
    80003db6:	c49d                	beqz	s1,80003de4 <dirlink+0x54>
    80003db8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dba:	4741                	li	a4,16
    80003dbc:	86a6                	mv	a3,s1
    80003dbe:	fc040613          	addi	a2,s0,-64
    80003dc2:	4581                	li	a1,0
    80003dc4:	854a                	mv	a0,s2
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	b8c080e7          	jalr	-1140(ra) # 80003952 <readi>
    80003dce:	47c1                	li	a5,16
    80003dd0:	06f51163          	bne	a0,a5,80003e32 <dirlink+0xa2>
    if(de.inum == 0)
    80003dd4:	fc045783          	lhu	a5,-64(s0)
    80003dd8:	c791                	beqz	a5,80003de4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dda:	24c1                	addiw	s1,s1,16
    80003ddc:	04c92783          	lw	a5,76(s2)
    80003de0:	fcf4ede3          	bltu	s1,a5,80003dba <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003de4:	4639                	li	a2,14
    80003de6:	85d2                	mv	a1,s4
    80003de8:	fc240513          	addi	a0,s0,-62
    80003dec:	ffffd097          	auipc	ra,0xffffd
    80003df0:	038080e7          	jalr	56(ra) # 80000e24 <strncpy>
  de.inum = inum;
    80003df4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003df8:	4741                	li	a4,16
    80003dfa:	86a6                	mv	a3,s1
    80003dfc:	fc040613          	addi	a2,s0,-64
    80003e00:	4581                	li	a1,0
    80003e02:	854a                	mv	a0,s2
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	c46080e7          	jalr	-954(ra) # 80003a4a <writei>
    80003e0c:	872a                	mv	a4,a0
    80003e0e:	47c1                	li	a5,16
  return 0;
    80003e10:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e12:	02f71863          	bne	a4,a5,80003e42 <dirlink+0xb2>
}
    80003e16:	70e2                	ld	ra,56(sp)
    80003e18:	7442                	ld	s0,48(sp)
    80003e1a:	74a2                	ld	s1,40(sp)
    80003e1c:	7902                	ld	s2,32(sp)
    80003e1e:	69e2                	ld	s3,24(sp)
    80003e20:	6a42                	ld	s4,16(sp)
    80003e22:	6121                	addi	sp,sp,64
    80003e24:	8082                	ret
    iput(ip);
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	a32080e7          	jalr	-1486(ra) # 80003858 <iput>
    return -1;
    80003e2e:	557d                	li	a0,-1
    80003e30:	b7dd                	j	80003e16 <dirlink+0x86>
      panic("dirlink read");
    80003e32:	00004517          	auipc	a0,0x4
    80003e36:	74650513          	addi	a0,a0,1862 # 80008578 <syscalls+0x1c8>
    80003e3a:	ffffc097          	auipc	ra,0xffffc
    80003e3e:	70e080e7          	jalr	1806(ra) # 80000548 <panic>
    panic("dirlink");
    80003e42:	00005517          	auipc	a0,0x5
    80003e46:	85650513          	addi	a0,a0,-1962 # 80008698 <syscalls+0x2e8>
    80003e4a:	ffffc097          	auipc	ra,0xffffc
    80003e4e:	6fe080e7          	jalr	1790(ra) # 80000548 <panic>

0000000080003e52 <namei>:

struct inode*
namei(char *path)
{
    80003e52:	1101                	addi	sp,sp,-32
    80003e54:	ec06                	sd	ra,24(sp)
    80003e56:	e822                	sd	s0,16(sp)
    80003e58:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e5a:	fe040613          	addi	a2,s0,-32
    80003e5e:	4581                	li	a1,0
    80003e60:	00000097          	auipc	ra,0x0
    80003e64:	dd0080e7          	jalr	-560(ra) # 80003c30 <namex>
}
    80003e68:	60e2                	ld	ra,24(sp)
    80003e6a:	6442                	ld	s0,16(sp)
    80003e6c:	6105                	addi	sp,sp,32
    80003e6e:	8082                	ret

0000000080003e70 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e70:	1141                	addi	sp,sp,-16
    80003e72:	e406                	sd	ra,8(sp)
    80003e74:	e022                	sd	s0,0(sp)
    80003e76:	0800                	addi	s0,sp,16
    80003e78:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e7a:	4585                	li	a1,1
    80003e7c:	00000097          	auipc	ra,0x0
    80003e80:	db4080e7          	jalr	-588(ra) # 80003c30 <namex>
}
    80003e84:	60a2                	ld	ra,8(sp)
    80003e86:	6402                	ld	s0,0(sp)
    80003e88:	0141                	addi	sp,sp,16
    80003e8a:	8082                	ret

0000000080003e8c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e8c:	1101                	addi	sp,sp,-32
    80003e8e:	ec06                	sd	ra,24(sp)
    80003e90:	e822                	sd	s0,16(sp)
    80003e92:	e426                	sd	s1,8(sp)
    80003e94:	e04a                	sd	s2,0(sp)
    80003e96:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e98:	0001e917          	auipc	s2,0x1e
    80003e9c:	a7090913          	addi	s2,s2,-1424 # 80021908 <log>
    80003ea0:	01892583          	lw	a1,24(s2)
    80003ea4:	02892503          	lw	a0,40(s2)
    80003ea8:	fffff097          	auipc	ra,0xfffff
    80003eac:	ff4080e7          	jalr	-12(ra) # 80002e9c <bread>
    80003eb0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003eb2:	02c92683          	lw	a3,44(s2)
    80003eb6:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003eb8:	02d05763          	blez	a3,80003ee6 <write_head+0x5a>
    80003ebc:	0001e797          	auipc	a5,0x1e
    80003ec0:	a7c78793          	addi	a5,a5,-1412 # 80021938 <log+0x30>
    80003ec4:	05c50713          	addi	a4,a0,92
    80003ec8:	36fd                	addiw	a3,a3,-1
    80003eca:	1682                	slli	a3,a3,0x20
    80003ecc:	9281                	srli	a3,a3,0x20
    80003ece:	068a                	slli	a3,a3,0x2
    80003ed0:	0001e617          	auipc	a2,0x1e
    80003ed4:	a6c60613          	addi	a2,a2,-1428 # 8002193c <log+0x34>
    80003ed8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003eda:	4390                	lw	a2,0(a5)
    80003edc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ede:	0791                	addi	a5,a5,4
    80003ee0:	0711                	addi	a4,a4,4
    80003ee2:	fed79ce3          	bne	a5,a3,80003eda <write_head+0x4e>
  }
  bwrite(buf);
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	fffff097          	auipc	ra,0xfffff
    80003eec:	0a6080e7          	jalr	166(ra) # 80002f8e <bwrite>
  brelse(buf);
    80003ef0:	8526                	mv	a0,s1
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	0da080e7          	jalr	218(ra) # 80002fcc <brelse>
}
    80003efa:	60e2                	ld	ra,24(sp)
    80003efc:	6442                	ld	s0,16(sp)
    80003efe:	64a2                	ld	s1,8(sp)
    80003f00:	6902                	ld	s2,0(sp)
    80003f02:	6105                	addi	sp,sp,32
    80003f04:	8082                	ret

0000000080003f06 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f06:	0001e797          	auipc	a5,0x1e
    80003f0a:	a2e7a783          	lw	a5,-1490(a5) # 80021934 <log+0x2c>
    80003f0e:	0af05663          	blez	a5,80003fba <install_trans+0xb4>
{
    80003f12:	7139                	addi	sp,sp,-64
    80003f14:	fc06                	sd	ra,56(sp)
    80003f16:	f822                	sd	s0,48(sp)
    80003f18:	f426                	sd	s1,40(sp)
    80003f1a:	f04a                	sd	s2,32(sp)
    80003f1c:	ec4e                	sd	s3,24(sp)
    80003f1e:	e852                	sd	s4,16(sp)
    80003f20:	e456                	sd	s5,8(sp)
    80003f22:	0080                	addi	s0,sp,64
    80003f24:	0001ea97          	auipc	s5,0x1e
    80003f28:	a14a8a93          	addi	s5,s5,-1516 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f2c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f2e:	0001e997          	auipc	s3,0x1e
    80003f32:	9da98993          	addi	s3,s3,-1574 # 80021908 <log>
    80003f36:	0189a583          	lw	a1,24(s3)
    80003f3a:	014585bb          	addw	a1,a1,s4
    80003f3e:	2585                	addiw	a1,a1,1
    80003f40:	0289a503          	lw	a0,40(s3)
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	f58080e7          	jalr	-168(ra) # 80002e9c <bread>
    80003f4c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f4e:	000aa583          	lw	a1,0(s5)
    80003f52:	0289a503          	lw	a0,40(s3)
    80003f56:	fffff097          	auipc	ra,0xfffff
    80003f5a:	f46080e7          	jalr	-186(ra) # 80002e9c <bread>
    80003f5e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f60:	40000613          	li	a2,1024
    80003f64:	05890593          	addi	a1,s2,88
    80003f68:	05850513          	addi	a0,a0,88
    80003f6c:	ffffd097          	auipc	ra,0xffffd
    80003f70:	e00080e7          	jalr	-512(ra) # 80000d6c <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f74:	8526                	mv	a0,s1
    80003f76:	fffff097          	auipc	ra,0xfffff
    80003f7a:	018080e7          	jalr	24(ra) # 80002f8e <bwrite>
    bunpin(dbuf);
    80003f7e:	8526                	mv	a0,s1
    80003f80:	fffff097          	auipc	ra,0xfffff
    80003f84:	126080e7          	jalr	294(ra) # 800030a6 <bunpin>
    brelse(lbuf);
    80003f88:	854a                	mv	a0,s2
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	042080e7          	jalr	66(ra) # 80002fcc <brelse>
    brelse(dbuf);
    80003f92:	8526                	mv	a0,s1
    80003f94:	fffff097          	auipc	ra,0xfffff
    80003f98:	038080e7          	jalr	56(ra) # 80002fcc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f9c:	2a05                	addiw	s4,s4,1
    80003f9e:	0a91                	addi	s5,s5,4
    80003fa0:	02c9a783          	lw	a5,44(s3)
    80003fa4:	f8fa49e3          	blt	s4,a5,80003f36 <install_trans+0x30>
}
    80003fa8:	70e2                	ld	ra,56(sp)
    80003faa:	7442                	ld	s0,48(sp)
    80003fac:	74a2                	ld	s1,40(sp)
    80003fae:	7902                	ld	s2,32(sp)
    80003fb0:	69e2                	ld	s3,24(sp)
    80003fb2:	6a42                	ld	s4,16(sp)
    80003fb4:	6aa2                	ld	s5,8(sp)
    80003fb6:	6121                	addi	sp,sp,64
    80003fb8:	8082                	ret
    80003fba:	8082                	ret

0000000080003fbc <initlog>:
{
    80003fbc:	7179                	addi	sp,sp,-48
    80003fbe:	f406                	sd	ra,40(sp)
    80003fc0:	f022                	sd	s0,32(sp)
    80003fc2:	ec26                	sd	s1,24(sp)
    80003fc4:	e84a                	sd	s2,16(sp)
    80003fc6:	e44e                	sd	s3,8(sp)
    80003fc8:	1800                	addi	s0,sp,48
    80003fca:	892a                	mv	s2,a0
    80003fcc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fce:	0001e497          	auipc	s1,0x1e
    80003fd2:	93a48493          	addi	s1,s1,-1734 # 80021908 <log>
    80003fd6:	00004597          	auipc	a1,0x4
    80003fda:	5b258593          	addi	a1,a1,1458 # 80008588 <syscalls+0x1d8>
    80003fde:	8526                	mv	a0,s1
    80003fe0:	ffffd097          	auipc	ra,0xffffd
    80003fe4:	ba0080e7          	jalr	-1120(ra) # 80000b80 <initlock>
  log.start = sb->logstart;
    80003fe8:	0149a583          	lw	a1,20(s3)
    80003fec:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003fee:	0109a783          	lw	a5,16(s3)
    80003ff2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ff4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ff8:	854a                	mv	a0,s2
    80003ffa:	fffff097          	auipc	ra,0xfffff
    80003ffe:	ea2080e7          	jalr	-350(ra) # 80002e9c <bread>
  log.lh.n = lh->n;
    80004002:	4d3c                	lw	a5,88(a0)
    80004004:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004006:	02f05563          	blez	a5,80004030 <initlog+0x74>
    8000400a:	05c50713          	addi	a4,a0,92
    8000400e:	0001e697          	auipc	a3,0x1e
    80004012:	92a68693          	addi	a3,a3,-1750 # 80021938 <log+0x30>
    80004016:	37fd                	addiw	a5,a5,-1
    80004018:	1782                	slli	a5,a5,0x20
    8000401a:	9381                	srli	a5,a5,0x20
    8000401c:	078a                	slli	a5,a5,0x2
    8000401e:	06050613          	addi	a2,a0,96
    80004022:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004024:	4310                	lw	a2,0(a4)
    80004026:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004028:	0711                	addi	a4,a4,4
    8000402a:	0691                	addi	a3,a3,4
    8000402c:	fef71ce3          	bne	a4,a5,80004024 <initlog+0x68>
  brelse(buf);
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	f9c080e7          	jalr	-100(ra) # 80002fcc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004038:	00000097          	auipc	ra,0x0
    8000403c:	ece080e7          	jalr	-306(ra) # 80003f06 <install_trans>
  log.lh.n = 0;
    80004040:	0001e797          	auipc	a5,0x1e
    80004044:	8e07aa23          	sw	zero,-1804(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    80004048:	00000097          	auipc	ra,0x0
    8000404c:	e44080e7          	jalr	-444(ra) # 80003e8c <write_head>
}
    80004050:	70a2                	ld	ra,40(sp)
    80004052:	7402                	ld	s0,32(sp)
    80004054:	64e2                	ld	s1,24(sp)
    80004056:	6942                	ld	s2,16(sp)
    80004058:	69a2                	ld	s3,8(sp)
    8000405a:	6145                	addi	sp,sp,48
    8000405c:	8082                	ret

000000008000405e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000405e:	1101                	addi	sp,sp,-32
    80004060:	ec06                	sd	ra,24(sp)
    80004062:	e822                	sd	s0,16(sp)
    80004064:	e426                	sd	s1,8(sp)
    80004066:	e04a                	sd	s2,0(sp)
    80004068:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000406a:	0001e517          	auipc	a0,0x1e
    8000406e:	89e50513          	addi	a0,a0,-1890 # 80021908 <log>
    80004072:	ffffd097          	auipc	ra,0xffffd
    80004076:	b9e080e7          	jalr	-1122(ra) # 80000c10 <acquire>
  while(1){
    if(log.committing){
    8000407a:	0001e497          	auipc	s1,0x1e
    8000407e:	88e48493          	addi	s1,s1,-1906 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004082:	4979                	li	s2,30
    80004084:	a039                	j	80004092 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004086:	85a6                	mv	a1,s1
    80004088:	8526                	mv	a0,s1
    8000408a:	ffffe097          	auipc	ra,0xffffe
    8000408e:	182080e7          	jalr	386(ra) # 8000220c <sleep>
    if(log.committing){
    80004092:	50dc                	lw	a5,36(s1)
    80004094:	fbed                	bnez	a5,80004086 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004096:	509c                	lw	a5,32(s1)
    80004098:	0017871b          	addiw	a4,a5,1
    8000409c:	0007069b          	sext.w	a3,a4
    800040a0:	0027179b          	slliw	a5,a4,0x2
    800040a4:	9fb9                	addw	a5,a5,a4
    800040a6:	0017979b          	slliw	a5,a5,0x1
    800040aa:	54d8                	lw	a4,44(s1)
    800040ac:	9fb9                	addw	a5,a5,a4
    800040ae:	00f95963          	bge	s2,a5,800040c0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040b2:	85a6                	mv	a1,s1
    800040b4:	8526                	mv	a0,s1
    800040b6:	ffffe097          	auipc	ra,0xffffe
    800040ba:	156080e7          	jalr	342(ra) # 8000220c <sleep>
    800040be:	bfd1                	j	80004092 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040c0:	0001e517          	auipc	a0,0x1e
    800040c4:	84850513          	addi	a0,a0,-1976 # 80021908 <log>
    800040c8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040ca:	ffffd097          	auipc	ra,0xffffd
    800040ce:	bfa080e7          	jalr	-1030(ra) # 80000cc4 <release>
      break;
    }
  }
}
    800040d2:	60e2                	ld	ra,24(sp)
    800040d4:	6442                	ld	s0,16(sp)
    800040d6:	64a2                	ld	s1,8(sp)
    800040d8:	6902                	ld	s2,0(sp)
    800040da:	6105                	addi	sp,sp,32
    800040dc:	8082                	ret

00000000800040de <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040de:	7139                	addi	sp,sp,-64
    800040e0:	fc06                	sd	ra,56(sp)
    800040e2:	f822                	sd	s0,48(sp)
    800040e4:	f426                	sd	s1,40(sp)
    800040e6:	f04a                	sd	s2,32(sp)
    800040e8:	ec4e                	sd	s3,24(sp)
    800040ea:	e852                	sd	s4,16(sp)
    800040ec:	e456                	sd	s5,8(sp)
    800040ee:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040f0:	0001e497          	auipc	s1,0x1e
    800040f4:	81848493          	addi	s1,s1,-2024 # 80021908 <log>
    800040f8:	8526                	mv	a0,s1
    800040fa:	ffffd097          	auipc	ra,0xffffd
    800040fe:	b16080e7          	jalr	-1258(ra) # 80000c10 <acquire>
  log.outstanding -= 1;
    80004102:	509c                	lw	a5,32(s1)
    80004104:	37fd                	addiw	a5,a5,-1
    80004106:	0007891b          	sext.w	s2,a5
    8000410a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000410c:	50dc                	lw	a5,36(s1)
    8000410e:	efb9                	bnez	a5,8000416c <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004110:	06091663          	bnez	s2,8000417c <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004114:	0001d497          	auipc	s1,0x1d
    80004118:	7f448493          	addi	s1,s1,2036 # 80021908 <log>
    8000411c:	4785                	li	a5,1
    8000411e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004120:	8526                	mv	a0,s1
    80004122:	ffffd097          	auipc	ra,0xffffd
    80004126:	ba2080e7          	jalr	-1118(ra) # 80000cc4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000412a:	54dc                	lw	a5,44(s1)
    8000412c:	06f04763          	bgtz	a5,8000419a <end_op+0xbc>
    acquire(&log.lock);
    80004130:	0001d497          	auipc	s1,0x1d
    80004134:	7d848493          	addi	s1,s1,2008 # 80021908 <log>
    80004138:	8526                	mv	a0,s1
    8000413a:	ffffd097          	auipc	ra,0xffffd
    8000413e:	ad6080e7          	jalr	-1322(ra) # 80000c10 <acquire>
    log.committing = 0;
    80004142:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004146:	8526                	mv	a0,s1
    80004148:	ffffe097          	auipc	ra,0xffffe
    8000414c:	24a080e7          	jalr	586(ra) # 80002392 <wakeup>
    release(&log.lock);
    80004150:	8526                	mv	a0,s1
    80004152:	ffffd097          	auipc	ra,0xffffd
    80004156:	b72080e7          	jalr	-1166(ra) # 80000cc4 <release>
}
    8000415a:	70e2                	ld	ra,56(sp)
    8000415c:	7442                	ld	s0,48(sp)
    8000415e:	74a2                	ld	s1,40(sp)
    80004160:	7902                	ld	s2,32(sp)
    80004162:	69e2                	ld	s3,24(sp)
    80004164:	6a42                	ld	s4,16(sp)
    80004166:	6aa2                	ld	s5,8(sp)
    80004168:	6121                	addi	sp,sp,64
    8000416a:	8082                	ret
    panic("log.committing");
    8000416c:	00004517          	auipc	a0,0x4
    80004170:	42450513          	addi	a0,a0,1060 # 80008590 <syscalls+0x1e0>
    80004174:	ffffc097          	auipc	ra,0xffffc
    80004178:	3d4080e7          	jalr	980(ra) # 80000548 <panic>
    wakeup(&log);
    8000417c:	0001d497          	auipc	s1,0x1d
    80004180:	78c48493          	addi	s1,s1,1932 # 80021908 <log>
    80004184:	8526                	mv	a0,s1
    80004186:	ffffe097          	auipc	ra,0xffffe
    8000418a:	20c080e7          	jalr	524(ra) # 80002392 <wakeup>
  release(&log.lock);
    8000418e:	8526                	mv	a0,s1
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	b34080e7          	jalr	-1228(ra) # 80000cc4 <release>
  if(do_commit){
    80004198:	b7c9                	j	8000415a <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000419a:	0001da97          	auipc	s5,0x1d
    8000419e:	79ea8a93          	addi	s5,s5,1950 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041a2:	0001da17          	auipc	s4,0x1d
    800041a6:	766a0a13          	addi	s4,s4,1894 # 80021908 <log>
    800041aa:	018a2583          	lw	a1,24(s4)
    800041ae:	012585bb          	addw	a1,a1,s2
    800041b2:	2585                	addiw	a1,a1,1
    800041b4:	028a2503          	lw	a0,40(s4)
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	ce4080e7          	jalr	-796(ra) # 80002e9c <bread>
    800041c0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041c2:	000aa583          	lw	a1,0(s5)
    800041c6:	028a2503          	lw	a0,40(s4)
    800041ca:	fffff097          	auipc	ra,0xfffff
    800041ce:	cd2080e7          	jalr	-814(ra) # 80002e9c <bread>
    800041d2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041d4:	40000613          	li	a2,1024
    800041d8:	05850593          	addi	a1,a0,88
    800041dc:	05848513          	addi	a0,s1,88
    800041e0:	ffffd097          	auipc	ra,0xffffd
    800041e4:	b8c080e7          	jalr	-1140(ra) # 80000d6c <memmove>
    bwrite(to);  // write the log
    800041e8:	8526                	mv	a0,s1
    800041ea:	fffff097          	auipc	ra,0xfffff
    800041ee:	da4080e7          	jalr	-604(ra) # 80002f8e <bwrite>
    brelse(from);
    800041f2:	854e                	mv	a0,s3
    800041f4:	fffff097          	auipc	ra,0xfffff
    800041f8:	dd8080e7          	jalr	-552(ra) # 80002fcc <brelse>
    brelse(to);
    800041fc:	8526                	mv	a0,s1
    800041fe:	fffff097          	auipc	ra,0xfffff
    80004202:	dce080e7          	jalr	-562(ra) # 80002fcc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004206:	2905                	addiw	s2,s2,1
    80004208:	0a91                	addi	s5,s5,4
    8000420a:	02ca2783          	lw	a5,44(s4)
    8000420e:	f8f94ee3          	blt	s2,a5,800041aa <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004212:	00000097          	auipc	ra,0x0
    80004216:	c7a080e7          	jalr	-902(ra) # 80003e8c <write_head>
    install_trans(); // Now install writes to home locations
    8000421a:	00000097          	auipc	ra,0x0
    8000421e:	cec080e7          	jalr	-788(ra) # 80003f06 <install_trans>
    log.lh.n = 0;
    80004222:	0001d797          	auipc	a5,0x1d
    80004226:	7007a923          	sw	zero,1810(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000422a:	00000097          	auipc	ra,0x0
    8000422e:	c62080e7          	jalr	-926(ra) # 80003e8c <write_head>
    80004232:	bdfd                	j	80004130 <end_op+0x52>

0000000080004234 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004234:	1101                	addi	sp,sp,-32
    80004236:	ec06                	sd	ra,24(sp)
    80004238:	e822                	sd	s0,16(sp)
    8000423a:	e426                	sd	s1,8(sp)
    8000423c:	e04a                	sd	s2,0(sp)
    8000423e:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004240:	0001d717          	auipc	a4,0x1d
    80004244:	6f472703          	lw	a4,1780(a4) # 80021934 <log+0x2c>
    80004248:	47f5                	li	a5,29
    8000424a:	08e7c063          	blt	a5,a4,800042ca <log_write+0x96>
    8000424e:	84aa                	mv	s1,a0
    80004250:	0001d797          	auipc	a5,0x1d
    80004254:	6d47a783          	lw	a5,1748(a5) # 80021924 <log+0x1c>
    80004258:	37fd                	addiw	a5,a5,-1
    8000425a:	06f75863          	bge	a4,a5,800042ca <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000425e:	0001d797          	auipc	a5,0x1d
    80004262:	6ca7a783          	lw	a5,1738(a5) # 80021928 <log+0x20>
    80004266:	06f05a63          	blez	a5,800042da <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000426a:	0001d917          	auipc	s2,0x1d
    8000426e:	69e90913          	addi	s2,s2,1694 # 80021908 <log>
    80004272:	854a                	mv	a0,s2
    80004274:	ffffd097          	auipc	ra,0xffffd
    80004278:	99c080e7          	jalr	-1636(ra) # 80000c10 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000427c:	02c92603          	lw	a2,44(s2)
    80004280:	06c05563          	blez	a2,800042ea <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004284:	44cc                	lw	a1,12(s1)
    80004286:	0001d717          	auipc	a4,0x1d
    8000428a:	6b270713          	addi	a4,a4,1714 # 80021938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000428e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004290:	4314                	lw	a3,0(a4)
    80004292:	04b68d63          	beq	a3,a1,800042ec <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004296:	2785                	addiw	a5,a5,1
    80004298:	0711                	addi	a4,a4,4
    8000429a:	fec79be3          	bne	a5,a2,80004290 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000429e:	0621                	addi	a2,a2,8
    800042a0:	060a                	slli	a2,a2,0x2
    800042a2:	0001d797          	auipc	a5,0x1d
    800042a6:	66678793          	addi	a5,a5,1638 # 80021908 <log>
    800042aa:	963e                	add	a2,a2,a5
    800042ac:	44dc                	lw	a5,12(s1)
    800042ae:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042b0:	8526                	mv	a0,s1
    800042b2:	fffff097          	auipc	ra,0xfffff
    800042b6:	db8080e7          	jalr	-584(ra) # 8000306a <bpin>
    log.lh.n++;
    800042ba:	0001d717          	auipc	a4,0x1d
    800042be:	64e70713          	addi	a4,a4,1614 # 80021908 <log>
    800042c2:	575c                	lw	a5,44(a4)
    800042c4:	2785                	addiw	a5,a5,1
    800042c6:	d75c                	sw	a5,44(a4)
    800042c8:	a83d                	j	80004306 <log_write+0xd2>
    panic("too big a transaction");
    800042ca:	00004517          	auipc	a0,0x4
    800042ce:	2d650513          	addi	a0,a0,726 # 800085a0 <syscalls+0x1f0>
    800042d2:	ffffc097          	auipc	ra,0xffffc
    800042d6:	276080e7          	jalr	630(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    800042da:	00004517          	auipc	a0,0x4
    800042de:	2de50513          	addi	a0,a0,734 # 800085b8 <syscalls+0x208>
    800042e2:	ffffc097          	auipc	ra,0xffffc
    800042e6:	266080e7          	jalr	614(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800042ea:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800042ec:	00878713          	addi	a4,a5,8
    800042f0:	00271693          	slli	a3,a4,0x2
    800042f4:	0001d717          	auipc	a4,0x1d
    800042f8:	61470713          	addi	a4,a4,1556 # 80021908 <log>
    800042fc:	9736                	add	a4,a4,a3
    800042fe:	44d4                	lw	a3,12(s1)
    80004300:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004302:	faf607e3          	beq	a2,a5,800042b0 <log_write+0x7c>
  }
  release(&log.lock);
    80004306:	0001d517          	auipc	a0,0x1d
    8000430a:	60250513          	addi	a0,a0,1538 # 80021908 <log>
    8000430e:	ffffd097          	auipc	ra,0xffffd
    80004312:	9b6080e7          	jalr	-1610(ra) # 80000cc4 <release>
}
    80004316:	60e2                	ld	ra,24(sp)
    80004318:	6442                	ld	s0,16(sp)
    8000431a:	64a2                	ld	s1,8(sp)
    8000431c:	6902                	ld	s2,0(sp)
    8000431e:	6105                	addi	sp,sp,32
    80004320:	8082                	ret

0000000080004322 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004322:	1101                	addi	sp,sp,-32
    80004324:	ec06                	sd	ra,24(sp)
    80004326:	e822                	sd	s0,16(sp)
    80004328:	e426                	sd	s1,8(sp)
    8000432a:	e04a                	sd	s2,0(sp)
    8000432c:	1000                	addi	s0,sp,32
    8000432e:	84aa                	mv	s1,a0
    80004330:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004332:	00004597          	auipc	a1,0x4
    80004336:	2a658593          	addi	a1,a1,678 # 800085d8 <syscalls+0x228>
    8000433a:	0521                	addi	a0,a0,8
    8000433c:	ffffd097          	auipc	ra,0xffffd
    80004340:	844080e7          	jalr	-1980(ra) # 80000b80 <initlock>
  lk->name = name;
    80004344:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004348:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000434c:	0204a423          	sw	zero,40(s1)
}
    80004350:	60e2                	ld	ra,24(sp)
    80004352:	6442                	ld	s0,16(sp)
    80004354:	64a2                	ld	s1,8(sp)
    80004356:	6902                	ld	s2,0(sp)
    80004358:	6105                	addi	sp,sp,32
    8000435a:	8082                	ret

000000008000435c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	e04a                	sd	s2,0(sp)
    80004366:	1000                	addi	s0,sp,32
    80004368:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000436a:	00850913          	addi	s2,a0,8
    8000436e:	854a                	mv	a0,s2
    80004370:	ffffd097          	auipc	ra,0xffffd
    80004374:	8a0080e7          	jalr	-1888(ra) # 80000c10 <acquire>
  while (lk->locked) {
    80004378:	409c                	lw	a5,0(s1)
    8000437a:	cb89                	beqz	a5,8000438c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000437c:	85ca                	mv	a1,s2
    8000437e:	8526                	mv	a0,s1
    80004380:	ffffe097          	auipc	ra,0xffffe
    80004384:	e8c080e7          	jalr	-372(ra) # 8000220c <sleep>
  while (lk->locked) {
    80004388:	409c                	lw	a5,0(s1)
    8000438a:	fbed                	bnez	a5,8000437c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000438c:	4785                	li	a5,1
    8000438e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004390:	ffffd097          	auipc	ra,0xffffd
    80004394:	66c080e7          	jalr	1644(ra) # 800019fc <myproc>
    80004398:	5d1c                	lw	a5,56(a0)
    8000439a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000439c:	854a                	mv	a0,s2
    8000439e:	ffffd097          	auipc	ra,0xffffd
    800043a2:	926080e7          	jalr	-1754(ra) # 80000cc4 <release>
}
    800043a6:	60e2                	ld	ra,24(sp)
    800043a8:	6442                	ld	s0,16(sp)
    800043aa:	64a2                	ld	s1,8(sp)
    800043ac:	6902                	ld	s2,0(sp)
    800043ae:	6105                	addi	sp,sp,32
    800043b0:	8082                	ret

00000000800043b2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043b2:	1101                	addi	sp,sp,-32
    800043b4:	ec06                	sd	ra,24(sp)
    800043b6:	e822                	sd	s0,16(sp)
    800043b8:	e426                	sd	s1,8(sp)
    800043ba:	e04a                	sd	s2,0(sp)
    800043bc:	1000                	addi	s0,sp,32
    800043be:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043c0:	00850913          	addi	s2,a0,8
    800043c4:	854a                	mv	a0,s2
    800043c6:	ffffd097          	auipc	ra,0xffffd
    800043ca:	84a080e7          	jalr	-1974(ra) # 80000c10 <acquire>
  lk->locked = 0;
    800043ce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043d2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043d6:	8526                	mv	a0,s1
    800043d8:	ffffe097          	auipc	ra,0xffffe
    800043dc:	fba080e7          	jalr	-70(ra) # 80002392 <wakeup>
  release(&lk->lk);
    800043e0:	854a                	mv	a0,s2
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	8e2080e7          	jalr	-1822(ra) # 80000cc4 <release>
}
    800043ea:	60e2                	ld	ra,24(sp)
    800043ec:	6442                	ld	s0,16(sp)
    800043ee:	64a2                	ld	s1,8(sp)
    800043f0:	6902                	ld	s2,0(sp)
    800043f2:	6105                	addi	sp,sp,32
    800043f4:	8082                	ret

00000000800043f6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043f6:	7179                	addi	sp,sp,-48
    800043f8:	f406                	sd	ra,40(sp)
    800043fa:	f022                	sd	s0,32(sp)
    800043fc:	ec26                	sd	s1,24(sp)
    800043fe:	e84a                	sd	s2,16(sp)
    80004400:	e44e                	sd	s3,8(sp)
    80004402:	1800                	addi	s0,sp,48
    80004404:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004406:	00850913          	addi	s2,a0,8
    8000440a:	854a                	mv	a0,s2
    8000440c:	ffffd097          	auipc	ra,0xffffd
    80004410:	804080e7          	jalr	-2044(ra) # 80000c10 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004414:	409c                	lw	a5,0(s1)
    80004416:	ef99                	bnez	a5,80004434 <holdingsleep+0x3e>
    80004418:	4481                	li	s1,0
  release(&lk->lk);
    8000441a:	854a                	mv	a0,s2
    8000441c:	ffffd097          	auipc	ra,0xffffd
    80004420:	8a8080e7          	jalr	-1880(ra) # 80000cc4 <release>
  return r;
}
    80004424:	8526                	mv	a0,s1
    80004426:	70a2                	ld	ra,40(sp)
    80004428:	7402                	ld	s0,32(sp)
    8000442a:	64e2                	ld	s1,24(sp)
    8000442c:	6942                	ld	s2,16(sp)
    8000442e:	69a2                	ld	s3,8(sp)
    80004430:	6145                	addi	sp,sp,48
    80004432:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004434:	0284a983          	lw	s3,40(s1)
    80004438:	ffffd097          	auipc	ra,0xffffd
    8000443c:	5c4080e7          	jalr	1476(ra) # 800019fc <myproc>
    80004440:	5d04                	lw	s1,56(a0)
    80004442:	413484b3          	sub	s1,s1,s3
    80004446:	0014b493          	seqz	s1,s1
    8000444a:	bfc1                	j	8000441a <holdingsleep+0x24>

000000008000444c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000444c:	1141                	addi	sp,sp,-16
    8000444e:	e406                	sd	ra,8(sp)
    80004450:	e022                	sd	s0,0(sp)
    80004452:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004454:	00004597          	auipc	a1,0x4
    80004458:	19458593          	addi	a1,a1,404 # 800085e8 <syscalls+0x238>
    8000445c:	0001d517          	auipc	a0,0x1d
    80004460:	5f450513          	addi	a0,a0,1524 # 80021a50 <ftable>
    80004464:	ffffc097          	auipc	ra,0xffffc
    80004468:	71c080e7          	jalr	1820(ra) # 80000b80 <initlock>
}
    8000446c:	60a2                	ld	ra,8(sp)
    8000446e:	6402                	ld	s0,0(sp)
    80004470:	0141                	addi	sp,sp,16
    80004472:	8082                	ret

0000000080004474 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004474:	1101                	addi	sp,sp,-32
    80004476:	ec06                	sd	ra,24(sp)
    80004478:	e822                	sd	s0,16(sp)
    8000447a:	e426                	sd	s1,8(sp)
    8000447c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000447e:	0001d517          	auipc	a0,0x1d
    80004482:	5d250513          	addi	a0,a0,1490 # 80021a50 <ftable>
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	78a080e7          	jalr	1930(ra) # 80000c10 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000448e:	0001d497          	auipc	s1,0x1d
    80004492:	5da48493          	addi	s1,s1,1498 # 80021a68 <ftable+0x18>
    80004496:	0001e717          	auipc	a4,0x1e
    8000449a:	57270713          	addi	a4,a4,1394 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    8000449e:	40dc                	lw	a5,4(s1)
    800044a0:	cf99                	beqz	a5,800044be <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044a2:	02848493          	addi	s1,s1,40
    800044a6:	fee49ce3          	bne	s1,a4,8000449e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044aa:	0001d517          	auipc	a0,0x1d
    800044ae:	5a650513          	addi	a0,a0,1446 # 80021a50 <ftable>
    800044b2:	ffffd097          	auipc	ra,0xffffd
    800044b6:	812080e7          	jalr	-2030(ra) # 80000cc4 <release>
  return 0;
    800044ba:	4481                	li	s1,0
    800044bc:	a819                	j	800044d2 <filealloc+0x5e>
      f->ref = 1;
    800044be:	4785                	li	a5,1
    800044c0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044c2:	0001d517          	auipc	a0,0x1d
    800044c6:	58e50513          	addi	a0,a0,1422 # 80021a50 <ftable>
    800044ca:	ffffc097          	auipc	ra,0xffffc
    800044ce:	7fa080e7          	jalr	2042(ra) # 80000cc4 <release>
}
    800044d2:	8526                	mv	a0,s1
    800044d4:	60e2                	ld	ra,24(sp)
    800044d6:	6442                	ld	s0,16(sp)
    800044d8:	64a2                	ld	s1,8(sp)
    800044da:	6105                	addi	sp,sp,32
    800044dc:	8082                	ret

00000000800044de <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044de:	1101                	addi	sp,sp,-32
    800044e0:	ec06                	sd	ra,24(sp)
    800044e2:	e822                	sd	s0,16(sp)
    800044e4:	e426                	sd	s1,8(sp)
    800044e6:	1000                	addi	s0,sp,32
    800044e8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044ea:	0001d517          	auipc	a0,0x1d
    800044ee:	56650513          	addi	a0,a0,1382 # 80021a50 <ftable>
    800044f2:	ffffc097          	auipc	ra,0xffffc
    800044f6:	71e080e7          	jalr	1822(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    800044fa:	40dc                	lw	a5,4(s1)
    800044fc:	02f05263          	blez	a5,80004520 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004500:	2785                	addiw	a5,a5,1
    80004502:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004504:	0001d517          	auipc	a0,0x1d
    80004508:	54c50513          	addi	a0,a0,1356 # 80021a50 <ftable>
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	7b8080e7          	jalr	1976(ra) # 80000cc4 <release>
  return f;
}
    80004514:	8526                	mv	a0,s1
    80004516:	60e2                	ld	ra,24(sp)
    80004518:	6442                	ld	s0,16(sp)
    8000451a:	64a2                	ld	s1,8(sp)
    8000451c:	6105                	addi	sp,sp,32
    8000451e:	8082                	ret
    panic("filedup");
    80004520:	00004517          	auipc	a0,0x4
    80004524:	0d050513          	addi	a0,a0,208 # 800085f0 <syscalls+0x240>
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	020080e7          	jalr	32(ra) # 80000548 <panic>

0000000080004530 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004530:	7139                	addi	sp,sp,-64
    80004532:	fc06                	sd	ra,56(sp)
    80004534:	f822                	sd	s0,48(sp)
    80004536:	f426                	sd	s1,40(sp)
    80004538:	f04a                	sd	s2,32(sp)
    8000453a:	ec4e                	sd	s3,24(sp)
    8000453c:	e852                	sd	s4,16(sp)
    8000453e:	e456                	sd	s5,8(sp)
    80004540:	0080                	addi	s0,sp,64
    80004542:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004544:	0001d517          	auipc	a0,0x1d
    80004548:	50c50513          	addi	a0,a0,1292 # 80021a50 <ftable>
    8000454c:	ffffc097          	auipc	ra,0xffffc
    80004550:	6c4080e7          	jalr	1732(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    80004554:	40dc                	lw	a5,4(s1)
    80004556:	06f05163          	blez	a5,800045b8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000455a:	37fd                	addiw	a5,a5,-1
    8000455c:	0007871b          	sext.w	a4,a5
    80004560:	c0dc                	sw	a5,4(s1)
    80004562:	06e04363          	bgtz	a4,800045c8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004566:	0004a903          	lw	s2,0(s1)
    8000456a:	0094ca83          	lbu	s5,9(s1)
    8000456e:	0104ba03          	ld	s4,16(s1)
    80004572:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004576:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000457a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000457e:	0001d517          	auipc	a0,0x1d
    80004582:	4d250513          	addi	a0,a0,1234 # 80021a50 <ftable>
    80004586:	ffffc097          	auipc	ra,0xffffc
    8000458a:	73e080e7          	jalr	1854(ra) # 80000cc4 <release>

  if(ff.type == FD_PIPE){
    8000458e:	4785                	li	a5,1
    80004590:	04f90d63          	beq	s2,a5,800045ea <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004594:	3979                	addiw	s2,s2,-2
    80004596:	4785                	li	a5,1
    80004598:	0527e063          	bltu	a5,s2,800045d8 <fileclose+0xa8>
    begin_op();
    8000459c:	00000097          	auipc	ra,0x0
    800045a0:	ac2080e7          	jalr	-1342(ra) # 8000405e <begin_op>
    iput(ff.ip);
    800045a4:	854e                	mv	a0,s3
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	2b2080e7          	jalr	690(ra) # 80003858 <iput>
    end_op();
    800045ae:	00000097          	auipc	ra,0x0
    800045b2:	b30080e7          	jalr	-1232(ra) # 800040de <end_op>
    800045b6:	a00d                	j	800045d8 <fileclose+0xa8>
    panic("fileclose");
    800045b8:	00004517          	auipc	a0,0x4
    800045bc:	04050513          	addi	a0,a0,64 # 800085f8 <syscalls+0x248>
    800045c0:	ffffc097          	auipc	ra,0xffffc
    800045c4:	f88080e7          	jalr	-120(ra) # 80000548 <panic>
    release(&ftable.lock);
    800045c8:	0001d517          	auipc	a0,0x1d
    800045cc:	48850513          	addi	a0,a0,1160 # 80021a50 <ftable>
    800045d0:	ffffc097          	auipc	ra,0xffffc
    800045d4:	6f4080e7          	jalr	1780(ra) # 80000cc4 <release>
  }
}
    800045d8:	70e2                	ld	ra,56(sp)
    800045da:	7442                	ld	s0,48(sp)
    800045dc:	74a2                	ld	s1,40(sp)
    800045de:	7902                	ld	s2,32(sp)
    800045e0:	69e2                	ld	s3,24(sp)
    800045e2:	6a42                	ld	s4,16(sp)
    800045e4:	6aa2                	ld	s5,8(sp)
    800045e6:	6121                	addi	sp,sp,64
    800045e8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045ea:	85d6                	mv	a1,s5
    800045ec:	8552                	mv	a0,s4
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	372080e7          	jalr	882(ra) # 80004960 <pipeclose>
    800045f6:	b7cd                	j	800045d8 <fileclose+0xa8>

00000000800045f8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045f8:	715d                	addi	sp,sp,-80
    800045fa:	e486                	sd	ra,72(sp)
    800045fc:	e0a2                	sd	s0,64(sp)
    800045fe:	fc26                	sd	s1,56(sp)
    80004600:	f84a                	sd	s2,48(sp)
    80004602:	f44e                	sd	s3,40(sp)
    80004604:	0880                	addi	s0,sp,80
    80004606:	84aa                	mv	s1,a0
    80004608:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000460a:	ffffd097          	auipc	ra,0xffffd
    8000460e:	3f2080e7          	jalr	1010(ra) # 800019fc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004612:	409c                	lw	a5,0(s1)
    80004614:	37f9                	addiw	a5,a5,-2
    80004616:	4705                	li	a4,1
    80004618:	04f76763          	bltu	a4,a5,80004666 <filestat+0x6e>
    8000461c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000461e:	6c88                	ld	a0,24(s1)
    80004620:	fffff097          	auipc	ra,0xfffff
    80004624:	07e080e7          	jalr	126(ra) # 8000369e <ilock>
    stati(f->ip, &st);
    80004628:	fb840593          	addi	a1,s0,-72
    8000462c:	6c88                	ld	a0,24(s1)
    8000462e:	fffff097          	auipc	ra,0xfffff
    80004632:	2fa080e7          	jalr	762(ra) # 80003928 <stati>
    iunlock(f->ip);
    80004636:	6c88                	ld	a0,24(s1)
    80004638:	fffff097          	auipc	ra,0xfffff
    8000463c:	128080e7          	jalr	296(ra) # 80003760 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004640:	46e1                	li	a3,24
    80004642:	fb840613          	addi	a2,s0,-72
    80004646:	85ce                	mv	a1,s3
    80004648:	05093503          	ld	a0,80(s2)
    8000464c:	ffffd097          	auipc	ra,0xffffd
    80004650:	0a4080e7          	jalr	164(ra) # 800016f0 <copyout>
    80004654:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004658:	60a6                	ld	ra,72(sp)
    8000465a:	6406                	ld	s0,64(sp)
    8000465c:	74e2                	ld	s1,56(sp)
    8000465e:	7942                	ld	s2,48(sp)
    80004660:	79a2                	ld	s3,40(sp)
    80004662:	6161                	addi	sp,sp,80
    80004664:	8082                	ret
  return -1;
    80004666:	557d                	li	a0,-1
    80004668:	bfc5                	j	80004658 <filestat+0x60>

000000008000466a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000466a:	7179                	addi	sp,sp,-48
    8000466c:	f406                	sd	ra,40(sp)
    8000466e:	f022                	sd	s0,32(sp)
    80004670:	ec26                	sd	s1,24(sp)
    80004672:	e84a                	sd	s2,16(sp)
    80004674:	e44e                	sd	s3,8(sp)
    80004676:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004678:	00854783          	lbu	a5,8(a0)
    8000467c:	c3d5                	beqz	a5,80004720 <fileread+0xb6>
    8000467e:	84aa                	mv	s1,a0
    80004680:	89ae                	mv	s3,a1
    80004682:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004684:	411c                	lw	a5,0(a0)
    80004686:	4705                	li	a4,1
    80004688:	04e78963          	beq	a5,a4,800046da <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000468c:	470d                	li	a4,3
    8000468e:	04e78d63          	beq	a5,a4,800046e8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004692:	4709                	li	a4,2
    80004694:	06e79e63          	bne	a5,a4,80004710 <fileread+0xa6>
    ilock(f->ip);
    80004698:	6d08                	ld	a0,24(a0)
    8000469a:	fffff097          	auipc	ra,0xfffff
    8000469e:	004080e7          	jalr	4(ra) # 8000369e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046a2:	874a                	mv	a4,s2
    800046a4:	5094                	lw	a3,32(s1)
    800046a6:	864e                	mv	a2,s3
    800046a8:	4585                	li	a1,1
    800046aa:	6c88                	ld	a0,24(s1)
    800046ac:	fffff097          	auipc	ra,0xfffff
    800046b0:	2a6080e7          	jalr	678(ra) # 80003952 <readi>
    800046b4:	892a                	mv	s2,a0
    800046b6:	00a05563          	blez	a0,800046c0 <fileread+0x56>
      f->off += r;
    800046ba:	509c                	lw	a5,32(s1)
    800046bc:	9fa9                	addw	a5,a5,a0
    800046be:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046c0:	6c88                	ld	a0,24(s1)
    800046c2:	fffff097          	auipc	ra,0xfffff
    800046c6:	09e080e7          	jalr	158(ra) # 80003760 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046ca:	854a                	mv	a0,s2
    800046cc:	70a2                	ld	ra,40(sp)
    800046ce:	7402                	ld	s0,32(sp)
    800046d0:	64e2                	ld	s1,24(sp)
    800046d2:	6942                	ld	s2,16(sp)
    800046d4:	69a2                	ld	s3,8(sp)
    800046d6:	6145                	addi	sp,sp,48
    800046d8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046da:	6908                	ld	a0,16(a0)
    800046dc:	00000097          	auipc	ra,0x0
    800046e0:	418080e7          	jalr	1048(ra) # 80004af4 <piperead>
    800046e4:	892a                	mv	s2,a0
    800046e6:	b7d5                	j	800046ca <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046e8:	02451783          	lh	a5,36(a0)
    800046ec:	03079693          	slli	a3,a5,0x30
    800046f0:	92c1                	srli	a3,a3,0x30
    800046f2:	4725                	li	a4,9
    800046f4:	02d76863          	bltu	a4,a3,80004724 <fileread+0xba>
    800046f8:	0792                	slli	a5,a5,0x4
    800046fa:	0001d717          	auipc	a4,0x1d
    800046fe:	2b670713          	addi	a4,a4,694 # 800219b0 <devsw>
    80004702:	97ba                	add	a5,a5,a4
    80004704:	639c                	ld	a5,0(a5)
    80004706:	c38d                	beqz	a5,80004728 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004708:	4505                	li	a0,1
    8000470a:	9782                	jalr	a5
    8000470c:	892a                	mv	s2,a0
    8000470e:	bf75                	j	800046ca <fileread+0x60>
    panic("fileread");
    80004710:	00004517          	auipc	a0,0x4
    80004714:	ef850513          	addi	a0,a0,-264 # 80008608 <syscalls+0x258>
    80004718:	ffffc097          	auipc	ra,0xffffc
    8000471c:	e30080e7          	jalr	-464(ra) # 80000548 <panic>
    return -1;
    80004720:	597d                	li	s2,-1
    80004722:	b765                	j	800046ca <fileread+0x60>
      return -1;
    80004724:	597d                	li	s2,-1
    80004726:	b755                	j	800046ca <fileread+0x60>
    80004728:	597d                	li	s2,-1
    8000472a:	b745                	j	800046ca <fileread+0x60>

000000008000472c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000472c:	00954783          	lbu	a5,9(a0)
    80004730:	14078563          	beqz	a5,8000487a <filewrite+0x14e>
{
    80004734:	715d                	addi	sp,sp,-80
    80004736:	e486                	sd	ra,72(sp)
    80004738:	e0a2                	sd	s0,64(sp)
    8000473a:	fc26                	sd	s1,56(sp)
    8000473c:	f84a                	sd	s2,48(sp)
    8000473e:	f44e                	sd	s3,40(sp)
    80004740:	f052                	sd	s4,32(sp)
    80004742:	ec56                	sd	s5,24(sp)
    80004744:	e85a                	sd	s6,16(sp)
    80004746:	e45e                	sd	s7,8(sp)
    80004748:	e062                	sd	s8,0(sp)
    8000474a:	0880                	addi	s0,sp,80
    8000474c:	892a                	mv	s2,a0
    8000474e:	8aae                	mv	s5,a1
    80004750:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004752:	411c                	lw	a5,0(a0)
    80004754:	4705                	li	a4,1
    80004756:	02e78263          	beq	a5,a4,8000477a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000475a:	470d                	li	a4,3
    8000475c:	02e78563          	beq	a5,a4,80004786 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004760:	4709                	li	a4,2
    80004762:	10e79463          	bne	a5,a4,8000486a <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004766:	0ec05e63          	blez	a2,80004862 <filewrite+0x136>
    int i = 0;
    8000476a:	4981                	li	s3,0
    8000476c:	6b05                	lui	s6,0x1
    8000476e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004772:	6b85                	lui	s7,0x1
    80004774:	c00b8b9b          	addiw	s7,s7,-1024
    80004778:	a851                	j	8000480c <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000477a:	6908                	ld	a0,16(a0)
    8000477c:	00000097          	auipc	ra,0x0
    80004780:	254080e7          	jalr	596(ra) # 800049d0 <pipewrite>
    80004784:	a85d                	j	8000483a <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004786:	02451783          	lh	a5,36(a0)
    8000478a:	03079693          	slli	a3,a5,0x30
    8000478e:	92c1                	srli	a3,a3,0x30
    80004790:	4725                	li	a4,9
    80004792:	0ed76663          	bltu	a4,a3,8000487e <filewrite+0x152>
    80004796:	0792                	slli	a5,a5,0x4
    80004798:	0001d717          	auipc	a4,0x1d
    8000479c:	21870713          	addi	a4,a4,536 # 800219b0 <devsw>
    800047a0:	97ba                	add	a5,a5,a4
    800047a2:	679c                	ld	a5,8(a5)
    800047a4:	cff9                	beqz	a5,80004882 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    800047a6:	4505                	li	a0,1
    800047a8:	9782                	jalr	a5
    800047aa:	a841                	j	8000483a <filewrite+0x10e>
    800047ac:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800047b0:	00000097          	auipc	ra,0x0
    800047b4:	8ae080e7          	jalr	-1874(ra) # 8000405e <begin_op>
      ilock(f->ip);
    800047b8:	01893503          	ld	a0,24(s2)
    800047bc:	fffff097          	auipc	ra,0xfffff
    800047c0:	ee2080e7          	jalr	-286(ra) # 8000369e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047c4:	8762                	mv	a4,s8
    800047c6:	02092683          	lw	a3,32(s2)
    800047ca:	01598633          	add	a2,s3,s5
    800047ce:	4585                	li	a1,1
    800047d0:	01893503          	ld	a0,24(s2)
    800047d4:	fffff097          	auipc	ra,0xfffff
    800047d8:	276080e7          	jalr	630(ra) # 80003a4a <writei>
    800047dc:	84aa                	mv	s1,a0
    800047de:	02a05f63          	blez	a0,8000481c <filewrite+0xf0>
        f->off += r;
    800047e2:	02092783          	lw	a5,32(s2)
    800047e6:	9fa9                	addw	a5,a5,a0
    800047e8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047ec:	01893503          	ld	a0,24(s2)
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	f70080e7          	jalr	-144(ra) # 80003760 <iunlock>
      end_op();
    800047f8:	00000097          	auipc	ra,0x0
    800047fc:	8e6080e7          	jalr	-1818(ra) # 800040de <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004800:	049c1963          	bne	s8,s1,80004852 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004804:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004808:	0349d663          	bge	s3,s4,80004834 <filewrite+0x108>
      int n1 = n - i;
    8000480c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004810:	84be                	mv	s1,a5
    80004812:	2781                	sext.w	a5,a5
    80004814:	f8fb5ce3          	bge	s6,a5,800047ac <filewrite+0x80>
    80004818:	84de                	mv	s1,s7
    8000481a:	bf49                	j	800047ac <filewrite+0x80>
      iunlock(f->ip);
    8000481c:	01893503          	ld	a0,24(s2)
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	f40080e7          	jalr	-192(ra) # 80003760 <iunlock>
      end_op();
    80004828:	00000097          	auipc	ra,0x0
    8000482c:	8b6080e7          	jalr	-1866(ra) # 800040de <end_op>
      if(r < 0)
    80004830:	fc04d8e3          	bgez	s1,80004800 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004834:	8552                	mv	a0,s4
    80004836:	033a1863          	bne	s4,s3,80004866 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000483a:	60a6                	ld	ra,72(sp)
    8000483c:	6406                	ld	s0,64(sp)
    8000483e:	74e2                	ld	s1,56(sp)
    80004840:	7942                	ld	s2,48(sp)
    80004842:	79a2                	ld	s3,40(sp)
    80004844:	7a02                	ld	s4,32(sp)
    80004846:	6ae2                	ld	s5,24(sp)
    80004848:	6b42                	ld	s6,16(sp)
    8000484a:	6ba2                	ld	s7,8(sp)
    8000484c:	6c02                	ld	s8,0(sp)
    8000484e:	6161                	addi	sp,sp,80
    80004850:	8082                	ret
        panic("short filewrite");
    80004852:	00004517          	auipc	a0,0x4
    80004856:	dc650513          	addi	a0,a0,-570 # 80008618 <syscalls+0x268>
    8000485a:	ffffc097          	auipc	ra,0xffffc
    8000485e:	cee080e7          	jalr	-786(ra) # 80000548 <panic>
    int i = 0;
    80004862:	4981                	li	s3,0
    80004864:	bfc1                	j	80004834 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004866:	557d                	li	a0,-1
    80004868:	bfc9                	j	8000483a <filewrite+0x10e>
    panic("filewrite");
    8000486a:	00004517          	auipc	a0,0x4
    8000486e:	dbe50513          	addi	a0,a0,-578 # 80008628 <syscalls+0x278>
    80004872:	ffffc097          	auipc	ra,0xffffc
    80004876:	cd6080e7          	jalr	-810(ra) # 80000548 <panic>
    return -1;
    8000487a:	557d                	li	a0,-1
}
    8000487c:	8082                	ret
      return -1;
    8000487e:	557d                	li	a0,-1
    80004880:	bf6d                	j	8000483a <filewrite+0x10e>
    80004882:	557d                	li	a0,-1
    80004884:	bf5d                	j	8000483a <filewrite+0x10e>

0000000080004886 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004886:	7179                	addi	sp,sp,-48
    80004888:	f406                	sd	ra,40(sp)
    8000488a:	f022                	sd	s0,32(sp)
    8000488c:	ec26                	sd	s1,24(sp)
    8000488e:	e84a                	sd	s2,16(sp)
    80004890:	e44e                	sd	s3,8(sp)
    80004892:	e052                	sd	s4,0(sp)
    80004894:	1800                	addi	s0,sp,48
    80004896:	84aa                	mv	s1,a0
    80004898:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000489a:	0005b023          	sd	zero,0(a1)
    8000489e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048a2:	00000097          	auipc	ra,0x0
    800048a6:	bd2080e7          	jalr	-1070(ra) # 80004474 <filealloc>
    800048aa:	e088                	sd	a0,0(s1)
    800048ac:	c551                	beqz	a0,80004938 <pipealloc+0xb2>
    800048ae:	00000097          	auipc	ra,0x0
    800048b2:	bc6080e7          	jalr	-1082(ra) # 80004474 <filealloc>
    800048b6:	00aa3023          	sd	a0,0(s4)
    800048ba:	c92d                	beqz	a0,8000492c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	264080e7          	jalr	612(ra) # 80000b20 <kalloc>
    800048c4:	892a                	mv	s2,a0
    800048c6:	c125                	beqz	a0,80004926 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048c8:	4985                	li	s3,1
    800048ca:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048ce:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048d2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048d6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048da:	00004597          	auipc	a1,0x4
    800048de:	d5e58593          	addi	a1,a1,-674 # 80008638 <syscalls+0x288>
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	29e080e7          	jalr	670(ra) # 80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    800048ea:	609c                	ld	a5,0(s1)
    800048ec:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048f0:	609c                	ld	a5,0(s1)
    800048f2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048f6:	609c                	ld	a5,0(s1)
    800048f8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048fc:	609c                	ld	a5,0(s1)
    800048fe:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004902:	000a3783          	ld	a5,0(s4)
    80004906:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000490a:	000a3783          	ld	a5,0(s4)
    8000490e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004912:	000a3783          	ld	a5,0(s4)
    80004916:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000491a:	000a3783          	ld	a5,0(s4)
    8000491e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004922:	4501                	li	a0,0
    80004924:	a025                	j	8000494c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004926:	6088                	ld	a0,0(s1)
    80004928:	e501                	bnez	a0,80004930 <pipealloc+0xaa>
    8000492a:	a039                	j	80004938 <pipealloc+0xb2>
    8000492c:	6088                	ld	a0,0(s1)
    8000492e:	c51d                	beqz	a0,8000495c <pipealloc+0xd6>
    fileclose(*f0);
    80004930:	00000097          	auipc	ra,0x0
    80004934:	c00080e7          	jalr	-1024(ra) # 80004530 <fileclose>
  if(*f1)
    80004938:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000493c:	557d                	li	a0,-1
  if(*f1)
    8000493e:	c799                	beqz	a5,8000494c <pipealloc+0xc6>
    fileclose(*f1);
    80004940:	853e                	mv	a0,a5
    80004942:	00000097          	auipc	ra,0x0
    80004946:	bee080e7          	jalr	-1042(ra) # 80004530 <fileclose>
  return -1;
    8000494a:	557d                	li	a0,-1
}
    8000494c:	70a2                	ld	ra,40(sp)
    8000494e:	7402                	ld	s0,32(sp)
    80004950:	64e2                	ld	s1,24(sp)
    80004952:	6942                	ld	s2,16(sp)
    80004954:	69a2                	ld	s3,8(sp)
    80004956:	6a02                	ld	s4,0(sp)
    80004958:	6145                	addi	sp,sp,48
    8000495a:	8082                	ret
  return -1;
    8000495c:	557d                	li	a0,-1
    8000495e:	b7fd                	j	8000494c <pipealloc+0xc6>

0000000080004960 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004960:	1101                	addi	sp,sp,-32
    80004962:	ec06                	sd	ra,24(sp)
    80004964:	e822                	sd	s0,16(sp)
    80004966:	e426                	sd	s1,8(sp)
    80004968:	e04a                	sd	s2,0(sp)
    8000496a:	1000                	addi	s0,sp,32
    8000496c:	84aa                	mv	s1,a0
    8000496e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	2a0080e7          	jalr	672(ra) # 80000c10 <acquire>
  if(writable){
    80004978:	02090d63          	beqz	s2,800049b2 <pipeclose+0x52>
    pi->writeopen = 0;
    8000497c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004980:	21848513          	addi	a0,s1,536
    80004984:	ffffe097          	auipc	ra,0xffffe
    80004988:	a0e080e7          	jalr	-1522(ra) # 80002392 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000498c:	2204b783          	ld	a5,544(s1)
    80004990:	eb95                	bnez	a5,800049c4 <pipeclose+0x64>
    release(&pi->lock);
    80004992:	8526                	mv	a0,s1
    80004994:	ffffc097          	auipc	ra,0xffffc
    80004998:	330080e7          	jalr	816(ra) # 80000cc4 <release>
    kfree((char*)pi);
    8000499c:	8526                	mv	a0,s1
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	086080e7          	jalr	134(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    800049a6:	60e2                	ld	ra,24(sp)
    800049a8:	6442                	ld	s0,16(sp)
    800049aa:	64a2                	ld	s1,8(sp)
    800049ac:	6902                	ld	s2,0(sp)
    800049ae:	6105                	addi	sp,sp,32
    800049b0:	8082                	ret
    pi->readopen = 0;
    800049b2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049b6:	21c48513          	addi	a0,s1,540
    800049ba:	ffffe097          	auipc	ra,0xffffe
    800049be:	9d8080e7          	jalr	-1576(ra) # 80002392 <wakeup>
    800049c2:	b7e9                	j	8000498c <pipeclose+0x2c>
    release(&pi->lock);
    800049c4:	8526                	mv	a0,s1
    800049c6:	ffffc097          	auipc	ra,0xffffc
    800049ca:	2fe080e7          	jalr	766(ra) # 80000cc4 <release>
}
    800049ce:	bfe1                	j	800049a6 <pipeclose+0x46>

00000000800049d0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049d0:	7119                	addi	sp,sp,-128
    800049d2:	fc86                	sd	ra,120(sp)
    800049d4:	f8a2                	sd	s0,112(sp)
    800049d6:	f4a6                	sd	s1,104(sp)
    800049d8:	f0ca                	sd	s2,96(sp)
    800049da:	ecce                	sd	s3,88(sp)
    800049dc:	e8d2                	sd	s4,80(sp)
    800049de:	e4d6                	sd	s5,72(sp)
    800049e0:	e0da                	sd	s6,64(sp)
    800049e2:	fc5e                	sd	s7,56(sp)
    800049e4:	f862                	sd	s8,48(sp)
    800049e6:	f466                	sd	s9,40(sp)
    800049e8:	f06a                	sd	s10,32(sp)
    800049ea:	ec6e                	sd	s11,24(sp)
    800049ec:	0100                	addi	s0,sp,128
    800049ee:	84aa                	mv	s1,a0
    800049f0:	8cae                	mv	s9,a1
    800049f2:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    800049f4:	ffffd097          	auipc	ra,0xffffd
    800049f8:	008080e7          	jalr	8(ra) # 800019fc <myproc>
    800049fc:	892a                	mv	s2,a0

  acquire(&pi->lock);
    800049fe:	8526                	mv	a0,s1
    80004a00:	ffffc097          	auipc	ra,0xffffc
    80004a04:	210080e7          	jalr	528(ra) # 80000c10 <acquire>
  for(i = 0; i < n; i++){
    80004a08:	0d605963          	blez	s6,80004ada <pipewrite+0x10a>
    80004a0c:	89a6                	mv	s3,s1
    80004a0e:	3b7d                	addiw	s6,s6,-1
    80004a10:	1b02                	slli	s6,s6,0x20
    80004a12:	020b5b13          	srli	s6,s6,0x20
    80004a16:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004a18:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a1c:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a20:	5dfd                	li	s11,-1
    80004a22:	000b8d1b          	sext.w	s10,s7
    80004a26:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a28:	2184a783          	lw	a5,536(s1)
    80004a2c:	21c4a703          	lw	a4,540(s1)
    80004a30:	2007879b          	addiw	a5,a5,512
    80004a34:	02f71b63          	bne	a4,a5,80004a6a <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004a38:	2204a783          	lw	a5,544(s1)
    80004a3c:	cbad                	beqz	a5,80004aae <pipewrite+0xde>
    80004a3e:	03092783          	lw	a5,48(s2)
    80004a42:	e7b5                	bnez	a5,80004aae <pipewrite+0xde>
      wakeup(&pi->nread);
    80004a44:	8556                	mv	a0,s5
    80004a46:	ffffe097          	auipc	ra,0xffffe
    80004a4a:	94c080e7          	jalr	-1716(ra) # 80002392 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a4e:	85ce                	mv	a1,s3
    80004a50:	8552                	mv	a0,s4
    80004a52:	ffffd097          	auipc	ra,0xffffd
    80004a56:	7ba080e7          	jalr	1978(ra) # 8000220c <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a5a:	2184a783          	lw	a5,536(s1)
    80004a5e:	21c4a703          	lw	a4,540(s1)
    80004a62:	2007879b          	addiw	a5,a5,512
    80004a66:	fcf709e3          	beq	a4,a5,80004a38 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a6a:	4685                	li	a3,1
    80004a6c:	019b8633          	add	a2,s7,s9
    80004a70:	f8f40593          	addi	a1,s0,-113
    80004a74:	05093503          	ld	a0,80(s2)
    80004a78:	ffffd097          	auipc	ra,0xffffd
    80004a7c:	d04080e7          	jalr	-764(ra) # 8000177c <copyin>
    80004a80:	05b50e63          	beq	a0,s11,80004adc <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a84:	21c4a783          	lw	a5,540(s1)
    80004a88:	0017871b          	addiw	a4,a5,1
    80004a8c:	20e4ae23          	sw	a4,540(s1)
    80004a90:	1ff7f793          	andi	a5,a5,511
    80004a94:	97a6                	add	a5,a5,s1
    80004a96:	f8f44703          	lbu	a4,-113(s0)
    80004a9a:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004a9e:	001d0c1b          	addiw	s8,s10,1
    80004aa2:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004aa6:	036b8b63          	beq	s7,s6,80004adc <pipewrite+0x10c>
    80004aaa:	8bbe                	mv	s7,a5
    80004aac:	bf9d                	j	80004a22 <pipewrite+0x52>
        release(&pi->lock);
    80004aae:	8526                	mv	a0,s1
    80004ab0:	ffffc097          	auipc	ra,0xffffc
    80004ab4:	214080e7          	jalr	532(ra) # 80000cc4 <release>
        return -1;
    80004ab8:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004aba:	8562                	mv	a0,s8
    80004abc:	70e6                	ld	ra,120(sp)
    80004abe:	7446                	ld	s0,112(sp)
    80004ac0:	74a6                	ld	s1,104(sp)
    80004ac2:	7906                	ld	s2,96(sp)
    80004ac4:	69e6                	ld	s3,88(sp)
    80004ac6:	6a46                	ld	s4,80(sp)
    80004ac8:	6aa6                	ld	s5,72(sp)
    80004aca:	6b06                	ld	s6,64(sp)
    80004acc:	7be2                	ld	s7,56(sp)
    80004ace:	7c42                	ld	s8,48(sp)
    80004ad0:	7ca2                	ld	s9,40(sp)
    80004ad2:	7d02                	ld	s10,32(sp)
    80004ad4:	6de2                	ld	s11,24(sp)
    80004ad6:	6109                	addi	sp,sp,128
    80004ad8:	8082                	ret
  for(i = 0; i < n; i++){
    80004ada:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004adc:	21848513          	addi	a0,s1,536
    80004ae0:	ffffe097          	auipc	ra,0xffffe
    80004ae4:	8b2080e7          	jalr	-1870(ra) # 80002392 <wakeup>
  release(&pi->lock);
    80004ae8:	8526                	mv	a0,s1
    80004aea:	ffffc097          	auipc	ra,0xffffc
    80004aee:	1da080e7          	jalr	474(ra) # 80000cc4 <release>
  return i;
    80004af2:	b7e1                	j	80004aba <pipewrite+0xea>

0000000080004af4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004af4:	715d                	addi	sp,sp,-80
    80004af6:	e486                	sd	ra,72(sp)
    80004af8:	e0a2                	sd	s0,64(sp)
    80004afa:	fc26                	sd	s1,56(sp)
    80004afc:	f84a                	sd	s2,48(sp)
    80004afe:	f44e                	sd	s3,40(sp)
    80004b00:	f052                	sd	s4,32(sp)
    80004b02:	ec56                	sd	s5,24(sp)
    80004b04:	e85a                	sd	s6,16(sp)
    80004b06:	0880                	addi	s0,sp,80
    80004b08:	84aa                	mv	s1,a0
    80004b0a:	892e                	mv	s2,a1
    80004b0c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b0e:	ffffd097          	auipc	ra,0xffffd
    80004b12:	eee080e7          	jalr	-274(ra) # 800019fc <myproc>
    80004b16:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b18:	8b26                	mv	s6,s1
    80004b1a:	8526                	mv	a0,s1
    80004b1c:	ffffc097          	auipc	ra,0xffffc
    80004b20:	0f4080e7          	jalr	244(ra) # 80000c10 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b24:	2184a703          	lw	a4,536(s1)
    80004b28:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b2c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b30:	02f71463          	bne	a4,a5,80004b58 <piperead+0x64>
    80004b34:	2244a783          	lw	a5,548(s1)
    80004b38:	c385                	beqz	a5,80004b58 <piperead+0x64>
    if(pr->killed){
    80004b3a:	030a2783          	lw	a5,48(s4)
    80004b3e:	ebc1                	bnez	a5,80004bce <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b40:	85da                	mv	a1,s6
    80004b42:	854e                	mv	a0,s3
    80004b44:	ffffd097          	auipc	ra,0xffffd
    80004b48:	6c8080e7          	jalr	1736(ra) # 8000220c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b4c:	2184a703          	lw	a4,536(s1)
    80004b50:	21c4a783          	lw	a5,540(s1)
    80004b54:	fef700e3          	beq	a4,a5,80004b34 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b58:	09505263          	blez	s5,80004bdc <piperead+0xe8>
    80004b5c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b5e:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004b60:	2184a783          	lw	a5,536(s1)
    80004b64:	21c4a703          	lw	a4,540(s1)
    80004b68:	02f70d63          	beq	a4,a5,80004ba2 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b6c:	0017871b          	addiw	a4,a5,1
    80004b70:	20e4ac23          	sw	a4,536(s1)
    80004b74:	1ff7f793          	andi	a5,a5,511
    80004b78:	97a6                	add	a5,a5,s1
    80004b7a:	0187c783          	lbu	a5,24(a5)
    80004b7e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b82:	4685                	li	a3,1
    80004b84:	fbf40613          	addi	a2,s0,-65
    80004b88:	85ca                	mv	a1,s2
    80004b8a:	050a3503          	ld	a0,80(s4)
    80004b8e:	ffffd097          	auipc	ra,0xffffd
    80004b92:	b62080e7          	jalr	-1182(ra) # 800016f0 <copyout>
    80004b96:	01650663          	beq	a0,s6,80004ba2 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b9a:	2985                	addiw	s3,s3,1
    80004b9c:	0905                	addi	s2,s2,1
    80004b9e:	fd3a91e3          	bne	s5,s3,80004b60 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ba2:	21c48513          	addi	a0,s1,540
    80004ba6:	ffffd097          	auipc	ra,0xffffd
    80004baa:	7ec080e7          	jalr	2028(ra) # 80002392 <wakeup>
  release(&pi->lock);
    80004bae:	8526                	mv	a0,s1
    80004bb0:	ffffc097          	auipc	ra,0xffffc
    80004bb4:	114080e7          	jalr	276(ra) # 80000cc4 <release>
  return i;
}
    80004bb8:	854e                	mv	a0,s3
    80004bba:	60a6                	ld	ra,72(sp)
    80004bbc:	6406                	ld	s0,64(sp)
    80004bbe:	74e2                	ld	s1,56(sp)
    80004bc0:	7942                	ld	s2,48(sp)
    80004bc2:	79a2                	ld	s3,40(sp)
    80004bc4:	7a02                	ld	s4,32(sp)
    80004bc6:	6ae2                	ld	s5,24(sp)
    80004bc8:	6b42                	ld	s6,16(sp)
    80004bca:	6161                	addi	sp,sp,80
    80004bcc:	8082                	ret
      release(&pi->lock);
    80004bce:	8526                	mv	a0,s1
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	0f4080e7          	jalr	244(ra) # 80000cc4 <release>
      return -1;
    80004bd8:	59fd                	li	s3,-1
    80004bda:	bff9                	j	80004bb8 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bdc:	4981                	li	s3,0
    80004bde:	b7d1                	j	80004ba2 <piperead+0xae>

0000000080004be0 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004be0:	df010113          	addi	sp,sp,-528
    80004be4:	20113423          	sd	ra,520(sp)
    80004be8:	20813023          	sd	s0,512(sp)
    80004bec:	ffa6                	sd	s1,504(sp)
    80004bee:	fbca                	sd	s2,496(sp)
    80004bf0:	f7ce                	sd	s3,488(sp)
    80004bf2:	f3d2                	sd	s4,480(sp)
    80004bf4:	efd6                	sd	s5,472(sp)
    80004bf6:	ebda                	sd	s6,464(sp)
    80004bf8:	e7de                	sd	s7,456(sp)
    80004bfa:	e3e2                	sd	s8,448(sp)
    80004bfc:	ff66                	sd	s9,440(sp)
    80004bfe:	fb6a                	sd	s10,432(sp)
    80004c00:	f76e                	sd	s11,424(sp)
    80004c02:	0c00                	addi	s0,sp,528
    80004c04:	84aa                	mv	s1,a0
    80004c06:	dea43c23          	sd	a0,-520(s0)
    80004c0a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c0e:	ffffd097          	auipc	ra,0xffffd
    80004c12:	dee080e7          	jalr	-530(ra) # 800019fc <myproc>
    80004c16:	892a                	mv	s2,a0

  begin_op();
    80004c18:	fffff097          	auipc	ra,0xfffff
    80004c1c:	446080e7          	jalr	1094(ra) # 8000405e <begin_op>

  if((ip = namei(path)) == 0){
    80004c20:	8526                	mv	a0,s1
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	230080e7          	jalr	560(ra) # 80003e52 <namei>
    80004c2a:	c92d                	beqz	a0,80004c9c <exec+0xbc>
    80004c2c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c2e:	fffff097          	auipc	ra,0xfffff
    80004c32:	a70080e7          	jalr	-1424(ra) # 8000369e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c36:	04000713          	li	a4,64
    80004c3a:	4681                	li	a3,0
    80004c3c:	e4840613          	addi	a2,s0,-440
    80004c40:	4581                	li	a1,0
    80004c42:	8526                	mv	a0,s1
    80004c44:	fffff097          	auipc	ra,0xfffff
    80004c48:	d0e080e7          	jalr	-754(ra) # 80003952 <readi>
    80004c4c:	04000793          	li	a5,64
    80004c50:	00f51a63          	bne	a0,a5,80004c64 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c54:	e4842703          	lw	a4,-440(s0)
    80004c58:	464c47b7          	lui	a5,0x464c4
    80004c5c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c60:	04f70463          	beq	a4,a5,80004ca8 <exec+0xc8>
 bad:
  if(pagetable) 
    proc_freepagetable(pagetable, sz);
    
  if(ip){
    iunlockput(ip);
    80004c64:	8526                	mv	a0,s1
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	c9a080e7          	jalr	-870(ra) # 80003900 <iunlockput>
    end_op();
    80004c6e:	fffff097          	auipc	ra,0xfffff
    80004c72:	470080e7          	jalr	1136(ra) # 800040de <end_op>
  }
  return -1;
    80004c76:	557d                	li	a0,-1
}
    80004c78:	20813083          	ld	ra,520(sp)
    80004c7c:	20013403          	ld	s0,512(sp)
    80004c80:	74fe                	ld	s1,504(sp)
    80004c82:	795e                	ld	s2,496(sp)
    80004c84:	79be                	ld	s3,488(sp)
    80004c86:	7a1e                	ld	s4,480(sp)
    80004c88:	6afe                	ld	s5,472(sp)
    80004c8a:	6b5e                	ld	s6,464(sp)
    80004c8c:	6bbe                	ld	s7,456(sp)
    80004c8e:	6c1e                	ld	s8,448(sp)
    80004c90:	7cfa                	ld	s9,440(sp)
    80004c92:	7d5a                	ld	s10,432(sp)
    80004c94:	7dba                	ld	s11,424(sp)
    80004c96:	21010113          	addi	sp,sp,528
    80004c9a:	8082                	ret
    end_op();
    80004c9c:	fffff097          	auipc	ra,0xfffff
    80004ca0:	442080e7          	jalr	1090(ra) # 800040de <end_op>
    return -1;
    80004ca4:	557d                	li	a0,-1
    80004ca6:	bfc9                	j	80004c78 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ca8:	854a                	mv	a0,s2
    80004caa:	ffffd097          	auipc	ra,0xffffd
    80004cae:	e16080e7          	jalr	-490(ra) # 80001ac0 <proc_pagetable>
    80004cb2:	8baa                	mv	s7,a0
    80004cb4:	d945                	beqz	a0,80004c64 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cb6:	e6842983          	lw	s3,-408(s0)
    80004cba:	e8045783          	lhu	a5,-384(s0)
    80004cbe:	c7ad                	beqz	a5,80004d28 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004cc0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cc2:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004cc4:	6c85                	lui	s9,0x1
    80004cc6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004cca:	def43823          	sd	a5,-528(s0)
    80004cce:	a42d                	j	80004ef8 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cd0:	00004517          	auipc	a0,0x4
    80004cd4:	97050513          	addi	a0,a0,-1680 # 80008640 <syscalls+0x290>
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	870080e7          	jalr	-1936(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ce0:	8756                	mv	a4,s5
    80004ce2:	012d86bb          	addw	a3,s11,s2
    80004ce6:	4581                	li	a1,0
    80004ce8:	8526                	mv	a0,s1
    80004cea:	fffff097          	auipc	ra,0xfffff
    80004cee:	c68080e7          	jalr	-920(ra) # 80003952 <readi>
    80004cf2:	2501                	sext.w	a0,a0
    80004cf4:	1aaa9963          	bne	s5,a0,80004ea6 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004cf8:	6785                	lui	a5,0x1
    80004cfa:	0127893b          	addw	s2,a5,s2
    80004cfe:	77fd                	lui	a5,0xfffff
    80004d00:	01478a3b          	addw	s4,a5,s4
    80004d04:	1f897163          	bgeu	s2,s8,80004ee6 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004d08:	02091593          	slli	a1,s2,0x20
    80004d0c:	9181                	srli	a1,a1,0x20
    80004d0e:	95ea                	add	a1,a1,s10
    80004d10:	855e                	mv	a0,s7
    80004d12:	ffffc097          	auipc	ra,0xffffc
    80004d16:	478080e7          	jalr	1144(ra) # 8000118a <walkaddr>
    80004d1a:	862a                	mv	a2,a0
    if(pa == 0)
    80004d1c:	d955                	beqz	a0,80004cd0 <exec+0xf0>
      n = PGSIZE;
    80004d1e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004d20:	fd9a70e3          	bgeu	s4,s9,80004ce0 <exec+0x100>
      n = sz - i;
    80004d24:	8ad2                	mv	s5,s4
    80004d26:	bf6d                	j	80004ce0 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d28:	4901                	li	s2,0
  iunlockput(ip);
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	fffff097          	auipc	ra,0xfffff
    80004d30:	bd4080e7          	jalr	-1068(ra) # 80003900 <iunlockput>
  end_op();
    80004d34:	fffff097          	auipc	ra,0xfffff
    80004d38:	3aa080e7          	jalr	938(ra) # 800040de <end_op>
  p = myproc();
    80004d3c:	ffffd097          	auipc	ra,0xffffd
    80004d40:	cc0080e7          	jalr	-832(ra) # 800019fc <myproc>
    80004d44:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d46:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d4a:	6785                	lui	a5,0x1
    80004d4c:	17fd                	addi	a5,a5,-1
    80004d4e:	993e                	add	s2,s2,a5
    80004d50:	757d                	lui	a0,0xfffff
    80004d52:	00a977b3          	and	a5,s2,a0
    80004d56:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d5a:	6609                	lui	a2,0x2
    80004d5c:	963e                	add	a2,a2,a5
    80004d5e:	85be                	mv	a1,a5
    80004d60:	855e                	mv	a0,s7
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	76c080e7          	jalr	1900(ra) # 800014ce <uvmalloc>
    80004d6a:	8b2a                	mv	s6,a0
  ip = 0;
    80004d6c:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d6e:	12050c63          	beqz	a0,80004ea6 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d72:	75f9                	lui	a1,0xffffe
    80004d74:	95aa                	add	a1,a1,a0
    80004d76:	855e                	mv	a0,s7
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	946080e7          	jalr	-1722(ra) # 800016be <uvmclear>
  stackbase = sp - PGSIZE;
    80004d80:	7c7d                	lui	s8,0xfffff
    80004d82:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004d84:	e0043783          	ld	a5,-512(s0)
    80004d88:	6388                	ld	a0,0(a5)
    80004d8a:	c535                	beqz	a0,80004df6 <exec+0x216>
    80004d8c:	e8840993          	addi	s3,s0,-376
    80004d90:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004d94:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	0fe080e7          	jalr	254(ra) # 80000e94 <strlen>
    80004d9e:	2505                	addiw	a0,a0,1
    80004da0:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004da4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004da8:	13896363          	bltu	s2,s8,80004ece <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dac:	e0043d83          	ld	s11,-512(s0)
    80004db0:	000dba03          	ld	s4,0(s11)
    80004db4:	8552                	mv	a0,s4
    80004db6:	ffffc097          	auipc	ra,0xffffc
    80004dba:	0de080e7          	jalr	222(ra) # 80000e94 <strlen>
    80004dbe:	0015069b          	addiw	a3,a0,1
    80004dc2:	8652                	mv	a2,s4
    80004dc4:	85ca                	mv	a1,s2
    80004dc6:	855e                	mv	a0,s7
    80004dc8:	ffffd097          	auipc	ra,0xffffd
    80004dcc:	928080e7          	jalr	-1752(ra) # 800016f0 <copyout>
    80004dd0:	10054363          	bltz	a0,80004ed6 <exec+0x2f6>
    ustack[argc] = sp;
    80004dd4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004dd8:	0485                	addi	s1,s1,1
    80004dda:	008d8793          	addi	a5,s11,8
    80004dde:	e0f43023          	sd	a5,-512(s0)
    80004de2:	008db503          	ld	a0,8(s11)
    80004de6:	c911                	beqz	a0,80004dfa <exec+0x21a>
    if(argc >= MAXARG)
    80004de8:	09a1                	addi	s3,s3,8
    80004dea:	fb3c96e3          	bne	s9,s3,80004d96 <exec+0x1b6>
  sz = sz1;
    80004dee:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004df2:	4481                	li	s1,0
    80004df4:	a84d                	j	80004ea6 <exec+0x2c6>
  sp = sz;
    80004df6:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004df8:	4481                	li	s1,0
  ustack[argc] = 0;
    80004dfa:	00349793          	slli	a5,s1,0x3
    80004dfe:	f9040713          	addi	a4,s0,-112
    80004e02:	97ba                	add	a5,a5,a4
    80004e04:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004e08:	00148693          	addi	a3,s1,1
    80004e0c:	068e                	slli	a3,a3,0x3
    80004e0e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e12:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e16:	01897663          	bgeu	s2,s8,80004e22 <exec+0x242>
  sz = sz1;
    80004e1a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e1e:	4481                	li	s1,0
    80004e20:	a059                	j	80004ea6 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e22:	e8840613          	addi	a2,s0,-376
    80004e26:	85ca                	mv	a1,s2
    80004e28:	855e                	mv	a0,s7
    80004e2a:	ffffd097          	auipc	ra,0xffffd
    80004e2e:	8c6080e7          	jalr	-1850(ra) # 800016f0 <copyout>
    80004e32:	0a054663          	bltz	a0,80004ede <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004e36:	058ab783          	ld	a5,88(s5)
    80004e3a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e3e:	df843783          	ld	a5,-520(s0)
    80004e42:	0007c703          	lbu	a4,0(a5)
    80004e46:	cf11                	beqz	a4,80004e62 <exec+0x282>
    80004e48:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e4a:	02f00693          	li	a3,47
    80004e4e:	a029                	j	80004e58 <exec+0x278>
  for(last=s=path; *s; s++)
    80004e50:	0785                	addi	a5,a5,1
    80004e52:	fff7c703          	lbu	a4,-1(a5)
    80004e56:	c711                	beqz	a4,80004e62 <exec+0x282>
    if(*s == '/')
    80004e58:	fed71ce3          	bne	a4,a3,80004e50 <exec+0x270>
      last = s+1;
    80004e5c:	def43c23          	sd	a5,-520(s0)
    80004e60:	bfc5                	j	80004e50 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e62:	4641                	li	a2,16
    80004e64:	df843583          	ld	a1,-520(s0)
    80004e68:	158a8513          	addi	a0,s5,344
    80004e6c:	ffffc097          	auipc	ra,0xffffc
    80004e70:	ff6080e7          	jalr	-10(ra) # 80000e62 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e74:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004e78:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004e7c:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e80:	058ab783          	ld	a5,88(s5)
    80004e84:	e6043703          	ld	a4,-416(s0)
    80004e88:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e8a:	058ab783          	ld	a5,88(s5)
    80004e8e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e92:	85ea                	mv	a1,s10
    80004e94:	ffffd097          	auipc	ra,0xffffd
    80004e98:	cc8080e7          	jalr	-824(ra) # 80001b5c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e9c:	0004851b          	sext.w	a0,s1
    80004ea0:	bbe1                	j	80004c78 <exec+0x98>
    80004ea2:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004ea6:	e0843583          	ld	a1,-504(s0)
    80004eaa:	855e                	mv	a0,s7
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	cb0080e7          	jalr	-848(ra) # 80001b5c <proc_freepagetable>
  if(ip){
    80004eb4:	da0498e3          	bnez	s1,80004c64 <exec+0x84>
  return -1;
    80004eb8:	557d                	li	a0,-1
    80004eba:	bb7d                	j	80004c78 <exec+0x98>
    80004ebc:	e1243423          	sd	s2,-504(s0)
    80004ec0:	b7dd                	j	80004ea6 <exec+0x2c6>
    80004ec2:	e1243423          	sd	s2,-504(s0)
    80004ec6:	b7c5                	j	80004ea6 <exec+0x2c6>
    80004ec8:	e1243423          	sd	s2,-504(s0)
    80004ecc:	bfe9                	j	80004ea6 <exec+0x2c6>
  sz = sz1;
    80004ece:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ed2:	4481                	li	s1,0
    80004ed4:	bfc9                	j	80004ea6 <exec+0x2c6>
  sz = sz1;
    80004ed6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004eda:	4481                	li	s1,0
    80004edc:	b7e9                	j	80004ea6 <exec+0x2c6>
  sz = sz1;
    80004ede:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ee2:	4481                	li	s1,0
    80004ee4:	b7c9                	j	80004ea6 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ee6:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eea:	2b05                	addiw	s6,s6,1
    80004eec:	0389899b          	addiw	s3,s3,56
    80004ef0:	e8045783          	lhu	a5,-384(s0)
    80004ef4:	e2fb5be3          	bge	s6,a5,80004d2a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ef8:	2981                	sext.w	s3,s3
    80004efa:	03800713          	li	a4,56
    80004efe:	86ce                	mv	a3,s3
    80004f00:	e1040613          	addi	a2,s0,-496
    80004f04:	4581                	li	a1,0
    80004f06:	8526                	mv	a0,s1
    80004f08:	fffff097          	auipc	ra,0xfffff
    80004f0c:	a4a080e7          	jalr	-1462(ra) # 80003952 <readi>
    80004f10:	03800793          	li	a5,56
    80004f14:	f8f517e3          	bne	a0,a5,80004ea2 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004f18:	e1042783          	lw	a5,-496(s0)
    80004f1c:	4705                	li	a4,1
    80004f1e:	fce796e3          	bne	a5,a4,80004eea <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004f22:	e3843603          	ld	a2,-456(s0)
    80004f26:	e3043783          	ld	a5,-464(s0)
    80004f2a:	f8f669e3          	bltu	a2,a5,80004ebc <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f2e:	e2043783          	ld	a5,-480(s0)
    80004f32:	963e                	add	a2,a2,a5
    80004f34:	f8f667e3          	bltu	a2,a5,80004ec2 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f38:	85ca                	mv	a1,s2
    80004f3a:	855e                	mv	a0,s7
    80004f3c:	ffffc097          	auipc	ra,0xffffc
    80004f40:	592080e7          	jalr	1426(ra) # 800014ce <uvmalloc>
    80004f44:	e0a43423          	sd	a0,-504(s0)
    80004f48:	d141                	beqz	a0,80004ec8 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80004f4a:	e2043d03          	ld	s10,-480(s0)
    80004f4e:	df043783          	ld	a5,-528(s0)
    80004f52:	00fd77b3          	and	a5,s10,a5
    80004f56:	fba1                	bnez	a5,80004ea6 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f58:	e1842d83          	lw	s11,-488(s0)
    80004f5c:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f60:	f80c03e3          	beqz	s8,80004ee6 <exec+0x306>
    80004f64:	8a62                	mv	s4,s8
    80004f66:	4901                	li	s2,0
    80004f68:	b345                	j	80004d08 <exec+0x128>

0000000080004f6a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f6a:	7179                	addi	sp,sp,-48
    80004f6c:	f406                	sd	ra,40(sp)
    80004f6e:	f022                	sd	s0,32(sp)
    80004f70:	ec26                	sd	s1,24(sp)
    80004f72:	e84a                	sd	s2,16(sp)
    80004f74:	1800                	addi	s0,sp,48
    80004f76:	892e                	mv	s2,a1
    80004f78:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f7a:	fdc40593          	addi	a1,s0,-36
    80004f7e:	ffffe097          	auipc	ra,0xffffe
    80004f82:	b9e080e7          	jalr	-1122(ra) # 80002b1c <argint>
    80004f86:	04054063          	bltz	a0,80004fc6 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f8a:	fdc42703          	lw	a4,-36(s0)
    80004f8e:	47bd                	li	a5,15
    80004f90:	02e7ed63          	bltu	a5,a4,80004fca <argfd+0x60>
    80004f94:	ffffd097          	auipc	ra,0xffffd
    80004f98:	a68080e7          	jalr	-1432(ra) # 800019fc <myproc>
    80004f9c:	fdc42703          	lw	a4,-36(s0)
    80004fa0:	01a70793          	addi	a5,a4,26
    80004fa4:	078e                	slli	a5,a5,0x3
    80004fa6:	953e                	add	a0,a0,a5
    80004fa8:	611c                	ld	a5,0(a0)
    80004faa:	c395                	beqz	a5,80004fce <argfd+0x64>
    return -1;
  if(pfd)
    80004fac:	00090463          	beqz	s2,80004fb4 <argfd+0x4a>
    *pfd = fd;
    80004fb0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fb4:	4501                	li	a0,0
  if(pf)
    80004fb6:	c091                	beqz	s1,80004fba <argfd+0x50>
    *pf = f;
    80004fb8:	e09c                	sd	a5,0(s1)
}
    80004fba:	70a2                	ld	ra,40(sp)
    80004fbc:	7402                	ld	s0,32(sp)
    80004fbe:	64e2                	ld	s1,24(sp)
    80004fc0:	6942                	ld	s2,16(sp)
    80004fc2:	6145                	addi	sp,sp,48
    80004fc4:	8082                	ret
    return -1;
    80004fc6:	557d                	li	a0,-1
    80004fc8:	bfcd                	j	80004fba <argfd+0x50>
    return -1;
    80004fca:	557d                	li	a0,-1
    80004fcc:	b7fd                	j	80004fba <argfd+0x50>
    80004fce:	557d                	li	a0,-1
    80004fd0:	b7ed                	j	80004fba <argfd+0x50>

0000000080004fd2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fd2:	1101                	addi	sp,sp,-32
    80004fd4:	ec06                	sd	ra,24(sp)
    80004fd6:	e822                	sd	s0,16(sp)
    80004fd8:	e426                	sd	s1,8(sp)
    80004fda:	1000                	addi	s0,sp,32
    80004fdc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fde:	ffffd097          	auipc	ra,0xffffd
    80004fe2:	a1e080e7          	jalr	-1506(ra) # 800019fc <myproc>
    80004fe6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fe8:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    80004fec:	4501                	li	a0,0
    80004fee:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ff0:	6398                	ld	a4,0(a5)
    80004ff2:	cb19                	beqz	a4,80005008 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004ff4:	2505                	addiw	a0,a0,1
    80004ff6:	07a1                	addi	a5,a5,8
    80004ff8:	fed51ce3          	bne	a0,a3,80004ff0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ffc:	557d                	li	a0,-1
}
    80004ffe:	60e2                	ld	ra,24(sp)
    80005000:	6442                	ld	s0,16(sp)
    80005002:	64a2                	ld	s1,8(sp)
    80005004:	6105                	addi	sp,sp,32
    80005006:	8082                	ret
      p->ofile[fd] = f;
    80005008:	01a50793          	addi	a5,a0,26
    8000500c:	078e                	slli	a5,a5,0x3
    8000500e:	963e                	add	a2,a2,a5
    80005010:	e204                	sd	s1,0(a2)
      return fd;
    80005012:	b7f5                	j	80004ffe <fdalloc+0x2c>

0000000080005014 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005014:	715d                	addi	sp,sp,-80
    80005016:	e486                	sd	ra,72(sp)
    80005018:	e0a2                	sd	s0,64(sp)
    8000501a:	fc26                	sd	s1,56(sp)
    8000501c:	f84a                	sd	s2,48(sp)
    8000501e:	f44e                	sd	s3,40(sp)
    80005020:	f052                	sd	s4,32(sp)
    80005022:	ec56                	sd	s5,24(sp)
    80005024:	0880                	addi	s0,sp,80
    80005026:	89ae                	mv	s3,a1
    80005028:	8ab2                	mv	s5,a2
    8000502a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000502c:	fb040593          	addi	a1,s0,-80
    80005030:	fffff097          	auipc	ra,0xfffff
    80005034:	e40080e7          	jalr	-448(ra) # 80003e70 <nameiparent>
    80005038:	892a                	mv	s2,a0
    8000503a:	12050f63          	beqz	a0,80005178 <create+0x164>
    return 0;

  ilock(dp);
    8000503e:	ffffe097          	auipc	ra,0xffffe
    80005042:	660080e7          	jalr	1632(ra) # 8000369e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005046:	4601                	li	a2,0
    80005048:	fb040593          	addi	a1,s0,-80
    8000504c:	854a                	mv	a0,s2
    8000504e:	fffff097          	auipc	ra,0xfffff
    80005052:	b32080e7          	jalr	-1230(ra) # 80003b80 <dirlookup>
    80005056:	84aa                	mv	s1,a0
    80005058:	c921                	beqz	a0,800050a8 <create+0x94>
    iunlockput(dp);
    8000505a:	854a                	mv	a0,s2
    8000505c:	fffff097          	auipc	ra,0xfffff
    80005060:	8a4080e7          	jalr	-1884(ra) # 80003900 <iunlockput>
    ilock(ip);
    80005064:	8526                	mv	a0,s1
    80005066:	ffffe097          	auipc	ra,0xffffe
    8000506a:	638080e7          	jalr	1592(ra) # 8000369e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000506e:	2981                	sext.w	s3,s3
    80005070:	4789                	li	a5,2
    80005072:	02f99463          	bne	s3,a5,8000509a <create+0x86>
    80005076:	0444d783          	lhu	a5,68(s1)
    8000507a:	37f9                	addiw	a5,a5,-2
    8000507c:	17c2                	slli	a5,a5,0x30
    8000507e:	93c1                	srli	a5,a5,0x30
    80005080:	4705                	li	a4,1
    80005082:	00f76c63          	bltu	a4,a5,8000509a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005086:	8526                	mv	a0,s1
    80005088:	60a6                	ld	ra,72(sp)
    8000508a:	6406                	ld	s0,64(sp)
    8000508c:	74e2                	ld	s1,56(sp)
    8000508e:	7942                	ld	s2,48(sp)
    80005090:	79a2                	ld	s3,40(sp)
    80005092:	7a02                	ld	s4,32(sp)
    80005094:	6ae2                	ld	s5,24(sp)
    80005096:	6161                	addi	sp,sp,80
    80005098:	8082                	ret
    iunlockput(ip);
    8000509a:	8526                	mv	a0,s1
    8000509c:	fffff097          	auipc	ra,0xfffff
    800050a0:	864080e7          	jalr	-1948(ra) # 80003900 <iunlockput>
    return 0;
    800050a4:	4481                	li	s1,0
    800050a6:	b7c5                	j	80005086 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800050a8:	85ce                	mv	a1,s3
    800050aa:	00092503          	lw	a0,0(s2)
    800050ae:	ffffe097          	auipc	ra,0xffffe
    800050b2:	458080e7          	jalr	1112(ra) # 80003506 <ialloc>
    800050b6:	84aa                	mv	s1,a0
    800050b8:	c529                	beqz	a0,80005102 <create+0xee>
  ilock(ip);
    800050ba:	ffffe097          	auipc	ra,0xffffe
    800050be:	5e4080e7          	jalr	1508(ra) # 8000369e <ilock>
  ip->major = major;
    800050c2:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800050c6:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800050ca:	4785                	li	a5,1
    800050cc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050d0:	8526                	mv	a0,s1
    800050d2:	ffffe097          	auipc	ra,0xffffe
    800050d6:	502080e7          	jalr	1282(ra) # 800035d4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050da:	2981                	sext.w	s3,s3
    800050dc:	4785                	li	a5,1
    800050de:	02f98a63          	beq	s3,a5,80005112 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800050e2:	40d0                	lw	a2,4(s1)
    800050e4:	fb040593          	addi	a1,s0,-80
    800050e8:	854a                	mv	a0,s2
    800050ea:	fffff097          	auipc	ra,0xfffff
    800050ee:	ca6080e7          	jalr	-858(ra) # 80003d90 <dirlink>
    800050f2:	06054b63          	bltz	a0,80005168 <create+0x154>
  iunlockput(dp);
    800050f6:	854a                	mv	a0,s2
    800050f8:	fffff097          	auipc	ra,0xfffff
    800050fc:	808080e7          	jalr	-2040(ra) # 80003900 <iunlockput>
  return ip;
    80005100:	b759                	j	80005086 <create+0x72>
    panic("create: ialloc");
    80005102:	00003517          	auipc	a0,0x3
    80005106:	55e50513          	addi	a0,a0,1374 # 80008660 <syscalls+0x2b0>
    8000510a:	ffffb097          	auipc	ra,0xffffb
    8000510e:	43e080e7          	jalr	1086(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    80005112:	04a95783          	lhu	a5,74(s2)
    80005116:	2785                	addiw	a5,a5,1
    80005118:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000511c:	854a                	mv	a0,s2
    8000511e:	ffffe097          	auipc	ra,0xffffe
    80005122:	4b6080e7          	jalr	1206(ra) # 800035d4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005126:	40d0                	lw	a2,4(s1)
    80005128:	00003597          	auipc	a1,0x3
    8000512c:	54858593          	addi	a1,a1,1352 # 80008670 <syscalls+0x2c0>
    80005130:	8526                	mv	a0,s1
    80005132:	fffff097          	auipc	ra,0xfffff
    80005136:	c5e080e7          	jalr	-930(ra) # 80003d90 <dirlink>
    8000513a:	00054f63          	bltz	a0,80005158 <create+0x144>
    8000513e:	00492603          	lw	a2,4(s2)
    80005142:	00003597          	auipc	a1,0x3
    80005146:	53658593          	addi	a1,a1,1334 # 80008678 <syscalls+0x2c8>
    8000514a:	8526                	mv	a0,s1
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	c44080e7          	jalr	-956(ra) # 80003d90 <dirlink>
    80005154:	f80557e3          	bgez	a0,800050e2 <create+0xce>
      panic("create dots");
    80005158:	00003517          	auipc	a0,0x3
    8000515c:	52850513          	addi	a0,a0,1320 # 80008680 <syscalls+0x2d0>
    80005160:	ffffb097          	auipc	ra,0xffffb
    80005164:	3e8080e7          	jalr	1000(ra) # 80000548 <panic>
    panic("create: dirlink");
    80005168:	00003517          	auipc	a0,0x3
    8000516c:	52850513          	addi	a0,a0,1320 # 80008690 <syscalls+0x2e0>
    80005170:	ffffb097          	auipc	ra,0xffffb
    80005174:	3d8080e7          	jalr	984(ra) # 80000548 <panic>
    return 0;
    80005178:	84aa                	mv	s1,a0
    8000517a:	b731                	j	80005086 <create+0x72>

000000008000517c <sys_dup>:
{
    8000517c:	7179                	addi	sp,sp,-48
    8000517e:	f406                	sd	ra,40(sp)
    80005180:	f022                	sd	s0,32(sp)
    80005182:	ec26                	sd	s1,24(sp)
    80005184:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005186:	fd840613          	addi	a2,s0,-40
    8000518a:	4581                	li	a1,0
    8000518c:	4501                	li	a0,0
    8000518e:	00000097          	auipc	ra,0x0
    80005192:	ddc080e7          	jalr	-548(ra) # 80004f6a <argfd>
    return -1;
    80005196:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005198:	02054363          	bltz	a0,800051be <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000519c:	fd843503          	ld	a0,-40(s0)
    800051a0:	00000097          	auipc	ra,0x0
    800051a4:	e32080e7          	jalr	-462(ra) # 80004fd2 <fdalloc>
    800051a8:	84aa                	mv	s1,a0
    return -1;
    800051aa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051ac:	00054963          	bltz	a0,800051be <sys_dup+0x42>
  filedup(f);
    800051b0:	fd843503          	ld	a0,-40(s0)
    800051b4:	fffff097          	auipc	ra,0xfffff
    800051b8:	32a080e7          	jalr	810(ra) # 800044de <filedup>
  return fd;
    800051bc:	87a6                	mv	a5,s1
}
    800051be:	853e                	mv	a0,a5
    800051c0:	70a2                	ld	ra,40(sp)
    800051c2:	7402                	ld	s0,32(sp)
    800051c4:	64e2                	ld	s1,24(sp)
    800051c6:	6145                	addi	sp,sp,48
    800051c8:	8082                	ret

00000000800051ca <sys_read>:
{
    800051ca:	7179                	addi	sp,sp,-48
    800051cc:	f406                	sd	ra,40(sp)
    800051ce:	f022                	sd	s0,32(sp)
    800051d0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051d2:	fe840613          	addi	a2,s0,-24
    800051d6:	4581                	li	a1,0
    800051d8:	4501                	li	a0,0
    800051da:	00000097          	auipc	ra,0x0
    800051de:	d90080e7          	jalr	-624(ra) # 80004f6a <argfd>
    return -1;
    800051e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051e4:	04054163          	bltz	a0,80005226 <sys_read+0x5c>
    800051e8:	fe440593          	addi	a1,s0,-28
    800051ec:	4509                	li	a0,2
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	92e080e7          	jalr	-1746(ra) # 80002b1c <argint>
    return -1;
    800051f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051f8:	02054763          	bltz	a0,80005226 <sys_read+0x5c>
    800051fc:	fd840593          	addi	a1,s0,-40
    80005200:	4505                	li	a0,1
    80005202:	ffffe097          	auipc	ra,0xffffe
    80005206:	93c080e7          	jalr	-1732(ra) # 80002b3e <argaddr>
    return -1;
    8000520a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000520c:	00054d63          	bltz	a0,80005226 <sys_read+0x5c>
  return fileread(f, p, n);
    80005210:	fe442603          	lw	a2,-28(s0)
    80005214:	fd843583          	ld	a1,-40(s0)
    80005218:	fe843503          	ld	a0,-24(s0)
    8000521c:	fffff097          	auipc	ra,0xfffff
    80005220:	44e080e7          	jalr	1102(ra) # 8000466a <fileread>
    80005224:	87aa                	mv	a5,a0
}
    80005226:	853e                	mv	a0,a5
    80005228:	70a2                	ld	ra,40(sp)
    8000522a:	7402                	ld	s0,32(sp)
    8000522c:	6145                	addi	sp,sp,48
    8000522e:	8082                	ret

0000000080005230 <sys_write>:
{
    80005230:	7179                	addi	sp,sp,-48
    80005232:	f406                	sd	ra,40(sp)
    80005234:	f022                	sd	s0,32(sp)
    80005236:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005238:	fe840613          	addi	a2,s0,-24
    8000523c:	4581                	li	a1,0
    8000523e:	4501                	li	a0,0
    80005240:	00000097          	auipc	ra,0x0
    80005244:	d2a080e7          	jalr	-726(ra) # 80004f6a <argfd>
    return -1;
    80005248:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000524a:	04054163          	bltz	a0,8000528c <sys_write+0x5c>
    8000524e:	fe440593          	addi	a1,s0,-28
    80005252:	4509                	li	a0,2
    80005254:	ffffe097          	auipc	ra,0xffffe
    80005258:	8c8080e7          	jalr	-1848(ra) # 80002b1c <argint>
    return -1;
    8000525c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000525e:	02054763          	bltz	a0,8000528c <sys_write+0x5c>
    80005262:	fd840593          	addi	a1,s0,-40
    80005266:	4505                	li	a0,1
    80005268:	ffffe097          	auipc	ra,0xffffe
    8000526c:	8d6080e7          	jalr	-1834(ra) # 80002b3e <argaddr>
    return -1;
    80005270:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005272:	00054d63          	bltz	a0,8000528c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005276:	fe442603          	lw	a2,-28(s0)
    8000527a:	fd843583          	ld	a1,-40(s0)
    8000527e:	fe843503          	ld	a0,-24(s0)
    80005282:	fffff097          	auipc	ra,0xfffff
    80005286:	4aa080e7          	jalr	1194(ra) # 8000472c <filewrite>
    8000528a:	87aa                	mv	a5,a0
}
    8000528c:	853e                	mv	a0,a5
    8000528e:	70a2                	ld	ra,40(sp)
    80005290:	7402                	ld	s0,32(sp)
    80005292:	6145                	addi	sp,sp,48
    80005294:	8082                	ret

0000000080005296 <sys_close>:
{
    80005296:	1101                	addi	sp,sp,-32
    80005298:	ec06                	sd	ra,24(sp)
    8000529a:	e822                	sd	s0,16(sp)
    8000529c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000529e:	fe040613          	addi	a2,s0,-32
    800052a2:	fec40593          	addi	a1,s0,-20
    800052a6:	4501                	li	a0,0
    800052a8:	00000097          	auipc	ra,0x0
    800052ac:	cc2080e7          	jalr	-830(ra) # 80004f6a <argfd>
    return -1;
    800052b0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052b2:	02054463          	bltz	a0,800052da <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052b6:	ffffc097          	auipc	ra,0xffffc
    800052ba:	746080e7          	jalr	1862(ra) # 800019fc <myproc>
    800052be:	fec42783          	lw	a5,-20(s0)
    800052c2:	07e9                	addi	a5,a5,26
    800052c4:	078e                	slli	a5,a5,0x3
    800052c6:	97aa                	add	a5,a5,a0
    800052c8:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800052cc:	fe043503          	ld	a0,-32(s0)
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	260080e7          	jalr	608(ra) # 80004530 <fileclose>
  return 0;
    800052d8:	4781                	li	a5,0
}
    800052da:	853e                	mv	a0,a5
    800052dc:	60e2                	ld	ra,24(sp)
    800052de:	6442                	ld	s0,16(sp)
    800052e0:	6105                	addi	sp,sp,32
    800052e2:	8082                	ret

00000000800052e4 <sys_fstat>:
{
    800052e4:	1101                	addi	sp,sp,-32
    800052e6:	ec06                	sd	ra,24(sp)
    800052e8:	e822                	sd	s0,16(sp)
    800052ea:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052ec:	fe840613          	addi	a2,s0,-24
    800052f0:	4581                	li	a1,0
    800052f2:	4501                	li	a0,0
    800052f4:	00000097          	auipc	ra,0x0
    800052f8:	c76080e7          	jalr	-906(ra) # 80004f6a <argfd>
    return -1;
    800052fc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052fe:	02054563          	bltz	a0,80005328 <sys_fstat+0x44>
    80005302:	fe040593          	addi	a1,s0,-32
    80005306:	4505                	li	a0,1
    80005308:	ffffe097          	auipc	ra,0xffffe
    8000530c:	836080e7          	jalr	-1994(ra) # 80002b3e <argaddr>
    return -1;
    80005310:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005312:	00054b63          	bltz	a0,80005328 <sys_fstat+0x44>
  return filestat(f, st);
    80005316:	fe043583          	ld	a1,-32(s0)
    8000531a:	fe843503          	ld	a0,-24(s0)
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	2da080e7          	jalr	730(ra) # 800045f8 <filestat>
    80005326:	87aa                	mv	a5,a0
}
    80005328:	853e                	mv	a0,a5
    8000532a:	60e2                	ld	ra,24(sp)
    8000532c:	6442                	ld	s0,16(sp)
    8000532e:	6105                	addi	sp,sp,32
    80005330:	8082                	ret

0000000080005332 <sys_link>:
{
    80005332:	7169                	addi	sp,sp,-304
    80005334:	f606                	sd	ra,296(sp)
    80005336:	f222                	sd	s0,288(sp)
    80005338:	ee26                	sd	s1,280(sp)
    8000533a:	ea4a                	sd	s2,272(sp)
    8000533c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000533e:	08000613          	li	a2,128
    80005342:	ed040593          	addi	a1,s0,-304
    80005346:	4501                	li	a0,0
    80005348:	ffffe097          	auipc	ra,0xffffe
    8000534c:	818080e7          	jalr	-2024(ra) # 80002b60 <argstr>
    return -1;
    80005350:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005352:	10054e63          	bltz	a0,8000546e <sys_link+0x13c>
    80005356:	08000613          	li	a2,128
    8000535a:	f5040593          	addi	a1,s0,-176
    8000535e:	4505                	li	a0,1
    80005360:	ffffe097          	auipc	ra,0xffffe
    80005364:	800080e7          	jalr	-2048(ra) # 80002b60 <argstr>
    return -1;
    80005368:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000536a:	10054263          	bltz	a0,8000546e <sys_link+0x13c>
  begin_op();
    8000536e:	fffff097          	auipc	ra,0xfffff
    80005372:	cf0080e7          	jalr	-784(ra) # 8000405e <begin_op>
  if((ip = namei(old)) == 0){
    80005376:	ed040513          	addi	a0,s0,-304
    8000537a:	fffff097          	auipc	ra,0xfffff
    8000537e:	ad8080e7          	jalr	-1320(ra) # 80003e52 <namei>
    80005382:	84aa                	mv	s1,a0
    80005384:	c551                	beqz	a0,80005410 <sys_link+0xde>
  ilock(ip);
    80005386:	ffffe097          	auipc	ra,0xffffe
    8000538a:	318080e7          	jalr	792(ra) # 8000369e <ilock>
  if(ip->type == T_DIR){
    8000538e:	04449703          	lh	a4,68(s1)
    80005392:	4785                	li	a5,1
    80005394:	08f70463          	beq	a4,a5,8000541c <sys_link+0xea>
  ip->nlink++;
    80005398:	04a4d783          	lhu	a5,74(s1)
    8000539c:	2785                	addiw	a5,a5,1
    8000539e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053a2:	8526                	mv	a0,s1
    800053a4:	ffffe097          	auipc	ra,0xffffe
    800053a8:	230080e7          	jalr	560(ra) # 800035d4 <iupdate>
  iunlock(ip);
    800053ac:	8526                	mv	a0,s1
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	3b2080e7          	jalr	946(ra) # 80003760 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053b6:	fd040593          	addi	a1,s0,-48
    800053ba:	f5040513          	addi	a0,s0,-176
    800053be:	fffff097          	auipc	ra,0xfffff
    800053c2:	ab2080e7          	jalr	-1358(ra) # 80003e70 <nameiparent>
    800053c6:	892a                	mv	s2,a0
    800053c8:	c935                	beqz	a0,8000543c <sys_link+0x10a>
  ilock(dp);
    800053ca:	ffffe097          	auipc	ra,0xffffe
    800053ce:	2d4080e7          	jalr	724(ra) # 8000369e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053d2:	00092703          	lw	a4,0(s2)
    800053d6:	409c                	lw	a5,0(s1)
    800053d8:	04f71d63          	bne	a4,a5,80005432 <sys_link+0x100>
    800053dc:	40d0                	lw	a2,4(s1)
    800053de:	fd040593          	addi	a1,s0,-48
    800053e2:	854a                	mv	a0,s2
    800053e4:	fffff097          	auipc	ra,0xfffff
    800053e8:	9ac080e7          	jalr	-1620(ra) # 80003d90 <dirlink>
    800053ec:	04054363          	bltz	a0,80005432 <sys_link+0x100>
  iunlockput(dp);
    800053f0:	854a                	mv	a0,s2
    800053f2:	ffffe097          	auipc	ra,0xffffe
    800053f6:	50e080e7          	jalr	1294(ra) # 80003900 <iunlockput>
  iput(ip);
    800053fa:	8526                	mv	a0,s1
    800053fc:	ffffe097          	auipc	ra,0xffffe
    80005400:	45c080e7          	jalr	1116(ra) # 80003858 <iput>
  end_op();
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	cda080e7          	jalr	-806(ra) # 800040de <end_op>
  return 0;
    8000540c:	4781                	li	a5,0
    8000540e:	a085                	j	8000546e <sys_link+0x13c>
    end_op();
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	cce080e7          	jalr	-818(ra) # 800040de <end_op>
    return -1;
    80005418:	57fd                	li	a5,-1
    8000541a:	a891                	j	8000546e <sys_link+0x13c>
    iunlockput(ip);
    8000541c:	8526                	mv	a0,s1
    8000541e:	ffffe097          	auipc	ra,0xffffe
    80005422:	4e2080e7          	jalr	1250(ra) # 80003900 <iunlockput>
    end_op();
    80005426:	fffff097          	auipc	ra,0xfffff
    8000542a:	cb8080e7          	jalr	-840(ra) # 800040de <end_op>
    return -1;
    8000542e:	57fd                	li	a5,-1
    80005430:	a83d                	j	8000546e <sys_link+0x13c>
    iunlockput(dp);
    80005432:	854a                	mv	a0,s2
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	4cc080e7          	jalr	1228(ra) # 80003900 <iunlockput>
  ilock(ip);
    8000543c:	8526                	mv	a0,s1
    8000543e:	ffffe097          	auipc	ra,0xffffe
    80005442:	260080e7          	jalr	608(ra) # 8000369e <ilock>
  ip->nlink--;
    80005446:	04a4d783          	lhu	a5,74(s1)
    8000544a:	37fd                	addiw	a5,a5,-1
    8000544c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005450:	8526                	mv	a0,s1
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	182080e7          	jalr	386(ra) # 800035d4 <iupdate>
  iunlockput(ip);
    8000545a:	8526                	mv	a0,s1
    8000545c:	ffffe097          	auipc	ra,0xffffe
    80005460:	4a4080e7          	jalr	1188(ra) # 80003900 <iunlockput>
  end_op();
    80005464:	fffff097          	auipc	ra,0xfffff
    80005468:	c7a080e7          	jalr	-902(ra) # 800040de <end_op>
  return -1;
    8000546c:	57fd                	li	a5,-1
}
    8000546e:	853e                	mv	a0,a5
    80005470:	70b2                	ld	ra,296(sp)
    80005472:	7412                	ld	s0,288(sp)
    80005474:	64f2                	ld	s1,280(sp)
    80005476:	6952                	ld	s2,272(sp)
    80005478:	6155                	addi	sp,sp,304
    8000547a:	8082                	ret

000000008000547c <sys_unlink>:
{
    8000547c:	7151                	addi	sp,sp,-240
    8000547e:	f586                	sd	ra,232(sp)
    80005480:	f1a2                	sd	s0,224(sp)
    80005482:	eda6                	sd	s1,216(sp)
    80005484:	e9ca                	sd	s2,208(sp)
    80005486:	e5ce                	sd	s3,200(sp)
    80005488:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000548a:	08000613          	li	a2,128
    8000548e:	f3040593          	addi	a1,s0,-208
    80005492:	4501                	li	a0,0
    80005494:	ffffd097          	auipc	ra,0xffffd
    80005498:	6cc080e7          	jalr	1740(ra) # 80002b60 <argstr>
    8000549c:	18054163          	bltz	a0,8000561e <sys_unlink+0x1a2>
  begin_op();
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	bbe080e7          	jalr	-1090(ra) # 8000405e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054a8:	fb040593          	addi	a1,s0,-80
    800054ac:	f3040513          	addi	a0,s0,-208
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	9c0080e7          	jalr	-1600(ra) # 80003e70 <nameiparent>
    800054b8:	84aa                	mv	s1,a0
    800054ba:	c979                	beqz	a0,80005590 <sys_unlink+0x114>
  ilock(dp);
    800054bc:	ffffe097          	auipc	ra,0xffffe
    800054c0:	1e2080e7          	jalr	482(ra) # 8000369e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054c4:	00003597          	auipc	a1,0x3
    800054c8:	1ac58593          	addi	a1,a1,428 # 80008670 <syscalls+0x2c0>
    800054cc:	fb040513          	addi	a0,s0,-80
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	696080e7          	jalr	1686(ra) # 80003b66 <namecmp>
    800054d8:	14050a63          	beqz	a0,8000562c <sys_unlink+0x1b0>
    800054dc:	00003597          	auipc	a1,0x3
    800054e0:	19c58593          	addi	a1,a1,412 # 80008678 <syscalls+0x2c8>
    800054e4:	fb040513          	addi	a0,s0,-80
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	67e080e7          	jalr	1662(ra) # 80003b66 <namecmp>
    800054f0:	12050e63          	beqz	a0,8000562c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054f4:	f2c40613          	addi	a2,s0,-212
    800054f8:	fb040593          	addi	a1,s0,-80
    800054fc:	8526                	mv	a0,s1
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	682080e7          	jalr	1666(ra) # 80003b80 <dirlookup>
    80005506:	892a                	mv	s2,a0
    80005508:	12050263          	beqz	a0,8000562c <sys_unlink+0x1b0>
  ilock(ip);
    8000550c:	ffffe097          	auipc	ra,0xffffe
    80005510:	192080e7          	jalr	402(ra) # 8000369e <ilock>
  if(ip->nlink < 1)
    80005514:	04a91783          	lh	a5,74(s2)
    80005518:	08f05263          	blez	a5,8000559c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000551c:	04491703          	lh	a4,68(s2)
    80005520:	4785                	li	a5,1
    80005522:	08f70563          	beq	a4,a5,800055ac <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005526:	4641                	li	a2,16
    80005528:	4581                	li	a1,0
    8000552a:	fc040513          	addi	a0,s0,-64
    8000552e:	ffffb097          	auipc	ra,0xffffb
    80005532:	7de080e7          	jalr	2014(ra) # 80000d0c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005536:	4741                	li	a4,16
    80005538:	f2c42683          	lw	a3,-212(s0)
    8000553c:	fc040613          	addi	a2,s0,-64
    80005540:	4581                	li	a1,0
    80005542:	8526                	mv	a0,s1
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	506080e7          	jalr	1286(ra) # 80003a4a <writei>
    8000554c:	47c1                	li	a5,16
    8000554e:	0af51563          	bne	a0,a5,800055f8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005552:	04491703          	lh	a4,68(s2)
    80005556:	4785                	li	a5,1
    80005558:	0af70863          	beq	a4,a5,80005608 <sys_unlink+0x18c>
  iunlockput(dp);
    8000555c:	8526                	mv	a0,s1
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	3a2080e7          	jalr	930(ra) # 80003900 <iunlockput>
  ip->nlink--;
    80005566:	04a95783          	lhu	a5,74(s2)
    8000556a:	37fd                	addiw	a5,a5,-1
    8000556c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005570:	854a                	mv	a0,s2
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	062080e7          	jalr	98(ra) # 800035d4 <iupdate>
  iunlockput(ip);
    8000557a:	854a                	mv	a0,s2
    8000557c:	ffffe097          	auipc	ra,0xffffe
    80005580:	384080e7          	jalr	900(ra) # 80003900 <iunlockput>
  end_op();
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	b5a080e7          	jalr	-1190(ra) # 800040de <end_op>
  return 0;
    8000558c:	4501                	li	a0,0
    8000558e:	a84d                	j	80005640 <sys_unlink+0x1c4>
    end_op();
    80005590:	fffff097          	auipc	ra,0xfffff
    80005594:	b4e080e7          	jalr	-1202(ra) # 800040de <end_op>
    return -1;
    80005598:	557d                	li	a0,-1
    8000559a:	a05d                	j	80005640 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000559c:	00003517          	auipc	a0,0x3
    800055a0:	10450513          	addi	a0,a0,260 # 800086a0 <syscalls+0x2f0>
    800055a4:	ffffb097          	auipc	ra,0xffffb
    800055a8:	fa4080e7          	jalr	-92(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055ac:	04c92703          	lw	a4,76(s2)
    800055b0:	02000793          	li	a5,32
    800055b4:	f6e7f9e3          	bgeu	a5,a4,80005526 <sys_unlink+0xaa>
    800055b8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055bc:	4741                	li	a4,16
    800055be:	86ce                	mv	a3,s3
    800055c0:	f1840613          	addi	a2,s0,-232
    800055c4:	4581                	li	a1,0
    800055c6:	854a                	mv	a0,s2
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	38a080e7          	jalr	906(ra) # 80003952 <readi>
    800055d0:	47c1                	li	a5,16
    800055d2:	00f51b63          	bne	a0,a5,800055e8 <sys_unlink+0x16c>
    if(de.inum != 0)
    800055d6:	f1845783          	lhu	a5,-232(s0)
    800055da:	e7a1                	bnez	a5,80005622 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055dc:	29c1                	addiw	s3,s3,16
    800055de:	04c92783          	lw	a5,76(s2)
    800055e2:	fcf9ede3          	bltu	s3,a5,800055bc <sys_unlink+0x140>
    800055e6:	b781                	j	80005526 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800055e8:	00003517          	auipc	a0,0x3
    800055ec:	0d050513          	addi	a0,a0,208 # 800086b8 <syscalls+0x308>
    800055f0:	ffffb097          	auipc	ra,0xffffb
    800055f4:	f58080e7          	jalr	-168(ra) # 80000548 <panic>
    panic("unlink: writei");
    800055f8:	00003517          	auipc	a0,0x3
    800055fc:	0d850513          	addi	a0,a0,216 # 800086d0 <syscalls+0x320>
    80005600:	ffffb097          	auipc	ra,0xffffb
    80005604:	f48080e7          	jalr	-184(ra) # 80000548 <panic>
    dp->nlink--;
    80005608:	04a4d783          	lhu	a5,74(s1)
    8000560c:	37fd                	addiw	a5,a5,-1
    8000560e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005612:	8526                	mv	a0,s1
    80005614:	ffffe097          	auipc	ra,0xffffe
    80005618:	fc0080e7          	jalr	-64(ra) # 800035d4 <iupdate>
    8000561c:	b781                	j	8000555c <sys_unlink+0xe0>
    return -1;
    8000561e:	557d                	li	a0,-1
    80005620:	a005                	j	80005640 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005622:	854a                	mv	a0,s2
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	2dc080e7          	jalr	732(ra) # 80003900 <iunlockput>
  iunlockput(dp);
    8000562c:	8526                	mv	a0,s1
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	2d2080e7          	jalr	722(ra) # 80003900 <iunlockput>
  end_op();
    80005636:	fffff097          	auipc	ra,0xfffff
    8000563a:	aa8080e7          	jalr	-1368(ra) # 800040de <end_op>
  return -1;
    8000563e:	557d                	li	a0,-1
}
    80005640:	70ae                	ld	ra,232(sp)
    80005642:	740e                	ld	s0,224(sp)
    80005644:	64ee                	ld	s1,216(sp)
    80005646:	694e                	ld	s2,208(sp)
    80005648:	69ae                	ld	s3,200(sp)
    8000564a:	616d                	addi	sp,sp,240
    8000564c:	8082                	ret

000000008000564e <sys_open>:

uint64
sys_open(void)
{
    8000564e:	7131                	addi	sp,sp,-192
    80005650:	fd06                	sd	ra,184(sp)
    80005652:	f922                	sd	s0,176(sp)
    80005654:	f526                	sd	s1,168(sp)
    80005656:	f14a                	sd	s2,160(sp)
    80005658:	ed4e                	sd	s3,152(sp)
    8000565a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000565c:	08000613          	li	a2,128
    80005660:	f5040593          	addi	a1,s0,-176
    80005664:	4501                	li	a0,0
    80005666:	ffffd097          	auipc	ra,0xffffd
    8000566a:	4fa080e7          	jalr	1274(ra) # 80002b60 <argstr>
    return -1;
    8000566e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005670:	0c054163          	bltz	a0,80005732 <sys_open+0xe4>
    80005674:	f4c40593          	addi	a1,s0,-180
    80005678:	4505                	li	a0,1
    8000567a:	ffffd097          	auipc	ra,0xffffd
    8000567e:	4a2080e7          	jalr	1186(ra) # 80002b1c <argint>
    80005682:	0a054863          	bltz	a0,80005732 <sys_open+0xe4>

  begin_op();
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	9d8080e7          	jalr	-1576(ra) # 8000405e <begin_op>

  if(omode & O_CREATE){
    8000568e:	f4c42783          	lw	a5,-180(s0)
    80005692:	2007f793          	andi	a5,a5,512
    80005696:	cbdd                	beqz	a5,8000574c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005698:	4681                	li	a3,0
    8000569a:	4601                	li	a2,0
    8000569c:	4589                	li	a1,2
    8000569e:	f5040513          	addi	a0,s0,-176
    800056a2:	00000097          	auipc	ra,0x0
    800056a6:	972080e7          	jalr	-1678(ra) # 80005014 <create>
    800056aa:	892a                	mv	s2,a0
    if(ip == 0){
    800056ac:	c959                	beqz	a0,80005742 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056ae:	04491703          	lh	a4,68(s2)
    800056b2:	478d                	li	a5,3
    800056b4:	00f71763          	bne	a4,a5,800056c2 <sys_open+0x74>
    800056b8:	04695703          	lhu	a4,70(s2)
    800056bc:	47a5                	li	a5,9
    800056be:	0ce7ec63          	bltu	a5,a4,80005796 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056c2:	fffff097          	auipc	ra,0xfffff
    800056c6:	db2080e7          	jalr	-590(ra) # 80004474 <filealloc>
    800056ca:	89aa                	mv	s3,a0
    800056cc:	10050263          	beqz	a0,800057d0 <sys_open+0x182>
    800056d0:	00000097          	auipc	ra,0x0
    800056d4:	902080e7          	jalr	-1790(ra) # 80004fd2 <fdalloc>
    800056d8:	84aa                	mv	s1,a0
    800056da:	0e054663          	bltz	a0,800057c6 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056de:	04491703          	lh	a4,68(s2)
    800056e2:	478d                	li	a5,3
    800056e4:	0cf70463          	beq	a4,a5,800057ac <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056e8:	4789                	li	a5,2
    800056ea:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800056ee:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800056f2:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800056f6:	f4c42783          	lw	a5,-180(s0)
    800056fa:	0017c713          	xori	a4,a5,1
    800056fe:	8b05                	andi	a4,a4,1
    80005700:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005704:	0037f713          	andi	a4,a5,3
    80005708:	00e03733          	snez	a4,a4
    8000570c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005710:	4007f793          	andi	a5,a5,1024
    80005714:	c791                	beqz	a5,80005720 <sys_open+0xd2>
    80005716:	04491703          	lh	a4,68(s2)
    8000571a:	4789                	li	a5,2
    8000571c:	08f70f63          	beq	a4,a5,800057ba <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005720:	854a                	mv	a0,s2
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	03e080e7          	jalr	62(ra) # 80003760 <iunlock>
  end_op();
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	9b4080e7          	jalr	-1612(ra) # 800040de <end_op>

  return fd;
}
    80005732:	8526                	mv	a0,s1
    80005734:	70ea                	ld	ra,184(sp)
    80005736:	744a                	ld	s0,176(sp)
    80005738:	74aa                	ld	s1,168(sp)
    8000573a:	790a                	ld	s2,160(sp)
    8000573c:	69ea                	ld	s3,152(sp)
    8000573e:	6129                	addi	sp,sp,192
    80005740:	8082                	ret
      end_op();
    80005742:	fffff097          	auipc	ra,0xfffff
    80005746:	99c080e7          	jalr	-1636(ra) # 800040de <end_op>
      return -1;
    8000574a:	b7e5                	j	80005732 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000574c:	f5040513          	addi	a0,s0,-176
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	702080e7          	jalr	1794(ra) # 80003e52 <namei>
    80005758:	892a                	mv	s2,a0
    8000575a:	c905                	beqz	a0,8000578a <sys_open+0x13c>
    ilock(ip);
    8000575c:	ffffe097          	auipc	ra,0xffffe
    80005760:	f42080e7          	jalr	-190(ra) # 8000369e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005764:	04491703          	lh	a4,68(s2)
    80005768:	4785                	li	a5,1
    8000576a:	f4f712e3          	bne	a4,a5,800056ae <sys_open+0x60>
    8000576e:	f4c42783          	lw	a5,-180(s0)
    80005772:	dba1                	beqz	a5,800056c2 <sys_open+0x74>
      iunlockput(ip);
    80005774:	854a                	mv	a0,s2
    80005776:	ffffe097          	auipc	ra,0xffffe
    8000577a:	18a080e7          	jalr	394(ra) # 80003900 <iunlockput>
      end_op();
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	960080e7          	jalr	-1696(ra) # 800040de <end_op>
      return -1;
    80005786:	54fd                	li	s1,-1
    80005788:	b76d                	j	80005732 <sys_open+0xe4>
      end_op();
    8000578a:	fffff097          	auipc	ra,0xfffff
    8000578e:	954080e7          	jalr	-1708(ra) # 800040de <end_op>
      return -1;
    80005792:	54fd                	li	s1,-1
    80005794:	bf79                	j	80005732 <sys_open+0xe4>
    iunlockput(ip);
    80005796:	854a                	mv	a0,s2
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	168080e7          	jalr	360(ra) # 80003900 <iunlockput>
    end_op();
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	93e080e7          	jalr	-1730(ra) # 800040de <end_op>
    return -1;
    800057a8:	54fd                	li	s1,-1
    800057aa:	b761                	j	80005732 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057ac:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057b0:	04691783          	lh	a5,70(s2)
    800057b4:	02f99223          	sh	a5,36(s3)
    800057b8:	bf2d                	j	800056f2 <sys_open+0xa4>
    itrunc(ip);
    800057ba:	854a                	mv	a0,s2
    800057bc:	ffffe097          	auipc	ra,0xffffe
    800057c0:	ff0080e7          	jalr	-16(ra) # 800037ac <itrunc>
    800057c4:	bfb1                	j	80005720 <sys_open+0xd2>
      fileclose(f);
    800057c6:	854e                	mv	a0,s3
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	d68080e7          	jalr	-664(ra) # 80004530 <fileclose>
    iunlockput(ip);
    800057d0:	854a                	mv	a0,s2
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	12e080e7          	jalr	302(ra) # 80003900 <iunlockput>
    end_op();
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	904080e7          	jalr	-1788(ra) # 800040de <end_op>
    return -1;
    800057e2:	54fd                	li	s1,-1
    800057e4:	b7b9                	j	80005732 <sys_open+0xe4>

00000000800057e6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057e6:	7175                	addi	sp,sp,-144
    800057e8:	e506                	sd	ra,136(sp)
    800057ea:	e122                	sd	s0,128(sp)
    800057ec:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	870080e7          	jalr	-1936(ra) # 8000405e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057f6:	08000613          	li	a2,128
    800057fa:	f7040593          	addi	a1,s0,-144
    800057fe:	4501                	li	a0,0
    80005800:	ffffd097          	auipc	ra,0xffffd
    80005804:	360080e7          	jalr	864(ra) # 80002b60 <argstr>
    80005808:	02054963          	bltz	a0,8000583a <sys_mkdir+0x54>
    8000580c:	4681                	li	a3,0
    8000580e:	4601                	li	a2,0
    80005810:	4585                	li	a1,1
    80005812:	f7040513          	addi	a0,s0,-144
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	7fe080e7          	jalr	2046(ra) # 80005014 <create>
    8000581e:	cd11                	beqz	a0,8000583a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	0e0080e7          	jalr	224(ra) # 80003900 <iunlockput>
  end_op();
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	8b6080e7          	jalr	-1866(ra) # 800040de <end_op>
  return 0;
    80005830:	4501                	li	a0,0
}
    80005832:	60aa                	ld	ra,136(sp)
    80005834:	640a                	ld	s0,128(sp)
    80005836:	6149                	addi	sp,sp,144
    80005838:	8082                	ret
    end_op();
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	8a4080e7          	jalr	-1884(ra) # 800040de <end_op>
    return -1;
    80005842:	557d                	li	a0,-1
    80005844:	b7fd                	j	80005832 <sys_mkdir+0x4c>

0000000080005846 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005846:	7135                	addi	sp,sp,-160
    80005848:	ed06                	sd	ra,152(sp)
    8000584a:	e922                	sd	s0,144(sp)
    8000584c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	810080e7          	jalr	-2032(ra) # 8000405e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005856:	08000613          	li	a2,128
    8000585a:	f7040593          	addi	a1,s0,-144
    8000585e:	4501                	li	a0,0
    80005860:	ffffd097          	auipc	ra,0xffffd
    80005864:	300080e7          	jalr	768(ra) # 80002b60 <argstr>
    80005868:	04054a63          	bltz	a0,800058bc <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000586c:	f6c40593          	addi	a1,s0,-148
    80005870:	4505                	li	a0,1
    80005872:	ffffd097          	auipc	ra,0xffffd
    80005876:	2aa080e7          	jalr	682(ra) # 80002b1c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000587a:	04054163          	bltz	a0,800058bc <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000587e:	f6840593          	addi	a1,s0,-152
    80005882:	4509                	li	a0,2
    80005884:	ffffd097          	auipc	ra,0xffffd
    80005888:	298080e7          	jalr	664(ra) # 80002b1c <argint>
     argint(1, &major) < 0 ||
    8000588c:	02054863          	bltz	a0,800058bc <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005890:	f6841683          	lh	a3,-152(s0)
    80005894:	f6c41603          	lh	a2,-148(s0)
    80005898:	458d                	li	a1,3
    8000589a:	f7040513          	addi	a0,s0,-144
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	776080e7          	jalr	1910(ra) # 80005014 <create>
     argint(2, &minor) < 0 ||
    800058a6:	c919                	beqz	a0,800058bc <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	058080e7          	jalr	88(ra) # 80003900 <iunlockput>
  end_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	82e080e7          	jalr	-2002(ra) # 800040de <end_op>
  return 0;
    800058b8:	4501                	li	a0,0
    800058ba:	a031                	j	800058c6 <sys_mknod+0x80>
    end_op();
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	822080e7          	jalr	-2014(ra) # 800040de <end_op>
    return -1;
    800058c4:	557d                	li	a0,-1
}
    800058c6:	60ea                	ld	ra,152(sp)
    800058c8:	644a                	ld	s0,144(sp)
    800058ca:	610d                	addi	sp,sp,160
    800058cc:	8082                	ret

00000000800058ce <sys_chdir>:

uint64
sys_chdir(void)
{
    800058ce:	7135                	addi	sp,sp,-160
    800058d0:	ed06                	sd	ra,152(sp)
    800058d2:	e922                	sd	s0,144(sp)
    800058d4:	e526                	sd	s1,136(sp)
    800058d6:	e14a                	sd	s2,128(sp)
    800058d8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058da:	ffffc097          	auipc	ra,0xffffc
    800058de:	122080e7          	jalr	290(ra) # 800019fc <myproc>
    800058e2:	892a                	mv	s2,a0
  
  begin_op();
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	77a080e7          	jalr	1914(ra) # 8000405e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058ec:	08000613          	li	a2,128
    800058f0:	f6040593          	addi	a1,s0,-160
    800058f4:	4501                	li	a0,0
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	26a080e7          	jalr	618(ra) # 80002b60 <argstr>
    800058fe:	04054b63          	bltz	a0,80005954 <sys_chdir+0x86>
    80005902:	f6040513          	addi	a0,s0,-160
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	54c080e7          	jalr	1356(ra) # 80003e52 <namei>
    8000590e:	84aa                	mv	s1,a0
    80005910:	c131                	beqz	a0,80005954 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	d8c080e7          	jalr	-628(ra) # 8000369e <ilock>
  if(ip->type != T_DIR){
    8000591a:	04449703          	lh	a4,68(s1)
    8000591e:	4785                	li	a5,1
    80005920:	04f71063          	bne	a4,a5,80005960 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005924:	8526                	mv	a0,s1
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	e3a080e7          	jalr	-454(ra) # 80003760 <iunlock>
  iput(p->cwd);
    8000592e:	15093503          	ld	a0,336(s2)
    80005932:	ffffe097          	auipc	ra,0xffffe
    80005936:	f26080e7          	jalr	-218(ra) # 80003858 <iput>
  end_op();
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	7a4080e7          	jalr	1956(ra) # 800040de <end_op>
  p->cwd = ip;
    80005942:	14993823          	sd	s1,336(s2)
  return 0;
    80005946:	4501                	li	a0,0
}
    80005948:	60ea                	ld	ra,152(sp)
    8000594a:	644a                	ld	s0,144(sp)
    8000594c:	64aa                	ld	s1,136(sp)
    8000594e:	690a                	ld	s2,128(sp)
    80005950:	610d                	addi	sp,sp,160
    80005952:	8082                	ret
    end_op();
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	78a080e7          	jalr	1930(ra) # 800040de <end_op>
    return -1;
    8000595c:	557d                	li	a0,-1
    8000595e:	b7ed                	j	80005948 <sys_chdir+0x7a>
    iunlockput(ip);
    80005960:	8526                	mv	a0,s1
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	f9e080e7          	jalr	-98(ra) # 80003900 <iunlockput>
    end_op();
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	774080e7          	jalr	1908(ra) # 800040de <end_op>
    return -1;
    80005972:	557d                	li	a0,-1
    80005974:	bfd1                	j	80005948 <sys_chdir+0x7a>

0000000080005976 <sys_exec>:

uint64
sys_exec(void)
{
    80005976:	7145                	addi	sp,sp,-464
    80005978:	e786                	sd	ra,456(sp)
    8000597a:	e3a2                	sd	s0,448(sp)
    8000597c:	ff26                	sd	s1,440(sp)
    8000597e:	fb4a                	sd	s2,432(sp)
    80005980:	f74e                	sd	s3,424(sp)
    80005982:	f352                	sd	s4,416(sp)
    80005984:	ef56                	sd	s5,408(sp)
    80005986:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005988:	08000613          	li	a2,128
    8000598c:	f4040593          	addi	a1,s0,-192
    80005990:	4501                	li	a0,0
    80005992:	ffffd097          	auipc	ra,0xffffd
    80005996:	1ce080e7          	jalr	462(ra) # 80002b60 <argstr>
    return -1;
    8000599a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000599c:	0c054a63          	bltz	a0,80005a70 <sys_exec+0xfa>
    800059a0:	e3840593          	addi	a1,s0,-456
    800059a4:	4505                	li	a0,1
    800059a6:	ffffd097          	auipc	ra,0xffffd
    800059aa:	198080e7          	jalr	408(ra) # 80002b3e <argaddr>
    800059ae:	0c054163          	bltz	a0,80005a70 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800059b2:	10000613          	li	a2,256
    800059b6:	4581                	li	a1,0
    800059b8:	e4040513          	addi	a0,s0,-448
    800059bc:	ffffb097          	auipc	ra,0xffffb
    800059c0:	350080e7          	jalr	848(ra) # 80000d0c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059c4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800059c8:	89a6                	mv	s3,s1
    800059ca:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800059cc:	02000a13          	li	s4,32
    800059d0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059d4:	00391513          	slli	a0,s2,0x3
    800059d8:	e3040593          	addi	a1,s0,-464
    800059dc:	e3843783          	ld	a5,-456(s0)
    800059e0:	953e                	add	a0,a0,a5
    800059e2:	ffffd097          	auipc	ra,0xffffd
    800059e6:	0a0080e7          	jalr	160(ra) # 80002a82 <fetchaddr>
    800059ea:	02054a63          	bltz	a0,80005a1e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800059ee:	e3043783          	ld	a5,-464(s0)
    800059f2:	c3b9                	beqz	a5,80005a38 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059f4:	ffffb097          	auipc	ra,0xffffb
    800059f8:	12c080e7          	jalr	300(ra) # 80000b20 <kalloc>
    800059fc:	85aa                	mv	a1,a0
    800059fe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a02:	cd11                	beqz	a0,80005a1e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a04:	6605                	lui	a2,0x1
    80005a06:	e3043503          	ld	a0,-464(s0)
    80005a0a:	ffffd097          	auipc	ra,0xffffd
    80005a0e:	0ca080e7          	jalr	202(ra) # 80002ad4 <fetchstr>
    80005a12:	00054663          	bltz	a0,80005a1e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005a16:	0905                	addi	s2,s2,1
    80005a18:	09a1                	addi	s3,s3,8
    80005a1a:	fb491be3          	bne	s2,s4,800059d0 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a1e:	10048913          	addi	s2,s1,256
    80005a22:	6088                	ld	a0,0(s1)
    80005a24:	c529                	beqz	a0,80005a6e <sys_exec+0xf8>
    kfree(argv[i]);
    80005a26:	ffffb097          	auipc	ra,0xffffb
    80005a2a:	ffe080e7          	jalr	-2(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a2e:	04a1                	addi	s1,s1,8
    80005a30:	ff2499e3          	bne	s1,s2,80005a22 <sys_exec+0xac>
  return -1;
    80005a34:	597d                	li	s2,-1
    80005a36:	a82d                	j	80005a70 <sys_exec+0xfa>
      argv[i] = 0;
    80005a38:	0a8e                	slli	s5,s5,0x3
    80005a3a:	fc040793          	addi	a5,s0,-64
    80005a3e:	9abe                	add	s5,s5,a5
    80005a40:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a44:	e4040593          	addi	a1,s0,-448
    80005a48:	f4040513          	addi	a0,s0,-192
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	194080e7          	jalr	404(ra) # 80004be0 <exec>
    80005a54:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a56:	10048993          	addi	s3,s1,256
    80005a5a:	6088                	ld	a0,0(s1)
    80005a5c:	c911                	beqz	a0,80005a70 <sys_exec+0xfa>
    kfree(argv[i]);
    80005a5e:	ffffb097          	auipc	ra,0xffffb
    80005a62:	fc6080e7          	jalr	-58(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a66:	04a1                	addi	s1,s1,8
    80005a68:	ff3499e3          	bne	s1,s3,80005a5a <sys_exec+0xe4>
    80005a6c:	a011                	j	80005a70 <sys_exec+0xfa>
  return -1;
    80005a6e:	597d                	li	s2,-1
}
    80005a70:	854a                	mv	a0,s2
    80005a72:	60be                	ld	ra,456(sp)
    80005a74:	641e                	ld	s0,448(sp)
    80005a76:	74fa                	ld	s1,440(sp)
    80005a78:	795a                	ld	s2,432(sp)
    80005a7a:	79ba                	ld	s3,424(sp)
    80005a7c:	7a1a                	ld	s4,416(sp)
    80005a7e:	6afa                	ld	s5,408(sp)
    80005a80:	6179                	addi	sp,sp,464
    80005a82:	8082                	ret

0000000080005a84 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a84:	7139                	addi	sp,sp,-64
    80005a86:	fc06                	sd	ra,56(sp)
    80005a88:	f822                	sd	s0,48(sp)
    80005a8a:	f426                	sd	s1,40(sp)
    80005a8c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a8e:	ffffc097          	auipc	ra,0xffffc
    80005a92:	f6e080e7          	jalr	-146(ra) # 800019fc <myproc>
    80005a96:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005a98:	fd840593          	addi	a1,s0,-40
    80005a9c:	4501                	li	a0,0
    80005a9e:	ffffd097          	auipc	ra,0xffffd
    80005aa2:	0a0080e7          	jalr	160(ra) # 80002b3e <argaddr>
    return -1;
    80005aa6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005aa8:	0e054063          	bltz	a0,80005b88 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005aac:	fc840593          	addi	a1,s0,-56
    80005ab0:	fd040513          	addi	a0,s0,-48
    80005ab4:	fffff097          	auipc	ra,0xfffff
    80005ab8:	dd2080e7          	jalr	-558(ra) # 80004886 <pipealloc>
    return -1;
    80005abc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005abe:	0c054563          	bltz	a0,80005b88 <sys_pipe+0x104>
  fd0 = -1;
    80005ac2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ac6:	fd043503          	ld	a0,-48(s0)
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	508080e7          	jalr	1288(ra) # 80004fd2 <fdalloc>
    80005ad2:	fca42223          	sw	a0,-60(s0)
    80005ad6:	08054c63          	bltz	a0,80005b6e <sys_pipe+0xea>
    80005ada:	fc843503          	ld	a0,-56(s0)
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	4f4080e7          	jalr	1268(ra) # 80004fd2 <fdalloc>
    80005ae6:	fca42023          	sw	a0,-64(s0)
    80005aea:	06054863          	bltz	a0,80005b5a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005aee:	4691                	li	a3,4
    80005af0:	fc440613          	addi	a2,s0,-60
    80005af4:	fd843583          	ld	a1,-40(s0)
    80005af8:	68a8                	ld	a0,80(s1)
    80005afa:	ffffc097          	auipc	ra,0xffffc
    80005afe:	bf6080e7          	jalr	-1034(ra) # 800016f0 <copyout>
    80005b02:	02054063          	bltz	a0,80005b22 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b06:	4691                	li	a3,4
    80005b08:	fc040613          	addi	a2,s0,-64
    80005b0c:	fd843583          	ld	a1,-40(s0)
    80005b10:	0591                	addi	a1,a1,4
    80005b12:	68a8                	ld	a0,80(s1)
    80005b14:	ffffc097          	auipc	ra,0xffffc
    80005b18:	bdc080e7          	jalr	-1060(ra) # 800016f0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b1c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b1e:	06055563          	bgez	a0,80005b88 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005b22:	fc442783          	lw	a5,-60(s0)
    80005b26:	07e9                	addi	a5,a5,26
    80005b28:	078e                	slli	a5,a5,0x3
    80005b2a:	97a6                	add	a5,a5,s1
    80005b2c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b30:	fc042503          	lw	a0,-64(s0)
    80005b34:	0569                	addi	a0,a0,26
    80005b36:	050e                	slli	a0,a0,0x3
    80005b38:	9526                	add	a0,a0,s1
    80005b3a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b3e:	fd043503          	ld	a0,-48(s0)
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	9ee080e7          	jalr	-1554(ra) # 80004530 <fileclose>
    fileclose(wf);
    80005b4a:	fc843503          	ld	a0,-56(s0)
    80005b4e:	fffff097          	auipc	ra,0xfffff
    80005b52:	9e2080e7          	jalr	-1566(ra) # 80004530 <fileclose>
    return -1;
    80005b56:	57fd                	li	a5,-1
    80005b58:	a805                	j	80005b88 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005b5a:	fc442783          	lw	a5,-60(s0)
    80005b5e:	0007c863          	bltz	a5,80005b6e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005b62:	01a78513          	addi	a0,a5,26
    80005b66:	050e                	slli	a0,a0,0x3
    80005b68:	9526                	add	a0,a0,s1
    80005b6a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b6e:	fd043503          	ld	a0,-48(s0)
    80005b72:	fffff097          	auipc	ra,0xfffff
    80005b76:	9be080e7          	jalr	-1602(ra) # 80004530 <fileclose>
    fileclose(wf);
    80005b7a:	fc843503          	ld	a0,-56(s0)
    80005b7e:	fffff097          	auipc	ra,0xfffff
    80005b82:	9b2080e7          	jalr	-1614(ra) # 80004530 <fileclose>
    return -1;
    80005b86:	57fd                	li	a5,-1
}
    80005b88:	853e                	mv	a0,a5
    80005b8a:	70e2                	ld	ra,56(sp)
    80005b8c:	7442                	ld	s0,48(sp)
    80005b8e:	74a2                	ld	s1,40(sp)
    80005b90:	6121                	addi	sp,sp,64
    80005b92:	8082                	ret
	...

0000000080005ba0 <kernelvec>:
    80005ba0:	7111                	addi	sp,sp,-256
    80005ba2:	e006                	sd	ra,0(sp)
    80005ba4:	e40a                	sd	sp,8(sp)
    80005ba6:	e80e                	sd	gp,16(sp)
    80005ba8:	ec12                	sd	tp,24(sp)
    80005baa:	f016                	sd	t0,32(sp)
    80005bac:	f41a                	sd	t1,40(sp)
    80005bae:	f81e                	sd	t2,48(sp)
    80005bb0:	fc22                	sd	s0,56(sp)
    80005bb2:	e0a6                	sd	s1,64(sp)
    80005bb4:	e4aa                	sd	a0,72(sp)
    80005bb6:	e8ae                	sd	a1,80(sp)
    80005bb8:	ecb2                	sd	a2,88(sp)
    80005bba:	f0b6                	sd	a3,96(sp)
    80005bbc:	f4ba                	sd	a4,104(sp)
    80005bbe:	f8be                	sd	a5,112(sp)
    80005bc0:	fcc2                	sd	a6,120(sp)
    80005bc2:	e146                	sd	a7,128(sp)
    80005bc4:	e54a                	sd	s2,136(sp)
    80005bc6:	e94e                	sd	s3,144(sp)
    80005bc8:	ed52                	sd	s4,152(sp)
    80005bca:	f156                	sd	s5,160(sp)
    80005bcc:	f55a                	sd	s6,168(sp)
    80005bce:	f95e                	sd	s7,176(sp)
    80005bd0:	fd62                	sd	s8,184(sp)
    80005bd2:	e1e6                	sd	s9,192(sp)
    80005bd4:	e5ea                	sd	s10,200(sp)
    80005bd6:	e9ee                	sd	s11,208(sp)
    80005bd8:	edf2                	sd	t3,216(sp)
    80005bda:	f1f6                	sd	t4,224(sp)
    80005bdc:	f5fa                	sd	t5,232(sp)
    80005bde:	f9fe                	sd	t6,240(sp)
    80005be0:	d6ffc0ef          	jal	ra,8000294e <kerneltrap>
    80005be4:	6082                	ld	ra,0(sp)
    80005be6:	6122                	ld	sp,8(sp)
    80005be8:	61c2                	ld	gp,16(sp)
    80005bea:	7282                	ld	t0,32(sp)
    80005bec:	7322                	ld	t1,40(sp)
    80005bee:	73c2                	ld	t2,48(sp)
    80005bf0:	7462                	ld	s0,56(sp)
    80005bf2:	6486                	ld	s1,64(sp)
    80005bf4:	6526                	ld	a0,72(sp)
    80005bf6:	65c6                	ld	a1,80(sp)
    80005bf8:	6666                	ld	a2,88(sp)
    80005bfa:	7686                	ld	a3,96(sp)
    80005bfc:	7726                	ld	a4,104(sp)
    80005bfe:	77c6                	ld	a5,112(sp)
    80005c00:	7866                	ld	a6,120(sp)
    80005c02:	688a                	ld	a7,128(sp)
    80005c04:	692a                	ld	s2,136(sp)
    80005c06:	69ca                	ld	s3,144(sp)
    80005c08:	6a6a                	ld	s4,152(sp)
    80005c0a:	7a8a                	ld	s5,160(sp)
    80005c0c:	7b2a                	ld	s6,168(sp)
    80005c0e:	7bca                	ld	s7,176(sp)
    80005c10:	7c6a                	ld	s8,184(sp)
    80005c12:	6c8e                	ld	s9,192(sp)
    80005c14:	6d2e                	ld	s10,200(sp)
    80005c16:	6dce                	ld	s11,208(sp)
    80005c18:	6e6e                	ld	t3,216(sp)
    80005c1a:	7e8e                	ld	t4,224(sp)
    80005c1c:	7f2e                	ld	t5,232(sp)
    80005c1e:	7fce                	ld	t6,240(sp)
    80005c20:	6111                	addi	sp,sp,256
    80005c22:	10200073          	sret
    80005c26:	00000013          	nop
    80005c2a:	00000013          	nop
    80005c2e:	0001                	nop

0000000080005c30 <timervec>:
    80005c30:	34051573          	csrrw	a0,mscratch,a0
    80005c34:	e10c                	sd	a1,0(a0)
    80005c36:	e510                	sd	a2,8(a0)
    80005c38:	e914                	sd	a3,16(a0)
    80005c3a:	710c                	ld	a1,32(a0)
    80005c3c:	7510                	ld	a2,40(a0)
    80005c3e:	6194                	ld	a3,0(a1)
    80005c40:	96b2                	add	a3,a3,a2
    80005c42:	e194                	sd	a3,0(a1)
    80005c44:	4589                	li	a1,2
    80005c46:	14459073          	csrw	sip,a1
    80005c4a:	6914                	ld	a3,16(a0)
    80005c4c:	6510                	ld	a2,8(a0)
    80005c4e:	610c                	ld	a1,0(a0)
    80005c50:	34051573          	csrrw	a0,mscratch,a0
    80005c54:	30200073          	mret
	...

0000000080005c5a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c5a:	1141                	addi	sp,sp,-16
    80005c5c:	e422                	sd	s0,8(sp)
    80005c5e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c60:	0c0007b7          	lui	a5,0xc000
    80005c64:	4705                	li	a4,1
    80005c66:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c68:	c3d8                	sw	a4,4(a5)
}
    80005c6a:	6422                	ld	s0,8(sp)
    80005c6c:	0141                	addi	sp,sp,16
    80005c6e:	8082                	ret

0000000080005c70 <plicinithart>:

void
plicinithart(void)
{
    80005c70:	1141                	addi	sp,sp,-16
    80005c72:	e406                	sd	ra,8(sp)
    80005c74:	e022                	sd	s0,0(sp)
    80005c76:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c78:	ffffc097          	auipc	ra,0xffffc
    80005c7c:	d58080e7          	jalr	-680(ra) # 800019d0 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c80:	0085171b          	slliw	a4,a0,0x8
    80005c84:	0c0027b7          	lui	a5,0xc002
    80005c88:	97ba                	add	a5,a5,a4
    80005c8a:	40200713          	li	a4,1026
    80005c8e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c92:	00d5151b          	slliw	a0,a0,0xd
    80005c96:	0c2017b7          	lui	a5,0xc201
    80005c9a:	953e                	add	a0,a0,a5
    80005c9c:	00052023          	sw	zero,0(a0)
}
    80005ca0:	60a2                	ld	ra,8(sp)
    80005ca2:	6402                	ld	s0,0(sp)
    80005ca4:	0141                	addi	sp,sp,16
    80005ca6:	8082                	ret

0000000080005ca8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ca8:	1141                	addi	sp,sp,-16
    80005caa:	e406                	sd	ra,8(sp)
    80005cac:	e022                	sd	s0,0(sp)
    80005cae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cb0:	ffffc097          	auipc	ra,0xffffc
    80005cb4:	d20080e7          	jalr	-736(ra) # 800019d0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005cb8:	00d5179b          	slliw	a5,a0,0xd
    80005cbc:	0c201537          	lui	a0,0xc201
    80005cc0:	953e                	add	a0,a0,a5
  return irq;
}
    80005cc2:	4148                	lw	a0,4(a0)
    80005cc4:	60a2                	ld	ra,8(sp)
    80005cc6:	6402                	ld	s0,0(sp)
    80005cc8:	0141                	addi	sp,sp,16
    80005cca:	8082                	ret

0000000080005ccc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ccc:	1101                	addi	sp,sp,-32
    80005cce:	ec06                	sd	ra,24(sp)
    80005cd0:	e822                	sd	s0,16(sp)
    80005cd2:	e426                	sd	s1,8(sp)
    80005cd4:	1000                	addi	s0,sp,32
    80005cd6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005cd8:	ffffc097          	auipc	ra,0xffffc
    80005cdc:	cf8080e7          	jalr	-776(ra) # 800019d0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ce0:	00d5151b          	slliw	a0,a0,0xd
    80005ce4:	0c2017b7          	lui	a5,0xc201
    80005ce8:	97aa                	add	a5,a5,a0
    80005cea:	c3c4                	sw	s1,4(a5)
}
    80005cec:	60e2                	ld	ra,24(sp)
    80005cee:	6442                	ld	s0,16(sp)
    80005cf0:	64a2                	ld	s1,8(sp)
    80005cf2:	6105                	addi	sp,sp,32
    80005cf4:	8082                	ret

0000000080005cf6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005cf6:	1141                	addi	sp,sp,-16
    80005cf8:	e406                	sd	ra,8(sp)
    80005cfa:	e022                	sd	s0,0(sp)
    80005cfc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005cfe:	479d                	li	a5,7
    80005d00:	04a7cc63          	blt	a5,a0,80005d58 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005d04:	0001d797          	auipc	a5,0x1d
    80005d08:	2fc78793          	addi	a5,a5,764 # 80023000 <disk>
    80005d0c:	00a78733          	add	a4,a5,a0
    80005d10:	6789                	lui	a5,0x2
    80005d12:	97ba                	add	a5,a5,a4
    80005d14:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005d18:	eba1                	bnez	a5,80005d68 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005d1a:	00451713          	slli	a4,a0,0x4
    80005d1e:	0001f797          	auipc	a5,0x1f
    80005d22:	2e27b783          	ld	a5,738(a5) # 80025000 <disk+0x2000>
    80005d26:	97ba                	add	a5,a5,a4
    80005d28:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005d2c:	0001d797          	auipc	a5,0x1d
    80005d30:	2d478793          	addi	a5,a5,724 # 80023000 <disk>
    80005d34:	97aa                	add	a5,a5,a0
    80005d36:	6509                	lui	a0,0x2
    80005d38:	953e                	add	a0,a0,a5
    80005d3a:	4785                	li	a5,1
    80005d3c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005d40:	0001f517          	auipc	a0,0x1f
    80005d44:	2d850513          	addi	a0,a0,728 # 80025018 <disk+0x2018>
    80005d48:	ffffc097          	auipc	ra,0xffffc
    80005d4c:	64a080e7          	jalr	1610(ra) # 80002392 <wakeup>
}
    80005d50:	60a2                	ld	ra,8(sp)
    80005d52:	6402                	ld	s0,0(sp)
    80005d54:	0141                	addi	sp,sp,16
    80005d56:	8082                	ret
    panic("virtio_disk_intr 1");
    80005d58:	00003517          	auipc	a0,0x3
    80005d5c:	98850513          	addi	a0,a0,-1656 # 800086e0 <syscalls+0x330>
    80005d60:	ffffa097          	auipc	ra,0xffffa
    80005d64:	7e8080e7          	jalr	2024(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005d68:	00003517          	auipc	a0,0x3
    80005d6c:	99050513          	addi	a0,a0,-1648 # 800086f8 <syscalls+0x348>
    80005d70:	ffffa097          	auipc	ra,0xffffa
    80005d74:	7d8080e7          	jalr	2008(ra) # 80000548 <panic>

0000000080005d78 <virtio_disk_init>:
{
    80005d78:	1101                	addi	sp,sp,-32
    80005d7a:	ec06                	sd	ra,24(sp)
    80005d7c:	e822                	sd	s0,16(sp)
    80005d7e:	e426                	sd	s1,8(sp)
    80005d80:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d82:	00003597          	auipc	a1,0x3
    80005d86:	98e58593          	addi	a1,a1,-1650 # 80008710 <syscalls+0x360>
    80005d8a:	0001f517          	auipc	a0,0x1f
    80005d8e:	31e50513          	addi	a0,a0,798 # 800250a8 <disk+0x20a8>
    80005d92:	ffffb097          	auipc	ra,0xffffb
    80005d96:	dee080e7          	jalr	-530(ra) # 80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d9a:	100017b7          	lui	a5,0x10001
    80005d9e:	4398                	lw	a4,0(a5)
    80005da0:	2701                	sext.w	a4,a4
    80005da2:	747277b7          	lui	a5,0x74727
    80005da6:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005daa:	0ef71163          	bne	a4,a5,80005e8c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005dae:	100017b7          	lui	a5,0x10001
    80005db2:	43dc                	lw	a5,4(a5)
    80005db4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005db6:	4705                	li	a4,1
    80005db8:	0ce79a63          	bne	a5,a4,80005e8c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dbc:	100017b7          	lui	a5,0x10001
    80005dc0:	479c                	lw	a5,8(a5)
    80005dc2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005dc4:	4709                	li	a4,2
    80005dc6:	0ce79363          	bne	a5,a4,80005e8c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005dca:	100017b7          	lui	a5,0x10001
    80005dce:	47d8                	lw	a4,12(a5)
    80005dd0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dd2:	554d47b7          	lui	a5,0x554d4
    80005dd6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005dda:	0af71963          	bne	a4,a5,80005e8c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dde:	100017b7          	lui	a5,0x10001
    80005de2:	4705                	li	a4,1
    80005de4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005de6:	470d                	li	a4,3
    80005de8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005dea:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005dec:	c7ffe737          	lui	a4,0xc7ffe
    80005df0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005df4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005df6:	2701                	sext.w	a4,a4
    80005df8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dfa:	472d                	li	a4,11
    80005dfc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dfe:	473d                	li	a4,15
    80005e00:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e02:	6705                	lui	a4,0x1
    80005e04:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e06:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e0a:	5bdc                	lw	a5,52(a5)
    80005e0c:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e0e:	c7d9                	beqz	a5,80005e9c <virtio_disk_init+0x124>
  if(max < NUM)
    80005e10:	471d                	li	a4,7
    80005e12:	08f77d63          	bgeu	a4,a5,80005eac <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e16:	100014b7          	lui	s1,0x10001
    80005e1a:	47a1                	li	a5,8
    80005e1c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005e1e:	6609                	lui	a2,0x2
    80005e20:	4581                	li	a1,0
    80005e22:	0001d517          	auipc	a0,0x1d
    80005e26:	1de50513          	addi	a0,a0,478 # 80023000 <disk>
    80005e2a:	ffffb097          	auipc	ra,0xffffb
    80005e2e:	ee2080e7          	jalr	-286(ra) # 80000d0c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005e32:	0001d717          	auipc	a4,0x1d
    80005e36:	1ce70713          	addi	a4,a4,462 # 80023000 <disk>
    80005e3a:	00c75793          	srli	a5,a4,0xc
    80005e3e:	2781                	sext.w	a5,a5
    80005e40:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005e42:	0001f797          	auipc	a5,0x1f
    80005e46:	1be78793          	addi	a5,a5,446 # 80025000 <disk+0x2000>
    80005e4a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005e4c:	0001d717          	auipc	a4,0x1d
    80005e50:	23470713          	addi	a4,a4,564 # 80023080 <disk+0x80>
    80005e54:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005e56:	0001e717          	auipc	a4,0x1e
    80005e5a:	1aa70713          	addi	a4,a4,426 # 80024000 <disk+0x1000>
    80005e5e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005e60:	4705                	li	a4,1
    80005e62:	00e78c23          	sb	a4,24(a5)
    80005e66:	00e78ca3          	sb	a4,25(a5)
    80005e6a:	00e78d23          	sb	a4,26(a5)
    80005e6e:	00e78da3          	sb	a4,27(a5)
    80005e72:	00e78e23          	sb	a4,28(a5)
    80005e76:	00e78ea3          	sb	a4,29(a5)
    80005e7a:	00e78f23          	sb	a4,30(a5)
    80005e7e:	00e78fa3          	sb	a4,31(a5)
}
    80005e82:	60e2                	ld	ra,24(sp)
    80005e84:	6442                	ld	s0,16(sp)
    80005e86:	64a2                	ld	s1,8(sp)
    80005e88:	6105                	addi	sp,sp,32
    80005e8a:	8082                	ret
    panic("could not find virtio disk");
    80005e8c:	00003517          	auipc	a0,0x3
    80005e90:	89450513          	addi	a0,a0,-1900 # 80008720 <syscalls+0x370>
    80005e94:	ffffa097          	auipc	ra,0xffffa
    80005e98:	6b4080e7          	jalr	1716(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    80005e9c:	00003517          	auipc	a0,0x3
    80005ea0:	8a450513          	addi	a0,a0,-1884 # 80008740 <syscalls+0x390>
    80005ea4:	ffffa097          	auipc	ra,0xffffa
    80005ea8:	6a4080e7          	jalr	1700(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    80005eac:	00003517          	auipc	a0,0x3
    80005eb0:	8b450513          	addi	a0,a0,-1868 # 80008760 <syscalls+0x3b0>
    80005eb4:	ffffa097          	auipc	ra,0xffffa
    80005eb8:	694080e7          	jalr	1684(ra) # 80000548 <panic>

0000000080005ebc <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ebc:	7119                	addi	sp,sp,-128
    80005ebe:	fc86                	sd	ra,120(sp)
    80005ec0:	f8a2                	sd	s0,112(sp)
    80005ec2:	f4a6                	sd	s1,104(sp)
    80005ec4:	f0ca                	sd	s2,96(sp)
    80005ec6:	ecce                	sd	s3,88(sp)
    80005ec8:	e8d2                	sd	s4,80(sp)
    80005eca:	e4d6                	sd	s5,72(sp)
    80005ecc:	e0da                	sd	s6,64(sp)
    80005ece:	fc5e                	sd	s7,56(sp)
    80005ed0:	f862                	sd	s8,48(sp)
    80005ed2:	f466                	sd	s9,40(sp)
    80005ed4:	f06a                	sd	s10,32(sp)
    80005ed6:	0100                	addi	s0,sp,128
    80005ed8:	892a                	mv	s2,a0
    80005eda:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005edc:	00c52c83          	lw	s9,12(a0)
    80005ee0:	001c9c9b          	slliw	s9,s9,0x1
    80005ee4:	1c82                	slli	s9,s9,0x20
    80005ee6:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005eea:	0001f517          	auipc	a0,0x1f
    80005eee:	1be50513          	addi	a0,a0,446 # 800250a8 <disk+0x20a8>
    80005ef2:	ffffb097          	auipc	ra,0xffffb
    80005ef6:	d1e080e7          	jalr	-738(ra) # 80000c10 <acquire>
  for(int i = 0; i < 3; i++){
    80005efa:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005efc:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005efe:	0001db97          	auipc	s7,0x1d
    80005f02:	102b8b93          	addi	s7,s7,258 # 80023000 <disk>
    80005f06:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005f08:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005f0a:	8a4e                	mv	s4,s3
    80005f0c:	a051                	j	80005f90 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005f0e:	00fb86b3          	add	a3,s7,a5
    80005f12:	96da                	add	a3,a3,s6
    80005f14:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005f18:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005f1a:	0207c563          	bltz	a5,80005f44 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005f1e:	2485                	addiw	s1,s1,1
    80005f20:	0711                	addi	a4,a4,4
    80005f22:	23548d63          	beq	s1,s5,8000615c <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80005f26:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005f28:	0001f697          	auipc	a3,0x1f
    80005f2c:	0f068693          	addi	a3,a3,240 # 80025018 <disk+0x2018>
    80005f30:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005f32:	0006c583          	lbu	a1,0(a3)
    80005f36:	fde1                	bnez	a1,80005f0e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005f38:	2785                	addiw	a5,a5,1
    80005f3a:	0685                	addi	a3,a3,1
    80005f3c:	ff879be3          	bne	a5,s8,80005f32 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005f40:	57fd                	li	a5,-1
    80005f42:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005f44:	02905a63          	blez	s1,80005f78 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f48:	f9042503          	lw	a0,-112(s0)
    80005f4c:	00000097          	auipc	ra,0x0
    80005f50:	daa080e7          	jalr	-598(ra) # 80005cf6 <free_desc>
      for(int j = 0; j < i; j++)
    80005f54:	4785                	li	a5,1
    80005f56:	0297d163          	bge	a5,s1,80005f78 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f5a:	f9442503          	lw	a0,-108(s0)
    80005f5e:	00000097          	auipc	ra,0x0
    80005f62:	d98080e7          	jalr	-616(ra) # 80005cf6 <free_desc>
      for(int j = 0; j < i; j++)
    80005f66:	4789                	li	a5,2
    80005f68:	0097d863          	bge	a5,s1,80005f78 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f6c:	f9842503          	lw	a0,-104(s0)
    80005f70:	00000097          	auipc	ra,0x0
    80005f74:	d86080e7          	jalr	-634(ra) # 80005cf6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f78:	0001f597          	auipc	a1,0x1f
    80005f7c:	13058593          	addi	a1,a1,304 # 800250a8 <disk+0x20a8>
    80005f80:	0001f517          	auipc	a0,0x1f
    80005f84:	09850513          	addi	a0,a0,152 # 80025018 <disk+0x2018>
    80005f88:	ffffc097          	auipc	ra,0xffffc
    80005f8c:	284080e7          	jalr	644(ra) # 8000220c <sleep>
  for(int i = 0; i < 3; i++){
    80005f90:	f9040713          	addi	a4,s0,-112
    80005f94:	84ce                	mv	s1,s3
    80005f96:	bf41                	j	80005f26 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80005f98:	4785                	li	a5,1
    80005f9a:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    80005f9e:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80005fa2:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80005fa6:	f9042983          	lw	s3,-112(s0)
    80005faa:	00499493          	slli	s1,s3,0x4
    80005fae:	0001fa17          	auipc	s4,0x1f
    80005fb2:	052a0a13          	addi	s4,s4,82 # 80025000 <disk+0x2000>
    80005fb6:	000a3a83          	ld	s5,0(s4)
    80005fba:	9aa6                	add	s5,s5,s1
    80005fbc:	f8040513          	addi	a0,s0,-128
    80005fc0:	ffffb097          	auipc	ra,0xffffb
    80005fc4:	0de080e7          	jalr	222(ra) # 8000109e <kvmpa>
    80005fc8:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    80005fcc:	000a3783          	ld	a5,0(s4)
    80005fd0:	97a6                	add	a5,a5,s1
    80005fd2:	4741                	li	a4,16
    80005fd4:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005fd6:	000a3783          	ld	a5,0(s4)
    80005fda:	97a6                	add	a5,a5,s1
    80005fdc:	4705                	li	a4,1
    80005fde:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80005fe2:	f9442703          	lw	a4,-108(s0)
    80005fe6:	000a3783          	ld	a5,0(s4)
    80005fea:	97a6                	add	a5,a5,s1
    80005fec:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005ff0:	0712                	slli	a4,a4,0x4
    80005ff2:	000a3783          	ld	a5,0(s4)
    80005ff6:	97ba                	add	a5,a5,a4
    80005ff8:	05890693          	addi	a3,s2,88
    80005ffc:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    80005ffe:	000a3783          	ld	a5,0(s4)
    80006002:	97ba                	add	a5,a5,a4
    80006004:	40000693          	li	a3,1024
    80006008:	c794                	sw	a3,8(a5)
  if(write)
    8000600a:	100d0a63          	beqz	s10,8000611e <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000600e:	0001f797          	auipc	a5,0x1f
    80006012:	ff27b783          	ld	a5,-14(a5) # 80025000 <disk+0x2000>
    80006016:	97ba                	add	a5,a5,a4
    80006018:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000601c:	0001d517          	auipc	a0,0x1d
    80006020:	fe450513          	addi	a0,a0,-28 # 80023000 <disk>
    80006024:	0001f797          	auipc	a5,0x1f
    80006028:	fdc78793          	addi	a5,a5,-36 # 80025000 <disk+0x2000>
    8000602c:	6394                	ld	a3,0(a5)
    8000602e:	96ba                	add	a3,a3,a4
    80006030:	00c6d603          	lhu	a2,12(a3)
    80006034:	00166613          	ori	a2,a2,1
    80006038:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000603c:	f9842683          	lw	a3,-104(s0)
    80006040:	6390                	ld	a2,0(a5)
    80006042:	9732                	add	a4,a4,a2
    80006044:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006048:	20098613          	addi	a2,s3,512
    8000604c:	0612                	slli	a2,a2,0x4
    8000604e:	962a                	add	a2,a2,a0
    80006050:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006054:	00469713          	slli	a4,a3,0x4
    80006058:	6394                	ld	a3,0(a5)
    8000605a:	96ba                	add	a3,a3,a4
    8000605c:	6589                	lui	a1,0x2
    8000605e:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80006062:	94ae                	add	s1,s1,a1
    80006064:	94aa                	add	s1,s1,a0
    80006066:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006068:	6394                	ld	a3,0(a5)
    8000606a:	96ba                	add	a3,a3,a4
    8000606c:	4585                	li	a1,1
    8000606e:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006070:	6394                	ld	a3,0(a5)
    80006072:	96ba                	add	a3,a3,a4
    80006074:	4509                	li	a0,2
    80006076:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000607a:	6394                	ld	a3,0(a5)
    8000607c:	9736                	add	a4,a4,a3
    8000607e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006082:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006086:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000608a:	6794                	ld	a3,8(a5)
    8000608c:	0026d703          	lhu	a4,2(a3)
    80006090:	8b1d                	andi	a4,a4,7
    80006092:	2709                	addiw	a4,a4,2
    80006094:	0706                	slli	a4,a4,0x1
    80006096:	9736                	add	a4,a4,a3
    80006098:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    8000609c:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800060a0:	6798                	ld	a4,8(a5)
    800060a2:	00275783          	lhu	a5,2(a4)
    800060a6:	2785                	addiw	a5,a5,1
    800060a8:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060ac:	100017b7          	lui	a5,0x10001
    800060b0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060b4:	00492703          	lw	a4,4(s2)
    800060b8:	4785                	li	a5,1
    800060ba:	02f71163          	bne	a4,a5,800060dc <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    800060be:	0001f997          	auipc	s3,0x1f
    800060c2:	fea98993          	addi	s3,s3,-22 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800060c6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800060c8:	85ce                	mv	a1,s3
    800060ca:	854a                	mv	a0,s2
    800060cc:	ffffc097          	auipc	ra,0xffffc
    800060d0:	140080e7          	jalr	320(ra) # 8000220c <sleep>
  while(b->disk == 1) {
    800060d4:	00492783          	lw	a5,4(s2)
    800060d8:	fe9788e3          	beq	a5,s1,800060c8 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    800060dc:	f9042483          	lw	s1,-112(s0)
    800060e0:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    800060e4:	00479713          	slli	a4,a5,0x4
    800060e8:	0001d797          	auipc	a5,0x1d
    800060ec:	f1878793          	addi	a5,a5,-232 # 80023000 <disk>
    800060f0:	97ba                	add	a5,a5,a4
    800060f2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800060f6:	0001f917          	auipc	s2,0x1f
    800060fa:	f0a90913          	addi	s2,s2,-246 # 80025000 <disk+0x2000>
    free_desc(i);
    800060fe:	8526                	mv	a0,s1
    80006100:	00000097          	auipc	ra,0x0
    80006104:	bf6080e7          	jalr	-1034(ra) # 80005cf6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006108:	0492                	slli	s1,s1,0x4
    8000610a:	00093783          	ld	a5,0(s2)
    8000610e:	94be                	add	s1,s1,a5
    80006110:	00c4d783          	lhu	a5,12(s1)
    80006114:	8b85                	andi	a5,a5,1
    80006116:	cf89                	beqz	a5,80006130 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    80006118:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000611c:	b7cd                	j	800060fe <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000611e:	0001f797          	auipc	a5,0x1f
    80006122:	ee27b783          	ld	a5,-286(a5) # 80025000 <disk+0x2000>
    80006126:	97ba                	add	a5,a5,a4
    80006128:	4689                	li	a3,2
    8000612a:	00d79623          	sh	a3,12(a5)
    8000612e:	b5fd                	j	8000601c <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006130:	0001f517          	auipc	a0,0x1f
    80006134:	f7850513          	addi	a0,a0,-136 # 800250a8 <disk+0x20a8>
    80006138:	ffffb097          	auipc	ra,0xffffb
    8000613c:	b8c080e7          	jalr	-1140(ra) # 80000cc4 <release>
}
    80006140:	70e6                	ld	ra,120(sp)
    80006142:	7446                	ld	s0,112(sp)
    80006144:	74a6                	ld	s1,104(sp)
    80006146:	7906                	ld	s2,96(sp)
    80006148:	69e6                	ld	s3,88(sp)
    8000614a:	6a46                	ld	s4,80(sp)
    8000614c:	6aa6                	ld	s5,72(sp)
    8000614e:	6b06                	ld	s6,64(sp)
    80006150:	7be2                	ld	s7,56(sp)
    80006152:	7c42                	ld	s8,48(sp)
    80006154:	7ca2                	ld	s9,40(sp)
    80006156:	7d02                	ld	s10,32(sp)
    80006158:	6109                	addi	sp,sp,128
    8000615a:	8082                	ret
  if(write)
    8000615c:	e20d1ee3          	bnez	s10,80005f98 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006160:	f8042023          	sw	zero,-128(s0)
    80006164:	bd2d                	j	80005f9e <virtio_disk_rw+0xe2>

0000000080006166 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006166:	1101                	addi	sp,sp,-32
    80006168:	ec06                	sd	ra,24(sp)
    8000616a:	e822                	sd	s0,16(sp)
    8000616c:	e426                	sd	s1,8(sp)
    8000616e:	e04a                	sd	s2,0(sp)
    80006170:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006172:	0001f517          	auipc	a0,0x1f
    80006176:	f3650513          	addi	a0,a0,-202 # 800250a8 <disk+0x20a8>
    8000617a:	ffffb097          	auipc	ra,0xffffb
    8000617e:	a96080e7          	jalr	-1386(ra) # 80000c10 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006182:	0001f717          	auipc	a4,0x1f
    80006186:	e7e70713          	addi	a4,a4,-386 # 80025000 <disk+0x2000>
    8000618a:	02075783          	lhu	a5,32(a4)
    8000618e:	6b18                	ld	a4,16(a4)
    80006190:	00275683          	lhu	a3,2(a4)
    80006194:	8ebd                	xor	a3,a3,a5
    80006196:	8a9d                	andi	a3,a3,7
    80006198:	cab9                	beqz	a3,800061ee <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000619a:	0001d917          	auipc	s2,0x1d
    8000619e:	e6690913          	addi	s2,s2,-410 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800061a2:	0001f497          	auipc	s1,0x1f
    800061a6:	e5e48493          	addi	s1,s1,-418 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800061aa:	078e                	slli	a5,a5,0x3
    800061ac:	97ba                	add	a5,a5,a4
    800061ae:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800061b0:	20078713          	addi	a4,a5,512
    800061b4:	0712                	slli	a4,a4,0x4
    800061b6:	974a                	add	a4,a4,s2
    800061b8:	03074703          	lbu	a4,48(a4)
    800061bc:	ef21                	bnez	a4,80006214 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800061be:	20078793          	addi	a5,a5,512
    800061c2:	0792                	slli	a5,a5,0x4
    800061c4:	97ca                	add	a5,a5,s2
    800061c6:	7798                	ld	a4,40(a5)
    800061c8:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800061cc:	7788                	ld	a0,40(a5)
    800061ce:	ffffc097          	auipc	ra,0xffffc
    800061d2:	1c4080e7          	jalr	452(ra) # 80002392 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800061d6:	0204d783          	lhu	a5,32(s1)
    800061da:	2785                	addiw	a5,a5,1
    800061dc:	8b9d                	andi	a5,a5,7
    800061de:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800061e2:	6898                	ld	a4,16(s1)
    800061e4:	00275683          	lhu	a3,2(a4)
    800061e8:	8a9d                	andi	a3,a3,7
    800061ea:	fcf690e3          	bne	a3,a5,800061aa <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061ee:	10001737          	lui	a4,0x10001
    800061f2:	533c                	lw	a5,96(a4)
    800061f4:	8b8d                	andi	a5,a5,3
    800061f6:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800061f8:	0001f517          	auipc	a0,0x1f
    800061fc:	eb050513          	addi	a0,a0,-336 # 800250a8 <disk+0x20a8>
    80006200:	ffffb097          	auipc	ra,0xffffb
    80006204:	ac4080e7          	jalr	-1340(ra) # 80000cc4 <release>
}
    80006208:	60e2                	ld	ra,24(sp)
    8000620a:	6442                	ld	s0,16(sp)
    8000620c:	64a2                	ld	s1,8(sp)
    8000620e:	6902                	ld	s2,0(sp)
    80006210:	6105                	addi	sp,sp,32
    80006212:	8082                	ret
      panic("virtio_disk_intr status");
    80006214:	00002517          	auipc	a0,0x2
    80006218:	56c50513          	addi	a0,a0,1388 # 80008780 <syscalls+0x3d0>
    8000621c:	ffffa097          	auipc	ra,0xffffa
    80006220:	32c080e7          	jalr	812(ra) # 80000548 <panic>
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
