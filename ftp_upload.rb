# encoding: utf-8

require_relative "app/span_ftp"

controller = SpanFtp::Task::FtptaskController.new :upload
controller.run