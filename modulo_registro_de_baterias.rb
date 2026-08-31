require 'sqlite3'
require_relative 'constants'
require_relative 'statistics_logic'
require_relative 'database_operations'
module DatabaseOperations
  NOMBRE_DB = 'base_de_datos.db'.freeze
  def self.setup_database
    SQLite3::Database.new(NOMBRE_DB)
  end
  def self.insertar_datos(datos)
    begin
      db = setup_database
      column_names = datos.keys.join(', ')
      placeholders = (['?'] * datos.size).join(', ')
      insert_query = "INSERT OR IGNORE INTO tabla_de_datos (#{column_names}) VALUES (#{placeholders})"
      db.execute(insert_query, datos.values)
      if db.changes > 0
        #puts "Datos insertados exitosamente en la base de datos."
        Logica.incrementar_contador_registros
        total_registros = Logica.obtener_total_registros
       # puts "Total de registros: #{total_registros}"
      else
      #  puts "Los datos ya existen en la base de datos y no se han insertado."
      end
    rescue SQLite3::Exception => e
      puts "Error al insertar datos: #{e.message}"
    ensure
      db.close if db
    end
  end
end
