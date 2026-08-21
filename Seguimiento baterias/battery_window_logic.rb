require_relative 'battery_window_interface'
require_relative 'constants'
require_relative 'database_operations'
require_relative 'message_helper'
require_relative 'interface_setup'
def obtener_datos_baterias
  db = setup_database
  begin
    query = 'SELECT * FROM tabla_de_datos'
    result_set = db.execute(query)
    db.close
    formatted_data = result_set.map do |data|
      [
        data[0],
        data[1].to_s,
        data[2].to_s,
        data[3].to_s,
        data[4].to_s,
        data[5].to_s,
        data[6].to_i,
        data[7].to_s,
        data[8].to_s,
        data[9].to_s,
        data[10].to_s,
        data[11].to_s,
        data[12].to_s,
        data[13].to_s,
        data[14].to_s
      ]
    end
    formatted_data.first(1).each_with_index do |row, index|
    end
    formatted_data
  rescue SQLite3::Exception => e
    puts "Error al obtener datos de la base de datos: #{e.message}"
    return nil
  end
end
def update_battery_view(list_store, battery_data)
  list_store.clear
  begin
    return if battery_data.nil?
    battery_data.each do |data|
      iter = list_store.append
      iter[0] = data[0].to_s
      iter[1] = data[1].to_s
      iter[2] = data[2].to_s
      iter[3] = data[3].to_s
      iter[4] = data[4].to_s
      iter[5] = data[5].to_s
      iter[6] = data[6].to_s
      iter[7] = data[7].to_s
      iter[8] = data[8].to_s
      iter[9] = data[9].to_s
      iter[10] = data[10].to_s
      iter[11] = data[11].to_s
      iter[12] = data[12].to_s
      iter[13] = data[13].to_s
      iter[14] = data[14].to_s
    end
  rescue StandardError => e
    puts "Error al actualizar la vista de la batería: #{e.message}"
    puts e.backtrace
  end
end
