*JonesForth ARM64 with APL symbols*

This is an ARMv8 AArch64 version of Richard W.M. Jones' original x86 JonesForth.
I have added a few things including:

    - Defining words
    - Combinators
    - Delimited continuations

Also I have used the APL character set.

The pizza is in the examples dir but by way of garlic bread:

∇ ε ( ⌈⌊ ⊤ - ↑ ∥) ↓ ∇   / Define ε as Euclid's algorithm /          

∇ λ ◁ , ▷ @ ⍎ ∇         / A defining word λ which names anonymous functions /

3 ⊂ ↑ ⊃ ⊂ + ⊃ cat ⍎     / Double three using the cat combinator /

1 2 3 4 ⊂ × ⟦ + - ⊃ ⟧ ⍎ / Capture '+ -' in a delimited continuation with ⟦ ⟧ /

ASCII equivalents for APL-character words are defined in ascii.f (they are the
corresponding Forth words where applicable so ascii.f makes a handy glossary).


You can compile and run with

    gcc -nostdlib jonesforth.S

    cat jonesforth.f - | ./a.out

and run the the examples like

    cat jonesforth.f examples/sockets.f - | ./a.out

You may need to

    stty iutf8

if your terminal isn't set up to handle utf8 by default.

