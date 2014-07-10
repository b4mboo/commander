require 'spec_helper'


describe Commander::Client do

  subject { Commander::Client }

  describe '.new' do

    let(:cli) { subject.new(%w{-f name}) }

    it 'should run with default settings' do
      Runner.any_instance.stub(:run).and_return true
      cli.execute!
    end

  end
end