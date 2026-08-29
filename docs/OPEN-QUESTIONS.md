# What is still not settled, listed one by one

The budget is at 100 %: the 16,384 bytes are split between traced code (9,872)
and named data ranges (6,512), and `make sanity` checks it. What follows is not
unassigned bytes but things that are explained with less certainty than I would
like.

## 1. Twelve dead bytes at 0x4E64

The same ones as in the sibling cartridge and in the same posture, right next to
the eight VDP registers: `00 70 38 70 / 00 A0 38 70 / 00 F0 38 F0`. Nobody reads
them.

## 2. The annotations come ported, and 16.6 % do not

Of Hyper Olympic 1's 5,032 instructions, 4,195 turn up here and bring their
comments with them (`tools/porta_notas.py` lines both ROMs up and moves the Ls,
the Cs and the Bs). The 1,519 bytes of code that do NOT come from the sibling
were read and commented by hand. Even so, a ported comment says what the
instruction did IN THE OTHER CARTRIDGE; where the meaning changes —the event
names above all— it was corrected one by one, but this is the place where
something could have slipped through.

Two guards watch it, and both caught something real: `tools/repasa_el_porte.py`
found nine cited addresses that do not exist here and a block heading that still
talked about the hammer, and `tools/cifras_portadas.py` found the two comments
at 0x4389 that said "32 sprites" when here they are 26.

## 3. The data blocks were NOT ported

The D ranges and the F widths were worked out here again by walking the scripts,
the melodies, the poses and the actor records with the same tools. Not one comes
copied from the sibling.

## 4. The large-letter labels go by address, not by name

The 31 labels from 0x632F to 0x64B0 are delimited by the walk over the scripts,
but only four have a name of their own: the four events'. The rest are published
as `rotulo_XXXX`. Naming them would mean drawing them.

## 5. Five small gaps in the object's patterns

Walking 0x789E leaves loose four groups of four bytes (0x78AE, 0x78C0, 0x78D6,
0x78E6) and one of twenty (0x78FC). ASSUMPTION: they are the attribute rows that
follow each pattern, because 0x690A writes two sprites per pattern and the
numbers add up. They fall inside the `patrones_del_objeto` range and that is why
the budget balances, but they have not been checked one by one.

## 6. Four strips of melody nothing reaches

Walking the table at 0x6E64 from the seventeen sounds the code asks for with an
immediate value leaves four stretches unvisited: 0x6EE5-0x6EF6 (entry 10 of the
table), 0x6F3E-0x6F53 (13), 0x6F6B-0x6F75 (21) and 0x710E-0x7116, which no entry
points at. Their bytes ARE inside the `melodias` range, so the budget balances.
The seventeen sounds are ALL the ones the cartridge asks for: the two calls that
do not carry the number right in front were resolved by hand and come out as
0x99 and 0x02, which were already counted. So nothing asks for those three
strips. ASSUMPTION: they are sounds that went unused. The fourth stretch,
0x710E-0x7116, is the tail of the strip next to it, which the walk cuts at the
0xFF.

## 7. Exactly what each bit of 0xE201 does

Bits 0, 6 and 7 of the high jump are clear from the code that reads them. The
two lower ones are used as a phase count and are commented where they are used,
but without a single name.
