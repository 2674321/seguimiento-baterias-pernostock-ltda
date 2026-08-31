#!/usr/bin/env ruby
# frozen_string_literal: true

# Prueba de interfaz DEV para Seguimiento de Baterías.
#
# Renderiza la ventana principal en un entorno gráfico X11 con una base de datos
# VACÍA (demo) recién creada, SIN pasar por la secuencia de arranque original
# (ventana de carga con `exit`, que impide mostrar la ventana principal y provoca
# un segfault en `at_exit` — ver docs/DEV-SETUP.md / Problemas conocidos).
#
# Uso (dentro del proyecto):
#   DISPLAY=:0 mise exec -- bundle exec ruby _scripts/dev/prueba_interfaz.rb
#
# La prueba hace `exit!` al terminar (no ejecuta los hooks at_exit del código).

require_relative "../../interface_setup"

create_interface(Constants::TablaDeDatos::COLUMN_NAMES)

exit!
