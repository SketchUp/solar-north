# frozen_string_literal: true

Sketchup.require "su_solarnorth/angle_helper"
Sketchup.require "su_solarnorth/ui_helper"

module Trimble
  module SolarNorth
    # Dialog for entering north angle.
    module SolarNorthDialog
      # Get command for showing the dialog.
      #
      # @return [UI::Command]
      def self.command
        # TODO: translate strings.
        command = UI::Command.new("Enter North Angle") { show }
        command.tooltip = "Enter North Angle"
        command.status_bar_text = "Type in a north angle."
        UIHelper.set_icons(command, "#{EXTENSION_ROOT}/icons/north_text")

        command
      end

      # Show dialog for entering north angle.
      def self.show
        # TODO: Translate
        title = "North Angle"
        label = "North angle"

        angle = Sketchup.active_model.shadow_info["NorthAngle"].degrees
        value = AngleHelper.format_angle(angle)

        result = UI.inputbox([label], [value], title)
        return unless result

        # If the user didn't change the value, don't parse it.
        # Parsing would cause precision to be lost if the value is rounded.
        return if result.first == value

        angle = AngleHelper.parse_angle(result.first)
        Sketchup.active_model.shadow_info["NorthAngle"] = angle.radians
      end
    end
  end
end
