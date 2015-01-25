require 'thor'
require 'json'
require 'term/ansicolor'
require 'trello'
require "trello_github/version"
require "trello_github/cli"
require "trello_github/config"
require 'trello_github/git_actions'
require 'trello_github/formatters/terminal'

class TrelloGithub
  attr_reader :config

  include GitActions
  include Term::ANSIColor

  def initialize(thor: CLI.new, formatter: Formatters::Terminal.new)
    @thor = thor
    @config = Config.new(thor)
    @config.configure_api
    @formatter = formatter
  end

  def start
    cards = todo_cards
    puts @formatter.to_selection_list(cards)
    puts
    i = @thor.ask("Please pick a card: ").to_i
    card = cards[i]
    move_to(:doing, card)
    puts
    puts "You're now working on #{bold(card.name)}`"
  end

  def set_default_board
    boards = Trello::Board.all
    puts "\t#{underline("Select the board to use for this GitHub repository")}"
    puts
    puts @formatter.to_selection_list(boards)

    i = @thor.ask("Enter the board's number:").to_i
    until board = boards[i.to_i]
      i = @thor.ask('Invalid number. Try again:')
    end
    @config.set('board', board.id)
    board
  end

  def set_workflow(board)
    lists = board.lists
    board = Trello::Board.find(board) if board.is_a?(String)
    puts "The #{board.name} board contains the following lists"
    puts
    puts @formatter.to_selection_list(lists)
    puts
    i = @thor.ask("Select the list(s) which should be used to fetch open cards:")
    todo_lists = i.split(',').map { |el| lists[el.to_i] }
    @config.set('lists.to_do', todo_lists.map(&:id))
    puts

    filter = @thor.ask("Do you want to filter these cards by a username? If yes, please enter one:")
    @config.set('filter.user', filter) unless filter.empty?
    puts

    i = @thor.ask("To which list shall the card be moved when you start working:").to_i
    @config.set('lists.doing', lists[i].id)
    puts

    i = @thor.ask("To which list shall the card be moved when you finish working:").to_i
    @config.set('lists.finished', lists[i].id)
  end

  private

  def move_to(list_name, card)
    card.list_id = @config.get("lists.#{list_name}")
    card.save
  end

  def todo_cards
    todo_ids = @config.get('lists.to_do')
    # Cards are in a custom collection that does not behave like an array -
    # we have to trick this a bit
    todo_ids.map { |id| get_list(id).cards }.each_with_object([]) do |cards, arr|
      cards.each { |card| arr << card }
    end
  end

  def get_list(id)
    Trello::List.find(id)
  end
end
