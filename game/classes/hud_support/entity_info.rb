module Tarona
  module Game
    class HudSupport
      # Sends short information about entity when it is requested through
      # `Tardvig::GameIO`
      #
      # It responds to the `entity_info_request` event with attributes: `id`
      # (Entity's identificator).
      # It sends back the `entity_info_show` with some entity's attributes
      # (keys are original names of the attributes).
      #
      # You must set attributes below using `Tardvig::Command` interface to
      # start this command.
      # @!attribute [r] act
      #   @return [Tarona::Action] current act.
      # @!attribute [r] session
      #   @return [#[]] information about current game state.
      # @see Tarona::PrManager
      class EntityInfo < Tarona::PrManager
        # Attributes of Entity which will be send if they exist.
        ATTRIBUTES = [:name, :hp, :max_hp, :energy, :max_energy].freeze

        def job_type
          :entity_info
        end

        def job(msg)
          entity = get_entity msg[:id]
          attrs = attributes(entity)
          @act.io.happen :entity_info_show, attrs unless attrs.empty?
        end

        def get_entity(id)
          map = @session[:act_inf][:landscape]
          index = @session[:act_inf][:entities_index]
          Tarona::Action::PlaceEntity.find map, index, id
        end

        def attributes(entity)
          result = {}
          ATTRIBUTES.each do |attr_name|
            next unless entity.respond_to? attr_name
            result[attr_name] = entity.send attr_name
          end
          result
        end
      end
    end
  end
end
