# encoding: utf-8


module SpanFtp::Task
  class BaseTask
    
    attr_accessor :status

    def initialize
      @status = :idle  
    end

    def start_task
      @thread = Thread.new do
        begin
          before_process
          @status = :running
          process
          @status = :finish
        rescue Exception => e
          @status = :error
          puts e
          puts e.backtrace
        ensure
          after_process
        end
      end
    end

    def stop_task
      Thread.kill @thread if @thread
    end

    # should be implement
    def task_name
      "base"
    end


    protected
    # should be implement
    def process
      puts "should be implement"
    end

    def before_process ; end

    def after_process ; end
      
  end
end