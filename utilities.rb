require 'gtk3'
require 'fileutils'
require_relative 'dialog_helper'
def show_message_dialog(title, message)
  DialogHelper.show_info(title, message)
end
def update_time_label(label)
  return unless label && !label.destroyed?
  begin
    label.text = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  rescue StandardError => e
    puts "Error updating time label: #{e.message}"
    puts e.backtrace.join("\n")
  end
end