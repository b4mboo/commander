require 'optparse'
require 'commander/runner'
require 'commander/setup'
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
      runner = Commander::Runner
      if @options[:force]
        puts 'Forcing ..'
        runner.new(@options).set_commander
      elsif @options[:status]
        puts 'Status output ..'
        runner.new(@options).show_status(@options[:status])
      elsif @options[:vacation]
        puts 'Setting specified user as <on vacation>'
        runner.new(@options).set_vacation_flag(@options[:vacation][0], @options[:vacation][1])
      elsif @options[:auto]
        puts 'Running with default settings..'
        runner.new(@options).set_commander
      elsif @options[:list]
        puts 'Display all Members: '
        runner.new(@options).list_all_members
      elsif @options[:setup]
        puts 'Running setup..'
        Commander::Setup.configure
      else
        puts @optparse
        exit
      end
    end

    def extract_options
      @optparse = OptionParser.new do |opts|

        opts.banner = "Usage: commander [options] ..."

        @options[:vacation] = false
        opts.on( '-v', '--vacation name,bool', Array, '<NAME>,true/false(bool) comma is important' ) do |opt|
          @options[:vacation] = opt
        end

        @options[:force] = false
        opts.on( '-f', '--force name', 'Set COMM manually <NAME>' ) do |opt|
          @options[:force] = opt
        end

        @options[:status] = false
        opts.on( '-s', '--status name', 'Inspect history and status of <NAME>' ) do |opt|
          @options[:status] = opt
        end

        @options[:auto] = false
        opts.on( '-a', '--auto', 'Runs with default settings' ) do
          @options[:auto] = true
        end

        @options[:list] = false
        opts.on( '-l', '--list', 'Lists all available Members.' ) do |opt|
          @options[:list] = opt
        end

        @options[:setup] = false
        opts.on( '-x' ,'--setup', 'Runs setup for your environment.' ) do |opt|
          @options[:setup] = opt
        end

        opts.on( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end

        opts.on( '-u', '--version', 'Print programs version' ) do
          puts Commander::VERSION
          exit
        end
      end
      @optparse.parse(@argv)
    end
  end
end
