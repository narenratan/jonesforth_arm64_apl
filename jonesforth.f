/ JonesForth ARM64 /
/ based on Richard W.M. Jones' original x86 JonesForth /

/ In stack comments n, a, and x are used to mean: /
/       n | number              /
/       a | address             /
/       x | execution token     /

: MOD ÷MOD ↓ ;                          / nn→n modulo by dropping quotient from ÷MOD /
: NEG 0 ↕ - ;                           / n→n negate /

: CR 0A EMIT ;                          / Print newline /
: SPACE 20 EMIT ;                       / Print space /

: find WORD FIND ;                      / find next word in input /
: create WORD CREATE 0 , ;              / Create word header with next word as name, codeword pointer 0 /
: ,LIT ' LIT , , ;                      / n→ Compile literal number /
: LITERAL I ,LIT ;                      / n→ Compile literal number (immediate) /
: >CFA 8+ 8+ ;                          / n→n Compute codeword address from dictionary pointer address /
: >DFA >CFA 8+ ;                        / n→n Compute address of first word in definition from dictionary pointer address /
: [COMP] I find >CFA , ;                / Compile an immediate word /

/ Character constants /
: '"' [ CHAR " ] LITERAL ;              / →n '"' pushes 22 (ASCII ") to the stack /
: '-' [ CHAR - ] LITERAL ;              / →n '-' pushes 2D (ASCII -) to the stack /

/ Control structures /
: { I ' BZ , H 0 , ;                    / { A } does A if top of stack (TOS) is true /
: } I ↑ H ↕ - ↕ ! ;
: | I ' BR , H 0 , ↕ ↑ H ↕ - ↕ ! ;      / { A | B } does A if TOS true, B if false /

: ( I H ;                               / ( A ∥ B ) does B while A gives true /
: ∥ I ' BZ , H 0 , ;
: ) I ' BR , ↕ H - , ↑ H ↕ - ↕ ! ;

: ∥) I ' BNZ , H - , ;                  / ( A ∥) does A until false /
: 1∥) I ' BR , H - , ;                  / ( A 1∥) does A indefinitely /

: ∇ I S { [COMP] ; | : } ;              / ∇ starts and ends definitions /

∇ . ↑ 0≥ { U. | NEG U. '-' EMIT } ∇     / n→ Print signed number /

∇ ¯ I S { H 8- ↑ @ NEG ↕ ! | NEG } ∇    / n→n Compile time negate /

∇ SPACES ( ↑ ∥ SPACE 1- ) ↓ ∇           / n→ Print n spaces /

∇ .S D ( ↑ D0 < ∥ ↑ @ . CR 8+ ) ↓ ∇     / Print the stack /

∇ ⌈⌊ 2↑ > { ↕ } ∇                       / nn→nn Sort top two elements of stack /

∇ ε ( ⌈⌊ ⊤ - ↑ ∥) ↓ ∇                   / nn→n Euclid's algorithm for greatest common divisor /

∇ ? @ . ∇                               / a→ Print contents of memory address /

∇ WITHIN -⌽ ⊤ ≤ { > | 2↓ 0 } ∇          / nnn→n Check if number lies in range /

∇ DEPTH D D0 ↕ - 8 ÷ ∇                  / →n Current stack depth /

∇ CLEAR D0 D! ∇                         / Clear stack /

/ Strings /
∇ S" I ' LITS , H 0 , ( KEY ↑ '"' ≠ ∥ C, ) ↓ ↑ H ↕ - 8- ↕ ! 0 C, ALIGN ∇ / Compile a string in a word /
∇ ." I S { [COMP] S" ' TELL , | ( KEY ↑ '"' ≠ ∥ EMIT ) ↓ } ∇             / Print a string /

/ Constants and variables /
∇ CONST WORD CREATE DOCOL , ' LIT , , ' EXIT , ∇
∇ ALLOT H + H! ∇ / n→ /
∇ CELLS 8 × ∇ / n→n /
∇ VAR H 1 CELLS ALLOT CONST ∇

/ Values /
∇ VALUE WORD CREATE DOCOL , ' LIT , , ' EXIT , ∇
∇ TO I find >DFA 8+ S {  ' LIT , , ' ! , | ! } ∇
∇ +TO I find >DFA 8+ S {  ' LIT , , ' +! , | +! } ∇

