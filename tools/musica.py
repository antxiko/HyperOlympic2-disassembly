#!/usr/bin/env python3
"""La musica del cartucho, ejecutando su motor de sonido (ver motor_musica.py).

Pide el sonido con `PIDE_UN_SONIDO` (0x6BCE, A = numero; no suena en la demo) y
corre `MUEVE_EL_SONIDO` (0x6C56), que la interrupcion llama cada cuadro (0x404C).
Los tres canales son tres fichas de 11 bytes desde 0xE162.
Uso:  musica.py registros 0x9F [cuadros] | mp3 0x9F f.mp3 | todas docs/audio
      musica.py barrido 0x80 0xFF | emu
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import motor_musica  # noqa: E402
from motor_musica import P  # noqa: E402

PIEZAS = [
    P(0x9F, "La música del título", "The title tune",
      "`TITULO_SIN_PARPADEO`"),
    P(0x96, "Récord nuevo", "New record", "`GUARDA_EL_RECORD_NUEVO`"),
    P(0x99, "La prueba nueva", "The new event", "`SUENA_LA_PRUEBA_NUEVA`"),
    P(0x9C, "El cartel de fin", "The end sign", "`CARTEL_DE_FIN`"),
    P(0x88, "Una pista larga de la tabla", "A long track in the table",
      "ninguna llamada directa: está en la tabla de pistas"),
    P(0x90, "Otra pista de la tabla", "Another track in the table",
      "ninguna llamada directa: está en la tabla de pistas"),
]

PAGINA = motor_musica.pagina_basica(
    "`MUEVE_EL_SONIDO`, 0x6C56, y `PIDE_UN_SONIDO`, 0x6BCE, que le reparte "
    "los canales; lo llama la interrupción en 0x404C",
    "`MUEVE_EL_SONIDO`, 0x6C56, and `PIDE_UN_SONIDO`, 0x6BCE, which hands it "
    "the channels; the interrupt calls it at 0x404C",
    "C-BIOS MSX1 japonés",
    [("la música del título (0x9F) entera, 275 cuadros",
      "the title tune (0x9F), whole, 275 frames"),
     ("la pista larga 0x88 entera, 1.794 cuadros, con su vuelta",
      "the long track 0x88, whole, 1,794 frames, with its repeat")],
    [("Cómo se pide una pieza",
      "`PIDE_UN_SONIDO` recibe el número en A y no suena en la demo. Los "
      "efectos van por debajo de 0x81; de 0x81 a 0x95 la música usa dos voces "
      "y del 0x96 en adelante tres. Las fichas de los canales están en "
      "0xE162, 0xE16D y 0xE178. Las 0x88 y 0x90 son pistas de la tabla que "
      "ninguna rutina pide con un `ld a`. El motor no escribe el mezclador "
      "del PSG: lo deja el arranque, y aquí se parte de su mismo valor, 0xB8. "
      "En la primera petición del título el cotejo difiere solo en el canal "
      "C, donde aún sonaba algo anterior; en la segunda es igual en los 275 "
      "cuadros.",
      "How a piece is asked for",
      "`PIDE_UN_SONIDO` takes the number in A and makes no sound in the demo. "
      "Effects are below 0x81; from 0x81 to 0x95 music uses two voices and "
      "from 0x96 up three. The channel records are at 0xE162, 0xE16D and "
      "0xE178. Tracks 0x88 and 0x90 are in the table but no routine asks for "
      "them with an `ld a`. The engine never writes the PSG mixer: start-up "
      "leaves it set, and here it starts from that same value, 0xB8. On the "
      "first title request the check differs only on channel C, where "
      "something earlier was still sounding; on the second it is equal over "
      "all 275 frames.")])

CFG = dict(rom="hyperolympic2.rom", org=0x4000, frame=0x6C56, pide=0x6BCE,
           ram=(0xE162, 0xE184), hz=60, psg0={7: 0xB8}, piezas=PIEZAS,
           pagina=PAGINA, cotejado=[(0x9F, 275, None), (0x88, 1794, 1025)])

if __name__ == "__main__":
    sys.exit(motor_musica.main(CFG, sys.argv[1:]))
