require 'yaml'
require 'fileutils'
require 'commander/trello'
require 'trello'
require 'net/telnet'
module Commander

  NAMES = YAML.load_file("#{File.dirname(__FILE__)}/../../config/free.yml")
  CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/.trello.yml")

  class Runner

    attr_accessor :options, :board, :selected_commander

    def initialize(opts = nil)
      @options         = opts
      @options[:force] = opts[:force]
      # select commander after update_vacations if autorun
      @selected_commander = opts[:force] || opts[:status] || opts[:vacation]
    end

    def run
      set_commander
    end

    # Should update all vacations
    def update_vacations
      NAMES.keys.each do |x|
        create_vacations(x)
        proper_vacations(x) unless @vacations.empty? || NAMES[x][:vacations].empty? #can be deleted later
      end
    end

    def set_commander
      import
      find_card
      update_vacations
      select_commander if @options[:auto]
      comment_on_card
      delete_assigned_members
      add_member_to_card
      @forced = build_new_hash(@selected_commander, count_up, false, NAMES[@selected_commander][:vacations]) if @options[:force]#replace with @vacations [debugging]
      write_to_file('free', NAMES.merge(@forced).to_yaml) if @options[:force]
      puts "Chose: #{@selected_commander}" # debug
    end

    # How to ignore optionals (change the e.g. last parameter)
    def hash_scaffold(commander = @selected_commander, counter = count_up, vacation_flag = false, vacation_dates = @vacations)

      { commander => {times_commander: counter,
                      trello_name: NAMES[commander][:trello_name],
                      date: Time.now,
                      vacation: vacation_flag,
                      tel_name: NAMES[commander][:tel_name],
                      vacations: vacation_dates}}
    end


    def build_new_hash(commander, counter, vacation_flag, vacation_dates)
      { commander => { times_commander:  counter,
                       trello_name: NAMES[@selected_commander][:trello_name],
                       date: Time.now,
                       vacation: vacation_flag,
                       tel_name: NAMES[@selected_commander][:tel_name],
                       vacations: vacation_dates } }
    end

    def set_vacation_flag(commander, state)
      to_boolean(state)
      puts "Set #{commander} to <on/not on vacation>"
      @vacation_state = { commander => { times_commander: NAMES[commander][:times_commander],
                                         trello_name: NAMES[commander][:trello_name],
                                         date: NAMES[commander][:date],
                                         vacation: @state,
                                         tel_name: NAMES[commander][:tel_name],
                                         vacations: NAMES[commander][:vacations] } }

      @foo = YAML.load_file("#{File.dirname(__FILE__)}/../../config/free.yml")
      @merged_stuff = @foo.merge(@vacation_state)
      write_to_file('free', @merged_stuff.to_yaml)
    end

    # Diry workaround..
    def to_boolean(state)
      (state == 'true') ? @state = true : @state = false
    end

    def proper_vacations(commander)
      a = NAMES[commander][:vacations].map {|x| x.split(' - ') } ## replace later with @vacations
      c = a.map { |x| x.map { |b| Date.parse(b) } }
      c.each do |x|
        set_vacation_flag(commander, 'true') if (x[0]..x[1]).cover?(Date.today)
      end
    end

    # rarely used
    def set_vacation_list(commander)
      write_to_file('free', NAMES.merge(hash_scaffold(commander)).to_yaml)
    end

    def show_status(commander)
      puts "#{commander} was #{NAMES[commander][:times_commander] } times Commanding officer of the week."
      puts "#{commander} is currently on vacation" if NAMES[commander][:vacation]
      NAMES[commander][:vacations].each { |x| puts x}
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
    end

    # Klaus
    def create_vacations(commander)
      @vacations = []
      tn = Net::Telnet.new('Host' => 'present.suse.de', 'Port' => 9874, 'Binmode' => false)
      collect = false
      tn.cmd(NAMES[commander][:tel_name]) do |data|
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
              STDERR.puts "#{dates.size} dates for '(#{NAME[commander][:tel_name]})' #{l}"
          end
        end
      end
      tn.close
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

    def list_all_members
      NAMES.each { |x| puts "-#{x.first}"}
    end


    def find_card
      @card = @trello.find_card_by_id('56') # replace when move to real board
    end

    def find_member
      @trello.find_member_by_username(NAMES[@selected_commander][:trello_name])
    end

    def count_up
      NAMES[@selected_commander][:times_commander] += 1
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
      @comment_string = "#{@selected_commander} is your commanding officer for the next 7 Days."
      @trello.comment_on_card(@comment_string, @card)
    end
  end

end


