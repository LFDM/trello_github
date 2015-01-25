require 'json'
require 'trello'
require "trello_github/version"
require "trello_github/config"
require 'trello_github/git_actions'

class TrelloGithub
  attr_reader :config
  include GitActions

  def initialize
    @config = Config.new
  end

  private
end
