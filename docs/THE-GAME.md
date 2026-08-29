# The game

Hyper Olympic 2 is the second MSX helping of Konami's athletics: four new events
on top of the same program as the first. It plays the same way, hammering two
keys to run and one to jump or throw.

## Four events, twelve rounds

`0xE016` runs from 1 to 4 and picks the event; `0xE015` counts up to twelve. So
**the four events, three times each**. Photographed one by one in the emulator
(`medidas/pruebas.txt`):

| | event | record it shows |
|---|---|---|
| 1 | 110 HURDLERS | 12 SEC 93 |
| 2 | JAVELIN THROW | 96 M 72 |
| 3 | HIGH JUMP | 02 M 36 |
| 4 | 1500 METER | 03 min 31 |

**Yes, it says HURDLERS.** It is not the capture and it is not the emulation:
the typo is in the cartridge's data, and it can be read byte by byte. It is
written up in [Findings](FINDINGS.md).

Just as in the sibling cartridge, the fourth event is built on top of the first:
the 110 hurdles and the 1500 metres share their scenery list (0x655A) and their
scoreboard, and the javelin and the high jump share theirs (0x661F). Four events
with two sets of screens.

## You have to qualify

Every round has a mark to beat, and they live in `marcas_de_clasificacion`
(0x500A): two BCD bytes per round, which 0x4651 reads with `2*(round-1)`. They
come out as

```
15.00  75.00  02.30  04.30
13.00  85.00  02.35  04.00
11.00  90.00  02.40  03.30
```

Each lap tightens the screw: in the hurdles you have to get under 15, then under
13, then under 11; in the javelin, past 75, 85 and 90 metres; in the high jump,
2.30, 2.35 and 2.40; and in the 1500, under 4:30, 4:00 and 3:30.

Fail to qualify and that is that. `0xE021` carries one bit per player saying
whether they are still in, and `0xE022` who goes through to the next round.

## The hurdles: the only event you can knock over

The 110 hurdles is a normal race with one thing on top, and it takes very little
code (0x5A1B). While the athlete runs, bit 1 of `0xE0C5` asks to jump. The jump
lasts **ten frames**, counted at 0x5A34, and while it lasts the pose is 13; when
it ends it goes back to 6.

And then it is checked: 0x5A5B compares the athlete's column with the column of
the hurdle that is his, and **if when the jump ends they are less than eight
columns apart**, bit 4 of `0xE028` or `0xE029` gets set. That bit is the fall.
0x5AA5 gives him pose 14, wipes his four speed bytes and gives him 0x14 frames
of getting back up.

So knocking a hurdle over is not a collision: it is a comparison of columns at
one specific instant.

## The attempts

In the javelin and the high jump there is not one run and done: there are four
attempts. `0xE023`/`0xE024` count the ones used up per player and
`0xE025`/`0xE026` the one under way. Each result goes in `0xE02A`/`0xE02B`:
**1 foul, 2 valid, 3 record**.

When an attempt does not count, the scoreboard writes the foul label
(`rotulo_de_fallo`, 0x5140), and two different places ask for it: 0x4379 and
0x4521.

## The clock lies in Europe

The routine that counts the time (0x56D7) adds **1.665 hundredths per frame**,
that is, one sixtieth of a second. It was worked out for a 60 Hz machine.

It is the same routine as the sibling cartridge's, and over there it is measured
on both machines:

| machine | Hz | game clock per real second |
|---|---|---|
| Philips VG-8020 (PAL) | 50 | **0.8325 s** |
| C-BIOS MSX1 JP (NTSC) | 60 | 0.9990 s |

On a European MSX, **a "13.00" in the hurdles is really 15.6 seconds**. And it
is not that the game runs slow: it is that the clock counts short. The
qualifying marks and the world records are meant for the Japanese machine.

Careful reading that backwards: it is a **period**, not a **speed**. The detail
is in [In the emulator](IN-THE-EMULATOR.md).

## Two players, alternating frames

`0xE010` says whether two are playing and `0xE011` whose turn it is. When both
run at once, the race motor looks at bit 0 of the frame counter: **on even
frames it moves player 1's athlete and on odd ones player 2's**. Half the work
per frame, and at 50 or 60 Hz nobody notices.

## Six sprites fewer than the sibling

A measured detail that says a fair bit about how this cartridge was made: 0x4389
uploads **26 rows** of the sprite attribute table (`ld bc,01AFEh`); in Hyper
Olympic 1 the same routine uploaded 32.

And the pose table is shorter too: **eighteen** entries (`posturas_del_atleta`,
0x713C) against the twenty-five over there. These events need fewer figures.

## The demo plays itself, and plays badly

When nobody touches anything a demo starts. It does not carry a recorded game:
**the interrupt plays it**, and the pilot is about as dumb as you can write.
With `0xE002` at 1, the interrupt drops into `0xE00B` a value from `ld a,r` —the
memory refresh register— masked to two bits, once every four frames. That is all
of it: **random keypresses**.

## The controls

`0xE004` says whether you play with joystick or keyboard, and `0xE005` carries
what was read this frame: bit 0 up, bit 1 down, bit 4 space, bit 5 F5. With a
joystick, the two buttons. For each player **both the previous and the current
controls** are kept (0xE008-0xE00F), which is how you detect an edge rather than
a held key — indispensable in a game built on mashing one.
