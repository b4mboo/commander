require 'yaml'
require 'colorize'
require 'fileutils'
module Commander

  class Setup

    attr_accessor :conf
    @conf = YAML.load_file("#{File.join(ENV['HOME'])}/.config/happy-commander/.trello.yml")


    def self.get_user_input
      $stdin.gets.chomp
    end

    def self.configure
      system('clear')
      puts 'Provide your Trello Board ID'.green
      puts 'if you dont know where to find it visit your board '
      puts 'with your browser and check the url '
      puts 'https://trello.com/b/YOURBOARDID/boardname etc..'
      printf '>>'
      @conf['board_id'] = get_user_input
      system('clear')

      puts 'Provide your Trello consumer key'.green
      puts 'you can generate this key on '
      puts 'https://trello.com/1/appKey/generate'
      printf '>>'
      @conf['consumerkey'] = get_user_input
      system('clear')

      puts 'Provide your Trello consumer secret'.green
      puts 'you can generate this key on '
      puts 'https://trello.com/1/appKey/generate'
      printf '>>'
      @conf['consumersecret'] = get_user_input
      system('clear')


      puts 'finally provide the generated token '.green
      puts 'which you can get here'
      puts 'https://trello.com/docs/gettingstarted/index.html#getting-a-token-from-a-user'
      puts 'or'
      puts "https://trello.com/1/authorize?key=#{@conf['consumerkey']}&name=happy-commander&expiration=never&response_type=token&scope=read,write"
      printf '>>'
      @conf['oauthtoken'] = get_user_input
      system('clear')

      puts 'Specify the card id (comments and assignments on this card)'.green
      puts 'see in card description'
      puts 'or in browser url'
      puts "e.g https://trello.com/c/somecard/"+"2075".green+"-commanding-officer-of-the-week"
      puts '                                 card_id'
      printf '>>'
      @conf['card_id'] = get_user_input
      system('clear')


      puts 'Set the interval '.green
      puts 'e.g. for every tuesday'
      puts 'write: tuesday, or weekdays'
      puts 'at what time?'
      puts 'write: 1pm, 10pm, 2pm, 1am and so on..'
      puts 'or: raw cron syntax'
      puts 'like: 0 0 27-31 * *'
      puts ''
      puts 'what syntax will you provide?'
      puts '1. written language'.green
      puts '2. raw cron syntax'.green
      printf '>>'
      choice = get_user_input
      system('clear')
      case choice.to_i
        when 1
          puts 'Chose written language:'
          puts 'e.g. Monday, Tuesday, ...'
          puts '>>'
          pick_cron_day
          puts 'time..'
          puts 'e.g. 11, 21, 24, 8, 3'
          time = get_user_input
          evaluate_cron_syntax_time(time)

        when 2
          puts 'Chose raw cron syntax'
          puts 'e.g. 0 0 27-31 * *'
          printf '>>'
          raw_syn = get_user_input
          system('clear')
          puts 'put this in your cron'
          puts 'edit it with crontab -e'
          puts raw_syn
        else
          exit('provide proper input')
      end

      puts ("#{concat_cron_syntax}      #{%x[which commander].chomp || %x[which commander2.0].chomp} -a").red
      puts 'put this in your cron'
      puts 'edit it with crontab -e'
      write_to_file('.trello', @conf.to_yaml)

    end

    def self.concat_cron_syntax
      "0 #{@hour} 0 0 #{@cron_day}"
    end

    def self.evaluate_cron_syntax_time(time)
      case time
        when '1'
          puts '1 am'
          @hour = 1
        when '2'
          puts '2 am'
          @hour = 2
        when '3'
          puts '3 am'
          @hour = 3
        when '4'
          puts '4 am'
          @hour = 4
        when '5'
          puts '5 am'
          @hour = 5
        when '6'
          puts '6 am'
          @hour = 6
        when '7'
          puts '7 am'
          @hour = 7
        when '8'
          puts '8 am'
          @hour = 8
        when '9'
          puts '9 am'
          @hour = 9
        when '10'
          puts '10 am'
          @hour = 10
        when '11'
          puts '11 am'
          @hour = 11
        when '12'
          puts '12 am'
          @hour = 12
        when '13'
          puts '1 pm'
          @hour = 13
        when '14'
          puts '2 pm'
          @hour = 14
        when '15'
          puts '3 pm'
          @hour = 15
        when '16'
          puts '4 pm'
          @hour = 16
        when '17'
          puts '5 pm'
          @hour = 17
        when '18'
          puts '6 pm'
          @hour = 18
        when '19'
          puts '7 pm'
          @hour = 19
        when '20'
          puts '8 pm'
          @hour = 20
        when '21'
          puts '9 pm'
          @hour = 21
        when '22'
          puts '10 pm'
          @hour = 22
        when '23'
          puts '11 pm'
          @hour = 23
        when '24'
          puts '12 pm'
          @hour = 24
        else
          puts 'typo?'
      end
    end

    class InvalidInputException < Exception

    end

    def self.pick_cron_day
      day = get_user_input
      weekdays = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
      unless weekdays.include?(day)
        raise InvalidInputException, "Not a valid weekday: '#{day}'"
      end
      puts "selected: #{day}"
      @cron_day = weekdays.index(day)
    rescue InvalidInputException => e
      puts e.message
      puts "Valid options are: #{weekdays}"
      retry
    end

    def self.write_to_file(filename, content)
      File.open("#{File.join(Dir.home)}/.config/happy-commander/#{filename}.yml", 'w') do |f|
        f.write(content)
      end
    end

  end
end
