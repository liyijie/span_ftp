# encoding: utf-8

require 'logger'
require "nokogiri"
require "monitor"
require "net/ftp"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "app"))


module SpanFtp
  autoload :Task, "span_ftp/task"
end