/ Dictionary /
∇ ID. @ 1 1⌽ ~ ∧ H ! H 8 TELL ∇         / a→ Print name at address a (masking immediate bit) /
∇ WORDS L ( ↑ 8+ ID. SPACE @ ↑ ∥) ↓ ∇   / Print all words in dictionary /
∇ FORGET find ↑ @ L! H! ∇               / forget all words after next word in input stream /

∇ 1DUMP ↑ U. SPACE @ 40⌽ U. ∇ / a→ /
∇ DUMP ( ↑ ∥ ↕ ↑ 1DUMP CR 8+ ↕ 1- ) 2↓ ∇ / an→ /

∇ INDATA? [ find EXIT ] LITERAL [ find MOD 4000 + ] LITERAL WITHIN ∇                    / a→n Check if address is in data area /
∇ CEXIT [ find EXIT >CFA ] LITERAL ∇                                                    / →a  Codeword address of EXIT /
∇ SEE find >DFA ( ↑ @ CEXIT ≠ ∥ ↑ ↑ 1DUMP SPACE @ ↑ INDATA? { 8- ID. | . } CR 8+ ) ↓ ∇  / Decompile a word (try printing names of words, print literals) /

/ Execution tokens /
∇ ⊂ H DOCOL , ] ∇       / →x Start compiling anonymous word /
∇ ⊃ I [COMP] ; ∇        /    Finish compiling anonymous word /
⊂ ⊃ ∇ ⊂⊃ LITERAL ∇      / →x Push execution token for anonymous word which does nothing /
∇ ['] I ' LIT , ∇       / Compile execution token of next word in input /

/ Combinators - see combinators.f /
∇ unit H ↕ DOCOL , ,LIT ' EXIT , ∇                      / x→x /
∇ cat H -⌽ ↕ DOCOL , ,LIT ' ⍎ , ,LIT ' ⍎ , ' EXIT , ∇   / xx→x /
∇ cons H -⌽ ↕ DOCOL , ,LIT ,LIT ' ⍎ , ' EXIT , ∇        / xx→x /
∇ dip ↕ >R ⍎ R> ∇
∇ sip ⊤ >R ⍎ R> ∇

/ Assembler /
∇ ∆ WORD CREATE H 8+ , ∇        / Create header for assembly word; codeword points to cell following it /

∇ .dr B << ∨ 5 << ∨ ∇           / nnn→n build opcode for register data-processing instruction /
∇ .di 5 << ∨ 5 << ∨ ∇           / nnn→n build opcode for immediate data-processing instruction /
∇ .li 1FF ∧ 7 << ∨ 5 << ∨ ∇     / nnn→n build opcode for immediate load or store instruction /

/ Data processing instructions (register) nnn→n /
∇ add .dr 8B000000 ∨ ∇  ∇ sub .dr CB000000 ∨ ∇
∇ and .dr 8A000000 ∨ ∇  ∇ orr .dr AA000000 ∨ ∇

/ Data processing instructions (immediate) nnn→n /
∇ addi .di 91000000 ∨ ∇ ∇ subi .di D1000000 ∨ ∇

/ Load and store instructions (immediate) nnn→n /
∇ ldr .li F8400000 ∨ ∇  ∇ str .li F8000000 ∨ ∇

/ Set post- and pre- index flags for load and store instructions /
∇ post 400 ∨ ∇          ∇ pre C00 ∨ ∇           / n→n /

∇ pop 8 ldr post ∇      ∇ push 8 ¯ str pre ∇    / nn→n /

∇ .D 13 ∇ ∇ .R 14 ∇ ∇ .I 15 ∇ ∇ .J 16 ∇ / Register numbers for D,R,I,J pointers /

∇ NEXT .J .I 8 ldr post ,, 0 .J 0 ldr ,, D61F0000 ,, ALIGN ∇ / Code for NEXT (hex opcode is for the branch br x0) /

/ Example defining 7+ with the assembler /
∆ 7+ 0 .D pop ,, 0 0 7 addi ,, 0 .D push ,, NEXT

/ Defining words - see R.G. Loeliger's Threaded Interpretive Languages book /
∇ SCODE L >CFA ! ∇              / a→ Store address as codeword of latest word defined (used to set behaviour of word when run) /
∇ ⋄ I H 20 + ,LIT ' SCODE , ∇   / ⋄ compiles code to overwrite the latest word's codeword with the address following the word containing ⋄ /

/ Example defining words whose actions are defined with the assembler /
∇ CONST' create , ⋄ ∇ 0 .J 8 ldr ,, 0 .D push ,, NEXT
∇ 2CONST create , , ⋄ ∇ 0 .J 8 ldr ,, 1 .J 10 ldr ,, 0 .D push ,, 1 .D push ,, NEXT
∇ VAR' create 0 , ⋄ ∇ 0 .J 8 addi ,, 0 .D push ,, NEXT

/ ◁ and ▷ let you define the action of the defined words in Forth rather than assembler - see defining_words.f /
∇ ◁ create 0 , ∇
∇ ▷ R> L >CFA 8+ ! ⋄ ∇ .I .R push ,, 0 .J 10 addi ,, 0 .D push ,, .I .J 8 ldr ,, NEXT

/ Example defining words with their actions specified in Forth (also see defining_words.f) /
∇ CONST'' ◁ , ▷ @ ∇
∇ VAR'' ◁ , ▷ ∇

/ λ allows us to name an execution token (see combinators.f) /
∇ λ ◁ , ▷ @ ⍎ ∇

/ Exceptions /
/ Data stack restored after exception using a stack of stacks - see exceptions.f /
VAR SS                                                          / Stack-stack pointer /
D0 10 CELLS - CONST SS0                                         / Initial stack-stack pointer /
SS0 SS !                                                        / Initialize SS /
∇ SPUSH 10 CELLS SS -! DEPTH SS0 ! SS @ SS0 10 MOVE ∇           / Push current stack to stack-stack /
∇ SPOP D0 SS0 @ CELLS - D! SS0 SS @ 10 MOVE 10 CELLS SS +! ∇    / Pop stack from stack-stack /
∇ S↓ 10 CELLS SS +! ∇                                           / Drop top stack-stack stack /

∇ MARKER S↓ ∇
∇ CATCH ' MARKER 8+ >R SPUSH ⍎ ∇
∇ THROW ↑ { R ( ↑ R0 8- < ∥ ↑ @ ' MARKER 8+ = { 8+ R! >R SPOP ↓ R> EXIT } 8+ ) ↓ ." Uncaught throw" CR QUIT } ∇
∇ ABORT 1 ¯ THROW ∇

∇ TRACE R ( ↑ R0 8- < ∥ ↑ @ ↑ H ! U. CR 8+ ) ↓ ∇ / Print addresses currently on return stack (no attempt to decompile them) /

/ Delimited continuations - see continuations.f /
∇ RCOMP H DOCOL , >R ( 2↑ ≤ ∥ ↑ @ ,LIT ' >R , 8- ) 2↓ R> ' EXIT , ∇             / aa→x Compile word pushing addresses to return stack /
∇ ⟦ R ↑ ( ↑ R0 8- < ∥ ↑ @ ' MARKER 8+ = { ↑ 8+ R! 10 - CR RCOMP EXIT } 8+ ) ∇   / Start capturing a continuation /
∇ ⟧ ' MARKER 8+ >R ⍎ ∇                                                          / Finish capturing a continuation /

/ C Strings /
∇ STRLEN ↑ ( ↑ C@ ∥ 1+ ) ↕ - ∇ / a→n Get length of null terminated string /

/ Environment /
∇ ARGC D0 @ ∇
∇ ARGV 1+ CELLS D0 + @ ↑ STRLEN ∇
∇ ENV ARGC 2 + CELLS D0 + ∇

/ Syscalls /
∇ _EXIT 5D 2 SYS ∇
∇ BYE 0 _EXIT ∇

∇ ⍇ 3F 3 SYS ∇          / read  /
∇ ⍈ 40 3 SYS ∇          / write /
∇ ⍐ 64 ¯ 38 4 SYS ∇     / open  /
∇ ⍗ 39 1 SYS ∇          / close /

∇ UNAME A0 1 SYS ∇
∇ OS H UNAME ↓ H 40 TELL ∇
∇ HOSTNAME H UNAME ↓ H 41 + 40 TELL ∇

." ⍋ JONESFORTH ARM64 ⍋" CR
