require 'sqlite3'
require 'gtk3'
require_relative 'database_operations'
require_relative 'message_helper'
require_relative 'edit_validation'
require_relative 'statistics_logic'
require_relative 'constants'
require_relative 'interface_setup'
module SearchLogic
  def handle_search_button(start_date, end_date, selected_column)
    db = obtain_database_connection
   # puts "Búsqueda en el rango de fechas desde '#{start_date}' hasta '#{end_date}'"
    results = {}
    if selected_column == "Todas"
      all_columns = ["RECEPCION", "FECHA_C", "FECHA_NC", "FECHA_ENVIO"]
      all_columns.each do |column|
        query = "SELECT ID, #{column} FROM tabla_de_datos WHERE #{column} BETWEEN ? AND ?"
        begin
          rows = db.execute(query, start_date, end_date)
          if rows.empty?
            # puts "No se encontraron resultados en '#{column}' para el rango de fechas.\n\n"
          else
            results[column] = rows
          end
        rescue SQLite3::Exception => e
          handle_search_error(e)
        end
      end
    else
      query = "SELECT ID, #{selected_column} FROM tabla_de_datos WHERE #{selected_column} BETWEEN ? AND ?"
      begin
        rows = db.execute(query, start_date, end_date)
        if rows.empty?
        #  puts "No se encontraron resultados en '#{selected_column}' para el rango de fechas.\n\n"
        else
          results[selected_column] = rows
        end
      rescue SQLite3::Exception => e
        handle_search_error(e)
      end
    end
    return results
  end
  def construct_result(results, columns)
    formatted_results = []
    results.each do |column_name, rows|
      rows.each do |row|
        formatted_row = []
        column_names = columns.is_a?(Hash) ? columns[column_name] : []
        row.each_with_index do |col_value, i|
          key = i.zero? ? "ID" : column_names[i - 1]
          formatted_row << "#{key}: #{col_value}" if col_value
        end
        formatted_results << formatted_row
      end
    end
    formatted_results
  end
  def obtain_columns
    Constants::TablaDeDatos::COLUMN_NAMES.select do |_key, value|
      ["RECEPCION", "FECHA_C", "FECHA_NC", "FECHA_ENVIO"].include?(value)
    end
  end
  def display_search_results(rows, column_name)
    #puts "\nColumna: #{column_name}"
    #rows.each { |row| puts "Resultado: #{row.first}" }
  end
  def handle_search_error(error)
    #puts "Error en la búsqueda: #{error.message}"
  end
  def obtain_database_connection
    SQLite3::Database.new('base_de_datos.db')
  end
  def obtain_columns
    Constants::TablaDeDatos::COLUMN_NAMES
  end
end
def map_column_name(value)
  case value
  when 'ID'
    'ID de la Bateria'
  when 'MODELO'
    'Modelo'
  when 'SERIE'
    'Serie'
  when 'RECEPCION'
    'Recepción'
  when 'FACTURA'
    'Factura'
  when 'FECHA_C'
    'Fecha Factura'
  when 'NC'
    'Nota de Credito'
  when 'FECHA_NC'
    'Fecha N.C'
  when 'MOTIVO'
    'Motivo de la devolución'
  when 'CLIENTE'
    'Cliente'
  when 'VENDEDOR'
    'Vendedor'
  when 'RECARGA'
    'Recarga'
  when 'FECHA_ENVIO'
    'Fecha Envío'
  when 'DESTINO'
    'Destino'
  when 'COMENTARIOS'
    'Comentarios'
  else
    value
  end
end
def construct_result(rows, columns, column_names)
  return "No se encontraron resultados." if rows.empty?
  separator = "--------------------------------------\n\n"
  result = rows.map do |row|
    row_data = row.each_with_index.map do |col_value, i|
      column_name = column_names[i]
      display_name = map_column_name(column_name)
      "#{display_name}: #{col_value}" if col_value
    end.compact.join("\n")
  end.join("\n#{separator}")
#  puts result
#  puts "-------------"
  result
end
def search_data(valor, label, index, columns, db)
  column_names = Constants::TablaDeDatos::COLUMN_NAMES.values
  index = index.to_i
  column_name = column_names[index]
 # puts "Buscando en la columna: #{column_name}"
  query = "SELECT * FROM tabla_de_datos WHERE LOWER(#{column_name}) LIKE LOWER(?)"
  begin
    rows = db.execute(query, "%#{valor.downcase}%")
    if rows.empty?
      GLib::Idle.add do
        label.markup = "<b>No se encontró '#{valor}' en '#{column_name}'.</b>\n\n"
        false
      end
    else
      result = construct_result(rows, columns, column_names)
      GLib::Idle.add do
        label.markup = "<b>Se encontró '#{valor}' en '#{column_name}'</b>\n\n" + result
        #puts "Resultados de la búsqueda:"
        display_search_results(rows, columns)
        contador_busqueda(column_name, valor)
        false
      end
    end
  rescue SQLite3::Exception => e
    GLib::Idle.add do
      handle_search_error(e)
      false
    end
  end
end
def show_message_window(message)
  if @message_window.nil?
    @message_window = Gtk::MessageDialog.new(
      transient_for: @current_edit_window,
      flags: Gtk::DialogFlags::MODAL,
      type: Gtk::MessageType::INFO,
      buttons: Gtk::ButtonsType::OK,
      message: message
    )
    @message_window.signal_connect("response") { @message_window.close }
    @message_window.show_all
    @message_window.set_position(Gtk::WindowPosition::CENTER)
  else
    @message_window.set_text(message)
  end
end
def contador_busqueda(column_name, valor)
  Logica.incrementar_contador_busquedas
  UltimaOperacion.actualizar_ultima_operacion_realizada("Búsqueda en #{column_name} por '#{valor}'")
end
def display_search_results(rows, columns)
 # puts "Resultados de la búsqueda:"
 # rows.each do |row|
 #   row.each_with_index do |column_value, i|
  #    puts "#{columns[i]}: #{column_value}"
  #  end
  #  puts "-------------"
  #end
end
def handle_search_error(error)
  #puts "Error en la búsqueda: #{error.message}"
  show_message("Error en la búsqueda: #{error.message}")
end
def configure_button_signals(edit_button, search_buttons, backup_button, exit_button, columns, entry_serie, column_combo, result_label)
  edit_button.signal_connect('clicked') { create_edit_window }
  search_buttons[0].signal_connect('clicked') do
    valor = entry_serie.text.strip
    column_text = column_combo.active_text
    index = columns.key(column_text)
    if index.nil? || valor.empty?
      show_message("Por favor, escriba un valor para buscar.")
    else
      begin
        database = setup_database
        search_data(valor, result_label, index.to_s, columns, database)
      rescue StandardError => e
       # puts "Error: #{e.message}"
        show_message("Error en la búsqueda: #{e.message}")
      end
    end
  end
  search_buttons[1].signal_connect('clicked') { save_results(result_label.text) }
  backup_button.signal_connect('clicked') { create_backup_window }
  exit_button.signal_connect('clicked') { Gtk.main_quit }
end
def handle_search_button_click(entry_serie, column_combo, result_label, columns)
  valor = entry_serie.text.strip
  column_text = column_combo.active_text
  index = columns.key(column_text)
  if index.nil? || valor.empty?
    show_message("Por favor, escriba un valor para buscar.")
  else
    begin
      database = setup_database
      search_data(valor, result_label, index.to_s, columns, database)
    rescue StandardError => e
     # puts "Error: #{e.message}"
      show_message("Error en la búsqueda: #{e.message}")
    end
  end
end
