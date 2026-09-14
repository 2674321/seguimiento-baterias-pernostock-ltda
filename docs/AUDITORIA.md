# AUDITORIA.md — Seguimiento de Baterías (PernoStock Ltda.)

Resumen de la auditoría y estabilización del código (2026), efectuada sobre el
software histórico recuperado de PernoStock Ltda.

> Software histórico (proyecto de formación, ene–feb 2024). No representa software
> en uso actual por la empresa.

## Alcance

- ~4.150 líneas de Ruby en ~60 archivos (`*.rb`, `*.rbw`).
- Stack: Ruby 3.2.x · GTK3 · SQLite · YAML · write_xlsx.
- Revisión manual archivo por archivo + verificación funcional en Linux/X11
  (renderizado de todas las ventanas principales con DB demo vacía).

## Defectos críticos encontrados y resueltos

| # | Archivo | Defecto | Resolución |
|---|---|---|---|
| 1 | `history_window_delete_db.rb` | `NameError` por la constante indefinida `Mesaa` al eliminar un registro de historial | Reemplazado por mensaje "Por favor, seleccione una fila para eliminar." |
| 2 | `statistics_window.rb` | Crash al agrupar por MODELO cuando hay filas nulas (`row[0].nil?.downcase`) | `row[0].to_s.downcase` |
| 3 | `statistics_logic.rb` | `NOMBRES_CAMPOS[:FECHA_FACTURA]` apuntaba a una clave inexistente (la real es `FECHA_C`); faltaba `require 'time'` | Clave corregida; `require 'time'` añadido |
| 4 | `show_loading_window.rb` | El `destroy` de la ventana de carga ejecutaba `exit`, cerrando la app a los 5 s antes de mostrar la ventana principal | `destroy` simple, sin `exit` |
| 5 | `backup_exit.rb` | `at_exit { BackupAndExit.backup_exit }` abría un `Gtk.main` en la salida → **segfault** | Eliminado el `at_exit`; el respaldo de cierre se ejecuta desde el handler `destroy` de la ventana principal |

## Depuraciones (mensajería y validaciones)

Redefiniciones múltiples de helpers de UI que producían *method redefined warnings*,
mensajes duplicados y comportamiento impredecible:

- `message_helper.rb` → único punto de definición de `show_message_window`,
  `show_message`, `handle_search_error`, `mostrar_ventana_de_error`.
- Eliminadas redefiniciones en `search_logic.rb`, `battery_window_search_logic.rb`
  (incluida una versión GLib que fallaba), `criteria_menu_validator.rb`,
  `edit_validation.rb`, `edit_window_methods.rb`, `registration_window.rb`.
- `utilities.rb` → depurado a un único `show_message_dialog` (se eliminaron
  `save_results`, `validate_data` y un `show_message` duplicado).
- Eliminado `varyyy` (código muerto).
- `registration_window.rb`: eliminados `datos_a_insertar` duplicados, loops vacíos y
  defs anidadas (`clear_fields`, `update_time_label` movidas a nivel superior).

## Búsqueda y consultas

- `search_logic.rb` reescrito: se eliminaron `obtain_columns` (existía 2 veces),
  `configure_button_signals`, `handle_search_button_click`, `display_search_results`
  y una redefinición de `show_message_window`. El flujo activo (Botón Buscar) quedó
  verificado contra la DB.
- `date_search_window.rb` reescrito:
  - Ordenamiento de columnas corregido (`row[1].to_i` → índice real).
  - `delete_selected_data` definido como método (antes invocaba `Mesaa`).
  - Columnas clicables y ordenables.

## Bucles `Gtk.main` anidados

Llamadas a `Gtk.main` dentro de callbacks congelaban la interfaz. Eliminadas de:

- `calendario.rb`
- `date_search_window.rb`
- `configuracion_cop_seg.rb`

## Copias de seguridad

