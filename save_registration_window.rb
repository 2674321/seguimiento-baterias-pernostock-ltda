require_relative 'database_operations'
require 'date'
def save_data_tabla_de_datos(entries)
  db = setup_database
  begin
    db.transaction do
      entries.each do |entry|
        existing_data = db.execute(
          "SELECT ID FROM tabla_de_datos WHERE MODELO = ? AND SERIE = ? AND RECEPCION = ?",
          entry[:MODELO].to_s, entry[:SERIE].to_s, entry[:RECEPCION].to_s
        )
        if existing_data.empty?
          insert_data_tabla_de_datos(db, entry)
        else
          update_data_tabla_de_datos(db, entry, existing_data[0][0])
        end
      end
    end
    show_success_message("Datos guardados")
  rescue SQLite3::Exception => e
    show_error_message("Error al insertar o actualizar datos: #{e.message}")
  ensure
    db.close if db
  end
end
def insert_data_tabla_de_datos(db, entry)
  db.execute(
    "INSERT INTO tabla_de_datos (MODELO, SERIE, RECEPCION, FACTURA, FECHA_C, NC, FECHA_NC, MOTIVO, CLIENTE, VENDEDOR, RECARGA, FECHA_ENVIO, DESTINO) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
    entry[:MODELO].to_s,
    entry[:SERIE].to_s,
    Date.strptime(entry[:RECEPCION], "%Y/%m/%d"),
    entry[:FACTURA].to_s,
    Date.strptime(entry[:FECHA_C], "%Y/%m/%d"),
    entry[:NC].to_s,
    Date.strptime(entry[:FECHA_NC], "%Y/%m/%d"),
    entry[:MOTIVO].to_s,
    entry[:CLIENTE].to_s,
    entry[:VENDEDOR].to_s,
    entry[:RECARGA].to_s,
    Date.strptime(entry[:FECHA_ENVIO], "%Y/%m/%d"),
    entry[:DESTINO].to_s
  )
end
def update_data_tabla_de_datos(db, entry, existing_id)
  db.execute(
    "UPDATE tabla_de_datos SET MODELO = ?, SERIE = ?, RECEPCION = ?, FACTURA = ?, FECHA_C = ?, NC = ?, FECHA_NC = ?, MOTIVO = ?, CLIENTE = ?, VENDEDOR = ?, RECARGA = ?, FECHA_ENVIO = ?, DESTINO = ? WHERE ID = ?",
    entry[:MODELO].to_s,
    entry[:SERIE].to_s,
    Date.strptime(entry[:RECEPCION], "%Y/%m/%d"),
    entry[:FACTURA].to_s,
    Date.strptime(entry[:FECHA_C], "%Y/%m/%d"),
    entry[:NC].to_s,
    Date.strptime(entry[:FECHA_NC], "%Y/%m/%d"),
    entry[:MOTIVO].to_s,
    entry[:CLIENTE].to_s,
    entry[:VENDEDOR].to_s,
    entry[:RECARGA].to_s,
    Date.strptime(entry[:FECHA_ENVIO], "%Y/%m/%d"),
    entry[:DESTINO].to_s,
    existing_id
  )
end
def format_date(date_str)
  Date.strptime(date_str, "%Y/%m/%d").to_s
end
def insert_or_update_data(db, entry)
  existing_data = db.execute(
    "SELECT ID FROM tabla_de_datos WHERE MODELO = ? AND SERIE = ? AND RECEPCION = ?",
    entry['MODELO'], entry['SERIE'], entry['RECEPCION']
  )
  if existing_data.any?
    update_data_tabla_de_datos(db, entry, existing_data[0][0])
  else
    insert_data_tabla_de_datos(db, entry)
  end
end
def save_data_tabla_de_registro(entries)
  begin
    show_success_message("Datos insertados en la tabla de registro correctamente")
  rescue => e
    show_error_message("Error al insertar datos en la tabla de registro: #{e.message}")
  end
end
