/ Delimited continuations /
/
When THROWing an exception we unwind the return stack and ignore all the return
addresses until the marker left by CATCH. But we can instead compile them into a
word which when run will push them onto the return stack - and so do the work we
have skipped by THROWing the exception. This word is called a delimited
continuation. We can leave its execution token on top of the data stack.

The following four lines all calculate the same thing:
/

1 2 3 4 × + -                           / Initial calculation /

1 2 3 4 ⊂ × + - ⊃ ⍎                     / Push an execution token for the whole calculation and execute it /

1 2 3 4 ⊂ × ⟦ + - ⊃ ⟧ ⍎                 / Do the ×, push an execution token for the + -, execute it /

1 2 3 4 ⊂ × + ⟦ - ⊃ ⟧ ⍎                 / Do the × +, push an execution token for the -, execute it /

/
The continuation works even if the ⟦ is further down
the return stack, e.g.
/

∇ new+ + ⟦ 42 EMIT ∇                    / Word containing ⟦ /

1 2 3 4 ⊂ × new+ - ⊃ ⟧                  / Do the × and new+ up to ⟦ (so just the +), push xt for rest of work /
⍎                                       / Execute rest of work, i.e. do rest of new+ (prints B) and the - /

/
The continuation is just like any execution token; in particular it can be
manipulated with combinators. For example to execute it twice we can use ↑ cat
/

1 2 3 4 5 × + - -                       / Initial calculation /

1 2 3 4 5 ⊂ × + ⟦ - ⊃ ⟧ ↑ cat   ⍎       / Capture - in continuation, make execution token to do it twice, execute it /

1 2 3 4 5 ⊂ × new+ - ⊃ ⟧ ↑ cat ⍎        / Prints B twice since continuation executed twice /



/
Below are some examples illustrating how to execute Forth words by pushing their
corresponding return addresses to the return stack. They're probably unnecessary
but they are the experiments I did before writing ⟦ and ⟧ so I have left them
in in case they help anyone else.
/

∇ α ↑ ∇                 / Example Forth words /
∇ β × ∇

3 α β                   / α β is just ↑ ×, squares 3 /

∇ ρ find >CFA 8+ ∇      / ρ gets return stack address corresponding to a word /

ρ α CONST rα            / Return stack addresses of α and β /
ρ β CONST rβ

∇ ψ rβ >R rα >R ∇       / ψ pushes addresses rβ and rα onto return stack /

3 ψ                     / ψ does the same thing as α β /

/
We can execute a Forth word by directly pushing the corresponding return stack
address onto the return stack.

We can even jump inside words by adding an offset to their return address.
/

∇ γ 8+ NEG ∇
ρ γ 8+ CONST rγ+

∇ ω rγ+ >R ∇

3 γ                     / Gives 3 8+ NEG /
3 ω                     / Gives 3 NEG /

/
If all the addresses are the first in Forth words it is simpler to let DOCOL do
the work.
/

rβ 8- rα 8- ∇ ψ' [ , , ] ∇

3 ψ'                    / ψ' does the same thing as ψ /

/
This doesn't work trying to jump into a word since in this case there is no
DOCOL 8 bytes before the return address, e.g.
/

rγ+ 8- ∇ ω' [ , ] ∇     / ω' doesn't work! /

∇ ψω rγ+ >R rβ >R rα >R ∇

3 ψω                    / Gives 3 ↑ × NEG /

