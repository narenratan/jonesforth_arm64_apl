// JonesForth ARM64 (ARMv8 AArch64)
// Richard W.M. Jones' original x86 JonesForth available at http://git.annexia.org/?p=jonesforth.git

// Pointers
#define	D x19 			// Data stack pointer
#define	R x20 			// Return stack pointer
#define I x21			// Instruction pointer
#define J x22			// Codeword pointer

#define S x23			// State
#define H x24			// Here pointer
#define L x25			// Latest pointer

#define D0 x26			// Data stack top pointer
#define R0 x27			// Return stack top pointer

#define PDOC x28		// DOCOL pointer
#define PLIT x29		// LIT pointer

#define W x12			// Word register
#define F x13			// Find register
#define N x14			// Number register

#define B x15			// Buffer pointer
#define K x16			// Key pointer
#define E x17			// End pointer
#define OUTB x11		// Output buffer pointer

// Stack macros
.macro push s,x; str \x,[\s,-8]!; .endm		// e.g. push D,x0 pushes x0 to data stack
.macro push2 s,x,y; stp \y,\x,[\s,-16]!; .endm	// One instruction, two pushes!
.macro pop s,x; ldr \x,[\s],8; .endm		// e.g. pop R,I pops instruction pointer from return stack
.macro pop2 s,x,y; ldp \x,\y,[\s],16; .endm	// One instruction, two pops!

// Definition macros
.macro def x				// Define assembly word
	.data; .align 3
"l\x":	.xword link; .set link, "l\x"	// Dictionary pointer (to last word defined)
	.ascii "\x"; .align 3		// 8-byte name
"\x":	.xword "c\x"			// Codeword - points to assembly code defined below
	.text
"c\x": 	; .endm				// Assembly code follows

.macro defw x				// Define Forth word
	.data; .align 3
"l\x":	.xword link; .set link, "l\x"	// Dictionary pointer
	.ascii "\x"; .align 3		// 8-byte name
"\x":	.xword docol; .endm		// Codeword - docol points to code which runs the Forth words to follow

.set link, 0				// link points to last defined word; it is updated by def and defw

// Forthisms
.macro NEXT; ldr J,[I],8; ldr x0,[J]; br x0; .endm	// Run next word (ends assembly words)
docol:	push R,I; add I,J,8; NEXT			// Code to run a Forth word (the one found after J)
def EXIT; pop R,I; NEXT					// Finish running a Forth word, run next word
def LIT; ldr x0,[I],8; push D,x0; NEXT			// Push following literal number to stack and skip it

// Assembly functions
// Stack manipulation
def ↓; add D,D,8; NEXT;							def ↑; ldr x0,[D]; push D,x0; NEXT
def 2↓; add D,D,16; NEXT;						def 2↑; ldp x0,x1,[D]; push2 D,x1,x0; NEXT
def ⌽; pop2 D,x0,x1; pop D,x2; push2 D,x1,x0; push D,x2; NEXT;		def -⌽; pop2 D,x0,x1; pop D,x2; push2 D,x0,x2; push D,x1; NEXT
def ↕; pop2 D,x0,x1; push2 D,x0,x1; NEXT;				def ⊤; ldr x0,[D,8]; push D,x0; NEXT;

// Arithmetic
def +; pop2 D,x0,x1; add x0,x1,x0; push D,x0; NEXT;			def -; pop2 D,x0,x1; sub x0,x1,x0; push D,x0; NEXT
def ×; pop2 D,x0,x1; mul x0,x1,x0; push D,x0; NEXT;			def ÷; pop2 D,x0,x1; sdiv x0,x1,x0; push D,x0; NEXT
def ⌈; pop2 D,x0,x1; cmp x1,x0; csel x0,x1,x0,gt; push D,x0; NEXT;	def ⌊; pop2 D,x0,x1; cmp x1,x0; csel x0,x1,x0,lt; push D,x0; NEXT
def 1+; pop D,x0; add x0,x0,1; push D,x0; NEXT;				def 1-; pop D,x0; sub x0,x0,1; push D,x0; NEXT
def 8+; pop D,x0; add x0,x0,8; push D,x0; NEXT;				def 8-; pop D,x0; sub x0,x0,8; push D,x0; NEXT
def ÷MOD; pop2 D x0,x1; sdiv x2,x1,x0; msub x1,x0,x2,x1; push2 D,x1,x2; NEXT

