require 'term/ansicolor'

class TrelloGithub
  module Formatters
    class Terminal
      include Term::ANSIColor

      def to_selection_list(collection)
        to_list(collection).lines.map.with_index do |el, i|
          "[#{i.to_s.rjust(2, ' ')}] #{el}"
        end.join
      end

      def to_list(collection)
        collection.map { |el| "- #{bold(el.name)} (#{el.id})" }.join("\n")
      end
    end
  end
end
