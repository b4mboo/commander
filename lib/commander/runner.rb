require 'yaml'
require 'commander/trello'
require 'commander/vacations'
require 'commander/helpers'
require 'trello'
module Commander

  CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/.trello.yml")

  class Runner

    attr_accessor :options, :board, :selected_commander, :users

    # Init
    def initialize(opts = {})
      @options         = opts
      @options[:force] = opts[:force]
      @selected_commander = opts[:force] || opts[:status] || opts[:vacation]
      @users = YAML.load_file("#{File.dirname(__FILE__)}/../../config/members.yml")
    end

    # Call for options
    def run
      set_commander
    end

    # Steps
    def set_commander
      import
      find_card
      update_vacations
      select_commander if @options[:auto]
      forced if @options[:force]
      comment_on_card
      delete_assigned_members
      add_member_to_card
      puts "Chose: #{@selected_commander}" # debug
    end

    # Updates all vacations
    def update_vacations
      self.users.keys.each do |name|
        @vacations = Commander::Vacations.find_vacations(self.users[name][:tel_name]) #tel_name
        evaluate_vacations(name)
        @users[name][:vacations] = @vacations
      end
      write_to_file('members', @users.to_yaml)
    end

    # Sets :vacation true if vacation
    def set_vacation_flag(commander, state)
      Commander::Helpers.to_boolean(state)
      puts "#{commander} is on vacation"
      @users[commander][:vacation] = true
    end

    # Check for timespans
    def evaluate_vacations(commander)
      parse_vacations.each do |check|
        set_vacation_flag(commander, 'true') if (check[0]..check[1]).cover?(Date.today)
      end
    end

    # Parsing vacation to computable format
    def parse_vacations
      split = @vacations.map { |x| x.split(' - ') }
      split.map { |x| x.map { |b| Date.parse(b) } }
    end

    # Sorting logic
    def select_commander
      @selected_commander = Hash[@users.select { |_, v| !v[:vacation] }].sort_by{ |_, v| v[:times_commander] }
      if @selected_commander.count > 1
        if @selected_commander[0][1][:times_commander] == @selected_commander[1][1][:times_commander]
          @selected_commander = @selected_commander.sort_by { |_,v| v[:date] }[0][0]
        else
          @selected_commander = @selected_commander[0][0]
        end
      else
        @selected_commander = @selected_commander[0][0]
      end
      write_attributes
    end

    # Prints out the status
    def show_status(commander)
      puts "#{commander} was #{@users[commander][:times_commander] } times Commanding officer of the week."
      puts "#{commander} is currently on vacation" if @users[commander][:vacation]
      @users[commander][:vacations].each { |x| puts x}
    end

    # And writes
    def write_attributes
      users[@selected_commander][:vacation] = false
      users[@selected_commander][:times_commander] = count_up
      users[@selected_commander][:date] = Time.now
      write_to_file('members', @users.to_yaml)
    end

    # Manipulates yaml on options[:force]
    def forced
      write_attributes
    end

    # Delete assigned commander from Trello Card
    def delete_assigned_members
      @card.members.each{|member| @card.remove_member member}
    end

    # Adds commander to Trello Card
    def add_member_to_card
      @trello.add_commander_to_card(find_member, @card)
    end

    # List all available Users
    def list_all_members
      @users.each { |x| puts "-#{x.first}"}
    end

    # Finds the Commander Card on Trello
    def find_card
      @card = @trello.find_card_by_id('56') # replace when move to real board
    end

    # Finds the member on Trello
    def find_member
      @trello.find_member_by_username(users[@selected_commander][:trello_name])
    end

    # Increments the counter
    def count_up
      users[@selected_commander][:times_commander] += 1
    end

    # Writes to yaml
    def write_to_file(filename, content)
      File.open("#{File.dirname(__FILE__)}/../../config/#{filename}.yml", 'w') do |f|
        f.write(content)
      end
    end

    # Imports TrelloConnection
    def import
      @trello = Commander::TrelloConnection.new
    end

    # Comments on Trello Card
    def comment_on_card
      @comment_string = "@#{@users[@selected_commander][:trello_name]} is your commanding officer for the next 7 Days."
      @trello.comment_on_card(@comment_string, @card)
    end
  end
end
