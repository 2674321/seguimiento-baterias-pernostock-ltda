#!/bin/bash
# Lanzador de Seguimiento de Baterías — PernoStock Ltda.
# Requiere: mise, bundle (Ruby 3.2.x), GTK3
APP_DIR="/home/a2cl/Documentos/07_Proyectos/15_seguimiento-baterias-pernostock-ltda"
cd "$APP_DIR" || exit 1
export DISPLAY="${DISPLAY:-:0}"
exec mise exec -- bundle exec ruby main.rbw
