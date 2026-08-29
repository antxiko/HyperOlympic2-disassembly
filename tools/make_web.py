#!/usr/bin/env python3
"""Genera la portada de la web, en los dos idiomas.

El diseno es el compartido por la serie (tools/estilo_web.py) y la pagina sale
autocontenida, con las imagenes embebidas como data URI.

Las imagenes NO son ilustraciones ni montajes. Unas son capturas del cartucho
corriendo en openMSX -hechas con tools/omsx_pruebas.tcl, que solo cambia el
numero de prueba de 0xE016 y deja que el juego dibuje con sus datos-, y otras
estan dibujadas a partir de los propios bytes de la ROM por tools/graficos.py y
por el interprete de guiones traducido a Python. Ninguna se ha retocado.

Uso: make_web.py <docs/imagenes> <salida.html> <idioma>
"""
import base64
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from estilo_web import ESTILO                                   # noqa: E402

# Las cifras salen de contar sobre el listado generado, no de escribirlas aqui
# a ojo: 16384 = 9872 + 6512, que es lo que imprime tools/presupuesto.py
# (make sanity). RUTINAS son las etiquetas de codigo con nombre propio, las
# mismas que cuenta el .notes con su directiva L. PRUEBAS son los cuatro
# valores que toma 0xE016.
CODIGO = 9872
DATOS = 6512
RUTINAS = 647
PRUEBAS = 4

# El porcentaje de codigo que este cartucho comparte con el hermano, medido con
# tools/comun_normalizado.py sobre las dos ROM con los operandos de dieciseis
# bits puestos a cero.
COMUN = "83,4"


def mil(n, idioma):
    return f"{n:,}".replace(",", "." if idioma == "es" else ",")


TXT = {
    "es": dict(
        titulo="Hyper Olympic 2 — desensamblado comentado",
        aviso="<b>Aquí no hay ninguna ilustración.</b> Las pantallas son "
              "capturas del cartucho corriendo en openMSX, tomadas por un "
              "guion que solo cambia el número de prueba que el propio juego "
              "usa como índice; el logotipo y la hoja de la fuente están "
              "<b>dibujados desde los bytes de la ROM</b>, ejecutando en "
              "Python el mismo intérprete de guiones que ejecuta el Z80. El "
              "listado y las cifras salen del binario y se reproducen con "
              "<code>make</code>.",
        claim="Cuatro pruebas nuevas sobre el programa del cartucho anterior: "
              "el 83,4 % de sus instrucciones están aquí, y el motor que allí "
              "hacía girar el martillo es el que aquí levanta al saltador de "
              "altura. Lo propio de éste cabe en 2.227 bytes — y en el rótulo "
              "de la primera prueba, que dice HURDLERS.",
        ficha=["Konami · <b>© Konami 1984</b>",
               "Cartucho <b>RC-711</b>, 16 KB",
               "MSX1 · <b>página 1</b>", "Volcado <b>f254764f…</b>"],
        nav=[("#numbers", "Las cifras"), ("#findings", "Hallazgos"),
             ("#screens", "Lo que dibuja")],
        docnav=[("EMPEZAR.html", "Empezar"), ("EL-JUEGO.html", "El juego"),
                ("EL-CARTUCHO.html", "El cartucho"),
                ("EL-CODIGO.html", "El código"),
                ("HALLAZGOS.html", "Hallazgos"),
                ("EN-EL-EMULADOR.html", "En el emulador"),
                ("PREGUNTAS-ABIERTAS.html", "Preguntas abiertas")],
        otro=("../", "In English"),
        h_num="El cartucho en cifras", h_find="Lo que apareció al desmontarlo",
        h_scr="Lo que el cartucho dibuja",
        cifras=[("100 %", "del binario explicado"),
                (str(RUTINAS), "rutinas identificadas"),
                (COMUN + " %", "de instrucciones del hermano"),
                (mil(CODIGO, "es"), "bytes de código"),
                (mil(DATOS, "es"), "bytes de datos"),
                ("0", "bytes sin identificar")],
        nota_scr="Debajo de cada imagen está de dónde sale y qué se está "
                 "viendo.",
        pie_leg="Esto es trabajo de documentación y preservación: el código y "
                "los gráficos siguen siendo de sus autores y de Konami, y la "
                "imagen del cartucho no se distribuye.",
    ),
    "en": dict(
        titulo="Hyper Olympic 2 — a commented disassembly",
        aviso="<b>There is not one illustration here.</b> The screens are "
              "captures of the cartridge running in openMSX, taken by a script "
              "that only changes the event number the game itself uses as an "
              "index; the logo and the font sheet are <b>drawn from the bytes "
              "of the ROM</b>, by running in Python the same script "
              "interpreter the Z80 runs. The listing and the numbers come from "
              "the binary and are reproducible with <code>make</code>.",
        claim="Four new events on top of the previous cartridge's program: "
              "83.4 % of its instructions are here, and the motor that span "
              "the hammer over there is the one that lifts the high jumper "
              "here. What belongs to this one fits in 2,227 bytes — and in the "
              "first event's label, which reads HURDLERS.",
        ficha=["Konami · <b>© Konami 1984</b>",
               "An <b>RC-711</b> 16 KB cartridge",
               "MSX1 · <b>page 1</b>", "Dump <b>f254764f…</b>"],
        nav=[("#numbers", "The numbers"), ("#findings", "What turned up"),
             ("#screens", "What it draws")],
        docnav=[("GETTING-STARTED.html", "Getting started"),
                ("THE-GAME.html", "The game"),
                ("THE-CARTRIDGE.html", "The cartridge"),
                ("THE-CODE.html", "The code"),
                ("FINDINGS.html", "Findings"),
                ("IN-THE-EMULATOR.html", "In the emulator"),
                ("OPEN-QUESTIONS.html", "Open questions")],
        otro=("es/", "En castellano"),
        h_num="The cartridge in numbers",
        h_find="What turned up when we took it apart",
        h_scr="What the cartridge draws",
        cifras=[("100%", "of the binary explained"),
                (str(RUTINAS), "routines identified"),
                ("83.4%", "of instructions from the sibling"),
                (mil(CODIGO, "en"), "bytes of code"),
                (mil(DATOS, "en"), "bytes of data"),
                ("0", "bytes unidentified")],
        nota_scr="Under each picture is where it comes from and what is on it.",
        pie_leg="This is documentation and preservation work: the code and "
                "artwork still belong to their authors and to Konami, and the "
                "cartridge image is not distributed.",
    ),
}

