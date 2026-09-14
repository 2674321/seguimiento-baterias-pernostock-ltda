require 'sqlite3'
require_relative 'constants'
require_relative 'statistics_logic'
module DatabaseOperations
  def self.setup_database
    SQLite3::Database.new(NOMBRE_DB)
  end
  def self.insertar_datos(datos)
    db = setup_database
    begin
      column_names = datos.keys.join(', ')
      placeholders = (['?'] * datos.size).join(', ')
      insert_query = "INSERT INTO tabla_de_datos (#{column_names}) VALUES (#{placeholders})"
      db.execute(insert_query, datos.values)
      Logica.incrementar_contador_registros if db.changes > 0
    rescue SQLite3::Exception => e
      puts "Error al insertar datos: #{e.message}"
    ensure
      db.close if db
    end
  end
end