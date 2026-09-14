require 'gtk3'
module AppTheme
  CSS = <<~CSS
    window {
      background-color: #f7f9fc;
    }
    button {
      background-image: none;
      background-color: #ffffff;
      border: 1px solid #cfd8e3;
      border-radius: 6px;
      color: #1c2733;
      padding: 6px 14px;
      font-weight: 600;
    }
    button:hover {
      background-color: #e7f1fb;
      border-color: #7db3e3;
    }
    button:active {
      background-color: #cddeec;
    }
    button:checked {
      background-color: #2a7ab0;
      color: #ffffff;
      border-color: #2a7ab0;
    }
    entry {
      background-color: #ffffff;
      border: 1px solid #cfd8e3;
      border-radius: 6px;
      padding: 6px 8px;
      color: #1c2733;
    }
    entry:focus {
      border-color: #2a7ab0;
    }
    combobox button {
      background-color: #ffffff;
    }
    treeview {
      background-color: #ffffff;
      border: 1px solid #e3e8ee;
      color: #1c2733;
    }
    treeview header button {
      background-color: #eef2f6;
      border: 1px solid #d5dbe3;
      border-radius: 0;
      font-weight: 700;
      color: #33465a;
    }
    treeview row:selected {
      background-color: #2a7ab0;
      color: #ffffff;
    }
    label#brand {
      font-size: 20px;
      font-weight: 800;
      color: #2a7ab0;
    }
    label#title {
      font-size: 15px;
      font-weight: 700;
      color: #33465a;
    }
    label#hint {
      color: #64748b;
    }
    progressbar {
      background-color: #e3e8ee;
      border-radius: 4px;
      min-height: 10px;
    }
    progressbar progress {
      background-color: #2a7ab0;
      border-radius: 4px;
    }
    window.splash {
      background-color: #ffffff;
      border: 1px solid #d5dbe3;
    }
  CSS

  @installed = false

  def self.install
    return if @installed
    provider = Gtk::CssProvider.new
    provider.load_from_data(CSS)
    Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
    @installed = true
  end
end