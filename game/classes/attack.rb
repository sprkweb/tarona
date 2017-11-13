module Tarona
  module Game
    # Represents an action which can harm (reduce HP of) an entity.
    # @!attribute [r] damage
    #   @deprecated It will be removed as soon as advanced damage system is
    #     created.
    #   @return [Integer] how much damage does this attack cause.
    class Attack < Interaction
      def initialize(options = {})
        default_options = {
          damage: 1
        }
        default_options.merge(options).each do |key, val|
          instance_variable_set "@#{key}".to_sym, val
        end
        super options
      end

      # @param session [#[]] information about current game state.
      # @param entity [Tarona::Action::Entity] target of the attack. It must
      #   have the `#hp` attribute available to write and read.
      # @return [TrueClass,FalseClass] whether the attack is applied
      def apply(session, entity, io)
        return false unless applicable?(session, entity)
        entity.hp -= @damage if entity.respond_to?(:hp)
        true
      end
    end
  end
end
