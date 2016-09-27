module Tarona
  # It is container class for different useful objects. It is easier to pass
  # these objects to methods when they are in the container. What is more, it
  # also acts as a dependency injection container for some of these tools.
  # @!attribute [r] settings
  #   @return [Tardvig::SavedHash] hash containing user's settings. It is
  #     default settings overwritten with user's settings (it is because user's
  #     settings can be incomplete). You can see names of the settings' files
  #     in the constants of the toolkit.
  # @!attribute [r] i18n
  #   @return [Tardvig::SavedHash] hash containing translations for some phrases
  #     for the current language (it is taken from the settings).
  #     You can see translations inside the /game/i18n directory.
  # @!attribute [r] config
  #   @return [Tardvig::SavedHash] hash containing configuration of this game,
  #     that is some constants which should not be hardcoded, so they are stored
  #     in a separate file.
  class Toolkit < Tardvig::Toolkit
    # @see #settings
    DEFAULT_SETTINGS_PATH = 'game/default_settings.yml'.freeze
    # @see #settings
    SETTINGS_PATH = 'player/settings.yml'.freeze
    # @see #config
    CONFIG_PATH = 'game/config.yml'.freeze

    class << self
      def load_hash(from)
        hash = Tardvig::HashContainer.new
        hash.load from
        yield hash if block_given?
        hash
      end
      private :load_hash
    end

    tool :settings do |_, params|
      load_hash(params[:default_settings] || DEFAULT_SETTINGS_PATH) do |hash|
        if params[:settings] || File.exist?(SETTINGS_PATH)
          hash.load(params[:settings] || SETTINGS_PATH)
        end
      end
    end

    tool :i18n do |tk, params|
      load_hash(params[:i18n] || "game/i18n/#{tk.settings['language']}.yml")
    end

    tool :config do |_, params|
      load_hash(params[:config] || CONFIG_PATH)
    end
  end
end
