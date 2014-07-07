require 'yaml'
require 'fileutils'
require 'commander/trello'
require 'trello'
module Commander

    NAMES = YAML.load_file("#{File.dirname(__FILE__)}/../../config/free.yml")
    CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/.trello.yml")

  class Runner

    attr_accessor :options, :board

    def initialize(opts = nil)
      @options         = opts
      @options[:force] = opts[:force]
      @selected_commander = opts[:force] || select_commander
    end

    def run
      set_commander
    end

    def set_commander
      import
      find_card
      comment_on_card
      delete_assigned_members
      # add_member_to_card
      build_new_hash
      delete_in_old_hash(@selected_commander)
      write_to_file('free', NAMES.merge(@content).to_yaml)
      puts "Chose #{@selected_commander}"

    end

    def select_commander
      Hash[NAMES.sort_by { |k, v| [v[:times_commander], v[:date]] }].keys.first
    end

    def delete_in_old_hash(commander)
      NAMES.delete(commander)
    end

    def build_new_hash
      count_up
    end

    def count_up
      @counter = NAMES[@selected_commander]['times_commander'] += 1
      @content = { @selected_commander => { 'times_commander' => @counter , 'trello_name' =>  NAMES[@selected_commander]['trello_name'], 'date' => Time.now } }
    end


    def write_to_file(filename, content)
      File.open("#{File.dirname(__FILE__)}/../../config/#{filename}.yml", 'w') do |f|
        f.write(content)
      end
    end

    def import
      @trello = Commander::TrelloConnection.new
    end

    def find_card
      @card = @trello.find_card_by_id('56') # replace when move to real board
    end

    def find_member
      @trello.find_member_by_username(NAMES[@selected_commander]['trello_name'])
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
      puts "#{commander} was #{@list[commander]['times_commander'] } times Commanding officer of the week."
    end
  end
end


# choose based on time


# def refill_list
#   unless NAMES.any?
#     FileUtils.cp("#{File.dirname(__FILE__)}/../../config/notfree.yml", "#{File.dirname(__FILE__)}/../../config/free.yml")
#     File.open("#{File.dirname(__FILE__)}/../../config/notfree.yml", 'w') do |f|
#       f.write('')
#     end
#     puts 'refilled the list[debug]'
#     abort('i need to die until i know how to reset CONSTANTS.. need to')
# end
# end


# def actually_write
#   NOTFREE ? write_to_file('notfree', NOTFREE.merge(@content).to_yaml) : write_to_file('notfree', (@content).to_yaml)
# end

# NOTFREE = YAML.load_file("#{File.dirname(__FILE__)}/../../config/notfree.yml")
