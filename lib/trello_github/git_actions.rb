class TrelloGithub
  module GitActions
    def self.git_path
      @git_path

    end

    def self.git_path=(path)
      @git_path = path
    end

    def git(cmd, *options)
      `git #{cmd} #{options.map{ |o| o.is_a?(Symbol) ? "--#{o}" : o}.join(' ')}`.strip
    end

    def git_path
      GitActions.git_path ||= File.join(git_root, '.git')
    end

    private

    def git_root
      git 'rev-parse', '--show-toplevel'
    end
  end
end
