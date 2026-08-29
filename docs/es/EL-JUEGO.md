# El juego

Hyper Olympic 2 es la segunda entrega para MSX del atletismo de Konami: cuatro
pruebas nuevas sobre el mismo programa que la primera. Se juega igual, aporreando
dos teclas para correr y una para saltar o lanzar.

## Cuatro pruebas, doce rondas

`0xE016` va de 1 a 4 y elige la prueba; `0xE015` cuenta hasta doce. O sea **las
cuatro pruebas, tres veces**. Fotografiadas una a una en el emulador
(`medidas/pruebas.txt`):

| | prueba | récord que enseña |
|---|---|---|
| 1 | 110 HURDLERS | 12 SEC 93 |
| 2 | JAVELIN THROW | 96 M 72 |
| 3 | HIGH JUMP | 02 M 36 |
| 4 | 1500 METER | 03 min 31 |

**Sí, pone HURDLERS.** No es cosa de la captura ni de la emulación: la errata
está en los datos del cartucho, y se puede leer byte a byte. Está contado en
[Hallazgos](HALLAZGOS.md).

Igual que en el cartucho hermano, la cuarta prueba se monta encima de la
primera: las 110 vallas y los 1500 metros comparten la lista de decorados
(0x655A) y el marcador, y la jabalina y el salto de altura comparten la suya
(0x661F). Cuatro pruebas con dos juegos de pantallas.

## Hay que clasificarse

Cada ronda tiene una marca que batir, y están en `marcas_de_clasificacion`
(0x500A): dos bytes en BCD por ronda, que 0x4651 lee con `2*(ronda-1)`. Salen

```
15.00  75.00  02.30  04.30
13.00  85.00  02.35  04.00
11.00  90.00  02.40  03.30
```

Cada vuelta aprieta: en las vallas hay que bajar de 15, luego de 13, luego de
11; en jabalina pasar de 75, 85 y 90 metros; en altura de 2,30, 2,35 y 2,40; y
en los 1500, bajar de 4:30, de 4:00 y de 3:30.

Si no te clasificas, se acabó. `0xE021` lleva un bit por jugador diciendo si
sigue en juego, y `0xE022` quién pasa a la ronda siguiente.

## Las vallas: la única prueba que se puede tirar

Las 110 vallas son una carrera normal con una cosa encima, y ocupa muy poco
código (0x5A1B). Mientras el atleta corre, el bit 1 de `0xE0C5` pide saltar. El
salto dura **diez cuadros** contados en 0x5A34, y mientras dura la postura es la
13; al acabar vuelve a la 6.

Y entonces se mira si ha valido: 0x5A5B compara la columna del atleta con la de
la valla que le toca y, **si al acabar el salto están a menos de ocho columnas**,
se pone el bit 4 de `0xE028` o de `0xE029`. Ese bit es la caída. 0x5AA5 le pone
la postura 14, le borra los cuatro bytes de velocidad y le mete 0x14 cuadros de
levantarse.

O sea que derribar una valla no es una colisión: es una comparación de columnas
en un instante concreto.

## Los intentos

En la jabalina y en el salto de altura no hay una carrera y ya: hay cuatro
intentos. `0xE023`/`0xE024` cuentan los gastados por jugador y
`0xE025`/`0xE026` el que está en curso. El resultado de cada uno va en
`0xE02A`/`0xE02B`: **1 nulo, 2 vale, 3 récord**.

Cuando un intento no vale, el marcador escribe el rótulo de fallo
(`rotulo_de_fallo`, 0x5140), y lo piden dos sitios distintos: 0x4379 y 0x4521.

## El reloj miente en Europa

La rutina que cuenta el tiempo (0x56D7) suma **1,665 centésimas por cuadro**, o
sea un sesentavo de segundo. Está calculada para una máquina de 60 Hz.

Es la misma rutina que la del cartucho hermano, y allí está medida en las dos
máquinas:

| máquina | Hz | reloj del juego por segundo real |
|---|---|---|
| Philips VG-8020 (PAL) | 50 | **0,8325 s** |
| C-BIOS MSX1 JP (NTSC) | 60 | 0,9990 s |

En un MSX europeo, **un «13,00» en las vallas son 15,6 segundos de verdad**. Y
no es que el juego vaya lento: es que el reloj cuenta corto. Las marcas de
clasificación y los récords del mundo están pensados para la máquina japonesa.

Cuidado con leerlo al revés: eso es un **periodo**, no una velocidad. El detalle
está en [En el emulador](EN-EL-EMULADOR.md).

## Dos jugadores, cuadros alternos

`0xE010` dice si juegan dos y `0xE011` a quién le toca. Cuando corren los dos a
la vez, el motor de la carrera mira el bit 0 del contador de cuadros: **en los
pares mueve al atleta del jugador 1 y en los impares al del 2**. La mitad del
trabajo por cuadro, y a 50 o 60 Hz no se nota.

## Seis sprites menos que en el hermano

Un detalle medido que dice bastante de cómo se hizo este cartucho: 0x4389 sube
**26 filas** de la tabla de atributos de sprite (`ld bc,01AFEh`); en Hyper
Olympic 1 la misma rutina subía 32.

Y la tabla de posturas también es más corta: **dieciocho** entradas
(`posturas_del_atleta`, 0x713C) contra las veinticinco de allí. Estas pruebas
necesitan menos figuras.

## La demo se juega sola, y muy mal

Cuando nadie toca nada arranca una demo. No lleva una partida grabada: la
**juega la interrupción**, y el piloto es de lo más tonto que se puede escribir.
Con `0xE002` a 1, la interrupción mete en `0xE00B` un valor de `ld a,r` —el
registro de refresco de la memoria— enmascarado a dos bits, una vez cada cuatro
cuadros. Eso es todo: **pulsaciones al azar**.

## Los mandos

`0xE004` dice si se juega con joystick o con teclado, y `0xE005` lleva lo leído
en este cuadro: bit 0 arriba, bit 1 abajo, bit 4 espacio, bit 5 F5. Con joystick,
los dos botones. De cada jugador se guardan **los mandos de antes y los de
ahora** (0xE008-0xE00F), que es como se detecta el flanco y no la pulsación
mantenida — imprescindible en un juego que se basa en machacar una tecla.
