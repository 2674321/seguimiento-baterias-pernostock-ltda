require_relative 'constants'
require_relative 'database_operations'
require 'sqlite3'
class HistoryData
  def self.get_data_from_database
    begin
      db = setup_database
      query = <<-SQL
        SELECT ID, FECHA_HORA, CAMPO_MODIFICADO, VALOR_ANTERIOR, VALOR_NUEVO, RAZON_CAMBIO, ID_BATERIA
        FROM tabla_de_registro;
      SQL
      results = db.execute(query)
      results = format_results(results)
      return results
    rescue SQLite3::Exception => e
   #   puts "ERROR: Ha ocurrido una excepción SQLite3 - #{e.message}"
    rescue StandardError => e
   #   puts "ERROR: Ha ocurrido una excepción - #{e.message}"
    ensure
      db.close if db
    end
  end
  def self.format_results(results)
    results.each do |row|
      case row[2]
      when 'ID'
        row[2] = 'ID de la Bateria'
      when 'MODELO'
        row[2] = 'Modelo'
      when 'SERIE'
        row[2] = 'Serie'
      when 'RECEPCION'
        row[2] = 'Recepción'
      when 'FACTURA'
        row[2] = 'Factura'
      when 'FECHA_C'
        row[2] = 'Fecha Factura'
      when 'NC'
        row[2] = 'Nota de Credito'
      when 'FECHA_NC'
        row[2] = 'Fecha N.C'
      when 'MOTIVO'
        row[2] = 'Motivo de la devolución'
      when 'CLIENTE'
        row[2] = 'Cliente'
      when 'VENDEDOR'
        row[2] = 'Vendedor'
      when 'RECARGA'
        row[2] = 'Recarga'
      when 'FECHA_ENVIO'
        row[2] = 'Fecha Envío'
      when 'DESTINO'
        row[2] = 'Destino'
      when 'COMENTARIOS'
        row[2] = 'Comentarios'
      end
    end
    return results
  end
end