HALLAZGOS = {
    "es": [
        ("«110 HURDLERS»: la errata está en la ROM",
         "<p>El rótulo de la primera prueba tiene una R de más. No es la "
         "captura, ni el emulador, ni el recorte: <b>está escrita en los "
         "datos</b>. El rótulo de 0x64B1 lleva, detrás de su byte de cabecera, "
         "la tira de glifos</p>"
         "<pre class=\"asm\">0A 01 01 00 0A 12 1E 1B 0E 16 0F 1B 1C 0A</pre>"
         "<p>y en la fuente del cartucho (0x6197) esos índices son "
         "<code> 110 HURDLERS </code>. La captura solo enseña el resultado.</p>"),
        ("El motor del martillo levanta al saltador de altura",
         "<p>Las cuatro pruebas son nuevas, pero solo dos motores lo son. El "
         "de las 110 vallas y los 1500 metros es <b>el mismo</b> que movía las "
         "carreras del cartucho anterior. Y el del salto de altura (0x6A2C) es "
         "el que allí hacía girar el martillo: tomar impulso, marcar el ángulo "
         "con el botón y soltar.</p>"
         "<p>Cambia lo que se dibuja, no la mecánica. Lo que este cartucho "
         "añade de verdad son <b>2.227 bytes</b>, y sus cuatro tramos mayores son: "
         "el salto de la valla, el motor de la jabalina, el del salto de "
         "altura y el dibujo de la valla.</p>"),
        ("Derribar una valla no es una colisión",
         "<p>Es una comparación de columnas en un instante concreto. Mientras "
         "el atleta salta —postura 13, diez cuadros contados en 0x5A34—, "
         "0x5A5B compara su columna con la de la valla que le toca. <b>Si al "
         "acabar el salto están a menos de ocho columnas</b>, se pone el bit 4 "
         "de 0xE028 o de 0xE029.</p>"
         "<p>Ese bit es la caída: 0x5AA5 le pone la postura 14, le borra los "
         "cuatro bytes de velocidad y le mete 0x14 cuadros de levantarse. "
         "Fuera de ese instante, la valla y el atleta no se tocan.</p>"),
        ("La valla se dibuja en dos papeles",
         "<p>Un actor normal monta su figura en el papel de 0xE230 y la sube "
         "de una vez. La valla no cabe en una fila, así que 0x7AB3 monta la "
         "mitad de arriba en 0xE230 y la de abajo en 0xE270, y las sube por "
         "separado, cada una a su fila de la tabla de nombres.</p>"
         "<p><b>Es el único actor del cartucho que hace esto.</b></p>"),
        ("La tabla de récords se compiló antes de la temporada de 1983",
         "<p>0x517B lleva <code>00 12 93 / 00 96 72 / 00 02 36 / 00 03 31</code>, "
         "que INIT copia a 0xE040. Los cuatro son récords del mundo de verdad, "
         "pero <b>tres ya estaban batidos</b> cuando el cartucho llegó a las "
         "tiendas: Petranoff tiró la jabalina a 99,72 en mayo de 1983, Zhu "
         "Jianhua saltó 2,37 el 11 de junio, y Ovett bajó el 1500 a 3:30,77 en "
         "septiembre.</p>"
         "<p>El que aguanta es el más antiguo de todos, los 12,93 de Nehemiah "
         "de 1981. Las fechas no salen del cartucho: son un cotejo con las "
         "progresiones públicas. Del cartucho sale la cifra.</p>"),
        ("La fuente se quedó sin X y sin Z, y la Q llegó tarde",
         "<p>Los 51 glifos de 0x6197 van ordenados: 0..9, el espacio, y luego "
         "el alfabeto <b>de la A a la Y saltándose la Q, la X y la Z</b>. Con "
         "la A en el índice 0x0B, la P cae en 0x1A y la siguiente ya es la "
         "R.</p>"
         "<p>Y sin embargo la Q existe: está al final, en el índice "
         "<b>0x2C</b>, fuera del alfabeto. El motivo es la única palabra del "
         "juego que la necesita, el rótulo <b>QUALIFY</b> del marcador, que en "
         "0x611E es la tira <code>2C 1E 0B 16 13 10 21</code>.</p>"
         "<p>Esto es de lo que solo se ve <b>dibujando</b>: leyendo el bloque, "
         "los 51 glifos son 408 bytes iguales. La hoja está más abajo.</p>"),
        ("Un comentario portado puede mentir, y dos lo hacían",
         "<p>El 86,9 % de los comentarios de este cartucho son <b>idénticos</b> "
         "a uno del hermano: vienen portados con el código compartido, y eso "
         "los coloca en la dirección buena sin cambiar lo que dicen.</p>"
         "<p>Dos guardianes lo vigilan y los dos han cazado algo. "
         "<code>repasa_el_porte.py</code> comprueba que toda dirección citada "
         "exista aquí: encontró nueve que no. Y "
         "<code>cifras_portadas.py</code> comprueba que, cuando el comentario "
         "es idéntico, la instrucción anotada también lo sea: encontró los dos "
         "comentarios de 0x4389, que decían <b>«32 sprites»</b> cuando aquí el "
         "<code>ld bc,01afeh</code> carga <b>26</b>.</p>"),
        ("Doce bytes muertos que están en los dos cartuchos",
         "<p>En 0x4E64, pegados a los ocho registros del VDP, hay tres grupos "
         "de cuatro bytes con pinta de filas de la tabla de atributos de "
         "sprite: <code>00 70 38 70 / 00 A0 38 70 / 00 F0 38 F0</code>. "
         "<b>Ningún puntero de la ROM cae ahí</b> y nadie los lee.</p>"
         "<p>Están también en el cartucho anterior, byte a byte iguales y tan "
         "muertos como aquí. Los dos heredaron el mismo cadáver.</p>"),
        ("No pertenece a ninguna de las dos familias Konami ya medidas",
         "<p>Comparando el código con los operandos de dieciséis bits puestos "
         "a cero —para que una rutina reensamblada en otro sitio también se "
         "vea—, este cartucho comparte <b>6.298 bytes, el 63,8 %</b>, con su "
         "hermano. Con cualquier otro cartucho Konami de MSX de esta serie no "
         "llega al 2 %, y sus tramos comunes más largos van de 21 a 42 bytes, "
         "frente a los <b>681 seguidos</b> que comparte con el hermano.</p>"
         "<p>O sea que los dos Hyper Olympic no son ni el armazón de unos ni "
         "el de los otros. Son un <b>tercero</b>, y de momento solo tiene dos "
         "miembros. Las cifras completas están en Hallazgos.</p>"),
        ("No lleva la marca oculta de Konami",
         "<p>Muchos cartuchos de la casa esconden al final de la ROM su número "
         "de catálogo RC-7xx y el título en katakana, detrás del relleno; lo "
         "descubrió <b>Manuel Pazos</b> "
         "(<a href=\"https://twitter.com/ManuelPazosMSX\">@ManuelPazosMSX</a>).</p>"
         "<p>Aquí no está: los dos últimos bytes son <code>0xFF</code> y "
         "delante hay código del reproductor de sonido. Se comprobó con "
         "<code>tools/marca_konami.py</code>, que en el mismo tiro <b>sí</b> "
         "la encuentra en otro cartucho de la casa. El RC-711 viene del "
         "catálogo, no del binario.</p>"),
    ],
    "en": [
        ("“110 HURDLERS”: the typo is in the ROM",
         "<p>The first event's label has one R too many. It is not the "
         "capture, nor the emulator, nor the crop: <b>it is written into the "
         "data</b>. The label at 0x64B1 carries, behind its header byte, the "
         "glyph string</p>"
         "<pre class=\"asm\">0A 01 01 00 0A 12 1E 1B 0E 16 0F 1B 1C 0A</pre>"
         "<p>and in the cartridge's font (0x6197) those indices read "
         "<code> 110 HURDLERS </code>. The capture only shows the result.</p>"),
        ("The hammer motor lifts the high jumper",
         "<p>The four events are new, but only two of the motors are. The one "
         "for the 110 hurdles and the 1500 metres is <b>the same</b> that ran "
         "the previous cartridge's races. And the high jump one (0x6A2C) is "
         "the one that span the hammer over there: wind up, mark the angle "
         "with the button and let go.</p>"
         "<p>What changes is what gets drawn, not the mechanism. What this "
         "cartridge really adds is <b>2,227 bytes</b>, and its four largest runs are: "
         "places: the hurdle jump, the javelin motor, the high jump one and "
         "the drawing of the hurdle.</p>"),
        ("Knocking a hurdle over is not a collision",
         "<p>It is a comparison of columns at one specific instant. While the "
         "athlete jumps —pose 13, ten frames counted at 0x5A34— 0x5A5B "
         "compares his column with the column of the hurdle that is his. <b>If "
         "when the jump ends they are less than eight columns apart</b>, bit 4 "
         "of 0xE028 or 0xE029 gets set.</p>"
         "<p>That bit is the fall: 0x5AA5 gives him pose 14, wipes his four "
         "speed bytes and gives him 0x14 frames of getting back up. Outside "
         "that instant, the hurdle and the athlete never touch.</p>"),
        ("The hurdle is drawn on two sheets",
         "<p>A normal actor assembles its figure in the scratch area at 0xE230 "
         "and uploads it in one go. The hurdle does not fit in one row, so "
         "0x7AB3 assembles the top half at 0xE230 and the bottom half at "
         "0xE270, and uploads them separately, each to its own row of the name "
         "table.</p>"
         "<p><b>It is the only actor in the cartridge that does this.</b></p>"),
        ("The record table was compiled before the 1983 season",
         "<p>0x517B holds <code>00 12 93 / 00 96 72 / 00 02 36 / 00 03 31</code>, "
         "which INIT copies to 0xE040. All four are real world records, but "
         "<b>three had already been beaten</b> by the time the cartridge "
         "reached the shops: Petranoff threw the javelin 99.72 in May 1983, "
         "Zhu Jianhua cleared 2.37 on 11 June, and Ovett took the 1500 down to "
         "3:30.77 in September.</p>"
         "<p>The one that holds is the oldest of them all, Nehemiah's 12.93 "
         "from 1981. The dates do not come from the cartridge: they are a "
         "cross-check against the published progressions. What comes from the "
         "cartridge is the figure.</p>"),
        ("The font ran out of X and Z, and the Q arrived late",
         "<p>The 51 glyphs at 0x6197 are in order: 0..9, the space, and then "
         "the alphabet <b>from A to Y skipping Q, X and Z</b>. With A at index "
         "0x0B, P falls at 0x1A and the next one is already R.</p>"
         "<p>And yet the Q exists: it sits at the end, at index <b>0x2C</b>, "
         "outside the alphabet. The reason is the one word in the game that "
         "needs it, the scoreboard's <b>QUALIFY</b>, which at 0x611E is the "
         "string <code>2C 1E 0B 16 13 10 21</code>.</p>"
         "<p>This is the kind of thing you only see by <b>drawing it</b>: read "
         "as a block, the 51 glyphs are 408 bytes that all look alike. The "
         "sheet is further down.</p>"),
        ("A ported comment can lie, and two of them did",
         "<p>86.9 % of this cartridge's comments are <b>identical</b> to one in "
         "the sibling: they came over with the shared code, and that puts them "
         "at the right address without changing what they say.</p>"
         "<p>Two guards watch for it and both have caught something. "
         "<code>repasa_el_porte.py</code> checks that every cited address "
         "exists here: it found nine that did not. And "
         "<code>cifras_portadas.py</code> checks that, when the comment is "
         "identical, the instruction it annotates is too: it found the two "
         "comments at 0x4389, which said <b>“32 sprites”</b> when "
         "here the <code>ld bc,01afeh</code> loads <b>26</b>.</p>"),
        ("Twelve dead bytes that are in both cartridges",
         "<p>At 0x4E64, right next to the eight VDP registers, there are three "
         "groups of four bytes shaped like rows of the sprite attribute table: "
         "<code>00 70 38 70 / 00 A0 38 70 / 00 F0 38 F0</code>. <b>No pointer "
         "in the ROM lands there</b> and nobody reads them.</p>"
         "<p>They are also in the previous cartridge, byte for byte identical "
         "and just as dead as here. Both inherited the same corpse.</p>"),
        ("It belongs to neither of the two Konami families already measured",
         "<p>Comparing the code with all sixteen-bit operands zeroed —so that "
         "a routine reassembled somewhere else still shows up— this cartridge "
         "shares <b>6,298 bytes, 63.8 %</b>, with its sibling. With any other "
         "Konami MSX cartridge in this series it does not reach 2 %, and the "
         "longest common runs go from 21 to 42 bytes, against the <b>681 "
         "consecutive</b> ones it shares with the sibling.</p>"
         "<p>So the two Hyper Olympics are neither one framework nor the "
         "other. They are a <b>third</b>, and so far it has just two members. "
         "The full figures are in Findings.</p>"),
        ("It does not carry Konami's hidden mark",
         "<p>Many cartridges from the house hide their RC-7xx catalogue number "
         "and the game's title in katakana at the end of the ROM, behind the "
         "filler; it was <b>Manuel Pazos</b> "
         "(<a href=\"https://twitter.com/ManuelPazosMSX\">@ManuelPazosMSX</a>) "
         "who found that out.</p>"
         "<p>Not here: the last two bytes are <code>0xFF</code> and in front of "
         "them there is sound player code. It was checked with "
         "<code>tools/marca_konami.py</code>, which in the same run <b>does</b> "
         "find it in another cartridge from the house. The RC-711 comes from "
         "the catalogue, not from the binary.</p>"),
    ],
}

