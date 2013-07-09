# encoding: utf-8

require_relative "app/span_ftp"

File.open("download.log", "w") do |file|
  controller = SpanFtp::Task::FtptaskController.new :download, file
  controller.run
end

