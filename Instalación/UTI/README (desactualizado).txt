Programa de Seguimiento de Baterías 
Última actualización: 24-01-2024

Descripción del Programa:
--------------------------
Es herramienta diseñada para ofrecer una interfaz gráfica que permita realizar un seguimiento en tiempo real del estado de las baterías.

Este programa facilita operaciones como registro, búsqueda, edición y copias de seguridad, tanto de forma manual como automática.

Lenguaje de Programación:
--------------------------
Version del lenguajes: Ruby 3.2.2.1
Este programa está impulsado por el lenguaje de programación Ruby. Ruby es reconocido por ser amigable, dinámico y orientado a objetos, con una sintaxis elegante que simplifica la escritura de código. Algunas características clave incluyen su enfoque en la orientación a objetos, una sintaxis limpia y elegante, interpretación en tiempo real, tipado dinámico para mayor flexibilidad y una activa comunidad de desarrolladores que proporciona numerosas bibliotecas (gemas) para facilitar el desarrollo.

Instalación:
------------
Para obtener instrucciones detalladas sobre la instalación, consulta el archivo Instrucciones de instalación.txt.

Estructura del Proyecto:
------------------------
Programa_Seguimiento_Baterias/
Estructura del Proyecto:
------------------------
Seguimiento baterias/
|-- Programa_Seguimiento_Baterias (acceso directo a main.rb)
|-- archivos_guardados/

|-- copias_de_seguridad/
    |--copia_de_seguridad_automatica

|-- Instalacion/
    |-- Instrucciones de instalación.txt

|-- desktop.ini


|-- main.rb

|-- interface_setup.rb
 |-- message_helper.rb
 |-- search_logic.rb
 |-- utilities.rb

 |-- backup_exit.rb

 |-- backup_window.rb
   |-- backup_window_logic.rb
 

 |-- battery_window.rb
  |-- battery_window_interface.rb
  |-- battery_window_logic.rb
  |-- battery_window_search_logic.rb
 

 |-- criteria_menu.rb
  |-- menu_date_window.rb
    |-- criteria_menu_logic.rb
    |-- criteria_menu_validator.rb
   

|-- base_de_datos.db
 |-- database_operations.rb
 |-- constants.rb


 |-- edit_window.rb
  |-- edit_window_interface.rb
   |-- validador_edit_inputs.rb
   |-- validacion_inputs_edit.rb
   |-- edit_window_validators.rb
   |-- edit_validation.rb


   |-- edit_window_history_data_insert_module.rb
   |-- edit_window_methods.rb
   |-- edit_database_methods.rb
   |-- edit_save_button_methods.rb
   |-- reemplazo_de_datos.rb


 |-- history_window.rb
  |-- history_window_interface.rb
   |-- history_data.rb
   |-- history_search.rb
   |-- history_helper.rb
 

|-- registration_window.rb
 |-- registration_window_labels_and_placeholders.rb
  |-- registration_window_validators.rb
  |-- save_registration_window.rb
  |-- modulo_registro_de_baterias.rb


 |-- statistics_window.rb
  |-- statistics_data.rb
  |-- statistics_logic.rb
    |-- counter.yaml
    |-- Ultima_copia_de_seguridad_automatica.yaml
    |-- Ultima_operacion.yaml


---------------------
Base de Datos (SQL):
---------------------

- database_operations.rb: Gestión de la base de datos, incluyendo creación, configuración y validación.
- constants.rb: Definición de constantes y variables.
- backup_exit.rb: Realiza una copia de seguridad al salir del programa.

Carpetas:
---------
- archivos_guardados: Contiene los resultados de las búsquedas de la ventana principal.
- copias_de_seguridad: Almacena copias de seguridad manuales y automáticas.
- Instalacion: Instrucciones detalladas sobre la instalación del programa y su entorno.

Gemas Ruby Utilizadas:
-----------------------
Este proyecto hace uso de las siguientes gemas de Ruby:
- gtk3 (Versión 4.2.0): Utilizada para la interfaz gráfica.
- sqlite3 (Versión 1.7.0): Proporciona acceso a la base de datos SQLite.
- fileutils (Versión 1.7.2): Facilita la manipulación de archivos y directorios.
- date (Versión 3.3.4): Permite la manipulación de fechas.

Mejoras y Correcciones Pendientes:
-----------------------------------

Contribuciones:
----------------
¡Las contribuciones son bienvenidas! Si encuentras errores o tienes ideas de mejora, no dudes en enviar un comentario.

---

Nota: Este README es un borrador y esta sin terminar.
Creador: Patricio Varela C.
Contacto: patriciovarelacontreras@gmail.com
