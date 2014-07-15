require 'spec_helper'

describe Commander::Client do

  subject { Commander::Client }

  before do
    allow_any_instance_of(Commander::Runner).to receive(:set_commander) { true }
  end

  describe '#execute' do
    context 'with auto options' do
      let(:cli) { subject.new(%w{-a}) }

      it 'should run with default settings' do
        expect(Commander::Runner).to receive(:new).with(cli.options).and_return Commander::Runner.new(cli.options)
        expect_any_instance_of(Commander::Runner).to receive(:run)
        cli.execute!
      end
    end

    context 'with force options' do
      let(:cli) { subject.new(%w{-f, name}) }

      it 'should run with force settings' do
        expect(Commander::Runner).to receive(:new).with(cli.options).and_return Commander::Runner.new(cli.options)
        expect_any_instance_of(Commander::Runner).to receive(:run)
        cli.execute!
      end
    end

    context 'with list options' do
      let(:cli) { subject.new(%w{-l}) }

      it 'should run with list settings' do
        expect(Commander::Runner).to receive(:new).with(cli.options).and_return Commander::Runner.new(cli.options)
        expect_any_instance_of(Commander::Runner).to receive(:list_all_members)
        cli.execute!
      end
    end

    context 'with status options' do
      let(:cli) { subject.new(%w{-s, name}) }

      it 'should run with force settings' do
        expect(Commander::Runner).to receive(:new).with(cli.options).and_return Commander::Runner.new(cli.options)
        expect_any_instance_of(Commander::Runner).to receive(:show_status)
        cli.execute!
      end
    end

    context 'with vacation options' do
      let(:cli) { subject.new(%w{-v, name, true}) }

      it 'should run with vacation settings' do
        expect(Commander::Runner).to receive(:new).with(cli.options).and_return Commander::Runner.new(cli.options)
        expect_any_instance_of(Commander::Runner).to receive(:set_vacation_flag)
        cli.execute!
      end
    end

    context 'with no options' do
      let(:cli) { subject.new(%w{}) }

      it 'should exit cleanly when no arg is given' do
        expect_any_instance_of(subject).to receive(:exit)
        cli.execute!
      end
    end
  end

  describe '?extract_options' do
    it 'sets status options' do
      cli = subject.new(%w{-s Joshua})
      expect(cli.options[:status]).to eq 'Joshua'
    end

    it 'sets force options' do
      cli = subject.new(%w{-f Joshua})
      expect(cli.options[:force]).to eq 'Joshua'
    end

    it 'sets vacation options' do
      cli = subject.new(%w{-v Joshua,true})
      expect(cli.options[:vacation]).to eq ['Joshua', 'true']
    end

    it 'sets list options' do
      cli = subject.new(['-l'])
      expect(cli.options[:list]).to eq true
    end

    it 'sets auto options' do
      cli = subject.new(['-a'])
      expect(cli.options[:auto]).to eq true
    end

    it 'sets help options' do
      argv = %w{-h}
      expect_any_instance_of(subject).to receive(:puts)
      expect_any_instance_of(subject).to receive(:exit)
      subject.new(argv)
    end

    it 'gets version options' do
      argv = %w{-u}
      expect_any_instance_of(subject).to receive(:puts).with(Commander::VERSION)
      expect_any_instance_of(subject).to receive(:exit)
      subject.new(argv)
    end
  end
end
