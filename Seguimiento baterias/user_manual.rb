class ManualWindow
  def initialize(parent)
    @parent = parent
    build_window
  end
  def build_window
    @window = Gtk::Window.new("Manual de uso")
    @window.set_default_size(870, 620)
    @window.set_resizable(false)
    @window.set_position(Gtk::WindowPosition::CENTER)
    title_label = Gtk::Label.new
    title_label.set_markup("<big><b>Manual de Uso del Programa de Seguimiento de Baterías</b></big>")
    title_label.set_halign(Gtk::Align::CENTER)
    subtitle_label = Gtk::Label.new
    subtitle_label.set_markup("<b>Introducción al programa e Instrucciones de uso</b>")
    subtitle_label.set_halign(Gtk::Align::CENTER)
    content_label = Gtk::Label.new
    content_label.set_markup("
    <b>Índices:</b>\n
    <a href='#introduccion'>1. Introducción</a>\n
    <a href='#funcionalidades'>2. Funcionalidades principales</a>\n
    <a href='#uso_programa'>3. Uso del programa</a>\n
    <a href='#rango_fechas'>4. Rango de fechas</a>\n
    <a href='#copia_seguridad'>5. Copia de Seguridad</a>\n
    <a href='#boton_guardar'>6. Botón ¨Guardar¨ (Ventana principal)</a>\n
    <a href='#ventana_edicion'>7. Ventana de Edición</a>\n
    <a href='#registro_baterías'>8. Registro de baterías</a>\n
    <a href='#ventana_baterías'>9. Ventana de baterías</a>\n
    <a href='#historial_cambios'>10. Historial de cambios</a>\n
    <a href='#estadísticas'>11. Estadísticas</a>\n
    <a href='#config_copia_seguridad'>12. Configuracion copia de segurida (menu con icono de herramientas)</a>\n
    <a href='#exportar_base_de_datos'>13. Exportar base de datos a Excel</a>\n
    <a href='#soporte_contacto'>14. Reporte de errores</a>\n\n\n\n\n\n\n\n\n\n\n\n


    <b>1. Introducción:</b>\n
    Este programa te permite realizar un seguimiento del estado de las baterías. Fue creado con el lenguaje de programación Ruby, versión 3.2.2.1, para Pernostock desde el 4 de diciembre de 2023 hasta el 02 de febrero de 2024, en contexto de una practica profesional.\n\n

    <b>2. Funcionalidades principales:</b>\n
    - <b>Búsqueda de baterías:</b> Permite buscar baterías en la base de datos, seleccionando una columna específica para una búsqueda más detallada (utiliza el menú desplegable al lado derecho del texto).\n\n
    - <b>Rango de fechas:</b> Busca baterías dentro de un rango de fechas los resultados de busqueda indican su ID, Fecha y Columna asociada a la fecha.\n\n
    - <b>Manual de usuario:</b> Proporciona un conocimiento básico sobre el uso del programa y una visión general de sus funcionalidades.\n\n
    - <b>Copia de Seguridad:</b> Permite realizar copias de seguridad manualmente mediante un botón, y también cargar copias de seguridad anteriores si es necesario. Las copias de seguridad pueden ser manuales o automáticas, siendo estas últimas realizadas por el programa al cerrarse.\n\n
    - <b>Botón de Guardar (Ventana principal):</b> Permite guardar los resultados de las consultas de búsqueda en formatos como JSON, DOCX, CSV y TXT.\n\n
    - <b>Ventana de edición:</b> Permite modificar los datos de una batería después de buscarla por su ID, siempre que los cambios cumplan con los requisitos y se ingrese una razón.\n\n
    - <b>Registro de baterías:</b> Permite agregar nuevas baterías a la base de datos a través de un formulario, solicitando datos obligatorios y opcionales según la situación.\n\n
    - <b>Ventana de baterías:</b> Muestra todas las baterías actuales en la base de datos con sus respectivos datos. Posee un buscador similar al de la ventana principal.\n\n
    - <b>Historial de cambios:</b> Registra todas las ediciones realizadas a las baterías, y permite hacer consultas y ordenar por fecha y hora.\n\n
    - <b>Estadísticas:</b> Muestra estadísticas sobre el uso del programa, como cantidad de búsquedas, últimas operaciones realizadas, copias de seguridad, etc.\n
    - <b>Configuracion Copias de seguridad:</b> Permite configurar tiempo con el cual se ejecuta cada copia de seguridad temporizada.\n\n\n\n\n\n\n
    <b>3. Uso del programa:</b>\n
    - <b>Sobre el Desplazamiento:</b> El programa permite desplazarse por el programa mediante el uso de las flechas del teclado.

    - <b>Buscadores:</b>\n
    Uso de teclas: Digitando el valor a buscar puede realizar la busqueda presionando el boton ¨Enter¨
    Los buscadores están disponibles en 3 ventanas:\n
    - La Ventana Principal (se despliega al ejecutar el programa)\n
    - La Ventana de Baterías (ubicada en la parte superior derecha del programa, botón: Ventana Baterías)\n
    - y el Historial (Parte superior).\n

    Estos buscadores permiten buscar datos por columnas, lo que hace que la búsqueda sea más precisa y versátil.

    - <b>Ejemplo de Uso en la Ventana Principal:</b>\n
    1. Al lado derecho del texto, encontrarás la opción (Seleccione la columna).\n
    2. Al hacer clic en el botón, se desplegará una serie de columnas (por ejemplo: ID, Comentario, etc.).\n
    3. Selecciona una columna según lo que estés buscando.\n
    4. Luego, al lado derecho del texto, en (Ingrese valor a buscar),Ingresa el valor que deseas buscar. Por ejemplo, si buscas en la columna (Recarga) y el valor a buscar es (Cargado),\n
    5. Una vez presionado el boton (Buscar) mostrará los resultados correspondientes a la búsqueda.\n

    - <b>Rango de Fechas (Menú con Icono de Herramientas):</b>\n
    Esta función te permite buscar ciertas baterías en un rango de fechas (inicio y final) según tu elección.\n
    Una vez realizada la búsqueda, aparecerán los datos principales de las baterías que cumplan con los requisitos, mostrando la ID de la batería, la fecha y la columna donde fue encontrada.\n
    - <b>Ejemplo de Uso:</b>\n
    1. Al hacer clic en el Menú con Icono de Herramientas y seleccionar la opción (Rango de Fecha), se abrirá una ventana.\n
    2. En esta ventana, encontrarás un botón que te permite seleccionar la columna en la que deseas buscar (por defecto, busca en todas las columnas de fecha),\n
    3. En la ventana ingresaras 2 fechas en los campos de entrada, la fecha de inicio y la fecha final.\n
    4. Finalmente presionara el boton buscar, lo cual mostrara los resultados.\n
    4. (Puedes presionar el encabezado (ID bateria) para organizarlos de Mayor a Menor y viceversa)\n

    - <b>Copia de Seguridad (Ventana principal):</b>\n
    <b>Recomendaciones:</b> Intente eliminar periodicamente las copias de seguridad ya que pueden acumularse una gran cantidad dependiendo del uso.\n
    Esta función tiene dos propósitos principales:\n
    Permitir la creación de copias de seguridad y cargar una copia de seguridad de la base de datos.\n
    Esto resulta útil en casos de pérdida de datos, fallos, errores o cortes de electricidad.\n
    La ventana de Copia de Seguridad cuenta con dos botones principales: Crear Copia de Seguridad y Cargar Base de Datos.\n

    - <b>Ejemplo de Uso:</b>\n
    1. <b>Crear Copia de Seguridad:</b>\n
     Simplemente haciendo clic en el botón y luego en el botón de confirmación, se generará manualmente la copia de seguridad.
    2. <b>Cargar Base de Datos:</b>\n
      1. Presionar el botón Cargar Base de Datos.\n
      2. Se abrirá una ventana mostrando la carpeta llamada Copias_de_seguridad,\n
      3. Al hacer clic, se ingresará a la carpeta.\n
      4. Dentro, se mostrarán tres archivos: base_de_datos.db (que contiene los datos predeterminados) y las carpetas copias_de_seguridad_manual y copia_de_seguridad_automatica.\n
      5. Dependiendo de lo que se busque, se ingresará a una carpeta haciendo clic.\n
      6. Una vez dentro de cualquiera de las dos carpetas, se seleccionará un archivo y se hará clic en el botón ¨Abrir¨ para cargar la copia de seguridad.\n
      7. Si no hubo problemas enviara el mensaje ¨Base de datos reemplazada con exito¨

    - <b>Botón Guardar (Ventana principal):</b>\n
    Este botón se encuentra en la ventana principal, ubicada en la parte inferior derecha. El botón está etiquetado como ¨Guardar¨.
    Este boton al cuando crea un archivos en un lugar especifico tambien creara una copia en la carpeta (Archivos Guardados),\n    cada tipo de archivo tiene una carpeta correspondiente\n

    - <b>Ejemplo de Uso:</b>\n
    1. Para guardar los resultados de búsqueda, primero se realizará una búsqueda en el buscador superior izquierdo.\n
    2. Se hará clic en el botón Guardar, lo que abrirá una ventana.\n
    3. En la ventana, primero se asignará un nombre al archivo (Ubicado en la parte superior, junto a; Nombre:).\n
    4. Una vez ingresado el nombre, se podrá elegir el tipo de archivo con el que se desea guardar (CSV, DOCX, TXT o JSON).\n
    5. Después de seleccionar el tipo de archivo (por ejemplo, archivo de texto), se elegirá la ubicación de guardado, que será la ubicación actual.\n
    6. Una vez seleccionada la ubicación, al presionar el botón (Guardar), el archivo se guardará en la ubicación elegida.\n
    7. Además, se creará una copia automáticamente en una carpeta llamada (archivos_guardados), donde se podrán consultar los archivos.\n

    - <b>Ventana de Edición:</b>\n
    - Digitando el valor de ID o el Motivo de la edicion puede realizar la Busqueda/Guardado Respectivamente presionando el boton ¨Enter¨\n\n

    Esta ventana puede ser accedida desde las ventanas: Ventana principal y Ventana de Baterías.\n
    Esta ventana permite editar las baterías actuales. Para ello, necesitarás el ID de la batería.\n

    - <b>Ejemplo de Uso:</b>\n
    1. Ingresa a la ventana de edición haciendo clic en el botón 'Editar' o 'Edición', el cual abrirá la ventana de edición.\n
    2. Una vez dentro, en el primer campo de entrada (llamado 'ID de la batería'), ingresarás el ID de la batería que necesitas buscar (puedes obtenerlo del buscador, ventana de baterías, etc).\n
    3. Ingresarás el ID de la batería y presionarás el botón de búsqueda.\n
    4. Los datos de la batería correspondiente se cargarán en los campos inferiores, los cuales se volverán editables.\n
    5. Una vez realizados los cambios (respetando los requisitos y formatos) y haber escrito el motivo del cambio, presionarás el botón 'Guardar cambios'.\n
    6. Con eso, los datos serán editados y podrás consultarlos en el buscador o ventana de baterías. Además, podrás consultar el cambio específico que hiciste en el Historial.\n

    - <b>Registro de Baterías:</b>\n
    Esta ventana es un formulario de registro que permite registrar las baterias en la base de datos.
    Tiene acceso a las ventanas Baterias, Historial y Estadisticas.\n
    Para poder registrar baterias usted tendra que rellenar los campos con la informacion requerida y cumpliendo con los requisitos.
    Los campos que posee un (*) Son <b>obligatorios</b> (Si no tiene la informacion obligatoria al momento del registro puede insertar: <b>PENDIENTE</b>)
    Los datos siguientes: Motivo de Devolución y Estado de recarga Permite solamente ciertos estados.\n
      - Motivo Devolución: Funcional (Significa que fue devuelto pero sigue funcional), Cambio de modelo, Defectuoso, Problemas de fabrica, Daño en el envio y Incompatible.
      - Estado de Recarga:Cargado, Descargado, En revisión y Defectuoso
    - <b>Ejemplo de Uso:</b>\n
    1. Ingresara los datos de los campos de los cuales poseea informacion.\n
    2. Asegurese de que los datos sean correcto y con el formato correcto.\n   (Si tiene dudas puede pasar por encima en los inputs y mostrara un mensaje con una pequeña descripcion, formato, los estados permitidos, etc.)\n
    2. Una vez ingresados los datos usted presionara el boton (Guardar) el cual registrara las baterias en la base de datos.\n

   - Al presionar el ¨Limpiar campos¨ hara que los datos insertados se borren iniciar nuevamente si asi lo requiere.
   - Cuando la Nota de Credito es dejada vacia, usa el valor predeterminado ¨0¨

    - <b>Ventana de Baterías:</b>\n
      - Uso de teclas:
        - Digitando el valor a buscar puede realizar la busqueda presionando el boton ¨Enter¨
        - Desplazamiento: Puede desplazarse usando las flechas en el teclado atraves de las distintas filas.
        - Busqueda rapida: Puede digitar la ID de la bateria y la llevara a la correspondiente bateria,sin necesidad de presionar nada\n\n
    Esta ventana muestra todas las baterias actuales en la base de datos, con sus respectias columnas.\n
    Posee un buscador con el cual se puede buscar en base a columnas y acceso a las ventanas de Historial, Estadisticas y Edición.\n
    - <b>Uso:</b>\n
    Al hacer click derecho tras haber seleccionado una linea de datos, se presentaran las siguentes opciones;\n

    - Invertir Orden: Invertira el orden de los datos\n
    - Restablecer pagina: Esta opcion recargara los datos de la pantalla. \n
    - Agregar a favoritos: Esta opcion movera los datos seleccionados a la parte superior de la ventana separado de los demas datos \n
    - Eliminar (Interfaz): Esta opcion eliminara temporalmente la bateria de la interfaz (aparecera nuevamente al restablecer la pagina) \n
    - Eliminar (Base de datos): Esta opcion eliminara la bateria seleccionada de la base de datos \n

    Es una ventana de analisis, no necesita intrucciones.
    Para saber como usar las demas ventanas o el buscador puede ir a las siguientes secciones;\n
    1. <a href='#buscadores'>Buscadores</a>\n
    2. <a href='#ventana_edicion'>Ventana de Edición</a>\n
    3. <a href='#historial_cambios'>Historial de cambios</a>\n
    4. <a href='#estadísticas'>Estadísticas</a>\n

    - <b>Historial de Cambios/Ediciones:</b>\n\n
      - Uso de teclas:
        - Digitando el valor a buscar puede realizar la busqueda presionando el boton ¨Enter¨
        - Desplazamiento: Puede desplazarse usando las flechas en el teclado atraves de las distintas filas.
        - Busqueda rapida: Puede digitar la ID de la bateria y la llevara a la correspondiente bateria,sin necesidad de presionar nada\n\n
    Esta ventana muestra todos los cambios hecho mediante la ventana de edicion de baterias, ademas de poseer un buscador.\n
    Mostrara datos como;\n
    - ID Cambio (Un ID especifico para el cambio) \n
    - Fecha y Hora (Fecha y hora en la cual se hizo el cambio)\n
    - Campo modificado (El campo/columna que fue modificada Ej:Fecha de Factura )\n
    - Valores anteriores (Es el valor que tuvo el campo (Ej: Factura))\n
    - Valores nuevos (Son los nuevos datos que reemplazaron a los antiguos)\n
    - Razon cambio (Es un comentario breve de la razon del porque se edito los datos) \n
    - ID Bateria (Es la ID de la bateria)\n

    - <b>Uso:</b>\n
    Al hacer click derecho tras haber seleccionado una linea de datos, se presentaran las siguentes opciones;\n

    - Invertir Orden: Invertira el orden de los datos\n
    - Restablecer pagina: Esta opcion recargara los datos de la pantalla. \n
    - Agregar a favoritos: Esta opcion movera los datos seleccionados a la parte superior de la ventana separado de los demas datos \n
    - Eliminar (Interfaz): Esta opcion eliminara temporalmente la bateria de la interfaz (aparecera nuevamente al restablecer la pagina) \n
    - Eliminar (Base de datos): Esta opcion eliminara la bateria seleccionada de la base de datos \n

    Es una ventana de analisis, no necesita intrucciones.
    Para el uso del buscador puede ir a la sección <a href='#buscadores'>Buscadores</a>\n

    - <b>Estadísticas:</b>\n

    (EP) = Significa que solo será un dato que se recolectará en cada ejecución del programa; es decir, al cerrar el programa se reiniciarán los datos.\n
    Esta ventana muestra una serie de estadísticas relacionadas con el uso del programa que pueden ser de utilidad, tales como:
    - Última Operación Realizada\n
    - Último respaldo automático\n
    - Registros de baterías totales (EP)\n
    - Búsquedas totales (EP)\n
    - Cantidad de copias de seguridad manuales (EP)\n
    - Búsquedas en la ventana de Historial (EP)\n
    - Búsqueda en la ventana de Baterías (EP)\n
    - Búsquedas en el rango de fechas (EP)\n

    - <b>Ejemplo de Uso:</b>\n
    1. Se hará clic en el botón llamado Estadísticas.\n
    2. Una vez presionado, se mostrará la ventana de estadísticas.\n
    3. Para mostrar las estadísticas, tendrás que hacer clic en el botón Actualizar estadísticas.\n\n
    - <b>Configuración Copias de seguridad:</b>\n
    Esta ventana permite configurar la copia de seguridad temporizada que tiene el programa, la cual hace una copia de seguridad cada cierto tiempo que es ejecutado el programa.
    - <b>Uso:</b>\n
    Esta ventana se encuentra en la parte superior derecha de la ventana principal, en el menu con el icono de herramientas.\n
    Usted presionara el menu y seguidamente el boton Configuración Cop Seg.
    Una vez abierta la ventana se le presentara un menu desplegable con 6 opciones de las cuales puede elegir el tiempo a eleccion,\n
    con el cual se ejecuta la copia de seguridad temporizada.\n\n
    - <b>Exportar base de datos a Excel:</b>\n Esta ventana permite convertir los datos actuales de la base de datos en Excel/hoja de cálculo.\n
    - <b>Uso:</b>\n
    1. Presione el menú que se encuentra en la parte superior derecha de la ventana principal (icono de herramientas).\n
    2. Una vez abierto el menú, presione el botón ¨Exportar base de datos a Excel¨.\n
    3. Cuando se encuentre en la ventana, presione el botón con el icono de carpeta.\n
    4. Una vez presionado, se le mostrará una ventana en la cual usted elegirá la base de datos a convertir.\n
      - Para convertir la base de datos actual, usted debería retroceder a la carpeta llamada Seguimiento batería, haciendo click sobre ella en la ruta.\n
      - Para convertir una copia de seguridad, debería dirigirse a una de las 3 que contienen las copias de seguridad, en la ventana actual.\n
    5. Una vez elegido el archivo, presionará el botón ¨Convertir a Excel¨ y luego de la notificación, presionará el botón ¨Guardar archivo Excel¨.\n
    6. Una vez presionado el botón ¨Guardar archivo Excel¨, usted elegirá el lugar donde quiere guardar el archivo y presionará ¨Guardar¨.\n\n
    <b>5. Reporte de errores:</b>\n
    Para reportar problemas, contáctame en <u>patriciovarelacontreras@gmail.com</u>.\n
    Este es mi primer programa de alta complejidad, puede tener varios errores que no pude detectar. Puedes mencionarlos enviando un correo.\n\n
    ¡Gracias por usar mi programa!\n\n
    Creador: Patricio Varela C.\n
    Contacto: patriciovarelacontreras@gmail.com\n
    Última actualización: 02 de febrero de 2024\n")
    scrolled_window = Gtk::ScrolledWindow.new
    scrolled_window.add(content_label)

          content_label.signal_connect("activate-link") do |_, uri|
            case uri
            when '#introduccion'
              scrolled_window.vadjustment.value = 500
            when '#funcionalidades'
              scrolled_window.vadjustment.value = 720
            when '#uso_programa'
              scrolled_window.vadjustment.value = 1450
            when '#rango_fechas'
              scrolled_window.vadjustment.value = 1900
            when '#copia_seguridad'
              scrolled_window.vadjustment.value = 2250
            when '#boton_guardar'
              scrolled_window.vadjustment.value = 2800
            when '#ventana_edicion'
              scrolled_window.vadjustment.value = 3250
            when '#registro_baterías'
              scrolled_window.vadjustment.value = 3700
            when '#ventana_baterías'
              scrolled_window.vadjustment.value = 4100
            when '#historial_cambios'
              scrolled_window.vadjustment.value = 4750
            when '#estadísticas'
              scrolled_window.vadjustment.value = 5500
            when '#soporte_contacto'
              scrolled_window.vadjustment.value = scrolled_window.vadjustment.upper - scrolled_window.vadjustment.page_size
            when '#config_copia_seguridad'
              scrolled_window.vadjustment.value = 5900
            when '#buscadores'
              scrolled_window.vadjustment.value = 1200
            when '#exportar_base_de_datos'
              scrolled_window.vadjustment.value = 6260
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
