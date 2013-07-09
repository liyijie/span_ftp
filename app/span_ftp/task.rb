# encoding: utf-8

module SpanFtp::Task
  autoload :BaseTask, "span_ftp/task/base_task"
  autoload :FtpTask, "span_ftp/task/ftp_task"
  autoload :UploadTask, "span_ftp/task/upload_task"
  autoload :DownloadTask, "span_ftp/task/download_task"
  autoload :FtptaskController, "span_ftp/task/ftptask_controller"
end