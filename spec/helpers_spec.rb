require 'spec_helper'

describe Commander::Helpers do

  subject { Commander::Helpers }

  describe '.to_boolean' do

    it 'converts string to bool' do
      expect(subject.to_boolean('true')).to eq true
    end
  end
end