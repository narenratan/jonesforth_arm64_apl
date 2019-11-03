/ Combinators /
/ Following Brent Kerby's 'The Theory of Concatenative Combinators' (TCC) /

/ Everything below doubles 3 /

3 ↑ +                   / Double 3 /

3 ⊂ ↑ + ⊃ ⍎             / Push execution token to stack, execute it /

3 ⊂ ↑ + ⊃ unit ⍎ ⍎      / Push execution token, wrap with unit, unwrap with ⍎, execute with ⍎ /

3 ⊂ ↑ ⊃ ⊂ + ⊃ cat ⍎     / Push separate execution tokens for ↑ and +, combine with cat, execute with ⍎ /

3 ⊂ + ⊃ ⊂ ↑ ⊃ ↕ cat ⍎   / Push executions for + and ↑, swap order with ↕, combine with cat, execute /

/ The examples above illustrate the definitions of the combinators /
/ The combinators also satisfy some interesting identities /
/ For example 

                unit ≡ ⊂⊃ cons

so this also doubles 3: /

3 ⊂ ↑ + ⊃ ⊂⊃ cons ⍎ ⍎

/ We can define a unit' which does this: /

∇ unit' ⊂⊃ cons ∇

3 ⊂ ↑ + ⊃ unit' ⍎ ⍎

/ The following also doubles three: /

3 ⊂ ↑ ⊃ ⊂ + ⊃ ⊂ ⍎ ⊃ ⊂ dip ⍎ ⊃ cons cons cons ⍎

/ This is because of the identity

        cat ≡ ⊂ ⍎ ⊃ ⊂ dip ⍎ ⊃ cons cons cons

We can define a new cat' which does this:
/

⊂ dip ⍎ ⊃ ⊂ ⍎ ⊃ ∇ cat' LITERAL LITERAL cons cons cons ∇

/ The LITERALs just compile the execution tokens in the definition of cat' /

3 ⊂ ↑ ⊃ ⊂ + ⊃ cat' ⍎

/ Also cons can be written in terms of cat,

        cons ≡ ⊂ unit ⊃ dip cat

giving /

⊂ unit ⊃ ∇ cons' LITERAL dip cat ∇

3 ⊂ ↑ + ⊃ ⊂⊃ cons' ⍎ ⍎

/ swap ≡ unit dip /

∇ swap' unit dip ∇

3 ⊂ + ⊃ ⊂ ↑ ⊃ swap' cat ⍎

∇ dip' ↕ unit cat ⍎ ∇

3 ⊂ + ⊃ ⊂ ↑ ⊃ unit dip' cat ⍎

/ ⍎ ≡ ↑ dip ↓ /                 ∇ ⍎'    ↑ dip ↓ ∇
/ ⍎ ≡ ⊂⊃ unit dip dip ↓ /       ∇ ⍎''   ⊂⊃ unit dip dip ↓ ∇
/ ⍎ ≡ ⊂⊃ unit dip dip dip /     ∇ ⍎'''  ⊂⊃ unit dip dip dip ∇

3 ⊂ ↑ + ⊃ ⍎'

3 ⊂ ↑ + ⊃ ⍎''

3 ⊂ ↑ + ⊃ ⍎'''

/ Lambdas /
/ λ (written \ in TCC) can be implemented as a Forth defining word /

∇ λ ◁ , ▷ @ ⍎ ∇

/ dip ≡ λ a λ b a ⊂ b ⊃ /

3 ⊂ + ⊃ ⊂ ↑ ⊃ unit λ a λ b a ⊂ b ⊃ cat ⍎

/ End of scope ($ in TCC) can be done with HIDE a /

∇ $ HIDE ∇

/ An Abstraction Algorithm /
/ TCC gives an algorithm to eliminate λ's from combinators. Applying it /
/ gives the equivalence of /

/ λ a b a ⊂ c a ⊃   ≡   ⊂ b ⊃ dip ↑ ⊂ ⍎ ⊃ dip ⊂ c ⊃ ⊂ dip ⍎ ⊃ cons cons /
/ ( lambda )                    ( no lambda ) /

/ For example, letting b be ↑ and c be + and trying each of the above /
/ combinators on a stack with 2 ⊂ 1+ ⊃ on ( adding an ⍎ at the end of /
/ both to test the effect of the ⊂ c a ⊃ left on top of the stack) /

⊂ ↑ ⊃ ⊂ + ⊃ λ c λ b
        2 ⊂ 1+ ⊃     λ a b a ⊂ c a ⊃ ⍎
        2 ⊂ 1+ ⊃     ⊂ b ⊃ dip ↑ ⊂ ⍎ ⊃ dip ⊂ c ⊃ ⊂ dip ⍎ ⊃ cons cons ⍎

/ Both give 6 since in this case both lines are equivalent to 2 ↑ 1+ + 1+ /

/ The sip Combinator /
/ ⊂ b ⊃ ⊂ a ⊃ sip   ≡   ⊂ b ⊃ a ⊂ b ⊃ /

/ ↑ ≡ ⊂⊃ sip /
3 ⊂⊃ sip +

/ dip ≡ λ a ⊂ ↓ a ⊃ sip /
3 ⊂ + ⊃ ⊂ ↑ ⊃ unit   λ a ⊂ ↓ a ⊃ sip   cat ⍎

/ dip ≡ ⊂ ↓ ↓ ⊃ ⊂ sip ⍎ ⊃ cons cons sip /
3 ⊂ + ⊃ ⊂ ↑ ⊃ unit   ⊂ ↓ ↓ ⊃ ⊂ sip ⍎ ⊃ cons cons sip   cat ⍎

/ Applicative Combinators /

∇ w ['] ↑ dip ⍎ ∇
∇ k ['] ↓ dip ⍎ ∇
∇ b ['] cons dip ⍎ ∇
∇ c ['] ↕ dip ⍎ ∇

∇ s >R ⊤ ↕ cons ↕ R> ⍎ ∇

/ ↑    ≡ ⊂⊃ w /
/ ↓    ≡ ⊂⊃ k /
/ cons ≡ ⊂⊃ b /
/ ↕    ≡ ⊂⊃ c /

3 ⊂⊃ w +
3 ↑ ↑ ⊂⊃ k +
3 ⊂ ↑ + ⊃ ⊂⊃  ⊂⊃ b  ⍎ ⍎
3 ⊂ + ⊃ ⊂ ↑ ⊃ ⊂⊃ c cat ⍎

/ b ≡ ⊂ k ⊃ ⊂ s ⊃ ⊂ k ⊃ cons s /

⊂ k ⊃ ⊂ s ⊃ ⊂ k ⊃ ∇ b' LITERAL LITERAL LITERAL cons s ∇

3 ⊂ ↑ + ⊃ ⊂⊃  ⊂⊃ b'  ⍎ ⍎
