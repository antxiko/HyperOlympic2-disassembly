# Hyper Olympic 2 (Konami, RC-711) — desensamblado comentado

Desensamblado comentado del cartucho de MSX de 16 KB, reproducible byte a byte.

**[Leer el trabajo →](https://antxiko.github.io/HyperOlympic2-disassembly/es/)**
· [In English](README.md)

    make            # traza, genera el listado, lo reensambla y pasa los tests
    make verify     # la prueba que decide: reensamblar tiene que dar la ROM
    make sanity     # que ningun byte se quede sin explicar
    make densidad   # cuanto esta comentado, rutina por rutina
    make web        # regenera la web

La ROM **no se distribuye aqui**. Hace falta en la raiz como `hyperolympic2.rom`,
16384 bytes, sha256

    f254764f4bd1634f50abcdabe5813d133d719197216071772845983ffabad22d

`make comprueba` lo verifica.

## Como esta

| | |
|---|---|
| reensambla byte a byte | si |
| bytes explicados | 16.384 de 16.384 (100 %) |
| codigo trazado | 9.872 bytes, 5.345 instrucciones |
| datos identificados | 6.512 bytes en 98 rangos con nombre |
| comentado | 1.600 comentarios de linea, 29,9 % |
| rutinas flojas (por debajo del 10 %) | 0 de 647 |

Las anotaciones viven aparte del listado, ancladas a la direccion que
describen. Lo que hay en el fichero `.notes`:

| | |
|---|---|
| etiquetas con nombre | 647 |
| comentarios anclados | 1.587 |
| rangos de datos con explicación | 98 |

## Es el mismo programa que Hyper Olympic 1

Dos tercios del codigo son comunes. Las anotaciones del codigo compartido vienen
portadas del cartucho hermano con `tools/porta_notas.py`, que alinea las dos ROM
instruccion a instruccion con los operandos de dieciseis bits puestos a cero. Los
2.227 bytes que no tienen pareja alli -la jabalina, el salto de la valla, el
actor doble de la valla y el levantarse tras derribarla- se leyeron aqui. Los bloques de datos NO se
portaron: se volvieron a localizar recorriendo los guiones.

Portar un comentario lo coloca en la direccion buena sin cambiar lo que dice, asi
que hay dos guardianes vigilandolo y los dos han cazado algo de verdad:
`tools/repasa_el_porte.py` encontro nueve direcciones citadas que aqui no
existen y una cabecera de bloque que nombraba la prueba del hermano, y
`tools/cifras_portadas.py` encontro dos comentarios que decian "32 sprites"
cuando este cartucho carga 26.

## Que hay dentro

- `src/hyperolympic2.asm` — el listado, generado; no se edita a mano
- `src/hyperolympic2.notes` — las anotaciones, ancladas a direccion
- `src/hyperolympic2.entries` — los puntos de entrada, cada uno justificado
- `docs/` — la web, en ingles y en castellano
- `medidas/` — lo que se midio en openMSX
- `tools/` — el trazador, el generador del listado, los recorredores de datos y
  el portador de anotaciones

## El trabajo escrito

| | |
|---|---|
| [Empezar](docs/es/EMPEZAR.md) | lo que hace falta y que hace cada orden |
| [El juego](docs/es/EL-JUEGO.md) | cuatro pruebas, doce rondas y una que se puede tirar |
| [El cartucho](docs/es/EL-CARTUCHO.md) | la cabecera, el mapa de memoria y la pantalla |
| [El codigo](docs/es/EL-CODIGO.md) | como esta montado el programa, y que vino del hermano |
| [Hallazgos](docs/es/HALLAZGOS.md) | lo que dice el binario |
| [En el emulador](docs/es/EN-EL-EMULADOR.md) | lo que se midio, y como repetirlo |
| [Preguntas abiertas](docs/es/PREGUNTAS-ABIERTAS.md) | lo que queda sin cerrar |
| [Hyper Olympic contra Track & Field](docs/es/COMPARATIVA-TRACK-AND-FIELD.md) | las dos compilaciones de este cartucho, comparadas |

Ver `AVISO-LEGAL.md`.
