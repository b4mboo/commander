require 'spec_helper'

describe Commander::Vacations do

  subject { Commander::Vacations }

  describe '.find_vacations' do

    it 'parses out vacations from tel' do
        subject.find_vacations('jschmid')
    end
  end
end