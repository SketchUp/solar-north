#!/usr/bin/ruby
#
# Copyright 2012, Trimble Navigation Limited
# License:: All Rights Reserved.
# Original Author:: Scott Lininger
#
# This file provides a toolbar with buttons for altering the "solar north"
# angle in SketchUp 8 and above. Most users never use these features, so
# we removed it from the standard UI. This extension provides a way to get
# at the old functionality if desired.
#
require 'sketchup.rb'
require 'LangHandler.rb'

module Sketchup::SolarNorth

#
# Set up the UI hooks.
#
if (not $sn_loaded)

  # Create our toolbar.
  toolbar = UI::Toolbar.new $sn_strings.GetString("Solar North")
  path = "Plugins/su_solarnorth"

  # If we are not in pro, add a message to our tooltips to explain why the
  # buttons are grayed out.
  pro_only_message = ''
  if !Sketchup.is_pro?
    pro_only_message = ' ' + $sn_strings.GetString("(Pro Only)")
  end

  # Toggle North Arrow command.
  name = $sn_strings.GetString("Toggle North Arrow")
  north_arrow_command = UI::Command.new(name) {
    Sketchup.active_model.shadow_info['DisplayNorth'] =
        !Sketchup.active_model.shadow_info['DisplayNorth']
  }
  cursor_path = Sketchup.find_support_file("northarrow.png", path)
  small_cursor_path = Sketchup.find_support_file("northarrow_small.png", path)
  north_arrow_command.large_icon = cursor_path
  north_arrow_command.small_icon = small_cursor_path
  north_arrow_command.tooltip = name
  north_arrow_command.set_validation_proc {
    if Sketchup.active_model.shadow_info['DisplayNorth']
      MF_CHECKED
    else
      MF_ENABLED
    end
  }
  toolbar.add_item north_arrow_command


  # Create North Tool command.
  name = $sn_strings.GetString("Set North Tool")
  north_tool_command = UI::Command.new(name) {
    Sketchup.send_action('selectNorthTool:')
  }
  cursor_path = Sketchup.find_support_file("northtool.png", path)
  small_cursor_path = Sketchup.find_support_file("northtool_small.png", path)
  north_tool_command.large_icon = cursor_path
  north_tool_command.small_icon = small_cursor_path
  north_tool_command.tooltip = name + pro_only_message
  north_tool_command.set_validation_proc {
    if !Sketchup.is_pro?
      MF_GRAYED
    else
      MF_ENABLED
    end
  }
  toolbar.add_item north_tool_command


  # Create North Tool command.
  name = $sn_strings.GetString("Enter North Angle")
  prompt = $sn_strings.GetString('North Angle (0-360)')
  north_text_command = UI::Command.new(name) {

    # Keep prompting the user until they cancel or enter a good value.
    done = false
    while done != true
      begin
        input = UI.inputbox [prompt + ' '],
            [Sketchup.active_model.shadow_info['NorthAngle']], name
        if (input != false)
          angle = input[0].to_f % 360.0
          Sketchup.active_model.shadow_info['NorthAngle'] = angle
        end
        done = true
      rescue Exception => e
        puts "Solar North Extension Error: #{e.class}: #{e.message}"
        UI.messagebox($sn_strings.GetString(
            "Your input could not be understood. " +
            "Please enter a number between 0 and 360."))
      end
    end

  }
  cursor_path = Sketchup.find_support_file("northtext.png", path)
  small_cursor_path = Sketchup.find_support_file("northtext_small.png", path)
  north_text_command.large_icon = cursor_path
  north_text_command.small_icon = small_cursor_path
  north_text_command.tooltip = name + pro_only_message
  north_text_command.set_validation_proc {
    if !Sketchup.is_pro?
      MF_GRAYED
    else
      MF_ENABLED
    end
  }
  toolbar.add_item north_text_command

  # Show toolbar if it was open when we shutdown.
  toolbar.restore
  # Per bug 2902434, adding a timer call to restore the toolbar. This
  # fixes a toolbar resizing regression on PC as the restore() call
  # does not seem to work as the script is first loading.
  UI.start_timer(0.1, false) {
    toolbar.restore
  }

  $sn_loaded = true
end

end # module Sketchup::SolarNorth
