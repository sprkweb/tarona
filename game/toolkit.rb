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
  class Toolkit < Tardvig::Toolkit
    # @see #settings
    DEFAULT_SETTINGS_PATH = 'player/default_settings.yml'.freeze
    # @see #settings
    SETTINGS_PATH = 'player/settings.yml'.freeze

    tool :settings do |_, params|
      default_settings = params[:default_settings] || DEFAULT_SETTINGS_PATH
      settings = Tardvig::SavedHash.new default_settings
      if params[:settings] || File.exist?(SETTINGS_PATH)
        settings.load(params[:settings] || SETTINGS_PATH)
      end
      settings
    end

    tool :i18n do |_, params|
      i18n_input = params[:i18n] || "game/i18n/#{settings['language']}.yml"
      Tardvig::SavedHash.new i18n_input
    end
  end
end