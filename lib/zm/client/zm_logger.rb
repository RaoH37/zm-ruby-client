# frozen_string_literal: true

require 'logger'

module Zm
  module Client
    class ZmLogger < ::Logger
      def initialize(*args, **kwargs)
        super
        @formatter ||= ZmFormatter.new
      end

      def colorize!
        extend(ZmLoggerColorized)
      end

      class ZmFormatter < ::Logger::Formatter
        Format = "[%s] %5s : %s\n"

        def call(severity, time, _, msg)
          format(Format, format_datetime(time), severity, msg2str(msg))
        end
      end

      module ZmLoggerColorized
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

        def format_message(severity, datetime, progname, msg)
          colorize_message(
            severity,
            super(severity, datetime, progname, msg)
          )
        end
      end
    end
  end
end
