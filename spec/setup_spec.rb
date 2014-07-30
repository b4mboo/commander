# require 'spec_helper'
#
# describe Commander::Setup do
#
#   subject { Commander::Setup }
#
#   describe '.get_user_input' do
#
#     it 'gets user input' do
#       expect($stdin).to receive_message_chain(:gets, :chomp)
#       subject.get_user_input
#     end
#
#
#   end
#
#   describe '.configure' do
#
#     it 'prompts lots of text' do
#       expect(STDOUT).to receive(:puts).with(String)
#       # expect(STDIN).to receive(:gets)
#       # expect(subject.configure).to receive(:get_user_input).and_return true
#       # subject.configure
#     end
#
#   end
# end
