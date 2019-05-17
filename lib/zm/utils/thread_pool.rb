module Zm
  module Utils
    class ThreadPool
      attr_reader :result, :number, :size

      def initialize(size)
        @finish = false
        @result = nil
        @number = nil
        @size = size
        @jobs = Queue.new
        @pool = init_pool
      end

      def finish?
        @finish
      end

      def finish!(result, number)
        @finish = true
        @result = result
        @number = number
        @jobs = [[ Proc.new {}, nil]]
      end

      def jobs_size
        @jobs.size
      end

      # add a job to queue
      def schedule(*args, &block)
        @jobs << [block, args]
      end

      def clear!
        @jobs = []
      end

      # run threads and perform jobs from queue
      def run!
        @size.times do
          schedule { throw :exit }
        end
        @pool.map(&:join)
        stop
      end

      def stop
        @jobs.close
        @pool.each(&:exit)
        @pool.clear
        true
      end

      private

      def init_pool
        Array.new(size) do
          Thread.new do
            catch(:exit) do
              loop do
                job, args = @jobs.pop
                job.call(*args)
                break if @jobs.size.zero?
              end
            end
          end
        end
      end
    end
  end
end
