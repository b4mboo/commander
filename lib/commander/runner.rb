require 'yaml'
require 'fileutils'
require 'commander/trello'
require 'trello'
module Commander

  NAMES = YAML.load_file("#{File.dirname(__FILE__)}/../../config/free.yml")
  NOTFREE = YAML.load_file("#{File.dirname(__FILE__)}/../../config/notfree.yml")
  CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/.trello.yml")

  class Runner

    attr_accessor :options, :board

    def initialize(opts = nil)
      import
      @options         = opts
      @options[:force] = opts[:force]
      @selected_commander = opts[:force] || select_commander
    end

    def run
      set_commander
    end

    def set_commander
      refill_list
      find_card
      comment_on_card
      delete_assigned_members
      add_member_to_card
      build_new_hash
      delete_in_old_hash(@selected_commander)
      write_to_file('free', NAMES.to_yaml) # twice?
      write_to_file('free', NAMES.to_yaml)
      puts "chose #{@selected_commander}"

    end

    def select_commander
      NAMES.keys.sample
    end

    def delete_in_old_hash(commander)
      NAMES.delete(commander)
    end

    def build_new_hash
      # logical error while forcing with -f
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
        abort('i need to die until i know how to reset CONSTANTS.. need to')
      end
    end

    def import
      @trello = Commander::TrelloConnection.new
    end

    def find_card
      @card = @trello.find_card_by_id('56') # replace when move to real board
    end

    def find_member
      if NAMES[@selected_commander]
        @trello.find_member_by_username(NAMES[@selected_commander]['trello_name']) #replace when list is valid with @selcted_commander
      else
        @trello.find_member_by_username(NOTFREE[@selected_commander]['trello_name'])
      end
    end

    def comment_on_card
      @comment_string = "#{@selected_commander} is your commanding officer for the next 7 Days."
      @trello.comment_on_card(@comment_string, @card)
    end

    def delete_assigned_members
      begin
      @trello.list_of_assigned_members(@card).each do |x|
      @trello.remove_member(@trello.find_member_by_username(x), @card)
      end
      rescue
        puts 'nothing more to delete'
      end
    end

    def add_member_to_card
      @trello.add_commander_to_card(find_member, @card)
    end

    def show_hist(commander)
      puts "#{commander} was #{NAMES[commander]['times_commander'] } times Commanding officer of the week." if NAMES[commander]
      puts "#{commander} was #{NOTFREE[commander]['times_commander'] } times Commanding officer of the week." if NOTFREE[commander]
    end
  end
end


# Change variable names
# add delete method