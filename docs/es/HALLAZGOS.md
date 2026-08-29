# Hyper Olympic 2 (Konami, RC-711) - lo que dice el binario

Todo lo de aqui sale de leer el cartucho o de medirlo en openMSX. Lo que es
suposicion lleva la palabra SUPOSICION delante.

## 1. Las cuatro pruebas

0xE016 va de 1 a 4 y 0xE015 cuenta doce rondas. Fotografiadas una a una
(`medidas/pruebas.txt`):

    1  110 HURDLERS       record 12 SEC 93
    2  JAVELIN THROW      record 96 M 72
    3  HIGH JUMP          record 02 M 36
    4  1500 METER         record 03 min 31

Igual que en el cartucho hermano, la cuarta reaprovecha el decorado (0x655A) y
el marcador (0x67C0) de la primera, y solo cambia el rotulo de la pizarra.

## 2. "110 HURDLERS": la errata esta en la ROM

El rotulo de la primera prueba no dice HURDLES sino HURDLERS. No es cosa de la
captura: el rotulo de 0x64B1 lleva, detras de su byte de cabecera, la tira de glifos
0A 01 01 00 0A 12 1E 1B 0E 16 0F 1B 1C 0A, que en la fuente del cartucho
(0x6197) se lee " 110 HURDLERS ".

## 3. Los records son de verdad, pero tres de los cuatro ya estaban batidos

MEDIDO en el binario: 0x517B lleva `00 12 93 / 00 96 72 / 00 02 36 / 00 03 31`,
que INIT copia a 0xE040. O sea 12,93 s en las 110 vallas, 96,72 m en jabalina,
2,36 m en altura y 3:31 en los 1500.

Los cuatro son records del mundo de verdad. Lo que **no** es verdad es que
fueran los vigentes cuando salio el cartucho, que es lo que decia aqui antes:

| prueba | el cartucho | de cuando | ¿seguia en pie en 1984? |
|---|---|---|---|
| 110 vallas | 12,93 | Renaldo Nehemiah, Zurich, agosto de 1981 | si, y hasta 1989 |
| jabalina | 96,72 | Ferenc Paragi, 1980 | **no**: Tom Petranoff tiro 99,72 en mayo de 1983 |
| altura | 2,36 | la marca anterior al 2,37 de Zhu Jianhua | **no**: Zhu Jianhua salto 2,37 el 11 de junio de 1983 |
| 1500 m | 3:31 | Steve Ovett, 3:31.36, agosto de 1980 | **no**: el propio Ovett lo dejo en 3:30.77 en septiembre de 1983 |

**Tres de los cuatro caducaron en 1983**, y el que aguanta es el mas antiguo de
todos. Junto con lo que pasa en el cartucho hermano, eso dice que **la tabla de
records de los dos se compilo antes de la temporada de 1983**, aunque los
cartuchos se vendieran en 1984.

Las fechas no salen del cartucho, sino de las progresiones publicas de records:
se dan como lo que son, un cotejo externo. Lo del cartucho es la cifra.

## 4. Es el mismo programa que Hyper Olympic 1, con las pruebas cambiadas

Alineando las dos ROM instruccion a instruccion -con los operandos de dieciseis
bits puestos a cero, para que las direcciones no estorben-, 4.195 de las 5.032
instrucciones de Hyper Olympic 1 aparecen tambien aqui: el 83,4 %. Contado en
bytes normalizados, 6.298 de 9.872, o sea el 63,8 % de este cartucho.

Lo que NO tiene pareja en el hermano son 2.227 bytes de codigo, en 247 tramos.
Los cuatro mayores: el motor de la jabalina (0x682A, 434 bytes), el salto de la
valla (0x5A1B, 172), MONTA_LA_VALLA (0x7AB3, 159) y EL_ATLETA_SE_LEVANTA
(0x5AD7, 109). El salto de altura NO esta entre ellos: su motor es entero el del
martillo del hermano.

## 5. La valla se dibuja en DOS papeles

Un actor normal monta su figura en 0xE230 y la sube de una vez. La valla no
cabe en una fila: 0x7AB3 monta la mitad de arriba en 0xE230 y la de abajo en
0xE270, y las sube por separado, cada una a su fila de la tabla de nombres.
Es el unico actor del cartucho que hace esto.

## 6. Derribar una valla es un bit

