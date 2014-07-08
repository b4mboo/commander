require 'yaml'
require 'fileutils'
require 'commander/trello'
require 'trello'
module Commander

  NAMES = YAML.load_file("#{File.dirname(__FILE__)}/../../config/free.yml")
  CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/.trello.yml")

  class Runner

    attr_accessor :options, :board, :selected_commander

    def initialize(opts = nil)
      @options         = opts
      @options[:force] = opts[:force]
      @selected_commander = opts[:force] || opts[:status] || opts[:vacation] || (select_commander if opts[:auto])
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
      # sorting logic
      @selected_commander = Hash[NAMES.select { |_, v| !v[:vacation] }].sort_by{ |_, v| v[:times_commander] }
      if @selected_commander.count > 1
        if @selected_commander[0][1][:times_commander] == @selected_commander[1][1][:times_commander]
          @selected_commander = @selected_commander.sort_by { |_,v| v[:date] }[0][0]
        else
          @selected_commander = @selected_commander[0][0]
        end
      else
        @selected_commander = @selected_commander[0][0]
      end
      set_commander
    end

    def delete_in_old_hash(commander)
      NAMES.delete(commander)
    end

    def build_new_hash
      count_up
    end

    def count_up
      @counter = NAMES[@selected_commander][:times_commander] += 1
      @content = { @selected_commander => { times_commander:  @counter , trello_name: NAMES[@selected_commander][:trello_name], date: Time.now, vacation: false } }
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
      @trello.find_member_by_username(NAMES[@selected_commander][:trello_name])
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

    def show_status(commander)
      puts "#{commander} was #{NAMES[commander][:times_commander] } times Commanding officer of the week."
      puts "#{commander} is currently on vacation" if NAMES[commander][:vacation]
    end

    # Diry workaround..
    def to_boolean(state)
      (state == 'true') ? @state = true : @state = false
    end

    def set_vacation_flag(commander, state)
      to_boolean(state)
      puts "will set #{commander} to <on/not on vacation>"
      @vacation = { commander => { times_commander: NAMES[commander][:times_commander], trello_name: NAMES[commander][:trello_name], date: Time.now, vacation: @state } }
      write_to_file('free', NAMES.merge(@vacation).to_yaml)
    end

    def list_all_members
      NAMES.each { |x| puts "-#{x.first}"}
    end

  end
end
# set holiday
