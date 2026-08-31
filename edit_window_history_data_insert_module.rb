module GuardarEnTablaDelHistorial
  NOMBRE_DB = 'base_de_datos.db'
  @db = SQLite3::Database.open(NOMBRE_DB)
  def self.guardar_en_tabla_de_registro(id_bateria, campo_modificado, valor_anterior, valor_nuevo, comment)
    fecha_hora = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @db.execute("INSERT INTO tabla_de_registro (fecha_hora, campo_modificado, valor_anterior, valor_nuevo, razon_cambio, ID_bateria) VALUES (?, ?, ?, ?, ?, ?)",
    [fecha_hora, campo_modificado, valor_anterior, valor_nuevo, comment, id_bateria])
    assigned_id = @db.last_insert_row_id
  end
end
