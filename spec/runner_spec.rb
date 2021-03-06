require 'spec_helper'
require 'fileutils'

describe Commander::Runner do

  let( :vacations) { File.read(File.join(File.dirname(__FILE__), 'fixtures/vacations.txt')) }
  let( :config) { File.read(File.join(File.dirname(__FILE__), 'fixtures/trello.txt')) }
  let( :users) { File.read(File.join(File.dirname(__FILE__), 'fixtures/users.txt')) }
  subject { Commander::Runner }

  describe '.new' do
    context 'without options' do
      it 'initializes new instance of Commander::Runner' do
        instance = subject.new({})
        expect(instance.users).not_to be nil
        expect(instance.options[:force]).to be_nil
        expect(instance.selected_commander).to be nil
      end
    end

    context 'with options' do
      it 'initializes new instance of Commander::Runner' do
        instance = subject.new({:vacation=>false, :force=>'a_user', :status=>false, :auto=>true, :list=>false})
        expect(instance.options[:force]).to be_a_kind_of String
        expect(instance.users).not_to be nil
        expect(instance.options[:auto]).to be true
        expect(instance.selected_commander).to eq 'a_user'
      end
    end
  end

  describe '#set_commander' do
    subject { Commander::Runner.new({:vacation=>false, :force=>false, :status=>false, :auto=>true, :list=>false}) }

    it 'sets the commander with help of methods' do
      expect(subject).to receive(:import)
      expect(subject).to receive(:find_card)
      expect(subject).to receive(:update_vacations)
      expect(subject).to receive(:select_commander)
      expect(subject).to receive(:manipulate_trello)
      expect(subject).not_to receive(:write_attributes)
      subject.set_commander
    end
  end

  describe '#manipulate_trello' do
    subject { Commander::Runner.new({:vacation=>false, :force=>false, :status=>false, :auto=>true, :list=>false}) }

    it 'holds trello manipulation methods' do
      expect(subject).to receive(:comment_on_card)
      expect(subject).to receive(:delete_assigned_members)
      expect(subject).to receive(:add_member_to_card)
      subject.manipulate_trello
    end
  end

  describe '#set_commander' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>false}) }

    it 'sets the commander with help of methods' do
      expect(subject).to receive(:import)
      expect(subject).to receive(:find_card)
      expect(subject).to receive(:update_vacations)
      expect(subject).not_to receive(:select_commander)
      expect(subject).to receive(:write_attributes)
      expect(subject).to receive(:manipulate_trello)
      subject.set_commander
    end
  end

  describe '#update_vacations' do

    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>false}) }

    let( :vacations) { File.read(File.join(File.dirname(__FILE__), 'fixtures/vacations.txt')) }

    it 'updates vacations from tel' do
      instance_variable_set(:@vacations, vacations)
      allow(Commander::Vacations).to receive(:find_vacations).with(any_args).and_return vacations
      expect(subject).to receive_message_chain(:users, :keys, :each)
      # expect(subject).to receive(:evaluate_vacations)
      subject.update_vacations
    end

    it 'can write to file' do
      expect(subject).to receive(:write_to_file)
      subject.update_vacations
    end
  end

  describe '#set_vacation_flag' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>false}) }

    it 'sets a vacation flag if on vacation' do
      allow(Commander::Helpers).to receive(:to_boolean).and_return 'true'
      subject.set_vacation_flag(subject.users.first.first, 'true')
    end
  end

  describe '#evaulate_vacations' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>false}) }

    it 'evaluates vacation times' do
      allow(subject).to receive(:parse_vacations).and_return [1,2,3,4]
      subject.evaluate_vacations(subject.users.first.first)
    end

  end

  describe '#show_status' do
    subject { Commander::Runner.new({:vacation=>false, :force=>false, :status=>'Joshua', :auto=>false, :list=>false}) }

    it 'prints out the status' do
      expect(STDOUT).to receive(:puts).with("#{subject.options[:status]} was #{subject.users['Joshua'][:times_commander]} times Commanding officer of the week.")
      expect(STDOUT).to_not receive(:puts).with("#{subject.options[:status]} is currently on vacation.")
      subject.show_status(subject.options[:status])
    end

  end

  describe '#wirte_attributes' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'writes standard attributes' do
      instance_variable_set(:@selected_commander, 'test')
      instance_variable_set(:@users, 'test')
      expect(subject.users.first.last[:vacation]).to eq false
      expect(subject.users.first.last[:times_commander]).to be_a_kind_of Integer
      expect(subject.users.first.last[:date]).to be_a_kind_of Time
      expect(subject).to receive(:write_to_file).and_return true
      subject.write_attributes
    end
  end


  describe '#delete_assigned_members' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'delete all remaining members on the trello card' do
      card = Trello::Card.new
      members = Trello::Member.new
      subject.instance_variable_set(:@card, card)
      expect(card).to receive_message_chain(:members, :each) { members }
      subject.delete_assigned_members
    end
  end



  describe '#list_all_members' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'lists all available members' do
      # user = subject.users.first.first
      expect(STDOUT).to receive(:puts).with(String)
      expect(STDOUT).to receive(:puts).with(String)
      expect(STDOUT).to receive(:puts).with(String)
      expect(STDOUT).to receive(:puts).with(String)
      expect(STDOUT).to receive(:puts).with(String)
      expect(STDOUT).to receive(:puts).with(String)
      # how to test 6 times?
      subject.list_all_members
    end
  end

  # describe '#find_card' do
  #   subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }
  #
  #   it 'find the card from trello board' do
  #     card = double('card')
  #     trello = double('trello')
  #     subject.instance_variable_set(:@trello, trello)
  #     allow(subject).to receive(:find_card_by_id).with('5').and_return card
  #     expect(trello).to receive(:find_card_by_id).with('2')
  #     subject.find_card
  #   end
  # end

  describe '#count_up' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'increments the user counter' do
      instance_variable_set(:@selected_commander, 'Joshua')
      count = subject.users[@selected_commander][:times_commander]
      expect(subject.count_up).to eq (count + 1)
    end
  end

  describe '#add_member_to_card' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'adds a member to the specified trello card ' do
      trello = double('trello')
      card =  double('card')
      member = double('member')
      subject.instance_variable_set(:@trello, trello)
      subject.instance_variable_set(:@card, card)
      expect(subject).to receive(:find_member).and_return member
      expect(trello).to receive(:add_commander_to_card).with(member, card)
      subject.add_member_to_card
    end
  end

  describe '#find_member' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'finds the member based on its trello username' do
      trello = double('trello')
      subject.instance_variable_set(:@trello, trello)
      expect(trello).to receive(:find_member_by_username)
      subject.find_member
    end
  end

  describe '#wirte_to_file' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'writes all the stuff to the yaml file' do
      expect(File).to receive(:open).and_return true
      File.open
    end
  end

  describe '#comment_on_card' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'comments on the card' do
      trello = double('trello')
      card = double('card')
      comment_string = '@jschmid is your commanding officer for the next 7 Days.'
      subject.instance_variable_set(:@trello, trello)
      subject.instance_variable_set(:@comment_string, comment_string)
      subject.instance_variable_set(:@card, card)
      expect(trello).to receive(:comment_on_card).with(comment_string, card)
      subject.comment_on_card
    end
  end

  describe '#select_commander' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'selects a commander based on date, count and presence' do
      subject.instance_variable_get(:@selected_commander)
      subject.select_commander
    end
  end

  describe '#import' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'Joshua', :status=>false, :auto=>false, :list=>true}) }

    it 'imports trello config' do
      stub_boards_call
      expect(subject.import).to be_a_kind_of Commander::TrelloConnection
    end
  end

  describe '#select_commander' do
    subject { Commander::Runner.new({:vacation=>false, :force=>false, :status=>false, :auto=>true, :list=>true}) }
      it 'selects the commander based on yamldata' do
      end

  end
end
