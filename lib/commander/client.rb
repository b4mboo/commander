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
        puts 'FORCING'
        Commander::Runner.new(@options).run
      elsif @options[:history]
        Commander::Runner.new(@options).show_hist(@options[:history])
      elsif @options[:verbose]
        puts 'verbose output.. whatever'
      else
        puts 'DEFAULT OPTIONS'
        Commander::Runner.new(@options).run
      end
    end

    def extract_options
      @optparse = OptionParser.new do |opts|

        opts.banner = "Usage: commander [options] ..."

        @options[:verbose] = false
        opts.on( '-v', '--verbose name', 'Output more information <NAME>' ) do |opt|
          @options[:verbose] = opt
        end

        @options[:force] = false
        opts.on( '-f', '--force name', 'Set COMM manually <NAME>' ) do |opt|
          @options[:force] = opt
        end

        @options[:history] = false
        opts.on( '-l', '--history name', 'Inspect history of <NAME>' ) do |opt|
          @options[:history] = opt
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

