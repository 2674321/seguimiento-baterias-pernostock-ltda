require 'date'
require_relative 'constants'
require_relative 'database_operations'
require_relative 'modulo_registro_de_baterias'
require_relative 'registration_window_validators'
require_relative 'registration_window_labels_and_paceholders'
require_relative 'registration_data_cleaning'
require_relative 'statistics_logic'
require_relative 'message_helper'
require_relative 'registration_window_validation_m'
def create_registration_window(parent)
  registration_window = Gtk::Window.new('Ventana de Registro')
  registration_window.set_size_request(800, 600)
  registration_window.set_transient_for(parent)
  registration_box = Gtk::Box.new(:vertical, 10)
  registration_box.margin = 20
  registration_window.add(registration_box)
  header_label = Gtk::Label.new('Formulario de Registro')
  header_label.margin_bottom = 10
  header_label.halign = :start
  header_label.valign = :center
  registration_box.pack_start(header_label, expand: false, fill: true, padding: 5)
  column_entries = {}
  max_inputs = 13
  Constants::TablaDeDatos::COLUMN_NAMES.each_slice(5).with_index do |column_group, index|
    break if index >= 3 || column_entries.length >= max_inputs
    row_box = Gtk::Box.new(:horizontal, 10)
    row_box.halign = :start
    column_group.each do |(key, value)|
      next if key == :ID
      break if column_entries.length >= max_inputs
      column_box = Gtk::Box.new(:vertical, 5)
      label_text = label_text(value)
      required_fields = ["MODELO", "SERIE", "RECEPCION", "CLIENTE", "VENDEDOR"]
      label = Gtk::Label.new(label_text + ":")
      label.margin_bottom = 5
      entry = Gtk::Entry.new
      entry.width_chars = 40
      entry.height_request = 23
      entry.name = key.to_s
      placeholder_text = placeholder_text(value)
      entry.set_placeholder_text(placeholder_text)
      column_box.pack_start(label, expand: false, fill: true, padding: 5)
      column_box.pack_start(entry, expand: true, fill: true, padding: 5)
      row_box.pack_start(column_box, expand: true, fill: true, padding: 5)
      column_entries[key] = entry
    end
    column_entries.each do |key, entry|
      tooltip_text = tooltip_text(key)
      entry.set_tooltip_text(tooltip_text)
    end
    registration_box.pack_start(row_box, expand: true, fill: true, padding: 5)
  end
  comment_box = Gtk::Box.new(:vertical, 5)
  comment_label = Gtk::Label.new('Comentarios:')
  comment_label.margin_bottom = 5
  comment_entry = Gtk::Entry.new
  comment_entry.name = 'comments'
  comment_entry.set_placeholder_text('Ingrese un comentario sobre la batería (Opcional)')
  comment_box.pack_start(comment_label, expand: false, fill: true, padding: 5)
  comment_box.pack_start(comment_entry, expand: true, fill: true, padding: 5)
  registration_box.pack_start(comment_box, expand: false, fill: true, padding: 5)
  button_box = Gtk::Box.new(:horizontal, 0)
  button_box.valign = :center
  button_box.halign = :center
  spacer = Gtk::Box.new(:horizontal, 0)
  spacer.expand = true
  save_button = Gtk::Button.new(label: 'Guardar')
  save_button.set_size_request(50, 40)
  save_button.set_hexpand(true)
  save_button.set_tooltip_text('Este botón te permite ingresar los datos.')
  clear_button = Gtk::Button.new(label: 'Limpiar Campos')
  clear_button.set_size_request(50, 40)
  clear_button.set_tooltip_text('Limpiar todos los campos de entrada')
  clear_button.signal_connect('clicked') do
    clear_fields(column_entries, comment_entry)
  end
  def clear_fields(column_entries, comment_entry)
    column_entries.values.each do |entry|
    entry.text = ''
  end
  comment_entry.text = ''
end
  statistics_button = Gtk::Button.new(label: 'Estadísticas')
  statistics_button.set_size_request(50, 40)
  statistics_button.set_hexpand(true)
  statistics_button.set_tooltip_text('Abrir la ventana de estadísticas de operaciones')
  history_button = Gtk::Button.new(label: 'Historial')
  history_button.set_size_request(50, 40)
  history_button.set_tooltip_text('Abrir la ventana de historial de Cambios')
  ventana_baterias_button = Gtk::Button.new(label: 'Ventana de Baterías')
  ventana_baterias_button.set_size_request(50, 40)
  ventana_baterias_button.set_tooltip_text('Abrir la ventana de baterías')
  button_box.pack_start(ventana_baterias_button, expand: false, fill: false, padding: 5)
  button_box.pack_start(history_button, expand: false, fill: false, padding: 5)
  button_box.pack_start(statistics_button, expand: false, fill: false, padding: 5)
  statistics_button.set_margin_right(50)
  button_box.pack_start(clear_button, expand: false, fill: false, padding: 5)
  button_box.pack_start(save_button, expand: false, fill: false, padding: 5)
  registration_box.pack_start(button_box, expand: true, fill: true, padding: 5)
  required_fields = ["MODELO", "SERIE", "RECEPCION", "CLIENTE", "VENDEDOR"]
  time_label = Gtk::Label.new
  time_label.halign = :end
  time_label.valign = :start
  time_label.margin_right = 10
def update_time_label(label)
  return unless label && !label.destroyed?
  current_time = Time.now
  formatted_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
  label.text = "#{formatted_time}"
