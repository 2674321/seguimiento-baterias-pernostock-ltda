require_relative 'constants'
require 'sqlite3'
require_relative 'statistics_logic'
module REEMPLAZO_DE_DATOS
  def self.reemplazar_datos(id, changed_fields)
    begin
      db = SQLite3::Database.new(NOMBRE_DB)
      db.transaction
      set_clause = changed_fields.transform_values { |value| limpiar_valor(value) }.map { |key, value| "#{key} = ?" }.join(', ')
      update_query = "UPDATE tabla_de_datos SET #{set_clause} WHERE id = ?"
      db.execute(update_query, *changed_fields.values, id)
      db.commit
      Logica.incrementar_contador_ediciones
      total_ediciones = Logica.obtener_total_ediciones
      ultima_operacion = "\n\nReemplazo de datos en la BATERIA CON ID: #{id}\nCampos editados: #{changed_fields.map { |key, value| "#{key}: #{value}" }.join(', ')}"
      UltimaOperacion.actualizar_ultima_operacion_realizada(ultima_operacion)
    rescue SQLite3::Exception => e
      show_message_window("Error al reemplazar datos: #{e.message}")
      db.rollback if db
    ensure
      db.close if db
    end
  end
  def self.limpiar_valor(value)
    value.strip!
    value.squeeze!(" ")
    value
  end
end
