# Hyper Olympic 2 (Konami, MSX1) - desensamblado
#
# El orden de las cosas: trazar el flujo -> generar el listado -> comprobar que
# vuelve a dar la ROM byte a byte -> las comprobaciones que el reensamblado NO
# cubre.
#
# La ROM no se distribuye. Hace falta en la raiz como hyperolympic2.rom, y
# `make comprueba` verifica el sha256.

ROM      = hyperolympic2.rom
SHA      = f254764f4bd1634f50abcdabe5813d133d719197216071772845983ffabad22d
SRC      = src
WORK     = work
ORG      = 0x4000
TITULO   = HYPER OLYMPIC 2 - Konami - MSX1 - cartucho RC-711 de 16 KB en la pagina 1

all: listado verify sanity test

$(ROM):
	@echo "=================================================================="
	@echo " Falta $(ROM), y este repositorio NO lo distribuye."
	@echo ""
	@echo " Es Hyper Olympic 2 (Konami, RC-711) para MSX, 16384 bytes exactos."
	@echo " Ponlo aqui con ese nombre. Para comprobar que es el mismo:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo "=================================================================="
	@false

comprueba: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# El trazado sigue el flujo desde los puntos de entrada. Los que no se pueden
# deducir estaticamente -ganchos de interrupcion, destinos de saltos
# indirectos- estan declarados en el .entries, cada uno con su justificacion.
$(WORK)/hyperolympic2.trace.json: $(ROM) $(SRC)/hyperolympic2.entries $(SRC)/hyperolympic2.nocode
	@mkdir -p $(WORK)
	python3 tools/z80trace.py $(ROM) $(ORG) $(SRC)/hyperolympic2.entries \
	        $(WORK)/hyperolympic2 $(SRC)/hyperolympic2.nocode

trace: $(WORK)/hyperolympic2.trace.json

listado: $(WORK)/hyperolympic2.trace.json $(SRC)/hyperolympic2.notes
	python3 tools/mkasm.py $(ROM) $(ORG) $(WORK)/hyperolympic2.trace.json \
	        $(SRC)/hyperolympic2.notes work/msx.sym $(SRC)/hyperolympic2.asm "$(TITULO)"

# La prueba que decide si el desensamblado es fiable.
verify: $(SRC)/hyperolympic2.asm $(ROM)
	@sh tools/verify_build.sh $(SRC)/hyperolympic2.asm $(ROM) $(ORG)

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. El binario sale identico igual, porque los bytes no cambian; lo unico
# que cambia es lo que decimos de ellos.
sanity: $(WORK)/hyperolympic2.trace.json
	@echo "=================================================================="
	@echo " ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py $(WORK)/hyperolympic2.trace.json $(SRC)/hyperolympic2.nocode
	@python3 tools/check_datos_como_codigo.py $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py $(SRC)/hyperolympic2.entries $(SRC)/hyperolympic2.notes \
	        $(SRC)/hyperolympic2.nocode
	@echo "=================================================================="
	@echo " ni un byte del cartucho sin asignar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " ninguna anotacion puede citar una direccion del cartucho HERMANO"
	@echo "=================================================================="
	@python3 tools/repasa_el_porte.py
	@echo "=================================================================="
	@echo " ni un comentario portado puede describir la instruccion del HERMANO"
	@echo "=================================================================="
	@python3 tools/cifras_portadas.py
	@echo "=================================================================="
	@echo " toda tira de bytes publicada tiene que estar DONDE se dice"
	@echo "=================================================================="
	@python3 tools/comprueba_las_tiras.py

densidad:
	@python3 tools/densidad.py $(SRC)/hyperolympic2.asm

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

# Dibuja los bloques de datos graficos declarados en el .notes, para MIRARLOS.
imagenes: $(ROM)
	@mkdir -p work/gfx
	python3 tools/dibuja.py $(ROM) $(ORG) $(SRC)/hyperolympic2.notes work/gfx

# LA WEB
#
# Bilingue: el ingles en docs/ y el castellano en docs/es/. Las paginas se
# escriben en markdown y se convierten con md2html.py; la portada la monta
# make_web.py, que declara las cifras medidas de ESTE cartucho.
web: $(ROM)
	python3 tools/graficos.py $(ROM) $(ORG) $(SRC)/hyperolympic2.notes docs/imagenes
	python3 tools/md2html.py docs en
	python3 tools/md2html.py docs/es es
	python3 tools/make_web.py docs/imagenes docs/index.html en
	python3 tools/make_web.py docs/imagenes docs/es/index.html es
	python3 tools/check_enlaces.py docs

clean:
	rm -rf $(WORK)/hyperolympic2.trace.json $(WORK)/hyperolympic2.blocks

.PHONY: all comprueba trace listado verify sanity test densidad imagenes web clean