end
  update_time_label(time_label)
  GLib::Timeout.add_seconds(1) { update_time_label(time_label); true }
  time_box = Gtk::Box.new(:horizontal, 10)
  time_box.pack_end(time_label, expand: false, fill: false, padding: 5)
  registration_box.pack_end(time_box, expand: false, fill: false, padding: 5)
  save_button.signal_connect('clicked') do
    on_save_button_clicked(column_entries, comment_entry)
  end
  statistics_button.signal_connect('clicked') do
    Interfaz.ventana_de_estadisticas
  end
  history_button.signal_connect('clicked') do |_button|
    create_history_window
  end
  ventana_baterias_button.signal_connect('clicked') do |_button|
    create_battery_window
  end
registration_window.show_all
end
def on_save_button_clicked(column_entries, comment_entry)
  required_fields = ["MODELO", "SERIE", "RECEPCION", "CLIENTE", "VENDEDOR"]
  if column_entries.values.uniq.length == 1 && !column_entries.values.uniq[0].empty?
    show_message("Todos los campos contienen los mismos datos. Por favor, verifica.")
    return
  end
  if required_fields_valid?(column_entries, required_fields)
    if !column_entries[:RECEPCION].text.empty? && !valid_sensible_combined_date?(column_entries[:RECEPCION].text)
      show_validation_message("Por favor, ingresa una fecha de recepción válida y coherente.", "Formato correcto: (AAAA/MM/DD).")
    elsif !column_entries[:FECHA_C].text.empty? && !valid_sensible_combined_date?(column_entries[:FECHA_C].text)
      show_validation_message("Por favor, ingresa una fecha de crédito válida y coherente.", "Formato correcto: (AAAA/MM/DD)).")
    elsif !column_entries[:FECHA_NC].text.empty? && !valid_sensible_combined_date?(column_entries[:FECHA_NC].text)
      show_validation_message("Por favor, ingresa una fecha de nota de crédito válida y coherente.", "Formato correcto: (AAAA/MM/DD).")
    elsif !column_entries[:FECHA_ENVIO].text.empty? && !valid_sensible_combined_date?(column_entries[:FECHA_ENVIO].text)
      show_validation_message("Por favor, ingresa una fecha de envío válida y coherente.", "Formato correcto: (AAAA/MM/DD).")
    else
      if !column_entries[:NC].text.empty? && !validate_nota_de_credito?(column_entries[:NC].text)
        show_message("Por favor, ingresa una nota de crédito válida.")
      elsif !valid_cliente?(column_entries[:CLIENTE].text)
        show_message("Por favor ingresa un nombre válido con 'al menos Nombre y Apellido y/o Nombre de la empresa' (sin caracteres no alfabéticos).")
      elsif !valid_vendedor?(column_entries[:VENDEDOR].text)
        show_message("Por favor ingresa un nombre válido con 'al menos Nombre y Apellido y/o Nombre de la empresa' (sin caracteres no alfabéticos).")
      elsif !valid_recarga?(column_entries[:RECARGA].text, ["cargado", "descargado", "en revision", "defectuoso"])
        show_message("Por favor ingresa un estado de recarga válido (Cargado, Descargado, En Revisión, Defectuoso).")
      elsif !column_entries[:MOTIVO].text.empty? && !valid_motivo?(column_entries[:MOTIVO].text)
        show_message("Por favor, ingresa un motivo de devolución válido (Lista de estados permitidos:\n-Funcional (Devuelta pero sigue Funcional)\n-Cambio de modelo \n-Defectuoso \n-Problema de fábrica \n-Daño en el envío \n-Incompatible).")
      elsif !column_entries[:DESTINO].text.empty? && !valid_destino?(column_entries[:DESTINO].text)
        show_message("Por favor ingresa un destino válido (solo letras, números, comas, guiones y barras inclinadas).")
      elsif !column_entries[:MODELO].text.empty? && !valid_modelo?(column_entries[:MODELO].text)
        show_message("Por favor ingresa un modelo válido (solo letras, números, comas, guiones y barras inclinadas).")
      elsif !column_entries[:SERIE].text.empty? && !valid_serie?(column_entries[:SERIE].text)
        show_message("Por favor ingresa una serie válida (solo letras, números, comas, guiones y barras inclinadas).")
      elsif !column_entries[:FACTURA].text.empty? && !valid_factura?(column_entries[:FACTURA].text)
        show_message("Por favor ingresa una factura  válida (solo letras, números, comas, guiones y barras inclinadas).")
      else
        datos_a_insertar = {}
        column_entries.each { |key, entry| validate_length(entry.text); datos_a_insertar[key] = entry.text }
        validate_length(comment_entry.text)
        datos_a_insertar[:COMENTARIOS] = comment_entry.text
        datos_a_insertar.each do |key, value|
          column_name = Constants::TablaDeDatos::COLUMN_NAMES[key]
         # puts "#{column_name.ljust(20)}: #{value}"
        end
        recolectar_datos_ultima_operacion(column_entries, comment_entry)
        cleaned_data = limpiar_datos(column_entries, comment_entry)
        datos_a_insertar = redefine_datos_originales(column_entries, comment_entry)
        registrar_datos_ventana_registro(cleaned_data)
        column_entries.each_value { |entry| entry.set_text('') }
        comment_entry.set_text('')
        MessageHelper.show_message_window("Datos registrados con éxito.")
      end
    end
  else
    show_message("Por favor completa todos los campos obligatorios.")
  end
end
def registrar_datos_ventana_registro(datos_a_insertar)
  fecha_actual = Time.now.strftime("%Y/%m/%d %H:%M:%S")
  [:RECEPCION, :FECHA_C, :FECHA_NC, :FECHA_ENVIO].each do |campo_fecha|
  end
  datos_a_insertar.each do |key, value|
    column_name = Constants::TablaDeDatos::COLUMN_NAMES[key]
   # puts "#{column_name.ljust(20)}: #{value}"
  end
  DatabaseOperations.insertar_datos(datos_a_insertar)
end
