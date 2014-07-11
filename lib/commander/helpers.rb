module Commander

  class Helpers

    # no .to_bool
    def self.to_boolean(state)
      (state == 'true') ? @state = true : @state = false
    end

  end
end