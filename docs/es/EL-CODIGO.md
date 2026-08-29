# El código

Dieciséis kilobytes repartidos en 9.872 bytes de código y 6.512 de datos. No hay
ningún cambio de banco ni ningún truco de carga: el programa entero está a la
vista entre 0x4000 y 0x7FFF.

Y hay una cosa que conviene saber antes de leer nada: **este cartucho es, en su
mayor parte, el mismo programa que Hyper Olympic 1**. Alineando las dos ROM
instrucción a instrucción, 4.195 de las 5.032 instrucciones de aquél aparecen
aquí: el 83,4 %. Lo que sigue vale para los dos salvo donde se diga.

## Dos hilos que se reparten el trabajo

**La interrupción** (`INTERRUPCION`, 0x4010) entra por el gancho H.KEYI que INIT
rellena con un `jp`, y hace todo lo que tiene que ir a ritmo de pantalla: lee
los mandos, mueve el reproductor de sonido, cuenta el reloj y llama al motor de
la prueba que se esté jugando. Es donde ocurre el juego.

**El principal** lleva la máquina de estados: montar el decorado, esperar a que
acabe el intento, repartir puntos, pasar de ronda. Casi siempre está esperando a
que la interrupción le ponga un bit.

## Los cuatro motores, y de dónde salen

Aquí está lo interesante de este cartucho. Las cuatro pruebas son nuevas, pero
solo dos motores lo son:

| prueba | motor | de dónde viene |
|---|---|---|
| 110 vallas y 1500 m | `MOTOR_DE_LA_CARRERA` (0x5187) | el mismo que las carreras del hermano |
| jabalina | `MOTOR_DE_LA_JABALINA` (0x680A) | escrito aquí, sobre el molde del salto |
| salto de altura | `MOTOR_DEL_SALTO_DE_ALTURA` (0x6A2C) | **el motor del martillo, reaprovechado** |

Ese tercero es el que más dice. El motor que en el cartucho hermano hacía girar
el martillo —tomar impulso, marcar el ángulo con el botón y soltar— es
exactamente el que aquí levanta al saltador de altura. Cambia lo que se dibuja,
no la mecánica.

Y hay un cuarto trozo que no es un motor pero se comporta como si lo fuera:
`AVANZA_EL_TIRO` (0x7D2B), que calcula el vuelo. Lo usan la jabalina y el salto,
y es lo único del cartucho que hace cuentas de verdad.

## Lo que este cartucho añade: 1.519 bytes

Los bytes de código que **no** vienen del hermano son 1.519, y están casi todos
en cuatro sitios:

- **el salto de la valla** (0x5A1B), que es lo único que las 110 vallas añaden a
  una carrera normal;
- **el motor de la jabalina** (0x682A);
- **el del salto de altura** (0x6A2C);
- **el dibujo de la valla como actor doble** (0x7AAE).

Todo lo demás es el hermano.

### El salto de la valla

Mientras el atleta corre, el bit 1 de `0xE0C5` pide saltar. El salto dura diez
cuadros, contados en 0x5A34, y mientras dura la postura es la 13; al acabar, la
6. Entonces 0x5A5B compara la columna del atleta con la de la valla que le toca
y, si están a menos de ocho columnas, pone el bit 4 de `0xE028` o `0xE029`.

Ese bit es la caída: 0x5AA5 le pone la postura 14, le borra los cuatro bytes de
velocidad y le mete 0x14 cuadros de levantarse. **Derribar una valla no es una
colisión: es una comparación de columnas en un instante concreto.**

### La valla se dibuja en dos papeles

Un actor normal monta su figura en el papel de 0xE230 y la sube de una vez. La
valla no cabe en una fila, así que 0x7AB3 monta la mitad de arriba en 0xE230 y
la de abajo en 0xE270, y las sube por separado, cada una a su fila de la tabla
de nombres. Es el único actor del cartucho que hace esto.

## La única cuenta de verdad

`CALCULA_EL_TIRO` (0x7D38) coge la velocidad de carrera y el ángulo y saca de
ahí el avance y la altura de cada cuadro, y al final la marca. Para eso hay tres
rutinas de aritmética escritas a mano, porque el Z80 no trae ninguna:

- `DIVIDE` (0x7E75), desplazando y restando;
- `MULTIPLICA` (0x7E93), desplazando y sumando;
- `PASA_A_BCD` (0x7EB7), que convierte un número binario a BCD doblándolo en
  BCD, bit a bit, para poder imprimirlo.

Y el seno sale de una tabla, `EL_SENO_DEL_ANGULO` (0x7E53): un byte por grado.
Nada de aproximaciones en tiempo real.

## Los puntos

`PUNTUA_EL_INTENTO` (0x4F36) convierte la marca en puntos, y la aritmética
cambia de signo según la prueba: los puntos salen de la diferencia entre la
marca y una referencia fija por prueba (`marca_de_referencia`, 0x5022). **En las
pruebas de tiempo la referencia está arriba** y se le resta la marca; **en las
de distancia está abajo** y es la marca la que le gana. Después se multiplica
por dieciséis, y en las pruebas impares se dobla otra vez.

## El cartucho no guarda pantallas: guarda guiones

Ninguna pantalla está dibujada en la ROM tal cual. Lo que hay son **guiones**, y
cuatro intérpretes distintos que los leen.

**El guion largo** (`GUION_LARGO`, 0x4CF2) es el gordo: un byte con el número de
órdenes y detrás las órdenes, cada una empezando por su tipo.

