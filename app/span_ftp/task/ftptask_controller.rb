# encoding: utf-8

module SpanFtp::Task

  class FtptaskController

    def initialize type, logger
      @type = type
      @config_map = {}
      @task_map = {}
      @total_file_size = 0
      @process_file_size = 0
      @begintime = 0
      @endtime = 0
      @index = 1
      load_config
      @logger = logger
    end

    def run
      return if @test == "true" || @test == "test"
      @index = 1
      loop do
        begin
          puts "=====================begin #{@index} ftp cycle==================="
          @logger.puts "=====================begin #{@index} ftp cycle==================="
          process
          @endtime = Time.now
          interval = @endtime - @begintime
          speed = @process_file_size * 8.0 / 1024 / interval
          speed = speed.round(2)
          puts "file size is:#{@process_file_size * 8.0 /1024}kb, spend time is:#{interval}s, speed is:#{speed}kbps"
          @logger.puts "file size is:#{@process_file_size * 8.0 /1024}kb, spend time is:#{interval}s, speed is:#{speed}kbps"
          puts "=====================end #{@index} ftp cycle==================="
          @logger.puts "=====================end #{@index} ftp cycle==================="
          @logger.flush
          sleep(@sleep - 1) if (@sleep - 1 > 0)
        rescue Exception => e 
          # puts e
          # puts e.backtrace 
          @endtime = Time.now
          interval = @endtime - @begintime
          speed = @process_file_size * 8.0 / 1024
          speed = speed.round(2)
          puts "file size is:#{@process_file_size * 8.0 /1024}kb, spend time is:#{interval}s, speed is:#{speed}kbps" 
          @logger.puts "file size is:#{@process_file_size * 8.0 /1024}kb, spend time is:#{interval}s, speed is:#{speed}kbps" 
          next
        ensure
          (1..@thread_num).each do |index|
            @task_map[index].stop_task if @task_map[index]
          end
          @index += 1
          @logger.flush
          sleep 1
        end
      end
    end

    private
    # load config from the config.xml
    def load_config
      if @type == :upload
        config_file = "ul_config.xml"
      else
        config_file = "dl_config.xml"
      end
      doc = Nokogiri::XML(open("config/#{config_file}"))
      doc.search(@type.to_s).each do |config|
        @config_map[:ip] = get_content config, "ip"
        @config_map[:port] = get_content config, "port"
        @config_map[:user] = get_content config, "user"
        @config_map[:password] = get_content config, "password"
        @config_map[:remotedir] = get_content config, "remotedir"
        @config_map[:localdir] = get_content config, "localdir"

        @localfile = get_content config, "localfile"
        @remotefile = get_content config, "remotefile"

        @thread_num = get_content(config, "thread_num").to_i
        @sleep = get_content(config, "sleep").to_i
        @test = get_content(config, "test")
      end
    end

    def get_content element, name
      content = ""
      node = element.search(name).first
      if node
        content = node.content.to_s.strip.encode 'gbk'
      end
      content
    end

    def create_task index
      task = nil
      if (@type == :upload)
        remotefile = "#{index}_#{@localfile}"
        localfile = @localfile
        task = UploadTask.new @config_map, remotefile, localfile
      else
        remotefile = @remotefile
        localfile = "#{index}_#{@remotefile}"
        task = DownloadTask.new @config_map, remotefile, localfile
      end
      task
    end

    def process

      (1..@thread_num).each do |index|
        @task_map[index] = create_task index
        @task_map[index].start_task
      end

      monitor_ftp = @task_map[1].create_ftp_session
      @total_file_size = @task_map[1].total_file_size monitor_ftp
      @process_file_size = 0
      @begintime = Time.now

      loop do
        sleep 1
        process_file_size = 0
        (1..@thread_num).each do |index|
          task = @task_map[index]
          next if task.nil?
          if task.status == :running || task.status == :finish
            process_file_size += task.process_file_size monitor_ftp
          elsif task.status == :error
            process_file_size = @total_file_size
            break
          end
        end
        progress = (process_file_size * 100.0 / @total_file_size).round(2)
        speed = (process_file_size - @process_file_size) * 8.0 / 1024
        speed = speed.round(2)
        progress = 100 if progress > 100
        $stdout.print "speed is:#{speed}kbps\tprogress is:#{progress}%\t\r"
        $stdout.flush
        @process_file_size = process_file_size
        break if process_file_size >= @total_file_size
      end

      (1..@thread_num).each do |index|
        @task_map[index].stop_task if @task_map[index]
      end
    end

  end
end