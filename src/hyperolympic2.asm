; ==========================================================================
; HYPER OLYMPIC 2 - Konami - MSX1 - cartucho RC-711 de 16 KB en la pagina 1
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; DATOS cabecera: Cabecera del cartucho: la firma AB y los cuatro punteros que
;   lee la BIOS. Solo INIT (0x4081) tiene valor; STATEMENT, DEVICE y TEXT van
;   a cero.
;   0x4000..0x4010  (16 bytes)
DATA_cabecera:
	defb 041h,042h	; 4000
	defb 081h,040h	; 4002
	defb 000h,000h	; 4004
	defb 000h,000h	; 4006
	defb 000h,000h	; 4008
	defb 000h,000h	; 400a
	defb 000h,000h	; 400c
	defb 000h,000h	; 400e

; ======================================================================
; CODIGO 0x4010..0x4ae6  (2774 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  LA INTERRUPCION  ==========
; Entra por el gancho H.KEYI (0xFD9A), que INIT rellena con un `jp` aqui.
; Hace el trabajo que tiene que ir a ritmo de pantalla: el reloj, los
; mandos, la musica y el motor de la prueba que se este jugando.
; ----------------------------------------------------------------------
INTERRUPCION:
	call 0013eh		;4010   ; BIOS RDVDP - Reads VDP status register | leer el estado del VDP es lo que retira la peticion de interrupcion
	ld hl,0e01dh		;4013
	ld (hl),001h		;4016   ; avisa de que ha entrado: quien estuviera fijando una direccion de VRAM la repite
	inc hl			;4018   ; -> 0xE01E, el candado
	ld a,(hl)			;4019
	or a			;401a
	ret nz			;401b   ; con el candado puesto la interrupcion se va sin tocar nada
	ld hl,0e000h		;401c
	inc (hl)			;401f   ; el contador de cuadros
	ld a,(hl)			;4020
	and 01fh		;4021   ; los cinco bits de abajo
	jr nz,INT_CON_MANDOS		;4023
	inc hl			;4025
	dec (hl)			;4026   ; la espera de 0xE001 baja UNA VEZ CADA 32 CUADROS, no una por cuadro
INT_CON_MANDOS:
	call LEE_LOS_MANDOS		;4027   ; lee los mandos crudos
	ld a,(0e002h)		;402a
	or a			;402d
	jr z,INT_PARTIDA_DE_VERDAD		;402e   ; con 0xE002 puesto lo que corre es la DEMO: ni se leen los mandos ni suena la musica
	ld a,(0e029h)		;4030   ; MEDIDO: aqui solo se entra en la demo. El bit 7 de 0xE029 esta puesto tambien en partida, pero entonces manda 0xE002 y este trozo no corre
	rlca			;4033
	jr nc,INT_MOTOR_DE_LA_PRUEBA		;4034
	ld hl,0e00bh		;4036
	ld (hl),000h		;4039   ; borra el boton antes de inventarselo
	ld a,(0e000h)		;403b
	and 003h		;403e   ; una de cada cuatro cuadros
	jr nz,INT_MOTOR_DE_LA_PRUEBA		;4040
	ld a,r		;4042   ; el azar del cartucho es el registro de refresco de la memoria
	and 003h		;4044
	ld (hl),a			;4046   ; pulsaciones al azar en el boton del jugador 1
	jr INT_MOTOR_DE_LA_PRUEBA		;4047
INT_PARTIDA_DE_VERDAD:
	call LEE_LOS_MANDOS_DE_LOS_DOS		;4049   ; y en partida de verdad se reparten los mandos entre los dos jugadores
	call MUEVE_EL_SONIDO		;404c   ; y mueve la musica
	di			;404f
INT_MOTOR_DE_LA_PRUEBA:
	ld a,(0e003h)		;4050
	or a			;4053
	jr z,INT_FIN		;4054   ; con 0xE003 a cero no hay prueba que mover
	call PARPADEO_DEL_RESULTADO		;4056   ; el parpadeo del rotulo del resultado
	ld a,(0e016h)		;4059
	dec a			;405c
	push af			;405d
	call z,MOTOR_DE_LA_CARRERA		;405e   ; prueba 1, las 110 vallas
	pop af			;4061
	dec a			;4062
	push af			;4063
	call z,MOTOR_DE_LA_JABALINA		;4064   ; prueba 2, el lanzamiento de jabalina
	pop af			;4067
	dec a			;4068
	push af			;4069
	call z,MOTOR_DEL_SALTO_DE_ALTURA		;406a   ; prueba 3, el salto de altura
	pop af			;406d
	dec a			;406e
	call z,MOTOR_DE_LA_CARRERA		;406f   ; prueba 4, los 1500 metros: el mismo motor que las vallas
INT_FIN:
	call 0013eh		;4072   ; BIOS RDVDP - Reads VDP status register | vuelve a mirar el estado del VDP
	rlca			;4075
	jp c,INTERRUPCION		;4076   ; si ha entrado OTRO cuadro mientras trabajabamos, se repite la pasada entera
	ld a,001h		;4079
	ld (0e01dh),a		;407b   ; deja la marca puesta para el que estuviera fijando VRAM
	ei			;407e
	reti		;407f

; ----------------------------------------------------------------------
; ==========  INIT  ==========
; El unico punto de entrada que declara la cabecera. La BIOS lo llama
; con la maquina ya inicializada, y de aqui no se vuelve.
; ----------------------------------------------------------------------
INIT:
	di			;4081
	ld hl,0fd9ah		;4082   ; el gancho de interrupcion de la BIOS
	ld (hl),0c3h		;4085   ; le mete un `jp`
	ld hl,INTERRUPCION		;4087   ; y detras la direccion de nuestra interrupcion
	ld (0fd9bh),hl		;408a
	ld hl,0e000h		;408d   ; limpia la RAM del juego de 0xE000 a 0xE3FE
	ld de,0e001h		;4090
	ld bc,003feh		;4093
	ld (hl),l			;4096   ; con L, que en este momento vale cero
	ldir		;4097
	ld sp,hl			;4099   ; y deja la pila justo encima, en 0xE3FE
	ld a,008h		;409a   ; los tres registros de tono del PSG
	ld e,000h		;409c
	ld b,003h		;409e   ; a cero, para que no suene nada
LIMPIA_UN_REGISTRO_DEL_PSG:
	call 00093h		;40a0   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;40a3
	djnz LIMPIA_UN_REGISTRO_DEL_PSG		;40a4
	ld de,081a2h		;40a6   ; canal A a volumen 8, mezclador a 0xA2
	call FIJA_ESCRITURA		;40a9
	ld a,00fh		;40ac   ; registro 15, el puerto de salida
	ld e,0cfh		;40ae
	call 00093h		;40b0   ; BIOS WRTPSG - Writes data to PSG-register
	call 00132h		;40b3   ; BIOS CHGCAP - Alternates the CAPS lamp status | apaga el piloto de CAPS
	im 1		;40b6
	ld hl,0517bh		;40b8   ; los cuatro records del mundo
	ld de,0e040h		;40bb   ; a su sitio en la RAM
	ld bc,0000ch		;40be
	ldir		;40c1
	ld hl,07ac5h		;40c3   ; la flecha del menu arranca en la fila de la primera linea
	ld (0e019h),hl		;40c6
	ld a,001h		;40c9   ; y la linea elegida es la primera
	ld (0e01bh),a		;40cb
ARRANQUE_DE_LA_PRESENTACION:
	di			;40ce
	ld hl,00000h		;40cf   ; borra el numero de jugadores
	ld (0e010h),hl		;40d2
	ld hl,0e020h		;40d5   ; limpia los tres canales de sonido
	ld bc,0001fh		;40d8
	call LIMPIA_MEMORIA		;40db
	ld hl,0e050h		;40de   ; y el trozo de trabajo de 0xE050
	ld c,02eh		;40e1
	call LIMPIA_MEMORIA		;40e3
	ld hl,0e083h		;40e6   ; y el de 0xE083
	ld c,01ah		;40e9
	call LIMPIA_MEMORIA		;40eb
	ld hl,0e0a0h		;40ee   ; y los tres bytes de 0xE0A0
	ld b,003h		;40f1
	call LIMPIA_MEMORIA		;40f3
	ld de,04000h		;40f6   ; se planta al principio de la VRAM
	call FIJA_ESCRITURA		;40f9
BORRA_LA_VRAM:
	ld b,e			;40fc
	ld a,e			;40fd
	call REPITE_BYTE		;40fe   ; escribe 256 bytes de una tacada
	dec d			;4101   ; hasta cubrir los 16 KB
	jr nz,BORRA_LA_VRAM		;4102
	call 00096h		;4104   ; BIOS RDPSG - Reads value from PSG-register | lee el PSG para dejarlo en un estado conocido
	ld a,001h		;4107
	ld (0e01eh),a		;4109   ; candado puesto: la interrupcion no debe pisar los registros del VDP
	ld hl,04e5ch		;410c   ; los ocho registros del VDP
	ld d,008h		;410f
	ld c,000h		;4111
SUBE_LOS_REGISTROS_DEL_VDP:
	ld b,(hl)			;4113
	call 00047h		;4114   ; BIOS WRTVDP - Writes data in the VDP-register | registro C con el valor B
	inc hl			;4117
	inc c			;4118
	dec d			;4119
	jr nz,SUBE_LOS_REGISTROS_DEL_VDP		;411a
	xor a			;411c
	ld (0e01eh),a		;411d   ; candado quitado
	ei			;4120
	inc a			;4121
	call ESPERA_PUNTOS		;4122   ; espera cuatro puntos de espera, o sea 128 cuadros
	di			;4125
	ld hl,05e35h		;4126   ; el guion de la pantalla del titulo
	call GUION_LARGO		;4129
	ld de,00000h		;412c   ; copia la tabla de patrones sobre la de color
	ld hl,04800h		;412f
	call COPIA_VRAM_A_VRAM		;4132
	ld de,02000h		;4135   ; y el tercer tercio sobre el segundo
	ld hl,06800h		;4138
	call COPIA_VRAM_A_VRAM		;413b
	ld a,005h		;413e   ; espera de ocho, unos cinco segundos
	ld (0e001h),a		;4140
	ei			;4143
	ld a,(0e006h)		;4144   ; con 0xE006 puesto se salta la espera del titulo
	or a			;4147
	jr nz,MENU		;4148
	ld hl,07a8bh		;414a   ; la flecha empieza en la ultima fila y sube
	ld (0e230h),hl		;414d

; ----------------------------------------------------------------------
; ==========  LA PANTALLA DEL TITULO  ==========
; Sube el rotulo una fila cada dos cuadros y espera a que toquen una
; tecla. Si no la tocan, cae en la demo.
; ----------------------------------------------------------------------
SUBE_EL_ROTULO:
	ld hl,0e000h		;4150
	ld a,(hl)			;4153
	and 003h		;4154   ; una de cada cuatro cuadros
	jr nz,TITULO_MIRA_LAS_TECLAS		;4156
	inc (hl)			;4158   ; el contador de cuadros va de dos en dos mientras dura esto
	inc (hl)			;4159
	ld de,(0e230h)		;415a   ; la fila de VRAM donde va ahora el rotulo
	ld hl,0786bh		;415e   ; cuando llega a 0x386B ya esta arriba del todo
	xor a			;4161
	sbc hl,de		;4162
	jr z,ROTULO_ARRIBA		;4164
	di			;4166
	xor a			;4167   ; el primer codigo de caracter del rotulo
	ld b,003h		;4168   ; tres caracteres en la fila de arriba
	call SUBE_CODIGOS_CORRELATIVOS		;416a
	ld b,00bh		;416d   ; once en la de en medio
	call SUBE_CODIGOS_CORRELATIVOS		;416f
	ld b,00ch		;4172   ; y doce en la de abajo
	call SUBE_CODIGOS_CORRELATIVOS		;4174
	ld b,00ch		;4177
	call FIJA_ESCRITURA		;4179   ; se pone en la fila siguiente
	xor a			;417c
	call REPITE_BYTE_EN_DE		;417d   ; y la borra, que es la que el rotulo acaba de dejar
	ei			;4180
	ld hl,0e230h		;4181
	ld a,(hl)			;4184   ; sube la direccion una fila, o sea 0x20 hacia atras
	sub 020h		;4185
	ld (hl),a			;4187
	jr nc,ROTULO_ARRIBA		;4188
	inc hl			;418a
	dec (hl)			;418b
ROTULO_ARRIBA:
	ld a,(0e001h)		;418c   ; con 0xE001 a cero se acabo la espera
	or a			;418f
	jr z,MENU		;4190
TITULO_MIRA_LAS_TECLAS:
	ld a,(0e005h)		;4192
	and 03fh		;4195   ; cualquiera de los seis mandos vale
	jr z,SUBE_EL_ROTULO		;4197
MENU:
	di			;4199
	call PINTA_EL_MARCO_DEL_MENU		;419a   ; pinta el marco del menu
	call PINTA_LA_FLECHA		;419d   ; y la flecha en la linea elegida
	ld a,008h		;41a0   ; ocho puntos de espera, unos cinco segundos
	ld (0e001h),a		;41a2
	ei			;41a5
MENU_ESPERA:
	call MUEVE_LA_FLECHA		;41a6   ; mueve la flecha o devuelve acarreo si han elegido
	ld hl,0e002h		;41a9
	ld (hl),000h		;41ac   ; mientras se elige, la demo queda armada
	jr c,EMPIEZA_LA_PARTIDA		;41ae
	inc (hl)			;41b0
	ld a,(0e001h)		;41b1
	or a			;41b4
	jp z,PARTIDA_NUEVA		;41b5   ; se acabo la espera: a la demo
	jr MENU_ESPERA		;41b8
EMPIEZA_LA_PARTIDA:
	xor a			;41ba
	ld hl,0e01bh		;41bb
	bit 0,(hl)		;41be   ; lineas impares (1 y 3) son de un jugador
	jr nz,GUARDA_EL_NUMERO_DE_JUGADORES		;41c0
	inc a			;41c2
GUARDA_EL_NUMERO_DE_JUGADORES:
	ld (0e010h),a		;41c3   ; 0xE010: juegan dos
	ld a,(hl)			;41c6
	cp 003h		;41c7   ; las lineas 1 y 2 son con joystick
	ld a,000h		;41c9
	jr nc,GUARDA_EL_MANDO_ELEGIDO		;41cb
	inc a			;41cd
GUARDA_EL_MANDO_ELEGIDO:
	ld (0e004h),a		;41ce   ; 0xE004: se juega con joystick
	ld a,(hl)			;41d1
	ld hl,04ebeh		;41d2   ; y el mensaje del menu que hay que borrar
	dec a			;41d5
	jr z,EMPIEZA_EL_PARPADEO_DEL_MENU		;41d6
	ld hl,04ed6h		;41d8
	dec a			;41db
	jr z,EMPIEZA_EL_PARPADEO_DEL_MENU		;41dc
	ld hl,04eeeh		;41de
	dec a			;41e1
	jr z,EMPIEZA_EL_PARPADEO_DEL_MENU		;41e2
	ld hl,04f06h		;41e4
EMPIEZA_EL_PARPADEO_DEL_MENU:
	xor a			;41e7
	ld (0e000h),a		;41e8
TITULO_PARPADEA:
	ei			;41eb
	ld a,(0e000h)		;41ec
	bit 3,a		;41ef   ; el bit 3 del contador de cuadros hace el parpadeo
	di			;41f1
	jr z,TITULO_SIN_PARPADEO		;41f2
	push hl			;41f4
	ld d,(hl)			;41f5   ; la direccion de VRAM que encabeza el mensaje elegido
	inc hl			;41f6
	ld e,(hl)			;41f7
	inc hl			;41f8
	ld b,01ah		;41f9   ; 0x1A caracteres, los que ocupa la linea
	ld c,000h		;41fb
	call REPITE_BYTE_EN_DE		;41fd   ; los borra
	pop hl			;4200
	jr TITULO_PARPADEA		;4201
TITULO_SIN_PARPADEO:
	push hl			;4203
	call GUION_CORTO		;4204   ; vuelve a escribir la linea entera
	ld hl,0e000h		;4207
	bit 6,(hl)		;420a   ; y sale cuando el contador pasa de 0x40
	pop hl			;420c
	jr z,TITULO_PARPADEA		;420d
	di			;420f
	ld a,09fh		;4210
	call PIDE_UN_SONIDO		;4212
	ei			;4215
PARTIDA_NUEVA:
	ld hl,00101h		;4216   ; ronda 1 y prueba 1 de una tacada
	ld (0e015h),hl		;4219
	call ES_LA_DEMO		;421c   ; viniendo de la demo no se toca la espera
	jr z,CARGA_LA_MARCA_A_BATIR		;421f
	ld a,004h		;4221   ; cuatro puntos de espera
	ld (0e016h),a		;4223
	ld hl,05010h		;4226
	ld de,0e05ah		;4229
	jr AJUSTA_EL_INTENTO_DEL_1		;422c
CARGA_LA_MARCA_A_BATIR:
	ld hl,0500ah		;422e   ; la marca a batir de la primera ronda
	ld de,0e051h		;4231
AJUSTA_EL_INTENTO_DEL_1:
	call COPIA_DOS_BYTES		;4234
	ld hl,0e021h		;4237
	ld a,(0e010h)		;423a   ; con un solo jugador, el segundo arranca ya eliminado
	or a			;423d
	jr nz,MONTA_LA_PRUEBA		;423e
	ld (hl),002h		;4240
MONTA_LA_PRUEBA:
	di			;4242
	call LIMPIA_LA_TABLA_DE_NOMBRES		;4243   ; limpia la tabla de nombres
	ld hl,064efh		;4246   ; el marco del marcador
	call GUION_LARGO		;4249
	ld hl,0e025h		;424c   ; intento 1 del jugador 1
	ld (hl),001h		;424f
	ld a,(0e021h)		;4251
	rrca			;4254   ; si el jugador 1 esta fuera, se le ponen cuatro (o sea, ninguno)
	jr nc,INTENTO_DEL_JUGADOR_2		;4255
	ld (hl),004h		;4257
INTENTO_DEL_JUGADOR_2:
	inc hl			;4259
	ld (hl),001h		;425a   ; intento 1 del jugador 2
	rrca			;425c
	jr nc,MONTA_EL_DECORADO		;425d
	ld (hl),004h		;425f   ; lo mismo para el jugador 2
MONTA_EL_DECORADO:
	di			;4261
	ld hl,04f24h		;4262   ; la lista de guiones de esta prueba
	call CASILLA_DE_LA_PRUEBA		;4265
	ld b,(hl)			;4268   ; cuantos guiones lleva
	inc hl			;4269
MONTA_UN_GUION:
	push bc			;426a
	di			;426b
	call GUION_LARGO		;426c   ; uno por vuelta, dejando entrar la interrupcion entre medias
	ei			;426f
	pop bc			;4270
	djnz MONTA_UN_GUION		;4271
	ld hl,04f1ch		;4273   ; y detras, el rotulo de la pizarra
	call CASILLA_DE_LA_PRUEBA		;4276
	di			;4279
	call GUION_LARGO		;427a
	ld hl,05026h		;427d   ; el marco del marcador de arriba
	call GUION_CORTO		;4280   ; el rotulo del segundo jugador si lo hay
	call ES_PRUEBA_DE_DISTANCIA		;4283   ; en jabalina y altura se anade la columna de intentos
	jr nz,PINTA_EL_ROTULO_DE_DOS		;4286
	rrca			;4288
	jr c,PINTA_EL_TURNO		;4289
	ld hl,05135h		;428b
	jr PINTA_EL_MARCO_Y_EL_TURNO		;428e
PINTA_EL_ROTULO_DE_DOS:
	ld hl,050f6h		;4290
PINTA_EL_MARCO_Y_EL_TURNO:
	call GUION_CORTO		;4293   ; pinta el marco del marcador
	ld a,(0e016h)		;4296   ; la prueba en curso
	cp 003h		;4299   ; en el salto de altura el turno va en otra casilla
	jr nz,PINTA_EL_TURNO		;429b
	ld hl,0e057h		;429d
	ld de,0e099h		;42a0
	push hl			;42a3
	call COPIA_DOS_BYTES		;42a4
	pop hl			;42a7
	call COPIA_DOS_BYTES		;42a8
PINTA_EL_TURNO:
	ld hl,0514ah		;42ab
	ld de,078a2h		;42ae   ; la casilla del jugador 1
	ld b,003h		;42b1
	ld a,(0e021h)		;42b3
	rrca			;42b6   ; prueba impar: le toca al 1
	jr c,PINTA_LA_CASILLA_DEL_TURNO		;42b7
	rrca			;42b9
	jr nc,EMPIEZA_EL_INTENTO		;42ba
	ld e,0c2h		;42bc   ; si no, la casilla del jugador 2
PINTA_LA_CASILLA_DEL_TURNO:
	call SUBE_BYTES_SEGURO		;42be
EMPIEZA_EL_INTENTO:
	call BORRA_LA_FILA_DE_LA_MARCA		;42c1   ; borra la fila de la marca
	call PINTA_LOS_TANTOS		;42c4   ; pinta los tantos
	ld hl,0e051h		;42c7   ; la marca a batir de esta ronda
	call SALTA_A_LA_FILA_DE_LA_PRUEBA		;42ca
	ld a,(0e016h)		;42cd
	cp 003h		;42d0
	jr nz,PINTA_LA_MARCA_A_BATIR		;42d2
	ex de,hl			;42d4
	ld hl,0e099h		;42d5
	call A_QUIEN_LE_TOCA		;42d8
	jr z,GUARDA_LA_MARCA_A_BATIR		;42db
	inc hl			;42dd
	inc hl			;42de
GUARDA_LA_MARCA_A_BATIR:
	push hl			;42df
	call COPIA_DOS_BYTES		;42e0
	pop hl			;42e3
PINTA_LA_MARCA_A_BATIR:
	ld de,07877h		;42e4   ; en la casilla de QUALIFY
	call PINTA_MARCA_SIN_INTERRUPCION		;42e7
	ld hl,0e041h		;42ea   ; el record del mundo de esta prueba
	call SALTA_A_LA_FILA_DE_LA_PRUEBA		;42ed
	ld e,033h		;42f0
	call PINTA_MARCA_SIN_INTERRUPCION		;42f2
	ld de,05a40h		;42f5   ; borra los patrones de sprite de 0x1A40
	ld b,000h		;42f8
	ld c,b			;42fa
	call REPITE_BYTE_SEGURO		;42fb
	call BORRA_LOS_HUECOS_DE_CIFRA		;42fe   ; sube los ceros de la fuente a los cuatro huecos de cifra
	ld hl,0e0a0h		;4301   ; limpia el estado de los dos atletas
	ld bc,000bfh		;4304
	call LIMPIA_MEMORIA		;4307
	ld hl,0e200h		;430a   ; y el trozo de 0xE200
	ld c,01fh		;430d
	call LIMPIA_MEMORIA		;430f
	ld h,c			;4312
	ld l,c			;4313
	ld (0e028h),hl		;4314
	ld b,002h		;4317
	ld hl,0e0f2h		;4319
	ld a,010h		;431c
COLOCA_LOS_DOS_ATLETAS:
	ld (hl),0cfh		;431e   ; fila 0xCF, o sea el suelo
	inc hl			;4320
	inc hl			;4321
	ld (hl),a			;4322   ; columna 0x10 el primero y 0x20 el segundo
	ld l,0f6h		;4323   ; salta a la ficha del segundo
	ld a,020h		;4325
	djnz COLOCA_LOS_DOS_ATLETAS		;4327
	call FICHA_DEL_QUE_JUEGA		;4329   ; la ficha del atleta al que le toca
	ld (hl),078h		;432c   ; columna 0x78
	inc hl			;432e
	ld (hl),040h		;432f
	call ES_PRUEBA_IMPAR		;4331   ; en las pruebas impares
	jr nc,PONE_LA_POSTURA_DE_ESPERA		;4334
	ld (hl),020h		;4336
PONE_LA_POSTURA_DE_ESPERA:
	inc hl			;4338
	ld (hl),006h		;4339
	jr nc,MIRA_SI_HAY_TABLA_DE_INTENTOS		;433b
	ld (hl),00ch		;433d
MIRA_SI_HAY_TABLA_DE_INTENTOS:
	call ES_PRUEBA_DE_DISTANCIA		;433f   ; en jabalina y altura se pinta la tabla de intentos
	jr z,MONTA_LOS_ACTORES_Y_SIGUE		;4342
	ld hl,05113h		;4344
	call GUION_CORTO		;4347
MONTA_LOS_ACTORES_Y_SIGUE:
	call MONTA_LOS_ACTORES_DE_LA_PRUEBA		;434a   ; sube las figuras de los actores
	call MONTA_LOS_ACTORES		;434d   ; y el decorado que se mueve
	call ES_PRUEBA_DE_DISTANCIA		;4350   ; en las pruebas de distancia hay que pintar la lista de intentos
	jr z,SUBE_LOS_COLORES_DE_LOS_SPRITES		;4353
	call FILA_DEL_INTENTO		;4355   ; el intento en curso del jugador que juega
	ld b,(hl)			;4358
	ld de,07897h		;4359   ; la fila de la tabla de intentos
	ld hl,0e061h		;435c
	call FILA_DEL_MARCADOR_DE		;435f   ; y salta a la ficha de ese intento
	dec b			;4362   ; con un solo intento no hay lista que pintar
	jr z,SUBE_LOS_COLORES_DE_LOS_SPRITES		;4363
PINTA_UN_INTENTO:
	push bc			;4365
	ld a,(hl)			;4366   ; con marca a cero el intento aun no se ha hecho
	or a			;4367
	jr z,INTENTO_SIN_MARCA		;4368
	push de			;436a
	call PINTA_MARCA_SIN_INTERRUPCION		;436b   ; pinta la marca de ese intento
	pop de			;436e
	inc hl			;436f
	call BAJA_UNA_FILA		;4370   ; y baja a la fila siguiente
	jr SIGUIENTE_INTENTO_DE_LA_LISTA		;4373
INTENTO_SIN_MARCA:
	inc hl			;4375
	inc hl			;4376
	inc hl			;4377
	push hl			;4378   ; se guarda la fila
	ld hl,05140h		;4379   ; el rotulo de fallo
	ld b,006h		;437c
	call SUBE_BYTES_SEGURO		;437e   ; seis caracteres
	call BAJA_UNA_FILA		;4381
	pop hl			;4384
SIGUIENTE_INTENTO_DE_LA_LISTA:
	pop bc			;4385
	djnz PINTA_UN_INTENTO		;4386
SUBE_LOS_COLORES_DE_LOS_SPRITES:
	di			;4388
	ld hl,05161h		;4389   ; la tabla de colores de los 26 sprites
	ld de,07b00h		;438c   ; empezando en el sprite 0
	ld bc,01afeh		;438f   ; 26 sprites, columna inicial 0xFE; el hermano subia 32
	call FIJA_ESCRITURA		;4392
	exx			;4395
	ld a,(00006h)		;4396   ; el puerto de datos del VDP en el juego alterno
	ld c,a			;4399
	exx			;439a
UN_SPRITE:
	ld a,0d1h		;439b   ; fila 0xD1: fuera de la pantalla
	exx			;439d
	out (c),a		;439e
	exx			;43a0
	ld a,c			;43a1   ; la columna avanza de cuatro en cuatro
	add a,004h		;43a2
	ld c,a			;43a4
	exx			;43a5
	out (c),a		;43a6   ; columna
	exx			;43a8
	push hl			;43a9   ; un respiro para que al VDP le de tiempo
	pop hl			;43aa
	exx			;43ab
	out (c),a		;43ac   ; y patron, que aqui lleva el mismo valor
	exx			;43ae
	ld a,(hl)			;43af   ; el color sale de la tabla
	inc hl			;43b0
	exx			;43b1
	out (c),a		;43b2
	exx			;43b4
	djnz UN_SPRITE		;43b5
	ei			;43b7
	call MIRA_EL_CANAL_1		;43b8
	inc a			;43bb
	ld (0e003h),a		;43bc   ; ya hay partida
	ld (0e017h),a		;43bf   ; y demo apagada
	ld a,004h		;43c2   ; cuatro puntos de espera
	call ESPERA_PUNTOS		;43c4
	di			;43c7
	ld a,091h		;43c8
	call PIDE_UN_SONIDO		;43ca
	ei			;43cd
	xor a			;43ce
	ld (0e017h),a		;43cf
BUCLE_DE_LA_PRUEBA:
	call ES_LA_DEMO		;43d2   ; en la demo, cualquier tecla vuelve al titulo
	jr z,PINTA_LA_MARCA		;43d5
	ld hl,0e005h		;43d7   ; si han tocado una tecla se vuelve al titulo
	ld a,(hl)			;43da
	or a			;43db
	jr z,MIRA_LA_MARCA_DE_LA_MAQUINA		;43dc
	inc hl			;43de
	ld (hl),a			;43df
RECORTA_EL_ANGULO_2:
	xor a			;43e0
	ld (0e003h),a		;43e1
	jp ARRANQUE_DE_LA_PRESENTACION		;43e4   ; vuelta a la presentacion
MIRA_LA_MARCA_DE_LA_MAQUINA:
	ld a,(0e029h)		;43e7   ; el estado del atleta del jugador 2
	rlca			;43ea
	jr nc,PINTA_LA_MARCA		;43eb
	ld a,(0e0a1h)		;43ed   ; la velocidad del jugador 1
	cp 030h		;43f0   ; con 0x30 justo se usa la escala corta
	jr z,RECORTA_EL_ANGULO_2		;43f2
PINTA_LA_MARCA:
	call ES_PRUEBA_DE_DISTANCIA		;43f4
	jr nz,PINTA_LA_DISTANCIA		;43f7
	ld de,07a47h		;43f9   ; la casilla del reloj
	ld hl,0e0e3h		;43fc
	call PINTA_DOS_CARACTERES		;43ff
	ld e,058h		;4402
	ld l,0adh		;4404
	call PINTA_DOS_CARACTERES		;4406
	jp REPARTE_EL_TRABAJO_DEL_CUADRO		;4409
PINTA_LA_DISTANCIA:
	ld hl,0e0adh		;440c
	ld de,07af9h		;440f   ; la casilla de los metros
	call PINTA_DOS_CARACTERES		;4412
	dec hl			;4415
	ld de,07ae7h		;4416   ; y el angulo, justo antes
	ld a,(hl)			;4419
	or a			;441a
	jr nz,RECORTA_EL_ANGULO		;441b   ; con angulo cero no hay flecha que pintar
	ld bc,00ee0h		;441d   ; borra los 0x0E caracteres de la barra
	inc de			;4420
	call REPITE_BYTE_SEGURO		;4421
	dec de			;4424
	jr PINTA_EL_TRAMO_A_MEDIAS		;4425
RECORTA_EL_ANGULO:
	cp 010h		;4427   ; por encima de 0x10 la barra se acorta seis
	jr c,PINTA_LA_BARRA_DEL_ANGULO		;4429
	sub 006h		;442b
PINTA_LA_BARRA_DEL_ANGULO:
	ld c,0e7h		;442d   ; el caracter de la barra llena
	ld b,a			;442f   ; tantos como diga el angulo
	push af			;4430
	call REPITE_BYTE_SEGURO		;4431   ; los pinta
	pop af			;4434
	cp 00fh		;4435   ; con quince tramos la barra esta llena
	jr z,REPARTE_EL_TRABAJO_DEL_CUADRO		;4437
	push af			;4439
	call BAJA_HL_EN_DE		;443a   ; se corre al siguiente hueco
	pop af			;443d
	ld b,a			;443e
	ld a,00fh		;443f   ; lo que falta hasta quince
	sub b			;4441
	jr z,PINTA_EL_TRAMO_A_MEDIAS		;4442
	ld b,a			;4444
	dec b			;4445   ; uno menos, que lleva el tramo a medias
	jr z,PINTA_EL_TRAMO_A_MEDIAS		;4446
	ld c,0e0h		;4448   ; caracter 0xE0: la barra vacia
	push af			;444a
	inc de			;444b   ; y se rellena el resto
	call REPITE_BYTE_SEGURO		;444c
	dec de			;444f
	pop af			;4450
PINTA_EL_TRAMO_A_MEDIAS:
	ld b,000h		;4451
	dec hl			;4453   ; la cifra de abajo del angulo
	ld a,(hl)			;4454
	or a			;4455
	jr z,PINTA_EL_TRAMO_SUELTO		;4456   ; con cero no hay tramo a medias
	ld c,015h		;4458   ; cada tramo son quince centesimas
CUENTA_LOS_TRAMOS_DE_LA_BARRA:
	inc b			;445a
	sub c			;445b   ; restando de quince en quince en BCD
	daa			;445c
	jr nc,CUENTA_LOS_TRAMOS_DE_LA_BARRA		;445d
PINTA_EL_TRAMO_SUELTO:
	ld a,0e0h		;445f   ; el primer caracter de la escala de barras
	add a,b			;4461
	ld b,001h		;4462   ; un solo caracter
	ld c,a			;4464
	call REPITE_BYTE_SEGURO		;4465
REPARTE_EL_TRABAJO_DEL_CUADRO:
	call ES_PRUEBA_DE_DISTANCIA		;4468
	jp z,CUADRO_DE_LAS_PRUEBAS_DE_TIEMPO		;446b   ; en las vallas y los 1500 se va por otro lado
	call SUBE_EL_PATRON_DEL_OBJETO		;446e
	jr z,MIRA_EL_FIN_DEL_INTENTO_2		;4471
	ld de,07a35h		;4473   ; la casilla del resultado
	ld hl,0e033h		;4476
	call ES_PRUEBA_IMPAR		;4479   ; en las pruebas impares es la de la izquierda
	jr nc,PINTA_EL_RESULTADO_DEL_TIRO		;447c
	ld e,025h		;447e
PINTA_EL_RESULTADO_DEL_TIRO:
	call PINTA_UNA_CIFRA_SEGURA		;4480
MIRA_EL_FIN_DEL_INTENTO_2:
	call MIRA_EL_INTENTO_ACABADO		;4483
	jr nc,MIRA_EL_OBJETO_QUE_VUELA		;4486
PINTA_LA_UNIDAD:
	ld de,079e8h		;4488   ; el rotulo de la unidad
	ld hl,05146h		;448b
PINTA_EL_ROTULO_DE_UNIDAD:
	ld b,004h		;448e
	call SUBE_BYTES_SEGURO		;4490
	jr MIRA_SI_ACABO_EL_INTENTO		;4493
MIRA_EL_OBJETO_QUE_VUELA:
	call SUBE_EL_PATRON_DEL_OBJETO		;4495
	jr z,MIRA_SI_ACABO_EL_INTENTO		;4498
	call ES_PRUEBA_IMPAR		;449a
	jr nc,PINTA_LA_LISTA_DE_INTENTOS		;449d
MIRA_LA_LISTA_DE_INTENTOS:
	ld a,(0e200h)		;449f
	bit 1,a		;44a2
	jr z,MIRA_SI_ACABO_EL_INTENTO		;44a4
	call MIRA_EL_INTENTO_ACABADO		;44a6
	jr c,PINTA_LA_UNIDAD		;44a9
PINTA_LA_LISTA_DE_INTENTOS:
	call FILA_DEL_INTENTO		;44ab   ; el intento en curso
	ld a,(hl)			;44ae
	ld hl,0e030h		;44af
	ld de,07877h		;44b2
	push af			;44b5
	ld b,a			;44b6
BAJA_A_LA_FILA_DEL_INTENTO:
	call ES_PRUEBA_IMPAR		;44b7
	jr nc,BAJA_A_LA_FILA_QUE_TOCA		;44ba
	ld hl,0e057h		;44bc
BAJA_A_LA_FILA_QUE_TOCA:
	call BAJA_UNA_FILA		;44bf
	djnz BAJA_A_LA_FILA_QUE_TOCA		;44c2
	di			;44c4
	push hl			;44c5
	call PINTA_UNA_MARCA		;44c6   ; pinta la marca en la lista de intentos
	ld hl,0e061h		;44c9
	call FILA_DEL_MARCADOR_DE		;44cc
	pop de			;44cf
	pop af			;44d0
	call SALTA_N_FILAS_DE_TRES		;44d1   ; salta a la fila de ese intento
	ex de,hl			;44d4
	call COPIA_DOS_BYTES		;44d5   ; y la guarda
	ei			;44d8
MIRA_SI_ACABO_EL_INTENTO:
	ld a,(0e02eh)		;44d9   ; bit 0 de 0xE02E: se acabo el intento
	rrca			;44dc
	jp nc,MIRA_SI_SE_ACABO_LA_PRUEBA		;44dd
	ld hl,0e06bh		;44e0   ; la fila de la mejor marca del jugador
	call FILA_DEL_MARCADOR_DE		;44e3
	push hl			;44e6
	call FILA_DEL_MARCADOR		;44e7   ; la casilla de la marca de este intento
	ex de,hl			;44ea
	call FILA_DEL_INTENTO		;44eb
	ex de,hl			;44ee
	ld a,(de)			;44ef
	call SALTA_N_FILAS_DE_TRES		;44f0
	ex de,hl			;44f3
	pop hl			;44f4
	push de			;44f5
	call COMPARA_TRES_BYTES		;44f6   ; compara la marca nueva con la que habia
	jr c,COMPARA_CON_LA_MARCA_A_BATIR		;44f9   ; si no la mejora, no se toca
	ex de,hl			;44fb
	inc hl			;44fc
	inc de			;44fd
	call COPIA_DOS_BYTES		;44fe   ; y si la mejora, la sustituye
COMPARA_CON_LA_MARCA_A_BATIR:
	pop de			;4501
	ld hl,0e052h		;4502   ; la marca a batir de la ronda
	call SALTA_A_LA_FILA_DE_LA_PRUEBA		;4505
	call COMPARA_TRES_BYTES		;4508   ; compara la marca con ella
	jp nc,INTENTO_QUE_CLASIFICA		;450b   ; si no llega, intento fallido
	call MIRA_EL_INTENTO_ACABADO		;450e
	jr nc,MARCA_EL_INTENTO_QUE_VALE		;4511
	ld hl,0e023h		;4513
	call FILA_DEL_INTENTO_DE		;4516   ; sube el contador de intentos
	inc (hl)			;4519
	call FILA_DEL_INTENTO		;451a
	ld b,(hl)			;451d   ; y borra su fila
	ld de,07877h		;451e
	ld hl,05140h		;4521
BORRA_LA_FILA_DEL_INTENTO:
	call BAJA_UNA_FILA		;4524
	djnz BORRA_LA_FILA_DEL_INTENTO		;4527
	ld b,006h		;4529
	call SUBE_BYTES_SEGURO		;452b   ; con los seis caracteres del rotulo de fallo
MARCA_EL_INTENTO_QUE_VALE:
	di			;452e
INTENTO_QUE_NO_CLASIFICA:
	ld a,002h		;452f   ; resultado 2: vale pero no clasifica
	ld (0e02ah),a		;4531
	ld hl,0e020h		;4534
	ld b,(hl)			;4537
	call A_QUIEN_LE_TOCA		;4538   ; el jugador que juega
	jr z,MIRA_EL_BIT_DE_CLASIFICADO		;453b
	rrc b		;453d
MIRA_EL_BIT_DE_CLASIFICADO:
	rrc b		;453f   ; mira su bit de clasificado
	jr c,GUARDA_LA_MARCA		;4541
PINTA_EL_CARTEL_DE_FALLO:
	call CASILLA_DEL_CARTEL_2		;4543   ; la casilla del cartel
	ld (hl),0b9h		;4546   ; caracter 0xB9: el de fallo
	jr GUARDA_LA_MARCA		;4548
INTENTO_QUE_CLASIFICA:
	ld hl,0e020h		;454a
	call A_QUIEN_LE_TOCA		;454d   ; el jugador que juega
	add a,001h		;4550
	or (hl)			;4552
	ld (hl),a			;4553   ; le pone su bit de clasificado
	call ES_PRUEBA_IMPAR		;4554
	jr nc,SUENA_EL_RECORD		;4557
	ld hl,0e09ah		;4559
	call A_QUIEN_LE_TOCA		;455c
	jr z,SUBE_LA_MARCA_DOS		;455f
	inc hl			;4561
	inc hl			;4562
SUBE_LA_MARCA_DOS:
	ld a,(hl)			;4563   ; la marca sube dos en BCD
	add a,002h		;4564
	daa			;4566
	ld (hl),a			;4567
	ld a,000h		;4568
	dec hl			;456a   ; con acarreo al byte de arriba
	adc a,(hl)			;456b
	ld (hl),a			;456c
SUENA_EL_RECORD:
	di			;456d
	call RESULTADO_CLASIFICADO		;456e   ; sonido 2: la fanfarria de clasificacion
	call CASILLA_DEL_CARTEL_2		;4571
	ld (hl),0bah		;4574   ; caracter 0xBA: el de clasificado
GUARDA_LA_MARCA:
	ei			;4576
	ld hl,0e02eh		;4577
	res 0,(hl)		;457a   ; baja la bandera de intento acabado
	call CASILLA_DEL_CARTEL		;457c
	ld de,078a7h		;457f   ; la casilla de la marca en el marcador
	ld hl,0e08fh		;4582
	ld a,(0e021h)		;4585
	bit 1,a		;4588   ; mira si el jugador 2 sigue en juego
	jr nz,PINTA_LA_MARCA_DEL_QUE_JUEGA		;458a
	ld e,0c7h		;458c   ; si no, la casilla del otro
	ld l,094h		;458e
	rrca			;4590
	jr c,PINTA_LA_MARCA_DEL_QUE_JUEGA		;4591
	call PINTA_MARCA_Y_UNIDAD		;4593   ; pinta la marca del jugador 1 en su sitio
	ld l,08fh		;4596
	ld e,0a7h		;4598
PINTA_LA_MARCA_DEL_QUE_JUEGA:
	call PINTA_MARCA_Y_UNIDAD		;459a
	ld hl,0e042h		;459d   ; la mejor marca de la prueba
	call SALTA_A_LA_FILA_DE_LA_PRUEBA		;45a0
	push hl			;45a3
	call FILA_DEL_MARCADOR		;45a4   ; y la casilla donde va
	ex de,hl			;45a7
	call FILA_DEL_INTENTO		;45a8
	ex de,hl			;45ab
	ld a,(de)			;45ac
	call SALTA_N_FILAS_DE_TRES		;45ad
	ex de,hl			;45b0
	pop hl			;45b1
	call COMPARA_TRES_BYTES		;45b2   ; compara la marca nueva con el record
	jr c,MIRA_SI_SE_ACABO_LA_PRUEBA		;45b5
	ex de,hl			;45b7
GUARDA_EL_RECORD_NUEVO:
	inc hl			;45b8   ; y si lo bate, lo sustituye
	inc de			;45b9
	push de			;45ba
	call COPIA_DOS_BYTES		;45bb
	pop hl			;45be
	ld de,07833h		;45bf   ; en la casilla de WORLD RECORD
	call PINTA_MARCA_SIN_INTERRUPCION		;45c2
	di			;45c5
	ld a,096h		;45c6
	call PIDE_UN_SONIDO		;45c8
	ei			;45cb
	ld hl,0e014h		;45cc   ; enciende el parpadeo del rotulo
	ld (hl),001h		;45cf
	ld a,00ah		;45d1   ; y espera diez puntos
	ld (0e001h),a		;45d3
ESPERA_AL_ROTULO:
	ld a,(hl)			;45d6
	or a			;45d7
	jr nz,ESPERA_AL_ROTULO		;45d8
MIRA_SI_SE_ACABO_LA_PRUEBA:
	ld a,(0e02eh)		;45da
	bit 1,a		;45dd   ; bit 1 de 0xE02E: la prueba ha terminado
	jp z,BUCLE_DE_LA_PRUEBA		;45df   ; si no, otra vuelta
	di			;45e2
	xor a			;45e3   ; limpia las banderas de la prueba
	ld (0e02eh),a		;45e4
	xor a			;45e7
	ld h,a			;45e8
	ld l,a			;45e9
	ld (0e02ah),hl		;45ea   ; y los resultados de los dos jugadores
	ld (0e02ch),hl		;45ed
	ld (0e030h),hl		;45f0
	ld (0e003h),a		;45f3   ; deja de pintar el marcador
	ld (0e017h),a		;45f6
	ei			;45f9
	ld a,003h		;45fa   ; tres puntos de espera
	call ESPERA_PUNTOS		;45fc
	di			;45ff
	ld a,0a2h		;4600
	call PIDE_UN_SONIDO		;4602
	call MUEVE_EL_SONIDO		;4605   ; y para la musica
	ei			;4608
	call ES_PRUEBA_DE_DISTANCIA		;4609   ; si han tocado tecla, al titulo
	jr z,MIRA_QUIEN_SIGUE		;460c
	call FILA_DEL_INTENTO		;460e   ; sube el intento del jugador que juega
	inc (hl)			;4611
	call CAMBIA_DE_JUGADOR		;4612   ; y cambia de jugador si toca
	ld hl,0e025h		;4615
	ld a,004h		;4618   ; con el cuarto intento se acaba
	cp (hl)			;461a
	jp nz,EMPIEZA_EL_INTENTO		;461b   ; mientras quede intento al jugador 1, otra vuelta
	inc hl			;461e
	cp (hl)			;461f
	jp nz,EMPIEZA_EL_INTENTO		;4620   ; o al jugador 2
MIRA_QUIEN_SIGUE:
	ld hl,0e021h		;4623
	bit 0,(hl)		;4626   ; el jugador 2 sigue en juego
	jr nz,MIRA_AL_JUGADOR_1		;4628
	dec hl			;462a
	bit 0,(hl)		;462b   ; si el 1 tampoco, se acabo la partida
	jp z,SE_ACABO_LA_PARTIDA		;462d
	inc hl			;4630
	bit 1,(hl)		;4631   ; y si el 2 no se ha clasificado, tambien
	jr nz,SIGUIENTE_RONDA		;4633
MIRA_AL_JUGADOR_1:
	dec hl			;4635
	bit 1,(hl)		;4636   ; el jugador 1 se ha clasificado
	jp z,SE_ACABO_LA_PARTIDA		;4638
SIGUIENTE_RONDA:
	call PINTA_LOS_TANTOS_GANADOS		;463b   ; pinta los tantos que se han ganado
	ld hl,0e015h		;463e
	inc (hl)			;4641   ; sube la ronda
	inc hl			;4642
	inc (hl)			;4643   ; y la prueba
	ld a,(hl)			;4644
	cp 005h		;4645   ; tras la cuarta prueba
	jr nz,MIRA_SI_QUEDAN_RONDAS		;4647
	ld (hl),001h		;4649   ; se vuelve a la primera
MIRA_SI_QUEDAN_RONDAS:
	dec hl			;464b
	ld a,(hl)			;464c
	cp 00dh		;464d   ; las doce rondas
	jr nc,SUENA_LA_PRUEBA_NUEVA		;464f
	ld hl,0500ah		;4651   ; la marca a batir de la ronda nueva
	dec a			;4654
	rlca			;4655   ; con dos bytes por ronda
	call SUMA_A_A_HL		;4656
	ex de,hl			;4659
	ld hl,0e051h		;465a   ; y la casilla donde va
	call SALTA_A_LA_FILA_DE_LA_PRUEBA		;465d
	ex de,hl			;4660
	call COPIA_DOS_BYTES		;4661
SUENA_LA_PRUEBA_NUEVA:
	ld a,(0e016h)		;4664
	dec a			;4667
	ld a,09fh		;4668
	jr z,SUENA_Y_LIMPIA		;466a
	ld a,099h		;466c
SUENA_Y_LIMPIA:
	di			;466e
	call PIDE_UN_SONIDO		;466f
	ei			;4672
	ld hl,0e022h		;4673   ; borra los resultados del intento
	ld bc,0000fh		;4676
	call LIMPIA_MEMORIA		;4679
	ld hl,0e089h		;467c   ; y las marcas que se pintan
	ld c,010h		;467f
	call LIMPIA_MEMORIA		;4681
	ld hl,0e060h		;4684   ; y el trozo de marcador
	ld c,01bh		;4687
	call LIMPIA_MEMORIA		;4689
	xor a			;468c
	ld (0e020h),a		;468d   ; nadie clasificado todavia
	call MIRA_EL_CANAL_1		;4690
	jp MONTA_LA_PRUEBA		;4693   ; y a montar la prueba nueva
SE_ACABO_LA_PARTIDA:
	ld hl,0e022h		;4696
	ld a,(0e021h)		;4699   ; quien seguia en juego
	ld b,a			;469c
	call MIRA_EL_INTENTO_ACABADO		;469d
	jr nc,MIRA_EL_INTENTO_DEL_JUGADOR_2		;46a0
SIGUE_EL_JUGADOR_1:
	ld (hl),001h		;46a2   ; marca al jugador 1 como el que sigue
	set 0,b		;46a4
	jr CARTEL_DE_FIN		;46a6
MIRA_EL_INTENTO_DEL_JUGADOR_2:
	ld a,(0e02dh)		;46a8
	rrca			;46ab
	jr nc,MIRA_QUIEN_ESTABA_EN_JUEGO		;46ac
SIGUE_EL_JUGADOR_2:
	ld (hl),002h		;46ae   ; marca al jugador 2
	set 1,b		;46b0
	jr CARTEL_DE_FIN		;46b2
MIRA_QUIEN_ESTABA_EN_JUEGO:
	ld a,b			;46b4
	rrca			;46b5
	jr c,SIGUE_EL_JUGADOR_2		;46b6
	rrca			;46b8
	jr c,SIGUE_EL_JUGADOR_1		;46b9
	ld a,(0e020h)		;46bb   ; los bits de clasificado
	rrca			;46be
	jr c,MIRA_AL_SEGUNDO_CLASIFICADO		;46bf
	set 0,b		;46c1
	set 0,(hl)		;46c3
MIRA_AL_SEGUNDO_CLASIFICADO:
	rrca			;46c5
	jr c,CARTEL_DE_FIN		;46c6
	set 1,b		;46c8
	set 1,(hl)		;46ca
CARTEL_DE_FIN:
	push bc			;46cc
	di			;46cd
	ld a,09ch		;46ce
	call PIDE_UN_SONIDO		;46d0
	ei			;46d3
	ld hl,0514dh		;46d4   ; el cartel de GAME OVER
	call GUION_CORTO		;46d7
	ld a,(0e022h)		;46da   ; quien sigue
	dec a			;46dd
	jr z,ESPERA_A_QUE_CALLE		;46de
	dec a			;46e0
	jr z,BORRA_EL_CARTEL		;46e1
	ld a,003h		;46e3   ; tres puntos de espera
	call ESPERA_PUNTOS		;46e5
	call MONTA_LOS_ACTORES		;46e8   ; vuelve a pintar el decorado
	ei			;46eb
	ld a,002h		;46ec   ; dos puntos mas
	call ESPERA_PUNTOS		;46ee
	ld hl,0514dh		;46f1   ; y el cartel otra vez
	call GUION_CORTO		;46f4
BORRA_EL_CARTEL:
	ld de,0798ah		;46f7   ; la fila del cartel
	ld bc,001f2h		;46fa   ; 0x1F caracteres en blanco
	call REPITE_BYTE_SEGURO		;46fd
ESPERA_A_QUE_CALLE:
	call MIRA_EL_CANAL_1		;4700
	pop bc			;4703
	ld a,b			;4704
	ld (0e021h),a		;4705   ; deja apuntado quien sigue
	cp 003h		;4708
	jr z,FIN_DE_LA_PARTIDA		;470a   ; con los dos fuera se acabo del todo
	and 001h		;470c
	ld (0e011h),a		;470e   ; y con uno, ese pasa a ser el jugador
	ld hl,0e02ch		;4711
	bit 0,(hl)		;4714   ; si al jugador 1 le quedaba intento
	jp nz,OTRA_VEZ_A_LA_LINEA		;4716
	inc hl			;4719
	bit 0,(hl)		;471a   ; o al 2
	jp nz,OTRA_VEZ_A_LA_LINEA		;471c
	jp SIGUIENTE_RONDA		;471f   ; se sigue jugando
FIN_DE_LA_PARTIDA:
	call PINTA_LOS_TANTOS_GANADOS		;4722   ; los tantos finales
	ld a,003h		;4725   ; tres puntos de espera
	call ESPERA_PUNTOS		;4727
	jp ARRANQUE_DE_LA_PRESENTACION		;472a   ; y a la presentacion
CUADRO_DE_LAS_PRUEBAS_DE_TIEMPO:
	ld a,(0e029h)		;472d
	rlca			;4730   ; MEDIDO: aqui solo se entra en la demo. El bit 7 de 0xE029 esta puesto tambien en partida, pero entonces manda 0xE002 y este trozo no corre
	jp nc,MIRA_EL_FIN_DEL_INTENTO		;4731
	ld hl,0e0a1h		;4734   ; la marca de la maquina
	call MIRA_SI_ES_PRUEBA_IMPAR		;4737
	ld de,078b4h		;473a   ; y en la de al lado
	call PINTA_UNA_CIFRA_SEGURA		;473d
	ld e,0b7h		;4740
	call PINTA_UNA_CIFRA_SEGURA		;4742
MIRA_EL_FIN_DEL_INTENTO:
	ld hl,0e023h		;4745
	call MIRA_EL_INTENTO_ACABADO		;4748
	jr c,SUBE_EL_INTENTO_DE_TIEMPO		;474b
	inc hl			;474d   ; si no, se mira el 2
	ld a,(0e02dh)		;474e
	rrca			;4751
	jr nc,MIRA_EL_FIN_DEL_TIRO		;4752
SUBE_EL_INTENTO_DE_TIEMPO:
	xor a			;4754
	ld (0e003h),a		;4755   ; deja de pintar el marcador
	inc (hl)			;4758   ; sube el intento
	ld b,(hl)			;4759
	ld de,078a7h		;475a   ; la fila del cartel
	call MIRA_EL_INTENTO_ACABADO		;475d
	jr c,PINTA_EL_CARTEL_DE_TIEMPO		;4760   ; en las pruebas impares va a la izquierda
	ld e,0c7h		;4762
PINTA_EL_CARTEL_DE_TIEMPO:
	ld c,0beh		;4764   ; caracter 0xBE
	call REPITE_BYTE_SEGURO		;4766
	ld a,(hl)			;4769   ; con tres intentos gastados se acabo
	cp 003h		;476a
	jp z,SE_ACABO_LA_PARTIDA		;476c
OTRA_VEZ_A_LA_LINEA:
	ld hl,00000h		;476f   ; limpia las banderas de los dos jugadores
	ld (0e02ch),hl		;4772
	jp PINTA_EL_TURNO		;4775   ; y a montar la prueba otra vez
MIRA_EL_FIN_DEL_TIRO:
	ld a,(0e02eh)		;4778
	rrca			;477b   ; bit 0 de 0xE02E: el tiro ha acabado
	jp nc,MIRA_SI_SE_ACABO_LA_PRUEBA		;477c
	ld hl,0e0a9h		;477f   ; la marca que ha salido
	call MIRA_SI_ES_PRUEBA_IMPAR		;4782   ; a la casilla de pintado del jugador 1
	ld de,0e06ah		;4785
	call COPIA_DOS_BYTES		;4788   ; y a la del 2
	ld l,0a5h		;478b
	call MIRA_SI_ES_PRUEBA_IMPAR		;478d
	ld e,07ah		;4790
	call COPIA_DOS_BYTES		;4792
	call CASILLA_DEL_CARTEL		;4795
	ld de,078a5h		;4798   ; la fila del reloj
	ld bc,00a00h		;479b   ; diez caracteres en blanco
	call REPITE_BYTE_SEGURO		;479e
	ld e,0c5h		;47a1   ; y la del segundo jugador
	ld b,00ah		;47a3
	call REPITE_BYTE_SEGURO		;47a5
	ld de,0e0aah		;47a8   ; la marca a batir
	ld hl,0e020h		;47ab
	set 7,(hl)		;47ae   ; bit 7 de 0xE020, que aqui hace de "clasifica"
	ld l,0a6h		;47b0
	ld b,003h		;47b2
	call COMPARA_N_BYTES		;47b4   ; compara los tres bytes
	jr nc,REPARTE_EL_RESULTADO		;47b7
	ld l,020h		;47b9
	res 7,(hl)		;47bb
REPARTE_EL_RESULTADO:
	ld hl,0e052h		;47bd   ; la marca de este intento
	call SALTA_A_LA_FILA_DE_LA_PRUEBA		;47c0
	ex de,hl			;47c3
	ld hl,0e06bh		;47c4
	push de			;47c7
	di			;47c8
	ld a,002h		;47c9
	ld (0e02ah),a		;47cb
	ld a,0b9h		;47ce   ; caracter 0xB9, el de fallo
	ld (0e091h),a		;47d0
	call COMPARA_TRES_BYTES		;47d3   ; compara con la marca a batir
	jr c,REPARTE_EL_DEL_JUGADOR_2		;47d6
	ld a,0bah		;47d8   ; caracter 0xBA, el de clasificado
	ld (0e091h),a		;47da
	call RESULTADO_CLASIFICADO		;47dd   ; sonido 2: la fanfarria
	ld hl,0e020h		;47e0
	set 0,(hl)		;47e3   ; y le pone su bit de clasificado
REPARTE_EL_DEL_JUGADOR_2:
	pop de			;47e5
	ld hl,0e07bh		;47e6
	ld a,002h		;47e9
	ld (0e02bh),a		;47eb   ; lo mismo para el jugador 2
	ld a,0b9h		;47ee
	ld (0e096h),a		;47f0
	call COMPARA_TRES_BYTES		;47f3
	jr c,REPARTE_LOS_TANTOS		;47f6
	ld a,0bah		;47f8
	ld (0e096h),a		;47fa
	ld a,001h		;47fd
	ld (0e02bh),a		;47ff
	call SUENA_LA_FANFARRIA		;4802   ; sonido 2
	ld hl,0e020h		;4805
	set 1,(hl)		;4808
REPARTE_LOS_TANTOS:
	ld hl,0e02ah		;480a
	ld a,(hl)			;480d   ; el resultado del jugador 1
	dec a			;480e
	jr nz,PINTA_LAS_DOS_MARCAS		;480f   ; con resultado 1 no se toca
	inc hl			;4811
	ld a,(hl)			;4812
MIRA_AL_SEGUNDO:
	dec a			;4813
	jr nz,PINTA_LAS_DOS_MARCAS		;4814
	ld a,(0e020h)		;4816   ; bit 7 de 0xE020
	dec hl			;4819
	inc (hl)			;481a   ; sube el resultado del jugador 1
	rlca			;481b
	jr c,PINTA_LAS_DOS_MARCAS		;481c
	dec (hl)			;481e
	inc hl			;481f
	inc (hl)			;4820   ; o el del 2
PINTA_LAS_DOS_MARCAS:
	ei			;4821
	ld hl,0e02eh		;4822
	res 0,(hl)		;4825   ; baja la bandera de intento acabado
	ld l,08fh		;4827
	ld de,078a7h		;4829   ; en su casilla
	call PINTA_MARCA_Y_UNIDAD		;482c
	ld l,094h		;482f
	ld e,0c7h		;4831
	call PINTA_MARCA_Y_UNIDAD		;4833
	ld hl,0e042h		;4836   ; la mejor marca de la prueba
	call SALTA_A_LA_FILA_DE_LA_PRUEBA		;4839
	ex de,hl			;483c
	ld hl,0e07bh		;483d
	ld a,(0e021h)		;4840   ; el jugador 1 sigue en juego
	rrca			;4843
	jr c,ELIGE_LA_MARCA_A_COMPARAR		;4844
	ld l,06bh		;4846
	rrca			;4848
	jr c,ELIGE_LA_MARCA_A_COMPARAR		;4849
	ld a,(0e020h)		;484b   ; bit 7 de 0xE020
	rlca			;484e
	jr nc,ELIGE_LA_MARCA_A_COMPARAR		;484f
	ld l,07bh		;4851
ELIGE_LA_MARCA_A_COMPARAR:
	call COMPARA_TRES_BYTES		;4853   ; compara la marca con el record
	jp nc,GUARDA_EL_RECORD_NUEVO		;4856   ; si lo bate, se apunta
	jp MIRA_SI_SE_ACABO_LA_PRUEBA		;4859
CASILLA_DEL_CARTEL:
	ld hl,0e06ah		;485c   ; la del jugador 1
	ld de,0e08fh		;485f
	call COPIA_DOS_BYTES		;4862
	ld l,07ah		;4865
	ld e,094h		;4867
	call COPIA_DOS_BYTES		;4869
	ret			;486c
RESULTADO_CLASIFICADO:
	ld a,001h		;486d
	ld (0e02ah),a		;486f
SUENA_LA_FANFARRIA:
	inc a			;4872
	jp PIDE_UN_SONIDO		;4873
CASILLA_DEL_CARTEL_2:
	ld hl,0e091h		;4876
	call A_QUIEN_LE_TOCA		;4879   ; mira a quien le toca
	ret z			;487c
	ld l,096h		;487d
	ret			;487f
MIRA_SI_ES_PRUEBA_IMPAR:
	call ES_PRUEBA_IMPAR		;4880
	ret c			;4883
	dec hl			;4884
	ret			;4885
MIRA_EL_INTENTO_ACABADO:
	ld a,(0e02ch)		;4886
	rrca			;4889
	ret			;488a
MIRA_EL_CANAL_1:
	ld a,(0e162h)		;488b
	or a			;488e
	jr nz,MIRA_EL_CANAL_1		;488f
	ret			;4891
ES_LA_DEMO:
	ld a,(0e002h)		;4892   ; devuelve Z cuando no hay partida
	or a			;4895
	ret			;4896
PINTA_LOS_TANTOS_GANADOS:
	ld hl,0e02ch		;4897
	bit 0,(hl)		;489a   ; con el jugador 1 aun en el intento
	jr nz,MIRA_QUIEN_SE_LOS_LLEVA		;489c
	inc hl			;489e
	bit 0,(hl)		;489f   ; o el 2
	jr nz,MIRA_QUIEN_SE_LOS_LLEVA		;48a1
	call ES_PRUEBA_DE_DISTANCIA		;48a3   ; no se cuentan todavia
	jr nz,PUNTUA_Y_REPARTE		;48a6
	rrca			;48a8
	jr c,PUNTUA_Y_REPARTE		;48a9
	ld hl,0e06ah		;48ab   ; los tantos del jugador 1
	ld c,002h		;48ae
COGE_LOS_TANTOS:
	ld b,(hl)			;48b0
	ld (hl),000h		;48b1
SUMA_SESENTA_EN_BCD:
	inc hl			;48b3   ; el byte de abajo
	ld a,(hl)			;48b4
	add a,060h		;48b5   ; sube 0x60 en BCD
	daa			;48b7
	ld (hl),a			;48b8
	dec hl			;48b9
	jr nc,ACABA_DE_SUMAR		;48ba   ; con acarreo al de arriba
	inc (hl)			;48bc
ACABA_DE_SUMAR:
	djnz SUMA_SESENTA_EN_BCD		;48bd
MIRA_SI_PINTA_AL_JUGADOR_2:
	ld hl,0e07ah		;48bf
	dec c			;48c2
	jr nz,COGE_LOS_TANTOS		;48c3
PUNTUA_Y_REPARTE:
	call PUNTUA_EL_INTENTO		;48c5   ; tres bytes en BCD
MIRA_QUIEN_SE_LOS_LLEVA:
	ld a,(0e021h)		;48c8
	rrca			;48cb
	jr nc,SUMA_LOS_DEL_JUGADOR_1		;48cc   ; el jugador 1 sigue
	ld a,(0e022h)		;48ce
	dec a			;48d1
	jr z,SUMA_LOS_DEL_JUGADOR_1		;48d2
	cp 002h		;48d4
	jr nz,SUMA_LOS_DEL_JUGADOR_2		;48d6
SUMA_LOS_DEL_JUGADOR_1:
	ld hl,0e089h		;48d8   ; le suma los tantos del intento
	ld de,0e085h		;48db
	call SUMA_TRES_BYTES_BCD		;48de
SUMA_LOS_DEL_JUGADOR_2:
	ld a,(0e021h)		;48e1
	bit 1,a		;48e4   ; el jugador 2 sigue en juego
	jr z,SUMA_LOS_TANTOS_DEL_2		;48e6
	ld a,(0e022h)		;48e8   ; quien pasa de ronda
	sub 002h		;48eb   ; con 2 se le suman al 2
	jr z,SUMA_LOS_TANTOS_DEL_2		;48ed
	dec a			;48ef   ; y con 3, a los dos
	jr nz,PASA_LOS_TANTOS_A_LA_CUENTA		;48f0
SUMA_LOS_TANTOS_DEL_2:
	ld hl,0e08ch		;48f2   ; los tantos del jugador 2
	ld de,0e088h		;48f5   ; a su cuenta
	call SUMA_TRES_BYTES_BCD		;48f8   ; y al jugador 2 los suyos
PASA_LOS_TANTOS_A_LA_CUENTA:
	ld de,0e082h		;48fb   ; la cuenta del jugador 1
	ld hl,0e085h		;48fe
	ld b,002h		;4901
UNA_CUENTA_DE_TANTOS:
	push bc			;4903
	push de			;4904
	ld b,003h		;4905   ; compara la cuenta de este intento con la del anterior
	call COMPARA_N_BYTES		;4907
	jr nc,SIGUIENTE_JUGADOR		;490a
	inc de			;490c
	inc hl			;490d
	ld bc,00003h		;490e
	ldir		;4911   ; y se queda con la mayor
SIGUIENTE_JUGADOR:
	ld hl,0e088h		;4913
	pop de			;4916
	pop bc			;4917
	djnz UNA_CUENTA_DE_TANTOS		;4918
	ld a,006h		;491a   ; seis puntos de espera
	call ESPERA_PUNTOS		;491c
	xor a			;491f
	ld (0e022h),a		;4920   ; se acabo el reparto
	call BORRA_LA_FILA_DE_LA_MARCA		;4923   ; borra la fila de la marca
	jp PINTA_LOS_TANTOS		;4926   ; y vuelve a pintar los tantos
SUMA_TRES_BYTES_BCD:
	ld a,(hl)			;4929   ; los tres bytes que hay que sumar
	inc hl			;492a
	ld b,(hl)			;492b
	inc hl			;492c
	ld c,(hl)			;492d
	inc hl			;492e
	ex de,hl			;492f
	jp SUMA_BCD_DE_TRES_BYTES		;4930   ; y a la suma en BCD
MONTA_LOS_ACTORES:
	ld hl,04f2ch		;4933   ; el guion del marcador de esta prueba
	call CASILLA_DE_LA_PRUEBA		;4936
	call GUION_CORTO		;4939
	ld b,004h		;493c
	ld hl,0e120h		;493e
PINTA_UNA_FICHA_MAS:
	push bc			;4941   ; pinta la ficha del atleta
	push hl			;4942
	pop ix		;4943
	push hl			;4945
	call PINTA_SI_ESTA_ENCENDIDO		;4946   ; con sus dos partes
	pop hl			;4949
	ld a,010h		;494a   ; y salta a la ficha siguiente, 0x10 bytes mas alla
	call SUMA_A_A_HL		;494c
	pop bc			;494f
	djnz PINTA_UNA_FICHA_MAS		;4950
	ret			;4952
SALTA_A_LA_FILA_DE_LA_PRUEBA:
	ld a,(0e016h)		;4953   ; la prueba en curso
SALTA_N_FILAS_DE_TRES:
	dec a			;4956
	ret z			;4957   ; la primera no salta nada
	ld b,a			;4958
SALTA_TRES:
	ld a,003h		;4959   ; tres bytes por fila
	call SUMA_A_A_HL		;495b
	djnz SALTA_TRES		;495e
	ret			;4960
ES_PRUEBA_DE_DISTANCIA:
	ld a,(0e016h)		;4961   ; el bit 1 de la prueba separa 2 y 3 (distancia) de 1 y 4 (tiempo)
	bit 1,a		;4964
	ret			;4966
ES_PRUEBA_IMPAR:
	ld a,(0e016h)		;4967   ; el bit 0 separa 1 y 3 de 2 y 4
	rrca			;496a
	ret			;496b
PINTA_DOS_CARACTERES:
	call PINTA_UNA_CIFRA_SEGURA		;496c   ; uno
	dec de			;496f   ; se echa dos atras
	dec de			;4970
	jp PINTA_UNA_CIFRA_SEGURA		;4971   ; y el otro
FILA_DEL_INTENTO:
	ld hl,0e025h		;4974   ; la del jugador 1
FILA_DEL_INTENTO_DE:
	call A_QUIEN_LE_TOCA		;4977   ; mira a quien le toca
	jp SUMA_A_A_HL		;497a   ; y si es el 2, salta una casilla
FILA_DEL_MARCADOR:
	ld hl,0e062h		;497d   ; la del jugador 1
FILA_DEL_MARCADOR_DE:
	call A_QUIEN_LE_TOCA		;4980
	ret z			;4983   ; el jugador 1 no salta
	ld a,010h		;4984   ; y el 2 salta 0x10
	jp SUMA_A_A_HL		;4986
COPIA_DOS_BYTES:
	ld bc,00002h		;4989
	ldir		;498c
	ret			;498e
BAJA_UNA_FILA:
	ld a,020h		;498f   ; una fila de la tabla de nombres son 0x20 caracteres
BAJA_HL_EN_DE:
	ex de,hl			;4991   ; suma A a DE, no a HL
	call SUMA_A_A_HL		;4992
	ex de,hl			;4995
	ret			;4996
PINTA_LOS_TANTOS:
	ld hl,0e080h		;4997   ; los tantos del record de la partida
	ld de,07826h		;499a   ; en la fila de arriba del marcador
	ld b,002h		;499d   ; dos filas: record y jugador 1
	ld a,(0e010h)		;499f
	or a			;49a2
	jr z,PINTA_UNA_FILA_DE_TANTOS		;49a3
	inc b			;49a5   ; con dos jugadores, tres
PINTA_UNA_FILA_DE_TANTOS:
	push bc			;49a6
	ld b,003h		;49a7   ; tres bytes en BCD
	call PINTA_CIFRAS_SEGURAS		;49a9
	call BAJA_UNA_FILA		;49ac   ; y baja de fila
	pop bc			;49af
	djnz PINTA_UNA_FILA_DE_TANTOS		;49b0
	ret			;49b2
CASILLA_DE_LA_PRUEBA:
	ld a,(0e016h)		;49b3   ; la prueba, de 1 a 4
	ld b,a			;49b6
SALTA_UNA_PALABRA:
	inc hl			;49b7   ; dos bytes por casilla; AVANZA ANTES DE LEER, asi que la direccion que
	inc hl			;49b8   ; le pasan esta dos bytes antes de la casilla de la prueba 1
	djnz SALTA_UNA_PALABRA		;49b9
	ld e,(hl)			;49bb   ; y saca el puntero
	inc hl			;49bc
	ld d,(hl)			;49bd
	ex de,hl			;49be
	ret			;49bf
PINTA_MARCA_Y_UNIDAD:
	call PINTA_MARCA_SIN_INTERRUPCION		;49c0   ; los tres grupos de cifras
	inc de			;49c3   ; tres caracteres mas alla
	inc de			;49c4
	inc de			;49c5
	ld b,001h		;49c6   ; va la unidad
	jp SUBE_BYTES_SEGURO		;49c8
PINTA_UNA_MARCA:
	call PINTA_UNA_CIFRA		;49cb   ; el primer grupo, dos cifras
	inc de			;49ce
	inc de			;49cf
	push hl			;49d0
	ld hl,050f8h		;49d1   ; el separador de las de distancia
	ld b,002h		;49d4
	call ES_PRUEBA_DE_DISTANCIA		;49d6   ; en las de tiempo
	jr nz,PINTA_EL_SEPARADOR		;49d9
	ld hl,05058h		;49db
	rrca			;49de
	jr c,PINTA_EL_SEPARADOR		;49df
	ld hl,05137h		;49e1   ; el separador es otro
PINTA_EL_SEPARADOR:
	call SUBE_BYTES_EN_DE		;49e4
	pop hl			;49e7
	inc de			;49e8   ; y detras, el ultimo grupo
	inc de			;49e9
	jp PINTA_UNA_CIFRA		;49ea
PINTA_MARCA_SIN_INTERRUPCION:
	di			;49ed   ; escribir en VRAM y dejar entrar la interrupcion no se llevan bien
	call PINTA_UNA_MARCA		;49ee
	ei			;49f1
	ret			;49f2
LEE_EL_JOYSTICK:
	ld a,00fh		;49f3   ; registro 15 del PSG: elige que puerto se lee
	call 00093h		;49f5   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00eh		;49f8   ; y el 14 lo devuelve
	call 00096h		;49fa   ; BIOS RDPSG - Reads value from PSG-register
	cpl			;49fd   ; el PSG devuelve los bits al reves
	ret			;49fe
LEE_LOS_MANDOS_DE_LOS_DOS:
	ld b,002h		;49ff   ; los dos jugadores
	ld hl,0e008h		;4a01
	ld a,(0e004h)		;4a04   ; con 0xE004 puesto se juega con joystick
	or a			;4a07
	jr z,LEE_EL_TECLADO		;4a08
	ld e,08fh		;4a0a   ; puerto A del joystick
LEE_UN_JOYSTICK:
	ld a,00fh		;4a0c
	call LEE_EL_JOYSTICK		;4a0e
	and 018h		;4a11   ; los dos botones
	rrca			;4a13
	rrca			;4a14
	rrca			;4a15
	ld (hl),a			;4a16   ; en los dos bits de abajo
	ld hl,0e00ch		;4a17   ; el hueco del jugador 2
	ld e,0cfh		;4a1a   ; y su puerto
	djnz LEE_UN_JOYSTICK		;4a1c
	jr GUARDA_LOS_MANDOS		;4a1e
LEE_EL_TECLADO:
	ld a,008h		;4a20   ; fila 8 del teclado
LEE_UNA_FILA:
	call 00141h		;4a22   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;4a25   ; el bit 7 (derecha) y el 0 (espacio)
	and 081h		;4a26
	rlca			;4a28   ; juntos en los dos de abajo
	ld (hl),a			;4a29
	ld hl,0e00ch		;4a2a
	ld a,005h		;4a2d   ; y el jugador 2 juega con la fila 5
	djnz LEE_UNA_FILA		;4a2f
GUARDA_LOS_MANDOS:
	ld b,002h		;4a31   ; los dos jugadores
	ld hl,0e008h		;4a33
GUARDA_UN_MANDO:
	ld a,(hl)			;4a36   ; lo que habia antes
	inc hl			;4a37
	cp (hl)			;4a38   ; contra lo que hay ahora
	ld c,a			;4a39
	jr nz,PASA_AL_SIGUIENTE_MANDO		;4a3a   ; si ha cambiado, no hay nada que hacer
	inc hl			;4a3c
	srl (hl)		;4a3d   ; y si no, se va gastando la cuenta de repeticion
	ld (hl),a			;4a3f
	inc hl			;4a40
	jr nc,REPITE_EL_MANDO		;4a41
	and 002h		;4a43
REPITE_EL_MANDO:
	ld (hl),a			;4a45
	dec hl			;4a46
	dec hl			;4a47
PASA_AL_SIGUIENTE_MANDO:
	ld (hl),c			;4a48
	ld hl,0e00ch		;4a49
	djnz GUARDA_UN_MANDO		;4a4c
	ret			;4a4e
LEE_LOS_MANDOS:
	ld b,002h		;4a4f   ; los dos puertos de joystick
	ld e,08fh		;4a51   ; el puerto A
LEE_UN_PUERTO:
	call LEE_EL_JOYSTICK		;4a53
	and 03fh		;4a56   ; los seis bits utiles
	ld (0e005h),a		;4a58
	or a			;4a5b
	ret nz			;4a5c   ; con algo pulsado ya vale
	ld e,0cfh		;4a5d   ; y si no, el puerto B
	djnz LEE_UN_PUERTO		;4a5f
	ld e,000h		;4a61   ; sin joystick se prueba el teclado
	ld hl,0e005h		;4a63
	ld a,007h		;4a66   ; fila 7: la F5
	call 00141h		;4a68   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;4a6b
	bit 6,a		;4a6c
	jr z,LEE_LA_FILA_8_DEL_TECLADO		;4a6e
	set 5,e		;4a70   ; en el bit 5
LEE_LA_FILA_8_DEL_TECLADO:
	ld a,008h		;4a72   ; fila 8: espacio y cursores
	call 00141h		;4a74   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;4a77
	bit 0,a		;4a78
	jr z,JUNTA_LOS_CURSORES		;4a7a   ; espacio en el bit 4
	set 4,e		;4a7c
JUNTA_LOS_CURSORES:
	and 060h		;4a7e   ; arriba y abajo
	rrca			;4a80   ; bajados a los dos bits de abajo
	rrca			;4a81
	rrca			;4a82
	rrca			;4a83
	rrca			;4a84
	or e			;4a85
	ld (0e005h),a		;4a86
	ret			;4a89
MUEVE_LA_FLECHA:
	ld hl,0e01ch		;4a8a
	ld a,(0e005h)		;4a8d   ; sin nada pulsado se suelta el antirrebote
	or a			;4a90
	jr nz,MIRA_LA_TECLA		;4a91
	ld (hl),a			;4a93
	ret			;4a94
MIRA_LA_TECLA:
	bit 0,(hl)		;4a95   ; con el antirrebote puesto no se repite
	ret nz			;4a97
	ld a,(0e005h)		;4a98
	and 030h		;4a9b   ; espacio o F5
	or a			;4a9d
	scf			;4a9e   ; acarreo: han elegido
	ret nz			;4a9f
	ld a,(0e005h)		;4aa0
	and 003h		;4aa3   ; arriba o abajo
	set 0,(hl)		;4aa5   ; y baja el antirrebote
	dec a			;4aa7   ; abajo va por el otro lado
	jr nz,FLECHA_ABAJO		;4aa8
	dec hl			;4aaa
	ld a,(hl)			;4aab   ; la linea elegida
	dec a			;4aac
	or a			;4aad   ; de la 1 se pasa a la 4
	jr nz,GUARDA_LA_LINEA_DE_ARRIBA		;4aae
	ld a,004h		;4ab0
GUARDA_LA_LINEA_DE_ARRIBA:
	ld (hl),a			;4ab2
	dec hl			;4ab3
	dec hl			;4ab4
	ld a,(hl)			;4ab5   ; y la fila de VRAM sube 0x40, o sea dos filas
	sub 040h		;4ab6
	ld (hl),a			;4ab8
	jr PINTA_LA_FLECHA		;4ab9
FLECHA_ABAJO:
	dec hl			;4abb
	ld a,(hl)			;4abc   ; la linea elegida
	inc a			;4abd
	cp 005h		;4abe   ; de la 4 se pasa a la 1
	jr nz,GUARDA_LA_LINEA_DE_ABAJO		;4ac0
	ld a,001h		;4ac2
GUARDA_LA_LINEA_DE_ABAJO:
	ld (hl),a			;4ac4
	dec hl			;4ac5
	dec hl			;4ac6
	ld a,(hl)			;4ac7   ; y la fila baja dos
	add a,040h		;4ac8
	ld (hl),a			;4aca
PINTA_LA_FLECHA:
	di			;4acb
	ld hl,0e019h		;4acc   ; la fila de VRAM de la linea elegida
	ld e,(hl)			;4acf
	inc hl			;4ad0
	ld d,(hl)			;4ad1
	ld hl,04ae6h		;4ad2   ; los tres pares de caracteres de la flecha
PINTA_UNA_FILA_DE_LA_FLECHA:
	ld a,(hl)			;4ad5
	cp 0ffh		;4ad6   ; el 0xFF cierra la lista
	ret z			;4ad8
	ld b,002h		;4ad9   ; dos caracteres por fila
	di			;4adb
	call SUBE_BYTES_EN_DE		;4adc
	ei			;4adf
	ld a,040h		;4ae0   ; y baja una fila
	add a,e			;4ae2
	ld e,a			;4ae3
	jr PINTA_UNA_FILA_DE_LA_FLECHA		;4ae4

; ----------------------------------------------------------------------
; DATOS marca_del_menu: La flecha que senala la linea elegida del menu: tres
;   filas de dos caracteres y un 0xFF de fin. La pinta 0x4ACB en la direccion
;   de VRAM guardada en 0xE019, bajando 0x40 por fila.
;   0x4ae6..0x4aed  (7 bytes)
DATA_marca_del_menu:
	defb 000h,000h	; 4ae6
	defb 0b6h,0b7h	; 4ae8
	defb 000h,000h	; 4aea
	defb 0ffh	; 4aec

; ======================================================================
; CODIGO 0x4aed..0x4e5c  (879 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  LOS INTERPRETES DE PANTALLA  ==========
; ----------------------------------------------------------------------
PINTA_EL_MARCO_DEL_MENU:
	call LIMPIA_LA_TABLA_DE_NOMBRES		;4aed   ; limpia la tabla de nombres
	ld hl,04e70h		;4af0   ; el guion del menu
	ld b,005h		;4af3   ; y sus cinco grupos: el marco y las cuatro lineas
PINTA_UN_GRUPO_DEL_MENU:
	push bc			;4af5
	call GUION_CORTO		;4af6
	pop bc			;4af9
	djnz PINTA_UN_GRUPO_DEL_MENU		;4afa
	ret			;4afc
GUION_CORTO:
	exx			;4afd   ; el puerto de datos del VDP, en el juego alterno
	ld a,(00006h)		;4afe
	ld c,a			;4b01
	exx			;4b02
	di			;4b03   ; nadie puede interrumpir mientras se escribe en VRAM
	call FIJA_LA_VRAM_DEL_GUION		;4b04   ; los dos primeros bytes son la direccion de VRAM
GUION_CORTO_UN_BYTE:
	inc hl			;4b07
	ld a,(hl)			;4b08
	cp 0feh		;4b09   ; 0xFE abre una racha
	jr nz,GUION_CORTO_MIRA_EL_FIN		;4b0b
GUION_CORTO_RACHA:
	inc hl			;4b0d
	ld b,(hl)			;4b0e   ; cuantas veces
	inc hl			;4b0f
	ld a,(hl)			;4b10   ; y que byte
	call REPITE_BYTE		;4b11
	inc hl			;4b14
	ld a,(hl)			;4b15
	cp 0feh		;4b16   ; detras puede venir otra racha
	jr z,GUION_CORTO_RACHA		;4b18
GUION_CORTO_MIRA_EL_FIN:
	cp 0ffh		;4b1a   ; 0xFF cierra el bloque
	jr z,GUION_CORTO_OTRO_BLOQUE		;4b1c
	exx			;4b1e
	out (c),a		;4b1f   ; y cualquier otro byte va tal cual a la VRAM
	exx			;4b21
	jr GUION_CORTO_UN_BYTE		;4b22
GUION_CORTO_OTRO_BLOQUE:
	inc hl			;4b24
	ld a,(hl)			;4b25
	cp 0ffh		;4b26   ; dos 0xFF seguidos cierran el guion
	jr nz,GUION_CORTO		;4b28   ; y si no, viene otro bloque detras
	inc hl			;4b2a
	ei			;4b2b
	ret			;4b2c
PINTA_UNA_CIFRA:
	ld b,001h		;4b2d   ; un solo byte, o sea dos cifras
PINTA_CIFRAS:
	call FIJA_ESCRITURA		;4b2f   ; fija la direccion de VRAM
PINTA_UN_BYTE_BCD:
	ld a,(hl)			;4b32
	ld c,a			;4b33
	call CIFRA_DE_ARRIBA		;4b34   ; la cifra de arriba
	ld a,c			;4b37
	call CIFRA_A_CARACTER		;4b38   ; y la de abajo
	inc hl			;4b3b
	djnz PINTA_UN_BYTE_BCD		;4b3c
	ret			;4b3e
CIFRA_DE_ARRIBA:
	rrca			;4b3f   ; el nibble alto al bajo
	rrca			;4b40
	rrca			;4b41
	rrca			;4b42
CIFRA_A_CARACTER:
	and 00fh		;4b43   ; se queda con el nibble
	or 0f0h		;4b45   ; y los caracteres de las cifras empiezan en 0xF0
	push bc			;4b47
	push af			;4b48
	ld a,(00006h)		;4b49   ; el puerto de datos del VDP
	ld c,a			;4b4c
	pop af			;4b4d
	out (c),a		;4b4e
	pop bc			;4b50
	ret			;4b51
PINTA_UNA_CIFRA_SEGURA:
	ld b,001h		;4b52
PINTA_CIFRAS_SEGURAS:
	di			;4b54   ; con la interrupcion cerrada, que va a escribir en VRAM
	call PINTA_CIFRAS		;4b55
	ei			;4b58
	ret			;4b59
CAMBIA_DE_JUGADOR:
	ld hl,0e011h		;4b5a   ; el jugador al que le toca
	ld b,(hl)			;4b5d
	ld a,(0e010h)		;4b5e   ; con un solo jugador no hay cambio
	or a			;4b61
	ret z			;4b62
	ld (hl),a			;4b63
	ld a,(0e021h)		;4b64   ; el jugador 1 sigue en juego
	rrca			;4b67
	ret c			;4b68   ; entonces le toca a el
	dec (hl)			;4b69   ; y si no, se prueba con el 2
	rrca			;4b6a
	ret c			;4b6b
	ld a,b			;4b6c
	inc a			;4b6d   ; y si tampoco, se alterna
	and 001h		;4b6e
	ld (hl),a			;4b70
	ret			;4b71
PARPADEO_DEL_RESULTADO:
	call ES_LA_DEMO		;4b72   ; en la demo no hay nada que parpadear
	ret nz			;4b75
	ld a,(0e014h)		;4b76   ; con 0xE014 puesto se ensena el resultado grande
	or a			;4b79
	jp nz,ENSENA_EL_RESULTADO_GRANDE		;4b7a
	ld hl,0e012h		;4b7d   ; la cuenta atras del parpadeo
	dec (hl)			;4b80
	ret nz			;4b81
	ld (hl),020h		;4b82   ; medio segundo entre cambios
	inc hl			;4b84
	ld c,0bdh		;4b85   ; caracter 0xBD, el del rotulo encendido
	ld a,(hl)			;4b87
	or a			;4b88
	jr z,PARPADEA_EL_ROTULO		;4b89   ; con la cuenta a cero se apaga
	dec (hl)			;4b8b
	dec (hl)			;4b8c
	ld c,000h		;4b8d   ; y el rotulo se pone en blanco
PARPADEA_EL_ROTULO:
	inc (hl)			;4b8f
	ld de,078a5h		;4b90   ; la fila del rotulo
	call ES_PRUEBA_DE_DISTANCIA		;4b93   ; en las de distancia solo hay un rotulo
	jr z,CIFRAS_DEL_ROTULO		;4b96
	call A_QUIEN_LE_TOCA		;4b98   ; en las de tiempo, el del jugador que juega
	jr z,PINTA_UN_ROTULO		;4b9b
	ld e,0c5h		;4b9d   ; o el del otro
PINTA_UN_ROTULO:
	ld b,001h		;4b9f
	jp REPITE_BYTE_CON_CANDADO		;4ba1
CIFRAS_DEL_ROTULO:
	ld b,000h		;4ba4
	ld a,c			;4ba6
	or a			;4ba7
	jr z,PINTA_LOS_DOS_ROTULOS		;4ba8
	ld bc,0bcbdh		;4baa   ; con la cuenta a cero los dos rotulos en blanco
PINTA_LOS_DOS_ROTULOS:
	ld h,b			;4bad   ; caracteres 0xBC y 0xBD, uno por jugador
	ld b,001h		;4bae
	call REPITE_BYTE_CON_CANDADO		;4bb0
	ld de,078c5h		;4bb3   ; la fila del jugador 2
	ld c,h			;4bb6
	ld b,001h		;4bb7
	jp REPITE_BYTE_CON_CANDADO		;4bb9
ENSENA_EL_RESULTADO_GRANDE:
	ld hl,0e001h		;4bbc   ; la espera, en puntos de 32 cuadros
	ld de,07833h		;4bbf   ; la fila del resultado
	bit 0,(hl)		;4bc2   ; mientras quede espera, se pinta
	jr nz,PINTA_EL_RESULTADO_GRANDE		;4bc4
	ld a,(hl)			;4bc6
	or a			;4bc7
	jr nz,BORRA_SEIS_CARACTERES		;4bc8   ; con la espera agotada
	ld (0e014h),a		;4bca   ; se acabo de ensenar
	ret			;4bcd
BORRA_SEIS_CARACTERES:
	ld bc,00600h		;4bce
	jp REPITE_BYTE_CON_CANDADO		;4bd1
PINTA_EL_RESULTADO_GRANDE:
	ld hl,0e041h		;4bd4   ; la mejor marca de la prueba
	call SALTA_A_LA_FILA_DE_LA_PRUEBA		;4bd7
	jp PINTA_UNA_MARCA		;4bda
SUMA_BCD_DE_TRES_BYTES:
	ld d,a			;4bdd   ; A lleva el byte alto, B el medio y C el bajo
	ld a,(hl)			;4bde
	add a,c			;4bdf
	daa			;4be0   ; en BCD desde el byte de abajo
	ld (hl),a			;4be1
	dec hl			;4be2
	ld a,(hl)			;4be3
	adc a,b			;4be4
	daa			;4be5
	ld (hl),a			;4be6
	dec hl			;4be7
	ld a,(hl)			;4be8
	adc a,d			;4be9
	daa			;4bea
	ld (hl),a			;4beb
	ret			;4bec
LIMPIA_LA_TABLA_DE_NOMBRES:
	di			;4bed
	ld de,07800h		;4bee   ; el principio de la tabla de nombres
	call FIJA_ESCRITURA		;4bf1
	ld h,003h		;4bf4   ; tres tercios
	xor a			;4bf6
LIMPIA_UN_TERCIO:
	ld b,a			;4bf7
	call REPITE_BYTE		;4bf8   ; 256 caracteres a cero
	dec h			;4bfb
	jr nz,LIMPIA_UN_TERCIO		;4bfc
	ei			;4bfe
	ret			;4bff
COPIA_VRAM_A_VRAM:
	ld bc,00fffh		;4c00   ; 0x1000 bytes, un tercio entero
	exx			;4c03
	ld a,(00006h)		;4c04   ; el puerto de datos
	ld d,a			;4c07
	ld a,(00007h)		;4c08   ; y el de direcciones
	ld e,a			;4c0b
	exx			;4c0c
COPIA_UN_BYTE_DE_VRAM:
	call FIJA_LECTURA		;4c0d   ; fija la direccion de lectura
	inc de			;4c10
	exx			;4c11
	ld c,e			;4c12   ; lee un byte
	in a,(c)		;4c13
	exx			;4c15
	ex de,hl			;4c16
	push af			;4c17
	call FIJA_ESCRITURA		;4c18   ; fija la de escritura
	inc de			;4c1b
	pop af			;4c1c
	exx			;4c1d
	ld c,d			;4c1e
	out (c),a		;4c1f   ; y lo suelta
	exx			;4c21
	ex de,hl			;4c22
	dec bc			;4c23
	ld a,b			;4c24
	or c			;4c25
	jr nz,COPIA_UN_BYTE_DE_VRAM		;4c26
	ret			;4c28
ESPERA_PUNTOS:
	ld hl,0e001h		;4c29   ; A puntos de espera; cada punto son 32 cuadros, o sea 0,64 segundos
	ld (hl),a			;4c2c   ; la interrupcion los va bajando
ESPERA_A_QUE_LLEGUE_A_CERO:
	ld a,(hl)			;4c2d
	or a			;4c2e
	jr nz,ESPERA_A_QUE_LLEGUE_A_CERO		;4c2f
	ret			;4c31

; ----------------------------------------------------------------------
; ==========  LAS LETRAS GRANDES  ==========
; Un rotulo de letra grande no esta dibujado en la ROM: se monta. Se
; copian los glifos normales a 0xE230, se suben tal cual, y luego se dan
; TRES PASADAS que van sacando los dos bits altos de cada byte y
; metiendolos en el byte de ocho posiciones antes. Con eso una fila de
; ocho glifos da cuatro filas de patron: la letra sale al doble.
; ----------------------------------------------------------------------
MONTA_UN_ROTULO:
	call LLENA_EL_PAPEL		;4c32   ; llena 0xE230 con los glifos del rotulo
	ex de,hl			;4c35   ; DE quedo en el final del papel
	ld de,00008h		;4c36
	or a			;4c39
	sbc hl,de		;4c3a   ; ocho bytes antes
	ld a,(hl)			;4c3c
	ld (hl),011h		;4c3d   ; le pone la marca de fin
	push af			;4c3f
	ld hl,0e230h		;4c40
	call SUBE_EL_PAPEL		;4c43   ; y sube a la VRAM lo que queda por delante
	pop af			;4c46
	ld (hl),a			;4c47   ; devuelve el byte que habia pisado
	call ESTIRA_LAS_LETRAS		;4c48   ; y estira las letras
	ret			;4c4b
LLENA_EL_PAPEL:
	ld de,0e230h		;4c4c   ; el papel donde se monta el rotulo
	ld a,(hl)			;4c4f   ; el primer byte dice de que tipo es
	inc hl			;4c50
	or a			;4c51
	jr nz,ROTULO_DE_GLIFOS		;4c52   ; tipo 0: bytes tal cual
	ld c,(hl)			;4c54   ; cuantos bytes salen
ROTULO_UN_BYTE:
	inc hl			;4c55
	ld a,(hl)			;4c56
	cp 011h		;4c57   ; 0x11 abre una racha
	jr z,ROTULO_RACHA		;4c59
	ld (de),a			;4c5b
	inc de			;4c5c
	dec c			;4c5d
	jr nz,ROTULO_UN_BYTE		;4c5e
ROTULO_FIN:
	ld a,011h		;4c60   ; la marca de fin del papel
	ld (de),a			;4c62
	ret			;4c63
ROTULO_RACHA:
	inc hl			;4c64
	ld b,(hl)			;4c65   ; cuantas veces
	inc hl			;4c66
ROTULO_REPITE:
	ld a,(hl)			;4c67
	ld (de),a			;4c68
	inc de			;4c69
	dec c			;4c6a   ; la cuenta manda sobre la racha
	jr z,ROTULO_FIN		;4c6b
	djnz ROTULO_REPITE		;4c6d
	jr ROTULO_UN_BYTE		;4c6f
ROTULO_DE_GLIFOS:
	ld b,(hl)			;4c71   ; el indice del glifo
	push hl			;4c72
	ld hl,06197h		;4c73   ; la fuente
	inc b			;4c76   ; el glifo 0 no salta nada
	dec b			;4c77
	jr z,COPIA_EL_GLIFO		;4c78
SALTA_UN_GLIFO:
	ld a,008h		;4c7a   ; ocho bytes por glifo
	add a,l			;4c7c
	ld l,a			;4c7d
	jr nc,SIGUE_SALTANDO_GLIFOS		;4c7e
	inc h			;4c80
SIGUE_SALTANDO_GLIFOS:
	djnz SALTA_UN_GLIFO		;4c81
COPIA_EL_GLIFO:
	ld bc,00008h		;4c83   ; ocho bytes al papel
	ldir		;4c86
	pop hl			;4c88
	inc hl			;4c89
	ld a,0ffh		;4c8a   ; 0xFF cierra la lista de glifos
	cp (hl)			;4c8c
	jr nz,ROTULO_DE_GLIFOS		;4c8d
	ld a,011h		;4c8f   ; y se cierra el papel
	ld (de),a			;4c91
	inc hl			;4c92
	ret			;4c93
ESTIRA_LAS_LETRAS:
	ld b,003h		;4c94   ; tres pasadas
UNA_PASADA:
	push bc			;4c96
	ld hl,0e230h		;4c97   ; desde el principio del papel
UNA_FILA_DE_OCHO:
	ld b,008h		;4c9a   ; ocho bytes por fila
UN_BYTE_DE_LA_FILA:
	push bc			;4c9c
	xor a			;4c9d
	ld c,a			;4c9e   ; aqui se recogen los dos bits
	ld b,002h		;4c9f   ; dos bits por byte y pasada
SACA_DOS_BITS:
	sla (hl)		;4ca1   ; saca el bit alto del byte
	rl c		;4ca3   ; y lo mete en C
	djnz SACA_DOS_BITS		;4ca5
	ld de,00008h		;4ca7
	or a			;4caa
	sbc hl,de		;4cab   ; ocho posiciones antes
	ld a,(hl)			;4cad
	or c			;4cae   ; alli se meten los dos bits
	ld (hl),a			;4caf
	add hl,de			;4cb0   ; y se vuelve al byte siguiente
	inc hl			;4cb1
	pop bc			;4cb2
	djnz UN_BYTE_DE_LA_FILA		;4cb3
	ld a,011h		;4cb5   ; la marca cierra el papel
	cp (hl)			;4cb7
	jr nz,UNA_FILA_DE_OCHO		;4cb8
	ld de,00008h		;4cba   ; otra vez ocho antes
	or a			;4cbd
	sbc hl,de		;4cbe
	ld a,(hl)			;4cc0
	push af			;4cc1
	ld (hl),011h		;4cc2   ; marca de fin provisional
	ld hl,0e230h		;4cc4
	call SUBE_EL_PAPEL		;4cc7   ; sube a la VRAM lo que quede por delante
	pop af			;4cca
	ld (hl),a			;4ccb   ; devuelve el byte pisado
	add hl,de			;4ccc
	ld (hl),011h		;4ccd   ; y corre la marca ocho mas
	pop bc			;4ccf
	djnz UNA_PASADA		;4cd0
	ld hl,0e230h		;4cd2   ; al acabar, el papel se deja limpio
	ld bc,000a0h		;4cd5   ; sus 0xA0 bytes
	call LIMPIA_MEMORIA		;4cd8
	ret			;4cdb
SUBE_EL_PAPEL:
	ld b,008h		;4cdc   ; de ocho en ocho
SUBE_OCHO:
	ld a,(hl)			;4cde
	push bc			;4cdf
	push af			;4ce0
	ld a,(00006h)		;4ce1   ; el puerto de datos del VDP
	ld c,a			;4ce4
	pop af			;4ce5
	out (c),a		;4ce6
	pop bc			;4ce8
	inc hl			;4ce9
	djnz SUBE_OCHO		;4cea
	ld a,011h		;4cec
	cp (hl)			;4cee   ; hasta la marca de fin
	jr nz,SUBE_EL_PAPEL		;4cef
	ret			;4cf1

; ----------------------------------------------------------------------
; ==========  EL GUION LARGO  ==========
; [N] y detras N ordenes. La primera de cada una dice de que tipo es:
; 0  bytes a VRAM, con 0x11 cuenta valor para las rachas
; 1  tiras de glifos de la fuente, subidos como patron
; 2  rotulos de letra grande
; 3  rellenos de un byte
; 4+ repetir un patron de ocho bytes N veces
; ----------------------------------------------------------------------
GUION_LARGO:
	ld b,(hl)			;4cf2   ; cuantas ordenes
	inc hl			;4cf3
UNA_ORDEN:
	push bc			;4cf4
	ld a,(hl)			;4cf5   ; el tipo
	inc hl			;4cf6   ; y detras van sus datos
	or a			;4cf7
	jr z,ORDEN_DE_BYTES		;4cf8   ; tipo 0
	dec a			;4cfa
	jr z,ORDEN_DE_GLIFOS		;4cfb   ; tipo 1
	dec a			;4cfd
	jr z,ORDEN_DE_ROTULOS		;4cfe   ; tipo 2
	dec a			;4d00
	jr z,ORDEN_DE_RELLENOS		;4d01   ; tipo 3
	jp ORDEN_DE_PATRON_REPETIDO		;4d03   ; y cualquier otro va al tipo 4
SIGUIENTE_ORDEN:
	pop bc			;4d06
	djnz UNA_ORDEN		;4d07   ; una orden menos
	ret			;4d09
ORDEN_DE_BYTES:
	ld b,(hl)			;4d0a   ; cuantos bloques
	inc hl			;4d0b
UN_BLOQUE_DE_BYTES:
	push bc			;4d0c
	call FIJA_LA_VRAM_DEL_GUION		;4d0d   ; la direccion de VRAM
	inc hl			;4d10
	ld c,(hl)			;4d11   ; y cuantos bytes; cero significa 256
	inc hl			;4d12
UN_BYTE_DEL_BLOQUE:
	ld a,(hl)			;4d13
	cp 011h		;4d14   ; 0x11 abre una racha
	jr z,RACHA_DE_BYTES		;4d16
	ex af,af'			;4d18
	exx			;4d19
	ld a,(00006h)		;4d1a   ; el puerto de datos del VDP
	ld c,a			;4d1d
	ex af,af'			;4d1e
	out (c),a		;4d1f
	exx			;4d21
	inc hl			;4d22
	dec c			;4d23
	jr nz,UN_BYTE_DEL_BLOQUE		;4d24
SIGUIENTE_BLOQUE_DE_BYTES:
	pop bc			;4d26
	djnz UN_BLOQUE_DE_BYTES		;4d27
	jr SIGUIENTE_ORDEN		;4d29
RACHA_DE_BYTES:
	inc hl			;4d2b
	ld b,(hl)			;4d2c   ; cuantas veces
	inc hl			;4d2d
	ld a,(hl)			;4d2e   ; y que byte
	inc hl			;4d2f
SUELTA_LA_RACHA:
	ex af,af'			;4d30
	exx			;4d31
	ld a,(00006h)		;4d32   ; el puerto de datos del VDP
	ld c,a			;4d35
	ex af,af'			;4d36
	out (c),a		;4d37
	exx			;4d39
	dec c			;4d3a   ; la cuenta del bloque manda sobre la de la racha
	jr z,SIGUIENTE_BLOQUE_DE_BYTES		;4d3b
	djnz SUELTA_LA_RACHA		;4d3d   ; y mientras la racha aguante
	jr UN_BYTE_DEL_BLOQUE		;4d3f
ORDEN_DE_GLIFOS:
	ld b,(hl)			;4d41   ; cuantos bloques
UN_BLOQUE_DE_GLIFOS:
	push bc			;4d42
	inc hl			;4d43
	call FIJA_LA_VRAM_DEL_GUION		;4d44   ; la direccion de VRAM
	inc hl			;4d47
UN_GLIFO:
	ld b,(hl)			;4d48   ; el indice
	push hl			;4d49
	ld hl,06197h		;4d4a   ; la fuente
	ld a,b			;4d4d
	or a			;4d4e
	jr z,SUELTA_EL_GLIFO		;4d4f
SALTA_GLIFOS:
	ld a,008h		;4d51   ; ocho bytes por glifo
	add a,l			;4d53
	ld l,a			;4d54
	jr nc,ACABA_DE_SALTAR_GLIFOS		;4d55
	inc h			;4d57
ACABA_DE_SALTAR_GLIFOS:
	djnz SALTA_GLIFOS		;4d58
SUELTA_EL_GLIFO:
	ld b,008h		;4d5a   ; sus ocho bytes
	call SUBE_BYTES		;4d5c
	pop hl			;4d5f
	inc hl			;4d60
	ld a,0ffh		;4d61
	cp (hl)			;4d63   ; 0xFF cierra la tira
	jr nz,UN_GLIFO		;4d64
	pop bc			;4d66
	djnz UN_BLOQUE_DE_GLIFOS		;4d67
	inc hl			;4d69
VUELVE_A_LA_SIGUIENTE_ORDEN:
	jr SIGUIENTE_ORDEN		;4d6a
ORDEN_DE_ROTULOS:
	ld b,(hl)			;4d6c   ; cuantos rotulos
	inc hl			;4d6d
	call FIJA_LA_VRAM_DEL_GUION		;4d6e   ; la direccion de VRAM, que vale para todos
	inc hl			;4d71
UN_ROTULO:
	push bc			;4d72
	ld e,(hl)			;4d73   ; el puntero al rotulo
	inc hl			;4d74
	ld d,(hl)			;4d75
	inc hl			;4d76
	push hl			;4d77
	ex de,hl			;4d78
	call MONTA_UN_ROTULO		;4d79   ; y a montarlo
	pop hl			;4d7c
	pop bc			;4d7d
	djnz UN_ROTULO		;4d7e
	jr SIGUIENTE_ORDEN		;4d80
ORDEN_DE_RELLENOS:
	ld b,(hl)			;4d82   ; cuantos rellenos
	inc hl			;4d83
	call FIJA_LA_VRAM_DEL_GUION		;4d84   ; la direccion de VRAM
UN_RELLENO:
	push bc			;4d87
	inc hl			;4d88
	ld b,(hl)			;4d89   ; cuantas veces
	inc hl			;4d8a
	ld a,(hl)			;4d8b   ; y que byte
	call REPITE_BYTE		;4d8c
	pop bc			;4d8f
	djnz UN_RELLENO		;4d90
	inc hl			;4d92
	jr VUELVE_A_LA_SIGUIENTE_ORDEN		;4d93
ORDEN_DE_PATRON_REPETIDO:
	call FIJA_LA_VRAM_DEL_GUION		;4d95   ; la direccion de VRAM
	inc hl			;4d98
	ld b,(hl)			;4d99   ; cuantas veces
	inc hl			;4d9a
	ld e,(hl)			;4d9b   ; y de donde sale el patron
	inc hl			;4d9c
	ld d,(hl)			;4d9d
	push hl			;4d9e
	push de			;4d9f
	pop hl			;4da0
REPITE_EL_PATRON:
	push bc			;4da1
	push hl			;4da2
	ld b,008h		;4da3   ; ocho bytes cada vez, siempre los mismos
	call SUBE_BYTES		;4da5
	pop hl			;4da8
	pop bc			;4da9
	djnz REPITE_EL_PATRON		;4daa
	pop hl			;4dac
	inc hl			;4dad
	jr VUELVE_A_LA_SIGUIENTE_ORDEN		;4dae
FIJA_LA_VRAM_DEL_GUION:
	ld d,(hl)			;4db0   ; los guiones guardan la direccion de VRAM al reves, byte alto primero
	inc hl			;4db1
	ld e,(hl)			;4db2
	jp FIJA_ESCRITURA		;4db3
SUBE_CODIGOS_CORRELATIVOS:
	push af			;4db6
	call FIJA_ESCRITURA		;4db7   ; fija la direccion
	pop af			;4dba
UN_CODIGO_MAS:
	ex af,af'			;4dbb
	exx			;4dbc
	ld a,(00006h)		;4dbd   ; el puerto de datos
	ld c,a			;4dc0
	ex af,af'			;4dc1
	out (c),a		;4dc2
	exx			;4dc4
	inc a			;4dc5   ; cada caracter es el siguiente del anterior
	djnz UN_CODIGO_MAS		;4dc6
	ex de,hl			;4dc8
	ld de,00020h		;4dc9   ; y al acabar baja una fila
	add hl,de			;4dcc
	ex de,hl			;4dcd
	ret			;4dce
LIMPIA_MEMORIA:
	push hl			;4dcf
	pop de			;4dd0   ; el clasico relleno con LDIR desplazado un byte
	inc de			;4dd1
	ld (hl),000h		;4dd2
	ldir		;4dd4
	ret			;4dd6
BORRA_LA_FILA_DE_LA_MARCA:
	ld de,07b00h		;4dd7   ; la fila 0x3B00 de la tabla de nombres
	ld bc,080cfh		;4dda   ; 0x80 caracteres a 0xCF
	jp REPITE_BYTE_SEGURO		;4ddd
SUMA_A_A_HL:
	add a,l			;4de0   ; con acarreo al byte alto
	ld l,a			;4de1
	ret nc			;4de2
	inc h			;4de3
	ret			;4de4

; ----------------------------------------------------------------------
; ==========  FIJAR DIRECCION DE VRAM SIN QUE LA INTERRUPCION LA PISE
; El VDP lleva la direccion en un registro suyo, y la interrupcion
; tambien escribe. Estas rutinas borran 0xE01D, fijan la direccion y
; comprueban si la interrupcion ha entrado por en medio: si ha entrado,
; vuelven a fijarla. Es el mismo truco en las cuatro variantes.
; ----------------------------------------------------------------------
FIJA_ESCRITURA_CON_CANDADO:
	xor a			;4de5
	ld (0e01dh),a		;4de6   ; baja la marca de "ha entrado la interrupcion"
	inc a			;4de9
	ld (0e01eh),a		;4dea   ; y sube el candado
	ex de,hl			;4ded
	call 00053h		;4dee   ; BIOS SETWRT - Enables VDP to write | la BIOS fija la direccion de escritura
	di			;4df1
	ex de,hl			;4df2
	ld a,(0e01dh)		;4df3   ; si la interrupcion se colo, se repite
	or a			;4df6
	jr nz,FIJA_ESCRITURA_CON_CANDADO		;4df7
	ld (0e01eh),a		;4df9   ; y al salir se quita el candado
	ret			;4dfc
FIJA_LECTURA:
	xor a			;4dfd
	ld (0e01dh),a		;4dfe   ; baja la marca
	ex de,hl			;4e01
	call 00050h		;4e02   ; BIOS SETRD - Enables VDP to read | la BIOS fija la direccion de lectura
	di			;4e05
	ex de,hl			;4e06
	ld a,(0e01dh)		;4e07   ; y si se colo la interrupcion, otra vez
	or a			;4e0a
	jr nz,FIJA_LECTURA		;4e0b
	ret			;4e0d
FIJA_ESCRITURA:
	xor a			;4e0e
	ld (0e01dh),a		;4e0f   ; baja la marca
	ex de,hl			;4e12
	call 00053h		;4e13   ; BIOS SETWRT - Enables VDP to write | la BIOS fija la direccion de escritura
	di			;4e16
	ex de,hl			;4e17
	ld a,(0e01dh)		;4e18   ; y si se colo la interrupcion, otra vez
	or a			;4e1b
	jr nz,FIJA_ESCRITURA		;4e1c
	ret			;4e1e
SUBE_BYTES_CON_DIRECCION:
	call FIJA_ESCRITURA_CON_CANDADO		;4e1f
SUBE_BYTES:
	push bc			;4e22
	ld a,(00006h)		;4e23   ; el puerto de datos del VDP
	ld c,a			;4e26
	ld a,(hl)			;4e27   ; byte a byte desde HL
	out (c),a		;4e28
	inc hl			;4e2a
	pop bc			;4e2b
	djnz SUBE_BYTES		;4e2c
	ret			;4e2e
SUBE_BYTES_EN_DE:
	call FIJA_ESCRITURA		;4e2f   ; fija la direccion y suelta B bytes
	jr SUBE_BYTES		;4e32
REPITE_BYTE_CON_CANDADO:
	call FIJA_ESCRITURA_CON_CANDADO		;4e34
	ld a,c			;4e37
REPITE_BYTE:
	push bc			;4e38
	push af			;4e39
	ld a,(00006h)		;4e3a   ; el puerto de datos
	ld c,a			;4e3d
	pop af			;4e3e
	out (c),a		;4e3f   ; el mismo byte B veces
	pop bc			;4e41
	djnz REPITE_BYTE		;4e42
	ret			;4e44
REPITE_BYTE_EN_DE:
	call FIJA_ESCRITURA		;4e45
	ld a,c			;4e48
	jr REPITE_BYTE		;4e49
A_QUIEN_LE_TOCA:
	ld a,(0e011h)		;4e4b   ; devuelve Z si le toca al jugador 1
	or a			;4e4e
	ret			;4e4f
SUBE_BYTES_SEGURO:
	di			;4e50   ; escribir en VRAM con la interrupcion abierta sale mal
	call SUBE_BYTES_EN_DE		;4e51
	ei			;4e54
	ret			;4e55
REPITE_BYTE_SEGURO:
	di			;4e56
	call REPITE_BYTE_EN_DE		;4e57
	ei			;4e5a
	ret			;4e5b

; ----------------------------------------------------------------------
; DATOS registros_del_vdp: Los ocho registros del VDP tal cual los escribe
;   0x410C. Dan SCREEN 2 con nombres en 0x3800, color en 0x0000, patrones en
;   0x2000, atributos de sprite en 0x3B00 y patrones de sprite en 0x1800
;   (16x16, sin ampliar). Son byte a byte los mismos que en el cartucho
;   hermano.
;   0x4e5c..0x4e64  (8 bytes)
DATA_registros_del_vdp:
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e1h	; 4e5c  .....v..

; ----------------------------------------------------------------------
; DATOS restos_sin_uso: Tres grupos de cuatro bytes con pinta de atributos de
;   sprite. NADIE los lee: ningun puntero de la ROM cae aqui. Estan tambien en
;   Hyper Olympic 1, byte a byte iguales y tan muertos como aqui.
;   0x4e64..0x4e70  (12 bytes)
DATA_restos_sin_uso:
	defb 000h,070h,038h,070h	; 4e64
	defb 000h,0a0h,038h,070h	; 4e68
	defb 000h,0f0h,038h,0f0h	; 4e6c

; ----------------------------------------------------------------------
; DATOS pantalla_del_menu: Guion corto de SEIS bloques, y los cuatro PRIMEROS
;   colocan el LOGOTIPO del juego (filas 3-6, columnas 12-21); PLAY SELECT y
;   los cuatro numeros de la izquierda son los dos de detras, a VRAM 0x390B y
;   0x39AB. Medido ejecutando el guion al comparar las dos compilaciones del
;   cartucho (ver docs/es/COMPARATIVA-TRACK-AND-FIELD.md).
;   0x4e70..0x4ebe  (78 bytes)
DATA_pantalla_del_menu:
	defb 078h,06ch,020h,021h,022h,023h,024h,025h	; 4e70  xl !"#$%
	defb 026h,03fh,040h,0ffh,078h,08ch,030h,031h	; 4e78  &?@.x.01
	defb 032h,033h,034h,035h,036h,041h,042h,0ffh	; 4e80  23456AB.
	defb 078h,0ach,027h,028h,029h,022h,02ah,02bh	; 4e88  x.'()"*+
	defb 02ch,02dh,02eh,02fh,0ffh,078h,0cch,037h	; 4e90  ,-./.x.7
	defb 038h,039h,032h,03ah,03bh,03ch,03dh,03eh	; 4e98  892:;<=>
	defb 0ffh,079h,00bh,0eah,0ebh,0ech,0edh,0eeh	; 4ea0  .y......
	defb 0efh,000h,0f1h,0f9h,0f8h,0f4h,0ffh,079h	; 4ea8  .......y
	defb 0abh,0cfh,0cbh,0c0h,0d6h,000h,0d1h,0c4h	; 4eb0  ........
	defb 0cbh,0c4h,0c2h,0d2h,0ffh,0ffh	; 4eb8

; ----------------------------------------------------------------------
; DATOS linea_de_menu_1: "1PLAYER with JOYSTICK", en la fila 0x3A07 de la
;   tabla de nombres.
;   0x4ebe..0x4ed6  (24 bytes)
DATA_linea_de_menu_1:
	defb 07ah,007h,0a1h,0adh,0aeh,0afh,0b0h,0b1h	; 4ebe  z.......
	defb 0b2h,000h,000h,0b4h,0b5h,000h,0a7h,0a8h	; 4ec6  ........
	defb 0b0h,0b3h,0a9h,0aah,0abh,0ach,0ffh,0ffh	; 4ece  ........

; ----------------------------------------------------------------------
; DATOS linea_de_menu_2: "2PLAYERS with JOYSTICK", en 0x3A47.
;   0x4ed6..0x4eee  (24 bytes)
DATA_linea_de_menu_2:
	defb 07ah,047h,0a2h,0adh,0aeh,0afh,0b0h,0b1h	; 4ed6  zG......
	defb 0b2h,0b3h,000h,0b4h,0b5h,000h,0a7h,0a8h	; 4ede  ........
	defb 0b0h,0b3h,0a9h,0aah,0abh,0ach,0ffh,0ffh	; 4ee6  ........

; ----------------------------------------------------------------------
; DATOS linea_de_menu_3: "1PLAYER with KEYBOARD", en 0x3A87.
;   0x4eee..0x4f06  (24 bytes)
DATA_linea_de_menu_3:
	defb 07ah,087h,0a1h,0adh,0aeh,0afh,0b0h,0b1h	; 4eee  z.......
	defb 0b2h,000h,000h,0b4h,0b5h,000h,0ach,0b1h	; 4ef6  ........
	defb 0b0h,0a5h,0a8h,0afh,0b2h,0a6h,0ffh,0ffh	; 4efe  ........

; ----------------------------------------------------------------------
; DATOS linea_de_menu_4: "2PLAYERS with KEYBOARD", en 0x3AC7. El 0xFF 0xFF del
;   final le sirve tambien de casilla cero a la tabla de abajo.
;   0x4f06..0x4f1e  (24 bytes)
DATA_linea_de_menu_4:
	defb 07ah,0c7h,0a2h,0adh,0aeh,0afh,0b0h,0b1h	; 4f06  z.......
	defb 0b2h,0b3h,000h,0b4h,0b5h,000h,0ach,0b1h	; 4f0e  ........
	defb 0b0h,0a5h,0a8h,0afh,0b2h,0a6h,0ffh,0ffh	; 4f16  ........

; ----------------------------------------------------------------------
; DATOS rotulo_de_la_prueba: Un guion largo por prueba con el nombre que va en
;   la pizarra: 110 vallas, jabalina, altura y 1500. Lo carga 0x4273 con
;   0x49AF, que indexa desde uno, y por eso el codigo registra 0x4F1C.
;   0x4f1e..0x4f26  (8 bytes)
DATA_rotulo_de_la_prueba:
	defw 067a4h	; 4f1e  -> DATA_pizarra_de_las_110_vallas
	defw 067b2h	; 4f20  -> DATA_pizarra_de_la_jabalina
	defw 067abh	; 4f22  -> DATA_pizarra_del_salto_de_altura
	defw 067b9h	; 4f24  -> DATA_pizarra_de_los_1500_metros

; ----------------------------------------------------------------------
; DATOS pantallas_de_la_prueba: Una lista de guiones largos por prueba, el
;   decorado. La carga 0x4261 desde 0x4F24. Las vallas y los 1500 comparten
;   lista (0x655A), y la jabalina y la altura otra (0x661F).
;   0x4f26..0x4f2e  (8 bytes)
DATA_pantallas_de_la_prueba:
	defw 0655ah	; 4f26  -> DATA_pantallas_de_las_110_vallas
	defw 0661fh	; 4f28  -> DATA_pantallas_de_jabalina_y_altura
	defw 0661fh	; 4f2a  -> DATA_pantallas_de_jabalina_y_altura
	defw 0655ah	; 4f2c  -> DATA_pantallas_de_las_110_vallas

; ----------------------------------------------------------------------
; DATOS marcador_de_la_prueba: El guion corto del marcador de cada prueba, que
;   carga 0x4933 desde 0x4F2C. Las vallas y los 1500 comparten el suyo.
;   0x4f2e..0x4f36  (8 bytes)
DATA_marcador_de_la_prueba:
	defw 067c0h	; 4f2e  -> DATA_marcador_de_las_110_vallas
	defw 0670eh	; 4f30  -> DATA_marcador_de_la_jabalina
	defw 0674eh	; 4f32  -> DATA_marcador_del_salto_de_altura
	defw 067c0h	; 4f34  -> DATA_marcador_de_las_110_vallas

; ======================================================================
; CODIGO 0x4f36..0x500a  (212 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  LOS PUNTOS DEL INTENTO  ==========
; Los puntos salen de la diferencia entre la marca y una referencia fija
; por prueba (0x5022). En las de tiempo la referencia esta ARRIBA y se le
; resta la marca; en las de distancia esta ABAJO y es la marca la que le
; gana. Despues se multiplica por dieciseis, y en las pruebas impares se
; dobla otra vez.
; ----------------------------------------------------------------------
PUNTUA_EL_INTENTO:
	ld hl,05022h		;4f36   ; la tabla de referencias
	ld a,(0e016h)		;4f39   ; la prueba en curso
	push af			;4f3c
	dec a			;4f3d
	call SUMA_A_A_HL		;4f3e   ; una referencia por prueba
	ex de,hl			;4f41   ; DE apunta a la referencia
	pop af			;4f42
	bit 1,a		;4f43
	jp nz,PUNTUA_POR_DISTANCIA		;4f45   ; pruebas 2 y 3: se puntua por distancia
	push de			;4f48
	ld hl,0e06bh		;4f49   ; la marca del jugador 1
	call REFERENCIA_MENOS_MARCA		;4f4c   ; referencia menos marca, en BCD
	jr c,PUNTUA_AL_JUGADOR_2		;4f4f
	ld hl,0e08ah		;4f51   ; los puntos del jugador 1
	call GUARDA_Y_ESCALA		;4f54
	jr nc,CUATRO_DESPLAZAMIENTOS		;4f57
	call MULTIPLICA_POR_DIECISEIS		;4f59
	jr PUNTUA_AL_JUGADOR_2		;4f5c
CUATRO_DESPLAZAMIENTOS:
	ld d,008h		;4f5e
	call UN_DESPLAZAMIENTO		;4f60
	call DOBLA_LOS_PUNTOS		;4f63
PUNTUA_AL_JUGADOR_2:
	pop de			;4f66
	ld hl,0e07bh		;4f67   ; la marca del jugador 2
	call REFERENCIA_MENOS_MARCA		;4f6a
	ret c			;4f6d
	ld hl,0e08dh		;4f6e   ; si se pasa, cero
	call GUARDA_Y_ESCALA		;4f71
	jr nc,CUATRO_DESPLAZAMIENTOS_2		;4f74
	call MULTIPLICA_POR_DIECISEIS		;4f76
	ret			;4f79
CUATRO_DESPLAZAMIENTOS_2:
	ld d,008h		;4f7a
	call UN_DESPLAZAMIENTO		;4f7c
	jp DOBLA_LOS_PUNTOS		;4f7f   ; y su doble en las impares
PUNTUA_POR_DISTANCIA:
	ld a,(de)			;4f82   ; la referencia
	ld b,a			;4f83
	ld a,(0e010h)		;4f84   ; con un solo jugador se salta el segundo
	or a			;4f87
	jr z,PUNTUA_POR_DISTANCIA_AL_1		;4f88
	push bc			;4f8a
	ld hl,0e07bh		;4f8b   ; la marca del jugador 2
	call MARCA_MENOS_REFERENCIA		;4f8e   ; marca menos referencia
	jr c,RECUPERA_LA_REFERENCIA		;4f91
	ld hl,0e08dh		;4f93
	call GUARDA_Y_ESCALA		;4f96
	jr nc,DOBLA_Y_SIGUE		;4f99
	ld d,008h		;4f9b
	call UN_DESPLAZAMIENTO		;4f9d
	jr RECUPERA_LA_REFERENCIA		;4fa0
DOBLA_Y_SIGUE:
	call DOBLA_LOS_PUNTOS		;4fa2
RECUPERA_LA_REFERENCIA:
	pop bc			;4fa5
PUNTUA_POR_DISTANCIA_AL_1:
	ld hl,0e06bh		;4fa6   ; la marca del jugador 1
	call MARCA_MENOS_REFERENCIA		;4fa9
	ret c			;4fac
	ld hl,0e08ah		;4fad
	call GUARDA_Y_ESCALA		;4fb0
	jr nc,DOBLA_Y_SALE		;4fb3
	ld d,008h		;4fb5
	call UN_DESPLAZAMIENTO		;4fb7
	ret			;4fba
DOBLA_Y_SALE:
	jp DOBLA_LOS_PUNTOS		;4fbb
MULTIPLICA_POR_DIECISEIS:
	xor a			;4fbe
	ld d,004h		;4fbf   ; cuatro desplazamientos
UN_DESPLAZAMIENTO:
	sla c		;4fc1   ; BC a la izquierda, y lo que se sale va a A
	rl b		;4fc3
	rla			;4fc5
	dec d			;4fc6
	jr nz,UN_DESPLAZAMIENTO		;4fc7
	push hl			;4fc9
	ld (hl),c			;4fca   ; los tres bytes del resultado
	dec hl			;4fcb
	ld (hl),b			;4fcc
	dec hl			;4fcd
	ld (hl),a			;4fce
	pop hl			;4fcf
	ret			;4fd0
DOBLA_LOS_PUNTOS:
	ld a,(hl)			;4fd1   ; el byte de abajo
	add a,a			;4fd2
	daa			;4fd3
	ld (hl),a			;4fd4
	ld b,002h		;4fd5   ; y los dos de arriba, con acarreo
DOBLA_UN_BYTE:
	dec hl			;4fd7
	ld a,(hl)			;4fd8   ; el byte siguiente, con el acarreo del anterior
	adc a,(hl)			;4fd9   ; sumarse a si mismo es doblar
	daa			;4fda
	ld (hl),a			;4fdb
	djnz DOBLA_UN_BYTE		;4fdc
	ret			;4fde
REFERENCIA_MENOS_MARCA:
	ld c,(hl)			;4fdf   ; la marca, dos bytes
	dec hl			;4fe0
	ld b,(hl)			;4fe1
	xor a			;4fe2   ; cero menos la marca, en BCD
	sub c			;4fe3
	daa			;4fe4
	ld c,a			;4fe5
	ld a,(de)			;4fe6   ; y la referencia por encima
	sbc a,b			;4fe7
	daa			;4fe8
	ld b,a			;4fe9
	ret			;4fea
GUARDA_Y_ESCALA:
	ld (hl),b			;4feb   ; deja la diferencia donde va
	inc hl			;4fec
	ld (hl),c			;4fed
DEVUELVE_SI_ES_IMPAR:
	jp ES_PRUEBA_IMPAR		;4fee
MARCA_MENOS_REFERENCIA:
	call ES_PRUEBA_IMPAR		;4ff1   ; en las pares se tira la cifra de abajo
	ld a,(hl)			;4ff4
	jr c,GUARDA_LA_DIFERENCIA		;4ff5
	and 0f0h		;4ff7
GUARDA_LA_DIFERENCIA:
	ld c,a			;4ff9
	dec hl			;4ffa
	ld a,(hl)			;4ffb   ; y la diferencia contra la referencia
	sub b			;4ffc
	daa			;4ffd
	ld b,a			;4ffe
	ret			;4fff
COMPARA_TRES_BYTES:
	ld b,002h		;5000
COMPARA_N_BYTES:
	or a			;5002   ; acarreo limpio para la primera resta
UNA_RESTA:
	ld a,(de)			;5003   ; (DE) menos (HL) desde el byte de abajo; solo interesa el acarreo
	sbc a,(hl)			;5004
	dec hl			;5005
	dec de			;5006
	djnz UNA_RESTA		;5007
	ret			;5009

; ----------------------------------------------------------------------
; DATOS marcas_de_clasificacion: La marca que hay que batir en cada una de las
;   DOCE rondas, dos bytes en BCD. 0x4651 la lee con 2*(ronda-1).
;   0x500a..0x5022  (24 bytes)
DATA_marcas_de_clasificacion:
	defw 00015h	; 500a
	defw 00075h	; 500c
	defw 03002h	; 500e
	defw 03004h	; 5010
	defw 00013h	; 5012
	defw 00085h	; 5014
	defw 03502h	; 5016
	defw 00004h	; 5018
	defw 00011h	; 501a
	defw 00090h	; 501c
	defw 04002h	; 501e
	defw 03003h	; 5020

; ----------------------------------------------------------------------
; DATOS marca_de_referencia: La marca desde la que se cuentan los puntos, una
;   por prueba (0x4F36).
;   0x5022..0x5026  (4 bytes)
DATA_marca_de_referencia:
	defb 024h,030h,001h,003h	; 5022

; ----------------------------------------------------------------------
; DATOS marco_del_marcador: El recuadro de arriba con SCORE, WORLD RECORD y
;   QUALIFY. Guion corto de ocho bloques.
;   0x5026..0x50f6  (208 bytes)
DATA_marco_del_marcador:
	defb 078h,000h,0a0h,07bh,083h,086h,086h,09bh	; 5026  x..{....
	defb 09ch,09dh,09eh,09fh,086h,086h,086h,087h	; 502e  ........
	defb 083h,086h,09ah,09dh,09eh,099h,098h,000h	; 5036  ........
	defb 09eh,09fh,09ch,09dh,09eh,098h,086h,087h	; 503e  ........
	defb 07dh,0a0h,0ffh,078h,020h,0a0h,07bh,084h	; 5046  }..x .{.
	defb 0c7h,0c8h,0feh,008h,000h,088h,084h,0feh	; 504e  ........
	defb 006h,000h,0deh,0dfh,0feh,006h,000h,088h	; 5056  ........
	defb 07dh,0a0h,0ffh,078h,040h,0a0h,07bh,084h	; 505e  }..x@.{.
	defb 0f1h,0cfh,0feh,008h,000h,088h,085h,0feh	; 5066  ........
	defb 00eh,086h,089h,07dh,0a0h,0ffh,078h,060h	; 506e  ...}..x`
	defb 0a0h,07bh,084h,0f2h,0cfh,0feh,008h,000h	; 5076  .{......
	defb 088h,000h,0e3h,0e4h,0e5h,0e6h,0e7h,0e8h	; 507e  ........
	defb 0e9h,000h,000h,000h,0deh,0dfh,000h,000h	; 5086  ........
	defb 000h,07dh,0a0h,0ffh,078h,080h,0a0h,07bh	; 508e  .}..x..{
	defb 085h,0feh,00ah,086h,089h,0feh,004h,000h	; 5096  ........
	defb 08ah,08dh,0feh,005h,090h,092h,095h,000h	; 509e  ........
	defb 000h,000h,07dh,0a0h,0ffh,078h,0a0h,0a0h	; 50a6  ..}..x..
	defb 07bh,0f1h,0cfh,000h,000h,000h,0feh,003h	; 50ae  {.......
	defb 0bfh,000h,000h,0feh,006h,000h,08bh,08eh	; 50b6  ........
	defb 0f0h,0f0h,0e2h,0f0h,0f0h,093h,096h,000h	; 50be  ........
	defb 000h,000h,07dh,0a0h,0ffh,078h,0c0h,0a0h	; 50c6  ..}..x..
	defb 07bh,0f2h,0cfh,000h,000h,000h,0feh,003h	; 50ce  {.......
	defb 0bfh,000h,000h,0feh,006h,000h,08ch,08fh	; 50d6  ........
	defb 0feh,005h,091h,094h,097h,000h,000h,000h	; 50de  ........
	defb 07dh,0a0h,0ffh,078h,0e0h,0a0h,07ch,07fh	; 50e6  }..x..|.
	defb 0feh,01ah,081h,080h,07eh,0a0h,0ffh,0ffh	; 50ee  ....~...

; ----------------------------------------------------------------------
; DATOS rotulo_de_dos_jugadores: Lo que se anade al marcador cuando juegan dos
;   (0x4290).
;   0x50f6..0x5113  (29 bytes)
DATA_rotulo_de_dos_jugadores:
	defb 078h,035h,0dch,0ddh,0ffh,078h,079h,0dch	; 50f6  x5...xy.
	defb 0ddh,0ffh,078h,090h,0feh,00dh,000h,0ffh	; 50fe  ..x.....
	defb 078h,0a5h,0feh,018h,000h,0ffh,078h,0c5h	; 5106  x.....x.
	defb 0feh,018h,000h,0ffh,0ffh	; 510e

; ----------------------------------------------------------------------
; DATOS rotulo_de_intentos: La columna de TRY del marcador de la jabalina y la
;   altura (0x4344).
;   0x5113..0x5135  (34 bytes)
DATA_rotulo_de_intentos:
	defb 078h,090h,0f1h,000h,0d2h,0d0h,0d6h,0feh	; 5113  x.......
	defb 008h,000h,0ffh,078h,0b0h,0f2h,000h,0d2h	; 511b  ...x....
	defb 0d0h,0d6h,0feh,008h,000h,0ffh,078h,0d0h	; 5123  ......x.
	defb 0f3h,000h,0d2h,0d0h,0d6h,0feh,008h,000h	; 512b  ........
	defb 0ffh,0ffh	; 5133

; ----------------------------------------------------------------------
; DATOS rotulo_del_segundo_reloj: El trozo de marcador que 0x428B anade en las
;   pruebas de tiempo.
;   0x5135..0x5140  (11 bytes)
DATA_rotulo_del_segundo_reloj:
	defb 078h,035h,0e0h,0e1h,0ffh,078h,079h,0e0h	; 5135  x5...xy.
	defb 0e1h,0ffh,0ffh	; 513d

; ----------------------------------------------------------------------
; DATOS rotulo_de_fallo: Seis codigos de caracter que 0x4379 y 0x4521 escriben
;   cuando un intento no vale.
;   0x5140..0x5146  (6 bytes)
DATA_rotulo_de_fallo:
	defb 000h,0c5h,0ceh,0d3h,0cbh,000h	; 5140

; ----------------------------------------------------------------------
; DATOS rotulo_de_unidad: Cuatro codigos de caracter que se ponen al lado del
;   resultado.
;   0x5146..0x514a  (4 bytes)
DATA_rotulo_de_unidad:
	defb 0dch,0ddh,0deh,0dfh	; 5146

; ----------------------------------------------------------------------
; DATOS rotulo_de_turno: Tres codigos de caracter que 0x42AB pone en 0x38A2 o
;   en 0x38C2 segun a quien le toque.
;   0x514a..0x514d  (3 bytes)
DATA_rotulo_de_turno:
	defb 0c2h,0cfh,0d3h	; 514a

; ----------------------------------------------------------------------
; DATOS pantalla_de_fin_de_ronda: Guion corto de un bloque que 0x46D4 saca al
;   acabar la vuelta.
;   0x514d..0x5161  (20 bytes)
DATA_pantalla_de_fin_de_ronda:
	defb 079h,089h,000h,0ech,0e0h,000h,000h,0e8h	; 514d  y.......
	defb 0e2h,0e9h,0e4h,000h,0eah,0ebh,0e4h,0e5h	; 5155  ........
	defb 000h,000h,0ffh,0ffh	; 515d

; ----------------------------------------------------------------------
; DATOS colores_de_los_sprites: Un color por cada uno de los 26 sprites; los
;   sube 0x4389 a la tabla de atributos con la Y a 0xD1, o sea escondidos. Son
;   SEIS MENOS que en el cartucho hermano, que subia 32.
;   0x5161..0x517b  (26 bytes)
DATA_colores_de_los_sprites:
	defb 00fh,00fh,00fh,00fh,00bh,006h,00fh,00bh	; 5161  ........
	defb 001h,00bh,001h,006h,001h,007h,006h,00fh	; 5169  ........
	defb 006h,00fh,001h,001h,001h,001h,001h,001h	; 5171  ........
	defb 001h,001h	; 5179

; ----------------------------------------------------------------------
; DATOS records_del_mundo: Los cuatro records del mundo, tres bytes en BCD por
;   prueba, copiados a 0xE040 por 0x40B8: 12.93 en las 110 vallas, 96.72 en
;   jabalina, 2.36 en altura y 3.31 en los 1500. Son marcas reales, pero
;   ANTERIORES a la temporada de 1983: cuando el cartucho salio, TRES de las
;   cuatro ya estaban batidas. Ver docs/es/HALLAZGOS.md.
;   0x517b..0x5187  (12 bytes)
DATA_records_del_mundo:
	defb 000h,012h,093h	; 517b
	defb 000h,096h,072h	; 517e
	defb 000h,002h,036h	; 5181
	defb 000h,003h,031h	; 5184

; ======================================================================
; CODIGO 0x5187..0x53e3  (604 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  MOTOR DE LAS 110 VALLAS Y LOS 1500 METROS  ==========
; Lo llama la interrupcion una vez por cuadro. Los dos atletas NO se
; mueven en el mismo cuadro: en los pares se mueve el del jugador 1 y en
; los impares el del 2, que es como el cartucho se ahorra la mitad del
; trabajo por cuadro.
; ----------------------------------------------------------------------
MOTOR_DE_LA_CARRERA:
	ld hl,0e02eh		;5187
	bit 2,(hl)		;518a   ; bit 2: se acabo el tiempo
	jr nz,MUEVE_A_UNO_DE_LOS_DOS		;518c
	bit 6,(hl)		;518e   ; bit 6: hay carrera en marcha
	jr z,APUNTA_LAS_PULSACIONES		;5190
	call REPARTE_EL_ESFUERZO		;5192   ; reparte el esfuerzo de las pulsaciones
	call SUMA_LA_VELOCIDAD_A_LA_MARCA		;5195   ; lo convierte en avance
	call REPARTE_EL_AVANCE		;5198   ; y reparte el avance entre los dos
APUNTA_LAS_PULSACIONES:
	ld a,(0e00bh)		;519b   ; el boton del jugador 1
	rrca			;519e
	jr nc,APUNTA_LA_DEL_JUGADOR_2		;519f
	ld a,001h		;51a1
	ld (0e0ceh),a		;51a3   ; queda apuntado en 0xE0CC
APUNTA_LA_DEL_JUGADOR_2:
	ld a,(0e00fh)		;51a6   ; el boton del jugador 2
	rrca			;51a9
	jr nc,CUENTA_EL_RELOJ		;51aa
	ld a,001h		;51ac
	ld (0e0cfh),a		;51ae   ; y en 0xE0CD
CUENTA_EL_RELOJ:
	call EL_RELOJ_DE_LA_PRUEBA		;51b1   ; el reloj de la prueba
MUEVE_A_UNO_DE_LOS_DOS:
	ld a,(0e000h)		;51b4   ; el contador de cuadros
	rrca			;51b7
	jr c,MUEVE_AL_JUGADOR_2		;51b8
	call MUEVE_AL_ATLETA_1		;51ba   ; mueve al atleta del jugador 1
	xor a			;51bd
	ld (0e0ceh),a		;51be
	ld a,(0e028h)		;51c1   ; bit 2 de 0xE028: ya ha llegado
	bit 2,a		;51c4
	jr nz,PINTA_AL_JUGADOR_1		;51c6
	ld hl,0e150h		;51c8   ; la ficha del segundo objeto
	call MUEVE_Y_PINTA_UN_ACTOR		;51cb
	ld a,001h		;51ce
	call MUEVE_EL_DECORADO		;51d0   ; y su sprite
	xor a			;51d3
	ld de,0e153h		;51d4
	ld (de),a			;51d7
PINTA_AL_JUGADOR_1:
	ld hl,0e130h		;51d8   ; y la ficha del atleta del jugador 1
	jp MUEVE_Y_PINTA_UN_ACTOR		;51db
MUEVE_AL_JUGADOR_2:
	call MUEVE_AL_ATLETA_2		;51de   ; mueve al atleta del jugador 2
	xor a			;51e1
	ld (0e0cfh),a		;51e2
	ld a,(0e029h)		;51e5   ; bit 2 de 0xE029: ya ha llegado
	bit 2,a		;51e8
	jr nz,PINTA_AL_JUGADOR_2		;51ea
	ld hl,0e140h		;51ec   ; la ficha del primer objeto
	call MUEVE_Y_PINTA_UN_ACTOR		;51ef
	xor a			;51f2
	call MUEVE_EL_DECORADO		;51f3
	xor a			;51f6
	ld de,0e143h		;51f7
	ld (de),a			;51fa
PINTA_AL_JUGADOR_2:
	ld hl,0e120h		;51fb
	jp MUEVE_Y_PINTA_UN_ACTOR		;51fe
REPARTE_EL_ESFUERZO:
	ld hl,0e021h		;5201
	bit 1,(hl)		;5204   ; el jugador 2 sigue en juego
	jr nz,MIRA_A_QUIEN_LE_TOCA_GASTAR		;5206
	bit 0,(hl)		;5208   ; o el 1
	jr nz,MIRA_A_QUIEN_LE_TOCA_GASTAR_2		;520a
MIRA_A_QUIEN_LE_TOCA_GASTAR:
	call ES_PRUEBA_IMPAR		;520c
	jr nc,GASTA_LA_DEL_JUGADOR_1		;520f
	ld a,(0e0bah)		;5211
	or a			;5214
	jr nz,MIRA_AL_SEGUNDO_EN_JUEGO		;5215
GASTA_LA_DEL_JUGADOR_1:
	push hl			;5217
	ld a,(0e0b7h)		;5218   ; bit 2 de 0xE028: el jugador 1 ya ha llegado
	bit 6,a		;521b
	jr nz,LE_TOCA_AL_JUGADOR_2		;521d
	ld hl,0e0adh		;521f   ; su velocidad
	ld a,(0e00bh)		;5222   ; la pulsacion apuntada
	ld (0e0c5h),a		;5225
	call GASTA_Y_APUNTA		;5228   ; gasta un poco de velocidad
LE_TOCA_AL_JUGADOR_2:
	pop hl			;522b
MIRA_AL_SEGUNDO_EN_JUEGO:
	bit 1,(hl)		;522c   ; bit 1: el jugador 2 sigue en juego
	jr z,MIRA_A_QUIEN_LE_TOCA_GASTAR_2		;522e
	call ES_PRUEBA_IMPAR		;5230   ; en las pruebas impares le toca al 1
	jr nc,PASA_AL_JUGADOR_2		;5233
	ld a,(0e0f0h)		;5235   ; con velocidad no hace falta empujar
	or a			;5238
	ret nz			;5239
PASA_AL_JUGADOR_2:
	ld hl,0e0e4h		;523a   ; y le toca al 2
	ld de,0e0ebh		;523d
	ld a,(0e0edh)		;5240
	jp MIRA_EL_BIT_6		;5243
MIRA_A_QUIEN_LE_TOCA_GASTAR_2:
	call ES_PRUEBA_IMPAR		;5246
	jr nc,REPARTE_EL_ESFUERZO_DEL_2		;5249
	ld a,(0e0f0h)		;524b
	or a			;524e
	jr nz,MIRA_AL_PRIMERO_EN_JUEGO		;524f
REPARTE_EL_ESFUERZO_DEL_2:
	push hl			;5251
	ld a,(0e0edh)		;5252
	bit 6,a		;5255
	jr nz,LE_TOCA_AL_JUGADOR_1		;5257
	ld hl,0e0e3h		;5259   ; la velocidad del jugador 2
	ld a,(0e00fh)		;525c   ; su pulsacion
	ld (0e0c5h),a		;525f
	call GASTA_Y_APUNTA		;5262
LE_TOCA_AL_JUGADOR_1:
	pop hl			;5265
MIRA_AL_PRIMERO_EN_JUEGO:
	bit 0,(hl)		;5266   ; bit 0: el jugador 1 sigue en juego
	ret z			;5268
	call ES_PRUEBA_IMPAR		;5269   ; y en las impares le toca a el
	jr nc,PASA_AL_JUGADOR_1		;526c
	ld a,(0e0bah)		;526e
	or a			;5271
	ret nz			;5272
PASA_AL_JUGADOR_1:
	ld hl,0e0aeh		;5273   ; y luego el 1
	ld de,0e0b5h		;5276
	ld a,(0e0b7h)		;5279
	jp MIRA_EL_BIT_6		;527c
MIRA_EL_BIT_6:
	bit 6,a		;527f
	ret nz			;5281
	ld a,(hl)			;5282   ; su velocidad
	cp 005h		;5283
	jr nc,GASTA_A_TODA_VELOCIDAD		;5285
	dec hl			;5287
	ld a,001h		;5288
	ld (0e0c5h),a		;528a   ; hay marca nueva que pintar
	push hl			;528d
	ld hl,0e02eh		;528e
	set 5,(hl)		;5291
	pop hl			;5293
	call GASTA_Y_APUNTA		;5294   ; gasta lo que toque
	ld a,(hl)			;5297   ; y baja la velocidad 0x20 en BCD
	sub 020h		;5298
	daa			;529a
	ld (hl),a			;529b
	inc hl			;529c
	ld b,000h		;529d
	ld a,(hl)			;529f
	sbc a,b			;52a0   ; con acarreo al byte de arriba
	daa			;52a1
	ld (hl),a			;52a2
	inc hl			;52a3
	ld a,(hl)			;52a4
	sub 014h		;52a5   ; y la distancia recorrida baja 0x14
	ld (hl),a			;52a7
	inc hl			;52a8
	jr nc,SIN_VELOCIDAD_QUE_GASTAR		;52a9
	dec (hl)			;52ab
SIN_VELOCIDAD_QUE_GASTAR:
	ret			;52ac
GASTA_A_TODA_VELOCIDAD:
	dec hl			;52ad
	ex de,hl			;52ae
	ld a,(0e021h)		;52af   ; mira a quien le toca
	rrca			;52b2
	ld a,(0e0ebh)		;52b3   ; la posicion del otro atleta
	jr c,COMPARA_LAS_DOS_POSICIONES		;52b6
	ld a,(0e0b5h)		;52b8
COMPARA_LAS_DOS_POSICIONES:
	ld c,a			;52bb
	cp (hl)			;52bc   ; comparada con la de este
	ex de,hl			;52bd
	ld b,002h		;52be   ; se gastan dos por cuadro
	jr c,FRENA_UN_POCO		;52c0   ; si va por detras, no se le frena mas
	ld a,(0e02eh)		;52c2
	bit 7,a		;52c5   ; bit 7 de 0xE02E: el que va delante ya frena poco
	jr nz,SALTA_AL_SIGUIENTE_CAMPO		;52c7
	ld a,(de)			;52c9   ; su velocidad
	ld b,001h		;52ca
	cp 018h		;52cc   ; por debajo de 0x18 solo se gasta uno
	jr nc,FRENA_UN_POCO		;52ce
	push hl			;52d0
	ld hl,0e02eh		;52d1
	set 7,(hl)		;52d4
	pop hl			;52d6
	jr SALTA_AL_SIGUIENTE_CAMPO		;52d7
FRENA_UN_POCO:
	push hl			;52d9
	ld hl,0e02eh		;52da   ; baja el bit de "va suelto"
	res 7,(hl)		;52dd
	pop hl			;52df
	push bc			;52e0
	ld a,(hl)			;52e1   ; baja la velocidad en BCD
	sub b			;52e2
	daa			;52e3
	ld (hl),a			;52e4
	inc hl			;52e5
	ld c,000h		;52e6
	ld a,(hl)			;52e8
	sbc a,c			;52e9
	daa			;52ea
	ld (hl),a			;52eb
	inc hl			;52ec
	ld a,(hl)			;52ed   ; y la distancia
	sub b			;52ee
	ld (hl),a			;52ef
	inc hl			;52f0   ; con acarreo
	jr nc,MIRA_EL_SUELO_DE_VELOCIDAD		;52f1
	dec (hl)			;52f3
MIRA_EL_SUELO_DE_VELOCIDAD:
	dec hl			;52f4
	dec hl			;52f5
	ld a,(hl)			;52f6   ; por debajo de 5 la velocidad se planta
	cp 005h		;52f7
	jr nc,MIRA_SI_HAY_QUE_REFRESCAR		;52f9
	dec hl			;52fb
	ld (hl),000h		;52fc   ; en 0x05F4 de velocidad y 0x01 de distancia
	inc hl			;52fe
	ld (hl),005h		;52ff
	inc hl			;5301
	ld (hl),0f4h		;5302
	inc hl			;5304
	ld (hl),001h		;5305
	dec hl			;5307
	dec hl			;5308
MIRA_SI_HAY_QUE_REFRESCAR:
	dec hl			;5309
	pop bc			;530a
	ld a,c			;530b
	cp 011h		;530c   ; con el otro por debajo de 0x11
	jr c,LIMPIA_EL_TRAMO		;530e
	ex de,hl			;5310
	ld hl,0e02eh		;5311
	bit 3,(hl)		;5314   ; bit 3 de 0xE02E
	jr z,LIMPIA_EL_TRAMO		;5316
	ex de,hl			;5318
SALTA_AL_SIGUIENTE_CAMPO:
	inc hl			;5319
	ld a,011h		;531a
	cp (hl)			;531c
	dec hl			;531d
	jr c,LIMPIA_EL_TRAMO		;531e
APUNTA_EL_REFRESCO:
	ld a,001h		;5320
	ld (0e0c5h),a		;5322   ; hay marca nueva
	ld a,(0e02eh)		;5325
	set 5,a		;5328   ; bit 5 de 0xE02E
	ld (0e02eh),a		;532a
	call GASTA_Y_APUNTA		;532d
LIMPIA_EL_TRAMO:
	ld hl,0e02eh		;5330
	res 3,(hl)		;5333
	ret			;5335
GASTA_Y_APUNTA:
	push de			;5336
	push hl			;5337
	ld b,002h		;5338   ; dos por cuadro
	ld a,(0e016h)		;533a
	bit 2,a		;533d
	jr z,GASTA_LA_VELOCIDAD_BCD		;533f
	ld hl,(0e0b2h)		;5341   ; la marca del jugador 2
	ld a,(0e000h)		;5344   ; en los cuadros pares
	rrca			;5347
	jr nc,RESTA_LO_QUE_FALTA		;5348
	ld hl,(0e0e8h)		;534a   ; la del jugador 1
RESTA_LO_QUE_FALTA:
	ld de,0aab0h		;534d   ; lo que falta para 0x1D4
	add hl,de			;5350
	jr c,GASTA_DOS_POR_CUADRO		;5351
	ld b,001h		;5353   ; cerca de la meta solo se gasta uno
GASTA_DOS_POR_CUADRO:
	pop hl			;5355
	push hl			;5356
GASTA_LA_VELOCIDAD_BCD:
	ld a,(hl)			;5357
	or a			;5358
	jr nz,RESTA_LA_VELOCIDAD		;5359   ; con la velocidad ya a cero no hay nada que gastar
	inc hl			;535b
	ld a,(hl)			;535c
	or a			;535d
	dec hl			;535e
	jr z,GASTA_LA_DISTANCIA		;535f
RESTA_LA_VELOCIDAD:
	ld a,(hl)			;5361
	sub b			;5362   ; en BCD
	daa			;5363
	ld (hl),a			;5364
	jr nc,GASTA_LA_DISTANCIA		;5365
	inc hl			;5367
	ld a,(hl)			;5368
	sub 001h		;5369   ; con acarreo al byte de arriba
	daa			;536b
	ld (hl),a			;536c
	jr nc,GASTA_LA_DISTANCIA		;536d
	xor a			;536f   ; y sin bajar de cero
	ld (hl),a			;5370
	dec hl			;5371
	ld (hl),a			;5372
GASTA_LA_DISTANCIA:
	pop hl			;5373
	push hl			;5374
	inc hl			;5375
	inc hl			;5376
	ld a,(hl)			;5377   ; la distancia, dos bytes en binario
	or a			;5378
	jr nz,RESTA_LA_DISTANCIA		;5379
	inc hl			;537b
	ld a,(hl)			;537c   ; el byte de arriba
	or a			;537d
	dec hl			;537e
	jr z,MIRA_EL_TRAMO		;537f
RESTA_LA_DISTANCIA:
	ld a,(hl)			;5381   ; le resta la velocidad
	sub b			;5382
	ld (hl),a			;5383
	jr nc,MIRA_EL_TRAMO		;5384
	inc hl			;5386   ; con acarreo al byte de arriba
	ld a,(hl)			;5387
	sub 001h		;5388
	ld (hl),a			;538a
	jr nc,MIRA_EL_TRAMO		;538b
	xor a			;538d   ; y sin bajar de cero
	ld (hl),a			;538e
	dec hl			;538f
	ld (hl),a			;5390
MIRA_EL_TRAMO:
	pop hl			;5391
	ld a,(0e0c5h)		;5392   ; la marca de refresco
	rrca			;5395
	jr nc,SIN_TRAMO		;5396   ; sin ella no hay tramo que apuntar
	xor a			;5398
	ld (0e0c5h),a		;5399
	push hl			;539c
	ld hl,0e02eh		;539d
	bit 5,(hl)		;53a0   ; bit 5: el tramo no cuenta
	jr nz,APUNTA_UN_TRAMO		;53a2
	set 3,(hl)		;53a4   ; y si no, se apunta
APUNTA_UN_TRAMO:
	res 5,(hl)		;53a6
	pop hl			;53a8
	push hl			;53a9
	ld a,(0e016h)		;53aa   ; la prueba
	ld de,053e3h		;53ad   ; la tabla de avance de las de tiempo
	cp 004h		;53b0
	jr z,SUMA_EL_TRAMO		;53b2
	ld de,05403h		;53b4   ; o la de las de distancia
SUMA_EL_TRAMO:
	inc hl			;53b7
	ld b,000h		;53b8   ; el nivel de esfuerzo
	ld a,(hl)			;53ba
	cp 010h		;53bb
	jr c,BUSCA_EN_LA_TABLA_DE_AVANCE		;53bd   ; por encima de 0x10 se recorta seis
	sub 006h		;53bf
BUSCA_EN_LA_TABLA_DE_AVANCE:
	ld c,a			;53c1
	ex de,hl			;53c2
	add hl,bc			;53c3   ; la casilla del nivel
	ld a,(hl)			;53c4
	ex de,hl			;53c5
	dec hl			;53c6
	add a,(hl)			;53c7   ; se suma a la marca en BCD
	daa			;53c8
	ld (hl),a			;53c9
	inc hl			;53ca
	ld a,000h		;53cb
	adc a,(hl)			;53cd
	daa			;53ce
	ld (hl),a			;53cf
	push hl			;53d0
	ex de,hl			;53d1
	ld de,00010h		;53d2   ; la segunda tira de la misma tabla
	add hl,de			;53d5
	ld a,(hl)			;53d6
	pop hl			;53d7
	inc hl			;53d8
	add a,(hl)			;53d9   ; y se suma al reloj, este en binario
	ld (hl),a			;53da
	inc hl			;53db
	ld a,000h		;53dc
	adc a,(hl)			;53de
	ld (hl),a			;53df
	pop hl			;53e0
SIN_TRAMO:
	pop de			;53e1
	ret			;53e2

; ----------------------------------------------------------------------
; DATOS avance_de_las_pruebas_de_tiempo: Dos tiras de dieciseis: cuanto suma
;   la marca y cuanto el reloj en cada nivel de esfuerzo. Las usan las 110
;   vallas y los 1500.
;   0x53e3..0x5403  (32 bytes)
DATA_avance_de_las_pruebas_de_tiempo:
	defb 094h,081h,078h,065h,047h,030h,020h,010h,008h,007h,006h,005h,004h,003h,002h,000h	; 53e3  ..xeG0 .........
	defb 05eh,051h,04eh,041h,02fh,01eh,014h,00ah,008h,007h,006h,005h,004h,003h,002h,000h	; 53f3  ^QNA/...........

; ----------------------------------------------------------------------
; DATOS avance_de_las_pruebas_de_distancia: Las mismas dos tiras para la
;   jabalina y la altura.
;   0x5403..0x5423  (32 bytes)
DATA_avance_de_las_pruebas_de_distancia:
	defb 099h,095h,090h,085h,080h,075h,070h,060h,050h,040h,030h,020h,015h,012h,006h,000h	; 5403  .....up`P@0 ....
	defb 063h,05fh,05ah,055h,050h,04bh,046h,03ch,032h,028h,01eh,014h,00fh,00ch,006h,000h	; 5413  c_ZUPKF<2(......

; ======================================================================
; CODIGO 0x5423..0x57fc  (985 bytes)
; ======================================================================


SUMA_LA_VELOCIDAD_A_LA_MARCA:
	ld a,(0e0edh)		;5423
	rrca			;5426   ; bit 0 de 0xE0ED: el jugador 2 ya no corre
	ld hl,0e0e5h		;5427   ; su velocidad
	ld de,0e0eeh		;542a   ; y su marca
	call nc,MULTIPLICA_LA_VELOCIDAD		;542d
	ld a,(0e0b7h)		;5430   ; bit 0 de 0xE0B7: el jugador 1 ya no corre
	rrca			;5433
	ret c			;5434
	ld hl,0e0afh		;5435   ; su velocidad
	ld de,0e0b8h		;5438
MULTIPLICA_LA_VELOCIDAD:
	push de			;543b
	call ES_PRUEBA_DE_DISTANCIA		;543c   ; en las pruebas de distancia
	ld b,019h		;543f   ; se suma 0x19 veces
	jr nz,SUMA_REPETIDA		;5441
	ld b,03ah		;5443   ; y en las de tiempo 0x3A
SUMA_REPETIDA:
	ld c,000h		;5445
	ld e,(hl)			;5447   ; la velocidad, dos bytes en BCD
	ld d,(hl)			;5448
	inc hl			;5449
	ld a,(hl)			;544a
	ld h,(hl)			;544b
	ld l,a			;544c
UNA_SUMA:
	ld a,e			;544d   ; byte de abajo
	add a,d			;544e
	daa			;544f
	ld e,a			;5450
	ld a,l			;5451   ; byte de arriba
	adc a,h			;5452
	daa			;5453
	ld h,a			;5454
	ld a,c			;5455   ; y el acarreo se guarda aparte
	adc a,000h		;5456
	ld c,a			;5458
	djnz UNA_SUMA		;5459
	ld a,h			;545b
	pop hl			;545c   ; la casilla de destino
	add a,(hl)			;545d   ; se le suma lo acumulado
	daa			;545e
	ld (hl),a			;545f
	inc hl			;5460
	ld a,c			;5461
	adc a,(hl)			;5462
	daa			;5463
	ld (hl),a			;5464
	ret			;5465
REPARTE_EL_AVANCE:
	ld hl,0e028h		;5466
	bit 2,(hl)		;5469   ; bit 2 de 0xE028: el jugador 1 ya ha llegado
	jr z,MIRA_AL_JUGADOR_2		;546b
	ld hl,0e0b5h		;546d   ; entonces solo avanza el 2
	call AVANZA_EL_ATLETA		;5470
	ld hl,0e029h		;5473
	bit 2,(hl)		;5476   ; bit 2 de 0xE029: y el 2 tambien
	jr nz,SOLO_AVANZA_UNO		;5478
	ld hl,0e141h		;547a   ; la columna del objeto del jugador 2
	ld a,(0e0efh)		;547d   ; se le suma su avance
	add a,(hl)			;5480
	ld (hl),a			;5481
	jr FIN_DEL_REPARTO		;5482
MIRA_AL_JUGADOR_2:
	inc hl			;5484
	bit 2,(hl)		;5485   ; bit 2 de 0xE029: el 2 ha llegado
	jr z,AVANZAN_LOS_DOS		;5487
	ld hl,0e151h		;5489   ; la columna del objeto del jugador 1
	ld a,(0e0b9h)		;548c
	add a,(hl)			;548f
	ld (hl),a			;5490
SOLO_AVANZA_UNO:
	ld hl,0e0ebh		;5491
	call AVANZA_EL_ATLETA		;5494
FIN_DEL_REPARTO:
	jp LIMPIA_LOS_AVANCES		;5497
AVANZAN_LOS_DOS:
	ld hl,(0e0b2h)		;549a   ; la posicion del jugador 1
	ld a,(0e0b9h)		;549d   ; mas su avance
	call SUMA_A_A_HL		;54a0
	ex de,hl			;54a3
	ld hl,(0e0e8h)		;54a4   ; la del jugador 2
	ld a,(0e0efh)		;54a7   ; mas el suyo
	call SUMA_A_A_HL		;54aa
	push hl			;54ad
	ld hl,0e0ebh		;54ae
	ld a,(0e0b5h)		;54b1   ; quien va delante
	cp (hl)			;54b4
	pop hl			;54b5
	jr nc,COMPARA_LAS_POSICIONES		;54b6
	ex de,hl			;54b8
COMPARA_LAS_POSICIONES:
	or a			;54b9
	sbc hl,de		;54ba   ; si van igualados
	jr nz,UNO_SE_QUEDA_ATRAS		;54bc
	ld hl,0e0b9h		;54be   ; los dos avanzan lo suyo y no hay arrastre
	ld a,(hl)			;54c1
	ld (hl),000h		;54c2
	ld hl,0e151h		;54c4
	add a,(hl)			;54c7
	ld (hl),a			;54c8
	ld hl,0e0efh		;54c9
	ld a,(hl)			;54cc
	ld (hl),000h		;54cd
	ld hl,0e141h		;54cf
	add a,(hl)			;54d2
	ld (hl),a			;54d3
	ret			;54d4
UNO_SE_QUEDA_ATRAS:
	jp c,EL_JUGADOR_2_VA_DELANTE		;54d5   ; si el de detras es el que manda, por el otro lado
	exx			;54d8
	ld hl,(0e0e8h)		;54d9   ; las dos posiciones en el juego alterno
	ld de,(0e0b2h)		;54dc
	exx			;54e0
	ld de,0e0efh		;54e1   ; el avance del jugador 2
	ld a,(de)			;54e4
	ld (0e0c7h),a		;54e5
	ld bc,0e0b9h		;54e8   ; y el del 1
	ld a,(bc)			;54eb
	ld (0e0c8h),a		;54ec
	ld hl,0e0ebh		;54ef
	ld a,(0e0b5h)		;54f2
	cp (hl)			;54f5   ; el que va delante manda la camara
	jr c,MIRA_SI_CABEN_LOS_DOS		;54f6
	ld de,0e0b9h		;54f8
	ld a,(de)			;54fb
	ld (0e0c7h),a		;54fc
	ld bc,0e0efh		;54ff
	ld a,(bc)			;5502
	ld (0e0c8h),a		;5503
	ld a,(0e0ebh)		;5506
	exx			;5509
	ex de,hl			;550a
	exx			;550b
MIRA_SI_CABEN_LOS_DOS:
	ld h,a			;550c   ; la distancia entre los dos
	ld a,(bc)			;550d
	add a,h			;550e
	ld h,a			;550f
	ld a,(de)			;5510
	add a,058h		;5511
	cp h			;5513
	jr z,SE_SALE_DE_LA_PANTALLA		;5514
	jr c,SE_SALE_DE_LA_PANTALLA		;5516
ARRASTRA_AL_DE_ATRAS:
	ld a,(de)			;5518
	push af			;5519
	exx			;551a
	xor a			;551b
	sbc hl,de		;551c   ; la diferencia
	ld a,l			;551e
	exx			;551f
	bit 7,a		;5520
	jr z,CALCULA_EL_ARRASTRE		;5522   ; en valor absoluto
	cpl			;5524
CALCULA_EL_ARRASTRE:
	ld l,a			;5525
	ld a,(bc)			;5526
	sub l			;5527   ; lo que se puede mover el de detras
	ld h,a			;5528
	ld a,(de)			;5529
	ld l,a			;552a
	ld a,h			;552b
	sub l			;552c
	ld b,a			;552d
	exx			;552e
	ld hl,0e141h		;552f   ; las columnas de los dos objetos
	ld de,0e151h		;5532
	exx			;5535
	ld hl,0e0ebh		;5536
	ld de,0e0b5h		;5539
	ld a,(de)			;553c   ; y quien va delante
	cp (hl)			;553d
	jr c,REPARTE_LO_QUE_CABE		;553e
	exx			;5540
	ex de,hl			;5541
	exx			;5542
	ex de,hl			;5543
REPARTE_LO_QUE_CABE:
	ld a,(de)			;5544
	add a,b			;5545   ; al de detras se le da lo que cabe
	cp 008h		;5546
	jr nc,REPARTE_LO_QUE_CABE_2		;5548
	ld a,008h		;554a
REPARTE_LO_QUE_CABE_2:
	ld (de),a			;554c   ; lo que cabe al de detras
	ld a,(0e0c8h)		;554d   ; y el resto se lo lleva el decorado
	sub b			;5550
	ld b,a			;5551
	exx			;5552
	ld a,(hl)			;5553   ; y lo que sobra al decorado
	exx			;5554
	add a,b			;5555
	exx			;5556
	ld (hl),a			;5557
	exx			;5558
	pop af			;5559
	exx			;555a
	ex de,hl			;555b
	add a,(hl)			;555c
	ld (hl),a			;555d
	jp LIMPIA_LOS_AVANCES		;555e
SE_SALE_DE_LA_PANTALLA:
	ld hl,0e0ebh		;5561   ; la posicion del jugador 2
	ld de,0e0b5h		;5564
	ld a,(de)			;5567   ; quien va delante
	cp (hl)			;5568
	jr z,EMPATE_A_POSICION		;5569   ; empatados: desempata la velocidad
	jr c,CLAVA_LA_SEPARACION		;556b
DESEMPATA:
	ex de,hl			;556d
CLAVA_LA_SEPARACION:
	ld a,(de)			;556e
	ld h,a			;556f
	ld a,058h		;5570
	sub h			;5572
	ld h,a			;5573
	ld a,(0e0c8h)		;5574   ; lo que sobra se lo come el decorado
	sub h			;5577
	ld b,a			;5578
	ld hl,0e141h		;5579   ; la columna del primer objeto
	add a,(hl)			;557c
	ld (hl),a			;557d
	ld hl,0e151h		;557e   ; y la del segundo
	ld a,b			;5581
	add a,(hl)			;5582
	ld (hl),a			;5583
	ld a,(0e0c7h)		;5584
	ld c,a			;5587
	ld a,b			;5588
	sub c			;5589
	ld b,a			;558a
	ld hl,0e0ebh		;558b
	ld de,0e0b5h		;558e
	ld a,(de)			;5591
	cp (hl)			;5592
	jr c,QUITA_LO_ARRASTRADO		;5593
	ex de,hl			;5595
QUITA_LO_ARRASTRADO:
	ld a,(hl)			;5596   ; al de delante se le quita lo arrastrado
	sub b			;5597
	ld (hl),a			;5598
	ld a,058h		;5599   ; y se clava en 0x58
	ld (de),a			;559b
	jr LIMPIA_LOS_AVANCES		;559c
EMPATE_A_POSICION:
	ld a,(0e0efh)		;559e   ; el avance del jugador 2
	ld b,a			;55a1
	ld a,(0e0b9h)		;55a2   ; contra el del 1
	cp b			;55a5
	jr nc,DESEMPATA		;55a6
	jr CLAVA_LA_SEPARACION		;55a8
EL_JUGADOR_2_VA_DELANTE:
	ld hl,0e0ebh		;55aa
	ld a,(0e0b5h)		;55ad   ; quien va delante de verdad
	cp (hl)			;55b0
	jr c,EL_JUGADOR_1_VA_DELANTE		;55b1
	ld a,(0e0b9h)		;55b3   ; el avance del jugador 2
	ld hl,0e151h		;55b6   ; al decorado
	add a,(hl)			;55b9
	ld (hl),a			;55ba
	ld a,(0e0ebh)		;55bb
	cp 009h		;55be   ; con el otro por debajo de 9
	jr nc,AJUSTA_LA_SEPARACION		;55c0
	ld a,(0e0efh)		;55c2   ; su avance tambien al decorado
	ld l,041h		;55c5
	add a,(hl)			;55c7
	ld (hl),a			;55c8
	jr LIMPIA_LOS_AVANCES		;55c9
AJUSTA_LA_SEPARACION:
	ld hl,0e0b9h		;55cb
	ld a,(0e0ebh)		;55ce   ; la separacion actual
	sub (hl)			;55d1
	ld b,a			;55d2
	ld a,(0e0efh)		;55d3   ; mas el avance del otro
	add a,b			;55d6
	cp 008h		;55d7   ; por debajo de 8 se recorta
	jr nc,SEPARACION_QUE_CABE		;55d9
	ld b,a			;55db
	ld a,008h		;55dc
	sub b			;55de
	ld b,a			;55df
	ld a,(0e0b9h)		;55e0
	sub b			;55e3
	ld hl,0e141h		;55e4
	add a,(hl)			;55e7
	ld (hl),a			;55e8
	ld a,008h		;55e9
	ld (0e0ebh),a		;55eb   ; y la separacion se clava en 8
LIMPIA_LOS_AVANCES:
	xor a			;55ee   ; los dos avances gastados
	ld (0e0b9h),a		;55ef
	ld (0e0efh),a		;55f2
	ret			;55f5
SEPARACION_QUE_CABE:
	ld hl,0e141h		;55f6
	ld a,(0e0b9h)		;55f9   ; el avance del jugador 1
	ld b,a			;55fc
	add a,(hl)			;55fd   ; al decorado
	ld (hl),a			;55fe
	ld a,(0e0ebh)		;55ff   ; la separacion
	sub b			;5602
	ld b,a			;5603
	ld a,(0e0efh)		;5604   ; mas el avance del jugador 2
	add a,b			;5607
	ld (0e0ebh),a		;5608
	jr LIMPIA_LOS_AVANCES		;560b
EL_JUGADOR_1_VA_DELANTE:
	ld a,(0e0efh)		;560d   ; el avance del jugador 2
	ld hl,0e141h		;5610   ; al decorado
	add a,(hl)			;5613
	ld (hl),a			;5614
	ld a,(0e0b5h)		;5615   ; con la separacion por debajo de 9
	cp 009h		;5618
	jr nc,AJUSTA_LA_SEPARACION_2		;561a
	ld a,(0e0b9h)		;561c   ; el avance del jugador 1
	ld l,051h		;561f
	add a,(hl)			;5621
	ld (hl),a			;5622
	jr LIMPIA_LOS_AVANCES		;5623
AJUSTA_LA_SEPARACION_2:
	ld hl,0e0efh		;5625
	ld a,(0e0b5h)		;5628   ; la separacion menos el avance del 2
	sub (hl)			;562b
	ld b,a			;562c
	ld a,(0e0b9h)		;562d   ; mas el avance del 1
	add a,b			;5630
	cp 008h		;5631   ; por encima de 8 cabe entera
	jr nc,SEPARACION_QUE_CABE_2		;5633
	ld b,a			;5635
	ld a,008h		;5636   ; lo que le falta para 8
	sub b			;5638
	ld b,a			;5639
	ld a,(0e0efh)		;563a   ; se le quita al avance del 2
	sub b			;563d
	ld hl,0e151h		;563e
	add a,(hl)			;5641
	ld (hl),a			;5642
	ld a,008h		;5643   ; y la separacion se clava en 8
	ld (0e0b5h),a		;5645
	jr LIMPIA_LOS_AVANCES		;5648
SEPARACION_QUE_CABE_2:
	ld hl,0e151h		;564a
	ld a,(0e0efh)		;564d   ; el avance del jugador 2
	ld b,a			;5650
	add a,(hl)			;5651   ; al segundo decorado
	ld (hl),a			;5652
	ld a,(0e0b5h)		;5653   ; la separacion
	sub b			;5656
	ld b,a			;5657
	ld a,(0e0b9h)		;5658   ; mas el avance del 1
	add a,b			;565b
	ld (0e0b5h),a		;565c
	jr LIMPIA_LOS_AVANCES		;565f
AVANZA_EL_ATLETA:
	push hl			;5661
	push bc			;5662
	push hl			;5663
	ld bc,00004h		;5664   ; cuatro bytes mas alla esta su avance
	add hl,bc			;5667
	ld a,(hl)			;5668   ; se le suma a la columna
	pop hl			;5669
	add a,(hl)			;566a
	ld (hl),a			;566b
	cp 059h		;566c
	jr c,SIN_LLEGADA		;566e
	inc hl			;5670
	inc hl			;5671
	set 6,(hl)		;5672   ; bit 6: ya esta en el tramo final
	dec hl			;5674
	dec hl			;5675
	cp 0d8h		;5676   ; y a partir de 0xD8 se planta
	jr c,SIN_LLEGADA		;5678
	ld (hl),0d8h		;567a
	inc hl			;567c
	inc hl			;567d
	bit 0,(hl)		;567e   ; bit 0: ya ha llegado
	jr nz,SIN_LLEGADA		;5680
	set 0,(hl)		;5682
	dec hl			;5684
	ld (hl),000h		;5685
	ld a,0b6h		;5687   ; 0xE0B6 es el jugador 1
	cp l			;5689
	ld a,001h		;568a
	jr z,PINTA_LA_LLEGADA		;568c
	xor a			;568e
PINTA_LA_LLEGADA:
	call PINTA_AL_ATLETA		;568f   ; y a pintarlo
SIN_LLEGADA:
	pop bc			;5692
	pop hl			;5693
	ret			;5694
EL_RELOJ_DE_LA_PRUEBA:
	ld hl,0e0b7h		;5695
	bit 6,(hl)		;5698   ; bit 6 de 0xE0B7: el jugador 1 ya ha llegado
	jr nz,EL_RELOJ_DEL_JUGADOR_2		;569a
	ld hl,0e0abh		;569c   ; su reloj
	call SUMA_AL_RELOJ		;569f
EL_RELOJ_DEL_JUGADOR_2:
	ld hl,0e0edh		;56a2
	bit 6,(hl)		;56a5   ; bit 6 de 0xE0ED
	jr nz,MIRA_EL_RELOJ_DEL_JUGADOR_1		;56a7
	ld hl,0e0a7h		;56a9   ; el reloj del jugador 2
	call SUMA_AL_RELOJ		;56ac
	ld hl,0e0b7h		;56af
	bit 6,(hl)		;56b2   ; si el 1 ya paro
	jr z,SUMA_AL_RELOJ_COMUN		;56b4
	ld a,(0e021h)		;56b6   ; y sigue en juego
	rrca			;56b9
	jr nc,PASA_EL_CUADRO		;56ba
SUMA_AL_RELOJ_COMUN:
	ld hl,0e0a3h		;56bc   ; el reloj comun
	call SUMA_AL_RELOJ		;56bf
	jr PASA_EL_CUADRO		;56c2
MIRA_EL_RELOJ_DEL_JUGADOR_1:
	ld a,(0e021h)		;56c4
	bit 1,a		;56c7   ; el jugador 2 sigue en juego
	jr z,PASA_EL_CUADRO		;56c9
	ld a,(0e0b7h)		;56cb   ; bit 6 de 0xE0B7
	bit 6,a		;56ce
	jr z,SUMA_AL_RELOJ_COMUN		;56d0
PASA_EL_CUADRO:
	ld hl,0e0ach		;56d2
	inc (hl)			;56d5   ; el contador del reloj
	ret			;56d6
SUMA_AL_RELOJ:
	ld a,(0e0ach)		;56d7   ; el contador de cuadros del reloj
	rrca			;56da
	ld a,067h		;56db   ; un cuadro suma 0x0167 y el siguiente 0x0166
	jr c,SUMA_LAS_CENTESIMAS		;56dd
	ld a,066h		;56df   ; o sea 1,67 y 1,66 centesimas de segundo, media 1,665: UN SESENTAVO DE
SUMA_LAS_CENTESIMAS:
	add a,(hl)			;56e1   ; SEGUNDO. El reloj esta calculado para una maquina de 60 Hz
	daa			;56e2
	ld (hl),a			;56e3   ; suma en BCD, centesimas
	dec hl			;56e4
	ld a,001h		;56e5
	adc a,(hl)			;56e7
	daa			;56e8
	ld (hl),a			;56e9
	dec hl			;56ea
	ld a,000h		;56eb
	adc a,(hl)			;56ed
	daa			;56ee
	ld (hl),a			;56ef
	jr nc,MIRA_LA_PRUEBA_EN_CURSO		;56f0
MIRA_EL_LIMITE_DEL_RELOJ:
	ld a,(0e02eh)		;56f2   ; en las 110 vallas
	bit 6,a		;56f5
	jr z,MIRA_LA_PRUEBA_EN_CURSO		;56f7
MIRA_LA_PRUEBA_EN_CURSO:
	ld a,(0e016h)		;56f9
	dec a			;56fc
	jr nz,LIMITE_DE_SESENTA_SEGUNDOS		;56fd
	ld a,(hl)			;56ff
	cp 040h		;5700   ; el limite son 40 segundos
	ret nz			;5702
	jr SE_ACABO_EL_TIEMPO		;5703
LIMITE_DE_SESENTA_SEGUNDOS:
	ld a,(hl)			;5705
	cp 060h		;5706   ; y en las demas, 60
	ret nz			;5708
	ld (hl),000h		;5709
	dec hl			;570b
	inc (hl)			;570c
	ld a,005h		;570d
	cp (hl)			;570f
	ret nz			;5710
	inc hl			;5711
SE_ACABO_EL_TIEMPO:
	inc hl			;5712
	ld (hl),000h		;5713   ; el reloj se planta
	ld l,02eh		;5715
	set 2,(hl)		;5717   ; bit 2 de 0xE02E: se acabo el tiempo
	ret			;5719

; ----------------------------------------------------------------------
; ==========  EL ATLETA DEL JUGADOR 1  ==========
; ----------------------------------------------------------------------
MUEVE_AL_ATLETA_1:
	ld hl,0e0cah		;571a
	bit 0,(hl)		;571d   ; bit 0 de 0xE0CA: ya esta puesto en su sitio
	jr nz,MIRA_EL_ESTADO_DEL_ATLETA_1		;571f
	set 0,(hl)		;5721   ; se marca para no repetirlo
	ld hl,05096h		;5723   ; la ficha de sprite del jugador 1
	ld (0e0b4h),hl		;5726
	ld a,00ch		;5729
	ld (0e0b6h),a		;572b
	call PINTA_AL_ATLETA_1		;572e   ; y se pinta
	ld hl,057fch		;5731   ; el estado inicial del atleta
	ld de,0e0bch		;5734   ; a su hueco de trabajo
	ld bc,00007h		;5737
	ldir		;573a
	ld a,096h		;573c   ; caracter 0x96 en la casilla del suelo
	ld (0e0c4h),a		;573e
	ld (0e0fah),a		;5741
	ld hl,057fch		;5744   ; el mismo estado inicial
	ld de,0e0f2h		;5747   ; al del segundo atleta
	ld bc,00007h		;574a
	ldir		;574d
BORRA_LOS_HUECOS_DE_CIFRA:
	ld de,05a50h		;574f   ; los cuatro sitios de la VRAM donde van las cifras
	ld hl,06197h		;5752   ; el glifo del cero
	ld b,008h		;5755   ; sus ocho bytes
	call SUBE_BYTES_CON_DIRECCION		;5757
	ld de,05a90h		;575a   ; segundo hueco
	ld hl,06197h		;575d
	ld b,008h		;5760
	call SUBE_BYTES_CON_DIRECCION		;5762
	ld de,05ad0h		;5765   ; tercero
	ld hl,06197h		;5768
	ld b,008h		;576b
	call SUBE_BYTES_CON_DIRECCION		;576d
	ld de,05b10h		;5770   ; y cuarto
	ld hl,06197h		;5773
	ld b,008h		;5776
	jp SUBE_BYTES_CON_DIRECCION		;5778
MIRA_EL_ESTADO_DEL_ATLETA_1:
	ld l,02dh		;577b
	bit 4,(hl)		;577d   ; bit 4 de 0xE02D: el jugador 2 ya no cuenta
	ret nz			;577f
	ld hl,0e02eh		;5780
	bit 2,(hl)		;5783   ; bit 2 de 0xE02E: se acabo el tiempo
	jp nz,ATLETA_1_FUERA_DE_TIEMPO		;5785
	ld a,(0e028h)		;5788   ; bit 3 de 0xE028: el atleta esta parando
	bit 3,a		;578b
	jp nz,MIRA_QUIEN_ARRANCA		;578d
	bit 1,a		;5790   ; bit 1: aun no ha arrancado
	jp z,SALIDA_DEL_ATLETA_1		;5792
	ld a,(0e0b7h)		;5795   ; bit 0 de 0xE0B7: ya ha llegado
	rrca			;5798
	ld a,(0e02ah)		;5799   ; el resultado del intento
	ld hl,0e0bbh		;579c
	jp c,MIRA_SI_HAN_LLEGADO_LOS_DOS		;579f   ; entonces toca la animacion de llegada
	ld a,(0e00bh)		;57a2
	ld (0e0c5h),a		;57a5
	ld a,(0e016h)		;57a8
	dec a			;57ab
	jr nz,CORRE_EL_ATLETA_1		;57ac
	ld a,(0e021h)		;57ae
	rrca			;57b1
	jr nc,MUEVE_LA_VALLA_DEL_1		;57b2
	ld a,001h		;57b4
	ld (0e0c5h),a		;57b6
	ld hl,0e15bh		;57b9   ; y si no, la de correr
	ld a,(hl)			;57bc
	cp 001h		;57bd
	jr z,MUEVE_LA_VALLA_DEL_1		;57bf
	inc hl			;57c1
	ld b,(hl)			;57c2
	ld a,(0e0b5h)		;57c3
	add a,010h		;57c6
	cp b			;57c8
	jr c,MUEVE_LA_VALLA_DEL_1		;57c9
	sub 010h		;57cb
	cp b			;57cd
	jr nc,MUEVE_LA_VALLA_DEL_1		;57ce
	ld a,002h		;57d0
	ld (0e0c5h),a		;57d2
MUEVE_LA_VALLA_DEL_1:
	ld hl,0e0bah		;57d5   ; la velocidad del jugador 1
	ld de,0e028h		;57d8   ; su estado
	ld ix,0e0d0h		;57db   ; y la ficha de su valla
	call MIRA_EL_SALTO_DE_LA_VALLA		;57df
	xor a			;57e2
	ld (0e0c5h),a		;57e3   ; la pulsacion queda gastada
	ret			;57e6
CORRE_EL_ATLETA_1:
	ld l,0aeh		;57e7
	ld de,0e0b1h		;57e9
	jp CORRE_EL_ATLETA		;57ec
ATLETA_1_FUERA_DE_TIEMPO:
	ld a,(0e02ah)		;57ef
	or a			;57f2   ; sin resultado no hay nada que ensenar
	jp z,SE_ACABO_LA_CARRERA		;57f3
	ld hl,0e0bbh		;57f6
	jp ANIMA_LA_LLEGADA		;57f9

; ----------------------------------------------------------------------
; DATOS estado_inicial_del_atleta: Siete bytes que 0x5731 copia a 0xE0BC y a
;   0xE0F2 para dejar al atleta en su sitio al empezar.
;   0x57fc..0x5803  (7 bytes)
DATA_estado_inicial_del_atleta:
	defb 0cfh,000h,010h,000h,0cfh,000h,020h	; 57fc

; ======================================================================
; CODIGO 0x5803..0x5e35  (1586 bytes)
; ======================================================================


MUEVE_AL_ATLETA_2:
	ld hl,0e0cbh		;5803
	bit 0,(hl)		;5806   ; bit 0 de 0xE0CB: ya esta puesto
	jr nz,MIRA_EL_ESTADO_DEL_ATLETA_2		;5808
	set 0,(hl)		;580a
	ld hl,05066h		;580c   ; la ficha de sprite del jugador 2
	ld (0e0eah),hl		;580f
	ld a,00ch		;5812
	ld (0e0ech),a		;5814
	jp PINTA_AL_ATLETA_2		;5817
MIRA_EL_ESTADO_DEL_ATLETA_2:
	ld l,02ch		;581a
	bit 4,(hl)		;581c   ; bit 4 de 0xE02C
	ret nz			;581e
	ld hl,0e02eh		;581f
	bit 2,(hl)		;5822   ; bit 2 de 0xE02E
	jr nz,ATLETA_2_FUERA_DE_TIEMPO		;5824
	ld a,(0e029h)		;5826   ; bit 3 de 0xE029
	bit 3,a		;5829
	jp nz,ATLETA_2_PARANDO		;582b
	bit 1,a		;582e   ; bit 1
	jp z,SALIDA_DEL_ATLETA_2		;5830
	ld a,(0e0edh)		;5833   ; bit 0 de 0xE0ED
	rrca			;5836
	ld a,(0e02bh)		;5837
	ld hl,0e0f1h		;583a
	jp c,MIRA_SI_HAN_LLEGADO_LOS_DOS		;583d
	ld a,(0e00fh)		;5840
	ld (0e0c5h),a		;5843
	ld a,(0e016h)		;5846
	dec a			;5849
	jr nz,CORRE_EL_ATLETA_2		;584a
	ld a,(0e021h)		;584c
	bit 1,a		;584f
	jr z,MUEVE_LA_VALLA_DEL_2		;5851
	ld a,001h		;5853
	ld (0e0c5h),a		;5855
	ld hl,0e14bh		;5858
	ld a,(hl)			;585b
	dec a			;585c
	jr z,MUEVE_LA_VALLA_DEL_2		;585d
	inc hl			;585f
	ld b,(hl)			;5860
	ld a,(0e0ebh)		;5861
	add a,010h		;5864
	cp b			;5866
	jr c,MUEVE_LA_VALLA_DEL_2		;5867
	sub 010h		;5869
	cp b			;586b
	jr nc,MUEVE_LA_VALLA_DEL_2		;586c
	ld a,002h		;586e
	ld (0e0c5h),a		;5870
MUEVE_LA_VALLA_DEL_2:
	ld hl,0e0f0h		;5873   ; la velocidad del jugador 2
	ld de,0e029h		;5876   ; su estado
	ld ix,0e0d1h		;5879   ; y la ficha de su valla
	call MIRA_EL_SALTO_DE_LA_VALLA		;587d
	xor a			;5880
	ld (0e0c5h),a		;5881   ; la pulsacion queda gastada
	ret			;5884
CORRE_EL_ATLETA_2:
	ld l,0e4h		;5885
	ld de,0e0e7h		;5887
	jp CORRE_EL_ATLETA		;588a
ATLETA_2_FUERA_DE_TIEMPO:
	ld a,(0e02bh)		;588d
	or a			;5890
	jp z,SE_ACABO_LA_CARRERA		;5891
	ld hl,0e0f1h		;5894
	jp ANIMA_LA_LLEGADA		;5897
SALIDA_DEL_ATLETA_1:
	ld a,(0e0a1h)		;589a   ; el contador de la salida
	cp 005h		;589d   ; hasta 5 no pasa nada
	jr nc,ATLETA_1_EN_LA_SALIDA		;589f
	cp 003h		;58a1   ; y por debajo de 3, tampoco
	ret c			;58a3
	ld de,07981h		;58a4   ; la casilla del juez de salida
	ld bc,001efh		;58a7   ; caracter 0xEF: el pistoletazo
	call REPITE_BYTE_CON_CANDADO		;58aa
	call ES_PRUEBA_IMPAR		;58ad
	ret nc			;58b0
	ld a,004h		;58b1
	ld (0e0b6h),a		;58b3
	jp PINTA_AL_ATLETA_1		;58b6
ATLETA_1_EN_LA_SALIDA:
	ld hl,0e02ch		;58b9
	bit 4,(hl)		;58bc   ; bit 4 de 0xE02C: ya salio
	jr nz,ATLETA_1_YA_SALIO		;58be
	cp 008h		;58c0   ; con 8 arranca la carrera
	jr nc,MIRA_LA_SALIDA_DEL_2		;58c2
	call ES_PRUEBA_IMPAR		;58c4
	ld a,00ch		;58c7
	jr nc,PONE_POSTURA_AL_ATLETA_1		;58c9
	ld a,005h		;58cb
PONE_POSTURA_AL_ATLETA_1:
	ld (0e0b6h),a		;58cd
	call PINTA_AL_ATLETA_1		;58d0
	ld de,07982h		;58d3   ; la casilla del juez
	ld bc,001efh		;58d6   ; caracter 0xEF
	call REPITE_BYTE_CON_CANDADO		;58d9
	ld a,(0e021h)		;58dc   ; el jugador 1 no juega esta prueba
	rrca			;58df
	ret c			;58e0
	ld a,(0e0ceh)		;58e1   ; y hasta que no pulse, nada
	rrca			;58e4
	ret nc			;58e5
	ld a,020h		;58e6   ; 0x20 cuadros de aguante
	ld (0e0bbh),a		;58e8
	ld a,006h		;58eb
	ld hl,0e0b6h		;58ed
	ld (hl),a			;58f0
	dec hl			;58f1
	ld a,00ch		;58f2
	add a,(hl)			;58f4
	ld (hl),a			;58f5
	call PINTA_AL_ATLETA_1		;58f6
	ld hl,0e02eh		;58f9
	res 6,(hl)		;58fc   ; bit 6 de 0xE02E
	ld hl,0e02ch		;58fe   ; bit 4 de 0xE02C: ya ha salido
	set 4,(hl)		;5901
	inc hl			;5903
	bit 4,(hl)		;5904   ; si el otro tambien ha salido
	ret nz			;5906
	ld a,04bh		;5907
	jp PIDE_UN_SONIDO		;5909
ATLETA_1_YA_SALIO:
	ld a,(0e0bbh)		;590c   ; el aguante que le queda
	or a			;590f
	jr z,SIN_AGUANTE		;5910
	dec a			;5912
	ld (0e0bbh),a		;5913   ; se le va gastando
	cp 00ah		;5916   ; al llegar a 10
	ret nz			;5918
	ld a,00ch		;5919
	ld (0e0b6h),a		;591b
	jp PINTA_AL_ATLETA_1		;591e
SIN_AGUANTE:
	set 0,(hl)		;5921   ; bit 0 de 0xE02D
	ret			;5923
MIRA_LA_SALIDA_DEL_2:
	ld l,028h		;5924
	bit 3,(hl)		;5926   ; bit 3 de 0xE028
	jr nz,MIRA_QUIEN_ARRANCA		;5928
	set 3,(hl)		;592a   ; se marca
	inc hl			;592c
	set 3,(hl)		;592d   ; y en 0xE029 tambien
	set 7,(hl)		;592f   ; bit 7: A PARTIR DE AQUI EL BOTON LO PULSA LA MAQUINA, al azar, desde
	ld l,0a0h		;5931
	xor a			;5933   ; limpia el estado del atleta
	ld b,00ch		;5934
LIMPIA_UN_BYTE:
	ld (hl),a			;5936
	inc hl			;5937
	djnz LIMPIA_UN_BYTE		;5938
	ld de,07983h		;593a   ; la casilla del juez
	ld bc,001efh		;593d   ; caracter 0xEF
	call REPITE_BYTE_CON_CANDADO		;5940
	ld a,049h		;5943
	call PIDE_UN_SONIDO		;5945
	ld a,043h		;5948   ; y 0x43 detras
	jp PIDE_UN_SONIDO		;594a
MIRA_QUIEN_ARRANCA:
	ld a,(0e021h)		;594d
	rrca			;5950   ; en las pruebas impares
	jr c,ARRANCA_EL_ATLETA_1		;5951
	ld a,(0e0ceh)		;5953   ; la pulsacion apuntada
	rrca			;5956
	jr nc,PINTA_AL_ATLETA_1		;5957
ARRANCA_EL_ATLETA_1:
	ld hl,0e028h		;5959
	set 1,(hl)		;595c   ; bit 1 de 0xE028: ya corre
	res 3,(hl)		;595e   ; y se quita la de parando
	ld l,02eh		;5960
	set 6,(hl)		;5962   ; bit 6 de 0xE02E: la carrera esta en marcha
	ld a,004h		;5964   ; velocidad inicial 4
	ld (0e0b9h),a		;5966
	ld a,006h		;5969
	ld (0e0b6h),a		;596b
PINTA_AL_ATLETA_1:
	ld a,001h		;596e   ; el 1 es el jugador 1
	jp PINTA_AL_ATLETA		;5970
SALIDA_DEL_ATLETA_2:
	ld a,(0e0a1h)		;5973   ; el contador de la salida
	cp 005h		;5976
	jr nc,ATLETA_2_EN_LA_SALIDA		;5978
	cp 003h		;597a
	ret c			;597c
	call ES_PRUEBA_IMPAR		;597d
	ret nc			;5980
	ld a,004h		;5981
	ld (0e0ech),a		;5983
	jp PINTA_AL_ATLETA_2		;5986
ATLETA_2_EN_LA_SALIDA:
	ld hl,0e02dh		;5989
	bit 4,(hl)		;598c   ; bit 4 de 0xE02D
	jr nz,ATLETA_2_YA_SALIO		;598e
	cp 008h		;5990
	jr nc,MIRA_LA_SALIDA_DEL_1		;5992
	call ES_PRUEBA_IMPAR		;5994
	ld a,00ch		;5997
	jr nc,PONE_POSTURA_AL_ATLETA_2		;5999
	ld a,005h		;599b
PONE_POSTURA_AL_ATLETA_2:
	ld (0e0ech),a		;599d
	call PINTA_AL_ATLETA_2		;59a0
	ld a,(0e021h)		;59a3   ; el jugador 2 no juega esta prueba
	bit 1,a		;59a6
	ret nz			;59a8
	ld a,(0e0cfh)		;59a9   ; su pulsacion
	rrca			;59ac
	ret nc			;59ad
	ld a,020h		;59ae   ; 0x20 cuadros de aguante
	ld (0e0f1h),a		;59b0
	ld a,006h		;59b3
	ld hl,0e0ech		;59b5
	ld (hl),a			;59b8
	dec hl			;59b9
	ld a,008h		;59ba
	add a,(hl)			;59bc
	ld (hl),a			;59bd
	call PINTA_AL_ATLETA_2		;59be
	ld hl,0e02eh		;59c1
	res 6,(hl)		;59c4   ; bit 6 de 0xE02E
	ld hl,0e02dh		;59c6
	set 4,(hl)		;59c9   ; bit 4 de 0xE02D
	dec hl			;59cb
	bit 4,(hl)		;59cc
	ret nz			;59ce
	ld a,04bh		;59cf
	jp PIDE_UN_SONIDO		;59d1
ATLETA_2_YA_SALIO:
	ld a,(0e0f1h)		;59d4
	or a			;59d7
	jr z,SIN_AGUANTE_2		;59d8
	dec a			;59da   ; gasta el aguante
	ld (0e0f1h),a		;59db
	cp 00ah		;59de
	ret nz			;59e0
	ld a,00ch		;59e1
	ld (0e0ech),a		;59e3
	jp PINTA_AL_ATLETA_2		;59e6
SIN_AGUANTE_2:
	set 0,(hl)		;59e9
	ret			;59eb
MIRA_LA_SALIDA_DEL_1:
	ld l,029h		;59ec
	bit 3,(hl)		;59ee   ; bit 3 de 0xE029
	jr nz,ATLETA_2_PARANDO		;59f0
	set 3,(hl)		;59f2
	ret			;59f4
ATLETA_2_PARANDO:
	ld a,(0e021h)		;59f5
	bit 1,a		;59f8
	jr nz,ARRANCA_EL_ATLETA_2		;59fa
	ld a,(0e0cfh)		;59fc   ; su pulsacion
	rrca			;59ff
ARRANCA_O_PINTA:
	jr nc,PINTA_AL_ATLETA_2		;5a00
ARRANCA_EL_ATLETA_2:
	ld hl,0e029h		;5a02   ; bit 1 de 0xE029
	set 1,(hl)		;5a05
	res 3,(hl)		;5a07
	ld l,02eh		;5a09
	set 6,(hl)		;5a0b   ; bit 6 de 0xE02E
	ld a,004h		;5a0d   ; velocidad inicial 4
	ld (0e0efh),a		;5a0f
	ld a,006h		;5a12
	ld (0e0ech),a		;5a14
PINTA_AL_ATLETA_2:
	xor a			;5a17   ; el 0 es el jugador 2
	jp PINTA_AL_ATLETA		;5a18

; ----------------------------------------------------------------------
; ==========  EL SALTO DE LA VALLA  ==========
; Lo unico que las 110 vallas anaden a la carrera: mientras el atleta
; corre, el bit 1 de 0xE0C5 pide saltar. El salto dura diez cuadros
; (0x5A34) y mientras dura la postura es la 13; al final, la 6. Si al
; acabar el atleta esta a menos de ocho columnas de una valla, se le
; pone el bit 4 de 0xE028 o 0xE029, que es lo que le hace caer.
; ----------------------------------------------------------------------
MIRA_EL_SALTO_DE_LA_VALLA:
	ld a,(de)			;5a1b
	bit 4,a		;5a1c   ; bit 4: el atleta viene de derribar una valla
	jp nz,EL_ATLETA_HA_TROPEZADO		;5a1e
	xor a			;5a21
	cp (hl)			;5a22   ; con la cuenta de salto a cero no esta saltando
	jr nz,GASTA_EL_SALTO		;5a23
	ld a,(0e0c5h)		;5a25
	bit 1,a		;5a28   ; bit 1 de 0xE0C5: han pedido saltar
	jp z,APAGA_EL_SALTO		;5a2a
	bit 0,(ix+000h)		;5a2d   ; bit 0 de la ficha: el actor esta encendido
	jp nz,CORRE_SIN_SALTAR		;5a31
	ld (hl),00ah		;5a34   ; diez cuadros de salto
	push hl			;5a36
	set 0,(ix+000h)		;5a37   ; y el actor se enciende
	ld hl,0e0adh		;5a3b   ; la marca del jugador 1
	ld a,028h		;5a3e
	cp e			;5a40   ; o la del 2, segun de quien sea la ficha
	jr z,APUNTA_EL_SALTO		;5a41
	ld l,0e3h		;5a43
APUNTA_EL_SALTO:
	ld a,001h		;5a45
	ld (0e0c5h),a		;5a47   ; hay marca nueva que pintar
	call GASTA_Y_APUNTA		;5a4a   ; y se gasta velocidad por saltar
	pop hl			;5a4d
GASTA_EL_SALTO:
	dec (hl)			;5a4e   ; la cuenta de salto
	ld b,00dh		;5a4f   ; postura 13 mientras dure
	ld a,001h		;5a51
	cp (hl)			;5a53
	jr c,PINTA_EL_SALTO		;5a54
	ld b,006h		;5a56   ; y la 6 en el ultimo cuadro
PINTA_EL_SALTO:
	call PONE_LA_POSTURA_Y_PINTA		;5a58
MIRA_SI_DERRIBA_LA_VALLA:
	dec hl			;5a5b
	ld a,008h		;5a5c   ; ocho columnas de margen
	add a,(hl)			;5a5e
	ld b,a			;5a5f
	ld a,0b5h		;5a60   ; 0xE0B5 es el atleta del jugador 1
	cp l			;5a62
	ex de,hl			;5a63
	ld hl,0e15bh		;5a64   ; la valla que le toca al jugador 1
	ld a,(0e0cch)		;5a67
	jr z,MIRA_LA_VALLA		;5a6a
	ld l,04bh		;5a6c   ; o la del jugador 2
	ld a,(0e0cdh)		;5a6e
MIRA_LA_VALLA:
	or a			;5a71
	ret nz			;5a72   ; sin pulsacion apuntada no se mira
	ld a,(hl)			;5a73
	cp 000h		;5a74   ; con la valla a cero no hay valla
	ret z			;5a76
	cp 001h		;5a77   ; con la valla a uno, ya esta derribada
	jp z,LA_VALLA_YA_ESTA_DERRIBADA		;5a79
	inc hl			;5a7c
	ld a,(hl)			;5a7d
	cp b			;5a7e   ; la columna de la valla contra la del atleta
	ret nc			;5a7f
MARGEN_POR_DELANTE:
	add a,008h		;5a80   ; y ocho mas de margen por delante
	cp b			;5a82
	ret c			;5a83
	ex de,hl			;5a84
	inc hl			;5a85
	ld a,00dh		;5a86   ; con la postura 13 el atleta va por encima
	cp (hl)			;5a88
	ret z			;5a89
	ld bc,0fff9h		;5a8a
	add hl,bc			;5a8d
	ld (hl),02ch		;5a8e   ; la valla se pone en 0x012C
	inc hl			;5a90
	ld (hl),001h		;5a91
	ld bc,0000ah		;5a93
	add hl,bc			;5a96
	ld (hl),015h		;5a97   ; y el sprite en la fila 0x15
	ld a,0bah		;5a99   ; 0xE0BA es el jugador 1
	cp l			;5a9b
	ld hl,0e028h		;5a9c
	jr z,DERRIBA_LA_VALLA		;5a9f
	inc hl			;5aa1
DERRIBA_LA_VALLA:
	set 4,(hl)		;5aa2   ; bit 4: el atleta ha derribado la valla
	ret			;5aa4
EL_ATLETA_HA_TROPEZADO:
	xor a			;5aa5
	cp (hl)			;5aa6   ; con la cuenta a cero se levanta
	jr z,EL_ATLETA_SE_LEVANTA		;5aa7
	dec (hl)			;5aa9   ; la cuenta del tropiezo
	ld a,013h		;5aaa   ; por encima de 0x13 la postura es la 13
	ld b,00dh		;5aac
	cp (hl)			;5aae
	jr c,PONE_LA_POSTURA_Y_PINTA		;5aaf
	ld a,008h		;5ab1   ; y por encima de 8, tambien
	cp (hl)			;5ab3
	jr c,PONE_LA_POSTURA_Y_PINTA		;5ab4
	ld bc,0fff3h		;5ab6   ; trece bytes atras
	add hl,bc			;5ab9
	xor a			;5aba
	ld b,004h		;5abb   ; cuatro bytes de velocidad
LIMPIA_LA_VELOCIDAD:
	ld (hl),a			;5abd
	inc hl			;5abe
	djnz LIMPIA_LA_VELOCIDAD		;5abf
	ld bc,00009h		;5ac1
	add hl,bc			;5ac4
	ld b,00eh		;5ac5   ; y la postura queda en la 14
PONE_LA_POSTURA_Y_PINTA:
	dec hl			;5ac7
	dec hl			;5ac8
	dec hl			;5ac9
	dec hl			;5aca
	ld (hl),b			;5acb   ; la postura queda cuatro bytes antes
	ld a,0b6h		;5acc   ; 0xE0B6 es el atleta del jugador 1
	cp l			;5ace
	ld a,001h		;5acf
	jr z,PINTA_LA_POSTURA		;5ad1
	xor a			;5ad3
PINTA_LA_POSTURA:
	jp PINTA_AL_ATLETA		;5ad4
EL_ATLETA_SE_LEVANTA:
	ld a,(0e0c5h)		;5ad7   ; sin pulsacion no se levanta
	rrca			;5ada
	ret nc			;5adb
	push hl			;5adc
	ld bc,0fff4h		;5add   ; doce bytes atras
	add hl,bc			;5ae0
	ld (hl),003h		;5ae1   ; velocidad 0x032C
	inc hl			;5ae3
	ld (hl),02ch		;5ae4
	inc hl			;5ae6
	ld (hl),001h		;5ae7
	ex de,hl			;5ae9
	res 4,(hl)		;5aea   ; baja el bit de tropiezo
	pop hl			;5aec
	push hl			;5aed
	ld a,0bah		;5aee
	cp l			;5af0
	ld hl,0e0cch		;5af1   ; la pulsacion del jugador 1
	jr z,CUENTA_DE_LEVANTARSE		;5af4
	inc hl			;5af6
CUENTA_DE_LEVANTARSE:
	ld a,014h		;5af7   ; 0x14 cuadros de levantarse
	ld (hl),a			;5af9
	pop hl			;5afa
	ld b,006h		;5afb   ; y postura 6
	jr PONE_LA_POSTURA_Y_PINTA		;5afd
APAGA_EL_SALTO:
	res 0,(ix+000h)		;5aff   ; el actor se apaga
CORRE_SIN_SALTAR:
	ld a,0bah		;5b03   ; 0xE0BA es el jugador 1
	cp l			;5b05
	jr nz,CORRE_SIN_SALTAR_EL_2		;5b06
	push hl			;5b08
	push de			;5b09
	call CORRE_EL_ATLETA_1		;5b0a   ; mueve al atleta del jugador 1
	ld a,(0e0cch)		;5b0d   ; y le gasta una pulsacion
	or a			;5b10
	jr z,VUELVE_DEL_ATLETA_1		;5b11
	dec a			;5b13
	ld (0e0cch),a		;5b14
VUELVE_DEL_ATLETA_1:
	pop de			;5b17
	pop hl			;5b18
	jr VUELVE_A_MIRAR_LA_VALLA		;5b19
CORRE_SIN_SALTAR_EL_2:
	push hl			;5b1b
	push de			;5b1c
	call CORRE_EL_ATLETA_2		;5b1d   ; mueve al atleta del jugador 2
	ld a,(0e0cdh)		;5b20   ; y le gasta la suya
	or a			;5b23
	jr z,VUELVE_DEL_ATLETA_2		;5b24
	dec a			;5b26
	ld (0e0cdh),a		;5b27
VUELVE_DEL_ATLETA_2:
	pop de			;5b2a
	pop hl			;5b2b
VUELVE_A_MIRAR_LA_VALLA:
	dec hl			;5b2c
	dec hl			;5b2d
	dec hl			;5b2e
	dec hl			;5b2f
	jp MIRA_SI_DERRIBA_LA_VALLA		;5b30
LA_VALLA_YA_ESTA_DERRIBADA:
	inc hl			;5b33
	ld a,(hl)			;5b34   ; la columna de la valla caida
	cp 062h		;5b35   ; pasada la columna 0x62 ya no estorba
	ret nc			;5b37
	ld a,05ch		;5b38
	cp l			;5b3a   ; 0xE05C es el jugador 1
	ld hl,0e028h		;5b3b
	jr z,MARCA_LA_VALLA_PASADA		;5b3e
	inc hl			;5b40
MARCA_LA_VALLA_PASADA:
	set 2,(hl)		;5b41   ; bit 2: el atleta ha pasado la valla
	ret			;5b43
MIRA_SI_HAN_LLEGADO_LOS_DOS:
	or a			;5b44
	jr nz,ANIMA_LA_LLEGADA		;5b45   ; con resultado, va por otro lado
	ld a,(0e0b7h)		;5b47   ; bit 0 de 0xE0B7
	rrca			;5b4a
	ret nc			;5b4b
	ld a,(0e0edh)		;5b4c   ; y bit 0 de 0xE0ED
	rrca			;5b4f
	ret nc			;5b50
SE_ACABO_LA_CARRERA:
	ld a,080h		;5b51
	ld (0e0bbh),a		;5b53   ; cuenta de 0x80 cuadros para los dos
	ld (0e0f1h),a		;5b56
	ld hl,0e02eh		;5b59
	set 0,(hl)		;5b5c   ; bit 0 de 0xE02E: intento acabado
	ld a,0a2h		;5b5e
	call PIDE_UN_SONIDO		;5b60
	jp MUEVE_EL_SONIDO		;5b63   ; y para la musica
ANIMA_LA_LLEGADA:
	ld c,a			;5b66
	dec (hl)			;5b67   ; la cuenta de la animacion
	jr z,SE_ACABO_LA_ANIMACION		;5b68
	bit 4,(hl)		;5b6a   ; bit 4: va hacia atras
	jr nz,UNA_POSTURA_ATRAS		;5b6c
	ld a,001h		;5b6e
	jr CAMBIA_DE_POSTURA		;5b70
UNA_POSTURA_ATRAS:
	ld a,0ffh		;5b72   ; o una menos
CAMBIA_DE_POSTURA:
	add a,c			;5b74   ; la postura que toca
	ld b,a			;5b75
	dec hl			;5b76
	call ES_PRUEBA_DE_DISTANCIA		;5b77   ; en jabalina y altura la postura va cuatro bytes antes
	jp z,PONE_LA_POSTURA_Y_PINTA		;5b7a
	dec hl			;5b7d
	dec hl			;5b7e
	dec hl			;5b7f
	dec hl			;5b80
	ld (hl),b			;5b81
	call FICHA_DEL_QUE_JUEGA		;5b82   ; la ficha del atleta al que le toca
	ld a,b			;5b85
	jp PINTA_AL_ATLETA		;5b86
SE_ACABO_LA_ANIMACION:
	ld hl,0e02eh		;5b89
	set 1,(hl)		;5b8c   ; bit 1 de 0xE02E: se acabo la prueba
	ld l,020h		;5b8e
	res 2,(hl)		;5b90   ; y baja el bit de prueba terminada
	ret			;5b92
CORRE_EL_ATLETA:
	push hl			;5b93
	call FICHA_DEL_QUE_JUEGA		;5b94   ; la ficha del que juega
	pop hl			;5b97
	ld a,(0e020h)		;5b98   ; bit 2 de 0xE020: la prueba ya termino
	bit 2,a		;5b9b
	ld a,b			;5b9d
	jp nz,PINTA_AL_ATLETA		;5b9e
	push hl			;5ba1
	push de			;5ba2
	ld a,l			;5ba3
	ld de,0e15ch		;5ba4   ; la columna del objeto del jugador 1
	ld hl,0e028h		;5ba7
	cp 0aeh		;5baa
	jr z,MIRA_SI_LLEGA_A_LA_META		;5bac
	ld de,0e14ch		;5bae   ; o la del 2
	ld hl,0e029h		;5bb1
MIRA_SI_LLEGA_A_LA_META:
	ld a,(de)			;5bb4
	cp 062h		;5bb5
	jr nc,MUEVE_LAS_PIERNAS		;5bb7   ; la meta esta en 0x5A
	dec de			;5bb9
	ld a,(de)			;5bba
	cp 001h		;5bbb   ; y con el tramo final puesto
	jr nz,MUEVE_LAS_PIERNAS		;5bbd
	set 2,(hl)		;5bbf   ; bit 2: llegada
MUEVE_LAS_PIERNAS:
	pop de			;5bc1
	pop hl			;5bc2
	push hl			;5bc3
	xor a			;5bc4
	cp (hl)			;5bc5   ; sin velocidad no se mueve
	jr z,PINTA_LA_ZANCADA		;5bc6
	ld a,(de)			;5bc8   ; mientras quede cuenta de paso, se gasta
	or a			;5bc9
	jr nz,GASTA_LA_CUENTA_DE_PASO		;5bca
	ld a,016h		;5bcc   ; 0x16 menos la velocidad da los cuadros por paso
	sub (hl)			;5bce
	daa			;5bcf
	cp 010h		;5bd0   ; en BCD
	jr c,CUADROS_POR_PASO		;5bd2
AJUSTA_EL_PASO:
	sub 006h		;5bd4
CUADROS_POR_PASO:
	srl a		;5bd6   ; dividido por ocho
	srl a		;5bd8
	srl a		;5bda
	ld (de),a			;5bdc   ; y se guarda como cuenta
	call ES_PRUEBA_DE_DISTANCIA		;5bdd
	jr z,SALTA_A_LA_POSTURA_DE_TIEMPO		;5be0
	call POSTURA_DEL_QUE_JUEGA		;5be2
	jr SUBE_LA_POSTURA		;5be5
SALTA_A_LA_POSTURA_DE_TIEMPO:
	ld bc,00008h		;5be7   ; y en las de tiempo, ocho bytes mas alla
	add hl,bc			;5bea
SUBE_LA_POSTURA:
	inc (hl)			;5beb   ; postura siguiente
	ld a,00bh		;5bec
	cp (hl)			;5bee
	jr nc,PINTA_LA_ZANCADA		;5bef
	ld (hl),006h		;5bf1
	ld a,047h		;5bf3
	call PIDE_UN_SONIDO		;5bf5
PINTA_LA_ZANCADA:
	pop hl			;5bf8   ; la ficha del que juega
	push hl			;5bf9
	call ES_PRUEBA_DE_DISTANCIA		;5bfa   ; en jabalina y altura se pinta de otra forma
	jr z,PINTA_LA_ZANCADA_DE_TIEMPO		;5bfd
	push hl			;5bff
	call FICHA_DEL_QUE_JUEGA		;5c00
	pop hl			;5c03
	jr PINTA_Y_MIRA_EL_FINAL		;5c04
PINTA_LA_ZANCADA_DE_TIEMPO:
	ld a,l			;5c06
	ld b,001h		;5c07   ; el 1 es el jugador 1
	cp 0aeh		;5c09
	jr z,PINTA_Y_MIRA_EL_FINAL		;5c0b
	ld b,000h		;5c0d
PINTA_Y_MIRA_EL_FINAL:
	ld a,b			;5c0f
	call PINTA_AL_ATLETA		;5c10
	pop hl			;5c13
	jr MIRA_SI_ES_DISTANCIA		;5c14
GASTA_LA_CUENTA_DE_PASO:
	ld a,(de)			;5c16
	dec a			;5c17
	ld (de),a			;5c18
	jr PINTA_LA_ZANCADA		;5c19
MIRA_SI_ES_DISTANCIA:
	call ES_PRUEBA_DE_DISTANCIA		;5c1b
	ret z			;5c1e
	rrca			;5c1f
	jr c,MIRA_EL_ANGULO_DEL_TIRO		;5c20
	ld bc,0fe2bh		;5c22   ; lo que falta para 0x1D5
	ld hl,(0e0e8h)		;5c25
	add hl,bc			;5c28
	ret nc			;5c29   ; aun no ha llegado a la tabla
	ld de,0e0aeh		;5c2a
	ld a,(de)			;5c2d   ; hace falta angulo
	cp 005h		;5c2e
	ret c			;5c30
MIRA_EL_ANGULO_DEL_TIRO:
	ld a,(0e0c5h)		;5c31   ; bit 1 de 0xE0C5
	bit 1,a		;5c34
	ret z			;5c36
	xor a			;5c37
	ld (0e0c5h),a		;5c38
	ld hl,0e020h		;5c3b   ; bit 2 de 0xE020: la prueba se acaba
	set 2,(hl)		;5c3e
	ret			;5c40
SUBE_UN_PATRON_DE_SPRITE:
	ld c,020h		;5c41   ; 32 bytes por patron
	call FIJA_ESCRITURA_CON_CANDADO		;5c43   ; fija la direccion de VRAM
	exx			;5c46
	push bc			;5c47
	ld a,(00006h)		;5c48   ; el puerto de datos
	ld c,a			;5c4b
	exx			;5c4c
UN_BYTE_DEL_PATRON:
	ld a,(hl)			;5c4d
	or a			;5c4e   ; el cero abre una racha
	jr nz,SUELTA_UN_BYTE		;5c4f
	inc c			;5c51   ; la cuenta no gasta el byte de la racha
	inc hl			;5c52
	ld b,(hl)			;5c53   ; cuantos ceros
SUELTA_CEROS:
	exx			;5c54
	out (c),a		;5c55   ; el puerto de datos del VDP
	exx			;5c57
	dec c			;5c58   ; la cuenta baja con cada cero
	djnz SUELTA_CEROS		;5c59
	jr SIGUIENTE_BYTE_DEL_PATRON		;5c5b
SUELTA_UN_BYTE:
	exx			;5c5d
	out (c),a		;5c5e   ; el byte va tal cual
	exx			;5c60
SIGUIENTE_BYTE_DEL_PATRON:
	inc hl			;5c61
	dec c			;5c62   ; hasta completar los 32
	jr nz,UN_BYTE_DEL_PATRON		;5c63
	exx			;5c65
	pop bc			;5c66
	exx			;5c67
	ret			;5c68
MUEVE_EL_DECORADO:
	ld (0e0fdh),a		;5c69   ; el 1 es el jugador 1, el 0 el jugador 2
	ld de,0e153h		;5c6c   ; la columna del segundo objeto
	push de			;5c6f
	ld hl,0e0c4h		;5c70   ; y la marca del jugador 1
	exx			;5c73
	ld hl,0e0b2h		;5c74   ; su posicion
	pop de			;5c77
	exx			;5c78
	or a			;5c79
	jr nz,SUMA_EL_AVANCE_AL_DECORADO		;5c7a   ; con cero se pasa al jugador 2
	exx			;5c7c
	ld hl,0e0e8h		;5c7d   ; la posicion del jugador 2
	ld de,0e143h		;5c80   ; la columna del primer objeto
	push de			;5c83
	exx			;5c84
	pop de			;5c85
	ld hl,0e0fah		;5c86   ; y su marca
SUMA_EL_AVANCE_AL_DECORADO:
	exx			;5c89
	ld a,(de)			;5c8a   ; el avance del cuadro
	add a,(hl)			;5c8b   ; se acumula en la posicion
	ld (hl),a			;5c8c
	inc hl			;5c8d
	ld a,000h		;5c8e
	adc a,(hl)			;5c90
	ld (hl),a			;5c91
	exx			;5c92
	call ES_PRUEBA_IMPAR		;5c93
	ret c			;5c96
	ld a,(de)			;5c97
	add a,(hl)			;5c98
	ld c,a			;5c99
	ld (hl),a			;5c9a
	sub 09ch		;5c9b   ; cada 0x9C de avance toca cambiar de tramo
	jr c,CORRE_LAS_MARCAS		;5c9d
	ld (hl),a			;5c9f
	push hl			;5ca0
	push de			;5ca1
	push bc			;5ca2
	call CORRE_LAS_MARCAS		;5ca3   ; y se corre el decorado
	pop bc			;5ca6
	pop de			;5ca7
	pop hl			;5ca8
	ld a,(0e0fdh)		;5ca9
	push de			;5cac
	ld de,ARRANCA_O_PINTA		;5cad   ; la fila de sprites del decorado
	ld hl,0e0b8h		;5cb0
	push bc			;5cb3
	ld bc,003b7h		;5cb4
	or a			;5cb7
	jr nz,BUSCA_UNA_MARCA_LIBRE		;5cb8
	ld c,087h		;5cba   ; el jugador 2 usa la 0x87
	call ES_PRUEBA_DE_DISTANCIA		;5cbc
	jr z,MARCAS_DEL_JUGADOR_1		;5cbf
	ld c,0a0h		;5cc1   ; o la 0xA0 en las de distancia
MARCAS_DEL_JUGADOR_1:
	ld de,MARGEN_POR_DELANTE		;5cc3
	ld hl,0e0eeh		;5cc6
BUSCA_UNA_MARCA_LIBRE:
	push hl			;5cc9
	ex de,hl			;5cca
	ld de,00040h		;5ccb   ; cuatro bytes por sprite
	add hl,de			;5cce
	ex de,hl			;5ccf
	pop hl			;5cd0
	inc hl			;5cd1   ; y cuatro por marca
	inc hl			;5cd2
	inc hl			;5cd3
	inc hl			;5cd4
	dec b			;5cd5
	jr z,PONE_LA_MARCA_EN_SU_SITIO		;5cd6
	ld a,0cfh		;5cd8   ; 0xCF es fila libre
	cp (hl)			;5cda
	jr nz,BUSCA_UNA_MARCA_LIBRE		;5cdb
PONE_LA_MARCA_EN_SU_SITIO:
	ld (hl),c			;5cdd   ; el patron de la marca
	inc hl			;5cde
	pop bc			;5cdf
	ld a,c			;5ce0
	sub 09ch		;5ce1   ; lo que sobra del tramo
	ld b,a			;5ce3
	ld a,0e0h		;5ce4   ; da la columna
	sub b			;5ce6
	ld (hl),a			;5ce7
	xor a			;5ce8
	pop bc			;5ce9
	ld (bc),a			;5cea   ; y el avance se da por gastado
	inc hl			;5ceb
	push hl			;5cec
	push de			;5ced
	push bc			;5cee
	call PINTA_LA_CIFRA_DE_LA_MARCA		;5cef   ; pinta la cifra de la marca
	pop bc			;5cf2
	pop de			;5cf3
	pop hl			;5cf4
	ld a,020h		;5cf5   ; la marca sube 0x20 en BCD
	add a,(hl)			;5cf7
	daa			;5cf8
	ld (hl),a			;5cf9
	inc hl			;5cfa
	ld a,000h		;5cfb
	adc a,(hl)			;5cfd
	daa			;5cfe
	ld (hl),a			;5cff
	ret			;5d00
CORRE_LAS_MARCAS:
	ld b,002h		;5d01   ; dos marcas
	ld a,(de)			;5d03   ; lo que hay que correr
	ld c,a			;5d04
	xor a			;5d05
	ld (de),a			;5d06   ; y se da por gastado
	ld a,(0e0fdh)		;5d07
	ld hl,0e0bdh		;5d0a   ; las marcas del jugador 1
	or a			;5d0d
	jr nz,CORRE_UNA_MARCA		;5d0e
	ld hl,0e0f3h		;5d10   ; o las del 2
CORRE_UNA_MARCA:
	ld a,(hl)			;5d13
	sub c			;5d14   ; se le resta el avance
	ld (hl),a			;5d15
	push hl			;5d16
	sub 010h		;5d17   ; y si se sale por la izquierda
	jr nc,SIGUIENTE_MARCA		;5d19
	dec hl			;5d1b
	ld (hl),0cfh		;5d1c   ; se esconde en la fila 0xCF
SIGUIENTE_MARCA:
	pop hl			;5d1e
	inc hl			;5d1f   ; cuatro bytes por sprite
	inc hl			;5d20
	inc hl			;5d21
	inc hl			;5d22
	djnz CORRE_UNA_MARCA		;5d23
	ld bc,0fff7h		;5d25   ; nueve atras
	add hl,bc			;5d28
	jp CORRE_LAS_CIFRAS		;5d29
PINTA_LA_CIFRA_DE_LA_MARCA:
	push hl			;5d2c
	ld a,(hl)			;5d2d   ; la cifra de arriba
	and 0f0h		;5d2e
	rrca			;5d30   ; en la fuente
	ld hl,06197h		;5d31
	call SUMA_A_A_HL		;5d34
	ld b,008h		;5d37   ; sus ocho bytes al patron del sprite
	call SUBE_BYTES_CON_DIRECCION		;5d39
	pop hl			;5d3c
	inc hl			;5d3d
	ld a,(hl)			;5d3e   ; con la cifra de abajo a cero se acaba
	cp 000h		;5d3f
	ret z			;5d41
	and 00fh		;5d42   ; la cifra de abajo
	rlca			;5d44
	rlca			;5d45
	rlca			;5d46
	push hl			;5d47
	ld hl,00030h		;5d48   ; tres filas mas abajo
	add hl,de			;5d4b
	ex de,hl			;5d4c
	ld hl,06197h		;5d4d   ; en la fuente
	call SUMA_A_A_HL		;5d50
	ld b,008h		;5d53
	call SUBE_BYTES_CON_DIRECCION		;5d55
	pop hl			;5d58
	bit 4,(hl)		;5d59   ; bit 4: hace falta un cero delante
	ret z			;5d5b
	ld hl,0fff0h		;5d5c   ; dieciseis atras
	add hl,de			;5d5f
	ex de,hl			;5d60
	ld hl,0619fh		;5d61   ; el glifo del uno
	ld b,008h		;5d64
	call SUBE_BYTES_CON_DIRECCION		;5d66
	ret			;5d69
CORRE_LAS_CIFRAS:
	push hl			;5d6a
	push de			;5d6b
	ld de,07b48h		;5d6c   ; la fila de las cifras del jugador 1
	ld a,0bch		;5d6f
	cp l			;5d71   ; segun de quien sean
	jr z,DOS_CIFRAS		;5d72
	ld de,07b58h		;5d74   ; o la del 2
DOS_CIFRAS:
	ld c,002h		;5d77
UNA_CIFRA:
	ld b,002h		;5d79
	call SUBE_BYTES_CON_DIRECCION		;5d7b   ; fila y columna
	dec hl			;5d7e
	dec hl			;5d7f
	inc de			;5d80
	inc de			;5d81
	inc de			;5d82
	inc de			;5d83
	ld a,(hl)			;5d84   ; la fila
	ld (0e0fbh),a		;5d85
	inc hl			;5d88
	ld a,(hl)			;5d89
	sub 010h		;5d8a   ; y la columna menos 0x10
	ld (0e0fch),a		;5d8c
	push hl			;5d8f
	ld hl,0e0fbh		;5d90
	ld b,002h		;5d93
	call SUBE_BYTES_CON_DIRECCION		;5d95   ; al sprite de al lado
	pop hl			;5d98
	inc hl			;5d99
	inc hl			;5d9a
	inc hl			;5d9b
	inc de			;5d9c
	inc de			;5d9d
	inc de			;5d9e
	inc de			;5d9f
	dec c			;5da0
	jr nz,UNA_CIFRA		;5da1
	pop de			;5da3
	pop hl			;5da4
	ret			;5da5
PINTA_A_LOS_DOS_ATLETAS:
	ld a,(0e000h)		;5da6
	bit 0,a		;5da9   ; en los cuadros pares
	jr nz,PINTA_LAS_MARCAS		;5dab
	call AVANZA_EL_QUE_JUEGA		;5dad   ; mueve el decorado
	ld hl,0e130h		;5db0   ; y las dos fichas
	call MUEVE_Y_PINTA_UN_ACTOR		;5db3
	ld hl,0e120h		;5db6
	jp MUEVE_Y_PINTA_UN_ACTOR		;5db9
PINTA_LAS_MARCAS:
	ld hl,0e140h		;5dbc   ; la ficha del primer objeto
	call MUEVE_Y_PINTA_UN_ACTOR		;5dbf   ; y la del segundo
	ld hl,0e150h		;5dc2
	call MUEVE_Y_PINTA_UN_ACTOR		;5dc5
	xor a			;5dc8
	call MUEVE_EL_DECORADO		;5dc9   ; corre el decorado del jugador 2
	xor a			;5dcc   ; y le borra el avance
	ld (0e143h),a		;5dcd
	ret			;5dd0
AVANZA_EL_QUE_JUEGA:
	call COLUMNA_DEL_QUE_JUEGA		;5dd1   ; la ficha del que juega
	ex de,hl			;5dd4
	ld a,(0e020h)		;5dd5   ; bit 2 de 0xE020: la prueba ya acabo
	bit 2,a		;5dd8
	jr nz,MIRA_EL_FIN_DEL_TRAMO		;5dda
	call ES_PRUEBA_IMPAR		;5ddc
	jr c,TIRA_DEL_ATLETA		;5ddf
AVANZA_EL_DECORADO:
	ld a,(0e0b9h)		;5de1
	ld hl,0e141h		;5de4   ; el avance del cuadro
	add a,(hl)			;5de7   ; al decorado
	ld (hl),a			;5de8
GASTA_EL_AVANCE:
	ld hl,0e0b9h		;5de9   ; el avance del cuadro
	ld (hl),000h		;5dec   ; el avance se da por gastado
	ld hl,0e02eh		;5dee
	bit 7,(hl)		;5df1   ; bit 7 de 0xE02E: el atleta va suelto
	jr nz,MIRA_EL_FIN_DEL_TRAMO		;5df3
	ld hl,(0e0e8h)		;5df5   ; la marca del jugador 2
	ld bc,0fe1fh		;5df8
	add hl,bc			;5dfb
	ld hl,0e0fah		;5dfc
	ld (hl),000h		;5dff
	jr nc,MIRA_EL_FIN_DEL_TRAMO		;5e01
	ld hl,0e02eh		;5e03
	set 7,(hl)		;5e06
MIRA_EL_FIN_DEL_TRAMO:
	ld a,(0e020h)		;5e08
	bit 2,a		;5e0b   ; bit 2 de 0xE020
	jr nz,QUITA_CUATRO_SPRITES		;5e0d
	ld hl,(0e0e8h)		;5e0f   ; la posicion del jugador 2
	ld bc,0fd60h		;5e12   ; lo que falta para 0x291
	add hl,bc			;5e15
	jr nc,QUITA_CUATRO_SPRITES		;5e16
MARCA_LA_LLEGADA:
	ld hl,0e02ch		;5e18
	set 0,(hl)		;5e1b   ; bit 0 de 0xE02C: ha llegado
QUITA_CUATRO_SPRITES:
	dec de			;5e1d
	dec de			;5e1e
	dec de			;5e1f
	dec de			;5e20
	ld hl,0e0aeh		;5e21   ; la ficha del atleta del jugador 1
	jp CORRE_EL_ATLETA		;5e24
TIRA_DEL_ATLETA:
	ld a,(de)			;5e27
	cp 0a8h		;5e28
	jr nc,MARCA_LA_LLEGADA		;5e2a
AVANZA_EL_ATLETA_SOLO:
	ld hl,0e0b9h		;5e2c
	add a,(hl)			;5e2f   ; el avance del cuadro
	ld (de),a			;5e30   ; a la columna
	ld (hl),000h		;5e31
	jr QUITA_CUATRO_SPRITES		;5e33

; ----------------------------------------------------------------------
; DATOS pantalla_del_titulo: El guion largo entero de la presentacion:
;   logotipo, el copyright de Konami y el menu. Nueve ordenes.
;   0x5e35..0x6187  (850 bytes)
DATA_pantalla_del_titulo:
	defb 009h,000h,00eh,065h,0a0h,038h,000h,000h	; 5e35  ...e.8..
	defb 002h,000h,08ah,0aah,0aah,0dah,000h,000h	; 5e3d  ........
	defb 008h,048h,0eeh,04ah,04ah,06ah,000h,00fh	; 5e45  .H.JJj..
	defb 0bfh,0ffh,0ffh,0ffh,0bfh,00fh,000h,000h	; 5e4d  ........
	defb 0fch,0c0h,0c0h,080h,080h,000h,011h,008h	; 5e55  ........
	defb 000h,081h,042h,024h,018h,018h,024h,042h	; 5e5d  ..B$..$B
	defb 081h,03ch,042h,099h,0bdh,0bdh,099h,042h	; 5e65  .<B....B
	defb 03ch,067h,050h,030h,03ch,042h,099h,0a1h	; 5e6d  <gP0<B..
	defb 0a1h,099h,042h,03ch,003h,067h,06eh,07ch	; 5e75  ..B<.gn|
	defb 079h,079h,07fh,06fh,080h,000h,000h,03dh	; 5e7d  yy.o...=
	defb 0adh,0adh,0adh,03dh,000h,000h,000h,0ceh	; 5e85  ...=....
	defb 063h,06fh,06bh,06fh,000h,000h,000h,07ch	; 5e8d  coko...|
	defb 056h,056h,056h,056h,000h,000h,0c0h,000h	; 5e95  VVVV....
	defb 011h,004h,0c0h,063h,0d8h,0e8h,011h,00ah	; 5e9d  ...c....
	defb 0f0h,0f8h,0fch,07fh,03fh,00fh,003h,011h	; 5ea5  ....?...
	defb 00ah,00fh,01fh,03fh,0feh,0fch,0f0h,0c0h	; 5ead  ...?....
	defb 000h,080h,011h,006h,0ffh,000h,001h,011h	; 5eb5  ........
	defb 006h,0ffh,000h,000h,011h,00eh,0ffh,000h	; 5ebd  ........
	defb 000h,000h,003h,007h,00fh,01eh,011h,00bh	; 5ec5  ........
	defb 01ch,01eh,00fh,007h,003h,011h,005h,000h	; 5ecd  ........
	defb 0ffh,0ffh,0ffh,011h,005h,000h,0e0h,0f0h	; 5ed5  ........
	defb 0f8h,03ch,011h,00bh,01ch,03ch,0f8h,0f0h	; 5edd  .<...<..
	defb 0e0h,011h,007h,000h,001h,011h,00ch,003h	; 5ee5  ........
	defb 001h,011h,008h,000h,07fh,0ffh,0ffh,0c0h	; 5eed  ........
	defb 011h,00ah,080h,0c0h,0ffh,0ffh,07fh,011h	; 5ef5  ........
	defb 006h,000h,0ffh,0ffh,0ffh,011h,004h,000h	; 5efd  ........
	defb 0ffh,0ffh,0ffh,011h,006h,000h,0feh,0ffh	; 5f05  ........
	defb 0ffh,003h,011h,00ah,001h,003h,0ffh,0ffh	; 5f0d  ........
	defb 0feh,011h,008h,000h,080h,011h,00ch,0c0h	; 5f15  ........
	defb 080h,011h,005h,000h,060h,00eh,002h,007h	; 5f1d  ....`...
	defb 00fh,060h,016h,01ah,0f8h,0f0h,011h,004h	; 5f25  .`......
	defb 03eh,011h,004h,03fh,01fh,03fh,07fh,0ffh	; 5f2d  >..?.?..
	defb 0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,000h	; 5f35  ........
	defb 000h,000h,03eh,03eh,060h,035h,003h,01fh	; 5f3d  ..>>`5..
	defb 07fh,0fbh,060h,03dh,003h,00fh,0cfh,0efh	; 5f45  ..`=....
	defb 060h,045h,003h,078h,0fch,0bch,060h,04dh	; 5f4d  `E.x..`M
	defb 003h,03fh,07fh,0f3h,060h,055h,003h,087h	; 5f55  .?..`U..
	defb 0c7h,0c7h,060h,05dh,003h,0bch,0feh,0dfh	; 5f5d  ..`]....
	defb 060h,065h,06bh,078h,0fch,0bch,060h,0f0h	; 5f65  `ekx..`.
	defb 0f0h,060h,000h,0f0h,0f0h,0f0h,03fh,03fh	; 5f6d  .`....??
	defb 011h,006h,03eh,0f8h,0fch,0feh,07fh,03fh	; 5f75  ..>....?
	defb 01fh,00fh,007h,03eh,03eh,03eh,07eh,0fch	; 5f7d  ...>>>~.
	defb 0fch,0f8h,0e0h,011h,005h,0f1h,0fbh,07fh	; 5f85  ........
	defb 01fh,011h,006h,0efh,0cfh,00fh,011h,008h	; 5f8d  ........
	defb 01eh,0e1h,003h,03fh,0f1h,0e1h,0f3h,07fh	; 5f95  ...?....
	defb 01eh,011h,008h,0e7h,011h,008h,08fh,011h	; 5f9d  ........
	defb 008h,01eh,0f1h,0f2h,011h,004h,0f5h,0f2h	; 5fa5  ........
	defb 0f1h,0e0h,010h,0c8h,068h,0c8h,028h,010h	; 5fad  ....h.(.
	defb 0e0h,061h,000h,000h,011h,004h,00fh,01eh	; 5fb5  .a......
	defb 01eh,01eh,03fh,09eh,03eh,03eh,03ch,07ch	; 5fbd  ..?.>><|
	defb 078h,0f8h,0f0h,000h,0e7h,0e7h,0eeh,0eeh	; 5fc5  x.......
	defb 0fch,0dch,0f8h,000h,0bfh,03fh,03fh,073h	; 5fcd  .....??s
	defb 077h,077h,0ffh,000h,00fh,08fh,09fh,09ch	; 5fd5  ww......
	defb 09ch,038h,03fh,000h,0e7h,0c7h,0c7h,00eh	; 5fdd  .8?.....
	defb 00eh,00eh,09fh,000h,0e0h,0f0h,0f0h,070h	; 5fe5  .......p
	defb 0f0h,0f0h,0e0h,000h,007h,00fh,00fh,01eh	; 5fed  ........
	defb 01eh,01ch,03dh,000h,0f0h,0f8h,0f8h,071h	; 5ff5  ..=....q
	defb 0f1h,0f1h,0e3h,000h,0f8h,0f0h,0f0h,0e0h	; 5ffd  ........
	defb 0e0h,0e0h,0c0h,000h,0bch,03ch,03ch,07ch	; 6005  .....<<|
	defb 07dh,07dh,0ffh,000h,07eh,07ch,0fch,0f8h	; 600d  }}..~|..
	defb 0f8h,0f8h,0f0h,000h,03fh,03fh,03fh,073h	; 6015  ....???s
	defb 077h,077h,0ffh,000h,00fh,08eh,09eh,09ch	; 601d  ww......
	defb 09ch,03ch,038h,000h,00fh,03fh,03fh,073h	; 6025  .<8..??s
	defb 073h,0e0h,0e0h,000h,000h,080h,080h,080h	; 602d  s.......
	defb 080h,000h,000h,03fh,03ch,079h,079h,079h	; 6035  ...?<yyy
	defb 0f3h,0f3h,0f3h,0f0h,0f0h,0f0h,0e0h,0e1h	; 603d  ........
	defb 0e1h,0c3h,0c3h,0f8h,0f0h,0f1h,0e1h,0e1h	; 6045  ........
	defb 0c3h,0c3h,0c7h,0feh,0feh,0fch,0c0h,0c0h	; 604d  ........
	defb 080h,080h,081h,03fh,07fh,070h,070h,0e0h	; 6055  ...?.pp.
	defb 0feh,0fch,0fch,01fh,01fh,03bh,03bh,03bh	; 605d  .....;;;
	defb 073h,073h,0f3h,011h,008h,080h,03dh,039h	; 6065  ss....=9
	defb 07bh,07bh,0e3h,0ffh,0ffh,07fh,0e3h,0e3h	; 606d  {{......
	defb 0c7h,0c7h,0c7h,08fh,08fh,01fh,0c0h,0c0h	; 6075  ........
	defb 080h,080h,001h,0f9h,0f3h,0f3h,0ffh,0deh	; 607d  ........
	defb 0deh,0dch,09dh,099h,099h,013h,0f0h,0f0h	; 6085  ........
	defb 0f1h,0e1h,0e1h,0e3h,0c3h,0c7h,0feh,0feh	; 608d  ........
	defb 0fch,0c0h,0c0h,080h,080h,081h,039h,079h	; 6095  ......9y
	defb 071h,073h,0f3h,0e3h,0e3h,0e1h,0c0h,0c0h	; 609d  qs......
	defb 0c0h,08eh,08eh,0dch,0fch,0f8h,001h,003h	; 60a5  ........
	defb 007h,007h,00fh,00eh,01eh,001h,062h,000h	; 60ad  ......b.
	defb 018h,0f0h,0f8h,0fch,03ch,07ch,078h,0f8h	; 60b5  ....<|x.
	defb 0f0h,007h,00fh,01fh,01eh,03eh,03fh,07fh	; 60bd  .....>?.
	defb 07fh,0e0h,080h,000h,000h,000h,0f0h,0e0h	; 60c5  ........
	defb 0e0h,001h,006h,065h,008h,001h,002h,003h	; 60cd  ...e....
	defb 004h,00ch,00eh,014h,019h,01dh,013h,00dh	; 60d5  ........
	defb 015h,01ah,016h,00bh,021h,00fh,01bh,01ch	; 60dd  ....!...
	defb 0ffh,065h,0d8h,028h,029h,029h,02ah,02ah	; 60e5  .e.())**
	defb 00bh,00ch,00dh,00eh,00fh,010h,011h,012h	; 60ed  ........
	defb 013h,014h,015h,016h,017h,018h,019h,01ah	; 60f5  ........
	defb 01bh,01ch,01dh,01eh,01fh,020h,021h,0ffh	; 60fd  ..... !.
	defb 066h,0e0h,026h,027h,024h,025h,022h,023h	; 6105  f.&'$%"#
	defb 0ffh,067h,080h,000h,001h,002h,003h,004h	; 610d  .g......
	defb 005h,006h,007h,008h,009h,0ffh,067h,010h	; 6115  ......g.
	defb 02bh,02ch,01eh,00bh,016h,013h,010h,021h	; 611d  +,.....!
	defb 0ffh,064h,0c0h,00eh,016h,020h,01ch,00dh	; 6125  .d... ..
	defb 019h,01bh,00fh,0ffh,003h,009h,045h,008h	; 612d  ......E.
	defb 0a8h,070h,018h,0f0h,010h,060h,010h,0f0h	; 6135  .p...`..
	defb 010h,060h,0c0h,0f0h,060h,070h,038h,060h	; 613d  .`..`p8`
	defb 088h,0f0h,003h,001h,040h,008h,000h,0f0h	; 6145  ....@...
	defb 003h,001h,041h,000h,0a8h,050h,003h,00fh	; 614d  ..A..P..
	defb 043h,0d8h,00ch,06ah,004h,067h,00ch,06ah	; 6155  C..j.g.j
	defb 004h,067h,004h,0a0h,004h,066h,004h,0a0h	; 615d  .g...f..
	defb 004h,066h,004h,0a0h,004h,060h,008h,011h	; 6165  .f...`..
	defb 038h,0a0h,070h,050h,040h,070h,008h,077h	; 616d  8.pP@p.w
	defb 004h,041h,000h,010h,087h,061h,004h,041h	; 6175  .A...a.A
	defb 080h,00fh,08fh,061h,003h,001h,041h,0f8h	; 617d  ...a..A.
	defb 020h,0a0h	; 6185

; ----------------------------------------------------------------------
; DATOS patrones_de_relleno: Dos patrones de ocho bytes que la orden 4 del
;   guion del titulo repite.
;   0x6187..0x6197  (16 bytes)
DATA_patrones_de_relleno:
	defb 060h,060h,060h,090h,060h,0f0h,060h,0f0h	; 6187  ```.`.`.
	defb 080h,0f0h,080h,0f0h,090h,0f0h,090h,0f0h	; 618f  ........

; ----------------------------------------------------------------------
; DATOS fuente: Los 51 glifos de 8x8 con los que se escribe todo el cartucho,
;   byte a byte los mismos que en el cartucho hermano. El alfabeto va de la A
;   (indice 0x0B) a la Y SALTANDOSE la Q, la X y la Z, pero la Q SI existe:
;   esta al final, en el indice 0x2C, porque la necesita QUALIFY (la tira de
;   0x611E). X y Z no salen en ningun rotulo.
;   0x6197..0x632f  (408 bytes)
DATA_fuente:
	defb 000h,01ch,022h,063h,063h,063h,022h,01ch	; 6197  .."ccc".
	defb 000h,018h,038h,018h,018h,018h,018h,07eh	; 619f  ..8....~
	defb 000h,03eh,063h,003h,00eh,03ch,070h,07fh	; 61a7  .>c..<p.
	defb 000h,03eh,063h,003h,00eh,003h,063h,03eh	; 61af  .>c...c>
	defb 000h,00eh,01eh,036h,066h,066h,07fh,006h	; 61b7  ...6ff..
	defb 000h,07fh,060h,07eh,063h,003h,063h,03eh	; 61bf  ..`~c.c>
	defb 000h,03eh,063h,060h,07eh,063h,063h,03eh	; 61c7  .>c`~cc>
	defb 000h,07fh,063h,006h,00ch,018h,018h,018h	; 61cf  ..c.....
	defb 000h,03eh,063h,063h,03eh,063h,063h,03eh	; 61d7  .>cc>cc>
	defb 000h,03eh,063h,063h,03fh,003h,063h,03eh	; 61df  .>cc?.c>
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 61e7  ........
	defb 000h,01ch,036h,063h,063h,07fh,063h,063h	; 61ef  ..6cc.cc
	defb 000h,07eh,063h,063h,07eh,063h,063h,07eh	; 61f7  .~cc~cc~
	defb 000h,03eh,063h,060h,060h,060h,063h,03eh	; 61ff  .>c```c>
	defb 000h,07ch,066h,063h,063h,063h,066h,07ch	; 6207  .|fcccf|
	defb 000h,07fh,060h,060h,07eh,060h,060h,07fh	; 620f  ..``~``.
	defb 000h,07fh,060h,060h,07eh,060h,060h,060h	; 6217  ..``~```
	defb 000h,03eh,063h,060h,067h,063h,063h,03fh	; 621f  .>c`gcc?
	defb 000h,063h,063h,063h,07fh,063h,063h,063h	; 6227  .ccc.ccc
	defb 000h,03ch,018h,018h,018h,018h,018h,03ch	; 622f  .<.....<
	defb 000h,01fh,006h,006h,006h,006h,066h,03ch	; 6237  ......f<
	defb 000h,063h,066h,06ch,078h,07ch,06eh,067h	; 623f  .cflx|ng
	defb 000h,060h,060h,060h,060h,060h,060h,07fh	; 6247  .``````.
	defb 000h,063h,077h,07fh,07fh,06bh,063h,063h	; 624f  .cw..kcc
	defb 000h,063h,073h,07bh,07fh,06fh,067h,063h	; 6257  .cs{.ogc
	defb 000h,03eh,063h,063h,063h,063h,063h,03eh	; 625f  .>ccccc>
	defb 000h,07eh,063h,063h,063h,07eh,060h,060h	; 6267  .~ccc~``
	defb 000h,07eh,063h,063h,062h,07ch,066h,063h	; 626f  .~ccb|fc
	defb 000h,03eh,063h,060h,03eh,003h,063h,03eh	; 6277  .>c`>.c>
	defb 000h,07eh,018h,018h,018h,018h,018h,018h	; 627f  .~......
	defb 000h,063h,063h,063h,063h,063h,063h,03eh	; 6287  .cccccc>
	defb 000h,063h,063h,063h,063h,036h,01ch,008h	; 628f  .cccc6..
	defb 000h,063h,063h,06bh,06bh,07fh,077h,022h	; 6297  .cckk.w"
	defb 000h,066h,066h,07eh,03ch,018h,018h,018h	; 629f  .ff~<...
	defb 000h,000h,000h,0d4h,07ch,054h,054h,056h	; 62a7  ....|TTV
	defb 000h,000h,000h,0dch,00eh,0cah,0cah,0cbh	; 62af  ........
	defb 000h,07bh,04ah,062h,033h,00ah,04ah,07bh	; 62b7  .{Jb3.J{
	defb 000h,0deh,012h,010h,0d0h,010h,012h,0deh	; 62bf  ........
	defb 000h,06dh,036h,024h,024h,024h,024h,024h	; 62c7  .m6$$$$$
	defb 000h,080h,080h,080h,080h,080h,0a0h,0c0h	; 62cf  ........
	defb 010h,030h,07eh,0feh,0feh,07eh,030h,010h	; 62d7  .0~..~0.
	defb 008h,00ch,07eh,07fh,07fh,07eh,00ch,008h	; 62df  ..~..~..
	defb 000h,038h,07ch,0feh,0feh,0feh,07ch,038h	; 62e7  .8|...|8
	defb 000h,018h,018h,000h,000h,018h,018h,000h	; 62ef  ........
	defb 000h,03eh,063h,063h,063h,06fh,066h,03dh	; 62f7  .>cccof=
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 62ff  ........
	defb 000h,066h,0ebh,06bh,06bh,06bh,06bh,066h	; 6307  .f.kkkkf
	defb 000h,07bh,049h,041h,041h,041h,049h,079h	; 630f  .{IAAAIy
	defb 000h,06ch,0b4h,024h,024h,024h,025h,026h	; 6317  .l.$$$%&
	defb 001h,002h,004h,008h,010h,020h,040h,080h	; 631f  ..... @.
	defb 000h,000h,07eh,000h,000h,07eh,000h,000h	; 6327  ..~..~..

; ----------------------------------------------------------------------
; DATOS rotulo_632F: Rotulo de letra grande, formato de 0x4C4C.
;   0x632f..0x634a  (27 bytes)
DATA_rotulo_632F:
	defb 000h,020h,000h,000h,0ffh,0ffh,011h,006h,000h,0ffh,0ffh,078h,03ch,01eh,00fh,000h	; 632f  . .........x<...
	defb 000h,0ffh,0ffh,011h,006h,000h,0ffh,0ffh,011h,004h,000h	; 633f  ...........

; ----------------------------------------------------------------------
; DATOS rotulo_634A: Rotulo de letra grande, formato de 0x4C4C.
;   0x634a..0x6360  (22 bytes)
DATA_rotulo_634A:
	defb 000h,020h,011h,008h,000h,007h,003h,001h,011h,005h,000h,080h,0c0h,0e0h,0f0h,078h	; 634a  . .............x
	defb 03ch,01eh,00fh,011h,008h,000h	; 635a

; ----------------------------------------------------------------------
; DATOS rotulo_6360: Rotulo de letra grande, formato de 0x4C4C.
;   0x6360..0x637f  (31 bytes)
DATA_rotulo_6360:
	defb 000h,020h,000h,000h,000h,0ffh,0ffh,000h,000h,000h,007h,003h,001h,0ffh,0ffh,000h	; 6360  . ..............
	defb 000h,000h,080h,0c0h,0e0h,0ffh,0ffh,011h,006h,000h,0ffh,0ffh,000h,000h,000h	; 6370  ...............

; ----------------------------------------------------------------------
; DATOS rotulo_637F: Rotulo de letra grande, formato de 0x4C4C.
;   0x637f..0x6393  (20 bytes)
DATA_rotulo_637F:
	defb 000h,020h,011h,009h,000h,002h,011h,006h,003h,000h,000h,000h,080h,0c0h,0e0h,0f0h	; 637f  . ..............
	defb 078h,011h,008h,000h	; 638f

; ----------------------------------------------------------------------
; DATOS rotulo_6393: Rotulo de letra grande, formato de 0x4C4C.
;   0x6393..0x63a9  (22 bytes)
DATA_rotulo_6393:
	defb 000h,020h,011h,008h,003h,03ch,01eh,00fh,007h,003h,001h,011h,005h,000h,080h,0c0h	; 6393  . ...<..........
	defb 0e0h,0f0h,078h,011h,008h,000h	; 63a3

; ----------------------------------------------------------------------
; DATOS rotulo_63A9: Rotulo de letra grande, formato de 0x4C4C.
;   0x63a9..0x63bc  (19 bytes)
DATA_rotulo_63A9:
	defb 000h,028h,011h,008h,000h,003h,003h,01fh,01fh,011h,00ch,000h,03ch,01eh,00fh,007h	; 63a9  .(..........<...
	defb 011h,004h,003h	; 63b9

; ----------------------------------------------------------------------
; DATOS rotulo_63BC: Rotulo de letra grande, formato de 0x4C4C.
;   0x63bc..0x63c7  (11 bytes)
DATA_rotulo_63BC:
	defb 000h,018h,011h,008h,000h,011h,008h,003h,011h,008h,000h	; 63bc  ...........

; ----------------------------------------------------------------------
; DATOS rotulo_63C7: Rotulo de letra grande, formato de 0x4C4C.
;   0x63c7..0x63d4  (13 bytes)
DATA_rotulo_63C7:
	defb 000h,018h,011h,008h,000h,003h,003h,003h,07fh,07fh,011h,00bh,000h	; 63c7  .............

; ----------------------------------------------------------------------
; DATOS patrones_63D4: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x63d4..0x63dc  (8 bytes)
DATA_patrones_63D4:
	defb 0e9h,0e9h,0efh,0efh,0e9h,0e9h,0e9h,0e9h	; 63d4  ........

; ----------------------------------------------------------------------
; DATOS patrones_63DC: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x63dc..0x63e4  (8 bytes)
DATA_patrones_63DC:
	defb 0e9h,0e9h,0e9h,0efh,0efh,0e9h,0e9h,0e9h	; 63dc  ........

; ----------------------------------------------------------------------
; DATOS rotulo_63E4: Rotulo de letra grande, formato de 0x4C4C.
;   0x63e4..0x63f2  (14 bytes)
DATA_rotulo_63E4:
	defb 000h,010h,002h,011h,007h,000h,002h,000h,000h,080h,000h,004h,000h,000h	; 63e4  ..............

; ----------------------------------------------------------------------
; DATOS patrones_63F2: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x63f2..0x63fa  (8 bytes)
DATA_patrones_63F2:
	defb 089h,089h,0ffh,0ffh,089h,089h,089h,089h	; 63f2  ........

; ----------------------------------------------------------------------
; DATOS patrones_63FA: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x63fa..0x6402  (8 bytes)
DATA_patrones_63FA:
	defb 089h,089h,089h,0ffh,0ffh,089h,089h,089h	; 63fa  ........

; ----------------------------------------------------------------------
; DATOS rotulo_6402: Rotulo de letra grande, formato de 0x4C4C.
;   0x6402..0x6413  (17 bytes)
DATA_rotulo_6402:
	defb 000h,010h,000h,001h,000h,001h,011h,004h,000h,008h,001h,000h,009h,000h,000h,004h	; 6402  ................
	defb 000h	; 6412

; ----------------------------------------------------------------------
; DATOS patrones_6413: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x6413..0x641b  (8 bytes)
DATA_patrones_6413:
	defb 032h,0a2h,022h,032h,022h,022h,0a2h,022h	; 6413  2."2""."

; ----------------------------------------------------------------------
; DATOS rotulo_641B: Rotulo de letra grande, formato de 0x4C4C.
;   0x641b..0x6443  (40 bytes)
DATA_rotulo_641B:
	defb 000h,030h,000h,011h,007h,003h,01ch,038h,070h,0e1h,0cdh,0cdh,0fdh,079h,000h,000h	; 641b  .0.....8p....y..
	defb 000h,0eeh,06bh,06bh,06bh,0ebh,000h,000h,000h,073h,01ah,07ah,05ah,07ah,000h,003h	; 642b  ..kkk....s.zZz..
	defb 000h,0f3h,011h,004h,05bh,011h,008h,000h	; 643b  ....[...

; ----------------------------------------------------------------------
; DATOS rotulo_6443: Rotulo de letra grande, formato de 0x4C4C.
;   0x6443..0x6455  (18 bytes)
DATA_rotulo_6443:
	defb 000h,018h,0ffh,033h,033h,033h,0f0h,09ch,09ch,09ch,0ffh,033h,033h,033h,0f0h,09ch	; 6443  ...333.....333..
	defb 09ch,09ch	; 6453

; ----------------------------------------------------------------------
; DATOS rotulo_6455: Rotulo de letra grande, formato de 0x4C4C.
;   0x6455..0x6463  (14 bytes)
DATA_rotulo_6455:
	defb 000h,018h,073h,073h,011h,005h,07ch,038h,073h,073h,011h,005h,07ch,038h	; 6455  ..ss..|8ss..|8

; ----------------------------------------------------------------------
; DATOS rotulo_6463: Rotulo de letra grande, formato de 0x4C4C.
;   0x6463..0x6471  (14 bytes)
DATA_rotulo_6463:
	defb 000h,018h,0e3h,011h,005h,0c3h,081h,0ffh,0e3h,011h,005h,0c3h,081h,0ffh	; 6463  ..............

; ----------------------------------------------------------------------
; DATOS patrones_6471: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x6471..0x6479  (8 bytes)
DATA_patrones_6471:
	defb 0e0h,041h,04fh,04fh,097h,051h,05fh,05fh	; 6471  .AOO.Q__

; ----------------------------------------------------------------------
; DATOS patrones_6479: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x6479..0x6481  (8 bytes)
DATA_patrones_6479:
	defb 095h,095h,0f1h,07fh,07fh,07fh,074h,074h	; 6479  ......tt

; ----------------------------------------------------------------------
; DATOS patrones_6481: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x6481..0x6489  (8 bytes)
DATA_patrones_6481:
	defb 0f1h,071h,07bh,07bh,07bh,0edh,0edh,0b0h	; 6481  .q{{{...

; ----------------------------------------------------------------------
; DATOS rotulo_6489: Rotulo de letra grande, formato de 0x4C4C.
;   0x6489..0x6491  (8 bytes)
DATA_rotulo_6489:
	defb 000h,018h,011h,008h,000h,011h,010h,0ffh	; 6489  ........

; ----------------------------------------------------------------------
; DATOS patrones_6491: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x6491..0x6499  (8 bytes)
DATA_patrones_6491:
	defb 0c6h,039h,039h,039h,039h,028h,039h,028h	; 6491  .9999(9(

; ----------------------------------------------------------------------
; DATOS patrones_6499: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x6499..0x64a1  (8 bytes)
DATA_patrones_6499:
	defb 039h,028h,028h,039h,028h,028h,039h,028h	; 6499  9((9((9(

; ----------------------------------------------------------------------
; DATOS patrones_64A1: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x64a1..0x64a9  (8 bytes)
DATA_patrones_64A1:
	defb 0c6h,028h,028h,028h,0c6h,0c6h,028h,0c6h	; 64a1  .(((..(.

; ----------------------------------------------------------------------
; DATOS patrones_64A9: Patrones de ocho bytes que la orden 4 de un guion
;   repite.
;   0x64a9..0x64b1  (8 bytes)
DATA_patrones_64A9:
	defb 028h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h	; 64a9  (.......

; ----------------------------------------------------------------------
; DATOS rotulo_110_vallas: "110 HURDLERS" en letra grande, glifo a glifo. El
;   cartucho escribe HURDLERS, no HURDLES: la errata esta en estos mismos
;   bytes.
;   0x64b1..0x64c1  (16 bytes)
DATA_rotulo_110_vallas:
	defb 011h,00ah,001h,001h,000h,00ah,012h,01eh,01bh,00eh,016h,00fh,01bh,01ch,00ah,0ffh	; 64b1  ................

; ----------------------------------------------------------------------
; DATOS rotulo_jabalina: "JAVELIN THROW" en letra grande.
;   0x64c1..0x64d2  (17 bytes)
DATA_rotulo_jabalina:
	defb 011h,00ah,014h,00bh,01fh,00fh,016h,013h,018h,00ah,01dh,012h,01bh,019h,020h,00ah	; 64c1  .............. .
	defb 0ffh	; 64d1

; ----------------------------------------------------------------------
; DATOS rotulo_salto_de_altura: "HIGH JUMP" en letra grande.
;   0x64d2..0x64df  (13 bytes)
DATA_rotulo_salto_de_altura:
	defb 011h,00ah,012h,013h,011h,012h,00ah,014h,01eh,017h,01ah,00ah,0ffh	; 64d2  .............

; ----------------------------------------------------------------------
; DATOS rotulo_1500_metros: "1500 METER" en letra grande.
;   0x64df..0x64ef  (16 bytes)
DATA_rotulo_1500_metros:
	defb 011h,00ah,00ah,00ah,001h,005h,000h,000h,00ah,017h,00fh,01dh,00fh,01bh,00ah,0ffh	; 64df  ................

; ----------------------------------------------------------------------
; DATOS marco_del_marcador_grande: Guion largo de nueve ordenes que dibuja el
;   marco del marcador y sube los rotulos grandes de arriba.
;   0x64ef..0x655a  (107 bytes)
DATA_marco_del_marcador_grande:
	defb 009h,003h,008h,077h,000h,008h,001h,008h	; 64ef  ...w....
	defb 080h,008h,0c0h,008h,0e0h,008h,0f0h,008h	; 64f7  ........
	defb 0f8h,008h,0fch,008h,0feh,001h,002h,077h	; 64ff  .......w
	defb 040h,01ch,01ah,00fh,00eh,02fh,030h,031h	; 6507  @..../01
	defb 032h,0ffh,077h,0d0h,024h,025h,01eh,0ffh	; 650f  2.w.$%..
	defb 002h,003h,068h,020h,043h,064h,055h,064h	; 6517  ..h CdUd
	defb 063h,064h,001h,001h,06fh,000h,01ah,016h	; 651f  cd..o...
	defb 00bh,021h,00fh,01bh,01ch,01dh,011h,017h	; 6527  .!......
	defb 019h,01fh,001h,002h,02ah,02ah,0ffh,003h	; 652f  ....**..
	defb 002h,057h,000h,040h,0a4h,0c0h,0f0h,004h	; 6537  .W.@....
	defb 048h,020h,008h,071h,064h,004h,048h,060h	; 653f  H .qd.H`
	defb 008h,079h,064h,004h,048h,0a0h,008h,081h	; 6547  .yd.H...
	defb 064h,003h,003h,04fh,000h,070h,0f0h,008h	; 654f  d..O.p..
	defb 0f4h,008h,064h	; 6557

; ----------------------------------------------------------------------
; DATOS pantallas_de_las_110_vallas: Lista de doce guiones largos: la pista,
;   las calles y el fondo de las 110 vallas y los 1500 metros.
;   0x655a..0x661f  (197 bytes)
DATA_pantallas_de_las_110_vallas:
	defb 00ch,002h,002h,001h,06bh,0a0h,02fh,063h	; 655a  ....k./c
	defb 002h,002h,06bh,000h,002h,064h,0e4h,063h	; 6562  ..k..d.c
	defb 001h,002h,003h,069h,040h,07fh,063h,093h	; 656a  ...i@.c.
	defb 063h,0a9h,063h,001h,002h,001h,06ch,0a0h	; 6572  c.c...l.
	defb 01bh,064h,002h,003h,002h,049h,040h,060h	; 657a  .d...I@`
	defb 0e4h,060h,0e2h,004h,04ah,000h,020h,0d4h	; 6582  .`..J. .
	defb 063h,003h,004h,04bh,000h,004h,013h,064h	; 658a  c..K...d
	defb 004h,04bh,020h,004h,0f2h,063h,003h,002h	; 6592  .K ..c..
	defb 04bh,080h,020h,044h,060h,0f9h,001h,003h	; 659a  K. D`...
	defb 003h,04ch,0a0h,000h,0f4h,000h,0f4h,040h	; 65a2  .L.....@
	defb 0f4h,002h,002h,001h,073h,0a0h,02fh,063h	; 65aa  ....s./c
	defb 002h,002h,070h,080h,04ah,063h,060h,063h	; 65b2  ..p.Jc`c
	defb 001h,002h,005h,071h,040h,07fh,063h,093h	; 65ba  ...q@.c.
	defb 063h,0a9h,063h,0bch,063h,0c7h,063h,001h	; 65c2  c.c.c.c.
	defb 002h,005h,073h,000h,002h,064h,0e4h,063h	; 65ca  ..s..d.c
	defb 0e4h,063h,0e4h,063h,002h,064h,002h,003h	; 65d2  .c.c.d..
	defb 002h,050h,020h,000h,0f9h,020h,0f9h,003h	; 65da  .P .. ..
	defb 001h,053h,0a0h,060h,0f9h,004h,003h,001h	; 65e2  .S.`....
	defb 051h,040h,0d8h,0e2h,004h,052h,000h,010h	; 65ea  Q@...R..
	defb 0d4h,063h,003h,001h,052h,080h,040h,0e9h	; 65f2  .c..R.@.
	defb 004h,052h,0c0h,008h,0dch,063h,005h,004h	; 65fa  .R...c..
	defb 053h,000h,004h,013h,064h,004h,053h,020h	; 6602  S...d.S 
	defb 004h,0f2h,063h,003h,001h,053h,040h,020h	; 660a  ..c..S@ 
	defb 069h,004h,053h,060h,004h,0fah,063h,004h	; 6612  i.S`..c.
	defb 053h,080h,004h,013h,064h	; 661a

; ----------------------------------------------------------------------
; DATOS pantallas_de_jabalina_y_altura: Lista de guiones largos: el pasillo,
;   el liston y el fondo de las dos pruebas de distancia.
;   0x661f..0x670e  (239 bytes)
DATA_pantallas_de_jabalina_y_altura:
	defb 008h,001h,000h,001h,069h,000h,010h,011h	; 661f  ....i...
	defb 006h,000h,0dbh,0dbh,011h,008h,0c0h,002h	; 6627  ........
	defb 002h,001h,06bh,0c0h,01bh,064h,001h,001h	; 662f  ..k..d..
	defb 06eh,0e0h,010h,019h,01eh,016h,0ffh,001h	; 6637  n.......
	defb 003h,003h,048h,0f0h,016h,055h,002h,097h	; 663f  ..H..U..
	defb 008h,0f5h,002h,003h,005h,04ah,080h,000h	; 6647  .....J..
	defb 0f5h,000h,0f5h,000h,0f5h,000h,0f5h,040h	; 664f  .......@
	defb 0f5h,003h,001h,04eh,0e0h,020h,091h,001h	; 6657  ...N. ..
	defb 002h,005h,070h,030h,002h,064h,089h,064h	; 665f  ..p0.d.d
	defb 089h,064h,089h,064h,089h,064h,002h,000h	; 6667  .d.d.d..
	defb 001h,071h,060h,018h,011h,008h,0c0h,000h	; 666f  .q`.....
	defb 000h,011h,00eh,0ffh,000h,001h,075h,0b0h	; 6677  ......u.
	defb 040h,011h,004h,000h,07fh,0ffh,011h,00ch	; 667f  @.......
	defb 0c0h,0ffh,07fh,011h,008h,000h,0ffh,0ffh	; 6687  ........
	defb 011h,004h,000h,0ffh,0ffh,011h,008h,000h	; 668f  ........
	defb 0feh,0ffh,003h,003h,063h,093h,093h,063h	; 6697  ....c..c
	defb 011h,006h,003h,0ffh,0feh,000h,000h,000h	; 669f  ........
	defb 000h,007h,004h,050h,020h,002h,091h,064h	; 66a7  ...P ..d
	defb 004h,050h,030h,004h,013h,064h,004h,050h	; 66af  .P0..d.P
	defb 050h,008h,091h,064h,004h,050h,090h,008h	; 66b7  P..d.P..
	defb 099h,064h,004h,050h,0d0h,008h,0a1h,064h	; 66bf  .d.P...d
	defb 004h,051h,010h,008h,0a9h,064h,003h,003h	; 66c7  .Q...d..
	defb 051h,050h,010h,055h,008h,0f5h,010h,0afh	; 66cf  QP.U....
	defb 002h,000h,001h,054h,0c0h,020h,044h,011h	; 66d7  ...T. D.
	defb 004h,077h,055h,077h,055h,077h,055h,055h	; 66df  .wUwUwUU
	defb 077h,055h,055h,077h,055h,044h,055h,055h	; 66e7  wUUwUDUU
	defb 055h,044h,044h,055h,044h,055h,011h,007h	; 66ef  UDDUDU..
	defb 044h,003h,009h,055h,0b0h,006h,075h,00ch	; 66f7  D..U..u.
	defb 070h,00ch,075h,004h,000h,00ch,075h,00ch	; 66ff  p.u...u.
	defb 070h,006h,075h,006h,055h,002h,099h	; 6707

; ----------------------------------------------------------------------
; DATOS marcador_de_la_jabalina: Guion corto del marcador del lanzamiento.
;   0x670e..0x674e  (64 bytes)
DATA_marcador_de_la_jabalina:
	defb 079h,060h,0feh,0a0h,0a0h,0feh,014h,02ah	; 670e  y`.....*
	defb 0b6h,0b9h,0b9h,0bbh,0feh,008h,02ah,0feh	; 6716  ......*.
	defb 014h,02ah,0b7h,0f2h,0f0h,0bch,0feh,008h	; 671e  .*......
	defb 02ah,0feh,014h,02ah,0b8h,0bah,0bah,0bdh	; 6726  *..*....
	defb 0feh,008h,02ah,0feh,020h,00ah,0feh,020h	; 672e  ..*. .. 
	defb 012h,0feh,020h,01ah,0feh,020h,022h,000h	; 6736  .. .. ".
	defb 0e8h,0e9h,0eah,0eah,0ebh,0efh,0feh,014h	; 673e  ........
	defb 000h,0ech,0edh,0eeh,0fah,0fbh,0ffh,0ffh	; 6746  ........

; ----------------------------------------------------------------------
; DATOS marcador_del_salto_de_altura: Guion corto del marcador del salto.
;   0x674e..0x67a4  (86 bytes)
DATA_marcador_del_salto_de_altura:
	defb 079h,060h,0feh,076h,0a0h,020h,0feh,01fh	; 674e  y`.v. ..
	defb 0a0h,021h,021h,0feh,008h,0a0h,0feh,004h	; 6756  .!!.....
	defb 02bh,0b6h,0b9h,0b9h,0bbh,0feh,00eh,02bh	; 675e  +......+
	defb 02ch,02ch,0feh,00ch,02bh,0b7h,0f9h,0f0h	; 6766  ,,..+...
	defb 0bch,0feh,00eh,02bh,02ch,02ch,0feh,007h	; 676e  ...+,,..
	defb 02dh,0feh,005h,02bh,0b8h,0bah,0bah,0bdh	; 6776  -..+....
	defb 0feh,00eh,02bh,02ch,02ch,0feh,007h,02eh	; 677e  ..+,,...
	defb 02bh,0feh,020h,098h,0feh,020h,099h,0feh	; 6786  +. .. ..
	defb 020h,09ah,0feh,020h,09bh,000h,0e8h,0e9h	; 678e   .. ....
	defb 0eah,0eah,0ebh,0efh,0feh,014h,000h,0ech	; 6796  ........
	defb 0edh,0eeh,0fah,0fbh,0ffh,0ffh	; 679e

; ----------------------------------------------------------------------
; DATOS pizarra_de_las_110_vallas: Guion largo de una orden: pone "110
;   HURDLERS" en la pizarra.
;   0x67a4..0x67ab  (7 bytes)
DATA_pizarra_de_las_110_vallas:
	defb 001h,002h,001h,06dh,040h,0b1h,064h	; 67a4

; ----------------------------------------------------------------------
; DATOS pizarra_del_salto_de_altura: Guion largo de una orden: "HIGH JUMP".
;   0x67ab..0x67b2  (7 bytes)
DATA_pizarra_del_salto_de_altura:
	defb 001h,002h,001h,06dh,000h,0d2h,064h	; 67ab

; ----------------------------------------------------------------------
; DATOS pizarra_de_la_jabalina: Guion largo de una orden: "JAVELIN THROW".
;   0x67b2..0x67b9  (7 bytes)
DATA_pizarra_de_la_jabalina:
	defb 001h,002h,001h,06dh,000h,0c1h,064h	; 67b2

; ----------------------------------------------------------------------
; DATOS pizarra_de_los_1500_metros: Guion largo de una orden: "1500 METER".
;   0x67b9..0x67c0  (7 bytes)
DATA_pizarra_de_los_1500_metros:
	defb 001h,002h,001h,06dh,040h,0dfh,064h	; 67b9

; ----------------------------------------------------------------------
; DATOS marcador_de_las_110_vallas: Guion corto del marcador de las pruebas de
;   tiempo; lo comparten las vallas y los 1500.
;   0x67c0..0x680a  (74 bytes)
DATA_marcador_de_las_110_vallas:
	defb 079h,060h,0feh,021h,0a8h,0eeh,0eeh,0eeh	; 67c0  y`.!....
	defb 0feh,03ch,0a8h,0feh,020h,063h,0feh,020h	; 67c8  .<.. c. 
	defb 067h,06bh,06bh,0f2h,0fch,0e9h,0feh,01bh	; 67d0  gkk.....
	defb 06bh,0feh,020h,06fh,000h,0f2h,0fch,0e9h	; 67d8  k. o....
	defb 0feh,005h,000h,0ech,0edh,0eeh,0fah,0fbh	; 67e0  ........
	defb 0feh,004h,000h,0f1h,0fch,0e9h,0feh,005h	; 67e8  ........
	defb 000h,0ech,0edh,0eeh,0fah,0fbh,000h,0feh	; 67f0  ........
	defb 040h,063h,0feh,020h,067h,06bh,06bh,0f1h	; 67f8  @c. gkk.
	defb 0fch,0e9h,0feh,01bh,06bh,0feh,020h,06fh	; 6800  ....k. o
	defb 0ffh,0ffh	; 6808

; ======================================================================
; CODIGO 0x680a..0x6bc2  (952 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  MOTOR DEL LANZAMIENTO DE JABALINA  ==========
; Aqui el atleta corre, salta y cae. La carrera reaprovecha el motor de
; las 110 vallas; lo propio de la prueba es el tiro, que sale del trozo
; de 0x7D2B, y la caida.
; ----------------------------------------------------------------------
MOTOR_DE_LA_JABALINA:
	ld a,(0e02eh)		;680a
	bit 1,a		;680d   ; bit 1 de 0xE02E: la prueba ya acabo
	ret nz			;680f
	ld a,(0e207h)		;6810   ; bit 2 de 0xE020: el salto esta en el aire
	cp 001h		;6813
	jp z,ESPERA_A_QUE_ACABE_EL_GOLPE		;6815
	cp 002h		;6818
	jp z,MIRA_EL_RESULTADO		;681a
	call CUENTA_EL_ANGULO		;681d
	call SUBE_EL_PATRON_DEL_OBJETO		;6820
	jp nz,JABALINA_EN_EL_AIRE		;6823
	ld a,(0e02ch)		;6826   ; bit 0 de 0xE02C: el intento ha terminado
	rrca			;6829

; ----------------------------------------------------------------------
; ==========  MOTOR DE LA JABALINA  ==========
; Igual que el salto del cartucho hermano: se corre, se marca el angulo
; con el boton y se suelta. La jabalina vuela con el trozo de 0x7D2B, y
; el patron que se le sube (0x789E) cambia con la inclinacion.
; ----------------------------------------------------------------------
	jr nc,CORRE_CON_LA_JABALINA		;682a
	ld de,07b00h		;682c   ; la fila de sprites del objeto
	ld b,002h		;682f   ; dos sprites
ESCONDE_EL_OBJETO:
	call FIJA_ESCRITURA_CON_CANDADO		;6831
	ld a,(00006h)		;6834
	ld c,a			;6837
	ld a,0cfh		;6838   ; fila 0xCF, o sea fuera de la pantalla
	out (c),a		;683a
	ld de,07b04h		;683c   ; y el siguiente
	djnz ESCONDE_EL_OBJETO		;683f
	jp PASA_A_LA_FASE_1		;6841
CORRE_CON_LA_JABALINA:
	call GASTA_LA_VELOCIDAD_DEL_QUE_JUEGA		;6844   ; cuenta el angulo con el boton
	ld hl,02014h		;6847   ; sonido de fondo de la carrerilla
	ld (0e032h),hl		;684a
	call FICHA_DEL_QUE_JUEGA		;684d   ; la ficha del que juega
	ld de,0e208h		;6850   ; la posicion de la jabalina
	ld a,(hl)			;6853
	add a,0f5h		;6854   ; once columnas por delante del atleta
	ld (de),a			;6856
	inc hl			;6857
	inc de			;6858
	ld a,(hl)			;6859
	add a,0fbh		;685a   ; y cinco filas por encima
	ld (de),a			;685c
	ld de,07900h		;685d   ; la fila de sprites del objeto
	call SUBE_EL_OBJETO		;6860
	call POSTURA_DEL_QUE_JUEGA		;6863   ; la postura del atleta
	ld a,(hl)			;6866
	sub 006h		;6867   ; las posturas 6 a 11 llevan jabalina en la mano
	cp 006h		;6869
	jr nc,MIRA_EL_SUELTE		;686b
	ld hl,07910h		;686d   ; la tabla de patrones del atleta con jabalina
	rlca			;6870
	call SUMA_A_A_HL		;6871
	ld e,(hl)			;6874
	inc hl			;6875
	ld d,(hl)			;6876
	ex de,hl			;6877
	ld de,05880h		;6878   ; los patrones del jugador 1
	ld a,b			;687b
	or a			;687c
	jr nz,SUBE_EL_ATLETA_CON_JABALINA		;687d
	ld de,05960h		;687f   ; o los del 2
SUBE_EL_ATLETA_CON_JABALINA:
	call SUBE_UN_PATRON_DE_SPRITE		;6882
MIRA_EL_SUELTE:
	call SUBE_EL_PATRON_DEL_OBJETO		;6885   ; sube el patron de la jabalina
	ret z			;6888
	ld hl,(0e208h)		;6889   ; la posicion del tiro
	ld (0e201h),hl		;688c
	ld hl,(0e0e8h)		;688f   ; la marca del jugador 2
	ld de,0026ch		;6892   ; pasada la columna 0x26C
	or a			;6895
	sbc hl,de		;6896
	ret c			;6898
	jp SE_ACABO_LA_TABLA		;6899   ; se acaba la carrerilla
JABALINA_EN_EL_AIRE:
	call CORRE_Y_LANZA		;689c   ; mueve el vuelo
	ret c			;689f   ; mientras vuele, aqui se sigue
	ld a,04eh		;68a0   ; sonido 0x4E: la clavada
	call PIDE_UN_SONIDO		;68a2
	xor a			;68a5
	ld (0e190h),a		;68a6   ; musica normal otra vez
PASA_A_LA_FASE_1:
	ld a,001h		;68a9
	ld (0e207h),a		;68ab
ESPERA_A_QUE_ACABE_EL_GOLPE:
	ld a,(0e178h)		;68ae   ; mientras el canal 3 suene, se espera
	or a			;68b1
	ret nz			;68b2
	ld a,002h		;68b3   ; fase 2
	ld (0e207h),a		;68b5
	call PREPARA_LA_ANIMACION_FINAL		;68b8   ; y a la animacion final
MIRA_EL_RESULTADO:
	ld a,(0e02ah)		;68bb   ; sin resultado no hay animacion
	or a			;68be
	ret z			;68bf
	jp ANIMA_EL_FINAL_DEL_SALTO		;68c0
ELIGE_EL_PATRON_DE_LA_JABALINA:
	ld hl,0e106h		;68c3   ; la velocidad vertical del tiro
	ld d,(hl)			;68c6
	inc hl			;68c7
	ld e,(hl)			;68c8
	ld b,000h		;68c9
	bit 7,d		;68cb   ; con el bit alto puesto, la jabalina baja
	jr z,REPARTE_LA_INCLINACION		;68cd
	ld a,002h		;68cf   ; modo 2 de la musica: el silbido
	ld (0e190h),a		;68d1
	xor a			;68d4
	inc b			;68d5
	ld l,a			;68d6
	ld h,a			;68d7
	sbc hl,de		;68d8   ; se le quita el signo
	ex de,hl			;68da
REPARTE_LA_INCLINACION:
	ld hl,020f3h		;68db   ; por encima de 0x20F3 va casi vertical
	ld a,002h		;68de
	sbc hl,de		;68e0
	jr c,AJUSTA_LA_INCLINACION		;68e2
	ld hl,00cd2h		;68e4   ; y por debajo de 0x0CD2, casi horizontal
	xor a			;68e7
	sbc hl,de		;68e8
	jr nc,SUBE_EL_PATRON_QUE_TOCA		;68ea
	inc a			;68ec
AJUSTA_LA_INCLINACION:
	bit 0,b		;68ed   ; bajando, los patrones van dos mas alla
	jr z,SUBE_EL_PATRON_QUE_TOCA		;68ef
	add a,002h		;68f1
SUBE_EL_PATRON_QUE_TOCA:
	ld (0e20ah),a		;68f3   ; el patron elegido
	ld a,(0e20ah)		;68f6
	ld hl,0789eh		;68f9   ; la tabla de patrones del objeto
	rlca			;68fc
	call SUMA_A_A_HL		;68fd
	ld e,(hl)			;6900
	inc hl			;6901
	ld d,(hl)			;6902
SUBE_EL_OBJETO:
	ld hl,05800h		;6903   ; al hueco de sprite de 0x1800
	ex de,hl			;6906
	call SUBE_UN_PATRON_DE_SPRITE		;6907
	ld de,07b00h		;690a   ; la fila de atributos del objeto
	ld bc,0e208h		;690d   ; la posicion del objeto
	exx			;6910
	ld a,(00006h)		;6911   ; el puerto de datos del VDP
	ld c,a			;6914
	exx			;6915
	ld a,002h		;6916   ; dos sprites, que la jabalina ocupa dos
UN_SPRITE_DE_LA_JABALINA:
	push af			;6918
	call FIJA_ESCRITURA_CON_CANDADO		;6919
	ld a,(bc)			;691c   ; la fila, sumada a la de la lista
	add a,(hl)			;691d
	exx			;691e
	out (c),a		;691f
	exx			;6921
	inc hl			;6922
	inc bc			;6923
	ld a,(bc)			;6924   ; la columna, igual
	add a,(hl)			;6925
	exx			;6926
	out (c),a		;6927
	exx			;6929
	inc hl			;692a
	dec bc			;692b
	inc de			;692c
	inc de			;692d
	inc de			;692e
	inc de			;692f
	xor a			;6930   ; y el patron 0, que es el que se acaba de subir
	exx			;6931
	out (c),a		;6932
	exx			;6934
	pop af			;6935
	dec a			;6936
	jr nz,UN_SPRITE_DE_LA_JABALINA		;6937
	ret			;6939
CORRE_Y_LANZA:
	ld a,(0e200h)		;693a   ; con 0xE200 puesto ya esta lanzada
	or a			;693d
	jr nz,SUENA_EL_LANZAMIENTO		;693e
	call POSTURA_DEL_QUE_JUEGA		;6940   ; postura 9, la de correr con la jabalina
	ld (hl),009h		;6943
	call BOTON_DEL_QUE_JUEGA		;6945   ; el boton del que juega
	bit 1,(hl)		;6948   ; bit 1: han soltado
	jr z,SUELTA_LA_JABALINA		;694a
	ld hl,0e033h		;694c
	ld a,(hl)			;694f   ; el angulo, en BCD
	add a,001h		;6950
	daa			;6952
	ld (hl),a			;6953
	dec hl			;6954
	ld a,(hl)			;6955   ; y su cuenta en binario
	inc a			;6956
	ld (hl),a			;6957
	cp 050h		;6958   ; el tope son 50 grados
	jr c,SUENA_EL_LANZAMIENTO		;695a
SUELTA_LA_JABALINA:
	ld a,001h		;695c
	ld (0e200h),a		;695e
SUENA_EL_LANZAMIENTO:
	ld a,(0e178h)		;6961   ; si el canal 3 esta libre
	or a			;6964
	jr nz,AVANZA_LA_JABALINA		;6965
	ld a,001h		;6967   ; suena el sonido 1
	call PIDE_UN_SONIDO		;6969
AVANZA_LA_JABALINA:
	exx			;696c
	ld bc,06660h		;696d   ; sonido de fondo del vuelo
	ld d,01ch		;6970
	exx			;6972
	ld a,(0e000h)		;6973   ; solo en los cuadros impares
	rrca			;6976
	jr nc,MIRA_SI_TERMINA_EL_VUELO		;6977
	call AVANZA_EL_TIRO		;6979   ; avanza el tiro
	ld hl,(0e0e8h)		;697c
	ld de,0026ch		;697f
	or a			;6982
	sbc hl,de		;6983
	jr nc,CLAVA_LA_JABALINA_EN_EL_SUELO		;6985
	xor a			;6987
	ld h,a			;6988
	ld l,a			;6989
	ld (0e110h),hl		;698a
	ld (0e110h),a		;698d
CLAVA_LA_JABALINA_EN_EL_SUELO:
	call FICHA_DEL_QUE_JUEGA		;6990   ; la ficha del que juega
	ex de,hl			;6993
	ld hl,0e117h		;6994   ; la altura de este cuadro
	ld a,(de)			;6997
	cp 0cfh		;6998   ; con la fila en 0xCF ya esta clavada en el suelo
	jr z,SUMA_EL_AVANCE_DEL_VUELO		;699a
	inc de			;699c
	ld a,(de)			;699d
	sub (hl)			;699e
	ld (de),a			;699f
	jr nc,SUMA_EL_AVANCE_DEL_VUELO		;69a0
	dec de			;69a2
	ld a,0cfh		;69a3
	ld (de),a			;69a5
SUMA_EL_AVANCE_DEL_VUELO:
	ld de,0e141h		;69a6   ; la columna del primer objeto
	ld a,(de)			;69a9
	add a,(hl)			;69aa
	ld (de),a			;69ab
	ld hl,0e201h		;69ac
	ld a,(0e116h)		;69af   ; el contador del vuelo
	sub (hl)			;69b2
	neg		;69b3
	ld (0e208h),a		;69b5   ; da la columna del atleta
	cp 0c0h		;69b8   ; fuera del tramo 0x90..0xBF
	jr nc,CAMBIA_EL_PATRON_EN_VUELO		;69ba
	cp 090h		;69bc
	jr nc,GUARDA_EL_AVANCE_DEL_VUELO		;69be
CAMBIA_EL_PATRON_EN_VUELO:
	call ELIGE_EL_PATRON_DE_LA_JABALINA		;69c0   ; se cambia el patron de la jabalina
GUARDA_EL_AVANCE_DEL_VUELO:
	ld a,(0e02ch)		;69c3
	rrca			;69c6   ; bit 0 de 0xE02C: intento acabado
	jr c,MIRA_SI_TERMINA_EL_VUELO		;69c7
	ld hl,(0e11ah)		;69c9
	ld (0e030h),hl		;69cc
MIRA_SI_TERMINA_EL_VUELO:
	call PINTA_A_LOS_DOS_ATLETAS		;69cf   ; pinta a los dos atletas
	ld a,(0e116h)		;69d2   ; el avance acumulado
	cp 0e0h		;69d5   ; por debajo de 0xE0 aun vuela
	ret c			;69d7
	cp 0f0h		;69d8   ; y por encima de 0xF0 tampoco ha caido
	ccf			;69da
	ret			;69db
CUENTA_EL_ANGULO:
	call BOTON_DEL_QUE_JUEGA		;69dc   ; el boton del que juega
	ld a,(0e017h)		;69df   ; en la demo no se hace caso al boton
	or a			;69e2
	ld a,000h		;69e3
	jr nz,GUARDA_LA_PULSACION		;69e5
	ld a,(hl)			;69e7
GUARDA_LA_PULSACION:
	ld (0e0c5h),a		;69e8   ; queda apuntado
	ret			;69eb
GASTA_LA_VELOCIDAD_DEL_QUE_JUEGA:
	ld hl,0e0adh		;69ec   ; gasta la velocidad
	call GASTA_Y_APUNTA		;69ef
	ld de,0e0b8h		;69f2   ; y la convierte en avance
	call MULTIPLICA_LA_VELOCIDAD		;69f5
	call PINTA_A_LOS_DOS_ATLETAS		;69f8   ; pinta a los dos atletas
MUEVE_LA_TABLA_DE_BATIDA:
	ld a,(0e000h)		;69fb
	rrca			;69fe   ; solo en los cuadros pares
	ret c			;69ff
	call BOTON_DEL_QUE_JUEGA		;6a00   ; el boton del que juega
	ld a,(hl)			;6a03
	ld hl,0e21eh		;6a04   ; la cuenta de la tabla
	or a			;6a07
	jr z,GASTA_LA_CUENTA		;6a08   ; con el boton pulsado se reinicia
	xor a			;6a0a
	ld (hl),a			;6a0b
	inc hl			;6a0c
	ld (hl),a			;6a0d
	dec hl			;6a0e
GASTA_LA_CUENTA:
	dec (hl)			;6a0f
	ret nz			;6a10   ; mientras quede, nada
	inc hl			;6a11
	ld a,(hl)			;6a12   ; la fase de la tabla
	or a			;6a13
	jr nz,SE_ACABO_LA_TABLA		;6a14
	ld (hl),001h		;6a16   ; primera fase
	dec hl			;6a18
	ld (hl),040h		;6a19   ; 0x40 cuadros
	ld a,004h		;6a1b   ; sonido 4: el crujido de la tabla
	jp PIDE_UN_SONIDO		;6a1d
SE_ACABO_LA_TABLA:
	ld hl,0e02ch		;6a20
	set 0,(hl)		;6a23   ; bit 0 de 0xE02C: intento acabado
	ret			;6a25
SUBE_EL_PATRON_DEL_OBJETO:
	ld a,(0e020h)		;6a26
	bit 2,a		;6a29
	ret			;6a2b

; ----------------------------------------------------------------------
; ==========  MOTOR DEL SALTO DE ALTURA  ==========
; El atleta toma carrera, y al soltar el boton salta con el angulo que
; marque la flecha. La trayectoria la calcula el mismo trozo de 0x7D2B
; que la jabalina: es el motor que en el cartucho hermano movia el
; martillo, reaprovechado aqui para el salto de altura.
; ----------------------------------------------------------------------
MOTOR_DEL_SALTO_DE_ALTURA:
	ld a,(0e02eh)		;6a2c
	bit 1,a		;6a2f   ; bit 1 de 0xE02E: la prueba ya acabo
	ret nz			;6a31
	ld a,(0e017h)		;6a32   ; con 0xE206 puesto ya esta lanzando
	or a			;6a35
	jr nz,MIRA_LA_FASE_DEL_LANZAMIENTO		;6a36
	ld hl,0e21ch		;6a38   ; el liston empieza en fila 0x88, columna 0x30
	ld a,(hl)			;6a3b
	or a			;6a3c
	jr nz,MIRA_LA_FASE_DEL_LANZAMIENTO		;6a3d
	push hl			;6a3f
	call BOTON_DEL_QUE_JUEGA		;6a40   ; el boton del que juega
	bit 0,(hl)		;6a43   ; sin pulsar no se lanza
	pop hl			;6a45
	jr z,MIRA_LA_FASE_DEL_LANZAMIENTO		;6a46
	ld (hl),001h		;6a48
	ld hl,0e0aeh		;6a4a   ; velocidad inicial 0x05F4, distancia 1
	ld (hl),005h		;6a4d
	inc hl			;6a4f
	ld (hl),0f4h		;6a50
	inc hl			;6a52
	ld (hl),001h		;6a53
MIRA_LA_FASE_DEL_LANZAMIENTO:
	ld a,(0e200h)		;6a55   ; la fase
	dec a			;6a58
	jr z,MIRA_EL_IMPULSO		;6a59
	dec a			;6a5b
	jp z,MIRA_EL_RESULTADO_DEL_SALTO		;6a5c   ; fase 2: ya cayo
	ld a,(0e02ch)		;6a5f   ; bit 0 de 0xE02C
	rrca			;6a62
	jp c,MIRA_EL_RESULTADO_DEL_SALTO		;6a63
	call CUENTA_EL_ANGULO		;6a66
	call GASTA_LA_VELOCIDAD_DEL_QUE_JUEGA		;6a69
	call SUBE_EL_PATRON_DEL_OBJETO		;6a6c
	ret z			;6a6f
	ld a,001h		;6a70
	ld (0e200h),a		;6a72
	call FICHA_DEL_QUE_JUEGA		;6a75
	ld e,(hl)			;6a78
	inc hl			;6a79
	ld d,(hl)			;6a7a
	ld (0e204h),de		;6a7b
	ld hl,0905ah		;6a7f
	ld (0e032h),hl		;6a82
	ld a,080h		;6a85
	ld (0e208h),a		;6a87
	ld a,04eh		;6a8a
	jp PIDE_UN_SONIDO		;6a8c
MIRA_EL_IMPULSO:
	call BOTON_DEL_QUE_JUEGA		;6a8f   ; el boton del que juega
	bit 1,(hl)		;6a92   ; bit 1: siguen apretando
	jr z,MUEVE_EL_SALTO_DE_ALTURA		;6a94
	ld hl,0e032h		;6a96   ; la vuelta que lleva
	ld a,(hl)			;6a99   ; el impulso acumulado
	cp 015h		;6a9a
	jr c,MUEVE_EL_SALTO_DE_ALTURA		;6a9c   ; por debajo de 0x15 ya no baja mas
	dec (hl)			;6a9e   ; y se va gastando, en binario y en BCD
	inc hl			;6a9f
	ld a,(hl)			;6aa0
	dec a			;6aa1
	daa			;6aa2
	ld (hl),a			;6aa3
MUEVE_EL_SALTO_DE_ALTURA:
	ld a,(0e201h)		;6aa4   ; la fase del salto
	rlca			;6aa7
	jp c,GASTA_LA_CAIDA		;6aa8   ; bit 7: ya ha caido
	rlca			;6aab   ; bit 6: esta en el aire
	jp c,CUENTA_LA_VUELTA		;6aac
	ld a,(0e000h)		;6aaf
	rrca			;6ab2   ; solo en los cuadros pares
	ret nc			;6ab3
	exx			;6ab4
	ld bc,07f25h		;6ab5   ; sonido de fondo del salto
	ld d,050h		;6ab8
	exx			;6aba
	call AVANZA_EL_TIRO		;6abb   ; avanza la parabola
	call COLUMNA_DEL_QUE_JUEGA		;6abe   ; la columna del que juega
	ex de,hl			;6ac1
ACABA_EL_INTENTO:
	ld hl,0e205h		;6ac2   ; la altura acumulada
	ld a,(de)			;6ac5
	cp 0d2h		;6ac6   ; pasada la columna 0xD2 ya no avanza mas
	jr nc,SUMA_LA_ALTURA_DEL_CUADRO		;6ac8
	ld a,(0e114h)		;6aca   ; y se le suma el avance del cuadro
	add a,(hl)			;6acd
	ld (de),a			;6ace
SUMA_LA_ALTURA_DEL_CUADRO:
	dec hl			;6acf
	dec de			;6ad0
	ld a,(0e116h)		;6ad1   ; la altura de este cuadro, cambiada de signo
	neg		;6ad4
	add a,(hl)			;6ad6
	ld (de),a			;6ad7
	ld hl,0e106h		;6ad8   ; la velocidad vertical
	ld d,(hl)			;6adb
	inc hl			;6adc
	ld e,(hl)			;6add
	ld a,00fh		;6ade
	bit 7,d		;6ae0   ; con el bit alto puesto, el atleta baja
	jr nz,CORTE_BAJANDO		;6ae2
	ld hl,00500h		;6ae4   ; subiendo, el corte esta en 0x0500
	jr COMPARA_CON_EL_CORTE		;6ae7
CORTE_BAJANDO:
	ld hl,0fc00h		;6ae9   ; y bajando, en 0xFC00
	inc a			;6aec
COMPARA_CON_EL_CORTE:
	sbc hl,de		;6aed
	jr c,GUARDA_LA_POSTURA_DEL_VUELO		;6aef
	inc a			;6af1
GUARDA_LA_POSTURA_DEL_VUELO:
	ld (0e203h),a		;6af2   ; de ahi sale la postura del vuelo
	push af			;6af5
	call POSTURA_DEL_QUE_JUEGA		;6af6   ; la postura del que juega
	pop af			;6af9
	push hl			;6afa
	call GUARDA_LA_POSTURA		;6afb
	pop hl			;6afe
	ld a,(hl)			;6aff
	sub 00fh		;6b00   ; quince posturas mas abajo
	rlca			;6b02
	rlca			;6b03
	ex de,hl			;6b04
	ld hl,06bc2h		;6b05   ; la tabla de desplazamientos del salto
	call SUMA_A_A_HL		;6b08
	ld b,002h		;6b0b   ; dos pares por postura
	dec de			;6b0d
	ld a,(de)			;6b0e
COLOCA_EL_SPRITE_DEL_SALTO:
	cp (hl)			;6b0f   ; compara la fila con la del liston
	jr c,MIRA_SI_HA_PASADO_EL_LISTON		;6b10
	inc hl			;6b12   ; y con la columna, para saber si lo ha tirado
	cp (hl)			;6b13
	jr nc,MIRA_SI_HA_PASADO_EL_LISTON		;6b14
	dec de			;6b16
	inc hl			;6b17
	ld a,(0e015h)		;6b18   ; la ronda entra en la cuenta de la fila
	ld c,a			;6b1b
	ld a,(de)			;6b1c
	add a,c			;6b1d
	djnz COLOCA_EL_SPRITE_DEL_SALTO		;6b1e
	ld hl,0e201h		;6b20
	set 1,(hl)		;6b23   ; la marca que se acaba de saltar
	ld hl,0e208h		;6b25
	bit 7,(hl)		;6b28
	jr z,MIRA_SI_HA_PASADO_EL_LISTON		;6b2a
	ld (hl),020h		;6b2c
	ld de,079d6h		;6b2e
	call FIJA_ESCRITURA_CON_CANDADO		;6b31
	ld a,(00006h)		;6b34
	ld c,a			;6b37
	ld a,0a0h		;6b38
	out (c),a		;6b3a
	ld de,07a19h		;6b3c
	call FIJA_ESCRITURA_CON_CANDADO		;6b3f
	ld a,0beh		;6b42
	out (c),a		;6b44
	ld a,005h		;6b46
	call PIDE_UN_SONIDO		;6b48
MIRA_SI_HA_PASADO_EL_LISTON:
	call COLUMNA_DEL_QUE_JUEGA		;6b4b   ; la columna del que juega
	ld a,(hl)			;6b4e
	cp 0b0h		;6b4f   ; pasada la columna 0xB0
	jr c,MIRA_LA_CAIDA_DEL_SALTO		;6b51
	ld hl,0e201h		;6b53
	set 0,(hl)		;6b56   ; bit 0 de 0xE201: ya esta al otro lado
MIRA_LA_CAIDA_DEL_SALTO:
	ld a,(0e203h)		;6b58   ; la postura del vuelo
	cp 011h		;6b5b   ; solo la 0x11 cuenta como caida
	ret nz			;6b5d
	call FICHA_DEL_QUE_JUEGA		;6b5e   ; la ficha del que juega
	ld a,(0e201h)		;6b61   ; bit 0: viene del otro lado del liston
	rrca			;6b64
	ld a,(hl)			;6b65
	jr nc,MARGEN_SUBIENDO		;6b66
	cp 074h		;6b68   ; cayendo se admite hasta la fila 0x74
	jr nc,CIERRA_EL_SALTO		;6b6a
	ret			;6b6c
MARGEN_SUBIENDO:
	cp 082h		;6b6d   ; y subiendo, hasta la 0x82
	ret c			;6b6f
CIERRA_EL_SALTO:
	ld a,(0e201h)		;6b70   ; la fase del salto
	and 003h		;6b73
	cp 001h		;6b75   ; si no es la 1, el intento se da por acabado
	call nz,SE_ACABO_LA_TABLA		;6b77
	ld hl,0e201h		;6b7a
	set 7,(hl)		;6b7d   ; bit 7 de 0xE201: se acabo el salto
	inc hl			;6b7f
	ld (hl),020h		;6b80
	ld a,093h		;6b82
	jp PIDE_UN_SONIDO		;6b84
GASTA_LA_CAIDA:
	ld hl,0e202h		;6b87
	dec (hl)			;6b8a   ; la cuenta
	ret nz			;6b8b
	ld (hl),020h		;6b8c   ; 0x20 cuadros por figura
	dec hl			;6b8e
	res 7,(hl)		;6b8f
	set 6,(hl)		;6b91
	call COLUMNA_DEL_QUE_JUEGA		;6b93
	ld a,(hl)			;6b96
	add a,008h		;6b97   ; ocho columnas
GUARDA_LA_POSTURA:
	ld (hl),a			;6b99
	ld a,b			;6b9a
	jp PINTA_AL_ATLETA		;6b9b
CUENTA_LA_VUELTA:
	ld hl,0e202h		;6b9e   ; la cuenta del giro
	dec (hl)			;6ba1
	ret nz			;6ba2
	dec hl			;6ba3
	dec hl			;6ba4
	ld (hl),002h		;6ba5
	call FICHA_DEL_QUE_JUEGA		;6ba7
	ld (hl),078h		;6baa
	ret			;6bac
MIRA_EL_RESULTADO_DEL_SALTO:
	ld a,(0e02ah)		;6bad   ; la vuelta que lleva
	or a			;6bb0
	jr z,PREPARA_LA_ANIMACION_FINAL		;6bb1
ANIMA_EL_FINAL_DEL_SALTO:
	call CUENTA_DE_ANIMACION		;6bb3
	ld a,(0e02ah)		;6bb6
	jp ANIMA_LA_LLEGADA		;6bb9
PREPARA_LA_ANIMACION_FINAL:
	call ACABA_EL_INTENTO_Y_ANIMA		;6bbc
	ld (hl),080h		;6bbf
	ret			;6bc1

; ----------------------------------------------------------------------
; DATOS salto_del_atleta: Seis pares de desplazamiento que 0x6B05 suma a la
;   posicion del atleta mientras esta en el aire.
;   0x6bc2..0x6bce  (12 bytes)
DATA_salto_del_atleta:
	defb 0a4h,0b0h	; 6bc2
	defb 059h,078h	; 6bc4
	defb 096h,0ach	; 6bc6
	defb 064h,06eh	; 6bc8
	defb 096h,0a9h	; 6bca
	defb 064h,076h	; 6bcc

; ======================================================================
; CODIGO 0x6bce..0x6d16  (328 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  EL REPRODUCTOR DE SONIDO  ==========
; Tres canales de once bytes en 0xE160, 0xE16B y 0xE176. La ficha de un
; canal es: +0 cuenta de la nota, +1 duracion base, +2 numero de sonido,
; +3/+4 puntero a la tira, +5 octava, +6 caida, +7 volumen, +8 cuenta de
; la caida, +9 repeticiones que quedan, +0x0A duracion.
; El numero de sonido lleva la informacion en sus bits altos: el bit 7
; dice que la nota va en UN byte, y el bit 6 que el canal 3 se usa como
; ruido. Los seis de abajo son la PRIORIDAD: un sonido no interrumpe a
; otro de prioridad mas alta.
; ----------------------------------------------------------------------
PIDE_UN_SONIDO:
	push af			;6bce
	ld a,(0e002h)		;6bcf   ; en la demo no suena nada
	or a			;6bd2
	jr z,PIDE_UN_SONIDO_DE_VERDAD		;6bd3
	pop af			;6bd5
	ret			;6bd6
PIDE_UN_SONIDO_DE_VERDAD:
	pop af			;6bd7
	push hl			;6bd8
	push de			;6bd9
	push bc			;6bda
	push af			;6bdb
	ld d,000h		;6bdc   ; D a cero: hay que mirar la prioridad
	cp 002h		;6bde   ; el sonido 2 son tres a la vez
	jr nz,PIDE_EL_ULTIMO		;6be0
	call ENCHUFA_UN_SONIDO		;6be2   ; el suyo
	ld a,046h		;6be5
	call ENCHUFA_UN_SONIDO		;6be7
	ld a,048h		;6bea
PIDE_EL_ULTIMO:
	call ENCHUFA_UN_SONIDO		;6bec
	pop af			;6bef   ; se devuelven los registros
	pop bc			;6bf0
	pop de			;6bf1
	pop hl			;6bf2
	ret			;6bf3
ENCHUFA_UN_SONIDO:
	ld c,a			;6bf4   ; el numero de sonido
	ld b,002h		;6bf5   ; dos voces de entrada
	ld hl,0e162h		;6bf7   ; empezando por el canal 1
	cp 001h		;6bfa   ; el sonido 1 es un caso aparte
	jr z,MIRA_LA_PRIORIDAD		;6bfc
	cp 081h		;6bfe   ; por debajo de 0x81 son efectos
	jr c,REPARTE_EL_EFECTO		;6c00
	cp 093h		;6c02
	jr c,MIRA_LA_PRIORIDAD		;6c04
TRES_VOCES:
	inc b			;6c06   ; de 0x96 en adelante, tres
	jr MIRA_LA_PRIORIDAD		;6c07
REPARTE_EL_EFECTO:
	and 03fh		;6c09   ; los seis bits de la prioridad
	cp 009h		;6c0b
	jr c,UNA_VOZ		;6c0d
	cp 00bh		;6c0f
	jr c,AL_CANAL_2		;6c11
	jr TRES_VOCES		;6c13   ; y de 12 en adelante, tres
UNA_VOZ:
	dec b			;6c15   ; una sola voz
	cp 006h		;6c16   ; los cinco primeros van al canal 1
	jr c,MIRA_LA_PRIORIDAD		;6c18
	ld hl,0e178h		;6c1a   ; del 6 al 9, al canal 3
	cp 008h		;6c1d
	jr nc,MIRA_LA_PRIORIDAD		;6c1f
AL_CANAL_2:
	ld hl,0e16dh		;6c21
MIRA_LA_PRIORIDAD:
	dec d			;6c24   ; con D a uno se enchufa sin mirar
	jr z,ENCHUFA_LA_TIRA		;6c25
	ld e,(hl)			;6c27   ; el sonido que hay puesto
	ld a,e			;6c28
	and 03fh		;6c29   ; su prioridad
	ld (hl),a			;6c2b
	ld a,c			;6c2c   ; contra la del nuevo
	and 03fh		;6c2d
	cp (hl)			;6c2f
	ld (hl),e			;6c30   ; si el nuevo pierde, se queda como estaba
	ret c			;6c31
ENCHUFA_LA_TIRA:
	add a,a			;6c32   ; dos bytes por casilla; el acarreo se PIERDE, y por eso los sonidos de
	ld de,06e62h		;6c33   ; 0x81 en adelante caen en la casilla que da su numero sin el bit 7
	ex de,hl			;6c36
	call SUMA_A_A_HL		;6c37   ; la casilla de la tabla
	ex de,hl			;6c3a
	dec hl			;6c3b   ; la ficha del canal empieza dos bytes antes
	dec hl			;6c3c
MONTA_UN_CANAL:
	ld (hl),001h		;6c3d   ; cuenta y duracion a uno
	inc hl			;6c3f
	ld (hl),001h		;6c40
	inc hl			;6c42
	ld (hl),c			;6c43   ; el numero de sonido
	inc hl			;6c44
	ld a,(de)			;6c45   ; y el puntero a su tira
	ld (hl),a			;6c46
	inc hl			;6c47
	inc de			;6c48
	ld a,(de)			;6c49
	ld (hl),a			;6c4a
	ld a,006h		;6c4b   ; seis bytes mas alla
	add a,l			;6c4d
	ld l,a			;6c4e
	ld (hl),000h		;6c4f   ; va la cuenta de repeticiones, a cero
	inc hl			;6c51
	inc de			;6c52   ; y la voz siguiente se lleva la casilla siguiente
	djnz MONTA_UN_CANAL		;6c53
	ret			;6c55
MUEVE_EL_SONIDO:
	ld c,001h		;6c56   ; el canal 1 escribe en los registros 0 y 1
	ld ix,0e160h		;6c58   ; la ficha del canal 1
	exx			;6c5c
	ld b,003h		;6c5d   ; tres canales
	ld de,0000bh		;6c5f   ; once bytes por ficha
MUEVE_UN_CANAL:
	exx			;6c62
	ld a,(ix+002h)		;6c63   ; el numero de sonido
	push af			;6c66
	cp 001h		;6c67
	call z,DOBLA_LA_MELODIA		;6c69   ; el sonido 1 es la mezcla de tono y ruido
	pop af			;6c6c
	or a			;6c6d
	call nz,MUEVE_UNA_VOZ		;6c6e   ; con sonido puesto, se mueve
	inc c			;6c71   ; dos registros por canal
	inc c			;6c72
	exx			;6c73
	add ix,de		;6c74
	djnz MUEVE_UN_CANAL		;6c76
	exx			;6c78
	ret			;6c79
MIRA_LAS_REPETICIONES:
	inc hl			;6c7a
	ld a,(ix+009h)		;6c7b   ; las que lleva
	inc a			;6c7e
	cp (hl)			;6c7f   ; contra las que pide la tira
	jp z,APAGA_LA_VOZ		;6c80   ; al llegar, se apaga
	jp m,REPITE_LA_TIRA		;6c83   ; la primera vez viene con el bit alto puesto
	dec a			;6c86
REPITE_LA_TIRA:
	ex af,af'			;6c87
	ld a,(ix+002h)		;6c88   ; el mismo sonido otra vez
	push bc			;6c8b
	call ENCHUFA_UN_SONIDO		;6c8c   ; se vuelve a enchufar
	pop bc			;6c8f
	ex af,af'			;6c90
	ld (ix+009h),a		;6c91   ; y se apunta una repeticion mas
	ret			;6c94
ENCIENDE_O_APAGA_LA_VOZ:
	ld a,007h		;6c95   ; el registro 7 del PSG, el mezclador
	call 00096h		;6c97   ; BIOS RDPSG - Reads value from PSG-register
	ld e,a			;6c9a
	ld a,c			;6c9b   ; el canal
	cp 001h		;6c9c   ; el 1 no se ajusta
	jr z,COLOCA_EL_BIT_DEL_CANAL		;6c9e
	dec a			;6ca0
COLOCA_EL_BIT_DEL_CANAL:
	rlca			;6ca1   ; tres desplazamientos: los bits de ruido
	rlca			;6ca2
	rlca			;6ca3
	dec d			;6ca4   ; con D a uno se apaga
	jr z,ENCIENDE_LA_VOZ		;6ca5
	cpl			;6ca7   ; y si no, se enciende
	and e			;6ca8
	jr AJUSTA_EL_RUIDO		;6ca9
ENCIENDE_LA_VOZ:
	or e			;6cab
AJUSTA_EL_RUIDO:
	set 2,a		;6cac   ; el canal 3 lleva el ruido
	bit 5,a		;6cae   ; salvo si ya estaba activo
	jr z,ESCRIBE_EL_MEZCLADOR		;6cb0
	res 2,a		;6cb2
ESCRIBE_EL_MEZCLADOR:
	ld e,a			;6cb4
	ld a,007h		;6cb5
	jp 00093h		;6cb7   ; BIOS WRTPSG - Writes data to PSG-register
DOBLA_LA_MELODIA:
	ld hl,0e193h		;6cba   ; el trozo del canal 3
	ld de,06d19h		;6cbd   ; y su tira de recambio
	ld a,c			;6cc0
	cp 003h		;6cc1   ; el canal 3
	jr z,MIRA_EL_MODO_DE_DOBLADO		;6cc3
	ld hl,0e197h		;6cc5   ; o el trozo del canal 2
	ld de,06d1dh		;6cc8
MIRA_EL_MODO_DE_DOBLADO:
	ld a,(0e190h)		;6ccb   ; el modo de doblado
	cp 001h		;6cce
	jr z,BAJA_EL_DOBLADO		;6cd0   ; modo 1: baja
	jr c,ENCHUFA_LA_TIRA_DE_RECAMBIO		;6cd2   ; modo 0: se recupera
	dec hl			;6cd4
	ld a,(hl)			;6cd5   ; lo que lleva doblado
	or a			;6cd6
	jr nz,SUBE_EL_DOBLADO		;6cd7   ; si es cero, se enchufa la tira de recambio
	inc hl			;6cd9
	ld de,06d1eh		;6cda   ; la del canal 3
	ld a,c			;6cdd
	cp 003h		;6cde
	jr z,ENCHUFA_LA_TIRA_DE_RECAMBIO		;6ce0
	ld de,06d22h		;6ce2   ; o la del 2
	jr ENCHUFA_LA_TIRA_DE_RECAMBIO		;6ce5
SUBE_EL_DOBLADO:
	inc hl			;6ce7
	inc (hl)			;6ce8   ; dos de golpe
	inc (hl)			;6ce9
	dec hl			;6cea
	jr nz,GUARDA_EL_PUNTERO		;6ceb
	inc (hl)			;6ced
GUARDA_EL_PUNTERO:
	dec hl			;6cee
	ld (ix+003h),l		;6cef   ; el puntero de la tira, en la ficha
	ld (ix+004h),h		;6cf2
	ret			;6cf5
BAJA_EL_DOBLADO:
	dec hl			;6cf6
	ld a,08fh		;6cf7   ; el byte de arriba
	cp (hl)			;6cf9   ; por debajo de 0x8F se planta
	jr c,BAJA_DE_DOS_EN_DOS		;6cfa
	xor a			;6cfc
	ld (hl),a			;6cfd
	jr GUARDA_EL_PUNTERO		;6cfe
BAJA_DE_DOS_EN_DOS:
	inc hl			;6d00
	dec (hl)			;6d01   ; dos de golpe
	dec (hl)			;6d02
	dec hl			;6d03
	jr nz,GUARDA_EL_PUNTERO		;6d04   ; y con acarreo al byte de arriba
	dec (hl)			;6d06
	jr GUARDA_EL_PUNTERO		;6d07
ENCHUFA_LA_TIRA_DE_RECAMBIO:
	push bc			;6d09
	ex de,hl			;6d0a
	ld bc,00004h		;6d0b   ; cuatro bytes hacia atras
	lddr		;6d0e
	ex de,hl			;6d10
	pop bc			;6d11
	inc hl			;6d12
	inc hl			;6d13
	jr GUARDA_EL_PUNTERO		;6d14

; ----------------------------------------------------------------------
; DATOS trozos_de_melodia: Los cachos de tira que 0x6CBA enchufa a un canal
;   para doblar o quebrar la nota segun 0xE190.
;   0x6d16..0x6d23  (13 bytes)
DATA_trozos_de_melodia:
	defb 001h,021h,092h,0c0h	; 6d16
	defb 001h,021h,092h,0c8h	; 6d1a
	defb 000h,002h,021h,090h	; 6d1e
	defb 008h	; 6d22

; ======================================================================
; CODIGO 0x6d23..0x6e58  (309 bytes)
; ======================================================================


MUEVE_UNA_VOZ:
	bit 6,a		;6d23   ; bit 6: el canal se usa para ruido
	ld d,001h		;6d25
	call z,ENCIENDE_O_APAGA_LA_VOZ		;6d27   ; entonces se enciende el tono
	ld a,(ix+002h)		;6d2a   ; el numero de sonido
	or a			;6d2d
	jp m,GASTA_LA_NOTA		;6d2e   ; con el bit 7 puesto la nota va en un byte
	dec (ix+000h)		;6d31   ; la cuenta de la nota
	ret nz			;6d34   ; mientras quede, se deja sonando
LEE_LA_TIRA:
	ld l,(ix+003h)		;6d35   ; el puntero de la tira
	ld h,(ix+004h)		;6d38
	ld a,(hl)			;6d3b   ; el byte que toca
	cp 0feh		;6d3c   ; 0xFE pide repetir
	jp z,MIRA_LAS_REPETICIONES		;6d3e
	jp nc,APAGA_LA_VOZ		;6d41   ; 0xFF acaba
	bit 7,(ix+002h)		;6d44   ; los sonidos con el bit 7 usan el formato de un byte
	jp nz,NOTA_DE_UN_BYTE		;6d48
	and 0f0h		;6d4b
	cp 020h		;6d4d   ; 0x2n cambia la duracion base
	jr nz,MIRA_EL_RUIDO		;6d4f
	ld a,(hl)			;6d51
	and 00fh		;6d52
	ld (ix+001h),a		;6d54   ; y se guarda
	inc hl			;6d57
MIRA_EL_RUIDO:
	ld a,(hl)			;6d58
	and 0f0h		;6d59
	cp 010h		;6d5b   ; 0x1n pide ruido
	jr nz,MIRA_EL_SILENCIO		;6d5d
	ld a,(hl)			;6d5f
	and 01fh		;6d60   ; los cinco bits del periodo
	ld e,a			;6d62
	ld a,006h		;6d63   ; al registro 6 del PSG
	call 00093h		;6d65   ; BIOS WRTPSG - Writes data to PSG-register
	ld d,000h		;6d68
	call ENCIENDE_O_APAGA_LA_VOZ		;6d6a   ; y se enciende el canal de ruido
	inc hl			;6d6d
	ld a,(hl)			;6d6e
MIRA_EL_SILENCIO:
	ld b,(ix+002h)		;6d6f   ; el numero de sonido
	bit 6,b		;6d72   ; bit 6: canal de ruido
	jr z,TOCA_LA_NOTA		;6d74
	ld a,c			;6d76
	cp 005h		;6d77   ; el canal 3
	ld a,(hl)			;6d79
	jr nz,TOCA_LA_NOTA		;6d7a
	inc hl			;6d7c
	ld (ix+003h),l		;6d7d   ; se guarda el puntero
	ld (ix+004h),h		;6d80
	call ARRANCA_LA_NOTA		;6d83   ; y solo se toca el volumen
	ret			;6d86
TOCA_LA_NOTA:
	and 0f0h		;6d87   ; el nibble alto es la duracion
	ld b,a			;6d89
	xor (hl)			;6d8a   ; y el bajo, la parte alta del periodo
	ld d,a			;6d8b
	inc hl			;6d8c
	ld e,(hl)			;6d8d   ; el byte siguiente es la parte baja
	inc hl			;6d8e
	ld (ix+003h),l		;6d8f   ; se guarda el puntero
	ld (ix+004h),h		;6d92
	ex de,hl			;6d95
	call ESCRIBE_EL_PERIODO		;6d96   ; y se escribe el periodo en el PSG
	ld a,b			;6d99   ; la duracion vuelve a la parte baja
	rrca			;6d9a
	rrca			;6d9b
	rrca			;6d9c
	rrca			;6d9d
ARRANCA_LA_NOTA:
	ld h,a			;6d9e
	ld a,(ix+001h)		;6d9f   ; la duracion base
	ld (ix+000h),a		;6da2   ; se copia a la cuenta
	add a,002h		;6da5   ; y la cuenta de caida sale dos por encima
	ld (ix+008h),a		;6da7
	jr ESCRIBE_EL_VOLUMEN		;6daa
APAGA_LA_VOZ:
	xor a			;6dac
	ld (ix+009h),a		;6dad   ; sin repeticiones pendientes
	ld d,001h		;6db0   ; apaga la voz
	call ENCIENDE_O_APAGA_LA_VOZ		;6db2
	xor a			;6db5
	ld (ix+002h),a		;6db6   ; y borra el numero de sonido
	ld h,a			;6db9
	jr ESCRIBE_EL_VOLUMEN		;6dba
GASTA_LA_NOTA:
	dec (ix+000h)		;6dbc   ; la cuenta de la nota
	jp z,LEE_LA_TIRA		;6dbf   ; al llegar a cero se lee la siguiente
	dec (ix+008h)		;6dc2   ; la cuenta de la caida
	ld a,(ix+008h)		;6dc5
	cp (ix+000h)		;6dc8   ; mientras las dos vayan iguales, no se baja el volumen
	jr nz,ADELANTA_LA_CAIDA		;6dcb
	cp 002h		;6dcd   ; salvo en los dos ultimos cuadros
	jr c,BAJA_EL_VOLUMEN		;6dcf
	ret			;6dd1
ADELANTA_LA_CAIDA:
	dec (ix+008h)		;6dd2
BAJA_EL_VOLUMEN:
	ld a,(ix+007h)		;6dd5   ; el volumen del canal
	dec a			;6dd8
	ret m			;6dd9   ; por debajo de cero no se baja
	ld (ix+007h),a		;6dda
	ld h,a			;6ddd
ESCRIBE_EL_VOLUMEN:
	ld a,c			;6dde   ; los registros 8, 9 y 10 del PSG
	rrca			;6ddf
	add a,088h		;6de0
	ld e,h			;6de2
	jp 00093h		;6de3   ; BIOS WRTPSG - Writes data to PSG-register
NOTA_DE_UN_BYTE:
	and 0f0h		;6de6
	cp 0d0h		;6de8   ; 0xDn cambia la duracion
	ld a,(hl)			;6dea
	jr nz,MIRA_LA_CAIDA		;6deb
	and 00fh		;6ded
	ld (ix+00ah),a		;6def   ; y se guarda
	inc hl			;6df2
	ld a,(hl)			;6df3
MIRA_LA_CAIDA:
	cp 0f0h		;6df4   ; 0xFn cambia la caida
	jr c,MIRA_LA_OCTAVA		;6df6
	and 00fh		;6df8
	ld (ix+006h),a		;6dfa   ; y se guarda
	inc hl			;6dfd
	ld a,(hl)			;6dfe
MIRA_LA_OCTAVA:
	cp 0e0h		;6dff   ; 0xEn cambia la octava
	jr c,CALCULA_LA_DURACION		;6e01
	and 00fh		;6e03
	ld (ix+005h),a		;6e05   ; y se guarda
	inc hl			;6e08
	ld a,(hl)			;6e09
CALCULA_LA_DURACION:
	and 00fh		;6e0a   ; el nibble bajo dice cuantas duraciones
	ld b,a			;6e0c
	ld a,(ix+00ah)		;6e0d   ; la duracion de base
	jr z,ARRANCA_LA_NOTA_DE_UN_BYTE		;6e10
SUMA_UNA_DURACION:
	add a,(ix+00ah)		;6e12
	djnz SUMA_UNA_DURACION		;6e15
ARRANCA_LA_NOTA_DE_UN_BYTE:
	ld (ix+001h),a		;6e17   ; la duracion que sale
	ld a,(hl)			;6e1a   ; el mismo byte otra vez
	inc hl			;6e1b
	ld (ix+003h),l		;6e1c   ; se guarda el puntero
	ld (ix+004h),h		;6e1f
	and 0f0h		;6e22   ; el nibble alto es la nota
	rrca			;6e24
	rrca			;6e25
	rrca			;6e26
	rrca			;6e27
	ld b,a			;6e28
	sub 00ch		;6e29   ; la nota 12 es el silencio
	ld (ix+007h),a		;6e2b   ; y las demas, volumen
	jr z,TOCA_LA_NOTA_DE_UN_BYTE		;6e2e
	ld a,(ix+006h)		;6e30   ; y si no, la caida de la ficha
	ld (ix+007h),a		;6e33
TOCA_LA_NOTA_DE_UN_BYTE:
	call ARRANCA_LA_NOTA		;6e36   ; arranca la nota
	ld a,b			;6e39
	ld hl,06e58h		;6e3a   ; la tabla de los doce periodos
	call SUMA_A_A_HL		;6e3d
	ld l,(hl)			;6e40   ; el periodo de la nota
	ld h,000h		;6e41
	ld a,(ix+005h)		;6e43   ; la octava
	or a			;6e46
	jr z,ESCRIBE_EL_PERIODO		;6e47   ; la primera no desplaza
	ld b,a			;6e49
BAJA_UNA_OCTAVA:
	add hl,hl			;6e4a   ; cada octava abajo dobla el periodo
	djnz BAJA_UNA_OCTAVA		;6e4b
ESCRIBE_EL_PERIODO:
	ld a,c			;6e4d   ; el registro alto del canal
	ld e,h			;6e4e
	call 00093h		;6e4f   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,c			;6e52   ; y el bajo
	dec a			;6e53
	ld e,l			;6e54
	jp 00093h		;6e55   ; BIOS WRTPSG - Writes data to PSG-register

; ----------------------------------------------------------------------
; DATOS periodos_de_las_notas: Los doce periodos de una octava. El reproductor
;   los desplaza a la izquierda para bajar de octava.
;   0x6e58..0x6e64  (12 bytes)
DATA_periodos_de_las_notas:
	defb 06ah,064h,05fh,059h,054h,050h,04bh,047h,043h,03fh,03ch,038h	; 6e58  jd_YTPKGC?<8

; ----------------------------------------------------------------------
; DATOS punteros_de_melodia: Treinta y seis punteros a tiras de melodia.
;   0x6C32 los indexa desde uno -por eso registra 0x6E62- y un sonido de
;   varias voces se lleva entradas seguidas.
;   0x6e64..0x6eac  (72 bytes)
DATA_punteros_de_melodia:
	defw 06each	; 6e64  -> DATA_melodias
	defw 07117h	; 6e66
	defw 06eadh	; 6e68
	defw 0705ch	; 6e6a
	defw 070d6h	; 6e6c
	defw 07101h	; 6e6e
	defw 070f3h	; 6e70
	defw 07110h	; 6e72
	defw 06eb6h	; 6e74
	defw 06ee5h	; 6e76
	defw 06each	; 6e78  -> DATA_melodias
	defw 06ef7h	; 6e7a
	defw 06f3eh	; 6e7c
	defw 06each	; 6e7e  -> DATA_melodias
	defw 06each	; 6e80  -> DATA_melodias
	defw 070f8h	; 6e82
	defw 070e9h	; 6e84
	defw 070eeh	; 6e86
	defw 06f54h	; 6e88
	defw 06f5fh	; 6e8a
	defw 06f6bh	; 6e8c
	defw 06f76h	; 6e8e
	defw 06f91h	; 6e90
	defw 06fach	; 6e92
	defw 06fc7h	; 6e94
	defw 06fdah	; 6e96
	defw 06fedh	; 6e98
	defw 07000h	; 6e9a
	defw 07021h	; 6e9c
	defw 07042h	; 6e9e
	defw 07082h	; 6ea0
	defw 0709bh	; 6ea2
	defw 070bch	; 6ea4
	defw 06each	; 6ea6  -> DATA_melodias
	defw 06each	; 6ea8  -> DATA_melodias
	defw 06each	; 6eaa  -> DATA_melodias

; ----------------------------------------------------------------------
; DATOS melodias: Las tiras de notas. Los sonidos con el bit 7 puesto llevan
;   la nota en UN byte; los demas en DOS. 0xFF acaba y 0xFE vuelve a empezar.
;   0x6eac..0x713c  (656 bytes)
DATA_melodias:
	defb 0ffh,021h,01ch,0b0h,00ch,023h,000h,000h	; 6eac  .!...#..
	defb 0feh,0ffh,021h,0f1h,050h,0f2h,040h,0f1h	; 6eb4  ..!.P.@.
	defb 000h,0e2h,010h,0e1h,0a0h,0d2h,040h,0d1h	; 6ebc  ......@.
	defb 050h,0c1h,0d0h,0b1h,080h,0b1h,0c0h,0a2h	; 6ec4  P.......
	defb 020h,0a1h,010h,091h,0d0h,091h,020h,081h	; 6ecc   ..... .
	defb 0a0h,023h,082h,030h,071h,050h,071h,0a0h	; 6ed4  .#.0qPq.
	defb 061h,0f0h,061h,0c0h,051h,0a0h,051h,0f0h	; 6edc  a.a.Q.Q.
	defb 0ffh,023h,01fh,00ch,00bh,00ah,009h,008h	; 6ee4  .#......
	defb 01dh,008h,01ch,007h,01bh,007h,01ah,006h	; 6eec  ........
	defb 019h,006h,0ffh,021h,0f1h,050h,0f2h,040h	; 6ef4  ...!.P.@
	defb 0f1h,000h,0e2h,010h,0e1h,0a0h,0d2h,040h	; 6efc  .......@
	defb 0d1h,050h,0c1h,0d0h,0b1h,080h,0b1h,0c0h	; 6f04  .P......
	defb 0a2h,020h,0a1h,010h,0f1h,050h,0f2h,040h	; 6f0c  . ...P.@
	defb 0f1h,000h,0e2h,010h,0e1h,0a0h,0d2h,040h	; 6f14  .......@
	defb 0d1h,050h,0c1h,0d0h,0b1h,080h,0b1h,0c0h	; 6f1c  .P......
	defb 0a2h,020h,0a1h,010h,091h,0d0h,091h,020h	; 6f24  . ..... 
	defb 081h,0a0h,023h,082h,030h,071h,050h,071h	; 6f2c  ..#.0qPq
	defb 0a0h,061h,0f0h,061h,0c0h,051h,0a0h,051h	; 6f34  .a.a.Q.Q
	defb 0f0h,0ffh,023h,01fh,00ch,00bh,00ah,009h	; 6f3c  ..#.....
	defb 00ch,00bh,00ah,009h,008h,01dh,008h,01ch	; 6f44  ........
	defb 007h,01bh,007h,01ah,006h,019h,006h,0ffh	; 6f4c  ........
	defb 0d4h,0fdh,0e2h,023h,0c0h,0d2h,040h,0d4h	; 6f54  ...#..@.
	defb 0c0h,047h,0ffh,0d4h,0fdh,0e3h,0b3h,0c0h	; 6f5c  .G......
	defb 0d2h,0e2h,010h,0d4h,0c0h,017h,0ffh,0d4h	; 6f64  ........
	defb 0fdh,0e3h,073h,0c0h,0d2h,090h,0d4h,0c0h	; 6f6c  ..s.....
	defb 097h,0ffh,0d4h,0fch,0e2h,021h,021h,021h	; 6f74  .....!!!
	defb 075h,0e1h,001h,0e2h,0b1h,091h,0d3h,0b5h	; 6f7c  u.......
	defb 071h,0d4h,0a1h,0a1h,0a1h,0e1h,035h,071h	; 6f84  q.....5q
	defb 051h,031h,0d6h,02bh,0ffh,0d4h,0fch,0e3h	; 6f8c  Q1.+....
	defb 0b1h,0b1h,0b1h,0b5h,0e2h,041h,041h,041h	; 6f94  .....AAA
	defb 0d3h,055h,0e3h,0b1h,0d4h,0e2h,031h,031h	; 6f9c  .U....11
	defb 031h,035h,031h,031h,051h,0d6h,07bh,0ffh	; 6fa4  1511Q.{.
	defb 0d4h,0fch,0e3h,071h,071h,071h,075h,0e2h	; 6fac  ...qqqu.
	defb 001h,001h,001h,0d3h,0e3h,075h,071h,0d4h	; 6fb4  .....uq.
	defb 0e2h,071h,071h,071h,075h,0a1h,0a1h,091h	; 6fbc  .qqqu...
	defb 0d6h,0bbh,0ffh,0d2h,0fch,0e2h,053h,093h	; 6fc4  ......S.
	defb 0e1h,003h,057h,001h,001h,023h,0e2h,0a1h	; 6fcc  ..W..#..
	defb 0e1h,021h,053h,0d6h,097h,0ffh,0d2h,0fch	; 6fd4  .!S.....
	defb 0e2h,053h,093h,0e1h,003h,0e2h,097h,051h	; 6fdc  .S.....Q
	defb 051h,053h,021h,051h,0b3h,0d6h,0e1h,007h	; 6fe4  QS!Q....
	defb 0ffh,0d2h,0fch,0e3h,053h,093h,0e2h,003h	; 6fec  ....S...
	defb 057h,0e3h,091h,091h,0a3h,0a1h,0a1h,0e2h	; 6ff4  W.......
	defb 023h,0d6h,057h,0ffh,0d4h,0fch,0e1h,041h	; 6ffc  #.W....A
	defb 091h,0e0h,011h,0e1h,0b1h,041h,091h,0e0h	; 7004  .....A..
	defb 011h,0e1h,0b1h,041h,091h,0b1h,091h,081h	; 700c  ...A....
	defb 0b1h,0e0h,041h,0e1h,0b1h,0e0h,011h,001h	; 7014  ..A.....
	defb 0e1h,0b1h,0a1h,093h,0ffh,0d4h,0fch,0e2h	; 701c  ........
	defb 041h,091h,0e1h,011h,0e2h,0b1h,041h,091h	; 7024  A.....A.
	defb 0e1h,011h,0e2h,0b1h,041h,091h,0b1h,091h	; 702c  ....A...
	defb 081h,0b1h,0e1h,041h,0e2h,0b1h,0e1h,011h	; 7034  ...A....
	defb 001h,0e2h,0b1h,0a1h,093h,0ffh,0d4h,0fch	; 703c  ........
	defb 0e4h,0c3h,091h,0e3h,041h,091h,091h,0e4h	; 7044  ....A...
	defb 091h,0e3h,041h,091h,041h,041h,081h,0b1h	; 704c  ..A.AA..
	defb 081h,041h,031h,021h,011h,0e4h,093h,0ffh	; 7054  .A1!....
	defb 023h,0d0h,08fh,0d0h,0a0h,0d0h,08fh,0d0h	; 705c  #.......
	defb 0a0h,0d0h,08fh,0d0h,0a0h,0d0h,08fh,0d0h	; 7064  ........
	defb 0a0h,0d0h,08fh,0d0h,0a0h,0d0h,08fh,0d0h	; 706c  ........
	defb 0a0h,0d0h,08fh,0d0h,0a0h,0d0h,08fh,0d0h	; 7074  ........
	defb 0a0h,02fh,000h,000h,0feh,002h,0d4h,0fch	; 707c  ./......
	defb 0e2h,098h,0d6h,090h,090h,0d4h,0e1h,001h	; 7084  ........
	defb 0e2h,091h,051h,071h,051h,0e1h,021h,00bh	; 708c  ..QqQ.!.
	defb 025h,023h,020h,020h,0d9h,048h,0ffh,0d4h	; 7094  %#  .H..
	defb 0fch,0e3h,058h,0d6h,050h,050h,0d4h,051h	; 709c  ..X.PP.Q
	defb 051h,051h,051h,051h,051h,092h,090h,090h	; 70a4  QQQQQ...
	defb 090h,0e2h,001h,0e3h,091h,051h,071h,021h	; 70ac  .....Qq!
	defb 071h,0b1h,071h,0b1h,0d9h,0e2h,018h,0ffh	; 70b4  q.q.....
	defb 0d4h,0fch,0e2h,008h,0d6h,000h,000h,0d4h	; 70bc  ........
	defb 051h,001h,0e2h,091h,0a1h,0a1h,0a1h,0fbh	; 70c4  Q.......
	defb 0e1h,059h,091h,0b5h,073h,070h,070h,0d9h	; 70cc  .Y..spp.
	defb 098h,0ffh,022h,0f0h,078h,0e0h,078h,0d0h	; 70d4  ..".x.x.
	defb 078h,0c0h,078h,023h,0b0h,078h,0a0h,078h	; 70dc  x.x#.x.x
	defb 090h,078h,070h,078h,0ffh,0dah,0fdh,0e1h	; 70e4  .xpx....
	defb 075h,0ffh,0dah,0fdh,0e0h,005h,0ffh,021h	; 70ec  u......!
	defb 01fh,0c1h,0f0h,0ffh,022h,014h,00eh,000h	; 70f4  ...."...
	defb 000h,021h,01fh,00eh,0ffh,023h,014h,081h	; 70fc  .!...#..
	defb 070h,000h,000h,023h,081h,098h,000h,000h	; 7104  p..#....
	defb 0feh,0ffh,0feh,016h,02fh,014h,00bh,0feh	; 710c  ..../...
	defb 0ffh,0feh,00fh,024h,000h,000h,026h,090h	; 7114  ...$..&.
	defb 021h,090h,020h,090h,021h,090h,020h,02fh	; 711c  !. .!. /
	defb 000h,000h,000h,000h,026h,090h,021h,090h	; 7124  ....&.!.
	defb 020h,090h,021h,090h,020h,02fh,000h,000h	; 712c   .!. /..
	defb 000h,000h,000h,000h,0feh,0ffh,0feh,002h	; 7134  ........

; ----------------------------------------------------------------------
; DATOS posturas_del_atleta: Dieciocho punteros, uno por postura, que 0x7FA0
;   indexa con 0xE0B6 o 0xE0EC. Son SIETE MENOS que en el cartucho hermano.
;   0x713c..0x7160  (36 bytes)
DATA_posturas_del_atleta:
	defw 07174h	; 713c
	defw 07160h	; 713e  -> DATA_registros_de_postura
	defw 07181h	; 7140
	defw 0716dh	; 7142
	defw 07232h	; 7144
	defw 07241h	; 7146
	defw 07188h	; 7148
	defw 07195h	; 714a
	defw 071a2h	; 714c
	defw 071b3h	; 714e
	defw 071c4h	; 7150
	defw 071d1h	; 7152
	defw 071deh	; 7154
	defw 07214h	; 7156
	defw 07225h	; 7158
	defw 071ebh	; 715a
	defw 071f8h	; 715c
	defw 07205h	; 715e

; ----------------------------------------------------------------------
; DATOS registros_de_postura: Por postura: cuantos trozos de sprite lleva, un
;   puntero a cada uno y, al final, el puntero a su lista de atributos.
;   0x7160..0x7250  (240 bytes)
DATA_registros_de_postura:
	defw 06f05h	; 7160
	defw 0a173h	; 7162
	defw 08974h	; 7164
	defw 08674h	; 7166
	defw 05d73h	; 7168
	defw 05c74h	; 716a
	defw 00272h	; 716c
	defw 07464h	; 716e
	defw 074a1h	; 7170
	defw 0725ch	; 7172
	defw 0b405h	; 7174
	defw 03a73h	; 7176
	defw 08975h	; 7178
	defw 01874h	; 717a
	defw 03b73h	; 717c
	defw 05073h	; 717e
	defw 00272h	; 7180
	defw 073d1h	; 7182
	defw 0753ah	; 7184
	defw 07250h	; 7186  -> DATA_atributos_de_las_posturas
	defw 03805h	; 7188
	defw 01876h	; 718a
	defw 02a76h	; 718c
	defw 0d276h	; 718e
	defw 05275h	; 7190
	defw 08274h	; 7192
	defw 00572h	; 7194
	defw 07412h	; 7196
	defw 07618h	; 7198
	defw 0762ah	; 719a
	defw 07511h	; 719c
	defw 07343h	; 719e
	defw 0728eh	; 71a0
	defw 0d907h	; 71a2
	defw 01874h	; 71a4
	defw 08f76h	; 71a6
	defw 05875h	; 71a8
	defw 09776h	; 71aa
	defw 0ce78h	; 71ac
	defw 08174h	; 71ae
	defw 09a74h	; 71b0
	defw 00772h	; 71b2
	defw 07688h	; 71b4
	defw 07618h	; 71b6
	defw 0762ah	; 71b8
	defw 07552h	; 71ba
	defw 076a7h	; 71bc
	defw 00000h	; 71be
	defw 0747ah	; 71c0
	defw 072a8h	; 71c2
	defw 06905h	; 71c4
	defw 01876h	; 71c6
	defw 02a76h	; 71c8
	defw 0b776h	; 71ca
	defw 09776h	; 71cc
	defw 0b574h	; 71ce
	defw 00572h	; 71d0
	defw 07597h	; 71d2
	defw 07618h	; 71d4
	defw 0762ah	; 71d6
	defw 076cfh	; 71d8
	defw 076ach	; 71da
	defw 072c1h	; 71dc
	defw 04105h	; 71de
	defw 01877h	; 71e0
	defw 02a76h	; 71e2
	defw 03476h	; 71e4
	defw 08977h	; 71e6
	defw 0cd75h	; 71e8
	defw 00572h	; 71ea
	defw 07757h	; 71ec
	defw 074a1h	; 71ee
	defw 07489h	; 71f0
	defw 077bch	; 71f2
	defw 077cah	; 71f4
	defw 072d9h	; 71f6
	defw 0d505h	; 71f8
	defw 04f77h	; 71fa
	defw 0e973h	; 71fc
	defw 03d76h	; 71fe
	defw 0ea74h	; 7200
	defw 0e577h	; 7202
	defw 00672h	; 7204
	defw 077f2h	; 7206
	defw 07777h	; 7208
	defw 0762fh	; 720a
	defw 074f5h	; 720c
	defw 075b2h	; 720e
	defw 07807h	; 7210
	defw 072f1h	; 7212
	defw 0bf07h	; 7214
	defw 0eb75h	; 7216
	defw 02973h	; 7218
	defw 00378h	; 721a
	defw 03674h	; 721c
	defw 02a73h	; 721e
	defw 02e75h	; 7220
	defw 0fe78h	; 7222
	defw 00572h	; 7224
	defw 076dch	; 7226
	defw 0780ch	; 7228
	defw 07820h	; 722a
	defw 0770bh	; 722c
	defw 075f0h	; 722e
	defw 0730ch	; 7230
	defw 06206h	; 7232
	defw 09d73h	; 7234
	defw 02173h	; 7236
	defw 06977h	; 7238
	defw 0e875h	; 723a
	defw 02a75h	; 723c
	defw 06877h	; 723e
	defw 00672h	; 7240
	defw 0757ah	; 7242
	defw 0778eh	; 7244
	defw 0748eh	; 7246
	defw 07429h	; 7248
	defw 077a6h	; 724a
	defw 077b0h	; 724c
	defw 07275h	; 724e

; ----------------------------------------------------------------------
; DATOS atributos_de_las_posturas: Siete sprites por postura, cuatro bytes
;   cada uno. Las listas se solapan entre si.
;   0x7250..0x7328  (216 bytes)
DATA_atributos_de_las_posturas:
	defb 001h,004h,0ffh,007h	; 7250
	defb 00fh,007h,012h,003h	; 7254
	defb 01ch,002h,0cfh,0cfh	; 7258
	defb 003h,007h,0ffh,008h	; 725c
	defb 00fh,009h,012h,006h	; 7260
	defb 01eh,007h,0cfh,0cfh	; 7264
	defb 008h,011h,008h,00bh	; 7268
	defb 014h,007h,018h,002h	; 726c
	defb 01ch,000h,018h,011h	; 7270
	defb 0cfh,006h,011h,00ch	; 7274
	defb 00ch,010h,006h,016h	; 7278
	defb 001h,01ch,000h,016h	; 727c
	defb 011h,0cfh,003h,006h	; 7280
	defb 0ffh,008h,00eh,009h	; 7284
	defb 011h,007h,010h,006h	; 7288
	defb 0cfh,0cfh,003h,008h	; 728c
	defb 0ffh,008h,00fh,009h	; 7290
	defb 011h,005h,011h,004h	; 7294
	defb 0cfh,0cfh,003h,005h	; 7298
	defb 0ffh,008h,003h,009h	; 729c
	defb 012h,0ffh,015h,0fdh	; 72a0
	defb 012h,00fh,013h,014h	; 72a4
	defb 003h,005h,0ffh,008h	; 72a8
	defb 00fh,009h,012h,002h	; 72ac
	defb 012h,000h,0cfh,013h	; 72b0
	defb 010h,003h,004h,0ffh	; 72b4
	defb 008h,00fh,009h,012h	; 72b8
	defb 006h,011h,004h,0cfh	; 72bc
	defb 0cfh,003h,005h,0ffh	; 72c0
	defb 008h,00fh,009h,012h	; 72c4
	defb 008h,011h,005h,0cfh	; 72c8
	defb 0cfh,005h,008h,001h	; 72cc
	defb 008h,00fh,008h,013h	; 72d0
	defb 009h,01ch,008h,0cfh	; 72d4
	defb 0cfh,003h,002h,0ffh	; 72d8
	defb 008h,00fh,009h,013h	; 72dc
	defb 007h,01dh,005h,0cfh	; 72e0
	defb 0cfh,00ch,017h,00bh	; 72e4
	defb 012h,002h,00eh,00ah	; 72e8
	defb 004h,013h,003h,0cfh	; 72ec
	defb 0cfh,003h,015h,00ah	; 72f0
	defb 010h,00ch,00ch,003h	; 72f4
	defb 005h,0fch,004h,013h	; 72f8
	defb 016h,0cfh,0f7h,002h	; 72fc
	defb 0f8h,004h,008h,004h	; 7300
	defb 008h,0feh,00ch,0fch	; 7304
	defb 0fch,00eh,008h,018h	; 7308
	defb 019h,013h,017h,00bh	; 730c
	defb 019h,008h,012h,001h	; 7310
	defb 008h,000h,0cfh,0cfh	; 7314
	defb 006h,00fh,00fh,00eh	; 7318
	defb 01eh,01ch,01ch,038h	; 731c
	defb 038h,038h,030h,070h	; 7320
	defb 0e0h,020h,000h,003h	; 7324

; ----------------------------------------------------------------------
; DATOS patrones_del_atleta: Los patrones de sprite de 16x16 comprimidos con
;   la racha de ceros de 0x5C41. Se solapan donde dos figuras acaban igual.
;   0x7328..0x789e  (1398 bytes)
DATA_patrones_del_atleta:
	defb 070h,078h,038h,03ch,01ch,01ch,038h,038h	; 7328  px8<..88
	defb 070h,070h,0e0h,0c0h,000h,003h,018h,070h	; 7330  pp.....p
	defb 0c0h,000h,01dh,080h,080h,0e0h,070h,000h	; 7338  ......p.
	defb 00eh,038h,03ch,000h,00ch,080h,0e0h,070h	; 7340  .8<....p
	defb 000h,00ah,0c0h,060h,030h,000h,004h,0c0h	; 7348  ...`0...
	defb 0e0h,0f2h,0fbh,0fah,0fch,078h,038h,002h	; 7350  .....x8.
	defb 001h,000h,008h,010h,018h,018h,018h,0f8h	; 7358  ........
	defb 078h,030h,000h,007h,030h,060h,03ch,030h	; 7360  x0..0`<0
	defb 01ch,018h,0d0h,0e0h,0e0h,000h,010h,028h	; 7368  .......(
	defb 069h,0fbh,0dfh,00ch,031h,003h,003h,031h	; 7370  i...1..1
	defb 070h,0f0h,0c0h,000h,006h,080h,0e0h,070h	; 7378  p......p
	defb 0b8h,0f8h,0f0h,0e0h,000h,007h,030h,07bh	; 7380  ......0{
	defb 07bh,0f1h,0e0h,0e0h,071h,071h,03bh,03bh	; 7388  {...qq;;
	defb 01bh,01bh,000h,005h,0c0h,0c0h,0e0h,0e0h	; 7390  ........
	defb 0e0h,0c0h,0c0h,080h,080h,000h,006h,001h	; 7398  ........
	defb 001h,006h,01fh,03fh,0ffh,0ffh,07ch,03ch	; 73a0  ...?..|<
	defb 010h,000h,005h,0f0h,0f8h,03ch,07ch,00ch	; 73a8  .....<|.
	defb 00ch,08ch,088h,080h,000h,002h,005h,00dh	; 73b0  ........
	defb 01fh,01bh,001h,006h,0e0h,0e0h,080h,0c0h	; 73b8  ........
	defb 0e0h,070h,020h,000h,005h,040h,0c0h,080h	; 73c0  .p ..@..
	defb 000h,001h,040h,0e7h,0f7h,073h,077h,03eh	; 73c8  ..@..sw>
	defb 01ch,000h,001h,0e0h,0e5h,0cdh,0dfh,0dbh	; 73d0  ........
	defb 0e1h,06eh,078h,030h,020h,000h,005h,00eh	; 73d8  .nx0 ...
	defb 00eh,006h,006h,046h,0ceh,09eh,03ch,07ch	; 73e0  ...F..<|
	defb 0f8h,0e0h,060h,000h,004h,003h,007h,00fh	; 73e8  ..`.....
	defb 00fh,00fh,00fh,00fh,01fh,01fh,03fh,07fh	; 73f0  ......?.
	defb 0ffh,000h,004h,0e0h,0f0h,000h,003h,0a0h	; 73f8  ........
	defb 0f0h,080h,080h,000h,003h,001h,007h,03fh	; 7400  .......?
	defb 0ffh,000h,009h,003h,017h,07bh,0fdh,0fch	; 7408  .....{..
	defb 0f8h,000h,00ah,00bh,02fh,03dh,018h,006h	; 7410  ..../=..
	defb 018h,038h,0b8h,09ch,09fh,08fh,000h,006h	; 7418  .8......
	defb 080h,080h,000h,005h,0c0h,0c0h,0c0h,000h	; 7420  ........
	defb 004h,004h,00fh,00fh,01eh,03ch,078h,0e0h	; 7428  .....<x.
	defb 0c0h,000h,008h,070h,0f8h,07ch,03eh,01eh	; 7430  ...p.|>.
	defb 03ch,078h,0e0h,0c0h,000h,007h,00fh,01fh	; 7438  <x......
	defb 03dh,03bh,01fh,01fh,01fh,03eh,038h,070h	; 7440  =;...>8p
	defb 0e0h,0c0h,000h,004h,0c0h,0c0h,0c0h,0c0h	; 7448  ........
	defb 0c0h,0e0h,000h,009h,008h,00ch,006h,080h	; 7450  ........
	defb 0c0h,060h,030h,000h,010h,077h,0f7h,000h	; 7458  .`0..w..
	defb 00fh,080h,000h,00eh,029h,068h,0fah,0deh	; 7460  ....)h..
	defb 00ch,030h,003h,01bh,038h,078h,0e0h,0c0h	; 7468  .0..8x..
	defb 000h,004h,0c0h,0e0h,070h,038h,078h,0f0h	; 7470  ....p8x.
	defb 0e0h,0c0h,000h,008h,010h,0f0h,0e0h,000h	; 7478  ........
	defb 015h,000h,005h,010h,030h,060h,0c0h,000h	; 7480  ....0`..
	defb 017h,0fch,0fch,0fch,07ch,000h,01ch,03eh	; 7488  ....|..>
	defb 07eh,0fch,0fch,0fch,070h,000h,019h,030h	; 7490  ~...p..0
	defb 070h,0c0h,040h,000h,019h,038h,03ch,000h	; 7498  p.@..8<.
	defb 001h,000h,002h,07ch,0feh,00fh,00fh,00bh	; 74a0  ...|....
	defb 043h,0e6h,01ch,03eh,07eh,07eh,07eh,07eh	; 74a8  C..>~~~~
	defb 07eh,000h,010h,000h,002h,03ch,07eh,0f2h	; 74b0  ~....<~.
	defb 0f8h,0c1h,0c3h,0c7h,043h,007h,007h,007h	; 74b8  ....C...
	defb 007h,003h,003h,000h,006h,080h,000h,002h	; 74c0  ........
	defb 080h,080h,080h,0c0h,0c0h,0c0h,0e0h,0f0h	; 74c8  ........
	defb 0f8h,078h,038h,03ch,01ch,00eh,004h,000h	; 74d0  .x8<....
	defb 017h,001h,001h,005h,007h,003h,018h,071h	; 74d8  .......q
	defb 0f3h,0c3h,0e1h,070h,030h,030h,000h,003h	; 74e0  ...p00..
	defb 040h,060h,0f0h,0b0h,00eh,00eh,016h,01ch	; 74e8  @`......
	defb 0dch,0f8h,070h,000h,005h,003h,003h,001h	; 74f0  ..p.....
	defb 040h,0e0h,07ch,03fh,00fh,003h,003h,001h	; 74f8  @.|?....
	defb 001h,001h,000h,004h,080h,0c1h,0e1h,0f3h	; 7500  ........
	defb 073h,07bh,0f9h,0f9h,0c0h,0c0h,080h,000h	; 7508  s{......
	defb 004h,000h,002h,00fh,01eh,01eh,01ch,03ch	; 7510  .......<
	defb 038h,078h,070h,0e0h,0c0h,0c0h,000h,003h	; 7518  8xp.....
	defb 030h,078h,0fch,07ch,01ch,038h,078h,070h	; 7520  0x.|.8xp
	defb 0e0h,040h,000h,006h,006h,00eh,00eh,000h	; 7528  .@......
	defb 002h,018h,0ffh,0ffh,0f7h,0c0h,000h,00ch	; 7530  ........
	defb 0f0h,0e0h,000h,002h,03eh,07fh,007h,007h	; 7538  ....>...
	defb 005h,021h,073h,00eh,03eh,07eh,0feh,0feh	; 7540  .!s.>~..
	defb 0feh,07eh,000h,004h,080h,080h,080h,080h	; 7548  .~......
	defb 000h,008h,000h,001h,023h,0e7h,077h,07fh	; 7550  ....#.w.
	defb 03fh,01eh,00ch,000h,008h,00ch,0fch,09ch	; 7558  ?.......
	defb 09eh,00eh,00eh,00eh,007h,003h,003h,000h	; 7560  ........
	defb 006h,000h,001h,004h,006h,037h,0ffh,0ffh	; 7568  .....7..
	defb 00eh,000h,009h,01eh,03eh,076h,09ch,03ch	; 7570  ....>v.<
	defb 038h,010h,000h,009h,00ah,00bh,02fh,03dh	; 7578  8...../=
	defb 018h,0deh,0e0h,000h,00bh,080h,080h,000h	; 7580  ........
	defb 003h,080h,0c0h,06fh,00fh,000h,01ch,000h	; 7588  ...o....
	defb 00ch,0fch,0fch,0fch,0f8h,000h,010h,001h	; 7590  ........
	defb 001h,005h,007h,003h,000h,001h,03ch,07eh	; 7598  ......<~
	defb 0e0h,0c0h,0d8h,0f8h,038h,000h,003h,040h	; 75a0  ....8..@
	defb 060h,0f0h,0beh,00eh,0c6h,00eh,01ch,038h	; 75a8  `......8
	defb 038h,030h,000h,005h,001h,003h,002h,010h	; 75b0  80......
	defb 060h,0c0h,080h,000h,009h,0c0h,080h,000h	; 75b8  `.......
	defb 009h,030h,07ch,0fch,0d8h,0c0h,0e0h,0e0h	; 75c0  .0|.....
	defb 000h,007h,028h,02ch,0beh,016h,0e0h,0ffh	; 75c8  ..(,....
	defb 0ffh,00ch,000h,001h,03fh,03fh,03dh,03fh	; 75d0  ....??=?
	defb 03fh,07fh,06ch,060h,060h,0c0h,040h,000h	; 75d8  ?.l``.@.
	defb 004h,0c0h,0e0h,0e0h,0e0h,0c0h,000h,00bh	; 75e0  ........
	defb 0c0h,0c0h,0c0h,060h,000h,00eh,008h,01eh	; 75e8  ...`....
	defb 000h,00ch,080h,0c0h,0e0h,020h,000h,008h	; 75f0  ..... ..
	defb 003h,001h,003h,003h,000h,004h,001h,001h	; 75f8  ........
	defb 007h,003h,003h,005h,00eh,00fh,007h,003h	; 7600  ........
	defb 000h,006h,040h,040h,010h,0b0h,080h,0d8h	; 7608  ..@@....
	defb 0dch,0dch,0cch,0bch,038h,060h,000h,004h	; 7610  ....8`..
	defb 000h,002h,03eh,07fh,0f0h,0f0h,0d0h,0c2h	; 7618  ..>.....
	defb 067h,038h,07ch,07eh,07eh,07eh,07eh,07eh	; 7620  g8|~~~~~
	defb 000h,010h,0fch,0fch,0fch,0f8h,000h,01ch	; 7628  ........
	defb 01ch,03ch,078h,0f8h,0f0h,070h,000h,019h	; 7630  .<x..p..
	defb 002h,002h,00bh,00fh,006h,009h,01ch,038h	; 7638  .......8
	defb 070h,0e0h,0e0h,070h,038h,038h,000h,002h	; 7640  p..p88..
	defb 080h,0c0h,0e0h,060h,000h,001h,080h,000h	; 7648  ...`....
	defb 001h,018h,018h,078h,070h,040h,000h,004h	; 7650  ...xp@..
	defb 000h,002h,001h,01dh,0ffh,0ffh,00fh,000h	; 7658  ........
	defb 009h,041h,0ffh,0f3h,0e0h,0c0h,080h,000h	; 7660  .A......
	defb 00ah,000h,002h,002h,003h,001h,000h,003h	; 7668  ........
	defb 00fh,00eh,00eh,007h,003h,001h,000h,002h	; 7670  ........
	defb 0a0h,0b0h,0f8h,0d8h,080h,060h,0c0h,070h	; 7678  .....`.p
	defb 000h,002h,010h,018h,0d8h,0c0h,0c0h,080h	; 7680  ........
	defb 001h,001h,005h,007h,003h,000h,001h,011h	; 7688  ........
	defb 033h,073h,0e1h,061h,070h,030h,000h,003h	; 7690  3s.ap0..
	defb 040h,060h,0f0h,0b0h,000h,001h,0c0h,080h	; 7698  @`......
	defb 01eh,01eh,0deh,0f8h,0f0h,000h,004h,038h	; 76a0  .......8
	defb 070h,0c0h,000h,01dh,030h,070h,0e0h,040h	; 76a8  p...0p.@
	defb 000h,009h,007h,007h,000h,00fh,080h,000h	; 76b0  ........
	defb 001h,0dfh,0dfh,0fdh,079h,078h,030h,000h	; 76b8  ....yx0.
	defb 009h,080h,0c0h,0c0h,0e0h,0e0h,0f0h,070h	; 76c0  .......p
	defb 0e0h,0e0h,0c0h,0c0h,0c0h,000h,004h,002h	; 76c8  ........
	defb 0deh,0feh,0feh,07eh,07ch,03ch,01ch,018h	; 76d0  ...~|<..
	defb 018h,038h,030h,000h,014h,016h,05fh,07bh	; 76d8  .80..._{
	defb 070h,0ffh,0ffh,000h,00ch,008h,030h,0e0h	; 76e0  p.....0.
	defb 0f0h,000h,009h,0f0h,0f0h,0f0h,0f0h,0f0h	; 76e8  ........
	defb 070h,020h,000h,010h,001h,001h,007h,003h	; 76f0  p ......
	defb 003h,005h,00eh,00fh,007h,003h,000h,006h	; 76f8  ........
	defb 040h,040h,010h,0beh,08eh,0c6h,0ceh,0dch	; 7700  @@......
	defb 0f8h,0b8h,030h,000h,005h,080h,0c0h,0c0h	; 7708  ..0.....
	defb 0e0h,0e0h,0deh,0feh,07eh,00fh,000h,002h	; 7710  ....~...
	defb 038h,078h,0f0h,0e0h,0c0h,0e0h,0f0h,000h	; 7718  8x......
	defb 009h,030h,0f8h,0fch,0ffh,0fch,078h,030h	; 7720  .0....x0
	defb 000h,019h,0e0h,0c0h,0e0h,0e0h,060h,060h	; 7728  ......``
	defb 060h,0e0h,000h,018h,07ch,07ch,03ch,01ch	; 7730  `...||<.
	defb 038h,038h,078h,0f8h,0f8h,0d8h,018h,000h	; 7738  88x.....
	defb 015h,00ah,00bh,02fh,03dh,018h,006h,030h	; 7740  .../=..0
	defb 038h,070h,0e0h,0c0h,0e0h,060h,070h,030h	; 7748  8p...`p0
	defb 030h,000h,002h,080h,080h,000h,00ch,001h	; 7750  0.......
	defb 003h,027h,0e6h,0e0h,061h,070h,03eh,01eh	; 7758  .'..ap>.
	defb 00eh,000h,001h,001h,01fh,00fh,00ch,000h	; 7760  ........
	defb 001h,040h,040h,0d0h,0f0h,060h,080h,060h	; 7768  .@@..`.`
	defb 070h,070h,060h,0e0h,0e0h,0c0h,080h,000h	; 7770  pp`.....
	defb 002h,00eh,03eh,03fh,07fh,079h,0f8h,0f8h	; 7778  ..>?.y..
	defb 0f0h,000h,006h,008h,08ch,0cch,08ch,00ch	; 7780  ........
	defb 03ch,098h,0f8h,070h,000h,007h,000h,001h	; 7788  <..p....
	defb 001h,003h,007h,007h,05eh,07eh,0ffh,0f9h	; 7790  ....^~..
	defb 0f8h,078h,008h,000h,005h,0f0h,0f8h,080h	; 7798  .x......
	defb 080h,080h,010h,038h,000h,008h,080h,080h	; 77a0  ...8....
	defb 0c0h,0e0h,000h,00eh,080h,0f0h,000h,00ch	; 77a8  ........
	defb 0e0h,0e0h,0e0h,0c0h,0e0h,0e0h,060h,060h	; 77b0  ......``
	defb 060h,0b0h,000h,016h,03eh,03eh,03ch,03ch	; 77b8  `...>><<
	defb 078h,078h,0fch,0feh,0eeh,0c7h,0c3h,002h	; 77c0  xx......
	defb 000h,014h,000h,001h,070h,0f1h,000h,00dh	; 77c8  ....p...
	defb 020h,060h,0c0h,000h,00dh,030h,038h,09ch	; 77d0   `...08.
	defb 0b0h,07ch,0e0h,0f0h,038h,01ch,00eh,007h	; 77d8  .|..8...
	defb 003h,003h,000h,00dh,080h,000h,001h,080h	; 77e0  ........
	defb 000h,003h,002h,004h,000h,002h,070h,0f0h	; 77e8  ......p.
	defb 000h,01ah,0e0h,0c0h,0e0h,080h,080h,080h	; 77f0  ........
	defb 0c0h,0c8h,0cch,026h,028h,01eh,018h,0cch	; 77f8  ...&(...
	defb 0e0h,0f1h,000h,00dh,0a0h,0e0h,0e0h,0efh	; 7800  ........
	defb 0ffh,07ch,000h,01dh,000h,002h,001h,021h	; 7808  .|.....!
	defb 07fh,07fh,0ffh,0ffh,07fh,000h,007h,07ch	; 7810  .......|
	defb 0feh,0e0h,0e0h,0a0h,084h,08eh,000h,009h	; 7818  ........
	defb 078h,078h,070h,0f0h,0e0h,0e0h,070h,000h	; 7820  xxp...p.
	defb 019h,0ffh,0fah,0e0h,000h,01dh,030h,060h	; 7828  ......0`
	defb 0c0h,000h,01dh,002h,002h,00eh,007h,007h	; 7830  ........
	defb 00bh,03dh,01fh,02fh,027h,030h,020h,000h	; 7838  .=./'0 .
	defb 006h,020h,060h,080h,080h,080h,080h,080h	; 7840  . `.....
	defb 000h,007h,014h,010h,070h,03dh,03ch,05ch	; 7848  ....p=<\
	defb 0ech,0fch,07ch,038h,001h,001h,001h,000h	; 7850  ..|8....
	defb 005h,080h,080h,000h,007h,080h,080h,000h	; 7858  ........
	defb 003h,000h,002h,002h,000h,002h,001h,00bh	; 7860  ........
	defb 0fbh,061h,070h,030h,010h,010h,000h,003h	; 7868  .ap0....
	defb 0a0h,0a0h,0c0h,0e8h,0e0h,070h,0b0h,0f0h	; 7870  .....p..
	defb 0e0h,0e0h,000h,006h,001h,001h,005h,001h	; 7878  ........
	defb 001h,002h,017h,037h,063h,0e1h,060h,060h	; 7880  ...7c.``
	defb 020h,000h,003h,040h,040h,080h,0d0h,0c0h	; 7888   ..@@...
	defb 0e0h,060h,0e0h,0c0h,0c0h,000h,006h,060h	; 7890  .`.....`
	defb 0c0h,0c0h,0c0h,080h,000h,01bh	; 7898

; ----------------------------------------------------------------------
; DATOS posturas_del_objeto: Cinco punteros a patrones que 0x68F6 sube a
;   0x1800 para el objeto que vuela.
;   0x789e..0x78a8  (10 bytes)
DATA_posturas_del_objeto:
	defw 078a8h	; 789e  -> DATA_patrones_del_objeto
	defw 078b2h	; 78a0
	defw 078c4h	; 78a2
	defw 078dah	; 78a4
	defw 078eah	; 78a6

; ----------------------------------------------------------------------
; DATOS patrones_del_objeto: Los patrones del objeto que vuela y las filas de
;   atributos que van detras de cada uno.
;   0x78a8..0x7910  (104 bytes)
DATA_patrones_del_objeto:
	defb 00fh,000h,00fh,0ffh,000h,00fh,00fh,000h	; 78a8  ........
	defb 010h,00bh,000h,004h,003h,00ch,030h,0c0h	; 78b0  ......0.
	defb 000h,008h,003h,00ch,030h,0c0h,000h,00ch	; 78b8  ....0...
	defb 00fh,004h,00ah,00ch,001h,001h,002h,002h	; 78c0  ........
	defb 004h,004h,008h,008h,010h,010h,020h,020h	; 78c8  ......  
	defb 040h,040h,080h,080h,000h,010h,00ch,009h	; 78d0  @@......
	defb 004h,00eh,0c0h,030h,00ch,003h,000h,010h	; 78d8  ...0....
	defb 0c0h,030h,00ch,003h,000h,008h,00eh,006h	; 78e0  .0......
	defb 012h,00ch,080h,080h,040h,040h,020h,020h	; 78e8  ....@@  
	defb 010h,010h,008h,008h,004h,004h,002h,002h	; 78f0  ........
	defb 001h,001h,000h,010h,004h,00bh,00ch,00eh	; 78f8  ........
	defb 000h,002h,003h,00ch,030h,0c0h,000h,00ah	; 7900  ....0...
	defb 030h,0c0h,000h,00eh,010h,005h,00ah,013h	; 7908  0.......

; ----------------------------------------------------------------------
; DATOS posturas_del_atleta_en_el_aire: Seis punteros a patrones que 0x686D
;   sube cuando el atleta esta saltando.
;   0x7910..0x791c  (12 bytes)
DATA_posturas_del_atleta_en_el_aire:
	defw 07833h	; 7910
	defw 0784ah	; 7912
	defw 075feh	; 7914
	defw 076f4h	; 7916
	defw 07861h	; 7918
	defw 0787ch	; 791a

; ======================================================================
; CODIGO 0x791c..0x7aaf  (403 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  LOS ACTORES  ==========
; Un actor es una ficha de dieciseis bytes en RAM (0xE120, 0xE130,
; 0xE140 y 0xE150) con: +0 banderas, +1 cuenta, +2 escalon, +6 columna
; dentro de la figura, +7/+8 direccion de VRAM, +9/+0A la ficha que le
; releva, +0B la fila de la tabla de ajuste, +0C columna calculada,
; +0D/+0E la figura y +0F cuantos caracteres se pintan.
; Las cuatro fichas van SEGUIDAS en memoria, y de ahi el truco: el bit 2
; hace que el actor empuje al de DELANTE y el bit 3 al de DETRAS,
; sumando o restando 0x11 al puntero. Asi se arrastran unos a otros.
; ----------------------------------------------------------------------
MUEVE_Y_PINTA_UN_ACTOR:
	push hl			;791c   ; IX apunta a la ficha
	pop ix		;791d
	inc hl			;791f
	ld a,(hl)			;7920   ; la cuenta
	cp 002h		;7921
	ret c			;7923   ; por debajo de dos no se mueve
	call ADELANTA_LA_ANIMACION		;7924   ; adelanta la animacion
	call CALCULA_LA_COLUMNA		;7927   ; y calcula en que columna cae
PINTA_SI_ESTA_ENCENDIDO:
	bit 0,(ix+000h)		;792a   ; bit 0: el actor esta encendido
	ret z			;792e
	bit 6,(ix+000h)		;792f
	jp nz,MONTA_LA_VALLA		;7933
PINTA_UN_ACTOR:
	call MONTA_LA_FIGURA		;7936   ; monta la figura en el papel
	jp SUBE_LA_FIGURA		;7939   ; y la sube a la VRAM
ADELANTA_LA_ANIMACION:
	push ix		;793c
	pop hl			;793e
	inc hl			;793f   ; la cuenta
	ld a,(hl)			;7940
	cp 002h		;7941
	ret c			;7943   ; por debajo de dos se acabo
	dec (hl)			;7944   ; baja de dos en dos
	dec (hl)			;7945
	inc hl			;7946
	inc (hl)			;7947   ; y el escalon sube de uno en uno
	ld a,(ix+000h)		;7948
	and 006h		;794b
	jr nz,MIRA_SI_EMPUJA_AL_DE_DETRAS		;794d
	push hl			;794f
	ld de,00011h		;7950   ; 0x11 hacia atras es la cuenta de la ficha anterior
	sbc hl,de		;7953
	inc (hl)			;7955
NO_HAY_ACTOR_DELANTE:
	pop hl			;7956
MIRA_SI_EMPUJA_AL_DE_DETRAS:
	bit 3,(ix+000h)		;7957   ; bit 3: empuja al de detras
	jr z,MIRA_EL_ESCALON		;795b
	push hl			;795d
	ld de,0000fh		;795e   ; 0x0F hacia delante es la cuenta de la siguiente
	add hl,de			;7961
	inc (hl)			;7962   ; y la sube de dos en dos
	inc (hl)			;7963
	pop hl			;7964
MIRA_EL_ESCALON:
	ld a,(hl)			;7965   ; el escalon
	inc hl			;7966
	inc (hl)			;7967   ; la columna sube de dos en dos
	inc (hl)			;7968
	cp 004h		;7969   ; hasta cuatro escalones se sigue moviendo
	jr c,ADELANTA_LA_ANIMACION		;796b
	dec hl			;796d
	xor a			;796e   ; el escalon se reinicia
	ld (hl),a			;796f
	ld a,(ix+000h)		;7970
	rrca			;7973
	jr nc,GASTA_LA_ESPERA_DEL_ACTOR		;7974
	rrca			;7976
	ret c			;7977
	dec (ix+00fh)		;7978
	jr nz,SALTA_DOS_BYTES		;797b
	inc (ix+00fh)		;797d
SALTA_DOS_BYTES:
	inc hl			;7980
	inc hl			;7981
	inc hl			;7982
	inc hl			;7983
	inc hl			;7984
	dec (hl)			;7985   ; la parte baja de la direccion de VRAM
	ld a,(hl)			;7986
	and 01fh		;7987   ; los cinco bits de la fila
	cp 01fh		;7989
	jr nz,ADELANTA_LA_ANIMACION		;798b
	inc (hl)			;798d   ; al pasar de 0x1F se sube una fila
	dec hl			;798e
	inc (hl)			;798f
	jr ADELANTA_LA_ANIMACION		;7990
GASTA_LA_ESPERA_DEL_ACTOR:
	inc hl			;7992
	inc hl			;7993
	dec (hl)			;7994   ; la espera corta
	jr nz,ADELANTA_LA_ANIMACION		;7995
	inc hl			;7997
	ld a,(hl)			;7998   ; y la larga
	or a			;7999
	jr z,ENCIENDE_EL_ACTOR		;799a
	dec (hl)			;799c
	jr nz,ADELANTA_LA_ANIMACION		;799d
ENCIENDE_EL_ACTOR:
	set 0,(ix+000h)		;799f   ; al acabarse, el actor se enciende
	jr ADELANTA_LA_ANIMACION		;79a3
MONTA_LA_FIGURA:
	ld l,(ix+00dh)		;79a5   ; el puntero a la figura
	ld h,(ix+00eh)		;79a8
	ld de,0e230h		;79ab   ; el papel donde se monta
UNA_ORDEN_DE_LA_FIGURA:
	ld a,(hl)			;79ae
	or a			;79af
	jr z,REPITE_UN_CODIGO		;79b0   ; 0x00 repite un codigo
	cp 001h		;79b2
	jr z,REPITE_SUBIENDO		;79b4   ; 0x01 lo repite subiendo
	cp 002h		;79b6
	jr z,CAMBIA_EL_DESPLAZAMIENTO		;79b8   ; 0x02 cambia el desplazamiento
	cp 0ffh		;79ba   ; 0xFF acaba la fila
	jr z,ACABA_LA_FILA		;79bc
	add a,c			;79be   ; y cualquier otro va con su desplazamiento
	ld (de),a			;79bf
	inc de			;79c0
	inc hl			;79c1
	jr UNA_ORDEN_DE_LA_FIGURA		;79c2
REPITE_UN_CODIGO:
	inc hl			;79c4
	ld a,(hl)			;79c5   ; el codigo
	inc hl			;79c6
	ld b,(hl)			;79c7   ; y cuantas veces
	add a,c			;79c8
SUELTA_EL_CODIGO:
	ld (de),a			;79c9
	inc de			;79ca
	djnz SUELTA_EL_CODIGO		;79cb
	inc hl			;79cd
	jr UNA_ORDEN_DE_LA_FIGURA		;79ce
REPITE_SUBIENDO:
	inc hl			;79d0
	ld a,(hl)			;79d1   ; el primer codigo
	inc hl			;79d2
	ld b,(hl)			;79d3   ; y cuantos
	add a,c			;79d4
SUELTA_UNO_MAS:
	ld (de),a			;79d5
	inc a			;79d6   ; cada uno es el siguiente del anterior
	inc de			;79d7
	djnz SUELTA_UNO_MAS		;79d8
	inc hl			;79da
	jr UNA_ORDEN_DE_LA_FIGURA		;79db
CAMBIA_EL_DESPLAZAMIENTO:
	inc hl			;79dd
	ld c,(hl)			;79de   ; el paso
	ld b,(ix+002h)		;79df   ; por el escalon del actor
	xor a			;79e2
	inc b			;79e3
	dec b			;79e4
	jr z,GUARDA_EL_DESPLAZAMIENTO		;79e5
MULTIPLICA_EL_PASO:
	add a,c			;79e7
	djnz MULTIPLICA_EL_PASO		;79e8
GUARDA_EL_DESPLAZAMIENTO:
	ld c,a			;79ea
	inc hl			;79eb
	jr UNA_ORDEN_DE_LA_FIGURA		;79ec
ACABA_LA_FILA:
	ld (de),a			;79ee   ; dos 0xFF cierran la fila
	inc de			;79ef
	ld (de),a			;79f0
	inc hl			;79f1
	inc de			;79f2
	ld a,(hl)			;79f3   ; y otro 0xFF detras cierra la figura
	inc a			;79f4
	jr nz,UNA_ORDEN_DE_LA_FIGURA		;79f5
	dec a			;79f7
	ld (de),a			;79f8   ; con un tercero de cierre
	ret			;79f9
SUBE_LA_FIGURA:
	exx			;79fa
	ld a,(00006h)		;79fb   ; el puerto de datos del VDP
	ld c,a			;79fe
	exx			;79ff
	ld hl,0e230h		;7a00   ; el papel
	ld e,(ix+007h)		;7a03   ; la direccion de VRAM del actor
	ld d,(ix+008h)		;7a06
	call FIJA_ESCRITURA_CON_CANDADO		;7a09
	bit 1,(ix+000h)		;7a0c   ; bit 1: se sube tal cual, sin recortar
	jr nz,SUBE_LA_FIGURA_ENTERA		;7a10
	ld a,(ix+006h)		;7a12
	ld c,a			;7a15
	call SUMA_A_A_HL		;7a16
	ld b,(ix+00fh)		;7a19
	ld a,(hl)			;7a1c
	cp 0ffh		;7a1d
	jr z,MIRA_LA_FICHA_DE_RELEVO		;7a1f
MONTA_LA_FIGURA_EN:
	push bc			;7a21
SUBE_UNA_FILA_DE_LA_FIGURA:
	ld a,(hl)			;7a22
	cp 0ffh		;7a23   ; 0xFF acaba la fila
	jr z,SIGUIENTE_ORDEN_DE_LA_FIGURA		;7a25
	inc b			;7a27
	dec b			;7a28   ; mientras el ancho no se agote
	jr z,SIGUIENTE_CARACTER_DE_LA_FILA		;7a29
	inc b			;7a2b
	exx			;7a2c
	out (c),a		;7a2d   ; el codigo va a la VRAM
	exx			;7a2f
SIGUIENTE_CARACTER_DE_LA_FILA:
	inc hl			;7a30
	jr SUBE_UNA_FILA_DE_LA_FIGURA		;7a31
SIGUIENTE_ORDEN_DE_LA_FIGURA:
	pop bc			;7a33
SIGUIENTE_FILA:
	inc hl			;7a34
	inc hl			;7a35
	ld a,(hl)			;7a36   ; otro 0xFF cierra la figura
	cp 0ffh		;7a37
	ret z			;7a39
	call BAJA_UNA_FILA		;7a3a   ; baja una fila en la VRAM
	call FIJA_ESCRITURA_CON_CANDADO		;7a3d
	ld a,c			;7a40
	call SUMA_A_A_HL		;7a41
	jr MONTA_LA_FIGURA_EN		;7a44
MIRA_LA_FICHA_DE_RELEVO:
	ld l,(ix+009h)		;7a46   ; la ficha que releva a esta
	ld h,(ix+00ah)		;7a49
	ld a,h			;7a4c
	cp 0ffh		;7a4d
	jr z,BORRA_EL_ACTOR		;7a4f
	or a			;7a51
	jr z,APAGA_EL_ACTOR		;7a52   ; 0x00xx: hay que apagar
	push ix		;7a54
	pop de			;7a56
	jp COPIA_UNA_FICHA		;7a57   ; y si no, se carga encima
BORRA_EL_ACTOR:
	ld a,(ix+007h)		;7a5a
	or 01fh		;7a5d   ; la columna se lleva al final de la fila
	ld (ix+007h),a		;7a5f
	xor a			;7a62
	ld (ix+006h),a		;7a63   ; y el actor se queda sin figura
	dec a			;7a66
	ld (ix+00fh),a		;7a67   ; con el ancho a 0xFF
	ret			;7a6a
APAGA_EL_ACTOR:
	ld a,0ffh		;7a6b
	ld (ix+006h),a		;7a6d   ; sin figura
	res 0,(ix+000h)		;7a70   ; y apagado
	ret			;7a74
SUBE_LA_FIGURA_ENTERA:
	ld a,(hl)			;7a75
	ld b,020h		;7a76   ; 0x20 caracteres, la fila entera
	call REPITE_BYTE		;7a78
	inc hl			;7a7b
	ld a,(hl)			;7a7c
	inc a			;7a7d   ; hasta el 0xFF
	jr nz,SUBE_LA_FIGURA_ENTERA		;7a7e
	ret			;7a80
CALCULA_LA_COLUMNA:
	bit 0,(ix+000h)		;7a81   ; bit 0: apagado
	jr nz,COLUMNA_DEL_ACTOR		;7a85
	ld (ix+00ch),0ffh		;7a87   ; y entonces no se pinta nada
	ret			;7a8b
COLUMNA_DEL_ACTOR:
	ld a,(ix+007h)		;7a8c   ; la parte baja de la direccion de VRAM
	and 01fh		;7a8f   ; los cinco bits de la columna
	rlca			;7a91   ; por ocho
	rlca			;7a92
	rlca			;7a93
	cp 0f0h		;7a94
	ret nc			;7a96
	ld c,a			;7a97
	ld hl,07aafh		;7a98   ; la tabla de ajuste
	ld a,(ix+00bh)		;7a9b   ; con la fila que diga la ficha
	call SUMA_A_A_HL		;7a9e
	ld a,(hl)			;7aa1   ; se le suma
	add a,c			;7aa2
	ld c,a			;7aa3
	ld a,(ix+002h)		;7aa4   ; y el escalon cuenta doble
	add a,a			;7aa7
	ld b,a			;7aa8
	ld a,c			;7aa9
	sub b			;7aaa
	ld (ix+00ch),a		;7aab
	ret			;7aae

; ----------------------------------------------------------------------
; DATOS ajuste_de_la_figura: Cuatro bytes que 0x7A98 suma al calcular en que
;   columna cae la figura.
;   0x7aaf..0x7ab3  (4 bytes)
DATA_ajuste_de_la_figura:
	defb 000h,000h,000h,004h	; 7aaf

; ======================================================================
; CODIGO 0x7ab3..0x7b6d  (186 bytes)
; ======================================================================


MONTA_LA_VALLA:
	ld l,(ix+00dh)		;7ab3   ; la figura de la valla
	ld h,(ix+00eh)		;7ab6
	push hl			;7ab9
	ld de,0e230h		;7aba   ; la mitad de arriba va al papel de 0xE230
	call UNA_ORDEN_DE_LA_FIGURA		;7abd
	pop hl			;7ac0
	ld de,0e270h		;7ac1   ; y la de abajo al de 0xE270
	call UNA_ORDEN_DE_LA_FIGURA		;7ac4
	ld a,(ix+00fh)		;7ac7   ; el ancho de la figura
	cp 0f8h		;7aca   ; con 0xF8 se pasa a 0xF9
	jr nz,MIRA_SI_LA_VALLA_CABE		;7acc
	ld (ix+00fh),0f9h		;7ace
MIRA_SI_LA_VALLA_CABE:
	ld a,(ix+006h)		;7ad2   ; la columna del actor
	ld hl,0e230h		;7ad5   ; dentro del papel
	call SUMA_A_A_HL		;7ad8
	ld a,(hl)			;7adb
	cp 0ffh		;7adc   ; con 0xFF ahi ya no hay figura
	jr nz,PINTA_LA_VALLA		;7ade
	call RECALCULA_LA_DIRECCION		;7ae0   ; recalcula la direccion de VRAM
	ld (ix+007h),e		;7ae3   ; y la guarda en la ficha
	ld (ix+008h),d		;7ae6
	xor a			;7ae9
	ld (ix+006h),a		;7aea   ; la figura se pone a cero
	ld hl,0e125h		;7aed   ; la cuenta de la valla del jugador 1
	ld bc,07bf3h		;7af0   ; y la ficha que la releva
	bit 5,(ix+000h)		;7af3   ; bit 5: es la valla del jugador 2
	jr z,SUBE_LA_CUENTA_DE_LA_VALLA		;7af7
	inc hl			;7af9   ; entonces la del 2
	ld bc,07bffh		;7afa
SUBE_LA_CUENTA_DE_LA_VALLA:
	inc (hl)			;7afd   ; una valla mas
	ld a,(hl)			;7afe
	cp 00ah		;7aff   ; con diez se acabaron las vallas
	jr nz,PINTA_LA_MITAD_DE_ABAJO		;7b01
	push ix		;7b03   ; y se carga la ficha de relevo encima
	pop de			;7b05
	push bc			;7b06
	pop hl			;7b07
	jp COPIA_UNA_FICHA		;7b08
PINTA_LA_VALLA:
	call SUBE_LA_FIGURA		;7b0b   ; sube la mitad de arriba
	call RECALCULA_LA_DIRECCION		;7b0e   ; y recalcula la direccion
PINTA_LA_MITAD_DE_ABAJO:
	ld a,e			;7b11
	and 01fh		;7b12   ; la columna dentro de la fila
	cp 00ch		;7b14   ; por debajo de la doce no se pinta
	ret c			;7b16
	or 0e0h		;7b17   ; se lleva a la fila de abajo
	ld b,a			;7b19
	call FIJA_ESCRITURA_CON_CANDADO		;7b1a   ; y se fija la direccion
	ld hl,0e125h		;7b1d   ; la cuenta de la valla del jugador 1
	bit 5,(ix+000h)		;7b20   ; bit 5: la del jugador 2
	jr z,MIRA_LA_VALLA_QUE_TOCA		;7b24
	inc hl			;7b26
MIRA_LA_VALLA_QUE_TOCA:
	ld a,(hl)			;7b27   ; con nueve vallas se acabo
	cp 009h		;7b28
	ret z			;7b2a
	or a			;7b2b
	jr nz,SUBE_LA_MITAD_DE_ABAJO		;7b2c   ; a partir de la primera se pinta siempre
	ld a,e			;7b2e   ; la columna
	and 01fh		;7b2f
	cp 014h		;7b31   ; antes de la 0x14 no se pinta
	jr nc,SUBE_LA_MITAD_DE_ABAJO		;7b33
	ld a,(ix+007h)		;7b35   ; y la parte baja de la direccion de VRAM
	and 01fh		;7b38
	or a			;7b3a
	ret nz			;7b3b
SUBE_LA_MITAD_DE_ABAJO:
	ld hl,0e270h		;7b3c   ; el papel de abajo
	ld c,000h		;7b3f
	jp MONTA_LA_FIGURA_EN		;7b41
RECALCULA_LA_DIRECCION:
	ld e,(ix+007h)		;7b44   ; la direccion de VRAM de la ficha
	ld d,(ix+008h)		;7b47
	ld a,014h		;7b4a   ; 0x14 columnas mas alla
	add a,e			;7b4c
	ld c,(ix+006h)		;7b4d   ; menos la columna del actor
	sub c			;7b50
	ld e,a			;7b51
	ret			;7b52
MONTA_LOS_ACTORES_DE_LA_PRUEBA:
	ld hl,07babh		;7b53   ; la ficha del atleta
	ld de,0e120h		;7b56   ; siempre va en 0xE120
	call COPIA_UNA_FICHA		;7b59
	ld hl,07b6bh		;7b5c   ; y la cadena de esta prueba
	call CASILLA_DE_LA_PRUEBA		;7b5f
	ld de,0e130h		;7b62   ; empezando en 0xE130
MONTA_UNA_FICHA_MAS:
	call COPIA_UNA_FICHA		;7b65   ; cada una se lleva los dieciseis bytes siguientes
	ld a,(hl)			;7b68   ; hasta el 0xFF
	inc a			;7b69
	jr nz,MONTA_UNA_FICHA_MAS		;7b6a
	ret			;7b6c

; ----------------------------------------------------------------------
; DATOS fichas_de_la_prueba: Un puntero por prueba a la cadena de fichas de
;   actor que se copia a 0xE130 en adelante. 0x7B5C los indexa desde uno, con
;   la direccion dos bytes antes.
;   0x7b6d..0x7b75  (8 bytes)
DATA_fichas_de_la_prueba:
	defw 07bb6h	; 7b6d  -> DATA_fichas_de_las_110_vallas
	defw 07c93h	; 7b6f  -> DATA_fichas_de_la_jabalina
	defw 07b93h	; 7b71  -> DATA_fichas_del_salto_de_altura
	defw 07ce7h	; 7b73  -> DATA_fichas_de_los_1500_metros

; ======================================================================
; CODIGO 0x7b75..0x7b8c  (23 bytes)
; ======================================================================


COPIA_UNA_FICHA:
	ld c,010h		;7b75   ; dieciseis bytes por ficha
UN_BYTE_DE_LA_FICHA:
	ld a,(hl)			;7b77
	or a			;7b78   ; el cero abre una racha
	jr z,RACHA_DE_CEROS		;7b79
	ld (de),a			;7b7b
	inc de			;7b7c
	inc hl			;7b7d
	dec c			;7b7e
	jr nz,UN_BYTE_DE_LA_FICHA		;7b7f
	ret			;7b81
RACHA_DE_CEROS:
	inc hl			;7b82
	ld b,(hl)			;7b83   ; cuantos
	inc hl			;7b84
SUELTA_UN_CERO:
	ld (de),a			;7b85
	dec c			;7b86
	inc de			;7b87
	djnz SUELTA_UN_CERO		;7b88
	jr UN_BYTE_DE_LA_FICHA		;7b8a

; ----------------------------------------------------------------------
; DATOS figura_del_liston: Figura del decorado que 0x79A5 expande a codigos de
;   caracter.
;   0x7b8c..0x7b93  (7 bytes)
DATA_figura_del_liston:
	defb 002h,002h,004h,00ch,014h,0ffh,0ffh	; 7b8c

; ----------------------------------------------------------------------
; DATOS fichas_del_salto_de_altura: Cadena de una ficha de actor de dieciseis
;   bytes, comprimida con rachas de ceros.
;   0x7b93..0x7b9e  (11 bytes)
DATA_fichas_del_salto_de_altura:
	defb 001h,000h,006h,0a4h,079h,000h,004h,09eh	; 7b93  ....y...
	defb 07bh,001h,0ffh	; 7b9b

; ----------------------------------------------------------------------
; DATOS figura_del_salto_de_altura: Otra figura del decorado.
;   0x7b9e..0x7bab  (13 bytes)
DATA_figura_del_salto_de_altura:
	defb 002h,000h,001h,0a0h,00ah,0a0h,001h,078h	; 7b9e  .......x
	defb 005h,0a0h,0a0h,0ffh,0ffh	; 7ba6

; ----------------------------------------------------------------------
; DATOS ficha_del_atleta: La ficha que 0x7B53 copia siempre a 0xE120.
;   0x7bab..0x7bb6  (11 bytes)
DATA_ficha_del_atleta:
	defb 003h,000h,007h,079h,0abh,07bh,000h,002h	; 7bab  ...y.{..
	defb 08ch,07bh,001h	; 7bb3

; ----------------------------------------------------------------------
; DATOS fichas_de_las_110_vallas: Cadena de tres fichas para 0xE130, 0xE140 y
;   0xE150.
;   0x7bb6..0x7bdb  (37 bytes)
DATA_fichas_de_las_110_vallas:
	defb 001h,000h,006h,084h,079h,0ffh,0ffh,000h	; 7bb6  ....y...
	defb 002h,00bh,07ch,001h,001h,000h,006h,0eah	; 7bbe  ..|.....
	defb 079h,0dbh,07bh,000h,002h,021h,07ch,001h	; 7bc6  y.{..!|.
	defb 005h,000h,006h,0aah,07ah,0e7h,07bh,000h	; 7bce  ....z.{.
	defb 002h,021h,07ch,001h,0ffh	; 7bd6

; ----------------------------------------------------------------------
; DATOS fichas_de_relevo: Las fichas que 0x7A46 y el trozo de 0x7AF0 cargan
;   encima de otra cuando la animacion cambia.
;   0x7bdb..0x7c0b  (48 bytes)
DATA_fichas_de_relevo:
	defb 041h,000h,006h,0bfh,079h,093h,07ch,002h	; 7bdb  A...y.|.
	defb 0ffh,047h,07ch,0ffh,065h,000h,006h,07fh	; 7be3  .G|.e...
	defb 07ah,093h,07ch,002h,0ffh,047h,07ch,0ffh	; 7beb  z.|..G|.
	defb 001h,000h,006h,0ffh,079h,0c2h,07bh,001h	; 7bf3  ....y.{.
	defb 0ffh,021h,07ch,0ffh,005h,000h,006h,0bfh	; 7bfb  .!|.....
	defb 07ah,0ceh,07bh,001h,0ffh,021h,07ch,0ffh	; 7c03  z.{..!|.

; ----------------------------------------------------------------------
; DATOS figuras_de_las_110_vallas: Las figuras del decorado de las pruebas de
;   carrera, incluidas las vallas.
;   0x7c0b..0x7c93  (136 bytes)
DATA_figuras_de_las_110_vallas:
	defb 002h,00dh,001h,0a8h,00dh,002h,000h,000h	; 7c0b  ........
	defb 0a8h,002h,002h,005h,001h,094h,005h,002h	; 7c13  ........
	defb 000h,000h,0a8h,004h,0ffh,0ffh,002h,003h	; 7c1b  ........
	defb 074h,075h,076h,002h,001h,064h,002h,000h	; 7c23  tuv..d..
	defb 067h,067h,0ffh,002h,003h,010h,011h,012h	; 7c2b  gg......
	defb 002h,001h,068h,002h,000h,06bh,0ffh,002h	; 7c33  ..h..k..
	defb 000h,01ch,002h,003h,01ch,01dh,01eh,002h	; 7c3b  ........
	defb 001h,06ch,0ffh,0ffh,002h,003h,028h,029h	; 7c43  .l....()
	defb 02ah,002h,001h,070h,002h,000h,000h,073h	; 7c4b  *..p...s
	defb 003h,0ffh,060h,002h,003h,034h,035h,036h	; 7c53  ..`..456
	defb 002h,001h,060h,002h,000h,000h,063h,003h	; 7c5b  ..`...c.
	defb 0ffh,002h,004h,040h,041h,042h,043h,002h	; 7c63  ...@ABC.
	defb 001h,064h,002h,000h,067h,067h,0ffh,002h	; 7c6b  .d..gg..
	defb 000h,06bh,06bh,002h,002h,050h,051h,002h	; 7c73  .kk..PQ.
	defb 001h,068h,002h,000h,06bh,06bh,0ffh,002h	; 7c7b  .h..kk..
	defb 000h,06fh,06fh,002h,002h,058h,059h,002h	; 7c83  .oo..XY.
	defb 001h,06ch,002h,000h,06fh,06fh,0ffh,0ffh	; 7c8b  .l..oo..

; ----------------------------------------------------------------------
; DATOS fichas_de_la_jabalina: Cadena de dos fichas para 0xE130 y 0xE140.
;   0x7c93..0x7cae  (27 bytes)
DATA_fichas_de_la_jabalina:
	defb 001h,000h,006h,0a4h,079h,0ffh,0ffh,000h	; 7c93  ....y...
	defb 002h,0aeh,07ch,001h,000h,004h,038h,000h	; 7c9b  ..|...8.
	defb 002h,07fh,07ah,000h,002h,003h,0ffh,0c2h	; 7ca3  ..z.....
	defb 07ch,0ffh,0ffh	; 7cab

; ----------------------------------------------------------------------
; DATOS figuras_de_la_jabalina: Las figuras del pasillo y la linea de nulo.
;   0x7cae..0x7ce7  (57 bytes)
DATA_figuras_de_la_jabalina:
	defb 002h,00eh,001h,0a0h,00eh,002h,000h,0a0h	; 7cae  ........
	defb 0a0h,002h,005h,001h,078h,005h,002h,000h	; 7cb6  ....x...
	defb 0a0h,0a0h,0ffh,0ffh,002h,002h,00ah,00bh	; 7cbe  ........
	defb 002h,000h,00bh,00bh,0ffh,002h,002h,012h	; 7cc6  ........
	defb 013h,002h,000h,013h,013h,0ffh,002h,002h	; 7cce  ........
	defb 01ah,01bh,002h,000h,01bh,01bh,0ffh,002h	; 7cd6  ........
	defb 002h,022h,023h,002h,000h,023h,023h,0ffh	; 7cde  ."#..##.
	defb 0ffh	; 7ce6

; ----------------------------------------------------------------------
; DATOS fichas_de_los_1500_metros: Cadena de tres fichas.
;   0x7ce7..0x7d0c  (37 bytes)
DATA_fichas_de_los_1500_metros:
	defb 001h,000h,006h,084h,079h,0ffh,0ffh,000h	; 7ce7  ....y...
	defb 002h,00bh,07ch,001h,001h,000h,006h,0eah	; 7cef  ..|.....
	defb 079h,00ch,07dh,000h,002h,021h,07ch,001h	; 7cf7  y.}..!|.
	defb 005h,000h,006h,0aah,07ah,01bh,07dh,000h	; 7cff  ....z.}.
	defb 002h,021h,07ch,001h,0ffh	; 7d07

; ----------------------------------------------------------------------
; DATOS fichas_de_relevo_2: Dos fichas mas de relevo.
;   0x7d0c..0x7d2b  (31 bytes)
DATA_fichas_de_relevo_2:
	defb 000h,004h,044h,00ch,000h,001h,0ffh,079h	; 7d0c  ..D....y
	defb 00ch,07dh,001h,0ffh,021h,07ch,0ffh,004h	; 7d14  .}..!|..
	defb 000h,003h,044h,00ch,000h,001h,0bfh,07ah	; 7d1c  ..D....z
	defb 01bh,07dh,001h,0ffh,021h,07ch,0ffh	; 7d24

; ======================================================================
; CODIGO 0x7d2b..0x7ef5  (458 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  EL VUELO DE LA JABALINA Y DEL SALTO  ==========
; La unica cuenta de verdad del cartucho. Con la velocidad de carrera y
; el angulo saca el avance y la altura de cada cuadro, y la marca en
; metros. Se apoya en tres rutinas de aritmetica escritas a mano:
; 0x7E75 divide desplazando y restando, 0x7E93 multiplica desplazando y
; sumando, y 0x7EB7 pasa un numero binario a BCD doblandolo en BCD.
; El seno sale de la tabla de 0x7EF5, un byte por grado.
; ----------------------------------------------------------------------
AVANZA_EL_TIRO:
	ld hl,(0e0afh)		;7d2b   ; la velocidad de salida
	push hl			;7d2e
	ld de,00546h		;7d2f   ; el tope es 0x546
	sbc hl,de		;7d32
	pop hl			;7d34
	jr c,CALCULA_EL_TIRO		;7d35   ; y si se pasa, se usa el tope
	ex de,hl			;7d37
CALCULA_EL_TIRO:
	ld a,l			;7d38   ; al reves, que es como lo quiere la division
	ld l,h			;7d39
	ld h,a			;7d3a
	ld (0e220h),hl		;7d3b
	ld hl,0e222h		;7d3e   ; el divisor
	ld (hl),000h		;7d41
	inc hl			;7d43
	exx			;7d44
	ld a,d			;7d45
	exx			;7d46
	ld (hl),a			;7d47
	call DIVIDE		;7d48   ; divide
	ld hl,(0e221h)		;7d4b   ; el cociente
	ld (0e100h),hl		;7d4e
	ld a,(0e032h)		;7d51   ; el angulo
	push af			;7d54
	add a,0a5h		;7d55   ; su complemento a 90 grados
	cpl			;7d57
	ld de,0e103h		;7d58   ; y de ahi sale el coseno
	call EL_SENO_DEL_ANGULO		;7d5b
	ld hl,(0e220h)		;7d5e   ; la velocidad
	ld (0e104h),hl		;7d61
	ld hl,0e109h		;7d64   ; el ajuste de 0x41
	ld a,(hl)			;7d67
	add a,041h		;7d68
	ld (hl),a			;7d6a
	dec hl			;7d6b
	ld a,(hl)			;7d6c
	adc a,000h		;7d6d
	ld (hl),a			;7d6f
	ld de,0e102h		;7d70   ; el angulo tal cual
	pop af			;7d73
	call EL_SENO_DEL_ANGULO		;7d74   ; da el seno
	ld de,0e221h		;7d77   ; y la parte vertical sale de restarlo
	ld hl,0e109h		;7d7a
	ld a,(de)			;7d7d
	sub (hl)			;7d7e
	ld (de),a			;7d7f
	dec de			;7d80
	dec hl			;7d81
	ld a,(de)			;7d82
	sbc a,(hl)			;7d83
	ld (de),a			;7d84
	ld hl,(0e220h)		;7d85   ; la velocidad otra vez
	ld (0e106h),hl		;7d88
	ld hl,0e10ch		;7d8b
	ld b,002h		;7d8e
ACUMULA_LAS_DOS_COMPONENTES:
	or a			;7d90
	ld de,0e105h		;7d91   ; el avance del cuadro
	call SUMA_TRES_BYTES		;7d94
	ld a,000h		;7d97
	adc a,(hl)			;7d99
	ld (hl),a			;7d9a
	ld hl,0e112h		;7d9b   ; y la altura
	djnz ACUMULA_LAS_DOS_COMPONENTES		;7d9e
ACUMULA_LA_ALTURA:
	ld hl,0e10fh		;7da0
	ld de,0e107h		;7da3   ; la componente vertical
	call SUMA_TRES_BYTES		;7da6
	push af			;7da9
	ld a,(de)			;7daa   ; el signo manda en el acarreo
	bit 7,a		;7dab
	jr z,PASA_EL_TIRO_A_METROS		;7dad
	dec b			;7daf
PASA_EL_TIRO_A_METROS:
	pop af			;7db0
	ld a,b			;7db1
	adc a,(hl)			;7db2
	ld (hl),a			;7db3
	ld de,0e220h		;7db4   ; el avance acumulado
	ld hl,0e10ah		;7db7
	ld bc,00003h		;7dba
	ldir		;7dbd
	exx			;7dbf
	ld a,b			;7dc0
	exx			;7dc1
	ld (de),a			;7dc2
	call DIVIDE		;7dc3   ; lo divide
	ld hl,0e221h		;7dc6
	ld a,(hl)			;7dc9
	inc hl			;7dca
	rrd		;7dcb   ; mueve el nibble de sitio
	ld a,(hl)			;7dcd
	ld de,0e114h		;7dce
	ex de,hl			;7dd1
	sub (hl)			;7dd2   ; la altura de este cuadro
	ld (0e117h),a		;7dd3
	ld a,(de)			;7dd6
	ld (hl),a			;7dd7
	dec hl			;7dd8
	dec de			;7dd9
	ld a,(de)			;7dda   ; los cuatro bits de arriba
	and 0f0h		;7ddb
	rrca			;7ddd
	rrca			;7dde
	rrca			;7ddf
	rrca			;7de0
	ld (hl),a			;7de1
	dec de			;7de2
	ld hl,0e10dh		;7de3
	bit 7,(hl)		;7de6   ; con el bit 7 puesto el tiro baja
	jr z,TIRO_QUE_BAJA		;7de8
	inc b			;7dea
TIRO_QUE_BAJA:
	push bc			;7deb
	jr z,TIRO_QUE_SUBE		;7dec   ; si baja, se cambia de signo
	inc hl			;7dee
	inc hl			;7def
	inc de			;7df0
	inc de			;7df1
	ld b,003h		;7df2
	scf			;7df4
CAMBIA_DE_SIGNO:
	ld a,(hl)			;7df5
	cpl			;7df6   ; complemento a dos de tres bytes
	adc a,000h		;7df7
	ld (de),a			;7df9
	dec de			;7dfa
	dec hl			;7dfb
	djnz CAMBIA_DE_SIGNO		;7dfc
	ld de,0e223h		;7dfe
	jr GUARDA_EL_TIRO		;7e01
TIRO_QUE_SUBE:
	ld c,003h		;7e03   ; tres bytes tal cual
	ldir		;7e05
GUARDA_EL_TIRO:
	exx			;7e07
	ld a,c			;7e08
	exx			;7e09
	ld (de),a			;7e0a
	call DIVIDE		;7e0b   ; el divisor
	ld hl,0e221h		;7e0e   ; el dividendo
	ld b,002h		;7e11
	ld c,(hl)			;7e13
	ld (hl),000h		;7e14
	inc hl			;7e16
	ld a,(hl)			;7e17
	ld (hl),c			;7e18
DESPLAZA_EL_RESULTADO:
	rlca			;7e19   ; dos desplazamientos a la izquierda, o sea por cuatro
	rl (hl)		;7e1a
	dec hl			;7e1c
	rl (hl)		;7e1d
	inc hl			;7e1f
	djnz DESPLAZA_EL_RESULTADO		;7e20
	ld de,0e116h		;7e22
	ex de,hl			;7e25
	pop bc			;7e26
	ld a,b			;7e27   ; con signo, la altura va restando
	or a			;7e28
	jr z,ALTURA_QUE_SUBE		;7e29
	ld a,(de)			;7e2b   ; cambiada de signo
	neg		;7e2c
	sub (hl)			;7e2e
	ld (0e118h),a		;7e2f
	ld a,(de)			;7e32
	neg		;7e33
	jr GUARDA_LA_ALTURA		;7e35
ALTURA_QUE_SUBE:
	ld a,(de)			;7e37
	sub (hl)			;7e38   ; la altura de este cuadro
	ld (0e118h),a		;7e39
	ld a,(de)			;7e3c
GUARDA_LA_ALTURA:
	ld (hl),a			;7e3d
	ld hl,(0e110h)		;7e3e   ; la marca acumulada
	ld (0e220h),hl		;7e41
	call PASA_A_BCD		;7e44   ; se pasa a BCD
	ld hl,0e222h		;7e47   ; y se guarda en metros
	ld de,0e119h		;7e4a
	ld bc,00003h		;7e4d
	ldir		;7e50
	ret			;7e52
EL_SENO_DEL_ANGULO:
	ld hl,07ef5h		;7e53   ; la tabla del seno
	call SUMA_A_A_HL		;7e56
	ld a,(hl)			;7e59   ; el valor del angulo
	ld (de),a			;7e5a
	ld hl,(0e100h)		;7e5b   ; la velocidad
	ld (0e220h),hl		;7e5e
	ld hl,0e222h		;7e61
	ld (hl),000h		;7e64
	inc hl			;7e66
	ld a,(de)			;7e67   ; y el seno de multiplicador
	ld (hl),a			;7e68
	jp MULTIPLICA		;7e69
SUMA_TRES_BYTES:
	call SUMA_UN_BYTE		;7e6c
	dec de			;7e6f
SUMA_UN_BYTE:
	ld a,(de)			;7e70
	adc a,(hl)			;7e71
	ld (hl),a			;7e72
	dec hl			;7e73
	ret			;7e74
DIVIDE:
	ld c,010h		;7e75   ; dieciseis vueltas, un bit de cociente por vuelta
UNA_VUELTA_DE_DIVISION:
	ld hl,0e222h		;7e77
	or a			;7e7a
	ld b,003h		;7e7b   ; tres bytes de dividendo
DESPLAZA_EL_DIVIDENDO:
	rl (hl)		;7e7d
	dec hl			;7e7f
	djnz DESPLAZA_EL_DIVIDENDO		;7e80
	inc hl			;7e82
	ex de,hl			;7e83
	ld hl,0e223h		;7e84   ; el divisor
	ld a,(de)			;7e87   ; se resta si cabe
	sub (hl)			;7e88
	jr c,SIGUIENTE_VUELTA_DE_DIVISION		;7e89
	ld (de),a			;7e8b
	dec hl			;7e8c
	set 0,(hl)		;7e8d   ; y se apunta el bit del cociente
SIGUIENTE_VUELTA_DE_DIVISION:
	dec c			;7e8f
	jr nz,UNA_VUELTA_DE_DIVISION		;7e90
	ret			;7e92
MULTIPLICA:
	ld b,010h		;7e93   ; dieciseis vueltas
UNA_VUELTA_DE_MULTIPLICACION:
	ld hl,0e222h		;7e95
	or a			;7e98
	rl (hl)		;7e99   ; tres bytes a la izquierda
	dec hl			;7e9b
	rl (hl)		;7e9c
	dec hl			;7e9e
	rl (hl)		;7e9f
	jr nc,SIGUIENTE_VUELTA_DE_MULTIPLICACION		;7ea1   ; si sale un uno, se suma el multiplicando
	ld hl,0e223h		;7ea3
	ld a,(hl)			;7ea6   ; tres bytes con acarreo
	dec hl			;7ea7
	add a,(hl)			;7ea8
	ld (hl),a			;7ea9
	dec hl			;7eaa
	ld a,(hl)			;7eab
	adc a,000h		;7eac
	ld (hl),a			;7eae
	dec hl			;7eaf
	ld a,(hl)			;7eb0
	adc a,000h		;7eb1
	ld (hl),a			;7eb3
SIGUIENTE_VUELTA_DE_MULTIPLICACION:
	djnz UNA_VUELTA_DE_MULTIPLICACION		;7eb4
	ret			;7eb6
PASA_A_BCD:
	ld hl,0e222h		;7eb7   ; el acumulador
	ld b,005h		;7eba   ; cinco bytes a cero
LIMPIA_EL_ACUMULADOR:
	ld (hl),000h		;7ebc
	inc hl			;7ebe
	djnz LIMPIA_EL_ACUMULADOR		;7ebf
	ld (hl),001h		;7ec1   ; y el ultimo a uno, que es la primera potencia
	ex de,hl			;7ec3
	ld hl,0e224h		;7ec4
	exx			;7ec7
	ld b,010h		;7ec8   ; dieciseis bits
UN_BIT_A_BCD:
	ld hl,0e220h		;7eca   ; el numero, dos bytes
	or a			;7ecd
	rr (hl)		;7ece   ; a la derecha
	inc hl			;7ed0
	rr (hl)		;7ed1
	exx			;7ed3
	jr nc,DOBLA_LA_POTENCIA		;7ed4   ; con el bit a cero solo se dobla la potencia
	push hl			;7ed6
	push de			;7ed7
	ld b,003h		;7ed8   ; tres bytes
	or a			;7eda
SUMA_LA_POTENCIA:
	ld a,(de)			;7edb   ; en BCD
	adc a,(hl)			;7edc
	daa			;7edd
	ld (hl),a			;7ede
	dec de			;7edf
	dec hl			;7ee0
	djnz SUMA_LA_POTENCIA		;7ee1
	pop de			;7ee3
	pop hl			;7ee4
DOBLA_LA_POTENCIA:
	push de			;7ee5
	ld b,003h		;7ee6   ; tres bytes
	or a			;7ee8
DOBLA_UN_BYTE_BCD:
	ld a,(de)			;7ee9   ; sumarse a si mismo es doblar
	adc a,a			;7eea
	daa			;7eeb
	ld (de),a			;7eec
	dec de			;7eed
	djnz DOBLA_UN_BYTE_BCD		;7eee
	pop de			;7ef0
	exx			;7ef1
	djnz UN_BIT_A_BCD		;7ef2
	ret			;7ef4

; ----------------------------------------------------------------------
; DATOS seno: El seno de 0 a 91 grados por 255, un byte por grado. Lo lee
;   0x7E53 con el angulo de lanzamiento.
;   0x7ef5..0x7f51  (92 bytes)
DATA_seno:
	defb 000h,004h,009h,00dh,012h,016h,01bh,01fh,023h,028h,02ch,031h,035h,039h,03eh,042h	; 7ef5  ........#(,159>B
	defb 046h,04bh,04fh,053h,057h,05bh,060h,064h,068h,06ch,070h,074h,078h,07ch,080h,083h	; 7f05  FKOSW[`dhlptx|..
	defb 087h,08bh,08fh,092h,096h,099h,09dh,0a0h,0a4h,0a7h,0abh,0adh,0b1h,0b3h,0b7h,0bah	; 7f15  ................
	defb 0beh,0c0h,0c3h,0c6h,0c9h,0cch,0ceh,0d1h,0d3h,0d6h,0d8h,0dbh,0ddh,0dfh,0e1h,0e3h	; 7f25  ................
	defb 0e5h,0e7h,0e9h,0ebh,0ech,0eeh,0f0h,0f1h,0f3h,0f4h,0f5h,0f6h,0f7h,0f8h,0f9h,0fah	; 7f35  ................
	defb 0fbh,0fch,0fdh,0fdh,0feh,0feh,0feh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f45  ............

; ======================================================================
; CODIGO 0x7f51..0x7ffe  (173 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ==========  MONTAR EL SPRITE DEL ATLETA  ==========
; El atleta no es un sprite: son SIETE, y cada postura los coloca a mano.
; 0x7F85 sube los patrones que hagan falta y despues escribe las siete
; filas de la tabla de atributos, sumando a cada una la fila y la
; columna del atleta.
; ----------------------------------------------------------------------
FICHA_DEL_QUE_JUEGA:
	ld hl,0e0b4h		;7f51   ; la del jugador 1
	ld b,001h		;7f54   ; y su numero de atleta
	call A_QUIEN_LE_TOCA		;7f56
	ret z			;7f59
	ld hl,0e0eah		;7f5a   ; o la del jugador 2
	dec b			;7f5d
	ret			;7f5e
COLUMNA_DEL_QUE_JUEGA:
	call FICHA_DEL_QUE_JUEGA		;7f5f
	inc hl			;7f62
	ret			;7f63
POSTURA_DEL_QUE_JUEGA:
	call FICHA_DEL_QUE_JUEGA		;7f64
	inc hl			;7f67
	inc hl			;7f68
	ret			;7f69
BOTON_DEL_QUE_JUEGA:
	ld hl,0e00bh		;7f6a   ; el del jugador 1
	call A_QUIEN_LE_TOCA		;7f6d
	ret z			;7f70
	ld hl,0e00fh		;7f71   ; o el del 2
	ret			;7f74
ACABA_EL_INTENTO_Y_ANIMA:
	ld hl,0e02eh		;7f75
	set 0,(hl)		;7f78   ; bit 0 de 0xE02E: intento acabado
CUENTA_DE_ANIMACION:
	ld hl,0e0bbh		;7f7a   ; la del jugador 1
	call A_QUIEN_LE_TOCA		;7f7d
	ret z			;7f80
	ld hl,0e0f1h		;7f81   ; o la del 2
	ret			;7f84
PINTA_AL_ATLETA:
	exx			;7f85
	ld hl,07b10h		;7f86   ; la fila de atributos del jugador 2
	ld de,05880h		;7f89   ; y sus patrones de sprite
	ld bc,0e0b6h		;7f8c   ; y su postura
	or a			;7f8f
	jr nz,SUBE_LOS_PATRONES		;7f90
	ld hl,07b2ch		;7f92   ; o los del jugador 1
	ld de,05960h		;7f95
	ld bc,0e0ech		;7f98
SUBE_LOS_PATRONES:
	ld a,(bc)			;7f9b   ; la postura
	dec bc			;7f9c   ; y de paso deja BC en la fila y la columna
	dec bc			;7f9d
	push bc			;7f9e
	push hl			;7f9f
	ld hl,0713ch		;7fa0   ; la tabla de posturas
	rlca			;7fa3
	call SUMA_A_A_HL		;7fa4
	ld a,(hl)			;7fa7   ; el registro de la postura
	inc hl			;7fa8
	ld h,(hl)			;7fa9
	ld l,a			;7faa
	ld b,(hl)			;7fab   ; cuantos trozos lleva
	inc hl			;7fac
UN_TROZO_DEL_ATLETA:
	push bc			;7fad
	push hl			;7fae
	ld a,(hl)			;7faf   ; el puntero al patron
	inc hl			;7fb0
	ld h,(hl)			;7fb1
	ld l,a			;7fb2
	xor a			;7fb3
	cp h			;7fb4   ; con el byte alto a cero no hay patron que subir
	jr z,SIGUIENTE_TROZO		;7fb5
	call SUBE_UN_PATRON_DE_SPRITE		;7fb7   ; y si lo hay, se sube comprimido
SIGUIENTE_TROZO:
	ld hl,00020h		;7fba   ; cada patron ocupa 0x20 bytes de VRAM
	add hl,de			;7fbd
	ex de,hl			;7fbe
	pop hl			;7fbf
	inc hl			;7fc0
	inc hl			;7fc1
	pop bc			;7fc2
	djnz UN_TROZO_DEL_ATLETA		;7fc3
	ld a,(hl)			;7fc5   ; detras del ultimo trozo va la lista de atributos
	inc hl			;7fc6
	ld h,(hl)			;7fc7
	ld l,a			;7fc8
	pop de			;7fc9
	pop bc			;7fca
	exx			;7fcb
	push bc			;7fcc
	ld a,(00006h)		;7fcd   ; el puerto de datos del VDP
	ld c,a			;7fd0
	exx			;7fd1
	ld a,007h		;7fd2   ; siete sprites
UN_SPRITE_DEL_ATLETA:
	ex af,af'			;7fd4
	call FIJA_ESCRITURA_CON_CANDADO		;7fd5   ; fija la fila de la tabla de atributos
	ld a,(hl)			;7fd8
	cp 0cfh		;7fd9   ; 0xCF es "no pintar"
	jr z,SUELTA_LA_COLUMNA		;7fdb
	ld a,(bc)			;7fdd   ; la fila de la lista mas la del atleta
	add a,(hl)			;7fde
	cp 0d0h		;7fdf   ; y 0xD0 se cambia por 0xCF para no esconderlo
	jr nz,SUELTA_LA_FILA		;7fe1
	ld a,0cfh		;7fe3
SUELTA_LA_FILA:
	exx			;7fe5
	out (c),a		;7fe6
	exx			;7fe8
	inc bc			;7fe9   ; la columna, sumada igual
	inc hl			;7fea
	ld a,(bc)			;7feb
	add a,(hl)			;7fec
	dec bc			;7fed
SUELTA_LA_COLUMNA:
	exx			;7fee
	out (c),a		;7fef   ; la suelta
	exx			;7ff1
	inc hl			;7ff2   ; el siguiente byte de la lista
	inc de			;7ff3   ; cuatro bytes por sprite
	inc de			;7ff4
	inc de			;7ff5
	inc de			;7ff6
	ex af,af'			;7ff7
	dec a			;7ff8   ; hasta los siete sprites
	jr nz,UN_SPRITE_DEL_ATLETA		;7ff9
	exx			;7ffb
	pop bc			;7ffc
	ret			;7ffd

; ----------------------------------------------------------------------
; DATOS relleno: Los dos bytes que sobran del cartucho, a 0xFF.
;   0x7ffe..0x8000  (2 bytes)
DATA_relleno:
	defb 0ffh,0ffh	; 7ffe
