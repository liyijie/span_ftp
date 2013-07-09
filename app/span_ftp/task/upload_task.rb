# encodind: utf-8

module SpanFtp::Task
  class UploadTask < FtpTask

    def initialize config_map, remotefile, localfile
      super
      @process_file_size = 0
    end


    def task_name
      "upload"
    end

    def process_file_size ftp
      @process_file_size
    end

    def total_file_size ftp
      @total_file_size = File.size(@localfile_url)
    end

    protected

    def process
      block_size = 10_000
      @ftp.putbinaryfile(@localfile_url, @remotefile, block_size) do |block|
        @process_file_size += block_size
      end
    end

  end
end