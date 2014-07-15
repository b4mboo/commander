require 'spec_helper'

describe Commander::Helpers do

  subject { Commander::Helpers }

  describe '.to_boolean' do

    it 'converts string to bool' do
      expect(subject).to receive(:to_boolean).with(any_args)
      subject.to_boolean
    end
  end
end