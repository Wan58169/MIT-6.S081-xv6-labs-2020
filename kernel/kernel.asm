
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	87013103          	ld	sp,-1936(sp) # 80008870 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000060:	df478793          	addi	a5,a5,-524 # 80005e50 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7eed87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	09278793          	addi	a5,a5,146 # 80001138 <main>
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
    80000110:	d7e080e7          	jalr	-642(ra) # 80000e8a <acquire>
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
    8000012a:	60c080e7          	jalr	1548(ra) # 80002732 <either_copyin>
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
    80000152:	df0080e7          	jalr	-528(ra) # 80000f3e <release>

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
    800001a2:	cec080e7          	jalr	-788(ra) # 80000e8a <acquire>
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
    800001d2:	a9c080e7          	jalr	-1380(ra) # 80001c6a <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	29c080e7          	jalr	668(ra) # 8000247a <sleep>
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
    8000021e:	4c2080e7          	jalr	1218(ra) # 800026dc <either_copyout>
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
    8000023a:	d08080e7          	jalr	-760(ra) # 80000f3e <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	cf2080e7          	jalr	-782(ra) # 80000f3e <release>
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
    800002e2:	bac080e7          	jalr	-1108(ra) # 80000e8a <acquire>

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
    80000300:	48c080e7          	jalr	1164(ra) # 80002788 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	c32080e7          	jalr	-974(ra) # 80000f3e <release>
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
    80000454:	1b0080e7          	jalr	432(ra) # 80002600 <wakeup>
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
    80000472:	00001097          	auipc	ra,0x1
    80000476:	988080e7          	jalr	-1656(ra) # 80000dfa <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	01121797          	auipc	a5,0x1121
    80000486:	52e78793          	addi	a5,a5,1326 # 811219b0 <devsw>
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
    8000057a:	b5a50513          	addi	a0,a0,-1190 # 800080d0 <digits+0x90>
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
    8000060a:	00001097          	auipc	ra,0x1
    8000060e:	880080e7          	jalr	-1920(ra) # 80000e8a <acquire>
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
    80000772:	7d0080e7          	jalr	2000(ra) # 80000f3e <release>
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
    80000798:	666080e7          	jalr	1638(ra) # 80000dfa <initlock>
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
    800007ee:	610080e7          	jalr	1552(ra) # 80000dfa <initlock>
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
    8000080a:	638080e7          	jalr	1592(ra) # 80000e3e <push_off>

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
    8000083c:	6a6080e7          	jalr	1702(ra) # 80000ede <pop_off>
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
    800008ba:	d4a080e7          	jalr	-694(ra) # 80002600 <wakeup>
    
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
    800008fe:	590080e7          	jalr	1424(ra) # 80000e8a <acquire>
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
    80000954:	b2a080e7          	jalr	-1238(ra) # 8000247a <sleep>
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
    80000998:	5aa080e7          	jalr	1450(ra) # 80000f3e <release>
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
    80000a04:	48a080e7          	jalr	1162(ra) # 80000e8a <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	52c080e7          	jalr	1324(ra) # 80000f3e <release>
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
    80000a24:	7179                	addi	sp,sp,-48
    80000a26:	f406                	sd	ra,40(sp)
    80000a28:	f022                	sd	s0,32(sp)
    80000a2a:	ec26                	sd	s1,24(sp)
    80000a2c:	e84a                	sd	s2,16(sp)
    80000a2e:	e44e                	sd	s3,8(sp)
    80000a30:	e052                	sd	s4,0(sp)
    80000a32:	1800                	addi	s0,sp,48
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a34:	03451793          	slli	a5,a0,0x34
    80000a38:	e7b5                	bnez	a5,80000aa4 <kfree+0x80>
    80000a3a:	84aa                	mv	s1,a0
    80000a3c:	01125797          	auipc	a5,0x1125
    80000a40:	5c478793          	addi	a5,a5,1476 # 81126000 <end>
    80000a44:	06f56063          	bltu	a0,a5,80000aa4 <kfree+0x80>
    80000a48:	47c5                	li	a5,17
    80000a4a:	07ee                	slli	a5,a5,0x1b
    80000a4c:	04f57c63          	bgeu	a0,a5,80000aa4 <kfree+0x80>
    panic("kfree");

  /** 释放页块时需要解引用 */
  uint32 i = (uint64)pa/PGSIZE;
    80000a50:	00c55913          	srli	s2,a0,0xc
    80000a54:	00090a1b          	sext.w	s4,s2
  acquire(&(memrefs[i].lock));
    80000a58:	0916                	slli	s2,s2,0x5
    80000a5a:	00011997          	auipc	s3,0x11
    80000a5e:	ef698993          	addi	s3,s3,-266 # 80011950 <memrefs>
    80000a62:	994e                	add	s2,s2,s3
    80000a64:	854a                	mv	a0,s2
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	424080e7          	jalr	1060(ra) # 80000e8a <acquire>
  memrefs[i].count--;
    80000a6e:	1a02                	slli	s4,s4,0x20
    80000a70:	020a5a13          	srli	s4,s4,0x20
    80000a74:	0a16                	slli	s4,s4,0x5
    80000a76:	99d2                	add	s3,s3,s4
    80000a78:	0189a783          	lw	a5,24(s3)
    80000a7c:	37fd                	addiw	a5,a5,-1
    80000a7e:	0007871b          	sext.w	a4,a5
    80000a82:	00f9ac23          	sw	a5,24(s3)

  if(memrefs[i].count > 0) 
    80000a86:	02e05763          	blez	a4,80000ab4 <kfree+0x90>
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);

notzero:
  release(&(memrefs[i].lock));
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	4b2080e7          	jalr	1202(ra) # 80000f3e <release>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret
    panic("kfree");
    80000aa4:	00007517          	auipc	a0,0x7
    80000aa8:	5bc50513          	addi	a0,a0,1468 # 80008060 <digits+0x20>
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	a9c080e7          	jalr	-1380(ra) # 80000548 <panic>
  memset(pa, 1, PGSIZE);
    80000ab4:	6605                	lui	a2,0x1
    80000ab6:	4585                	li	a1,1
    80000ab8:	8526                	mv	a0,s1
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	4cc080e7          	jalr	1228(ra) # 80000f86 <memset>
  acquire(&kmem.lock);
    80000ac2:	00011997          	auipc	s3,0x11
    80000ac6:	e6e98993          	addi	s3,s3,-402 # 80011930 <kmem>
    80000aca:	854e                	mv	a0,s3
    80000acc:	00000097          	auipc	ra,0x0
    80000ad0:	3be080e7          	jalr	958(ra) # 80000e8a <acquire>
  r->next = kmem.freelist;
    80000ad4:	0189b783          	ld	a5,24(s3)
    80000ad8:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ada:	0099bc23          	sd	s1,24(s3)
  release(&kmem.lock);
    80000ade:	854e                	mv	a0,s3
    80000ae0:	00000097          	auipc	ra,0x0
    80000ae4:	45e080e7          	jalr	1118(ra) # 80000f3e <release>
    80000ae8:	b74d                	j	80000a8a <kfree+0x66>

0000000080000aea <freerange>:
{
    80000aea:	7179                	addi	sp,sp,-48
    80000aec:	f406                	sd	ra,40(sp)
    80000aee:	f022                	sd	s0,32(sp)
    80000af0:	ec26                	sd	s1,24(sp)
    80000af2:	e84a                	sd	s2,16(sp)
    80000af4:	e44e                	sd	s3,8(sp)
    80000af6:	e052                	sd	s4,0(sp)
    80000af8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000afa:	6785                	lui	a5,0x1
    80000afc:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b00:	94aa                	add	s1,s1,a0
    80000b02:	757d                	lui	a0,0xfffff
    80000b04:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b06:	94be                	add	s1,s1,a5
    80000b08:	0095ee63          	bltu	a1,s1,80000b24 <freerange+0x3a>
    80000b0c:	892e                	mv	s2,a1
    kfree(p);
    80000b0e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b10:	6985                	lui	s3,0x1
    kfree(p);
    80000b12:	01448533          	add	a0,s1,s4
    80000b16:	00000097          	auipc	ra,0x0
    80000b1a:	f0e080e7          	jalr	-242(ra) # 80000a24 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b1e:	94ce                	add	s1,s1,s3
    80000b20:	fe9979e3          	bgeu	s2,s1,80000b12 <freerange+0x28>
}
    80000b24:	70a2                	ld	ra,40(sp)
    80000b26:	7402                	ld	s0,32(sp)
    80000b28:	64e2                	ld	s1,24(sp)
    80000b2a:	6942                	ld	s2,16(sp)
    80000b2c:	69a2                	ld	s3,8(sp)
    80000b2e:	6a02                	ld	s4,0(sp)
    80000b30:	6145                	addi	sp,sp,48
    80000b32:	8082                	ret

0000000080000b34 <kinit>:
{
    80000b34:	7179                	addi	sp,sp,-48
    80000b36:	f406                	sd	ra,40(sp)
    80000b38:	f022                	sd	s0,32(sp)
    80000b3a:	ec26                	sd	s1,24(sp)
    80000b3c:	e84a                	sd	s2,16(sp)
    80000b3e:	e44e                	sd	s3,8(sp)
    80000b40:	1800                	addi	s0,sp,48
  for(int i=0; i<MEMREFS; i++) 
    80000b42:	00011497          	auipc	s1,0x11
    80000b46:	e0e48493          	addi	s1,s1,-498 # 80011950 <memrefs>
    80000b4a:	01111997          	auipc	s3,0x1111
    80000b4e:	e0698993          	addi	s3,s3,-506 # 81111950 <pid_lock>
    initlock(&(memrefs[i].lock), "memrefs");
    80000b52:	00007917          	auipc	s2,0x7
    80000b56:	51690913          	addi	s2,s2,1302 # 80008068 <digits+0x28>
    80000b5a:	85ca                	mv	a1,s2
    80000b5c:	8526                	mv	a0,s1
    80000b5e:	00000097          	auipc	ra,0x0
    80000b62:	29c080e7          	jalr	668(ra) # 80000dfa <initlock>
  for(int i=0; i<MEMREFS; i++) 
    80000b66:	02048493          	addi	s1,s1,32
    80000b6a:	ff3498e3          	bne	s1,s3,80000b5a <kinit+0x26>
  initlock(&kmem.lock, "kmem");
    80000b6e:	00007597          	auipc	a1,0x7
    80000b72:	50258593          	addi	a1,a1,1282 # 80008070 <digits+0x30>
    80000b76:	00011517          	auipc	a0,0x11
    80000b7a:	dba50513          	addi	a0,a0,-582 # 80011930 <kmem>
    80000b7e:	00000097          	auipc	ra,0x0
    80000b82:	27c080e7          	jalr	636(ra) # 80000dfa <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b86:	45c5                	li	a1,17
    80000b88:	05ee                	slli	a1,a1,0x1b
    80000b8a:	01125517          	auipc	a0,0x1125
    80000b8e:	47650513          	addi	a0,a0,1142 # 81126000 <end>
    80000b92:	00000097          	auipc	ra,0x0
    80000b96:	f58080e7          	jalr	-168(ra) # 80000aea <freerange>
}
    80000b9a:	70a2                	ld	ra,40(sp)
    80000b9c:	7402                	ld	s0,32(sp)
    80000b9e:	64e2                	ld	s1,24(sp)
    80000ba0:	6942                	ld	s2,16(sp)
    80000ba2:	69a2                	ld	s3,8(sp)
    80000ba4:	6145                	addi	sp,sp,48
    80000ba6:	8082                	ret

0000000080000ba8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ba8:	7179                	addi	sp,sp,-48
    80000baa:	f406                	sd	ra,40(sp)
    80000bac:	f022                	sd	s0,32(sp)
    80000bae:	ec26                	sd	s1,24(sp)
    80000bb0:	e84a                	sd	s2,16(sp)
    80000bb2:	e44e                	sd	s3,8(sp)
    80000bb4:	e052                	sd	s4,0(sp)
    80000bb6:	1800                	addi	s0,sp,48
  struct run *r;

  acquire(&kmem.lock);
    80000bb8:	00011497          	auipc	s1,0x11
    80000bbc:	d7848493          	addi	s1,s1,-648 # 80011930 <kmem>
    80000bc0:	8526                	mv	a0,s1
    80000bc2:	00000097          	auipc	ra,0x0
    80000bc6:	2c8080e7          	jalr	712(ra) # 80000e8a <acquire>
  r = kmem.freelist;
    80000bca:	6c84                	ld	s1,24(s1)
  
  if(r) {
    80000bcc:	c4a5                	beqz	s1,80000c34 <kalloc+0x8c>
    /** 初始化引用计数，刚alloc完，引用必然为1 */
    uint32 i = (uint64)r/PGSIZE;
    80000bce:	00c4d993          	srli	s3,s1,0xc
    acquire(&(memrefs[i].lock));
    80000bd2:	02099913          	slli	s2,s3,0x20
    80000bd6:	02095913          	srli	s2,s2,0x20
    80000bda:	0916                	slli	s2,s2,0x5
    80000bdc:	00011a17          	auipc	s4,0x11
    80000be0:	d74a0a13          	addi	s4,s4,-652 # 80011950 <memrefs>
    80000be4:	9952                	add	s2,s2,s4
    80000be6:	854a                	mv	a0,s2
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	2a2080e7          	jalr	674(ra) # 80000e8a <acquire>
    memrefs[i].count = 1;
    80000bf0:	4785                	li	a5,1
    80000bf2:	00f92c23          	sw	a5,24(s2)
    release(&(memrefs[i].lock));
    80000bf6:	854a                	mv	a0,s2
    80000bf8:	00000097          	auipc	ra,0x0
    80000bfc:	346080e7          	jalr	838(ra) # 80000f3e <release>

    kmem.freelist = r->next;
    80000c00:	609c                	ld	a5,0(s1)
    80000c02:	00011517          	auipc	a0,0x11
    80000c06:	d2e50513          	addi	a0,a0,-722 # 80011930 <kmem>
    80000c0a:	ed1c                	sd	a5,24(a0)
  }
  release(&kmem.lock);
    80000c0c:	00000097          	auipc	ra,0x0
    80000c10:	332080e7          	jalr	818(ra) # 80000f3e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c14:	6605                	lui	a2,0x1
    80000c16:	4595                	li	a1,5
    80000c18:	8526                	mv	a0,s1
    80000c1a:	00000097          	auipc	ra,0x0
    80000c1e:	36c080e7          	jalr	876(ra) # 80000f86 <memset>
  return (void*)r;
}
    80000c22:	8526                	mv	a0,s1
    80000c24:	70a2                	ld	ra,40(sp)
    80000c26:	7402                	ld	s0,32(sp)
    80000c28:	64e2                	ld	s1,24(sp)
    80000c2a:	6942                	ld	s2,16(sp)
    80000c2c:	69a2                	ld	s3,8(sp)
    80000c2e:	6a02                	ld	s4,0(sp)
    80000c30:	6145                	addi	sp,sp,48
    80000c32:	8082                	ret
  release(&kmem.lock);
    80000c34:	00011517          	auipc	a0,0x11
    80000c38:	cfc50513          	addi	a0,a0,-772 # 80011930 <kmem>
    80000c3c:	00000097          	auipc	ra,0x0
    80000c40:	302080e7          	jalr	770(ra) # 80000f3e <release>
  if(r)
    80000c44:	bff9                	j	80000c22 <kalloc+0x7a>

0000000080000c46 <incr_ref>:

/** 新分配的页块，也要增加引用 */
int
incr_ref(void* pa)
{
   if(((uint64)pa%PGSIZE)!=0 || (char*)pa<end || (uint64)pa>=PHYSTOP)
    80000c46:	03451713          	slli	a4,a0,0x34
    80000c4a:	eb3d                	bnez	a4,80000cc0 <incr_ref+0x7a>
    80000c4c:	87aa                	mv	a5,a0
    80000c4e:	01125717          	auipc	a4,0x1125
    80000c52:	3b270713          	addi	a4,a4,946 # 81126000 <end>
    return -1;
    80000c56:	557d                	li	a0,-1
   if(((uint64)pa%PGSIZE)!=0 || (char*)pa<end || (uint64)pa>=PHYSTOP)
    80000c58:	00e7e663          	bltu	a5,a4,80000c64 <incr_ref+0x1e>
    80000c5c:	4745                	li	a4,17
    80000c5e:	076e                	slli	a4,a4,0x1b
    80000c60:	00e7e363          	bltu	a5,a4,80000c66 <incr_ref+0x20>
  uint32 i = (uint64)pa/PGSIZE;
  acquire(&(memrefs[i].lock));
  memrefs[i].count++;
  release(&(memrefs[i].lock));
  return 1;
}
    80000c64:	8082                	ret
{
    80000c66:	7179                	addi	sp,sp,-48
    80000c68:	f406                	sd	ra,40(sp)
    80000c6a:	f022                	sd	s0,32(sp)
    80000c6c:	ec26                	sd	s1,24(sp)
    80000c6e:	e84a                	sd	s2,16(sp)
    80000c70:	e44e                	sd	s3,8(sp)
    80000c72:	1800                	addi	s0,sp,48
  uint32 i = (uint64)pa/PGSIZE;
    80000c74:	83b1                	srli	a5,a5,0xc
    80000c76:	0007899b          	sext.w	s3,a5
  acquire(&(memrefs[i].lock));
    80000c7a:	0796                	slli	a5,a5,0x5
    80000c7c:	00011917          	auipc	s2,0x11
    80000c80:	cd490913          	addi	s2,s2,-812 # 80011950 <memrefs>
    80000c84:	012784b3          	add	s1,a5,s2
    80000c88:	8526                	mv	a0,s1
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	200080e7          	jalr	512(ra) # 80000e8a <acquire>
  memrefs[i].count++;
    80000c92:	1982                	slli	s3,s3,0x20
    80000c94:	0209d993          	srli	s3,s3,0x20
    80000c98:	0996                	slli	s3,s3,0x5
    80000c9a:	994e                	add	s2,s2,s3
    80000c9c:	01892783          	lw	a5,24(s2)
    80000ca0:	2785                	addiw	a5,a5,1
    80000ca2:	00f92c23          	sw	a5,24(s2)
  release(&(memrefs[i].lock));
    80000ca6:	8526                	mv	a0,s1
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	296080e7          	jalr	662(ra) # 80000f3e <release>
  return 1;
    80000cb0:	4505                	li	a0,1
}
    80000cb2:	70a2                	ld	ra,40(sp)
    80000cb4:	7402                	ld	s0,32(sp)
    80000cb6:	64e2                	ld	s1,24(sp)
    80000cb8:	6942                	ld	s2,16(sp)
    80000cba:	69a2                	ld	s3,8(sp)
    80000cbc:	6145                	addi	sp,sp,48
    80000cbe:	8082                	ret
    return -1;
    80000cc0:	557d                	li	a0,-1
    80000cc2:	8082                	ret

0000000080000cc4 <iscow>:

/** 检查该页块是否为copy-on-write */
int 
iscow(pagetable_t pagetable, uint64 va)
{
  if(va > MAXVA)
    80000cc4:	4785                	li	a5,1
    80000cc6:	179a                	slli	a5,a5,0x26
    80000cc8:	00b7f463          	bgeu	a5,a1,80000cd0 <iscow+0xc>
    return 0;
    80000ccc:	4501                	li	a0,0
  pte_t* pte = walk(pagetable, va, 0);
  if(pte==0 || (*pte&PTE_V)==0)
    return 0;

  return (*pte&PTE_COW);
}
    80000cce:	8082                	ret
{
    80000cd0:	1141                	addi	sp,sp,-16
    80000cd2:	e406                	sd	ra,8(sp)
    80000cd4:	e022                	sd	s0,0(sp)
    80000cd6:	0800                	addi	s0,sp,16
  pte_t* pte = walk(pagetable, va, 0);
    80000cd8:	4601                	li	a2,0
    80000cda:	00000097          	auipc	ra,0x0
    80000cde:	598080e7          	jalr	1432(ra) # 80001272 <walk>
  if(pte==0 || (*pte&PTE_V)==0)
    80000ce2:	cd09                	beqz	a0,80000cfc <iscow+0x38>
    80000ce4:	611c                	ld	a5,0(a0)
    80000ce6:	0017f713          	andi	a4,a5,1
    return 0;
    80000cea:	4501                	li	a0,0
  if(pte==0 || (*pte&PTE_V)==0)
    80000cec:	c701                	beqz	a4,80000cf4 <iscow+0x30>
  return (*pte&PTE_COW);
    80000cee:	1007f513          	andi	a0,a5,256
    80000cf2:	2501                	sext.w	a0,a0
}
    80000cf4:	60a2                	ld	ra,8(sp)
    80000cf6:	6402                	ld	s0,0(sp)
    80000cf8:	0141                	addi	sp,sp,16
    80000cfa:	8082                	ret
    return 0;
    80000cfc:	4501                	li	a0,0
    80000cfe:	bfdd                	j	80000cf4 <iscow+0x30>

0000000080000d00 <cowcopy>:

/** copy-on-write拷贝工作（父->子） */
uint64 
cowcopy(pagetable_t pagetable, uint64 va)
{
    80000d00:	715d                	addi	sp,sp,-80
    80000d02:	e486                	sd	ra,72(sp)
    80000d04:	e0a2                	sd	s0,64(sp)
    80000d06:	fc26                	sd	s1,56(sp)
    80000d08:	f84a                	sd	s2,48(sp)
    80000d0a:	f44e                	sd	s3,40(sp)
    80000d0c:	f052                	sd	s4,32(sp)
    80000d0e:	ec56                	sd	s5,24(sp)
    80000d10:	e85a                	sd	s6,16(sp)
    80000d12:	e45e                	sd	s7,8(sp)
    80000d14:	0880                	addi	s0,sp,80
    80000d16:	8baa                	mv	s7,a0
  va = PGROUNDDOWN(va);
    80000d18:	77fd                	lui	a5,0xfffff
    80000d1a:	00f5fb33          	and	s6,a1,a5
  pte_t* pte = walk(pagetable, va, 0);
    80000d1e:	4601                	li	a2,0
    80000d20:	85da                	mv	a1,s6
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	550080e7          	jalr	1360(ra) # 80001272 <walk>
    80000d2a:	8a2a                	mv	s4,a0
  uint64 pa = PTE2PA(*pte);
    80000d2c:	6104                	ld	s1,0(a0)
    80000d2e:	80a9                	srli	s1,s1,0xa
    80000d30:	04b2                	slli	s1,s1,0xc
  uint32 i = pa/PGSIZE;
    80000d32:	00c4d913          	srli	s2,s1,0xc

  /** 检查是否只有一个进程正在使用该页块 */
  acquire(&(memrefs[i].lock));
    80000d36:	02091993          	slli	s3,s2,0x20
    80000d3a:	0209d993          	srli	s3,s3,0x20
    80000d3e:	0996                	slli	s3,s3,0x5
    80000d40:	00011a97          	auipc	s5,0x11
    80000d44:	c10a8a93          	addi	s5,s5,-1008 # 80011950 <memrefs>
    80000d48:	99d6                	add	s3,s3,s5
    80000d4a:	854e                	mv	a0,s3
    80000d4c:	00000097          	auipc	ra,0x0
    80000d50:	13e080e7          	jalr	318(ra) # 80000e8a <acquire>
  if(memrefs[i].count == 1) {
    80000d54:	0189a703          	lw	a4,24(s3)
    80000d58:	4785                	li	a5,1
    80000d5a:	06f70a63          	beq	a4,a5,80000dce <cowcopy+0xce>
    *pte &= (~PTE_COW);
    release(&(memrefs[i].lock));
    return pa;
  }

  release(&(memrefs[i].lock));
    80000d5e:	854e                	mv	a0,s3
    80000d60:	00000097          	auipc	ra,0x0
    80000d64:	1de080e7          	jalr	478(ra) # 80000f3e <release>
  /** 尝试分配空间（缺页中断handler） */
  char* mem = kalloc();
    80000d68:	00000097          	auipc	ra,0x0
    80000d6c:	e40080e7          	jalr	-448(ra) # 80000ba8 <kalloc>
    80000d70:	892a                	mv	s2,a0
  if(mem == 0)
    80000d72:	c151                	beqz	a0,80000df6 <cowcopy+0xf6>
    return 0;

  /** 拷贝工作 */
  memmove(mem, (char*)pa, PGSIZE);
    80000d74:	89a6                	mv	s3,s1
    80000d76:	6605                	lui	a2,0x1
    80000d78:	85a6                	mv	a1,s1
    80000d7a:	00000097          	auipc	ra,0x0
    80000d7e:	26c080e7          	jalr	620(ra) # 80000fe6 <memmove>
  *pte &= (~PTE_V);
    80000d82:	000a3703          	ld	a4,0(s4)
    80000d86:	ffe77793          	andi	a5,a4,-2
    80000d8a:	00fa3023          	sd	a5,0(s4)
  uint64 flag = PTE_FLAGS(*pte);
  flag |= PTE_W;
  flag &= (~PTE_COW);

  if(mappages(pagetable, va, PGSIZE, (uint64)mem, flag) != 0) 
    80000d8e:	84ca                	mv	s1,s2
  flag &= (~PTE_COW);
    80000d90:	2fe77713          	andi	a4,a4,766
  if(mappages(pagetable, va, PGSIZE, (uint64)mem, flag) != 0) 
    80000d94:	00476713          	ori	a4,a4,4
    80000d98:	86ca                	mv	a3,s2
    80000d9a:	6605                	lui	a2,0x1
    80000d9c:	85da                	mv	a1,s6
    80000d9e:	855e                	mv	a0,s7
    80000da0:	00000097          	auipc	ra,0x0
    80000da4:	618080e7          	jalr	1560(ra) # 800013b8 <mappages>
    80000da8:	c129                	beqz	a0,80000dea <cowcopy+0xea>
  
  /** 顺利结束拷贝工作 */
  goto rest;

freeing:
  kfree(mem);
    80000daa:	854a                	mv	a0,s2
    80000dac:	00000097          	auipc	ra,0x0
    80000db0:	c78080e7          	jalr	-904(ra) # 80000a24 <kfree>
  return 0;
    80000db4:	4481                	li	s1,0
  
rest:
  kfree((char*)PGROUNDDOWN(pa));
  return (uint64)mem;
    80000db6:	8526                	mv	a0,s1
    80000db8:	60a6                	ld	ra,72(sp)
    80000dba:	6406                	ld	s0,64(sp)
    80000dbc:	74e2                	ld	s1,56(sp)
    80000dbe:	7942                	ld	s2,48(sp)
    80000dc0:	79a2                	ld	s3,40(sp)
    80000dc2:	7a02                	ld	s4,32(sp)
    80000dc4:	6ae2                	ld	s5,24(sp)
    80000dc6:	6b42                	ld	s6,16(sp)
    80000dc8:	6ba2                	ld	s7,8(sp)
    80000dca:	6161                	addi	sp,sp,80
    80000dcc:	8082                	ret
    *pte &= (~PTE_COW);
    80000dce:	000a3783          	ld	a5,0(s4)
    80000dd2:	eff7f793          	andi	a5,a5,-257
    80000dd6:	0047e793          	ori	a5,a5,4
    80000dda:	00fa3023          	sd	a5,0(s4)
    release(&(memrefs[i].lock));
    80000dde:	854e                	mv	a0,s3
    80000de0:	00000097          	auipc	ra,0x0
    80000de4:	15e080e7          	jalr	350(ra) # 80000f3e <release>
    return pa;
    80000de8:	b7f9                	j	80000db6 <cowcopy+0xb6>
  kfree((char*)PGROUNDDOWN(pa));
    80000dea:	854e                	mv	a0,s3
    80000dec:	00000097          	auipc	ra,0x0
    80000df0:	c38080e7          	jalr	-968(ra) # 80000a24 <kfree>
  return (uint64)mem;
    80000df4:	b7c9                	j	80000db6 <cowcopy+0xb6>
    return 0;
    80000df6:	4481                	li	s1,0
    80000df8:	bf7d                	j	80000db6 <cowcopy+0xb6>

0000000080000dfa <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e422                	sd	s0,8(sp)
    80000dfe:	0800                	addi	s0,sp,16
  lk->name = name;
    80000e00:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000e02:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000e06:	00053823          	sd	zero,16(a0)
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000e10:	411c                	lw	a5,0(a0)
    80000e12:	e399                	bnez	a5,80000e18 <holding+0x8>
    80000e14:	4501                	li	a0,0
  return r;
}
    80000e16:	8082                	ret
{
    80000e18:	1101                	addi	sp,sp,-32
    80000e1a:	ec06                	sd	ra,24(sp)
    80000e1c:	e822                	sd	s0,16(sp)
    80000e1e:	e426                	sd	s1,8(sp)
    80000e20:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000e22:	6904                	ld	s1,16(a0)
    80000e24:	00001097          	auipc	ra,0x1
    80000e28:	e2a080e7          	jalr	-470(ra) # 80001c4e <mycpu>
    80000e2c:	40a48533          	sub	a0,s1,a0
    80000e30:	00153513          	seqz	a0,a0
}
    80000e34:	60e2                	ld	ra,24(sp)
    80000e36:	6442                	ld	s0,16(sp)
    80000e38:	64a2                	ld	s1,8(sp)
    80000e3a:	6105                	addi	sp,sp,32
    80000e3c:	8082                	ret

0000000080000e3e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000e3e:	1101                	addi	sp,sp,-32
    80000e40:	ec06                	sd	ra,24(sp)
    80000e42:	e822                	sd	s0,16(sp)
    80000e44:	e426                	sd	s1,8(sp)
    80000e46:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e48:	100024f3          	csrr	s1,sstatus
    80000e4c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000e50:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e52:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000e56:	00001097          	auipc	ra,0x1
    80000e5a:	df8080e7          	jalr	-520(ra) # 80001c4e <mycpu>
    80000e5e:	5d3c                	lw	a5,120(a0)
    80000e60:	cf89                	beqz	a5,80000e7a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000e62:	00001097          	auipc	ra,0x1
    80000e66:	dec080e7          	jalr	-532(ra) # 80001c4e <mycpu>
    80000e6a:	5d3c                	lw	a5,120(a0)
    80000e6c:	2785                	addiw	a5,a5,1
    80000e6e:	dd3c                	sw	a5,120(a0)
}
    80000e70:	60e2                	ld	ra,24(sp)
    80000e72:	6442                	ld	s0,16(sp)
    80000e74:	64a2                	ld	s1,8(sp)
    80000e76:	6105                	addi	sp,sp,32
    80000e78:	8082                	ret
    mycpu()->intena = old;
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	dd4080e7          	jalr	-556(ra) # 80001c4e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000e82:	8085                	srli	s1,s1,0x1
    80000e84:	8885                	andi	s1,s1,1
    80000e86:	dd64                	sw	s1,124(a0)
    80000e88:	bfe9                	j	80000e62 <push_off+0x24>

0000000080000e8a <acquire>:
{
    80000e8a:	1101                	addi	sp,sp,-32
    80000e8c:	ec06                	sd	ra,24(sp)
    80000e8e:	e822                	sd	s0,16(sp)
    80000e90:	e426                	sd	s1,8(sp)
    80000e92:	1000                	addi	s0,sp,32
    80000e94:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000e96:	00000097          	auipc	ra,0x0
    80000e9a:	fa8080e7          	jalr	-88(ra) # 80000e3e <push_off>
  if(holding(lk))
    80000e9e:	8526                	mv	a0,s1
    80000ea0:	00000097          	auipc	ra,0x0
    80000ea4:	f70080e7          	jalr	-144(ra) # 80000e10 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000ea8:	4705                	li	a4,1
  if(holding(lk))
    80000eaa:	e115                	bnez	a0,80000ece <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000eac:	87ba                	mv	a5,a4
    80000eae:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000eb2:	2781                	sext.w	a5,a5
    80000eb4:	ffe5                	bnez	a5,80000eac <acquire+0x22>
  __sync_synchronize();
    80000eb6:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000eba:	00001097          	auipc	ra,0x1
    80000ebe:	d94080e7          	jalr	-620(ra) # 80001c4e <mycpu>
    80000ec2:	e888                	sd	a0,16(s1)
}
    80000ec4:	60e2                	ld	ra,24(sp)
    80000ec6:	6442                	ld	s0,16(sp)
    80000ec8:	64a2                	ld	s1,8(sp)
    80000eca:	6105                	addi	sp,sp,32
    80000ecc:	8082                	ret
    panic("acquire");
    80000ece:	00007517          	auipc	a0,0x7
    80000ed2:	1aa50513          	addi	a0,a0,426 # 80008078 <digits+0x38>
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	672080e7          	jalr	1650(ra) # 80000548 <panic>

0000000080000ede <pop_off>:

void
pop_off(void)
{
    80000ede:	1141                	addi	sp,sp,-16
    80000ee0:	e406                	sd	ra,8(sp)
    80000ee2:	e022                	sd	s0,0(sp)
    80000ee4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000ee6:	00001097          	auipc	ra,0x1
    80000eea:	d68080e7          	jalr	-664(ra) # 80001c4e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000eee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ef2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ef4:	e78d                	bnez	a5,80000f1e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ef6:	5d3c                	lw	a5,120(a0)
    80000ef8:	02f05b63          	blez	a5,80000f2e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000efc:	37fd                	addiw	a5,a5,-1
    80000efe:	0007871b          	sext.w	a4,a5
    80000f02:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000f04:	eb09                	bnez	a4,80000f16 <pop_off+0x38>
    80000f06:	5d7c                	lw	a5,124(a0)
    80000f08:	c799                	beqz	a5,80000f16 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000f0a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000f0e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000f12:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000f16:	60a2                	ld	ra,8(sp)
    80000f18:	6402                	ld	s0,0(sp)
    80000f1a:	0141                	addi	sp,sp,16
    80000f1c:	8082                	ret
    panic("pop_off - interruptible");
    80000f1e:	00007517          	auipc	a0,0x7
    80000f22:	16250513          	addi	a0,a0,354 # 80008080 <digits+0x40>
    80000f26:	fffff097          	auipc	ra,0xfffff
    80000f2a:	622080e7          	jalr	1570(ra) # 80000548 <panic>
    panic("pop_off");
    80000f2e:	00007517          	auipc	a0,0x7
    80000f32:	16a50513          	addi	a0,a0,362 # 80008098 <digits+0x58>
    80000f36:	fffff097          	auipc	ra,0xfffff
    80000f3a:	612080e7          	jalr	1554(ra) # 80000548 <panic>

0000000080000f3e <release>:
{
    80000f3e:	1101                	addi	sp,sp,-32
    80000f40:	ec06                	sd	ra,24(sp)
    80000f42:	e822                	sd	s0,16(sp)
    80000f44:	e426                	sd	s1,8(sp)
    80000f46:	1000                	addi	s0,sp,32
    80000f48:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000f4a:	00000097          	auipc	ra,0x0
    80000f4e:	ec6080e7          	jalr	-314(ra) # 80000e10 <holding>
    80000f52:	c115                	beqz	a0,80000f76 <release+0x38>
  lk->cpu = 0;
    80000f54:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000f58:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000f5c:	0f50000f          	fence	iorw,ow
    80000f60:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	f7a080e7          	jalr	-134(ra) # 80000ede <pop_off>
}
    80000f6c:	60e2                	ld	ra,24(sp)
    80000f6e:	6442                	ld	s0,16(sp)
    80000f70:	64a2                	ld	s1,8(sp)
    80000f72:	6105                	addi	sp,sp,32
    80000f74:	8082                	ret
    panic("release");
    80000f76:	00007517          	auipc	a0,0x7
    80000f7a:	12a50513          	addi	a0,a0,298 # 800080a0 <digits+0x60>
    80000f7e:	fffff097          	auipc	ra,0xfffff
    80000f82:	5ca080e7          	jalr	1482(ra) # 80000548 <panic>

0000000080000f86 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000f86:	1141                	addi	sp,sp,-16
    80000f88:	e422                	sd	s0,8(sp)
    80000f8a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000f8c:	ce09                	beqz	a2,80000fa6 <memset+0x20>
    80000f8e:	87aa                	mv	a5,a0
    80000f90:	fff6071b          	addiw	a4,a2,-1
    80000f94:	1702                	slli	a4,a4,0x20
    80000f96:	9301                	srli	a4,a4,0x20
    80000f98:	0705                	addi	a4,a4,1
    80000f9a:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000f9c:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7eed9000>
  for(i = 0; i < n; i++){
    80000fa0:	0785                	addi	a5,a5,1
    80000fa2:	fee79de3          	bne	a5,a4,80000f9c <memset+0x16>
  }
  return dst;
}
    80000fa6:	6422                	ld	s0,8(sp)
    80000fa8:	0141                	addi	sp,sp,16
    80000faa:	8082                	ret

0000000080000fac <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000fac:	1141                	addi	sp,sp,-16
    80000fae:	e422                	sd	s0,8(sp)
    80000fb0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000fb2:	ca05                	beqz	a2,80000fe2 <memcmp+0x36>
    80000fb4:	fff6069b          	addiw	a3,a2,-1
    80000fb8:	1682                	slli	a3,a3,0x20
    80000fba:	9281                	srli	a3,a3,0x20
    80000fbc:	0685                	addi	a3,a3,1
    80000fbe:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000fc0:	00054783          	lbu	a5,0(a0)
    80000fc4:	0005c703          	lbu	a4,0(a1)
    80000fc8:	00e79863          	bne	a5,a4,80000fd8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000fcc:	0505                	addi	a0,a0,1
    80000fce:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000fd0:	fed518e3          	bne	a0,a3,80000fc0 <memcmp+0x14>
  }

  return 0;
    80000fd4:	4501                	li	a0,0
    80000fd6:	a019                	j	80000fdc <memcmp+0x30>
      return *s1 - *s2;
    80000fd8:	40e7853b          	subw	a0,a5,a4
}
    80000fdc:	6422                	ld	s0,8(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  return 0;
    80000fe2:	4501                	li	a0,0
    80000fe4:	bfe5                	j	80000fdc <memcmp+0x30>

0000000080000fe6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000fe6:	1141                	addi	sp,sp,-16
    80000fe8:	e422                	sd	s0,8(sp)
    80000fea:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000fec:	00a5f963          	bgeu	a1,a0,80000ffe <memmove+0x18>
    80000ff0:	02061713          	slli	a4,a2,0x20
    80000ff4:	9301                	srli	a4,a4,0x20
    80000ff6:	00e587b3          	add	a5,a1,a4
    80000ffa:	02f56563          	bltu	a0,a5,80001024 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ffe:	fff6069b          	addiw	a3,a2,-1
    80001002:	ce11                	beqz	a2,8000101e <memmove+0x38>
    80001004:	1682                	slli	a3,a3,0x20
    80001006:	9281                	srli	a3,a3,0x20
    80001008:	0685                	addi	a3,a3,1
    8000100a:	96ae                	add	a3,a3,a1
    8000100c:	87aa                	mv	a5,a0
      *d++ = *s++;
    8000100e:	0585                	addi	a1,a1,1
    80001010:	0785                	addi	a5,a5,1
    80001012:	fff5c703          	lbu	a4,-1(a1)
    80001016:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    8000101a:	fed59ae3          	bne	a1,a3,8000100e <memmove+0x28>

  return dst;
}
    8000101e:	6422                	ld	s0,8(sp)
    80001020:	0141                	addi	sp,sp,16
    80001022:	8082                	ret
    d += n;
    80001024:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80001026:	fff6069b          	addiw	a3,a2,-1
    8000102a:	da75                	beqz	a2,8000101e <memmove+0x38>
    8000102c:	02069613          	slli	a2,a3,0x20
    80001030:	9201                	srli	a2,a2,0x20
    80001032:	fff64613          	not	a2,a2
    80001036:	963e                	add	a2,a2,a5
      *--d = *--s;
    80001038:	17fd                	addi	a5,a5,-1
    8000103a:	177d                	addi	a4,a4,-1
    8000103c:	0007c683          	lbu	a3,0(a5)
    80001040:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80001044:	fec79ae3          	bne	a5,a2,80001038 <memmove+0x52>
    80001048:	bfd9                	j	8000101e <memmove+0x38>

000000008000104a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000104a:	1141                	addi	sp,sp,-16
    8000104c:	e406                	sd	ra,8(sp)
    8000104e:	e022                	sd	s0,0(sp)
    80001050:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80001052:	00000097          	auipc	ra,0x0
    80001056:	f94080e7          	jalr	-108(ra) # 80000fe6 <memmove>
}
    8000105a:	60a2                	ld	ra,8(sp)
    8000105c:	6402                	ld	s0,0(sp)
    8000105e:	0141                	addi	sp,sp,16
    80001060:	8082                	ret

0000000080001062 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e422                	sd	s0,8(sp)
    80001066:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001068:	ce11                	beqz	a2,80001084 <strncmp+0x22>
    8000106a:	00054783          	lbu	a5,0(a0)
    8000106e:	cf89                	beqz	a5,80001088 <strncmp+0x26>
    80001070:	0005c703          	lbu	a4,0(a1)
    80001074:	00f71a63          	bne	a4,a5,80001088 <strncmp+0x26>
    n--, p++, q++;
    80001078:	367d                	addiw	a2,a2,-1
    8000107a:	0505                	addi	a0,a0,1
    8000107c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000107e:	f675                	bnez	a2,8000106a <strncmp+0x8>
  if(n == 0)
    return 0;
    80001080:	4501                	li	a0,0
    80001082:	a809                	j	80001094 <strncmp+0x32>
    80001084:	4501                	li	a0,0
    80001086:	a039                	j	80001094 <strncmp+0x32>
  if(n == 0)
    80001088:	ca09                	beqz	a2,8000109a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    8000108a:	00054503          	lbu	a0,0(a0)
    8000108e:	0005c783          	lbu	a5,0(a1)
    80001092:	9d1d                	subw	a0,a0,a5
}
    80001094:	6422                	ld	s0,8(sp)
    80001096:	0141                	addi	sp,sp,16
    80001098:	8082                	ret
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	bfe5                	j	80001094 <strncmp+0x32>

000000008000109e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e422                	sd	s0,8(sp)
    800010a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800010a4:	872a                	mv	a4,a0
    800010a6:	8832                	mv	a6,a2
    800010a8:	367d                	addiw	a2,a2,-1
    800010aa:	01005963          	blez	a6,800010bc <strncpy+0x1e>
    800010ae:	0705                	addi	a4,a4,1
    800010b0:	0005c783          	lbu	a5,0(a1)
    800010b4:	fef70fa3          	sb	a5,-1(a4)
    800010b8:	0585                	addi	a1,a1,1
    800010ba:	f7f5                	bnez	a5,800010a6 <strncpy+0x8>
    ;
  while(n-- > 0)
    800010bc:	00c05d63          	blez	a2,800010d6 <strncpy+0x38>
    800010c0:	86ba                	mv	a3,a4
    *s++ = 0;
    800010c2:	0685                	addi	a3,a3,1
    800010c4:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800010c8:	fff6c793          	not	a5,a3
    800010cc:	9fb9                	addw	a5,a5,a4
    800010ce:	010787bb          	addw	a5,a5,a6
    800010d2:	fef048e3          	bgtz	a5,800010c2 <strncpy+0x24>
  return os;
}
    800010d6:	6422                	ld	s0,8(sp)
    800010d8:	0141                	addi	sp,sp,16
    800010da:	8082                	ret

00000000800010dc <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800010dc:	1141                	addi	sp,sp,-16
    800010de:	e422                	sd	s0,8(sp)
    800010e0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800010e2:	02c05363          	blez	a2,80001108 <safestrcpy+0x2c>
    800010e6:	fff6069b          	addiw	a3,a2,-1
    800010ea:	1682                	slli	a3,a3,0x20
    800010ec:	9281                	srli	a3,a3,0x20
    800010ee:	96ae                	add	a3,a3,a1
    800010f0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800010f2:	00d58963          	beq	a1,a3,80001104 <safestrcpy+0x28>
    800010f6:	0585                	addi	a1,a1,1
    800010f8:	0785                	addi	a5,a5,1
    800010fa:	fff5c703          	lbu	a4,-1(a1)
    800010fe:	fee78fa3          	sb	a4,-1(a5)
    80001102:	fb65                	bnez	a4,800010f2 <safestrcpy+0x16>
    ;
  *s = 0;
    80001104:	00078023          	sb	zero,0(a5)
  return os;
}
    80001108:	6422                	ld	s0,8(sp)
    8000110a:	0141                	addi	sp,sp,16
    8000110c:	8082                	ret

000000008000110e <strlen>:

int
strlen(const char *s)
{
    8000110e:	1141                	addi	sp,sp,-16
    80001110:	e422                	sd	s0,8(sp)
    80001112:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001114:	00054783          	lbu	a5,0(a0)
    80001118:	cf91                	beqz	a5,80001134 <strlen+0x26>
    8000111a:	0505                	addi	a0,a0,1
    8000111c:	87aa                	mv	a5,a0
    8000111e:	4685                	li	a3,1
    80001120:	9e89                	subw	a3,a3,a0
    80001122:	00f6853b          	addw	a0,a3,a5
    80001126:	0785                	addi	a5,a5,1
    80001128:	fff7c703          	lbu	a4,-1(a5)
    8000112c:	fb7d                	bnez	a4,80001122 <strlen+0x14>
    ;
  return n;
}
    8000112e:	6422                	ld	s0,8(sp)
    80001130:	0141                	addi	sp,sp,16
    80001132:	8082                	ret
  for(n = 0; s[n]; n++)
    80001134:	4501                	li	a0,0
    80001136:	bfe5                	j	8000112e <strlen+0x20>

0000000080001138 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001140:	00001097          	auipc	ra,0x1
    80001144:	afe080e7          	jalr	-1282(ra) # 80001c3e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001148:	00008717          	auipc	a4,0x8
    8000114c:	ec470713          	addi	a4,a4,-316 # 8000900c <started>
  if(cpuid() == 0){
    80001150:	c139                	beqz	a0,80001196 <main+0x5e>
    while(started == 0)
    80001152:	431c                	lw	a5,0(a4)
    80001154:	2781                	sext.w	a5,a5
    80001156:	dff5                	beqz	a5,80001152 <main+0x1a>
      ;
    __sync_synchronize();
    80001158:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000115c:	00001097          	auipc	ra,0x1
    80001160:	ae2080e7          	jalr	-1310(ra) # 80001c3e <cpuid>
    80001164:	85aa                	mv	a1,a0
    80001166:	00007517          	auipc	a0,0x7
    8000116a:	f5a50513          	addi	a0,a0,-166 # 800080c0 <digits+0x80>
    8000116e:	fffff097          	auipc	ra,0xfffff
    80001172:	424080e7          	jalr	1060(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80001176:	00000097          	auipc	ra,0x0
    8000117a:	0d8080e7          	jalr	216(ra) # 8000124e <kvminithart>
    trapinithart();   // install kernel trap vector
    8000117e:	00001097          	auipc	ra,0x1
    80001182:	74a080e7          	jalr	1866(ra) # 800028c8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001186:	00005097          	auipc	ra,0x5
    8000118a:	d0a080e7          	jalr	-758(ra) # 80005e90 <plicinithart>
  }

  scheduler();        
    8000118e:	00001097          	auipc	ra,0x1
    80001192:	00c080e7          	jalr	12(ra) # 8000219a <scheduler>
    consoleinit();
    80001196:	fffff097          	auipc	ra,0xfffff
    8000119a:	2c4080e7          	jalr	708(ra) # 8000045a <consoleinit>
    printfinit();
    8000119e:	fffff097          	auipc	ra,0xfffff
    800011a2:	5da080e7          	jalr	1498(ra) # 80000778 <printfinit>
    printf("\n");
    800011a6:	00007517          	auipc	a0,0x7
    800011aa:	f2a50513          	addi	a0,a0,-214 # 800080d0 <digits+0x90>
    800011ae:	fffff097          	auipc	ra,0xfffff
    800011b2:	3e4080e7          	jalr	996(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    800011b6:	00007517          	auipc	a0,0x7
    800011ba:	ef250513          	addi	a0,a0,-270 # 800080a8 <digits+0x68>
    800011be:	fffff097          	auipc	ra,0xfffff
    800011c2:	3d4080e7          	jalr	980(ra) # 80000592 <printf>
    printf("\n");
    800011c6:	00007517          	auipc	a0,0x7
    800011ca:	f0a50513          	addi	a0,a0,-246 # 800080d0 <digits+0x90>
    800011ce:	fffff097          	auipc	ra,0xfffff
    800011d2:	3c4080e7          	jalr	964(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    800011d6:	00000097          	auipc	ra,0x0
    800011da:	95e080e7          	jalr	-1698(ra) # 80000b34 <kinit>
    kvminit();       // create kernel page table
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	2a0080e7          	jalr	672(ra) # 8000147e <kvminit>
    kvminithart();   // turn on paging
    800011e6:	00000097          	auipc	ra,0x0
    800011ea:	068080e7          	jalr	104(ra) # 8000124e <kvminithart>
    procinit();      // process table
    800011ee:	00001097          	auipc	ra,0x1
    800011f2:	980080e7          	jalr	-1664(ra) # 80001b6e <procinit>
    trapinit();      // trap vectors
    800011f6:	00001097          	auipc	ra,0x1
    800011fa:	6aa080e7          	jalr	1706(ra) # 800028a0 <trapinit>
    trapinithart();  // install kernel trap vector
    800011fe:	00001097          	auipc	ra,0x1
    80001202:	6ca080e7          	jalr	1738(ra) # 800028c8 <trapinithart>
    plicinit();      // set up interrupt controller
    80001206:	00005097          	auipc	ra,0x5
    8000120a:	c74080e7          	jalr	-908(ra) # 80005e7a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000120e:	00005097          	auipc	ra,0x5
    80001212:	c82080e7          	jalr	-894(ra) # 80005e90 <plicinithart>
    binit();         // buffer cache
    80001216:	00002097          	auipc	ra,0x2
    8000121a:	e24080e7          	jalr	-476(ra) # 8000303a <binit>
    iinit();         // inode cache
    8000121e:	00002097          	auipc	ra,0x2
    80001222:	4b4080e7          	jalr	1204(ra) # 800036d2 <iinit>
    fileinit();      // file table
    80001226:	00003097          	auipc	ra,0x3
    8000122a:	452080e7          	jalr	1106(ra) # 80004678 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000122e:	00005097          	auipc	ra,0x5
    80001232:	d6a080e7          	jalr	-662(ra) # 80005f98 <virtio_disk_init>
    userinit();      // first user process
    80001236:	00001097          	auipc	ra,0x1
    8000123a:	cfe080e7          	jalr	-770(ra) # 80001f34 <userinit>
    __sync_synchronize();
    8000123e:	0ff0000f          	fence
    started = 1;
    80001242:	4785                	li	a5,1
    80001244:	00008717          	auipc	a4,0x8
    80001248:	dcf72423          	sw	a5,-568(a4) # 8000900c <started>
    8000124c:	b789                	j	8000118e <main+0x56>

000000008000124e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000124e:	1141                	addi	sp,sp,-16
    80001250:	e422                	sd	s0,8(sp)
    80001252:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001254:	00008797          	auipc	a5,0x8
    80001258:	dbc7b783          	ld	a5,-580(a5) # 80009010 <kernel_pagetable>
    8000125c:	83b1                	srli	a5,a5,0xc
    8000125e:	577d                	li	a4,-1
    80001260:	177e                	slli	a4,a4,0x3f
    80001262:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001264:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001268:	12000073          	sfence.vma
  sfence_vma();
}
    8000126c:	6422                	ld	s0,8(sp)
    8000126e:	0141                	addi	sp,sp,16
    80001270:	8082                	ret

0000000080001272 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001272:	7139                	addi	sp,sp,-64
    80001274:	fc06                	sd	ra,56(sp)
    80001276:	f822                	sd	s0,48(sp)
    80001278:	f426                	sd	s1,40(sp)
    8000127a:	f04a                	sd	s2,32(sp)
    8000127c:	ec4e                	sd	s3,24(sp)
    8000127e:	e852                	sd	s4,16(sp)
    80001280:	e456                	sd	s5,8(sp)
    80001282:	e05a                	sd	s6,0(sp)
    80001284:	0080                	addi	s0,sp,64
    80001286:	84aa                	mv	s1,a0
    80001288:	89ae                	mv	s3,a1
    8000128a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000128c:	57fd                	li	a5,-1
    8000128e:	83e9                	srli	a5,a5,0x1a
    80001290:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001292:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001294:	04b7f263          	bgeu	a5,a1,800012d8 <walk+0x66>
    panic("walk");
    80001298:	00007517          	auipc	a0,0x7
    8000129c:	e4050513          	addi	a0,a0,-448 # 800080d8 <digits+0x98>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	2a8080e7          	jalr	680(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800012a8:	060a8663          	beqz	s5,80001314 <walk+0xa2>
    800012ac:	00000097          	auipc	ra,0x0
    800012b0:	8fc080e7          	jalr	-1796(ra) # 80000ba8 <kalloc>
    800012b4:	84aa                	mv	s1,a0
    800012b6:	c529                	beqz	a0,80001300 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800012b8:	6605                	lui	a2,0x1
    800012ba:	4581                	li	a1,0
    800012bc:	00000097          	auipc	ra,0x0
    800012c0:	cca080e7          	jalr	-822(ra) # 80000f86 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800012c4:	00c4d793          	srli	a5,s1,0xc
    800012c8:	07aa                	slli	a5,a5,0xa
    800012ca:	0017e793          	ori	a5,a5,1
    800012ce:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800012d2:	3a5d                	addiw	s4,s4,-9
    800012d4:	036a0063          	beq	s4,s6,800012f4 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800012d8:	0149d933          	srl	s2,s3,s4
    800012dc:	1ff97913          	andi	s2,s2,511
    800012e0:	090e                	slli	s2,s2,0x3
    800012e2:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800012e4:	00093483          	ld	s1,0(s2)
    800012e8:	0014f793          	andi	a5,s1,1
    800012ec:	dfd5                	beqz	a5,800012a8 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800012ee:	80a9                	srli	s1,s1,0xa
    800012f0:	04b2                	slli	s1,s1,0xc
    800012f2:	b7c5                	j	800012d2 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800012f4:	00c9d513          	srli	a0,s3,0xc
    800012f8:	1ff57513          	andi	a0,a0,511
    800012fc:	050e                	slli	a0,a0,0x3
    800012fe:	9526                	add	a0,a0,s1
}
    80001300:	70e2                	ld	ra,56(sp)
    80001302:	7442                	ld	s0,48(sp)
    80001304:	74a2                	ld	s1,40(sp)
    80001306:	7902                	ld	s2,32(sp)
    80001308:	69e2                	ld	s3,24(sp)
    8000130a:	6a42                	ld	s4,16(sp)
    8000130c:	6aa2                	ld	s5,8(sp)
    8000130e:	6b02                	ld	s6,0(sp)
    80001310:	6121                	addi	sp,sp,64
    80001312:	8082                	ret
        return 0;
    80001314:	4501                	li	a0,0
    80001316:	b7ed                	j	80001300 <walk+0x8e>

0000000080001318 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001318:	57fd                	li	a5,-1
    8000131a:	83e9                	srli	a5,a5,0x1a
    8000131c:	00b7f463          	bgeu	a5,a1,80001324 <walkaddr+0xc>
    return 0;
    80001320:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001322:	8082                	ret
{
    80001324:	1141                	addi	sp,sp,-16
    80001326:	e406                	sd	ra,8(sp)
    80001328:	e022                	sd	s0,0(sp)
    8000132a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000132c:	4601                	li	a2,0
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	f44080e7          	jalr	-188(ra) # 80001272 <walk>
  if(pte == 0)
    80001336:	c105                	beqz	a0,80001356 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001338:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000133a:	0117f693          	andi	a3,a5,17
    8000133e:	4745                	li	a4,17
    return 0;
    80001340:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001342:	00e68663          	beq	a3,a4,8000134e <walkaddr+0x36>
}
    80001346:	60a2                	ld	ra,8(sp)
    80001348:	6402                	ld	s0,0(sp)
    8000134a:	0141                	addi	sp,sp,16
    8000134c:	8082                	ret
  pa = PTE2PA(*pte);
    8000134e:	00a7d513          	srli	a0,a5,0xa
    80001352:	0532                	slli	a0,a0,0xc
  return pa;
    80001354:	bfcd                	j	80001346 <walkaddr+0x2e>
    return 0;
    80001356:	4501                	li	a0,0
    80001358:	b7fd                	j	80001346 <walkaddr+0x2e>

000000008000135a <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    8000135a:	1101                	addi	sp,sp,-32
    8000135c:	ec06                	sd	ra,24(sp)
    8000135e:	e822                	sd	s0,16(sp)
    80001360:	e426                	sd	s1,8(sp)
    80001362:	1000                	addi	s0,sp,32
    80001364:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001366:	1552                	slli	a0,a0,0x34
    80001368:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    8000136c:	4601                	li	a2,0
    8000136e:	00008517          	auipc	a0,0x8
    80001372:	ca253503          	ld	a0,-862(a0) # 80009010 <kernel_pagetable>
    80001376:	00000097          	auipc	ra,0x0
    8000137a:	efc080e7          	jalr	-260(ra) # 80001272 <walk>
  if(pte == 0)
    8000137e:	cd09                	beqz	a0,80001398 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001380:	6108                	ld	a0,0(a0)
    80001382:	00157793          	andi	a5,a0,1
    80001386:	c38d                	beqz	a5,800013a8 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001388:	8129                	srli	a0,a0,0xa
    8000138a:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000138c:	9526                	add	a0,a0,s1
    8000138e:	60e2                	ld	ra,24(sp)
    80001390:	6442                	ld	s0,16(sp)
    80001392:	64a2                	ld	s1,8(sp)
    80001394:	6105                	addi	sp,sp,32
    80001396:	8082                	ret
    panic("kvmpa");
    80001398:	00007517          	auipc	a0,0x7
    8000139c:	d4850513          	addi	a0,a0,-696 # 800080e0 <digits+0xa0>
    800013a0:	fffff097          	auipc	ra,0xfffff
    800013a4:	1a8080e7          	jalr	424(ra) # 80000548 <panic>
    panic("kvmpa");
    800013a8:	00007517          	auipc	a0,0x7
    800013ac:	d3850513          	addi	a0,a0,-712 # 800080e0 <digits+0xa0>
    800013b0:	fffff097          	auipc	ra,0xfffff
    800013b4:	198080e7          	jalr	408(ra) # 80000548 <panic>

00000000800013b8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800013b8:	715d                	addi	sp,sp,-80
    800013ba:	e486                	sd	ra,72(sp)
    800013bc:	e0a2                	sd	s0,64(sp)
    800013be:	fc26                	sd	s1,56(sp)
    800013c0:	f84a                	sd	s2,48(sp)
    800013c2:	f44e                	sd	s3,40(sp)
    800013c4:	f052                	sd	s4,32(sp)
    800013c6:	ec56                	sd	s5,24(sp)
    800013c8:	e85a                	sd	s6,16(sp)
    800013ca:	e45e                	sd	s7,8(sp)
    800013cc:	0880                	addi	s0,sp,80
    800013ce:	8aaa                	mv	s5,a0
    800013d0:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800013d2:	777d                	lui	a4,0xfffff
    800013d4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800013d8:	167d                	addi	a2,a2,-1
    800013da:	00b609b3          	add	s3,a2,a1
    800013de:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800013e2:	893e                	mv	s2,a5
    800013e4:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800013e8:	6b85                	lui	s7,0x1
    800013ea:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800013ee:	4605                	li	a2,1
    800013f0:	85ca                	mv	a1,s2
    800013f2:	8556                	mv	a0,s5
    800013f4:	00000097          	auipc	ra,0x0
    800013f8:	e7e080e7          	jalr	-386(ra) # 80001272 <walk>
    800013fc:	c51d                	beqz	a0,8000142a <mappages+0x72>
    if(*pte & PTE_V)
    800013fe:	611c                	ld	a5,0(a0)
    80001400:	8b85                	andi	a5,a5,1
    80001402:	ef81                	bnez	a5,8000141a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001404:	80b1                	srli	s1,s1,0xc
    80001406:	04aa                	slli	s1,s1,0xa
    80001408:	0164e4b3          	or	s1,s1,s6
    8000140c:	0014e493          	ori	s1,s1,1
    80001410:	e104                	sd	s1,0(a0)
    if(a == last)
    80001412:	03390863          	beq	s2,s3,80001442 <mappages+0x8a>
    a += PGSIZE;
    80001416:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001418:	bfc9                	j	800013ea <mappages+0x32>
      panic("remap");
    8000141a:	00007517          	auipc	a0,0x7
    8000141e:	cce50513          	addi	a0,a0,-818 # 800080e8 <digits+0xa8>
    80001422:	fffff097          	auipc	ra,0xfffff
    80001426:	126080e7          	jalr	294(ra) # 80000548 <panic>
      return -1;
    8000142a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000142c:	60a6                	ld	ra,72(sp)
    8000142e:	6406                	ld	s0,64(sp)
    80001430:	74e2                	ld	s1,56(sp)
    80001432:	7942                	ld	s2,48(sp)
    80001434:	79a2                	ld	s3,40(sp)
    80001436:	7a02                	ld	s4,32(sp)
    80001438:	6ae2                	ld	s5,24(sp)
    8000143a:	6b42                	ld	s6,16(sp)
    8000143c:	6ba2                	ld	s7,8(sp)
    8000143e:	6161                	addi	sp,sp,80
    80001440:	8082                	ret
  return 0;
    80001442:	4501                	li	a0,0
    80001444:	b7e5                	j	8000142c <mappages+0x74>

0000000080001446 <kvmmap>:
{
    80001446:	1141                	addi	sp,sp,-16
    80001448:	e406                	sd	ra,8(sp)
    8000144a:	e022                	sd	s0,0(sp)
    8000144c:	0800                	addi	s0,sp,16
    8000144e:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001450:	86ae                	mv	a3,a1
    80001452:	85aa                	mv	a1,a0
    80001454:	00008517          	auipc	a0,0x8
    80001458:	bbc53503          	ld	a0,-1092(a0) # 80009010 <kernel_pagetable>
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	f5c080e7          	jalr	-164(ra) # 800013b8 <mappages>
    80001464:	e509                	bnez	a0,8000146e <kvmmap+0x28>
}
    80001466:	60a2                	ld	ra,8(sp)
    80001468:	6402                	ld	s0,0(sp)
    8000146a:	0141                	addi	sp,sp,16
    8000146c:	8082                	ret
    panic("kvmmap");
    8000146e:	00007517          	auipc	a0,0x7
    80001472:	c8250513          	addi	a0,a0,-894 # 800080f0 <digits+0xb0>
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	0d2080e7          	jalr	210(ra) # 80000548 <panic>

000000008000147e <kvminit>:
{
    8000147e:	1101                	addi	sp,sp,-32
    80001480:	ec06                	sd	ra,24(sp)
    80001482:	e822                	sd	s0,16(sp)
    80001484:	e426                	sd	s1,8(sp)
    80001486:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001488:	fffff097          	auipc	ra,0xfffff
    8000148c:	720080e7          	jalr	1824(ra) # 80000ba8 <kalloc>
    80001490:	00008797          	auipc	a5,0x8
    80001494:	b8a7b023          	sd	a0,-1152(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001498:	6605                	lui	a2,0x1
    8000149a:	4581                	li	a1,0
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	aea080e7          	jalr	-1302(ra) # 80000f86 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800014a4:	4699                	li	a3,6
    800014a6:	6605                	lui	a2,0x1
    800014a8:	100005b7          	lui	a1,0x10000
    800014ac:	10000537          	lui	a0,0x10000
    800014b0:	00000097          	auipc	ra,0x0
    800014b4:	f96080e7          	jalr	-106(ra) # 80001446 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800014b8:	4699                	li	a3,6
    800014ba:	6605                	lui	a2,0x1
    800014bc:	100015b7          	lui	a1,0x10001
    800014c0:	10001537          	lui	a0,0x10001
    800014c4:	00000097          	auipc	ra,0x0
    800014c8:	f82080e7          	jalr	-126(ra) # 80001446 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800014cc:	4699                	li	a3,6
    800014ce:	6641                	lui	a2,0x10
    800014d0:	020005b7          	lui	a1,0x2000
    800014d4:	02000537          	lui	a0,0x2000
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	f6e080e7          	jalr	-146(ra) # 80001446 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800014e0:	4699                	li	a3,6
    800014e2:	00400637          	lui	a2,0x400
    800014e6:	0c0005b7          	lui	a1,0xc000
    800014ea:	0c000537          	lui	a0,0xc000
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	f58080e7          	jalr	-168(ra) # 80001446 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800014f6:	00007497          	auipc	s1,0x7
    800014fa:	b0a48493          	addi	s1,s1,-1270 # 80008000 <etext>
    800014fe:	46a9                	li	a3,10
    80001500:	80007617          	auipc	a2,0x80007
    80001504:	b0060613          	addi	a2,a2,-1280 # 8000 <_entry-0x7fff8000>
    80001508:	4585                	li	a1,1
    8000150a:	05fe                	slli	a1,a1,0x1f
    8000150c:	852e                	mv	a0,a1
    8000150e:	00000097          	auipc	ra,0x0
    80001512:	f38080e7          	jalr	-200(ra) # 80001446 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001516:	4699                	li	a3,6
    80001518:	4645                	li	a2,17
    8000151a:	066e                	slli	a2,a2,0x1b
    8000151c:	8e05                	sub	a2,a2,s1
    8000151e:	85a6                	mv	a1,s1
    80001520:	8526                	mv	a0,s1
    80001522:	00000097          	auipc	ra,0x0
    80001526:	f24080e7          	jalr	-220(ra) # 80001446 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000152a:	46a9                	li	a3,10
    8000152c:	6605                	lui	a2,0x1
    8000152e:	00006597          	auipc	a1,0x6
    80001532:	ad258593          	addi	a1,a1,-1326 # 80007000 <_trampoline>
    80001536:	04000537          	lui	a0,0x4000
    8000153a:	157d                	addi	a0,a0,-1
    8000153c:	0532                	slli	a0,a0,0xc
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f08080e7          	jalr	-248(ra) # 80001446 <kvmmap>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret

0000000080001550 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001550:	715d                	addi	sp,sp,-80
    80001552:	e486                	sd	ra,72(sp)
    80001554:	e0a2                	sd	s0,64(sp)
    80001556:	fc26                	sd	s1,56(sp)
    80001558:	f84a                	sd	s2,48(sp)
    8000155a:	f44e                	sd	s3,40(sp)
    8000155c:	f052                	sd	s4,32(sp)
    8000155e:	ec56                	sd	s5,24(sp)
    80001560:	e85a                	sd	s6,16(sp)
    80001562:	e45e                	sd	s7,8(sp)
    80001564:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001566:	03459793          	slli	a5,a1,0x34
    8000156a:	e795                	bnez	a5,80001596 <uvmunmap+0x46>
    8000156c:	8a2a                	mv	s4,a0
    8000156e:	892e                	mv	s2,a1
    80001570:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001572:	0632                	slli	a2,a2,0xc
    80001574:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001578:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000157a:	6b05                	lui	s6,0x1
    8000157c:	0735e863          	bltu	a1,s3,800015ec <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001580:	60a6                	ld	ra,72(sp)
    80001582:	6406                	ld	s0,64(sp)
    80001584:	74e2                	ld	s1,56(sp)
    80001586:	7942                	ld	s2,48(sp)
    80001588:	79a2                	ld	s3,40(sp)
    8000158a:	7a02                	ld	s4,32(sp)
    8000158c:	6ae2                	ld	s5,24(sp)
    8000158e:	6b42                	ld	s6,16(sp)
    80001590:	6ba2                	ld	s7,8(sp)
    80001592:	6161                	addi	sp,sp,80
    80001594:	8082                	ret
    panic("uvmunmap: not aligned");
    80001596:	00007517          	auipc	a0,0x7
    8000159a:	b6250513          	addi	a0,a0,-1182 # 800080f8 <digits+0xb8>
    8000159e:	fffff097          	auipc	ra,0xfffff
    800015a2:	faa080e7          	jalr	-86(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    800015a6:	00007517          	auipc	a0,0x7
    800015aa:	b6a50513          	addi	a0,a0,-1174 # 80008110 <digits+0xd0>
    800015ae:	fffff097          	auipc	ra,0xfffff
    800015b2:	f9a080e7          	jalr	-102(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    800015b6:	00007517          	auipc	a0,0x7
    800015ba:	b6a50513          	addi	a0,a0,-1174 # 80008120 <digits+0xe0>
    800015be:	fffff097          	auipc	ra,0xfffff
    800015c2:	f8a080e7          	jalr	-118(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800015c6:	00007517          	auipc	a0,0x7
    800015ca:	b7250513          	addi	a0,a0,-1166 # 80008138 <digits+0xf8>
    800015ce:	fffff097          	auipc	ra,0xfffff
    800015d2:	f7a080e7          	jalr	-134(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    800015d6:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800015d8:	0532                	slli	a0,a0,0xc
    800015da:	fffff097          	auipc	ra,0xfffff
    800015de:	44a080e7          	jalr	1098(ra) # 80000a24 <kfree>
    *pte = 0;
    800015e2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015e6:	995a                	add	s2,s2,s6
    800015e8:	f9397ce3          	bgeu	s2,s3,80001580 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800015ec:	4601                	li	a2,0
    800015ee:	85ca                	mv	a1,s2
    800015f0:	8552                	mv	a0,s4
    800015f2:	00000097          	auipc	ra,0x0
    800015f6:	c80080e7          	jalr	-896(ra) # 80001272 <walk>
    800015fa:	84aa                	mv	s1,a0
    800015fc:	d54d                	beqz	a0,800015a6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800015fe:	6108                	ld	a0,0(a0)
    80001600:	00157793          	andi	a5,a0,1
    80001604:	dbcd                	beqz	a5,800015b6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001606:	3ff57793          	andi	a5,a0,1023
    8000160a:	fb778ee3          	beq	a5,s7,800015c6 <uvmunmap+0x76>
    if(do_free){
    8000160e:	fc0a8ae3          	beqz	s5,800015e2 <uvmunmap+0x92>
    80001612:	b7d1                	j	800015d6 <uvmunmap+0x86>

0000000080001614 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001614:	1101                	addi	sp,sp,-32
    80001616:	ec06                	sd	ra,24(sp)
    80001618:	e822                	sd	s0,16(sp)
    8000161a:	e426                	sd	s1,8(sp)
    8000161c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000161e:	fffff097          	auipc	ra,0xfffff
    80001622:	58a080e7          	jalr	1418(ra) # 80000ba8 <kalloc>
    80001626:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001628:	c519                	beqz	a0,80001636 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000162a:	6605                	lui	a2,0x1
    8000162c:	4581                	li	a1,0
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	958080e7          	jalr	-1704(ra) # 80000f86 <memset>
  return pagetable;
}
    80001636:	8526                	mv	a0,s1
    80001638:	60e2                	ld	ra,24(sp)
    8000163a:	6442                	ld	s0,16(sp)
    8000163c:	64a2                	ld	s1,8(sp)
    8000163e:	6105                	addi	sp,sp,32
    80001640:	8082                	ret

0000000080001642 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001642:	7179                	addi	sp,sp,-48
    80001644:	f406                	sd	ra,40(sp)
    80001646:	f022                	sd	s0,32(sp)
    80001648:	ec26                	sd	s1,24(sp)
    8000164a:	e84a                	sd	s2,16(sp)
    8000164c:	e44e                	sd	s3,8(sp)
    8000164e:	e052                	sd	s4,0(sp)
    80001650:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001652:	6785                	lui	a5,0x1
    80001654:	04f67863          	bgeu	a2,a5,800016a4 <uvminit+0x62>
    80001658:	8a2a                	mv	s4,a0
    8000165a:	89ae                	mv	s3,a1
    8000165c:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	54a080e7          	jalr	1354(ra) # 80000ba8 <kalloc>
    80001666:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001668:	6605                	lui	a2,0x1
    8000166a:	4581                	li	a1,0
    8000166c:	00000097          	auipc	ra,0x0
    80001670:	91a080e7          	jalr	-1766(ra) # 80000f86 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001674:	4779                	li	a4,30
    80001676:	86ca                	mv	a3,s2
    80001678:	6605                	lui	a2,0x1
    8000167a:	4581                	li	a1,0
    8000167c:	8552                	mv	a0,s4
    8000167e:	00000097          	auipc	ra,0x0
    80001682:	d3a080e7          	jalr	-710(ra) # 800013b8 <mappages>
  memmove(mem, src, sz);
    80001686:	8626                	mv	a2,s1
    80001688:	85ce                	mv	a1,s3
    8000168a:	854a                	mv	a0,s2
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	95a080e7          	jalr	-1702(ra) # 80000fe6 <memmove>
}
    80001694:	70a2                	ld	ra,40(sp)
    80001696:	7402                	ld	s0,32(sp)
    80001698:	64e2                	ld	s1,24(sp)
    8000169a:	6942                	ld	s2,16(sp)
    8000169c:	69a2                	ld	s3,8(sp)
    8000169e:	6a02                	ld	s4,0(sp)
    800016a0:	6145                	addi	sp,sp,48
    800016a2:	8082                	ret
    panic("inituvm: more than a page");
    800016a4:	00007517          	auipc	a0,0x7
    800016a8:	aac50513          	addi	a0,a0,-1364 # 80008150 <digits+0x110>
    800016ac:	fffff097          	auipc	ra,0xfffff
    800016b0:	e9c080e7          	jalr	-356(ra) # 80000548 <panic>

00000000800016b4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800016b4:	1101                	addi	sp,sp,-32
    800016b6:	ec06                	sd	ra,24(sp)
    800016b8:	e822                	sd	s0,16(sp)
    800016ba:	e426                	sd	s1,8(sp)
    800016bc:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800016be:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800016c0:	00b67d63          	bgeu	a2,a1,800016da <uvmdealloc+0x26>
    800016c4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800016c6:	6785                	lui	a5,0x1
    800016c8:	17fd                	addi	a5,a5,-1
    800016ca:	00f60733          	add	a4,a2,a5
    800016ce:	767d                	lui	a2,0xfffff
    800016d0:	8f71                	and	a4,a4,a2
    800016d2:	97ae                	add	a5,a5,a1
    800016d4:	8ff1                	and	a5,a5,a2
    800016d6:	00f76863          	bltu	a4,a5,800016e6 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800016da:	8526                	mv	a0,s1
    800016dc:	60e2                	ld	ra,24(sp)
    800016de:	6442                	ld	s0,16(sp)
    800016e0:	64a2                	ld	s1,8(sp)
    800016e2:	6105                	addi	sp,sp,32
    800016e4:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800016e6:	8f99                	sub	a5,a5,a4
    800016e8:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800016ea:	4685                	li	a3,1
    800016ec:	0007861b          	sext.w	a2,a5
    800016f0:	85ba                	mv	a1,a4
    800016f2:	00000097          	auipc	ra,0x0
    800016f6:	e5e080e7          	jalr	-418(ra) # 80001550 <uvmunmap>
    800016fa:	b7c5                	j	800016da <uvmdealloc+0x26>

00000000800016fc <uvmalloc>:
  if(newsz < oldsz)
    800016fc:	0ab66163          	bltu	a2,a1,8000179e <uvmalloc+0xa2>
{
    80001700:	7139                	addi	sp,sp,-64
    80001702:	fc06                	sd	ra,56(sp)
    80001704:	f822                	sd	s0,48(sp)
    80001706:	f426                	sd	s1,40(sp)
    80001708:	f04a                	sd	s2,32(sp)
    8000170a:	ec4e                	sd	s3,24(sp)
    8000170c:	e852                	sd	s4,16(sp)
    8000170e:	e456                	sd	s5,8(sp)
    80001710:	0080                	addi	s0,sp,64
    80001712:	8aaa                	mv	s5,a0
    80001714:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001716:	6985                	lui	s3,0x1
    80001718:	19fd                	addi	s3,s3,-1
    8000171a:	95ce                	add	a1,a1,s3
    8000171c:	79fd                	lui	s3,0xfffff
    8000171e:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001722:	08c9f063          	bgeu	s3,a2,800017a2 <uvmalloc+0xa6>
    80001726:	894e                	mv	s2,s3
    mem = kalloc();
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	480080e7          	jalr	1152(ra) # 80000ba8 <kalloc>
    80001730:	84aa                	mv	s1,a0
    if(mem == 0){
    80001732:	c51d                	beqz	a0,80001760 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001734:	6605                	lui	a2,0x1
    80001736:	4581                	li	a1,0
    80001738:	00000097          	auipc	ra,0x0
    8000173c:	84e080e7          	jalr	-1970(ra) # 80000f86 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001740:	4779                	li	a4,30
    80001742:	86a6                	mv	a3,s1
    80001744:	6605                	lui	a2,0x1
    80001746:	85ca                	mv	a1,s2
    80001748:	8556                	mv	a0,s5
    8000174a:	00000097          	auipc	ra,0x0
    8000174e:	c6e080e7          	jalr	-914(ra) # 800013b8 <mappages>
    80001752:	e905                	bnez	a0,80001782 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001754:	6785                	lui	a5,0x1
    80001756:	993e                	add	s2,s2,a5
    80001758:	fd4968e3          	bltu	s2,s4,80001728 <uvmalloc+0x2c>
  return newsz;
    8000175c:	8552                	mv	a0,s4
    8000175e:	a809                	j	80001770 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001760:	864e                	mv	a2,s3
    80001762:	85ca                	mv	a1,s2
    80001764:	8556                	mv	a0,s5
    80001766:	00000097          	auipc	ra,0x0
    8000176a:	f4e080e7          	jalr	-178(ra) # 800016b4 <uvmdealloc>
      return 0;
    8000176e:	4501                	li	a0,0
}
    80001770:	70e2                	ld	ra,56(sp)
    80001772:	7442                	ld	s0,48(sp)
    80001774:	74a2                	ld	s1,40(sp)
    80001776:	7902                	ld	s2,32(sp)
    80001778:	69e2                	ld	s3,24(sp)
    8000177a:	6a42                	ld	s4,16(sp)
    8000177c:	6aa2                	ld	s5,8(sp)
    8000177e:	6121                	addi	sp,sp,64
    80001780:	8082                	ret
      kfree(mem);
    80001782:	8526                	mv	a0,s1
    80001784:	fffff097          	auipc	ra,0xfffff
    80001788:	2a0080e7          	jalr	672(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000178c:	864e                	mv	a2,s3
    8000178e:	85ca                	mv	a1,s2
    80001790:	8556                	mv	a0,s5
    80001792:	00000097          	auipc	ra,0x0
    80001796:	f22080e7          	jalr	-222(ra) # 800016b4 <uvmdealloc>
      return 0;
    8000179a:	4501                	li	a0,0
    8000179c:	bfd1                	j	80001770 <uvmalloc+0x74>
    return oldsz;
    8000179e:	852e                	mv	a0,a1
}
    800017a0:	8082                	ret
  return newsz;
    800017a2:	8532                	mv	a0,a2
    800017a4:	b7f1                	j	80001770 <uvmalloc+0x74>

00000000800017a6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800017a6:	7179                	addi	sp,sp,-48
    800017a8:	f406                	sd	ra,40(sp)
    800017aa:	f022                	sd	s0,32(sp)
    800017ac:	ec26                	sd	s1,24(sp)
    800017ae:	e84a                	sd	s2,16(sp)
    800017b0:	e44e                	sd	s3,8(sp)
    800017b2:	e052                	sd	s4,0(sp)
    800017b4:	1800                	addi	s0,sp,48
    800017b6:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800017b8:	84aa                	mv	s1,a0
    800017ba:	6905                	lui	s2,0x1
    800017bc:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800017be:	4985                	li	s3,1
    800017c0:	a821                	j	800017d8 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800017c2:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800017c4:	0532                	slli	a0,a0,0xc
    800017c6:	00000097          	auipc	ra,0x0
    800017ca:	fe0080e7          	jalr	-32(ra) # 800017a6 <freewalk>
      pagetable[i] = 0;
    800017ce:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800017d2:	04a1                	addi	s1,s1,8
    800017d4:	03248163          	beq	s1,s2,800017f6 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800017d8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800017da:	00f57793          	andi	a5,a0,15
    800017de:	ff3782e3          	beq	a5,s3,800017c2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800017e2:	8905                	andi	a0,a0,1
    800017e4:	d57d                	beqz	a0,800017d2 <freewalk+0x2c>
      panic("freewalk: leaf");
    800017e6:	00007517          	auipc	a0,0x7
    800017ea:	98a50513          	addi	a0,a0,-1654 # 80008170 <digits+0x130>
    800017ee:	fffff097          	auipc	ra,0xfffff
    800017f2:	d5a080e7          	jalr	-678(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    800017f6:	8552                	mv	a0,s4
    800017f8:	fffff097          	auipc	ra,0xfffff
    800017fc:	22c080e7          	jalr	556(ra) # 80000a24 <kfree>
}
    80001800:	70a2                	ld	ra,40(sp)
    80001802:	7402                	ld	s0,32(sp)
    80001804:	64e2                	ld	s1,24(sp)
    80001806:	6942                	ld	s2,16(sp)
    80001808:	69a2                	ld	s3,8(sp)
    8000180a:	6a02                	ld	s4,0(sp)
    8000180c:	6145                	addi	sp,sp,48
    8000180e:	8082                	ret

0000000080001810 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001810:	1101                	addi	sp,sp,-32
    80001812:	ec06                	sd	ra,24(sp)
    80001814:	e822                	sd	s0,16(sp)
    80001816:	e426                	sd	s1,8(sp)
    80001818:	1000                	addi	s0,sp,32
    8000181a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000181c:	e999                	bnez	a1,80001832 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000181e:	8526                	mv	a0,s1
    80001820:	00000097          	auipc	ra,0x0
    80001824:	f86080e7          	jalr	-122(ra) # 800017a6 <freewalk>
}
    80001828:	60e2                	ld	ra,24(sp)
    8000182a:	6442                	ld	s0,16(sp)
    8000182c:	64a2                	ld	s1,8(sp)
    8000182e:	6105                	addi	sp,sp,32
    80001830:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001832:	6605                	lui	a2,0x1
    80001834:	167d                	addi	a2,a2,-1
    80001836:	962e                	add	a2,a2,a1
    80001838:	4685                	li	a3,1
    8000183a:	8231                	srli	a2,a2,0xc
    8000183c:	4581                	li	a1,0
    8000183e:	00000097          	auipc	ra,0x0
    80001842:	d12080e7          	jalr	-750(ra) # 80001550 <uvmunmap>
    80001846:	bfe1                	j	8000181e <uvmfree+0xe>

0000000080001848 <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    80001848:	7139                	addi	sp,sp,-64
    8000184a:	fc06                	sd	ra,56(sp)
    8000184c:	f822                	sd	s0,48(sp)
    8000184e:	f426                	sd	s1,40(sp)
    80001850:	f04a                	sd	s2,32(sp)
    80001852:	ec4e                	sd	s3,24(sp)
    80001854:	e852                	sd	s4,16(sp)
    80001856:	e456                	sd	s5,8(sp)
    80001858:	e05a                	sd	s6,0(sp)
    8000185a:	0080                	addi	s0,sp,64
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000185c:	c25d                	beqz	a2,80001902 <uvmcopy+0xba>
    8000185e:	8aaa                	mv	s5,a0
    80001860:	8a2e                	mv	s4,a1
    80001862:	89b2                	mv	s3,a2
    80001864:	4481                	li	s1,0
    if((pte = walk(old, i, 0)) == 0)
    80001866:	4601                	li	a2,0
    80001868:	85a6                	mv	a1,s1
    8000186a:	8556                	mv	a0,s5
    8000186c:	00000097          	auipc	ra,0x0
    80001870:	a06080e7          	jalr	-1530(ra) # 80001272 <walk>
    80001874:	c131                	beqz	a0,800018b8 <uvmcopy+0x70>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001876:	6118                	ld	a4,0(a0)
    80001878:	00177793          	andi	a5,a4,1
    8000187c:	c7b1                	beqz	a5,800018c8 <uvmcopy+0x80>
    // if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    //   kfree(mem);
    //   goto err;
    // }

    pa = PTE2PA(*pte);
    8000187e:	00a75913          	srli	s2,a4,0xa
    80001882:	0932                	slli	s2,s2,0xc
    /** 标记子进程和父进程不可写，这也会导致父进程失去对该PTE写入的权限 */
    *pte &= (~PTE_W);
    80001884:	9b6d                	andi	a4,a4,-5
    *pte |= PTE_COW;
    80001886:	10076713          	ori	a4,a4,256
    8000188a:	e118                	sd	a4,0(a0)

    flags = PTE_FLAGS(*pte);
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0)
    8000188c:	3fb77713          	andi	a4,a4,1019
    80001890:	86ca                	mv	a3,s2
    80001892:	6605                	lui	a2,0x1
    80001894:	85a6                	mv	a1,s1
    80001896:	8552                	mv	a0,s4
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	b20080e7          	jalr	-1248(ra) # 800013b8 <mappages>
    800018a0:	8b2a                	mv	s6,a0
    800018a2:	e91d                	bnez	a0,800018d8 <uvmcopy+0x90>
      goto err;
    
    /** 告诉引用计数向量，在第(uint64)pa/PGSIZE页块处，有进程正在引用 */
    incr_ref((char*)pa);
    800018a4:	854a                	mv	a0,s2
    800018a6:	fffff097          	auipc	ra,0xfffff
    800018aa:	3a0080e7          	jalr	928(ra) # 80000c46 <incr_ref>
  for(i = 0; i < sz; i += PGSIZE){
    800018ae:	6785                	lui	a5,0x1
    800018b0:	94be                	add	s1,s1,a5
    800018b2:	fb34eae3          	bltu	s1,s3,80001866 <uvmcopy+0x1e>
    800018b6:	a81d                	j	800018ec <uvmcopy+0xa4>
      panic("uvmcopy: pte should exist");
    800018b8:	00007517          	auipc	a0,0x7
    800018bc:	8c850513          	addi	a0,a0,-1848 # 80008180 <digits+0x140>
    800018c0:	fffff097          	auipc	ra,0xfffff
    800018c4:	c88080e7          	jalr	-888(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800018c8:	00007517          	auipc	a0,0x7
    800018cc:	8d850513          	addi	a0,a0,-1832 # 800081a0 <digits+0x160>
    800018d0:	fffff097          	auipc	ra,0xfffff
    800018d4:	c78080e7          	jalr	-904(ra) # 80000548 <panic>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800018d8:	4685                	li	a3,1
    800018da:	00c4d613          	srli	a2,s1,0xc
    800018de:	4581                	li	a1,0
    800018e0:	8552                	mv	a0,s4
    800018e2:	00000097          	auipc	ra,0x0
    800018e6:	c6e080e7          	jalr	-914(ra) # 80001550 <uvmunmap>
  return -1;
    800018ea:	5b7d                	li	s6,-1
}
    800018ec:	855a                	mv	a0,s6
    800018ee:	70e2                	ld	ra,56(sp)
    800018f0:	7442                	ld	s0,48(sp)
    800018f2:	74a2                	ld	s1,40(sp)
    800018f4:	7902                	ld	s2,32(sp)
    800018f6:	69e2                	ld	s3,24(sp)
    800018f8:	6a42                	ld	s4,16(sp)
    800018fa:	6aa2                	ld	s5,8(sp)
    800018fc:	6b02                	ld	s6,0(sp)
    800018fe:	6121                	addi	sp,sp,64
    80001900:	8082                	ret
  return 0;
    80001902:	4b01                	li	s6,0
    80001904:	b7e5                	j	800018ec <uvmcopy+0xa4>

0000000080001906 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001906:	1141                	addi	sp,sp,-16
    80001908:	e406                	sd	ra,8(sp)
    8000190a:	e022                	sd	s0,0(sp)
    8000190c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000190e:	4601                	li	a2,0
    80001910:	00000097          	auipc	ra,0x0
    80001914:	962080e7          	jalr	-1694(ra) # 80001272 <walk>
  if(pte == 0)
    80001918:	c901                	beqz	a0,80001928 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000191a:	611c                	ld	a5,0(a0)
    8000191c:	9bbd                	andi	a5,a5,-17
    8000191e:	e11c                	sd	a5,0(a0)
}
    80001920:	60a2                	ld	ra,8(sp)
    80001922:	6402                	ld	s0,0(sp)
    80001924:	0141                	addi	sp,sp,16
    80001926:	8082                	ret
    panic("uvmclear");
    80001928:	00007517          	auipc	a0,0x7
    8000192c:	89850513          	addi	a0,a0,-1896 # 800081c0 <digits+0x180>
    80001930:	fffff097          	auipc	ra,0xfffff
    80001934:	c18080e7          	jalr	-1000(ra) # 80000548 <panic>

0000000080001938 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001938:	cac9                	beqz	a3,800019ca <copyout+0x92>
{
    8000193a:	711d                	addi	sp,sp,-96
    8000193c:	ec86                	sd	ra,88(sp)
    8000193e:	e8a2                	sd	s0,80(sp)
    80001940:	e4a6                	sd	s1,72(sp)
    80001942:	e0ca                	sd	s2,64(sp)
    80001944:	fc4e                	sd	s3,56(sp)
    80001946:	f852                	sd	s4,48(sp)
    80001948:	f456                	sd	s5,40(sp)
    8000194a:	f05a                	sd	s6,32(sp)
    8000194c:	ec5e                	sd	s7,24(sp)
    8000194e:	e862                	sd	s8,16(sp)
    80001950:	e466                	sd	s9,8(sp)
    80001952:	1080                	addi	s0,sp,96
    80001954:	8baa                	mv	s7,a0
    80001956:	89ae                	mv	s3,a1
    80001958:	8b32                	mv	s6,a2
    8000195a:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000195c:	7cfd                	lui	s9,0xfffff
    if(iscow(pagetable, va0))
      pa0 = cowcopy(pagetable, va0);

    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000195e:	6c05                	lui	s8,0x1
    80001960:	a815                	j	80001994 <copyout+0x5c>
      pa0 = cowcopy(pagetable, va0);
    80001962:	85ca                	mv	a1,s2
    80001964:	855e                	mv	a0,s7
    80001966:	fffff097          	auipc	ra,0xfffff
    8000196a:	39a080e7          	jalr	922(ra) # 80000d00 <cowcopy>
    8000196e:	8a2a                	mv	s4,a0
    80001970:	a091                	j	800019b4 <copyout+0x7c>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001972:	41298533          	sub	a0,s3,s2
    80001976:	0004861b          	sext.w	a2,s1
    8000197a:	85da                	mv	a1,s6
    8000197c:	9552                	add	a0,a0,s4
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	668080e7          	jalr	1640(ra) # 80000fe6 <memmove>

    len -= n;
    80001986:	409a8ab3          	sub	s5,s5,s1
    src += n;
    8000198a:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    8000198c:	018909b3          	add	s3,s2,s8
  while(len > 0){
    80001990:	020a8b63          	beqz	s5,800019c6 <copyout+0x8e>
    va0 = PGROUNDDOWN(dstva);
    80001994:	0199f933          	and	s2,s3,s9
    pa0 = walkaddr(pagetable, va0);
    80001998:	85ca                	mv	a1,s2
    8000199a:	855e                	mv	a0,s7
    8000199c:	00000097          	auipc	ra,0x0
    800019a0:	97c080e7          	jalr	-1668(ra) # 80001318 <walkaddr>
    800019a4:	8a2a                	mv	s4,a0
    if(iscow(pagetable, va0))
    800019a6:	85ca                	mv	a1,s2
    800019a8:	855e                	mv	a0,s7
    800019aa:	fffff097          	auipc	ra,0xfffff
    800019ae:	31a080e7          	jalr	794(ra) # 80000cc4 <iscow>
    800019b2:	f945                	bnez	a0,80001962 <copyout+0x2a>
    if(pa0 == 0)
    800019b4:	000a0d63          	beqz	s4,800019ce <copyout+0x96>
    n = PGSIZE - (dstva - va0);
    800019b8:	413904b3          	sub	s1,s2,s3
    800019bc:	94e2                	add	s1,s1,s8
    if(n > len)
    800019be:	fa9afae3          	bgeu	s5,s1,80001972 <copyout+0x3a>
    800019c2:	84d6                	mv	s1,s5
    800019c4:	b77d                	j	80001972 <copyout+0x3a>
  }
  return 0;
    800019c6:	4501                	li	a0,0
    800019c8:	a021                	j	800019d0 <copyout+0x98>
    800019ca:	4501                	li	a0,0
}
    800019cc:	8082                	ret
      return -1;
    800019ce:	557d                	li	a0,-1
}
    800019d0:	60e6                	ld	ra,88(sp)
    800019d2:	6446                	ld	s0,80(sp)
    800019d4:	64a6                	ld	s1,72(sp)
    800019d6:	6906                	ld	s2,64(sp)
    800019d8:	79e2                	ld	s3,56(sp)
    800019da:	7a42                	ld	s4,48(sp)
    800019dc:	7aa2                	ld	s5,40(sp)
    800019de:	7b02                	ld	s6,32(sp)
    800019e0:	6be2                	ld	s7,24(sp)
    800019e2:	6c42                	ld	s8,16(sp)
    800019e4:	6ca2                	ld	s9,8(sp)
    800019e6:	6125                	addi	sp,sp,96
    800019e8:	8082                	ret

00000000800019ea <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800019ea:	c6bd                	beqz	a3,80001a58 <copyin+0x6e>
{
    800019ec:	715d                	addi	sp,sp,-80
    800019ee:	e486                	sd	ra,72(sp)
    800019f0:	e0a2                	sd	s0,64(sp)
    800019f2:	fc26                	sd	s1,56(sp)
    800019f4:	f84a                	sd	s2,48(sp)
    800019f6:	f44e                	sd	s3,40(sp)
    800019f8:	f052                	sd	s4,32(sp)
    800019fa:	ec56                	sd	s5,24(sp)
    800019fc:	e85a                	sd	s6,16(sp)
    800019fe:	e45e                	sd	s7,8(sp)
    80001a00:	e062                	sd	s8,0(sp)
    80001a02:	0880                	addi	s0,sp,80
    80001a04:	8b2a                	mv	s6,a0
    80001a06:	8a2e                	mv	s4,a1
    80001a08:	8c32                	mv	s8,a2
    80001a0a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001a0c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a0e:	6a85                	lui	s5,0x1
    80001a10:	a015                	j	80001a34 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a12:	9562                	add	a0,a0,s8
    80001a14:	0004861b          	sext.w	a2,s1
    80001a18:	412505b3          	sub	a1,a0,s2
    80001a1c:	8552                	mv	a0,s4
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	5c8080e7          	jalr	1480(ra) # 80000fe6 <memmove>

    len -= n;
    80001a26:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001a2a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001a2c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001a30:	02098263          	beqz	s3,80001a54 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001a34:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a38:	85ca                	mv	a1,s2
    80001a3a:	855a                	mv	a0,s6
    80001a3c:	00000097          	auipc	ra,0x0
    80001a40:	8dc080e7          	jalr	-1828(ra) # 80001318 <walkaddr>
    if(pa0 == 0)
    80001a44:	cd01                	beqz	a0,80001a5c <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001a46:	418904b3          	sub	s1,s2,s8
    80001a4a:	94d6                	add	s1,s1,s5
    if(n > len)
    80001a4c:	fc99f3e3          	bgeu	s3,s1,80001a12 <copyin+0x28>
    80001a50:	84ce                	mv	s1,s3
    80001a52:	b7c1                	j	80001a12 <copyin+0x28>
  }
  return 0;
    80001a54:	4501                	li	a0,0
    80001a56:	a021                	j	80001a5e <copyin+0x74>
    80001a58:	4501                	li	a0,0
}
    80001a5a:	8082                	ret
      return -1;
    80001a5c:	557d                	li	a0,-1
}
    80001a5e:	60a6                	ld	ra,72(sp)
    80001a60:	6406                	ld	s0,64(sp)
    80001a62:	74e2                	ld	s1,56(sp)
    80001a64:	7942                	ld	s2,48(sp)
    80001a66:	79a2                	ld	s3,40(sp)
    80001a68:	7a02                	ld	s4,32(sp)
    80001a6a:	6ae2                	ld	s5,24(sp)
    80001a6c:	6b42                	ld	s6,16(sp)
    80001a6e:	6ba2                	ld	s7,8(sp)
    80001a70:	6c02                	ld	s8,0(sp)
    80001a72:	6161                	addi	sp,sp,80
    80001a74:	8082                	ret

0000000080001a76 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001a76:	c6c5                	beqz	a3,80001b1e <copyinstr+0xa8>
{
    80001a78:	715d                	addi	sp,sp,-80
    80001a7a:	e486                	sd	ra,72(sp)
    80001a7c:	e0a2                	sd	s0,64(sp)
    80001a7e:	fc26                	sd	s1,56(sp)
    80001a80:	f84a                	sd	s2,48(sp)
    80001a82:	f44e                	sd	s3,40(sp)
    80001a84:	f052                	sd	s4,32(sp)
    80001a86:	ec56                	sd	s5,24(sp)
    80001a88:	e85a                	sd	s6,16(sp)
    80001a8a:	e45e                	sd	s7,8(sp)
    80001a8c:	0880                	addi	s0,sp,80
    80001a8e:	8a2a                	mv	s4,a0
    80001a90:	8b2e                	mv	s6,a1
    80001a92:	8bb2                	mv	s7,a2
    80001a94:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001a96:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a98:	6985                	lui	s3,0x1
    80001a9a:	a035                	j	80001ac6 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001a9c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001aa0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001aa2:	0017b793          	seqz	a5,a5
    80001aa6:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001aaa:	60a6                	ld	ra,72(sp)
    80001aac:	6406                	ld	s0,64(sp)
    80001aae:	74e2                	ld	s1,56(sp)
    80001ab0:	7942                	ld	s2,48(sp)
    80001ab2:	79a2                	ld	s3,40(sp)
    80001ab4:	7a02                	ld	s4,32(sp)
    80001ab6:	6ae2                	ld	s5,24(sp)
    80001ab8:	6b42                	ld	s6,16(sp)
    80001aba:	6ba2                	ld	s7,8(sp)
    80001abc:	6161                	addi	sp,sp,80
    80001abe:	8082                	ret
    srcva = va0 + PGSIZE;
    80001ac0:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001ac4:	c8a9                	beqz	s1,80001b16 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001ac6:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001aca:	85ca                	mv	a1,s2
    80001acc:	8552                	mv	a0,s4
    80001ace:	00000097          	auipc	ra,0x0
    80001ad2:	84a080e7          	jalr	-1974(ra) # 80001318 <walkaddr>
    if(pa0 == 0)
    80001ad6:	c131                	beqz	a0,80001b1a <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001ad8:	41790833          	sub	a6,s2,s7
    80001adc:	984e                	add	a6,a6,s3
    if(n > max)
    80001ade:	0104f363          	bgeu	s1,a6,80001ae4 <copyinstr+0x6e>
    80001ae2:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001ae4:	955e                	add	a0,a0,s7
    80001ae6:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001aea:	fc080be3          	beqz	a6,80001ac0 <copyinstr+0x4a>
    80001aee:	985a                	add	a6,a6,s6
    80001af0:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001af2:	41650633          	sub	a2,a0,s6
    80001af6:	14fd                	addi	s1,s1,-1
    80001af8:	9b26                	add	s6,s6,s1
    80001afa:	00f60733          	add	a4,a2,a5
    80001afe:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7eed9000>
    80001b02:	df49                	beqz	a4,80001a9c <copyinstr+0x26>
        *dst = *p;
    80001b04:	00e78023          	sb	a4,0(a5)
      --max;
    80001b08:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001b0c:	0785                	addi	a5,a5,1
    while(n > 0){
    80001b0e:	ff0796e3          	bne	a5,a6,80001afa <copyinstr+0x84>
      dst++;
    80001b12:	8b42                	mv	s6,a6
    80001b14:	b775                	j	80001ac0 <copyinstr+0x4a>
    80001b16:	4781                	li	a5,0
    80001b18:	b769                	j	80001aa2 <copyinstr+0x2c>
      return -1;
    80001b1a:	557d                	li	a0,-1
    80001b1c:	b779                	j	80001aaa <copyinstr+0x34>
  int got_null = 0;
    80001b1e:	4781                	li	a5,0
  if(got_null){
    80001b20:	0017b793          	seqz	a5,a5
    80001b24:	40f00533          	neg	a0,a5
}
    80001b28:	8082                	ret

0000000080001b2a <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001b2a:	1101                	addi	sp,sp,-32
    80001b2c:	ec06                	sd	ra,24(sp)
    80001b2e:	e822                	sd	s0,16(sp)
    80001b30:	e426                	sd	s1,8(sp)
    80001b32:	1000                	addi	s0,sp,32
    80001b34:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001b36:	fffff097          	auipc	ra,0xfffff
    80001b3a:	2da080e7          	jalr	730(ra) # 80000e10 <holding>
    80001b3e:	c909                	beqz	a0,80001b50 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001b40:	749c                	ld	a5,40(s1)
    80001b42:	00978f63          	beq	a5,s1,80001b60 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001b46:	60e2                	ld	ra,24(sp)
    80001b48:	6442                	ld	s0,16(sp)
    80001b4a:	64a2                	ld	s1,8(sp)
    80001b4c:	6105                	addi	sp,sp,32
    80001b4e:	8082                	ret
    panic("wakeup1");
    80001b50:	00006517          	auipc	a0,0x6
    80001b54:	68050513          	addi	a0,a0,1664 # 800081d0 <digits+0x190>
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	9f0080e7          	jalr	-1552(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001b60:	4c98                	lw	a4,24(s1)
    80001b62:	4785                	li	a5,1
    80001b64:	fef711e3          	bne	a4,a5,80001b46 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001b68:	4789                	li	a5,2
    80001b6a:	cc9c                	sw	a5,24(s1)
}
    80001b6c:	bfe9                	j	80001b46 <wakeup1+0x1c>

0000000080001b6e <procinit>:
{
    80001b6e:	715d                	addi	sp,sp,-80
    80001b70:	e486                	sd	ra,72(sp)
    80001b72:	e0a2                	sd	s0,64(sp)
    80001b74:	fc26                	sd	s1,56(sp)
    80001b76:	f84a                	sd	s2,48(sp)
    80001b78:	f44e                	sd	s3,40(sp)
    80001b7a:	f052                	sd	s4,32(sp)
    80001b7c:	ec56                	sd	s5,24(sp)
    80001b7e:	e85a                	sd	s6,16(sp)
    80001b80:	e45e                	sd	s7,8(sp)
    80001b82:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001b84:	00006597          	auipc	a1,0x6
    80001b88:	65458593          	addi	a1,a1,1620 # 800081d8 <digits+0x198>
    80001b8c:	01110517          	auipc	a0,0x1110
    80001b90:	dc450513          	addi	a0,a0,-572 # 81111950 <pid_lock>
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	266080e7          	jalr	614(ra) # 80000dfa <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b9c:	01110917          	auipc	s2,0x1110
    80001ba0:	1cc90913          	addi	s2,s2,460 # 81111d68 <proc>
      initlock(&p->lock, "proc");
    80001ba4:	00006b97          	auipc	s7,0x6
    80001ba8:	63cb8b93          	addi	s7,s7,1596 # 800081e0 <digits+0x1a0>
      uint64 va = KSTACK((int) (p - proc));
    80001bac:	8b4a                	mv	s6,s2
    80001bae:	00006a97          	auipc	s5,0x6
    80001bb2:	452a8a93          	addi	s5,s5,1106 # 80008000 <etext>
    80001bb6:	040009b7          	lui	s3,0x4000
    80001bba:	19fd                	addi	s3,s3,-1
    80001bbc:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbe:	01116a17          	auipc	s4,0x1116
    80001bc2:	baaa0a13          	addi	s4,s4,-1110 # 81117768 <tickslock>
      initlock(&p->lock, "proc");
    80001bc6:	85de                	mv	a1,s7
    80001bc8:	854a                	mv	a0,s2
    80001bca:	fffff097          	auipc	ra,0xfffff
    80001bce:	230080e7          	jalr	560(ra) # 80000dfa <initlock>
      char *pa = kalloc();
    80001bd2:	fffff097          	auipc	ra,0xfffff
    80001bd6:	fd6080e7          	jalr	-42(ra) # 80000ba8 <kalloc>
    80001bda:	85aa                	mv	a1,a0
      if(pa == 0)
    80001bdc:	c929                	beqz	a0,80001c2e <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001bde:	416904b3          	sub	s1,s2,s6
    80001be2:	848d                	srai	s1,s1,0x3
    80001be4:	000ab783          	ld	a5,0(s5)
    80001be8:	02f484b3          	mul	s1,s1,a5
    80001bec:	2485                	addiw	s1,s1,1
    80001bee:	00d4949b          	slliw	s1,s1,0xd
    80001bf2:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001bf6:	4699                	li	a3,6
    80001bf8:	6605                	lui	a2,0x1
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	84a080e7          	jalr	-1974(ra) # 80001446 <kvmmap>
      p->kstack = va;
    80001c04:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c08:	16890913          	addi	s2,s2,360
    80001c0c:	fb491de3          	bne	s2,s4,80001bc6 <procinit+0x58>
  kvminithart();
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	63e080e7          	jalr	1598(ra) # 8000124e <kvminithart>
}
    80001c18:	60a6                	ld	ra,72(sp)
    80001c1a:	6406                	ld	s0,64(sp)
    80001c1c:	74e2                	ld	s1,56(sp)
    80001c1e:	7942                	ld	s2,48(sp)
    80001c20:	79a2                	ld	s3,40(sp)
    80001c22:	7a02                	ld	s4,32(sp)
    80001c24:	6ae2                	ld	s5,24(sp)
    80001c26:	6b42                	ld	s6,16(sp)
    80001c28:	6ba2                	ld	s7,8(sp)
    80001c2a:	6161                	addi	sp,sp,80
    80001c2c:	8082                	ret
        panic("kalloc");
    80001c2e:	00006517          	auipc	a0,0x6
    80001c32:	5ba50513          	addi	a0,a0,1466 # 800081e8 <digits+0x1a8>
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	912080e7          	jalr	-1774(ra) # 80000548 <panic>

0000000080001c3e <cpuid>:
{
    80001c3e:	1141                	addi	sp,sp,-16
    80001c40:	e422                	sd	s0,8(sp)
    80001c42:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c44:	8512                	mv	a0,tp
}
    80001c46:	2501                	sext.w	a0,a0
    80001c48:	6422                	ld	s0,8(sp)
    80001c4a:	0141                	addi	sp,sp,16
    80001c4c:	8082                	ret

0000000080001c4e <mycpu>:
mycpu(void) {
    80001c4e:	1141                	addi	sp,sp,-16
    80001c50:	e422                	sd	s0,8(sp)
    80001c52:	0800                	addi	s0,sp,16
    80001c54:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001c56:	2781                	sext.w	a5,a5
    80001c58:	079e                	slli	a5,a5,0x7
}
    80001c5a:	01110517          	auipc	a0,0x1110
    80001c5e:	d0e50513          	addi	a0,a0,-754 # 81111968 <cpus>
    80001c62:	953e                	add	a0,a0,a5
    80001c64:	6422                	ld	s0,8(sp)
    80001c66:	0141                	addi	sp,sp,16
    80001c68:	8082                	ret

0000000080001c6a <myproc>:
myproc(void) {
    80001c6a:	1101                	addi	sp,sp,-32
    80001c6c:	ec06                	sd	ra,24(sp)
    80001c6e:	e822                	sd	s0,16(sp)
    80001c70:	e426                	sd	s1,8(sp)
    80001c72:	1000                	addi	s0,sp,32
  push_off();
    80001c74:	fffff097          	auipc	ra,0xfffff
    80001c78:	1ca080e7          	jalr	458(ra) # 80000e3e <push_off>
    80001c7c:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001c7e:	2781                	sext.w	a5,a5
    80001c80:	079e                	slli	a5,a5,0x7
    80001c82:	01110717          	auipc	a4,0x1110
    80001c86:	cce70713          	addi	a4,a4,-818 # 81111950 <pid_lock>
    80001c8a:	97ba                	add	a5,a5,a4
    80001c8c:	6f84                	ld	s1,24(a5)
  pop_off();
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	250080e7          	jalr	592(ra) # 80000ede <pop_off>
}
    80001c96:	8526                	mv	a0,s1
    80001c98:	60e2                	ld	ra,24(sp)
    80001c9a:	6442                	ld	s0,16(sp)
    80001c9c:	64a2                	ld	s1,8(sp)
    80001c9e:	6105                	addi	sp,sp,32
    80001ca0:	8082                	ret

0000000080001ca2 <forkret>:
{
    80001ca2:	1141                	addi	sp,sp,-16
    80001ca4:	e406                	sd	ra,8(sp)
    80001ca6:	e022                	sd	s0,0(sp)
    80001ca8:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	fc0080e7          	jalr	-64(ra) # 80001c6a <myproc>
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	28c080e7          	jalr	652(ra) # 80000f3e <release>
  if (first) {
    80001cba:	00007797          	auipc	a5,0x7
    80001cbe:	b667a783          	lw	a5,-1178(a5) # 80008820 <first.1674>
    80001cc2:	eb89                	bnez	a5,80001cd4 <forkret+0x32>
  usertrapret();
    80001cc4:	00001097          	auipc	ra,0x1
    80001cc8:	c1c080e7          	jalr	-996(ra) # 800028e0 <usertrapret>
}
    80001ccc:	60a2                	ld	ra,8(sp)
    80001cce:	6402                	ld	s0,0(sp)
    80001cd0:	0141                	addi	sp,sp,16
    80001cd2:	8082                	ret
    first = 0;
    80001cd4:	00007797          	auipc	a5,0x7
    80001cd8:	b407a623          	sw	zero,-1204(a5) # 80008820 <first.1674>
    fsinit(ROOTDEV);
    80001cdc:	4505                	li	a0,1
    80001cde:	00002097          	auipc	ra,0x2
    80001ce2:	974080e7          	jalr	-1676(ra) # 80003652 <fsinit>
    80001ce6:	bff9                	j	80001cc4 <forkret+0x22>

0000000080001ce8 <allocpid>:
allocpid() {
    80001ce8:	1101                	addi	sp,sp,-32
    80001cea:	ec06                	sd	ra,24(sp)
    80001cec:	e822                	sd	s0,16(sp)
    80001cee:	e426                	sd	s1,8(sp)
    80001cf0:	e04a                	sd	s2,0(sp)
    80001cf2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001cf4:	01110917          	auipc	s2,0x1110
    80001cf8:	c5c90913          	addi	s2,s2,-932 # 81111950 <pid_lock>
    80001cfc:	854a                	mv	a0,s2
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	18c080e7          	jalr	396(ra) # 80000e8a <acquire>
  pid = nextpid;
    80001d06:	00007797          	auipc	a5,0x7
    80001d0a:	b1e78793          	addi	a5,a5,-1250 # 80008824 <nextpid>
    80001d0e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d10:	0014871b          	addiw	a4,s1,1
    80001d14:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d16:	854a                	mv	a0,s2
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	226080e7          	jalr	550(ra) # 80000f3e <release>
}
    80001d20:	8526                	mv	a0,s1
    80001d22:	60e2                	ld	ra,24(sp)
    80001d24:	6442                	ld	s0,16(sp)
    80001d26:	64a2                	ld	s1,8(sp)
    80001d28:	6902                	ld	s2,0(sp)
    80001d2a:	6105                	addi	sp,sp,32
    80001d2c:	8082                	ret

0000000080001d2e <proc_pagetable>:
{
    80001d2e:	1101                	addi	sp,sp,-32
    80001d30:	ec06                	sd	ra,24(sp)
    80001d32:	e822                	sd	s0,16(sp)
    80001d34:	e426                	sd	s1,8(sp)
    80001d36:	e04a                	sd	s2,0(sp)
    80001d38:	1000                	addi	s0,sp,32
    80001d3a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d3c:	00000097          	auipc	ra,0x0
    80001d40:	8d8080e7          	jalr	-1832(ra) # 80001614 <uvmcreate>
    80001d44:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d46:	c121                	beqz	a0,80001d86 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d48:	4729                	li	a4,10
    80001d4a:	00005697          	auipc	a3,0x5
    80001d4e:	2b668693          	addi	a3,a3,694 # 80007000 <_trampoline>
    80001d52:	6605                	lui	a2,0x1
    80001d54:	040005b7          	lui	a1,0x4000
    80001d58:	15fd                	addi	a1,a1,-1
    80001d5a:	05b2                	slli	a1,a1,0xc
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	65c080e7          	jalr	1628(ra) # 800013b8 <mappages>
    80001d64:	02054863          	bltz	a0,80001d94 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d68:	4719                	li	a4,6
    80001d6a:	05893683          	ld	a3,88(s2)
    80001d6e:	6605                	lui	a2,0x1
    80001d70:	020005b7          	lui	a1,0x2000
    80001d74:	15fd                	addi	a1,a1,-1
    80001d76:	05b6                	slli	a1,a1,0xd
    80001d78:	8526                	mv	a0,s1
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	63e080e7          	jalr	1598(ra) # 800013b8 <mappages>
    80001d82:	02054163          	bltz	a0,80001da4 <proc_pagetable+0x76>
}
    80001d86:	8526                	mv	a0,s1
    80001d88:	60e2                	ld	ra,24(sp)
    80001d8a:	6442                	ld	s0,16(sp)
    80001d8c:	64a2                	ld	s1,8(sp)
    80001d8e:	6902                	ld	s2,0(sp)
    80001d90:	6105                	addi	sp,sp,32
    80001d92:	8082                	ret
    uvmfree(pagetable, 0);
    80001d94:	4581                	li	a1,0
    80001d96:	8526                	mv	a0,s1
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	a78080e7          	jalr	-1416(ra) # 80001810 <uvmfree>
    return 0;
    80001da0:	4481                	li	s1,0
    80001da2:	b7d5                	j	80001d86 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001da4:	4681                	li	a3,0
    80001da6:	4605                	li	a2,1
    80001da8:	040005b7          	lui	a1,0x4000
    80001dac:	15fd                	addi	a1,a1,-1
    80001dae:	05b2                	slli	a1,a1,0xc
    80001db0:	8526                	mv	a0,s1
    80001db2:	fffff097          	auipc	ra,0xfffff
    80001db6:	79e080e7          	jalr	1950(ra) # 80001550 <uvmunmap>
    uvmfree(pagetable, 0);
    80001dba:	4581                	li	a1,0
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	00000097          	auipc	ra,0x0
    80001dc2:	a52080e7          	jalr	-1454(ra) # 80001810 <uvmfree>
    return 0;
    80001dc6:	4481                	li	s1,0
    80001dc8:	bf7d                	j	80001d86 <proc_pagetable+0x58>

0000000080001dca <proc_freepagetable>:
{
    80001dca:	1101                	addi	sp,sp,-32
    80001dcc:	ec06                	sd	ra,24(sp)
    80001dce:	e822                	sd	s0,16(sp)
    80001dd0:	e426                	sd	s1,8(sp)
    80001dd2:	e04a                	sd	s2,0(sp)
    80001dd4:	1000                	addi	s0,sp,32
    80001dd6:	84aa                	mv	s1,a0
    80001dd8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dda:	4681                	li	a3,0
    80001ddc:	4605                	li	a2,1
    80001dde:	040005b7          	lui	a1,0x4000
    80001de2:	15fd                	addi	a1,a1,-1
    80001de4:	05b2                	slli	a1,a1,0xc
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	76a080e7          	jalr	1898(ra) # 80001550 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001dee:	4681                	li	a3,0
    80001df0:	4605                	li	a2,1
    80001df2:	020005b7          	lui	a1,0x2000
    80001df6:	15fd                	addi	a1,a1,-1
    80001df8:	05b6                	slli	a1,a1,0xd
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	754080e7          	jalr	1876(ra) # 80001550 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e04:	85ca                	mv	a1,s2
    80001e06:	8526                	mv	a0,s1
    80001e08:	00000097          	auipc	ra,0x0
    80001e0c:	a08080e7          	jalr	-1528(ra) # 80001810 <uvmfree>
}
    80001e10:	60e2                	ld	ra,24(sp)
    80001e12:	6442                	ld	s0,16(sp)
    80001e14:	64a2                	ld	s1,8(sp)
    80001e16:	6902                	ld	s2,0(sp)
    80001e18:	6105                	addi	sp,sp,32
    80001e1a:	8082                	ret

0000000080001e1c <freeproc>:
{
    80001e1c:	1101                	addi	sp,sp,-32
    80001e1e:	ec06                	sd	ra,24(sp)
    80001e20:	e822                	sd	s0,16(sp)
    80001e22:	e426                	sd	s1,8(sp)
    80001e24:	1000                	addi	s0,sp,32
    80001e26:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e28:	6d28                	ld	a0,88(a0)
    80001e2a:	c509                	beqz	a0,80001e34 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001e2c:	fffff097          	auipc	ra,0xfffff
    80001e30:	bf8080e7          	jalr	-1032(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001e34:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001e38:	68a8                	ld	a0,80(s1)
    80001e3a:	c511                	beqz	a0,80001e46 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e3c:	64ac                	ld	a1,72(s1)
    80001e3e:	00000097          	auipc	ra,0x0
    80001e42:	f8c080e7          	jalr	-116(ra) # 80001dca <proc_freepagetable>
  p->pagetable = 0;
    80001e46:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e4a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e4e:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001e52:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001e56:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e5a:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001e5e:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001e62:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001e66:	0004ac23          	sw	zero,24(s1)
}
    80001e6a:	60e2                	ld	ra,24(sp)
    80001e6c:	6442                	ld	s0,16(sp)
    80001e6e:	64a2                	ld	s1,8(sp)
    80001e70:	6105                	addi	sp,sp,32
    80001e72:	8082                	ret

0000000080001e74 <allocproc>:
{
    80001e74:	1101                	addi	sp,sp,-32
    80001e76:	ec06                	sd	ra,24(sp)
    80001e78:	e822                	sd	s0,16(sp)
    80001e7a:	e426                	sd	s1,8(sp)
    80001e7c:	e04a                	sd	s2,0(sp)
    80001e7e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e80:	01110497          	auipc	s1,0x1110
    80001e84:	ee848493          	addi	s1,s1,-280 # 81111d68 <proc>
    80001e88:	01116917          	auipc	s2,0x1116
    80001e8c:	8e090913          	addi	s2,s2,-1824 # 81117768 <tickslock>
    acquire(&p->lock);
    80001e90:	8526                	mv	a0,s1
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	ff8080e7          	jalr	-8(ra) # 80000e8a <acquire>
    if(p->state == UNUSED) {
    80001e9a:	4c9c                	lw	a5,24(s1)
    80001e9c:	cf81                	beqz	a5,80001eb4 <allocproc+0x40>
      release(&p->lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	09e080e7          	jalr	158(ra) # 80000f3e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ea8:	16848493          	addi	s1,s1,360
    80001eac:	ff2492e3          	bne	s1,s2,80001e90 <allocproc+0x1c>
  return 0;
    80001eb0:	4481                	li	s1,0
    80001eb2:	a0b9                	j	80001f00 <allocproc+0x8c>
  p->pid = allocpid();
    80001eb4:	00000097          	auipc	ra,0x0
    80001eb8:	e34080e7          	jalr	-460(ra) # 80001ce8 <allocpid>
    80001ebc:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	cea080e7          	jalr	-790(ra) # 80000ba8 <kalloc>
    80001ec6:	892a                	mv	s2,a0
    80001ec8:	eca8                	sd	a0,88(s1)
    80001eca:	c131                	beqz	a0,80001f0e <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001ecc:	8526                	mv	a0,s1
    80001ece:	00000097          	auipc	ra,0x0
    80001ed2:	e60080e7          	jalr	-416(ra) # 80001d2e <proc_pagetable>
    80001ed6:	892a                	mv	s2,a0
    80001ed8:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001eda:	c129                	beqz	a0,80001f1c <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001edc:	07000613          	li	a2,112
    80001ee0:	4581                	li	a1,0
    80001ee2:	06048513          	addi	a0,s1,96
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	0a0080e7          	jalr	160(ra) # 80000f86 <memset>
  p->context.ra = (uint64)forkret;
    80001eee:	00000797          	auipc	a5,0x0
    80001ef2:	db478793          	addi	a5,a5,-588 # 80001ca2 <forkret>
    80001ef6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ef8:	60bc                	ld	a5,64(s1)
    80001efa:	6705                	lui	a4,0x1
    80001efc:	97ba                	add	a5,a5,a4
    80001efe:	f4bc                	sd	a5,104(s1)
}
    80001f00:	8526                	mv	a0,s1
    80001f02:	60e2                	ld	ra,24(sp)
    80001f04:	6442                	ld	s0,16(sp)
    80001f06:	64a2                	ld	s1,8(sp)
    80001f08:	6902                	ld	s2,0(sp)
    80001f0a:	6105                	addi	sp,sp,32
    80001f0c:	8082                	ret
    release(&p->lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	02e080e7          	jalr	46(ra) # 80000f3e <release>
    return 0;
    80001f18:	84ca                	mv	s1,s2
    80001f1a:	b7dd                	j	80001f00 <allocproc+0x8c>
    freeproc(p);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	00000097          	auipc	ra,0x0
    80001f22:	efe080e7          	jalr	-258(ra) # 80001e1c <freeproc>
    release(&p->lock);
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	016080e7          	jalr	22(ra) # 80000f3e <release>
    return 0;
    80001f30:	84ca                	mv	s1,s2
    80001f32:	b7f9                	j	80001f00 <allocproc+0x8c>

0000000080001f34 <userinit>:
{
    80001f34:	1101                	addi	sp,sp,-32
    80001f36:	ec06                	sd	ra,24(sp)
    80001f38:	e822                	sd	s0,16(sp)
    80001f3a:	e426                	sd	s1,8(sp)
    80001f3c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f3e:	00000097          	auipc	ra,0x0
    80001f42:	f36080e7          	jalr	-202(ra) # 80001e74 <allocproc>
    80001f46:	84aa                	mv	s1,a0
  initproc = p;
    80001f48:	00007797          	auipc	a5,0x7
    80001f4c:	0ca7b823          	sd	a0,208(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f50:	03400613          	li	a2,52
    80001f54:	00007597          	auipc	a1,0x7
    80001f58:	8dc58593          	addi	a1,a1,-1828 # 80008830 <initcode>
    80001f5c:	6928                	ld	a0,80(a0)
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	6e4080e7          	jalr	1764(ra) # 80001642 <uvminit>
  p->sz = PGSIZE;
    80001f66:	6785                	lui	a5,0x1
    80001f68:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001f6a:	6cb8                	ld	a4,88(s1)
    80001f6c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001f70:	6cb8                	ld	a4,88(s1)
    80001f72:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f74:	4641                	li	a2,16
    80001f76:	00006597          	auipc	a1,0x6
    80001f7a:	27a58593          	addi	a1,a1,634 # 800081f0 <digits+0x1b0>
    80001f7e:	15848513          	addi	a0,s1,344
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	15a080e7          	jalr	346(ra) # 800010dc <safestrcpy>
  p->cwd = namei("/");
    80001f8a:	00006517          	auipc	a0,0x6
    80001f8e:	27650513          	addi	a0,a0,630 # 80008200 <digits+0x1c0>
    80001f92:	00002097          	auipc	ra,0x2
    80001f96:	0ec080e7          	jalr	236(ra) # 8000407e <namei>
    80001f9a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f9e:	4789                	li	a5,2
    80001fa0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	f9a080e7          	jalr	-102(ra) # 80000f3e <release>
}
    80001fac:	60e2                	ld	ra,24(sp)
    80001fae:	6442                	ld	s0,16(sp)
    80001fb0:	64a2                	ld	s1,8(sp)
    80001fb2:	6105                	addi	sp,sp,32
    80001fb4:	8082                	ret

0000000080001fb6 <growproc>:
{
    80001fb6:	1101                	addi	sp,sp,-32
    80001fb8:	ec06                	sd	ra,24(sp)
    80001fba:	e822                	sd	s0,16(sp)
    80001fbc:	e426                	sd	s1,8(sp)
    80001fbe:	e04a                	sd	s2,0(sp)
    80001fc0:	1000                	addi	s0,sp,32
    80001fc2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fc4:	00000097          	auipc	ra,0x0
    80001fc8:	ca6080e7          	jalr	-858(ra) # 80001c6a <myproc>
    80001fcc:	892a                	mv	s2,a0
  sz = p->sz;
    80001fce:	652c                	ld	a1,72(a0)
    80001fd0:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001fd4:	00904f63          	bgtz	s1,80001ff2 <growproc+0x3c>
  } else if(n < 0){
    80001fd8:	0204cc63          	bltz	s1,80002010 <growproc+0x5a>
  p->sz = sz;
    80001fdc:	1602                	slli	a2,a2,0x20
    80001fde:	9201                	srli	a2,a2,0x20
    80001fe0:	04c93423          	sd	a2,72(s2)
  return 0;
    80001fe4:	4501                	li	a0,0
}
    80001fe6:	60e2                	ld	ra,24(sp)
    80001fe8:	6442                	ld	s0,16(sp)
    80001fea:	64a2                	ld	s1,8(sp)
    80001fec:	6902                	ld	s2,0(sp)
    80001fee:	6105                	addi	sp,sp,32
    80001ff0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001ff2:	9e25                	addw	a2,a2,s1
    80001ff4:	1602                	slli	a2,a2,0x20
    80001ff6:	9201                	srli	a2,a2,0x20
    80001ff8:	1582                	slli	a1,a1,0x20
    80001ffa:	9181                	srli	a1,a1,0x20
    80001ffc:	6928                	ld	a0,80(a0)
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	6fe080e7          	jalr	1790(ra) # 800016fc <uvmalloc>
    80002006:	0005061b          	sext.w	a2,a0
    8000200a:	fa69                	bnez	a2,80001fdc <growproc+0x26>
      return -1;
    8000200c:	557d                	li	a0,-1
    8000200e:	bfe1                	j	80001fe6 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002010:	9e25                	addw	a2,a2,s1
    80002012:	1602                	slli	a2,a2,0x20
    80002014:	9201                	srli	a2,a2,0x20
    80002016:	1582                	slli	a1,a1,0x20
    80002018:	9181                	srli	a1,a1,0x20
    8000201a:	6928                	ld	a0,80(a0)
    8000201c:	fffff097          	auipc	ra,0xfffff
    80002020:	698080e7          	jalr	1688(ra) # 800016b4 <uvmdealloc>
    80002024:	0005061b          	sext.w	a2,a0
    80002028:	bf55                	j	80001fdc <growproc+0x26>

000000008000202a <fork>:
{
    8000202a:	7179                	addi	sp,sp,-48
    8000202c:	f406                	sd	ra,40(sp)
    8000202e:	f022                	sd	s0,32(sp)
    80002030:	ec26                	sd	s1,24(sp)
    80002032:	e84a                	sd	s2,16(sp)
    80002034:	e44e                	sd	s3,8(sp)
    80002036:	e052                	sd	s4,0(sp)
    80002038:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	c30080e7          	jalr	-976(ra) # 80001c6a <myproc>
    80002042:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002044:	00000097          	auipc	ra,0x0
    80002048:	e30080e7          	jalr	-464(ra) # 80001e74 <allocproc>
    8000204c:	c175                	beqz	a0,80002130 <fork+0x106>
    8000204e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002050:	04893603          	ld	a2,72(s2)
    80002054:	692c                	ld	a1,80(a0)
    80002056:	05093503          	ld	a0,80(s2)
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	7ee080e7          	jalr	2030(ra) # 80001848 <uvmcopy>
    80002062:	04054863          	bltz	a0,800020b2 <fork+0x88>
  np->sz = p->sz;
    80002066:	04893783          	ld	a5,72(s2)
    8000206a:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    8000206e:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80002072:	05893683          	ld	a3,88(s2)
    80002076:	87b6                	mv	a5,a3
    80002078:	0589b703          	ld	a4,88(s3)
    8000207c:	12068693          	addi	a3,a3,288
    80002080:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002084:	6788                	ld	a0,8(a5)
    80002086:	6b8c                	ld	a1,16(a5)
    80002088:	6f90                	ld	a2,24(a5)
    8000208a:	01073023          	sd	a6,0(a4)
    8000208e:	e708                	sd	a0,8(a4)
    80002090:	eb0c                	sd	a1,16(a4)
    80002092:	ef10                	sd	a2,24(a4)
    80002094:	02078793          	addi	a5,a5,32
    80002098:	02070713          	addi	a4,a4,32
    8000209c:	fed792e3          	bne	a5,a3,80002080 <fork+0x56>
  np->trapframe->a0 = 0;
    800020a0:	0589b783          	ld	a5,88(s3)
    800020a4:	0607b823          	sd	zero,112(a5)
    800020a8:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    800020ac:	15000a13          	li	s4,336
    800020b0:	a03d                	j	800020de <fork+0xb4>
    freeproc(np);
    800020b2:	854e                	mv	a0,s3
    800020b4:	00000097          	auipc	ra,0x0
    800020b8:	d68080e7          	jalr	-664(ra) # 80001e1c <freeproc>
    release(&np->lock);
    800020bc:	854e                	mv	a0,s3
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	e80080e7          	jalr	-384(ra) # 80000f3e <release>
    return -1;
    800020c6:	54fd                	li	s1,-1
    800020c8:	a899                	j	8000211e <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    800020ca:	00002097          	auipc	ra,0x2
    800020ce:	640080e7          	jalr	1600(ra) # 8000470a <filedup>
    800020d2:	009987b3          	add	a5,s3,s1
    800020d6:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800020d8:	04a1                	addi	s1,s1,8
    800020da:	01448763          	beq	s1,s4,800020e8 <fork+0xbe>
    if(p->ofile[i])
    800020de:	009907b3          	add	a5,s2,s1
    800020e2:	6388                	ld	a0,0(a5)
    800020e4:	f17d                	bnez	a0,800020ca <fork+0xa0>
    800020e6:	bfcd                	j	800020d8 <fork+0xae>
  np->cwd = idup(p->cwd);
    800020e8:	15093503          	ld	a0,336(s2)
    800020ec:	00001097          	auipc	ra,0x1
    800020f0:	7a0080e7          	jalr	1952(ra) # 8000388c <idup>
    800020f4:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020f8:	4641                	li	a2,16
    800020fa:	15890593          	addi	a1,s2,344
    800020fe:	15898513          	addi	a0,s3,344
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	fda080e7          	jalr	-38(ra) # 800010dc <safestrcpy>
  pid = np->pid;
    8000210a:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    8000210e:	4789                	li	a5,2
    80002110:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002114:	854e                	mv	a0,s3
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	e28080e7          	jalr	-472(ra) # 80000f3e <release>
}
    8000211e:	8526                	mv	a0,s1
    80002120:	70a2                	ld	ra,40(sp)
    80002122:	7402                	ld	s0,32(sp)
    80002124:	64e2                	ld	s1,24(sp)
    80002126:	6942                	ld	s2,16(sp)
    80002128:	69a2                	ld	s3,8(sp)
    8000212a:	6a02                	ld	s4,0(sp)
    8000212c:	6145                	addi	sp,sp,48
    8000212e:	8082                	ret
    return -1;
    80002130:	54fd                	li	s1,-1
    80002132:	b7f5                	j	8000211e <fork+0xf4>

0000000080002134 <reparent>:
{
    80002134:	7179                	addi	sp,sp,-48
    80002136:	f406                	sd	ra,40(sp)
    80002138:	f022                	sd	s0,32(sp)
    8000213a:	ec26                	sd	s1,24(sp)
    8000213c:	e84a                	sd	s2,16(sp)
    8000213e:	e44e                	sd	s3,8(sp)
    80002140:	e052                	sd	s4,0(sp)
    80002142:	1800                	addi	s0,sp,48
    80002144:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002146:	01110497          	auipc	s1,0x1110
    8000214a:	c2248493          	addi	s1,s1,-990 # 81111d68 <proc>
      pp->parent = initproc;
    8000214e:	00007a17          	auipc	s4,0x7
    80002152:	ecaa0a13          	addi	s4,s4,-310 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002156:	01115997          	auipc	s3,0x1115
    8000215a:	61298993          	addi	s3,s3,1554 # 81117768 <tickslock>
    8000215e:	a029                	j	80002168 <reparent+0x34>
    80002160:	16848493          	addi	s1,s1,360
    80002164:	03348363          	beq	s1,s3,8000218a <reparent+0x56>
    if(pp->parent == p){
    80002168:	709c                	ld	a5,32(s1)
    8000216a:	ff279be3          	bne	a5,s2,80002160 <reparent+0x2c>
      acquire(&pp->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	d1a080e7          	jalr	-742(ra) # 80000e8a <acquire>
      pp->parent = initproc;
    80002178:	000a3783          	ld	a5,0(s4)
    8000217c:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    8000217e:	8526                	mv	a0,s1
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	dbe080e7          	jalr	-578(ra) # 80000f3e <release>
    80002188:	bfe1                	j	80002160 <reparent+0x2c>
}
    8000218a:	70a2                	ld	ra,40(sp)
    8000218c:	7402                	ld	s0,32(sp)
    8000218e:	64e2                	ld	s1,24(sp)
    80002190:	6942                	ld	s2,16(sp)
    80002192:	69a2                	ld	s3,8(sp)
    80002194:	6a02                	ld	s4,0(sp)
    80002196:	6145                	addi	sp,sp,48
    80002198:	8082                	ret

000000008000219a <scheduler>:
{
    8000219a:	711d                	addi	sp,sp,-96
    8000219c:	ec86                	sd	ra,88(sp)
    8000219e:	e8a2                	sd	s0,80(sp)
    800021a0:	e4a6                	sd	s1,72(sp)
    800021a2:	e0ca                	sd	s2,64(sp)
    800021a4:	fc4e                	sd	s3,56(sp)
    800021a6:	f852                	sd	s4,48(sp)
    800021a8:	f456                	sd	s5,40(sp)
    800021aa:	f05a                	sd	s6,32(sp)
    800021ac:	ec5e                	sd	s7,24(sp)
    800021ae:	e862                	sd	s8,16(sp)
    800021b0:	e466                	sd	s9,8(sp)
    800021b2:	1080                	addi	s0,sp,96
    800021b4:	8792                	mv	a5,tp
  int id = r_tp();
    800021b6:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021b8:	00779c13          	slli	s8,a5,0x7
    800021bc:	0110f717          	auipc	a4,0x110f
    800021c0:	79470713          	addi	a4,a4,1940 # 81111950 <pid_lock>
    800021c4:	9762                	add	a4,a4,s8
    800021c6:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    800021ca:	0110f717          	auipc	a4,0x110f
    800021ce:	7a670713          	addi	a4,a4,1958 # 81111970 <cpus+0x8>
    800021d2:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    800021d4:	4a89                	li	s5,2
        c->proc = p;
    800021d6:	079e                	slli	a5,a5,0x7
    800021d8:	0110fb17          	auipc	s6,0x110f
    800021dc:	778b0b13          	addi	s6,s6,1912 # 81111950 <pid_lock>
    800021e0:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800021e2:	01115a17          	auipc	s4,0x1115
    800021e6:	586a0a13          	addi	s4,s4,1414 # 81117768 <tickslock>
    int nproc = 0;
    800021ea:	4c81                	li	s9,0
    800021ec:	a8a1                	j	80002244 <scheduler+0xaa>
        p->state = RUNNING;
    800021ee:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    800021f2:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    800021f6:	06048593          	addi	a1,s1,96
    800021fa:	8562                	mv	a0,s8
    800021fc:	00000097          	auipc	ra,0x0
    80002200:	63a080e7          	jalr	1594(ra) # 80002836 <swtch>
        c->proc = 0;
    80002204:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80002208:	8526                	mv	a0,s1
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	d34080e7          	jalr	-716(ra) # 80000f3e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002212:	16848493          	addi	s1,s1,360
    80002216:	01448d63          	beq	s1,s4,80002230 <scheduler+0x96>
      acquire(&p->lock);
    8000221a:	8526                	mv	a0,s1
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	c6e080e7          	jalr	-914(ra) # 80000e8a <acquire>
      if(p->state != UNUSED) {
    80002224:	4c9c                	lw	a5,24(s1)
    80002226:	d3ed                	beqz	a5,80002208 <scheduler+0x6e>
        nproc++;
    80002228:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    8000222a:	fd579fe3          	bne	a5,s5,80002208 <scheduler+0x6e>
    8000222e:	b7c1                	j	800021ee <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    80002230:	013aca63          	blt	s5,s3,80002244 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002234:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002238:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000223c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002240:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002244:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002248:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000224c:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80002250:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80002252:	01110497          	auipc	s1,0x1110
    80002256:	b1648493          	addi	s1,s1,-1258 # 81111d68 <proc>
        p->state = RUNNING;
    8000225a:	4b8d                	li	s7,3
    8000225c:	bf7d                	j	8000221a <scheduler+0x80>

000000008000225e <sched>:
{
    8000225e:	7179                	addi	sp,sp,-48
    80002260:	f406                	sd	ra,40(sp)
    80002262:	f022                	sd	s0,32(sp)
    80002264:	ec26                	sd	s1,24(sp)
    80002266:	e84a                	sd	s2,16(sp)
    80002268:	e44e                	sd	s3,8(sp)
    8000226a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000226c:	00000097          	auipc	ra,0x0
    80002270:	9fe080e7          	jalr	-1538(ra) # 80001c6a <myproc>
    80002274:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	b9a080e7          	jalr	-1126(ra) # 80000e10 <holding>
    8000227e:	c93d                	beqz	a0,800022f4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002280:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002282:	2781                	sext.w	a5,a5
    80002284:	079e                	slli	a5,a5,0x7
    80002286:	0110f717          	auipc	a4,0x110f
    8000228a:	6ca70713          	addi	a4,a4,1738 # 81111950 <pid_lock>
    8000228e:	97ba                	add	a5,a5,a4
    80002290:	0907a703          	lw	a4,144(a5)
    80002294:	4785                	li	a5,1
    80002296:	06f71763          	bne	a4,a5,80002304 <sched+0xa6>
  if(p->state == RUNNING)
    8000229a:	4c98                	lw	a4,24(s1)
    8000229c:	478d                	li	a5,3
    8000229e:	06f70b63          	beq	a4,a5,80002314 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022a2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022a6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022a8:	efb5                	bnez	a5,80002324 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022aa:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022ac:	0110f917          	auipc	s2,0x110f
    800022b0:	6a490913          	addi	s2,s2,1700 # 81111950 <pid_lock>
    800022b4:	2781                	sext.w	a5,a5
    800022b6:	079e                	slli	a5,a5,0x7
    800022b8:	97ca                	add	a5,a5,s2
    800022ba:	0947a983          	lw	s3,148(a5)
    800022be:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800022c0:	2781                	sext.w	a5,a5
    800022c2:	079e                	slli	a5,a5,0x7
    800022c4:	0110f597          	auipc	a1,0x110f
    800022c8:	6ac58593          	addi	a1,a1,1708 # 81111970 <cpus+0x8>
    800022cc:	95be                	add	a1,a1,a5
    800022ce:	06048513          	addi	a0,s1,96
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	564080e7          	jalr	1380(ra) # 80002836 <swtch>
    800022da:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022dc:	2781                	sext.w	a5,a5
    800022de:	079e                	slli	a5,a5,0x7
    800022e0:	97ca                	add	a5,a5,s2
    800022e2:	0937aa23          	sw	s3,148(a5)
}
    800022e6:	70a2                	ld	ra,40(sp)
    800022e8:	7402                	ld	s0,32(sp)
    800022ea:	64e2                	ld	s1,24(sp)
    800022ec:	6942                	ld	s2,16(sp)
    800022ee:	69a2                	ld	s3,8(sp)
    800022f0:	6145                	addi	sp,sp,48
    800022f2:	8082                	ret
    panic("sched p->lock");
    800022f4:	00006517          	auipc	a0,0x6
    800022f8:	f1450513          	addi	a0,a0,-236 # 80008208 <digits+0x1c8>
    800022fc:	ffffe097          	auipc	ra,0xffffe
    80002300:	24c080e7          	jalr	588(ra) # 80000548 <panic>
    panic("sched locks");
    80002304:	00006517          	auipc	a0,0x6
    80002308:	f1450513          	addi	a0,a0,-236 # 80008218 <digits+0x1d8>
    8000230c:	ffffe097          	auipc	ra,0xffffe
    80002310:	23c080e7          	jalr	572(ra) # 80000548 <panic>
    panic("sched running");
    80002314:	00006517          	auipc	a0,0x6
    80002318:	f1450513          	addi	a0,a0,-236 # 80008228 <digits+0x1e8>
    8000231c:	ffffe097          	auipc	ra,0xffffe
    80002320:	22c080e7          	jalr	556(ra) # 80000548 <panic>
    panic("sched interruptible");
    80002324:	00006517          	auipc	a0,0x6
    80002328:	f1450513          	addi	a0,a0,-236 # 80008238 <digits+0x1f8>
    8000232c:	ffffe097          	auipc	ra,0xffffe
    80002330:	21c080e7          	jalr	540(ra) # 80000548 <panic>

0000000080002334 <exit>:
{
    80002334:	7179                	addi	sp,sp,-48
    80002336:	f406                	sd	ra,40(sp)
    80002338:	f022                	sd	s0,32(sp)
    8000233a:	ec26                	sd	s1,24(sp)
    8000233c:	e84a                	sd	s2,16(sp)
    8000233e:	e44e                	sd	s3,8(sp)
    80002340:	e052                	sd	s4,0(sp)
    80002342:	1800                	addi	s0,sp,48
    80002344:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002346:	00000097          	auipc	ra,0x0
    8000234a:	924080e7          	jalr	-1756(ra) # 80001c6a <myproc>
    8000234e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002350:	00007797          	auipc	a5,0x7
    80002354:	cc87b783          	ld	a5,-824(a5) # 80009018 <initproc>
    80002358:	0d050493          	addi	s1,a0,208
    8000235c:	15050913          	addi	s2,a0,336
    80002360:	02a79363          	bne	a5,a0,80002386 <exit+0x52>
    panic("init exiting");
    80002364:	00006517          	auipc	a0,0x6
    80002368:	eec50513          	addi	a0,a0,-276 # 80008250 <digits+0x210>
    8000236c:	ffffe097          	auipc	ra,0xffffe
    80002370:	1dc080e7          	jalr	476(ra) # 80000548 <panic>
      fileclose(f);
    80002374:	00002097          	auipc	ra,0x2
    80002378:	3e8080e7          	jalr	1000(ra) # 8000475c <fileclose>
      p->ofile[fd] = 0;
    8000237c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002380:	04a1                	addi	s1,s1,8
    80002382:	01248563          	beq	s1,s2,8000238c <exit+0x58>
    if(p->ofile[fd]){
    80002386:	6088                	ld	a0,0(s1)
    80002388:	f575                	bnez	a0,80002374 <exit+0x40>
    8000238a:	bfdd                	j	80002380 <exit+0x4c>
  begin_op();
    8000238c:	00002097          	auipc	ra,0x2
    80002390:	efe080e7          	jalr	-258(ra) # 8000428a <begin_op>
  iput(p->cwd);
    80002394:	1509b503          	ld	a0,336(s3)
    80002398:	00001097          	auipc	ra,0x1
    8000239c:	6ec080e7          	jalr	1772(ra) # 80003a84 <iput>
  end_op();
    800023a0:	00002097          	auipc	ra,0x2
    800023a4:	f6a080e7          	jalr	-150(ra) # 8000430a <end_op>
  p->cwd = 0;
    800023a8:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800023ac:	00007497          	auipc	s1,0x7
    800023b0:	c6c48493          	addi	s1,s1,-916 # 80009018 <initproc>
    800023b4:	6088                	ld	a0,0(s1)
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	ad4080e7          	jalr	-1324(ra) # 80000e8a <acquire>
  wakeup1(initproc);
    800023be:	6088                	ld	a0,0(s1)
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	76a080e7          	jalr	1898(ra) # 80001b2a <wakeup1>
  release(&initproc->lock);
    800023c8:	6088                	ld	a0,0(s1)
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	b74080e7          	jalr	-1164(ra) # 80000f3e <release>
  acquire(&p->lock);
    800023d2:	854e                	mv	a0,s3
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	ab6080e7          	jalr	-1354(ra) # 80000e8a <acquire>
  struct proc *original_parent = p->parent;
    800023dc:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800023e0:	854e                	mv	a0,s3
    800023e2:	fffff097          	auipc	ra,0xfffff
    800023e6:	b5c080e7          	jalr	-1188(ra) # 80000f3e <release>
  acquire(&original_parent->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	a9e080e7          	jalr	-1378(ra) # 80000e8a <acquire>
  acquire(&p->lock);
    800023f4:	854e                	mv	a0,s3
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	a94080e7          	jalr	-1388(ra) # 80000e8a <acquire>
  reparent(p);
    800023fe:	854e                	mv	a0,s3
    80002400:	00000097          	auipc	ra,0x0
    80002404:	d34080e7          	jalr	-716(ra) # 80002134 <reparent>
  wakeup1(original_parent);
    80002408:	8526                	mv	a0,s1
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	720080e7          	jalr	1824(ra) # 80001b2a <wakeup1>
  p->xstate = status;
    80002412:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002416:	4791                	li	a5,4
    80002418:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000241c:	8526                	mv	a0,s1
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	b20080e7          	jalr	-1248(ra) # 80000f3e <release>
  sched();
    80002426:	00000097          	auipc	ra,0x0
    8000242a:	e38080e7          	jalr	-456(ra) # 8000225e <sched>
  panic("zombie exit");
    8000242e:	00006517          	auipc	a0,0x6
    80002432:	e3250513          	addi	a0,a0,-462 # 80008260 <digits+0x220>
    80002436:	ffffe097          	auipc	ra,0xffffe
    8000243a:	112080e7          	jalr	274(ra) # 80000548 <panic>

000000008000243e <yield>:
{
    8000243e:	1101                	addi	sp,sp,-32
    80002440:	ec06                	sd	ra,24(sp)
    80002442:	e822                	sd	s0,16(sp)
    80002444:	e426                	sd	s1,8(sp)
    80002446:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002448:	00000097          	auipc	ra,0x0
    8000244c:	822080e7          	jalr	-2014(ra) # 80001c6a <myproc>
    80002450:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	a38080e7          	jalr	-1480(ra) # 80000e8a <acquire>
  p->state = RUNNABLE;
    8000245a:	4789                	li	a5,2
    8000245c:	cc9c                	sw	a5,24(s1)
  sched();
    8000245e:	00000097          	auipc	ra,0x0
    80002462:	e00080e7          	jalr	-512(ra) # 8000225e <sched>
  release(&p->lock);
    80002466:	8526                	mv	a0,s1
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	ad6080e7          	jalr	-1322(ra) # 80000f3e <release>
}
    80002470:	60e2                	ld	ra,24(sp)
    80002472:	6442                	ld	s0,16(sp)
    80002474:	64a2                	ld	s1,8(sp)
    80002476:	6105                	addi	sp,sp,32
    80002478:	8082                	ret

000000008000247a <sleep>:
{
    8000247a:	7179                	addi	sp,sp,-48
    8000247c:	f406                	sd	ra,40(sp)
    8000247e:	f022                	sd	s0,32(sp)
    80002480:	ec26                	sd	s1,24(sp)
    80002482:	e84a                	sd	s2,16(sp)
    80002484:	e44e                	sd	s3,8(sp)
    80002486:	1800                	addi	s0,sp,48
    80002488:	89aa                	mv	s3,a0
    8000248a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	7de080e7          	jalr	2014(ra) # 80001c6a <myproc>
    80002494:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002496:	05250663          	beq	a0,s2,800024e2 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	9f0080e7          	jalr	-1552(ra) # 80000e8a <acquire>
    release(lk);
    800024a2:	854a                	mv	a0,s2
    800024a4:	fffff097          	auipc	ra,0xfffff
    800024a8:	a9a080e7          	jalr	-1382(ra) # 80000f3e <release>
  p->chan = chan;
    800024ac:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800024b0:	4785                	li	a5,1
    800024b2:	cc9c                	sw	a5,24(s1)
  sched();
    800024b4:	00000097          	auipc	ra,0x0
    800024b8:	daa080e7          	jalr	-598(ra) # 8000225e <sched>
  p->chan = 0;
    800024bc:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800024c0:	8526                	mv	a0,s1
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	a7c080e7          	jalr	-1412(ra) # 80000f3e <release>
    acquire(lk);
    800024ca:	854a                	mv	a0,s2
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	9be080e7          	jalr	-1602(ra) # 80000e8a <acquire>
}
    800024d4:	70a2                	ld	ra,40(sp)
    800024d6:	7402                	ld	s0,32(sp)
    800024d8:	64e2                	ld	s1,24(sp)
    800024da:	6942                	ld	s2,16(sp)
    800024dc:	69a2                	ld	s3,8(sp)
    800024de:	6145                	addi	sp,sp,48
    800024e0:	8082                	ret
  p->chan = chan;
    800024e2:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800024e6:	4785                	li	a5,1
    800024e8:	cd1c                	sw	a5,24(a0)
  sched();
    800024ea:	00000097          	auipc	ra,0x0
    800024ee:	d74080e7          	jalr	-652(ra) # 8000225e <sched>
  p->chan = 0;
    800024f2:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800024f6:	bff9                	j	800024d4 <sleep+0x5a>

00000000800024f8 <wait>:
{
    800024f8:	715d                	addi	sp,sp,-80
    800024fa:	e486                	sd	ra,72(sp)
    800024fc:	e0a2                	sd	s0,64(sp)
    800024fe:	fc26                	sd	s1,56(sp)
    80002500:	f84a                	sd	s2,48(sp)
    80002502:	f44e                	sd	s3,40(sp)
    80002504:	f052                	sd	s4,32(sp)
    80002506:	ec56                	sd	s5,24(sp)
    80002508:	e85a                	sd	s6,16(sp)
    8000250a:	e45e                	sd	s7,8(sp)
    8000250c:	e062                	sd	s8,0(sp)
    8000250e:	0880                	addi	s0,sp,80
    80002510:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002512:	fffff097          	auipc	ra,0xfffff
    80002516:	758080e7          	jalr	1880(ra) # 80001c6a <myproc>
    8000251a:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000251c:	8c2a                	mv	s8,a0
    8000251e:	fffff097          	auipc	ra,0xfffff
    80002522:	96c080e7          	jalr	-1684(ra) # 80000e8a <acquire>
    havekids = 0;
    80002526:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002528:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000252a:	01115997          	auipc	s3,0x1115
    8000252e:	23e98993          	addi	s3,s3,574 # 81117768 <tickslock>
        havekids = 1;
    80002532:	4a85                	li	s5,1
    havekids = 0;
    80002534:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002536:	01110497          	auipc	s1,0x1110
    8000253a:	83248493          	addi	s1,s1,-1998 # 81111d68 <proc>
    8000253e:	a08d                	j	800025a0 <wait+0xa8>
          pid = np->pid;
    80002540:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002544:	000b0e63          	beqz	s6,80002560 <wait+0x68>
    80002548:	4691                	li	a3,4
    8000254a:	03448613          	addi	a2,s1,52
    8000254e:	85da                	mv	a1,s6
    80002550:	05093503          	ld	a0,80(s2)
    80002554:	fffff097          	auipc	ra,0xfffff
    80002558:	3e4080e7          	jalr	996(ra) # 80001938 <copyout>
    8000255c:	02054263          	bltz	a0,80002580 <wait+0x88>
          freeproc(np);
    80002560:	8526                	mv	a0,s1
    80002562:	00000097          	auipc	ra,0x0
    80002566:	8ba080e7          	jalr	-1862(ra) # 80001e1c <freeproc>
          release(&np->lock);
    8000256a:	8526                	mv	a0,s1
    8000256c:	fffff097          	auipc	ra,0xfffff
    80002570:	9d2080e7          	jalr	-1582(ra) # 80000f3e <release>
          release(&p->lock);
    80002574:	854a                	mv	a0,s2
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	9c8080e7          	jalr	-1592(ra) # 80000f3e <release>
          return pid;
    8000257e:	a8a9                	j	800025d8 <wait+0xe0>
            release(&np->lock);
    80002580:	8526                	mv	a0,s1
    80002582:	fffff097          	auipc	ra,0xfffff
    80002586:	9bc080e7          	jalr	-1604(ra) # 80000f3e <release>
            release(&p->lock);
    8000258a:	854a                	mv	a0,s2
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	9b2080e7          	jalr	-1614(ra) # 80000f3e <release>
            return -1;
    80002594:	59fd                	li	s3,-1
    80002596:	a089                	j	800025d8 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002598:	16848493          	addi	s1,s1,360
    8000259c:	03348463          	beq	s1,s3,800025c4 <wait+0xcc>
      if(np->parent == p){
    800025a0:	709c                	ld	a5,32(s1)
    800025a2:	ff279be3          	bne	a5,s2,80002598 <wait+0xa0>
        acquire(&np->lock);
    800025a6:	8526                	mv	a0,s1
    800025a8:	fffff097          	auipc	ra,0xfffff
    800025ac:	8e2080e7          	jalr	-1822(ra) # 80000e8a <acquire>
        if(np->state == ZOMBIE){
    800025b0:	4c9c                	lw	a5,24(s1)
    800025b2:	f94787e3          	beq	a5,s4,80002540 <wait+0x48>
        release(&np->lock);
    800025b6:	8526                	mv	a0,s1
    800025b8:	fffff097          	auipc	ra,0xfffff
    800025bc:	986080e7          	jalr	-1658(ra) # 80000f3e <release>
        havekids = 1;
    800025c0:	8756                	mv	a4,s5
    800025c2:	bfd9                	j	80002598 <wait+0xa0>
    if(!havekids || p->killed){
    800025c4:	c701                	beqz	a4,800025cc <wait+0xd4>
    800025c6:	03092783          	lw	a5,48(s2)
    800025ca:	c785                	beqz	a5,800025f2 <wait+0xfa>
      release(&p->lock);
    800025cc:	854a                	mv	a0,s2
    800025ce:	fffff097          	auipc	ra,0xfffff
    800025d2:	970080e7          	jalr	-1680(ra) # 80000f3e <release>
      return -1;
    800025d6:	59fd                	li	s3,-1
}
    800025d8:	854e                	mv	a0,s3
    800025da:	60a6                	ld	ra,72(sp)
    800025dc:	6406                	ld	s0,64(sp)
    800025de:	74e2                	ld	s1,56(sp)
    800025e0:	7942                	ld	s2,48(sp)
    800025e2:	79a2                	ld	s3,40(sp)
    800025e4:	7a02                	ld	s4,32(sp)
    800025e6:	6ae2                	ld	s5,24(sp)
    800025e8:	6b42                	ld	s6,16(sp)
    800025ea:	6ba2                	ld	s7,8(sp)
    800025ec:	6c02                	ld	s8,0(sp)
    800025ee:	6161                	addi	sp,sp,80
    800025f0:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800025f2:	85e2                	mv	a1,s8
    800025f4:	854a                	mv	a0,s2
    800025f6:	00000097          	auipc	ra,0x0
    800025fa:	e84080e7          	jalr	-380(ra) # 8000247a <sleep>
    havekids = 0;
    800025fe:	bf1d                	j	80002534 <wait+0x3c>

0000000080002600 <wakeup>:
{
    80002600:	7139                	addi	sp,sp,-64
    80002602:	fc06                	sd	ra,56(sp)
    80002604:	f822                	sd	s0,48(sp)
    80002606:	f426                	sd	s1,40(sp)
    80002608:	f04a                	sd	s2,32(sp)
    8000260a:	ec4e                	sd	s3,24(sp)
    8000260c:	e852                	sd	s4,16(sp)
    8000260e:	e456                	sd	s5,8(sp)
    80002610:	0080                	addi	s0,sp,64
    80002612:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002614:	0110f497          	auipc	s1,0x110f
    80002618:	75448493          	addi	s1,s1,1876 # 81111d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000261c:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000261e:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002620:	01115917          	auipc	s2,0x1115
    80002624:	14890913          	addi	s2,s2,328 # 81117768 <tickslock>
    80002628:	a821                	j	80002640 <wakeup+0x40>
      p->state = RUNNABLE;
    8000262a:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    8000262e:	8526                	mv	a0,s1
    80002630:	fffff097          	auipc	ra,0xfffff
    80002634:	90e080e7          	jalr	-1778(ra) # 80000f3e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002638:	16848493          	addi	s1,s1,360
    8000263c:	01248e63          	beq	s1,s2,80002658 <wakeup+0x58>
    acquire(&p->lock);
    80002640:	8526                	mv	a0,s1
    80002642:	fffff097          	auipc	ra,0xfffff
    80002646:	848080e7          	jalr	-1976(ra) # 80000e8a <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000264a:	4c9c                	lw	a5,24(s1)
    8000264c:	ff3791e3          	bne	a5,s3,8000262e <wakeup+0x2e>
    80002650:	749c                	ld	a5,40(s1)
    80002652:	fd479ee3          	bne	a5,s4,8000262e <wakeup+0x2e>
    80002656:	bfd1                	j	8000262a <wakeup+0x2a>
}
    80002658:	70e2                	ld	ra,56(sp)
    8000265a:	7442                	ld	s0,48(sp)
    8000265c:	74a2                	ld	s1,40(sp)
    8000265e:	7902                	ld	s2,32(sp)
    80002660:	69e2                	ld	s3,24(sp)
    80002662:	6a42                	ld	s4,16(sp)
    80002664:	6aa2                	ld	s5,8(sp)
    80002666:	6121                	addi	sp,sp,64
    80002668:	8082                	ret

000000008000266a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000266a:	7179                	addi	sp,sp,-48
    8000266c:	f406                	sd	ra,40(sp)
    8000266e:	f022                	sd	s0,32(sp)
    80002670:	ec26                	sd	s1,24(sp)
    80002672:	e84a                	sd	s2,16(sp)
    80002674:	e44e                	sd	s3,8(sp)
    80002676:	1800                	addi	s0,sp,48
    80002678:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000267a:	0110f497          	auipc	s1,0x110f
    8000267e:	6ee48493          	addi	s1,s1,1774 # 81111d68 <proc>
    80002682:	01115997          	auipc	s3,0x1115
    80002686:	0e698993          	addi	s3,s3,230 # 81117768 <tickslock>
    acquire(&p->lock);
    8000268a:	8526                	mv	a0,s1
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	7fe080e7          	jalr	2046(ra) # 80000e8a <acquire>
    if(p->pid == pid){
    80002694:	5c9c                	lw	a5,56(s1)
    80002696:	01278d63          	beq	a5,s2,800026b0 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000269a:	8526                	mv	a0,s1
    8000269c:	fffff097          	auipc	ra,0xfffff
    800026a0:	8a2080e7          	jalr	-1886(ra) # 80000f3e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800026a4:	16848493          	addi	s1,s1,360
    800026a8:	ff3491e3          	bne	s1,s3,8000268a <kill+0x20>
  }
  return -1;
    800026ac:	557d                	li	a0,-1
    800026ae:	a829                	j	800026c8 <kill+0x5e>
      p->killed = 1;
    800026b0:	4785                	li	a5,1
    800026b2:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800026b4:	4c98                	lw	a4,24(s1)
    800026b6:	4785                	li	a5,1
    800026b8:	00f70f63          	beq	a4,a5,800026d6 <kill+0x6c>
      release(&p->lock);
    800026bc:	8526                	mv	a0,s1
    800026be:	fffff097          	auipc	ra,0xfffff
    800026c2:	880080e7          	jalr	-1920(ra) # 80000f3e <release>
      return 0;
    800026c6:	4501                	li	a0,0
}
    800026c8:	70a2                	ld	ra,40(sp)
    800026ca:	7402                	ld	s0,32(sp)
    800026cc:	64e2                	ld	s1,24(sp)
    800026ce:	6942                	ld	s2,16(sp)
    800026d0:	69a2                	ld	s3,8(sp)
    800026d2:	6145                	addi	sp,sp,48
    800026d4:	8082                	ret
        p->state = RUNNABLE;
    800026d6:	4789                	li	a5,2
    800026d8:	cc9c                	sw	a5,24(s1)
    800026da:	b7cd                	j	800026bc <kill+0x52>

00000000800026dc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026dc:	7179                	addi	sp,sp,-48
    800026de:	f406                	sd	ra,40(sp)
    800026e0:	f022                	sd	s0,32(sp)
    800026e2:	ec26                	sd	s1,24(sp)
    800026e4:	e84a                	sd	s2,16(sp)
    800026e6:	e44e                	sd	s3,8(sp)
    800026e8:	e052                	sd	s4,0(sp)
    800026ea:	1800                	addi	s0,sp,48
    800026ec:	84aa                	mv	s1,a0
    800026ee:	892e                	mv	s2,a1
    800026f0:	89b2                	mv	s3,a2
    800026f2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026f4:	fffff097          	auipc	ra,0xfffff
    800026f8:	576080e7          	jalr	1398(ra) # 80001c6a <myproc>
  if(user_dst){
    800026fc:	c08d                	beqz	s1,8000271e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800026fe:	86d2                	mv	a3,s4
    80002700:	864e                	mv	a2,s3
    80002702:	85ca                	mv	a1,s2
    80002704:	6928                	ld	a0,80(a0)
    80002706:	fffff097          	auipc	ra,0xfffff
    8000270a:	232080e7          	jalr	562(ra) # 80001938 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000270e:	70a2                	ld	ra,40(sp)
    80002710:	7402                	ld	s0,32(sp)
    80002712:	64e2                	ld	s1,24(sp)
    80002714:	6942                	ld	s2,16(sp)
    80002716:	69a2                	ld	s3,8(sp)
    80002718:	6a02                	ld	s4,0(sp)
    8000271a:	6145                	addi	sp,sp,48
    8000271c:	8082                	ret
    memmove((char *)dst, src, len);
    8000271e:	000a061b          	sext.w	a2,s4
    80002722:	85ce                	mv	a1,s3
    80002724:	854a                	mv	a0,s2
    80002726:	fffff097          	auipc	ra,0xfffff
    8000272a:	8c0080e7          	jalr	-1856(ra) # 80000fe6 <memmove>
    return 0;
    8000272e:	8526                	mv	a0,s1
    80002730:	bff9                	j	8000270e <either_copyout+0x32>

0000000080002732 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002732:	7179                	addi	sp,sp,-48
    80002734:	f406                	sd	ra,40(sp)
    80002736:	f022                	sd	s0,32(sp)
    80002738:	ec26                	sd	s1,24(sp)
    8000273a:	e84a                	sd	s2,16(sp)
    8000273c:	e44e                	sd	s3,8(sp)
    8000273e:	e052                	sd	s4,0(sp)
    80002740:	1800                	addi	s0,sp,48
    80002742:	892a                	mv	s2,a0
    80002744:	84ae                	mv	s1,a1
    80002746:	89b2                	mv	s3,a2
    80002748:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000274a:	fffff097          	auipc	ra,0xfffff
    8000274e:	520080e7          	jalr	1312(ra) # 80001c6a <myproc>
  if(user_src){
    80002752:	c08d                	beqz	s1,80002774 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002754:	86d2                	mv	a3,s4
    80002756:	864e                	mv	a2,s3
    80002758:	85ca                	mv	a1,s2
    8000275a:	6928                	ld	a0,80(a0)
    8000275c:	fffff097          	auipc	ra,0xfffff
    80002760:	28e080e7          	jalr	654(ra) # 800019ea <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002764:	70a2                	ld	ra,40(sp)
    80002766:	7402                	ld	s0,32(sp)
    80002768:	64e2                	ld	s1,24(sp)
    8000276a:	6942                	ld	s2,16(sp)
    8000276c:	69a2                	ld	s3,8(sp)
    8000276e:	6a02                	ld	s4,0(sp)
    80002770:	6145                	addi	sp,sp,48
    80002772:	8082                	ret
    memmove(dst, (char*)src, len);
    80002774:	000a061b          	sext.w	a2,s4
    80002778:	85ce                	mv	a1,s3
    8000277a:	854a                	mv	a0,s2
    8000277c:	fffff097          	auipc	ra,0xfffff
    80002780:	86a080e7          	jalr	-1942(ra) # 80000fe6 <memmove>
    return 0;
    80002784:	8526                	mv	a0,s1
    80002786:	bff9                	j	80002764 <either_copyin+0x32>

0000000080002788 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002788:	715d                	addi	sp,sp,-80
    8000278a:	e486                	sd	ra,72(sp)
    8000278c:	e0a2                	sd	s0,64(sp)
    8000278e:	fc26                	sd	s1,56(sp)
    80002790:	f84a                	sd	s2,48(sp)
    80002792:	f44e                	sd	s3,40(sp)
    80002794:	f052                	sd	s4,32(sp)
    80002796:	ec56                	sd	s5,24(sp)
    80002798:	e85a                	sd	s6,16(sp)
    8000279a:	e45e                	sd	s7,8(sp)
    8000279c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000279e:	00006517          	auipc	a0,0x6
    800027a2:	93250513          	addi	a0,a0,-1742 # 800080d0 <digits+0x90>
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	dec080e7          	jalr	-532(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ae:	0110f497          	auipc	s1,0x110f
    800027b2:	71248493          	addi	s1,s1,1810 # 81111ec0 <proc+0x158>
    800027b6:	01115917          	auipc	s2,0x1115
    800027ba:	10a90913          	addi	s2,s2,266 # 811178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027be:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800027c0:	00006997          	auipc	s3,0x6
    800027c4:	ab098993          	addi	s3,s3,-1360 # 80008270 <digits+0x230>
    printf("%d %s %s", p->pid, state, p->name);
    800027c8:	00006a97          	auipc	s5,0x6
    800027cc:	ab0a8a93          	addi	s5,s5,-1360 # 80008278 <digits+0x238>
    printf("\n");
    800027d0:	00006a17          	auipc	s4,0x6
    800027d4:	900a0a13          	addi	s4,s4,-1792 # 800080d0 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027d8:	00006b97          	auipc	s7,0x6
    800027dc:	ad8b8b93          	addi	s7,s7,-1320 # 800082b0 <states.1714>
    800027e0:	a00d                	j	80002802 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027e2:	ee06a583          	lw	a1,-288(a3)
    800027e6:	8556                	mv	a0,s5
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	daa080e7          	jalr	-598(ra) # 80000592 <printf>
    printf("\n");
    800027f0:	8552                	mv	a0,s4
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	da0080e7          	jalr	-608(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027fa:	16848493          	addi	s1,s1,360
    800027fe:	03248163          	beq	s1,s2,80002820 <procdump+0x98>
    if(p->state == UNUSED)
    80002802:	86a6                	mv	a3,s1
    80002804:	ec04a783          	lw	a5,-320(s1)
    80002808:	dbed                	beqz	a5,800027fa <procdump+0x72>
      state = "???";
    8000280a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000280c:	fcfb6be3          	bltu	s6,a5,800027e2 <procdump+0x5a>
    80002810:	1782                	slli	a5,a5,0x20
    80002812:	9381                	srli	a5,a5,0x20
    80002814:	078e                	slli	a5,a5,0x3
    80002816:	97de                	add	a5,a5,s7
    80002818:	6390                	ld	a2,0(a5)
    8000281a:	f661                	bnez	a2,800027e2 <procdump+0x5a>
      state = "???";
    8000281c:	864e                	mv	a2,s3
    8000281e:	b7d1                	j	800027e2 <procdump+0x5a>
  }
}
    80002820:	60a6                	ld	ra,72(sp)
    80002822:	6406                	ld	s0,64(sp)
    80002824:	74e2                	ld	s1,56(sp)
    80002826:	7942                	ld	s2,48(sp)
    80002828:	79a2                	ld	s3,40(sp)
    8000282a:	7a02                	ld	s4,32(sp)
    8000282c:	6ae2                	ld	s5,24(sp)
    8000282e:	6b42                	ld	s6,16(sp)
    80002830:	6ba2                	ld	s7,8(sp)
    80002832:	6161                	addi	sp,sp,80
    80002834:	8082                	ret

0000000080002836 <swtch>:
    80002836:	00153023          	sd	ra,0(a0)
    8000283a:	00253423          	sd	sp,8(a0)
    8000283e:	e900                	sd	s0,16(a0)
    80002840:	ed04                	sd	s1,24(a0)
    80002842:	03253023          	sd	s2,32(a0)
    80002846:	03353423          	sd	s3,40(a0)
    8000284a:	03453823          	sd	s4,48(a0)
    8000284e:	03553c23          	sd	s5,56(a0)
    80002852:	05653023          	sd	s6,64(a0)
    80002856:	05753423          	sd	s7,72(a0)
    8000285a:	05853823          	sd	s8,80(a0)
    8000285e:	05953c23          	sd	s9,88(a0)
    80002862:	07a53023          	sd	s10,96(a0)
    80002866:	07b53423          	sd	s11,104(a0)
    8000286a:	0005b083          	ld	ra,0(a1)
    8000286e:	0085b103          	ld	sp,8(a1)
    80002872:	6980                	ld	s0,16(a1)
    80002874:	6d84                	ld	s1,24(a1)
    80002876:	0205b903          	ld	s2,32(a1)
    8000287a:	0285b983          	ld	s3,40(a1)
    8000287e:	0305ba03          	ld	s4,48(a1)
    80002882:	0385ba83          	ld	s5,56(a1)
    80002886:	0405bb03          	ld	s6,64(a1)
    8000288a:	0485bb83          	ld	s7,72(a1)
    8000288e:	0505bc03          	ld	s8,80(a1)
    80002892:	0585bc83          	ld	s9,88(a1)
    80002896:	0605bd03          	ld	s10,96(a1)
    8000289a:	0685bd83          	ld	s11,104(a1)
    8000289e:	8082                	ret

00000000800028a0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028a0:	1141                	addi	sp,sp,-16
    800028a2:	e406                	sd	ra,8(sp)
    800028a4:	e022                	sd	s0,0(sp)
    800028a6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028a8:	00006597          	auipc	a1,0x6
    800028ac:	a3058593          	addi	a1,a1,-1488 # 800082d8 <states.1714+0x28>
    800028b0:	01115517          	auipc	a0,0x1115
    800028b4:	eb850513          	addi	a0,a0,-328 # 81117768 <tickslock>
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	542080e7          	jalr	1346(ra) # 80000dfa <initlock>
}
    800028c0:	60a2                	ld	ra,8(sp)
    800028c2:	6402                	ld	s0,0(sp)
    800028c4:	0141                	addi	sp,sp,16
    800028c6:	8082                	ret

00000000800028c8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028c8:	1141                	addi	sp,sp,-16
    800028ca:	e422                	sd	s0,8(sp)
    800028cc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028ce:	00003797          	auipc	a5,0x3
    800028d2:	4f278793          	addi	a5,a5,1266 # 80005dc0 <kernelvec>
    800028d6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028da:	6422                	ld	s0,8(sp)
    800028dc:	0141                	addi	sp,sp,16
    800028de:	8082                	ret

00000000800028e0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028e0:	1141                	addi	sp,sp,-16
    800028e2:	e406                	sd	ra,8(sp)
    800028e4:	e022                	sd	s0,0(sp)
    800028e6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028e8:	fffff097          	auipc	ra,0xfffff
    800028ec:	382080e7          	jalr	898(ra) # 80001c6a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028f4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028f6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800028fa:	00004617          	auipc	a2,0x4
    800028fe:	70660613          	addi	a2,a2,1798 # 80007000 <_trampoline>
    80002902:	00004697          	auipc	a3,0x4
    80002906:	6fe68693          	addi	a3,a3,1790 # 80007000 <_trampoline>
    8000290a:	8e91                	sub	a3,a3,a2
    8000290c:	040007b7          	lui	a5,0x4000
    80002910:	17fd                	addi	a5,a5,-1
    80002912:	07b2                	slli	a5,a5,0xc
    80002914:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002916:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000291a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000291c:	180026f3          	csrr	a3,satp
    80002920:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002922:	6d38                	ld	a4,88(a0)
    80002924:	6134                	ld	a3,64(a0)
    80002926:	6585                	lui	a1,0x1
    80002928:	96ae                	add	a3,a3,a1
    8000292a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000292c:	6d38                	ld	a4,88(a0)
    8000292e:	00000697          	auipc	a3,0x0
    80002932:	13868693          	addi	a3,a3,312 # 80002a66 <usertrap>
    80002936:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002938:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000293a:	8692                	mv	a3,tp
    8000293c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000293e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002942:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002946:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000294a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000294e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002950:	6f18                	ld	a4,24(a4)
    80002952:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002956:	692c                	ld	a1,80(a0)
    80002958:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000295a:	00004717          	auipc	a4,0x4
    8000295e:	73670713          	addi	a4,a4,1846 # 80007090 <userret>
    80002962:	8f11                	sub	a4,a4,a2
    80002964:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002966:	577d                	li	a4,-1
    80002968:	177e                	slli	a4,a4,0x3f
    8000296a:	8dd9                	or	a1,a1,a4
    8000296c:	02000537          	lui	a0,0x2000
    80002970:	157d                	addi	a0,a0,-1
    80002972:	0536                	slli	a0,a0,0xd
    80002974:	9782                	jalr	a5
}
    80002976:	60a2                	ld	ra,8(sp)
    80002978:	6402                	ld	s0,0(sp)
    8000297a:	0141                	addi	sp,sp,16
    8000297c:	8082                	ret

000000008000297e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000297e:	1101                	addi	sp,sp,-32
    80002980:	ec06                	sd	ra,24(sp)
    80002982:	e822                	sd	s0,16(sp)
    80002984:	e426                	sd	s1,8(sp)
    80002986:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002988:	01115497          	auipc	s1,0x1115
    8000298c:	de048493          	addi	s1,s1,-544 # 81117768 <tickslock>
    80002990:	8526                	mv	a0,s1
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	4f8080e7          	jalr	1272(ra) # 80000e8a <acquire>
  ticks++;
    8000299a:	00006517          	auipc	a0,0x6
    8000299e:	68650513          	addi	a0,a0,1670 # 80009020 <ticks>
    800029a2:	411c                	lw	a5,0(a0)
    800029a4:	2785                	addiw	a5,a5,1
    800029a6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029a8:	00000097          	auipc	ra,0x0
    800029ac:	c58080e7          	jalr	-936(ra) # 80002600 <wakeup>
  release(&tickslock);
    800029b0:	8526                	mv	a0,s1
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	58c080e7          	jalr	1420(ra) # 80000f3e <release>
}
    800029ba:	60e2                	ld	ra,24(sp)
    800029bc:	6442                	ld	s0,16(sp)
    800029be:	64a2                	ld	s1,8(sp)
    800029c0:	6105                	addi	sp,sp,32
    800029c2:	8082                	ret

00000000800029c4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029c4:	1101                	addi	sp,sp,-32
    800029c6:	ec06                	sd	ra,24(sp)
    800029c8:	e822                	sd	s0,16(sp)
    800029ca:	e426                	sd	s1,8(sp)
    800029cc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ce:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029d2:	00074d63          	bltz	a4,800029ec <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800029d6:	57fd                	li	a5,-1
    800029d8:	17fe                	slli	a5,a5,0x3f
    800029da:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029dc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029de:	06f70363          	beq	a4,a5,80002a44 <devintr+0x80>
  }
}
    800029e2:	60e2                	ld	ra,24(sp)
    800029e4:	6442                	ld	s0,16(sp)
    800029e6:	64a2                	ld	s1,8(sp)
    800029e8:	6105                	addi	sp,sp,32
    800029ea:	8082                	ret
     (scause & 0xff) == 9){
    800029ec:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800029f0:	46a5                	li	a3,9
    800029f2:	fed792e3          	bne	a5,a3,800029d6 <devintr+0x12>
    int irq = plic_claim();
    800029f6:	00003097          	auipc	ra,0x3
    800029fa:	4d2080e7          	jalr	1234(ra) # 80005ec8 <plic_claim>
    800029fe:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a00:	47a9                	li	a5,10
    80002a02:	02f50763          	beq	a0,a5,80002a30 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a06:	4785                	li	a5,1
    80002a08:	02f50963          	beq	a0,a5,80002a3a <devintr+0x76>
    return 1;
    80002a0c:	4505                	li	a0,1
    } else if(irq){
    80002a0e:	d8f1                	beqz	s1,800029e2 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a10:	85a6                	mv	a1,s1
    80002a12:	00006517          	auipc	a0,0x6
    80002a16:	8ce50513          	addi	a0,a0,-1842 # 800082e0 <states.1714+0x30>
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	b78080e7          	jalr	-1160(ra) # 80000592 <printf>
      plic_complete(irq);
    80002a22:	8526                	mv	a0,s1
    80002a24:	00003097          	auipc	ra,0x3
    80002a28:	4c8080e7          	jalr	1224(ra) # 80005eec <plic_complete>
    return 1;
    80002a2c:	4505                	li	a0,1
    80002a2e:	bf55                	j	800029e2 <devintr+0x1e>
      uartintr();
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	fa4080e7          	jalr	-92(ra) # 800009d4 <uartintr>
    80002a38:	b7ed                	j	80002a22 <devintr+0x5e>
      virtio_disk_intr();
    80002a3a:	00004097          	auipc	ra,0x4
    80002a3e:	94c080e7          	jalr	-1716(ra) # 80006386 <virtio_disk_intr>
    80002a42:	b7c5                	j	80002a22 <devintr+0x5e>
    if(cpuid() == 0){
    80002a44:	fffff097          	auipc	ra,0xfffff
    80002a48:	1fa080e7          	jalr	506(ra) # 80001c3e <cpuid>
    80002a4c:	c901                	beqz	a0,80002a5c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a4e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a52:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a54:	14479073          	csrw	sip,a5
    return 2;
    80002a58:	4509                	li	a0,2
    80002a5a:	b761                	j	800029e2 <devintr+0x1e>
      clockintr();
    80002a5c:	00000097          	auipc	ra,0x0
    80002a60:	f22080e7          	jalr	-222(ra) # 8000297e <clockintr>
    80002a64:	b7ed                	j	80002a4e <devintr+0x8a>

0000000080002a66 <usertrap>:
{
    80002a66:	1101                	addi	sp,sp,-32
    80002a68:	ec06                	sd	ra,24(sp)
    80002a6a:	e822                	sd	s0,16(sp)
    80002a6c:	e426                	sd	s1,8(sp)
    80002a6e:	e04a                	sd	s2,0(sp)
    80002a70:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a72:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a76:	1007f793          	andi	a5,a5,256
    80002a7a:	e3b1                	bnez	a5,80002abe <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a7c:	00003797          	auipc	a5,0x3
    80002a80:	34478793          	addi	a5,a5,836 # 80005dc0 <kernelvec>
    80002a84:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a88:	fffff097          	auipc	ra,0xfffff
    80002a8c:	1e2080e7          	jalr	482(ra) # 80001c6a <myproc>
    80002a90:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a92:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a94:	14102773          	csrr	a4,sepc
    80002a98:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a9a:	142027f3          	csrr	a5,scause
  if(scause == 8){
    80002a9e:	4721                	li	a4,8
    80002aa0:	02e78763          	beq	a5,a4,80002ace <usertrap+0x68>
  } else if(scause==13 || scause==15) {
    80002aa4:	9bf5                	andi	a5,a5,-3
    80002aa6:	4735                	li	a4,13
    80002aa8:	06e78563          	beq	a5,a4,80002b12 <usertrap+0xac>
  } else if((which_dev = devintr()) != 0){
    80002aac:	00000097          	auipc	ra,0x0
    80002ab0:	f18080e7          	jalr	-232(ra) # 800029c4 <devintr>
    80002ab4:	892a                	mv	s2,a0
    80002ab6:	cd51                	beqz	a0,80002b52 <usertrap+0xec>
  if(p->killed)
    80002ab8:	589c                	lw	a5,48(s1)
    80002aba:	c7c1                	beqz	a5,80002b42 <usertrap+0xdc>
    80002abc:	a8b5                	j	80002b38 <usertrap+0xd2>
    panic("usertrap: not from user mode");
    80002abe:	00006517          	auipc	a0,0x6
    80002ac2:	84250513          	addi	a0,a0,-1982 # 80008300 <states.1714+0x50>
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	a82080e7          	jalr	-1406(ra) # 80000548 <panic>
    if(p->killed)
    80002ace:	591c                	lw	a5,48(a0)
    80002ad0:	eb9d                	bnez	a5,80002b06 <usertrap+0xa0>
    p->trapframe->epc += 4;
    80002ad2:	6cb8                	ld	a4,88(s1)
    80002ad4:	6f1c                	ld	a5,24(a4)
    80002ad6:	0791                	addi	a5,a5,4
    80002ad8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ada:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ade:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ae2:	10079073          	csrw	sstatus,a5
    syscall();
    80002ae6:	00000097          	auipc	ra,0x0
    80002aea:	2e6080e7          	jalr	742(ra) # 80002dcc <syscall>
  if(p->killed)
    80002aee:	589c                	lw	a5,48(s1)
    80002af0:	ebd9                	bnez	a5,80002b86 <usertrap+0x120>
  usertrapret();
    80002af2:	00000097          	auipc	ra,0x0
    80002af6:	dee080e7          	jalr	-530(ra) # 800028e0 <usertrapret>
}
    80002afa:	60e2                	ld	ra,24(sp)
    80002afc:	6442                	ld	s0,16(sp)
    80002afe:	64a2                	ld	s1,8(sp)
    80002b00:	6902                	ld	s2,0(sp)
    80002b02:	6105                	addi	sp,sp,32
    80002b04:	8082                	ret
      exit(-1);
    80002b06:	557d                	li	a0,-1
    80002b08:	00000097          	auipc	ra,0x0
    80002b0c:	82c080e7          	jalr	-2004(ra) # 80002334 <exit>
    80002b10:	b7c9                	j	80002ad2 <usertrap+0x6c>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b12:	14302973          	csrr	s2,stval
    if(!iscow(p->pagetable, va)) 
    80002b16:	85ca                	mv	a1,s2
    80002b18:	6928                	ld	a0,80(a0)
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	1aa080e7          	jalr	426(ra) # 80000cc4 <iscow>
    80002b22:	d571                	beqz	a0,80002aee <usertrap+0x88>
    if(!cowcopy(p->pagetable, va))
    80002b24:	85ca                	mv	a1,s2
    80002b26:	68a8                	ld	a0,80(s1)
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	1d8080e7          	jalr	472(ra) # 80000d00 <cowcopy>
    80002b30:	fd5d                	bnez	a0,80002aee <usertrap+0x88>
    p->killed = 1;
    80002b32:	4785                	li	a5,1
    80002b34:	d89c                	sw	a5,48(s1)
{
    80002b36:	4901                	li	s2,0
    exit(-1);
    80002b38:	557d                	li	a0,-1
    80002b3a:	fffff097          	auipc	ra,0xfffff
    80002b3e:	7fa080e7          	jalr	2042(ra) # 80002334 <exit>
  if(which_dev == 2)
    80002b42:	4789                	li	a5,2
    80002b44:	faf917e3          	bne	s2,a5,80002af2 <usertrap+0x8c>
    yield();
    80002b48:	00000097          	auipc	ra,0x0
    80002b4c:	8f6080e7          	jalr	-1802(ra) # 8000243e <yield>
    80002b50:	b74d                	j	80002af2 <usertrap+0x8c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b52:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b56:	5c90                	lw	a2,56(s1)
    80002b58:	00005517          	auipc	a0,0x5
    80002b5c:	7c850513          	addi	a0,a0,1992 # 80008320 <states.1714+0x70>
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	a32080e7          	jalr	-1486(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b68:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b6c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b70:	00005517          	auipc	a0,0x5
    80002b74:	7e050513          	addi	a0,a0,2016 # 80008350 <states.1714+0xa0>
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	a1a080e7          	jalr	-1510(ra) # 80000592 <printf>
    p->killed = 1;
    80002b80:	4785                	li	a5,1
    80002b82:	d89c                	sw	a5,48(s1)
    80002b84:	bf4d                	j	80002b36 <usertrap+0xd0>
  if(p->killed)
    80002b86:	4901                	li	s2,0
    80002b88:	bf45                	j	80002b38 <usertrap+0xd2>

0000000080002b8a <kerneltrap>:
{
    80002b8a:	7179                	addi	sp,sp,-48
    80002b8c:	f406                	sd	ra,40(sp)
    80002b8e:	f022                	sd	s0,32(sp)
    80002b90:	ec26                	sd	s1,24(sp)
    80002b92:	e84a                	sd	s2,16(sp)
    80002b94:	e44e                	sd	s3,8(sp)
    80002b96:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b98:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ba0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ba4:	1004f793          	andi	a5,s1,256
    80002ba8:	cb85                	beqz	a5,80002bd8 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002baa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bae:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bb0:	ef85                	bnez	a5,80002be8 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	e12080e7          	jalr	-494(ra) # 800029c4 <devintr>
    80002bba:	cd1d                	beqz	a0,80002bf8 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bbc:	4789                	li	a5,2
    80002bbe:	06f50a63          	beq	a0,a5,80002c32 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bc2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc6:	10049073          	csrw	sstatus,s1
}
    80002bca:	70a2                	ld	ra,40(sp)
    80002bcc:	7402                	ld	s0,32(sp)
    80002bce:	64e2                	ld	s1,24(sp)
    80002bd0:	6942                	ld	s2,16(sp)
    80002bd2:	69a2                	ld	s3,8(sp)
    80002bd4:	6145                	addi	sp,sp,48
    80002bd6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bd8:	00005517          	auipc	a0,0x5
    80002bdc:	79850513          	addi	a0,a0,1944 # 80008370 <states.1714+0xc0>
    80002be0:	ffffe097          	auipc	ra,0xffffe
    80002be4:	968080e7          	jalr	-1688(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002be8:	00005517          	auipc	a0,0x5
    80002bec:	7b050513          	addi	a0,a0,1968 # 80008398 <states.1714+0xe8>
    80002bf0:	ffffe097          	auipc	ra,0xffffe
    80002bf4:	958080e7          	jalr	-1704(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002bf8:	85ce                	mv	a1,s3
    80002bfa:	00005517          	auipc	a0,0x5
    80002bfe:	7be50513          	addi	a0,a0,1982 # 800083b8 <states.1714+0x108>
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	990080e7          	jalr	-1648(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c0e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c12:	00005517          	auipc	a0,0x5
    80002c16:	7b650513          	addi	a0,a0,1974 # 800083c8 <states.1714+0x118>
    80002c1a:	ffffe097          	auipc	ra,0xffffe
    80002c1e:	978080e7          	jalr	-1672(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002c22:	00005517          	auipc	a0,0x5
    80002c26:	7be50513          	addi	a0,a0,1982 # 800083e0 <states.1714+0x130>
    80002c2a:	ffffe097          	auipc	ra,0xffffe
    80002c2e:	91e080e7          	jalr	-1762(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c32:	fffff097          	auipc	ra,0xfffff
    80002c36:	038080e7          	jalr	56(ra) # 80001c6a <myproc>
    80002c3a:	d541                	beqz	a0,80002bc2 <kerneltrap+0x38>
    80002c3c:	fffff097          	auipc	ra,0xfffff
    80002c40:	02e080e7          	jalr	46(ra) # 80001c6a <myproc>
    80002c44:	4d18                	lw	a4,24(a0)
    80002c46:	478d                	li	a5,3
    80002c48:	f6f71de3          	bne	a4,a5,80002bc2 <kerneltrap+0x38>
    yield();
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	7f2080e7          	jalr	2034(ra) # 8000243e <yield>
    80002c54:	b7bd                	j	80002bc2 <kerneltrap+0x38>

0000000080002c56 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c56:	1101                	addi	sp,sp,-32
    80002c58:	ec06                	sd	ra,24(sp)
    80002c5a:	e822                	sd	s0,16(sp)
    80002c5c:	e426                	sd	s1,8(sp)
    80002c5e:	1000                	addi	s0,sp,32
    80002c60:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c62:	fffff097          	auipc	ra,0xfffff
    80002c66:	008080e7          	jalr	8(ra) # 80001c6a <myproc>
  switch (n) {
    80002c6a:	4795                	li	a5,5
    80002c6c:	0497e163          	bltu	a5,s1,80002cae <argraw+0x58>
    80002c70:	048a                	slli	s1,s1,0x2
    80002c72:	00005717          	auipc	a4,0x5
    80002c76:	7a670713          	addi	a4,a4,1958 # 80008418 <states.1714+0x168>
    80002c7a:	94ba                	add	s1,s1,a4
    80002c7c:	409c                	lw	a5,0(s1)
    80002c7e:	97ba                	add	a5,a5,a4
    80002c80:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c82:	6d3c                	ld	a5,88(a0)
    80002c84:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c86:	60e2                	ld	ra,24(sp)
    80002c88:	6442                	ld	s0,16(sp)
    80002c8a:	64a2                	ld	s1,8(sp)
    80002c8c:	6105                	addi	sp,sp,32
    80002c8e:	8082                	ret
    return p->trapframe->a1;
    80002c90:	6d3c                	ld	a5,88(a0)
    80002c92:	7fa8                	ld	a0,120(a5)
    80002c94:	bfcd                	j	80002c86 <argraw+0x30>
    return p->trapframe->a2;
    80002c96:	6d3c                	ld	a5,88(a0)
    80002c98:	63c8                	ld	a0,128(a5)
    80002c9a:	b7f5                	j	80002c86 <argraw+0x30>
    return p->trapframe->a3;
    80002c9c:	6d3c                	ld	a5,88(a0)
    80002c9e:	67c8                	ld	a0,136(a5)
    80002ca0:	b7dd                	j	80002c86 <argraw+0x30>
    return p->trapframe->a4;
    80002ca2:	6d3c                	ld	a5,88(a0)
    80002ca4:	6bc8                	ld	a0,144(a5)
    80002ca6:	b7c5                	j	80002c86 <argraw+0x30>
    return p->trapframe->a5;
    80002ca8:	6d3c                	ld	a5,88(a0)
    80002caa:	6fc8                	ld	a0,152(a5)
    80002cac:	bfe9                	j	80002c86 <argraw+0x30>
  panic("argraw");
    80002cae:	00005517          	auipc	a0,0x5
    80002cb2:	74250513          	addi	a0,a0,1858 # 800083f0 <states.1714+0x140>
    80002cb6:	ffffe097          	auipc	ra,0xffffe
    80002cba:	892080e7          	jalr	-1902(ra) # 80000548 <panic>

0000000080002cbe <fetchaddr>:
{
    80002cbe:	1101                	addi	sp,sp,-32
    80002cc0:	ec06                	sd	ra,24(sp)
    80002cc2:	e822                	sd	s0,16(sp)
    80002cc4:	e426                	sd	s1,8(sp)
    80002cc6:	e04a                	sd	s2,0(sp)
    80002cc8:	1000                	addi	s0,sp,32
    80002cca:	84aa                	mv	s1,a0
    80002ccc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	f9c080e7          	jalr	-100(ra) # 80001c6a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002cd6:	653c                	ld	a5,72(a0)
    80002cd8:	02f4f863          	bgeu	s1,a5,80002d08 <fetchaddr+0x4a>
    80002cdc:	00848713          	addi	a4,s1,8
    80002ce0:	02e7e663          	bltu	a5,a4,80002d0c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ce4:	46a1                	li	a3,8
    80002ce6:	8626                	mv	a2,s1
    80002ce8:	85ca                	mv	a1,s2
    80002cea:	6928                	ld	a0,80(a0)
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	cfe080e7          	jalr	-770(ra) # 800019ea <copyin>
    80002cf4:	00a03533          	snez	a0,a0
    80002cf8:	40a00533          	neg	a0,a0
}
    80002cfc:	60e2                	ld	ra,24(sp)
    80002cfe:	6442                	ld	s0,16(sp)
    80002d00:	64a2                	ld	s1,8(sp)
    80002d02:	6902                	ld	s2,0(sp)
    80002d04:	6105                	addi	sp,sp,32
    80002d06:	8082                	ret
    return -1;
    80002d08:	557d                	li	a0,-1
    80002d0a:	bfcd                	j	80002cfc <fetchaddr+0x3e>
    80002d0c:	557d                	li	a0,-1
    80002d0e:	b7fd                	j	80002cfc <fetchaddr+0x3e>

0000000080002d10 <fetchstr>:
{
    80002d10:	7179                	addi	sp,sp,-48
    80002d12:	f406                	sd	ra,40(sp)
    80002d14:	f022                	sd	s0,32(sp)
    80002d16:	ec26                	sd	s1,24(sp)
    80002d18:	e84a                	sd	s2,16(sp)
    80002d1a:	e44e                	sd	s3,8(sp)
    80002d1c:	1800                	addi	s0,sp,48
    80002d1e:	892a                	mv	s2,a0
    80002d20:	84ae                	mv	s1,a1
    80002d22:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d24:	fffff097          	auipc	ra,0xfffff
    80002d28:	f46080e7          	jalr	-186(ra) # 80001c6a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d2c:	86ce                	mv	a3,s3
    80002d2e:	864a                	mv	a2,s2
    80002d30:	85a6                	mv	a1,s1
    80002d32:	6928                	ld	a0,80(a0)
    80002d34:	fffff097          	auipc	ra,0xfffff
    80002d38:	d42080e7          	jalr	-702(ra) # 80001a76 <copyinstr>
  if(err < 0)
    80002d3c:	00054763          	bltz	a0,80002d4a <fetchstr+0x3a>
  return strlen(buf);
    80002d40:	8526                	mv	a0,s1
    80002d42:	ffffe097          	auipc	ra,0xffffe
    80002d46:	3cc080e7          	jalr	972(ra) # 8000110e <strlen>
}
    80002d4a:	70a2                	ld	ra,40(sp)
    80002d4c:	7402                	ld	s0,32(sp)
    80002d4e:	64e2                	ld	s1,24(sp)
    80002d50:	6942                	ld	s2,16(sp)
    80002d52:	69a2                	ld	s3,8(sp)
    80002d54:	6145                	addi	sp,sp,48
    80002d56:	8082                	ret

0000000080002d58 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d58:	1101                	addi	sp,sp,-32
    80002d5a:	ec06                	sd	ra,24(sp)
    80002d5c:	e822                	sd	s0,16(sp)
    80002d5e:	e426                	sd	s1,8(sp)
    80002d60:	1000                	addi	s0,sp,32
    80002d62:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d64:	00000097          	auipc	ra,0x0
    80002d68:	ef2080e7          	jalr	-270(ra) # 80002c56 <argraw>
    80002d6c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d6e:	4501                	li	a0,0
    80002d70:	60e2                	ld	ra,24(sp)
    80002d72:	6442                	ld	s0,16(sp)
    80002d74:	64a2                	ld	s1,8(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret

0000000080002d7a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d7a:	1101                	addi	sp,sp,-32
    80002d7c:	ec06                	sd	ra,24(sp)
    80002d7e:	e822                	sd	s0,16(sp)
    80002d80:	e426                	sd	s1,8(sp)
    80002d82:	1000                	addi	s0,sp,32
    80002d84:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d86:	00000097          	auipc	ra,0x0
    80002d8a:	ed0080e7          	jalr	-304(ra) # 80002c56 <argraw>
    80002d8e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d90:	4501                	li	a0,0
    80002d92:	60e2                	ld	ra,24(sp)
    80002d94:	6442                	ld	s0,16(sp)
    80002d96:	64a2                	ld	s1,8(sp)
    80002d98:	6105                	addi	sp,sp,32
    80002d9a:	8082                	ret

0000000080002d9c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d9c:	1101                	addi	sp,sp,-32
    80002d9e:	ec06                	sd	ra,24(sp)
    80002da0:	e822                	sd	s0,16(sp)
    80002da2:	e426                	sd	s1,8(sp)
    80002da4:	e04a                	sd	s2,0(sp)
    80002da6:	1000                	addi	s0,sp,32
    80002da8:	84ae                	mv	s1,a1
    80002daa:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002dac:	00000097          	auipc	ra,0x0
    80002db0:	eaa080e7          	jalr	-342(ra) # 80002c56 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002db4:	864a                	mv	a2,s2
    80002db6:	85a6                	mv	a1,s1
    80002db8:	00000097          	auipc	ra,0x0
    80002dbc:	f58080e7          	jalr	-168(ra) # 80002d10 <fetchstr>
}
    80002dc0:	60e2                	ld	ra,24(sp)
    80002dc2:	6442                	ld	s0,16(sp)
    80002dc4:	64a2                	ld	s1,8(sp)
    80002dc6:	6902                	ld	s2,0(sp)
    80002dc8:	6105                	addi	sp,sp,32
    80002dca:	8082                	ret

0000000080002dcc <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002dcc:	1101                	addi	sp,sp,-32
    80002dce:	ec06                	sd	ra,24(sp)
    80002dd0:	e822                	sd	s0,16(sp)
    80002dd2:	e426                	sd	s1,8(sp)
    80002dd4:	e04a                	sd	s2,0(sp)
    80002dd6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	e92080e7          	jalr	-366(ra) # 80001c6a <myproc>
    80002de0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002de2:	05853903          	ld	s2,88(a0)
    80002de6:	0a893783          	ld	a5,168(s2)
    80002dea:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dee:	37fd                	addiw	a5,a5,-1
    80002df0:	4751                	li	a4,20
    80002df2:	00f76f63          	bltu	a4,a5,80002e10 <syscall+0x44>
    80002df6:	00369713          	slli	a4,a3,0x3
    80002dfa:	00005797          	auipc	a5,0x5
    80002dfe:	63678793          	addi	a5,a5,1590 # 80008430 <syscalls>
    80002e02:	97ba                	add	a5,a5,a4
    80002e04:	639c                	ld	a5,0(a5)
    80002e06:	c789                	beqz	a5,80002e10 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e08:	9782                	jalr	a5
    80002e0a:	06a93823          	sd	a0,112(s2)
    80002e0e:	a839                	j	80002e2c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e10:	15848613          	addi	a2,s1,344
    80002e14:	5c8c                	lw	a1,56(s1)
    80002e16:	00005517          	auipc	a0,0x5
    80002e1a:	5e250513          	addi	a0,a0,1506 # 800083f8 <states.1714+0x148>
    80002e1e:	ffffd097          	auipc	ra,0xffffd
    80002e22:	774080e7          	jalr	1908(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e26:	6cbc                	ld	a5,88(s1)
    80002e28:	577d                	li	a4,-1
    80002e2a:	fbb8                	sd	a4,112(a5)
  }
}
    80002e2c:	60e2                	ld	ra,24(sp)
    80002e2e:	6442                	ld	s0,16(sp)
    80002e30:	64a2                	ld	s1,8(sp)
    80002e32:	6902                	ld	s2,0(sp)
    80002e34:	6105                	addi	sp,sp,32
    80002e36:	8082                	ret

0000000080002e38 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e38:	1101                	addi	sp,sp,-32
    80002e3a:	ec06                	sd	ra,24(sp)
    80002e3c:	e822                	sd	s0,16(sp)
    80002e3e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e40:	fec40593          	addi	a1,s0,-20
    80002e44:	4501                	li	a0,0
    80002e46:	00000097          	auipc	ra,0x0
    80002e4a:	f12080e7          	jalr	-238(ra) # 80002d58 <argint>
    return -1;
    80002e4e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e50:	00054963          	bltz	a0,80002e62 <sys_exit+0x2a>
  exit(n);
    80002e54:	fec42503          	lw	a0,-20(s0)
    80002e58:	fffff097          	auipc	ra,0xfffff
    80002e5c:	4dc080e7          	jalr	1244(ra) # 80002334 <exit>
  return 0;  // not reached
    80002e60:	4781                	li	a5,0
}
    80002e62:	853e                	mv	a0,a5
    80002e64:	60e2                	ld	ra,24(sp)
    80002e66:	6442                	ld	s0,16(sp)
    80002e68:	6105                	addi	sp,sp,32
    80002e6a:	8082                	ret

0000000080002e6c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e6c:	1141                	addi	sp,sp,-16
    80002e6e:	e406                	sd	ra,8(sp)
    80002e70:	e022                	sd	s0,0(sp)
    80002e72:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e74:	fffff097          	auipc	ra,0xfffff
    80002e78:	df6080e7          	jalr	-522(ra) # 80001c6a <myproc>
}
    80002e7c:	5d08                	lw	a0,56(a0)
    80002e7e:	60a2                	ld	ra,8(sp)
    80002e80:	6402                	ld	s0,0(sp)
    80002e82:	0141                	addi	sp,sp,16
    80002e84:	8082                	ret

0000000080002e86 <sys_fork>:

uint64
sys_fork(void)
{
    80002e86:	1141                	addi	sp,sp,-16
    80002e88:	e406                	sd	ra,8(sp)
    80002e8a:	e022                	sd	s0,0(sp)
    80002e8c:	0800                	addi	s0,sp,16
  return fork();
    80002e8e:	fffff097          	auipc	ra,0xfffff
    80002e92:	19c080e7          	jalr	412(ra) # 8000202a <fork>
}
    80002e96:	60a2                	ld	ra,8(sp)
    80002e98:	6402                	ld	s0,0(sp)
    80002e9a:	0141                	addi	sp,sp,16
    80002e9c:	8082                	ret

0000000080002e9e <sys_wait>:

uint64
sys_wait(void)
{
    80002e9e:	1101                	addi	sp,sp,-32
    80002ea0:	ec06                	sd	ra,24(sp)
    80002ea2:	e822                	sd	s0,16(sp)
    80002ea4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002ea6:	fe840593          	addi	a1,s0,-24
    80002eaa:	4501                	li	a0,0
    80002eac:	00000097          	auipc	ra,0x0
    80002eb0:	ece080e7          	jalr	-306(ra) # 80002d7a <argaddr>
    80002eb4:	87aa                	mv	a5,a0
    return -1;
    80002eb6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002eb8:	0007c863          	bltz	a5,80002ec8 <sys_wait+0x2a>
  return wait(p);
    80002ebc:	fe843503          	ld	a0,-24(s0)
    80002ec0:	fffff097          	auipc	ra,0xfffff
    80002ec4:	638080e7          	jalr	1592(ra) # 800024f8 <wait>
}
    80002ec8:	60e2                	ld	ra,24(sp)
    80002eca:	6442                	ld	s0,16(sp)
    80002ecc:	6105                	addi	sp,sp,32
    80002ece:	8082                	ret

0000000080002ed0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ed0:	7179                	addi	sp,sp,-48
    80002ed2:	f406                	sd	ra,40(sp)
    80002ed4:	f022                	sd	s0,32(sp)
    80002ed6:	ec26                	sd	s1,24(sp)
    80002ed8:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002eda:	fdc40593          	addi	a1,s0,-36
    80002ede:	4501                	li	a0,0
    80002ee0:	00000097          	auipc	ra,0x0
    80002ee4:	e78080e7          	jalr	-392(ra) # 80002d58 <argint>
    80002ee8:	87aa                	mv	a5,a0
    return -1;
    80002eea:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002eec:	0207c063          	bltz	a5,80002f0c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002ef0:	fffff097          	auipc	ra,0xfffff
    80002ef4:	d7a080e7          	jalr	-646(ra) # 80001c6a <myproc>
    80002ef8:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002efa:	fdc42503          	lw	a0,-36(s0)
    80002efe:	fffff097          	auipc	ra,0xfffff
    80002f02:	0b8080e7          	jalr	184(ra) # 80001fb6 <growproc>
    80002f06:	00054863          	bltz	a0,80002f16 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002f0a:	8526                	mv	a0,s1
}
    80002f0c:	70a2                	ld	ra,40(sp)
    80002f0e:	7402                	ld	s0,32(sp)
    80002f10:	64e2                	ld	s1,24(sp)
    80002f12:	6145                	addi	sp,sp,48
    80002f14:	8082                	ret
    return -1;
    80002f16:	557d                	li	a0,-1
    80002f18:	bfd5                	j	80002f0c <sys_sbrk+0x3c>

0000000080002f1a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f1a:	7139                	addi	sp,sp,-64
    80002f1c:	fc06                	sd	ra,56(sp)
    80002f1e:	f822                	sd	s0,48(sp)
    80002f20:	f426                	sd	s1,40(sp)
    80002f22:	f04a                	sd	s2,32(sp)
    80002f24:	ec4e                	sd	s3,24(sp)
    80002f26:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f28:	fcc40593          	addi	a1,s0,-52
    80002f2c:	4501                	li	a0,0
    80002f2e:	00000097          	auipc	ra,0x0
    80002f32:	e2a080e7          	jalr	-470(ra) # 80002d58 <argint>
    return -1;
    80002f36:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f38:	06054563          	bltz	a0,80002fa2 <sys_sleep+0x88>
  acquire(&tickslock);
    80002f3c:	01115517          	auipc	a0,0x1115
    80002f40:	82c50513          	addi	a0,a0,-2004 # 81117768 <tickslock>
    80002f44:	ffffe097          	auipc	ra,0xffffe
    80002f48:	f46080e7          	jalr	-186(ra) # 80000e8a <acquire>
  ticks0 = ticks;
    80002f4c:	00006917          	auipc	s2,0x6
    80002f50:	0d492903          	lw	s2,212(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002f54:	fcc42783          	lw	a5,-52(s0)
    80002f58:	cf85                	beqz	a5,80002f90 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f5a:	01115997          	auipc	s3,0x1115
    80002f5e:	80e98993          	addi	s3,s3,-2034 # 81117768 <tickslock>
    80002f62:	00006497          	auipc	s1,0x6
    80002f66:	0be48493          	addi	s1,s1,190 # 80009020 <ticks>
    if(myproc()->killed){
    80002f6a:	fffff097          	auipc	ra,0xfffff
    80002f6e:	d00080e7          	jalr	-768(ra) # 80001c6a <myproc>
    80002f72:	591c                	lw	a5,48(a0)
    80002f74:	ef9d                	bnez	a5,80002fb2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002f76:	85ce                	mv	a1,s3
    80002f78:	8526                	mv	a0,s1
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	500080e7          	jalr	1280(ra) # 8000247a <sleep>
  while(ticks - ticks0 < n){
    80002f82:	409c                	lw	a5,0(s1)
    80002f84:	412787bb          	subw	a5,a5,s2
    80002f88:	fcc42703          	lw	a4,-52(s0)
    80002f8c:	fce7efe3          	bltu	a5,a4,80002f6a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002f90:	01114517          	auipc	a0,0x1114
    80002f94:	7d850513          	addi	a0,a0,2008 # 81117768 <tickslock>
    80002f98:	ffffe097          	auipc	ra,0xffffe
    80002f9c:	fa6080e7          	jalr	-90(ra) # 80000f3e <release>
  return 0;
    80002fa0:	4781                	li	a5,0
}
    80002fa2:	853e                	mv	a0,a5
    80002fa4:	70e2                	ld	ra,56(sp)
    80002fa6:	7442                	ld	s0,48(sp)
    80002fa8:	74a2                	ld	s1,40(sp)
    80002faa:	7902                	ld	s2,32(sp)
    80002fac:	69e2                	ld	s3,24(sp)
    80002fae:	6121                	addi	sp,sp,64
    80002fb0:	8082                	ret
      release(&tickslock);
    80002fb2:	01114517          	auipc	a0,0x1114
    80002fb6:	7b650513          	addi	a0,a0,1974 # 81117768 <tickslock>
    80002fba:	ffffe097          	auipc	ra,0xffffe
    80002fbe:	f84080e7          	jalr	-124(ra) # 80000f3e <release>
      return -1;
    80002fc2:	57fd                	li	a5,-1
    80002fc4:	bff9                	j	80002fa2 <sys_sleep+0x88>

0000000080002fc6 <sys_kill>:

uint64
sys_kill(void)
{
    80002fc6:	1101                	addi	sp,sp,-32
    80002fc8:	ec06                	sd	ra,24(sp)
    80002fca:	e822                	sd	s0,16(sp)
    80002fcc:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002fce:	fec40593          	addi	a1,s0,-20
    80002fd2:	4501                	li	a0,0
    80002fd4:	00000097          	auipc	ra,0x0
    80002fd8:	d84080e7          	jalr	-636(ra) # 80002d58 <argint>
    80002fdc:	87aa                	mv	a5,a0
    return -1;
    80002fde:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002fe0:	0007c863          	bltz	a5,80002ff0 <sys_kill+0x2a>
  return kill(pid);
    80002fe4:	fec42503          	lw	a0,-20(s0)
    80002fe8:	fffff097          	auipc	ra,0xfffff
    80002fec:	682080e7          	jalr	1666(ra) # 8000266a <kill>
}
    80002ff0:	60e2                	ld	ra,24(sp)
    80002ff2:	6442                	ld	s0,16(sp)
    80002ff4:	6105                	addi	sp,sp,32
    80002ff6:	8082                	ret

0000000080002ff8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ff8:	1101                	addi	sp,sp,-32
    80002ffa:	ec06                	sd	ra,24(sp)
    80002ffc:	e822                	sd	s0,16(sp)
    80002ffe:	e426                	sd	s1,8(sp)
    80003000:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003002:	01114517          	auipc	a0,0x1114
    80003006:	76650513          	addi	a0,a0,1894 # 81117768 <tickslock>
    8000300a:	ffffe097          	auipc	ra,0xffffe
    8000300e:	e80080e7          	jalr	-384(ra) # 80000e8a <acquire>
  xticks = ticks;
    80003012:	00006497          	auipc	s1,0x6
    80003016:	00e4a483          	lw	s1,14(s1) # 80009020 <ticks>
  release(&tickslock);
    8000301a:	01114517          	auipc	a0,0x1114
    8000301e:	74e50513          	addi	a0,a0,1870 # 81117768 <tickslock>
    80003022:	ffffe097          	auipc	ra,0xffffe
    80003026:	f1c080e7          	jalr	-228(ra) # 80000f3e <release>
  return xticks;
}
    8000302a:	02049513          	slli	a0,s1,0x20
    8000302e:	9101                	srli	a0,a0,0x20
    80003030:	60e2                	ld	ra,24(sp)
    80003032:	6442                	ld	s0,16(sp)
    80003034:	64a2                	ld	s1,8(sp)
    80003036:	6105                	addi	sp,sp,32
    80003038:	8082                	ret

000000008000303a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000303a:	7179                	addi	sp,sp,-48
    8000303c:	f406                	sd	ra,40(sp)
    8000303e:	f022                	sd	s0,32(sp)
    80003040:	ec26                	sd	s1,24(sp)
    80003042:	e84a                	sd	s2,16(sp)
    80003044:	e44e                	sd	s3,8(sp)
    80003046:	e052                	sd	s4,0(sp)
    80003048:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000304a:	00005597          	auipc	a1,0x5
    8000304e:	49658593          	addi	a1,a1,1174 # 800084e0 <syscalls+0xb0>
    80003052:	01114517          	auipc	a0,0x1114
    80003056:	72e50513          	addi	a0,a0,1838 # 81117780 <bcache>
    8000305a:	ffffe097          	auipc	ra,0xffffe
    8000305e:	da0080e7          	jalr	-608(ra) # 80000dfa <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003062:	0111c797          	auipc	a5,0x111c
    80003066:	71e78793          	addi	a5,a5,1822 # 8111f780 <bcache+0x8000>
    8000306a:	0111d717          	auipc	a4,0x111d
    8000306e:	97e70713          	addi	a4,a4,-1666 # 8111f9e8 <bcache+0x8268>
    80003072:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003076:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000307a:	01114497          	auipc	s1,0x1114
    8000307e:	71e48493          	addi	s1,s1,1822 # 81117798 <bcache+0x18>
    b->next = bcache.head.next;
    80003082:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003084:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003086:	00005a17          	auipc	s4,0x5
    8000308a:	462a0a13          	addi	s4,s4,1122 # 800084e8 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000308e:	2b893783          	ld	a5,696(s2)
    80003092:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003094:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003098:	85d2                	mv	a1,s4
    8000309a:	01048513          	addi	a0,s1,16
    8000309e:	00001097          	auipc	ra,0x1
    800030a2:	4b0080e7          	jalr	1200(ra) # 8000454e <initsleeplock>
    bcache.head.next->prev = b;
    800030a6:	2b893783          	ld	a5,696(s2)
    800030aa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030ac:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030b0:	45848493          	addi	s1,s1,1112
    800030b4:	fd349de3          	bne	s1,s3,8000308e <binit+0x54>
  }
}
    800030b8:	70a2                	ld	ra,40(sp)
    800030ba:	7402                	ld	s0,32(sp)
    800030bc:	64e2                	ld	s1,24(sp)
    800030be:	6942                	ld	s2,16(sp)
    800030c0:	69a2                	ld	s3,8(sp)
    800030c2:	6a02                	ld	s4,0(sp)
    800030c4:	6145                	addi	sp,sp,48
    800030c6:	8082                	ret

00000000800030c8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030c8:	7179                	addi	sp,sp,-48
    800030ca:	f406                	sd	ra,40(sp)
    800030cc:	f022                	sd	s0,32(sp)
    800030ce:	ec26                	sd	s1,24(sp)
    800030d0:	e84a                	sd	s2,16(sp)
    800030d2:	e44e                	sd	s3,8(sp)
    800030d4:	1800                	addi	s0,sp,48
    800030d6:	89aa                	mv	s3,a0
    800030d8:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800030da:	01114517          	auipc	a0,0x1114
    800030de:	6a650513          	addi	a0,a0,1702 # 81117780 <bcache>
    800030e2:	ffffe097          	auipc	ra,0xffffe
    800030e6:	da8080e7          	jalr	-600(ra) # 80000e8a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030ea:	0111d497          	auipc	s1,0x111d
    800030ee:	94e4b483          	ld	s1,-1714(s1) # 8111fa38 <bcache+0x82b8>
    800030f2:	0111d797          	auipc	a5,0x111d
    800030f6:	8f678793          	addi	a5,a5,-1802 # 8111f9e8 <bcache+0x8268>
    800030fa:	02f48f63          	beq	s1,a5,80003138 <bread+0x70>
    800030fe:	873e                	mv	a4,a5
    80003100:	a021                	j	80003108 <bread+0x40>
    80003102:	68a4                	ld	s1,80(s1)
    80003104:	02e48a63          	beq	s1,a4,80003138 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003108:	449c                	lw	a5,8(s1)
    8000310a:	ff379ce3          	bne	a5,s3,80003102 <bread+0x3a>
    8000310e:	44dc                	lw	a5,12(s1)
    80003110:	ff2799e3          	bne	a5,s2,80003102 <bread+0x3a>
      b->refcnt++;
    80003114:	40bc                	lw	a5,64(s1)
    80003116:	2785                	addiw	a5,a5,1
    80003118:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000311a:	01114517          	auipc	a0,0x1114
    8000311e:	66650513          	addi	a0,a0,1638 # 81117780 <bcache>
    80003122:	ffffe097          	auipc	ra,0xffffe
    80003126:	e1c080e7          	jalr	-484(ra) # 80000f3e <release>
      acquiresleep(&b->lock);
    8000312a:	01048513          	addi	a0,s1,16
    8000312e:	00001097          	auipc	ra,0x1
    80003132:	45a080e7          	jalr	1114(ra) # 80004588 <acquiresleep>
      return b;
    80003136:	a8b9                	j	80003194 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003138:	0111d497          	auipc	s1,0x111d
    8000313c:	8f84b483          	ld	s1,-1800(s1) # 8111fa30 <bcache+0x82b0>
    80003140:	0111d797          	auipc	a5,0x111d
    80003144:	8a878793          	addi	a5,a5,-1880 # 8111f9e8 <bcache+0x8268>
    80003148:	00f48863          	beq	s1,a5,80003158 <bread+0x90>
    8000314c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000314e:	40bc                	lw	a5,64(s1)
    80003150:	cf81                	beqz	a5,80003168 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003152:	64a4                	ld	s1,72(s1)
    80003154:	fee49de3          	bne	s1,a4,8000314e <bread+0x86>
  panic("bget: no buffers");
    80003158:	00005517          	auipc	a0,0x5
    8000315c:	39850513          	addi	a0,a0,920 # 800084f0 <syscalls+0xc0>
    80003160:	ffffd097          	auipc	ra,0xffffd
    80003164:	3e8080e7          	jalr	1000(ra) # 80000548 <panic>
      b->dev = dev;
    80003168:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000316c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003170:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003174:	4785                	li	a5,1
    80003176:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003178:	01114517          	auipc	a0,0x1114
    8000317c:	60850513          	addi	a0,a0,1544 # 81117780 <bcache>
    80003180:	ffffe097          	auipc	ra,0xffffe
    80003184:	dbe080e7          	jalr	-578(ra) # 80000f3e <release>
      acquiresleep(&b->lock);
    80003188:	01048513          	addi	a0,s1,16
    8000318c:	00001097          	auipc	ra,0x1
    80003190:	3fc080e7          	jalr	1020(ra) # 80004588 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003194:	409c                	lw	a5,0(s1)
    80003196:	cb89                	beqz	a5,800031a8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003198:	8526                	mv	a0,s1
    8000319a:	70a2                	ld	ra,40(sp)
    8000319c:	7402                	ld	s0,32(sp)
    8000319e:	64e2                	ld	s1,24(sp)
    800031a0:	6942                	ld	s2,16(sp)
    800031a2:	69a2                	ld	s3,8(sp)
    800031a4:	6145                	addi	sp,sp,48
    800031a6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031a8:	4581                	li	a1,0
    800031aa:	8526                	mv	a0,s1
    800031ac:	00003097          	auipc	ra,0x3
    800031b0:	f30080e7          	jalr	-208(ra) # 800060dc <virtio_disk_rw>
    b->valid = 1;
    800031b4:	4785                	li	a5,1
    800031b6:	c09c                	sw	a5,0(s1)
  return b;
    800031b8:	b7c5                	j	80003198 <bread+0xd0>

00000000800031ba <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031ba:	1101                	addi	sp,sp,-32
    800031bc:	ec06                	sd	ra,24(sp)
    800031be:	e822                	sd	s0,16(sp)
    800031c0:	e426                	sd	s1,8(sp)
    800031c2:	1000                	addi	s0,sp,32
    800031c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031c6:	0541                	addi	a0,a0,16
    800031c8:	00001097          	auipc	ra,0x1
    800031cc:	45a080e7          	jalr	1114(ra) # 80004622 <holdingsleep>
    800031d0:	cd01                	beqz	a0,800031e8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031d2:	4585                	li	a1,1
    800031d4:	8526                	mv	a0,s1
    800031d6:	00003097          	auipc	ra,0x3
    800031da:	f06080e7          	jalr	-250(ra) # 800060dc <virtio_disk_rw>
}
    800031de:	60e2                	ld	ra,24(sp)
    800031e0:	6442                	ld	s0,16(sp)
    800031e2:	64a2                	ld	s1,8(sp)
    800031e4:	6105                	addi	sp,sp,32
    800031e6:	8082                	ret
    panic("bwrite");
    800031e8:	00005517          	auipc	a0,0x5
    800031ec:	32050513          	addi	a0,a0,800 # 80008508 <syscalls+0xd8>
    800031f0:	ffffd097          	auipc	ra,0xffffd
    800031f4:	358080e7          	jalr	856(ra) # 80000548 <panic>

00000000800031f8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031f8:	1101                	addi	sp,sp,-32
    800031fa:	ec06                	sd	ra,24(sp)
    800031fc:	e822                	sd	s0,16(sp)
    800031fe:	e426                	sd	s1,8(sp)
    80003200:	e04a                	sd	s2,0(sp)
    80003202:	1000                	addi	s0,sp,32
    80003204:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003206:	01050913          	addi	s2,a0,16
    8000320a:	854a                	mv	a0,s2
    8000320c:	00001097          	auipc	ra,0x1
    80003210:	416080e7          	jalr	1046(ra) # 80004622 <holdingsleep>
    80003214:	c92d                	beqz	a0,80003286 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003216:	854a                	mv	a0,s2
    80003218:	00001097          	auipc	ra,0x1
    8000321c:	3c6080e7          	jalr	966(ra) # 800045de <releasesleep>

  acquire(&bcache.lock);
    80003220:	01114517          	auipc	a0,0x1114
    80003224:	56050513          	addi	a0,a0,1376 # 81117780 <bcache>
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	c62080e7          	jalr	-926(ra) # 80000e8a <acquire>
  b->refcnt--;
    80003230:	40bc                	lw	a5,64(s1)
    80003232:	37fd                	addiw	a5,a5,-1
    80003234:	0007871b          	sext.w	a4,a5
    80003238:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000323a:	eb05                	bnez	a4,8000326a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000323c:	68bc                	ld	a5,80(s1)
    8000323e:	64b8                	ld	a4,72(s1)
    80003240:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003242:	64bc                	ld	a5,72(s1)
    80003244:	68b8                	ld	a4,80(s1)
    80003246:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003248:	0111c797          	auipc	a5,0x111c
    8000324c:	53878793          	addi	a5,a5,1336 # 8111f780 <bcache+0x8000>
    80003250:	2b87b703          	ld	a4,696(a5)
    80003254:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003256:	0111c717          	auipc	a4,0x111c
    8000325a:	79270713          	addi	a4,a4,1938 # 8111f9e8 <bcache+0x8268>
    8000325e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003260:	2b87b703          	ld	a4,696(a5)
    80003264:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003266:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000326a:	01114517          	auipc	a0,0x1114
    8000326e:	51650513          	addi	a0,a0,1302 # 81117780 <bcache>
    80003272:	ffffe097          	auipc	ra,0xffffe
    80003276:	ccc080e7          	jalr	-820(ra) # 80000f3e <release>
}
    8000327a:	60e2                	ld	ra,24(sp)
    8000327c:	6442                	ld	s0,16(sp)
    8000327e:	64a2                	ld	s1,8(sp)
    80003280:	6902                	ld	s2,0(sp)
    80003282:	6105                	addi	sp,sp,32
    80003284:	8082                	ret
    panic("brelse");
    80003286:	00005517          	auipc	a0,0x5
    8000328a:	28a50513          	addi	a0,a0,650 # 80008510 <syscalls+0xe0>
    8000328e:	ffffd097          	auipc	ra,0xffffd
    80003292:	2ba080e7          	jalr	698(ra) # 80000548 <panic>

0000000080003296 <bpin>:

void
bpin(struct buf *b) {
    80003296:	1101                	addi	sp,sp,-32
    80003298:	ec06                	sd	ra,24(sp)
    8000329a:	e822                	sd	s0,16(sp)
    8000329c:	e426                	sd	s1,8(sp)
    8000329e:	1000                	addi	s0,sp,32
    800032a0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032a2:	01114517          	auipc	a0,0x1114
    800032a6:	4de50513          	addi	a0,a0,1246 # 81117780 <bcache>
    800032aa:	ffffe097          	auipc	ra,0xffffe
    800032ae:	be0080e7          	jalr	-1056(ra) # 80000e8a <acquire>
  b->refcnt++;
    800032b2:	40bc                	lw	a5,64(s1)
    800032b4:	2785                	addiw	a5,a5,1
    800032b6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032b8:	01114517          	auipc	a0,0x1114
    800032bc:	4c850513          	addi	a0,a0,1224 # 81117780 <bcache>
    800032c0:	ffffe097          	auipc	ra,0xffffe
    800032c4:	c7e080e7          	jalr	-898(ra) # 80000f3e <release>
}
    800032c8:	60e2                	ld	ra,24(sp)
    800032ca:	6442                	ld	s0,16(sp)
    800032cc:	64a2                	ld	s1,8(sp)
    800032ce:	6105                	addi	sp,sp,32
    800032d0:	8082                	ret

00000000800032d2 <bunpin>:

void
bunpin(struct buf *b) {
    800032d2:	1101                	addi	sp,sp,-32
    800032d4:	ec06                	sd	ra,24(sp)
    800032d6:	e822                	sd	s0,16(sp)
    800032d8:	e426                	sd	s1,8(sp)
    800032da:	1000                	addi	s0,sp,32
    800032dc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032de:	01114517          	auipc	a0,0x1114
    800032e2:	4a250513          	addi	a0,a0,1186 # 81117780 <bcache>
    800032e6:	ffffe097          	auipc	ra,0xffffe
    800032ea:	ba4080e7          	jalr	-1116(ra) # 80000e8a <acquire>
  b->refcnt--;
    800032ee:	40bc                	lw	a5,64(s1)
    800032f0:	37fd                	addiw	a5,a5,-1
    800032f2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032f4:	01114517          	auipc	a0,0x1114
    800032f8:	48c50513          	addi	a0,a0,1164 # 81117780 <bcache>
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	c42080e7          	jalr	-958(ra) # 80000f3e <release>
}
    80003304:	60e2                	ld	ra,24(sp)
    80003306:	6442                	ld	s0,16(sp)
    80003308:	64a2                	ld	s1,8(sp)
    8000330a:	6105                	addi	sp,sp,32
    8000330c:	8082                	ret

000000008000330e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000330e:	1101                	addi	sp,sp,-32
    80003310:	ec06                	sd	ra,24(sp)
    80003312:	e822                	sd	s0,16(sp)
    80003314:	e426                	sd	s1,8(sp)
    80003316:	e04a                	sd	s2,0(sp)
    80003318:	1000                	addi	s0,sp,32
    8000331a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000331c:	00d5d59b          	srliw	a1,a1,0xd
    80003320:	0111d797          	auipc	a5,0x111d
    80003324:	b3c7a783          	lw	a5,-1220(a5) # 8111fe5c <sb+0x1c>
    80003328:	9dbd                	addw	a1,a1,a5
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	d9e080e7          	jalr	-610(ra) # 800030c8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003332:	0074f713          	andi	a4,s1,7
    80003336:	4785                	li	a5,1
    80003338:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000333c:	14ce                	slli	s1,s1,0x33
    8000333e:	90d9                	srli	s1,s1,0x36
    80003340:	00950733          	add	a4,a0,s1
    80003344:	05874703          	lbu	a4,88(a4)
    80003348:	00e7f6b3          	and	a3,a5,a4
    8000334c:	c69d                	beqz	a3,8000337a <bfree+0x6c>
    8000334e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003350:	94aa                	add	s1,s1,a0
    80003352:	fff7c793          	not	a5,a5
    80003356:	8ff9                	and	a5,a5,a4
    80003358:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000335c:	00001097          	auipc	ra,0x1
    80003360:	104080e7          	jalr	260(ra) # 80004460 <log_write>
  brelse(bp);
    80003364:	854a                	mv	a0,s2
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	e92080e7          	jalr	-366(ra) # 800031f8 <brelse>
}
    8000336e:	60e2                	ld	ra,24(sp)
    80003370:	6442                	ld	s0,16(sp)
    80003372:	64a2                	ld	s1,8(sp)
    80003374:	6902                	ld	s2,0(sp)
    80003376:	6105                	addi	sp,sp,32
    80003378:	8082                	ret
    panic("freeing free block");
    8000337a:	00005517          	auipc	a0,0x5
    8000337e:	19e50513          	addi	a0,a0,414 # 80008518 <syscalls+0xe8>
    80003382:	ffffd097          	auipc	ra,0xffffd
    80003386:	1c6080e7          	jalr	454(ra) # 80000548 <panic>

000000008000338a <balloc>:
{
    8000338a:	711d                	addi	sp,sp,-96
    8000338c:	ec86                	sd	ra,88(sp)
    8000338e:	e8a2                	sd	s0,80(sp)
    80003390:	e4a6                	sd	s1,72(sp)
    80003392:	e0ca                	sd	s2,64(sp)
    80003394:	fc4e                	sd	s3,56(sp)
    80003396:	f852                	sd	s4,48(sp)
    80003398:	f456                	sd	s5,40(sp)
    8000339a:	f05a                	sd	s6,32(sp)
    8000339c:	ec5e                	sd	s7,24(sp)
    8000339e:	e862                	sd	s8,16(sp)
    800033a0:	e466                	sd	s9,8(sp)
    800033a2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033a4:	0111d797          	auipc	a5,0x111d
    800033a8:	aa07a783          	lw	a5,-1376(a5) # 8111fe44 <sb+0x4>
    800033ac:	cbd1                	beqz	a5,80003440 <balloc+0xb6>
    800033ae:	8baa                	mv	s7,a0
    800033b0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033b2:	0111db17          	auipc	s6,0x111d
    800033b6:	a8eb0b13          	addi	s6,s6,-1394 # 8111fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033ba:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033bc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033be:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033c0:	6c89                	lui	s9,0x2
    800033c2:	a831                	j	800033de <balloc+0x54>
    brelse(bp);
    800033c4:	854a                	mv	a0,s2
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	e32080e7          	jalr	-462(ra) # 800031f8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033ce:	015c87bb          	addw	a5,s9,s5
    800033d2:	00078a9b          	sext.w	s5,a5
    800033d6:	004b2703          	lw	a4,4(s6)
    800033da:	06eaf363          	bgeu	s5,a4,80003440 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800033de:	41fad79b          	sraiw	a5,s5,0x1f
    800033e2:	0137d79b          	srliw	a5,a5,0x13
    800033e6:	015787bb          	addw	a5,a5,s5
    800033ea:	40d7d79b          	sraiw	a5,a5,0xd
    800033ee:	01cb2583          	lw	a1,28(s6)
    800033f2:	9dbd                	addw	a1,a1,a5
    800033f4:	855e                	mv	a0,s7
    800033f6:	00000097          	auipc	ra,0x0
    800033fa:	cd2080e7          	jalr	-814(ra) # 800030c8 <bread>
    800033fe:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003400:	004b2503          	lw	a0,4(s6)
    80003404:	000a849b          	sext.w	s1,s5
    80003408:	8662                	mv	a2,s8
    8000340a:	faa4fde3          	bgeu	s1,a0,800033c4 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000340e:	41f6579b          	sraiw	a5,a2,0x1f
    80003412:	01d7d69b          	srliw	a3,a5,0x1d
    80003416:	00c6873b          	addw	a4,a3,a2
    8000341a:	00777793          	andi	a5,a4,7
    8000341e:	9f95                	subw	a5,a5,a3
    80003420:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003424:	4037571b          	sraiw	a4,a4,0x3
    80003428:	00e906b3          	add	a3,s2,a4
    8000342c:	0586c683          	lbu	a3,88(a3)
    80003430:	00d7f5b3          	and	a1,a5,a3
    80003434:	cd91                	beqz	a1,80003450 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003436:	2605                	addiw	a2,a2,1
    80003438:	2485                	addiw	s1,s1,1
    8000343a:	fd4618e3          	bne	a2,s4,8000340a <balloc+0x80>
    8000343e:	b759                	j	800033c4 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003440:	00005517          	auipc	a0,0x5
    80003444:	0f050513          	addi	a0,a0,240 # 80008530 <syscalls+0x100>
    80003448:	ffffd097          	auipc	ra,0xffffd
    8000344c:	100080e7          	jalr	256(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003450:	974a                	add	a4,a4,s2
    80003452:	8fd5                	or	a5,a5,a3
    80003454:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003458:	854a                	mv	a0,s2
    8000345a:	00001097          	auipc	ra,0x1
    8000345e:	006080e7          	jalr	6(ra) # 80004460 <log_write>
        brelse(bp);
    80003462:	854a                	mv	a0,s2
    80003464:	00000097          	auipc	ra,0x0
    80003468:	d94080e7          	jalr	-620(ra) # 800031f8 <brelse>
  bp = bread(dev, bno);
    8000346c:	85a6                	mv	a1,s1
    8000346e:	855e                	mv	a0,s7
    80003470:	00000097          	auipc	ra,0x0
    80003474:	c58080e7          	jalr	-936(ra) # 800030c8 <bread>
    80003478:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000347a:	40000613          	li	a2,1024
    8000347e:	4581                	li	a1,0
    80003480:	05850513          	addi	a0,a0,88
    80003484:	ffffe097          	auipc	ra,0xffffe
    80003488:	b02080e7          	jalr	-1278(ra) # 80000f86 <memset>
  log_write(bp);
    8000348c:	854a                	mv	a0,s2
    8000348e:	00001097          	auipc	ra,0x1
    80003492:	fd2080e7          	jalr	-46(ra) # 80004460 <log_write>
  brelse(bp);
    80003496:	854a                	mv	a0,s2
    80003498:	00000097          	auipc	ra,0x0
    8000349c:	d60080e7          	jalr	-672(ra) # 800031f8 <brelse>
}
    800034a0:	8526                	mv	a0,s1
    800034a2:	60e6                	ld	ra,88(sp)
    800034a4:	6446                	ld	s0,80(sp)
    800034a6:	64a6                	ld	s1,72(sp)
    800034a8:	6906                	ld	s2,64(sp)
    800034aa:	79e2                	ld	s3,56(sp)
    800034ac:	7a42                	ld	s4,48(sp)
    800034ae:	7aa2                	ld	s5,40(sp)
    800034b0:	7b02                	ld	s6,32(sp)
    800034b2:	6be2                	ld	s7,24(sp)
    800034b4:	6c42                	ld	s8,16(sp)
    800034b6:	6ca2                	ld	s9,8(sp)
    800034b8:	6125                	addi	sp,sp,96
    800034ba:	8082                	ret

00000000800034bc <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800034bc:	7179                	addi	sp,sp,-48
    800034be:	f406                	sd	ra,40(sp)
    800034c0:	f022                	sd	s0,32(sp)
    800034c2:	ec26                	sd	s1,24(sp)
    800034c4:	e84a                	sd	s2,16(sp)
    800034c6:	e44e                	sd	s3,8(sp)
    800034c8:	e052                	sd	s4,0(sp)
    800034ca:	1800                	addi	s0,sp,48
    800034cc:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034ce:	47ad                	li	a5,11
    800034d0:	04b7fe63          	bgeu	a5,a1,8000352c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800034d4:	ff45849b          	addiw	s1,a1,-12
    800034d8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034dc:	0ff00793          	li	a5,255
    800034e0:	0ae7e363          	bltu	a5,a4,80003586 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800034e4:	08052583          	lw	a1,128(a0)
    800034e8:	c5ad                	beqz	a1,80003552 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800034ea:	00092503          	lw	a0,0(s2)
    800034ee:	00000097          	auipc	ra,0x0
    800034f2:	bda080e7          	jalr	-1062(ra) # 800030c8 <bread>
    800034f6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034f8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034fc:	02049593          	slli	a1,s1,0x20
    80003500:	9181                	srli	a1,a1,0x20
    80003502:	058a                	slli	a1,a1,0x2
    80003504:	00b784b3          	add	s1,a5,a1
    80003508:	0004a983          	lw	s3,0(s1)
    8000350c:	04098d63          	beqz	s3,80003566 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003510:	8552                	mv	a0,s4
    80003512:	00000097          	auipc	ra,0x0
    80003516:	ce6080e7          	jalr	-794(ra) # 800031f8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000351a:	854e                	mv	a0,s3
    8000351c:	70a2                	ld	ra,40(sp)
    8000351e:	7402                	ld	s0,32(sp)
    80003520:	64e2                	ld	s1,24(sp)
    80003522:	6942                	ld	s2,16(sp)
    80003524:	69a2                	ld	s3,8(sp)
    80003526:	6a02                	ld	s4,0(sp)
    80003528:	6145                	addi	sp,sp,48
    8000352a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000352c:	02059493          	slli	s1,a1,0x20
    80003530:	9081                	srli	s1,s1,0x20
    80003532:	048a                	slli	s1,s1,0x2
    80003534:	94aa                	add	s1,s1,a0
    80003536:	0504a983          	lw	s3,80(s1)
    8000353a:	fe0990e3          	bnez	s3,8000351a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000353e:	4108                	lw	a0,0(a0)
    80003540:	00000097          	auipc	ra,0x0
    80003544:	e4a080e7          	jalr	-438(ra) # 8000338a <balloc>
    80003548:	0005099b          	sext.w	s3,a0
    8000354c:	0534a823          	sw	s3,80(s1)
    80003550:	b7e9                	j	8000351a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003552:	4108                	lw	a0,0(a0)
    80003554:	00000097          	auipc	ra,0x0
    80003558:	e36080e7          	jalr	-458(ra) # 8000338a <balloc>
    8000355c:	0005059b          	sext.w	a1,a0
    80003560:	08b92023          	sw	a1,128(s2)
    80003564:	b759                	j	800034ea <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003566:	00092503          	lw	a0,0(s2)
    8000356a:	00000097          	auipc	ra,0x0
    8000356e:	e20080e7          	jalr	-480(ra) # 8000338a <balloc>
    80003572:	0005099b          	sext.w	s3,a0
    80003576:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000357a:	8552                	mv	a0,s4
    8000357c:	00001097          	auipc	ra,0x1
    80003580:	ee4080e7          	jalr	-284(ra) # 80004460 <log_write>
    80003584:	b771                	j	80003510 <bmap+0x54>
  panic("bmap: out of range");
    80003586:	00005517          	auipc	a0,0x5
    8000358a:	fc250513          	addi	a0,a0,-62 # 80008548 <syscalls+0x118>
    8000358e:	ffffd097          	auipc	ra,0xffffd
    80003592:	fba080e7          	jalr	-70(ra) # 80000548 <panic>

0000000080003596 <iget>:
{
    80003596:	7179                	addi	sp,sp,-48
    80003598:	f406                	sd	ra,40(sp)
    8000359a:	f022                	sd	s0,32(sp)
    8000359c:	ec26                	sd	s1,24(sp)
    8000359e:	e84a                	sd	s2,16(sp)
    800035a0:	e44e                	sd	s3,8(sp)
    800035a2:	e052                	sd	s4,0(sp)
    800035a4:	1800                	addi	s0,sp,48
    800035a6:	89aa                	mv	s3,a0
    800035a8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800035aa:	0111d517          	auipc	a0,0x111d
    800035ae:	8b650513          	addi	a0,a0,-1866 # 8111fe60 <icache>
    800035b2:	ffffe097          	auipc	ra,0xffffe
    800035b6:	8d8080e7          	jalr	-1832(ra) # 80000e8a <acquire>
  empty = 0;
    800035ba:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035bc:	0111d497          	auipc	s1,0x111d
    800035c0:	8bc48493          	addi	s1,s1,-1860 # 8111fe78 <icache+0x18>
    800035c4:	0111e697          	auipc	a3,0x111e
    800035c8:	34468693          	addi	a3,a3,836 # 81121908 <log>
    800035cc:	a039                	j	800035da <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ce:	02090b63          	beqz	s2,80003604 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035d2:	08848493          	addi	s1,s1,136
    800035d6:	02d48a63          	beq	s1,a3,8000360a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035da:	449c                	lw	a5,8(s1)
    800035dc:	fef059e3          	blez	a5,800035ce <iget+0x38>
    800035e0:	4098                	lw	a4,0(s1)
    800035e2:	ff3716e3          	bne	a4,s3,800035ce <iget+0x38>
    800035e6:	40d8                	lw	a4,4(s1)
    800035e8:	ff4713e3          	bne	a4,s4,800035ce <iget+0x38>
      ip->ref++;
    800035ec:	2785                	addiw	a5,a5,1
    800035ee:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800035f0:	0111d517          	auipc	a0,0x111d
    800035f4:	87050513          	addi	a0,a0,-1936 # 8111fe60 <icache>
    800035f8:	ffffe097          	auipc	ra,0xffffe
    800035fc:	946080e7          	jalr	-1722(ra) # 80000f3e <release>
      return ip;
    80003600:	8926                	mv	s2,s1
    80003602:	a03d                	j	80003630 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003604:	f7f9                	bnez	a5,800035d2 <iget+0x3c>
    80003606:	8926                	mv	s2,s1
    80003608:	b7e9                	j	800035d2 <iget+0x3c>
  if(empty == 0)
    8000360a:	02090c63          	beqz	s2,80003642 <iget+0xac>
  ip->dev = dev;
    8000360e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003612:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003616:	4785                	li	a5,1
    80003618:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000361c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003620:	0111d517          	auipc	a0,0x111d
    80003624:	84050513          	addi	a0,a0,-1984 # 8111fe60 <icache>
    80003628:	ffffe097          	auipc	ra,0xffffe
    8000362c:	916080e7          	jalr	-1770(ra) # 80000f3e <release>
}
    80003630:	854a                	mv	a0,s2
    80003632:	70a2                	ld	ra,40(sp)
    80003634:	7402                	ld	s0,32(sp)
    80003636:	64e2                	ld	s1,24(sp)
    80003638:	6942                	ld	s2,16(sp)
    8000363a:	69a2                	ld	s3,8(sp)
    8000363c:	6a02                	ld	s4,0(sp)
    8000363e:	6145                	addi	sp,sp,48
    80003640:	8082                	ret
    panic("iget: no inodes");
    80003642:	00005517          	auipc	a0,0x5
    80003646:	f1e50513          	addi	a0,a0,-226 # 80008560 <syscalls+0x130>
    8000364a:	ffffd097          	auipc	ra,0xffffd
    8000364e:	efe080e7          	jalr	-258(ra) # 80000548 <panic>

0000000080003652 <fsinit>:
fsinit(int dev) {
    80003652:	7179                	addi	sp,sp,-48
    80003654:	f406                	sd	ra,40(sp)
    80003656:	f022                	sd	s0,32(sp)
    80003658:	ec26                	sd	s1,24(sp)
    8000365a:	e84a                	sd	s2,16(sp)
    8000365c:	e44e                	sd	s3,8(sp)
    8000365e:	1800                	addi	s0,sp,48
    80003660:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003662:	4585                	li	a1,1
    80003664:	00000097          	auipc	ra,0x0
    80003668:	a64080e7          	jalr	-1436(ra) # 800030c8 <bread>
    8000366c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000366e:	0111c997          	auipc	s3,0x111c
    80003672:	7d298993          	addi	s3,s3,2002 # 8111fe40 <sb>
    80003676:	02000613          	li	a2,32
    8000367a:	05850593          	addi	a1,a0,88
    8000367e:	854e                	mv	a0,s3
    80003680:	ffffe097          	auipc	ra,0xffffe
    80003684:	966080e7          	jalr	-1690(ra) # 80000fe6 <memmove>
  brelse(bp);
    80003688:	8526                	mv	a0,s1
    8000368a:	00000097          	auipc	ra,0x0
    8000368e:	b6e080e7          	jalr	-1170(ra) # 800031f8 <brelse>
  if(sb.magic != FSMAGIC)
    80003692:	0009a703          	lw	a4,0(s3)
    80003696:	102037b7          	lui	a5,0x10203
    8000369a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000369e:	02f71263          	bne	a4,a5,800036c2 <fsinit+0x70>
  initlog(dev, &sb);
    800036a2:	0111c597          	auipc	a1,0x111c
    800036a6:	79e58593          	addi	a1,a1,1950 # 8111fe40 <sb>
    800036aa:	854a                	mv	a0,s2
    800036ac:	00001097          	auipc	ra,0x1
    800036b0:	b3c080e7          	jalr	-1220(ra) # 800041e8 <initlog>
}
    800036b4:	70a2                	ld	ra,40(sp)
    800036b6:	7402                	ld	s0,32(sp)
    800036b8:	64e2                	ld	s1,24(sp)
    800036ba:	6942                	ld	s2,16(sp)
    800036bc:	69a2                	ld	s3,8(sp)
    800036be:	6145                	addi	sp,sp,48
    800036c0:	8082                	ret
    panic("invalid file system");
    800036c2:	00005517          	auipc	a0,0x5
    800036c6:	eae50513          	addi	a0,a0,-338 # 80008570 <syscalls+0x140>
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	e7e080e7          	jalr	-386(ra) # 80000548 <panic>

00000000800036d2 <iinit>:
{
    800036d2:	7179                	addi	sp,sp,-48
    800036d4:	f406                	sd	ra,40(sp)
    800036d6:	f022                	sd	s0,32(sp)
    800036d8:	ec26                	sd	s1,24(sp)
    800036da:	e84a                	sd	s2,16(sp)
    800036dc:	e44e                	sd	s3,8(sp)
    800036de:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800036e0:	00005597          	auipc	a1,0x5
    800036e4:	ea858593          	addi	a1,a1,-344 # 80008588 <syscalls+0x158>
    800036e8:	0111c517          	auipc	a0,0x111c
    800036ec:	77850513          	addi	a0,a0,1912 # 8111fe60 <icache>
    800036f0:	ffffd097          	auipc	ra,0xffffd
    800036f4:	70a080e7          	jalr	1802(ra) # 80000dfa <initlock>
  for(i = 0; i < NINODE; i++) {
    800036f8:	0111c497          	auipc	s1,0x111c
    800036fc:	79048493          	addi	s1,s1,1936 # 8111fe88 <icache+0x28>
    80003700:	0111e997          	auipc	s3,0x111e
    80003704:	21898993          	addi	s3,s3,536 # 81121918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003708:	00005917          	auipc	s2,0x5
    8000370c:	e8890913          	addi	s2,s2,-376 # 80008590 <syscalls+0x160>
    80003710:	85ca                	mv	a1,s2
    80003712:	8526                	mv	a0,s1
    80003714:	00001097          	auipc	ra,0x1
    80003718:	e3a080e7          	jalr	-454(ra) # 8000454e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000371c:	08848493          	addi	s1,s1,136
    80003720:	ff3498e3          	bne	s1,s3,80003710 <iinit+0x3e>
}
    80003724:	70a2                	ld	ra,40(sp)
    80003726:	7402                	ld	s0,32(sp)
    80003728:	64e2                	ld	s1,24(sp)
    8000372a:	6942                	ld	s2,16(sp)
    8000372c:	69a2                	ld	s3,8(sp)
    8000372e:	6145                	addi	sp,sp,48
    80003730:	8082                	ret

0000000080003732 <ialloc>:
{
    80003732:	715d                	addi	sp,sp,-80
    80003734:	e486                	sd	ra,72(sp)
    80003736:	e0a2                	sd	s0,64(sp)
    80003738:	fc26                	sd	s1,56(sp)
    8000373a:	f84a                	sd	s2,48(sp)
    8000373c:	f44e                	sd	s3,40(sp)
    8000373e:	f052                	sd	s4,32(sp)
    80003740:	ec56                	sd	s5,24(sp)
    80003742:	e85a                	sd	s6,16(sp)
    80003744:	e45e                	sd	s7,8(sp)
    80003746:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003748:	0111c717          	auipc	a4,0x111c
    8000374c:	70472703          	lw	a4,1796(a4) # 8111fe4c <sb+0xc>
    80003750:	4785                	li	a5,1
    80003752:	04e7fa63          	bgeu	a5,a4,800037a6 <ialloc+0x74>
    80003756:	8aaa                	mv	s5,a0
    80003758:	8bae                	mv	s7,a1
    8000375a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000375c:	0111ca17          	auipc	s4,0x111c
    80003760:	6e4a0a13          	addi	s4,s4,1764 # 8111fe40 <sb>
    80003764:	00048b1b          	sext.w	s6,s1
    80003768:	0044d593          	srli	a1,s1,0x4
    8000376c:	018a2783          	lw	a5,24(s4)
    80003770:	9dbd                	addw	a1,a1,a5
    80003772:	8556                	mv	a0,s5
    80003774:	00000097          	auipc	ra,0x0
    80003778:	954080e7          	jalr	-1708(ra) # 800030c8 <bread>
    8000377c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000377e:	05850993          	addi	s3,a0,88
    80003782:	00f4f793          	andi	a5,s1,15
    80003786:	079a                	slli	a5,a5,0x6
    80003788:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000378a:	00099783          	lh	a5,0(s3)
    8000378e:	c785                	beqz	a5,800037b6 <ialloc+0x84>
    brelse(bp);
    80003790:	00000097          	auipc	ra,0x0
    80003794:	a68080e7          	jalr	-1432(ra) # 800031f8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003798:	0485                	addi	s1,s1,1
    8000379a:	00ca2703          	lw	a4,12(s4)
    8000379e:	0004879b          	sext.w	a5,s1
    800037a2:	fce7e1e3          	bltu	a5,a4,80003764 <ialloc+0x32>
  panic("ialloc: no inodes");
    800037a6:	00005517          	auipc	a0,0x5
    800037aa:	df250513          	addi	a0,a0,-526 # 80008598 <syscalls+0x168>
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	d9a080e7          	jalr	-614(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    800037b6:	04000613          	li	a2,64
    800037ba:	4581                	li	a1,0
    800037bc:	854e                	mv	a0,s3
    800037be:	ffffd097          	auipc	ra,0xffffd
    800037c2:	7c8080e7          	jalr	1992(ra) # 80000f86 <memset>
      dip->type = type;
    800037c6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037ca:	854a                	mv	a0,s2
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	c94080e7          	jalr	-876(ra) # 80004460 <log_write>
      brelse(bp);
    800037d4:	854a                	mv	a0,s2
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	a22080e7          	jalr	-1502(ra) # 800031f8 <brelse>
      return iget(dev, inum);
    800037de:	85da                	mv	a1,s6
    800037e0:	8556                	mv	a0,s5
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	db4080e7          	jalr	-588(ra) # 80003596 <iget>
}
    800037ea:	60a6                	ld	ra,72(sp)
    800037ec:	6406                	ld	s0,64(sp)
    800037ee:	74e2                	ld	s1,56(sp)
    800037f0:	7942                	ld	s2,48(sp)
    800037f2:	79a2                	ld	s3,40(sp)
    800037f4:	7a02                	ld	s4,32(sp)
    800037f6:	6ae2                	ld	s5,24(sp)
    800037f8:	6b42                	ld	s6,16(sp)
    800037fa:	6ba2                	ld	s7,8(sp)
    800037fc:	6161                	addi	sp,sp,80
    800037fe:	8082                	ret

0000000080003800 <iupdate>:
{
    80003800:	1101                	addi	sp,sp,-32
    80003802:	ec06                	sd	ra,24(sp)
    80003804:	e822                	sd	s0,16(sp)
    80003806:	e426                	sd	s1,8(sp)
    80003808:	e04a                	sd	s2,0(sp)
    8000380a:	1000                	addi	s0,sp,32
    8000380c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000380e:	415c                	lw	a5,4(a0)
    80003810:	0047d79b          	srliw	a5,a5,0x4
    80003814:	0111c597          	auipc	a1,0x111c
    80003818:	6445a583          	lw	a1,1604(a1) # 8111fe58 <sb+0x18>
    8000381c:	9dbd                	addw	a1,a1,a5
    8000381e:	4108                	lw	a0,0(a0)
    80003820:	00000097          	auipc	ra,0x0
    80003824:	8a8080e7          	jalr	-1880(ra) # 800030c8 <bread>
    80003828:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000382a:	05850793          	addi	a5,a0,88
    8000382e:	40c8                	lw	a0,4(s1)
    80003830:	893d                	andi	a0,a0,15
    80003832:	051a                	slli	a0,a0,0x6
    80003834:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003836:	04449703          	lh	a4,68(s1)
    8000383a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000383e:	04649703          	lh	a4,70(s1)
    80003842:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003846:	04849703          	lh	a4,72(s1)
    8000384a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000384e:	04a49703          	lh	a4,74(s1)
    80003852:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003856:	44f8                	lw	a4,76(s1)
    80003858:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000385a:	03400613          	li	a2,52
    8000385e:	05048593          	addi	a1,s1,80
    80003862:	0531                	addi	a0,a0,12
    80003864:	ffffd097          	auipc	ra,0xffffd
    80003868:	782080e7          	jalr	1922(ra) # 80000fe6 <memmove>
  log_write(bp);
    8000386c:	854a                	mv	a0,s2
    8000386e:	00001097          	auipc	ra,0x1
    80003872:	bf2080e7          	jalr	-1038(ra) # 80004460 <log_write>
  brelse(bp);
    80003876:	854a                	mv	a0,s2
    80003878:	00000097          	auipc	ra,0x0
    8000387c:	980080e7          	jalr	-1664(ra) # 800031f8 <brelse>
}
    80003880:	60e2                	ld	ra,24(sp)
    80003882:	6442                	ld	s0,16(sp)
    80003884:	64a2                	ld	s1,8(sp)
    80003886:	6902                	ld	s2,0(sp)
    80003888:	6105                	addi	sp,sp,32
    8000388a:	8082                	ret

000000008000388c <idup>:
{
    8000388c:	1101                	addi	sp,sp,-32
    8000388e:	ec06                	sd	ra,24(sp)
    80003890:	e822                	sd	s0,16(sp)
    80003892:	e426                	sd	s1,8(sp)
    80003894:	1000                	addi	s0,sp,32
    80003896:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003898:	0111c517          	auipc	a0,0x111c
    8000389c:	5c850513          	addi	a0,a0,1480 # 8111fe60 <icache>
    800038a0:	ffffd097          	auipc	ra,0xffffd
    800038a4:	5ea080e7          	jalr	1514(ra) # 80000e8a <acquire>
  ip->ref++;
    800038a8:	449c                	lw	a5,8(s1)
    800038aa:	2785                	addiw	a5,a5,1
    800038ac:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800038ae:	0111c517          	auipc	a0,0x111c
    800038b2:	5b250513          	addi	a0,a0,1458 # 8111fe60 <icache>
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	688080e7          	jalr	1672(ra) # 80000f3e <release>
}
    800038be:	8526                	mv	a0,s1
    800038c0:	60e2                	ld	ra,24(sp)
    800038c2:	6442                	ld	s0,16(sp)
    800038c4:	64a2                	ld	s1,8(sp)
    800038c6:	6105                	addi	sp,sp,32
    800038c8:	8082                	ret

00000000800038ca <ilock>:
{
    800038ca:	1101                	addi	sp,sp,-32
    800038cc:	ec06                	sd	ra,24(sp)
    800038ce:	e822                	sd	s0,16(sp)
    800038d0:	e426                	sd	s1,8(sp)
    800038d2:	e04a                	sd	s2,0(sp)
    800038d4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038d6:	c115                	beqz	a0,800038fa <ilock+0x30>
    800038d8:	84aa                	mv	s1,a0
    800038da:	451c                	lw	a5,8(a0)
    800038dc:	00f05f63          	blez	a5,800038fa <ilock+0x30>
  acquiresleep(&ip->lock);
    800038e0:	0541                	addi	a0,a0,16
    800038e2:	00001097          	auipc	ra,0x1
    800038e6:	ca6080e7          	jalr	-858(ra) # 80004588 <acquiresleep>
  if(ip->valid == 0){
    800038ea:	40bc                	lw	a5,64(s1)
    800038ec:	cf99                	beqz	a5,8000390a <ilock+0x40>
}
    800038ee:	60e2                	ld	ra,24(sp)
    800038f0:	6442                	ld	s0,16(sp)
    800038f2:	64a2                	ld	s1,8(sp)
    800038f4:	6902                	ld	s2,0(sp)
    800038f6:	6105                	addi	sp,sp,32
    800038f8:	8082                	ret
    panic("ilock");
    800038fa:	00005517          	auipc	a0,0x5
    800038fe:	cb650513          	addi	a0,a0,-842 # 800085b0 <syscalls+0x180>
    80003902:	ffffd097          	auipc	ra,0xffffd
    80003906:	c46080e7          	jalr	-954(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000390a:	40dc                	lw	a5,4(s1)
    8000390c:	0047d79b          	srliw	a5,a5,0x4
    80003910:	0111c597          	auipc	a1,0x111c
    80003914:	5485a583          	lw	a1,1352(a1) # 8111fe58 <sb+0x18>
    80003918:	9dbd                	addw	a1,a1,a5
    8000391a:	4088                	lw	a0,0(s1)
    8000391c:	fffff097          	auipc	ra,0xfffff
    80003920:	7ac080e7          	jalr	1964(ra) # 800030c8 <bread>
    80003924:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003926:	05850593          	addi	a1,a0,88
    8000392a:	40dc                	lw	a5,4(s1)
    8000392c:	8bbd                	andi	a5,a5,15
    8000392e:	079a                	slli	a5,a5,0x6
    80003930:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003932:	00059783          	lh	a5,0(a1)
    80003936:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000393a:	00259783          	lh	a5,2(a1)
    8000393e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003942:	00459783          	lh	a5,4(a1)
    80003946:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000394a:	00659783          	lh	a5,6(a1)
    8000394e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003952:	459c                	lw	a5,8(a1)
    80003954:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003956:	03400613          	li	a2,52
    8000395a:	05b1                	addi	a1,a1,12
    8000395c:	05048513          	addi	a0,s1,80
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	686080e7          	jalr	1670(ra) # 80000fe6 <memmove>
    brelse(bp);
    80003968:	854a                	mv	a0,s2
    8000396a:	00000097          	auipc	ra,0x0
    8000396e:	88e080e7          	jalr	-1906(ra) # 800031f8 <brelse>
    ip->valid = 1;
    80003972:	4785                	li	a5,1
    80003974:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003976:	04449783          	lh	a5,68(s1)
    8000397a:	fbb5                	bnez	a5,800038ee <ilock+0x24>
      panic("ilock: no type");
    8000397c:	00005517          	auipc	a0,0x5
    80003980:	c3c50513          	addi	a0,a0,-964 # 800085b8 <syscalls+0x188>
    80003984:	ffffd097          	auipc	ra,0xffffd
    80003988:	bc4080e7          	jalr	-1084(ra) # 80000548 <panic>

000000008000398c <iunlock>:
{
    8000398c:	1101                	addi	sp,sp,-32
    8000398e:	ec06                	sd	ra,24(sp)
    80003990:	e822                	sd	s0,16(sp)
    80003992:	e426                	sd	s1,8(sp)
    80003994:	e04a                	sd	s2,0(sp)
    80003996:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003998:	c905                	beqz	a0,800039c8 <iunlock+0x3c>
    8000399a:	84aa                	mv	s1,a0
    8000399c:	01050913          	addi	s2,a0,16
    800039a0:	854a                	mv	a0,s2
    800039a2:	00001097          	auipc	ra,0x1
    800039a6:	c80080e7          	jalr	-896(ra) # 80004622 <holdingsleep>
    800039aa:	cd19                	beqz	a0,800039c8 <iunlock+0x3c>
    800039ac:	449c                	lw	a5,8(s1)
    800039ae:	00f05d63          	blez	a5,800039c8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039b2:	854a                	mv	a0,s2
    800039b4:	00001097          	auipc	ra,0x1
    800039b8:	c2a080e7          	jalr	-982(ra) # 800045de <releasesleep>
}
    800039bc:	60e2                	ld	ra,24(sp)
    800039be:	6442                	ld	s0,16(sp)
    800039c0:	64a2                	ld	s1,8(sp)
    800039c2:	6902                	ld	s2,0(sp)
    800039c4:	6105                	addi	sp,sp,32
    800039c6:	8082                	ret
    panic("iunlock");
    800039c8:	00005517          	auipc	a0,0x5
    800039cc:	c0050513          	addi	a0,a0,-1024 # 800085c8 <syscalls+0x198>
    800039d0:	ffffd097          	auipc	ra,0xffffd
    800039d4:	b78080e7          	jalr	-1160(ra) # 80000548 <panic>

00000000800039d8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039d8:	7179                	addi	sp,sp,-48
    800039da:	f406                	sd	ra,40(sp)
    800039dc:	f022                	sd	s0,32(sp)
    800039de:	ec26                	sd	s1,24(sp)
    800039e0:	e84a                	sd	s2,16(sp)
    800039e2:	e44e                	sd	s3,8(sp)
    800039e4:	e052                	sd	s4,0(sp)
    800039e6:	1800                	addi	s0,sp,48
    800039e8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039ea:	05050493          	addi	s1,a0,80
    800039ee:	08050913          	addi	s2,a0,128
    800039f2:	a021                	j	800039fa <itrunc+0x22>
    800039f4:	0491                	addi	s1,s1,4
    800039f6:	01248d63          	beq	s1,s2,80003a10 <itrunc+0x38>
    if(ip->addrs[i]){
    800039fa:	408c                	lw	a1,0(s1)
    800039fc:	dde5                	beqz	a1,800039f4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800039fe:	0009a503          	lw	a0,0(s3)
    80003a02:	00000097          	auipc	ra,0x0
    80003a06:	90c080e7          	jalr	-1780(ra) # 8000330e <bfree>
      ip->addrs[i] = 0;
    80003a0a:	0004a023          	sw	zero,0(s1)
    80003a0e:	b7dd                	j	800039f4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a10:	0809a583          	lw	a1,128(s3)
    80003a14:	e185                	bnez	a1,80003a34 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a16:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a1a:	854e                	mv	a0,s3
    80003a1c:	00000097          	auipc	ra,0x0
    80003a20:	de4080e7          	jalr	-540(ra) # 80003800 <iupdate>
}
    80003a24:	70a2                	ld	ra,40(sp)
    80003a26:	7402                	ld	s0,32(sp)
    80003a28:	64e2                	ld	s1,24(sp)
    80003a2a:	6942                	ld	s2,16(sp)
    80003a2c:	69a2                	ld	s3,8(sp)
    80003a2e:	6a02                	ld	s4,0(sp)
    80003a30:	6145                	addi	sp,sp,48
    80003a32:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a34:	0009a503          	lw	a0,0(s3)
    80003a38:	fffff097          	auipc	ra,0xfffff
    80003a3c:	690080e7          	jalr	1680(ra) # 800030c8 <bread>
    80003a40:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a42:	05850493          	addi	s1,a0,88
    80003a46:	45850913          	addi	s2,a0,1112
    80003a4a:	a811                	j	80003a5e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a4c:	0009a503          	lw	a0,0(s3)
    80003a50:	00000097          	auipc	ra,0x0
    80003a54:	8be080e7          	jalr	-1858(ra) # 8000330e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a58:	0491                	addi	s1,s1,4
    80003a5a:	01248563          	beq	s1,s2,80003a64 <itrunc+0x8c>
      if(a[j])
    80003a5e:	408c                	lw	a1,0(s1)
    80003a60:	dde5                	beqz	a1,80003a58 <itrunc+0x80>
    80003a62:	b7ed                	j	80003a4c <itrunc+0x74>
    brelse(bp);
    80003a64:	8552                	mv	a0,s4
    80003a66:	fffff097          	auipc	ra,0xfffff
    80003a6a:	792080e7          	jalr	1938(ra) # 800031f8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a6e:	0809a583          	lw	a1,128(s3)
    80003a72:	0009a503          	lw	a0,0(s3)
    80003a76:	00000097          	auipc	ra,0x0
    80003a7a:	898080e7          	jalr	-1896(ra) # 8000330e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a7e:	0809a023          	sw	zero,128(s3)
    80003a82:	bf51                	j	80003a16 <itrunc+0x3e>

0000000080003a84 <iput>:
{
    80003a84:	1101                	addi	sp,sp,-32
    80003a86:	ec06                	sd	ra,24(sp)
    80003a88:	e822                	sd	s0,16(sp)
    80003a8a:	e426                	sd	s1,8(sp)
    80003a8c:	e04a                	sd	s2,0(sp)
    80003a8e:	1000                	addi	s0,sp,32
    80003a90:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a92:	0111c517          	auipc	a0,0x111c
    80003a96:	3ce50513          	addi	a0,a0,974 # 8111fe60 <icache>
    80003a9a:	ffffd097          	auipc	ra,0xffffd
    80003a9e:	3f0080e7          	jalr	1008(ra) # 80000e8a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003aa2:	4498                	lw	a4,8(s1)
    80003aa4:	4785                	li	a5,1
    80003aa6:	02f70363          	beq	a4,a5,80003acc <iput+0x48>
  ip->ref--;
    80003aaa:	449c                	lw	a5,8(s1)
    80003aac:	37fd                	addiw	a5,a5,-1
    80003aae:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ab0:	0111c517          	auipc	a0,0x111c
    80003ab4:	3b050513          	addi	a0,a0,944 # 8111fe60 <icache>
    80003ab8:	ffffd097          	auipc	ra,0xffffd
    80003abc:	486080e7          	jalr	1158(ra) # 80000f3e <release>
}
    80003ac0:	60e2                	ld	ra,24(sp)
    80003ac2:	6442                	ld	s0,16(sp)
    80003ac4:	64a2                	ld	s1,8(sp)
    80003ac6:	6902                	ld	s2,0(sp)
    80003ac8:	6105                	addi	sp,sp,32
    80003aca:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003acc:	40bc                	lw	a5,64(s1)
    80003ace:	dff1                	beqz	a5,80003aaa <iput+0x26>
    80003ad0:	04a49783          	lh	a5,74(s1)
    80003ad4:	fbf9                	bnez	a5,80003aaa <iput+0x26>
    acquiresleep(&ip->lock);
    80003ad6:	01048913          	addi	s2,s1,16
    80003ada:	854a                	mv	a0,s2
    80003adc:	00001097          	auipc	ra,0x1
    80003ae0:	aac080e7          	jalr	-1364(ra) # 80004588 <acquiresleep>
    release(&icache.lock);
    80003ae4:	0111c517          	auipc	a0,0x111c
    80003ae8:	37c50513          	addi	a0,a0,892 # 8111fe60 <icache>
    80003aec:	ffffd097          	auipc	ra,0xffffd
    80003af0:	452080e7          	jalr	1106(ra) # 80000f3e <release>
    itrunc(ip);
    80003af4:	8526                	mv	a0,s1
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	ee2080e7          	jalr	-286(ra) # 800039d8 <itrunc>
    ip->type = 0;
    80003afe:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b02:	8526                	mv	a0,s1
    80003b04:	00000097          	auipc	ra,0x0
    80003b08:	cfc080e7          	jalr	-772(ra) # 80003800 <iupdate>
    ip->valid = 0;
    80003b0c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b10:	854a                	mv	a0,s2
    80003b12:	00001097          	auipc	ra,0x1
    80003b16:	acc080e7          	jalr	-1332(ra) # 800045de <releasesleep>
    acquire(&icache.lock);
    80003b1a:	0111c517          	auipc	a0,0x111c
    80003b1e:	34650513          	addi	a0,a0,838 # 8111fe60 <icache>
    80003b22:	ffffd097          	auipc	ra,0xffffd
    80003b26:	368080e7          	jalr	872(ra) # 80000e8a <acquire>
    80003b2a:	b741                	j	80003aaa <iput+0x26>

0000000080003b2c <iunlockput>:
{
    80003b2c:	1101                	addi	sp,sp,-32
    80003b2e:	ec06                	sd	ra,24(sp)
    80003b30:	e822                	sd	s0,16(sp)
    80003b32:	e426                	sd	s1,8(sp)
    80003b34:	1000                	addi	s0,sp,32
    80003b36:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b38:	00000097          	auipc	ra,0x0
    80003b3c:	e54080e7          	jalr	-428(ra) # 8000398c <iunlock>
  iput(ip);
    80003b40:	8526                	mv	a0,s1
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	f42080e7          	jalr	-190(ra) # 80003a84 <iput>
}
    80003b4a:	60e2                	ld	ra,24(sp)
    80003b4c:	6442                	ld	s0,16(sp)
    80003b4e:	64a2                	ld	s1,8(sp)
    80003b50:	6105                	addi	sp,sp,32
    80003b52:	8082                	ret

0000000080003b54 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b54:	1141                	addi	sp,sp,-16
    80003b56:	e422                	sd	s0,8(sp)
    80003b58:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b5a:	411c                	lw	a5,0(a0)
    80003b5c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b5e:	415c                	lw	a5,4(a0)
    80003b60:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b62:	04451783          	lh	a5,68(a0)
    80003b66:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b6a:	04a51783          	lh	a5,74(a0)
    80003b6e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b72:	04c56783          	lwu	a5,76(a0)
    80003b76:	e99c                	sd	a5,16(a1)
}
    80003b78:	6422                	ld	s0,8(sp)
    80003b7a:	0141                	addi	sp,sp,16
    80003b7c:	8082                	ret

0000000080003b7e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b7e:	457c                	lw	a5,76(a0)
    80003b80:	0ed7e963          	bltu	a5,a3,80003c72 <readi+0xf4>
{
    80003b84:	7159                	addi	sp,sp,-112
    80003b86:	f486                	sd	ra,104(sp)
    80003b88:	f0a2                	sd	s0,96(sp)
    80003b8a:	eca6                	sd	s1,88(sp)
    80003b8c:	e8ca                	sd	s2,80(sp)
    80003b8e:	e4ce                	sd	s3,72(sp)
    80003b90:	e0d2                	sd	s4,64(sp)
    80003b92:	fc56                	sd	s5,56(sp)
    80003b94:	f85a                	sd	s6,48(sp)
    80003b96:	f45e                	sd	s7,40(sp)
    80003b98:	f062                	sd	s8,32(sp)
    80003b9a:	ec66                	sd	s9,24(sp)
    80003b9c:	e86a                	sd	s10,16(sp)
    80003b9e:	e46e                	sd	s11,8(sp)
    80003ba0:	1880                	addi	s0,sp,112
    80003ba2:	8baa                	mv	s7,a0
    80003ba4:	8c2e                	mv	s8,a1
    80003ba6:	8ab2                	mv	s5,a2
    80003ba8:	84b6                	mv	s1,a3
    80003baa:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bac:	9f35                	addw	a4,a4,a3
    return 0;
    80003bae:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bb0:	0ad76063          	bltu	a4,a3,80003c50 <readi+0xd2>
  if(off + n > ip->size)
    80003bb4:	00e7f463          	bgeu	a5,a4,80003bbc <readi+0x3e>
    n = ip->size - off;
    80003bb8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bbc:	0a0b0963          	beqz	s6,80003c6e <readi+0xf0>
    80003bc0:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bc2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bc6:	5cfd                	li	s9,-1
    80003bc8:	a82d                	j	80003c02 <readi+0x84>
    80003bca:	020a1d93          	slli	s11,s4,0x20
    80003bce:	020ddd93          	srli	s11,s11,0x20
    80003bd2:	05890613          	addi	a2,s2,88
    80003bd6:	86ee                	mv	a3,s11
    80003bd8:	963a                	add	a2,a2,a4
    80003bda:	85d6                	mv	a1,s5
    80003bdc:	8562                	mv	a0,s8
    80003bde:	fffff097          	auipc	ra,0xfffff
    80003be2:	afe080e7          	jalr	-1282(ra) # 800026dc <either_copyout>
    80003be6:	05950d63          	beq	a0,s9,80003c40 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bea:	854a                	mv	a0,s2
    80003bec:	fffff097          	auipc	ra,0xfffff
    80003bf0:	60c080e7          	jalr	1548(ra) # 800031f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bf4:	013a09bb          	addw	s3,s4,s3
    80003bf8:	009a04bb          	addw	s1,s4,s1
    80003bfc:	9aee                	add	s5,s5,s11
    80003bfe:	0569f763          	bgeu	s3,s6,80003c4c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c02:	000ba903          	lw	s2,0(s7)
    80003c06:	00a4d59b          	srliw	a1,s1,0xa
    80003c0a:	855e                	mv	a0,s7
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	8b0080e7          	jalr	-1872(ra) # 800034bc <bmap>
    80003c14:	0005059b          	sext.w	a1,a0
    80003c18:	854a                	mv	a0,s2
    80003c1a:	fffff097          	auipc	ra,0xfffff
    80003c1e:	4ae080e7          	jalr	1198(ra) # 800030c8 <bread>
    80003c22:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c24:	3ff4f713          	andi	a4,s1,1023
    80003c28:	40ed07bb          	subw	a5,s10,a4
    80003c2c:	413b06bb          	subw	a3,s6,s3
    80003c30:	8a3e                	mv	s4,a5
    80003c32:	2781                	sext.w	a5,a5
    80003c34:	0006861b          	sext.w	a2,a3
    80003c38:	f8f679e3          	bgeu	a2,a5,80003bca <readi+0x4c>
    80003c3c:	8a36                	mv	s4,a3
    80003c3e:	b771                	j	80003bca <readi+0x4c>
      brelse(bp);
    80003c40:	854a                	mv	a0,s2
    80003c42:	fffff097          	auipc	ra,0xfffff
    80003c46:	5b6080e7          	jalr	1462(ra) # 800031f8 <brelse>
      tot = -1;
    80003c4a:	59fd                	li	s3,-1
  }
  return tot;
    80003c4c:	0009851b          	sext.w	a0,s3
}
    80003c50:	70a6                	ld	ra,104(sp)
    80003c52:	7406                	ld	s0,96(sp)
    80003c54:	64e6                	ld	s1,88(sp)
    80003c56:	6946                	ld	s2,80(sp)
    80003c58:	69a6                	ld	s3,72(sp)
    80003c5a:	6a06                	ld	s4,64(sp)
    80003c5c:	7ae2                	ld	s5,56(sp)
    80003c5e:	7b42                	ld	s6,48(sp)
    80003c60:	7ba2                	ld	s7,40(sp)
    80003c62:	7c02                	ld	s8,32(sp)
    80003c64:	6ce2                	ld	s9,24(sp)
    80003c66:	6d42                	ld	s10,16(sp)
    80003c68:	6da2                	ld	s11,8(sp)
    80003c6a:	6165                	addi	sp,sp,112
    80003c6c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c6e:	89da                	mv	s3,s6
    80003c70:	bff1                	j	80003c4c <readi+0xce>
    return 0;
    80003c72:	4501                	li	a0,0
}
    80003c74:	8082                	ret

0000000080003c76 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c76:	457c                	lw	a5,76(a0)
    80003c78:	10d7e763          	bltu	a5,a3,80003d86 <writei+0x110>
{
    80003c7c:	7159                	addi	sp,sp,-112
    80003c7e:	f486                	sd	ra,104(sp)
    80003c80:	f0a2                	sd	s0,96(sp)
    80003c82:	eca6                	sd	s1,88(sp)
    80003c84:	e8ca                	sd	s2,80(sp)
    80003c86:	e4ce                	sd	s3,72(sp)
    80003c88:	e0d2                	sd	s4,64(sp)
    80003c8a:	fc56                	sd	s5,56(sp)
    80003c8c:	f85a                	sd	s6,48(sp)
    80003c8e:	f45e                	sd	s7,40(sp)
    80003c90:	f062                	sd	s8,32(sp)
    80003c92:	ec66                	sd	s9,24(sp)
    80003c94:	e86a                	sd	s10,16(sp)
    80003c96:	e46e                	sd	s11,8(sp)
    80003c98:	1880                	addi	s0,sp,112
    80003c9a:	8baa                	mv	s7,a0
    80003c9c:	8c2e                	mv	s8,a1
    80003c9e:	8ab2                	mv	s5,a2
    80003ca0:	8936                	mv	s2,a3
    80003ca2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ca4:	00e687bb          	addw	a5,a3,a4
    80003ca8:	0ed7e163          	bltu	a5,a3,80003d8a <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cac:	00043737          	lui	a4,0x43
    80003cb0:	0cf76f63          	bltu	a4,a5,80003d8e <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cb4:	0a0b0863          	beqz	s6,80003d64 <writei+0xee>
    80003cb8:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cba:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cbe:	5cfd                	li	s9,-1
    80003cc0:	a091                	j	80003d04 <writei+0x8e>
    80003cc2:	02099d93          	slli	s11,s3,0x20
    80003cc6:	020ddd93          	srli	s11,s11,0x20
    80003cca:	05848513          	addi	a0,s1,88
    80003cce:	86ee                	mv	a3,s11
    80003cd0:	8656                	mv	a2,s5
    80003cd2:	85e2                	mv	a1,s8
    80003cd4:	953a                	add	a0,a0,a4
    80003cd6:	fffff097          	auipc	ra,0xfffff
    80003cda:	a5c080e7          	jalr	-1444(ra) # 80002732 <either_copyin>
    80003cde:	07950263          	beq	a0,s9,80003d42 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003ce2:	8526                	mv	a0,s1
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	77c080e7          	jalr	1916(ra) # 80004460 <log_write>
    brelse(bp);
    80003cec:	8526                	mv	a0,s1
    80003cee:	fffff097          	auipc	ra,0xfffff
    80003cf2:	50a080e7          	jalr	1290(ra) # 800031f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cf6:	01498a3b          	addw	s4,s3,s4
    80003cfa:	0129893b          	addw	s2,s3,s2
    80003cfe:	9aee                	add	s5,s5,s11
    80003d00:	056a7763          	bgeu	s4,s6,80003d4e <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d04:	000ba483          	lw	s1,0(s7)
    80003d08:	00a9559b          	srliw	a1,s2,0xa
    80003d0c:	855e                	mv	a0,s7
    80003d0e:	fffff097          	auipc	ra,0xfffff
    80003d12:	7ae080e7          	jalr	1966(ra) # 800034bc <bmap>
    80003d16:	0005059b          	sext.w	a1,a0
    80003d1a:	8526                	mv	a0,s1
    80003d1c:	fffff097          	auipc	ra,0xfffff
    80003d20:	3ac080e7          	jalr	940(ra) # 800030c8 <bread>
    80003d24:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d26:	3ff97713          	andi	a4,s2,1023
    80003d2a:	40ed07bb          	subw	a5,s10,a4
    80003d2e:	414b06bb          	subw	a3,s6,s4
    80003d32:	89be                	mv	s3,a5
    80003d34:	2781                	sext.w	a5,a5
    80003d36:	0006861b          	sext.w	a2,a3
    80003d3a:	f8f674e3          	bgeu	a2,a5,80003cc2 <writei+0x4c>
    80003d3e:	89b6                	mv	s3,a3
    80003d40:	b749                	j	80003cc2 <writei+0x4c>
      brelse(bp);
    80003d42:	8526                	mv	a0,s1
    80003d44:	fffff097          	auipc	ra,0xfffff
    80003d48:	4b4080e7          	jalr	1204(ra) # 800031f8 <brelse>
      n = -1;
    80003d4c:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003d4e:	04cba783          	lw	a5,76(s7)
    80003d52:	0127f463          	bgeu	a5,s2,80003d5a <writei+0xe4>
      ip->size = off;
    80003d56:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003d5a:	855e                	mv	a0,s7
    80003d5c:	00000097          	auipc	ra,0x0
    80003d60:	aa4080e7          	jalr	-1372(ra) # 80003800 <iupdate>
  }

  return n;
    80003d64:	000b051b          	sext.w	a0,s6
}
    80003d68:	70a6                	ld	ra,104(sp)
    80003d6a:	7406                	ld	s0,96(sp)
    80003d6c:	64e6                	ld	s1,88(sp)
    80003d6e:	6946                	ld	s2,80(sp)
    80003d70:	69a6                	ld	s3,72(sp)
    80003d72:	6a06                	ld	s4,64(sp)
    80003d74:	7ae2                	ld	s5,56(sp)
    80003d76:	7b42                	ld	s6,48(sp)
    80003d78:	7ba2                	ld	s7,40(sp)
    80003d7a:	7c02                	ld	s8,32(sp)
    80003d7c:	6ce2                	ld	s9,24(sp)
    80003d7e:	6d42                	ld	s10,16(sp)
    80003d80:	6da2                	ld	s11,8(sp)
    80003d82:	6165                	addi	sp,sp,112
    80003d84:	8082                	ret
    return -1;
    80003d86:	557d                	li	a0,-1
}
    80003d88:	8082                	ret
    return -1;
    80003d8a:	557d                	li	a0,-1
    80003d8c:	bff1                	j	80003d68 <writei+0xf2>
    return -1;
    80003d8e:	557d                	li	a0,-1
    80003d90:	bfe1                	j	80003d68 <writei+0xf2>

0000000080003d92 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d92:	1141                	addi	sp,sp,-16
    80003d94:	e406                	sd	ra,8(sp)
    80003d96:	e022                	sd	s0,0(sp)
    80003d98:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d9a:	4639                	li	a2,14
    80003d9c:	ffffd097          	auipc	ra,0xffffd
    80003da0:	2c6080e7          	jalr	710(ra) # 80001062 <strncmp>
}
    80003da4:	60a2                	ld	ra,8(sp)
    80003da6:	6402                	ld	s0,0(sp)
    80003da8:	0141                	addi	sp,sp,16
    80003daa:	8082                	ret

0000000080003dac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dac:	7139                	addi	sp,sp,-64
    80003dae:	fc06                	sd	ra,56(sp)
    80003db0:	f822                	sd	s0,48(sp)
    80003db2:	f426                	sd	s1,40(sp)
    80003db4:	f04a                	sd	s2,32(sp)
    80003db6:	ec4e                	sd	s3,24(sp)
    80003db8:	e852                	sd	s4,16(sp)
    80003dba:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dbc:	04451703          	lh	a4,68(a0)
    80003dc0:	4785                	li	a5,1
    80003dc2:	00f71a63          	bne	a4,a5,80003dd6 <dirlookup+0x2a>
    80003dc6:	892a                	mv	s2,a0
    80003dc8:	89ae                	mv	s3,a1
    80003dca:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dcc:	457c                	lw	a5,76(a0)
    80003dce:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dd0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dd2:	e79d                	bnez	a5,80003e00 <dirlookup+0x54>
    80003dd4:	a8a5                	j	80003e4c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003dd6:	00004517          	auipc	a0,0x4
    80003dda:	7fa50513          	addi	a0,a0,2042 # 800085d0 <syscalls+0x1a0>
    80003dde:	ffffc097          	auipc	ra,0xffffc
    80003de2:	76a080e7          	jalr	1898(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003de6:	00005517          	auipc	a0,0x5
    80003dea:	80250513          	addi	a0,a0,-2046 # 800085e8 <syscalls+0x1b8>
    80003dee:	ffffc097          	auipc	ra,0xffffc
    80003df2:	75a080e7          	jalr	1882(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df6:	24c1                	addiw	s1,s1,16
    80003df8:	04c92783          	lw	a5,76(s2)
    80003dfc:	04f4f763          	bgeu	s1,a5,80003e4a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e00:	4741                	li	a4,16
    80003e02:	86a6                	mv	a3,s1
    80003e04:	fc040613          	addi	a2,s0,-64
    80003e08:	4581                	li	a1,0
    80003e0a:	854a                	mv	a0,s2
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	d72080e7          	jalr	-654(ra) # 80003b7e <readi>
    80003e14:	47c1                	li	a5,16
    80003e16:	fcf518e3          	bne	a0,a5,80003de6 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e1a:	fc045783          	lhu	a5,-64(s0)
    80003e1e:	dfe1                	beqz	a5,80003df6 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e20:	fc240593          	addi	a1,s0,-62
    80003e24:	854e                	mv	a0,s3
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	f6c080e7          	jalr	-148(ra) # 80003d92 <namecmp>
    80003e2e:	f561                	bnez	a0,80003df6 <dirlookup+0x4a>
      if(poff)
    80003e30:	000a0463          	beqz	s4,80003e38 <dirlookup+0x8c>
        *poff = off;
    80003e34:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e38:	fc045583          	lhu	a1,-64(s0)
    80003e3c:	00092503          	lw	a0,0(s2)
    80003e40:	fffff097          	auipc	ra,0xfffff
    80003e44:	756080e7          	jalr	1878(ra) # 80003596 <iget>
    80003e48:	a011                	j	80003e4c <dirlookup+0xa0>
  return 0;
    80003e4a:	4501                	li	a0,0
}
    80003e4c:	70e2                	ld	ra,56(sp)
    80003e4e:	7442                	ld	s0,48(sp)
    80003e50:	74a2                	ld	s1,40(sp)
    80003e52:	7902                	ld	s2,32(sp)
    80003e54:	69e2                	ld	s3,24(sp)
    80003e56:	6a42                	ld	s4,16(sp)
    80003e58:	6121                	addi	sp,sp,64
    80003e5a:	8082                	ret

0000000080003e5c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e5c:	711d                	addi	sp,sp,-96
    80003e5e:	ec86                	sd	ra,88(sp)
    80003e60:	e8a2                	sd	s0,80(sp)
    80003e62:	e4a6                	sd	s1,72(sp)
    80003e64:	e0ca                	sd	s2,64(sp)
    80003e66:	fc4e                	sd	s3,56(sp)
    80003e68:	f852                	sd	s4,48(sp)
    80003e6a:	f456                	sd	s5,40(sp)
    80003e6c:	f05a                	sd	s6,32(sp)
    80003e6e:	ec5e                	sd	s7,24(sp)
    80003e70:	e862                	sd	s8,16(sp)
    80003e72:	e466                	sd	s9,8(sp)
    80003e74:	1080                	addi	s0,sp,96
    80003e76:	84aa                	mv	s1,a0
    80003e78:	8b2e                	mv	s6,a1
    80003e7a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e7c:	00054703          	lbu	a4,0(a0)
    80003e80:	02f00793          	li	a5,47
    80003e84:	02f70363          	beq	a4,a5,80003eaa <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e88:	ffffe097          	auipc	ra,0xffffe
    80003e8c:	de2080e7          	jalr	-542(ra) # 80001c6a <myproc>
    80003e90:	15053503          	ld	a0,336(a0)
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	9f8080e7          	jalr	-1544(ra) # 8000388c <idup>
    80003e9c:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e9e:	02f00913          	li	s2,47
  len = path - s;
    80003ea2:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003ea4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ea6:	4c05                	li	s8,1
    80003ea8:	a865                	j	80003f60 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003eaa:	4585                	li	a1,1
    80003eac:	4505                	li	a0,1
    80003eae:	fffff097          	auipc	ra,0xfffff
    80003eb2:	6e8080e7          	jalr	1768(ra) # 80003596 <iget>
    80003eb6:	89aa                	mv	s3,a0
    80003eb8:	b7dd                	j	80003e9e <namex+0x42>
      iunlockput(ip);
    80003eba:	854e                	mv	a0,s3
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	c70080e7          	jalr	-912(ra) # 80003b2c <iunlockput>
      return 0;
    80003ec4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ec6:	854e                	mv	a0,s3
    80003ec8:	60e6                	ld	ra,88(sp)
    80003eca:	6446                	ld	s0,80(sp)
    80003ecc:	64a6                	ld	s1,72(sp)
    80003ece:	6906                	ld	s2,64(sp)
    80003ed0:	79e2                	ld	s3,56(sp)
    80003ed2:	7a42                	ld	s4,48(sp)
    80003ed4:	7aa2                	ld	s5,40(sp)
    80003ed6:	7b02                	ld	s6,32(sp)
    80003ed8:	6be2                	ld	s7,24(sp)
    80003eda:	6c42                	ld	s8,16(sp)
    80003edc:	6ca2                	ld	s9,8(sp)
    80003ede:	6125                	addi	sp,sp,96
    80003ee0:	8082                	ret
      iunlock(ip);
    80003ee2:	854e                	mv	a0,s3
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	aa8080e7          	jalr	-1368(ra) # 8000398c <iunlock>
      return ip;
    80003eec:	bfe9                	j	80003ec6 <namex+0x6a>
      iunlockput(ip);
    80003eee:	854e                	mv	a0,s3
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	c3c080e7          	jalr	-964(ra) # 80003b2c <iunlockput>
      return 0;
    80003ef8:	89d2                	mv	s3,s4
    80003efa:	b7f1                	j	80003ec6 <namex+0x6a>
  len = path - s;
    80003efc:	40b48633          	sub	a2,s1,a1
    80003f00:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f04:	094cd463          	bge	s9,s4,80003f8c <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f08:	4639                	li	a2,14
    80003f0a:	8556                	mv	a0,s5
    80003f0c:	ffffd097          	auipc	ra,0xffffd
    80003f10:	0da080e7          	jalr	218(ra) # 80000fe6 <memmove>
  while(*path == '/')
    80003f14:	0004c783          	lbu	a5,0(s1)
    80003f18:	01279763          	bne	a5,s2,80003f26 <namex+0xca>
    path++;
    80003f1c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f1e:	0004c783          	lbu	a5,0(s1)
    80003f22:	ff278de3          	beq	a5,s2,80003f1c <namex+0xc0>
    ilock(ip);
    80003f26:	854e                	mv	a0,s3
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	9a2080e7          	jalr	-1630(ra) # 800038ca <ilock>
    if(ip->type != T_DIR){
    80003f30:	04499783          	lh	a5,68(s3)
    80003f34:	f98793e3          	bne	a5,s8,80003eba <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f38:	000b0563          	beqz	s6,80003f42 <namex+0xe6>
    80003f3c:	0004c783          	lbu	a5,0(s1)
    80003f40:	d3cd                	beqz	a5,80003ee2 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f42:	865e                	mv	a2,s7
    80003f44:	85d6                	mv	a1,s5
    80003f46:	854e                	mv	a0,s3
    80003f48:	00000097          	auipc	ra,0x0
    80003f4c:	e64080e7          	jalr	-412(ra) # 80003dac <dirlookup>
    80003f50:	8a2a                	mv	s4,a0
    80003f52:	dd51                	beqz	a0,80003eee <namex+0x92>
    iunlockput(ip);
    80003f54:	854e                	mv	a0,s3
    80003f56:	00000097          	auipc	ra,0x0
    80003f5a:	bd6080e7          	jalr	-1066(ra) # 80003b2c <iunlockput>
    ip = next;
    80003f5e:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f60:	0004c783          	lbu	a5,0(s1)
    80003f64:	05279763          	bne	a5,s2,80003fb2 <namex+0x156>
    path++;
    80003f68:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f6a:	0004c783          	lbu	a5,0(s1)
    80003f6e:	ff278de3          	beq	a5,s2,80003f68 <namex+0x10c>
  if(*path == 0)
    80003f72:	c79d                	beqz	a5,80003fa0 <namex+0x144>
    path++;
    80003f74:	85a6                	mv	a1,s1
  len = path - s;
    80003f76:	8a5e                	mv	s4,s7
    80003f78:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f7a:	01278963          	beq	a5,s2,80003f8c <namex+0x130>
    80003f7e:	dfbd                	beqz	a5,80003efc <namex+0xa0>
    path++;
    80003f80:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f82:	0004c783          	lbu	a5,0(s1)
    80003f86:	ff279ce3          	bne	a5,s2,80003f7e <namex+0x122>
    80003f8a:	bf8d                	j	80003efc <namex+0xa0>
    memmove(name, s, len);
    80003f8c:	2601                	sext.w	a2,a2
    80003f8e:	8556                	mv	a0,s5
    80003f90:	ffffd097          	auipc	ra,0xffffd
    80003f94:	056080e7          	jalr	86(ra) # 80000fe6 <memmove>
    name[len] = 0;
    80003f98:	9a56                	add	s4,s4,s5
    80003f9a:	000a0023          	sb	zero,0(s4)
    80003f9e:	bf9d                	j	80003f14 <namex+0xb8>
  if(nameiparent){
    80003fa0:	f20b03e3          	beqz	s6,80003ec6 <namex+0x6a>
    iput(ip);
    80003fa4:	854e                	mv	a0,s3
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	ade080e7          	jalr	-1314(ra) # 80003a84 <iput>
    return 0;
    80003fae:	4981                	li	s3,0
    80003fb0:	bf19                	j	80003ec6 <namex+0x6a>
  if(*path == 0)
    80003fb2:	d7fd                	beqz	a5,80003fa0 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003fb4:	0004c783          	lbu	a5,0(s1)
    80003fb8:	85a6                	mv	a1,s1
    80003fba:	b7d1                	j	80003f7e <namex+0x122>

0000000080003fbc <dirlink>:
{
    80003fbc:	7139                	addi	sp,sp,-64
    80003fbe:	fc06                	sd	ra,56(sp)
    80003fc0:	f822                	sd	s0,48(sp)
    80003fc2:	f426                	sd	s1,40(sp)
    80003fc4:	f04a                	sd	s2,32(sp)
    80003fc6:	ec4e                	sd	s3,24(sp)
    80003fc8:	e852                	sd	s4,16(sp)
    80003fca:	0080                	addi	s0,sp,64
    80003fcc:	892a                	mv	s2,a0
    80003fce:	8a2e                	mv	s4,a1
    80003fd0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fd2:	4601                	li	a2,0
    80003fd4:	00000097          	auipc	ra,0x0
    80003fd8:	dd8080e7          	jalr	-552(ra) # 80003dac <dirlookup>
    80003fdc:	e93d                	bnez	a0,80004052 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fde:	04c92483          	lw	s1,76(s2)
    80003fe2:	c49d                	beqz	s1,80004010 <dirlink+0x54>
    80003fe4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe6:	4741                	li	a4,16
    80003fe8:	86a6                	mv	a3,s1
    80003fea:	fc040613          	addi	a2,s0,-64
    80003fee:	4581                	li	a1,0
    80003ff0:	854a                	mv	a0,s2
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	b8c080e7          	jalr	-1140(ra) # 80003b7e <readi>
    80003ffa:	47c1                	li	a5,16
    80003ffc:	06f51163          	bne	a0,a5,8000405e <dirlink+0xa2>
    if(de.inum == 0)
    80004000:	fc045783          	lhu	a5,-64(s0)
    80004004:	c791                	beqz	a5,80004010 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004006:	24c1                	addiw	s1,s1,16
    80004008:	04c92783          	lw	a5,76(s2)
    8000400c:	fcf4ede3          	bltu	s1,a5,80003fe6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004010:	4639                	li	a2,14
    80004012:	85d2                	mv	a1,s4
    80004014:	fc240513          	addi	a0,s0,-62
    80004018:	ffffd097          	auipc	ra,0xffffd
    8000401c:	086080e7          	jalr	134(ra) # 8000109e <strncpy>
  de.inum = inum;
    80004020:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004024:	4741                	li	a4,16
    80004026:	86a6                	mv	a3,s1
    80004028:	fc040613          	addi	a2,s0,-64
    8000402c:	4581                	li	a1,0
    8000402e:	854a                	mv	a0,s2
    80004030:	00000097          	auipc	ra,0x0
    80004034:	c46080e7          	jalr	-954(ra) # 80003c76 <writei>
    80004038:	872a                	mv	a4,a0
    8000403a:	47c1                	li	a5,16
  return 0;
    8000403c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000403e:	02f71863          	bne	a4,a5,8000406e <dirlink+0xb2>
}
    80004042:	70e2                	ld	ra,56(sp)
    80004044:	7442                	ld	s0,48(sp)
    80004046:	74a2                	ld	s1,40(sp)
    80004048:	7902                	ld	s2,32(sp)
    8000404a:	69e2                	ld	s3,24(sp)
    8000404c:	6a42                	ld	s4,16(sp)
    8000404e:	6121                	addi	sp,sp,64
    80004050:	8082                	ret
    iput(ip);
    80004052:	00000097          	auipc	ra,0x0
    80004056:	a32080e7          	jalr	-1486(ra) # 80003a84 <iput>
    return -1;
    8000405a:	557d                	li	a0,-1
    8000405c:	b7dd                	j	80004042 <dirlink+0x86>
      panic("dirlink read");
    8000405e:	00004517          	auipc	a0,0x4
    80004062:	59a50513          	addi	a0,a0,1434 # 800085f8 <syscalls+0x1c8>
    80004066:	ffffc097          	auipc	ra,0xffffc
    8000406a:	4e2080e7          	jalr	1250(ra) # 80000548 <panic>
    panic("dirlink");
    8000406e:	00004517          	auipc	a0,0x4
    80004072:	6aa50513          	addi	a0,a0,1706 # 80008718 <syscalls+0x2e8>
    80004076:	ffffc097          	auipc	ra,0xffffc
    8000407a:	4d2080e7          	jalr	1234(ra) # 80000548 <panic>

000000008000407e <namei>:

struct inode*
namei(char *path)
{
    8000407e:	1101                	addi	sp,sp,-32
    80004080:	ec06                	sd	ra,24(sp)
    80004082:	e822                	sd	s0,16(sp)
    80004084:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004086:	fe040613          	addi	a2,s0,-32
    8000408a:	4581                	li	a1,0
    8000408c:	00000097          	auipc	ra,0x0
    80004090:	dd0080e7          	jalr	-560(ra) # 80003e5c <namex>
}
    80004094:	60e2                	ld	ra,24(sp)
    80004096:	6442                	ld	s0,16(sp)
    80004098:	6105                	addi	sp,sp,32
    8000409a:	8082                	ret

000000008000409c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000409c:	1141                	addi	sp,sp,-16
    8000409e:	e406                	sd	ra,8(sp)
    800040a0:	e022                	sd	s0,0(sp)
    800040a2:	0800                	addi	s0,sp,16
    800040a4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040a6:	4585                	li	a1,1
    800040a8:	00000097          	auipc	ra,0x0
    800040ac:	db4080e7          	jalr	-588(ra) # 80003e5c <namex>
}
    800040b0:	60a2                	ld	ra,8(sp)
    800040b2:	6402                	ld	s0,0(sp)
    800040b4:	0141                	addi	sp,sp,16
    800040b6:	8082                	ret

00000000800040b8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040b8:	1101                	addi	sp,sp,-32
    800040ba:	ec06                	sd	ra,24(sp)
    800040bc:	e822                	sd	s0,16(sp)
    800040be:	e426                	sd	s1,8(sp)
    800040c0:	e04a                	sd	s2,0(sp)
    800040c2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040c4:	0111e917          	auipc	s2,0x111e
    800040c8:	84490913          	addi	s2,s2,-1980 # 81121908 <log>
    800040cc:	01892583          	lw	a1,24(s2)
    800040d0:	02892503          	lw	a0,40(s2)
    800040d4:	fffff097          	auipc	ra,0xfffff
    800040d8:	ff4080e7          	jalr	-12(ra) # 800030c8 <bread>
    800040dc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040de:	02c92683          	lw	a3,44(s2)
    800040e2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040e4:	02d05763          	blez	a3,80004112 <write_head+0x5a>
    800040e8:	0111e797          	auipc	a5,0x111e
    800040ec:	85078793          	addi	a5,a5,-1968 # 81121938 <log+0x30>
    800040f0:	05c50713          	addi	a4,a0,92
    800040f4:	36fd                	addiw	a3,a3,-1
    800040f6:	1682                	slli	a3,a3,0x20
    800040f8:	9281                	srli	a3,a3,0x20
    800040fa:	068a                	slli	a3,a3,0x2
    800040fc:	0111e617          	auipc	a2,0x111e
    80004100:	84060613          	addi	a2,a2,-1984 # 8112193c <log+0x34>
    80004104:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004106:	4390                	lw	a2,0(a5)
    80004108:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000410a:	0791                	addi	a5,a5,4
    8000410c:	0711                	addi	a4,a4,4
    8000410e:	fed79ce3          	bne	a5,a3,80004106 <write_head+0x4e>
  }
  bwrite(buf);
    80004112:	8526                	mv	a0,s1
    80004114:	fffff097          	auipc	ra,0xfffff
    80004118:	0a6080e7          	jalr	166(ra) # 800031ba <bwrite>
  brelse(buf);
    8000411c:	8526                	mv	a0,s1
    8000411e:	fffff097          	auipc	ra,0xfffff
    80004122:	0da080e7          	jalr	218(ra) # 800031f8 <brelse>
}
    80004126:	60e2                	ld	ra,24(sp)
    80004128:	6442                	ld	s0,16(sp)
    8000412a:	64a2                	ld	s1,8(sp)
    8000412c:	6902                	ld	s2,0(sp)
    8000412e:	6105                	addi	sp,sp,32
    80004130:	8082                	ret

0000000080004132 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004132:	0111e797          	auipc	a5,0x111e
    80004136:	8027a783          	lw	a5,-2046(a5) # 81121934 <log+0x2c>
    8000413a:	0af05663          	blez	a5,800041e6 <install_trans+0xb4>
{
    8000413e:	7139                	addi	sp,sp,-64
    80004140:	fc06                	sd	ra,56(sp)
    80004142:	f822                	sd	s0,48(sp)
    80004144:	f426                	sd	s1,40(sp)
    80004146:	f04a                	sd	s2,32(sp)
    80004148:	ec4e                	sd	s3,24(sp)
    8000414a:	e852                	sd	s4,16(sp)
    8000414c:	e456                	sd	s5,8(sp)
    8000414e:	0080                	addi	s0,sp,64
    80004150:	0111da97          	auipc	s5,0x111d
    80004154:	7e8a8a93          	addi	s5,s5,2024 # 81121938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004158:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000415a:	0111d997          	auipc	s3,0x111d
    8000415e:	7ae98993          	addi	s3,s3,1966 # 81121908 <log>
    80004162:	0189a583          	lw	a1,24(s3)
    80004166:	014585bb          	addw	a1,a1,s4
    8000416a:	2585                	addiw	a1,a1,1
    8000416c:	0289a503          	lw	a0,40(s3)
    80004170:	fffff097          	auipc	ra,0xfffff
    80004174:	f58080e7          	jalr	-168(ra) # 800030c8 <bread>
    80004178:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000417a:	000aa583          	lw	a1,0(s5)
    8000417e:	0289a503          	lw	a0,40(s3)
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	f46080e7          	jalr	-186(ra) # 800030c8 <bread>
    8000418a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000418c:	40000613          	li	a2,1024
    80004190:	05890593          	addi	a1,s2,88
    80004194:	05850513          	addi	a0,a0,88
    80004198:	ffffd097          	auipc	ra,0xffffd
    8000419c:	e4e080e7          	jalr	-434(ra) # 80000fe6 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041a0:	8526                	mv	a0,s1
    800041a2:	fffff097          	auipc	ra,0xfffff
    800041a6:	018080e7          	jalr	24(ra) # 800031ba <bwrite>
    bunpin(dbuf);
    800041aa:	8526                	mv	a0,s1
    800041ac:	fffff097          	auipc	ra,0xfffff
    800041b0:	126080e7          	jalr	294(ra) # 800032d2 <bunpin>
    brelse(lbuf);
    800041b4:	854a                	mv	a0,s2
    800041b6:	fffff097          	auipc	ra,0xfffff
    800041ba:	042080e7          	jalr	66(ra) # 800031f8 <brelse>
    brelse(dbuf);
    800041be:	8526                	mv	a0,s1
    800041c0:	fffff097          	auipc	ra,0xfffff
    800041c4:	038080e7          	jalr	56(ra) # 800031f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c8:	2a05                	addiw	s4,s4,1
    800041ca:	0a91                	addi	s5,s5,4
    800041cc:	02c9a783          	lw	a5,44(s3)
    800041d0:	f8fa49e3          	blt	s4,a5,80004162 <install_trans+0x30>
}
    800041d4:	70e2                	ld	ra,56(sp)
    800041d6:	7442                	ld	s0,48(sp)
    800041d8:	74a2                	ld	s1,40(sp)
    800041da:	7902                	ld	s2,32(sp)
    800041dc:	69e2                	ld	s3,24(sp)
    800041de:	6a42                	ld	s4,16(sp)
    800041e0:	6aa2                	ld	s5,8(sp)
    800041e2:	6121                	addi	sp,sp,64
    800041e4:	8082                	ret
    800041e6:	8082                	ret

00000000800041e8 <initlog>:
{
    800041e8:	7179                	addi	sp,sp,-48
    800041ea:	f406                	sd	ra,40(sp)
    800041ec:	f022                	sd	s0,32(sp)
    800041ee:	ec26                	sd	s1,24(sp)
    800041f0:	e84a                	sd	s2,16(sp)
    800041f2:	e44e                	sd	s3,8(sp)
    800041f4:	1800                	addi	s0,sp,48
    800041f6:	892a                	mv	s2,a0
    800041f8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041fa:	0111d497          	auipc	s1,0x111d
    800041fe:	70e48493          	addi	s1,s1,1806 # 81121908 <log>
    80004202:	00004597          	auipc	a1,0x4
    80004206:	40658593          	addi	a1,a1,1030 # 80008608 <syscalls+0x1d8>
    8000420a:	8526                	mv	a0,s1
    8000420c:	ffffd097          	auipc	ra,0xffffd
    80004210:	bee080e7          	jalr	-1042(ra) # 80000dfa <initlock>
  log.start = sb->logstart;
    80004214:	0149a583          	lw	a1,20(s3)
    80004218:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000421a:	0109a783          	lw	a5,16(s3)
    8000421e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004220:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004224:	854a                	mv	a0,s2
    80004226:	fffff097          	auipc	ra,0xfffff
    8000422a:	ea2080e7          	jalr	-350(ra) # 800030c8 <bread>
  log.lh.n = lh->n;
    8000422e:	4d3c                	lw	a5,88(a0)
    80004230:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004232:	02f05563          	blez	a5,8000425c <initlog+0x74>
    80004236:	05c50713          	addi	a4,a0,92
    8000423a:	0111d697          	auipc	a3,0x111d
    8000423e:	6fe68693          	addi	a3,a3,1790 # 81121938 <log+0x30>
    80004242:	37fd                	addiw	a5,a5,-1
    80004244:	1782                	slli	a5,a5,0x20
    80004246:	9381                	srli	a5,a5,0x20
    80004248:	078a                	slli	a5,a5,0x2
    8000424a:	06050613          	addi	a2,a0,96
    8000424e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004250:	4310                	lw	a2,0(a4)
    80004252:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004254:	0711                	addi	a4,a4,4
    80004256:	0691                	addi	a3,a3,4
    80004258:	fef71ce3          	bne	a4,a5,80004250 <initlog+0x68>
  brelse(buf);
    8000425c:	fffff097          	auipc	ra,0xfffff
    80004260:	f9c080e7          	jalr	-100(ra) # 800031f8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004264:	00000097          	auipc	ra,0x0
    80004268:	ece080e7          	jalr	-306(ra) # 80004132 <install_trans>
  log.lh.n = 0;
    8000426c:	0111d797          	auipc	a5,0x111d
    80004270:	6c07a423          	sw	zero,1736(a5) # 81121934 <log+0x2c>
  write_head(); // clear the log
    80004274:	00000097          	auipc	ra,0x0
    80004278:	e44080e7          	jalr	-444(ra) # 800040b8 <write_head>
}
    8000427c:	70a2                	ld	ra,40(sp)
    8000427e:	7402                	ld	s0,32(sp)
    80004280:	64e2                	ld	s1,24(sp)
    80004282:	6942                	ld	s2,16(sp)
    80004284:	69a2                	ld	s3,8(sp)
    80004286:	6145                	addi	sp,sp,48
    80004288:	8082                	ret

000000008000428a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000428a:	1101                	addi	sp,sp,-32
    8000428c:	ec06                	sd	ra,24(sp)
    8000428e:	e822                	sd	s0,16(sp)
    80004290:	e426                	sd	s1,8(sp)
    80004292:	e04a                	sd	s2,0(sp)
    80004294:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004296:	0111d517          	auipc	a0,0x111d
    8000429a:	67250513          	addi	a0,a0,1650 # 81121908 <log>
    8000429e:	ffffd097          	auipc	ra,0xffffd
    800042a2:	bec080e7          	jalr	-1044(ra) # 80000e8a <acquire>
  while(1){
    if(log.committing){
    800042a6:	0111d497          	auipc	s1,0x111d
    800042aa:	66248493          	addi	s1,s1,1634 # 81121908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042ae:	4979                	li	s2,30
    800042b0:	a039                	j	800042be <begin_op+0x34>
      sleep(&log, &log.lock);
    800042b2:	85a6                	mv	a1,s1
    800042b4:	8526                	mv	a0,s1
    800042b6:	ffffe097          	auipc	ra,0xffffe
    800042ba:	1c4080e7          	jalr	452(ra) # 8000247a <sleep>
    if(log.committing){
    800042be:	50dc                	lw	a5,36(s1)
    800042c0:	fbed                	bnez	a5,800042b2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042c2:	509c                	lw	a5,32(s1)
    800042c4:	0017871b          	addiw	a4,a5,1
    800042c8:	0007069b          	sext.w	a3,a4
    800042cc:	0027179b          	slliw	a5,a4,0x2
    800042d0:	9fb9                	addw	a5,a5,a4
    800042d2:	0017979b          	slliw	a5,a5,0x1
    800042d6:	54d8                	lw	a4,44(s1)
    800042d8:	9fb9                	addw	a5,a5,a4
    800042da:	00f95963          	bge	s2,a5,800042ec <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042de:	85a6                	mv	a1,s1
    800042e0:	8526                	mv	a0,s1
    800042e2:	ffffe097          	auipc	ra,0xffffe
    800042e6:	198080e7          	jalr	408(ra) # 8000247a <sleep>
    800042ea:	bfd1                	j	800042be <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042ec:	0111d517          	auipc	a0,0x111d
    800042f0:	61c50513          	addi	a0,a0,1564 # 81121908 <log>
    800042f4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800042f6:	ffffd097          	auipc	ra,0xffffd
    800042fa:	c48080e7          	jalr	-952(ra) # 80000f3e <release>
      break;
    }
  }
}
    800042fe:	60e2                	ld	ra,24(sp)
    80004300:	6442                	ld	s0,16(sp)
    80004302:	64a2                	ld	s1,8(sp)
    80004304:	6902                	ld	s2,0(sp)
    80004306:	6105                	addi	sp,sp,32
    80004308:	8082                	ret

000000008000430a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000430a:	7139                	addi	sp,sp,-64
    8000430c:	fc06                	sd	ra,56(sp)
    8000430e:	f822                	sd	s0,48(sp)
    80004310:	f426                	sd	s1,40(sp)
    80004312:	f04a                	sd	s2,32(sp)
    80004314:	ec4e                	sd	s3,24(sp)
    80004316:	e852                	sd	s4,16(sp)
    80004318:	e456                	sd	s5,8(sp)
    8000431a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000431c:	0111d497          	auipc	s1,0x111d
    80004320:	5ec48493          	addi	s1,s1,1516 # 81121908 <log>
    80004324:	8526                	mv	a0,s1
    80004326:	ffffd097          	auipc	ra,0xffffd
    8000432a:	b64080e7          	jalr	-1180(ra) # 80000e8a <acquire>
  log.outstanding -= 1;
    8000432e:	509c                	lw	a5,32(s1)
    80004330:	37fd                	addiw	a5,a5,-1
    80004332:	0007891b          	sext.w	s2,a5
    80004336:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004338:	50dc                	lw	a5,36(s1)
    8000433a:	efb9                	bnez	a5,80004398 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000433c:	06091663          	bnez	s2,800043a8 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004340:	0111d497          	auipc	s1,0x111d
    80004344:	5c848493          	addi	s1,s1,1480 # 81121908 <log>
    80004348:	4785                	li	a5,1
    8000434a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000434c:	8526                	mv	a0,s1
    8000434e:	ffffd097          	auipc	ra,0xffffd
    80004352:	bf0080e7          	jalr	-1040(ra) # 80000f3e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004356:	54dc                	lw	a5,44(s1)
    80004358:	06f04763          	bgtz	a5,800043c6 <end_op+0xbc>
    acquire(&log.lock);
    8000435c:	0111d497          	auipc	s1,0x111d
    80004360:	5ac48493          	addi	s1,s1,1452 # 81121908 <log>
    80004364:	8526                	mv	a0,s1
    80004366:	ffffd097          	auipc	ra,0xffffd
    8000436a:	b24080e7          	jalr	-1244(ra) # 80000e8a <acquire>
    log.committing = 0;
    8000436e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004372:	8526                	mv	a0,s1
    80004374:	ffffe097          	auipc	ra,0xffffe
    80004378:	28c080e7          	jalr	652(ra) # 80002600 <wakeup>
    release(&log.lock);
    8000437c:	8526                	mv	a0,s1
    8000437e:	ffffd097          	auipc	ra,0xffffd
    80004382:	bc0080e7          	jalr	-1088(ra) # 80000f3e <release>
}
    80004386:	70e2                	ld	ra,56(sp)
    80004388:	7442                	ld	s0,48(sp)
    8000438a:	74a2                	ld	s1,40(sp)
    8000438c:	7902                	ld	s2,32(sp)
    8000438e:	69e2                	ld	s3,24(sp)
    80004390:	6a42                	ld	s4,16(sp)
    80004392:	6aa2                	ld	s5,8(sp)
    80004394:	6121                	addi	sp,sp,64
    80004396:	8082                	ret
    panic("log.committing");
    80004398:	00004517          	auipc	a0,0x4
    8000439c:	27850513          	addi	a0,a0,632 # 80008610 <syscalls+0x1e0>
    800043a0:	ffffc097          	auipc	ra,0xffffc
    800043a4:	1a8080e7          	jalr	424(ra) # 80000548 <panic>
    wakeup(&log);
    800043a8:	0111d497          	auipc	s1,0x111d
    800043ac:	56048493          	addi	s1,s1,1376 # 81121908 <log>
    800043b0:	8526                	mv	a0,s1
    800043b2:	ffffe097          	auipc	ra,0xffffe
    800043b6:	24e080e7          	jalr	590(ra) # 80002600 <wakeup>
  release(&log.lock);
    800043ba:	8526                	mv	a0,s1
    800043bc:	ffffd097          	auipc	ra,0xffffd
    800043c0:	b82080e7          	jalr	-1150(ra) # 80000f3e <release>
  if(do_commit){
    800043c4:	b7c9                	j	80004386 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043c6:	0111da97          	auipc	s5,0x111d
    800043ca:	572a8a93          	addi	s5,s5,1394 # 81121938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043ce:	0111da17          	auipc	s4,0x111d
    800043d2:	53aa0a13          	addi	s4,s4,1338 # 81121908 <log>
    800043d6:	018a2583          	lw	a1,24(s4)
    800043da:	012585bb          	addw	a1,a1,s2
    800043de:	2585                	addiw	a1,a1,1
    800043e0:	028a2503          	lw	a0,40(s4)
    800043e4:	fffff097          	auipc	ra,0xfffff
    800043e8:	ce4080e7          	jalr	-796(ra) # 800030c8 <bread>
    800043ec:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043ee:	000aa583          	lw	a1,0(s5)
    800043f2:	028a2503          	lw	a0,40(s4)
    800043f6:	fffff097          	auipc	ra,0xfffff
    800043fa:	cd2080e7          	jalr	-814(ra) # 800030c8 <bread>
    800043fe:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004400:	40000613          	li	a2,1024
    80004404:	05850593          	addi	a1,a0,88
    80004408:	05848513          	addi	a0,s1,88
    8000440c:	ffffd097          	auipc	ra,0xffffd
    80004410:	bda080e7          	jalr	-1062(ra) # 80000fe6 <memmove>
    bwrite(to);  // write the log
    80004414:	8526                	mv	a0,s1
    80004416:	fffff097          	auipc	ra,0xfffff
    8000441a:	da4080e7          	jalr	-604(ra) # 800031ba <bwrite>
    brelse(from);
    8000441e:	854e                	mv	a0,s3
    80004420:	fffff097          	auipc	ra,0xfffff
    80004424:	dd8080e7          	jalr	-552(ra) # 800031f8 <brelse>
    brelse(to);
    80004428:	8526                	mv	a0,s1
    8000442a:	fffff097          	auipc	ra,0xfffff
    8000442e:	dce080e7          	jalr	-562(ra) # 800031f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004432:	2905                	addiw	s2,s2,1
    80004434:	0a91                	addi	s5,s5,4
    80004436:	02ca2783          	lw	a5,44(s4)
    8000443a:	f8f94ee3          	blt	s2,a5,800043d6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000443e:	00000097          	auipc	ra,0x0
    80004442:	c7a080e7          	jalr	-902(ra) # 800040b8 <write_head>
    install_trans(); // Now install writes to home locations
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	cec080e7          	jalr	-788(ra) # 80004132 <install_trans>
    log.lh.n = 0;
    8000444e:	0111d797          	auipc	a5,0x111d
    80004452:	4e07a323          	sw	zero,1254(a5) # 81121934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004456:	00000097          	auipc	ra,0x0
    8000445a:	c62080e7          	jalr	-926(ra) # 800040b8 <write_head>
    8000445e:	bdfd                	j	8000435c <end_op+0x52>

0000000080004460 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004460:	1101                	addi	sp,sp,-32
    80004462:	ec06                	sd	ra,24(sp)
    80004464:	e822                	sd	s0,16(sp)
    80004466:	e426                	sd	s1,8(sp)
    80004468:	e04a                	sd	s2,0(sp)
    8000446a:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000446c:	0111d717          	auipc	a4,0x111d
    80004470:	4c872703          	lw	a4,1224(a4) # 81121934 <log+0x2c>
    80004474:	47f5                	li	a5,29
    80004476:	08e7c063          	blt	a5,a4,800044f6 <log_write+0x96>
    8000447a:	84aa                	mv	s1,a0
    8000447c:	0111d797          	auipc	a5,0x111d
    80004480:	4a87a783          	lw	a5,1192(a5) # 81121924 <log+0x1c>
    80004484:	37fd                	addiw	a5,a5,-1
    80004486:	06f75863          	bge	a4,a5,800044f6 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000448a:	0111d797          	auipc	a5,0x111d
    8000448e:	49e7a783          	lw	a5,1182(a5) # 81121928 <log+0x20>
    80004492:	06f05a63          	blez	a5,80004506 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004496:	0111d917          	auipc	s2,0x111d
    8000449a:	47290913          	addi	s2,s2,1138 # 81121908 <log>
    8000449e:	854a                	mv	a0,s2
    800044a0:	ffffd097          	auipc	ra,0xffffd
    800044a4:	9ea080e7          	jalr	-1558(ra) # 80000e8a <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800044a8:	02c92603          	lw	a2,44(s2)
    800044ac:	06c05563          	blez	a2,80004516 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800044b0:	44cc                	lw	a1,12(s1)
    800044b2:	0111d717          	auipc	a4,0x111d
    800044b6:	48670713          	addi	a4,a4,1158 # 81121938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044ba:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800044bc:	4314                	lw	a3,0(a4)
    800044be:	04b68d63          	beq	a3,a1,80004518 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800044c2:	2785                	addiw	a5,a5,1
    800044c4:	0711                	addi	a4,a4,4
    800044c6:	fec79be3          	bne	a5,a2,800044bc <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044ca:	0621                	addi	a2,a2,8
    800044cc:	060a                	slli	a2,a2,0x2
    800044ce:	0111d797          	auipc	a5,0x111d
    800044d2:	43a78793          	addi	a5,a5,1082 # 81121908 <log>
    800044d6:	963e                	add	a2,a2,a5
    800044d8:	44dc                	lw	a5,12(s1)
    800044da:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044dc:	8526                	mv	a0,s1
    800044de:	fffff097          	auipc	ra,0xfffff
    800044e2:	db8080e7          	jalr	-584(ra) # 80003296 <bpin>
    log.lh.n++;
    800044e6:	0111d717          	auipc	a4,0x111d
    800044ea:	42270713          	addi	a4,a4,1058 # 81121908 <log>
    800044ee:	575c                	lw	a5,44(a4)
    800044f0:	2785                	addiw	a5,a5,1
    800044f2:	d75c                	sw	a5,44(a4)
    800044f4:	a83d                	j	80004532 <log_write+0xd2>
    panic("too big a transaction");
    800044f6:	00004517          	auipc	a0,0x4
    800044fa:	12a50513          	addi	a0,a0,298 # 80008620 <syscalls+0x1f0>
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	04a080e7          	jalr	74(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004506:	00004517          	auipc	a0,0x4
    8000450a:	13250513          	addi	a0,a0,306 # 80008638 <syscalls+0x208>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	03a080e7          	jalr	58(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004516:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004518:	00878713          	addi	a4,a5,8
    8000451c:	00271693          	slli	a3,a4,0x2
    80004520:	0111d717          	auipc	a4,0x111d
    80004524:	3e870713          	addi	a4,a4,1000 # 81121908 <log>
    80004528:	9736                	add	a4,a4,a3
    8000452a:	44d4                	lw	a3,12(s1)
    8000452c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000452e:	faf607e3          	beq	a2,a5,800044dc <log_write+0x7c>
  }
  release(&log.lock);
    80004532:	0111d517          	auipc	a0,0x111d
    80004536:	3d650513          	addi	a0,a0,982 # 81121908 <log>
    8000453a:	ffffd097          	auipc	ra,0xffffd
    8000453e:	a04080e7          	jalr	-1532(ra) # 80000f3e <release>
}
    80004542:	60e2                	ld	ra,24(sp)
    80004544:	6442                	ld	s0,16(sp)
    80004546:	64a2                	ld	s1,8(sp)
    80004548:	6902                	ld	s2,0(sp)
    8000454a:	6105                	addi	sp,sp,32
    8000454c:	8082                	ret

000000008000454e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000454e:	1101                	addi	sp,sp,-32
    80004550:	ec06                	sd	ra,24(sp)
    80004552:	e822                	sd	s0,16(sp)
    80004554:	e426                	sd	s1,8(sp)
    80004556:	e04a                	sd	s2,0(sp)
    80004558:	1000                	addi	s0,sp,32
    8000455a:	84aa                	mv	s1,a0
    8000455c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000455e:	00004597          	auipc	a1,0x4
    80004562:	0fa58593          	addi	a1,a1,250 # 80008658 <syscalls+0x228>
    80004566:	0521                	addi	a0,a0,8
    80004568:	ffffd097          	auipc	ra,0xffffd
    8000456c:	892080e7          	jalr	-1902(ra) # 80000dfa <initlock>
  lk->name = name;
    80004570:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004574:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004578:	0204a423          	sw	zero,40(s1)
}
    8000457c:	60e2                	ld	ra,24(sp)
    8000457e:	6442                	ld	s0,16(sp)
    80004580:	64a2                	ld	s1,8(sp)
    80004582:	6902                	ld	s2,0(sp)
    80004584:	6105                	addi	sp,sp,32
    80004586:	8082                	ret

0000000080004588 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004588:	1101                	addi	sp,sp,-32
    8000458a:	ec06                	sd	ra,24(sp)
    8000458c:	e822                	sd	s0,16(sp)
    8000458e:	e426                	sd	s1,8(sp)
    80004590:	e04a                	sd	s2,0(sp)
    80004592:	1000                	addi	s0,sp,32
    80004594:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004596:	00850913          	addi	s2,a0,8
    8000459a:	854a                	mv	a0,s2
    8000459c:	ffffd097          	auipc	ra,0xffffd
    800045a0:	8ee080e7          	jalr	-1810(ra) # 80000e8a <acquire>
  while (lk->locked) {
    800045a4:	409c                	lw	a5,0(s1)
    800045a6:	cb89                	beqz	a5,800045b8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045a8:	85ca                	mv	a1,s2
    800045aa:	8526                	mv	a0,s1
    800045ac:	ffffe097          	auipc	ra,0xffffe
    800045b0:	ece080e7          	jalr	-306(ra) # 8000247a <sleep>
  while (lk->locked) {
    800045b4:	409c                	lw	a5,0(s1)
    800045b6:	fbed                	bnez	a5,800045a8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045b8:	4785                	li	a5,1
    800045ba:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045bc:	ffffd097          	auipc	ra,0xffffd
    800045c0:	6ae080e7          	jalr	1710(ra) # 80001c6a <myproc>
    800045c4:	5d1c                	lw	a5,56(a0)
    800045c6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045c8:	854a                	mv	a0,s2
    800045ca:	ffffd097          	auipc	ra,0xffffd
    800045ce:	974080e7          	jalr	-1676(ra) # 80000f3e <release>
}
    800045d2:	60e2                	ld	ra,24(sp)
    800045d4:	6442                	ld	s0,16(sp)
    800045d6:	64a2                	ld	s1,8(sp)
    800045d8:	6902                	ld	s2,0(sp)
    800045da:	6105                	addi	sp,sp,32
    800045dc:	8082                	ret

00000000800045de <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045de:	1101                	addi	sp,sp,-32
    800045e0:	ec06                	sd	ra,24(sp)
    800045e2:	e822                	sd	s0,16(sp)
    800045e4:	e426                	sd	s1,8(sp)
    800045e6:	e04a                	sd	s2,0(sp)
    800045e8:	1000                	addi	s0,sp,32
    800045ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045ec:	00850913          	addi	s2,a0,8
    800045f0:	854a                	mv	a0,s2
    800045f2:	ffffd097          	auipc	ra,0xffffd
    800045f6:	898080e7          	jalr	-1896(ra) # 80000e8a <acquire>
  lk->locked = 0;
    800045fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045fe:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004602:	8526                	mv	a0,s1
    80004604:	ffffe097          	auipc	ra,0xffffe
    80004608:	ffc080e7          	jalr	-4(ra) # 80002600 <wakeup>
  release(&lk->lk);
    8000460c:	854a                	mv	a0,s2
    8000460e:	ffffd097          	auipc	ra,0xffffd
    80004612:	930080e7          	jalr	-1744(ra) # 80000f3e <release>
}
    80004616:	60e2                	ld	ra,24(sp)
    80004618:	6442                	ld	s0,16(sp)
    8000461a:	64a2                	ld	s1,8(sp)
    8000461c:	6902                	ld	s2,0(sp)
    8000461e:	6105                	addi	sp,sp,32
    80004620:	8082                	ret

0000000080004622 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004622:	7179                	addi	sp,sp,-48
    80004624:	f406                	sd	ra,40(sp)
    80004626:	f022                	sd	s0,32(sp)
    80004628:	ec26                	sd	s1,24(sp)
    8000462a:	e84a                	sd	s2,16(sp)
    8000462c:	e44e                	sd	s3,8(sp)
    8000462e:	1800                	addi	s0,sp,48
    80004630:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004632:	00850913          	addi	s2,a0,8
    80004636:	854a                	mv	a0,s2
    80004638:	ffffd097          	auipc	ra,0xffffd
    8000463c:	852080e7          	jalr	-1966(ra) # 80000e8a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004640:	409c                	lw	a5,0(s1)
    80004642:	ef99                	bnez	a5,80004660 <holdingsleep+0x3e>
    80004644:	4481                	li	s1,0
  release(&lk->lk);
    80004646:	854a                	mv	a0,s2
    80004648:	ffffd097          	auipc	ra,0xffffd
    8000464c:	8f6080e7          	jalr	-1802(ra) # 80000f3e <release>
  return r;
}
    80004650:	8526                	mv	a0,s1
    80004652:	70a2                	ld	ra,40(sp)
    80004654:	7402                	ld	s0,32(sp)
    80004656:	64e2                	ld	s1,24(sp)
    80004658:	6942                	ld	s2,16(sp)
    8000465a:	69a2                	ld	s3,8(sp)
    8000465c:	6145                	addi	sp,sp,48
    8000465e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004660:	0284a983          	lw	s3,40(s1)
    80004664:	ffffd097          	auipc	ra,0xffffd
    80004668:	606080e7          	jalr	1542(ra) # 80001c6a <myproc>
    8000466c:	5d04                	lw	s1,56(a0)
    8000466e:	413484b3          	sub	s1,s1,s3
    80004672:	0014b493          	seqz	s1,s1
    80004676:	bfc1                	j	80004646 <holdingsleep+0x24>

0000000080004678 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004678:	1141                	addi	sp,sp,-16
    8000467a:	e406                	sd	ra,8(sp)
    8000467c:	e022                	sd	s0,0(sp)
    8000467e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004680:	00004597          	auipc	a1,0x4
    80004684:	fe858593          	addi	a1,a1,-24 # 80008668 <syscalls+0x238>
    80004688:	0111d517          	auipc	a0,0x111d
    8000468c:	3c850513          	addi	a0,a0,968 # 81121a50 <ftable>
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	76a080e7          	jalr	1898(ra) # 80000dfa <initlock>
}
    80004698:	60a2                	ld	ra,8(sp)
    8000469a:	6402                	ld	s0,0(sp)
    8000469c:	0141                	addi	sp,sp,16
    8000469e:	8082                	ret

00000000800046a0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046a0:	1101                	addi	sp,sp,-32
    800046a2:	ec06                	sd	ra,24(sp)
    800046a4:	e822                	sd	s0,16(sp)
    800046a6:	e426                	sd	s1,8(sp)
    800046a8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046aa:	0111d517          	auipc	a0,0x111d
    800046ae:	3a650513          	addi	a0,a0,934 # 81121a50 <ftable>
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	7d8080e7          	jalr	2008(ra) # 80000e8a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046ba:	0111d497          	auipc	s1,0x111d
    800046be:	3ae48493          	addi	s1,s1,942 # 81121a68 <ftable+0x18>
    800046c2:	0111e717          	auipc	a4,0x111e
    800046c6:	34670713          	addi	a4,a4,838 # 81122a08 <ftable+0xfb8>
    if(f->ref == 0){
    800046ca:	40dc                	lw	a5,4(s1)
    800046cc:	cf99                	beqz	a5,800046ea <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046ce:	02848493          	addi	s1,s1,40
    800046d2:	fee49ce3          	bne	s1,a4,800046ca <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046d6:	0111d517          	auipc	a0,0x111d
    800046da:	37a50513          	addi	a0,a0,890 # 81121a50 <ftable>
    800046de:	ffffd097          	auipc	ra,0xffffd
    800046e2:	860080e7          	jalr	-1952(ra) # 80000f3e <release>
  return 0;
    800046e6:	4481                	li	s1,0
    800046e8:	a819                	j	800046fe <filealloc+0x5e>
      f->ref = 1;
    800046ea:	4785                	li	a5,1
    800046ec:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046ee:	0111d517          	auipc	a0,0x111d
    800046f2:	36250513          	addi	a0,a0,866 # 81121a50 <ftable>
    800046f6:	ffffd097          	auipc	ra,0xffffd
    800046fa:	848080e7          	jalr	-1976(ra) # 80000f3e <release>
}
    800046fe:	8526                	mv	a0,s1
    80004700:	60e2                	ld	ra,24(sp)
    80004702:	6442                	ld	s0,16(sp)
    80004704:	64a2                	ld	s1,8(sp)
    80004706:	6105                	addi	sp,sp,32
    80004708:	8082                	ret

000000008000470a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000470a:	1101                	addi	sp,sp,-32
    8000470c:	ec06                	sd	ra,24(sp)
    8000470e:	e822                	sd	s0,16(sp)
    80004710:	e426                	sd	s1,8(sp)
    80004712:	1000                	addi	s0,sp,32
    80004714:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004716:	0111d517          	auipc	a0,0x111d
    8000471a:	33a50513          	addi	a0,a0,826 # 81121a50 <ftable>
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	76c080e7          	jalr	1900(ra) # 80000e8a <acquire>
  if(f->ref < 1)
    80004726:	40dc                	lw	a5,4(s1)
    80004728:	02f05263          	blez	a5,8000474c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000472c:	2785                	addiw	a5,a5,1
    8000472e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004730:	0111d517          	auipc	a0,0x111d
    80004734:	32050513          	addi	a0,a0,800 # 81121a50 <ftable>
    80004738:	ffffd097          	auipc	ra,0xffffd
    8000473c:	806080e7          	jalr	-2042(ra) # 80000f3e <release>
  return f;
}
    80004740:	8526                	mv	a0,s1
    80004742:	60e2                	ld	ra,24(sp)
    80004744:	6442                	ld	s0,16(sp)
    80004746:	64a2                	ld	s1,8(sp)
    80004748:	6105                	addi	sp,sp,32
    8000474a:	8082                	ret
    panic("filedup");
    8000474c:	00004517          	auipc	a0,0x4
    80004750:	f2450513          	addi	a0,a0,-220 # 80008670 <syscalls+0x240>
    80004754:	ffffc097          	auipc	ra,0xffffc
    80004758:	df4080e7          	jalr	-524(ra) # 80000548 <panic>

000000008000475c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000475c:	7139                	addi	sp,sp,-64
    8000475e:	fc06                	sd	ra,56(sp)
    80004760:	f822                	sd	s0,48(sp)
    80004762:	f426                	sd	s1,40(sp)
    80004764:	f04a                	sd	s2,32(sp)
    80004766:	ec4e                	sd	s3,24(sp)
    80004768:	e852                	sd	s4,16(sp)
    8000476a:	e456                	sd	s5,8(sp)
    8000476c:	0080                	addi	s0,sp,64
    8000476e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004770:	0111d517          	auipc	a0,0x111d
    80004774:	2e050513          	addi	a0,a0,736 # 81121a50 <ftable>
    80004778:	ffffc097          	auipc	ra,0xffffc
    8000477c:	712080e7          	jalr	1810(ra) # 80000e8a <acquire>
  if(f->ref < 1)
    80004780:	40dc                	lw	a5,4(s1)
    80004782:	06f05163          	blez	a5,800047e4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004786:	37fd                	addiw	a5,a5,-1
    80004788:	0007871b          	sext.w	a4,a5
    8000478c:	c0dc                	sw	a5,4(s1)
    8000478e:	06e04363          	bgtz	a4,800047f4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004792:	0004a903          	lw	s2,0(s1)
    80004796:	0094ca83          	lbu	s5,9(s1)
    8000479a:	0104ba03          	ld	s4,16(s1)
    8000479e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047a2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047a6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047aa:	0111d517          	auipc	a0,0x111d
    800047ae:	2a650513          	addi	a0,a0,678 # 81121a50 <ftable>
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	78c080e7          	jalr	1932(ra) # 80000f3e <release>

  if(ff.type == FD_PIPE){
    800047ba:	4785                	li	a5,1
    800047bc:	04f90d63          	beq	s2,a5,80004816 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047c0:	3979                	addiw	s2,s2,-2
    800047c2:	4785                	li	a5,1
    800047c4:	0527e063          	bltu	a5,s2,80004804 <fileclose+0xa8>
    begin_op();
    800047c8:	00000097          	auipc	ra,0x0
    800047cc:	ac2080e7          	jalr	-1342(ra) # 8000428a <begin_op>
    iput(ff.ip);
    800047d0:	854e                	mv	a0,s3
    800047d2:	fffff097          	auipc	ra,0xfffff
    800047d6:	2b2080e7          	jalr	690(ra) # 80003a84 <iput>
    end_op();
    800047da:	00000097          	auipc	ra,0x0
    800047de:	b30080e7          	jalr	-1232(ra) # 8000430a <end_op>
    800047e2:	a00d                	j	80004804 <fileclose+0xa8>
    panic("fileclose");
    800047e4:	00004517          	auipc	a0,0x4
    800047e8:	e9450513          	addi	a0,a0,-364 # 80008678 <syscalls+0x248>
    800047ec:	ffffc097          	auipc	ra,0xffffc
    800047f0:	d5c080e7          	jalr	-676(ra) # 80000548 <panic>
    release(&ftable.lock);
    800047f4:	0111d517          	auipc	a0,0x111d
    800047f8:	25c50513          	addi	a0,a0,604 # 81121a50 <ftable>
    800047fc:	ffffc097          	auipc	ra,0xffffc
    80004800:	742080e7          	jalr	1858(ra) # 80000f3e <release>
  }
}
    80004804:	70e2                	ld	ra,56(sp)
    80004806:	7442                	ld	s0,48(sp)
    80004808:	74a2                	ld	s1,40(sp)
    8000480a:	7902                	ld	s2,32(sp)
    8000480c:	69e2                	ld	s3,24(sp)
    8000480e:	6a42                	ld	s4,16(sp)
    80004810:	6aa2                	ld	s5,8(sp)
    80004812:	6121                	addi	sp,sp,64
    80004814:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004816:	85d6                	mv	a1,s5
    80004818:	8552                	mv	a0,s4
    8000481a:	00000097          	auipc	ra,0x0
    8000481e:	372080e7          	jalr	882(ra) # 80004b8c <pipeclose>
    80004822:	b7cd                	j	80004804 <fileclose+0xa8>

0000000080004824 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004824:	715d                	addi	sp,sp,-80
    80004826:	e486                	sd	ra,72(sp)
    80004828:	e0a2                	sd	s0,64(sp)
    8000482a:	fc26                	sd	s1,56(sp)
    8000482c:	f84a                	sd	s2,48(sp)
    8000482e:	f44e                	sd	s3,40(sp)
    80004830:	0880                	addi	s0,sp,80
    80004832:	84aa                	mv	s1,a0
    80004834:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004836:	ffffd097          	auipc	ra,0xffffd
    8000483a:	434080e7          	jalr	1076(ra) # 80001c6a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000483e:	409c                	lw	a5,0(s1)
    80004840:	37f9                	addiw	a5,a5,-2
    80004842:	4705                	li	a4,1
    80004844:	04f76763          	bltu	a4,a5,80004892 <filestat+0x6e>
    80004848:	892a                	mv	s2,a0
    ilock(f->ip);
    8000484a:	6c88                	ld	a0,24(s1)
    8000484c:	fffff097          	auipc	ra,0xfffff
    80004850:	07e080e7          	jalr	126(ra) # 800038ca <ilock>
    stati(f->ip, &st);
    80004854:	fb840593          	addi	a1,s0,-72
    80004858:	6c88                	ld	a0,24(s1)
    8000485a:	fffff097          	auipc	ra,0xfffff
    8000485e:	2fa080e7          	jalr	762(ra) # 80003b54 <stati>
    iunlock(f->ip);
    80004862:	6c88                	ld	a0,24(s1)
    80004864:	fffff097          	auipc	ra,0xfffff
    80004868:	128080e7          	jalr	296(ra) # 8000398c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000486c:	46e1                	li	a3,24
    8000486e:	fb840613          	addi	a2,s0,-72
    80004872:	85ce                	mv	a1,s3
    80004874:	05093503          	ld	a0,80(s2)
    80004878:	ffffd097          	auipc	ra,0xffffd
    8000487c:	0c0080e7          	jalr	192(ra) # 80001938 <copyout>
    80004880:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004884:	60a6                	ld	ra,72(sp)
    80004886:	6406                	ld	s0,64(sp)
    80004888:	74e2                	ld	s1,56(sp)
    8000488a:	7942                	ld	s2,48(sp)
    8000488c:	79a2                	ld	s3,40(sp)
    8000488e:	6161                	addi	sp,sp,80
    80004890:	8082                	ret
  return -1;
    80004892:	557d                	li	a0,-1
    80004894:	bfc5                	j	80004884 <filestat+0x60>

0000000080004896 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004896:	7179                	addi	sp,sp,-48
    80004898:	f406                	sd	ra,40(sp)
    8000489a:	f022                	sd	s0,32(sp)
    8000489c:	ec26                	sd	s1,24(sp)
    8000489e:	e84a                	sd	s2,16(sp)
    800048a0:	e44e                	sd	s3,8(sp)
    800048a2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048a4:	00854783          	lbu	a5,8(a0)
    800048a8:	c3d5                	beqz	a5,8000494c <fileread+0xb6>
    800048aa:	84aa                	mv	s1,a0
    800048ac:	89ae                	mv	s3,a1
    800048ae:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048b0:	411c                	lw	a5,0(a0)
    800048b2:	4705                	li	a4,1
    800048b4:	04e78963          	beq	a5,a4,80004906 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048b8:	470d                	li	a4,3
    800048ba:	04e78d63          	beq	a5,a4,80004914 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048be:	4709                	li	a4,2
    800048c0:	06e79e63          	bne	a5,a4,8000493c <fileread+0xa6>
    ilock(f->ip);
    800048c4:	6d08                	ld	a0,24(a0)
    800048c6:	fffff097          	auipc	ra,0xfffff
    800048ca:	004080e7          	jalr	4(ra) # 800038ca <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048ce:	874a                	mv	a4,s2
    800048d0:	5094                	lw	a3,32(s1)
    800048d2:	864e                	mv	a2,s3
    800048d4:	4585                	li	a1,1
    800048d6:	6c88                	ld	a0,24(s1)
    800048d8:	fffff097          	auipc	ra,0xfffff
    800048dc:	2a6080e7          	jalr	678(ra) # 80003b7e <readi>
    800048e0:	892a                	mv	s2,a0
    800048e2:	00a05563          	blez	a0,800048ec <fileread+0x56>
      f->off += r;
    800048e6:	509c                	lw	a5,32(s1)
    800048e8:	9fa9                	addw	a5,a5,a0
    800048ea:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048ec:	6c88                	ld	a0,24(s1)
    800048ee:	fffff097          	auipc	ra,0xfffff
    800048f2:	09e080e7          	jalr	158(ra) # 8000398c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048f6:	854a                	mv	a0,s2
    800048f8:	70a2                	ld	ra,40(sp)
    800048fa:	7402                	ld	s0,32(sp)
    800048fc:	64e2                	ld	s1,24(sp)
    800048fe:	6942                	ld	s2,16(sp)
    80004900:	69a2                	ld	s3,8(sp)
    80004902:	6145                	addi	sp,sp,48
    80004904:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004906:	6908                	ld	a0,16(a0)
    80004908:	00000097          	auipc	ra,0x0
    8000490c:	418080e7          	jalr	1048(ra) # 80004d20 <piperead>
    80004910:	892a                	mv	s2,a0
    80004912:	b7d5                	j	800048f6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004914:	02451783          	lh	a5,36(a0)
    80004918:	03079693          	slli	a3,a5,0x30
    8000491c:	92c1                	srli	a3,a3,0x30
    8000491e:	4725                	li	a4,9
    80004920:	02d76863          	bltu	a4,a3,80004950 <fileread+0xba>
    80004924:	0792                	slli	a5,a5,0x4
    80004926:	0111d717          	auipc	a4,0x111d
    8000492a:	08a70713          	addi	a4,a4,138 # 811219b0 <devsw>
    8000492e:	97ba                	add	a5,a5,a4
    80004930:	639c                	ld	a5,0(a5)
    80004932:	c38d                	beqz	a5,80004954 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004934:	4505                	li	a0,1
    80004936:	9782                	jalr	a5
    80004938:	892a                	mv	s2,a0
    8000493a:	bf75                	j	800048f6 <fileread+0x60>
    panic("fileread");
    8000493c:	00004517          	auipc	a0,0x4
    80004940:	d4c50513          	addi	a0,a0,-692 # 80008688 <syscalls+0x258>
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	c04080e7          	jalr	-1020(ra) # 80000548 <panic>
    return -1;
    8000494c:	597d                	li	s2,-1
    8000494e:	b765                	j	800048f6 <fileread+0x60>
      return -1;
    80004950:	597d                	li	s2,-1
    80004952:	b755                	j	800048f6 <fileread+0x60>
    80004954:	597d                	li	s2,-1
    80004956:	b745                	j	800048f6 <fileread+0x60>

0000000080004958 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004958:	00954783          	lbu	a5,9(a0)
    8000495c:	14078563          	beqz	a5,80004aa6 <filewrite+0x14e>
{
    80004960:	715d                	addi	sp,sp,-80
    80004962:	e486                	sd	ra,72(sp)
    80004964:	e0a2                	sd	s0,64(sp)
    80004966:	fc26                	sd	s1,56(sp)
    80004968:	f84a                	sd	s2,48(sp)
    8000496a:	f44e                	sd	s3,40(sp)
    8000496c:	f052                	sd	s4,32(sp)
    8000496e:	ec56                	sd	s5,24(sp)
    80004970:	e85a                	sd	s6,16(sp)
    80004972:	e45e                	sd	s7,8(sp)
    80004974:	e062                	sd	s8,0(sp)
    80004976:	0880                	addi	s0,sp,80
    80004978:	892a                	mv	s2,a0
    8000497a:	8aae                	mv	s5,a1
    8000497c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000497e:	411c                	lw	a5,0(a0)
    80004980:	4705                	li	a4,1
    80004982:	02e78263          	beq	a5,a4,800049a6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004986:	470d                	li	a4,3
    80004988:	02e78563          	beq	a5,a4,800049b2 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000498c:	4709                	li	a4,2
    8000498e:	10e79463          	bne	a5,a4,80004a96 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004992:	0ec05e63          	blez	a2,80004a8e <filewrite+0x136>
    int i = 0;
    80004996:	4981                	li	s3,0
    80004998:	6b05                	lui	s6,0x1
    8000499a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000499e:	6b85                	lui	s7,0x1
    800049a0:	c00b8b9b          	addiw	s7,s7,-1024
    800049a4:	a851                	j	80004a38 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049a6:	6908                	ld	a0,16(a0)
    800049a8:	00000097          	auipc	ra,0x0
    800049ac:	254080e7          	jalr	596(ra) # 80004bfc <pipewrite>
    800049b0:	a85d                	j	80004a66 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049b2:	02451783          	lh	a5,36(a0)
    800049b6:	03079693          	slli	a3,a5,0x30
    800049ba:	92c1                	srli	a3,a3,0x30
    800049bc:	4725                	li	a4,9
    800049be:	0ed76663          	bltu	a4,a3,80004aaa <filewrite+0x152>
    800049c2:	0792                	slli	a5,a5,0x4
    800049c4:	0111d717          	auipc	a4,0x111d
    800049c8:	fec70713          	addi	a4,a4,-20 # 811219b0 <devsw>
    800049cc:	97ba                	add	a5,a5,a4
    800049ce:	679c                	ld	a5,8(a5)
    800049d0:	cff9                	beqz	a5,80004aae <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    800049d2:	4505                	li	a0,1
    800049d4:	9782                	jalr	a5
    800049d6:	a841                	j	80004a66 <filewrite+0x10e>
    800049d8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049dc:	00000097          	auipc	ra,0x0
    800049e0:	8ae080e7          	jalr	-1874(ra) # 8000428a <begin_op>
      ilock(f->ip);
    800049e4:	01893503          	ld	a0,24(s2)
    800049e8:	fffff097          	auipc	ra,0xfffff
    800049ec:	ee2080e7          	jalr	-286(ra) # 800038ca <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049f0:	8762                	mv	a4,s8
    800049f2:	02092683          	lw	a3,32(s2)
    800049f6:	01598633          	add	a2,s3,s5
    800049fa:	4585                	li	a1,1
    800049fc:	01893503          	ld	a0,24(s2)
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	276080e7          	jalr	630(ra) # 80003c76 <writei>
    80004a08:	84aa                	mv	s1,a0
    80004a0a:	02a05f63          	blez	a0,80004a48 <filewrite+0xf0>
        f->off += r;
    80004a0e:	02092783          	lw	a5,32(s2)
    80004a12:	9fa9                	addw	a5,a5,a0
    80004a14:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a18:	01893503          	ld	a0,24(s2)
    80004a1c:	fffff097          	auipc	ra,0xfffff
    80004a20:	f70080e7          	jalr	-144(ra) # 8000398c <iunlock>
      end_op();
    80004a24:	00000097          	auipc	ra,0x0
    80004a28:	8e6080e7          	jalr	-1818(ra) # 8000430a <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a2c:	049c1963          	bne	s8,s1,80004a7e <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004a30:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a34:	0349d663          	bge	s3,s4,80004a60 <filewrite+0x108>
      int n1 = n - i;
    80004a38:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a3c:	84be                	mv	s1,a5
    80004a3e:	2781                	sext.w	a5,a5
    80004a40:	f8fb5ce3          	bge	s6,a5,800049d8 <filewrite+0x80>
    80004a44:	84de                	mv	s1,s7
    80004a46:	bf49                	j	800049d8 <filewrite+0x80>
      iunlock(f->ip);
    80004a48:	01893503          	ld	a0,24(s2)
    80004a4c:	fffff097          	auipc	ra,0xfffff
    80004a50:	f40080e7          	jalr	-192(ra) # 8000398c <iunlock>
      end_op();
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	8b6080e7          	jalr	-1866(ra) # 8000430a <end_op>
      if(r < 0)
    80004a5c:	fc04d8e3          	bgez	s1,80004a2c <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004a60:	8552                	mv	a0,s4
    80004a62:	033a1863          	bne	s4,s3,80004a92 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a66:	60a6                	ld	ra,72(sp)
    80004a68:	6406                	ld	s0,64(sp)
    80004a6a:	74e2                	ld	s1,56(sp)
    80004a6c:	7942                	ld	s2,48(sp)
    80004a6e:	79a2                	ld	s3,40(sp)
    80004a70:	7a02                	ld	s4,32(sp)
    80004a72:	6ae2                	ld	s5,24(sp)
    80004a74:	6b42                	ld	s6,16(sp)
    80004a76:	6ba2                	ld	s7,8(sp)
    80004a78:	6c02                	ld	s8,0(sp)
    80004a7a:	6161                	addi	sp,sp,80
    80004a7c:	8082                	ret
        panic("short filewrite");
    80004a7e:	00004517          	auipc	a0,0x4
    80004a82:	c1a50513          	addi	a0,a0,-998 # 80008698 <syscalls+0x268>
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	ac2080e7          	jalr	-1342(ra) # 80000548 <panic>
    int i = 0;
    80004a8e:	4981                	li	s3,0
    80004a90:	bfc1                	j	80004a60 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004a92:	557d                	li	a0,-1
    80004a94:	bfc9                	j	80004a66 <filewrite+0x10e>
    panic("filewrite");
    80004a96:	00004517          	auipc	a0,0x4
    80004a9a:	c1250513          	addi	a0,a0,-1006 # 800086a8 <syscalls+0x278>
    80004a9e:	ffffc097          	auipc	ra,0xffffc
    80004aa2:	aaa080e7          	jalr	-1366(ra) # 80000548 <panic>
    return -1;
    80004aa6:	557d                	li	a0,-1
}
    80004aa8:	8082                	ret
      return -1;
    80004aaa:	557d                	li	a0,-1
    80004aac:	bf6d                	j	80004a66 <filewrite+0x10e>
    80004aae:	557d                	li	a0,-1
    80004ab0:	bf5d                	j	80004a66 <filewrite+0x10e>

0000000080004ab2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ab2:	7179                	addi	sp,sp,-48
    80004ab4:	f406                	sd	ra,40(sp)
    80004ab6:	f022                	sd	s0,32(sp)
    80004ab8:	ec26                	sd	s1,24(sp)
    80004aba:	e84a                	sd	s2,16(sp)
    80004abc:	e44e                	sd	s3,8(sp)
    80004abe:	e052                	sd	s4,0(sp)
    80004ac0:	1800                	addi	s0,sp,48
    80004ac2:	84aa                	mv	s1,a0
    80004ac4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ac6:	0005b023          	sd	zero,0(a1)
    80004aca:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ace:	00000097          	auipc	ra,0x0
    80004ad2:	bd2080e7          	jalr	-1070(ra) # 800046a0 <filealloc>
    80004ad6:	e088                	sd	a0,0(s1)
    80004ad8:	c551                	beqz	a0,80004b64 <pipealloc+0xb2>
    80004ada:	00000097          	auipc	ra,0x0
    80004ade:	bc6080e7          	jalr	-1082(ra) # 800046a0 <filealloc>
    80004ae2:	00aa3023          	sd	a0,0(s4)
    80004ae6:	c92d                	beqz	a0,80004b58 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	0c0080e7          	jalr	192(ra) # 80000ba8 <kalloc>
    80004af0:	892a                	mv	s2,a0
    80004af2:	c125                	beqz	a0,80004b52 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004af4:	4985                	li	s3,1
    80004af6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004afa:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004afe:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b02:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b06:	00004597          	auipc	a1,0x4
    80004b0a:	bb258593          	addi	a1,a1,-1102 # 800086b8 <syscalls+0x288>
    80004b0e:	ffffc097          	auipc	ra,0xffffc
    80004b12:	2ec080e7          	jalr	748(ra) # 80000dfa <initlock>
  (*f0)->type = FD_PIPE;
    80004b16:	609c                	ld	a5,0(s1)
    80004b18:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b1c:	609c                	ld	a5,0(s1)
    80004b1e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b22:	609c                	ld	a5,0(s1)
    80004b24:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b28:	609c                	ld	a5,0(s1)
    80004b2a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b2e:	000a3783          	ld	a5,0(s4)
    80004b32:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b36:	000a3783          	ld	a5,0(s4)
    80004b3a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b3e:	000a3783          	ld	a5,0(s4)
    80004b42:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b46:	000a3783          	ld	a5,0(s4)
    80004b4a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b4e:	4501                	li	a0,0
    80004b50:	a025                	j	80004b78 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b52:	6088                	ld	a0,0(s1)
    80004b54:	e501                	bnez	a0,80004b5c <pipealloc+0xaa>
    80004b56:	a039                	j	80004b64 <pipealloc+0xb2>
    80004b58:	6088                	ld	a0,0(s1)
    80004b5a:	c51d                	beqz	a0,80004b88 <pipealloc+0xd6>
    fileclose(*f0);
    80004b5c:	00000097          	auipc	ra,0x0
    80004b60:	c00080e7          	jalr	-1024(ra) # 8000475c <fileclose>
  if(*f1)
    80004b64:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b68:	557d                	li	a0,-1
  if(*f1)
    80004b6a:	c799                	beqz	a5,80004b78 <pipealloc+0xc6>
    fileclose(*f1);
    80004b6c:	853e                	mv	a0,a5
    80004b6e:	00000097          	auipc	ra,0x0
    80004b72:	bee080e7          	jalr	-1042(ra) # 8000475c <fileclose>
  return -1;
    80004b76:	557d                	li	a0,-1
}
    80004b78:	70a2                	ld	ra,40(sp)
    80004b7a:	7402                	ld	s0,32(sp)
    80004b7c:	64e2                	ld	s1,24(sp)
    80004b7e:	6942                	ld	s2,16(sp)
    80004b80:	69a2                	ld	s3,8(sp)
    80004b82:	6a02                	ld	s4,0(sp)
    80004b84:	6145                	addi	sp,sp,48
    80004b86:	8082                	ret
  return -1;
    80004b88:	557d                	li	a0,-1
    80004b8a:	b7fd                	j	80004b78 <pipealloc+0xc6>

0000000080004b8c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b8c:	1101                	addi	sp,sp,-32
    80004b8e:	ec06                	sd	ra,24(sp)
    80004b90:	e822                	sd	s0,16(sp)
    80004b92:	e426                	sd	s1,8(sp)
    80004b94:	e04a                	sd	s2,0(sp)
    80004b96:	1000                	addi	s0,sp,32
    80004b98:	84aa                	mv	s1,a0
    80004b9a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	2ee080e7          	jalr	750(ra) # 80000e8a <acquire>
  if(writable){
    80004ba4:	02090d63          	beqz	s2,80004bde <pipeclose+0x52>
    pi->writeopen = 0;
    80004ba8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bac:	21848513          	addi	a0,s1,536
    80004bb0:	ffffe097          	auipc	ra,0xffffe
    80004bb4:	a50080e7          	jalr	-1456(ra) # 80002600 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bb8:	2204b783          	ld	a5,544(s1)
    80004bbc:	eb95                	bnez	a5,80004bf0 <pipeclose+0x64>
    release(&pi->lock);
    80004bbe:	8526                	mv	a0,s1
    80004bc0:	ffffc097          	auipc	ra,0xffffc
    80004bc4:	37e080e7          	jalr	894(ra) # 80000f3e <release>
    kfree((char*)pi);
    80004bc8:	8526                	mv	a0,s1
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	e5a080e7          	jalr	-422(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    80004bd2:	60e2                	ld	ra,24(sp)
    80004bd4:	6442                	ld	s0,16(sp)
    80004bd6:	64a2                	ld	s1,8(sp)
    80004bd8:	6902                	ld	s2,0(sp)
    80004bda:	6105                	addi	sp,sp,32
    80004bdc:	8082                	ret
    pi->readopen = 0;
    80004bde:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004be2:	21c48513          	addi	a0,s1,540
    80004be6:	ffffe097          	auipc	ra,0xffffe
    80004bea:	a1a080e7          	jalr	-1510(ra) # 80002600 <wakeup>
    80004bee:	b7e9                	j	80004bb8 <pipeclose+0x2c>
    release(&pi->lock);
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	34c080e7          	jalr	844(ra) # 80000f3e <release>
}
    80004bfa:	bfe1                	j	80004bd2 <pipeclose+0x46>

0000000080004bfc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bfc:	7119                	addi	sp,sp,-128
    80004bfe:	fc86                	sd	ra,120(sp)
    80004c00:	f8a2                	sd	s0,112(sp)
    80004c02:	f4a6                	sd	s1,104(sp)
    80004c04:	f0ca                	sd	s2,96(sp)
    80004c06:	ecce                	sd	s3,88(sp)
    80004c08:	e8d2                	sd	s4,80(sp)
    80004c0a:	e4d6                	sd	s5,72(sp)
    80004c0c:	e0da                	sd	s6,64(sp)
    80004c0e:	fc5e                	sd	s7,56(sp)
    80004c10:	f862                	sd	s8,48(sp)
    80004c12:	f466                	sd	s9,40(sp)
    80004c14:	f06a                	sd	s10,32(sp)
    80004c16:	ec6e                	sd	s11,24(sp)
    80004c18:	0100                	addi	s0,sp,128
    80004c1a:	84aa                	mv	s1,a0
    80004c1c:	8cae                	mv	s9,a1
    80004c1e:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c20:	ffffd097          	auipc	ra,0xffffd
    80004c24:	04a080e7          	jalr	74(ra) # 80001c6a <myproc>
    80004c28:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004c2a:	8526                	mv	a0,s1
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	25e080e7          	jalr	606(ra) # 80000e8a <acquire>
  for(i = 0; i < n; i++){
    80004c34:	0d605963          	blez	s6,80004d06 <pipewrite+0x10a>
    80004c38:	89a6                	mv	s3,s1
    80004c3a:	3b7d                	addiw	s6,s6,-1
    80004c3c:	1b02                	slli	s6,s6,0x20
    80004c3e:	020b5b13          	srli	s6,s6,0x20
    80004c42:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c44:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c48:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c4c:	5dfd                	li	s11,-1
    80004c4e:	000b8d1b          	sext.w	s10,s7
    80004c52:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c54:	2184a783          	lw	a5,536(s1)
    80004c58:	21c4a703          	lw	a4,540(s1)
    80004c5c:	2007879b          	addiw	a5,a5,512
    80004c60:	02f71b63          	bne	a4,a5,80004c96 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004c64:	2204a783          	lw	a5,544(s1)
    80004c68:	cbad                	beqz	a5,80004cda <pipewrite+0xde>
    80004c6a:	03092783          	lw	a5,48(s2)
    80004c6e:	e7b5                	bnez	a5,80004cda <pipewrite+0xde>
      wakeup(&pi->nread);
    80004c70:	8556                	mv	a0,s5
    80004c72:	ffffe097          	auipc	ra,0xffffe
    80004c76:	98e080e7          	jalr	-1650(ra) # 80002600 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c7a:	85ce                	mv	a1,s3
    80004c7c:	8552                	mv	a0,s4
    80004c7e:	ffffd097          	auipc	ra,0xffffd
    80004c82:	7fc080e7          	jalr	2044(ra) # 8000247a <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c86:	2184a783          	lw	a5,536(s1)
    80004c8a:	21c4a703          	lw	a4,540(s1)
    80004c8e:	2007879b          	addiw	a5,a5,512
    80004c92:	fcf709e3          	beq	a4,a5,80004c64 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c96:	4685                	li	a3,1
    80004c98:	019b8633          	add	a2,s7,s9
    80004c9c:	f8f40593          	addi	a1,s0,-113
    80004ca0:	05093503          	ld	a0,80(s2)
    80004ca4:	ffffd097          	auipc	ra,0xffffd
    80004ca8:	d46080e7          	jalr	-698(ra) # 800019ea <copyin>
    80004cac:	05b50e63          	beq	a0,s11,80004d08 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cb0:	21c4a783          	lw	a5,540(s1)
    80004cb4:	0017871b          	addiw	a4,a5,1
    80004cb8:	20e4ae23          	sw	a4,540(s1)
    80004cbc:	1ff7f793          	andi	a5,a5,511
    80004cc0:	97a6                	add	a5,a5,s1
    80004cc2:	f8f44703          	lbu	a4,-113(s0)
    80004cc6:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004cca:	001d0c1b          	addiw	s8,s10,1
    80004cce:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004cd2:	036b8b63          	beq	s7,s6,80004d08 <pipewrite+0x10c>
    80004cd6:	8bbe                	mv	s7,a5
    80004cd8:	bf9d                	j	80004c4e <pipewrite+0x52>
        release(&pi->lock);
    80004cda:	8526                	mv	a0,s1
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	262080e7          	jalr	610(ra) # 80000f3e <release>
        return -1;
    80004ce4:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004ce6:	8562                	mv	a0,s8
    80004ce8:	70e6                	ld	ra,120(sp)
    80004cea:	7446                	ld	s0,112(sp)
    80004cec:	74a6                	ld	s1,104(sp)
    80004cee:	7906                	ld	s2,96(sp)
    80004cf0:	69e6                	ld	s3,88(sp)
    80004cf2:	6a46                	ld	s4,80(sp)
    80004cf4:	6aa6                	ld	s5,72(sp)
    80004cf6:	6b06                	ld	s6,64(sp)
    80004cf8:	7be2                	ld	s7,56(sp)
    80004cfa:	7c42                	ld	s8,48(sp)
    80004cfc:	7ca2                	ld	s9,40(sp)
    80004cfe:	7d02                	ld	s10,32(sp)
    80004d00:	6de2                	ld	s11,24(sp)
    80004d02:	6109                	addi	sp,sp,128
    80004d04:	8082                	ret
  for(i = 0; i < n; i++){
    80004d06:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004d08:	21848513          	addi	a0,s1,536
    80004d0c:	ffffe097          	auipc	ra,0xffffe
    80004d10:	8f4080e7          	jalr	-1804(ra) # 80002600 <wakeup>
  release(&pi->lock);
    80004d14:	8526                	mv	a0,s1
    80004d16:	ffffc097          	auipc	ra,0xffffc
    80004d1a:	228080e7          	jalr	552(ra) # 80000f3e <release>
  return i;
    80004d1e:	b7e1                	j	80004ce6 <pipewrite+0xea>

0000000080004d20 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d20:	715d                	addi	sp,sp,-80
    80004d22:	e486                	sd	ra,72(sp)
    80004d24:	e0a2                	sd	s0,64(sp)
    80004d26:	fc26                	sd	s1,56(sp)
    80004d28:	f84a                	sd	s2,48(sp)
    80004d2a:	f44e                	sd	s3,40(sp)
    80004d2c:	f052                	sd	s4,32(sp)
    80004d2e:	ec56                	sd	s5,24(sp)
    80004d30:	e85a                	sd	s6,16(sp)
    80004d32:	0880                	addi	s0,sp,80
    80004d34:	84aa                	mv	s1,a0
    80004d36:	892e                	mv	s2,a1
    80004d38:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d3a:	ffffd097          	auipc	ra,0xffffd
    80004d3e:	f30080e7          	jalr	-208(ra) # 80001c6a <myproc>
    80004d42:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d44:	8b26                	mv	s6,s1
    80004d46:	8526                	mv	a0,s1
    80004d48:	ffffc097          	auipc	ra,0xffffc
    80004d4c:	142080e7          	jalr	322(ra) # 80000e8a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d50:	2184a703          	lw	a4,536(s1)
    80004d54:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d58:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d5c:	02f71463          	bne	a4,a5,80004d84 <piperead+0x64>
    80004d60:	2244a783          	lw	a5,548(s1)
    80004d64:	c385                	beqz	a5,80004d84 <piperead+0x64>
    if(pr->killed){
    80004d66:	030a2783          	lw	a5,48(s4)
    80004d6a:	ebc1                	bnez	a5,80004dfa <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d6c:	85da                	mv	a1,s6
    80004d6e:	854e                	mv	a0,s3
    80004d70:	ffffd097          	auipc	ra,0xffffd
    80004d74:	70a080e7          	jalr	1802(ra) # 8000247a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d78:	2184a703          	lw	a4,536(s1)
    80004d7c:	21c4a783          	lw	a5,540(s1)
    80004d80:	fef700e3          	beq	a4,a5,80004d60 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d84:	09505263          	blez	s5,80004e08 <piperead+0xe8>
    80004d88:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d8a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004d8c:	2184a783          	lw	a5,536(s1)
    80004d90:	21c4a703          	lw	a4,540(s1)
    80004d94:	02f70d63          	beq	a4,a5,80004dce <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d98:	0017871b          	addiw	a4,a5,1
    80004d9c:	20e4ac23          	sw	a4,536(s1)
    80004da0:	1ff7f793          	andi	a5,a5,511
    80004da4:	97a6                	add	a5,a5,s1
    80004da6:	0187c783          	lbu	a5,24(a5)
    80004daa:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dae:	4685                	li	a3,1
    80004db0:	fbf40613          	addi	a2,s0,-65
    80004db4:	85ca                	mv	a1,s2
    80004db6:	050a3503          	ld	a0,80(s4)
    80004dba:	ffffd097          	auipc	ra,0xffffd
    80004dbe:	b7e080e7          	jalr	-1154(ra) # 80001938 <copyout>
    80004dc2:	01650663          	beq	a0,s6,80004dce <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dc6:	2985                	addiw	s3,s3,1
    80004dc8:	0905                	addi	s2,s2,1
    80004dca:	fd3a91e3          	bne	s5,s3,80004d8c <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dce:	21c48513          	addi	a0,s1,540
    80004dd2:	ffffe097          	auipc	ra,0xffffe
    80004dd6:	82e080e7          	jalr	-2002(ra) # 80002600 <wakeup>
  release(&pi->lock);
    80004dda:	8526                	mv	a0,s1
    80004ddc:	ffffc097          	auipc	ra,0xffffc
    80004de0:	162080e7          	jalr	354(ra) # 80000f3e <release>
  return i;
}
    80004de4:	854e                	mv	a0,s3
    80004de6:	60a6                	ld	ra,72(sp)
    80004de8:	6406                	ld	s0,64(sp)
    80004dea:	74e2                	ld	s1,56(sp)
    80004dec:	7942                	ld	s2,48(sp)
    80004dee:	79a2                	ld	s3,40(sp)
    80004df0:	7a02                	ld	s4,32(sp)
    80004df2:	6ae2                	ld	s5,24(sp)
    80004df4:	6b42                	ld	s6,16(sp)
    80004df6:	6161                	addi	sp,sp,80
    80004df8:	8082                	ret
      release(&pi->lock);
    80004dfa:	8526                	mv	a0,s1
    80004dfc:	ffffc097          	auipc	ra,0xffffc
    80004e00:	142080e7          	jalr	322(ra) # 80000f3e <release>
      return -1;
    80004e04:	59fd                	li	s3,-1
    80004e06:	bff9                	j	80004de4 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e08:	4981                	li	s3,0
    80004e0a:	b7d1                	j	80004dce <piperead+0xae>

0000000080004e0c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e0c:	df010113          	addi	sp,sp,-528
    80004e10:	20113423          	sd	ra,520(sp)
    80004e14:	20813023          	sd	s0,512(sp)
    80004e18:	ffa6                	sd	s1,504(sp)
    80004e1a:	fbca                	sd	s2,496(sp)
    80004e1c:	f7ce                	sd	s3,488(sp)
    80004e1e:	f3d2                	sd	s4,480(sp)
    80004e20:	efd6                	sd	s5,472(sp)
    80004e22:	ebda                	sd	s6,464(sp)
    80004e24:	e7de                	sd	s7,456(sp)
    80004e26:	e3e2                	sd	s8,448(sp)
    80004e28:	ff66                	sd	s9,440(sp)
    80004e2a:	fb6a                	sd	s10,432(sp)
    80004e2c:	f76e                	sd	s11,424(sp)
    80004e2e:	0c00                	addi	s0,sp,528
    80004e30:	84aa                	mv	s1,a0
    80004e32:	dea43c23          	sd	a0,-520(s0)
    80004e36:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e3a:	ffffd097          	auipc	ra,0xffffd
    80004e3e:	e30080e7          	jalr	-464(ra) # 80001c6a <myproc>
    80004e42:	892a                	mv	s2,a0

  begin_op();
    80004e44:	fffff097          	auipc	ra,0xfffff
    80004e48:	446080e7          	jalr	1094(ra) # 8000428a <begin_op>

  if((ip = namei(path)) == 0){
    80004e4c:	8526                	mv	a0,s1
    80004e4e:	fffff097          	auipc	ra,0xfffff
    80004e52:	230080e7          	jalr	560(ra) # 8000407e <namei>
    80004e56:	c92d                	beqz	a0,80004ec8 <exec+0xbc>
    80004e58:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e5a:	fffff097          	auipc	ra,0xfffff
    80004e5e:	a70080e7          	jalr	-1424(ra) # 800038ca <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e62:	04000713          	li	a4,64
    80004e66:	4681                	li	a3,0
    80004e68:	e4840613          	addi	a2,s0,-440
    80004e6c:	4581                	li	a1,0
    80004e6e:	8526                	mv	a0,s1
    80004e70:	fffff097          	auipc	ra,0xfffff
    80004e74:	d0e080e7          	jalr	-754(ra) # 80003b7e <readi>
    80004e78:	04000793          	li	a5,64
    80004e7c:	00f51a63          	bne	a0,a5,80004e90 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e80:	e4842703          	lw	a4,-440(s0)
    80004e84:	464c47b7          	lui	a5,0x464c4
    80004e88:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e8c:	04f70463          	beq	a4,a5,80004ed4 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e90:	8526                	mv	a0,s1
    80004e92:	fffff097          	auipc	ra,0xfffff
    80004e96:	c9a080e7          	jalr	-870(ra) # 80003b2c <iunlockput>
    end_op();
    80004e9a:	fffff097          	auipc	ra,0xfffff
    80004e9e:	470080e7          	jalr	1136(ra) # 8000430a <end_op>
  }
  return -1;
    80004ea2:	557d                	li	a0,-1
}
    80004ea4:	20813083          	ld	ra,520(sp)
    80004ea8:	20013403          	ld	s0,512(sp)
    80004eac:	74fe                	ld	s1,504(sp)
    80004eae:	795e                	ld	s2,496(sp)
    80004eb0:	79be                	ld	s3,488(sp)
    80004eb2:	7a1e                	ld	s4,480(sp)
    80004eb4:	6afe                	ld	s5,472(sp)
    80004eb6:	6b5e                	ld	s6,464(sp)
    80004eb8:	6bbe                	ld	s7,456(sp)
    80004eba:	6c1e                	ld	s8,448(sp)
    80004ebc:	7cfa                	ld	s9,440(sp)
    80004ebe:	7d5a                	ld	s10,432(sp)
    80004ec0:	7dba                	ld	s11,424(sp)
    80004ec2:	21010113          	addi	sp,sp,528
    80004ec6:	8082                	ret
    end_op();
    80004ec8:	fffff097          	auipc	ra,0xfffff
    80004ecc:	442080e7          	jalr	1090(ra) # 8000430a <end_op>
    return -1;
    80004ed0:	557d                	li	a0,-1
    80004ed2:	bfc9                	j	80004ea4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ed4:	854a                	mv	a0,s2
    80004ed6:	ffffd097          	auipc	ra,0xffffd
    80004eda:	e58080e7          	jalr	-424(ra) # 80001d2e <proc_pagetable>
    80004ede:	8baa                	mv	s7,a0
    80004ee0:	d945                	beqz	a0,80004e90 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ee2:	e6842983          	lw	s3,-408(s0)
    80004ee6:	e8045783          	lhu	a5,-384(s0)
    80004eea:	c7ad                	beqz	a5,80004f54 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004eec:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eee:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004ef0:	6c85                	lui	s9,0x1
    80004ef2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ef6:	def43823          	sd	a5,-528(s0)
    80004efa:	a42d                	j	80005124 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004efc:	00003517          	auipc	a0,0x3
    80004f00:	7c450513          	addi	a0,a0,1988 # 800086c0 <syscalls+0x290>
    80004f04:	ffffb097          	auipc	ra,0xffffb
    80004f08:	644080e7          	jalr	1604(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f0c:	8756                	mv	a4,s5
    80004f0e:	012d86bb          	addw	a3,s11,s2
    80004f12:	4581                	li	a1,0
    80004f14:	8526                	mv	a0,s1
    80004f16:	fffff097          	auipc	ra,0xfffff
    80004f1a:	c68080e7          	jalr	-920(ra) # 80003b7e <readi>
    80004f1e:	2501                	sext.w	a0,a0
    80004f20:	1aaa9963          	bne	s5,a0,800050d2 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004f24:	6785                	lui	a5,0x1
    80004f26:	0127893b          	addw	s2,a5,s2
    80004f2a:	77fd                	lui	a5,0xfffff
    80004f2c:	01478a3b          	addw	s4,a5,s4
    80004f30:	1f897163          	bgeu	s2,s8,80005112 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004f34:	02091593          	slli	a1,s2,0x20
    80004f38:	9181                	srli	a1,a1,0x20
    80004f3a:	95ea                	add	a1,a1,s10
    80004f3c:	855e                	mv	a0,s7
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	3da080e7          	jalr	986(ra) # 80001318 <walkaddr>
    80004f46:	862a                	mv	a2,a0
    if(pa == 0)
    80004f48:	d955                	beqz	a0,80004efc <exec+0xf0>
      n = PGSIZE;
    80004f4a:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004f4c:	fd9a70e3          	bgeu	s4,s9,80004f0c <exec+0x100>
      n = sz - i;
    80004f50:	8ad2                	mv	s5,s4
    80004f52:	bf6d                	j	80004f0c <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f54:	4901                	li	s2,0
  iunlockput(ip);
    80004f56:	8526                	mv	a0,s1
    80004f58:	fffff097          	auipc	ra,0xfffff
    80004f5c:	bd4080e7          	jalr	-1068(ra) # 80003b2c <iunlockput>
  end_op();
    80004f60:	fffff097          	auipc	ra,0xfffff
    80004f64:	3aa080e7          	jalr	938(ra) # 8000430a <end_op>
  p = myproc();
    80004f68:	ffffd097          	auipc	ra,0xffffd
    80004f6c:	d02080e7          	jalr	-766(ra) # 80001c6a <myproc>
    80004f70:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f72:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f76:	6785                	lui	a5,0x1
    80004f78:	17fd                	addi	a5,a5,-1
    80004f7a:	993e                	add	s2,s2,a5
    80004f7c:	757d                	lui	a0,0xfffff
    80004f7e:	00a977b3          	and	a5,s2,a0
    80004f82:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f86:	6609                	lui	a2,0x2
    80004f88:	963e                	add	a2,a2,a5
    80004f8a:	85be                	mv	a1,a5
    80004f8c:	855e                	mv	a0,s7
    80004f8e:	ffffc097          	auipc	ra,0xffffc
    80004f92:	76e080e7          	jalr	1902(ra) # 800016fc <uvmalloc>
    80004f96:	8b2a                	mv	s6,a0
  ip = 0;
    80004f98:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f9a:	12050c63          	beqz	a0,800050d2 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f9e:	75f9                	lui	a1,0xffffe
    80004fa0:	95aa                	add	a1,a1,a0
    80004fa2:	855e                	mv	a0,s7
    80004fa4:	ffffd097          	auipc	ra,0xffffd
    80004fa8:	962080e7          	jalr	-1694(ra) # 80001906 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fac:	7c7d                	lui	s8,0xfffff
    80004fae:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fb0:	e0043783          	ld	a5,-512(s0)
    80004fb4:	6388                	ld	a0,0(a5)
    80004fb6:	c535                	beqz	a0,80005022 <exec+0x216>
    80004fb8:	e8840993          	addi	s3,s0,-376
    80004fbc:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004fc0:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004fc2:	ffffc097          	auipc	ra,0xffffc
    80004fc6:	14c080e7          	jalr	332(ra) # 8000110e <strlen>
    80004fca:	2505                	addiw	a0,a0,1
    80004fcc:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fd0:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004fd4:	13896363          	bltu	s2,s8,800050fa <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fd8:	e0043d83          	ld	s11,-512(s0)
    80004fdc:	000dba03          	ld	s4,0(s11)
    80004fe0:	8552                	mv	a0,s4
    80004fe2:	ffffc097          	auipc	ra,0xffffc
    80004fe6:	12c080e7          	jalr	300(ra) # 8000110e <strlen>
    80004fea:	0015069b          	addiw	a3,a0,1
    80004fee:	8652                	mv	a2,s4
    80004ff0:	85ca                	mv	a1,s2
    80004ff2:	855e                	mv	a0,s7
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	944080e7          	jalr	-1724(ra) # 80001938 <copyout>
    80004ffc:	10054363          	bltz	a0,80005102 <exec+0x2f6>
    ustack[argc] = sp;
    80005000:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005004:	0485                	addi	s1,s1,1
    80005006:	008d8793          	addi	a5,s11,8
    8000500a:	e0f43023          	sd	a5,-512(s0)
    8000500e:	008db503          	ld	a0,8(s11)
    80005012:	c911                	beqz	a0,80005026 <exec+0x21a>
    if(argc >= MAXARG)
    80005014:	09a1                	addi	s3,s3,8
    80005016:	fb3c96e3          	bne	s9,s3,80004fc2 <exec+0x1b6>
  sz = sz1;
    8000501a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000501e:	4481                	li	s1,0
    80005020:	a84d                	j	800050d2 <exec+0x2c6>
  sp = sz;
    80005022:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005024:	4481                	li	s1,0
  ustack[argc] = 0;
    80005026:	00349793          	slli	a5,s1,0x3
    8000502a:	f9040713          	addi	a4,s0,-112
    8000502e:	97ba                	add	a5,a5,a4
    80005030:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80005034:	00148693          	addi	a3,s1,1
    80005038:	068e                	slli	a3,a3,0x3
    8000503a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000503e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005042:	01897663          	bgeu	s2,s8,8000504e <exec+0x242>
  sz = sz1;
    80005046:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000504a:	4481                	li	s1,0
    8000504c:	a059                	j	800050d2 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000504e:	e8840613          	addi	a2,s0,-376
    80005052:	85ca                	mv	a1,s2
    80005054:	855e                	mv	a0,s7
    80005056:	ffffd097          	auipc	ra,0xffffd
    8000505a:	8e2080e7          	jalr	-1822(ra) # 80001938 <copyout>
    8000505e:	0a054663          	bltz	a0,8000510a <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005062:	058ab783          	ld	a5,88(s5)
    80005066:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000506a:	df843783          	ld	a5,-520(s0)
    8000506e:	0007c703          	lbu	a4,0(a5)
    80005072:	cf11                	beqz	a4,8000508e <exec+0x282>
    80005074:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005076:	02f00693          	li	a3,47
    8000507a:	a029                	j	80005084 <exec+0x278>
  for(last=s=path; *s; s++)
    8000507c:	0785                	addi	a5,a5,1
    8000507e:	fff7c703          	lbu	a4,-1(a5)
    80005082:	c711                	beqz	a4,8000508e <exec+0x282>
    if(*s == '/')
    80005084:	fed71ce3          	bne	a4,a3,8000507c <exec+0x270>
      last = s+1;
    80005088:	def43c23          	sd	a5,-520(s0)
    8000508c:	bfc5                	j	8000507c <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    8000508e:	4641                	li	a2,16
    80005090:	df843583          	ld	a1,-520(s0)
    80005094:	158a8513          	addi	a0,s5,344
    80005098:	ffffc097          	auipc	ra,0xffffc
    8000509c:	044080e7          	jalr	68(ra) # 800010dc <safestrcpy>
  oldpagetable = p->pagetable;
    800050a0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050a4:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800050a8:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050ac:	058ab783          	ld	a5,88(s5)
    800050b0:	e6043703          	ld	a4,-416(s0)
    800050b4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050b6:	058ab783          	ld	a5,88(s5)
    800050ba:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050be:	85ea                	mv	a1,s10
    800050c0:	ffffd097          	auipc	ra,0xffffd
    800050c4:	d0a080e7          	jalr	-758(ra) # 80001dca <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050c8:	0004851b          	sext.w	a0,s1
    800050cc:	bbe1                	j	80004ea4 <exec+0x98>
    800050ce:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800050d2:	e0843583          	ld	a1,-504(s0)
    800050d6:	855e                	mv	a0,s7
    800050d8:	ffffd097          	auipc	ra,0xffffd
    800050dc:	cf2080e7          	jalr	-782(ra) # 80001dca <proc_freepagetable>
  if(ip){
    800050e0:	da0498e3          	bnez	s1,80004e90 <exec+0x84>
  return -1;
    800050e4:	557d                	li	a0,-1
    800050e6:	bb7d                	j	80004ea4 <exec+0x98>
    800050e8:	e1243423          	sd	s2,-504(s0)
    800050ec:	b7dd                	j	800050d2 <exec+0x2c6>
    800050ee:	e1243423          	sd	s2,-504(s0)
    800050f2:	b7c5                	j	800050d2 <exec+0x2c6>
    800050f4:	e1243423          	sd	s2,-504(s0)
    800050f8:	bfe9                	j	800050d2 <exec+0x2c6>
  sz = sz1;
    800050fa:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050fe:	4481                	li	s1,0
    80005100:	bfc9                	j	800050d2 <exec+0x2c6>
  sz = sz1;
    80005102:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005106:	4481                	li	s1,0
    80005108:	b7e9                	j	800050d2 <exec+0x2c6>
  sz = sz1;
    8000510a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000510e:	4481                	li	s1,0
    80005110:	b7c9                	j	800050d2 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005112:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005116:	2b05                	addiw	s6,s6,1
    80005118:	0389899b          	addiw	s3,s3,56
    8000511c:	e8045783          	lhu	a5,-384(s0)
    80005120:	e2fb5be3          	bge	s6,a5,80004f56 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005124:	2981                	sext.w	s3,s3
    80005126:	03800713          	li	a4,56
    8000512a:	86ce                	mv	a3,s3
    8000512c:	e1040613          	addi	a2,s0,-496
    80005130:	4581                	li	a1,0
    80005132:	8526                	mv	a0,s1
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	a4a080e7          	jalr	-1462(ra) # 80003b7e <readi>
    8000513c:	03800793          	li	a5,56
    80005140:	f8f517e3          	bne	a0,a5,800050ce <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005144:	e1042783          	lw	a5,-496(s0)
    80005148:	4705                	li	a4,1
    8000514a:	fce796e3          	bne	a5,a4,80005116 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    8000514e:	e3843603          	ld	a2,-456(s0)
    80005152:	e3043783          	ld	a5,-464(s0)
    80005156:	f8f669e3          	bltu	a2,a5,800050e8 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000515a:	e2043783          	ld	a5,-480(s0)
    8000515e:	963e                	add	a2,a2,a5
    80005160:	f8f667e3          	bltu	a2,a5,800050ee <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005164:	85ca                	mv	a1,s2
    80005166:	855e                	mv	a0,s7
    80005168:	ffffc097          	auipc	ra,0xffffc
    8000516c:	594080e7          	jalr	1428(ra) # 800016fc <uvmalloc>
    80005170:	e0a43423          	sd	a0,-504(s0)
    80005174:	d141                	beqz	a0,800050f4 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80005176:	e2043d03          	ld	s10,-480(s0)
    8000517a:	df043783          	ld	a5,-528(s0)
    8000517e:	00fd77b3          	and	a5,s10,a5
    80005182:	fba1                	bnez	a5,800050d2 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005184:	e1842d83          	lw	s11,-488(s0)
    80005188:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000518c:	f80c03e3          	beqz	s8,80005112 <exec+0x306>
    80005190:	8a62                	mv	s4,s8
    80005192:	4901                	li	s2,0
    80005194:	b345                	j	80004f34 <exec+0x128>

0000000080005196 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005196:	7179                	addi	sp,sp,-48
    80005198:	f406                	sd	ra,40(sp)
    8000519a:	f022                	sd	s0,32(sp)
    8000519c:	ec26                	sd	s1,24(sp)
    8000519e:	e84a                	sd	s2,16(sp)
    800051a0:	1800                	addi	s0,sp,48
    800051a2:	892e                	mv	s2,a1
    800051a4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051a6:	fdc40593          	addi	a1,s0,-36
    800051aa:	ffffe097          	auipc	ra,0xffffe
    800051ae:	bae080e7          	jalr	-1106(ra) # 80002d58 <argint>
    800051b2:	04054063          	bltz	a0,800051f2 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051b6:	fdc42703          	lw	a4,-36(s0)
    800051ba:	47bd                	li	a5,15
    800051bc:	02e7ed63          	bltu	a5,a4,800051f6 <argfd+0x60>
    800051c0:	ffffd097          	auipc	ra,0xffffd
    800051c4:	aaa080e7          	jalr	-1366(ra) # 80001c6a <myproc>
    800051c8:	fdc42703          	lw	a4,-36(s0)
    800051cc:	01a70793          	addi	a5,a4,26
    800051d0:	078e                	slli	a5,a5,0x3
    800051d2:	953e                	add	a0,a0,a5
    800051d4:	611c                	ld	a5,0(a0)
    800051d6:	c395                	beqz	a5,800051fa <argfd+0x64>
    return -1;
  if(pfd)
    800051d8:	00090463          	beqz	s2,800051e0 <argfd+0x4a>
    *pfd = fd;
    800051dc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051e0:	4501                	li	a0,0
  if(pf)
    800051e2:	c091                	beqz	s1,800051e6 <argfd+0x50>
    *pf = f;
    800051e4:	e09c                	sd	a5,0(s1)
}
    800051e6:	70a2                	ld	ra,40(sp)
    800051e8:	7402                	ld	s0,32(sp)
    800051ea:	64e2                	ld	s1,24(sp)
    800051ec:	6942                	ld	s2,16(sp)
    800051ee:	6145                	addi	sp,sp,48
    800051f0:	8082                	ret
    return -1;
    800051f2:	557d                	li	a0,-1
    800051f4:	bfcd                	j	800051e6 <argfd+0x50>
    return -1;
    800051f6:	557d                	li	a0,-1
    800051f8:	b7fd                	j	800051e6 <argfd+0x50>
    800051fa:	557d                	li	a0,-1
    800051fc:	b7ed                	j	800051e6 <argfd+0x50>

00000000800051fe <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051fe:	1101                	addi	sp,sp,-32
    80005200:	ec06                	sd	ra,24(sp)
    80005202:	e822                	sd	s0,16(sp)
    80005204:	e426                	sd	s1,8(sp)
    80005206:	1000                	addi	s0,sp,32
    80005208:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000520a:	ffffd097          	auipc	ra,0xffffd
    8000520e:	a60080e7          	jalr	-1440(ra) # 80001c6a <myproc>
    80005212:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005214:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7eed90d0>
    80005218:	4501                	li	a0,0
    8000521a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000521c:	6398                	ld	a4,0(a5)
    8000521e:	cb19                	beqz	a4,80005234 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005220:	2505                	addiw	a0,a0,1
    80005222:	07a1                	addi	a5,a5,8
    80005224:	fed51ce3          	bne	a0,a3,8000521c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005228:	557d                	li	a0,-1
}
    8000522a:	60e2                	ld	ra,24(sp)
    8000522c:	6442                	ld	s0,16(sp)
    8000522e:	64a2                	ld	s1,8(sp)
    80005230:	6105                	addi	sp,sp,32
    80005232:	8082                	ret
      p->ofile[fd] = f;
    80005234:	01a50793          	addi	a5,a0,26
    80005238:	078e                	slli	a5,a5,0x3
    8000523a:	963e                	add	a2,a2,a5
    8000523c:	e204                	sd	s1,0(a2)
      return fd;
    8000523e:	b7f5                	j	8000522a <fdalloc+0x2c>

0000000080005240 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005240:	715d                	addi	sp,sp,-80
    80005242:	e486                	sd	ra,72(sp)
    80005244:	e0a2                	sd	s0,64(sp)
    80005246:	fc26                	sd	s1,56(sp)
    80005248:	f84a                	sd	s2,48(sp)
    8000524a:	f44e                	sd	s3,40(sp)
    8000524c:	f052                	sd	s4,32(sp)
    8000524e:	ec56                	sd	s5,24(sp)
    80005250:	0880                	addi	s0,sp,80
    80005252:	89ae                	mv	s3,a1
    80005254:	8ab2                	mv	s5,a2
    80005256:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005258:	fb040593          	addi	a1,s0,-80
    8000525c:	fffff097          	auipc	ra,0xfffff
    80005260:	e40080e7          	jalr	-448(ra) # 8000409c <nameiparent>
    80005264:	892a                	mv	s2,a0
    80005266:	12050f63          	beqz	a0,800053a4 <create+0x164>
    return 0;

  ilock(dp);
    8000526a:	ffffe097          	auipc	ra,0xffffe
    8000526e:	660080e7          	jalr	1632(ra) # 800038ca <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005272:	4601                	li	a2,0
    80005274:	fb040593          	addi	a1,s0,-80
    80005278:	854a                	mv	a0,s2
    8000527a:	fffff097          	auipc	ra,0xfffff
    8000527e:	b32080e7          	jalr	-1230(ra) # 80003dac <dirlookup>
    80005282:	84aa                	mv	s1,a0
    80005284:	c921                	beqz	a0,800052d4 <create+0x94>
    iunlockput(dp);
    80005286:	854a                	mv	a0,s2
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	8a4080e7          	jalr	-1884(ra) # 80003b2c <iunlockput>
    ilock(ip);
    80005290:	8526                	mv	a0,s1
    80005292:	ffffe097          	auipc	ra,0xffffe
    80005296:	638080e7          	jalr	1592(ra) # 800038ca <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000529a:	2981                	sext.w	s3,s3
    8000529c:	4789                	li	a5,2
    8000529e:	02f99463          	bne	s3,a5,800052c6 <create+0x86>
    800052a2:	0444d783          	lhu	a5,68(s1)
    800052a6:	37f9                	addiw	a5,a5,-2
    800052a8:	17c2                	slli	a5,a5,0x30
    800052aa:	93c1                	srli	a5,a5,0x30
    800052ac:	4705                	li	a4,1
    800052ae:	00f76c63          	bltu	a4,a5,800052c6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052b2:	8526                	mv	a0,s1
    800052b4:	60a6                	ld	ra,72(sp)
    800052b6:	6406                	ld	s0,64(sp)
    800052b8:	74e2                	ld	s1,56(sp)
    800052ba:	7942                	ld	s2,48(sp)
    800052bc:	79a2                	ld	s3,40(sp)
    800052be:	7a02                	ld	s4,32(sp)
    800052c0:	6ae2                	ld	s5,24(sp)
    800052c2:	6161                	addi	sp,sp,80
    800052c4:	8082                	ret
    iunlockput(ip);
    800052c6:	8526                	mv	a0,s1
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	864080e7          	jalr	-1948(ra) # 80003b2c <iunlockput>
    return 0;
    800052d0:	4481                	li	s1,0
    800052d2:	b7c5                	j	800052b2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052d4:	85ce                	mv	a1,s3
    800052d6:	00092503          	lw	a0,0(s2)
    800052da:	ffffe097          	auipc	ra,0xffffe
    800052de:	458080e7          	jalr	1112(ra) # 80003732 <ialloc>
    800052e2:	84aa                	mv	s1,a0
    800052e4:	c529                	beqz	a0,8000532e <create+0xee>
  ilock(ip);
    800052e6:	ffffe097          	auipc	ra,0xffffe
    800052ea:	5e4080e7          	jalr	1508(ra) # 800038ca <ilock>
  ip->major = major;
    800052ee:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800052f2:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800052f6:	4785                	li	a5,1
    800052f8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052fc:	8526                	mv	a0,s1
    800052fe:	ffffe097          	auipc	ra,0xffffe
    80005302:	502080e7          	jalr	1282(ra) # 80003800 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005306:	2981                	sext.w	s3,s3
    80005308:	4785                	li	a5,1
    8000530a:	02f98a63          	beq	s3,a5,8000533e <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000530e:	40d0                	lw	a2,4(s1)
    80005310:	fb040593          	addi	a1,s0,-80
    80005314:	854a                	mv	a0,s2
    80005316:	fffff097          	auipc	ra,0xfffff
    8000531a:	ca6080e7          	jalr	-858(ra) # 80003fbc <dirlink>
    8000531e:	06054b63          	bltz	a0,80005394 <create+0x154>
  iunlockput(dp);
    80005322:	854a                	mv	a0,s2
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	808080e7          	jalr	-2040(ra) # 80003b2c <iunlockput>
  return ip;
    8000532c:	b759                	j	800052b2 <create+0x72>
    panic("create: ialloc");
    8000532e:	00003517          	auipc	a0,0x3
    80005332:	3b250513          	addi	a0,a0,946 # 800086e0 <syscalls+0x2b0>
    80005336:	ffffb097          	auipc	ra,0xffffb
    8000533a:	212080e7          	jalr	530(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    8000533e:	04a95783          	lhu	a5,74(s2)
    80005342:	2785                	addiw	a5,a5,1
    80005344:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005348:	854a                	mv	a0,s2
    8000534a:	ffffe097          	auipc	ra,0xffffe
    8000534e:	4b6080e7          	jalr	1206(ra) # 80003800 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005352:	40d0                	lw	a2,4(s1)
    80005354:	00003597          	auipc	a1,0x3
    80005358:	39c58593          	addi	a1,a1,924 # 800086f0 <syscalls+0x2c0>
    8000535c:	8526                	mv	a0,s1
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	c5e080e7          	jalr	-930(ra) # 80003fbc <dirlink>
    80005366:	00054f63          	bltz	a0,80005384 <create+0x144>
    8000536a:	00492603          	lw	a2,4(s2)
    8000536e:	00003597          	auipc	a1,0x3
    80005372:	38a58593          	addi	a1,a1,906 # 800086f8 <syscalls+0x2c8>
    80005376:	8526                	mv	a0,s1
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	c44080e7          	jalr	-956(ra) # 80003fbc <dirlink>
    80005380:	f80557e3          	bgez	a0,8000530e <create+0xce>
      panic("create dots");
    80005384:	00003517          	auipc	a0,0x3
    80005388:	37c50513          	addi	a0,a0,892 # 80008700 <syscalls+0x2d0>
    8000538c:	ffffb097          	auipc	ra,0xffffb
    80005390:	1bc080e7          	jalr	444(ra) # 80000548 <panic>
    panic("create: dirlink");
    80005394:	00003517          	auipc	a0,0x3
    80005398:	37c50513          	addi	a0,a0,892 # 80008710 <syscalls+0x2e0>
    8000539c:	ffffb097          	auipc	ra,0xffffb
    800053a0:	1ac080e7          	jalr	428(ra) # 80000548 <panic>
    return 0;
    800053a4:	84aa                	mv	s1,a0
    800053a6:	b731                	j	800052b2 <create+0x72>

00000000800053a8 <sys_dup>:
{
    800053a8:	7179                	addi	sp,sp,-48
    800053aa:	f406                	sd	ra,40(sp)
    800053ac:	f022                	sd	s0,32(sp)
    800053ae:	ec26                	sd	s1,24(sp)
    800053b0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053b2:	fd840613          	addi	a2,s0,-40
    800053b6:	4581                	li	a1,0
    800053b8:	4501                	li	a0,0
    800053ba:	00000097          	auipc	ra,0x0
    800053be:	ddc080e7          	jalr	-548(ra) # 80005196 <argfd>
    return -1;
    800053c2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053c4:	02054363          	bltz	a0,800053ea <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053c8:	fd843503          	ld	a0,-40(s0)
    800053cc:	00000097          	auipc	ra,0x0
    800053d0:	e32080e7          	jalr	-462(ra) # 800051fe <fdalloc>
    800053d4:	84aa                	mv	s1,a0
    return -1;
    800053d6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053d8:	00054963          	bltz	a0,800053ea <sys_dup+0x42>
  filedup(f);
    800053dc:	fd843503          	ld	a0,-40(s0)
    800053e0:	fffff097          	auipc	ra,0xfffff
    800053e4:	32a080e7          	jalr	810(ra) # 8000470a <filedup>
  return fd;
    800053e8:	87a6                	mv	a5,s1
}
    800053ea:	853e                	mv	a0,a5
    800053ec:	70a2                	ld	ra,40(sp)
    800053ee:	7402                	ld	s0,32(sp)
    800053f0:	64e2                	ld	s1,24(sp)
    800053f2:	6145                	addi	sp,sp,48
    800053f4:	8082                	ret

00000000800053f6 <sys_read>:
{
    800053f6:	7179                	addi	sp,sp,-48
    800053f8:	f406                	sd	ra,40(sp)
    800053fa:	f022                	sd	s0,32(sp)
    800053fc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053fe:	fe840613          	addi	a2,s0,-24
    80005402:	4581                	li	a1,0
    80005404:	4501                	li	a0,0
    80005406:	00000097          	auipc	ra,0x0
    8000540a:	d90080e7          	jalr	-624(ra) # 80005196 <argfd>
    return -1;
    8000540e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005410:	04054163          	bltz	a0,80005452 <sys_read+0x5c>
    80005414:	fe440593          	addi	a1,s0,-28
    80005418:	4509                	li	a0,2
    8000541a:	ffffe097          	auipc	ra,0xffffe
    8000541e:	93e080e7          	jalr	-1730(ra) # 80002d58 <argint>
    return -1;
    80005422:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005424:	02054763          	bltz	a0,80005452 <sys_read+0x5c>
    80005428:	fd840593          	addi	a1,s0,-40
    8000542c:	4505                	li	a0,1
    8000542e:	ffffe097          	auipc	ra,0xffffe
    80005432:	94c080e7          	jalr	-1716(ra) # 80002d7a <argaddr>
    return -1;
    80005436:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005438:	00054d63          	bltz	a0,80005452 <sys_read+0x5c>
  return fileread(f, p, n);
    8000543c:	fe442603          	lw	a2,-28(s0)
    80005440:	fd843583          	ld	a1,-40(s0)
    80005444:	fe843503          	ld	a0,-24(s0)
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	44e080e7          	jalr	1102(ra) # 80004896 <fileread>
    80005450:	87aa                	mv	a5,a0
}
    80005452:	853e                	mv	a0,a5
    80005454:	70a2                	ld	ra,40(sp)
    80005456:	7402                	ld	s0,32(sp)
    80005458:	6145                	addi	sp,sp,48
    8000545a:	8082                	ret

000000008000545c <sys_write>:
{
    8000545c:	7179                	addi	sp,sp,-48
    8000545e:	f406                	sd	ra,40(sp)
    80005460:	f022                	sd	s0,32(sp)
    80005462:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005464:	fe840613          	addi	a2,s0,-24
    80005468:	4581                	li	a1,0
    8000546a:	4501                	li	a0,0
    8000546c:	00000097          	auipc	ra,0x0
    80005470:	d2a080e7          	jalr	-726(ra) # 80005196 <argfd>
    return -1;
    80005474:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005476:	04054163          	bltz	a0,800054b8 <sys_write+0x5c>
    8000547a:	fe440593          	addi	a1,s0,-28
    8000547e:	4509                	li	a0,2
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	8d8080e7          	jalr	-1832(ra) # 80002d58 <argint>
    return -1;
    80005488:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000548a:	02054763          	bltz	a0,800054b8 <sys_write+0x5c>
    8000548e:	fd840593          	addi	a1,s0,-40
    80005492:	4505                	li	a0,1
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	8e6080e7          	jalr	-1818(ra) # 80002d7a <argaddr>
    return -1;
    8000549c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000549e:	00054d63          	bltz	a0,800054b8 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054a2:	fe442603          	lw	a2,-28(s0)
    800054a6:	fd843583          	ld	a1,-40(s0)
    800054aa:	fe843503          	ld	a0,-24(s0)
    800054ae:	fffff097          	auipc	ra,0xfffff
    800054b2:	4aa080e7          	jalr	1194(ra) # 80004958 <filewrite>
    800054b6:	87aa                	mv	a5,a0
}
    800054b8:	853e                	mv	a0,a5
    800054ba:	70a2                	ld	ra,40(sp)
    800054bc:	7402                	ld	s0,32(sp)
    800054be:	6145                	addi	sp,sp,48
    800054c0:	8082                	ret

00000000800054c2 <sys_close>:
{
    800054c2:	1101                	addi	sp,sp,-32
    800054c4:	ec06                	sd	ra,24(sp)
    800054c6:	e822                	sd	s0,16(sp)
    800054c8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054ca:	fe040613          	addi	a2,s0,-32
    800054ce:	fec40593          	addi	a1,s0,-20
    800054d2:	4501                	li	a0,0
    800054d4:	00000097          	auipc	ra,0x0
    800054d8:	cc2080e7          	jalr	-830(ra) # 80005196 <argfd>
    return -1;
    800054dc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054de:	02054463          	bltz	a0,80005506 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054e2:	ffffc097          	auipc	ra,0xffffc
    800054e6:	788080e7          	jalr	1928(ra) # 80001c6a <myproc>
    800054ea:	fec42783          	lw	a5,-20(s0)
    800054ee:	07e9                	addi	a5,a5,26
    800054f0:	078e                	slli	a5,a5,0x3
    800054f2:	97aa                	add	a5,a5,a0
    800054f4:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800054f8:	fe043503          	ld	a0,-32(s0)
    800054fc:	fffff097          	auipc	ra,0xfffff
    80005500:	260080e7          	jalr	608(ra) # 8000475c <fileclose>
  return 0;
    80005504:	4781                	li	a5,0
}
    80005506:	853e                	mv	a0,a5
    80005508:	60e2                	ld	ra,24(sp)
    8000550a:	6442                	ld	s0,16(sp)
    8000550c:	6105                	addi	sp,sp,32
    8000550e:	8082                	ret

0000000080005510 <sys_fstat>:
{
    80005510:	1101                	addi	sp,sp,-32
    80005512:	ec06                	sd	ra,24(sp)
    80005514:	e822                	sd	s0,16(sp)
    80005516:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005518:	fe840613          	addi	a2,s0,-24
    8000551c:	4581                	li	a1,0
    8000551e:	4501                	li	a0,0
    80005520:	00000097          	auipc	ra,0x0
    80005524:	c76080e7          	jalr	-906(ra) # 80005196 <argfd>
    return -1;
    80005528:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000552a:	02054563          	bltz	a0,80005554 <sys_fstat+0x44>
    8000552e:	fe040593          	addi	a1,s0,-32
    80005532:	4505                	li	a0,1
    80005534:	ffffe097          	auipc	ra,0xffffe
    80005538:	846080e7          	jalr	-1978(ra) # 80002d7a <argaddr>
    return -1;
    8000553c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000553e:	00054b63          	bltz	a0,80005554 <sys_fstat+0x44>
  return filestat(f, st);
    80005542:	fe043583          	ld	a1,-32(s0)
    80005546:	fe843503          	ld	a0,-24(s0)
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	2da080e7          	jalr	730(ra) # 80004824 <filestat>
    80005552:	87aa                	mv	a5,a0
}
    80005554:	853e                	mv	a0,a5
    80005556:	60e2                	ld	ra,24(sp)
    80005558:	6442                	ld	s0,16(sp)
    8000555a:	6105                	addi	sp,sp,32
    8000555c:	8082                	ret

000000008000555e <sys_link>:
{
    8000555e:	7169                	addi	sp,sp,-304
    80005560:	f606                	sd	ra,296(sp)
    80005562:	f222                	sd	s0,288(sp)
    80005564:	ee26                	sd	s1,280(sp)
    80005566:	ea4a                	sd	s2,272(sp)
    80005568:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000556a:	08000613          	li	a2,128
    8000556e:	ed040593          	addi	a1,s0,-304
    80005572:	4501                	li	a0,0
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	828080e7          	jalr	-2008(ra) # 80002d9c <argstr>
    return -1;
    8000557c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000557e:	10054e63          	bltz	a0,8000569a <sys_link+0x13c>
    80005582:	08000613          	li	a2,128
    80005586:	f5040593          	addi	a1,s0,-176
    8000558a:	4505                	li	a0,1
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	810080e7          	jalr	-2032(ra) # 80002d9c <argstr>
    return -1;
    80005594:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005596:	10054263          	bltz	a0,8000569a <sys_link+0x13c>
  begin_op();
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	cf0080e7          	jalr	-784(ra) # 8000428a <begin_op>
  if((ip = namei(old)) == 0){
    800055a2:	ed040513          	addi	a0,s0,-304
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	ad8080e7          	jalr	-1320(ra) # 8000407e <namei>
    800055ae:	84aa                	mv	s1,a0
    800055b0:	c551                	beqz	a0,8000563c <sys_link+0xde>
  ilock(ip);
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	318080e7          	jalr	792(ra) # 800038ca <ilock>
  if(ip->type == T_DIR){
    800055ba:	04449703          	lh	a4,68(s1)
    800055be:	4785                	li	a5,1
    800055c0:	08f70463          	beq	a4,a5,80005648 <sys_link+0xea>
  ip->nlink++;
    800055c4:	04a4d783          	lhu	a5,74(s1)
    800055c8:	2785                	addiw	a5,a5,1
    800055ca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055ce:	8526                	mv	a0,s1
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	230080e7          	jalr	560(ra) # 80003800 <iupdate>
  iunlock(ip);
    800055d8:	8526                	mv	a0,s1
    800055da:	ffffe097          	auipc	ra,0xffffe
    800055de:	3b2080e7          	jalr	946(ra) # 8000398c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055e2:	fd040593          	addi	a1,s0,-48
    800055e6:	f5040513          	addi	a0,s0,-176
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	ab2080e7          	jalr	-1358(ra) # 8000409c <nameiparent>
    800055f2:	892a                	mv	s2,a0
    800055f4:	c935                	beqz	a0,80005668 <sys_link+0x10a>
  ilock(dp);
    800055f6:	ffffe097          	auipc	ra,0xffffe
    800055fa:	2d4080e7          	jalr	724(ra) # 800038ca <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055fe:	00092703          	lw	a4,0(s2)
    80005602:	409c                	lw	a5,0(s1)
    80005604:	04f71d63          	bne	a4,a5,8000565e <sys_link+0x100>
    80005608:	40d0                	lw	a2,4(s1)
    8000560a:	fd040593          	addi	a1,s0,-48
    8000560e:	854a                	mv	a0,s2
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	9ac080e7          	jalr	-1620(ra) # 80003fbc <dirlink>
    80005618:	04054363          	bltz	a0,8000565e <sys_link+0x100>
  iunlockput(dp);
    8000561c:	854a                	mv	a0,s2
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	50e080e7          	jalr	1294(ra) # 80003b2c <iunlockput>
  iput(ip);
    80005626:	8526                	mv	a0,s1
    80005628:	ffffe097          	auipc	ra,0xffffe
    8000562c:	45c080e7          	jalr	1116(ra) # 80003a84 <iput>
  end_op();
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	cda080e7          	jalr	-806(ra) # 8000430a <end_op>
  return 0;
    80005638:	4781                	li	a5,0
    8000563a:	a085                	j	8000569a <sys_link+0x13c>
    end_op();
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	cce080e7          	jalr	-818(ra) # 8000430a <end_op>
    return -1;
    80005644:	57fd                	li	a5,-1
    80005646:	a891                	j	8000569a <sys_link+0x13c>
    iunlockput(ip);
    80005648:	8526                	mv	a0,s1
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	4e2080e7          	jalr	1250(ra) # 80003b2c <iunlockput>
    end_op();
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	cb8080e7          	jalr	-840(ra) # 8000430a <end_op>
    return -1;
    8000565a:	57fd                	li	a5,-1
    8000565c:	a83d                	j	8000569a <sys_link+0x13c>
    iunlockput(dp);
    8000565e:	854a                	mv	a0,s2
    80005660:	ffffe097          	auipc	ra,0xffffe
    80005664:	4cc080e7          	jalr	1228(ra) # 80003b2c <iunlockput>
  ilock(ip);
    80005668:	8526                	mv	a0,s1
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	260080e7          	jalr	608(ra) # 800038ca <ilock>
  ip->nlink--;
    80005672:	04a4d783          	lhu	a5,74(s1)
    80005676:	37fd                	addiw	a5,a5,-1
    80005678:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000567c:	8526                	mv	a0,s1
    8000567e:	ffffe097          	auipc	ra,0xffffe
    80005682:	182080e7          	jalr	386(ra) # 80003800 <iupdate>
  iunlockput(ip);
    80005686:	8526                	mv	a0,s1
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	4a4080e7          	jalr	1188(ra) # 80003b2c <iunlockput>
  end_op();
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	c7a080e7          	jalr	-902(ra) # 8000430a <end_op>
  return -1;
    80005698:	57fd                	li	a5,-1
}
    8000569a:	853e                	mv	a0,a5
    8000569c:	70b2                	ld	ra,296(sp)
    8000569e:	7412                	ld	s0,288(sp)
    800056a0:	64f2                	ld	s1,280(sp)
    800056a2:	6952                	ld	s2,272(sp)
    800056a4:	6155                	addi	sp,sp,304
    800056a6:	8082                	ret

00000000800056a8 <sys_unlink>:
{
    800056a8:	7151                	addi	sp,sp,-240
    800056aa:	f586                	sd	ra,232(sp)
    800056ac:	f1a2                	sd	s0,224(sp)
    800056ae:	eda6                	sd	s1,216(sp)
    800056b0:	e9ca                	sd	s2,208(sp)
    800056b2:	e5ce                	sd	s3,200(sp)
    800056b4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056b6:	08000613          	li	a2,128
    800056ba:	f3040593          	addi	a1,s0,-208
    800056be:	4501                	li	a0,0
    800056c0:	ffffd097          	auipc	ra,0xffffd
    800056c4:	6dc080e7          	jalr	1756(ra) # 80002d9c <argstr>
    800056c8:	18054163          	bltz	a0,8000584a <sys_unlink+0x1a2>
  begin_op();
    800056cc:	fffff097          	auipc	ra,0xfffff
    800056d0:	bbe080e7          	jalr	-1090(ra) # 8000428a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056d4:	fb040593          	addi	a1,s0,-80
    800056d8:	f3040513          	addi	a0,s0,-208
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	9c0080e7          	jalr	-1600(ra) # 8000409c <nameiparent>
    800056e4:	84aa                	mv	s1,a0
    800056e6:	c979                	beqz	a0,800057bc <sys_unlink+0x114>
  ilock(dp);
    800056e8:	ffffe097          	auipc	ra,0xffffe
    800056ec:	1e2080e7          	jalr	482(ra) # 800038ca <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056f0:	00003597          	auipc	a1,0x3
    800056f4:	00058593          	mv	a1,a1
    800056f8:	fb040513          	addi	a0,s0,-80
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	696080e7          	jalr	1686(ra) # 80003d92 <namecmp>
    80005704:	14050a63          	beqz	a0,80005858 <sys_unlink+0x1b0>
    80005708:	00003597          	auipc	a1,0x3
    8000570c:	ff058593          	addi	a1,a1,-16 # 800086f8 <syscalls+0x2c8>
    80005710:	fb040513          	addi	a0,s0,-80
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	67e080e7          	jalr	1662(ra) # 80003d92 <namecmp>
    8000571c:	12050e63          	beqz	a0,80005858 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005720:	f2c40613          	addi	a2,s0,-212
    80005724:	fb040593          	addi	a1,s0,-80
    80005728:	8526                	mv	a0,s1
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	682080e7          	jalr	1666(ra) # 80003dac <dirlookup>
    80005732:	892a                	mv	s2,a0
    80005734:	12050263          	beqz	a0,80005858 <sys_unlink+0x1b0>
  ilock(ip);
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	192080e7          	jalr	402(ra) # 800038ca <ilock>
  if(ip->nlink < 1)
    80005740:	04a91783          	lh	a5,74(s2)
    80005744:	08f05263          	blez	a5,800057c8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005748:	04491703          	lh	a4,68(s2)
    8000574c:	4785                	li	a5,1
    8000574e:	08f70563          	beq	a4,a5,800057d8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005752:	4641                	li	a2,16
    80005754:	4581                	li	a1,0
    80005756:	fc040513          	addi	a0,s0,-64
    8000575a:	ffffc097          	auipc	ra,0xffffc
    8000575e:	82c080e7          	jalr	-2004(ra) # 80000f86 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005762:	4741                	li	a4,16
    80005764:	f2c42683          	lw	a3,-212(s0)
    80005768:	fc040613          	addi	a2,s0,-64
    8000576c:	4581                	li	a1,0
    8000576e:	8526                	mv	a0,s1
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	506080e7          	jalr	1286(ra) # 80003c76 <writei>
    80005778:	47c1                	li	a5,16
    8000577a:	0af51563          	bne	a0,a5,80005824 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000577e:	04491703          	lh	a4,68(s2)
    80005782:	4785                	li	a5,1
    80005784:	0af70863          	beq	a4,a5,80005834 <sys_unlink+0x18c>
  iunlockput(dp);
    80005788:	8526                	mv	a0,s1
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	3a2080e7          	jalr	930(ra) # 80003b2c <iunlockput>
  ip->nlink--;
    80005792:	04a95783          	lhu	a5,74(s2)
    80005796:	37fd                	addiw	a5,a5,-1
    80005798:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000579c:	854a                	mv	a0,s2
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	062080e7          	jalr	98(ra) # 80003800 <iupdate>
  iunlockput(ip);
    800057a6:	854a                	mv	a0,s2
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	384080e7          	jalr	900(ra) # 80003b2c <iunlockput>
  end_op();
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	b5a080e7          	jalr	-1190(ra) # 8000430a <end_op>
  return 0;
    800057b8:	4501                	li	a0,0
    800057ba:	a84d                	j	8000586c <sys_unlink+0x1c4>
    end_op();
    800057bc:	fffff097          	auipc	ra,0xfffff
    800057c0:	b4e080e7          	jalr	-1202(ra) # 8000430a <end_op>
    return -1;
    800057c4:	557d                	li	a0,-1
    800057c6:	a05d                	j	8000586c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057c8:	00003517          	auipc	a0,0x3
    800057cc:	f5850513          	addi	a0,a0,-168 # 80008720 <syscalls+0x2f0>
    800057d0:	ffffb097          	auipc	ra,0xffffb
    800057d4:	d78080e7          	jalr	-648(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057d8:	04c92703          	lw	a4,76(s2)
    800057dc:	02000793          	li	a5,32
    800057e0:	f6e7f9e3          	bgeu	a5,a4,80005752 <sys_unlink+0xaa>
    800057e4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057e8:	4741                	li	a4,16
    800057ea:	86ce                	mv	a3,s3
    800057ec:	f1840613          	addi	a2,s0,-232
    800057f0:	4581                	li	a1,0
    800057f2:	854a                	mv	a0,s2
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	38a080e7          	jalr	906(ra) # 80003b7e <readi>
    800057fc:	47c1                	li	a5,16
    800057fe:	00f51b63          	bne	a0,a5,80005814 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005802:	f1845783          	lhu	a5,-232(s0)
    80005806:	e7a1                	bnez	a5,8000584e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005808:	29c1                	addiw	s3,s3,16
    8000580a:	04c92783          	lw	a5,76(s2)
    8000580e:	fcf9ede3          	bltu	s3,a5,800057e8 <sys_unlink+0x140>
    80005812:	b781                	j	80005752 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005814:	00003517          	auipc	a0,0x3
    80005818:	f2450513          	addi	a0,a0,-220 # 80008738 <syscalls+0x308>
    8000581c:	ffffb097          	auipc	ra,0xffffb
    80005820:	d2c080e7          	jalr	-724(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005824:	00003517          	auipc	a0,0x3
    80005828:	f2c50513          	addi	a0,a0,-212 # 80008750 <syscalls+0x320>
    8000582c:	ffffb097          	auipc	ra,0xffffb
    80005830:	d1c080e7          	jalr	-740(ra) # 80000548 <panic>
    dp->nlink--;
    80005834:	04a4d783          	lhu	a5,74(s1)
    80005838:	37fd                	addiw	a5,a5,-1
    8000583a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000583e:	8526                	mv	a0,s1
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	fc0080e7          	jalr	-64(ra) # 80003800 <iupdate>
    80005848:	b781                	j	80005788 <sys_unlink+0xe0>
    return -1;
    8000584a:	557d                	li	a0,-1
    8000584c:	a005                	j	8000586c <sys_unlink+0x1c4>
    iunlockput(ip);
    8000584e:	854a                	mv	a0,s2
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	2dc080e7          	jalr	732(ra) # 80003b2c <iunlockput>
  iunlockput(dp);
    80005858:	8526                	mv	a0,s1
    8000585a:	ffffe097          	auipc	ra,0xffffe
    8000585e:	2d2080e7          	jalr	722(ra) # 80003b2c <iunlockput>
  end_op();
    80005862:	fffff097          	auipc	ra,0xfffff
    80005866:	aa8080e7          	jalr	-1368(ra) # 8000430a <end_op>
  return -1;
    8000586a:	557d                	li	a0,-1
}
    8000586c:	70ae                	ld	ra,232(sp)
    8000586e:	740e                	ld	s0,224(sp)
    80005870:	64ee                	ld	s1,216(sp)
    80005872:	694e                	ld	s2,208(sp)
    80005874:	69ae                	ld	s3,200(sp)
    80005876:	616d                	addi	sp,sp,240
    80005878:	8082                	ret

000000008000587a <sys_open>:

uint64
sys_open(void)
{
    8000587a:	7131                	addi	sp,sp,-192
    8000587c:	fd06                	sd	ra,184(sp)
    8000587e:	f922                	sd	s0,176(sp)
    80005880:	f526                	sd	s1,168(sp)
    80005882:	f14a                	sd	s2,160(sp)
    80005884:	ed4e                	sd	s3,152(sp)
    80005886:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005888:	08000613          	li	a2,128
    8000588c:	f5040593          	addi	a1,s0,-176
    80005890:	4501                	li	a0,0
    80005892:	ffffd097          	auipc	ra,0xffffd
    80005896:	50a080e7          	jalr	1290(ra) # 80002d9c <argstr>
    return -1;
    8000589a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000589c:	0c054163          	bltz	a0,8000595e <sys_open+0xe4>
    800058a0:	f4c40593          	addi	a1,s0,-180
    800058a4:	4505                	li	a0,1
    800058a6:	ffffd097          	auipc	ra,0xffffd
    800058aa:	4b2080e7          	jalr	1202(ra) # 80002d58 <argint>
    800058ae:	0a054863          	bltz	a0,8000595e <sys_open+0xe4>

  begin_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	9d8080e7          	jalr	-1576(ra) # 8000428a <begin_op>

  if(omode & O_CREATE){
    800058ba:	f4c42783          	lw	a5,-180(s0)
    800058be:	2007f793          	andi	a5,a5,512
    800058c2:	cbdd                	beqz	a5,80005978 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058c4:	4681                	li	a3,0
    800058c6:	4601                	li	a2,0
    800058c8:	4589                	li	a1,2
    800058ca:	f5040513          	addi	a0,s0,-176
    800058ce:	00000097          	auipc	ra,0x0
    800058d2:	972080e7          	jalr	-1678(ra) # 80005240 <create>
    800058d6:	892a                	mv	s2,a0
    if(ip == 0){
    800058d8:	c959                	beqz	a0,8000596e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058da:	04491703          	lh	a4,68(s2)
    800058de:	478d                	li	a5,3
    800058e0:	00f71763          	bne	a4,a5,800058ee <sys_open+0x74>
    800058e4:	04695703          	lhu	a4,70(s2)
    800058e8:	47a5                	li	a5,9
    800058ea:	0ce7ec63          	bltu	a5,a4,800059c2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058ee:	fffff097          	auipc	ra,0xfffff
    800058f2:	db2080e7          	jalr	-590(ra) # 800046a0 <filealloc>
    800058f6:	89aa                	mv	s3,a0
    800058f8:	10050263          	beqz	a0,800059fc <sys_open+0x182>
    800058fc:	00000097          	auipc	ra,0x0
    80005900:	902080e7          	jalr	-1790(ra) # 800051fe <fdalloc>
    80005904:	84aa                	mv	s1,a0
    80005906:	0e054663          	bltz	a0,800059f2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000590a:	04491703          	lh	a4,68(s2)
    8000590e:	478d                	li	a5,3
    80005910:	0cf70463          	beq	a4,a5,800059d8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005914:	4789                	li	a5,2
    80005916:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000591a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000591e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005922:	f4c42783          	lw	a5,-180(s0)
    80005926:	0017c713          	xori	a4,a5,1
    8000592a:	8b05                	andi	a4,a4,1
    8000592c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005930:	0037f713          	andi	a4,a5,3
    80005934:	00e03733          	snez	a4,a4
    80005938:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000593c:	4007f793          	andi	a5,a5,1024
    80005940:	c791                	beqz	a5,8000594c <sys_open+0xd2>
    80005942:	04491703          	lh	a4,68(s2)
    80005946:	4789                	li	a5,2
    80005948:	08f70f63          	beq	a4,a5,800059e6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000594c:	854a                	mv	a0,s2
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	03e080e7          	jalr	62(ra) # 8000398c <iunlock>
  end_op();
    80005956:	fffff097          	auipc	ra,0xfffff
    8000595a:	9b4080e7          	jalr	-1612(ra) # 8000430a <end_op>

  return fd;
}
    8000595e:	8526                	mv	a0,s1
    80005960:	70ea                	ld	ra,184(sp)
    80005962:	744a                	ld	s0,176(sp)
    80005964:	74aa                	ld	s1,168(sp)
    80005966:	790a                	ld	s2,160(sp)
    80005968:	69ea                	ld	s3,152(sp)
    8000596a:	6129                	addi	sp,sp,192
    8000596c:	8082                	ret
      end_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	99c080e7          	jalr	-1636(ra) # 8000430a <end_op>
      return -1;
    80005976:	b7e5                	j	8000595e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005978:	f5040513          	addi	a0,s0,-176
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	702080e7          	jalr	1794(ra) # 8000407e <namei>
    80005984:	892a                	mv	s2,a0
    80005986:	c905                	beqz	a0,800059b6 <sys_open+0x13c>
    ilock(ip);
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	f42080e7          	jalr	-190(ra) # 800038ca <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005990:	04491703          	lh	a4,68(s2)
    80005994:	4785                	li	a5,1
    80005996:	f4f712e3          	bne	a4,a5,800058da <sys_open+0x60>
    8000599a:	f4c42783          	lw	a5,-180(s0)
    8000599e:	dba1                	beqz	a5,800058ee <sys_open+0x74>
      iunlockput(ip);
    800059a0:	854a                	mv	a0,s2
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	18a080e7          	jalr	394(ra) # 80003b2c <iunlockput>
      end_op();
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	960080e7          	jalr	-1696(ra) # 8000430a <end_op>
      return -1;
    800059b2:	54fd                	li	s1,-1
    800059b4:	b76d                	j	8000595e <sys_open+0xe4>
      end_op();
    800059b6:	fffff097          	auipc	ra,0xfffff
    800059ba:	954080e7          	jalr	-1708(ra) # 8000430a <end_op>
      return -1;
    800059be:	54fd                	li	s1,-1
    800059c0:	bf79                	j	8000595e <sys_open+0xe4>
    iunlockput(ip);
    800059c2:	854a                	mv	a0,s2
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	168080e7          	jalr	360(ra) # 80003b2c <iunlockput>
    end_op();
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	93e080e7          	jalr	-1730(ra) # 8000430a <end_op>
    return -1;
    800059d4:	54fd                	li	s1,-1
    800059d6:	b761                	j	8000595e <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059d8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059dc:	04691783          	lh	a5,70(s2)
    800059e0:	02f99223          	sh	a5,36(s3)
    800059e4:	bf2d                	j	8000591e <sys_open+0xa4>
    itrunc(ip);
    800059e6:	854a                	mv	a0,s2
    800059e8:	ffffe097          	auipc	ra,0xffffe
    800059ec:	ff0080e7          	jalr	-16(ra) # 800039d8 <itrunc>
    800059f0:	bfb1                	j	8000594c <sys_open+0xd2>
      fileclose(f);
    800059f2:	854e                	mv	a0,s3
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	d68080e7          	jalr	-664(ra) # 8000475c <fileclose>
    iunlockput(ip);
    800059fc:	854a                	mv	a0,s2
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	12e080e7          	jalr	302(ra) # 80003b2c <iunlockput>
    end_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	904080e7          	jalr	-1788(ra) # 8000430a <end_op>
    return -1;
    80005a0e:	54fd                	li	s1,-1
    80005a10:	b7b9                	j	8000595e <sys_open+0xe4>

0000000080005a12 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a12:	7175                	addi	sp,sp,-144
    80005a14:	e506                	sd	ra,136(sp)
    80005a16:	e122                	sd	s0,128(sp)
    80005a18:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	870080e7          	jalr	-1936(ra) # 8000428a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a22:	08000613          	li	a2,128
    80005a26:	f7040593          	addi	a1,s0,-144
    80005a2a:	4501                	li	a0,0
    80005a2c:	ffffd097          	auipc	ra,0xffffd
    80005a30:	370080e7          	jalr	880(ra) # 80002d9c <argstr>
    80005a34:	02054963          	bltz	a0,80005a66 <sys_mkdir+0x54>
    80005a38:	4681                	li	a3,0
    80005a3a:	4601                	li	a2,0
    80005a3c:	4585                	li	a1,1
    80005a3e:	f7040513          	addi	a0,s0,-144
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	7fe080e7          	jalr	2046(ra) # 80005240 <create>
    80005a4a:	cd11                	beqz	a0,80005a66 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	0e0080e7          	jalr	224(ra) # 80003b2c <iunlockput>
  end_op();
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	8b6080e7          	jalr	-1866(ra) # 8000430a <end_op>
  return 0;
    80005a5c:	4501                	li	a0,0
}
    80005a5e:	60aa                	ld	ra,136(sp)
    80005a60:	640a                	ld	s0,128(sp)
    80005a62:	6149                	addi	sp,sp,144
    80005a64:	8082                	ret
    end_op();
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	8a4080e7          	jalr	-1884(ra) # 8000430a <end_op>
    return -1;
    80005a6e:	557d                	li	a0,-1
    80005a70:	b7fd                	j	80005a5e <sys_mkdir+0x4c>

0000000080005a72 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a72:	7135                	addi	sp,sp,-160
    80005a74:	ed06                	sd	ra,152(sp)
    80005a76:	e922                	sd	s0,144(sp)
    80005a78:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	810080e7          	jalr	-2032(ra) # 8000428a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a82:	08000613          	li	a2,128
    80005a86:	f7040593          	addi	a1,s0,-144
    80005a8a:	4501                	li	a0,0
    80005a8c:	ffffd097          	auipc	ra,0xffffd
    80005a90:	310080e7          	jalr	784(ra) # 80002d9c <argstr>
    80005a94:	04054a63          	bltz	a0,80005ae8 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a98:	f6c40593          	addi	a1,s0,-148
    80005a9c:	4505                	li	a0,1
    80005a9e:	ffffd097          	auipc	ra,0xffffd
    80005aa2:	2ba080e7          	jalr	698(ra) # 80002d58 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa6:	04054163          	bltz	a0,80005ae8 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005aaa:	f6840593          	addi	a1,s0,-152
    80005aae:	4509                	li	a0,2
    80005ab0:	ffffd097          	auipc	ra,0xffffd
    80005ab4:	2a8080e7          	jalr	680(ra) # 80002d58 <argint>
     argint(1, &major) < 0 ||
    80005ab8:	02054863          	bltz	a0,80005ae8 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005abc:	f6841683          	lh	a3,-152(s0)
    80005ac0:	f6c41603          	lh	a2,-148(s0)
    80005ac4:	458d                	li	a1,3
    80005ac6:	f7040513          	addi	a0,s0,-144
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	776080e7          	jalr	1910(ra) # 80005240 <create>
     argint(2, &minor) < 0 ||
    80005ad2:	c919                	beqz	a0,80005ae8 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	058080e7          	jalr	88(ra) # 80003b2c <iunlockput>
  end_op();
    80005adc:	fffff097          	auipc	ra,0xfffff
    80005ae0:	82e080e7          	jalr	-2002(ra) # 8000430a <end_op>
  return 0;
    80005ae4:	4501                	li	a0,0
    80005ae6:	a031                	j	80005af2 <sys_mknod+0x80>
    end_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	822080e7          	jalr	-2014(ra) # 8000430a <end_op>
    return -1;
    80005af0:	557d                	li	a0,-1
}
    80005af2:	60ea                	ld	ra,152(sp)
    80005af4:	644a                	ld	s0,144(sp)
    80005af6:	610d                	addi	sp,sp,160
    80005af8:	8082                	ret

0000000080005afa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005afa:	7135                	addi	sp,sp,-160
    80005afc:	ed06                	sd	ra,152(sp)
    80005afe:	e922                	sd	s0,144(sp)
    80005b00:	e526                	sd	s1,136(sp)
    80005b02:	e14a                	sd	s2,128(sp)
    80005b04:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b06:	ffffc097          	auipc	ra,0xffffc
    80005b0a:	164080e7          	jalr	356(ra) # 80001c6a <myproc>
    80005b0e:	892a                	mv	s2,a0
  
  begin_op();
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	77a080e7          	jalr	1914(ra) # 8000428a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b18:	08000613          	li	a2,128
    80005b1c:	f6040593          	addi	a1,s0,-160
    80005b20:	4501                	li	a0,0
    80005b22:	ffffd097          	auipc	ra,0xffffd
    80005b26:	27a080e7          	jalr	634(ra) # 80002d9c <argstr>
    80005b2a:	04054b63          	bltz	a0,80005b80 <sys_chdir+0x86>
    80005b2e:	f6040513          	addi	a0,s0,-160
    80005b32:	ffffe097          	auipc	ra,0xffffe
    80005b36:	54c080e7          	jalr	1356(ra) # 8000407e <namei>
    80005b3a:	84aa                	mv	s1,a0
    80005b3c:	c131                	beqz	a0,80005b80 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b3e:	ffffe097          	auipc	ra,0xffffe
    80005b42:	d8c080e7          	jalr	-628(ra) # 800038ca <ilock>
  if(ip->type != T_DIR){
    80005b46:	04449703          	lh	a4,68(s1)
    80005b4a:	4785                	li	a5,1
    80005b4c:	04f71063          	bne	a4,a5,80005b8c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b50:	8526                	mv	a0,s1
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	e3a080e7          	jalr	-454(ra) # 8000398c <iunlock>
  iput(p->cwd);
    80005b5a:	15093503          	ld	a0,336(s2)
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	f26080e7          	jalr	-218(ra) # 80003a84 <iput>
  end_op();
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	7a4080e7          	jalr	1956(ra) # 8000430a <end_op>
  p->cwd = ip;
    80005b6e:	14993823          	sd	s1,336(s2)
  return 0;
    80005b72:	4501                	li	a0,0
}
    80005b74:	60ea                	ld	ra,152(sp)
    80005b76:	644a                	ld	s0,144(sp)
    80005b78:	64aa                	ld	s1,136(sp)
    80005b7a:	690a                	ld	s2,128(sp)
    80005b7c:	610d                	addi	sp,sp,160
    80005b7e:	8082                	ret
    end_op();
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	78a080e7          	jalr	1930(ra) # 8000430a <end_op>
    return -1;
    80005b88:	557d                	li	a0,-1
    80005b8a:	b7ed                	j	80005b74 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b8c:	8526                	mv	a0,s1
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	f9e080e7          	jalr	-98(ra) # 80003b2c <iunlockput>
    end_op();
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	774080e7          	jalr	1908(ra) # 8000430a <end_op>
    return -1;
    80005b9e:	557d                	li	a0,-1
    80005ba0:	bfd1                	j	80005b74 <sys_chdir+0x7a>

0000000080005ba2 <sys_exec>:

uint64
sys_exec(void)
{
    80005ba2:	7145                	addi	sp,sp,-464
    80005ba4:	e786                	sd	ra,456(sp)
    80005ba6:	e3a2                	sd	s0,448(sp)
    80005ba8:	ff26                	sd	s1,440(sp)
    80005baa:	fb4a                	sd	s2,432(sp)
    80005bac:	f74e                	sd	s3,424(sp)
    80005bae:	f352                	sd	s4,416(sp)
    80005bb0:	ef56                	sd	s5,408(sp)
    80005bb2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bb4:	08000613          	li	a2,128
    80005bb8:	f4040593          	addi	a1,s0,-192
    80005bbc:	4501                	li	a0,0
    80005bbe:	ffffd097          	auipc	ra,0xffffd
    80005bc2:	1de080e7          	jalr	478(ra) # 80002d9c <argstr>
    return -1;
    80005bc6:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bc8:	0c054a63          	bltz	a0,80005c9c <sys_exec+0xfa>
    80005bcc:	e3840593          	addi	a1,s0,-456
    80005bd0:	4505                	li	a0,1
    80005bd2:	ffffd097          	auipc	ra,0xffffd
    80005bd6:	1a8080e7          	jalr	424(ra) # 80002d7a <argaddr>
    80005bda:	0c054163          	bltz	a0,80005c9c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005bde:	10000613          	li	a2,256
    80005be2:	4581                	li	a1,0
    80005be4:	e4040513          	addi	a0,s0,-448
    80005be8:	ffffb097          	auipc	ra,0xffffb
    80005bec:	39e080e7          	jalr	926(ra) # 80000f86 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bf0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005bf4:	89a6                	mv	s3,s1
    80005bf6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bf8:	02000a13          	li	s4,32
    80005bfc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c00:	00391513          	slli	a0,s2,0x3
    80005c04:	e3040593          	addi	a1,s0,-464
    80005c08:	e3843783          	ld	a5,-456(s0)
    80005c0c:	953e                	add	a0,a0,a5
    80005c0e:	ffffd097          	auipc	ra,0xffffd
    80005c12:	0b0080e7          	jalr	176(ra) # 80002cbe <fetchaddr>
    80005c16:	02054a63          	bltz	a0,80005c4a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c1a:	e3043783          	ld	a5,-464(s0)
    80005c1e:	c3b9                	beqz	a5,80005c64 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c20:	ffffb097          	auipc	ra,0xffffb
    80005c24:	f88080e7          	jalr	-120(ra) # 80000ba8 <kalloc>
    80005c28:	85aa                	mv	a1,a0
    80005c2a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c2e:	cd11                	beqz	a0,80005c4a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c30:	6605                	lui	a2,0x1
    80005c32:	e3043503          	ld	a0,-464(s0)
    80005c36:	ffffd097          	auipc	ra,0xffffd
    80005c3a:	0da080e7          	jalr	218(ra) # 80002d10 <fetchstr>
    80005c3e:	00054663          	bltz	a0,80005c4a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c42:	0905                	addi	s2,s2,1
    80005c44:	09a1                	addi	s3,s3,8
    80005c46:	fb491be3          	bne	s2,s4,80005bfc <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c4a:	10048913          	addi	s2,s1,256
    80005c4e:	6088                	ld	a0,0(s1)
    80005c50:	c529                	beqz	a0,80005c9a <sys_exec+0xf8>
    kfree(argv[i]);
    80005c52:	ffffb097          	auipc	ra,0xffffb
    80005c56:	dd2080e7          	jalr	-558(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c5a:	04a1                	addi	s1,s1,8
    80005c5c:	ff2499e3          	bne	s1,s2,80005c4e <sys_exec+0xac>
  return -1;
    80005c60:	597d                	li	s2,-1
    80005c62:	a82d                	j	80005c9c <sys_exec+0xfa>
      argv[i] = 0;
    80005c64:	0a8e                	slli	s5,s5,0x3
    80005c66:	fc040793          	addi	a5,s0,-64
    80005c6a:	9abe                	add	s5,s5,a5
    80005c6c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c70:	e4040593          	addi	a1,s0,-448
    80005c74:	f4040513          	addi	a0,s0,-192
    80005c78:	fffff097          	auipc	ra,0xfffff
    80005c7c:	194080e7          	jalr	404(ra) # 80004e0c <exec>
    80005c80:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c82:	10048993          	addi	s3,s1,256
    80005c86:	6088                	ld	a0,0(s1)
    80005c88:	c911                	beqz	a0,80005c9c <sys_exec+0xfa>
    kfree(argv[i]);
    80005c8a:	ffffb097          	auipc	ra,0xffffb
    80005c8e:	d9a080e7          	jalr	-614(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c92:	04a1                	addi	s1,s1,8
    80005c94:	ff3499e3          	bne	s1,s3,80005c86 <sys_exec+0xe4>
    80005c98:	a011                	j	80005c9c <sys_exec+0xfa>
  return -1;
    80005c9a:	597d                	li	s2,-1
}
    80005c9c:	854a                	mv	a0,s2
    80005c9e:	60be                	ld	ra,456(sp)
    80005ca0:	641e                	ld	s0,448(sp)
    80005ca2:	74fa                	ld	s1,440(sp)
    80005ca4:	795a                	ld	s2,432(sp)
    80005ca6:	79ba                	ld	s3,424(sp)
    80005ca8:	7a1a                	ld	s4,416(sp)
    80005caa:	6afa                	ld	s5,408(sp)
    80005cac:	6179                	addi	sp,sp,464
    80005cae:	8082                	ret

0000000080005cb0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cb0:	7139                	addi	sp,sp,-64
    80005cb2:	fc06                	sd	ra,56(sp)
    80005cb4:	f822                	sd	s0,48(sp)
    80005cb6:	f426                	sd	s1,40(sp)
    80005cb8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cba:	ffffc097          	auipc	ra,0xffffc
    80005cbe:	fb0080e7          	jalr	-80(ra) # 80001c6a <myproc>
    80005cc2:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cc4:	fd840593          	addi	a1,s0,-40
    80005cc8:	4501                	li	a0,0
    80005cca:	ffffd097          	auipc	ra,0xffffd
    80005cce:	0b0080e7          	jalr	176(ra) # 80002d7a <argaddr>
    return -1;
    80005cd2:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005cd4:	0e054063          	bltz	a0,80005db4 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005cd8:	fc840593          	addi	a1,s0,-56
    80005cdc:	fd040513          	addi	a0,s0,-48
    80005ce0:	fffff097          	auipc	ra,0xfffff
    80005ce4:	dd2080e7          	jalr	-558(ra) # 80004ab2 <pipealloc>
    return -1;
    80005ce8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cea:	0c054563          	bltz	a0,80005db4 <sys_pipe+0x104>
  fd0 = -1;
    80005cee:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005cf2:	fd043503          	ld	a0,-48(s0)
    80005cf6:	fffff097          	auipc	ra,0xfffff
    80005cfa:	508080e7          	jalr	1288(ra) # 800051fe <fdalloc>
    80005cfe:	fca42223          	sw	a0,-60(s0)
    80005d02:	08054c63          	bltz	a0,80005d9a <sys_pipe+0xea>
    80005d06:	fc843503          	ld	a0,-56(s0)
    80005d0a:	fffff097          	auipc	ra,0xfffff
    80005d0e:	4f4080e7          	jalr	1268(ra) # 800051fe <fdalloc>
    80005d12:	fca42023          	sw	a0,-64(s0)
    80005d16:	06054863          	bltz	a0,80005d86 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d1a:	4691                	li	a3,4
    80005d1c:	fc440613          	addi	a2,s0,-60
    80005d20:	fd843583          	ld	a1,-40(s0)
    80005d24:	68a8                	ld	a0,80(s1)
    80005d26:	ffffc097          	auipc	ra,0xffffc
    80005d2a:	c12080e7          	jalr	-1006(ra) # 80001938 <copyout>
    80005d2e:	02054063          	bltz	a0,80005d4e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d32:	4691                	li	a3,4
    80005d34:	fc040613          	addi	a2,s0,-64
    80005d38:	fd843583          	ld	a1,-40(s0)
    80005d3c:	0591                	addi	a1,a1,4
    80005d3e:	68a8                	ld	a0,80(s1)
    80005d40:	ffffc097          	auipc	ra,0xffffc
    80005d44:	bf8080e7          	jalr	-1032(ra) # 80001938 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d48:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d4a:	06055563          	bgez	a0,80005db4 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d4e:	fc442783          	lw	a5,-60(s0)
    80005d52:	07e9                	addi	a5,a5,26
    80005d54:	078e                	slli	a5,a5,0x3
    80005d56:	97a6                	add	a5,a5,s1
    80005d58:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d5c:	fc042503          	lw	a0,-64(s0)
    80005d60:	0569                	addi	a0,a0,26
    80005d62:	050e                	slli	a0,a0,0x3
    80005d64:	9526                	add	a0,a0,s1
    80005d66:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d6a:	fd043503          	ld	a0,-48(s0)
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	9ee080e7          	jalr	-1554(ra) # 8000475c <fileclose>
    fileclose(wf);
    80005d76:	fc843503          	ld	a0,-56(s0)
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	9e2080e7          	jalr	-1566(ra) # 8000475c <fileclose>
    return -1;
    80005d82:	57fd                	li	a5,-1
    80005d84:	a805                	j	80005db4 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005d86:	fc442783          	lw	a5,-60(s0)
    80005d8a:	0007c863          	bltz	a5,80005d9a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005d8e:	01a78513          	addi	a0,a5,26
    80005d92:	050e                	slli	a0,a0,0x3
    80005d94:	9526                	add	a0,a0,s1
    80005d96:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d9a:	fd043503          	ld	a0,-48(s0)
    80005d9e:	fffff097          	auipc	ra,0xfffff
    80005da2:	9be080e7          	jalr	-1602(ra) # 8000475c <fileclose>
    fileclose(wf);
    80005da6:	fc843503          	ld	a0,-56(s0)
    80005daa:	fffff097          	auipc	ra,0xfffff
    80005dae:	9b2080e7          	jalr	-1614(ra) # 8000475c <fileclose>
    return -1;
    80005db2:	57fd                	li	a5,-1
}
    80005db4:	853e                	mv	a0,a5
    80005db6:	70e2                	ld	ra,56(sp)
    80005db8:	7442                	ld	s0,48(sp)
    80005dba:	74a2                	ld	s1,40(sp)
    80005dbc:	6121                	addi	sp,sp,64
    80005dbe:	8082                	ret

0000000080005dc0 <kernelvec>:
    80005dc0:	7111                	addi	sp,sp,-256
    80005dc2:	e006                	sd	ra,0(sp)
    80005dc4:	e40a                	sd	sp,8(sp)
    80005dc6:	e80e                	sd	gp,16(sp)
    80005dc8:	ec12                	sd	tp,24(sp)
    80005dca:	f016                	sd	t0,32(sp)
    80005dcc:	f41a                	sd	t1,40(sp)
    80005dce:	f81e                	sd	t2,48(sp)
    80005dd0:	fc22                	sd	s0,56(sp)
    80005dd2:	e0a6                	sd	s1,64(sp)
    80005dd4:	e4aa                	sd	a0,72(sp)
    80005dd6:	e8ae                	sd	a1,80(sp)
    80005dd8:	ecb2                	sd	a2,88(sp)
    80005dda:	f0b6                	sd	a3,96(sp)
    80005ddc:	f4ba                	sd	a4,104(sp)
    80005dde:	f8be                	sd	a5,112(sp)
    80005de0:	fcc2                	sd	a6,120(sp)
    80005de2:	e146                	sd	a7,128(sp)
    80005de4:	e54a                	sd	s2,136(sp)
    80005de6:	e94e                	sd	s3,144(sp)
    80005de8:	ed52                	sd	s4,152(sp)
    80005dea:	f156                	sd	s5,160(sp)
    80005dec:	f55a                	sd	s6,168(sp)
    80005dee:	f95e                	sd	s7,176(sp)
    80005df0:	fd62                	sd	s8,184(sp)
    80005df2:	e1e6                	sd	s9,192(sp)
    80005df4:	e5ea                	sd	s10,200(sp)
    80005df6:	e9ee                	sd	s11,208(sp)
    80005df8:	edf2                	sd	t3,216(sp)
    80005dfa:	f1f6                	sd	t4,224(sp)
    80005dfc:	f5fa                	sd	t5,232(sp)
    80005dfe:	f9fe                	sd	t6,240(sp)
    80005e00:	d8bfc0ef          	jal	ra,80002b8a <kerneltrap>
    80005e04:	6082                	ld	ra,0(sp)
    80005e06:	6122                	ld	sp,8(sp)
    80005e08:	61c2                	ld	gp,16(sp)
    80005e0a:	7282                	ld	t0,32(sp)
    80005e0c:	7322                	ld	t1,40(sp)
    80005e0e:	73c2                	ld	t2,48(sp)
    80005e10:	7462                	ld	s0,56(sp)
    80005e12:	6486                	ld	s1,64(sp)
    80005e14:	6526                	ld	a0,72(sp)
    80005e16:	65c6                	ld	a1,80(sp)
    80005e18:	6666                	ld	a2,88(sp)
    80005e1a:	7686                	ld	a3,96(sp)
    80005e1c:	7726                	ld	a4,104(sp)
    80005e1e:	77c6                	ld	a5,112(sp)
    80005e20:	7866                	ld	a6,120(sp)
    80005e22:	688a                	ld	a7,128(sp)
    80005e24:	692a                	ld	s2,136(sp)
    80005e26:	69ca                	ld	s3,144(sp)
    80005e28:	6a6a                	ld	s4,152(sp)
    80005e2a:	7a8a                	ld	s5,160(sp)
    80005e2c:	7b2a                	ld	s6,168(sp)
    80005e2e:	7bca                	ld	s7,176(sp)
    80005e30:	7c6a                	ld	s8,184(sp)
    80005e32:	6c8e                	ld	s9,192(sp)
    80005e34:	6d2e                	ld	s10,200(sp)
    80005e36:	6dce                	ld	s11,208(sp)
    80005e38:	6e6e                	ld	t3,216(sp)
    80005e3a:	7e8e                	ld	t4,224(sp)
    80005e3c:	7f2e                	ld	t5,232(sp)
    80005e3e:	7fce                	ld	t6,240(sp)
    80005e40:	6111                	addi	sp,sp,256
    80005e42:	10200073          	sret
    80005e46:	00000013          	nop
    80005e4a:	00000013          	nop
    80005e4e:	0001                	nop

0000000080005e50 <timervec>:
    80005e50:	34051573          	csrrw	a0,mscratch,a0
    80005e54:	e10c                	sd	a1,0(a0)
    80005e56:	e510                	sd	a2,8(a0)
    80005e58:	e914                	sd	a3,16(a0)
    80005e5a:	710c                	ld	a1,32(a0)
    80005e5c:	7510                	ld	a2,40(a0)
    80005e5e:	6194                	ld	a3,0(a1)
    80005e60:	96b2                	add	a3,a3,a2
    80005e62:	e194                	sd	a3,0(a1)
    80005e64:	4589                	li	a1,2
    80005e66:	14459073          	csrw	sip,a1
    80005e6a:	6914                	ld	a3,16(a0)
    80005e6c:	6510                	ld	a2,8(a0)
    80005e6e:	610c                	ld	a1,0(a0)
    80005e70:	34051573          	csrrw	a0,mscratch,a0
    80005e74:	30200073          	mret
	...

0000000080005e7a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e7a:	1141                	addi	sp,sp,-16
    80005e7c:	e422                	sd	s0,8(sp)
    80005e7e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e80:	0c0007b7          	lui	a5,0xc000
    80005e84:	4705                	li	a4,1
    80005e86:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e88:	c3d8                	sw	a4,4(a5)
}
    80005e8a:	6422                	ld	s0,8(sp)
    80005e8c:	0141                	addi	sp,sp,16
    80005e8e:	8082                	ret

0000000080005e90 <plicinithart>:

void
plicinithart(void)
{
    80005e90:	1141                	addi	sp,sp,-16
    80005e92:	e406                	sd	ra,8(sp)
    80005e94:	e022                	sd	s0,0(sp)
    80005e96:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e98:	ffffc097          	auipc	ra,0xffffc
    80005e9c:	da6080e7          	jalr	-602(ra) # 80001c3e <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ea0:	0085171b          	slliw	a4,a0,0x8
    80005ea4:	0c0027b7          	lui	a5,0xc002
    80005ea8:	97ba                	add	a5,a5,a4
    80005eaa:	40200713          	li	a4,1026
    80005eae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005eb2:	00d5151b          	slliw	a0,a0,0xd
    80005eb6:	0c2017b7          	lui	a5,0xc201
    80005eba:	953e                	add	a0,a0,a5
    80005ebc:	00052023          	sw	zero,0(a0)
}
    80005ec0:	60a2                	ld	ra,8(sp)
    80005ec2:	6402                	ld	s0,0(sp)
    80005ec4:	0141                	addi	sp,sp,16
    80005ec6:	8082                	ret

0000000080005ec8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ec8:	1141                	addi	sp,sp,-16
    80005eca:	e406                	sd	ra,8(sp)
    80005ecc:	e022                	sd	s0,0(sp)
    80005ece:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ed0:	ffffc097          	auipc	ra,0xffffc
    80005ed4:	d6e080e7          	jalr	-658(ra) # 80001c3e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ed8:	00d5179b          	slliw	a5,a0,0xd
    80005edc:	0c201537          	lui	a0,0xc201
    80005ee0:	953e                	add	a0,a0,a5
  return irq;
}
    80005ee2:	4148                	lw	a0,4(a0)
    80005ee4:	60a2                	ld	ra,8(sp)
    80005ee6:	6402                	ld	s0,0(sp)
    80005ee8:	0141                	addi	sp,sp,16
    80005eea:	8082                	ret

0000000080005eec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005eec:	1101                	addi	sp,sp,-32
    80005eee:	ec06                	sd	ra,24(sp)
    80005ef0:	e822                	sd	s0,16(sp)
    80005ef2:	e426                	sd	s1,8(sp)
    80005ef4:	1000                	addi	s0,sp,32
    80005ef6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ef8:	ffffc097          	auipc	ra,0xffffc
    80005efc:	d46080e7          	jalr	-698(ra) # 80001c3e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f00:	00d5151b          	slliw	a0,a0,0xd
    80005f04:	0c2017b7          	lui	a5,0xc201
    80005f08:	97aa                	add	a5,a5,a0
    80005f0a:	c3c4                	sw	s1,4(a5)
}
    80005f0c:	60e2                	ld	ra,24(sp)
    80005f0e:	6442                	ld	s0,16(sp)
    80005f10:	64a2                	ld	s1,8(sp)
    80005f12:	6105                	addi	sp,sp,32
    80005f14:	8082                	ret

0000000080005f16 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f16:	1141                	addi	sp,sp,-16
    80005f18:	e406                	sd	ra,8(sp)
    80005f1a:	e022                	sd	s0,0(sp)
    80005f1c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f1e:	479d                	li	a5,7
    80005f20:	04a7cc63          	blt	a5,a0,80005f78 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f24:	0111d797          	auipc	a5,0x111d
    80005f28:	0dc78793          	addi	a5,a5,220 # 81123000 <disk>
    80005f2c:	00a78733          	add	a4,a5,a0
    80005f30:	6789                	lui	a5,0x2
    80005f32:	97ba                	add	a5,a5,a4
    80005f34:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f38:	eba1                	bnez	a5,80005f88 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f3a:	00451713          	slli	a4,a0,0x4
    80005f3e:	0111f797          	auipc	a5,0x111f
    80005f42:	0c27b783          	ld	a5,194(a5) # 81125000 <disk+0x2000>
    80005f46:	97ba                	add	a5,a5,a4
    80005f48:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f4c:	0111d797          	auipc	a5,0x111d
    80005f50:	0b478793          	addi	a5,a5,180 # 81123000 <disk>
    80005f54:	97aa                	add	a5,a5,a0
    80005f56:	6509                	lui	a0,0x2
    80005f58:	953e                	add	a0,a0,a5
    80005f5a:	4785                	li	a5,1
    80005f5c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f60:	0111f517          	auipc	a0,0x111f
    80005f64:	0b850513          	addi	a0,a0,184 # 81125018 <disk+0x2018>
    80005f68:	ffffc097          	auipc	ra,0xffffc
    80005f6c:	698080e7          	jalr	1688(ra) # 80002600 <wakeup>
}
    80005f70:	60a2                	ld	ra,8(sp)
    80005f72:	6402                	ld	s0,0(sp)
    80005f74:	0141                	addi	sp,sp,16
    80005f76:	8082                	ret
    panic("virtio_disk_intr 1");
    80005f78:	00002517          	auipc	a0,0x2
    80005f7c:	7e850513          	addi	a0,a0,2024 # 80008760 <syscalls+0x330>
    80005f80:	ffffa097          	auipc	ra,0xffffa
    80005f84:	5c8080e7          	jalr	1480(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005f88:	00002517          	auipc	a0,0x2
    80005f8c:	7f050513          	addi	a0,a0,2032 # 80008778 <syscalls+0x348>
    80005f90:	ffffa097          	auipc	ra,0xffffa
    80005f94:	5b8080e7          	jalr	1464(ra) # 80000548 <panic>

0000000080005f98 <virtio_disk_init>:
{
    80005f98:	1101                	addi	sp,sp,-32
    80005f9a:	ec06                	sd	ra,24(sp)
    80005f9c:	e822                	sd	s0,16(sp)
    80005f9e:	e426                	sd	s1,8(sp)
    80005fa0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fa2:	00002597          	auipc	a1,0x2
    80005fa6:	7ee58593          	addi	a1,a1,2030 # 80008790 <syscalls+0x360>
    80005faa:	0111f517          	auipc	a0,0x111f
    80005fae:	0fe50513          	addi	a0,a0,254 # 811250a8 <disk+0x20a8>
    80005fb2:	ffffb097          	auipc	ra,0xffffb
    80005fb6:	e48080e7          	jalr	-440(ra) # 80000dfa <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fba:	100017b7          	lui	a5,0x10001
    80005fbe:	4398                	lw	a4,0(a5)
    80005fc0:	2701                	sext.w	a4,a4
    80005fc2:	747277b7          	lui	a5,0x74727
    80005fc6:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005fca:	0ef71163          	bne	a4,a5,800060ac <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fce:	100017b7          	lui	a5,0x10001
    80005fd2:	43dc                	lw	a5,4(a5)
    80005fd4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fd6:	4705                	li	a4,1
    80005fd8:	0ce79a63          	bne	a5,a4,800060ac <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fdc:	100017b7          	lui	a5,0x10001
    80005fe0:	479c                	lw	a5,8(a5)
    80005fe2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fe4:	4709                	li	a4,2
    80005fe6:	0ce79363          	bne	a5,a4,800060ac <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005fea:	100017b7          	lui	a5,0x10001
    80005fee:	47d8                	lw	a4,12(a5)
    80005ff0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ff2:	554d47b7          	lui	a5,0x554d4
    80005ff6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ffa:	0af71963          	bne	a4,a5,800060ac <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ffe:	100017b7          	lui	a5,0x10001
    80006002:	4705                	li	a4,1
    80006004:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006006:	470d                	li	a4,3
    80006008:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000600a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000600c:	c7ffe737          	lui	a4,0xc7ffe
    80006010:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff46ed875f>
    80006014:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006016:	2701                	sext.w	a4,a4
    80006018:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000601a:	472d                	li	a4,11
    8000601c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000601e:	473d                	li	a4,15
    80006020:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006022:	6705                	lui	a4,0x1
    80006024:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006026:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000602a:	5bdc                	lw	a5,52(a5)
    8000602c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000602e:	c7d9                	beqz	a5,800060bc <virtio_disk_init+0x124>
  if(max < NUM)
    80006030:	471d                	li	a4,7
    80006032:	08f77d63          	bgeu	a4,a5,800060cc <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006036:	100014b7          	lui	s1,0x10001
    8000603a:	47a1                	li	a5,8
    8000603c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000603e:	6609                	lui	a2,0x2
    80006040:	4581                	li	a1,0
    80006042:	0111d517          	auipc	a0,0x111d
    80006046:	fbe50513          	addi	a0,a0,-66 # 81123000 <disk>
    8000604a:	ffffb097          	auipc	ra,0xffffb
    8000604e:	f3c080e7          	jalr	-196(ra) # 80000f86 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006052:	0111d717          	auipc	a4,0x111d
    80006056:	fae70713          	addi	a4,a4,-82 # 81123000 <disk>
    8000605a:	00c75793          	srli	a5,a4,0xc
    8000605e:	2781                	sext.w	a5,a5
    80006060:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006062:	0111f797          	auipc	a5,0x111f
    80006066:	f9e78793          	addi	a5,a5,-98 # 81125000 <disk+0x2000>
    8000606a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000606c:	0111d717          	auipc	a4,0x111d
    80006070:	01470713          	addi	a4,a4,20 # 81123080 <disk+0x80>
    80006074:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006076:	0111e717          	auipc	a4,0x111e
    8000607a:	f8a70713          	addi	a4,a4,-118 # 81124000 <disk+0x1000>
    8000607e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006080:	4705                	li	a4,1
    80006082:	00e78c23          	sb	a4,24(a5)
    80006086:	00e78ca3          	sb	a4,25(a5)
    8000608a:	00e78d23          	sb	a4,26(a5)
    8000608e:	00e78da3          	sb	a4,27(a5)
    80006092:	00e78e23          	sb	a4,28(a5)
    80006096:	00e78ea3          	sb	a4,29(a5)
    8000609a:	00e78f23          	sb	a4,30(a5)
    8000609e:	00e78fa3          	sb	a4,31(a5)
}
    800060a2:	60e2                	ld	ra,24(sp)
    800060a4:	6442                	ld	s0,16(sp)
    800060a6:	64a2                	ld	s1,8(sp)
    800060a8:	6105                	addi	sp,sp,32
    800060aa:	8082                	ret
    panic("could not find virtio disk");
    800060ac:	00002517          	auipc	a0,0x2
    800060b0:	6f450513          	addi	a0,a0,1780 # 800087a0 <syscalls+0x370>
    800060b4:	ffffa097          	auipc	ra,0xffffa
    800060b8:	494080e7          	jalr	1172(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    800060bc:	00002517          	auipc	a0,0x2
    800060c0:	70450513          	addi	a0,a0,1796 # 800087c0 <syscalls+0x390>
    800060c4:	ffffa097          	auipc	ra,0xffffa
    800060c8:	484080e7          	jalr	1156(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    800060cc:	00002517          	auipc	a0,0x2
    800060d0:	71450513          	addi	a0,a0,1812 # 800087e0 <syscalls+0x3b0>
    800060d4:	ffffa097          	auipc	ra,0xffffa
    800060d8:	474080e7          	jalr	1140(ra) # 80000548 <panic>

00000000800060dc <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060dc:	7119                	addi	sp,sp,-128
    800060de:	fc86                	sd	ra,120(sp)
    800060e0:	f8a2                	sd	s0,112(sp)
    800060e2:	f4a6                	sd	s1,104(sp)
    800060e4:	f0ca                	sd	s2,96(sp)
    800060e6:	ecce                	sd	s3,88(sp)
    800060e8:	e8d2                	sd	s4,80(sp)
    800060ea:	e4d6                	sd	s5,72(sp)
    800060ec:	e0da                	sd	s6,64(sp)
    800060ee:	fc5e                	sd	s7,56(sp)
    800060f0:	f862                	sd	s8,48(sp)
    800060f2:	f466                	sd	s9,40(sp)
    800060f4:	f06a                	sd	s10,32(sp)
    800060f6:	0100                	addi	s0,sp,128
    800060f8:	892a                	mv	s2,a0
    800060fa:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060fc:	00c52c83          	lw	s9,12(a0)
    80006100:	001c9c9b          	slliw	s9,s9,0x1
    80006104:	1c82                	slli	s9,s9,0x20
    80006106:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000610a:	0111f517          	auipc	a0,0x111f
    8000610e:	f9e50513          	addi	a0,a0,-98 # 811250a8 <disk+0x20a8>
    80006112:	ffffb097          	auipc	ra,0xffffb
    80006116:	d78080e7          	jalr	-648(ra) # 80000e8a <acquire>
  for(int i = 0; i < 3; i++){
    8000611a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000611c:	4c21                	li	s8,8
      disk.free[i] = 0;
    8000611e:	0111db97          	auipc	s7,0x111d
    80006122:	ee2b8b93          	addi	s7,s7,-286 # 81123000 <disk>
    80006126:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006128:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    8000612a:	8a4e                	mv	s4,s3
    8000612c:	a051                	j	800061b0 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    8000612e:	00fb86b3          	add	a3,s7,a5
    80006132:	96da                	add	a3,a3,s6
    80006134:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006138:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000613a:	0207c563          	bltz	a5,80006164 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000613e:	2485                	addiw	s1,s1,1
    80006140:	0711                	addi	a4,a4,4
    80006142:	23548d63          	beq	s1,s5,8000637c <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80006146:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006148:	0111f697          	auipc	a3,0x111f
    8000614c:	ed068693          	addi	a3,a3,-304 # 81125018 <disk+0x2018>
    80006150:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006152:	0006c583          	lbu	a1,0(a3)
    80006156:	fde1                	bnez	a1,8000612e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006158:	2785                	addiw	a5,a5,1
    8000615a:	0685                	addi	a3,a3,1
    8000615c:	ff879be3          	bne	a5,s8,80006152 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006160:	57fd                	li	a5,-1
    80006162:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006164:	02905a63          	blez	s1,80006198 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006168:	f9042503          	lw	a0,-112(s0)
    8000616c:	00000097          	auipc	ra,0x0
    80006170:	daa080e7          	jalr	-598(ra) # 80005f16 <free_desc>
      for(int j = 0; j < i; j++)
    80006174:	4785                	li	a5,1
    80006176:	0297d163          	bge	a5,s1,80006198 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000617a:	f9442503          	lw	a0,-108(s0)
    8000617e:	00000097          	auipc	ra,0x0
    80006182:	d98080e7          	jalr	-616(ra) # 80005f16 <free_desc>
      for(int j = 0; j < i; j++)
    80006186:	4789                	li	a5,2
    80006188:	0097d863          	bge	a5,s1,80006198 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000618c:	f9842503          	lw	a0,-104(s0)
    80006190:	00000097          	auipc	ra,0x0
    80006194:	d86080e7          	jalr	-634(ra) # 80005f16 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006198:	0111f597          	auipc	a1,0x111f
    8000619c:	f1058593          	addi	a1,a1,-240 # 811250a8 <disk+0x20a8>
    800061a0:	0111f517          	auipc	a0,0x111f
    800061a4:	e7850513          	addi	a0,a0,-392 # 81125018 <disk+0x2018>
    800061a8:	ffffc097          	auipc	ra,0xffffc
    800061ac:	2d2080e7          	jalr	722(ra) # 8000247a <sleep>
  for(int i = 0; i < 3; i++){
    800061b0:	f9040713          	addi	a4,s0,-112
    800061b4:	84ce                	mv	s1,s3
    800061b6:	bf41                	j	80006146 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    800061b8:	4785                	li	a5,1
    800061ba:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    800061be:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    800061c2:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800061c6:	f9042983          	lw	s3,-112(s0)
    800061ca:	00499493          	slli	s1,s3,0x4
    800061ce:	0111fa17          	auipc	s4,0x111f
    800061d2:	e32a0a13          	addi	s4,s4,-462 # 81125000 <disk+0x2000>
    800061d6:	000a3a83          	ld	s5,0(s4)
    800061da:	9aa6                	add	s5,s5,s1
    800061dc:	f8040513          	addi	a0,s0,-128
    800061e0:	ffffb097          	auipc	ra,0xffffb
    800061e4:	17a080e7          	jalr	378(ra) # 8000135a <kvmpa>
    800061e8:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    800061ec:	000a3783          	ld	a5,0(s4)
    800061f0:	97a6                	add	a5,a5,s1
    800061f2:	4741                	li	a4,16
    800061f4:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061f6:	000a3783          	ld	a5,0(s4)
    800061fa:	97a6                	add	a5,a5,s1
    800061fc:	4705                	li	a4,1
    800061fe:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006202:	f9442703          	lw	a4,-108(s0)
    80006206:	000a3783          	ld	a5,0(s4)
    8000620a:	97a6                	add	a5,a5,s1
    8000620c:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006210:	0712                	slli	a4,a4,0x4
    80006212:	000a3783          	ld	a5,0(s4)
    80006216:	97ba                	add	a5,a5,a4
    80006218:	05890693          	addi	a3,s2,88
    8000621c:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000621e:	000a3783          	ld	a5,0(s4)
    80006222:	97ba                	add	a5,a5,a4
    80006224:	40000693          	li	a3,1024
    80006228:	c794                	sw	a3,8(a5)
  if(write)
    8000622a:	100d0a63          	beqz	s10,8000633e <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000622e:	0111f797          	auipc	a5,0x111f
    80006232:	dd27b783          	ld	a5,-558(a5) # 81125000 <disk+0x2000>
    80006236:	97ba                	add	a5,a5,a4
    80006238:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000623c:	0111d517          	auipc	a0,0x111d
    80006240:	dc450513          	addi	a0,a0,-572 # 81123000 <disk>
    80006244:	0111f797          	auipc	a5,0x111f
    80006248:	dbc78793          	addi	a5,a5,-580 # 81125000 <disk+0x2000>
    8000624c:	6394                	ld	a3,0(a5)
    8000624e:	96ba                	add	a3,a3,a4
    80006250:	00c6d603          	lhu	a2,12(a3)
    80006254:	00166613          	ori	a2,a2,1
    80006258:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000625c:	f9842683          	lw	a3,-104(s0)
    80006260:	6390                	ld	a2,0(a5)
    80006262:	9732                	add	a4,a4,a2
    80006264:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006268:	20098613          	addi	a2,s3,512
    8000626c:	0612                	slli	a2,a2,0x4
    8000626e:	962a                	add	a2,a2,a0
    80006270:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006274:	00469713          	slli	a4,a3,0x4
    80006278:	6394                	ld	a3,0(a5)
    8000627a:	96ba                	add	a3,a3,a4
    8000627c:	6589                	lui	a1,0x2
    8000627e:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80006282:	94ae                	add	s1,s1,a1
    80006284:	94aa                	add	s1,s1,a0
    80006286:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006288:	6394                	ld	a3,0(a5)
    8000628a:	96ba                	add	a3,a3,a4
    8000628c:	4585                	li	a1,1
    8000628e:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006290:	6394                	ld	a3,0(a5)
    80006292:	96ba                	add	a3,a3,a4
    80006294:	4509                	li	a0,2
    80006296:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000629a:	6394                	ld	a3,0(a5)
    8000629c:	9736                	add	a4,a4,a3
    8000629e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062a2:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062a6:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800062aa:	6794                	ld	a3,8(a5)
    800062ac:	0026d703          	lhu	a4,2(a3)
    800062b0:	8b1d                	andi	a4,a4,7
    800062b2:	2709                	addiw	a4,a4,2
    800062b4:	0706                	slli	a4,a4,0x1
    800062b6:	9736                	add	a4,a4,a3
    800062b8:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    800062bc:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800062c0:	6798                	ld	a4,8(a5)
    800062c2:	00275783          	lhu	a5,2(a4)
    800062c6:	2785                	addiw	a5,a5,1
    800062c8:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062cc:	100017b7          	lui	a5,0x10001
    800062d0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062d4:	00492703          	lw	a4,4(s2)
    800062d8:	4785                	li	a5,1
    800062da:	02f71163          	bne	a4,a5,800062fc <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    800062de:	0111f997          	auipc	s3,0x111f
    800062e2:	dca98993          	addi	s3,s3,-566 # 811250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800062e6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800062e8:	85ce                	mv	a1,s3
    800062ea:	854a                	mv	a0,s2
    800062ec:	ffffc097          	auipc	ra,0xffffc
    800062f0:	18e080e7          	jalr	398(ra) # 8000247a <sleep>
  while(b->disk == 1) {
    800062f4:	00492783          	lw	a5,4(s2)
    800062f8:	fe9788e3          	beq	a5,s1,800062e8 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    800062fc:	f9042483          	lw	s1,-112(s0)
    80006300:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80006304:	00479713          	slli	a4,a5,0x4
    80006308:	0111d797          	auipc	a5,0x111d
    8000630c:	cf878793          	addi	a5,a5,-776 # 81123000 <disk>
    80006310:	97ba                	add	a5,a5,a4
    80006312:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006316:	0111f917          	auipc	s2,0x111f
    8000631a:	cea90913          	addi	s2,s2,-790 # 81125000 <disk+0x2000>
    free_desc(i);
    8000631e:	8526                	mv	a0,s1
    80006320:	00000097          	auipc	ra,0x0
    80006324:	bf6080e7          	jalr	-1034(ra) # 80005f16 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006328:	0492                	slli	s1,s1,0x4
    8000632a:	00093783          	ld	a5,0(s2)
    8000632e:	94be                	add	s1,s1,a5
    80006330:	00c4d783          	lhu	a5,12(s1)
    80006334:	8b85                	andi	a5,a5,1
    80006336:	cf89                	beqz	a5,80006350 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    80006338:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000633c:	b7cd                	j	8000631e <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000633e:	0111f797          	auipc	a5,0x111f
    80006342:	cc27b783          	ld	a5,-830(a5) # 81125000 <disk+0x2000>
    80006346:	97ba                	add	a5,a5,a4
    80006348:	4689                	li	a3,2
    8000634a:	00d79623          	sh	a3,12(a5)
    8000634e:	b5fd                	j	8000623c <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006350:	0111f517          	auipc	a0,0x111f
    80006354:	d5850513          	addi	a0,a0,-680 # 811250a8 <disk+0x20a8>
    80006358:	ffffb097          	auipc	ra,0xffffb
    8000635c:	be6080e7          	jalr	-1050(ra) # 80000f3e <release>
}
    80006360:	70e6                	ld	ra,120(sp)
    80006362:	7446                	ld	s0,112(sp)
    80006364:	74a6                	ld	s1,104(sp)
    80006366:	7906                	ld	s2,96(sp)
    80006368:	69e6                	ld	s3,88(sp)
    8000636a:	6a46                	ld	s4,80(sp)
    8000636c:	6aa6                	ld	s5,72(sp)
    8000636e:	6b06                	ld	s6,64(sp)
    80006370:	7be2                	ld	s7,56(sp)
    80006372:	7c42                	ld	s8,48(sp)
    80006374:	7ca2                	ld	s9,40(sp)
    80006376:	7d02                	ld	s10,32(sp)
    80006378:	6109                	addi	sp,sp,128
    8000637a:	8082                	ret
  if(write)
    8000637c:	e20d1ee3          	bnez	s10,800061b8 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006380:	f8042023          	sw	zero,-128(s0)
    80006384:	bd2d                	j	800061be <virtio_disk_rw+0xe2>

0000000080006386 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006386:	1101                	addi	sp,sp,-32
    80006388:	ec06                	sd	ra,24(sp)
    8000638a:	e822                	sd	s0,16(sp)
    8000638c:	e426                	sd	s1,8(sp)
    8000638e:	e04a                	sd	s2,0(sp)
    80006390:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006392:	0111f517          	auipc	a0,0x111f
    80006396:	d1650513          	addi	a0,a0,-746 # 811250a8 <disk+0x20a8>
    8000639a:	ffffb097          	auipc	ra,0xffffb
    8000639e:	af0080e7          	jalr	-1296(ra) # 80000e8a <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063a2:	0111f717          	auipc	a4,0x111f
    800063a6:	c5e70713          	addi	a4,a4,-930 # 81125000 <disk+0x2000>
    800063aa:	02075783          	lhu	a5,32(a4)
    800063ae:	6b18                	ld	a4,16(a4)
    800063b0:	00275683          	lhu	a3,2(a4)
    800063b4:	8ebd                	xor	a3,a3,a5
    800063b6:	8a9d                	andi	a3,a3,7
    800063b8:	cab9                	beqz	a3,8000640e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800063ba:	0111d917          	auipc	s2,0x111d
    800063be:	c4690913          	addi	s2,s2,-954 # 81123000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800063c2:	0111f497          	auipc	s1,0x111f
    800063c6:	c3e48493          	addi	s1,s1,-962 # 81125000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800063ca:	078e                	slli	a5,a5,0x3
    800063cc:	97ba                	add	a5,a5,a4
    800063ce:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800063d0:	20078713          	addi	a4,a5,512
    800063d4:	0712                	slli	a4,a4,0x4
    800063d6:	974a                	add	a4,a4,s2
    800063d8:	03074703          	lbu	a4,48(a4)
    800063dc:	ef21                	bnez	a4,80006434 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800063de:	20078793          	addi	a5,a5,512
    800063e2:	0792                	slli	a5,a5,0x4
    800063e4:	97ca                	add	a5,a5,s2
    800063e6:	7798                	ld	a4,40(a5)
    800063e8:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800063ec:	7788                	ld	a0,40(a5)
    800063ee:	ffffc097          	auipc	ra,0xffffc
    800063f2:	212080e7          	jalr	530(ra) # 80002600 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800063f6:	0204d783          	lhu	a5,32(s1)
    800063fa:	2785                	addiw	a5,a5,1
    800063fc:	8b9d                	andi	a5,a5,7
    800063fe:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006402:	6898                	ld	a4,16(s1)
    80006404:	00275683          	lhu	a3,2(a4)
    80006408:	8a9d                	andi	a3,a3,7
    8000640a:	fcf690e3          	bne	a3,a5,800063ca <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000640e:	10001737          	lui	a4,0x10001
    80006412:	533c                	lw	a5,96(a4)
    80006414:	8b8d                	andi	a5,a5,3
    80006416:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006418:	0111f517          	auipc	a0,0x111f
    8000641c:	c9050513          	addi	a0,a0,-880 # 811250a8 <disk+0x20a8>
    80006420:	ffffb097          	auipc	ra,0xffffb
    80006424:	b1e080e7          	jalr	-1250(ra) # 80000f3e <release>
}
    80006428:	60e2                	ld	ra,24(sp)
    8000642a:	6442                	ld	s0,16(sp)
    8000642c:	64a2                	ld	s1,8(sp)
    8000642e:	6902                	ld	s2,0(sp)
    80006430:	6105                	addi	sp,sp,32
    80006432:	8082                	ret
      panic("virtio_disk_intr status");
    80006434:	00002517          	auipc	a0,0x2
    80006438:	3cc50513          	addi	a0,a0,972 # 80008800 <syscalls+0x3d0>
    8000643c:	ffffa097          	auipc	ra,0xffffa
    80006440:	10c080e7          	jalr	268(ra) # 80000548 <panic>
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
