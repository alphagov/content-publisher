# frozen_string_literal: true

module AccessibleAutocompleteHelper
  def accessible_autocomplete_select(option, for_id:, value:)
    # accessible autocomplete replaces a select element with an input
    autocomplete_input = find("input##{for_id}")
    autocomplete_input.fill_in(with: option)

    # select the option
    parent_node = autocomplete_input.find(:xpath, "..")
    parent_node.first(".autocomplete__option").click

    # wait until option is selected
    within("##{for_id}-select", visible: false) do
      find(%{option[value="#{value}"]:checked}, visible: false)
    end
  end
end
