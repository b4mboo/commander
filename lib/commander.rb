# Commanding Officer of the week tool
require 'commander/version'
require 'yaml'
module Commander
  CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../config/.trello.yml")
  # TODO: MHH
  # use opts
  # -f set a co
  # -r randomize
  # -s show -h help
  # --history show history
  # -t toplist+counting
  #
  # post on a trellocard
  # set user on trellocard
  # implement in rails
end
