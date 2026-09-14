require 'gtk3'
class ManualWindow
  ANCHORS = {
    '#introduccion' => '1. INTRODUCCIÓN',
    '#funcionalidades' => '2. FUNCIONALIDADES PRINCIPALES',
    '#uso_programa' => '3. USO DEL PROGRAMA (VENTANA PRINCIPAL)',
    '#ventana_principal' => '4. TABLA DE BATERÍAS: MENÚ CONTEXTUAL',
    '#buscadores' => '5. BUSCADORES',
    '#rango_fechas' => '6. RANGO DE FECHAS',
    '#ventana_edicion' => '7. VENTANA DE EDICIÓN',
    '#registro_baterias' => '8. REGISTRO DE BATERÍAS',
    '#historial_cambios' => '9. HISTORIAL DE CAMBIOS',
    '#estadisticas' => '10. ESTADÍSTICAS',
    '#calendario' => '11. CALENDARIO',
    '#copia_seguridad' => '12. COPIA DE SEGURIDAD',
    '#config_copia_seguridad' => '13. CONFIGURACIÓN DE COPIAS DE SEGURIDAD',
    '#importar_exportar' => '14. IMPORTAR/EXPORTAR BASE DE DATOS',
    '#atajos' => '15. ATAJOS DE TECLADO',
    '#soporte_contacto' => '16. REPORTE DE ERRORES'
  }.freeze

  def initialize(parent)
    @parent = parent
    build_window
  end

  def build_window
    @window = Gtk::Window.new('Manual de uso')
    @window.set_default_size(920, 680)
    @window.set_position(Gtk::WindowPosition::CENTER)
    title_label = Gtk::Label.new
    title_label.set_markup('<big><b>Manual de Uso del Programa de Seguimiento de Baterías</b></big>')
    title_label.set_halign(Gtk::Align::CENTER)
    subtitle_label = Gtk::Label.new
    subtitle_label.set_markup("<b>Introducción al programa e Instrucciones de uso</b>\nVersión 1.0.1 · PernoStock Ltda.")
    subtitle_label.set_halign(Gtk::Align::CENTER)
    content_label = Gtk::Label.new
    content_label.set_markup(<<~'MANUAL'
      <b>Índice:</b>
      1. <a href='#introduccion'>Introducción</a>
      2. <a href='#funcionalidades'>Funcionalidades principales</a>
      3. <a href='#uso_programa'>Uso del programa (ventana principal)</a>
      4. <a href='#ventana_principal'>Tabla de baterías y menú contextual</a>
      5. <a href='#buscadores'>Buscadores</a>
      6. <a href='#rango_fechas'>Rango de fechas</a>
      7. <a href='#ventana_edicion'>Ventana de edición</a>
      8. <a href='#registro_baterias'>Registro de baterías</a>
      9. <a href='#historial_cambios'>Historial de cambios</a>
      10. <a href='#estadisticas'>Estadísticas</a>
      11. <a href='#calendario'>Calendario</a>
      12. <a href='#copia_seguridad'>Copia de seguridad</a>
      13. <a href='#config_copia_seguridad'>Configuración de copias de seguridad</a>
      14. <a href='#importar_exportar'>Importar/Exportar base de datos</a>
      15. <a href='#atajos'>Atajos de teclado</a>
      16. <a href='#soporte_contacto'>Reporte de errores y contacto</a>

      <b>1. INTRODUCCIÓN</b>

      El programa "Seguimiento de Baterías" permite realizar un seguimiento completo del estado de las baterías: consultarlas, registrarlas, editarlas y generar respaldos, todo desde una única ventana principal.

      Fue desarrollado con el lenguaje de programación Ruby, versión 3.2.2, sobre la biblioteca gráfica GTK3, con base de datos SQLite y exportación a Excel mediante la librería write_xlsx. Se construyó para PernoStock Ltda. entre el 04 de diciembre de 2023 y el 02 de febrero de 2024, en el contexto de una práctica profesional, y fue recuperado y estabilizado en 2026 (esta versión auditada).

      El programa trabaja con una base de datos local (el archivo base_de_datos.db), por lo que todas las consultas, registros, ediciones, historial y estadísticas se conservan entre sesiones. Las copias de seguridad se guardan en carpetas separadas que puedes revisar o restaurar cuando lo necesites.

      <b>2. FUNCIONALIDADES PRINCIPALES</b>

      - <b>Tabla de baterías:</b> Al abrir el programa se muestran todas las baterías de la base de datos en una grilla de 15 columnas, con la posibilidad de elegir qué columnas mostrar, ordenar y desplazarse con el teclado.
      - <b>Búsqueda por columnas:</b> Permite buscar baterías en la base de datos seleccionando una columna específica (o todas las columnas de texto) para una búsqueda más precisa.
      - <b>Menú contextual:</b> Clic derecho sobre una fila de la tabla permite editar, agregar a favoritos, invertir el orden, eliminar (solo de la interfaz o de la base de datos) y volver a mostrar todas las baterías.
      - <b>Rango de fechas:</b> Busca baterías dentro de un rango de fechas; los resultados indican el ID, la fecha y la columna asociada.
      - <b>Registro de baterías:</b> Formulario para agregar nuevas baterías con campos obligatorios y opcionales, validaciones y estados predefinidos.
      - <b>Ventana de edición:</b> Permite modificar los datos de una batería buscándola por su ID, siempre respetando los requisitos y registrando la razón del cambio.
      - <b>Historial de cambios:</b> Registra todas las ediciones realizadas, con su fecha y hora, valores anteriores y nuevos, la razón y el ID de la batería. Incluye buscador y menú contextual.
      - <b>Estadísticas:</b> Muestra estadísticas de uso del programa (búsquedas, ediciones, respaldos, última operación, etc.) y un resumen de modelos por cantidad.
      - <b>Calendario:</b> Acceso rápido a un calendario para consultar fechas.
      - <b>Copia de seguridad:</b> Copias manuales (botón "Realizar copia ahora" o botón "Copia de Seguridad"), automáticas al cerrar el programa y temporizadas con intervalo configurable.
      - <b>Guardar resultados:</b> Permite guardar los resultados de una búsqueda en formatos JSON, DOCX, CSV y TXT, con una copia automática en la carpeta "Archivos Guardados".
      - <b>Importar/Exportar base de datos:</b> Importa datos desde CSV o desde otra base de datos .db y exporta la base de datos actual a Excel.
      - <b>Manual y Acerca de:</b> Esta ayuda, disponible desde el menú superior derecho (icono de herramientas).

      <b>3. USO DEL PROGRAMA (VENTANA PRINCIPAL)</b>

      La ventana principal se divide en las siguientes zonas:

      - <b>Encabezado:</b> Título y subtítulo del programa, y en la parte superior derecha el menú con icono de herramientas (engranaje), que da acceso a Manual, Acerca de, Rango de Fecha, Calendario, Importar/Exportar, Configuración de copias de seguridad y "Realizar copia ahora".
      - <b>Barra de búsqueda:</b> Un campo de texto, un selector de columna, el botón de columnas (ícono de tabla, para elegir qué columnas se muestran en los resultados) y el botón "Buscar".
      - <b>Fila de botones principales:</b> Salir, Copia de Seguridad, Edición, Registro Bat., Historial, Estadísticas, Buscar y Guardar.
      - <b>Tabla de resultados:</b> La grilla con las baterías (15 columnas), con sus títulos en los encabezados.
      - <b>Pie de la ventana:</b> Una barra de estado que informa cuántas baterías se están mostrando y la hora actual en vivo.

      <b>Desplazamiento:</b> Puedes desplazarte por todas las filas y columnas con las flechas del teclado y con el desplazamiento del mouse, igual que en cualquier tabla.

      <b>Columna a mostrar:</b> El botón con ícono de tabla (a la derecha del buscador) abre una lista con las 15 columnas. Marca o desmarca las casillas para mostrar u ocultar columnas en los resultados; la opción superior permite seleccionar todas o ninguna, y la opción "Solo ID" deja únicamente la primera columna visible.

      <b>4. TABLA DE BATERÍAS: MENÚ CONTEXTUAL</b>

      Al abrir el programa, la ventana principal muestra la lista completa de baterías registradas en la base de datos (no es necesario buscar primero). La tabla posee 15 columnas:

      ID · MODELO · SERIE · RECEPCION · FACTURA · FECHA_C · NC · FECHA_NC · MOTIVO · CLIENTE · VENDEDOR · RECARGA · FECHA_ENVIO · DESTINO · COMENTARIOS

      Tras seleccionar una fila, al hacer clic derecho se presentan las siguientes opciones:

      - <b>Editar:</b> Abre la ventana de edición con el ID de la batería seleccionada ya cargado.
      - <b>Agregar a Favoritos:</b> Mueve la fila seleccionada a la parte superior de la tabla, separada del resto por un divisor "FAVORITOS (SUPERIOR)". Útil para marcar baterías de atención prioritaria.
      - <b>Invertir Orden:</b> Invierte el orden de los datos (descendente/ascendente).
      - <b>Eliminar (Interfaz):</b> Elimina temporalmente la batería de la pantalla actual. Vuelve a aparecer al usar "Ver todas las baterías".
      - <b>Eliminar (Base de datos):</b> Elimina definitivamente la batería de la base de datos. El programa pide confirmación antes de borrar.
      - <b>Ver todas las baterías:</b> Recarga la tabla con todas las baterías de la base de datos (útil después de una búsqueda o de una eliminación de interfaz).

      <b>5. BUSCADORES</b>

      Los buscadores están disponibles en 2 ventanas: en la Ventana Principal (se despliega al ejecutar el programa, sobre la tabla completa de baterías) y en el Historial. Ambos permiten buscar por columnas, lo que hace la búsqueda más precisa y versátil. Para ejecutar una búsqueda presiona el botón "Buscar" o la tecla Enter.

      - <b>Ejemplo de uso en la ventana principal:</b>
      1. Al lado derecho del campo de texto, encuentra el selector "(Seleccione la columna)".
      2. Al hacer clic, se desplegará la lista de columnas (por ejemplo: ID, MODELO, CLIENTE, etc.).
      3. Selecciona la columna según lo que estés buscando. Si eliges "Todas", el programa busca en las columnas de texto a la vez.
      4. En "Ingrese valor a buscar", escribe el valor que deseas. Por ejemplo, si seleccionas la columna RECARGA y escribes "Cargado".
      5. Presiona el botón "Buscar": se mostrarán los resultados correspondientes en la tabla.
      6. Para volver a ver todo, usa el menú contextual → "Ver todas las baterías" o realiza una nueva búsqueda.

      La búsqueda no distingue entre mayúsculas y minúsculas y acepta coincidencias parciales, por lo que un fragmento del valor también entrega resultados.

      <b>6. RANGO DE FECHAS</b>

      Esta función permite buscar ciertas baterías dentro de un rango de fechas (inicio y final) según tu elección. Una vez realizada la búsqueda, aparecen los datos principales de las baterías que cumplen los requisitos: ID de la batería, columna donde fue encontrada y la fecha.

      - <b>Ejemplo de uso:</b>
      1. Haz clic en el menú con icono de herramientas (engranaje) y selecciona la opción "Rango de Fecha".
      2. En la ventana, usa el botón/selector para elegir la columna de fecha en la que deseas buscar: Todas, RECEPCION, FECHA_C, FECHA_NC o FECHA_ENVIO (por defecto, busca en todas).
      3. Ingresa 2 fechas: la fecha de inicio y la fecha final.
      4. Finalmente presiona el botón buscar: se mostrarán los resultados.
      5. Puedes presionar el encabezado "ID Bateria" para organizarlos de mayor a menor y viceversa.

      <b>7. VENTANA DE EDICIÓN</b>

      Esta ventana permite modificar las baterías actuales. Para ello necesitarás el ID de la batería (disponible en la primera columna de la tabla de la ventana principal).

      Se puede acceder de dos formas: presionando el botón "Edición" de la ventana principal, o a través del menú contextual de la tabla → "Editar" (que carga el ID automáticamente).

      - <b>Ejemplo de uso:</b>
      1. Ingresa a la ventana de edición (botón "Edición" o menú contextual → "Editar").
      2. En el campo "ID de la batería", escribe el ID que necesitas buscar.
      3. Presiona el botón de búsqueda (o la tecla Enter): los datos de la batería se cargarán en los campos inferiores, que se vuelven editables.
      4. Realiza los cambios respetando los requisitos y formatos indicados (puedes pasar el mouse sobre los campos para ver la descripción de cada uno).
      5. Escribe el motivo del cambio en el campo correspondiente (es obligatorio).
      6. Presiona "Guardar cambios": los datos quedan actualizados y el cambio queda registrado en el Historial.

      Nota: el campo MOTIVO acepta únicamente estos estados: Funcional, Cambio de modelo, Defectuoso, Problemas de fábrica, Daño en el envío e Incompatible. En el campo de recarga los estados permitidos son: Cargado, Descargado, En revisión y Defectuoso.

      <b>8. REGISTRO DE BATERÍAS</b>

      Esta ventana es un formulario de registro que permite ingresar nuevas baterías a la base de datos. Tiene acceso a las ventanas Historial y Estadísticas. Para registrar una batería debes completar los campos con la información requerida y cumpliendo los requisitos.

      - Los campos marcados con un asterisco (*) son <b>obligatorios</b>. Si no cuentas con la información obligatoria al momento del registro, puedes insertar el texto <b>PENDIENTE</b>.
      - Los campos "Motivo de Devolución" y "Estado de recarga" permiten solamente ciertos estados:
        - Motivo Devolución: Funcional, Cambio de modelo, Defectuoso, Problemas de fábrica, Daño en el envío e Incompatible.
        - Estado de Recarga: Cargado, Descargado, En revisión y Defectuoso.
      - Si tienes dudas sobre el formato de un campo, pasa el mouse por encima de cada entrada: se mostrará un mensaje con una pequeña descripción, el formato esperado y los estados permitidos.

      - <b>Ejemplo de uso:</b>
      1. Ingresa los datos de los campos de los cuales posees información.
      2. Asegúrate de que los datos sean correctos y con el formato correcto.
      3. Presiona el botón "Guardar": la batería quedará registrada y aparecerá en la ventana principal al ver todas las baterías.
      4. Si te equivocas, el botón "Limpiar campos" borra lo ingresado para comenzar de nuevo.
      5. Cuando la Nota de Crédito (NC) se deja vacía, se usa el valor predeterminado 0.

      <b>9. HISTORIAL DE CAMBIOS</b>

      Esta ventana muestra todos los cambios realizados mediante la ventana de edición de baterías. Muestra los siguientes datos:
      - ID Cambio (identificador único del cambio)
      - Fecha y Hora (cuándo se hizo el cambio)
      - Campo modificado (la columna que fue modificada, por ejemplo FECHA_C)
      - Valores anteriores (el valor que tenía el campo)
      - Valores nuevos (los nuevos datos que reemplazaron a los antiguos)
      - Razón cambio (comentario breve del porqué se editaron los datos)
      - ID Bateria (el ID de la batería afectada)

      <b>Uso:</b> posee un buscador igual al de la ventana principal (busca por columna, presionando Enter). Además, al hacer clic derecho sobre una línea se presentan las opciones:

      - <b>Invertir Orden:</b> Invierte el orden de los datos.
      - <b>Restablecer página:</b> Recarga los datos de la pantalla (útil después de eliminar de la interfaz).
      - <b>Agregar a Favoritos:</b> Mueve la línea seleccionada a la parte superior, separada por el divisor "FAVORITOS (SUPERIOR)".
      - <b>Eliminar (Interfaz):</b> Elimina temporalmente la línea de la pantalla actual (vuelve al restablecer la página).
      - <b>Eliminar (Base de datos):</b> Elimina definitivamente el registro del historial (pide confirmación).

      <b>Búsqueda rápida:</b> puedes digitar el ID de la batería y te llevará directamente a la batería correspondiente, sin necesidad de presionar nada.

      <b>10. ESTADÍSTICAS</b>

      (EP) significa que el dato se recolecta en cada ejecución del programa; es decir, al cerrar el programa se reinician los valores de recuento.

      La ventana de estadísticas muestra información sobre el uso del programa a través de 8 columnas:
      1. Últ. Operación Realizada
      2. Ult. Respaldo Automático
      3. Reg. Totales (cantidad de baterías en la base de datos)
      4. Búsq. totales (EP)
      5. Edic. totales (EP)
      6. Cant. Cop. Seguridad (EP, copias manuales)
      7. Búsq. Vent. Historial (EP)
      8. Op. Rang. de Fechas (EP)

      Además muestra una segunda tabla con el resumen de baterías agrupadas por MODELO y su CanT. Modelo.

      - <b>Ejemplo de uso:</b>
      1. Haz clic en el botón "Estadísticas" de la ventana principal.
      2. Se mostrará la ventana de estadísticas.
      3. Para mostrar/actualizar los valores, haz clic en el botón "Actualizar Estadísticas".

      <b>11. CALENDARIO</b>

      Desde el menú con icono de herramientas (engranaje) → "Calendario" se abre un calendario para consultar fechas de forma visual. Sirve como apoyo para anotar o verificar fechas relacionadas con recepciones, facturas, notas de crédito y envíos.

      <b>12. COPIA DE SEGURIDAD</b>

      La copia de seguridad protege la base de datos ante pérdida de datos, fallos, errores o cortes de electricidad. El programa contempla tres tipos de copias:

      - <b>Manual:</b> Puedes crearla con el botón "Realizar copia ahora" del menú de herramientas, o abriendo la ventana de copias con el botón "Copia de Seguridad" de la ventana principal y presionando "Crear Copia de Seguridad".
      - <b>Automática:</b> El programa realiza una copia automáticamente cada vez que se cierra de forma normal.
      - <b>Temporizada:</b> Una copia automática en intervalos configurables (ver Configuración de copias de seguridad).

      <b>Cargar una copia de seguridad:</b>
      1. Presiona el botón "Copia de Seguridad" en la ventana principal.
      2. Presiona el botón "Cargar Base de Datos".
      3. Se abrirá una ventana mostrando la carpeta "Copias_de_seguridad".
      4. Dentro se muestran la base de datos predeterminada y las carpetas "copia_de_seguridad_automatica" y "copias_de_seguridad_manual".
      5. Ingresa a la carpeta correspondiente a lo que buscas.
      6. Selecciona el archivo y presiona "Abrir" para cargar la copia de seguridad.
      7. Si no hubo problemas, el programa mostrará "Base de datos reemplazada con éxito".

      <b>Recomendación:</b> elimina periódicamente las copias de seguridad antiguas, ya que pueden acumularse en gran cantidad según el uso.

      <b>13. CONFIGURACIÓN DE COPIAS DE SEGURIDAD</b>

      Esta ventana permite configurar la copia de seguridad temporizada, que hace una copia cada cierto intervalo mientras el programa está abierto.

      - <b>Uso:</b>
      1. Abre el menú de la parte superior derecha de la ventana principal (icono de herramientas).
      2. Presiona el botón "Configuración de Copia Seg.".
      3. En la ventana se muestra un menú desplegable con 6 opciones de intervalo de tiempo.
      4. Elige el intervalo que prefieras: a partir de ese momento el programa ejecutará la copia temporizada con esa frecuencia.
      5. Se muestra la fecha/hora de la última copia automática realizada.

      <b>14. IMPORTAR/EXPORTAR BASE DE DATOS</b>

      Esta ventana permite importar datos (CSV u otra base de datos .db) a la base de datos actual y convertir/exportar los datos a Excel (hoja de cálculo).

      <b>Exportar a Excel:</b>
      1. Abre el menú de la parte superior derecha (icono de herramientas) → "Importar/Exportar base de datos".
      2. Presiona el botón con el ícono de carpeta para elegir la base de datos a convertir.
        - Para convertir la base de datos actual, retrocede hasta la carpeta del proyecto "Seguimiento de baterías".
        - Para convertir una copia de seguridad, dirígete a la carpeta correspondiente de Copias_de_seguridad.
      3. Elige el archivo y presiona "Convertir a Excel".
      4. Tras la notificación, presiona "Guardar archivo Excel", elige la ubicación y presiona "Guardar".

      <b>Importar datos (CSV o .db):</b>
      1. En la misma ventana, elige el tipo de archivo a importar (CSV o base de datos .db).
      2. Selecciona el archivo con el botón de carpeta o arrástralo y suéltalo directamente sobre la ventana (drag &amp; drop).
      3. Presiona el botón "Importar a la base de datos": los registros se insertarán en la base de datos actual.

      <b>15. ATAJOS DE TECLADO</b>

      - <b>Buscar:</b> en los buscadores de la ventana principal y del historial, presiona Enter después de escribir el valor.
      - <b>Edición:</b> en la ventana de edición, Enter en el campo de ID realiza la búsqueda; Enter en el campo de motivo guarda los cambios.
      - <b>Desplazamiento:</b> flechas del teclado para moverse por las filas y columnas de las tablas.
      - <b>Búsqueda rápida de ID (historial):</b> digitando el ID de la batería te lleva directamente a su registro sin presionar Enter.

      <b>16. REPORTE DE ERRORES</b>

      Para reportar problemas o sugerencias, contacta a patriciovarelacontreras@gmail.com. Este es un proyecto de práctica profesional; si encuentras un error que no fue detectado, puedes mencionarlo enviando un correo con una descripción del problema y, si es posible, los pasos para reproducirlo.

      ¡Gracias por usar mi programa!

      Creador: Patricio Varela C. (CA2OPX)
      Contacto: patriciovarelacontreras@gmail.com
      Licencia: MIT · Repositorio: https://github.com/2674321/seguimiento-baterias-pernostock-ltda
      Última actualización del programa: 02 de febrero de 2024 (recuperado y auditado en 2026)
    MANUAL
    )
    scrolled_window = Gtk::ScrolledWindow.new
    scrolled_window.add(content_label)

    content_label.signal_connect('activate-link') do |_, uri|
      needle = ANCHORS[uri]
      if needle
        text = content_label.text
        offset = text.rindex(needle)
        if offset
          rect = content_label.layout.index_to_pos(offset)
          adjustment = scrolled_window.vadjustment
          target = rect.y / 1024
          target = 0 if target.negative?
          max = adjustment.upper - adjustment.page_size
          adjustment.value = [target, max].min
        end
        true
      else
        false
      end
    end
    content_label.set_line_wrap(true)
    content_label.set_justify(Gtk::Justification::LEFT)
    content_label.set_margin_top(20)
    content_label.set_margin_bottom(20)
    content_label.set_margin_left(20)
    content_label.set_margin_right(20)
    box = Gtk::Box.new(:vertical, 5)
    box.margin = 20
    box.pack_start(title_label, expand: false, fill: true, padding: 10)
    box.pack_start(subtitle_label, expand: false, fill: true, padding: 5)
    box.pack_start(scrolled_window, expand: true, fill: true, padding: 5)
    @window.add(box)
    @window.signal_connect('destroy') { @window.destroy }
  end
  def show
    @window.show_all
  end
end