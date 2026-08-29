# Lo que queda sin cerrar, contado uno a uno

El presupuesto esta al 100 %: los 16.384 bytes estan repartidos entre codigo
trazado (9.872) y rangos de datos con nombre (6.512), y `make sanity` lo
comprueba. Lo que sigue no son bytes sin repartir, sino cosas que se explican
con menos certeza de la que me gustaria.

## 1. Doce bytes muertos en 0x4E64

Los mismos que en el cartucho hermano y en la misma postura, pegados a los ocho
registros del VDP: `00 70 38 70 / 00 A0 38 70 / 00 F0 38 F0`. Nadie los lee.

## 2b. INIT fija una direccion de VRAM y no escribe nada detras

En 0x40A6 hay `ld de,081a2h` y un `call` a la rutina que fija la direccion de
escritura del VDP. Detras no viene ninguna escritura a VRAM. Igual que en el
cartucho hermano. SUPOSICION: es un resto de una version anterior.

## 2. Las anotaciones vienen portadas, y hay un 16,6 % que no

De las 5.032 instrucciones de Hyper Olympic 1, 4.195 aparecen aqui y traen sus
comentarios con ellas (`tools/porta_notas.py` alinea las dos ROM y mueve las
L, las C y las B). Los 2.227 bytes de codigo sin pareja alli se leyeron y comentaron a mano. Aun asi, un comentario portado dice lo que hacia
la instruccion EN EL OTRO CARTUCHO: donde el sentido cambia -los nombres de las
pruebas, sobre todo- se corrigio uno a uno, pero es el sitio por donde puede
haberse colado algo.

Dos guardianes lo vigilan, y los dos cazaron algo de verdad: `repasa_el_porte.py`
encontro nueve direcciones citadas que aqui no existen y una cabecera de bloque
que aun hablaba del martillo, y `cifras_portadas.py` encontro los dos comentarios
de 0x4389 que decian "32 sprites" cuando aqui son 26.

## 3. Los bloques de datos NO se portaron

Los rangos D y las anchuras F se volvieron a sacar aqui recorriendo los
guiones, las melodias, las posturas y las fichas con las mismas herramientas.
Ninguno viene copiado del hermano.

## 4. Quince rotulos de letra grande van por direccion, no por nombre

Los DIECINUEVE rotulos de letra grande, de 0x632F a 0x64EF, estan delimitados
por el recorrido de los guiones, pero solo CUATRO tienen nombre propio: los de
las cuatro pruebas, que empiezan en 0x64B1. Los otros QUINCE se publican como
`rotulo_XXXX`. Para bautizarlos habria que dibujarlos.

## 5. Cinco huecos pequenos en los patrones del objeto

El recorrido de 0x789E deja sueltos cuatro grupos de cuatro bytes (0x78AE,
0x78C0, 0x78D6, 0x78E6) y uno de veinte (0x78FC). SUPOSICION: son las filas de
atributos que van detras de cada patron, porque 0x690A escribe dos sprites por
patron y los numeros cuadran. Entran en el rango `patrones_del_objeto` y por
eso el presupuesto sale, pero no estan comprobados uno a uno.

## 6. Cuatro tiras de melodia a las que no se llega

Recorriendo la tabla de 0x6E64 desde los diecisiete sonidos que el codigo pide
con un valor inmediato, quedan cuatro tramos sin visitar: 0x6EE5-0x6EF6 (la
entrada 10 de la tabla), 0x6F3E-0x6F53 (la 13), 0x6F6B-0x6F75 (la 21) y
0x710E-0x7116, al que no apunta ninguna entrada. Sus bytes SI estan dentro del
rango `melodias`, asi que el presupuesto sale. Los diecisiete sonidos son TODOS
los que pide el cartucho: las dos llamadas que no llevan el numero pegado
delante se resolvieron a mano y salen 0x99 y 0x02, que ya estaban contados. Asi
que a esas tres tiras NO LAS PIDE NADIE. SUPOSICION: son sonidos que se
quedaron sin usar. El cuarto tramo, 0x710E-0x7116, es el final de la tira de al
lado, que el recorrido corta en el 0xFF.

## 7. Que hace exactamente cada bit de 0xE201

Los bits 0, 6 y 7 del salto de altura estan claros por el codigo que los mira.
Los dos de abajo se usan como cuenta de fase y estan comentados en su sitio,
pero sin un nombre unico.
