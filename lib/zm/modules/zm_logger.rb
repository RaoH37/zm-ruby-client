module ZmLogger
  attr_accessor :logger, :logger_file_path, :logger_level

  def logger
    @logger ||= init_logger
  end

  def logger_file_path
    @logger_file_path ||= $stdout
  end

  def logger_level
    @logger_level ||= Logger::ERROR
  end

  def init_logger
    logger = Logger.new(logger_file_path)
    logger.level = logger_level
    logger.formatter = proc do |severity, datetime, prog_name, msg|
      "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{severity} #{prog_name} - #{msg}\n"
    end
    logger
  end
end