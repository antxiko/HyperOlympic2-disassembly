# Hyper Olympic 2 (Konami, RC-711) — what the binary says

Everything here comes from reading the cartridge or from measuring it in
openMSX. Anything that is a guess is labelled ASSUMPTION.

## 1. The four events

0xE016 runs from 1 to 4 and 0xE015 counts twelve rounds. Photographed one by one
(`medidas/pruebas.txt`):

    1  110 HURDLERS       record 12 SEC 93
    2  JAVELIN THROW      record 96 M 72
    3  HIGH JUMP          record 02 M 36
    4  1500 METER         record 03 min 31

Just as in the sibling cartridge, the fourth reuses the scenery (0x655A) and the
scoreboard (0x67C0) of the first, and only the label on the board changes.

## 2. "110 HURDLERS": the typo is in the ROM

The first event's label does not say HURDLES but HURDLERS. It is not the
capture: the glyph string at 0x64B1 is 0A 01 01 00 0A 12 1E 1B 0E 16 0F 1B 1C
0A, and in the cartridge's font (0x6197) those indices read " 110 HURDLERS ".

## 3. The records are real, but three of the four had already been beaten

MEASURED in the binary: 0x517B holds `00 12 93 / 00 96 72 / 00 02 36 /
00 03 31`, which INIT copies to 0xE040. That is 12.93 s in the 110 hurdles,
96.72 m in the javelin, 2.36 m in the high jump and 3:31 in the 1500 m.

All four are genuine world records. What is **not** true is that they were the
standing records when the cartridge came out, which is what this page used to
say:

| event | the cartridge | from when | still standing in 1984? |
|---|---|---|---|
| 110 hurdles | 12.93 | Renaldo Nehemiah, Zurich, August 1981 | yes, and until 1989 |
| javelin | 96.72 | Ferenc Paragi, 1980 | **no**: Tom Petranoff threw 99.72 in May 1983 |
| high jump | 2.36 | the mark before Zhu Jianhua's 2.37 | **no**: Zhu Jianhua cleared 2.37 on 11 June 1983 |
| 1500 m | 3:31 | Steve Ovett, 3:31.36, August 1980 | **no**: Ovett himself took it to 3:30.77 in September 1983 |

**Three of the four expired in 1983**, and the one that holds is the oldest of
them all. Together with what happens in the sibling cartridge, that says **the
record table of both was compiled before the 1983 season**, even though the
cartridges were sold in 1984.

The dates do not come from the cartridge but from the published record
progressions: they are given as what they are, an outside cross-check. What
comes from the cartridge is the figure.

## 4. It is the same program as Hyper Olympic 1, with the events swapped

Lining both ROMs up instruction by instruction —with the sixteen-bit operands
zeroed, so the addresses do not get in the way— 4,195 of Hyper Olympic 1's 5,032
instructions turn up here too: 83.4 %. Counted in normalised bytes, 6,298 out of
9,872, that is 63.8 % of this cartridge.

What does NOT come from the sibling is 1,519 bytes of code, and they are nearly
all in four places: the hurdle jump (0x5A1B), the javelin motor (0x682A), the
high jump one (0x6A66) and drawing the hurdle as a double actor (0x7AAE).

## 5. The hurdle is drawn on TWO sheets

A normal actor assembles its figure at 0xE230 and uploads it in one go. The
hurdle does not fit in one row: 0x7AB3 assembles the top half at 0xE230 and the
bottom half at 0xE270, and uploads them separately, each to its own row of the
name table. It is the only actor in the cartridge that does this.

## 6. Knocking a hurdle over is one bit

While the athlete is jumping (pose 13, ten frames counted at 0x5A34), 0x5A5B
compares his column with the column of the hurdle that is his. If when the jump
ends they are less than eight columns apart, bit 4 of 0xE028 or 0xE029 gets set
and the athlete falls: 0x5AA5 gives him pose 14, wipes his four speed bytes and
gives him 0x14 frames of getting back up.

## 7. Six sprites fewer than the sibling

0x4389 uploads 26 rows of the attribute table (`ld bc,01AFEh`); in Hyper Olympic
1 the same routine uploaded 32. The pose table is shorter too: 18 entries
against 25.

## 8. The font ran out of X and Z, and the Q arrived late

The 51 glyphs at 0x6197 are in order: 0..9, the space, and then the alphabet
**from A to Y skipping Q, X and Z**. With A at index 0x0B, P falls at 0x1A and
the next one, at 0x1B, is already R.

And yet **the Q exists**. It sits at the end, at index **0x2C**, outside the
alphabet, and the reason is the one word in the game that needs it: the
scoreboard's **QUALIFY**, which at 0x611E is the string `2C 1E 0B 16 13 10 21`.

X and Z do not turn up: no word in the cartridge uses them.

The whole sheet is in `docs/imagenes/fuente.png`, drawn by `tools/graficos.py`
reading the range the listing declares.

## 9. What it shares with the sibling cartridge

Byte for byte, with nothing normalised: the whole font (408 bytes, the same 51
glyphs with no Q, no X and no Z), the eight VDP registers, and the twelve dead
bytes at 0x4E64, which nobody reads here either.

## 10. Konami's hidden mark is NOT there

The trick Manuel Pazos uncovered —the RC-7xx code and the title in katakana
hidden behind the filler at the end of the ROM— does not show up: the last two
bytes are 0xFF and in front of them there is sound player code. It was checked
with `tools/marca_konami.py`, which in the same run DOES find it in Pippols.

## 11. The clock was worked out for 60 Hz

The routine that counts the time (0x56D7) is the same one as the sibling
cartridge's and adds 1.665 hundredths per frame. It was measured over there: on
a 50 Hz MSX the game clock advances 0.8325 seconds per real second, and on a
60 Hz one 0.9990.

## 12. Which Konami family it belongs to

### The method

`tools/comun_normalizado.py`: it traces both ROMs with their existing
disassemblies, decodes the instructions, zeroes the sixteen-bit operands —which
are the ones carrying addresses— and looks for common runs. That way a routine
reassembled somewhere else DOES show up. Control: Frogger against Time Pilot,
already known to share a sound player, gives 667 bytes in 15 runs.

### The figures

    against               bytes in common   % of Hyper Olympic 2   longest run
    -------------------   ---------------   --------------------   -----------
    Hyper Olympic 1                 6,298                 63.8 %        63 B
    Frogger                           175                  1.8 %        21 B
    Super Cobra                       173                  1.8 %        21 B
    Konami's Billiards                105                  1.1 %        23 B
    Monkey Academy                     83                  0.8 %        20 B
    Athletic Land                      78                  0.8 %        20 B
    Pippols                            44                  0.4 %        20 B
    Time Pilot                         21                  0.2 %        21 B

### What comes out of that

The two Hyper Olympics are the same program. With any other Konami MSX cartridge
in the series they share NOTHING: the longest runs are twenty bytes, which is
what two programs from the same house give by coincidence. There is no trace of
Frogger and Time Pilot's sound player, nor of Athletic Land's framework. They
are a THIRD framework, with two members.
