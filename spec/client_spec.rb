require 'spec_helper'


describe Commander::Client do

  subject { Commander::Client }

  describe '.new' do

    let(:cli) { subject.new(argv) }

    it 'should run with default settings' do
      expect($stdout).to receive(:print).with('i will run with default settings')
      cli.execute!
    end

    let(:cli) { subject.new(%w{-v}) }

    it 'should print verbose output' do
      expect($stdout).to receive(:print).with('verbose output')
      cli.execute!
    end
  end
end