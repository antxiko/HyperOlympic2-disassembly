# En el emulador

Leer el binario dice lo que el código **hace**. Hay cosas que solo dicen lo que
el código **vale** cuando corre, y para ésas está openMSX. Todo lo de esta
página está medido, y las tablas en crudo están en `medidas/`.

## La regla de la casa

Los guiones de `tools/omsx_*.tcl` **solo leen memoria**. La ROM no se toca en
ningún caso: no hay parches, ni bytes cambiados, ni ejecución forzada de nada.

La única excepción está declarada y es una medida, no una modificación:
`tools/omsx_prueba_n.tcl` para la máquina en 0x422E —justo después de que 0x4216
ponga la ronda y la prueba a 1— y escribe en 0xE016 el número de la prueba que
se quiere ver. 0xE016 es una variable del propio juego, y de ahí en adelante
corre el cartucho solo, con sus datos y su código. Lo que se ahorra es tener que
clasificarse en las tres pruebas anteriores para llegar a la cuarta.

## Las cuatro pruebas

Con eso se fotografiaron una a una (`medidas/pruebas.txt`, capturas en
`docs/imagenes/`):

| 0xE016 | rótulo que sale | récord que pinta |
|---|---|---|
| 1 | 110 HURDLERS | 12 SEC 93 |
| 2 | JAVELIN THROW | 96 M 72 |
| 3 | HIGH JUMP | 02 M 36 |
| 4 | 1500 METER | 03 min 31 |

Los cuatro récords coinciden byte a byte con la tabla de 0x517B, que INIT copia
a 0xE040: `00 12 93 / 00 96 72 / 00 02 36 / 00 03 31`. O sea que lo que se ve en
pantalla y lo que dice el binario son lo mismo, comprobado por los dos lados.

## La captura confirma la errata, pero no es la prueba

En la pantalla de la primera prueba se lee **110 HURDLERS**, con una R de más.
Una captura sola no demostraría nada: podría ser cosa del emulador, del
recorte o de la resolución.

La prueba está en los datos. El rótulo `rotulo_110_vallas` empieza en 0x64B1,
y detrás de su byte de cabecera lleva la tira de glifos

```
0A 01 01 00 0A 12 1E 1B 0E 16 0F 1B 1C 0A
```

y en la fuente del cartucho (0x6197) esos índices son ` 110 HURDLERS `. La
errata está escrita en la ROM. La captura solo enseña el resultado.

## El reloj está calculado para 60 Hz

`SUMA_AL_RELOJ` (0x56D7) suma al contador BCD de 0xE0A9-0xE0AB una vez por
cuadro, alternando 0x0167 y 0x0166. Si el byte de arriba son segundos y el de en
medio centésimas, eso es 1,67 y 1,66 centésimas: media **1,665**, que es un
sesentavo de segundo con cuatro cifras.

Es **la misma rutina** que la del cartucho hermano, y allí está medida corriendo
la prueba con el botón apretado y muestreando el contador una vez por segundo
emulado:

| máquina | Hz | reloj del juego por segundo real |
|---|---|---|
| Philips VG-8020 (PAL) | 50 | **0,8325 s** — se queda un 16,75 % corto |
| C-BIOS MSX1 JP (NTSC) | 60 | 0,9990 s — clavado |

Las dos cifras coinciden con la cuenta: 50 × 1,665 = 83,25 y 60 × 1,665 = 99,9.

**La consecuencia:** en un MSX europeo los tiempos que enseña el cartucho no son
segundos. Unas 110 vallas cronometradas en 13,00 por el juego han durado 15,6
segundos de verdad. Las marcas de clasificación de 0x500A y los récords del
mundo de 0x517B están pensados para la máquina japonesa.

**Y cuidado con leerlo al revés.** Eso es un *periodo*, no una *velocidad*: el
juego no va más despacio en Europa —el atleta corre a la velocidad de pantalla
que le permitan los 50 Hz—, lo que pasa es que **el cronómetro cuenta corto**.
Son dos afirmaciones distintas y solo una está medida.

## El menú

Cuatro líneas, las mismas que en el cartucho hermano: un jugador o dos, y
joystick o teclado. La que se elija deja en 0xE01B un número del 1 al 4, y de
ahí salen el número de jugadores (0xE010) y el mando (0xE004).

## Cómo repetirlo

```sh
PRUEBA=3 openmsx -machine Philips_VG_8020 -cart hyperolympic2.rom \
        -script tools/omsx_prueba_n.tcl
openmsx -machine Philips_VG_8020 -cart hyperolympic2.rom \
        -script tools/omsx_pruebas.tcl
```

El segundo hace las cuatro capturas de una pasada, y también la del título. Las
tablas y los PNG que salen se quedan en `work/omsx/`. Los que están en
`medidas/` y en `docs/imagenes/` son los que se usaron para escribir esto.
