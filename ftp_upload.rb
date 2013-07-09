# encoding: utf-8

require_relative "app/span_ftp"

File.open("upload.log", "w") do |file|
  controller = SpanFtp::Task::FtptaskController.new :upload, file
  controller.run
end
