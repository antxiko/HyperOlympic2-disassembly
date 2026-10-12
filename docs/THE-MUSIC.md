# The music

Everything you hear here comes from running the cartridge's own sound engine (`MUEVE_EL_SONIDO`, 0x6C56, and `PIDE_UN_SONIDO`, 0x6BCE, which hands it the channels; the interrupt calls it at 0x404C) on an emulated Z80, frame by frame at 60 per second, just as the game calls it. What the engine writes to the PSG is turned into sound with an AY-3-8910 (`tools/musica.py`). Each MP3 is the whole piece up to where it starts again, plus 8 seconds of the repeat fading out; those that do not repeat end where the engine ends.

## Checked against openMSX

The PSG writes have been compared frame by frame with those of openMSX (C-BIOS MSX1 japonés). In every frame the PSG ends up the same:

- the title tune (0x9F), whole, 275 frames;
- the long track 0x88, whole, 1,794 frames, with its repeat.

The timbre is not checked: it is a textbook AY-3-8910, not a recording of the emulator. The probes are `tools/omsx_psg.tcl` and `tools/coteja_psg.py`.

## How a piece is asked for

`PIDE_UN_SONIDO` takes the number in A and makes no sound in the demo. Effects are below 0x81; from 0x81 to 0x95 music uses two voices and from 0x96 up three. The channel records are at 0xE162, 0xE16D and 0xE178. Tracks 0x88 and 0x90 are in the table but no routine asks for them with an `ld a`. The engine never writes the PSG mixer: start-up leaves it set, and here it starts from that same value, 0xB8. On the first title request the check differs only on channel C, where something earlier was still sounding; on the second it is equal over all 275 frames.

## The tunes

**The title tune** (0x9F)

Asked for by `TITULO_SIN_PARPADEO`; lasts 4.6 s.

<audio controls preload="none" src="audio/musica_9F.mp3?v=6085e1c6"></audio>

**New record** (0x96)

Asked for by `GUARDA_EL_RECORD_NUEVO`; lasts 4.0 s.

<audio controls preload="none" src="audio/musica_96.mp3?v=37ff5580"></audio>

**The new event** (0x99)

Asked for by `SUENA_LA_PRUEBA_NUEVA`; lasts 2.0 s.

<audio controls preload="none" src="audio/musica_99.mp3?v=4f4a6ddd"></audio>

**The end sign** (0x9C)

Asked for by `CARTEL_DE_FIN`; lasts 3.0 s.

<audio controls preload="none" src="audio/musica_9C.mp3?v=e32c0b05"></audio>

**A long track in the table** (0x88)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 29.9 s and starts again at second 17.1.

<audio controls preload="none" src="audio/musica_88.mp3?v=9d241414"></audio>

**Another track in the table** (0x90)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 8.5 s and starts again at second 4.3.

<audio controls preload="none" src="audio/musica_90.mp3?v=1e36a5c0"></audio>
