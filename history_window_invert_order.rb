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
