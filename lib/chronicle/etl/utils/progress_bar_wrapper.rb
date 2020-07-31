require 'ruby-progressbar'
require 'colorize'

module Chronicle
  module Etl
    module Utils
      class ProgressBarWrapper
        def initialize(count)
          return unless tty?

          @pbar = ProgressBar.create(
            format: '%b%i  %c/%C (%P%%)  %a %e  Rate: %R',
            remainder_mark: '░',
            progress_mark: '▓'.colorize(:light_green),
            starting_time: 0,
            lenth: 200,
            throttle_rate: 0.1,
            total: count,
            unknown_progress_animation_steps: ['▓░░░', '░▓░░', '░░▓░', '░░░▓']
          )
        end

        def increment
          @pbar&.increment
        end

        def log(message)
          @pbar&.log message
        end

        def finish
          @pbar&.finish
        end

        private

        def tty?
          $stdout.isatty
        end
      end
    end
  end
end
