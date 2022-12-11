
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	89013103          	ld	sp,-1904(sp) # 80008890 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000060:	cc478793          	addi	a5,a5,-828 # 80005d20 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e7c78793          	addi	a5,a5,-388 # 80000f22 <main>
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
    80000110:	b68080e7          	jalr	-1176(ra) # 80000c74 <acquire>
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
    8000012a:	414080e7          	jalr	1044(ra) # 8000253a <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00001097          	auipc	ra,0x1
    8000013a:	80e080e7          	jalr	-2034(ra) # 80000944 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	bda080e7          	jalr	-1062(ra) # 80000d28 <release>

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
    800001a2:	ad6080e7          	jalr	-1322(ra) # 80000c74 <acquire>
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
    800001d2:	874080e7          	jalr	-1932(ra) # 80001a42 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	0a4080e7          	jalr	164(ra) # 80002282 <sleep>
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
    8000021e:	2ca080e7          	jalr	714(ra) # 800024e4 <either_copyout>
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
    8000023a:	af2080e7          	jalr	-1294(ra) # 80000d28 <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	adc080e7          	jalr	-1316(ra) # 80000d28 <release>
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
    8000029a:	5c8080e7          	jalr	1480(ra) # 8000085e <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	5b6080e7          	jalr	1462(ra) # 8000085e <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	5aa080e7          	jalr	1450(ra) # 8000085e <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	5a0080e7          	jalr	1440(ra) # 8000085e <uartputc_sync>
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
    800002e2:	996080e7          	jalr	-1642(ra) # 80000c74 <acquire>

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
    80000300:	294080e7          	jalr	660(ra) # 80002590 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	a1c080e7          	jalr	-1508(ra) # 80000d28 <release>
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
    80000454:	fb8080e7          	jalr	-72(ra) # 80002408 <wakeup>
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
    80000476:	772080e7          	jalr	1906(ra) # 80000be4 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	394080e7          	jalr	916(ra) # 8000080e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00022797          	auipc	a5,0x22
    80000486:	d2e78793          	addi	a5,a5,-722 # 800221b0 <devsw>
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
    800004c8:	b9460613          	addi	a2,a2,-1132 # 80008058 <digits>
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

0000000080000548 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000552:	00011497          	auipc	s1,0x11
    80000556:	38648493          	addi	s1,s1,902 # 800118d8 <pr>
    8000055a:	00008597          	auipc	a1,0x8
    8000055e:	abe58593          	addi	a1,a1,-1346 # 80008018 <etext+0x18>
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	680080e7          	jalr	1664(ra) # 80000be4 <initlock>
  pr.locking = 1;
    8000056c:	4785                	li	a5,1
    8000056e:	cc9c                	sw	a5,24(s1)
}
    80000570:	60e2                	ld	ra,24(sp)
    80000572:	6442                	ld	s0,16(sp)
    80000574:	64a2                	ld	s1,8(sp)
    80000576:	6105                	addi	sp,sp,32
    80000578:	8082                	ret

000000008000057a <backtrace>:

void
backtrace(void)
{
    8000057a:	7179                	addi	sp,sp,-48
    8000057c:	f406                	sd	ra,40(sp)
    8000057e:	f022                	sd	s0,32(sp)
    80000580:	ec26                	sd	s1,24(sp)
    80000582:	e84a                	sd	s2,16(sp)
    80000584:	e44e                	sd	s3,8(sp)
    80000586:	1800                	addi	s0,sp,48
/** fp = frame pointer，指向函数栈顶 */
static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0" : "=r" (x) );
    80000588:	84a2                	mv	s1,s0
  uint64 fp = r_fp();
  uint64 top = PGROUNDUP(fp);
    8000058a:	6905                	lui	s2,0x1
    8000058c:	197d                	addi	s2,s2,-1
    8000058e:	9926                	add	s2,s2,s1
    80000590:	77fd                	lui	a5,0xfffff
    80000592:	00f97933          	and	s2,s2,a5

  printf("backtrace:\n");
    80000596:	00008517          	auipc	a0,0x8
    8000059a:	a8a50513          	addi	a0,a0,-1398 # 80008020 <etext+0x20>
    8000059e:	00000097          	auipc	ra,0x0
    800005a2:	08a080e7          	jalr	138(ra) # 80000628 <printf>
  while(fp < top) {
    800005a6:	0324f163          	bgeu	s1,s2,800005c8 <backtrace+0x4e>
    uint64 retaddr = fp-8;
    printf("%p\n", *(uint64*)retaddr);
    800005aa:	00008997          	auipc	s3,0x8
    800005ae:	a8698993          	addi	s3,s3,-1402 # 80008030 <etext+0x30>
    800005b2:	ff84b583          	ld	a1,-8(s1)
    800005b6:	854e                	mv	a0,s3
    800005b8:	00000097          	auipc	ra,0x0
    800005bc:	070080e7          	jalr	112(ra) # 80000628 <printf>
    
    fp = *((uint64*)(fp-16));
    800005c0:	ff04b483          	ld	s1,-16(s1)
  while(fp < top) {
    800005c4:	ff24e7e3          	bltu	s1,s2,800005b2 <backtrace+0x38>
  }
}
    800005c8:	70a2                	ld	ra,40(sp)
    800005ca:	7402                	ld	s0,32(sp)
    800005cc:	64e2                	ld	s1,24(sp)
    800005ce:	6942                	ld	s2,16(sp)
    800005d0:	69a2                	ld	s3,8(sp)
    800005d2:	6145                	addi	sp,sp,48
    800005d4:	8082                	ret

00000000800005d6 <panic>:
{
    800005d6:	1101                	addi	sp,sp,-32
    800005d8:	ec06                	sd	ra,24(sp)
    800005da:	e822                	sd	s0,16(sp)
    800005dc:	e426                	sd	s1,8(sp)
    800005de:	1000                	addi	s0,sp,32
    800005e0:	84aa                	mv	s1,a0
  pr.locking = 0;
    800005e2:	00011797          	auipc	a5,0x11
    800005e6:	3007a723          	sw	zero,782(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    800005ea:	00008517          	auipc	a0,0x8
    800005ee:	a4e50513          	addi	a0,a0,-1458 # 80008038 <etext+0x38>
    800005f2:	00000097          	auipc	ra,0x0
    800005f6:	036080e7          	jalr	54(ra) # 80000628 <printf>
  printf(s);
    800005fa:	8526                	mv	a0,s1
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	02c080e7          	jalr	44(ra) # 80000628 <printf>
  printf("\n");
    80000604:	00008517          	auipc	a0,0x8
    80000608:	adc50513          	addi	a0,a0,-1316 # 800080e0 <digits+0x88>
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	01c080e7          	jalr	28(ra) # 80000628 <printf>
  backtrace();
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f66080e7          	jalr	-154(ra) # 8000057a <backtrace>
  panicked = 1; // freeze uart output from other CPUs
    8000061c:	4785                	li	a5,1
    8000061e:	00009717          	auipc	a4,0x9
    80000622:	9ef72123          	sw	a5,-1566(a4) # 80009000 <panicked>
  for(;;)
    80000626:	a001                	j	80000626 <panic+0x50>

0000000080000628 <printf>:
{
    80000628:	7131                	addi	sp,sp,-192
    8000062a:	fc86                	sd	ra,120(sp)
    8000062c:	f8a2                	sd	s0,112(sp)
    8000062e:	f4a6                	sd	s1,104(sp)
    80000630:	f0ca                	sd	s2,96(sp)
    80000632:	ecce                	sd	s3,88(sp)
    80000634:	e8d2                	sd	s4,80(sp)
    80000636:	e4d6                	sd	s5,72(sp)
    80000638:	e0da                	sd	s6,64(sp)
    8000063a:	fc5e                	sd	s7,56(sp)
    8000063c:	f862                	sd	s8,48(sp)
    8000063e:	f466                	sd	s9,40(sp)
    80000640:	f06a                	sd	s10,32(sp)
    80000642:	ec6e                	sd	s11,24(sp)
    80000644:	0100                	addi	s0,sp,128
    80000646:	8a2a                	mv	s4,a0
    80000648:	e40c                	sd	a1,8(s0)
    8000064a:	e810                	sd	a2,16(s0)
    8000064c:	ec14                	sd	a3,24(s0)
    8000064e:	f018                	sd	a4,32(s0)
    80000650:	f41c                	sd	a5,40(s0)
    80000652:	03043823          	sd	a6,48(s0)
    80000656:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    8000065a:	00011d97          	auipc	s11,0x11
    8000065e:	296dad83          	lw	s11,662(s11) # 800118f0 <pr+0x18>
  if(locking)
    80000662:	020d9b63          	bnez	s11,80000698 <printf+0x70>
  if (fmt == 0)
    80000666:	040a0263          	beqz	s4,800006aa <printf+0x82>
  va_start(ap, fmt);
    8000066a:	00840793          	addi	a5,s0,8
    8000066e:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000672:	000a4503          	lbu	a0,0(s4)
    80000676:	16050263          	beqz	a0,800007da <printf+0x1b2>
    8000067a:	4481                	li	s1,0
    if(c != '%'){
    8000067c:	02500a93          	li	s5,37
    switch(c){
    80000680:	07000b13          	li	s6,112
  consputc('x');
    80000684:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000686:	00008b97          	auipc	s7,0x8
    8000068a:	9d2b8b93          	addi	s7,s7,-1582 # 80008058 <digits>
    switch(c){
    8000068e:	07300c93          	li	s9,115
    80000692:	06400c13          	li	s8,100
    80000696:	a82d                	j	800006d0 <printf+0xa8>
    acquire(&pr.lock);
    80000698:	00011517          	auipc	a0,0x11
    8000069c:	24050513          	addi	a0,a0,576 # 800118d8 <pr>
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	5d4080e7          	jalr	1492(ra) # 80000c74 <acquire>
    800006a8:	bf7d                	j	80000666 <printf+0x3e>
    panic("null fmt");
    800006aa:	00008517          	auipc	a0,0x8
    800006ae:	99e50513          	addi	a0,a0,-1634 # 80008048 <etext+0x48>
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	f24080e7          	jalr	-220(ra) # 800005d6 <panic>
      consputc(c);
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bcc080e7          	jalr	-1076(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800006c2:	2485                	addiw	s1,s1,1
    800006c4:	009a07b3          	add	a5,s4,s1
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	10050763          	beqz	a0,800007da <printf+0x1b2>
    if(c != '%'){
    800006d0:	ff5515e3          	bne	a0,s5,800006ba <printf+0x92>
    c = fmt[++i] & 0xff;
    800006d4:	2485                	addiw	s1,s1,1
    800006d6:	009a07b3          	add	a5,s4,s1
    800006da:	0007c783          	lbu	a5,0(a5)
    800006de:	0007891b          	sext.w	s2,a5
    if(c == 0)
    800006e2:	cfe5                	beqz	a5,800007da <printf+0x1b2>
    switch(c){
    800006e4:	05678a63          	beq	a5,s6,80000738 <printf+0x110>
    800006e8:	02fb7663          	bgeu	s6,a5,80000714 <printf+0xec>
    800006ec:	09978963          	beq	a5,s9,8000077e <printf+0x156>
    800006f0:	07800713          	li	a4,120
    800006f4:	0ce79863          	bne	a5,a4,800007c4 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	4605                	li	a2,1
    80000706:	85ea                	mv	a1,s10
    80000708:	4388                	lw	a0,0(a5)
    8000070a:	00000097          	auipc	ra,0x0
    8000070e:	d9c080e7          	jalr	-612(ra) # 800004a6 <printint>
      break;
    80000712:	bf45                	j	800006c2 <printf+0x9a>
    switch(c){
    80000714:	0b578263          	beq	a5,s5,800007b8 <printf+0x190>
    80000718:	0b879663          	bne	a5,s8,800007c4 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000071c:	f8843783          	ld	a5,-120(s0)
    80000720:	00878713          	addi	a4,a5,8
    80000724:	f8e43423          	sd	a4,-120(s0)
    80000728:	4605                	li	a2,1
    8000072a:	45a9                	li	a1,10
    8000072c:	4388                	lw	a0,0(a5)
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	d78080e7          	jalr	-648(ra) # 800004a6 <printint>
      break;
    80000736:	b771                	j	800006c2 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000738:	f8843783          	ld	a5,-120(s0)
    8000073c:	00878713          	addi	a4,a5,8
    80000740:	f8e43423          	sd	a4,-120(s0)
    80000744:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000748:	03000513          	li	a0,48
    8000074c:	00000097          	auipc	ra,0x0
    80000750:	b3a080e7          	jalr	-1222(ra) # 80000286 <consputc>
  consputc('x');
    80000754:	07800513          	li	a0,120
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	b2e080e7          	jalr	-1234(ra) # 80000286 <consputc>
    80000760:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000762:	03c9d793          	srli	a5,s3,0x3c
    80000766:	97de                	add	a5,a5,s7
    80000768:	0007c503          	lbu	a0,0(a5)
    8000076c:	00000097          	auipc	ra,0x0
    80000770:	b1a080e7          	jalr	-1254(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000774:	0992                	slli	s3,s3,0x4
    80000776:	397d                	addiw	s2,s2,-1
    80000778:	fe0915e3          	bnez	s2,80000762 <printf+0x13a>
    8000077c:	b799                	j	800006c2 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    8000077e:	f8843783          	ld	a5,-120(s0)
    80000782:	00878713          	addi	a4,a5,8
    80000786:	f8e43423          	sd	a4,-120(s0)
    8000078a:	0007b903          	ld	s2,0(a5)
    8000078e:	00090e63          	beqz	s2,800007aa <printf+0x182>
      for(; *s; s++)
    80000792:	00094503          	lbu	a0,0(s2) # 1000 <_entry-0x7ffff000>
    80000796:	d515                	beqz	a0,800006c2 <printf+0x9a>
        consputc(*s);
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	aee080e7          	jalr	-1298(ra) # 80000286 <consputc>
      for(; *s; s++)
    800007a0:	0905                	addi	s2,s2,1
    800007a2:	00094503          	lbu	a0,0(s2)
    800007a6:	f96d                	bnez	a0,80000798 <printf+0x170>
    800007a8:	bf29                	j	800006c2 <printf+0x9a>
        s = "(null)";
    800007aa:	00008917          	auipc	s2,0x8
    800007ae:	89690913          	addi	s2,s2,-1898 # 80008040 <etext+0x40>
      for(; *s; s++)
    800007b2:	02800513          	li	a0,40
    800007b6:	b7cd                	j	80000798 <printf+0x170>
      consputc('%');
    800007b8:	8556                	mv	a0,s5
    800007ba:	00000097          	auipc	ra,0x0
    800007be:	acc080e7          	jalr	-1332(ra) # 80000286 <consputc>
      break;
    800007c2:	b701                	j	800006c2 <printf+0x9a>
      consputc('%');
    800007c4:	8556                	mv	a0,s5
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	ac0080e7          	jalr	-1344(ra) # 80000286 <consputc>
      consputc(c);
    800007ce:	854a                	mv	a0,s2
    800007d0:	00000097          	auipc	ra,0x0
    800007d4:	ab6080e7          	jalr	-1354(ra) # 80000286 <consputc>
      break;
    800007d8:	b5ed                	j	800006c2 <printf+0x9a>
  if(locking)
    800007da:	020d9163          	bnez	s11,800007fc <printf+0x1d4>
}
    800007de:	70e6                	ld	ra,120(sp)
    800007e0:	7446                	ld	s0,112(sp)
    800007e2:	74a6                	ld	s1,104(sp)
    800007e4:	7906                	ld	s2,96(sp)
    800007e6:	69e6                	ld	s3,88(sp)
    800007e8:	6a46                	ld	s4,80(sp)
    800007ea:	6aa6                	ld	s5,72(sp)
    800007ec:	6b06                	ld	s6,64(sp)
    800007ee:	7be2                	ld	s7,56(sp)
    800007f0:	7c42                	ld	s8,48(sp)
    800007f2:	7ca2                	ld	s9,40(sp)
    800007f4:	7d02                	ld	s10,32(sp)
    800007f6:	6de2                	ld	s11,24(sp)
    800007f8:	6129                	addi	sp,sp,192
    800007fa:	8082                	ret
    release(&pr.lock);
    800007fc:	00011517          	auipc	a0,0x11
    80000800:	0dc50513          	addi	a0,a0,220 # 800118d8 <pr>
    80000804:	00000097          	auipc	ra,0x0
    80000808:	524080e7          	jalr	1316(ra) # 80000d28 <release>
}
    8000080c:	bfc9                	j	800007de <printf+0x1b6>

000000008000080e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000080e:	1141                	addi	sp,sp,-16
    80000810:	e406                	sd	ra,8(sp)
    80000812:	e022                	sd	s0,0(sp)
    80000814:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000081e:	f8000713          	li	a4,-128
    80000822:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000826:	470d                	li	a4,3
    80000828:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000082c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000830:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000834:	469d                	li	a3,7
    80000836:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000083a:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000083e:	00008597          	auipc	a1,0x8
    80000842:	83258593          	addi	a1,a1,-1998 # 80008070 <digits+0x18>
    80000846:	00011517          	auipc	a0,0x11
    8000084a:	0b250513          	addi	a0,a0,178 # 800118f8 <uart_tx_lock>
    8000084e:	00000097          	auipc	ra,0x0
    80000852:	396080e7          	jalr	918(ra) # 80000be4 <initlock>
}
    80000856:	60a2                	ld	ra,8(sp)
    80000858:	6402                	ld	s0,0(sp)
    8000085a:	0141                	addi	sp,sp,16
    8000085c:	8082                	ret

000000008000085e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000085e:	1101                	addi	sp,sp,-32
    80000860:	ec06                	sd	ra,24(sp)
    80000862:	e822                	sd	s0,16(sp)
    80000864:	e426                	sd	s1,8(sp)
    80000866:	1000                	addi	s0,sp,32
    80000868:	84aa                	mv	s1,a0
  push_off();
    8000086a:	00000097          	auipc	ra,0x0
    8000086e:	3be080e7          	jalr	958(ra) # 80000c28 <push_off>

  if(panicked){
    80000872:	00008797          	auipc	a5,0x8
    80000876:	78e7a783          	lw	a5,1934(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000087a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000087e:	c391                	beqz	a5,80000882 <uartputc_sync+0x24>
    for(;;)
    80000880:	a001                	j	80000880 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000882:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000886:	0ff7f793          	andi	a5,a5,255
    8000088a:	0207f793          	andi	a5,a5,32
    8000088e:	dbf5                	beqz	a5,80000882 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000890:	0ff4f793          	andi	a5,s1,255
    80000894:	10000737          	lui	a4,0x10000
    80000898:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000089c:	00000097          	auipc	ra,0x0
    800008a0:	42c080e7          	jalr	1068(ra) # 80000cc8 <pop_off>
}
    800008a4:	60e2                	ld	ra,24(sp)
    800008a6:	6442                	ld	s0,16(sp)
    800008a8:	64a2                	ld	s1,8(sp)
    800008aa:	6105                	addi	sp,sp,32
    800008ac:	8082                	ret

00000000800008ae <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008ae:	00008797          	auipc	a5,0x8
    800008b2:	7567a783          	lw	a5,1878(a5) # 80009004 <uart_tx_r>
    800008b6:	00008717          	auipc	a4,0x8
    800008ba:	75272703          	lw	a4,1874(a4) # 80009008 <uart_tx_w>
    800008be:	08f70263          	beq	a4,a5,80000942 <uartstart+0x94>
{
    800008c2:	7139                	addi	sp,sp,-64
    800008c4:	fc06                	sd	ra,56(sp)
    800008c6:	f822                	sd	s0,48(sp)
    800008c8:	f426                	sd	s1,40(sp)
    800008ca:	f04a                	sd	s2,32(sp)
    800008cc:	ec4e                	sd	s3,24(sp)
    800008ce:	e852                	sd	s4,16(sp)
    800008d0:	e456                	sd	s5,8(sp)
    800008d2:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d4:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    800008d8:	00011a17          	auipc	s4,0x11
    800008dc:	020a0a13          	addi	s4,s4,32 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008e0:	00008497          	auipc	s1,0x8
    800008e4:	72448493          	addi	s1,s1,1828 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800008e8:	00008997          	auipc	s3,0x8
    800008ec:	72098993          	addi	s3,s3,1824 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008f0:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    800008f4:	0ff77713          	andi	a4,a4,255
    800008f8:	02077713          	andi	a4,a4,32
    800008fc:	cb15                	beqz	a4,80000930 <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    800008fe:	00fa0733          	add	a4,s4,a5
    80000902:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000906:	2785                	addiw	a5,a5,1
    80000908:	41f7d71b          	sraiw	a4,a5,0x1f
    8000090c:	01b7571b          	srliw	a4,a4,0x1b
    80000910:	9fb9                	addw	a5,a5,a4
    80000912:	8bfd                	andi	a5,a5,31
    80000914:	9f99                	subw	a5,a5,a4
    80000916:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	aee080e7          	jalr	-1298(ra) # 80002408 <wakeup>
    
    WriteReg(THR, c);
    80000922:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80000926:	409c                	lw	a5,0(s1)
    80000928:	0009a703          	lw	a4,0(s3)
    8000092c:	fcf712e3          	bne	a4,a5,800008f0 <uartstart+0x42>
  }
}
    80000930:	70e2                	ld	ra,56(sp)
    80000932:	7442                	ld	s0,48(sp)
    80000934:	74a2                	ld	s1,40(sp)
    80000936:	7902                	ld	s2,32(sp)
    80000938:	69e2                	ld	s3,24(sp)
    8000093a:	6a42                	ld	s4,16(sp)
    8000093c:	6aa2                	ld	s5,8(sp)
    8000093e:	6121                	addi	sp,sp,64
    80000940:	8082                	ret
    80000942:	8082                	ret

0000000080000944 <uartputc>:
{
    80000944:	7179                	addi	sp,sp,-48
    80000946:	f406                	sd	ra,40(sp)
    80000948:	f022                	sd	s0,32(sp)
    8000094a:	ec26                	sd	s1,24(sp)
    8000094c:	e84a                	sd	s2,16(sp)
    8000094e:	e44e                	sd	s3,8(sp)
    80000950:	e052                	sd	s4,0(sp)
    80000952:	1800                	addi	s0,sp,48
    80000954:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80000956:	00011517          	auipc	a0,0x11
    8000095a:	fa250513          	addi	a0,a0,-94 # 800118f8 <uart_tx_lock>
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	316080e7          	jalr	790(ra) # 80000c74 <acquire>
  if(panicked){
    80000966:	00008797          	auipc	a5,0x8
    8000096a:	69a7a783          	lw	a5,1690(a5) # 80009000 <panicked>
    8000096e:	c391                	beqz	a5,80000972 <uartputc+0x2e>
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000972:	00008717          	auipc	a4,0x8
    80000976:	69672703          	lw	a4,1686(a4) # 80009008 <uart_tx_w>
    8000097a:	0017079b          	addiw	a5,a4,1
    8000097e:	41f7d69b          	sraiw	a3,a5,0x1f
    80000982:	01b6d69b          	srliw	a3,a3,0x1b
    80000986:	9fb5                	addw	a5,a5,a3
    80000988:	8bfd                	andi	a5,a5,31
    8000098a:	9f95                	subw	a5,a5,a3
    8000098c:	00008697          	auipc	a3,0x8
    80000990:	6786a683          	lw	a3,1656(a3) # 80009004 <uart_tx_r>
    80000994:	04f69263          	bne	a3,a5,800009d8 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000998:	00011a17          	auipc	s4,0x11
    8000099c:	f60a0a13          	addi	s4,s4,-160 # 800118f8 <uart_tx_lock>
    800009a0:	00008497          	auipc	s1,0x8
    800009a4:	66448493          	addi	s1,s1,1636 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009a8:	00008917          	auipc	s2,0x8
    800009ac:	66090913          	addi	s2,s2,1632 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    800009b0:	85d2                	mv	a1,s4
    800009b2:	8526                	mv	a0,s1
    800009b4:	00002097          	auipc	ra,0x2
    800009b8:	8ce080e7          	jalr	-1842(ra) # 80002282 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009bc:	00092703          	lw	a4,0(s2)
    800009c0:	0017079b          	addiw	a5,a4,1
    800009c4:	41f7d69b          	sraiw	a3,a5,0x1f
    800009c8:	01b6d69b          	srliw	a3,a3,0x1b
    800009cc:	9fb5                	addw	a5,a5,a3
    800009ce:	8bfd                	andi	a5,a5,31
    800009d0:	9f95                	subw	a5,a5,a3
    800009d2:	4094                	lw	a3,0(s1)
    800009d4:	fcf68ee3          	beq	a3,a5,800009b0 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    800009d8:	00011497          	auipc	s1,0x11
    800009dc:	f2048493          	addi	s1,s1,-224 # 800118f8 <uart_tx_lock>
    800009e0:	9726                	add	a4,a4,s1
    800009e2:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    800009e6:	00008717          	auipc	a4,0x8
    800009ea:	62f72123          	sw	a5,1570(a4) # 80009008 <uart_tx_w>
      uartstart();
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	ec0080e7          	jalr	-320(ra) # 800008ae <uartstart>
      release(&uart_tx_lock);
    800009f6:	8526                	mv	a0,s1
    800009f8:	00000097          	auipc	ra,0x0
    800009fc:	330080e7          	jalr	816(ra) # 80000d28 <release>
}
    80000a00:	70a2                	ld	ra,40(sp)
    80000a02:	7402                	ld	s0,32(sp)
    80000a04:	64e2                	ld	s1,24(sp)
    80000a06:	6942                	ld	s2,16(sp)
    80000a08:	69a2                	ld	s3,8(sp)
    80000a0a:	6a02                	ld	s4,0(sp)
    80000a0c:	6145                	addi	sp,sp,48
    80000a0e:	8082                	ret

0000000080000a10 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a10:	1141                	addi	sp,sp,-16
    80000a12:	e422                	sd	s0,8(sp)
    80000a14:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a16:	100007b7          	lui	a5,0x10000
    80000a1a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1e:	8b85                	andi	a5,a5,1
    80000a20:	cb91                	beqz	a5,80000a34 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a22:	100007b7          	lui	a5,0x10000
    80000a26:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a2a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a2e:	6422                	ld	s0,8(sp)
    80000a30:	0141                	addi	sp,sp,16
    80000a32:	8082                	ret
    return -1;
    80000a34:	557d                	li	a0,-1
    80000a36:	bfe5                	j	80000a2e <uartgetc+0x1e>

0000000080000a38 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a38:	1101                	addi	sp,sp,-32
    80000a3a:	ec06                	sd	ra,24(sp)
    80000a3c:	e822                	sd	s0,16(sp)
    80000a3e:	e426                	sd	s1,8(sp)
    80000a40:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a42:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	fcc080e7          	jalr	-52(ra) # 80000a10 <uartgetc>
    if(c == -1)
    80000a4c:	00950763          	beq	a0,s1,80000a5a <uartintr+0x22>
      break;
    consoleintr(c);
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	878080e7          	jalr	-1928(ra) # 800002c8 <consoleintr>
  while(1){
    80000a58:	b7f5                	j	80000a44 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a5a:	00011497          	auipc	s1,0x11
    80000a5e:	e9e48493          	addi	s1,s1,-354 # 800118f8 <uart_tx_lock>
    80000a62:	8526                	mv	a0,s1
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	210080e7          	jalr	528(ra) # 80000c74 <acquire>
  uartstart();
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	e42080e7          	jalr	-446(ra) # 800008ae <uartstart>
  release(&uart_tx_lock);
    80000a74:	8526                	mv	a0,s1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2b2080e7          	jalr	690(ra) # 80000d28 <release>
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6105                	addi	sp,sp,32
    80000a86:	8082                	ret

0000000080000a88 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a88:	1101                	addi	sp,sp,-32
    80000a8a:	ec06                	sd	ra,24(sp)
    80000a8c:	e822                	sd	s0,16(sp)
    80000a8e:	e426                	sd	s1,8(sp)
    80000a90:	e04a                	sd	s2,0(sp)
    80000a92:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a94:	03451793          	slli	a5,a0,0x34
    80000a98:	ebb9                	bnez	a5,80000aee <kfree+0x66>
    80000a9a:	84aa                	mv	s1,a0
    80000a9c:	00026797          	auipc	a5,0x26
    80000aa0:	56478793          	addi	a5,a5,1380 # 80027000 <end>
    80000aa4:	04f56563          	bltu	a0,a5,80000aee <kfree+0x66>
    80000aa8:	47c5                	li	a5,17
    80000aaa:	07ee                	slli	a5,a5,0x1b
    80000aac:	04f57163          	bgeu	a0,a5,80000aee <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000ab0:	6605                	lui	a2,0x1
    80000ab2:	4585                	li	a1,1
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	2bc080e7          	jalr	700(ra) # 80000d70 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000abc:	00011917          	auipc	s2,0x11
    80000ac0:	e7490913          	addi	s2,s2,-396 # 80011930 <kmem>
    80000ac4:	854a                	mv	a0,s2
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	1ae080e7          	jalr	430(ra) # 80000c74 <acquire>
  r->next = kmem.freelist;
    80000ace:	01893783          	ld	a5,24(s2)
    80000ad2:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ad4:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ad8:	854a                	mv	a0,s2
    80000ada:	00000097          	auipc	ra,0x0
    80000ade:	24e080e7          	jalr	590(ra) # 80000d28 <release>
}
    80000ae2:	60e2                	ld	ra,24(sp)
    80000ae4:	6442                	ld	s0,16(sp)
    80000ae6:	64a2                	ld	s1,8(sp)
    80000ae8:	6902                	ld	s2,0(sp)
    80000aea:	6105                	addi	sp,sp,32
    80000aec:	8082                	ret
    panic("kfree");
    80000aee:	00007517          	auipc	a0,0x7
    80000af2:	58a50513          	addi	a0,a0,1418 # 80008078 <digits+0x20>
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	ae0080e7          	jalr	-1312(ra) # 800005d6 <panic>

0000000080000afe <freerange>:
{
    80000afe:	7179                	addi	sp,sp,-48
    80000b00:	f406                	sd	ra,40(sp)
    80000b02:	f022                	sd	s0,32(sp)
    80000b04:	ec26                	sd	s1,24(sp)
    80000b06:	e84a                	sd	s2,16(sp)
    80000b08:	e44e                	sd	s3,8(sp)
    80000b0a:	e052                	sd	s4,0(sp)
    80000b0c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b0e:	6785                	lui	a5,0x1
    80000b10:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b14:	94aa                	add	s1,s1,a0
    80000b16:	757d                	lui	a0,0xfffff
    80000b18:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b1a:	94be                	add	s1,s1,a5
    80000b1c:	0095ee63          	bltu	a1,s1,80000b38 <freerange+0x3a>
    80000b20:	892e                	mv	s2,a1
    kfree(p);
    80000b22:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b24:	6985                	lui	s3,0x1
    kfree(p);
    80000b26:	01448533          	add	a0,s1,s4
    80000b2a:	00000097          	auipc	ra,0x0
    80000b2e:	f5e080e7          	jalr	-162(ra) # 80000a88 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b32:	94ce                	add	s1,s1,s3
    80000b34:	fe9979e3          	bgeu	s2,s1,80000b26 <freerange+0x28>
}
    80000b38:	70a2                	ld	ra,40(sp)
    80000b3a:	7402                	ld	s0,32(sp)
    80000b3c:	64e2                	ld	s1,24(sp)
    80000b3e:	6942                	ld	s2,16(sp)
    80000b40:	69a2                	ld	s3,8(sp)
    80000b42:	6a02                	ld	s4,0(sp)
    80000b44:	6145                	addi	sp,sp,48
    80000b46:	8082                	ret

0000000080000b48 <kinit>:
{
    80000b48:	1141                	addi	sp,sp,-16
    80000b4a:	e406                	sd	ra,8(sp)
    80000b4c:	e022                	sd	s0,0(sp)
    80000b4e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b50:	00007597          	auipc	a1,0x7
    80000b54:	53058593          	addi	a1,a1,1328 # 80008080 <digits+0x28>
    80000b58:	00011517          	auipc	a0,0x11
    80000b5c:	dd850513          	addi	a0,a0,-552 # 80011930 <kmem>
    80000b60:	00000097          	auipc	ra,0x0
    80000b64:	084080e7          	jalr	132(ra) # 80000be4 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b68:	45c5                	li	a1,17
    80000b6a:	05ee                	slli	a1,a1,0x1b
    80000b6c:	00026517          	auipc	a0,0x26
    80000b70:	49450513          	addi	a0,a0,1172 # 80027000 <end>
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	f8a080e7          	jalr	-118(ra) # 80000afe <freerange>
}
    80000b7c:	60a2                	ld	ra,8(sp)
    80000b7e:	6402                	ld	s0,0(sp)
    80000b80:	0141                	addi	sp,sp,16
    80000b82:	8082                	ret

0000000080000b84 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b8e:	00011497          	auipc	s1,0x11
    80000b92:	da248493          	addi	s1,s1,-606 # 80011930 <kmem>
    80000b96:	8526                	mv	a0,s1
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	0dc080e7          	jalr	220(ra) # 80000c74 <acquire>
  r = kmem.freelist;
    80000ba0:	6c84                	ld	s1,24(s1)
  if(r)
    80000ba2:	c885                	beqz	s1,80000bd2 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000ba4:	609c                	ld	a5,0(s1)
    80000ba6:	00011517          	auipc	a0,0x11
    80000baa:	d8a50513          	addi	a0,a0,-630 # 80011930 <kmem>
    80000bae:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	178080e7          	jalr	376(ra) # 80000d28 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bb8:	6605                	lui	a2,0x1
    80000bba:	4595                	li	a1,5
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	00000097          	auipc	ra,0x0
    80000bc2:	1b2080e7          	jalr	434(ra) # 80000d70 <memset>
  return (void*)r;
}
    80000bc6:	8526                	mv	a0,s1
    80000bc8:	60e2                	ld	ra,24(sp)
    80000bca:	6442                	ld	s0,16(sp)
    80000bcc:	64a2                	ld	s1,8(sp)
    80000bce:	6105                	addi	sp,sp,32
    80000bd0:	8082                	ret
  release(&kmem.lock);
    80000bd2:	00011517          	auipc	a0,0x11
    80000bd6:	d5e50513          	addi	a0,a0,-674 # 80011930 <kmem>
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	14e080e7          	jalr	334(ra) # 80000d28 <release>
  if(r)
    80000be2:	b7d5                	j	80000bc6 <kalloc+0x42>

0000000080000be4 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000be4:	1141                	addi	sp,sp,-16
    80000be6:	e422                	sd	s0,8(sp)
    80000be8:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bea:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bec:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bf0:	00053823          	sd	zero,16(a0)
}
    80000bf4:	6422                	ld	s0,8(sp)
    80000bf6:	0141                	addi	sp,sp,16
    80000bf8:	8082                	ret

0000000080000bfa <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bfa:	411c                	lw	a5,0(a0)
    80000bfc:	e399                	bnez	a5,80000c02 <holding+0x8>
    80000bfe:	4501                	li	a0,0
  return r;
}
    80000c00:	8082                	ret
{
    80000c02:	1101                	addi	sp,sp,-32
    80000c04:	ec06                	sd	ra,24(sp)
    80000c06:	e822                	sd	s0,16(sp)
    80000c08:	e426                	sd	s1,8(sp)
    80000c0a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c0c:	6904                	ld	s1,16(a0)
    80000c0e:	00001097          	auipc	ra,0x1
    80000c12:	e18080e7          	jalr	-488(ra) # 80001a26 <mycpu>
    80000c16:	40a48533          	sub	a0,s1,a0
    80000c1a:	00153513          	seqz	a0,a0
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret

0000000080000c28 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c32:	100024f3          	csrr	s1,sstatus
    80000c36:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c3a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c3c:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	de6080e7          	jalr	-538(ra) # 80001a26 <mycpu>
    80000c48:	5d3c                	lw	a5,120(a0)
    80000c4a:	cf89                	beqz	a5,80000c64 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c4c:	00001097          	auipc	ra,0x1
    80000c50:	dda080e7          	jalr	-550(ra) # 80001a26 <mycpu>
    80000c54:	5d3c                	lw	a5,120(a0)
    80000c56:	2785                	addiw	a5,a5,1
    80000c58:	dd3c                	sw	a5,120(a0)
}
    80000c5a:	60e2                	ld	ra,24(sp)
    80000c5c:	6442                	ld	s0,16(sp)
    80000c5e:	64a2                	ld	s1,8(sp)
    80000c60:	6105                	addi	sp,sp,32
    80000c62:	8082                	ret
    mycpu()->intena = old;
    80000c64:	00001097          	auipc	ra,0x1
    80000c68:	dc2080e7          	jalr	-574(ra) # 80001a26 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c6c:	8085                	srli	s1,s1,0x1
    80000c6e:	8885                	andi	s1,s1,1
    80000c70:	dd64                	sw	s1,124(a0)
    80000c72:	bfe9                	j	80000c4c <push_off+0x24>

0000000080000c74 <acquire>:
{
    80000c74:	1101                	addi	sp,sp,-32
    80000c76:	ec06                	sd	ra,24(sp)
    80000c78:	e822                	sd	s0,16(sp)
    80000c7a:	e426                	sd	s1,8(sp)
    80000c7c:	1000                	addi	s0,sp,32
    80000c7e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	fa8080e7          	jalr	-88(ra) # 80000c28 <push_off>
  if(holding(lk))
    80000c88:	8526                	mv	a0,s1
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	f70080e7          	jalr	-144(ra) # 80000bfa <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c92:	4705                	li	a4,1
  if(holding(lk))
    80000c94:	e115                	bnez	a0,80000cb8 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c96:	87ba                	mv	a5,a4
    80000c98:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c9c:	2781                	sext.w	a5,a5
    80000c9e:	ffe5                	bnez	a5,80000c96 <acquire+0x22>
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000ca4:	00001097          	auipc	ra,0x1
    80000ca8:	d82080e7          	jalr	-638(ra) # 80001a26 <mycpu>
    80000cac:	e888                	sd	a0,16(s1)
}
    80000cae:	60e2                	ld	ra,24(sp)
    80000cb0:	6442                	ld	s0,16(sp)
    80000cb2:	64a2                	ld	s1,8(sp)
    80000cb4:	6105                	addi	sp,sp,32
    80000cb6:	8082                	ret
    panic("acquire");
    80000cb8:	00007517          	auipc	a0,0x7
    80000cbc:	3d050513          	addi	a0,a0,976 # 80008088 <digits+0x30>
    80000cc0:	00000097          	auipc	ra,0x0
    80000cc4:	916080e7          	jalr	-1770(ra) # 800005d6 <panic>

0000000080000cc8 <pop_off>:

void
pop_off(void)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e406                	sd	ra,8(sp)
    80000ccc:	e022                	sd	s0,0(sp)
    80000cce:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cd0:	00001097          	auipc	ra,0x1
    80000cd4:	d56080e7          	jalr	-682(ra) # 80001a26 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cdc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cde:	e78d                	bnez	a5,80000d08 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ce0:	5d3c                	lw	a5,120(a0)
    80000ce2:	02f05b63          	blez	a5,80000d18 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000ce6:	37fd                	addiw	a5,a5,-1
    80000ce8:	0007871b          	sext.w	a4,a5
    80000cec:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cee:	eb09                	bnez	a4,80000d00 <pop_off+0x38>
    80000cf0:	5d7c                	lw	a5,124(a0)
    80000cf2:	c799                	beqz	a5,80000d00 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cf8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cfc:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d00:	60a2                	ld	ra,8(sp)
    80000d02:	6402                	ld	s0,0(sp)
    80000d04:	0141                	addi	sp,sp,16
    80000d06:	8082                	ret
    panic("pop_off - interruptible");
    80000d08:	00007517          	auipc	a0,0x7
    80000d0c:	38850513          	addi	a0,a0,904 # 80008090 <digits+0x38>
    80000d10:	00000097          	auipc	ra,0x0
    80000d14:	8c6080e7          	jalr	-1850(ra) # 800005d6 <panic>
    panic("pop_off");
    80000d18:	00007517          	auipc	a0,0x7
    80000d1c:	39050513          	addi	a0,a0,912 # 800080a8 <digits+0x50>
    80000d20:	00000097          	auipc	ra,0x0
    80000d24:	8b6080e7          	jalr	-1866(ra) # 800005d6 <panic>

0000000080000d28 <release>:
{
    80000d28:	1101                	addi	sp,sp,-32
    80000d2a:	ec06                	sd	ra,24(sp)
    80000d2c:	e822                	sd	s0,16(sp)
    80000d2e:	e426                	sd	s1,8(sp)
    80000d30:	1000                	addi	s0,sp,32
    80000d32:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d34:	00000097          	auipc	ra,0x0
    80000d38:	ec6080e7          	jalr	-314(ra) # 80000bfa <holding>
    80000d3c:	c115                	beqz	a0,80000d60 <release+0x38>
  lk->cpu = 0;
    80000d3e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d42:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d46:	0f50000f          	fence	iorw,ow
    80000d4a:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d4e:	00000097          	auipc	ra,0x0
    80000d52:	f7a080e7          	jalr	-134(ra) # 80000cc8 <pop_off>
}
    80000d56:	60e2                	ld	ra,24(sp)
    80000d58:	6442                	ld	s0,16(sp)
    80000d5a:	64a2                	ld	s1,8(sp)
    80000d5c:	6105                	addi	sp,sp,32
    80000d5e:	8082                	ret
    panic("release");
    80000d60:	00007517          	auipc	a0,0x7
    80000d64:	35050513          	addi	a0,a0,848 # 800080b0 <digits+0x58>
    80000d68:	00000097          	auipc	ra,0x0
    80000d6c:	86e080e7          	jalr	-1938(ra) # 800005d6 <panic>

0000000080000d70 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d70:	1141                	addi	sp,sp,-16
    80000d72:	e422                	sd	s0,8(sp)
    80000d74:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d76:	ce09                	beqz	a2,80000d90 <memset+0x20>
    80000d78:	87aa                	mv	a5,a0
    80000d7a:	fff6071b          	addiw	a4,a2,-1
    80000d7e:	1702                	slli	a4,a4,0x20
    80000d80:	9301                	srli	a4,a4,0x20
    80000d82:	0705                	addi	a4,a4,1
    80000d84:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d86:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d8a:	0785                	addi	a5,a5,1
    80000d8c:	fee79de3          	bne	a5,a4,80000d86 <memset+0x16>
  }
  return dst;
}
    80000d90:	6422                	ld	s0,8(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d9c:	ca05                	beqz	a2,80000dcc <memcmp+0x36>
    80000d9e:	fff6069b          	addiw	a3,a2,-1
    80000da2:	1682                	slli	a3,a3,0x20
    80000da4:	9281                	srli	a3,a3,0x20
    80000da6:	0685                	addi	a3,a3,1
    80000da8:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	0005c703          	lbu	a4,0(a1)
    80000db2:	00e79863          	bne	a5,a4,80000dc2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dba:	fed518e3          	bne	a0,a3,80000daa <memcmp+0x14>
  }

  return 0;
    80000dbe:	4501                	li	a0,0
    80000dc0:	a019                	j	80000dc6 <memcmp+0x30>
      return *s1 - *s2;
    80000dc2:	40e7853b          	subw	a0,a5,a4
}
    80000dc6:	6422                	ld	s0,8(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret
  return 0;
    80000dcc:	4501                	li	a0,0
    80000dce:	bfe5                	j	80000dc6 <memcmp+0x30>

0000000080000dd0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dd0:	1141                	addi	sp,sp,-16
    80000dd2:	e422                	sd	s0,8(sp)
    80000dd4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dd6:	00a5f963          	bgeu	a1,a0,80000de8 <memmove+0x18>
    80000dda:	02061713          	slli	a4,a2,0x20
    80000dde:	9301                	srli	a4,a4,0x20
    80000de0:	00e587b3          	add	a5,a1,a4
    80000de4:	02f56563          	bltu	a0,a5,80000e0e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000de8:	fff6069b          	addiw	a3,a2,-1
    80000dec:	ce11                	beqz	a2,80000e08 <memmove+0x38>
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	0685                	addi	a3,a3,1
    80000df4:	96ae                	add	a3,a3,a1
    80000df6:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	0785                	addi	a5,a5,1
    80000dfc:	fff5c703          	lbu	a4,-1(a1)
    80000e00:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e04:	fed59ae3          	bne	a1,a3,80000df8 <memmove+0x28>

  return dst;
}
    80000e08:	6422                	ld	s0,8(sp)
    80000e0a:	0141                	addi	sp,sp,16
    80000e0c:	8082                	ret
    d += n;
    80000e0e:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	da75                	beqz	a2,80000e08 <memmove+0x38>
    80000e16:	02069613          	slli	a2,a3,0x20
    80000e1a:	9201                	srli	a2,a2,0x20
    80000e1c:	fff64613          	not	a2,a2
    80000e20:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e22:	17fd                	addi	a5,a5,-1
    80000e24:	177d                	addi	a4,a4,-1
    80000e26:	0007c683          	lbu	a3,0(a5)
    80000e2a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e2e:	fec79ae3          	bne	a5,a2,80000e22 <memmove+0x52>
    80000e32:	bfd9                	j	80000e08 <memmove+0x38>

0000000080000e34 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e34:	1141                	addi	sp,sp,-16
    80000e36:	e406                	sd	ra,8(sp)
    80000e38:	e022                	sd	s0,0(sp)
    80000e3a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e3c:	00000097          	auipc	ra,0x0
    80000e40:	f94080e7          	jalr	-108(ra) # 80000dd0 <memmove>
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e422                	sd	s0,8(sp)
    80000e50:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e52:	ce11                	beqz	a2,80000e6e <strncmp+0x22>
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf89                	beqz	a5,80000e72 <strncmp+0x26>
    80000e5a:	0005c703          	lbu	a4,0(a1)
    80000e5e:	00f71a63          	bne	a4,a5,80000e72 <strncmp+0x26>
    n--, p++, q++;
    80000e62:	367d                	addiw	a2,a2,-1
    80000e64:	0505                	addi	a0,a0,1
    80000e66:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e68:	f675                	bnez	a2,80000e54 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e6a:	4501                	li	a0,0
    80000e6c:	a809                	j	80000e7e <strncmp+0x32>
    80000e6e:	4501                	li	a0,0
    80000e70:	a039                	j	80000e7e <strncmp+0x32>
  if(n == 0)
    80000e72:	ca09                	beqz	a2,80000e84 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e74:	00054503          	lbu	a0,0(a0)
    80000e78:	0005c783          	lbu	a5,0(a1)
    80000e7c:	9d1d                	subw	a0,a0,a5
}
    80000e7e:	6422                	ld	s0,8(sp)
    80000e80:	0141                	addi	sp,sp,16
    80000e82:	8082                	ret
    return 0;
    80000e84:	4501                	li	a0,0
    80000e86:	bfe5                	j	80000e7e <strncmp+0x32>

0000000080000e88 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e88:	1141                	addi	sp,sp,-16
    80000e8a:	e422                	sd	s0,8(sp)
    80000e8c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e8e:	872a                	mv	a4,a0
    80000e90:	8832                	mv	a6,a2
    80000e92:	367d                	addiw	a2,a2,-1
    80000e94:	01005963          	blez	a6,80000ea6 <strncpy+0x1e>
    80000e98:	0705                	addi	a4,a4,1
    80000e9a:	0005c783          	lbu	a5,0(a1)
    80000e9e:	fef70fa3          	sb	a5,-1(a4)
    80000ea2:	0585                	addi	a1,a1,1
    80000ea4:	f7f5                	bnez	a5,80000e90 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ea6:	00c05d63          	blez	a2,80000ec0 <strncpy+0x38>
    80000eaa:	86ba                	mv	a3,a4
    *s++ = 0;
    80000eac:	0685                	addi	a3,a3,1
    80000eae:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000eb2:	fff6c793          	not	a5,a3
    80000eb6:	9fb9                	addw	a5,a5,a4
    80000eb8:	010787bb          	addw	a5,a5,a6
    80000ebc:	fef048e3          	bgtz	a5,80000eac <strncpy+0x24>
  return os;
}
    80000ec0:	6422                	ld	s0,8(sp)
    80000ec2:	0141                	addi	sp,sp,16
    80000ec4:	8082                	ret

0000000080000ec6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ec6:	1141                	addi	sp,sp,-16
    80000ec8:	e422                	sd	s0,8(sp)
    80000eca:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ecc:	02c05363          	blez	a2,80000ef2 <safestrcpy+0x2c>
    80000ed0:	fff6069b          	addiw	a3,a2,-1
    80000ed4:	1682                	slli	a3,a3,0x20
    80000ed6:	9281                	srli	a3,a3,0x20
    80000ed8:	96ae                	add	a3,a3,a1
    80000eda:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000edc:	00d58963          	beq	a1,a3,80000eee <safestrcpy+0x28>
    80000ee0:	0585                	addi	a1,a1,1
    80000ee2:	0785                	addi	a5,a5,1
    80000ee4:	fff5c703          	lbu	a4,-1(a1)
    80000ee8:	fee78fa3          	sb	a4,-1(a5)
    80000eec:	fb65                	bnez	a4,80000edc <safestrcpy+0x16>
    ;
  *s = 0;
    80000eee:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ef2:	6422                	ld	s0,8(sp)
    80000ef4:	0141                	addi	sp,sp,16
    80000ef6:	8082                	ret

0000000080000ef8 <strlen>:

int
strlen(const char *s)
{
    80000ef8:	1141                	addi	sp,sp,-16
    80000efa:	e422                	sd	s0,8(sp)
    80000efc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000efe:	00054783          	lbu	a5,0(a0)
    80000f02:	cf91                	beqz	a5,80000f1e <strlen+0x26>
    80000f04:	0505                	addi	a0,a0,1
    80000f06:	87aa                	mv	a5,a0
    80000f08:	4685                	li	a3,1
    80000f0a:	9e89                	subw	a3,a3,a0
    80000f0c:	00f6853b          	addw	a0,a3,a5
    80000f10:	0785                	addi	a5,a5,1
    80000f12:	fff7c703          	lbu	a4,-1(a5)
    80000f16:	fb7d                	bnez	a4,80000f0c <strlen+0x14>
    ;
  return n;
}
    80000f18:	6422                	ld	s0,8(sp)
    80000f1a:	0141                	addi	sp,sp,16
    80000f1c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f1e:	4501                	li	a0,0
    80000f20:	bfe5                	j	80000f18 <strlen+0x20>

0000000080000f22 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f22:	1141                	addi	sp,sp,-16
    80000f24:	e406                	sd	ra,8(sp)
    80000f26:	e022                	sd	s0,0(sp)
    80000f28:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f2a:	00001097          	auipc	ra,0x1
    80000f2e:	aec080e7          	jalr	-1300(ra) # 80001a16 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f32:	00008717          	auipc	a4,0x8
    80000f36:	0da70713          	addi	a4,a4,218 # 8000900c <started>
  if(cpuid() == 0){
    80000f3a:	c139                	beqz	a0,80000f80 <main+0x5e>
    while(started == 0)
    80000f3c:	431c                	lw	a5,0(a4)
    80000f3e:	2781                	sext.w	a5,a5
    80000f40:	dff5                	beqz	a5,80000f3c <main+0x1a>
      ;
    __sync_synchronize();
    80000f42:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	ad0080e7          	jalr	-1328(ra) # 80001a16 <cpuid>
    80000f4e:	85aa                	mv	a1,a0
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	18050513          	addi	a0,a0,384 # 800080d0 <digits+0x78>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	6d0080e7          	jalr	1744(ra) # 80000628 <printf>
    kvminithart();    // turn on paging
    80000f60:	00000097          	auipc	ra,0x0
    80000f64:	0d8080e7          	jalr	216(ra) # 80001038 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f68:	00001097          	auipc	ra,0x1
    80000f6c:	768080e7          	jalr	1896(ra) # 800026d0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f70:	00005097          	auipc	ra,0x5
    80000f74:	df0080e7          	jalr	-528(ra) # 80005d60 <plicinithart>
  }

  scheduler();        
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	02e080e7          	jalr	46(ra) # 80001fa6 <scheduler>
    consoleinit();
    80000f80:	fffff097          	auipc	ra,0xfffff
    80000f84:	4da080e7          	jalr	1242(ra) # 8000045a <consoleinit>
    printfinit();
    80000f88:	fffff097          	auipc	ra,0xfffff
    80000f8c:	5c0080e7          	jalr	1472(ra) # 80000548 <printfinit>
    printf("\n");
    80000f90:	00007517          	auipc	a0,0x7
    80000f94:	15050513          	addi	a0,a0,336 # 800080e0 <digits+0x88>
    80000f98:	fffff097          	auipc	ra,0xfffff
    80000f9c:	690080e7          	jalr	1680(ra) # 80000628 <printf>
    printf("xv6 kernel is booting\n");
    80000fa0:	00007517          	auipc	a0,0x7
    80000fa4:	11850513          	addi	a0,a0,280 # 800080b8 <digits+0x60>
    80000fa8:	fffff097          	auipc	ra,0xfffff
    80000fac:	680080e7          	jalr	1664(ra) # 80000628 <printf>
    printf("\n");
    80000fb0:	00007517          	auipc	a0,0x7
    80000fb4:	13050513          	addi	a0,a0,304 # 800080e0 <digits+0x88>
    80000fb8:	fffff097          	auipc	ra,0xfffff
    80000fbc:	670080e7          	jalr	1648(ra) # 80000628 <printf>
    kinit();         // physical page allocator
    80000fc0:	00000097          	auipc	ra,0x0
    80000fc4:	b88080e7          	jalr	-1144(ra) # 80000b48 <kinit>
    kvminit();       // create kernel page table
    80000fc8:	00000097          	auipc	ra,0x0
    80000fcc:	2a0080e7          	jalr	672(ra) # 80001268 <kvminit>
    kvminithart();   // turn on paging
    80000fd0:	00000097          	auipc	ra,0x0
    80000fd4:	068080e7          	jalr	104(ra) # 80001038 <kvminithart>
    procinit();      // process table
    80000fd8:	00001097          	auipc	ra,0x1
    80000fdc:	96e080e7          	jalr	-1682(ra) # 80001946 <procinit>
    trapinit();      // trap vectors
    80000fe0:	00001097          	auipc	ra,0x1
    80000fe4:	6c8080e7          	jalr	1736(ra) # 800026a8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fe8:	00001097          	auipc	ra,0x1
    80000fec:	6e8080e7          	jalr	1768(ra) # 800026d0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ff0:	00005097          	auipc	ra,0x5
    80000ff4:	d5a080e7          	jalr	-678(ra) # 80005d4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ff8:	00005097          	auipc	ra,0x5
    80000ffc:	d68080e7          	jalr	-664(ra) # 80005d60 <plicinithart>
    binit();         // buffer cache
    80001000:	00002097          	auipc	ra,0x2
    80001004:	f0c080e7          	jalr	-244(ra) # 80002f0c <binit>
    iinit();         // inode cache
    80001008:	00002097          	auipc	ra,0x2
    8000100c:	59c080e7          	jalr	1436(ra) # 800035a4 <iinit>
    fileinit();      // file table
    80001010:	00003097          	auipc	ra,0x3
    80001014:	536080e7          	jalr	1334(ra) # 80004546 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001018:	00005097          	auipc	ra,0x5
    8000101c:	e50080e7          	jalr	-432(ra) # 80005e68 <virtio_disk_init>
    userinit();      // first user process
    80001020:	00001097          	auipc	ra,0x1
    80001024:	d20080e7          	jalr	-736(ra) # 80001d40 <userinit>
    __sync_synchronize();
    80001028:	0ff0000f          	fence
    started = 1;
    8000102c:	4785                	li	a5,1
    8000102e:	00008717          	auipc	a4,0x8
    80001032:	fcf72f23          	sw	a5,-34(a4) # 8000900c <started>
    80001036:	b789                	j	80000f78 <main+0x56>

0000000080001038 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001038:	1141                	addi	sp,sp,-16
    8000103a:	e422                	sd	s0,8(sp)
    8000103c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000103e:	00008797          	auipc	a5,0x8
    80001042:	fd27b783          	ld	a5,-46(a5) # 80009010 <kernel_pagetable>
    80001046:	83b1                	srli	a5,a5,0xc
    80001048:	577d                	li	a4,-1
    8000104a:	177e                	slli	a4,a4,0x3f
    8000104c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000104e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001052:	12000073          	sfence.vma
  sfence_vma();
}
    80001056:	6422                	ld	s0,8(sp)
    80001058:	0141                	addi	sp,sp,16
    8000105a:	8082                	ret

000000008000105c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000105c:	7139                	addi	sp,sp,-64
    8000105e:	fc06                	sd	ra,56(sp)
    80001060:	f822                	sd	s0,48(sp)
    80001062:	f426                	sd	s1,40(sp)
    80001064:	f04a                	sd	s2,32(sp)
    80001066:	ec4e                	sd	s3,24(sp)
    80001068:	e852                	sd	s4,16(sp)
    8000106a:	e456                	sd	s5,8(sp)
    8000106c:	e05a                	sd	s6,0(sp)
    8000106e:	0080                	addi	s0,sp,64
    80001070:	84aa                	mv	s1,a0
    80001072:	89ae                	mv	s3,a1
    80001074:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001076:	57fd                	li	a5,-1
    80001078:	83e9                	srli	a5,a5,0x1a
    8000107a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000107c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000107e:	04b7f263          	bgeu	a5,a1,800010c2 <walk+0x66>
    panic("walk");
    80001082:	00007517          	auipc	a0,0x7
    80001086:	06650513          	addi	a0,a0,102 # 800080e8 <digits+0x90>
    8000108a:	fffff097          	auipc	ra,0xfffff
    8000108e:	54c080e7          	jalr	1356(ra) # 800005d6 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001092:	060a8663          	beqz	s5,800010fe <walk+0xa2>
    80001096:	00000097          	auipc	ra,0x0
    8000109a:	aee080e7          	jalr	-1298(ra) # 80000b84 <kalloc>
    8000109e:	84aa                	mv	s1,a0
    800010a0:	c529                	beqz	a0,800010ea <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010a2:	6605                	lui	a2,0x1
    800010a4:	4581                	li	a1,0
    800010a6:	00000097          	auipc	ra,0x0
    800010aa:	cca080e7          	jalr	-822(ra) # 80000d70 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010ae:	00c4d793          	srli	a5,s1,0xc
    800010b2:	07aa                	slli	a5,a5,0xa
    800010b4:	0017e793          	ori	a5,a5,1
    800010b8:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010bc:	3a5d                	addiw	s4,s4,-9
    800010be:	036a0063          	beq	s4,s6,800010de <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010c2:	0149d933          	srl	s2,s3,s4
    800010c6:	1ff97913          	andi	s2,s2,511
    800010ca:	090e                	slli	s2,s2,0x3
    800010cc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010ce:	00093483          	ld	s1,0(s2)
    800010d2:	0014f793          	andi	a5,s1,1
    800010d6:	dfd5                	beqz	a5,80001092 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010d8:	80a9                	srli	s1,s1,0xa
    800010da:	04b2                	slli	s1,s1,0xc
    800010dc:	b7c5                	j	800010bc <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010de:	00c9d513          	srli	a0,s3,0xc
    800010e2:	1ff57513          	andi	a0,a0,511
    800010e6:	050e                	slli	a0,a0,0x3
    800010e8:	9526                	add	a0,a0,s1
}
    800010ea:	70e2                	ld	ra,56(sp)
    800010ec:	7442                	ld	s0,48(sp)
    800010ee:	74a2                	ld	s1,40(sp)
    800010f0:	7902                	ld	s2,32(sp)
    800010f2:	69e2                	ld	s3,24(sp)
    800010f4:	6a42                	ld	s4,16(sp)
    800010f6:	6aa2                	ld	s5,8(sp)
    800010f8:	6b02                	ld	s6,0(sp)
    800010fa:	6121                	addi	sp,sp,64
    800010fc:	8082                	ret
        return 0;
    800010fe:	4501                	li	a0,0
    80001100:	b7ed                	j	800010ea <walk+0x8e>

0000000080001102 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001102:	57fd                	li	a5,-1
    80001104:	83e9                	srli	a5,a5,0x1a
    80001106:	00b7f463          	bgeu	a5,a1,8000110e <walkaddr+0xc>
    return 0;
    8000110a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000110c:	8082                	ret
{
    8000110e:	1141                	addi	sp,sp,-16
    80001110:	e406                	sd	ra,8(sp)
    80001112:	e022                	sd	s0,0(sp)
    80001114:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001116:	4601                	li	a2,0
    80001118:	00000097          	auipc	ra,0x0
    8000111c:	f44080e7          	jalr	-188(ra) # 8000105c <walk>
  if(pte == 0)
    80001120:	c105                	beqz	a0,80001140 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001122:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001124:	0117f693          	andi	a3,a5,17
    80001128:	4745                	li	a4,17
    return 0;
    8000112a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000112c:	00e68663          	beq	a3,a4,80001138 <walkaddr+0x36>
}
    80001130:	60a2                	ld	ra,8(sp)
    80001132:	6402                	ld	s0,0(sp)
    80001134:	0141                	addi	sp,sp,16
    80001136:	8082                	ret
  pa = PTE2PA(*pte);
    80001138:	00a7d513          	srli	a0,a5,0xa
    8000113c:	0532                	slli	a0,a0,0xc
  return pa;
    8000113e:	bfcd                	j	80001130 <walkaddr+0x2e>
    return 0;
    80001140:	4501                	li	a0,0
    80001142:	b7fd                	j	80001130 <walkaddr+0x2e>

0000000080001144 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001144:	1101                	addi	sp,sp,-32
    80001146:	ec06                	sd	ra,24(sp)
    80001148:	e822                	sd	s0,16(sp)
    8000114a:	e426                	sd	s1,8(sp)
    8000114c:	1000                	addi	s0,sp,32
    8000114e:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001150:	1552                	slli	a0,a0,0x34
    80001152:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001156:	4601                	li	a2,0
    80001158:	00008517          	auipc	a0,0x8
    8000115c:	eb853503          	ld	a0,-328(a0) # 80009010 <kernel_pagetable>
    80001160:	00000097          	auipc	ra,0x0
    80001164:	efc080e7          	jalr	-260(ra) # 8000105c <walk>
  if(pte == 0)
    80001168:	cd09                	beqz	a0,80001182 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000116a:	6108                	ld	a0,0(a0)
    8000116c:	00157793          	andi	a5,a0,1
    80001170:	c38d                	beqz	a5,80001192 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001172:	8129                	srli	a0,a0,0xa
    80001174:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001176:	9526                	add	a0,a0,s1
    80001178:	60e2                	ld	ra,24(sp)
    8000117a:	6442                	ld	s0,16(sp)
    8000117c:	64a2                	ld	s1,8(sp)
    8000117e:	6105                	addi	sp,sp,32
    80001180:	8082                	ret
    panic("kvmpa");
    80001182:	00007517          	auipc	a0,0x7
    80001186:	f6e50513          	addi	a0,a0,-146 # 800080f0 <digits+0x98>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	44c080e7          	jalr	1100(ra) # 800005d6 <panic>
    panic("kvmpa");
    80001192:	00007517          	auipc	a0,0x7
    80001196:	f5e50513          	addi	a0,a0,-162 # 800080f0 <digits+0x98>
    8000119a:	fffff097          	auipc	ra,0xfffff
    8000119e:	43c080e7          	jalr	1084(ra) # 800005d6 <panic>

00000000800011a2 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011a2:	715d                	addi	sp,sp,-80
    800011a4:	e486                	sd	ra,72(sp)
    800011a6:	e0a2                	sd	s0,64(sp)
    800011a8:	fc26                	sd	s1,56(sp)
    800011aa:	f84a                	sd	s2,48(sp)
    800011ac:	f44e                	sd	s3,40(sp)
    800011ae:	f052                	sd	s4,32(sp)
    800011b0:	ec56                	sd	s5,24(sp)
    800011b2:	e85a                	sd	s6,16(sp)
    800011b4:	e45e                	sd	s7,8(sp)
    800011b6:	0880                	addi	s0,sp,80
    800011b8:	8aaa                	mv	s5,a0
    800011ba:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011bc:	777d                	lui	a4,0xfffff
    800011be:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011c2:	167d                	addi	a2,a2,-1
    800011c4:	00b609b3          	add	s3,a2,a1
    800011c8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011cc:	893e                	mv	s2,a5
    800011ce:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011d2:	6b85                	lui	s7,0x1
    800011d4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011d8:	4605                	li	a2,1
    800011da:	85ca                	mv	a1,s2
    800011dc:	8556                	mv	a0,s5
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	e7e080e7          	jalr	-386(ra) # 8000105c <walk>
    800011e6:	c51d                	beqz	a0,80001214 <mappages+0x72>
    if(*pte & PTE_V)
    800011e8:	611c                	ld	a5,0(a0)
    800011ea:	8b85                	andi	a5,a5,1
    800011ec:	ef81                	bnez	a5,80001204 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011ee:	80b1                	srli	s1,s1,0xc
    800011f0:	04aa                	slli	s1,s1,0xa
    800011f2:	0164e4b3          	or	s1,s1,s6
    800011f6:	0014e493          	ori	s1,s1,1
    800011fa:	e104                	sd	s1,0(a0)
    if(a == last)
    800011fc:	03390863          	beq	s2,s3,8000122c <mappages+0x8a>
    a += PGSIZE;
    80001200:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001202:	bfc9                	j	800011d4 <mappages+0x32>
      panic("remap");
    80001204:	00007517          	auipc	a0,0x7
    80001208:	ef450513          	addi	a0,a0,-268 # 800080f8 <digits+0xa0>
    8000120c:	fffff097          	auipc	ra,0xfffff
    80001210:	3ca080e7          	jalr	970(ra) # 800005d6 <panic>
      return -1;
    80001214:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001216:	60a6                	ld	ra,72(sp)
    80001218:	6406                	ld	s0,64(sp)
    8000121a:	74e2                	ld	s1,56(sp)
    8000121c:	7942                	ld	s2,48(sp)
    8000121e:	79a2                	ld	s3,40(sp)
    80001220:	7a02                	ld	s4,32(sp)
    80001222:	6ae2                	ld	s5,24(sp)
    80001224:	6b42                	ld	s6,16(sp)
    80001226:	6ba2                	ld	s7,8(sp)
    80001228:	6161                	addi	sp,sp,80
    8000122a:	8082                	ret
  return 0;
    8000122c:	4501                	li	a0,0
    8000122e:	b7e5                	j	80001216 <mappages+0x74>

0000000080001230 <kvmmap>:
{
    80001230:	1141                	addi	sp,sp,-16
    80001232:	e406                	sd	ra,8(sp)
    80001234:	e022                	sd	s0,0(sp)
    80001236:	0800                	addi	s0,sp,16
    80001238:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000123a:	86ae                	mv	a3,a1
    8000123c:	85aa                	mv	a1,a0
    8000123e:	00008517          	auipc	a0,0x8
    80001242:	dd253503          	ld	a0,-558(a0) # 80009010 <kernel_pagetable>
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f5c080e7          	jalr	-164(ra) # 800011a2 <mappages>
    8000124e:	e509                	bnez	a0,80001258 <kvmmap+0x28>
}
    80001250:	60a2                	ld	ra,8(sp)
    80001252:	6402                	ld	s0,0(sp)
    80001254:	0141                	addi	sp,sp,16
    80001256:	8082                	ret
    panic("kvmmap");
    80001258:	00007517          	auipc	a0,0x7
    8000125c:	ea850513          	addi	a0,a0,-344 # 80008100 <digits+0xa8>
    80001260:	fffff097          	auipc	ra,0xfffff
    80001264:	376080e7          	jalr	886(ra) # 800005d6 <panic>

0000000080001268 <kvminit>:
{
    80001268:	1101                	addi	sp,sp,-32
    8000126a:	ec06                	sd	ra,24(sp)
    8000126c:	e822                	sd	s0,16(sp)
    8000126e:	e426                	sd	s1,8(sp)
    80001270:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001272:	00000097          	auipc	ra,0x0
    80001276:	912080e7          	jalr	-1774(ra) # 80000b84 <kalloc>
    8000127a:	00008797          	auipc	a5,0x8
    8000127e:	d8a7bb23          	sd	a0,-618(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001282:	6605                	lui	a2,0x1
    80001284:	4581                	li	a1,0
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	aea080e7          	jalr	-1302(ra) # 80000d70 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000128e:	4699                	li	a3,6
    80001290:	6605                	lui	a2,0x1
    80001292:	100005b7          	lui	a1,0x10000
    80001296:	10000537          	lui	a0,0x10000
    8000129a:	00000097          	auipc	ra,0x0
    8000129e:	f96080e7          	jalr	-106(ra) # 80001230 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012a2:	4699                	li	a3,6
    800012a4:	6605                	lui	a2,0x1
    800012a6:	100015b7          	lui	a1,0x10001
    800012aa:	10001537          	lui	a0,0x10001
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	f82080e7          	jalr	-126(ra) # 80001230 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800012b6:	4699                	li	a3,6
    800012b8:	6641                	lui	a2,0x10
    800012ba:	020005b7          	lui	a1,0x2000
    800012be:	02000537          	lui	a0,0x2000
    800012c2:	00000097          	auipc	ra,0x0
    800012c6:	f6e080e7          	jalr	-146(ra) # 80001230 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012ca:	4699                	li	a3,6
    800012cc:	00400637          	lui	a2,0x400
    800012d0:	0c0005b7          	lui	a1,0xc000
    800012d4:	0c000537          	lui	a0,0xc000
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	f58080e7          	jalr	-168(ra) # 80001230 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012e0:	00007497          	auipc	s1,0x7
    800012e4:	d2048493          	addi	s1,s1,-736 # 80008000 <etext>
    800012e8:	46a9                	li	a3,10
    800012ea:	80007617          	auipc	a2,0x80007
    800012ee:	d1660613          	addi	a2,a2,-746 # 8000 <_entry-0x7fff8000>
    800012f2:	4585                	li	a1,1
    800012f4:	05fe                	slli	a1,a1,0x1f
    800012f6:	852e                	mv	a0,a1
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	f38080e7          	jalr	-200(ra) # 80001230 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001300:	4699                	li	a3,6
    80001302:	4645                	li	a2,17
    80001304:	066e                	slli	a2,a2,0x1b
    80001306:	8e05                	sub	a2,a2,s1
    80001308:	85a6                	mv	a1,s1
    8000130a:	8526                	mv	a0,s1
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	f24080e7          	jalr	-220(ra) # 80001230 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001314:	46a9                	li	a3,10
    80001316:	6605                	lui	a2,0x1
    80001318:	00006597          	auipc	a1,0x6
    8000131c:	ce858593          	addi	a1,a1,-792 # 80007000 <_trampoline>
    80001320:	04000537          	lui	a0,0x4000
    80001324:	157d                	addi	a0,a0,-1
    80001326:	0532                	slli	a0,a0,0xc
    80001328:	00000097          	auipc	ra,0x0
    8000132c:	f08080e7          	jalr	-248(ra) # 80001230 <kvmmap>
}
    80001330:	60e2                	ld	ra,24(sp)
    80001332:	6442                	ld	s0,16(sp)
    80001334:	64a2                	ld	s1,8(sp)
    80001336:	6105                	addi	sp,sp,32
    80001338:	8082                	ret

000000008000133a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000133a:	715d                	addi	sp,sp,-80
    8000133c:	e486                	sd	ra,72(sp)
    8000133e:	e0a2                	sd	s0,64(sp)
    80001340:	fc26                	sd	s1,56(sp)
    80001342:	f84a                	sd	s2,48(sp)
    80001344:	f44e                	sd	s3,40(sp)
    80001346:	f052                	sd	s4,32(sp)
    80001348:	ec56                	sd	s5,24(sp)
    8000134a:	e85a                	sd	s6,16(sp)
    8000134c:	e45e                	sd	s7,8(sp)
    8000134e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001350:	03459793          	slli	a5,a1,0x34
    80001354:	e795                	bnez	a5,80001380 <uvmunmap+0x46>
    80001356:	8a2a                	mv	s4,a0
    80001358:	892e                	mv	s2,a1
    8000135a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000135c:	0632                	slli	a2,a2,0xc
    8000135e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001364:	6b05                	lui	s6,0x1
    80001366:	0735e863          	bltu	a1,s3,800013d6 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000136a:	60a6                	ld	ra,72(sp)
    8000136c:	6406                	ld	s0,64(sp)
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	7942                	ld	s2,48(sp)
    80001372:	79a2                	ld	s3,40(sp)
    80001374:	7a02                	ld	s4,32(sp)
    80001376:	6ae2                	ld	s5,24(sp)
    80001378:	6b42                	ld	s6,16(sp)
    8000137a:	6ba2                	ld	s7,8(sp)
    8000137c:	6161                	addi	sp,sp,80
    8000137e:	8082                	ret
    panic("uvmunmap: not aligned");
    80001380:	00007517          	auipc	a0,0x7
    80001384:	d8850513          	addi	a0,a0,-632 # 80008108 <digits+0xb0>
    80001388:	fffff097          	auipc	ra,0xfffff
    8000138c:	24e080e7          	jalr	590(ra) # 800005d6 <panic>
      panic("uvmunmap: walk");
    80001390:	00007517          	auipc	a0,0x7
    80001394:	d9050513          	addi	a0,a0,-624 # 80008120 <digits+0xc8>
    80001398:	fffff097          	auipc	ra,0xfffff
    8000139c:	23e080e7          	jalr	574(ra) # 800005d6 <panic>
      panic("uvmunmap: not mapped");
    800013a0:	00007517          	auipc	a0,0x7
    800013a4:	d9050513          	addi	a0,a0,-624 # 80008130 <digits+0xd8>
    800013a8:	fffff097          	auipc	ra,0xfffff
    800013ac:	22e080e7          	jalr	558(ra) # 800005d6 <panic>
      panic("uvmunmap: not a leaf");
    800013b0:	00007517          	auipc	a0,0x7
    800013b4:	d9850513          	addi	a0,a0,-616 # 80008148 <digits+0xf0>
    800013b8:	fffff097          	auipc	ra,0xfffff
    800013bc:	21e080e7          	jalr	542(ra) # 800005d6 <panic>
      uint64 pa = PTE2PA(*pte);
    800013c0:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013c2:	0532                	slli	a0,a0,0xc
    800013c4:	fffff097          	auipc	ra,0xfffff
    800013c8:	6c4080e7          	jalr	1732(ra) # 80000a88 <kfree>
    *pte = 0;
    800013cc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013d0:	995a                	add	s2,s2,s6
    800013d2:	f9397ce3          	bgeu	s2,s3,8000136a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013d6:	4601                	li	a2,0
    800013d8:	85ca                	mv	a1,s2
    800013da:	8552                	mv	a0,s4
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	c80080e7          	jalr	-896(ra) # 8000105c <walk>
    800013e4:	84aa                	mv	s1,a0
    800013e6:	d54d                	beqz	a0,80001390 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013e8:	6108                	ld	a0,0(a0)
    800013ea:	00157793          	andi	a5,a0,1
    800013ee:	dbcd                	beqz	a5,800013a0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013f0:	3ff57793          	andi	a5,a0,1023
    800013f4:	fb778ee3          	beq	a5,s7,800013b0 <uvmunmap+0x76>
    if(do_free){
    800013f8:	fc0a8ae3          	beqz	s5,800013cc <uvmunmap+0x92>
    800013fc:	b7d1                	j	800013c0 <uvmunmap+0x86>

00000000800013fe <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013fe:	1101                	addi	sp,sp,-32
    80001400:	ec06                	sd	ra,24(sp)
    80001402:	e822                	sd	s0,16(sp)
    80001404:	e426                	sd	s1,8(sp)
    80001406:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001408:	fffff097          	auipc	ra,0xfffff
    8000140c:	77c080e7          	jalr	1916(ra) # 80000b84 <kalloc>
    80001410:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001412:	c519                	beqz	a0,80001420 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001414:	6605                	lui	a2,0x1
    80001416:	4581                	li	a1,0
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	958080e7          	jalr	-1704(ra) # 80000d70 <memset>
  return pagetable;
}
    80001420:	8526                	mv	a0,s1
    80001422:	60e2                	ld	ra,24(sp)
    80001424:	6442                	ld	s0,16(sp)
    80001426:	64a2                	ld	s1,8(sp)
    80001428:	6105                	addi	sp,sp,32
    8000142a:	8082                	ret

000000008000142c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000142c:	7179                	addi	sp,sp,-48
    8000142e:	f406                	sd	ra,40(sp)
    80001430:	f022                	sd	s0,32(sp)
    80001432:	ec26                	sd	s1,24(sp)
    80001434:	e84a                	sd	s2,16(sp)
    80001436:	e44e                	sd	s3,8(sp)
    80001438:	e052                	sd	s4,0(sp)
    8000143a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000143c:	6785                	lui	a5,0x1
    8000143e:	04f67863          	bgeu	a2,a5,8000148e <uvminit+0x62>
    80001442:	8a2a                	mv	s4,a0
    80001444:	89ae                	mv	s3,a1
    80001446:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001448:	fffff097          	auipc	ra,0xfffff
    8000144c:	73c080e7          	jalr	1852(ra) # 80000b84 <kalloc>
    80001450:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001452:	6605                	lui	a2,0x1
    80001454:	4581                	li	a1,0
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	91a080e7          	jalr	-1766(ra) # 80000d70 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000145e:	4779                	li	a4,30
    80001460:	86ca                	mv	a3,s2
    80001462:	6605                	lui	a2,0x1
    80001464:	4581                	li	a1,0
    80001466:	8552                	mv	a0,s4
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	d3a080e7          	jalr	-710(ra) # 800011a2 <mappages>
  memmove(mem, src, sz);
    80001470:	8626                	mv	a2,s1
    80001472:	85ce                	mv	a1,s3
    80001474:	854a                	mv	a0,s2
    80001476:	00000097          	auipc	ra,0x0
    8000147a:	95a080e7          	jalr	-1702(ra) # 80000dd0 <memmove>
}
    8000147e:	70a2                	ld	ra,40(sp)
    80001480:	7402                	ld	s0,32(sp)
    80001482:	64e2                	ld	s1,24(sp)
    80001484:	6942                	ld	s2,16(sp)
    80001486:	69a2                	ld	s3,8(sp)
    80001488:	6a02                	ld	s4,0(sp)
    8000148a:	6145                	addi	sp,sp,48
    8000148c:	8082                	ret
    panic("inituvm: more than a page");
    8000148e:	00007517          	auipc	a0,0x7
    80001492:	cd250513          	addi	a0,a0,-814 # 80008160 <digits+0x108>
    80001496:	fffff097          	auipc	ra,0xfffff
    8000149a:	140080e7          	jalr	320(ra) # 800005d6 <panic>

000000008000149e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000149e:	1101                	addi	sp,sp,-32
    800014a0:	ec06                	sd	ra,24(sp)
    800014a2:	e822                	sd	s0,16(sp)
    800014a4:	e426                	sd	s1,8(sp)
    800014a6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014a8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014aa:	00b67d63          	bgeu	a2,a1,800014c4 <uvmdealloc+0x26>
    800014ae:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014b0:	6785                	lui	a5,0x1
    800014b2:	17fd                	addi	a5,a5,-1
    800014b4:	00f60733          	add	a4,a2,a5
    800014b8:	767d                	lui	a2,0xfffff
    800014ba:	8f71                	and	a4,a4,a2
    800014bc:	97ae                	add	a5,a5,a1
    800014be:	8ff1                	and	a5,a5,a2
    800014c0:	00f76863          	bltu	a4,a5,800014d0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014c4:	8526                	mv	a0,s1
    800014c6:	60e2                	ld	ra,24(sp)
    800014c8:	6442                	ld	s0,16(sp)
    800014ca:	64a2                	ld	s1,8(sp)
    800014cc:	6105                	addi	sp,sp,32
    800014ce:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014d0:	8f99                	sub	a5,a5,a4
    800014d2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014d4:	4685                	li	a3,1
    800014d6:	0007861b          	sext.w	a2,a5
    800014da:	85ba                	mv	a1,a4
    800014dc:	00000097          	auipc	ra,0x0
    800014e0:	e5e080e7          	jalr	-418(ra) # 8000133a <uvmunmap>
    800014e4:	b7c5                	j	800014c4 <uvmdealloc+0x26>

00000000800014e6 <uvmalloc>:
  if(newsz < oldsz)
    800014e6:	0ab66163          	bltu	a2,a1,80001588 <uvmalloc+0xa2>
{
    800014ea:	7139                	addi	sp,sp,-64
    800014ec:	fc06                	sd	ra,56(sp)
    800014ee:	f822                	sd	s0,48(sp)
    800014f0:	f426                	sd	s1,40(sp)
    800014f2:	f04a                	sd	s2,32(sp)
    800014f4:	ec4e                	sd	s3,24(sp)
    800014f6:	e852                	sd	s4,16(sp)
    800014f8:	e456                	sd	s5,8(sp)
    800014fa:	0080                	addi	s0,sp,64
    800014fc:	8aaa                	mv	s5,a0
    800014fe:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001500:	6985                	lui	s3,0x1
    80001502:	19fd                	addi	s3,s3,-1
    80001504:	95ce                	add	a1,a1,s3
    80001506:	79fd                	lui	s3,0xfffff
    80001508:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000150c:	08c9f063          	bgeu	s3,a2,8000158c <uvmalloc+0xa6>
    80001510:	894e                	mv	s2,s3
    mem = kalloc();
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	672080e7          	jalr	1650(ra) # 80000b84 <kalloc>
    8000151a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000151c:	c51d                	beqz	a0,8000154a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000151e:	6605                	lui	a2,0x1
    80001520:	4581                	li	a1,0
    80001522:	00000097          	auipc	ra,0x0
    80001526:	84e080e7          	jalr	-1970(ra) # 80000d70 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000152a:	4779                	li	a4,30
    8000152c:	86a6                	mv	a3,s1
    8000152e:	6605                	lui	a2,0x1
    80001530:	85ca                	mv	a1,s2
    80001532:	8556                	mv	a0,s5
    80001534:	00000097          	auipc	ra,0x0
    80001538:	c6e080e7          	jalr	-914(ra) # 800011a2 <mappages>
    8000153c:	e905                	bnez	a0,8000156c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000153e:	6785                	lui	a5,0x1
    80001540:	993e                	add	s2,s2,a5
    80001542:	fd4968e3          	bltu	s2,s4,80001512 <uvmalloc+0x2c>
  return newsz;
    80001546:	8552                	mv	a0,s4
    80001548:	a809                	j	8000155a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000154a:	864e                	mv	a2,s3
    8000154c:	85ca                	mv	a1,s2
    8000154e:	8556                	mv	a0,s5
    80001550:	00000097          	auipc	ra,0x0
    80001554:	f4e080e7          	jalr	-178(ra) # 8000149e <uvmdealloc>
      return 0;
    80001558:	4501                	li	a0,0
}
    8000155a:	70e2                	ld	ra,56(sp)
    8000155c:	7442                	ld	s0,48(sp)
    8000155e:	74a2                	ld	s1,40(sp)
    80001560:	7902                	ld	s2,32(sp)
    80001562:	69e2                	ld	s3,24(sp)
    80001564:	6a42                	ld	s4,16(sp)
    80001566:	6aa2                	ld	s5,8(sp)
    80001568:	6121                	addi	sp,sp,64
    8000156a:	8082                	ret
      kfree(mem);
    8000156c:	8526                	mv	a0,s1
    8000156e:	fffff097          	auipc	ra,0xfffff
    80001572:	51a080e7          	jalr	1306(ra) # 80000a88 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001576:	864e                	mv	a2,s3
    80001578:	85ca                	mv	a1,s2
    8000157a:	8556                	mv	a0,s5
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	f22080e7          	jalr	-222(ra) # 8000149e <uvmdealloc>
      return 0;
    80001584:	4501                	li	a0,0
    80001586:	bfd1                	j	8000155a <uvmalloc+0x74>
    return oldsz;
    80001588:	852e                	mv	a0,a1
}
    8000158a:	8082                	ret
  return newsz;
    8000158c:	8532                	mv	a0,a2
    8000158e:	b7f1                	j	8000155a <uvmalloc+0x74>

0000000080001590 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001590:	7179                	addi	sp,sp,-48
    80001592:	f406                	sd	ra,40(sp)
    80001594:	f022                	sd	s0,32(sp)
    80001596:	ec26                	sd	s1,24(sp)
    80001598:	e84a                	sd	s2,16(sp)
    8000159a:	e44e                	sd	s3,8(sp)
    8000159c:	e052                	sd	s4,0(sp)
    8000159e:	1800                	addi	s0,sp,48
    800015a0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015a2:	84aa                	mv	s1,a0
    800015a4:	6905                	lui	s2,0x1
    800015a6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a8:	4985                	li	s3,1
    800015aa:	a821                	j	800015c2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015ac:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015ae:	0532                	slli	a0,a0,0xc
    800015b0:	00000097          	auipc	ra,0x0
    800015b4:	fe0080e7          	jalr	-32(ra) # 80001590 <freewalk>
      pagetable[i] = 0;
    800015b8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015bc:	04a1                	addi	s1,s1,8
    800015be:	03248163          	beq	s1,s2,800015e0 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015c2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c4:	00f57793          	andi	a5,a0,15
    800015c8:	ff3782e3          	beq	a5,s3,800015ac <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015cc:	8905                	andi	a0,a0,1
    800015ce:	d57d                	beqz	a0,800015bc <freewalk+0x2c>
      panic("freewalk: leaf");
    800015d0:	00007517          	auipc	a0,0x7
    800015d4:	bb050513          	addi	a0,a0,-1104 # 80008180 <digits+0x128>
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	ffe080e7          	jalr	-2(ra) # 800005d6 <panic>
    }
  }
  kfree((void*)pagetable);
    800015e0:	8552                	mv	a0,s4
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	4a6080e7          	jalr	1190(ra) # 80000a88 <kfree>
}
    800015ea:	70a2                	ld	ra,40(sp)
    800015ec:	7402                	ld	s0,32(sp)
    800015ee:	64e2                	ld	s1,24(sp)
    800015f0:	6942                	ld	s2,16(sp)
    800015f2:	69a2                	ld	s3,8(sp)
    800015f4:	6a02                	ld	s4,0(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret

00000000800015fa <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015fa:	1101                	addi	sp,sp,-32
    800015fc:	ec06                	sd	ra,24(sp)
    800015fe:	e822                	sd	s0,16(sp)
    80001600:	e426                	sd	s1,8(sp)
    80001602:	1000                	addi	s0,sp,32
    80001604:	84aa                	mv	s1,a0
  if(sz > 0)
    80001606:	e999                	bnez	a1,8000161c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001608:	8526                	mv	a0,s1
    8000160a:	00000097          	auipc	ra,0x0
    8000160e:	f86080e7          	jalr	-122(ra) # 80001590 <freewalk>
}
    80001612:	60e2                	ld	ra,24(sp)
    80001614:	6442                	ld	s0,16(sp)
    80001616:	64a2                	ld	s1,8(sp)
    80001618:	6105                	addi	sp,sp,32
    8000161a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000161c:	6605                	lui	a2,0x1
    8000161e:	167d                	addi	a2,a2,-1
    80001620:	962e                	add	a2,a2,a1
    80001622:	4685                	li	a3,1
    80001624:	8231                	srli	a2,a2,0xc
    80001626:	4581                	li	a1,0
    80001628:	00000097          	auipc	ra,0x0
    8000162c:	d12080e7          	jalr	-750(ra) # 8000133a <uvmunmap>
    80001630:	bfe1                	j	80001608 <uvmfree+0xe>

0000000080001632 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001632:	c679                	beqz	a2,80001700 <uvmcopy+0xce>
{
    80001634:	715d                	addi	sp,sp,-80
    80001636:	e486                	sd	ra,72(sp)
    80001638:	e0a2                	sd	s0,64(sp)
    8000163a:	fc26                	sd	s1,56(sp)
    8000163c:	f84a                	sd	s2,48(sp)
    8000163e:	f44e                	sd	s3,40(sp)
    80001640:	f052                	sd	s4,32(sp)
    80001642:	ec56                	sd	s5,24(sp)
    80001644:	e85a                	sd	s6,16(sp)
    80001646:	e45e                	sd	s7,8(sp)
    80001648:	0880                	addi	s0,sp,80
    8000164a:	8b2a                	mv	s6,a0
    8000164c:	8aae                	mv	s5,a1
    8000164e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001650:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001652:	4601                	li	a2,0
    80001654:	85ce                	mv	a1,s3
    80001656:	855a                	mv	a0,s6
    80001658:	00000097          	auipc	ra,0x0
    8000165c:	a04080e7          	jalr	-1532(ra) # 8000105c <walk>
    80001660:	c531                	beqz	a0,800016ac <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001662:	6118                	ld	a4,0(a0)
    80001664:	00177793          	andi	a5,a4,1
    80001668:	cbb1                	beqz	a5,800016bc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000166a:	00a75593          	srli	a1,a4,0xa
    8000166e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001672:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001676:	fffff097          	auipc	ra,0xfffff
    8000167a:	50e080e7          	jalr	1294(ra) # 80000b84 <kalloc>
    8000167e:	892a                	mv	s2,a0
    80001680:	c939                	beqz	a0,800016d6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001682:	6605                	lui	a2,0x1
    80001684:	85de                	mv	a1,s7
    80001686:	fffff097          	auipc	ra,0xfffff
    8000168a:	74a080e7          	jalr	1866(ra) # 80000dd0 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000168e:	8726                	mv	a4,s1
    80001690:	86ca                	mv	a3,s2
    80001692:	6605                	lui	a2,0x1
    80001694:	85ce                	mv	a1,s3
    80001696:	8556                	mv	a0,s5
    80001698:	00000097          	auipc	ra,0x0
    8000169c:	b0a080e7          	jalr	-1270(ra) # 800011a2 <mappages>
    800016a0:	e515                	bnez	a0,800016cc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016a2:	6785                	lui	a5,0x1
    800016a4:	99be                	add	s3,s3,a5
    800016a6:	fb49e6e3          	bltu	s3,s4,80001652 <uvmcopy+0x20>
    800016aa:	a081                	j	800016ea <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016ac:	00007517          	auipc	a0,0x7
    800016b0:	ae450513          	addi	a0,a0,-1308 # 80008190 <digits+0x138>
    800016b4:	fffff097          	auipc	ra,0xfffff
    800016b8:	f22080e7          	jalr	-222(ra) # 800005d6 <panic>
      panic("uvmcopy: page not present");
    800016bc:	00007517          	auipc	a0,0x7
    800016c0:	af450513          	addi	a0,a0,-1292 # 800081b0 <digits+0x158>
    800016c4:	fffff097          	auipc	ra,0xfffff
    800016c8:	f12080e7          	jalr	-238(ra) # 800005d6 <panic>
      kfree(mem);
    800016cc:	854a                	mv	a0,s2
    800016ce:	fffff097          	auipc	ra,0xfffff
    800016d2:	3ba080e7          	jalr	954(ra) # 80000a88 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016d6:	4685                	li	a3,1
    800016d8:	00c9d613          	srli	a2,s3,0xc
    800016dc:	4581                	li	a1,0
    800016de:	8556                	mv	a0,s5
    800016e0:	00000097          	auipc	ra,0x0
    800016e4:	c5a080e7          	jalr	-934(ra) # 8000133a <uvmunmap>
  return -1;
    800016e8:	557d                	li	a0,-1
}
    800016ea:	60a6                	ld	ra,72(sp)
    800016ec:	6406                	ld	s0,64(sp)
    800016ee:	74e2                	ld	s1,56(sp)
    800016f0:	7942                	ld	s2,48(sp)
    800016f2:	79a2                	ld	s3,40(sp)
    800016f4:	7a02                	ld	s4,32(sp)
    800016f6:	6ae2                	ld	s5,24(sp)
    800016f8:	6b42                	ld	s6,16(sp)
    800016fa:	6ba2                	ld	s7,8(sp)
    800016fc:	6161                	addi	sp,sp,80
    800016fe:	8082                	ret
  return 0;
    80001700:	4501                	li	a0,0
}
    80001702:	8082                	ret

0000000080001704 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001704:	1141                	addi	sp,sp,-16
    80001706:	e406                	sd	ra,8(sp)
    80001708:	e022                	sd	s0,0(sp)
    8000170a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000170c:	4601                	li	a2,0
    8000170e:	00000097          	auipc	ra,0x0
    80001712:	94e080e7          	jalr	-1714(ra) # 8000105c <walk>
  if(pte == 0)
    80001716:	c901                	beqz	a0,80001726 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001718:	611c                	ld	a5,0(a0)
    8000171a:	9bbd                	andi	a5,a5,-17
    8000171c:	e11c                	sd	a5,0(a0)
}
    8000171e:	60a2                	ld	ra,8(sp)
    80001720:	6402                	ld	s0,0(sp)
    80001722:	0141                	addi	sp,sp,16
    80001724:	8082                	ret
    panic("uvmclear");
    80001726:	00007517          	auipc	a0,0x7
    8000172a:	aaa50513          	addi	a0,a0,-1366 # 800081d0 <digits+0x178>
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	ea8080e7          	jalr	-344(ra) # 800005d6 <panic>

0000000080001736 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001736:	c6bd                	beqz	a3,800017a4 <copyout+0x6e>
{
    80001738:	715d                	addi	sp,sp,-80
    8000173a:	e486                	sd	ra,72(sp)
    8000173c:	e0a2                	sd	s0,64(sp)
    8000173e:	fc26                	sd	s1,56(sp)
    80001740:	f84a                	sd	s2,48(sp)
    80001742:	f44e                	sd	s3,40(sp)
    80001744:	f052                	sd	s4,32(sp)
    80001746:	ec56                	sd	s5,24(sp)
    80001748:	e85a                	sd	s6,16(sp)
    8000174a:	e45e                	sd	s7,8(sp)
    8000174c:	e062                	sd	s8,0(sp)
    8000174e:	0880                	addi	s0,sp,80
    80001750:	8b2a                	mv	s6,a0
    80001752:	8c2e                	mv	s8,a1
    80001754:	8a32                	mv	s4,a2
    80001756:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001758:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000175a:	6a85                	lui	s5,0x1
    8000175c:	a015                	j	80001780 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000175e:	9562                	add	a0,a0,s8
    80001760:	0004861b          	sext.w	a2,s1
    80001764:	85d2                	mv	a1,s4
    80001766:	41250533          	sub	a0,a0,s2
    8000176a:	fffff097          	auipc	ra,0xfffff
    8000176e:	666080e7          	jalr	1638(ra) # 80000dd0 <memmove>

    len -= n;
    80001772:	409989b3          	sub	s3,s3,s1
    src += n;
    80001776:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001778:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000177c:	02098263          	beqz	s3,800017a0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001780:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001784:	85ca                	mv	a1,s2
    80001786:	855a                	mv	a0,s6
    80001788:	00000097          	auipc	ra,0x0
    8000178c:	97a080e7          	jalr	-1670(ra) # 80001102 <walkaddr>
    if(pa0 == 0)
    80001790:	cd01                	beqz	a0,800017a8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001792:	418904b3          	sub	s1,s2,s8
    80001796:	94d6                	add	s1,s1,s5
    if(n > len)
    80001798:	fc99f3e3          	bgeu	s3,s1,8000175e <copyout+0x28>
    8000179c:	84ce                	mv	s1,s3
    8000179e:	b7c1                	j	8000175e <copyout+0x28>
  }
  return 0;
    800017a0:	4501                	li	a0,0
    800017a2:	a021                	j	800017aa <copyout+0x74>
    800017a4:	4501                	li	a0,0
}
    800017a6:	8082                	ret
      return -1;
    800017a8:	557d                	li	a0,-1
}
    800017aa:	60a6                	ld	ra,72(sp)
    800017ac:	6406                	ld	s0,64(sp)
    800017ae:	74e2                	ld	s1,56(sp)
    800017b0:	7942                	ld	s2,48(sp)
    800017b2:	79a2                	ld	s3,40(sp)
    800017b4:	7a02                	ld	s4,32(sp)
    800017b6:	6ae2                	ld	s5,24(sp)
    800017b8:	6b42                	ld	s6,16(sp)
    800017ba:	6ba2                	ld	s7,8(sp)
    800017bc:	6c02                	ld	s8,0(sp)
    800017be:	6161                	addi	sp,sp,80
    800017c0:	8082                	ret

00000000800017c2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017c2:	c6bd                	beqz	a3,80001830 <copyin+0x6e>
{
    800017c4:	715d                	addi	sp,sp,-80
    800017c6:	e486                	sd	ra,72(sp)
    800017c8:	e0a2                	sd	s0,64(sp)
    800017ca:	fc26                	sd	s1,56(sp)
    800017cc:	f84a                	sd	s2,48(sp)
    800017ce:	f44e                	sd	s3,40(sp)
    800017d0:	f052                	sd	s4,32(sp)
    800017d2:	ec56                	sd	s5,24(sp)
    800017d4:	e85a                	sd	s6,16(sp)
    800017d6:	e45e                	sd	s7,8(sp)
    800017d8:	e062                	sd	s8,0(sp)
    800017da:	0880                	addi	s0,sp,80
    800017dc:	8b2a                	mv	s6,a0
    800017de:	8a2e                	mv	s4,a1
    800017e0:	8c32                	mv	s8,a2
    800017e2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017e4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e6:	6a85                	lui	s5,0x1
    800017e8:	a015                	j	8000180c <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017ea:	9562                	add	a0,a0,s8
    800017ec:	0004861b          	sext.w	a2,s1
    800017f0:	412505b3          	sub	a1,a0,s2
    800017f4:	8552                	mv	a0,s4
    800017f6:	fffff097          	auipc	ra,0xfffff
    800017fa:	5da080e7          	jalr	1498(ra) # 80000dd0 <memmove>

    len -= n;
    800017fe:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001802:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001804:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001808:	02098263          	beqz	s3,8000182c <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000180c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001810:	85ca                	mv	a1,s2
    80001812:	855a                	mv	a0,s6
    80001814:	00000097          	auipc	ra,0x0
    80001818:	8ee080e7          	jalr	-1810(ra) # 80001102 <walkaddr>
    if(pa0 == 0)
    8000181c:	cd01                	beqz	a0,80001834 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000181e:	418904b3          	sub	s1,s2,s8
    80001822:	94d6                	add	s1,s1,s5
    if(n > len)
    80001824:	fc99f3e3          	bgeu	s3,s1,800017ea <copyin+0x28>
    80001828:	84ce                	mv	s1,s3
    8000182a:	b7c1                	j	800017ea <copyin+0x28>
  }
  return 0;
    8000182c:	4501                	li	a0,0
    8000182e:	a021                	j	80001836 <copyin+0x74>
    80001830:	4501                	li	a0,0
}
    80001832:	8082                	ret
      return -1;
    80001834:	557d                	li	a0,-1
}
    80001836:	60a6                	ld	ra,72(sp)
    80001838:	6406                	ld	s0,64(sp)
    8000183a:	74e2                	ld	s1,56(sp)
    8000183c:	7942                	ld	s2,48(sp)
    8000183e:	79a2                	ld	s3,40(sp)
    80001840:	7a02                	ld	s4,32(sp)
    80001842:	6ae2                	ld	s5,24(sp)
    80001844:	6b42                	ld	s6,16(sp)
    80001846:	6ba2                	ld	s7,8(sp)
    80001848:	6c02                	ld	s8,0(sp)
    8000184a:	6161                	addi	sp,sp,80
    8000184c:	8082                	ret

000000008000184e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000184e:	c6c5                	beqz	a3,800018f6 <copyinstr+0xa8>
{
    80001850:	715d                	addi	sp,sp,-80
    80001852:	e486                	sd	ra,72(sp)
    80001854:	e0a2                	sd	s0,64(sp)
    80001856:	fc26                	sd	s1,56(sp)
    80001858:	f84a                	sd	s2,48(sp)
    8000185a:	f44e                	sd	s3,40(sp)
    8000185c:	f052                	sd	s4,32(sp)
    8000185e:	ec56                	sd	s5,24(sp)
    80001860:	e85a                	sd	s6,16(sp)
    80001862:	e45e                	sd	s7,8(sp)
    80001864:	0880                	addi	s0,sp,80
    80001866:	8a2a                	mv	s4,a0
    80001868:	8b2e                	mv	s6,a1
    8000186a:	8bb2                	mv	s7,a2
    8000186c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000186e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001870:	6985                	lui	s3,0x1
    80001872:	a035                	j	8000189e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001874:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001878:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000187a:	0017b793          	seqz	a5,a5
    8000187e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001882:	60a6                	ld	ra,72(sp)
    80001884:	6406                	ld	s0,64(sp)
    80001886:	74e2                	ld	s1,56(sp)
    80001888:	7942                	ld	s2,48(sp)
    8000188a:	79a2                	ld	s3,40(sp)
    8000188c:	7a02                	ld	s4,32(sp)
    8000188e:	6ae2                	ld	s5,24(sp)
    80001890:	6b42                	ld	s6,16(sp)
    80001892:	6ba2                	ld	s7,8(sp)
    80001894:	6161                	addi	sp,sp,80
    80001896:	8082                	ret
    srcva = va0 + PGSIZE;
    80001898:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000189c:	c8a9                	beqz	s1,800018ee <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000189e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018a2:	85ca                	mv	a1,s2
    800018a4:	8552                	mv	a0,s4
    800018a6:	00000097          	auipc	ra,0x0
    800018aa:	85c080e7          	jalr	-1956(ra) # 80001102 <walkaddr>
    if(pa0 == 0)
    800018ae:	c131                	beqz	a0,800018f2 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018b0:	41790833          	sub	a6,s2,s7
    800018b4:	984e                	add	a6,a6,s3
    if(n > max)
    800018b6:	0104f363          	bgeu	s1,a6,800018bc <copyinstr+0x6e>
    800018ba:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018bc:	955e                	add	a0,a0,s7
    800018be:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018c2:	fc080be3          	beqz	a6,80001898 <copyinstr+0x4a>
    800018c6:	985a                	add	a6,a6,s6
    800018c8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018ca:	41650633          	sub	a2,a0,s6
    800018ce:	14fd                	addi	s1,s1,-1
    800018d0:	9b26                	add	s6,s6,s1
    800018d2:	00f60733          	add	a4,a2,a5
    800018d6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8000>
    800018da:	df49                	beqz	a4,80001874 <copyinstr+0x26>
        *dst = *p;
    800018dc:	00e78023          	sb	a4,0(a5)
      --max;
    800018e0:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018e4:	0785                	addi	a5,a5,1
    while(n > 0){
    800018e6:	ff0796e3          	bne	a5,a6,800018d2 <copyinstr+0x84>
      dst++;
    800018ea:	8b42                	mv	s6,a6
    800018ec:	b775                	j	80001898 <copyinstr+0x4a>
    800018ee:	4781                	li	a5,0
    800018f0:	b769                	j	8000187a <copyinstr+0x2c>
      return -1;
    800018f2:	557d                	li	a0,-1
    800018f4:	b779                	j	80001882 <copyinstr+0x34>
  int got_null = 0;
    800018f6:	4781                	li	a5,0
  if(got_null){
    800018f8:	0017b793          	seqz	a5,a5
    800018fc:	40f00533          	neg	a0,a5
}
    80001900:	8082                	ret

0000000080001902 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001902:	1101                	addi	sp,sp,-32
    80001904:	ec06                	sd	ra,24(sp)
    80001906:	e822                	sd	s0,16(sp)
    80001908:	e426                	sd	s1,8(sp)
    8000190a:	1000                	addi	s0,sp,32
    8000190c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000190e:	fffff097          	auipc	ra,0xfffff
    80001912:	2ec080e7          	jalr	748(ra) # 80000bfa <holding>
    80001916:	c909                	beqz	a0,80001928 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001918:	749c                	ld	a5,40(s1)
    8000191a:	00978f63          	beq	a5,s1,80001938 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    8000191e:	60e2                	ld	ra,24(sp)
    80001920:	6442                	ld	s0,16(sp)
    80001922:	64a2                	ld	s1,8(sp)
    80001924:	6105                	addi	sp,sp,32
    80001926:	8082                	ret
    panic("wakeup1");
    80001928:	00007517          	auipc	a0,0x7
    8000192c:	8b850513          	addi	a0,a0,-1864 # 800081e0 <digits+0x188>
    80001930:	fffff097          	auipc	ra,0xfffff
    80001934:	ca6080e7          	jalr	-858(ra) # 800005d6 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001938:	4c98                	lw	a4,24(s1)
    8000193a:	4785                	li	a5,1
    8000193c:	fef711e3          	bne	a4,a5,8000191e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001940:	4789                	li	a5,2
    80001942:	cc9c                	sw	a5,24(s1)
}
    80001944:	bfe9                	j	8000191e <wakeup1+0x1c>

0000000080001946 <procinit>:
{
    80001946:	715d                	addi	sp,sp,-80
    80001948:	e486                	sd	ra,72(sp)
    8000194a:	e0a2                	sd	s0,64(sp)
    8000194c:	fc26                	sd	s1,56(sp)
    8000194e:	f84a                	sd	s2,48(sp)
    80001950:	f44e                	sd	s3,40(sp)
    80001952:	f052                	sd	s4,32(sp)
    80001954:	ec56                	sd	s5,24(sp)
    80001956:	e85a                	sd	s6,16(sp)
    80001958:	e45e                	sd	s7,8(sp)
    8000195a:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000195c:	00007597          	auipc	a1,0x7
    80001960:	88c58593          	addi	a1,a1,-1908 # 800081e8 <digits+0x190>
    80001964:	00010517          	auipc	a0,0x10
    80001968:	fec50513          	addi	a0,a0,-20 # 80011950 <pid_lock>
    8000196c:	fffff097          	auipc	ra,0xfffff
    80001970:	278080e7          	jalr	632(ra) # 80000be4 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001974:	00010917          	auipc	s2,0x10
    80001978:	3f490913          	addi	s2,s2,1012 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    8000197c:	00007b97          	auipc	s7,0x7
    80001980:	874b8b93          	addi	s7,s7,-1932 # 800081f0 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001984:	8b4a                	mv	s6,s2
    80001986:	00006a97          	auipc	s5,0x6
    8000198a:	67aa8a93          	addi	s5,s5,1658 # 80008000 <etext>
    8000198e:	040009b7          	lui	s3,0x4000
    80001992:	19fd                	addi	s3,s3,-1
    80001994:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001996:	00016a17          	auipc	s4,0x16
    8000199a:	5d2a0a13          	addi	s4,s4,1490 # 80017f68 <tickslock>
      initlock(&p->lock, "proc");
    8000199e:	85de                	mv	a1,s7
    800019a0:	854a                	mv	a0,s2
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	242080e7          	jalr	578(ra) # 80000be4 <initlock>
      char *pa = kalloc();
    800019aa:	fffff097          	auipc	ra,0xfffff
    800019ae:	1da080e7          	jalr	474(ra) # 80000b84 <kalloc>
    800019b2:	85aa                	mv	a1,a0
      if(pa == 0)
    800019b4:	c929                	beqz	a0,80001a06 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019b6:	416904b3          	sub	s1,s2,s6
    800019ba:	848d                	srai	s1,s1,0x3
    800019bc:	000ab783          	ld	a5,0(s5)
    800019c0:	02f484b3          	mul	s1,s1,a5
    800019c4:	2485                	addiw	s1,s1,1
    800019c6:	00d4949b          	slliw	s1,s1,0xd
    800019ca:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ce:	4699                	li	a3,6
    800019d0:	6605                	lui	a2,0x1
    800019d2:	8526                	mv	a0,s1
    800019d4:	00000097          	auipc	ra,0x0
    800019d8:	85c080e7          	jalr	-1956(ra) # 80001230 <kvmmap>
      p->kstack = va;
    800019dc:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e0:	18890913          	addi	s2,s2,392
    800019e4:	fb491de3          	bne	s2,s4,8000199e <procinit+0x58>
  kvminithart();
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	650080e7          	jalr	1616(ra) # 80001038 <kvminithart>
}
    800019f0:	60a6                	ld	ra,72(sp)
    800019f2:	6406                	ld	s0,64(sp)
    800019f4:	74e2                	ld	s1,56(sp)
    800019f6:	7942                	ld	s2,48(sp)
    800019f8:	79a2                	ld	s3,40(sp)
    800019fa:	7a02                	ld	s4,32(sp)
    800019fc:	6ae2                	ld	s5,24(sp)
    800019fe:	6b42                	ld	s6,16(sp)
    80001a00:	6ba2                	ld	s7,8(sp)
    80001a02:	6161                	addi	sp,sp,80
    80001a04:	8082                	ret
        panic("kalloc");
    80001a06:	00006517          	auipc	a0,0x6
    80001a0a:	7f250513          	addi	a0,a0,2034 # 800081f8 <digits+0x1a0>
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	bc8080e7          	jalr	-1080(ra) # 800005d6 <panic>

0000000080001a16 <cpuid>:
{
    80001a16:	1141                	addi	sp,sp,-16
    80001a18:	e422                	sd	s0,8(sp)
    80001a1a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a1c:	8512                	mv	a0,tp
}
    80001a1e:	2501                	sext.w	a0,a0
    80001a20:	6422                	ld	s0,8(sp)
    80001a22:	0141                	addi	sp,sp,16
    80001a24:	8082                	ret

0000000080001a26 <mycpu>:
mycpu(void) {
    80001a26:	1141                	addi	sp,sp,-16
    80001a28:	e422                	sd	s0,8(sp)
    80001a2a:	0800                	addi	s0,sp,16
    80001a2c:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a2e:	2781                	sext.w	a5,a5
    80001a30:	079e                	slli	a5,a5,0x7
}
    80001a32:	00010517          	auipc	a0,0x10
    80001a36:	f3650513          	addi	a0,a0,-202 # 80011968 <cpus>
    80001a3a:	953e                	add	a0,a0,a5
    80001a3c:	6422                	ld	s0,8(sp)
    80001a3e:	0141                	addi	sp,sp,16
    80001a40:	8082                	ret

0000000080001a42 <myproc>:
myproc(void) {
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	1000                	addi	s0,sp,32
  push_off();
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	1dc080e7          	jalr	476(ra) # 80000c28 <push_off>
    80001a54:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a56:	2781                	sext.w	a5,a5
    80001a58:	079e                	slli	a5,a5,0x7
    80001a5a:	00010717          	auipc	a4,0x10
    80001a5e:	ef670713          	addi	a4,a4,-266 # 80011950 <pid_lock>
    80001a62:	97ba                	add	a5,a5,a4
    80001a64:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	262080e7          	jalr	610(ra) # 80000cc8 <pop_off>
}
    80001a6e:	8526                	mv	a0,s1
    80001a70:	60e2                	ld	ra,24(sp)
    80001a72:	6442                	ld	s0,16(sp)
    80001a74:	64a2                	ld	s1,8(sp)
    80001a76:	6105                	addi	sp,sp,32
    80001a78:	8082                	ret

0000000080001a7a <forkret>:
{
    80001a7a:	1141                	addi	sp,sp,-16
    80001a7c:	e406                	sd	ra,8(sp)
    80001a7e:	e022                	sd	s0,0(sp)
    80001a80:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a82:	00000097          	auipc	ra,0x0
    80001a86:	fc0080e7          	jalr	-64(ra) # 80001a42 <myproc>
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	29e080e7          	jalr	670(ra) # 80000d28 <release>
  if (first) {
    80001a92:	00007797          	auipc	a5,0x7
    80001a96:	dae7a783          	lw	a5,-594(a5) # 80008840 <first.1671>
    80001a9a:	eb89                	bnez	a5,80001aac <forkret+0x32>
  usertrapret();
    80001a9c:	00001097          	auipc	ra,0x1
    80001aa0:	c4c080e7          	jalr	-948(ra) # 800026e8 <usertrapret>
}
    80001aa4:	60a2                	ld	ra,8(sp)
    80001aa6:	6402                	ld	s0,0(sp)
    80001aa8:	0141                	addi	sp,sp,16
    80001aaa:	8082                	ret
    first = 0;
    80001aac:	00007797          	auipc	a5,0x7
    80001ab0:	d807aa23          	sw	zero,-620(a5) # 80008840 <first.1671>
    fsinit(ROOTDEV);
    80001ab4:	4505                	li	a0,1
    80001ab6:	00002097          	auipc	ra,0x2
    80001aba:	a6e080e7          	jalr	-1426(ra) # 80003524 <fsinit>
    80001abe:	bff9                	j	80001a9c <forkret+0x22>

0000000080001ac0 <allocpid>:
allocpid() {
    80001ac0:	1101                	addi	sp,sp,-32
    80001ac2:	ec06                	sd	ra,24(sp)
    80001ac4:	e822                	sd	s0,16(sp)
    80001ac6:	e426                	sd	s1,8(sp)
    80001ac8:	e04a                	sd	s2,0(sp)
    80001aca:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001acc:	00010917          	auipc	s2,0x10
    80001ad0:	e8490913          	addi	s2,s2,-380 # 80011950 <pid_lock>
    80001ad4:	854a                	mv	a0,s2
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	19e080e7          	jalr	414(ra) # 80000c74 <acquire>
  pid = nextpid;
    80001ade:	00007797          	auipc	a5,0x7
    80001ae2:	d6678793          	addi	a5,a5,-666 # 80008844 <nextpid>
    80001ae6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ae8:	0014871b          	addiw	a4,s1,1
    80001aec:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aee:	854a                	mv	a0,s2
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	238080e7          	jalr	568(ra) # 80000d28 <release>
}
    80001af8:	8526                	mv	a0,s1
    80001afa:	60e2                	ld	ra,24(sp)
    80001afc:	6442                	ld	s0,16(sp)
    80001afe:	64a2                	ld	s1,8(sp)
    80001b00:	6902                	ld	s2,0(sp)
    80001b02:	6105                	addi	sp,sp,32
    80001b04:	8082                	ret

0000000080001b06 <proc_pagetable>:
{
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	addi	s0,sp,32
    80001b12:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b14:	00000097          	auipc	ra,0x0
    80001b18:	8ea080e7          	jalr	-1814(ra) # 800013fe <uvmcreate>
    80001b1c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b1e:	c121                	beqz	a0,80001b5e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b20:	4729                	li	a4,10
    80001b22:	00005697          	auipc	a3,0x5
    80001b26:	4de68693          	addi	a3,a3,1246 # 80007000 <_trampoline>
    80001b2a:	6605                	lui	a2,0x1
    80001b2c:	040005b7          	lui	a1,0x4000
    80001b30:	15fd                	addi	a1,a1,-1
    80001b32:	05b2                	slli	a1,a1,0xc
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	66e080e7          	jalr	1646(ra) # 800011a2 <mappages>
    80001b3c:	02054863          	bltz	a0,80001b6c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b40:	4719                	li	a4,6
    80001b42:	05893683          	ld	a3,88(s2)
    80001b46:	6605                	lui	a2,0x1
    80001b48:	020005b7          	lui	a1,0x2000
    80001b4c:	15fd                	addi	a1,a1,-1
    80001b4e:	05b6                	slli	a1,a1,0xd
    80001b50:	8526                	mv	a0,s1
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	650080e7          	jalr	1616(ra) # 800011a2 <mappages>
    80001b5a:	02054163          	bltz	a0,80001b7c <proc_pagetable+0x76>
}
    80001b5e:	8526                	mv	a0,s1
    80001b60:	60e2                	ld	ra,24(sp)
    80001b62:	6442                	ld	s0,16(sp)
    80001b64:	64a2                	ld	s1,8(sp)
    80001b66:	6902                	ld	s2,0(sp)
    80001b68:	6105                	addi	sp,sp,32
    80001b6a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b6c:	4581                	li	a1,0
    80001b6e:	8526                	mv	a0,s1
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	a8a080e7          	jalr	-1398(ra) # 800015fa <uvmfree>
    return 0;
    80001b78:	4481                	li	s1,0
    80001b7a:	b7d5                	j	80001b5e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b7c:	4681                	li	a3,0
    80001b7e:	4605                	li	a2,1
    80001b80:	040005b7          	lui	a1,0x4000
    80001b84:	15fd                	addi	a1,a1,-1
    80001b86:	05b2                	slli	a1,a1,0xc
    80001b88:	8526                	mv	a0,s1
    80001b8a:	fffff097          	auipc	ra,0xfffff
    80001b8e:	7b0080e7          	jalr	1968(ra) # 8000133a <uvmunmap>
    uvmfree(pagetable, 0);
    80001b92:	4581                	li	a1,0
    80001b94:	8526                	mv	a0,s1
    80001b96:	00000097          	auipc	ra,0x0
    80001b9a:	a64080e7          	jalr	-1436(ra) # 800015fa <uvmfree>
    return 0;
    80001b9e:	4481                	li	s1,0
    80001ba0:	bf7d                	j	80001b5e <proc_pagetable+0x58>

0000000080001ba2 <proc_freepagetable>:
{
    80001ba2:	1101                	addi	sp,sp,-32
    80001ba4:	ec06                	sd	ra,24(sp)
    80001ba6:	e822                	sd	s0,16(sp)
    80001ba8:	e426                	sd	s1,8(sp)
    80001baa:	e04a                	sd	s2,0(sp)
    80001bac:	1000                	addi	s0,sp,32
    80001bae:	84aa                	mv	s1,a0
    80001bb0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bb2:	4681                	li	a3,0
    80001bb4:	4605                	li	a2,1
    80001bb6:	040005b7          	lui	a1,0x4000
    80001bba:	15fd                	addi	a1,a1,-1
    80001bbc:	05b2                	slli	a1,a1,0xc
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	77c080e7          	jalr	1916(ra) # 8000133a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bc6:	4681                	li	a3,0
    80001bc8:	4605                	li	a2,1
    80001bca:	020005b7          	lui	a1,0x2000
    80001bce:	15fd                	addi	a1,a1,-1
    80001bd0:	05b6                	slli	a1,a1,0xd
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	766080e7          	jalr	1894(ra) # 8000133a <uvmunmap>
  uvmfree(pagetable, sz);
    80001bdc:	85ca                	mv	a1,s2
    80001bde:	8526                	mv	a0,s1
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	a1a080e7          	jalr	-1510(ra) # 800015fa <uvmfree>
}
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret

0000000080001bf4 <freeproc>:
{
    80001bf4:	1101                	addi	sp,sp,-32
    80001bf6:	ec06                	sd	ra,24(sp)
    80001bf8:	e822                	sd	s0,16(sp)
    80001bfa:	e426                	sd	s1,8(sp)
    80001bfc:	1000                	addi	s0,sp,32
    80001bfe:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c00:	6d28                	ld	a0,88(a0)
    80001c02:	c509                	beqz	a0,80001c0c <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	e84080e7          	jalr	-380(ra) # 80000a88 <kfree>
  if(p->trapframe2)
    80001c0c:	1804b503          	ld	a0,384(s1)
    80001c10:	c509                	beqz	a0,80001c1a <freeproc+0x26>
    kfree((void*)p->trapframe2);
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	e76080e7          	jalr	-394(ra) # 80000a88 <kfree>
  p->trapframe = 0;
    80001c1a:	0404bc23          	sd	zero,88(s1)
  p->trapframe2 = 0;
    80001c1e:	1804b023          	sd	zero,384(s1)
  if(p->pagetable)
    80001c22:	68a8                	ld	a0,80(s1)
    80001c24:	c511                	beqz	a0,80001c30 <freeproc+0x3c>
    proc_freepagetable(p->pagetable, p->sz);
    80001c26:	64ac                	ld	a1,72(s1)
    80001c28:	00000097          	auipc	ra,0x0
    80001c2c:	f7a080e7          	jalr	-134(ra) # 80001ba2 <proc_freepagetable>
  p->pagetable = 0;
    80001c30:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c34:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c38:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c3c:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c40:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c44:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c48:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c4c:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c50:	0004ac23          	sw	zero,24(s1)
}
    80001c54:	60e2                	ld	ra,24(sp)
    80001c56:	6442                	ld	s0,16(sp)
    80001c58:	64a2                	ld	s1,8(sp)
    80001c5a:	6105                	addi	sp,sp,32
    80001c5c:	8082                	ret

0000000080001c5e <allocproc>:
{
    80001c5e:	1101                	addi	sp,sp,-32
    80001c60:	ec06                	sd	ra,24(sp)
    80001c62:	e822                	sd	s0,16(sp)
    80001c64:	e426                	sd	s1,8(sp)
    80001c66:	e04a                	sd	s2,0(sp)
    80001c68:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c6a:	00010497          	auipc	s1,0x10
    80001c6e:	0fe48493          	addi	s1,s1,254 # 80011d68 <proc>
    80001c72:	00016917          	auipc	s2,0x16
    80001c76:	2f690913          	addi	s2,s2,758 # 80017f68 <tickslock>
    acquire(&p->lock);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	ff8080e7          	jalr	-8(ra) # 80000c74 <acquire>
    if(p->state == UNUSED) {
    80001c84:	4c9c                	lw	a5,24(s1)
    80001c86:	cf81                	beqz	a5,80001c9e <allocproc+0x40>
      release(&p->lock);
    80001c88:	8526                	mv	a0,s1
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	09e080e7          	jalr	158(ra) # 80000d28 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c92:	18848493          	addi	s1,s1,392
    80001c96:	ff2492e3          	bne	s1,s2,80001c7a <allocproc+0x1c>
  return 0;
    80001c9a:	4481                	li	s1,0
    80001c9c:	a08d                	j	80001cfe <allocproc+0xa0>
  p->pid = allocpid();
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	e22080e7          	jalr	-478(ra) # 80001ac0 <allocpid>
    80001ca6:	dc88                	sw	a0,56(s1)
  p->ticks = 0;
    80001ca8:	1604ac23          	sw	zero,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	ed8080e7          	jalr	-296(ra) # 80000b84 <kalloc>
    80001cb4:	892a                	mv	s2,a0
    80001cb6:	eca8                	sd	a0,88(s1)
    80001cb8:	c931                	beqz	a0,80001d0c <allocproc+0xae>
  if((p->trapframe2 = (struct trapframe *)kalloc()) == 0){
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	eca080e7          	jalr	-310(ra) # 80000b84 <kalloc>
    80001cc2:	892a                	mv	s2,a0
    80001cc4:	18a4b023          	sd	a0,384(s1)
    80001cc8:	c929                	beqz	a0,80001d1a <allocproc+0xbc>
  p->pagetable = proc_pagetable(p);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	00000097          	auipc	ra,0x0
    80001cd0:	e3a080e7          	jalr	-454(ra) # 80001b06 <proc_pagetable>
    80001cd4:	892a                	mv	s2,a0
    80001cd6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cd8:	c921                	beqz	a0,80001d28 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001cda:	07000613          	li	a2,112
    80001cde:	4581                	li	a1,0
    80001ce0:	06048513          	addi	a0,s1,96
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	08c080e7          	jalr	140(ra) # 80000d70 <memset>
  p->context.ra = (uint64)forkret;
    80001cec:	00000797          	auipc	a5,0x0
    80001cf0:	d8e78793          	addi	a5,a5,-626 # 80001a7a <forkret>
    80001cf4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cf6:	60bc                	ld	a5,64(s1)
    80001cf8:	6705                	lui	a4,0x1
    80001cfa:	97ba                	add	a5,a5,a4
    80001cfc:	f4bc                	sd	a5,104(s1)
}
    80001cfe:	8526                	mv	a0,s1
    80001d00:	60e2                	ld	ra,24(sp)
    80001d02:	6442                	ld	s0,16(sp)
    80001d04:	64a2                	ld	s1,8(sp)
    80001d06:	6902                	ld	s2,0(sp)
    80001d08:	6105                	addi	sp,sp,32
    80001d0a:	8082                	ret
    release(&p->lock);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	01a080e7          	jalr	26(ra) # 80000d28 <release>
    return 0;
    80001d16:	84ca                	mv	s1,s2
    80001d18:	b7dd                	j	80001cfe <allocproc+0xa0>
    release(&p->lock);
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	00c080e7          	jalr	12(ra) # 80000d28 <release>
    return 0;
    80001d24:	84ca                	mv	s1,s2
    80001d26:	bfe1                	j	80001cfe <allocproc+0xa0>
    freeproc(p);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	00000097          	auipc	ra,0x0
    80001d2e:	eca080e7          	jalr	-310(ra) # 80001bf4 <freeproc>
    release(&p->lock);
    80001d32:	8526                	mv	a0,s1
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	ff4080e7          	jalr	-12(ra) # 80000d28 <release>
    return 0;
    80001d3c:	84ca                	mv	s1,s2
    80001d3e:	b7c1                	j	80001cfe <allocproc+0xa0>

0000000080001d40 <userinit>:
{
    80001d40:	1101                	addi	sp,sp,-32
    80001d42:	ec06                	sd	ra,24(sp)
    80001d44:	e822                	sd	s0,16(sp)
    80001d46:	e426                	sd	s1,8(sp)
    80001d48:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d4a:	00000097          	auipc	ra,0x0
    80001d4e:	f14080e7          	jalr	-236(ra) # 80001c5e <allocproc>
    80001d52:	84aa                	mv	s1,a0
  initproc = p;
    80001d54:	00007797          	auipc	a5,0x7
    80001d58:	2ca7b223          	sd	a0,708(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d5c:	03400613          	li	a2,52
    80001d60:	00007597          	auipc	a1,0x7
    80001d64:	af058593          	addi	a1,a1,-1296 # 80008850 <initcode>
    80001d68:	6928                	ld	a0,80(a0)
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	6c2080e7          	jalr	1730(ra) # 8000142c <uvminit>
  p->sz = PGSIZE;
    80001d72:	6785                	lui	a5,0x1
    80001d74:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d76:	6cb8                	ld	a4,88(s1)
    80001d78:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d7c:	6cb8                	ld	a4,88(s1)
    80001d7e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d80:	4641                	li	a2,16
    80001d82:	00006597          	auipc	a1,0x6
    80001d86:	47e58593          	addi	a1,a1,1150 # 80008200 <digits+0x1a8>
    80001d8a:	15848513          	addi	a0,s1,344
    80001d8e:	fffff097          	auipc	ra,0xfffff
    80001d92:	138080e7          	jalr	312(ra) # 80000ec6 <safestrcpy>
  p->cwd = namei("/");
    80001d96:	00006517          	auipc	a0,0x6
    80001d9a:	47a50513          	addi	a0,a0,1146 # 80008210 <digits+0x1b8>
    80001d9e:	00002097          	auipc	ra,0x2
    80001da2:	1ae080e7          	jalr	430(ra) # 80003f4c <namei>
    80001da6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001daa:	4789                	li	a5,2
    80001dac:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dae:	8526                	mv	a0,s1
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	f78080e7          	jalr	-136(ra) # 80000d28 <release>
}
    80001db8:	60e2                	ld	ra,24(sp)
    80001dba:	6442                	ld	s0,16(sp)
    80001dbc:	64a2                	ld	s1,8(sp)
    80001dbe:	6105                	addi	sp,sp,32
    80001dc0:	8082                	ret

0000000080001dc2 <growproc>:
{
    80001dc2:	1101                	addi	sp,sp,-32
    80001dc4:	ec06                	sd	ra,24(sp)
    80001dc6:	e822                	sd	s0,16(sp)
    80001dc8:	e426                	sd	s1,8(sp)
    80001dca:	e04a                	sd	s2,0(sp)
    80001dcc:	1000                	addi	s0,sp,32
    80001dce:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dd0:	00000097          	auipc	ra,0x0
    80001dd4:	c72080e7          	jalr	-910(ra) # 80001a42 <myproc>
    80001dd8:	892a                	mv	s2,a0
  sz = p->sz;
    80001dda:	652c                	ld	a1,72(a0)
    80001ddc:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001de0:	00904f63          	bgtz	s1,80001dfe <growproc+0x3c>
  } else if(n < 0){
    80001de4:	0204cc63          	bltz	s1,80001e1c <growproc+0x5a>
  p->sz = sz;
    80001de8:	1602                	slli	a2,a2,0x20
    80001dea:	9201                	srli	a2,a2,0x20
    80001dec:	04c93423          	sd	a2,72(s2)
  return 0;
    80001df0:	4501                	li	a0,0
}
    80001df2:	60e2                	ld	ra,24(sp)
    80001df4:	6442                	ld	s0,16(sp)
    80001df6:	64a2                	ld	s1,8(sp)
    80001df8:	6902                	ld	s2,0(sp)
    80001dfa:	6105                	addi	sp,sp,32
    80001dfc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dfe:	9e25                	addw	a2,a2,s1
    80001e00:	1602                	slli	a2,a2,0x20
    80001e02:	9201                	srli	a2,a2,0x20
    80001e04:	1582                	slli	a1,a1,0x20
    80001e06:	9181                	srli	a1,a1,0x20
    80001e08:	6928                	ld	a0,80(a0)
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	6dc080e7          	jalr	1756(ra) # 800014e6 <uvmalloc>
    80001e12:	0005061b          	sext.w	a2,a0
    80001e16:	fa69                	bnez	a2,80001de8 <growproc+0x26>
      return -1;
    80001e18:	557d                	li	a0,-1
    80001e1a:	bfe1                	j	80001df2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e1c:	9e25                	addw	a2,a2,s1
    80001e1e:	1602                	slli	a2,a2,0x20
    80001e20:	9201                	srli	a2,a2,0x20
    80001e22:	1582                	slli	a1,a1,0x20
    80001e24:	9181                	srli	a1,a1,0x20
    80001e26:	6928                	ld	a0,80(a0)
    80001e28:	fffff097          	auipc	ra,0xfffff
    80001e2c:	676080e7          	jalr	1654(ra) # 8000149e <uvmdealloc>
    80001e30:	0005061b          	sext.w	a2,a0
    80001e34:	bf55                	j	80001de8 <growproc+0x26>

0000000080001e36 <fork>:
{
    80001e36:	7179                	addi	sp,sp,-48
    80001e38:	f406                	sd	ra,40(sp)
    80001e3a:	f022                	sd	s0,32(sp)
    80001e3c:	ec26                	sd	s1,24(sp)
    80001e3e:	e84a                	sd	s2,16(sp)
    80001e40:	e44e                	sd	s3,8(sp)
    80001e42:	e052                	sd	s4,0(sp)
    80001e44:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e46:	00000097          	auipc	ra,0x0
    80001e4a:	bfc080e7          	jalr	-1028(ra) # 80001a42 <myproc>
    80001e4e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e50:	00000097          	auipc	ra,0x0
    80001e54:	e0e080e7          	jalr	-498(ra) # 80001c5e <allocproc>
    80001e58:	c175                	beqz	a0,80001f3c <fork+0x106>
    80001e5a:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e5c:	04893603          	ld	a2,72(s2)
    80001e60:	692c                	ld	a1,80(a0)
    80001e62:	05093503          	ld	a0,80(s2)
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	7cc080e7          	jalr	1996(ra) # 80001632 <uvmcopy>
    80001e6e:	04054863          	bltz	a0,80001ebe <fork+0x88>
  np->sz = p->sz;
    80001e72:	04893783          	ld	a5,72(s2)
    80001e76:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001e7a:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e7e:	05893683          	ld	a3,88(s2)
    80001e82:	87b6                	mv	a5,a3
    80001e84:	0589b703          	ld	a4,88(s3)
    80001e88:	12068693          	addi	a3,a3,288
    80001e8c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e90:	6788                	ld	a0,8(a5)
    80001e92:	6b8c                	ld	a1,16(a5)
    80001e94:	6f90                	ld	a2,24(a5)
    80001e96:	01073023          	sd	a6,0(a4)
    80001e9a:	e708                	sd	a0,8(a4)
    80001e9c:	eb0c                	sd	a1,16(a4)
    80001e9e:	ef10                	sd	a2,24(a4)
    80001ea0:	02078793          	addi	a5,a5,32
    80001ea4:	02070713          	addi	a4,a4,32
    80001ea8:	fed792e3          	bne	a5,a3,80001e8c <fork+0x56>
  np->trapframe->a0 = 0;
    80001eac:	0589b783          	ld	a5,88(s3)
    80001eb0:	0607b823          	sd	zero,112(a5)
    80001eb4:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001eb8:	15000a13          	li	s4,336
    80001ebc:	a03d                	j	80001eea <fork+0xb4>
    freeproc(np);
    80001ebe:	854e                	mv	a0,s3
    80001ec0:	00000097          	auipc	ra,0x0
    80001ec4:	d34080e7          	jalr	-716(ra) # 80001bf4 <freeproc>
    release(&np->lock);
    80001ec8:	854e                	mv	a0,s3
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	e5e080e7          	jalr	-418(ra) # 80000d28 <release>
    return -1;
    80001ed2:	54fd                	li	s1,-1
    80001ed4:	a899                	j	80001f2a <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ed6:	00002097          	auipc	ra,0x2
    80001eda:	702080e7          	jalr	1794(ra) # 800045d8 <filedup>
    80001ede:	009987b3          	add	a5,s3,s1
    80001ee2:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ee4:	04a1                	addi	s1,s1,8
    80001ee6:	01448763          	beq	s1,s4,80001ef4 <fork+0xbe>
    if(p->ofile[i])
    80001eea:	009907b3          	add	a5,s2,s1
    80001eee:	6388                	ld	a0,0(a5)
    80001ef0:	f17d                	bnez	a0,80001ed6 <fork+0xa0>
    80001ef2:	bfcd                	j	80001ee4 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001ef4:	15093503          	ld	a0,336(s2)
    80001ef8:	00002097          	auipc	ra,0x2
    80001efc:	866080e7          	jalr	-1946(ra) # 8000375e <idup>
    80001f00:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f04:	4641                	li	a2,16
    80001f06:	15890593          	addi	a1,s2,344
    80001f0a:	15898513          	addi	a0,s3,344
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	fb8080e7          	jalr	-72(ra) # 80000ec6 <safestrcpy>
  pid = np->pid;
    80001f16:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001f1a:	4789                	li	a5,2
    80001f1c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f20:	854e                	mv	a0,s3
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	e06080e7          	jalr	-506(ra) # 80000d28 <release>
}
    80001f2a:	8526                	mv	a0,s1
    80001f2c:	70a2                	ld	ra,40(sp)
    80001f2e:	7402                	ld	s0,32(sp)
    80001f30:	64e2                	ld	s1,24(sp)
    80001f32:	6942                	ld	s2,16(sp)
    80001f34:	69a2                	ld	s3,8(sp)
    80001f36:	6a02                	ld	s4,0(sp)
    80001f38:	6145                	addi	sp,sp,48
    80001f3a:	8082                	ret
    return -1;
    80001f3c:	54fd                	li	s1,-1
    80001f3e:	b7f5                	j	80001f2a <fork+0xf4>

0000000080001f40 <reparent>:
{
    80001f40:	7179                	addi	sp,sp,-48
    80001f42:	f406                	sd	ra,40(sp)
    80001f44:	f022                	sd	s0,32(sp)
    80001f46:	ec26                	sd	s1,24(sp)
    80001f48:	e84a                	sd	s2,16(sp)
    80001f4a:	e44e                	sd	s3,8(sp)
    80001f4c:	e052                	sd	s4,0(sp)
    80001f4e:	1800                	addi	s0,sp,48
    80001f50:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f52:	00010497          	auipc	s1,0x10
    80001f56:	e1648493          	addi	s1,s1,-490 # 80011d68 <proc>
      pp->parent = initproc;
    80001f5a:	00007a17          	auipc	s4,0x7
    80001f5e:	0bea0a13          	addi	s4,s4,190 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f62:	00016997          	auipc	s3,0x16
    80001f66:	00698993          	addi	s3,s3,6 # 80017f68 <tickslock>
    80001f6a:	a029                	j	80001f74 <reparent+0x34>
    80001f6c:	18848493          	addi	s1,s1,392
    80001f70:	03348363          	beq	s1,s3,80001f96 <reparent+0x56>
    if(pp->parent == p){
    80001f74:	709c                	ld	a5,32(s1)
    80001f76:	ff279be3          	bne	a5,s2,80001f6c <reparent+0x2c>
      acquire(&pp->lock);
    80001f7a:	8526                	mv	a0,s1
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	cf8080e7          	jalr	-776(ra) # 80000c74 <acquire>
      pp->parent = initproc;
    80001f84:	000a3783          	ld	a5,0(s4)
    80001f88:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	d9c080e7          	jalr	-612(ra) # 80000d28 <release>
    80001f94:	bfe1                	j	80001f6c <reparent+0x2c>
}
    80001f96:	70a2                	ld	ra,40(sp)
    80001f98:	7402                	ld	s0,32(sp)
    80001f9a:	64e2                	ld	s1,24(sp)
    80001f9c:	6942                	ld	s2,16(sp)
    80001f9e:	69a2                	ld	s3,8(sp)
    80001fa0:	6a02                	ld	s4,0(sp)
    80001fa2:	6145                	addi	sp,sp,48
    80001fa4:	8082                	ret

0000000080001fa6 <scheduler>:
{
    80001fa6:	715d                	addi	sp,sp,-80
    80001fa8:	e486                	sd	ra,72(sp)
    80001faa:	e0a2                	sd	s0,64(sp)
    80001fac:	fc26                	sd	s1,56(sp)
    80001fae:	f84a                	sd	s2,48(sp)
    80001fb0:	f44e                	sd	s3,40(sp)
    80001fb2:	f052                	sd	s4,32(sp)
    80001fb4:	ec56                	sd	s5,24(sp)
    80001fb6:	e85a                	sd	s6,16(sp)
    80001fb8:	e45e                	sd	s7,8(sp)
    80001fba:	e062                	sd	s8,0(sp)
    80001fbc:	0880                	addi	s0,sp,80
    80001fbe:	8792                	mv	a5,tp
  int id = r_tp();
    80001fc0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fc2:	00779b13          	slli	s6,a5,0x7
    80001fc6:	00010717          	auipc	a4,0x10
    80001fca:	98a70713          	addi	a4,a4,-1654 # 80011950 <pid_lock>
    80001fce:	975a                	add	a4,a4,s6
    80001fd0:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001fd4:	00010717          	auipc	a4,0x10
    80001fd8:	99c70713          	addi	a4,a4,-1636 # 80011970 <cpus+0x8>
    80001fdc:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fde:	4c0d                	li	s8,3
        c->proc = p;
    80001fe0:	079e                	slli	a5,a5,0x7
    80001fe2:	00010a17          	auipc	s4,0x10
    80001fe6:	96ea0a13          	addi	s4,s4,-1682 # 80011950 <pid_lock>
    80001fea:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fec:	00016997          	auipc	s3,0x16
    80001ff0:	f7c98993          	addi	s3,s3,-132 # 80017f68 <tickslock>
        found = 1;
    80001ff4:	4b85                	li	s7,1
    80001ff6:	a899                	j	8000204c <scheduler+0xa6>
        p->state = RUNNING;
    80001ff8:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001ffc:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80002000:	06048593          	addi	a1,s1,96
    80002004:	855a                	mv	a0,s6
    80002006:	00000097          	auipc	ra,0x0
    8000200a:	638080e7          	jalr	1592(ra) # 8000263e <swtch>
        c->proc = 0;
    8000200e:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80002012:	8ade                	mv	s5,s7
      release(&p->lock);
    80002014:	8526                	mv	a0,s1
    80002016:	fffff097          	auipc	ra,0xfffff
    8000201a:	d12080e7          	jalr	-750(ra) # 80000d28 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000201e:	18848493          	addi	s1,s1,392
    80002022:	01348b63          	beq	s1,s3,80002038 <scheduler+0x92>
      acquire(&p->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	c4c080e7          	jalr	-948(ra) # 80000c74 <acquire>
      if(p->state == RUNNABLE) {
    80002030:	4c9c                	lw	a5,24(s1)
    80002032:	ff2791e3          	bne	a5,s2,80002014 <scheduler+0x6e>
    80002036:	b7c9                	j	80001ff8 <scheduler+0x52>
    if(found == 0) {
    80002038:	000a9a63          	bnez	s5,8000204c <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000203c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002044:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002048:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000204c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002050:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002054:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002058:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000205a:	00010497          	auipc	s1,0x10
    8000205e:	d0e48493          	addi	s1,s1,-754 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002062:	4909                	li	s2,2
    80002064:	b7c9                	j	80002026 <scheduler+0x80>

0000000080002066 <sched>:
{
    80002066:	7179                	addi	sp,sp,-48
    80002068:	f406                	sd	ra,40(sp)
    8000206a:	f022                	sd	s0,32(sp)
    8000206c:	ec26                	sd	s1,24(sp)
    8000206e:	e84a                	sd	s2,16(sp)
    80002070:	e44e                	sd	s3,8(sp)
    80002072:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002074:	00000097          	auipc	ra,0x0
    80002078:	9ce080e7          	jalr	-1586(ra) # 80001a42 <myproc>
    8000207c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	b7c080e7          	jalr	-1156(ra) # 80000bfa <holding>
    80002086:	c93d                	beqz	a0,800020fc <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002088:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000208a:	2781                	sext.w	a5,a5
    8000208c:	079e                	slli	a5,a5,0x7
    8000208e:	00010717          	auipc	a4,0x10
    80002092:	8c270713          	addi	a4,a4,-1854 # 80011950 <pid_lock>
    80002096:	97ba                	add	a5,a5,a4
    80002098:	0907a703          	lw	a4,144(a5)
    8000209c:	4785                	li	a5,1
    8000209e:	06f71763          	bne	a4,a5,8000210c <sched+0xa6>
  if(p->state == RUNNING)
    800020a2:	4c98                	lw	a4,24(s1)
    800020a4:	478d                	li	a5,3
    800020a6:	06f70b63          	beq	a4,a5,8000211c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020aa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020ae:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020b0:	efb5                	bnez	a5,8000212c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020b2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020b4:	00010917          	auipc	s2,0x10
    800020b8:	89c90913          	addi	s2,s2,-1892 # 80011950 <pid_lock>
    800020bc:	2781                	sext.w	a5,a5
    800020be:	079e                	slli	a5,a5,0x7
    800020c0:	97ca                	add	a5,a5,s2
    800020c2:	0947a983          	lw	s3,148(a5)
    800020c6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020c8:	2781                	sext.w	a5,a5
    800020ca:	079e                	slli	a5,a5,0x7
    800020cc:	00010597          	auipc	a1,0x10
    800020d0:	8a458593          	addi	a1,a1,-1884 # 80011970 <cpus+0x8>
    800020d4:	95be                	add	a1,a1,a5
    800020d6:	06048513          	addi	a0,s1,96
    800020da:	00000097          	auipc	ra,0x0
    800020de:	564080e7          	jalr	1380(ra) # 8000263e <swtch>
    800020e2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020e4:	2781                	sext.w	a5,a5
    800020e6:	079e                	slli	a5,a5,0x7
    800020e8:	97ca                	add	a5,a5,s2
    800020ea:	0937aa23          	sw	s3,148(a5)
}
    800020ee:	70a2                	ld	ra,40(sp)
    800020f0:	7402                	ld	s0,32(sp)
    800020f2:	64e2                	ld	s1,24(sp)
    800020f4:	6942                	ld	s2,16(sp)
    800020f6:	69a2                	ld	s3,8(sp)
    800020f8:	6145                	addi	sp,sp,48
    800020fa:	8082                	ret
    panic("sched p->lock");
    800020fc:	00006517          	auipc	a0,0x6
    80002100:	11c50513          	addi	a0,a0,284 # 80008218 <digits+0x1c0>
    80002104:	ffffe097          	auipc	ra,0xffffe
    80002108:	4d2080e7          	jalr	1234(ra) # 800005d6 <panic>
    panic("sched locks");
    8000210c:	00006517          	auipc	a0,0x6
    80002110:	11c50513          	addi	a0,a0,284 # 80008228 <digits+0x1d0>
    80002114:	ffffe097          	auipc	ra,0xffffe
    80002118:	4c2080e7          	jalr	1218(ra) # 800005d6 <panic>
    panic("sched running");
    8000211c:	00006517          	auipc	a0,0x6
    80002120:	11c50513          	addi	a0,a0,284 # 80008238 <digits+0x1e0>
    80002124:	ffffe097          	auipc	ra,0xffffe
    80002128:	4b2080e7          	jalr	1202(ra) # 800005d6 <panic>
    panic("sched interruptible");
    8000212c:	00006517          	auipc	a0,0x6
    80002130:	11c50513          	addi	a0,a0,284 # 80008248 <digits+0x1f0>
    80002134:	ffffe097          	auipc	ra,0xffffe
    80002138:	4a2080e7          	jalr	1186(ra) # 800005d6 <panic>

000000008000213c <exit>:
{
    8000213c:	7179                	addi	sp,sp,-48
    8000213e:	f406                	sd	ra,40(sp)
    80002140:	f022                	sd	s0,32(sp)
    80002142:	ec26                	sd	s1,24(sp)
    80002144:	e84a                	sd	s2,16(sp)
    80002146:	e44e                	sd	s3,8(sp)
    80002148:	e052                	sd	s4,0(sp)
    8000214a:	1800                	addi	s0,sp,48
    8000214c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000214e:	00000097          	auipc	ra,0x0
    80002152:	8f4080e7          	jalr	-1804(ra) # 80001a42 <myproc>
    80002156:	89aa                	mv	s3,a0
  if(p == initproc)
    80002158:	00007797          	auipc	a5,0x7
    8000215c:	ec07b783          	ld	a5,-320(a5) # 80009018 <initproc>
    80002160:	0d050493          	addi	s1,a0,208
    80002164:	15050913          	addi	s2,a0,336
    80002168:	02a79363          	bne	a5,a0,8000218e <exit+0x52>
    panic("init exiting");
    8000216c:	00006517          	auipc	a0,0x6
    80002170:	0f450513          	addi	a0,a0,244 # 80008260 <digits+0x208>
    80002174:	ffffe097          	auipc	ra,0xffffe
    80002178:	462080e7          	jalr	1122(ra) # 800005d6 <panic>
      fileclose(f);
    8000217c:	00002097          	auipc	ra,0x2
    80002180:	4ae080e7          	jalr	1198(ra) # 8000462a <fileclose>
      p->ofile[fd] = 0;
    80002184:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002188:	04a1                	addi	s1,s1,8
    8000218a:	01248563          	beq	s1,s2,80002194 <exit+0x58>
    if(p->ofile[fd]){
    8000218e:	6088                	ld	a0,0(s1)
    80002190:	f575                	bnez	a0,8000217c <exit+0x40>
    80002192:	bfdd                	j	80002188 <exit+0x4c>
  begin_op();
    80002194:	00002097          	auipc	ra,0x2
    80002198:	fc4080e7          	jalr	-60(ra) # 80004158 <begin_op>
  iput(p->cwd);
    8000219c:	1509b503          	ld	a0,336(s3)
    800021a0:	00001097          	auipc	ra,0x1
    800021a4:	7b6080e7          	jalr	1974(ra) # 80003956 <iput>
  end_op();
    800021a8:	00002097          	auipc	ra,0x2
    800021ac:	030080e7          	jalr	48(ra) # 800041d8 <end_op>
  p->cwd = 0;
    800021b0:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800021b4:	00007497          	auipc	s1,0x7
    800021b8:	e6448493          	addi	s1,s1,-412 # 80009018 <initproc>
    800021bc:	6088                	ld	a0,0(s1)
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	ab6080e7          	jalr	-1354(ra) # 80000c74 <acquire>
  wakeup1(initproc);
    800021c6:	6088                	ld	a0,0(s1)
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	73a080e7          	jalr	1850(ra) # 80001902 <wakeup1>
  release(&initproc->lock);
    800021d0:	6088                	ld	a0,0(s1)
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	b56080e7          	jalr	-1194(ra) # 80000d28 <release>
  acquire(&p->lock);
    800021da:	854e                	mv	a0,s3
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	a98080e7          	jalr	-1384(ra) # 80000c74 <acquire>
  struct proc *original_parent = p->parent;
    800021e4:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021e8:	854e                	mv	a0,s3
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	b3e080e7          	jalr	-1218(ra) # 80000d28 <release>
  acquire(&original_parent->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	a80080e7          	jalr	-1408(ra) # 80000c74 <acquire>
  acquire(&p->lock);
    800021fc:	854e                	mv	a0,s3
    800021fe:	fffff097          	auipc	ra,0xfffff
    80002202:	a76080e7          	jalr	-1418(ra) # 80000c74 <acquire>
  reparent(p);
    80002206:	854e                	mv	a0,s3
    80002208:	00000097          	auipc	ra,0x0
    8000220c:	d38080e7          	jalr	-712(ra) # 80001f40 <reparent>
  wakeup1(original_parent);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	6f0080e7          	jalr	1776(ra) # 80001902 <wakeup1>
  p->xstate = status;
    8000221a:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    8000221e:	4791                	li	a5,4
    80002220:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002224:	8526                	mv	a0,s1
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	b02080e7          	jalr	-1278(ra) # 80000d28 <release>
  sched();
    8000222e:	00000097          	auipc	ra,0x0
    80002232:	e38080e7          	jalr	-456(ra) # 80002066 <sched>
  panic("zombie exit");
    80002236:	00006517          	auipc	a0,0x6
    8000223a:	03a50513          	addi	a0,a0,58 # 80008270 <digits+0x218>
    8000223e:	ffffe097          	auipc	ra,0xffffe
    80002242:	398080e7          	jalr	920(ra) # 800005d6 <panic>

0000000080002246 <yield>:
{
    80002246:	1101                	addi	sp,sp,-32
    80002248:	ec06                	sd	ra,24(sp)
    8000224a:	e822                	sd	s0,16(sp)
    8000224c:	e426                	sd	s1,8(sp)
    8000224e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	7f2080e7          	jalr	2034(ra) # 80001a42 <myproc>
    80002258:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	a1a080e7          	jalr	-1510(ra) # 80000c74 <acquire>
  p->state = RUNNABLE;
    80002262:	4789                	li	a5,2
    80002264:	cc9c                	sw	a5,24(s1)
  sched();
    80002266:	00000097          	auipc	ra,0x0
    8000226a:	e00080e7          	jalr	-512(ra) # 80002066 <sched>
  release(&p->lock);
    8000226e:	8526                	mv	a0,s1
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	ab8080e7          	jalr	-1352(ra) # 80000d28 <release>
}
    80002278:	60e2                	ld	ra,24(sp)
    8000227a:	6442                	ld	s0,16(sp)
    8000227c:	64a2                	ld	s1,8(sp)
    8000227e:	6105                	addi	sp,sp,32
    80002280:	8082                	ret

0000000080002282 <sleep>:
{
    80002282:	7179                	addi	sp,sp,-48
    80002284:	f406                	sd	ra,40(sp)
    80002286:	f022                	sd	s0,32(sp)
    80002288:	ec26                	sd	s1,24(sp)
    8000228a:	e84a                	sd	s2,16(sp)
    8000228c:	e44e                	sd	s3,8(sp)
    8000228e:	1800                	addi	s0,sp,48
    80002290:	89aa                	mv	s3,a0
    80002292:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	7ae080e7          	jalr	1966(ra) # 80001a42 <myproc>
    8000229c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000229e:	05250663          	beq	a0,s2,800022ea <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	9d2080e7          	jalr	-1582(ra) # 80000c74 <acquire>
    release(lk);
    800022aa:	854a                	mv	a0,s2
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	a7c080e7          	jalr	-1412(ra) # 80000d28 <release>
  p->chan = chan;
    800022b4:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800022b8:	4785                	li	a5,1
    800022ba:	cc9c                	sw	a5,24(s1)
  sched();
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	daa080e7          	jalr	-598(ra) # 80002066 <sched>
  p->chan = 0;
    800022c4:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800022c8:	8526                	mv	a0,s1
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	a5e080e7          	jalr	-1442(ra) # 80000d28 <release>
    acquire(lk);
    800022d2:	854a                	mv	a0,s2
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	9a0080e7          	jalr	-1632(ra) # 80000c74 <acquire>
}
    800022dc:	70a2                	ld	ra,40(sp)
    800022de:	7402                	ld	s0,32(sp)
    800022e0:	64e2                	ld	s1,24(sp)
    800022e2:	6942                	ld	s2,16(sp)
    800022e4:	69a2                	ld	s3,8(sp)
    800022e6:	6145                	addi	sp,sp,48
    800022e8:	8082                	ret
  p->chan = chan;
    800022ea:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022ee:	4785                	li	a5,1
    800022f0:	cd1c                	sw	a5,24(a0)
  sched();
    800022f2:	00000097          	auipc	ra,0x0
    800022f6:	d74080e7          	jalr	-652(ra) # 80002066 <sched>
  p->chan = 0;
    800022fa:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022fe:	bff9                	j	800022dc <sleep+0x5a>

0000000080002300 <wait>:
{
    80002300:	715d                	addi	sp,sp,-80
    80002302:	e486                	sd	ra,72(sp)
    80002304:	e0a2                	sd	s0,64(sp)
    80002306:	fc26                	sd	s1,56(sp)
    80002308:	f84a                	sd	s2,48(sp)
    8000230a:	f44e                	sd	s3,40(sp)
    8000230c:	f052                	sd	s4,32(sp)
    8000230e:	ec56                	sd	s5,24(sp)
    80002310:	e85a                	sd	s6,16(sp)
    80002312:	e45e                	sd	s7,8(sp)
    80002314:	e062                	sd	s8,0(sp)
    80002316:	0880                	addi	s0,sp,80
    80002318:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	728080e7          	jalr	1832(ra) # 80001a42 <myproc>
    80002322:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002324:	8c2a                	mv	s8,a0
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	94e080e7          	jalr	-1714(ra) # 80000c74 <acquire>
    havekids = 0;
    8000232e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002330:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002332:	00016997          	auipc	s3,0x16
    80002336:	c3698993          	addi	s3,s3,-970 # 80017f68 <tickslock>
        havekids = 1;
    8000233a:	4a85                	li	s5,1
    havekids = 0;
    8000233c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000233e:	00010497          	auipc	s1,0x10
    80002342:	a2a48493          	addi	s1,s1,-1494 # 80011d68 <proc>
    80002346:	a08d                	j	800023a8 <wait+0xa8>
          pid = np->pid;
    80002348:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000234c:	000b0e63          	beqz	s6,80002368 <wait+0x68>
    80002350:	4691                	li	a3,4
    80002352:	03448613          	addi	a2,s1,52
    80002356:	85da                	mv	a1,s6
    80002358:	05093503          	ld	a0,80(s2)
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	3da080e7          	jalr	986(ra) # 80001736 <copyout>
    80002364:	02054263          	bltz	a0,80002388 <wait+0x88>
          freeproc(np);
    80002368:	8526                	mv	a0,s1
    8000236a:	00000097          	auipc	ra,0x0
    8000236e:	88a080e7          	jalr	-1910(ra) # 80001bf4 <freeproc>
          release(&np->lock);
    80002372:	8526                	mv	a0,s1
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	9b4080e7          	jalr	-1612(ra) # 80000d28 <release>
          release(&p->lock);
    8000237c:	854a                	mv	a0,s2
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	9aa080e7          	jalr	-1622(ra) # 80000d28 <release>
          return pid;
    80002386:	a8a9                	j	800023e0 <wait+0xe0>
            release(&np->lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	99e080e7          	jalr	-1634(ra) # 80000d28 <release>
            release(&p->lock);
    80002392:	854a                	mv	a0,s2
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	994080e7          	jalr	-1644(ra) # 80000d28 <release>
            return -1;
    8000239c:	59fd                	li	s3,-1
    8000239e:	a089                	j	800023e0 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800023a0:	18848493          	addi	s1,s1,392
    800023a4:	03348463          	beq	s1,s3,800023cc <wait+0xcc>
      if(np->parent == p){
    800023a8:	709c                	ld	a5,32(s1)
    800023aa:	ff279be3          	bne	a5,s2,800023a0 <wait+0xa0>
        acquire(&np->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8c4080e7          	jalr	-1852(ra) # 80000c74 <acquire>
        if(np->state == ZOMBIE){
    800023b8:	4c9c                	lw	a5,24(s1)
    800023ba:	f94787e3          	beq	a5,s4,80002348 <wait+0x48>
        release(&np->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	968080e7          	jalr	-1688(ra) # 80000d28 <release>
        havekids = 1;
    800023c8:	8756                	mv	a4,s5
    800023ca:	bfd9                	j	800023a0 <wait+0xa0>
    if(!havekids || p->killed){
    800023cc:	c701                	beqz	a4,800023d4 <wait+0xd4>
    800023ce:	03092783          	lw	a5,48(s2)
    800023d2:	c785                	beqz	a5,800023fa <wait+0xfa>
      release(&p->lock);
    800023d4:	854a                	mv	a0,s2
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	952080e7          	jalr	-1710(ra) # 80000d28 <release>
      return -1;
    800023de:	59fd                	li	s3,-1
}
    800023e0:	854e                	mv	a0,s3
    800023e2:	60a6                	ld	ra,72(sp)
    800023e4:	6406                	ld	s0,64(sp)
    800023e6:	74e2                	ld	s1,56(sp)
    800023e8:	7942                	ld	s2,48(sp)
    800023ea:	79a2                	ld	s3,40(sp)
    800023ec:	7a02                	ld	s4,32(sp)
    800023ee:	6ae2                	ld	s5,24(sp)
    800023f0:	6b42                	ld	s6,16(sp)
    800023f2:	6ba2                	ld	s7,8(sp)
    800023f4:	6c02                	ld	s8,0(sp)
    800023f6:	6161                	addi	sp,sp,80
    800023f8:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023fa:	85e2                	mv	a1,s8
    800023fc:	854a                	mv	a0,s2
    800023fe:	00000097          	auipc	ra,0x0
    80002402:	e84080e7          	jalr	-380(ra) # 80002282 <sleep>
    havekids = 0;
    80002406:	bf1d                	j	8000233c <wait+0x3c>

0000000080002408 <wakeup>:
{
    80002408:	7139                	addi	sp,sp,-64
    8000240a:	fc06                	sd	ra,56(sp)
    8000240c:	f822                	sd	s0,48(sp)
    8000240e:	f426                	sd	s1,40(sp)
    80002410:	f04a                	sd	s2,32(sp)
    80002412:	ec4e                	sd	s3,24(sp)
    80002414:	e852                	sd	s4,16(sp)
    80002416:	e456                	sd	s5,8(sp)
    80002418:	0080                	addi	s0,sp,64
    8000241a:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000241c:	00010497          	auipc	s1,0x10
    80002420:	94c48493          	addi	s1,s1,-1716 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002424:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002426:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002428:	00016917          	auipc	s2,0x16
    8000242c:	b4090913          	addi	s2,s2,-1216 # 80017f68 <tickslock>
    80002430:	a821                	j	80002448 <wakeup+0x40>
      p->state = RUNNABLE;
    80002432:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    80002436:	8526                	mv	a0,s1
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	8f0080e7          	jalr	-1808(ra) # 80000d28 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002440:	18848493          	addi	s1,s1,392
    80002444:	01248e63          	beq	s1,s2,80002460 <wakeup+0x58>
    acquire(&p->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	82a080e7          	jalr	-2006(ra) # 80000c74 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002452:	4c9c                	lw	a5,24(s1)
    80002454:	ff3791e3          	bne	a5,s3,80002436 <wakeup+0x2e>
    80002458:	749c                	ld	a5,40(s1)
    8000245a:	fd479ee3          	bne	a5,s4,80002436 <wakeup+0x2e>
    8000245e:	bfd1                	j	80002432 <wakeup+0x2a>
}
    80002460:	70e2                	ld	ra,56(sp)
    80002462:	7442                	ld	s0,48(sp)
    80002464:	74a2                	ld	s1,40(sp)
    80002466:	7902                	ld	s2,32(sp)
    80002468:	69e2                	ld	s3,24(sp)
    8000246a:	6a42                	ld	s4,16(sp)
    8000246c:	6aa2                	ld	s5,8(sp)
    8000246e:	6121                	addi	sp,sp,64
    80002470:	8082                	ret

0000000080002472 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002472:	7179                	addi	sp,sp,-48
    80002474:	f406                	sd	ra,40(sp)
    80002476:	f022                	sd	s0,32(sp)
    80002478:	ec26                	sd	s1,24(sp)
    8000247a:	e84a                	sd	s2,16(sp)
    8000247c:	e44e                	sd	s3,8(sp)
    8000247e:	1800                	addi	s0,sp,48
    80002480:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002482:	00010497          	auipc	s1,0x10
    80002486:	8e648493          	addi	s1,s1,-1818 # 80011d68 <proc>
    8000248a:	00016997          	auipc	s3,0x16
    8000248e:	ade98993          	addi	s3,s3,-1314 # 80017f68 <tickslock>
    acquire(&p->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7e0080e7          	jalr	2016(ra) # 80000c74 <acquire>
    if(p->pid == pid){
    8000249c:	5c9c                	lw	a5,56(s1)
    8000249e:	01278d63          	beq	a5,s2,800024b8 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024a2:	8526                	mv	a0,s1
    800024a4:	fffff097          	auipc	ra,0xfffff
    800024a8:	884080e7          	jalr	-1916(ra) # 80000d28 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024ac:	18848493          	addi	s1,s1,392
    800024b0:	ff3491e3          	bne	s1,s3,80002492 <kill+0x20>
  }
  return -1;
    800024b4:	557d                	li	a0,-1
    800024b6:	a829                	j	800024d0 <kill+0x5e>
      p->killed = 1;
    800024b8:	4785                	li	a5,1
    800024ba:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800024bc:	4c98                	lw	a4,24(s1)
    800024be:	4785                	li	a5,1
    800024c0:	00f70f63          	beq	a4,a5,800024de <kill+0x6c>
      release(&p->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	862080e7          	jalr	-1950(ra) # 80000d28 <release>
      return 0;
    800024ce:	4501                	li	a0,0
}
    800024d0:	70a2                	ld	ra,40(sp)
    800024d2:	7402                	ld	s0,32(sp)
    800024d4:	64e2                	ld	s1,24(sp)
    800024d6:	6942                	ld	s2,16(sp)
    800024d8:	69a2                	ld	s3,8(sp)
    800024da:	6145                	addi	sp,sp,48
    800024dc:	8082                	ret
        p->state = RUNNABLE;
    800024de:	4789                	li	a5,2
    800024e0:	cc9c                	sw	a5,24(s1)
    800024e2:	b7cd                	j	800024c4 <kill+0x52>

00000000800024e4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024e4:	7179                	addi	sp,sp,-48
    800024e6:	f406                	sd	ra,40(sp)
    800024e8:	f022                	sd	s0,32(sp)
    800024ea:	ec26                	sd	s1,24(sp)
    800024ec:	e84a                	sd	s2,16(sp)
    800024ee:	e44e                	sd	s3,8(sp)
    800024f0:	e052                	sd	s4,0(sp)
    800024f2:	1800                	addi	s0,sp,48
    800024f4:	84aa                	mv	s1,a0
    800024f6:	892e                	mv	s2,a1
    800024f8:	89b2                	mv	s3,a2
    800024fa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	546080e7          	jalr	1350(ra) # 80001a42 <myproc>
  if(user_dst){
    80002504:	c08d                	beqz	s1,80002526 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002506:	86d2                	mv	a3,s4
    80002508:	864e                	mv	a2,s3
    8000250a:	85ca                	mv	a1,s2
    8000250c:	6928                	ld	a0,80(a0)
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	228080e7          	jalr	552(ra) # 80001736 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002516:	70a2                	ld	ra,40(sp)
    80002518:	7402                	ld	s0,32(sp)
    8000251a:	64e2                	ld	s1,24(sp)
    8000251c:	6942                	ld	s2,16(sp)
    8000251e:	69a2                	ld	s3,8(sp)
    80002520:	6a02                	ld	s4,0(sp)
    80002522:	6145                	addi	sp,sp,48
    80002524:	8082                	ret
    memmove((char *)dst, src, len);
    80002526:	000a061b          	sext.w	a2,s4
    8000252a:	85ce                	mv	a1,s3
    8000252c:	854a                	mv	a0,s2
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	8a2080e7          	jalr	-1886(ra) # 80000dd0 <memmove>
    return 0;
    80002536:	8526                	mv	a0,s1
    80002538:	bff9                	j	80002516 <either_copyout+0x32>

000000008000253a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000253a:	7179                	addi	sp,sp,-48
    8000253c:	f406                	sd	ra,40(sp)
    8000253e:	f022                	sd	s0,32(sp)
    80002540:	ec26                	sd	s1,24(sp)
    80002542:	e84a                	sd	s2,16(sp)
    80002544:	e44e                	sd	s3,8(sp)
    80002546:	e052                	sd	s4,0(sp)
    80002548:	1800                	addi	s0,sp,48
    8000254a:	892a                	mv	s2,a0
    8000254c:	84ae                	mv	s1,a1
    8000254e:	89b2                	mv	s3,a2
    80002550:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002552:	fffff097          	auipc	ra,0xfffff
    80002556:	4f0080e7          	jalr	1264(ra) # 80001a42 <myproc>
  if(user_src){
    8000255a:	c08d                	beqz	s1,8000257c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000255c:	86d2                	mv	a3,s4
    8000255e:	864e                	mv	a2,s3
    80002560:	85ca                	mv	a1,s2
    80002562:	6928                	ld	a0,80(a0)
    80002564:	fffff097          	auipc	ra,0xfffff
    80002568:	25e080e7          	jalr	606(ra) # 800017c2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000256c:	70a2                	ld	ra,40(sp)
    8000256e:	7402                	ld	s0,32(sp)
    80002570:	64e2                	ld	s1,24(sp)
    80002572:	6942                	ld	s2,16(sp)
    80002574:	69a2                	ld	s3,8(sp)
    80002576:	6a02                	ld	s4,0(sp)
    80002578:	6145                	addi	sp,sp,48
    8000257a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000257c:	000a061b          	sext.w	a2,s4
    80002580:	85ce                	mv	a1,s3
    80002582:	854a                	mv	a0,s2
    80002584:	fffff097          	auipc	ra,0xfffff
    80002588:	84c080e7          	jalr	-1972(ra) # 80000dd0 <memmove>
    return 0;
    8000258c:	8526                	mv	a0,s1
    8000258e:	bff9                	j	8000256c <either_copyin+0x32>

0000000080002590 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002590:	715d                	addi	sp,sp,-80
    80002592:	e486                	sd	ra,72(sp)
    80002594:	e0a2                	sd	s0,64(sp)
    80002596:	fc26                	sd	s1,56(sp)
    80002598:	f84a                	sd	s2,48(sp)
    8000259a:	f44e                	sd	s3,40(sp)
    8000259c:	f052                	sd	s4,32(sp)
    8000259e:	ec56                	sd	s5,24(sp)
    800025a0:	e85a                	sd	s6,16(sp)
    800025a2:	e45e                	sd	s7,8(sp)
    800025a4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025a6:	00006517          	auipc	a0,0x6
    800025aa:	b3a50513          	addi	a0,a0,-1222 # 800080e0 <digits+0x88>
    800025ae:	ffffe097          	auipc	ra,0xffffe
    800025b2:	07a080e7          	jalr	122(ra) # 80000628 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025b6:	00010497          	auipc	s1,0x10
    800025ba:	90a48493          	addi	s1,s1,-1782 # 80011ec0 <proc+0x158>
    800025be:	00016917          	auipc	s2,0x16
    800025c2:	b0290913          	addi	s2,s2,-1278 # 800180c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c6:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025c8:	00006997          	auipc	s3,0x6
    800025cc:	cb898993          	addi	s3,s3,-840 # 80008280 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800025d0:	00006a97          	auipc	s5,0x6
    800025d4:	cb8a8a93          	addi	s5,s5,-840 # 80008288 <digits+0x230>
    printf("\n");
    800025d8:	00006a17          	auipc	s4,0x6
    800025dc:	b08a0a13          	addi	s4,s4,-1272 # 800080e0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e0:	00006b97          	auipc	s7,0x6
    800025e4:	ce0b8b93          	addi	s7,s7,-800 # 800082c0 <states.1711>
    800025e8:	a00d                	j	8000260a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025ea:	ee06a583          	lw	a1,-288(a3)
    800025ee:	8556                	mv	a0,s5
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	038080e7          	jalr	56(ra) # 80000628 <printf>
    printf("\n");
    800025f8:	8552                	mv	a0,s4
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	02e080e7          	jalr	46(ra) # 80000628 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002602:	18848493          	addi	s1,s1,392
    80002606:	03248163          	beq	s1,s2,80002628 <procdump+0x98>
    if(p->state == UNUSED)
    8000260a:	86a6                	mv	a3,s1
    8000260c:	ec04a783          	lw	a5,-320(s1)
    80002610:	dbed                	beqz	a5,80002602 <procdump+0x72>
      state = "???";
    80002612:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002614:	fcfb6be3          	bltu	s6,a5,800025ea <procdump+0x5a>
    80002618:	1782                	slli	a5,a5,0x20
    8000261a:	9381                	srli	a5,a5,0x20
    8000261c:	078e                	slli	a5,a5,0x3
    8000261e:	97de                	add	a5,a5,s7
    80002620:	6390                	ld	a2,0(a5)
    80002622:	f661                	bnez	a2,800025ea <procdump+0x5a>
      state = "???";
    80002624:	864e                	mv	a2,s3
    80002626:	b7d1                	j	800025ea <procdump+0x5a>
  }
}
    80002628:	60a6                	ld	ra,72(sp)
    8000262a:	6406                	ld	s0,64(sp)
    8000262c:	74e2                	ld	s1,56(sp)
    8000262e:	7942                	ld	s2,48(sp)
    80002630:	79a2                	ld	s3,40(sp)
    80002632:	7a02                	ld	s4,32(sp)
    80002634:	6ae2                	ld	s5,24(sp)
    80002636:	6b42                	ld	s6,16(sp)
    80002638:	6ba2                	ld	s7,8(sp)
    8000263a:	6161                	addi	sp,sp,80
    8000263c:	8082                	ret

000000008000263e <swtch>:
    8000263e:	00153023          	sd	ra,0(a0)
    80002642:	00253423          	sd	sp,8(a0)
    80002646:	e900                	sd	s0,16(a0)
    80002648:	ed04                	sd	s1,24(a0)
    8000264a:	03253023          	sd	s2,32(a0)
    8000264e:	03353423          	sd	s3,40(a0)
    80002652:	03453823          	sd	s4,48(a0)
    80002656:	03553c23          	sd	s5,56(a0)
    8000265a:	05653023          	sd	s6,64(a0)
    8000265e:	05753423          	sd	s7,72(a0)
    80002662:	05853823          	sd	s8,80(a0)
    80002666:	05953c23          	sd	s9,88(a0)
    8000266a:	07a53023          	sd	s10,96(a0)
    8000266e:	07b53423          	sd	s11,104(a0)
    80002672:	0005b083          	ld	ra,0(a1)
    80002676:	0085b103          	ld	sp,8(a1)
    8000267a:	6980                	ld	s0,16(a1)
    8000267c:	6d84                	ld	s1,24(a1)
    8000267e:	0205b903          	ld	s2,32(a1)
    80002682:	0285b983          	ld	s3,40(a1)
    80002686:	0305ba03          	ld	s4,48(a1)
    8000268a:	0385ba83          	ld	s5,56(a1)
    8000268e:	0405bb03          	ld	s6,64(a1)
    80002692:	0485bb83          	ld	s7,72(a1)
    80002696:	0505bc03          	ld	s8,80(a1)
    8000269a:	0585bc83          	ld	s9,88(a1)
    8000269e:	0605bd03          	ld	s10,96(a1)
    800026a2:	0685bd83          	ld	s11,104(a1)
    800026a6:	8082                	ret

00000000800026a8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026a8:	1141                	addi	sp,sp,-16
    800026aa:	e406                	sd	ra,8(sp)
    800026ac:	e022                	sd	s0,0(sp)
    800026ae:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026b0:	00006597          	auipc	a1,0x6
    800026b4:	c3858593          	addi	a1,a1,-968 # 800082e8 <states.1711+0x28>
    800026b8:	00016517          	auipc	a0,0x16
    800026bc:	8b050513          	addi	a0,a0,-1872 # 80017f68 <tickslock>
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	524080e7          	jalr	1316(ra) # 80000be4 <initlock>
}
    800026c8:	60a2                	ld	ra,8(sp)
    800026ca:	6402                	ld	s0,0(sp)
    800026cc:	0141                	addi	sp,sp,16
    800026ce:	8082                	ret

00000000800026d0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026d0:	1141                	addi	sp,sp,-16
    800026d2:	e422                	sd	s0,8(sp)
    800026d4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026d6:	00003797          	auipc	a5,0x3
    800026da:	5ba78793          	addi	a5,a5,1466 # 80005c90 <kernelvec>
    800026de:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026e2:	6422                	ld	s0,8(sp)
    800026e4:	0141                	addi	sp,sp,16
    800026e6:	8082                	ret

00000000800026e8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026e8:	1141                	addi	sp,sp,-16
    800026ea:	e406                	sd	ra,8(sp)
    800026ec:	e022                	sd	s0,0(sp)
    800026ee:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026f0:	fffff097          	auipc	ra,0xfffff
    800026f4:	352080e7          	jalr	850(ra) # 80001a42 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026f8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026fc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026fe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002702:	00005617          	auipc	a2,0x5
    80002706:	8fe60613          	addi	a2,a2,-1794 # 80007000 <_trampoline>
    8000270a:	00005697          	auipc	a3,0x5
    8000270e:	8f668693          	addi	a3,a3,-1802 # 80007000 <_trampoline>
    80002712:	8e91                	sub	a3,a3,a2
    80002714:	040007b7          	lui	a5,0x4000
    80002718:	17fd                	addi	a5,a5,-1
    8000271a:	07b2                	slli	a5,a5,0xc
    8000271c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000271e:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002722:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002724:	180026f3          	csrr	a3,satp
    80002728:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000272a:	6d38                	ld	a4,88(a0)
    8000272c:	6134                	ld	a3,64(a0)
    8000272e:	6585                	lui	a1,0x1
    80002730:	96ae                	add	a3,a3,a1
    80002732:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002734:	6d38                	ld	a4,88(a0)
    80002736:	00000697          	auipc	a3,0x0
    8000273a:	13868693          	addi	a3,a3,312 # 8000286e <usertrap>
    8000273e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002740:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002742:	8692                	mv	a3,tp
    80002744:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002746:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000274a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000274e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002752:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002756:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002758:	6f18                	ld	a4,24(a4)
    8000275a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000275e:	692c                	ld	a1,80(a0)
    80002760:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002762:	00005717          	auipc	a4,0x5
    80002766:	92e70713          	addi	a4,a4,-1746 # 80007090 <userret>
    8000276a:	8f11                	sub	a4,a4,a2
    8000276c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000276e:	577d                	li	a4,-1
    80002770:	177e                	slli	a4,a4,0x3f
    80002772:	8dd9                	or	a1,a1,a4
    80002774:	02000537          	lui	a0,0x2000
    80002778:	157d                	addi	a0,a0,-1
    8000277a:	0536                	slli	a0,a0,0xd
    8000277c:	9782                	jalr	a5
}
    8000277e:	60a2                	ld	ra,8(sp)
    80002780:	6402                	ld	s0,0(sp)
    80002782:	0141                	addi	sp,sp,16
    80002784:	8082                	ret

0000000080002786 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002786:	1101                	addi	sp,sp,-32
    80002788:	ec06                	sd	ra,24(sp)
    8000278a:	e822                	sd	s0,16(sp)
    8000278c:	e426                	sd	s1,8(sp)
    8000278e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002790:	00015497          	auipc	s1,0x15
    80002794:	7d848493          	addi	s1,s1,2008 # 80017f68 <tickslock>
    80002798:	8526                	mv	a0,s1
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	4da080e7          	jalr	1242(ra) # 80000c74 <acquire>
  ticks++;
    800027a2:	00007517          	auipc	a0,0x7
    800027a6:	87e50513          	addi	a0,a0,-1922 # 80009020 <ticks>
    800027aa:	411c                	lw	a5,0(a0)
    800027ac:	2785                	addiw	a5,a5,1
    800027ae:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027b0:	00000097          	auipc	ra,0x0
    800027b4:	c58080e7          	jalr	-936(ra) # 80002408 <wakeup>
  release(&tickslock);
    800027b8:	8526                	mv	a0,s1
    800027ba:	ffffe097          	auipc	ra,0xffffe
    800027be:	56e080e7          	jalr	1390(ra) # 80000d28 <release>
}
    800027c2:	60e2                	ld	ra,24(sp)
    800027c4:	6442                	ld	s0,16(sp)
    800027c6:	64a2                	ld	s1,8(sp)
    800027c8:	6105                	addi	sp,sp,32
    800027ca:	8082                	ret

00000000800027cc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027cc:	1101                	addi	sp,sp,-32
    800027ce:	ec06                	sd	ra,24(sp)
    800027d0:	e822                	sd	s0,16(sp)
    800027d2:	e426                	sd	s1,8(sp)
    800027d4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027d6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027da:	00074d63          	bltz	a4,800027f4 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027de:	57fd                	li	a5,-1
    800027e0:	17fe                	slli	a5,a5,0x3f
    800027e2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027e4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027e6:	06f70363          	beq	a4,a5,8000284c <devintr+0x80>
  }
}
    800027ea:	60e2                	ld	ra,24(sp)
    800027ec:	6442                	ld	s0,16(sp)
    800027ee:	64a2                	ld	s1,8(sp)
    800027f0:	6105                	addi	sp,sp,32
    800027f2:	8082                	ret
     (scause & 0xff) == 9){
    800027f4:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027f8:	46a5                	li	a3,9
    800027fa:	fed792e3          	bne	a5,a3,800027de <devintr+0x12>
    int irq = plic_claim();
    800027fe:	00003097          	auipc	ra,0x3
    80002802:	59a080e7          	jalr	1434(ra) # 80005d98 <plic_claim>
    80002806:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002808:	47a9                	li	a5,10
    8000280a:	02f50763          	beq	a0,a5,80002838 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000280e:	4785                	li	a5,1
    80002810:	02f50963          	beq	a0,a5,80002842 <devintr+0x76>
    return 1;
    80002814:	4505                	li	a0,1
    } else if(irq){
    80002816:	d8f1                	beqz	s1,800027ea <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002818:	85a6                	mv	a1,s1
    8000281a:	00006517          	auipc	a0,0x6
    8000281e:	ad650513          	addi	a0,a0,-1322 # 800082f0 <states.1711+0x30>
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	e06080e7          	jalr	-506(ra) # 80000628 <printf>
      plic_complete(irq);
    8000282a:	8526                	mv	a0,s1
    8000282c:	00003097          	auipc	ra,0x3
    80002830:	590080e7          	jalr	1424(ra) # 80005dbc <plic_complete>
    return 1;
    80002834:	4505                	li	a0,1
    80002836:	bf55                	j	800027ea <devintr+0x1e>
      uartintr();
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	200080e7          	jalr	512(ra) # 80000a38 <uartintr>
    80002840:	b7ed                	j	8000282a <devintr+0x5e>
      virtio_disk_intr();
    80002842:	00004097          	auipc	ra,0x4
    80002846:	a14080e7          	jalr	-1516(ra) # 80006256 <virtio_disk_intr>
    8000284a:	b7c5                	j	8000282a <devintr+0x5e>
    if(cpuid() == 0){
    8000284c:	fffff097          	auipc	ra,0xfffff
    80002850:	1ca080e7          	jalr	458(ra) # 80001a16 <cpuid>
    80002854:	c901                	beqz	a0,80002864 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002856:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000285a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000285c:	14479073          	csrw	sip,a5
    return 2;
    80002860:	4509                	li	a0,2
    80002862:	b761                	j	800027ea <devintr+0x1e>
      clockintr();
    80002864:	00000097          	auipc	ra,0x0
    80002868:	f22080e7          	jalr	-222(ra) # 80002786 <clockintr>
    8000286c:	b7ed                	j	80002856 <devintr+0x8a>

000000008000286e <usertrap>:
{
    8000286e:	1101                	addi	sp,sp,-32
    80002870:	ec06                	sd	ra,24(sp)
    80002872:	e822                	sd	s0,16(sp)
    80002874:	e426                	sd	s1,8(sp)
    80002876:	e04a                	sd	s2,0(sp)
    80002878:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000287a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000287e:	1007f793          	andi	a5,a5,256
    80002882:	e3ad                	bnez	a5,800028e4 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002884:	00003797          	auipc	a5,0x3
    80002888:	40c78793          	addi	a5,a5,1036 # 80005c90 <kernelvec>
    8000288c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002890:	fffff097          	auipc	ra,0xfffff
    80002894:	1b2080e7          	jalr	434(ra) # 80001a42 <myproc>
    80002898:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000289a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000289c:	14102773          	csrr	a4,sepc
    800028a0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028a2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028a6:	47a1                	li	a5,8
    800028a8:	04f71c63          	bne	a4,a5,80002900 <usertrap+0x92>
    if(p->killed)
    800028ac:	591c                	lw	a5,48(a0)
    800028ae:	e3b9                	bnez	a5,800028f4 <usertrap+0x86>
    p->trapframe->epc += 4;
    800028b0:	6cb8                	ld	a4,88(s1)
    800028b2:	6f1c                	ld	a5,24(a4)
    800028b4:	0791                	addi	a5,a5,4
    800028b6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028bc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028c0:	10079073          	csrw	sstatus,a5
    syscall();
    800028c4:	00000097          	auipc	ra,0x0
    800028c8:	330080e7          	jalr	816(ra) # 80002bf4 <syscall>
  if(p->killed)
    800028cc:	589c                	lw	a5,48(s1)
    800028ce:	e7cd                	bnez	a5,80002978 <usertrap+0x10a>
  usertrapret();
    800028d0:	00000097          	auipc	ra,0x0
    800028d4:	e18080e7          	jalr	-488(ra) # 800026e8 <usertrapret>
}
    800028d8:	60e2                	ld	ra,24(sp)
    800028da:	6442                	ld	s0,16(sp)
    800028dc:	64a2                	ld	s1,8(sp)
    800028de:	6902                	ld	s2,0(sp)
    800028e0:	6105                	addi	sp,sp,32
    800028e2:	8082                	ret
    panic("usertrap: not from user mode");
    800028e4:	00006517          	auipc	a0,0x6
    800028e8:	a2c50513          	addi	a0,a0,-1492 # 80008310 <states.1711+0x50>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	cea080e7          	jalr	-790(ra) # 800005d6 <panic>
      exit(-1);
    800028f4:	557d                	li	a0,-1
    800028f6:	00000097          	auipc	ra,0x0
    800028fa:	846080e7          	jalr	-1978(ra) # 8000213c <exit>
    800028fe:	bf4d                	j	800028b0 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002900:	00000097          	auipc	ra,0x0
    80002904:	ecc080e7          	jalr	-308(ra) # 800027cc <devintr>
    80002908:	892a                	mv	s2,a0
    8000290a:	c501                	beqz	a0,80002912 <usertrap+0xa4>
  if(p->killed)
    8000290c:	589c                	lw	a5,48(s1)
    8000290e:	c3a1                	beqz	a5,8000294e <usertrap+0xe0>
    80002910:	a815                	j	80002944 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002912:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002916:	5c90                	lw	a2,56(s1)
    80002918:	00006517          	auipc	a0,0x6
    8000291c:	a1850513          	addi	a0,a0,-1512 # 80008330 <states.1711+0x70>
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	d08080e7          	jalr	-760(ra) # 80000628 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002928:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000292c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002930:	00006517          	auipc	a0,0x6
    80002934:	a3050513          	addi	a0,a0,-1488 # 80008360 <states.1711+0xa0>
    80002938:	ffffe097          	auipc	ra,0xffffe
    8000293c:	cf0080e7          	jalr	-784(ra) # 80000628 <printf>
    p->killed = 1;
    80002940:	4785                	li	a5,1
    80002942:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002944:	557d                	li	a0,-1
    80002946:	fffff097          	auipc	ra,0xfffff
    8000294a:	7f6080e7          	jalr	2038(ra) # 8000213c <exit>
  if(which_dev == 2) {
    8000294e:	4789                	li	a5,2
    80002950:	f8f910e3          	bne	s2,a5,800028d0 <usertrap+0x62>
    if(p->interval <= 0)
    80002954:	1684a703          	lw	a4,360(s1)
    80002958:	00e05b63          	blez	a4,8000296e <usertrap+0x100>
    p->ticks++;
    8000295c:	1784a783          	lw	a5,376(s1)
    80002960:	2785                	addiw	a5,a5,1
    80002962:	0007869b          	sext.w	a3,a5
    80002966:	16f4ac23          	sw	a5,376(s1)
    if(p->ticks == p->interval) {
    8000296a:	00d70963          	beq	a4,a3,8000297c <usertrap+0x10e>
    yield();
    8000296e:	00000097          	auipc	ra,0x0
    80002972:	8d8080e7          	jalr	-1832(ra) # 80002246 <yield>
    80002976:	bfa9                	j	800028d0 <usertrap+0x62>
  int which_dev = 0;
    80002978:	4901                	li	s2,0
    8000297a:	b7e9                	j	80002944 <usertrap+0xd6>
      *p->trapframe2 = *p->trapframe;
    8000297c:	6cb4                	ld	a3,88(s1)
    8000297e:	87b6                	mv	a5,a3
    80002980:	1804b703          	ld	a4,384(s1)
    80002984:	12068693          	addi	a3,a3,288
    80002988:	0007b803          	ld	a6,0(a5)
    8000298c:	6788                	ld	a0,8(a5)
    8000298e:	6b8c                	ld	a1,16(a5)
    80002990:	6f90                	ld	a2,24(a5)
    80002992:	01073023          	sd	a6,0(a4)
    80002996:	e708                	sd	a0,8(a4)
    80002998:	eb0c                	sd	a1,16(a4)
    8000299a:	ef10                	sd	a2,24(a4)
    8000299c:	02078793          	addi	a5,a5,32
    800029a0:	02070713          	addi	a4,a4,32
    800029a4:	fed792e3          	bne	a5,a3,80002988 <usertrap+0x11a>
      p->trapframe->epc = p->handler;
    800029a8:	6cbc                	ld	a5,88(s1)
    800029aa:	1704b703          	ld	a4,368(s1)
    800029ae:	ef98                	sd	a4,24(a5)
    800029b0:	bf7d                	j	8000296e <usertrap+0x100>

00000000800029b2 <kerneltrap>:
{
    800029b2:	7179                	addi	sp,sp,-48
    800029b4:	f406                	sd	ra,40(sp)
    800029b6:	f022                	sd	s0,32(sp)
    800029b8:	ec26                	sd	s1,24(sp)
    800029ba:	e84a                	sd	s2,16(sp)
    800029bc:	e44e                	sd	s3,8(sp)
    800029be:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029c0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029c8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029cc:	1004f793          	andi	a5,s1,256
    800029d0:	cb85                	beqz	a5,80002a00 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029d6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029d8:	ef85                	bnez	a5,80002a10 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029da:	00000097          	auipc	ra,0x0
    800029de:	df2080e7          	jalr	-526(ra) # 800027cc <devintr>
    800029e2:	cd1d                	beqz	a0,80002a20 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029e4:	4789                	li	a5,2
    800029e6:	06f50a63          	beq	a0,a5,80002a5a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029ea:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ee:	10049073          	csrw	sstatus,s1
}
    800029f2:	70a2                	ld	ra,40(sp)
    800029f4:	7402                	ld	s0,32(sp)
    800029f6:	64e2                	ld	s1,24(sp)
    800029f8:	6942                	ld	s2,16(sp)
    800029fa:	69a2                	ld	s3,8(sp)
    800029fc:	6145                	addi	sp,sp,48
    800029fe:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a00:	00006517          	auipc	a0,0x6
    80002a04:	98050513          	addi	a0,a0,-1664 # 80008380 <states.1711+0xc0>
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	bce080e7          	jalr	-1074(ra) # 800005d6 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a10:	00006517          	auipc	a0,0x6
    80002a14:	99850513          	addi	a0,a0,-1640 # 800083a8 <states.1711+0xe8>
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	bbe080e7          	jalr	-1090(ra) # 800005d6 <panic>
    printf("scause %p\n", scause);
    80002a20:	85ce                	mv	a1,s3
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	9a650513          	addi	a0,a0,-1626 # 800083c8 <states.1711+0x108>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	bfe080e7          	jalr	-1026(ra) # 80000628 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a32:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a36:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a3a:	00006517          	auipc	a0,0x6
    80002a3e:	99e50513          	addi	a0,a0,-1634 # 800083d8 <states.1711+0x118>
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	be6080e7          	jalr	-1050(ra) # 80000628 <printf>
    panic("kerneltrap");
    80002a4a:	00006517          	auipc	a0,0x6
    80002a4e:	9a650513          	addi	a0,a0,-1626 # 800083f0 <states.1711+0x130>
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	b84080e7          	jalr	-1148(ra) # 800005d6 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	fe8080e7          	jalr	-24(ra) # 80001a42 <myproc>
    80002a62:	d541                	beqz	a0,800029ea <kerneltrap+0x38>
    80002a64:	fffff097          	auipc	ra,0xfffff
    80002a68:	fde080e7          	jalr	-34(ra) # 80001a42 <myproc>
    80002a6c:	4d18                	lw	a4,24(a0)
    80002a6e:	478d                	li	a5,3
    80002a70:	f6f71de3          	bne	a4,a5,800029ea <kerneltrap+0x38>
    yield();
    80002a74:	fffff097          	auipc	ra,0xfffff
    80002a78:	7d2080e7          	jalr	2002(ra) # 80002246 <yield>
    80002a7c:	b7bd                	j	800029ea <kerneltrap+0x38>

0000000080002a7e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	e426                	sd	s1,8(sp)
    80002a86:	1000                	addi	s0,sp,32
    80002a88:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a8a:	fffff097          	auipc	ra,0xfffff
    80002a8e:	fb8080e7          	jalr	-72(ra) # 80001a42 <myproc>
  switch (n) {
    80002a92:	4795                	li	a5,5
    80002a94:	0497e163          	bltu	a5,s1,80002ad6 <argraw+0x58>
    80002a98:	048a                	slli	s1,s1,0x2
    80002a9a:	00006717          	auipc	a4,0x6
    80002a9e:	98e70713          	addi	a4,a4,-1650 # 80008428 <states.1711+0x168>
    80002aa2:	94ba                	add	s1,s1,a4
    80002aa4:	409c                	lw	a5,0(s1)
    80002aa6:	97ba                	add	a5,a5,a4
    80002aa8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002aaa:	6d3c                	ld	a5,88(a0)
    80002aac:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002aae:	60e2                	ld	ra,24(sp)
    80002ab0:	6442                	ld	s0,16(sp)
    80002ab2:	64a2                	ld	s1,8(sp)
    80002ab4:	6105                	addi	sp,sp,32
    80002ab6:	8082                	ret
    return p->trapframe->a1;
    80002ab8:	6d3c                	ld	a5,88(a0)
    80002aba:	7fa8                	ld	a0,120(a5)
    80002abc:	bfcd                	j	80002aae <argraw+0x30>
    return p->trapframe->a2;
    80002abe:	6d3c                	ld	a5,88(a0)
    80002ac0:	63c8                	ld	a0,128(a5)
    80002ac2:	b7f5                	j	80002aae <argraw+0x30>
    return p->trapframe->a3;
    80002ac4:	6d3c                	ld	a5,88(a0)
    80002ac6:	67c8                	ld	a0,136(a5)
    80002ac8:	b7dd                	j	80002aae <argraw+0x30>
    return p->trapframe->a4;
    80002aca:	6d3c                	ld	a5,88(a0)
    80002acc:	6bc8                	ld	a0,144(a5)
    80002ace:	b7c5                	j	80002aae <argraw+0x30>
    return p->trapframe->a5;
    80002ad0:	6d3c                	ld	a5,88(a0)
    80002ad2:	6fc8                	ld	a0,152(a5)
    80002ad4:	bfe9                	j	80002aae <argraw+0x30>
  panic("argraw");
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	92a50513          	addi	a0,a0,-1750 # 80008400 <states.1711+0x140>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	af8080e7          	jalr	-1288(ra) # 800005d6 <panic>

0000000080002ae6 <fetchaddr>:
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	e426                	sd	s1,8(sp)
    80002aee:	e04a                	sd	s2,0(sp)
    80002af0:	1000                	addi	s0,sp,32
    80002af2:	84aa                	mv	s1,a0
    80002af4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	f4c080e7          	jalr	-180(ra) # 80001a42 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002afe:	653c                	ld	a5,72(a0)
    80002b00:	02f4f863          	bgeu	s1,a5,80002b30 <fetchaddr+0x4a>
    80002b04:	00848713          	addi	a4,s1,8
    80002b08:	02e7e663          	bltu	a5,a4,80002b34 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b0c:	46a1                	li	a3,8
    80002b0e:	8626                	mv	a2,s1
    80002b10:	85ca                	mv	a1,s2
    80002b12:	6928                	ld	a0,80(a0)
    80002b14:	fffff097          	auipc	ra,0xfffff
    80002b18:	cae080e7          	jalr	-850(ra) # 800017c2 <copyin>
    80002b1c:	00a03533          	snez	a0,a0
    80002b20:	40a00533          	neg	a0,a0
}
    80002b24:	60e2                	ld	ra,24(sp)
    80002b26:	6442                	ld	s0,16(sp)
    80002b28:	64a2                	ld	s1,8(sp)
    80002b2a:	6902                	ld	s2,0(sp)
    80002b2c:	6105                	addi	sp,sp,32
    80002b2e:	8082                	ret
    return -1;
    80002b30:	557d                	li	a0,-1
    80002b32:	bfcd                	j	80002b24 <fetchaddr+0x3e>
    80002b34:	557d                	li	a0,-1
    80002b36:	b7fd                	j	80002b24 <fetchaddr+0x3e>

0000000080002b38 <fetchstr>:
{
    80002b38:	7179                	addi	sp,sp,-48
    80002b3a:	f406                	sd	ra,40(sp)
    80002b3c:	f022                	sd	s0,32(sp)
    80002b3e:	ec26                	sd	s1,24(sp)
    80002b40:	e84a                	sd	s2,16(sp)
    80002b42:	e44e                	sd	s3,8(sp)
    80002b44:	1800                	addi	s0,sp,48
    80002b46:	892a                	mv	s2,a0
    80002b48:	84ae                	mv	s1,a1
    80002b4a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	ef6080e7          	jalr	-266(ra) # 80001a42 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b54:	86ce                	mv	a3,s3
    80002b56:	864a                	mv	a2,s2
    80002b58:	85a6                	mv	a1,s1
    80002b5a:	6928                	ld	a0,80(a0)
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	cf2080e7          	jalr	-782(ra) # 8000184e <copyinstr>
  if(err < 0)
    80002b64:	00054763          	bltz	a0,80002b72 <fetchstr+0x3a>
  return strlen(buf);
    80002b68:	8526                	mv	a0,s1
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	38e080e7          	jalr	910(ra) # 80000ef8 <strlen>
}
    80002b72:	70a2                	ld	ra,40(sp)
    80002b74:	7402                	ld	s0,32(sp)
    80002b76:	64e2                	ld	s1,24(sp)
    80002b78:	6942                	ld	s2,16(sp)
    80002b7a:	69a2                	ld	s3,8(sp)
    80002b7c:	6145                	addi	sp,sp,48
    80002b7e:	8082                	ret

0000000080002b80 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b80:	1101                	addi	sp,sp,-32
    80002b82:	ec06                	sd	ra,24(sp)
    80002b84:	e822                	sd	s0,16(sp)
    80002b86:	e426                	sd	s1,8(sp)
    80002b88:	1000                	addi	s0,sp,32
    80002b8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	ef2080e7          	jalr	-270(ra) # 80002a7e <argraw>
    80002b94:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b96:	4501                	li	a0,0
    80002b98:	60e2                	ld	ra,24(sp)
    80002b9a:	6442                	ld	s0,16(sp)
    80002b9c:	64a2                	ld	s1,8(sp)
    80002b9e:	6105                	addi	sp,sp,32
    80002ba0:	8082                	ret

0000000080002ba2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002ba2:	1101                	addi	sp,sp,-32
    80002ba4:	ec06                	sd	ra,24(sp)
    80002ba6:	e822                	sd	s0,16(sp)
    80002ba8:	e426                	sd	s1,8(sp)
    80002baa:	1000                	addi	s0,sp,32
    80002bac:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bae:	00000097          	auipc	ra,0x0
    80002bb2:	ed0080e7          	jalr	-304(ra) # 80002a7e <argraw>
    80002bb6:	e088                	sd	a0,0(s1)
  return 0;
}
    80002bb8:	4501                	li	a0,0
    80002bba:	60e2                	ld	ra,24(sp)
    80002bbc:	6442                	ld	s0,16(sp)
    80002bbe:	64a2                	ld	s1,8(sp)
    80002bc0:	6105                	addi	sp,sp,32
    80002bc2:	8082                	ret

0000000080002bc4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bc4:	1101                	addi	sp,sp,-32
    80002bc6:	ec06                	sd	ra,24(sp)
    80002bc8:	e822                	sd	s0,16(sp)
    80002bca:	e426                	sd	s1,8(sp)
    80002bcc:	e04a                	sd	s2,0(sp)
    80002bce:	1000                	addi	s0,sp,32
    80002bd0:	84ae                	mv	s1,a1
    80002bd2:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	eaa080e7          	jalr	-342(ra) # 80002a7e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002bdc:	864a                	mv	a2,s2
    80002bde:	85a6                	mv	a1,s1
    80002be0:	00000097          	auipc	ra,0x0
    80002be4:	f58080e7          	jalr	-168(ra) # 80002b38 <fetchstr>
}
    80002be8:	60e2                	ld	ra,24(sp)
    80002bea:	6442                	ld	s0,16(sp)
    80002bec:	64a2                	ld	s1,8(sp)
    80002bee:	6902                	ld	s2,0(sp)
    80002bf0:	6105                	addi	sp,sp,32
    80002bf2:	8082                	ret

0000000080002bf4 <syscall>:
[SYS_sigreturn] sys_sigreturn
};

void
syscall(void)
{
    80002bf4:	1101                	addi	sp,sp,-32
    80002bf6:	ec06                	sd	ra,24(sp)
    80002bf8:	e822                	sd	s0,16(sp)
    80002bfa:	e426                	sd	s1,8(sp)
    80002bfc:	e04a                	sd	s2,0(sp)
    80002bfe:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	e42080e7          	jalr	-446(ra) # 80001a42 <myproc>
    80002c08:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c0a:	05853903          	ld	s2,88(a0)
    80002c0e:	0a893783          	ld	a5,168(s2)
    80002c12:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c16:	37fd                	addiw	a5,a5,-1
    80002c18:	4759                	li	a4,22
    80002c1a:	00f76f63          	bltu	a4,a5,80002c38 <syscall+0x44>
    80002c1e:	00369713          	slli	a4,a3,0x3
    80002c22:	00006797          	auipc	a5,0x6
    80002c26:	81e78793          	addi	a5,a5,-2018 # 80008440 <syscalls>
    80002c2a:	97ba                	add	a5,a5,a4
    80002c2c:	639c                	ld	a5,0(a5)
    80002c2e:	c789                	beqz	a5,80002c38 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c30:	9782                	jalr	a5
    80002c32:	06a93823          	sd	a0,112(s2)
    80002c36:	a839                	j	80002c54 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c38:	15848613          	addi	a2,s1,344
    80002c3c:	5c8c                	lw	a1,56(s1)
    80002c3e:	00005517          	auipc	a0,0x5
    80002c42:	7ca50513          	addi	a0,a0,1994 # 80008408 <states.1711+0x148>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	9e2080e7          	jalr	-1566(ra) # 80000628 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c4e:	6cbc                	ld	a5,88(s1)
    80002c50:	577d                	li	a4,-1
    80002c52:	fbb8                	sd	a4,112(a5)
  }
}
    80002c54:	60e2                	ld	ra,24(sp)
    80002c56:	6442                	ld	s0,16(sp)
    80002c58:	64a2                	ld	s1,8(sp)
    80002c5a:	6902                	ld	s2,0(sp)
    80002c5c:	6105                	addi	sp,sp,32
    80002c5e:	8082                	ret

0000000080002c60 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c60:	1101                	addi	sp,sp,-32
    80002c62:	ec06                	sd	ra,24(sp)
    80002c64:	e822                	sd	s0,16(sp)
    80002c66:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c68:	fec40593          	addi	a1,s0,-20
    80002c6c:	4501                	li	a0,0
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	f12080e7          	jalr	-238(ra) # 80002b80 <argint>
    return -1;
    80002c76:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c78:	00054963          	bltz	a0,80002c8a <sys_exit+0x2a>
  exit(n);
    80002c7c:	fec42503          	lw	a0,-20(s0)
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	4bc080e7          	jalr	1212(ra) # 8000213c <exit>
  return 0;  // not reached
    80002c88:	4781                	li	a5,0
}
    80002c8a:	853e                	mv	a0,a5
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret

0000000080002c94 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c94:	1141                	addi	sp,sp,-16
    80002c96:	e406                	sd	ra,8(sp)
    80002c98:	e022                	sd	s0,0(sp)
    80002c9a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	da6080e7          	jalr	-602(ra) # 80001a42 <myproc>
}
    80002ca4:	5d08                	lw	a0,56(a0)
    80002ca6:	60a2                	ld	ra,8(sp)
    80002ca8:	6402                	ld	s0,0(sp)
    80002caa:	0141                	addi	sp,sp,16
    80002cac:	8082                	ret

0000000080002cae <sys_fork>:

uint64
sys_fork(void)
{
    80002cae:	1141                	addi	sp,sp,-16
    80002cb0:	e406                	sd	ra,8(sp)
    80002cb2:	e022                	sd	s0,0(sp)
    80002cb4:	0800                	addi	s0,sp,16
  return fork();
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	180080e7          	jalr	384(ra) # 80001e36 <fork>
}
    80002cbe:	60a2                	ld	ra,8(sp)
    80002cc0:	6402                	ld	s0,0(sp)
    80002cc2:	0141                	addi	sp,sp,16
    80002cc4:	8082                	ret

0000000080002cc6 <sys_wait>:

uint64
sys_wait(void)
{
    80002cc6:	1101                	addi	sp,sp,-32
    80002cc8:	ec06                	sd	ra,24(sp)
    80002cca:	e822                	sd	s0,16(sp)
    80002ccc:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002cce:	fe840593          	addi	a1,s0,-24
    80002cd2:	4501                	li	a0,0
    80002cd4:	00000097          	auipc	ra,0x0
    80002cd8:	ece080e7          	jalr	-306(ra) # 80002ba2 <argaddr>
    80002cdc:	87aa                	mv	a5,a0
    return -1;
    80002cde:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002ce0:	0007c863          	bltz	a5,80002cf0 <sys_wait+0x2a>
  return wait(p);
    80002ce4:	fe843503          	ld	a0,-24(s0)
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	618080e7          	jalr	1560(ra) # 80002300 <wait>
}
    80002cf0:	60e2                	ld	ra,24(sp)
    80002cf2:	6442                	ld	s0,16(sp)
    80002cf4:	6105                	addi	sp,sp,32
    80002cf6:	8082                	ret

0000000080002cf8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cf8:	7179                	addi	sp,sp,-48
    80002cfa:	f406                	sd	ra,40(sp)
    80002cfc:	f022                	sd	s0,32(sp)
    80002cfe:	ec26                	sd	s1,24(sp)
    80002d00:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d02:	fdc40593          	addi	a1,s0,-36
    80002d06:	4501                	li	a0,0
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	e78080e7          	jalr	-392(ra) # 80002b80 <argint>
    80002d10:	87aa                	mv	a5,a0
    return -1;
    80002d12:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002d14:	0207c063          	bltz	a5,80002d34 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002d18:	fffff097          	auipc	ra,0xfffff
    80002d1c:	d2a080e7          	jalr	-726(ra) # 80001a42 <myproc>
    80002d20:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002d22:	fdc42503          	lw	a0,-36(s0)
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	09c080e7          	jalr	156(ra) # 80001dc2 <growproc>
    80002d2e:	00054863          	bltz	a0,80002d3e <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d32:	8526                	mv	a0,s1
}
    80002d34:	70a2                	ld	ra,40(sp)
    80002d36:	7402                	ld	s0,32(sp)
    80002d38:	64e2                	ld	s1,24(sp)
    80002d3a:	6145                	addi	sp,sp,48
    80002d3c:	8082                	ret
    return -1;
    80002d3e:	557d                	li	a0,-1
    80002d40:	bfd5                	j	80002d34 <sys_sbrk+0x3c>

0000000080002d42 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d42:	7139                	addi	sp,sp,-64
    80002d44:	fc06                	sd	ra,56(sp)
    80002d46:	f822                	sd	s0,48(sp)
    80002d48:	f426                	sd	s1,40(sp)
    80002d4a:	f04a                	sd	s2,32(sp)
    80002d4c:	ec4e                	sd	s3,24(sp)
    80002d4e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d50:	fcc40593          	addi	a1,s0,-52
    80002d54:	4501                	li	a0,0
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	e2a080e7          	jalr	-470(ra) # 80002b80 <argint>
    return -1;
    80002d5e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d60:	06054963          	bltz	a0,80002dd2 <sys_sleep+0x90>
  acquire(&tickslock);
    80002d64:	00015517          	auipc	a0,0x15
    80002d68:	20450513          	addi	a0,a0,516 # 80017f68 <tickslock>
    80002d6c:	ffffe097          	auipc	ra,0xffffe
    80002d70:	f08080e7          	jalr	-248(ra) # 80000c74 <acquire>
  ticks0 = ticks;
    80002d74:	00006917          	auipc	s2,0x6
    80002d78:	2ac92903          	lw	s2,684(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002d7c:	fcc42783          	lw	a5,-52(s0)
    80002d80:	cf85                	beqz	a5,80002db8 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d82:	00015997          	auipc	s3,0x15
    80002d86:	1e698993          	addi	s3,s3,486 # 80017f68 <tickslock>
    80002d8a:	00006497          	auipc	s1,0x6
    80002d8e:	29648493          	addi	s1,s1,662 # 80009020 <ticks>
    if(myproc()->killed){
    80002d92:	fffff097          	auipc	ra,0xfffff
    80002d96:	cb0080e7          	jalr	-848(ra) # 80001a42 <myproc>
    80002d9a:	591c                	lw	a5,48(a0)
    80002d9c:	e3b9                	bnez	a5,80002de2 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80002d9e:	85ce                	mv	a1,s3
    80002da0:	8526                	mv	a0,s1
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	4e0080e7          	jalr	1248(ra) # 80002282 <sleep>
  while(ticks - ticks0 < n){
    80002daa:	409c                	lw	a5,0(s1)
    80002dac:	412787bb          	subw	a5,a5,s2
    80002db0:	fcc42703          	lw	a4,-52(s0)
    80002db4:	fce7efe3          	bltu	a5,a4,80002d92 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002db8:	00015517          	auipc	a0,0x15
    80002dbc:	1b050513          	addi	a0,a0,432 # 80017f68 <tickslock>
    80002dc0:	ffffe097          	auipc	ra,0xffffe
    80002dc4:	f68080e7          	jalr	-152(ra) # 80000d28 <release>
  backtrace();
    80002dc8:	ffffd097          	auipc	ra,0xffffd
    80002dcc:	7b2080e7          	jalr	1970(ra) # 8000057a <backtrace>
  return 0;
    80002dd0:	4781                	li	a5,0
}
    80002dd2:	853e                	mv	a0,a5
    80002dd4:	70e2                	ld	ra,56(sp)
    80002dd6:	7442                	ld	s0,48(sp)
    80002dd8:	74a2                	ld	s1,40(sp)
    80002dda:	7902                	ld	s2,32(sp)
    80002ddc:	69e2                	ld	s3,24(sp)
    80002dde:	6121                	addi	sp,sp,64
    80002de0:	8082                	ret
      release(&tickslock);
    80002de2:	00015517          	auipc	a0,0x15
    80002de6:	18650513          	addi	a0,a0,390 # 80017f68 <tickslock>
    80002dea:	ffffe097          	auipc	ra,0xffffe
    80002dee:	f3e080e7          	jalr	-194(ra) # 80000d28 <release>
      return -1;
    80002df2:	57fd                	li	a5,-1
    80002df4:	bff9                	j	80002dd2 <sys_sleep+0x90>

0000000080002df6 <sys_kill>:

uint64
sys_kill(void)
{
    80002df6:	1101                	addi	sp,sp,-32
    80002df8:	ec06                	sd	ra,24(sp)
    80002dfa:	e822                	sd	s0,16(sp)
    80002dfc:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002dfe:	fec40593          	addi	a1,s0,-20
    80002e02:	4501                	li	a0,0
    80002e04:	00000097          	auipc	ra,0x0
    80002e08:	d7c080e7          	jalr	-644(ra) # 80002b80 <argint>
    80002e0c:	87aa                	mv	a5,a0
    return -1;
    80002e0e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e10:	0007c863          	bltz	a5,80002e20 <sys_kill+0x2a>
  return kill(pid);
    80002e14:	fec42503          	lw	a0,-20(s0)
    80002e18:	fffff097          	auipc	ra,0xfffff
    80002e1c:	65a080e7          	jalr	1626(ra) # 80002472 <kill>
}
    80002e20:	60e2                	ld	ra,24(sp)
    80002e22:	6442                	ld	s0,16(sp)
    80002e24:	6105                	addi	sp,sp,32
    80002e26:	8082                	ret

0000000080002e28 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e28:	1101                	addi	sp,sp,-32
    80002e2a:	ec06                	sd	ra,24(sp)
    80002e2c:	e822                	sd	s0,16(sp)
    80002e2e:	e426                	sd	s1,8(sp)
    80002e30:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e32:	00015517          	auipc	a0,0x15
    80002e36:	13650513          	addi	a0,a0,310 # 80017f68 <tickslock>
    80002e3a:	ffffe097          	auipc	ra,0xffffe
    80002e3e:	e3a080e7          	jalr	-454(ra) # 80000c74 <acquire>
  xticks = ticks;
    80002e42:	00006497          	auipc	s1,0x6
    80002e46:	1de4a483          	lw	s1,478(s1) # 80009020 <ticks>
  release(&tickslock);
    80002e4a:	00015517          	auipc	a0,0x15
    80002e4e:	11e50513          	addi	a0,a0,286 # 80017f68 <tickslock>
    80002e52:	ffffe097          	auipc	ra,0xffffe
    80002e56:	ed6080e7          	jalr	-298(ra) # 80000d28 <release>
  return xticks;
}
    80002e5a:	02049513          	slli	a0,s1,0x20
    80002e5e:	9101                	srli	a0,a0,0x20
    80002e60:	60e2                	ld	ra,24(sp)
    80002e62:	6442                	ld	s0,16(sp)
    80002e64:	64a2                	ld	s1,8(sp)
    80002e66:	6105                	addi	sp,sp,32
    80002e68:	8082                	ret

0000000080002e6a <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80002e6a:	1101                	addi	sp,sp,-32
    80002e6c:	ec06                	sd	ra,24(sp)
    80002e6e:	e822                	sd	s0,16(sp)
    80002e70:	1000                	addi	s0,sp,32
  int interval;
  uint64 handler;
  struct proc* p;

  if(argint(0, &interval)<0 || argaddr(1, &handler)<0) 
    80002e72:	fec40593          	addi	a1,s0,-20
    80002e76:	4501                	li	a0,0
    80002e78:	00000097          	auipc	ra,0x0
    80002e7c:	d08080e7          	jalr	-760(ra) # 80002b80 <argint>
    return -1;
    80002e80:	57fd                	li	a5,-1
  if(argint(0, &interval)<0 || argaddr(1, &handler)<0) 
    80002e82:	02054963          	bltz	a0,80002eb4 <sys_sigalarm+0x4a>
    80002e86:	fe040593          	addi	a1,s0,-32
    80002e8a:	4505                	li	a0,1
    80002e8c:	00000097          	auipc	ra,0x0
    80002e90:	d16080e7          	jalr	-746(ra) # 80002ba2 <argaddr>
    return -1;
    80002e94:	57fd                	li	a5,-1
  if(argint(0, &interval)<0 || argaddr(1, &handler)<0) 
    80002e96:	00054f63          	bltz	a0,80002eb4 <sys_sigalarm+0x4a>

  p = myproc();
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	ba8080e7          	jalr	-1112(ra) # 80001a42 <myproc>
  p->interval = interval;
    80002ea2:	fec42783          	lw	a5,-20(s0)
    80002ea6:	16f52423          	sw	a5,360(a0)
  p->handler = handler;
    80002eaa:	fe043783          	ld	a5,-32(s0)
    80002eae:	16f53823          	sd	a5,368(a0)

  return 0;
    80002eb2:	4781                	li	a5,0
}
    80002eb4:	853e                	mv	a0,a5
    80002eb6:	60e2                	ld	ra,24(sp)
    80002eb8:	6442                	ld	s0,16(sp)
    80002eba:	6105                	addi	sp,sp,32
    80002ebc:	8082                	ret

0000000080002ebe <sys_sigreturn>:

uint64
sys_sigreturn(void)
{ 
    80002ebe:	1141                	addi	sp,sp,-16
    80002ec0:	e406                	sd	ra,8(sp)
    80002ec2:	e022                	sd	s0,0(sp)
    80002ec4:	0800                	addi	s0,sp,16
  struct proc* p;

  p = myproc();
    80002ec6:	fffff097          	auipc	ra,0xfffff
    80002eca:	b7c080e7          	jalr	-1156(ra) # 80001a42 <myproc>
  *p->trapframe = *p->trapframe2;
    80002ece:	18053683          	ld	a3,384(a0)
    80002ed2:	87b6                	mv	a5,a3
    80002ed4:	6d38                	ld	a4,88(a0)
    80002ed6:	12068693          	addi	a3,a3,288
    80002eda:	0007b883          	ld	a7,0(a5)
    80002ede:	0087b803          	ld	a6,8(a5)
    80002ee2:	6b8c                	ld	a1,16(a5)
    80002ee4:	6f90                	ld	a2,24(a5)
    80002ee6:	01173023          	sd	a7,0(a4)
    80002eea:	01073423          	sd	a6,8(a4)
    80002eee:	eb0c                	sd	a1,16(a4)
    80002ef0:	ef10                	sd	a2,24(a4)
    80002ef2:	02078793          	addi	a5,a5,32
    80002ef6:	02070713          	addi	a4,a4,32
    80002efa:	fed790e3          	bne	a5,a3,80002eda <sys_sigreturn+0x1c>
  
  /** 为下一次回调handler函数做准备 */
  p->ticks = 0;
    80002efe:	16052c23          	sw	zero,376(a0)

  return 0;
    80002f02:	4501                	li	a0,0
    80002f04:	60a2                	ld	ra,8(sp)
    80002f06:	6402                	ld	s0,0(sp)
    80002f08:	0141                	addi	sp,sp,16
    80002f0a:	8082                	ret

0000000080002f0c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f0c:	7179                	addi	sp,sp,-48
    80002f0e:	f406                	sd	ra,40(sp)
    80002f10:	f022                	sd	s0,32(sp)
    80002f12:	ec26                	sd	s1,24(sp)
    80002f14:	e84a                	sd	s2,16(sp)
    80002f16:	e44e                	sd	s3,8(sp)
    80002f18:	e052                	sd	s4,0(sp)
    80002f1a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f1c:	00005597          	auipc	a1,0x5
    80002f20:	5e458593          	addi	a1,a1,1508 # 80008500 <syscalls+0xc0>
    80002f24:	00015517          	auipc	a0,0x15
    80002f28:	05c50513          	addi	a0,a0,92 # 80017f80 <bcache>
    80002f2c:	ffffe097          	auipc	ra,0xffffe
    80002f30:	cb8080e7          	jalr	-840(ra) # 80000be4 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f34:	0001d797          	auipc	a5,0x1d
    80002f38:	04c78793          	addi	a5,a5,76 # 8001ff80 <bcache+0x8000>
    80002f3c:	0001d717          	auipc	a4,0x1d
    80002f40:	2ac70713          	addi	a4,a4,684 # 800201e8 <bcache+0x8268>
    80002f44:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f48:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f4c:	00015497          	auipc	s1,0x15
    80002f50:	04c48493          	addi	s1,s1,76 # 80017f98 <bcache+0x18>
    b->next = bcache.head.next;
    80002f54:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f56:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f58:	00005a17          	auipc	s4,0x5
    80002f5c:	5b0a0a13          	addi	s4,s4,1456 # 80008508 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002f60:	2b893783          	ld	a5,696(s2)
    80002f64:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f66:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f6a:	85d2                	mv	a1,s4
    80002f6c:	01048513          	addi	a0,s1,16
    80002f70:	00001097          	auipc	ra,0x1
    80002f74:	4ac080e7          	jalr	1196(ra) # 8000441c <initsleeplock>
    bcache.head.next->prev = b;
    80002f78:	2b893783          	ld	a5,696(s2)
    80002f7c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f7e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f82:	45848493          	addi	s1,s1,1112
    80002f86:	fd349de3          	bne	s1,s3,80002f60 <binit+0x54>
  }
}
    80002f8a:	70a2                	ld	ra,40(sp)
    80002f8c:	7402                	ld	s0,32(sp)
    80002f8e:	64e2                	ld	s1,24(sp)
    80002f90:	6942                	ld	s2,16(sp)
    80002f92:	69a2                	ld	s3,8(sp)
    80002f94:	6a02                	ld	s4,0(sp)
    80002f96:	6145                	addi	sp,sp,48
    80002f98:	8082                	ret

0000000080002f9a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f9a:	7179                	addi	sp,sp,-48
    80002f9c:	f406                	sd	ra,40(sp)
    80002f9e:	f022                	sd	s0,32(sp)
    80002fa0:	ec26                	sd	s1,24(sp)
    80002fa2:	e84a                	sd	s2,16(sp)
    80002fa4:	e44e                	sd	s3,8(sp)
    80002fa6:	1800                	addi	s0,sp,48
    80002fa8:	89aa                	mv	s3,a0
    80002faa:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002fac:	00015517          	auipc	a0,0x15
    80002fb0:	fd450513          	addi	a0,a0,-44 # 80017f80 <bcache>
    80002fb4:	ffffe097          	auipc	ra,0xffffe
    80002fb8:	cc0080e7          	jalr	-832(ra) # 80000c74 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fbc:	0001d497          	auipc	s1,0x1d
    80002fc0:	27c4b483          	ld	s1,636(s1) # 80020238 <bcache+0x82b8>
    80002fc4:	0001d797          	auipc	a5,0x1d
    80002fc8:	22478793          	addi	a5,a5,548 # 800201e8 <bcache+0x8268>
    80002fcc:	02f48f63          	beq	s1,a5,8000300a <bread+0x70>
    80002fd0:	873e                	mv	a4,a5
    80002fd2:	a021                	j	80002fda <bread+0x40>
    80002fd4:	68a4                	ld	s1,80(s1)
    80002fd6:	02e48a63          	beq	s1,a4,8000300a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fda:	449c                	lw	a5,8(s1)
    80002fdc:	ff379ce3          	bne	a5,s3,80002fd4 <bread+0x3a>
    80002fe0:	44dc                	lw	a5,12(s1)
    80002fe2:	ff2799e3          	bne	a5,s2,80002fd4 <bread+0x3a>
      b->refcnt++;
    80002fe6:	40bc                	lw	a5,64(s1)
    80002fe8:	2785                	addiw	a5,a5,1
    80002fea:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fec:	00015517          	auipc	a0,0x15
    80002ff0:	f9450513          	addi	a0,a0,-108 # 80017f80 <bcache>
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	d34080e7          	jalr	-716(ra) # 80000d28 <release>
      acquiresleep(&b->lock);
    80002ffc:	01048513          	addi	a0,s1,16
    80003000:	00001097          	auipc	ra,0x1
    80003004:	456080e7          	jalr	1110(ra) # 80004456 <acquiresleep>
      return b;
    80003008:	a8b9                	j	80003066 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000300a:	0001d497          	auipc	s1,0x1d
    8000300e:	2264b483          	ld	s1,550(s1) # 80020230 <bcache+0x82b0>
    80003012:	0001d797          	auipc	a5,0x1d
    80003016:	1d678793          	addi	a5,a5,470 # 800201e8 <bcache+0x8268>
    8000301a:	00f48863          	beq	s1,a5,8000302a <bread+0x90>
    8000301e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003020:	40bc                	lw	a5,64(s1)
    80003022:	cf81                	beqz	a5,8000303a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003024:	64a4                	ld	s1,72(s1)
    80003026:	fee49de3          	bne	s1,a4,80003020 <bread+0x86>
  panic("bget: no buffers");
    8000302a:	00005517          	auipc	a0,0x5
    8000302e:	4e650513          	addi	a0,a0,1254 # 80008510 <syscalls+0xd0>
    80003032:	ffffd097          	auipc	ra,0xffffd
    80003036:	5a4080e7          	jalr	1444(ra) # 800005d6 <panic>
      b->dev = dev;
    8000303a:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000303e:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003042:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003046:	4785                	li	a5,1
    80003048:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000304a:	00015517          	auipc	a0,0x15
    8000304e:	f3650513          	addi	a0,a0,-202 # 80017f80 <bcache>
    80003052:	ffffe097          	auipc	ra,0xffffe
    80003056:	cd6080e7          	jalr	-810(ra) # 80000d28 <release>
      acquiresleep(&b->lock);
    8000305a:	01048513          	addi	a0,s1,16
    8000305e:	00001097          	auipc	ra,0x1
    80003062:	3f8080e7          	jalr	1016(ra) # 80004456 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003066:	409c                	lw	a5,0(s1)
    80003068:	cb89                	beqz	a5,8000307a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000306a:	8526                	mv	a0,s1
    8000306c:	70a2                	ld	ra,40(sp)
    8000306e:	7402                	ld	s0,32(sp)
    80003070:	64e2                	ld	s1,24(sp)
    80003072:	6942                	ld	s2,16(sp)
    80003074:	69a2                	ld	s3,8(sp)
    80003076:	6145                	addi	sp,sp,48
    80003078:	8082                	ret
    virtio_disk_rw(b, 0);
    8000307a:	4581                	li	a1,0
    8000307c:	8526                	mv	a0,s1
    8000307e:	00003097          	auipc	ra,0x3
    80003082:	f2e080e7          	jalr	-210(ra) # 80005fac <virtio_disk_rw>
    b->valid = 1;
    80003086:	4785                	li	a5,1
    80003088:	c09c                	sw	a5,0(s1)
  return b;
    8000308a:	b7c5                	j	8000306a <bread+0xd0>

000000008000308c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	e426                	sd	s1,8(sp)
    80003094:	1000                	addi	s0,sp,32
    80003096:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003098:	0541                	addi	a0,a0,16
    8000309a:	00001097          	auipc	ra,0x1
    8000309e:	456080e7          	jalr	1110(ra) # 800044f0 <holdingsleep>
    800030a2:	cd01                	beqz	a0,800030ba <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030a4:	4585                	li	a1,1
    800030a6:	8526                	mv	a0,s1
    800030a8:	00003097          	auipc	ra,0x3
    800030ac:	f04080e7          	jalr	-252(ra) # 80005fac <virtio_disk_rw>
}
    800030b0:	60e2                	ld	ra,24(sp)
    800030b2:	6442                	ld	s0,16(sp)
    800030b4:	64a2                	ld	s1,8(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret
    panic("bwrite");
    800030ba:	00005517          	auipc	a0,0x5
    800030be:	46e50513          	addi	a0,a0,1134 # 80008528 <syscalls+0xe8>
    800030c2:	ffffd097          	auipc	ra,0xffffd
    800030c6:	514080e7          	jalr	1300(ra) # 800005d6 <panic>

00000000800030ca <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030ca:	1101                	addi	sp,sp,-32
    800030cc:	ec06                	sd	ra,24(sp)
    800030ce:	e822                	sd	s0,16(sp)
    800030d0:	e426                	sd	s1,8(sp)
    800030d2:	e04a                	sd	s2,0(sp)
    800030d4:	1000                	addi	s0,sp,32
    800030d6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030d8:	01050913          	addi	s2,a0,16
    800030dc:	854a                	mv	a0,s2
    800030de:	00001097          	auipc	ra,0x1
    800030e2:	412080e7          	jalr	1042(ra) # 800044f0 <holdingsleep>
    800030e6:	c92d                	beqz	a0,80003158 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800030e8:	854a                	mv	a0,s2
    800030ea:	00001097          	auipc	ra,0x1
    800030ee:	3c2080e7          	jalr	962(ra) # 800044ac <releasesleep>

  acquire(&bcache.lock);
    800030f2:	00015517          	auipc	a0,0x15
    800030f6:	e8e50513          	addi	a0,a0,-370 # 80017f80 <bcache>
    800030fa:	ffffe097          	auipc	ra,0xffffe
    800030fe:	b7a080e7          	jalr	-1158(ra) # 80000c74 <acquire>
  b->refcnt--;
    80003102:	40bc                	lw	a5,64(s1)
    80003104:	37fd                	addiw	a5,a5,-1
    80003106:	0007871b          	sext.w	a4,a5
    8000310a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000310c:	eb05                	bnez	a4,8000313c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000310e:	68bc                	ld	a5,80(s1)
    80003110:	64b8                	ld	a4,72(s1)
    80003112:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003114:	64bc                	ld	a5,72(s1)
    80003116:	68b8                	ld	a4,80(s1)
    80003118:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000311a:	0001d797          	auipc	a5,0x1d
    8000311e:	e6678793          	addi	a5,a5,-410 # 8001ff80 <bcache+0x8000>
    80003122:	2b87b703          	ld	a4,696(a5)
    80003126:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003128:	0001d717          	auipc	a4,0x1d
    8000312c:	0c070713          	addi	a4,a4,192 # 800201e8 <bcache+0x8268>
    80003130:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003132:	2b87b703          	ld	a4,696(a5)
    80003136:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003138:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000313c:	00015517          	auipc	a0,0x15
    80003140:	e4450513          	addi	a0,a0,-444 # 80017f80 <bcache>
    80003144:	ffffe097          	auipc	ra,0xffffe
    80003148:	be4080e7          	jalr	-1052(ra) # 80000d28 <release>
}
    8000314c:	60e2                	ld	ra,24(sp)
    8000314e:	6442                	ld	s0,16(sp)
    80003150:	64a2                	ld	s1,8(sp)
    80003152:	6902                	ld	s2,0(sp)
    80003154:	6105                	addi	sp,sp,32
    80003156:	8082                	ret
    panic("brelse");
    80003158:	00005517          	auipc	a0,0x5
    8000315c:	3d850513          	addi	a0,a0,984 # 80008530 <syscalls+0xf0>
    80003160:	ffffd097          	auipc	ra,0xffffd
    80003164:	476080e7          	jalr	1142(ra) # 800005d6 <panic>

0000000080003168 <bpin>:

void
bpin(struct buf *b) {
    80003168:	1101                	addi	sp,sp,-32
    8000316a:	ec06                	sd	ra,24(sp)
    8000316c:	e822                	sd	s0,16(sp)
    8000316e:	e426                	sd	s1,8(sp)
    80003170:	1000                	addi	s0,sp,32
    80003172:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003174:	00015517          	auipc	a0,0x15
    80003178:	e0c50513          	addi	a0,a0,-500 # 80017f80 <bcache>
    8000317c:	ffffe097          	auipc	ra,0xffffe
    80003180:	af8080e7          	jalr	-1288(ra) # 80000c74 <acquire>
  b->refcnt++;
    80003184:	40bc                	lw	a5,64(s1)
    80003186:	2785                	addiw	a5,a5,1
    80003188:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000318a:	00015517          	auipc	a0,0x15
    8000318e:	df650513          	addi	a0,a0,-522 # 80017f80 <bcache>
    80003192:	ffffe097          	auipc	ra,0xffffe
    80003196:	b96080e7          	jalr	-1130(ra) # 80000d28 <release>
}
    8000319a:	60e2                	ld	ra,24(sp)
    8000319c:	6442                	ld	s0,16(sp)
    8000319e:	64a2                	ld	s1,8(sp)
    800031a0:	6105                	addi	sp,sp,32
    800031a2:	8082                	ret

00000000800031a4 <bunpin>:

void
bunpin(struct buf *b) {
    800031a4:	1101                	addi	sp,sp,-32
    800031a6:	ec06                	sd	ra,24(sp)
    800031a8:	e822                	sd	s0,16(sp)
    800031aa:	e426                	sd	s1,8(sp)
    800031ac:	1000                	addi	s0,sp,32
    800031ae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031b0:	00015517          	auipc	a0,0x15
    800031b4:	dd050513          	addi	a0,a0,-560 # 80017f80 <bcache>
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	abc080e7          	jalr	-1348(ra) # 80000c74 <acquire>
  b->refcnt--;
    800031c0:	40bc                	lw	a5,64(s1)
    800031c2:	37fd                	addiw	a5,a5,-1
    800031c4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031c6:	00015517          	auipc	a0,0x15
    800031ca:	dba50513          	addi	a0,a0,-582 # 80017f80 <bcache>
    800031ce:	ffffe097          	auipc	ra,0xffffe
    800031d2:	b5a080e7          	jalr	-1190(ra) # 80000d28 <release>
}
    800031d6:	60e2                	ld	ra,24(sp)
    800031d8:	6442                	ld	s0,16(sp)
    800031da:	64a2                	ld	s1,8(sp)
    800031dc:	6105                	addi	sp,sp,32
    800031de:	8082                	ret

00000000800031e0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031e0:	1101                	addi	sp,sp,-32
    800031e2:	ec06                	sd	ra,24(sp)
    800031e4:	e822                	sd	s0,16(sp)
    800031e6:	e426                	sd	s1,8(sp)
    800031e8:	e04a                	sd	s2,0(sp)
    800031ea:	1000                	addi	s0,sp,32
    800031ec:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031ee:	00d5d59b          	srliw	a1,a1,0xd
    800031f2:	0001d797          	auipc	a5,0x1d
    800031f6:	46a7a783          	lw	a5,1130(a5) # 8002065c <sb+0x1c>
    800031fa:	9dbd                	addw	a1,a1,a5
    800031fc:	00000097          	auipc	ra,0x0
    80003200:	d9e080e7          	jalr	-610(ra) # 80002f9a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003204:	0074f713          	andi	a4,s1,7
    80003208:	4785                	li	a5,1
    8000320a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000320e:	14ce                	slli	s1,s1,0x33
    80003210:	90d9                	srli	s1,s1,0x36
    80003212:	00950733          	add	a4,a0,s1
    80003216:	05874703          	lbu	a4,88(a4)
    8000321a:	00e7f6b3          	and	a3,a5,a4
    8000321e:	c69d                	beqz	a3,8000324c <bfree+0x6c>
    80003220:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003222:	94aa                	add	s1,s1,a0
    80003224:	fff7c793          	not	a5,a5
    80003228:	8ff9                	and	a5,a5,a4
    8000322a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000322e:	00001097          	auipc	ra,0x1
    80003232:	100080e7          	jalr	256(ra) # 8000432e <log_write>
  brelse(bp);
    80003236:	854a                	mv	a0,s2
    80003238:	00000097          	auipc	ra,0x0
    8000323c:	e92080e7          	jalr	-366(ra) # 800030ca <brelse>
}
    80003240:	60e2                	ld	ra,24(sp)
    80003242:	6442                	ld	s0,16(sp)
    80003244:	64a2                	ld	s1,8(sp)
    80003246:	6902                	ld	s2,0(sp)
    80003248:	6105                	addi	sp,sp,32
    8000324a:	8082                	ret
    panic("freeing free block");
    8000324c:	00005517          	auipc	a0,0x5
    80003250:	2ec50513          	addi	a0,a0,748 # 80008538 <syscalls+0xf8>
    80003254:	ffffd097          	auipc	ra,0xffffd
    80003258:	382080e7          	jalr	898(ra) # 800005d6 <panic>

000000008000325c <balloc>:
{
    8000325c:	711d                	addi	sp,sp,-96
    8000325e:	ec86                	sd	ra,88(sp)
    80003260:	e8a2                	sd	s0,80(sp)
    80003262:	e4a6                	sd	s1,72(sp)
    80003264:	e0ca                	sd	s2,64(sp)
    80003266:	fc4e                	sd	s3,56(sp)
    80003268:	f852                	sd	s4,48(sp)
    8000326a:	f456                	sd	s5,40(sp)
    8000326c:	f05a                	sd	s6,32(sp)
    8000326e:	ec5e                	sd	s7,24(sp)
    80003270:	e862                	sd	s8,16(sp)
    80003272:	e466                	sd	s9,8(sp)
    80003274:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003276:	0001d797          	auipc	a5,0x1d
    8000327a:	3ce7a783          	lw	a5,974(a5) # 80020644 <sb+0x4>
    8000327e:	cbd1                	beqz	a5,80003312 <balloc+0xb6>
    80003280:	8baa                	mv	s7,a0
    80003282:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003284:	0001db17          	auipc	s6,0x1d
    80003288:	3bcb0b13          	addi	s6,s6,956 # 80020640 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000328c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000328e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003290:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003292:	6c89                	lui	s9,0x2
    80003294:	a831                	j	800032b0 <balloc+0x54>
    brelse(bp);
    80003296:	854a                	mv	a0,s2
    80003298:	00000097          	auipc	ra,0x0
    8000329c:	e32080e7          	jalr	-462(ra) # 800030ca <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032a0:	015c87bb          	addw	a5,s9,s5
    800032a4:	00078a9b          	sext.w	s5,a5
    800032a8:	004b2703          	lw	a4,4(s6)
    800032ac:	06eaf363          	bgeu	s5,a4,80003312 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800032b0:	41fad79b          	sraiw	a5,s5,0x1f
    800032b4:	0137d79b          	srliw	a5,a5,0x13
    800032b8:	015787bb          	addw	a5,a5,s5
    800032bc:	40d7d79b          	sraiw	a5,a5,0xd
    800032c0:	01cb2583          	lw	a1,28(s6)
    800032c4:	9dbd                	addw	a1,a1,a5
    800032c6:	855e                	mv	a0,s7
    800032c8:	00000097          	auipc	ra,0x0
    800032cc:	cd2080e7          	jalr	-814(ra) # 80002f9a <bread>
    800032d0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032d2:	004b2503          	lw	a0,4(s6)
    800032d6:	000a849b          	sext.w	s1,s5
    800032da:	8662                	mv	a2,s8
    800032dc:	faa4fde3          	bgeu	s1,a0,80003296 <balloc+0x3a>
      m = 1 << (bi % 8);
    800032e0:	41f6579b          	sraiw	a5,a2,0x1f
    800032e4:	01d7d69b          	srliw	a3,a5,0x1d
    800032e8:	00c6873b          	addw	a4,a3,a2
    800032ec:	00777793          	andi	a5,a4,7
    800032f0:	9f95                	subw	a5,a5,a3
    800032f2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032f6:	4037571b          	sraiw	a4,a4,0x3
    800032fa:	00e906b3          	add	a3,s2,a4
    800032fe:	0586c683          	lbu	a3,88(a3)
    80003302:	00d7f5b3          	and	a1,a5,a3
    80003306:	cd91                	beqz	a1,80003322 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003308:	2605                	addiw	a2,a2,1
    8000330a:	2485                	addiw	s1,s1,1
    8000330c:	fd4618e3          	bne	a2,s4,800032dc <balloc+0x80>
    80003310:	b759                	j	80003296 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003312:	00005517          	auipc	a0,0x5
    80003316:	23e50513          	addi	a0,a0,574 # 80008550 <syscalls+0x110>
    8000331a:	ffffd097          	auipc	ra,0xffffd
    8000331e:	2bc080e7          	jalr	700(ra) # 800005d6 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003322:	974a                	add	a4,a4,s2
    80003324:	8fd5                	or	a5,a5,a3
    80003326:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000332a:	854a                	mv	a0,s2
    8000332c:	00001097          	auipc	ra,0x1
    80003330:	002080e7          	jalr	2(ra) # 8000432e <log_write>
        brelse(bp);
    80003334:	854a                	mv	a0,s2
    80003336:	00000097          	auipc	ra,0x0
    8000333a:	d94080e7          	jalr	-620(ra) # 800030ca <brelse>
  bp = bread(dev, bno);
    8000333e:	85a6                	mv	a1,s1
    80003340:	855e                	mv	a0,s7
    80003342:	00000097          	auipc	ra,0x0
    80003346:	c58080e7          	jalr	-936(ra) # 80002f9a <bread>
    8000334a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000334c:	40000613          	li	a2,1024
    80003350:	4581                	li	a1,0
    80003352:	05850513          	addi	a0,a0,88
    80003356:	ffffe097          	auipc	ra,0xffffe
    8000335a:	a1a080e7          	jalr	-1510(ra) # 80000d70 <memset>
  log_write(bp);
    8000335e:	854a                	mv	a0,s2
    80003360:	00001097          	auipc	ra,0x1
    80003364:	fce080e7          	jalr	-50(ra) # 8000432e <log_write>
  brelse(bp);
    80003368:	854a                	mv	a0,s2
    8000336a:	00000097          	auipc	ra,0x0
    8000336e:	d60080e7          	jalr	-672(ra) # 800030ca <brelse>
}
    80003372:	8526                	mv	a0,s1
    80003374:	60e6                	ld	ra,88(sp)
    80003376:	6446                	ld	s0,80(sp)
    80003378:	64a6                	ld	s1,72(sp)
    8000337a:	6906                	ld	s2,64(sp)
    8000337c:	79e2                	ld	s3,56(sp)
    8000337e:	7a42                	ld	s4,48(sp)
    80003380:	7aa2                	ld	s5,40(sp)
    80003382:	7b02                	ld	s6,32(sp)
    80003384:	6be2                	ld	s7,24(sp)
    80003386:	6c42                	ld	s8,16(sp)
    80003388:	6ca2                	ld	s9,8(sp)
    8000338a:	6125                	addi	sp,sp,96
    8000338c:	8082                	ret

000000008000338e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000338e:	7179                	addi	sp,sp,-48
    80003390:	f406                	sd	ra,40(sp)
    80003392:	f022                	sd	s0,32(sp)
    80003394:	ec26                	sd	s1,24(sp)
    80003396:	e84a                	sd	s2,16(sp)
    80003398:	e44e                	sd	s3,8(sp)
    8000339a:	e052                	sd	s4,0(sp)
    8000339c:	1800                	addi	s0,sp,48
    8000339e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033a0:	47ad                	li	a5,11
    800033a2:	04b7fe63          	bgeu	a5,a1,800033fe <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800033a6:	ff45849b          	addiw	s1,a1,-12
    800033aa:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033ae:	0ff00793          	li	a5,255
    800033b2:	0ae7e363          	bltu	a5,a4,80003458 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800033b6:	08052583          	lw	a1,128(a0)
    800033ba:	c5ad                	beqz	a1,80003424 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800033bc:	00092503          	lw	a0,0(s2)
    800033c0:	00000097          	auipc	ra,0x0
    800033c4:	bda080e7          	jalr	-1062(ra) # 80002f9a <bread>
    800033c8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033ca:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033ce:	02049593          	slli	a1,s1,0x20
    800033d2:	9181                	srli	a1,a1,0x20
    800033d4:	058a                	slli	a1,a1,0x2
    800033d6:	00b784b3          	add	s1,a5,a1
    800033da:	0004a983          	lw	s3,0(s1)
    800033de:	04098d63          	beqz	s3,80003438 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800033e2:	8552                	mv	a0,s4
    800033e4:	00000097          	auipc	ra,0x0
    800033e8:	ce6080e7          	jalr	-794(ra) # 800030ca <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033ec:	854e                	mv	a0,s3
    800033ee:	70a2                	ld	ra,40(sp)
    800033f0:	7402                	ld	s0,32(sp)
    800033f2:	64e2                	ld	s1,24(sp)
    800033f4:	6942                	ld	s2,16(sp)
    800033f6:	69a2                	ld	s3,8(sp)
    800033f8:	6a02                	ld	s4,0(sp)
    800033fa:	6145                	addi	sp,sp,48
    800033fc:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033fe:	02059493          	slli	s1,a1,0x20
    80003402:	9081                	srli	s1,s1,0x20
    80003404:	048a                	slli	s1,s1,0x2
    80003406:	94aa                	add	s1,s1,a0
    80003408:	0504a983          	lw	s3,80(s1)
    8000340c:	fe0990e3          	bnez	s3,800033ec <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003410:	4108                	lw	a0,0(a0)
    80003412:	00000097          	auipc	ra,0x0
    80003416:	e4a080e7          	jalr	-438(ra) # 8000325c <balloc>
    8000341a:	0005099b          	sext.w	s3,a0
    8000341e:	0534a823          	sw	s3,80(s1)
    80003422:	b7e9                	j	800033ec <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003424:	4108                	lw	a0,0(a0)
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	e36080e7          	jalr	-458(ra) # 8000325c <balloc>
    8000342e:	0005059b          	sext.w	a1,a0
    80003432:	08b92023          	sw	a1,128(s2)
    80003436:	b759                	j	800033bc <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003438:	00092503          	lw	a0,0(s2)
    8000343c:	00000097          	auipc	ra,0x0
    80003440:	e20080e7          	jalr	-480(ra) # 8000325c <balloc>
    80003444:	0005099b          	sext.w	s3,a0
    80003448:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000344c:	8552                	mv	a0,s4
    8000344e:	00001097          	auipc	ra,0x1
    80003452:	ee0080e7          	jalr	-288(ra) # 8000432e <log_write>
    80003456:	b771                	j	800033e2 <bmap+0x54>
  panic("bmap: out of range");
    80003458:	00005517          	auipc	a0,0x5
    8000345c:	11050513          	addi	a0,a0,272 # 80008568 <syscalls+0x128>
    80003460:	ffffd097          	auipc	ra,0xffffd
    80003464:	176080e7          	jalr	374(ra) # 800005d6 <panic>

0000000080003468 <iget>:
{
    80003468:	7179                	addi	sp,sp,-48
    8000346a:	f406                	sd	ra,40(sp)
    8000346c:	f022                	sd	s0,32(sp)
    8000346e:	ec26                	sd	s1,24(sp)
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	e44e                	sd	s3,8(sp)
    80003474:	e052                	sd	s4,0(sp)
    80003476:	1800                	addi	s0,sp,48
    80003478:	89aa                	mv	s3,a0
    8000347a:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000347c:	0001d517          	auipc	a0,0x1d
    80003480:	1e450513          	addi	a0,a0,484 # 80020660 <icache>
    80003484:	ffffd097          	auipc	ra,0xffffd
    80003488:	7f0080e7          	jalr	2032(ra) # 80000c74 <acquire>
  empty = 0;
    8000348c:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000348e:	0001d497          	auipc	s1,0x1d
    80003492:	1ea48493          	addi	s1,s1,490 # 80020678 <icache+0x18>
    80003496:	0001f697          	auipc	a3,0x1f
    8000349a:	c7268693          	addi	a3,a3,-910 # 80022108 <log>
    8000349e:	a039                	j	800034ac <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034a0:	02090b63          	beqz	s2,800034d6 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800034a4:	08848493          	addi	s1,s1,136
    800034a8:	02d48a63          	beq	s1,a3,800034dc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034ac:	449c                	lw	a5,8(s1)
    800034ae:	fef059e3          	blez	a5,800034a0 <iget+0x38>
    800034b2:	4098                	lw	a4,0(s1)
    800034b4:	ff3716e3          	bne	a4,s3,800034a0 <iget+0x38>
    800034b8:	40d8                	lw	a4,4(s1)
    800034ba:	ff4713e3          	bne	a4,s4,800034a0 <iget+0x38>
      ip->ref++;
    800034be:	2785                	addiw	a5,a5,1
    800034c0:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800034c2:	0001d517          	auipc	a0,0x1d
    800034c6:	19e50513          	addi	a0,a0,414 # 80020660 <icache>
    800034ca:	ffffe097          	auipc	ra,0xffffe
    800034ce:	85e080e7          	jalr	-1954(ra) # 80000d28 <release>
      return ip;
    800034d2:	8926                	mv	s2,s1
    800034d4:	a03d                	j	80003502 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034d6:	f7f9                	bnez	a5,800034a4 <iget+0x3c>
    800034d8:	8926                	mv	s2,s1
    800034da:	b7e9                	j	800034a4 <iget+0x3c>
  if(empty == 0)
    800034dc:	02090c63          	beqz	s2,80003514 <iget+0xac>
  ip->dev = dev;
    800034e0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034e4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034e8:	4785                	li	a5,1
    800034ea:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034ee:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800034f2:	0001d517          	auipc	a0,0x1d
    800034f6:	16e50513          	addi	a0,a0,366 # 80020660 <icache>
    800034fa:	ffffe097          	auipc	ra,0xffffe
    800034fe:	82e080e7          	jalr	-2002(ra) # 80000d28 <release>
}
    80003502:	854a                	mv	a0,s2
    80003504:	70a2                	ld	ra,40(sp)
    80003506:	7402                	ld	s0,32(sp)
    80003508:	64e2                	ld	s1,24(sp)
    8000350a:	6942                	ld	s2,16(sp)
    8000350c:	69a2                	ld	s3,8(sp)
    8000350e:	6a02                	ld	s4,0(sp)
    80003510:	6145                	addi	sp,sp,48
    80003512:	8082                	ret
    panic("iget: no inodes");
    80003514:	00005517          	auipc	a0,0x5
    80003518:	06c50513          	addi	a0,a0,108 # 80008580 <syscalls+0x140>
    8000351c:	ffffd097          	auipc	ra,0xffffd
    80003520:	0ba080e7          	jalr	186(ra) # 800005d6 <panic>

0000000080003524 <fsinit>:
fsinit(int dev) {
    80003524:	7179                	addi	sp,sp,-48
    80003526:	f406                	sd	ra,40(sp)
    80003528:	f022                	sd	s0,32(sp)
    8000352a:	ec26                	sd	s1,24(sp)
    8000352c:	e84a                	sd	s2,16(sp)
    8000352e:	e44e                	sd	s3,8(sp)
    80003530:	1800                	addi	s0,sp,48
    80003532:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003534:	4585                	li	a1,1
    80003536:	00000097          	auipc	ra,0x0
    8000353a:	a64080e7          	jalr	-1436(ra) # 80002f9a <bread>
    8000353e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003540:	0001d997          	auipc	s3,0x1d
    80003544:	10098993          	addi	s3,s3,256 # 80020640 <sb>
    80003548:	02000613          	li	a2,32
    8000354c:	05850593          	addi	a1,a0,88
    80003550:	854e                	mv	a0,s3
    80003552:	ffffe097          	auipc	ra,0xffffe
    80003556:	87e080e7          	jalr	-1922(ra) # 80000dd0 <memmove>
  brelse(bp);
    8000355a:	8526                	mv	a0,s1
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	b6e080e7          	jalr	-1170(ra) # 800030ca <brelse>
  if(sb.magic != FSMAGIC)
    80003564:	0009a703          	lw	a4,0(s3)
    80003568:	102037b7          	lui	a5,0x10203
    8000356c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003570:	02f71263          	bne	a4,a5,80003594 <fsinit+0x70>
  initlog(dev, &sb);
    80003574:	0001d597          	auipc	a1,0x1d
    80003578:	0cc58593          	addi	a1,a1,204 # 80020640 <sb>
    8000357c:	854a                	mv	a0,s2
    8000357e:	00001097          	auipc	ra,0x1
    80003582:	b38080e7          	jalr	-1224(ra) # 800040b6 <initlog>
}
    80003586:	70a2                	ld	ra,40(sp)
    80003588:	7402                	ld	s0,32(sp)
    8000358a:	64e2                	ld	s1,24(sp)
    8000358c:	6942                	ld	s2,16(sp)
    8000358e:	69a2                	ld	s3,8(sp)
    80003590:	6145                	addi	sp,sp,48
    80003592:	8082                	ret
    panic("invalid file system");
    80003594:	00005517          	auipc	a0,0x5
    80003598:	ffc50513          	addi	a0,a0,-4 # 80008590 <syscalls+0x150>
    8000359c:	ffffd097          	auipc	ra,0xffffd
    800035a0:	03a080e7          	jalr	58(ra) # 800005d6 <panic>

00000000800035a4 <iinit>:
{
    800035a4:	7179                	addi	sp,sp,-48
    800035a6:	f406                	sd	ra,40(sp)
    800035a8:	f022                	sd	s0,32(sp)
    800035aa:	ec26                	sd	s1,24(sp)
    800035ac:	e84a                	sd	s2,16(sp)
    800035ae:	e44e                	sd	s3,8(sp)
    800035b0:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800035b2:	00005597          	auipc	a1,0x5
    800035b6:	ff658593          	addi	a1,a1,-10 # 800085a8 <syscalls+0x168>
    800035ba:	0001d517          	auipc	a0,0x1d
    800035be:	0a650513          	addi	a0,a0,166 # 80020660 <icache>
    800035c2:	ffffd097          	auipc	ra,0xffffd
    800035c6:	622080e7          	jalr	1570(ra) # 80000be4 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035ca:	0001d497          	auipc	s1,0x1d
    800035ce:	0be48493          	addi	s1,s1,190 # 80020688 <icache+0x28>
    800035d2:	0001f997          	auipc	s3,0x1f
    800035d6:	b4698993          	addi	s3,s3,-1210 # 80022118 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800035da:	00005917          	auipc	s2,0x5
    800035de:	fd690913          	addi	s2,s2,-42 # 800085b0 <syscalls+0x170>
    800035e2:	85ca                	mv	a1,s2
    800035e4:	8526                	mv	a0,s1
    800035e6:	00001097          	auipc	ra,0x1
    800035ea:	e36080e7          	jalr	-458(ra) # 8000441c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035ee:	08848493          	addi	s1,s1,136
    800035f2:	ff3498e3          	bne	s1,s3,800035e2 <iinit+0x3e>
}
    800035f6:	70a2                	ld	ra,40(sp)
    800035f8:	7402                	ld	s0,32(sp)
    800035fa:	64e2                	ld	s1,24(sp)
    800035fc:	6942                	ld	s2,16(sp)
    800035fe:	69a2                	ld	s3,8(sp)
    80003600:	6145                	addi	sp,sp,48
    80003602:	8082                	ret

0000000080003604 <ialloc>:
{
    80003604:	715d                	addi	sp,sp,-80
    80003606:	e486                	sd	ra,72(sp)
    80003608:	e0a2                	sd	s0,64(sp)
    8000360a:	fc26                	sd	s1,56(sp)
    8000360c:	f84a                	sd	s2,48(sp)
    8000360e:	f44e                	sd	s3,40(sp)
    80003610:	f052                	sd	s4,32(sp)
    80003612:	ec56                	sd	s5,24(sp)
    80003614:	e85a                	sd	s6,16(sp)
    80003616:	e45e                	sd	s7,8(sp)
    80003618:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000361a:	0001d717          	auipc	a4,0x1d
    8000361e:	03272703          	lw	a4,50(a4) # 8002064c <sb+0xc>
    80003622:	4785                	li	a5,1
    80003624:	04e7fa63          	bgeu	a5,a4,80003678 <ialloc+0x74>
    80003628:	8aaa                	mv	s5,a0
    8000362a:	8bae                	mv	s7,a1
    8000362c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000362e:	0001da17          	auipc	s4,0x1d
    80003632:	012a0a13          	addi	s4,s4,18 # 80020640 <sb>
    80003636:	00048b1b          	sext.w	s6,s1
    8000363a:	0044d593          	srli	a1,s1,0x4
    8000363e:	018a2783          	lw	a5,24(s4)
    80003642:	9dbd                	addw	a1,a1,a5
    80003644:	8556                	mv	a0,s5
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	954080e7          	jalr	-1708(ra) # 80002f9a <bread>
    8000364e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003650:	05850993          	addi	s3,a0,88
    80003654:	00f4f793          	andi	a5,s1,15
    80003658:	079a                	slli	a5,a5,0x6
    8000365a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000365c:	00099783          	lh	a5,0(s3)
    80003660:	c785                	beqz	a5,80003688 <ialloc+0x84>
    brelse(bp);
    80003662:	00000097          	auipc	ra,0x0
    80003666:	a68080e7          	jalr	-1432(ra) # 800030ca <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000366a:	0485                	addi	s1,s1,1
    8000366c:	00ca2703          	lw	a4,12(s4)
    80003670:	0004879b          	sext.w	a5,s1
    80003674:	fce7e1e3          	bltu	a5,a4,80003636 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003678:	00005517          	auipc	a0,0x5
    8000367c:	f4050513          	addi	a0,a0,-192 # 800085b8 <syscalls+0x178>
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	f56080e7          	jalr	-170(ra) # 800005d6 <panic>
      memset(dip, 0, sizeof(*dip));
    80003688:	04000613          	li	a2,64
    8000368c:	4581                	li	a1,0
    8000368e:	854e                	mv	a0,s3
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	6e0080e7          	jalr	1760(ra) # 80000d70 <memset>
      dip->type = type;
    80003698:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000369c:	854a                	mv	a0,s2
    8000369e:	00001097          	auipc	ra,0x1
    800036a2:	c90080e7          	jalr	-880(ra) # 8000432e <log_write>
      brelse(bp);
    800036a6:	854a                	mv	a0,s2
    800036a8:	00000097          	auipc	ra,0x0
    800036ac:	a22080e7          	jalr	-1502(ra) # 800030ca <brelse>
      return iget(dev, inum);
    800036b0:	85da                	mv	a1,s6
    800036b2:	8556                	mv	a0,s5
    800036b4:	00000097          	auipc	ra,0x0
    800036b8:	db4080e7          	jalr	-588(ra) # 80003468 <iget>
}
    800036bc:	60a6                	ld	ra,72(sp)
    800036be:	6406                	ld	s0,64(sp)
    800036c0:	74e2                	ld	s1,56(sp)
    800036c2:	7942                	ld	s2,48(sp)
    800036c4:	79a2                	ld	s3,40(sp)
    800036c6:	7a02                	ld	s4,32(sp)
    800036c8:	6ae2                	ld	s5,24(sp)
    800036ca:	6b42                	ld	s6,16(sp)
    800036cc:	6ba2                	ld	s7,8(sp)
    800036ce:	6161                	addi	sp,sp,80
    800036d0:	8082                	ret

00000000800036d2 <iupdate>:
{
    800036d2:	1101                	addi	sp,sp,-32
    800036d4:	ec06                	sd	ra,24(sp)
    800036d6:	e822                	sd	s0,16(sp)
    800036d8:	e426                	sd	s1,8(sp)
    800036da:	e04a                	sd	s2,0(sp)
    800036dc:	1000                	addi	s0,sp,32
    800036de:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036e0:	415c                	lw	a5,4(a0)
    800036e2:	0047d79b          	srliw	a5,a5,0x4
    800036e6:	0001d597          	auipc	a1,0x1d
    800036ea:	f725a583          	lw	a1,-142(a1) # 80020658 <sb+0x18>
    800036ee:	9dbd                	addw	a1,a1,a5
    800036f0:	4108                	lw	a0,0(a0)
    800036f2:	00000097          	auipc	ra,0x0
    800036f6:	8a8080e7          	jalr	-1880(ra) # 80002f9a <bread>
    800036fa:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036fc:	05850793          	addi	a5,a0,88
    80003700:	40c8                	lw	a0,4(s1)
    80003702:	893d                	andi	a0,a0,15
    80003704:	051a                	slli	a0,a0,0x6
    80003706:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003708:	04449703          	lh	a4,68(s1)
    8000370c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003710:	04649703          	lh	a4,70(s1)
    80003714:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003718:	04849703          	lh	a4,72(s1)
    8000371c:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003720:	04a49703          	lh	a4,74(s1)
    80003724:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003728:	44f8                	lw	a4,76(s1)
    8000372a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000372c:	03400613          	li	a2,52
    80003730:	05048593          	addi	a1,s1,80
    80003734:	0531                	addi	a0,a0,12
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	69a080e7          	jalr	1690(ra) # 80000dd0 <memmove>
  log_write(bp);
    8000373e:	854a                	mv	a0,s2
    80003740:	00001097          	auipc	ra,0x1
    80003744:	bee080e7          	jalr	-1042(ra) # 8000432e <log_write>
  brelse(bp);
    80003748:	854a                	mv	a0,s2
    8000374a:	00000097          	auipc	ra,0x0
    8000374e:	980080e7          	jalr	-1664(ra) # 800030ca <brelse>
}
    80003752:	60e2                	ld	ra,24(sp)
    80003754:	6442                	ld	s0,16(sp)
    80003756:	64a2                	ld	s1,8(sp)
    80003758:	6902                	ld	s2,0(sp)
    8000375a:	6105                	addi	sp,sp,32
    8000375c:	8082                	ret

000000008000375e <idup>:
{
    8000375e:	1101                	addi	sp,sp,-32
    80003760:	ec06                	sd	ra,24(sp)
    80003762:	e822                	sd	s0,16(sp)
    80003764:	e426                	sd	s1,8(sp)
    80003766:	1000                	addi	s0,sp,32
    80003768:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000376a:	0001d517          	auipc	a0,0x1d
    8000376e:	ef650513          	addi	a0,a0,-266 # 80020660 <icache>
    80003772:	ffffd097          	auipc	ra,0xffffd
    80003776:	502080e7          	jalr	1282(ra) # 80000c74 <acquire>
  ip->ref++;
    8000377a:	449c                	lw	a5,8(s1)
    8000377c:	2785                	addiw	a5,a5,1
    8000377e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003780:	0001d517          	auipc	a0,0x1d
    80003784:	ee050513          	addi	a0,a0,-288 # 80020660 <icache>
    80003788:	ffffd097          	auipc	ra,0xffffd
    8000378c:	5a0080e7          	jalr	1440(ra) # 80000d28 <release>
}
    80003790:	8526                	mv	a0,s1
    80003792:	60e2                	ld	ra,24(sp)
    80003794:	6442                	ld	s0,16(sp)
    80003796:	64a2                	ld	s1,8(sp)
    80003798:	6105                	addi	sp,sp,32
    8000379a:	8082                	ret

000000008000379c <ilock>:
{
    8000379c:	1101                	addi	sp,sp,-32
    8000379e:	ec06                	sd	ra,24(sp)
    800037a0:	e822                	sd	s0,16(sp)
    800037a2:	e426                	sd	s1,8(sp)
    800037a4:	e04a                	sd	s2,0(sp)
    800037a6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037a8:	c115                	beqz	a0,800037cc <ilock+0x30>
    800037aa:	84aa                	mv	s1,a0
    800037ac:	451c                	lw	a5,8(a0)
    800037ae:	00f05f63          	blez	a5,800037cc <ilock+0x30>
  acquiresleep(&ip->lock);
    800037b2:	0541                	addi	a0,a0,16
    800037b4:	00001097          	auipc	ra,0x1
    800037b8:	ca2080e7          	jalr	-862(ra) # 80004456 <acquiresleep>
  if(ip->valid == 0){
    800037bc:	40bc                	lw	a5,64(s1)
    800037be:	cf99                	beqz	a5,800037dc <ilock+0x40>
}
    800037c0:	60e2                	ld	ra,24(sp)
    800037c2:	6442                	ld	s0,16(sp)
    800037c4:	64a2                	ld	s1,8(sp)
    800037c6:	6902                	ld	s2,0(sp)
    800037c8:	6105                	addi	sp,sp,32
    800037ca:	8082                	ret
    panic("ilock");
    800037cc:	00005517          	auipc	a0,0x5
    800037d0:	e0450513          	addi	a0,a0,-508 # 800085d0 <syscalls+0x190>
    800037d4:	ffffd097          	auipc	ra,0xffffd
    800037d8:	e02080e7          	jalr	-510(ra) # 800005d6 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037dc:	40dc                	lw	a5,4(s1)
    800037de:	0047d79b          	srliw	a5,a5,0x4
    800037e2:	0001d597          	auipc	a1,0x1d
    800037e6:	e765a583          	lw	a1,-394(a1) # 80020658 <sb+0x18>
    800037ea:	9dbd                	addw	a1,a1,a5
    800037ec:	4088                	lw	a0,0(s1)
    800037ee:	fffff097          	auipc	ra,0xfffff
    800037f2:	7ac080e7          	jalr	1964(ra) # 80002f9a <bread>
    800037f6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037f8:	05850593          	addi	a1,a0,88
    800037fc:	40dc                	lw	a5,4(s1)
    800037fe:	8bbd                	andi	a5,a5,15
    80003800:	079a                	slli	a5,a5,0x6
    80003802:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003804:	00059783          	lh	a5,0(a1)
    80003808:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000380c:	00259783          	lh	a5,2(a1)
    80003810:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003814:	00459783          	lh	a5,4(a1)
    80003818:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000381c:	00659783          	lh	a5,6(a1)
    80003820:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003824:	459c                	lw	a5,8(a1)
    80003826:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003828:	03400613          	li	a2,52
    8000382c:	05b1                	addi	a1,a1,12
    8000382e:	05048513          	addi	a0,s1,80
    80003832:	ffffd097          	auipc	ra,0xffffd
    80003836:	59e080e7          	jalr	1438(ra) # 80000dd0 <memmove>
    brelse(bp);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	88e080e7          	jalr	-1906(ra) # 800030ca <brelse>
    ip->valid = 1;
    80003844:	4785                	li	a5,1
    80003846:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003848:	04449783          	lh	a5,68(s1)
    8000384c:	fbb5                	bnez	a5,800037c0 <ilock+0x24>
      panic("ilock: no type");
    8000384e:	00005517          	auipc	a0,0x5
    80003852:	d8a50513          	addi	a0,a0,-630 # 800085d8 <syscalls+0x198>
    80003856:	ffffd097          	auipc	ra,0xffffd
    8000385a:	d80080e7          	jalr	-640(ra) # 800005d6 <panic>

000000008000385e <iunlock>:
{
    8000385e:	1101                	addi	sp,sp,-32
    80003860:	ec06                	sd	ra,24(sp)
    80003862:	e822                	sd	s0,16(sp)
    80003864:	e426                	sd	s1,8(sp)
    80003866:	e04a                	sd	s2,0(sp)
    80003868:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000386a:	c905                	beqz	a0,8000389a <iunlock+0x3c>
    8000386c:	84aa                	mv	s1,a0
    8000386e:	01050913          	addi	s2,a0,16
    80003872:	854a                	mv	a0,s2
    80003874:	00001097          	auipc	ra,0x1
    80003878:	c7c080e7          	jalr	-900(ra) # 800044f0 <holdingsleep>
    8000387c:	cd19                	beqz	a0,8000389a <iunlock+0x3c>
    8000387e:	449c                	lw	a5,8(s1)
    80003880:	00f05d63          	blez	a5,8000389a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003884:	854a                	mv	a0,s2
    80003886:	00001097          	auipc	ra,0x1
    8000388a:	c26080e7          	jalr	-986(ra) # 800044ac <releasesleep>
}
    8000388e:	60e2                	ld	ra,24(sp)
    80003890:	6442                	ld	s0,16(sp)
    80003892:	64a2                	ld	s1,8(sp)
    80003894:	6902                	ld	s2,0(sp)
    80003896:	6105                	addi	sp,sp,32
    80003898:	8082                	ret
    panic("iunlock");
    8000389a:	00005517          	auipc	a0,0x5
    8000389e:	d4e50513          	addi	a0,a0,-690 # 800085e8 <syscalls+0x1a8>
    800038a2:	ffffd097          	auipc	ra,0xffffd
    800038a6:	d34080e7          	jalr	-716(ra) # 800005d6 <panic>

00000000800038aa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038aa:	7179                	addi	sp,sp,-48
    800038ac:	f406                	sd	ra,40(sp)
    800038ae:	f022                	sd	s0,32(sp)
    800038b0:	ec26                	sd	s1,24(sp)
    800038b2:	e84a                	sd	s2,16(sp)
    800038b4:	e44e                	sd	s3,8(sp)
    800038b6:	e052                	sd	s4,0(sp)
    800038b8:	1800                	addi	s0,sp,48
    800038ba:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038bc:	05050493          	addi	s1,a0,80
    800038c0:	08050913          	addi	s2,a0,128
    800038c4:	a021                	j	800038cc <itrunc+0x22>
    800038c6:	0491                	addi	s1,s1,4
    800038c8:	01248d63          	beq	s1,s2,800038e2 <itrunc+0x38>
    if(ip->addrs[i]){
    800038cc:	408c                	lw	a1,0(s1)
    800038ce:	dde5                	beqz	a1,800038c6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038d0:	0009a503          	lw	a0,0(s3)
    800038d4:	00000097          	auipc	ra,0x0
    800038d8:	90c080e7          	jalr	-1780(ra) # 800031e0 <bfree>
      ip->addrs[i] = 0;
    800038dc:	0004a023          	sw	zero,0(s1)
    800038e0:	b7dd                	j	800038c6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038e2:	0809a583          	lw	a1,128(s3)
    800038e6:	e185                	bnez	a1,80003906 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038e8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038ec:	854e                	mv	a0,s3
    800038ee:	00000097          	auipc	ra,0x0
    800038f2:	de4080e7          	jalr	-540(ra) # 800036d2 <iupdate>
}
    800038f6:	70a2                	ld	ra,40(sp)
    800038f8:	7402                	ld	s0,32(sp)
    800038fa:	64e2                	ld	s1,24(sp)
    800038fc:	6942                	ld	s2,16(sp)
    800038fe:	69a2                	ld	s3,8(sp)
    80003900:	6a02                	ld	s4,0(sp)
    80003902:	6145                	addi	sp,sp,48
    80003904:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003906:	0009a503          	lw	a0,0(s3)
    8000390a:	fffff097          	auipc	ra,0xfffff
    8000390e:	690080e7          	jalr	1680(ra) # 80002f9a <bread>
    80003912:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003914:	05850493          	addi	s1,a0,88
    80003918:	45850913          	addi	s2,a0,1112
    8000391c:	a811                	j	80003930 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    8000391e:	0009a503          	lw	a0,0(s3)
    80003922:	00000097          	auipc	ra,0x0
    80003926:	8be080e7          	jalr	-1858(ra) # 800031e0 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000392a:	0491                	addi	s1,s1,4
    8000392c:	01248563          	beq	s1,s2,80003936 <itrunc+0x8c>
      if(a[j])
    80003930:	408c                	lw	a1,0(s1)
    80003932:	dde5                	beqz	a1,8000392a <itrunc+0x80>
    80003934:	b7ed                	j	8000391e <itrunc+0x74>
    brelse(bp);
    80003936:	8552                	mv	a0,s4
    80003938:	fffff097          	auipc	ra,0xfffff
    8000393c:	792080e7          	jalr	1938(ra) # 800030ca <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003940:	0809a583          	lw	a1,128(s3)
    80003944:	0009a503          	lw	a0,0(s3)
    80003948:	00000097          	auipc	ra,0x0
    8000394c:	898080e7          	jalr	-1896(ra) # 800031e0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003950:	0809a023          	sw	zero,128(s3)
    80003954:	bf51                	j	800038e8 <itrunc+0x3e>

0000000080003956 <iput>:
{
    80003956:	1101                	addi	sp,sp,-32
    80003958:	ec06                	sd	ra,24(sp)
    8000395a:	e822                	sd	s0,16(sp)
    8000395c:	e426                	sd	s1,8(sp)
    8000395e:	e04a                	sd	s2,0(sp)
    80003960:	1000                	addi	s0,sp,32
    80003962:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003964:	0001d517          	auipc	a0,0x1d
    80003968:	cfc50513          	addi	a0,a0,-772 # 80020660 <icache>
    8000396c:	ffffd097          	auipc	ra,0xffffd
    80003970:	308080e7          	jalr	776(ra) # 80000c74 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003974:	4498                	lw	a4,8(s1)
    80003976:	4785                	li	a5,1
    80003978:	02f70363          	beq	a4,a5,8000399e <iput+0x48>
  ip->ref--;
    8000397c:	449c                	lw	a5,8(s1)
    8000397e:	37fd                	addiw	a5,a5,-1
    80003980:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003982:	0001d517          	auipc	a0,0x1d
    80003986:	cde50513          	addi	a0,a0,-802 # 80020660 <icache>
    8000398a:	ffffd097          	auipc	ra,0xffffd
    8000398e:	39e080e7          	jalr	926(ra) # 80000d28 <release>
}
    80003992:	60e2                	ld	ra,24(sp)
    80003994:	6442                	ld	s0,16(sp)
    80003996:	64a2                	ld	s1,8(sp)
    80003998:	6902                	ld	s2,0(sp)
    8000399a:	6105                	addi	sp,sp,32
    8000399c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000399e:	40bc                	lw	a5,64(s1)
    800039a0:	dff1                	beqz	a5,8000397c <iput+0x26>
    800039a2:	04a49783          	lh	a5,74(s1)
    800039a6:	fbf9                	bnez	a5,8000397c <iput+0x26>
    acquiresleep(&ip->lock);
    800039a8:	01048913          	addi	s2,s1,16
    800039ac:	854a                	mv	a0,s2
    800039ae:	00001097          	auipc	ra,0x1
    800039b2:	aa8080e7          	jalr	-1368(ra) # 80004456 <acquiresleep>
    release(&icache.lock);
    800039b6:	0001d517          	auipc	a0,0x1d
    800039ba:	caa50513          	addi	a0,a0,-854 # 80020660 <icache>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	36a080e7          	jalr	874(ra) # 80000d28 <release>
    itrunc(ip);
    800039c6:	8526                	mv	a0,s1
    800039c8:	00000097          	auipc	ra,0x0
    800039cc:	ee2080e7          	jalr	-286(ra) # 800038aa <itrunc>
    ip->type = 0;
    800039d0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039d4:	8526                	mv	a0,s1
    800039d6:	00000097          	auipc	ra,0x0
    800039da:	cfc080e7          	jalr	-772(ra) # 800036d2 <iupdate>
    ip->valid = 0;
    800039de:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039e2:	854a                	mv	a0,s2
    800039e4:	00001097          	auipc	ra,0x1
    800039e8:	ac8080e7          	jalr	-1336(ra) # 800044ac <releasesleep>
    acquire(&icache.lock);
    800039ec:	0001d517          	auipc	a0,0x1d
    800039f0:	c7450513          	addi	a0,a0,-908 # 80020660 <icache>
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	280080e7          	jalr	640(ra) # 80000c74 <acquire>
    800039fc:	b741                	j	8000397c <iput+0x26>

00000000800039fe <iunlockput>:
{
    800039fe:	1101                	addi	sp,sp,-32
    80003a00:	ec06                	sd	ra,24(sp)
    80003a02:	e822                	sd	s0,16(sp)
    80003a04:	e426                	sd	s1,8(sp)
    80003a06:	1000                	addi	s0,sp,32
    80003a08:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a0a:	00000097          	auipc	ra,0x0
    80003a0e:	e54080e7          	jalr	-428(ra) # 8000385e <iunlock>
  iput(ip);
    80003a12:	8526                	mv	a0,s1
    80003a14:	00000097          	auipc	ra,0x0
    80003a18:	f42080e7          	jalr	-190(ra) # 80003956 <iput>
}
    80003a1c:	60e2                	ld	ra,24(sp)
    80003a1e:	6442                	ld	s0,16(sp)
    80003a20:	64a2                	ld	s1,8(sp)
    80003a22:	6105                	addi	sp,sp,32
    80003a24:	8082                	ret

0000000080003a26 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a26:	1141                	addi	sp,sp,-16
    80003a28:	e422                	sd	s0,8(sp)
    80003a2a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a2c:	411c                	lw	a5,0(a0)
    80003a2e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a30:	415c                	lw	a5,4(a0)
    80003a32:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a34:	04451783          	lh	a5,68(a0)
    80003a38:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a3c:	04a51783          	lh	a5,74(a0)
    80003a40:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a44:	04c56783          	lwu	a5,76(a0)
    80003a48:	e99c                	sd	a5,16(a1)
}
    80003a4a:	6422                	ld	s0,8(sp)
    80003a4c:	0141                	addi	sp,sp,16
    80003a4e:	8082                	ret

0000000080003a50 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a50:	457c                	lw	a5,76(a0)
    80003a52:	0ed7e863          	bltu	a5,a3,80003b42 <readi+0xf2>
{
    80003a56:	7159                	addi	sp,sp,-112
    80003a58:	f486                	sd	ra,104(sp)
    80003a5a:	f0a2                	sd	s0,96(sp)
    80003a5c:	eca6                	sd	s1,88(sp)
    80003a5e:	e8ca                	sd	s2,80(sp)
    80003a60:	e4ce                	sd	s3,72(sp)
    80003a62:	e0d2                	sd	s4,64(sp)
    80003a64:	fc56                	sd	s5,56(sp)
    80003a66:	f85a                	sd	s6,48(sp)
    80003a68:	f45e                	sd	s7,40(sp)
    80003a6a:	f062                	sd	s8,32(sp)
    80003a6c:	ec66                	sd	s9,24(sp)
    80003a6e:	e86a                	sd	s10,16(sp)
    80003a70:	e46e                	sd	s11,8(sp)
    80003a72:	1880                	addi	s0,sp,112
    80003a74:	8baa                	mv	s7,a0
    80003a76:	8c2e                	mv	s8,a1
    80003a78:	8ab2                	mv	s5,a2
    80003a7a:	84b6                	mv	s1,a3
    80003a7c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a7e:	9f35                	addw	a4,a4,a3
    return 0;
    80003a80:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a82:	08d76f63          	bltu	a4,a3,80003b20 <readi+0xd0>
  if(off + n > ip->size)
    80003a86:	00e7f463          	bgeu	a5,a4,80003a8e <readi+0x3e>
    n = ip->size - off;
    80003a8a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a8e:	0a0b0863          	beqz	s6,80003b3e <readi+0xee>
    80003a92:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a94:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a98:	5cfd                	li	s9,-1
    80003a9a:	a82d                	j	80003ad4 <readi+0x84>
    80003a9c:	020a1d93          	slli	s11,s4,0x20
    80003aa0:	020ddd93          	srli	s11,s11,0x20
    80003aa4:	05890613          	addi	a2,s2,88
    80003aa8:	86ee                	mv	a3,s11
    80003aaa:	963a                	add	a2,a2,a4
    80003aac:	85d6                	mv	a1,s5
    80003aae:	8562                	mv	a0,s8
    80003ab0:	fffff097          	auipc	ra,0xfffff
    80003ab4:	a34080e7          	jalr	-1484(ra) # 800024e4 <either_copyout>
    80003ab8:	05950d63          	beq	a0,s9,80003b12 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003abc:	854a                	mv	a0,s2
    80003abe:	fffff097          	auipc	ra,0xfffff
    80003ac2:	60c080e7          	jalr	1548(ra) # 800030ca <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ac6:	013a09bb          	addw	s3,s4,s3
    80003aca:	009a04bb          	addw	s1,s4,s1
    80003ace:	9aee                	add	s5,s5,s11
    80003ad0:	0569f663          	bgeu	s3,s6,80003b1c <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ad4:	000ba903          	lw	s2,0(s7)
    80003ad8:	00a4d59b          	srliw	a1,s1,0xa
    80003adc:	855e                	mv	a0,s7
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	8b0080e7          	jalr	-1872(ra) # 8000338e <bmap>
    80003ae6:	0005059b          	sext.w	a1,a0
    80003aea:	854a                	mv	a0,s2
    80003aec:	fffff097          	auipc	ra,0xfffff
    80003af0:	4ae080e7          	jalr	1198(ra) # 80002f9a <bread>
    80003af4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003af6:	3ff4f713          	andi	a4,s1,1023
    80003afa:	40ed07bb          	subw	a5,s10,a4
    80003afe:	413b06bb          	subw	a3,s6,s3
    80003b02:	8a3e                	mv	s4,a5
    80003b04:	2781                	sext.w	a5,a5
    80003b06:	0006861b          	sext.w	a2,a3
    80003b0a:	f8f679e3          	bgeu	a2,a5,80003a9c <readi+0x4c>
    80003b0e:	8a36                	mv	s4,a3
    80003b10:	b771                	j	80003a9c <readi+0x4c>
      brelse(bp);
    80003b12:	854a                	mv	a0,s2
    80003b14:	fffff097          	auipc	ra,0xfffff
    80003b18:	5b6080e7          	jalr	1462(ra) # 800030ca <brelse>
  }
  return tot;
    80003b1c:	0009851b          	sext.w	a0,s3
}
    80003b20:	70a6                	ld	ra,104(sp)
    80003b22:	7406                	ld	s0,96(sp)
    80003b24:	64e6                	ld	s1,88(sp)
    80003b26:	6946                	ld	s2,80(sp)
    80003b28:	69a6                	ld	s3,72(sp)
    80003b2a:	6a06                	ld	s4,64(sp)
    80003b2c:	7ae2                	ld	s5,56(sp)
    80003b2e:	7b42                	ld	s6,48(sp)
    80003b30:	7ba2                	ld	s7,40(sp)
    80003b32:	7c02                	ld	s8,32(sp)
    80003b34:	6ce2                	ld	s9,24(sp)
    80003b36:	6d42                	ld	s10,16(sp)
    80003b38:	6da2                	ld	s11,8(sp)
    80003b3a:	6165                	addi	sp,sp,112
    80003b3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b3e:	89da                	mv	s3,s6
    80003b40:	bff1                	j	80003b1c <readi+0xcc>
    return 0;
    80003b42:	4501                	li	a0,0
}
    80003b44:	8082                	ret

0000000080003b46 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b46:	457c                	lw	a5,76(a0)
    80003b48:	10d7e663          	bltu	a5,a3,80003c54 <writei+0x10e>
{
    80003b4c:	7159                	addi	sp,sp,-112
    80003b4e:	f486                	sd	ra,104(sp)
    80003b50:	f0a2                	sd	s0,96(sp)
    80003b52:	eca6                	sd	s1,88(sp)
    80003b54:	e8ca                	sd	s2,80(sp)
    80003b56:	e4ce                	sd	s3,72(sp)
    80003b58:	e0d2                	sd	s4,64(sp)
    80003b5a:	fc56                	sd	s5,56(sp)
    80003b5c:	f85a                	sd	s6,48(sp)
    80003b5e:	f45e                	sd	s7,40(sp)
    80003b60:	f062                	sd	s8,32(sp)
    80003b62:	ec66                	sd	s9,24(sp)
    80003b64:	e86a                	sd	s10,16(sp)
    80003b66:	e46e                	sd	s11,8(sp)
    80003b68:	1880                	addi	s0,sp,112
    80003b6a:	8baa                	mv	s7,a0
    80003b6c:	8c2e                	mv	s8,a1
    80003b6e:	8ab2                	mv	s5,a2
    80003b70:	8936                	mv	s2,a3
    80003b72:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b74:	00e687bb          	addw	a5,a3,a4
    80003b78:	0ed7e063          	bltu	a5,a3,80003c58 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b7c:	00043737          	lui	a4,0x43
    80003b80:	0cf76e63          	bltu	a4,a5,80003c5c <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b84:	0a0b0763          	beqz	s6,80003c32 <writei+0xec>
    80003b88:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b8a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b8e:	5cfd                	li	s9,-1
    80003b90:	a091                	j	80003bd4 <writei+0x8e>
    80003b92:	02099d93          	slli	s11,s3,0x20
    80003b96:	020ddd93          	srli	s11,s11,0x20
    80003b9a:	05848513          	addi	a0,s1,88
    80003b9e:	86ee                	mv	a3,s11
    80003ba0:	8656                	mv	a2,s5
    80003ba2:	85e2                	mv	a1,s8
    80003ba4:	953a                	add	a0,a0,a4
    80003ba6:	fffff097          	auipc	ra,0xfffff
    80003baa:	994080e7          	jalr	-1644(ra) # 8000253a <either_copyin>
    80003bae:	07950263          	beq	a0,s9,80003c12 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bb2:	8526                	mv	a0,s1
    80003bb4:	00000097          	auipc	ra,0x0
    80003bb8:	77a080e7          	jalr	1914(ra) # 8000432e <log_write>
    brelse(bp);
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	fffff097          	auipc	ra,0xfffff
    80003bc2:	50c080e7          	jalr	1292(ra) # 800030ca <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bc6:	01498a3b          	addw	s4,s3,s4
    80003bca:	0129893b          	addw	s2,s3,s2
    80003bce:	9aee                	add	s5,s5,s11
    80003bd0:	056a7663          	bgeu	s4,s6,80003c1c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bd4:	000ba483          	lw	s1,0(s7)
    80003bd8:	00a9559b          	srliw	a1,s2,0xa
    80003bdc:	855e                	mv	a0,s7
    80003bde:	fffff097          	auipc	ra,0xfffff
    80003be2:	7b0080e7          	jalr	1968(ra) # 8000338e <bmap>
    80003be6:	0005059b          	sext.w	a1,a0
    80003bea:	8526                	mv	a0,s1
    80003bec:	fffff097          	auipc	ra,0xfffff
    80003bf0:	3ae080e7          	jalr	942(ra) # 80002f9a <bread>
    80003bf4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf6:	3ff97713          	andi	a4,s2,1023
    80003bfa:	40ed07bb          	subw	a5,s10,a4
    80003bfe:	414b06bb          	subw	a3,s6,s4
    80003c02:	89be                	mv	s3,a5
    80003c04:	2781                	sext.w	a5,a5
    80003c06:	0006861b          	sext.w	a2,a3
    80003c0a:	f8f674e3          	bgeu	a2,a5,80003b92 <writei+0x4c>
    80003c0e:	89b6                	mv	s3,a3
    80003c10:	b749                	j	80003b92 <writei+0x4c>
      brelse(bp);
    80003c12:	8526                	mv	a0,s1
    80003c14:	fffff097          	auipc	ra,0xfffff
    80003c18:	4b6080e7          	jalr	1206(ra) # 800030ca <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003c1c:	04cba783          	lw	a5,76(s7)
    80003c20:	0127f463          	bgeu	a5,s2,80003c28 <writei+0xe2>
      ip->size = off;
    80003c24:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003c28:	855e                	mv	a0,s7
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	aa8080e7          	jalr	-1368(ra) # 800036d2 <iupdate>
  }

  return n;
    80003c32:	000b051b          	sext.w	a0,s6
}
    80003c36:	70a6                	ld	ra,104(sp)
    80003c38:	7406                	ld	s0,96(sp)
    80003c3a:	64e6                	ld	s1,88(sp)
    80003c3c:	6946                	ld	s2,80(sp)
    80003c3e:	69a6                	ld	s3,72(sp)
    80003c40:	6a06                	ld	s4,64(sp)
    80003c42:	7ae2                	ld	s5,56(sp)
    80003c44:	7b42                	ld	s6,48(sp)
    80003c46:	7ba2                	ld	s7,40(sp)
    80003c48:	7c02                	ld	s8,32(sp)
    80003c4a:	6ce2                	ld	s9,24(sp)
    80003c4c:	6d42                	ld	s10,16(sp)
    80003c4e:	6da2                	ld	s11,8(sp)
    80003c50:	6165                	addi	sp,sp,112
    80003c52:	8082                	ret
    return -1;
    80003c54:	557d                	li	a0,-1
}
    80003c56:	8082                	ret
    return -1;
    80003c58:	557d                	li	a0,-1
    80003c5a:	bff1                	j	80003c36 <writei+0xf0>
    return -1;
    80003c5c:	557d                	li	a0,-1
    80003c5e:	bfe1                	j	80003c36 <writei+0xf0>

0000000080003c60 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c60:	1141                	addi	sp,sp,-16
    80003c62:	e406                	sd	ra,8(sp)
    80003c64:	e022                	sd	s0,0(sp)
    80003c66:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c68:	4639                	li	a2,14
    80003c6a:	ffffd097          	auipc	ra,0xffffd
    80003c6e:	1e2080e7          	jalr	482(ra) # 80000e4c <strncmp>
}
    80003c72:	60a2                	ld	ra,8(sp)
    80003c74:	6402                	ld	s0,0(sp)
    80003c76:	0141                	addi	sp,sp,16
    80003c78:	8082                	ret

0000000080003c7a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c7a:	7139                	addi	sp,sp,-64
    80003c7c:	fc06                	sd	ra,56(sp)
    80003c7e:	f822                	sd	s0,48(sp)
    80003c80:	f426                	sd	s1,40(sp)
    80003c82:	f04a                	sd	s2,32(sp)
    80003c84:	ec4e                	sd	s3,24(sp)
    80003c86:	e852                	sd	s4,16(sp)
    80003c88:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c8a:	04451703          	lh	a4,68(a0)
    80003c8e:	4785                	li	a5,1
    80003c90:	00f71a63          	bne	a4,a5,80003ca4 <dirlookup+0x2a>
    80003c94:	892a                	mv	s2,a0
    80003c96:	89ae                	mv	s3,a1
    80003c98:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c9a:	457c                	lw	a5,76(a0)
    80003c9c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c9e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ca0:	e79d                	bnez	a5,80003cce <dirlookup+0x54>
    80003ca2:	a8a5                	j	80003d1a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ca4:	00005517          	auipc	a0,0x5
    80003ca8:	94c50513          	addi	a0,a0,-1716 # 800085f0 <syscalls+0x1b0>
    80003cac:	ffffd097          	auipc	ra,0xffffd
    80003cb0:	92a080e7          	jalr	-1750(ra) # 800005d6 <panic>
      panic("dirlookup read");
    80003cb4:	00005517          	auipc	a0,0x5
    80003cb8:	95450513          	addi	a0,a0,-1708 # 80008608 <syscalls+0x1c8>
    80003cbc:	ffffd097          	auipc	ra,0xffffd
    80003cc0:	91a080e7          	jalr	-1766(ra) # 800005d6 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cc4:	24c1                	addiw	s1,s1,16
    80003cc6:	04c92783          	lw	a5,76(s2)
    80003cca:	04f4f763          	bgeu	s1,a5,80003d18 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cce:	4741                	li	a4,16
    80003cd0:	86a6                	mv	a3,s1
    80003cd2:	fc040613          	addi	a2,s0,-64
    80003cd6:	4581                	li	a1,0
    80003cd8:	854a                	mv	a0,s2
    80003cda:	00000097          	auipc	ra,0x0
    80003cde:	d76080e7          	jalr	-650(ra) # 80003a50 <readi>
    80003ce2:	47c1                	li	a5,16
    80003ce4:	fcf518e3          	bne	a0,a5,80003cb4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003ce8:	fc045783          	lhu	a5,-64(s0)
    80003cec:	dfe1                	beqz	a5,80003cc4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cee:	fc240593          	addi	a1,s0,-62
    80003cf2:	854e                	mv	a0,s3
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	f6c080e7          	jalr	-148(ra) # 80003c60 <namecmp>
    80003cfc:	f561                	bnez	a0,80003cc4 <dirlookup+0x4a>
      if(poff)
    80003cfe:	000a0463          	beqz	s4,80003d06 <dirlookup+0x8c>
        *poff = off;
    80003d02:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d06:	fc045583          	lhu	a1,-64(s0)
    80003d0a:	00092503          	lw	a0,0(s2)
    80003d0e:	fffff097          	auipc	ra,0xfffff
    80003d12:	75a080e7          	jalr	1882(ra) # 80003468 <iget>
    80003d16:	a011                	j	80003d1a <dirlookup+0xa0>
  return 0;
    80003d18:	4501                	li	a0,0
}
    80003d1a:	70e2                	ld	ra,56(sp)
    80003d1c:	7442                	ld	s0,48(sp)
    80003d1e:	74a2                	ld	s1,40(sp)
    80003d20:	7902                	ld	s2,32(sp)
    80003d22:	69e2                	ld	s3,24(sp)
    80003d24:	6a42                	ld	s4,16(sp)
    80003d26:	6121                	addi	sp,sp,64
    80003d28:	8082                	ret

0000000080003d2a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d2a:	711d                	addi	sp,sp,-96
    80003d2c:	ec86                	sd	ra,88(sp)
    80003d2e:	e8a2                	sd	s0,80(sp)
    80003d30:	e4a6                	sd	s1,72(sp)
    80003d32:	e0ca                	sd	s2,64(sp)
    80003d34:	fc4e                	sd	s3,56(sp)
    80003d36:	f852                	sd	s4,48(sp)
    80003d38:	f456                	sd	s5,40(sp)
    80003d3a:	f05a                	sd	s6,32(sp)
    80003d3c:	ec5e                	sd	s7,24(sp)
    80003d3e:	e862                	sd	s8,16(sp)
    80003d40:	e466                	sd	s9,8(sp)
    80003d42:	1080                	addi	s0,sp,96
    80003d44:	84aa                	mv	s1,a0
    80003d46:	8b2e                	mv	s6,a1
    80003d48:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d4a:	00054703          	lbu	a4,0(a0)
    80003d4e:	02f00793          	li	a5,47
    80003d52:	02f70363          	beq	a4,a5,80003d78 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d56:	ffffe097          	auipc	ra,0xffffe
    80003d5a:	cec080e7          	jalr	-788(ra) # 80001a42 <myproc>
    80003d5e:	15053503          	ld	a0,336(a0)
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	9fc080e7          	jalr	-1540(ra) # 8000375e <idup>
    80003d6a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d6c:	02f00913          	li	s2,47
  len = path - s;
    80003d70:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003d72:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d74:	4c05                	li	s8,1
    80003d76:	a865                	j	80003e2e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d78:	4585                	li	a1,1
    80003d7a:	4505                	li	a0,1
    80003d7c:	fffff097          	auipc	ra,0xfffff
    80003d80:	6ec080e7          	jalr	1772(ra) # 80003468 <iget>
    80003d84:	89aa                	mv	s3,a0
    80003d86:	b7dd                	j	80003d6c <namex+0x42>
      iunlockput(ip);
    80003d88:	854e                	mv	a0,s3
    80003d8a:	00000097          	auipc	ra,0x0
    80003d8e:	c74080e7          	jalr	-908(ra) # 800039fe <iunlockput>
      return 0;
    80003d92:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d94:	854e                	mv	a0,s3
    80003d96:	60e6                	ld	ra,88(sp)
    80003d98:	6446                	ld	s0,80(sp)
    80003d9a:	64a6                	ld	s1,72(sp)
    80003d9c:	6906                	ld	s2,64(sp)
    80003d9e:	79e2                	ld	s3,56(sp)
    80003da0:	7a42                	ld	s4,48(sp)
    80003da2:	7aa2                	ld	s5,40(sp)
    80003da4:	7b02                	ld	s6,32(sp)
    80003da6:	6be2                	ld	s7,24(sp)
    80003da8:	6c42                	ld	s8,16(sp)
    80003daa:	6ca2                	ld	s9,8(sp)
    80003dac:	6125                	addi	sp,sp,96
    80003dae:	8082                	ret
      iunlock(ip);
    80003db0:	854e                	mv	a0,s3
    80003db2:	00000097          	auipc	ra,0x0
    80003db6:	aac080e7          	jalr	-1364(ra) # 8000385e <iunlock>
      return ip;
    80003dba:	bfe9                	j	80003d94 <namex+0x6a>
      iunlockput(ip);
    80003dbc:	854e                	mv	a0,s3
    80003dbe:	00000097          	auipc	ra,0x0
    80003dc2:	c40080e7          	jalr	-960(ra) # 800039fe <iunlockput>
      return 0;
    80003dc6:	89d2                	mv	s3,s4
    80003dc8:	b7f1                	j	80003d94 <namex+0x6a>
  len = path - s;
    80003dca:	40b48633          	sub	a2,s1,a1
    80003dce:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003dd2:	094cd463          	bge	s9,s4,80003e5a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003dd6:	4639                	li	a2,14
    80003dd8:	8556                	mv	a0,s5
    80003dda:	ffffd097          	auipc	ra,0xffffd
    80003dde:	ff6080e7          	jalr	-10(ra) # 80000dd0 <memmove>
  while(*path == '/')
    80003de2:	0004c783          	lbu	a5,0(s1)
    80003de6:	01279763          	bne	a5,s2,80003df4 <namex+0xca>
    path++;
    80003dea:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dec:	0004c783          	lbu	a5,0(s1)
    80003df0:	ff278de3          	beq	a5,s2,80003dea <namex+0xc0>
    ilock(ip);
    80003df4:	854e                	mv	a0,s3
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	9a6080e7          	jalr	-1626(ra) # 8000379c <ilock>
    if(ip->type != T_DIR){
    80003dfe:	04499783          	lh	a5,68(s3)
    80003e02:	f98793e3          	bne	a5,s8,80003d88 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003e06:	000b0563          	beqz	s6,80003e10 <namex+0xe6>
    80003e0a:	0004c783          	lbu	a5,0(s1)
    80003e0e:	d3cd                	beqz	a5,80003db0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e10:	865e                	mv	a2,s7
    80003e12:	85d6                	mv	a1,s5
    80003e14:	854e                	mv	a0,s3
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	e64080e7          	jalr	-412(ra) # 80003c7a <dirlookup>
    80003e1e:	8a2a                	mv	s4,a0
    80003e20:	dd51                	beqz	a0,80003dbc <namex+0x92>
    iunlockput(ip);
    80003e22:	854e                	mv	a0,s3
    80003e24:	00000097          	auipc	ra,0x0
    80003e28:	bda080e7          	jalr	-1062(ra) # 800039fe <iunlockput>
    ip = next;
    80003e2c:	89d2                	mv	s3,s4
  while(*path == '/')
    80003e2e:	0004c783          	lbu	a5,0(s1)
    80003e32:	05279763          	bne	a5,s2,80003e80 <namex+0x156>
    path++;
    80003e36:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e38:	0004c783          	lbu	a5,0(s1)
    80003e3c:	ff278de3          	beq	a5,s2,80003e36 <namex+0x10c>
  if(*path == 0)
    80003e40:	c79d                	beqz	a5,80003e6e <namex+0x144>
    path++;
    80003e42:	85a6                	mv	a1,s1
  len = path - s;
    80003e44:	8a5e                	mv	s4,s7
    80003e46:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003e48:	01278963          	beq	a5,s2,80003e5a <namex+0x130>
    80003e4c:	dfbd                	beqz	a5,80003dca <namex+0xa0>
    path++;
    80003e4e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e50:	0004c783          	lbu	a5,0(s1)
    80003e54:	ff279ce3          	bne	a5,s2,80003e4c <namex+0x122>
    80003e58:	bf8d                	j	80003dca <namex+0xa0>
    memmove(name, s, len);
    80003e5a:	2601                	sext.w	a2,a2
    80003e5c:	8556                	mv	a0,s5
    80003e5e:	ffffd097          	auipc	ra,0xffffd
    80003e62:	f72080e7          	jalr	-142(ra) # 80000dd0 <memmove>
    name[len] = 0;
    80003e66:	9a56                	add	s4,s4,s5
    80003e68:	000a0023          	sb	zero,0(s4)
    80003e6c:	bf9d                	j	80003de2 <namex+0xb8>
  if(nameiparent){
    80003e6e:	f20b03e3          	beqz	s6,80003d94 <namex+0x6a>
    iput(ip);
    80003e72:	854e                	mv	a0,s3
    80003e74:	00000097          	auipc	ra,0x0
    80003e78:	ae2080e7          	jalr	-1310(ra) # 80003956 <iput>
    return 0;
    80003e7c:	4981                	li	s3,0
    80003e7e:	bf19                	j	80003d94 <namex+0x6a>
  if(*path == 0)
    80003e80:	d7fd                	beqz	a5,80003e6e <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e82:	0004c783          	lbu	a5,0(s1)
    80003e86:	85a6                	mv	a1,s1
    80003e88:	b7d1                	j	80003e4c <namex+0x122>

0000000080003e8a <dirlink>:
{
    80003e8a:	7139                	addi	sp,sp,-64
    80003e8c:	fc06                	sd	ra,56(sp)
    80003e8e:	f822                	sd	s0,48(sp)
    80003e90:	f426                	sd	s1,40(sp)
    80003e92:	f04a                	sd	s2,32(sp)
    80003e94:	ec4e                	sd	s3,24(sp)
    80003e96:	e852                	sd	s4,16(sp)
    80003e98:	0080                	addi	s0,sp,64
    80003e9a:	892a                	mv	s2,a0
    80003e9c:	8a2e                	mv	s4,a1
    80003e9e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ea0:	4601                	li	a2,0
    80003ea2:	00000097          	auipc	ra,0x0
    80003ea6:	dd8080e7          	jalr	-552(ra) # 80003c7a <dirlookup>
    80003eaa:	e93d                	bnez	a0,80003f20 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eac:	04c92483          	lw	s1,76(s2)
    80003eb0:	c49d                	beqz	s1,80003ede <dirlink+0x54>
    80003eb2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eb4:	4741                	li	a4,16
    80003eb6:	86a6                	mv	a3,s1
    80003eb8:	fc040613          	addi	a2,s0,-64
    80003ebc:	4581                	li	a1,0
    80003ebe:	854a                	mv	a0,s2
    80003ec0:	00000097          	auipc	ra,0x0
    80003ec4:	b90080e7          	jalr	-1136(ra) # 80003a50 <readi>
    80003ec8:	47c1                	li	a5,16
    80003eca:	06f51163          	bne	a0,a5,80003f2c <dirlink+0xa2>
    if(de.inum == 0)
    80003ece:	fc045783          	lhu	a5,-64(s0)
    80003ed2:	c791                	beqz	a5,80003ede <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ed4:	24c1                	addiw	s1,s1,16
    80003ed6:	04c92783          	lw	a5,76(s2)
    80003eda:	fcf4ede3          	bltu	s1,a5,80003eb4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ede:	4639                	li	a2,14
    80003ee0:	85d2                	mv	a1,s4
    80003ee2:	fc240513          	addi	a0,s0,-62
    80003ee6:	ffffd097          	auipc	ra,0xffffd
    80003eea:	fa2080e7          	jalr	-94(ra) # 80000e88 <strncpy>
  de.inum = inum;
    80003eee:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ef2:	4741                	li	a4,16
    80003ef4:	86a6                	mv	a3,s1
    80003ef6:	fc040613          	addi	a2,s0,-64
    80003efa:	4581                	li	a1,0
    80003efc:	854a                	mv	a0,s2
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	c48080e7          	jalr	-952(ra) # 80003b46 <writei>
    80003f06:	872a                	mv	a4,a0
    80003f08:	47c1                	li	a5,16
  return 0;
    80003f0a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f0c:	02f71863          	bne	a4,a5,80003f3c <dirlink+0xb2>
}
    80003f10:	70e2                	ld	ra,56(sp)
    80003f12:	7442                	ld	s0,48(sp)
    80003f14:	74a2                	ld	s1,40(sp)
    80003f16:	7902                	ld	s2,32(sp)
    80003f18:	69e2                	ld	s3,24(sp)
    80003f1a:	6a42                	ld	s4,16(sp)
    80003f1c:	6121                	addi	sp,sp,64
    80003f1e:	8082                	ret
    iput(ip);
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	a36080e7          	jalr	-1482(ra) # 80003956 <iput>
    return -1;
    80003f28:	557d                	li	a0,-1
    80003f2a:	b7dd                	j	80003f10 <dirlink+0x86>
      panic("dirlink read");
    80003f2c:	00004517          	auipc	a0,0x4
    80003f30:	6ec50513          	addi	a0,a0,1772 # 80008618 <syscalls+0x1d8>
    80003f34:	ffffc097          	auipc	ra,0xffffc
    80003f38:	6a2080e7          	jalr	1698(ra) # 800005d6 <panic>
    panic("dirlink");
    80003f3c:	00004517          	auipc	a0,0x4
    80003f40:	7fc50513          	addi	a0,a0,2044 # 80008738 <syscalls+0x2f8>
    80003f44:	ffffc097          	auipc	ra,0xffffc
    80003f48:	692080e7          	jalr	1682(ra) # 800005d6 <panic>

0000000080003f4c <namei>:

struct inode*
namei(char *path)
{
    80003f4c:	1101                	addi	sp,sp,-32
    80003f4e:	ec06                	sd	ra,24(sp)
    80003f50:	e822                	sd	s0,16(sp)
    80003f52:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f54:	fe040613          	addi	a2,s0,-32
    80003f58:	4581                	li	a1,0
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	dd0080e7          	jalr	-560(ra) # 80003d2a <namex>
}
    80003f62:	60e2                	ld	ra,24(sp)
    80003f64:	6442                	ld	s0,16(sp)
    80003f66:	6105                	addi	sp,sp,32
    80003f68:	8082                	ret

0000000080003f6a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f6a:	1141                	addi	sp,sp,-16
    80003f6c:	e406                	sd	ra,8(sp)
    80003f6e:	e022                	sd	s0,0(sp)
    80003f70:	0800                	addi	s0,sp,16
    80003f72:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f74:	4585                	li	a1,1
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	db4080e7          	jalr	-588(ra) # 80003d2a <namex>
}
    80003f7e:	60a2                	ld	ra,8(sp)
    80003f80:	6402                	ld	s0,0(sp)
    80003f82:	0141                	addi	sp,sp,16
    80003f84:	8082                	ret

0000000080003f86 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f86:	1101                	addi	sp,sp,-32
    80003f88:	ec06                	sd	ra,24(sp)
    80003f8a:	e822                	sd	s0,16(sp)
    80003f8c:	e426                	sd	s1,8(sp)
    80003f8e:	e04a                	sd	s2,0(sp)
    80003f90:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f92:	0001e917          	auipc	s2,0x1e
    80003f96:	17690913          	addi	s2,s2,374 # 80022108 <log>
    80003f9a:	01892583          	lw	a1,24(s2)
    80003f9e:	02892503          	lw	a0,40(s2)
    80003fa2:	fffff097          	auipc	ra,0xfffff
    80003fa6:	ff8080e7          	jalr	-8(ra) # 80002f9a <bread>
    80003faa:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fac:	02c92683          	lw	a3,44(s2)
    80003fb0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fb2:	02d05763          	blez	a3,80003fe0 <write_head+0x5a>
    80003fb6:	0001e797          	auipc	a5,0x1e
    80003fba:	18278793          	addi	a5,a5,386 # 80022138 <log+0x30>
    80003fbe:	05c50713          	addi	a4,a0,92
    80003fc2:	36fd                	addiw	a3,a3,-1
    80003fc4:	1682                	slli	a3,a3,0x20
    80003fc6:	9281                	srli	a3,a3,0x20
    80003fc8:	068a                	slli	a3,a3,0x2
    80003fca:	0001e617          	auipc	a2,0x1e
    80003fce:	17260613          	addi	a2,a2,370 # 8002213c <log+0x34>
    80003fd2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003fd4:	4390                	lw	a2,0(a5)
    80003fd6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fd8:	0791                	addi	a5,a5,4
    80003fda:	0711                	addi	a4,a4,4
    80003fdc:	fed79ce3          	bne	a5,a3,80003fd4 <write_head+0x4e>
  }
  bwrite(buf);
    80003fe0:	8526                	mv	a0,s1
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	0aa080e7          	jalr	170(ra) # 8000308c <bwrite>
  brelse(buf);
    80003fea:	8526                	mv	a0,s1
    80003fec:	fffff097          	auipc	ra,0xfffff
    80003ff0:	0de080e7          	jalr	222(ra) # 800030ca <brelse>
}
    80003ff4:	60e2                	ld	ra,24(sp)
    80003ff6:	6442                	ld	s0,16(sp)
    80003ff8:	64a2                	ld	s1,8(sp)
    80003ffa:	6902                	ld	s2,0(sp)
    80003ffc:	6105                	addi	sp,sp,32
    80003ffe:	8082                	ret

0000000080004000 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004000:	0001e797          	auipc	a5,0x1e
    80004004:	1347a783          	lw	a5,308(a5) # 80022134 <log+0x2c>
    80004008:	0af05663          	blez	a5,800040b4 <install_trans+0xb4>
{
    8000400c:	7139                	addi	sp,sp,-64
    8000400e:	fc06                	sd	ra,56(sp)
    80004010:	f822                	sd	s0,48(sp)
    80004012:	f426                	sd	s1,40(sp)
    80004014:	f04a                	sd	s2,32(sp)
    80004016:	ec4e                	sd	s3,24(sp)
    80004018:	e852                	sd	s4,16(sp)
    8000401a:	e456                	sd	s5,8(sp)
    8000401c:	0080                	addi	s0,sp,64
    8000401e:	0001ea97          	auipc	s5,0x1e
    80004022:	11aa8a93          	addi	s5,s5,282 # 80022138 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004026:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004028:	0001e997          	auipc	s3,0x1e
    8000402c:	0e098993          	addi	s3,s3,224 # 80022108 <log>
    80004030:	0189a583          	lw	a1,24(s3)
    80004034:	014585bb          	addw	a1,a1,s4
    80004038:	2585                	addiw	a1,a1,1
    8000403a:	0289a503          	lw	a0,40(s3)
    8000403e:	fffff097          	auipc	ra,0xfffff
    80004042:	f5c080e7          	jalr	-164(ra) # 80002f9a <bread>
    80004046:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004048:	000aa583          	lw	a1,0(s5)
    8000404c:	0289a503          	lw	a0,40(s3)
    80004050:	fffff097          	auipc	ra,0xfffff
    80004054:	f4a080e7          	jalr	-182(ra) # 80002f9a <bread>
    80004058:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000405a:	40000613          	li	a2,1024
    8000405e:	05890593          	addi	a1,s2,88
    80004062:	05850513          	addi	a0,a0,88
    80004066:	ffffd097          	auipc	ra,0xffffd
    8000406a:	d6a080e7          	jalr	-662(ra) # 80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000406e:	8526                	mv	a0,s1
    80004070:	fffff097          	auipc	ra,0xfffff
    80004074:	01c080e7          	jalr	28(ra) # 8000308c <bwrite>
    bunpin(dbuf);
    80004078:	8526                	mv	a0,s1
    8000407a:	fffff097          	auipc	ra,0xfffff
    8000407e:	12a080e7          	jalr	298(ra) # 800031a4 <bunpin>
    brelse(lbuf);
    80004082:	854a                	mv	a0,s2
    80004084:	fffff097          	auipc	ra,0xfffff
    80004088:	046080e7          	jalr	70(ra) # 800030ca <brelse>
    brelse(dbuf);
    8000408c:	8526                	mv	a0,s1
    8000408e:	fffff097          	auipc	ra,0xfffff
    80004092:	03c080e7          	jalr	60(ra) # 800030ca <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004096:	2a05                	addiw	s4,s4,1
    80004098:	0a91                	addi	s5,s5,4
    8000409a:	02c9a783          	lw	a5,44(s3)
    8000409e:	f8fa49e3          	blt	s4,a5,80004030 <install_trans+0x30>
}
    800040a2:	70e2                	ld	ra,56(sp)
    800040a4:	7442                	ld	s0,48(sp)
    800040a6:	74a2                	ld	s1,40(sp)
    800040a8:	7902                	ld	s2,32(sp)
    800040aa:	69e2                	ld	s3,24(sp)
    800040ac:	6a42                	ld	s4,16(sp)
    800040ae:	6aa2                	ld	s5,8(sp)
    800040b0:	6121                	addi	sp,sp,64
    800040b2:	8082                	ret
    800040b4:	8082                	ret

00000000800040b6 <initlog>:
{
    800040b6:	7179                	addi	sp,sp,-48
    800040b8:	f406                	sd	ra,40(sp)
    800040ba:	f022                	sd	s0,32(sp)
    800040bc:	ec26                	sd	s1,24(sp)
    800040be:	e84a                	sd	s2,16(sp)
    800040c0:	e44e                	sd	s3,8(sp)
    800040c2:	1800                	addi	s0,sp,48
    800040c4:	892a                	mv	s2,a0
    800040c6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040c8:	0001e497          	auipc	s1,0x1e
    800040cc:	04048493          	addi	s1,s1,64 # 80022108 <log>
    800040d0:	00004597          	auipc	a1,0x4
    800040d4:	55858593          	addi	a1,a1,1368 # 80008628 <syscalls+0x1e8>
    800040d8:	8526                	mv	a0,s1
    800040da:	ffffd097          	auipc	ra,0xffffd
    800040de:	b0a080e7          	jalr	-1270(ra) # 80000be4 <initlock>
  log.start = sb->logstart;
    800040e2:	0149a583          	lw	a1,20(s3)
    800040e6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040e8:	0109a783          	lw	a5,16(s3)
    800040ec:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040ee:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040f2:	854a                	mv	a0,s2
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	ea6080e7          	jalr	-346(ra) # 80002f9a <bread>
  log.lh.n = lh->n;
    800040fc:	4d3c                	lw	a5,88(a0)
    800040fe:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004100:	02f05563          	blez	a5,8000412a <initlog+0x74>
    80004104:	05c50713          	addi	a4,a0,92
    80004108:	0001e697          	auipc	a3,0x1e
    8000410c:	03068693          	addi	a3,a3,48 # 80022138 <log+0x30>
    80004110:	37fd                	addiw	a5,a5,-1
    80004112:	1782                	slli	a5,a5,0x20
    80004114:	9381                	srli	a5,a5,0x20
    80004116:	078a                	slli	a5,a5,0x2
    80004118:	06050613          	addi	a2,a0,96
    8000411c:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000411e:	4310                	lw	a2,0(a4)
    80004120:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004122:	0711                	addi	a4,a4,4
    80004124:	0691                	addi	a3,a3,4
    80004126:	fef71ce3          	bne	a4,a5,8000411e <initlog+0x68>
  brelse(buf);
    8000412a:	fffff097          	auipc	ra,0xfffff
    8000412e:	fa0080e7          	jalr	-96(ra) # 800030ca <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004132:	00000097          	auipc	ra,0x0
    80004136:	ece080e7          	jalr	-306(ra) # 80004000 <install_trans>
  log.lh.n = 0;
    8000413a:	0001e797          	auipc	a5,0x1e
    8000413e:	fe07ad23          	sw	zero,-6(a5) # 80022134 <log+0x2c>
  write_head(); // clear the log
    80004142:	00000097          	auipc	ra,0x0
    80004146:	e44080e7          	jalr	-444(ra) # 80003f86 <write_head>
}
    8000414a:	70a2                	ld	ra,40(sp)
    8000414c:	7402                	ld	s0,32(sp)
    8000414e:	64e2                	ld	s1,24(sp)
    80004150:	6942                	ld	s2,16(sp)
    80004152:	69a2                	ld	s3,8(sp)
    80004154:	6145                	addi	sp,sp,48
    80004156:	8082                	ret

0000000080004158 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004158:	1101                	addi	sp,sp,-32
    8000415a:	ec06                	sd	ra,24(sp)
    8000415c:	e822                	sd	s0,16(sp)
    8000415e:	e426                	sd	s1,8(sp)
    80004160:	e04a                	sd	s2,0(sp)
    80004162:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004164:	0001e517          	auipc	a0,0x1e
    80004168:	fa450513          	addi	a0,a0,-92 # 80022108 <log>
    8000416c:	ffffd097          	auipc	ra,0xffffd
    80004170:	b08080e7          	jalr	-1272(ra) # 80000c74 <acquire>
  while(1){
    if(log.committing){
    80004174:	0001e497          	auipc	s1,0x1e
    80004178:	f9448493          	addi	s1,s1,-108 # 80022108 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000417c:	4979                	li	s2,30
    8000417e:	a039                	j	8000418c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004180:	85a6                	mv	a1,s1
    80004182:	8526                	mv	a0,s1
    80004184:	ffffe097          	auipc	ra,0xffffe
    80004188:	0fe080e7          	jalr	254(ra) # 80002282 <sleep>
    if(log.committing){
    8000418c:	50dc                	lw	a5,36(s1)
    8000418e:	fbed                	bnez	a5,80004180 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004190:	509c                	lw	a5,32(s1)
    80004192:	0017871b          	addiw	a4,a5,1
    80004196:	0007069b          	sext.w	a3,a4
    8000419a:	0027179b          	slliw	a5,a4,0x2
    8000419e:	9fb9                	addw	a5,a5,a4
    800041a0:	0017979b          	slliw	a5,a5,0x1
    800041a4:	54d8                	lw	a4,44(s1)
    800041a6:	9fb9                	addw	a5,a5,a4
    800041a8:	00f95963          	bge	s2,a5,800041ba <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041ac:	85a6                	mv	a1,s1
    800041ae:	8526                	mv	a0,s1
    800041b0:	ffffe097          	auipc	ra,0xffffe
    800041b4:	0d2080e7          	jalr	210(ra) # 80002282 <sleep>
    800041b8:	bfd1                	j	8000418c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800041ba:	0001e517          	auipc	a0,0x1e
    800041be:	f4e50513          	addi	a0,a0,-178 # 80022108 <log>
    800041c2:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800041c4:	ffffd097          	auipc	ra,0xffffd
    800041c8:	b64080e7          	jalr	-1180(ra) # 80000d28 <release>
      break;
    }
  }
}
    800041cc:	60e2                	ld	ra,24(sp)
    800041ce:	6442                	ld	s0,16(sp)
    800041d0:	64a2                	ld	s1,8(sp)
    800041d2:	6902                	ld	s2,0(sp)
    800041d4:	6105                	addi	sp,sp,32
    800041d6:	8082                	ret

00000000800041d8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041d8:	7139                	addi	sp,sp,-64
    800041da:	fc06                	sd	ra,56(sp)
    800041dc:	f822                	sd	s0,48(sp)
    800041de:	f426                	sd	s1,40(sp)
    800041e0:	f04a                	sd	s2,32(sp)
    800041e2:	ec4e                	sd	s3,24(sp)
    800041e4:	e852                	sd	s4,16(sp)
    800041e6:	e456                	sd	s5,8(sp)
    800041e8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041ea:	0001e497          	auipc	s1,0x1e
    800041ee:	f1e48493          	addi	s1,s1,-226 # 80022108 <log>
    800041f2:	8526                	mv	a0,s1
    800041f4:	ffffd097          	auipc	ra,0xffffd
    800041f8:	a80080e7          	jalr	-1408(ra) # 80000c74 <acquire>
  log.outstanding -= 1;
    800041fc:	509c                	lw	a5,32(s1)
    800041fe:	37fd                	addiw	a5,a5,-1
    80004200:	0007891b          	sext.w	s2,a5
    80004204:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004206:	50dc                	lw	a5,36(s1)
    80004208:	efb9                	bnez	a5,80004266 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000420a:	06091663          	bnez	s2,80004276 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000420e:	0001e497          	auipc	s1,0x1e
    80004212:	efa48493          	addi	s1,s1,-262 # 80022108 <log>
    80004216:	4785                	li	a5,1
    80004218:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000421a:	8526                	mv	a0,s1
    8000421c:	ffffd097          	auipc	ra,0xffffd
    80004220:	b0c080e7          	jalr	-1268(ra) # 80000d28 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004224:	54dc                	lw	a5,44(s1)
    80004226:	06f04763          	bgtz	a5,80004294 <end_op+0xbc>
    acquire(&log.lock);
    8000422a:	0001e497          	auipc	s1,0x1e
    8000422e:	ede48493          	addi	s1,s1,-290 # 80022108 <log>
    80004232:	8526                	mv	a0,s1
    80004234:	ffffd097          	auipc	ra,0xffffd
    80004238:	a40080e7          	jalr	-1472(ra) # 80000c74 <acquire>
    log.committing = 0;
    8000423c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004240:	8526                	mv	a0,s1
    80004242:	ffffe097          	auipc	ra,0xffffe
    80004246:	1c6080e7          	jalr	454(ra) # 80002408 <wakeup>
    release(&log.lock);
    8000424a:	8526                	mv	a0,s1
    8000424c:	ffffd097          	auipc	ra,0xffffd
    80004250:	adc080e7          	jalr	-1316(ra) # 80000d28 <release>
}
    80004254:	70e2                	ld	ra,56(sp)
    80004256:	7442                	ld	s0,48(sp)
    80004258:	74a2                	ld	s1,40(sp)
    8000425a:	7902                	ld	s2,32(sp)
    8000425c:	69e2                	ld	s3,24(sp)
    8000425e:	6a42                	ld	s4,16(sp)
    80004260:	6aa2                	ld	s5,8(sp)
    80004262:	6121                	addi	sp,sp,64
    80004264:	8082                	ret
    panic("log.committing");
    80004266:	00004517          	auipc	a0,0x4
    8000426a:	3ca50513          	addi	a0,a0,970 # 80008630 <syscalls+0x1f0>
    8000426e:	ffffc097          	auipc	ra,0xffffc
    80004272:	368080e7          	jalr	872(ra) # 800005d6 <panic>
    wakeup(&log);
    80004276:	0001e497          	auipc	s1,0x1e
    8000427a:	e9248493          	addi	s1,s1,-366 # 80022108 <log>
    8000427e:	8526                	mv	a0,s1
    80004280:	ffffe097          	auipc	ra,0xffffe
    80004284:	188080e7          	jalr	392(ra) # 80002408 <wakeup>
  release(&log.lock);
    80004288:	8526                	mv	a0,s1
    8000428a:	ffffd097          	auipc	ra,0xffffd
    8000428e:	a9e080e7          	jalr	-1378(ra) # 80000d28 <release>
  if(do_commit){
    80004292:	b7c9                	j	80004254 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004294:	0001ea97          	auipc	s5,0x1e
    80004298:	ea4a8a93          	addi	s5,s5,-348 # 80022138 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000429c:	0001ea17          	auipc	s4,0x1e
    800042a0:	e6ca0a13          	addi	s4,s4,-404 # 80022108 <log>
    800042a4:	018a2583          	lw	a1,24(s4)
    800042a8:	012585bb          	addw	a1,a1,s2
    800042ac:	2585                	addiw	a1,a1,1
    800042ae:	028a2503          	lw	a0,40(s4)
    800042b2:	fffff097          	auipc	ra,0xfffff
    800042b6:	ce8080e7          	jalr	-792(ra) # 80002f9a <bread>
    800042ba:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042bc:	000aa583          	lw	a1,0(s5)
    800042c0:	028a2503          	lw	a0,40(s4)
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	cd6080e7          	jalr	-810(ra) # 80002f9a <bread>
    800042cc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042ce:	40000613          	li	a2,1024
    800042d2:	05850593          	addi	a1,a0,88
    800042d6:	05848513          	addi	a0,s1,88
    800042da:	ffffd097          	auipc	ra,0xffffd
    800042de:	af6080e7          	jalr	-1290(ra) # 80000dd0 <memmove>
    bwrite(to);  // write the log
    800042e2:	8526                	mv	a0,s1
    800042e4:	fffff097          	auipc	ra,0xfffff
    800042e8:	da8080e7          	jalr	-600(ra) # 8000308c <bwrite>
    brelse(from);
    800042ec:	854e                	mv	a0,s3
    800042ee:	fffff097          	auipc	ra,0xfffff
    800042f2:	ddc080e7          	jalr	-548(ra) # 800030ca <brelse>
    brelse(to);
    800042f6:	8526                	mv	a0,s1
    800042f8:	fffff097          	auipc	ra,0xfffff
    800042fc:	dd2080e7          	jalr	-558(ra) # 800030ca <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004300:	2905                	addiw	s2,s2,1
    80004302:	0a91                	addi	s5,s5,4
    80004304:	02ca2783          	lw	a5,44(s4)
    80004308:	f8f94ee3          	blt	s2,a5,800042a4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	c7a080e7          	jalr	-902(ra) # 80003f86 <write_head>
    install_trans(); // Now install writes to home locations
    80004314:	00000097          	auipc	ra,0x0
    80004318:	cec080e7          	jalr	-788(ra) # 80004000 <install_trans>
    log.lh.n = 0;
    8000431c:	0001e797          	auipc	a5,0x1e
    80004320:	e007ac23          	sw	zero,-488(a5) # 80022134 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004324:	00000097          	auipc	ra,0x0
    80004328:	c62080e7          	jalr	-926(ra) # 80003f86 <write_head>
    8000432c:	bdfd                	j	8000422a <end_op+0x52>

000000008000432e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000432e:	1101                	addi	sp,sp,-32
    80004330:	ec06                	sd	ra,24(sp)
    80004332:	e822                	sd	s0,16(sp)
    80004334:	e426                	sd	s1,8(sp)
    80004336:	e04a                	sd	s2,0(sp)
    80004338:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000433a:	0001e717          	auipc	a4,0x1e
    8000433e:	dfa72703          	lw	a4,-518(a4) # 80022134 <log+0x2c>
    80004342:	47f5                	li	a5,29
    80004344:	08e7c063          	blt	a5,a4,800043c4 <log_write+0x96>
    80004348:	84aa                	mv	s1,a0
    8000434a:	0001e797          	auipc	a5,0x1e
    8000434e:	dda7a783          	lw	a5,-550(a5) # 80022124 <log+0x1c>
    80004352:	37fd                	addiw	a5,a5,-1
    80004354:	06f75863          	bge	a4,a5,800043c4 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004358:	0001e797          	auipc	a5,0x1e
    8000435c:	dd07a783          	lw	a5,-560(a5) # 80022128 <log+0x20>
    80004360:	06f05a63          	blez	a5,800043d4 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004364:	0001e917          	auipc	s2,0x1e
    80004368:	da490913          	addi	s2,s2,-604 # 80022108 <log>
    8000436c:	854a                	mv	a0,s2
    8000436e:	ffffd097          	auipc	ra,0xffffd
    80004372:	906080e7          	jalr	-1786(ra) # 80000c74 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004376:	02c92603          	lw	a2,44(s2)
    8000437a:	06c05563          	blez	a2,800043e4 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000437e:	44cc                	lw	a1,12(s1)
    80004380:	0001e717          	auipc	a4,0x1e
    80004384:	db870713          	addi	a4,a4,-584 # 80022138 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004388:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000438a:	4314                	lw	a3,0(a4)
    8000438c:	04b68d63          	beq	a3,a1,800043e6 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004390:	2785                	addiw	a5,a5,1
    80004392:	0711                	addi	a4,a4,4
    80004394:	fec79be3          	bne	a5,a2,8000438a <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004398:	0621                	addi	a2,a2,8
    8000439a:	060a                	slli	a2,a2,0x2
    8000439c:	0001e797          	auipc	a5,0x1e
    800043a0:	d6c78793          	addi	a5,a5,-660 # 80022108 <log>
    800043a4:	963e                	add	a2,a2,a5
    800043a6:	44dc                	lw	a5,12(s1)
    800043a8:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043aa:	8526                	mv	a0,s1
    800043ac:	fffff097          	auipc	ra,0xfffff
    800043b0:	dbc080e7          	jalr	-580(ra) # 80003168 <bpin>
    log.lh.n++;
    800043b4:	0001e717          	auipc	a4,0x1e
    800043b8:	d5470713          	addi	a4,a4,-684 # 80022108 <log>
    800043bc:	575c                	lw	a5,44(a4)
    800043be:	2785                	addiw	a5,a5,1
    800043c0:	d75c                	sw	a5,44(a4)
    800043c2:	a83d                	j	80004400 <log_write+0xd2>
    panic("too big a transaction");
    800043c4:	00004517          	auipc	a0,0x4
    800043c8:	27c50513          	addi	a0,a0,636 # 80008640 <syscalls+0x200>
    800043cc:	ffffc097          	auipc	ra,0xffffc
    800043d0:	20a080e7          	jalr	522(ra) # 800005d6 <panic>
    panic("log_write outside of trans");
    800043d4:	00004517          	auipc	a0,0x4
    800043d8:	28450513          	addi	a0,a0,644 # 80008658 <syscalls+0x218>
    800043dc:	ffffc097          	auipc	ra,0xffffc
    800043e0:	1fa080e7          	jalr	506(ra) # 800005d6 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800043e4:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800043e6:	00878713          	addi	a4,a5,8
    800043ea:	00271693          	slli	a3,a4,0x2
    800043ee:	0001e717          	auipc	a4,0x1e
    800043f2:	d1a70713          	addi	a4,a4,-742 # 80022108 <log>
    800043f6:	9736                	add	a4,a4,a3
    800043f8:	44d4                	lw	a3,12(s1)
    800043fa:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043fc:	faf607e3          	beq	a2,a5,800043aa <log_write+0x7c>
  }
  release(&log.lock);
    80004400:	0001e517          	auipc	a0,0x1e
    80004404:	d0850513          	addi	a0,a0,-760 # 80022108 <log>
    80004408:	ffffd097          	auipc	ra,0xffffd
    8000440c:	920080e7          	jalr	-1760(ra) # 80000d28 <release>
}
    80004410:	60e2                	ld	ra,24(sp)
    80004412:	6442                	ld	s0,16(sp)
    80004414:	64a2                	ld	s1,8(sp)
    80004416:	6902                	ld	s2,0(sp)
    80004418:	6105                	addi	sp,sp,32
    8000441a:	8082                	ret

000000008000441c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000441c:	1101                	addi	sp,sp,-32
    8000441e:	ec06                	sd	ra,24(sp)
    80004420:	e822                	sd	s0,16(sp)
    80004422:	e426                	sd	s1,8(sp)
    80004424:	e04a                	sd	s2,0(sp)
    80004426:	1000                	addi	s0,sp,32
    80004428:	84aa                	mv	s1,a0
    8000442a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000442c:	00004597          	auipc	a1,0x4
    80004430:	24c58593          	addi	a1,a1,588 # 80008678 <syscalls+0x238>
    80004434:	0521                	addi	a0,a0,8
    80004436:	ffffc097          	auipc	ra,0xffffc
    8000443a:	7ae080e7          	jalr	1966(ra) # 80000be4 <initlock>
  lk->name = name;
    8000443e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004442:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004446:	0204a423          	sw	zero,40(s1)
}
    8000444a:	60e2                	ld	ra,24(sp)
    8000444c:	6442                	ld	s0,16(sp)
    8000444e:	64a2                	ld	s1,8(sp)
    80004450:	6902                	ld	s2,0(sp)
    80004452:	6105                	addi	sp,sp,32
    80004454:	8082                	ret

0000000080004456 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004456:	1101                	addi	sp,sp,-32
    80004458:	ec06                	sd	ra,24(sp)
    8000445a:	e822                	sd	s0,16(sp)
    8000445c:	e426                	sd	s1,8(sp)
    8000445e:	e04a                	sd	s2,0(sp)
    80004460:	1000                	addi	s0,sp,32
    80004462:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004464:	00850913          	addi	s2,a0,8
    80004468:	854a                	mv	a0,s2
    8000446a:	ffffd097          	auipc	ra,0xffffd
    8000446e:	80a080e7          	jalr	-2038(ra) # 80000c74 <acquire>
  while (lk->locked) {
    80004472:	409c                	lw	a5,0(s1)
    80004474:	cb89                	beqz	a5,80004486 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004476:	85ca                	mv	a1,s2
    80004478:	8526                	mv	a0,s1
    8000447a:	ffffe097          	auipc	ra,0xffffe
    8000447e:	e08080e7          	jalr	-504(ra) # 80002282 <sleep>
  while (lk->locked) {
    80004482:	409c                	lw	a5,0(s1)
    80004484:	fbed                	bnez	a5,80004476 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004486:	4785                	li	a5,1
    80004488:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000448a:	ffffd097          	auipc	ra,0xffffd
    8000448e:	5b8080e7          	jalr	1464(ra) # 80001a42 <myproc>
    80004492:	5d1c                	lw	a5,56(a0)
    80004494:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004496:	854a                	mv	a0,s2
    80004498:	ffffd097          	auipc	ra,0xffffd
    8000449c:	890080e7          	jalr	-1904(ra) # 80000d28 <release>
}
    800044a0:	60e2                	ld	ra,24(sp)
    800044a2:	6442                	ld	s0,16(sp)
    800044a4:	64a2                	ld	s1,8(sp)
    800044a6:	6902                	ld	s2,0(sp)
    800044a8:	6105                	addi	sp,sp,32
    800044aa:	8082                	ret

00000000800044ac <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044ac:	1101                	addi	sp,sp,-32
    800044ae:	ec06                	sd	ra,24(sp)
    800044b0:	e822                	sd	s0,16(sp)
    800044b2:	e426                	sd	s1,8(sp)
    800044b4:	e04a                	sd	s2,0(sp)
    800044b6:	1000                	addi	s0,sp,32
    800044b8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044ba:	00850913          	addi	s2,a0,8
    800044be:	854a                	mv	a0,s2
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	7b4080e7          	jalr	1972(ra) # 80000c74 <acquire>
  lk->locked = 0;
    800044c8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044cc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044d0:	8526                	mv	a0,s1
    800044d2:	ffffe097          	auipc	ra,0xffffe
    800044d6:	f36080e7          	jalr	-202(ra) # 80002408 <wakeup>
  release(&lk->lk);
    800044da:	854a                	mv	a0,s2
    800044dc:	ffffd097          	auipc	ra,0xffffd
    800044e0:	84c080e7          	jalr	-1972(ra) # 80000d28 <release>
}
    800044e4:	60e2                	ld	ra,24(sp)
    800044e6:	6442                	ld	s0,16(sp)
    800044e8:	64a2                	ld	s1,8(sp)
    800044ea:	6902                	ld	s2,0(sp)
    800044ec:	6105                	addi	sp,sp,32
    800044ee:	8082                	ret

00000000800044f0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044f0:	7179                	addi	sp,sp,-48
    800044f2:	f406                	sd	ra,40(sp)
    800044f4:	f022                	sd	s0,32(sp)
    800044f6:	ec26                	sd	s1,24(sp)
    800044f8:	e84a                	sd	s2,16(sp)
    800044fa:	e44e                	sd	s3,8(sp)
    800044fc:	1800                	addi	s0,sp,48
    800044fe:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004500:	00850913          	addi	s2,a0,8
    80004504:	854a                	mv	a0,s2
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	76e080e7          	jalr	1902(ra) # 80000c74 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000450e:	409c                	lw	a5,0(s1)
    80004510:	ef99                	bnez	a5,8000452e <holdingsleep+0x3e>
    80004512:	4481                	li	s1,0
  release(&lk->lk);
    80004514:	854a                	mv	a0,s2
    80004516:	ffffd097          	auipc	ra,0xffffd
    8000451a:	812080e7          	jalr	-2030(ra) # 80000d28 <release>
  return r;
}
    8000451e:	8526                	mv	a0,s1
    80004520:	70a2                	ld	ra,40(sp)
    80004522:	7402                	ld	s0,32(sp)
    80004524:	64e2                	ld	s1,24(sp)
    80004526:	6942                	ld	s2,16(sp)
    80004528:	69a2                	ld	s3,8(sp)
    8000452a:	6145                	addi	sp,sp,48
    8000452c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000452e:	0284a983          	lw	s3,40(s1)
    80004532:	ffffd097          	auipc	ra,0xffffd
    80004536:	510080e7          	jalr	1296(ra) # 80001a42 <myproc>
    8000453a:	5d04                	lw	s1,56(a0)
    8000453c:	413484b3          	sub	s1,s1,s3
    80004540:	0014b493          	seqz	s1,s1
    80004544:	bfc1                	j	80004514 <holdingsleep+0x24>

0000000080004546 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004546:	1141                	addi	sp,sp,-16
    80004548:	e406                	sd	ra,8(sp)
    8000454a:	e022                	sd	s0,0(sp)
    8000454c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000454e:	00004597          	auipc	a1,0x4
    80004552:	13a58593          	addi	a1,a1,314 # 80008688 <syscalls+0x248>
    80004556:	0001e517          	auipc	a0,0x1e
    8000455a:	cfa50513          	addi	a0,a0,-774 # 80022250 <ftable>
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	686080e7          	jalr	1670(ra) # 80000be4 <initlock>
}
    80004566:	60a2                	ld	ra,8(sp)
    80004568:	6402                	ld	s0,0(sp)
    8000456a:	0141                	addi	sp,sp,16
    8000456c:	8082                	ret

000000008000456e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000456e:	1101                	addi	sp,sp,-32
    80004570:	ec06                	sd	ra,24(sp)
    80004572:	e822                	sd	s0,16(sp)
    80004574:	e426                	sd	s1,8(sp)
    80004576:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004578:	0001e517          	auipc	a0,0x1e
    8000457c:	cd850513          	addi	a0,a0,-808 # 80022250 <ftable>
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	6f4080e7          	jalr	1780(ra) # 80000c74 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004588:	0001e497          	auipc	s1,0x1e
    8000458c:	ce048493          	addi	s1,s1,-800 # 80022268 <ftable+0x18>
    80004590:	0001f717          	auipc	a4,0x1f
    80004594:	c7870713          	addi	a4,a4,-904 # 80023208 <ftable+0xfb8>
    if(f->ref == 0){
    80004598:	40dc                	lw	a5,4(s1)
    8000459a:	cf99                	beqz	a5,800045b8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000459c:	02848493          	addi	s1,s1,40
    800045a0:	fee49ce3          	bne	s1,a4,80004598 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045a4:	0001e517          	auipc	a0,0x1e
    800045a8:	cac50513          	addi	a0,a0,-852 # 80022250 <ftable>
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	77c080e7          	jalr	1916(ra) # 80000d28 <release>
  return 0;
    800045b4:	4481                	li	s1,0
    800045b6:	a819                	j	800045cc <filealloc+0x5e>
      f->ref = 1;
    800045b8:	4785                	li	a5,1
    800045ba:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045bc:	0001e517          	auipc	a0,0x1e
    800045c0:	c9450513          	addi	a0,a0,-876 # 80022250 <ftable>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	764080e7          	jalr	1892(ra) # 80000d28 <release>
}
    800045cc:	8526                	mv	a0,s1
    800045ce:	60e2                	ld	ra,24(sp)
    800045d0:	6442                	ld	s0,16(sp)
    800045d2:	64a2                	ld	s1,8(sp)
    800045d4:	6105                	addi	sp,sp,32
    800045d6:	8082                	ret

00000000800045d8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045d8:	1101                	addi	sp,sp,-32
    800045da:	ec06                	sd	ra,24(sp)
    800045dc:	e822                	sd	s0,16(sp)
    800045de:	e426                	sd	s1,8(sp)
    800045e0:	1000                	addi	s0,sp,32
    800045e2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045e4:	0001e517          	auipc	a0,0x1e
    800045e8:	c6c50513          	addi	a0,a0,-916 # 80022250 <ftable>
    800045ec:	ffffc097          	auipc	ra,0xffffc
    800045f0:	688080e7          	jalr	1672(ra) # 80000c74 <acquire>
  if(f->ref < 1)
    800045f4:	40dc                	lw	a5,4(s1)
    800045f6:	02f05263          	blez	a5,8000461a <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045fa:	2785                	addiw	a5,a5,1
    800045fc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045fe:	0001e517          	auipc	a0,0x1e
    80004602:	c5250513          	addi	a0,a0,-942 # 80022250 <ftable>
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	722080e7          	jalr	1826(ra) # 80000d28 <release>
  return f;
}
    8000460e:	8526                	mv	a0,s1
    80004610:	60e2                	ld	ra,24(sp)
    80004612:	6442                	ld	s0,16(sp)
    80004614:	64a2                	ld	s1,8(sp)
    80004616:	6105                	addi	sp,sp,32
    80004618:	8082                	ret
    panic("filedup");
    8000461a:	00004517          	auipc	a0,0x4
    8000461e:	07650513          	addi	a0,a0,118 # 80008690 <syscalls+0x250>
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	fb4080e7          	jalr	-76(ra) # 800005d6 <panic>

000000008000462a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000462a:	7139                	addi	sp,sp,-64
    8000462c:	fc06                	sd	ra,56(sp)
    8000462e:	f822                	sd	s0,48(sp)
    80004630:	f426                	sd	s1,40(sp)
    80004632:	f04a                	sd	s2,32(sp)
    80004634:	ec4e                	sd	s3,24(sp)
    80004636:	e852                	sd	s4,16(sp)
    80004638:	e456                	sd	s5,8(sp)
    8000463a:	0080                	addi	s0,sp,64
    8000463c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000463e:	0001e517          	auipc	a0,0x1e
    80004642:	c1250513          	addi	a0,a0,-1006 # 80022250 <ftable>
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	62e080e7          	jalr	1582(ra) # 80000c74 <acquire>
  if(f->ref < 1)
    8000464e:	40dc                	lw	a5,4(s1)
    80004650:	06f05163          	blez	a5,800046b2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004654:	37fd                	addiw	a5,a5,-1
    80004656:	0007871b          	sext.w	a4,a5
    8000465a:	c0dc                	sw	a5,4(s1)
    8000465c:	06e04363          	bgtz	a4,800046c2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004660:	0004a903          	lw	s2,0(s1)
    80004664:	0094ca83          	lbu	s5,9(s1)
    80004668:	0104ba03          	ld	s4,16(s1)
    8000466c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004670:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004674:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004678:	0001e517          	auipc	a0,0x1e
    8000467c:	bd850513          	addi	a0,a0,-1064 # 80022250 <ftable>
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	6a8080e7          	jalr	1704(ra) # 80000d28 <release>

  if(ff.type == FD_PIPE){
    80004688:	4785                	li	a5,1
    8000468a:	04f90d63          	beq	s2,a5,800046e4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000468e:	3979                	addiw	s2,s2,-2
    80004690:	4785                	li	a5,1
    80004692:	0527e063          	bltu	a5,s2,800046d2 <fileclose+0xa8>
    begin_op();
    80004696:	00000097          	auipc	ra,0x0
    8000469a:	ac2080e7          	jalr	-1342(ra) # 80004158 <begin_op>
    iput(ff.ip);
    8000469e:	854e                	mv	a0,s3
    800046a0:	fffff097          	auipc	ra,0xfffff
    800046a4:	2b6080e7          	jalr	694(ra) # 80003956 <iput>
    end_op();
    800046a8:	00000097          	auipc	ra,0x0
    800046ac:	b30080e7          	jalr	-1232(ra) # 800041d8 <end_op>
    800046b0:	a00d                	j	800046d2 <fileclose+0xa8>
    panic("fileclose");
    800046b2:	00004517          	auipc	a0,0x4
    800046b6:	fe650513          	addi	a0,a0,-26 # 80008698 <syscalls+0x258>
    800046ba:	ffffc097          	auipc	ra,0xffffc
    800046be:	f1c080e7          	jalr	-228(ra) # 800005d6 <panic>
    release(&ftable.lock);
    800046c2:	0001e517          	auipc	a0,0x1e
    800046c6:	b8e50513          	addi	a0,a0,-1138 # 80022250 <ftable>
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	65e080e7          	jalr	1630(ra) # 80000d28 <release>
  }
}
    800046d2:	70e2                	ld	ra,56(sp)
    800046d4:	7442                	ld	s0,48(sp)
    800046d6:	74a2                	ld	s1,40(sp)
    800046d8:	7902                	ld	s2,32(sp)
    800046da:	69e2                	ld	s3,24(sp)
    800046dc:	6a42                	ld	s4,16(sp)
    800046de:	6aa2                	ld	s5,8(sp)
    800046e0:	6121                	addi	sp,sp,64
    800046e2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046e4:	85d6                	mv	a1,s5
    800046e6:	8552                	mv	a0,s4
    800046e8:	00000097          	auipc	ra,0x0
    800046ec:	372080e7          	jalr	882(ra) # 80004a5a <pipeclose>
    800046f0:	b7cd                	j	800046d2 <fileclose+0xa8>

00000000800046f2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046f2:	715d                	addi	sp,sp,-80
    800046f4:	e486                	sd	ra,72(sp)
    800046f6:	e0a2                	sd	s0,64(sp)
    800046f8:	fc26                	sd	s1,56(sp)
    800046fa:	f84a                	sd	s2,48(sp)
    800046fc:	f44e                	sd	s3,40(sp)
    800046fe:	0880                	addi	s0,sp,80
    80004700:	84aa                	mv	s1,a0
    80004702:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004704:	ffffd097          	auipc	ra,0xffffd
    80004708:	33e080e7          	jalr	830(ra) # 80001a42 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000470c:	409c                	lw	a5,0(s1)
    8000470e:	37f9                	addiw	a5,a5,-2
    80004710:	4705                	li	a4,1
    80004712:	04f76763          	bltu	a4,a5,80004760 <filestat+0x6e>
    80004716:	892a                	mv	s2,a0
    ilock(f->ip);
    80004718:	6c88                	ld	a0,24(s1)
    8000471a:	fffff097          	auipc	ra,0xfffff
    8000471e:	082080e7          	jalr	130(ra) # 8000379c <ilock>
    stati(f->ip, &st);
    80004722:	fb840593          	addi	a1,s0,-72
    80004726:	6c88                	ld	a0,24(s1)
    80004728:	fffff097          	auipc	ra,0xfffff
    8000472c:	2fe080e7          	jalr	766(ra) # 80003a26 <stati>
    iunlock(f->ip);
    80004730:	6c88                	ld	a0,24(s1)
    80004732:	fffff097          	auipc	ra,0xfffff
    80004736:	12c080e7          	jalr	300(ra) # 8000385e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000473a:	46e1                	li	a3,24
    8000473c:	fb840613          	addi	a2,s0,-72
    80004740:	85ce                	mv	a1,s3
    80004742:	05093503          	ld	a0,80(s2)
    80004746:	ffffd097          	auipc	ra,0xffffd
    8000474a:	ff0080e7          	jalr	-16(ra) # 80001736 <copyout>
    8000474e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004752:	60a6                	ld	ra,72(sp)
    80004754:	6406                	ld	s0,64(sp)
    80004756:	74e2                	ld	s1,56(sp)
    80004758:	7942                	ld	s2,48(sp)
    8000475a:	79a2                	ld	s3,40(sp)
    8000475c:	6161                	addi	sp,sp,80
    8000475e:	8082                	ret
  return -1;
    80004760:	557d                	li	a0,-1
    80004762:	bfc5                	j	80004752 <filestat+0x60>

0000000080004764 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004764:	7179                	addi	sp,sp,-48
    80004766:	f406                	sd	ra,40(sp)
    80004768:	f022                	sd	s0,32(sp)
    8000476a:	ec26                	sd	s1,24(sp)
    8000476c:	e84a                	sd	s2,16(sp)
    8000476e:	e44e                	sd	s3,8(sp)
    80004770:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004772:	00854783          	lbu	a5,8(a0)
    80004776:	c3d5                	beqz	a5,8000481a <fileread+0xb6>
    80004778:	84aa                	mv	s1,a0
    8000477a:	89ae                	mv	s3,a1
    8000477c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000477e:	411c                	lw	a5,0(a0)
    80004780:	4705                	li	a4,1
    80004782:	04e78963          	beq	a5,a4,800047d4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004786:	470d                	li	a4,3
    80004788:	04e78d63          	beq	a5,a4,800047e2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000478c:	4709                	li	a4,2
    8000478e:	06e79e63          	bne	a5,a4,8000480a <fileread+0xa6>
    ilock(f->ip);
    80004792:	6d08                	ld	a0,24(a0)
    80004794:	fffff097          	auipc	ra,0xfffff
    80004798:	008080e7          	jalr	8(ra) # 8000379c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000479c:	874a                	mv	a4,s2
    8000479e:	5094                	lw	a3,32(s1)
    800047a0:	864e                	mv	a2,s3
    800047a2:	4585                	li	a1,1
    800047a4:	6c88                	ld	a0,24(s1)
    800047a6:	fffff097          	auipc	ra,0xfffff
    800047aa:	2aa080e7          	jalr	682(ra) # 80003a50 <readi>
    800047ae:	892a                	mv	s2,a0
    800047b0:	00a05563          	blez	a0,800047ba <fileread+0x56>
      f->off += r;
    800047b4:	509c                	lw	a5,32(s1)
    800047b6:	9fa9                	addw	a5,a5,a0
    800047b8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047ba:	6c88                	ld	a0,24(s1)
    800047bc:	fffff097          	auipc	ra,0xfffff
    800047c0:	0a2080e7          	jalr	162(ra) # 8000385e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800047c4:	854a                	mv	a0,s2
    800047c6:	70a2                	ld	ra,40(sp)
    800047c8:	7402                	ld	s0,32(sp)
    800047ca:	64e2                	ld	s1,24(sp)
    800047cc:	6942                	ld	s2,16(sp)
    800047ce:	69a2                	ld	s3,8(sp)
    800047d0:	6145                	addi	sp,sp,48
    800047d2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047d4:	6908                	ld	a0,16(a0)
    800047d6:	00000097          	auipc	ra,0x0
    800047da:	418080e7          	jalr	1048(ra) # 80004bee <piperead>
    800047de:	892a                	mv	s2,a0
    800047e0:	b7d5                	j	800047c4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047e2:	02451783          	lh	a5,36(a0)
    800047e6:	03079693          	slli	a3,a5,0x30
    800047ea:	92c1                	srli	a3,a3,0x30
    800047ec:	4725                	li	a4,9
    800047ee:	02d76863          	bltu	a4,a3,8000481e <fileread+0xba>
    800047f2:	0792                	slli	a5,a5,0x4
    800047f4:	0001e717          	auipc	a4,0x1e
    800047f8:	9bc70713          	addi	a4,a4,-1604 # 800221b0 <devsw>
    800047fc:	97ba                	add	a5,a5,a4
    800047fe:	639c                	ld	a5,0(a5)
    80004800:	c38d                	beqz	a5,80004822 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004802:	4505                	li	a0,1
    80004804:	9782                	jalr	a5
    80004806:	892a                	mv	s2,a0
    80004808:	bf75                	j	800047c4 <fileread+0x60>
    panic("fileread");
    8000480a:	00004517          	auipc	a0,0x4
    8000480e:	e9e50513          	addi	a0,a0,-354 # 800086a8 <syscalls+0x268>
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	dc4080e7          	jalr	-572(ra) # 800005d6 <panic>
    return -1;
    8000481a:	597d                	li	s2,-1
    8000481c:	b765                	j	800047c4 <fileread+0x60>
      return -1;
    8000481e:	597d                	li	s2,-1
    80004820:	b755                	j	800047c4 <fileread+0x60>
    80004822:	597d                	li	s2,-1
    80004824:	b745                	j	800047c4 <fileread+0x60>

0000000080004826 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004826:	00954783          	lbu	a5,9(a0)
    8000482a:	14078563          	beqz	a5,80004974 <filewrite+0x14e>
{
    8000482e:	715d                	addi	sp,sp,-80
    80004830:	e486                	sd	ra,72(sp)
    80004832:	e0a2                	sd	s0,64(sp)
    80004834:	fc26                	sd	s1,56(sp)
    80004836:	f84a                	sd	s2,48(sp)
    80004838:	f44e                	sd	s3,40(sp)
    8000483a:	f052                	sd	s4,32(sp)
    8000483c:	ec56                	sd	s5,24(sp)
    8000483e:	e85a                	sd	s6,16(sp)
    80004840:	e45e                	sd	s7,8(sp)
    80004842:	e062                	sd	s8,0(sp)
    80004844:	0880                	addi	s0,sp,80
    80004846:	892a                	mv	s2,a0
    80004848:	8aae                	mv	s5,a1
    8000484a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000484c:	411c                	lw	a5,0(a0)
    8000484e:	4705                	li	a4,1
    80004850:	02e78263          	beq	a5,a4,80004874 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004854:	470d                	li	a4,3
    80004856:	02e78563          	beq	a5,a4,80004880 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000485a:	4709                	li	a4,2
    8000485c:	10e79463          	bne	a5,a4,80004964 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004860:	0ec05e63          	blez	a2,8000495c <filewrite+0x136>
    int i = 0;
    80004864:	4981                	li	s3,0
    80004866:	6b05                	lui	s6,0x1
    80004868:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000486c:	6b85                	lui	s7,0x1
    8000486e:	c00b8b9b          	addiw	s7,s7,-1024
    80004872:	a851                	j	80004906 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004874:	6908                	ld	a0,16(a0)
    80004876:	00000097          	auipc	ra,0x0
    8000487a:	254080e7          	jalr	596(ra) # 80004aca <pipewrite>
    8000487e:	a85d                	j	80004934 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004880:	02451783          	lh	a5,36(a0)
    80004884:	03079693          	slli	a3,a5,0x30
    80004888:	92c1                	srli	a3,a3,0x30
    8000488a:	4725                	li	a4,9
    8000488c:	0ed76663          	bltu	a4,a3,80004978 <filewrite+0x152>
    80004890:	0792                	slli	a5,a5,0x4
    80004892:	0001e717          	auipc	a4,0x1e
    80004896:	91e70713          	addi	a4,a4,-1762 # 800221b0 <devsw>
    8000489a:	97ba                	add	a5,a5,a4
    8000489c:	679c                	ld	a5,8(a5)
    8000489e:	cff9                	beqz	a5,8000497c <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    800048a0:	4505                	li	a0,1
    800048a2:	9782                	jalr	a5
    800048a4:	a841                	j	80004934 <filewrite+0x10e>
    800048a6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800048aa:	00000097          	auipc	ra,0x0
    800048ae:	8ae080e7          	jalr	-1874(ra) # 80004158 <begin_op>
      ilock(f->ip);
    800048b2:	01893503          	ld	a0,24(s2)
    800048b6:	fffff097          	auipc	ra,0xfffff
    800048ba:	ee6080e7          	jalr	-282(ra) # 8000379c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048be:	8762                	mv	a4,s8
    800048c0:	02092683          	lw	a3,32(s2)
    800048c4:	01598633          	add	a2,s3,s5
    800048c8:	4585                	li	a1,1
    800048ca:	01893503          	ld	a0,24(s2)
    800048ce:	fffff097          	auipc	ra,0xfffff
    800048d2:	278080e7          	jalr	632(ra) # 80003b46 <writei>
    800048d6:	84aa                	mv	s1,a0
    800048d8:	02a05f63          	blez	a0,80004916 <filewrite+0xf0>
        f->off += r;
    800048dc:	02092783          	lw	a5,32(s2)
    800048e0:	9fa9                	addw	a5,a5,a0
    800048e2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048e6:	01893503          	ld	a0,24(s2)
    800048ea:	fffff097          	auipc	ra,0xfffff
    800048ee:	f74080e7          	jalr	-140(ra) # 8000385e <iunlock>
      end_op();
    800048f2:	00000097          	auipc	ra,0x0
    800048f6:	8e6080e7          	jalr	-1818(ra) # 800041d8 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800048fa:	049c1963          	bne	s8,s1,8000494c <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800048fe:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004902:	0349d663          	bge	s3,s4,8000492e <filewrite+0x108>
      int n1 = n - i;
    80004906:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000490a:	84be                	mv	s1,a5
    8000490c:	2781                	sext.w	a5,a5
    8000490e:	f8fb5ce3          	bge	s6,a5,800048a6 <filewrite+0x80>
    80004912:	84de                	mv	s1,s7
    80004914:	bf49                	j	800048a6 <filewrite+0x80>
      iunlock(f->ip);
    80004916:	01893503          	ld	a0,24(s2)
    8000491a:	fffff097          	auipc	ra,0xfffff
    8000491e:	f44080e7          	jalr	-188(ra) # 8000385e <iunlock>
      end_op();
    80004922:	00000097          	auipc	ra,0x0
    80004926:	8b6080e7          	jalr	-1866(ra) # 800041d8 <end_op>
      if(r < 0)
    8000492a:	fc04d8e3          	bgez	s1,800048fa <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    8000492e:	8552                	mv	a0,s4
    80004930:	033a1863          	bne	s4,s3,80004960 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004934:	60a6                	ld	ra,72(sp)
    80004936:	6406                	ld	s0,64(sp)
    80004938:	74e2                	ld	s1,56(sp)
    8000493a:	7942                	ld	s2,48(sp)
    8000493c:	79a2                	ld	s3,40(sp)
    8000493e:	7a02                	ld	s4,32(sp)
    80004940:	6ae2                	ld	s5,24(sp)
    80004942:	6b42                	ld	s6,16(sp)
    80004944:	6ba2                	ld	s7,8(sp)
    80004946:	6c02                	ld	s8,0(sp)
    80004948:	6161                	addi	sp,sp,80
    8000494a:	8082                	ret
        panic("short filewrite");
    8000494c:	00004517          	auipc	a0,0x4
    80004950:	d6c50513          	addi	a0,a0,-660 # 800086b8 <syscalls+0x278>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	c82080e7          	jalr	-894(ra) # 800005d6 <panic>
    int i = 0;
    8000495c:	4981                	li	s3,0
    8000495e:	bfc1                	j	8000492e <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004960:	557d                	li	a0,-1
    80004962:	bfc9                	j	80004934 <filewrite+0x10e>
    panic("filewrite");
    80004964:	00004517          	auipc	a0,0x4
    80004968:	d6450513          	addi	a0,a0,-668 # 800086c8 <syscalls+0x288>
    8000496c:	ffffc097          	auipc	ra,0xffffc
    80004970:	c6a080e7          	jalr	-918(ra) # 800005d6 <panic>
    return -1;
    80004974:	557d                	li	a0,-1
}
    80004976:	8082                	ret
      return -1;
    80004978:	557d                	li	a0,-1
    8000497a:	bf6d                	j	80004934 <filewrite+0x10e>
    8000497c:	557d                	li	a0,-1
    8000497e:	bf5d                	j	80004934 <filewrite+0x10e>

0000000080004980 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004980:	7179                	addi	sp,sp,-48
    80004982:	f406                	sd	ra,40(sp)
    80004984:	f022                	sd	s0,32(sp)
    80004986:	ec26                	sd	s1,24(sp)
    80004988:	e84a                	sd	s2,16(sp)
    8000498a:	e44e                	sd	s3,8(sp)
    8000498c:	e052                	sd	s4,0(sp)
    8000498e:	1800                	addi	s0,sp,48
    80004990:	84aa                	mv	s1,a0
    80004992:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004994:	0005b023          	sd	zero,0(a1)
    80004998:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000499c:	00000097          	auipc	ra,0x0
    800049a0:	bd2080e7          	jalr	-1070(ra) # 8000456e <filealloc>
    800049a4:	e088                	sd	a0,0(s1)
    800049a6:	c551                	beqz	a0,80004a32 <pipealloc+0xb2>
    800049a8:	00000097          	auipc	ra,0x0
    800049ac:	bc6080e7          	jalr	-1082(ra) # 8000456e <filealloc>
    800049b0:	00aa3023          	sd	a0,0(s4)
    800049b4:	c92d                	beqz	a0,80004a26 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	1ce080e7          	jalr	462(ra) # 80000b84 <kalloc>
    800049be:	892a                	mv	s2,a0
    800049c0:	c125                	beqz	a0,80004a20 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800049c2:	4985                	li	s3,1
    800049c4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049c8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049cc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049d0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049d4:	00004597          	auipc	a1,0x4
    800049d8:	d0458593          	addi	a1,a1,-764 # 800086d8 <syscalls+0x298>
    800049dc:	ffffc097          	auipc	ra,0xffffc
    800049e0:	208080e7          	jalr	520(ra) # 80000be4 <initlock>
  (*f0)->type = FD_PIPE;
    800049e4:	609c                	ld	a5,0(s1)
    800049e6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049ea:	609c                	ld	a5,0(s1)
    800049ec:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049f0:	609c                	ld	a5,0(s1)
    800049f2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049f6:	609c                	ld	a5,0(s1)
    800049f8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049fc:	000a3783          	ld	a5,0(s4)
    80004a00:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a04:	000a3783          	ld	a5,0(s4)
    80004a08:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a0c:	000a3783          	ld	a5,0(s4)
    80004a10:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a14:	000a3783          	ld	a5,0(s4)
    80004a18:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a1c:	4501                	li	a0,0
    80004a1e:	a025                	j	80004a46 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a20:	6088                	ld	a0,0(s1)
    80004a22:	e501                	bnez	a0,80004a2a <pipealloc+0xaa>
    80004a24:	a039                	j	80004a32 <pipealloc+0xb2>
    80004a26:	6088                	ld	a0,0(s1)
    80004a28:	c51d                	beqz	a0,80004a56 <pipealloc+0xd6>
    fileclose(*f0);
    80004a2a:	00000097          	auipc	ra,0x0
    80004a2e:	c00080e7          	jalr	-1024(ra) # 8000462a <fileclose>
  if(*f1)
    80004a32:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a36:	557d                	li	a0,-1
  if(*f1)
    80004a38:	c799                	beqz	a5,80004a46 <pipealloc+0xc6>
    fileclose(*f1);
    80004a3a:	853e                	mv	a0,a5
    80004a3c:	00000097          	auipc	ra,0x0
    80004a40:	bee080e7          	jalr	-1042(ra) # 8000462a <fileclose>
  return -1;
    80004a44:	557d                	li	a0,-1
}
    80004a46:	70a2                	ld	ra,40(sp)
    80004a48:	7402                	ld	s0,32(sp)
    80004a4a:	64e2                	ld	s1,24(sp)
    80004a4c:	6942                	ld	s2,16(sp)
    80004a4e:	69a2                	ld	s3,8(sp)
    80004a50:	6a02                	ld	s4,0(sp)
    80004a52:	6145                	addi	sp,sp,48
    80004a54:	8082                	ret
  return -1;
    80004a56:	557d                	li	a0,-1
    80004a58:	b7fd                	j	80004a46 <pipealloc+0xc6>

0000000080004a5a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a5a:	1101                	addi	sp,sp,-32
    80004a5c:	ec06                	sd	ra,24(sp)
    80004a5e:	e822                	sd	s0,16(sp)
    80004a60:	e426                	sd	s1,8(sp)
    80004a62:	e04a                	sd	s2,0(sp)
    80004a64:	1000                	addi	s0,sp,32
    80004a66:	84aa                	mv	s1,a0
    80004a68:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a6a:	ffffc097          	auipc	ra,0xffffc
    80004a6e:	20a080e7          	jalr	522(ra) # 80000c74 <acquire>
  if(writable){
    80004a72:	02090d63          	beqz	s2,80004aac <pipeclose+0x52>
    pi->writeopen = 0;
    80004a76:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a7a:	21848513          	addi	a0,s1,536
    80004a7e:	ffffe097          	auipc	ra,0xffffe
    80004a82:	98a080e7          	jalr	-1654(ra) # 80002408 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a86:	2204b783          	ld	a5,544(s1)
    80004a8a:	eb95                	bnez	a5,80004abe <pipeclose+0x64>
    release(&pi->lock);
    80004a8c:	8526                	mv	a0,s1
    80004a8e:	ffffc097          	auipc	ra,0xffffc
    80004a92:	29a080e7          	jalr	666(ra) # 80000d28 <release>
    kfree((char*)pi);
    80004a96:	8526                	mv	a0,s1
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	ff0080e7          	jalr	-16(ra) # 80000a88 <kfree>
  } else
    release(&pi->lock);
}
    80004aa0:	60e2                	ld	ra,24(sp)
    80004aa2:	6442                	ld	s0,16(sp)
    80004aa4:	64a2                	ld	s1,8(sp)
    80004aa6:	6902                	ld	s2,0(sp)
    80004aa8:	6105                	addi	sp,sp,32
    80004aaa:	8082                	ret
    pi->readopen = 0;
    80004aac:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ab0:	21c48513          	addi	a0,s1,540
    80004ab4:	ffffe097          	auipc	ra,0xffffe
    80004ab8:	954080e7          	jalr	-1708(ra) # 80002408 <wakeup>
    80004abc:	b7e9                	j	80004a86 <pipeclose+0x2c>
    release(&pi->lock);
    80004abe:	8526                	mv	a0,s1
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	268080e7          	jalr	616(ra) # 80000d28 <release>
}
    80004ac8:	bfe1                	j	80004aa0 <pipeclose+0x46>

0000000080004aca <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004aca:	7119                	addi	sp,sp,-128
    80004acc:	fc86                	sd	ra,120(sp)
    80004ace:	f8a2                	sd	s0,112(sp)
    80004ad0:	f4a6                	sd	s1,104(sp)
    80004ad2:	f0ca                	sd	s2,96(sp)
    80004ad4:	ecce                	sd	s3,88(sp)
    80004ad6:	e8d2                	sd	s4,80(sp)
    80004ad8:	e4d6                	sd	s5,72(sp)
    80004ada:	e0da                	sd	s6,64(sp)
    80004adc:	fc5e                	sd	s7,56(sp)
    80004ade:	f862                	sd	s8,48(sp)
    80004ae0:	f466                	sd	s9,40(sp)
    80004ae2:	f06a                	sd	s10,32(sp)
    80004ae4:	ec6e                	sd	s11,24(sp)
    80004ae6:	0100                	addi	s0,sp,128
    80004ae8:	84aa                	mv	s1,a0
    80004aea:	8cae                	mv	s9,a1
    80004aec:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004aee:	ffffd097          	auipc	ra,0xffffd
    80004af2:	f54080e7          	jalr	-172(ra) # 80001a42 <myproc>
    80004af6:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004af8:	8526                	mv	a0,s1
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	17a080e7          	jalr	378(ra) # 80000c74 <acquire>
  for(i = 0; i < n; i++){
    80004b02:	0d605963          	blez	s6,80004bd4 <pipewrite+0x10a>
    80004b06:	89a6                	mv	s3,s1
    80004b08:	3b7d                	addiw	s6,s6,-1
    80004b0a:	1b02                	slli	s6,s6,0x20
    80004b0c:	020b5b13          	srli	s6,s6,0x20
    80004b10:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004b12:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b16:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b1a:	5dfd                	li	s11,-1
    80004b1c:	000b8d1b          	sext.w	s10,s7
    80004b20:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b22:	2184a783          	lw	a5,536(s1)
    80004b26:	21c4a703          	lw	a4,540(s1)
    80004b2a:	2007879b          	addiw	a5,a5,512
    80004b2e:	02f71b63          	bne	a4,a5,80004b64 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004b32:	2204a783          	lw	a5,544(s1)
    80004b36:	cbad                	beqz	a5,80004ba8 <pipewrite+0xde>
    80004b38:	03092783          	lw	a5,48(s2)
    80004b3c:	e7b5                	bnez	a5,80004ba8 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004b3e:	8556                	mv	a0,s5
    80004b40:	ffffe097          	auipc	ra,0xffffe
    80004b44:	8c8080e7          	jalr	-1848(ra) # 80002408 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b48:	85ce                	mv	a1,s3
    80004b4a:	8552                	mv	a0,s4
    80004b4c:	ffffd097          	auipc	ra,0xffffd
    80004b50:	736080e7          	jalr	1846(ra) # 80002282 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b54:	2184a783          	lw	a5,536(s1)
    80004b58:	21c4a703          	lw	a4,540(s1)
    80004b5c:	2007879b          	addiw	a5,a5,512
    80004b60:	fcf709e3          	beq	a4,a5,80004b32 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b64:	4685                	li	a3,1
    80004b66:	019b8633          	add	a2,s7,s9
    80004b6a:	f8f40593          	addi	a1,s0,-113
    80004b6e:	05093503          	ld	a0,80(s2)
    80004b72:	ffffd097          	auipc	ra,0xffffd
    80004b76:	c50080e7          	jalr	-944(ra) # 800017c2 <copyin>
    80004b7a:	05b50e63          	beq	a0,s11,80004bd6 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b7e:	21c4a783          	lw	a5,540(s1)
    80004b82:	0017871b          	addiw	a4,a5,1
    80004b86:	20e4ae23          	sw	a4,540(s1)
    80004b8a:	1ff7f793          	andi	a5,a5,511
    80004b8e:	97a6                	add	a5,a5,s1
    80004b90:	f8f44703          	lbu	a4,-113(s0)
    80004b94:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b98:	001d0c1b          	addiw	s8,s10,1
    80004b9c:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004ba0:	036b8b63          	beq	s7,s6,80004bd6 <pipewrite+0x10c>
    80004ba4:	8bbe                	mv	s7,a5
    80004ba6:	bf9d                	j	80004b1c <pipewrite+0x52>
        release(&pi->lock);
    80004ba8:	8526                	mv	a0,s1
    80004baa:	ffffc097          	auipc	ra,0xffffc
    80004bae:	17e080e7          	jalr	382(ra) # 80000d28 <release>
        return -1;
    80004bb2:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004bb4:	8562                	mv	a0,s8
    80004bb6:	70e6                	ld	ra,120(sp)
    80004bb8:	7446                	ld	s0,112(sp)
    80004bba:	74a6                	ld	s1,104(sp)
    80004bbc:	7906                	ld	s2,96(sp)
    80004bbe:	69e6                	ld	s3,88(sp)
    80004bc0:	6a46                	ld	s4,80(sp)
    80004bc2:	6aa6                	ld	s5,72(sp)
    80004bc4:	6b06                	ld	s6,64(sp)
    80004bc6:	7be2                	ld	s7,56(sp)
    80004bc8:	7c42                	ld	s8,48(sp)
    80004bca:	7ca2                	ld	s9,40(sp)
    80004bcc:	7d02                	ld	s10,32(sp)
    80004bce:	6de2                	ld	s11,24(sp)
    80004bd0:	6109                	addi	sp,sp,128
    80004bd2:	8082                	ret
  for(i = 0; i < n; i++){
    80004bd4:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004bd6:	21848513          	addi	a0,s1,536
    80004bda:	ffffe097          	auipc	ra,0xffffe
    80004bde:	82e080e7          	jalr	-2002(ra) # 80002408 <wakeup>
  release(&pi->lock);
    80004be2:	8526                	mv	a0,s1
    80004be4:	ffffc097          	auipc	ra,0xffffc
    80004be8:	144080e7          	jalr	324(ra) # 80000d28 <release>
  return i;
    80004bec:	b7e1                	j	80004bb4 <pipewrite+0xea>

0000000080004bee <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004bee:	715d                	addi	sp,sp,-80
    80004bf0:	e486                	sd	ra,72(sp)
    80004bf2:	e0a2                	sd	s0,64(sp)
    80004bf4:	fc26                	sd	s1,56(sp)
    80004bf6:	f84a                	sd	s2,48(sp)
    80004bf8:	f44e                	sd	s3,40(sp)
    80004bfa:	f052                	sd	s4,32(sp)
    80004bfc:	ec56                	sd	s5,24(sp)
    80004bfe:	e85a                	sd	s6,16(sp)
    80004c00:	0880                	addi	s0,sp,80
    80004c02:	84aa                	mv	s1,a0
    80004c04:	892e                	mv	s2,a1
    80004c06:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c08:	ffffd097          	auipc	ra,0xffffd
    80004c0c:	e3a080e7          	jalr	-454(ra) # 80001a42 <myproc>
    80004c10:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c12:	8b26                	mv	s6,s1
    80004c14:	8526                	mv	a0,s1
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	05e080e7          	jalr	94(ra) # 80000c74 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c1e:	2184a703          	lw	a4,536(s1)
    80004c22:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c26:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c2a:	02f71463          	bne	a4,a5,80004c52 <piperead+0x64>
    80004c2e:	2244a783          	lw	a5,548(s1)
    80004c32:	c385                	beqz	a5,80004c52 <piperead+0x64>
    if(pr->killed){
    80004c34:	030a2783          	lw	a5,48(s4)
    80004c38:	ebc1                	bnez	a5,80004cc8 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c3a:	85da                	mv	a1,s6
    80004c3c:	854e                	mv	a0,s3
    80004c3e:	ffffd097          	auipc	ra,0xffffd
    80004c42:	644080e7          	jalr	1604(ra) # 80002282 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c46:	2184a703          	lw	a4,536(s1)
    80004c4a:	21c4a783          	lw	a5,540(s1)
    80004c4e:	fef700e3          	beq	a4,a5,80004c2e <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c52:	09505263          	blez	s5,80004cd6 <piperead+0xe8>
    80004c56:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c58:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004c5a:	2184a783          	lw	a5,536(s1)
    80004c5e:	21c4a703          	lw	a4,540(s1)
    80004c62:	02f70d63          	beq	a4,a5,80004c9c <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c66:	0017871b          	addiw	a4,a5,1
    80004c6a:	20e4ac23          	sw	a4,536(s1)
    80004c6e:	1ff7f793          	andi	a5,a5,511
    80004c72:	97a6                	add	a5,a5,s1
    80004c74:	0187c783          	lbu	a5,24(a5)
    80004c78:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c7c:	4685                	li	a3,1
    80004c7e:	fbf40613          	addi	a2,s0,-65
    80004c82:	85ca                	mv	a1,s2
    80004c84:	050a3503          	ld	a0,80(s4)
    80004c88:	ffffd097          	auipc	ra,0xffffd
    80004c8c:	aae080e7          	jalr	-1362(ra) # 80001736 <copyout>
    80004c90:	01650663          	beq	a0,s6,80004c9c <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c94:	2985                	addiw	s3,s3,1
    80004c96:	0905                	addi	s2,s2,1
    80004c98:	fd3a91e3          	bne	s5,s3,80004c5a <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c9c:	21c48513          	addi	a0,s1,540
    80004ca0:	ffffd097          	auipc	ra,0xffffd
    80004ca4:	768080e7          	jalr	1896(ra) # 80002408 <wakeup>
  release(&pi->lock);
    80004ca8:	8526                	mv	a0,s1
    80004caa:	ffffc097          	auipc	ra,0xffffc
    80004cae:	07e080e7          	jalr	126(ra) # 80000d28 <release>
  return i;
}
    80004cb2:	854e                	mv	a0,s3
    80004cb4:	60a6                	ld	ra,72(sp)
    80004cb6:	6406                	ld	s0,64(sp)
    80004cb8:	74e2                	ld	s1,56(sp)
    80004cba:	7942                	ld	s2,48(sp)
    80004cbc:	79a2                	ld	s3,40(sp)
    80004cbe:	7a02                	ld	s4,32(sp)
    80004cc0:	6ae2                	ld	s5,24(sp)
    80004cc2:	6b42                	ld	s6,16(sp)
    80004cc4:	6161                	addi	sp,sp,80
    80004cc6:	8082                	ret
      release(&pi->lock);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	05e080e7          	jalr	94(ra) # 80000d28 <release>
      return -1;
    80004cd2:	59fd                	li	s3,-1
    80004cd4:	bff9                	j	80004cb2 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cd6:	4981                	li	s3,0
    80004cd8:	b7d1                	j	80004c9c <piperead+0xae>

0000000080004cda <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004cda:	df010113          	addi	sp,sp,-528
    80004cde:	20113423          	sd	ra,520(sp)
    80004ce2:	20813023          	sd	s0,512(sp)
    80004ce6:	ffa6                	sd	s1,504(sp)
    80004ce8:	fbca                	sd	s2,496(sp)
    80004cea:	f7ce                	sd	s3,488(sp)
    80004cec:	f3d2                	sd	s4,480(sp)
    80004cee:	efd6                	sd	s5,472(sp)
    80004cf0:	ebda                	sd	s6,464(sp)
    80004cf2:	e7de                	sd	s7,456(sp)
    80004cf4:	e3e2                	sd	s8,448(sp)
    80004cf6:	ff66                	sd	s9,440(sp)
    80004cf8:	fb6a                	sd	s10,432(sp)
    80004cfa:	f76e                	sd	s11,424(sp)
    80004cfc:	0c00                	addi	s0,sp,528
    80004cfe:	84aa                	mv	s1,a0
    80004d00:	dea43c23          	sd	a0,-520(s0)
    80004d04:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d08:	ffffd097          	auipc	ra,0xffffd
    80004d0c:	d3a080e7          	jalr	-710(ra) # 80001a42 <myproc>
    80004d10:	892a                	mv	s2,a0

  begin_op();
    80004d12:	fffff097          	auipc	ra,0xfffff
    80004d16:	446080e7          	jalr	1094(ra) # 80004158 <begin_op>

  if((ip = namei(path)) == 0){
    80004d1a:	8526                	mv	a0,s1
    80004d1c:	fffff097          	auipc	ra,0xfffff
    80004d20:	230080e7          	jalr	560(ra) # 80003f4c <namei>
    80004d24:	c92d                	beqz	a0,80004d96 <exec+0xbc>
    80004d26:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d28:	fffff097          	auipc	ra,0xfffff
    80004d2c:	a74080e7          	jalr	-1420(ra) # 8000379c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d30:	04000713          	li	a4,64
    80004d34:	4681                	li	a3,0
    80004d36:	e4840613          	addi	a2,s0,-440
    80004d3a:	4581                	li	a1,0
    80004d3c:	8526                	mv	a0,s1
    80004d3e:	fffff097          	auipc	ra,0xfffff
    80004d42:	d12080e7          	jalr	-750(ra) # 80003a50 <readi>
    80004d46:	04000793          	li	a5,64
    80004d4a:	00f51a63          	bne	a0,a5,80004d5e <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d4e:	e4842703          	lw	a4,-440(s0)
    80004d52:	464c47b7          	lui	a5,0x464c4
    80004d56:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d5a:	04f70463          	beq	a4,a5,80004da2 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	fffff097          	auipc	ra,0xfffff
    80004d64:	c9e080e7          	jalr	-866(ra) # 800039fe <iunlockput>
    end_op();
    80004d68:	fffff097          	auipc	ra,0xfffff
    80004d6c:	470080e7          	jalr	1136(ra) # 800041d8 <end_op>
  }
  return -1;
    80004d70:	557d                	li	a0,-1
}
    80004d72:	20813083          	ld	ra,520(sp)
    80004d76:	20013403          	ld	s0,512(sp)
    80004d7a:	74fe                	ld	s1,504(sp)
    80004d7c:	795e                	ld	s2,496(sp)
    80004d7e:	79be                	ld	s3,488(sp)
    80004d80:	7a1e                	ld	s4,480(sp)
    80004d82:	6afe                	ld	s5,472(sp)
    80004d84:	6b5e                	ld	s6,464(sp)
    80004d86:	6bbe                	ld	s7,456(sp)
    80004d88:	6c1e                	ld	s8,448(sp)
    80004d8a:	7cfa                	ld	s9,440(sp)
    80004d8c:	7d5a                	ld	s10,432(sp)
    80004d8e:	7dba                	ld	s11,424(sp)
    80004d90:	21010113          	addi	sp,sp,528
    80004d94:	8082                	ret
    end_op();
    80004d96:	fffff097          	auipc	ra,0xfffff
    80004d9a:	442080e7          	jalr	1090(ra) # 800041d8 <end_op>
    return -1;
    80004d9e:	557d                	li	a0,-1
    80004da0:	bfc9                	j	80004d72 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004da2:	854a                	mv	a0,s2
    80004da4:	ffffd097          	auipc	ra,0xffffd
    80004da8:	d62080e7          	jalr	-670(ra) # 80001b06 <proc_pagetable>
    80004dac:	8baa                	mv	s7,a0
    80004dae:	d945                	beqz	a0,80004d5e <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004db0:	e6842983          	lw	s3,-408(s0)
    80004db4:	e8045783          	lhu	a5,-384(s0)
    80004db8:	c7ad                	beqz	a5,80004e22 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004dba:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dbc:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004dbe:	6c85                	lui	s9,0x1
    80004dc0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004dc4:	def43823          	sd	a5,-528(s0)
    80004dc8:	a42d                	j	80004ff2 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004dca:	00004517          	auipc	a0,0x4
    80004dce:	91650513          	addi	a0,a0,-1770 # 800086e0 <syscalls+0x2a0>
    80004dd2:	ffffc097          	auipc	ra,0xffffc
    80004dd6:	804080e7          	jalr	-2044(ra) # 800005d6 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004dda:	8756                	mv	a4,s5
    80004ddc:	012d86bb          	addw	a3,s11,s2
    80004de0:	4581                	li	a1,0
    80004de2:	8526                	mv	a0,s1
    80004de4:	fffff097          	auipc	ra,0xfffff
    80004de8:	c6c080e7          	jalr	-916(ra) # 80003a50 <readi>
    80004dec:	2501                	sext.w	a0,a0
    80004dee:	1aaa9963          	bne	s5,a0,80004fa0 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004df2:	6785                	lui	a5,0x1
    80004df4:	0127893b          	addw	s2,a5,s2
    80004df8:	77fd                	lui	a5,0xfffff
    80004dfa:	01478a3b          	addw	s4,a5,s4
    80004dfe:	1f897163          	bgeu	s2,s8,80004fe0 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004e02:	02091593          	slli	a1,s2,0x20
    80004e06:	9181                	srli	a1,a1,0x20
    80004e08:	95ea                	add	a1,a1,s10
    80004e0a:	855e                	mv	a0,s7
    80004e0c:	ffffc097          	auipc	ra,0xffffc
    80004e10:	2f6080e7          	jalr	758(ra) # 80001102 <walkaddr>
    80004e14:	862a                	mv	a2,a0
    if(pa == 0)
    80004e16:	d955                	beqz	a0,80004dca <exec+0xf0>
      n = PGSIZE;
    80004e18:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004e1a:	fd9a70e3          	bgeu	s4,s9,80004dda <exec+0x100>
      n = sz - i;
    80004e1e:	8ad2                	mv	s5,s4
    80004e20:	bf6d                	j	80004dda <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004e22:	4901                	li	s2,0
  iunlockput(ip);
    80004e24:	8526                	mv	a0,s1
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	bd8080e7          	jalr	-1064(ra) # 800039fe <iunlockput>
  end_op();
    80004e2e:	fffff097          	auipc	ra,0xfffff
    80004e32:	3aa080e7          	jalr	938(ra) # 800041d8 <end_op>
  p = myproc();
    80004e36:	ffffd097          	auipc	ra,0xffffd
    80004e3a:	c0c080e7          	jalr	-1012(ra) # 80001a42 <myproc>
    80004e3e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e40:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e44:	6785                	lui	a5,0x1
    80004e46:	17fd                	addi	a5,a5,-1
    80004e48:	993e                	add	s2,s2,a5
    80004e4a:	757d                	lui	a0,0xfffff
    80004e4c:	00a977b3          	and	a5,s2,a0
    80004e50:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e54:	6609                	lui	a2,0x2
    80004e56:	963e                	add	a2,a2,a5
    80004e58:	85be                	mv	a1,a5
    80004e5a:	855e                	mv	a0,s7
    80004e5c:	ffffc097          	auipc	ra,0xffffc
    80004e60:	68a080e7          	jalr	1674(ra) # 800014e6 <uvmalloc>
    80004e64:	8b2a                	mv	s6,a0
  ip = 0;
    80004e66:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e68:	12050c63          	beqz	a0,80004fa0 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e6c:	75f9                	lui	a1,0xffffe
    80004e6e:	95aa                	add	a1,a1,a0
    80004e70:	855e                	mv	a0,s7
    80004e72:	ffffd097          	auipc	ra,0xffffd
    80004e76:	892080e7          	jalr	-1902(ra) # 80001704 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e7a:	7c7d                	lui	s8,0xfffff
    80004e7c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e7e:	e0043783          	ld	a5,-512(s0)
    80004e82:	6388                	ld	a0,0(a5)
    80004e84:	c535                	beqz	a0,80004ef0 <exec+0x216>
    80004e86:	e8840993          	addi	s3,s0,-376
    80004e8a:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004e8e:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004e90:	ffffc097          	auipc	ra,0xffffc
    80004e94:	068080e7          	jalr	104(ra) # 80000ef8 <strlen>
    80004e98:	2505                	addiw	a0,a0,1
    80004e9a:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e9e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004ea2:	13896363          	bltu	s2,s8,80004fc8 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ea6:	e0043d83          	ld	s11,-512(s0)
    80004eaa:	000dba03          	ld	s4,0(s11)
    80004eae:	8552                	mv	a0,s4
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	048080e7          	jalr	72(ra) # 80000ef8 <strlen>
    80004eb8:	0015069b          	addiw	a3,a0,1
    80004ebc:	8652                	mv	a2,s4
    80004ebe:	85ca                	mv	a1,s2
    80004ec0:	855e                	mv	a0,s7
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	874080e7          	jalr	-1932(ra) # 80001736 <copyout>
    80004eca:	10054363          	bltz	a0,80004fd0 <exec+0x2f6>
    ustack[argc] = sp;
    80004ece:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ed2:	0485                	addi	s1,s1,1
    80004ed4:	008d8793          	addi	a5,s11,8
    80004ed8:	e0f43023          	sd	a5,-512(s0)
    80004edc:	008db503          	ld	a0,8(s11)
    80004ee0:	c911                	beqz	a0,80004ef4 <exec+0x21a>
    if(argc >= MAXARG)
    80004ee2:	09a1                	addi	s3,s3,8
    80004ee4:	fb3c96e3          	bne	s9,s3,80004e90 <exec+0x1b6>
  sz = sz1;
    80004ee8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004eec:	4481                	li	s1,0
    80004eee:	a84d                	j	80004fa0 <exec+0x2c6>
  sp = sz;
    80004ef0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004ef2:	4481                	li	s1,0
  ustack[argc] = 0;
    80004ef4:	00349793          	slli	a5,s1,0x3
    80004ef8:	f9040713          	addi	a4,s0,-112
    80004efc:	97ba                	add	a5,a5,a4
    80004efe:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004f02:	00148693          	addi	a3,s1,1
    80004f06:	068e                	slli	a3,a3,0x3
    80004f08:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f0c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004f10:	01897663          	bgeu	s2,s8,80004f1c <exec+0x242>
  sz = sz1;
    80004f14:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f18:	4481                	li	s1,0
    80004f1a:	a059                	j	80004fa0 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f1c:	e8840613          	addi	a2,s0,-376
    80004f20:	85ca                	mv	a1,s2
    80004f22:	855e                	mv	a0,s7
    80004f24:	ffffd097          	auipc	ra,0xffffd
    80004f28:	812080e7          	jalr	-2030(ra) # 80001736 <copyout>
    80004f2c:	0a054663          	bltz	a0,80004fd8 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004f30:	058ab783          	ld	a5,88(s5)
    80004f34:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f38:	df843783          	ld	a5,-520(s0)
    80004f3c:	0007c703          	lbu	a4,0(a5)
    80004f40:	cf11                	beqz	a4,80004f5c <exec+0x282>
    80004f42:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f44:	02f00693          	li	a3,47
    80004f48:	a029                	j	80004f52 <exec+0x278>
  for(last=s=path; *s; s++)
    80004f4a:	0785                	addi	a5,a5,1
    80004f4c:	fff7c703          	lbu	a4,-1(a5)
    80004f50:	c711                	beqz	a4,80004f5c <exec+0x282>
    if(*s == '/')
    80004f52:	fed71ce3          	bne	a4,a3,80004f4a <exec+0x270>
      last = s+1;
    80004f56:	def43c23          	sd	a5,-520(s0)
    80004f5a:	bfc5                	j	80004f4a <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f5c:	4641                	li	a2,16
    80004f5e:	df843583          	ld	a1,-520(s0)
    80004f62:	158a8513          	addi	a0,s5,344
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	f60080e7          	jalr	-160(ra) # 80000ec6 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f6e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f72:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004f76:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f7a:	058ab783          	ld	a5,88(s5)
    80004f7e:	e6043703          	ld	a4,-416(s0)
    80004f82:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f84:	058ab783          	ld	a5,88(s5)
    80004f88:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f8c:	85ea                	mv	a1,s10
    80004f8e:	ffffd097          	auipc	ra,0xffffd
    80004f92:	c14080e7          	jalr	-1004(ra) # 80001ba2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f96:	0004851b          	sext.w	a0,s1
    80004f9a:	bbe1                	j	80004d72 <exec+0x98>
    80004f9c:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004fa0:	e0843583          	ld	a1,-504(s0)
    80004fa4:	855e                	mv	a0,s7
    80004fa6:	ffffd097          	auipc	ra,0xffffd
    80004faa:	bfc080e7          	jalr	-1028(ra) # 80001ba2 <proc_freepagetable>
  if(ip){
    80004fae:	da0498e3          	bnez	s1,80004d5e <exec+0x84>
  return -1;
    80004fb2:	557d                	li	a0,-1
    80004fb4:	bb7d                	j	80004d72 <exec+0x98>
    80004fb6:	e1243423          	sd	s2,-504(s0)
    80004fba:	b7dd                	j	80004fa0 <exec+0x2c6>
    80004fbc:	e1243423          	sd	s2,-504(s0)
    80004fc0:	b7c5                	j	80004fa0 <exec+0x2c6>
    80004fc2:	e1243423          	sd	s2,-504(s0)
    80004fc6:	bfe9                	j	80004fa0 <exec+0x2c6>
  sz = sz1;
    80004fc8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fcc:	4481                	li	s1,0
    80004fce:	bfc9                	j	80004fa0 <exec+0x2c6>
  sz = sz1;
    80004fd0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fd4:	4481                	li	s1,0
    80004fd6:	b7e9                	j	80004fa0 <exec+0x2c6>
  sz = sz1;
    80004fd8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fdc:	4481                	li	s1,0
    80004fde:	b7c9                	j	80004fa0 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fe0:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fe4:	2b05                	addiw	s6,s6,1
    80004fe6:	0389899b          	addiw	s3,s3,56
    80004fea:	e8045783          	lhu	a5,-384(s0)
    80004fee:	e2fb5be3          	bge	s6,a5,80004e24 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ff2:	2981                	sext.w	s3,s3
    80004ff4:	03800713          	li	a4,56
    80004ff8:	86ce                	mv	a3,s3
    80004ffa:	e1040613          	addi	a2,s0,-496
    80004ffe:	4581                	li	a1,0
    80005000:	8526                	mv	a0,s1
    80005002:	fffff097          	auipc	ra,0xfffff
    80005006:	a4e080e7          	jalr	-1458(ra) # 80003a50 <readi>
    8000500a:	03800793          	li	a5,56
    8000500e:	f8f517e3          	bne	a0,a5,80004f9c <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005012:	e1042783          	lw	a5,-496(s0)
    80005016:	4705                	li	a4,1
    80005018:	fce796e3          	bne	a5,a4,80004fe4 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    8000501c:	e3843603          	ld	a2,-456(s0)
    80005020:	e3043783          	ld	a5,-464(s0)
    80005024:	f8f669e3          	bltu	a2,a5,80004fb6 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005028:	e2043783          	ld	a5,-480(s0)
    8000502c:	963e                	add	a2,a2,a5
    8000502e:	f8f667e3          	bltu	a2,a5,80004fbc <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005032:	85ca                	mv	a1,s2
    80005034:	855e                	mv	a0,s7
    80005036:	ffffc097          	auipc	ra,0xffffc
    8000503a:	4b0080e7          	jalr	1200(ra) # 800014e6 <uvmalloc>
    8000503e:	e0a43423          	sd	a0,-504(s0)
    80005042:	d141                	beqz	a0,80004fc2 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80005044:	e2043d03          	ld	s10,-480(s0)
    80005048:	df043783          	ld	a5,-528(s0)
    8000504c:	00fd77b3          	and	a5,s10,a5
    80005050:	fba1                	bnez	a5,80004fa0 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005052:	e1842d83          	lw	s11,-488(s0)
    80005056:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000505a:	f80c03e3          	beqz	s8,80004fe0 <exec+0x306>
    8000505e:	8a62                	mv	s4,s8
    80005060:	4901                	li	s2,0
    80005062:	b345                	j	80004e02 <exec+0x128>

0000000080005064 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005064:	7179                	addi	sp,sp,-48
    80005066:	f406                	sd	ra,40(sp)
    80005068:	f022                	sd	s0,32(sp)
    8000506a:	ec26                	sd	s1,24(sp)
    8000506c:	e84a                	sd	s2,16(sp)
    8000506e:	1800                	addi	s0,sp,48
    80005070:	892e                	mv	s2,a1
    80005072:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005074:	fdc40593          	addi	a1,s0,-36
    80005078:	ffffe097          	auipc	ra,0xffffe
    8000507c:	b08080e7          	jalr	-1272(ra) # 80002b80 <argint>
    80005080:	04054063          	bltz	a0,800050c0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005084:	fdc42703          	lw	a4,-36(s0)
    80005088:	47bd                	li	a5,15
    8000508a:	02e7ed63          	bltu	a5,a4,800050c4 <argfd+0x60>
    8000508e:	ffffd097          	auipc	ra,0xffffd
    80005092:	9b4080e7          	jalr	-1612(ra) # 80001a42 <myproc>
    80005096:	fdc42703          	lw	a4,-36(s0)
    8000509a:	01a70793          	addi	a5,a4,26
    8000509e:	078e                	slli	a5,a5,0x3
    800050a0:	953e                	add	a0,a0,a5
    800050a2:	611c                	ld	a5,0(a0)
    800050a4:	c395                	beqz	a5,800050c8 <argfd+0x64>
    return -1;
  if(pfd)
    800050a6:	00090463          	beqz	s2,800050ae <argfd+0x4a>
    *pfd = fd;
    800050aa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800050ae:	4501                	li	a0,0
  if(pf)
    800050b0:	c091                	beqz	s1,800050b4 <argfd+0x50>
    *pf = f;
    800050b2:	e09c                	sd	a5,0(s1)
}
    800050b4:	70a2                	ld	ra,40(sp)
    800050b6:	7402                	ld	s0,32(sp)
    800050b8:	64e2                	ld	s1,24(sp)
    800050ba:	6942                	ld	s2,16(sp)
    800050bc:	6145                	addi	sp,sp,48
    800050be:	8082                	ret
    return -1;
    800050c0:	557d                	li	a0,-1
    800050c2:	bfcd                	j	800050b4 <argfd+0x50>
    return -1;
    800050c4:	557d                	li	a0,-1
    800050c6:	b7fd                	j	800050b4 <argfd+0x50>
    800050c8:	557d                	li	a0,-1
    800050ca:	b7ed                	j	800050b4 <argfd+0x50>

00000000800050cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050cc:	1101                	addi	sp,sp,-32
    800050ce:	ec06                	sd	ra,24(sp)
    800050d0:	e822                	sd	s0,16(sp)
    800050d2:	e426                	sd	s1,8(sp)
    800050d4:	1000                	addi	s0,sp,32
    800050d6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050d8:	ffffd097          	auipc	ra,0xffffd
    800050dc:	96a080e7          	jalr	-1686(ra) # 80001a42 <myproc>
    800050e0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050e2:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd80d0>
    800050e6:	4501                	li	a0,0
    800050e8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050ea:	6398                	ld	a4,0(a5)
    800050ec:	cb19                	beqz	a4,80005102 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050ee:	2505                	addiw	a0,a0,1
    800050f0:	07a1                	addi	a5,a5,8
    800050f2:	fed51ce3          	bne	a0,a3,800050ea <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050f6:	557d                	li	a0,-1
}
    800050f8:	60e2                	ld	ra,24(sp)
    800050fa:	6442                	ld	s0,16(sp)
    800050fc:	64a2                	ld	s1,8(sp)
    800050fe:	6105                	addi	sp,sp,32
    80005100:	8082                	ret
      p->ofile[fd] = f;
    80005102:	01a50793          	addi	a5,a0,26
    80005106:	078e                	slli	a5,a5,0x3
    80005108:	963e                	add	a2,a2,a5
    8000510a:	e204                	sd	s1,0(a2)
      return fd;
    8000510c:	b7f5                	j	800050f8 <fdalloc+0x2c>

000000008000510e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000510e:	715d                	addi	sp,sp,-80
    80005110:	e486                	sd	ra,72(sp)
    80005112:	e0a2                	sd	s0,64(sp)
    80005114:	fc26                	sd	s1,56(sp)
    80005116:	f84a                	sd	s2,48(sp)
    80005118:	f44e                	sd	s3,40(sp)
    8000511a:	f052                	sd	s4,32(sp)
    8000511c:	ec56                	sd	s5,24(sp)
    8000511e:	0880                	addi	s0,sp,80
    80005120:	89ae                	mv	s3,a1
    80005122:	8ab2                	mv	s5,a2
    80005124:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005126:	fb040593          	addi	a1,s0,-80
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	e40080e7          	jalr	-448(ra) # 80003f6a <nameiparent>
    80005132:	892a                	mv	s2,a0
    80005134:	12050f63          	beqz	a0,80005272 <create+0x164>
    return 0;

  ilock(dp);
    80005138:	ffffe097          	auipc	ra,0xffffe
    8000513c:	664080e7          	jalr	1636(ra) # 8000379c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005140:	4601                	li	a2,0
    80005142:	fb040593          	addi	a1,s0,-80
    80005146:	854a                	mv	a0,s2
    80005148:	fffff097          	auipc	ra,0xfffff
    8000514c:	b32080e7          	jalr	-1230(ra) # 80003c7a <dirlookup>
    80005150:	84aa                	mv	s1,a0
    80005152:	c921                	beqz	a0,800051a2 <create+0x94>
    iunlockput(dp);
    80005154:	854a                	mv	a0,s2
    80005156:	fffff097          	auipc	ra,0xfffff
    8000515a:	8a8080e7          	jalr	-1880(ra) # 800039fe <iunlockput>
    ilock(ip);
    8000515e:	8526                	mv	a0,s1
    80005160:	ffffe097          	auipc	ra,0xffffe
    80005164:	63c080e7          	jalr	1596(ra) # 8000379c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005168:	2981                	sext.w	s3,s3
    8000516a:	4789                	li	a5,2
    8000516c:	02f99463          	bne	s3,a5,80005194 <create+0x86>
    80005170:	0444d783          	lhu	a5,68(s1)
    80005174:	37f9                	addiw	a5,a5,-2
    80005176:	17c2                	slli	a5,a5,0x30
    80005178:	93c1                	srli	a5,a5,0x30
    8000517a:	4705                	li	a4,1
    8000517c:	00f76c63          	bltu	a4,a5,80005194 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005180:	8526                	mv	a0,s1
    80005182:	60a6                	ld	ra,72(sp)
    80005184:	6406                	ld	s0,64(sp)
    80005186:	74e2                	ld	s1,56(sp)
    80005188:	7942                	ld	s2,48(sp)
    8000518a:	79a2                	ld	s3,40(sp)
    8000518c:	7a02                	ld	s4,32(sp)
    8000518e:	6ae2                	ld	s5,24(sp)
    80005190:	6161                	addi	sp,sp,80
    80005192:	8082                	ret
    iunlockput(ip);
    80005194:	8526                	mv	a0,s1
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	868080e7          	jalr	-1944(ra) # 800039fe <iunlockput>
    return 0;
    8000519e:	4481                	li	s1,0
    800051a0:	b7c5                	j	80005180 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800051a2:	85ce                	mv	a1,s3
    800051a4:	00092503          	lw	a0,0(s2)
    800051a8:	ffffe097          	auipc	ra,0xffffe
    800051ac:	45c080e7          	jalr	1116(ra) # 80003604 <ialloc>
    800051b0:	84aa                	mv	s1,a0
    800051b2:	c529                	beqz	a0,800051fc <create+0xee>
  ilock(ip);
    800051b4:	ffffe097          	auipc	ra,0xffffe
    800051b8:	5e8080e7          	jalr	1512(ra) # 8000379c <ilock>
  ip->major = major;
    800051bc:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800051c0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800051c4:	4785                	li	a5,1
    800051c6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051ca:	8526                	mv	a0,s1
    800051cc:	ffffe097          	auipc	ra,0xffffe
    800051d0:	506080e7          	jalr	1286(ra) # 800036d2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051d4:	2981                	sext.w	s3,s3
    800051d6:	4785                	li	a5,1
    800051d8:	02f98a63          	beq	s3,a5,8000520c <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800051dc:	40d0                	lw	a2,4(s1)
    800051de:	fb040593          	addi	a1,s0,-80
    800051e2:	854a                	mv	a0,s2
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	ca6080e7          	jalr	-858(ra) # 80003e8a <dirlink>
    800051ec:	06054b63          	bltz	a0,80005262 <create+0x154>
  iunlockput(dp);
    800051f0:	854a                	mv	a0,s2
    800051f2:	fffff097          	auipc	ra,0xfffff
    800051f6:	80c080e7          	jalr	-2036(ra) # 800039fe <iunlockput>
  return ip;
    800051fa:	b759                	j	80005180 <create+0x72>
    panic("create: ialloc");
    800051fc:	00003517          	auipc	a0,0x3
    80005200:	50450513          	addi	a0,a0,1284 # 80008700 <syscalls+0x2c0>
    80005204:	ffffb097          	auipc	ra,0xffffb
    80005208:	3d2080e7          	jalr	978(ra) # 800005d6 <panic>
    dp->nlink++;  // for ".."
    8000520c:	04a95783          	lhu	a5,74(s2)
    80005210:	2785                	addiw	a5,a5,1
    80005212:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005216:	854a                	mv	a0,s2
    80005218:	ffffe097          	auipc	ra,0xffffe
    8000521c:	4ba080e7          	jalr	1210(ra) # 800036d2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005220:	40d0                	lw	a2,4(s1)
    80005222:	00003597          	auipc	a1,0x3
    80005226:	4ee58593          	addi	a1,a1,1262 # 80008710 <syscalls+0x2d0>
    8000522a:	8526                	mv	a0,s1
    8000522c:	fffff097          	auipc	ra,0xfffff
    80005230:	c5e080e7          	jalr	-930(ra) # 80003e8a <dirlink>
    80005234:	00054f63          	bltz	a0,80005252 <create+0x144>
    80005238:	00492603          	lw	a2,4(s2)
    8000523c:	00003597          	auipc	a1,0x3
    80005240:	4dc58593          	addi	a1,a1,1244 # 80008718 <syscalls+0x2d8>
    80005244:	8526                	mv	a0,s1
    80005246:	fffff097          	auipc	ra,0xfffff
    8000524a:	c44080e7          	jalr	-956(ra) # 80003e8a <dirlink>
    8000524e:	f80557e3          	bgez	a0,800051dc <create+0xce>
      panic("create dots");
    80005252:	00003517          	auipc	a0,0x3
    80005256:	4ce50513          	addi	a0,a0,1230 # 80008720 <syscalls+0x2e0>
    8000525a:	ffffb097          	auipc	ra,0xffffb
    8000525e:	37c080e7          	jalr	892(ra) # 800005d6 <panic>
    panic("create: dirlink");
    80005262:	00003517          	auipc	a0,0x3
    80005266:	4ce50513          	addi	a0,a0,1230 # 80008730 <syscalls+0x2f0>
    8000526a:	ffffb097          	auipc	ra,0xffffb
    8000526e:	36c080e7          	jalr	876(ra) # 800005d6 <panic>
    return 0;
    80005272:	84aa                	mv	s1,a0
    80005274:	b731                	j	80005180 <create+0x72>

0000000080005276 <sys_dup>:
{
    80005276:	7179                	addi	sp,sp,-48
    80005278:	f406                	sd	ra,40(sp)
    8000527a:	f022                	sd	s0,32(sp)
    8000527c:	ec26                	sd	s1,24(sp)
    8000527e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005280:	fd840613          	addi	a2,s0,-40
    80005284:	4581                	li	a1,0
    80005286:	4501                	li	a0,0
    80005288:	00000097          	auipc	ra,0x0
    8000528c:	ddc080e7          	jalr	-548(ra) # 80005064 <argfd>
    return -1;
    80005290:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005292:	02054363          	bltz	a0,800052b8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005296:	fd843503          	ld	a0,-40(s0)
    8000529a:	00000097          	auipc	ra,0x0
    8000529e:	e32080e7          	jalr	-462(ra) # 800050cc <fdalloc>
    800052a2:	84aa                	mv	s1,a0
    return -1;
    800052a4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052a6:	00054963          	bltz	a0,800052b8 <sys_dup+0x42>
  filedup(f);
    800052aa:	fd843503          	ld	a0,-40(s0)
    800052ae:	fffff097          	auipc	ra,0xfffff
    800052b2:	32a080e7          	jalr	810(ra) # 800045d8 <filedup>
  return fd;
    800052b6:	87a6                	mv	a5,s1
}
    800052b8:	853e                	mv	a0,a5
    800052ba:	70a2                	ld	ra,40(sp)
    800052bc:	7402                	ld	s0,32(sp)
    800052be:	64e2                	ld	s1,24(sp)
    800052c0:	6145                	addi	sp,sp,48
    800052c2:	8082                	ret

00000000800052c4 <sys_read>:
{
    800052c4:	7179                	addi	sp,sp,-48
    800052c6:	f406                	sd	ra,40(sp)
    800052c8:	f022                	sd	s0,32(sp)
    800052ca:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052cc:	fe840613          	addi	a2,s0,-24
    800052d0:	4581                	li	a1,0
    800052d2:	4501                	li	a0,0
    800052d4:	00000097          	auipc	ra,0x0
    800052d8:	d90080e7          	jalr	-624(ra) # 80005064 <argfd>
    return -1;
    800052dc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052de:	04054163          	bltz	a0,80005320 <sys_read+0x5c>
    800052e2:	fe440593          	addi	a1,s0,-28
    800052e6:	4509                	li	a0,2
    800052e8:	ffffe097          	auipc	ra,0xffffe
    800052ec:	898080e7          	jalr	-1896(ra) # 80002b80 <argint>
    return -1;
    800052f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052f2:	02054763          	bltz	a0,80005320 <sys_read+0x5c>
    800052f6:	fd840593          	addi	a1,s0,-40
    800052fa:	4505                	li	a0,1
    800052fc:	ffffe097          	auipc	ra,0xffffe
    80005300:	8a6080e7          	jalr	-1882(ra) # 80002ba2 <argaddr>
    return -1;
    80005304:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005306:	00054d63          	bltz	a0,80005320 <sys_read+0x5c>
  return fileread(f, p, n);
    8000530a:	fe442603          	lw	a2,-28(s0)
    8000530e:	fd843583          	ld	a1,-40(s0)
    80005312:	fe843503          	ld	a0,-24(s0)
    80005316:	fffff097          	auipc	ra,0xfffff
    8000531a:	44e080e7          	jalr	1102(ra) # 80004764 <fileread>
    8000531e:	87aa                	mv	a5,a0
}
    80005320:	853e                	mv	a0,a5
    80005322:	70a2                	ld	ra,40(sp)
    80005324:	7402                	ld	s0,32(sp)
    80005326:	6145                	addi	sp,sp,48
    80005328:	8082                	ret

000000008000532a <sys_write>:
{
    8000532a:	7179                	addi	sp,sp,-48
    8000532c:	f406                	sd	ra,40(sp)
    8000532e:	f022                	sd	s0,32(sp)
    80005330:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005332:	fe840613          	addi	a2,s0,-24
    80005336:	4581                	li	a1,0
    80005338:	4501                	li	a0,0
    8000533a:	00000097          	auipc	ra,0x0
    8000533e:	d2a080e7          	jalr	-726(ra) # 80005064 <argfd>
    return -1;
    80005342:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005344:	04054163          	bltz	a0,80005386 <sys_write+0x5c>
    80005348:	fe440593          	addi	a1,s0,-28
    8000534c:	4509                	li	a0,2
    8000534e:	ffffe097          	auipc	ra,0xffffe
    80005352:	832080e7          	jalr	-1998(ra) # 80002b80 <argint>
    return -1;
    80005356:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005358:	02054763          	bltz	a0,80005386 <sys_write+0x5c>
    8000535c:	fd840593          	addi	a1,s0,-40
    80005360:	4505                	li	a0,1
    80005362:	ffffe097          	auipc	ra,0xffffe
    80005366:	840080e7          	jalr	-1984(ra) # 80002ba2 <argaddr>
    return -1;
    8000536a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000536c:	00054d63          	bltz	a0,80005386 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005370:	fe442603          	lw	a2,-28(s0)
    80005374:	fd843583          	ld	a1,-40(s0)
    80005378:	fe843503          	ld	a0,-24(s0)
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	4aa080e7          	jalr	1194(ra) # 80004826 <filewrite>
    80005384:	87aa                	mv	a5,a0
}
    80005386:	853e                	mv	a0,a5
    80005388:	70a2                	ld	ra,40(sp)
    8000538a:	7402                	ld	s0,32(sp)
    8000538c:	6145                	addi	sp,sp,48
    8000538e:	8082                	ret

0000000080005390 <sys_close>:
{
    80005390:	1101                	addi	sp,sp,-32
    80005392:	ec06                	sd	ra,24(sp)
    80005394:	e822                	sd	s0,16(sp)
    80005396:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005398:	fe040613          	addi	a2,s0,-32
    8000539c:	fec40593          	addi	a1,s0,-20
    800053a0:	4501                	li	a0,0
    800053a2:	00000097          	auipc	ra,0x0
    800053a6:	cc2080e7          	jalr	-830(ra) # 80005064 <argfd>
    return -1;
    800053aa:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053ac:	02054463          	bltz	a0,800053d4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	692080e7          	jalr	1682(ra) # 80001a42 <myproc>
    800053b8:	fec42783          	lw	a5,-20(s0)
    800053bc:	07e9                	addi	a5,a5,26
    800053be:	078e                	slli	a5,a5,0x3
    800053c0:	97aa                	add	a5,a5,a0
    800053c2:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800053c6:	fe043503          	ld	a0,-32(s0)
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	260080e7          	jalr	608(ra) # 8000462a <fileclose>
  return 0;
    800053d2:	4781                	li	a5,0
}
    800053d4:	853e                	mv	a0,a5
    800053d6:	60e2                	ld	ra,24(sp)
    800053d8:	6442                	ld	s0,16(sp)
    800053da:	6105                	addi	sp,sp,32
    800053dc:	8082                	ret

00000000800053de <sys_fstat>:
{
    800053de:	1101                	addi	sp,sp,-32
    800053e0:	ec06                	sd	ra,24(sp)
    800053e2:	e822                	sd	s0,16(sp)
    800053e4:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053e6:	fe840613          	addi	a2,s0,-24
    800053ea:	4581                	li	a1,0
    800053ec:	4501                	li	a0,0
    800053ee:	00000097          	auipc	ra,0x0
    800053f2:	c76080e7          	jalr	-906(ra) # 80005064 <argfd>
    return -1;
    800053f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053f8:	02054563          	bltz	a0,80005422 <sys_fstat+0x44>
    800053fc:	fe040593          	addi	a1,s0,-32
    80005400:	4505                	li	a0,1
    80005402:	ffffd097          	auipc	ra,0xffffd
    80005406:	7a0080e7          	jalr	1952(ra) # 80002ba2 <argaddr>
    return -1;
    8000540a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000540c:	00054b63          	bltz	a0,80005422 <sys_fstat+0x44>
  return filestat(f, st);
    80005410:	fe043583          	ld	a1,-32(s0)
    80005414:	fe843503          	ld	a0,-24(s0)
    80005418:	fffff097          	auipc	ra,0xfffff
    8000541c:	2da080e7          	jalr	730(ra) # 800046f2 <filestat>
    80005420:	87aa                	mv	a5,a0
}
    80005422:	853e                	mv	a0,a5
    80005424:	60e2                	ld	ra,24(sp)
    80005426:	6442                	ld	s0,16(sp)
    80005428:	6105                	addi	sp,sp,32
    8000542a:	8082                	ret

000000008000542c <sys_link>:
{
    8000542c:	7169                	addi	sp,sp,-304
    8000542e:	f606                	sd	ra,296(sp)
    80005430:	f222                	sd	s0,288(sp)
    80005432:	ee26                	sd	s1,280(sp)
    80005434:	ea4a                	sd	s2,272(sp)
    80005436:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005438:	08000613          	li	a2,128
    8000543c:	ed040593          	addi	a1,s0,-304
    80005440:	4501                	li	a0,0
    80005442:	ffffd097          	auipc	ra,0xffffd
    80005446:	782080e7          	jalr	1922(ra) # 80002bc4 <argstr>
    return -1;
    8000544a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000544c:	10054e63          	bltz	a0,80005568 <sys_link+0x13c>
    80005450:	08000613          	li	a2,128
    80005454:	f5040593          	addi	a1,s0,-176
    80005458:	4505                	li	a0,1
    8000545a:	ffffd097          	auipc	ra,0xffffd
    8000545e:	76a080e7          	jalr	1898(ra) # 80002bc4 <argstr>
    return -1;
    80005462:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005464:	10054263          	bltz	a0,80005568 <sys_link+0x13c>
  begin_op();
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	cf0080e7          	jalr	-784(ra) # 80004158 <begin_op>
  if((ip = namei(old)) == 0){
    80005470:	ed040513          	addi	a0,s0,-304
    80005474:	fffff097          	auipc	ra,0xfffff
    80005478:	ad8080e7          	jalr	-1320(ra) # 80003f4c <namei>
    8000547c:	84aa                	mv	s1,a0
    8000547e:	c551                	beqz	a0,8000550a <sys_link+0xde>
  ilock(ip);
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	31c080e7          	jalr	796(ra) # 8000379c <ilock>
  if(ip->type == T_DIR){
    80005488:	04449703          	lh	a4,68(s1)
    8000548c:	4785                	li	a5,1
    8000548e:	08f70463          	beq	a4,a5,80005516 <sys_link+0xea>
  ip->nlink++;
    80005492:	04a4d783          	lhu	a5,74(s1)
    80005496:	2785                	addiw	a5,a5,1
    80005498:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	234080e7          	jalr	564(ra) # 800036d2 <iupdate>
  iunlock(ip);
    800054a6:	8526                	mv	a0,s1
    800054a8:	ffffe097          	auipc	ra,0xffffe
    800054ac:	3b6080e7          	jalr	950(ra) # 8000385e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054b0:	fd040593          	addi	a1,s0,-48
    800054b4:	f5040513          	addi	a0,s0,-176
    800054b8:	fffff097          	auipc	ra,0xfffff
    800054bc:	ab2080e7          	jalr	-1358(ra) # 80003f6a <nameiparent>
    800054c0:	892a                	mv	s2,a0
    800054c2:	c935                	beqz	a0,80005536 <sys_link+0x10a>
  ilock(dp);
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	2d8080e7          	jalr	728(ra) # 8000379c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054cc:	00092703          	lw	a4,0(s2)
    800054d0:	409c                	lw	a5,0(s1)
    800054d2:	04f71d63          	bne	a4,a5,8000552c <sys_link+0x100>
    800054d6:	40d0                	lw	a2,4(s1)
    800054d8:	fd040593          	addi	a1,s0,-48
    800054dc:	854a                	mv	a0,s2
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	9ac080e7          	jalr	-1620(ra) # 80003e8a <dirlink>
    800054e6:	04054363          	bltz	a0,8000552c <sys_link+0x100>
  iunlockput(dp);
    800054ea:	854a                	mv	a0,s2
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	512080e7          	jalr	1298(ra) # 800039fe <iunlockput>
  iput(ip);
    800054f4:	8526                	mv	a0,s1
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	460080e7          	jalr	1120(ra) # 80003956 <iput>
  end_op();
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	cda080e7          	jalr	-806(ra) # 800041d8 <end_op>
  return 0;
    80005506:	4781                	li	a5,0
    80005508:	a085                	j	80005568 <sys_link+0x13c>
    end_op();
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	cce080e7          	jalr	-818(ra) # 800041d8 <end_op>
    return -1;
    80005512:	57fd                	li	a5,-1
    80005514:	a891                	j	80005568 <sys_link+0x13c>
    iunlockput(ip);
    80005516:	8526                	mv	a0,s1
    80005518:	ffffe097          	auipc	ra,0xffffe
    8000551c:	4e6080e7          	jalr	1254(ra) # 800039fe <iunlockput>
    end_op();
    80005520:	fffff097          	auipc	ra,0xfffff
    80005524:	cb8080e7          	jalr	-840(ra) # 800041d8 <end_op>
    return -1;
    80005528:	57fd                	li	a5,-1
    8000552a:	a83d                	j	80005568 <sys_link+0x13c>
    iunlockput(dp);
    8000552c:	854a                	mv	a0,s2
    8000552e:	ffffe097          	auipc	ra,0xffffe
    80005532:	4d0080e7          	jalr	1232(ra) # 800039fe <iunlockput>
  ilock(ip);
    80005536:	8526                	mv	a0,s1
    80005538:	ffffe097          	auipc	ra,0xffffe
    8000553c:	264080e7          	jalr	612(ra) # 8000379c <ilock>
  ip->nlink--;
    80005540:	04a4d783          	lhu	a5,74(s1)
    80005544:	37fd                	addiw	a5,a5,-1
    80005546:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000554a:	8526                	mv	a0,s1
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	186080e7          	jalr	390(ra) # 800036d2 <iupdate>
  iunlockput(ip);
    80005554:	8526                	mv	a0,s1
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	4a8080e7          	jalr	1192(ra) # 800039fe <iunlockput>
  end_op();
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	c7a080e7          	jalr	-902(ra) # 800041d8 <end_op>
  return -1;
    80005566:	57fd                	li	a5,-1
}
    80005568:	853e                	mv	a0,a5
    8000556a:	70b2                	ld	ra,296(sp)
    8000556c:	7412                	ld	s0,288(sp)
    8000556e:	64f2                	ld	s1,280(sp)
    80005570:	6952                	ld	s2,272(sp)
    80005572:	6155                	addi	sp,sp,304
    80005574:	8082                	ret

0000000080005576 <sys_unlink>:
{
    80005576:	7151                	addi	sp,sp,-240
    80005578:	f586                	sd	ra,232(sp)
    8000557a:	f1a2                	sd	s0,224(sp)
    8000557c:	eda6                	sd	s1,216(sp)
    8000557e:	e9ca                	sd	s2,208(sp)
    80005580:	e5ce                	sd	s3,200(sp)
    80005582:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005584:	08000613          	li	a2,128
    80005588:	f3040593          	addi	a1,s0,-208
    8000558c:	4501                	li	a0,0
    8000558e:	ffffd097          	auipc	ra,0xffffd
    80005592:	636080e7          	jalr	1590(ra) # 80002bc4 <argstr>
    80005596:	18054163          	bltz	a0,80005718 <sys_unlink+0x1a2>
  begin_op();
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	bbe080e7          	jalr	-1090(ra) # 80004158 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800055a2:	fb040593          	addi	a1,s0,-80
    800055a6:	f3040513          	addi	a0,s0,-208
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	9c0080e7          	jalr	-1600(ra) # 80003f6a <nameiparent>
    800055b2:	84aa                	mv	s1,a0
    800055b4:	c979                	beqz	a0,8000568a <sys_unlink+0x114>
  ilock(dp);
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	1e6080e7          	jalr	486(ra) # 8000379c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055be:	00003597          	auipc	a1,0x3
    800055c2:	15258593          	addi	a1,a1,338 # 80008710 <syscalls+0x2d0>
    800055c6:	fb040513          	addi	a0,s0,-80
    800055ca:	ffffe097          	auipc	ra,0xffffe
    800055ce:	696080e7          	jalr	1686(ra) # 80003c60 <namecmp>
    800055d2:	14050a63          	beqz	a0,80005726 <sys_unlink+0x1b0>
    800055d6:	00003597          	auipc	a1,0x3
    800055da:	14258593          	addi	a1,a1,322 # 80008718 <syscalls+0x2d8>
    800055de:	fb040513          	addi	a0,s0,-80
    800055e2:	ffffe097          	auipc	ra,0xffffe
    800055e6:	67e080e7          	jalr	1662(ra) # 80003c60 <namecmp>
    800055ea:	12050e63          	beqz	a0,80005726 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055ee:	f2c40613          	addi	a2,s0,-212
    800055f2:	fb040593          	addi	a1,s0,-80
    800055f6:	8526                	mv	a0,s1
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	682080e7          	jalr	1666(ra) # 80003c7a <dirlookup>
    80005600:	892a                	mv	s2,a0
    80005602:	12050263          	beqz	a0,80005726 <sys_unlink+0x1b0>
  ilock(ip);
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	196080e7          	jalr	406(ra) # 8000379c <ilock>
  if(ip->nlink < 1)
    8000560e:	04a91783          	lh	a5,74(s2)
    80005612:	08f05263          	blez	a5,80005696 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005616:	04491703          	lh	a4,68(s2)
    8000561a:	4785                	li	a5,1
    8000561c:	08f70563          	beq	a4,a5,800056a6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005620:	4641                	li	a2,16
    80005622:	4581                	li	a1,0
    80005624:	fc040513          	addi	a0,s0,-64
    80005628:	ffffb097          	auipc	ra,0xffffb
    8000562c:	748080e7          	jalr	1864(ra) # 80000d70 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005630:	4741                	li	a4,16
    80005632:	f2c42683          	lw	a3,-212(s0)
    80005636:	fc040613          	addi	a2,s0,-64
    8000563a:	4581                	li	a1,0
    8000563c:	8526                	mv	a0,s1
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	508080e7          	jalr	1288(ra) # 80003b46 <writei>
    80005646:	47c1                	li	a5,16
    80005648:	0af51563          	bne	a0,a5,800056f2 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000564c:	04491703          	lh	a4,68(s2)
    80005650:	4785                	li	a5,1
    80005652:	0af70863          	beq	a4,a5,80005702 <sys_unlink+0x18c>
  iunlockput(dp);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	3a6080e7          	jalr	934(ra) # 800039fe <iunlockput>
  ip->nlink--;
    80005660:	04a95783          	lhu	a5,74(s2)
    80005664:	37fd                	addiw	a5,a5,-1
    80005666:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000566a:	854a                	mv	a0,s2
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	066080e7          	jalr	102(ra) # 800036d2 <iupdate>
  iunlockput(ip);
    80005674:	854a                	mv	a0,s2
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	388080e7          	jalr	904(ra) # 800039fe <iunlockput>
  end_op();
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	b5a080e7          	jalr	-1190(ra) # 800041d8 <end_op>
  return 0;
    80005686:	4501                	li	a0,0
    80005688:	a84d                	j	8000573a <sys_unlink+0x1c4>
    end_op();
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	b4e080e7          	jalr	-1202(ra) # 800041d8 <end_op>
    return -1;
    80005692:	557d                	li	a0,-1
    80005694:	a05d                	j	8000573a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005696:	00003517          	auipc	a0,0x3
    8000569a:	0aa50513          	addi	a0,a0,170 # 80008740 <syscalls+0x300>
    8000569e:	ffffb097          	auipc	ra,0xffffb
    800056a2:	f38080e7          	jalr	-200(ra) # 800005d6 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056a6:	04c92703          	lw	a4,76(s2)
    800056aa:	02000793          	li	a5,32
    800056ae:	f6e7f9e3          	bgeu	a5,a4,80005620 <sys_unlink+0xaa>
    800056b2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056b6:	4741                	li	a4,16
    800056b8:	86ce                	mv	a3,s3
    800056ba:	f1840613          	addi	a2,s0,-232
    800056be:	4581                	li	a1,0
    800056c0:	854a                	mv	a0,s2
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	38e080e7          	jalr	910(ra) # 80003a50 <readi>
    800056ca:	47c1                	li	a5,16
    800056cc:	00f51b63          	bne	a0,a5,800056e2 <sys_unlink+0x16c>
    if(de.inum != 0)
    800056d0:	f1845783          	lhu	a5,-232(s0)
    800056d4:	e7a1                	bnez	a5,8000571c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056d6:	29c1                	addiw	s3,s3,16
    800056d8:	04c92783          	lw	a5,76(s2)
    800056dc:	fcf9ede3          	bltu	s3,a5,800056b6 <sys_unlink+0x140>
    800056e0:	b781                	j	80005620 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056e2:	00003517          	auipc	a0,0x3
    800056e6:	07650513          	addi	a0,a0,118 # 80008758 <syscalls+0x318>
    800056ea:	ffffb097          	auipc	ra,0xffffb
    800056ee:	eec080e7          	jalr	-276(ra) # 800005d6 <panic>
    panic("unlink: writei");
    800056f2:	00003517          	auipc	a0,0x3
    800056f6:	07e50513          	addi	a0,a0,126 # 80008770 <syscalls+0x330>
    800056fa:	ffffb097          	auipc	ra,0xffffb
    800056fe:	edc080e7          	jalr	-292(ra) # 800005d6 <panic>
    dp->nlink--;
    80005702:	04a4d783          	lhu	a5,74(s1)
    80005706:	37fd                	addiw	a5,a5,-1
    80005708:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000570c:	8526                	mv	a0,s1
    8000570e:	ffffe097          	auipc	ra,0xffffe
    80005712:	fc4080e7          	jalr	-60(ra) # 800036d2 <iupdate>
    80005716:	b781                	j	80005656 <sys_unlink+0xe0>
    return -1;
    80005718:	557d                	li	a0,-1
    8000571a:	a005                	j	8000573a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000571c:	854a                	mv	a0,s2
    8000571e:	ffffe097          	auipc	ra,0xffffe
    80005722:	2e0080e7          	jalr	736(ra) # 800039fe <iunlockput>
  iunlockput(dp);
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	2d6080e7          	jalr	726(ra) # 800039fe <iunlockput>
  end_op();
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	aa8080e7          	jalr	-1368(ra) # 800041d8 <end_op>
  return -1;
    80005738:	557d                	li	a0,-1
}
    8000573a:	70ae                	ld	ra,232(sp)
    8000573c:	740e                	ld	s0,224(sp)
    8000573e:	64ee                	ld	s1,216(sp)
    80005740:	694e                	ld	s2,208(sp)
    80005742:	69ae                	ld	s3,200(sp)
    80005744:	616d                	addi	sp,sp,240
    80005746:	8082                	ret

0000000080005748 <sys_open>:

uint64
sys_open(void)
{
    80005748:	7131                	addi	sp,sp,-192
    8000574a:	fd06                	sd	ra,184(sp)
    8000574c:	f922                	sd	s0,176(sp)
    8000574e:	f526                	sd	s1,168(sp)
    80005750:	f14a                	sd	s2,160(sp)
    80005752:	ed4e                	sd	s3,152(sp)
    80005754:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005756:	08000613          	li	a2,128
    8000575a:	f5040593          	addi	a1,s0,-176
    8000575e:	4501                	li	a0,0
    80005760:	ffffd097          	auipc	ra,0xffffd
    80005764:	464080e7          	jalr	1124(ra) # 80002bc4 <argstr>
    return -1;
    80005768:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000576a:	0c054163          	bltz	a0,8000582c <sys_open+0xe4>
    8000576e:	f4c40593          	addi	a1,s0,-180
    80005772:	4505                	li	a0,1
    80005774:	ffffd097          	auipc	ra,0xffffd
    80005778:	40c080e7          	jalr	1036(ra) # 80002b80 <argint>
    8000577c:	0a054863          	bltz	a0,8000582c <sys_open+0xe4>

  begin_op();
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	9d8080e7          	jalr	-1576(ra) # 80004158 <begin_op>

  if(omode & O_CREATE){
    80005788:	f4c42783          	lw	a5,-180(s0)
    8000578c:	2007f793          	andi	a5,a5,512
    80005790:	cbdd                	beqz	a5,80005846 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005792:	4681                	li	a3,0
    80005794:	4601                	li	a2,0
    80005796:	4589                	li	a1,2
    80005798:	f5040513          	addi	a0,s0,-176
    8000579c:	00000097          	auipc	ra,0x0
    800057a0:	972080e7          	jalr	-1678(ra) # 8000510e <create>
    800057a4:	892a                	mv	s2,a0
    if(ip == 0){
    800057a6:	c959                	beqz	a0,8000583c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057a8:	04491703          	lh	a4,68(s2)
    800057ac:	478d                	li	a5,3
    800057ae:	00f71763          	bne	a4,a5,800057bc <sys_open+0x74>
    800057b2:	04695703          	lhu	a4,70(s2)
    800057b6:	47a5                	li	a5,9
    800057b8:	0ce7ec63          	bltu	a5,a4,80005890 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057bc:	fffff097          	auipc	ra,0xfffff
    800057c0:	db2080e7          	jalr	-590(ra) # 8000456e <filealloc>
    800057c4:	89aa                	mv	s3,a0
    800057c6:	10050263          	beqz	a0,800058ca <sys_open+0x182>
    800057ca:	00000097          	auipc	ra,0x0
    800057ce:	902080e7          	jalr	-1790(ra) # 800050cc <fdalloc>
    800057d2:	84aa                	mv	s1,a0
    800057d4:	0e054663          	bltz	a0,800058c0 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057d8:	04491703          	lh	a4,68(s2)
    800057dc:	478d                	li	a5,3
    800057de:	0cf70463          	beq	a4,a5,800058a6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057e2:	4789                	li	a5,2
    800057e4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800057e8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800057ec:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800057f0:	f4c42783          	lw	a5,-180(s0)
    800057f4:	0017c713          	xori	a4,a5,1
    800057f8:	8b05                	andi	a4,a4,1
    800057fa:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057fe:	0037f713          	andi	a4,a5,3
    80005802:	00e03733          	snez	a4,a4
    80005806:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000580a:	4007f793          	andi	a5,a5,1024
    8000580e:	c791                	beqz	a5,8000581a <sys_open+0xd2>
    80005810:	04491703          	lh	a4,68(s2)
    80005814:	4789                	li	a5,2
    80005816:	08f70f63          	beq	a4,a5,800058b4 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000581a:	854a                	mv	a0,s2
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	042080e7          	jalr	66(ra) # 8000385e <iunlock>
  end_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	9b4080e7          	jalr	-1612(ra) # 800041d8 <end_op>

  return fd;
}
    8000582c:	8526                	mv	a0,s1
    8000582e:	70ea                	ld	ra,184(sp)
    80005830:	744a                	ld	s0,176(sp)
    80005832:	74aa                	ld	s1,168(sp)
    80005834:	790a                	ld	s2,160(sp)
    80005836:	69ea                	ld	s3,152(sp)
    80005838:	6129                	addi	sp,sp,192
    8000583a:	8082                	ret
      end_op();
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	99c080e7          	jalr	-1636(ra) # 800041d8 <end_op>
      return -1;
    80005844:	b7e5                	j	8000582c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005846:	f5040513          	addi	a0,s0,-176
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	702080e7          	jalr	1794(ra) # 80003f4c <namei>
    80005852:	892a                	mv	s2,a0
    80005854:	c905                	beqz	a0,80005884 <sys_open+0x13c>
    ilock(ip);
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	f46080e7          	jalr	-186(ra) # 8000379c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000585e:	04491703          	lh	a4,68(s2)
    80005862:	4785                	li	a5,1
    80005864:	f4f712e3          	bne	a4,a5,800057a8 <sys_open+0x60>
    80005868:	f4c42783          	lw	a5,-180(s0)
    8000586c:	dba1                	beqz	a5,800057bc <sys_open+0x74>
      iunlockput(ip);
    8000586e:	854a                	mv	a0,s2
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	18e080e7          	jalr	398(ra) # 800039fe <iunlockput>
      end_op();
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	960080e7          	jalr	-1696(ra) # 800041d8 <end_op>
      return -1;
    80005880:	54fd                	li	s1,-1
    80005882:	b76d                	j	8000582c <sys_open+0xe4>
      end_op();
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	954080e7          	jalr	-1708(ra) # 800041d8 <end_op>
      return -1;
    8000588c:	54fd                	li	s1,-1
    8000588e:	bf79                	j	8000582c <sys_open+0xe4>
    iunlockput(ip);
    80005890:	854a                	mv	a0,s2
    80005892:	ffffe097          	auipc	ra,0xffffe
    80005896:	16c080e7          	jalr	364(ra) # 800039fe <iunlockput>
    end_op();
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	93e080e7          	jalr	-1730(ra) # 800041d8 <end_op>
    return -1;
    800058a2:	54fd                	li	s1,-1
    800058a4:	b761                	j	8000582c <sys_open+0xe4>
    f->type = FD_DEVICE;
    800058a6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058aa:	04691783          	lh	a5,70(s2)
    800058ae:	02f99223          	sh	a5,36(s3)
    800058b2:	bf2d                	j	800057ec <sys_open+0xa4>
    itrunc(ip);
    800058b4:	854a                	mv	a0,s2
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	ff4080e7          	jalr	-12(ra) # 800038aa <itrunc>
    800058be:	bfb1                	j	8000581a <sys_open+0xd2>
      fileclose(f);
    800058c0:	854e                	mv	a0,s3
    800058c2:	fffff097          	auipc	ra,0xfffff
    800058c6:	d68080e7          	jalr	-664(ra) # 8000462a <fileclose>
    iunlockput(ip);
    800058ca:	854a                	mv	a0,s2
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	132080e7          	jalr	306(ra) # 800039fe <iunlockput>
    end_op();
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	904080e7          	jalr	-1788(ra) # 800041d8 <end_op>
    return -1;
    800058dc:	54fd                	li	s1,-1
    800058de:	b7b9                	j	8000582c <sys_open+0xe4>

00000000800058e0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058e0:	7175                	addi	sp,sp,-144
    800058e2:	e506                	sd	ra,136(sp)
    800058e4:	e122                	sd	s0,128(sp)
    800058e6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	870080e7          	jalr	-1936(ra) # 80004158 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058f0:	08000613          	li	a2,128
    800058f4:	f7040593          	addi	a1,s0,-144
    800058f8:	4501                	li	a0,0
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	2ca080e7          	jalr	714(ra) # 80002bc4 <argstr>
    80005902:	02054963          	bltz	a0,80005934 <sys_mkdir+0x54>
    80005906:	4681                	li	a3,0
    80005908:	4601                	li	a2,0
    8000590a:	4585                	li	a1,1
    8000590c:	f7040513          	addi	a0,s0,-144
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	7fe080e7          	jalr	2046(ra) # 8000510e <create>
    80005918:	cd11                	beqz	a0,80005934 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000591a:	ffffe097          	auipc	ra,0xffffe
    8000591e:	0e4080e7          	jalr	228(ra) # 800039fe <iunlockput>
  end_op();
    80005922:	fffff097          	auipc	ra,0xfffff
    80005926:	8b6080e7          	jalr	-1866(ra) # 800041d8 <end_op>
  return 0;
    8000592a:	4501                	li	a0,0
}
    8000592c:	60aa                	ld	ra,136(sp)
    8000592e:	640a                	ld	s0,128(sp)
    80005930:	6149                	addi	sp,sp,144
    80005932:	8082                	ret
    end_op();
    80005934:	fffff097          	auipc	ra,0xfffff
    80005938:	8a4080e7          	jalr	-1884(ra) # 800041d8 <end_op>
    return -1;
    8000593c:	557d                	li	a0,-1
    8000593e:	b7fd                	j	8000592c <sys_mkdir+0x4c>

0000000080005940 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005940:	7135                	addi	sp,sp,-160
    80005942:	ed06                	sd	ra,152(sp)
    80005944:	e922                	sd	s0,144(sp)
    80005946:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005948:	fffff097          	auipc	ra,0xfffff
    8000594c:	810080e7          	jalr	-2032(ra) # 80004158 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005950:	08000613          	li	a2,128
    80005954:	f7040593          	addi	a1,s0,-144
    80005958:	4501                	li	a0,0
    8000595a:	ffffd097          	auipc	ra,0xffffd
    8000595e:	26a080e7          	jalr	618(ra) # 80002bc4 <argstr>
    80005962:	04054a63          	bltz	a0,800059b6 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005966:	f6c40593          	addi	a1,s0,-148
    8000596a:	4505                	li	a0,1
    8000596c:	ffffd097          	auipc	ra,0xffffd
    80005970:	214080e7          	jalr	532(ra) # 80002b80 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005974:	04054163          	bltz	a0,800059b6 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005978:	f6840593          	addi	a1,s0,-152
    8000597c:	4509                	li	a0,2
    8000597e:	ffffd097          	auipc	ra,0xffffd
    80005982:	202080e7          	jalr	514(ra) # 80002b80 <argint>
     argint(1, &major) < 0 ||
    80005986:	02054863          	bltz	a0,800059b6 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000598a:	f6841683          	lh	a3,-152(s0)
    8000598e:	f6c41603          	lh	a2,-148(s0)
    80005992:	458d                	li	a1,3
    80005994:	f7040513          	addi	a0,s0,-144
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	776080e7          	jalr	1910(ra) # 8000510e <create>
     argint(2, &minor) < 0 ||
    800059a0:	c919                	beqz	a0,800059b6 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	05c080e7          	jalr	92(ra) # 800039fe <iunlockput>
  end_op();
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	82e080e7          	jalr	-2002(ra) # 800041d8 <end_op>
  return 0;
    800059b2:	4501                	li	a0,0
    800059b4:	a031                	j	800059c0 <sys_mknod+0x80>
    end_op();
    800059b6:	fffff097          	auipc	ra,0xfffff
    800059ba:	822080e7          	jalr	-2014(ra) # 800041d8 <end_op>
    return -1;
    800059be:	557d                	li	a0,-1
}
    800059c0:	60ea                	ld	ra,152(sp)
    800059c2:	644a                	ld	s0,144(sp)
    800059c4:	610d                	addi	sp,sp,160
    800059c6:	8082                	ret

00000000800059c8 <sys_chdir>:

uint64
sys_chdir(void)
{
    800059c8:	7135                	addi	sp,sp,-160
    800059ca:	ed06                	sd	ra,152(sp)
    800059cc:	e922                	sd	s0,144(sp)
    800059ce:	e526                	sd	s1,136(sp)
    800059d0:	e14a                	sd	s2,128(sp)
    800059d2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059d4:	ffffc097          	auipc	ra,0xffffc
    800059d8:	06e080e7          	jalr	110(ra) # 80001a42 <myproc>
    800059dc:	892a                	mv	s2,a0
  
  begin_op();
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	77a080e7          	jalr	1914(ra) # 80004158 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059e6:	08000613          	li	a2,128
    800059ea:	f6040593          	addi	a1,s0,-160
    800059ee:	4501                	li	a0,0
    800059f0:	ffffd097          	auipc	ra,0xffffd
    800059f4:	1d4080e7          	jalr	468(ra) # 80002bc4 <argstr>
    800059f8:	04054b63          	bltz	a0,80005a4e <sys_chdir+0x86>
    800059fc:	f6040513          	addi	a0,s0,-160
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	54c080e7          	jalr	1356(ra) # 80003f4c <namei>
    80005a08:	84aa                	mv	s1,a0
    80005a0a:	c131                	beqz	a0,80005a4e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	d90080e7          	jalr	-624(ra) # 8000379c <ilock>
  if(ip->type != T_DIR){
    80005a14:	04449703          	lh	a4,68(s1)
    80005a18:	4785                	li	a5,1
    80005a1a:	04f71063          	bne	a4,a5,80005a5a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a1e:	8526                	mv	a0,s1
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	e3e080e7          	jalr	-450(ra) # 8000385e <iunlock>
  iput(p->cwd);
    80005a28:	15093503          	ld	a0,336(s2)
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	f2a080e7          	jalr	-214(ra) # 80003956 <iput>
  end_op();
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	7a4080e7          	jalr	1956(ra) # 800041d8 <end_op>
  p->cwd = ip;
    80005a3c:	14993823          	sd	s1,336(s2)
  return 0;
    80005a40:	4501                	li	a0,0
}
    80005a42:	60ea                	ld	ra,152(sp)
    80005a44:	644a                	ld	s0,144(sp)
    80005a46:	64aa                	ld	s1,136(sp)
    80005a48:	690a                	ld	s2,128(sp)
    80005a4a:	610d                	addi	sp,sp,160
    80005a4c:	8082                	ret
    end_op();
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	78a080e7          	jalr	1930(ra) # 800041d8 <end_op>
    return -1;
    80005a56:	557d                	li	a0,-1
    80005a58:	b7ed                	j	80005a42 <sys_chdir+0x7a>
    iunlockput(ip);
    80005a5a:	8526                	mv	a0,s1
    80005a5c:	ffffe097          	auipc	ra,0xffffe
    80005a60:	fa2080e7          	jalr	-94(ra) # 800039fe <iunlockput>
    end_op();
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	774080e7          	jalr	1908(ra) # 800041d8 <end_op>
    return -1;
    80005a6c:	557d                	li	a0,-1
    80005a6e:	bfd1                	j	80005a42 <sys_chdir+0x7a>

0000000080005a70 <sys_exec>:

uint64
sys_exec(void)
{
    80005a70:	7145                	addi	sp,sp,-464
    80005a72:	e786                	sd	ra,456(sp)
    80005a74:	e3a2                	sd	s0,448(sp)
    80005a76:	ff26                	sd	s1,440(sp)
    80005a78:	fb4a                	sd	s2,432(sp)
    80005a7a:	f74e                	sd	s3,424(sp)
    80005a7c:	f352                	sd	s4,416(sp)
    80005a7e:	ef56                	sd	s5,408(sp)
    80005a80:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a82:	08000613          	li	a2,128
    80005a86:	f4040593          	addi	a1,s0,-192
    80005a8a:	4501                	li	a0,0
    80005a8c:	ffffd097          	auipc	ra,0xffffd
    80005a90:	138080e7          	jalr	312(ra) # 80002bc4 <argstr>
    return -1;
    80005a94:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a96:	0c054a63          	bltz	a0,80005b6a <sys_exec+0xfa>
    80005a9a:	e3840593          	addi	a1,s0,-456
    80005a9e:	4505                	li	a0,1
    80005aa0:	ffffd097          	auipc	ra,0xffffd
    80005aa4:	102080e7          	jalr	258(ra) # 80002ba2 <argaddr>
    80005aa8:	0c054163          	bltz	a0,80005b6a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005aac:	10000613          	li	a2,256
    80005ab0:	4581                	li	a1,0
    80005ab2:	e4040513          	addi	a0,s0,-448
    80005ab6:	ffffb097          	auipc	ra,0xffffb
    80005aba:	2ba080e7          	jalr	698(ra) # 80000d70 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005abe:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ac2:	89a6                	mv	s3,s1
    80005ac4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ac6:	02000a13          	li	s4,32
    80005aca:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ace:	00391513          	slli	a0,s2,0x3
    80005ad2:	e3040593          	addi	a1,s0,-464
    80005ad6:	e3843783          	ld	a5,-456(s0)
    80005ada:	953e                	add	a0,a0,a5
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	00a080e7          	jalr	10(ra) # 80002ae6 <fetchaddr>
    80005ae4:	02054a63          	bltz	a0,80005b18 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005ae8:	e3043783          	ld	a5,-464(s0)
    80005aec:	c3b9                	beqz	a5,80005b32 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005aee:	ffffb097          	auipc	ra,0xffffb
    80005af2:	096080e7          	jalr	150(ra) # 80000b84 <kalloc>
    80005af6:	85aa                	mv	a1,a0
    80005af8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005afc:	cd11                	beqz	a0,80005b18 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005afe:	6605                	lui	a2,0x1
    80005b00:	e3043503          	ld	a0,-464(s0)
    80005b04:	ffffd097          	auipc	ra,0xffffd
    80005b08:	034080e7          	jalr	52(ra) # 80002b38 <fetchstr>
    80005b0c:	00054663          	bltz	a0,80005b18 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b10:	0905                	addi	s2,s2,1
    80005b12:	09a1                	addi	s3,s3,8
    80005b14:	fb491be3          	bne	s2,s4,80005aca <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b18:	10048913          	addi	s2,s1,256
    80005b1c:	6088                	ld	a0,0(s1)
    80005b1e:	c529                	beqz	a0,80005b68 <sys_exec+0xf8>
    kfree(argv[i]);
    80005b20:	ffffb097          	auipc	ra,0xffffb
    80005b24:	f68080e7          	jalr	-152(ra) # 80000a88 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b28:	04a1                	addi	s1,s1,8
    80005b2a:	ff2499e3          	bne	s1,s2,80005b1c <sys_exec+0xac>
  return -1;
    80005b2e:	597d                	li	s2,-1
    80005b30:	a82d                	j	80005b6a <sys_exec+0xfa>
      argv[i] = 0;
    80005b32:	0a8e                	slli	s5,s5,0x3
    80005b34:	fc040793          	addi	a5,s0,-64
    80005b38:	9abe                	add	s5,s5,a5
    80005b3a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b3e:	e4040593          	addi	a1,s0,-448
    80005b42:	f4040513          	addi	a0,s0,-192
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	194080e7          	jalr	404(ra) # 80004cda <exec>
    80005b4e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b50:	10048993          	addi	s3,s1,256
    80005b54:	6088                	ld	a0,0(s1)
    80005b56:	c911                	beqz	a0,80005b6a <sys_exec+0xfa>
    kfree(argv[i]);
    80005b58:	ffffb097          	auipc	ra,0xffffb
    80005b5c:	f30080e7          	jalr	-208(ra) # 80000a88 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b60:	04a1                	addi	s1,s1,8
    80005b62:	ff3499e3          	bne	s1,s3,80005b54 <sys_exec+0xe4>
    80005b66:	a011                	j	80005b6a <sys_exec+0xfa>
  return -1;
    80005b68:	597d                	li	s2,-1
}
    80005b6a:	854a                	mv	a0,s2
    80005b6c:	60be                	ld	ra,456(sp)
    80005b6e:	641e                	ld	s0,448(sp)
    80005b70:	74fa                	ld	s1,440(sp)
    80005b72:	795a                	ld	s2,432(sp)
    80005b74:	79ba                	ld	s3,424(sp)
    80005b76:	7a1a                	ld	s4,416(sp)
    80005b78:	6afa                	ld	s5,408(sp)
    80005b7a:	6179                	addi	sp,sp,464
    80005b7c:	8082                	ret

0000000080005b7e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b7e:	7139                	addi	sp,sp,-64
    80005b80:	fc06                	sd	ra,56(sp)
    80005b82:	f822                	sd	s0,48(sp)
    80005b84:	f426                	sd	s1,40(sp)
    80005b86:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b88:	ffffc097          	auipc	ra,0xffffc
    80005b8c:	eba080e7          	jalr	-326(ra) # 80001a42 <myproc>
    80005b90:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b92:	fd840593          	addi	a1,s0,-40
    80005b96:	4501                	li	a0,0
    80005b98:	ffffd097          	auipc	ra,0xffffd
    80005b9c:	00a080e7          	jalr	10(ra) # 80002ba2 <argaddr>
    return -1;
    80005ba0:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005ba2:	0e054063          	bltz	a0,80005c82 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005ba6:	fc840593          	addi	a1,s0,-56
    80005baa:	fd040513          	addi	a0,s0,-48
    80005bae:	fffff097          	auipc	ra,0xfffff
    80005bb2:	dd2080e7          	jalr	-558(ra) # 80004980 <pipealloc>
    return -1;
    80005bb6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bb8:	0c054563          	bltz	a0,80005c82 <sys_pipe+0x104>
  fd0 = -1;
    80005bbc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005bc0:	fd043503          	ld	a0,-48(s0)
    80005bc4:	fffff097          	auipc	ra,0xfffff
    80005bc8:	508080e7          	jalr	1288(ra) # 800050cc <fdalloc>
    80005bcc:	fca42223          	sw	a0,-60(s0)
    80005bd0:	08054c63          	bltz	a0,80005c68 <sys_pipe+0xea>
    80005bd4:	fc843503          	ld	a0,-56(s0)
    80005bd8:	fffff097          	auipc	ra,0xfffff
    80005bdc:	4f4080e7          	jalr	1268(ra) # 800050cc <fdalloc>
    80005be0:	fca42023          	sw	a0,-64(s0)
    80005be4:	06054863          	bltz	a0,80005c54 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005be8:	4691                	li	a3,4
    80005bea:	fc440613          	addi	a2,s0,-60
    80005bee:	fd843583          	ld	a1,-40(s0)
    80005bf2:	68a8                	ld	a0,80(s1)
    80005bf4:	ffffc097          	auipc	ra,0xffffc
    80005bf8:	b42080e7          	jalr	-1214(ra) # 80001736 <copyout>
    80005bfc:	02054063          	bltz	a0,80005c1c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c00:	4691                	li	a3,4
    80005c02:	fc040613          	addi	a2,s0,-64
    80005c06:	fd843583          	ld	a1,-40(s0)
    80005c0a:	0591                	addi	a1,a1,4
    80005c0c:	68a8                	ld	a0,80(s1)
    80005c0e:	ffffc097          	auipc	ra,0xffffc
    80005c12:	b28080e7          	jalr	-1240(ra) # 80001736 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c16:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c18:	06055563          	bgez	a0,80005c82 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c1c:	fc442783          	lw	a5,-60(s0)
    80005c20:	07e9                	addi	a5,a5,26
    80005c22:	078e                	slli	a5,a5,0x3
    80005c24:	97a6                	add	a5,a5,s1
    80005c26:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c2a:	fc042503          	lw	a0,-64(s0)
    80005c2e:	0569                	addi	a0,a0,26
    80005c30:	050e                	slli	a0,a0,0x3
    80005c32:	9526                	add	a0,a0,s1
    80005c34:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c38:	fd043503          	ld	a0,-48(s0)
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	9ee080e7          	jalr	-1554(ra) # 8000462a <fileclose>
    fileclose(wf);
    80005c44:	fc843503          	ld	a0,-56(s0)
    80005c48:	fffff097          	auipc	ra,0xfffff
    80005c4c:	9e2080e7          	jalr	-1566(ra) # 8000462a <fileclose>
    return -1;
    80005c50:	57fd                	li	a5,-1
    80005c52:	a805                	j	80005c82 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c54:	fc442783          	lw	a5,-60(s0)
    80005c58:	0007c863          	bltz	a5,80005c68 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c5c:	01a78513          	addi	a0,a5,26
    80005c60:	050e                	slli	a0,a0,0x3
    80005c62:	9526                	add	a0,a0,s1
    80005c64:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c68:	fd043503          	ld	a0,-48(s0)
    80005c6c:	fffff097          	auipc	ra,0xfffff
    80005c70:	9be080e7          	jalr	-1602(ra) # 8000462a <fileclose>
    fileclose(wf);
    80005c74:	fc843503          	ld	a0,-56(s0)
    80005c78:	fffff097          	auipc	ra,0xfffff
    80005c7c:	9b2080e7          	jalr	-1614(ra) # 8000462a <fileclose>
    return -1;
    80005c80:	57fd                	li	a5,-1
}
    80005c82:	853e                	mv	a0,a5
    80005c84:	70e2                	ld	ra,56(sp)
    80005c86:	7442                	ld	s0,48(sp)
    80005c88:	74a2                	ld	s1,40(sp)
    80005c8a:	6121                	addi	sp,sp,64
    80005c8c:	8082                	ret
	...

0000000080005c90 <kernelvec>:
    80005c90:	7111                	addi	sp,sp,-256
    80005c92:	e006                	sd	ra,0(sp)
    80005c94:	e40a                	sd	sp,8(sp)
    80005c96:	e80e                	sd	gp,16(sp)
    80005c98:	ec12                	sd	tp,24(sp)
    80005c9a:	f016                	sd	t0,32(sp)
    80005c9c:	f41a                	sd	t1,40(sp)
    80005c9e:	f81e                	sd	t2,48(sp)
    80005ca0:	fc22                	sd	s0,56(sp)
    80005ca2:	e0a6                	sd	s1,64(sp)
    80005ca4:	e4aa                	sd	a0,72(sp)
    80005ca6:	e8ae                	sd	a1,80(sp)
    80005ca8:	ecb2                	sd	a2,88(sp)
    80005caa:	f0b6                	sd	a3,96(sp)
    80005cac:	f4ba                	sd	a4,104(sp)
    80005cae:	f8be                	sd	a5,112(sp)
    80005cb0:	fcc2                	sd	a6,120(sp)
    80005cb2:	e146                	sd	a7,128(sp)
    80005cb4:	e54a                	sd	s2,136(sp)
    80005cb6:	e94e                	sd	s3,144(sp)
    80005cb8:	ed52                	sd	s4,152(sp)
    80005cba:	f156                	sd	s5,160(sp)
    80005cbc:	f55a                	sd	s6,168(sp)
    80005cbe:	f95e                	sd	s7,176(sp)
    80005cc0:	fd62                	sd	s8,184(sp)
    80005cc2:	e1e6                	sd	s9,192(sp)
    80005cc4:	e5ea                	sd	s10,200(sp)
    80005cc6:	e9ee                	sd	s11,208(sp)
    80005cc8:	edf2                	sd	t3,216(sp)
    80005cca:	f1f6                	sd	t4,224(sp)
    80005ccc:	f5fa                	sd	t5,232(sp)
    80005cce:	f9fe                	sd	t6,240(sp)
    80005cd0:	ce3fc0ef          	jal	ra,800029b2 <kerneltrap>
    80005cd4:	6082                	ld	ra,0(sp)
    80005cd6:	6122                	ld	sp,8(sp)
    80005cd8:	61c2                	ld	gp,16(sp)
    80005cda:	7282                	ld	t0,32(sp)
    80005cdc:	7322                	ld	t1,40(sp)
    80005cde:	73c2                	ld	t2,48(sp)
    80005ce0:	7462                	ld	s0,56(sp)
    80005ce2:	6486                	ld	s1,64(sp)
    80005ce4:	6526                	ld	a0,72(sp)
    80005ce6:	65c6                	ld	a1,80(sp)
    80005ce8:	6666                	ld	a2,88(sp)
    80005cea:	7686                	ld	a3,96(sp)
    80005cec:	7726                	ld	a4,104(sp)
    80005cee:	77c6                	ld	a5,112(sp)
    80005cf0:	7866                	ld	a6,120(sp)
    80005cf2:	688a                	ld	a7,128(sp)
    80005cf4:	692a                	ld	s2,136(sp)
    80005cf6:	69ca                	ld	s3,144(sp)
    80005cf8:	6a6a                	ld	s4,152(sp)
    80005cfa:	7a8a                	ld	s5,160(sp)
    80005cfc:	7b2a                	ld	s6,168(sp)
    80005cfe:	7bca                	ld	s7,176(sp)
    80005d00:	7c6a                	ld	s8,184(sp)
    80005d02:	6c8e                	ld	s9,192(sp)
    80005d04:	6d2e                	ld	s10,200(sp)
    80005d06:	6dce                	ld	s11,208(sp)
    80005d08:	6e6e                	ld	t3,216(sp)
    80005d0a:	7e8e                	ld	t4,224(sp)
    80005d0c:	7f2e                	ld	t5,232(sp)
    80005d0e:	7fce                	ld	t6,240(sp)
    80005d10:	6111                	addi	sp,sp,256
    80005d12:	10200073          	sret
    80005d16:	00000013          	nop
    80005d1a:	00000013          	nop
    80005d1e:	0001                	nop

0000000080005d20 <timervec>:
    80005d20:	34051573          	csrrw	a0,mscratch,a0
    80005d24:	e10c                	sd	a1,0(a0)
    80005d26:	e510                	sd	a2,8(a0)
    80005d28:	e914                	sd	a3,16(a0)
    80005d2a:	710c                	ld	a1,32(a0)
    80005d2c:	7510                	ld	a2,40(a0)
    80005d2e:	6194                	ld	a3,0(a1)
    80005d30:	96b2                	add	a3,a3,a2
    80005d32:	e194                	sd	a3,0(a1)
    80005d34:	4589                	li	a1,2
    80005d36:	14459073          	csrw	sip,a1
    80005d3a:	6914                	ld	a3,16(a0)
    80005d3c:	6510                	ld	a2,8(a0)
    80005d3e:	610c                	ld	a1,0(a0)
    80005d40:	34051573          	csrrw	a0,mscratch,a0
    80005d44:	30200073          	mret
	...

0000000080005d4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d4a:	1141                	addi	sp,sp,-16
    80005d4c:	e422                	sd	s0,8(sp)
    80005d4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d50:	0c0007b7          	lui	a5,0xc000
    80005d54:	4705                	li	a4,1
    80005d56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d58:	c3d8                	sw	a4,4(a5)
}
    80005d5a:	6422                	ld	s0,8(sp)
    80005d5c:	0141                	addi	sp,sp,16
    80005d5e:	8082                	ret

0000000080005d60 <plicinithart>:

void
plicinithart(void)
{
    80005d60:	1141                	addi	sp,sp,-16
    80005d62:	e406                	sd	ra,8(sp)
    80005d64:	e022                	sd	s0,0(sp)
    80005d66:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d68:	ffffc097          	auipc	ra,0xffffc
    80005d6c:	cae080e7          	jalr	-850(ra) # 80001a16 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d70:	0085171b          	slliw	a4,a0,0x8
    80005d74:	0c0027b7          	lui	a5,0xc002
    80005d78:	97ba                	add	a5,a5,a4
    80005d7a:	40200713          	li	a4,1026
    80005d7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d82:	00d5151b          	slliw	a0,a0,0xd
    80005d86:	0c2017b7          	lui	a5,0xc201
    80005d8a:	953e                	add	a0,a0,a5
    80005d8c:	00052023          	sw	zero,0(a0)
}
    80005d90:	60a2                	ld	ra,8(sp)
    80005d92:	6402                	ld	s0,0(sp)
    80005d94:	0141                	addi	sp,sp,16
    80005d96:	8082                	ret

0000000080005d98 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d98:	1141                	addi	sp,sp,-16
    80005d9a:	e406                	sd	ra,8(sp)
    80005d9c:	e022                	sd	s0,0(sp)
    80005d9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005da0:	ffffc097          	auipc	ra,0xffffc
    80005da4:	c76080e7          	jalr	-906(ra) # 80001a16 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005da8:	00d5179b          	slliw	a5,a0,0xd
    80005dac:	0c201537          	lui	a0,0xc201
    80005db0:	953e                	add	a0,a0,a5
  return irq;
}
    80005db2:	4148                	lw	a0,4(a0)
    80005db4:	60a2                	ld	ra,8(sp)
    80005db6:	6402                	ld	s0,0(sp)
    80005db8:	0141                	addi	sp,sp,16
    80005dba:	8082                	ret

0000000080005dbc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005dbc:	1101                	addi	sp,sp,-32
    80005dbe:	ec06                	sd	ra,24(sp)
    80005dc0:	e822                	sd	s0,16(sp)
    80005dc2:	e426                	sd	s1,8(sp)
    80005dc4:	1000                	addi	s0,sp,32
    80005dc6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005dc8:	ffffc097          	auipc	ra,0xffffc
    80005dcc:	c4e080e7          	jalr	-946(ra) # 80001a16 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005dd0:	00d5151b          	slliw	a0,a0,0xd
    80005dd4:	0c2017b7          	lui	a5,0xc201
    80005dd8:	97aa                	add	a5,a5,a0
    80005dda:	c3c4                	sw	s1,4(a5)
}
    80005ddc:	60e2                	ld	ra,24(sp)
    80005dde:	6442                	ld	s0,16(sp)
    80005de0:	64a2                	ld	s1,8(sp)
    80005de2:	6105                	addi	sp,sp,32
    80005de4:	8082                	ret

0000000080005de6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005de6:	1141                	addi	sp,sp,-16
    80005de8:	e406                	sd	ra,8(sp)
    80005dea:	e022                	sd	s0,0(sp)
    80005dec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dee:	479d                	li	a5,7
    80005df0:	04a7cc63          	blt	a5,a0,80005e48 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005df4:	0001e797          	auipc	a5,0x1e
    80005df8:	20c78793          	addi	a5,a5,524 # 80024000 <disk>
    80005dfc:	00a78733          	add	a4,a5,a0
    80005e00:	6789                	lui	a5,0x2
    80005e02:	97ba                	add	a5,a5,a4
    80005e04:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e08:	eba1                	bnez	a5,80005e58 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005e0a:	00451713          	slli	a4,a0,0x4
    80005e0e:	00020797          	auipc	a5,0x20
    80005e12:	1f27b783          	ld	a5,498(a5) # 80026000 <disk+0x2000>
    80005e16:	97ba                	add	a5,a5,a4
    80005e18:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005e1c:	0001e797          	auipc	a5,0x1e
    80005e20:	1e478793          	addi	a5,a5,484 # 80024000 <disk>
    80005e24:	97aa                	add	a5,a5,a0
    80005e26:	6509                	lui	a0,0x2
    80005e28:	953e                	add	a0,a0,a5
    80005e2a:	4785                	li	a5,1
    80005e2c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e30:	00020517          	auipc	a0,0x20
    80005e34:	1e850513          	addi	a0,a0,488 # 80026018 <disk+0x2018>
    80005e38:	ffffc097          	auipc	ra,0xffffc
    80005e3c:	5d0080e7          	jalr	1488(ra) # 80002408 <wakeup>
}
    80005e40:	60a2                	ld	ra,8(sp)
    80005e42:	6402                	ld	s0,0(sp)
    80005e44:	0141                	addi	sp,sp,16
    80005e46:	8082                	ret
    panic("virtio_disk_intr 1");
    80005e48:	00003517          	auipc	a0,0x3
    80005e4c:	93850513          	addi	a0,a0,-1736 # 80008780 <syscalls+0x340>
    80005e50:	ffffa097          	auipc	ra,0xffffa
    80005e54:	786080e7          	jalr	1926(ra) # 800005d6 <panic>
    panic("virtio_disk_intr 2");
    80005e58:	00003517          	auipc	a0,0x3
    80005e5c:	94050513          	addi	a0,a0,-1728 # 80008798 <syscalls+0x358>
    80005e60:	ffffa097          	auipc	ra,0xffffa
    80005e64:	776080e7          	jalr	1910(ra) # 800005d6 <panic>

0000000080005e68 <virtio_disk_init>:
{
    80005e68:	1101                	addi	sp,sp,-32
    80005e6a:	ec06                	sd	ra,24(sp)
    80005e6c:	e822                	sd	s0,16(sp)
    80005e6e:	e426                	sd	s1,8(sp)
    80005e70:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e72:	00003597          	auipc	a1,0x3
    80005e76:	93e58593          	addi	a1,a1,-1730 # 800087b0 <syscalls+0x370>
    80005e7a:	00020517          	auipc	a0,0x20
    80005e7e:	22e50513          	addi	a0,a0,558 # 800260a8 <disk+0x20a8>
    80005e82:	ffffb097          	auipc	ra,0xffffb
    80005e86:	d62080e7          	jalr	-670(ra) # 80000be4 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e8a:	100017b7          	lui	a5,0x10001
    80005e8e:	4398                	lw	a4,0(a5)
    80005e90:	2701                	sext.w	a4,a4
    80005e92:	747277b7          	lui	a5,0x74727
    80005e96:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e9a:	0ef71163          	bne	a4,a5,80005f7c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e9e:	100017b7          	lui	a5,0x10001
    80005ea2:	43dc                	lw	a5,4(a5)
    80005ea4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ea6:	4705                	li	a4,1
    80005ea8:	0ce79a63          	bne	a5,a4,80005f7c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005eac:	100017b7          	lui	a5,0x10001
    80005eb0:	479c                	lw	a5,8(a5)
    80005eb2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005eb4:	4709                	li	a4,2
    80005eb6:	0ce79363          	bne	a5,a4,80005f7c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005eba:	100017b7          	lui	a5,0x10001
    80005ebe:	47d8                	lw	a4,12(a5)
    80005ec0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ec2:	554d47b7          	lui	a5,0x554d4
    80005ec6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005eca:	0af71963          	bne	a4,a5,80005f7c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ece:	100017b7          	lui	a5,0x10001
    80005ed2:	4705                	li	a4,1
    80005ed4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ed6:	470d                	li	a4,3
    80005ed8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005eda:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005edc:	c7ffe737          	lui	a4,0xc7ffe
    80005ee0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
    80005ee4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005ee6:	2701                	sext.w	a4,a4
    80005ee8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eea:	472d                	li	a4,11
    80005eec:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eee:	473d                	li	a4,15
    80005ef0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005ef2:	6705                	lui	a4,0x1
    80005ef4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ef6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005efa:	5bdc                	lw	a5,52(a5)
    80005efc:	2781                	sext.w	a5,a5
  if(max == 0)
    80005efe:	c7d9                	beqz	a5,80005f8c <virtio_disk_init+0x124>
  if(max < NUM)
    80005f00:	471d                	li	a4,7
    80005f02:	08f77d63          	bgeu	a4,a5,80005f9c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f06:	100014b7          	lui	s1,0x10001
    80005f0a:	47a1                	li	a5,8
    80005f0c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005f0e:	6609                	lui	a2,0x2
    80005f10:	4581                	li	a1,0
    80005f12:	0001e517          	auipc	a0,0x1e
    80005f16:	0ee50513          	addi	a0,a0,238 # 80024000 <disk>
    80005f1a:	ffffb097          	auipc	ra,0xffffb
    80005f1e:	e56080e7          	jalr	-426(ra) # 80000d70 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005f22:	0001e717          	auipc	a4,0x1e
    80005f26:	0de70713          	addi	a4,a4,222 # 80024000 <disk>
    80005f2a:	00c75793          	srli	a5,a4,0xc
    80005f2e:	2781                	sext.w	a5,a5
    80005f30:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005f32:	00020797          	auipc	a5,0x20
    80005f36:	0ce78793          	addi	a5,a5,206 # 80026000 <disk+0x2000>
    80005f3a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005f3c:	0001e717          	auipc	a4,0x1e
    80005f40:	14470713          	addi	a4,a4,324 # 80024080 <disk+0x80>
    80005f44:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005f46:	0001f717          	auipc	a4,0x1f
    80005f4a:	0ba70713          	addi	a4,a4,186 # 80025000 <disk+0x1000>
    80005f4e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005f50:	4705                	li	a4,1
    80005f52:	00e78c23          	sb	a4,24(a5)
    80005f56:	00e78ca3          	sb	a4,25(a5)
    80005f5a:	00e78d23          	sb	a4,26(a5)
    80005f5e:	00e78da3          	sb	a4,27(a5)
    80005f62:	00e78e23          	sb	a4,28(a5)
    80005f66:	00e78ea3          	sb	a4,29(a5)
    80005f6a:	00e78f23          	sb	a4,30(a5)
    80005f6e:	00e78fa3          	sb	a4,31(a5)
}
    80005f72:	60e2                	ld	ra,24(sp)
    80005f74:	6442                	ld	s0,16(sp)
    80005f76:	64a2                	ld	s1,8(sp)
    80005f78:	6105                	addi	sp,sp,32
    80005f7a:	8082                	ret
    panic("could not find virtio disk");
    80005f7c:	00003517          	auipc	a0,0x3
    80005f80:	84450513          	addi	a0,a0,-1980 # 800087c0 <syscalls+0x380>
    80005f84:	ffffa097          	auipc	ra,0xffffa
    80005f88:	652080e7          	jalr	1618(ra) # 800005d6 <panic>
    panic("virtio disk has no queue 0");
    80005f8c:	00003517          	auipc	a0,0x3
    80005f90:	85450513          	addi	a0,a0,-1964 # 800087e0 <syscalls+0x3a0>
    80005f94:	ffffa097          	auipc	ra,0xffffa
    80005f98:	642080e7          	jalr	1602(ra) # 800005d6 <panic>
    panic("virtio disk max queue too short");
    80005f9c:	00003517          	auipc	a0,0x3
    80005fa0:	86450513          	addi	a0,a0,-1948 # 80008800 <syscalls+0x3c0>
    80005fa4:	ffffa097          	auipc	ra,0xffffa
    80005fa8:	632080e7          	jalr	1586(ra) # 800005d6 <panic>

0000000080005fac <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fac:	7119                	addi	sp,sp,-128
    80005fae:	fc86                	sd	ra,120(sp)
    80005fb0:	f8a2                	sd	s0,112(sp)
    80005fb2:	f4a6                	sd	s1,104(sp)
    80005fb4:	f0ca                	sd	s2,96(sp)
    80005fb6:	ecce                	sd	s3,88(sp)
    80005fb8:	e8d2                	sd	s4,80(sp)
    80005fba:	e4d6                	sd	s5,72(sp)
    80005fbc:	e0da                	sd	s6,64(sp)
    80005fbe:	fc5e                	sd	s7,56(sp)
    80005fc0:	f862                	sd	s8,48(sp)
    80005fc2:	f466                	sd	s9,40(sp)
    80005fc4:	f06a                	sd	s10,32(sp)
    80005fc6:	0100                	addi	s0,sp,128
    80005fc8:	892a                	mv	s2,a0
    80005fca:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fcc:	00c52c83          	lw	s9,12(a0)
    80005fd0:	001c9c9b          	slliw	s9,s9,0x1
    80005fd4:	1c82                	slli	s9,s9,0x20
    80005fd6:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005fda:	00020517          	auipc	a0,0x20
    80005fde:	0ce50513          	addi	a0,a0,206 # 800260a8 <disk+0x20a8>
    80005fe2:	ffffb097          	auipc	ra,0xffffb
    80005fe6:	c92080e7          	jalr	-878(ra) # 80000c74 <acquire>
  for(int i = 0; i < 3; i++){
    80005fea:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fec:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005fee:	0001eb97          	auipc	s7,0x1e
    80005ff2:	012b8b93          	addi	s7,s7,18 # 80024000 <disk>
    80005ff6:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005ff8:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005ffa:	8a4e                	mv	s4,s3
    80005ffc:	a051                	j	80006080 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005ffe:	00fb86b3          	add	a3,s7,a5
    80006002:	96da                	add	a3,a3,s6
    80006004:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006008:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000600a:	0207c563          	bltz	a5,80006034 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000600e:	2485                	addiw	s1,s1,1
    80006010:	0711                	addi	a4,a4,4
    80006012:	23548d63          	beq	s1,s5,8000624c <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80006016:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006018:	00020697          	auipc	a3,0x20
    8000601c:	00068693          	mv	a3,a3
    80006020:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006022:	0006c583          	lbu	a1,0(a3) # 80026018 <disk+0x2018>
    80006026:	fde1                	bnez	a1,80005ffe <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006028:	2785                	addiw	a5,a5,1
    8000602a:	0685                	addi	a3,a3,1
    8000602c:	ff879be3          	bne	a5,s8,80006022 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006030:	57fd                	li	a5,-1
    80006032:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006034:	02905a63          	blez	s1,80006068 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006038:	f9042503          	lw	a0,-112(s0)
    8000603c:	00000097          	auipc	ra,0x0
    80006040:	daa080e7          	jalr	-598(ra) # 80005de6 <free_desc>
      for(int j = 0; j < i; j++)
    80006044:	4785                	li	a5,1
    80006046:	0297d163          	bge	a5,s1,80006068 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000604a:	f9442503          	lw	a0,-108(s0)
    8000604e:	00000097          	auipc	ra,0x0
    80006052:	d98080e7          	jalr	-616(ra) # 80005de6 <free_desc>
      for(int j = 0; j < i; j++)
    80006056:	4789                	li	a5,2
    80006058:	0097d863          	bge	a5,s1,80006068 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000605c:	f9842503          	lw	a0,-104(s0)
    80006060:	00000097          	auipc	ra,0x0
    80006064:	d86080e7          	jalr	-634(ra) # 80005de6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006068:	00020597          	auipc	a1,0x20
    8000606c:	04058593          	addi	a1,a1,64 # 800260a8 <disk+0x20a8>
    80006070:	00020517          	auipc	a0,0x20
    80006074:	fa850513          	addi	a0,a0,-88 # 80026018 <disk+0x2018>
    80006078:	ffffc097          	auipc	ra,0xffffc
    8000607c:	20a080e7          	jalr	522(ra) # 80002282 <sleep>
  for(int i = 0; i < 3; i++){
    80006080:	f9040713          	addi	a4,s0,-112
    80006084:	84ce                	mv	s1,s3
    80006086:	bf41                	j	80006016 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006088:	4785                	li	a5,1
    8000608a:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000608e:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80006092:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006096:	f9042983          	lw	s3,-112(s0)
    8000609a:	00499493          	slli	s1,s3,0x4
    8000609e:	00020a17          	auipc	s4,0x20
    800060a2:	f62a0a13          	addi	s4,s4,-158 # 80026000 <disk+0x2000>
    800060a6:	000a3a83          	ld	s5,0(s4)
    800060aa:	9aa6                	add	s5,s5,s1
    800060ac:	f8040513          	addi	a0,s0,-128
    800060b0:	ffffb097          	auipc	ra,0xffffb
    800060b4:	094080e7          	jalr	148(ra) # 80001144 <kvmpa>
    800060b8:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    800060bc:	000a3783          	ld	a5,0(s4)
    800060c0:	97a6                	add	a5,a5,s1
    800060c2:	4741                	li	a4,16
    800060c4:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060c6:	000a3783          	ld	a5,0(s4)
    800060ca:	97a6                	add	a5,a5,s1
    800060cc:	4705                	li	a4,1
    800060ce:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800060d2:	f9442703          	lw	a4,-108(s0)
    800060d6:	000a3783          	ld	a5,0(s4)
    800060da:	97a6                	add	a5,a5,s1
    800060dc:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060e0:	0712                	slli	a4,a4,0x4
    800060e2:	000a3783          	ld	a5,0(s4)
    800060e6:	97ba                	add	a5,a5,a4
    800060e8:	05890693          	addi	a3,s2,88
    800060ec:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    800060ee:	000a3783          	ld	a5,0(s4)
    800060f2:	97ba                	add	a5,a5,a4
    800060f4:	40000693          	li	a3,1024
    800060f8:	c794                	sw	a3,8(a5)
  if(write)
    800060fa:	100d0a63          	beqz	s10,8000620e <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800060fe:	00020797          	auipc	a5,0x20
    80006102:	f027b783          	ld	a5,-254(a5) # 80026000 <disk+0x2000>
    80006106:	97ba                	add	a5,a5,a4
    80006108:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000610c:	0001e517          	auipc	a0,0x1e
    80006110:	ef450513          	addi	a0,a0,-268 # 80024000 <disk>
    80006114:	00020797          	auipc	a5,0x20
    80006118:	eec78793          	addi	a5,a5,-276 # 80026000 <disk+0x2000>
    8000611c:	6394                	ld	a3,0(a5)
    8000611e:	96ba                	add	a3,a3,a4
    80006120:	00c6d603          	lhu	a2,12(a3)
    80006124:	00166613          	ori	a2,a2,1
    80006128:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000612c:	f9842683          	lw	a3,-104(s0)
    80006130:	6390                	ld	a2,0(a5)
    80006132:	9732                	add	a4,a4,a2
    80006134:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006138:	20098613          	addi	a2,s3,512
    8000613c:	0612                	slli	a2,a2,0x4
    8000613e:	962a                	add	a2,a2,a0
    80006140:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006144:	00469713          	slli	a4,a3,0x4
    80006148:	6394                	ld	a3,0(a5)
    8000614a:	96ba                	add	a3,a3,a4
    8000614c:	6589                	lui	a1,0x2
    8000614e:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80006152:	94ae                	add	s1,s1,a1
    80006154:	94aa                	add	s1,s1,a0
    80006156:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006158:	6394                	ld	a3,0(a5)
    8000615a:	96ba                	add	a3,a3,a4
    8000615c:	4585                	li	a1,1
    8000615e:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006160:	6394                	ld	a3,0(a5)
    80006162:	96ba                	add	a3,a3,a4
    80006164:	4509                	li	a0,2
    80006166:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000616a:	6394                	ld	a3,0(a5)
    8000616c:	9736                	add	a4,a4,a3
    8000616e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006172:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006176:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000617a:	6794                	ld	a3,8(a5)
    8000617c:	0026d703          	lhu	a4,2(a3)
    80006180:	8b1d                	andi	a4,a4,7
    80006182:	2709                	addiw	a4,a4,2
    80006184:	0706                	slli	a4,a4,0x1
    80006186:	9736                	add	a4,a4,a3
    80006188:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    8000618c:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006190:	6798                	ld	a4,8(a5)
    80006192:	00275783          	lhu	a5,2(a4)
    80006196:	2785                	addiw	a5,a5,1
    80006198:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000619c:	100017b7          	lui	a5,0x10001
    800061a0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800061a4:	00492703          	lw	a4,4(s2)
    800061a8:	4785                	li	a5,1
    800061aa:	02f71163          	bne	a4,a5,800061cc <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    800061ae:	00020997          	auipc	s3,0x20
    800061b2:	efa98993          	addi	s3,s3,-262 # 800260a8 <disk+0x20a8>
  while(b->disk == 1) {
    800061b6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800061b8:	85ce                	mv	a1,s3
    800061ba:	854a                	mv	a0,s2
    800061bc:	ffffc097          	auipc	ra,0xffffc
    800061c0:	0c6080e7          	jalr	198(ra) # 80002282 <sleep>
  while(b->disk == 1) {
    800061c4:	00492783          	lw	a5,4(s2)
    800061c8:	fe9788e3          	beq	a5,s1,800061b8 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    800061cc:	f9042483          	lw	s1,-112(s0)
    800061d0:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    800061d4:	00479713          	slli	a4,a5,0x4
    800061d8:	0001e797          	auipc	a5,0x1e
    800061dc:	e2878793          	addi	a5,a5,-472 # 80024000 <disk>
    800061e0:	97ba                	add	a5,a5,a4
    800061e2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061e6:	00020917          	auipc	s2,0x20
    800061ea:	e1a90913          	addi	s2,s2,-486 # 80026000 <disk+0x2000>
    free_desc(i);
    800061ee:	8526                	mv	a0,s1
    800061f0:	00000097          	auipc	ra,0x0
    800061f4:	bf6080e7          	jalr	-1034(ra) # 80005de6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061f8:	0492                	slli	s1,s1,0x4
    800061fa:	00093783          	ld	a5,0(s2)
    800061fe:	94be                	add	s1,s1,a5
    80006200:	00c4d783          	lhu	a5,12(s1)
    80006204:	8b85                	andi	a5,a5,1
    80006206:	cf89                	beqz	a5,80006220 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    80006208:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000620c:	b7cd                	j	800061ee <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000620e:	00020797          	auipc	a5,0x20
    80006212:	df27b783          	ld	a5,-526(a5) # 80026000 <disk+0x2000>
    80006216:	97ba                	add	a5,a5,a4
    80006218:	4689                	li	a3,2
    8000621a:	00d79623          	sh	a3,12(a5)
    8000621e:	b5fd                	j	8000610c <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006220:	00020517          	auipc	a0,0x20
    80006224:	e8850513          	addi	a0,a0,-376 # 800260a8 <disk+0x20a8>
    80006228:	ffffb097          	auipc	ra,0xffffb
    8000622c:	b00080e7          	jalr	-1280(ra) # 80000d28 <release>
}
    80006230:	70e6                	ld	ra,120(sp)
    80006232:	7446                	ld	s0,112(sp)
    80006234:	74a6                	ld	s1,104(sp)
    80006236:	7906                	ld	s2,96(sp)
    80006238:	69e6                	ld	s3,88(sp)
    8000623a:	6a46                	ld	s4,80(sp)
    8000623c:	6aa6                	ld	s5,72(sp)
    8000623e:	6b06                	ld	s6,64(sp)
    80006240:	7be2                	ld	s7,56(sp)
    80006242:	7c42                	ld	s8,48(sp)
    80006244:	7ca2                	ld	s9,40(sp)
    80006246:	7d02                	ld	s10,32(sp)
    80006248:	6109                	addi	sp,sp,128
    8000624a:	8082                	ret
  if(write)
    8000624c:	e20d1ee3          	bnez	s10,80006088 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006250:	f8042023          	sw	zero,-128(s0)
    80006254:	bd2d                	j	8000608e <virtio_disk_rw+0xe2>

0000000080006256 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006256:	1101                	addi	sp,sp,-32
    80006258:	ec06                	sd	ra,24(sp)
    8000625a:	e822                	sd	s0,16(sp)
    8000625c:	e426                	sd	s1,8(sp)
    8000625e:	e04a                	sd	s2,0(sp)
    80006260:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006262:	00020517          	auipc	a0,0x20
    80006266:	e4650513          	addi	a0,a0,-442 # 800260a8 <disk+0x20a8>
    8000626a:	ffffb097          	auipc	ra,0xffffb
    8000626e:	a0a080e7          	jalr	-1526(ra) # 80000c74 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006272:	00020717          	auipc	a4,0x20
    80006276:	d8e70713          	addi	a4,a4,-626 # 80026000 <disk+0x2000>
    8000627a:	02075783          	lhu	a5,32(a4)
    8000627e:	6b18                	ld	a4,16(a4)
    80006280:	00275683          	lhu	a3,2(a4)
    80006284:	8ebd                	xor	a3,a3,a5
    80006286:	8a9d                	andi	a3,a3,7
    80006288:	cab9                	beqz	a3,800062de <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000628a:	0001e917          	auipc	s2,0x1e
    8000628e:	d7690913          	addi	s2,s2,-650 # 80024000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006292:	00020497          	auipc	s1,0x20
    80006296:	d6e48493          	addi	s1,s1,-658 # 80026000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000629a:	078e                	slli	a5,a5,0x3
    8000629c:	97ba                	add	a5,a5,a4
    8000629e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800062a0:	20078713          	addi	a4,a5,512
    800062a4:	0712                	slli	a4,a4,0x4
    800062a6:	974a                	add	a4,a4,s2
    800062a8:	03074703          	lbu	a4,48(a4)
    800062ac:	ef21                	bnez	a4,80006304 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800062ae:	20078793          	addi	a5,a5,512
    800062b2:	0792                	slli	a5,a5,0x4
    800062b4:	97ca                	add	a5,a5,s2
    800062b6:	7798                	ld	a4,40(a5)
    800062b8:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800062bc:	7788                	ld	a0,40(a5)
    800062be:	ffffc097          	auipc	ra,0xffffc
    800062c2:	14a080e7          	jalr	330(ra) # 80002408 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800062c6:	0204d783          	lhu	a5,32(s1)
    800062ca:	2785                	addiw	a5,a5,1
    800062cc:	8b9d                	andi	a5,a5,7
    800062ce:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800062d2:	6898                	ld	a4,16(s1)
    800062d4:	00275683          	lhu	a3,2(a4)
    800062d8:	8a9d                	andi	a3,a3,7
    800062da:	fcf690e3          	bne	a3,a5,8000629a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800062de:	10001737          	lui	a4,0x10001
    800062e2:	533c                	lw	a5,96(a4)
    800062e4:	8b8d                	andi	a5,a5,3
    800062e6:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800062e8:	00020517          	auipc	a0,0x20
    800062ec:	dc050513          	addi	a0,a0,-576 # 800260a8 <disk+0x20a8>
    800062f0:	ffffb097          	auipc	ra,0xffffb
    800062f4:	a38080e7          	jalr	-1480(ra) # 80000d28 <release>
}
    800062f8:	60e2                	ld	ra,24(sp)
    800062fa:	6442                	ld	s0,16(sp)
    800062fc:	64a2                	ld	s1,8(sp)
    800062fe:	6902                	ld	s2,0(sp)
    80006300:	6105                	addi	sp,sp,32
    80006302:	8082                	ret
      panic("virtio_disk_intr status");
    80006304:	00002517          	auipc	a0,0x2
    80006308:	51c50513          	addi	a0,a0,1308 # 80008820 <syscalls+0x3e0>
    8000630c:	ffffa097          	auipc	ra,0xffffa
    80006310:	2ca080e7          	jalr	714(ra) # 800005d6 <panic>
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
