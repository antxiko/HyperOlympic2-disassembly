# Hyper Olympic 2 (Konami, RC-711) — commented disassembly

A commented disassembly of the 16 KB MSX cartridge, reproducible byte for byte.

**[Read the write-up →](https://antxiko.github.io/HyperOlympic2-disassembly/)**
· [En castellano](README.es.md)

    make            # trace, generate the listing, reassemble it and run the tests
    make verify     # the test that decides: reassembling has to give the ROM back
    make sanity     # that not one byte is left unexplained
    make densidad   # how much is commented, routine by routine
    make web        # rebuild the website

The ROM is **not distributed here**. It goes in the root as `hyperolympic2.rom`,
16384 bytes, sha256

    f254764f4bd1634f50abcdabe5813d133d719197216071772845983ffabad22d

`make comprueba` checks it.

## Where it stands

| | |
|---|---|
| reassembles byte for byte | yes |
| bytes explained | 16,384 of 16,384 (100 %) |
| traced code | 9,872 bytes, 5,345 instructions |
| identified data | 6,512 bytes in 98 named ranges |
| commented | 1,599 line comments, 29.9 % |
| thin routines (under 10 %) | 0 of 647 |

The annotations live apart from the listing, anchored to the address they
describe. What the `.notes` file holds:

| | |
|---|---|
| named labels | 647 |
| anchored comments | 1.586 |
| explained data ranges | 98 |

## It is the same program as Hyper Olympic 1

Two thirds of the code is shared. The annotations for the shared code come
ported from the sibling cartridge with `tools/porta_notas.py`, which lines both
ROMs up instruction by instruction with the sixteen-bit operands zeroed. The
1,519 bytes that do not come from there —the hurdle jump, the javelin, the high
jump and drawing the hurdle— were read here. The data blocks were NOT ported:
they were located again by walking the scripts.

Porting a comment puts it at the right address without changing what it says, so
two guards watch it and both caught something real:
`tools/repasa_el_porte.py` found nine cited addresses that do not exist here and
a block heading naming the sibling's event, and `tools/cifras_portadas.py` found
two comments that said "32 sprites" where this cartridge loads 26.

## What is in here

- `src/hyperolympic2.asm` — the listing; generated, not hand-edited
- `src/hyperolympic2.notes` — the annotations, anchored to addresses
- `src/hyperolympic2.entries` — the entry points, each one justified
- `docs/` — the website, in English and Spanish
- `medidas/` — what was measured in openMSX
- `tools/` — the tracer, the listing generator, the data walkers and the
  annotation porter

## The write-up

| | |
|---|---|
| [Getting started](docs/GETTING-STARTED.md) | what you need and what each command does |
| [The game](docs/THE-GAME.md) | four events, twelve rounds, and one you can knock over |
| [The cartridge](docs/THE-CARTRIDGE.md) | the header, the memory map and the screen |
| [The code](docs/THE-CODE.md) | how the program is put together, and what came from the sibling |
| [Findings](docs/FINDINGS.md) | what the binary says |
| [In the emulator](docs/IN-THE-EMULATOR.md) | what was measured, and how to repeat it |
| [Open questions](docs/OPEN-QUESTIONS.md) | what is still not settled |
| [Hyper Olympic vs Track & Field](docs/COMPARISON-TRACK-AND-FIELD.md) | the two builds of this cartridge, compared |

See `LEGAL-NOTICE.md`.
