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

## Quinta pasada — gran reforma de mejoras (commit pendiente)

Reforma estructural con verificación integral (`ruby -c`, `ruby -w` sin warnings, render X11 de todas las ventanas, app real lanzada sin errores).

**Bugs de runtime corregidos**
- `Gtk::Window#set_window_position` **no existe** en GTK3 (NoMethodError garantizado) → `set_position` en `show_loading_window.rb` y `calendario.rb`.
- `menu.popup(nil, nil, ...)` deprecado en GTK 3.22 → `menu.popup_at_pointer(event)` en `battery_window_interface.rb`, `history_window_interface.rb` y `date_search_window.rb`.
- Fuga de conexión SQLite en `edit_database_methods.rb` (db.close fuera de ensure; execute fallido dejaba la conexión abierta) → `ensure db.close`.
- Fuga de conexión en el callback de búsqueda de `interface_setup.rb` (una conexión nueva por clic en "Buscar") → `ensure database.close`.
- `statistics_window.rb` usaba `'base_de_datos.db'` hardcodeado → `NOMBRE_DB`.

**Fugas de recursos (timers GLib nunca cancelados)**
- `registration_window.rb` y `statistics_window.rb`: el timeout de 1s seguía despertando indefinidamente tras cerrar la ventana → se guarda el id y se cancela en `signal_connect('destroy')`.
- `show_loading_window.rb`: el timer de 2s del spinner se autocancela al destruir la ventana y se cancela explícitamente al terminar la carga.

**Unificación de lógica duplicada**
- **Diálogos**: 8 helpers equivalentes en 5 archivos (`show_message_dialog`, `show_message_window`, `show_message`, `show_error_dialog`, `show_info_dialog`, `show_confirmation_dialog`, `mostrar_ventana_de_error`, `show_validation_message`) → ahora un único `DialogHelper` (`dialog_helper.rb`) con `show_dialog/show_info/show_error/show_warning/show_confirmation`; los helpers globales quedan como delegados de 1 línea (API pública intacta).
- **Reloj**: 3 versiones de `update_time_label` (registro / baterías con rescue / lambda en estadísticas) → una sola robusta en `utilities.rb`.
- **Validadores**: 12+ reimplementaciones por columna → módulo puro `FieldValidators` (`field_validators.rb`), con constantes centralizadas (`MOTIVO_STATES`, `RECARGA_STATES`, `MIN_YEAR..MAX_YEAR`, `MAX_COMMENT_LENGTH`). `registration_window_validators.rb` y `validacion_inputs_edit.rb` delegan a él; comportamiento por campo preservado al pie de la letra (incl. divergencias por flujo: NC/letras-espacios en edición vs Float/Integer en registro). `require 'date'` explícito (antes dependencia frágil vía statistics_logic).
- **Base de datos**: única `setup_database` global; eliminado `DatabaseOperations.setup_database` duplicado (el módulo ahora usa el global).

**Limpieza (dead code)**
- Eliminadas defs sin llamadores: `backup_database` global (`backup_window.rb`), `BackupAndExit.backup_exit`, `MessageHelper.close_window`, `MAX_LONGITUD_GENERAL`.
- Requires redundantes retirados: `statistics_data` (battery_window_search_logic), `statistics_window` e `interface_setup` (battery_window), `edit_save_button_methods`, `edit_window_methods` y `statistics_logic` (validacion_inputs_edit).
- `@edited_fields` era un ivar persistente en `collect_edited_fields` → variable local.

## Sexta pasada — mejora visual y corrección de ventana de carga (commit pendiente)

Reforma visual y corrección del flujo de arranque, verificada con tests automatizados y capturas de pantalla de las ventanas.

**Ventana de carga: bug crítico corregido**
- **Causa raíz** (`main.rbw`): la ventana de carga se creaba y se destruía ANTES de que `Gtk.main` iniciara el loop, por lo que nunca llegaba a pintarse. Ahora el init corre dentro de `GLib::Idle` tras mostrar la ventana, y la ventana se destruye en el `ensure` de ese callback.
- La ventana de carga ahora es funcional: se muestra durante la inicialización y se destruye automáticamente cuando la interfaz principal está lista.

**Mejora visual: tema claro y limpio (GtkCssProvider global)**
- Nuevo `app_theme.rb` con módulo `AppTheme` que instala un proveedor CSS global vía `Gtk::StyleContext.add_provider_for_screen`. CSS centrado en:
  - Fondo blanco/gris muy claro (`#f7f9fc`), bordes sutiles (`#cfd8e3`).
  - Botones con fondo blanco, bordes redondeados, hover/active states suaves.
  - Entradas con bordes redondeados y focus azul (`#2a7ab0`).
  - Treeviews con header gris y selección azul.
  - Progressbar con accent azul.
  - Tipografías específicas para marcas y subtítulos (`#brand`, `#title`, `#hint`).
