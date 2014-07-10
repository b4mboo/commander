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

    def set_commander
      import
      find_card
      update_vacations
      select_commander if @options[:auto]
      # comment_on_card
      # delete_assigned_members
      # add_member_to_card
      write_to_file('free', (@forced).to_yaml) if @options[:force]
      # set new hash for chosen TODO
      puts "Chose: #{@selected_commander}" # debug
    end

    # Should update all vacations
    def update_vacations
      NAMES.keys.each do |x|
        create_vacations(x)
        proper_vacations(x) unless @vacations.empty? #for real run
      end
    end

    # merge will cause old data to remain.. delete and build new
    def delete_old_hash(commander)
      NAMES.delete(commander)
    end

    def set_vacation_flag(commander, state)
      to_boolean(state)
      puts "Set #{commander} to <on/not on vacation>"
      @vacation_state = { commander => { times_commander: NAMES[commander][:times_commander],
                                         trello_name: NAMES[commander][:trello_name],
                                         date: NAMES[commander][:date],
                                         vacation: @state,
                                         tel_name: NAMES[commander][:tel_name],
                                         vacations: @vacations } } # for real run

      # have to delete the old hash and rebuild it from scratch because merge sucks
      @foo = load_new_yaml
      @foo.delete(commander)
      @merged_stuff = @foo.merge(@vacation_state)
      write_to_file('free', @merged_stuff.to_yaml)
    end

    #needed for reload, to get latest filedata
    def load_new_yaml
      YAML.load_file("#{File.dirname(__FILE__)}/../../config/free.yml")
    end

    # Diry workaround..
    def to_boolean(state)
      (state == 'true') ? @state = true : @state = false
    end

    def proper_vacations(commander)
      a = @vacations.map {|x| x.split(' - ') }
      c = a.map { |x| x.map { |b| Date.parse(b) } }
      c.each do |x|
        # Unfortunately writes only if @vacation matches.. should write @vacation to file
        set_vacation_flag(commander, 'true') if (x[0]..x[1]).cover?(Date.today)
      end
    end



    # Klaus refactor later
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

    def build_new_hash(commander, counter, vacation_flag, vacation_dates)
      { commander => { times_commander:  counter,
                       trello_name: NAMES[@selected_commander][:trello_name],
                       date: Time.now,
                       vacation: vacation_flag,
                       tel_name: NAMES[@selected_commander][:tel_name],
                       vacations: vacation_dates } }
    end

    def select_commander
      # sorting logic
      new = load_new_yaml
      @selected_commander = Hash[new.select { |_, v| !v[:vacation] }].sort_by{ |_, v| v[:times_commander] }
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

    def show_status(commander)
      puts "#{commander} was #{NAMES[commander][:times_commander] } times Commanding officer of the week."
      puts "#{commander} is currently on vacation" if NAMES[commander][:vacation]
      NAMES[commander][:vacations].each { |x| puts x}
    end

    def forced
      @forced = build_new_hash(@selected_commander, count_up, false, @vacations) if @options[:force]#replace with @vacations [debugging]
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


