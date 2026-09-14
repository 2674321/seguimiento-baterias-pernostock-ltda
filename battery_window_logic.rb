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
    result_set.map do |data|
      [
        data[0],
        data[1].to_s,
        data[2].to_s,
        data[3].to_s,
        data[4].to_s,
        data[5].to_s,
        data[6].to_s,
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
  rescue SQLite3::Exception => e
    puts "Error al obtener datos de la base de datos: #{e.message}"
    nil
  ensure
    db.close if db
  end
end
def update_battery_view(list_store, battery_data)
  list_store.clear
  return if battery_data.nil?
  battery_data.each do |data|
    iter = list_store.append
    indicies = 0.upto(14)
    indicies.each do |index|
      iter[index] = data[index].to_s
    end
  end
rescue StandardError => e
  puts "Error al actualizar la vista de la batería: #{e.message}"
  puts e.backtrace
end