module Tarona
  module Game
    # Represents an action which can harm (reduce HP of) an entity.
    # @!attribute [r] damage
    #   @deprecated It will be removed as soon as advanced damage system is
    #     created.
    #   @return [Integer] how much damage does this attack cause.
    # @!attribute [r] visual_effect
    #   @return [Symbol,nil] (optional) which visual effect will be shown
    #     after this attack.
    class Attack < Interaction
      attr_reader :visual_effect

      def initialize(options = {})
        default_options = {
          damage: 1,
          visual_effect: nil
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
        show_effect session, entity, io if visual_effect
        true
      end

      private

      def show_effect(session, entity, io)
        from = session[:act_inf][:entities_index][owner.id]
        to = session[:act_inf][:entities_index][entity.id]
        ViewScripts.show_effect io, visual_effect, from: from, to: to
      end
    end
  end
end
