require 'sqlite3'
require 'gtk3'
require_relative 'database_operations'
require_relative 'message_helper'
require_relative 'statistics_logic'
require_relative 'constants'
module SearchLogic
  def handle_search_button(start_date, end_date, selected_column)
    db = obtain_database_connection
    results = {}
    all_columns = ["RECEPCION", "FECHA_C", "FECHA_NC", "FECHA_ENVIO"]
    columns = selected_column == "Todas" ? all_columns : [selected_column]
    columns.each do |column|
      query = "SELECT ID, #{column} FROM tabla_de_datos WHERE #{column} BETWEEN ? AND ?"
      begin
        rows = db.execute(query, [start_date, end_date])
        results[column] = rows unless rows.empty?
      rescue SQLite3::Exception => e
        handle_search_error(e)
      end
    end
    results
  ensure
    db.close if db
  end

  def obtain_database_connection
    SQLite3::Database.new('base_de_datos.db')
  end
end
def map_column_name(value)
  case value
  when 'ID' then 'ID de la Bateria'
  when 'MODELO' then 'Modelo'
  when 'SERIE' then 'Serie'
  when 'RECEPCION' then 'Recepción'
  when 'FACTURA' then 'Factura'
  when 'FECHA_C' then 'Fecha Factura'
  when 'NC' then 'Nota de Credito'
  when 'FECHA_NC' then 'Fecha N.C'
  when 'MOTIVO' then 'Motivo de la devolución'
  when 'CLIENTE' then 'Cliente'
  when 'VENDEDOR' then 'Vendedor'
  when 'RECARGA' then 'Recarga'
  when 'FECHA_ENVIO' then 'Fecha Envío'
  when 'DESTINO' then 'Destino'
  when 'COMENTARIOS' then 'Comentarios'
  else value
  end
end
def construct_result(rows, column_names)
  return "No se encontraron resultados." if rows.empty?
  separator = "--------------------------------------\n\n"
  rows.map do |row|
    row.each_with_index.map do |col_value, i|
      display_name = map_column_name(column_names[i])
      "#{display_name}: #{col_value}" if col_value
    end.compact.join("\n")
  end.join("\n#{separator}")
end
def search_data(valor, label, index, columns, db)
  column_names = Constants::TablaDeDatos::COLUMN_NAMES.values
  index = index.to_i
  column_name = column_names[index]
  query = "SELECT * FROM tabla_de_datos WHERE LOWER(#{column_name}) LIKE LOWER(?)"
  begin
    rows = db.execute(query, "%#{valor.downcase}%")
    if rows.empty?
      GLib::Idle.add do
        label.markup = "<b>No se encontró '#{valor}' en '#{column_name}'.</b>\n\n"
        false
      end
    else
      result = construct_result(rows, column_names)
      GLib::Idle.add do
        label.markup = "<b>Se encontró '#{valor}' en '#{column_name}'</b>\n\n" + result
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
def contador_busqueda(column_name, valor)
  Logica.incrementar_contador_busquedas
  UltimaOperacion.actualizar_ultima_operacion_realizada("Búsqueda en #{column_name} por '#{valor}'")
end