// Logic
def "="; pop2 D,x0,x1; cmp x1,x0; cset x0,eq; push D,x0; NEXT;		def ≠; pop2 D,x0,x1; cmp x1,x0; cset x0,ne; push D,x0; NEXT
def <; pop2 D,x0,x1; cmp x1,x0; cset x0,lt; push D,x0; NEXT;		def >; pop2 D,x0,x1; cmp x1,x0; cset x0,gt; push D,x0; NEXT
def ≤; pop2 D,x0,x1; cmp x1,x0; cset x0,le; push D,x0; NEXT;		def ≥; pop2 D,x0,x1; cmp x1,x0; cset x0,ge; push D,x0; NEXT
def "0="; pop D,x0; cmp x0,0; cset x0,eq; push D,x0; NEXT;		def 0≠; pop D,x0; cmp x0,0; cset x0,ne; push D,x0; NEXT
def 0<; pop D,x0; cmp x0,0; cset x0,lt; push D,x0; NEXT;		def 0>; pop D,x0; cmp x0,0; cset x0,gt; push D,x0; NEXT
def 0≤; pop D,x0; cmp x0,0; cset x0,le; push D,x0; NEXT;		def 0≥; pop D,x0; cmp x0,0; cset x0,ge; push D,x0; NEXT
def ∧; pop2 D,x0,x1; and x0,x1,x0; push D,x0; NEXT;			def ∨; pop2 D,x0,x1; orr x0,x1,x0; push D,x0; NEXT
def ~; pop D,x0; mvn x0,x0; push D,x0; NEXT;				def ⊕; pop2 D,x0,x1; eor x0,x1,x0; push D,x0; NEXT

// Bitwise operations
def 40⌽; pop D,x0; rev x0,x0; push D,x0; NEXT;				def 20⌽; pop D,x0; rev32 x0,x0; push D,x0; NEXT
def 10⌽; pop D,x0; rev16 x0,x0; push D,x0; NEXT;			def 1⌽; pop D,x0; rbit x0,x0; push D,x0; NEXT
def >>;	pop2 D,x0,x1; lsr x0,x1,x0; push D,x0; NEXT;			def <<;	pop2 D,x0,x1; lsl x0,x1,x0; push D,x0; NEXT
def ⌽>;	pop2 D,x0,x1; ror x0,x1,x0; push D,x0; NEXT

// Memory
def !; pop2 D,x0,x1; str x1,[x0]; NEXT;					def @; pop D,x0; ldr x0,[x0]; push D,x0; NEXT
def +!; pop2 D,x0,x1; ldr x2,[x0]; add x1,x2,x1; str x1,[x0]; NEXT;	def -!; pop2 D,x0,x1; ldr x2,[x0]; sub x1,x2,x1; str x1,[x0]; NEXT
def C!; pop2 D,x0,x1; strb w1,[x0]; NEXT;				def C@; pop D,x0; ldrb w0,[x0]; push D,x0; NEXT

def MOVE; pop2 D,x0,x1; pop D,x2; 1:ldr x3,[x1],8; str x3,[x2],8; sub x0,x0,1; cbnz x0,1b; NEXT
def CMOVE; pop2 D,x0,x1; pop D,x2; 1:ldrb w3,[x1],1; strb w3,[x2],1; sub x0,x0,1; cbnz x0,1b; NEXT

// Return stack
def ">R"; pop D,x0; push R,x0; NEXT;					def "R>"; pop R,x0; push D,x0; NEXT
def "R↓"; add R,R,8; NEXT;						def "R↑"; ldr x0,[R]; push R,x0; NEXT

// Register values
def "D"; mov x0,D; push D,x0; NEXT; 					def "D!"; pop D,x0; mov D,x0; NEXT
def "R"; push D,R; NEXT; 						def "R!"; pop D,R; NEXT
def "H"; push D,H; NEXT; 						def "H!"; pop D,H; NEXT
def "L"; push D,L; NEXT; 						def "L!"; pop D,L; NEXT
def "S"; push D,S; NEXT; 						def "S!"; pop D,S; NEXT

def "D0"; push D,D0; NEXT
def "R0"; push D,R0; NEXT
def DOCOL; push D,PDOC; NEXT

