
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	510080e7          	jalr	1296(ra) # 5520 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	4fe080e7          	jalr	1278(ra) # 5520 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	caa50513          	addi	a0,a0,-854 # 5ce8 <malloc+0x3d2>
      46:	00006097          	auipc	ra,0x6
      4a:	812080e7          	jalr	-2030(ra) # 5858 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	490080e7          	jalr	1168(ra) # 54e0 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	18078793          	addi	a5,a5,384 # 91d8 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	88868693          	addi	a3,a3,-1912 # b8e8 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	c8850513          	addi	a0,a0,-888 # 5d08 <malloc+0x3f2>
      88:	00005097          	auipc	ra,0x5
      8c:	7d0080e7          	jalr	2000(ra) # 5858 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	44e080e7          	jalr	1102(ra) # 54e0 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	c7850513          	addi	a0,a0,-904 # 5d20 <malloc+0x40a>
      b0:	00005097          	auipc	ra,0x5
      b4:	470080e7          	jalr	1136(ra) # 5520 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	44c080e7          	jalr	1100(ra) # 5508 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	c7a50513          	addi	a0,a0,-902 # 5d40 <malloc+0x42a>
      ce:	00005097          	auipc	ra,0x5
      d2:	452080e7          	jalr	1106(ra) # 5520 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	c4250513          	addi	a0,a0,-958 # 5d28 <malloc+0x412>
      ee:	00005097          	auipc	ra,0x5
      f2:	76a080e7          	jalr	1898(ra) # 5858 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	3e8080e7          	jalr	1000(ra) # 54e0 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	c4e50513          	addi	a0,a0,-946 # 5d50 <malloc+0x43a>
     10a:	00005097          	auipc	ra,0x5
     10e:	74e080e7          	jalr	1870(ra) # 5858 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	3cc080e7          	jalr	972(ra) # 54e0 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	c4c50513          	addi	a0,a0,-948 # 5d78 <malloc+0x462>
     134:	00005097          	auipc	ra,0x5
     138:	3fc080e7          	jalr	1020(ra) # 5530 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	c3850513          	addi	a0,a0,-968 # 5d78 <malloc+0x462>
     148:	00005097          	auipc	ra,0x5
     14c:	3d8080e7          	jalr	984(ra) # 5520 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	c3458593          	addi	a1,a1,-972 # 5d88 <malloc+0x472>
     15c:	00005097          	auipc	ra,0x5
     160:	3a4080e7          	jalr	932(ra) # 5500 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	c1050513          	addi	a0,a0,-1008 # 5d78 <malloc+0x462>
     170:	00005097          	auipc	ra,0x5
     174:	3b0080e7          	jalr	944(ra) # 5520 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	c1458593          	addi	a1,a1,-1004 # 5d90 <malloc+0x47a>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	37a080e7          	jalr	890(ra) # 5500 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	be450513          	addi	a0,a0,-1052 # 5d78 <malloc+0x462>
     19c:	00005097          	auipc	ra,0x5
     1a0:	394080e7          	jalr	916(ra) # 5530 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	362080e7          	jalr	866(ra) # 5508 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	358080e7          	jalr	856(ra) # 5508 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	bce50513          	addi	a0,a0,-1074 # 5d98 <malloc+0x482>
     1d2:	00005097          	auipc	ra,0x5
     1d6:	686080e7          	jalr	1670(ra) # 5858 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	304080e7          	jalr	772(ra) # 54e0 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	e44e                	sd	s3,8(sp)
     1f0:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f2:	00008797          	auipc	a5,0x8
     1f6:	ece78793          	addi	a5,a5,-306 # 80c0 <name>
     1fa:	06100713          	li	a4,97
     1fe:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     202:	00078123          	sb	zero,2(a5)
     206:	03000493          	li	s1,48
    name[1] = '0' + i;
     20a:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     20c:	06400993          	li	s3,100
    name[1] = '0' + i;
     210:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
     214:	20200593          	li	a1,514
     218:	854a                	mv	a0,s2
     21a:	00005097          	auipc	ra,0x5
     21e:	306080e7          	jalr	774(ra) # 5520 <open>
    close(fd);
     222:	00005097          	auipc	ra,0x5
     226:	2e6080e7          	jalr	742(ra) # 5508 <close>
  for(i = 0; i < N; i++){
     22a:	2485                	addiw	s1,s1,1
     22c:	0ff4f493          	andi	s1,s1,255
     230:	ff3490e3          	bne	s1,s3,210 <createtest+0x2c>
  name[0] = 'a';
     234:	00008797          	auipc	a5,0x8
     238:	e8c78793          	addi	a5,a5,-372 # 80c0 <name>
     23c:	06100713          	li	a4,97
     240:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     244:	00078123          	sb	zero,2(a5)
     248:	03000493          	li	s1,48
    name[1] = '0' + i;
     24c:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     24e:	06400993          	li	s3,100
    name[1] = '0' + i;
     252:	009900a3          	sb	s1,1(s2)
    unlink(name);
     256:	854a                	mv	a0,s2
     258:	00005097          	auipc	ra,0x5
     25c:	2d8080e7          	jalr	728(ra) # 5530 <unlink>
  for(i = 0; i < N; i++){
     260:	2485                	addiw	s1,s1,1
     262:	0ff4f493          	andi	s1,s1,255
     266:	ff3496e3          	bne	s1,s3,252 <createtest+0x6e>
}
     26a:	70a2                	ld	ra,40(sp)
     26c:	7402                	ld	s0,32(sp)
     26e:	64e2                	ld	s1,24(sp)
     270:	6942                	ld	s2,16(sp)
     272:	69a2                	ld	s3,8(sp)
     274:	6145                	addi	sp,sp,48
     276:	8082                	ret

0000000000000278 <bigwrite>:
{
     278:	715d                	addi	sp,sp,-80
     27a:	e486                	sd	ra,72(sp)
     27c:	e0a2                	sd	s0,64(sp)
     27e:	fc26                	sd	s1,56(sp)
     280:	f84a                	sd	s2,48(sp)
     282:	f44e                	sd	s3,40(sp)
     284:	f052                	sd	s4,32(sp)
     286:	ec56                	sd	s5,24(sp)
     288:	e85a                	sd	s6,16(sp)
     28a:	e45e                	sd	s7,8(sp)
     28c:	0880                	addi	s0,sp,80
     28e:	8baa                	mv	s7,a0
  unlink("bigwrite");
     290:	00006517          	auipc	a0,0x6
     294:	93050513          	addi	a0,a0,-1744 # 5bc0 <malloc+0x2aa>
     298:	00005097          	auipc	ra,0x5
     29c:	298080e7          	jalr	664(ra) # 5530 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a4:	00006a97          	auipc	s5,0x6
     2a8:	91ca8a93          	addi	s5,s5,-1764 # 5bc0 <malloc+0x2aa>
      int cc = write(fd, buf, sz);
     2ac:	0000ba17          	auipc	s4,0xb
     2b0:	63ca0a13          	addi	s4,s4,1596 # b8e8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2b4:	6b0d                	lui	s6,0x3
     2b6:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x3d7>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ba:	20200593          	li	a1,514
     2be:	8556                	mv	a0,s5
     2c0:	00005097          	auipc	ra,0x5
     2c4:	260080e7          	jalr	608(ra) # 5520 <open>
     2c8:	892a                	mv	s2,a0
    if(fd < 0){
     2ca:	04054d63          	bltz	a0,324 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ce:	8626                	mv	a2,s1
     2d0:	85d2                	mv	a1,s4
     2d2:	00005097          	auipc	ra,0x5
     2d6:	22e080e7          	jalr	558(ra) # 5500 <write>
     2da:	89aa                	mv	s3,a0
      if(cc != sz){
     2dc:	06a49463          	bne	s1,a0,344 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2e0:	8626                	mv	a2,s1
     2e2:	85d2                	mv	a1,s4
     2e4:	854a                	mv	a0,s2
     2e6:	00005097          	auipc	ra,0x5
     2ea:	21a080e7          	jalr	538(ra) # 5500 <write>
      if(cc != sz){
     2ee:	04951963          	bne	a0,s1,340 <bigwrite+0xc8>
    close(fd);
     2f2:	854a                	mv	a0,s2
     2f4:	00005097          	auipc	ra,0x5
     2f8:	214080e7          	jalr	532(ra) # 5508 <close>
    unlink("bigwrite");
     2fc:	8556                	mv	a0,s5
     2fe:	00005097          	auipc	ra,0x5
     302:	232080e7          	jalr	562(ra) # 5530 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     306:	1d74849b          	addiw	s1,s1,471
     30a:	fb6498e3          	bne	s1,s6,2ba <bigwrite+0x42>
}
     30e:	60a6                	ld	ra,72(sp)
     310:	6406                	ld	s0,64(sp)
     312:	74e2                	ld	s1,56(sp)
     314:	7942                	ld	s2,48(sp)
     316:	79a2                	ld	s3,40(sp)
     318:	7a02                	ld	s4,32(sp)
     31a:	6ae2                	ld	s5,24(sp)
     31c:	6b42                	ld	s6,16(sp)
     31e:	6ba2                	ld	s7,8(sp)
     320:	6161                	addi	sp,sp,80
     322:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     324:	85de                	mv	a1,s7
     326:	00006517          	auipc	a0,0x6
     32a:	a9a50513          	addi	a0,a0,-1382 # 5dc0 <malloc+0x4aa>
     32e:	00005097          	auipc	ra,0x5
     332:	52a080e7          	jalr	1322(ra) # 5858 <printf>
      exit(1);
     336:	4505                	li	a0,1
     338:	00005097          	auipc	ra,0x5
     33c:	1a8080e7          	jalr	424(ra) # 54e0 <exit>
     340:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     342:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     344:	86ce                	mv	a3,s3
     346:	8626                	mv	a2,s1
     348:	85de                	mv	a1,s7
     34a:	00006517          	auipc	a0,0x6
     34e:	a9650513          	addi	a0,a0,-1386 # 5de0 <malloc+0x4ca>
     352:	00005097          	auipc	ra,0x5
     356:	506080e7          	jalr	1286(ra) # 5858 <printf>
        exit(1);
     35a:	4505                	li	a0,1
     35c:	00005097          	auipc	ra,0x5
     360:	184080e7          	jalr	388(ra) # 54e0 <exit>

0000000000000364 <copyin>:
{
     364:	715d                	addi	sp,sp,-80
     366:	e486                	sd	ra,72(sp)
     368:	e0a2                	sd	s0,64(sp)
     36a:	fc26                	sd	s1,56(sp)
     36c:	f84a                	sd	s2,48(sp)
     36e:	f44e                	sd	s3,40(sp)
     370:	f052                	sd	s4,32(sp)
     372:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     374:	4785                	li	a5,1
     376:	07fe                	slli	a5,a5,0x1f
     378:	fcf43023          	sd	a5,-64(s0)
     37c:	57fd                	li	a5,-1
     37e:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     382:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     386:	00006a17          	auipc	s4,0x6
     38a:	a72a0a13          	addi	s4,s4,-1422 # 5df8 <malloc+0x4e2>
    uint64 addr = addrs[ai];
     38e:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     392:	20100593          	li	a1,513
     396:	8552                	mv	a0,s4
     398:	00005097          	auipc	ra,0x5
     39c:	188080e7          	jalr	392(ra) # 5520 <open>
     3a0:	84aa                	mv	s1,a0
    if(fd < 0){
     3a2:	08054863          	bltz	a0,432 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     3a6:	6609                	lui	a2,0x2
     3a8:	85ce                	mv	a1,s3
     3aa:	00005097          	auipc	ra,0x5
     3ae:	156080e7          	jalr	342(ra) # 5500 <write>
    if(n >= 0){
     3b2:	08055d63          	bgez	a0,44c <copyin+0xe8>
    close(fd);
     3b6:	8526                	mv	a0,s1
     3b8:	00005097          	auipc	ra,0x5
     3bc:	150080e7          	jalr	336(ra) # 5508 <close>
    unlink("copyin1");
     3c0:	8552                	mv	a0,s4
     3c2:	00005097          	auipc	ra,0x5
     3c6:	16e080e7          	jalr	366(ra) # 5530 <unlink>
    n = write(1, (char*)addr, 8192);
     3ca:	6609                	lui	a2,0x2
     3cc:	85ce                	mv	a1,s3
     3ce:	4505                	li	a0,1
     3d0:	00005097          	auipc	ra,0x5
     3d4:	130080e7          	jalr	304(ra) # 5500 <write>
    if(n > 0){
     3d8:	08a04963          	bgtz	a0,46a <copyin+0x106>
    if(pipe(fds) < 0){
     3dc:	fb840513          	addi	a0,s0,-72
     3e0:	00005097          	auipc	ra,0x5
     3e4:	110080e7          	jalr	272(ra) # 54f0 <pipe>
     3e8:	0a054063          	bltz	a0,488 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3ec:	6609                	lui	a2,0x2
     3ee:	85ce                	mv	a1,s3
     3f0:	fbc42503          	lw	a0,-68(s0)
     3f4:	00005097          	auipc	ra,0x5
     3f8:	10c080e7          	jalr	268(ra) # 5500 <write>
    if(n > 0){
     3fc:	0aa04363          	bgtz	a0,4a2 <copyin+0x13e>
    close(fds[0]);
     400:	fb842503          	lw	a0,-72(s0)
     404:	00005097          	auipc	ra,0x5
     408:	104080e7          	jalr	260(ra) # 5508 <close>
    close(fds[1]);
     40c:	fbc42503          	lw	a0,-68(s0)
     410:	00005097          	auipc	ra,0x5
     414:	0f8080e7          	jalr	248(ra) # 5508 <close>
  for(int ai = 0; ai < 2; ai++){
     418:	0921                	addi	s2,s2,8
     41a:	fd040793          	addi	a5,s0,-48
     41e:	f6f918e3          	bne	s2,a5,38e <copyin+0x2a>
}
     422:	60a6                	ld	ra,72(sp)
     424:	6406                	ld	s0,64(sp)
     426:	74e2                	ld	s1,56(sp)
     428:	7942                	ld	s2,48(sp)
     42a:	79a2                	ld	s3,40(sp)
     42c:	7a02                	ld	s4,32(sp)
     42e:	6161                	addi	sp,sp,80
     430:	8082                	ret
      printf("open(copyin1) failed\n");
     432:	00006517          	auipc	a0,0x6
     436:	9ce50513          	addi	a0,a0,-1586 # 5e00 <malloc+0x4ea>
     43a:	00005097          	auipc	ra,0x5
     43e:	41e080e7          	jalr	1054(ra) # 5858 <printf>
      exit(1);
     442:	4505                	li	a0,1
     444:	00005097          	auipc	ra,0x5
     448:	09c080e7          	jalr	156(ra) # 54e0 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     44c:	862a                	mv	a2,a0
     44e:	85ce                	mv	a1,s3
     450:	00006517          	auipc	a0,0x6
     454:	9c850513          	addi	a0,a0,-1592 # 5e18 <malloc+0x502>
     458:	00005097          	auipc	ra,0x5
     45c:	400080e7          	jalr	1024(ra) # 5858 <printf>
      exit(1);
     460:	4505                	li	a0,1
     462:	00005097          	auipc	ra,0x5
     466:	07e080e7          	jalr	126(ra) # 54e0 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     46a:	862a                	mv	a2,a0
     46c:	85ce                	mv	a1,s3
     46e:	00006517          	auipc	a0,0x6
     472:	9da50513          	addi	a0,a0,-1574 # 5e48 <malloc+0x532>
     476:	00005097          	auipc	ra,0x5
     47a:	3e2080e7          	jalr	994(ra) # 5858 <printf>
      exit(1);
     47e:	4505                	li	a0,1
     480:	00005097          	auipc	ra,0x5
     484:	060080e7          	jalr	96(ra) # 54e0 <exit>
      printf("pipe() failed\n");
     488:	00006517          	auipc	a0,0x6
     48c:	9f050513          	addi	a0,a0,-1552 # 5e78 <malloc+0x562>
     490:	00005097          	auipc	ra,0x5
     494:	3c8080e7          	jalr	968(ra) # 5858 <printf>
      exit(1);
     498:	4505                	li	a0,1
     49a:	00005097          	auipc	ra,0x5
     49e:	046080e7          	jalr	70(ra) # 54e0 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     4a2:	862a                	mv	a2,a0
     4a4:	85ce                	mv	a1,s3
     4a6:	00006517          	auipc	a0,0x6
     4aa:	9e250513          	addi	a0,a0,-1566 # 5e88 <malloc+0x572>
     4ae:	00005097          	auipc	ra,0x5
     4b2:	3aa080e7          	jalr	938(ra) # 5858 <printf>
      exit(1);
     4b6:	4505                	li	a0,1
     4b8:	00005097          	auipc	ra,0x5
     4bc:	028080e7          	jalr	40(ra) # 54e0 <exit>

00000000000004c0 <copyout>:
{
     4c0:	711d                	addi	sp,sp,-96
     4c2:	ec86                	sd	ra,88(sp)
     4c4:	e8a2                	sd	s0,80(sp)
     4c6:	e4a6                	sd	s1,72(sp)
     4c8:	e0ca                	sd	s2,64(sp)
     4ca:	fc4e                	sd	s3,56(sp)
     4cc:	f852                	sd	s4,48(sp)
     4ce:	f456                	sd	s5,40(sp)
     4d0:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4d2:	4785                	li	a5,1
     4d4:	07fe                	slli	a5,a5,0x1f
     4d6:	faf43823          	sd	a5,-80(s0)
     4da:	57fd                	li	a5,-1
     4dc:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4e0:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4e4:	00006a17          	auipc	s4,0x6
     4e8:	9d4a0a13          	addi	s4,s4,-1580 # 5eb8 <malloc+0x5a2>
    n = write(fds[1], "x", 1);
     4ec:	00006a97          	auipc	s5,0x6
     4f0:	8a4a8a93          	addi	s5,s5,-1884 # 5d90 <malloc+0x47a>
    uint64 addr = addrs[ai];
     4f4:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4f8:	4581                	li	a1,0
     4fa:	8552                	mv	a0,s4
     4fc:	00005097          	auipc	ra,0x5
     500:	024080e7          	jalr	36(ra) # 5520 <open>
     504:	84aa                	mv	s1,a0
    if(fd < 0){
     506:	08054663          	bltz	a0,592 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     50a:	6609                	lui	a2,0x2
     50c:	85ce                	mv	a1,s3
     50e:	00005097          	auipc	ra,0x5
     512:	fea080e7          	jalr	-22(ra) # 54f8 <read>
    if(n > 0){
     516:	08a04b63          	bgtz	a0,5ac <copyout+0xec>
    close(fd);
     51a:	8526                	mv	a0,s1
     51c:	00005097          	auipc	ra,0x5
     520:	fec080e7          	jalr	-20(ra) # 5508 <close>
    if(pipe(fds) < 0){
     524:	fa840513          	addi	a0,s0,-88
     528:	00005097          	auipc	ra,0x5
     52c:	fc8080e7          	jalr	-56(ra) # 54f0 <pipe>
     530:	08054d63          	bltz	a0,5ca <copyout+0x10a>
    n = write(fds[1], "x", 1);
     534:	4605                	li	a2,1
     536:	85d6                	mv	a1,s5
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00005097          	auipc	ra,0x5
     540:	fc4080e7          	jalr	-60(ra) # 5500 <write>
    if(n != 1){
     544:	4785                	li	a5,1
     546:	08f51f63          	bne	a0,a5,5e4 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     54a:	6609                	lui	a2,0x2
     54c:	85ce                	mv	a1,s3
     54e:	fa842503          	lw	a0,-88(s0)
     552:	00005097          	auipc	ra,0x5
     556:	fa6080e7          	jalr	-90(ra) # 54f8 <read>
    if(n > 0){
     55a:	0aa04263          	bgtz	a0,5fe <copyout+0x13e>
    close(fds[0]);
     55e:	fa842503          	lw	a0,-88(s0)
     562:	00005097          	auipc	ra,0x5
     566:	fa6080e7          	jalr	-90(ra) # 5508 <close>
    close(fds[1]);
     56a:	fac42503          	lw	a0,-84(s0)
     56e:	00005097          	auipc	ra,0x5
     572:	f9a080e7          	jalr	-102(ra) # 5508 <close>
  for(int ai = 0; ai < 2; ai++){
     576:	0921                	addi	s2,s2,8
     578:	fc040793          	addi	a5,s0,-64
     57c:	f6f91ce3          	bne	s2,a5,4f4 <copyout+0x34>
}
     580:	60e6                	ld	ra,88(sp)
     582:	6446                	ld	s0,80(sp)
     584:	64a6                	ld	s1,72(sp)
     586:	6906                	ld	s2,64(sp)
     588:	79e2                	ld	s3,56(sp)
     58a:	7a42                	ld	s4,48(sp)
     58c:	7aa2                	ld	s5,40(sp)
     58e:	6125                	addi	sp,sp,96
     590:	8082                	ret
      printf("open(README) failed\n");
     592:	00006517          	auipc	a0,0x6
     596:	92e50513          	addi	a0,a0,-1746 # 5ec0 <malloc+0x5aa>
     59a:	00005097          	auipc	ra,0x5
     59e:	2be080e7          	jalr	702(ra) # 5858 <printf>
      exit(1);
     5a2:	4505                	li	a0,1
     5a4:	00005097          	auipc	ra,0x5
     5a8:	f3c080e7          	jalr	-196(ra) # 54e0 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ac:	862a                	mv	a2,a0
     5ae:	85ce                	mv	a1,s3
     5b0:	00006517          	auipc	a0,0x6
     5b4:	92850513          	addi	a0,a0,-1752 # 5ed8 <malloc+0x5c2>
     5b8:	00005097          	auipc	ra,0x5
     5bc:	2a0080e7          	jalr	672(ra) # 5858 <printf>
      exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00005097          	auipc	ra,0x5
     5c6:	f1e080e7          	jalr	-226(ra) # 54e0 <exit>
      printf("pipe() failed\n");
     5ca:	00006517          	auipc	a0,0x6
     5ce:	8ae50513          	addi	a0,a0,-1874 # 5e78 <malloc+0x562>
     5d2:	00005097          	auipc	ra,0x5
     5d6:	286080e7          	jalr	646(ra) # 5858 <printf>
      exit(1);
     5da:	4505                	li	a0,1
     5dc:	00005097          	auipc	ra,0x5
     5e0:	f04080e7          	jalr	-252(ra) # 54e0 <exit>
      printf("pipe write failed\n");
     5e4:	00006517          	auipc	a0,0x6
     5e8:	92450513          	addi	a0,a0,-1756 # 5f08 <malloc+0x5f2>
     5ec:	00005097          	auipc	ra,0x5
     5f0:	26c080e7          	jalr	620(ra) # 5858 <printf>
      exit(1);
     5f4:	4505                	li	a0,1
     5f6:	00005097          	auipc	ra,0x5
     5fa:	eea080e7          	jalr	-278(ra) # 54e0 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5fe:	862a                	mv	a2,a0
     600:	85ce                	mv	a1,s3
     602:	00006517          	auipc	a0,0x6
     606:	91e50513          	addi	a0,a0,-1762 # 5f20 <malloc+0x60a>
     60a:	00005097          	auipc	ra,0x5
     60e:	24e080e7          	jalr	590(ra) # 5858 <printf>
      exit(1);
     612:	4505                	li	a0,1
     614:	00005097          	auipc	ra,0x5
     618:	ecc080e7          	jalr	-308(ra) # 54e0 <exit>

000000000000061c <truncate1>:
{
     61c:	711d                	addi	sp,sp,-96
     61e:	ec86                	sd	ra,88(sp)
     620:	e8a2                	sd	s0,80(sp)
     622:	e4a6                	sd	s1,72(sp)
     624:	e0ca                	sd	s2,64(sp)
     626:	fc4e                	sd	s3,56(sp)
     628:	f852                	sd	s4,48(sp)
     62a:	f456                	sd	s5,40(sp)
     62c:	1080                	addi	s0,sp,96
     62e:	8aaa                	mv	s5,a0
  unlink("truncfile");
     630:	00005517          	auipc	a0,0x5
     634:	74850513          	addi	a0,a0,1864 # 5d78 <malloc+0x462>
     638:	00005097          	auipc	ra,0x5
     63c:	ef8080e7          	jalr	-264(ra) # 5530 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     640:	60100593          	li	a1,1537
     644:	00005517          	auipc	a0,0x5
     648:	73450513          	addi	a0,a0,1844 # 5d78 <malloc+0x462>
     64c:	00005097          	auipc	ra,0x5
     650:	ed4080e7          	jalr	-300(ra) # 5520 <open>
     654:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     656:	4611                	li	a2,4
     658:	00005597          	auipc	a1,0x5
     65c:	73058593          	addi	a1,a1,1840 # 5d88 <malloc+0x472>
     660:	00005097          	auipc	ra,0x5
     664:	ea0080e7          	jalr	-352(ra) # 5500 <write>
  close(fd1);
     668:	8526                	mv	a0,s1
     66a:	00005097          	auipc	ra,0x5
     66e:	e9e080e7          	jalr	-354(ra) # 5508 <close>
  int fd2 = open("truncfile", O_RDONLY);
     672:	4581                	li	a1,0
     674:	00005517          	auipc	a0,0x5
     678:	70450513          	addi	a0,a0,1796 # 5d78 <malloc+0x462>
     67c:	00005097          	auipc	ra,0x5
     680:	ea4080e7          	jalr	-348(ra) # 5520 <open>
     684:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     686:	02000613          	li	a2,32
     68a:	fa040593          	addi	a1,s0,-96
     68e:	00005097          	auipc	ra,0x5
     692:	e6a080e7          	jalr	-406(ra) # 54f8 <read>
  if(n != 4){
     696:	4791                	li	a5,4
     698:	0cf51e63          	bne	a0,a5,774 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     69c:	40100593          	li	a1,1025
     6a0:	00005517          	auipc	a0,0x5
     6a4:	6d850513          	addi	a0,a0,1752 # 5d78 <malloc+0x462>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	e78080e7          	jalr	-392(ra) # 5520 <open>
     6b0:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6b2:	4581                	li	a1,0
     6b4:	00005517          	auipc	a0,0x5
     6b8:	6c450513          	addi	a0,a0,1732 # 5d78 <malloc+0x462>
     6bc:	00005097          	auipc	ra,0x5
     6c0:	e64080e7          	jalr	-412(ra) # 5520 <open>
     6c4:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	00005097          	auipc	ra,0x5
     6d2:	e2a080e7          	jalr	-470(ra) # 54f8 <read>
     6d6:	8a2a                	mv	s4,a0
  if(n != 0){
     6d8:	ed4d                	bnez	a0,792 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6da:	02000613          	li	a2,32
     6de:	fa040593          	addi	a1,s0,-96
     6e2:	8526                	mv	a0,s1
     6e4:	00005097          	auipc	ra,0x5
     6e8:	e14080e7          	jalr	-492(ra) # 54f8 <read>
     6ec:	8a2a                	mv	s4,a0
  if(n != 0){
     6ee:	e971                	bnez	a0,7c2 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6f0:	4619                	li	a2,6
     6f2:	00006597          	auipc	a1,0x6
     6f6:	8be58593          	addi	a1,a1,-1858 # 5fb0 <malloc+0x69a>
     6fa:	854e                	mv	a0,s3
     6fc:	00005097          	auipc	ra,0x5
     700:	e04080e7          	jalr	-508(ra) # 5500 <write>
  n = read(fd3, buf, sizeof(buf));
     704:	02000613          	li	a2,32
     708:	fa040593          	addi	a1,s0,-96
     70c:	854a                	mv	a0,s2
     70e:	00005097          	auipc	ra,0x5
     712:	dea080e7          	jalr	-534(ra) # 54f8 <read>
  if(n != 6){
     716:	4799                	li	a5,6
     718:	0cf51d63          	bne	a0,a5,7f2 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     71c:	02000613          	li	a2,32
     720:	fa040593          	addi	a1,s0,-96
     724:	8526                	mv	a0,s1
     726:	00005097          	auipc	ra,0x5
     72a:	dd2080e7          	jalr	-558(ra) # 54f8 <read>
  if(n != 2){
     72e:	4789                	li	a5,2
     730:	0ef51063          	bne	a0,a5,810 <truncate1+0x1f4>
  unlink("truncfile");
     734:	00005517          	auipc	a0,0x5
     738:	64450513          	addi	a0,a0,1604 # 5d78 <malloc+0x462>
     73c:	00005097          	auipc	ra,0x5
     740:	df4080e7          	jalr	-524(ra) # 5530 <unlink>
  close(fd1);
     744:	854e                	mv	a0,s3
     746:	00005097          	auipc	ra,0x5
     74a:	dc2080e7          	jalr	-574(ra) # 5508 <close>
  close(fd2);
     74e:	8526                	mv	a0,s1
     750:	00005097          	auipc	ra,0x5
     754:	db8080e7          	jalr	-584(ra) # 5508 <close>
  close(fd3);
     758:	854a                	mv	a0,s2
     75a:	00005097          	auipc	ra,0x5
     75e:	dae080e7          	jalr	-594(ra) # 5508 <close>
}
     762:	60e6                	ld	ra,88(sp)
     764:	6446                	ld	s0,80(sp)
     766:	64a6                	ld	s1,72(sp)
     768:	6906                	ld	s2,64(sp)
     76a:	79e2                	ld	s3,56(sp)
     76c:	7a42                	ld	s4,48(sp)
     76e:	7aa2                	ld	s5,40(sp)
     770:	6125                	addi	sp,sp,96
     772:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     774:	862a                	mv	a2,a0
     776:	85d6                	mv	a1,s5
     778:	00005517          	auipc	a0,0x5
     77c:	7d850513          	addi	a0,a0,2008 # 5f50 <malloc+0x63a>
     780:	00005097          	auipc	ra,0x5
     784:	0d8080e7          	jalr	216(ra) # 5858 <printf>
    exit(1);
     788:	4505                	li	a0,1
     78a:	00005097          	auipc	ra,0x5
     78e:	d56080e7          	jalr	-682(ra) # 54e0 <exit>
    printf("aaa fd3=%d\n", fd3);
     792:	85ca                	mv	a1,s2
     794:	00005517          	auipc	a0,0x5
     798:	7dc50513          	addi	a0,a0,2012 # 5f70 <malloc+0x65a>
     79c:	00005097          	auipc	ra,0x5
     7a0:	0bc080e7          	jalr	188(ra) # 5858 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7a4:	8652                	mv	a2,s4
     7a6:	85d6                	mv	a1,s5
     7a8:	00005517          	auipc	a0,0x5
     7ac:	7d850513          	addi	a0,a0,2008 # 5f80 <malloc+0x66a>
     7b0:	00005097          	auipc	ra,0x5
     7b4:	0a8080e7          	jalr	168(ra) # 5858 <printf>
    exit(1);
     7b8:	4505                	li	a0,1
     7ba:	00005097          	auipc	ra,0x5
     7be:	d26080e7          	jalr	-730(ra) # 54e0 <exit>
    printf("bbb fd2=%d\n", fd2);
     7c2:	85a6                	mv	a1,s1
     7c4:	00005517          	auipc	a0,0x5
     7c8:	7dc50513          	addi	a0,a0,2012 # 5fa0 <malloc+0x68a>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	08c080e7          	jalr	140(ra) # 5858 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7d4:	8652                	mv	a2,s4
     7d6:	85d6                	mv	a1,s5
     7d8:	00005517          	auipc	a0,0x5
     7dc:	7a850513          	addi	a0,a0,1960 # 5f80 <malloc+0x66a>
     7e0:	00005097          	auipc	ra,0x5
     7e4:	078080e7          	jalr	120(ra) # 5858 <printf>
    exit(1);
     7e8:	4505                	li	a0,1
     7ea:	00005097          	auipc	ra,0x5
     7ee:	cf6080e7          	jalr	-778(ra) # 54e0 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7f2:	862a                	mv	a2,a0
     7f4:	85d6                	mv	a1,s5
     7f6:	00005517          	auipc	a0,0x5
     7fa:	7c250513          	addi	a0,a0,1986 # 5fb8 <malloc+0x6a2>
     7fe:	00005097          	auipc	ra,0x5
     802:	05a080e7          	jalr	90(ra) # 5858 <printf>
    exit(1);
     806:	4505                	li	a0,1
     808:	00005097          	auipc	ra,0x5
     80c:	cd8080e7          	jalr	-808(ra) # 54e0 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     810:	862a                	mv	a2,a0
     812:	85d6                	mv	a1,s5
     814:	00005517          	auipc	a0,0x5
     818:	7c450513          	addi	a0,a0,1988 # 5fd8 <malloc+0x6c2>
     81c:	00005097          	auipc	ra,0x5
     820:	03c080e7          	jalr	60(ra) # 5858 <printf>
    exit(1);
     824:	4505                	li	a0,1
     826:	00005097          	auipc	ra,0x5
     82a:	cba080e7          	jalr	-838(ra) # 54e0 <exit>

000000000000082e <writetest>:
{
     82e:	7139                	addi	sp,sp,-64
     830:	fc06                	sd	ra,56(sp)
     832:	f822                	sd	s0,48(sp)
     834:	f426                	sd	s1,40(sp)
     836:	f04a                	sd	s2,32(sp)
     838:	ec4e                	sd	s3,24(sp)
     83a:	e852                	sd	s4,16(sp)
     83c:	e456                	sd	s5,8(sp)
     83e:	e05a                	sd	s6,0(sp)
     840:	0080                	addi	s0,sp,64
     842:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     844:	20200593          	li	a1,514
     848:	00005517          	auipc	a0,0x5
     84c:	7b050513          	addi	a0,a0,1968 # 5ff8 <malloc+0x6e2>
     850:	00005097          	auipc	ra,0x5
     854:	cd0080e7          	jalr	-816(ra) # 5520 <open>
  if(fd < 0){
     858:	0a054d63          	bltz	a0,912 <writetest+0xe4>
     85c:	892a                	mv	s2,a0
     85e:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	00005997          	auipc	s3,0x5
     864:	7c098993          	addi	s3,s3,1984 # 6020 <malloc+0x70a>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     868:	00005a97          	auipc	s5,0x5
     86c:	7f0a8a93          	addi	s5,s5,2032 # 6058 <malloc+0x742>
  for(i = 0; i < N; i++){
     870:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85ce                	mv	a1,s3
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	c86080e7          	jalr	-890(ra) # 5500 <write>
     882:	47a9                	li	a5,10
     884:	0af51563          	bne	a0,a5,92e <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     888:	4629                	li	a2,10
     88a:	85d6                	mv	a1,s5
     88c:	854a                	mv	a0,s2
     88e:	00005097          	auipc	ra,0x5
     892:	c72080e7          	jalr	-910(ra) # 5500 <write>
     896:	47a9                	li	a5,10
     898:	0af51a63          	bne	a0,a5,94c <writetest+0x11e>
  for(i = 0; i < N; i++){
     89c:	2485                	addiw	s1,s1,1
     89e:	fd449be3          	bne	s1,s4,874 <writetest+0x46>
  close(fd);
     8a2:	854a                	mv	a0,s2
     8a4:	00005097          	auipc	ra,0x5
     8a8:	c64080e7          	jalr	-924(ra) # 5508 <close>
  fd = open("small", O_RDONLY);
     8ac:	4581                	li	a1,0
     8ae:	00005517          	auipc	a0,0x5
     8b2:	74a50513          	addi	a0,a0,1866 # 5ff8 <malloc+0x6e2>
     8b6:	00005097          	auipc	ra,0x5
     8ba:	c6a080e7          	jalr	-918(ra) # 5520 <open>
     8be:	84aa                	mv	s1,a0
  if(fd < 0){
     8c0:	0a054563          	bltz	a0,96a <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8c4:	7d000613          	li	a2,2000
     8c8:	0000b597          	auipc	a1,0xb
     8cc:	02058593          	addi	a1,a1,32 # b8e8 <buf>
     8d0:	00005097          	auipc	ra,0x5
     8d4:	c28080e7          	jalr	-984(ra) # 54f8 <read>
  if(i != N*SZ*2){
     8d8:	7d000793          	li	a5,2000
     8dc:	0af51563          	bne	a0,a5,986 <writetest+0x158>
  close(fd);
     8e0:	8526                	mv	a0,s1
     8e2:	00005097          	auipc	ra,0x5
     8e6:	c26080e7          	jalr	-986(ra) # 5508 <close>
  if(unlink("small") < 0){
     8ea:	00005517          	auipc	a0,0x5
     8ee:	70e50513          	addi	a0,a0,1806 # 5ff8 <malloc+0x6e2>
     8f2:	00005097          	auipc	ra,0x5
     8f6:	c3e080e7          	jalr	-962(ra) # 5530 <unlink>
     8fa:	0a054463          	bltz	a0,9a2 <writetest+0x174>
}
     8fe:	70e2                	ld	ra,56(sp)
     900:	7442                	ld	s0,48(sp)
     902:	74a2                	ld	s1,40(sp)
     904:	7902                	ld	s2,32(sp)
     906:	69e2                	ld	s3,24(sp)
     908:	6a42                	ld	s4,16(sp)
     90a:	6aa2                	ld	s5,8(sp)
     90c:	6b02                	ld	s6,0(sp)
     90e:	6121                	addi	sp,sp,64
     910:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     912:	85da                	mv	a1,s6
     914:	00005517          	auipc	a0,0x5
     918:	6ec50513          	addi	a0,a0,1772 # 6000 <malloc+0x6ea>
     91c:	00005097          	auipc	ra,0x5
     920:	f3c080e7          	jalr	-196(ra) # 5858 <printf>
    exit(1);
     924:	4505                	li	a0,1
     926:	00005097          	auipc	ra,0x5
     92a:	bba080e7          	jalr	-1094(ra) # 54e0 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     92e:	8626                	mv	a2,s1
     930:	85da                	mv	a1,s6
     932:	00005517          	auipc	a0,0x5
     936:	6fe50513          	addi	a0,a0,1790 # 6030 <malloc+0x71a>
     93a:	00005097          	auipc	ra,0x5
     93e:	f1e080e7          	jalr	-226(ra) # 5858 <printf>
      exit(1);
     942:	4505                	li	a0,1
     944:	00005097          	auipc	ra,0x5
     948:	b9c080e7          	jalr	-1124(ra) # 54e0 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     94c:	8626                	mv	a2,s1
     94e:	85da                	mv	a1,s6
     950:	00005517          	auipc	a0,0x5
     954:	71850513          	addi	a0,a0,1816 # 6068 <malloc+0x752>
     958:	00005097          	auipc	ra,0x5
     95c:	f00080e7          	jalr	-256(ra) # 5858 <printf>
      exit(1);
     960:	4505                	li	a0,1
     962:	00005097          	auipc	ra,0x5
     966:	b7e080e7          	jalr	-1154(ra) # 54e0 <exit>
    printf("%s: error: open small failed!\n", s);
     96a:	85da                	mv	a1,s6
     96c:	00005517          	auipc	a0,0x5
     970:	72450513          	addi	a0,a0,1828 # 6090 <malloc+0x77a>
     974:	00005097          	auipc	ra,0x5
     978:	ee4080e7          	jalr	-284(ra) # 5858 <printf>
    exit(1);
     97c:	4505                	li	a0,1
     97e:	00005097          	auipc	ra,0x5
     982:	b62080e7          	jalr	-1182(ra) # 54e0 <exit>
    printf("%s: read failed\n", s);
     986:	85da                	mv	a1,s6
     988:	00005517          	auipc	a0,0x5
     98c:	72850513          	addi	a0,a0,1832 # 60b0 <malloc+0x79a>
     990:	00005097          	auipc	ra,0x5
     994:	ec8080e7          	jalr	-312(ra) # 5858 <printf>
    exit(1);
     998:	4505                	li	a0,1
     99a:	00005097          	auipc	ra,0x5
     99e:	b46080e7          	jalr	-1210(ra) # 54e0 <exit>
    printf("%s: unlink small failed\n", s);
     9a2:	85da                	mv	a1,s6
     9a4:	00005517          	auipc	a0,0x5
     9a8:	72450513          	addi	a0,a0,1828 # 60c8 <malloc+0x7b2>
     9ac:	00005097          	auipc	ra,0x5
     9b0:	eac080e7          	jalr	-340(ra) # 5858 <printf>
    exit(1);
     9b4:	4505                	li	a0,1
     9b6:	00005097          	auipc	ra,0x5
     9ba:	b2a080e7          	jalr	-1238(ra) # 54e0 <exit>

00000000000009be <writebig>:
{
     9be:	7139                	addi	sp,sp,-64
     9c0:	fc06                	sd	ra,56(sp)
     9c2:	f822                	sd	s0,48(sp)
     9c4:	f426                	sd	s1,40(sp)
     9c6:	f04a                	sd	s2,32(sp)
     9c8:	ec4e                	sd	s3,24(sp)
     9ca:	e852                	sd	s4,16(sp)
     9cc:	e456                	sd	s5,8(sp)
     9ce:	0080                	addi	s0,sp,64
     9d0:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d2:	20200593          	li	a1,514
     9d6:	00005517          	auipc	a0,0x5
     9da:	71250513          	addi	a0,a0,1810 # 60e8 <malloc+0x7d2>
     9de:	00005097          	auipc	ra,0x5
     9e2:	b42080e7          	jalr	-1214(ra) # 5520 <open>
     9e6:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e8:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9ea:	0000b917          	auipc	s2,0xb
     9ee:	efe90913          	addi	s2,s2,-258 # b8e8 <buf>
  for(i = 0; i < MAXFILE; i++){
     9f2:	10c00a13          	li	s4,268
  if(fd < 0){
     9f6:	06054c63          	bltz	a0,a6e <writebig+0xb0>
    ((int*)buf)[0] = i;
     9fa:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fe:	40000613          	li	a2,1024
     a02:	85ca                	mv	a1,s2
     a04:	854e                	mv	a0,s3
     a06:	00005097          	auipc	ra,0x5
     a0a:	afa080e7          	jalr	-1286(ra) # 5500 <write>
     a0e:	40000793          	li	a5,1024
     a12:	06f51c63          	bne	a0,a5,a8a <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a16:	2485                	addiw	s1,s1,1
     a18:	ff4491e3          	bne	s1,s4,9fa <writebig+0x3c>
  close(fd);
     a1c:	854e                	mv	a0,s3
     a1e:	00005097          	auipc	ra,0x5
     a22:	aea080e7          	jalr	-1302(ra) # 5508 <close>
  fd = open("big", O_RDONLY);
     a26:	4581                	li	a1,0
     a28:	00005517          	auipc	a0,0x5
     a2c:	6c050513          	addi	a0,a0,1728 # 60e8 <malloc+0x7d2>
     a30:	00005097          	auipc	ra,0x5
     a34:	af0080e7          	jalr	-1296(ra) # 5520 <open>
     a38:	89aa                	mv	s3,a0
  n = 0;
     a3a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a3c:	0000b917          	auipc	s2,0xb
     a40:	eac90913          	addi	s2,s2,-340 # b8e8 <buf>
  if(fd < 0){
     a44:	06054263          	bltz	a0,aa8 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a48:	40000613          	li	a2,1024
     a4c:	85ca                	mv	a1,s2
     a4e:	854e                	mv	a0,s3
     a50:	00005097          	auipc	ra,0x5
     a54:	aa8080e7          	jalr	-1368(ra) # 54f8 <read>
    if(i == 0){
     a58:	c535                	beqz	a0,ac4 <writebig+0x106>
    } else if(i != BSIZE){
     a5a:	40000793          	li	a5,1024
     a5e:	0af51f63          	bne	a0,a5,b1c <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a62:	00092683          	lw	a3,0(s2)
     a66:	0c969a63          	bne	a3,s1,b3a <writebig+0x17c>
    n++;
     a6a:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a6c:	bff1                	j	a48 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a6e:	85d6                	mv	a1,s5
     a70:	00005517          	auipc	a0,0x5
     a74:	68050513          	addi	a0,a0,1664 # 60f0 <malloc+0x7da>
     a78:	00005097          	auipc	ra,0x5
     a7c:	de0080e7          	jalr	-544(ra) # 5858 <printf>
    exit(1);
     a80:	4505                	li	a0,1
     a82:	00005097          	auipc	ra,0x5
     a86:	a5e080e7          	jalr	-1442(ra) # 54e0 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a8a:	8626                	mv	a2,s1
     a8c:	85d6                	mv	a1,s5
     a8e:	00005517          	auipc	a0,0x5
     a92:	68250513          	addi	a0,a0,1666 # 6110 <malloc+0x7fa>
     a96:	00005097          	auipc	ra,0x5
     a9a:	dc2080e7          	jalr	-574(ra) # 5858 <printf>
      exit(1);
     a9e:	4505                	li	a0,1
     aa0:	00005097          	auipc	ra,0x5
     aa4:	a40080e7          	jalr	-1472(ra) # 54e0 <exit>
    printf("%s: error: open big failed!\n", s);
     aa8:	85d6                	mv	a1,s5
     aaa:	00005517          	auipc	a0,0x5
     aae:	68e50513          	addi	a0,a0,1678 # 6138 <malloc+0x822>
     ab2:	00005097          	auipc	ra,0x5
     ab6:	da6080e7          	jalr	-602(ra) # 5858 <printf>
    exit(1);
     aba:	4505                	li	a0,1
     abc:	00005097          	auipc	ra,0x5
     ac0:	a24080e7          	jalr	-1500(ra) # 54e0 <exit>
      if(n == MAXFILE - 1){
     ac4:	10b00793          	li	a5,267
     ac8:	02f48a63          	beq	s1,a5,afc <writebig+0x13e>
  close(fd);
     acc:	854e                	mv	a0,s3
     ace:	00005097          	auipc	ra,0x5
     ad2:	a3a080e7          	jalr	-1478(ra) # 5508 <close>
  if(unlink("big") < 0){
     ad6:	00005517          	auipc	a0,0x5
     ada:	61250513          	addi	a0,a0,1554 # 60e8 <malloc+0x7d2>
     ade:	00005097          	auipc	ra,0x5
     ae2:	a52080e7          	jalr	-1454(ra) # 5530 <unlink>
     ae6:	06054963          	bltz	a0,b58 <writebig+0x19a>
}
     aea:	70e2                	ld	ra,56(sp)
     aec:	7442                	ld	s0,48(sp)
     aee:	74a2                	ld	s1,40(sp)
     af0:	7902                	ld	s2,32(sp)
     af2:	69e2                	ld	s3,24(sp)
     af4:	6a42                	ld	s4,16(sp)
     af6:	6aa2                	ld	s5,8(sp)
     af8:	6121                	addi	sp,sp,64
     afa:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     afc:	10b00613          	li	a2,267
     b00:	85d6                	mv	a1,s5
     b02:	00005517          	auipc	a0,0x5
     b06:	65650513          	addi	a0,a0,1622 # 6158 <malloc+0x842>
     b0a:	00005097          	auipc	ra,0x5
     b0e:	d4e080e7          	jalr	-690(ra) # 5858 <printf>
        exit(1);
     b12:	4505                	li	a0,1
     b14:	00005097          	auipc	ra,0x5
     b18:	9cc080e7          	jalr	-1588(ra) # 54e0 <exit>
      printf("%s: read failed %d\n", s, i);
     b1c:	862a                	mv	a2,a0
     b1e:	85d6                	mv	a1,s5
     b20:	00005517          	auipc	a0,0x5
     b24:	66050513          	addi	a0,a0,1632 # 6180 <malloc+0x86a>
     b28:	00005097          	auipc	ra,0x5
     b2c:	d30080e7          	jalr	-720(ra) # 5858 <printf>
      exit(1);
     b30:	4505                	li	a0,1
     b32:	00005097          	auipc	ra,0x5
     b36:	9ae080e7          	jalr	-1618(ra) # 54e0 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b3a:	8626                	mv	a2,s1
     b3c:	85d6                	mv	a1,s5
     b3e:	00005517          	auipc	a0,0x5
     b42:	65a50513          	addi	a0,a0,1626 # 6198 <malloc+0x882>
     b46:	00005097          	auipc	ra,0x5
     b4a:	d12080e7          	jalr	-750(ra) # 5858 <printf>
      exit(1);
     b4e:	4505                	li	a0,1
     b50:	00005097          	auipc	ra,0x5
     b54:	990080e7          	jalr	-1648(ra) # 54e0 <exit>
    printf("%s: unlink big failed\n", s);
     b58:	85d6                	mv	a1,s5
     b5a:	00005517          	auipc	a0,0x5
     b5e:	66650513          	addi	a0,a0,1638 # 61c0 <malloc+0x8aa>
     b62:	00005097          	auipc	ra,0x5
     b66:	cf6080e7          	jalr	-778(ra) # 5858 <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00005097          	auipc	ra,0x5
     b70:	974080e7          	jalr	-1676(ra) # 54e0 <exit>

0000000000000b74 <unlinkread>:
{
     b74:	7179                	addi	sp,sp,-48
     b76:	f406                	sd	ra,40(sp)
     b78:	f022                	sd	s0,32(sp)
     b7a:	ec26                	sd	s1,24(sp)
     b7c:	e84a                	sd	s2,16(sp)
     b7e:	e44e                	sd	s3,8(sp)
     b80:	1800                	addi	s0,sp,48
     b82:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b84:	20200593          	li	a1,514
     b88:	00005517          	auipc	a0,0x5
     b8c:	fc850513          	addi	a0,a0,-56 # 5b50 <malloc+0x23a>
     b90:	00005097          	auipc	ra,0x5
     b94:	990080e7          	jalr	-1648(ra) # 5520 <open>
  if(fd < 0){
     b98:	0e054563          	bltz	a0,c82 <unlinkread+0x10e>
     b9c:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b9e:	4615                	li	a2,5
     ba0:	00005597          	auipc	a1,0x5
     ba4:	65858593          	addi	a1,a1,1624 # 61f8 <malloc+0x8e2>
     ba8:	00005097          	auipc	ra,0x5
     bac:	958080e7          	jalr	-1704(ra) # 5500 <write>
  close(fd);
     bb0:	8526                	mv	a0,s1
     bb2:	00005097          	auipc	ra,0x5
     bb6:	956080e7          	jalr	-1706(ra) # 5508 <close>
  fd = open("unlinkread", O_RDWR);
     bba:	4589                	li	a1,2
     bbc:	00005517          	auipc	a0,0x5
     bc0:	f9450513          	addi	a0,a0,-108 # 5b50 <malloc+0x23a>
     bc4:	00005097          	auipc	ra,0x5
     bc8:	95c080e7          	jalr	-1700(ra) # 5520 <open>
     bcc:	84aa                	mv	s1,a0
  if(fd < 0){
     bce:	0c054863          	bltz	a0,c9e <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bd2:	00005517          	auipc	a0,0x5
     bd6:	f7e50513          	addi	a0,a0,-130 # 5b50 <malloc+0x23a>
     bda:	00005097          	auipc	ra,0x5
     bde:	956080e7          	jalr	-1706(ra) # 5530 <unlink>
     be2:	ed61                	bnez	a0,cba <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     be4:	20200593          	li	a1,514
     be8:	00005517          	auipc	a0,0x5
     bec:	f6850513          	addi	a0,a0,-152 # 5b50 <malloc+0x23a>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	930080e7          	jalr	-1744(ra) # 5520 <open>
     bf8:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     bfa:	460d                	li	a2,3
     bfc:	00005597          	auipc	a1,0x5
     c00:	64458593          	addi	a1,a1,1604 # 6240 <malloc+0x92a>
     c04:	00005097          	auipc	ra,0x5
     c08:	8fc080e7          	jalr	-1796(ra) # 5500 <write>
  close(fd1);
     c0c:	854a                	mv	a0,s2
     c0e:	00005097          	auipc	ra,0x5
     c12:	8fa080e7          	jalr	-1798(ra) # 5508 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c16:	660d                	lui	a2,0x3
     c18:	0000b597          	auipc	a1,0xb
     c1c:	cd058593          	addi	a1,a1,-816 # b8e8 <buf>
     c20:	8526                	mv	a0,s1
     c22:	00005097          	auipc	ra,0x5
     c26:	8d6080e7          	jalr	-1834(ra) # 54f8 <read>
     c2a:	4795                	li	a5,5
     c2c:	0af51563          	bne	a0,a5,cd6 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c30:	0000b717          	auipc	a4,0xb
     c34:	cb874703          	lbu	a4,-840(a4) # b8e8 <buf>
     c38:	06800793          	li	a5,104
     c3c:	0af71b63          	bne	a4,a5,cf2 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c40:	4629                	li	a2,10
     c42:	0000b597          	auipc	a1,0xb
     c46:	ca658593          	addi	a1,a1,-858 # b8e8 <buf>
     c4a:	8526                	mv	a0,s1
     c4c:	00005097          	auipc	ra,0x5
     c50:	8b4080e7          	jalr	-1868(ra) # 5500 <write>
     c54:	47a9                	li	a5,10
     c56:	0af51c63          	bne	a0,a5,d0e <unlinkread+0x19a>
  close(fd);
     c5a:	8526                	mv	a0,s1
     c5c:	00005097          	auipc	ra,0x5
     c60:	8ac080e7          	jalr	-1876(ra) # 5508 <close>
  unlink("unlinkread");
     c64:	00005517          	auipc	a0,0x5
     c68:	eec50513          	addi	a0,a0,-276 # 5b50 <malloc+0x23a>
     c6c:	00005097          	auipc	ra,0x5
     c70:	8c4080e7          	jalr	-1852(ra) # 5530 <unlink>
}
     c74:	70a2                	ld	ra,40(sp)
     c76:	7402                	ld	s0,32(sp)
     c78:	64e2                	ld	s1,24(sp)
     c7a:	6942                	ld	s2,16(sp)
     c7c:	69a2                	ld	s3,8(sp)
     c7e:	6145                	addi	sp,sp,48
     c80:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c82:	85ce                	mv	a1,s3
     c84:	00005517          	auipc	a0,0x5
     c88:	55450513          	addi	a0,a0,1364 # 61d8 <malloc+0x8c2>
     c8c:	00005097          	auipc	ra,0x5
     c90:	bcc080e7          	jalr	-1076(ra) # 5858 <printf>
    exit(1);
     c94:	4505                	li	a0,1
     c96:	00005097          	auipc	ra,0x5
     c9a:	84a080e7          	jalr	-1974(ra) # 54e0 <exit>
    printf("%s: open unlinkread failed\n", s);
     c9e:	85ce                	mv	a1,s3
     ca0:	00005517          	auipc	a0,0x5
     ca4:	56050513          	addi	a0,a0,1376 # 6200 <malloc+0x8ea>
     ca8:	00005097          	auipc	ra,0x5
     cac:	bb0080e7          	jalr	-1104(ra) # 5858 <printf>
    exit(1);
     cb0:	4505                	li	a0,1
     cb2:	00005097          	auipc	ra,0x5
     cb6:	82e080e7          	jalr	-2002(ra) # 54e0 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cba:	85ce                	mv	a1,s3
     cbc:	00005517          	auipc	a0,0x5
     cc0:	56450513          	addi	a0,a0,1380 # 6220 <malloc+0x90a>
     cc4:	00005097          	auipc	ra,0x5
     cc8:	b94080e7          	jalr	-1132(ra) # 5858 <printf>
    exit(1);
     ccc:	4505                	li	a0,1
     cce:	00005097          	auipc	ra,0x5
     cd2:	812080e7          	jalr	-2030(ra) # 54e0 <exit>
    printf("%s: unlinkread read failed", s);
     cd6:	85ce                	mv	a1,s3
     cd8:	00005517          	auipc	a0,0x5
     cdc:	57050513          	addi	a0,a0,1392 # 6248 <malloc+0x932>
     ce0:	00005097          	auipc	ra,0x5
     ce4:	b78080e7          	jalr	-1160(ra) # 5858 <printf>
    exit(1);
     ce8:	4505                	li	a0,1
     cea:	00004097          	auipc	ra,0x4
     cee:	7f6080e7          	jalr	2038(ra) # 54e0 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cf2:	85ce                	mv	a1,s3
     cf4:	00005517          	auipc	a0,0x5
     cf8:	57450513          	addi	a0,a0,1396 # 6268 <malloc+0x952>
     cfc:	00005097          	auipc	ra,0x5
     d00:	b5c080e7          	jalr	-1188(ra) # 5858 <printf>
    exit(1);
     d04:	4505                	li	a0,1
     d06:	00004097          	auipc	ra,0x4
     d0a:	7da080e7          	jalr	2010(ra) # 54e0 <exit>
    printf("%s: unlinkread write failed\n", s);
     d0e:	85ce                	mv	a1,s3
     d10:	00005517          	auipc	a0,0x5
     d14:	57850513          	addi	a0,a0,1400 # 6288 <malloc+0x972>
     d18:	00005097          	auipc	ra,0x5
     d1c:	b40080e7          	jalr	-1216(ra) # 5858 <printf>
    exit(1);
     d20:	4505                	li	a0,1
     d22:	00004097          	auipc	ra,0x4
     d26:	7be080e7          	jalr	1982(ra) # 54e0 <exit>

0000000000000d2a <linktest>:
{
     d2a:	1101                	addi	sp,sp,-32
     d2c:	ec06                	sd	ra,24(sp)
     d2e:	e822                	sd	s0,16(sp)
     d30:	e426                	sd	s1,8(sp)
     d32:	e04a                	sd	s2,0(sp)
     d34:	1000                	addi	s0,sp,32
     d36:	892a                	mv	s2,a0
  unlink("lf1");
     d38:	00005517          	auipc	a0,0x5
     d3c:	57050513          	addi	a0,a0,1392 # 62a8 <malloc+0x992>
     d40:	00004097          	auipc	ra,0x4
     d44:	7f0080e7          	jalr	2032(ra) # 5530 <unlink>
  unlink("lf2");
     d48:	00005517          	auipc	a0,0x5
     d4c:	56850513          	addi	a0,a0,1384 # 62b0 <malloc+0x99a>
     d50:	00004097          	auipc	ra,0x4
     d54:	7e0080e7          	jalr	2016(ra) # 5530 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d58:	20200593          	li	a1,514
     d5c:	00005517          	auipc	a0,0x5
     d60:	54c50513          	addi	a0,a0,1356 # 62a8 <malloc+0x992>
     d64:	00004097          	auipc	ra,0x4
     d68:	7bc080e7          	jalr	1980(ra) # 5520 <open>
  if(fd < 0){
     d6c:	10054763          	bltz	a0,e7a <linktest+0x150>
     d70:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d72:	4615                	li	a2,5
     d74:	00005597          	auipc	a1,0x5
     d78:	48458593          	addi	a1,a1,1156 # 61f8 <malloc+0x8e2>
     d7c:	00004097          	auipc	ra,0x4
     d80:	784080e7          	jalr	1924(ra) # 5500 <write>
     d84:	4795                	li	a5,5
     d86:	10f51863          	bne	a0,a5,e96 <linktest+0x16c>
  close(fd);
     d8a:	8526                	mv	a0,s1
     d8c:	00004097          	auipc	ra,0x4
     d90:	77c080e7          	jalr	1916(ra) # 5508 <close>
  if(link("lf1", "lf2") < 0){
     d94:	00005597          	auipc	a1,0x5
     d98:	51c58593          	addi	a1,a1,1308 # 62b0 <malloc+0x99a>
     d9c:	00005517          	auipc	a0,0x5
     da0:	50c50513          	addi	a0,a0,1292 # 62a8 <malloc+0x992>
     da4:	00004097          	auipc	ra,0x4
     da8:	79c080e7          	jalr	1948(ra) # 5540 <link>
     dac:	10054363          	bltz	a0,eb2 <linktest+0x188>
  unlink("lf1");
     db0:	00005517          	auipc	a0,0x5
     db4:	4f850513          	addi	a0,a0,1272 # 62a8 <malloc+0x992>
     db8:	00004097          	auipc	ra,0x4
     dbc:	778080e7          	jalr	1912(ra) # 5530 <unlink>
  if(open("lf1", 0) >= 0){
     dc0:	4581                	li	a1,0
     dc2:	00005517          	auipc	a0,0x5
     dc6:	4e650513          	addi	a0,a0,1254 # 62a8 <malloc+0x992>
     dca:	00004097          	auipc	ra,0x4
     dce:	756080e7          	jalr	1878(ra) # 5520 <open>
     dd2:	0e055e63          	bgez	a0,ece <linktest+0x1a4>
  fd = open("lf2", 0);
     dd6:	4581                	li	a1,0
     dd8:	00005517          	auipc	a0,0x5
     ddc:	4d850513          	addi	a0,a0,1240 # 62b0 <malloc+0x99a>
     de0:	00004097          	auipc	ra,0x4
     de4:	740080e7          	jalr	1856(ra) # 5520 <open>
     de8:	84aa                	mv	s1,a0
  if(fd < 0){
     dea:	10054063          	bltz	a0,eea <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dee:	660d                	lui	a2,0x3
     df0:	0000b597          	auipc	a1,0xb
     df4:	af858593          	addi	a1,a1,-1288 # b8e8 <buf>
     df8:	00004097          	auipc	ra,0x4
     dfc:	700080e7          	jalr	1792(ra) # 54f8 <read>
     e00:	4795                	li	a5,5
     e02:	10f51263          	bne	a0,a5,f06 <linktest+0x1dc>
  close(fd);
     e06:	8526                	mv	a0,s1
     e08:	00004097          	auipc	ra,0x4
     e0c:	700080e7          	jalr	1792(ra) # 5508 <close>
  if(link("lf2", "lf2") >= 0){
     e10:	00005597          	auipc	a1,0x5
     e14:	4a058593          	addi	a1,a1,1184 # 62b0 <malloc+0x99a>
     e18:	852e                	mv	a0,a1
     e1a:	00004097          	auipc	ra,0x4
     e1e:	726080e7          	jalr	1830(ra) # 5540 <link>
     e22:	10055063          	bgez	a0,f22 <linktest+0x1f8>
  unlink("lf2");
     e26:	00005517          	auipc	a0,0x5
     e2a:	48a50513          	addi	a0,a0,1162 # 62b0 <malloc+0x99a>
     e2e:	00004097          	auipc	ra,0x4
     e32:	702080e7          	jalr	1794(ra) # 5530 <unlink>
  if(link("lf2", "lf1") >= 0){
     e36:	00005597          	auipc	a1,0x5
     e3a:	47258593          	addi	a1,a1,1138 # 62a8 <malloc+0x992>
     e3e:	00005517          	auipc	a0,0x5
     e42:	47250513          	addi	a0,a0,1138 # 62b0 <malloc+0x99a>
     e46:	00004097          	auipc	ra,0x4
     e4a:	6fa080e7          	jalr	1786(ra) # 5540 <link>
     e4e:	0e055863          	bgez	a0,f3e <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e52:	00005597          	auipc	a1,0x5
     e56:	45658593          	addi	a1,a1,1110 # 62a8 <malloc+0x992>
     e5a:	00005517          	auipc	a0,0x5
     e5e:	55e50513          	addi	a0,a0,1374 # 63b8 <malloc+0xaa2>
     e62:	00004097          	auipc	ra,0x4
     e66:	6de080e7          	jalr	1758(ra) # 5540 <link>
     e6a:	0e055863          	bgez	a0,f5a <linktest+0x230>
}
     e6e:	60e2                	ld	ra,24(sp)
     e70:	6442                	ld	s0,16(sp)
     e72:	64a2                	ld	s1,8(sp)
     e74:	6902                	ld	s2,0(sp)
     e76:	6105                	addi	sp,sp,32
     e78:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e7a:	85ca                	mv	a1,s2
     e7c:	00005517          	auipc	a0,0x5
     e80:	43c50513          	addi	a0,a0,1084 # 62b8 <malloc+0x9a2>
     e84:	00005097          	auipc	ra,0x5
     e88:	9d4080e7          	jalr	-1580(ra) # 5858 <printf>
    exit(1);
     e8c:	4505                	li	a0,1
     e8e:	00004097          	auipc	ra,0x4
     e92:	652080e7          	jalr	1618(ra) # 54e0 <exit>
    printf("%s: write lf1 failed\n", s);
     e96:	85ca                	mv	a1,s2
     e98:	00005517          	auipc	a0,0x5
     e9c:	43850513          	addi	a0,a0,1080 # 62d0 <malloc+0x9ba>
     ea0:	00005097          	auipc	ra,0x5
     ea4:	9b8080e7          	jalr	-1608(ra) # 5858 <printf>
    exit(1);
     ea8:	4505                	li	a0,1
     eaa:	00004097          	auipc	ra,0x4
     eae:	636080e7          	jalr	1590(ra) # 54e0 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     eb2:	85ca                	mv	a1,s2
     eb4:	00005517          	auipc	a0,0x5
     eb8:	43450513          	addi	a0,a0,1076 # 62e8 <malloc+0x9d2>
     ebc:	00005097          	auipc	ra,0x5
     ec0:	99c080e7          	jalr	-1636(ra) # 5858 <printf>
    exit(1);
     ec4:	4505                	li	a0,1
     ec6:	00004097          	auipc	ra,0x4
     eca:	61a080e7          	jalr	1562(ra) # 54e0 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ece:	85ca                	mv	a1,s2
     ed0:	00005517          	auipc	a0,0x5
     ed4:	43850513          	addi	a0,a0,1080 # 6308 <malloc+0x9f2>
     ed8:	00005097          	auipc	ra,0x5
     edc:	980080e7          	jalr	-1664(ra) # 5858 <printf>
    exit(1);
     ee0:	4505                	li	a0,1
     ee2:	00004097          	auipc	ra,0x4
     ee6:	5fe080e7          	jalr	1534(ra) # 54e0 <exit>
    printf("%s: open lf2 failed\n", s);
     eea:	85ca                	mv	a1,s2
     eec:	00005517          	auipc	a0,0x5
     ef0:	44c50513          	addi	a0,a0,1100 # 6338 <malloc+0xa22>
     ef4:	00005097          	auipc	ra,0x5
     ef8:	964080e7          	jalr	-1692(ra) # 5858 <printf>
    exit(1);
     efc:	4505                	li	a0,1
     efe:	00004097          	auipc	ra,0x4
     f02:	5e2080e7          	jalr	1506(ra) # 54e0 <exit>
    printf("%s: read lf2 failed\n", s);
     f06:	85ca                	mv	a1,s2
     f08:	00005517          	auipc	a0,0x5
     f0c:	44850513          	addi	a0,a0,1096 # 6350 <malloc+0xa3a>
     f10:	00005097          	auipc	ra,0x5
     f14:	948080e7          	jalr	-1720(ra) # 5858 <printf>
    exit(1);
     f18:	4505                	li	a0,1
     f1a:	00004097          	auipc	ra,0x4
     f1e:	5c6080e7          	jalr	1478(ra) # 54e0 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f22:	85ca                	mv	a1,s2
     f24:	00005517          	auipc	a0,0x5
     f28:	44450513          	addi	a0,a0,1092 # 6368 <malloc+0xa52>
     f2c:	00005097          	auipc	ra,0x5
     f30:	92c080e7          	jalr	-1748(ra) # 5858 <printf>
    exit(1);
     f34:	4505                	li	a0,1
     f36:	00004097          	auipc	ra,0x4
     f3a:	5aa080e7          	jalr	1450(ra) # 54e0 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f3e:	85ca                	mv	a1,s2
     f40:	00005517          	auipc	a0,0x5
     f44:	45050513          	addi	a0,a0,1104 # 6390 <malloc+0xa7a>
     f48:	00005097          	auipc	ra,0x5
     f4c:	910080e7          	jalr	-1776(ra) # 5858 <printf>
    exit(1);
     f50:	4505                	li	a0,1
     f52:	00004097          	auipc	ra,0x4
     f56:	58e080e7          	jalr	1422(ra) # 54e0 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f5a:	85ca                	mv	a1,s2
     f5c:	00005517          	auipc	a0,0x5
     f60:	46450513          	addi	a0,a0,1124 # 63c0 <malloc+0xaaa>
     f64:	00005097          	auipc	ra,0x5
     f68:	8f4080e7          	jalr	-1804(ra) # 5858 <printf>
    exit(1);
     f6c:	4505                	li	a0,1
     f6e:	00004097          	auipc	ra,0x4
     f72:	572080e7          	jalr	1394(ra) # 54e0 <exit>

0000000000000f76 <bigdir>:
{
     f76:	715d                	addi	sp,sp,-80
     f78:	e486                	sd	ra,72(sp)
     f7a:	e0a2                	sd	s0,64(sp)
     f7c:	fc26                	sd	s1,56(sp)
     f7e:	f84a                	sd	s2,48(sp)
     f80:	f44e                	sd	s3,40(sp)
     f82:	f052                	sd	s4,32(sp)
     f84:	ec56                	sd	s5,24(sp)
     f86:	e85a                	sd	s6,16(sp)
     f88:	0880                	addi	s0,sp,80
     f8a:	89aa                	mv	s3,a0
  unlink("bd");
     f8c:	00005517          	auipc	a0,0x5
     f90:	45450513          	addi	a0,a0,1108 # 63e0 <malloc+0xaca>
     f94:	00004097          	auipc	ra,0x4
     f98:	59c080e7          	jalr	1436(ra) # 5530 <unlink>
  fd = open("bd", O_CREATE);
     f9c:	20000593          	li	a1,512
     fa0:	00005517          	auipc	a0,0x5
     fa4:	44050513          	addi	a0,a0,1088 # 63e0 <malloc+0xaca>
     fa8:	00004097          	auipc	ra,0x4
     fac:	578080e7          	jalr	1400(ra) # 5520 <open>
  if(fd < 0){
     fb0:	0c054963          	bltz	a0,1082 <bigdir+0x10c>
  close(fd);
     fb4:	00004097          	auipc	ra,0x4
     fb8:	554080e7          	jalr	1364(ra) # 5508 <close>
  for(i = 0; i < N; i++){
     fbc:	4901                	li	s2,0
    name[0] = 'x';
     fbe:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fc2:	00005a17          	auipc	s4,0x5
     fc6:	41ea0a13          	addi	s4,s4,1054 # 63e0 <malloc+0xaca>
  for(i = 0; i < N; i++){
     fca:	1f400b13          	li	s6,500
    name[0] = 'x';
     fce:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fd2:	41f9579b          	sraiw	a5,s2,0x1f
     fd6:	01a7d71b          	srliw	a4,a5,0x1a
     fda:	012707bb          	addw	a5,a4,s2
     fde:	4067d69b          	sraiw	a3,a5,0x6
     fe2:	0306869b          	addiw	a3,a3,48
     fe6:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fea:	03f7f793          	andi	a5,a5,63
     fee:	9f99                	subw	a5,a5,a4
     ff0:	0307879b          	addiw	a5,a5,48
     ff4:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     ff8:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     ffc:	fb040593          	addi	a1,s0,-80
    1000:	8552                	mv	a0,s4
    1002:	00004097          	auipc	ra,0x4
    1006:	53e080e7          	jalr	1342(ra) # 5540 <link>
    100a:	84aa                	mv	s1,a0
    100c:	e949                	bnez	a0,109e <bigdir+0x128>
  for(i = 0; i < N; i++){
    100e:	2905                	addiw	s2,s2,1
    1010:	fb691fe3          	bne	s2,s6,fce <bigdir+0x58>
  unlink("bd");
    1014:	00005517          	auipc	a0,0x5
    1018:	3cc50513          	addi	a0,a0,972 # 63e0 <malloc+0xaca>
    101c:	00004097          	auipc	ra,0x4
    1020:	514080e7          	jalr	1300(ra) # 5530 <unlink>
    name[0] = 'x';
    1024:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1028:	1f400a13          	li	s4,500
    name[0] = 'x';
    102c:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1030:	41f4d79b          	sraiw	a5,s1,0x1f
    1034:	01a7d71b          	srliw	a4,a5,0x1a
    1038:	009707bb          	addw	a5,a4,s1
    103c:	4067d69b          	sraiw	a3,a5,0x6
    1040:	0306869b          	addiw	a3,a3,48
    1044:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1048:	03f7f793          	andi	a5,a5,63
    104c:	9f99                	subw	a5,a5,a4
    104e:	0307879b          	addiw	a5,a5,48
    1052:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1056:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    105a:	fb040513          	addi	a0,s0,-80
    105e:	00004097          	auipc	ra,0x4
    1062:	4d2080e7          	jalr	1234(ra) # 5530 <unlink>
    1066:	ed21                	bnez	a0,10be <bigdir+0x148>
  for(i = 0; i < N; i++){
    1068:	2485                	addiw	s1,s1,1
    106a:	fd4491e3          	bne	s1,s4,102c <bigdir+0xb6>
}
    106e:	60a6                	ld	ra,72(sp)
    1070:	6406                	ld	s0,64(sp)
    1072:	74e2                	ld	s1,56(sp)
    1074:	7942                	ld	s2,48(sp)
    1076:	79a2                	ld	s3,40(sp)
    1078:	7a02                	ld	s4,32(sp)
    107a:	6ae2                	ld	s5,24(sp)
    107c:	6b42                	ld	s6,16(sp)
    107e:	6161                	addi	sp,sp,80
    1080:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1082:	85ce                	mv	a1,s3
    1084:	00005517          	auipc	a0,0x5
    1088:	36450513          	addi	a0,a0,868 # 63e8 <malloc+0xad2>
    108c:	00004097          	auipc	ra,0x4
    1090:	7cc080e7          	jalr	1996(ra) # 5858 <printf>
    exit(1);
    1094:	4505                	li	a0,1
    1096:	00004097          	auipc	ra,0x4
    109a:	44a080e7          	jalr	1098(ra) # 54e0 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    109e:	fb040613          	addi	a2,s0,-80
    10a2:	85ce                	mv	a1,s3
    10a4:	00005517          	auipc	a0,0x5
    10a8:	36450513          	addi	a0,a0,868 # 6408 <malloc+0xaf2>
    10ac:	00004097          	auipc	ra,0x4
    10b0:	7ac080e7          	jalr	1964(ra) # 5858 <printf>
      exit(1);
    10b4:	4505                	li	a0,1
    10b6:	00004097          	auipc	ra,0x4
    10ba:	42a080e7          	jalr	1066(ra) # 54e0 <exit>
      printf("%s: bigdir unlink failed", s);
    10be:	85ce                	mv	a1,s3
    10c0:	00005517          	auipc	a0,0x5
    10c4:	36850513          	addi	a0,a0,872 # 6428 <malloc+0xb12>
    10c8:	00004097          	auipc	ra,0x4
    10cc:	790080e7          	jalr	1936(ra) # 5858 <printf>
      exit(1);
    10d0:	4505                	li	a0,1
    10d2:	00004097          	auipc	ra,0x4
    10d6:	40e080e7          	jalr	1038(ra) # 54e0 <exit>

00000000000010da <validatetest>:
{
    10da:	7139                	addi	sp,sp,-64
    10dc:	fc06                	sd	ra,56(sp)
    10de:	f822                	sd	s0,48(sp)
    10e0:	f426                	sd	s1,40(sp)
    10e2:	f04a                	sd	s2,32(sp)
    10e4:	ec4e                	sd	s3,24(sp)
    10e6:	e852                	sd	s4,16(sp)
    10e8:	e456                	sd	s5,8(sp)
    10ea:	e05a                	sd	s6,0(sp)
    10ec:	0080                	addi	s0,sp,64
    10ee:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10f0:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10f2:	00005997          	auipc	s3,0x5
    10f6:	35698993          	addi	s3,s3,854 # 6448 <malloc+0xb32>
    10fa:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fc:	6a85                	lui	s5,0x1
    10fe:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1102:	85a6                	mv	a1,s1
    1104:	854e                	mv	a0,s3
    1106:	00004097          	auipc	ra,0x4
    110a:	43a080e7          	jalr	1082(ra) # 5540 <link>
    110e:	01251f63          	bne	a0,s2,112c <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1112:	94d6                	add	s1,s1,s5
    1114:	ff4497e3          	bne	s1,s4,1102 <validatetest+0x28>
}
    1118:	70e2                	ld	ra,56(sp)
    111a:	7442                	ld	s0,48(sp)
    111c:	74a2                	ld	s1,40(sp)
    111e:	7902                	ld	s2,32(sp)
    1120:	69e2                	ld	s3,24(sp)
    1122:	6a42                	ld	s4,16(sp)
    1124:	6aa2                	ld	s5,8(sp)
    1126:	6b02                	ld	s6,0(sp)
    1128:	6121                	addi	sp,sp,64
    112a:	8082                	ret
      printf("%s: link should not succeed\n", s);
    112c:	85da                	mv	a1,s6
    112e:	00005517          	auipc	a0,0x5
    1132:	32a50513          	addi	a0,a0,810 # 6458 <malloc+0xb42>
    1136:	00004097          	auipc	ra,0x4
    113a:	722080e7          	jalr	1826(ra) # 5858 <printf>
      exit(1);
    113e:	4505                	li	a0,1
    1140:	00004097          	auipc	ra,0x4
    1144:	3a0080e7          	jalr	928(ra) # 54e0 <exit>

0000000000001148 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1148:	7179                	addi	sp,sp,-48
    114a:	f406                	sd	ra,40(sp)
    114c:	f022                	sd	s0,32(sp)
    114e:	ec26                	sd	s1,24(sp)
    1150:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1152:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1156:	00007497          	auipc	s1,0x7
    115a:	f5a4b483          	ld	s1,-166(s1) # 80b0 <__SDATA_BEGIN__>
    115e:	fd840593          	addi	a1,s0,-40
    1162:	8526                	mv	a0,s1
    1164:	00004097          	auipc	ra,0x4
    1168:	3b4080e7          	jalr	948(ra) # 5518 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    116c:	8526                	mv	a0,s1
    116e:	00004097          	auipc	ra,0x4
    1172:	382080e7          	jalr	898(ra) # 54f0 <pipe>

  exit(0);
    1176:	4501                	li	a0,0
    1178:	00004097          	auipc	ra,0x4
    117c:	368080e7          	jalr	872(ra) # 54e0 <exit>

0000000000001180 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1180:	7139                	addi	sp,sp,-64
    1182:	fc06                	sd	ra,56(sp)
    1184:	f822                	sd	s0,48(sp)
    1186:	f426                	sd	s1,40(sp)
    1188:	f04a                	sd	s2,32(sp)
    118a:	ec4e                	sd	s3,24(sp)
    118c:	0080                	addi	s0,sp,64
    118e:	64b1                	lui	s1,0xc
    1190:	35048493          	addi	s1,s1,848 # c350 <buf+0xa68>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1194:	597d                	li	s2,-1
    1196:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    119a:	00005997          	auipc	s3,0x5
    119e:	b8698993          	addi	s3,s3,-1146 # 5d20 <malloc+0x40a>
    argv[0] = (char*)0xffffffff;
    11a2:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    11a6:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    11aa:	fc040593          	addi	a1,s0,-64
    11ae:	854e                	mv	a0,s3
    11b0:	00004097          	auipc	ra,0x4
    11b4:	368080e7          	jalr	872(ra) # 5518 <exec>
  for(int i = 0; i < 50000; i++){
    11b8:	34fd                	addiw	s1,s1,-1
    11ba:	f4e5                	bnez	s1,11a2 <badarg+0x22>
  }
  
  exit(0);
    11bc:	4501                	li	a0,0
    11be:	00004097          	auipc	ra,0x4
    11c2:	322080e7          	jalr	802(ra) # 54e0 <exit>

00000000000011c6 <copyinstr2>:
{
    11c6:	7155                	addi	sp,sp,-208
    11c8:	e586                	sd	ra,200(sp)
    11ca:	e1a2                	sd	s0,192(sp)
    11cc:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ce:	f6840793          	addi	a5,s0,-152
    11d2:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11d6:	07800713          	li	a4,120
    11da:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11de:	0785                	addi	a5,a5,1
    11e0:	fed79de3          	bne	a5,a3,11da <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11e4:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11e8:	f6840513          	addi	a0,s0,-152
    11ec:	00004097          	auipc	ra,0x4
    11f0:	344080e7          	jalr	836(ra) # 5530 <unlink>
  if(ret != -1){
    11f4:	57fd                	li	a5,-1
    11f6:	0ef51063          	bne	a0,a5,12d6 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11fa:	20100593          	li	a1,513
    11fe:	f6840513          	addi	a0,s0,-152
    1202:	00004097          	auipc	ra,0x4
    1206:	31e080e7          	jalr	798(ra) # 5520 <open>
  if(fd != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51563          	bne	a0,a5,12f6 <copyinstr2+0x130>
  ret = link(b, b);
    1210:	f6840593          	addi	a1,s0,-152
    1214:	852e                	mv	a0,a1
    1216:	00004097          	auipc	ra,0x4
    121a:	32a080e7          	jalr	810(ra) # 5540 <link>
  if(ret != -1){
    121e:	57fd                	li	a5,-1
    1220:	0ef51b63          	bne	a0,a5,1316 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1224:	00006797          	auipc	a5,0x6
    1228:	3a478793          	addi	a5,a5,932 # 75c8 <malloc+0x1cb2>
    122c:	f4f43c23          	sd	a5,-168(s0)
    1230:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1234:	f5840593          	addi	a1,s0,-168
    1238:	f6840513          	addi	a0,s0,-152
    123c:	00004097          	auipc	ra,0x4
    1240:	2dc080e7          	jalr	732(ra) # 5518 <exec>
  if(ret != -1){
    1244:	57fd                	li	a5,-1
    1246:	0ef51963          	bne	a0,a5,1338 <copyinstr2+0x172>
  int pid = fork();
    124a:	00004097          	auipc	ra,0x4
    124e:	28e080e7          	jalr	654(ra) # 54d8 <fork>
  if(pid < 0){
    1252:	10054363          	bltz	a0,1358 <copyinstr2+0x192>
  if(pid == 0){
    1256:	12051463          	bnez	a0,137e <copyinstr2+0x1b8>
    125a:	00007797          	auipc	a5,0x7
    125e:	f7678793          	addi	a5,a5,-138 # 81d0 <big.1265>
    1262:	00008697          	auipc	a3,0x8
    1266:	f6e68693          	addi	a3,a3,-146 # 91d0 <__global_pointer$+0x920>
      big[i] = 'x';
    126a:	07800713          	li	a4,120
    126e:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1272:	0785                	addi	a5,a5,1
    1274:	fed79de3          	bne	a5,a3,126e <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1278:	00008797          	auipc	a5,0x8
    127c:	f4078c23          	sb	zero,-168(a5) # 91d0 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1280:	00007797          	auipc	a5,0x7
    1284:	a8078793          	addi	a5,a5,-1408 # 7d00 <malloc+0x23ea>
    1288:	6390                	ld	a2,0(a5)
    128a:	6794                	ld	a3,8(a5)
    128c:	6b98                	ld	a4,16(a5)
    128e:	6f9c                	ld	a5,24(a5)
    1290:	f2c43823          	sd	a2,-208(s0)
    1294:	f2d43c23          	sd	a3,-200(s0)
    1298:	f4e43023          	sd	a4,-192(s0)
    129c:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    12a0:	f3040593          	addi	a1,s0,-208
    12a4:	00005517          	auipc	a0,0x5
    12a8:	a7c50513          	addi	a0,a0,-1412 # 5d20 <malloc+0x40a>
    12ac:	00004097          	auipc	ra,0x4
    12b0:	26c080e7          	jalr	620(ra) # 5518 <exec>
    if(ret != -1){
    12b4:	57fd                	li	a5,-1
    12b6:	0af50e63          	beq	a0,a5,1372 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12ba:	55fd                	li	a1,-1
    12bc:	00005517          	auipc	a0,0x5
    12c0:	24450513          	addi	a0,a0,580 # 6500 <malloc+0xbea>
    12c4:	00004097          	auipc	ra,0x4
    12c8:	594080e7          	jalr	1428(ra) # 5858 <printf>
      exit(1);
    12cc:	4505                	li	a0,1
    12ce:	00004097          	auipc	ra,0x4
    12d2:	212080e7          	jalr	530(ra) # 54e0 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12d6:	862a                	mv	a2,a0
    12d8:	f6840593          	addi	a1,s0,-152
    12dc:	00005517          	auipc	a0,0x5
    12e0:	19c50513          	addi	a0,a0,412 # 6478 <malloc+0xb62>
    12e4:	00004097          	auipc	ra,0x4
    12e8:	574080e7          	jalr	1396(ra) # 5858 <printf>
    exit(1);
    12ec:	4505                	li	a0,1
    12ee:	00004097          	auipc	ra,0x4
    12f2:	1f2080e7          	jalr	498(ra) # 54e0 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12f6:	862a                	mv	a2,a0
    12f8:	f6840593          	addi	a1,s0,-152
    12fc:	00005517          	auipc	a0,0x5
    1300:	19c50513          	addi	a0,a0,412 # 6498 <malloc+0xb82>
    1304:	00004097          	auipc	ra,0x4
    1308:	554080e7          	jalr	1364(ra) # 5858 <printf>
    exit(1);
    130c:	4505                	li	a0,1
    130e:	00004097          	auipc	ra,0x4
    1312:	1d2080e7          	jalr	466(ra) # 54e0 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1316:	86aa                	mv	a3,a0
    1318:	f6840613          	addi	a2,s0,-152
    131c:	85b2                	mv	a1,a2
    131e:	00005517          	auipc	a0,0x5
    1322:	19a50513          	addi	a0,a0,410 # 64b8 <malloc+0xba2>
    1326:	00004097          	auipc	ra,0x4
    132a:	532080e7          	jalr	1330(ra) # 5858 <printf>
    exit(1);
    132e:	4505                	li	a0,1
    1330:	00004097          	auipc	ra,0x4
    1334:	1b0080e7          	jalr	432(ra) # 54e0 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1338:	567d                	li	a2,-1
    133a:	f6840593          	addi	a1,s0,-152
    133e:	00005517          	auipc	a0,0x5
    1342:	1a250513          	addi	a0,a0,418 # 64e0 <malloc+0xbca>
    1346:	00004097          	auipc	ra,0x4
    134a:	512080e7          	jalr	1298(ra) # 5858 <printf>
    exit(1);
    134e:	4505                	li	a0,1
    1350:	00004097          	auipc	ra,0x4
    1354:	190080e7          	jalr	400(ra) # 54e0 <exit>
    printf("fork failed\n");
    1358:	00005517          	auipc	a0,0x5
    135c:	5d050513          	addi	a0,a0,1488 # 6928 <malloc+0x1012>
    1360:	00004097          	auipc	ra,0x4
    1364:	4f8080e7          	jalr	1272(ra) # 5858 <printf>
    exit(1);
    1368:	4505                	li	a0,1
    136a:	00004097          	auipc	ra,0x4
    136e:	176080e7          	jalr	374(ra) # 54e0 <exit>
    exit(747); // OK
    1372:	2eb00513          	li	a0,747
    1376:	00004097          	auipc	ra,0x4
    137a:	16a080e7          	jalr	362(ra) # 54e0 <exit>
  int st = 0;
    137e:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1382:	f5440513          	addi	a0,s0,-172
    1386:	00004097          	auipc	ra,0x4
    138a:	162080e7          	jalr	354(ra) # 54e8 <wait>
  if(st != 747){
    138e:	f5442703          	lw	a4,-172(s0)
    1392:	2eb00793          	li	a5,747
    1396:	00f71663          	bne	a4,a5,13a2 <copyinstr2+0x1dc>
}
    139a:	60ae                	ld	ra,200(sp)
    139c:	640e                	ld	s0,192(sp)
    139e:	6169                	addi	sp,sp,208
    13a0:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    13a2:	00005517          	auipc	a0,0x5
    13a6:	18650513          	addi	a0,a0,390 # 6528 <malloc+0xc12>
    13aa:	00004097          	auipc	ra,0x4
    13ae:	4ae080e7          	jalr	1198(ra) # 5858 <printf>
    exit(1);
    13b2:	4505                	li	a0,1
    13b4:	00004097          	auipc	ra,0x4
    13b8:	12c080e7          	jalr	300(ra) # 54e0 <exit>

00000000000013bc <truncate3>:
{
    13bc:	7159                	addi	sp,sp,-112
    13be:	f486                	sd	ra,104(sp)
    13c0:	f0a2                	sd	s0,96(sp)
    13c2:	eca6                	sd	s1,88(sp)
    13c4:	e8ca                	sd	s2,80(sp)
    13c6:	e4ce                	sd	s3,72(sp)
    13c8:	e0d2                	sd	s4,64(sp)
    13ca:	fc56                	sd	s5,56(sp)
    13cc:	1880                	addi	s0,sp,112
    13ce:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13d0:	60100593          	li	a1,1537
    13d4:	00005517          	auipc	a0,0x5
    13d8:	9a450513          	addi	a0,a0,-1628 # 5d78 <malloc+0x462>
    13dc:	00004097          	auipc	ra,0x4
    13e0:	144080e7          	jalr	324(ra) # 5520 <open>
    13e4:	00004097          	auipc	ra,0x4
    13e8:	124080e7          	jalr	292(ra) # 5508 <close>
  pid = fork();
    13ec:	00004097          	auipc	ra,0x4
    13f0:	0ec080e7          	jalr	236(ra) # 54d8 <fork>
  if(pid < 0){
    13f4:	08054063          	bltz	a0,1474 <truncate3+0xb8>
  if(pid == 0){
    13f8:	e969                	bnez	a0,14ca <truncate3+0x10e>
    13fa:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13fe:	00005a17          	auipc	s4,0x5
    1402:	97aa0a13          	addi	s4,s4,-1670 # 5d78 <malloc+0x462>
      int n = write(fd, "1234567890", 10);
    1406:	00005a97          	auipc	s5,0x5
    140a:	182a8a93          	addi	s5,s5,386 # 6588 <malloc+0xc72>
      int fd = open("truncfile", O_WRONLY);
    140e:	4585                	li	a1,1
    1410:	8552                	mv	a0,s4
    1412:	00004097          	auipc	ra,0x4
    1416:	10e080e7          	jalr	270(ra) # 5520 <open>
    141a:	84aa                	mv	s1,a0
      if(fd < 0){
    141c:	06054a63          	bltz	a0,1490 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1420:	4629                	li	a2,10
    1422:	85d6                	mv	a1,s5
    1424:	00004097          	auipc	ra,0x4
    1428:	0dc080e7          	jalr	220(ra) # 5500 <write>
      if(n != 10){
    142c:	47a9                	li	a5,10
    142e:	06f51f63          	bne	a0,a5,14ac <truncate3+0xf0>
      close(fd);
    1432:	8526                	mv	a0,s1
    1434:	00004097          	auipc	ra,0x4
    1438:	0d4080e7          	jalr	212(ra) # 5508 <close>
      fd = open("truncfile", O_RDONLY);
    143c:	4581                	li	a1,0
    143e:	8552                	mv	a0,s4
    1440:	00004097          	auipc	ra,0x4
    1444:	0e0080e7          	jalr	224(ra) # 5520 <open>
    1448:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    144a:	02000613          	li	a2,32
    144e:	f9840593          	addi	a1,s0,-104
    1452:	00004097          	auipc	ra,0x4
    1456:	0a6080e7          	jalr	166(ra) # 54f8 <read>
      close(fd);
    145a:	8526                	mv	a0,s1
    145c:	00004097          	auipc	ra,0x4
    1460:	0ac080e7          	jalr	172(ra) # 5508 <close>
    for(int i = 0; i < 100; i++){
    1464:	39fd                	addiw	s3,s3,-1
    1466:	fa0994e3          	bnez	s3,140e <truncate3+0x52>
    exit(0);
    146a:	4501                	li	a0,0
    146c:	00004097          	auipc	ra,0x4
    1470:	074080e7          	jalr	116(ra) # 54e0 <exit>
    printf("%s: fork failed\n", s);
    1474:	85ca                	mv	a1,s2
    1476:	00005517          	auipc	a0,0x5
    147a:	0e250513          	addi	a0,a0,226 # 6558 <malloc+0xc42>
    147e:	00004097          	auipc	ra,0x4
    1482:	3da080e7          	jalr	986(ra) # 5858 <printf>
    exit(1);
    1486:	4505                	li	a0,1
    1488:	00004097          	auipc	ra,0x4
    148c:	058080e7          	jalr	88(ra) # 54e0 <exit>
        printf("%s: open failed\n", s);
    1490:	85ca                	mv	a1,s2
    1492:	00005517          	auipc	a0,0x5
    1496:	0de50513          	addi	a0,a0,222 # 6570 <malloc+0xc5a>
    149a:	00004097          	auipc	ra,0x4
    149e:	3be080e7          	jalr	958(ra) # 5858 <printf>
        exit(1);
    14a2:	4505                	li	a0,1
    14a4:	00004097          	auipc	ra,0x4
    14a8:	03c080e7          	jalr	60(ra) # 54e0 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14ac:	862a                	mv	a2,a0
    14ae:	85ca                	mv	a1,s2
    14b0:	00005517          	auipc	a0,0x5
    14b4:	0e850513          	addi	a0,a0,232 # 6598 <malloc+0xc82>
    14b8:	00004097          	auipc	ra,0x4
    14bc:	3a0080e7          	jalr	928(ra) # 5858 <printf>
        exit(1);
    14c0:	4505                	li	a0,1
    14c2:	00004097          	auipc	ra,0x4
    14c6:	01e080e7          	jalr	30(ra) # 54e0 <exit>
    14ca:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ce:	00005a17          	auipc	s4,0x5
    14d2:	8aaa0a13          	addi	s4,s4,-1878 # 5d78 <malloc+0x462>
    int n = write(fd, "xxx", 3);
    14d6:	00005a97          	auipc	s5,0x5
    14da:	0e2a8a93          	addi	s5,s5,226 # 65b8 <malloc+0xca2>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14de:	60100593          	li	a1,1537
    14e2:	8552                	mv	a0,s4
    14e4:	00004097          	auipc	ra,0x4
    14e8:	03c080e7          	jalr	60(ra) # 5520 <open>
    14ec:	84aa                	mv	s1,a0
    if(fd < 0){
    14ee:	04054763          	bltz	a0,153c <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14f2:	460d                	li	a2,3
    14f4:	85d6                	mv	a1,s5
    14f6:	00004097          	auipc	ra,0x4
    14fa:	00a080e7          	jalr	10(ra) # 5500 <write>
    if(n != 3){
    14fe:	478d                	li	a5,3
    1500:	04f51c63          	bne	a0,a5,1558 <truncate3+0x19c>
    close(fd);
    1504:	8526                	mv	a0,s1
    1506:	00004097          	auipc	ra,0x4
    150a:	002080e7          	jalr	2(ra) # 5508 <close>
  for(int i = 0; i < 150; i++){
    150e:	39fd                	addiw	s3,s3,-1
    1510:	fc0997e3          	bnez	s3,14de <truncate3+0x122>
  wait(&xstatus);
    1514:	fbc40513          	addi	a0,s0,-68
    1518:	00004097          	auipc	ra,0x4
    151c:	fd0080e7          	jalr	-48(ra) # 54e8 <wait>
  unlink("truncfile");
    1520:	00005517          	auipc	a0,0x5
    1524:	85850513          	addi	a0,a0,-1960 # 5d78 <malloc+0x462>
    1528:	00004097          	auipc	ra,0x4
    152c:	008080e7          	jalr	8(ra) # 5530 <unlink>
  exit(xstatus);
    1530:	fbc42503          	lw	a0,-68(s0)
    1534:	00004097          	auipc	ra,0x4
    1538:	fac080e7          	jalr	-84(ra) # 54e0 <exit>
      printf("%s: open failed\n", s);
    153c:	85ca                	mv	a1,s2
    153e:	00005517          	auipc	a0,0x5
    1542:	03250513          	addi	a0,a0,50 # 6570 <malloc+0xc5a>
    1546:	00004097          	auipc	ra,0x4
    154a:	312080e7          	jalr	786(ra) # 5858 <printf>
      exit(1);
    154e:	4505                	li	a0,1
    1550:	00004097          	auipc	ra,0x4
    1554:	f90080e7          	jalr	-112(ra) # 54e0 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1558:	862a                	mv	a2,a0
    155a:	85ca                	mv	a1,s2
    155c:	00005517          	auipc	a0,0x5
    1560:	06450513          	addi	a0,a0,100 # 65c0 <malloc+0xcaa>
    1564:	00004097          	auipc	ra,0x4
    1568:	2f4080e7          	jalr	756(ra) # 5858 <printf>
      exit(1);
    156c:	4505                	li	a0,1
    156e:	00004097          	auipc	ra,0x4
    1572:	f72080e7          	jalr	-142(ra) # 54e0 <exit>

0000000000001576 <exectest>:
{
    1576:	715d                	addi	sp,sp,-80
    1578:	e486                	sd	ra,72(sp)
    157a:	e0a2                	sd	s0,64(sp)
    157c:	fc26                	sd	s1,56(sp)
    157e:	f84a                	sd	s2,48(sp)
    1580:	0880                	addi	s0,sp,80
    1582:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1584:	00004797          	auipc	a5,0x4
    1588:	79c78793          	addi	a5,a5,1948 # 5d20 <malloc+0x40a>
    158c:	fcf43023          	sd	a5,-64(s0)
    1590:	00005797          	auipc	a5,0x5
    1594:	05078793          	addi	a5,a5,80 # 65e0 <malloc+0xcca>
    1598:	fcf43423          	sd	a5,-56(s0)
    159c:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    15a0:	00005517          	auipc	a0,0x5
    15a4:	04850513          	addi	a0,a0,72 # 65e8 <malloc+0xcd2>
    15a8:	00004097          	auipc	ra,0x4
    15ac:	f88080e7          	jalr	-120(ra) # 5530 <unlink>
  pid = fork();
    15b0:	00004097          	auipc	ra,0x4
    15b4:	f28080e7          	jalr	-216(ra) # 54d8 <fork>
  if(pid < 0) {
    15b8:	04054663          	bltz	a0,1604 <exectest+0x8e>
    15bc:	84aa                	mv	s1,a0
  if(pid == 0) {
    15be:	e959                	bnez	a0,1654 <exectest+0xde>
    close(1);
    15c0:	4505                	li	a0,1
    15c2:	00004097          	auipc	ra,0x4
    15c6:	f46080e7          	jalr	-186(ra) # 5508 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15ca:	20100593          	li	a1,513
    15ce:	00005517          	auipc	a0,0x5
    15d2:	01a50513          	addi	a0,a0,26 # 65e8 <malloc+0xcd2>
    15d6:	00004097          	auipc	ra,0x4
    15da:	f4a080e7          	jalr	-182(ra) # 5520 <open>
    if(fd < 0) {
    15de:	04054163          	bltz	a0,1620 <exectest+0xaa>
    if(fd != 1) {
    15e2:	4785                	li	a5,1
    15e4:	04f50c63          	beq	a0,a5,163c <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15e8:	85ca                	mv	a1,s2
    15ea:	00005517          	auipc	a0,0x5
    15ee:	01e50513          	addi	a0,a0,30 # 6608 <malloc+0xcf2>
    15f2:	00004097          	auipc	ra,0x4
    15f6:	266080e7          	jalr	614(ra) # 5858 <printf>
      exit(1);
    15fa:	4505                	li	a0,1
    15fc:	00004097          	auipc	ra,0x4
    1600:	ee4080e7          	jalr	-284(ra) # 54e0 <exit>
     printf("%s: fork failed\n", s);
    1604:	85ca                	mv	a1,s2
    1606:	00005517          	auipc	a0,0x5
    160a:	f5250513          	addi	a0,a0,-174 # 6558 <malloc+0xc42>
    160e:	00004097          	auipc	ra,0x4
    1612:	24a080e7          	jalr	586(ra) # 5858 <printf>
     exit(1);
    1616:	4505                	li	a0,1
    1618:	00004097          	auipc	ra,0x4
    161c:	ec8080e7          	jalr	-312(ra) # 54e0 <exit>
      printf("%s: create failed\n", s);
    1620:	85ca                	mv	a1,s2
    1622:	00005517          	auipc	a0,0x5
    1626:	fce50513          	addi	a0,a0,-50 # 65f0 <malloc+0xcda>
    162a:	00004097          	auipc	ra,0x4
    162e:	22e080e7          	jalr	558(ra) # 5858 <printf>
      exit(1);
    1632:	4505                	li	a0,1
    1634:	00004097          	auipc	ra,0x4
    1638:	eac080e7          	jalr	-340(ra) # 54e0 <exit>
    if(exec("echo", echoargv) < 0){
    163c:	fc040593          	addi	a1,s0,-64
    1640:	00004517          	auipc	a0,0x4
    1644:	6e050513          	addi	a0,a0,1760 # 5d20 <malloc+0x40a>
    1648:	00004097          	auipc	ra,0x4
    164c:	ed0080e7          	jalr	-304(ra) # 5518 <exec>
    1650:	02054163          	bltz	a0,1672 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1654:	fdc40513          	addi	a0,s0,-36
    1658:	00004097          	auipc	ra,0x4
    165c:	e90080e7          	jalr	-368(ra) # 54e8 <wait>
    1660:	02951763          	bne	a0,s1,168e <exectest+0x118>
  if(xstatus != 0)
    1664:	fdc42503          	lw	a0,-36(s0)
    1668:	cd0d                	beqz	a0,16a2 <exectest+0x12c>
    exit(xstatus);
    166a:	00004097          	auipc	ra,0x4
    166e:	e76080e7          	jalr	-394(ra) # 54e0 <exit>
      printf("%s: exec echo failed\n", s);
    1672:	85ca                	mv	a1,s2
    1674:	00005517          	auipc	a0,0x5
    1678:	fa450513          	addi	a0,a0,-92 # 6618 <malloc+0xd02>
    167c:	00004097          	auipc	ra,0x4
    1680:	1dc080e7          	jalr	476(ra) # 5858 <printf>
      exit(1);
    1684:	4505                	li	a0,1
    1686:	00004097          	auipc	ra,0x4
    168a:	e5a080e7          	jalr	-422(ra) # 54e0 <exit>
    printf("%s: wait failed!\n", s);
    168e:	85ca                	mv	a1,s2
    1690:	00005517          	auipc	a0,0x5
    1694:	fa050513          	addi	a0,a0,-96 # 6630 <malloc+0xd1a>
    1698:	00004097          	auipc	ra,0x4
    169c:	1c0080e7          	jalr	448(ra) # 5858 <printf>
    16a0:	b7d1                	j	1664 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    16a2:	4581                	li	a1,0
    16a4:	00005517          	auipc	a0,0x5
    16a8:	f4450513          	addi	a0,a0,-188 # 65e8 <malloc+0xcd2>
    16ac:	00004097          	auipc	ra,0x4
    16b0:	e74080e7          	jalr	-396(ra) # 5520 <open>
  if(fd < 0) {
    16b4:	02054a63          	bltz	a0,16e8 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16b8:	4609                	li	a2,2
    16ba:	fb840593          	addi	a1,s0,-72
    16be:	00004097          	auipc	ra,0x4
    16c2:	e3a080e7          	jalr	-454(ra) # 54f8 <read>
    16c6:	4789                	li	a5,2
    16c8:	02f50e63          	beq	a0,a5,1704 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16cc:	85ca                	mv	a1,s2
    16ce:	00005517          	auipc	a0,0x5
    16d2:	9e250513          	addi	a0,a0,-1566 # 60b0 <malloc+0x79a>
    16d6:	00004097          	auipc	ra,0x4
    16da:	182080e7          	jalr	386(ra) # 5858 <printf>
    exit(1);
    16de:	4505                	li	a0,1
    16e0:	00004097          	auipc	ra,0x4
    16e4:	e00080e7          	jalr	-512(ra) # 54e0 <exit>
    printf("%s: open failed\n", s);
    16e8:	85ca                	mv	a1,s2
    16ea:	00005517          	auipc	a0,0x5
    16ee:	e8650513          	addi	a0,a0,-378 # 6570 <malloc+0xc5a>
    16f2:	00004097          	auipc	ra,0x4
    16f6:	166080e7          	jalr	358(ra) # 5858 <printf>
    exit(1);
    16fa:	4505                	li	a0,1
    16fc:	00004097          	auipc	ra,0x4
    1700:	de4080e7          	jalr	-540(ra) # 54e0 <exit>
  unlink("echo-ok");
    1704:	00005517          	auipc	a0,0x5
    1708:	ee450513          	addi	a0,a0,-284 # 65e8 <malloc+0xcd2>
    170c:	00004097          	auipc	ra,0x4
    1710:	e24080e7          	jalr	-476(ra) # 5530 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1714:	fb844703          	lbu	a4,-72(s0)
    1718:	04f00793          	li	a5,79
    171c:	00f71863          	bne	a4,a5,172c <exectest+0x1b6>
    1720:	fb944703          	lbu	a4,-71(s0)
    1724:	04b00793          	li	a5,75
    1728:	02f70063          	beq	a4,a5,1748 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    172c:	85ca                	mv	a1,s2
    172e:	00005517          	auipc	a0,0x5
    1732:	f1a50513          	addi	a0,a0,-230 # 6648 <malloc+0xd32>
    1736:	00004097          	auipc	ra,0x4
    173a:	122080e7          	jalr	290(ra) # 5858 <printf>
    exit(1);
    173e:	4505                	li	a0,1
    1740:	00004097          	auipc	ra,0x4
    1744:	da0080e7          	jalr	-608(ra) # 54e0 <exit>
    exit(0);
    1748:	4501                	li	a0,0
    174a:	00004097          	auipc	ra,0x4
    174e:	d96080e7          	jalr	-618(ra) # 54e0 <exit>

0000000000001752 <pipe1>:
{
    1752:	711d                	addi	sp,sp,-96
    1754:	ec86                	sd	ra,88(sp)
    1756:	e8a2                	sd	s0,80(sp)
    1758:	e4a6                	sd	s1,72(sp)
    175a:	e0ca                	sd	s2,64(sp)
    175c:	fc4e                	sd	s3,56(sp)
    175e:	f852                	sd	s4,48(sp)
    1760:	f456                	sd	s5,40(sp)
    1762:	f05a                	sd	s6,32(sp)
    1764:	ec5e                	sd	s7,24(sp)
    1766:	1080                	addi	s0,sp,96
    1768:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    176a:	fa840513          	addi	a0,s0,-88
    176e:	00004097          	auipc	ra,0x4
    1772:	d82080e7          	jalr	-638(ra) # 54f0 <pipe>
    1776:	ed25                	bnez	a0,17ee <pipe1+0x9c>
    1778:	84aa                	mv	s1,a0
  pid = fork();
    177a:	00004097          	auipc	ra,0x4
    177e:	d5e080e7          	jalr	-674(ra) # 54d8 <fork>
    1782:	8a2a                	mv	s4,a0
  if(pid == 0){
    1784:	c159                	beqz	a0,180a <pipe1+0xb8>
  } else if(pid > 0){
    1786:	16a05e63          	blez	a0,1902 <pipe1+0x1b0>
    close(fds[1]);
    178a:	fac42503          	lw	a0,-84(s0)
    178e:	00004097          	auipc	ra,0x4
    1792:	d7a080e7          	jalr	-646(ra) # 5508 <close>
    total = 0;
    1796:	8a26                	mv	s4,s1
    cc = 1;
    1798:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    179a:	0000aa97          	auipc	s5,0xa
    179e:	14ea8a93          	addi	s5,s5,334 # b8e8 <buf>
      if(cc > sizeof(buf))
    17a2:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17a4:	864e                	mv	a2,s3
    17a6:	85d6                	mv	a1,s5
    17a8:	fa842503          	lw	a0,-88(s0)
    17ac:	00004097          	auipc	ra,0x4
    17b0:	d4c080e7          	jalr	-692(ra) # 54f8 <read>
    17b4:	10a05263          	blez	a0,18b8 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17b8:	0000a717          	auipc	a4,0xa
    17bc:	13070713          	addi	a4,a4,304 # b8e8 <buf>
    17c0:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17c4:	00074683          	lbu	a3,0(a4)
    17c8:	0ff4f793          	andi	a5,s1,255
    17cc:	2485                	addiw	s1,s1,1
    17ce:	0cf69163          	bne	a3,a5,1890 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17d2:	0705                	addi	a4,a4,1
    17d4:	fec498e3          	bne	s1,a2,17c4 <pipe1+0x72>
      total += n;
    17d8:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17dc:	0019979b          	slliw	a5,s3,0x1
    17e0:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17e4:	013b7363          	bgeu	s6,s3,17ea <pipe1+0x98>
        cc = sizeof(buf);
    17e8:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17ea:	84b2                	mv	s1,a2
    17ec:	bf65                	j	17a4 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17ee:	85ca                	mv	a1,s2
    17f0:	00005517          	auipc	a0,0x5
    17f4:	e7050513          	addi	a0,a0,-400 # 6660 <malloc+0xd4a>
    17f8:	00004097          	auipc	ra,0x4
    17fc:	060080e7          	jalr	96(ra) # 5858 <printf>
    exit(1);
    1800:	4505                	li	a0,1
    1802:	00004097          	auipc	ra,0x4
    1806:	cde080e7          	jalr	-802(ra) # 54e0 <exit>
    close(fds[0]);
    180a:	fa842503          	lw	a0,-88(s0)
    180e:	00004097          	auipc	ra,0x4
    1812:	cfa080e7          	jalr	-774(ra) # 5508 <close>
    for(n = 0; n < N; n++){
    1816:	0000ab17          	auipc	s6,0xa
    181a:	0d2b0b13          	addi	s6,s6,210 # b8e8 <buf>
    181e:	416004bb          	negw	s1,s6
    1822:	0ff4f493          	andi	s1,s1,255
    1826:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    182a:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    182c:	6a85                	lui	s5,0x1
    182e:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x71>
{
    1832:	87da                	mv	a5,s6
        buf[i] = seq++;
    1834:	0097873b          	addw	a4,a5,s1
    1838:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    183c:	0785                	addi	a5,a5,1
    183e:	fef99be3          	bne	s3,a5,1834 <pipe1+0xe2>
    1842:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1846:	40900613          	li	a2,1033
    184a:	85de                	mv	a1,s7
    184c:	fac42503          	lw	a0,-84(s0)
    1850:	00004097          	auipc	ra,0x4
    1854:	cb0080e7          	jalr	-848(ra) # 5500 <write>
    1858:	40900793          	li	a5,1033
    185c:	00f51c63          	bne	a0,a5,1874 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1860:	24a5                	addiw	s1,s1,9
    1862:	0ff4f493          	andi	s1,s1,255
    1866:	fd5a16e3          	bne	s4,s5,1832 <pipe1+0xe0>
    exit(0);
    186a:	4501                	li	a0,0
    186c:	00004097          	auipc	ra,0x4
    1870:	c74080e7          	jalr	-908(ra) # 54e0 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1874:	85ca                	mv	a1,s2
    1876:	00005517          	auipc	a0,0x5
    187a:	e0250513          	addi	a0,a0,-510 # 6678 <malloc+0xd62>
    187e:	00004097          	auipc	ra,0x4
    1882:	fda080e7          	jalr	-38(ra) # 5858 <printf>
        exit(1);
    1886:	4505                	li	a0,1
    1888:	00004097          	auipc	ra,0x4
    188c:	c58080e7          	jalr	-936(ra) # 54e0 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1890:	85ca                	mv	a1,s2
    1892:	00005517          	auipc	a0,0x5
    1896:	dfe50513          	addi	a0,a0,-514 # 6690 <malloc+0xd7a>
    189a:	00004097          	auipc	ra,0x4
    189e:	fbe080e7          	jalr	-66(ra) # 5858 <printf>
}
    18a2:	60e6                	ld	ra,88(sp)
    18a4:	6446                	ld	s0,80(sp)
    18a6:	64a6                	ld	s1,72(sp)
    18a8:	6906                	ld	s2,64(sp)
    18aa:	79e2                	ld	s3,56(sp)
    18ac:	7a42                	ld	s4,48(sp)
    18ae:	7aa2                	ld	s5,40(sp)
    18b0:	7b02                	ld	s6,32(sp)
    18b2:	6be2                	ld	s7,24(sp)
    18b4:	6125                	addi	sp,sp,96
    18b6:	8082                	ret
    if(total != N * SZ){
    18b8:	6785                	lui	a5,0x1
    18ba:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x71>
    18be:	02fa0063          	beq	s4,a5,18de <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18c2:	85d2                	mv	a1,s4
    18c4:	00005517          	auipc	a0,0x5
    18c8:	de450513          	addi	a0,a0,-540 # 66a8 <malloc+0xd92>
    18cc:	00004097          	auipc	ra,0x4
    18d0:	f8c080e7          	jalr	-116(ra) # 5858 <printf>
      exit(1);
    18d4:	4505                	li	a0,1
    18d6:	00004097          	auipc	ra,0x4
    18da:	c0a080e7          	jalr	-1014(ra) # 54e0 <exit>
    close(fds[0]);
    18de:	fa842503          	lw	a0,-88(s0)
    18e2:	00004097          	auipc	ra,0x4
    18e6:	c26080e7          	jalr	-986(ra) # 5508 <close>
    wait(&xstatus);
    18ea:	fa440513          	addi	a0,s0,-92
    18ee:	00004097          	auipc	ra,0x4
    18f2:	bfa080e7          	jalr	-1030(ra) # 54e8 <wait>
    exit(xstatus);
    18f6:	fa442503          	lw	a0,-92(s0)
    18fa:	00004097          	auipc	ra,0x4
    18fe:	be6080e7          	jalr	-1050(ra) # 54e0 <exit>
    printf("%s: fork() failed\n", s);
    1902:	85ca                	mv	a1,s2
    1904:	00005517          	auipc	a0,0x5
    1908:	dc450513          	addi	a0,a0,-572 # 66c8 <malloc+0xdb2>
    190c:	00004097          	auipc	ra,0x4
    1910:	f4c080e7          	jalr	-180(ra) # 5858 <printf>
    exit(1);
    1914:	4505                	li	a0,1
    1916:	00004097          	auipc	ra,0x4
    191a:	bca080e7          	jalr	-1078(ra) # 54e0 <exit>

000000000000191e <exitwait>:
{
    191e:	7139                	addi	sp,sp,-64
    1920:	fc06                	sd	ra,56(sp)
    1922:	f822                	sd	s0,48(sp)
    1924:	f426                	sd	s1,40(sp)
    1926:	f04a                	sd	s2,32(sp)
    1928:	ec4e                	sd	s3,24(sp)
    192a:	e852                	sd	s4,16(sp)
    192c:	0080                	addi	s0,sp,64
    192e:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1930:	4901                	li	s2,0
    1932:	06400993          	li	s3,100
    pid = fork();
    1936:	00004097          	auipc	ra,0x4
    193a:	ba2080e7          	jalr	-1118(ra) # 54d8 <fork>
    193e:	84aa                	mv	s1,a0
    if(pid < 0){
    1940:	02054a63          	bltz	a0,1974 <exitwait+0x56>
    if(pid){
    1944:	c151                	beqz	a0,19c8 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1946:	fcc40513          	addi	a0,s0,-52
    194a:	00004097          	auipc	ra,0x4
    194e:	b9e080e7          	jalr	-1122(ra) # 54e8 <wait>
    1952:	02951f63          	bne	a0,s1,1990 <exitwait+0x72>
      if(i != xstate) {
    1956:	fcc42783          	lw	a5,-52(s0)
    195a:	05279963          	bne	a5,s2,19ac <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    195e:	2905                	addiw	s2,s2,1
    1960:	fd391be3          	bne	s2,s3,1936 <exitwait+0x18>
}
    1964:	70e2                	ld	ra,56(sp)
    1966:	7442                	ld	s0,48(sp)
    1968:	74a2                	ld	s1,40(sp)
    196a:	7902                	ld	s2,32(sp)
    196c:	69e2                	ld	s3,24(sp)
    196e:	6a42                	ld	s4,16(sp)
    1970:	6121                	addi	sp,sp,64
    1972:	8082                	ret
      printf("%s: fork failed\n", s);
    1974:	85d2                	mv	a1,s4
    1976:	00005517          	auipc	a0,0x5
    197a:	be250513          	addi	a0,a0,-1054 # 6558 <malloc+0xc42>
    197e:	00004097          	auipc	ra,0x4
    1982:	eda080e7          	jalr	-294(ra) # 5858 <printf>
      exit(1);
    1986:	4505                	li	a0,1
    1988:	00004097          	auipc	ra,0x4
    198c:	b58080e7          	jalr	-1192(ra) # 54e0 <exit>
        printf("%s: wait wrong pid\n", s);
    1990:	85d2                	mv	a1,s4
    1992:	00005517          	auipc	a0,0x5
    1996:	d4e50513          	addi	a0,a0,-690 # 66e0 <malloc+0xdca>
    199a:	00004097          	auipc	ra,0x4
    199e:	ebe080e7          	jalr	-322(ra) # 5858 <printf>
        exit(1);
    19a2:	4505                	li	a0,1
    19a4:	00004097          	auipc	ra,0x4
    19a8:	b3c080e7          	jalr	-1220(ra) # 54e0 <exit>
        printf("%s: wait wrong exit status\n", s);
    19ac:	85d2                	mv	a1,s4
    19ae:	00005517          	auipc	a0,0x5
    19b2:	d4a50513          	addi	a0,a0,-694 # 66f8 <malloc+0xde2>
    19b6:	00004097          	auipc	ra,0x4
    19ba:	ea2080e7          	jalr	-350(ra) # 5858 <printf>
        exit(1);
    19be:	4505                	li	a0,1
    19c0:	00004097          	auipc	ra,0x4
    19c4:	b20080e7          	jalr	-1248(ra) # 54e0 <exit>
      exit(i);
    19c8:	854a                	mv	a0,s2
    19ca:	00004097          	auipc	ra,0x4
    19ce:	b16080e7          	jalr	-1258(ra) # 54e0 <exit>

00000000000019d2 <twochildren>:
{
    19d2:	1101                	addi	sp,sp,-32
    19d4:	ec06                	sd	ra,24(sp)
    19d6:	e822                	sd	s0,16(sp)
    19d8:	e426                	sd	s1,8(sp)
    19da:	e04a                	sd	s2,0(sp)
    19dc:	1000                	addi	s0,sp,32
    19de:	892a                	mv	s2,a0
    19e0:	3e800493          	li	s1,1000
    int pid1 = fork();
    19e4:	00004097          	auipc	ra,0x4
    19e8:	af4080e7          	jalr	-1292(ra) # 54d8 <fork>
    if(pid1 < 0){
    19ec:	02054c63          	bltz	a0,1a24 <twochildren+0x52>
    if(pid1 == 0){
    19f0:	c921                	beqz	a0,1a40 <twochildren+0x6e>
      int pid2 = fork();
    19f2:	00004097          	auipc	ra,0x4
    19f6:	ae6080e7          	jalr	-1306(ra) # 54d8 <fork>
      if(pid2 < 0){
    19fa:	04054763          	bltz	a0,1a48 <twochildren+0x76>
      if(pid2 == 0){
    19fe:	c13d                	beqz	a0,1a64 <twochildren+0x92>
        wait(0);
    1a00:	4501                	li	a0,0
    1a02:	00004097          	auipc	ra,0x4
    1a06:	ae6080e7          	jalr	-1306(ra) # 54e8 <wait>
        wait(0);
    1a0a:	4501                	li	a0,0
    1a0c:	00004097          	auipc	ra,0x4
    1a10:	adc080e7          	jalr	-1316(ra) # 54e8 <wait>
  for(int i = 0; i < 1000; i++){
    1a14:	34fd                	addiw	s1,s1,-1
    1a16:	f4f9                	bnez	s1,19e4 <twochildren+0x12>
}
    1a18:	60e2                	ld	ra,24(sp)
    1a1a:	6442                	ld	s0,16(sp)
    1a1c:	64a2                	ld	s1,8(sp)
    1a1e:	6902                	ld	s2,0(sp)
    1a20:	6105                	addi	sp,sp,32
    1a22:	8082                	ret
      printf("%s: fork failed\n", s);
    1a24:	85ca                	mv	a1,s2
    1a26:	00005517          	auipc	a0,0x5
    1a2a:	b3250513          	addi	a0,a0,-1230 # 6558 <malloc+0xc42>
    1a2e:	00004097          	auipc	ra,0x4
    1a32:	e2a080e7          	jalr	-470(ra) # 5858 <printf>
      exit(1);
    1a36:	4505                	li	a0,1
    1a38:	00004097          	auipc	ra,0x4
    1a3c:	aa8080e7          	jalr	-1368(ra) # 54e0 <exit>
      exit(0);
    1a40:	00004097          	auipc	ra,0x4
    1a44:	aa0080e7          	jalr	-1376(ra) # 54e0 <exit>
        printf("%s: fork failed\n", s);
    1a48:	85ca                	mv	a1,s2
    1a4a:	00005517          	auipc	a0,0x5
    1a4e:	b0e50513          	addi	a0,a0,-1266 # 6558 <malloc+0xc42>
    1a52:	00004097          	auipc	ra,0x4
    1a56:	e06080e7          	jalr	-506(ra) # 5858 <printf>
        exit(1);
    1a5a:	4505                	li	a0,1
    1a5c:	00004097          	auipc	ra,0x4
    1a60:	a84080e7          	jalr	-1404(ra) # 54e0 <exit>
        exit(0);
    1a64:	00004097          	auipc	ra,0x4
    1a68:	a7c080e7          	jalr	-1412(ra) # 54e0 <exit>

0000000000001a6c <forkfork>:
{
    1a6c:	7179                	addi	sp,sp,-48
    1a6e:	f406                	sd	ra,40(sp)
    1a70:	f022                	sd	s0,32(sp)
    1a72:	ec26                	sd	s1,24(sp)
    1a74:	1800                	addi	s0,sp,48
    1a76:	84aa                	mv	s1,a0
    int pid = fork();
    1a78:	00004097          	auipc	ra,0x4
    1a7c:	a60080e7          	jalr	-1440(ra) # 54d8 <fork>
    if(pid < 0){
    1a80:	04054163          	bltz	a0,1ac2 <forkfork+0x56>
    if(pid == 0){
    1a84:	cd29                	beqz	a0,1ade <forkfork+0x72>
    int pid = fork();
    1a86:	00004097          	auipc	ra,0x4
    1a8a:	a52080e7          	jalr	-1454(ra) # 54d8 <fork>
    if(pid < 0){
    1a8e:	02054a63          	bltz	a0,1ac2 <forkfork+0x56>
    if(pid == 0){
    1a92:	c531                	beqz	a0,1ade <forkfork+0x72>
    wait(&xstatus);
    1a94:	fdc40513          	addi	a0,s0,-36
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	a50080e7          	jalr	-1456(ra) # 54e8 <wait>
    if(xstatus != 0) {
    1aa0:	fdc42783          	lw	a5,-36(s0)
    1aa4:	ebbd                	bnez	a5,1b1a <forkfork+0xae>
    wait(&xstatus);
    1aa6:	fdc40513          	addi	a0,s0,-36
    1aaa:	00004097          	auipc	ra,0x4
    1aae:	a3e080e7          	jalr	-1474(ra) # 54e8 <wait>
    if(xstatus != 0) {
    1ab2:	fdc42783          	lw	a5,-36(s0)
    1ab6:	e3b5                	bnez	a5,1b1a <forkfork+0xae>
}
    1ab8:	70a2                	ld	ra,40(sp)
    1aba:	7402                	ld	s0,32(sp)
    1abc:	64e2                	ld	s1,24(sp)
    1abe:	6145                	addi	sp,sp,48
    1ac0:	8082                	ret
      printf("%s: fork failed", s);
    1ac2:	85a6                	mv	a1,s1
    1ac4:	00005517          	auipc	a0,0x5
    1ac8:	c5450513          	addi	a0,a0,-940 # 6718 <malloc+0xe02>
    1acc:	00004097          	auipc	ra,0x4
    1ad0:	d8c080e7          	jalr	-628(ra) # 5858 <printf>
      exit(1);
    1ad4:	4505                	li	a0,1
    1ad6:	00004097          	auipc	ra,0x4
    1ada:	a0a080e7          	jalr	-1526(ra) # 54e0 <exit>
{
    1ade:	0c800493          	li	s1,200
        int pid1 = fork();
    1ae2:	00004097          	auipc	ra,0x4
    1ae6:	9f6080e7          	jalr	-1546(ra) # 54d8 <fork>
        if(pid1 < 0){
    1aea:	00054f63          	bltz	a0,1b08 <forkfork+0x9c>
        if(pid1 == 0){
    1aee:	c115                	beqz	a0,1b12 <forkfork+0xa6>
        wait(0);
    1af0:	4501                	li	a0,0
    1af2:	00004097          	auipc	ra,0x4
    1af6:	9f6080e7          	jalr	-1546(ra) # 54e8 <wait>
      for(int j = 0; j < 200; j++){
    1afa:	34fd                	addiw	s1,s1,-1
    1afc:	f0fd                	bnez	s1,1ae2 <forkfork+0x76>
      exit(0);
    1afe:	4501                	li	a0,0
    1b00:	00004097          	auipc	ra,0x4
    1b04:	9e0080e7          	jalr	-1568(ra) # 54e0 <exit>
          exit(1);
    1b08:	4505                	li	a0,1
    1b0a:	00004097          	auipc	ra,0x4
    1b0e:	9d6080e7          	jalr	-1578(ra) # 54e0 <exit>
          exit(0);
    1b12:	00004097          	auipc	ra,0x4
    1b16:	9ce080e7          	jalr	-1586(ra) # 54e0 <exit>
      printf("%s: fork in child failed", s);
    1b1a:	85a6                	mv	a1,s1
    1b1c:	00005517          	auipc	a0,0x5
    1b20:	c0c50513          	addi	a0,a0,-1012 # 6728 <malloc+0xe12>
    1b24:	00004097          	auipc	ra,0x4
    1b28:	d34080e7          	jalr	-716(ra) # 5858 <printf>
      exit(1);
    1b2c:	4505                	li	a0,1
    1b2e:	00004097          	auipc	ra,0x4
    1b32:	9b2080e7          	jalr	-1614(ra) # 54e0 <exit>

0000000000001b36 <reparent2>:
{
    1b36:	1101                	addi	sp,sp,-32
    1b38:	ec06                	sd	ra,24(sp)
    1b3a:	e822                	sd	s0,16(sp)
    1b3c:	e426                	sd	s1,8(sp)
    1b3e:	1000                	addi	s0,sp,32
    1b40:	32000493          	li	s1,800
    int pid1 = fork();
    1b44:	00004097          	auipc	ra,0x4
    1b48:	994080e7          	jalr	-1644(ra) # 54d8 <fork>
    if(pid1 < 0){
    1b4c:	00054f63          	bltz	a0,1b6a <reparent2+0x34>
    if(pid1 == 0){
    1b50:	c915                	beqz	a0,1b84 <reparent2+0x4e>
    wait(0);
    1b52:	4501                	li	a0,0
    1b54:	00004097          	auipc	ra,0x4
    1b58:	994080e7          	jalr	-1644(ra) # 54e8 <wait>
  for(int i = 0; i < 800; i++){
    1b5c:	34fd                	addiw	s1,s1,-1
    1b5e:	f0fd                	bnez	s1,1b44 <reparent2+0xe>
  exit(0);
    1b60:	4501                	li	a0,0
    1b62:	00004097          	auipc	ra,0x4
    1b66:	97e080e7          	jalr	-1666(ra) # 54e0 <exit>
      printf("fork failed\n");
    1b6a:	00005517          	auipc	a0,0x5
    1b6e:	dbe50513          	addi	a0,a0,-578 # 6928 <malloc+0x1012>
    1b72:	00004097          	auipc	ra,0x4
    1b76:	ce6080e7          	jalr	-794(ra) # 5858 <printf>
      exit(1);
    1b7a:	4505                	li	a0,1
    1b7c:	00004097          	auipc	ra,0x4
    1b80:	964080e7          	jalr	-1692(ra) # 54e0 <exit>
      fork();
    1b84:	00004097          	auipc	ra,0x4
    1b88:	954080e7          	jalr	-1708(ra) # 54d8 <fork>
      fork();
    1b8c:	00004097          	auipc	ra,0x4
    1b90:	94c080e7          	jalr	-1716(ra) # 54d8 <fork>
      exit(0);
    1b94:	4501                	li	a0,0
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	94a080e7          	jalr	-1718(ra) # 54e0 <exit>

0000000000001b9e <createdelete>:
{
    1b9e:	7175                	addi	sp,sp,-144
    1ba0:	e506                	sd	ra,136(sp)
    1ba2:	e122                	sd	s0,128(sp)
    1ba4:	fca6                	sd	s1,120(sp)
    1ba6:	f8ca                	sd	s2,112(sp)
    1ba8:	f4ce                	sd	s3,104(sp)
    1baa:	f0d2                	sd	s4,96(sp)
    1bac:	ecd6                	sd	s5,88(sp)
    1bae:	e8da                	sd	s6,80(sp)
    1bb0:	e4de                	sd	s7,72(sp)
    1bb2:	e0e2                	sd	s8,64(sp)
    1bb4:	fc66                	sd	s9,56(sp)
    1bb6:	0900                	addi	s0,sp,144
    1bb8:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bba:	4901                	li	s2,0
    1bbc:	4991                	li	s3,4
    pid = fork();
    1bbe:	00004097          	auipc	ra,0x4
    1bc2:	91a080e7          	jalr	-1766(ra) # 54d8 <fork>
    1bc6:	84aa                	mv	s1,a0
    if(pid < 0){
    1bc8:	02054f63          	bltz	a0,1c06 <createdelete+0x68>
    if(pid == 0){
    1bcc:	c939                	beqz	a0,1c22 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bce:	2905                	addiw	s2,s2,1
    1bd0:	ff3917e3          	bne	s2,s3,1bbe <createdelete+0x20>
    1bd4:	4491                	li	s1,4
    wait(&xstatus);
    1bd6:	f7c40513          	addi	a0,s0,-132
    1bda:	00004097          	auipc	ra,0x4
    1bde:	90e080e7          	jalr	-1778(ra) # 54e8 <wait>
    if(xstatus != 0)
    1be2:	f7c42903          	lw	s2,-132(s0)
    1be6:	0e091263          	bnez	s2,1cca <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bea:	34fd                	addiw	s1,s1,-1
    1bec:	f4ed                	bnez	s1,1bd6 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bee:	f8040123          	sb	zero,-126(s0)
    1bf2:	03000993          	li	s3,48
    1bf6:	5a7d                	li	s4,-1
    1bf8:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bfc:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bfe:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1c00:	07400a93          	li	s5,116
    1c04:	a29d                	j	1d6a <createdelete+0x1cc>
      printf("fork failed\n", s);
    1c06:	85e6                	mv	a1,s9
    1c08:	00005517          	auipc	a0,0x5
    1c0c:	d2050513          	addi	a0,a0,-736 # 6928 <malloc+0x1012>
    1c10:	00004097          	auipc	ra,0x4
    1c14:	c48080e7          	jalr	-952(ra) # 5858 <printf>
      exit(1);
    1c18:	4505                	li	a0,1
    1c1a:	00004097          	auipc	ra,0x4
    1c1e:	8c6080e7          	jalr	-1850(ra) # 54e0 <exit>
      name[0] = 'p' + pi;
    1c22:	0709091b          	addiw	s2,s2,112
    1c26:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c2a:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c2e:	4951                	li	s2,20
    1c30:	a015                	j	1c54 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c32:	85e6                	mv	a1,s9
    1c34:	00005517          	auipc	a0,0x5
    1c38:	9bc50513          	addi	a0,a0,-1604 # 65f0 <malloc+0xcda>
    1c3c:	00004097          	auipc	ra,0x4
    1c40:	c1c080e7          	jalr	-996(ra) # 5858 <printf>
          exit(1);
    1c44:	4505                	li	a0,1
    1c46:	00004097          	auipc	ra,0x4
    1c4a:	89a080e7          	jalr	-1894(ra) # 54e0 <exit>
      for(i = 0; i < N; i++){
    1c4e:	2485                	addiw	s1,s1,1
    1c50:	07248863          	beq	s1,s2,1cc0 <createdelete+0x122>
        name[1] = '0' + i;
    1c54:	0304879b          	addiw	a5,s1,48
    1c58:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c5c:	20200593          	li	a1,514
    1c60:	f8040513          	addi	a0,s0,-128
    1c64:	00004097          	auipc	ra,0x4
    1c68:	8bc080e7          	jalr	-1860(ra) # 5520 <open>
        if(fd < 0){
    1c6c:	fc0543e3          	bltz	a0,1c32 <createdelete+0x94>
        close(fd);
    1c70:	00004097          	auipc	ra,0x4
    1c74:	898080e7          	jalr	-1896(ra) # 5508 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c78:	fc905be3          	blez	s1,1c4e <createdelete+0xb0>
    1c7c:	0014f793          	andi	a5,s1,1
    1c80:	f7f9                	bnez	a5,1c4e <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c82:	01f4d79b          	srliw	a5,s1,0x1f
    1c86:	9fa5                	addw	a5,a5,s1
    1c88:	4017d79b          	sraiw	a5,a5,0x1
    1c8c:	0307879b          	addiw	a5,a5,48
    1c90:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c94:	f8040513          	addi	a0,s0,-128
    1c98:	00004097          	auipc	ra,0x4
    1c9c:	898080e7          	jalr	-1896(ra) # 5530 <unlink>
    1ca0:	fa0557e3          	bgez	a0,1c4e <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1ca4:	85e6                	mv	a1,s9
    1ca6:	00005517          	auipc	a0,0x5
    1caa:	aa250513          	addi	a0,a0,-1374 # 6748 <malloc+0xe32>
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	baa080e7          	jalr	-1110(ra) # 5858 <printf>
            exit(1);
    1cb6:	4505                	li	a0,1
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	828080e7          	jalr	-2008(ra) # 54e0 <exit>
      exit(0);
    1cc0:	4501                	li	a0,0
    1cc2:	00004097          	auipc	ra,0x4
    1cc6:	81e080e7          	jalr	-2018(ra) # 54e0 <exit>
      exit(1);
    1cca:	4505                	li	a0,1
    1ccc:	00004097          	auipc	ra,0x4
    1cd0:	814080e7          	jalr	-2028(ra) # 54e0 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cd4:	f8040613          	addi	a2,s0,-128
    1cd8:	85e6                	mv	a1,s9
    1cda:	00005517          	auipc	a0,0x5
    1cde:	a8650513          	addi	a0,a0,-1402 # 6760 <malloc+0xe4a>
    1ce2:	00004097          	auipc	ra,0x4
    1ce6:	b76080e7          	jalr	-1162(ra) # 5858 <printf>
        exit(1);
    1cea:	4505                	li	a0,1
    1cec:	00003097          	auipc	ra,0x3
    1cf0:	7f4080e7          	jalr	2036(ra) # 54e0 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1cf4:	054b7163          	bgeu	s6,s4,1d36 <createdelete+0x198>
      if(fd >= 0)
    1cf8:	02055a63          	bgez	a0,1d2c <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1cfc:	2485                	addiw	s1,s1,1
    1cfe:	0ff4f493          	andi	s1,s1,255
    1d02:	05548c63          	beq	s1,s5,1d5a <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1d06:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1d0a:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d0e:	4581                	li	a1,0
    1d10:	f8040513          	addi	a0,s0,-128
    1d14:	00004097          	auipc	ra,0x4
    1d18:	80c080e7          	jalr	-2036(ra) # 5520 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d1c:	00090463          	beqz	s2,1d24 <createdelete+0x186>
    1d20:	fd2bdae3          	bge	s7,s2,1cf4 <createdelete+0x156>
    1d24:	fa0548e3          	bltz	a0,1cd4 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d28:	014b7963          	bgeu	s6,s4,1d3a <createdelete+0x19c>
        close(fd);
    1d2c:	00003097          	auipc	ra,0x3
    1d30:	7dc080e7          	jalr	2012(ra) # 5508 <close>
    1d34:	b7e1                	j	1cfc <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d36:	fc0543e3          	bltz	a0,1cfc <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d3a:	f8040613          	addi	a2,s0,-128
    1d3e:	85e6                	mv	a1,s9
    1d40:	00005517          	auipc	a0,0x5
    1d44:	a4850513          	addi	a0,a0,-1464 # 6788 <malloc+0xe72>
    1d48:	00004097          	auipc	ra,0x4
    1d4c:	b10080e7          	jalr	-1264(ra) # 5858 <printf>
        exit(1);
    1d50:	4505                	li	a0,1
    1d52:	00003097          	auipc	ra,0x3
    1d56:	78e080e7          	jalr	1934(ra) # 54e0 <exit>
  for(i = 0; i < N; i++){
    1d5a:	2905                	addiw	s2,s2,1
    1d5c:	2a05                	addiw	s4,s4,1
    1d5e:	2985                	addiw	s3,s3,1
    1d60:	0ff9f993          	andi	s3,s3,255
    1d64:	47d1                	li	a5,20
    1d66:	02f90a63          	beq	s2,a5,1d9a <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d6a:	84e2                	mv	s1,s8
    1d6c:	bf69                	j	1d06 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d6e:	2905                	addiw	s2,s2,1
    1d70:	0ff97913          	andi	s2,s2,255
    1d74:	2985                	addiw	s3,s3,1
    1d76:	0ff9f993          	andi	s3,s3,255
    1d7a:	03490863          	beq	s2,s4,1daa <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d7e:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d80:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d84:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d88:	f8040513          	addi	a0,s0,-128
    1d8c:	00003097          	auipc	ra,0x3
    1d90:	7a4080e7          	jalr	1956(ra) # 5530 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d94:	34fd                	addiw	s1,s1,-1
    1d96:	f4ed                	bnez	s1,1d80 <createdelete+0x1e2>
    1d98:	bfd9                	j	1d6e <createdelete+0x1d0>
    1d9a:	03000993          	li	s3,48
    1d9e:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1da2:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1da4:	08400a13          	li	s4,132
    1da8:	bfd9                	j	1d7e <createdelete+0x1e0>
}
    1daa:	60aa                	ld	ra,136(sp)
    1dac:	640a                	ld	s0,128(sp)
    1dae:	74e6                	ld	s1,120(sp)
    1db0:	7946                	ld	s2,112(sp)
    1db2:	79a6                	ld	s3,104(sp)
    1db4:	7a06                	ld	s4,96(sp)
    1db6:	6ae6                	ld	s5,88(sp)
    1db8:	6b46                	ld	s6,80(sp)
    1dba:	6ba6                	ld	s7,72(sp)
    1dbc:	6c06                	ld	s8,64(sp)
    1dbe:	7ce2                	ld	s9,56(sp)
    1dc0:	6149                	addi	sp,sp,144
    1dc2:	8082                	ret

0000000000001dc4 <linkunlink>:
{
    1dc4:	711d                	addi	sp,sp,-96
    1dc6:	ec86                	sd	ra,88(sp)
    1dc8:	e8a2                	sd	s0,80(sp)
    1dca:	e4a6                	sd	s1,72(sp)
    1dcc:	e0ca                	sd	s2,64(sp)
    1dce:	fc4e                	sd	s3,56(sp)
    1dd0:	f852                	sd	s4,48(sp)
    1dd2:	f456                	sd	s5,40(sp)
    1dd4:	f05a                	sd	s6,32(sp)
    1dd6:	ec5e                	sd	s7,24(sp)
    1dd8:	e862                	sd	s8,16(sp)
    1dda:	e466                	sd	s9,8(sp)
    1ddc:	1080                	addi	s0,sp,96
    1dde:	84aa                	mv	s1,a0
  unlink("x");
    1de0:	00004517          	auipc	a0,0x4
    1de4:	fb050513          	addi	a0,a0,-80 # 5d90 <malloc+0x47a>
    1de8:	00003097          	auipc	ra,0x3
    1dec:	748080e7          	jalr	1864(ra) # 5530 <unlink>
  pid = fork();
    1df0:	00003097          	auipc	ra,0x3
    1df4:	6e8080e7          	jalr	1768(ra) # 54d8 <fork>
  if(pid < 0){
    1df8:	02054b63          	bltz	a0,1e2e <linkunlink+0x6a>
    1dfc:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dfe:	4c85                	li	s9,1
    1e00:	e119                	bnez	a0,1e06 <linkunlink+0x42>
    1e02:	06100c93          	li	s9,97
    1e06:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1e0a:	41c659b7          	lui	s3,0x41c65
    1e0e:	e6d9899b          	addiw	s3,s3,-403
    1e12:	690d                	lui	s2,0x3
    1e14:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e18:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e1a:	4b05                	li	s6,1
      unlink("x");
    1e1c:	00004a97          	auipc	s5,0x4
    1e20:	f74a8a93          	addi	s5,s5,-140 # 5d90 <malloc+0x47a>
      link("cat", "x");
    1e24:	00005b97          	auipc	s7,0x5
    1e28:	98cb8b93          	addi	s7,s7,-1652 # 67b0 <malloc+0xe9a>
    1e2c:	a091                	j	1e70 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e2e:	85a6                	mv	a1,s1
    1e30:	00004517          	auipc	a0,0x4
    1e34:	72850513          	addi	a0,a0,1832 # 6558 <malloc+0xc42>
    1e38:	00004097          	auipc	ra,0x4
    1e3c:	a20080e7          	jalr	-1504(ra) # 5858 <printf>
    exit(1);
    1e40:	4505                	li	a0,1
    1e42:	00003097          	auipc	ra,0x3
    1e46:	69e080e7          	jalr	1694(ra) # 54e0 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e4a:	20200593          	li	a1,514
    1e4e:	8556                	mv	a0,s5
    1e50:	00003097          	auipc	ra,0x3
    1e54:	6d0080e7          	jalr	1744(ra) # 5520 <open>
    1e58:	00003097          	auipc	ra,0x3
    1e5c:	6b0080e7          	jalr	1712(ra) # 5508 <close>
    1e60:	a031                	j	1e6c <linkunlink+0xa8>
      unlink("x");
    1e62:	8556                	mv	a0,s5
    1e64:	00003097          	auipc	ra,0x3
    1e68:	6cc080e7          	jalr	1740(ra) # 5530 <unlink>
  for(i = 0; i < 100; i++){
    1e6c:	34fd                	addiw	s1,s1,-1
    1e6e:	c09d                	beqz	s1,1e94 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e70:	033c87bb          	mulw	a5,s9,s3
    1e74:	012787bb          	addw	a5,a5,s2
    1e78:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e7c:	0347f7bb          	remuw	a5,a5,s4
    1e80:	d7e9                	beqz	a5,1e4a <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e82:	ff6790e3          	bne	a5,s6,1e62 <linkunlink+0x9e>
      link("cat", "x");
    1e86:	85d6                	mv	a1,s5
    1e88:	855e                	mv	a0,s7
    1e8a:	00003097          	auipc	ra,0x3
    1e8e:	6b6080e7          	jalr	1718(ra) # 5540 <link>
    1e92:	bfe9                	j	1e6c <linkunlink+0xa8>
  if(pid)
    1e94:	020c0463          	beqz	s8,1ebc <linkunlink+0xf8>
    wait(0);
    1e98:	4501                	li	a0,0
    1e9a:	00003097          	auipc	ra,0x3
    1e9e:	64e080e7          	jalr	1614(ra) # 54e8 <wait>
}
    1ea2:	60e6                	ld	ra,88(sp)
    1ea4:	6446                	ld	s0,80(sp)
    1ea6:	64a6                	ld	s1,72(sp)
    1ea8:	6906                	ld	s2,64(sp)
    1eaa:	79e2                	ld	s3,56(sp)
    1eac:	7a42                	ld	s4,48(sp)
    1eae:	7aa2                	ld	s5,40(sp)
    1eb0:	7b02                	ld	s6,32(sp)
    1eb2:	6be2                	ld	s7,24(sp)
    1eb4:	6c42                	ld	s8,16(sp)
    1eb6:	6ca2                	ld	s9,8(sp)
    1eb8:	6125                	addi	sp,sp,96
    1eba:	8082                	ret
    exit(0);
    1ebc:	4501                	li	a0,0
    1ebe:	00003097          	auipc	ra,0x3
    1ec2:	622080e7          	jalr	1570(ra) # 54e0 <exit>

0000000000001ec6 <forktest>:
{
    1ec6:	7179                	addi	sp,sp,-48
    1ec8:	f406                	sd	ra,40(sp)
    1eca:	f022                	sd	s0,32(sp)
    1ecc:	ec26                	sd	s1,24(sp)
    1ece:	e84a                	sd	s2,16(sp)
    1ed0:	e44e                	sd	s3,8(sp)
    1ed2:	1800                	addi	s0,sp,48
    1ed4:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1ed6:	4481                	li	s1,0
    1ed8:	3e800913          	li	s2,1000
    pid = fork();
    1edc:	00003097          	auipc	ra,0x3
    1ee0:	5fc080e7          	jalr	1532(ra) # 54d8 <fork>
    if(pid < 0)
    1ee4:	02054863          	bltz	a0,1f14 <forktest+0x4e>
    if(pid == 0)
    1ee8:	c115                	beqz	a0,1f0c <forktest+0x46>
  for(n=0; n<N; n++){
    1eea:	2485                	addiw	s1,s1,1
    1eec:	ff2498e3          	bne	s1,s2,1edc <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1ef0:	85ce                	mv	a1,s3
    1ef2:	00005517          	auipc	a0,0x5
    1ef6:	8de50513          	addi	a0,a0,-1826 # 67d0 <malloc+0xeba>
    1efa:	00004097          	auipc	ra,0x4
    1efe:	95e080e7          	jalr	-1698(ra) # 5858 <printf>
    exit(1);
    1f02:	4505                	li	a0,1
    1f04:	00003097          	auipc	ra,0x3
    1f08:	5dc080e7          	jalr	1500(ra) # 54e0 <exit>
      exit(0);
    1f0c:	00003097          	auipc	ra,0x3
    1f10:	5d4080e7          	jalr	1492(ra) # 54e0 <exit>
  if (n == 0) {
    1f14:	cc9d                	beqz	s1,1f52 <forktest+0x8c>
  if(n == N){
    1f16:	3e800793          	li	a5,1000
    1f1a:	fcf48be3          	beq	s1,a5,1ef0 <forktest+0x2a>
  for(; n > 0; n--){
    1f1e:	00905b63          	blez	s1,1f34 <forktest+0x6e>
    if(wait(0) < 0){
    1f22:	4501                	li	a0,0
    1f24:	00003097          	auipc	ra,0x3
    1f28:	5c4080e7          	jalr	1476(ra) # 54e8 <wait>
    1f2c:	04054163          	bltz	a0,1f6e <forktest+0xa8>
  for(; n > 0; n--){
    1f30:	34fd                	addiw	s1,s1,-1
    1f32:	f8e5                	bnez	s1,1f22 <forktest+0x5c>
  if(wait(0) != -1){
    1f34:	4501                	li	a0,0
    1f36:	00003097          	auipc	ra,0x3
    1f3a:	5b2080e7          	jalr	1458(ra) # 54e8 <wait>
    1f3e:	57fd                	li	a5,-1
    1f40:	04f51563          	bne	a0,a5,1f8a <forktest+0xc4>
}
    1f44:	70a2                	ld	ra,40(sp)
    1f46:	7402                	ld	s0,32(sp)
    1f48:	64e2                	ld	s1,24(sp)
    1f4a:	6942                	ld	s2,16(sp)
    1f4c:	69a2                	ld	s3,8(sp)
    1f4e:	6145                	addi	sp,sp,48
    1f50:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1f52:	85ce                	mv	a1,s3
    1f54:	00005517          	auipc	a0,0x5
    1f58:	86450513          	addi	a0,a0,-1948 # 67b8 <malloc+0xea2>
    1f5c:	00004097          	auipc	ra,0x4
    1f60:	8fc080e7          	jalr	-1796(ra) # 5858 <printf>
    exit(1);
    1f64:	4505                	li	a0,1
    1f66:	00003097          	auipc	ra,0x3
    1f6a:	57a080e7          	jalr	1402(ra) # 54e0 <exit>
      printf("%s: wait stopped early\n", s);
    1f6e:	85ce                	mv	a1,s3
    1f70:	00005517          	auipc	a0,0x5
    1f74:	88850513          	addi	a0,a0,-1912 # 67f8 <malloc+0xee2>
    1f78:	00004097          	auipc	ra,0x4
    1f7c:	8e0080e7          	jalr	-1824(ra) # 5858 <printf>
      exit(1);
    1f80:	4505                	li	a0,1
    1f82:	00003097          	auipc	ra,0x3
    1f86:	55e080e7          	jalr	1374(ra) # 54e0 <exit>
    printf("%s: wait got too many\n", s);
    1f8a:	85ce                	mv	a1,s3
    1f8c:	00005517          	auipc	a0,0x5
    1f90:	88450513          	addi	a0,a0,-1916 # 6810 <malloc+0xefa>
    1f94:	00004097          	auipc	ra,0x4
    1f98:	8c4080e7          	jalr	-1852(ra) # 5858 <printf>
    exit(1);
    1f9c:	4505                	li	a0,1
    1f9e:	00003097          	auipc	ra,0x3
    1fa2:	542080e7          	jalr	1346(ra) # 54e0 <exit>

0000000000001fa6 <bigargtest>:
{
    1fa6:	7179                	addi	sp,sp,-48
    1fa8:	f406                	sd	ra,40(sp)
    1faa:	f022                	sd	s0,32(sp)
    1fac:	ec26                	sd	s1,24(sp)
    1fae:	1800                	addi	s0,sp,48
    1fb0:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    1fb2:	00005517          	auipc	a0,0x5
    1fb6:	87650513          	addi	a0,a0,-1930 # 6828 <malloc+0xf12>
    1fba:	00003097          	auipc	ra,0x3
    1fbe:	576080e7          	jalr	1398(ra) # 5530 <unlink>
  pid = fork();
    1fc2:	00003097          	auipc	ra,0x3
    1fc6:	516080e7          	jalr	1302(ra) # 54d8 <fork>
  if(pid == 0){
    1fca:	c121                	beqz	a0,200a <bigargtest+0x64>
  } else if(pid < 0){
    1fcc:	0a054063          	bltz	a0,206c <bigargtest+0xc6>
  wait(&xstatus);
    1fd0:	fdc40513          	addi	a0,s0,-36
    1fd4:	00003097          	auipc	ra,0x3
    1fd8:	514080e7          	jalr	1300(ra) # 54e8 <wait>
  if(xstatus != 0)
    1fdc:	fdc42503          	lw	a0,-36(s0)
    1fe0:	e545                	bnez	a0,2088 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    1fe2:	4581                	li	a1,0
    1fe4:	00005517          	auipc	a0,0x5
    1fe8:	84450513          	addi	a0,a0,-1980 # 6828 <malloc+0xf12>
    1fec:	00003097          	auipc	ra,0x3
    1ff0:	534080e7          	jalr	1332(ra) # 5520 <open>
  if(fd < 0){
    1ff4:	08054e63          	bltz	a0,2090 <bigargtest+0xea>
  close(fd);
    1ff8:	00003097          	auipc	ra,0x3
    1ffc:	510080e7          	jalr	1296(ra) # 5508 <close>
}
    2000:	70a2                	ld	ra,40(sp)
    2002:	7402                	ld	s0,32(sp)
    2004:	64e2                	ld	s1,24(sp)
    2006:	6145                	addi	sp,sp,48
    2008:	8082                	ret
    200a:	00006797          	auipc	a5,0x6
    200e:	0c678793          	addi	a5,a5,198 # 80d0 <args.1807>
    2012:	00006697          	auipc	a3,0x6
    2016:	1b668693          	addi	a3,a3,438 # 81c8 <args.1807+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    201a:	00005717          	auipc	a4,0x5
    201e:	81e70713          	addi	a4,a4,-2018 # 6838 <malloc+0xf22>
    2022:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    2024:	07a1                	addi	a5,a5,8
    2026:	fed79ee3          	bne	a5,a3,2022 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    202a:	00006597          	auipc	a1,0x6
    202e:	0a658593          	addi	a1,a1,166 # 80d0 <args.1807>
    2032:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2036:	00004517          	auipc	a0,0x4
    203a:	cea50513          	addi	a0,a0,-790 # 5d20 <malloc+0x40a>
    203e:	00003097          	auipc	ra,0x3
    2042:	4da080e7          	jalr	1242(ra) # 5518 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2046:	20000593          	li	a1,512
    204a:	00004517          	auipc	a0,0x4
    204e:	7de50513          	addi	a0,a0,2014 # 6828 <malloc+0xf12>
    2052:	00003097          	auipc	ra,0x3
    2056:	4ce080e7          	jalr	1230(ra) # 5520 <open>
    close(fd);
    205a:	00003097          	auipc	ra,0x3
    205e:	4ae080e7          	jalr	1198(ra) # 5508 <close>
    exit(0);
    2062:	4501                	li	a0,0
    2064:	00003097          	auipc	ra,0x3
    2068:	47c080e7          	jalr	1148(ra) # 54e0 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    206c:	85a6                	mv	a1,s1
    206e:	00005517          	auipc	a0,0x5
    2072:	8aa50513          	addi	a0,a0,-1878 # 6918 <malloc+0x1002>
    2076:	00003097          	auipc	ra,0x3
    207a:	7e2080e7          	jalr	2018(ra) # 5858 <printf>
    exit(1);
    207e:	4505                	li	a0,1
    2080:	00003097          	auipc	ra,0x3
    2084:	460080e7          	jalr	1120(ra) # 54e0 <exit>
    exit(xstatus);
    2088:	00003097          	auipc	ra,0x3
    208c:	458080e7          	jalr	1112(ra) # 54e0 <exit>
    printf("%s: bigarg test failed!\n", s);
    2090:	85a6                	mv	a1,s1
    2092:	00005517          	auipc	a0,0x5
    2096:	8a650513          	addi	a0,a0,-1882 # 6938 <malloc+0x1022>
    209a:	00003097          	auipc	ra,0x3
    209e:	7be080e7          	jalr	1982(ra) # 5858 <printf>
    exit(1);
    20a2:	4505                	li	a0,1
    20a4:	00003097          	auipc	ra,0x3
    20a8:	43c080e7          	jalr	1084(ra) # 54e0 <exit>

00000000000020ac <copyinstr3>:
{
    20ac:	7179                	addi	sp,sp,-48
    20ae:	f406                	sd	ra,40(sp)
    20b0:	f022                	sd	s0,32(sp)
    20b2:	ec26                	sd	s1,24(sp)
    20b4:	1800                	addi	s0,sp,48
  sbrk(8192);
    20b6:	6509                	lui	a0,0x2
    20b8:	00003097          	auipc	ra,0x3
    20bc:	4b0080e7          	jalr	1200(ra) # 5568 <sbrk>
  uint64 top = (uint64) sbrk(0);
    20c0:	4501                	li	a0,0
    20c2:	00003097          	auipc	ra,0x3
    20c6:	4a6080e7          	jalr	1190(ra) # 5568 <sbrk>
  if((top % PGSIZE) != 0){
    20ca:	03451793          	slli	a5,a0,0x34
    20ce:	e3c9                	bnez	a5,2150 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    20d0:	4501                	li	a0,0
    20d2:	00003097          	auipc	ra,0x3
    20d6:	496080e7          	jalr	1174(ra) # 5568 <sbrk>
  if(top % PGSIZE){
    20da:	03451793          	slli	a5,a0,0x34
    20de:	e3d9                	bnez	a5,2164 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    20e0:	fff50493          	addi	s1,a0,-1 # 1fff <bigargtest+0x59>
  *b = 'x';
    20e4:	07800793          	li	a5,120
    20e8:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    20ec:	8526                	mv	a0,s1
    20ee:	00003097          	auipc	ra,0x3
    20f2:	442080e7          	jalr	1090(ra) # 5530 <unlink>
  if(ret != -1){
    20f6:	57fd                	li	a5,-1
    20f8:	08f51363          	bne	a0,a5,217e <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    20fc:	20100593          	li	a1,513
    2100:	8526                	mv	a0,s1
    2102:	00003097          	auipc	ra,0x3
    2106:	41e080e7          	jalr	1054(ra) # 5520 <open>
  if(fd != -1){
    210a:	57fd                	li	a5,-1
    210c:	08f51863          	bne	a0,a5,219c <copyinstr3+0xf0>
  ret = link(b, b);
    2110:	85a6                	mv	a1,s1
    2112:	8526                	mv	a0,s1
    2114:	00003097          	auipc	ra,0x3
    2118:	42c080e7          	jalr	1068(ra) # 5540 <link>
  if(ret != -1){
    211c:	57fd                	li	a5,-1
    211e:	08f51e63          	bne	a0,a5,21ba <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2122:	00005797          	auipc	a5,0x5
    2126:	4a678793          	addi	a5,a5,1190 # 75c8 <malloc+0x1cb2>
    212a:	fcf43823          	sd	a5,-48(s0)
    212e:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2132:	fd040593          	addi	a1,s0,-48
    2136:	8526                	mv	a0,s1
    2138:	00003097          	auipc	ra,0x3
    213c:	3e0080e7          	jalr	992(ra) # 5518 <exec>
  if(ret != -1){
    2140:	57fd                	li	a5,-1
    2142:	08f51c63          	bne	a0,a5,21da <copyinstr3+0x12e>
}
    2146:	70a2                	ld	ra,40(sp)
    2148:	7402                	ld	s0,32(sp)
    214a:	64e2                	ld	s1,24(sp)
    214c:	6145                	addi	sp,sp,48
    214e:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2150:	0347d513          	srli	a0,a5,0x34
    2154:	6785                	lui	a5,0x1
    2156:	40a7853b          	subw	a0,a5,a0
    215a:	00003097          	auipc	ra,0x3
    215e:	40e080e7          	jalr	1038(ra) # 5568 <sbrk>
    2162:	b7bd                	j	20d0 <copyinstr3+0x24>
    printf("oops\n");
    2164:	00004517          	auipc	a0,0x4
    2168:	7f450513          	addi	a0,a0,2036 # 6958 <malloc+0x1042>
    216c:	00003097          	auipc	ra,0x3
    2170:	6ec080e7          	jalr	1772(ra) # 5858 <printf>
    exit(1);
    2174:	4505                	li	a0,1
    2176:	00003097          	auipc	ra,0x3
    217a:	36a080e7          	jalr	874(ra) # 54e0 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    217e:	862a                	mv	a2,a0
    2180:	85a6                	mv	a1,s1
    2182:	00004517          	auipc	a0,0x4
    2186:	2f650513          	addi	a0,a0,758 # 6478 <malloc+0xb62>
    218a:	00003097          	auipc	ra,0x3
    218e:	6ce080e7          	jalr	1742(ra) # 5858 <printf>
    exit(1);
    2192:	4505                	li	a0,1
    2194:	00003097          	auipc	ra,0x3
    2198:	34c080e7          	jalr	844(ra) # 54e0 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    219c:	862a                	mv	a2,a0
    219e:	85a6                	mv	a1,s1
    21a0:	00004517          	auipc	a0,0x4
    21a4:	2f850513          	addi	a0,a0,760 # 6498 <malloc+0xb82>
    21a8:	00003097          	auipc	ra,0x3
    21ac:	6b0080e7          	jalr	1712(ra) # 5858 <printf>
    exit(1);
    21b0:	4505                	li	a0,1
    21b2:	00003097          	auipc	ra,0x3
    21b6:	32e080e7          	jalr	814(ra) # 54e0 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    21ba:	86aa                	mv	a3,a0
    21bc:	8626                	mv	a2,s1
    21be:	85a6                	mv	a1,s1
    21c0:	00004517          	auipc	a0,0x4
    21c4:	2f850513          	addi	a0,a0,760 # 64b8 <malloc+0xba2>
    21c8:	00003097          	auipc	ra,0x3
    21cc:	690080e7          	jalr	1680(ra) # 5858 <printf>
    exit(1);
    21d0:	4505                	li	a0,1
    21d2:	00003097          	auipc	ra,0x3
    21d6:	30e080e7          	jalr	782(ra) # 54e0 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    21da:	567d                	li	a2,-1
    21dc:	85a6                	mv	a1,s1
    21de:	00004517          	auipc	a0,0x4
    21e2:	30250513          	addi	a0,a0,770 # 64e0 <malloc+0xbca>
    21e6:	00003097          	auipc	ra,0x3
    21ea:	672080e7          	jalr	1650(ra) # 5858 <printf>
    exit(1);
    21ee:	4505                	li	a0,1
    21f0:	00003097          	auipc	ra,0x3
    21f4:	2f0080e7          	jalr	752(ra) # 54e0 <exit>

00000000000021f8 <rwsbrk>:
{
    21f8:	1101                	addi	sp,sp,-32
    21fa:	ec06                	sd	ra,24(sp)
    21fc:	e822                	sd	s0,16(sp)
    21fe:	e426                	sd	s1,8(sp)
    2200:	e04a                	sd	s2,0(sp)
    2202:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2204:	6509                	lui	a0,0x2
    2206:	00003097          	auipc	ra,0x3
    220a:	362080e7          	jalr	866(ra) # 5568 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    220e:	57fd                	li	a5,-1
    2210:	06f50363          	beq	a0,a5,2276 <rwsbrk+0x7e>
    2214:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2216:	7579                	lui	a0,0xffffe
    2218:	00003097          	auipc	ra,0x3
    221c:	350080e7          	jalr	848(ra) # 5568 <sbrk>
    2220:	57fd                	li	a5,-1
    2222:	06f50763          	beq	a0,a5,2290 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2226:	20100593          	li	a1,513
    222a:	00004517          	auipc	a0,0x4
    222e:	83e50513          	addi	a0,a0,-1986 # 5a68 <malloc+0x152>
    2232:	00003097          	auipc	ra,0x3
    2236:	2ee080e7          	jalr	750(ra) # 5520 <open>
    223a:	892a                	mv	s2,a0
  if(fd < 0){
    223c:	06054763          	bltz	a0,22aa <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    2240:	6505                	lui	a0,0x1
    2242:	94aa                	add	s1,s1,a0
    2244:	40000613          	li	a2,1024
    2248:	85a6                	mv	a1,s1
    224a:	854a                	mv	a0,s2
    224c:	00003097          	auipc	ra,0x3
    2250:	2b4080e7          	jalr	692(ra) # 5500 <write>
    2254:	862a                	mv	a2,a0
  if(n >= 0){
    2256:	06054763          	bltz	a0,22c4 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    225a:	85a6                	mv	a1,s1
    225c:	00004517          	auipc	a0,0x4
    2260:	75450513          	addi	a0,a0,1876 # 69b0 <malloc+0x109a>
    2264:	00003097          	auipc	ra,0x3
    2268:	5f4080e7          	jalr	1524(ra) # 5858 <printf>
    exit(1);
    226c:	4505                	li	a0,1
    226e:	00003097          	auipc	ra,0x3
    2272:	272080e7          	jalr	626(ra) # 54e0 <exit>
    printf("sbrk(rwsbrk) failed\n");
    2276:	00004517          	auipc	a0,0x4
    227a:	6ea50513          	addi	a0,a0,1770 # 6960 <malloc+0x104a>
    227e:	00003097          	auipc	ra,0x3
    2282:	5da080e7          	jalr	1498(ra) # 5858 <printf>
    exit(1);
    2286:	4505                	li	a0,1
    2288:	00003097          	auipc	ra,0x3
    228c:	258080e7          	jalr	600(ra) # 54e0 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    2290:	00004517          	auipc	a0,0x4
    2294:	6e850513          	addi	a0,a0,1768 # 6978 <malloc+0x1062>
    2298:	00003097          	auipc	ra,0x3
    229c:	5c0080e7          	jalr	1472(ra) # 5858 <printf>
    exit(1);
    22a0:	4505                	li	a0,1
    22a2:	00003097          	auipc	ra,0x3
    22a6:	23e080e7          	jalr	574(ra) # 54e0 <exit>
    printf("open(rwsbrk) failed\n");
    22aa:	00004517          	auipc	a0,0x4
    22ae:	6ee50513          	addi	a0,a0,1774 # 6998 <malloc+0x1082>
    22b2:	00003097          	auipc	ra,0x3
    22b6:	5a6080e7          	jalr	1446(ra) # 5858 <printf>
    exit(1);
    22ba:	4505                	li	a0,1
    22bc:	00003097          	auipc	ra,0x3
    22c0:	224080e7          	jalr	548(ra) # 54e0 <exit>
  close(fd);
    22c4:	854a                	mv	a0,s2
    22c6:	00003097          	auipc	ra,0x3
    22ca:	242080e7          	jalr	578(ra) # 5508 <close>
  unlink("rwsbrk");
    22ce:	00003517          	auipc	a0,0x3
    22d2:	79a50513          	addi	a0,a0,1946 # 5a68 <malloc+0x152>
    22d6:	00003097          	auipc	ra,0x3
    22da:	25a080e7          	jalr	602(ra) # 5530 <unlink>
  fd = open("README", O_RDONLY);
    22de:	4581                	li	a1,0
    22e0:	00004517          	auipc	a0,0x4
    22e4:	bd850513          	addi	a0,a0,-1064 # 5eb8 <malloc+0x5a2>
    22e8:	00003097          	auipc	ra,0x3
    22ec:	238080e7          	jalr	568(ra) # 5520 <open>
    22f0:	892a                	mv	s2,a0
  if(fd < 0){
    22f2:	02054963          	bltz	a0,2324 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    22f6:	4629                	li	a2,10
    22f8:	85a6                	mv	a1,s1
    22fa:	00003097          	auipc	ra,0x3
    22fe:	1fe080e7          	jalr	510(ra) # 54f8 <read>
    2302:	862a                	mv	a2,a0
  if(n >= 0){
    2304:	02054d63          	bltz	a0,233e <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2308:	85a6                	mv	a1,s1
    230a:	00004517          	auipc	a0,0x4
    230e:	6d650513          	addi	a0,a0,1750 # 69e0 <malloc+0x10ca>
    2312:	00003097          	auipc	ra,0x3
    2316:	546080e7          	jalr	1350(ra) # 5858 <printf>
    exit(1);
    231a:	4505                	li	a0,1
    231c:	00003097          	auipc	ra,0x3
    2320:	1c4080e7          	jalr	452(ra) # 54e0 <exit>
    printf("open(rwsbrk) failed\n");
    2324:	00004517          	auipc	a0,0x4
    2328:	67450513          	addi	a0,a0,1652 # 6998 <malloc+0x1082>
    232c:	00003097          	auipc	ra,0x3
    2330:	52c080e7          	jalr	1324(ra) # 5858 <printf>
    exit(1);
    2334:	4505                	li	a0,1
    2336:	00003097          	auipc	ra,0x3
    233a:	1aa080e7          	jalr	426(ra) # 54e0 <exit>
  close(fd);
    233e:	854a                	mv	a0,s2
    2340:	00003097          	auipc	ra,0x3
    2344:	1c8080e7          	jalr	456(ra) # 5508 <close>
  exit(0);
    2348:	4501                	li	a0,0
    234a:	00003097          	auipc	ra,0x3
    234e:	196080e7          	jalr	406(ra) # 54e0 <exit>

0000000000002352 <sbrkbasic>:
{
    2352:	715d                	addi	sp,sp,-80
    2354:	e486                	sd	ra,72(sp)
    2356:	e0a2                	sd	s0,64(sp)
    2358:	fc26                	sd	s1,56(sp)
    235a:	f84a                	sd	s2,48(sp)
    235c:	f44e                	sd	s3,40(sp)
    235e:	f052                	sd	s4,32(sp)
    2360:	ec56                	sd	s5,24(sp)
    2362:	0880                	addi	s0,sp,80
    2364:	8a2a                	mv	s4,a0
  pid = fork();
    2366:	00003097          	auipc	ra,0x3
    236a:	172080e7          	jalr	370(ra) # 54d8 <fork>
  if(pid < 0){
    236e:	02054c63          	bltz	a0,23a6 <sbrkbasic+0x54>
  if(pid == 0){
    2372:	ed21                	bnez	a0,23ca <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    2374:	40000537          	lui	a0,0x40000
    2378:	00003097          	auipc	ra,0x3
    237c:	1f0080e7          	jalr	496(ra) # 5568 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    2380:	57fd                	li	a5,-1
    2382:	02f50f63          	beq	a0,a5,23c0 <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2386:	400007b7          	lui	a5,0x40000
    238a:	97aa                	add	a5,a5,a0
      *b = 99;
    238c:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2390:	6705                	lui	a4,0x1
      *b = 99;
    2392:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1708>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2396:	953a                	add	a0,a0,a4
    2398:	fef51de3          	bne	a0,a5,2392 <sbrkbasic+0x40>
    exit(1);
    239c:	4505                	li	a0,1
    239e:	00003097          	auipc	ra,0x3
    23a2:	142080e7          	jalr	322(ra) # 54e0 <exit>
    printf("fork failed in sbrkbasic\n");
    23a6:	00004517          	auipc	a0,0x4
    23aa:	66250513          	addi	a0,a0,1634 # 6a08 <malloc+0x10f2>
    23ae:	00003097          	auipc	ra,0x3
    23b2:	4aa080e7          	jalr	1194(ra) # 5858 <printf>
    exit(1);
    23b6:	4505                	li	a0,1
    23b8:	00003097          	auipc	ra,0x3
    23bc:	128080e7          	jalr	296(ra) # 54e0 <exit>
      exit(0);
    23c0:	4501                	li	a0,0
    23c2:	00003097          	auipc	ra,0x3
    23c6:	11e080e7          	jalr	286(ra) # 54e0 <exit>
  wait(&xstatus);
    23ca:	fbc40513          	addi	a0,s0,-68
    23ce:	00003097          	auipc	ra,0x3
    23d2:	11a080e7          	jalr	282(ra) # 54e8 <wait>
  if(xstatus == 1){
    23d6:	fbc42703          	lw	a4,-68(s0)
    23da:	4785                	li	a5,1
    23dc:	00f70e63          	beq	a4,a5,23f8 <sbrkbasic+0xa6>
  a = sbrk(0);
    23e0:	4501                	li	a0,0
    23e2:	00003097          	auipc	ra,0x3
    23e6:	186080e7          	jalr	390(ra) # 5568 <sbrk>
    23ea:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    23ec:	4901                	li	s2,0
    *b = 1;
    23ee:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    23f0:	6985                	lui	s3,0x1
    23f2:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1c2>
    23f6:	a005                	j	2416 <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    23f8:	85d2                	mv	a1,s4
    23fa:	00004517          	auipc	a0,0x4
    23fe:	62e50513          	addi	a0,a0,1582 # 6a28 <malloc+0x1112>
    2402:	00003097          	auipc	ra,0x3
    2406:	456080e7          	jalr	1110(ra) # 5858 <printf>
    exit(1);
    240a:	4505                	li	a0,1
    240c:	00003097          	auipc	ra,0x3
    2410:	0d4080e7          	jalr	212(ra) # 54e0 <exit>
    a = b + 1;
    2414:	84be                	mv	s1,a5
    b = sbrk(1);
    2416:	4505                	li	a0,1
    2418:	00003097          	auipc	ra,0x3
    241c:	150080e7          	jalr	336(ra) # 5568 <sbrk>
    if(b != a){
    2420:	04951b63          	bne	a0,s1,2476 <sbrkbasic+0x124>
    *b = 1;
    2424:	01548023          	sb	s5,0(s1)
    a = b + 1;
    2428:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    242c:	2905                	addiw	s2,s2,1
    242e:	ff3913e3          	bne	s2,s3,2414 <sbrkbasic+0xc2>
  pid = fork();
    2432:	00003097          	auipc	ra,0x3
    2436:	0a6080e7          	jalr	166(ra) # 54d8 <fork>
    243a:	892a                	mv	s2,a0
  if(pid < 0){
    243c:	04054d63          	bltz	a0,2496 <sbrkbasic+0x144>
  c = sbrk(1);
    2440:	4505                	li	a0,1
    2442:	00003097          	auipc	ra,0x3
    2446:	126080e7          	jalr	294(ra) # 5568 <sbrk>
  c = sbrk(1);
    244a:	4505                	li	a0,1
    244c:	00003097          	auipc	ra,0x3
    2450:	11c080e7          	jalr	284(ra) # 5568 <sbrk>
  if(c != a + 1){
    2454:	0489                	addi	s1,s1,2
    2456:	04a48e63          	beq	s1,a0,24b2 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    245a:	85d2                	mv	a1,s4
    245c:	00004517          	auipc	a0,0x4
    2460:	62c50513          	addi	a0,a0,1580 # 6a88 <malloc+0x1172>
    2464:	00003097          	auipc	ra,0x3
    2468:	3f4080e7          	jalr	1012(ra) # 5858 <printf>
    exit(1);
    246c:	4505                	li	a0,1
    246e:	00003097          	auipc	ra,0x3
    2472:	072080e7          	jalr	114(ra) # 54e0 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    2476:	86aa                	mv	a3,a0
    2478:	8626                	mv	a2,s1
    247a:	85ca                	mv	a1,s2
    247c:	00004517          	auipc	a0,0x4
    2480:	5cc50513          	addi	a0,a0,1484 # 6a48 <malloc+0x1132>
    2484:	00003097          	auipc	ra,0x3
    2488:	3d4080e7          	jalr	980(ra) # 5858 <printf>
      exit(1);
    248c:	4505                	li	a0,1
    248e:	00003097          	auipc	ra,0x3
    2492:	052080e7          	jalr	82(ra) # 54e0 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2496:	85d2                	mv	a1,s4
    2498:	00004517          	auipc	a0,0x4
    249c:	5d050513          	addi	a0,a0,1488 # 6a68 <malloc+0x1152>
    24a0:	00003097          	auipc	ra,0x3
    24a4:	3b8080e7          	jalr	952(ra) # 5858 <printf>
    exit(1);
    24a8:	4505                	li	a0,1
    24aa:	00003097          	auipc	ra,0x3
    24ae:	036080e7          	jalr	54(ra) # 54e0 <exit>
  if(pid == 0)
    24b2:	00091763          	bnez	s2,24c0 <sbrkbasic+0x16e>
    exit(0);
    24b6:	4501                	li	a0,0
    24b8:	00003097          	auipc	ra,0x3
    24bc:	028080e7          	jalr	40(ra) # 54e0 <exit>
  wait(&xstatus);
    24c0:	fbc40513          	addi	a0,s0,-68
    24c4:	00003097          	auipc	ra,0x3
    24c8:	024080e7          	jalr	36(ra) # 54e8 <wait>
  exit(xstatus);
    24cc:	fbc42503          	lw	a0,-68(s0)
    24d0:	00003097          	auipc	ra,0x3
    24d4:	010080e7          	jalr	16(ra) # 54e0 <exit>

00000000000024d8 <sbrkmuch>:
{
    24d8:	7179                	addi	sp,sp,-48
    24da:	f406                	sd	ra,40(sp)
    24dc:	f022                	sd	s0,32(sp)
    24de:	ec26                	sd	s1,24(sp)
    24e0:	e84a                	sd	s2,16(sp)
    24e2:	e44e                	sd	s3,8(sp)
    24e4:	e052                	sd	s4,0(sp)
    24e6:	1800                	addi	s0,sp,48
    24e8:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    24ea:	4501                	li	a0,0
    24ec:	00003097          	auipc	ra,0x3
    24f0:	07c080e7          	jalr	124(ra) # 5568 <sbrk>
    24f4:	892a                	mv	s2,a0
  a = sbrk(0);
    24f6:	4501                	li	a0,0
    24f8:	00003097          	auipc	ra,0x3
    24fc:	070080e7          	jalr	112(ra) # 5568 <sbrk>
    2500:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2502:	06400537          	lui	a0,0x6400
    2506:	9d05                	subw	a0,a0,s1
    2508:	00003097          	auipc	ra,0x3
    250c:	060080e7          	jalr	96(ra) # 5568 <sbrk>
  if (p != a) {
    2510:	0ca49863          	bne	s1,a0,25e0 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2514:	4501                	li	a0,0
    2516:	00003097          	auipc	ra,0x3
    251a:	052080e7          	jalr	82(ra) # 5568 <sbrk>
    251e:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2520:	00a4f963          	bgeu	s1,a0,2532 <sbrkmuch+0x5a>
    *pp = 1;
    2524:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2526:	6705                	lui	a4,0x1
    *pp = 1;
    2528:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    252c:	94ba                	add	s1,s1,a4
    252e:	fef4ede3          	bltu	s1,a5,2528 <sbrkmuch+0x50>
  *lastaddr = 99;
    2532:	064007b7          	lui	a5,0x6400
    2536:	06300713          	li	a4,99
    253a:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f1707>
  a = sbrk(0);
    253e:	4501                	li	a0,0
    2540:	00003097          	auipc	ra,0x3
    2544:	028080e7          	jalr	40(ra) # 5568 <sbrk>
    2548:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    254a:	757d                	lui	a0,0xfffff
    254c:	00003097          	auipc	ra,0x3
    2550:	01c080e7          	jalr	28(ra) # 5568 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2554:	57fd                	li	a5,-1
    2556:	0af50363          	beq	a0,a5,25fc <sbrkmuch+0x124>
  c = sbrk(0);
    255a:	4501                	li	a0,0
    255c:	00003097          	auipc	ra,0x3
    2560:	00c080e7          	jalr	12(ra) # 5568 <sbrk>
  if(c != a - PGSIZE){
    2564:	77fd                	lui	a5,0xfffff
    2566:	97a6                	add	a5,a5,s1
    2568:	0af51863          	bne	a0,a5,2618 <sbrkmuch+0x140>
  a = sbrk(0);
    256c:	4501                	li	a0,0
    256e:	00003097          	auipc	ra,0x3
    2572:	ffa080e7          	jalr	-6(ra) # 5568 <sbrk>
    2576:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2578:	6505                	lui	a0,0x1
    257a:	00003097          	auipc	ra,0x3
    257e:	fee080e7          	jalr	-18(ra) # 5568 <sbrk>
    2582:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2584:	0aa49a63          	bne	s1,a0,2638 <sbrkmuch+0x160>
    2588:	4501                	li	a0,0
    258a:	00003097          	auipc	ra,0x3
    258e:	fde080e7          	jalr	-34(ra) # 5568 <sbrk>
    2592:	6785                	lui	a5,0x1
    2594:	97a6                	add	a5,a5,s1
    2596:	0af51163          	bne	a0,a5,2638 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    259a:	064007b7          	lui	a5,0x6400
    259e:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f1707>
    25a2:	06300793          	li	a5,99
    25a6:	0af70963          	beq	a4,a5,2658 <sbrkmuch+0x180>
  a = sbrk(0);
    25aa:	4501                	li	a0,0
    25ac:	00003097          	auipc	ra,0x3
    25b0:	fbc080e7          	jalr	-68(ra) # 5568 <sbrk>
    25b4:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    25b6:	4501                	li	a0,0
    25b8:	00003097          	auipc	ra,0x3
    25bc:	fb0080e7          	jalr	-80(ra) # 5568 <sbrk>
    25c0:	40a9053b          	subw	a0,s2,a0
    25c4:	00003097          	auipc	ra,0x3
    25c8:	fa4080e7          	jalr	-92(ra) # 5568 <sbrk>
  if(c != a){
    25cc:	0aa49463          	bne	s1,a0,2674 <sbrkmuch+0x19c>
}
    25d0:	70a2                	ld	ra,40(sp)
    25d2:	7402                	ld	s0,32(sp)
    25d4:	64e2                	ld	s1,24(sp)
    25d6:	6942                	ld	s2,16(sp)
    25d8:	69a2                	ld	s3,8(sp)
    25da:	6a02                	ld	s4,0(sp)
    25dc:	6145                	addi	sp,sp,48
    25de:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    25e0:	85ce                	mv	a1,s3
    25e2:	00004517          	auipc	a0,0x4
    25e6:	4c650513          	addi	a0,a0,1222 # 6aa8 <malloc+0x1192>
    25ea:	00003097          	auipc	ra,0x3
    25ee:	26e080e7          	jalr	622(ra) # 5858 <printf>
    exit(1);
    25f2:	4505                	li	a0,1
    25f4:	00003097          	auipc	ra,0x3
    25f8:	eec080e7          	jalr	-276(ra) # 54e0 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    25fc:	85ce                	mv	a1,s3
    25fe:	00004517          	auipc	a0,0x4
    2602:	4f250513          	addi	a0,a0,1266 # 6af0 <malloc+0x11da>
    2606:	00003097          	auipc	ra,0x3
    260a:	252080e7          	jalr	594(ra) # 5858 <printf>
    exit(1);
    260e:	4505                	li	a0,1
    2610:	00003097          	auipc	ra,0x3
    2614:	ed0080e7          	jalr	-304(ra) # 54e0 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2618:	86aa                	mv	a3,a0
    261a:	8626                	mv	a2,s1
    261c:	85ce                	mv	a1,s3
    261e:	00004517          	auipc	a0,0x4
    2622:	4f250513          	addi	a0,a0,1266 # 6b10 <malloc+0x11fa>
    2626:	00003097          	auipc	ra,0x3
    262a:	232080e7          	jalr	562(ra) # 5858 <printf>
    exit(1);
    262e:	4505                	li	a0,1
    2630:	00003097          	auipc	ra,0x3
    2634:	eb0080e7          	jalr	-336(ra) # 54e0 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2638:	86d2                	mv	a3,s4
    263a:	8626                	mv	a2,s1
    263c:	85ce                	mv	a1,s3
    263e:	00004517          	auipc	a0,0x4
    2642:	51250513          	addi	a0,a0,1298 # 6b50 <malloc+0x123a>
    2646:	00003097          	auipc	ra,0x3
    264a:	212080e7          	jalr	530(ra) # 5858 <printf>
    exit(1);
    264e:	4505                	li	a0,1
    2650:	00003097          	auipc	ra,0x3
    2654:	e90080e7          	jalr	-368(ra) # 54e0 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2658:	85ce                	mv	a1,s3
    265a:	00004517          	auipc	a0,0x4
    265e:	52650513          	addi	a0,a0,1318 # 6b80 <malloc+0x126a>
    2662:	00003097          	auipc	ra,0x3
    2666:	1f6080e7          	jalr	502(ra) # 5858 <printf>
    exit(1);
    266a:	4505                	li	a0,1
    266c:	00003097          	auipc	ra,0x3
    2670:	e74080e7          	jalr	-396(ra) # 54e0 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2674:	86aa                	mv	a3,a0
    2676:	8626                	mv	a2,s1
    2678:	85ce                	mv	a1,s3
    267a:	00004517          	auipc	a0,0x4
    267e:	53e50513          	addi	a0,a0,1342 # 6bb8 <malloc+0x12a2>
    2682:	00003097          	auipc	ra,0x3
    2686:	1d6080e7          	jalr	470(ra) # 5858 <printf>
    exit(1);
    268a:	4505                	li	a0,1
    268c:	00003097          	auipc	ra,0x3
    2690:	e54080e7          	jalr	-428(ra) # 54e0 <exit>

0000000000002694 <sbrkarg>:
{
    2694:	7179                	addi	sp,sp,-48
    2696:	f406                	sd	ra,40(sp)
    2698:	f022                	sd	s0,32(sp)
    269a:	ec26                	sd	s1,24(sp)
    269c:	e84a                	sd	s2,16(sp)
    269e:	e44e                	sd	s3,8(sp)
    26a0:	1800                	addi	s0,sp,48
    26a2:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    26a4:	6505                	lui	a0,0x1
    26a6:	00003097          	auipc	ra,0x3
    26aa:	ec2080e7          	jalr	-318(ra) # 5568 <sbrk>
    26ae:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    26b0:	20100593          	li	a1,513
    26b4:	00004517          	auipc	a0,0x4
    26b8:	52c50513          	addi	a0,a0,1324 # 6be0 <malloc+0x12ca>
    26bc:	00003097          	auipc	ra,0x3
    26c0:	e64080e7          	jalr	-412(ra) # 5520 <open>
    26c4:	84aa                	mv	s1,a0
  unlink("sbrk");
    26c6:	00004517          	auipc	a0,0x4
    26ca:	51a50513          	addi	a0,a0,1306 # 6be0 <malloc+0x12ca>
    26ce:	00003097          	auipc	ra,0x3
    26d2:	e62080e7          	jalr	-414(ra) # 5530 <unlink>
  if(fd < 0)  {
    26d6:	0404c163          	bltz	s1,2718 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    26da:	6605                	lui	a2,0x1
    26dc:	85ca                	mv	a1,s2
    26de:	8526                	mv	a0,s1
    26e0:	00003097          	auipc	ra,0x3
    26e4:	e20080e7          	jalr	-480(ra) # 5500 <write>
    26e8:	04054663          	bltz	a0,2734 <sbrkarg+0xa0>
  close(fd);
    26ec:	8526                	mv	a0,s1
    26ee:	00003097          	auipc	ra,0x3
    26f2:	e1a080e7          	jalr	-486(ra) # 5508 <close>
  a = sbrk(PGSIZE);
    26f6:	6505                	lui	a0,0x1
    26f8:	00003097          	auipc	ra,0x3
    26fc:	e70080e7          	jalr	-400(ra) # 5568 <sbrk>
  if(pipe((int *) a) != 0){
    2700:	00003097          	auipc	ra,0x3
    2704:	df0080e7          	jalr	-528(ra) # 54f0 <pipe>
    2708:	e521                	bnez	a0,2750 <sbrkarg+0xbc>
}
    270a:	70a2                	ld	ra,40(sp)
    270c:	7402                	ld	s0,32(sp)
    270e:	64e2                	ld	s1,24(sp)
    2710:	6942                	ld	s2,16(sp)
    2712:	69a2                	ld	s3,8(sp)
    2714:	6145                	addi	sp,sp,48
    2716:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2718:	85ce                	mv	a1,s3
    271a:	00004517          	auipc	a0,0x4
    271e:	4ce50513          	addi	a0,a0,1230 # 6be8 <malloc+0x12d2>
    2722:	00003097          	auipc	ra,0x3
    2726:	136080e7          	jalr	310(ra) # 5858 <printf>
    exit(1);
    272a:	4505                	li	a0,1
    272c:	00003097          	auipc	ra,0x3
    2730:	db4080e7          	jalr	-588(ra) # 54e0 <exit>
    printf("%s: write sbrk failed\n", s);
    2734:	85ce                	mv	a1,s3
    2736:	00004517          	auipc	a0,0x4
    273a:	4ca50513          	addi	a0,a0,1226 # 6c00 <malloc+0x12ea>
    273e:	00003097          	auipc	ra,0x3
    2742:	11a080e7          	jalr	282(ra) # 5858 <printf>
    exit(1);
    2746:	4505                	li	a0,1
    2748:	00003097          	auipc	ra,0x3
    274c:	d98080e7          	jalr	-616(ra) # 54e0 <exit>
    printf("%s: pipe() failed\n", s);
    2750:	85ce                	mv	a1,s3
    2752:	00004517          	auipc	a0,0x4
    2756:	f0e50513          	addi	a0,a0,-242 # 6660 <malloc+0xd4a>
    275a:	00003097          	auipc	ra,0x3
    275e:	0fe080e7          	jalr	254(ra) # 5858 <printf>
    exit(1);
    2762:	4505                	li	a0,1
    2764:	00003097          	auipc	ra,0x3
    2768:	d7c080e7          	jalr	-644(ra) # 54e0 <exit>

000000000000276c <argptest>:
{
    276c:	1101                	addi	sp,sp,-32
    276e:	ec06                	sd	ra,24(sp)
    2770:	e822                	sd	s0,16(sp)
    2772:	e426                	sd	s1,8(sp)
    2774:	e04a                	sd	s2,0(sp)
    2776:	1000                	addi	s0,sp,32
    2778:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    277a:	4581                	li	a1,0
    277c:	00004517          	auipc	a0,0x4
    2780:	49c50513          	addi	a0,a0,1180 # 6c18 <malloc+0x1302>
    2784:	00003097          	auipc	ra,0x3
    2788:	d9c080e7          	jalr	-612(ra) # 5520 <open>
  if (fd < 0) {
    278c:	02054b63          	bltz	a0,27c2 <argptest+0x56>
    2790:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2792:	4501                	li	a0,0
    2794:	00003097          	auipc	ra,0x3
    2798:	dd4080e7          	jalr	-556(ra) # 5568 <sbrk>
    279c:	567d                	li	a2,-1
    279e:	fff50593          	addi	a1,a0,-1
    27a2:	8526                	mv	a0,s1
    27a4:	00003097          	auipc	ra,0x3
    27a8:	d54080e7          	jalr	-684(ra) # 54f8 <read>
  close(fd);
    27ac:	8526                	mv	a0,s1
    27ae:	00003097          	auipc	ra,0x3
    27b2:	d5a080e7          	jalr	-678(ra) # 5508 <close>
}
    27b6:	60e2                	ld	ra,24(sp)
    27b8:	6442                	ld	s0,16(sp)
    27ba:	64a2                	ld	s1,8(sp)
    27bc:	6902                	ld	s2,0(sp)
    27be:	6105                	addi	sp,sp,32
    27c0:	8082                	ret
    printf("%s: open failed\n", s);
    27c2:	85ca                	mv	a1,s2
    27c4:	00004517          	auipc	a0,0x4
    27c8:	dac50513          	addi	a0,a0,-596 # 6570 <malloc+0xc5a>
    27cc:	00003097          	auipc	ra,0x3
    27d0:	08c080e7          	jalr	140(ra) # 5858 <printf>
    exit(1);
    27d4:	4505                	li	a0,1
    27d6:	00003097          	auipc	ra,0x3
    27da:	d0a080e7          	jalr	-758(ra) # 54e0 <exit>

00000000000027de <sbrkbugs>:
{
    27de:	1141                	addi	sp,sp,-16
    27e0:	e406                	sd	ra,8(sp)
    27e2:	e022                	sd	s0,0(sp)
    27e4:	0800                	addi	s0,sp,16
  int pid = fork();
    27e6:	00003097          	auipc	ra,0x3
    27ea:	cf2080e7          	jalr	-782(ra) # 54d8 <fork>
  if(pid < 0){
    27ee:	02054263          	bltz	a0,2812 <sbrkbugs+0x34>
  if(pid == 0){
    27f2:	ed0d                	bnez	a0,282c <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    27f4:	00003097          	auipc	ra,0x3
    27f8:	d74080e7          	jalr	-652(ra) # 5568 <sbrk>
    sbrk(-sz);
    27fc:	40a0053b          	negw	a0,a0
    2800:	00003097          	auipc	ra,0x3
    2804:	d68080e7          	jalr	-664(ra) # 5568 <sbrk>
    exit(0);
    2808:	4501                	li	a0,0
    280a:	00003097          	auipc	ra,0x3
    280e:	cd6080e7          	jalr	-810(ra) # 54e0 <exit>
    printf("fork failed\n");
    2812:	00004517          	auipc	a0,0x4
    2816:	11650513          	addi	a0,a0,278 # 6928 <malloc+0x1012>
    281a:	00003097          	auipc	ra,0x3
    281e:	03e080e7          	jalr	62(ra) # 5858 <printf>
    exit(1);
    2822:	4505                	li	a0,1
    2824:	00003097          	auipc	ra,0x3
    2828:	cbc080e7          	jalr	-836(ra) # 54e0 <exit>
  wait(0);
    282c:	4501                	li	a0,0
    282e:	00003097          	auipc	ra,0x3
    2832:	cba080e7          	jalr	-838(ra) # 54e8 <wait>
  pid = fork();
    2836:	00003097          	auipc	ra,0x3
    283a:	ca2080e7          	jalr	-862(ra) # 54d8 <fork>
  if(pid < 0){
    283e:	02054563          	bltz	a0,2868 <sbrkbugs+0x8a>
  if(pid == 0){
    2842:	e121                	bnez	a0,2882 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2844:	00003097          	auipc	ra,0x3
    2848:	d24080e7          	jalr	-732(ra) # 5568 <sbrk>
    sbrk(-(sz - 3500));
    284c:	6785                	lui	a5,0x1
    284e:	dac7879b          	addiw	a5,a5,-596
    2852:	40a7853b          	subw	a0,a5,a0
    2856:	00003097          	auipc	ra,0x3
    285a:	d12080e7          	jalr	-750(ra) # 5568 <sbrk>
    exit(0);
    285e:	4501                	li	a0,0
    2860:	00003097          	auipc	ra,0x3
    2864:	c80080e7          	jalr	-896(ra) # 54e0 <exit>
    printf("fork failed\n");
    2868:	00004517          	auipc	a0,0x4
    286c:	0c050513          	addi	a0,a0,192 # 6928 <malloc+0x1012>
    2870:	00003097          	auipc	ra,0x3
    2874:	fe8080e7          	jalr	-24(ra) # 5858 <printf>
    exit(1);
    2878:	4505                	li	a0,1
    287a:	00003097          	auipc	ra,0x3
    287e:	c66080e7          	jalr	-922(ra) # 54e0 <exit>
  wait(0);
    2882:	4501                	li	a0,0
    2884:	00003097          	auipc	ra,0x3
    2888:	c64080e7          	jalr	-924(ra) # 54e8 <wait>
  pid = fork();
    288c:	00003097          	auipc	ra,0x3
    2890:	c4c080e7          	jalr	-948(ra) # 54d8 <fork>
  if(pid < 0){
    2894:	02054a63          	bltz	a0,28c8 <sbrkbugs+0xea>
  if(pid == 0){
    2898:	e529                	bnez	a0,28e2 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    289a:	00003097          	auipc	ra,0x3
    289e:	cce080e7          	jalr	-818(ra) # 5568 <sbrk>
    28a2:	67ad                	lui	a5,0xb
    28a4:	8007879b          	addiw	a5,a5,-2048
    28a8:	40a7853b          	subw	a0,a5,a0
    28ac:	00003097          	auipc	ra,0x3
    28b0:	cbc080e7          	jalr	-836(ra) # 5568 <sbrk>
    sbrk(-10);
    28b4:	5559                	li	a0,-10
    28b6:	00003097          	auipc	ra,0x3
    28ba:	cb2080e7          	jalr	-846(ra) # 5568 <sbrk>
    exit(0);
    28be:	4501                	li	a0,0
    28c0:	00003097          	auipc	ra,0x3
    28c4:	c20080e7          	jalr	-992(ra) # 54e0 <exit>
    printf("fork failed\n");
    28c8:	00004517          	auipc	a0,0x4
    28cc:	06050513          	addi	a0,a0,96 # 6928 <malloc+0x1012>
    28d0:	00003097          	auipc	ra,0x3
    28d4:	f88080e7          	jalr	-120(ra) # 5858 <printf>
    exit(1);
    28d8:	4505                	li	a0,1
    28da:	00003097          	auipc	ra,0x3
    28de:	c06080e7          	jalr	-1018(ra) # 54e0 <exit>
  wait(0);
    28e2:	4501                	li	a0,0
    28e4:	00003097          	auipc	ra,0x3
    28e8:	c04080e7          	jalr	-1020(ra) # 54e8 <wait>
  exit(0);
    28ec:	4501                	li	a0,0
    28ee:	00003097          	auipc	ra,0x3
    28f2:	bf2080e7          	jalr	-1038(ra) # 54e0 <exit>

00000000000028f6 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    28f6:	715d                	addi	sp,sp,-80
    28f8:	e486                	sd	ra,72(sp)
    28fa:	e0a2                	sd	s0,64(sp)
    28fc:	fc26                	sd	s1,56(sp)
    28fe:	f84a                	sd	s2,48(sp)
    2900:	f44e                	sd	s3,40(sp)
    2902:	f052                	sd	s4,32(sp)
    2904:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2906:	4901                	li	s2,0
    2908:	49bd                	li	s3,15
    int pid = fork();
    290a:	00003097          	auipc	ra,0x3
    290e:	bce080e7          	jalr	-1074(ra) # 54d8 <fork>
    2912:	84aa                	mv	s1,a0
    if(pid < 0){
    2914:	02054063          	bltz	a0,2934 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2918:	c91d                	beqz	a0,294e <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    291a:	4501                	li	a0,0
    291c:	00003097          	auipc	ra,0x3
    2920:	bcc080e7          	jalr	-1076(ra) # 54e8 <wait>
  for(int avail = 0; avail < 15; avail++){
    2924:	2905                	addiw	s2,s2,1
    2926:	ff3912e3          	bne	s2,s3,290a <execout+0x14>
    }
  }

  exit(0);
    292a:	4501                	li	a0,0
    292c:	00003097          	auipc	ra,0x3
    2930:	bb4080e7          	jalr	-1100(ra) # 54e0 <exit>
      printf("fork failed\n");
    2934:	00004517          	auipc	a0,0x4
    2938:	ff450513          	addi	a0,a0,-12 # 6928 <malloc+0x1012>
    293c:	00003097          	auipc	ra,0x3
    2940:	f1c080e7          	jalr	-228(ra) # 5858 <printf>
      exit(1);
    2944:	4505                	li	a0,1
    2946:	00003097          	auipc	ra,0x3
    294a:	b9a080e7          	jalr	-1126(ra) # 54e0 <exit>
        if(a == 0xffffffffffffffffLL)
    294e:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2950:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2952:	6505                	lui	a0,0x1
    2954:	00003097          	auipc	ra,0x3
    2958:	c14080e7          	jalr	-1004(ra) # 5568 <sbrk>
        if(a == 0xffffffffffffffffLL)
    295c:	01350763          	beq	a0,s3,296a <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2960:	6785                	lui	a5,0x1
    2962:	953e                	add	a0,a0,a5
    2964:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x89>
      while(1){
    2968:	b7ed                	j	2952 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    296a:	01205a63          	blez	s2,297e <execout+0x88>
        sbrk(-4096);
    296e:	757d                	lui	a0,0xfffff
    2970:	00003097          	auipc	ra,0x3
    2974:	bf8080e7          	jalr	-1032(ra) # 5568 <sbrk>
      for(int i = 0; i < avail; i++)
    2978:	2485                	addiw	s1,s1,1
    297a:	ff249ae3          	bne	s1,s2,296e <execout+0x78>
      close(1);
    297e:	4505                	li	a0,1
    2980:	00003097          	auipc	ra,0x3
    2984:	b88080e7          	jalr	-1144(ra) # 5508 <close>
      char *args[] = { "echo", "x", 0 };
    2988:	00003517          	auipc	a0,0x3
    298c:	39850513          	addi	a0,a0,920 # 5d20 <malloc+0x40a>
    2990:	faa43c23          	sd	a0,-72(s0)
    2994:	00003797          	auipc	a5,0x3
    2998:	3fc78793          	addi	a5,a5,1020 # 5d90 <malloc+0x47a>
    299c:	fcf43023          	sd	a5,-64(s0)
    29a0:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    29a4:	fb840593          	addi	a1,s0,-72
    29a8:	00003097          	auipc	ra,0x3
    29ac:	b70080e7          	jalr	-1168(ra) # 5518 <exec>
      exit(0);
    29b0:	4501                	li	a0,0
    29b2:	00003097          	auipc	ra,0x3
    29b6:	b2e080e7          	jalr	-1234(ra) # 54e0 <exit>

00000000000029ba <fourteen>:
{
    29ba:	1101                	addi	sp,sp,-32
    29bc:	ec06                	sd	ra,24(sp)
    29be:	e822                	sd	s0,16(sp)
    29c0:	e426                	sd	s1,8(sp)
    29c2:	1000                	addi	s0,sp,32
    29c4:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    29c6:	00004517          	auipc	a0,0x4
    29ca:	42a50513          	addi	a0,a0,1066 # 6df0 <malloc+0x14da>
    29ce:	00003097          	auipc	ra,0x3
    29d2:	b7a080e7          	jalr	-1158(ra) # 5548 <mkdir>
    29d6:	e165                	bnez	a0,2ab6 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    29d8:	00004517          	auipc	a0,0x4
    29dc:	27050513          	addi	a0,a0,624 # 6c48 <malloc+0x1332>
    29e0:	00003097          	auipc	ra,0x3
    29e4:	b68080e7          	jalr	-1176(ra) # 5548 <mkdir>
    29e8:	e56d                	bnez	a0,2ad2 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    29ea:	20000593          	li	a1,512
    29ee:	00004517          	auipc	a0,0x4
    29f2:	2b250513          	addi	a0,a0,690 # 6ca0 <malloc+0x138a>
    29f6:	00003097          	auipc	ra,0x3
    29fa:	b2a080e7          	jalr	-1238(ra) # 5520 <open>
  if(fd < 0){
    29fe:	0e054863          	bltz	a0,2aee <fourteen+0x134>
  close(fd);
    2a02:	00003097          	auipc	ra,0x3
    2a06:	b06080e7          	jalr	-1274(ra) # 5508 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2a0a:	4581                	li	a1,0
    2a0c:	00004517          	auipc	a0,0x4
    2a10:	30c50513          	addi	a0,a0,780 # 6d18 <malloc+0x1402>
    2a14:	00003097          	auipc	ra,0x3
    2a18:	b0c080e7          	jalr	-1268(ra) # 5520 <open>
  if(fd < 0){
    2a1c:	0e054763          	bltz	a0,2b0a <fourteen+0x150>
  close(fd);
    2a20:	00003097          	auipc	ra,0x3
    2a24:	ae8080e7          	jalr	-1304(ra) # 5508 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2a28:	00004517          	auipc	a0,0x4
    2a2c:	36050513          	addi	a0,a0,864 # 6d88 <malloc+0x1472>
    2a30:	00003097          	auipc	ra,0x3
    2a34:	b18080e7          	jalr	-1256(ra) # 5548 <mkdir>
    2a38:	c57d                	beqz	a0,2b26 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2a3a:	00004517          	auipc	a0,0x4
    2a3e:	3a650513          	addi	a0,a0,934 # 6de0 <malloc+0x14ca>
    2a42:	00003097          	auipc	ra,0x3
    2a46:	b06080e7          	jalr	-1274(ra) # 5548 <mkdir>
    2a4a:	cd65                	beqz	a0,2b42 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2a4c:	00004517          	auipc	a0,0x4
    2a50:	39450513          	addi	a0,a0,916 # 6de0 <malloc+0x14ca>
    2a54:	00003097          	auipc	ra,0x3
    2a58:	adc080e7          	jalr	-1316(ra) # 5530 <unlink>
  unlink("12345678901234/12345678901234");
    2a5c:	00004517          	auipc	a0,0x4
    2a60:	32c50513          	addi	a0,a0,812 # 6d88 <malloc+0x1472>
    2a64:	00003097          	auipc	ra,0x3
    2a68:	acc080e7          	jalr	-1332(ra) # 5530 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2a6c:	00004517          	auipc	a0,0x4
    2a70:	2ac50513          	addi	a0,a0,684 # 6d18 <malloc+0x1402>
    2a74:	00003097          	auipc	ra,0x3
    2a78:	abc080e7          	jalr	-1348(ra) # 5530 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2a7c:	00004517          	auipc	a0,0x4
    2a80:	22450513          	addi	a0,a0,548 # 6ca0 <malloc+0x138a>
    2a84:	00003097          	auipc	ra,0x3
    2a88:	aac080e7          	jalr	-1364(ra) # 5530 <unlink>
  unlink("12345678901234/123456789012345");
    2a8c:	00004517          	auipc	a0,0x4
    2a90:	1bc50513          	addi	a0,a0,444 # 6c48 <malloc+0x1332>
    2a94:	00003097          	auipc	ra,0x3
    2a98:	a9c080e7          	jalr	-1380(ra) # 5530 <unlink>
  unlink("12345678901234");
    2a9c:	00004517          	auipc	a0,0x4
    2aa0:	35450513          	addi	a0,a0,852 # 6df0 <malloc+0x14da>
    2aa4:	00003097          	auipc	ra,0x3
    2aa8:	a8c080e7          	jalr	-1396(ra) # 5530 <unlink>
}
    2aac:	60e2                	ld	ra,24(sp)
    2aae:	6442                	ld	s0,16(sp)
    2ab0:	64a2                	ld	s1,8(sp)
    2ab2:	6105                	addi	sp,sp,32
    2ab4:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2ab6:	85a6                	mv	a1,s1
    2ab8:	00004517          	auipc	a0,0x4
    2abc:	16850513          	addi	a0,a0,360 # 6c20 <malloc+0x130a>
    2ac0:	00003097          	auipc	ra,0x3
    2ac4:	d98080e7          	jalr	-616(ra) # 5858 <printf>
    exit(1);
    2ac8:	4505                	li	a0,1
    2aca:	00003097          	auipc	ra,0x3
    2ace:	a16080e7          	jalr	-1514(ra) # 54e0 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2ad2:	85a6                	mv	a1,s1
    2ad4:	00004517          	auipc	a0,0x4
    2ad8:	19450513          	addi	a0,a0,404 # 6c68 <malloc+0x1352>
    2adc:	00003097          	auipc	ra,0x3
    2ae0:	d7c080e7          	jalr	-644(ra) # 5858 <printf>
    exit(1);
    2ae4:	4505                	li	a0,1
    2ae6:	00003097          	auipc	ra,0x3
    2aea:	9fa080e7          	jalr	-1542(ra) # 54e0 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2aee:	85a6                	mv	a1,s1
    2af0:	00004517          	auipc	a0,0x4
    2af4:	1e050513          	addi	a0,a0,480 # 6cd0 <malloc+0x13ba>
    2af8:	00003097          	auipc	ra,0x3
    2afc:	d60080e7          	jalr	-672(ra) # 5858 <printf>
    exit(1);
    2b00:	4505                	li	a0,1
    2b02:	00003097          	auipc	ra,0x3
    2b06:	9de080e7          	jalr	-1570(ra) # 54e0 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2b0a:	85a6                	mv	a1,s1
    2b0c:	00004517          	auipc	a0,0x4
    2b10:	23c50513          	addi	a0,a0,572 # 6d48 <malloc+0x1432>
    2b14:	00003097          	auipc	ra,0x3
    2b18:	d44080e7          	jalr	-700(ra) # 5858 <printf>
    exit(1);
    2b1c:	4505                	li	a0,1
    2b1e:	00003097          	auipc	ra,0x3
    2b22:	9c2080e7          	jalr	-1598(ra) # 54e0 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2b26:	85a6                	mv	a1,s1
    2b28:	00004517          	auipc	a0,0x4
    2b2c:	28050513          	addi	a0,a0,640 # 6da8 <malloc+0x1492>
    2b30:	00003097          	auipc	ra,0x3
    2b34:	d28080e7          	jalr	-728(ra) # 5858 <printf>
    exit(1);
    2b38:	4505                	li	a0,1
    2b3a:	00003097          	auipc	ra,0x3
    2b3e:	9a6080e7          	jalr	-1626(ra) # 54e0 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2b42:	85a6                	mv	a1,s1
    2b44:	00004517          	auipc	a0,0x4
    2b48:	2bc50513          	addi	a0,a0,700 # 6e00 <malloc+0x14ea>
    2b4c:	00003097          	auipc	ra,0x3
    2b50:	d0c080e7          	jalr	-756(ra) # 5858 <printf>
    exit(1);
    2b54:	4505                	li	a0,1
    2b56:	00003097          	auipc	ra,0x3
    2b5a:	98a080e7          	jalr	-1654(ra) # 54e0 <exit>

0000000000002b5e <iputtest>:
{
    2b5e:	1101                	addi	sp,sp,-32
    2b60:	ec06                	sd	ra,24(sp)
    2b62:	e822                	sd	s0,16(sp)
    2b64:	e426                	sd	s1,8(sp)
    2b66:	1000                	addi	s0,sp,32
    2b68:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2b6a:	00004517          	auipc	a0,0x4
    2b6e:	2ce50513          	addi	a0,a0,718 # 6e38 <malloc+0x1522>
    2b72:	00003097          	auipc	ra,0x3
    2b76:	9d6080e7          	jalr	-1578(ra) # 5548 <mkdir>
    2b7a:	04054563          	bltz	a0,2bc4 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2b7e:	00004517          	auipc	a0,0x4
    2b82:	2ba50513          	addi	a0,a0,698 # 6e38 <malloc+0x1522>
    2b86:	00003097          	auipc	ra,0x3
    2b8a:	9ca080e7          	jalr	-1590(ra) # 5550 <chdir>
    2b8e:	04054963          	bltz	a0,2be0 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2b92:	00004517          	auipc	a0,0x4
    2b96:	2e650513          	addi	a0,a0,742 # 6e78 <malloc+0x1562>
    2b9a:	00003097          	auipc	ra,0x3
    2b9e:	996080e7          	jalr	-1642(ra) # 5530 <unlink>
    2ba2:	04054d63          	bltz	a0,2bfc <iputtest+0x9e>
  if(chdir("/") < 0){
    2ba6:	00004517          	auipc	a0,0x4
    2baa:	30250513          	addi	a0,a0,770 # 6ea8 <malloc+0x1592>
    2bae:	00003097          	auipc	ra,0x3
    2bb2:	9a2080e7          	jalr	-1630(ra) # 5550 <chdir>
    2bb6:	06054163          	bltz	a0,2c18 <iputtest+0xba>
}
    2bba:	60e2                	ld	ra,24(sp)
    2bbc:	6442                	ld	s0,16(sp)
    2bbe:	64a2                	ld	s1,8(sp)
    2bc0:	6105                	addi	sp,sp,32
    2bc2:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2bc4:	85a6                	mv	a1,s1
    2bc6:	00004517          	auipc	a0,0x4
    2bca:	27a50513          	addi	a0,a0,634 # 6e40 <malloc+0x152a>
    2bce:	00003097          	auipc	ra,0x3
    2bd2:	c8a080e7          	jalr	-886(ra) # 5858 <printf>
    exit(1);
    2bd6:	4505                	li	a0,1
    2bd8:	00003097          	auipc	ra,0x3
    2bdc:	908080e7          	jalr	-1784(ra) # 54e0 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2be0:	85a6                	mv	a1,s1
    2be2:	00004517          	auipc	a0,0x4
    2be6:	27650513          	addi	a0,a0,630 # 6e58 <malloc+0x1542>
    2bea:	00003097          	auipc	ra,0x3
    2bee:	c6e080e7          	jalr	-914(ra) # 5858 <printf>
    exit(1);
    2bf2:	4505                	li	a0,1
    2bf4:	00003097          	auipc	ra,0x3
    2bf8:	8ec080e7          	jalr	-1812(ra) # 54e0 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2bfc:	85a6                	mv	a1,s1
    2bfe:	00004517          	auipc	a0,0x4
    2c02:	28a50513          	addi	a0,a0,650 # 6e88 <malloc+0x1572>
    2c06:	00003097          	auipc	ra,0x3
    2c0a:	c52080e7          	jalr	-942(ra) # 5858 <printf>
    exit(1);
    2c0e:	4505                	li	a0,1
    2c10:	00003097          	auipc	ra,0x3
    2c14:	8d0080e7          	jalr	-1840(ra) # 54e0 <exit>
    printf("%s: chdir / failed\n", s);
    2c18:	85a6                	mv	a1,s1
    2c1a:	00004517          	auipc	a0,0x4
    2c1e:	29650513          	addi	a0,a0,662 # 6eb0 <malloc+0x159a>
    2c22:	00003097          	auipc	ra,0x3
    2c26:	c36080e7          	jalr	-970(ra) # 5858 <printf>
    exit(1);
    2c2a:	4505                	li	a0,1
    2c2c:	00003097          	auipc	ra,0x3
    2c30:	8b4080e7          	jalr	-1868(ra) # 54e0 <exit>

0000000000002c34 <exitiputtest>:
{
    2c34:	7179                	addi	sp,sp,-48
    2c36:	f406                	sd	ra,40(sp)
    2c38:	f022                	sd	s0,32(sp)
    2c3a:	ec26                	sd	s1,24(sp)
    2c3c:	1800                	addi	s0,sp,48
    2c3e:	84aa                	mv	s1,a0
  pid = fork();
    2c40:	00003097          	auipc	ra,0x3
    2c44:	898080e7          	jalr	-1896(ra) # 54d8 <fork>
  if(pid < 0){
    2c48:	04054663          	bltz	a0,2c94 <exitiputtest+0x60>
  if(pid == 0){
    2c4c:	ed45                	bnez	a0,2d04 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2c4e:	00004517          	auipc	a0,0x4
    2c52:	1ea50513          	addi	a0,a0,490 # 6e38 <malloc+0x1522>
    2c56:	00003097          	auipc	ra,0x3
    2c5a:	8f2080e7          	jalr	-1806(ra) # 5548 <mkdir>
    2c5e:	04054963          	bltz	a0,2cb0 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2c62:	00004517          	auipc	a0,0x4
    2c66:	1d650513          	addi	a0,a0,470 # 6e38 <malloc+0x1522>
    2c6a:	00003097          	auipc	ra,0x3
    2c6e:	8e6080e7          	jalr	-1818(ra) # 5550 <chdir>
    2c72:	04054d63          	bltz	a0,2ccc <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2c76:	00004517          	auipc	a0,0x4
    2c7a:	20250513          	addi	a0,a0,514 # 6e78 <malloc+0x1562>
    2c7e:	00003097          	auipc	ra,0x3
    2c82:	8b2080e7          	jalr	-1870(ra) # 5530 <unlink>
    2c86:	06054163          	bltz	a0,2ce8 <exitiputtest+0xb4>
    exit(0);
    2c8a:	4501                	li	a0,0
    2c8c:	00003097          	auipc	ra,0x3
    2c90:	854080e7          	jalr	-1964(ra) # 54e0 <exit>
    printf("%s: fork failed\n", s);
    2c94:	85a6                	mv	a1,s1
    2c96:	00004517          	auipc	a0,0x4
    2c9a:	8c250513          	addi	a0,a0,-1854 # 6558 <malloc+0xc42>
    2c9e:	00003097          	auipc	ra,0x3
    2ca2:	bba080e7          	jalr	-1094(ra) # 5858 <printf>
    exit(1);
    2ca6:	4505                	li	a0,1
    2ca8:	00003097          	auipc	ra,0x3
    2cac:	838080e7          	jalr	-1992(ra) # 54e0 <exit>
      printf("%s: mkdir failed\n", s);
    2cb0:	85a6                	mv	a1,s1
    2cb2:	00004517          	auipc	a0,0x4
    2cb6:	18e50513          	addi	a0,a0,398 # 6e40 <malloc+0x152a>
    2cba:	00003097          	auipc	ra,0x3
    2cbe:	b9e080e7          	jalr	-1122(ra) # 5858 <printf>
      exit(1);
    2cc2:	4505                	li	a0,1
    2cc4:	00003097          	auipc	ra,0x3
    2cc8:	81c080e7          	jalr	-2020(ra) # 54e0 <exit>
      printf("%s: child chdir failed\n", s);
    2ccc:	85a6                	mv	a1,s1
    2cce:	00004517          	auipc	a0,0x4
    2cd2:	1fa50513          	addi	a0,a0,506 # 6ec8 <malloc+0x15b2>
    2cd6:	00003097          	auipc	ra,0x3
    2cda:	b82080e7          	jalr	-1150(ra) # 5858 <printf>
      exit(1);
    2cde:	4505                	li	a0,1
    2ce0:	00003097          	auipc	ra,0x3
    2ce4:	800080e7          	jalr	-2048(ra) # 54e0 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2ce8:	85a6                	mv	a1,s1
    2cea:	00004517          	auipc	a0,0x4
    2cee:	19e50513          	addi	a0,a0,414 # 6e88 <malloc+0x1572>
    2cf2:	00003097          	auipc	ra,0x3
    2cf6:	b66080e7          	jalr	-1178(ra) # 5858 <printf>
      exit(1);
    2cfa:	4505                	li	a0,1
    2cfc:	00002097          	auipc	ra,0x2
    2d00:	7e4080e7          	jalr	2020(ra) # 54e0 <exit>
  wait(&xstatus);
    2d04:	fdc40513          	addi	a0,s0,-36
    2d08:	00002097          	auipc	ra,0x2
    2d0c:	7e0080e7          	jalr	2016(ra) # 54e8 <wait>
  exit(xstatus);
    2d10:	fdc42503          	lw	a0,-36(s0)
    2d14:	00002097          	auipc	ra,0x2
    2d18:	7cc080e7          	jalr	1996(ra) # 54e0 <exit>

0000000000002d1c <dirtest>:
{
    2d1c:	1101                	addi	sp,sp,-32
    2d1e:	ec06                	sd	ra,24(sp)
    2d20:	e822                	sd	s0,16(sp)
    2d22:	e426                	sd	s1,8(sp)
    2d24:	1000                	addi	s0,sp,32
    2d26:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2d28:	00004517          	auipc	a0,0x4
    2d2c:	1b850513          	addi	a0,a0,440 # 6ee0 <malloc+0x15ca>
    2d30:	00003097          	auipc	ra,0x3
    2d34:	818080e7          	jalr	-2024(ra) # 5548 <mkdir>
    2d38:	04054563          	bltz	a0,2d82 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2d3c:	00004517          	auipc	a0,0x4
    2d40:	1a450513          	addi	a0,a0,420 # 6ee0 <malloc+0x15ca>
    2d44:	00003097          	auipc	ra,0x3
    2d48:	80c080e7          	jalr	-2036(ra) # 5550 <chdir>
    2d4c:	04054963          	bltz	a0,2d9e <dirtest+0x82>
  if(chdir("..") < 0){
    2d50:	00004517          	auipc	a0,0x4
    2d54:	1b050513          	addi	a0,a0,432 # 6f00 <malloc+0x15ea>
    2d58:	00002097          	auipc	ra,0x2
    2d5c:	7f8080e7          	jalr	2040(ra) # 5550 <chdir>
    2d60:	04054d63          	bltz	a0,2dba <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2d64:	00004517          	auipc	a0,0x4
    2d68:	17c50513          	addi	a0,a0,380 # 6ee0 <malloc+0x15ca>
    2d6c:	00002097          	auipc	ra,0x2
    2d70:	7c4080e7          	jalr	1988(ra) # 5530 <unlink>
    2d74:	06054163          	bltz	a0,2dd6 <dirtest+0xba>
}
    2d78:	60e2                	ld	ra,24(sp)
    2d7a:	6442                	ld	s0,16(sp)
    2d7c:	64a2                	ld	s1,8(sp)
    2d7e:	6105                	addi	sp,sp,32
    2d80:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2d82:	85a6                	mv	a1,s1
    2d84:	00004517          	auipc	a0,0x4
    2d88:	0bc50513          	addi	a0,a0,188 # 6e40 <malloc+0x152a>
    2d8c:	00003097          	auipc	ra,0x3
    2d90:	acc080e7          	jalr	-1332(ra) # 5858 <printf>
    exit(1);
    2d94:	4505                	li	a0,1
    2d96:	00002097          	auipc	ra,0x2
    2d9a:	74a080e7          	jalr	1866(ra) # 54e0 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2d9e:	85a6                	mv	a1,s1
    2da0:	00004517          	auipc	a0,0x4
    2da4:	14850513          	addi	a0,a0,328 # 6ee8 <malloc+0x15d2>
    2da8:	00003097          	auipc	ra,0x3
    2dac:	ab0080e7          	jalr	-1360(ra) # 5858 <printf>
    exit(1);
    2db0:	4505                	li	a0,1
    2db2:	00002097          	auipc	ra,0x2
    2db6:	72e080e7          	jalr	1838(ra) # 54e0 <exit>
    printf("%s: chdir .. failed\n", s);
    2dba:	85a6                	mv	a1,s1
    2dbc:	00004517          	auipc	a0,0x4
    2dc0:	14c50513          	addi	a0,a0,332 # 6f08 <malloc+0x15f2>
    2dc4:	00003097          	auipc	ra,0x3
    2dc8:	a94080e7          	jalr	-1388(ra) # 5858 <printf>
    exit(1);
    2dcc:	4505                	li	a0,1
    2dce:	00002097          	auipc	ra,0x2
    2dd2:	712080e7          	jalr	1810(ra) # 54e0 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2dd6:	85a6                	mv	a1,s1
    2dd8:	00004517          	auipc	a0,0x4
    2ddc:	14850513          	addi	a0,a0,328 # 6f20 <malloc+0x160a>
    2de0:	00003097          	auipc	ra,0x3
    2de4:	a78080e7          	jalr	-1416(ra) # 5858 <printf>
    exit(1);
    2de8:	4505                	li	a0,1
    2dea:	00002097          	auipc	ra,0x2
    2dee:	6f6080e7          	jalr	1782(ra) # 54e0 <exit>

0000000000002df2 <subdir>:
{
    2df2:	1101                	addi	sp,sp,-32
    2df4:	ec06                	sd	ra,24(sp)
    2df6:	e822                	sd	s0,16(sp)
    2df8:	e426                	sd	s1,8(sp)
    2dfa:	e04a                	sd	s2,0(sp)
    2dfc:	1000                	addi	s0,sp,32
    2dfe:	892a                	mv	s2,a0
  unlink("ff");
    2e00:	00004517          	auipc	a0,0x4
    2e04:	26850513          	addi	a0,a0,616 # 7068 <malloc+0x1752>
    2e08:	00002097          	auipc	ra,0x2
    2e0c:	728080e7          	jalr	1832(ra) # 5530 <unlink>
  if(mkdir("dd") != 0){
    2e10:	00004517          	auipc	a0,0x4
    2e14:	12850513          	addi	a0,a0,296 # 6f38 <malloc+0x1622>
    2e18:	00002097          	auipc	ra,0x2
    2e1c:	730080e7          	jalr	1840(ra) # 5548 <mkdir>
    2e20:	38051663          	bnez	a0,31ac <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2e24:	20200593          	li	a1,514
    2e28:	00004517          	auipc	a0,0x4
    2e2c:	13050513          	addi	a0,a0,304 # 6f58 <malloc+0x1642>
    2e30:	00002097          	auipc	ra,0x2
    2e34:	6f0080e7          	jalr	1776(ra) # 5520 <open>
    2e38:	84aa                	mv	s1,a0
  if(fd < 0){
    2e3a:	38054763          	bltz	a0,31c8 <subdir+0x3d6>
  write(fd, "ff", 2);
    2e3e:	4609                	li	a2,2
    2e40:	00004597          	auipc	a1,0x4
    2e44:	22858593          	addi	a1,a1,552 # 7068 <malloc+0x1752>
    2e48:	00002097          	auipc	ra,0x2
    2e4c:	6b8080e7          	jalr	1720(ra) # 5500 <write>
  close(fd);
    2e50:	8526                	mv	a0,s1
    2e52:	00002097          	auipc	ra,0x2
    2e56:	6b6080e7          	jalr	1718(ra) # 5508 <close>
  if(unlink("dd") >= 0){
    2e5a:	00004517          	auipc	a0,0x4
    2e5e:	0de50513          	addi	a0,a0,222 # 6f38 <malloc+0x1622>
    2e62:	00002097          	auipc	ra,0x2
    2e66:	6ce080e7          	jalr	1742(ra) # 5530 <unlink>
    2e6a:	36055d63          	bgez	a0,31e4 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2e6e:	00004517          	auipc	a0,0x4
    2e72:	14250513          	addi	a0,a0,322 # 6fb0 <malloc+0x169a>
    2e76:	00002097          	auipc	ra,0x2
    2e7a:	6d2080e7          	jalr	1746(ra) # 5548 <mkdir>
    2e7e:	38051163          	bnez	a0,3200 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2e82:	20200593          	li	a1,514
    2e86:	00004517          	auipc	a0,0x4
    2e8a:	15250513          	addi	a0,a0,338 # 6fd8 <malloc+0x16c2>
    2e8e:	00002097          	auipc	ra,0x2
    2e92:	692080e7          	jalr	1682(ra) # 5520 <open>
    2e96:	84aa                	mv	s1,a0
  if(fd < 0){
    2e98:	38054263          	bltz	a0,321c <subdir+0x42a>
  write(fd, "FF", 2);
    2e9c:	4609                	li	a2,2
    2e9e:	00004597          	auipc	a1,0x4
    2ea2:	16a58593          	addi	a1,a1,362 # 7008 <malloc+0x16f2>
    2ea6:	00002097          	auipc	ra,0x2
    2eaa:	65a080e7          	jalr	1626(ra) # 5500 <write>
  close(fd);
    2eae:	8526                	mv	a0,s1
    2eb0:	00002097          	auipc	ra,0x2
    2eb4:	658080e7          	jalr	1624(ra) # 5508 <close>
  fd = open("dd/dd/../ff", 0);
    2eb8:	4581                	li	a1,0
    2eba:	00004517          	auipc	a0,0x4
    2ebe:	15650513          	addi	a0,a0,342 # 7010 <malloc+0x16fa>
    2ec2:	00002097          	auipc	ra,0x2
    2ec6:	65e080e7          	jalr	1630(ra) # 5520 <open>
    2eca:	84aa                	mv	s1,a0
  if(fd < 0){
    2ecc:	36054663          	bltz	a0,3238 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2ed0:	660d                	lui	a2,0x3
    2ed2:	00009597          	auipc	a1,0x9
    2ed6:	a1658593          	addi	a1,a1,-1514 # b8e8 <buf>
    2eda:	00002097          	auipc	ra,0x2
    2ede:	61e080e7          	jalr	1566(ra) # 54f8 <read>
  if(cc != 2 || buf[0] != 'f'){
    2ee2:	4789                	li	a5,2
    2ee4:	36f51863          	bne	a0,a5,3254 <subdir+0x462>
    2ee8:	00009717          	auipc	a4,0x9
    2eec:	a0074703          	lbu	a4,-1536(a4) # b8e8 <buf>
    2ef0:	06600793          	li	a5,102
    2ef4:	36f71063          	bne	a4,a5,3254 <subdir+0x462>
  close(fd);
    2ef8:	8526                	mv	a0,s1
    2efa:	00002097          	auipc	ra,0x2
    2efe:	60e080e7          	jalr	1550(ra) # 5508 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2f02:	00004597          	auipc	a1,0x4
    2f06:	15e58593          	addi	a1,a1,350 # 7060 <malloc+0x174a>
    2f0a:	00004517          	auipc	a0,0x4
    2f0e:	0ce50513          	addi	a0,a0,206 # 6fd8 <malloc+0x16c2>
    2f12:	00002097          	auipc	ra,0x2
    2f16:	62e080e7          	jalr	1582(ra) # 5540 <link>
    2f1a:	34051b63          	bnez	a0,3270 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2f1e:	00004517          	auipc	a0,0x4
    2f22:	0ba50513          	addi	a0,a0,186 # 6fd8 <malloc+0x16c2>
    2f26:	00002097          	auipc	ra,0x2
    2f2a:	60a080e7          	jalr	1546(ra) # 5530 <unlink>
    2f2e:	34051f63          	bnez	a0,328c <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2f32:	4581                	li	a1,0
    2f34:	00004517          	auipc	a0,0x4
    2f38:	0a450513          	addi	a0,a0,164 # 6fd8 <malloc+0x16c2>
    2f3c:	00002097          	auipc	ra,0x2
    2f40:	5e4080e7          	jalr	1508(ra) # 5520 <open>
    2f44:	36055263          	bgez	a0,32a8 <subdir+0x4b6>
  if(chdir("dd") != 0){
    2f48:	00004517          	auipc	a0,0x4
    2f4c:	ff050513          	addi	a0,a0,-16 # 6f38 <malloc+0x1622>
    2f50:	00002097          	auipc	ra,0x2
    2f54:	600080e7          	jalr	1536(ra) # 5550 <chdir>
    2f58:	36051663          	bnez	a0,32c4 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2f5c:	00004517          	auipc	a0,0x4
    2f60:	19c50513          	addi	a0,a0,412 # 70f8 <malloc+0x17e2>
    2f64:	00002097          	auipc	ra,0x2
    2f68:	5ec080e7          	jalr	1516(ra) # 5550 <chdir>
    2f6c:	36051a63          	bnez	a0,32e0 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2f70:	00004517          	auipc	a0,0x4
    2f74:	1b850513          	addi	a0,a0,440 # 7128 <malloc+0x1812>
    2f78:	00002097          	auipc	ra,0x2
    2f7c:	5d8080e7          	jalr	1496(ra) # 5550 <chdir>
    2f80:	36051e63          	bnez	a0,32fc <subdir+0x50a>
  if(chdir("./..") != 0){
    2f84:	00004517          	auipc	a0,0x4
    2f88:	1d450513          	addi	a0,a0,468 # 7158 <malloc+0x1842>
    2f8c:	00002097          	auipc	ra,0x2
    2f90:	5c4080e7          	jalr	1476(ra) # 5550 <chdir>
    2f94:	38051263          	bnez	a0,3318 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    2f98:	4581                	li	a1,0
    2f9a:	00004517          	auipc	a0,0x4
    2f9e:	0c650513          	addi	a0,a0,198 # 7060 <malloc+0x174a>
    2fa2:	00002097          	auipc	ra,0x2
    2fa6:	57e080e7          	jalr	1406(ra) # 5520 <open>
    2faa:	84aa                	mv	s1,a0
  if(fd < 0){
    2fac:	38054463          	bltz	a0,3334 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    2fb0:	660d                	lui	a2,0x3
    2fb2:	00009597          	auipc	a1,0x9
    2fb6:	93658593          	addi	a1,a1,-1738 # b8e8 <buf>
    2fba:	00002097          	auipc	ra,0x2
    2fbe:	53e080e7          	jalr	1342(ra) # 54f8 <read>
    2fc2:	4789                	li	a5,2
    2fc4:	38f51663          	bne	a0,a5,3350 <subdir+0x55e>
  close(fd);
    2fc8:	8526                	mv	a0,s1
    2fca:	00002097          	auipc	ra,0x2
    2fce:	53e080e7          	jalr	1342(ra) # 5508 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2fd2:	4581                	li	a1,0
    2fd4:	00004517          	auipc	a0,0x4
    2fd8:	00450513          	addi	a0,a0,4 # 6fd8 <malloc+0x16c2>
    2fdc:	00002097          	auipc	ra,0x2
    2fe0:	544080e7          	jalr	1348(ra) # 5520 <open>
    2fe4:	38055463          	bgez	a0,336c <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2fe8:	20200593          	li	a1,514
    2fec:	00004517          	auipc	a0,0x4
    2ff0:	1fc50513          	addi	a0,a0,508 # 71e8 <malloc+0x18d2>
    2ff4:	00002097          	auipc	ra,0x2
    2ff8:	52c080e7          	jalr	1324(ra) # 5520 <open>
    2ffc:	38055663          	bgez	a0,3388 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3000:	20200593          	li	a1,514
    3004:	00004517          	auipc	a0,0x4
    3008:	21450513          	addi	a0,a0,532 # 7218 <malloc+0x1902>
    300c:	00002097          	auipc	ra,0x2
    3010:	514080e7          	jalr	1300(ra) # 5520 <open>
    3014:	38055863          	bgez	a0,33a4 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3018:	20000593          	li	a1,512
    301c:	00004517          	auipc	a0,0x4
    3020:	f1c50513          	addi	a0,a0,-228 # 6f38 <malloc+0x1622>
    3024:	00002097          	auipc	ra,0x2
    3028:	4fc080e7          	jalr	1276(ra) # 5520 <open>
    302c:	38055a63          	bgez	a0,33c0 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3030:	4589                	li	a1,2
    3032:	00004517          	auipc	a0,0x4
    3036:	f0650513          	addi	a0,a0,-250 # 6f38 <malloc+0x1622>
    303a:	00002097          	auipc	ra,0x2
    303e:	4e6080e7          	jalr	1254(ra) # 5520 <open>
    3042:	38055d63          	bgez	a0,33dc <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3046:	4585                	li	a1,1
    3048:	00004517          	auipc	a0,0x4
    304c:	ef050513          	addi	a0,a0,-272 # 6f38 <malloc+0x1622>
    3050:	00002097          	auipc	ra,0x2
    3054:	4d0080e7          	jalr	1232(ra) # 5520 <open>
    3058:	3a055063          	bgez	a0,33f8 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    305c:	00004597          	auipc	a1,0x4
    3060:	24c58593          	addi	a1,a1,588 # 72a8 <malloc+0x1992>
    3064:	00004517          	auipc	a0,0x4
    3068:	18450513          	addi	a0,a0,388 # 71e8 <malloc+0x18d2>
    306c:	00002097          	auipc	ra,0x2
    3070:	4d4080e7          	jalr	1236(ra) # 5540 <link>
    3074:	3a050063          	beqz	a0,3414 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3078:	00004597          	auipc	a1,0x4
    307c:	23058593          	addi	a1,a1,560 # 72a8 <malloc+0x1992>
    3080:	00004517          	auipc	a0,0x4
    3084:	19850513          	addi	a0,a0,408 # 7218 <malloc+0x1902>
    3088:	00002097          	auipc	ra,0x2
    308c:	4b8080e7          	jalr	1208(ra) # 5540 <link>
    3090:	3a050063          	beqz	a0,3430 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3094:	00004597          	auipc	a1,0x4
    3098:	fcc58593          	addi	a1,a1,-52 # 7060 <malloc+0x174a>
    309c:	00004517          	auipc	a0,0x4
    30a0:	ebc50513          	addi	a0,a0,-324 # 6f58 <malloc+0x1642>
    30a4:	00002097          	auipc	ra,0x2
    30a8:	49c080e7          	jalr	1180(ra) # 5540 <link>
    30ac:	3a050063          	beqz	a0,344c <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    30b0:	00004517          	auipc	a0,0x4
    30b4:	13850513          	addi	a0,a0,312 # 71e8 <malloc+0x18d2>
    30b8:	00002097          	auipc	ra,0x2
    30bc:	490080e7          	jalr	1168(ra) # 5548 <mkdir>
    30c0:	3a050463          	beqz	a0,3468 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    30c4:	00004517          	auipc	a0,0x4
    30c8:	15450513          	addi	a0,a0,340 # 7218 <malloc+0x1902>
    30cc:	00002097          	auipc	ra,0x2
    30d0:	47c080e7          	jalr	1148(ra) # 5548 <mkdir>
    30d4:	3a050863          	beqz	a0,3484 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    30d8:	00004517          	auipc	a0,0x4
    30dc:	f8850513          	addi	a0,a0,-120 # 7060 <malloc+0x174a>
    30e0:	00002097          	auipc	ra,0x2
    30e4:	468080e7          	jalr	1128(ra) # 5548 <mkdir>
    30e8:	3a050c63          	beqz	a0,34a0 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    30ec:	00004517          	auipc	a0,0x4
    30f0:	12c50513          	addi	a0,a0,300 # 7218 <malloc+0x1902>
    30f4:	00002097          	auipc	ra,0x2
    30f8:	43c080e7          	jalr	1084(ra) # 5530 <unlink>
    30fc:	3c050063          	beqz	a0,34bc <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3100:	00004517          	auipc	a0,0x4
    3104:	0e850513          	addi	a0,a0,232 # 71e8 <malloc+0x18d2>
    3108:	00002097          	auipc	ra,0x2
    310c:	428080e7          	jalr	1064(ra) # 5530 <unlink>
    3110:	3c050463          	beqz	a0,34d8 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3114:	00004517          	auipc	a0,0x4
    3118:	e4450513          	addi	a0,a0,-444 # 6f58 <malloc+0x1642>
    311c:	00002097          	auipc	ra,0x2
    3120:	434080e7          	jalr	1076(ra) # 5550 <chdir>
    3124:	3c050863          	beqz	a0,34f4 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3128:	00004517          	auipc	a0,0x4
    312c:	2d050513          	addi	a0,a0,720 # 73f8 <malloc+0x1ae2>
    3130:	00002097          	auipc	ra,0x2
    3134:	420080e7          	jalr	1056(ra) # 5550 <chdir>
    3138:	3c050c63          	beqz	a0,3510 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    313c:	00004517          	auipc	a0,0x4
    3140:	f2450513          	addi	a0,a0,-220 # 7060 <malloc+0x174a>
    3144:	00002097          	auipc	ra,0x2
    3148:	3ec080e7          	jalr	1004(ra) # 5530 <unlink>
    314c:	3e051063          	bnez	a0,352c <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3150:	00004517          	auipc	a0,0x4
    3154:	e0850513          	addi	a0,a0,-504 # 6f58 <malloc+0x1642>
    3158:	00002097          	auipc	ra,0x2
    315c:	3d8080e7          	jalr	984(ra) # 5530 <unlink>
    3160:	3e051463          	bnez	a0,3548 <subdir+0x756>
  if(unlink("dd") == 0){
    3164:	00004517          	auipc	a0,0x4
    3168:	dd450513          	addi	a0,a0,-556 # 6f38 <malloc+0x1622>
    316c:	00002097          	auipc	ra,0x2
    3170:	3c4080e7          	jalr	964(ra) # 5530 <unlink>
    3174:	3e050863          	beqz	a0,3564 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3178:	00004517          	auipc	a0,0x4
    317c:	2f050513          	addi	a0,a0,752 # 7468 <malloc+0x1b52>
    3180:	00002097          	auipc	ra,0x2
    3184:	3b0080e7          	jalr	944(ra) # 5530 <unlink>
    3188:	3e054c63          	bltz	a0,3580 <subdir+0x78e>
  if(unlink("dd") < 0){
    318c:	00004517          	auipc	a0,0x4
    3190:	dac50513          	addi	a0,a0,-596 # 6f38 <malloc+0x1622>
    3194:	00002097          	auipc	ra,0x2
    3198:	39c080e7          	jalr	924(ra) # 5530 <unlink>
    319c:	40054063          	bltz	a0,359c <subdir+0x7aa>
}
    31a0:	60e2                	ld	ra,24(sp)
    31a2:	6442                	ld	s0,16(sp)
    31a4:	64a2                	ld	s1,8(sp)
    31a6:	6902                	ld	s2,0(sp)
    31a8:	6105                	addi	sp,sp,32
    31aa:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    31ac:	85ca                	mv	a1,s2
    31ae:	00004517          	auipc	a0,0x4
    31b2:	d9250513          	addi	a0,a0,-622 # 6f40 <malloc+0x162a>
    31b6:	00002097          	auipc	ra,0x2
    31ba:	6a2080e7          	jalr	1698(ra) # 5858 <printf>
    exit(1);
    31be:	4505                	li	a0,1
    31c0:	00002097          	auipc	ra,0x2
    31c4:	320080e7          	jalr	800(ra) # 54e0 <exit>
    printf("%s: create dd/ff failed\n", s);
    31c8:	85ca                	mv	a1,s2
    31ca:	00004517          	auipc	a0,0x4
    31ce:	d9650513          	addi	a0,a0,-618 # 6f60 <malloc+0x164a>
    31d2:	00002097          	auipc	ra,0x2
    31d6:	686080e7          	jalr	1670(ra) # 5858 <printf>
    exit(1);
    31da:	4505                	li	a0,1
    31dc:	00002097          	auipc	ra,0x2
    31e0:	304080e7          	jalr	772(ra) # 54e0 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    31e4:	85ca                	mv	a1,s2
    31e6:	00004517          	auipc	a0,0x4
    31ea:	d9a50513          	addi	a0,a0,-614 # 6f80 <malloc+0x166a>
    31ee:	00002097          	auipc	ra,0x2
    31f2:	66a080e7          	jalr	1642(ra) # 5858 <printf>
    exit(1);
    31f6:	4505                	li	a0,1
    31f8:	00002097          	auipc	ra,0x2
    31fc:	2e8080e7          	jalr	744(ra) # 54e0 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3200:	85ca                	mv	a1,s2
    3202:	00004517          	auipc	a0,0x4
    3206:	db650513          	addi	a0,a0,-586 # 6fb8 <malloc+0x16a2>
    320a:	00002097          	auipc	ra,0x2
    320e:	64e080e7          	jalr	1614(ra) # 5858 <printf>
    exit(1);
    3212:	4505                	li	a0,1
    3214:	00002097          	auipc	ra,0x2
    3218:	2cc080e7          	jalr	716(ra) # 54e0 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    321c:	85ca                	mv	a1,s2
    321e:	00004517          	auipc	a0,0x4
    3222:	dca50513          	addi	a0,a0,-566 # 6fe8 <malloc+0x16d2>
    3226:	00002097          	auipc	ra,0x2
    322a:	632080e7          	jalr	1586(ra) # 5858 <printf>
    exit(1);
    322e:	4505                	li	a0,1
    3230:	00002097          	auipc	ra,0x2
    3234:	2b0080e7          	jalr	688(ra) # 54e0 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3238:	85ca                	mv	a1,s2
    323a:	00004517          	auipc	a0,0x4
    323e:	de650513          	addi	a0,a0,-538 # 7020 <malloc+0x170a>
    3242:	00002097          	auipc	ra,0x2
    3246:	616080e7          	jalr	1558(ra) # 5858 <printf>
    exit(1);
    324a:	4505                	li	a0,1
    324c:	00002097          	auipc	ra,0x2
    3250:	294080e7          	jalr	660(ra) # 54e0 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3254:	85ca                	mv	a1,s2
    3256:	00004517          	auipc	a0,0x4
    325a:	dea50513          	addi	a0,a0,-534 # 7040 <malloc+0x172a>
    325e:	00002097          	auipc	ra,0x2
    3262:	5fa080e7          	jalr	1530(ra) # 5858 <printf>
    exit(1);
    3266:	4505                	li	a0,1
    3268:	00002097          	auipc	ra,0x2
    326c:	278080e7          	jalr	632(ra) # 54e0 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3270:	85ca                	mv	a1,s2
    3272:	00004517          	auipc	a0,0x4
    3276:	dfe50513          	addi	a0,a0,-514 # 7070 <malloc+0x175a>
    327a:	00002097          	auipc	ra,0x2
    327e:	5de080e7          	jalr	1502(ra) # 5858 <printf>
    exit(1);
    3282:	4505                	li	a0,1
    3284:	00002097          	auipc	ra,0x2
    3288:	25c080e7          	jalr	604(ra) # 54e0 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    328c:	85ca                	mv	a1,s2
    328e:	00004517          	auipc	a0,0x4
    3292:	e0a50513          	addi	a0,a0,-502 # 7098 <malloc+0x1782>
    3296:	00002097          	auipc	ra,0x2
    329a:	5c2080e7          	jalr	1474(ra) # 5858 <printf>
    exit(1);
    329e:	4505                	li	a0,1
    32a0:	00002097          	auipc	ra,0x2
    32a4:	240080e7          	jalr	576(ra) # 54e0 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    32a8:	85ca                	mv	a1,s2
    32aa:	00004517          	auipc	a0,0x4
    32ae:	e0e50513          	addi	a0,a0,-498 # 70b8 <malloc+0x17a2>
    32b2:	00002097          	auipc	ra,0x2
    32b6:	5a6080e7          	jalr	1446(ra) # 5858 <printf>
    exit(1);
    32ba:	4505                	li	a0,1
    32bc:	00002097          	auipc	ra,0x2
    32c0:	224080e7          	jalr	548(ra) # 54e0 <exit>
    printf("%s: chdir dd failed\n", s);
    32c4:	85ca                	mv	a1,s2
    32c6:	00004517          	auipc	a0,0x4
    32ca:	e1a50513          	addi	a0,a0,-486 # 70e0 <malloc+0x17ca>
    32ce:	00002097          	auipc	ra,0x2
    32d2:	58a080e7          	jalr	1418(ra) # 5858 <printf>
    exit(1);
    32d6:	4505                	li	a0,1
    32d8:	00002097          	auipc	ra,0x2
    32dc:	208080e7          	jalr	520(ra) # 54e0 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    32e0:	85ca                	mv	a1,s2
    32e2:	00004517          	auipc	a0,0x4
    32e6:	e2650513          	addi	a0,a0,-474 # 7108 <malloc+0x17f2>
    32ea:	00002097          	auipc	ra,0x2
    32ee:	56e080e7          	jalr	1390(ra) # 5858 <printf>
    exit(1);
    32f2:	4505                	li	a0,1
    32f4:	00002097          	auipc	ra,0x2
    32f8:	1ec080e7          	jalr	492(ra) # 54e0 <exit>
    printf("chdir dd/../../dd failed\n", s);
    32fc:	85ca                	mv	a1,s2
    32fe:	00004517          	auipc	a0,0x4
    3302:	e3a50513          	addi	a0,a0,-454 # 7138 <malloc+0x1822>
    3306:	00002097          	auipc	ra,0x2
    330a:	552080e7          	jalr	1362(ra) # 5858 <printf>
    exit(1);
    330e:	4505                	li	a0,1
    3310:	00002097          	auipc	ra,0x2
    3314:	1d0080e7          	jalr	464(ra) # 54e0 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3318:	85ca                	mv	a1,s2
    331a:	00004517          	auipc	a0,0x4
    331e:	e4650513          	addi	a0,a0,-442 # 7160 <malloc+0x184a>
    3322:	00002097          	auipc	ra,0x2
    3326:	536080e7          	jalr	1334(ra) # 5858 <printf>
    exit(1);
    332a:	4505                	li	a0,1
    332c:	00002097          	auipc	ra,0x2
    3330:	1b4080e7          	jalr	436(ra) # 54e0 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3334:	85ca                	mv	a1,s2
    3336:	00004517          	auipc	a0,0x4
    333a:	e4250513          	addi	a0,a0,-446 # 7178 <malloc+0x1862>
    333e:	00002097          	auipc	ra,0x2
    3342:	51a080e7          	jalr	1306(ra) # 5858 <printf>
    exit(1);
    3346:	4505                	li	a0,1
    3348:	00002097          	auipc	ra,0x2
    334c:	198080e7          	jalr	408(ra) # 54e0 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3350:	85ca                	mv	a1,s2
    3352:	00004517          	auipc	a0,0x4
    3356:	e4650513          	addi	a0,a0,-442 # 7198 <malloc+0x1882>
    335a:	00002097          	auipc	ra,0x2
    335e:	4fe080e7          	jalr	1278(ra) # 5858 <printf>
    exit(1);
    3362:	4505                	li	a0,1
    3364:	00002097          	auipc	ra,0x2
    3368:	17c080e7          	jalr	380(ra) # 54e0 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    336c:	85ca                	mv	a1,s2
    336e:	00004517          	auipc	a0,0x4
    3372:	e4a50513          	addi	a0,a0,-438 # 71b8 <malloc+0x18a2>
    3376:	00002097          	auipc	ra,0x2
    337a:	4e2080e7          	jalr	1250(ra) # 5858 <printf>
    exit(1);
    337e:	4505                	li	a0,1
    3380:	00002097          	auipc	ra,0x2
    3384:	160080e7          	jalr	352(ra) # 54e0 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3388:	85ca                	mv	a1,s2
    338a:	00004517          	auipc	a0,0x4
    338e:	e6e50513          	addi	a0,a0,-402 # 71f8 <malloc+0x18e2>
    3392:	00002097          	auipc	ra,0x2
    3396:	4c6080e7          	jalr	1222(ra) # 5858 <printf>
    exit(1);
    339a:	4505                	li	a0,1
    339c:	00002097          	auipc	ra,0x2
    33a0:	144080e7          	jalr	324(ra) # 54e0 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    33a4:	85ca                	mv	a1,s2
    33a6:	00004517          	auipc	a0,0x4
    33aa:	e8250513          	addi	a0,a0,-382 # 7228 <malloc+0x1912>
    33ae:	00002097          	auipc	ra,0x2
    33b2:	4aa080e7          	jalr	1194(ra) # 5858 <printf>
    exit(1);
    33b6:	4505                	li	a0,1
    33b8:	00002097          	auipc	ra,0x2
    33bc:	128080e7          	jalr	296(ra) # 54e0 <exit>
    printf("%s: create dd succeeded!\n", s);
    33c0:	85ca                	mv	a1,s2
    33c2:	00004517          	auipc	a0,0x4
    33c6:	e8650513          	addi	a0,a0,-378 # 7248 <malloc+0x1932>
    33ca:	00002097          	auipc	ra,0x2
    33ce:	48e080e7          	jalr	1166(ra) # 5858 <printf>
    exit(1);
    33d2:	4505                	li	a0,1
    33d4:	00002097          	auipc	ra,0x2
    33d8:	10c080e7          	jalr	268(ra) # 54e0 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    33dc:	85ca                	mv	a1,s2
    33de:	00004517          	auipc	a0,0x4
    33e2:	e8a50513          	addi	a0,a0,-374 # 7268 <malloc+0x1952>
    33e6:	00002097          	auipc	ra,0x2
    33ea:	472080e7          	jalr	1138(ra) # 5858 <printf>
    exit(1);
    33ee:	4505                	li	a0,1
    33f0:	00002097          	auipc	ra,0x2
    33f4:	0f0080e7          	jalr	240(ra) # 54e0 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    33f8:	85ca                	mv	a1,s2
    33fa:	00004517          	auipc	a0,0x4
    33fe:	e8e50513          	addi	a0,a0,-370 # 7288 <malloc+0x1972>
    3402:	00002097          	auipc	ra,0x2
    3406:	456080e7          	jalr	1110(ra) # 5858 <printf>
    exit(1);
    340a:	4505                	li	a0,1
    340c:	00002097          	auipc	ra,0x2
    3410:	0d4080e7          	jalr	212(ra) # 54e0 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3414:	85ca                	mv	a1,s2
    3416:	00004517          	auipc	a0,0x4
    341a:	ea250513          	addi	a0,a0,-350 # 72b8 <malloc+0x19a2>
    341e:	00002097          	auipc	ra,0x2
    3422:	43a080e7          	jalr	1082(ra) # 5858 <printf>
    exit(1);
    3426:	4505                	li	a0,1
    3428:	00002097          	auipc	ra,0x2
    342c:	0b8080e7          	jalr	184(ra) # 54e0 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3430:	85ca                	mv	a1,s2
    3432:	00004517          	auipc	a0,0x4
    3436:	eae50513          	addi	a0,a0,-338 # 72e0 <malloc+0x19ca>
    343a:	00002097          	auipc	ra,0x2
    343e:	41e080e7          	jalr	1054(ra) # 5858 <printf>
    exit(1);
    3442:	4505                	li	a0,1
    3444:	00002097          	auipc	ra,0x2
    3448:	09c080e7          	jalr	156(ra) # 54e0 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    344c:	85ca                	mv	a1,s2
    344e:	00004517          	auipc	a0,0x4
    3452:	eba50513          	addi	a0,a0,-326 # 7308 <malloc+0x19f2>
    3456:	00002097          	auipc	ra,0x2
    345a:	402080e7          	jalr	1026(ra) # 5858 <printf>
    exit(1);
    345e:	4505                	li	a0,1
    3460:	00002097          	auipc	ra,0x2
    3464:	080080e7          	jalr	128(ra) # 54e0 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3468:	85ca                	mv	a1,s2
    346a:	00004517          	auipc	a0,0x4
    346e:	ec650513          	addi	a0,a0,-314 # 7330 <malloc+0x1a1a>
    3472:	00002097          	auipc	ra,0x2
    3476:	3e6080e7          	jalr	998(ra) # 5858 <printf>
    exit(1);
    347a:	4505                	li	a0,1
    347c:	00002097          	auipc	ra,0x2
    3480:	064080e7          	jalr	100(ra) # 54e0 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3484:	85ca                	mv	a1,s2
    3486:	00004517          	auipc	a0,0x4
    348a:	eca50513          	addi	a0,a0,-310 # 7350 <malloc+0x1a3a>
    348e:	00002097          	auipc	ra,0x2
    3492:	3ca080e7          	jalr	970(ra) # 5858 <printf>
    exit(1);
    3496:	4505                	li	a0,1
    3498:	00002097          	auipc	ra,0x2
    349c:	048080e7          	jalr	72(ra) # 54e0 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    34a0:	85ca                	mv	a1,s2
    34a2:	00004517          	auipc	a0,0x4
    34a6:	ece50513          	addi	a0,a0,-306 # 7370 <malloc+0x1a5a>
    34aa:	00002097          	auipc	ra,0x2
    34ae:	3ae080e7          	jalr	942(ra) # 5858 <printf>
    exit(1);
    34b2:	4505                	li	a0,1
    34b4:	00002097          	auipc	ra,0x2
    34b8:	02c080e7          	jalr	44(ra) # 54e0 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    34bc:	85ca                	mv	a1,s2
    34be:	00004517          	auipc	a0,0x4
    34c2:	eda50513          	addi	a0,a0,-294 # 7398 <malloc+0x1a82>
    34c6:	00002097          	auipc	ra,0x2
    34ca:	392080e7          	jalr	914(ra) # 5858 <printf>
    exit(1);
    34ce:	4505                	li	a0,1
    34d0:	00002097          	auipc	ra,0x2
    34d4:	010080e7          	jalr	16(ra) # 54e0 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    34d8:	85ca                	mv	a1,s2
    34da:	00004517          	auipc	a0,0x4
    34de:	ede50513          	addi	a0,a0,-290 # 73b8 <malloc+0x1aa2>
    34e2:	00002097          	auipc	ra,0x2
    34e6:	376080e7          	jalr	886(ra) # 5858 <printf>
    exit(1);
    34ea:	4505                	li	a0,1
    34ec:	00002097          	auipc	ra,0x2
    34f0:	ff4080e7          	jalr	-12(ra) # 54e0 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    34f4:	85ca                	mv	a1,s2
    34f6:	00004517          	auipc	a0,0x4
    34fa:	ee250513          	addi	a0,a0,-286 # 73d8 <malloc+0x1ac2>
    34fe:	00002097          	auipc	ra,0x2
    3502:	35a080e7          	jalr	858(ra) # 5858 <printf>
    exit(1);
    3506:	4505                	li	a0,1
    3508:	00002097          	auipc	ra,0x2
    350c:	fd8080e7          	jalr	-40(ra) # 54e0 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3510:	85ca                	mv	a1,s2
    3512:	00004517          	auipc	a0,0x4
    3516:	eee50513          	addi	a0,a0,-274 # 7400 <malloc+0x1aea>
    351a:	00002097          	auipc	ra,0x2
    351e:	33e080e7          	jalr	830(ra) # 5858 <printf>
    exit(1);
    3522:	4505                	li	a0,1
    3524:	00002097          	auipc	ra,0x2
    3528:	fbc080e7          	jalr	-68(ra) # 54e0 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    352c:	85ca                	mv	a1,s2
    352e:	00004517          	auipc	a0,0x4
    3532:	b6a50513          	addi	a0,a0,-1174 # 7098 <malloc+0x1782>
    3536:	00002097          	auipc	ra,0x2
    353a:	322080e7          	jalr	802(ra) # 5858 <printf>
    exit(1);
    353e:	4505                	li	a0,1
    3540:	00002097          	auipc	ra,0x2
    3544:	fa0080e7          	jalr	-96(ra) # 54e0 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3548:	85ca                	mv	a1,s2
    354a:	00004517          	auipc	a0,0x4
    354e:	ed650513          	addi	a0,a0,-298 # 7420 <malloc+0x1b0a>
    3552:	00002097          	auipc	ra,0x2
    3556:	306080e7          	jalr	774(ra) # 5858 <printf>
    exit(1);
    355a:	4505                	li	a0,1
    355c:	00002097          	auipc	ra,0x2
    3560:	f84080e7          	jalr	-124(ra) # 54e0 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3564:	85ca                	mv	a1,s2
    3566:	00004517          	auipc	a0,0x4
    356a:	eda50513          	addi	a0,a0,-294 # 7440 <malloc+0x1b2a>
    356e:	00002097          	auipc	ra,0x2
    3572:	2ea080e7          	jalr	746(ra) # 5858 <printf>
    exit(1);
    3576:	4505                	li	a0,1
    3578:	00002097          	auipc	ra,0x2
    357c:	f68080e7          	jalr	-152(ra) # 54e0 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3580:	85ca                	mv	a1,s2
    3582:	00004517          	auipc	a0,0x4
    3586:	eee50513          	addi	a0,a0,-274 # 7470 <malloc+0x1b5a>
    358a:	00002097          	auipc	ra,0x2
    358e:	2ce080e7          	jalr	718(ra) # 5858 <printf>
    exit(1);
    3592:	4505                	li	a0,1
    3594:	00002097          	auipc	ra,0x2
    3598:	f4c080e7          	jalr	-180(ra) # 54e0 <exit>
    printf("%s: unlink dd failed\n", s);
    359c:	85ca                	mv	a1,s2
    359e:	00004517          	auipc	a0,0x4
    35a2:	ef250513          	addi	a0,a0,-270 # 7490 <malloc+0x1b7a>
    35a6:	00002097          	auipc	ra,0x2
    35aa:	2b2080e7          	jalr	690(ra) # 5858 <printf>
    exit(1);
    35ae:	4505                	li	a0,1
    35b0:	00002097          	auipc	ra,0x2
    35b4:	f30080e7          	jalr	-208(ra) # 54e0 <exit>

00000000000035b8 <rmdot>:
{
    35b8:	1101                	addi	sp,sp,-32
    35ba:	ec06                	sd	ra,24(sp)
    35bc:	e822                	sd	s0,16(sp)
    35be:	e426                	sd	s1,8(sp)
    35c0:	1000                	addi	s0,sp,32
    35c2:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    35c4:	00004517          	auipc	a0,0x4
    35c8:	ee450513          	addi	a0,a0,-284 # 74a8 <malloc+0x1b92>
    35cc:	00002097          	auipc	ra,0x2
    35d0:	f7c080e7          	jalr	-132(ra) # 5548 <mkdir>
    35d4:	e549                	bnez	a0,365e <rmdot+0xa6>
  if(chdir("dots") != 0){
    35d6:	00004517          	auipc	a0,0x4
    35da:	ed250513          	addi	a0,a0,-302 # 74a8 <malloc+0x1b92>
    35de:	00002097          	auipc	ra,0x2
    35e2:	f72080e7          	jalr	-142(ra) # 5550 <chdir>
    35e6:	e951                	bnez	a0,367a <rmdot+0xc2>
  if(unlink(".") == 0){
    35e8:	00003517          	auipc	a0,0x3
    35ec:	dd050513          	addi	a0,a0,-560 # 63b8 <malloc+0xaa2>
    35f0:	00002097          	auipc	ra,0x2
    35f4:	f40080e7          	jalr	-192(ra) # 5530 <unlink>
    35f8:	cd59                	beqz	a0,3696 <rmdot+0xde>
  if(unlink("..") == 0){
    35fa:	00004517          	auipc	a0,0x4
    35fe:	90650513          	addi	a0,a0,-1786 # 6f00 <malloc+0x15ea>
    3602:	00002097          	auipc	ra,0x2
    3606:	f2e080e7          	jalr	-210(ra) # 5530 <unlink>
    360a:	c545                	beqz	a0,36b2 <rmdot+0xfa>
  if(chdir("/") != 0){
    360c:	00004517          	auipc	a0,0x4
    3610:	89c50513          	addi	a0,a0,-1892 # 6ea8 <malloc+0x1592>
    3614:	00002097          	auipc	ra,0x2
    3618:	f3c080e7          	jalr	-196(ra) # 5550 <chdir>
    361c:	e94d                	bnez	a0,36ce <rmdot+0x116>
  if(unlink("dots/.") == 0){
    361e:	00004517          	auipc	a0,0x4
    3622:	ef250513          	addi	a0,a0,-270 # 7510 <malloc+0x1bfa>
    3626:	00002097          	auipc	ra,0x2
    362a:	f0a080e7          	jalr	-246(ra) # 5530 <unlink>
    362e:	cd55                	beqz	a0,36ea <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3630:	00004517          	auipc	a0,0x4
    3634:	f0850513          	addi	a0,a0,-248 # 7538 <malloc+0x1c22>
    3638:	00002097          	auipc	ra,0x2
    363c:	ef8080e7          	jalr	-264(ra) # 5530 <unlink>
    3640:	c179                	beqz	a0,3706 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3642:	00004517          	auipc	a0,0x4
    3646:	e6650513          	addi	a0,a0,-410 # 74a8 <malloc+0x1b92>
    364a:	00002097          	auipc	ra,0x2
    364e:	ee6080e7          	jalr	-282(ra) # 5530 <unlink>
    3652:	e961                	bnez	a0,3722 <rmdot+0x16a>
}
    3654:	60e2                	ld	ra,24(sp)
    3656:	6442                	ld	s0,16(sp)
    3658:	64a2                	ld	s1,8(sp)
    365a:	6105                	addi	sp,sp,32
    365c:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    365e:	85a6                	mv	a1,s1
    3660:	00004517          	auipc	a0,0x4
    3664:	e5050513          	addi	a0,a0,-432 # 74b0 <malloc+0x1b9a>
    3668:	00002097          	auipc	ra,0x2
    366c:	1f0080e7          	jalr	496(ra) # 5858 <printf>
    exit(1);
    3670:	4505                	li	a0,1
    3672:	00002097          	auipc	ra,0x2
    3676:	e6e080e7          	jalr	-402(ra) # 54e0 <exit>
    printf("%s: chdir dots failed\n", s);
    367a:	85a6                	mv	a1,s1
    367c:	00004517          	auipc	a0,0x4
    3680:	e4c50513          	addi	a0,a0,-436 # 74c8 <malloc+0x1bb2>
    3684:	00002097          	auipc	ra,0x2
    3688:	1d4080e7          	jalr	468(ra) # 5858 <printf>
    exit(1);
    368c:	4505                	li	a0,1
    368e:	00002097          	auipc	ra,0x2
    3692:	e52080e7          	jalr	-430(ra) # 54e0 <exit>
    printf("%s: rm . worked!\n", s);
    3696:	85a6                	mv	a1,s1
    3698:	00004517          	auipc	a0,0x4
    369c:	e4850513          	addi	a0,a0,-440 # 74e0 <malloc+0x1bca>
    36a0:	00002097          	auipc	ra,0x2
    36a4:	1b8080e7          	jalr	440(ra) # 5858 <printf>
    exit(1);
    36a8:	4505                	li	a0,1
    36aa:	00002097          	auipc	ra,0x2
    36ae:	e36080e7          	jalr	-458(ra) # 54e0 <exit>
    printf("%s: rm .. worked!\n", s);
    36b2:	85a6                	mv	a1,s1
    36b4:	00004517          	auipc	a0,0x4
    36b8:	e4450513          	addi	a0,a0,-444 # 74f8 <malloc+0x1be2>
    36bc:	00002097          	auipc	ra,0x2
    36c0:	19c080e7          	jalr	412(ra) # 5858 <printf>
    exit(1);
    36c4:	4505                	li	a0,1
    36c6:	00002097          	auipc	ra,0x2
    36ca:	e1a080e7          	jalr	-486(ra) # 54e0 <exit>
    printf("%s: chdir / failed\n", s);
    36ce:	85a6                	mv	a1,s1
    36d0:	00003517          	auipc	a0,0x3
    36d4:	7e050513          	addi	a0,a0,2016 # 6eb0 <malloc+0x159a>
    36d8:	00002097          	auipc	ra,0x2
    36dc:	180080e7          	jalr	384(ra) # 5858 <printf>
    exit(1);
    36e0:	4505                	li	a0,1
    36e2:	00002097          	auipc	ra,0x2
    36e6:	dfe080e7          	jalr	-514(ra) # 54e0 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    36ea:	85a6                	mv	a1,s1
    36ec:	00004517          	auipc	a0,0x4
    36f0:	e2c50513          	addi	a0,a0,-468 # 7518 <malloc+0x1c02>
    36f4:	00002097          	auipc	ra,0x2
    36f8:	164080e7          	jalr	356(ra) # 5858 <printf>
    exit(1);
    36fc:	4505                	li	a0,1
    36fe:	00002097          	auipc	ra,0x2
    3702:	de2080e7          	jalr	-542(ra) # 54e0 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3706:	85a6                	mv	a1,s1
    3708:	00004517          	auipc	a0,0x4
    370c:	e3850513          	addi	a0,a0,-456 # 7540 <malloc+0x1c2a>
    3710:	00002097          	auipc	ra,0x2
    3714:	148080e7          	jalr	328(ra) # 5858 <printf>
    exit(1);
    3718:	4505                	li	a0,1
    371a:	00002097          	auipc	ra,0x2
    371e:	dc6080e7          	jalr	-570(ra) # 54e0 <exit>
    printf("%s: unlink dots failed!\n", s);
    3722:	85a6                	mv	a1,s1
    3724:	00004517          	auipc	a0,0x4
    3728:	e3c50513          	addi	a0,a0,-452 # 7560 <malloc+0x1c4a>
    372c:	00002097          	auipc	ra,0x2
    3730:	12c080e7          	jalr	300(ra) # 5858 <printf>
    exit(1);
    3734:	4505                	li	a0,1
    3736:	00002097          	auipc	ra,0x2
    373a:	daa080e7          	jalr	-598(ra) # 54e0 <exit>

000000000000373e <dirfile>:
{
    373e:	1101                	addi	sp,sp,-32
    3740:	ec06                	sd	ra,24(sp)
    3742:	e822                	sd	s0,16(sp)
    3744:	e426                	sd	s1,8(sp)
    3746:	e04a                	sd	s2,0(sp)
    3748:	1000                	addi	s0,sp,32
    374a:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    374c:	20000593          	li	a1,512
    3750:	00002517          	auipc	a0,0x2
    3754:	57050513          	addi	a0,a0,1392 # 5cc0 <malloc+0x3aa>
    3758:	00002097          	auipc	ra,0x2
    375c:	dc8080e7          	jalr	-568(ra) # 5520 <open>
  if(fd < 0){
    3760:	0e054d63          	bltz	a0,385a <dirfile+0x11c>
  close(fd);
    3764:	00002097          	auipc	ra,0x2
    3768:	da4080e7          	jalr	-604(ra) # 5508 <close>
  if(chdir("dirfile") == 0){
    376c:	00002517          	auipc	a0,0x2
    3770:	55450513          	addi	a0,a0,1364 # 5cc0 <malloc+0x3aa>
    3774:	00002097          	auipc	ra,0x2
    3778:	ddc080e7          	jalr	-548(ra) # 5550 <chdir>
    377c:	cd6d                	beqz	a0,3876 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    377e:	4581                	li	a1,0
    3780:	00004517          	auipc	a0,0x4
    3784:	e4050513          	addi	a0,a0,-448 # 75c0 <malloc+0x1caa>
    3788:	00002097          	auipc	ra,0x2
    378c:	d98080e7          	jalr	-616(ra) # 5520 <open>
  if(fd >= 0){
    3790:	10055163          	bgez	a0,3892 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3794:	20000593          	li	a1,512
    3798:	00004517          	auipc	a0,0x4
    379c:	e2850513          	addi	a0,a0,-472 # 75c0 <malloc+0x1caa>
    37a0:	00002097          	auipc	ra,0x2
    37a4:	d80080e7          	jalr	-640(ra) # 5520 <open>
  if(fd >= 0){
    37a8:	10055363          	bgez	a0,38ae <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    37ac:	00004517          	auipc	a0,0x4
    37b0:	e1450513          	addi	a0,a0,-492 # 75c0 <malloc+0x1caa>
    37b4:	00002097          	auipc	ra,0x2
    37b8:	d94080e7          	jalr	-620(ra) # 5548 <mkdir>
    37bc:	10050763          	beqz	a0,38ca <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    37c0:	00004517          	auipc	a0,0x4
    37c4:	e0050513          	addi	a0,a0,-512 # 75c0 <malloc+0x1caa>
    37c8:	00002097          	auipc	ra,0x2
    37cc:	d68080e7          	jalr	-664(ra) # 5530 <unlink>
    37d0:	10050b63          	beqz	a0,38e6 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    37d4:	00004597          	auipc	a1,0x4
    37d8:	dec58593          	addi	a1,a1,-532 # 75c0 <malloc+0x1caa>
    37dc:	00002517          	auipc	a0,0x2
    37e0:	6dc50513          	addi	a0,a0,1756 # 5eb8 <malloc+0x5a2>
    37e4:	00002097          	auipc	ra,0x2
    37e8:	d5c080e7          	jalr	-676(ra) # 5540 <link>
    37ec:	10050b63          	beqz	a0,3902 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    37f0:	00002517          	auipc	a0,0x2
    37f4:	4d050513          	addi	a0,a0,1232 # 5cc0 <malloc+0x3aa>
    37f8:	00002097          	auipc	ra,0x2
    37fc:	d38080e7          	jalr	-712(ra) # 5530 <unlink>
    3800:	10051f63          	bnez	a0,391e <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3804:	4589                	li	a1,2
    3806:	00003517          	auipc	a0,0x3
    380a:	bb250513          	addi	a0,a0,-1102 # 63b8 <malloc+0xaa2>
    380e:	00002097          	auipc	ra,0x2
    3812:	d12080e7          	jalr	-750(ra) # 5520 <open>
  if(fd >= 0){
    3816:	12055263          	bgez	a0,393a <dirfile+0x1fc>
  fd = open(".", 0);
    381a:	4581                	li	a1,0
    381c:	00003517          	auipc	a0,0x3
    3820:	b9c50513          	addi	a0,a0,-1124 # 63b8 <malloc+0xaa2>
    3824:	00002097          	auipc	ra,0x2
    3828:	cfc080e7          	jalr	-772(ra) # 5520 <open>
    382c:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    382e:	4605                	li	a2,1
    3830:	00002597          	auipc	a1,0x2
    3834:	56058593          	addi	a1,a1,1376 # 5d90 <malloc+0x47a>
    3838:	00002097          	auipc	ra,0x2
    383c:	cc8080e7          	jalr	-824(ra) # 5500 <write>
    3840:	10a04b63          	bgtz	a0,3956 <dirfile+0x218>
  close(fd);
    3844:	8526                	mv	a0,s1
    3846:	00002097          	auipc	ra,0x2
    384a:	cc2080e7          	jalr	-830(ra) # 5508 <close>
}
    384e:	60e2                	ld	ra,24(sp)
    3850:	6442                	ld	s0,16(sp)
    3852:	64a2                	ld	s1,8(sp)
    3854:	6902                	ld	s2,0(sp)
    3856:	6105                	addi	sp,sp,32
    3858:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    385a:	85ca                	mv	a1,s2
    385c:	00004517          	auipc	a0,0x4
    3860:	d2450513          	addi	a0,a0,-732 # 7580 <malloc+0x1c6a>
    3864:	00002097          	auipc	ra,0x2
    3868:	ff4080e7          	jalr	-12(ra) # 5858 <printf>
    exit(1);
    386c:	4505                	li	a0,1
    386e:	00002097          	auipc	ra,0x2
    3872:	c72080e7          	jalr	-910(ra) # 54e0 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3876:	85ca                	mv	a1,s2
    3878:	00004517          	auipc	a0,0x4
    387c:	d2850513          	addi	a0,a0,-728 # 75a0 <malloc+0x1c8a>
    3880:	00002097          	auipc	ra,0x2
    3884:	fd8080e7          	jalr	-40(ra) # 5858 <printf>
    exit(1);
    3888:	4505                	li	a0,1
    388a:	00002097          	auipc	ra,0x2
    388e:	c56080e7          	jalr	-938(ra) # 54e0 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3892:	85ca                	mv	a1,s2
    3894:	00004517          	auipc	a0,0x4
    3898:	d3c50513          	addi	a0,a0,-708 # 75d0 <malloc+0x1cba>
    389c:	00002097          	auipc	ra,0x2
    38a0:	fbc080e7          	jalr	-68(ra) # 5858 <printf>
    exit(1);
    38a4:	4505                	li	a0,1
    38a6:	00002097          	auipc	ra,0x2
    38aa:	c3a080e7          	jalr	-966(ra) # 54e0 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    38ae:	85ca                	mv	a1,s2
    38b0:	00004517          	auipc	a0,0x4
    38b4:	d2050513          	addi	a0,a0,-736 # 75d0 <malloc+0x1cba>
    38b8:	00002097          	auipc	ra,0x2
    38bc:	fa0080e7          	jalr	-96(ra) # 5858 <printf>
    exit(1);
    38c0:	4505                	li	a0,1
    38c2:	00002097          	auipc	ra,0x2
    38c6:	c1e080e7          	jalr	-994(ra) # 54e0 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    38ca:	85ca                	mv	a1,s2
    38cc:	00004517          	auipc	a0,0x4
    38d0:	d2c50513          	addi	a0,a0,-724 # 75f8 <malloc+0x1ce2>
    38d4:	00002097          	auipc	ra,0x2
    38d8:	f84080e7          	jalr	-124(ra) # 5858 <printf>
    exit(1);
    38dc:	4505                	li	a0,1
    38de:	00002097          	auipc	ra,0x2
    38e2:	c02080e7          	jalr	-1022(ra) # 54e0 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    38e6:	85ca                	mv	a1,s2
    38e8:	00004517          	auipc	a0,0x4
    38ec:	d3850513          	addi	a0,a0,-712 # 7620 <malloc+0x1d0a>
    38f0:	00002097          	auipc	ra,0x2
    38f4:	f68080e7          	jalr	-152(ra) # 5858 <printf>
    exit(1);
    38f8:	4505                	li	a0,1
    38fa:	00002097          	auipc	ra,0x2
    38fe:	be6080e7          	jalr	-1050(ra) # 54e0 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3902:	85ca                	mv	a1,s2
    3904:	00004517          	auipc	a0,0x4
    3908:	d4450513          	addi	a0,a0,-700 # 7648 <malloc+0x1d32>
    390c:	00002097          	auipc	ra,0x2
    3910:	f4c080e7          	jalr	-180(ra) # 5858 <printf>
    exit(1);
    3914:	4505                	li	a0,1
    3916:	00002097          	auipc	ra,0x2
    391a:	bca080e7          	jalr	-1078(ra) # 54e0 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    391e:	85ca                	mv	a1,s2
    3920:	00004517          	auipc	a0,0x4
    3924:	d5050513          	addi	a0,a0,-688 # 7670 <malloc+0x1d5a>
    3928:	00002097          	auipc	ra,0x2
    392c:	f30080e7          	jalr	-208(ra) # 5858 <printf>
    exit(1);
    3930:	4505                	li	a0,1
    3932:	00002097          	auipc	ra,0x2
    3936:	bae080e7          	jalr	-1106(ra) # 54e0 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    393a:	85ca                	mv	a1,s2
    393c:	00004517          	auipc	a0,0x4
    3940:	d5450513          	addi	a0,a0,-684 # 7690 <malloc+0x1d7a>
    3944:	00002097          	auipc	ra,0x2
    3948:	f14080e7          	jalr	-236(ra) # 5858 <printf>
    exit(1);
    394c:	4505                	li	a0,1
    394e:	00002097          	auipc	ra,0x2
    3952:	b92080e7          	jalr	-1134(ra) # 54e0 <exit>
    printf("%s: write . succeeded!\n", s);
    3956:	85ca                	mv	a1,s2
    3958:	00004517          	auipc	a0,0x4
    395c:	d6050513          	addi	a0,a0,-672 # 76b8 <malloc+0x1da2>
    3960:	00002097          	auipc	ra,0x2
    3964:	ef8080e7          	jalr	-264(ra) # 5858 <printf>
    exit(1);
    3968:	4505                	li	a0,1
    396a:	00002097          	auipc	ra,0x2
    396e:	b76080e7          	jalr	-1162(ra) # 54e0 <exit>

0000000000003972 <iref>:
{
    3972:	7139                	addi	sp,sp,-64
    3974:	fc06                	sd	ra,56(sp)
    3976:	f822                	sd	s0,48(sp)
    3978:	f426                	sd	s1,40(sp)
    397a:	f04a                	sd	s2,32(sp)
    397c:	ec4e                	sd	s3,24(sp)
    397e:	e852                	sd	s4,16(sp)
    3980:	e456                	sd	s5,8(sp)
    3982:	e05a                	sd	s6,0(sp)
    3984:	0080                	addi	s0,sp,64
    3986:	8b2a                	mv	s6,a0
    3988:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    398c:	00004a17          	auipc	s4,0x4
    3990:	d44a0a13          	addi	s4,s4,-700 # 76d0 <malloc+0x1dba>
    mkdir("");
    3994:	00004497          	auipc	s1,0x4
    3998:	84c48493          	addi	s1,s1,-1972 # 71e0 <malloc+0x18ca>
    link("README", "");
    399c:	00002a97          	auipc	s5,0x2
    39a0:	51ca8a93          	addi	s5,s5,1308 # 5eb8 <malloc+0x5a2>
    fd = open("xx", O_CREATE);
    39a4:	00004997          	auipc	s3,0x4
    39a8:	c2498993          	addi	s3,s3,-988 # 75c8 <malloc+0x1cb2>
    39ac:	a891                	j	3a00 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    39ae:	85da                	mv	a1,s6
    39b0:	00004517          	auipc	a0,0x4
    39b4:	d2850513          	addi	a0,a0,-728 # 76d8 <malloc+0x1dc2>
    39b8:	00002097          	auipc	ra,0x2
    39bc:	ea0080e7          	jalr	-352(ra) # 5858 <printf>
      exit(1);
    39c0:	4505                	li	a0,1
    39c2:	00002097          	auipc	ra,0x2
    39c6:	b1e080e7          	jalr	-1250(ra) # 54e0 <exit>
      printf("%s: chdir irefd failed\n", s);
    39ca:	85da                	mv	a1,s6
    39cc:	00004517          	auipc	a0,0x4
    39d0:	d2450513          	addi	a0,a0,-732 # 76f0 <malloc+0x1dda>
    39d4:	00002097          	auipc	ra,0x2
    39d8:	e84080e7          	jalr	-380(ra) # 5858 <printf>
      exit(1);
    39dc:	4505                	li	a0,1
    39de:	00002097          	auipc	ra,0x2
    39e2:	b02080e7          	jalr	-1278(ra) # 54e0 <exit>
      close(fd);
    39e6:	00002097          	auipc	ra,0x2
    39ea:	b22080e7          	jalr	-1246(ra) # 5508 <close>
    39ee:	a889                	j	3a40 <iref+0xce>
    unlink("xx");
    39f0:	854e                	mv	a0,s3
    39f2:	00002097          	auipc	ra,0x2
    39f6:	b3e080e7          	jalr	-1218(ra) # 5530 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    39fa:	397d                	addiw	s2,s2,-1
    39fc:	06090063          	beqz	s2,3a5c <iref+0xea>
    if(mkdir("irefd") != 0){
    3a00:	8552                	mv	a0,s4
    3a02:	00002097          	auipc	ra,0x2
    3a06:	b46080e7          	jalr	-1210(ra) # 5548 <mkdir>
    3a0a:	f155                	bnez	a0,39ae <iref+0x3c>
    if(chdir("irefd") != 0){
    3a0c:	8552                	mv	a0,s4
    3a0e:	00002097          	auipc	ra,0x2
    3a12:	b42080e7          	jalr	-1214(ra) # 5550 <chdir>
    3a16:	f955                	bnez	a0,39ca <iref+0x58>
    mkdir("");
    3a18:	8526                	mv	a0,s1
    3a1a:	00002097          	auipc	ra,0x2
    3a1e:	b2e080e7          	jalr	-1234(ra) # 5548 <mkdir>
    link("README", "");
    3a22:	85a6                	mv	a1,s1
    3a24:	8556                	mv	a0,s5
    3a26:	00002097          	auipc	ra,0x2
    3a2a:	b1a080e7          	jalr	-1254(ra) # 5540 <link>
    fd = open("", O_CREATE);
    3a2e:	20000593          	li	a1,512
    3a32:	8526                	mv	a0,s1
    3a34:	00002097          	auipc	ra,0x2
    3a38:	aec080e7          	jalr	-1300(ra) # 5520 <open>
    if(fd >= 0)
    3a3c:	fa0555e3          	bgez	a0,39e6 <iref+0x74>
    fd = open("xx", O_CREATE);
    3a40:	20000593          	li	a1,512
    3a44:	854e                	mv	a0,s3
    3a46:	00002097          	auipc	ra,0x2
    3a4a:	ada080e7          	jalr	-1318(ra) # 5520 <open>
    if(fd >= 0)
    3a4e:	fa0541e3          	bltz	a0,39f0 <iref+0x7e>
      close(fd);
    3a52:	00002097          	auipc	ra,0x2
    3a56:	ab6080e7          	jalr	-1354(ra) # 5508 <close>
    3a5a:	bf59                	j	39f0 <iref+0x7e>
    3a5c:	03300493          	li	s1,51
    chdir("..");
    3a60:	00003997          	auipc	s3,0x3
    3a64:	4a098993          	addi	s3,s3,1184 # 6f00 <malloc+0x15ea>
    unlink("irefd");
    3a68:	00004917          	auipc	s2,0x4
    3a6c:	c6890913          	addi	s2,s2,-920 # 76d0 <malloc+0x1dba>
    chdir("..");
    3a70:	854e                	mv	a0,s3
    3a72:	00002097          	auipc	ra,0x2
    3a76:	ade080e7          	jalr	-1314(ra) # 5550 <chdir>
    unlink("irefd");
    3a7a:	854a                	mv	a0,s2
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	ab4080e7          	jalr	-1356(ra) # 5530 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3a84:	34fd                	addiw	s1,s1,-1
    3a86:	f4ed                	bnez	s1,3a70 <iref+0xfe>
  chdir("/");
    3a88:	00003517          	auipc	a0,0x3
    3a8c:	42050513          	addi	a0,a0,1056 # 6ea8 <malloc+0x1592>
    3a90:	00002097          	auipc	ra,0x2
    3a94:	ac0080e7          	jalr	-1344(ra) # 5550 <chdir>
}
    3a98:	70e2                	ld	ra,56(sp)
    3a9a:	7442                	ld	s0,48(sp)
    3a9c:	74a2                	ld	s1,40(sp)
    3a9e:	7902                	ld	s2,32(sp)
    3aa0:	69e2                	ld	s3,24(sp)
    3aa2:	6a42                	ld	s4,16(sp)
    3aa4:	6aa2                	ld	s5,8(sp)
    3aa6:	6b02                	ld	s6,0(sp)
    3aa8:	6121                	addi	sp,sp,64
    3aaa:	8082                	ret

0000000000003aac <openiputtest>:
{
    3aac:	7179                	addi	sp,sp,-48
    3aae:	f406                	sd	ra,40(sp)
    3ab0:	f022                	sd	s0,32(sp)
    3ab2:	ec26                	sd	s1,24(sp)
    3ab4:	1800                	addi	s0,sp,48
    3ab6:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3ab8:	00004517          	auipc	a0,0x4
    3abc:	c5050513          	addi	a0,a0,-944 # 7708 <malloc+0x1df2>
    3ac0:	00002097          	auipc	ra,0x2
    3ac4:	a88080e7          	jalr	-1400(ra) # 5548 <mkdir>
    3ac8:	04054263          	bltz	a0,3b0c <openiputtest+0x60>
  pid = fork();
    3acc:	00002097          	auipc	ra,0x2
    3ad0:	a0c080e7          	jalr	-1524(ra) # 54d8 <fork>
  if(pid < 0){
    3ad4:	04054a63          	bltz	a0,3b28 <openiputtest+0x7c>
  if(pid == 0){
    3ad8:	e93d                	bnez	a0,3b4e <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3ada:	4589                	li	a1,2
    3adc:	00004517          	auipc	a0,0x4
    3ae0:	c2c50513          	addi	a0,a0,-980 # 7708 <malloc+0x1df2>
    3ae4:	00002097          	auipc	ra,0x2
    3ae8:	a3c080e7          	jalr	-1476(ra) # 5520 <open>
    if(fd >= 0){
    3aec:	04054c63          	bltz	a0,3b44 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3af0:	85a6                	mv	a1,s1
    3af2:	00004517          	auipc	a0,0x4
    3af6:	c3650513          	addi	a0,a0,-970 # 7728 <malloc+0x1e12>
    3afa:	00002097          	auipc	ra,0x2
    3afe:	d5e080e7          	jalr	-674(ra) # 5858 <printf>
      exit(1);
    3b02:	4505                	li	a0,1
    3b04:	00002097          	auipc	ra,0x2
    3b08:	9dc080e7          	jalr	-1572(ra) # 54e0 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3b0c:	85a6                	mv	a1,s1
    3b0e:	00004517          	auipc	a0,0x4
    3b12:	c0250513          	addi	a0,a0,-1022 # 7710 <malloc+0x1dfa>
    3b16:	00002097          	auipc	ra,0x2
    3b1a:	d42080e7          	jalr	-702(ra) # 5858 <printf>
    exit(1);
    3b1e:	4505                	li	a0,1
    3b20:	00002097          	auipc	ra,0x2
    3b24:	9c0080e7          	jalr	-1600(ra) # 54e0 <exit>
    printf("%s: fork failed\n", s);
    3b28:	85a6                	mv	a1,s1
    3b2a:	00003517          	auipc	a0,0x3
    3b2e:	a2e50513          	addi	a0,a0,-1490 # 6558 <malloc+0xc42>
    3b32:	00002097          	auipc	ra,0x2
    3b36:	d26080e7          	jalr	-730(ra) # 5858 <printf>
    exit(1);
    3b3a:	4505                	li	a0,1
    3b3c:	00002097          	auipc	ra,0x2
    3b40:	9a4080e7          	jalr	-1628(ra) # 54e0 <exit>
    exit(0);
    3b44:	4501                	li	a0,0
    3b46:	00002097          	auipc	ra,0x2
    3b4a:	99a080e7          	jalr	-1638(ra) # 54e0 <exit>
  sleep(1);
    3b4e:	4505                	li	a0,1
    3b50:	00002097          	auipc	ra,0x2
    3b54:	a20080e7          	jalr	-1504(ra) # 5570 <sleep>
  if(unlink("oidir") != 0){
    3b58:	00004517          	auipc	a0,0x4
    3b5c:	bb050513          	addi	a0,a0,-1104 # 7708 <malloc+0x1df2>
    3b60:	00002097          	auipc	ra,0x2
    3b64:	9d0080e7          	jalr	-1584(ra) # 5530 <unlink>
    3b68:	cd19                	beqz	a0,3b86 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3b6a:	85a6                	mv	a1,s1
    3b6c:	00003517          	auipc	a0,0x3
    3b70:	bdc50513          	addi	a0,a0,-1060 # 6748 <malloc+0xe32>
    3b74:	00002097          	auipc	ra,0x2
    3b78:	ce4080e7          	jalr	-796(ra) # 5858 <printf>
    exit(1);
    3b7c:	4505                	li	a0,1
    3b7e:	00002097          	auipc	ra,0x2
    3b82:	962080e7          	jalr	-1694(ra) # 54e0 <exit>
  wait(&xstatus);
    3b86:	fdc40513          	addi	a0,s0,-36
    3b8a:	00002097          	auipc	ra,0x2
    3b8e:	95e080e7          	jalr	-1698(ra) # 54e8 <wait>
  exit(xstatus);
    3b92:	fdc42503          	lw	a0,-36(s0)
    3b96:	00002097          	auipc	ra,0x2
    3b9a:	94a080e7          	jalr	-1718(ra) # 54e0 <exit>

0000000000003b9e <forkforkfork>:
{
    3b9e:	1101                	addi	sp,sp,-32
    3ba0:	ec06                	sd	ra,24(sp)
    3ba2:	e822                	sd	s0,16(sp)
    3ba4:	e426                	sd	s1,8(sp)
    3ba6:	1000                	addi	s0,sp,32
    3ba8:	84aa                	mv	s1,a0
  unlink("stopforking");
    3baa:	00004517          	auipc	a0,0x4
    3bae:	ba650513          	addi	a0,a0,-1114 # 7750 <malloc+0x1e3a>
    3bb2:	00002097          	auipc	ra,0x2
    3bb6:	97e080e7          	jalr	-1666(ra) # 5530 <unlink>
  int pid = fork();
    3bba:	00002097          	auipc	ra,0x2
    3bbe:	91e080e7          	jalr	-1762(ra) # 54d8 <fork>
  if(pid < 0){
    3bc2:	04054563          	bltz	a0,3c0c <forkforkfork+0x6e>
  if(pid == 0){
    3bc6:	c12d                	beqz	a0,3c28 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3bc8:	4551                	li	a0,20
    3bca:	00002097          	auipc	ra,0x2
    3bce:	9a6080e7          	jalr	-1626(ra) # 5570 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3bd2:	20200593          	li	a1,514
    3bd6:	00004517          	auipc	a0,0x4
    3bda:	b7a50513          	addi	a0,a0,-1158 # 7750 <malloc+0x1e3a>
    3bde:	00002097          	auipc	ra,0x2
    3be2:	942080e7          	jalr	-1726(ra) # 5520 <open>
    3be6:	00002097          	auipc	ra,0x2
    3bea:	922080e7          	jalr	-1758(ra) # 5508 <close>
  wait(0);
    3bee:	4501                	li	a0,0
    3bf0:	00002097          	auipc	ra,0x2
    3bf4:	8f8080e7          	jalr	-1800(ra) # 54e8 <wait>
  sleep(10); // one second
    3bf8:	4529                	li	a0,10
    3bfa:	00002097          	auipc	ra,0x2
    3bfe:	976080e7          	jalr	-1674(ra) # 5570 <sleep>
}
    3c02:	60e2                	ld	ra,24(sp)
    3c04:	6442                	ld	s0,16(sp)
    3c06:	64a2                	ld	s1,8(sp)
    3c08:	6105                	addi	sp,sp,32
    3c0a:	8082                	ret
    printf("%s: fork failed", s);
    3c0c:	85a6                	mv	a1,s1
    3c0e:	00003517          	auipc	a0,0x3
    3c12:	b0a50513          	addi	a0,a0,-1270 # 6718 <malloc+0xe02>
    3c16:	00002097          	auipc	ra,0x2
    3c1a:	c42080e7          	jalr	-958(ra) # 5858 <printf>
    exit(1);
    3c1e:	4505                	li	a0,1
    3c20:	00002097          	auipc	ra,0x2
    3c24:	8c0080e7          	jalr	-1856(ra) # 54e0 <exit>
      int fd = open("stopforking", 0);
    3c28:	00004497          	auipc	s1,0x4
    3c2c:	b2848493          	addi	s1,s1,-1240 # 7750 <malloc+0x1e3a>
    3c30:	4581                	li	a1,0
    3c32:	8526                	mv	a0,s1
    3c34:	00002097          	auipc	ra,0x2
    3c38:	8ec080e7          	jalr	-1812(ra) # 5520 <open>
      if(fd >= 0){
    3c3c:	02055463          	bgez	a0,3c64 <forkforkfork+0xc6>
      if(fork() < 0){
    3c40:	00002097          	auipc	ra,0x2
    3c44:	898080e7          	jalr	-1896(ra) # 54d8 <fork>
    3c48:	fe0554e3          	bgez	a0,3c30 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3c4c:	20200593          	li	a1,514
    3c50:	8526                	mv	a0,s1
    3c52:	00002097          	auipc	ra,0x2
    3c56:	8ce080e7          	jalr	-1842(ra) # 5520 <open>
    3c5a:	00002097          	auipc	ra,0x2
    3c5e:	8ae080e7          	jalr	-1874(ra) # 5508 <close>
    3c62:	b7f9                	j	3c30 <forkforkfork+0x92>
        exit(0);
    3c64:	4501                	li	a0,0
    3c66:	00002097          	auipc	ra,0x2
    3c6a:	87a080e7          	jalr	-1926(ra) # 54e0 <exit>

0000000000003c6e <preempt>:
{
    3c6e:	7139                	addi	sp,sp,-64
    3c70:	fc06                	sd	ra,56(sp)
    3c72:	f822                	sd	s0,48(sp)
    3c74:	f426                	sd	s1,40(sp)
    3c76:	f04a                	sd	s2,32(sp)
    3c78:	ec4e                	sd	s3,24(sp)
    3c7a:	e852                	sd	s4,16(sp)
    3c7c:	0080                	addi	s0,sp,64
    3c7e:	84aa                	mv	s1,a0
  pid1 = fork();
    3c80:	00002097          	auipc	ra,0x2
    3c84:	858080e7          	jalr	-1960(ra) # 54d8 <fork>
  if(pid1 < 0) {
    3c88:	00054563          	bltz	a0,3c92 <preempt+0x24>
    3c8c:	8a2a                	mv	s4,a0
  if(pid1 == 0)
    3c8e:	e105                	bnez	a0,3cae <preempt+0x40>
    for(;;)
    3c90:	a001                	j	3c90 <preempt+0x22>
    printf("%s: fork failed", s);
    3c92:	85a6                	mv	a1,s1
    3c94:	00003517          	auipc	a0,0x3
    3c98:	a8450513          	addi	a0,a0,-1404 # 6718 <malloc+0xe02>
    3c9c:	00002097          	auipc	ra,0x2
    3ca0:	bbc080e7          	jalr	-1092(ra) # 5858 <printf>
    exit(1);
    3ca4:	4505                	li	a0,1
    3ca6:	00002097          	auipc	ra,0x2
    3caa:	83a080e7          	jalr	-1990(ra) # 54e0 <exit>
  pid2 = fork();
    3cae:	00002097          	auipc	ra,0x2
    3cb2:	82a080e7          	jalr	-2006(ra) # 54d8 <fork>
    3cb6:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3cb8:	00054463          	bltz	a0,3cc0 <preempt+0x52>
  if(pid2 == 0)
    3cbc:	e105                	bnez	a0,3cdc <preempt+0x6e>
    for(;;)
    3cbe:	a001                	j	3cbe <preempt+0x50>
    printf("%s: fork failed\n", s);
    3cc0:	85a6                	mv	a1,s1
    3cc2:	00003517          	auipc	a0,0x3
    3cc6:	89650513          	addi	a0,a0,-1898 # 6558 <malloc+0xc42>
    3cca:	00002097          	auipc	ra,0x2
    3cce:	b8e080e7          	jalr	-1138(ra) # 5858 <printf>
    exit(1);
    3cd2:	4505                	li	a0,1
    3cd4:	00002097          	auipc	ra,0x2
    3cd8:	80c080e7          	jalr	-2036(ra) # 54e0 <exit>
  pipe(pfds);
    3cdc:	fc840513          	addi	a0,s0,-56
    3ce0:	00002097          	auipc	ra,0x2
    3ce4:	810080e7          	jalr	-2032(ra) # 54f0 <pipe>
  pid3 = fork();
    3ce8:	00001097          	auipc	ra,0x1
    3cec:	7f0080e7          	jalr	2032(ra) # 54d8 <fork>
    3cf0:	892a                	mv	s2,a0
  if(pid3 < 0) {
    3cf2:	02054e63          	bltz	a0,3d2e <preempt+0xc0>
  if(pid3 == 0){
    3cf6:	e525                	bnez	a0,3d5e <preempt+0xf0>
    close(pfds[0]);
    3cf8:	fc842503          	lw	a0,-56(s0)
    3cfc:	00002097          	auipc	ra,0x2
    3d00:	80c080e7          	jalr	-2036(ra) # 5508 <close>
    if(write(pfds[1], "x", 1) != 1)
    3d04:	4605                	li	a2,1
    3d06:	00002597          	auipc	a1,0x2
    3d0a:	08a58593          	addi	a1,a1,138 # 5d90 <malloc+0x47a>
    3d0e:	fcc42503          	lw	a0,-52(s0)
    3d12:	00001097          	auipc	ra,0x1
    3d16:	7ee080e7          	jalr	2030(ra) # 5500 <write>
    3d1a:	4785                	li	a5,1
    3d1c:	02f51763          	bne	a0,a5,3d4a <preempt+0xdc>
    close(pfds[1]);
    3d20:	fcc42503          	lw	a0,-52(s0)
    3d24:	00001097          	auipc	ra,0x1
    3d28:	7e4080e7          	jalr	2020(ra) # 5508 <close>
    for(;;)
    3d2c:	a001                	j	3d2c <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3d2e:	85a6                	mv	a1,s1
    3d30:	00003517          	auipc	a0,0x3
    3d34:	82850513          	addi	a0,a0,-2008 # 6558 <malloc+0xc42>
    3d38:	00002097          	auipc	ra,0x2
    3d3c:	b20080e7          	jalr	-1248(ra) # 5858 <printf>
     exit(1);
    3d40:	4505                	li	a0,1
    3d42:	00001097          	auipc	ra,0x1
    3d46:	79e080e7          	jalr	1950(ra) # 54e0 <exit>
      printf("%s: preempt write error", s);
    3d4a:	85a6                	mv	a1,s1
    3d4c:	00004517          	auipc	a0,0x4
    3d50:	a1450513          	addi	a0,a0,-1516 # 7760 <malloc+0x1e4a>
    3d54:	00002097          	auipc	ra,0x2
    3d58:	b04080e7          	jalr	-1276(ra) # 5858 <printf>
    3d5c:	b7d1                	j	3d20 <preempt+0xb2>
  close(pfds[1]);
    3d5e:	fcc42503          	lw	a0,-52(s0)
    3d62:	00001097          	auipc	ra,0x1
    3d66:	7a6080e7          	jalr	1958(ra) # 5508 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3d6a:	660d                	lui	a2,0x3
    3d6c:	00008597          	auipc	a1,0x8
    3d70:	b7c58593          	addi	a1,a1,-1156 # b8e8 <buf>
    3d74:	fc842503          	lw	a0,-56(s0)
    3d78:	00001097          	auipc	ra,0x1
    3d7c:	780080e7          	jalr	1920(ra) # 54f8 <read>
    3d80:	4785                	li	a5,1
    3d82:	02f50363          	beq	a0,a5,3da8 <preempt+0x13a>
    printf("%s: preempt read error", s);
    3d86:	85a6                	mv	a1,s1
    3d88:	00004517          	auipc	a0,0x4
    3d8c:	9f050513          	addi	a0,a0,-1552 # 7778 <malloc+0x1e62>
    3d90:	00002097          	auipc	ra,0x2
    3d94:	ac8080e7          	jalr	-1336(ra) # 5858 <printf>
}
    3d98:	70e2                	ld	ra,56(sp)
    3d9a:	7442                	ld	s0,48(sp)
    3d9c:	74a2                	ld	s1,40(sp)
    3d9e:	7902                	ld	s2,32(sp)
    3da0:	69e2                	ld	s3,24(sp)
    3da2:	6a42                	ld	s4,16(sp)
    3da4:	6121                	addi	sp,sp,64
    3da6:	8082                	ret
  close(pfds[0]);
    3da8:	fc842503          	lw	a0,-56(s0)
    3dac:	00001097          	auipc	ra,0x1
    3db0:	75c080e7          	jalr	1884(ra) # 5508 <close>
  printf("kill... ");
    3db4:	00004517          	auipc	a0,0x4
    3db8:	9dc50513          	addi	a0,a0,-1572 # 7790 <malloc+0x1e7a>
    3dbc:	00002097          	auipc	ra,0x2
    3dc0:	a9c080e7          	jalr	-1380(ra) # 5858 <printf>
  kill(pid1);
    3dc4:	8552                	mv	a0,s4
    3dc6:	00001097          	auipc	ra,0x1
    3dca:	74a080e7          	jalr	1866(ra) # 5510 <kill>
  kill(pid2);
    3dce:	854e                	mv	a0,s3
    3dd0:	00001097          	auipc	ra,0x1
    3dd4:	740080e7          	jalr	1856(ra) # 5510 <kill>
  kill(pid3);
    3dd8:	854a                	mv	a0,s2
    3dda:	00001097          	auipc	ra,0x1
    3dde:	736080e7          	jalr	1846(ra) # 5510 <kill>
  printf("wait... ");
    3de2:	00004517          	auipc	a0,0x4
    3de6:	9be50513          	addi	a0,a0,-1602 # 77a0 <malloc+0x1e8a>
    3dea:	00002097          	auipc	ra,0x2
    3dee:	a6e080e7          	jalr	-1426(ra) # 5858 <printf>
  wait(0);
    3df2:	4501                	li	a0,0
    3df4:	00001097          	auipc	ra,0x1
    3df8:	6f4080e7          	jalr	1780(ra) # 54e8 <wait>
  wait(0);
    3dfc:	4501                	li	a0,0
    3dfe:	00001097          	auipc	ra,0x1
    3e02:	6ea080e7          	jalr	1770(ra) # 54e8 <wait>
  wait(0);
    3e06:	4501                	li	a0,0
    3e08:	00001097          	auipc	ra,0x1
    3e0c:	6e0080e7          	jalr	1760(ra) # 54e8 <wait>
    3e10:	b761                	j	3d98 <preempt+0x12a>

0000000000003e12 <reparent>:
{
    3e12:	7179                	addi	sp,sp,-48
    3e14:	f406                	sd	ra,40(sp)
    3e16:	f022                	sd	s0,32(sp)
    3e18:	ec26                	sd	s1,24(sp)
    3e1a:	e84a                	sd	s2,16(sp)
    3e1c:	e44e                	sd	s3,8(sp)
    3e1e:	e052                	sd	s4,0(sp)
    3e20:	1800                	addi	s0,sp,48
    3e22:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3e24:	00001097          	auipc	ra,0x1
    3e28:	73c080e7          	jalr	1852(ra) # 5560 <getpid>
    3e2c:	8a2a                	mv	s4,a0
    3e2e:	0c800913          	li	s2,200
    int pid = fork();
    3e32:	00001097          	auipc	ra,0x1
    3e36:	6a6080e7          	jalr	1702(ra) # 54d8 <fork>
    3e3a:	84aa                	mv	s1,a0
    if(pid < 0){
    3e3c:	02054263          	bltz	a0,3e60 <reparent+0x4e>
    if(pid){
    3e40:	cd21                	beqz	a0,3e98 <reparent+0x86>
      if(wait(0) != pid){
    3e42:	4501                	li	a0,0
    3e44:	00001097          	auipc	ra,0x1
    3e48:	6a4080e7          	jalr	1700(ra) # 54e8 <wait>
    3e4c:	02951863          	bne	a0,s1,3e7c <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    3e50:	397d                	addiw	s2,s2,-1
    3e52:	fe0910e3          	bnez	s2,3e32 <reparent+0x20>
  exit(0);
    3e56:	4501                	li	a0,0
    3e58:	00001097          	auipc	ra,0x1
    3e5c:	688080e7          	jalr	1672(ra) # 54e0 <exit>
      printf("%s: fork failed\n", s);
    3e60:	85ce                	mv	a1,s3
    3e62:	00002517          	auipc	a0,0x2
    3e66:	6f650513          	addi	a0,a0,1782 # 6558 <malloc+0xc42>
    3e6a:	00002097          	auipc	ra,0x2
    3e6e:	9ee080e7          	jalr	-1554(ra) # 5858 <printf>
      exit(1);
    3e72:	4505                	li	a0,1
    3e74:	00001097          	auipc	ra,0x1
    3e78:	66c080e7          	jalr	1644(ra) # 54e0 <exit>
        printf("%s: wait wrong pid\n", s);
    3e7c:	85ce                	mv	a1,s3
    3e7e:	00003517          	auipc	a0,0x3
    3e82:	86250513          	addi	a0,a0,-1950 # 66e0 <malloc+0xdca>
    3e86:	00002097          	auipc	ra,0x2
    3e8a:	9d2080e7          	jalr	-1582(ra) # 5858 <printf>
        exit(1);
    3e8e:	4505                	li	a0,1
    3e90:	00001097          	auipc	ra,0x1
    3e94:	650080e7          	jalr	1616(ra) # 54e0 <exit>
      int pid2 = fork();
    3e98:	00001097          	auipc	ra,0x1
    3e9c:	640080e7          	jalr	1600(ra) # 54d8 <fork>
      if(pid2 < 0){
    3ea0:	00054763          	bltz	a0,3eae <reparent+0x9c>
      exit(0);
    3ea4:	4501                	li	a0,0
    3ea6:	00001097          	auipc	ra,0x1
    3eaa:	63a080e7          	jalr	1594(ra) # 54e0 <exit>
        kill(master_pid);
    3eae:	8552                	mv	a0,s4
    3eb0:	00001097          	auipc	ra,0x1
    3eb4:	660080e7          	jalr	1632(ra) # 5510 <kill>
        exit(1);
    3eb8:	4505                	li	a0,1
    3eba:	00001097          	auipc	ra,0x1
    3ebe:	626080e7          	jalr	1574(ra) # 54e0 <exit>

0000000000003ec2 <mem>:
{
    3ec2:	7139                	addi	sp,sp,-64
    3ec4:	fc06                	sd	ra,56(sp)
    3ec6:	f822                	sd	s0,48(sp)
    3ec8:	f426                	sd	s1,40(sp)
    3eca:	f04a                	sd	s2,32(sp)
    3ecc:	ec4e                	sd	s3,24(sp)
    3ece:	0080                	addi	s0,sp,64
    3ed0:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3ed2:	00001097          	auipc	ra,0x1
    3ed6:	606080e7          	jalr	1542(ra) # 54d8 <fork>
    m1 = 0;
    3eda:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3edc:	6909                	lui	s2,0x2
    3ede:	71190913          	addi	s2,s2,1809 # 2711 <sbrkarg+0x7d>
  if((pid = fork()) == 0){
    3ee2:	ed39                	bnez	a0,3f40 <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    3ee4:	854a                	mv	a0,s2
    3ee6:	00002097          	auipc	ra,0x2
    3eea:	a30080e7          	jalr	-1488(ra) # 5916 <malloc>
    3eee:	c501                	beqz	a0,3ef6 <mem+0x34>
      *(char**)m2 = m1;
    3ef0:	e104                	sd	s1,0(a0)
      m1 = m2;
    3ef2:	84aa                	mv	s1,a0
    3ef4:	bfc5                	j	3ee4 <mem+0x22>
    while(m1){
    3ef6:	c881                	beqz	s1,3f06 <mem+0x44>
      m2 = *(char**)m1;
    3ef8:	8526                	mv	a0,s1
    3efa:	6084                	ld	s1,0(s1)
      free(m1);
    3efc:	00002097          	auipc	ra,0x2
    3f00:	992080e7          	jalr	-1646(ra) # 588e <free>
    while(m1){
    3f04:	f8f5                	bnez	s1,3ef8 <mem+0x36>
    m1 = malloc(1024*20);
    3f06:	6515                	lui	a0,0x5
    3f08:	00002097          	auipc	ra,0x2
    3f0c:	a0e080e7          	jalr	-1522(ra) # 5916 <malloc>
    if(m1 == 0){
    3f10:	c911                	beqz	a0,3f24 <mem+0x62>
    free(m1);
    3f12:	00002097          	auipc	ra,0x2
    3f16:	97c080e7          	jalr	-1668(ra) # 588e <free>
    exit(0);
    3f1a:	4501                	li	a0,0
    3f1c:	00001097          	auipc	ra,0x1
    3f20:	5c4080e7          	jalr	1476(ra) # 54e0 <exit>
      printf("couldn't allocate mem?!!\n", s);
    3f24:	85ce                	mv	a1,s3
    3f26:	00004517          	auipc	a0,0x4
    3f2a:	88a50513          	addi	a0,a0,-1910 # 77b0 <malloc+0x1e9a>
    3f2e:	00002097          	auipc	ra,0x2
    3f32:	92a080e7          	jalr	-1750(ra) # 5858 <printf>
      exit(1);
    3f36:	4505                	li	a0,1
    3f38:	00001097          	auipc	ra,0x1
    3f3c:	5a8080e7          	jalr	1448(ra) # 54e0 <exit>
    wait(&xstatus);
    3f40:	fcc40513          	addi	a0,s0,-52
    3f44:	00001097          	auipc	ra,0x1
    3f48:	5a4080e7          	jalr	1444(ra) # 54e8 <wait>
    if(xstatus == -1){
    3f4c:	fcc42503          	lw	a0,-52(s0)
    3f50:	57fd                	li	a5,-1
    3f52:	00f50663          	beq	a0,a5,3f5e <mem+0x9c>
    exit(xstatus);
    3f56:	00001097          	auipc	ra,0x1
    3f5a:	58a080e7          	jalr	1418(ra) # 54e0 <exit>
      exit(0);
    3f5e:	4501                	li	a0,0
    3f60:	00001097          	auipc	ra,0x1
    3f64:	580080e7          	jalr	1408(ra) # 54e0 <exit>

0000000000003f68 <sharedfd>:
{
    3f68:	7159                	addi	sp,sp,-112
    3f6a:	f486                	sd	ra,104(sp)
    3f6c:	f0a2                	sd	s0,96(sp)
    3f6e:	eca6                	sd	s1,88(sp)
    3f70:	e8ca                	sd	s2,80(sp)
    3f72:	e4ce                	sd	s3,72(sp)
    3f74:	e0d2                	sd	s4,64(sp)
    3f76:	fc56                	sd	s5,56(sp)
    3f78:	f85a                	sd	s6,48(sp)
    3f7a:	f45e                	sd	s7,40(sp)
    3f7c:	1880                	addi	s0,sp,112
    3f7e:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    3f80:	00002517          	auipc	a0,0x2
    3f84:	c0850513          	addi	a0,a0,-1016 # 5b88 <malloc+0x272>
    3f88:	00001097          	auipc	ra,0x1
    3f8c:	5a8080e7          	jalr	1448(ra) # 5530 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3f90:	20200593          	li	a1,514
    3f94:	00002517          	auipc	a0,0x2
    3f98:	bf450513          	addi	a0,a0,-1036 # 5b88 <malloc+0x272>
    3f9c:	00001097          	auipc	ra,0x1
    3fa0:	584080e7          	jalr	1412(ra) # 5520 <open>
  if(fd < 0){
    3fa4:	04054a63          	bltz	a0,3ff8 <sharedfd+0x90>
    3fa8:	892a                	mv	s2,a0
  pid = fork();
    3faa:	00001097          	auipc	ra,0x1
    3fae:	52e080e7          	jalr	1326(ra) # 54d8 <fork>
    3fb2:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3fb4:	06300593          	li	a1,99
    3fb8:	c119                	beqz	a0,3fbe <sharedfd+0x56>
    3fba:	07000593          	li	a1,112
    3fbe:	4629                	li	a2,10
    3fc0:	fa040513          	addi	a0,s0,-96
    3fc4:	00001097          	auipc	ra,0x1
    3fc8:	318080e7          	jalr	792(ra) # 52dc <memset>
    3fcc:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3fd0:	4629                	li	a2,10
    3fd2:	fa040593          	addi	a1,s0,-96
    3fd6:	854a                	mv	a0,s2
    3fd8:	00001097          	auipc	ra,0x1
    3fdc:	528080e7          	jalr	1320(ra) # 5500 <write>
    3fe0:	47a9                	li	a5,10
    3fe2:	02f51963          	bne	a0,a5,4014 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    3fe6:	34fd                	addiw	s1,s1,-1
    3fe8:	f4e5                	bnez	s1,3fd0 <sharedfd+0x68>
  if(pid == 0) {
    3fea:	04099363          	bnez	s3,4030 <sharedfd+0xc8>
    exit(0);
    3fee:	4501                	li	a0,0
    3ff0:	00001097          	auipc	ra,0x1
    3ff4:	4f0080e7          	jalr	1264(ra) # 54e0 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    3ff8:	85d2                	mv	a1,s4
    3ffa:	00003517          	auipc	a0,0x3
    3ffe:	7d650513          	addi	a0,a0,2006 # 77d0 <malloc+0x1eba>
    4002:	00002097          	auipc	ra,0x2
    4006:	856080e7          	jalr	-1962(ra) # 5858 <printf>
    exit(1);
    400a:	4505                	li	a0,1
    400c:	00001097          	auipc	ra,0x1
    4010:	4d4080e7          	jalr	1236(ra) # 54e0 <exit>
      printf("%s: write sharedfd failed\n", s);
    4014:	85d2                	mv	a1,s4
    4016:	00003517          	auipc	a0,0x3
    401a:	7e250513          	addi	a0,a0,2018 # 77f8 <malloc+0x1ee2>
    401e:	00002097          	auipc	ra,0x2
    4022:	83a080e7          	jalr	-1990(ra) # 5858 <printf>
      exit(1);
    4026:	4505                	li	a0,1
    4028:	00001097          	auipc	ra,0x1
    402c:	4b8080e7          	jalr	1208(ra) # 54e0 <exit>
    wait(&xstatus);
    4030:	f9c40513          	addi	a0,s0,-100
    4034:	00001097          	auipc	ra,0x1
    4038:	4b4080e7          	jalr	1204(ra) # 54e8 <wait>
    if(xstatus != 0)
    403c:	f9c42983          	lw	s3,-100(s0)
    4040:	00098763          	beqz	s3,404e <sharedfd+0xe6>
      exit(xstatus);
    4044:	854e                	mv	a0,s3
    4046:	00001097          	auipc	ra,0x1
    404a:	49a080e7          	jalr	1178(ra) # 54e0 <exit>
  close(fd);
    404e:	854a                	mv	a0,s2
    4050:	00001097          	auipc	ra,0x1
    4054:	4b8080e7          	jalr	1208(ra) # 5508 <close>
  fd = open("sharedfd", 0);
    4058:	4581                	li	a1,0
    405a:	00002517          	auipc	a0,0x2
    405e:	b2e50513          	addi	a0,a0,-1234 # 5b88 <malloc+0x272>
    4062:	00001097          	auipc	ra,0x1
    4066:	4be080e7          	jalr	1214(ra) # 5520 <open>
    406a:	8baa                	mv	s7,a0
  nc = np = 0;
    406c:	8ace                	mv	s5,s3
  if(fd < 0){
    406e:	02054563          	bltz	a0,4098 <sharedfd+0x130>
    4072:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4076:	06300493          	li	s1,99
      if(buf[i] == 'p')
    407a:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    407e:	4629                	li	a2,10
    4080:	fa040593          	addi	a1,s0,-96
    4084:	855e                	mv	a0,s7
    4086:	00001097          	auipc	ra,0x1
    408a:	472080e7          	jalr	1138(ra) # 54f8 <read>
    408e:	02a05f63          	blez	a0,40cc <sharedfd+0x164>
    4092:	fa040793          	addi	a5,s0,-96
    4096:	a01d                	j	40bc <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4098:	85d2                	mv	a1,s4
    409a:	00003517          	auipc	a0,0x3
    409e:	77e50513          	addi	a0,a0,1918 # 7818 <malloc+0x1f02>
    40a2:	00001097          	auipc	ra,0x1
    40a6:	7b6080e7          	jalr	1974(ra) # 5858 <printf>
    exit(1);
    40aa:	4505                	li	a0,1
    40ac:	00001097          	auipc	ra,0x1
    40b0:	434080e7          	jalr	1076(ra) # 54e0 <exit>
        nc++;
    40b4:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    40b6:	0785                	addi	a5,a5,1
    40b8:	fd2783e3          	beq	a5,s2,407e <sharedfd+0x116>
      if(buf[i] == 'c')
    40bc:	0007c703          	lbu	a4,0(a5)
    40c0:	fe970ae3          	beq	a4,s1,40b4 <sharedfd+0x14c>
      if(buf[i] == 'p')
    40c4:	ff6719e3          	bne	a4,s6,40b6 <sharedfd+0x14e>
        np++;
    40c8:	2a85                	addiw	s5,s5,1
    40ca:	b7f5                	j	40b6 <sharedfd+0x14e>
  close(fd);
    40cc:	855e                	mv	a0,s7
    40ce:	00001097          	auipc	ra,0x1
    40d2:	43a080e7          	jalr	1082(ra) # 5508 <close>
  unlink("sharedfd");
    40d6:	00002517          	auipc	a0,0x2
    40da:	ab250513          	addi	a0,a0,-1358 # 5b88 <malloc+0x272>
    40de:	00001097          	auipc	ra,0x1
    40e2:	452080e7          	jalr	1106(ra) # 5530 <unlink>
  if(nc == N*SZ && np == N*SZ){
    40e6:	6789                	lui	a5,0x2
    40e8:	71078793          	addi	a5,a5,1808 # 2710 <sbrkarg+0x7c>
    40ec:	00f99763          	bne	s3,a5,40fa <sharedfd+0x192>
    40f0:	6789                	lui	a5,0x2
    40f2:	71078793          	addi	a5,a5,1808 # 2710 <sbrkarg+0x7c>
    40f6:	02fa8063          	beq	s5,a5,4116 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    40fa:	85d2                	mv	a1,s4
    40fc:	00003517          	auipc	a0,0x3
    4100:	74450513          	addi	a0,a0,1860 # 7840 <malloc+0x1f2a>
    4104:	00001097          	auipc	ra,0x1
    4108:	754080e7          	jalr	1876(ra) # 5858 <printf>
    exit(1);
    410c:	4505                	li	a0,1
    410e:	00001097          	auipc	ra,0x1
    4112:	3d2080e7          	jalr	978(ra) # 54e0 <exit>
    exit(0);
    4116:	4501                	li	a0,0
    4118:	00001097          	auipc	ra,0x1
    411c:	3c8080e7          	jalr	968(ra) # 54e0 <exit>

0000000000004120 <fourfiles>:
{
    4120:	7171                	addi	sp,sp,-176
    4122:	f506                	sd	ra,168(sp)
    4124:	f122                	sd	s0,160(sp)
    4126:	ed26                	sd	s1,152(sp)
    4128:	e94a                	sd	s2,144(sp)
    412a:	e54e                	sd	s3,136(sp)
    412c:	e152                	sd	s4,128(sp)
    412e:	fcd6                	sd	s5,120(sp)
    4130:	f8da                	sd	s6,112(sp)
    4132:	f4de                	sd	s7,104(sp)
    4134:	f0e2                	sd	s8,96(sp)
    4136:	ece6                	sd	s9,88(sp)
    4138:	e8ea                	sd	s10,80(sp)
    413a:	e4ee                	sd	s11,72(sp)
    413c:	1900                	addi	s0,sp,176
    413e:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4140:	00002797          	auipc	a5,0x2
    4144:	8c078793          	addi	a5,a5,-1856 # 5a00 <malloc+0xea>
    4148:	f6f43823          	sd	a5,-144(s0)
    414c:	00002797          	auipc	a5,0x2
    4150:	8bc78793          	addi	a5,a5,-1860 # 5a08 <malloc+0xf2>
    4154:	f6f43c23          	sd	a5,-136(s0)
    4158:	00002797          	auipc	a5,0x2
    415c:	8b878793          	addi	a5,a5,-1864 # 5a10 <malloc+0xfa>
    4160:	f8f43023          	sd	a5,-128(s0)
    4164:	00002797          	auipc	a5,0x2
    4168:	8b478793          	addi	a5,a5,-1868 # 5a18 <malloc+0x102>
    416c:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4170:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4174:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4176:	4481                	li	s1,0
    4178:	4a11                	li	s4,4
    fname = names[pi];
    417a:	00093983          	ld	s3,0(s2)
    unlink(fname);
    417e:	854e                	mv	a0,s3
    4180:	00001097          	auipc	ra,0x1
    4184:	3b0080e7          	jalr	944(ra) # 5530 <unlink>
    pid = fork();
    4188:	00001097          	auipc	ra,0x1
    418c:	350080e7          	jalr	848(ra) # 54d8 <fork>
    if(pid < 0){
    4190:	04054563          	bltz	a0,41da <fourfiles+0xba>
    if(pid == 0){
    4194:	c12d                	beqz	a0,41f6 <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    4196:	2485                	addiw	s1,s1,1
    4198:	0921                	addi	s2,s2,8
    419a:	ff4490e3          	bne	s1,s4,417a <fourfiles+0x5a>
    419e:	4491                	li	s1,4
    wait(&xstatus);
    41a0:	f6c40513          	addi	a0,s0,-148
    41a4:	00001097          	auipc	ra,0x1
    41a8:	344080e7          	jalr	836(ra) # 54e8 <wait>
    if(xstatus != 0)
    41ac:	f6c42503          	lw	a0,-148(s0)
    41b0:	ed69                	bnez	a0,428a <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    41b2:	34fd                	addiw	s1,s1,-1
    41b4:	f4f5                	bnez	s1,41a0 <fourfiles+0x80>
    41b6:	03000b13          	li	s6,48
    total = 0;
    41ba:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    41be:	00007a17          	auipc	s4,0x7
    41c2:	72aa0a13          	addi	s4,s4,1834 # b8e8 <buf>
    41c6:	00007a97          	auipc	s5,0x7
    41ca:	723a8a93          	addi	s5,s5,1827 # b8e9 <buf+0x1>
    if(total != N*SZ){
    41ce:	6d05                	lui	s10,0x1
    41d0:	770d0d13          	addi	s10,s10,1904 # 1770 <pipe1+0x1e>
  for(i = 0; i < NCHILD; i++){
    41d4:	03400d93          	li	s11,52
    41d8:	a23d                	j	4306 <fourfiles+0x1e6>
      printf("fork failed\n", s);
    41da:	85e6                	mv	a1,s9
    41dc:	00002517          	auipc	a0,0x2
    41e0:	74c50513          	addi	a0,a0,1868 # 6928 <malloc+0x1012>
    41e4:	00001097          	auipc	ra,0x1
    41e8:	674080e7          	jalr	1652(ra) # 5858 <printf>
      exit(1);
    41ec:	4505                	li	a0,1
    41ee:	00001097          	auipc	ra,0x1
    41f2:	2f2080e7          	jalr	754(ra) # 54e0 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    41f6:	20200593          	li	a1,514
    41fa:	854e                	mv	a0,s3
    41fc:	00001097          	auipc	ra,0x1
    4200:	324080e7          	jalr	804(ra) # 5520 <open>
    4204:	892a                	mv	s2,a0
      if(fd < 0){
    4206:	04054763          	bltz	a0,4254 <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    420a:	1f400613          	li	a2,500
    420e:	0304859b          	addiw	a1,s1,48
    4212:	00007517          	auipc	a0,0x7
    4216:	6d650513          	addi	a0,a0,1750 # b8e8 <buf>
    421a:	00001097          	auipc	ra,0x1
    421e:	0c2080e7          	jalr	194(ra) # 52dc <memset>
    4222:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4224:	00007997          	auipc	s3,0x7
    4228:	6c498993          	addi	s3,s3,1732 # b8e8 <buf>
    422c:	1f400613          	li	a2,500
    4230:	85ce                	mv	a1,s3
    4232:	854a                	mv	a0,s2
    4234:	00001097          	auipc	ra,0x1
    4238:	2cc080e7          	jalr	716(ra) # 5500 <write>
    423c:	85aa                	mv	a1,a0
    423e:	1f400793          	li	a5,500
    4242:	02f51763          	bne	a0,a5,4270 <fourfiles+0x150>
      for(i = 0; i < N; i++){
    4246:	34fd                	addiw	s1,s1,-1
    4248:	f0f5                	bnez	s1,422c <fourfiles+0x10c>
      exit(0);
    424a:	4501                	li	a0,0
    424c:	00001097          	auipc	ra,0x1
    4250:	294080e7          	jalr	660(ra) # 54e0 <exit>
        printf("create failed\n", s);
    4254:	85e6                	mv	a1,s9
    4256:	00003517          	auipc	a0,0x3
    425a:	60250513          	addi	a0,a0,1538 # 7858 <malloc+0x1f42>
    425e:	00001097          	auipc	ra,0x1
    4262:	5fa080e7          	jalr	1530(ra) # 5858 <printf>
        exit(1);
    4266:	4505                	li	a0,1
    4268:	00001097          	auipc	ra,0x1
    426c:	278080e7          	jalr	632(ra) # 54e0 <exit>
          printf("write failed %d\n", n);
    4270:	00003517          	auipc	a0,0x3
    4274:	5f850513          	addi	a0,a0,1528 # 7868 <malloc+0x1f52>
    4278:	00001097          	auipc	ra,0x1
    427c:	5e0080e7          	jalr	1504(ra) # 5858 <printf>
          exit(1);
    4280:	4505                	li	a0,1
    4282:	00001097          	auipc	ra,0x1
    4286:	25e080e7          	jalr	606(ra) # 54e0 <exit>
      exit(xstatus);
    428a:	00001097          	auipc	ra,0x1
    428e:	256080e7          	jalr	598(ra) # 54e0 <exit>
          printf("wrong char\n", s);
    4292:	85e6                	mv	a1,s9
    4294:	00003517          	auipc	a0,0x3
    4298:	5ec50513          	addi	a0,a0,1516 # 7880 <malloc+0x1f6a>
    429c:	00001097          	auipc	ra,0x1
    42a0:	5bc080e7          	jalr	1468(ra) # 5858 <printf>
          exit(1);
    42a4:	4505                	li	a0,1
    42a6:	00001097          	auipc	ra,0x1
    42aa:	23a080e7          	jalr	570(ra) # 54e0 <exit>
      total += n;
    42ae:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    42b2:	660d                	lui	a2,0x3
    42b4:	85d2                	mv	a1,s4
    42b6:	854e                	mv	a0,s3
    42b8:	00001097          	auipc	ra,0x1
    42bc:	240080e7          	jalr	576(ra) # 54f8 <read>
    42c0:	02a05363          	blez	a0,42e6 <fourfiles+0x1c6>
    42c4:	00007797          	auipc	a5,0x7
    42c8:	62478793          	addi	a5,a5,1572 # b8e8 <buf>
    42cc:	fff5069b          	addiw	a3,a0,-1
    42d0:	1682                	slli	a3,a3,0x20
    42d2:	9281                	srli	a3,a3,0x20
    42d4:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    42d6:	0007c703          	lbu	a4,0(a5)
    42da:	fa971ce3          	bne	a4,s1,4292 <fourfiles+0x172>
      for(j = 0; j < n; j++){
    42de:	0785                	addi	a5,a5,1
    42e0:	fed79be3          	bne	a5,a3,42d6 <fourfiles+0x1b6>
    42e4:	b7e9                	j	42ae <fourfiles+0x18e>
    close(fd);
    42e6:	854e                	mv	a0,s3
    42e8:	00001097          	auipc	ra,0x1
    42ec:	220080e7          	jalr	544(ra) # 5508 <close>
    if(total != N*SZ){
    42f0:	03a91963          	bne	s2,s10,4322 <fourfiles+0x202>
    unlink(fname);
    42f4:	8562                	mv	a0,s8
    42f6:	00001097          	auipc	ra,0x1
    42fa:	23a080e7          	jalr	570(ra) # 5530 <unlink>
  for(i = 0; i < NCHILD; i++){
    42fe:	0ba1                	addi	s7,s7,8
    4300:	2b05                	addiw	s6,s6,1
    4302:	03bb0e63          	beq	s6,s11,433e <fourfiles+0x21e>
    fname = names[i];
    4306:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    430a:	4581                	li	a1,0
    430c:	8562                	mv	a0,s8
    430e:	00001097          	auipc	ra,0x1
    4312:	212080e7          	jalr	530(ra) # 5520 <open>
    4316:	89aa                	mv	s3,a0
    total = 0;
    4318:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    431c:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4320:	bf49                	j	42b2 <fourfiles+0x192>
      printf("wrong length %d\n", total);
    4322:	85ca                	mv	a1,s2
    4324:	00003517          	auipc	a0,0x3
    4328:	56c50513          	addi	a0,a0,1388 # 7890 <malloc+0x1f7a>
    432c:	00001097          	auipc	ra,0x1
    4330:	52c080e7          	jalr	1324(ra) # 5858 <printf>
      exit(1);
    4334:	4505                	li	a0,1
    4336:	00001097          	auipc	ra,0x1
    433a:	1aa080e7          	jalr	426(ra) # 54e0 <exit>
}
    433e:	70aa                	ld	ra,168(sp)
    4340:	740a                	ld	s0,160(sp)
    4342:	64ea                	ld	s1,152(sp)
    4344:	694a                	ld	s2,144(sp)
    4346:	69aa                	ld	s3,136(sp)
    4348:	6a0a                	ld	s4,128(sp)
    434a:	7ae6                	ld	s5,120(sp)
    434c:	7b46                	ld	s6,112(sp)
    434e:	7ba6                	ld	s7,104(sp)
    4350:	7c06                	ld	s8,96(sp)
    4352:	6ce6                	ld	s9,88(sp)
    4354:	6d46                	ld	s10,80(sp)
    4356:	6da6                	ld	s11,72(sp)
    4358:	614d                	addi	sp,sp,176
    435a:	8082                	ret

000000000000435c <concreate>:
{
    435c:	7135                	addi	sp,sp,-160
    435e:	ed06                	sd	ra,152(sp)
    4360:	e922                	sd	s0,144(sp)
    4362:	e526                	sd	s1,136(sp)
    4364:	e14a                	sd	s2,128(sp)
    4366:	fcce                	sd	s3,120(sp)
    4368:	f8d2                	sd	s4,112(sp)
    436a:	f4d6                	sd	s5,104(sp)
    436c:	f0da                	sd	s6,96(sp)
    436e:	ecde                	sd	s7,88(sp)
    4370:	1100                	addi	s0,sp,160
    4372:	89aa                	mv	s3,a0
  file[0] = 'C';
    4374:	04300793          	li	a5,67
    4378:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    437c:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4380:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4382:	4b0d                	li	s6,3
    4384:	4a85                	li	s5,1
      link("C0", file);
    4386:	00003b97          	auipc	s7,0x3
    438a:	522b8b93          	addi	s7,s7,1314 # 78a8 <malloc+0x1f92>
  for(i = 0; i < N; i++){
    438e:	02800a13          	li	s4,40
    4392:	acc1                	j	4662 <concreate+0x306>
      link("C0", file);
    4394:	fa840593          	addi	a1,s0,-88
    4398:	855e                	mv	a0,s7
    439a:	00001097          	auipc	ra,0x1
    439e:	1a6080e7          	jalr	422(ra) # 5540 <link>
    if(pid == 0) {
    43a2:	a45d                	j	4648 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    43a4:	4795                	li	a5,5
    43a6:	02f9693b          	remw	s2,s2,a5
    43aa:	4785                	li	a5,1
    43ac:	02f90b63          	beq	s2,a5,43e2 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    43b0:	20200593          	li	a1,514
    43b4:	fa840513          	addi	a0,s0,-88
    43b8:	00001097          	auipc	ra,0x1
    43bc:	168080e7          	jalr	360(ra) # 5520 <open>
      if(fd < 0){
    43c0:	26055b63          	bgez	a0,4636 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    43c4:	fa840593          	addi	a1,s0,-88
    43c8:	00003517          	auipc	a0,0x3
    43cc:	4e850513          	addi	a0,a0,1256 # 78b0 <malloc+0x1f9a>
    43d0:	00001097          	auipc	ra,0x1
    43d4:	488080e7          	jalr	1160(ra) # 5858 <printf>
        exit(1);
    43d8:	4505                	li	a0,1
    43da:	00001097          	auipc	ra,0x1
    43de:	106080e7          	jalr	262(ra) # 54e0 <exit>
      link("C0", file);
    43e2:	fa840593          	addi	a1,s0,-88
    43e6:	00003517          	auipc	a0,0x3
    43ea:	4c250513          	addi	a0,a0,1218 # 78a8 <malloc+0x1f92>
    43ee:	00001097          	auipc	ra,0x1
    43f2:	152080e7          	jalr	338(ra) # 5540 <link>
      exit(0);
    43f6:	4501                	li	a0,0
    43f8:	00001097          	auipc	ra,0x1
    43fc:	0e8080e7          	jalr	232(ra) # 54e0 <exit>
        exit(1);
    4400:	4505                	li	a0,1
    4402:	00001097          	auipc	ra,0x1
    4406:	0de080e7          	jalr	222(ra) # 54e0 <exit>
  memset(fa, 0, sizeof(fa));
    440a:	02800613          	li	a2,40
    440e:	4581                	li	a1,0
    4410:	f8040513          	addi	a0,s0,-128
    4414:	00001097          	auipc	ra,0x1
    4418:	ec8080e7          	jalr	-312(ra) # 52dc <memset>
  fd = open(".", 0);
    441c:	4581                	li	a1,0
    441e:	00002517          	auipc	a0,0x2
    4422:	f9a50513          	addi	a0,a0,-102 # 63b8 <malloc+0xaa2>
    4426:	00001097          	auipc	ra,0x1
    442a:	0fa080e7          	jalr	250(ra) # 5520 <open>
    442e:	892a                	mv	s2,a0
  n = 0;
    4430:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4432:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4436:	02700b13          	li	s6,39
      fa[i] = 1;
    443a:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    443c:	a03d                	j	446a <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    443e:	f7240613          	addi	a2,s0,-142
    4442:	85ce                	mv	a1,s3
    4444:	00003517          	auipc	a0,0x3
    4448:	48c50513          	addi	a0,a0,1164 # 78d0 <malloc+0x1fba>
    444c:	00001097          	auipc	ra,0x1
    4450:	40c080e7          	jalr	1036(ra) # 5858 <printf>
        exit(1);
    4454:	4505                	li	a0,1
    4456:	00001097          	auipc	ra,0x1
    445a:	08a080e7          	jalr	138(ra) # 54e0 <exit>
      fa[i] = 1;
    445e:	fb040793          	addi	a5,s0,-80
    4462:	973e                	add	a4,a4,a5
    4464:	fd770823          	sb	s7,-48(a4)
      n++;
    4468:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    446a:	4641                	li	a2,16
    446c:	f7040593          	addi	a1,s0,-144
    4470:	854a                	mv	a0,s2
    4472:	00001097          	auipc	ra,0x1
    4476:	086080e7          	jalr	134(ra) # 54f8 <read>
    447a:	04a05a63          	blez	a0,44ce <concreate+0x172>
    if(de.inum == 0)
    447e:	f7045783          	lhu	a5,-144(s0)
    4482:	d7e5                	beqz	a5,446a <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4484:	f7244783          	lbu	a5,-142(s0)
    4488:	ff4791e3          	bne	a5,s4,446a <concreate+0x10e>
    448c:	f7444783          	lbu	a5,-140(s0)
    4490:	ffe9                	bnez	a5,446a <concreate+0x10e>
      i = de.name[1] - '0';
    4492:	f7344783          	lbu	a5,-141(s0)
    4496:	fd07879b          	addiw	a5,a5,-48
    449a:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    449e:	faeb60e3          	bltu	s6,a4,443e <concreate+0xe2>
      if(fa[i]){
    44a2:	fb040793          	addi	a5,s0,-80
    44a6:	97ba                	add	a5,a5,a4
    44a8:	fd07c783          	lbu	a5,-48(a5)
    44ac:	dbcd                	beqz	a5,445e <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    44ae:	f7240613          	addi	a2,s0,-142
    44b2:	85ce                	mv	a1,s3
    44b4:	00003517          	auipc	a0,0x3
    44b8:	43c50513          	addi	a0,a0,1084 # 78f0 <malloc+0x1fda>
    44bc:	00001097          	auipc	ra,0x1
    44c0:	39c080e7          	jalr	924(ra) # 5858 <printf>
        exit(1);
    44c4:	4505                	li	a0,1
    44c6:	00001097          	auipc	ra,0x1
    44ca:	01a080e7          	jalr	26(ra) # 54e0 <exit>
  close(fd);
    44ce:	854a                	mv	a0,s2
    44d0:	00001097          	auipc	ra,0x1
    44d4:	038080e7          	jalr	56(ra) # 5508 <close>
  if(n != N){
    44d8:	02800793          	li	a5,40
    44dc:	00fa9763          	bne	s5,a5,44ea <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    44e0:	4a8d                	li	s5,3
    44e2:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    44e4:	02800a13          	li	s4,40
    44e8:	a8c9                	j	45ba <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    44ea:	85ce                	mv	a1,s3
    44ec:	00003517          	auipc	a0,0x3
    44f0:	42c50513          	addi	a0,a0,1068 # 7918 <malloc+0x2002>
    44f4:	00001097          	auipc	ra,0x1
    44f8:	364080e7          	jalr	868(ra) # 5858 <printf>
    exit(1);
    44fc:	4505                	li	a0,1
    44fe:	00001097          	auipc	ra,0x1
    4502:	fe2080e7          	jalr	-30(ra) # 54e0 <exit>
      printf("%s: fork failed\n", s);
    4506:	85ce                	mv	a1,s3
    4508:	00002517          	auipc	a0,0x2
    450c:	05050513          	addi	a0,a0,80 # 6558 <malloc+0xc42>
    4510:	00001097          	auipc	ra,0x1
    4514:	348080e7          	jalr	840(ra) # 5858 <printf>
      exit(1);
    4518:	4505                	li	a0,1
    451a:	00001097          	auipc	ra,0x1
    451e:	fc6080e7          	jalr	-58(ra) # 54e0 <exit>
      close(open(file, 0));
    4522:	4581                	li	a1,0
    4524:	fa840513          	addi	a0,s0,-88
    4528:	00001097          	auipc	ra,0x1
    452c:	ff8080e7          	jalr	-8(ra) # 5520 <open>
    4530:	00001097          	auipc	ra,0x1
    4534:	fd8080e7          	jalr	-40(ra) # 5508 <close>
      close(open(file, 0));
    4538:	4581                	li	a1,0
    453a:	fa840513          	addi	a0,s0,-88
    453e:	00001097          	auipc	ra,0x1
    4542:	fe2080e7          	jalr	-30(ra) # 5520 <open>
    4546:	00001097          	auipc	ra,0x1
    454a:	fc2080e7          	jalr	-62(ra) # 5508 <close>
      close(open(file, 0));
    454e:	4581                	li	a1,0
    4550:	fa840513          	addi	a0,s0,-88
    4554:	00001097          	auipc	ra,0x1
    4558:	fcc080e7          	jalr	-52(ra) # 5520 <open>
    455c:	00001097          	auipc	ra,0x1
    4560:	fac080e7          	jalr	-84(ra) # 5508 <close>
      close(open(file, 0));
    4564:	4581                	li	a1,0
    4566:	fa840513          	addi	a0,s0,-88
    456a:	00001097          	auipc	ra,0x1
    456e:	fb6080e7          	jalr	-74(ra) # 5520 <open>
    4572:	00001097          	auipc	ra,0x1
    4576:	f96080e7          	jalr	-106(ra) # 5508 <close>
      close(open(file, 0));
    457a:	4581                	li	a1,0
    457c:	fa840513          	addi	a0,s0,-88
    4580:	00001097          	auipc	ra,0x1
    4584:	fa0080e7          	jalr	-96(ra) # 5520 <open>
    4588:	00001097          	auipc	ra,0x1
    458c:	f80080e7          	jalr	-128(ra) # 5508 <close>
      close(open(file, 0));
    4590:	4581                	li	a1,0
    4592:	fa840513          	addi	a0,s0,-88
    4596:	00001097          	auipc	ra,0x1
    459a:	f8a080e7          	jalr	-118(ra) # 5520 <open>
    459e:	00001097          	auipc	ra,0x1
    45a2:	f6a080e7          	jalr	-150(ra) # 5508 <close>
    if(pid == 0)
    45a6:	08090363          	beqz	s2,462c <concreate+0x2d0>
      wait(0);
    45aa:	4501                	li	a0,0
    45ac:	00001097          	auipc	ra,0x1
    45b0:	f3c080e7          	jalr	-196(ra) # 54e8 <wait>
  for(i = 0; i < N; i++){
    45b4:	2485                	addiw	s1,s1,1
    45b6:	0f448563          	beq	s1,s4,46a0 <concreate+0x344>
    file[1] = '0' + i;
    45ba:	0304879b          	addiw	a5,s1,48
    45be:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    45c2:	00001097          	auipc	ra,0x1
    45c6:	f16080e7          	jalr	-234(ra) # 54d8 <fork>
    45ca:	892a                	mv	s2,a0
    if(pid < 0){
    45cc:	f2054de3          	bltz	a0,4506 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    45d0:	0354e73b          	remw	a4,s1,s5
    45d4:	00a767b3          	or	a5,a4,a0
    45d8:	2781                	sext.w	a5,a5
    45da:	d7a1                	beqz	a5,4522 <concreate+0x1c6>
    45dc:	01671363          	bne	a4,s6,45e2 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    45e0:	f129                	bnez	a0,4522 <concreate+0x1c6>
      unlink(file);
    45e2:	fa840513          	addi	a0,s0,-88
    45e6:	00001097          	auipc	ra,0x1
    45ea:	f4a080e7          	jalr	-182(ra) # 5530 <unlink>
      unlink(file);
    45ee:	fa840513          	addi	a0,s0,-88
    45f2:	00001097          	auipc	ra,0x1
    45f6:	f3e080e7          	jalr	-194(ra) # 5530 <unlink>
      unlink(file);
    45fa:	fa840513          	addi	a0,s0,-88
    45fe:	00001097          	auipc	ra,0x1
    4602:	f32080e7          	jalr	-206(ra) # 5530 <unlink>
      unlink(file);
    4606:	fa840513          	addi	a0,s0,-88
    460a:	00001097          	auipc	ra,0x1
    460e:	f26080e7          	jalr	-218(ra) # 5530 <unlink>
      unlink(file);
    4612:	fa840513          	addi	a0,s0,-88
    4616:	00001097          	auipc	ra,0x1
    461a:	f1a080e7          	jalr	-230(ra) # 5530 <unlink>
      unlink(file);
    461e:	fa840513          	addi	a0,s0,-88
    4622:	00001097          	auipc	ra,0x1
    4626:	f0e080e7          	jalr	-242(ra) # 5530 <unlink>
    462a:	bfb5                	j	45a6 <concreate+0x24a>
      exit(0);
    462c:	4501                	li	a0,0
    462e:	00001097          	auipc	ra,0x1
    4632:	eb2080e7          	jalr	-334(ra) # 54e0 <exit>
      close(fd);
    4636:	00001097          	auipc	ra,0x1
    463a:	ed2080e7          	jalr	-302(ra) # 5508 <close>
    if(pid == 0) {
    463e:	bb65                	j	43f6 <concreate+0x9a>
      close(fd);
    4640:	00001097          	auipc	ra,0x1
    4644:	ec8080e7          	jalr	-312(ra) # 5508 <close>
      wait(&xstatus);
    4648:	f6c40513          	addi	a0,s0,-148
    464c:	00001097          	auipc	ra,0x1
    4650:	e9c080e7          	jalr	-356(ra) # 54e8 <wait>
      if(xstatus != 0)
    4654:	f6c42483          	lw	s1,-148(s0)
    4658:	da0494e3          	bnez	s1,4400 <concreate+0xa4>
  for(i = 0; i < N; i++){
    465c:	2905                	addiw	s2,s2,1
    465e:	db4906e3          	beq	s2,s4,440a <concreate+0xae>
    file[1] = '0' + i;
    4662:	0309079b          	addiw	a5,s2,48
    4666:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    466a:	fa840513          	addi	a0,s0,-88
    466e:	00001097          	auipc	ra,0x1
    4672:	ec2080e7          	jalr	-318(ra) # 5530 <unlink>
    pid = fork();
    4676:	00001097          	auipc	ra,0x1
    467a:	e62080e7          	jalr	-414(ra) # 54d8 <fork>
    if(pid && (i % 3) == 1){
    467e:	d20503e3          	beqz	a0,43a4 <concreate+0x48>
    4682:	036967bb          	remw	a5,s2,s6
    4686:	d15787e3          	beq	a5,s5,4394 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    468a:	20200593          	li	a1,514
    468e:	fa840513          	addi	a0,s0,-88
    4692:	00001097          	auipc	ra,0x1
    4696:	e8e080e7          	jalr	-370(ra) # 5520 <open>
      if(fd < 0){
    469a:	fa0553e3          	bgez	a0,4640 <concreate+0x2e4>
    469e:	b31d                	j	43c4 <concreate+0x68>
}
    46a0:	60ea                	ld	ra,152(sp)
    46a2:	644a                	ld	s0,144(sp)
    46a4:	64aa                	ld	s1,136(sp)
    46a6:	690a                	ld	s2,128(sp)
    46a8:	79e6                	ld	s3,120(sp)
    46aa:	7a46                	ld	s4,112(sp)
    46ac:	7aa6                	ld	s5,104(sp)
    46ae:	7b06                	ld	s6,96(sp)
    46b0:	6be6                	ld	s7,88(sp)
    46b2:	610d                	addi	sp,sp,160
    46b4:	8082                	ret

00000000000046b6 <bigfile>:
{
    46b6:	7139                	addi	sp,sp,-64
    46b8:	fc06                	sd	ra,56(sp)
    46ba:	f822                	sd	s0,48(sp)
    46bc:	f426                	sd	s1,40(sp)
    46be:	f04a                	sd	s2,32(sp)
    46c0:	ec4e                	sd	s3,24(sp)
    46c2:	e852                	sd	s4,16(sp)
    46c4:	e456                	sd	s5,8(sp)
    46c6:	0080                	addi	s0,sp,64
    46c8:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    46ca:	00003517          	auipc	a0,0x3
    46ce:	28650513          	addi	a0,a0,646 # 7950 <malloc+0x203a>
    46d2:	00001097          	auipc	ra,0x1
    46d6:	e5e080e7          	jalr	-418(ra) # 5530 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    46da:	20200593          	li	a1,514
    46de:	00003517          	auipc	a0,0x3
    46e2:	27250513          	addi	a0,a0,626 # 7950 <malloc+0x203a>
    46e6:	00001097          	auipc	ra,0x1
    46ea:	e3a080e7          	jalr	-454(ra) # 5520 <open>
    46ee:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    46f0:	4481                	li	s1,0
    memset(buf, i, SZ);
    46f2:	00007917          	auipc	s2,0x7
    46f6:	1f690913          	addi	s2,s2,502 # b8e8 <buf>
  for(i = 0; i < N; i++){
    46fa:	4a51                	li	s4,20
  if(fd < 0){
    46fc:	0a054063          	bltz	a0,479c <bigfile+0xe6>
    memset(buf, i, SZ);
    4700:	25800613          	li	a2,600
    4704:	85a6                	mv	a1,s1
    4706:	854a                	mv	a0,s2
    4708:	00001097          	auipc	ra,0x1
    470c:	bd4080e7          	jalr	-1068(ra) # 52dc <memset>
    if(write(fd, buf, SZ) != SZ){
    4710:	25800613          	li	a2,600
    4714:	85ca                	mv	a1,s2
    4716:	854e                	mv	a0,s3
    4718:	00001097          	auipc	ra,0x1
    471c:	de8080e7          	jalr	-536(ra) # 5500 <write>
    4720:	25800793          	li	a5,600
    4724:	08f51a63          	bne	a0,a5,47b8 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4728:	2485                	addiw	s1,s1,1
    472a:	fd449be3          	bne	s1,s4,4700 <bigfile+0x4a>
  close(fd);
    472e:	854e                	mv	a0,s3
    4730:	00001097          	auipc	ra,0x1
    4734:	dd8080e7          	jalr	-552(ra) # 5508 <close>
  fd = open("bigfile.dat", 0);
    4738:	4581                	li	a1,0
    473a:	00003517          	auipc	a0,0x3
    473e:	21650513          	addi	a0,a0,534 # 7950 <malloc+0x203a>
    4742:	00001097          	auipc	ra,0x1
    4746:	dde080e7          	jalr	-546(ra) # 5520 <open>
    474a:	8a2a                	mv	s4,a0
  total = 0;
    474c:	4981                	li	s3,0
  for(i = 0; ; i++){
    474e:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4750:	00007917          	auipc	s2,0x7
    4754:	19890913          	addi	s2,s2,408 # b8e8 <buf>
  if(fd < 0){
    4758:	06054e63          	bltz	a0,47d4 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    475c:	12c00613          	li	a2,300
    4760:	85ca                	mv	a1,s2
    4762:	8552                	mv	a0,s4
    4764:	00001097          	auipc	ra,0x1
    4768:	d94080e7          	jalr	-620(ra) # 54f8 <read>
    if(cc < 0){
    476c:	08054263          	bltz	a0,47f0 <bigfile+0x13a>
    if(cc == 0)
    4770:	c971                	beqz	a0,4844 <bigfile+0x18e>
    if(cc != SZ/2){
    4772:	12c00793          	li	a5,300
    4776:	08f51b63          	bne	a0,a5,480c <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    477a:	01f4d79b          	srliw	a5,s1,0x1f
    477e:	9fa5                	addw	a5,a5,s1
    4780:	4017d79b          	sraiw	a5,a5,0x1
    4784:	00094703          	lbu	a4,0(s2)
    4788:	0af71063          	bne	a4,a5,4828 <bigfile+0x172>
    478c:	12b94703          	lbu	a4,299(s2)
    4790:	08f71c63          	bne	a4,a5,4828 <bigfile+0x172>
    total += cc;
    4794:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4798:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    479a:	b7c9                	j	475c <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    479c:	85d6                	mv	a1,s5
    479e:	00003517          	auipc	a0,0x3
    47a2:	1c250513          	addi	a0,a0,450 # 7960 <malloc+0x204a>
    47a6:	00001097          	auipc	ra,0x1
    47aa:	0b2080e7          	jalr	178(ra) # 5858 <printf>
    exit(1);
    47ae:	4505                	li	a0,1
    47b0:	00001097          	auipc	ra,0x1
    47b4:	d30080e7          	jalr	-720(ra) # 54e0 <exit>
      printf("%s: write bigfile failed\n", s);
    47b8:	85d6                	mv	a1,s5
    47ba:	00003517          	auipc	a0,0x3
    47be:	1c650513          	addi	a0,a0,454 # 7980 <malloc+0x206a>
    47c2:	00001097          	auipc	ra,0x1
    47c6:	096080e7          	jalr	150(ra) # 5858 <printf>
      exit(1);
    47ca:	4505                	li	a0,1
    47cc:	00001097          	auipc	ra,0x1
    47d0:	d14080e7          	jalr	-748(ra) # 54e0 <exit>
    printf("%s: cannot open bigfile\n", s);
    47d4:	85d6                	mv	a1,s5
    47d6:	00003517          	auipc	a0,0x3
    47da:	1ca50513          	addi	a0,a0,458 # 79a0 <malloc+0x208a>
    47de:	00001097          	auipc	ra,0x1
    47e2:	07a080e7          	jalr	122(ra) # 5858 <printf>
    exit(1);
    47e6:	4505                	li	a0,1
    47e8:	00001097          	auipc	ra,0x1
    47ec:	cf8080e7          	jalr	-776(ra) # 54e0 <exit>
      printf("%s: read bigfile failed\n", s);
    47f0:	85d6                	mv	a1,s5
    47f2:	00003517          	auipc	a0,0x3
    47f6:	1ce50513          	addi	a0,a0,462 # 79c0 <malloc+0x20aa>
    47fa:	00001097          	auipc	ra,0x1
    47fe:	05e080e7          	jalr	94(ra) # 5858 <printf>
      exit(1);
    4802:	4505                	li	a0,1
    4804:	00001097          	auipc	ra,0x1
    4808:	cdc080e7          	jalr	-804(ra) # 54e0 <exit>
      printf("%s: short read bigfile\n", s);
    480c:	85d6                	mv	a1,s5
    480e:	00003517          	auipc	a0,0x3
    4812:	1d250513          	addi	a0,a0,466 # 79e0 <malloc+0x20ca>
    4816:	00001097          	auipc	ra,0x1
    481a:	042080e7          	jalr	66(ra) # 5858 <printf>
      exit(1);
    481e:	4505                	li	a0,1
    4820:	00001097          	auipc	ra,0x1
    4824:	cc0080e7          	jalr	-832(ra) # 54e0 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4828:	85d6                	mv	a1,s5
    482a:	00003517          	auipc	a0,0x3
    482e:	1ce50513          	addi	a0,a0,462 # 79f8 <malloc+0x20e2>
    4832:	00001097          	auipc	ra,0x1
    4836:	026080e7          	jalr	38(ra) # 5858 <printf>
      exit(1);
    483a:	4505                	li	a0,1
    483c:	00001097          	auipc	ra,0x1
    4840:	ca4080e7          	jalr	-860(ra) # 54e0 <exit>
  close(fd);
    4844:	8552                	mv	a0,s4
    4846:	00001097          	auipc	ra,0x1
    484a:	cc2080e7          	jalr	-830(ra) # 5508 <close>
  if(total != N*SZ){
    484e:	678d                	lui	a5,0x3
    4850:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0xee>
    4854:	02f99363          	bne	s3,a5,487a <bigfile+0x1c4>
  unlink("bigfile.dat");
    4858:	00003517          	auipc	a0,0x3
    485c:	0f850513          	addi	a0,a0,248 # 7950 <malloc+0x203a>
    4860:	00001097          	auipc	ra,0x1
    4864:	cd0080e7          	jalr	-816(ra) # 5530 <unlink>
}
    4868:	70e2                	ld	ra,56(sp)
    486a:	7442                	ld	s0,48(sp)
    486c:	74a2                	ld	s1,40(sp)
    486e:	7902                	ld	s2,32(sp)
    4870:	69e2                	ld	s3,24(sp)
    4872:	6a42                	ld	s4,16(sp)
    4874:	6aa2                	ld	s5,8(sp)
    4876:	6121                	addi	sp,sp,64
    4878:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    487a:	85d6                	mv	a1,s5
    487c:	00003517          	auipc	a0,0x3
    4880:	19c50513          	addi	a0,a0,412 # 7a18 <malloc+0x2102>
    4884:	00001097          	auipc	ra,0x1
    4888:	fd4080e7          	jalr	-44(ra) # 5858 <printf>
    exit(1);
    488c:	4505                	li	a0,1
    488e:	00001097          	auipc	ra,0x1
    4892:	c52080e7          	jalr	-942(ra) # 54e0 <exit>

0000000000004896 <kernmem>:
{
    4896:	715d                	addi	sp,sp,-80
    4898:	e486                	sd	ra,72(sp)
    489a:	e0a2                	sd	s0,64(sp)
    489c:	fc26                	sd	s1,56(sp)
    489e:	f84a                	sd	s2,48(sp)
    48a0:	f44e                	sd	s3,40(sp)
    48a2:	f052                	sd	s4,32(sp)
    48a4:	ec56                	sd	s5,24(sp)
    48a6:	0880                	addi	s0,sp,80
    48a8:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    48aa:	4485                	li	s1,1
    48ac:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    48ae:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    48b0:	69b1                	lui	s3,0xc
    48b2:	35098993          	addi	s3,s3,848 # c350 <buf+0xa68>
    48b6:	1003d937          	lui	s2,0x1003d
    48ba:	090e                	slli	s2,s2,0x3
    48bc:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002eb88>
    pid = fork();
    48c0:	00001097          	auipc	ra,0x1
    48c4:	c18080e7          	jalr	-1000(ra) # 54d8 <fork>
    if(pid < 0){
    48c8:	02054963          	bltz	a0,48fa <kernmem+0x64>
    if(pid == 0){
    48cc:	c529                	beqz	a0,4916 <kernmem+0x80>
    wait(&xstatus);
    48ce:	fbc40513          	addi	a0,s0,-68
    48d2:	00001097          	auipc	ra,0x1
    48d6:	c16080e7          	jalr	-1002(ra) # 54e8 <wait>
    if(xstatus != -1)  // did kernel kill child?
    48da:	fbc42783          	lw	a5,-68(s0)
    48de:	05579d63          	bne	a5,s5,4938 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    48e2:	94ce                	add	s1,s1,s3
    48e4:	fd249ee3          	bne	s1,s2,48c0 <kernmem+0x2a>
}
    48e8:	60a6                	ld	ra,72(sp)
    48ea:	6406                	ld	s0,64(sp)
    48ec:	74e2                	ld	s1,56(sp)
    48ee:	7942                	ld	s2,48(sp)
    48f0:	79a2                	ld	s3,40(sp)
    48f2:	7a02                	ld	s4,32(sp)
    48f4:	6ae2                	ld	s5,24(sp)
    48f6:	6161                	addi	sp,sp,80
    48f8:	8082                	ret
      printf("%s: fork failed\n", s);
    48fa:	85d2                	mv	a1,s4
    48fc:	00002517          	auipc	a0,0x2
    4900:	c5c50513          	addi	a0,a0,-932 # 6558 <malloc+0xc42>
    4904:	00001097          	auipc	ra,0x1
    4908:	f54080e7          	jalr	-172(ra) # 5858 <printf>
      exit(1);
    490c:	4505                	li	a0,1
    490e:	00001097          	auipc	ra,0x1
    4912:	bd2080e7          	jalr	-1070(ra) # 54e0 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    4916:	0004c683          	lbu	a3,0(s1)
    491a:	8626                	mv	a2,s1
    491c:	85d2                	mv	a1,s4
    491e:	00003517          	auipc	a0,0x3
    4922:	11a50513          	addi	a0,a0,282 # 7a38 <malloc+0x2122>
    4926:	00001097          	auipc	ra,0x1
    492a:	f32080e7          	jalr	-206(ra) # 5858 <printf>
      exit(1);
    492e:	4505                	li	a0,1
    4930:	00001097          	auipc	ra,0x1
    4934:	bb0080e7          	jalr	-1104(ra) # 54e0 <exit>
      exit(1);
    4938:	4505                	li	a0,1
    493a:	00001097          	auipc	ra,0x1
    493e:	ba6080e7          	jalr	-1114(ra) # 54e0 <exit>

0000000000004942 <sbrkfail>:
{
    4942:	7119                	addi	sp,sp,-128
    4944:	fc86                	sd	ra,120(sp)
    4946:	f8a2                	sd	s0,112(sp)
    4948:	f4a6                	sd	s1,104(sp)
    494a:	f0ca                	sd	s2,96(sp)
    494c:	ecce                	sd	s3,88(sp)
    494e:	e8d2                	sd	s4,80(sp)
    4950:	e4d6                	sd	s5,72(sp)
    4952:	0100                	addi	s0,sp,128
    4954:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    4956:	fb040513          	addi	a0,s0,-80
    495a:	00001097          	auipc	ra,0x1
    495e:	b96080e7          	jalr	-1130(ra) # 54f0 <pipe>
    4962:	e901                	bnez	a0,4972 <sbrkfail+0x30>
    4964:	f8040493          	addi	s1,s0,-128
    4968:	fa840a13          	addi	s4,s0,-88
    496c:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    496e:	5afd                	li	s5,-1
    4970:	a08d                	j	49d2 <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    4972:	85ca                	mv	a1,s2
    4974:	00002517          	auipc	a0,0x2
    4978:	cec50513          	addi	a0,a0,-788 # 6660 <malloc+0xd4a>
    497c:	00001097          	auipc	ra,0x1
    4980:	edc080e7          	jalr	-292(ra) # 5858 <printf>
    exit(1);
    4984:	4505                	li	a0,1
    4986:	00001097          	auipc	ra,0x1
    498a:	b5a080e7          	jalr	-1190(ra) # 54e0 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    498e:	4501                	li	a0,0
    4990:	00001097          	auipc	ra,0x1
    4994:	bd8080e7          	jalr	-1064(ra) # 5568 <sbrk>
    4998:	064007b7          	lui	a5,0x6400
    499c:	40a7853b          	subw	a0,a5,a0
    49a0:	00001097          	auipc	ra,0x1
    49a4:	bc8080e7          	jalr	-1080(ra) # 5568 <sbrk>
      write(fds[1], "x", 1);
    49a8:	4605                	li	a2,1
    49aa:	00001597          	auipc	a1,0x1
    49ae:	3e658593          	addi	a1,a1,998 # 5d90 <malloc+0x47a>
    49b2:	fb442503          	lw	a0,-76(s0)
    49b6:	00001097          	auipc	ra,0x1
    49ba:	b4a080e7          	jalr	-1206(ra) # 5500 <write>
      for(;;) sleep(1000);
    49be:	3e800513          	li	a0,1000
    49c2:	00001097          	auipc	ra,0x1
    49c6:	bae080e7          	jalr	-1106(ra) # 5570 <sleep>
    49ca:	bfd5                	j	49be <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    49cc:	0991                	addi	s3,s3,4
    49ce:	03498563          	beq	s3,s4,49f8 <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    49d2:	00001097          	auipc	ra,0x1
    49d6:	b06080e7          	jalr	-1274(ra) # 54d8 <fork>
    49da:	00a9a023          	sw	a0,0(s3)
    49de:	d945                	beqz	a0,498e <sbrkfail+0x4c>
    if(pids[i] != -1)
    49e0:	ff5506e3          	beq	a0,s5,49cc <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    49e4:	4605                	li	a2,1
    49e6:	faf40593          	addi	a1,s0,-81
    49ea:	fb042503          	lw	a0,-80(s0)
    49ee:	00001097          	auipc	ra,0x1
    49f2:	b0a080e7          	jalr	-1270(ra) # 54f8 <read>
    49f6:	bfd9                	j	49cc <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    49f8:	6505                	lui	a0,0x1
    49fa:	00001097          	auipc	ra,0x1
    49fe:	b6e080e7          	jalr	-1170(ra) # 5568 <sbrk>
    4a02:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    4a04:	5afd                	li	s5,-1
    4a06:	a021                	j	4a0e <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4a08:	0491                	addi	s1,s1,4
    4a0a:	01448f63          	beq	s1,s4,4a28 <sbrkfail+0xe6>
    if(pids[i] == -1)
    4a0e:	4088                	lw	a0,0(s1)
    4a10:	ff550ce3          	beq	a0,s5,4a08 <sbrkfail+0xc6>
    kill(pids[i]);
    4a14:	00001097          	auipc	ra,0x1
    4a18:	afc080e7          	jalr	-1284(ra) # 5510 <kill>
    wait(0);
    4a1c:	4501                	li	a0,0
    4a1e:	00001097          	auipc	ra,0x1
    4a22:	aca080e7          	jalr	-1334(ra) # 54e8 <wait>
    4a26:	b7cd                	j	4a08 <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    4a28:	57fd                	li	a5,-1
    4a2a:	04f98163          	beq	s3,a5,4a6c <sbrkfail+0x12a>
  pid = fork();
    4a2e:	00001097          	auipc	ra,0x1
    4a32:	aaa080e7          	jalr	-1366(ra) # 54d8 <fork>
    4a36:	84aa                	mv	s1,a0
  if(pid < 0){
    4a38:	04054863          	bltz	a0,4a88 <sbrkfail+0x146>
  if(pid == 0){
    4a3c:	c525                	beqz	a0,4aa4 <sbrkfail+0x162>
  wait(&xstatus);
    4a3e:	fbc40513          	addi	a0,s0,-68
    4a42:	00001097          	auipc	ra,0x1
    4a46:	aa6080e7          	jalr	-1370(ra) # 54e8 <wait>
  if(xstatus != -1 && xstatus != 2)
    4a4a:	fbc42783          	lw	a5,-68(s0)
    4a4e:	577d                	li	a4,-1
    4a50:	00e78563          	beq	a5,a4,4a5a <sbrkfail+0x118>
    4a54:	4709                	li	a4,2
    4a56:	08e79d63          	bne	a5,a4,4af0 <sbrkfail+0x1ae>
}
    4a5a:	70e6                	ld	ra,120(sp)
    4a5c:	7446                	ld	s0,112(sp)
    4a5e:	74a6                	ld	s1,104(sp)
    4a60:	7906                	ld	s2,96(sp)
    4a62:	69e6                	ld	s3,88(sp)
    4a64:	6a46                	ld	s4,80(sp)
    4a66:	6aa6                	ld	s5,72(sp)
    4a68:	6109                	addi	sp,sp,128
    4a6a:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4a6c:	85ca                	mv	a1,s2
    4a6e:	00003517          	auipc	a0,0x3
    4a72:	fea50513          	addi	a0,a0,-22 # 7a58 <malloc+0x2142>
    4a76:	00001097          	auipc	ra,0x1
    4a7a:	de2080e7          	jalr	-542(ra) # 5858 <printf>
    exit(1);
    4a7e:	4505                	li	a0,1
    4a80:	00001097          	auipc	ra,0x1
    4a84:	a60080e7          	jalr	-1440(ra) # 54e0 <exit>
    printf("%s: fork failed\n", s);
    4a88:	85ca                	mv	a1,s2
    4a8a:	00002517          	auipc	a0,0x2
    4a8e:	ace50513          	addi	a0,a0,-1330 # 6558 <malloc+0xc42>
    4a92:	00001097          	auipc	ra,0x1
    4a96:	dc6080e7          	jalr	-570(ra) # 5858 <printf>
    exit(1);
    4a9a:	4505                	li	a0,1
    4a9c:	00001097          	auipc	ra,0x1
    4aa0:	a44080e7          	jalr	-1468(ra) # 54e0 <exit>
    a = sbrk(0);
    4aa4:	4501                	li	a0,0
    4aa6:	00001097          	auipc	ra,0x1
    4aaa:	ac2080e7          	jalr	-1342(ra) # 5568 <sbrk>
    4aae:	89aa                	mv	s3,a0
    sbrk(10*BIG);
    4ab0:	3e800537          	lui	a0,0x3e800
    4ab4:	00001097          	auipc	ra,0x1
    4ab8:	ab4080e7          	jalr	-1356(ra) # 5568 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4abc:	874e                	mv	a4,s3
    4abe:	3e8007b7          	lui	a5,0x3e800
    4ac2:	97ce                	add	a5,a5,s3
    4ac4:	6685                	lui	a3,0x1
      n += *(a+i);
    4ac6:	00074603          	lbu	a2,0(a4)
    4aca:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4acc:	9736                	add	a4,a4,a3
    4ace:	fef71ce3          	bne	a4,a5,4ac6 <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4ad2:	8626                	mv	a2,s1
    4ad4:	85ca                	mv	a1,s2
    4ad6:	00003517          	auipc	a0,0x3
    4ada:	fa250513          	addi	a0,a0,-94 # 7a78 <malloc+0x2162>
    4ade:	00001097          	auipc	ra,0x1
    4ae2:	d7a080e7          	jalr	-646(ra) # 5858 <printf>
    exit(1);
    4ae6:	4505                	li	a0,1
    4ae8:	00001097          	auipc	ra,0x1
    4aec:	9f8080e7          	jalr	-1544(ra) # 54e0 <exit>
    exit(1);
    4af0:	4505                	li	a0,1
    4af2:	00001097          	auipc	ra,0x1
    4af6:	9ee080e7          	jalr	-1554(ra) # 54e0 <exit>

0000000000004afa <fsfull>:
{
    4afa:	7171                	addi	sp,sp,-176
    4afc:	f506                	sd	ra,168(sp)
    4afe:	f122                	sd	s0,160(sp)
    4b00:	ed26                	sd	s1,152(sp)
    4b02:	e94a                	sd	s2,144(sp)
    4b04:	e54e                	sd	s3,136(sp)
    4b06:	e152                	sd	s4,128(sp)
    4b08:	fcd6                	sd	s5,120(sp)
    4b0a:	f8da                	sd	s6,112(sp)
    4b0c:	f4de                	sd	s7,104(sp)
    4b0e:	f0e2                	sd	s8,96(sp)
    4b10:	ece6                	sd	s9,88(sp)
    4b12:	e8ea                	sd	s10,80(sp)
    4b14:	e4ee                	sd	s11,72(sp)
    4b16:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4b18:	00003517          	auipc	a0,0x3
    4b1c:	f9050513          	addi	a0,a0,-112 # 7aa8 <malloc+0x2192>
    4b20:	00001097          	auipc	ra,0x1
    4b24:	d38080e7          	jalr	-712(ra) # 5858 <printf>
  for(nfiles = 0; ; nfiles++){
    4b28:	4481                	li	s1,0
    name[0] = 'f';
    4b2a:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4b2e:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4b32:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4b36:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4b38:	00003c97          	auipc	s9,0x3
    4b3c:	f80c8c93          	addi	s9,s9,-128 # 7ab8 <malloc+0x21a2>
    int total = 0;
    4b40:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4b42:	00007a17          	auipc	s4,0x7
    4b46:	da6a0a13          	addi	s4,s4,-602 # b8e8 <buf>
    name[0] = 'f';
    4b4a:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4b4e:	0384c7bb          	divw	a5,s1,s8
    4b52:	0307879b          	addiw	a5,a5,48
    4b56:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4b5a:	0384e7bb          	remw	a5,s1,s8
    4b5e:	0377c7bb          	divw	a5,a5,s7
    4b62:	0307879b          	addiw	a5,a5,48
    4b66:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4b6a:	0374e7bb          	remw	a5,s1,s7
    4b6e:	0367c7bb          	divw	a5,a5,s6
    4b72:	0307879b          	addiw	a5,a5,48
    4b76:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4b7a:	0364e7bb          	remw	a5,s1,s6
    4b7e:	0307879b          	addiw	a5,a5,48
    4b82:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4b86:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4b8a:	f5040593          	addi	a1,s0,-176
    4b8e:	8566                	mv	a0,s9
    4b90:	00001097          	auipc	ra,0x1
    4b94:	cc8080e7          	jalr	-824(ra) # 5858 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4b98:	20200593          	li	a1,514
    4b9c:	f5040513          	addi	a0,s0,-176
    4ba0:	00001097          	auipc	ra,0x1
    4ba4:	980080e7          	jalr	-1664(ra) # 5520 <open>
    4ba8:	892a                	mv	s2,a0
    if(fd < 0){
    4baa:	0a055663          	bgez	a0,4c56 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4bae:	f5040593          	addi	a1,s0,-176
    4bb2:	00003517          	auipc	a0,0x3
    4bb6:	f1650513          	addi	a0,a0,-234 # 7ac8 <malloc+0x21b2>
    4bba:	00001097          	auipc	ra,0x1
    4bbe:	c9e080e7          	jalr	-866(ra) # 5858 <printf>
  while(nfiles >= 0){
    4bc2:	0604c363          	bltz	s1,4c28 <fsfull+0x12e>
    name[0] = 'f';
    4bc6:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4bca:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4bce:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4bd2:	4929                	li	s2,10
  while(nfiles >= 0){
    4bd4:	5afd                	li	s5,-1
    name[0] = 'f';
    4bd6:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4bda:	0344c7bb          	divw	a5,s1,s4
    4bde:	0307879b          	addiw	a5,a5,48
    4be2:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4be6:	0344e7bb          	remw	a5,s1,s4
    4bea:	0337c7bb          	divw	a5,a5,s3
    4bee:	0307879b          	addiw	a5,a5,48
    4bf2:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4bf6:	0334e7bb          	remw	a5,s1,s3
    4bfa:	0327c7bb          	divw	a5,a5,s2
    4bfe:	0307879b          	addiw	a5,a5,48
    4c02:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c06:	0324e7bb          	remw	a5,s1,s2
    4c0a:	0307879b          	addiw	a5,a5,48
    4c0e:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c12:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4c16:	f5040513          	addi	a0,s0,-176
    4c1a:	00001097          	auipc	ra,0x1
    4c1e:	916080e7          	jalr	-1770(ra) # 5530 <unlink>
    nfiles--;
    4c22:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4c24:	fb5499e3          	bne	s1,s5,4bd6 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4c28:	00003517          	auipc	a0,0x3
    4c2c:	ec050513          	addi	a0,a0,-320 # 7ae8 <malloc+0x21d2>
    4c30:	00001097          	auipc	ra,0x1
    4c34:	c28080e7          	jalr	-984(ra) # 5858 <printf>
}
    4c38:	70aa                	ld	ra,168(sp)
    4c3a:	740a                	ld	s0,160(sp)
    4c3c:	64ea                	ld	s1,152(sp)
    4c3e:	694a                	ld	s2,144(sp)
    4c40:	69aa                	ld	s3,136(sp)
    4c42:	6a0a                	ld	s4,128(sp)
    4c44:	7ae6                	ld	s5,120(sp)
    4c46:	7b46                	ld	s6,112(sp)
    4c48:	7ba6                	ld	s7,104(sp)
    4c4a:	7c06                	ld	s8,96(sp)
    4c4c:	6ce6                	ld	s9,88(sp)
    4c4e:	6d46                	ld	s10,80(sp)
    4c50:	6da6                	ld	s11,72(sp)
    4c52:	614d                	addi	sp,sp,176
    4c54:	8082                	ret
    int total = 0;
    4c56:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4c58:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4c5c:	40000613          	li	a2,1024
    4c60:	85d2                	mv	a1,s4
    4c62:	854a                	mv	a0,s2
    4c64:	00001097          	auipc	ra,0x1
    4c68:	89c080e7          	jalr	-1892(ra) # 5500 <write>
      if(cc < BSIZE)
    4c6c:	00aad563          	bge	s5,a0,4c76 <fsfull+0x17c>
      total += cc;
    4c70:	00a989bb          	addw	s3,s3,a0
    while(1){
    4c74:	b7e5                	j	4c5c <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4c76:	85ce                	mv	a1,s3
    4c78:	00003517          	auipc	a0,0x3
    4c7c:	e6050513          	addi	a0,a0,-416 # 7ad8 <malloc+0x21c2>
    4c80:	00001097          	auipc	ra,0x1
    4c84:	bd8080e7          	jalr	-1064(ra) # 5858 <printf>
    close(fd);
    4c88:	854a                	mv	a0,s2
    4c8a:	00001097          	auipc	ra,0x1
    4c8e:	87e080e7          	jalr	-1922(ra) # 5508 <close>
    if(total == 0)
    4c92:	f20988e3          	beqz	s3,4bc2 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4c96:	2485                	addiw	s1,s1,1
    4c98:	bd4d                	j	4b4a <fsfull+0x50>

0000000000004c9a <rand>:
{
    4c9a:	1141                	addi	sp,sp,-16
    4c9c:	e422                	sd	s0,8(sp)
    4c9e:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4ca0:	00003717          	auipc	a4,0x3
    4ca4:	41870713          	addi	a4,a4,1048 # 80b8 <randstate>
    4ca8:	6308                	ld	a0,0(a4)
    4caa:	001967b7          	lui	a5,0x196
    4cae:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187d15>
    4cb2:	02f50533          	mul	a0,a0,a5
    4cb6:	3c6ef7b7          	lui	a5,0x3c6ef
    4cba:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e0a67>
    4cbe:	953e                	add	a0,a0,a5
    4cc0:	e308                	sd	a0,0(a4)
}
    4cc2:	2501                	sext.w	a0,a0
    4cc4:	6422                	ld	s0,8(sp)
    4cc6:	0141                	addi	sp,sp,16
    4cc8:	8082                	ret

0000000000004cca <stacktest>:
{
    4cca:	7179                	addi	sp,sp,-48
    4ccc:	f406                	sd	ra,40(sp)
    4cce:	f022                	sd	s0,32(sp)
    4cd0:	ec26                	sd	s1,24(sp)
    4cd2:	1800                	addi	s0,sp,48
    4cd4:	84aa                	mv	s1,a0
  pid = fork();
    4cd6:	00001097          	auipc	ra,0x1
    4cda:	802080e7          	jalr	-2046(ra) # 54d8 <fork>
  if(pid == 0) {
    4cde:	c115                	beqz	a0,4d02 <stacktest+0x38>
  } else if(pid < 0){
    4ce0:	04054463          	bltz	a0,4d28 <stacktest+0x5e>
  wait(&xstatus);
    4ce4:	fdc40513          	addi	a0,s0,-36
    4ce8:	00001097          	auipc	ra,0x1
    4cec:	800080e7          	jalr	-2048(ra) # 54e8 <wait>
  if(xstatus == -1)  // kernel killed child?
    4cf0:	fdc42503          	lw	a0,-36(s0)
    4cf4:	57fd                	li	a5,-1
    4cf6:	04f50763          	beq	a0,a5,4d44 <stacktest+0x7a>
    exit(xstatus);
    4cfa:	00000097          	auipc	ra,0x0
    4cfe:	7e6080e7          	jalr	2022(ra) # 54e0 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    4d02:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    4d04:	77fd                	lui	a5,0xfffff
    4d06:	97ba                	add	a5,a5,a4
    4d08:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0708>
    4d0c:	85a6                	mv	a1,s1
    4d0e:	00003517          	auipc	a0,0x3
    4d12:	df250513          	addi	a0,a0,-526 # 7b00 <malloc+0x21ea>
    4d16:	00001097          	auipc	ra,0x1
    4d1a:	b42080e7          	jalr	-1214(ra) # 5858 <printf>
    exit(1);
    4d1e:	4505                	li	a0,1
    4d20:	00000097          	auipc	ra,0x0
    4d24:	7c0080e7          	jalr	1984(ra) # 54e0 <exit>
    printf("%s: fork failed\n", s);
    4d28:	85a6                	mv	a1,s1
    4d2a:	00002517          	auipc	a0,0x2
    4d2e:	82e50513          	addi	a0,a0,-2002 # 6558 <malloc+0xc42>
    4d32:	00001097          	auipc	ra,0x1
    4d36:	b26080e7          	jalr	-1242(ra) # 5858 <printf>
    exit(1);
    4d3a:	4505                	li	a0,1
    4d3c:	00000097          	auipc	ra,0x0
    4d40:	7a4080e7          	jalr	1956(ra) # 54e0 <exit>
    exit(0);
    4d44:	4501                	li	a0,0
    4d46:	00000097          	auipc	ra,0x0
    4d4a:	79a080e7          	jalr	1946(ra) # 54e0 <exit>

0000000000004d4e <badwrite>:
{
    4d4e:	7179                	addi	sp,sp,-48
    4d50:	f406                	sd	ra,40(sp)
    4d52:	f022                	sd	s0,32(sp)
    4d54:	ec26                	sd	s1,24(sp)
    4d56:	e84a                	sd	s2,16(sp)
    4d58:	e44e                	sd	s3,8(sp)
    4d5a:	e052                	sd	s4,0(sp)
    4d5c:	1800                	addi	s0,sp,48
  unlink("junk");
    4d5e:	00003517          	auipc	a0,0x3
    4d62:	dca50513          	addi	a0,a0,-566 # 7b28 <malloc+0x2212>
    4d66:	00000097          	auipc	ra,0x0
    4d6a:	7ca080e7          	jalr	1994(ra) # 5530 <unlink>
    4d6e:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d72:	00003997          	auipc	s3,0x3
    4d76:	db698993          	addi	s3,s3,-586 # 7b28 <malloc+0x2212>
    write(fd, (char*)0xffffffffffL, 1);
    4d7a:	5a7d                	li	s4,-1
    4d7c:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d80:	20100593          	li	a1,513
    4d84:	854e                	mv	a0,s3
    4d86:	00000097          	auipc	ra,0x0
    4d8a:	79a080e7          	jalr	1946(ra) # 5520 <open>
    4d8e:	84aa                	mv	s1,a0
    if(fd < 0){
    4d90:	06054b63          	bltz	a0,4e06 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4d94:	4605                	li	a2,1
    4d96:	85d2                	mv	a1,s4
    4d98:	00000097          	auipc	ra,0x0
    4d9c:	768080e7          	jalr	1896(ra) # 5500 <write>
    close(fd);
    4da0:	8526                	mv	a0,s1
    4da2:	00000097          	auipc	ra,0x0
    4da6:	766080e7          	jalr	1894(ra) # 5508 <close>
    unlink("junk");
    4daa:	854e                	mv	a0,s3
    4dac:	00000097          	auipc	ra,0x0
    4db0:	784080e7          	jalr	1924(ra) # 5530 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4db4:	397d                	addiw	s2,s2,-1
    4db6:	fc0915e3          	bnez	s2,4d80 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4dba:	20100593          	li	a1,513
    4dbe:	00003517          	auipc	a0,0x3
    4dc2:	d6a50513          	addi	a0,a0,-662 # 7b28 <malloc+0x2212>
    4dc6:	00000097          	auipc	ra,0x0
    4dca:	75a080e7          	jalr	1882(ra) # 5520 <open>
    4dce:	84aa                	mv	s1,a0
  if(fd < 0){
    4dd0:	04054863          	bltz	a0,4e20 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4dd4:	4605                	li	a2,1
    4dd6:	00001597          	auipc	a1,0x1
    4dda:	fba58593          	addi	a1,a1,-70 # 5d90 <malloc+0x47a>
    4dde:	00000097          	auipc	ra,0x0
    4de2:	722080e7          	jalr	1826(ra) # 5500 <write>
    4de6:	4785                	li	a5,1
    4de8:	04f50963          	beq	a0,a5,4e3a <badwrite+0xec>
    printf("write failed\n");
    4dec:	00003517          	auipc	a0,0x3
    4df0:	d5c50513          	addi	a0,a0,-676 # 7b48 <malloc+0x2232>
    4df4:	00001097          	auipc	ra,0x1
    4df8:	a64080e7          	jalr	-1436(ra) # 5858 <printf>
    exit(1);
    4dfc:	4505                	li	a0,1
    4dfe:	00000097          	auipc	ra,0x0
    4e02:	6e2080e7          	jalr	1762(ra) # 54e0 <exit>
      printf("open junk failed\n");
    4e06:	00003517          	auipc	a0,0x3
    4e0a:	d2a50513          	addi	a0,a0,-726 # 7b30 <malloc+0x221a>
    4e0e:	00001097          	auipc	ra,0x1
    4e12:	a4a080e7          	jalr	-1462(ra) # 5858 <printf>
      exit(1);
    4e16:	4505                	li	a0,1
    4e18:	00000097          	auipc	ra,0x0
    4e1c:	6c8080e7          	jalr	1736(ra) # 54e0 <exit>
    printf("open junk failed\n");
    4e20:	00003517          	auipc	a0,0x3
    4e24:	d1050513          	addi	a0,a0,-752 # 7b30 <malloc+0x221a>
    4e28:	00001097          	auipc	ra,0x1
    4e2c:	a30080e7          	jalr	-1488(ra) # 5858 <printf>
    exit(1);
    4e30:	4505                	li	a0,1
    4e32:	00000097          	auipc	ra,0x0
    4e36:	6ae080e7          	jalr	1710(ra) # 54e0 <exit>
  close(fd);
    4e3a:	8526                	mv	a0,s1
    4e3c:	00000097          	auipc	ra,0x0
    4e40:	6cc080e7          	jalr	1740(ra) # 5508 <close>
  unlink("junk");
    4e44:	00003517          	auipc	a0,0x3
    4e48:	ce450513          	addi	a0,a0,-796 # 7b28 <malloc+0x2212>
    4e4c:	00000097          	auipc	ra,0x0
    4e50:	6e4080e7          	jalr	1764(ra) # 5530 <unlink>
  exit(0);
    4e54:	4501                	li	a0,0
    4e56:	00000097          	auipc	ra,0x0
    4e5a:	68a080e7          	jalr	1674(ra) # 54e0 <exit>

0000000000004e5e <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4e5e:	7139                	addi	sp,sp,-64
    4e60:	fc06                	sd	ra,56(sp)
    4e62:	f822                	sd	s0,48(sp)
    4e64:	f426                	sd	s1,40(sp)
    4e66:	f04a                	sd	s2,32(sp)
    4e68:	ec4e                	sd	s3,24(sp)
    4e6a:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4e6c:	fc840513          	addi	a0,s0,-56
    4e70:	00000097          	auipc	ra,0x0
    4e74:	680080e7          	jalr	1664(ra) # 54f0 <pipe>
    4e78:	06054863          	bltz	a0,4ee8 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4e7c:	00000097          	auipc	ra,0x0
    4e80:	65c080e7          	jalr	1628(ra) # 54d8 <fork>

  if(pid < 0){
    4e84:	06054f63          	bltz	a0,4f02 <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4e88:	ed59                	bnez	a0,4f26 <countfree+0xc8>
    close(fds[0]);
    4e8a:	fc842503          	lw	a0,-56(s0)
    4e8e:	00000097          	auipc	ra,0x0
    4e92:	67a080e7          	jalr	1658(ra) # 5508 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4e96:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4e98:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4e9a:	00001917          	auipc	s2,0x1
    4e9e:	ef690913          	addi	s2,s2,-266 # 5d90 <malloc+0x47a>
      uint64 a = (uint64) sbrk(4096);
    4ea2:	6505                	lui	a0,0x1
    4ea4:	00000097          	auipc	ra,0x0
    4ea8:	6c4080e7          	jalr	1732(ra) # 5568 <sbrk>
      if(a == 0xffffffffffffffff){
    4eac:	06950863          	beq	a0,s1,4f1c <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    4eb0:	6785                	lui	a5,0x1
    4eb2:	953e                	add	a0,a0,a5
    4eb4:	ff350fa3          	sb	s3,-1(a0) # fff <bigdir+0x89>
      if(write(fds[1], "x", 1) != 1){
    4eb8:	4605                	li	a2,1
    4eba:	85ca                	mv	a1,s2
    4ebc:	fcc42503          	lw	a0,-52(s0)
    4ec0:	00000097          	auipc	ra,0x0
    4ec4:	640080e7          	jalr	1600(ra) # 5500 <write>
    4ec8:	4785                	li	a5,1
    4eca:	fcf50ce3          	beq	a0,a5,4ea2 <countfree+0x44>
        printf("write() failed in countfree()\n");
    4ece:	00003517          	auipc	a0,0x3
    4ed2:	cca50513          	addi	a0,a0,-822 # 7b98 <malloc+0x2282>
    4ed6:	00001097          	auipc	ra,0x1
    4eda:	982080e7          	jalr	-1662(ra) # 5858 <printf>
        exit(1);
    4ede:	4505                	li	a0,1
    4ee0:	00000097          	auipc	ra,0x0
    4ee4:	600080e7          	jalr	1536(ra) # 54e0 <exit>
    printf("pipe() failed in countfree()\n");
    4ee8:	00003517          	auipc	a0,0x3
    4eec:	c7050513          	addi	a0,a0,-912 # 7b58 <malloc+0x2242>
    4ef0:	00001097          	auipc	ra,0x1
    4ef4:	968080e7          	jalr	-1688(ra) # 5858 <printf>
    exit(1);
    4ef8:	4505                	li	a0,1
    4efa:	00000097          	auipc	ra,0x0
    4efe:	5e6080e7          	jalr	1510(ra) # 54e0 <exit>
    printf("fork failed in countfree()\n");
    4f02:	00003517          	auipc	a0,0x3
    4f06:	c7650513          	addi	a0,a0,-906 # 7b78 <malloc+0x2262>
    4f0a:	00001097          	auipc	ra,0x1
    4f0e:	94e080e7          	jalr	-1714(ra) # 5858 <printf>
    exit(1);
    4f12:	4505                	li	a0,1
    4f14:	00000097          	auipc	ra,0x0
    4f18:	5cc080e7          	jalr	1484(ra) # 54e0 <exit>
      }
    }

    exit(0);
    4f1c:	4501                	li	a0,0
    4f1e:	00000097          	auipc	ra,0x0
    4f22:	5c2080e7          	jalr	1474(ra) # 54e0 <exit>
  }

  close(fds[1]);
    4f26:	fcc42503          	lw	a0,-52(s0)
    4f2a:	00000097          	auipc	ra,0x0
    4f2e:	5de080e7          	jalr	1502(ra) # 5508 <close>

  int n = 0;
    4f32:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    4f34:	4605                	li	a2,1
    4f36:	fc740593          	addi	a1,s0,-57
    4f3a:	fc842503          	lw	a0,-56(s0)
    4f3e:	00000097          	auipc	ra,0x0
    4f42:	5ba080e7          	jalr	1466(ra) # 54f8 <read>
    if(cc < 0){
    4f46:	00054563          	bltz	a0,4f50 <countfree+0xf2>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    4f4a:	c105                	beqz	a0,4f6a <countfree+0x10c>
      break;
    n += 1;
    4f4c:	2485                	addiw	s1,s1,1
  while(1){
    4f4e:	b7dd                	j	4f34 <countfree+0xd6>
      printf("read() failed in countfree()\n");
    4f50:	00003517          	auipc	a0,0x3
    4f54:	c6850513          	addi	a0,a0,-920 # 7bb8 <malloc+0x22a2>
    4f58:	00001097          	auipc	ra,0x1
    4f5c:	900080e7          	jalr	-1792(ra) # 5858 <printf>
      exit(1);
    4f60:	4505                	li	a0,1
    4f62:	00000097          	auipc	ra,0x0
    4f66:	57e080e7          	jalr	1406(ra) # 54e0 <exit>
  }

  close(fds[0]);
    4f6a:	fc842503          	lw	a0,-56(s0)
    4f6e:	00000097          	auipc	ra,0x0
    4f72:	59a080e7          	jalr	1434(ra) # 5508 <close>
  wait((int*)0);
    4f76:	4501                	li	a0,0
    4f78:	00000097          	auipc	ra,0x0
    4f7c:	570080e7          	jalr	1392(ra) # 54e8 <wait>
  
  return n;
}
    4f80:	8526                	mv	a0,s1
    4f82:	70e2                	ld	ra,56(sp)
    4f84:	7442                	ld	s0,48(sp)
    4f86:	74a2                	ld	s1,40(sp)
    4f88:	7902                	ld	s2,32(sp)
    4f8a:	69e2                	ld	s3,24(sp)
    4f8c:	6121                	addi	sp,sp,64
    4f8e:	8082                	ret

0000000000004f90 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4f90:	7179                	addi	sp,sp,-48
    4f92:	f406                	sd	ra,40(sp)
    4f94:	f022                	sd	s0,32(sp)
    4f96:	ec26                	sd	s1,24(sp)
    4f98:	e84a                	sd	s2,16(sp)
    4f9a:	1800                	addi	s0,sp,48
    4f9c:	84aa                	mv	s1,a0
    4f9e:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4fa0:	00003517          	auipc	a0,0x3
    4fa4:	c3850513          	addi	a0,a0,-968 # 7bd8 <malloc+0x22c2>
    4fa8:	00001097          	auipc	ra,0x1
    4fac:	8b0080e7          	jalr	-1872(ra) # 5858 <printf>
  if((pid = fork()) < 0) {
    4fb0:	00000097          	auipc	ra,0x0
    4fb4:	528080e7          	jalr	1320(ra) # 54d8 <fork>
    4fb8:	02054e63          	bltz	a0,4ff4 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4fbc:	c929                	beqz	a0,500e <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4fbe:	fdc40513          	addi	a0,s0,-36
    4fc2:	00000097          	auipc	ra,0x0
    4fc6:	526080e7          	jalr	1318(ra) # 54e8 <wait>
    if(xstatus != 0) 
    4fca:	fdc42783          	lw	a5,-36(s0)
    4fce:	c7b9                	beqz	a5,501c <run+0x8c>
      printf("FAILED\n");
    4fd0:	00003517          	auipc	a0,0x3
    4fd4:	c3050513          	addi	a0,a0,-976 # 7c00 <malloc+0x22ea>
    4fd8:	00001097          	auipc	ra,0x1
    4fdc:	880080e7          	jalr	-1920(ra) # 5858 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    4fe0:	fdc42503          	lw	a0,-36(s0)
  }
}
    4fe4:	00153513          	seqz	a0,a0
    4fe8:	70a2                	ld	ra,40(sp)
    4fea:	7402                	ld	s0,32(sp)
    4fec:	64e2                	ld	s1,24(sp)
    4fee:	6942                	ld	s2,16(sp)
    4ff0:	6145                	addi	sp,sp,48
    4ff2:	8082                	ret
    printf("runtest: fork error\n");
    4ff4:	00003517          	auipc	a0,0x3
    4ff8:	bf450513          	addi	a0,a0,-1036 # 7be8 <malloc+0x22d2>
    4ffc:	00001097          	auipc	ra,0x1
    5000:	85c080e7          	jalr	-1956(ra) # 5858 <printf>
    exit(1);
    5004:	4505                	li	a0,1
    5006:	00000097          	auipc	ra,0x0
    500a:	4da080e7          	jalr	1242(ra) # 54e0 <exit>
    f(s);
    500e:	854a                	mv	a0,s2
    5010:	9482                	jalr	s1
    exit(0);
    5012:	4501                	li	a0,0
    5014:	00000097          	auipc	ra,0x0
    5018:	4cc080e7          	jalr	1228(ra) # 54e0 <exit>
      printf("OK\n");
    501c:	00003517          	auipc	a0,0x3
    5020:	bec50513          	addi	a0,a0,-1044 # 7c08 <malloc+0x22f2>
    5024:	00001097          	auipc	ra,0x1
    5028:	834080e7          	jalr	-1996(ra) # 5858 <printf>
    502c:	bf55                	j	4fe0 <run+0x50>

000000000000502e <main>:

int
main(int argc, char *argv[])
{
    502e:	c5010113          	addi	sp,sp,-944
    5032:	3a113423          	sd	ra,936(sp)
    5036:	3a813023          	sd	s0,928(sp)
    503a:	38913c23          	sd	s1,920(sp)
    503e:	39213823          	sd	s2,912(sp)
    5042:	39313423          	sd	s3,904(sp)
    5046:	39413023          	sd	s4,896(sp)
    504a:	37513c23          	sd	s5,888(sp)
    504e:	37613823          	sd	s6,880(sp)
    5052:	1f00                	addi	s0,sp,944
    5054:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5056:	4789                	li	a5,2
    5058:	08f50b63          	beq	a0,a5,50ee <main+0xc0>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    505c:	4785                	li	a5,1
  char *justone = 0;
    505e:	4901                	li	s2,0
  } else if(argc > 1){
    5060:	0ca7c563          	blt	a5,a0,512a <main+0xfc>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    5064:	00003797          	auipc	a5,0x3
    5068:	cbc78793          	addi	a5,a5,-836 # 7d20 <malloc+0x240a>
    506c:	c5040713          	addi	a4,s0,-944
    5070:	00003897          	auipc	a7,0x3
    5074:	02088893          	addi	a7,a7,32 # 8090 <malloc+0x277a>
    5078:	0007b803          	ld	a6,0(a5)
    507c:	6788                	ld	a0,8(a5)
    507e:	6b8c                	ld	a1,16(a5)
    5080:	6f90                	ld	a2,24(a5)
    5082:	7394                	ld	a3,32(a5)
    5084:	01073023          	sd	a6,0(a4)
    5088:	e708                	sd	a0,8(a4)
    508a:	eb0c                	sd	a1,16(a4)
    508c:	ef10                	sd	a2,24(a4)
    508e:	f314                	sd	a3,32(a4)
    5090:	02878793          	addi	a5,a5,40
    5094:	02870713          	addi	a4,a4,40
    5098:	ff1790e3          	bne	a5,a7,5078 <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    509c:	00003517          	auipc	a0,0x3
    50a0:	c2450513          	addi	a0,a0,-988 # 7cc0 <malloc+0x23aa>
    50a4:	00000097          	auipc	ra,0x0
    50a8:	7b4080e7          	jalr	1972(ra) # 5858 <printf>
  int free0 = countfree();
    50ac:	00000097          	auipc	ra,0x0
    50b0:	db2080e7          	jalr	-590(ra) # 4e5e <countfree>
    50b4:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    50b6:	c5843503          	ld	a0,-936(s0)
    50ba:	c5040493          	addi	s1,s0,-944
  int fail = 0;
    50be:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    50c0:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    50c2:	e55d                	bnez	a0,5170 <main+0x142>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    50c4:	00000097          	auipc	ra,0x0
    50c8:	d9a080e7          	jalr	-614(ra) # 4e5e <countfree>
    50cc:	85aa                	mv	a1,a0
    50ce:	0f455163          	bge	a0,s4,51b0 <main+0x182>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    50d2:	8652                	mv	a2,s4
    50d4:	00003517          	auipc	a0,0x3
    50d8:	ba450513          	addi	a0,a0,-1116 # 7c78 <malloc+0x2362>
    50dc:	00000097          	auipc	ra,0x0
    50e0:	77c080e7          	jalr	1916(ra) # 5858 <printf>
    exit(1);
    50e4:	4505                	li	a0,1
    50e6:	00000097          	auipc	ra,0x0
    50ea:	3fa080e7          	jalr	1018(ra) # 54e0 <exit>
    50ee:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    50f0:	00003597          	auipc	a1,0x3
    50f4:	b2058593          	addi	a1,a1,-1248 # 7c10 <malloc+0x22fa>
    50f8:	6488                	ld	a0,8(s1)
    50fa:	00000097          	auipc	ra,0x0
    50fe:	18c080e7          	jalr	396(ra) # 5286 <strcmp>
    5102:	10050563          	beqz	a0,520c <main+0x1de>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5106:	00003597          	auipc	a1,0x3
    510a:	bf258593          	addi	a1,a1,-1038 # 7cf8 <malloc+0x23e2>
    510e:	6488                	ld	a0,8(s1)
    5110:	00000097          	auipc	ra,0x0
    5114:	176080e7          	jalr	374(ra) # 5286 <strcmp>
    5118:	c97d                	beqz	a0,520e <main+0x1e0>
  } else if(argc == 2 && argv[1][0] != '-'){
    511a:	0084b903          	ld	s2,8(s1)
    511e:	00094703          	lbu	a4,0(s2)
    5122:	02d00793          	li	a5,45
    5126:	f2f71fe3          	bne	a4,a5,5064 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    512a:	00003517          	auipc	a0,0x3
    512e:	aee50513          	addi	a0,a0,-1298 # 7c18 <malloc+0x2302>
    5132:	00000097          	auipc	ra,0x0
    5136:	726080e7          	jalr	1830(ra) # 5858 <printf>
    exit(1);
    513a:	4505                	li	a0,1
    513c:	00000097          	auipc	ra,0x0
    5140:	3a4080e7          	jalr	932(ra) # 54e0 <exit>
          exit(1);
    5144:	4505                	li	a0,1
    5146:	00000097          	auipc	ra,0x0
    514a:	39a080e7          	jalr	922(ra) # 54e0 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    514e:	40a905bb          	subw	a1,s2,a0
    5152:	855a                	mv	a0,s6
    5154:	00000097          	auipc	ra,0x0
    5158:	704080e7          	jalr	1796(ra) # 5858 <printf>
        if(continuous != 2)
    515c:	09498463          	beq	s3,s4,51e4 <main+0x1b6>
          exit(1);
    5160:	4505                	li	a0,1
    5162:	00000097          	auipc	ra,0x0
    5166:	37e080e7          	jalr	894(ra) # 54e0 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    516a:	04c1                	addi	s1,s1,16
    516c:	6488                	ld	a0,8(s1)
    516e:	c115                	beqz	a0,5192 <main+0x164>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5170:	00090863          	beqz	s2,5180 <main+0x152>
    5174:	85ca                	mv	a1,s2
    5176:	00000097          	auipc	ra,0x0
    517a:	110080e7          	jalr	272(ra) # 5286 <strcmp>
    517e:	f575                	bnez	a0,516a <main+0x13c>
      if(!run(t->f, t->s))
    5180:	648c                	ld	a1,8(s1)
    5182:	6088                	ld	a0,0(s1)
    5184:	00000097          	auipc	ra,0x0
    5188:	e0c080e7          	jalr	-500(ra) # 4f90 <run>
    518c:	fd79                	bnez	a0,516a <main+0x13c>
        fail = 1;
    518e:	89d6                	mv	s3,s5
    5190:	bfe9                	j	516a <main+0x13c>
  if(fail){
    5192:	f20989e3          	beqz	s3,50c4 <main+0x96>
    printf("SOME TESTS FAILED\n");
    5196:	00003517          	auipc	a0,0x3
    519a:	aca50513          	addi	a0,a0,-1334 # 7c60 <malloc+0x234a>
    519e:	00000097          	auipc	ra,0x0
    51a2:	6ba080e7          	jalr	1722(ra) # 5858 <printf>
    exit(1);
    51a6:	4505                	li	a0,1
    51a8:	00000097          	auipc	ra,0x0
    51ac:	338080e7          	jalr	824(ra) # 54e0 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    51b0:	00003517          	auipc	a0,0x3
    51b4:	af850513          	addi	a0,a0,-1288 # 7ca8 <malloc+0x2392>
    51b8:	00000097          	auipc	ra,0x0
    51bc:	6a0080e7          	jalr	1696(ra) # 5858 <printf>
    exit(0);
    51c0:	4501                	li	a0,0
    51c2:	00000097          	auipc	ra,0x0
    51c6:	31e080e7          	jalr	798(ra) # 54e0 <exit>
        printf("SOME TESTS FAILED\n");
    51ca:	8556                	mv	a0,s5
    51cc:	00000097          	auipc	ra,0x0
    51d0:	68c080e7          	jalr	1676(ra) # 5858 <printf>
        if(continuous != 2)
    51d4:	f74998e3          	bne	s3,s4,5144 <main+0x116>
      int free1 = countfree();
    51d8:	00000097          	auipc	ra,0x0
    51dc:	c86080e7          	jalr	-890(ra) # 4e5e <countfree>
      if(free1 < free0){
    51e0:	f72547e3          	blt	a0,s2,514e <main+0x120>
      int free0 = countfree();
    51e4:	00000097          	auipc	ra,0x0
    51e8:	c7a080e7          	jalr	-902(ra) # 4e5e <countfree>
    51ec:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    51ee:	c5843583          	ld	a1,-936(s0)
    51f2:	d1fd                	beqz	a1,51d8 <main+0x1aa>
    51f4:	c5040493          	addi	s1,s0,-944
        if(!run(t->f, t->s)){
    51f8:	6088                	ld	a0,0(s1)
    51fa:	00000097          	auipc	ra,0x0
    51fe:	d96080e7          	jalr	-618(ra) # 4f90 <run>
    5202:	d561                	beqz	a0,51ca <main+0x19c>
      for (struct test *t = tests; t->s != 0; t++) {
    5204:	04c1                	addi	s1,s1,16
    5206:	648c                	ld	a1,8(s1)
    5208:	f9e5                	bnez	a1,51f8 <main+0x1ca>
    520a:	b7f9                	j	51d8 <main+0x1aa>
    continuous = 1;
    520c:	4985                	li	s3,1
  } tests[] = {
    520e:	00003797          	auipc	a5,0x3
    5212:	b1278793          	addi	a5,a5,-1262 # 7d20 <malloc+0x240a>
    5216:	c5040713          	addi	a4,s0,-944
    521a:	00003897          	auipc	a7,0x3
    521e:	e7688893          	addi	a7,a7,-394 # 8090 <malloc+0x277a>
    5222:	0007b803          	ld	a6,0(a5)
    5226:	6788                	ld	a0,8(a5)
    5228:	6b8c                	ld	a1,16(a5)
    522a:	6f90                	ld	a2,24(a5)
    522c:	7394                	ld	a3,32(a5)
    522e:	01073023          	sd	a6,0(a4)
    5232:	e708                	sd	a0,8(a4)
    5234:	eb0c                	sd	a1,16(a4)
    5236:	ef10                	sd	a2,24(a4)
    5238:	f314                	sd	a3,32(a4)
    523a:	02878793          	addi	a5,a5,40
    523e:	02870713          	addi	a4,a4,40
    5242:	ff1790e3          	bne	a5,a7,5222 <main+0x1f4>
    printf("continuous usertests starting\n");
    5246:	00003517          	auipc	a0,0x3
    524a:	a9250513          	addi	a0,a0,-1390 # 7cd8 <malloc+0x23c2>
    524e:	00000097          	auipc	ra,0x0
    5252:	60a080e7          	jalr	1546(ra) # 5858 <printf>
        printf("SOME TESTS FAILED\n");
    5256:	00003a97          	auipc	s5,0x3
    525a:	a0aa8a93          	addi	s5,s5,-1526 # 7c60 <malloc+0x234a>
        if(continuous != 2)
    525e:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5260:	00003b17          	auipc	s6,0x3
    5264:	9e0b0b13          	addi	s6,s6,-1568 # 7c40 <malloc+0x232a>
    5268:	bfb5                	j	51e4 <main+0x1b6>

000000000000526a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    526a:	1141                	addi	sp,sp,-16
    526c:	e422                	sd	s0,8(sp)
    526e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5270:	87aa                	mv	a5,a0
    5272:	0585                	addi	a1,a1,1
    5274:	0785                	addi	a5,a5,1
    5276:	fff5c703          	lbu	a4,-1(a1)
    527a:	fee78fa3          	sb	a4,-1(a5)
    527e:	fb75                	bnez	a4,5272 <strcpy+0x8>
    ;
  return os;
}
    5280:	6422                	ld	s0,8(sp)
    5282:	0141                	addi	sp,sp,16
    5284:	8082                	ret

0000000000005286 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5286:	1141                	addi	sp,sp,-16
    5288:	e422                	sd	s0,8(sp)
    528a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    528c:	00054783          	lbu	a5,0(a0)
    5290:	cb91                	beqz	a5,52a4 <strcmp+0x1e>
    5292:	0005c703          	lbu	a4,0(a1)
    5296:	00f71763          	bne	a4,a5,52a4 <strcmp+0x1e>
    p++, q++;
    529a:	0505                	addi	a0,a0,1
    529c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    529e:	00054783          	lbu	a5,0(a0)
    52a2:	fbe5                	bnez	a5,5292 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    52a4:	0005c503          	lbu	a0,0(a1)
}
    52a8:	40a7853b          	subw	a0,a5,a0
    52ac:	6422                	ld	s0,8(sp)
    52ae:	0141                	addi	sp,sp,16
    52b0:	8082                	ret

00000000000052b2 <strlen>:

uint
strlen(const char *s)
{
    52b2:	1141                	addi	sp,sp,-16
    52b4:	e422                	sd	s0,8(sp)
    52b6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    52b8:	00054783          	lbu	a5,0(a0)
    52bc:	cf91                	beqz	a5,52d8 <strlen+0x26>
    52be:	0505                	addi	a0,a0,1
    52c0:	87aa                	mv	a5,a0
    52c2:	4685                	li	a3,1
    52c4:	9e89                	subw	a3,a3,a0
    52c6:	00f6853b          	addw	a0,a3,a5
    52ca:	0785                	addi	a5,a5,1
    52cc:	fff7c703          	lbu	a4,-1(a5)
    52d0:	fb7d                	bnez	a4,52c6 <strlen+0x14>
    ;
  return n;
}
    52d2:	6422                	ld	s0,8(sp)
    52d4:	0141                	addi	sp,sp,16
    52d6:	8082                	ret
  for(n = 0; s[n]; n++)
    52d8:	4501                	li	a0,0
    52da:	bfe5                	j	52d2 <strlen+0x20>

00000000000052dc <memset>:

void*
memset(void *dst, int c, uint n)
{
    52dc:	1141                	addi	sp,sp,-16
    52de:	e422                	sd	s0,8(sp)
    52e0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    52e2:	ce09                	beqz	a2,52fc <memset+0x20>
    52e4:	87aa                	mv	a5,a0
    52e6:	fff6071b          	addiw	a4,a2,-1
    52ea:	1702                	slli	a4,a4,0x20
    52ec:	9301                	srli	a4,a4,0x20
    52ee:	0705                	addi	a4,a4,1
    52f0:	972a                	add	a4,a4,a0
    cdst[i] = c;
    52f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    52f6:	0785                	addi	a5,a5,1
    52f8:	fee79de3          	bne	a5,a4,52f2 <memset+0x16>
  }
  return dst;
}
    52fc:	6422                	ld	s0,8(sp)
    52fe:	0141                	addi	sp,sp,16
    5300:	8082                	ret

0000000000005302 <strchr>:

char*
strchr(const char *s, char c)
{
    5302:	1141                	addi	sp,sp,-16
    5304:	e422                	sd	s0,8(sp)
    5306:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5308:	00054783          	lbu	a5,0(a0)
    530c:	cb99                	beqz	a5,5322 <strchr+0x20>
    if(*s == c)
    530e:	00f58763          	beq	a1,a5,531c <strchr+0x1a>
  for(; *s; s++)
    5312:	0505                	addi	a0,a0,1
    5314:	00054783          	lbu	a5,0(a0)
    5318:	fbfd                	bnez	a5,530e <strchr+0xc>
      return (char*)s;
  return 0;
    531a:	4501                	li	a0,0
}
    531c:	6422                	ld	s0,8(sp)
    531e:	0141                	addi	sp,sp,16
    5320:	8082                	ret
  return 0;
    5322:	4501                	li	a0,0
    5324:	bfe5                	j	531c <strchr+0x1a>

0000000000005326 <gets>:

char*
gets(char *buf, int max)
{
    5326:	711d                	addi	sp,sp,-96
    5328:	ec86                	sd	ra,88(sp)
    532a:	e8a2                	sd	s0,80(sp)
    532c:	e4a6                	sd	s1,72(sp)
    532e:	e0ca                	sd	s2,64(sp)
    5330:	fc4e                	sd	s3,56(sp)
    5332:	f852                	sd	s4,48(sp)
    5334:	f456                	sd	s5,40(sp)
    5336:	f05a                	sd	s6,32(sp)
    5338:	ec5e                	sd	s7,24(sp)
    533a:	1080                	addi	s0,sp,96
    533c:	8baa                	mv	s7,a0
    533e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5340:	892a                	mv	s2,a0
    5342:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5344:	4aa9                	li	s5,10
    5346:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5348:	89a6                	mv	s3,s1
    534a:	2485                	addiw	s1,s1,1
    534c:	0344d863          	bge	s1,s4,537c <gets+0x56>
    cc = read(0, &c, 1);
    5350:	4605                	li	a2,1
    5352:	faf40593          	addi	a1,s0,-81
    5356:	4501                	li	a0,0
    5358:	00000097          	auipc	ra,0x0
    535c:	1a0080e7          	jalr	416(ra) # 54f8 <read>
    if(cc < 1)
    5360:	00a05e63          	blez	a0,537c <gets+0x56>
    buf[i++] = c;
    5364:	faf44783          	lbu	a5,-81(s0)
    5368:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    536c:	01578763          	beq	a5,s5,537a <gets+0x54>
    5370:	0905                	addi	s2,s2,1
    5372:	fd679be3          	bne	a5,s6,5348 <gets+0x22>
  for(i=0; i+1 < max; ){
    5376:	89a6                	mv	s3,s1
    5378:	a011                	j	537c <gets+0x56>
    537a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    537c:	99de                	add	s3,s3,s7
    537e:	00098023          	sb	zero,0(s3)
  return buf;
}
    5382:	855e                	mv	a0,s7
    5384:	60e6                	ld	ra,88(sp)
    5386:	6446                	ld	s0,80(sp)
    5388:	64a6                	ld	s1,72(sp)
    538a:	6906                	ld	s2,64(sp)
    538c:	79e2                	ld	s3,56(sp)
    538e:	7a42                	ld	s4,48(sp)
    5390:	7aa2                	ld	s5,40(sp)
    5392:	7b02                	ld	s6,32(sp)
    5394:	6be2                	ld	s7,24(sp)
    5396:	6125                	addi	sp,sp,96
    5398:	8082                	ret

000000000000539a <stat>:

int
stat(const char *n, struct stat *st)
{
    539a:	1101                	addi	sp,sp,-32
    539c:	ec06                	sd	ra,24(sp)
    539e:	e822                	sd	s0,16(sp)
    53a0:	e426                	sd	s1,8(sp)
    53a2:	e04a                	sd	s2,0(sp)
    53a4:	1000                	addi	s0,sp,32
    53a6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    53a8:	4581                	li	a1,0
    53aa:	00000097          	auipc	ra,0x0
    53ae:	176080e7          	jalr	374(ra) # 5520 <open>
  if(fd < 0)
    53b2:	02054563          	bltz	a0,53dc <stat+0x42>
    53b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    53b8:	85ca                	mv	a1,s2
    53ba:	00000097          	auipc	ra,0x0
    53be:	17e080e7          	jalr	382(ra) # 5538 <fstat>
    53c2:	892a                	mv	s2,a0
  close(fd);
    53c4:	8526                	mv	a0,s1
    53c6:	00000097          	auipc	ra,0x0
    53ca:	142080e7          	jalr	322(ra) # 5508 <close>
  return r;
}
    53ce:	854a                	mv	a0,s2
    53d0:	60e2                	ld	ra,24(sp)
    53d2:	6442                	ld	s0,16(sp)
    53d4:	64a2                	ld	s1,8(sp)
    53d6:	6902                	ld	s2,0(sp)
    53d8:	6105                	addi	sp,sp,32
    53da:	8082                	ret
    return -1;
    53dc:	597d                	li	s2,-1
    53de:	bfc5                	j	53ce <stat+0x34>

00000000000053e0 <atoi>:

int
atoi(const char *s)
{
    53e0:	1141                	addi	sp,sp,-16
    53e2:	e422                	sd	s0,8(sp)
    53e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    53e6:	00054603          	lbu	a2,0(a0)
    53ea:	fd06079b          	addiw	a5,a2,-48
    53ee:	0ff7f793          	andi	a5,a5,255
    53f2:	4725                	li	a4,9
    53f4:	02f76963          	bltu	a4,a5,5426 <atoi+0x46>
    53f8:	86aa                	mv	a3,a0
  n = 0;
    53fa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    53fc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    53fe:	0685                	addi	a3,a3,1
    5400:	0025179b          	slliw	a5,a0,0x2
    5404:	9fa9                	addw	a5,a5,a0
    5406:	0017979b          	slliw	a5,a5,0x1
    540a:	9fb1                	addw	a5,a5,a2
    540c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5410:	0006c603          	lbu	a2,0(a3) # 1000 <bigdir+0x8a>
    5414:	fd06071b          	addiw	a4,a2,-48
    5418:	0ff77713          	andi	a4,a4,255
    541c:	fee5f1e3          	bgeu	a1,a4,53fe <atoi+0x1e>
  return n;
}
    5420:	6422                	ld	s0,8(sp)
    5422:	0141                	addi	sp,sp,16
    5424:	8082                	ret
  n = 0;
    5426:	4501                	li	a0,0
    5428:	bfe5                	j	5420 <atoi+0x40>

000000000000542a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    542a:	1141                	addi	sp,sp,-16
    542c:	e422                	sd	s0,8(sp)
    542e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5430:	02b57663          	bgeu	a0,a1,545c <memmove+0x32>
    while(n-- > 0)
    5434:	02c05163          	blez	a2,5456 <memmove+0x2c>
    5438:	fff6079b          	addiw	a5,a2,-1
    543c:	1782                	slli	a5,a5,0x20
    543e:	9381                	srli	a5,a5,0x20
    5440:	0785                	addi	a5,a5,1
    5442:	97aa                	add	a5,a5,a0
  dst = vdst;
    5444:	872a                	mv	a4,a0
      *dst++ = *src++;
    5446:	0585                	addi	a1,a1,1
    5448:	0705                	addi	a4,a4,1
    544a:	fff5c683          	lbu	a3,-1(a1)
    544e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5452:	fee79ae3          	bne	a5,a4,5446 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5456:	6422                	ld	s0,8(sp)
    5458:	0141                	addi	sp,sp,16
    545a:	8082                	ret
    dst += n;
    545c:	00c50733          	add	a4,a0,a2
    src += n;
    5460:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5462:	fec05ae3          	blez	a2,5456 <memmove+0x2c>
    5466:	fff6079b          	addiw	a5,a2,-1
    546a:	1782                	slli	a5,a5,0x20
    546c:	9381                	srli	a5,a5,0x20
    546e:	fff7c793          	not	a5,a5
    5472:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5474:	15fd                	addi	a1,a1,-1
    5476:	177d                	addi	a4,a4,-1
    5478:	0005c683          	lbu	a3,0(a1)
    547c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5480:	fee79ae3          	bne	a5,a4,5474 <memmove+0x4a>
    5484:	bfc9                	j	5456 <memmove+0x2c>

0000000000005486 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5486:	1141                	addi	sp,sp,-16
    5488:	e422                	sd	s0,8(sp)
    548a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    548c:	ca05                	beqz	a2,54bc <memcmp+0x36>
    548e:	fff6069b          	addiw	a3,a2,-1
    5492:	1682                	slli	a3,a3,0x20
    5494:	9281                	srli	a3,a3,0x20
    5496:	0685                	addi	a3,a3,1
    5498:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    549a:	00054783          	lbu	a5,0(a0)
    549e:	0005c703          	lbu	a4,0(a1)
    54a2:	00e79863          	bne	a5,a4,54b2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    54a6:	0505                	addi	a0,a0,1
    p2++;
    54a8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    54aa:	fed518e3          	bne	a0,a3,549a <memcmp+0x14>
  }
  return 0;
    54ae:	4501                	li	a0,0
    54b0:	a019                	j	54b6 <memcmp+0x30>
      return *p1 - *p2;
    54b2:	40e7853b          	subw	a0,a5,a4
}
    54b6:	6422                	ld	s0,8(sp)
    54b8:	0141                	addi	sp,sp,16
    54ba:	8082                	ret
  return 0;
    54bc:	4501                	li	a0,0
    54be:	bfe5                	j	54b6 <memcmp+0x30>

00000000000054c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    54c0:	1141                	addi	sp,sp,-16
    54c2:	e406                	sd	ra,8(sp)
    54c4:	e022                	sd	s0,0(sp)
    54c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    54c8:	00000097          	auipc	ra,0x0
    54cc:	f62080e7          	jalr	-158(ra) # 542a <memmove>
}
    54d0:	60a2                	ld	ra,8(sp)
    54d2:	6402                	ld	s0,0(sp)
    54d4:	0141                	addi	sp,sp,16
    54d6:	8082                	ret

00000000000054d8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    54d8:	4885                	li	a7,1
 ecall
    54da:	00000073          	ecall
 ret
    54de:	8082                	ret

00000000000054e0 <exit>:
.global exit
exit:
 li a7, SYS_exit
    54e0:	4889                	li	a7,2
 ecall
    54e2:	00000073          	ecall
 ret
    54e6:	8082                	ret

00000000000054e8 <wait>:
.global wait
wait:
 li a7, SYS_wait
    54e8:	488d                	li	a7,3
 ecall
    54ea:	00000073          	ecall
 ret
    54ee:	8082                	ret

00000000000054f0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    54f0:	4891                	li	a7,4
 ecall
    54f2:	00000073          	ecall
 ret
    54f6:	8082                	ret

00000000000054f8 <read>:
.global read
read:
 li a7, SYS_read
    54f8:	4895                	li	a7,5
 ecall
    54fa:	00000073          	ecall
 ret
    54fe:	8082                	ret

0000000000005500 <write>:
.global write
write:
 li a7, SYS_write
    5500:	48c1                	li	a7,16
 ecall
    5502:	00000073          	ecall
 ret
    5506:	8082                	ret

0000000000005508 <close>:
.global close
close:
 li a7, SYS_close
    5508:	48d5                	li	a7,21
 ecall
    550a:	00000073          	ecall
 ret
    550e:	8082                	ret

0000000000005510 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5510:	4899                	li	a7,6
 ecall
    5512:	00000073          	ecall
 ret
    5516:	8082                	ret

0000000000005518 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5518:	489d                	li	a7,7
 ecall
    551a:	00000073          	ecall
 ret
    551e:	8082                	ret

0000000000005520 <open>:
.global open
open:
 li a7, SYS_open
    5520:	48bd                	li	a7,15
 ecall
    5522:	00000073          	ecall
 ret
    5526:	8082                	ret

0000000000005528 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5528:	48c5                	li	a7,17
 ecall
    552a:	00000073          	ecall
 ret
    552e:	8082                	ret

0000000000005530 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5530:	48c9                	li	a7,18
 ecall
    5532:	00000073          	ecall
 ret
    5536:	8082                	ret

0000000000005538 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5538:	48a1                	li	a7,8
 ecall
    553a:	00000073          	ecall
 ret
    553e:	8082                	ret

0000000000005540 <link>:
.global link
link:
 li a7, SYS_link
    5540:	48cd                	li	a7,19
 ecall
    5542:	00000073          	ecall
 ret
    5546:	8082                	ret

0000000000005548 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5548:	48d1                	li	a7,20
 ecall
    554a:	00000073          	ecall
 ret
    554e:	8082                	ret

0000000000005550 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5550:	48a5                	li	a7,9
 ecall
    5552:	00000073          	ecall
 ret
    5556:	8082                	ret

0000000000005558 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5558:	48a9                	li	a7,10
 ecall
    555a:	00000073          	ecall
 ret
    555e:	8082                	ret

0000000000005560 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5560:	48ad                	li	a7,11
 ecall
    5562:	00000073          	ecall
 ret
    5566:	8082                	ret

0000000000005568 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5568:	48b1                	li	a7,12
 ecall
    556a:	00000073          	ecall
 ret
    556e:	8082                	ret

0000000000005570 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5570:	48b5                	li	a7,13
 ecall
    5572:	00000073          	ecall
 ret
    5576:	8082                	ret

0000000000005578 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5578:	48b9                	li	a7,14
 ecall
    557a:	00000073          	ecall
 ret
    557e:	8082                	ret

0000000000005580 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5580:	1101                	addi	sp,sp,-32
    5582:	ec06                	sd	ra,24(sp)
    5584:	e822                	sd	s0,16(sp)
    5586:	1000                	addi	s0,sp,32
    5588:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    558c:	4605                	li	a2,1
    558e:	fef40593          	addi	a1,s0,-17
    5592:	00000097          	auipc	ra,0x0
    5596:	f6e080e7          	jalr	-146(ra) # 5500 <write>
}
    559a:	60e2                	ld	ra,24(sp)
    559c:	6442                	ld	s0,16(sp)
    559e:	6105                	addi	sp,sp,32
    55a0:	8082                	ret

00000000000055a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    55a2:	7139                	addi	sp,sp,-64
    55a4:	fc06                	sd	ra,56(sp)
    55a6:	f822                	sd	s0,48(sp)
    55a8:	f426                	sd	s1,40(sp)
    55aa:	f04a                	sd	s2,32(sp)
    55ac:	ec4e                	sd	s3,24(sp)
    55ae:	0080                	addi	s0,sp,64
    55b0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    55b2:	c299                	beqz	a3,55b8 <printint+0x16>
    55b4:	0805c863          	bltz	a1,5644 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    55b8:	2581                	sext.w	a1,a1
  neg = 0;
    55ba:	4881                	li	a7,0
    55bc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    55c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    55c2:	2601                	sext.w	a2,a2
    55c4:	00003517          	auipc	a0,0x3
    55c8:	ad450513          	addi	a0,a0,-1324 # 8098 <digits>
    55cc:	883a                	mv	a6,a4
    55ce:	2705                	addiw	a4,a4,1
    55d0:	02c5f7bb          	remuw	a5,a1,a2
    55d4:	1782                	slli	a5,a5,0x20
    55d6:	9381                	srli	a5,a5,0x20
    55d8:	97aa                	add	a5,a5,a0
    55da:	0007c783          	lbu	a5,0(a5)
    55de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    55e2:	0005879b          	sext.w	a5,a1
    55e6:	02c5d5bb          	divuw	a1,a1,a2
    55ea:	0685                	addi	a3,a3,1
    55ec:	fec7f0e3          	bgeu	a5,a2,55cc <printint+0x2a>
  if(neg)
    55f0:	00088b63          	beqz	a7,5606 <printint+0x64>
    buf[i++] = '-';
    55f4:	fd040793          	addi	a5,s0,-48
    55f8:	973e                	add	a4,a4,a5
    55fa:	02d00793          	li	a5,45
    55fe:	fef70823          	sb	a5,-16(a4)
    5602:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5606:	02e05863          	blez	a4,5636 <printint+0x94>
    560a:	fc040793          	addi	a5,s0,-64
    560e:	00e78933          	add	s2,a5,a4
    5612:	fff78993          	addi	s3,a5,-1
    5616:	99ba                	add	s3,s3,a4
    5618:	377d                	addiw	a4,a4,-1
    561a:	1702                	slli	a4,a4,0x20
    561c:	9301                	srli	a4,a4,0x20
    561e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5622:	fff94583          	lbu	a1,-1(s2)
    5626:	8526                	mv	a0,s1
    5628:	00000097          	auipc	ra,0x0
    562c:	f58080e7          	jalr	-168(ra) # 5580 <putc>
  while(--i >= 0)
    5630:	197d                	addi	s2,s2,-1
    5632:	ff3918e3          	bne	s2,s3,5622 <printint+0x80>
}
    5636:	70e2                	ld	ra,56(sp)
    5638:	7442                	ld	s0,48(sp)
    563a:	74a2                	ld	s1,40(sp)
    563c:	7902                	ld	s2,32(sp)
    563e:	69e2                	ld	s3,24(sp)
    5640:	6121                	addi	sp,sp,64
    5642:	8082                	ret
    x = -xx;
    5644:	40b005bb          	negw	a1,a1
    neg = 1;
    5648:	4885                	li	a7,1
    x = -xx;
    564a:	bf8d                	j	55bc <printint+0x1a>

000000000000564c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    564c:	7119                	addi	sp,sp,-128
    564e:	fc86                	sd	ra,120(sp)
    5650:	f8a2                	sd	s0,112(sp)
    5652:	f4a6                	sd	s1,104(sp)
    5654:	f0ca                	sd	s2,96(sp)
    5656:	ecce                	sd	s3,88(sp)
    5658:	e8d2                	sd	s4,80(sp)
    565a:	e4d6                	sd	s5,72(sp)
    565c:	e0da                	sd	s6,64(sp)
    565e:	fc5e                	sd	s7,56(sp)
    5660:	f862                	sd	s8,48(sp)
    5662:	f466                	sd	s9,40(sp)
    5664:	f06a                	sd	s10,32(sp)
    5666:	ec6e                	sd	s11,24(sp)
    5668:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    566a:	0005c903          	lbu	s2,0(a1)
    566e:	18090f63          	beqz	s2,580c <vprintf+0x1c0>
    5672:	8aaa                	mv	s5,a0
    5674:	8b32                	mv	s6,a2
    5676:	00158493          	addi	s1,a1,1
  state = 0;
    567a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    567c:	02500a13          	li	s4,37
      if(c == 'd'){
    5680:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5684:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5688:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    568c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5690:	00003b97          	auipc	s7,0x3
    5694:	a08b8b93          	addi	s7,s7,-1528 # 8098 <digits>
    5698:	a839                	j	56b6 <vprintf+0x6a>
        putc(fd, c);
    569a:	85ca                	mv	a1,s2
    569c:	8556                	mv	a0,s5
    569e:	00000097          	auipc	ra,0x0
    56a2:	ee2080e7          	jalr	-286(ra) # 5580 <putc>
    56a6:	a019                	j	56ac <vprintf+0x60>
    } else if(state == '%'){
    56a8:	01498f63          	beq	s3,s4,56c6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    56ac:	0485                	addi	s1,s1,1
    56ae:	fff4c903          	lbu	s2,-1(s1)
    56b2:	14090d63          	beqz	s2,580c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    56b6:	0009079b          	sext.w	a5,s2
    if(state == 0){
    56ba:	fe0997e3          	bnez	s3,56a8 <vprintf+0x5c>
      if(c == '%'){
    56be:	fd479ee3          	bne	a5,s4,569a <vprintf+0x4e>
        state = '%';
    56c2:	89be                	mv	s3,a5
    56c4:	b7e5                	j	56ac <vprintf+0x60>
      if(c == 'd'){
    56c6:	05878063          	beq	a5,s8,5706 <vprintf+0xba>
      } else if(c == 'l') {
    56ca:	05978c63          	beq	a5,s9,5722 <vprintf+0xd6>
      } else if(c == 'x') {
    56ce:	07a78863          	beq	a5,s10,573e <vprintf+0xf2>
      } else if(c == 'p') {
    56d2:	09b78463          	beq	a5,s11,575a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    56d6:	07300713          	li	a4,115
    56da:	0ce78663          	beq	a5,a4,57a6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    56de:	06300713          	li	a4,99
    56e2:	0ee78e63          	beq	a5,a4,57de <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    56e6:	11478863          	beq	a5,s4,57f6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    56ea:	85d2                	mv	a1,s4
    56ec:	8556                	mv	a0,s5
    56ee:	00000097          	auipc	ra,0x0
    56f2:	e92080e7          	jalr	-366(ra) # 5580 <putc>
        putc(fd, c);
    56f6:	85ca                	mv	a1,s2
    56f8:	8556                	mv	a0,s5
    56fa:	00000097          	auipc	ra,0x0
    56fe:	e86080e7          	jalr	-378(ra) # 5580 <putc>
      }
      state = 0;
    5702:	4981                	li	s3,0
    5704:	b765                	j	56ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5706:	008b0913          	addi	s2,s6,8
    570a:	4685                	li	a3,1
    570c:	4629                	li	a2,10
    570e:	000b2583          	lw	a1,0(s6)
    5712:	8556                	mv	a0,s5
    5714:	00000097          	auipc	ra,0x0
    5718:	e8e080e7          	jalr	-370(ra) # 55a2 <printint>
    571c:	8b4a                	mv	s6,s2
      state = 0;
    571e:	4981                	li	s3,0
    5720:	b771                	j	56ac <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5722:	008b0913          	addi	s2,s6,8
    5726:	4681                	li	a3,0
    5728:	4629                	li	a2,10
    572a:	000b2583          	lw	a1,0(s6)
    572e:	8556                	mv	a0,s5
    5730:	00000097          	auipc	ra,0x0
    5734:	e72080e7          	jalr	-398(ra) # 55a2 <printint>
    5738:	8b4a                	mv	s6,s2
      state = 0;
    573a:	4981                	li	s3,0
    573c:	bf85                	j	56ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    573e:	008b0913          	addi	s2,s6,8
    5742:	4681                	li	a3,0
    5744:	4641                	li	a2,16
    5746:	000b2583          	lw	a1,0(s6)
    574a:	8556                	mv	a0,s5
    574c:	00000097          	auipc	ra,0x0
    5750:	e56080e7          	jalr	-426(ra) # 55a2 <printint>
    5754:	8b4a                	mv	s6,s2
      state = 0;
    5756:	4981                	li	s3,0
    5758:	bf91                	j	56ac <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    575a:	008b0793          	addi	a5,s6,8
    575e:	f8f43423          	sd	a5,-120(s0)
    5762:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5766:	03000593          	li	a1,48
    576a:	8556                	mv	a0,s5
    576c:	00000097          	auipc	ra,0x0
    5770:	e14080e7          	jalr	-492(ra) # 5580 <putc>
  putc(fd, 'x');
    5774:	85ea                	mv	a1,s10
    5776:	8556                	mv	a0,s5
    5778:	00000097          	auipc	ra,0x0
    577c:	e08080e7          	jalr	-504(ra) # 5580 <putc>
    5780:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5782:	03c9d793          	srli	a5,s3,0x3c
    5786:	97de                	add	a5,a5,s7
    5788:	0007c583          	lbu	a1,0(a5)
    578c:	8556                	mv	a0,s5
    578e:	00000097          	auipc	ra,0x0
    5792:	df2080e7          	jalr	-526(ra) # 5580 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5796:	0992                	slli	s3,s3,0x4
    5798:	397d                	addiw	s2,s2,-1
    579a:	fe0914e3          	bnez	s2,5782 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    579e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    57a2:	4981                	li	s3,0
    57a4:	b721                	j	56ac <vprintf+0x60>
        s = va_arg(ap, char*);
    57a6:	008b0993          	addi	s3,s6,8
    57aa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    57ae:	02090163          	beqz	s2,57d0 <vprintf+0x184>
        while(*s != 0){
    57b2:	00094583          	lbu	a1,0(s2)
    57b6:	c9a1                	beqz	a1,5806 <vprintf+0x1ba>
          putc(fd, *s);
    57b8:	8556                	mv	a0,s5
    57ba:	00000097          	auipc	ra,0x0
    57be:	dc6080e7          	jalr	-570(ra) # 5580 <putc>
          s++;
    57c2:	0905                	addi	s2,s2,1
        while(*s != 0){
    57c4:	00094583          	lbu	a1,0(s2)
    57c8:	f9e5                	bnez	a1,57b8 <vprintf+0x16c>
        s = va_arg(ap, char*);
    57ca:	8b4e                	mv	s6,s3
      state = 0;
    57cc:	4981                	li	s3,0
    57ce:	bdf9                	j	56ac <vprintf+0x60>
          s = "(null)";
    57d0:	00003917          	auipc	s2,0x3
    57d4:	8c090913          	addi	s2,s2,-1856 # 8090 <malloc+0x277a>
        while(*s != 0){
    57d8:	02800593          	li	a1,40
    57dc:	bff1                	j	57b8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    57de:	008b0913          	addi	s2,s6,8
    57e2:	000b4583          	lbu	a1,0(s6)
    57e6:	8556                	mv	a0,s5
    57e8:	00000097          	auipc	ra,0x0
    57ec:	d98080e7          	jalr	-616(ra) # 5580 <putc>
    57f0:	8b4a                	mv	s6,s2
      state = 0;
    57f2:	4981                	li	s3,0
    57f4:	bd65                	j	56ac <vprintf+0x60>
        putc(fd, c);
    57f6:	85d2                	mv	a1,s4
    57f8:	8556                	mv	a0,s5
    57fa:	00000097          	auipc	ra,0x0
    57fe:	d86080e7          	jalr	-634(ra) # 5580 <putc>
      state = 0;
    5802:	4981                	li	s3,0
    5804:	b565                	j	56ac <vprintf+0x60>
        s = va_arg(ap, char*);
    5806:	8b4e                	mv	s6,s3
      state = 0;
    5808:	4981                	li	s3,0
    580a:	b54d                	j	56ac <vprintf+0x60>
    }
  }
}
    580c:	70e6                	ld	ra,120(sp)
    580e:	7446                	ld	s0,112(sp)
    5810:	74a6                	ld	s1,104(sp)
    5812:	7906                	ld	s2,96(sp)
    5814:	69e6                	ld	s3,88(sp)
    5816:	6a46                	ld	s4,80(sp)
    5818:	6aa6                	ld	s5,72(sp)
    581a:	6b06                	ld	s6,64(sp)
    581c:	7be2                	ld	s7,56(sp)
    581e:	7c42                	ld	s8,48(sp)
    5820:	7ca2                	ld	s9,40(sp)
    5822:	7d02                	ld	s10,32(sp)
    5824:	6de2                	ld	s11,24(sp)
    5826:	6109                	addi	sp,sp,128
    5828:	8082                	ret

000000000000582a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    582a:	715d                	addi	sp,sp,-80
    582c:	ec06                	sd	ra,24(sp)
    582e:	e822                	sd	s0,16(sp)
    5830:	1000                	addi	s0,sp,32
    5832:	e010                	sd	a2,0(s0)
    5834:	e414                	sd	a3,8(s0)
    5836:	e818                	sd	a4,16(s0)
    5838:	ec1c                	sd	a5,24(s0)
    583a:	03043023          	sd	a6,32(s0)
    583e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5842:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5846:	8622                	mv	a2,s0
    5848:	00000097          	auipc	ra,0x0
    584c:	e04080e7          	jalr	-508(ra) # 564c <vprintf>
}
    5850:	60e2                	ld	ra,24(sp)
    5852:	6442                	ld	s0,16(sp)
    5854:	6161                	addi	sp,sp,80
    5856:	8082                	ret

0000000000005858 <printf>:

void
printf(const char *fmt, ...)
{
    5858:	711d                	addi	sp,sp,-96
    585a:	ec06                	sd	ra,24(sp)
    585c:	e822                	sd	s0,16(sp)
    585e:	1000                	addi	s0,sp,32
    5860:	e40c                	sd	a1,8(s0)
    5862:	e810                	sd	a2,16(s0)
    5864:	ec14                	sd	a3,24(s0)
    5866:	f018                	sd	a4,32(s0)
    5868:	f41c                	sd	a5,40(s0)
    586a:	03043823          	sd	a6,48(s0)
    586e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5872:	00840613          	addi	a2,s0,8
    5876:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    587a:	85aa                	mv	a1,a0
    587c:	4505                	li	a0,1
    587e:	00000097          	auipc	ra,0x0
    5882:	dce080e7          	jalr	-562(ra) # 564c <vprintf>
}
    5886:	60e2                	ld	ra,24(sp)
    5888:	6442                	ld	s0,16(sp)
    588a:	6125                	addi	sp,sp,96
    588c:	8082                	ret

000000000000588e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    588e:	1141                	addi	sp,sp,-16
    5890:	e422                	sd	s0,8(sp)
    5892:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5894:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5898:	00003797          	auipc	a5,0x3
    589c:	8307b783          	ld	a5,-2000(a5) # 80c8 <freep>
    58a0:	a805                	j	58d0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    58a2:	4618                	lw	a4,8(a2)
    58a4:	9db9                	addw	a1,a1,a4
    58a6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    58aa:	6398                	ld	a4,0(a5)
    58ac:	6318                	ld	a4,0(a4)
    58ae:	fee53823          	sd	a4,-16(a0)
    58b2:	a091                	j	58f6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    58b4:	ff852703          	lw	a4,-8(a0)
    58b8:	9e39                	addw	a2,a2,a4
    58ba:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    58bc:	ff053703          	ld	a4,-16(a0)
    58c0:	e398                	sd	a4,0(a5)
    58c2:	a099                	j	5908 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    58c4:	6398                	ld	a4,0(a5)
    58c6:	00e7e463          	bltu	a5,a4,58ce <free+0x40>
    58ca:	00e6ea63          	bltu	a3,a4,58de <free+0x50>
{
    58ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    58d0:	fed7fae3          	bgeu	a5,a3,58c4 <free+0x36>
    58d4:	6398                	ld	a4,0(a5)
    58d6:	00e6e463          	bltu	a3,a4,58de <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    58da:	fee7eae3          	bltu	a5,a4,58ce <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    58de:	ff852583          	lw	a1,-8(a0)
    58e2:	6390                	ld	a2,0(a5)
    58e4:	02059713          	slli	a4,a1,0x20
    58e8:	9301                	srli	a4,a4,0x20
    58ea:	0712                	slli	a4,a4,0x4
    58ec:	9736                	add	a4,a4,a3
    58ee:	fae60ae3          	beq	a2,a4,58a2 <free+0x14>
    bp->s.ptr = p->s.ptr;
    58f2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    58f6:	4790                	lw	a2,8(a5)
    58f8:	02061713          	slli	a4,a2,0x20
    58fc:	9301                	srli	a4,a4,0x20
    58fe:	0712                	slli	a4,a4,0x4
    5900:	973e                	add	a4,a4,a5
    5902:	fae689e3          	beq	a3,a4,58b4 <free+0x26>
  } else
    p->s.ptr = bp;
    5906:	e394                	sd	a3,0(a5)
  freep = p;
    5908:	00002717          	auipc	a4,0x2
    590c:	7cf73023          	sd	a5,1984(a4) # 80c8 <freep>
}
    5910:	6422                	ld	s0,8(sp)
    5912:	0141                	addi	sp,sp,16
    5914:	8082                	ret

0000000000005916 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5916:	7139                	addi	sp,sp,-64
    5918:	fc06                	sd	ra,56(sp)
    591a:	f822                	sd	s0,48(sp)
    591c:	f426                	sd	s1,40(sp)
    591e:	f04a                	sd	s2,32(sp)
    5920:	ec4e                	sd	s3,24(sp)
    5922:	e852                	sd	s4,16(sp)
    5924:	e456                	sd	s5,8(sp)
    5926:	e05a                	sd	s6,0(sp)
    5928:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    592a:	02051493          	slli	s1,a0,0x20
    592e:	9081                	srli	s1,s1,0x20
    5930:	04bd                	addi	s1,s1,15
    5932:	8091                	srli	s1,s1,0x4
    5934:	0014899b          	addiw	s3,s1,1
    5938:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    593a:	00002517          	auipc	a0,0x2
    593e:	78e53503          	ld	a0,1934(a0) # 80c8 <freep>
    5942:	c515                	beqz	a0,596e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5946:	4798                	lw	a4,8(a5)
    5948:	02977f63          	bgeu	a4,s1,5986 <malloc+0x70>
    594c:	8a4e                	mv	s4,s3
    594e:	0009871b          	sext.w	a4,s3
    5952:	6685                	lui	a3,0x1
    5954:	00d77363          	bgeu	a4,a3,595a <malloc+0x44>
    5958:	6a05                	lui	s4,0x1
    595a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    595e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5962:	00002917          	auipc	s2,0x2
    5966:	76690913          	addi	s2,s2,1894 # 80c8 <freep>
  if(p == (char*)-1)
    596a:	5afd                	li	s5,-1
    596c:	a88d                	j	59de <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    596e:	00009797          	auipc	a5,0x9
    5972:	f7a78793          	addi	a5,a5,-134 # e8e8 <base>
    5976:	00002717          	auipc	a4,0x2
    597a:	74f73923          	sd	a5,1874(a4) # 80c8 <freep>
    597e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5980:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5984:	b7e1                	j	594c <malloc+0x36>
      if(p->s.size == nunits)
    5986:	02e48b63          	beq	s1,a4,59bc <malloc+0xa6>
        p->s.size -= nunits;
    598a:	4137073b          	subw	a4,a4,s3
    598e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5990:	1702                	slli	a4,a4,0x20
    5992:	9301                	srli	a4,a4,0x20
    5994:	0712                	slli	a4,a4,0x4
    5996:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5998:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    599c:	00002717          	auipc	a4,0x2
    59a0:	72a73623          	sd	a0,1836(a4) # 80c8 <freep>
      return (void*)(p + 1);
    59a4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    59a8:	70e2                	ld	ra,56(sp)
    59aa:	7442                	ld	s0,48(sp)
    59ac:	74a2                	ld	s1,40(sp)
    59ae:	7902                	ld	s2,32(sp)
    59b0:	69e2                	ld	s3,24(sp)
    59b2:	6a42                	ld	s4,16(sp)
    59b4:	6aa2                	ld	s5,8(sp)
    59b6:	6b02                	ld	s6,0(sp)
    59b8:	6121                	addi	sp,sp,64
    59ba:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    59bc:	6398                	ld	a4,0(a5)
    59be:	e118                	sd	a4,0(a0)
    59c0:	bff1                	j	599c <malloc+0x86>
  hp->s.size = nu;
    59c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    59c6:	0541                	addi	a0,a0,16
    59c8:	00000097          	auipc	ra,0x0
    59cc:	ec6080e7          	jalr	-314(ra) # 588e <free>
  return freep;
    59d0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    59d4:	d971                	beqz	a0,59a8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    59d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    59d8:	4798                	lw	a4,8(a5)
    59da:	fa9776e3          	bgeu	a4,s1,5986 <malloc+0x70>
    if(p == freep)
    59de:	00093703          	ld	a4,0(s2)
    59e2:	853e                	mv	a0,a5
    59e4:	fef719e3          	bne	a4,a5,59d6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    59e8:	8552                	mv	a0,s4
    59ea:	00000097          	auipc	ra,0x0
    59ee:	b7e080e7          	jalr	-1154(ra) # 5568 <sbrk>
  if(p == (char*)-1)
    59f2:	fd5518e3          	bne	a0,s5,59c2 <malloc+0xac>
        return 0;
    59f6:	4501                	li	a0,0
    59f8:	bf45                	j	59a8 <malloc+0x92>
