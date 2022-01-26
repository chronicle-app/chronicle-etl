require 'tty/progressbar'
require 'colorize'

module Chronicle
  module ETL
    module Utils

      class ProgressBar
        FORMAT_WITH_TOTAL = [
          ':bar ',
          ':percent'.light_white,
          ' | '.light_black,
          ':current'.light_white,
          '/'.light_black,
          ':total'.light_white,
          ' ('.light_black,
          'ELAPSED:'.light_black,
          ':elapsed'.light_white,
          ' | ETA:'.light_black,
          ':eta'.light_white,
          ' | RATE: '.light_black,
          ':mean_rate'.light_white,
          '/s) '.light_black
        ].join.freeze

        FORMAT_WITHOUT_TOTAL = [
          ':current'.light_white,
          '/'.light_black,
          '???'.light_white,
          ' ('.light_black,
          'ELAPSED:'.light_black,
          ':elapsed'.light_white,
          ' | ETA:'.light_black,
          '??:??'.light_white,
          ' | RATE: '.light_black,
          ':mean_rate'.light_white,
          '/s) '.light_black
        ].join.freeze

        def initialize(title: 'Loading', total:)
          opts = {
            clear: true,
            complete: '▓'.light_blue,
            incomplete: '░'.blue,
            frequency: 10
          }

          if total
            opts[:total] = total
            format_str = "#{title} #{FORMAT_WITH_TOTAL}"
            @pbar = TTY::ProgressBar.new(FORMAT_WITH_TOTAL, opts)
          else
            format_str = "#{title} #{FORMAT_WITHOUT_TOTAL}"
            opts[:no_width] = true
          end

          @pbar = TTY::ProgressBar.new(format_str, opts)

          @pbar.resize
        end

        def increment
          @pbar.advance(1)
        end

        def log(message)
          message.split("\n").each do |line|
            @pbar.log message
          end
        end

        def finish
          @pbar.finish
        end
      end
    end
  end
end
