def eliminar_seleccion_interfaz(tree_view, list_store)
  selection = tree_view.selection
  iter = selection.selected
  if iter
    list_store.remove(iter)
  else
  end
end