- `configuracion_cop_seg.rb` reescrito: sin `Gtk.main` en `interfaz`, con validación
  de `configuracion.yaml` (valores fuera de rango → defaults seguros), guarda si falta
  `base_de_datos.db`, sin `logica_configuracion_automatica_salida` vacía, con
  `set_active_index` y `parse_intervalo_tiempo` como métodos.
- `backup_window.rb` / `database_loader.rb`:
  - Progreso de copia actualizado desde thread vía `GLib::Idle` (seguro para GTK).
  - Deprecados `Gtk::Stock::*` reemplazados por etiquetas de texto (también en
    `save_button_principal.rb` y `exportar_base_a_excel.rb`).
  - `exportar_base_a_excel.rb`: guarda real si `datos.xlsx` existe (antes podía
    "confirmar" guardado de un archivo inexistente).
- `backup_exit.rb`: `load_counter_from_file` ahora parsea el timestamp con
  `Time.parse` (con `require 'time'`), permitiendo calcular "último respaldo".
- Inserción en `modulo_registro_de_baterias.rb`: `INSERT OR IGNORE` → `INSERT`
  (la tabla no tiene claves únicas; ahora sí se inserta cada registro).

## Estructura y carga

- `database_operations.rb` reescrito: sin parámetros `db` redundantes; la activación
  de tablas se mantiene al cargar.
- `main.rbw` depurado: eliminados `load 'reemplazo_de_datos.rb'`
  (archivo no existe) y la tabla "indicadores" muerta.
- `constants.rb`: eliminado `INDICATOR_TABLE_NAME`; `create_interface` limpio
  (era una llamada a una función inexistente).
- `interface_setup.rb`: eliminados requires duplicados de `edit_window`,
  `date_search_window` y `search_logic`.
- `history_window.rb` / `history_helper.rb`: clase `VENTANA_DE_HISTORIAL` unificada
  (los dos archivos definían clases con el mismo nombre; una tenía código muerto).
- `history_search.rb`: añadido `require_relative 'message_helper'`.
- `save_button_principal.rb`: añadidos `require 'gtk3'` y `require 'fileutils'`.
- `battery_window_interface.rb`: defs anidadas (`update_time_label`, `on_destroy`)
  movidas a nivel superior.

## Verificación realizada

- `ruby -c` pasa en los ~60 archivos.
- Renderizado real en X11 de: ventana principal, edición, baterías, historial,
  estadísticas (con DB poblada) — sin excepciones.
- Inserción de registro + consulta SQL directa + contadores `Logica` verificados.
- `main.rbw`: secuencia completa de arranque (carga → principal) sin segfault al salir.
- `_scripts/dev/prueba_interfaz.rb` ahora devuelve 0.

## Cambio de control de versiones

- `archivo.yaml` y `configuracion.yaml` (artefactos de runtime regenerados) se dieron
  de baja del tracking (`git rm --cached`) y se añadieron a `.gitignore`, junto con
  `datos.xlsx`.

## Segunda pasada de limpieza (commit `2b220bf`)

- `battery_window_logic.rb`: `data[6].to_i` → `data[6].to_s` (la columna NC se
  mostraba como `0`), eliminado bucle vacío, `ensure db.close`. Se revirtió una
  consolidación de `agregar_a_favoritos`/`invertir_orden`/`eliminar_seleccion_bd`
  (los archivos dedicados `battery_window_add_fav.rb` y `battery_window_delete_db.rb`
  ya se cargan y eran la fuente única).
- `battery_window_delete_interface.rb`: eliminada `restablecer_pagina` duplicada
  (existía también en `battery_window_reset_window.rb`).
- `battery_window_search_logic.rb`: guarda contra `battery_data` nulo.
- `edit_database_methods.rb`: eliminados `collect_changed_fields` duplicado (queda en
  `edit_save_button_methods.rb`) y `required_fields_valid?` duplicado (queda en
  `registration_window_validators.rb`); variables muertas; requires añadidos.
- `edit_window_interface.rb`: eliminado el primer bloque `button_box`/`exit_button`
  duplicado (quedaba pisado por el segundo).
