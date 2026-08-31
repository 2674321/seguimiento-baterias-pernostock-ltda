require 'date'
require 'gtk3'
require_relative 'constants'
require_relative 'database_operations'
def setup_database
  SQLite3::Database.new(NOMBRE_DB)
end
def tabla_de_datos_creada?
  db = setup_database
  begin
    tables = db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name=?;", 'tabla_de_datos')
    tables.any?
  ensure
    db.close
  end
end
def configurar_base_de_datos
  unless tabla_de_datos_creada?
    db = setup_database
    begin
      db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS tabla_de_datos (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        MODELO TEXT NULL,
        SERIE TEXT NULL,
        RECEPCION TEXT NULL,
        FACTURA TEXT NULL,
        FECHA_C TEXT NULL,
        NC INTEGER NULL,
        FECHA_NC TEXT NULL,
        MOTIVO TEXT NULL,
        CLIENTE TEXT NULL,
        VENDEDOR TEXT NULL,
        RECARGA TEXT NULL,
        FECHA_ENVIO TEXT NULL,
        DESTINO TEXT NULL,
        COMENTARIOS TEXT NULL
      );
      SQL
      if db.table_info('tabla_de_datos').empty?
        puts "La tabla 'tabla_de_datos' no se creó correctamente."
      else
        db.execute("CREATE TABLE IF NOT EXISTS #{TABLE_CREATED_FLAG} (created INTEGER);")
        db.execute("INSERT INTO #{TABLE_CREATED_FLAG} (created) VALUES (1);")
      end
    rescue SQLite3::Exception => e
      puts "Error al configurar la base de datos: #{e.message}"
    ensure
      db.close if db
    end
  else
  end
end
def insertar_datos(db, datos)
  begin
    db = setup_database
    datos.each do |fila|
      column_names = Constants::TablaDeDatos::COLUMN_NAMES.keys[1..-1].join(', ')
      placeholders = (['?'] * (Constants::TablaDeDatos::COLUMN_NAMES.size - 1)).join(', ')
      insert_query = "INSERT INTO tabla_de_datos (#{column_names}) VALUES (#{placeholders})"
      db.execute(insert_query, fila[0..-1])
    end
  rescue SQLite3::Exception => e
    puts "Error al insertar datos: #{e.message}"
  ensure
    db.close if db
  end
end
def check_initial_data_inserted(db, data)
  db = setup_database
  data.each do |row|
    query = "SELECT COUNT(*) FROM tabla_de_datos WHERE MODELO = ? AND SERIE = ? AND RECEPCION = ?"
    count = db.execute(query, row[0], row[1], row[2]).flatten[0]
    return true if count > 0
  end
  false
ensure
  db.close if db
end
def configurar_tabla_de_registro
  db = setup_database
  begin
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS tabla_de_registro (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        FECHA_HORA TEXT NULL,
        CAMPO_MODIFICADO TEXT NULL,
        VALOR_ANTERIOR TEXT NULL,
        VALOR_NUEVO TEXT NULL,
        RAZON_CAMBIO TEXT NULL,
        ID_BATERIA INTEGER NULL,
        FOREIGN KEY (ID_BATERIA) REFERENCES tabla_de_datos(ID)
      );
    SQL
  rescue SQLite3::Exception => e
    puts "Error al configurar la tabla de registro: #{e.message}"
  ensure
    db.close if db
  end
end
configurar_base_de_datos
configurar_tabla_de_registro
