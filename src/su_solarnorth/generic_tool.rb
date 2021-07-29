# frozen_string_literal: true

module Trimble
  module SolarNorth
    # Generic SketchUp tool functionality.
    #
    # Designed to be reusable between tools and extensions.
    #
    # Subclass to use in your own tool.
    # Call `super` in `activate` and `deactivate` for `active?` to function.
    class GenericTool
      @active_tool = nil

      # Activate tool.
      #
      # Call on subclasses of {GenericTool}.
      def self.activate
        # using Tool#push_tool to allow for popping the tool later.
        Sketchup.active_model.tools.push_tool(new)
      end

      # Check if tool is currently active.
      #
      # Call on subclasses of {GenericTool}.
      #
      # @return [Boolean]
      def self.active?
        # In SketchUp 2019 + we could use
        # `Sketchup.active_model.tools.active_tool`. However we need to
        # manually track the active tool to support older SU version.
        active_tool = GenericTool.instance_variable_get(:@active_tool)

        active_tool.is_a?(self)
      end

      # Get command for activating tool.
      #
      # Call on subclasses of {GenericTool}.
      #
      # @return [UI::Command]
      def self.command
        command = UI::Command.new(tool_name) { activate }
        command.tooltip = tool_name
        command.status_bar_text = tool_description
        command.set_validation_proc { active? ? MF_CHECKED : MF_UNCHECKED }
        UIHelper.set_icons(command, tool_icon)

        command
      end

      # Guess tool name.
      #
      # Override in subclass to set a tool name.
      #
      # @return [String]
      def self.tool_name
        # 'name' here being the name of the class.
        # Turn camel case into separate words.
        # Strip trailing "Tool" from name.
        name.split("::").last.gsub(/([A-Z]+)([A-Z][a-z])/, '\1 \2')
            .gsub(/([a-z\d])([A-Z])/, '\1 \2').gsub(/ Tool$/, "")
      end

      # Fallback tool description.
      #
      # Override in subclass to set a tool description.
      #
      # @return [String]
      def self.tool_description
        # Fallback to tool name.
        tool_name
      end

      # Guess tool icon "basepath" (excluding file extension) from class name.
      #
      # Override in subclass to specify a custom icon.
      #
      # @return [String]
      def self.tool_icon
        "#{EXTENSION_ROOT}/icons/#{tool_id}"
      end

      # Guess tool snake case identifier string from class name.
      #
      # Used for tool specific resources like icon and instructor.
      #
      # Override in subclass to specify a custom id.
      def self.tool_id
        # 'name' here being the name of the class.
        # Turn camel case into snake case.
        name.split("::").last.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def activate
        # Track the active Ruby tool.
        GenericTool.instance_variable_set(:@active_tool, self)
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def deactivate(*_args)
        # Track the active Ruby tool.
        GenericTool.instance_variable_set(:@active_tool, nil)
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def getInstructorContentDirectory
        "#{EXTENSION_ROOT}/instructors/#{self.class.tool_id}.html"
      end
    end
  end
end