GALERIA = [
    ("titulo.png",
     "La pantalla del título, con el logotipo que monta el guion de "
     "<code>pantalla_del_menu</code> y las cuatro líneas del menú. La que se "
     "elija deja en 0xE01B un número del 1 al 4, y de ahí salen el número de "
     "jugadores y el mando",
     "The title screen, with the logo assembled by the "
     "<code>pantalla_del_menu</code> script and the four menu lines. Whichever "
     "you pick leaves a number from 1 to 4 in 0xE01B, and from that come the "
     "number of players and the controller"),
    ("prueba1-110vallas.png",
     "Prueba 1, las 110 vallas, con el récord de 12 SEC 93 y la errata del "
     "rótulo a la vista. Es una carrera normal más el salto de 0x5A1B: diez "
     "cuadros de postura 13 y una comparación de columnas al final",
     "Event 1, the 110 hurdles, with the 12 SEC 93 record and the label's typo "
     "in plain sight. It is an ordinary race plus the jump at 0x5A1B: ten "
     "frames of pose 13 and a comparison of columns at the end"),
    ("prueba2-jabalina.png",
     "Prueba 2, el lanzamiento de jabalina, con 96 M 72. La carrera es la "
     "misma rutina que la de las vallas; el vuelo sale de la única cuenta de "
     "verdad del cartucho, y el patrón que se sube cambia con la inclinación",
     "Event 2, the javelin throw, with 96 M 72. The run-up is the very routine "
     "used by the hurdles; the flight comes out of the only real piece of "
     "arithmetic in the cartridge, and the pattern uploaded changes with the "
     "angle"),
    ("prueba3-altura.png",
     "Prueba 3, el salto de altura, con 02 M 36. El motor (0x6A2C) es el que "
     "en el cartucho anterior hacía girar el martillo: se toma impulso, se "
     "marca el ángulo con el botón y se suelta",
     "Event 3, the high jump, with 02 M 36. The motor (0x6A2C) is the one that "
     "span the hammer in the previous cartridge: wind up, mark the angle with "
     "the button and let go"),
    ("prueba4-1500m.png",
     "Prueba 4, los 1500 metros, con 03 min 31. Reaprovecha entera la lista de "
     "decorados y el marcador de las 110 vallas, y solo cambia el rótulo de la "
     "pizarra",
     "Event 4, the 1500 metres, with 03 min 31. It reuses the 110 hurdles' "
     "scenery list and scoreboard whole, and only the label on the board "
     "changes"),
    ("fuente.png",
     "Los 51 glifos de la fuente, dibujados desde la ROM por "
     "<code>tools/graficos.py</code>. Se ve de un vistazo lo que el listado "
     "afirma: no hay X ni Z, y la Q está al final, fuera del alfabeto. Son "
     "byte a byte los mismos 408 bytes que en el cartucho anterior",
     "The 51 glyphs of the font, drawn straight from the ROM by "
     "<code>tools/graficos.py</code>. You can see at a glance what the listing "
     "claims: there is no X and no Z, and the Q sits at the end, outside the "
     "alphabet. They are byte for byte the same 408 bytes as in the previous "
     "cartridge"),
]


