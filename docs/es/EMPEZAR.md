# Empezar

Este repositorio no trae el juego: trae la manera de volver a montarlo desde tu
propia copia y de comprobar que lo que sale es exactamente el cartucho.

## Lo que hace falta

Tu propio volcado del cartucho, en la raíz y con este nombre:

| | |
|---|---|
| fichero | `hyperolympic2.rom` |
| tamaño | 16.384 bytes |
| sha256 | `f254764f4bd1634f50abcdabe5813d133d719197216071772845983ffabad22d` |

Y `pasmo`, `z80dasm` y Python 3. Para las medidas del emulador, openMSX.

## La orden que lo hace todo

```sh
make comprueba   # ¿es este el volcado bueno?
make             # traza, genera el listado, lo reensambla y pasa los tests
```

`make` acaba en verde o no acaba. La línea que importa es ésta:

```
  ensamblado : 16384 bytes  f254764f...abad22d
  original   : 16384 bytes  f254764f...abad22d
OK: reproducible byte a byte
```

## Las otras órdenes

```sh
make verify     # la prueba que decide: reensamblar tiene que dar la ROM
make sanity     # lo que el reensamblado NO puede cazar
make densidad   # cuánto está comentado, rutina por rutina
make imagenes   # dibuja bloques de la ROM para mirarlos
make test       # los tests del listado
make web        # regenera esta web
```

## Por qué `verify` no basta

Reensamblar y obtener los mismos bytes demuestra que el listado es **fiel**, no
que sea **correcto**. Si unos gráficos se leyeran como instrucciones, los bytes
saldrían idénticos igual: lo único que mentiría es el listado.

Por eso `make sanity` hace tres comprobaciones más, y las tres son las que de
verdad se ganan el sueldo:

- **ningún byte declarado como datos puede salir como código**, y al revés;
- **ningún punto de entrada puede caer dentro de una zona de datos**;
- **ni un byte del cartucho sin asignar** — el presupuesto tiene que sumar
  16.384, repartidos entre código al que el trazador llega de verdad y rangos
  de datos con nombre y explicación.

## Y una cuarta, que aquí importa más que en ningún sitio

**Ninguna anotación puede citar una dirección del cartucho hermano, ni nombrar
sus pruebas.**

Este cartucho y Hyper Olympic 1 son casi el mismo programa: el 83,4 % de las
instrucciones de aquél aparecen aquí. Aprovecharlo es lo sensato, y las
anotaciones del código compartido se traen con `tools/porta_notas.py`, que
alinea las dos ROM instrucción a instrucción con los operandos de dieciséis bits
puestos a cero. Pero eso coloca cada comentario en la dirección buena **sin
cambiar lo que dice**: un comentario que es verdad allí puede ser mentira aquí.

`tools/repasa_el_porte.py` es el guardián. La regla es exacta y no tiene
heurística: toda dirección citada dentro de un comentario —o dentro de una
página de esta web— tiene que ser arranque de instrucción o caer en un rango de
datos **de este cartucho**, y ninguna anotación puede nombrar las pruebas del
otro. Perdona tres cosas, y cada una con su razón escrita en el código: las
casillas cero de las tablas indexadas desde uno, las frases que se están
comparando con el hermano a propósito, y las dos páginas comparativas, cuyo
asunto es precisamente el otro binario.

No es un guardián decorativo. Cazó nueve direcciones citadas que aquí no
existían —seis desplazadas un byte y tres apuntando a otra rutina— y una
cabecera de bloque que seguía titulando el vuelo con el nombre de la prueba del
hermano, el martillo, que este cartucho no tiene.

Y hay un segundo guardián, `tools/cifras_portadas.py`, que vigila lo que el
primero no puede ver: si un comentario es idéntico a uno del hermano, la
instrucción que anota tiene que ser también la misma, una vez puestos a cero los
operandos de dieciséis bits. Cazó los dos comentarios de 0x4389, que decían «32
sprites» cuando aquí el `ld bc,01afeh` carga 26.

## Qué hay dentro

| | |
|---|---|
| `src/hyperolympic2.asm` | el listado, generado; no se edita a mano |
| `src/hyperolympic2.notes` | las anotaciones, ancladas a dirección |
| `src/hyperolympic2.entries` | los puntos de entrada, cada uno justificado |
| `src/hyperolympic2.nocode` | las zonas que el trazador tiene prohibidas |
| `medidas/` | lo medido en openMSX, con las tablas en crudo |
| `tools/` | el trazador, el generador del listado y los recorredores |
| `docs/` | esta web |

Los comentarios viven **aparte** del listado, anclados a la dirección que
describen. Así sobreviven a un retrazado: si mañana el trazador reparte el
binario de otra forma, los comentarios siguen cayendo donde tienen que caer.

## Lo que no está aquí

La imagen del cartucho. Ni ésta ni ninguna otra: es de Konami y no se
distribuye. Ver [AVISO-LEGAL.md](../AVISO-LEGAL.md).
