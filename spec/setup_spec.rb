require 'spec_helper'

describe Commander::Setup do

  subject { Commander::Setup }

  describe '.get_user_input' do

    it 'gets user input' do
      expect($stdin).to receive_message_chain(:gets, :chomp)
      subject.get_user_input
    end


  end

  describe '.pick_cron_day' do

    it 'translates literal day names into integers' do
      expect_user_input 'Tuesday'
      expect(subject.pick_cron_day).to eq(2)
    end

    it 'expects valid weekdays' do
      expect_user_input 'Invalid'
      expect(subject).to receive(:puts).with(include 'Not a valid weekday')
      expect(subject).to receive(:puts).with(include 'Valid options are')
      expect(subject.pick_cron_day).to be_nil
    end

    it 'translates "Sunday" into the integer 0' do
      expect_user_input 'Sunday'
      expect(subject.pick_cron_day).to eq(0)
    end

    it 'translates "Saturday" into the integer 6' do
      expect_user_input 'Saturday'
      expect(subject.pick_cron_day).to eq(6)
    end

  end

end