- `edit_window_history_data_insert_module.rb`: la conexión SQLite se abría en el
  momento de cargar el archivo; ahora se abre/cierra por llamada.
- `history_data.rb`: ante excepciones SQLite devuelve `[]` (antes conseguía devolver
  una fila inválida a `update_history_view`).
- `history_window_delete_inter.rb`: eliminado `else` vacío.
- `reemplazo_de_datos.rb`: **bug real** — `db.execute(update_query, *values, id)`
  rompía el arity de `sqlite3` 2.x durante el guardado de edición; ahora
  `db.execute(update_query, values + [id])`. Se añadió `require 'message_helper'`.
- `registration_data_cleaning.rb`: eliminado `redefine_datos_originales` (muerto).
- `save_registration_window.rb`: **eliminado** (huérfano; sus 6 helpers eran código
  muerto y nunca se cargaba).
- `user_manual.rb`: faltaba `require 'gtk3'` (fallaba en carga aislada).
- `validacion_inputs_edit.rb`: eliminada `show_alert_dialog` (muerta).

Verificación adicional de esta semana: `ruby -c` en todos los archivos; renderizado
X11 de principal/edición/baterías/historial/estadísticas/registro/manual; flujo
edición completo (recuperar → reemplazar → historial → contadores → última operación);
`invertir_orden`; sin *method redefined warnings* al cargar `main.rbw` con `-w`.

## Tercera pasada (commit pendiente)

- **Búsqueda por rango de fechas completamente rota** (`search_logic.rb`): `db.execute(query, start_date, end_date)` fallaba por el arity de `sqlite3` 2.x (igual que `reemplazo_de_datos`). Ahora `db.execute(query, [start_date, end_date])` + `ensure db.close` (antes fuga de conexión). Verificado con DB de prueba.
- **`DateSearchValidators`**: `show_error_message` se invocaba desde un class-method donde no existe (`NoMethodError` ante fechas fuera de rango). Los validadores ahora son puros: levantan `ValidationError` y la ventana lo muestra.
- `date_search_window.rb`: eliminado doble `destroy` en su propio handler; eliminado el falso parámetro `date_entry_box` (ya no se pasa).
- `criteria_menu.rb`: eliminada la cadena fantasma `selected_criteria_box`/"Criterios seleccionados:" y `date_entry_box`/`start_date_entry` (box creado y nunca montado); `create_criteria_menu` ya no recibe `main_box` sin uso.
- `menu_date_window.rb`: eliminado parámetro `date_button` sin usar.
- `criteria_menu_validator.rb`: **eliminado** (huérfano, nadie lo requería; `dates_valid?` era idéntico a `dates_selected?`).
- `battery_window_delete_db.rb` / `history_window_delete_db.rb`: eliminados arrays `deleted_battery_data`/`deleted_registro_data` (nunca usados) y branch vacíos; `ensure db.close`; retorno temprano sin selección.
- `battery_window.rb` / `history_window.rb`: quitado `@battery_window_open`/`@history_window_open` seteados en módulo/clase equivocados (el estado real vive en el objeto top-level).
- `history_window_interface.rb`: "Agregar a Favoritos" ahora llama a `agregar_a_favoritos_historial` (el helper propio del historial estaba muerto; usaba el de baterías).
- `statistics_window.rb`: `ensure db.close` en `add_data_from_database`; eliminados `extend StatisticsData` inútil, `each` vacío y handler `destroy` vacío.
- `edit_window_methods.rb` / `edit_save_button_methods.rb`: nueva `retrieve_for_save` (sin diálogos) para el guardado — antes el flujo de "Guardar cambios" re-ejecutaba la búsqueda y mostraba doble diálogo en el camino de error.
- `backup_exit.rb`: el rescate de `backup_database` abría un diálogo GTK durante el cierre (riesgo similar al segfault corregido); ahora `warn` no gráfico.
- `exportar_base_a_excel.rb`: eliminada `db_name` muerta; `ensure db.close`.
- `show_loading_window.rb`: eliminada `message_index` muerta.
- `battery_window_interface.rb`: eliminados handlers vacíos `clicked` y `row-activated`.
- Requires de aislamiento añadidos: `statistics_data.rb`→statistics_logic, `edit_validation.rb`→message_helper/constants, `save_button_principal.rb`→utilities.

