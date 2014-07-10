require 'yaml'
require 'fileutils'
require 'commander/trello'
require 'trello'
require 'net/telnet'
module Commander

  CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/.trello.yml")

  class Runner

    attr_accessor :options, :board, :selected_commander
    cattr_accessor :users
    @@users = YAML.load_file("#{File.dirname(__FILE__)}/../../config/free.yml")

    def initialize(opts = nil)
      @options         = opts
      @options[:force] = opts[:force]
      # select commander after update_vacations if autorun
      @selected_commander = opts[:force] || opts[:status] || opts[:vacation]
    end

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

    # Should update all vacations
    def update_vacations
      @@users.keys.each do |name|
        create_vacations(name)
        proper_vacations(name) unless @vacations.empty?
        @@users[name][:vacations] = @vacations
      end
      write_to_file('free', @@users.to_yaml)
    end

    # Sets :vacation true if vacation
    def set_vacation_flag(commander, state)
      to_boolean(state)
      puts "#{commander} is on vacation"
      @@users[commander][:vacation] = true
    end

    # no .to_bool
    def to_boolean(state)
      (state == 'true') ? @state = true : @state = false
    end

    # Check for timespans
    def proper_vacations(commander)
      a = @vacations.map {|x| x.split(' - ') }
      c = a.map { |x| x.map { |b| Date.parse(b) } }
      c.each do |x|
        set_vacation_flag(commander, 'true') if (x[0]..x[1]).cover?(Date.today)
      end
    end

    # Klaus, refactor later
    def create_vacations(commander)
      @vacations = []
      tn = Net::Telnet.new('Host' => 'present.suse.de', 'Port' => 9874, 'Binmode' => false)
      collect = false
      tn.cmd(@@users[commander][:tel_name]) do |data|
        data.split("\n").each do |l|
          collect = true if l =~ /^Absence/
          next unless collect
          if l[0,1] == "-"
            collect = false
            next
          end
          dates = []
          l.split(" ").each do |date|
            unless date =~ /2014/
              next
            end
            dates.push(date)
          end
          case dates.size
            when 1
              @vacations.push("#{dates[0]}")
            when 2
              @vacations.push("#{dates[0]} - #{dates[1]}")
            else
              STDERR.puts "#{dates.size} dates for '(#{@@users[commander][:tel_name]})' #{l}"
          end
        end
      end
      tn.close
    end

    def select_commander
      # sorting logic
      @selected_commander = Hash[@@users.select { |_, v| !v[:vacation] }].sort_by{ |_, v| v[:times_commander] }
      if @selected_commander.count > 1
        if @selected_commander[0][1][:times_commander] == @selected_commander[1][1][:times_commander]
          @selected_commander = @selected_commander.sort_by { |_,v| v[:date] }[0][0]
        else
          @selected_commander = @selected_commander[0][0]
        end
      else
        @selected_commander = @selected_commander[0][0]
      end
      @@users[@selected_commander][:vacation] = false
      @@users[@selected_commander][:times_commander] = count_up
      @@users[@selected_commander][:date] = Time.now
      write_to_file('free', @@users.to_yaml)
    end

    def show_status(commander)
      puts "#{commander} was #{@@users[commander][:times_commander] } times Commanding officer of the week."
      puts "#{commander} is currently on vacation" if @@users[commander][:vacation]
      @@users[commander][:vacations].each { |x| puts x}
    end

    def forced
      @@users[@selected_commander][:vacation] = false
      @@users[@selected_commander][:date] = Time.now
      @@users[@selected_commander][:times_commander] = count_up
      write_to_file('free', @@users.to_yaml)
      puts 'i were forced'
    end

    def delete_assigned_members
      begin
        @trello.list_of_assigned_members(@card).each do |x|
          @trello.remove_member(@trello.find_member_by_username(x), @card)
        end
      rescue
        puts 'Noone assigned.'
      end
    end

    def add_member_to_card
      @trello.add_commander_to_card(find_member, @card)
    end

    def list_all_members
      @@users.each { |x| puts "-#{x.first}"}
    end

    def find_card
      @card = @trello.find_card_by_id('56') # replace when move to real board
    end

    def find_member
      @trello.find_member_by_username(@@users[@selected_commander][:trello_name])
    end

    def count_up
      @@users[@selected_commander][:times_commander] += 1
    end

    def write_to_file(filename, content)
      File.open("#{File.dirname(__FILE__)}/../../config/#{filename}.yml", 'w') do |f|
        f.write(content)
      end
    end

    def import
      @trello = Commander::TrelloConnection.new
    end

    def comment_on_card
      @comment_string = "@#{@@users[@selected_commander][:trello_name]} is your commanding officer for the next 7 Days."
      @trello.comment_on_card(@comment_string, @card)
    end
  end
end
