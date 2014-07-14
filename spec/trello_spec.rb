require 'spec_helper'

describe Commander::TrelloConnection do

  subject { Commander::TrelloConnection }

  describe '.new' do

  end
  it 'populates board variable with instance of Trello::Board' do
    stub_boards_call
    expect(subject.new.board).to be_kind_of Trello::Board
  end

  it 'sets up trello' do
    allow(Trello::Board).to receive(:find).and_return nil
    config = Commander::CONFIG
    expect_any_instance_of(Trello::Configuration).to receive(:developer_public_key=).with(config['consumerkey']).and_call_original
    subject.new
  end

  it 'sets up trello' do
    allow(Trello::Board).to receive(:find).and_return nil
    config = Commander::CONFIG
    expect_any_instance_of(Trello::Configuration).to receive(:member_token=).with(config['oauthtoken']).and_call_original
    subject.new
  end

  describe '#find_member_by_id' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:configure_trello).and_return true
      allow(subject).to receive(:find_member_by_id).and_return :id
    end

    it 'finds the right member based on the trello id and returns a trello member object' do
      board = double('board')
      trello_connection.board = board
      expect(board).to receive_message_chain(:members, :find)
      trello_connection.send(:find_member_by_id, 42)
    end
  end

  describe '#find_member_by_username' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:configure_trello).and_return true
      allow(subject).to receive(:find_member_by_username).and_return :username
    end

    it 'finds a member based on a username and returns a trello member object' do
      board = double('board')
      trello_connection.board = board
      expect(board).to receive_message_chain(:members, :find)
      trello_connection.send(:find_member_by_username, 'art')
    end
  end

  describe '#comment_on_card' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:configure_trello).and_return true
    end

    it 'comments on the assigned trello card ' do
      card = double('card')
      allow(card).to receive(:add_comment).with('username').and_return true
      expect(trello_connection.comment_on_card('username', card)).to eq true
    end
  end

  describe '#add_commander_to_card' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:configure_trello).and_return true
    end

    it 'adds the valid member to the trello card and comments it' do
      card = double('card')
      allow(card).to receive(:add_member).and_return true
      expect(trello_connection.add_commander_to_card('asd', card)).to eq true
    end
  end

  describe '#remove_member_to_card' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:configure_trello).and_return true
    end

    it 'removes a member from trello card' do
      card = double('card')
      allow(card).to receive(:remove_member_from_card).and_return true
      expect(trello_connection.remove_member_from_card('asd', card)).to eq true
    end
  end

  describe '#list_of_assigned_members' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:configure_trello).and_return true
    end

    it 'list all the assigned members of the specified card ' do
      card = double('card')
      expect(card).to receive_message_chain(:assignees, :map)
      trello_connection.list_of_assigned_members(card)
    end
  end

  describe '#find_member_by_id(id)' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:configure_trello).and_return true
      allow(subject).to receive(:find_card_by_id).and_return :id
    end

    it 'finds the right card based on the trello id' do
      board = double('board')
      trello_connection.board = board
      expect(board).to receive_message_chain(:cards, :find)
      trello_connection.send(:find_card_by_id, 42)
    end
  end

end
