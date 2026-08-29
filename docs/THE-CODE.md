# The code

Sixteen kilobytes split into 9,872 bytes of code and 6,512 of data. There is no
bank switching and no loading trick: the whole program is in plain sight between
0x4000 and 0x7FFF.

And there is one thing worth knowing before reading any of it: **this cartridge
is, for the most part, the same program as Hyper Olympic 1**. Lining both ROMs
up instruction by instruction, 4,195 of that one's 5,032 instructions turn up
here: 83.4 %. What follows holds for both except where it says otherwise.

## Two threads sharing the work

**The interrupt** (`INTERRUPCION`, 0x4010) comes in through the H.KEYI hook that
INIT fills with a `jp`, and does everything that has to run at screen rate: it
reads the controls, moves the sound player, counts the clock and calls the motor
of whichever event is being played. It is where the game happens.

**The main program** carries the state machine: set up the scenery, wait for the
attempt to end, hand out points, move to the next round. Most of the time it is
waiting for the interrupt to set a bit.

## The four motors, and where they come from

This is the interesting part of this cartridge. The four events are new, but
only two of the motors are:

| event | motor | where it comes from |
|---|---|---|
| 110 hurdles and 1500 m | `MOTOR_DE_LA_CARRERA` (0x5187) | the same one as the sibling's races |
| javelin | `MOTOR_DE_LA_JABALINA` (0x680A) | written here, on the jump's mould |
| high jump | `MOTOR_DEL_SALTO_DE_ALTURA` (0x6A2C) | **the hammer motor, reused** |

That third one is the one that says most. The motor that in the sibling
cartridge span the hammer —wind up, mark the angle with the button and let go—
is exactly the one that lifts the high jumper here. What changes is what gets
drawn, not the mechanism.

And there is a fourth piece that is not a motor but behaves like one:
`AVANZA_EL_TIRO` (0x7D2B), which computes the flight. Both the javelin and the
jump use it, and it is the only part of the cartridge that does real arithmetic.

## What this cartridge adds: 1,519 bytes

The bytes of code that do **not** come from the sibling are 1,519, and they are
nearly all in four places:

- **the hurdle jump** (0x5A1B), which is all the 110 hurdles adds to an ordinary
  race;
- **the javelin motor** (0x682A);
- **the high jump one** (0x6A2C);
- **drawing the hurdle as a double actor** (0x7AAE).

Everything else is the sibling.

### The hurdle jump

While the athlete runs, bit 1 of `0xE0C5` asks to jump. The jump lasts ten
frames, counted at 0x5A34, and while it lasts the pose is 13; when it ends, 6.
Then 0x5A5B compares the athlete's column with the column of the hurdle that is
his and, if they are less than eight columns apart, sets bit 4 of `0xE028` or
`0xE029`.

That bit is the fall: 0x5AA5 gives him pose 14, wipes his four speed bytes and
gives him 0x14 frames of getting back up. **Knocking a hurdle over is not a
collision: it is a comparison of columns at one specific instant.**

### The hurdle is drawn on two sheets

A normal actor assembles its figure in the scratch area at 0xE230 and uploads it
in one go. The hurdle does not fit in one row, so 0x7AB3 assembles the top half
at 0xE230 and the bottom half at 0xE270, and uploads them separately, each to
its own row of the name table. It is the only actor in the cartridge that does
this.

## The only real piece of arithmetic

`CALCULA_EL_TIRO` (0x7D38) takes the running speed and the angle and gets from
them the advance and the height for each frame, and finally the mark. For that
there are three arithmetic routines written by hand, because the Z80 brings
none:

- `DIVIDE` (0x7E75), shifting and subtracting;
- `MULTIPLICA` (0x7E93), shifting and adding;
- `PASA_A_BCD` (0x7EB7), which converts a binary number to BCD by doubling it in
  BCD, bit by bit, so that it can be printed.

And the sine comes from a table, `EL_SENO_DEL_ANGULO` (0x7E53): one byte per
degree. No real-time approximations.

## The points

`PUNTUA_EL_INTENTO` (0x4F36) turns the mark into points, and the arithmetic
flips sign depending on the event: the points come from the difference between
the mark and a fixed per-event reference (`marca_de_referencia`, 0x5022). **In
timed events the reference is on top** and the mark is subtracted from it; **in
distance events it is underneath** and the mark is what beats it. Then it is
multiplied by sixteen, and in odd-numbered events doubled once more.

## The cartridge does not store screens: it stores scripts

Not one screen is drawn in the ROM as such. What there is are **scripts**, and
four different interpreters that read them.

**The long script** (`GUION_LARGO`, 0x4CF2) is the big one: a byte with the
number of orders and then the orders, each starting with its type.

