# Getting started

This repository does not ship the game: it ships the way to build it back from
your own copy and to check that what comes out is exactly the cartridge.

## What you need

Your own dump of the cartridge, in the root and with this name:

| | |
|---|---|
| file | `hyperolympic2.rom` |
| size | 16,384 bytes |
| sha256 | `f254764f4bd1634f50abcdabe5813d133d719197216071772845983ffabad22d` |

Plus `pasmo`, `z80dasm` and Python 3. For the emulator measurements, openMSX.

## The one command that does it all

```sh
make comprueba   # is this the right dump?
make             # trace, generate the listing, reassemble it and run the tests
```

`make` finishes green or it does not finish. The line that matters is this one:

```
  ensamblado : 16384 bytes  f254764f...abad22d
  original   : 16384 bytes  f254764f...abad22d
OK: reproducible byte a byte
```

## The other commands

```sh
make verify     # the test that decides: reassembling has to give the ROM back
make sanity     # what reassembling CANNOT catch
make densidad   # how much is commented, routine by routine
make imagenes   # draw blocks of the ROM so you can look at them
make test       # the listing tests
make web        # rebuild this website
```

## Why `verify` is not enough

Reassembling and getting the same bytes proves the listing is **faithful**, not
that it is **correct**. If some graphics were being read as instructions the
bytes would come out identical all the same: the only thing lying would be the
listing.

That is why `make sanity` runs three more checks, and those three are the ones
that really earn their keep:

- **no byte declared as data may come out as code**, and the other way round;
- **no entry point may fall inside a data area**;
- **not one byte of the cartridge left unassigned** — the budget has to add up
  to 16,384, split between code the tracer actually reaches and data ranges with
  a name and an explanation.

## And a fourth, which matters here more than anywhere

**No annotation may cite an address from the sibling cartridge, or name its
events.**

This cartridge and Hyper Olympic 1 are nearly the same program: 83.4 % of that
one's instructions turn up here. Making use of that is the sensible thing to do,
and the annotations for the shared code are brought over with
`tools/porta_notas.py`, which lines both ROMs up instruction by instruction with
the sixteen-bit operands zeroed. But that puts each comment at the right address
**without changing what it says**: a comment that is true over there can be a
lie here.

`tools/repasa_el_porte.py` is the guard. The rule is exact and has no heuristic:
every address cited inside a comment —or inside a page of this website— has to
be the start of an instruction or fall in a data range **of this cartridge**,
and no annotation may name the other one's events. It forgives three things,
each with its reason written into the code: the zero slots of the tables indexed
from one, sentences that are deliberately comparing with the sibling, and the
two comparison pages, whose subject is precisely the other binary.

It is not a decorative guard. It caught nine cited addresses that do not exist
here —six off by one byte and three pointing at a different routine— and a block
heading that still titled the flight with the name of the sibling's event, the
hammer, which this cartridge does not have.

And there is a second guard, `tools/cifras_portadas.py`, which watches what the
first one cannot see: if a comment is identical to one in the sibling, the
instruction it annotates has to be the same too, once the sixteen-bit operands
are zeroed. It caught the two comments at 0x4389, which said "32 sprites" when
the `ld bc,01afeh` here loads 26.

## What is inside

| | |
|---|---|
| `src/hyperolympic2.asm` | the listing; generated, not hand-edited |
| `src/hyperolympic2.notes` | the annotations, anchored to addresses |
| `src/hyperolympic2.entries` | the entry points, each one justified |
| `src/hyperolympic2.nocode` | the areas the tracer is forbidden to enter |
| `medidas/` | what was measured in openMSX, with the raw tables |
| `tools/` | the tracer, the listing generator and the data walkers |
| `docs/` | this website |

The comments live **apart** from the listing, anchored to the address they
describe. That way they survive a re-trace: if tomorrow the tracer splits the
binary differently, the comments still land where they belong.

## What is not here

The cartridge image. Neither this one nor any other: it belongs to Konami and is
not distributed. See [LEGAL-NOTICE.md](../LEGAL-NOTICE.md).