Verificación: `ruby -c` en los 60 archivos; `ruby -w` de `main.rbw` sin warnings; render X11 de principal/edición/baterías/historial/estadísticas/registro/manual/fecha; búsqueda por rango real contra DB; `retrieve_for_save` probado para ID válido/inválido/inexistente.

## Cuarta pasada (commit pendiente)

Hallazgos por auditoría empírica (`ruby -w`, grep, arity verificada contra sqlite3 2.9.6):

- **GTK en thread no-principal** (`backup_window.rb`): en el `rescue` del thread worker de la copia manual se mostraba `show_error_dialog` (diálogo GTK + `dialog.run`) → ahora vía `GLib::Idle.add` (seguro para GTK). También se añadió `show_info_dialog` (información) y el éxito de "Base de datos reemplazada" dejó de usar el diálogo de ERROR.
- **`validacion_inputs_edit.rb`**: la lista de columnas de fecha era `%w[RECEPCION FECHA_C FECHA_NC FECHA]` — la columna real es `FECHA_ENVIO`, así que "Fecha Envío" no se validaba en edición. Corregido. Rango de año unificado a `1950..2050` (antes 1800..2050 en edit/search vs 1950..2050 en registro).
- **Redefiniciones reales** (verificadas con `-w`): `update_time_label` (registro + baterías) → la de baterías pasa a `update_battery_time_label`; `invertir_orden` (baterías + historial) → ahora única en `history_window_invert_order.rb`, `battery_window_add_fav.rb` la requiere.
- **`@original_field_values` tipado como Array** (`collect_original_data` lo pisaba con `retrieve_battery_data`) → método y llamada eliminados (código muerto + tipo peligroso).
- **Registro "todos los campos iguales" nunca se disparaba** (`registration_window.rb`): `column_entries.values.uniq.length` comparaba objetos `Gtk::Entry` (siempre N) y `entry.empty?` no existe; ahora compara `.map(&:text)`.
- **Código muerto eliminado**: `edit_window.rb` (`iniciar_ventana_de_edicion`, `@edited_inputs`, `@message_window`), `database_operations.rb` (`insertar_datos` global sin llamadores), `registration_window_validators.rb` (`valid_espacios_en_blanco?`, `validate_length`), `date_search_validators.rb` (`validate_length`), `edit_validation.rb` (`flexible_validator`, `clear_search_fields`), `reemplazo_de_datos.rb` (`total_ediciones`), `interface_setup.rb` (`resultados_guardados`, `column_text`), `process_changed_fields` (llamada a `collect_edited_fields` sin uso).
- **DB name**: `search_logic.rb` y `configuracion_cop_seg.rb` usaban `'base_de_datos.db'` hardcodeado → `NOMBRE_DB`.
- `collect_edited_fields` devuelve `{}` bajo excepción (antes nil → `validate_edited_fields(nil)` crash latente).

Verificación: `ruby -c` en los 60 archivos; `ruby -w` de `main.rbw` **sin ningún warning** (antes había method-redefined); render X11 de todas las ventanas; app real lanzada con el script (Gtk.main corriendo, sin errores); flujo de edición/reemplazo contra DB real.

## Pendiente/mejoras futuras (no bloqueantes)

- Revisar mensajería de `backup_window_logic.rb` (`show_error_dialog`/
  `show_confirmation_dialog`) frente al helper consolidado.
- Portar `menu_date_window.rb`/`criteria_menu.rb` a clases con estado (callbacks
  globales funcionan, pero son frágiles ante redefiniciones).
- Evaluar migrar la interfaz a un DSL tipo `Adwaita` si se busca modernización.