
def eliminar_seleccion_interfaz_historial(tree_view, list_store)
  selection = tree_view.selection
  iter = selection.selected
  list_store.remove(iter) if iter
end
