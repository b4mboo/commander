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

end
