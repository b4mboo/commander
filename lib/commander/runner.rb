require 'yaml'
require 'fileutils'
require 'commander/trello'
module Commander

  NAMES = YAML.load_file("#{File.dirname(__FILE__)}/../../config/free.yml")
  NOTFREE = YAML.load_file("#{File.dirname(__FILE__)}/../../config/notfree.yml")
  CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/.trello.yml")

  class Runner

    attr_accessor :options

    def initialize(opts)
      @options         = opts
      @options[:force] = opts[:force]
      @commander = ARGV[1]
    end

    def run(commander = nil)
      debugger
      @commander ||= set_commander
    end

    def set_commander
      refill_list
      select_commander
      build_new_hash
      delete_in_old_hash(@selected_commander)
      write_to_file('free', NAMES.to_yaml)
      puts "chose #{@selected_commander}"
    end

    def select_commander
      @selected_commander = NAMES.keys.sample
    end

    def delete_in_old_hash(commander)
      NAMES.delete(commander)
    end

    def build_new_hash
      @variable_name = Hash.new
      @new_value = NAMES[@selected_commander]['times_commander'] += 1
      @stuff_to_write = { @selected_commander => { 'times_commander' => @new_value , 'trello_name' => NAMES[@selected_commander]['trello_name']} }
      if NOTFREE
        write_to_file('notfree', NOTFREE.merge(@stuff_to_write).to_yaml)
      else
        write_to_file('notfree', (@stuff_to_write).to_yaml)
      end
    end

    def write_to_file(filename, content)
      File.open("#{File.dirname(__FILE__)}/../../config/#{filename}.yml", 'w') do |f|
        f.write(content)
      end
    end

    def refill_list
      if !NAMES.any?
        FileUtils.cp("#{File.dirname(__FILE__)}/../../config/notfree.yml", "#{File.dirname(__FILE__)}/../../config/free.yml")
        File.open("#{File.dirname(__FILE__)}/../../config/notfree.yml", 'w') do |f|
          f.write('')
        end
        puts 'refilled the list[debug]'
        abort('died')
      end

      # def import
      #   @trello = Commander::TrelloConnection.new
      #   @client = Commander::Client.new(ARGV.dup)
      # end

    end
  end
end
