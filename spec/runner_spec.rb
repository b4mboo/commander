require 'spec_helper'
require 'fileutils'
describe Commander::Runner do

  let( :vacations) { File.read(File.join(File.dirname(__FILE__), 'fixtures/vacations.txt')) }
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

  describe '#run' do

    subject { Commander::Runner.new({:vacation=>false, :force=>'a_user', :status=>false, :auto=>true, :list=>false}) }

    it 'exectutes #set_commander' do
      expect(subject).to receive(:set_commander)
      subject.run
    end
  end

  describe '#set_commander' do
    subject { Commander::Runner.new({:vacation=>false, :force=>false, :status=>false, :auto=>true, :list=>false}) }

    it 'sets the commander with help of methods' do
      expect(subject).to receive(:import)
      expect(subject).to receive(:find_card)
      expect(subject).to receive(:update_vacations)
      expect(subject).to receive(:select_commander)
      expect(subject).not_to receive(:forced)
      expect(subject).to receive(:comment_on_card)
      expect(subject).to receive(:delete_assigned_members)
      expect(subject).to receive(:add_member_to_card)
      subject.set_commander
    end
  end

  describe '#set_commander' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>false}) }

    it 'sets the commander with help of methods' do
      expect(subject).to receive(:import)
      expect(subject).to receive(:find_card)
      expect(subject).to receive(:update_vacations)
      expect(subject).not_to receive(:select_commander)
      expect(subject).to receive(:forced)
      expect(subject).to receive(:comment_on_card)
      expect(subject).to receive(:delete_assigned_members)
      expect(subject).to receive(:add_member_to_card)
      subject.set_commander
    end
  end

  describe '#update_vacations' do

    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>false}) }

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
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>false}) }

    it 'sets a vacation flag if on vacation' do
      allow(Commander::Helpers).to receive(:to_boolean).and_return 'true'
      subject.set_vacation_flag(subject.users.first.first, 'true')
    end
  end

  describe '#evaulate_vacations' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>false}) }

    it 'evaluates vacation times' do
      expect(subject).to receive(:parse_vacation).to_return Array
      subject.evaluate_vacations(subject.users.first.first)
    end

  end

  describe '#show_status' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>true}) }

    it 'prints out the status' do
      expect($stdout).to receive(:puts).with("#{subject.users.first.first} was 3 times Commanding officer of the week.")
      expect($stdout).to_not receive(:puts).with("#{subject.users.first.first} is currently on vacation.")
      subject.show_status(subject.users.first.first)
    end

  end
  
  describe '#wirte_attributes' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>true}) }
    
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

  describe '#forced' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>true}) }

    it 'calls write_attributes if options[:forced]' do
      expect(subject).to receive(:write_attributes)
      subject.forced
    end
  end

  describe '#delete_assigned_members' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>true}) }

    it 'delete all remaining members on the trello card ' do
      trello = double('trello')
      expect(trello).to receive_message_chain(:list_of_assigned_members, :each)
      subject.delete_assigned_members
    end
  end

  describe '#add_member_to_card' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>true}) }

    it 'adds a member to the specified trello card ' do
      @trello = double('trello')
      @card = double('card')
      expect(@trello).to receive(:add_commander_to_card).with(:find_member, @card)
      subject.add_member_to_card
      debugger
    end

  end

  describe '#list_all_members' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>true}) }

    it 'lists all available members' do
      #??
    end
  end

  describe '#find_card' do
    subject { Commander::Runner.new({:vacation=>false, :force=>'name', :status=>false, :auto=>false, :list=>true}) }

    it 'find the card from trello board' do
      card = double('card')
      expect(subject).to receive(:find_card_by_id).with('56').to eq card
    end
  end


  #     Failure/Error: subject.add_member_to_card
  #     NoMethodError:
  #     undefined method `[]' for nil:NilClass
end
