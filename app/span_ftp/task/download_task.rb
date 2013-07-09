# encodind: utf-8

module SpanFtp::Task
  class DownloadTask < FtpTask

    def initialize config_map, remotefile, localfile
      super
      @process_file_size = 0
    end

    def total_file_size ftp
      @total_file_size = ftp.size(@remotefile) if ftp
    end

    def task_name
      "download"
    end

    def process_file_size ftp
      # @process_file_size = File.size(@localfile_url) if File.exist? @localfile_url
      @process_file_size
    end

    protected

    def process
      # puts "process download"
      block_size = 10_000
      File.delete @localfile_url if File.exist? @localfile_url
      @ftp.getbinaryfile(@remotefile, @localfile_url, block_size) do |block|
        @process_file_size += block_size
      end
    end

  end
end