
def agregar_a_favoritos(tree_view, list_store)
  selection = tree_view.selection
  if iter = selection.selected
    num_columns = list_store.n_columns
    values = []
    num_columns.times do |column|
      values << iter.get_value(column)
    end
    list_store.remove(iter)
    if !@linea_divisoria_agregada
      new_iter_favoritos = list_store.prepend
      list_store.set_value(new_iter_favoritos, 0, "FAVORITOS (SUPERIOR)")
      (1...num_columns).each do |index|
        list_store.set_value(new_iter_favoritos, index, "")
      end
      @linea_divisoria_agregada = true
    end
    new_iter_data = list_store.prepend
    values.each_with_index do |value, index|
      list_store.set_value(new_iter_data, index, value)
    end
    tree_view.selection.select_iter(new_iter_data)
  end
end
def invertir_orden(tree_view, list_store)
  num_items = list_store.iter_n_children(nil)
  items = []
  (0...num_items).each do |index|
    tree_path = Gtk::TreePath.new(index.to_s)

    iter = list_store.get_iter(tree_path)
    if iter
      iter_values = []
      list_store.n_columns.times do |column_index|
        iter_values << list_store.get_value(iter, column_index)
      end
      items << iter_values
    end
  end
  list_store.clear
  items.reverse_each do |iter_values|
    new_iter = list_store.append
    iter_values.each_with_index do |value, index|
      list_store.set_value(new_iter, index, value)
    end
  end
end
