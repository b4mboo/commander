# Helper for stubbing
module Helpers
  def self.boards_details
    [{
         id: 'abcdef123456789123456789',
         name: 'Test',
         desc: 'This is a test board',
         closed: false,
         idOrganization: 'abcdef123456789123456789',
         url: 'https://trello.com/board/test/abcdef123456789123456789'
     }]
  end

  def boards_payload
    JSON.generate(boards_details)
  end
end

def stub_boards_call
  trello_config = Commander::CONFIG
  stub_request(:get, "https://api.trello.com/1/boards/UuKxYj6M?key=#{trello_config['consumerkey']}&token=#{trello_config['oauthtoken']}")
  .to_return(status: 200, body:  Helpers.boards_details.first.to_json)
end

