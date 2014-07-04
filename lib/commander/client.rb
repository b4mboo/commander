require 'optparse'
require 'commander/runner'
module Commander
  # CLI with options
  class Client

    attr_accessor :options

    def initialize(argv)
      @options = {}
      @argv = argv
      extract_options
    end


    def execute!
      if @options[:force]
        puts 'will force a commander to be set'
        debugger
        Commander::Runner.new(@options).run
      elsif @options[:history]
        puts 'history'
      elsif @options[:verbose]
        puts 'verbose output'
      else
        puts 'i will run with default settings'
        Commander::Runner.new.run
      end
    end

    def extract_options
      @optparse = OptionParser.new do |opts|

        opts.banner = "Usage: commander [options] ..."

        @options[:verbose] = false
        opts.on( '-v', '--verbose', 'Output more information' ) do
          @options[:verbose] = true
        end

        @options[:force] = false
        opts.on( '-f', '--force', 'Set COMM manually' ) do
          @options[:force] = true
        end

        @options[:history] = nil
        opts.on( '-l', '--history FILE', 'Inspect history' ) do |file|
          @options[:history] = file
        end

        opts.on( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end

        opts.on( '', '--version', 'Print programm version' ) do
          puts Commander::VERSION
          exit
        end
      end
      @optparse.parse(@argv)
    end
  end
end

