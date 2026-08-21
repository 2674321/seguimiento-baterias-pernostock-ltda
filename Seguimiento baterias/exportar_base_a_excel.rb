require 'gtk3'
require 'write_xlsx'
require 'fileutils'
require 'sqlite3'
require_relative 'message_helper'
require_relative 'constants'
require_relative 'database_operations'
module ExportToExcel
  def self.export_to_excel(data)
    workbook = WriteXLSX.new('datos.xlsx')
    worksheet = workbook.add_worksheet
    data.each_with_index do |row_data, row_index|
      row_data.each_with_index do |cell_data, col_index|
        worksheet.write(row_index, col_index, cell_data)
      end
    end
    workbook.close
  end
  def self.obtain_data_base_data(file_path)
    begin
      db = SQLite3::Database.new file_path
      db_name = "base_de_datos"
      table_name = "tabla_de_datos"
      query = "SELECT * FROM #{table_name};"
      results = db.execute(query)
      db.close
      return results
    rescue SQLite3::Exception => e
      puts "Error al obtener datos de la base de datos: #{e}"
      return nil
    end
  end
  class ExportToExcelWindow
    def self.create_export_to_excel_window
      window = Gtk::Window.new
      window.title = "Exportar a Excel"
      window.set_default_size(500, 300)
      window.set_border_width(20)
      vbox = Gtk::Box.new(:vertical, 10)
      window.add(vbox)
      label_title = Gtk::Label.new("Exportar base de datos a Excel")
      label_title.set_halign(Gtk::Align::CENTER)
      vbox.pack_start(label_title, :expand => true, :fill => true, :padding => 0)
      file_chooser_label = Gtk::Label.new("Seleccionar archivo de base de datos:")
      file_chooser_label.set_halign(Gtk::Align::CENTER)
      vbox.pack_start(file_chooser_label, :expand => true, :fill => true, :padding => 0)
      file_chooser_button = Gtk::FileChooserButton.new("Seleccionar archivo", Gtk::FileChooserAction::OPEN)
      file_chooser_button.set_current_folder("#{Dir.pwd}/Copias_de_seguridad")
      file_filter = Gtk::FileFilter.new
      file_filter.name = "Archivos de base de datos (*.db)"
      file_filter.add_pattern("*.db")
      file_chooser_button.add_filter(file_filter)
      vbox.pack_start(file_chooser_button, :expand => true, :fill => true, :padding => 0)
      button_box = Gtk::Box.new(:horizontal, 10)
      vbox.pack_start(button_box, :expand => true, :fill => true, :padding => 0)
      export_button = Gtk::Button.new(:label => "Convertir a Excel")
      export_button.set_size_request(150, 30)
      export_button.set_halign(Gtk::Align::CENTER)
      export_button.set_valign(Gtk::Align::CENTER)
      button_box.pack_start(export_button, :expand => true, :fill => true, :padding => 0)
      save_button = Gtk::Button.new(:label => "Guardar archivo Excel")
      save_button.set_size_request(150, 30)
      save_button.set_halign(Gtk::Align::CENTER)
      save_button.set_valign(Gtk::Align::CENTER)
      button_box.pack_start(save_button, :expand => true, :fill => true, :padding => 0)
      close_button = Gtk::Button.new(:label => "Cerrar")
      close_button.set_size_request(150, 30)
      close_button.set_halign(Gtk::Align::CENTER)
      close_button.set_valign(Gtk::Align::CENTER)
      button_box.pack_start(close_button, :expand => true, :fill => true, :padding => 0)
      save_button.signal_connect("clicked") {
        if file_chooser_button.filename.nil? || file_chooser_button.filename.empty?
          MessageHelper.show_message_window("Primero seleccione un archivo.")
        else
          dialog = Gtk::FileChooserDialog.new(
            :title => "Guardar archivo Excel",
            :parent => nil,
            :action => Gtk::FileChooserAction::SAVE,
            :buttons => [[Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL],
                         [Gtk::Stock::SAVE, Gtk::ResponseType::ACCEPT]]
          )
          dialog.current_name = "Datos_convertidos_Base_de_datos.xlsx"
          if dialog.run == Gtk::ResponseType::ACCEPT
            save_path = dialog.filename
            dialog.destroy

            if save_path
              FileUtils.mv('datos.xlsx', save_path) if File.exist?('datos.xlsx')
              MessageHelper.show_message_window("Archivo Excel guardado exitosamente en #{save_path}.")
              FileUtils.mkdir_p("#{Dir.pwd}/archivos_guardados/archivos_excel") unless File.directory?("#{Dir.pwd}/archivos_guardados/archivos_excel")
              FileUtils.cp(save_path, "#{Dir.pwd}/archivos_guardados/archivos_excel/") if File.exist?(save_path)
            else
              MessageHelper.show_message_window("Error al guardar el archivo Excel.")
            end
          else
            dialog.destroy
          end
        end
      }
      export_button.signal_connect("clicked") {
        if file_chooser_button.filename.nil? || file_chooser_button.filename.empty?
          MessageHelper.show_message_window("Primero seleccione un archivo.")
        else
          data = ExportToExcel.obtain_data_base_data(file_chooser_button.filename)
          if data
            ExportToExcel.export_to_excel(data)

            MessageHelper.show_message_window("Datos exportados exitosamente.")
          else
            MessageHelper.show_message_window("Error al obtener datos de la base de datos.")
          end
        end
      }
      close_button.signal_connect("clicked") { window.destroy }
      window.signal_connect("delete-event") { window.destroy }
      window.set_position(Gtk::WindowPosition::CENTER)
      window.show_all
    end
  end
  def self.initialize
    ExportToExcelWindow.create_export_to_excel_window
  end
end
