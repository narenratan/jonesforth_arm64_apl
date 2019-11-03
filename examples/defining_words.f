/ Defining words examples /

∇ VECTOR ◁ CELLS ALLOT ▷ ↕ CELLS + ∇

/
When a vector β is being defined as 'N VECTOR β' all that happens is N cells
are allotted to store its elements.
When it is used as 'i β' it returns the address of its ith element.
/

2 VECTOR β      / Define a length 2 vector β /

6 0 β !         / β ≡ 6 7 /
7 1 β !

0 β ? CR        / Check the elements of β /
1 β ? CR

∇ ARRAY ◁ ⊤ , × CELLS ALLOT ▷ ↑ @ ⌽ × CELLS + ↕ CELLS + 8+ ∇

/
When an array is being defined as 'N M ARRAY μ' the value of N is stored in the
header and N×M cells are allotted for its elements.
When it is used as 'i j μ' it returns the address of its (i,j) element.
/

2 2 ARRAY μ     / Define a 2×2 array μ /

6 0 0 μ !       / μ ≡ 6 7 /
7 0 1 μ !       /     8 9 /
8 1 0 μ !
9 1 1 μ !

0 0 μ ? CR      / Check the elements of μ /
0 1 μ ? CR
1 0 μ ? CR
1 1 μ ? CR
