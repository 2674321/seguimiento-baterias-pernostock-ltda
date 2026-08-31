def restablecer_pagina_historial(list_store, tree_view)
  @linea_divisoria_agregada = false
  list_store.clear
  history_data = HistoryData.get_data_from_database
  update_history_view(list_store, history_data)
end