| tipo | qué hace |
|---|---|
| 0 | bytes a VRAM, con 0x11 como marca de racha (RLE) |
| 1 | tiras de glifos de la fuente, subidos como patrón |
| 2 | rótulos de letra grande |
| 3 | rellenos de un byte |
| 4+ | repetir un patrón de ocho bytes N veces |

**El guion corto** (`GUION_CORTO`, 0x4AFD) es para textos sueltos, como los del
menú. **El rótulo** (`LLENA_EL_PAPEL`, 0x4C4C) prepara un texto que después se
estira a letra grande. Y **la figura** (`MONTA_LA_FIGURA`, 0x79A5) expande la
descripción de un actor a códigos de carácter.

Las listas de decorado están emparejadas: las vallas y los 1500 metros comparten
la suya (0x655A) y la jabalina y la altura la otra (0x661F).

## Las letras grandes se fabrican

Un rótulo de letra grande no está dibujado en ningún sitio: se monta al vuelo.
`MONTA_UN_ROTULO` (0x4C32) copia los glifos **normales** de 8x8 a un papel en
0xE230, y luego `ESTIRA_LAS_LETRAS` (0x4C94) da **tres pasadas** que van sacando
los dos bits altos de cada byte y metiéndolos en el byte de ocho posiciones
antes.

Con eso una fila de ocho glifos da cuatro filas de patrón: la letra sale al
doble de tamaño sin ocupar el doble en la ROM.

## Escribir en el VDP sin que la interrupción lo pise

Hay cuatro rutinas dedicadas a esto, y todas hacen lo mismo (0x4DE5 y las de
debajo).

El problema: fijar una dirección en el VDP son **dos escrituras seguidas** al
puerto de control, y la interrupción también escribe en el VDP. Si se cuela
entre las dos, la dirección que queda puesta es la suya.

La solución no es prohibir la interrupción, sino **darse cuenta**: se borra
0xE01D, se fija la dirección, y se mira 0xE01D. Si la interrupción ha entrado
por en medio, lo habrá puesto, y entonces se repite. Es más barato que apagar y
encender las interrupciones en cada escritura, y no pierde ni un cuadro.

## El reproductor de sonido

Tres canales, once bytes de ficha cada uno, en 0xE160, 0xE16B y 0xE176:

| desplazamiento | qué es |
|---|---|
| +0 | cuenta de la nota |
| +1 | duración base |
| +2 | número de sonido |
| +3/+4 | puntero a la tira |
| +5 | octava |
| +6 | caída |
| +7 | volumen |
| +8 | cuenta de la caída |
| +9 | repeticiones que quedan |
| +0x0A | duración |

Lo interesante es **el número de sonido**, que lleva la información en sus bits
altos: el bit 7 dice que la nota va en un solo byte, el bit 6 que el canal 3 se
usa como ruido, y **los seis de abajo son la prioridad**. Un sonido no
interrumpe a otro de prioridad más alta.

Las tiras viven en `melodias` (0x6EAC): `0xFF` acaba y `0xFE` vuelve a empezar.
Los treinta y seis punteros están en 0x6E64, y un sonido de varias voces se
lleva entradas seguidas.

## Los actores

Un actor es una ficha de dieciséis bytes en RAM, y hay cuatro: 0xE120, 0xE130,
0xE140 y 0xE150.

| desplazamiento | qué es |
|---|---|
| +0 | banderas |
| +1 | cuenta |
| +2 | escalón |
| +6 | columna dentro de la figura |
| +7/+8 | dirección de VRAM |
| +9/+0A | la ficha que le releva |
| +0B | fila de la tabla de ajuste |
| +0C | columna calculada |
| +0D/+0E | la figura |
| +0F | cuántos caracteres se pintan |

Las cuatro fichas van **seguidas** en memoria, y de ahí sale el truco: el bit 2
de las banderas hace que el actor empuje al de delante y el bit 3 al de detrás,
sumando o restando 0x11 al puntero. Así el decorado se arrastra en cadena sin
que nadie lleve una lista de quién empuja a quién.

## El atleta son siete sprites

`FICHA_DEL_QUE_JUEGA` (0x7F51) y lo que hay debajo montan al corredor. No es un
sprite: son **siete**, y cada postura los coloca a mano. 0x7F85 sube a VRAM los
patrones que hagan falta y después escribe las siete filas de la tabla de
atributos, sumando a cada una la fila y la columna donde está el atleta.

Las posturas son dieciocho (0x713C), siete menos que en el cartucho hermano.

## Cómo leerlo

El listado se genera; no se edita a mano. Los comentarios viven aparte, en
`src/hyperolympic2.notes`, anclados a la dirección que describen.

Y aquí hay una cautela de más, porque **el 86,9 % de los comentarios de este
cartucho son idénticos a uno del hermano**: vienen portados, y un comentario
portado dice lo que hacía la instrucción *allí*. Dos guardianes lo vigilan, y
los dos han cazado algo de verdad:

- `tools/repasa_el_porte.py` comprueba que toda dirección citada exista aquí y
  que ninguna anotación nombre las pruebas del otro. Cazó nueve direcciones y
  una cabecera de bloque que hablaba del martillo.
- `tools/cifras_portadas.py` comprueba que, cuando un comentario es idéntico a
  uno del hermano, la instrucción que anota sea también la misma. Cazó los dos
  comentarios de 0x4389, que decían «32 sprites» cuando aquí son 26.

Está contado con detalle en [Empezar](EMPEZAR.md).
