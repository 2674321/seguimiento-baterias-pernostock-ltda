def limpiar_y_redefinir(comment, edit_grid, id)
  begin
    raise ArgumentError, "El comentario no es una cadena" unless comment.is_a? String
    comment.strip!
    comment.squeeze!(" ")
    return comment, edit_grid, id
  rescue ArgumentError => e
    puts "Error: #{e.message}"
    return comment, edit_grid, id
  end
end