def img64(ruta):
    with open(ruta, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def main(argv):
    if len(argv) < 4:
        print(__doc__)
        return 2
    imgdir, salida, idioma = argv[1:4]
    t = TXT[idioma]

    # El "logotipo" de la cabecera no es un montaje: es el rotulo que el propio
    # cartucho dibuja en su pantalla de titulo, sacado ejecutando su guion.
    ruta_logo = os.path.join(imgdir, "ho2_rotulo_A.png")
    cabecera = (f'<img src="{img64(ruta_logo)}" alt="Hyper Olympic 2">'
                if os.path.exists(ruta_logo) else "<h1>Hyper Olympic 2</h1>")

    nav = "".join(f'<a href="{h}">{x}</a>' for h, x in t["nav"])
    nav += "".join(f'<a href="{h}">{x}</a>' for h, x in t["docnav"])
    nav += (f'<a href="{t["otro"][0]}" style="margin-left:auto;color:var(--oro)">'
            f'{t["otro"][1]}</a>')

    cifras = "".join(f'<div class="cifra"><b>{v}</b><span>{e}</span></div>'
                     for v, e in t["cifras"])
    halls = "".join(f'<div class="hall"><h3>{tit}</h3>{cuerpo}</div>'
                    for tit, cuerpo in HALLAZGOS[idioma])
    imgs = ""
    faltan = []
    for fich, es, en in GALERIA:
        ruta = os.path.join(imgdir, fich)
        if not os.path.exists(ruta):
            faltan.append(fich)
            continue
        pie = es if idioma == "es" else en
        imgs += (f'<figure><img src="{img64(ruta)}" alt="{pie}">'
                 f'<figcaption>{pie}</figcaption></figure>')
    if faltan:
        print("  (faltan %d imagenes: %s)" % (len(faltan), " ".join(faltan)))

    html = f"""<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{t['titulo']}</title>
<style>{ESTILO}</style>
<header class="top">
  {cabecera}
  <p class="claim">{t['claim']}</p>
  <p class="ficha">{' · '.join(t['ficha'])}</p>
</header>
<p class="ficha" style="border:1px solid var(--oro);padding:.8em 1em;margin:1.5em 0">
{t['aviso']}</p>
<nav>{nav}</nav>
<section id="numbers">
  <h2>{t['h_num']}</h2>
  <div class="cifras">{cifras}</div>
</section>
<section id="findings"><h2>{t['h_find']}</h2>{halls}</section>
<section id="screens">
  <h2>{t['h_scr']}</h2>
  <p class="n">{t['nota_scr']}</p>
  <div class="galeria">{imgs}</div>
</section>
<footer><p>{t['pie_leg']}</p></footer>
"""
    with open(salida, "w", encoding="utf-8") as f:
        f.write(html)
    print("  %s: %d KB (%s)" % (salida, len(html) // 1024, idioma))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
