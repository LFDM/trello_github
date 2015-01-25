require 'json'
require 'fileutils'
require 'trello'
require 'trello_github/git_actions'
require 'trello_github/conf_keys'

class TrelloGithub
  class Config
    include GitActions

    def initialize(thor)
      @thor = thor
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

    def set_tokens
      get_tokens(true)
    end

    def configure_api
      dev_key =      get(ConfKeys.public_key)
      member_token = get(ConfKeys.member_token)

      unless dev_key && member_token
        dev_key, member_token = get_tokens
      end

      Trello.configure do |c|
        c.developer_public_key = dev_key
        c.member_token = member_token
      end
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

    TOKEN_VARS = {
      dev: {
        str: 'Trello API Key',
        conf_key: ConfKeys.public_key
      },
      member: {
        str: 'Trello Member Token',
        conf_key: ConfKeys.member_token
      }
    }

    def get_tokens(force_update = false)
      tokens = TOKEN_VARS.each_with_object({}) do |(k, obj), hsh|
        hsh[k] = get_token(obj, force_update)
      end

      dev_key      = set(ConfKeys.public_key, tokens[:dev])
      member_token = set(ConfKeys.member_token, tokens[:member])
      [dev_key, member_token]
    end

    def get_token(settings, update_tokens = false)
      str = settings[:str]
      current = get(settings[:conf_key])
      if current
        return current unless update_tokens
        @thor.say("Your current #{str} is\n\t#{current}")
        if @thor.yes?('Do you want to update it? [y]')
          ask_for_token(str)
        else
          current
        end
      else
        ask_for_token(str)
      end
    end

    def ask_for_token(name)
      @thor.ask("Enter your #{name}:")
    end
  end
end