def KEY; bl key; push D,x0; NEXT;

key:	cmp K,E; b.ge fill; ldrb w0,[K],1; ret			// Fill buffer if exhausted and read next character
fill:	mov x0,0; mov x1,B; mov x2,4096; mov x8,63; svc 0	// stdin, buffer start, buffer size, read syscall
	add E,B,x0; mov K,B					// Update E, reset K
	cbnz x0,key; mov x8,93; svc 0				// Exit 0 if no characters read

	.bss
b:	.space 4096						// Input buffer
outb:	.space 16						// Output buffer

def EMIT; mov x0,1; mov x1,D; mov x2,1; mov x8,64; svc 0; add D,D,8; NEXT	// Write top of stack to stdout

// The word macro loads next the next input word into W register
// It leaves N register ready to convert the word into a number (byte order ready to treat 42 as 00000042)
.macro word
	mov N,0							// Zero number register
1:	bl key; cmp w0,' '; ble 1b;				// Skip leading whitespace
2: 	add N,x0,N,lsl 8; bl key; cmp w0,' '; bgt 2b		// Add bytes until next whitespace
3:	clz x0,N; and x0,x0,~7; lsl W,N,x0; rev W,W; .endm	// Match byte arrangement of names loaded from memory in W

def WORD; word; NEXT

// Vector registers holding constants (for ASCII ←→ number conversion)
#define VC0A v8
#define VC0F v9
#define VC20 v10
#define VC30 v11
#define VC37 v12
#define VC41 v13

.macro number	// characters → number
	mov v2.2d[0],N; cmeq v0.8b,v2.8b,0; bsl v0.8b,VC30.8b,v2.8b		// Fill null bytes with '0'
	sub v1.8b,v0.8b,VC30.8b; sub v2.8b,v0.8b,VC37.8b			// Calculate values from characters
	cmge v3.8b,v0.8b,VC41.8b; bsl v3.8b,v2.8b,v1.8b				// Conditionally select values from 0-9 or A-F
	ushr v4.2d,v3.2d,4; add v3.8b,v3.8b,v4.8b; uzp1 v3.8b,v3.8b,v3.8b	// Pack half bytes into bytes (01 0A → 1A)
	mov w14,v3.s[1]; .endm							// Store number in lower half of N

.macro unnumber	// number → characters
	orr x0,N,1; clz x0,x0; and x0,x0,~7; movn x1,0; lsl x0,x1,x0; mov v2.2d[0],x0; zip1 v2.16b,v2.16b,v2.16b
	rev N,N; mov v0.2d[0],N
	ushr v1.8b,v0.8b,4; zip1 v0.16b,v1.16b,v0.16b; and v0.16b,v0.16b,VC0F.16b
	cmge v1.16b,v0.16b,VC0A.16b; bsl v1.16b,VC37.16b,VC30.16b; add v1.16b,v0.16b,v1.16b
	bsl v2.16b,v1.16b,VC20.16b; st1 {v2.16b},[OUTB]; .endm

def NUMBER; number; push D,N; NEXT

def U.; pop D,N; unnumber					// Print number on top of stack
	mov x0,1; mov x1,OUTB; mov x2,16; mov x8,64; svc 0
	NEXT

.set FIMMED, 0x80	// Immediate flag (stored in top bit of last byte of a name)

.macro find				// Search dictionary for word in W
	mov F,L					// Start searching at latest word defined
1:	cbz F,2f				// Stop if end of dictionary reached
	ldr x0,[F,8]; bic x0,x0,FIMMED<<56	// Load name and zero immediate bit
	cmp x0,W; beq 2f			// Stop if word matches
	ldr F,[F]; b 1b				// Otherwise loop
2:	; .endm

def FIND; find; push D,F; NEXT

def MINTERP					// Minimal interpreter - no compiling (not used below)
	word; find; cbz F,mnum			// Search for word; if not found convert it to a number
	add J,F,16; ldr x0,[J]; br x0		// If word found, get its codeword and execute
mnum:	number; push D,N; NEXT

defw QUIT; .xword "R0","R!",INTERP,BR,-16	// Top loop - Reset return stack, interpret, repeat

def ALIGN; add H,H,7; and H,H,~7; NEXT		// Round H up to next word boundary

