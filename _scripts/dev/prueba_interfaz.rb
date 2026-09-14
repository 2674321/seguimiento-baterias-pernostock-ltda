#!/usr/bin/env ruby
# frozen_string_literal: true

# Prueba de interfaz DEV para Seguimiento de Baterías.
#
# Renderiza la ventana principal en un entorno gráfico X11 con una base de datos
# VACÍA (demo) recién creada, SIN pasar por la secuencia de arranque original
# (ventana de carga con `exit`, que impedía mostrar la ventana principal y
# provocaba un segfault en `at_exit`; resuelto al quitar esos hooks).
#
# Uso (dentro del proyecto):
#   DISPLAY=:0 mise exec -- bundle exec ruby _scripts/dev/prueba_interfaz.rb
#
# Devuelve 0 si la ventana principal pudo crearse y mostrarse sin excepciones.

require_relative "../../interface_setup"

create_interface(Constants::TablaDeDatos::COLUMN_NAMES)

puts "GUI OK"

exit 0