- Se instala en `main.rbw` y `show_loading_window.rb` antes de crear cualquier ventana.

**Ventana de carga rediseñada**
- Marca: `Seguimiento de Baterías · PernoStock Ltda.` con estilo `#brand` (azul, bold, grande).
- Subtítulo: `Iniciando la aplicación…` estilo `#hint`.
- Icono de la app (icon_name: `seguimiento-baterias-pernostock`).
- Spinner animado.
- Mensajes rotativos (lista `MESSAGES`) cada 1.5s.
- Barra de progreso animada (`GLib::Timeout` cada 50ms, incremento de 0.01).
- Duración configurable como parámetro `duration`.
- Limpieza de timers con `begin/rescue` para evitar warnings de GLib.

**Ventana principal mejorada**
- Header con `#brand` (nombre de la app) y `#hint` (subtítulo) centrados.
- Iconos en todos los botones de acción: `system-search` (Buscar), `document-save` (Guardar), `document-save` (Copia de Seguridad), `accessories-text-editor` (Edición), `list-add` (Registro Bat.), `application-exit` (Salir).
- Helper `set_button_icon` añadido a `utilities.rb`.

**Base de datos de prueba (local)**
- Script `_scripts/dev/reset_db_prueba.rb`: crea `base_de_datos.db` (gitignored) con 7 filas de ejemplo para testing local.
- Ejecutado: `base_de_datos.db` regenerada con 7 filas (modelo serie cliente vendedor recarga destino etc.).

Verificación: `ruby -c` en todos los archivos; flujo de arranque completo con loading → main (ventana de carga efectivamente se pinta y se destruye al finalizar init); render X11 de las 8 ventanas con tema aplicado; app real lanzada sin errores; capturas de pantalla de loading y ventana principal verificadas; test de timeout de duración de la ventana de carga. 

## Pendiente/mejoras futuras (no bloqueantes)

**Código duplicado restante (bajo riesgo, valor moderado)**
- Acciones de menú contextual gemelas (battery vs history) — `agregar_a_favoritos`, `eliminar_seleccion_interfaz`, `eliminar_seleccion_bd`, `restablecer_pagina` — funciones prácticamente idénticas con distintos nombres. Podrían consolidarse en un módulo `TreeViewActions`, aunque el flag `@linea_divisoria_agregada` comparte estado entre ventanas.
- 4 misiones de nombres-legibles manuales (`NOMBRES_CAMPOS`, `NOMBRES_BATTERY_WINDOW_STAT`, `label_text`/`set_entry_tooltip`, `HistoryData.format_results`, `create_edit_window`): un cambio de nombre de columna requiere actualizar todos. Podrían derivarse de `Constants::TablaDeDatos::COLUMN_NAMES`.

**Recurso: copia temporizada sin transacción**
- `configuracion_cop_seg.rb` usa solo `FileUtils.cp` sin `BEGIN IMMEDIATE` / `ROLLBACK` como hacen las demás copias. Si SQLite escribe simultáneamente, la copia podría ser inconsistente.

**Recurso: hilo de copia temporizada sin `join`**
- `configuracion_cop_seg.rb` ejecuta `Thread.new` para el bucle infinito; `stop_backup_logic` hace `join(1)`, pero el hilo puede estar durmiendo. Se resolvería con `Thread.new { ...; Thread.current.report_on_exception = false }.daemon = true` o bien usando `sleep 1` entre chequeos de `@stop_backup`.

**Requerimientos frágiles**
- `statistics_window.rb` requiere explícitamente `utilities` para `update_time_label` (añadido en la quinta pasada). Si se carga en aislamiento sin `main.rbw`, podrían faltarse otros (`database_operations` / `statistics_logic`); una carga estricta (autoload o bundler) eliminaría esto.

**Oportunidades de modernización**
- Evaluar migración a `Gtk4` / `Adwaita` en el futuro (APIs de diálogos cambian: `Gtk::Dialog` eliminado en GTK4).
- `configuracion_cop_seg.rb` podría emitir evento `GLib::Idle` de progreso en el hilo de copia temporizada (actualmente solo avisa al cerrar).
- `ExportToExcel` usa `Workbook` de `write_xlsx`; alternativa con `odf` o `csv` con manejo básico de errores más robusto.