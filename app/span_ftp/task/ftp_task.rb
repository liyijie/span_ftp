# encodind: utf-8

module SpanFtp::Task
  class FtpTask < BaseTask

    def initialize config_map, remotefile, localfile
      super()
      @ip = config_map[:ip]
      @port = config_map[:port] || 21
      @user = config_map[:user]
      @password = config_map[:password]
      @remotedir = config_map[:remotedir]
      @localdir = config_map[:localdir]
      @remotefile = remotefile
      @localfile = localfile
      @ftp = nil
      @localfile_url = File.join @localdir, @localfile
    end

    def task_name
      "ftp"
    end

    def create_ftp_session
      ftp = Net::FTP.new()
      ftp.connect(@ip, @port) #默认端口是21  
      ftp.passive = true
      ftp.login(@user, @password)
      ftp.chdir @remotedir
      ftp
    end

    protected

    def before_process
      # puts "#{@ip},#{@user},#{@password},#{@remotedir},#{@remotefile}"
      @ftp = create_ftp_session
      @process_file_size = 0
    end

    def after_process
      @ftp.close if @ftp
      @ftp.quit if @ftp
    end

  end
end