Mientras el atleta salta (postura 13, diez cuadros contados en 0x5A34), 0x5A5B
compara su columna con la de la valla que le toca. Si al acabar el salto estan
a menos de ocho columnas, se pone el bit 4 de 0xE028 o 0xE029 y el atleta cae:
0x5AA5 le pone la postura 14, le borra los cuatro bytes de velocidad y le mete
0x14 cuadros de levantarse.

## 7. Seis sprites menos que en el hermano

0x4389 sube 26 filas de la tabla de atributos (`ld bc,01AFEh`); en Hyper
Olympic 1 la misma rutina subia 32. La tabla de posturas tambien es mas corta:
18 entradas contra 25.

## 8. La fuente se quedo sin X y sin Z, y la Q llego tarde

Los 51 glifos de 0x6197 empiezan ordenados: 0..9, el espacio, y luego el
alfabeto **de la A a la Y saltandose la Q, la X y la Z**. Con A en el indice
0x0B, la P cae en 0x1A y la siguiente, en 0x1B, ya es la R.

Y sin embargo **la Q existe**. Esta al final, en el indice **0x2C**, fuera del
alfabeto, y el motivo es la unica palabra del juego que la necesita: el rotulo
**QUALIFY** del marcador, que en 0x611E es la tira `2C 1E 0B 16 13 10 21`.

X y Z no aparecen: ninguna palabra del cartucho las usa.

La hoja entera esta en `docs/imagenes/fuente.png`, y la dibuja
`tools/graficos.py` leyendo el rango que declara el listado.

## 9. Lo que comparte con el cartucho hermano

Byte a byte y sin normalizar nada: la fuente entera (408 bytes, los mismos 51
glifos sin Q, sin X y sin Z), los ocho registros del VDP, y los doce bytes
muertos de 0x4E64, que tampoco los lee nadie aqui.

## 10. La marca oculta de Konami NO esta

El truco que destapo Manuel Pazos -el codigo RC-7xx y el titulo en katakana
escondidos detras del relleno del final de la ROM- no aparece: los dos ultimos
bytes son 0xFF y delante hay codigo del reproductor de sonido. Se comprobo con
`tools/marca_konami.py`, que en el mismo tiro SI la encuentra en Pippols.

## 11. El reloj esta calculado para 60 Hz

La rutina que cuenta el tiempo (0x56D7) es la misma que la del cartucho
hermano y suma 1,665 centesimas por cuadro. Alli se midio: en un MSX de 50 Hz
el reloj del juego avanza 0,8325 segundos por segundo real, y en uno de 60 Hz
0,9990. Ver `../HYPEROLYMPIC1_DISAM/medidas/reloj.md`.

## 12. A que familia de Konami pertenece

### El metodo

`tools/comun_normalizado.py`: traza las dos ROM con sus desensamblados ya
hechos, decodifica las instrucciones, pone a cero los operandos de dieciseis
bits -que son los que llevan direcciones- y busca los tramos comunes. Asi una
rutina reensamblada en otro sitio SI se ve. Control: Frogger contra Time Pilot,
que ya se sabia que comparten reproductor, da 667 bytes en 15 tramos.

### Las cifras

    contra                bytes en comun   % de Hyper Olympic 2   tramo mayor
    -------------------   --------------   --------------------   -----------
    Hyper Olympic 1                6.298                 63,8 %       681 B
    Frogger                          175                  1,8 %        42 B
    Super Cobra                      173                  1,8 %        37 B
    Monkey Academy                    83                  0,8 %        37 B
    Billiards de Konami              105                  1,1 %        36 B
    Athletic Land                     78                  0,8 %        32 B
    Pippols                           44                  0,4 %        22 B
    Time Pilot                        21                  0,2 %        21 B

### Lo que sale de ahi

Los dos Hyper Olympic son el mismo programa: el tramo mayor son 681 bytes
seguidos (0x7B52 aqui, 0x7B27 alli), o sea rutinas enteras.

Con los demas cartuchos Konami de MSX de la serie la diferencia es de dos
ordenes de magnitud: ninguno pasa del 2 %, y sus tramos mayores van de 21 a 42
bytes. No hay ni rastro del reproductor de Frogger y Time Pilot ni del armazon
de Athletic Land. Son un TERCER armazon, con dos miembros.

Los 42 bytes de Frogger son la excepcion que merece mirarse, y queda apuntada:
es mas de lo que da la casualidad, y no se ha identificado que rutina es.
