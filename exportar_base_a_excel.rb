require 'gtk3'
require 'csv'
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
    db = SQLite3::Database.new(file_path)
    db.execute("SELECT * FROM tabla_de_datos;")
  rescue SQLite3::Exception => e
    puts "Error al obtener datos de la base de datos: #{e}"
    nil
  ensure
    db.close if db
  end
  def self.import_csv(file_path, status_label)
    rows = CSV.read(file_path, headers: false)
    header_candidate = rows[0] || []
    first_val = header_candidate.first.to_s.upcase
    if first_val == 'ID' || first_val == 'MODELO' || first_val == 'SERIE'
      rows = rows[1..-1]
    end
    insert_rows = rows.map { |r| r.length > 14 ? r[1..-1] : r }
    insert_rows.each do |row|
      padded = row + Array.new([14 - row.length, 0].max, nil)
      insertar_datos([padded])
    end
    count = insert_rows.length
    status_label.text = "Importados #{count} registros desde CSV."
    count
  rescue StandardError => e
    status_label.text = "Error al importar CSV: #{e.message}"
    0
  end
  def self.import_db(file_path, status_label)
    data = obtain_data_base_data(file_path)
    if data.nil? || data.empty?
      status_label.text = "No se encontraron datos en la base de datos seleccionada."
      return 0
    end
    insert_rows = data.map { |r| r.length > 14 ? r[1..-1] : r }
    insert_rows.each do |row|
      padded = row + Array.new([14 - row.length, 0].max, nil)
      insertar_datos([padded])
    end
    count = insert_rows.length
    status_label.text = "Importados #{count} registros desde la base de datos."
    count
  rescue StandardError => e
    status_label.text = "Error al importar: #{e.message}"
    0
  end
  class ExportToExcelWindow
    def self.create_export_to_excel_window
      window = Gtk::Window.new("Importar/Exportar base de datos")
      window.set_default_size(540, 460)
      window.set_border_width(12)
      vbox = Gtk::Box.new(:vertical, 10)
      window.add(vbox)

      import_frame = Gtk::Frame.new(" Importar datos a la base de datos actual ")
      vbox.pack_start(import_frame, expand: false, fill: true, padding: 5)
      import_box = Gtk::Box.new(:vertical, 8)
      import_box.set_border_width(10)
      import_frame.add(import_box)

      import_source_combo = Gtk::ComboBoxText.new
      import_source_combo.append_text('CSV')
      import_source_combo.append_text('Archivo de base de datos (.db)')
      import_source_combo.active = 0
      import_source_combo.set_tooltip_text('Tipo de archivo a importar')
      import_box.pack_start(import_source_combo, expand: false, fill: false, padding: 0)

      import_file_chooser = Gtk::FileChooserButton.new("Seleccionar archivo", Gtk::FileChooserAction::OPEN)
      import_csv_filter = Gtk::FileFilter.new
      import_csv_filter.name = "Archivos CSV (*.csv)"
      import_csv_filter.add_pattern("*.csv")
      import_db_filter = Gtk::FileFilter.new
      import_db_filter.name = "Archivos de base de datos (*.db)"
      import_db_filter.add_pattern("*.db")
      import_file_chooser.add_filter(import_csv_filter)
      import_file_chooser.add_filter(import_db_filter)
      import_box.pack_start(import_file_chooser, expand: false, fill: false, padding: 0)

      import_status = Gtk::Label.new('Selecciona un archivo CSV o .db para importar.')
      import_status.set_halign(:start)
      import_box.pack_start(import_status, expand: false, fill: false, padding: 0)

      import_button = Gtk::Button.new(label: 'Importar a la base de datos')
      import_button.set_tooltip_text('Inserta los registros del archivo seleccionado en la base de datos actual.')
      import_button.set_halign(Gtk::Align::CENTER)
      import_box.pack_start(import_button, expand: false, fill: false, padding: 0)

      import_button.signal_connect("clicked") do
        path = import_file_chooser.filename
        if path.nil? || path.empty?
          import_status.text = "Selecciona un archivo primero."
        else
          case import_source_combo.active
          when 0
            ExportToExcel.import_csv(path, import_status)
          else
            ExportToExcel.import_db(path, import_status)
          end
        end
      end

      export_frame = Gtk::Frame.new(" Exportar base de datos a Excel ")
      vbox.pack_start(export_frame, expand: false, fill: true, padding: 5)
      export_box = Gtk::Box.new(:vertical, 8)
      export_box.set_border_width(10)
      export_frame.add(export_box)

      export_file_label = Gtk::Label.new("Seleccionar archivo de base de datos:")
      export_file_label.set_halign(Gtk::Align::CENTER)
      export_box.pack_start(export_file_label, expand: false, fill: false, padding: 0)

      export_file_chooser = Gtk::FileChooserButton.new("Seleccionar archivo", Gtk::FileChooserAction::OPEN)
      export_file_chooser.set_current_folder("#{Dir.pwd}/Copias_de_seguridad")
      export_file_filter = Gtk::FileFilter.new
      export_file_filter.name = "Archivos de base de datos (*.db)"
      export_file_filter.add_pattern("*.db")
      export_file_chooser.add_filter(export_file_filter)
      export_box.pack_start(export_file_chooser, expand: false, fill: false, padding: 0)

      export_status = Gtk::Label.new('')
      export_status.set_halign(Gtk::Align::CENTER)
      export_box.pack_start(export_status, expand: false, fill: false, padding: 0)

      export_button_box = Gtk::Box.new(:horizontal, 10)
      export_button_box.set_halign(Gtk::Align::CENTER)
      export_box.pack_start(export_button_box, expand: false, fill: false, padding: 0)

      convert_button = Gtk::Button.new(label: "Convertir a Excel")
      convert_button.set_size_request(150, 30)
      export_button_box.pack_start(convert_button, expand: true, fill: true, padding: 0)

      save_button = Gtk::Button.new(label: "Guardar archivo Excel")
      save_button.set_size_request(150, 30)
      export_button_box.pack_start(save_button, expand: true, fill: true, padding: 0)

      convert_button.signal_connect("clicked") do
        path = export_file_chooser.filename
        if path.nil? || path.empty?
          export_status.text = "Selecciona un archivo .db primero."
        else
          data = ExportToExcel.obtain_data_base_data(path)
          if data
            ExportToExcel.export_to_excel(data)
            export_status.text = "Archivo datos.xlsx creado correctamente."
          else
            export_status.text = "Error al leer la base de datos."
          end
        end
      end

      save_button.signal_connect("clicked") do
        if export_file_chooser.filename.nil? || export_file_chooser.filename.empty?
          export_status.text = "Primero selecciona un archivo .db."
        elsif !File.exist?('datos.xlsx')
          export_status.text = "Primero convierte la base de datos con 'Convertir a Excel'."
        else
          save_dialog = Gtk::FileChooserDialog.new(
            title: "Guardar archivo Excel",
            parent: window,
            action: Gtk::FileChooserAction::SAVE,
            buttons: [["Cancelar", Gtk::ResponseType::CANCEL], ["Guardar", Gtk::ResponseType::ACCEPT]]
          )
          save_dialog.current_name = "Datos_convertidos_Base_de_datos.xlsx"
          if save_dialog.run == Gtk::ResponseType::ACCEPT
            save_path = save_dialog.filename
            save_dialog.destroy
            if save_path
              FileUtils.mv('datos.xlsx', save_path)
              export_status.text = "Guardado en #{save_path}."
              FileUtils.mkdir_p("#{Dir.pwd}/archivos_guardados/archivos_excel")
              FileUtils.cp(save_path, "#{Dir.pwd}/archivos_guardados/archivos_excel/")
            end
          else
            save_dialog.destroy
          end
        end
      end

      target = Gtk::TargetEntry.new("text/uri-list", 0, 0)
      window.drag_dest_set(Gtk::DestDefaults::ALL, [target], Gtk::DragAction::COPY)
      window.signal_connect("drag-data-received") do |_widget, _ctx, _x, _y, data, _info, _time|
        uri = data.text.strip.split("\r\n").first
        next unless uri
        path = uri.sub(%r{^file://}, '').gsub(/%20/, ' ').strip
        ext = File.extname(path).downcase
        if ext == '.csv'
          import_source_combo.active = 0
          import_file_chooser.set_filename(path) rescue nil
          ExportToExcel.import_csv(path, import_status)
        elsif ext == '.db'
          import_source_combo.active = 1
          import_file_chooser.set_filename(path) rescue nil
          ExportToExcel.import_db(path, import_status)
        else
          import_status.text = "Formato no soportado: #{ext}. Arrastra un archivo .csv o .db."
        end
      end

      close_button = Gtk::Button.new(label: "Cerrar")
      close_button.set_size_request(150, 30)
      close_button.set_halign(Gtk::Align::CENTER)
      vbox.pack_end(close_button, expand: false, fill: false, padding: 5)
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
