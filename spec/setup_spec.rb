require 'spec_helper'

describe Commander::Setup do

  subject { Commander::Setup }

  describe '.get_user_input' do

    it 'gets user input' do
      expect($stdin).to receive_message_chain(:gets, :chomp)
      subject.get_user_input
    end


  end

  describe '.evaluate_cron_syntax_day' do

    it 'translates literal day names into integers' do
      expect(subject.evaluate_cron_syntax_day('Tuesday')).to eq(2)
    end

    it 'expects valid weekdays' do
      expect(subject.evaluate_cron_syntax_day('Fussball')).to be_nil
    end

    it 'translates "Sunday" into the integer 0' do
      expect(subject.evaluate_cron_syntax_day('Sunday')).to eq(0)
    end

    it 'translates "Saturday" into the integer 6' do
      expect(subject.evaluate_cron_syntax_day('Saturday')).to eq(6)
    end

  end

end
