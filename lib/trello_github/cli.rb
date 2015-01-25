require 'trello_github'
require 'trello_github/conf_keys'
require 'thor'

class TrelloGithub
  class CLI < Thor
    include Thor::Actions

    desc 'setup', 'Sets up your API keys for trello'
    def setup
      trello.config.set_tokens
    end

    desc 'config', 'Configure your GitHub repository to integrate a Trello workflow'
    def config
      board = trello.set_default_board
      puts
      trello.set_workflow(board)
    end

    desc 'start', 'Start a GitHub session'
    def start
      trello.start
    end

    desc 'pause', 'description'
    def pause
      trello.pause
    end

    desc 'continue', 'description'
    def continue
      trello.continue
    end

    desc 'finish', 'description'
    def finish
      trello.finish
    end

    no_commands do
      def trello
        @trello ||= TrelloGithub.new(thor: self)
      end
    end
  end
end
