def restablecer_pagina(tree_view, list_store)
  list_store.clear
  battery_data = obtener_datos_baterias
  update_battery_view(list_store, battery_data) unless battery_data.nil?
  @linea_divisoria_agregada = false
end
