# La música

Todo lo que suena aquí sale de ejecutar el motor de sonido del cartucho (`MUEVE_EL_SONIDO`, 0x6C56, y `PIDE_UN_SONIDO`, 0x6BCE, que le reparte los canales; lo llama la interrupción en 0x404C) en un Z80 emulado, cuadro a cuadro y a 60 por segundo, igual que lo llama el juego. Lo que el motor escribe en el PSG pasa a sonido con un AY-3-8910 (`tools/musica.py`). Cada MP3 es la pieza entera hasta donde vuelve a empezar, más 8 segundos de la vuelta apagándose; las que no se repiten acaban donde acaba el motor.

## Cotejado con openMSX

Las escrituras al PSG se han comparado cuadro a cuadro con las de openMSX (C-BIOS MSX1 japonés). En todos los cuadros el PSG queda igual:

- la música del título (0x9F) entera, 275 cuadros;
- la pista larga 0x88 entera, 1.794 cuadros, con su vuelta.

El timbre no está cotejado: es el de un AY-3-8910 de manual, no una grabación del emulador. Las sondas están en `tools/omsx_psg.tcl` y `tools/coteja_psg.py`.

## Cómo se pide una pieza

`PIDE_UN_SONIDO` recibe el número en A y no suena en la demo. Los efectos van por debajo de 0x81; de 0x81 a 0x95 la música usa dos voces y del 0x96 en adelante tres. Las fichas de los canales están en 0xE162, 0xE16D y 0xE178. Las 0x88 y 0x90 son pistas de la tabla que ninguna rutina pide con un `ld a`. El motor no escribe el mezclador del PSG: lo deja el arranque, y aquí se parte de su mismo valor, 0xB8. En la primera petición del título el cotejo difiere solo en el canal C, donde aún sonaba algo anterior; en la segunda es igual en los 275 cuadros.

## Las músicas

**La música del título** (0x9F)

Lo pide `TITULO_SIN_PARPADEO`; dura 4,6 s.

<audio controls preload="none" src="../audio/musica_9F.mp3?v=6085e1c6"></audio>

**Récord nuevo** (0x96)

Lo pide `GUARDA_EL_RECORD_NUEVO`; dura 4,0 s.

<audio controls preload="none" src="../audio/musica_96.mp3?v=37ff5580"></audio>

**La prueba nueva** (0x99)

Lo pide `SUENA_LA_PRUEBA_NUEVA`; dura 2,0 s.

<audio controls preload="none" src="../audio/musica_99.mp3?v=4f4a6ddd"></audio>

**El cartel de fin** (0x9C)

Lo pide `CARTEL_DE_FIN`; dura 3,0 s.

<audio controls preload="none" src="../audio/musica_9C.mp3?v=e32c0b05"></audio>

**Una pista larga de la tabla** (0x88)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 29,9 s y vuelve a empezar en el segundo 17,1.

<audio controls preload="none" src="../audio/musica_88.mp3?v=9d241414"></audio>

**Otra pista de la tabla** (0x90)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 8,5 s y vuelve a empezar en el segundo 4,3.

<audio controls preload="none" src="../audio/musica_90.mp3?v=1e36a5c0"></audio>
