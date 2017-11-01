module Tarona
  module Game
    # Inanimate entity which just stands.
    class StaticObject < Tarona::Action::Entity
      attr_reader :name
    end
  end
end
