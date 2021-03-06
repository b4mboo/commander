require 'trello'


class Trello::Card
  # Monkeypatching..
  def assignees
    @trello = Commander::TrelloConnection.new
    member_ids.map{|id| @trello.find_member_by_id(id)}
  end
end


module Commander
  # Trello Module
  class TrelloConnection

    attr_accessor :board

    # Loads the Configuration for Trello Auth
    def initialize
      configure_trello
    end

    # Adds a member to a certain card
    def add_commander_to_card(commander, card)
      card.add_member(commander) if commander
    end

    # Comments on a certain card
    def comment_on_card(commander, card)
      card.add_comment(commander) if commander
    end

    # Finds a member by its username
    def find_member_by_username(username)
      @board.members.find { |m| m.username == username }
    end

    # Lists all members who are assigned on a certain card
    def list_of_assigned_members(card)
      card.assignees.map(&:username)
    end

    # Finds a member by its id
    def find_member_by_id(id)
      @board.members.find { |m| m.id == id }
    end

    # Finds a card by its id
    def find_card_by_id(id)
      @board.cards.find{|c| c.short_id == id.to_i}
    end

    # Configures Trello
    def configure_trello
      Trello.configure do |config|
        config.developer_public_key = Commander::CONFIG['consumerkey']
        config.member_token = Commander::CONFIG['oauthtoken']
      end
      @board = Trello::Board.find(Commander::CONFIG['board_id'])
    end
  end
end
