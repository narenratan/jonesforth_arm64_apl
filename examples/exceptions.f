/ Exceptions examples /

∇ SHOW .S CR CLEAR ∇            / Print then clear stack /

1 2 ⊂ + ⊃ ⍎                     / Just runs + / SHOW

1 2 ⊂ + 0 THROW ⊃ CATCH         / Runs +, no exception thrown → 0 pushed to stack / SHOW

1 2 ⊂ + ABORT ⊃ CATCH           / Exception -1 thrown → Stack rewound, -1 pushed to stack / SHOW

1 2 ⊂ + ABORT ⊃ ⍎               / Uncaught exception /
