require 'json'
require 'fileutils'
require 'trello_github/git_actions'

class TrelloGithub
  class Config
    include GitActions

    def initialize
      @config = read_config
    end

    def get(key)
      keys = key.split('.')
      first = keys.shift
      value = @config[first]
      keys.inject(value) do |val, k|
        val.is_a?(Hash) ?  val[k] : nil
      end
    end

    def set(key, value)
      keys = key.split('.')
      value_key = keys.pop
      obj = keys.inject(@config) do |conf, k|
        conf[k] ||= {}
      end
      obj[value_key] = value
      write_config
      value
    end

    private

    def read_config
      if File.exist?(config_path)
        JSON.parse(File.read(config_path))
      else
        FileUtils.mkdir_p(File.dirname(config_path))
        {}
      end
    end

    def write_config
      File.write(config_path, JSON.pretty_generate(@config))
    end

    def config_path
      @config_path ||= find_config_path
    end

    def find_config_path
      File.join(git_path, 'trello', 'config.json')
    end

  end
end
