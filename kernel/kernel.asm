
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8f013103          	ld	sp,-1808(sp) # 800088f0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fde70713          	addi	a4,a4,-34 # 80009030 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	02c78793          	addi	a5,a5,44 # 80006090 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd27d7>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	1d478793          	addi	a5,a5,468 # 80001282 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
    80000106:	8a2a                	mv	s4,a0
    80000108:	84ae                	mv	s1,a1
    8000010a:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    8000010c:	00011517          	auipc	a0,0x11
    80000110:	06450513          	addi	a0,a0,100 # 80011170 <cons>
    80000114:	00001097          	auipc	ra,0x1
    80000118:	bdc080e7          	jalr	-1060(ra) # 80000cf0 <acquire>
  for(i = 0; i < n; i++){
    8000011c:	05305b63          	blez	s3,80000172 <consolewrite+0x7e>
    80000120:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000122:	5afd                	li	s5,-1
    80000124:	4685                	li	a3,1
    80000126:	8626                	mv	a2,s1
    80000128:	85d2                	mv	a1,s4
    8000012a:	fbf40513          	addi	a0,s0,-65
    8000012e:	00002097          	auipc	ra,0x2
    80000132:	6d2080e7          	jalr	1746(ra) # 80002800 <either_copyin>
    80000136:	01550c63          	beq	a0,s5,8000014e <consolewrite+0x5a>
      break;
    uartputc(c);
    8000013a:	fbf44503          	lbu	a0,-65(s0)
    8000013e:	00000097          	auipc	ra,0x0
    80000142:	7aa080e7          	jalr	1962(ra) # 800008e8 <uartputc>
  for(i = 0; i < n; i++){
    80000146:	2905                	addiw	s2,s2,1
    80000148:	0485                	addi	s1,s1,1
    8000014a:	fd299de3          	bne	s3,s2,80000124 <consolewrite+0x30>
  }
  release(&cons.lock);
    8000014e:	00011517          	auipc	a0,0x11
    80000152:	02250513          	addi	a0,a0,34 # 80011170 <cons>
    80000156:	00001097          	auipc	ra,0x1
    8000015a:	c6a080e7          	jalr	-918(ra) # 80000dc0 <release>

  return i;
}
    8000015e:	854a                	mv	a0,s2
    80000160:	60a6                	ld	ra,72(sp)
    80000162:	6406                	ld	s0,64(sp)
    80000164:	74e2                	ld	s1,56(sp)
    80000166:	7942                	ld	s2,48(sp)
    80000168:	79a2                	ld	s3,40(sp)
    8000016a:	7a02                	ld	s4,32(sp)
    8000016c:	6ae2                	ld	s5,24(sp)
    8000016e:	6161                	addi	sp,sp,80
    80000170:	8082                	ret
  for(i = 0; i < n; i++){
    80000172:	4901                	li	s2,0
    80000174:	bfe9                	j	8000014e <consolewrite+0x5a>

0000000080000176 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	7119                	addi	sp,sp,-128
    80000178:	fc86                	sd	ra,120(sp)
    8000017a:	f8a2                	sd	s0,112(sp)
    8000017c:	f4a6                	sd	s1,104(sp)
    8000017e:	f0ca                	sd	s2,96(sp)
    80000180:	ecce                	sd	s3,88(sp)
    80000182:	e8d2                	sd	s4,80(sp)
    80000184:	e4d6                	sd	s5,72(sp)
    80000186:	e0da                	sd	s6,64(sp)
    80000188:	fc5e                	sd	s7,56(sp)
    8000018a:	f862                	sd	s8,48(sp)
    8000018c:	f466                	sd	s9,40(sp)
    8000018e:	f06a                	sd	s10,32(sp)
    80000190:	ec6e                	sd	s11,24(sp)
    80000192:	0100                	addi	s0,sp,128
    80000194:	8b2a                	mv	s6,a0
    80000196:	8aae                	mv	s5,a1
    80000198:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000019a:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000019e:	00011517          	auipc	a0,0x11
    800001a2:	fd250513          	addi	a0,a0,-46 # 80011170 <cons>
    800001a6:	00001097          	auipc	ra,0x1
    800001aa:	b4a080e7          	jalr	-1206(ra) # 80000cf0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ae:	00011497          	auipc	s1,0x11
    800001b2:	fc248493          	addi	s1,s1,-62 # 80011170 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b6:	89a6                	mv	s3,s1
    800001b8:	00011917          	auipc	s2,0x11
    800001bc:	05890913          	addi	s2,s2,88 # 80011210 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001c0:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c2:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001c4:	4da9                	li	s11,10
  while(n > 0){
    800001c6:	07405863          	blez	s4,80000236 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001ca:	0a04a783          	lw	a5,160(s1)
    800001ce:	0a44a703          	lw	a4,164(s1)
    800001d2:	02f71463          	bne	a4,a5,800001fa <consoleread+0x84>
      if(myproc()->killed){
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	b62080e7          	jalr	-1182(ra) # 80001d38 <myproc>
    800001de:	5d1c                	lw	a5,56(a0)
    800001e0:	e7b5                	bnez	a5,8000024c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001e2:	85ce                	mv	a1,s3
    800001e4:	854a                	mv	a0,s2
    800001e6:	00002097          	auipc	ra,0x2
    800001ea:	362080e7          	jalr	866(ra) # 80002548 <sleep>
    while(cons.r == cons.w){
    800001ee:	0a04a783          	lw	a5,160(s1)
    800001f2:	0a44a703          	lw	a4,164(s1)
    800001f6:	fef700e3          	beq	a4,a5,800001d6 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001fa:	0017871b          	addiw	a4,a5,1
    800001fe:	0ae4a023          	sw	a4,160(s1)
    80000202:	07f7f713          	andi	a4,a5,127
    80000206:	9726                	add	a4,a4,s1
    80000208:	02074703          	lbu	a4,32(a4)
    8000020c:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000210:	079c0663          	beq	s8,s9,8000027c <consoleread+0x106>
    cbuf = c;
    80000214:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000218:	4685                	li	a3,1
    8000021a:	f8f40613          	addi	a2,s0,-113
    8000021e:	85d6                	mv	a1,s5
    80000220:	855a                	mv	a0,s6
    80000222:	00002097          	auipc	ra,0x2
    80000226:	588080e7          	jalr	1416(ra) # 800027aa <either_copyout>
    8000022a:	01a50663          	beq	a0,s10,80000236 <consoleread+0xc0>
    dst++;
    8000022e:	0a85                	addi	s5,s5,1
    --n;
    80000230:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000232:	f9bc1ae3          	bne	s8,s11,800001c6 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	f3a50513          	addi	a0,a0,-198 # 80011170 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	b82080e7          	jalr	-1150(ra) # 80000dc0 <release>

  return target - n;
    80000246:	414b853b          	subw	a0,s7,s4
    8000024a:	a811                	j	8000025e <consoleread+0xe8>
        release(&cons.lock);
    8000024c:	00011517          	auipc	a0,0x11
    80000250:	f2450513          	addi	a0,a0,-220 # 80011170 <cons>
    80000254:	00001097          	auipc	ra,0x1
    80000258:	b6c080e7          	jalr	-1172(ra) # 80000dc0 <release>
        return -1;
    8000025c:	557d                	li	a0,-1
}
    8000025e:	70e6                	ld	ra,120(sp)
    80000260:	7446                	ld	s0,112(sp)
    80000262:	74a6                	ld	s1,104(sp)
    80000264:	7906                	ld	s2,96(sp)
    80000266:	69e6                	ld	s3,88(sp)
    80000268:	6a46                	ld	s4,80(sp)
    8000026a:	6aa6                	ld	s5,72(sp)
    8000026c:	6b06                	ld	s6,64(sp)
    8000026e:	7be2                	ld	s7,56(sp)
    80000270:	7c42                	ld	s8,48(sp)
    80000272:	7ca2                	ld	s9,40(sp)
    80000274:	7d02                	ld	s10,32(sp)
    80000276:	6de2                	ld	s11,24(sp)
    80000278:	6109                	addi	sp,sp,128
    8000027a:	8082                	ret
      if(n < target){
    8000027c:	000a071b          	sext.w	a4,s4
    80000280:	fb777be3          	bgeu	a4,s7,80000236 <consoleread+0xc0>
        cons.r--;
    80000284:	00011717          	auipc	a4,0x11
    80000288:	f8f72623          	sw	a5,-116(a4) # 80011210 <cons+0xa0>
    8000028c:	b76d                	j	80000236 <consoleread+0xc0>

000000008000028e <consputc>:
{
    8000028e:	1141                	addi	sp,sp,-16
    80000290:	e406                	sd	ra,8(sp)
    80000292:	e022                	sd	s0,0(sp)
    80000294:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000296:	10000793          	li	a5,256
    8000029a:	00f50a63          	beq	a0,a5,800002ae <consputc+0x20>
    uartputc_sync(c);
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	564080e7          	jalr	1380(ra) # 80000802 <uartputc_sync>
}
    800002a6:	60a2                	ld	ra,8(sp)
    800002a8:	6402                	ld	s0,0(sp)
    800002aa:	0141                	addi	sp,sp,16
    800002ac:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	552080e7          	jalr	1362(ra) # 80000802 <uartputc_sync>
    800002b8:	02000513          	li	a0,32
    800002bc:	00000097          	auipc	ra,0x0
    800002c0:	546080e7          	jalr	1350(ra) # 80000802 <uartputc_sync>
    800002c4:	4521                	li	a0,8
    800002c6:	00000097          	auipc	ra,0x0
    800002ca:	53c080e7          	jalr	1340(ra) # 80000802 <uartputc_sync>
    800002ce:	bfe1                	j	800002a6 <consputc+0x18>

00000000800002d0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d0:	1101                	addi	sp,sp,-32
    800002d2:	ec06                	sd	ra,24(sp)
    800002d4:	e822                	sd	s0,16(sp)
    800002d6:	e426                	sd	s1,8(sp)
    800002d8:	e04a                	sd	s2,0(sp)
    800002da:	1000                	addi	s0,sp,32
    800002dc:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002de:	00011517          	auipc	a0,0x11
    800002e2:	e9250513          	addi	a0,a0,-366 # 80011170 <cons>
    800002e6:	00001097          	auipc	ra,0x1
    800002ea:	a0a080e7          	jalr	-1526(ra) # 80000cf0 <acquire>

  switch(c){
    800002ee:	47d5                	li	a5,21
    800002f0:	0af48663          	beq	s1,a5,8000039c <consoleintr+0xcc>
    800002f4:	0297ca63          	blt	a5,s1,80000328 <consoleintr+0x58>
    800002f8:	47a1                	li	a5,8
    800002fa:	0ef48763          	beq	s1,a5,800003e8 <consoleintr+0x118>
    800002fe:	47c1                	li	a5,16
    80000300:	10f49a63          	bne	s1,a5,80000414 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000304:	00002097          	auipc	ra,0x2
    80000308:	552080e7          	jalr	1362(ra) # 80002856 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030c:	00011517          	auipc	a0,0x11
    80000310:	e6450513          	addi	a0,a0,-412 # 80011170 <cons>
    80000314:	00001097          	auipc	ra,0x1
    80000318:	aac080e7          	jalr	-1364(ra) # 80000dc0 <release>
}
    8000031c:	60e2                	ld	ra,24(sp)
    8000031e:	6442                	ld	s0,16(sp)
    80000320:	64a2                	ld	s1,8(sp)
    80000322:	6902                	ld	s2,0(sp)
    80000324:	6105                	addi	sp,sp,32
    80000326:	8082                	ret
  switch(c){
    80000328:	07f00793          	li	a5,127
    8000032c:	0af48e63          	beq	s1,a5,800003e8 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000330:	00011717          	auipc	a4,0x11
    80000334:	e4070713          	addi	a4,a4,-448 # 80011170 <cons>
    80000338:	0a872783          	lw	a5,168(a4)
    8000033c:	0a072703          	lw	a4,160(a4)
    80000340:	9f99                	subw	a5,a5,a4
    80000342:	07f00713          	li	a4,127
    80000346:	fcf763e3          	bltu	a4,a5,8000030c <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000034a:	47b5                	li	a5,13
    8000034c:	0cf48763          	beq	s1,a5,8000041a <consoleintr+0x14a>
      consputc(c);
    80000350:	8526                	mv	a0,s1
    80000352:	00000097          	auipc	ra,0x0
    80000356:	f3c080e7          	jalr	-196(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000035a:	00011797          	auipc	a5,0x11
    8000035e:	e1678793          	addi	a5,a5,-490 # 80011170 <cons>
    80000362:	0a87a703          	lw	a4,168(a5)
    80000366:	0017069b          	addiw	a3,a4,1
    8000036a:	0006861b          	sext.w	a2,a3
    8000036e:	0ad7a423          	sw	a3,168(a5)
    80000372:	07f77713          	andi	a4,a4,127
    80000376:	97ba                	add	a5,a5,a4
    80000378:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000037c:	47a9                	li	a5,10
    8000037e:	0cf48563          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000382:	4791                	li	a5,4
    80000384:	0cf48263          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000388:	00011797          	auipc	a5,0x11
    8000038c:	e887a783          	lw	a5,-376(a5) # 80011210 <cons+0xa0>
    80000390:	0807879b          	addiw	a5,a5,128
    80000394:	f6f61ce3          	bne	a2,a5,8000030c <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000398:	863e                	mv	a2,a5
    8000039a:	a07d                	j	80000448 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000039c:	00011717          	auipc	a4,0x11
    800003a0:	dd470713          	addi	a4,a4,-556 # 80011170 <cons>
    800003a4:	0a872783          	lw	a5,168(a4)
    800003a8:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ac:	00011497          	auipc	s1,0x11
    800003b0:	dc448493          	addi	s1,s1,-572 # 80011170 <cons>
    while(cons.e != cons.w &&
    800003b4:	4929                	li	s2,10
    800003b6:	f4f70be3          	beq	a4,a5,8000030c <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ba:	37fd                	addiw	a5,a5,-1
    800003bc:	07f7f713          	andi	a4,a5,127
    800003c0:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c2:	02074703          	lbu	a4,32(a4)
    800003c6:	f52703e3          	beq	a4,s2,8000030c <consoleintr+0x3c>
      cons.e--;
    800003ca:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003ce:	10000513          	li	a0,256
    800003d2:	00000097          	auipc	ra,0x0
    800003d6:	ebc080e7          	jalr	-324(ra) # 8000028e <consputc>
    while(cons.e != cons.w &&
    800003da:	0a84a783          	lw	a5,168(s1)
    800003de:	0a44a703          	lw	a4,164(s1)
    800003e2:	fcf71ce3          	bne	a4,a5,800003ba <consoleintr+0xea>
    800003e6:	b71d                	j	8000030c <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	d8870713          	addi	a4,a4,-632 # 80011170 <cons>
    800003f0:	0a872783          	lw	a5,168(a4)
    800003f4:	0a472703          	lw	a4,164(a4)
    800003f8:	f0f70ae3          	beq	a4,a5,8000030c <consoleintr+0x3c>
      cons.e--;
    800003fc:	37fd                	addiw	a5,a5,-1
    800003fe:	00011717          	auipc	a4,0x11
    80000402:	e0f72d23          	sw	a5,-486(a4) # 80011218 <cons+0xa8>
      consputc(BACKSPACE);
    80000406:	10000513          	li	a0,256
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e84080e7          	jalr	-380(ra) # 8000028e <consputc>
    80000412:	bded                	j	8000030c <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000414:	ee048ce3          	beqz	s1,8000030c <consoleintr+0x3c>
    80000418:	bf21                	j	80000330 <consoleintr+0x60>
      consputc(c);
    8000041a:	4529                	li	a0,10
    8000041c:	00000097          	auipc	ra,0x0
    80000420:	e72080e7          	jalr	-398(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000424:	00011797          	auipc	a5,0x11
    80000428:	d4c78793          	addi	a5,a5,-692 # 80011170 <cons>
    8000042c:	0a87a703          	lw	a4,168(a5)
    80000430:	0017069b          	addiw	a3,a4,1
    80000434:	0006861b          	sext.w	a2,a3
    80000438:	0ad7a423          	sw	a3,168(a5)
    8000043c:	07f77713          	andi	a4,a4,127
    80000440:	97ba                	add	a5,a5,a4
    80000442:	4729                	li	a4,10
    80000444:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000448:	00011797          	auipc	a5,0x11
    8000044c:	dcc7a623          	sw	a2,-564(a5) # 80011214 <cons+0xa4>
        wakeup(&cons.r);
    80000450:	00011517          	auipc	a0,0x11
    80000454:	dc050513          	addi	a0,a0,-576 # 80011210 <cons+0xa0>
    80000458:	00002097          	auipc	ra,0x2
    8000045c:	276080e7          	jalr	630(ra) # 800026ce <wakeup>
    80000460:	b575                	j	8000030c <consoleintr+0x3c>

0000000080000462 <consoleinit>:

void
consoleinit(void)
{
    80000462:	1141                	addi	sp,sp,-16
    80000464:	e406                	sd	ra,8(sp)
    80000466:	e022                	sd	s0,0(sp)
    80000468:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000046a:	00008597          	auipc	a1,0x8
    8000046e:	ba658593          	addi	a1,a1,-1114 # 80008010 <etext+0x10>
    80000472:	00011517          	auipc	a0,0x11
    80000476:	cfe50513          	addi	a0,a0,-770 # 80011170 <cons>
    8000047a:	00001097          	auipc	ra,0x1
    8000047e:	9f2080e7          	jalr	-1550(ra) # 80000e6c <initlock>

  uartinit();
    80000482:	00000097          	auipc	ra,0x0
    80000486:	330080e7          	jalr	816(ra) # 800007b2 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048a:	00026797          	auipc	a5,0x26
    8000048e:	b8e78793          	addi	a5,a5,-1138 # 80026018 <devsw>
    80000492:	00000717          	auipc	a4,0x0
    80000496:	ce470713          	addi	a4,a4,-796 # 80000176 <consoleread>
    8000049a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000049c:	00000717          	auipc	a4,0x0
    800004a0:	c5870713          	addi	a4,a4,-936 # 800000f4 <consolewrite>
    800004a4:	ef98                	sd	a4,24(a5)
}
    800004a6:	60a2                	ld	ra,8(sp)
    800004a8:	6402                	ld	s0,0(sp)
    800004aa:	0141                	addi	sp,sp,16
    800004ac:	8082                	ret

00000000800004ae <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ae:	7179                	addi	sp,sp,-48
    800004b0:	f406                	sd	ra,40(sp)
    800004b2:	f022                	sd	s0,32(sp)
    800004b4:	ec26                	sd	s1,24(sp)
    800004b6:	e84a                	sd	s2,16(sp)
    800004b8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ba:	c219                	beqz	a2,800004c0 <printint+0x12>
    800004bc:	08054663          	bltz	a0,80000548 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004c0:	2501                	sext.w	a0,a0
    800004c2:	4881                	li	a7,0
    800004c4:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004ca:	2581                	sext.w	a1,a1
    800004cc:	00008617          	auipc	a2,0x8
    800004d0:	b7460613          	addi	a2,a2,-1164 # 80008040 <digits>
    800004d4:	883a                	mv	a6,a4
    800004d6:	2705                	addiw	a4,a4,1
    800004d8:	02b577bb          	remuw	a5,a0,a1
    800004dc:	1782                	slli	a5,a5,0x20
    800004de:	9381                	srli	a5,a5,0x20
    800004e0:	97b2                	add	a5,a5,a2
    800004e2:	0007c783          	lbu	a5,0(a5)
    800004e6:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ea:	0005079b          	sext.w	a5,a0
    800004ee:	02b5553b          	divuw	a0,a0,a1
    800004f2:	0685                	addi	a3,a3,1
    800004f4:	feb7f0e3          	bgeu	a5,a1,800004d4 <printint+0x26>

  if(sign)
    800004f8:	00088b63          	beqz	a7,8000050e <printint+0x60>
    buf[i++] = '-';
    800004fc:	fe040793          	addi	a5,s0,-32
    80000500:	973e                	add	a4,a4,a5
    80000502:	02d00793          	li	a5,45
    80000506:	fef70823          	sb	a5,-16(a4)
    8000050a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000050e:	02e05763          	blez	a4,8000053c <printint+0x8e>
    80000512:	fd040793          	addi	a5,s0,-48
    80000516:	00e784b3          	add	s1,a5,a4
    8000051a:	fff78913          	addi	s2,a5,-1
    8000051e:	993a                	add	s2,s2,a4
    80000520:	377d                	addiw	a4,a4,-1
    80000522:	1702                	slli	a4,a4,0x20
    80000524:	9301                	srli	a4,a4,0x20
    80000526:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000052a:	fff4c503          	lbu	a0,-1(s1)
    8000052e:	00000097          	auipc	ra,0x0
    80000532:	d60080e7          	jalr	-672(ra) # 8000028e <consputc>
  while(--i >= 0)
    80000536:	14fd                	addi	s1,s1,-1
    80000538:	ff2499e3          	bne	s1,s2,8000052a <printint+0x7c>
}
    8000053c:	70a2                	ld	ra,40(sp)
    8000053e:	7402                	ld	s0,32(sp)
    80000540:	64e2                	ld	s1,24(sp)
    80000542:	6942                	ld	s2,16(sp)
    80000544:	6145                	addi	sp,sp,48
    80000546:	8082                	ret
    x = -xx;
    80000548:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000054c:	4885                	li	a7,1
    x = -xx;
    8000054e:	bf9d                	j	800004c4 <printint+0x16>

0000000080000550 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000550:	1101                	addi	sp,sp,-32
    80000552:	ec06                	sd	ra,24(sp)
    80000554:	e822                	sd	s0,16(sp)
    80000556:	e426                	sd	s1,8(sp)
    80000558:	1000                	addi	s0,sp,32
    8000055a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000055c:	00011797          	auipc	a5,0x11
    80000560:	ce07a223          	sw	zero,-796(a5) # 80011240 <pr+0x20>
  printf("panic: ");
    80000564:	00008517          	auipc	a0,0x8
    80000568:	ab450513          	addi	a0,a0,-1356 # 80008018 <etext+0x18>
    8000056c:	00000097          	auipc	ra,0x0
    80000570:	02e080e7          	jalr	46(ra) # 8000059a <printf>
  printf(s);
    80000574:	8526                	mv	a0,s1
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	024080e7          	jalr	36(ra) # 8000059a <printf>
  printf("\n");
    8000057e:	00008517          	auipc	a0,0x8
    80000582:	be250513          	addi	a0,a0,-1054 # 80008160 <digits+0x120>
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	014080e7          	jalr	20(ra) # 8000059a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000058e:	4785                	li	a5,1
    80000590:	00009717          	auipc	a4,0x9
    80000594:	a6f72823          	sw	a5,-1424(a4) # 80009000 <panicked>
  for(;;)
    80000598:	a001                	j	80000598 <panic+0x48>

000000008000059a <printf>:
{
    8000059a:	7131                	addi	sp,sp,-192
    8000059c:	fc86                	sd	ra,120(sp)
    8000059e:	f8a2                	sd	s0,112(sp)
    800005a0:	f4a6                	sd	s1,104(sp)
    800005a2:	f0ca                	sd	s2,96(sp)
    800005a4:	ecce                	sd	s3,88(sp)
    800005a6:	e8d2                	sd	s4,80(sp)
    800005a8:	e4d6                	sd	s5,72(sp)
    800005aa:	e0da                	sd	s6,64(sp)
    800005ac:	fc5e                	sd	s7,56(sp)
    800005ae:	f862                	sd	s8,48(sp)
    800005b0:	f466                	sd	s9,40(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	ec6e                	sd	s11,24(sp)
    800005b6:	0100                	addi	s0,sp,128
    800005b8:	8a2a                	mv	s4,a0
    800005ba:	e40c                	sd	a1,8(s0)
    800005bc:	e810                	sd	a2,16(s0)
    800005be:	ec14                	sd	a3,24(s0)
    800005c0:	f018                	sd	a4,32(s0)
    800005c2:	f41c                	sd	a5,40(s0)
    800005c4:	03043823          	sd	a6,48(s0)
    800005c8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005cc:	00011d97          	auipc	s11,0x11
    800005d0:	c74dad83          	lw	s11,-908(s11) # 80011240 <pr+0x20>
  if(locking)
    800005d4:	020d9b63          	bnez	s11,8000060a <printf+0x70>
  if (fmt == 0)
    800005d8:	040a0263          	beqz	s4,8000061c <printf+0x82>
  va_start(ap, fmt);
    800005dc:	00840793          	addi	a5,s0,8
    800005e0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e4:	000a4503          	lbu	a0,0(s4)
    800005e8:	16050263          	beqz	a0,8000074c <printf+0x1b2>
    800005ec:	4481                	li	s1,0
    if(c != '%'){
    800005ee:	02500a93          	li	s5,37
    switch(c){
    800005f2:	07000b13          	li	s6,112
  consputc('x');
    800005f6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f8:	00008b97          	auipc	s7,0x8
    800005fc:	a48b8b93          	addi	s7,s7,-1464 # 80008040 <digits>
    switch(c){
    80000600:	07300c93          	li	s9,115
    80000604:	06400c13          	li	s8,100
    80000608:	a82d                	j	80000642 <printf+0xa8>
    acquire(&pr.lock);
    8000060a:	00011517          	auipc	a0,0x11
    8000060e:	c1650513          	addi	a0,a0,-1002 # 80011220 <pr>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	6de080e7          	jalr	1758(ra) # 80000cf0 <acquire>
    8000061a:	bf7d                	j	800005d8 <printf+0x3e>
    panic("null fmt");
    8000061c:	00008517          	auipc	a0,0x8
    80000620:	a0c50513          	addi	a0,a0,-1524 # 80008028 <etext+0x28>
    80000624:	00000097          	auipc	ra,0x0
    80000628:	f2c080e7          	jalr	-212(ra) # 80000550 <panic>
      consputc(c);
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	c62080e7          	jalr	-926(ra) # 8000028e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c503          	lbu	a0,0(a5)
    8000063e:	10050763          	beqz	a0,8000074c <printf+0x1b2>
    if(c != '%'){
    80000642:	ff5515e3          	bne	a0,s5,8000062c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000646:	2485                	addiw	s1,s1,1
    80000648:	009a07b3          	add	a5,s4,s1
    8000064c:	0007c783          	lbu	a5,0(a5)
    80000650:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000654:	cfe5                	beqz	a5,8000074c <printf+0x1b2>
    switch(c){
    80000656:	05678a63          	beq	a5,s6,800006aa <printf+0x110>
    8000065a:	02fb7663          	bgeu	s6,a5,80000686 <printf+0xec>
    8000065e:	09978963          	beq	a5,s9,800006f0 <printf+0x156>
    80000662:	07800713          	li	a4,120
    80000666:	0ce79863          	bne	a5,a4,80000736 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4605                	li	a2,1
    80000678:	85ea                	mv	a1,s10
    8000067a:	4388                	lw	a0,0(a5)
    8000067c:	00000097          	auipc	ra,0x0
    80000680:	e32080e7          	jalr	-462(ra) # 800004ae <printint>
      break;
    80000684:	bf45                	j	80000634 <printf+0x9a>
    switch(c){
    80000686:	0b578263          	beq	a5,s5,8000072a <printf+0x190>
    8000068a:	0b879663          	bne	a5,s8,80000736 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	45a9                	li	a1,10
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e0e080e7          	jalr	-498(ra) # 800004ae <printint>
      break;
    800006a8:	b771                	j	80000634 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006aa:	f8843783          	ld	a5,-120(s0)
    800006ae:	00878713          	addi	a4,a5,8
    800006b2:	f8e43423          	sd	a4,-120(s0)
    800006b6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ba:	03000513          	li	a0,48
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bd0080e7          	jalr	-1072(ra) # 8000028e <consputc>
  consputc('x');
    800006c6:	07800513          	li	a0,120
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bc4080e7          	jalr	-1084(ra) # 8000028e <consputc>
    800006d2:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d4:	03c9d793          	srli	a5,s3,0x3c
    800006d8:	97de                	add	a5,a5,s7
    800006da:	0007c503          	lbu	a0,0(a5)
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	bb0080e7          	jalr	-1104(ra) # 8000028e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e6:	0992                	slli	s3,s3,0x4
    800006e8:	397d                	addiw	s2,s2,-1
    800006ea:	fe0915e3          	bnez	s2,800006d4 <printf+0x13a>
    800006ee:	b799                	j	80000634 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006f0:	f8843783          	ld	a5,-120(s0)
    800006f4:	00878713          	addi	a4,a5,8
    800006f8:	f8e43423          	sd	a4,-120(s0)
    800006fc:	0007b903          	ld	s2,0(a5)
    80000700:	00090e63          	beqz	s2,8000071c <printf+0x182>
      for(; *s; s++)
    80000704:	00094503          	lbu	a0,0(s2)
    80000708:	d515                	beqz	a0,80000634 <printf+0x9a>
        consputc(*s);
    8000070a:	00000097          	auipc	ra,0x0
    8000070e:	b84080e7          	jalr	-1148(ra) # 8000028e <consputc>
      for(; *s; s++)
    80000712:	0905                	addi	s2,s2,1
    80000714:	00094503          	lbu	a0,0(s2)
    80000718:	f96d                	bnez	a0,8000070a <printf+0x170>
    8000071a:	bf29                	j	80000634 <printf+0x9a>
        s = "(null)";
    8000071c:	00008917          	auipc	s2,0x8
    80000720:	90490913          	addi	s2,s2,-1788 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000724:	02800513          	li	a0,40
    80000728:	b7cd                	j	8000070a <printf+0x170>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b62080e7          	jalr	-1182(ra) # 8000028e <consputc>
      break;
    80000734:	b701                	j	80000634 <printf+0x9a>
      consputc('%');
    80000736:	8556                	mv	a0,s5
    80000738:	00000097          	auipc	ra,0x0
    8000073c:	b56080e7          	jalr	-1194(ra) # 8000028e <consputc>
      consputc(c);
    80000740:	854a                	mv	a0,s2
    80000742:	00000097          	auipc	ra,0x0
    80000746:	b4c080e7          	jalr	-1204(ra) # 8000028e <consputc>
      break;
    8000074a:	b5ed                	j	80000634 <printf+0x9a>
  if(locking)
    8000074c:	020d9163          	bnez	s11,8000076e <printf+0x1d4>
}
    80000750:	70e6                	ld	ra,120(sp)
    80000752:	7446                	ld	s0,112(sp)
    80000754:	74a6                	ld	s1,104(sp)
    80000756:	7906                	ld	s2,96(sp)
    80000758:	69e6                	ld	s3,88(sp)
    8000075a:	6a46                	ld	s4,80(sp)
    8000075c:	6aa6                	ld	s5,72(sp)
    8000075e:	6b06                	ld	s6,64(sp)
    80000760:	7be2                	ld	s7,56(sp)
    80000762:	7c42                	ld	s8,48(sp)
    80000764:	7ca2                	ld	s9,40(sp)
    80000766:	7d02                	ld	s10,32(sp)
    80000768:	6de2                	ld	s11,24(sp)
    8000076a:	6129                	addi	sp,sp,192
    8000076c:	8082                	ret
    release(&pr.lock);
    8000076e:	00011517          	auipc	a0,0x11
    80000772:	ab250513          	addi	a0,a0,-1358 # 80011220 <pr>
    80000776:	00000097          	auipc	ra,0x0
    8000077a:	64a080e7          	jalr	1610(ra) # 80000dc0 <release>
}
    8000077e:	bfc9                	j	80000750 <printf+0x1b6>

0000000080000780 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000780:	1101                	addi	sp,sp,-32
    80000782:	ec06                	sd	ra,24(sp)
    80000784:	e822                	sd	s0,16(sp)
    80000786:	e426                	sd	s1,8(sp)
    80000788:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000078a:	00011497          	auipc	s1,0x11
    8000078e:	a9648493          	addi	s1,s1,-1386 # 80011220 <pr>
    80000792:	00008597          	auipc	a1,0x8
    80000796:	8a658593          	addi	a1,a1,-1882 # 80008038 <etext+0x38>
    8000079a:	8526                	mv	a0,s1
    8000079c:	00000097          	auipc	ra,0x0
    800007a0:	6d0080e7          	jalr	1744(ra) # 80000e6c <initlock>
  pr.locking = 1;
    800007a4:	4785                	li	a5,1
    800007a6:	d09c                	sw	a5,32(s1)
}
    800007a8:	60e2                	ld	ra,24(sp)
    800007aa:	6442                	ld	s0,16(sp)
    800007ac:	64a2                	ld	s1,8(sp)
    800007ae:	6105                	addi	sp,sp,32
    800007b0:	8082                	ret

00000000800007b2 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007b2:	1141                	addi	sp,sp,-16
    800007b4:	e406                	sd	ra,8(sp)
    800007b6:	e022                	sd	s0,0(sp)
    800007b8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ba:	100007b7          	lui	a5,0x10000
    800007be:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007c2:	f8000713          	li	a4,-128
    800007c6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ca:	470d                	li	a4,3
    800007cc:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007d0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007d4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d8:	469d                	li	a3,7
    800007da:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007de:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007e2:	00008597          	auipc	a1,0x8
    800007e6:	87658593          	addi	a1,a1,-1930 # 80008058 <digits+0x18>
    800007ea:	00011517          	auipc	a0,0x11
    800007ee:	a5e50513          	addi	a0,a0,-1442 # 80011248 <uart_tx_lock>
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	67a080e7          	jalr	1658(ra) # 80000e6c <initlock>
}
    800007fa:	60a2                	ld	ra,8(sp)
    800007fc:	6402                	ld	s0,0(sp)
    800007fe:	0141                	addi	sp,sp,16
    80000800:	8082                	ret

0000000080000802 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000802:	1101                	addi	sp,sp,-32
    80000804:	ec06                	sd	ra,24(sp)
    80000806:	e822                	sd	s0,16(sp)
    80000808:	e426                	sd	s1,8(sp)
    8000080a:	1000                	addi	s0,sp,32
    8000080c:	84aa                	mv	s1,a0
  push_off();
    8000080e:	00000097          	auipc	ra,0x0
    80000812:	496080e7          	jalr	1174(ra) # 80000ca4 <push_off>

  if(panicked){
    80000816:	00008797          	auipc	a5,0x8
    8000081a:	7ea7a783          	lw	a5,2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	10000737          	lui	a4,0x10000
  if(panicked){
    80000822:	c391                	beqz	a5,80000826 <uartputc_sync+0x24>
    for(;;)
    80000824:	a001                	j	80000824 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000826:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000082a:	0ff7f793          	andi	a5,a5,255
    8000082e:	0207f793          	andi	a5,a5,32
    80000832:	dbf5                	beqz	a5,80000826 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000834:	0ff4f793          	andi	a5,s1,255
    80000838:	10000737          	lui	a4,0x10000
    8000083c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000840:	00000097          	auipc	ra,0x0
    80000844:	520080e7          	jalr	1312(ra) # 80000d60 <pop_off>
}
    80000848:	60e2                	ld	ra,24(sp)
    8000084a:	6442                	ld	s0,16(sp)
    8000084c:	64a2                	ld	s1,8(sp)
    8000084e:	6105                	addi	sp,sp,32
    80000850:	8082                	ret

0000000080000852 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000852:	00008797          	auipc	a5,0x8
    80000856:	7b27a783          	lw	a5,1970(a5) # 80009004 <uart_tx_r>
    8000085a:	00008717          	auipc	a4,0x8
    8000085e:	7ae72703          	lw	a4,1966(a4) # 80009008 <uart_tx_w>
    80000862:	08f70263          	beq	a4,a5,800008e6 <uartstart+0x94>
{
    80000866:	7139                	addi	sp,sp,-64
    80000868:	fc06                	sd	ra,56(sp)
    8000086a:	f822                	sd	s0,48(sp)
    8000086c:	f426                	sd	s1,40(sp)
    8000086e:	f04a                	sd	s2,32(sp)
    80000870:	ec4e                	sd	s3,24(sp)
    80000872:	e852                	sd	s4,16(sp)
    80000874:	e456                	sd	s5,8(sp)
    80000876:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    8000087c:	00011a17          	auipc	s4,0x11
    80000880:	9cca0a13          	addi	s4,s4,-1588 # 80011248 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000884:	00008497          	auipc	s1,0x8
    80000888:	78048493          	addi	s1,s1,1920 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000088c:	00008997          	auipc	s3,0x8
    80000890:	77c98993          	addi	s3,s3,1916 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000894:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000898:	0ff77713          	andi	a4,a4,255
    8000089c:	02077713          	andi	a4,a4,32
    800008a0:	cb15                	beqz	a4,800008d4 <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    800008a2:	00fa0733          	add	a4,s4,a5
    800008a6:	02074a83          	lbu	s5,32(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008aa:	2785                	addiw	a5,a5,1
    800008ac:	41f7d71b          	sraiw	a4,a5,0x1f
    800008b0:	01b7571b          	srliw	a4,a4,0x1b
    800008b4:	9fb9                	addw	a5,a5,a4
    800008b6:	8bfd                	andi	a5,a5,31
    800008b8:	9f99                	subw	a5,a5,a4
    800008ba:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008bc:	8526                	mv	a0,s1
    800008be:	00002097          	auipc	ra,0x2
    800008c2:	e10080e7          	jalr	-496(ra) # 800026ce <wakeup>
    
    WriteReg(THR, c);
    800008c6:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ca:	409c                	lw	a5,0(s1)
    800008cc:	0009a703          	lw	a4,0(s3)
    800008d0:	fcf712e3          	bne	a4,a5,80000894 <uartstart+0x42>
  }
}
    800008d4:	70e2                	ld	ra,56(sp)
    800008d6:	7442                	ld	s0,48(sp)
    800008d8:	74a2                	ld	s1,40(sp)
    800008da:	7902                	ld	s2,32(sp)
    800008dc:	69e2                	ld	s3,24(sp)
    800008de:	6a42                	ld	s4,16(sp)
    800008e0:	6aa2                	ld	s5,8(sp)
    800008e2:	6121                	addi	sp,sp,64
    800008e4:	8082                	ret
    800008e6:	8082                	ret

00000000800008e8 <uartputc>:
{
    800008e8:	7179                	addi	sp,sp,-48
    800008ea:	f406                	sd	ra,40(sp)
    800008ec:	f022                	sd	s0,32(sp)
    800008ee:	ec26                	sd	s1,24(sp)
    800008f0:	e84a                	sd	s2,16(sp)
    800008f2:	e44e                	sd	s3,8(sp)
    800008f4:	e052                	sd	s4,0(sp)
    800008f6:	1800                	addi	s0,sp,48
    800008f8:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008fa:	00011517          	auipc	a0,0x11
    800008fe:	94e50513          	addi	a0,a0,-1714 # 80011248 <uart_tx_lock>
    80000902:	00000097          	auipc	ra,0x0
    80000906:	3ee080e7          	jalr	1006(ra) # 80000cf0 <acquire>
  if(panicked){
    8000090a:	00008797          	auipc	a5,0x8
    8000090e:	6f67a783          	lw	a5,1782(a5) # 80009000 <panicked>
    80000912:	c391                	beqz	a5,80000916 <uartputc+0x2e>
    for(;;)
    80000914:	a001                	j	80000914 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000916:	00008717          	auipc	a4,0x8
    8000091a:	6f272703          	lw	a4,1778(a4) # 80009008 <uart_tx_w>
    8000091e:	0017079b          	addiw	a5,a4,1
    80000922:	41f7d69b          	sraiw	a3,a5,0x1f
    80000926:	01b6d69b          	srliw	a3,a3,0x1b
    8000092a:	9fb5                	addw	a5,a5,a3
    8000092c:	8bfd                	andi	a5,a5,31
    8000092e:	9f95                	subw	a5,a5,a3
    80000930:	00008697          	auipc	a3,0x8
    80000934:	6d46a683          	lw	a3,1748(a3) # 80009004 <uart_tx_r>
    80000938:	04f69263          	bne	a3,a5,8000097c <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000093c:	00011a17          	auipc	s4,0x11
    80000940:	90ca0a13          	addi	s4,s4,-1780 # 80011248 <uart_tx_lock>
    80000944:	00008497          	auipc	s1,0x8
    80000948:	6c048493          	addi	s1,s1,1728 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000094c:	00008917          	auipc	s2,0x8
    80000950:	6bc90913          	addi	s2,s2,1724 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000954:	85d2                	mv	a1,s4
    80000956:	8526                	mv	a0,s1
    80000958:	00002097          	auipc	ra,0x2
    8000095c:	bf0080e7          	jalr	-1040(ra) # 80002548 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000960:	00092703          	lw	a4,0(s2)
    80000964:	0017079b          	addiw	a5,a4,1
    80000968:	41f7d69b          	sraiw	a3,a5,0x1f
    8000096c:	01b6d69b          	srliw	a3,a3,0x1b
    80000970:	9fb5                	addw	a5,a5,a3
    80000972:	8bfd                	andi	a5,a5,31
    80000974:	9f95                	subw	a5,a5,a3
    80000976:	4094                	lw	a3,0(s1)
    80000978:	fcf68ee3          	beq	a3,a5,80000954 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    8000097c:	00011497          	auipc	s1,0x11
    80000980:	8cc48493          	addi	s1,s1,-1844 # 80011248 <uart_tx_lock>
    80000984:	9726                	add	a4,a4,s1
    80000986:	03370023          	sb	s3,32(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    8000098a:	00008717          	auipc	a4,0x8
    8000098e:	66f72f23          	sw	a5,1662(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000992:	00000097          	auipc	ra,0x0
    80000996:	ec0080e7          	jalr	-320(ra) # 80000852 <uartstart>
      release(&uart_tx_lock);
    8000099a:	8526                	mv	a0,s1
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	424080e7          	jalr	1060(ra) # 80000dc0 <release>
}
    800009a4:	70a2                	ld	ra,40(sp)
    800009a6:	7402                	ld	s0,32(sp)
    800009a8:	64e2                	ld	s1,24(sp)
    800009aa:	6942                	ld	s2,16(sp)
    800009ac:	69a2                	ld	s3,8(sp)
    800009ae:	6a02                	ld	s4,0(sp)
    800009b0:	6145                	addi	sp,sp,48
    800009b2:	8082                	ret

00000000800009b4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009b4:	1141                	addi	sp,sp,-16
    800009b6:	e422                	sd	s0,8(sp)
    800009b8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009c2:	8b85                	andi	a5,a5,1
    800009c4:	cb91                	beqz	a5,800009d8 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009c6:	100007b7          	lui	a5,0x10000
    800009ca:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009ce:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009d2:	6422                	ld	s0,8(sp)
    800009d4:	0141                	addi	sp,sp,16
    800009d6:	8082                	ret
    return -1;
    800009d8:	557d                	li	a0,-1
    800009da:	bfe5                	j	800009d2 <uartgetc+0x1e>

00000000800009dc <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009dc:	1101                	addi	sp,sp,-32
    800009de:	ec06                	sd	ra,24(sp)
    800009e0:	e822                	sd	s0,16(sp)
    800009e2:	e426                	sd	s1,8(sp)
    800009e4:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009e6:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	fcc080e7          	jalr	-52(ra) # 800009b4 <uartgetc>
    if(c == -1)
    800009f0:	00950763          	beq	a0,s1,800009fe <uartintr+0x22>
      break;
    consoleintr(c);
    800009f4:	00000097          	auipc	ra,0x0
    800009f8:	8dc080e7          	jalr	-1828(ra) # 800002d0 <consoleintr>
  while(1){
    800009fc:	b7f5                	j	800009e8 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009fe:	00011497          	auipc	s1,0x11
    80000a02:	84a48493          	addi	s1,s1,-1974 # 80011248 <uart_tx_lock>
    80000a06:	8526                	mv	a0,s1
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	2e8080e7          	jalr	744(ra) # 80000cf0 <acquire>
  uartstart();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	e42080e7          	jalr	-446(ra) # 80000852 <uartstart>
  release(&uart_tx_lock);
    80000a18:	8526                	mv	a0,s1
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	3a6080e7          	jalr	934(ra) # 80000dc0 <release>
}
    80000a22:	60e2                	ld	ra,24(sp)
    80000a24:	6442                	ld	s0,16(sp)
    80000a26:	64a2                	ld	s1,8(sp)
    80000a28:	6105                	addi	sp,sp,32
    80000a2a:	8082                	ret

0000000080000a2c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a2c:	7139                	addi	sp,sp,-64
    80000a2e:	fc06                	sd	ra,56(sp)
    80000a30:	f822                	sd	s0,48(sp)
    80000a32:	f426                	sd	s1,40(sp)
    80000a34:	f04a                	sd	s2,32(sp)
    80000a36:	ec4e                	sd	s3,24(sp)
    80000a38:	e852                	sd	s4,16(sp)
    80000a3a:	e456                	sd	s5,8(sp)
    80000a3c:	0080                	addi	s0,sp,64
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a3e:	03451793          	slli	a5,a0,0x34
    80000a42:	e3c9                	bnez	a5,80000ac4 <kfree+0x98>
    80000a44:	84aa                	mv	s1,a0
    80000a46:	0002b797          	auipc	a5,0x2b
    80000a4a:	5e278793          	addi	a5,a5,1506 # 8002c028 <end>
    80000a4e:	06f56b63          	bltu	a0,a5,80000ac4 <kfree+0x98>
    80000a52:	47c5                	li	a5,17
    80000a54:	07ee                	slli	a5,a5,0x1b
    80000a56:	06f57763          	bgeu	a0,a5,80000ac4 <kfree+0x98>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a5a:	6605                	lui	a2,0x1
    80000a5c:	4585                	li	a1,1
    80000a5e:	00000097          	auipc	ra,0x0
    80000a62:	672080e7          	jalr	1650(ra) # 800010d0 <memset>

  r = (struct run*)pa;

  /** 获取 cpuid 时要关中断，完事之后再把中断开下来 */
  push_off();
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	23e080e7          	jalr	574(ra) # 80000ca4 <push_off>
  int id = cpuid();
    80000a6e:	00001097          	auipc	ra,0x1
    80000a72:	29e080e7          	jalr	670(ra) # 80001d0c <cpuid>
    80000a76:	8a2a                	mv	s4,a0
  pop_off();
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	2e8080e7          	jalr	744(ra) # 80000d60 <pop_off>

  /** 将空闲的 page 归还给第 id 个 CPU */
  acquire(&kmems[id].lock);
    80000a80:	00011a97          	auipc	s5,0x11
    80000a84:	808a8a93          	addi	s5,s5,-2040 # 80011288 <kmems>
    80000a88:	002a1993          	slli	s3,s4,0x2
    80000a8c:	01498933          	add	s2,s3,s4
    80000a90:	090e                	slli	s2,s2,0x3
    80000a92:	9956                	add	s2,s2,s5
    80000a94:	854a                	mv	a0,s2
    80000a96:	00000097          	auipc	ra,0x0
    80000a9a:	25a080e7          	jalr	602(ra) # 80000cf0 <acquire>
  r->next = kmems[id].freelist;
    80000a9e:	02093783          	ld	a5,32(s2)
    80000aa2:	e09c                	sd	a5,0(s1)
  kmems[id].freelist = r;
    80000aa4:	02993023          	sd	s1,32(s2)
  release(&kmems[id].lock);
    80000aa8:	854a                	mv	a0,s2
    80000aaa:	00000097          	auipc	ra,0x0
    80000aae:	316080e7          	jalr	790(ra) # 80000dc0 <release>

  // acquire(&kmem.lock);
  // r->next = kmem.freelist;
  // kmem.freelist = r;
  // release(&kmem.lock);
}
    80000ab2:	70e2                	ld	ra,56(sp)
    80000ab4:	7442                	ld	s0,48(sp)
    80000ab6:	74a2                	ld	s1,40(sp)
    80000ab8:	7902                	ld	s2,32(sp)
    80000aba:	69e2                	ld	s3,24(sp)
    80000abc:	6a42                	ld	s4,16(sp)
    80000abe:	6aa2                	ld	s5,8(sp)
    80000ac0:	6121                	addi	sp,sp,64
    80000ac2:	8082                	ret
    panic("kfree");
    80000ac4:	00007517          	auipc	a0,0x7
    80000ac8:	59c50513          	addi	a0,a0,1436 # 80008060 <digits+0x20>
    80000acc:	00000097          	auipc	ra,0x0
    80000ad0:	a84080e7          	jalr	-1404(ra) # 80000550 <panic>

0000000080000ad4 <freerange>:
{
    80000ad4:	7179                	addi	sp,sp,-48
    80000ad6:	f406                	sd	ra,40(sp)
    80000ad8:	f022                	sd	s0,32(sp)
    80000ada:	ec26                	sd	s1,24(sp)
    80000adc:	e84a                	sd	s2,16(sp)
    80000ade:	e44e                	sd	s3,8(sp)
    80000ae0:	e052                	sd	s4,0(sp)
    80000ae2:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ae4:	6785                	lui	a5,0x1
    80000ae6:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000aea:	94aa                	add	s1,s1,a0
    80000aec:	757d                	lui	a0,0xfffff
    80000aee:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	94be                	add	s1,s1,a5
    80000af2:	0095ee63          	bltu	a1,s1,80000b0e <freerange+0x3a>
    80000af6:	892e                	mv	s2,a1
    kfree(p);
    80000af8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	6985                	lui	s3,0x1
    kfree(p);
    80000afc:	01448533          	add	a0,s1,s4
    80000b00:	00000097          	auipc	ra,0x0
    80000b04:	f2c080e7          	jalr	-212(ra) # 80000a2c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b08:	94ce                	add	s1,s1,s3
    80000b0a:	fe9979e3          	bgeu	s2,s1,80000afc <freerange+0x28>
}
    80000b0e:	70a2                	ld	ra,40(sp)
    80000b10:	7402                	ld	s0,32(sp)
    80000b12:	64e2                	ld	s1,24(sp)
    80000b14:	6942                	ld	s2,16(sp)
    80000b16:	69a2                	ld	s3,8(sp)
    80000b18:	6a02                	ld	s4,0(sp)
    80000b1a:	6145                	addi	sp,sp,48
    80000b1c:	8082                	ret

0000000080000b1e <kinit>:
{
    80000b1e:	7179                	addi	sp,sp,-48
    80000b20:	f406                	sd	ra,40(sp)
    80000b22:	f022                	sd	s0,32(sp)
    80000b24:	ec26                	sd	s1,24(sp)
    80000b26:	e84a                	sd	s2,16(sp)
    80000b28:	e44e                	sd	s3,8(sp)
    80000b2a:	1800                	addi	s0,sp,48
  for(int i=0; i<NCPU; i++)
    80000b2c:	00010497          	auipc	s1,0x10
    80000b30:	75c48493          	addi	s1,s1,1884 # 80011288 <kmems>
    80000b34:	00011997          	auipc	s3,0x11
    80000b38:	89498993          	addi	s3,s3,-1900 # 800113c8 <kmem>
    initlock(&kmems[i].lock, "kmem");
    80000b3c:	00007917          	auipc	s2,0x7
    80000b40:	52c90913          	addi	s2,s2,1324 # 80008068 <digits+0x28>
    80000b44:	85ca                	mv	a1,s2
    80000b46:	8526                	mv	a0,s1
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	324080e7          	jalr	804(ra) # 80000e6c <initlock>
  for(int i=0; i<NCPU; i++)
    80000b50:	02848493          	addi	s1,s1,40
    80000b54:	ff3498e3          	bne	s1,s3,80000b44 <kinit+0x26>
  freerange(end, (void*)PHYSTOP); 
    80000b58:	45c5                	li	a1,17
    80000b5a:	05ee                	slli	a1,a1,0x1b
    80000b5c:	0002b517          	auipc	a0,0x2b
    80000b60:	4cc50513          	addi	a0,a0,1228 # 8002c028 <end>
    80000b64:	00000097          	auipc	ra,0x0
    80000b68:	f70080e7          	jalr	-144(ra) # 80000ad4 <freerange>
}
    80000b6c:	70a2                	ld	ra,40(sp)
    80000b6e:	7402                	ld	s0,32(sp)
    80000b70:	64e2                	ld	s1,24(sp)
    80000b72:	6942                	ld	s2,16(sp)
    80000b74:	69a2                	ld	s3,8(sp)
    80000b76:	6145                	addi	sp,sp,48
    80000b78:	8082                	ret

0000000080000b7a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b7a:	715d                	addi	sp,sp,-80
    80000b7c:	e486                	sd	ra,72(sp)
    80000b7e:	e0a2                	sd	s0,64(sp)
    80000b80:	fc26                	sd	s1,56(sp)
    80000b82:	f84a                	sd	s2,48(sp)
    80000b84:	f44e                	sd	s3,40(sp)
    80000b86:	f052                	sd	s4,32(sp)
    80000b88:	ec56                	sd	s5,24(sp)
    80000b8a:	e85a                	sd	s6,16(sp)
    80000b8c:	e45e                	sd	s7,8(sp)
    80000b8e:	e062                	sd	s8,0(sp)
    80000b90:	0880                	addi	s0,sp,80
  struct run *r;

  /** 获取 cpuid 时要关中断，完事之后再把中断开下来 */
  push_off();
    80000b92:	00000097          	auipc	ra,0x0
    80000b96:	112080e7          	jalr	274(ra) # 80000ca4 <push_off>
  int id = cpuid();
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	172080e7          	jalr	370(ra) # 80001d0c <cpuid>
    80000ba2:	84aa                	mv	s1,a0
  pop_off();
    80000ba4:	00000097          	auipc	ra,0x0
    80000ba8:	1bc080e7          	jalr	444(ra) # 80000d60 <pop_off>

  /** 尝试获取剩余的空闲 page */
  acquire(&kmems[id].lock);
    80000bac:	00249793          	slli	a5,s1,0x2
    80000bb0:	97a6                	add	a5,a5,s1
    80000bb2:	078e                	slli	a5,a5,0x3
    80000bb4:	00010517          	auipc	a0,0x10
    80000bb8:	6d450513          	addi	a0,a0,1748 # 80011288 <kmems>
    80000bbc:	00f509b3          	add	s3,a0,a5
    80000bc0:	854e                	mv	a0,s3
    80000bc2:	00000097          	auipc	ra,0x0
    80000bc6:	12e080e7          	jalr	302(ra) # 80000cf0 <acquire>
  r = kmems[id].freelist;
    80000bca:	0209b903          	ld	s2,32(s3)
  if(r) {
    80000bce:	02090f63          	beqz	s2,80000c0c <kalloc+0x92>
    kmems[id].freelist = r->next;
    80000bd2:	00093703          	ld	a4,0(s2)
    80000bd6:	02e9b023          	sd	a4,32(s3)
      kmems[i].freelist = r->next;
      release(&kmems[i].lock);
      break;
    }
  }
  release(&kmems[id].lock);
    80000bda:	854e                	mv	a0,s3
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	1e4080e7          	jalr	484(ra) # 80000dc0 <release>

  /** 有一种可能：第id个CPU没有空闲 page ，也没偷到 */
  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000be4:	6605                	lui	a2,0x1
    80000be6:	4595                	li	a1,5
    80000be8:	854a                	mv	a0,s2
    80000bea:	00000097          	auipc	ra,0x0
    80000bee:	4e6080e7          	jalr	1254(ra) # 800010d0 <memset>
  // release(&kmem.lock);

  // if(r)
  //   memset((char*)r, 5, PGSIZE); // fill with junk
  // return (void*)r;
}
    80000bf2:	854a                	mv	a0,s2
    80000bf4:	60a6                	ld	ra,72(sp)
    80000bf6:	6406                	ld	s0,64(sp)
    80000bf8:	74e2                	ld	s1,56(sp)
    80000bfa:	7942                	ld	s2,48(sp)
    80000bfc:	79a2                	ld	s3,40(sp)
    80000bfe:	7a02                	ld	s4,32(sp)
    80000c00:	6ae2                	ld	s5,24(sp)
    80000c02:	6b42                	ld	s6,16(sp)
    80000c04:	6ba2                	ld	s7,8(sp)
    80000c06:	6c02                	ld	s8,0(sp)
    80000c08:	6161                	addi	sp,sp,80
    80000c0a:	8082                	ret
    80000c0c:	00010a97          	auipc	s5,0x10
    80000c10:	67ca8a93          	addi	s5,s5,1660 # 80011288 <kmems>
    for(int i=0; i<NCPU; i++) {
    80000c14:	4a01                	li	s4,0
    80000c16:	4c21                	li	s8,8
      if(i == id)
    80000c18:	05448463          	beq	s1,s4,80000c60 <kalloc+0xe6>
      acquire(&kmems[i].lock);
    80000c1c:	8556                	mv	a0,s5
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	0d2080e7          	jalr	210(ra) # 80000cf0 <acquire>
      if(!kmems[i].freelist) {
    80000c26:	020abb03          	ld	s6,32(s5)
    80000c2a:	020b0663          	beqz	s6,80000c56 <kalloc+0xdc>
      kmems[i].freelist = r->next;
    80000c2e:	000b3703          	ld	a4,0(s6)
    80000c32:	002a1793          	slli	a5,s4,0x2
    80000c36:	9a3e                	add	s4,s4,a5
    80000c38:	0a0e                	slli	s4,s4,0x3
    80000c3a:	00010797          	auipc	a5,0x10
    80000c3e:	64e78793          	addi	a5,a5,1614 # 80011288 <kmems>
    80000c42:	9a3e                	add	s4,s4,a5
    80000c44:	02ea3023          	sd	a4,32(s4) # fffffffffffff020 <end+0xffffffff7ffd2ff8>
      release(&kmems[i].lock);
    80000c48:	8556                	mv	a0,s5
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	176080e7          	jalr	374(ra) # 80000dc0 <release>
      if(!kmems[i].freelist) {
    80000c52:	895a                	mv	s2,s6
      break;
    80000c54:	b759                	j	80000bda <kalloc+0x60>
        release(&kmems[i].lock);
    80000c56:	8556                	mv	a0,s5
    80000c58:	00000097          	auipc	ra,0x0
    80000c5c:	168080e7          	jalr	360(ra) # 80000dc0 <release>
    for(int i=0; i<NCPU; i++) {
    80000c60:	2a05                	addiw	s4,s4,1
    80000c62:	028a8a93          	addi	s5,s5,40
    80000c66:	fb8a19e3          	bne	s4,s8,80000c18 <kalloc+0x9e>
  release(&kmems[id].lock);
    80000c6a:	854e                	mv	a0,s3
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	154080e7          	jalr	340(ra) # 80000dc0 <release>
  if(r)
    80000c74:	bfbd                	j	80000bf2 <kalloc+0x78>

0000000080000c76 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c76:	411c                	lw	a5,0(a0)
    80000c78:	e399                	bnez	a5,80000c7e <holding+0x8>
    80000c7a:	4501                	li	a0,0
  return r;
}
    80000c7c:	8082                	ret
{
    80000c7e:	1101                	addi	sp,sp,-32
    80000c80:	ec06                	sd	ra,24(sp)
    80000c82:	e822                	sd	s0,16(sp)
    80000c84:	e426                	sd	s1,8(sp)
    80000c86:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c88:	6904                	ld	s1,16(a0)
    80000c8a:	00001097          	auipc	ra,0x1
    80000c8e:	092080e7          	jalr	146(ra) # 80001d1c <mycpu>
    80000c92:	40a48533          	sub	a0,s1,a0
    80000c96:	00153513          	seqz	a0,a0
}
    80000c9a:	60e2                	ld	ra,24(sp)
    80000c9c:	6442                	ld	s0,16(sp)
    80000c9e:	64a2                	ld	s1,8(sp)
    80000ca0:	6105                	addi	sp,sp,32
    80000ca2:	8082                	ret

0000000080000ca4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000ca4:	1101                	addi	sp,sp,-32
    80000ca6:	ec06                	sd	ra,24(sp)
    80000ca8:	e822                	sd	s0,16(sp)
    80000caa:	e426                	sd	s1,8(sp)
    80000cac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cae:	100024f3          	csrr	s1,sstatus
    80000cb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cb6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cb8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000cbc:	00001097          	auipc	ra,0x1
    80000cc0:	060080e7          	jalr	96(ra) # 80001d1c <mycpu>
    80000cc4:	5d3c                	lw	a5,120(a0)
    80000cc6:	cf89                	beqz	a5,80000ce0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cc8:	00001097          	auipc	ra,0x1
    80000ccc:	054080e7          	jalr	84(ra) # 80001d1c <mycpu>
    80000cd0:	5d3c                	lw	a5,120(a0)
    80000cd2:	2785                	addiw	a5,a5,1
    80000cd4:	dd3c                	sw	a5,120(a0)
}
    80000cd6:	60e2                	ld	ra,24(sp)
    80000cd8:	6442                	ld	s0,16(sp)
    80000cda:	64a2                	ld	s1,8(sp)
    80000cdc:	6105                	addi	sp,sp,32
    80000cde:	8082                	ret
    mycpu()->intena = old;
    80000ce0:	00001097          	auipc	ra,0x1
    80000ce4:	03c080e7          	jalr	60(ra) # 80001d1c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000ce8:	8085                	srli	s1,s1,0x1
    80000cea:	8885                	andi	s1,s1,1
    80000cec:	dd64                	sw	s1,124(a0)
    80000cee:	bfe9                	j	80000cc8 <push_off+0x24>

0000000080000cf0 <acquire>:
{
    80000cf0:	1101                	addi	sp,sp,-32
    80000cf2:	ec06                	sd	ra,24(sp)
    80000cf4:	e822                	sd	s0,16(sp)
    80000cf6:	e426                	sd	s1,8(sp)
    80000cf8:	1000                	addi	s0,sp,32
    80000cfa:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cfc:	00000097          	auipc	ra,0x0
    80000d00:	fa8080e7          	jalr	-88(ra) # 80000ca4 <push_off>
  if(holding(lk))
    80000d04:	8526                	mv	a0,s1
    80000d06:	00000097          	auipc	ra,0x0
    80000d0a:	f70080e7          	jalr	-144(ra) # 80000c76 <holding>
    80000d0e:	e911                	bnez	a0,80000d22 <acquire+0x32>
    __sync_fetch_and_add(&(lk->n), 1);
    80000d10:	4785                	li	a5,1
    80000d12:	01c48713          	addi	a4,s1,28
    80000d16:	0f50000f          	fence	iorw,ow
    80000d1a:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d1e:	4705                	li	a4,1
    80000d20:	a839                	j	80000d3e <acquire+0x4e>
    panic("acquire");
    80000d22:	00007517          	auipc	a0,0x7
    80000d26:	34e50513          	addi	a0,a0,846 # 80008070 <digits+0x30>
    80000d2a:	00000097          	auipc	ra,0x0
    80000d2e:	826080e7          	jalr	-2010(ra) # 80000550 <panic>
    __sync_fetch_and_add(&(lk->nts), 1);
    80000d32:	01848793          	addi	a5,s1,24
    80000d36:	0f50000f          	fence	iorw,ow
    80000d3a:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d3e:	87ba                	mv	a5,a4
    80000d40:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d44:	2781                	sext.w	a5,a5
    80000d46:	f7f5                	bnez	a5,80000d32 <acquire+0x42>
  __sync_synchronize();
    80000d48:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d4c:	00001097          	auipc	ra,0x1
    80000d50:	fd0080e7          	jalr	-48(ra) # 80001d1c <mycpu>
    80000d54:	e888                	sd	a0,16(s1)
}
    80000d56:	60e2                	ld	ra,24(sp)
    80000d58:	6442                	ld	s0,16(sp)
    80000d5a:	64a2                	ld	s1,8(sp)
    80000d5c:	6105                	addi	sp,sp,32
    80000d5e:	8082                	ret

0000000080000d60 <pop_off>:

void
pop_off(void)
{
    80000d60:	1141                	addi	sp,sp,-16
    80000d62:	e406                	sd	ra,8(sp)
    80000d64:	e022                	sd	s0,0(sp)
    80000d66:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d68:	00001097          	auipc	ra,0x1
    80000d6c:	fb4080e7          	jalr	-76(ra) # 80001d1c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d70:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d74:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d76:	e78d                	bnez	a5,80000da0 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d78:	5d3c                	lw	a5,120(a0)
    80000d7a:	02f05b63          	blez	a5,80000db0 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d7e:	37fd                	addiw	a5,a5,-1
    80000d80:	0007871b          	sext.w	a4,a5
    80000d84:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d86:	eb09                	bnez	a4,80000d98 <pop_off+0x38>
    80000d88:	5d7c                	lw	a5,124(a0)
    80000d8a:	c799                	beqz	a5,80000d98 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d8c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d90:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d94:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d98:	60a2                	ld	ra,8(sp)
    80000d9a:	6402                	ld	s0,0(sp)
    80000d9c:	0141                	addi	sp,sp,16
    80000d9e:	8082                	ret
    panic("pop_off - interruptible");
    80000da0:	00007517          	auipc	a0,0x7
    80000da4:	2d850513          	addi	a0,a0,728 # 80008078 <digits+0x38>
    80000da8:	fffff097          	auipc	ra,0xfffff
    80000dac:	7a8080e7          	jalr	1960(ra) # 80000550 <panic>
    panic("pop_off");
    80000db0:	00007517          	auipc	a0,0x7
    80000db4:	2e050513          	addi	a0,a0,736 # 80008090 <digits+0x50>
    80000db8:	fffff097          	auipc	ra,0xfffff
    80000dbc:	798080e7          	jalr	1944(ra) # 80000550 <panic>

0000000080000dc0 <release>:
{
    80000dc0:	1101                	addi	sp,sp,-32
    80000dc2:	ec06                	sd	ra,24(sp)
    80000dc4:	e822                	sd	s0,16(sp)
    80000dc6:	e426                	sd	s1,8(sp)
    80000dc8:	1000                	addi	s0,sp,32
    80000dca:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dcc:	00000097          	auipc	ra,0x0
    80000dd0:	eaa080e7          	jalr	-342(ra) # 80000c76 <holding>
    80000dd4:	c115                	beqz	a0,80000df8 <release+0x38>
  lk->cpu = 0;
    80000dd6:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000dda:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000dde:	0f50000f          	fence	iorw,ow
    80000de2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000de6:	00000097          	auipc	ra,0x0
    80000dea:	f7a080e7          	jalr	-134(ra) # 80000d60 <pop_off>
}
    80000dee:	60e2                	ld	ra,24(sp)
    80000df0:	6442                	ld	s0,16(sp)
    80000df2:	64a2                	ld	s1,8(sp)
    80000df4:	6105                	addi	sp,sp,32
    80000df6:	8082                	ret
    panic("release");
    80000df8:	00007517          	auipc	a0,0x7
    80000dfc:	2a050513          	addi	a0,a0,672 # 80008098 <digits+0x58>
    80000e00:	fffff097          	auipc	ra,0xfffff
    80000e04:	750080e7          	jalr	1872(ra) # 80000550 <panic>

0000000080000e08 <freelock>:
{
    80000e08:	1101                	addi	sp,sp,-32
    80000e0a:	ec06                	sd	ra,24(sp)
    80000e0c:	e822                	sd	s0,16(sp)
    80000e0e:	e426                	sd	s1,8(sp)
    80000e10:	1000                	addi	s0,sp,32
    80000e12:	84aa                	mv	s1,a0
  acquire(&lock_locks);
    80000e14:	00010517          	auipc	a0,0x10
    80000e18:	5dc50513          	addi	a0,a0,1500 # 800113f0 <lock_locks>
    80000e1c:	00000097          	auipc	ra,0x0
    80000e20:	ed4080e7          	jalr	-300(ra) # 80000cf0 <acquire>
  for (i = 0; i < NLOCK; i++) {
    80000e24:	00010717          	auipc	a4,0x10
    80000e28:	5ec70713          	addi	a4,a4,1516 # 80011410 <locks>
    80000e2c:	4781                	li	a5,0
    80000e2e:	1f400613          	li	a2,500
    if(locks[i] == lk) {
    80000e32:	6314                	ld	a3,0(a4)
    80000e34:	00968763          	beq	a3,s1,80000e42 <freelock+0x3a>
  for (i = 0; i < NLOCK; i++) {
    80000e38:	2785                	addiw	a5,a5,1
    80000e3a:	0721                	addi	a4,a4,8
    80000e3c:	fec79be3          	bne	a5,a2,80000e32 <freelock+0x2a>
    80000e40:	a809                	j	80000e52 <freelock+0x4a>
      locks[i] = 0;
    80000e42:	078e                	slli	a5,a5,0x3
    80000e44:	00010717          	auipc	a4,0x10
    80000e48:	5cc70713          	addi	a4,a4,1484 # 80011410 <locks>
    80000e4c:	97ba                	add	a5,a5,a4
    80000e4e:	0007b023          	sd	zero,0(a5)
  release(&lock_locks);
    80000e52:	00010517          	auipc	a0,0x10
    80000e56:	59e50513          	addi	a0,a0,1438 # 800113f0 <lock_locks>
    80000e5a:	00000097          	auipc	ra,0x0
    80000e5e:	f66080e7          	jalr	-154(ra) # 80000dc0 <release>
}
    80000e62:	60e2                	ld	ra,24(sp)
    80000e64:	6442                	ld	s0,16(sp)
    80000e66:	64a2                	ld	s1,8(sp)
    80000e68:	6105                	addi	sp,sp,32
    80000e6a:	8082                	ret

0000000080000e6c <initlock>:
{
    80000e6c:	1101                	addi	sp,sp,-32
    80000e6e:	ec06                	sd	ra,24(sp)
    80000e70:	e822                	sd	s0,16(sp)
    80000e72:	e426                	sd	s1,8(sp)
    80000e74:	1000                	addi	s0,sp,32
    80000e76:	84aa                	mv	s1,a0
  lk->name = name;
    80000e78:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000e7a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000e7e:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000e82:	00052c23          	sw	zero,24(a0)
  lk->n = 0;
    80000e86:	00052e23          	sw	zero,28(a0)
  acquire(&lock_locks);
    80000e8a:	00010517          	auipc	a0,0x10
    80000e8e:	56650513          	addi	a0,a0,1382 # 800113f0 <lock_locks>
    80000e92:	00000097          	auipc	ra,0x0
    80000e96:	e5e080e7          	jalr	-418(ra) # 80000cf0 <acquire>
  for (i = 0; i < NLOCK; i++) {
    80000e9a:	00010717          	auipc	a4,0x10
    80000e9e:	57670713          	addi	a4,a4,1398 # 80011410 <locks>
    80000ea2:	4781                	li	a5,0
    80000ea4:	1f400693          	li	a3,500
    if(locks[i] == 0) {
    80000ea8:	6310                	ld	a2,0(a4)
    80000eaa:	ce09                	beqz	a2,80000ec4 <initlock+0x58>
  for (i = 0; i < NLOCK; i++) {
    80000eac:	2785                	addiw	a5,a5,1
    80000eae:	0721                	addi	a4,a4,8
    80000eb0:	fed79ce3          	bne	a5,a3,80000ea8 <initlock+0x3c>
  panic("findslot");
    80000eb4:	00007517          	auipc	a0,0x7
    80000eb8:	1ec50513          	addi	a0,a0,492 # 800080a0 <digits+0x60>
    80000ebc:	fffff097          	auipc	ra,0xfffff
    80000ec0:	694080e7          	jalr	1684(ra) # 80000550 <panic>
      locks[i] = lk;
    80000ec4:	078e                	slli	a5,a5,0x3
    80000ec6:	00010717          	auipc	a4,0x10
    80000eca:	54a70713          	addi	a4,a4,1354 # 80011410 <locks>
    80000ece:	97ba                	add	a5,a5,a4
    80000ed0:	e384                	sd	s1,0(a5)
      release(&lock_locks);
    80000ed2:	00010517          	auipc	a0,0x10
    80000ed6:	51e50513          	addi	a0,a0,1310 # 800113f0 <lock_locks>
    80000eda:	00000097          	auipc	ra,0x0
    80000ede:	ee6080e7          	jalr	-282(ra) # 80000dc0 <release>
}
    80000ee2:	60e2                	ld	ra,24(sp)
    80000ee4:	6442                	ld	s0,16(sp)
    80000ee6:	64a2                	ld	s1,8(sp)
    80000ee8:	6105                	addi	sp,sp,32
    80000eea:	8082                	ret

0000000080000eec <snprint_lock>:
#ifdef LAB_LOCK
int
snprint_lock(char *buf, int sz, struct spinlock *lk)
{
  int n = 0;
  if(lk->n > 0) {
    80000eec:	4e5c                	lw	a5,28(a2)
    80000eee:	00f04463          	bgtz	a5,80000ef6 <snprint_lock+0xa>
  int n = 0;
    80000ef2:	4501                	li	a0,0
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
                 lk->name, lk->nts, lk->n);
  }
  return n;
}
    80000ef4:	8082                	ret
{
    80000ef6:	1141                	addi	sp,sp,-16
    80000ef8:	e406                	sd	ra,8(sp)
    80000efa:	e022                	sd	s0,0(sp)
    80000efc:	0800                	addi	s0,sp,16
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
    80000efe:	4e18                	lw	a4,24(a2)
    80000f00:	6614                	ld	a3,8(a2)
    80000f02:	00007617          	auipc	a2,0x7
    80000f06:	1ae60613          	addi	a2,a2,430 # 800080b0 <digits+0x70>
    80000f0a:	00006097          	auipc	ra,0x6
    80000f0e:	988080e7          	jalr	-1656(ra) # 80006892 <snprintf>
}
    80000f12:	60a2                	ld	ra,8(sp)
    80000f14:	6402                	ld	s0,0(sp)
    80000f16:	0141                	addi	sp,sp,16
    80000f18:	8082                	ret

0000000080000f1a <statslock>:

int
statslock(char *buf, int sz) {
    80000f1a:	7159                	addi	sp,sp,-112
    80000f1c:	f486                	sd	ra,104(sp)
    80000f1e:	f0a2                	sd	s0,96(sp)
    80000f20:	eca6                	sd	s1,88(sp)
    80000f22:	e8ca                	sd	s2,80(sp)
    80000f24:	e4ce                	sd	s3,72(sp)
    80000f26:	e0d2                	sd	s4,64(sp)
    80000f28:	fc56                	sd	s5,56(sp)
    80000f2a:	f85a                	sd	s6,48(sp)
    80000f2c:	f45e                	sd	s7,40(sp)
    80000f2e:	f062                	sd	s8,32(sp)
    80000f30:	ec66                	sd	s9,24(sp)
    80000f32:	e86a                	sd	s10,16(sp)
    80000f34:	e46e                	sd	s11,8(sp)
    80000f36:	1880                	addi	s0,sp,112
    80000f38:	8aaa                	mv	s5,a0
    80000f3a:	8b2e                	mv	s6,a1
  int n;
  int tot = 0;

  acquire(&lock_locks);
    80000f3c:	00010517          	auipc	a0,0x10
    80000f40:	4b450513          	addi	a0,a0,1204 # 800113f0 <lock_locks>
    80000f44:	00000097          	auipc	ra,0x0
    80000f48:	dac080e7          	jalr	-596(ra) # 80000cf0 <acquire>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80000f4c:	00007617          	auipc	a2,0x7
    80000f50:	19460613          	addi	a2,a2,404 # 800080e0 <digits+0xa0>
    80000f54:	85da                	mv	a1,s6
    80000f56:	8556                	mv	a0,s5
    80000f58:	00006097          	auipc	ra,0x6
    80000f5c:	93a080e7          	jalr	-1734(ra) # 80006892 <snprintf>
    80000f60:	892a                	mv	s2,a0
  for(int i = 0; i < NLOCK; i++) {
    80000f62:	00010c97          	auipc	s9,0x10
    80000f66:	4aec8c93          	addi	s9,s9,1198 # 80011410 <locks>
    80000f6a:	00011c17          	auipc	s8,0x11
    80000f6e:	446c0c13          	addi	s8,s8,1094 # 800123b0 <pid_lock>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80000f72:	84e6                	mv	s1,s9
  int tot = 0;
    80000f74:	4a01                	li	s4,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000f76:	00007b97          	auipc	s7,0x7
    80000f7a:	18ab8b93          	addi	s7,s7,394 # 80008100 <digits+0xc0>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000f7e:	00007d17          	auipc	s10,0x7
    80000f82:	0ead0d13          	addi	s10,s10,234 # 80008068 <digits+0x28>
    80000f86:	a01d                	j	80000fac <statslock+0x92>
      tot += locks[i]->nts;
    80000f88:	0009b603          	ld	a2,0(s3)
    80000f8c:	4e1c                	lw	a5,24(a2)
    80000f8e:	01478a3b          	addw	s4,a5,s4
      n += snprint_lock(buf +n, sz-n, locks[i]);
    80000f92:	412b05bb          	subw	a1,s6,s2
    80000f96:	012a8533          	add	a0,s5,s2
    80000f9a:	00000097          	auipc	ra,0x0
    80000f9e:	f52080e7          	jalr	-174(ra) # 80000eec <snprint_lock>
    80000fa2:	0125093b          	addw	s2,a0,s2
  for(int i = 0; i < NLOCK; i++) {
    80000fa6:	04a1                	addi	s1,s1,8
    80000fa8:	05848763          	beq	s1,s8,80000ff6 <statslock+0xdc>
    if(locks[i] == 0)
    80000fac:	89a6                	mv	s3,s1
    80000fae:	609c                	ld	a5,0(s1)
    80000fb0:	c3b9                	beqz	a5,80000ff6 <statslock+0xdc>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000fb2:	0087bd83          	ld	s11,8(a5)
    80000fb6:	855e                	mv	a0,s7
    80000fb8:	00000097          	auipc	ra,0x0
    80000fbc:	2a0080e7          	jalr	672(ra) # 80001258 <strlen>
    80000fc0:	0005061b          	sext.w	a2,a0
    80000fc4:	85de                	mv	a1,s7
    80000fc6:	856e                	mv	a0,s11
    80000fc8:	00000097          	auipc	ra,0x0
    80000fcc:	1e4080e7          	jalr	484(ra) # 800011ac <strncmp>
    80000fd0:	dd45                	beqz	a0,80000f88 <statslock+0x6e>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000fd2:	609c                	ld	a5,0(s1)
    80000fd4:	0087bd83          	ld	s11,8(a5)
    80000fd8:	856a                	mv	a0,s10
    80000fda:	00000097          	auipc	ra,0x0
    80000fde:	27e080e7          	jalr	638(ra) # 80001258 <strlen>
    80000fe2:	0005061b          	sext.w	a2,a0
    80000fe6:	85ea                	mv	a1,s10
    80000fe8:	856e                	mv	a0,s11
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	1c2080e7          	jalr	450(ra) # 800011ac <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000ff2:	f955                	bnez	a0,80000fa6 <statslock+0x8c>
    80000ff4:	bf51                	j	80000f88 <statslock+0x6e>
    }
  }
  
  n += snprintf(buf+n, sz-n, "--- top 5 contended locks:\n");
    80000ff6:	00007617          	auipc	a2,0x7
    80000ffa:	11260613          	addi	a2,a2,274 # 80008108 <digits+0xc8>
    80000ffe:	412b05bb          	subw	a1,s6,s2
    80001002:	012a8533          	add	a0,s5,s2
    80001006:	00006097          	auipc	ra,0x6
    8000100a:	88c080e7          	jalr	-1908(ra) # 80006892 <snprintf>
    8000100e:	012509bb          	addw	s3,a0,s2
    80001012:	4b95                	li	s7,5
  int last = 100000000;
    80001014:	05f5e537          	lui	a0,0x5f5e
    80001018:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t = 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    8000101c:	4c01                	li	s8,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    8000101e:	00010497          	auipc	s1,0x10
    80001022:	3f248493          	addi	s1,s1,1010 # 80011410 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80001026:	1f400913          	li	s2,500
    8000102a:	a881                	j	8000107a <statslock+0x160>
    8000102c:	2705                	addiw	a4,a4,1
    8000102e:	06a1                	addi	a3,a3,8
    80001030:	03270063          	beq	a4,s2,80001050 <statslock+0x136>
      if(locks[i] == 0)
    80001034:	629c                	ld	a5,0(a3)
    80001036:	cf89                	beqz	a5,80001050 <statslock+0x136>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80001038:	4f90                	lw	a2,24(a5)
    8000103a:	00359793          	slli	a5,a1,0x3
    8000103e:	97a6                	add	a5,a5,s1
    80001040:	639c                	ld	a5,0(a5)
    80001042:	4f9c                	lw	a5,24(a5)
    80001044:	fec7d4e3          	bge	a5,a2,8000102c <statslock+0x112>
    80001048:	fea652e3          	bge	a2,a0,8000102c <statslock+0x112>
    8000104c:	85ba                	mv	a1,a4
    8000104e:	bff9                	j	8000102c <statslock+0x112>
        top = i;
      }
    }
    n += snprint_lock(buf+n, sz-n, locks[top]);
    80001050:	058e                	slli	a1,a1,0x3
    80001052:	00b48d33          	add	s10,s1,a1
    80001056:	000d3603          	ld	a2,0(s10)
    8000105a:	413b05bb          	subw	a1,s6,s3
    8000105e:	013a8533          	add	a0,s5,s3
    80001062:	00000097          	auipc	ra,0x0
    80001066:	e8a080e7          	jalr	-374(ra) # 80000eec <snprint_lock>
    8000106a:	013509bb          	addw	s3,a0,s3
    last = locks[top]->nts;
    8000106e:	000d3783          	ld	a5,0(s10)
    80001072:	4f88                	lw	a0,24(a5)
  for(int t = 0; t < 5; t++) {
    80001074:	3bfd                	addiw	s7,s7,-1
    80001076:	000b8663          	beqz	s7,80001082 <statslock+0x168>
  int tot = 0;
    8000107a:	86e6                	mv	a3,s9
    for(int i = 0; i < NLOCK; i++) {
    8000107c:	8762                	mv	a4,s8
    int top = 0;
    8000107e:	85e2                	mv	a1,s8
    80001080:	bf55                	j	80001034 <statslock+0x11a>
  }
  n += snprintf(buf+n, sz-n, "tot= %d\n", tot);
    80001082:	86d2                	mv	a3,s4
    80001084:	00007617          	auipc	a2,0x7
    80001088:	0a460613          	addi	a2,a2,164 # 80008128 <digits+0xe8>
    8000108c:	413b05bb          	subw	a1,s6,s3
    80001090:	013a8533          	add	a0,s5,s3
    80001094:	00005097          	auipc	ra,0x5
    80001098:	7fe080e7          	jalr	2046(ra) # 80006892 <snprintf>
    8000109c:	013509bb          	addw	s3,a0,s3
  release(&lock_locks);  
    800010a0:	00010517          	auipc	a0,0x10
    800010a4:	35050513          	addi	a0,a0,848 # 800113f0 <lock_locks>
    800010a8:	00000097          	auipc	ra,0x0
    800010ac:	d18080e7          	jalr	-744(ra) # 80000dc0 <release>
  return n;
}
    800010b0:	854e                	mv	a0,s3
    800010b2:	70a6                	ld	ra,104(sp)
    800010b4:	7406                	ld	s0,96(sp)
    800010b6:	64e6                	ld	s1,88(sp)
    800010b8:	6946                	ld	s2,80(sp)
    800010ba:	69a6                	ld	s3,72(sp)
    800010bc:	6a06                	ld	s4,64(sp)
    800010be:	7ae2                	ld	s5,56(sp)
    800010c0:	7b42                	ld	s6,48(sp)
    800010c2:	7ba2                	ld	s7,40(sp)
    800010c4:	7c02                	ld	s8,32(sp)
    800010c6:	6ce2                	ld	s9,24(sp)
    800010c8:	6d42                	ld	s10,16(sp)
    800010ca:	6da2                	ld	s11,8(sp)
    800010cc:	6165                	addi	sp,sp,112
    800010ce:	8082                	ret

00000000800010d0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800010d0:	1141                	addi	sp,sp,-16
    800010d2:	e422                	sd	s0,8(sp)
    800010d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800010d6:	ce09                	beqz	a2,800010f0 <memset+0x20>
    800010d8:	87aa                	mv	a5,a0
    800010da:	fff6071b          	addiw	a4,a2,-1
    800010de:	1702                	slli	a4,a4,0x20
    800010e0:	9301                	srli	a4,a4,0x20
    800010e2:	0705                	addi	a4,a4,1
    800010e4:	972a                	add	a4,a4,a0
    cdst[i] = c;
    800010e6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800010ea:	0785                	addi	a5,a5,1
    800010ec:	fee79de3          	bne	a5,a4,800010e6 <memset+0x16>
  }
  return dst;
}
    800010f0:	6422                	ld	s0,8(sp)
    800010f2:	0141                	addi	sp,sp,16
    800010f4:	8082                	ret

00000000800010f6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800010f6:	1141                	addi	sp,sp,-16
    800010f8:	e422                	sd	s0,8(sp)
    800010fa:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800010fc:	ca05                	beqz	a2,8000112c <memcmp+0x36>
    800010fe:	fff6069b          	addiw	a3,a2,-1
    80001102:	1682                	slli	a3,a3,0x20
    80001104:	9281                	srli	a3,a3,0x20
    80001106:	0685                	addi	a3,a3,1
    80001108:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    8000110a:	00054783          	lbu	a5,0(a0)
    8000110e:	0005c703          	lbu	a4,0(a1)
    80001112:	00e79863          	bne	a5,a4,80001122 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80001116:	0505                	addi	a0,a0,1
    80001118:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000111a:	fed518e3          	bne	a0,a3,8000110a <memcmp+0x14>
  }

  return 0;
    8000111e:	4501                	li	a0,0
    80001120:	a019                	j	80001126 <memcmp+0x30>
      return *s1 - *s2;
    80001122:	40e7853b          	subw	a0,a5,a4
}
    80001126:	6422                	ld	s0,8(sp)
    80001128:	0141                	addi	sp,sp,16
    8000112a:	8082                	ret
  return 0;
    8000112c:	4501                	li	a0,0
    8000112e:	bfe5                	j	80001126 <memcmp+0x30>

0000000080001130 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001130:	1141                	addi	sp,sp,-16
    80001132:	e422                	sd	s0,8(sp)
    80001134:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80001136:	00a5f963          	bgeu	a1,a0,80001148 <memmove+0x18>
    8000113a:	02061713          	slli	a4,a2,0x20
    8000113e:	9301                	srli	a4,a4,0x20
    80001140:	00e587b3          	add	a5,a1,a4
    80001144:	02f56563          	bltu	a0,a5,8000116e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80001148:	fff6069b          	addiw	a3,a2,-1
    8000114c:	ce11                	beqz	a2,80001168 <memmove+0x38>
    8000114e:	1682                	slli	a3,a3,0x20
    80001150:	9281                	srli	a3,a3,0x20
    80001152:	0685                	addi	a3,a3,1
    80001154:	96ae                	add	a3,a3,a1
    80001156:	87aa                	mv	a5,a0
      *d++ = *s++;
    80001158:	0585                	addi	a1,a1,1
    8000115a:	0785                	addi	a5,a5,1
    8000115c:	fff5c703          	lbu	a4,-1(a1)
    80001160:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80001164:	fed59ae3          	bne	a1,a3,80001158 <memmove+0x28>

  return dst;
}
    80001168:	6422                	ld	s0,8(sp)
    8000116a:	0141                	addi	sp,sp,16
    8000116c:	8082                	ret
    d += n;
    8000116e:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80001170:	fff6069b          	addiw	a3,a2,-1
    80001174:	da75                	beqz	a2,80001168 <memmove+0x38>
    80001176:	02069613          	slli	a2,a3,0x20
    8000117a:	9201                	srli	a2,a2,0x20
    8000117c:	fff64613          	not	a2,a2
    80001180:	963e                	add	a2,a2,a5
      *--d = *--s;
    80001182:	17fd                	addi	a5,a5,-1
    80001184:	177d                	addi	a4,a4,-1
    80001186:	0007c683          	lbu	a3,0(a5)
    8000118a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    8000118e:	fec79ae3          	bne	a5,a2,80001182 <memmove+0x52>
    80001192:	bfd9                	j	80001168 <memmove+0x38>

0000000080001194 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80001194:	1141                	addi	sp,sp,-16
    80001196:	e406                	sd	ra,8(sp)
    80001198:	e022                	sd	s0,0(sp)
    8000119a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	f94080e7          	jalr	-108(ra) # 80001130 <memmove>
}
    800011a4:	60a2                	ld	ra,8(sp)
    800011a6:	6402                	ld	s0,0(sp)
    800011a8:	0141                	addi	sp,sp,16
    800011aa:	8082                	ret

00000000800011ac <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800011ac:	1141                	addi	sp,sp,-16
    800011ae:	e422                	sd	s0,8(sp)
    800011b0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800011b2:	ce11                	beqz	a2,800011ce <strncmp+0x22>
    800011b4:	00054783          	lbu	a5,0(a0)
    800011b8:	cf89                	beqz	a5,800011d2 <strncmp+0x26>
    800011ba:	0005c703          	lbu	a4,0(a1)
    800011be:	00f71a63          	bne	a4,a5,800011d2 <strncmp+0x26>
    n--, p++, q++;
    800011c2:	367d                	addiw	a2,a2,-1
    800011c4:	0505                	addi	a0,a0,1
    800011c6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800011c8:	f675                	bnez	a2,800011b4 <strncmp+0x8>
  if(n == 0)
    return 0;
    800011ca:	4501                	li	a0,0
    800011cc:	a809                	j	800011de <strncmp+0x32>
    800011ce:	4501                	li	a0,0
    800011d0:	a039                	j	800011de <strncmp+0x32>
  if(n == 0)
    800011d2:	ca09                	beqz	a2,800011e4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800011d4:	00054503          	lbu	a0,0(a0)
    800011d8:	0005c783          	lbu	a5,0(a1)
    800011dc:	9d1d                	subw	a0,a0,a5
}
    800011de:	6422                	ld	s0,8(sp)
    800011e0:	0141                	addi	sp,sp,16
    800011e2:	8082                	ret
    return 0;
    800011e4:	4501                	li	a0,0
    800011e6:	bfe5                	j	800011de <strncmp+0x32>

00000000800011e8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800011e8:	1141                	addi	sp,sp,-16
    800011ea:	e422                	sd	s0,8(sp)
    800011ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800011ee:	872a                	mv	a4,a0
    800011f0:	8832                	mv	a6,a2
    800011f2:	367d                	addiw	a2,a2,-1
    800011f4:	01005963          	blez	a6,80001206 <strncpy+0x1e>
    800011f8:	0705                	addi	a4,a4,1
    800011fa:	0005c783          	lbu	a5,0(a1)
    800011fe:	fef70fa3          	sb	a5,-1(a4)
    80001202:	0585                	addi	a1,a1,1
    80001204:	f7f5                	bnez	a5,800011f0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80001206:	00c05d63          	blez	a2,80001220 <strncpy+0x38>
    8000120a:	86ba                	mv	a3,a4
    *s++ = 0;
    8000120c:	0685                	addi	a3,a3,1
    8000120e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001212:	fff6c793          	not	a5,a3
    80001216:	9fb9                	addw	a5,a5,a4
    80001218:	010787bb          	addw	a5,a5,a6
    8000121c:	fef048e3          	bgtz	a5,8000120c <strncpy+0x24>
  return os;
}
    80001220:	6422                	ld	s0,8(sp)
    80001222:	0141                	addi	sp,sp,16
    80001224:	8082                	ret

0000000080001226 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80001226:	1141                	addi	sp,sp,-16
    80001228:	e422                	sd	s0,8(sp)
    8000122a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000122c:	02c05363          	blez	a2,80001252 <safestrcpy+0x2c>
    80001230:	fff6069b          	addiw	a3,a2,-1
    80001234:	1682                	slli	a3,a3,0x20
    80001236:	9281                	srli	a3,a3,0x20
    80001238:	96ae                	add	a3,a3,a1
    8000123a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000123c:	00d58963          	beq	a1,a3,8000124e <safestrcpy+0x28>
    80001240:	0585                	addi	a1,a1,1
    80001242:	0785                	addi	a5,a5,1
    80001244:	fff5c703          	lbu	a4,-1(a1)
    80001248:	fee78fa3          	sb	a4,-1(a5)
    8000124c:	fb65                	bnez	a4,8000123c <safestrcpy+0x16>
    ;
  *s = 0;
    8000124e:	00078023          	sb	zero,0(a5)
  return os;
}
    80001252:	6422                	ld	s0,8(sp)
    80001254:	0141                	addi	sp,sp,16
    80001256:	8082                	ret

0000000080001258 <strlen>:

int
strlen(const char *s)
{
    80001258:	1141                	addi	sp,sp,-16
    8000125a:	e422                	sd	s0,8(sp)
    8000125c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000125e:	00054783          	lbu	a5,0(a0)
    80001262:	cf91                	beqz	a5,8000127e <strlen+0x26>
    80001264:	0505                	addi	a0,a0,1
    80001266:	87aa                	mv	a5,a0
    80001268:	4685                	li	a3,1
    8000126a:	9e89                	subw	a3,a3,a0
    8000126c:	00f6853b          	addw	a0,a3,a5
    80001270:	0785                	addi	a5,a5,1
    80001272:	fff7c703          	lbu	a4,-1(a5)
    80001276:	fb7d                	bnez	a4,8000126c <strlen+0x14>
    ;
  return n;
}
    80001278:	6422                	ld	s0,8(sp)
    8000127a:	0141                	addi	sp,sp,16
    8000127c:	8082                	ret
  for(n = 0; s[n]; n++)
    8000127e:	4501                	li	a0,0
    80001280:	bfe5                	j	80001278 <strlen+0x20>

0000000080001282 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001282:	1141                	addi	sp,sp,-16
    80001284:	e406                	sd	ra,8(sp)
    80001286:	e022                	sd	s0,0(sp)
    80001288:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000128a:	00001097          	auipc	ra,0x1
    8000128e:	a82080e7          	jalr	-1406(ra) # 80001d0c <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001292:	00008717          	auipc	a4,0x8
    80001296:	d7a70713          	addi	a4,a4,-646 # 8000900c <started>
  if(cpuid() == 0){
    8000129a:	c139                	beqz	a0,800012e0 <main+0x5e>
    while(started == 0)
    8000129c:	431c                	lw	a5,0(a4)
    8000129e:	2781                	sext.w	a5,a5
    800012a0:	dff5                	beqz	a5,8000129c <main+0x1a>
      ;
    __sync_synchronize();
    800012a2:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800012a6:	00001097          	auipc	ra,0x1
    800012aa:	a66080e7          	jalr	-1434(ra) # 80001d0c <cpuid>
    800012ae:	85aa                	mv	a1,a0
    800012b0:	00007517          	auipc	a0,0x7
    800012b4:	ea050513          	addi	a0,a0,-352 # 80008150 <digits+0x110>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	2e2080e7          	jalr	738(ra) # 8000059a <printf>
    kvminithart();    // turn on paging
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	186080e7          	jalr	390(ra) # 80001446 <kvminithart>
    trapinithart();   // install kernel trap vector
    800012c8:	00001097          	auipc	ra,0x1
    800012cc:	6ce080e7          	jalr	1742(ra) # 80002996 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800012d0:	00005097          	auipc	ra,0x5
    800012d4:	e00080e7          	jalr	-512(ra) # 800060d0 <plicinithart>
  }

  scheduler();        
    800012d8:	00001097          	auipc	ra,0x1
    800012dc:	f90080e7          	jalr	-112(ra) # 80002268 <scheduler>
    consoleinit();
    800012e0:	fffff097          	auipc	ra,0xfffff
    800012e4:	182080e7          	jalr	386(ra) # 80000462 <consoleinit>
    statsinit();
    800012e8:	00005097          	auipc	ra,0x5
    800012ec:	4ce080e7          	jalr	1230(ra) # 800067b6 <statsinit>
    printfinit();
    800012f0:	fffff097          	auipc	ra,0xfffff
    800012f4:	490080e7          	jalr	1168(ra) # 80000780 <printfinit>
    printf("\n");
    800012f8:	00007517          	auipc	a0,0x7
    800012fc:	e6850513          	addi	a0,a0,-408 # 80008160 <digits+0x120>
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	29a080e7          	jalr	666(ra) # 8000059a <printf>
    printf("xv6 kernel is booting\n");
    80001308:	00007517          	auipc	a0,0x7
    8000130c:	e3050513          	addi	a0,a0,-464 # 80008138 <digits+0xf8>
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	28a080e7          	jalr	650(ra) # 8000059a <printf>
    printf("\n");
    80001318:	00007517          	auipc	a0,0x7
    8000131c:	e4850513          	addi	a0,a0,-440 # 80008160 <digits+0x120>
    80001320:	fffff097          	auipc	ra,0xfffff
    80001324:	27a080e7          	jalr	634(ra) # 8000059a <printf>
    kinit();         // physical page allocator
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	7f6080e7          	jalr	2038(ra) # 80000b1e <kinit>
    kvminit();       // create kernel page table
    80001330:	00000097          	auipc	ra,0x0
    80001334:	242080e7          	jalr	578(ra) # 80001572 <kvminit>
    kvminithart();   // turn on paging
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	10e080e7          	jalr	270(ra) # 80001446 <kvminithart>
    procinit();      // process table
    80001340:	00001097          	auipc	ra,0x1
    80001344:	8fc080e7          	jalr	-1796(ra) # 80001c3c <procinit>
    trapinit();      // trap vectors
    80001348:	00001097          	auipc	ra,0x1
    8000134c:	626080e7          	jalr	1574(ra) # 8000296e <trapinit>
    trapinithart();  // install kernel trap vector
    80001350:	00001097          	auipc	ra,0x1
    80001354:	646080e7          	jalr	1606(ra) # 80002996 <trapinithart>
    plicinit();      // set up interrupt controller
    80001358:	00005097          	auipc	ra,0x5
    8000135c:	d62080e7          	jalr	-670(ra) # 800060ba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001360:	00005097          	auipc	ra,0x5
    80001364:	d70080e7          	jalr	-656(ra) # 800060d0 <plicinithart>
    binit();         // buffer cache
    80001368:	00002097          	auipc	ra,0x2
    8000136c:	d70080e7          	jalr	-656(ra) # 800030d8 <binit>
    iinit();         // inode cache
    80001370:	00002097          	auipc	ra,0x2
    80001374:	57c080e7          	jalr	1404(ra) # 800038ec <iinit>
    fileinit();      // file table
    80001378:	00003097          	auipc	ra,0x3
    8000137c:	52c080e7          	jalr	1324(ra) # 800048a4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001380:	00005097          	auipc	ra,0x5
    80001384:	e72080e7          	jalr	-398(ra) # 800061f2 <virtio_disk_init>
    userinit();      // first user process
    80001388:	00001097          	auipc	ra,0x1
    8000138c:	c7a080e7          	jalr	-902(ra) # 80002002 <userinit>
    __sync_synchronize();
    80001390:	0ff0000f          	fence
    started = 1;
    80001394:	4785                	li	a5,1
    80001396:	00008717          	auipc	a4,0x8
    8000139a:	c6f72b23          	sw	a5,-906(a4) # 8000900c <started>
    8000139e:	bf2d                	j	800012d8 <main+0x56>

00000000800013a0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800013a0:	7139                	addi	sp,sp,-64
    800013a2:	fc06                	sd	ra,56(sp)
    800013a4:	f822                	sd	s0,48(sp)
    800013a6:	f426                	sd	s1,40(sp)
    800013a8:	f04a                	sd	s2,32(sp)
    800013aa:	ec4e                	sd	s3,24(sp)
    800013ac:	e852                	sd	s4,16(sp)
    800013ae:	e456                	sd	s5,8(sp)
    800013b0:	e05a                	sd	s6,0(sp)
    800013b2:	0080                	addi	s0,sp,64
    800013b4:	84aa                	mv	s1,a0
    800013b6:	89ae                	mv	s3,a1
    800013b8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800013ba:	57fd                	li	a5,-1
    800013bc:	83e9                	srli	a5,a5,0x1a
    800013be:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800013c0:	4b31                	li	s6,12
  if(va >= MAXVA)
    800013c2:	04b7f263          	bgeu	a5,a1,80001406 <walk+0x66>
    panic("walk");
    800013c6:	00007517          	auipc	a0,0x7
    800013ca:	da250513          	addi	a0,a0,-606 # 80008168 <digits+0x128>
    800013ce:	fffff097          	auipc	ra,0xfffff
    800013d2:	182080e7          	jalr	386(ra) # 80000550 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800013d6:	060a8663          	beqz	s5,80001442 <walk+0xa2>
    800013da:	fffff097          	auipc	ra,0xfffff
    800013de:	7a0080e7          	jalr	1952(ra) # 80000b7a <kalloc>
    800013e2:	84aa                	mv	s1,a0
    800013e4:	c529                	beqz	a0,8000142e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	ce6080e7          	jalr	-794(ra) # 800010d0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800013f2:	00c4d793          	srli	a5,s1,0xc
    800013f6:	07aa                	slli	a5,a5,0xa
    800013f8:	0017e793          	ori	a5,a5,1
    800013fc:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001400:	3a5d                	addiw	s4,s4,-9
    80001402:	036a0063          	beq	s4,s6,80001422 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001406:	0149d933          	srl	s2,s3,s4
    8000140a:	1ff97913          	andi	s2,s2,511
    8000140e:	090e                	slli	s2,s2,0x3
    80001410:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001412:	00093483          	ld	s1,0(s2)
    80001416:	0014f793          	andi	a5,s1,1
    8000141a:	dfd5                	beqz	a5,800013d6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000141c:	80a9                	srli	s1,s1,0xa
    8000141e:	04b2                	slli	s1,s1,0xc
    80001420:	b7c5                	j	80001400 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001422:	00c9d513          	srli	a0,s3,0xc
    80001426:	1ff57513          	andi	a0,a0,511
    8000142a:	050e                	slli	a0,a0,0x3
    8000142c:	9526                	add	a0,a0,s1
}
    8000142e:	70e2                	ld	ra,56(sp)
    80001430:	7442                	ld	s0,48(sp)
    80001432:	74a2                	ld	s1,40(sp)
    80001434:	7902                	ld	s2,32(sp)
    80001436:	69e2                	ld	s3,24(sp)
    80001438:	6a42                	ld	s4,16(sp)
    8000143a:	6aa2                	ld	s5,8(sp)
    8000143c:	6b02                	ld	s6,0(sp)
    8000143e:	6121                	addi	sp,sp,64
    80001440:	8082                	ret
        return 0;
    80001442:	4501                	li	a0,0
    80001444:	b7ed                	j	8000142e <walk+0x8e>

0000000080001446 <kvminithart>:
{
    80001446:	1141                	addi	sp,sp,-16
    80001448:	e422                	sd	s0,8(sp)
    8000144a:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000144c:	00008797          	auipc	a5,0x8
    80001450:	bc47b783          	ld	a5,-1084(a5) # 80009010 <kernel_pagetable>
    80001454:	83b1                	srli	a5,a5,0xc
    80001456:	577d                	li	a4,-1
    80001458:	177e                	slli	a4,a4,0x3f
    8000145a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000145c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001460:	12000073          	sfence.vma
}
    80001464:	6422                	ld	s0,8(sp)
    80001466:	0141                	addi	sp,sp,16
    80001468:	8082                	ret

000000008000146a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000146a:	57fd                	li	a5,-1
    8000146c:	83e9                	srli	a5,a5,0x1a
    8000146e:	00b7f463          	bgeu	a5,a1,80001476 <walkaddr+0xc>
    return 0;
    80001472:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001474:	8082                	ret
{
    80001476:	1141                	addi	sp,sp,-16
    80001478:	e406                	sd	ra,8(sp)
    8000147a:	e022                	sd	s0,0(sp)
    8000147c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000147e:	4601                	li	a2,0
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f20080e7          	jalr	-224(ra) # 800013a0 <walk>
  if(pte == 0)
    80001488:	c105                	beqz	a0,800014a8 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000148a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000148c:	0117f693          	andi	a3,a5,17
    80001490:	4745                	li	a4,17
    return 0;
    80001492:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001494:	00e68663          	beq	a3,a4,800014a0 <walkaddr+0x36>
}
    80001498:	60a2                	ld	ra,8(sp)
    8000149a:	6402                	ld	s0,0(sp)
    8000149c:	0141                	addi	sp,sp,16
    8000149e:	8082                	ret
  pa = PTE2PA(*pte);
    800014a0:	00a7d513          	srli	a0,a5,0xa
    800014a4:	0532                	slli	a0,a0,0xc
  return pa;
    800014a6:	bfcd                	j	80001498 <walkaddr+0x2e>
    return 0;
    800014a8:	4501                	li	a0,0
    800014aa:	b7fd                	j	80001498 <walkaddr+0x2e>

00000000800014ac <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800014ac:	715d                	addi	sp,sp,-80
    800014ae:	e486                	sd	ra,72(sp)
    800014b0:	e0a2                	sd	s0,64(sp)
    800014b2:	fc26                	sd	s1,56(sp)
    800014b4:	f84a                	sd	s2,48(sp)
    800014b6:	f44e                	sd	s3,40(sp)
    800014b8:	f052                	sd	s4,32(sp)
    800014ba:	ec56                	sd	s5,24(sp)
    800014bc:	e85a                	sd	s6,16(sp)
    800014be:	e45e                	sd	s7,8(sp)
    800014c0:	0880                	addi	s0,sp,80
    800014c2:	8aaa                	mv	s5,a0
    800014c4:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800014c6:	777d                	lui	a4,0xfffff
    800014c8:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800014cc:	167d                	addi	a2,a2,-1
    800014ce:	00b609b3          	add	s3,a2,a1
    800014d2:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800014d6:	893e                	mv	s2,a5
    800014d8:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800014dc:	6b85                	lui	s7,0x1
    800014de:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800014e2:	4605                	li	a2,1
    800014e4:	85ca                	mv	a1,s2
    800014e6:	8556                	mv	a0,s5
    800014e8:	00000097          	auipc	ra,0x0
    800014ec:	eb8080e7          	jalr	-328(ra) # 800013a0 <walk>
    800014f0:	c51d                	beqz	a0,8000151e <mappages+0x72>
    if(*pte & PTE_V)
    800014f2:	611c                	ld	a5,0(a0)
    800014f4:	8b85                	andi	a5,a5,1
    800014f6:	ef81                	bnez	a5,8000150e <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800014f8:	80b1                	srli	s1,s1,0xc
    800014fa:	04aa                	slli	s1,s1,0xa
    800014fc:	0164e4b3          	or	s1,s1,s6
    80001500:	0014e493          	ori	s1,s1,1
    80001504:	e104                	sd	s1,0(a0)
    if(a == last)
    80001506:	03390863          	beq	s2,s3,80001536 <mappages+0x8a>
    a += PGSIZE;
    8000150a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000150c:	bfc9                	j	800014de <mappages+0x32>
      panic("remap");
    8000150e:	00007517          	auipc	a0,0x7
    80001512:	c6250513          	addi	a0,a0,-926 # 80008170 <digits+0x130>
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	03a080e7          	jalr	58(ra) # 80000550 <panic>
      return -1;
    8000151e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001520:	60a6                	ld	ra,72(sp)
    80001522:	6406                	ld	s0,64(sp)
    80001524:	74e2                	ld	s1,56(sp)
    80001526:	7942                	ld	s2,48(sp)
    80001528:	79a2                	ld	s3,40(sp)
    8000152a:	7a02                	ld	s4,32(sp)
    8000152c:	6ae2                	ld	s5,24(sp)
    8000152e:	6b42                	ld	s6,16(sp)
    80001530:	6ba2                	ld	s7,8(sp)
    80001532:	6161                	addi	sp,sp,80
    80001534:	8082                	ret
  return 0;
    80001536:	4501                	li	a0,0
    80001538:	b7e5                	j	80001520 <mappages+0x74>

000000008000153a <kvmmap>:
{
    8000153a:	1141                	addi	sp,sp,-16
    8000153c:	e406                	sd	ra,8(sp)
    8000153e:	e022                	sd	s0,0(sp)
    80001540:	0800                	addi	s0,sp,16
    80001542:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001544:	86ae                	mv	a3,a1
    80001546:	85aa                	mv	a1,a0
    80001548:	00008517          	auipc	a0,0x8
    8000154c:	ac853503          	ld	a0,-1336(a0) # 80009010 <kernel_pagetable>
    80001550:	00000097          	auipc	ra,0x0
    80001554:	f5c080e7          	jalr	-164(ra) # 800014ac <mappages>
    80001558:	e509                	bnez	a0,80001562 <kvmmap+0x28>
}
    8000155a:	60a2                	ld	ra,8(sp)
    8000155c:	6402                	ld	s0,0(sp)
    8000155e:	0141                	addi	sp,sp,16
    80001560:	8082                	ret
    panic("kvmmap");
    80001562:	00007517          	auipc	a0,0x7
    80001566:	c1650513          	addi	a0,a0,-1002 # 80008178 <digits+0x138>
    8000156a:	fffff097          	auipc	ra,0xfffff
    8000156e:	fe6080e7          	jalr	-26(ra) # 80000550 <panic>

0000000080001572 <kvminit>:
{
    80001572:	1101                	addi	sp,sp,-32
    80001574:	ec06                	sd	ra,24(sp)
    80001576:	e822                	sd	s0,16(sp)
    80001578:	e426                	sd	s1,8(sp)
    8000157a:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    8000157c:	fffff097          	auipc	ra,0xfffff
    80001580:	5fe080e7          	jalr	1534(ra) # 80000b7a <kalloc>
    80001584:	00008797          	auipc	a5,0x8
    80001588:	a8a7b623          	sd	a0,-1396(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000158c:	6605                	lui	a2,0x1
    8000158e:	4581                	li	a1,0
    80001590:	00000097          	auipc	ra,0x0
    80001594:	b40080e7          	jalr	-1216(ra) # 800010d0 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001598:	4699                	li	a3,6
    8000159a:	6605                	lui	a2,0x1
    8000159c:	100005b7          	lui	a1,0x10000
    800015a0:	10000537          	lui	a0,0x10000
    800015a4:	00000097          	auipc	ra,0x0
    800015a8:	f96080e7          	jalr	-106(ra) # 8000153a <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800015ac:	4699                	li	a3,6
    800015ae:	6605                	lui	a2,0x1
    800015b0:	100015b7          	lui	a1,0x10001
    800015b4:	10001537          	lui	a0,0x10001
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	f82080e7          	jalr	-126(ra) # 8000153a <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800015c0:	4699                	li	a3,6
    800015c2:	00400637          	lui	a2,0x400
    800015c6:	0c0005b7          	lui	a1,0xc000
    800015ca:	0c000537          	lui	a0,0xc000
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	f6c080e7          	jalr	-148(ra) # 8000153a <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800015d6:	00007497          	auipc	s1,0x7
    800015da:	a2a48493          	addi	s1,s1,-1494 # 80008000 <etext>
    800015de:	46a9                	li	a3,10
    800015e0:	80007617          	auipc	a2,0x80007
    800015e4:	a2060613          	addi	a2,a2,-1504 # 8000 <_entry-0x7fff8000>
    800015e8:	4585                	li	a1,1
    800015ea:	05fe                	slli	a1,a1,0x1f
    800015ec:	852e                	mv	a0,a1
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	f4c080e7          	jalr	-180(ra) # 8000153a <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800015f6:	4699                	li	a3,6
    800015f8:	4645                	li	a2,17
    800015fa:	066e                	slli	a2,a2,0x1b
    800015fc:	8e05                	sub	a2,a2,s1
    800015fe:	85a6                	mv	a1,s1
    80001600:	8526                	mv	a0,s1
    80001602:	00000097          	auipc	ra,0x0
    80001606:	f38080e7          	jalr	-200(ra) # 8000153a <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000160a:	46a9                	li	a3,10
    8000160c:	6605                	lui	a2,0x1
    8000160e:	00006597          	auipc	a1,0x6
    80001612:	9f258593          	addi	a1,a1,-1550 # 80007000 <_trampoline>
    80001616:	04000537          	lui	a0,0x4000
    8000161a:	157d                	addi	a0,a0,-1
    8000161c:	0532                	slli	a0,a0,0xc
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	f1c080e7          	jalr	-228(ra) # 8000153a <kvmmap>
}
    80001626:	60e2                	ld	ra,24(sp)
    80001628:	6442                	ld	s0,16(sp)
    8000162a:	64a2                	ld	s1,8(sp)
    8000162c:	6105                	addi	sp,sp,32
    8000162e:	8082                	ret

0000000080001630 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001630:	715d                	addi	sp,sp,-80
    80001632:	e486                	sd	ra,72(sp)
    80001634:	e0a2                	sd	s0,64(sp)
    80001636:	fc26                	sd	s1,56(sp)
    80001638:	f84a                	sd	s2,48(sp)
    8000163a:	f44e                	sd	s3,40(sp)
    8000163c:	f052                	sd	s4,32(sp)
    8000163e:	ec56                	sd	s5,24(sp)
    80001640:	e85a                	sd	s6,16(sp)
    80001642:	e45e                	sd	s7,8(sp)
    80001644:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001646:	03459793          	slli	a5,a1,0x34
    8000164a:	e795                	bnez	a5,80001676 <uvmunmap+0x46>
    8000164c:	8a2a                	mv	s4,a0
    8000164e:	892e                	mv	s2,a1
    80001650:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001652:	0632                	slli	a2,a2,0xc
    80001654:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001658:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000165a:	6b05                	lui	s6,0x1
    8000165c:	0735e863          	bltu	a1,s3,800016cc <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001660:	60a6                	ld	ra,72(sp)
    80001662:	6406                	ld	s0,64(sp)
    80001664:	74e2                	ld	s1,56(sp)
    80001666:	7942                	ld	s2,48(sp)
    80001668:	79a2                	ld	s3,40(sp)
    8000166a:	7a02                	ld	s4,32(sp)
    8000166c:	6ae2                	ld	s5,24(sp)
    8000166e:	6b42                	ld	s6,16(sp)
    80001670:	6ba2                	ld	s7,8(sp)
    80001672:	6161                	addi	sp,sp,80
    80001674:	8082                	ret
    panic("uvmunmap: not aligned");
    80001676:	00007517          	auipc	a0,0x7
    8000167a:	b0a50513          	addi	a0,a0,-1270 # 80008180 <digits+0x140>
    8000167e:	fffff097          	auipc	ra,0xfffff
    80001682:	ed2080e7          	jalr	-302(ra) # 80000550 <panic>
      panic("uvmunmap: walk");
    80001686:	00007517          	auipc	a0,0x7
    8000168a:	b1250513          	addi	a0,a0,-1262 # 80008198 <digits+0x158>
    8000168e:	fffff097          	auipc	ra,0xfffff
    80001692:	ec2080e7          	jalr	-318(ra) # 80000550 <panic>
      panic("uvmunmap: not mapped");
    80001696:	00007517          	auipc	a0,0x7
    8000169a:	b1250513          	addi	a0,a0,-1262 # 800081a8 <digits+0x168>
    8000169e:	fffff097          	auipc	ra,0xfffff
    800016a2:	eb2080e7          	jalr	-334(ra) # 80000550 <panic>
      panic("uvmunmap: not a leaf");
    800016a6:	00007517          	auipc	a0,0x7
    800016aa:	b1a50513          	addi	a0,a0,-1254 # 800081c0 <digits+0x180>
    800016ae:	fffff097          	auipc	ra,0xfffff
    800016b2:	ea2080e7          	jalr	-350(ra) # 80000550 <panic>
      uint64 pa = PTE2PA(*pte);
    800016b6:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800016b8:	0532                	slli	a0,a0,0xc
    800016ba:	fffff097          	auipc	ra,0xfffff
    800016be:	372080e7          	jalr	882(ra) # 80000a2c <kfree>
    *pte = 0;
    800016c2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800016c6:	995a                	add	s2,s2,s6
    800016c8:	f9397ce3          	bgeu	s2,s3,80001660 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800016cc:	4601                	li	a2,0
    800016ce:	85ca                	mv	a1,s2
    800016d0:	8552                	mv	a0,s4
    800016d2:	00000097          	auipc	ra,0x0
    800016d6:	cce080e7          	jalr	-818(ra) # 800013a0 <walk>
    800016da:	84aa                	mv	s1,a0
    800016dc:	d54d                	beqz	a0,80001686 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800016de:	6108                	ld	a0,0(a0)
    800016e0:	00157793          	andi	a5,a0,1
    800016e4:	dbcd                	beqz	a5,80001696 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800016e6:	3ff57793          	andi	a5,a0,1023
    800016ea:	fb778ee3          	beq	a5,s7,800016a6 <uvmunmap+0x76>
    if(do_free){
    800016ee:	fc0a8ae3          	beqz	s5,800016c2 <uvmunmap+0x92>
    800016f2:	b7d1                	j	800016b6 <uvmunmap+0x86>

00000000800016f4 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800016f4:	1101                	addi	sp,sp,-32
    800016f6:	ec06                	sd	ra,24(sp)
    800016f8:	e822                	sd	s0,16(sp)
    800016fa:	e426                	sd	s1,8(sp)
    800016fc:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800016fe:	fffff097          	auipc	ra,0xfffff
    80001702:	47c080e7          	jalr	1148(ra) # 80000b7a <kalloc>
    80001706:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001708:	c519                	beqz	a0,80001716 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000170a:	6605                	lui	a2,0x1
    8000170c:	4581                	li	a1,0
    8000170e:	00000097          	auipc	ra,0x0
    80001712:	9c2080e7          	jalr	-1598(ra) # 800010d0 <memset>
  return pagetable;
}
    80001716:	8526                	mv	a0,s1
    80001718:	60e2                	ld	ra,24(sp)
    8000171a:	6442                	ld	s0,16(sp)
    8000171c:	64a2                	ld	s1,8(sp)
    8000171e:	6105                	addi	sp,sp,32
    80001720:	8082                	ret

0000000080001722 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001722:	7179                	addi	sp,sp,-48
    80001724:	f406                	sd	ra,40(sp)
    80001726:	f022                	sd	s0,32(sp)
    80001728:	ec26                	sd	s1,24(sp)
    8000172a:	e84a                	sd	s2,16(sp)
    8000172c:	e44e                	sd	s3,8(sp)
    8000172e:	e052                	sd	s4,0(sp)
    80001730:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001732:	6785                	lui	a5,0x1
    80001734:	04f67863          	bgeu	a2,a5,80001784 <uvminit+0x62>
    80001738:	8a2a                	mv	s4,a0
    8000173a:	89ae                	mv	s3,a1
    8000173c:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000173e:	fffff097          	auipc	ra,0xfffff
    80001742:	43c080e7          	jalr	1084(ra) # 80000b7a <kalloc>
    80001746:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001748:	6605                	lui	a2,0x1
    8000174a:	4581                	li	a1,0
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	984080e7          	jalr	-1660(ra) # 800010d0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001754:	4779                	li	a4,30
    80001756:	86ca                	mv	a3,s2
    80001758:	6605                	lui	a2,0x1
    8000175a:	4581                	li	a1,0
    8000175c:	8552                	mv	a0,s4
    8000175e:	00000097          	auipc	ra,0x0
    80001762:	d4e080e7          	jalr	-690(ra) # 800014ac <mappages>
  memmove(mem, src, sz);
    80001766:	8626                	mv	a2,s1
    80001768:	85ce                	mv	a1,s3
    8000176a:	854a                	mv	a0,s2
    8000176c:	00000097          	auipc	ra,0x0
    80001770:	9c4080e7          	jalr	-1596(ra) # 80001130 <memmove>
}
    80001774:	70a2                	ld	ra,40(sp)
    80001776:	7402                	ld	s0,32(sp)
    80001778:	64e2                	ld	s1,24(sp)
    8000177a:	6942                	ld	s2,16(sp)
    8000177c:	69a2                	ld	s3,8(sp)
    8000177e:	6a02                	ld	s4,0(sp)
    80001780:	6145                	addi	sp,sp,48
    80001782:	8082                	ret
    panic("inituvm: more than a page");
    80001784:	00007517          	auipc	a0,0x7
    80001788:	a5450513          	addi	a0,a0,-1452 # 800081d8 <digits+0x198>
    8000178c:	fffff097          	auipc	ra,0xfffff
    80001790:	dc4080e7          	jalr	-572(ra) # 80000550 <panic>

0000000080001794 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001794:	1101                	addi	sp,sp,-32
    80001796:	ec06                	sd	ra,24(sp)
    80001798:	e822                	sd	s0,16(sp)
    8000179a:	e426                	sd	s1,8(sp)
    8000179c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000179e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800017a0:	00b67d63          	bgeu	a2,a1,800017ba <uvmdealloc+0x26>
    800017a4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800017a6:	6785                	lui	a5,0x1
    800017a8:	17fd                	addi	a5,a5,-1
    800017aa:	00f60733          	add	a4,a2,a5
    800017ae:	767d                	lui	a2,0xfffff
    800017b0:	8f71                	and	a4,a4,a2
    800017b2:	97ae                	add	a5,a5,a1
    800017b4:	8ff1                	and	a5,a5,a2
    800017b6:	00f76863          	bltu	a4,a5,800017c6 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800017ba:	8526                	mv	a0,s1
    800017bc:	60e2                	ld	ra,24(sp)
    800017be:	6442                	ld	s0,16(sp)
    800017c0:	64a2                	ld	s1,8(sp)
    800017c2:	6105                	addi	sp,sp,32
    800017c4:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800017c6:	8f99                	sub	a5,a5,a4
    800017c8:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800017ca:	4685                	li	a3,1
    800017cc:	0007861b          	sext.w	a2,a5
    800017d0:	85ba                	mv	a1,a4
    800017d2:	00000097          	auipc	ra,0x0
    800017d6:	e5e080e7          	jalr	-418(ra) # 80001630 <uvmunmap>
    800017da:	b7c5                	j	800017ba <uvmdealloc+0x26>

00000000800017dc <uvmalloc>:
  if(newsz < oldsz)
    800017dc:	0ab66163          	bltu	a2,a1,8000187e <uvmalloc+0xa2>
{
    800017e0:	7139                	addi	sp,sp,-64
    800017e2:	fc06                	sd	ra,56(sp)
    800017e4:	f822                	sd	s0,48(sp)
    800017e6:	f426                	sd	s1,40(sp)
    800017e8:	f04a                	sd	s2,32(sp)
    800017ea:	ec4e                	sd	s3,24(sp)
    800017ec:	e852                	sd	s4,16(sp)
    800017ee:	e456                	sd	s5,8(sp)
    800017f0:	0080                	addi	s0,sp,64
    800017f2:	8aaa                	mv	s5,a0
    800017f4:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800017f6:	6985                	lui	s3,0x1
    800017f8:	19fd                	addi	s3,s3,-1
    800017fa:	95ce                	add	a1,a1,s3
    800017fc:	79fd                	lui	s3,0xfffff
    800017fe:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001802:	08c9f063          	bgeu	s3,a2,80001882 <uvmalloc+0xa6>
    80001806:	894e                	mv	s2,s3
    mem = kalloc();
    80001808:	fffff097          	auipc	ra,0xfffff
    8000180c:	372080e7          	jalr	882(ra) # 80000b7a <kalloc>
    80001810:	84aa                	mv	s1,a0
    if(mem == 0){
    80001812:	c51d                	beqz	a0,80001840 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001814:	6605                	lui	a2,0x1
    80001816:	4581                	li	a1,0
    80001818:	00000097          	auipc	ra,0x0
    8000181c:	8b8080e7          	jalr	-1864(ra) # 800010d0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001820:	4779                	li	a4,30
    80001822:	86a6                	mv	a3,s1
    80001824:	6605                	lui	a2,0x1
    80001826:	85ca                	mv	a1,s2
    80001828:	8556                	mv	a0,s5
    8000182a:	00000097          	auipc	ra,0x0
    8000182e:	c82080e7          	jalr	-894(ra) # 800014ac <mappages>
    80001832:	e905                	bnez	a0,80001862 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001834:	6785                	lui	a5,0x1
    80001836:	993e                	add	s2,s2,a5
    80001838:	fd4968e3          	bltu	s2,s4,80001808 <uvmalloc+0x2c>
  return newsz;
    8000183c:	8552                	mv	a0,s4
    8000183e:	a809                	j	80001850 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001840:	864e                	mv	a2,s3
    80001842:	85ca                	mv	a1,s2
    80001844:	8556                	mv	a0,s5
    80001846:	00000097          	auipc	ra,0x0
    8000184a:	f4e080e7          	jalr	-178(ra) # 80001794 <uvmdealloc>
      return 0;
    8000184e:	4501                	li	a0,0
}
    80001850:	70e2                	ld	ra,56(sp)
    80001852:	7442                	ld	s0,48(sp)
    80001854:	74a2                	ld	s1,40(sp)
    80001856:	7902                	ld	s2,32(sp)
    80001858:	69e2                	ld	s3,24(sp)
    8000185a:	6a42                	ld	s4,16(sp)
    8000185c:	6aa2                	ld	s5,8(sp)
    8000185e:	6121                	addi	sp,sp,64
    80001860:	8082                	ret
      kfree(mem);
    80001862:	8526                	mv	a0,s1
    80001864:	fffff097          	auipc	ra,0xfffff
    80001868:	1c8080e7          	jalr	456(ra) # 80000a2c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000186c:	864e                	mv	a2,s3
    8000186e:	85ca                	mv	a1,s2
    80001870:	8556                	mv	a0,s5
    80001872:	00000097          	auipc	ra,0x0
    80001876:	f22080e7          	jalr	-222(ra) # 80001794 <uvmdealloc>
      return 0;
    8000187a:	4501                	li	a0,0
    8000187c:	bfd1                	j	80001850 <uvmalloc+0x74>
    return oldsz;
    8000187e:	852e                	mv	a0,a1
}
    80001880:	8082                	ret
  return newsz;
    80001882:	8532                	mv	a0,a2
    80001884:	b7f1                	j	80001850 <uvmalloc+0x74>

0000000080001886 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001886:	7179                	addi	sp,sp,-48
    80001888:	f406                	sd	ra,40(sp)
    8000188a:	f022                	sd	s0,32(sp)
    8000188c:	ec26                	sd	s1,24(sp)
    8000188e:	e84a                	sd	s2,16(sp)
    80001890:	e44e                	sd	s3,8(sp)
    80001892:	e052                	sd	s4,0(sp)
    80001894:	1800                	addi	s0,sp,48
    80001896:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001898:	84aa                	mv	s1,a0
    8000189a:	6905                	lui	s2,0x1
    8000189c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000189e:	4985                	li	s3,1
    800018a0:	a821                	j	800018b8 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800018a2:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800018a4:	0532                	slli	a0,a0,0xc
    800018a6:	00000097          	auipc	ra,0x0
    800018aa:	fe0080e7          	jalr	-32(ra) # 80001886 <freewalk>
      pagetable[i] = 0;
    800018ae:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800018b2:	04a1                	addi	s1,s1,8
    800018b4:	03248163          	beq	s1,s2,800018d6 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800018b8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800018ba:	00f57793          	andi	a5,a0,15
    800018be:	ff3782e3          	beq	a5,s3,800018a2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800018c2:	8905                	andi	a0,a0,1
    800018c4:	d57d                	beqz	a0,800018b2 <freewalk+0x2c>
      panic("freewalk: leaf");
    800018c6:	00007517          	auipc	a0,0x7
    800018ca:	93250513          	addi	a0,a0,-1742 # 800081f8 <digits+0x1b8>
    800018ce:	fffff097          	auipc	ra,0xfffff
    800018d2:	c82080e7          	jalr	-894(ra) # 80000550 <panic>
    }
  }
  kfree((void*)pagetable);
    800018d6:	8552                	mv	a0,s4
    800018d8:	fffff097          	auipc	ra,0xfffff
    800018dc:	154080e7          	jalr	340(ra) # 80000a2c <kfree>
}
    800018e0:	70a2                	ld	ra,40(sp)
    800018e2:	7402                	ld	s0,32(sp)
    800018e4:	64e2                	ld	s1,24(sp)
    800018e6:	6942                	ld	s2,16(sp)
    800018e8:	69a2                	ld	s3,8(sp)
    800018ea:	6a02                	ld	s4,0(sp)
    800018ec:	6145                	addi	sp,sp,48
    800018ee:	8082                	ret

00000000800018f0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800018f0:	1101                	addi	sp,sp,-32
    800018f2:	ec06                	sd	ra,24(sp)
    800018f4:	e822                	sd	s0,16(sp)
    800018f6:	e426                	sd	s1,8(sp)
    800018f8:	1000                	addi	s0,sp,32
    800018fa:	84aa                	mv	s1,a0
  if(sz > 0)
    800018fc:	e999                	bnez	a1,80001912 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800018fe:	8526                	mv	a0,s1
    80001900:	00000097          	auipc	ra,0x0
    80001904:	f86080e7          	jalr	-122(ra) # 80001886 <freewalk>
}
    80001908:	60e2                	ld	ra,24(sp)
    8000190a:	6442                	ld	s0,16(sp)
    8000190c:	64a2                	ld	s1,8(sp)
    8000190e:	6105                	addi	sp,sp,32
    80001910:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001912:	6605                	lui	a2,0x1
    80001914:	167d                	addi	a2,a2,-1
    80001916:	962e                	add	a2,a2,a1
    80001918:	4685                	li	a3,1
    8000191a:	8231                	srli	a2,a2,0xc
    8000191c:	4581                	li	a1,0
    8000191e:	00000097          	auipc	ra,0x0
    80001922:	d12080e7          	jalr	-750(ra) # 80001630 <uvmunmap>
    80001926:	bfe1                	j	800018fe <uvmfree+0xe>

0000000080001928 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001928:	c679                	beqz	a2,800019f6 <uvmcopy+0xce>
{
    8000192a:	715d                	addi	sp,sp,-80
    8000192c:	e486                	sd	ra,72(sp)
    8000192e:	e0a2                	sd	s0,64(sp)
    80001930:	fc26                	sd	s1,56(sp)
    80001932:	f84a                	sd	s2,48(sp)
    80001934:	f44e                	sd	s3,40(sp)
    80001936:	f052                	sd	s4,32(sp)
    80001938:	ec56                	sd	s5,24(sp)
    8000193a:	e85a                	sd	s6,16(sp)
    8000193c:	e45e                	sd	s7,8(sp)
    8000193e:	0880                	addi	s0,sp,80
    80001940:	8b2a                	mv	s6,a0
    80001942:	8aae                	mv	s5,a1
    80001944:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001946:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001948:	4601                	li	a2,0
    8000194a:	85ce                	mv	a1,s3
    8000194c:	855a                	mv	a0,s6
    8000194e:	00000097          	auipc	ra,0x0
    80001952:	a52080e7          	jalr	-1454(ra) # 800013a0 <walk>
    80001956:	c531                	beqz	a0,800019a2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001958:	6118                	ld	a4,0(a0)
    8000195a:	00177793          	andi	a5,a4,1
    8000195e:	cbb1                	beqz	a5,800019b2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001960:	00a75593          	srli	a1,a4,0xa
    80001964:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001968:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000196c:	fffff097          	auipc	ra,0xfffff
    80001970:	20e080e7          	jalr	526(ra) # 80000b7a <kalloc>
    80001974:	892a                	mv	s2,a0
    80001976:	c939                	beqz	a0,800019cc <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001978:	6605                	lui	a2,0x1
    8000197a:	85de                	mv	a1,s7
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	7b4080e7          	jalr	1972(ra) # 80001130 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001984:	8726                	mv	a4,s1
    80001986:	86ca                	mv	a3,s2
    80001988:	6605                	lui	a2,0x1
    8000198a:	85ce                	mv	a1,s3
    8000198c:	8556                	mv	a0,s5
    8000198e:	00000097          	auipc	ra,0x0
    80001992:	b1e080e7          	jalr	-1250(ra) # 800014ac <mappages>
    80001996:	e515                	bnez	a0,800019c2 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001998:	6785                	lui	a5,0x1
    8000199a:	99be                	add	s3,s3,a5
    8000199c:	fb49e6e3          	bltu	s3,s4,80001948 <uvmcopy+0x20>
    800019a0:	a081                	j	800019e0 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800019a2:	00007517          	auipc	a0,0x7
    800019a6:	86650513          	addi	a0,a0,-1946 # 80008208 <digits+0x1c8>
    800019aa:	fffff097          	auipc	ra,0xfffff
    800019ae:	ba6080e7          	jalr	-1114(ra) # 80000550 <panic>
      panic("uvmcopy: page not present");
    800019b2:	00007517          	auipc	a0,0x7
    800019b6:	87650513          	addi	a0,a0,-1930 # 80008228 <digits+0x1e8>
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	b96080e7          	jalr	-1130(ra) # 80000550 <panic>
      kfree(mem);
    800019c2:	854a                	mv	a0,s2
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	068080e7          	jalr	104(ra) # 80000a2c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800019cc:	4685                	li	a3,1
    800019ce:	00c9d613          	srli	a2,s3,0xc
    800019d2:	4581                	li	a1,0
    800019d4:	8556                	mv	a0,s5
    800019d6:	00000097          	auipc	ra,0x0
    800019da:	c5a080e7          	jalr	-934(ra) # 80001630 <uvmunmap>
  return -1;
    800019de:	557d                	li	a0,-1
}
    800019e0:	60a6                	ld	ra,72(sp)
    800019e2:	6406                	ld	s0,64(sp)
    800019e4:	74e2                	ld	s1,56(sp)
    800019e6:	7942                	ld	s2,48(sp)
    800019e8:	79a2                	ld	s3,40(sp)
    800019ea:	7a02                	ld	s4,32(sp)
    800019ec:	6ae2                	ld	s5,24(sp)
    800019ee:	6b42                	ld	s6,16(sp)
    800019f0:	6ba2                	ld	s7,8(sp)
    800019f2:	6161                	addi	sp,sp,80
    800019f4:	8082                	ret
  return 0;
    800019f6:	4501                	li	a0,0
}
    800019f8:	8082                	ret

00000000800019fa <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800019fa:	1141                	addi	sp,sp,-16
    800019fc:	e406                	sd	ra,8(sp)
    800019fe:	e022                	sd	s0,0(sp)
    80001a00:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001a02:	4601                	li	a2,0
    80001a04:	00000097          	auipc	ra,0x0
    80001a08:	99c080e7          	jalr	-1636(ra) # 800013a0 <walk>
  if(pte == 0)
    80001a0c:	c901                	beqz	a0,80001a1c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001a0e:	611c                	ld	a5,0(a0)
    80001a10:	9bbd                	andi	a5,a5,-17
    80001a12:	e11c                	sd	a5,0(a0)
}
    80001a14:	60a2                	ld	ra,8(sp)
    80001a16:	6402                	ld	s0,0(sp)
    80001a18:	0141                	addi	sp,sp,16
    80001a1a:	8082                	ret
    panic("uvmclear");
    80001a1c:	00007517          	auipc	a0,0x7
    80001a20:	82c50513          	addi	a0,a0,-2004 # 80008248 <digits+0x208>
    80001a24:	fffff097          	auipc	ra,0xfffff
    80001a28:	b2c080e7          	jalr	-1236(ra) # 80000550 <panic>

0000000080001a2c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001a2c:	c6bd                	beqz	a3,80001a9a <copyout+0x6e>
{
    80001a2e:	715d                	addi	sp,sp,-80
    80001a30:	e486                	sd	ra,72(sp)
    80001a32:	e0a2                	sd	s0,64(sp)
    80001a34:	fc26                	sd	s1,56(sp)
    80001a36:	f84a                	sd	s2,48(sp)
    80001a38:	f44e                	sd	s3,40(sp)
    80001a3a:	f052                	sd	s4,32(sp)
    80001a3c:	ec56                	sd	s5,24(sp)
    80001a3e:	e85a                	sd	s6,16(sp)
    80001a40:	e45e                	sd	s7,8(sp)
    80001a42:	e062                	sd	s8,0(sp)
    80001a44:	0880                	addi	s0,sp,80
    80001a46:	8b2a                	mv	s6,a0
    80001a48:	8c2e                	mv	s8,a1
    80001a4a:	8a32                	mv	s4,a2
    80001a4c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001a4e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001a50:	6a85                	lui	s5,0x1
    80001a52:	a015                	j	80001a76 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001a54:	9562                	add	a0,a0,s8
    80001a56:	0004861b          	sext.w	a2,s1
    80001a5a:	85d2                	mv	a1,s4
    80001a5c:	41250533          	sub	a0,a0,s2
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	6d0080e7          	jalr	1744(ra) # 80001130 <memmove>

    len -= n;
    80001a68:	409989b3          	sub	s3,s3,s1
    src += n;
    80001a6c:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001a6e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001a72:	02098263          	beqz	s3,80001a96 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001a76:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a7a:	85ca                	mv	a1,s2
    80001a7c:	855a                	mv	a0,s6
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	9ec080e7          	jalr	-1556(ra) # 8000146a <walkaddr>
    if(pa0 == 0)
    80001a86:	cd01                	beqz	a0,80001a9e <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001a88:	418904b3          	sub	s1,s2,s8
    80001a8c:	94d6                	add	s1,s1,s5
    if(n > len)
    80001a8e:	fc99f3e3          	bgeu	s3,s1,80001a54 <copyout+0x28>
    80001a92:	84ce                	mv	s1,s3
    80001a94:	b7c1                	j	80001a54 <copyout+0x28>
  }
  return 0;
    80001a96:	4501                	li	a0,0
    80001a98:	a021                	j	80001aa0 <copyout+0x74>
    80001a9a:	4501                	li	a0,0
}
    80001a9c:	8082                	ret
      return -1;
    80001a9e:	557d                	li	a0,-1
}
    80001aa0:	60a6                	ld	ra,72(sp)
    80001aa2:	6406                	ld	s0,64(sp)
    80001aa4:	74e2                	ld	s1,56(sp)
    80001aa6:	7942                	ld	s2,48(sp)
    80001aa8:	79a2                	ld	s3,40(sp)
    80001aaa:	7a02                	ld	s4,32(sp)
    80001aac:	6ae2                	ld	s5,24(sp)
    80001aae:	6b42                	ld	s6,16(sp)
    80001ab0:	6ba2                	ld	s7,8(sp)
    80001ab2:	6c02                	ld	s8,0(sp)
    80001ab4:	6161                	addi	sp,sp,80
    80001ab6:	8082                	ret

0000000080001ab8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001ab8:	c6bd                	beqz	a3,80001b26 <copyin+0x6e>
{
    80001aba:	715d                	addi	sp,sp,-80
    80001abc:	e486                	sd	ra,72(sp)
    80001abe:	e0a2                	sd	s0,64(sp)
    80001ac0:	fc26                	sd	s1,56(sp)
    80001ac2:	f84a                	sd	s2,48(sp)
    80001ac4:	f44e                	sd	s3,40(sp)
    80001ac6:	f052                	sd	s4,32(sp)
    80001ac8:	ec56                	sd	s5,24(sp)
    80001aca:	e85a                	sd	s6,16(sp)
    80001acc:	e45e                	sd	s7,8(sp)
    80001ace:	e062                	sd	s8,0(sp)
    80001ad0:	0880                	addi	s0,sp,80
    80001ad2:	8b2a                	mv	s6,a0
    80001ad4:	8a2e                	mv	s4,a1
    80001ad6:	8c32                	mv	s8,a2
    80001ad8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001ada:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001adc:	6a85                	lui	s5,0x1
    80001ade:	a015                	j	80001b02 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001ae0:	9562                	add	a0,a0,s8
    80001ae2:	0004861b          	sext.w	a2,s1
    80001ae6:	412505b3          	sub	a1,a0,s2
    80001aea:	8552                	mv	a0,s4
    80001aec:	fffff097          	auipc	ra,0xfffff
    80001af0:	644080e7          	jalr	1604(ra) # 80001130 <memmove>

    len -= n;
    80001af4:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001af8:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001afa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001afe:	02098263          	beqz	s3,80001b22 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001b02:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001b06:	85ca                	mv	a1,s2
    80001b08:	855a                	mv	a0,s6
    80001b0a:	00000097          	auipc	ra,0x0
    80001b0e:	960080e7          	jalr	-1696(ra) # 8000146a <walkaddr>
    if(pa0 == 0)
    80001b12:	cd01                	beqz	a0,80001b2a <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001b14:	418904b3          	sub	s1,s2,s8
    80001b18:	94d6                	add	s1,s1,s5
    if(n > len)
    80001b1a:	fc99f3e3          	bgeu	s3,s1,80001ae0 <copyin+0x28>
    80001b1e:	84ce                	mv	s1,s3
    80001b20:	b7c1                	j	80001ae0 <copyin+0x28>
  }
  return 0;
    80001b22:	4501                	li	a0,0
    80001b24:	a021                	j	80001b2c <copyin+0x74>
    80001b26:	4501                	li	a0,0
}
    80001b28:	8082                	ret
      return -1;
    80001b2a:	557d                	li	a0,-1
}
    80001b2c:	60a6                	ld	ra,72(sp)
    80001b2e:	6406                	ld	s0,64(sp)
    80001b30:	74e2                	ld	s1,56(sp)
    80001b32:	7942                	ld	s2,48(sp)
    80001b34:	79a2                	ld	s3,40(sp)
    80001b36:	7a02                	ld	s4,32(sp)
    80001b38:	6ae2                	ld	s5,24(sp)
    80001b3a:	6b42                	ld	s6,16(sp)
    80001b3c:	6ba2                	ld	s7,8(sp)
    80001b3e:	6c02                	ld	s8,0(sp)
    80001b40:	6161                	addi	sp,sp,80
    80001b42:	8082                	ret

0000000080001b44 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001b44:	c6c5                	beqz	a3,80001bec <copyinstr+0xa8>
{
    80001b46:	715d                	addi	sp,sp,-80
    80001b48:	e486                	sd	ra,72(sp)
    80001b4a:	e0a2                	sd	s0,64(sp)
    80001b4c:	fc26                	sd	s1,56(sp)
    80001b4e:	f84a                	sd	s2,48(sp)
    80001b50:	f44e                	sd	s3,40(sp)
    80001b52:	f052                	sd	s4,32(sp)
    80001b54:	ec56                	sd	s5,24(sp)
    80001b56:	e85a                	sd	s6,16(sp)
    80001b58:	e45e                	sd	s7,8(sp)
    80001b5a:	0880                	addi	s0,sp,80
    80001b5c:	8a2a                	mv	s4,a0
    80001b5e:	8b2e                	mv	s6,a1
    80001b60:	8bb2                	mv	s7,a2
    80001b62:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001b64:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001b66:	6985                	lui	s3,0x1
    80001b68:	a035                	j	80001b94 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001b6a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001b6e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001b70:	0017b793          	seqz	a5,a5
    80001b74:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001b78:	60a6                	ld	ra,72(sp)
    80001b7a:	6406                	ld	s0,64(sp)
    80001b7c:	74e2                	ld	s1,56(sp)
    80001b7e:	7942                	ld	s2,48(sp)
    80001b80:	79a2                	ld	s3,40(sp)
    80001b82:	7a02                	ld	s4,32(sp)
    80001b84:	6ae2                	ld	s5,24(sp)
    80001b86:	6b42                	ld	s6,16(sp)
    80001b88:	6ba2                	ld	s7,8(sp)
    80001b8a:	6161                	addi	sp,sp,80
    80001b8c:	8082                	ret
    srcva = va0 + PGSIZE;
    80001b8e:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001b92:	c8a9                	beqz	s1,80001be4 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001b94:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001b98:	85ca                	mv	a1,s2
    80001b9a:	8552                	mv	a0,s4
    80001b9c:	00000097          	auipc	ra,0x0
    80001ba0:	8ce080e7          	jalr	-1842(ra) # 8000146a <walkaddr>
    if(pa0 == 0)
    80001ba4:	c131                	beqz	a0,80001be8 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001ba6:	41790833          	sub	a6,s2,s7
    80001baa:	984e                	add	a6,a6,s3
    if(n > max)
    80001bac:	0104f363          	bgeu	s1,a6,80001bb2 <copyinstr+0x6e>
    80001bb0:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001bb2:	955e                	add	a0,a0,s7
    80001bb4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001bb8:	fc080be3          	beqz	a6,80001b8e <copyinstr+0x4a>
    80001bbc:	985a                	add	a6,a6,s6
    80001bbe:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001bc0:	41650633          	sub	a2,a0,s6
    80001bc4:	14fd                	addi	s1,s1,-1
    80001bc6:	9b26                	add	s6,s6,s1
    80001bc8:	00f60733          	add	a4,a2,a5
    80001bcc:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd2fd8>
    80001bd0:	df49                	beqz	a4,80001b6a <copyinstr+0x26>
        *dst = *p;
    80001bd2:	00e78023          	sb	a4,0(a5)
      --max;
    80001bd6:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001bda:	0785                	addi	a5,a5,1
    while(n > 0){
    80001bdc:	ff0796e3          	bne	a5,a6,80001bc8 <copyinstr+0x84>
      dst++;
    80001be0:	8b42                	mv	s6,a6
    80001be2:	b775                	j	80001b8e <copyinstr+0x4a>
    80001be4:	4781                	li	a5,0
    80001be6:	b769                	j	80001b70 <copyinstr+0x2c>
      return -1;
    80001be8:	557d                	li	a0,-1
    80001bea:	b779                	j	80001b78 <copyinstr+0x34>
  int got_null = 0;
    80001bec:	4781                	li	a5,0
  if(got_null){
    80001bee:	0017b793          	seqz	a5,a5
    80001bf2:	40f00533          	neg	a0,a5
}
    80001bf6:	8082                	ret

0000000080001bf8 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001bf8:	1101                	addi	sp,sp,-32
    80001bfa:	ec06                	sd	ra,24(sp)
    80001bfc:	e822                	sd	s0,16(sp)
    80001bfe:	e426                	sd	s1,8(sp)
    80001c00:	1000                	addi	s0,sp,32
    80001c02:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	072080e7          	jalr	114(ra) # 80000c76 <holding>
    80001c0c:	c909                	beqz	a0,80001c1e <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001c0e:	789c                	ld	a5,48(s1)
    80001c10:	00978f63          	beq	a5,s1,80001c2e <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001c14:	60e2                	ld	ra,24(sp)
    80001c16:	6442                	ld	s0,16(sp)
    80001c18:	64a2                	ld	s1,8(sp)
    80001c1a:	6105                	addi	sp,sp,32
    80001c1c:	8082                	ret
    panic("wakeup1");
    80001c1e:	00006517          	auipc	a0,0x6
    80001c22:	63a50513          	addi	a0,a0,1594 # 80008258 <digits+0x218>
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	92a080e7          	jalr	-1750(ra) # 80000550 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001c2e:	5098                	lw	a4,32(s1)
    80001c30:	4785                	li	a5,1
    80001c32:	fef711e3          	bne	a4,a5,80001c14 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001c36:	4789                	li	a5,2
    80001c38:	d09c                	sw	a5,32(s1)
}
    80001c3a:	bfe9                	j	80001c14 <wakeup1+0x1c>

0000000080001c3c <procinit>:
{
    80001c3c:	715d                	addi	sp,sp,-80
    80001c3e:	e486                	sd	ra,72(sp)
    80001c40:	e0a2                	sd	s0,64(sp)
    80001c42:	fc26                	sd	s1,56(sp)
    80001c44:	f84a                	sd	s2,48(sp)
    80001c46:	f44e                	sd	s3,40(sp)
    80001c48:	f052                	sd	s4,32(sp)
    80001c4a:	ec56                	sd	s5,24(sp)
    80001c4c:	e85a                	sd	s6,16(sp)
    80001c4e:	e45e                	sd	s7,8(sp)
    80001c50:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001c52:	00006597          	auipc	a1,0x6
    80001c56:	60e58593          	addi	a1,a1,1550 # 80008260 <digits+0x220>
    80001c5a:	00010517          	auipc	a0,0x10
    80001c5e:	75650513          	addi	a0,a0,1878 # 800123b0 <pid_lock>
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	20a080e7          	jalr	522(ra) # 80000e6c <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c6a:	00011917          	auipc	s2,0x11
    80001c6e:	b6690913          	addi	s2,s2,-1178 # 800127d0 <proc>
      initlock(&p->lock, "proc");
    80001c72:	00006b97          	auipc	s7,0x6
    80001c76:	5f6b8b93          	addi	s7,s7,1526 # 80008268 <digits+0x228>
      uint64 va = KSTACK((int) (p - proc));
    80001c7a:	8b4a                	mv	s6,s2
    80001c7c:	00006a97          	auipc	s5,0x6
    80001c80:	384a8a93          	addi	s5,s5,900 # 80008000 <etext>
    80001c84:	040009b7          	lui	s3,0x4000
    80001c88:	19fd                	addi	s3,s3,-1
    80001c8a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c8c:	00016a17          	auipc	s4,0x16
    80001c90:	744a0a13          	addi	s4,s4,1860 # 800183d0 <tickslock>
      initlock(&p->lock, "proc");
    80001c94:	85de                	mv	a1,s7
    80001c96:	854a                	mv	a0,s2
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	1d4080e7          	jalr	468(ra) # 80000e6c <initlock>
      char *pa = kalloc();
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	eda080e7          	jalr	-294(ra) # 80000b7a <kalloc>
    80001ca8:	85aa                	mv	a1,a0
      if(pa == 0)
    80001caa:	c929                	beqz	a0,80001cfc <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001cac:	416904b3          	sub	s1,s2,s6
    80001cb0:	8491                	srai	s1,s1,0x4
    80001cb2:	000ab783          	ld	a5,0(s5)
    80001cb6:	02f484b3          	mul	s1,s1,a5
    80001cba:	2485                	addiw	s1,s1,1
    80001cbc:	00d4949b          	slliw	s1,s1,0xd
    80001cc0:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001cc4:	4699                	li	a3,6
    80001cc6:	6605                	lui	a2,0x1
    80001cc8:	8526                	mv	a0,s1
    80001cca:	00000097          	auipc	ra,0x0
    80001cce:	870080e7          	jalr	-1936(ra) # 8000153a <kvmmap>
      p->kstack = va;
    80001cd2:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cd6:	17090913          	addi	s2,s2,368
    80001cda:	fb491de3          	bne	s2,s4,80001c94 <procinit+0x58>
  kvminithart();
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	768080e7          	jalr	1896(ra) # 80001446 <kvminithart>
}
    80001ce6:	60a6                	ld	ra,72(sp)
    80001ce8:	6406                	ld	s0,64(sp)
    80001cea:	74e2                	ld	s1,56(sp)
    80001cec:	7942                	ld	s2,48(sp)
    80001cee:	79a2                	ld	s3,40(sp)
    80001cf0:	7a02                	ld	s4,32(sp)
    80001cf2:	6ae2                	ld	s5,24(sp)
    80001cf4:	6b42                	ld	s6,16(sp)
    80001cf6:	6ba2                	ld	s7,8(sp)
    80001cf8:	6161                	addi	sp,sp,80
    80001cfa:	8082                	ret
        panic("kalloc");
    80001cfc:	00006517          	auipc	a0,0x6
    80001d00:	57450513          	addi	a0,a0,1396 # 80008270 <digits+0x230>
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	84c080e7          	jalr	-1972(ra) # 80000550 <panic>

0000000080001d0c <cpuid>:
{
    80001d0c:	1141                	addi	sp,sp,-16
    80001d0e:	e422                	sd	s0,8(sp)
    80001d10:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d12:	8512                	mv	a0,tp
}
    80001d14:	2501                	sext.w	a0,a0
    80001d16:	6422                	ld	s0,8(sp)
    80001d18:	0141                	addi	sp,sp,16
    80001d1a:	8082                	ret

0000000080001d1c <mycpu>:
mycpu(void) {
    80001d1c:	1141                	addi	sp,sp,-16
    80001d1e:	e422                	sd	s0,8(sp)
    80001d20:	0800                	addi	s0,sp,16
    80001d22:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001d24:	2781                	sext.w	a5,a5
    80001d26:	079e                	slli	a5,a5,0x7
}
    80001d28:	00010517          	auipc	a0,0x10
    80001d2c:	6a850513          	addi	a0,a0,1704 # 800123d0 <cpus>
    80001d30:	953e                	add	a0,a0,a5
    80001d32:	6422                	ld	s0,8(sp)
    80001d34:	0141                	addi	sp,sp,16
    80001d36:	8082                	ret

0000000080001d38 <myproc>:
myproc(void) {
    80001d38:	1101                	addi	sp,sp,-32
    80001d3a:	ec06                	sd	ra,24(sp)
    80001d3c:	e822                	sd	s0,16(sp)
    80001d3e:	e426                	sd	s1,8(sp)
    80001d40:	1000                	addi	s0,sp,32
  push_off();
    80001d42:	fffff097          	auipc	ra,0xfffff
    80001d46:	f62080e7          	jalr	-158(ra) # 80000ca4 <push_off>
    80001d4a:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001d4c:	2781                	sext.w	a5,a5
    80001d4e:	079e                	slli	a5,a5,0x7
    80001d50:	00010717          	auipc	a4,0x10
    80001d54:	66070713          	addi	a4,a4,1632 # 800123b0 <pid_lock>
    80001d58:	97ba                	add	a5,a5,a4
    80001d5a:	7384                	ld	s1,32(a5)
  pop_off();
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	004080e7          	jalr	4(ra) # 80000d60 <pop_off>
}
    80001d64:	8526                	mv	a0,s1
    80001d66:	60e2                	ld	ra,24(sp)
    80001d68:	6442                	ld	s0,16(sp)
    80001d6a:	64a2                	ld	s1,8(sp)
    80001d6c:	6105                	addi	sp,sp,32
    80001d6e:	8082                	ret

0000000080001d70 <forkret>:
{
    80001d70:	1141                	addi	sp,sp,-16
    80001d72:	e406                	sd	ra,8(sp)
    80001d74:	e022                	sd	s0,0(sp)
    80001d76:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001d78:	00000097          	auipc	ra,0x0
    80001d7c:	fc0080e7          	jalr	-64(ra) # 80001d38 <myproc>
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	040080e7          	jalr	64(ra) # 80000dc0 <release>
  if (first) {
    80001d88:	00007797          	auipc	a5,0x7
    80001d8c:	b187a783          	lw	a5,-1256(a5) # 800088a0 <first.1672>
    80001d90:	eb89                	bnez	a5,80001da2 <forkret+0x32>
  usertrapret();
    80001d92:	00001097          	auipc	ra,0x1
    80001d96:	c1c080e7          	jalr	-996(ra) # 800029ae <usertrapret>
}
    80001d9a:	60a2                	ld	ra,8(sp)
    80001d9c:	6402                	ld	s0,0(sp)
    80001d9e:	0141                	addi	sp,sp,16
    80001da0:	8082                	ret
    first = 0;
    80001da2:	00007797          	auipc	a5,0x7
    80001da6:	ae07af23          	sw	zero,-1282(a5) # 800088a0 <first.1672>
    fsinit(ROOTDEV);
    80001daa:	4505                	li	a0,1
    80001dac:	00002097          	auipc	ra,0x2
    80001db0:	ac0080e7          	jalr	-1344(ra) # 8000386c <fsinit>
    80001db4:	bff9                	j	80001d92 <forkret+0x22>

0000000080001db6 <allocpid>:
allocpid() {
    80001db6:	1101                	addi	sp,sp,-32
    80001db8:	ec06                	sd	ra,24(sp)
    80001dba:	e822                	sd	s0,16(sp)
    80001dbc:	e426                	sd	s1,8(sp)
    80001dbe:	e04a                	sd	s2,0(sp)
    80001dc0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001dc2:	00010917          	auipc	s2,0x10
    80001dc6:	5ee90913          	addi	s2,s2,1518 # 800123b0 <pid_lock>
    80001dca:	854a                	mv	a0,s2
    80001dcc:	fffff097          	auipc	ra,0xfffff
    80001dd0:	f24080e7          	jalr	-220(ra) # 80000cf0 <acquire>
  pid = nextpid;
    80001dd4:	00007797          	auipc	a5,0x7
    80001dd8:	ad078793          	addi	a5,a5,-1328 # 800088a4 <nextpid>
    80001ddc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001dde:	0014871b          	addiw	a4,s1,1
    80001de2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001de4:	854a                	mv	a0,s2
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	fda080e7          	jalr	-38(ra) # 80000dc0 <release>
}
    80001dee:	8526                	mv	a0,s1
    80001df0:	60e2                	ld	ra,24(sp)
    80001df2:	6442                	ld	s0,16(sp)
    80001df4:	64a2                	ld	s1,8(sp)
    80001df6:	6902                	ld	s2,0(sp)
    80001df8:	6105                	addi	sp,sp,32
    80001dfa:	8082                	ret

0000000080001dfc <proc_pagetable>:
{
    80001dfc:	1101                	addi	sp,sp,-32
    80001dfe:	ec06                	sd	ra,24(sp)
    80001e00:	e822                	sd	s0,16(sp)
    80001e02:	e426                	sd	s1,8(sp)
    80001e04:	e04a                	sd	s2,0(sp)
    80001e06:	1000                	addi	s0,sp,32
    80001e08:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e0a:	00000097          	auipc	ra,0x0
    80001e0e:	8ea080e7          	jalr	-1814(ra) # 800016f4 <uvmcreate>
    80001e12:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e14:	c121                	beqz	a0,80001e54 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e16:	4729                	li	a4,10
    80001e18:	00005697          	auipc	a3,0x5
    80001e1c:	1e868693          	addi	a3,a3,488 # 80007000 <_trampoline>
    80001e20:	6605                	lui	a2,0x1
    80001e22:	040005b7          	lui	a1,0x4000
    80001e26:	15fd                	addi	a1,a1,-1
    80001e28:	05b2                	slli	a1,a1,0xc
    80001e2a:	fffff097          	auipc	ra,0xfffff
    80001e2e:	682080e7          	jalr	1666(ra) # 800014ac <mappages>
    80001e32:	02054863          	bltz	a0,80001e62 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e36:	4719                	li	a4,6
    80001e38:	06093683          	ld	a3,96(s2)
    80001e3c:	6605                	lui	a2,0x1
    80001e3e:	020005b7          	lui	a1,0x2000
    80001e42:	15fd                	addi	a1,a1,-1
    80001e44:	05b6                	slli	a1,a1,0xd
    80001e46:	8526                	mv	a0,s1
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	664080e7          	jalr	1636(ra) # 800014ac <mappages>
    80001e50:	02054163          	bltz	a0,80001e72 <proc_pagetable+0x76>
}
    80001e54:	8526                	mv	a0,s1
    80001e56:	60e2                	ld	ra,24(sp)
    80001e58:	6442                	ld	s0,16(sp)
    80001e5a:	64a2                	ld	s1,8(sp)
    80001e5c:	6902                	ld	s2,0(sp)
    80001e5e:	6105                	addi	sp,sp,32
    80001e60:	8082                	ret
    uvmfree(pagetable, 0);
    80001e62:	4581                	li	a1,0
    80001e64:	8526                	mv	a0,s1
    80001e66:	00000097          	auipc	ra,0x0
    80001e6a:	a8a080e7          	jalr	-1398(ra) # 800018f0 <uvmfree>
    return 0;
    80001e6e:	4481                	li	s1,0
    80001e70:	b7d5                	j	80001e54 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e72:	4681                	li	a3,0
    80001e74:	4605                	li	a2,1
    80001e76:	040005b7          	lui	a1,0x4000
    80001e7a:	15fd                	addi	a1,a1,-1
    80001e7c:	05b2                	slli	a1,a1,0xc
    80001e7e:	8526                	mv	a0,s1
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	7b0080e7          	jalr	1968(ra) # 80001630 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e88:	4581                	li	a1,0
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	00000097          	auipc	ra,0x0
    80001e90:	a64080e7          	jalr	-1436(ra) # 800018f0 <uvmfree>
    return 0;
    80001e94:	4481                	li	s1,0
    80001e96:	bf7d                	j	80001e54 <proc_pagetable+0x58>

0000000080001e98 <proc_freepagetable>:
{
    80001e98:	1101                	addi	sp,sp,-32
    80001e9a:	ec06                	sd	ra,24(sp)
    80001e9c:	e822                	sd	s0,16(sp)
    80001e9e:	e426                	sd	s1,8(sp)
    80001ea0:	e04a                	sd	s2,0(sp)
    80001ea2:	1000                	addi	s0,sp,32
    80001ea4:	84aa                	mv	s1,a0
    80001ea6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ea8:	4681                	li	a3,0
    80001eaa:	4605                	li	a2,1
    80001eac:	040005b7          	lui	a1,0x4000
    80001eb0:	15fd                	addi	a1,a1,-1
    80001eb2:	05b2                	slli	a1,a1,0xc
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	77c080e7          	jalr	1916(ra) # 80001630 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ebc:	4681                	li	a3,0
    80001ebe:	4605                	li	a2,1
    80001ec0:	020005b7          	lui	a1,0x2000
    80001ec4:	15fd                	addi	a1,a1,-1
    80001ec6:	05b6                	slli	a1,a1,0xd
    80001ec8:	8526                	mv	a0,s1
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	766080e7          	jalr	1894(ra) # 80001630 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ed2:	85ca                	mv	a1,s2
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	00000097          	auipc	ra,0x0
    80001eda:	a1a080e7          	jalr	-1510(ra) # 800018f0 <uvmfree>
}
    80001ede:	60e2                	ld	ra,24(sp)
    80001ee0:	6442                	ld	s0,16(sp)
    80001ee2:	64a2                	ld	s1,8(sp)
    80001ee4:	6902                	ld	s2,0(sp)
    80001ee6:	6105                	addi	sp,sp,32
    80001ee8:	8082                	ret

0000000080001eea <freeproc>:
{
    80001eea:	1101                	addi	sp,sp,-32
    80001eec:	ec06                	sd	ra,24(sp)
    80001eee:	e822                	sd	s0,16(sp)
    80001ef0:	e426                	sd	s1,8(sp)
    80001ef2:	1000                	addi	s0,sp,32
    80001ef4:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ef6:	7128                	ld	a0,96(a0)
    80001ef8:	c509                	beqz	a0,80001f02 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	b32080e7          	jalr	-1230(ra) # 80000a2c <kfree>
  p->trapframe = 0;
    80001f02:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001f06:	6ca8                	ld	a0,88(s1)
    80001f08:	c511                	beqz	a0,80001f14 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f0a:	68ac                	ld	a1,80(s1)
    80001f0c:	00000097          	auipc	ra,0x0
    80001f10:	f8c080e7          	jalr	-116(ra) # 80001e98 <proc_freepagetable>
  p->pagetable = 0;
    80001f14:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001f18:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001f1c:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001f20:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001f24:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001f28:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001f2c:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001f30:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001f34:	0204a023          	sw	zero,32(s1)
}
    80001f38:	60e2                	ld	ra,24(sp)
    80001f3a:	6442                	ld	s0,16(sp)
    80001f3c:	64a2                	ld	s1,8(sp)
    80001f3e:	6105                	addi	sp,sp,32
    80001f40:	8082                	ret

0000000080001f42 <allocproc>:
{
    80001f42:	1101                	addi	sp,sp,-32
    80001f44:	ec06                	sd	ra,24(sp)
    80001f46:	e822                	sd	s0,16(sp)
    80001f48:	e426                	sd	s1,8(sp)
    80001f4a:	e04a                	sd	s2,0(sp)
    80001f4c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f4e:	00011497          	auipc	s1,0x11
    80001f52:	88248493          	addi	s1,s1,-1918 # 800127d0 <proc>
    80001f56:	00016917          	auipc	s2,0x16
    80001f5a:	47a90913          	addi	s2,s2,1146 # 800183d0 <tickslock>
    acquire(&p->lock);
    80001f5e:	8526                	mv	a0,s1
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	d90080e7          	jalr	-624(ra) # 80000cf0 <acquire>
    if(p->state == UNUSED) {
    80001f68:	509c                	lw	a5,32(s1)
    80001f6a:	cf81                	beqz	a5,80001f82 <allocproc+0x40>
      release(&p->lock);
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	e52080e7          	jalr	-430(ra) # 80000dc0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f76:	17048493          	addi	s1,s1,368
    80001f7a:	ff2492e3          	bne	s1,s2,80001f5e <allocproc+0x1c>
  return 0;
    80001f7e:	4481                	li	s1,0
    80001f80:	a0b9                	j	80001fce <allocproc+0x8c>
  p->pid = allocpid();
    80001f82:	00000097          	auipc	ra,0x0
    80001f86:	e34080e7          	jalr	-460(ra) # 80001db6 <allocpid>
    80001f8a:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	bee080e7          	jalr	-1042(ra) # 80000b7a <kalloc>
    80001f94:	892a                	mv	s2,a0
    80001f96:	f0a8                	sd	a0,96(s1)
    80001f98:	c131                	beqz	a0,80001fdc <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	00000097          	auipc	ra,0x0
    80001fa0:	e60080e7          	jalr	-416(ra) # 80001dfc <proc_pagetable>
    80001fa4:	892a                	mv	s2,a0
    80001fa6:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001fa8:	c129                	beqz	a0,80001fea <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001faa:	07000613          	li	a2,112
    80001fae:	4581                	li	a1,0
    80001fb0:	06848513          	addi	a0,s1,104
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	11c080e7          	jalr	284(ra) # 800010d0 <memset>
  p->context.ra = (uint64)forkret;
    80001fbc:	00000797          	auipc	a5,0x0
    80001fc0:	db478793          	addi	a5,a5,-588 # 80001d70 <forkret>
    80001fc4:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fc6:	64bc                	ld	a5,72(s1)
    80001fc8:	6705                	lui	a4,0x1
    80001fca:	97ba                	add	a5,a5,a4
    80001fcc:	f8bc                	sd	a5,112(s1)
}
    80001fce:	8526                	mv	a0,s1
    80001fd0:	60e2                	ld	ra,24(sp)
    80001fd2:	6442                	ld	s0,16(sp)
    80001fd4:	64a2                	ld	s1,8(sp)
    80001fd6:	6902                	ld	s2,0(sp)
    80001fd8:	6105                	addi	sp,sp,32
    80001fda:	8082                	ret
    release(&p->lock);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	de2080e7          	jalr	-542(ra) # 80000dc0 <release>
    return 0;
    80001fe6:	84ca                	mv	s1,s2
    80001fe8:	b7dd                	j	80001fce <allocproc+0x8c>
    freeproc(p);
    80001fea:	8526                	mv	a0,s1
    80001fec:	00000097          	auipc	ra,0x0
    80001ff0:	efe080e7          	jalr	-258(ra) # 80001eea <freeproc>
    release(&p->lock);
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	fffff097          	auipc	ra,0xfffff
    80001ffa:	dca080e7          	jalr	-566(ra) # 80000dc0 <release>
    return 0;
    80001ffe:	84ca                	mv	s1,s2
    80002000:	b7f9                	j	80001fce <allocproc+0x8c>

0000000080002002 <userinit>:
{
    80002002:	1101                	addi	sp,sp,-32
    80002004:	ec06                	sd	ra,24(sp)
    80002006:	e822                	sd	s0,16(sp)
    80002008:	e426                	sd	s1,8(sp)
    8000200a:	1000                	addi	s0,sp,32
  p = allocproc();
    8000200c:	00000097          	auipc	ra,0x0
    80002010:	f36080e7          	jalr	-202(ra) # 80001f42 <allocproc>
    80002014:	84aa                	mv	s1,a0
  initproc = p;
    80002016:	00007797          	auipc	a5,0x7
    8000201a:	00a7b123          	sd	a0,2(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000201e:	03400613          	li	a2,52
    80002022:	00007597          	auipc	a1,0x7
    80002026:	88e58593          	addi	a1,a1,-1906 # 800088b0 <initcode>
    8000202a:	6d28                	ld	a0,88(a0)
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	6f6080e7          	jalr	1782(ra) # 80001722 <uvminit>
  p->sz = PGSIZE;
    80002034:	6785                	lui	a5,0x1
    80002036:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80002038:	70b8                	ld	a4,96(s1)
    8000203a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000203e:	70b8                	ld	a4,96(s1)
    80002040:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002042:	4641                	li	a2,16
    80002044:	00006597          	auipc	a1,0x6
    80002048:	23458593          	addi	a1,a1,564 # 80008278 <digits+0x238>
    8000204c:	16048513          	addi	a0,s1,352
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	1d6080e7          	jalr	470(ra) # 80001226 <safestrcpy>
  p->cwd = namei("/");
    80002058:	00006517          	auipc	a0,0x6
    8000205c:	23050513          	addi	a0,a0,560 # 80008288 <digits+0x248>
    80002060:	00002097          	auipc	ra,0x2
    80002064:	238080e7          	jalr	568(ra) # 80004298 <namei>
    80002068:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    8000206c:	4789                	li	a5,2
    8000206e:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80002070:	8526                	mv	a0,s1
    80002072:	fffff097          	auipc	ra,0xfffff
    80002076:	d4e080e7          	jalr	-690(ra) # 80000dc0 <release>
}
    8000207a:	60e2                	ld	ra,24(sp)
    8000207c:	6442                	ld	s0,16(sp)
    8000207e:	64a2                	ld	s1,8(sp)
    80002080:	6105                	addi	sp,sp,32
    80002082:	8082                	ret

0000000080002084 <growproc>:
{
    80002084:	1101                	addi	sp,sp,-32
    80002086:	ec06                	sd	ra,24(sp)
    80002088:	e822                	sd	s0,16(sp)
    8000208a:	e426                	sd	s1,8(sp)
    8000208c:	e04a                	sd	s2,0(sp)
    8000208e:	1000                	addi	s0,sp,32
    80002090:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002092:	00000097          	auipc	ra,0x0
    80002096:	ca6080e7          	jalr	-858(ra) # 80001d38 <myproc>
    8000209a:	892a                	mv	s2,a0
  sz = p->sz;
    8000209c:	692c                	ld	a1,80(a0)
    8000209e:	0005861b          	sext.w	a2,a1
  if(n > 0){
    800020a2:	00904f63          	bgtz	s1,800020c0 <growproc+0x3c>
  } else if(n < 0){
    800020a6:	0204cc63          	bltz	s1,800020de <growproc+0x5a>
  p->sz = sz;
    800020aa:	1602                	slli	a2,a2,0x20
    800020ac:	9201                	srli	a2,a2,0x20
    800020ae:	04c93823          	sd	a2,80(s2)
  return 0;
    800020b2:	4501                	li	a0,0
}
    800020b4:	60e2                	ld	ra,24(sp)
    800020b6:	6442                	ld	s0,16(sp)
    800020b8:	64a2                	ld	s1,8(sp)
    800020ba:	6902                	ld	s2,0(sp)
    800020bc:	6105                	addi	sp,sp,32
    800020be:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800020c0:	9e25                	addw	a2,a2,s1
    800020c2:	1602                	slli	a2,a2,0x20
    800020c4:	9201                	srli	a2,a2,0x20
    800020c6:	1582                	slli	a1,a1,0x20
    800020c8:	9181                	srli	a1,a1,0x20
    800020ca:	6d28                	ld	a0,88(a0)
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	710080e7          	jalr	1808(ra) # 800017dc <uvmalloc>
    800020d4:	0005061b          	sext.w	a2,a0
    800020d8:	fa69                	bnez	a2,800020aa <growproc+0x26>
      return -1;
    800020da:	557d                	li	a0,-1
    800020dc:	bfe1                	j	800020b4 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020de:	9e25                	addw	a2,a2,s1
    800020e0:	1602                	slli	a2,a2,0x20
    800020e2:	9201                	srli	a2,a2,0x20
    800020e4:	1582                	slli	a1,a1,0x20
    800020e6:	9181                	srli	a1,a1,0x20
    800020e8:	6d28                	ld	a0,88(a0)
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	6aa080e7          	jalr	1706(ra) # 80001794 <uvmdealloc>
    800020f2:	0005061b          	sext.w	a2,a0
    800020f6:	bf55                	j	800020aa <growproc+0x26>

00000000800020f8 <fork>:
{
    800020f8:	7179                	addi	sp,sp,-48
    800020fa:	f406                	sd	ra,40(sp)
    800020fc:	f022                	sd	s0,32(sp)
    800020fe:	ec26                	sd	s1,24(sp)
    80002100:	e84a                	sd	s2,16(sp)
    80002102:	e44e                	sd	s3,8(sp)
    80002104:	e052                	sd	s4,0(sp)
    80002106:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002108:	00000097          	auipc	ra,0x0
    8000210c:	c30080e7          	jalr	-976(ra) # 80001d38 <myproc>
    80002110:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002112:	00000097          	auipc	ra,0x0
    80002116:	e30080e7          	jalr	-464(ra) # 80001f42 <allocproc>
    8000211a:	c175                	beqz	a0,800021fe <fork+0x106>
    8000211c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000211e:	05093603          	ld	a2,80(s2)
    80002122:	6d2c                	ld	a1,88(a0)
    80002124:	05893503          	ld	a0,88(s2)
    80002128:	00000097          	auipc	ra,0x0
    8000212c:	800080e7          	jalr	-2048(ra) # 80001928 <uvmcopy>
    80002130:	04054863          	bltz	a0,80002180 <fork+0x88>
  np->sz = p->sz;
    80002134:	05093783          	ld	a5,80(s2)
    80002138:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    8000213c:	0329b423          	sd	s2,40(s3)
  *(np->trapframe) = *(p->trapframe);
    80002140:	06093683          	ld	a3,96(s2)
    80002144:	87b6                	mv	a5,a3
    80002146:	0609b703          	ld	a4,96(s3)
    8000214a:	12068693          	addi	a3,a3,288
    8000214e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002152:	6788                	ld	a0,8(a5)
    80002154:	6b8c                	ld	a1,16(a5)
    80002156:	6f90                	ld	a2,24(a5)
    80002158:	01073023          	sd	a6,0(a4)
    8000215c:	e708                	sd	a0,8(a4)
    8000215e:	eb0c                	sd	a1,16(a4)
    80002160:	ef10                	sd	a2,24(a4)
    80002162:	02078793          	addi	a5,a5,32
    80002166:	02070713          	addi	a4,a4,32
    8000216a:	fed792e3          	bne	a5,a3,8000214e <fork+0x56>
  np->trapframe->a0 = 0;
    8000216e:	0609b783          	ld	a5,96(s3)
    80002172:	0607b823          	sd	zero,112(a5)
    80002176:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    8000217a:	15800a13          	li	s4,344
    8000217e:	a03d                	j	800021ac <fork+0xb4>
    freeproc(np);
    80002180:	854e                	mv	a0,s3
    80002182:	00000097          	auipc	ra,0x0
    80002186:	d68080e7          	jalr	-664(ra) # 80001eea <freeproc>
    release(&np->lock);
    8000218a:	854e                	mv	a0,s3
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	c34080e7          	jalr	-972(ra) # 80000dc0 <release>
    return -1;
    80002194:	54fd                	li	s1,-1
    80002196:	a899                	j	800021ec <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002198:	00002097          	auipc	ra,0x2
    8000219c:	79e080e7          	jalr	1950(ra) # 80004936 <filedup>
    800021a0:	009987b3          	add	a5,s3,s1
    800021a4:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800021a6:	04a1                	addi	s1,s1,8
    800021a8:	01448763          	beq	s1,s4,800021b6 <fork+0xbe>
    if(p->ofile[i])
    800021ac:	009907b3          	add	a5,s2,s1
    800021b0:	6388                	ld	a0,0(a5)
    800021b2:	f17d                	bnez	a0,80002198 <fork+0xa0>
    800021b4:	bfcd                	j	800021a6 <fork+0xae>
  np->cwd = idup(p->cwd);
    800021b6:	15893503          	ld	a0,344(s2)
    800021ba:	00002097          	auipc	ra,0x2
    800021be:	8ec080e7          	jalr	-1812(ra) # 80003aa6 <idup>
    800021c2:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800021c6:	4641                	li	a2,16
    800021c8:	16090593          	addi	a1,s2,352
    800021cc:	16098513          	addi	a0,s3,352
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	056080e7          	jalr	86(ra) # 80001226 <safestrcpy>
  pid = np->pid;
    800021d8:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    800021dc:	4789                	li	a5,2
    800021de:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    800021e2:	854e                	mv	a0,s3
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	bdc080e7          	jalr	-1060(ra) # 80000dc0 <release>
}
    800021ec:	8526                	mv	a0,s1
    800021ee:	70a2                	ld	ra,40(sp)
    800021f0:	7402                	ld	s0,32(sp)
    800021f2:	64e2                	ld	s1,24(sp)
    800021f4:	6942                	ld	s2,16(sp)
    800021f6:	69a2                	ld	s3,8(sp)
    800021f8:	6a02                	ld	s4,0(sp)
    800021fa:	6145                	addi	sp,sp,48
    800021fc:	8082                	ret
    return -1;
    800021fe:	54fd                	li	s1,-1
    80002200:	b7f5                	j	800021ec <fork+0xf4>

0000000080002202 <reparent>:
{
    80002202:	7179                	addi	sp,sp,-48
    80002204:	f406                	sd	ra,40(sp)
    80002206:	f022                	sd	s0,32(sp)
    80002208:	ec26                	sd	s1,24(sp)
    8000220a:	e84a                	sd	s2,16(sp)
    8000220c:	e44e                	sd	s3,8(sp)
    8000220e:	e052                	sd	s4,0(sp)
    80002210:	1800                	addi	s0,sp,48
    80002212:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002214:	00010497          	auipc	s1,0x10
    80002218:	5bc48493          	addi	s1,s1,1468 # 800127d0 <proc>
      pp->parent = initproc;
    8000221c:	00007a17          	auipc	s4,0x7
    80002220:	dfca0a13          	addi	s4,s4,-516 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002224:	00016997          	auipc	s3,0x16
    80002228:	1ac98993          	addi	s3,s3,428 # 800183d0 <tickslock>
    8000222c:	a029                	j	80002236 <reparent+0x34>
    8000222e:	17048493          	addi	s1,s1,368
    80002232:	03348363          	beq	s1,s3,80002258 <reparent+0x56>
    if(pp->parent == p){
    80002236:	749c                	ld	a5,40(s1)
    80002238:	ff279be3          	bne	a5,s2,8000222e <reparent+0x2c>
      acquire(&pp->lock);
    8000223c:	8526                	mv	a0,s1
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	ab2080e7          	jalr	-1358(ra) # 80000cf0 <acquire>
      pp->parent = initproc;
    80002246:	000a3783          	ld	a5,0(s4)
    8000224a:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    8000224c:	8526                	mv	a0,s1
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	b72080e7          	jalr	-1166(ra) # 80000dc0 <release>
    80002256:	bfe1                	j	8000222e <reparent+0x2c>
}
    80002258:	70a2                	ld	ra,40(sp)
    8000225a:	7402                	ld	s0,32(sp)
    8000225c:	64e2                	ld	s1,24(sp)
    8000225e:	6942                	ld	s2,16(sp)
    80002260:	69a2                	ld	s3,8(sp)
    80002262:	6a02                	ld	s4,0(sp)
    80002264:	6145                	addi	sp,sp,48
    80002266:	8082                	ret

0000000080002268 <scheduler>:
{
    80002268:	711d                	addi	sp,sp,-96
    8000226a:	ec86                	sd	ra,88(sp)
    8000226c:	e8a2                	sd	s0,80(sp)
    8000226e:	e4a6                	sd	s1,72(sp)
    80002270:	e0ca                	sd	s2,64(sp)
    80002272:	fc4e                	sd	s3,56(sp)
    80002274:	f852                	sd	s4,48(sp)
    80002276:	f456                	sd	s5,40(sp)
    80002278:	f05a                	sd	s6,32(sp)
    8000227a:	ec5e                	sd	s7,24(sp)
    8000227c:	e862                	sd	s8,16(sp)
    8000227e:	e466                	sd	s9,8(sp)
    80002280:	1080                	addi	s0,sp,96
    80002282:	8792                	mv	a5,tp
  int id = r_tp();
    80002284:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002286:	00779c13          	slli	s8,a5,0x7
    8000228a:	00010717          	auipc	a4,0x10
    8000228e:	12670713          	addi	a4,a4,294 # 800123b0 <pid_lock>
    80002292:	9762                	add	a4,a4,s8
    80002294:	02073023          	sd	zero,32(a4)
        swtch(&c->context, &p->context);
    80002298:	00010717          	auipc	a4,0x10
    8000229c:	14070713          	addi	a4,a4,320 # 800123d8 <cpus+0x8>
    800022a0:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    800022a2:	4a89                	li	s5,2
        c->proc = p;
    800022a4:	079e                	slli	a5,a5,0x7
    800022a6:	00010b17          	auipc	s6,0x10
    800022aa:	10ab0b13          	addi	s6,s6,266 # 800123b0 <pid_lock>
    800022ae:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800022b0:	00016a17          	auipc	s4,0x16
    800022b4:	120a0a13          	addi	s4,s4,288 # 800183d0 <tickslock>
    int nproc = 0;
    800022b8:	4c81                	li	s9,0
    800022ba:	a8a1                	j	80002312 <scheduler+0xaa>
        p->state = RUNNING;
    800022bc:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    800022c0:	029b3023          	sd	s1,32(s6)
        swtch(&c->context, &p->context);
    800022c4:	06848593          	addi	a1,s1,104
    800022c8:	8562                	mv	a0,s8
    800022ca:	00000097          	auipc	ra,0x0
    800022ce:	63a080e7          	jalr	1594(ra) # 80002904 <swtch>
        c->proc = 0;
    800022d2:	020b3023          	sd	zero,32(s6)
      release(&p->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	ae8080e7          	jalr	-1304(ra) # 80000dc0 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800022e0:	17048493          	addi	s1,s1,368
    800022e4:	01448d63          	beq	s1,s4,800022fe <scheduler+0x96>
      acquire(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	a06080e7          	jalr	-1530(ra) # 80000cf0 <acquire>
      if(p->state != UNUSED) {
    800022f2:	509c                	lw	a5,32(s1)
    800022f4:	d3ed                	beqz	a5,800022d6 <scheduler+0x6e>
        nproc++;
    800022f6:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    800022f8:	fd579fe3          	bne	a5,s5,800022d6 <scheduler+0x6e>
    800022fc:	b7c1                	j	800022bc <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    800022fe:	013aca63          	blt	s5,s3,80002312 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002302:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002306:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000230a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000230e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002312:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002316:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000231a:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    8000231e:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80002320:	00010497          	auipc	s1,0x10
    80002324:	4b048493          	addi	s1,s1,1200 # 800127d0 <proc>
        p->state = RUNNING;
    80002328:	4b8d                	li	s7,3
    8000232a:	bf7d                	j	800022e8 <scheduler+0x80>

000000008000232c <sched>:
{
    8000232c:	7179                	addi	sp,sp,-48
    8000232e:	f406                	sd	ra,40(sp)
    80002330:	f022                	sd	s0,32(sp)
    80002332:	ec26                	sd	s1,24(sp)
    80002334:	e84a                	sd	s2,16(sp)
    80002336:	e44e                	sd	s3,8(sp)
    80002338:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000233a:	00000097          	auipc	ra,0x0
    8000233e:	9fe080e7          	jalr	-1538(ra) # 80001d38 <myproc>
    80002342:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	932080e7          	jalr	-1742(ra) # 80000c76 <holding>
    8000234c:	c93d                	beqz	a0,800023c2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000234e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002350:	2781                	sext.w	a5,a5
    80002352:	079e                	slli	a5,a5,0x7
    80002354:	00010717          	auipc	a4,0x10
    80002358:	05c70713          	addi	a4,a4,92 # 800123b0 <pid_lock>
    8000235c:	97ba                	add	a5,a5,a4
    8000235e:	0987a703          	lw	a4,152(a5)
    80002362:	4785                	li	a5,1
    80002364:	06f71763          	bne	a4,a5,800023d2 <sched+0xa6>
  if(p->state == RUNNING)
    80002368:	5098                	lw	a4,32(s1)
    8000236a:	478d                	li	a5,3
    8000236c:	06f70b63          	beq	a4,a5,800023e2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002370:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002374:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002376:	efb5                	bnez	a5,800023f2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002378:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000237a:	00010917          	auipc	s2,0x10
    8000237e:	03690913          	addi	s2,s2,54 # 800123b0 <pid_lock>
    80002382:	2781                	sext.w	a5,a5
    80002384:	079e                	slli	a5,a5,0x7
    80002386:	97ca                	add	a5,a5,s2
    80002388:	09c7a983          	lw	s3,156(a5)
    8000238c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000238e:	2781                	sext.w	a5,a5
    80002390:	079e                	slli	a5,a5,0x7
    80002392:	00010597          	auipc	a1,0x10
    80002396:	04658593          	addi	a1,a1,70 # 800123d8 <cpus+0x8>
    8000239a:	95be                	add	a1,a1,a5
    8000239c:	06848513          	addi	a0,s1,104
    800023a0:	00000097          	auipc	ra,0x0
    800023a4:	564080e7          	jalr	1380(ra) # 80002904 <swtch>
    800023a8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023aa:	2781                	sext.w	a5,a5
    800023ac:	079e                	slli	a5,a5,0x7
    800023ae:	97ca                	add	a5,a5,s2
    800023b0:	0937ae23          	sw	s3,156(a5)
}
    800023b4:	70a2                	ld	ra,40(sp)
    800023b6:	7402                	ld	s0,32(sp)
    800023b8:	64e2                	ld	s1,24(sp)
    800023ba:	6942                	ld	s2,16(sp)
    800023bc:	69a2                	ld	s3,8(sp)
    800023be:	6145                	addi	sp,sp,48
    800023c0:	8082                	ret
    panic("sched p->lock");
    800023c2:	00006517          	auipc	a0,0x6
    800023c6:	ece50513          	addi	a0,a0,-306 # 80008290 <digits+0x250>
    800023ca:	ffffe097          	auipc	ra,0xffffe
    800023ce:	186080e7          	jalr	390(ra) # 80000550 <panic>
    panic("sched locks");
    800023d2:	00006517          	auipc	a0,0x6
    800023d6:	ece50513          	addi	a0,a0,-306 # 800082a0 <digits+0x260>
    800023da:	ffffe097          	auipc	ra,0xffffe
    800023de:	176080e7          	jalr	374(ra) # 80000550 <panic>
    panic("sched running");
    800023e2:	00006517          	auipc	a0,0x6
    800023e6:	ece50513          	addi	a0,a0,-306 # 800082b0 <digits+0x270>
    800023ea:	ffffe097          	auipc	ra,0xffffe
    800023ee:	166080e7          	jalr	358(ra) # 80000550 <panic>
    panic("sched interruptible");
    800023f2:	00006517          	auipc	a0,0x6
    800023f6:	ece50513          	addi	a0,a0,-306 # 800082c0 <digits+0x280>
    800023fa:	ffffe097          	auipc	ra,0xffffe
    800023fe:	156080e7          	jalr	342(ra) # 80000550 <panic>

0000000080002402 <exit>:
{
    80002402:	7179                	addi	sp,sp,-48
    80002404:	f406                	sd	ra,40(sp)
    80002406:	f022                	sd	s0,32(sp)
    80002408:	ec26                	sd	s1,24(sp)
    8000240a:	e84a                	sd	s2,16(sp)
    8000240c:	e44e                	sd	s3,8(sp)
    8000240e:	e052                	sd	s4,0(sp)
    80002410:	1800                	addi	s0,sp,48
    80002412:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002414:	00000097          	auipc	ra,0x0
    80002418:	924080e7          	jalr	-1756(ra) # 80001d38 <myproc>
    8000241c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000241e:	00007797          	auipc	a5,0x7
    80002422:	bfa7b783          	ld	a5,-1030(a5) # 80009018 <initproc>
    80002426:	0d850493          	addi	s1,a0,216
    8000242a:	15850913          	addi	s2,a0,344
    8000242e:	02a79363          	bne	a5,a0,80002454 <exit+0x52>
    panic("init exiting");
    80002432:	00006517          	auipc	a0,0x6
    80002436:	ea650513          	addi	a0,a0,-346 # 800082d8 <digits+0x298>
    8000243a:	ffffe097          	auipc	ra,0xffffe
    8000243e:	116080e7          	jalr	278(ra) # 80000550 <panic>
      fileclose(f);
    80002442:	00002097          	auipc	ra,0x2
    80002446:	546080e7          	jalr	1350(ra) # 80004988 <fileclose>
      p->ofile[fd] = 0;
    8000244a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000244e:	04a1                	addi	s1,s1,8
    80002450:	01248563          	beq	s1,s2,8000245a <exit+0x58>
    if(p->ofile[fd]){
    80002454:	6088                	ld	a0,0(s1)
    80002456:	f575                	bnez	a0,80002442 <exit+0x40>
    80002458:	bfdd                	j	8000244e <exit+0x4c>
  begin_op();
    8000245a:	00002097          	auipc	ra,0x2
    8000245e:	05a080e7          	jalr	90(ra) # 800044b4 <begin_op>
  iput(p->cwd);
    80002462:	1589b503          	ld	a0,344(s3)
    80002466:	00002097          	auipc	ra,0x2
    8000246a:	838080e7          	jalr	-1992(ra) # 80003c9e <iput>
  end_op();
    8000246e:	00002097          	auipc	ra,0x2
    80002472:	0c6080e7          	jalr	198(ra) # 80004534 <end_op>
  p->cwd = 0;
    80002476:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    8000247a:	00007497          	auipc	s1,0x7
    8000247e:	b9e48493          	addi	s1,s1,-1122 # 80009018 <initproc>
    80002482:	6088                	ld	a0,0(s1)
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	86c080e7          	jalr	-1940(ra) # 80000cf0 <acquire>
  wakeup1(initproc);
    8000248c:	6088                	ld	a0,0(s1)
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	76a080e7          	jalr	1898(ra) # 80001bf8 <wakeup1>
  release(&initproc->lock);
    80002496:	6088                	ld	a0,0(s1)
    80002498:	fffff097          	auipc	ra,0xfffff
    8000249c:	928080e7          	jalr	-1752(ra) # 80000dc0 <release>
  acquire(&p->lock);
    800024a0:	854e                	mv	a0,s3
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	84e080e7          	jalr	-1970(ra) # 80000cf0 <acquire>
  struct proc *original_parent = p->parent;
    800024aa:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800024ae:	854e                	mv	a0,s3
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	910080e7          	jalr	-1776(ra) # 80000dc0 <release>
  acquire(&original_parent->lock);
    800024b8:	8526                	mv	a0,s1
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	836080e7          	jalr	-1994(ra) # 80000cf0 <acquire>
  acquire(&p->lock);
    800024c2:	854e                	mv	a0,s3
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	82c080e7          	jalr	-2004(ra) # 80000cf0 <acquire>
  reparent(p);
    800024cc:	854e                	mv	a0,s3
    800024ce:	00000097          	auipc	ra,0x0
    800024d2:	d34080e7          	jalr	-716(ra) # 80002202 <reparent>
  wakeup1(original_parent);
    800024d6:	8526                	mv	a0,s1
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	720080e7          	jalr	1824(ra) # 80001bf8 <wakeup1>
  p->xstate = status;
    800024e0:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800024e4:	4791                	li	a5,4
    800024e6:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	8d4080e7          	jalr	-1836(ra) # 80000dc0 <release>
  sched();
    800024f4:	00000097          	auipc	ra,0x0
    800024f8:	e38080e7          	jalr	-456(ra) # 8000232c <sched>
  panic("zombie exit");
    800024fc:	00006517          	auipc	a0,0x6
    80002500:	dec50513          	addi	a0,a0,-532 # 800082e8 <digits+0x2a8>
    80002504:	ffffe097          	auipc	ra,0xffffe
    80002508:	04c080e7          	jalr	76(ra) # 80000550 <panic>

000000008000250c <yield>:
{
    8000250c:	1101                	addi	sp,sp,-32
    8000250e:	ec06                	sd	ra,24(sp)
    80002510:	e822                	sd	s0,16(sp)
    80002512:	e426                	sd	s1,8(sp)
    80002514:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002516:	00000097          	auipc	ra,0x0
    8000251a:	822080e7          	jalr	-2014(ra) # 80001d38 <myproc>
    8000251e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	7d0080e7          	jalr	2000(ra) # 80000cf0 <acquire>
  p->state = RUNNABLE;
    80002528:	4789                	li	a5,2
    8000252a:	d09c                	sw	a5,32(s1)
  sched();
    8000252c:	00000097          	auipc	ra,0x0
    80002530:	e00080e7          	jalr	-512(ra) # 8000232c <sched>
  release(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	88a080e7          	jalr	-1910(ra) # 80000dc0 <release>
}
    8000253e:	60e2                	ld	ra,24(sp)
    80002540:	6442                	ld	s0,16(sp)
    80002542:	64a2                	ld	s1,8(sp)
    80002544:	6105                	addi	sp,sp,32
    80002546:	8082                	ret

0000000080002548 <sleep>:
{
    80002548:	7179                	addi	sp,sp,-48
    8000254a:	f406                	sd	ra,40(sp)
    8000254c:	f022                	sd	s0,32(sp)
    8000254e:	ec26                	sd	s1,24(sp)
    80002550:	e84a                	sd	s2,16(sp)
    80002552:	e44e                	sd	s3,8(sp)
    80002554:	1800                	addi	s0,sp,48
    80002556:	89aa                	mv	s3,a0
    80002558:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000255a:	fffff097          	auipc	ra,0xfffff
    8000255e:	7de080e7          	jalr	2014(ra) # 80001d38 <myproc>
    80002562:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002564:	05250663          	beq	a0,s2,800025b0 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	788080e7          	jalr	1928(ra) # 80000cf0 <acquire>
    release(lk);
    80002570:	854a                	mv	a0,s2
    80002572:	fffff097          	auipc	ra,0xfffff
    80002576:	84e080e7          	jalr	-1970(ra) # 80000dc0 <release>
  p->chan = chan;
    8000257a:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000257e:	4785                	li	a5,1
    80002580:	d09c                	sw	a5,32(s1)
  sched();
    80002582:	00000097          	auipc	ra,0x0
    80002586:	daa080e7          	jalr	-598(ra) # 8000232c <sched>
  p->chan = 0;
    8000258a:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000258e:	8526                	mv	a0,s1
    80002590:	fffff097          	auipc	ra,0xfffff
    80002594:	830080e7          	jalr	-2000(ra) # 80000dc0 <release>
    acquire(lk);
    80002598:	854a                	mv	a0,s2
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	756080e7          	jalr	1878(ra) # 80000cf0 <acquire>
}
    800025a2:	70a2                	ld	ra,40(sp)
    800025a4:	7402                	ld	s0,32(sp)
    800025a6:	64e2                	ld	s1,24(sp)
    800025a8:	6942                	ld	s2,16(sp)
    800025aa:	69a2                	ld	s3,8(sp)
    800025ac:	6145                	addi	sp,sp,48
    800025ae:	8082                	ret
  p->chan = chan;
    800025b0:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800025b4:	4785                	li	a5,1
    800025b6:	d11c                	sw	a5,32(a0)
  sched();
    800025b8:	00000097          	auipc	ra,0x0
    800025bc:	d74080e7          	jalr	-652(ra) # 8000232c <sched>
  p->chan = 0;
    800025c0:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800025c4:	bff9                	j	800025a2 <sleep+0x5a>

00000000800025c6 <wait>:
{
    800025c6:	715d                	addi	sp,sp,-80
    800025c8:	e486                	sd	ra,72(sp)
    800025ca:	e0a2                	sd	s0,64(sp)
    800025cc:	fc26                	sd	s1,56(sp)
    800025ce:	f84a                	sd	s2,48(sp)
    800025d0:	f44e                	sd	s3,40(sp)
    800025d2:	f052                	sd	s4,32(sp)
    800025d4:	ec56                	sd	s5,24(sp)
    800025d6:	e85a                	sd	s6,16(sp)
    800025d8:	e45e                	sd	s7,8(sp)
    800025da:	e062                	sd	s8,0(sp)
    800025dc:	0880                	addi	s0,sp,80
    800025de:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025e0:	fffff097          	auipc	ra,0xfffff
    800025e4:	758080e7          	jalr	1880(ra) # 80001d38 <myproc>
    800025e8:	892a                	mv	s2,a0
  acquire(&p->lock);
    800025ea:	8c2a                	mv	s8,a0
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	704080e7          	jalr	1796(ra) # 80000cf0 <acquire>
    havekids = 0;
    800025f4:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800025f6:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800025f8:	00016997          	auipc	s3,0x16
    800025fc:	dd898993          	addi	s3,s3,-552 # 800183d0 <tickslock>
        havekids = 1;
    80002600:	4a85                	li	s5,1
    havekids = 0;
    80002602:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002604:	00010497          	auipc	s1,0x10
    80002608:	1cc48493          	addi	s1,s1,460 # 800127d0 <proc>
    8000260c:	a08d                	j	8000266e <wait+0xa8>
          pid = np->pid;
    8000260e:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002612:	000b0e63          	beqz	s6,8000262e <wait+0x68>
    80002616:	4691                	li	a3,4
    80002618:	03c48613          	addi	a2,s1,60
    8000261c:	85da                	mv	a1,s6
    8000261e:	05893503          	ld	a0,88(s2)
    80002622:	fffff097          	auipc	ra,0xfffff
    80002626:	40a080e7          	jalr	1034(ra) # 80001a2c <copyout>
    8000262a:	02054263          	bltz	a0,8000264e <wait+0x88>
          freeproc(np);
    8000262e:	8526                	mv	a0,s1
    80002630:	00000097          	auipc	ra,0x0
    80002634:	8ba080e7          	jalr	-1862(ra) # 80001eea <freeproc>
          release(&np->lock);
    80002638:	8526                	mv	a0,s1
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	786080e7          	jalr	1926(ra) # 80000dc0 <release>
          release(&p->lock);
    80002642:	854a                	mv	a0,s2
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	77c080e7          	jalr	1916(ra) # 80000dc0 <release>
          return pid;
    8000264c:	a8a9                	j	800026a6 <wait+0xe0>
            release(&np->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	770080e7          	jalr	1904(ra) # 80000dc0 <release>
            release(&p->lock);
    80002658:	854a                	mv	a0,s2
    8000265a:	ffffe097          	auipc	ra,0xffffe
    8000265e:	766080e7          	jalr	1894(ra) # 80000dc0 <release>
            return -1;
    80002662:	59fd                	li	s3,-1
    80002664:	a089                	j	800026a6 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002666:	17048493          	addi	s1,s1,368
    8000266a:	03348463          	beq	s1,s3,80002692 <wait+0xcc>
      if(np->parent == p){
    8000266e:	749c                	ld	a5,40(s1)
    80002670:	ff279be3          	bne	a5,s2,80002666 <wait+0xa0>
        acquire(&np->lock);
    80002674:	8526                	mv	a0,s1
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	67a080e7          	jalr	1658(ra) # 80000cf0 <acquire>
        if(np->state == ZOMBIE){
    8000267e:	509c                	lw	a5,32(s1)
    80002680:	f94787e3          	beq	a5,s4,8000260e <wait+0x48>
        release(&np->lock);
    80002684:	8526                	mv	a0,s1
    80002686:	ffffe097          	auipc	ra,0xffffe
    8000268a:	73a080e7          	jalr	1850(ra) # 80000dc0 <release>
        havekids = 1;
    8000268e:	8756                	mv	a4,s5
    80002690:	bfd9                	j	80002666 <wait+0xa0>
    if(!havekids || p->killed){
    80002692:	c701                	beqz	a4,8000269a <wait+0xd4>
    80002694:	03892783          	lw	a5,56(s2)
    80002698:	c785                	beqz	a5,800026c0 <wait+0xfa>
      release(&p->lock);
    8000269a:	854a                	mv	a0,s2
    8000269c:	ffffe097          	auipc	ra,0xffffe
    800026a0:	724080e7          	jalr	1828(ra) # 80000dc0 <release>
      return -1;
    800026a4:	59fd                	li	s3,-1
}
    800026a6:	854e                	mv	a0,s3
    800026a8:	60a6                	ld	ra,72(sp)
    800026aa:	6406                	ld	s0,64(sp)
    800026ac:	74e2                	ld	s1,56(sp)
    800026ae:	7942                	ld	s2,48(sp)
    800026b0:	79a2                	ld	s3,40(sp)
    800026b2:	7a02                	ld	s4,32(sp)
    800026b4:	6ae2                	ld	s5,24(sp)
    800026b6:	6b42                	ld	s6,16(sp)
    800026b8:	6ba2                	ld	s7,8(sp)
    800026ba:	6c02                	ld	s8,0(sp)
    800026bc:	6161                	addi	sp,sp,80
    800026be:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800026c0:	85e2                	mv	a1,s8
    800026c2:	854a                	mv	a0,s2
    800026c4:	00000097          	auipc	ra,0x0
    800026c8:	e84080e7          	jalr	-380(ra) # 80002548 <sleep>
    havekids = 0;
    800026cc:	bf1d                	j	80002602 <wait+0x3c>

00000000800026ce <wakeup>:
{
    800026ce:	7139                	addi	sp,sp,-64
    800026d0:	fc06                	sd	ra,56(sp)
    800026d2:	f822                	sd	s0,48(sp)
    800026d4:	f426                	sd	s1,40(sp)
    800026d6:	f04a                	sd	s2,32(sp)
    800026d8:	ec4e                	sd	s3,24(sp)
    800026da:	e852                	sd	s4,16(sp)
    800026dc:	e456                	sd	s5,8(sp)
    800026de:	0080                	addi	s0,sp,64
    800026e0:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800026e2:	00010497          	auipc	s1,0x10
    800026e6:	0ee48493          	addi	s1,s1,238 # 800127d0 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800026ea:	4985                	li	s3,1
      p->state = RUNNABLE;
    800026ec:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800026ee:	00016917          	auipc	s2,0x16
    800026f2:	ce290913          	addi	s2,s2,-798 # 800183d0 <tickslock>
    800026f6:	a821                	j	8000270e <wakeup+0x40>
      p->state = RUNNABLE;
    800026f8:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    800026fc:	8526                	mv	a0,s1
    800026fe:	ffffe097          	auipc	ra,0xffffe
    80002702:	6c2080e7          	jalr	1730(ra) # 80000dc0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002706:	17048493          	addi	s1,s1,368
    8000270a:	01248e63          	beq	s1,s2,80002726 <wakeup+0x58>
    acquire(&p->lock);
    8000270e:	8526                	mv	a0,s1
    80002710:	ffffe097          	auipc	ra,0xffffe
    80002714:	5e0080e7          	jalr	1504(ra) # 80000cf0 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002718:	509c                	lw	a5,32(s1)
    8000271a:	ff3791e3          	bne	a5,s3,800026fc <wakeup+0x2e>
    8000271e:	789c                	ld	a5,48(s1)
    80002720:	fd479ee3          	bne	a5,s4,800026fc <wakeup+0x2e>
    80002724:	bfd1                	j	800026f8 <wakeup+0x2a>
}
    80002726:	70e2                	ld	ra,56(sp)
    80002728:	7442                	ld	s0,48(sp)
    8000272a:	74a2                	ld	s1,40(sp)
    8000272c:	7902                	ld	s2,32(sp)
    8000272e:	69e2                	ld	s3,24(sp)
    80002730:	6a42                	ld	s4,16(sp)
    80002732:	6aa2                	ld	s5,8(sp)
    80002734:	6121                	addi	sp,sp,64
    80002736:	8082                	ret

0000000080002738 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002738:	7179                	addi	sp,sp,-48
    8000273a:	f406                	sd	ra,40(sp)
    8000273c:	f022                	sd	s0,32(sp)
    8000273e:	ec26                	sd	s1,24(sp)
    80002740:	e84a                	sd	s2,16(sp)
    80002742:	e44e                	sd	s3,8(sp)
    80002744:	1800                	addi	s0,sp,48
    80002746:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002748:	00010497          	auipc	s1,0x10
    8000274c:	08848493          	addi	s1,s1,136 # 800127d0 <proc>
    80002750:	00016997          	auipc	s3,0x16
    80002754:	c8098993          	addi	s3,s3,-896 # 800183d0 <tickslock>
    acquire(&p->lock);
    80002758:	8526                	mv	a0,s1
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	596080e7          	jalr	1430(ra) # 80000cf0 <acquire>
    if(p->pid == pid){
    80002762:	40bc                	lw	a5,64(s1)
    80002764:	01278d63          	beq	a5,s2,8000277e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002768:	8526                	mv	a0,s1
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	656080e7          	jalr	1622(ra) # 80000dc0 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002772:	17048493          	addi	s1,s1,368
    80002776:	ff3491e3          	bne	s1,s3,80002758 <kill+0x20>
  }
  return -1;
    8000277a:	557d                	li	a0,-1
    8000277c:	a829                	j	80002796 <kill+0x5e>
      p->killed = 1;
    8000277e:	4785                	li	a5,1
    80002780:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    80002782:	5098                	lw	a4,32(s1)
    80002784:	4785                	li	a5,1
    80002786:	00f70f63          	beq	a4,a5,800027a4 <kill+0x6c>
      release(&p->lock);
    8000278a:	8526                	mv	a0,s1
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	634080e7          	jalr	1588(ra) # 80000dc0 <release>
      return 0;
    80002794:	4501                	li	a0,0
}
    80002796:	70a2                	ld	ra,40(sp)
    80002798:	7402                	ld	s0,32(sp)
    8000279a:	64e2                	ld	s1,24(sp)
    8000279c:	6942                	ld	s2,16(sp)
    8000279e:	69a2                	ld	s3,8(sp)
    800027a0:	6145                	addi	sp,sp,48
    800027a2:	8082                	ret
        p->state = RUNNABLE;
    800027a4:	4789                	li	a5,2
    800027a6:	d09c                	sw	a5,32(s1)
    800027a8:	b7cd                	j	8000278a <kill+0x52>

00000000800027aa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027aa:	7179                	addi	sp,sp,-48
    800027ac:	f406                	sd	ra,40(sp)
    800027ae:	f022                	sd	s0,32(sp)
    800027b0:	ec26                	sd	s1,24(sp)
    800027b2:	e84a                	sd	s2,16(sp)
    800027b4:	e44e                	sd	s3,8(sp)
    800027b6:	e052                	sd	s4,0(sp)
    800027b8:	1800                	addi	s0,sp,48
    800027ba:	84aa                	mv	s1,a0
    800027bc:	892e                	mv	s2,a1
    800027be:	89b2                	mv	s3,a2
    800027c0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027c2:	fffff097          	auipc	ra,0xfffff
    800027c6:	576080e7          	jalr	1398(ra) # 80001d38 <myproc>
  if(user_dst){
    800027ca:	c08d                	beqz	s1,800027ec <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800027cc:	86d2                	mv	a3,s4
    800027ce:	864e                	mv	a2,s3
    800027d0:	85ca                	mv	a1,s2
    800027d2:	6d28                	ld	a0,88(a0)
    800027d4:	fffff097          	auipc	ra,0xfffff
    800027d8:	258080e7          	jalr	600(ra) # 80001a2c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027dc:	70a2                	ld	ra,40(sp)
    800027de:	7402                	ld	s0,32(sp)
    800027e0:	64e2                	ld	s1,24(sp)
    800027e2:	6942                	ld	s2,16(sp)
    800027e4:	69a2                	ld	s3,8(sp)
    800027e6:	6a02                	ld	s4,0(sp)
    800027e8:	6145                	addi	sp,sp,48
    800027ea:	8082                	ret
    memmove((char *)dst, src, len);
    800027ec:	000a061b          	sext.w	a2,s4
    800027f0:	85ce                	mv	a1,s3
    800027f2:	854a                	mv	a0,s2
    800027f4:	fffff097          	auipc	ra,0xfffff
    800027f8:	93c080e7          	jalr	-1732(ra) # 80001130 <memmove>
    return 0;
    800027fc:	8526                	mv	a0,s1
    800027fe:	bff9                	j	800027dc <either_copyout+0x32>

0000000080002800 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002800:	7179                	addi	sp,sp,-48
    80002802:	f406                	sd	ra,40(sp)
    80002804:	f022                	sd	s0,32(sp)
    80002806:	ec26                	sd	s1,24(sp)
    80002808:	e84a                	sd	s2,16(sp)
    8000280a:	e44e                	sd	s3,8(sp)
    8000280c:	e052                	sd	s4,0(sp)
    8000280e:	1800                	addi	s0,sp,48
    80002810:	892a                	mv	s2,a0
    80002812:	84ae                	mv	s1,a1
    80002814:	89b2                	mv	s3,a2
    80002816:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002818:	fffff097          	auipc	ra,0xfffff
    8000281c:	520080e7          	jalr	1312(ra) # 80001d38 <myproc>
  if(user_src){
    80002820:	c08d                	beqz	s1,80002842 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002822:	86d2                	mv	a3,s4
    80002824:	864e                	mv	a2,s3
    80002826:	85ca                	mv	a1,s2
    80002828:	6d28                	ld	a0,88(a0)
    8000282a:	fffff097          	auipc	ra,0xfffff
    8000282e:	28e080e7          	jalr	654(ra) # 80001ab8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002832:	70a2                	ld	ra,40(sp)
    80002834:	7402                	ld	s0,32(sp)
    80002836:	64e2                	ld	s1,24(sp)
    80002838:	6942                	ld	s2,16(sp)
    8000283a:	69a2                	ld	s3,8(sp)
    8000283c:	6a02                	ld	s4,0(sp)
    8000283e:	6145                	addi	sp,sp,48
    80002840:	8082                	ret
    memmove(dst, (char*)src, len);
    80002842:	000a061b          	sext.w	a2,s4
    80002846:	85ce                	mv	a1,s3
    80002848:	854a                	mv	a0,s2
    8000284a:	fffff097          	auipc	ra,0xfffff
    8000284e:	8e6080e7          	jalr	-1818(ra) # 80001130 <memmove>
    return 0;
    80002852:	8526                	mv	a0,s1
    80002854:	bff9                	j	80002832 <either_copyin+0x32>

0000000080002856 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002856:	715d                	addi	sp,sp,-80
    80002858:	e486                	sd	ra,72(sp)
    8000285a:	e0a2                	sd	s0,64(sp)
    8000285c:	fc26                	sd	s1,56(sp)
    8000285e:	f84a                	sd	s2,48(sp)
    80002860:	f44e                	sd	s3,40(sp)
    80002862:	f052                	sd	s4,32(sp)
    80002864:	ec56                	sd	s5,24(sp)
    80002866:	e85a                	sd	s6,16(sp)
    80002868:	e45e                	sd	s7,8(sp)
    8000286a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000286c:	00006517          	auipc	a0,0x6
    80002870:	8f450513          	addi	a0,a0,-1804 # 80008160 <digits+0x120>
    80002874:	ffffe097          	auipc	ra,0xffffe
    80002878:	d26080e7          	jalr	-730(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000287c:	00010497          	auipc	s1,0x10
    80002880:	0b448493          	addi	s1,s1,180 # 80012930 <proc+0x160>
    80002884:	00016917          	auipc	s2,0x16
    80002888:	cac90913          	addi	s2,s2,-852 # 80018530 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000288c:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000288e:	00006997          	auipc	s3,0x6
    80002892:	a6a98993          	addi	s3,s3,-1430 # 800082f8 <digits+0x2b8>
    printf("%d %s %s", p->pid, state, p->name);
    80002896:	00006a97          	auipc	s5,0x6
    8000289a:	a6aa8a93          	addi	s5,s5,-1430 # 80008300 <digits+0x2c0>
    printf("\n");
    8000289e:	00006a17          	auipc	s4,0x6
    800028a2:	8c2a0a13          	addi	s4,s4,-1854 # 80008160 <digits+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a6:	00006b97          	auipc	s7,0x6
    800028aa:	a92b8b93          	addi	s7,s7,-1390 # 80008338 <states.1712>
    800028ae:	a00d                	j	800028d0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800028b0:	ee06a583          	lw	a1,-288(a3)
    800028b4:	8556                	mv	a0,s5
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	ce4080e7          	jalr	-796(ra) # 8000059a <printf>
    printf("\n");
    800028be:	8552                	mv	a0,s4
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	cda080e7          	jalr	-806(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028c8:	17048493          	addi	s1,s1,368
    800028cc:	03248163          	beq	s1,s2,800028ee <procdump+0x98>
    if(p->state == UNUSED)
    800028d0:	86a6                	mv	a3,s1
    800028d2:	ec04a783          	lw	a5,-320(s1)
    800028d6:	dbed                	beqz	a5,800028c8 <procdump+0x72>
      state = "???";
    800028d8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028da:	fcfb6be3          	bltu	s6,a5,800028b0 <procdump+0x5a>
    800028de:	1782                	slli	a5,a5,0x20
    800028e0:	9381                	srli	a5,a5,0x20
    800028e2:	078e                	slli	a5,a5,0x3
    800028e4:	97de                	add	a5,a5,s7
    800028e6:	6390                	ld	a2,0(a5)
    800028e8:	f661                	bnez	a2,800028b0 <procdump+0x5a>
      state = "???";
    800028ea:	864e                	mv	a2,s3
    800028ec:	b7d1                	j	800028b0 <procdump+0x5a>
  }
}
    800028ee:	60a6                	ld	ra,72(sp)
    800028f0:	6406                	ld	s0,64(sp)
    800028f2:	74e2                	ld	s1,56(sp)
    800028f4:	7942                	ld	s2,48(sp)
    800028f6:	79a2                	ld	s3,40(sp)
    800028f8:	7a02                	ld	s4,32(sp)
    800028fa:	6ae2                	ld	s5,24(sp)
    800028fc:	6b42                	ld	s6,16(sp)
    800028fe:	6ba2                	ld	s7,8(sp)
    80002900:	6161                	addi	sp,sp,80
    80002902:	8082                	ret

0000000080002904 <swtch>:
    80002904:	00153023          	sd	ra,0(a0)
    80002908:	00253423          	sd	sp,8(a0)
    8000290c:	e900                	sd	s0,16(a0)
    8000290e:	ed04                	sd	s1,24(a0)
    80002910:	03253023          	sd	s2,32(a0)
    80002914:	03353423          	sd	s3,40(a0)
    80002918:	03453823          	sd	s4,48(a0)
    8000291c:	03553c23          	sd	s5,56(a0)
    80002920:	05653023          	sd	s6,64(a0)
    80002924:	05753423          	sd	s7,72(a0)
    80002928:	05853823          	sd	s8,80(a0)
    8000292c:	05953c23          	sd	s9,88(a0)
    80002930:	07a53023          	sd	s10,96(a0)
    80002934:	07b53423          	sd	s11,104(a0)
    80002938:	0005b083          	ld	ra,0(a1)
    8000293c:	0085b103          	ld	sp,8(a1)
    80002940:	6980                	ld	s0,16(a1)
    80002942:	6d84                	ld	s1,24(a1)
    80002944:	0205b903          	ld	s2,32(a1)
    80002948:	0285b983          	ld	s3,40(a1)
    8000294c:	0305ba03          	ld	s4,48(a1)
    80002950:	0385ba83          	ld	s5,56(a1)
    80002954:	0405bb03          	ld	s6,64(a1)
    80002958:	0485bb83          	ld	s7,72(a1)
    8000295c:	0505bc03          	ld	s8,80(a1)
    80002960:	0585bc83          	ld	s9,88(a1)
    80002964:	0605bd03          	ld	s10,96(a1)
    80002968:	0685bd83          	ld	s11,104(a1)
    8000296c:	8082                	ret

000000008000296e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000296e:	1141                	addi	sp,sp,-16
    80002970:	e406                	sd	ra,8(sp)
    80002972:	e022                	sd	s0,0(sp)
    80002974:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002976:	00006597          	auipc	a1,0x6
    8000297a:	9ea58593          	addi	a1,a1,-1558 # 80008360 <states.1712+0x28>
    8000297e:	00016517          	auipc	a0,0x16
    80002982:	a5250513          	addi	a0,a0,-1454 # 800183d0 <tickslock>
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	4e6080e7          	jalr	1254(ra) # 80000e6c <initlock>
}
    8000298e:	60a2                	ld	ra,8(sp)
    80002990:	6402                	ld	s0,0(sp)
    80002992:	0141                	addi	sp,sp,16
    80002994:	8082                	ret

0000000080002996 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002996:	1141                	addi	sp,sp,-16
    80002998:	e422                	sd	s0,8(sp)
    8000299a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000299c:	00003797          	auipc	a5,0x3
    800029a0:	66478793          	addi	a5,a5,1636 # 80006000 <kernelvec>
    800029a4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029a8:	6422                	ld	s0,8(sp)
    800029aa:	0141                	addi	sp,sp,16
    800029ac:	8082                	ret

00000000800029ae <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029ae:	1141                	addi	sp,sp,-16
    800029b0:	e406                	sd	ra,8(sp)
    800029b2:	e022                	sd	s0,0(sp)
    800029b4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029b6:	fffff097          	auipc	ra,0xfffff
    800029ba:	382080e7          	jalr	898(ra) # 80001d38 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029be:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029c2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800029c8:	00004617          	auipc	a2,0x4
    800029cc:	63860613          	addi	a2,a2,1592 # 80007000 <_trampoline>
    800029d0:	00004697          	auipc	a3,0x4
    800029d4:	63068693          	addi	a3,a3,1584 # 80007000 <_trampoline>
    800029d8:	8e91                	sub	a3,a3,a2
    800029da:	040007b7          	lui	a5,0x4000
    800029de:	17fd                	addi	a5,a5,-1
    800029e0:	07b2                	slli	a5,a5,0xc
    800029e2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029e4:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029e8:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029ea:	180026f3          	csrr	a3,satp
    800029ee:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029f0:	7138                	ld	a4,96(a0)
    800029f2:	6534                	ld	a3,72(a0)
    800029f4:	6585                	lui	a1,0x1
    800029f6:	96ae                	add	a3,a3,a1
    800029f8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029fa:	7138                	ld	a4,96(a0)
    800029fc:	00000697          	auipc	a3,0x0
    80002a00:	13868693          	addi	a3,a3,312 # 80002b34 <usertrap>
    80002a04:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a06:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a08:	8692                	mv	a3,tp
    80002a0a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a0c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a10:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a14:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a18:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a1c:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a1e:	6f18                	ld	a4,24(a4)
    80002a20:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a24:	6d2c                	ld	a1,88(a0)
    80002a26:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a28:	00004717          	auipc	a4,0x4
    80002a2c:	66870713          	addi	a4,a4,1640 # 80007090 <userret>
    80002a30:	8f11                	sub	a4,a4,a2
    80002a32:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002a34:	577d                	li	a4,-1
    80002a36:	177e                	slli	a4,a4,0x3f
    80002a38:	8dd9                	or	a1,a1,a4
    80002a3a:	02000537          	lui	a0,0x2000
    80002a3e:	157d                	addi	a0,a0,-1
    80002a40:	0536                	slli	a0,a0,0xd
    80002a42:	9782                	jalr	a5
}
    80002a44:	60a2                	ld	ra,8(sp)
    80002a46:	6402                	ld	s0,0(sp)
    80002a48:	0141                	addi	sp,sp,16
    80002a4a:	8082                	ret

0000000080002a4c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a4c:	1101                	addi	sp,sp,-32
    80002a4e:	ec06                	sd	ra,24(sp)
    80002a50:	e822                	sd	s0,16(sp)
    80002a52:	e426                	sd	s1,8(sp)
    80002a54:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a56:	00016497          	auipc	s1,0x16
    80002a5a:	97a48493          	addi	s1,s1,-1670 # 800183d0 <tickslock>
    80002a5e:	8526                	mv	a0,s1
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	290080e7          	jalr	656(ra) # 80000cf0 <acquire>
  ticks++;
    80002a68:	00006517          	auipc	a0,0x6
    80002a6c:	5b850513          	addi	a0,a0,1464 # 80009020 <ticks>
    80002a70:	411c                	lw	a5,0(a0)
    80002a72:	2785                	addiw	a5,a5,1
    80002a74:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a76:	00000097          	auipc	ra,0x0
    80002a7a:	c58080e7          	jalr	-936(ra) # 800026ce <wakeup>
  release(&tickslock);
    80002a7e:	8526                	mv	a0,s1
    80002a80:	ffffe097          	auipc	ra,0xffffe
    80002a84:	340080e7          	jalr	832(ra) # 80000dc0 <release>
}
    80002a88:	60e2                	ld	ra,24(sp)
    80002a8a:	6442                	ld	s0,16(sp)
    80002a8c:	64a2                	ld	s1,8(sp)
    80002a8e:	6105                	addi	sp,sp,32
    80002a90:	8082                	ret

0000000080002a92 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a92:	1101                	addi	sp,sp,-32
    80002a94:	ec06                	sd	ra,24(sp)
    80002a96:	e822                	sd	s0,16(sp)
    80002a98:	e426                	sd	s1,8(sp)
    80002a9a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a9c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002aa0:	00074d63          	bltz	a4,80002aba <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002aa4:	57fd                	li	a5,-1
    80002aa6:	17fe                	slli	a5,a5,0x3f
    80002aa8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002aaa:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002aac:	06f70363          	beq	a4,a5,80002b12 <devintr+0x80>
  }
}
    80002ab0:	60e2                	ld	ra,24(sp)
    80002ab2:	6442                	ld	s0,16(sp)
    80002ab4:	64a2                	ld	s1,8(sp)
    80002ab6:	6105                	addi	sp,sp,32
    80002ab8:	8082                	ret
     (scause & 0xff) == 9){
    80002aba:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002abe:	46a5                	li	a3,9
    80002ac0:	fed792e3          	bne	a5,a3,80002aa4 <devintr+0x12>
    int irq = plic_claim();
    80002ac4:	00003097          	auipc	ra,0x3
    80002ac8:	644080e7          	jalr	1604(ra) # 80006108 <plic_claim>
    80002acc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ace:	47a9                	li	a5,10
    80002ad0:	02f50763          	beq	a0,a5,80002afe <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002ad4:	4785                	li	a5,1
    80002ad6:	02f50963          	beq	a0,a5,80002b08 <devintr+0x76>
    return 1;
    80002ada:	4505                	li	a0,1
    } else if(irq){
    80002adc:	d8f1                	beqz	s1,80002ab0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ade:	85a6                	mv	a1,s1
    80002ae0:	00006517          	auipc	a0,0x6
    80002ae4:	88850513          	addi	a0,a0,-1912 # 80008368 <states.1712+0x30>
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	ab2080e7          	jalr	-1358(ra) # 8000059a <printf>
      plic_complete(irq);
    80002af0:	8526                	mv	a0,s1
    80002af2:	00003097          	auipc	ra,0x3
    80002af6:	63a080e7          	jalr	1594(ra) # 8000612c <plic_complete>
    return 1;
    80002afa:	4505                	li	a0,1
    80002afc:	bf55                	j	80002ab0 <devintr+0x1e>
      uartintr();
    80002afe:	ffffe097          	auipc	ra,0xffffe
    80002b02:	ede080e7          	jalr	-290(ra) # 800009dc <uartintr>
    80002b06:	b7ed                	j	80002af0 <devintr+0x5e>
      virtio_disk_intr();
    80002b08:	00004097          	auipc	ra,0x4
    80002b0c:	b04080e7          	jalr	-1276(ra) # 8000660c <virtio_disk_intr>
    80002b10:	b7c5                	j	80002af0 <devintr+0x5e>
    if(cpuid() == 0){
    80002b12:	fffff097          	auipc	ra,0xfffff
    80002b16:	1fa080e7          	jalr	506(ra) # 80001d0c <cpuid>
    80002b1a:	c901                	beqz	a0,80002b2a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b1c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b20:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b22:	14479073          	csrw	sip,a5
    return 2;
    80002b26:	4509                	li	a0,2
    80002b28:	b761                	j	80002ab0 <devintr+0x1e>
      clockintr();
    80002b2a:	00000097          	auipc	ra,0x0
    80002b2e:	f22080e7          	jalr	-222(ra) # 80002a4c <clockintr>
    80002b32:	b7ed                	j	80002b1c <devintr+0x8a>

0000000080002b34 <usertrap>:
{
    80002b34:	1101                	addi	sp,sp,-32
    80002b36:	ec06                	sd	ra,24(sp)
    80002b38:	e822                	sd	s0,16(sp)
    80002b3a:	e426                	sd	s1,8(sp)
    80002b3c:	e04a                	sd	s2,0(sp)
    80002b3e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b40:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b44:	1007f793          	andi	a5,a5,256
    80002b48:	e3ad                	bnez	a5,80002baa <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b4a:	00003797          	auipc	a5,0x3
    80002b4e:	4b678793          	addi	a5,a5,1206 # 80006000 <kernelvec>
    80002b52:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b56:	fffff097          	auipc	ra,0xfffff
    80002b5a:	1e2080e7          	jalr	482(ra) # 80001d38 <myproc>
    80002b5e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b60:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b62:	14102773          	csrr	a4,sepc
    80002b66:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b68:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b6c:	47a1                	li	a5,8
    80002b6e:	04f71c63          	bne	a4,a5,80002bc6 <usertrap+0x92>
    if(p->killed)
    80002b72:	5d1c                	lw	a5,56(a0)
    80002b74:	e3b9                	bnez	a5,80002bba <usertrap+0x86>
    p->trapframe->epc += 4;
    80002b76:	70b8                	ld	a4,96(s1)
    80002b78:	6f1c                	ld	a5,24(a4)
    80002b7a:	0791                	addi	a5,a5,4
    80002b7c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b86:	10079073          	csrw	sstatus,a5
    syscall();
    80002b8a:	00000097          	auipc	ra,0x0
    80002b8e:	2e0080e7          	jalr	736(ra) # 80002e6a <syscall>
  if(p->killed)
    80002b92:	5c9c                	lw	a5,56(s1)
    80002b94:	ebc1                	bnez	a5,80002c24 <usertrap+0xf0>
  usertrapret();
    80002b96:	00000097          	auipc	ra,0x0
    80002b9a:	e18080e7          	jalr	-488(ra) # 800029ae <usertrapret>
}
    80002b9e:	60e2                	ld	ra,24(sp)
    80002ba0:	6442                	ld	s0,16(sp)
    80002ba2:	64a2                	ld	s1,8(sp)
    80002ba4:	6902                	ld	s2,0(sp)
    80002ba6:	6105                	addi	sp,sp,32
    80002ba8:	8082                	ret
    panic("usertrap: not from user mode");
    80002baa:	00005517          	auipc	a0,0x5
    80002bae:	7de50513          	addi	a0,a0,2014 # 80008388 <states.1712+0x50>
    80002bb2:	ffffe097          	auipc	ra,0xffffe
    80002bb6:	99e080e7          	jalr	-1634(ra) # 80000550 <panic>
      exit(-1);
    80002bba:	557d                	li	a0,-1
    80002bbc:	00000097          	auipc	ra,0x0
    80002bc0:	846080e7          	jalr	-1978(ra) # 80002402 <exit>
    80002bc4:	bf4d                	j	80002b76 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	ecc080e7          	jalr	-308(ra) # 80002a92 <devintr>
    80002bce:	892a                	mv	s2,a0
    80002bd0:	c501                	beqz	a0,80002bd8 <usertrap+0xa4>
  if(p->killed)
    80002bd2:	5c9c                	lw	a5,56(s1)
    80002bd4:	c3a1                	beqz	a5,80002c14 <usertrap+0xe0>
    80002bd6:	a815                	j	80002c0a <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bdc:	40b0                	lw	a2,64(s1)
    80002bde:	00005517          	auipc	a0,0x5
    80002be2:	7ca50513          	addi	a0,a0,1994 # 800083a8 <states.1712+0x70>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	9b4080e7          	jalr	-1612(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bee:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bf2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bf6:	00005517          	auipc	a0,0x5
    80002bfa:	7e250513          	addi	a0,a0,2018 # 800083d8 <states.1712+0xa0>
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	99c080e7          	jalr	-1636(ra) # 8000059a <printf>
    p->killed = 1;
    80002c06:	4785                	li	a5,1
    80002c08:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002c0a:	557d                	li	a0,-1
    80002c0c:	fffff097          	auipc	ra,0xfffff
    80002c10:	7f6080e7          	jalr	2038(ra) # 80002402 <exit>
  if(which_dev == 2)
    80002c14:	4789                	li	a5,2
    80002c16:	f8f910e3          	bne	s2,a5,80002b96 <usertrap+0x62>
    yield();
    80002c1a:	00000097          	auipc	ra,0x0
    80002c1e:	8f2080e7          	jalr	-1806(ra) # 8000250c <yield>
    80002c22:	bf95                	j	80002b96 <usertrap+0x62>
  int which_dev = 0;
    80002c24:	4901                	li	s2,0
    80002c26:	b7d5                	j	80002c0a <usertrap+0xd6>

0000000080002c28 <kerneltrap>:
{
    80002c28:	7179                	addi	sp,sp,-48
    80002c2a:	f406                	sd	ra,40(sp)
    80002c2c:	f022                	sd	s0,32(sp)
    80002c2e:	ec26                	sd	s1,24(sp)
    80002c30:	e84a                	sd	s2,16(sp)
    80002c32:	e44e                	sd	s3,8(sp)
    80002c34:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c36:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c3a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c3e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c42:	1004f793          	andi	a5,s1,256
    80002c46:	cb85                	beqz	a5,80002c76 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c4c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c4e:	ef85                	bnez	a5,80002c86 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c50:	00000097          	auipc	ra,0x0
    80002c54:	e42080e7          	jalr	-446(ra) # 80002a92 <devintr>
    80002c58:	cd1d                	beqz	a0,80002c96 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c5a:	4789                	li	a5,2
    80002c5c:	06f50a63          	beq	a0,a5,80002cd0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c60:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c64:	10049073          	csrw	sstatus,s1
}
    80002c68:	70a2                	ld	ra,40(sp)
    80002c6a:	7402                	ld	s0,32(sp)
    80002c6c:	64e2                	ld	s1,24(sp)
    80002c6e:	6942                	ld	s2,16(sp)
    80002c70:	69a2                	ld	s3,8(sp)
    80002c72:	6145                	addi	sp,sp,48
    80002c74:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c76:	00005517          	auipc	a0,0x5
    80002c7a:	78250513          	addi	a0,a0,1922 # 800083f8 <states.1712+0xc0>
    80002c7e:	ffffe097          	auipc	ra,0xffffe
    80002c82:	8d2080e7          	jalr	-1838(ra) # 80000550 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c86:	00005517          	auipc	a0,0x5
    80002c8a:	79a50513          	addi	a0,a0,1946 # 80008420 <states.1712+0xe8>
    80002c8e:	ffffe097          	auipc	ra,0xffffe
    80002c92:	8c2080e7          	jalr	-1854(ra) # 80000550 <panic>
    printf("scause %p\n", scause);
    80002c96:	85ce                	mv	a1,s3
    80002c98:	00005517          	auipc	a0,0x5
    80002c9c:	7a850513          	addi	a0,a0,1960 # 80008440 <states.1712+0x108>
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	8fa080e7          	jalr	-1798(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ca8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cac:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cb0:	00005517          	auipc	a0,0x5
    80002cb4:	7a050513          	addi	a0,a0,1952 # 80008450 <states.1712+0x118>
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	8e2080e7          	jalr	-1822(ra) # 8000059a <printf>
    panic("kerneltrap");
    80002cc0:	00005517          	auipc	a0,0x5
    80002cc4:	7a850513          	addi	a0,a0,1960 # 80008468 <states.1712+0x130>
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	888080e7          	jalr	-1912(ra) # 80000550 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	068080e7          	jalr	104(ra) # 80001d38 <myproc>
    80002cd8:	d541                	beqz	a0,80002c60 <kerneltrap+0x38>
    80002cda:	fffff097          	auipc	ra,0xfffff
    80002cde:	05e080e7          	jalr	94(ra) # 80001d38 <myproc>
    80002ce2:	5118                	lw	a4,32(a0)
    80002ce4:	478d                	li	a5,3
    80002ce6:	f6f71de3          	bne	a4,a5,80002c60 <kerneltrap+0x38>
    yield();
    80002cea:	00000097          	auipc	ra,0x0
    80002cee:	822080e7          	jalr	-2014(ra) # 8000250c <yield>
    80002cf2:	b7bd                	j	80002c60 <kerneltrap+0x38>

0000000080002cf4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	e426                	sd	s1,8(sp)
    80002cfc:	1000                	addi	s0,sp,32
    80002cfe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d00:	fffff097          	auipc	ra,0xfffff
    80002d04:	038080e7          	jalr	56(ra) # 80001d38 <myproc>
  switch (n) {
    80002d08:	4795                	li	a5,5
    80002d0a:	0497e163          	bltu	a5,s1,80002d4c <argraw+0x58>
    80002d0e:	048a                	slli	s1,s1,0x2
    80002d10:	00005717          	auipc	a4,0x5
    80002d14:	79070713          	addi	a4,a4,1936 # 800084a0 <states.1712+0x168>
    80002d18:	94ba                	add	s1,s1,a4
    80002d1a:	409c                	lw	a5,0(s1)
    80002d1c:	97ba                	add	a5,a5,a4
    80002d1e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d20:	713c                	ld	a5,96(a0)
    80002d22:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6105                	addi	sp,sp,32
    80002d2c:	8082                	ret
    return p->trapframe->a1;
    80002d2e:	713c                	ld	a5,96(a0)
    80002d30:	7fa8                	ld	a0,120(a5)
    80002d32:	bfcd                	j	80002d24 <argraw+0x30>
    return p->trapframe->a2;
    80002d34:	713c                	ld	a5,96(a0)
    80002d36:	63c8                	ld	a0,128(a5)
    80002d38:	b7f5                	j	80002d24 <argraw+0x30>
    return p->trapframe->a3;
    80002d3a:	713c                	ld	a5,96(a0)
    80002d3c:	67c8                	ld	a0,136(a5)
    80002d3e:	b7dd                	j	80002d24 <argraw+0x30>
    return p->trapframe->a4;
    80002d40:	713c                	ld	a5,96(a0)
    80002d42:	6bc8                	ld	a0,144(a5)
    80002d44:	b7c5                	j	80002d24 <argraw+0x30>
    return p->trapframe->a5;
    80002d46:	713c                	ld	a5,96(a0)
    80002d48:	6fc8                	ld	a0,152(a5)
    80002d4a:	bfe9                	j	80002d24 <argraw+0x30>
  panic("argraw");
    80002d4c:	00005517          	auipc	a0,0x5
    80002d50:	72c50513          	addi	a0,a0,1836 # 80008478 <states.1712+0x140>
    80002d54:	ffffd097          	auipc	ra,0xffffd
    80002d58:	7fc080e7          	jalr	2044(ra) # 80000550 <panic>

0000000080002d5c <fetchaddr>:
{
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	e426                	sd	s1,8(sp)
    80002d64:	e04a                	sd	s2,0(sp)
    80002d66:	1000                	addi	s0,sp,32
    80002d68:	84aa                	mv	s1,a0
    80002d6a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d6c:	fffff097          	auipc	ra,0xfffff
    80002d70:	fcc080e7          	jalr	-52(ra) # 80001d38 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d74:	693c                	ld	a5,80(a0)
    80002d76:	02f4f863          	bgeu	s1,a5,80002da6 <fetchaddr+0x4a>
    80002d7a:	00848713          	addi	a4,s1,8
    80002d7e:	02e7e663          	bltu	a5,a4,80002daa <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d82:	46a1                	li	a3,8
    80002d84:	8626                	mv	a2,s1
    80002d86:	85ca                	mv	a1,s2
    80002d88:	6d28                	ld	a0,88(a0)
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	d2e080e7          	jalr	-722(ra) # 80001ab8 <copyin>
    80002d92:	00a03533          	snez	a0,a0
    80002d96:	40a00533          	neg	a0,a0
}
    80002d9a:	60e2                	ld	ra,24(sp)
    80002d9c:	6442                	ld	s0,16(sp)
    80002d9e:	64a2                	ld	s1,8(sp)
    80002da0:	6902                	ld	s2,0(sp)
    80002da2:	6105                	addi	sp,sp,32
    80002da4:	8082                	ret
    return -1;
    80002da6:	557d                	li	a0,-1
    80002da8:	bfcd                	j	80002d9a <fetchaddr+0x3e>
    80002daa:	557d                	li	a0,-1
    80002dac:	b7fd                	j	80002d9a <fetchaddr+0x3e>

0000000080002dae <fetchstr>:
{
    80002dae:	7179                	addi	sp,sp,-48
    80002db0:	f406                	sd	ra,40(sp)
    80002db2:	f022                	sd	s0,32(sp)
    80002db4:	ec26                	sd	s1,24(sp)
    80002db6:	e84a                	sd	s2,16(sp)
    80002db8:	e44e                	sd	s3,8(sp)
    80002dba:	1800                	addi	s0,sp,48
    80002dbc:	892a                	mv	s2,a0
    80002dbe:	84ae                	mv	s1,a1
    80002dc0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002dc2:	fffff097          	auipc	ra,0xfffff
    80002dc6:	f76080e7          	jalr	-138(ra) # 80001d38 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002dca:	86ce                	mv	a3,s3
    80002dcc:	864a                	mv	a2,s2
    80002dce:	85a6                	mv	a1,s1
    80002dd0:	6d28                	ld	a0,88(a0)
    80002dd2:	fffff097          	auipc	ra,0xfffff
    80002dd6:	d72080e7          	jalr	-654(ra) # 80001b44 <copyinstr>
  if(err < 0)
    80002dda:	00054763          	bltz	a0,80002de8 <fetchstr+0x3a>
  return strlen(buf);
    80002dde:	8526                	mv	a0,s1
    80002de0:	ffffe097          	auipc	ra,0xffffe
    80002de4:	478080e7          	jalr	1144(ra) # 80001258 <strlen>
}
    80002de8:	70a2                	ld	ra,40(sp)
    80002dea:	7402                	ld	s0,32(sp)
    80002dec:	64e2                	ld	s1,24(sp)
    80002dee:	6942                	ld	s2,16(sp)
    80002df0:	69a2                	ld	s3,8(sp)
    80002df2:	6145                	addi	sp,sp,48
    80002df4:	8082                	ret

0000000080002df6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002df6:	1101                	addi	sp,sp,-32
    80002df8:	ec06                	sd	ra,24(sp)
    80002dfa:	e822                	sd	s0,16(sp)
    80002dfc:	e426                	sd	s1,8(sp)
    80002dfe:	1000                	addi	s0,sp,32
    80002e00:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e02:	00000097          	auipc	ra,0x0
    80002e06:	ef2080e7          	jalr	-270(ra) # 80002cf4 <argraw>
    80002e0a:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e0c:	4501                	li	a0,0
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	64a2                	ld	s1,8(sp)
    80002e14:	6105                	addi	sp,sp,32
    80002e16:	8082                	ret

0000000080002e18 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e18:	1101                	addi	sp,sp,-32
    80002e1a:	ec06                	sd	ra,24(sp)
    80002e1c:	e822                	sd	s0,16(sp)
    80002e1e:	e426                	sd	s1,8(sp)
    80002e20:	1000                	addi	s0,sp,32
    80002e22:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e24:	00000097          	auipc	ra,0x0
    80002e28:	ed0080e7          	jalr	-304(ra) # 80002cf4 <argraw>
    80002e2c:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e2e:	4501                	li	a0,0
    80002e30:	60e2                	ld	ra,24(sp)
    80002e32:	6442                	ld	s0,16(sp)
    80002e34:	64a2                	ld	s1,8(sp)
    80002e36:	6105                	addi	sp,sp,32
    80002e38:	8082                	ret

0000000080002e3a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e3a:	1101                	addi	sp,sp,-32
    80002e3c:	ec06                	sd	ra,24(sp)
    80002e3e:	e822                	sd	s0,16(sp)
    80002e40:	e426                	sd	s1,8(sp)
    80002e42:	e04a                	sd	s2,0(sp)
    80002e44:	1000                	addi	s0,sp,32
    80002e46:	84ae                	mv	s1,a1
    80002e48:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e4a:	00000097          	auipc	ra,0x0
    80002e4e:	eaa080e7          	jalr	-342(ra) # 80002cf4 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e52:	864a                	mv	a2,s2
    80002e54:	85a6                	mv	a1,s1
    80002e56:	00000097          	auipc	ra,0x0
    80002e5a:	f58080e7          	jalr	-168(ra) # 80002dae <fetchstr>
}
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	64a2                	ld	s1,8(sp)
    80002e64:	6902                	ld	s2,0(sp)
    80002e66:	6105                	addi	sp,sp,32
    80002e68:	8082                	ret

0000000080002e6a <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e6a:	1101                	addi	sp,sp,-32
    80002e6c:	ec06                	sd	ra,24(sp)
    80002e6e:	e822                	sd	s0,16(sp)
    80002e70:	e426                	sd	s1,8(sp)
    80002e72:	e04a                	sd	s2,0(sp)
    80002e74:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e76:	fffff097          	auipc	ra,0xfffff
    80002e7a:	ec2080e7          	jalr	-318(ra) # 80001d38 <myproc>
    80002e7e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e80:	06053903          	ld	s2,96(a0)
    80002e84:	0a893783          	ld	a5,168(s2)
    80002e88:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e8c:	37fd                	addiw	a5,a5,-1
    80002e8e:	4751                	li	a4,20
    80002e90:	00f76f63          	bltu	a4,a5,80002eae <syscall+0x44>
    80002e94:	00369713          	slli	a4,a3,0x3
    80002e98:	00005797          	auipc	a5,0x5
    80002e9c:	62078793          	addi	a5,a5,1568 # 800084b8 <syscalls>
    80002ea0:	97ba                	add	a5,a5,a4
    80002ea2:	639c                	ld	a5,0(a5)
    80002ea4:	c789                	beqz	a5,80002eae <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002ea6:	9782                	jalr	a5
    80002ea8:	06a93823          	sd	a0,112(s2)
    80002eac:	a839                	j	80002eca <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002eae:	16048613          	addi	a2,s1,352
    80002eb2:	40ac                	lw	a1,64(s1)
    80002eb4:	00005517          	auipc	a0,0x5
    80002eb8:	5cc50513          	addi	a0,a0,1484 # 80008480 <states.1712+0x148>
    80002ebc:	ffffd097          	auipc	ra,0xffffd
    80002ec0:	6de080e7          	jalr	1758(ra) # 8000059a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ec4:	70bc                	ld	a5,96(s1)
    80002ec6:	577d                	li	a4,-1
    80002ec8:	fbb8                	sd	a4,112(a5)
  }
}
    80002eca:	60e2                	ld	ra,24(sp)
    80002ecc:	6442                	ld	s0,16(sp)
    80002ece:	64a2                	ld	s1,8(sp)
    80002ed0:	6902                	ld	s2,0(sp)
    80002ed2:	6105                	addi	sp,sp,32
    80002ed4:	8082                	ret

0000000080002ed6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ed6:	1101                	addi	sp,sp,-32
    80002ed8:	ec06                	sd	ra,24(sp)
    80002eda:	e822                	sd	s0,16(sp)
    80002edc:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002ede:	fec40593          	addi	a1,s0,-20
    80002ee2:	4501                	li	a0,0
    80002ee4:	00000097          	auipc	ra,0x0
    80002ee8:	f12080e7          	jalr	-238(ra) # 80002df6 <argint>
    return -1;
    80002eec:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002eee:	00054963          	bltz	a0,80002f00 <sys_exit+0x2a>
  exit(n);
    80002ef2:	fec42503          	lw	a0,-20(s0)
    80002ef6:	fffff097          	auipc	ra,0xfffff
    80002efa:	50c080e7          	jalr	1292(ra) # 80002402 <exit>
  return 0;  // not reached
    80002efe:	4781                	li	a5,0
}
    80002f00:	853e                	mv	a0,a5
    80002f02:	60e2                	ld	ra,24(sp)
    80002f04:	6442                	ld	s0,16(sp)
    80002f06:	6105                	addi	sp,sp,32
    80002f08:	8082                	ret

0000000080002f0a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f0a:	1141                	addi	sp,sp,-16
    80002f0c:	e406                	sd	ra,8(sp)
    80002f0e:	e022                	sd	s0,0(sp)
    80002f10:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	e26080e7          	jalr	-474(ra) # 80001d38 <myproc>
}
    80002f1a:	4128                	lw	a0,64(a0)
    80002f1c:	60a2                	ld	ra,8(sp)
    80002f1e:	6402                	ld	s0,0(sp)
    80002f20:	0141                	addi	sp,sp,16
    80002f22:	8082                	ret

0000000080002f24 <sys_fork>:

uint64
sys_fork(void)
{
    80002f24:	1141                	addi	sp,sp,-16
    80002f26:	e406                	sd	ra,8(sp)
    80002f28:	e022                	sd	s0,0(sp)
    80002f2a:	0800                	addi	s0,sp,16
  return fork();
    80002f2c:	fffff097          	auipc	ra,0xfffff
    80002f30:	1cc080e7          	jalr	460(ra) # 800020f8 <fork>
}
    80002f34:	60a2                	ld	ra,8(sp)
    80002f36:	6402                	ld	s0,0(sp)
    80002f38:	0141                	addi	sp,sp,16
    80002f3a:	8082                	ret

0000000080002f3c <sys_wait>:

uint64
sys_wait(void)
{
    80002f3c:	1101                	addi	sp,sp,-32
    80002f3e:	ec06                	sd	ra,24(sp)
    80002f40:	e822                	sd	s0,16(sp)
    80002f42:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f44:	fe840593          	addi	a1,s0,-24
    80002f48:	4501                	li	a0,0
    80002f4a:	00000097          	auipc	ra,0x0
    80002f4e:	ece080e7          	jalr	-306(ra) # 80002e18 <argaddr>
    80002f52:	87aa                	mv	a5,a0
    return -1;
    80002f54:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f56:	0007c863          	bltz	a5,80002f66 <sys_wait+0x2a>
  return wait(p);
    80002f5a:	fe843503          	ld	a0,-24(s0)
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	668080e7          	jalr	1640(ra) # 800025c6 <wait>
}
    80002f66:	60e2                	ld	ra,24(sp)
    80002f68:	6442                	ld	s0,16(sp)
    80002f6a:	6105                	addi	sp,sp,32
    80002f6c:	8082                	ret

0000000080002f6e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f6e:	7179                	addi	sp,sp,-48
    80002f70:	f406                	sd	ra,40(sp)
    80002f72:	f022                	sd	s0,32(sp)
    80002f74:	ec26                	sd	s1,24(sp)
    80002f76:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f78:	fdc40593          	addi	a1,s0,-36
    80002f7c:	4501                	li	a0,0
    80002f7e:	00000097          	auipc	ra,0x0
    80002f82:	e78080e7          	jalr	-392(ra) # 80002df6 <argint>
    80002f86:	87aa                	mv	a5,a0
    return -1;
    80002f88:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002f8a:	0207c063          	bltz	a5,80002faa <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002f8e:	fffff097          	auipc	ra,0xfffff
    80002f92:	daa080e7          	jalr	-598(ra) # 80001d38 <myproc>
    80002f96:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002f98:	fdc42503          	lw	a0,-36(s0)
    80002f9c:	fffff097          	auipc	ra,0xfffff
    80002fa0:	0e8080e7          	jalr	232(ra) # 80002084 <growproc>
    80002fa4:	00054863          	bltz	a0,80002fb4 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002fa8:	8526                	mv	a0,s1
}
    80002faa:	70a2                	ld	ra,40(sp)
    80002fac:	7402                	ld	s0,32(sp)
    80002fae:	64e2                	ld	s1,24(sp)
    80002fb0:	6145                	addi	sp,sp,48
    80002fb2:	8082                	ret
    return -1;
    80002fb4:	557d                	li	a0,-1
    80002fb6:	bfd5                	j	80002faa <sys_sbrk+0x3c>

0000000080002fb8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fb8:	7139                	addi	sp,sp,-64
    80002fba:	fc06                	sd	ra,56(sp)
    80002fbc:	f822                	sd	s0,48(sp)
    80002fbe:	f426                	sd	s1,40(sp)
    80002fc0:	f04a                	sd	s2,32(sp)
    80002fc2:	ec4e                	sd	s3,24(sp)
    80002fc4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002fc6:	fcc40593          	addi	a1,s0,-52
    80002fca:	4501                	li	a0,0
    80002fcc:	00000097          	auipc	ra,0x0
    80002fd0:	e2a080e7          	jalr	-470(ra) # 80002df6 <argint>
    return -1;
    80002fd4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002fd6:	06054563          	bltz	a0,80003040 <sys_sleep+0x88>
  acquire(&tickslock);
    80002fda:	00015517          	auipc	a0,0x15
    80002fde:	3f650513          	addi	a0,a0,1014 # 800183d0 <tickslock>
    80002fe2:	ffffe097          	auipc	ra,0xffffe
    80002fe6:	d0e080e7          	jalr	-754(ra) # 80000cf0 <acquire>
  ticks0 = ticks;
    80002fea:	00006917          	auipc	s2,0x6
    80002fee:	03692903          	lw	s2,54(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002ff2:	fcc42783          	lw	a5,-52(s0)
    80002ff6:	cf85                	beqz	a5,8000302e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ff8:	00015997          	auipc	s3,0x15
    80002ffc:	3d898993          	addi	s3,s3,984 # 800183d0 <tickslock>
    80003000:	00006497          	auipc	s1,0x6
    80003004:	02048493          	addi	s1,s1,32 # 80009020 <ticks>
    if(myproc()->killed){
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	d30080e7          	jalr	-720(ra) # 80001d38 <myproc>
    80003010:	5d1c                	lw	a5,56(a0)
    80003012:	ef9d                	bnez	a5,80003050 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003014:	85ce                	mv	a1,s3
    80003016:	8526                	mv	a0,s1
    80003018:	fffff097          	auipc	ra,0xfffff
    8000301c:	530080e7          	jalr	1328(ra) # 80002548 <sleep>
  while(ticks - ticks0 < n){
    80003020:	409c                	lw	a5,0(s1)
    80003022:	412787bb          	subw	a5,a5,s2
    80003026:	fcc42703          	lw	a4,-52(s0)
    8000302a:	fce7efe3          	bltu	a5,a4,80003008 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000302e:	00015517          	auipc	a0,0x15
    80003032:	3a250513          	addi	a0,a0,930 # 800183d0 <tickslock>
    80003036:	ffffe097          	auipc	ra,0xffffe
    8000303a:	d8a080e7          	jalr	-630(ra) # 80000dc0 <release>
  return 0;
    8000303e:	4781                	li	a5,0
}
    80003040:	853e                	mv	a0,a5
    80003042:	70e2                	ld	ra,56(sp)
    80003044:	7442                	ld	s0,48(sp)
    80003046:	74a2                	ld	s1,40(sp)
    80003048:	7902                	ld	s2,32(sp)
    8000304a:	69e2                	ld	s3,24(sp)
    8000304c:	6121                	addi	sp,sp,64
    8000304e:	8082                	ret
      release(&tickslock);
    80003050:	00015517          	auipc	a0,0x15
    80003054:	38050513          	addi	a0,a0,896 # 800183d0 <tickslock>
    80003058:	ffffe097          	auipc	ra,0xffffe
    8000305c:	d68080e7          	jalr	-664(ra) # 80000dc0 <release>
      return -1;
    80003060:	57fd                	li	a5,-1
    80003062:	bff9                	j	80003040 <sys_sleep+0x88>

0000000080003064 <sys_kill>:

uint64
sys_kill(void)
{
    80003064:	1101                	addi	sp,sp,-32
    80003066:	ec06                	sd	ra,24(sp)
    80003068:	e822                	sd	s0,16(sp)
    8000306a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000306c:	fec40593          	addi	a1,s0,-20
    80003070:	4501                	li	a0,0
    80003072:	00000097          	auipc	ra,0x0
    80003076:	d84080e7          	jalr	-636(ra) # 80002df6 <argint>
    8000307a:	87aa                	mv	a5,a0
    return -1;
    8000307c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000307e:	0007c863          	bltz	a5,8000308e <sys_kill+0x2a>
  return kill(pid);
    80003082:	fec42503          	lw	a0,-20(s0)
    80003086:	fffff097          	auipc	ra,0xfffff
    8000308a:	6b2080e7          	jalr	1714(ra) # 80002738 <kill>
}
    8000308e:	60e2                	ld	ra,24(sp)
    80003090:	6442                	ld	s0,16(sp)
    80003092:	6105                	addi	sp,sp,32
    80003094:	8082                	ret

0000000080003096 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003096:	1101                	addi	sp,sp,-32
    80003098:	ec06                	sd	ra,24(sp)
    8000309a:	e822                	sd	s0,16(sp)
    8000309c:	e426                	sd	s1,8(sp)
    8000309e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030a0:	00015517          	auipc	a0,0x15
    800030a4:	33050513          	addi	a0,a0,816 # 800183d0 <tickslock>
    800030a8:	ffffe097          	auipc	ra,0xffffe
    800030ac:	c48080e7          	jalr	-952(ra) # 80000cf0 <acquire>
  xticks = ticks;
    800030b0:	00006497          	auipc	s1,0x6
    800030b4:	f704a483          	lw	s1,-144(s1) # 80009020 <ticks>
  release(&tickslock);
    800030b8:	00015517          	auipc	a0,0x15
    800030bc:	31850513          	addi	a0,a0,792 # 800183d0 <tickslock>
    800030c0:	ffffe097          	auipc	ra,0xffffe
    800030c4:	d00080e7          	jalr	-768(ra) # 80000dc0 <release>
  return xticks;
}
    800030c8:	02049513          	slli	a0,s1,0x20
    800030cc:	9101                	srli	a0,a0,0x20
    800030ce:	60e2                	ld	ra,24(sp)
    800030d0:	6442                	ld	s0,16(sp)
    800030d2:	64a2                	ld	s1,8(sp)
    800030d4:	6105                	addi	sp,sp,32
    800030d6:	8082                	ret

00000000800030d8 <binit>:
// }

/** 版本1 */
void
binit(void)
{
    800030d8:	7179                	addi	sp,sp,-48
    800030da:	f406                	sd	ra,40(sp)
    800030dc:	f022                	sd	s0,32(sp)
    800030de:	ec26                	sd	s1,24(sp)
    800030e0:	e84a                	sd	s2,16(sp)
    800030e2:	e44e                	sd	s3,8(sp)
    800030e4:	e052                	sd	s4,0(sp)
    800030e6:	1800                	addi	s0,sp,48
  struct buf *b;

  for(int i=0; i<NBUCKET; i++) 
    800030e8:	00021497          	auipc	s1,0x21
    800030ec:	08048493          	addi	s1,s1,128 # 80024168 <bcache+0xbd78>
    800030f0:	00021997          	auipc	s3,0x21
    800030f4:	21898993          	addi	s3,s3,536 # 80024308 <sb>
    initlock(&bcache.lks[i], "bcache");
    800030f8:	00005917          	auipc	s2,0x5
    800030fc:	00890913          	addi	s2,s2,8 # 80008100 <digits+0xc0>
    80003100:	85ca                	mv	a1,s2
    80003102:	8526                	mv	a0,s1
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	d68080e7          	jalr	-664(ra) # 80000e6c <initlock>
  for(int i=0; i<NBUCKET; i++) 
    8000310c:	02048493          	addi	s1,s1,32
    80003110:	ff3498e3          	bne	s1,s3,80003100 <binit+0x28>
    80003114:	0001d797          	auipc	a5,0x1d
    80003118:	70c78793          	addi	a5,a5,1804 # 80020820 <bcache+0x8430>
    8000311c:	00015717          	auipc	a4,0x15
    80003120:	2d470713          	addi	a4,a4,724 # 800183f0 <bcache>
    80003124:	66b1                	lui	a3,0xc
    80003126:	d7868693          	addi	a3,a3,-648 # bd78 <_entry-0x7fff4288>
    8000312a:	9736                	add	a4,a4,a3

  // Create linked list of buffers
  for(int i=0; i<NBUCKET; i++) {
    bcache.buckets[i].prev = &bcache.buckets[i];
    8000312c:	ebbc                	sd	a5,80(a5)
    bcache.buckets[i].next = &bcache.buckets[i];
    8000312e:	efbc                	sd	a5,88(a5)
  for(int i=0; i<NBUCKET; i++) {
    80003130:	46878793          	addi	a5,a5,1128
    80003134:	fee79ce3          	bne	a5,a4,8000312c <binit+0x54>
  /**
   * buf一开始全部挂载至0号哈希桶，
   * 这样方便后续接济其他哈希桶，因为
   * 有的哈希桶里可能没有buf 
   * */
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003138:	00015497          	auipc	s1,0x15
    8000313c:	2b848493          	addi	s1,s1,696 # 800183f0 <bcache>
    b->next = bcache.buckets[0].next;
    80003140:	0001d917          	auipc	s2,0x1d
    80003144:	2b090913          	addi	s2,s2,688 # 800203f0 <bcache+0x8000>
    b->prev = &bcache.buckets[0];
    80003148:	0001d997          	auipc	s3,0x1d
    8000314c:	6d898993          	addi	s3,s3,1752 # 80020820 <bcache+0x8430>
    initsleeplock(&b->lock, "buffer");
    80003150:	00005a17          	auipc	s4,0x5
    80003154:	418a0a13          	addi	s4,s4,1048 # 80008568 <syscalls+0xb0>
    b->next = bcache.buckets[0].next;
    80003158:	48893783          	ld	a5,1160(s2)
    8000315c:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.buckets[0];
    8000315e:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80003162:	85d2                	mv	a1,s4
    80003164:	01048513          	addi	a0,s1,16
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	612080e7          	jalr	1554(ra) # 8000477a <initsleeplock>
    bcache.buckets[0].next->prev = b;
    80003170:	48893783          	ld	a5,1160(s2)
    80003174:	eba4                	sd	s1,80(a5)
    bcache.buckets[0].next = b;
    80003176:	48993423          	sd	s1,1160(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000317a:	46848493          	addi	s1,s1,1128
    8000317e:	fd349de3          	bne	s1,s3,80003158 <binit+0x80>
  }
}
    80003182:	70a2                	ld	ra,40(sp)
    80003184:	7402                	ld	s0,32(sp)
    80003186:	64e2                	ld	s1,24(sp)
    80003188:	6942                	ld	s2,16(sp)
    8000318a:	69a2                	ld	s3,8(sp)
    8000318c:	6a02                	ld	s4,0(sp)
    8000318e:	6145                	addi	sp,sp,48
    80003190:	8082                	ret

0000000080003192 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003192:	7159                	addi	sp,sp,-112
    80003194:	f486                	sd	ra,104(sp)
    80003196:	f0a2                	sd	s0,96(sp)
    80003198:	eca6                	sd	s1,88(sp)
    8000319a:	e8ca                	sd	s2,80(sp)
    8000319c:	e4ce                	sd	s3,72(sp)
    8000319e:	e0d2                	sd	s4,64(sp)
    800031a0:	fc56                	sd	s5,56(sp)
    800031a2:	f85a                	sd	s6,48(sp)
    800031a4:	f45e                	sd	s7,40(sp)
    800031a6:	f062                	sd	s8,32(sp)
    800031a8:	ec66                	sd	s9,24(sp)
    800031aa:	e86a                	sd	s10,16(sp)
    800031ac:	e46e                	sd	s11,8(sp)
    800031ae:	1880                	addi	s0,sp,112
    800031b0:	8b2a                	mv	s6,a0
    800031b2:	8aae                	mv	s5,a1
  return x%NBUCKET;
    800031b4:	4a35                	li	s4,13
    800031b6:	0345ea3b          	remw	s4,a1,s4
  acquire(&bcache.lks[id]);
    800031ba:	005a1993          	slli	s3,s4,0x5
    800031be:	67b1                	lui	a5,0xc
    800031c0:	d7878793          	addi	a5,a5,-648 # bd78 <_entry-0x7fff4288>
    800031c4:	99be                	add	s3,s3,a5
    800031c6:	00015497          	auipc	s1,0x15
    800031ca:	22a48493          	addi	s1,s1,554 # 800183f0 <bcache>
    800031ce:	99a6                	add	s3,s3,s1
    800031d0:	854e                	mv	a0,s3
    800031d2:	ffffe097          	auipc	ra,0xffffe
    800031d6:	b1e080e7          	jalr	-1250(ra) # 80000cf0 <acquire>
  for(b = bcache.buckets[id].next; b != &bcache.buckets[id]; b = b->next){
    800031da:	46800713          	li	a4,1128
    800031de:	02ea0733          	mul	a4,s4,a4
    800031e2:	00e487b3          	add	a5,s1,a4
    800031e6:	66a1                	lui	a3,0x8
    800031e8:	97b6                	add	a5,a5,a3
    800031ea:	4887b783          	ld	a5,1160(a5)
    800031ee:	43068913          	addi	s2,a3,1072 # 8430 <_entry-0x7fff7bd0>
    800031f2:	974a                	add	a4,a4,s2
    800031f4:	00970933          	add	s2,a4,s1
    800031f8:	09278f63          	beq	a5,s2,80003296 <bread+0x104>
    800031fc:	84be                	mv	s1,a5
    800031fe:	a021                	j	80003206 <bread+0x74>
    80003200:	6ca4                	ld	s1,88(s1)
    80003202:	1b248163          	beq	s1,s2,800033a4 <bread+0x212>
    if(b->dev == dev && b->blockno == blockno){
    80003206:	4498                	lw	a4,8(s1)
    80003208:	ff671ce3          	bne	a4,s6,80003200 <bread+0x6e>
    8000320c:	44d8                	lw	a4,12(s1)
    8000320e:	ff5719e3          	bne	a4,s5,80003200 <bread+0x6e>
      b->refcnt++;
    80003212:	44bc                	lw	a5,72(s1)
    80003214:	2785                	addiw	a5,a5,1
    80003216:	c4bc                	sw	a5,72(s1)
      release(&bcache.lks[id]);
    80003218:	854e                	mv	a0,s3
    8000321a:	ffffe097          	auipc	ra,0xffffe
    8000321e:	ba6080e7          	jalr	-1114(ra) # 80000dc0 <release>
      acquiresleep(&b->lock);
    80003222:	01048513          	addi	a0,s1,16
    80003226:	00001097          	auipc	ra,0x1
    8000322a:	58e080e7          	jalr	1422(ra) # 800047b4 <acquiresleep>
      return b;
    8000322e:	a089                	j	80003270 <bread+0xde>
  for(b = bcache.buckets[id].next; b != &bcache.buckets[id]; b = b->next){
    80003230:	6fbc                	ld	a5,88(a5)
    80003232:	01278b63          	beq	a5,s2,80003248 <bread+0xb6>
    if(b->refcnt==0 && b->lastuse<=minticks) {
    80003236:	47b8                	lw	a4,72(a5)
    80003238:	ff65                	bnez	a4,80003230 <bread+0x9e>
    8000323a:	4607a703          	lw	a4,1120(a5)
    8000323e:	fee6e9e3          	bltu	a3,a4,80003230 <bread+0x9e>
      minticks = b->lastuse;
    80003242:	86ba                	mv	a3,a4
    if(b->refcnt==0 && b->lastuse<=minticks) {
    80003244:	84be                	mv	s1,a5
    80003246:	b7ed                	j	80003230 <bread+0x9e>
  if(!victm) 
    80003248:	c4b9                	beqz	s1,80003296 <bread+0x104>
  b->dev = dev;
    8000324a:	0164a423          	sw	s6,8(s1)
  b->blockno = blockno;
    8000324e:	0154a623          	sw	s5,12(s1)
  b->valid = 0;
    80003252:	0004a023          	sw	zero,0(s1)
  b->refcnt = 1;
    80003256:	4785                	li	a5,1
    80003258:	c4bc                	sw	a5,72(s1)
  release(&bcache.lks[id]);
    8000325a:	854e                	mv	a0,s3
    8000325c:	ffffe097          	auipc	ra,0xffffe
    80003260:	b64080e7          	jalr	-1180(ra) # 80000dc0 <release>
  acquiresleep(&victm->lock);
    80003264:	01048513          	addi	a0,s1,16
    80003268:	00001097          	auipc	ra,0x1
    8000326c:	54c080e7          	jalr	1356(ra) # 800047b4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  
  /** 如果buf中的数据过时了，那么需要重新读取 */
  if(!b->valid) {
    80003270:	409c                	lw	a5,0(s1)
    80003272:	10078e63          	beqz	a5,8000338e <bread+0x1fc>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003276:	8526                	mv	a0,s1
    80003278:	70a6                	ld	ra,104(sp)
    8000327a:	7406                	ld	s0,96(sp)
    8000327c:	64e6                	ld	s1,88(sp)
    8000327e:	6946                	ld	s2,80(sp)
    80003280:	69a6                	ld	s3,72(sp)
    80003282:	6a06                	ld	s4,64(sp)
    80003284:	7ae2                	ld	s5,56(sp)
    80003286:	7b42                	ld	s6,48(sp)
    80003288:	7ba2                	ld	s7,40(sp)
    8000328a:	7c02                	ld	s8,32(sp)
    8000328c:	6ce2                	ld	s9,24(sp)
    8000328e:	6d42                	ld	s10,16(sp)
    80003290:	6da2                	ld	s11,8(sp)
    80003292:	6165                	addi	sp,sp,112
    80003294:	8082                	ret
    80003296:	0001dc17          	auipc	s8,0x1d
    8000329a:	58ac0c13          	addi	s8,s8,1418 # 80020820 <bcache+0x8430>
    if(b->refcnt==0 && b->lastuse<=minticks) {
    8000329e:	4b81                	li	s7,0
    800032a0:	00021d97          	auipc	s11,0x21
    800032a4:	ec8d8d93          	addi	s11,s11,-312 # 80024168 <bcache+0xbd78>
  for(int i=0; i<NBUCKET; i++) {
    800032a8:	4d35                	li	s10,13
    800032aa:	a869                	j	80003344 <bread+0x1b2>
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
    800032ac:	6fbc                	ld	a5,88(a5)
    800032ae:	00d78f63          	beq	a5,a3,800032cc <bread+0x13a>
      if(b->refcnt==0 && b->lastuse<=minticks) {
    800032b2:	47b8                	lw	a4,72(a5)
    800032b4:	ff65                	bnez	a4,800032ac <bread+0x11a>
    800032b6:	4607a703          	lw	a4,1120(a5)
    800032ba:	fee669e3          	bltu	a2,a4,800032ac <bread+0x11a>
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
    800032be:	6fac                	ld	a1,88(a5)
    800032c0:	0ed58063          	beq	a1,a3,800033a0 <bread+0x20e>
        minticks = b->lastuse;
    800032c4:	863a                	mv	a2,a4
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
    800032c6:	84be                	mv	s1,a5
    800032c8:	87ae                	mv	a5,a1
    800032ca:	b7e5                	j	800032b2 <bread+0x120>
    if(!victm) {
    800032cc:	c0b5                	beqz	s1,80003330 <bread+0x19e>
  b->dev = dev;
    800032ce:	0164a423          	sw	s6,8(s1)
  b->blockno = blockno;
    800032d2:	0154a623          	sw	s5,12(s1)
  b->valid = 0;
    800032d6:	0004a023          	sw	zero,0(s1)
  b->refcnt = 1;
    800032da:	4785                	li	a5,1
    800032dc:	c4bc                	sw	a5,72(s1)
    victm->next->prev = victm->prev;
    800032de:	6cb8                	ld	a4,88(s1)
    800032e0:	68bc                	ld	a5,80(s1)
    800032e2:	eb3c                	sd	a5,80(a4)
    victm->prev->next = victm->next;
    800032e4:	6cb8                	ld	a4,88(s1)
    800032e6:	efb8                	sd	a4,88(a5)
    release(&bcache.lks[i]);
    800032e8:	8566                	mv	a0,s9
    800032ea:	ffffe097          	auipc	ra,0xffffe
    800032ee:	ad6080e7          	jalr	-1322(ra) # 80000dc0 <release>
    victm->next = bcache.buckets[id].next;
    800032f2:	46800793          	li	a5,1128
    800032f6:	02fa07b3          	mul	a5,s4,a5
    800032fa:	00015a17          	auipc	s4,0x15
    800032fe:	0f6a0a13          	addi	s4,s4,246 # 800183f0 <bcache>
    80003302:	97d2                	add	a5,a5,s4
    80003304:	6a21                	lui	s4,0x8
    80003306:	9a3e                	add	s4,s4,a5
    80003308:	488a3783          	ld	a5,1160(s4) # 8488 <_entry-0x7fff7b78>
    8000330c:	ecbc                	sd	a5,88(s1)
    bcache.buckets[id].next->prev = victm;
    8000330e:	eba4                	sd	s1,80(a5)
    bcache.buckets[id].next = victm;
    80003310:	489a3423          	sd	s1,1160(s4)
    victm->prev = &bcache.buckets[id];
    80003314:	0524b823          	sd	s2,80(s1)
    release(&bcache.lks[id]);
    80003318:	854e                	mv	a0,s3
    8000331a:	ffffe097          	auipc	ra,0xffffe
    8000331e:	aa6080e7          	jalr	-1370(ra) # 80000dc0 <release>
    acquiresleep(&victm->lock);
    80003322:	01048513          	addi	a0,s1,16
    80003326:	00001097          	auipc	ra,0x1
    8000332a:	48e080e7          	jalr	1166(ra) # 800047b4 <acquiresleep>
    return victm;
    8000332e:	b789                	j	80003270 <bread+0xde>
      release(&bcache.lks[i]);
    80003330:	8566                	mv	a0,s9
    80003332:	ffffe097          	auipc	ra,0xffffe
    80003336:	a8e080e7          	jalr	-1394(ra) # 80000dc0 <release>
  for(int i=0; i<NBUCKET; i++) {
    8000333a:	0b85                	addi	s7,s7,1
    8000333c:	468c0c13          	addi	s8,s8,1128
    80003340:	03ab8a63          	beq	s7,s10,80003374 <bread+0x1e2>
    if(i == id)
    80003344:	000b879b          	sext.w	a5,s7
    80003348:	ff4789e3          	beq	a5,s4,8000333a <bread+0x1a8>
    acquire(&bcache.lks[i]);
    8000334c:	005b9c93          	slli	s9,s7,0x5
    80003350:	9cee                	add	s9,s9,s11
    80003352:	8566                	mv	a0,s9
    80003354:	ffffe097          	auipc	ra,0xffffe
    80003358:	99c080e7          	jalr	-1636(ra) # 80000cf0 <acquire>
    minticks = ticks;
    8000335c:	00006797          	auipc	a5,0x6
    80003360:	cc478793          	addi	a5,a5,-828 # 80009020 <ticks>
    80003364:	4390                	lw	a2,0(a5)
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
    80003366:	86e2                	mv	a3,s8
    80003368:	058c3783          	ld	a5,88(s8)
    8000336c:	fd8782e3          	beq	a5,s8,80003330 <bread+0x19e>
    80003370:	4481                	li	s1,0
    80003372:	b781                	j	800032b2 <bread+0x120>
  release(&bcache.lks[id]);
    80003374:	854e                	mv	a0,s3
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	a4a080e7          	jalr	-1462(ra) # 80000dc0 <release>
  panic("bget: no buf");
    8000337e:	00005517          	auipc	a0,0x5
    80003382:	1f250513          	addi	a0,a0,498 # 80008570 <syscalls+0xb8>
    80003386:	ffffd097          	auipc	ra,0xffffd
    8000338a:	1ca080e7          	jalr	458(ra) # 80000550 <panic>
    virtio_disk_rw(b, 0);
    8000338e:	4581                	li	a1,0
    80003390:	8526                	mv	a0,s1
    80003392:	00003097          	auipc	ra,0x3
    80003396:	fa4080e7          	jalr	-92(ra) # 80006336 <virtio_disk_rw>
    b->valid = 1;
    8000339a:	4785                	li	a5,1
    8000339c:	c09c                	sw	a5,0(s1)
  return b;
    8000339e:	bde1                	j	80003276 <bread+0xe4>
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
    800033a0:	84be                	mv	s1,a5
    800033a2:	b735                	j	800032ce <bread+0x13c>
  uint minticks = ticks;
    800033a4:	00006697          	auipc	a3,0x6
    800033a8:	c7c6a683          	lw	a3,-900(a3) # 80009020 <ticks>
    800033ac:	4481                	li	s1,0
    800033ae:	b561                	j	80003236 <bread+0xa4>

00000000800033b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033b0:	1101                	addi	sp,sp,-32
    800033b2:	ec06                	sd	ra,24(sp)
    800033b4:	e822                	sd	s0,16(sp)
    800033b6:	e426                	sd	s1,8(sp)
    800033b8:	1000                	addi	s0,sp,32
    800033ba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033bc:	0541                	addi	a0,a0,16
    800033be:	00001097          	auipc	ra,0x1
    800033c2:	490080e7          	jalr	1168(ra) # 8000484e <holdingsleep>
    800033c6:	cd01                	beqz	a0,800033de <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033c8:	4585                	li	a1,1
    800033ca:	8526                	mv	a0,s1
    800033cc:	00003097          	auipc	ra,0x3
    800033d0:	f6a080e7          	jalr	-150(ra) # 80006336 <virtio_disk_rw>
}
    800033d4:	60e2                	ld	ra,24(sp)
    800033d6:	6442                	ld	s0,16(sp)
    800033d8:	64a2                	ld	s1,8(sp)
    800033da:	6105                	addi	sp,sp,32
    800033dc:	8082                	ret
    panic("bwrite");
    800033de:	00005517          	auipc	a0,0x5
    800033e2:	1a250513          	addi	a0,a0,418 # 80008580 <syscalls+0xc8>
    800033e6:	ffffd097          	auipc	ra,0xffffd
    800033ea:	16a080e7          	jalr	362(ra) # 80000550 <panic>

00000000800033ee <brelse>:
// }

/** 版本1 */
void
brelse(struct buf *b)
{
    800033ee:	1101                	addi	sp,sp,-32
    800033f0:	ec06                	sd	ra,24(sp)
    800033f2:	e822                	sd	s0,16(sp)
    800033f4:	e426                	sd	s1,8(sp)
    800033f6:	e04a                	sd	s2,0(sp)
    800033f8:	1000                	addi	s0,sp,32
    800033fa:	892a                	mv	s2,a0
  if(!holdingsleep(&b->lock))
    800033fc:	01050493          	addi	s1,a0,16
    80003400:	8526                	mv	a0,s1
    80003402:	00001097          	auipc	ra,0x1
    80003406:	44c080e7          	jalr	1100(ra) # 8000484e <holdingsleep>
    8000340a:	c13d                	beqz	a0,80003470 <brelse+0x82>
    panic("brelse");

  releasesleep(&b->lock);
    8000340c:	8526                	mv	a0,s1
    8000340e:	00001097          	auipc	ra,0x1
    80003412:	3fc080e7          	jalr	1020(ra) # 8000480a <releasesleep>
  return x%NBUCKET;
    80003416:	00c92483          	lw	s1,12(s2)
   * 不是原始的LRU算法，所以无需再将可淘汰的buf提到bcache队首 
   * 只需记录最后一次使用的时间戳即可
   * */
  int id = myhash(b->blockno);

  acquire(&bcache.lks[id]);
    8000341a:	47b5                	li	a5,13
    8000341c:	02f4e4bb          	remw	s1,s1,a5
    80003420:	0496                	slli	s1,s1,0x5
    80003422:	67b1                	lui	a5,0xc
    80003424:	d7878793          	addi	a5,a5,-648 # bd78 <_entry-0x7fff4288>
    80003428:	94be                	add	s1,s1,a5
    8000342a:	00015797          	auipc	a5,0x15
    8000342e:	fc678793          	addi	a5,a5,-58 # 800183f0 <bcache>
    80003432:	94be                	add	s1,s1,a5
    80003434:	8526                	mv	a0,s1
    80003436:	ffffe097          	auipc	ra,0xffffe
    8000343a:	8ba080e7          	jalr	-1862(ra) # 80000cf0 <acquire>
  b->refcnt--;
    8000343e:	04892783          	lw	a5,72(s2)
    80003442:	37fd                	addiw	a5,a5,-1
    80003444:	0007871b          	sext.w	a4,a5
    80003448:	04f92423          	sw	a5,72(s2)
  if(b->refcnt == 0)
    8000344c:	e719                	bnez	a4,8000345a <brelse+0x6c>
    b->lastuse = ticks;
    8000344e:	00006797          	auipc	a5,0x6
    80003452:	bd27a783          	lw	a5,-1070(a5) # 80009020 <ticks>
    80003456:	46f92023          	sw	a5,1120(s2)
  release(&bcache.lks[id]);
    8000345a:	8526                	mv	a0,s1
    8000345c:	ffffe097          	auipc	ra,0xffffe
    80003460:	964080e7          	jalr	-1692(ra) # 80000dc0 <release>
}
    80003464:	60e2                	ld	ra,24(sp)
    80003466:	6442                	ld	s0,16(sp)
    80003468:	64a2                	ld	s1,8(sp)
    8000346a:	6902                	ld	s2,0(sp)
    8000346c:	6105                	addi	sp,sp,32
    8000346e:	8082                	ret
    panic("brelse");
    80003470:	00005517          	auipc	a0,0x5
    80003474:	11850513          	addi	a0,a0,280 # 80008588 <syscalls+0xd0>
    80003478:	ffffd097          	auipc	ra,0xffffd
    8000347c:	0d8080e7          	jalr	216(ra) # 80000550 <panic>

0000000080003480 <bpin>:
// }

/** 版本1 */
void
bpin(struct buf *b) 
{
    80003480:	1101                	addi	sp,sp,-32
    80003482:	ec06                	sd	ra,24(sp)
    80003484:	e822                	sd	s0,16(sp)
    80003486:	e426                	sd	s1,8(sp)
    80003488:	e04a                	sd	s2,0(sp)
    8000348a:	1000                	addi	s0,sp,32
    8000348c:	892a                	mv	s2,a0
  return x%NBUCKET;
    8000348e:	4544                	lw	s1,12(a0)
  int id = myhash(b->blockno);

  acquire(&bcache.lks[id]);
    80003490:	47b5                	li	a5,13
    80003492:	02f4e4bb          	remw	s1,s1,a5
    80003496:	0496                	slli	s1,s1,0x5
    80003498:	67b1                	lui	a5,0xc
    8000349a:	d7878793          	addi	a5,a5,-648 # bd78 <_entry-0x7fff4288>
    8000349e:	94be                	add	s1,s1,a5
    800034a0:	00015797          	auipc	a5,0x15
    800034a4:	f5078793          	addi	a5,a5,-176 # 800183f0 <bcache>
    800034a8:	94be                	add	s1,s1,a5
    800034aa:	8526                	mv	a0,s1
    800034ac:	ffffe097          	auipc	ra,0xffffe
    800034b0:	844080e7          	jalr	-1980(ra) # 80000cf0 <acquire>
  b->refcnt++;
    800034b4:	04892783          	lw	a5,72(s2)
    800034b8:	2785                	addiw	a5,a5,1
    800034ba:	04f92423          	sw	a5,72(s2)
  release(&bcache.lks[id]);
    800034be:	8526                	mv	a0,s1
    800034c0:	ffffe097          	auipc	ra,0xffffe
    800034c4:	900080e7          	jalr	-1792(ra) # 80000dc0 <release>
}
    800034c8:	60e2                	ld	ra,24(sp)
    800034ca:	6442                	ld	s0,16(sp)
    800034cc:	64a2                	ld	s1,8(sp)
    800034ce:	6902                	ld	s2,0(sp)
    800034d0:	6105                	addi	sp,sp,32
    800034d2:	8082                	ret

00000000800034d4 <bunpin>:
// }

/** 版本1 */
void
bunpin(struct buf *b) 
{
    800034d4:	1101                	addi	sp,sp,-32
    800034d6:	ec06                	sd	ra,24(sp)
    800034d8:	e822                	sd	s0,16(sp)
    800034da:	e426                	sd	s1,8(sp)
    800034dc:	e04a                	sd	s2,0(sp)
    800034de:	1000                	addi	s0,sp,32
    800034e0:	892a                	mv	s2,a0
  return x%NBUCKET;
    800034e2:	4544                	lw	s1,12(a0)
  int id = myhash(b->blockno);

  acquire(&bcache.lks[id]);
    800034e4:	47b5                	li	a5,13
    800034e6:	02f4e4bb          	remw	s1,s1,a5
    800034ea:	0496                	slli	s1,s1,0x5
    800034ec:	67b1                	lui	a5,0xc
    800034ee:	d7878793          	addi	a5,a5,-648 # bd78 <_entry-0x7fff4288>
    800034f2:	94be                	add	s1,s1,a5
    800034f4:	00015797          	auipc	a5,0x15
    800034f8:	efc78793          	addi	a5,a5,-260 # 800183f0 <bcache>
    800034fc:	94be                	add	s1,s1,a5
    800034fe:	8526                	mv	a0,s1
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	7f0080e7          	jalr	2032(ra) # 80000cf0 <acquire>
  b->refcnt--;
    80003508:	04892783          	lw	a5,72(s2)
    8000350c:	37fd                	addiw	a5,a5,-1
    8000350e:	04f92423          	sw	a5,72(s2)
  release(&bcache.lks[id]);
    80003512:	8526                	mv	a0,s1
    80003514:	ffffe097          	auipc	ra,0xffffe
    80003518:	8ac080e7          	jalr	-1876(ra) # 80000dc0 <release>
}
    8000351c:	60e2                	ld	ra,24(sp)
    8000351e:	6442                	ld	s0,16(sp)
    80003520:	64a2                	ld	s1,8(sp)
    80003522:	6902                	ld	s2,0(sp)
    80003524:	6105                	addi	sp,sp,32
    80003526:	8082                	ret

0000000080003528 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003528:	1101                	addi	sp,sp,-32
    8000352a:	ec06                	sd	ra,24(sp)
    8000352c:	e822                	sd	s0,16(sp)
    8000352e:	e426                	sd	s1,8(sp)
    80003530:	e04a                	sd	s2,0(sp)
    80003532:	1000                	addi	s0,sp,32
    80003534:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003536:	00d5d59b          	srliw	a1,a1,0xd
    8000353a:	00021797          	auipc	a5,0x21
    8000353e:	dea7a783          	lw	a5,-534(a5) # 80024324 <sb+0x1c>
    80003542:	9dbd                	addw	a1,a1,a5
    80003544:	00000097          	auipc	ra,0x0
    80003548:	c4e080e7          	jalr	-946(ra) # 80003192 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000354c:	0074f713          	andi	a4,s1,7
    80003550:	4785                	li	a5,1
    80003552:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003556:	14ce                	slli	s1,s1,0x33
    80003558:	90d9                	srli	s1,s1,0x36
    8000355a:	00950733          	add	a4,a0,s1
    8000355e:	06074703          	lbu	a4,96(a4)
    80003562:	00e7f6b3          	and	a3,a5,a4
    80003566:	c69d                	beqz	a3,80003594 <bfree+0x6c>
    80003568:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000356a:	94aa                	add	s1,s1,a0
    8000356c:	fff7c793          	not	a5,a5
    80003570:	8ff9                	and	a5,a5,a4
    80003572:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003576:	00001097          	auipc	ra,0x1
    8000357a:	116080e7          	jalr	278(ra) # 8000468c <log_write>
  brelse(bp);
    8000357e:	854a                	mv	a0,s2
    80003580:	00000097          	auipc	ra,0x0
    80003584:	e6e080e7          	jalr	-402(ra) # 800033ee <brelse>
}
    80003588:	60e2                	ld	ra,24(sp)
    8000358a:	6442                	ld	s0,16(sp)
    8000358c:	64a2                	ld	s1,8(sp)
    8000358e:	6902                	ld	s2,0(sp)
    80003590:	6105                	addi	sp,sp,32
    80003592:	8082                	ret
    panic("freeing free block");
    80003594:	00005517          	auipc	a0,0x5
    80003598:	ffc50513          	addi	a0,a0,-4 # 80008590 <syscalls+0xd8>
    8000359c:	ffffd097          	auipc	ra,0xffffd
    800035a0:	fb4080e7          	jalr	-76(ra) # 80000550 <panic>

00000000800035a4 <balloc>:
{
    800035a4:	711d                	addi	sp,sp,-96
    800035a6:	ec86                	sd	ra,88(sp)
    800035a8:	e8a2                	sd	s0,80(sp)
    800035aa:	e4a6                	sd	s1,72(sp)
    800035ac:	e0ca                	sd	s2,64(sp)
    800035ae:	fc4e                	sd	s3,56(sp)
    800035b0:	f852                	sd	s4,48(sp)
    800035b2:	f456                	sd	s5,40(sp)
    800035b4:	f05a                	sd	s6,32(sp)
    800035b6:	ec5e                	sd	s7,24(sp)
    800035b8:	e862                	sd	s8,16(sp)
    800035ba:	e466                	sd	s9,8(sp)
    800035bc:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035be:	00021797          	auipc	a5,0x21
    800035c2:	d4e7a783          	lw	a5,-690(a5) # 8002430c <sb+0x4>
    800035c6:	cbd1                	beqz	a5,8000365a <balloc+0xb6>
    800035c8:	8baa                	mv	s7,a0
    800035ca:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035cc:	00021b17          	auipc	s6,0x21
    800035d0:	d3cb0b13          	addi	s6,s6,-708 # 80024308 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035d4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035d6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035d8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035da:	6c89                	lui	s9,0x2
    800035dc:	a831                	j	800035f8 <balloc+0x54>
    brelse(bp);
    800035de:	854a                	mv	a0,s2
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	e0e080e7          	jalr	-498(ra) # 800033ee <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035e8:	015c87bb          	addw	a5,s9,s5
    800035ec:	00078a9b          	sext.w	s5,a5
    800035f0:	004b2703          	lw	a4,4(s6)
    800035f4:	06eaf363          	bgeu	s5,a4,8000365a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800035f8:	41fad79b          	sraiw	a5,s5,0x1f
    800035fc:	0137d79b          	srliw	a5,a5,0x13
    80003600:	015787bb          	addw	a5,a5,s5
    80003604:	40d7d79b          	sraiw	a5,a5,0xd
    80003608:	01cb2583          	lw	a1,28(s6)
    8000360c:	9dbd                	addw	a1,a1,a5
    8000360e:	855e                	mv	a0,s7
    80003610:	00000097          	auipc	ra,0x0
    80003614:	b82080e7          	jalr	-1150(ra) # 80003192 <bread>
    80003618:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000361a:	004b2503          	lw	a0,4(s6)
    8000361e:	000a849b          	sext.w	s1,s5
    80003622:	8662                	mv	a2,s8
    80003624:	faa4fde3          	bgeu	s1,a0,800035de <balloc+0x3a>
      m = 1 << (bi % 8);
    80003628:	41f6579b          	sraiw	a5,a2,0x1f
    8000362c:	01d7d69b          	srliw	a3,a5,0x1d
    80003630:	00c6873b          	addw	a4,a3,a2
    80003634:	00777793          	andi	a5,a4,7
    80003638:	9f95                	subw	a5,a5,a3
    8000363a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000363e:	4037571b          	sraiw	a4,a4,0x3
    80003642:	00e906b3          	add	a3,s2,a4
    80003646:	0606c683          	lbu	a3,96(a3)
    8000364a:	00d7f5b3          	and	a1,a5,a3
    8000364e:	cd91                	beqz	a1,8000366a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003650:	2605                	addiw	a2,a2,1
    80003652:	2485                	addiw	s1,s1,1
    80003654:	fd4618e3          	bne	a2,s4,80003624 <balloc+0x80>
    80003658:	b759                	j	800035de <balloc+0x3a>
  panic("balloc: out of blocks");
    8000365a:	00005517          	auipc	a0,0x5
    8000365e:	f4e50513          	addi	a0,a0,-178 # 800085a8 <syscalls+0xf0>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	eee080e7          	jalr	-274(ra) # 80000550 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000366a:	974a                	add	a4,a4,s2
    8000366c:	8fd5                	or	a5,a5,a3
    8000366e:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80003672:	854a                	mv	a0,s2
    80003674:	00001097          	auipc	ra,0x1
    80003678:	018080e7          	jalr	24(ra) # 8000468c <log_write>
        brelse(bp);
    8000367c:	854a                	mv	a0,s2
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	d70080e7          	jalr	-656(ra) # 800033ee <brelse>
  bp = bread(dev, bno);
    80003686:	85a6                	mv	a1,s1
    80003688:	855e                	mv	a0,s7
    8000368a:	00000097          	auipc	ra,0x0
    8000368e:	b08080e7          	jalr	-1272(ra) # 80003192 <bread>
    80003692:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003694:	40000613          	li	a2,1024
    80003698:	4581                	li	a1,0
    8000369a:	06050513          	addi	a0,a0,96
    8000369e:	ffffe097          	auipc	ra,0xffffe
    800036a2:	a32080e7          	jalr	-1486(ra) # 800010d0 <memset>
  log_write(bp);
    800036a6:	854a                	mv	a0,s2
    800036a8:	00001097          	auipc	ra,0x1
    800036ac:	fe4080e7          	jalr	-28(ra) # 8000468c <log_write>
  brelse(bp);
    800036b0:	854a                	mv	a0,s2
    800036b2:	00000097          	auipc	ra,0x0
    800036b6:	d3c080e7          	jalr	-708(ra) # 800033ee <brelse>
}
    800036ba:	8526                	mv	a0,s1
    800036bc:	60e6                	ld	ra,88(sp)
    800036be:	6446                	ld	s0,80(sp)
    800036c0:	64a6                	ld	s1,72(sp)
    800036c2:	6906                	ld	s2,64(sp)
    800036c4:	79e2                	ld	s3,56(sp)
    800036c6:	7a42                	ld	s4,48(sp)
    800036c8:	7aa2                	ld	s5,40(sp)
    800036ca:	7b02                	ld	s6,32(sp)
    800036cc:	6be2                	ld	s7,24(sp)
    800036ce:	6c42                	ld	s8,16(sp)
    800036d0:	6ca2                	ld	s9,8(sp)
    800036d2:	6125                	addi	sp,sp,96
    800036d4:	8082                	ret

00000000800036d6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800036d6:	7179                	addi	sp,sp,-48
    800036d8:	f406                	sd	ra,40(sp)
    800036da:	f022                	sd	s0,32(sp)
    800036dc:	ec26                	sd	s1,24(sp)
    800036de:	e84a                	sd	s2,16(sp)
    800036e0:	e44e                	sd	s3,8(sp)
    800036e2:	e052                	sd	s4,0(sp)
    800036e4:	1800                	addi	s0,sp,48
    800036e6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036e8:	47ad                	li	a5,11
    800036ea:	04b7fe63          	bgeu	a5,a1,80003746 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800036ee:	ff45849b          	addiw	s1,a1,-12
    800036f2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036f6:	0ff00793          	li	a5,255
    800036fa:	0ae7e363          	bltu	a5,a4,800037a0 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800036fe:	08852583          	lw	a1,136(a0)
    80003702:	c5ad                	beqz	a1,8000376c <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003704:	00092503          	lw	a0,0(s2)
    80003708:	00000097          	auipc	ra,0x0
    8000370c:	a8a080e7          	jalr	-1398(ra) # 80003192 <bread>
    80003710:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003712:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003716:	02049593          	slli	a1,s1,0x20
    8000371a:	9181                	srli	a1,a1,0x20
    8000371c:	058a                	slli	a1,a1,0x2
    8000371e:	00b784b3          	add	s1,a5,a1
    80003722:	0004a983          	lw	s3,0(s1)
    80003726:	04098d63          	beqz	s3,80003780 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000372a:	8552                	mv	a0,s4
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	cc2080e7          	jalr	-830(ra) # 800033ee <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003734:	854e                	mv	a0,s3
    80003736:	70a2                	ld	ra,40(sp)
    80003738:	7402                	ld	s0,32(sp)
    8000373a:	64e2                	ld	s1,24(sp)
    8000373c:	6942                	ld	s2,16(sp)
    8000373e:	69a2                	ld	s3,8(sp)
    80003740:	6a02                	ld	s4,0(sp)
    80003742:	6145                	addi	sp,sp,48
    80003744:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003746:	02059493          	slli	s1,a1,0x20
    8000374a:	9081                	srli	s1,s1,0x20
    8000374c:	048a                	slli	s1,s1,0x2
    8000374e:	94aa                	add	s1,s1,a0
    80003750:	0584a983          	lw	s3,88(s1)
    80003754:	fe0990e3          	bnez	s3,80003734 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003758:	4108                	lw	a0,0(a0)
    8000375a:	00000097          	auipc	ra,0x0
    8000375e:	e4a080e7          	jalr	-438(ra) # 800035a4 <balloc>
    80003762:	0005099b          	sext.w	s3,a0
    80003766:	0534ac23          	sw	s3,88(s1)
    8000376a:	b7e9                	j	80003734 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000376c:	4108                	lw	a0,0(a0)
    8000376e:	00000097          	auipc	ra,0x0
    80003772:	e36080e7          	jalr	-458(ra) # 800035a4 <balloc>
    80003776:	0005059b          	sext.w	a1,a0
    8000377a:	08b92423          	sw	a1,136(s2)
    8000377e:	b759                	j	80003704 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003780:	00092503          	lw	a0,0(s2)
    80003784:	00000097          	auipc	ra,0x0
    80003788:	e20080e7          	jalr	-480(ra) # 800035a4 <balloc>
    8000378c:	0005099b          	sext.w	s3,a0
    80003790:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003794:	8552                	mv	a0,s4
    80003796:	00001097          	auipc	ra,0x1
    8000379a:	ef6080e7          	jalr	-266(ra) # 8000468c <log_write>
    8000379e:	b771                	j	8000372a <bmap+0x54>
  panic("bmap: out of range");
    800037a0:	00005517          	auipc	a0,0x5
    800037a4:	e2050513          	addi	a0,a0,-480 # 800085c0 <syscalls+0x108>
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	da8080e7          	jalr	-600(ra) # 80000550 <panic>

00000000800037b0 <iget>:
{
    800037b0:	7179                	addi	sp,sp,-48
    800037b2:	f406                	sd	ra,40(sp)
    800037b4:	f022                	sd	s0,32(sp)
    800037b6:	ec26                	sd	s1,24(sp)
    800037b8:	e84a                	sd	s2,16(sp)
    800037ba:	e44e                	sd	s3,8(sp)
    800037bc:	e052                	sd	s4,0(sp)
    800037be:	1800                	addi	s0,sp,48
    800037c0:	89aa                	mv	s3,a0
    800037c2:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800037c4:	00021517          	auipc	a0,0x21
    800037c8:	b6450513          	addi	a0,a0,-1180 # 80024328 <icache>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	524080e7          	jalr	1316(ra) # 80000cf0 <acquire>
  empty = 0;
    800037d4:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800037d6:	00021497          	auipc	s1,0x21
    800037da:	b7248493          	addi	s1,s1,-1166 # 80024348 <icache+0x20>
    800037de:	00022697          	auipc	a3,0x22
    800037e2:	78a68693          	addi	a3,a3,1930 # 80025f68 <log>
    800037e6:	a039                	j	800037f4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037e8:	02090b63          	beqz	s2,8000381e <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800037ec:	09048493          	addi	s1,s1,144
    800037f0:	02d48a63          	beq	s1,a3,80003824 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037f4:	449c                	lw	a5,8(s1)
    800037f6:	fef059e3          	blez	a5,800037e8 <iget+0x38>
    800037fa:	4098                	lw	a4,0(s1)
    800037fc:	ff3716e3          	bne	a4,s3,800037e8 <iget+0x38>
    80003800:	40d8                	lw	a4,4(s1)
    80003802:	ff4713e3          	bne	a4,s4,800037e8 <iget+0x38>
      ip->ref++;
    80003806:	2785                	addiw	a5,a5,1
    80003808:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000380a:	00021517          	auipc	a0,0x21
    8000380e:	b1e50513          	addi	a0,a0,-1250 # 80024328 <icache>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	5ae080e7          	jalr	1454(ra) # 80000dc0 <release>
      return ip;
    8000381a:	8926                	mv	s2,s1
    8000381c:	a03d                	j	8000384a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000381e:	f7f9                	bnez	a5,800037ec <iget+0x3c>
    80003820:	8926                	mv	s2,s1
    80003822:	b7e9                	j	800037ec <iget+0x3c>
  if(empty == 0)
    80003824:	02090c63          	beqz	s2,8000385c <iget+0xac>
  ip->dev = dev;
    80003828:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000382c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003830:	4785                	li	a5,1
    80003832:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003836:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    8000383a:	00021517          	auipc	a0,0x21
    8000383e:	aee50513          	addi	a0,a0,-1298 # 80024328 <icache>
    80003842:	ffffd097          	auipc	ra,0xffffd
    80003846:	57e080e7          	jalr	1406(ra) # 80000dc0 <release>
}
    8000384a:	854a                	mv	a0,s2
    8000384c:	70a2                	ld	ra,40(sp)
    8000384e:	7402                	ld	s0,32(sp)
    80003850:	64e2                	ld	s1,24(sp)
    80003852:	6942                	ld	s2,16(sp)
    80003854:	69a2                	ld	s3,8(sp)
    80003856:	6a02                	ld	s4,0(sp)
    80003858:	6145                	addi	sp,sp,48
    8000385a:	8082                	ret
    panic("iget: no inodes");
    8000385c:	00005517          	auipc	a0,0x5
    80003860:	d7c50513          	addi	a0,a0,-644 # 800085d8 <syscalls+0x120>
    80003864:	ffffd097          	auipc	ra,0xffffd
    80003868:	cec080e7          	jalr	-788(ra) # 80000550 <panic>

000000008000386c <fsinit>:
fsinit(int dev) {
    8000386c:	7179                	addi	sp,sp,-48
    8000386e:	f406                	sd	ra,40(sp)
    80003870:	f022                	sd	s0,32(sp)
    80003872:	ec26                	sd	s1,24(sp)
    80003874:	e84a                	sd	s2,16(sp)
    80003876:	e44e                	sd	s3,8(sp)
    80003878:	1800                	addi	s0,sp,48
    8000387a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000387c:	4585                	li	a1,1
    8000387e:	00000097          	auipc	ra,0x0
    80003882:	914080e7          	jalr	-1772(ra) # 80003192 <bread>
    80003886:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003888:	00021997          	auipc	s3,0x21
    8000388c:	a8098993          	addi	s3,s3,-1408 # 80024308 <sb>
    80003890:	02000613          	li	a2,32
    80003894:	06050593          	addi	a1,a0,96
    80003898:	854e                	mv	a0,s3
    8000389a:	ffffe097          	auipc	ra,0xffffe
    8000389e:	896080e7          	jalr	-1898(ra) # 80001130 <memmove>
  brelse(bp);
    800038a2:	8526                	mv	a0,s1
    800038a4:	00000097          	auipc	ra,0x0
    800038a8:	b4a080e7          	jalr	-1206(ra) # 800033ee <brelse>
  if(sb.magic != FSMAGIC)
    800038ac:	0009a703          	lw	a4,0(s3)
    800038b0:	102037b7          	lui	a5,0x10203
    800038b4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038b8:	02f71263          	bne	a4,a5,800038dc <fsinit+0x70>
  initlog(dev, &sb);
    800038bc:	00021597          	auipc	a1,0x21
    800038c0:	a4c58593          	addi	a1,a1,-1460 # 80024308 <sb>
    800038c4:	854a                	mv	a0,s2
    800038c6:	00001097          	auipc	ra,0x1
    800038ca:	b4a080e7          	jalr	-1206(ra) # 80004410 <initlog>
}
    800038ce:	70a2                	ld	ra,40(sp)
    800038d0:	7402                	ld	s0,32(sp)
    800038d2:	64e2                	ld	s1,24(sp)
    800038d4:	6942                	ld	s2,16(sp)
    800038d6:	69a2                	ld	s3,8(sp)
    800038d8:	6145                	addi	sp,sp,48
    800038da:	8082                	ret
    panic("invalid file system");
    800038dc:	00005517          	auipc	a0,0x5
    800038e0:	d0c50513          	addi	a0,a0,-756 # 800085e8 <syscalls+0x130>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	c6c080e7          	jalr	-916(ra) # 80000550 <panic>

00000000800038ec <iinit>:
{
    800038ec:	7179                	addi	sp,sp,-48
    800038ee:	f406                	sd	ra,40(sp)
    800038f0:	f022                	sd	s0,32(sp)
    800038f2:	ec26                	sd	s1,24(sp)
    800038f4:	e84a                	sd	s2,16(sp)
    800038f6:	e44e                	sd	s3,8(sp)
    800038f8:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800038fa:	00005597          	auipc	a1,0x5
    800038fe:	d0658593          	addi	a1,a1,-762 # 80008600 <syscalls+0x148>
    80003902:	00021517          	auipc	a0,0x21
    80003906:	a2650513          	addi	a0,a0,-1498 # 80024328 <icache>
    8000390a:	ffffd097          	auipc	ra,0xffffd
    8000390e:	562080e7          	jalr	1378(ra) # 80000e6c <initlock>
  for(i = 0; i < NINODE; i++) {
    80003912:	00021497          	auipc	s1,0x21
    80003916:	a4648493          	addi	s1,s1,-1466 # 80024358 <icache+0x30>
    8000391a:	00022997          	auipc	s3,0x22
    8000391e:	65e98993          	addi	s3,s3,1630 # 80025f78 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003922:	00005917          	auipc	s2,0x5
    80003926:	ce690913          	addi	s2,s2,-794 # 80008608 <syscalls+0x150>
    8000392a:	85ca                	mv	a1,s2
    8000392c:	8526                	mv	a0,s1
    8000392e:	00001097          	auipc	ra,0x1
    80003932:	e4c080e7          	jalr	-436(ra) # 8000477a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003936:	09048493          	addi	s1,s1,144
    8000393a:	ff3498e3          	bne	s1,s3,8000392a <iinit+0x3e>
}
    8000393e:	70a2                	ld	ra,40(sp)
    80003940:	7402                	ld	s0,32(sp)
    80003942:	64e2                	ld	s1,24(sp)
    80003944:	6942                	ld	s2,16(sp)
    80003946:	69a2                	ld	s3,8(sp)
    80003948:	6145                	addi	sp,sp,48
    8000394a:	8082                	ret

000000008000394c <ialloc>:
{
    8000394c:	715d                	addi	sp,sp,-80
    8000394e:	e486                	sd	ra,72(sp)
    80003950:	e0a2                	sd	s0,64(sp)
    80003952:	fc26                	sd	s1,56(sp)
    80003954:	f84a                	sd	s2,48(sp)
    80003956:	f44e                	sd	s3,40(sp)
    80003958:	f052                	sd	s4,32(sp)
    8000395a:	ec56                	sd	s5,24(sp)
    8000395c:	e85a                	sd	s6,16(sp)
    8000395e:	e45e                	sd	s7,8(sp)
    80003960:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003962:	00021717          	auipc	a4,0x21
    80003966:	9b272703          	lw	a4,-1614(a4) # 80024314 <sb+0xc>
    8000396a:	4785                	li	a5,1
    8000396c:	04e7fa63          	bgeu	a5,a4,800039c0 <ialloc+0x74>
    80003970:	8aaa                	mv	s5,a0
    80003972:	8bae                	mv	s7,a1
    80003974:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003976:	00021a17          	auipc	s4,0x21
    8000397a:	992a0a13          	addi	s4,s4,-1646 # 80024308 <sb>
    8000397e:	00048b1b          	sext.w	s6,s1
    80003982:	0044d593          	srli	a1,s1,0x4
    80003986:	018a2783          	lw	a5,24(s4)
    8000398a:	9dbd                	addw	a1,a1,a5
    8000398c:	8556                	mv	a0,s5
    8000398e:	00000097          	auipc	ra,0x0
    80003992:	804080e7          	jalr	-2044(ra) # 80003192 <bread>
    80003996:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003998:	06050993          	addi	s3,a0,96
    8000399c:	00f4f793          	andi	a5,s1,15
    800039a0:	079a                	slli	a5,a5,0x6
    800039a2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800039a4:	00099783          	lh	a5,0(s3)
    800039a8:	c785                	beqz	a5,800039d0 <ialloc+0x84>
    brelse(bp);
    800039aa:	00000097          	auipc	ra,0x0
    800039ae:	a44080e7          	jalr	-1468(ra) # 800033ee <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800039b2:	0485                	addi	s1,s1,1
    800039b4:	00ca2703          	lw	a4,12(s4)
    800039b8:	0004879b          	sext.w	a5,s1
    800039bc:	fce7e1e3          	bltu	a5,a4,8000397e <ialloc+0x32>
  panic("ialloc: no inodes");
    800039c0:	00005517          	auipc	a0,0x5
    800039c4:	c5050513          	addi	a0,a0,-944 # 80008610 <syscalls+0x158>
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	b88080e7          	jalr	-1144(ra) # 80000550 <panic>
      memset(dip, 0, sizeof(*dip));
    800039d0:	04000613          	li	a2,64
    800039d4:	4581                	li	a1,0
    800039d6:	854e                	mv	a0,s3
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	6f8080e7          	jalr	1784(ra) # 800010d0 <memset>
      dip->type = type;
    800039e0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039e4:	854a                	mv	a0,s2
    800039e6:	00001097          	auipc	ra,0x1
    800039ea:	ca6080e7          	jalr	-858(ra) # 8000468c <log_write>
      brelse(bp);
    800039ee:	854a                	mv	a0,s2
    800039f0:	00000097          	auipc	ra,0x0
    800039f4:	9fe080e7          	jalr	-1538(ra) # 800033ee <brelse>
      return iget(dev, inum);
    800039f8:	85da                	mv	a1,s6
    800039fa:	8556                	mv	a0,s5
    800039fc:	00000097          	auipc	ra,0x0
    80003a00:	db4080e7          	jalr	-588(ra) # 800037b0 <iget>
}
    80003a04:	60a6                	ld	ra,72(sp)
    80003a06:	6406                	ld	s0,64(sp)
    80003a08:	74e2                	ld	s1,56(sp)
    80003a0a:	7942                	ld	s2,48(sp)
    80003a0c:	79a2                	ld	s3,40(sp)
    80003a0e:	7a02                	ld	s4,32(sp)
    80003a10:	6ae2                	ld	s5,24(sp)
    80003a12:	6b42                	ld	s6,16(sp)
    80003a14:	6ba2                	ld	s7,8(sp)
    80003a16:	6161                	addi	sp,sp,80
    80003a18:	8082                	ret

0000000080003a1a <iupdate>:
{
    80003a1a:	1101                	addi	sp,sp,-32
    80003a1c:	ec06                	sd	ra,24(sp)
    80003a1e:	e822                	sd	s0,16(sp)
    80003a20:	e426                	sd	s1,8(sp)
    80003a22:	e04a                	sd	s2,0(sp)
    80003a24:	1000                	addi	s0,sp,32
    80003a26:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a28:	415c                	lw	a5,4(a0)
    80003a2a:	0047d79b          	srliw	a5,a5,0x4
    80003a2e:	00021597          	auipc	a1,0x21
    80003a32:	8f25a583          	lw	a1,-1806(a1) # 80024320 <sb+0x18>
    80003a36:	9dbd                	addw	a1,a1,a5
    80003a38:	4108                	lw	a0,0(a0)
    80003a3a:	fffff097          	auipc	ra,0xfffff
    80003a3e:	758080e7          	jalr	1880(ra) # 80003192 <bread>
    80003a42:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a44:	06050793          	addi	a5,a0,96
    80003a48:	40c8                	lw	a0,4(s1)
    80003a4a:	893d                	andi	a0,a0,15
    80003a4c:	051a                	slli	a0,a0,0x6
    80003a4e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a50:	04c49703          	lh	a4,76(s1)
    80003a54:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003a58:	04e49703          	lh	a4,78(s1)
    80003a5c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003a60:	05049703          	lh	a4,80(s1)
    80003a64:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003a68:	05249703          	lh	a4,82(s1)
    80003a6c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003a70:	48f8                	lw	a4,84(s1)
    80003a72:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a74:	03400613          	li	a2,52
    80003a78:	05848593          	addi	a1,s1,88
    80003a7c:	0531                	addi	a0,a0,12
    80003a7e:	ffffd097          	auipc	ra,0xffffd
    80003a82:	6b2080e7          	jalr	1714(ra) # 80001130 <memmove>
  log_write(bp);
    80003a86:	854a                	mv	a0,s2
    80003a88:	00001097          	auipc	ra,0x1
    80003a8c:	c04080e7          	jalr	-1020(ra) # 8000468c <log_write>
  brelse(bp);
    80003a90:	854a                	mv	a0,s2
    80003a92:	00000097          	auipc	ra,0x0
    80003a96:	95c080e7          	jalr	-1700(ra) # 800033ee <brelse>
}
    80003a9a:	60e2                	ld	ra,24(sp)
    80003a9c:	6442                	ld	s0,16(sp)
    80003a9e:	64a2                	ld	s1,8(sp)
    80003aa0:	6902                	ld	s2,0(sp)
    80003aa2:	6105                	addi	sp,sp,32
    80003aa4:	8082                	ret

0000000080003aa6 <idup>:
{
    80003aa6:	1101                	addi	sp,sp,-32
    80003aa8:	ec06                	sd	ra,24(sp)
    80003aaa:	e822                	sd	s0,16(sp)
    80003aac:	e426                	sd	s1,8(sp)
    80003aae:	1000                	addi	s0,sp,32
    80003ab0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003ab2:	00021517          	auipc	a0,0x21
    80003ab6:	87650513          	addi	a0,a0,-1930 # 80024328 <icache>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	236080e7          	jalr	566(ra) # 80000cf0 <acquire>
  ip->ref++;
    80003ac2:	449c                	lw	a5,8(s1)
    80003ac4:	2785                	addiw	a5,a5,1
    80003ac6:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ac8:	00021517          	auipc	a0,0x21
    80003acc:	86050513          	addi	a0,a0,-1952 # 80024328 <icache>
    80003ad0:	ffffd097          	auipc	ra,0xffffd
    80003ad4:	2f0080e7          	jalr	752(ra) # 80000dc0 <release>
}
    80003ad8:	8526                	mv	a0,s1
    80003ada:	60e2                	ld	ra,24(sp)
    80003adc:	6442                	ld	s0,16(sp)
    80003ade:	64a2                	ld	s1,8(sp)
    80003ae0:	6105                	addi	sp,sp,32
    80003ae2:	8082                	ret

0000000080003ae4 <ilock>:
{
    80003ae4:	1101                	addi	sp,sp,-32
    80003ae6:	ec06                	sd	ra,24(sp)
    80003ae8:	e822                	sd	s0,16(sp)
    80003aea:	e426                	sd	s1,8(sp)
    80003aec:	e04a                	sd	s2,0(sp)
    80003aee:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003af0:	c115                	beqz	a0,80003b14 <ilock+0x30>
    80003af2:	84aa                	mv	s1,a0
    80003af4:	451c                	lw	a5,8(a0)
    80003af6:	00f05f63          	blez	a5,80003b14 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003afa:	0541                	addi	a0,a0,16
    80003afc:	00001097          	auipc	ra,0x1
    80003b00:	cb8080e7          	jalr	-840(ra) # 800047b4 <acquiresleep>
  if(ip->valid == 0){
    80003b04:	44bc                	lw	a5,72(s1)
    80003b06:	cf99                	beqz	a5,80003b24 <ilock+0x40>
}
    80003b08:	60e2                	ld	ra,24(sp)
    80003b0a:	6442                	ld	s0,16(sp)
    80003b0c:	64a2                	ld	s1,8(sp)
    80003b0e:	6902                	ld	s2,0(sp)
    80003b10:	6105                	addi	sp,sp,32
    80003b12:	8082                	ret
    panic("ilock");
    80003b14:	00005517          	auipc	a0,0x5
    80003b18:	b1450513          	addi	a0,a0,-1260 # 80008628 <syscalls+0x170>
    80003b1c:	ffffd097          	auipc	ra,0xffffd
    80003b20:	a34080e7          	jalr	-1484(ra) # 80000550 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b24:	40dc                	lw	a5,4(s1)
    80003b26:	0047d79b          	srliw	a5,a5,0x4
    80003b2a:	00020597          	auipc	a1,0x20
    80003b2e:	7f65a583          	lw	a1,2038(a1) # 80024320 <sb+0x18>
    80003b32:	9dbd                	addw	a1,a1,a5
    80003b34:	4088                	lw	a0,0(s1)
    80003b36:	fffff097          	auipc	ra,0xfffff
    80003b3a:	65c080e7          	jalr	1628(ra) # 80003192 <bread>
    80003b3e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b40:	06050593          	addi	a1,a0,96
    80003b44:	40dc                	lw	a5,4(s1)
    80003b46:	8bbd                	andi	a5,a5,15
    80003b48:	079a                	slli	a5,a5,0x6
    80003b4a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b4c:	00059783          	lh	a5,0(a1)
    80003b50:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003b54:	00259783          	lh	a5,2(a1)
    80003b58:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003b5c:	00459783          	lh	a5,4(a1)
    80003b60:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003b64:	00659783          	lh	a5,6(a1)
    80003b68:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003b6c:	459c                	lw	a5,8(a1)
    80003b6e:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b70:	03400613          	li	a2,52
    80003b74:	05b1                	addi	a1,a1,12
    80003b76:	05848513          	addi	a0,s1,88
    80003b7a:	ffffd097          	auipc	ra,0xffffd
    80003b7e:	5b6080e7          	jalr	1462(ra) # 80001130 <memmove>
    brelse(bp);
    80003b82:	854a                	mv	a0,s2
    80003b84:	00000097          	auipc	ra,0x0
    80003b88:	86a080e7          	jalr	-1942(ra) # 800033ee <brelse>
    ip->valid = 1;
    80003b8c:	4785                	li	a5,1
    80003b8e:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003b90:	04c49783          	lh	a5,76(s1)
    80003b94:	fbb5                	bnez	a5,80003b08 <ilock+0x24>
      panic("ilock: no type");
    80003b96:	00005517          	auipc	a0,0x5
    80003b9a:	a9a50513          	addi	a0,a0,-1382 # 80008630 <syscalls+0x178>
    80003b9e:	ffffd097          	auipc	ra,0xffffd
    80003ba2:	9b2080e7          	jalr	-1614(ra) # 80000550 <panic>

0000000080003ba6 <iunlock>:
{
    80003ba6:	1101                	addi	sp,sp,-32
    80003ba8:	ec06                	sd	ra,24(sp)
    80003baa:	e822                	sd	s0,16(sp)
    80003bac:	e426                	sd	s1,8(sp)
    80003bae:	e04a                	sd	s2,0(sp)
    80003bb0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bb2:	c905                	beqz	a0,80003be2 <iunlock+0x3c>
    80003bb4:	84aa                	mv	s1,a0
    80003bb6:	01050913          	addi	s2,a0,16
    80003bba:	854a                	mv	a0,s2
    80003bbc:	00001097          	auipc	ra,0x1
    80003bc0:	c92080e7          	jalr	-878(ra) # 8000484e <holdingsleep>
    80003bc4:	cd19                	beqz	a0,80003be2 <iunlock+0x3c>
    80003bc6:	449c                	lw	a5,8(s1)
    80003bc8:	00f05d63          	blez	a5,80003be2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003bcc:	854a                	mv	a0,s2
    80003bce:	00001097          	auipc	ra,0x1
    80003bd2:	c3c080e7          	jalr	-964(ra) # 8000480a <releasesleep>
}
    80003bd6:	60e2                	ld	ra,24(sp)
    80003bd8:	6442                	ld	s0,16(sp)
    80003bda:	64a2                	ld	s1,8(sp)
    80003bdc:	6902                	ld	s2,0(sp)
    80003bde:	6105                	addi	sp,sp,32
    80003be0:	8082                	ret
    panic("iunlock");
    80003be2:	00005517          	auipc	a0,0x5
    80003be6:	a5e50513          	addi	a0,a0,-1442 # 80008640 <syscalls+0x188>
    80003bea:	ffffd097          	auipc	ra,0xffffd
    80003bee:	966080e7          	jalr	-1690(ra) # 80000550 <panic>

0000000080003bf2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bf2:	7179                	addi	sp,sp,-48
    80003bf4:	f406                	sd	ra,40(sp)
    80003bf6:	f022                	sd	s0,32(sp)
    80003bf8:	ec26                	sd	s1,24(sp)
    80003bfa:	e84a                	sd	s2,16(sp)
    80003bfc:	e44e                	sd	s3,8(sp)
    80003bfe:	e052                	sd	s4,0(sp)
    80003c00:	1800                	addi	s0,sp,48
    80003c02:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c04:	05850493          	addi	s1,a0,88
    80003c08:	08850913          	addi	s2,a0,136
    80003c0c:	a021                	j	80003c14 <itrunc+0x22>
    80003c0e:	0491                	addi	s1,s1,4
    80003c10:	01248d63          	beq	s1,s2,80003c2a <itrunc+0x38>
    if(ip->addrs[i]){
    80003c14:	408c                	lw	a1,0(s1)
    80003c16:	dde5                	beqz	a1,80003c0e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c18:	0009a503          	lw	a0,0(s3)
    80003c1c:	00000097          	auipc	ra,0x0
    80003c20:	90c080e7          	jalr	-1780(ra) # 80003528 <bfree>
      ip->addrs[i] = 0;
    80003c24:	0004a023          	sw	zero,0(s1)
    80003c28:	b7dd                	j	80003c0e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c2a:	0889a583          	lw	a1,136(s3)
    80003c2e:	e185                	bnez	a1,80003c4e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c30:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003c34:	854e                	mv	a0,s3
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	de4080e7          	jalr	-540(ra) # 80003a1a <iupdate>
}
    80003c3e:	70a2                	ld	ra,40(sp)
    80003c40:	7402                	ld	s0,32(sp)
    80003c42:	64e2                	ld	s1,24(sp)
    80003c44:	6942                	ld	s2,16(sp)
    80003c46:	69a2                	ld	s3,8(sp)
    80003c48:	6a02                	ld	s4,0(sp)
    80003c4a:	6145                	addi	sp,sp,48
    80003c4c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c4e:	0009a503          	lw	a0,0(s3)
    80003c52:	fffff097          	auipc	ra,0xfffff
    80003c56:	540080e7          	jalr	1344(ra) # 80003192 <bread>
    80003c5a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c5c:	06050493          	addi	s1,a0,96
    80003c60:	46050913          	addi	s2,a0,1120
    80003c64:	a811                	j	80003c78 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003c66:	0009a503          	lw	a0,0(s3)
    80003c6a:	00000097          	auipc	ra,0x0
    80003c6e:	8be080e7          	jalr	-1858(ra) # 80003528 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003c72:	0491                	addi	s1,s1,4
    80003c74:	01248563          	beq	s1,s2,80003c7e <itrunc+0x8c>
      if(a[j])
    80003c78:	408c                	lw	a1,0(s1)
    80003c7a:	dde5                	beqz	a1,80003c72 <itrunc+0x80>
    80003c7c:	b7ed                	j	80003c66 <itrunc+0x74>
    brelse(bp);
    80003c7e:	8552                	mv	a0,s4
    80003c80:	fffff097          	auipc	ra,0xfffff
    80003c84:	76e080e7          	jalr	1902(ra) # 800033ee <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c88:	0889a583          	lw	a1,136(s3)
    80003c8c:	0009a503          	lw	a0,0(s3)
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	898080e7          	jalr	-1896(ra) # 80003528 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c98:	0809a423          	sw	zero,136(s3)
    80003c9c:	bf51                	j	80003c30 <itrunc+0x3e>

0000000080003c9e <iput>:
{
    80003c9e:	1101                	addi	sp,sp,-32
    80003ca0:	ec06                	sd	ra,24(sp)
    80003ca2:	e822                	sd	s0,16(sp)
    80003ca4:	e426                	sd	s1,8(sp)
    80003ca6:	e04a                	sd	s2,0(sp)
    80003ca8:	1000                	addi	s0,sp,32
    80003caa:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003cac:	00020517          	auipc	a0,0x20
    80003cb0:	67c50513          	addi	a0,a0,1660 # 80024328 <icache>
    80003cb4:	ffffd097          	auipc	ra,0xffffd
    80003cb8:	03c080e7          	jalr	60(ra) # 80000cf0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cbc:	4498                	lw	a4,8(s1)
    80003cbe:	4785                	li	a5,1
    80003cc0:	02f70363          	beq	a4,a5,80003ce6 <iput+0x48>
  ip->ref--;
    80003cc4:	449c                	lw	a5,8(s1)
    80003cc6:	37fd                	addiw	a5,a5,-1
    80003cc8:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003cca:	00020517          	auipc	a0,0x20
    80003cce:	65e50513          	addi	a0,a0,1630 # 80024328 <icache>
    80003cd2:	ffffd097          	auipc	ra,0xffffd
    80003cd6:	0ee080e7          	jalr	238(ra) # 80000dc0 <release>
}
    80003cda:	60e2                	ld	ra,24(sp)
    80003cdc:	6442                	ld	s0,16(sp)
    80003cde:	64a2                	ld	s1,8(sp)
    80003ce0:	6902                	ld	s2,0(sp)
    80003ce2:	6105                	addi	sp,sp,32
    80003ce4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ce6:	44bc                	lw	a5,72(s1)
    80003ce8:	dff1                	beqz	a5,80003cc4 <iput+0x26>
    80003cea:	05249783          	lh	a5,82(s1)
    80003cee:	fbf9                	bnez	a5,80003cc4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003cf0:	01048913          	addi	s2,s1,16
    80003cf4:	854a                	mv	a0,s2
    80003cf6:	00001097          	auipc	ra,0x1
    80003cfa:	abe080e7          	jalr	-1346(ra) # 800047b4 <acquiresleep>
    release(&icache.lock);
    80003cfe:	00020517          	auipc	a0,0x20
    80003d02:	62a50513          	addi	a0,a0,1578 # 80024328 <icache>
    80003d06:	ffffd097          	auipc	ra,0xffffd
    80003d0a:	0ba080e7          	jalr	186(ra) # 80000dc0 <release>
    itrunc(ip);
    80003d0e:	8526                	mv	a0,s1
    80003d10:	00000097          	auipc	ra,0x0
    80003d14:	ee2080e7          	jalr	-286(ra) # 80003bf2 <itrunc>
    ip->type = 0;
    80003d18:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003d1c:	8526                	mv	a0,s1
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	cfc080e7          	jalr	-772(ra) # 80003a1a <iupdate>
    ip->valid = 0;
    80003d26:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	00001097          	auipc	ra,0x1
    80003d30:	ade080e7          	jalr	-1314(ra) # 8000480a <releasesleep>
    acquire(&icache.lock);
    80003d34:	00020517          	auipc	a0,0x20
    80003d38:	5f450513          	addi	a0,a0,1524 # 80024328 <icache>
    80003d3c:	ffffd097          	auipc	ra,0xffffd
    80003d40:	fb4080e7          	jalr	-76(ra) # 80000cf0 <acquire>
    80003d44:	b741                	j	80003cc4 <iput+0x26>

0000000080003d46 <iunlockput>:
{
    80003d46:	1101                	addi	sp,sp,-32
    80003d48:	ec06                	sd	ra,24(sp)
    80003d4a:	e822                	sd	s0,16(sp)
    80003d4c:	e426                	sd	s1,8(sp)
    80003d4e:	1000                	addi	s0,sp,32
    80003d50:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	e54080e7          	jalr	-428(ra) # 80003ba6 <iunlock>
  iput(ip);
    80003d5a:	8526                	mv	a0,s1
    80003d5c:	00000097          	auipc	ra,0x0
    80003d60:	f42080e7          	jalr	-190(ra) # 80003c9e <iput>
}
    80003d64:	60e2                	ld	ra,24(sp)
    80003d66:	6442                	ld	s0,16(sp)
    80003d68:	64a2                	ld	s1,8(sp)
    80003d6a:	6105                	addi	sp,sp,32
    80003d6c:	8082                	ret

0000000080003d6e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d6e:	1141                	addi	sp,sp,-16
    80003d70:	e422                	sd	s0,8(sp)
    80003d72:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d74:	411c                	lw	a5,0(a0)
    80003d76:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d78:	415c                	lw	a5,4(a0)
    80003d7a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d7c:	04c51783          	lh	a5,76(a0)
    80003d80:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d84:	05251783          	lh	a5,82(a0)
    80003d88:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d8c:	05456783          	lwu	a5,84(a0)
    80003d90:	e99c                	sd	a5,16(a1)
}
    80003d92:	6422                	ld	s0,8(sp)
    80003d94:	0141                	addi	sp,sp,16
    80003d96:	8082                	ret

0000000080003d98 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d98:	497c                	lw	a5,84(a0)
    80003d9a:	0ed7e963          	bltu	a5,a3,80003e8c <readi+0xf4>
{
    80003d9e:	7159                	addi	sp,sp,-112
    80003da0:	f486                	sd	ra,104(sp)
    80003da2:	f0a2                	sd	s0,96(sp)
    80003da4:	eca6                	sd	s1,88(sp)
    80003da6:	e8ca                	sd	s2,80(sp)
    80003da8:	e4ce                	sd	s3,72(sp)
    80003daa:	e0d2                	sd	s4,64(sp)
    80003dac:	fc56                	sd	s5,56(sp)
    80003dae:	f85a                	sd	s6,48(sp)
    80003db0:	f45e                	sd	s7,40(sp)
    80003db2:	f062                	sd	s8,32(sp)
    80003db4:	ec66                	sd	s9,24(sp)
    80003db6:	e86a                	sd	s10,16(sp)
    80003db8:	e46e                	sd	s11,8(sp)
    80003dba:	1880                	addi	s0,sp,112
    80003dbc:	8baa                	mv	s7,a0
    80003dbe:	8c2e                	mv	s8,a1
    80003dc0:	8ab2                	mv	s5,a2
    80003dc2:	84b6                	mv	s1,a3
    80003dc4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003dc6:	9f35                	addw	a4,a4,a3
    return 0;
    80003dc8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003dca:	0ad76063          	bltu	a4,a3,80003e6a <readi+0xd2>
  if(off + n > ip->size)
    80003dce:	00e7f463          	bgeu	a5,a4,80003dd6 <readi+0x3e>
    n = ip->size - off;
    80003dd2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dd6:	0a0b0963          	beqz	s6,80003e88 <readi+0xf0>
    80003dda:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ddc:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003de0:	5cfd                	li	s9,-1
    80003de2:	a82d                	j	80003e1c <readi+0x84>
    80003de4:	020a1d93          	slli	s11,s4,0x20
    80003de8:	020ddd93          	srli	s11,s11,0x20
    80003dec:	06090613          	addi	a2,s2,96
    80003df0:	86ee                	mv	a3,s11
    80003df2:	963a                	add	a2,a2,a4
    80003df4:	85d6                	mv	a1,s5
    80003df6:	8562                	mv	a0,s8
    80003df8:	fffff097          	auipc	ra,0xfffff
    80003dfc:	9b2080e7          	jalr	-1614(ra) # 800027aa <either_copyout>
    80003e00:	05950d63          	beq	a0,s9,80003e5a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e04:	854a                	mv	a0,s2
    80003e06:	fffff097          	auipc	ra,0xfffff
    80003e0a:	5e8080e7          	jalr	1512(ra) # 800033ee <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e0e:	013a09bb          	addw	s3,s4,s3
    80003e12:	009a04bb          	addw	s1,s4,s1
    80003e16:	9aee                	add	s5,s5,s11
    80003e18:	0569f763          	bgeu	s3,s6,80003e66 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e1c:	000ba903          	lw	s2,0(s7)
    80003e20:	00a4d59b          	srliw	a1,s1,0xa
    80003e24:	855e                	mv	a0,s7
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	8b0080e7          	jalr	-1872(ra) # 800036d6 <bmap>
    80003e2e:	0005059b          	sext.w	a1,a0
    80003e32:	854a                	mv	a0,s2
    80003e34:	fffff097          	auipc	ra,0xfffff
    80003e38:	35e080e7          	jalr	862(ra) # 80003192 <bread>
    80003e3c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e3e:	3ff4f713          	andi	a4,s1,1023
    80003e42:	40ed07bb          	subw	a5,s10,a4
    80003e46:	413b06bb          	subw	a3,s6,s3
    80003e4a:	8a3e                	mv	s4,a5
    80003e4c:	2781                	sext.w	a5,a5
    80003e4e:	0006861b          	sext.w	a2,a3
    80003e52:	f8f679e3          	bgeu	a2,a5,80003de4 <readi+0x4c>
    80003e56:	8a36                	mv	s4,a3
    80003e58:	b771                	j	80003de4 <readi+0x4c>
      brelse(bp);
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	fffff097          	auipc	ra,0xfffff
    80003e60:	592080e7          	jalr	1426(ra) # 800033ee <brelse>
      tot = -1;
    80003e64:	59fd                	li	s3,-1
  }
  return tot;
    80003e66:	0009851b          	sext.w	a0,s3
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
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e88:	89da                	mv	s3,s6
    80003e8a:	bff1                	j	80003e66 <readi+0xce>
    return 0;
    80003e8c:	4501                	li	a0,0
}
    80003e8e:	8082                	ret

0000000080003e90 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e90:	497c                	lw	a5,84(a0)
    80003e92:	10d7e763          	bltu	a5,a3,80003fa0 <writei+0x110>
{
    80003e96:	7159                	addi	sp,sp,-112
    80003e98:	f486                	sd	ra,104(sp)
    80003e9a:	f0a2                	sd	s0,96(sp)
    80003e9c:	eca6                	sd	s1,88(sp)
    80003e9e:	e8ca                	sd	s2,80(sp)
    80003ea0:	e4ce                	sd	s3,72(sp)
    80003ea2:	e0d2                	sd	s4,64(sp)
    80003ea4:	fc56                	sd	s5,56(sp)
    80003ea6:	f85a                	sd	s6,48(sp)
    80003ea8:	f45e                	sd	s7,40(sp)
    80003eaa:	f062                	sd	s8,32(sp)
    80003eac:	ec66                	sd	s9,24(sp)
    80003eae:	e86a                	sd	s10,16(sp)
    80003eb0:	e46e                	sd	s11,8(sp)
    80003eb2:	1880                	addi	s0,sp,112
    80003eb4:	8baa                	mv	s7,a0
    80003eb6:	8c2e                	mv	s8,a1
    80003eb8:	8ab2                	mv	s5,a2
    80003eba:	8936                	mv	s2,a3
    80003ebc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ebe:	00e687bb          	addw	a5,a3,a4
    80003ec2:	0ed7e163          	bltu	a5,a3,80003fa4 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ec6:	00043737          	lui	a4,0x43
    80003eca:	0cf76f63          	bltu	a4,a5,80003fa8 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ece:	0a0b0863          	beqz	s6,80003f7e <writei+0xee>
    80003ed2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ed4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ed8:	5cfd                	li	s9,-1
    80003eda:	a091                	j	80003f1e <writei+0x8e>
    80003edc:	02099d93          	slli	s11,s3,0x20
    80003ee0:	020ddd93          	srli	s11,s11,0x20
    80003ee4:	06048513          	addi	a0,s1,96
    80003ee8:	86ee                	mv	a3,s11
    80003eea:	8656                	mv	a2,s5
    80003eec:	85e2                	mv	a1,s8
    80003eee:	953a                	add	a0,a0,a4
    80003ef0:	fffff097          	auipc	ra,0xfffff
    80003ef4:	910080e7          	jalr	-1776(ra) # 80002800 <either_copyin>
    80003ef8:	07950263          	beq	a0,s9,80003f5c <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003efc:	8526                	mv	a0,s1
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	78e080e7          	jalr	1934(ra) # 8000468c <log_write>
    brelse(bp);
    80003f06:	8526                	mv	a0,s1
    80003f08:	fffff097          	auipc	ra,0xfffff
    80003f0c:	4e6080e7          	jalr	1254(ra) # 800033ee <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f10:	01498a3b          	addw	s4,s3,s4
    80003f14:	0129893b          	addw	s2,s3,s2
    80003f18:	9aee                	add	s5,s5,s11
    80003f1a:	056a7763          	bgeu	s4,s6,80003f68 <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f1e:	000ba483          	lw	s1,0(s7)
    80003f22:	00a9559b          	srliw	a1,s2,0xa
    80003f26:	855e                	mv	a0,s7
    80003f28:	fffff097          	auipc	ra,0xfffff
    80003f2c:	7ae080e7          	jalr	1966(ra) # 800036d6 <bmap>
    80003f30:	0005059b          	sext.w	a1,a0
    80003f34:	8526                	mv	a0,s1
    80003f36:	fffff097          	auipc	ra,0xfffff
    80003f3a:	25c080e7          	jalr	604(ra) # 80003192 <bread>
    80003f3e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f40:	3ff97713          	andi	a4,s2,1023
    80003f44:	40ed07bb          	subw	a5,s10,a4
    80003f48:	414b06bb          	subw	a3,s6,s4
    80003f4c:	89be                	mv	s3,a5
    80003f4e:	2781                	sext.w	a5,a5
    80003f50:	0006861b          	sext.w	a2,a3
    80003f54:	f8f674e3          	bgeu	a2,a5,80003edc <writei+0x4c>
    80003f58:	89b6                	mv	s3,a3
    80003f5a:	b749                	j	80003edc <writei+0x4c>
      brelse(bp);
    80003f5c:	8526                	mv	a0,s1
    80003f5e:	fffff097          	auipc	ra,0xfffff
    80003f62:	490080e7          	jalr	1168(ra) # 800033ee <brelse>
      n = -1;
    80003f66:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003f68:	054ba783          	lw	a5,84(s7)
    80003f6c:	0127f463          	bgeu	a5,s2,80003f74 <writei+0xe4>
      ip->size = off;
    80003f70:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003f74:	855e                	mv	a0,s7
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	aa4080e7          	jalr	-1372(ra) # 80003a1a <iupdate>
  }

  return n;
    80003f7e:	000b051b          	sext.w	a0,s6
}
    80003f82:	70a6                	ld	ra,104(sp)
    80003f84:	7406                	ld	s0,96(sp)
    80003f86:	64e6                	ld	s1,88(sp)
    80003f88:	6946                	ld	s2,80(sp)
    80003f8a:	69a6                	ld	s3,72(sp)
    80003f8c:	6a06                	ld	s4,64(sp)
    80003f8e:	7ae2                	ld	s5,56(sp)
    80003f90:	7b42                	ld	s6,48(sp)
    80003f92:	7ba2                	ld	s7,40(sp)
    80003f94:	7c02                	ld	s8,32(sp)
    80003f96:	6ce2                	ld	s9,24(sp)
    80003f98:	6d42                	ld	s10,16(sp)
    80003f9a:	6da2                	ld	s11,8(sp)
    80003f9c:	6165                	addi	sp,sp,112
    80003f9e:	8082                	ret
    return -1;
    80003fa0:	557d                	li	a0,-1
}
    80003fa2:	8082                	ret
    return -1;
    80003fa4:	557d                	li	a0,-1
    80003fa6:	bff1                	j	80003f82 <writei+0xf2>
    return -1;
    80003fa8:	557d                	li	a0,-1
    80003faa:	bfe1                	j	80003f82 <writei+0xf2>

0000000080003fac <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003fac:	1141                	addi	sp,sp,-16
    80003fae:	e406                	sd	ra,8(sp)
    80003fb0:	e022                	sd	s0,0(sp)
    80003fb2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fb4:	4639                	li	a2,14
    80003fb6:	ffffd097          	auipc	ra,0xffffd
    80003fba:	1f6080e7          	jalr	502(ra) # 800011ac <strncmp>
}
    80003fbe:	60a2                	ld	ra,8(sp)
    80003fc0:	6402                	ld	s0,0(sp)
    80003fc2:	0141                	addi	sp,sp,16
    80003fc4:	8082                	ret

0000000080003fc6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003fc6:	7139                	addi	sp,sp,-64
    80003fc8:	fc06                	sd	ra,56(sp)
    80003fca:	f822                	sd	s0,48(sp)
    80003fcc:	f426                	sd	s1,40(sp)
    80003fce:	f04a                	sd	s2,32(sp)
    80003fd0:	ec4e                	sd	s3,24(sp)
    80003fd2:	e852                	sd	s4,16(sp)
    80003fd4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003fd6:	04c51703          	lh	a4,76(a0)
    80003fda:	4785                	li	a5,1
    80003fdc:	00f71a63          	bne	a4,a5,80003ff0 <dirlookup+0x2a>
    80003fe0:	892a                	mv	s2,a0
    80003fe2:	89ae                	mv	s3,a1
    80003fe4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fe6:	497c                	lw	a5,84(a0)
    80003fe8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003fea:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fec:	e79d                	bnez	a5,8000401a <dirlookup+0x54>
    80003fee:	a8a5                	j	80004066 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ff0:	00004517          	auipc	a0,0x4
    80003ff4:	65850513          	addi	a0,a0,1624 # 80008648 <syscalls+0x190>
    80003ff8:	ffffc097          	auipc	ra,0xffffc
    80003ffc:	558080e7          	jalr	1368(ra) # 80000550 <panic>
      panic("dirlookup read");
    80004000:	00004517          	auipc	a0,0x4
    80004004:	66050513          	addi	a0,a0,1632 # 80008660 <syscalls+0x1a8>
    80004008:	ffffc097          	auipc	ra,0xffffc
    8000400c:	548080e7          	jalr	1352(ra) # 80000550 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004010:	24c1                	addiw	s1,s1,16
    80004012:	05492783          	lw	a5,84(s2)
    80004016:	04f4f763          	bgeu	s1,a5,80004064 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000401a:	4741                	li	a4,16
    8000401c:	86a6                	mv	a3,s1
    8000401e:	fc040613          	addi	a2,s0,-64
    80004022:	4581                	li	a1,0
    80004024:	854a                	mv	a0,s2
    80004026:	00000097          	auipc	ra,0x0
    8000402a:	d72080e7          	jalr	-654(ra) # 80003d98 <readi>
    8000402e:	47c1                	li	a5,16
    80004030:	fcf518e3          	bne	a0,a5,80004000 <dirlookup+0x3a>
    if(de.inum == 0)
    80004034:	fc045783          	lhu	a5,-64(s0)
    80004038:	dfe1                	beqz	a5,80004010 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000403a:	fc240593          	addi	a1,s0,-62
    8000403e:	854e                	mv	a0,s3
    80004040:	00000097          	auipc	ra,0x0
    80004044:	f6c080e7          	jalr	-148(ra) # 80003fac <namecmp>
    80004048:	f561                	bnez	a0,80004010 <dirlookup+0x4a>
      if(poff)
    8000404a:	000a0463          	beqz	s4,80004052 <dirlookup+0x8c>
        *poff = off;
    8000404e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004052:	fc045583          	lhu	a1,-64(s0)
    80004056:	00092503          	lw	a0,0(s2)
    8000405a:	fffff097          	auipc	ra,0xfffff
    8000405e:	756080e7          	jalr	1878(ra) # 800037b0 <iget>
    80004062:	a011                	j	80004066 <dirlookup+0xa0>
  return 0;
    80004064:	4501                	li	a0,0
}
    80004066:	70e2                	ld	ra,56(sp)
    80004068:	7442                	ld	s0,48(sp)
    8000406a:	74a2                	ld	s1,40(sp)
    8000406c:	7902                	ld	s2,32(sp)
    8000406e:	69e2                	ld	s3,24(sp)
    80004070:	6a42                	ld	s4,16(sp)
    80004072:	6121                	addi	sp,sp,64
    80004074:	8082                	ret

0000000080004076 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004076:	711d                	addi	sp,sp,-96
    80004078:	ec86                	sd	ra,88(sp)
    8000407a:	e8a2                	sd	s0,80(sp)
    8000407c:	e4a6                	sd	s1,72(sp)
    8000407e:	e0ca                	sd	s2,64(sp)
    80004080:	fc4e                	sd	s3,56(sp)
    80004082:	f852                	sd	s4,48(sp)
    80004084:	f456                	sd	s5,40(sp)
    80004086:	f05a                	sd	s6,32(sp)
    80004088:	ec5e                	sd	s7,24(sp)
    8000408a:	e862                	sd	s8,16(sp)
    8000408c:	e466                	sd	s9,8(sp)
    8000408e:	1080                	addi	s0,sp,96
    80004090:	84aa                	mv	s1,a0
    80004092:	8b2e                	mv	s6,a1
    80004094:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004096:	00054703          	lbu	a4,0(a0)
    8000409a:	02f00793          	li	a5,47
    8000409e:	02f70363          	beq	a4,a5,800040c4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040a2:	ffffe097          	auipc	ra,0xffffe
    800040a6:	c96080e7          	jalr	-874(ra) # 80001d38 <myproc>
    800040aa:	15853503          	ld	a0,344(a0)
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	9f8080e7          	jalr	-1544(ra) # 80003aa6 <idup>
    800040b6:	89aa                	mv	s3,a0
  while(*path == '/')
    800040b8:	02f00913          	li	s2,47
  len = path - s;
    800040bc:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800040be:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040c0:	4c05                	li	s8,1
    800040c2:	a865                	j	8000417a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800040c4:	4585                	li	a1,1
    800040c6:	4505                	li	a0,1
    800040c8:	fffff097          	auipc	ra,0xfffff
    800040cc:	6e8080e7          	jalr	1768(ra) # 800037b0 <iget>
    800040d0:	89aa                	mv	s3,a0
    800040d2:	b7dd                	j	800040b8 <namex+0x42>
      iunlockput(ip);
    800040d4:	854e                	mv	a0,s3
    800040d6:	00000097          	auipc	ra,0x0
    800040da:	c70080e7          	jalr	-912(ra) # 80003d46 <iunlockput>
      return 0;
    800040de:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040e0:	854e                	mv	a0,s3
    800040e2:	60e6                	ld	ra,88(sp)
    800040e4:	6446                	ld	s0,80(sp)
    800040e6:	64a6                	ld	s1,72(sp)
    800040e8:	6906                	ld	s2,64(sp)
    800040ea:	79e2                	ld	s3,56(sp)
    800040ec:	7a42                	ld	s4,48(sp)
    800040ee:	7aa2                	ld	s5,40(sp)
    800040f0:	7b02                	ld	s6,32(sp)
    800040f2:	6be2                	ld	s7,24(sp)
    800040f4:	6c42                	ld	s8,16(sp)
    800040f6:	6ca2                	ld	s9,8(sp)
    800040f8:	6125                	addi	sp,sp,96
    800040fa:	8082                	ret
      iunlock(ip);
    800040fc:	854e                	mv	a0,s3
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	aa8080e7          	jalr	-1368(ra) # 80003ba6 <iunlock>
      return ip;
    80004106:	bfe9                	j	800040e0 <namex+0x6a>
      iunlockput(ip);
    80004108:	854e                	mv	a0,s3
    8000410a:	00000097          	auipc	ra,0x0
    8000410e:	c3c080e7          	jalr	-964(ra) # 80003d46 <iunlockput>
      return 0;
    80004112:	89d2                	mv	s3,s4
    80004114:	b7f1                	j	800040e0 <namex+0x6a>
  len = path - s;
    80004116:	40b48633          	sub	a2,s1,a1
    8000411a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000411e:	094cd463          	bge	s9,s4,800041a6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004122:	4639                	li	a2,14
    80004124:	8556                	mv	a0,s5
    80004126:	ffffd097          	auipc	ra,0xffffd
    8000412a:	00a080e7          	jalr	10(ra) # 80001130 <memmove>
  while(*path == '/')
    8000412e:	0004c783          	lbu	a5,0(s1)
    80004132:	01279763          	bne	a5,s2,80004140 <namex+0xca>
    path++;
    80004136:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004138:	0004c783          	lbu	a5,0(s1)
    8000413c:	ff278de3          	beq	a5,s2,80004136 <namex+0xc0>
    ilock(ip);
    80004140:	854e                	mv	a0,s3
    80004142:	00000097          	auipc	ra,0x0
    80004146:	9a2080e7          	jalr	-1630(ra) # 80003ae4 <ilock>
    if(ip->type != T_DIR){
    8000414a:	04c99783          	lh	a5,76(s3)
    8000414e:	f98793e3          	bne	a5,s8,800040d4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004152:	000b0563          	beqz	s6,8000415c <namex+0xe6>
    80004156:	0004c783          	lbu	a5,0(s1)
    8000415a:	d3cd                	beqz	a5,800040fc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000415c:	865e                	mv	a2,s7
    8000415e:	85d6                	mv	a1,s5
    80004160:	854e                	mv	a0,s3
    80004162:	00000097          	auipc	ra,0x0
    80004166:	e64080e7          	jalr	-412(ra) # 80003fc6 <dirlookup>
    8000416a:	8a2a                	mv	s4,a0
    8000416c:	dd51                	beqz	a0,80004108 <namex+0x92>
    iunlockput(ip);
    8000416e:	854e                	mv	a0,s3
    80004170:	00000097          	auipc	ra,0x0
    80004174:	bd6080e7          	jalr	-1066(ra) # 80003d46 <iunlockput>
    ip = next;
    80004178:	89d2                	mv	s3,s4
  while(*path == '/')
    8000417a:	0004c783          	lbu	a5,0(s1)
    8000417e:	05279763          	bne	a5,s2,800041cc <namex+0x156>
    path++;
    80004182:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004184:	0004c783          	lbu	a5,0(s1)
    80004188:	ff278de3          	beq	a5,s2,80004182 <namex+0x10c>
  if(*path == 0)
    8000418c:	c79d                	beqz	a5,800041ba <namex+0x144>
    path++;
    8000418e:	85a6                	mv	a1,s1
  len = path - s;
    80004190:	8a5e                	mv	s4,s7
    80004192:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004194:	01278963          	beq	a5,s2,800041a6 <namex+0x130>
    80004198:	dfbd                	beqz	a5,80004116 <namex+0xa0>
    path++;
    8000419a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000419c:	0004c783          	lbu	a5,0(s1)
    800041a0:	ff279ce3          	bne	a5,s2,80004198 <namex+0x122>
    800041a4:	bf8d                	j	80004116 <namex+0xa0>
    memmove(name, s, len);
    800041a6:	2601                	sext.w	a2,a2
    800041a8:	8556                	mv	a0,s5
    800041aa:	ffffd097          	auipc	ra,0xffffd
    800041ae:	f86080e7          	jalr	-122(ra) # 80001130 <memmove>
    name[len] = 0;
    800041b2:	9a56                	add	s4,s4,s5
    800041b4:	000a0023          	sb	zero,0(s4)
    800041b8:	bf9d                	j	8000412e <namex+0xb8>
  if(nameiparent){
    800041ba:	f20b03e3          	beqz	s6,800040e0 <namex+0x6a>
    iput(ip);
    800041be:	854e                	mv	a0,s3
    800041c0:	00000097          	auipc	ra,0x0
    800041c4:	ade080e7          	jalr	-1314(ra) # 80003c9e <iput>
    return 0;
    800041c8:	4981                	li	s3,0
    800041ca:	bf19                	j	800040e0 <namex+0x6a>
  if(*path == 0)
    800041cc:	d7fd                	beqz	a5,800041ba <namex+0x144>
  while(*path != '/' && *path != 0)
    800041ce:	0004c783          	lbu	a5,0(s1)
    800041d2:	85a6                	mv	a1,s1
    800041d4:	b7d1                	j	80004198 <namex+0x122>

00000000800041d6 <dirlink>:
{
    800041d6:	7139                	addi	sp,sp,-64
    800041d8:	fc06                	sd	ra,56(sp)
    800041da:	f822                	sd	s0,48(sp)
    800041dc:	f426                	sd	s1,40(sp)
    800041de:	f04a                	sd	s2,32(sp)
    800041e0:	ec4e                	sd	s3,24(sp)
    800041e2:	e852                	sd	s4,16(sp)
    800041e4:	0080                	addi	s0,sp,64
    800041e6:	892a                	mv	s2,a0
    800041e8:	8a2e                	mv	s4,a1
    800041ea:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041ec:	4601                	li	a2,0
    800041ee:	00000097          	auipc	ra,0x0
    800041f2:	dd8080e7          	jalr	-552(ra) # 80003fc6 <dirlookup>
    800041f6:	e93d                	bnez	a0,8000426c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041f8:	05492483          	lw	s1,84(s2)
    800041fc:	c49d                	beqz	s1,8000422a <dirlink+0x54>
    800041fe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004200:	4741                	li	a4,16
    80004202:	86a6                	mv	a3,s1
    80004204:	fc040613          	addi	a2,s0,-64
    80004208:	4581                	li	a1,0
    8000420a:	854a                	mv	a0,s2
    8000420c:	00000097          	auipc	ra,0x0
    80004210:	b8c080e7          	jalr	-1140(ra) # 80003d98 <readi>
    80004214:	47c1                	li	a5,16
    80004216:	06f51163          	bne	a0,a5,80004278 <dirlink+0xa2>
    if(de.inum == 0)
    8000421a:	fc045783          	lhu	a5,-64(s0)
    8000421e:	c791                	beqz	a5,8000422a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004220:	24c1                	addiw	s1,s1,16
    80004222:	05492783          	lw	a5,84(s2)
    80004226:	fcf4ede3          	bltu	s1,a5,80004200 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000422a:	4639                	li	a2,14
    8000422c:	85d2                	mv	a1,s4
    8000422e:	fc240513          	addi	a0,s0,-62
    80004232:	ffffd097          	auipc	ra,0xffffd
    80004236:	fb6080e7          	jalr	-74(ra) # 800011e8 <strncpy>
  de.inum = inum;
    8000423a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000423e:	4741                	li	a4,16
    80004240:	86a6                	mv	a3,s1
    80004242:	fc040613          	addi	a2,s0,-64
    80004246:	4581                	li	a1,0
    80004248:	854a                	mv	a0,s2
    8000424a:	00000097          	auipc	ra,0x0
    8000424e:	c46080e7          	jalr	-954(ra) # 80003e90 <writei>
    80004252:	872a                	mv	a4,a0
    80004254:	47c1                	li	a5,16
  return 0;
    80004256:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004258:	02f71863          	bne	a4,a5,80004288 <dirlink+0xb2>
}
    8000425c:	70e2                	ld	ra,56(sp)
    8000425e:	7442                	ld	s0,48(sp)
    80004260:	74a2                	ld	s1,40(sp)
    80004262:	7902                	ld	s2,32(sp)
    80004264:	69e2                	ld	s3,24(sp)
    80004266:	6a42                	ld	s4,16(sp)
    80004268:	6121                	addi	sp,sp,64
    8000426a:	8082                	ret
    iput(ip);
    8000426c:	00000097          	auipc	ra,0x0
    80004270:	a32080e7          	jalr	-1486(ra) # 80003c9e <iput>
    return -1;
    80004274:	557d                	li	a0,-1
    80004276:	b7dd                	j	8000425c <dirlink+0x86>
      panic("dirlink read");
    80004278:	00004517          	auipc	a0,0x4
    8000427c:	3f850513          	addi	a0,a0,1016 # 80008670 <syscalls+0x1b8>
    80004280:	ffffc097          	auipc	ra,0xffffc
    80004284:	2d0080e7          	jalr	720(ra) # 80000550 <panic>
    panic("dirlink");
    80004288:	00004517          	auipc	a0,0x4
    8000428c:	50850513          	addi	a0,a0,1288 # 80008790 <syscalls+0x2d8>
    80004290:	ffffc097          	auipc	ra,0xffffc
    80004294:	2c0080e7          	jalr	704(ra) # 80000550 <panic>

0000000080004298 <namei>:

struct inode*
namei(char *path)
{
    80004298:	1101                	addi	sp,sp,-32
    8000429a:	ec06                	sd	ra,24(sp)
    8000429c:	e822                	sd	s0,16(sp)
    8000429e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042a0:	fe040613          	addi	a2,s0,-32
    800042a4:	4581                	li	a1,0
    800042a6:	00000097          	auipc	ra,0x0
    800042aa:	dd0080e7          	jalr	-560(ra) # 80004076 <namex>
}
    800042ae:	60e2                	ld	ra,24(sp)
    800042b0:	6442                	ld	s0,16(sp)
    800042b2:	6105                	addi	sp,sp,32
    800042b4:	8082                	ret

00000000800042b6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042b6:	1141                	addi	sp,sp,-16
    800042b8:	e406                	sd	ra,8(sp)
    800042ba:	e022                	sd	s0,0(sp)
    800042bc:	0800                	addi	s0,sp,16
    800042be:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042c0:	4585                	li	a1,1
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	db4080e7          	jalr	-588(ra) # 80004076 <namex>
}
    800042ca:	60a2                	ld	ra,8(sp)
    800042cc:	6402                	ld	s0,0(sp)
    800042ce:	0141                	addi	sp,sp,16
    800042d0:	8082                	ret

00000000800042d2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042d2:	1101                	addi	sp,sp,-32
    800042d4:	ec06                	sd	ra,24(sp)
    800042d6:	e822                	sd	s0,16(sp)
    800042d8:	e426                	sd	s1,8(sp)
    800042da:	e04a                	sd	s2,0(sp)
    800042dc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042de:	00022917          	auipc	s2,0x22
    800042e2:	c8a90913          	addi	s2,s2,-886 # 80025f68 <log>
    800042e6:	02092583          	lw	a1,32(s2)
    800042ea:	03092503          	lw	a0,48(s2)
    800042ee:	fffff097          	auipc	ra,0xfffff
    800042f2:	ea4080e7          	jalr	-348(ra) # 80003192 <bread>
    800042f6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042f8:	03492683          	lw	a3,52(s2)
    800042fc:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042fe:	02d05763          	blez	a3,8000432c <write_head+0x5a>
    80004302:	00022797          	auipc	a5,0x22
    80004306:	c9e78793          	addi	a5,a5,-866 # 80025fa0 <log+0x38>
    8000430a:	06450713          	addi	a4,a0,100
    8000430e:	36fd                	addiw	a3,a3,-1
    80004310:	1682                	slli	a3,a3,0x20
    80004312:	9281                	srli	a3,a3,0x20
    80004314:	068a                	slli	a3,a3,0x2
    80004316:	00022617          	auipc	a2,0x22
    8000431a:	c8e60613          	addi	a2,a2,-882 # 80025fa4 <log+0x3c>
    8000431e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004320:	4390                	lw	a2,0(a5)
    80004322:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004324:	0791                	addi	a5,a5,4
    80004326:	0711                	addi	a4,a4,4
    80004328:	fed79ce3          	bne	a5,a3,80004320 <write_head+0x4e>
  }
  bwrite(buf);
    8000432c:	8526                	mv	a0,s1
    8000432e:	fffff097          	auipc	ra,0xfffff
    80004332:	082080e7          	jalr	130(ra) # 800033b0 <bwrite>
  brelse(buf);
    80004336:	8526                	mv	a0,s1
    80004338:	fffff097          	auipc	ra,0xfffff
    8000433c:	0b6080e7          	jalr	182(ra) # 800033ee <brelse>
}
    80004340:	60e2                	ld	ra,24(sp)
    80004342:	6442                	ld	s0,16(sp)
    80004344:	64a2                	ld	s1,8(sp)
    80004346:	6902                	ld	s2,0(sp)
    80004348:	6105                	addi	sp,sp,32
    8000434a:	8082                	ret

000000008000434c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000434c:	00022797          	auipc	a5,0x22
    80004350:	c507a783          	lw	a5,-944(a5) # 80025f9c <log+0x34>
    80004354:	0af05d63          	blez	a5,8000440e <install_trans+0xc2>
{
    80004358:	7139                	addi	sp,sp,-64
    8000435a:	fc06                	sd	ra,56(sp)
    8000435c:	f822                	sd	s0,48(sp)
    8000435e:	f426                	sd	s1,40(sp)
    80004360:	f04a                	sd	s2,32(sp)
    80004362:	ec4e                	sd	s3,24(sp)
    80004364:	e852                	sd	s4,16(sp)
    80004366:	e456                	sd	s5,8(sp)
    80004368:	e05a                	sd	s6,0(sp)
    8000436a:	0080                	addi	s0,sp,64
    8000436c:	8b2a                	mv	s6,a0
    8000436e:	00022a97          	auipc	s5,0x22
    80004372:	c32a8a93          	addi	s5,s5,-974 # 80025fa0 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004376:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004378:	00022997          	auipc	s3,0x22
    8000437c:	bf098993          	addi	s3,s3,-1040 # 80025f68 <log>
    80004380:	a035                	j	800043ac <install_trans+0x60>
      bunpin(dbuf);
    80004382:	8526                	mv	a0,s1
    80004384:	fffff097          	auipc	ra,0xfffff
    80004388:	150080e7          	jalr	336(ra) # 800034d4 <bunpin>
    brelse(lbuf);
    8000438c:	854a                	mv	a0,s2
    8000438e:	fffff097          	auipc	ra,0xfffff
    80004392:	060080e7          	jalr	96(ra) # 800033ee <brelse>
    brelse(dbuf);
    80004396:	8526                	mv	a0,s1
    80004398:	fffff097          	auipc	ra,0xfffff
    8000439c:	056080e7          	jalr	86(ra) # 800033ee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043a0:	2a05                	addiw	s4,s4,1
    800043a2:	0a91                	addi	s5,s5,4
    800043a4:	0349a783          	lw	a5,52(s3)
    800043a8:	04fa5963          	bge	s4,a5,800043fa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043ac:	0209a583          	lw	a1,32(s3)
    800043b0:	014585bb          	addw	a1,a1,s4
    800043b4:	2585                	addiw	a1,a1,1
    800043b6:	0309a503          	lw	a0,48(s3)
    800043ba:	fffff097          	auipc	ra,0xfffff
    800043be:	dd8080e7          	jalr	-552(ra) # 80003192 <bread>
    800043c2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043c4:	000aa583          	lw	a1,0(s5)
    800043c8:	0309a503          	lw	a0,48(s3)
    800043cc:	fffff097          	auipc	ra,0xfffff
    800043d0:	dc6080e7          	jalr	-570(ra) # 80003192 <bread>
    800043d4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043d6:	40000613          	li	a2,1024
    800043da:	06090593          	addi	a1,s2,96
    800043de:	06050513          	addi	a0,a0,96
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	d4e080e7          	jalr	-690(ra) # 80001130 <memmove>
    bwrite(dbuf);  // write dst to disk
    800043ea:	8526                	mv	a0,s1
    800043ec:	fffff097          	auipc	ra,0xfffff
    800043f0:	fc4080e7          	jalr	-60(ra) # 800033b0 <bwrite>
    if(recovering == 0)
    800043f4:	f80b1ce3          	bnez	s6,8000438c <install_trans+0x40>
    800043f8:	b769                	j	80004382 <install_trans+0x36>
}
    800043fa:	70e2                	ld	ra,56(sp)
    800043fc:	7442                	ld	s0,48(sp)
    800043fe:	74a2                	ld	s1,40(sp)
    80004400:	7902                	ld	s2,32(sp)
    80004402:	69e2                	ld	s3,24(sp)
    80004404:	6a42                	ld	s4,16(sp)
    80004406:	6aa2                	ld	s5,8(sp)
    80004408:	6b02                	ld	s6,0(sp)
    8000440a:	6121                	addi	sp,sp,64
    8000440c:	8082                	ret
    8000440e:	8082                	ret

0000000080004410 <initlog>:
{
    80004410:	7179                	addi	sp,sp,-48
    80004412:	f406                	sd	ra,40(sp)
    80004414:	f022                	sd	s0,32(sp)
    80004416:	ec26                	sd	s1,24(sp)
    80004418:	e84a                	sd	s2,16(sp)
    8000441a:	e44e                	sd	s3,8(sp)
    8000441c:	1800                	addi	s0,sp,48
    8000441e:	892a                	mv	s2,a0
    80004420:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004422:	00022497          	auipc	s1,0x22
    80004426:	b4648493          	addi	s1,s1,-1210 # 80025f68 <log>
    8000442a:	00004597          	auipc	a1,0x4
    8000442e:	25658593          	addi	a1,a1,598 # 80008680 <syscalls+0x1c8>
    80004432:	8526                	mv	a0,s1
    80004434:	ffffd097          	auipc	ra,0xffffd
    80004438:	a38080e7          	jalr	-1480(ra) # 80000e6c <initlock>
  log.start = sb->logstart;
    8000443c:	0149a583          	lw	a1,20(s3)
    80004440:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    80004442:	0109a783          	lw	a5,16(s3)
    80004446:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    80004448:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000444c:	854a                	mv	a0,s2
    8000444e:	fffff097          	auipc	ra,0xfffff
    80004452:	d44080e7          	jalr	-700(ra) # 80003192 <bread>
  log.lh.n = lh->n;
    80004456:	513c                	lw	a5,96(a0)
    80004458:	d8dc                	sw	a5,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000445a:	02f05563          	blez	a5,80004484 <initlog+0x74>
    8000445e:	06450713          	addi	a4,a0,100
    80004462:	00022697          	auipc	a3,0x22
    80004466:	b3e68693          	addi	a3,a3,-1218 # 80025fa0 <log+0x38>
    8000446a:	37fd                	addiw	a5,a5,-1
    8000446c:	1782                	slli	a5,a5,0x20
    8000446e:	9381                	srli	a5,a5,0x20
    80004470:	078a                	slli	a5,a5,0x2
    80004472:	06850613          	addi	a2,a0,104
    80004476:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004478:	4310                	lw	a2,0(a4)
    8000447a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000447c:	0711                	addi	a4,a4,4
    8000447e:	0691                	addi	a3,a3,4
    80004480:	fef71ce3          	bne	a4,a5,80004478 <initlog+0x68>
  brelse(buf);
    80004484:	fffff097          	auipc	ra,0xfffff
    80004488:	f6a080e7          	jalr	-150(ra) # 800033ee <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000448c:	4505                	li	a0,1
    8000448e:	00000097          	auipc	ra,0x0
    80004492:	ebe080e7          	jalr	-322(ra) # 8000434c <install_trans>
  log.lh.n = 0;
    80004496:	00022797          	auipc	a5,0x22
    8000449a:	b007a323          	sw	zero,-1274(a5) # 80025f9c <log+0x34>
  write_head(); // clear the log
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	e34080e7          	jalr	-460(ra) # 800042d2 <write_head>
}
    800044a6:	70a2                	ld	ra,40(sp)
    800044a8:	7402                	ld	s0,32(sp)
    800044aa:	64e2                	ld	s1,24(sp)
    800044ac:	6942                	ld	s2,16(sp)
    800044ae:	69a2                	ld	s3,8(sp)
    800044b0:	6145                	addi	sp,sp,48
    800044b2:	8082                	ret

00000000800044b4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044b4:	1101                	addi	sp,sp,-32
    800044b6:	ec06                	sd	ra,24(sp)
    800044b8:	e822                	sd	s0,16(sp)
    800044ba:	e426                	sd	s1,8(sp)
    800044bc:	e04a                	sd	s2,0(sp)
    800044be:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044c0:	00022517          	auipc	a0,0x22
    800044c4:	aa850513          	addi	a0,a0,-1368 # 80025f68 <log>
    800044c8:	ffffd097          	auipc	ra,0xffffd
    800044cc:	828080e7          	jalr	-2008(ra) # 80000cf0 <acquire>
  while(1){
    if(log.committing){
    800044d0:	00022497          	auipc	s1,0x22
    800044d4:	a9848493          	addi	s1,s1,-1384 # 80025f68 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044d8:	4979                	li	s2,30
    800044da:	a039                	j	800044e8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800044dc:	85a6                	mv	a1,s1
    800044de:	8526                	mv	a0,s1
    800044e0:	ffffe097          	auipc	ra,0xffffe
    800044e4:	068080e7          	jalr	104(ra) # 80002548 <sleep>
    if(log.committing){
    800044e8:	54dc                	lw	a5,44(s1)
    800044ea:	fbed                	bnez	a5,800044dc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044ec:	549c                	lw	a5,40(s1)
    800044ee:	0017871b          	addiw	a4,a5,1
    800044f2:	0007069b          	sext.w	a3,a4
    800044f6:	0027179b          	slliw	a5,a4,0x2
    800044fa:	9fb9                	addw	a5,a5,a4
    800044fc:	0017979b          	slliw	a5,a5,0x1
    80004500:	58d8                	lw	a4,52(s1)
    80004502:	9fb9                	addw	a5,a5,a4
    80004504:	00f95963          	bge	s2,a5,80004516 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004508:	85a6                	mv	a1,s1
    8000450a:	8526                	mv	a0,s1
    8000450c:	ffffe097          	auipc	ra,0xffffe
    80004510:	03c080e7          	jalr	60(ra) # 80002548 <sleep>
    80004514:	bfd1                	j	800044e8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004516:	00022517          	auipc	a0,0x22
    8000451a:	a5250513          	addi	a0,a0,-1454 # 80025f68 <log>
    8000451e:	d514                	sw	a3,40(a0)
      release(&log.lock);
    80004520:	ffffd097          	auipc	ra,0xffffd
    80004524:	8a0080e7          	jalr	-1888(ra) # 80000dc0 <release>
      break;
    }
  }
}
    80004528:	60e2                	ld	ra,24(sp)
    8000452a:	6442                	ld	s0,16(sp)
    8000452c:	64a2                	ld	s1,8(sp)
    8000452e:	6902                	ld	s2,0(sp)
    80004530:	6105                	addi	sp,sp,32
    80004532:	8082                	ret

0000000080004534 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004534:	7139                	addi	sp,sp,-64
    80004536:	fc06                	sd	ra,56(sp)
    80004538:	f822                	sd	s0,48(sp)
    8000453a:	f426                	sd	s1,40(sp)
    8000453c:	f04a                	sd	s2,32(sp)
    8000453e:	ec4e                	sd	s3,24(sp)
    80004540:	e852                	sd	s4,16(sp)
    80004542:	e456                	sd	s5,8(sp)
    80004544:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004546:	00022497          	auipc	s1,0x22
    8000454a:	a2248493          	addi	s1,s1,-1502 # 80025f68 <log>
    8000454e:	8526                	mv	a0,s1
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	7a0080e7          	jalr	1952(ra) # 80000cf0 <acquire>
  log.outstanding -= 1;
    80004558:	549c                	lw	a5,40(s1)
    8000455a:	37fd                	addiw	a5,a5,-1
    8000455c:	0007891b          	sext.w	s2,a5
    80004560:	d49c                	sw	a5,40(s1)
  if(log.committing)
    80004562:	54dc                	lw	a5,44(s1)
    80004564:	efb9                	bnez	a5,800045c2 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004566:	06091663          	bnez	s2,800045d2 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000456a:	00022497          	auipc	s1,0x22
    8000456e:	9fe48493          	addi	s1,s1,-1538 # 80025f68 <log>
    80004572:	4785                	li	a5,1
    80004574:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004576:	8526                	mv	a0,s1
    80004578:	ffffd097          	auipc	ra,0xffffd
    8000457c:	848080e7          	jalr	-1976(ra) # 80000dc0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004580:	58dc                	lw	a5,52(s1)
    80004582:	06f04763          	bgtz	a5,800045f0 <end_op+0xbc>
    acquire(&log.lock);
    80004586:	00022497          	auipc	s1,0x22
    8000458a:	9e248493          	addi	s1,s1,-1566 # 80025f68 <log>
    8000458e:	8526                	mv	a0,s1
    80004590:	ffffc097          	auipc	ra,0xffffc
    80004594:	760080e7          	jalr	1888(ra) # 80000cf0 <acquire>
    log.committing = 0;
    80004598:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    8000459c:	8526                	mv	a0,s1
    8000459e:	ffffe097          	auipc	ra,0xffffe
    800045a2:	130080e7          	jalr	304(ra) # 800026ce <wakeup>
    release(&log.lock);
    800045a6:	8526                	mv	a0,s1
    800045a8:	ffffd097          	auipc	ra,0xffffd
    800045ac:	818080e7          	jalr	-2024(ra) # 80000dc0 <release>
}
    800045b0:	70e2                	ld	ra,56(sp)
    800045b2:	7442                	ld	s0,48(sp)
    800045b4:	74a2                	ld	s1,40(sp)
    800045b6:	7902                	ld	s2,32(sp)
    800045b8:	69e2                	ld	s3,24(sp)
    800045ba:	6a42                	ld	s4,16(sp)
    800045bc:	6aa2                	ld	s5,8(sp)
    800045be:	6121                	addi	sp,sp,64
    800045c0:	8082                	ret
    panic("log.committing");
    800045c2:	00004517          	auipc	a0,0x4
    800045c6:	0c650513          	addi	a0,a0,198 # 80008688 <syscalls+0x1d0>
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	f86080e7          	jalr	-122(ra) # 80000550 <panic>
    wakeup(&log);
    800045d2:	00022497          	auipc	s1,0x22
    800045d6:	99648493          	addi	s1,s1,-1642 # 80025f68 <log>
    800045da:	8526                	mv	a0,s1
    800045dc:	ffffe097          	auipc	ra,0xffffe
    800045e0:	0f2080e7          	jalr	242(ra) # 800026ce <wakeup>
  release(&log.lock);
    800045e4:	8526                	mv	a0,s1
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	7da080e7          	jalr	2010(ra) # 80000dc0 <release>
  if(do_commit){
    800045ee:	b7c9                	j	800045b0 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045f0:	00022a97          	auipc	s5,0x22
    800045f4:	9b0a8a93          	addi	s5,s5,-1616 # 80025fa0 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800045f8:	00022a17          	auipc	s4,0x22
    800045fc:	970a0a13          	addi	s4,s4,-1680 # 80025f68 <log>
    80004600:	020a2583          	lw	a1,32(s4)
    80004604:	012585bb          	addw	a1,a1,s2
    80004608:	2585                	addiw	a1,a1,1
    8000460a:	030a2503          	lw	a0,48(s4)
    8000460e:	fffff097          	auipc	ra,0xfffff
    80004612:	b84080e7          	jalr	-1148(ra) # 80003192 <bread>
    80004616:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004618:	000aa583          	lw	a1,0(s5)
    8000461c:	030a2503          	lw	a0,48(s4)
    80004620:	fffff097          	auipc	ra,0xfffff
    80004624:	b72080e7          	jalr	-1166(ra) # 80003192 <bread>
    80004628:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000462a:	40000613          	li	a2,1024
    8000462e:	06050593          	addi	a1,a0,96
    80004632:	06048513          	addi	a0,s1,96
    80004636:	ffffd097          	auipc	ra,0xffffd
    8000463a:	afa080e7          	jalr	-1286(ra) # 80001130 <memmove>
    bwrite(to);  // write the log
    8000463e:	8526                	mv	a0,s1
    80004640:	fffff097          	auipc	ra,0xfffff
    80004644:	d70080e7          	jalr	-656(ra) # 800033b0 <bwrite>
    brelse(from);
    80004648:	854e                	mv	a0,s3
    8000464a:	fffff097          	auipc	ra,0xfffff
    8000464e:	da4080e7          	jalr	-604(ra) # 800033ee <brelse>
    brelse(to);
    80004652:	8526                	mv	a0,s1
    80004654:	fffff097          	auipc	ra,0xfffff
    80004658:	d9a080e7          	jalr	-614(ra) # 800033ee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000465c:	2905                	addiw	s2,s2,1
    8000465e:	0a91                	addi	s5,s5,4
    80004660:	034a2783          	lw	a5,52(s4)
    80004664:	f8f94ee3          	blt	s2,a5,80004600 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004668:	00000097          	auipc	ra,0x0
    8000466c:	c6a080e7          	jalr	-918(ra) # 800042d2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004670:	4501                	li	a0,0
    80004672:	00000097          	auipc	ra,0x0
    80004676:	cda080e7          	jalr	-806(ra) # 8000434c <install_trans>
    log.lh.n = 0;
    8000467a:	00022797          	auipc	a5,0x22
    8000467e:	9207a123          	sw	zero,-1758(a5) # 80025f9c <log+0x34>
    write_head();    // Erase the transaction from the log
    80004682:	00000097          	auipc	ra,0x0
    80004686:	c50080e7          	jalr	-944(ra) # 800042d2 <write_head>
    8000468a:	bdf5                	j	80004586 <end_op+0x52>

000000008000468c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000468c:	1101                	addi	sp,sp,-32
    8000468e:	ec06                	sd	ra,24(sp)
    80004690:	e822                	sd	s0,16(sp)
    80004692:	e426                	sd	s1,8(sp)
    80004694:	e04a                	sd	s2,0(sp)
    80004696:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004698:	00022717          	auipc	a4,0x22
    8000469c:	90472703          	lw	a4,-1788(a4) # 80025f9c <log+0x34>
    800046a0:	47f5                	li	a5,29
    800046a2:	08e7c063          	blt	a5,a4,80004722 <log_write+0x96>
    800046a6:	84aa                	mv	s1,a0
    800046a8:	00022797          	auipc	a5,0x22
    800046ac:	8e47a783          	lw	a5,-1820(a5) # 80025f8c <log+0x24>
    800046b0:	37fd                	addiw	a5,a5,-1
    800046b2:	06f75863          	bge	a4,a5,80004722 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046b6:	00022797          	auipc	a5,0x22
    800046ba:	8da7a783          	lw	a5,-1830(a5) # 80025f90 <log+0x28>
    800046be:	06f05a63          	blez	a5,80004732 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800046c2:	00022917          	auipc	s2,0x22
    800046c6:	8a690913          	addi	s2,s2,-1882 # 80025f68 <log>
    800046ca:	854a                	mv	a0,s2
    800046cc:	ffffc097          	auipc	ra,0xffffc
    800046d0:	624080e7          	jalr	1572(ra) # 80000cf0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800046d4:	03492603          	lw	a2,52(s2)
    800046d8:	06c05563          	blez	a2,80004742 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046dc:	44cc                	lw	a1,12(s1)
    800046de:	00022717          	auipc	a4,0x22
    800046e2:	8c270713          	addi	a4,a4,-1854 # 80025fa0 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    800046e6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046e8:	4314                	lw	a3,0(a4)
    800046ea:	04b68d63          	beq	a3,a1,80004744 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800046ee:	2785                	addiw	a5,a5,1
    800046f0:	0711                	addi	a4,a4,4
    800046f2:	fec79be3          	bne	a5,a2,800046e8 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046f6:	0631                	addi	a2,a2,12
    800046f8:	060a                	slli	a2,a2,0x2
    800046fa:	00022797          	auipc	a5,0x22
    800046fe:	86e78793          	addi	a5,a5,-1938 # 80025f68 <log>
    80004702:	963e                	add	a2,a2,a5
    80004704:	44dc                	lw	a5,12(s1)
    80004706:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004708:	8526                	mv	a0,s1
    8000470a:	fffff097          	auipc	ra,0xfffff
    8000470e:	d76080e7          	jalr	-650(ra) # 80003480 <bpin>
    log.lh.n++;
    80004712:	00022717          	auipc	a4,0x22
    80004716:	85670713          	addi	a4,a4,-1962 # 80025f68 <log>
    8000471a:	5b5c                	lw	a5,52(a4)
    8000471c:	2785                	addiw	a5,a5,1
    8000471e:	db5c                	sw	a5,52(a4)
    80004720:	a83d                	j	8000475e <log_write+0xd2>
    panic("too big a transaction");
    80004722:	00004517          	auipc	a0,0x4
    80004726:	f7650513          	addi	a0,a0,-138 # 80008698 <syscalls+0x1e0>
    8000472a:	ffffc097          	auipc	ra,0xffffc
    8000472e:	e26080e7          	jalr	-474(ra) # 80000550 <panic>
    panic("log_write outside of trans");
    80004732:	00004517          	auipc	a0,0x4
    80004736:	f7e50513          	addi	a0,a0,-130 # 800086b0 <syscalls+0x1f8>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	e16080e7          	jalr	-490(ra) # 80000550 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004742:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004744:	00c78713          	addi	a4,a5,12
    80004748:	00271693          	slli	a3,a4,0x2
    8000474c:	00022717          	auipc	a4,0x22
    80004750:	81c70713          	addi	a4,a4,-2020 # 80025f68 <log>
    80004754:	9736                	add	a4,a4,a3
    80004756:	44d4                	lw	a3,12(s1)
    80004758:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000475a:	faf607e3          	beq	a2,a5,80004708 <log_write+0x7c>
  }
  release(&log.lock);
    8000475e:	00022517          	auipc	a0,0x22
    80004762:	80a50513          	addi	a0,a0,-2038 # 80025f68 <log>
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	65a080e7          	jalr	1626(ra) # 80000dc0 <release>
}
    8000476e:	60e2                	ld	ra,24(sp)
    80004770:	6442                	ld	s0,16(sp)
    80004772:	64a2                	ld	s1,8(sp)
    80004774:	6902                	ld	s2,0(sp)
    80004776:	6105                	addi	sp,sp,32
    80004778:	8082                	ret

000000008000477a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000477a:	1101                	addi	sp,sp,-32
    8000477c:	ec06                	sd	ra,24(sp)
    8000477e:	e822                	sd	s0,16(sp)
    80004780:	e426                	sd	s1,8(sp)
    80004782:	e04a                	sd	s2,0(sp)
    80004784:	1000                	addi	s0,sp,32
    80004786:	84aa                	mv	s1,a0
    80004788:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000478a:	00004597          	auipc	a1,0x4
    8000478e:	f4658593          	addi	a1,a1,-186 # 800086d0 <syscalls+0x218>
    80004792:	0521                	addi	a0,a0,8
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	6d8080e7          	jalr	1752(ra) # 80000e6c <initlock>
  lk->name = name;
    8000479c:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    800047a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047a4:	0204a823          	sw	zero,48(s1)
}
    800047a8:	60e2                	ld	ra,24(sp)
    800047aa:	6442                	ld	s0,16(sp)
    800047ac:	64a2                	ld	s1,8(sp)
    800047ae:	6902                	ld	s2,0(sp)
    800047b0:	6105                	addi	sp,sp,32
    800047b2:	8082                	ret

00000000800047b4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800047b4:	1101                	addi	sp,sp,-32
    800047b6:	ec06                	sd	ra,24(sp)
    800047b8:	e822                	sd	s0,16(sp)
    800047ba:	e426                	sd	s1,8(sp)
    800047bc:	e04a                	sd	s2,0(sp)
    800047be:	1000                	addi	s0,sp,32
    800047c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047c2:	00850913          	addi	s2,a0,8
    800047c6:	854a                	mv	a0,s2
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	528080e7          	jalr	1320(ra) # 80000cf0 <acquire>
  while (lk->locked) {
    800047d0:	409c                	lw	a5,0(s1)
    800047d2:	cb89                	beqz	a5,800047e4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047d4:	85ca                	mv	a1,s2
    800047d6:	8526                	mv	a0,s1
    800047d8:	ffffe097          	auipc	ra,0xffffe
    800047dc:	d70080e7          	jalr	-656(ra) # 80002548 <sleep>
  while (lk->locked) {
    800047e0:	409c                	lw	a5,0(s1)
    800047e2:	fbed                	bnez	a5,800047d4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047e4:	4785                	li	a5,1
    800047e6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047e8:	ffffd097          	auipc	ra,0xffffd
    800047ec:	550080e7          	jalr	1360(ra) # 80001d38 <myproc>
    800047f0:	413c                	lw	a5,64(a0)
    800047f2:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800047f4:	854a                	mv	a0,s2
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	5ca080e7          	jalr	1482(ra) # 80000dc0 <release>
}
    800047fe:	60e2                	ld	ra,24(sp)
    80004800:	6442                	ld	s0,16(sp)
    80004802:	64a2                	ld	s1,8(sp)
    80004804:	6902                	ld	s2,0(sp)
    80004806:	6105                	addi	sp,sp,32
    80004808:	8082                	ret

000000008000480a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000480a:	1101                	addi	sp,sp,-32
    8000480c:	ec06                	sd	ra,24(sp)
    8000480e:	e822                	sd	s0,16(sp)
    80004810:	e426                	sd	s1,8(sp)
    80004812:	e04a                	sd	s2,0(sp)
    80004814:	1000                	addi	s0,sp,32
    80004816:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004818:	00850913          	addi	s2,a0,8
    8000481c:	854a                	mv	a0,s2
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	4d2080e7          	jalr	1234(ra) # 80000cf0 <acquire>
  lk->locked = 0;
    80004826:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000482a:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    8000482e:	8526                	mv	a0,s1
    80004830:	ffffe097          	auipc	ra,0xffffe
    80004834:	e9e080e7          	jalr	-354(ra) # 800026ce <wakeup>
  release(&lk->lk);
    80004838:	854a                	mv	a0,s2
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	586080e7          	jalr	1414(ra) # 80000dc0 <release>
}
    80004842:	60e2                	ld	ra,24(sp)
    80004844:	6442                	ld	s0,16(sp)
    80004846:	64a2                	ld	s1,8(sp)
    80004848:	6902                	ld	s2,0(sp)
    8000484a:	6105                	addi	sp,sp,32
    8000484c:	8082                	ret

000000008000484e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000484e:	7179                	addi	sp,sp,-48
    80004850:	f406                	sd	ra,40(sp)
    80004852:	f022                	sd	s0,32(sp)
    80004854:	ec26                	sd	s1,24(sp)
    80004856:	e84a                	sd	s2,16(sp)
    80004858:	e44e                	sd	s3,8(sp)
    8000485a:	1800                	addi	s0,sp,48
    8000485c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000485e:	00850913          	addi	s2,a0,8
    80004862:	854a                	mv	a0,s2
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	48c080e7          	jalr	1164(ra) # 80000cf0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000486c:	409c                	lw	a5,0(s1)
    8000486e:	ef99                	bnez	a5,8000488c <holdingsleep+0x3e>
    80004870:	4481                	li	s1,0
  release(&lk->lk);
    80004872:	854a                	mv	a0,s2
    80004874:	ffffc097          	auipc	ra,0xffffc
    80004878:	54c080e7          	jalr	1356(ra) # 80000dc0 <release>
  return r;
}
    8000487c:	8526                	mv	a0,s1
    8000487e:	70a2                	ld	ra,40(sp)
    80004880:	7402                	ld	s0,32(sp)
    80004882:	64e2                	ld	s1,24(sp)
    80004884:	6942                	ld	s2,16(sp)
    80004886:	69a2                	ld	s3,8(sp)
    80004888:	6145                	addi	sp,sp,48
    8000488a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000488c:	0304a983          	lw	s3,48(s1)
    80004890:	ffffd097          	auipc	ra,0xffffd
    80004894:	4a8080e7          	jalr	1192(ra) # 80001d38 <myproc>
    80004898:	4124                	lw	s1,64(a0)
    8000489a:	413484b3          	sub	s1,s1,s3
    8000489e:	0014b493          	seqz	s1,s1
    800048a2:	bfc1                	j	80004872 <holdingsleep+0x24>

00000000800048a4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048a4:	1141                	addi	sp,sp,-16
    800048a6:	e406                	sd	ra,8(sp)
    800048a8:	e022                	sd	s0,0(sp)
    800048aa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048ac:	00004597          	auipc	a1,0x4
    800048b0:	e3458593          	addi	a1,a1,-460 # 800086e0 <syscalls+0x228>
    800048b4:	00022517          	auipc	a0,0x22
    800048b8:	80450513          	addi	a0,a0,-2044 # 800260b8 <ftable>
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	5b0080e7          	jalr	1456(ra) # 80000e6c <initlock>
}
    800048c4:	60a2                	ld	ra,8(sp)
    800048c6:	6402                	ld	s0,0(sp)
    800048c8:	0141                	addi	sp,sp,16
    800048ca:	8082                	ret

00000000800048cc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048cc:	1101                	addi	sp,sp,-32
    800048ce:	ec06                	sd	ra,24(sp)
    800048d0:	e822                	sd	s0,16(sp)
    800048d2:	e426                	sd	s1,8(sp)
    800048d4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048d6:	00021517          	auipc	a0,0x21
    800048da:	7e250513          	addi	a0,a0,2018 # 800260b8 <ftable>
    800048de:	ffffc097          	auipc	ra,0xffffc
    800048e2:	412080e7          	jalr	1042(ra) # 80000cf0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048e6:	00021497          	auipc	s1,0x21
    800048ea:	7f248493          	addi	s1,s1,2034 # 800260d8 <ftable+0x20>
    800048ee:	00022717          	auipc	a4,0x22
    800048f2:	78a70713          	addi	a4,a4,1930 # 80027078 <ftable+0xfc0>
    if(f->ref == 0){
    800048f6:	40dc                	lw	a5,4(s1)
    800048f8:	cf99                	beqz	a5,80004916 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048fa:	02848493          	addi	s1,s1,40
    800048fe:	fee49ce3          	bne	s1,a4,800048f6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004902:	00021517          	auipc	a0,0x21
    80004906:	7b650513          	addi	a0,a0,1974 # 800260b8 <ftable>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	4b6080e7          	jalr	1206(ra) # 80000dc0 <release>
  return 0;
    80004912:	4481                	li	s1,0
    80004914:	a819                	j	8000492a <filealloc+0x5e>
      f->ref = 1;
    80004916:	4785                	li	a5,1
    80004918:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000491a:	00021517          	auipc	a0,0x21
    8000491e:	79e50513          	addi	a0,a0,1950 # 800260b8 <ftable>
    80004922:	ffffc097          	auipc	ra,0xffffc
    80004926:	49e080e7          	jalr	1182(ra) # 80000dc0 <release>
}
    8000492a:	8526                	mv	a0,s1
    8000492c:	60e2                	ld	ra,24(sp)
    8000492e:	6442                	ld	s0,16(sp)
    80004930:	64a2                	ld	s1,8(sp)
    80004932:	6105                	addi	sp,sp,32
    80004934:	8082                	ret

0000000080004936 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004936:	1101                	addi	sp,sp,-32
    80004938:	ec06                	sd	ra,24(sp)
    8000493a:	e822                	sd	s0,16(sp)
    8000493c:	e426                	sd	s1,8(sp)
    8000493e:	1000                	addi	s0,sp,32
    80004940:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004942:	00021517          	auipc	a0,0x21
    80004946:	77650513          	addi	a0,a0,1910 # 800260b8 <ftable>
    8000494a:	ffffc097          	auipc	ra,0xffffc
    8000494e:	3a6080e7          	jalr	934(ra) # 80000cf0 <acquire>
  if(f->ref < 1)
    80004952:	40dc                	lw	a5,4(s1)
    80004954:	02f05263          	blez	a5,80004978 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004958:	2785                	addiw	a5,a5,1
    8000495a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000495c:	00021517          	auipc	a0,0x21
    80004960:	75c50513          	addi	a0,a0,1884 # 800260b8 <ftable>
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	45c080e7          	jalr	1116(ra) # 80000dc0 <release>
  return f;
}
    8000496c:	8526                	mv	a0,s1
    8000496e:	60e2                	ld	ra,24(sp)
    80004970:	6442                	ld	s0,16(sp)
    80004972:	64a2                	ld	s1,8(sp)
    80004974:	6105                	addi	sp,sp,32
    80004976:	8082                	ret
    panic("filedup");
    80004978:	00004517          	auipc	a0,0x4
    8000497c:	d7050513          	addi	a0,a0,-656 # 800086e8 <syscalls+0x230>
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	bd0080e7          	jalr	-1072(ra) # 80000550 <panic>

0000000080004988 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004988:	7139                	addi	sp,sp,-64
    8000498a:	fc06                	sd	ra,56(sp)
    8000498c:	f822                	sd	s0,48(sp)
    8000498e:	f426                	sd	s1,40(sp)
    80004990:	f04a                	sd	s2,32(sp)
    80004992:	ec4e                	sd	s3,24(sp)
    80004994:	e852                	sd	s4,16(sp)
    80004996:	e456                	sd	s5,8(sp)
    80004998:	0080                	addi	s0,sp,64
    8000499a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000499c:	00021517          	auipc	a0,0x21
    800049a0:	71c50513          	addi	a0,a0,1820 # 800260b8 <ftable>
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	34c080e7          	jalr	844(ra) # 80000cf0 <acquire>
  if(f->ref < 1)
    800049ac:	40dc                	lw	a5,4(s1)
    800049ae:	06f05163          	blez	a5,80004a10 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800049b2:	37fd                	addiw	a5,a5,-1
    800049b4:	0007871b          	sext.w	a4,a5
    800049b8:	c0dc                	sw	a5,4(s1)
    800049ba:	06e04363          	bgtz	a4,80004a20 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049be:	0004a903          	lw	s2,0(s1)
    800049c2:	0094ca83          	lbu	s5,9(s1)
    800049c6:	0104ba03          	ld	s4,16(s1)
    800049ca:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049ce:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049d2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049d6:	00021517          	auipc	a0,0x21
    800049da:	6e250513          	addi	a0,a0,1762 # 800260b8 <ftable>
    800049de:	ffffc097          	auipc	ra,0xffffc
    800049e2:	3e2080e7          	jalr	994(ra) # 80000dc0 <release>

  if(ff.type == FD_PIPE){
    800049e6:	4785                	li	a5,1
    800049e8:	04f90d63          	beq	s2,a5,80004a42 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049ec:	3979                	addiw	s2,s2,-2
    800049ee:	4785                	li	a5,1
    800049f0:	0527e063          	bltu	a5,s2,80004a30 <fileclose+0xa8>
    begin_op();
    800049f4:	00000097          	auipc	ra,0x0
    800049f8:	ac0080e7          	jalr	-1344(ra) # 800044b4 <begin_op>
    iput(ff.ip);
    800049fc:	854e                	mv	a0,s3
    800049fe:	fffff097          	auipc	ra,0xfffff
    80004a02:	2a0080e7          	jalr	672(ra) # 80003c9e <iput>
    end_op();
    80004a06:	00000097          	auipc	ra,0x0
    80004a0a:	b2e080e7          	jalr	-1234(ra) # 80004534 <end_op>
    80004a0e:	a00d                	j	80004a30 <fileclose+0xa8>
    panic("fileclose");
    80004a10:	00004517          	auipc	a0,0x4
    80004a14:	ce050513          	addi	a0,a0,-800 # 800086f0 <syscalls+0x238>
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	b38080e7          	jalr	-1224(ra) # 80000550 <panic>
    release(&ftable.lock);
    80004a20:	00021517          	auipc	a0,0x21
    80004a24:	69850513          	addi	a0,a0,1688 # 800260b8 <ftable>
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	398080e7          	jalr	920(ra) # 80000dc0 <release>
  }
}
    80004a30:	70e2                	ld	ra,56(sp)
    80004a32:	7442                	ld	s0,48(sp)
    80004a34:	74a2                	ld	s1,40(sp)
    80004a36:	7902                	ld	s2,32(sp)
    80004a38:	69e2                	ld	s3,24(sp)
    80004a3a:	6a42                	ld	s4,16(sp)
    80004a3c:	6aa2                	ld	s5,8(sp)
    80004a3e:	6121                	addi	sp,sp,64
    80004a40:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a42:	85d6                	mv	a1,s5
    80004a44:	8552                	mv	a0,s4
    80004a46:	00000097          	auipc	ra,0x0
    80004a4a:	372080e7          	jalr	882(ra) # 80004db8 <pipeclose>
    80004a4e:	b7cd                	j	80004a30 <fileclose+0xa8>

0000000080004a50 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a50:	715d                	addi	sp,sp,-80
    80004a52:	e486                	sd	ra,72(sp)
    80004a54:	e0a2                	sd	s0,64(sp)
    80004a56:	fc26                	sd	s1,56(sp)
    80004a58:	f84a                	sd	s2,48(sp)
    80004a5a:	f44e                	sd	s3,40(sp)
    80004a5c:	0880                	addi	s0,sp,80
    80004a5e:	84aa                	mv	s1,a0
    80004a60:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a62:	ffffd097          	auipc	ra,0xffffd
    80004a66:	2d6080e7          	jalr	726(ra) # 80001d38 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a6a:	409c                	lw	a5,0(s1)
    80004a6c:	37f9                	addiw	a5,a5,-2
    80004a6e:	4705                	li	a4,1
    80004a70:	04f76763          	bltu	a4,a5,80004abe <filestat+0x6e>
    80004a74:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a76:	6c88                	ld	a0,24(s1)
    80004a78:	fffff097          	auipc	ra,0xfffff
    80004a7c:	06c080e7          	jalr	108(ra) # 80003ae4 <ilock>
    stati(f->ip, &st);
    80004a80:	fb840593          	addi	a1,s0,-72
    80004a84:	6c88                	ld	a0,24(s1)
    80004a86:	fffff097          	auipc	ra,0xfffff
    80004a8a:	2e8080e7          	jalr	744(ra) # 80003d6e <stati>
    iunlock(f->ip);
    80004a8e:	6c88                	ld	a0,24(s1)
    80004a90:	fffff097          	auipc	ra,0xfffff
    80004a94:	116080e7          	jalr	278(ra) # 80003ba6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a98:	46e1                	li	a3,24
    80004a9a:	fb840613          	addi	a2,s0,-72
    80004a9e:	85ce                	mv	a1,s3
    80004aa0:	05893503          	ld	a0,88(s2)
    80004aa4:	ffffd097          	auipc	ra,0xffffd
    80004aa8:	f88080e7          	jalr	-120(ra) # 80001a2c <copyout>
    80004aac:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ab0:	60a6                	ld	ra,72(sp)
    80004ab2:	6406                	ld	s0,64(sp)
    80004ab4:	74e2                	ld	s1,56(sp)
    80004ab6:	7942                	ld	s2,48(sp)
    80004ab8:	79a2                	ld	s3,40(sp)
    80004aba:	6161                	addi	sp,sp,80
    80004abc:	8082                	ret
  return -1;
    80004abe:	557d                	li	a0,-1
    80004ac0:	bfc5                	j	80004ab0 <filestat+0x60>

0000000080004ac2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ac2:	7179                	addi	sp,sp,-48
    80004ac4:	f406                	sd	ra,40(sp)
    80004ac6:	f022                	sd	s0,32(sp)
    80004ac8:	ec26                	sd	s1,24(sp)
    80004aca:	e84a                	sd	s2,16(sp)
    80004acc:	e44e                	sd	s3,8(sp)
    80004ace:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ad0:	00854783          	lbu	a5,8(a0)
    80004ad4:	c3d5                	beqz	a5,80004b78 <fileread+0xb6>
    80004ad6:	84aa                	mv	s1,a0
    80004ad8:	89ae                	mv	s3,a1
    80004ada:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004adc:	411c                	lw	a5,0(a0)
    80004ade:	4705                	li	a4,1
    80004ae0:	04e78963          	beq	a5,a4,80004b32 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ae4:	470d                	li	a4,3
    80004ae6:	04e78d63          	beq	a5,a4,80004b40 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004aea:	4709                	li	a4,2
    80004aec:	06e79e63          	bne	a5,a4,80004b68 <fileread+0xa6>
    ilock(f->ip);
    80004af0:	6d08                	ld	a0,24(a0)
    80004af2:	fffff097          	auipc	ra,0xfffff
    80004af6:	ff2080e7          	jalr	-14(ra) # 80003ae4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004afa:	874a                	mv	a4,s2
    80004afc:	5094                	lw	a3,32(s1)
    80004afe:	864e                	mv	a2,s3
    80004b00:	4585                	li	a1,1
    80004b02:	6c88                	ld	a0,24(s1)
    80004b04:	fffff097          	auipc	ra,0xfffff
    80004b08:	294080e7          	jalr	660(ra) # 80003d98 <readi>
    80004b0c:	892a                	mv	s2,a0
    80004b0e:	00a05563          	blez	a0,80004b18 <fileread+0x56>
      f->off += r;
    80004b12:	509c                	lw	a5,32(s1)
    80004b14:	9fa9                	addw	a5,a5,a0
    80004b16:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b18:	6c88                	ld	a0,24(s1)
    80004b1a:	fffff097          	auipc	ra,0xfffff
    80004b1e:	08c080e7          	jalr	140(ra) # 80003ba6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b22:	854a                	mv	a0,s2
    80004b24:	70a2                	ld	ra,40(sp)
    80004b26:	7402                	ld	s0,32(sp)
    80004b28:	64e2                	ld	s1,24(sp)
    80004b2a:	6942                	ld	s2,16(sp)
    80004b2c:	69a2                	ld	s3,8(sp)
    80004b2e:	6145                	addi	sp,sp,48
    80004b30:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b32:	6908                	ld	a0,16(a0)
    80004b34:	00000097          	auipc	ra,0x0
    80004b38:	422080e7          	jalr	1058(ra) # 80004f56 <piperead>
    80004b3c:	892a                	mv	s2,a0
    80004b3e:	b7d5                	j	80004b22 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b40:	02451783          	lh	a5,36(a0)
    80004b44:	03079693          	slli	a3,a5,0x30
    80004b48:	92c1                	srli	a3,a3,0x30
    80004b4a:	4725                	li	a4,9
    80004b4c:	02d76863          	bltu	a4,a3,80004b7c <fileread+0xba>
    80004b50:	0792                	slli	a5,a5,0x4
    80004b52:	00021717          	auipc	a4,0x21
    80004b56:	4c670713          	addi	a4,a4,1222 # 80026018 <devsw>
    80004b5a:	97ba                	add	a5,a5,a4
    80004b5c:	639c                	ld	a5,0(a5)
    80004b5e:	c38d                	beqz	a5,80004b80 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b60:	4505                	li	a0,1
    80004b62:	9782                	jalr	a5
    80004b64:	892a                	mv	s2,a0
    80004b66:	bf75                	j	80004b22 <fileread+0x60>
    panic("fileread");
    80004b68:	00004517          	auipc	a0,0x4
    80004b6c:	b9850513          	addi	a0,a0,-1128 # 80008700 <syscalls+0x248>
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	9e0080e7          	jalr	-1568(ra) # 80000550 <panic>
    return -1;
    80004b78:	597d                	li	s2,-1
    80004b7a:	b765                	j	80004b22 <fileread+0x60>
      return -1;
    80004b7c:	597d                	li	s2,-1
    80004b7e:	b755                	j	80004b22 <fileread+0x60>
    80004b80:	597d                	li	s2,-1
    80004b82:	b745                	j	80004b22 <fileread+0x60>

0000000080004b84 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004b84:	00954783          	lbu	a5,9(a0)
    80004b88:	14078563          	beqz	a5,80004cd2 <filewrite+0x14e>
{
    80004b8c:	715d                	addi	sp,sp,-80
    80004b8e:	e486                	sd	ra,72(sp)
    80004b90:	e0a2                	sd	s0,64(sp)
    80004b92:	fc26                	sd	s1,56(sp)
    80004b94:	f84a                	sd	s2,48(sp)
    80004b96:	f44e                	sd	s3,40(sp)
    80004b98:	f052                	sd	s4,32(sp)
    80004b9a:	ec56                	sd	s5,24(sp)
    80004b9c:	e85a                	sd	s6,16(sp)
    80004b9e:	e45e                	sd	s7,8(sp)
    80004ba0:	e062                	sd	s8,0(sp)
    80004ba2:	0880                	addi	s0,sp,80
    80004ba4:	892a                	mv	s2,a0
    80004ba6:	8aae                	mv	s5,a1
    80004ba8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004baa:	411c                	lw	a5,0(a0)
    80004bac:	4705                	li	a4,1
    80004bae:	02e78263          	beq	a5,a4,80004bd2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bb2:	470d                	li	a4,3
    80004bb4:	02e78563          	beq	a5,a4,80004bde <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bb8:	4709                	li	a4,2
    80004bba:	10e79463          	bne	a5,a4,80004cc2 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004bbe:	0ec05e63          	blez	a2,80004cba <filewrite+0x136>
    int i = 0;
    80004bc2:	4981                	li	s3,0
    80004bc4:	6b05                	lui	s6,0x1
    80004bc6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004bca:	6b85                	lui	s7,0x1
    80004bcc:	c00b8b9b          	addiw	s7,s7,-1024
    80004bd0:	a851                	j	80004c64 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004bd2:	6908                	ld	a0,16(a0)
    80004bd4:	00000097          	auipc	ra,0x0
    80004bd8:	25e080e7          	jalr	606(ra) # 80004e32 <pipewrite>
    80004bdc:	a85d                	j	80004c92 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bde:	02451783          	lh	a5,36(a0)
    80004be2:	03079693          	slli	a3,a5,0x30
    80004be6:	92c1                	srli	a3,a3,0x30
    80004be8:	4725                	li	a4,9
    80004bea:	0ed76663          	bltu	a4,a3,80004cd6 <filewrite+0x152>
    80004bee:	0792                	slli	a5,a5,0x4
    80004bf0:	00021717          	auipc	a4,0x21
    80004bf4:	42870713          	addi	a4,a4,1064 # 80026018 <devsw>
    80004bf8:	97ba                	add	a5,a5,a4
    80004bfa:	679c                	ld	a5,8(a5)
    80004bfc:	cff9                	beqz	a5,80004cda <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004bfe:	4505                	li	a0,1
    80004c00:	9782                	jalr	a5
    80004c02:	a841                	j	80004c92 <filewrite+0x10e>
    80004c04:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c08:	00000097          	auipc	ra,0x0
    80004c0c:	8ac080e7          	jalr	-1876(ra) # 800044b4 <begin_op>
      ilock(f->ip);
    80004c10:	01893503          	ld	a0,24(s2)
    80004c14:	fffff097          	auipc	ra,0xfffff
    80004c18:	ed0080e7          	jalr	-304(ra) # 80003ae4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c1c:	8762                	mv	a4,s8
    80004c1e:	02092683          	lw	a3,32(s2)
    80004c22:	01598633          	add	a2,s3,s5
    80004c26:	4585                	li	a1,1
    80004c28:	01893503          	ld	a0,24(s2)
    80004c2c:	fffff097          	auipc	ra,0xfffff
    80004c30:	264080e7          	jalr	612(ra) # 80003e90 <writei>
    80004c34:	84aa                	mv	s1,a0
    80004c36:	02a05f63          	blez	a0,80004c74 <filewrite+0xf0>
        f->off += r;
    80004c3a:	02092783          	lw	a5,32(s2)
    80004c3e:	9fa9                	addw	a5,a5,a0
    80004c40:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c44:	01893503          	ld	a0,24(s2)
    80004c48:	fffff097          	auipc	ra,0xfffff
    80004c4c:	f5e080e7          	jalr	-162(ra) # 80003ba6 <iunlock>
      end_op();
    80004c50:	00000097          	auipc	ra,0x0
    80004c54:	8e4080e7          	jalr	-1820(ra) # 80004534 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004c58:	049c1963          	bne	s8,s1,80004caa <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004c5c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c60:	0349d663          	bge	s3,s4,80004c8c <filewrite+0x108>
      int n1 = n - i;
    80004c64:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c68:	84be                	mv	s1,a5
    80004c6a:	2781                	sext.w	a5,a5
    80004c6c:	f8fb5ce3          	bge	s6,a5,80004c04 <filewrite+0x80>
    80004c70:	84de                	mv	s1,s7
    80004c72:	bf49                	j	80004c04 <filewrite+0x80>
      iunlock(f->ip);
    80004c74:	01893503          	ld	a0,24(s2)
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	f2e080e7          	jalr	-210(ra) # 80003ba6 <iunlock>
      end_op();
    80004c80:	00000097          	auipc	ra,0x0
    80004c84:	8b4080e7          	jalr	-1868(ra) # 80004534 <end_op>
      if(r < 0)
    80004c88:	fc04d8e3          	bgez	s1,80004c58 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004c8c:	8552                	mv	a0,s4
    80004c8e:	033a1863          	bne	s4,s3,80004cbe <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c92:	60a6                	ld	ra,72(sp)
    80004c94:	6406                	ld	s0,64(sp)
    80004c96:	74e2                	ld	s1,56(sp)
    80004c98:	7942                	ld	s2,48(sp)
    80004c9a:	79a2                	ld	s3,40(sp)
    80004c9c:	7a02                	ld	s4,32(sp)
    80004c9e:	6ae2                	ld	s5,24(sp)
    80004ca0:	6b42                	ld	s6,16(sp)
    80004ca2:	6ba2                	ld	s7,8(sp)
    80004ca4:	6c02                	ld	s8,0(sp)
    80004ca6:	6161                	addi	sp,sp,80
    80004ca8:	8082                	ret
        panic("short filewrite");
    80004caa:	00004517          	auipc	a0,0x4
    80004cae:	a6650513          	addi	a0,a0,-1434 # 80008710 <syscalls+0x258>
    80004cb2:	ffffc097          	auipc	ra,0xffffc
    80004cb6:	89e080e7          	jalr	-1890(ra) # 80000550 <panic>
    int i = 0;
    80004cba:	4981                	li	s3,0
    80004cbc:	bfc1                	j	80004c8c <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004cbe:	557d                	li	a0,-1
    80004cc0:	bfc9                	j	80004c92 <filewrite+0x10e>
    panic("filewrite");
    80004cc2:	00004517          	auipc	a0,0x4
    80004cc6:	a5e50513          	addi	a0,a0,-1442 # 80008720 <syscalls+0x268>
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	886080e7          	jalr	-1914(ra) # 80000550 <panic>
    return -1;
    80004cd2:	557d                	li	a0,-1
}
    80004cd4:	8082                	ret
      return -1;
    80004cd6:	557d                	li	a0,-1
    80004cd8:	bf6d                	j	80004c92 <filewrite+0x10e>
    80004cda:	557d                	li	a0,-1
    80004cdc:	bf5d                	j	80004c92 <filewrite+0x10e>

0000000080004cde <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004cde:	7179                	addi	sp,sp,-48
    80004ce0:	f406                	sd	ra,40(sp)
    80004ce2:	f022                	sd	s0,32(sp)
    80004ce4:	ec26                	sd	s1,24(sp)
    80004ce6:	e84a                	sd	s2,16(sp)
    80004ce8:	e44e                	sd	s3,8(sp)
    80004cea:	e052                	sd	s4,0(sp)
    80004cec:	1800                	addi	s0,sp,48
    80004cee:	84aa                	mv	s1,a0
    80004cf0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004cf2:	0005b023          	sd	zero,0(a1)
    80004cf6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cfa:	00000097          	auipc	ra,0x0
    80004cfe:	bd2080e7          	jalr	-1070(ra) # 800048cc <filealloc>
    80004d02:	e088                	sd	a0,0(s1)
    80004d04:	c551                	beqz	a0,80004d90 <pipealloc+0xb2>
    80004d06:	00000097          	auipc	ra,0x0
    80004d0a:	bc6080e7          	jalr	-1082(ra) # 800048cc <filealloc>
    80004d0e:	00aa3023          	sd	a0,0(s4)
    80004d12:	c92d                	beqz	a0,80004d84 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d14:	ffffc097          	auipc	ra,0xffffc
    80004d18:	e66080e7          	jalr	-410(ra) # 80000b7a <kalloc>
    80004d1c:	892a                	mv	s2,a0
    80004d1e:	c125                	beqz	a0,80004d7e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d20:	4985                	li	s3,1
    80004d22:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004d26:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004d2a:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004d2e:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004d32:	00004597          	auipc	a1,0x4
    80004d36:	9fe58593          	addi	a1,a1,-1538 # 80008730 <syscalls+0x278>
    80004d3a:	ffffc097          	auipc	ra,0xffffc
    80004d3e:	132080e7          	jalr	306(ra) # 80000e6c <initlock>
  (*f0)->type = FD_PIPE;
    80004d42:	609c                	ld	a5,0(s1)
    80004d44:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d48:	609c                	ld	a5,0(s1)
    80004d4a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d4e:	609c                	ld	a5,0(s1)
    80004d50:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d54:	609c                	ld	a5,0(s1)
    80004d56:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d5a:	000a3783          	ld	a5,0(s4)
    80004d5e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d62:	000a3783          	ld	a5,0(s4)
    80004d66:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d6a:	000a3783          	ld	a5,0(s4)
    80004d6e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d72:	000a3783          	ld	a5,0(s4)
    80004d76:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d7a:	4501                	li	a0,0
    80004d7c:	a025                	j	80004da4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d7e:	6088                	ld	a0,0(s1)
    80004d80:	e501                	bnez	a0,80004d88 <pipealloc+0xaa>
    80004d82:	a039                	j	80004d90 <pipealloc+0xb2>
    80004d84:	6088                	ld	a0,0(s1)
    80004d86:	c51d                	beqz	a0,80004db4 <pipealloc+0xd6>
    fileclose(*f0);
    80004d88:	00000097          	auipc	ra,0x0
    80004d8c:	c00080e7          	jalr	-1024(ra) # 80004988 <fileclose>
  if(*f1)
    80004d90:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d94:	557d                	li	a0,-1
  if(*f1)
    80004d96:	c799                	beqz	a5,80004da4 <pipealloc+0xc6>
    fileclose(*f1);
    80004d98:	853e                	mv	a0,a5
    80004d9a:	00000097          	auipc	ra,0x0
    80004d9e:	bee080e7          	jalr	-1042(ra) # 80004988 <fileclose>
  return -1;
    80004da2:	557d                	li	a0,-1
}
    80004da4:	70a2                	ld	ra,40(sp)
    80004da6:	7402                	ld	s0,32(sp)
    80004da8:	64e2                	ld	s1,24(sp)
    80004daa:	6942                	ld	s2,16(sp)
    80004dac:	69a2                	ld	s3,8(sp)
    80004dae:	6a02                	ld	s4,0(sp)
    80004db0:	6145                	addi	sp,sp,48
    80004db2:	8082                	ret
  return -1;
    80004db4:	557d                	li	a0,-1
    80004db6:	b7fd                	j	80004da4 <pipealloc+0xc6>

0000000080004db8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004db8:	1101                	addi	sp,sp,-32
    80004dba:	ec06                	sd	ra,24(sp)
    80004dbc:	e822                	sd	s0,16(sp)
    80004dbe:	e426                	sd	s1,8(sp)
    80004dc0:	e04a                	sd	s2,0(sp)
    80004dc2:	1000                	addi	s0,sp,32
    80004dc4:	84aa                	mv	s1,a0
    80004dc6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004dc8:	ffffc097          	auipc	ra,0xffffc
    80004dcc:	f28080e7          	jalr	-216(ra) # 80000cf0 <acquire>
  if(writable){
    80004dd0:	04090263          	beqz	s2,80004e14 <pipeclose+0x5c>
    pi->writeopen = 0;
    80004dd4:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004dd8:	22048513          	addi	a0,s1,544
    80004ddc:	ffffe097          	auipc	ra,0xffffe
    80004de0:	8f2080e7          	jalr	-1806(ra) # 800026ce <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004de4:	2284b783          	ld	a5,552(s1)
    80004de8:	ef9d                	bnez	a5,80004e26 <pipeclose+0x6e>
    release(&pi->lock);
    80004dea:	8526                	mv	a0,s1
    80004dec:	ffffc097          	auipc	ra,0xffffc
    80004df0:	fd4080e7          	jalr	-44(ra) # 80000dc0 <release>
#ifdef LAB_LOCK
    freelock(&pi->lock);
    80004df4:	8526                	mv	a0,s1
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	012080e7          	jalr	18(ra) # 80000e08 <freelock>
#endif    
    kfree((char*)pi);
    80004dfe:	8526                	mv	a0,s1
    80004e00:	ffffc097          	auipc	ra,0xffffc
    80004e04:	c2c080e7          	jalr	-980(ra) # 80000a2c <kfree>
  } else
    release(&pi->lock);
}
    80004e08:	60e2                	ld	ra,24(sp)
    80004e0a:	6442                	ld	s0,16(sp)
    80004e0c:	64a2                	ld	s1,8(sp)
    80004e0e:	6902                	ld	s2,0(sp)
    80004e10:	6105                	addi	sp,sp,32
    80004e12:	8082                	ret
    pi->readopen = 0;
    80004e14:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004e18:	22448513          	addi	a0,s1,548
    80004e1c:	ffffe097          	auipc	ra,0xffffe
    80004e20:	8b2080e7          	jalr	-1870(ra) # 800026ce <wakeup>
    80004e24:	b7c1                	j	80004de4 <pipeclose+0x2c>
    release(&pi->lock);
    80004e26:	8526                	mv	a0,s1
    80004e28:	ffffc097          	auipc	ra,0xffffc
    80004e2c:	f98080e7          	jalr	-104(ra) # 80000dc0 <release>
}
    80004e30:	bfe1                	j	80004e08 <pipeclose+0x50>

0000000080004e32 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e32:	7119                	addi	sp,sp,-128
    80004e34:	fc86                	sd	ra,120(sp)
    80004e36:	f8a2                	sd	s0,112(sp)
    80004e38:	f4a6                	sd	s1,104(sp)
    80004e3a:	f0ca                	sd	s2,96(sp)
    80004e3c:	ecce                	sd	s3,88(sp)
    80004e3e:	e8d2                	sd	s4,80(sp)
    80004e40:	e4d6                	sd	s5,72(sp)
    80004e42:	e0da                	sd	s6,64(sp)
    80004e44:	fc5e                	sd	s7,56(sp)
    80004e46:	f862                	sd	s8,48(sp)
    80004e48:	f466                	sd	s9,40(sp)
    80004e4a:	f06a                	sd	s10,32(sp)
    80004e4c:	ec6e                	sd	s11,24(sp)
    80004e4e:	0100                	addi	s0,sp,128
    80004e50:	84aa                	mv	s1,a0
    80004e52:	8cae                	mv	s9,a1
    80004e54:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004e56:	ffffd097          	auipc	ra,0xffffd
    80004e5a:	ee2080e7          	jalr	-286(ra) # 80001d38 <myproc>
    80004e5e:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004e60:	8526                	mv	a0,s1
    80004e62:	ffffc097          	auipc	ra,0xffffc
    80004e66:	e8e080e7          	jalr	-370(ra) # 80000cf0 <acquire>
  for(i = 0; i < n; i++){
    80004e6a:	0d605963          	blez	s6,80004f3c <pipewrite+0x10a>
    80004e6e:	89a6                	mv	s3,s1
    80004e70:	3b7d                	addiw	s6,s6,-1
    80004e72:	1b02                	slli	s6,s6,0x20
    80004e74:	020b5b13          	srli	s6,s6,0x20
    80004e78:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004e7a:	22048a93          	addi	s5,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004e7e:	22448a13          	addi	s4,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e82:	5dfd                	li	s11,-1
    80004e84:	000b8d1b          	sext.w	s10,s7
    80004e88:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004e8a:	2204a783          	lw	a5,544(s1)
    80004e8e:	2244a703          	lw	a4,548(s1)
    80004e92:	2007879b          	addiw	a5,a5,512
    80004e96:	02f71b63          	bne	a4,a5,80004ecc <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004e9a:	2284a783          	lw	a5,552(s1)
    80004e9e:	cbad                	beqz	a5,80004f10 <pipewrite+0xde>
    80004ea0:	03892783          	lw	a5,56(s2)
    80004ea4:	e7b5                	bnez	a5,80004f10 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004ea6:	8556                	mv	a0,s5
    80004ea8:	ffffe097          	auipc	ra,0xffffe
    80004eac:	826080e7          	jalr	-2010(ra) # 800026ce <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004eb0:	85ce                	mv	a1,s3
    80004eb2:	8552                	mv	a0,s4
    80004eb4:	ffffd097          	auipc	ra,0xffffd
    80004eb8:	694080e7          	jalr	1684(ra) # 80002548 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ebc:	2204a783          	lw	a5,544(s1)
    80004ec0:	2244a703          	lw	a4,548(s1)
    80004ec4:	2007879b          	addiw	a5,a5,512
    80004ec8:	fcf709e3          	beq	a4,a5,80004e9a <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ecc:	4685                	li	a3,1
    80004ece:	019b8633          	add	a2,s7,s9
    80004ed2:	f8f40593          	addi	a1,s0,-113
    80004ed6:	05893503          	ld	a0,88(s2)
    80004eda:	ffffd097          	auipc	ra,0xffffd
    80004ede:	bde080e7          	jalr	-1058(ra) # 80001ab8 <copyin>
    80004ee2:	05b50e63          	beq	a0,s11,80004f3e <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ee6:	2244a783          	lw	a5,548(s1)
    80004eea:	0017871b          	addiw	a4,a5,1
    80004eee:	22e4a223          	sw	a4,548(s1)
    80004ef2:	1ff7f793          	andi	a5,a5,511
    80004ef6:	97a6                	add	a5,a5,s1
    80004ef8:	f8f44703          	lbu	a4,-113(s0)
    80004efc:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004f00:	001d0c1b          	addiw	s8,s10,1
    80004f04:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004f08:	036b8b63          	beq	s7,s6,80004f3e <pipewrite+0x10c>
    80004f0c:	8bbe                	mv	s7,a5
    80004f0e:	bf9d                	j	80004e84 <pipewrite+0x52>
        release(&pi->lock);
    80004f10:	8526                	mv	a0,s1
    80004f12:	ffffc097          	auipc	ra,0xffffc
    80004f16:	eae080e7          	jalr	-338(ra) # 80000dc0 <release>
        return -1;
    80004f1a:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004f1c:	8562                	mv	a0,s8
    80004f1e:	70e6                	ld	ra,120(sp)
    80004f20:	7446                	ld	s0,112(sp)
    80004f22:	74a6                	ld	s1,104(sp)
    80004f24:	7906                	ld	s2,96(sp)
    80004f26:	69e6                	ld	s3,88(sp)
    80004f28:	6a46                	ld	s4,80(sp)
    80004f2a:	6aa6                	ld	s5,72(sp)
    80004f2c:	6b06                	ld	s6,64(sp)
    80004f2e:	7be2                	ld	s7,56(sp)
    80004f30:	7c42                	ld	s8,48(sp)
    80004f32:	7ca2                	ld	s9,40(sp)
    80004f34:	7d02                	ld	s10,32(sp)
    80004f36:	6de2                	ld	s11,24(sp)
    80004f38:	6109                	addi	sp,sp,128
    80004f3a:	8082                	ret
  for(i = 0; i < n; i++){
    80004f3c:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004f3e:	22048513          	addi	a0,s1,544
    80004f42:	ffffd097          	auipc	ra,0xffffd
    80004f46:	78c080e7          	jalr	1932(ra) # 800026ce <wakeup>
  release(&pi->lock);
    80004f4a:	8526                	mv	a0,s1
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	e74080e7          	jalr	-396(ra) # 80000dc0 <release>
  return i;
    80004f54:	b7e1                	j	80004f1c <pipewrite+0xea>

0000000080004f56 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f56:	715d                	addi	sp,sp,-80
    80004f58:	e486                	sd	ra,72(sp)
    80004f5a:	e0a2                	sd	s0,64(sp)
    80004f5c:	fc26                	sd	s1,56(sp)
    80004f5e:	f84a                	sd	s2,48(sp)
    80004f60:	f44e                	sd	s3,40(sp)
    80004f62:	f052                	sd	s4,32(sp)
    80004f64:	ec56                	sd	s5,24(sp)
    80004f66:	e85a                	sd	s6,16(sp)
    80004f68:	0880                	addi	s0,sp,80
    80004f6a:	84aa                	mv	s1,a0
    80004f6c:	892e                	mv	s2,a1
    80004f6e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f70:	ffffd097          	auipc	ra,0xffffd
    80004f74:	dc8080e7          	jalr	-568(ra) # 80001d38 <myproc>
    80004f78:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f7a:	8b26                	mv	s6,s1
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	d72080e7          	jalr	-654(ra) # 80000cf0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f86:	2204a703          	lw	a4,544(s1)
    80004f8a:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f8e:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f92:	02f71463          	bne	a4,a5,80004fba <piperead+0x64>
    80004f96:	22c4a783          	lw	a5,556(s1)
    80004f9a:	c385                	beqz	a5,80004fba <piperead+0x64>
    if(pr->killed){
    80004f9c:	038a2783          	lw	a5,56(s4)
    80004fa0:	ebc1                	bnez	a5,80005030 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fa2:	85da                	mv	a1,s6
    80004fa4:	854e                	mv	a0,s3
    80004fa6:	ffffd097          	auipc	ra,0xffffd
    80004faa:	5a2080e7          	jalr	1442(ra) # 80002548 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fae:	2204a703          	lw	a4,544(s1)
    80004fb2:	2244a783          	lw	a5,548(s1)
    80004fb6:	fef700e3          	beq	a4,a5,80004f96 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fba:	09505263          	blez	s5,8000503e <piperead+0xe8>
    80004fbe:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fc0:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004fc2:	2204a783          	lw	a5,544(s1)
    80004fc6:	2244a703          	lw	a4,548(s1)
    80004fca:	02f70d63          	beq	a4,a5,80005004 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fce:	0017871b          	addiw	a4,a5,1
    80004fd2:	22e4a023          	sw	a4,544(s1)
    80004fd6:	1ff7f793          	andi	a5,a5,511
    80004fda:	97a6                	add	a5,a5,s1
    80004fdc:	0207c783          	lbu	a5,32(a5)
    80004fe0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fe4:	4685                	li	a3,1
    80004fe6:	fbf40613          	addi	a2,s0,-65
    80004fea:	85ca                	mv	a1,s2
    80004fec:	058a3503          	ld	a0,88(s4)
    80004ff0:	ffffd097          	auipc	ra,0xffffd
    80004ff4:	a3c080e7          	jalr	-1476(ra) # 80001a2c <copyout>
    80004ff8:	01650663          	beq	a0,s6,80005004 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ffc:	2985                	addiw	s3,s3,1
    80004ffe:	0905                	addi	s2,s2,1
    80005000:	fd3a91e3          	bne	s5,s3,80004fc2 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005004:	22448513          	addi	a0,s1,548
    80005008:	ffffd097          	auipc	ra,0xffffd
    8000500c:	6c6080e7          	jalr	1734(ra) # 800026ce <wakeup>
  release(&pi->lock);
    80005010:	8526                	mv	a0,s1
    80005012:	ffffc097          	auipc	ra,0xffffc
    80005016:	dae080e7          	jalr	-594(ra) # 80000dc0 <release>
  return i;
}
    8000501a:	854e                	mv	a0,s3
    8000501c:	60a6                	ld	ra,72(sp)
    8000501e:	6406                	ld	s0,64(sp)
    80005020:	74e2                	ld	s1,56(sp)
    80005022:	7942                	ld	s2,48(sp)
    80005024:	79a2                	ld	s3,40(sp)
    80005026:	7a02                	ld	s4,32(sp)
    80005028:	6ae2                	ld	s5,24(sp)
    8000502a:	6b42                	ld	s6,16(sp)
    8000502c:	6161                	addi	sp,sp,80
    8000502e:	8082                	ret
      release(&pi->lock);
    80005030:	8526                	mv	a0,s1
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	d8e080e7          	jalr	-626(ra) # 80000dc0 <release>
      return -1;
    8000503a:	59fd                	li	s3,-1
    8000503c:	bff9                	j	8000501a <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000503e:	4981                	li	s3,0
    80005040:	b7d1                	j	80005004 <piperead+0xae>

0000000080005042 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005042:	df010113          	addi	sp,sp,-528
    80005046:	20113423          	sd	ra,520(sp)
    8000504a:	20813023          	sd	s0,512(sp)
    8000504e:	ffa6                	sd	s1,504(sp)
    80005050:	fbca                	sd	s2,496(sp)
    80005052:	f7ce                	sd	s3,488(sp)
    80005054:	f3d2                	sd	s4,480(sp)
    80005056:	efd6                	sd	s5,472(sp)
    80005058:	ebda                	sd	s6,464(sp)
    8000505a:	e7de                	sd	s7,456(sp)
    8000505c:	e3e2                	sd	s8,448(sp)
    8000505e:	ff66                	sd	s9,440(sp)
    80005060:	fb6a                	sd	s10,432(sp)
    80005062:	f76e                	sd	s11,424(sp)
    80005064:	0c00                	addi	s0,sp,528
    80005066:	84aa                	mv	s1,a0
    80005068:	dea43c23          	sd	a0,-520(s0)
    8000506c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005070:	ffffd097          	auipc	ra,0xffffd
    80005074:	cc8080e7          	jalr	-824(ra) # 80001d38 <myproc>
    80005078:	892a                	mv	s2,a0

  begin_op();
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	43a080e7          	jalr	1082(ra) # 800044b4 <begin_op>

  if((ip = namei(path)) == 0){
    80005082:	8526                	mv	a0,s1
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	214080e7          	jalr	532(ra) # 80004298 <namei>
    8000508c:	c92d                	beqz	a0,800050fe <exec+0xbc>
    8000508e:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005090:	fffff097          	auipc	ra,0xfffff
    80005094:	a54080e7          	jalr	-1452(ra) # 80003ae4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005098:	04000713          	li	a4,64
    8000509c:	4681                	li	a3,0
    8000509e:	e4840613          	addi	a2,s0,-440
    800050a2:	4581                	li	a1,0
    800050a4:	8526                	mv	a0,s1
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	cf2080e7          	jalr	-782(ra) # 80003d98 <readi>
    800050ae:	04000793          	li	a5,64
    800050b2:	00f51a63          	bne	a0,a5,800050c6 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800050b6:	e4842703          	lw	a4,-440(s0)
    800050ba:	464c47b7          	lui	a5,0x464c4
    800050be:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050c2:	04f70463          	beq	a4,a5,8000510a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800050c6:	8526                	mv	a0,s1
    800050c8:	fffff097          	auipc	ra,0xfffff
    800050cc:	c7e080e7          	jalr	-898(ra) # 80003d46 <iunlockput>
    end_op();
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	464080e7          	jalr	1124(ra) # 80004534 <end_op>
  }
  return -1;
    800050d8:	557d                	li	a0,-1
}
    800050da:	20813083          	ld	ra,520(sp)
    800050de:	20013403          	ld	s0,512(sp)
    800050e2:	74fe                	ld	s1,504(sp)
    800050e4:	795e                	ld	s2,496(sp)
    800050e6:	79be                	ld	s3,488(sp)
    800050e8:	7a1e                	ld	s4,480(sp)
    800050ea:	6afe                	ld	s5,472(sp)
    800050ec:	6b5e                	ld	s6,464(sp)
    800050ee:	6bbe                	ld	s7,456(sp)
    800050f0:	6c1e                	ld	s8,448(sp)
    800050f2:	7cfa                	ld	s9,440(sp)
    800050f4:	7d5a                	ld	s10,432(sp)
    800050f6:	7dba                	ld	s11,424(sp)
    800050f8:	21010113          	addi	sp,sp,528
    800050fc:	8082                	ret
    end_op();
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	436080e7          	jalr	1078(ra) # 80004534 <end_op>
    return -1;
    80005106:	557d                	li	a0,-1
    80005108:	bfc9                	j	800050da <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000510a:	854a                	mv	a0,s2
    8000510c:	ffffd097          	auipc	ra,0xffffd
    80005110:	cf0080e7          	jalr	-784(ra) # 80001dfc <proc_pagetable>
    80005114:	8baa                	mv	s7,a0
    80005116:	d945                	beqz	a0,800050c6 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005118:	e6842983          	lw	s3,-408(s0)
    8000511c:	e8045783          	lhu	a5,-384(s0)
    80005120:	c7ad                	beqz	a5,8000518a <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005122:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005124:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005126:	6c85                	lui	s9,0x1
    80005128:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000512c:	def43823          	sd	a5,-528(s0)
    80005130:	a42d                	j	8000535a <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005132:	00003517          	auipc	a0,0x3
    80005136:	60650513          	addi	a0,a0,1542 # 80008738 <syscalls+0x280>
    8000513a:	ffffb097          	auipc	ra,0xffffb
    8000513e:	416080e7          	jalr	1046(ra) # 80000550 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005142:	8756                	mv	a4,s5
    80005144:	012d86bb          	addw	a3,s11,s2
    80005148:	4581                	li	a1,0
    8000514a:	8526                	mv	a0,s1
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	c4c080e7          	jalr	-948(ra) # 80003d98 <readi>
    80005154:	2501                	sext.w	a0,a0
    80005156:	1aaa9963          	bne	s5,a0,80005308 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    8000515a:	6785                	lui	a5,0x1
    8000515c:	0127893b          	addw	s2,a5,s2
    80005160:	77fd                	lui	a5,0xfffff
    80005162:	01478a3b          	addw	s4,a5,s4
    80005166:	1f897163          	bgeu	s2,s8,80005348 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    8000516a:	02091593          	slli	a1,s2,0x20
    8000516e:	9181                	srli	a1,a1,0x20
    80005170:	95ea                	add	a1,a1,s10
    80005172:	855e                	mv	a0,s7
    80005174:	ffffc097          	auipc	ra,0xffffc
    80005178:	2f6080e7          	jalr	758(ra) # 8000146a <walkaddr>
    8000517c:	862a                	mv	a2,a0
    if(pa == 0)
    8000517e:	d955                	beqz	a0,80005132 <exec+0xf0>
      n = PGSIZE;
    80005180:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005182:	fd9a70e3          	bgeu	s4,s9,80005142 <exec+0x100>
      n = sz - i;
    80005186:	8ad2                	mv	s5,s4
    80005188:	bf6d                	j	80005142 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000518a:	4901                	li	s2,0
  iunlockput(ip);
    8000518c:	8526                	mv	a0,s1
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	bb8080e7          	jalr	-1096(ra) # 80003d46 <iunlockput>
  end_op();
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	39e080e7          	jalr	926(ra) # 80004534 <end_op>
  p = myproc();
    8000519e:	ffffd097          	auipc	ra,0xffffd
    800051a2:	b9a080e7          	jalr	-1126(ra) # 80001d38 <myproc>
    800051a6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800051a8:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800051ac:	6785                	lui	a5,0x1
    800051ae:	17fd                	addi	a5,a5,-1
    800051b0:	993e                	add	s2,s2,a5
    800051b2:	757d                	lui	a0,0xfffff
    800051b4:	00a977b3          	and	a5,s2,a0
    800051b8:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800051bc:	6609                	lui	a2,0x2
    800051be:	963e                	add	a2,a2,a5
    800051c0:	85be                	mv	a1,a5
    800051c2:	855e                	mv	a0,s7
    800051c4:	ffffc097          	auipc	ra,0xffffc
    800051c8:	618080e7          	jalr	1560(ra) # 800017dc <uvmalloc>
    800051cc:	8b2a                	mv	s6,a0
  ip = 0;
    800051ce:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800051d0:	12050c63          	beqz	a0,80005308 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800051d4:	75f9                	lui	a1,0xffffe
    800051d6:	95aa                	add	a1,a1,a0
    800051d8:	855e                	mv	a0,s7
    800051da:	ffffd097          	auipc	ra,0xffffd
    800051de:	820080e7          	jalr	-2016(ra) # 800019fa <uvmclear>
  stackbase = sp - PGSIZE;
    800051e2:	7c7d                	lui	s8,0xfffff
    800051e4:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800051e6:	e0043783          	ld	a5,-512(s0)
    800051ea:	6388                	ld	a0,0(a5)
    800051ec:	c535                	beqz	a0,80005258 <exec+0x216>
    800051ee:	e8840993          	addi	s3,s0,-376
    800051f2:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    800051f6:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	060080e7          	jalr	96(ra) # 80001258 <strlen>
    80005200:	2505                	addiw	a0,a0,1
    80005202:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005206:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000520a:	13896363          	bltu	s2,s8,80005330 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000520e:	e0043d83          	ld	s11,-512(s0)
    80005212:	000dba03          	ld	s4,0(s11)
    80005216:	8552                	mv	a0,s4
    80005218:	ffffc097          	auipc	ra,0xffffc
    8000521c:	040080e7          	jalr	64(ra) # 80001258 <strlen>
    80005220:	0015069b          	addiw	a3,a0,1
    80005224:	8652                	mv	a2,s4
    80005226:	85ca                	mv	a1,s2
    80005228:	855e                	mv	a0,s7
    8000522a:	ffffd097          	auipc	ra,0xffffd
    8000522e:	802080e7          	jalr	-2046(ra) # 80001a2c <copyout>
    80005232:	10054363          	bltz	a0,80005338 <exec+0x2f6>
    ustack[argc] = sp;
    80005236:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000523a:	0485                	addi	s1,s1,1
    8000523c:	008d8793          	addi	a5,s11,8
    80005240:	e0f43023          	sd	a5,-512(s0)
    80005244:	008db503          	ld	a0,8(s11)
    80005248:	c911                	beqz	a0,8000525c <exec+0x21a>
    if(argc >= MAXARG)
    8000524a:	09a1                	addi	s3,s3,8
    8000524c:	fb3c96e3          	bne	s9,s3,800051f8 <exec+0x1b6>
  sz = sz1;
    80005250:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005254:	4481                	li	s1,0
    80005256:	a84d                	j	80005308 <exec+0x2c6>
  sp = sz;
    80005258:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000525a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000525c:	00349793          	slli	a5,s1,0x3
    80005260:	f9040713          	addi	a4,s0,-112
    80005264:	97ba                	add	a5,a5,a4
    80005266:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    8000526a:	00148693          	addi	a3,s1,1
    8000526e:	068e                	slli	a3,a3,0x3
    80005270:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005274:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005278:	01897663          	bgeu	s2,s8,80005284 <exec+0x242>
  sz = sz1;
    8000527c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005280:	4481                	li	s1,0
    80005282:	a059                	j	80005308 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005284:	e8840613          	addi	a2,s0,-376
    80005288:	85ca                	mv	a1,s2
    8000528a:	855e                	mv	a0,s7
    8000528c:	ffffc097          	auipc	ra,0xffffc
    80005290:	7a0080e7          	jalr	1952(ra) # 80001a2c <copyout>
    80005294:	0a054663          	bltz	a0,80005340 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005298:	060ab783          	ld	a5,96(s5)
    8000529c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800052a0:	df843783          	ld	a5,-520(s0)
    800052a4:	0007c703          	lbu	a4,0(a5)
    800052a8:	cf11                	beqz	a4,800052c4 <exec+0x282>
    800052aa:	0785                	addi	a5,a5,1
    if(*s == '/')
    800052ac:	02f00693          	li	a3,47
    800052b0:	a029                	j	800052ba <exec+0x278>
  for(last=s=path; *s; s++)
    800052b2:	0785                	addi	a5,a5,1
    800052b4:	fff7c703          	lbu	a4,-1(a5)
    800052b8:	c711                	beqz	a4,800052c4 <exec+0x282>
    if(*s == '/')
    800052ba:	fed71ce3          	bne	a4,a3,800052b2 <exec+0x270>
      last = s+1;
    800052be:	def43c23          	sd	a5,-520(s0)
    800052c2:	bfc5                	j	800052b2 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    800052c4:	4641                	li	a2,16
    800052c6:	df843583          	ld	a1,-520(s0)
    800052ca:	160a8513          	addi	a0,s5,352
    800052ce:	ffffc097          	auipc	ra,0xffffc
    800052d2:	f58080e7          	jalr	-168(ra) # 80001226 <safestrcpy>
  oldpagetable = p->pagetable;
    800052d6:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800052da:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    800052de:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800052e2:	060ab783          	ld	a5,96(s5)
    800052e6:	e6043703          	ld	a4,-416(s0)
    800052ea:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052ec:	060ab783          	ld	a5,96(s5)
    800052f0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052f4:	85ea                	mv	a1,s10
    800052f6:	ffffd097          	auipc	ra,0xffffd
    800052fa:	ba2080e7          	jalr	-1118(ra) # 80001e98 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052fe:	0004851b          	sext.w	a0,s1
    80005302:	bbe1                	j	800050da <exec+0x98>
    80005304:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005308:	e0843583          	ld	a1,-504(s0)
    8000530c:	855e                	mv	a0,s7
    8000530e:	ffffd097          	auipc	ra,0xffffd
    80005312:	b8a080e7          	jalr	-1142(ra) # 80001e98 <proc_freepagetable>
  if(ip){
    80005316:	da0498e3          	bnez	s1,800050c6 <exec+0x84>
  return -1;
    8000531a:	557d                	li	a0,-1
    8000531c:	bb7d                	j	800050da <exec+0x98>
    8000531e:	e1243423          	sd	s2,-504(s0)
    80005322:	b7dd                	j	80005308 <exec+0x2c6>
    80005324:	e1243423          	sd	s2,-504(s0)
    80005328:	b7c5                	j	80005308 <exec+0x2c6>
    8000532a:	e1243423          	sd	s2,-504(s0)
    8000532e:	bfe9                	j	80005308 <exec+0x2c6>
  sz = sz1;
    80005330:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005334:	4481                	li	s1,0
    80005336:	bfc9                	j	80005308 <exec+0x2c6>
  sz = sz1;
    80005338:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000533c:	4481                	li	s1,0
    8000533e:	b7e9                	j	80005308 <exec+0x2c6>
  sz = sz1;
    80005340:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005344:	4481                	li	s1,0
    80005346:	b7c9                	j	80005308 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005348:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000534c:	2b05                	addiw	s6,s6,1
    8000534e:	0389899b          	addiw	s3,s3,56
    80005352:	e8045783          	lhu	a5,-384(s0)
    80005356:	e2fb5be3          	bge	s6,a5,8000518c <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000535a:	2981                	sext.w	s3,s3
    8000535c:	03800713          	li	a4,56
    80005360:	86ce                	mv	a3,s3
    80005362:	e1040613          	addi	a2,s0,-496
    80005366:	4581                	li	a1,0
    80005368:	8526                	mv	a0,s1
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	a2e080e7          	jalr	-1490(ra) # 80003d98 <readi>
    80005372:	03800793          	li	a5,56
    80005376:	f8f517e3          	bne	a0,a5,80005304 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    8000537a:	e1042783          	lw	a5,-496(s0)
    8000537e:	4705                	li	a4,1
    80005380:	fce796e3          	bne	a5,a4,8000534c <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005384:	e3843603          	ld	a2,-456(s0)
    80005388:	e3043783          	ld	a5,-464(s0)
    8000538c:	f8f669e3          	bltu	a2,a5,8000531e <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005390:	e2043783          	ld	a5,-480(s0)
    80005394:	963e                	add	a2,a2,a5
    80005396:	f8f667e3          	bltu	a2,a5,80005324 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000539a:	85ca                	mv	a1,s2
    8000539c:	855e                	mv	a0,s7
    8000539e:	ffffc097          	auipc	ra,0xffffc
    800053a2:	43e080e7          	jalr	1086(ra) # 800017dc <uvmalloc>
    800053a6:	e0a43423          	sd	a0,-504(s0)
    800053aa:	d141                	beqz	a0,8000532a <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    800053ac:	e2043d03          	ld	s10,-480(s0)
    800053b0:	df043783          	ld	a5,-528(s0)
    800053b4:	00fd77b3          	and	a5,s10,a5
    800053b8:	fba1                	bnez	a5,80005308 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053ba:	e1842d83          	lw	s11,-488(s0)
    800053be:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800053c2:	f80c03e3          	beqz	s8,80005348 <exec+0x306>
    800053c6:	8a62                	mv	s4,s8
    800053c8:	4901                	li	s2,0
    800053ca:	b345                	j	8000516a <exec+0x128>

00000000800053cc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800053cc:	7179                	addi	sp,sp,-48
    800053ce:	f406                	sd	ra,40(sp)
    800053d0:	f022                	sd	s0,32(sp)
    800053d2:	ec26                	sd	s1,24(sp)
    800053d4:	e84a                	sd	s2,16(sp)
    800053d6:	1800                	addi	s0,sp,48
    800053d8:	892e                	mv	s2,a1
    800053da:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800053dc:	fdc40593          	addi	a1,s0,-36
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	a16080e7          	jalr	-1514(ra) # 80002df6 <argint>
    800053e8:	04054063          	bltz	a0,80005428 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053ec:	fdc42703          	lw	a4,-36(s0)
    800053f0:	47bd                	li	a5,15
    800053f2:	02e7ed63          	bltu	a5,a4,8000542c <argfd+0x60>
    800053f6:	ffffd097          	auipc	ra,0xffffd
    800053fa:	942080e7          	jalr	-1726(ra) # 80001d38 <myproc>
    800053fe:	fdc42703          	lw	a4,-36(s0)
    80005402:	01a70793          	addi	a5,a4,26
    80005406:	078e                	slli	a5,a5,0x3
    80005408:	953e                	add	a0,a0,a5
    8000540a:	651c                	ld	a5,8(a0)
    8000540c:	c395                	beqz	a5,80005430 <argfd+0x64>
    return -1;
  if(pfd)
    8000540e:	00090463          	beqz	s2,80005416 <argfd+0x4a>
    *pfd = fd;
    80005412:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005416:	4501                	li	a0,0
  if(pf)
    80005418:	c091                	beqz	s1,8000541c <argfd+0x50>
    *pf = f;
    8000541a:	e09c                	sd	a5,0(s1)
}
    8000541c:	70a2                	ld	ra,40(sp)
    8000541e:	7402                	ld	s0,32(sp)
    80005420:	64e2                	ld	s1,24(sp)
    80005422:	6942                	ld	s2,16(sp)
    80005424:	6145                	addi	sp,sp,48
    80005426:	8082                	ret
    return -1;
    80005428:	557d                	li	a0,-1
    8000542a:	bfcd                	j	8000541c <argfd+0x50>
    return -1;
    8000542c:	557d                	li	a0,-1
    8000542e:	b7fd                	j	8000541c <argfd+0x50>
    80005430:	557d                	li	a0,-1
    80005432:	b7ed                	j	8000541c <argfd+0x50>

0000000080005434 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005434:	1101                	addi	sp,sp,-32
    80005436:	ec06                	sd	ra,24(sp)
    80005438:	e822                	sd	s0,16(sp)
    8000543a:	e426                	sd	s1,8(sp)
    8000543c:	1000                	addi	s0,sp,32
    8000543e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005440:	ffffd097          	auipc	ra,0xffffd
    80005444:	8f8080e7          	jalr	-1800(ra) # 80001d38 <myproc>
    80005448:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000544a:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffd30b0>
    8000544e:	4501                	li	a0,0
    80005450:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005452:	6398                	ld	a4,0(a5)
    80005454:	cb19                	beqz	a4,8000546a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005456:	2505                	addiw	a0,a0,1
    80005458:	07a1                	addi	a5,a5,8
    8000545a:	fed51ce3          	bne	a0,a3,80005452 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000545e:	557d                	li	a0,-1
}
    80005460:	60e2                	ld	ra,24(sp)
    80005462:	6442                	ld	s0,16(sp)
    80005464:	64a2                	ld	s1,8(sp)
    80005466:	6105                	addi	sp,sp,32
    80005468:	8082                	ret
      p->ofile[fd] = f;
    8000546a:	01a50793          	addi	a5,a0,26
    8000546e:	078e                	slli	a5,a5,0x3
    80005470:	963e                	add	a2,a2,a5
    80005472:	e604                	sd	s1,8(a2)
      return fd;
    80005474:	b7f5                	j	80005460 <fdalloc+0x2c>

0000000080005476 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005476:	715d                	addi	sp,sp,-80
    80005478:	e486                	sd	ra,72(sp)
    8000547a:	e0a2                	sd	s0,64(sp)
    8000547c:	fc26                	sd	s1,56(sp)
    8000547e:	f84a                	sd	s2,48(sp)
    80005480:	f44e                	sd	s3,40(sp)
    80005482:	f052                	sd	s4,32(sp)
    80005484:	ec56                	sd	s5,24(sp)
    80005486:	0880                	addi	s0,sp,80
    80005488:	89ae                	mv	s3,a1
    8000548a:	8ab2                	mv	s5,a2
    8000548c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000548e:	fb040593          	addi	a1,s0,-80
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	e24080e7          	jalr	-476(ra) # 800042b6 <nameiparent>
    8000549a:	892a                	mv	s2,a0
    8000549c:	12050f63          	beqz	a0,800055da <create+0x164>
    return 0;

  ilock(dp);
    800054a0:	ffffe097          	auipc	ra,0xffffe
    800054a4:	644080e7          	jalr	1604(ra) # 80003ae4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800054a8:	4601                	li	a2,0
    800054aa:	fb040593          	addi	a1,s0,-80
    800054ae:	854a                	mv	a0,s2
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	b16080e7          	jalr	-1258(ra) # 80003fc6 <dirlookup>
    800054b8:	84aa                	mv	s1,a0
    800054ba:	c921                	beqz	a0,8000550a <create+0x94>
    iunlockput(dp);
    800054bc:	854a                	mv	a0,s2
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	888080e7          	jalr	-1912(ra) # 80003d46 <iunlockput>
    ilock(ip);
    800054c6:	8526                	mv	a0,s1
    800054c8:	ffffe097          	auipc	ra,0xffffe
    800054cc:	61c080e7          	jalr	1564(ra) # 80003ae4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800054d0:	2981                	sext.w	s3,s3
    800054d2:	4789                	li	a5,2
    800054d4:	02f99463          	bne	s3,a5,800054fc <create+0x86>
    800054d8:	04c4d783          	lhu	a5,76(s1)
    800054dc:	37f9                	addiw	a5,a5,-2
    800054de:	17c2                	slli	a5,a5,0x30
    800054e0:	93c1                	srli	a5,a5,0x30
    800054e2:	4705                	li	a4,1
    800054e4:	00f76c63          	bltu	a4,a5,800054fc <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800054e8:	8526                	mv	a0,s1
    800054ea:	60a6                	ld	ra,72(sp)
    800054ec:	6406                	ld	s0,64(sp)
    800054ee:	74e2                	ld	s1,56(sp)
    800054f0:	7942                	ld	s2,48(sp)
    800054f2:	79a2                	ld	s3,40(sp)
    800054f4:	7a02                	ld	s4,32(sp)
    800054f6:	6ae2                	ld	s5,24(sp)
    800054f8:	6161                	addi	sp,sp,80
    800054fa:	8082                	ret
    iunlockput(ip);
    800054fc:	8526                	mv	a0,s1
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	848080e7          	jalr	-1976(ra) # 80003d46 <iunlockput>
    return 0;
    80005506:	4481                	li	s1,0
    80005508:	b7c5                	j	800054e8 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000550a:	85ce                	mv	a1,s3
    8000550c:	00092503          	lw	a0,0(s2)
    80005510:	ffffe097          	auipc	ra,0xffffe
    80005514:	43c080e7          	jalr	1084(ra) # 8000394c <ialloc>
    80005518:	84aa                	mv	s1,a0
    8000551a:	c529                	beqz	a0,80005564 <create+0xee>
  ilock(ip);
    8000551c:	ffffe097          	auipc	ra,0xffffe
    80005520:	5c8080e7          	jalr	1480(ra) # 80003ae4 <ilock>
  ip->major = major;
    80005524:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80005528:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    8000552c:	4785                	li	a5,1
    8000552e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005532:	8526                	mv	a0,s1
    80005534:	ffffe097          	auipc	ra,0xffffe
    80005538:	4e6080e7          	jalr	1254(ra) # 80003a1a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000553c:	2981                	sext.w	s3,s3
    8000553e:	4785                	li	a5,1
    80005540:	02f98a63          	beq	s3,a5,80005574 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005544:	40d0                	lw	a2,4(s1)
    80005546:	fb040593          	addi	a1,s0,-80
    8000554a:	854a                	mv	a0,s2
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	c8a080e7          	jalr	-886(ra) # 800041d6 <dirlink>
    80005554:	06054b63          	bltz	a0,800055ca <create+0x154>
  iunlockput(dp);
    80005558:	854a                	mv	a0,s2
    8000555a:	ffffe097          	auipc	ra,0xffffe
    8000555e:	7ec080e7          	jalr	2028(ra) # 80003d46 <iunlockput>
  return ip;
    80005562:	b759                	j	800054e8 <create+0x72>
    panic("create: ialloc");
    80005564:	00003517          	auipc	a0,0x3
    80005568:	1f450513          	addi	a0,a0,500 # 80008758 <syscalls+0x2a0>
    8000556c:	ffffb097          	auipc	ra,0xffffb
    80005570:	fe4080e7          	jalr	-28(ra) # 80000550 <panic>
    dp->nlink++;  // for ".."
    80005574:	05295783          	lhu	a5,82(s2)
    80005578:	2785                	addiw	a5,a5,1
    8000557a:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    8000557e:	854a                	mv	a0,s2
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	49a080e7          	jalr	1178(ra) # 80003a1a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005588:	40d0                	lw	a2,4(s1)
    8000558a:	00003597          	auipc	a1,0x3
    8000558e:	1de58593          	addi	a1,a1,478 # 80008768 <syscalls+0x2b0>
    80005592:	8526                	mv	a0,s1
    80005594:	fffff097          	auipc	ra,0xfffff
    80005598:	c42080e7          	jalr	-958(ra) # 800041d6 <dirlink>
    8000559c:	00054f63          	bltz	a0,800055ba <create+0x144>
    800055a0:	00492603          	lw	a2,4(s2)
    800055a4:	00003597          	auipc	a1,0x3
    800055a8:	1cc58593          	addi	a1,a1,460 # 80008770 <syscalls+0x2b8>
    800055ac:	8526                	mv	a0,s1
    800055ae:	fffff097          	auipc	ra,0xfffff
    800055b2:	c28080e7          	jalr	-984(ra) # 800041d6 <dirlink>
    800055b6:	f80557e3          	bgez	a0,80005544 <create+0xce>
      panic("create dots");
    800055ba:	00003517          	auipc	a0,0x3
    800055be:	1be50513          	addi	a0,a0,446 # 80008778 <syscalls+0x2c0>
    800055c2:	ffffb097          	auipc	ra,0xffffb
    800055c6:	f8e080e7          	jalr	-114(ra) # 80000550 <panic>
    panic("create: dirlink");
    800055ca:	00003517          	auipc	a0,0x3
    800055ce:	1be50513          	addi	a0,a0,446 # 80008788 <syscalls+0x2d0>
    800055d2:	ffffb097          	auipc	ra,0xffffb
    800055d6:	f7e080e7          	jalr	-130(ra) # 80000550 <panic>
    return 0;
    800055da:	84aa                	mv	s1,a0
    800055dc:	b731                	j	800054e8 <create+0x72>

00000000800055de <sys_dup>:
{
    800055de:	7179                	addi	sp,sp,-48
    800055e0:	f406                	sd	ra,40(sp)
    800055e2:	f022                	sd	s0,32(sp)
    800055e4:	ec26                	sd	s1,24(sp)
    800055e6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800055e8:	fd840613          	addi	a2,s0,-40
    800055ec:	4581                	li	a1,0
    800055ee:	4501                	li	a0,0
    800055f0:	00000097          	auipc	ra,0x0
    800055f4:	ddc080e7          	jalr	-548(ra) # 800053cc <argfd>
    return -1;
    800055f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055fa:	02054363          	bltz	a0,80005620 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800055fe:	fd843503          	ld	a0,-40(s0)
    80005602:	00000097          	auipc	ra,0x0
    80005606:	e32080e7          	jalr	-462(ra) # 80005434 <fdalloc>
    8000560a:	84aa                	mv	s1,a0
    return -1;
    8000560c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000560e:	00054963          	bltz	a0,80005620 <sys_dup+0x42>
  filedup(f);
    80005612:	fd843503          	ld	a0,-40(s0)
    80005616:	fffff097          	auipc	ra,0xfffff
    8000561a:	320080e7          	jalr	800(ra) # 80004936 <filedup>
  return fd;
    8000561e:	87a6                	mv	a5,s1
}
    80005620:	853e                	mv	a0,a5
    80005622:	70a2                	ld	ra,40(sp)
    80005624:	7402                	ld	s0,32(sp)
    80005626:	64e2                	ld	s1,24(sp)
    80005628:	6145                	addi	sp,sp,48
    8000562a:	8082                	ret

000000008000562c <sys_read>:
{
    8000562c:	7179                	addi	sp,sp,-48
    8000562e:	f406                	sd	ra,40(sp)
    80005630:	f022                	sd	s0,32(sp)
    80005632:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005634:	fe840613          	addi	a2,s0,-24
    80005638:	4581                	li	a1,0
    8000563a:	4501                	li	a0,0
    8000563c:	00000097          	auipc	ra,0x0
    80005640:	d90080e7          	jalr	-624(ra) # 800053cc <argfd>
    return -1;
    80005644:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005646:	04054163          	bltz	a0,80005688 <sys_read+0x5c>
    8000564a:	fe440593          	addi	a1,s0,-28
    8000564e:	4509                	li	a0,2
    80005650:	ffffd097          	auipc	ra,0xffffd
    80005654:	7a6080e7          	jalr	1958(ra) # 80002df6 <argint>
    return -1;
    80005658:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000565a:	02054763          	bltz	a0,80005688 <sys_read+0x5c>
    8000565e:	fd840593          	addi	a1,s0,-40
    80005662:	4505                	li	a0,1
    80005664:	ffffd097          	auipc	ra,0xffffd
    80005668:	7b4080e7          	jalr	1972(ra) # 80002e18 <argaddr>
    return -1;
    8000566c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000566e:	00054d63          	bltz	a0,80005688 <sys_read+0x5c>
  return fileread(f, p, n);
    80005672:	fe442603          	lw	a2,-28(s0)
    80005676:	fd843583          	ld	a1,-40(s0)
    8000567a:	fe843503          	ld	a0,-24(s0)
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	444080e7          	jalr	1092(ra) # 80004ac2 <fileread>
    80005686:	87aa                	mv	a5,a0
}
    80005688:	853e                	mv	a0,a5
    8000568a:	70a2                	ld	ra,40(sp)
    8000568c:	7402                	ld	s0,32(sp)
    8000568e:	6145                	addi	sp,sp,48
    80005690:	8082                	ret

0000000080005692 <sys_write>:
{
    80005692:	7179                	addi	sp,sp,-48
    80005694:	f406                	sd	ra,40(sp)
    80005696:	f022                	sd	s0,32(sp)
    80005698:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000569a:	fe840613          	addi	a2,s0,-24
    8000569e:	4581                	li	a1,0
    800056a0:	4501                	li	a0,0
    800056a2:	00000097          	auipc	ra,0x0
    800056a6:	d2a080e7          	jalr	-726(ra) # 800053cc <argfd>
    return -1;
    800056aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056ac:	04054163          	bltz	a0,800056ee <sys_write+0x5c>
    800056b0:	fe440593          	addi	a1,s0,-28
    800056b4:	4509                	li	a0,2
    800056b6:	ffffd097          	auipc	ra,0xffffd
    800056ba:	740080e7          	jalr	1856(ra) # 80002df6 <argint>
    return -1;
    800056be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056c0:	02054763          	bltz	a0,800056ee <sys_write+0x5c>
    800056c4:	fd840593          	addi	a1,s0,-40
    800056c8:	4505                	li	a0,1
    800056ca:	ffffd097          	auipc	ra,0xffffd
    800056ce:	74e080e7          	jalr	1870(ra) # 80002e18 <argaddr>
    return -1;
    800056d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056d4:	00054d63          	bltz	a0,800056ee <sys_write+0x5c>
  return filewrite(f, p, n);
    800056d8:	fe442603          	lw	a2,-28(s0)
    800056dc:	fd843583          	ld	a1,-40(s0)
    800056e0:	fe843503          	ld	a0,-24(s0)
    800056e4:	fffff097          	auipc	ra,0xfffff
    800056e8:	4a0080e7          	jalr	1184(ra) # 80004b84 <filewrite>
    800056ec:	87aa                	mv	a5,a0
}
    800056ee:	853e                	mv	a0,a5
    800056f0:	70a2                	ld	ra,40(sp)
    800056f2:	7402                	ld	s0,32(sp)
    800056f4:	6145                	addi	sp,sp,48
    800056f6:	8082                	ret

00000000800056f8 <sys_close>:
{
    800056f8:	1101                	addi	sp,sp,-32
    800056fa:	ec06                	sd	ra,24(sp)
    800056fc:	e822                	sd	s0,16(sp)
    800056fe:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005700:	fe040613          	addi	a2,s0,-32
    80005704:	fec40593          	addi	a1,s0,-20
    80005708:	4501                	li	a0,0
    8000570a:	00000097          	auipc	ra,0x0
    8000570e:	cc2080e7          	jalr	-830(ra) # 800053cc <argfd>
    return -1;
    80005712:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005714:	02054463          	bltz	a0,8000573c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005718:	ffffc097          	auipc	ra,0xffffc
    8000571c:	620080e7          	jalr	1568(ra) # 80001d38 <myproc>
    80005720:	fec42783          	lw	a5,-20(s0)
    80005724:	07e9                	addi	a5,a5,26
    80005726:	078e                	slli	a5,a5,0x3
    80005728:	97aa                	add	a5,a5,a0
    8000572a:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000572e:	fe043503          	ld	a0,-32(s0)
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	256080e7          	jalr	598(ra) # 80004988 <fileclose>
  return 0;
    8000573a:	4781                	li	a5,0
}
    8000573c:	853e                	mv	a0,a5
    8000573e:	60e2                	ld	ra,24(sp)
    80005740:	6442                	ld	s0,16(sp)
    80005742:	6105                	addi	sp,sp,32
    80005744:	8082                	ret

0000000080005746 <sys_fstat>:
{
    80005746:	1101                	addi	sp,sp,-32
    80005748:	ec06                	sd	ra,24(sp)
    8000574a:	e822                	sd	s0,16(sp)
    8000574c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000574e:	fe840613          	addi	a2,s0,-24
    80005752:	4581                	li	a1,0
    80005754:	4501                	li	a0,0
    80005756:	00000097          	auipc	ra,0x0
    8000575a:	c76080e7          	jalr	-906(ra) # 800053cc <argfd>
    return -1;
    8000575e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005760:	02054563          	bltz	a0,8000578a <sys_fstat+0x44>
    80005764:	fe040593          	addi	a1,s0,-32
    80005768:	4505                	li	a0,1
    8000576a:	ffffd097          	auipc	ra,0xffffd
    8000576e:	6ae080e7          	jalr	1710(ra) # 80002e18 <argaddr>
    return -1;
    80005772:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005774:	00054b63          	bltz	a0,8000578a <sys_fstat+0x44>
  return filestat(f, st);
    80005778:	fe043583          	ld	a1,-32(s0)
    8000577c:	fe843503          	ld	a0,-24(s0)
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	2d0080e7          	jalr	720(ra) # 80004a50 <filestat>
    80005788:	87aa                	mv	a5,a0
}
    8000578a:	853e                	mv	a0,a5
    8000578c:	60e2                	ld	ra,24(sp)
    8000578e:	6442                	ld	s0,16(sp)
    80005790:	6105                	addi	sp,sp,32
    80005792:	8082                	ret

0000000080005794 <sys_link>:
{
    80005794:	7169                	addi	sp,sp,-304
    80005796:	f606                	sd	ra,296(sp)
    80005798:	f222                	sd	s0,288(sp)
    8000579a:	ee26                	sd	s1,280(sp)
    8000579c:	ea4a                	sd	s2,272(sp)
    8000579e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057a0:	08000613          	li	a2,128
    800057a4:	ed040593          	addi	a1,s0,-304
    800057a8:	4501                	li	a0,0
    800057aa:	ffffd097          	auipc	ra,0xffffd
    800057ae:	690080e7          	jalr	1680(ra) # 80002e3a <argstr>
    return -1;
    800057b2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057b4:	10054e63          	bltz	a0,800058d0 <sys_link+0x13c>
    800057b8:	08000613          	li	a2,128
    800057bc:	f5040593          	addi	a1,s0,-176
    800057c0:	4505                	li	a0,1
    800057c2:	ffffd097          	auipc	ra,0xffffd
    800057c6:	678080e7          	jalr	1656(ra) # 80002e3a <argstr>
    return -1;
    800057ca:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057cc:	10054263          	bltz	a0,800058d0 <sys_link+0x13c>
  begin_op();
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	ce4080e7          	jalr	-796(ra) # 800044b4 <begin_op>
  if((ip = namei(old)) == 0){
    800057d8:	ed040513          	addi	a0,s0,-304
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	abc080e7          	jalr	-1348(ra) # 80004298 <namei>
    800057e4:	84aa                	mv	s1,a0
    800057e6:	c551                	beqz	a0,80005872 <sys_link+0xde>
  ilock(ip);
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	2fc080e7          	jalr	764(ra) # 80003ae4 <ilock>
  if(ip->type == T_DIR){
    800057f0:	04c49703          	lh	a4,76(s1)
    800057f4:	4785                	li	a5,1
    800057f6:	08f70463          	beq	a4,a5,8000587e <sys_link+0xea>
  ip->nlink++;
    800057fa:	0524d783          	lhu	a5,82(s1)
    800057fe:	2785                	addiw	a5,a5,1
    80005800:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005804:	8526                	mv	a0,s1
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	214080e7          	jalr	532(ra) # 80003a1a <iupdate>
  iunlock(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	396080e7          	jalr	918(ra) # 80003ba6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005818:	fd040593          	addi	a1,s0,-48
    8000581c:	f5040513          	addi	a0,s0,-176
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	a96080e7          	jalr	-1386(ra) # 800042b6 <nameiparent>
    80005828:	892a                	mv	s2,a0
    8000582a:	c935                	beqz	a0,8000589e <sys_link+0x10a>
  ilock(dp);
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	2b8080e7          	jalr	696(ra) # 80003ae4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005834:	00092703          	lw	a4,0(s2)
    80005838:	409c                	lw	a5,0(s1)
    8000583a:	04f71d63          	bne	a4,a5,80005894 <sys_link+0x100>
    8000583e:	40d0                	lw	a2,4(s1)
    80005840:	fd040593          	addi	a1,s0,-48
    80005844:	854a                	mv	a0,s2
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	990080e7          	jalr	-1648(ra) # 800041d6 <dirlink>
    8000584e:	04054363          	bltz	a0,80005894 <sys_link+0x100>
  iunlockput(dp);
    80005852:	854a                	mv	a0,s2
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	4f2080e7          	jalr	1266(ra) # 80003d46 <iunlockput>
  iput(ip);
    8000585c:	8526                	mv	a0,s1
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	440080e7          	jalr	1088(ra) # 80003c9e <iput>
  end_op();
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	cce080e7          	jalr	-818(ra) # 80004534 <end_op>
  return 0;
    8000586e:	4781                	li	a5,0
    80005870:	a085                	j	800058d0 <sys_link+0x13c>
    end_op();
    80005872:	fffff097          	auipc	ra,0xfffff
    80005876:	cc2080e7          	jalr	-830(ra) # 80004534 <end_op>
    return -1;
    8000587a:	57fd                	li	a5,-1
    8000587c:	a891                	j	800058d0 <sys_link+0x13c>
    iunlockput(ip);
    8000587e:	8526                	mv	a0,s1
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	4c6080e7          	jalr	1222(ra) # 80003d46 <iunlockput>
    end_op();
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	cac080e7          	jalr	-852(ra) # 80004534 <end_op>
    return -1;
    80005890:	57fd                	li	a5,-1
    80005892:	a83d                	j	800058d0 <sys_link+0x13c>
    iunlockput(dp);
    80005894:	854a                	mv	a0,s2
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	4b0080e7          	jalr	1200(ra) # 80003d46 <iunlockput>
  ilock(ip);
    8000589e:	8526                	mv	a0,s1
    800058a0:	ffffe097          	auipc	ra,0xffffe
    800058a4:	244080e7          	jalr	580(ra) # 80003ae4 <ilock>
  ip->nlink--;
    800058a8:	0524d783          	lhu	a5,82(s1)
    800058ac:	37fd                	addiw	a5,a5,-1
    800058ae:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800058b2:	8526                	mv	a0,s1
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	166080e7          	jalr	358(ra) # 80003a1a <iupdate>
  iunlockput(ip);
    800058bc:	8526                	mv	a0,s1
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	488080e7          	jalr	1160(ra) # 80003d46 <iunlockput>
  end_op();
    800058c6:	fffff097          	auipc	ra,0xfffff
    800058ca:	c6e080e7          	jalr	-914(ra) # 80004534 <end_op>
  return -1;
    800058ce:	57fd                	li	a5,-1
}
    800058d0:	853e                	mv	a0,a5
    800058d2:	70b2                	ld	ra,296(sp)
    800058d4:	7412                	ld	s0,288(sp)
    800058d6:	64f2                	ld	s1,280(sp)
    800058d8:	6952                	ld	s2,272(sp)
    800058da:	6155                	addi	sp,sp,304
    800058dc:	8082                	ret

00000000800058de <sys_unlink>:
{
    800058de:	7151                	addi	sp,sp,-240
    800058e0:	f586                	sd	ra,232(sp)
    800058e2:	f1a2                	sd	s0,224(sp)
    800058e4:	eda6                	sd	s1,216(sp)
    800058e6:	e9ca                	sd	s2,208(sp)
    800058e8:	e5ce                	sd	s3,200(sp)
    800058ea:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058ec:	08000613          	li	a2,128
    800058f0:	f3040593          	addi	a1,s0,-208
    800058f4:	4501                	li	a0,0
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	544080e7          	jalr	1348(ra) # 80002e3a <argstr>
    800058fe:	18054163          	bltz	a0,80005a80 <sys_unlink+0x1a2>
  begin_op();
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	bb2080e7          	jalr	-1102(ra) # 800044b4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000590a:	fb040593          	addi	a1,s0,-80
    8000590e:	f3040513          	addi	a0,s0,-208
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	9a4080e7          	jalr	-1628(ra) # 800042b6 <nameiparent>
    8000591a:	84aa                	mv	s1,a0
    8000591c:	c979                	beqz	a0,800059f2 <sys_unlink+0x114>
  ilock(dp);
    8000591e:	ffffe097          	auipc	ra,0xffffe
    80005922:	1c6080e7          	jalr	454(ra) # 80003ae4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005926:	00003597          	auipc	a1,0x3
    8000592a:	e4258593          	addi	a1,a1,-446 # 80008768 <syscalls+0x2b0>
    8000592e:	fb040513          	addi	a0,s0,-80
    80005932:	ffffe097          	auipc	ra,0xffffe
    80005936:	67a080e7          	jalr	1658(ra) # 80003fac <namecmp>
    8000593a:	14050a63          	beqz	a0,80005a8e <sys_unlink+0x1b0>
    8000593e:	00003597          	auipc	a1,0x3
    80005942:	e3258593          	addi	a1,a1,-462 # 80008770 <syscalls+0x2b8>
    80005946:	fb040513          	addi	a0,s0,-80
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	662080e7          	jalr	1634(ra) # 80003fac <namecmp>
    80005952:	12050e63          	beqz	a0,80005a8e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005956:	f2c40613          	addi	a2,s0,-212
    8000595a:	fb040593          	addi	a1,s0,-80
    8000595e:	8526                	mv	a0,s1
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	666080e7          	jalr	1638(ra) # 80003fc6 <dirlookup>
    80005968:	892a                	mv	s2,a0
    8000596a:	12050263          	beqz	a0,80005a8e <sys_unlink+0x1b0>
  ilock(ip);
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	176080e7          	jalr	374(ra) # 80003ae4 <ilock>
  if(ip->nlink < 1)
    80005976:	05291783          	lh	a5,82(s2)
    8000597a:	08f05263          	blez	a5,800059fe <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000597e:	04c91703          	lh	a4,76(s2)
    80005982:	4785                	li	a5,1
    80005984:	08f70563          	beq	a4,a5,80005a0e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005988:	4641                	li	a2,16
    8000598a:	4581                	li	a1,0
    8000598c:	fc040513          	addi	a0,s0,-64
    80005990:	ffffb097          	auipc	ra,0xffffb
    80005994:	740080e7          	jalr	1856(ra) # 800010d0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005998:	4741                	li	a4,16
    8000599a:	f2c42683          	lw	a3,-212(s0)
    8000599e:	fc040613          	addi	a2,s0,-64
    800059a2:	4581                	li	a1,0
    800059a4:	8526                	mv	a0,s1
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	4ea080e7          	jalr	1258(ra) # 80003e90 <writei>
    800059ae:	47c1                	li	a5,16
    800059b0:	0af51563          	bne	a0,a5,80005a5a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800059b4:	04c91703          	lh	a4,76(s2)
    800059b8:	4785                	li	a5,1
    800059ba:	0af70863          	beq	a4,a5,80005a6a <sys_unlink+0x18c>
  iunlockput(dp);
    800059be:	8526                	mv	a0,s1
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	386080e7          	jalr	902(ra) # 80003d46 <iunlockput>
  ip->nlink--;
    800059c8:	05295783          	lhu	a5,82(s2)
    800059cc:	37fd                	addiw	a5,a5,-1
    800059ce:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800059d2:	854a                	mv	a0,s2
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	046080e7          	jalr	70(ra) # 80003a1a <iupdate>
  iunlockput(ip);
    800059dc:	854a                	mv	a0,s2
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	368080e7          	jalr	872(ra) # 80003d46 <iunlockput>
  end_op();
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	b4e080e7          	jalr	-1202(ra) # 80004534 <end_op>
  return 0;
    800059ee:	4501                	li	a0,0
    800059f0:	a84d                	j	80005aa2 <sys_unlink+0x1c4>
    end_op();
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	b42080e7          	jalr	-1214(ra) # 80004534 <end_op>
    return -1;
    800059fa:	557d                	li	a0,-1
    800059fc:	a05d                	j	80005aa2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800059fe:	00003517          	auipc	a0,0x3
    80005a02:	d9a50513          	addi	a0,a0,-614 # 80008798 <syscalls+0x2e0>
    80005a06:	ffffb097          	auipc	ra,0xffffb
    80005a0a:	b4a080e7          	jalr	-1206(ra) # 80000550 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a0e:	05492703          	lw	a4,84(s2)
    80005a12:	02000793          	li	a5,32
    80005a16:	f6e7f9e3          	bgeu	a5,a4,80005988 <sys_unlink+0xaa>
    80005a1a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a1e:	4741                	li	a4,16
    80005a20:	86ce                	mv	a3,s3
    80005a22:	f1840613          	addi	a2,s0,-232
    80005a26:	4581                	li	a1,0
    80005a28:	854a                	mv	a0,s2
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	36e080e7          	jalr	878(ra) # 80003d98 <readi>
    80005a32:	47c1                	li	a5,16
    80005a34:	00f51b63          	bne	a0,a5,80005a4a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a38:	f1845783          	lhu	a5,-232(s0)
    80005a3c:	e7a1                	bnez	a5,80005a84 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a3e:	29c1                	addiw	s3,s3,16
    80005a40:	05492783          	lw	a5,84(s2)
    80005a44:	fcf9ede3          	bltu	s3,a5,80005a1e <sys_unlink+0x140>
    80005a48:	b781                	j	80005988 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a4a:	00003517          	auipc	a0,0x3
    80005a4e:	d6650513          	addi	a0,a0,-666 # 800087b0 <syscalls+0x2f8>
    80005a52:	ffffb097          	auipc	ra,0xffffb
    80005a56:	afe080e7          	jalr	-1282(ra) # 80000550 <panic>
    panic("unlink: writei");
    80005a5a:	00003517          	auipc	a0,0x3
    80005a5e:	d6e50513          	addi	a0,a0,-658 # 800087c8 <syscalls+0x310>
    80005a62:	ffffb097          	auipc	ra,0xffffb
    80005a66:	aee080e7          	jalr	-1298(ra) # 80000550 <panic>
    dp->nlink--;
    80005a6a:	0524d783          	lhu	a5,82(s1)
    80005a6e:	37fd                	addiw	a5,a5,-1
    80005a70:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005a74:	8526                	mv	a0,s1
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	fa4080e7          	jalr	-92(ra) # 80003a1a <iupdate>
    80005a7e:	b781                	j	800059be <sys_unlink+0xe0>
    return -1;
    80005a80:	557d                	li	a0,-1
    80005a82:	a005                	j	80005aa2 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a84:	854a                	mv	a0,s2
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	2c0080e7          	jalr	704(ra) # 80003d46 <iunlockput>
  iunlockput(dp);
    80005a8e:	8526                	mv	a0,s1
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	2b6080e7          	jalr	694(ra) # 80003d46 <iunlockput>
  end_op();
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	a9c080e7          	jalr	-1380(ra) # 80004534 <end_op>
  return -1;
    80005aa0:	557d                	li	a0,-1
}
    80005aa2:	70ae                	ld	ra,232(sp)
    80005aa4:	740e                	ld	s0,224(sp)
    80005aa6:	64ee                	ld	s1,216(sp)
    80005aa8:	694e                	ld	s2,208(sp)
    80005aaa:	69ae                	ld	s3,200(sp)
    80005aac:	616d                	addi	sp,sp,240
    80005aae:	8082                	ret

0000000080005ab0 <sys_open>:

uint64
sys_open(void)
{
    80005ab0:	7131                	addi	sp,sp,-192
    80005ab2:	fd06                	sd	ra,184(sp)
    80005ab4:	f922                	sd	s0,176(sp)
    80005ab6:	f526                	sd	s1,168(sp)
    80005ab8:	f14a                	sd	s2,160(sp)
    80005aba:	ed4e                	sd	s3,152(sp)
    80005abc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005abe:	08000613          	li	a2,128
    80005ac2:	f5040593          	addi	a1,s0,-176
    80005ac6:	4501                	li	a0,0
    80005ac8:	ffffd097          	auipc	ra,0xffffd
    80005acc:	372080e7          	jalr	882(ra) # 80002e3a <argstr>
    return -1;
    80005ad0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ad2:	0c054163          	bltz	a0,80005b94 <sys_open+0xe4>
    80005ad6:	f4c40593          	addi	a1,s0,-180
    80005ada:	4505                	li	a0,1
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	31a080e7          	jalr	794(ra) # 80002df6 <argint>
    80005ae4:	0a054863          	bltz	a0,80005b94 <sys_open+0xe4>

  begin_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	9cc080e7          	jalr	-1588(ra) # 800044b4 <begin_op>

  if(omode & O_CREATE){
    80005af0:	f4c42783          	lw	a5,-180(s0)
    80005af4:	2007f793          	andi	a5,a5,512
    80005af8:	cbdd                	beqz	a5,80005bae <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005afa:	4681                	li	a3,0
    80005afc:	4601                	li	a2,0
    80005afe:	4589                	li	a1,2
    80005b00:	f5040513          	addi	a0,s0,-176
    80005b04:	00000097          	auipc	ra,0x0
    80005b08:	972080e7          	jalr	-1678(ra) # 80005476 <create>
    80005b0c:	892a                	mv	s2,a0
    if(ip == 0){
    80005b0e:	c959                	beqz	a0,80005ba4 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b10:	04c91703          	lh	a4,76(s2)
    80005b14:	478d                	li	a5,3
    80005b16:	00f71763          	bne	a4,a5,80005b24 <sys_open+0x74>
    80005b1a:	04e95703          	lhu	a4,78(s2)
    80005b1e:	47a5                	li	a5,9
    80005b20:	0ce7ec63          	bltu	a5,a4,80005bf8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b24:	fffff097          	auipc	ra,0xfffff
    80005b28:	da8080e7          	jalr	-600(ra) # 800048cc <filealloc>
    80005b2c:	89aa                	mv	s3,a0
    80005b2e:	10050263          	beqz	a0,80005c32 <sys_open+0x182>
    80005b32:	00000097          	auipc	ra,0x0
    80005b36:	902080e7          	jalr	-1790(ra) # 80005434 <fdalloc>
    80005b3a:	84aa                	mv	s1,a0
    80005b3c:	0e054663          	bltz	a0,80005c28 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b40:	04c91703          	lh	a4,76(s2)
    80005b44:	478d                	li	a5,3
    80005b46:	0cf70463          	beq	a4,a5,80005c0e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b4a:	4789                	li	a5,2
    80005b4c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b50:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b54:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b58:	f4c42783          	lw	a5,-180(s0)
    80005b5c:	0017c713          	xori	a4,a5,1
    80005b60:	8b05                	andi	a4,a4,1
    80005b62:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b66:	0037f713          	andi	a4,a5,3
    80005b6a:	00e03733          	snez	a4,a4
    80005b6e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b72:	4007f793          	andi	a5,a5,1024
    80005b76:	c791                	beqz	a5,80005b82 <sys_open+0xd2>
    80005b78:	04c91703          	lh	a4,76(s2)
    80005b7c:	4789                	li	a5,2
    80005b7e:	08f70f63          	beq	a4,a5,80005c1c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b82:	854a                	mv	a0,s2
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	022080e7          	jalr	34(ra) # 80003ba6 <iunlock>
  end_op();
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	9a8080e7          	jalr	-1624(ra) # 80004534 <end_op>

  return fd;
}
    80005b94:	8526                	mv	a0,s1
    80005b96:	70ea                	ld	ra,184(sp)
    80005b98:	744a                	ld	s0,176(sp)
    80005b9a:	74aa                	ld	s1,168(sp)
    80005b9c:	790a                	ld	s2,160(sp)
    80005b9e:	69ea                	ld	s3,152(sp)
    80005ba0:	6129                	addi	sp,sp,192
    80005ba2:	8082                	ret
      end_op();
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	990080e7          	jalr	-1648(ra) # 80004534 <end_op>
      return -1;
    80005bac:	b7e5                	j	80005b94 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005bae:	f5040513          	addi	a0,s0,-176
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	6e6080e7          	jalr	1766(ra) # 80004298 <namei>
    80005bba:	892a                	mv	s2,a0
    80005bbc:	c905                	beqz	a0,80005bec <sys_open+0x13c>
    ilock(ip);
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	f26080e7          	jalr	-218(ra) # 80003ae4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005bc6:	04c91703          	lh	a4,76(s2)
    80005bca:	4785                	li	a5,1
    80005bcc:	f4f712e3          	bne	a4,a5,80005b10 <sys_open+0x60>
    80005bd0:	f4c42783          	lw	a5,-180(s0)
    80005bd4:	dba1                	beqz	a5,80005b24 <sys_open+0x74>
      iunlockput(ip);
    80005bd6:	854a                	mv	a0,s2
    80005bd8:	ffffe097          	auipc	ra,0xffffe
    80005bdc:	16e080e7          	jalr	366(ra) # 80003d46 <iunlockput>
      end_op();
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	954080e7          	jalr	-1708(ra) # 80004534 <end_op>
      return -1;
    80005be8:	54fd                	li	s1,-1
    80005bea:	b76d                	j	80005b94 <sys_open+0xe4>
      end_op();
    80005bec:	fffff097          	auipc	ra,0xfffff
    80005bf0:	948080e7          	jalr	-1720(ra) # 80004534 <end_op>
      return -1;
    80005bf4:	54fd                	li	s1,-1
    80005bf6:	bf79                	j	80005b94 <sys_open+0xe4>
    iunlockput(ip);
    80005bf8:	854a                	mv	a0,s2
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	14c080e7          	jalr	332(ra) # 80003d46 <iunlockput>
    end_op();
    80005c02:	fffff097          	auipc	ra,0xfffff
    80005c06:	932080e7          	jalr	-1742(ra) # 80004534 <end_op>
    return -1;
    80005c0a:	54fd                	li	s1,-1
    80005c0c:	b761                	j	80005b94 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c0e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c12:	04e91783          	lh	a5,78(s2)
    80005c16:	02f99223          	sh	a5,36(s3)
    80005c1a:	bf2d                	j	80005b54 <sys_open+0xa4>
    itrunc(ip);
    80005c1c:	854a                	mv	a0,s2
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	fd4080e7          	jalr	-44(ra) # 80003bf2 <itrunc>
    80005c26:	bfb1                	j	80005b82 <sys_open+0xd2>
      fileclose(f);
    80005c28:	854e                	mv	a0,s3
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	d5e080e7          	jalr	-674(ra) # 80004988 <fileclose>
    iunlockput(ip);
    80005c32:	854a                	mv	a0,s2
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	112080e7          	jalr	274(ra) # 80003d46 <iunlockput>
    end_op();
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	8f8080e7          	jalr	-1800(ra) # 80004534 <end_op>
    return -1;
    80005c44:	54fd                	li	s1,-1
    80005c46:	b7b9                	j	80005b94 <sys_open+0xe4>

0000000080005c48 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c48:	7175                	addi	sp,sp,-144
    80005c4a:	e506                	sd	ra,136(sp)
    80005c4c:	e122                	sd	s0,128(sp)
    80005c4e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c50:	fffff097          	auipc	ra,0xfffff
    80005c54:	864080e7          	jalr	-1948(ra) # 800044b4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c58:	08000613          	li	a2,128
    80005c5c:	f7040593          	addi	a1,s0,-144
    80005c60:	4501                	li	a0,0
    80005c62:	ffffd097          	auipc	ra,0xffffd
    80005c66:	1d8080e7          	jalr	472(ra) # 80002e3a <argstr>
    80005c6a:	02054963          	bltz	a0,80005c9c <sys_mkdir+0x54>
    80005c6e:	4681                	li	a3,0
    80005c70:	4601                	li	a2,0
    80005c72:	4585                	li	a1,1
    80005c74:	f7040513          	addi	a0,s0,-144
    80005c78:	fffff097          	auipc	ra,0xfffff
    80005c7c:	7fe080e7          	jalr	2046(ra) # 80005476 <create>
    80005c80:	cd11                	beqz	a0,80005c9c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c82:	ffffe097          	auipc	ra,0xffffe
    80005c86:	0c4080e7          	jalr	196(ra) # 80003d46 <iunlockput>
  end_op();
    80005c8a:	fffff097          	auipc	ra,0xfffff
    80005c8e:	8aa080e7          	jalr	-1878(ra) # 80004534 <end_op>
  return 0;
    80005c92:	4501                	li	a0,0
}
    80005c94:	60aa                	ld	ra,136(sp)
    80005c96:	640a                	ld	s0,128(sp)
    80005c98:	6149                	addi	sp,sp,144
    80005c9a:	8082                	ret
    end_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	898080e7          	jalr	-1896(ra) # 80004534 <end_op>
    return -1;
    80005ca4:	557d                	li	a0,-1
    80005ca6:	b7fd                	j	80005c94 <sys_mkdir+0x4c>

0000000080005ca8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ca8:	7135                	addi	sp,sp,-160
    80005caa:	ed06                	sd	ra,152(sp)
    80005cac:	e922                	sd	s0,144(sp)
    80005cae:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cb0:	fffff097          	auipc	ra,0xfffff
    80005cb4:	804080e7          	jalr	-2044(ra) # 800044b4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cb8:	08000613          	li	a2,128
    80005cbc:	f7040593          	addi	a1,s0,-144
    80005cc0:	4501                	li	a0,0
    80005cc2:	ffffd097          	auipc	ra,0xffffd
    80005cc6:	178080e7          	jalr	376(ra) # 80002e3a <argstr>
    80005cca:	04054a63          	bltz	a0,80005d1e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005cce:	f6c40593          	addi	a1,s0,-148
    80005cd2:	4505                	li	a0,1
    80005cd4:	ffffd097          	auipc	ra,0xffffd
    80005cd8:	122080e7          	jalr	290(ra) # 80002df6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cdc:	04054163          	bltz	a0,80005d1e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ce0:	f6840593          	addi	a1,s0,-152
    80005ce4:	4509                	li	a0,2
    80005ce6:	ffffd097          	auipc	ra,0xffffd
    80005cea:	110080e7          	jalr	272(ra) # 80002df6 <argint>
     argint(1, &major) < 0 ||
    80005cee:	02054863          	bltz	a0,80005d1e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005cf2:	f6841683          	lh	a3,-152(s0)
    80005cf6:	f6c41603          	lh	a2,-148(s0)
    80005cfa:	458d                	li	a1,3
    80005cfc:	f7040513          	addi	a0,s0,-144
    80005d00:	fffff097          	auipc	ra,0xfffff
    80005d04:	776080e7          	jalr	1910(ra) # 80005476 <create>
     argint(2, &minor) < 0 ||
    80005d08:	c919                	beqz	a0,80005d1e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d0a:	ffffe097          	auipc	ra,0xffffe
    80005d0e:	03c080e7          	jalr	60(ra) # 80003d46 <iunlockput>
  end_op();
    80005d12:	fffff097          	auipc	ra,0xfffff
    80005d16:	822080e7          	jalr	-2014(ra) # 80004534 <end_op>
  return 0;
    80005d1a:	4501                	li	a0,0
    80005d1c:	a031                	j	80005d28 <sys_mknod+0x80>
    end_op();
    80005d1e:	fffff097          	auipc	ra,0xfffff
    80005d22:	816080e7          	jalr	-2026(ra) # 80004534 <end_op>
    return -1;
    80005d26:	557d                	li	a0,-1
}
    80005d28:	60ea                	ld	ra,152(sp)
    80005d2a:	644a                	ld	s0,144(sp)
    80005d2c:	610d                	addi	sp,sp,160
    80005d2e:	8082                	ret

0000000080005d30 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d30:	7135                	addi	sp,sp,-160
    80005d32:	ed06                	sd	ra,152(sp)
    80005d34:	e922                	sd	s0,144(sp)
    80005d36:	e526                	sd	s1,136(sp)
    80005d38:	e14a                	sd	s2,128(sp)
    80005d3a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d3c:	ffffc097          	auipc	ra,0xffffc
    80005d40:	ffc080e7          	jalr	-4(ra) # 80001d38 <myproc>
    80005d44:	892a                	mv	s2,a0
  
  begin_op();
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	76e080e7          	jalr	1902(ra) # 800044b4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d4e:	08000613          	li	a2,128
    80005d52:	f6040593          	addi	a1,s0,-160
    80005d56:	4501                	li	a0,0
    80005d58:	ffffd097          	auipc	ra,0xffffd
    80005d5c:	0e2080e7          	jalr	226(ra) # 80002e3a <argstr>
    80005d60:	04054b63          	bltz	a0,80005db6 <sys_chdir+0x86>
    80005d64:	f6040513          	addi	a0,s0,-160
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	530080e7          	jalr	1328(ra) # 80004298 <namei>
    80005d70:	84aa                	mv	s1,a0
    80005d72:	c131                	beqz	a0,80005db6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d74:	ffffe097          	auipc	ra,0xffffe
    80005d78:	d70080e7          	jalr	-656(ra) # 80003ae4 <ilock>
  if(ip->type != T_DIR){
    80005d7c:	04c49703          	lh	a4,76(s1)
    80005d80:	4785                	li	a5,1
    80005d82:	04f71063          	bne	a4,a5,80005dc2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d86:	8526                	mv	a0,s1
    80005d88:	ffffe097          	auipc	ra,0xffffe
    80005d8c:	e1e080e7          	jalr	-482(ra) # 80003ba6 <iunlock>
  iput(p->cwd);
    80005d90:	15893503          	ld	a0,344(s2)
    80005d94:	ffffe097          	auipc	ra,0xffffe
    80005d98:	f0a080e7          	jalr	-246(ra) # 80003c9e <iput>
  end_op();
    80005d9c:	ffffe097          	auipc	ra,0xffffe
    80005da0:	798080e7          	jalr	1944(ra) # 80004534 <end_op>
  p->cwd = ip;
    80005da4:	14993c23          	sd	s1,344(s2)
  return 0;
    80005da8:	4501                	li	a0,0
}
    80005daa:	60ea                	ld	ra,152(sp)
    80005dac:	644a                	ld	s0,144(sp)
    80005dae:	64aa                	ld	s1,136(sp)
    80005db0:	690a                	ld	s2,128(sp)
    80005db2:	610d                	addi	sp,sp,160
    80005db4:	8082                	ret
    end_op();
    80005db6:	ffffe097          	auipc	ra,0xffffe
    80005dba:	77e080e7          	jalr	1918(ra) # 80004534 <end_op>
    return -1;
    80005dbe:	557d                	li	a0,-1
    80005dc0:	b7ed                	j	80005daa <sys_chdir+0x7a>
    iunlockput(ip);
    80005dc2:	8526                	mv	a0,s1
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	f82080e7          	jalr	-126(ra) # 80003d46 <iunlockput>
    end_op();
    80005dcc:	ffffe097          	auipc	ra,0xffffe
    80005dd0:	768080e7          	jalr	1896(ra) # 80004534 <end_op>
    return -1;
    80005dd4:	557d                	li	a0,-1
    80005dd6:	bfd1                	j	80005daa <sys_chdir+0x7a>

0000000080005dd8 <sys_exec>:

uint64
sys_exec(void)
{
    80005dd8:	7145                	addi	sp,sp,-464
    80005dda:	e786                	sd	ra,456(sp)
    80005ddc:	e3a2                	sd	s0,448(sp)
    80005dde:	ff26                	sd	s1,440(sp)
    80005de0:	fb4a                	sd	s2,432(sp)
    80005de2:	f74e                	sd	s3,424(sp)
    80005de4:	f352                	sd	s4,416(sp)
    80005de6:	ef56                	sd	s5,408(sp)
    80005de8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005dea:	08000613          	li	a2,128
    80005dee:	f4040593          	addi	a1,s0,-192
    80005df2:	4501                	li	a0,0
    80005df4:	ffffd097          	auipc	ra,0xffffd
    80005df8:	046080e7          	jalr	70(ra) # 80002e3a <argstr>
    return -1;
    80005dfc:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005dfe:	0c054a63          	bltz	a0,80005ed2 <sys_exec+0xfa>
    80005e02:	e3840593          	addi	a1,s0,-456
    80005e06:	4505                	li	a0,1
    80005e08:	ffffd097          	auipc	ra,0xffffd
    80005e0c:	010080e7          	jalr	16(ra) # 80002e18 <argaddr>
    80005e10:	0c054163          	bltz	a0,80005ed2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005e14:	10000613          	li	a2,256
    80005e18:	4581                	li	a1,0
    80005e1a:	e4040513          	addi	a0,s0,-448
    80005e1e:	ffffb097          	auipc	ra,0xffffb
    80005e22:	2b2080e7          	jalr	690(ra) # 800010d0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e26:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e2a:	89a6                	mv	s3,s1
    80005e2c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e2e:	02000a13          	li	s4,32
    80005e32:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e36:	00391513          	slli	a0,s2,0x3
    80005e3a:	e3040593          	addi	a1,s0,-464
    80005e3e:	e3843783          	ld	a5,-456(s0)
    80005e42:	953e                	add	a0,a0,a5
    80005e44:	ffffd097          	auipc	ra,0xffffd
    80005e48:	f18080e7          	jalr	-232(ra) # 80002d5c <fetchaddr>
    80005e4c:	02054a63          	bltz	a0,80005e80 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005e50:	e3043783          	ld	a5,-464(s0)
    80005e54:	c3b9                	beqz	a5,80005e9a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e56:	ffffb097          	auipc	ra,0xffffb
    80005e5a:	d24080e7          	jalr	-732(ra) # 80000b7a <kalloc>
    80005e5e:	85aa                	mv	a1,a0
    80005e60:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e64:	cd11                	beqz	a0,80005e80 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e66:	6605                	lui	a2,0x1
    80005e68:	e3043503          	ld	a0,-464(s0)
    80005e6c:	ffffd097          	auipc	ra,0xffffd
    80005e70:	f42080e7          	jalr	-190(ra) # 80002dae <fetchstr>
    80005e74:	00054663          	bltz	a0,80005e80 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005e78:	0905                	addi	s2,s2,1
    80005e7a:	09a1                	addi	s3,s3,8
    80005e7c:	fb491be3          	bne	s2,s4,80005e32 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e80:	10048913          	addi	s2,s1,256
    80005e84:	6088                	ld	a0,0(s1)
    80005e86:	c529                	beqz	a0,80005ed0 <sys_exec+0xf8>
    kfree(argv[i]);
    80005e88:	ffffb097          	auipc	ra,0xffffb
    80005e8c:	ba4080e7          	jalr	-1116(ra) # 80000a2c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e90:	04a1                	addi	s1,s1,8
    80005e92:	ff2499e3          	bne	s1,s2,80005e84 <sys_exec+0xac>
  return -1;
    80005e96:	597d                	li	s2,-1
    80005e98:	a82d                	j	80005ed2 <sys_exec+0xfa>
      argv[i] = 0;
    80005e9a:	0a8e                	slli	s5,s5,0x3
    80005e9c:	fc040793          	addi	a5,s0,-64
    80005ea0:	9abe                	add	s5,s5,a5
    80005ea2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ea6:	e4040593          	addi	a1,s0,-448
    80005eaa:	f4040513          	addi	a0,s0,-192
    80005eae:	fffff097          	auipc	ra,0xfffff
    80005eb2:	194080e7          	jalr	404(ra) # 80005042 <exec>
    80005eb6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eb8:	10048993          	addi	s3,s1,256
    80005ebc:	6088                	ld	a0,0(s1)
    80005ebe:	c911                	beqz	a0,80005ed2 <sys_exec+0xfa>
    kfree(argv[i]);
    80005ec0:	ffffb097          	auipc	ra,0xffffb
    80005ec4:	b6c080e7          	jalr	-1172(ra) # 80000a2c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ec8:	04a1                	addi	s1,s1,8
    80005eca:	ff3499e3          	bne	s1,s3,80005ebc <sys_exec+0xe4>
    80005ece:	a011                	j	80005ed2 <sys_exec+0xfa>
  return -1;
    80005ed0:	597d                	li	s2,-1
}
    80005ed2:	854a                	mv	a0,s2
    80005ed4:	60be                	ld	ra,456(sp)
    80005ed6:	641e                	ld	s0,448(sp)
    80005ed8:	74fa                	ld	s1,440(sp)
    80005eda:	795a                	ld	s2,432(sp)
    80005edc:	79ba                	ld	s3,424(sp)
    80005ede:	7a1a                	ld	s4,416(sp)
    80005ee0:	6afa                	ld	s5,408(sp)
    80005ee2:	6179                	addi	sp,sp,464
    80005ee4:	8082                	ret

0000000080005ee6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ee6:	7139                	addi	sp,sp,-64
    80005ee8:	fc06                	sd	ra,56(sp)
    80005eea:	f822                	sd	s0,48(sp)
    80005eec:	f426                	sd	s1,40(sp)
    80005eee:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ef0:	ffffc097          	auipc	ra,0xffffc
    80005ef4:	e48080e7          	jalr	-440(ra) # 80001d38 <myproc>
    80005ef8:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005efa:	fd840593          	addi	a1,s0,-40
    80005efe:	4501                	li	a0,0
    80005f00:	ffffd097          	auipc	ra,0xffffd
    80005f04:	f18080e7          	jalr	-232(ra) # 80002e18 <argaddr>
    return -1;
    80005f08:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005f0a:	0e054063          	bltz	a0,80005fea <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005f0e:	fc840593          	addi	a1,s0,-56
    80005f12:	fd040513          	addi	a0,s0,-48
    80005f16:	fffff097          	auipc	ra,0xfffff
    80005f1a:	dc8080e7          	jalr	-568(ra) # 80004cde <pipealloc>
    return -1;
    80005f1e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f20:	0c054563          	bltz	a0,80005fea <sys_pipe+0x104>
  fd0 = -1;
    80005f24:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f28:	fd043503          	ld	a0,-48(s0)
    80005f2c:	fffff097          	auipc	ra,0xfffff
    80005f30:	508080e7          	jalr	1288(ra) # 80005434 <fdalloc>
    80005f34:	fca42223          	sw	a0,-60(s0)
    80005f38:	08054c63          	bltz	a0,80005fd0 <sys_pipe+0xea>
    80005f3c:	fc843503          	ld	a0,-56(s0)
    80005f40:	fffff097          	auipc	ra,0xfffff
    80005f44:	4f4080e7          	jalr	1268(ra) # 80005434 <fdalloc>
    80005f48:	fca42023          	sw	a0,-64(s0)
    80005f4c:	06054863          	bltz	a0,80005fbc <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f50:	4691                	li	a3,4
    80005f52:	fc440613          	addi	a2,s0,-60
    80005f56:	fd843583          	ld	a1,-40(s0)
    80005f5a:	6ca8                	ld	a0,88(s1)
    80005f5c:	ffffc097          	auipc	ra,0xffffc
    80005f60:	ad0080e7          	jalr	-1328(ra) # 80001a2c <copyout>
    80005f64:	02054063          	bltz	a0,80005f84 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f68:	4691                	li	a3,4
    80005f6a:	fc040613          	addi	a2,s0,-64
    80005f6e:	fd843583          	ld	a1,-40(s0)
    80005f72:	0591                	addi	a1,a1,4
    80005f74:	6ca8                	ld	a0,88(s1)
    80005f76:	ffffc097          	auipc	ra,0xffffc
    80005f7a:	ab6080e7          	jalr	-1354(ra) # 80001a2c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f7e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f80:	06055563          	bgez	a0,80005fea <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f84:	fc442783          	lw	a5,-60(s0)
    80005f88:	07e9                	addi	a5,a5,26
    80005f8a:	078e                	slli	a5,a5,0x3
    80005f8c:	97a6                	add	a5,a5,s1
    80005f8e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005f92:	fc042503          	lw	a0,-64(s0)
    80005f96:	0569                	addi	a0,a0,26
    80005f98:	050e                	slli	a0,a0,0x3
    80005f9a:	9526                	add	a0,a0,s1
    80005f9c:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005fa0:	fd043503          	ld	a0,-48(s0)
    80005fa4:	fffff097          	auipc	ra,0xfffff
    80005fa8:	9e4080e7          	jalr	-1564(ra) # 80004988 <fileclose>
    fileclose(wf);
    80005fac:	fc843503          	ld	a0,-56(s0)
    80005fb0:	fffff097          	auipc	ra,0xfffff
    80005fb4:	9d8080e7          	jalr	-1576(ra) # 80004988 <fileclose>
    return -1;
    80005fb8:	57fd                	li	a5,-1
    80005fba:	a805                	j	80005fea <sys_pipe+0x104>
    if(fd0 >= 0)
    80005fbc:	fc442783          	lw	a5,-60(s0)
    80005fc0:	0007c863          	bltz	a5,80005fd0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005fc4:	01a78513          	addi	a0,a5,26
    80005fc8:	050e                	slli	a0,a0,0x3
    80005fca:	9526                	add	a0,a0,s1
    80005fcc:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005fd0:	fd043503          	ld	a0,-48(s0)
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	9b4080e7          	jalr	-1612(ra) # 80004988 <fileclose>
    fileclose(wf);
    80005fdc:	fc843503          	ld	a0,-56(s0)
    80005fe0:	fffff097          	auipc	ra,0xfffff
    80005fe4:	9a8080e7          	jalr	-1624(ra) # 80004988 <fileclose>
    return -1;
    80005fe8:	57fd                	li	a5,-1
}
    80005fea:	853e                	mv	a0,a5
    80005fec:	70e2                	ld	ra,56(sp)
    80005fee:	7442                	ld	s0,48(sp)
    80005ff0:	74a2                	ld	s1,40(sp)
    80005ff2:	6121                	addi	sp,sp,64
    80005ff4:	8082                	ret
	...

0000000080006000 <kernelvec>:
    80006000:	7111                	addi	sp,sp,-256
    80006002:	e006                	sd	ra,0(sp)
    80006004:	e40a                	sd	sp,8(sp)
    80006006:	e80e                	sd	gp,16(sp)
    80006008:	ec12                	sd	tp,24(sp)
    8000600a:	f016                	sd	t0,32(sp)
    8000600c:	f41a                	sd	t1,40(sp)
    8000600e:	f81e                	sd	t2,48(sp)
    80006010:	fc22                	sd	s0,56(sp)
    80006012:	e0a6                	sd	s1,64(sp)
    80006014:	e4aa                	sd	a0,72(sp)
    80006016:	e8ae                	sd	a1,80(sp)
    80006018:	ecb2                	sd	a2,88(sp)
    8000601a:	f0b6                	sd	a3,96(sp)
    8000601c:	f4ba                	sd	a4,104(sp)
    8000601e:	f8be                	sd	a5,112(sp)
    80006020:	fcc2                	sd	a6,120(sp)
    80006022:	e146                	sd	a7,128(sp)
    80006024:	e54a                	sd	s2,136(sp)
    80006026:	e94e                	sd	s3,144(sp)
    80006028:	ed52                	sd	s4,152(sp)
    8000602a:	f156                	sd	s5,160(sp)
    8000602c:	f55a                	sd	s6,168(sp)
    8000602e:	f95e                	sd	s7,176(sp)
    80006030:	fd62                	sd	s8,184(sp)
    80006032:	e1e6                	sd	s9,192(sp)
    80006034:	e5ea                	sd	s10,200(sp)
    80006036:	e9ee                	sd	s11,208(sp)
    80006038:	edf2                	sd	t3,216(sp)
    8000603a:	f1f6                	sd	t4,224(sp)
    8000603c:	f5fa                	sd	t5,232(sp)
    8000603e:	f9fe                	sd	t6,240(sp)
    80006040:	be9fc0ef          	jal	ra,80002c28 <kerneltrap>
    80006044:	6082                	ld	ra,0(sp)
    80006046:	6122                	ld	sp,8(sp)
    80006048:	61c2                	ld	gp,16(sp)
    8000604a:	7282                	ld	t0,32(sp)
    8000604c:	7322                	ld	t1,40(sp)
    8000604e:	73c2                	ld	t2,48(sp)
    80006050:	7462                	ld	s0,56(sp)
    80006052:	6486                	ld	s1,64(sp)
    80006054:	6526                	ld	a0,72(sp)
    80006056:	65c6                	ld	a1,80(sp)
    80006058:	6666                	ld	a2,88(sp)
    8000605a:	7686                	ld	a3,96(sp)
    8000605c:	7726                	ld	a4,104(sp)
    8000605e:	77c6                	ld	a5,112(sp)
    80006060:	7866                	ld	a6,120(sp)
    80006062:	688a                	ld	a7,128(sp)
    80006064:	692a                	ld	s2,136(sp)
    80006066:	69ca                	ld	s3,144(sp)
    80006068:	6a6a                	ld	s4,152(sp)
    8000606a:	7a8a                	ld	s5,160(sp)
    8000606c:	7b2a                	ld	s6,168(sp)
    8000606e:	7bca                	ld	s7,176(sp)
    80006070:	7c6a                	ld	s8,184(sp)
    80006072:	6c8e                	ld	s9,192(sp)
    80006074:	6d2e                	ld	s10,200(sp)
    80006076:	6dce                	ld	s11,208(sp)
    80006078:	6e6e                	ld	t3,216(sp)
    8000607a:	7e8e                	ld	t4,224(sp)
    8000607c:	7f2e                	ld	t5,232(sp)
    8000607e:	7fce                	ld	t6,240(sp)
    80006080:	6111                	addi	sp,sp,256
    80006082:	10200073          	sret
    80006086:	00000013          	nop
    8000608a:	00000013          	nop
    8000608e:	0001                	nop

0000000080006090 <timervec>:
    80006090:	34051573          	csrrw	a0,mscratch,a0
    80006094:	e10c                	sd	a1,0(a0)
    80006096:	e510                	sd	a2,8(a0)
    80006098:	e914                	sd	a3,16(a0)
    8000609a:	6d0c                	ld	a1,24(a0)
    8000609c:	7110                	ld	a2,32(a0)
    8000609e:	6194                	ld	a3,0(a1)
    800060a0:	96b2                	add	a3,a3,a2
    800060a2:	e194                	sd	a3,0(a1)
    800060a4:	4589                	li	a1,2
    800060a6:	14459073          	csrw	sip,a1
    800060aa:	6914                	ld	a3,16(a0)
    800060ac:	6510                	ld	a2,8(a0)
    800060ae:	610c                	ld	a1,0(a0)
    800060b0:	34051573          	csrrw	a0,mscratch,a0
    800060b4:	30200073          	mret
	...

00000000800060ba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060ba:	1141                	addi	sp,sp,-16
    800060bc:	e422                	sd	s0,8(sp)
    800060be:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060c0:	0c0007b7          	lui	a5,0xc000
    800060c4:	4705                	li	a4,1
    800060c6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060c8:	c3d8                	sw	a4,4(a5)
}
    800060ca:	6422                	ld	s0,8(sp)
    800060cc:	0141                	addi	sp,sp,16
    800060ce:	8082                	ret

00000000800060d0 <plicinithart>:

void
plicinithart(void)
{
    800060d0:	1141                	addi	sp,sp,-16
    800060d2:	e406                	sd	ra,8(sp)
    800060d4:	e022                	sd	s0,0(sp)
    800060d6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060d8:	ffffc097          	auipc	ra,0xffffc
    800060dc:	c34080e7          	jalr	-972(ra) # 80001d0c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060e0:	0085171b          	slliw	a4,a0,0x8
    800060e4:	0c0027b7          	lui	a5,0xc002
    800060e8:	97ba                	add	a5,a5,a4
    800060ea:	40200713          	li	a4,1026
    800060ee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060f2:	00d5151b          	slliw	a0,a0,0xd
    800060f6:	0c2017b7          	lui	a5,0xc201
    800060fa:	953e                	add	a0,a0,a5
    800060fc:	00052023          	sw	zero,0(a0)
}
    80006100:	60a2                	ld	ra,8(sp)
    80006102:	6402                	ld	s0,0(sp)
    80006104:	0141                	addi	sp,sp,16
    80006106:	8082                	ret

0000000080006108 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006108:	1141                	addi	sp,sp,-16
    8000610a:	e406                	sd	ra,8(sp)
    8000610c:	e022                	sd	s0,0(sp)
    8000610e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006110:	ffffc097          	auipc	ra,0xffffc
    80006114:	bfc080e7          	jalr	-1028(ra) # 80001d0c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006118:	00d5179b          	slliw	a5,a0,0xd
    8000611c:	0c201537          	lui	a0,0xc201
    80006120:	953e                	add	a0,a0,a5
  return irq;
}
    80006122:	4148                	lw	a0,4(a0)
    80006124:	60a2                	ld	ra,8(sp)
    80006126:	6402                	ld	s0,0(sp)
    80006128:	0141                	addi	sp,sp,16
    8000612a:	8082                	ret

000000008000612c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000612c:	1101                	addi	sp,sp,-32
    8000612e:	ec06                	sd	ra,24(sp)
    80006130:	e822                	sd	s0,16(sp)
    80006132:	e426                	sd	s1,8(sp)
    80006134:	1000                	addi	s0,sp,32
    80006136:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006138:	ffffc097          	auipc	ra,0xffffc
    8000613c:	bd4080e7          	jalr	-1068(ra) # 80001d0c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006140:	00d5151b          	slliw	a0,a0,0xd
    80006144:	0c2017b7          	lui	a5,0xc201
    80006148:	97aa                	add	a5,a5,a0
    8000614a:	c3c4                	sw	s1,4(a5)
}
    8000614c:	60e2                	ld	ra,24(sp)
    8000614e:	6442                	ld	s0,16(sp)
    80006150:	64a2                	ld	s1,8(sp)
    80006152:	6105                	addi	sp,sp,32
    80006154:	8082                	ret

0000000080006156 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006156:	1141                	addi	sp,sp,-16
    80006158:	e406                	sd	ra,8(sp)
    8000615a:	e022                	sd	s0,0(sp)
    8000615c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000615e:	479d                	li	a5,7
    80006160:	06a7c963          	blt	a5,a0,800061d2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006164:	00022797          	auipc	a5,0x22
    80006168:	e9c78793          	addi	a5,a5,-356 # 80028000 <disk>
    8000616c:	00a78733          	add	a4,a5,a0
    80006170:	6789                	lui	a5,0x2
    80006172:	97ba                	add	a5,a5,a4
    80006174:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006178:	e7ad                	bnez	a5,800061e2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000617a:	00451793          	slli	a5,a0,0x4
    8000617e:	00024717          	auipc	a4,0x24
    80006182:	e8270713          	addi	a4,a4,-382 # 8002a000 <disk+0x2000>
    80006186:	6314                	ld	a3,0(a4)
    80006188:	96be                	add	a3,a3,a5
    8000618a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000618e:	6314                	ld	a3,0(a4)
    80006190:	96be                	add	a3,a3,a5
    80006192:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006196:	6314                	ld	a3,0(a4)
    80006198:	96be                	add	a3,a3,a5
    8000619a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000619e:	6318                	ld	a4,0(a4)
    800061a0:	97ba                	add	a5,a5,a4
    800061a2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800061a6:	00022797          	auipc	a5,0x22
    800061aa:	e5a78793          	addi	a5,a5,-422 # 80028000 <disk>
    800061ae:	97aa                	add	a5,a5,a0
    800061b0:	6509                	lui	a0,0x2
    800061b2:	953e                	add	a0,a0,a5
    800061b4:	4785                	li	a5,1
    800061b6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800061ba:	00024517          	auipc	a0,0x24
    800061be:	e5e50513          	addi	a0,a0,-418 # 8002a018 <disk+0x2018>
    800061c2:	ffffc097          	auipc	ra,0xffffc
    800061c6:	50c080e7          	jalr	1292(ra) # 800026ce <wakeup>
}
    800061ca:	60a2                	ld	ra,8(sp)
    800061cc:	6402                	ld	s0,0(sp)
    800061ce:	0141                	addi	sp,sp,16
    800061d0:	8082                	ret
    panic("free_desc 1");
    800061d2:	00002517          	auipc	a0,0x2
    800061d6:	60650513          	addi	a0,a0,1542 # 800087d8 <syscalls+0x320>
    800061da:	ffffa097          	auipc	ra,0xffffa
    800061de:	376080e7          	jalr	886(ra) # 80000550 <panic>
    panic("free_desc 2");
    800061e2:	00002517          	auipc	a0,0x2
    800061e6:	60650513          	addi	a0,a0,1542 # 800087e8 <syscalls+0x330>
    800061ea:	ffffa097          	auipc	ra,0xffffa
    800061ee:	366080e7          	jalr	870(ra) # 80000550 <panic>

00000000800061f2 <virtio_disk_init>:
{
    800061f2:	1101                	addi	sp,sp,-32
    800061f4:	ec06                	sd	ra,24(sp)
    800061f6:	e822                	sd	s0,16(sp)
    800061f8:	e426                	sd	s1,8(sp)
    800061fa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061fc:	00002597          	auipc	a1,0x2
    80006200:	5fc58593          	addi	a1,a1,1532 # 800087f8 <syscalls+0x340>
    80006204:	00024517          	auipc	a0,0x24
    80006208:	f2450513          	addi	a0,a0,-220 # 8002a128 <disk+0x2128>
    8000620c:	ffffb097          	auipc	ra,0xffffb
    80006210:	c60080e7          	jalr	-928(ra) # 80000e6c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006214:	100017b7          	lui	a5,0x10001
    80006218:	4398                	lw	a4,0(a5)
    8000621a:	2701                	sext.w	a4,a4
    8000621c:	747277b7          	lui	a5,0x74727
    80006220:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006224:	0ef71163          	bne	a4,a5,80006306 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006228:	100017b7          	lui	a5,0x10001
    8000622c:	43dc                	lw	a5,4(a5)
    8000622e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006230:	4705                	li	a4,1
    80006232:	0ce79a63          	bne	a5,a4,80006306 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006236:	100017b7          	lui	a5,0x10001
    8000623a:	479c                	lw	a5,8(a5)
    8000623c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000623e:	4709                	li	a4,2
    80006240:	0ce79363          	bne	a5,a4,80006306 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006244:	100017b7          	lui	a5,0x10001
    80006248:	47d8                	lw	a4,12(a5)
    8000624a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000624c:	554d47b7          	lui	a5,0x554d4
    80006250:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006254:	0af71963          	bne	a4,a5,80006306 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006258:	100017b7          	lui	a5,0x10001
    8000625c:	4705                	li	a4,1
    8000625e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006260:	470d                	li	a4,3
    80006262:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006264:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006266:	c7ffe737          	lui	a4,0xc7ffe
    8000626a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd2737>
    8000626e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006270:	2701                	sext.w	a4,a4
    80006272:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006274:	472d                	li	a4,11
    80006276:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006278:	473d                	li	a4,15
    8000627a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000627c:	6705                	lui	a4,0x1
    8000627e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006280:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006284:	5bdc                	lw	a5,52(a5)
    80006286:	2781                	sext.w	a5,a5
  if(max == 0)
    80006288:	c7d9                	beqz	a5,80006316 <virtio_disk_init+0x124>
  if(max < NUM)
    8000628a:	471d                	li	a4,7
    8000628c:	08f77d63          	bgeu	a4,a5,80006326 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006290:	100014b7          	lui	s1,0x10001
    80006294:	47a1                	li	a5,8
    80006296:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006298:	6609                	lui	a2,0x2
    8000629a:	4581                	li	a1,0
    8000629c:	00022517          	auipc	a0,0x22
    800062a0:	d6450513          	addi	a0,a0,-668 # 80028000 <disk>
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	e2c080e7          	jalr	-468(ra) # 800010d0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800062ac:	00022717          	auipc	a4,0x22
    800062b0:	d5470713          	addi	a4,a4,-684 # 80028000 <disk>
    800062b4:	00c75793          	srli	a5,a4,0xc
    800062b8:	2781                	sext.w	a5,a5
    800062ba:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800062bc:	00024797          	auipc	a5,0x24
    800062c0:	d4478793          	addi	a5,a5,-700 # 8002a000 <disk+0x2000>
    800062c4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800062c6:	00022717          	auipc	a4,0x22
    800062ca:	dba70713          	addi	a4,a4,-582 # 80028080 <disk+0x80>
    800062ce:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800062d0:	00023717          	auipc	a4,0x23
    800062d4:	d3070713          	addi	a4,a4,-720 # 80029000 <disk+0x1000>
    800062d8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800062da:	4705                	li	a4,1
    800062dc:	00e78c23          	sb	a4,24(a5)
    800062e0:	00e78ca3          	sb	a4,25(a5)
    800062e4:	00e78d23          	sb	a4,26(a5)
    800062e8:	00e78da3          	sb	a4,27(a5)
    800062ec:	00e78e23          	sb	a4,28(a5)
    800062f0:	00e78ea3          	sb	a4,29(a5)
    800062f4:	00e78f23          	sb	a4,30(a5)
    800062f8:	00e78fa3          	sb	a4,31(a5)
}
    800062fc:	60e2                	ld	ra,24(sp)
    800062fe:	6442                	ld	s0,16(sp)
    80006300:	64a2                	ld	s1,8(sp)
    80006302:	6105                	addi	sp,sp,32
    80006304:	8082                	ret
    panic("could not find virtio disk");
    80006306:	00002517          	auipc	a0,0x2
    8000630a:	50250513          	addi	a0,a0,1282 # 80008808 <syscalls+0x350>
    8000630e:	ffffa097          	auipc	ra,0xffffa
    80006312:	242080e7          	jalr	578(ra) # 80000550 <panic>
    panic("virtio disk has no queue 0");
    80006316:	00002517          	auipc	a0,0x2
    8000631a:	51250513          	addi	a0,a0,1298 # 80008828 <syscalls+0x370>
    8000631e:	ffffa097          	auipc	ra,0xffffa
    80006322:	232080e7          	jalr	562(ra) # 80000550 <panic>
    panic("virtio disk max queue too short");
    80006326:	00002517          	auipc	a0,0x2
    8000632a:	52250513          	addi	a0,a0,1314 # 80008848 <syscalls+0x390>
    8000632e:	ffffa097          	auipc	ra,0xffffa
    80006332:	222080e7          	jalr	546(ra) # 80000550 <panic>

0000000080006336 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006336:	7159                	addi	sp,sp,-112
    80006338:	f486                	sd	ra,104(sp)
    8000633a:	f0a2                	sd	s0,96(sp)
    8000633c:	eca6                	sd	s1,88(sp)
    8000633e:	e8ca                	sd	s2,80(sp)
    80006340:	e4ce                	sd	s3,72(sp)
    80006342:	e0d2                	sd	s4,64(sp)
    80006344:	fc56                	sd	s5,56(sp)
    80006346:	f85a                	sd	s6,48(sp)
    80006348:	f45e                	sd	s7,40(sp)
    8000634a:	f062                	sd	s8,32(sp)
    8000634c:	ec66                	sd	s9,24(sp)
    8000634e:	e86a                	sd	s10,16(sp)
    80006350:	1880                	addi	s0,sp,112
    80006352:	892a                	mv	s2,a0
    80006354:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006356:	00c52c83          	lw	s9,12(a0)
    8000635a:	001c9c9b          	slliw	s9,s9,0x1
    8000635e:	1c82                	slli	s9,s9,0x20
    80006360:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006364:	00024517          	auipc	a0,0x24
    80006368:	dc450513          	addi	a0,a0,-572 # 8002a128 <disk+0x2128>
    8000636c:	ffffb097          	auipc	ra,0xffffb
    80006370:	984080e7          	jalr	-1660(ra) # 80000cf0 <acquire>
  for(int i = 0; i < 3; i++){
    80006374:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006376:	4c21                	li	s8,8
      disk.free[i] = 0;
    80006378:	00022b97          	auipc	s7,0x22
    8000637c:	c88b8b93          	addi	s7,s7,-888 # 80028000 <disk>
    80006380:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006382:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006384:	8a4e                	mv	s4,s3
    80006386:	a051                	j	8000640a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80006388:	00fb86b3          	add	a3,s7,a5
    8000638c:	96da                	add	a3,a3,s6
    8000638e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006392:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006394:	0207c563          	bltz	a5,800063be <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006398:	2485                	addiw	s1,s1,1
    8000639a:	0711                	addi	a4,a4,4
    8000639c:	25548063          	beq	s1,s5,800065dc <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    800063a0:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800063a2:	00024697          	auipc	a3,0x24
    800063a6:	c7668693          	addi	a3,a3,-906 # 8002a018 <disk+0x2018>
    800063aa:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800063ac:	0006c583          	lbu	a1,0(a3)
    800063b0:	fde1                	bnez	a1,80006388 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800063b2:	2785                	addiw	a5,a5,1
    800063b4:	0685                	addi	a3,a3,1
    800063b6:	ff879be3          	bne	a5,s8,800063ac <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800063ba:	57fd                	li	a5,-1
    800063bc:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800063be:	02905a63          	blez	s1,800063f2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800063c2:	f9042503          	lw	a0,-112(s0)
    800063c6:	00000097          	auipc	ra,0x0
    800063ca:	d90080e7          	jalr	-624(ra) # 80006156 <free_desc>
      for(int j = 0; j < i; j++)
    800063ce:	4785                	li	a5,1
    800063d0:	0297d163          	bge	a5,s1,800063f2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800063d4:	f9442503          	lw	a0,-108(s0)
    800063d8:	00000097          	auipc	ra,0x0
    800063dc:	d7e080e7          	jalr	-642(ra) # 80006156 <free_desc>
      for(int j = 0; j < i; j++)
    800063e0:	4789                	li	a5,2
    800063e2:	0097d863          	bge	a5,s1,800063f2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800063e6:	f9842503          	lw	a0,-104(s0)
    800063ea:	00000097          	auipc	ra,0x0
    800063ee:	d6c080e7          	jalr	-660(ra) # 80006156 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063f2:	00024597          	auipc	a1,0x24
    800063f6:	d3658593          	addi	a1,a1,-714 # 8002a128 <disk+0x2128>
    800063fa:	00024517          	auipc	a0,0x24
    800063fe:	c1e50513          	addi	a0,a0,-994 # 8002a018 <disk+0x2018>
    80006402:	ffffc097          	auipc	ra,0xffffc
    80006406:	146080e7          	jalr	326(ra) # 80002548 <sleep>
  for(int i = 0; i < 3; i++){
    8000640a:	f9040713          	addi	a4,s0,-112
    8000640e:	84ce                	mv	s1,s3
    80006410:	bf41                	j	800063a0 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006412:	20058713          	addi	a4,a1,512
    80006416:	00471693          	slli	a3,a4,0x4
    8000641a:	00022717          	auipc	a4,0x22
    8000641e:	be670713          	addi	a4,a4,-1050 # 80028000 <disk>
    80006422:	9736                	add	a4,a4,a3
    80006424:	4685                	li	a3,1
    80006426:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000642a:	20058713          	addi	a4,a1,512
    8000642e:	00471693          	slli	a3,a4,0x4
    80006432:	00022717          	auipc	a4,0x22
    80006436:	bce70713          	addi	a4,a4,-1074 # 80028000 <disk>
    8000643a:	9736                	add	a4,a4,a3
    8000643c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006440:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006444:	7679                	lui	a2,0xffffe
    80006446:	963e                	add	a2,a2,a5
    80006448:	00024697          	auipc	a3,0x24
    8000644c:	bb868693          	addi	a3,a3,-1096 # 8002a000 <disk+0x2000>
    80006450:	6298                	ld	a4,0(a3)
    80006452:	9732                	add	a4,a4,a2
    80006454:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006456:	6298                	ld	a4,0(a3)
    80006458:	9732                	add	a4,a4,a2
    8000645a:	4541                	li	a0,16
    8000645c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000645e:	6298                	ld	a4,0(a3)
    80006460:	9732                	add	a4,a4,a2
    80006462:	4505                	li	a0,1
    80006464:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006468:	f9442703          	lw	a4,-108(s0)
    8000646c:	6288                	ld	a0,0(a3)
    8000646e:	962a                	add	a2,a2,a0
    80006470:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd1fe6>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006474:	0712                	slli	a4,a4,0x4
    80006476:	6290                	ld	a2,0(a3)
    80006478:	963a                	add	a2,a2,a4
    8000647a:	06090513          	addi	a0,s2,96
    8000647e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006480:	6294                	ld	a3,0(a3)
    80006482:	96ba                	add	a3,a3,a4
    80006484:	40000613          	li	a2,1024
    80006488:	c690                	sw	a2,8(a3)
  if(write)
    8000648a:	140d0063          	beqz	s10,800065ca <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000648e:	00024697          	auipc	a3,0x24
    80006492:	b726b683          	ld	a3,-1166(a3) # 8002a000 <disk+0x2000>
    80006496:	96ba                	add	a3,a3,a4
    80006498:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000649c:	00022817          	auipc	a6,0x22
    800064a0:	b6480813          	addi	a6,a6,-1180 # 80028000 <disk>
    800064a4:	00024517          	auipc	a0,0x24
    800064a8:	b5c50513          	addi	a0,a0,-1188 # 8002a000 <disk+0x2000>
    800064ac:	6114                	ld	a3,0(a0)
    800064ae:	96ba                	add	a3,a3,a4
    800064b0:	00c6d603          	lhu	a2,12(a3)
    800064b4:	00166613          	ori	a2,a2,1
    800064b8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800064bc:	f9842683          	lw	a3,-104(s0)
    800064c0:	6110                	ld	a2,0(a0)
    800064c2:	9732                	add	a4,a4,a2
    800064c4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064c8:	20058613          	addi	a2,a1,512
    800064cc:	0612                	slli	a2,a2,0x4
    800064ce:	9642                	add	a2,a2,a6
    800064d0:	577d                	li	a4,-1
    800064d2:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800064d6:	00469713          	slli	a4,a3,0x4
    800064da:	6114                	ld	a3,0(a0)
    800064dc:	96ba                	add	a3,a3,a4
    800064de:	03078793          	addi	a5,a5,48
    800064e2:	97c2                	add	a5,a5,a6
    800064e4:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    800064e6:	611c                	ld	a5,0(a0)
    800064e8:	97ba                	add	a5,a5,a4
    800064ea:	4685                	li	a3,1
    800064ec:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064ee:	611c                	ld	a5,0(a0)
    800064f0:	97ba                	add	a5,a5,a4
    800064f2:	4809                	li	a6,2
    800064f4:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800064f8:	611c                	ld	a5,0(a0)
    800064fa:	973e                	add	a4,a4,a5
    800064fc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006500:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006504:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006508:	6518                	ld	a4,8(a0)
    8000650a:	00275783          	lhu	a5,2(a4)
    8000650e:	8b9d                	andi	a5,a5,7
    80006510:	0786                	slli	a5,a5,0x1
    80006512:	97ba                	add	a5,a5,a4
    80006514:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006518:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000651c:	6518                	ld	a4,8(a0)
    8000651e:	00275783          	lhu	a5,2(a4)
    80006522:	2785                	addiw	a5,a5,1
    80006524:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006528:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000652c:	100017b7          	lui	a5,0x10001
    80006530:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006534:	00492703          	lw	a4,4(s2)
    80006538:	4785                	li	a5,1
    8000653a:	02f71163          	bne	a4,a5,8000655c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000653e:	00024997          	auipc	s3,0x24
    80006542:	bea98993          	addi	s3,s3,-1046 # 8002a128 <disk+0x2128>
  while(b->disk == 1) {
    80006546:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006548:	85ce                	mv	a1,s3
    8000654a:	854a                	mv	a0,s2
    8000654c:	ffffc097          	auipc	ra,0xffffc
    80006550:	ffc080e7          	jalr	-4(ra) # 80002548 <sleep>
  while(b->disk == 1) {
    80006554:	00492783          	lw	a5,4(s2)
    80006558:	fe9788e3          	beq	a5,s1,80006548 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000655c:	f9042903          	lw	s2,-112(s0)
    80006560:	20090793          	addi	a5,s2,512
    80006564:	00479713          	slli	a4,a5,0x4
    80006568:	00022797          	auipc	a5,0x22
    8000656c:	a9878793          	addi	a5,a5,-1384 # 80028000 <disk>
    80006570:	97ba                	add	a5,a5,a4
    80006572:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006576:	00024997          	auipc	s3,0x24
    8000657a:	a8a98993          	addi	s3,s3,-1398 # 8002a000 <disk+0x2000>
    8000657e:	00491713          	slli	a4,s2,0x4
    80006582:	0009b783          	ld	a5,0(s3)
    80006586:	97ba                	add	a5,a5,a4
    80006588:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000658c:	854a                	mv	a0,s2
    8000658e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006592:	00000097          	auipc	ra,0x0
    80006596:	bc4080e7          	jalr	-1084(ra) # 80006156 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000659a:	8885                	andi	s1,s1,1
    8000659c:	f0ed                	bnez	s1,8000657e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000659e:	00024517          	auipc	a0,0x24
    800065a2:	b8a50513          	addi	a0,a0,-1142 # 8002a128 <disk+0x2128>
    800065a6:	ffffb097          	auipc	ra,0xffffb
    800065aa:	81a080e7          	jalr	-2022(ra) # 80000dc0 <release>
}
    800065ae:	70a6                	ld	ra,104(sp)
    800065b0:	7406                	ld	s0,96(sp)
    800065b2:	64e6                	ld	s1,88(sp)
    800065b4:	6946                	ld	s2,80(sp)
    800065b6:	69a6                	ld	s3,72(sp)
    800065b8:	6a06                	ld	s4,64(sp)
    800065ba:	7ae2                	ld	s5,56(sp)
    800065bc:	7b42                	ld	s6,48(sp)
    800065be:	7ba2                	ld	s7,40(sp)
    800065c0:	7c02                	ld	s8,32(sp)
    800065c2:	6ce2                	ld	s9,24(sp)
    800065c4:	6d42                	ld	s10,16(sp)
    800065c6:	6165                	addi	sp,sp,112
    800065c8:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800065ca:	00024697          	auipc	a3,0x24
    800065ce:	a366b683          	ld	a3,-1482(a3) # 8002a000 <disk+0x2000>
    800065d2:	96ba                	add	a3,a3,a4
    800065d4:	4609                	li	a2,2
    800065d6:	00c69623          	sh	a2,12(a3)
    800065da:	b5c9                	j	8000649c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065dc:	f9042583          	lw	a1,-112(s0)
    800065e0:	20058793          	addi	a5,a1,512
    800065e4:	0792                	slli	a5,a5,0x4
    800065e6:	00022517          	auipc	a0,0x22
    800065ea:	ac250513          	addi	a0,a0,-1342 # 800280a8 <disk+0xa8>
    800065ee:	953e                	add	a0,a0,a5
  if(write)
    800065f0:	e20d11e3          	bnez	s10,80006412 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800065f4:	20058713          	addi	a4,a1,512
    800065f8:	00471693          	slli	a3,a4,0x4
    800065fc:	00022717          	auipc	a4,0x22
    80006600:	a0470713          	addi	a4,a4,-1532 # 80028000 <disk>
    80006604:	9736                	add	a4,a4,a3
    80006606:	0a072423          	sw	zero,168(a4)
    8000660a:	b505                	j	8000642a <virtio_disk_rw+0xf4>

000000008000660c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000660c:	1101                	addi	sp,sp,-32
    8000660e:	ec06                	sd	ra,24(sp)
    80006610:	e822                	sd	s0,16(sp)
    80006612:	e426                	sd	s1,8(sp)
    80006614:	e04a                	sd	s2,0(sp)
    80006616:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006618:	00024517          	auipc	a0,0x24
    8000661c:	b1050513          	addi	a0,a0,-1264 # 8002a128 <disk+0x2128>
    80006620:	ffffa097          	auipc	ra,0xffffa
    80006624:	6d0080e7          	jalr	1744(ra) # 80000cf0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006628:	10001737          	lui	a4,0x10001
    8000662c:	533c                	lw	a5,96(a4)
    8000662e:	8b8d                	andi	a5,a5,3
    80006630:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006632:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006636:	00024797          	auipc	a5,0x24
    8000663a:	9ca78793          	addi	a5,a5,-1590 # 8002a000 <disk+0x2000>
    8000663e:	6b94                	ld	a3,16(a5)
    80006640:	0207d703          	lhu	a4,32(a5)
    80006644:	0026d783          	lhu	a5,2(a3)
    80006648:	06f70163          	beq	a4,a5,800066aa <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000664c:	00022917          	auipc	s2,0x22
    80006650:	9b490913          	addi	s2,s2,-1612 # 80028000 <disk>
    80006654:	00024497          	auipc	s1,0x24
    80006658:	9ac48493          	addi	s1,s1,-1620 # 8002a000 <disk+0x2000>
    __sync_synchronize();
    8000665c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006660:	6898                	ld	a4,16(s1)
    80006662:	0204d783          	lhu	a5,32(s1)
    80006666:	8b9d                	andi	a5,a5,7
    80006668:	078e                	slli	a5,a5,0x3
    8000666a:	97ba                	add	a5,a5,a4
    8000666c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000666e:	20078713          	addi	a4,a5,512
    80006672:	0712                	slli	a4,a4,0x4
    80006674:	974a                	add	a4,a4,s2
    80006676:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000667a:	e731                	bnez	a4,800066c6 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000667c:	20078793          	addi	a5,a5,512
    80006680:	0792                	slli	a5,a5,0x4
    80006682:	97ca                	add	a5,a5,s2
    80006684:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006686:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000668a:	ffffc097          	auipc	ra,0xffffc
    8000668e:	044080e7          	jalr	68(ra) # 800026ce <wakeup>

    disk.used_idx += 1;
    80006692:	0204d783          	lhu	a5,32(s1)
    80006696:	2785                	addiw	a5,a5,1
    80006698:	17c2                	slli	a5,a5,0x30
    8000669a:	93c1                	srli	a5,a5,0x30
    8000669c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800066a0:	6898                	ld	a4,16(s1)
    800066a2:	00275703          	lhu	a4,2(a4)
    800066a6:	faf71be3          	bne	a4,a5,8000665c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800066aa:	00024517          	auipc	a0,0x24
    800066ae:	a7e50513          	addi	a0,a0,-1410 # 8002a128 <disk+0x2128>
    800066b2:	ffffa097          	auipc	ra,0xffffa
    800066b6:	70e080e7          	jalr	1806(ra) # 80000dc0 <release>
}
    800066ba:	60e2                	ld	ra,24(sp)
    800066bc:	6442                	ld	s0,16(sp)
    800066be:	64a2                	ld	s1,8(sp)
    800066c0:	6902                	ld	s2,0(sp)
    800066c2:	6105                	addi	sp,sp,32
    800066c4:	8082                	ret
      panic("virtio_disk_intr status");
    800066c6:	00002517          	auipc	a0,0x2
    800066ca:	1a250513          	addi	a0,a0,418 # 80008868 <syscalls+0x3b0>
    800066ce:	ffffa097          	auipc	ra,0xffffa
    800066d2:	e82080e7          	jalr	-382(ra) # 80000550 <panic>

00000000800066d6 <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    800066d6:	1141                	addi	sp,sp,-16
    800066d8:	e422                	sd	s0,8(sp)
    800066da:	0800                	addi	s0,sp,16
  return -1;
}
    800066dc:	557d                	li	a0,-1
    800066de:	6422                	ld	s0,8(sp)
    800066e0:	0141                	addi	sp,sp,16
    800066e2:	8082                	ret

00000000800066e4 <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    800066e4:	7179                	addi	sp,sp,-48
    800066e6:	f406                	sd	ra,40(sp)
    800066e8:	f022                	sd	s0,32(sp)
    800066ea:	ec26                	sd	s1,24(sp)
    800066ec:	e84a                	sd	s2,16(sp)
    800066ee:	e44e                	sd	s3,8(sp)
    800066f0:	e052                	sd	s4,0(sp)
    800066f2:	1800                	addi	s0,sp,48
    800066f4:	892a                	mv	s2,a0
    800066f6:	89ae                	mv	s3,a1
    800066f8:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    800066fa:	00025517          	auipc	a0,0x25
    800066fe:	90650513          	addi	a0,a0,-1786 # 8002b000 <stats>
    80006702:	ffffa097          	auipc	ra,0xffffa
    80006706:	5ee080e7          	jalr	1518(ra) # 80000cf0 <acquire>

  if(stats.sz == 0) {
    8000670a:	00026797          	auipc	a5,0x26
    8000670e:	9167a783          	lw	a5,-1770(a5) # 8002c020 <stats+0x1020>
    80006712:	cbb5                	beqz	a5,80006786 <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    80006714:	00026797          	auipc	a5,0x26
    80006718:	8ec78793          	addi	a5,a5,-1812 # 8002c000 <stats+0x1000>
    8000671c:	53d8                	lw	a4,36(a5)
    8000671e:	539c                	lw	a5,32(a5)
    80006720:	9f99                	subw	a5,a5,a4
    80006722:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    80006726:	06d05e63          	blez	a3,800067a2 <statsread+0xbe>
    if(m > n)
    8000672a:	8a3e                	mv	s4,a5
    8000672c:	00d4d363          	bge	s1,a3,80006732 <statsread+0x4e>
    80006730:	8a26                	mv	s4,s1
    80006732:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    80006736:	86a6                	mv	a3,s1
    80006738:	00025617          	auipc	a2,0x25
    8000673c:	8e860613          	addi	a2,a2,-1816 # 8002b020 <stats+0x20>
    80006740:	963a                	add	a2,a2,a4
    80006742:	85ce                	mv	a1,s3
    80006744:	854a                	mv	a0,s2
    80006746:	ffffc097          	auipc	ra,0xffffc
    8000674a:	064080e7          	jalr	100(ra) # 800027aa <either_copyout>
    8000674e:	57fd                	li	a5,-1
    80006750:	00f50a63          	beq	a0,a5,80006764 <statsread+0x80>
      stats.off += m;
    80006754:	00026717          	auipc	a4,0x26
    80006758:	8ac70713          	addi	a4,a4,-1876 # 8002c000 <stats+0x1000>
    8000675c:	535c                	lw	a5,36(a4)
    8000675e:	014787bb          	addw	a5,a5,s4
    80006762:	d35c                	sw	a5,36(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    80006764:	00025517          	auipc	a0,0x25
    80006768:	89c50513          	addi	a0,a0,-1892 # 8002b000 <stats>
    8000676c:	ffffa097          	auipc	ra,0xffffa
    80006770:	654080e7          	jalr	1620(ra) # 80000dc0 <release>
  return m;
}
    80006774:	8526                	mv	a0,s1
    80006776:	70a2                	ld	ra,40(sp)
    80006778:	7402                	ld	s0,32(sp)
    8000677a:	64e2                	ld	s1,24(sp)
    8000677c:	6942                	ld	s2,16(sp)
    8000677e:	69a2                	ld	s3,8(sp)
    80006780:	6a02                	ld	s4,0(sp)
    80006782:	6145                	addi	sp,sp,48
    80006784:	8082                	ret
    stats.sz = statslock(stats.buf, BUFSZ);
    80006786:	6585                	lui	a1,0x1
    80006788:	00025517          	auipc	a0,0x25
    8000678c:	89850513          	addi	a0,a0,-1896 # 8002b020 <stats+0x20>
    80006790:	ffffa097          	auipc	ra,0xffffa
    80006794:	78a080e7          	jalr	1930(ra) # 80000f1a <statslock>
    80006798:	00026797          	auipc	a5,0x26
    8000679c:	88a7a423          	sw	a0,-1912(a5) # 8002c020 <stats+0x1020>
    800067a0:	bf95                	j	80006714 <statsread+0x30>
    stats.sz = 0;
    800067a2:	00026797          	auipc	a5,0x26
    800067a6:	85e78793          	addi	a5,a5,-1954 # 8002c000 <stats+0x1000>
    800067aa:	0207a023          	sw	zero,32(a5)
    stats.off = 0;
    800067ae:	0207a223          	sw	zero,36(a5)
    m = -1;
    800067b2:	54fd                	li	s1,-1
    800067b4:	bf45                	j	80006764 <statsread+0x80>

00000000800067b6 <statsinit>:

void
statsinit(void)
{
    800067b6:	1141                	addi	sp,sp,-16
    800067b8:	e406                	sd	ra,8(sp)
    800067ba:	e022                	sd	s0,0(sp)
    800067bc:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    800067be:	00002597          	auipc	a1,0x2
    800067c2:	0c258593          	addi	a1,a1,194 # 80008880 <syscalls+0x3c8>
    800067c6:	00025517          	auipc	a0,0x25
    800067ca:	83a50513          	addi	a0,a0,-1990 # 8002b000 <stats>
    800067ce:	ffffa097          	auipc	ra,0xffffa
    800067d2:	69e080e7          	jalr	1694(ra) # 80000e6c <initlock>

  devsw[STATS].read = statsread;
    800067d6:	00020797          	auipc	a5,0x20
    800067da:	84278793          	addi	a5,a5,-1982 # 80026018 <devsw>
    800067de:	00000717          	auipc	a4,0x0
    800067e2:	f0670713          	addi	a4,a4,-250 # 800066e4 <statsread>
    800067e6:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    800067e8:	00000717          	auipc	a4,0x0
    800067ec:	eee70713          	addi	a4,a4,-274 # 800066d6 <statswrite>
    800067f0:	f798                	sd	a4,40(a5)
}
    800067f2:	60a2                	ld	ra,8(sp)
    800067f4:	6402                	ld	s0,0(sp)
    800067f6:	0141                	addi	sp,sp,16
    800067f8:	8082                	ret

00000000800067fa <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    800067fa:	1101                	addi	sp,sp,-32
    800067fc:	ec22                	sd	s0,24(sp)
    800067fe:	1000                	addi	s0,sp,32
    80006800:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    80006802:	c299                	beqz	a3,80006808 <sprintint+0xe>
    80006804:	0805c163          	bltz	a1,80006886 <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    80006808:	2581                	sext.w	a1,a1
    8000680a:	4301                	li	t1,0

  i = 0;
    8000680c:	fe040713          	addi	a4,s0,-32
    80006810:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    80006812:	2601                	sext.w	a2,a2
    80006814:	00002697          	auipc	a3,0x2
    80006818:	07468693          	addi	a3,a3,116 # 80008888 <digits>
    8000681c:	88aa                	mv	a7,a0
    8000681e:	2505                	addiw	a0,a0,1
    80006820:	02c5f7bb          	remuw	a5,a1,a2
    80006824:	1782                	slli	a5,a5,0x20
    80006826:	9381                	srli	a5,a5,0x20
    80006828:	97b6                	add	a5,a5,a3
    8000682a:	0007c783          	lbu	a5,0(a5)
    8000682e:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    80006832:	0005879b          	sext.w	a5,a1
    80006836:	02c5d5bb          	divuw	a1,a1,a2
    8000683a:	0705                	addi	a4,a4,1
    8000683c:	fec7f0e3          	bgeu	a5,a2,8000681c <sprintint+0x22>

  if(sign)
    80006840:	00030b63          	beqz	t1,80006856 <sprintint+0x5c>
    buf[i++] = '-';
    80006844:	ff040793          	addi	a5,s0,-16
    80006848:	97aa                	add	a5,a5,a0
    8000684a:	02d00713          	li	a4,45
    8000684e:	fee78823          	sb	a4,-16(a5)
    80006852:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    80006856:	02a05c63          	blez	a0,8000688e <sprintint+0x94>
    8000685a:	fe040793          	addi	a5,s0,-32
    8000685e:	00a78733          	add	a4,a5,a0
    80006862:	87c2                	mv	a5,a6
    80006864:	0805                	addi	a6,a6,1
    80006866:	fff5061b          	addiw	a2,a0,-1
    8000686a:	1602                	slli	a2,a2,0x20
    8000686c:	9201                	srli	a2,a2,0x20
    8000686e:	9642                	add	a2,a2,a6
  *s = c;
    80006870:	fff74683          	lbu	a3,-1(a4)
    80006874:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    80006878:	177d                	addi	a4,a4,-1
    8000687a:	0785                	addi	a5,a5,1
    8000687c:	fec79ae3          	bne	a5,a2,80006870 <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    80006880:	6462                	ld	s0,24(sp)
    80006882:	6105                	addi	sp,sp,32
    80006884:	8082                	ret
    x = -xx;
    80006886:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    8000688a:	4305                	li	t1,1
    x = -xx;
    8000688c:	b741                	j	8000680c <sprintint+0x12>
  while(--i >= 0)
    8000688e:	4501                	li	a0,0
    80006890:	bfc5                	j	80006880 <sprintint+0x86>

0000000080006892 <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    80006892:	7171                	addi	sp,sp,-176
    80006894:	fc86                	sd	ra,120(sp)
    80006896:	f8a2                	sd	s0,112(sp)
    80006898:	f4a6                	sd	s1,104(sp)
    8000689a:	f0ca                	sd	s2,96(sp)
    8000689c:	ecce                	sd	s3,88(sp)
    8000689e:	e8d2                	sd	s4,80(sp)
    800068a0:	e4d6                	sd	s5,72(sp)
    800068a2:	e0da                	sd	s6,64(sp)
    800068a4:	fc5e                	sd	s7,56(sp)
    800068a6:	f862                	sd	s8,48(sp)
    800068a8:	f466                	sd	s9,40(sp)
    800068aa:	f06a                	sd	s10,32(sp)
    800068ac:	ec6e                	sd	s11,24(sp)
    800068ae:	0100                	addi	s0,sp,128
    800068b0:	e414                	sd	a3,8(s0)
    800068b2:	e818                	sd	a4,16(s0)
    800068b4:	ec1c                	sd	a5,24(s0)
    800068b6:	03043023          	sd	a6,32(s0)
    800068ba:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    800068be:	ca0d                	beqz	a2,800068f0 <snprintf+0x5e>
    800068c0:	8baa                	mv	s7,a0
    800068c2:	89ae                	mv	s3,a1
    800068c4:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    800068c6:	00840793          	addi	a5,s0,8
    800068ca:	f8f43423          	sd	a5,-120(s0)
  int off = 0;
    800068ce:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    800068d0:	4901                	li	s2,0
    800068d2:	02b05763          	blez	a1,80006900 <snprintf+0x6e>
    if(c != '%'){
    800068d6:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    800068da:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    800068de:	02800d93          	li	s11,40
  *s = c;
    800068e2:	02500d13          	li	s10,37
    switch(c){
    800068e6:	07800c93          	li	s9,120
    800068ea:	06400c13          	li	s8,100
    800068ee:	a01d                	j	80006914 <snprintf+0x82>
    panic("null fmt");
    800068f0:	00001517          	auipc	a0,0x1
    800068f4:	73850513          	addi	a0,a0,1848 # 80008028 <etext+0x28>
    800068f8:	ffffa097          	auipc	ra,0xffffa
    800068fc:	c58080e7          	jalr	-936(ra) # 80000550 <panic>
  int off = 0;
    80006900:	4481                	li	s1,0
    80006902:	a86d                	j	800069bc <snprintf+0x12a>
  *s = c;
    80006904:	009b8733          	add	a4,s7,s1
    80006908:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    8000690c:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    8000690e:	2905                	addiw	s2,s2,1
    80006910:	0b34d663          	bge	s1,s3,800069bc <snprintf+0x12a>
    80006914:	012a07b3          	add	a5,s4,s2
    80006918:	0007c783          	lbu	a5,0(a5)
    8000691c:	0007871b          	sext.w	a4,a5
    80006920:	cfd1                	beqz	a5,800069bc <snprintf+0x12a>
    if(c != '%'){
    80006922:	ff5711e3          	bne	a4,s5,80006904 <snprintf+0x72>
    c = fmt[++i] & 0xff;
    80006926:	2905                	addiw	s2,s2,1
    80006928:	012a07b3          	add	a5,s4,s2
    8000692c:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    80006930:	c7d1                	beqz	a5,800069bc <snprintf+0x12a>
    switch(c){
    80006932:	05678c63          	beq	a5,s6,8000698a <snprintf+0xf8>
    80006936:	02fb6763          	bltu	s6,a5,80006964 <snprintf+0xd2>
    8000693a:	0b578763          	beq	a5,s5,800069e8 <snprintf+0x156>
    8000693e:	0b879b63          	bne	a5,s8,800069f4 <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    80006942:	f8843783          	ld	a5,-120(s0)
    80006946:	00878713          	addi	a4,a5,8
    8000694a:	f8e43423          	sd	a4,-120(s0)
    8000694e:	4685                	li	a3,1
    80006950:	4629                	li	a2,10
    80006952:	438c                	lw	a1,0(a5)
    80006954:	009b8533          	add	a0,s7,s1
    80006958:	00000097          	auipc	ra,0x0
    8000695c:	ea2080e7          	jalr	-350(ra) # 800067fa <sprintint>
    80006960:	9ca9                	addw	s1,s1,a0
      break;
    80006962:	b775                	j	8000690e <snprintf+0x7c>
    switch(c){
    80006964:	09979863          	bne	a5,s9,800069f4 <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    80006968:	f8843783          	ld	a5,-120(s0)
    8000696c:	00878713          	addi	a4,a5,8
    80006970:	f8e43423          	sd	a4,-120(s0)
    80006974:	4685                	li	a3,1
    80006976:	4641                	li	a2,16
    80006978:	438c                	lw	a1,0(a5)
    8000697a:	009b8533          	add	a0,s7,s1
    8000697e:	00000097          	auipc	ra,0x0
    80006982:	e7c080e7          	jalr	-388(ra) # 800067fa <sprintint>
    80006986:	9ca9                	addw	s1,s1,a0
      break;
    80006988:	b759                	j	8000690e <snprintf+0x7c>
      if((s = va_arg(ap, char*)) == 0)
    8000698a:	f8843783          	ld	a5,-120(s0)
    8000698e:	00878713          	addi	a4,a5,8
    80006992:	f8e43423          	sd	a4,-120(s0)
    80006996:	639c                	ld	a5,0(a5)
    80006998:	c3b1                	beqz	a5,800069dc <snprintf+0x14a>
      for(; *s && off < sz; s++)
    8000699a:	0007c703          	lbu	a4,0(a5)
    8000699e:	db25                	beqz	a4,8000690e <snprintf+0x7c>
    800069a0:	0134de63          	bge	s1,s3,800069bc <snprintf+0x12a>
    800069a4:	009b86b3          	add	a3,s7,s1
  *s = c;
    800069a8:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    800069ac:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    800069ae:	0785                	addi	a5,a5,1
    800069b0:	0007c703          	lbu	a4,0(a5)
    800069b4:	df29                	beqz	a4,8000690e <snprintf+0x7c>
    800069b6:	0685                	addi	a3,a3,1
    800069b8:	fe9998e3          	bne	s3,s1,800069a8 <snprintf+0x116>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    800069bc:	8526                	mv	a0,s1
    800069be:	70e6                	ld	ra,120(sp)
    800069c0:	7446                	ld	s0,112(sp)
    800069c2:	74a6                	ld	s1,104(sp)
    800069c4:	7906                	ld	s2,96(sp)
    800069c6:	69e6                	ld	s3,88(sp)
    800069c8:	6a46                	ld	s4,80(sp)
    800069ca:	6aa6                	ld	s5,72(sp)
    800069cc:	6b06                	ld	s6,64(sp)
    800069ce:	7be2                	ld	s7,56(sp)
    800069d0:	7c42                	ld	s8,48(sp)
    800069d2:	7ca2                	ld	s9,40(sp)
    800069d4:	7d02                	ld	s10,32(sp)
    800069d6:	6de2                	ld	s11,24(sp)
    800069d8:	614d                	addi	sp,sp,176
    800069da:	8082                	ret
        s = "(null)";
    800069dc:	00001797          	auipc	a5,0x1
    800069e0:	64478793          	addi	a5,a5,1604 # 80008020 <etext+0x20>
      for(; *s && off < sz; s++)
    800069e4:	876e                	mv	a4,s11
    800069e6:	bf6d                	j	800069a0 <snprintf+0x10e>
  *s = c;
    800069e8:	009b87b3          	add	a5,s7,s1
    800069ec:	01a78023          	sb	s10,0(a5)
      off += sputc(buf+off, '%');
    800069f0:	2485                	addiw	s1,s1,1
      break;
    800069f2:	bf31                	j	8000690e <snprintf+0x7c>
  *s = c;
    800069f4:	009b8733          	add	a4,s7,s1
    800069f8:	01a70023          	sb	s10,0(a4)
      off += sputc(buf+off, c);
    800069fc:	0014871b          	addiw	a4,s1,1
  *s = c;
    80006a00:	975e                	add	a4,a4,s7
    80006a02:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006a06:	2489                	addiw	s1,s1,2
      break;
    80006a08:	b719                	j	8000690e <snprintf+0x7c>
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
