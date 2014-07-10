require 'spec_helper'


describe Commander::Client do

  subject { Commander::Client }

  describe '.new' do

    let(:cli) { subject.new(%w{-f name}) }

    it 'should run with default settings' do
      expect($stdout).to receive(:print).with('Forcing...')
      cli.execute!
    end

    it 'should print verbose output' do
      expect($stdout).to receive(:print).with('Setting specified user as <on vacation>')
      cli.execute!
    end
  end
end