
def eliminar_seleccion_interfaz_historial(tree_view, list_store)
  selection = tree_view.selection
  iter = selection.selected
  if iter
    list_store.remove(iter)
  else
   # puts "No hay ninguna fila seleccionada para eliminar de la interfaz."
  end
end
