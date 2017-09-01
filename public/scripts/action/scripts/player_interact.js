/**
 * Script for Action.Generator which handles interaction request from player.
 * It means that it decides what does player want to do when he presses right
 * mouse button (by default) and does it.
 *
 * @see Action.Generator
 */
function PlayerInteract(env, data, essence) {
  var self = this;
  this._init = function() {
    env.keybindings.bind(
      essence.field, 'interact:press', self._handleInteraction);
  };

  var self = this;
  this._handleInteraction = function(ev) {
    var hoveredHex = essence.hovered_hex, focused = essence.focused;
    if (focused && focused.id) {
      var targetEntityId = ev.target.getAttribute('data-entity_id');
      var targetEntity = essence.entities[targetEntityId];
      if (targetEntityId == focused.id) return;
      if (targetEntity)
        PlayerInteract.EntityInteraction(env, data, focused, targetEntity);
      else if (hoveredHex)
        PlayerInteract.Movement(env, data, focused, hoveredHex);
    }
  };

  this._init();
}

/**
 * Part of the PlayerInteract script which handles situation when player wants
 * his entity to interact with another entity.
 *
 * It asks player which interaction he wants. If everything is fine with the
 * chosen interaction, it sends the `interaction_request` event to server with
 * attributes `from_entity` (id of the player's Entity), `target` (id of the
 * target Entity) and `interaction_id`.
 *
 * @param {object} env - environment variables (see {@link Action.Generator})
 * @param {object} data - information about the action.
 * @param {Action.Entity} initiator - Entity which initiates the interaction.
 * @param {Action.Entity} target - Entity to which the interaction shall be
 *   applied.
 */
PlayerInteract.EntityInteraction = function(env, data, initiator, target) {
  this._request = function(env, initiator, target) {
    var message = this._createAskingPopup(initiator, target);
    if (message) {
      message.on('close', this._sendInteractionRequest);
      // TODO: I do not know how to test it automatically :/
      setTimeout(function() {
        var binding;
        binding = env.keybindings.bind(document, 'interact:press', function() {
          message.close();
          binding.remove();
        });
      }, 0);
      message.show();
    }
  };

  this._sendInteractionRequest = function(formData) {
    var interactionId = (formData ? formData.clicked : null);
    if (interactionId) {
      env.io.happen('interaction_request',
        {
          from_entity: initiator.id,
          target: target.id,
          interaction_id: interactionId
        });
    }
  };

  this._createAskingPopup = function(initiator, target) {
    var interactions = this._available(initiator, target);
     if (!interactions || (Object.keys(interactions).length == 0)) return;
    var stickTo = 'bottom-right';
    var content = this._createChooseForm(interactions);
    var message = new InteractivePopUp(env.area, content,
      { closable: true, stick_to: stickTo });
    return message;
  };

  this._createChooseForm = function(interactions) {
    var content = '<form>';
    _.each(interactions, function(interaction, id) {
      var label = data.subject.i18n[interaction.name];
      if (!label) label = interaction.name
      content +=
        '<button name="' + id + '">' + label + '</button>';
    });
    content += '</form>'
    return content;
  };

  this._available = function(initiator, target) {
    return _.pick(initiator.options.interactions, function(interaction) {
      return (interaction.distance >= Action.HexGrid.distance(
          initiator.coordinates, target.coordinates
        ));
    });
  };

  this._request(env, initiator, target);
};

/**
 * Part of the PlayerInteract script which handles situation when player wants
 * to move his entity.
 *
 * It sends the `move_request` event to server with the `entity_id` and `to`
 * attributes.
 *
 * @param {object} env - environment variables (see {@link Action.Generator})
 * @param {object} data - information about the action.
 * @param {Action.Entity} entity - Entity which shall be moved
 * @param {Action.Coordinates} to - target place of the movement.
 */
PlayerInteract.Movement = function(env, data, entity, to) {
  env.io.happen('move_request',
    { entity_id: entity.id, to: to });
};
