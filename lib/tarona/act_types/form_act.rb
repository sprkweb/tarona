module Tarona
  # This class represents part of a game. It consists of some kind of form,
  # which can contain some fields to input something.
  #
  # To create it, you need to set `subject` (with form markup) and
  # {#handle_input}.
  # Do not overwrite the {#process} method.
  class FormAct < Act
    act_type :form

    def process
      @io.on_first :form_filled do |form_data|
        happen :end, handle_input(form_data)
      end
    end

    # The method is called after user filled the form. You should redefine it.
    # @param input [Hash] form data
    # @return identificator of next act. See {Play#acts}
    def handle_input(input)
    end
  end
end
