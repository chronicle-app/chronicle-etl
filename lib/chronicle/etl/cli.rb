require "chronicle/etl/version"
require 'thor'

module Chronicle
  module Etl
    class Error < StandardError; end
    class CLI < Thor
      desc "hello [name]", "Says name"
      def hello(name)
        puts name
      end
    end
  end
end
