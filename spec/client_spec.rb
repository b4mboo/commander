require 'spec_helper'


describe Commander::Client do

  describe '#execute' do

    subject { Commander::Client }
    let(:cli) { subject.new(%w{-a}) }

    it 'should run with default settings' do
      expect(cli).to receive(:run).and_return true
      cli.execute!
      # stub
    end
  end


  describe '?extract_options' do
    let(:cli) { subject.new(%w{-a}) }

    it 'sets status options' do
      argv = %w{-s Joshua}
      cli = subject.new(argv)
      expect(cli.options[:status]).to eq 'Joshua'
    end

    it 'sets force options' do
      argv = %w{-f Joshua}
      cli = subject.new(argv)
      expect(cli.options[:force]).to eq 'Joshua'
    end

    it 'sets vacation options' do
      argv = %w{-v Joshua,true}
      cli = subject.new(argv)
      expect(cli.options[:vacation]).to eq ['Joshua', 'true']
    end

    it 'sets list options' do
      argv = %w{-l}
      cli = subject.new(argv)
      expect(cli.options[:list]).to eq true
    end

    it 'sets auto options' do
      argv = %w{-a}
      cli = subject.new(argv)
      expect(cli.options[:auto]).to eq true
    end

    #
    # it 'sets help options' do
    #   argv = %w{-h}
    #   cli = subject.new(argv)
    #   expect(cli.options[:auto]).to eq true
    # end

    # it 'gets version options' do
    #   argv = %w{-u}
    #   cli = subject.new(argv)
    #   expect(cli).to eq options
    # end

  end
end