module Tarona
  # It is extended tardvig's act.
  #
  # Events:
  # * `end` - you must trigger it when the act execution is ended. Argument: the identificator of the next act
  class Act < Tardvig::Act
    include Tardvig::Events
  end
end