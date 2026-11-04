# frozen_string_literal: true

require 'logger'

module Zm
  module Client
    class ZmLogger < ::Logger
      def initialize(*, **)
        super
        @formatter ||= ZmFormatter.new
        @colorize = false
      end

      def colorize!
        self.colorize = true
      end

      def colorize=(value)
        @colorize = value ? true : false
      end

      def colorize?
        @colorize
      end

      def log_path=(log_path)
        previous = @logdev
        @logdev = log_path.nil? || log_path == File::NULL ? nil : ::Logger::LogDevice.new(log_path)
        previous.close if previous&.filename
      end

      class ZmFormatter < ::Logger::Formatter
        Format = "[%s] %5s : %s\n"

        def call(severity, time, _, msg)
          format(Format, format_datetime(time), severity, msg2str(msg))
        end
      end

      # ANSI colors of the log messages
      module ZmLoggerColors
        # ANSI sequence modes
        MODES = {
          clear: 0,
          bold: 1,
          italic: 3,
          underline: 4
        }.freeze

        # ANSI sequence colors
        BLACK   = "\e[30m"
        RED     = "\e[31m"
        GREEN   = "\e[32m"
        YELLOW  = "\e[33m"
        BLUE    = "\e[34m"
        MAGENTA = "\e[35m"
        CYAN    = "\e[36m"
        WHITE   = "\e[37m"

        def severity_color(severity)
          case severity
          when 'DEBUG'
            CYAN
          when 'INFO'
            GREEN
          when 'WARN'
            YELLOW
          when 'ERROR'
            RED
          when 'FATAL'
            mode_code(:bold)
          when 'ANY'
            mode_code(:clear)
          else
            mode_code(:clear)
          end
        end

        def mode_code(mode)
          mode = mode.to_sym if mode.is_a?(String)
          return unless (value = MODES[mode])

          "\e[#{value}m"
        end

        def colorize_message(severity, str)
          "#{severity_color(severity)}#{str}#{mode_code(:clear)}"
        end
      end

      include ZmLoggerColors

      private

      def format_message(severity, datetime, progname, msg)
        message = super
        @colorize ? colorize_message(severity, message) : message
      end

      # colorizes every message, kept for the loggers extended with it
      module ZmLoggerColorized
        include ZmLoggerColors

        def format_message(severity, datetime, progname, msg)
          colorize_message(
            severity,
            super
          )
        end
      end
    end
  end
end
