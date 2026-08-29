# In the emulator

Reading the binary tells you what the code **does**. Some things only tell you
what the code is **worth** once it runs, and that is what openMSX is for.
Everything on this page is measured, and the raw tables are in `medidas/`.

## The house rule

The scripts in `tools/omsx_*.tcl` **only read memory**. The ROM is never
touched: no patches, no changed bytes, nothing forced to execute.

The one exception is declared and is a measurement, not a modification:
`tools/omsx_prueba_n.tcl` stops the machine at 0x422E —right after 0x4216 sets
the round and the event to 1— and writes into 0xE016 the number of the event you
want to see. 0xE016 is the game's own variable, and from there on the cartridge
runs by itself, with its data and its code. What you save is having to qualify
in the three previous events to reach the fourth.

## The four events

With that, they were photographed one by one (`medidas/pruebas.txt`, captures in
`docs/imagenes/`):

| 0xE016 | label that comes up | record it paints |
|---|---|---|
| 1 | 110 HURDLERS | 12 SEC 93 |
| 2 | JAVELIN THROW | 96 M 72 |
| 3 | HIGH JUMP | 02 M 36 |
| 4 | 1500 METER | 03 min 31 |

All four records match byte for byte the table at 0x517B, which INIT copies to
0xE040: `00 12 93 / 00 96 72 / 00 02 36 / 00 03 31`. So what is on screen and
what the binary says are the same thing, checked from both ends.

## The capture confirms the typo, but it is not the proof

On the first event's screen you can read **110 HURDLERS**, with an extra R. A
capture on its own would prove nothing: it could be the emulator, the crop or
the resolution.

The proof is in the data. The `rotulo_110_vallas` label starts at 0x64B1, and
behind its header byte it carries the glyph string

```
0A 01 01 00 0A 12 1E 1B 0E 16 0F 1B 1C 0A
```

and in the cartridge's font (0x6197) those indices read ` 110 HURDLERS `. The
typo is written into the ROM. The capture only shows the result.

## The clock was worked out for 60 Hz

`SUMA_AL_RELOJ` (0x56D7) adds to the BCD counter at 0xE0A9-0xE0AB once per
frame, alternating 0x0167 and 0x0166. If the top byte is seconds and the middle
one hundredths, that is 1.67 and 1.66 hundredths: an average of **1.665**, which
is one sixtieth of a second to four figures.

It is **the same routine** as the sibling cartridge's, and over there it is
measured by running the event mashing the space bar and sampling the counter
once per emulated second:

| machine | Hz | game clock per real second |
|---|---|---|
| Philips VG-8020 (PAL) | 50 | **0.8325 s** — runs 16.75 % short |
| C-BIOS MSX1 JP (NTSC) | 60 | 0.9990 s — spot on |

Both figures agree with the arithmetic: 50 × 1.665 = 83.25 and 60 × 1.665 =
99.9.

**The consequence:** on a European MSX the times the cartridge shows are not
seconds. A 110 hurdles timed at 13.00 by the game took 15.6 real seconds. The
qualifying marks at 0x500A and the world records at 0x517B are meant for the
Japanese machine.

**And mind reading it backwards.** That is a *period*, not a *speed*: the game
does not run slower in Europe —the athlete moves across the screen at whatever
speed 50 Hz allows— what happens is that **the stopwatch counts short**. Those
are two different claims and only one of them is measured.

## The menu

Four lines, the same as in the sibling cartridge: one player or two, and
joystick or keyboard. Whichever you pick leaves a number from 1 to 4 in 0xE01B,
and from that come the number of players (0xE010) and the controller (0xE004).

## How to repeat it

```sh
PRUEBA=3 openmsx -machine Philips_VG_8020 -cart hyperolympic2.rom \
        -script tools/omsx_prueba_n.tcl
openmsx -machine Philips_VG_8020 -cart hyperolympic2.rom \
        -script tools/omsx_pruebas.tcl
```

The second one takes all four captures in a single pass, and the title one too.
The tables and PNGs that come out land in `work/omsx/`. The ones in `medidas/`
and `docs/imagenes/` are the ones this page was written from.