def CREATE; stp L,W,[H],16; sub L,H,16; NEXT	// Store link pointer and name Here, updating Here and Latest

def ","; pop D,x0; str x0,[H],8; NEXT		// Store word at H
def ",,"; pop D,x0; str w0,[H],4; NEXT		// Store half word at H
def "C,"; pop D,x0; strb w0,[H],1; NEXT		// Store byte at H

def "[\x0\x0\x0\x0\x0\x0\x80"; mov S,0; NEXT 	// [ starts compiling (defined with immediate flag)

def "]"; mov S,1; NEXT				// ] Stops compiling

// : creates a Forth word header (like defw) and starts compiling
defw ":"; .xword ALIGN,WORD,CREATE,LIT,docol,",","]",EXIT

// ; appends EXIT and stops compiling (immediate)
defw ";\x0\x0\x0\x0\x0\x0\x80"; .xword LIT,EXIT,",","[\x0\x0\x0\x0\x0\x0\x80",EXIT

// I sets immediate flag of latest word defined (I is itself immediate)
def "I\x0\x0\x0\x0\x0\x0\x80"; ldr x0,[L,8]; eor x0,x0,FIMMED<<56; str x0,[L,8]; NEXT

def "'"; ldr x0,[I],8; push D,x0; NEXT		// ' pushes next word to data stack and skips it

def BR; ldr x0,[I]; add I,x0,I; NEXT		// Unconditional branch
def BZ; pop D,x0; cbz x0,cBR; add I,I,8; NEXT	// Branch if zero
def BNZ; pop D,x0; cbnz x0,cBR; add I,I,8; NEXT	// Branch if non-zero

def LITS; ldr x0,[I],8; push2 D,I,x0; add I,I,x0; add I,I,8; and I,I,~7; NEXT	// Push string literal address+length to stack
def TELL; mov x0,1; pop2 D,x2,x1; mov x8,64; svc 0; NEXT			// Print string

def INTERP
	word; find; cbz F,num			// Search for word; if not found, it is a number
	add J,F,16; cbz S,ex			// Get codeword pointer; if not compiling, execute word
	ldr x0,[J,-8]; tbnz x0,63,ex		// Check if word is immediate; if so execute it
	str J,[H],8; NEXT			// Else just compile word
num:	number; cbnz S,lit; push D,N; NEXT	// Convert to number; if compiling, compile literal, else push to stack
lit:	stp PLIT,N,[H],16; NEXT			// Compile two words LIT N
ex:	ldr x0,[J]; br x0			// Get codeword and execute it

def CHAR; word; and x0,W,0xFF; push D,x0; NEXT	// Push first character of next input word

def ⍎; pop D,J; ldr x0,[J]; br x0		// Execute (use top of stack as a codeword pointer)

def "/\x0\x0\x0\x0\x0\x0\x80"; skip: bl key; cmp x0,'/'; bne skip; NEXT		// Use / for comments, e.g. / comment /

def SYS	// n SYS performs syscall with n arguments
	pop2 D,x9,x8; ldp x0,x1,[D]; ldp x2,x3,[D,16]; ldp x4,x5,[D,32]
	svc 0; add D,D,x9,lsl 3; push D,x0; NEXT

	.text
	.globl _start
_start:	mov D,sp					// Initialize Data stack pointer
	adr R,Rtop;					// Initialize Return stack pointer
	adr I,first					// Initialize Instruction pointer
	mov S,0						// Initialize State
	adr H,Dstart; adr L,lSYS			// Initialize Here and Latest pointers
	adr B,b; mov K,B; mov E,B			// Initialize Buffer, Key, End pointers
	adr OUTB,outb					// Initialize output buffer pointer
	mov D0,D; mov R0,R				// Initialize stack top pointers
	adr PLIT,LIT; adr PDOC,docol			// Initialize LIT and DOCOL pointers
	movi VC0A.16b,10; movi VC0F.16b,0x0F		// Initialize constant vector registers
	movi VC20.16b,32; movi VC30.16b,'0'
	movi VC37.16b,55; movi VC41.16b,65
	NEXT						// Start interpreter

	.data
first:	.xword QUIT
	.bss
	.align 3; Dstart: .space 16384; Rtop:		// Space for data area (pointed to by H) and return stack
