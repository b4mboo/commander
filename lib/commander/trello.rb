module Commander
  # Trello Module
  class TrelloConnection

    attr_accessor :board

    def initialize
      configure
    end

    def add_reviewer_to_card(commander, card)
      card.add_member(commander) if commander
    end

    def comment_on_card(commander, card)
      card.add_comment(commander) if commander
    end

    def find_member_by_username(username)
      @board.members.find { |m| m.username == username }
    end

    def find_member_by_id(id)
      @board.members.find { |m| m.id == id }
    end

    def configure
      Trello.configure do |config|
        config.developer_public_key = Commander::CONFIG['consumerkey']
        config.member_token = Commander::CONFIG['oauthtoken']
      end
      @board = Trello::Board.find(Commander::CONFIG['board_id'])
    end
  end
end
