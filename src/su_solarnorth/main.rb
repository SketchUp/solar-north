# frozen_string_literal: true

Sketchup.require "su_solarnorth/north_tool"
Sketchup.require "su_solarnorth/ui_helper"

module Trimble
  module SolarNorth
    # Reload extension.
    #
    # @param clear_console [Boolean] Whether console should be cleared.
    # @param undo [Boolean] Whether last oration should be undone.
    #
    # @return [void]
    def self.reload(clear_console = true, undo = false)
      # Hide warnings for already defined constants.
      verbose = $VERBOSE
      $VERBOSE = nil
      Dir.glob(File.join(EXTENSION_ROOT, "**/*.rb")).each { |f| load(f) }
      $VERBOSE = verbose

      # Use a timer to make call to method itself register to console.
      # Otherwise the user cannot use up arrow to repeat command.
      UI.start_timer(0) { SKETCHUP_CONSOLE.clear } if clear_console

      Sketchup.undo if undo

      nil
    end

    # TODO: Translate strings.

    unless @loaded
      @loaded = true

      display_command = UI::Command.new("Toggle North Angle") do
        shadow_info = Sketchup.active_model.shadow_info
        shadow_info["DisplayNorth"] = !shadow_info["DisplayNorth"]
      end
      display_command.set_validation_proc do
        # Cater for no model open on Mac.
        next MF_UNCHECKED unless Sketchup.active_model

        shadow_info = Sketchup.active_model.shadow_info

        shadow_info["DisplayNorth"] ? MF_CHECKED : MF_UNCHECKED
      end
      display_command.tooltip = "Display North"
      display_command.status_bar_text = "Display north direction."
      UIHelper.set_icons(display_command, "#{EXTENSION_ROOT}/icons/north_display")

      toolbar = UI::Toolbar.new("Solar North")
      toolbar.add_item(display_command)
      toolbar.add_item(NorthTool.command)
      toolbar.restore

      menu = UI.menu("Plugins").add_submenu("Solar North")
      menu.add_item(display_command)
      menu.add_item(NorthTool.command)
    end
  end
end