| type | what it does |
|---|---|
| 0 | bytes to VRAM, with 0x11 as the run marker (RLE) |
| 1 | strings of font glyphs, uploaded as patterns |
| 2 | large-letter labels |
| 3 | fills of one byte |
| 4+ | repeat an eight-byte pattern N times |

**The short script** (`GUION_CORTO`, 0x4AFD) is for loose text, like the menu's.
**The label** (`LLENA_EL_PAPEL`, 0x4C4C) prepares text that is later stretched
into large letters. And **the figure** (`MONTA_LA_FIGURA`, 0x79A5) expands an
actor's description into character codes.

The scenery lists come in pairs: the hurdles and the 1500 metres share theirs
(0x655A) and the javelin and the high jump the other (0x661F).

## The large letters are manufactured

A large-letter label is not drawn anywhere: it is assembled on the fly.
`MONTA_UN_ROTULO` (0x4C32) copies the **normal** 8x8 glyphs into a scratch area
at 0xE230, and then `ESTIRA_LAS_LETRAS` (0x4C94) makes **three passes** pulling
the top two bits out of each byte and pushing them into the byte eight positions
earlier.

With that, a row of eight glyphs yields four rows of pattern: the letter comes
out twice the size without taking twice the ROM.

## Writing to the VDP without the interrupt stepping on it

There are four routines devoted to this, and they all do the same thing (0x4DE5
and the ones below it).

The problem: setting an address in the VDP is **two consecutive writes** to the
control port, and the interrupt writes to the VDP too. If it slips in between
the two, the address left standing is its own.

The solution is not to forbid the interrupt but to **notice**: clear 0xE01D, set
the address, and look at 0xE01D. If the interrupt went through in the middle it
will have set it, and then you do it again. It is cheaper than disabling and
re-enabling interrupts on every write, and it does not lose a frame.

## The sound player

Three channels, an eleven-byte record each, at 0xE160, 0xE16B and 0xE176:

| offset | what it is |
|---|---|
| +0 | note countdown |
| +1 | base duration |
| +2 | sound number |
| +3/+4 | pointer to the string |
| +5 | octave |
| +6 | decay |
| +7 | volume |
| +8 | decay countdown |
| +9 | repeats left |
| +0x0A | duration |

The interesting part is **the sound number**, which carries information in its
top bits: bit 7 says the note takes a single byte, bit 6 that channel 3 is used
as noise, and **the bottom six are the priority**. A sound does not interrupt
another one of higher priority.

The strings live in `melodias` (0x6EAC): `0xFF` ends and `0xFE` starts over. The
thirty-six pointers are at 0x6E64, and a sound with several voices takes
consecutive entries.

## The actors

An actor is a sixteen-byte record in RAM, and there are four: 0xE120, 0xE130,
0xE140 and 0xE150.

| offset | what it is |
|---|---|
| +0 | flags |
| +1 | counter |
| +2 | step |
| +6 | column within the figure |
| +7/+8 | VRAM address |
| +9/+0A | the record that relieves it |
| +0B | row of the adjustment table |
| +0C | computed column |
| +0D/+0E | the figure |
| +0F | how many characters get painted |

The four records sit **back to back** in memory, and that is where the trick
comes from: bit 2 of the flags makes the actor push the one ahead and bit 3 the
one behind, adding or subtracting 0x11 from the pointer. That is how the scenery
drags itself along in a chain with nobody keeping a list of who pushes whom.

## The athlete is seven sprites

`FICHA_DEL_QUE_JUEGA` (0x7F51) and what sits under it assemble the runner. He is
not a sprite: he is **seven**, and every pose places them by hand. 0x7F85
uploads to VRAM whatever patterns the pose needs, and then it writes the seven
rows of the attribute table, adding to each the row and column the athlete is
at.

There are eighteen poses (0x713C), seven fewer than in the sibling cartridge.

## How to read it

The listing is generated; it is not hand-edited. The comments live apart, in
`src/hyperolympic2.notes`, anchored to the address they describe.

And here there is an extra caution, because **86.9 % of this cartridge's
comments are identical to one in the sibling**: they were ported, and a ported
comment says what the instruction did *over there*. Two guards watch for it, and
both have caught something real:

- `tools/repasa_el_porte.py` checks that every cited address exists here and
  that no annotation names the other one's events. It caught nine addresses and
  a block heading that talked about the hammer.
- `tools/cifras_portadas.py` checks that, when a comment is identical to one in
  the sibling, the instruction it annotates is the same one too. It caught the
  two comments at 0x4389, which said "32 sprites" when here they are 26.

It is written up in detail in [Getting started](GETTING-STARTED.md).
