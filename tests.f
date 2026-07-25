∇ ASSERT= 2↑ ≠ { ." FAIL:" CR . CR . CR 1 _EXIT | 2↓ } ∇

DEPTH
0 ASSERT=

1 2 +
3 ASSERT=

/ Test defining words /
∇ VECTOR ◁ CELLS ALLOT ▷ ↕ CELLS + ∇
2 VECTOR β      / Define a length 2 vector β /
6 0 β !         / β ≡ 6 7 /
7 1 β !

0 β @
6 ASSERT=
1 β @
7 ASSERT=

/ Test exception handling /
1 2 ⊂ + 0 THROW ⊃ CATCH
DEPTH
2 ASSERT=
0 ASSERT=
3 ASSERT=

1 2 ⊂ + ABORT ⊃ CATCH
DEPTH
3 ASSERT=
1 ¯ ASSERT=
2 ASSERT=
1 ASSERT=

1 2 ⊂ 3 4 5 + ABORT ⊃ CATCH
DEPTH
3 ASSERT=
1 ¯ ASSERT=
2 ASSERT=
1 ASSERT=

/ Test that nested throw-catches restore the original stack /
∇ INNER  3 4 5 ABORT ∇
∇ MIDDLE 6 7 ' INNER CATCH THROW ∇
∇ OUTER ' MIDDLE CATCH ∇

1 2 OUTER
DEPTH
3 ASSERT=
1 ¯ ASSERT=
2 ASSERT=
1 ASSERT=


/ Test throw-catch with deep stack /
1 2 3 4 5 6 7 8 9 0A 0B 0C 0D 0E 0F 10 11
⊂ ABORT ⊃ CATCH
DEPTH
12 ASSERT=
1 ¯ ASSERT=
11 ASSERT=
10 ASSERT=
0F ASSERT=
0E ASSERT=
0D ASSERT=
0C ASSERT=
0B ASSERT=
0A ASSERT=
9 ASSERT=
8 ASSERT=
7 ASSERT=
6 ASSERT=
5 ASSERT=
4 ASSERT=
3 ASSERT=
2 ASSERT=
1 ASSERT=
