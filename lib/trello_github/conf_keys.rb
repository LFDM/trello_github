class TrelloGithub
  module ConfKeys
    class << self
      def public_key
        'token.developer_public_key'
      end

      def member_token
        'tokens.member_token'
      end
    end
  end
end
