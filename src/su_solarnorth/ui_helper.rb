# frozen_string_literal: true

Sketchup.require "su_solarnorth/ui_helper"

module Trimble
  module SolarNorth
    # UI related functionality.
    module UIHelper
      # Check whether this SketchUp version support vector icons or not.
      #
      # @return [Boolean]
      def self.support_vector_icons?
        Sketchup.version.to_i > 15
      end

      # Get vector icon file extension supported by SketchUp on this system.
      #
      # Only applies when `.support_vector_icons?` is `true`.
      #
      # @return [String]
      def self.vector_format
        Sketchup.platform == :platform_win ? ".svg" : ".pdf"
      end

      # Attach icons to command.
      #
      # SketchUp supports different file formats on different systems and in
      # different versions. This method helps picking the correct file.
      #
      # @param command [UI::Command]
      # @param basepath [String] Path to file, excluding its file extension.
      #
      # @example
      #   # Following files may be used:
      #   # - 'dir/my_icon.svg' (for Windows)
      #   # - 'dir/my_icon.pdf' (for Mac)
      #   # - 'dir/my_icon.png' (32 x 32 px, for SU 2015 and older)
      #   # - 'dir/my_icon_small.png' (24 x 24 px)
      #   command = UI::Command.new("My action") { p "Do stuff" }
      #   UIHelper.set_icons(command, "dir/my_icon")
      def self.set_icons(command, basepath)
        return set_legacy_icons(command, basepath) unless support_vector_icons?

        path = "#{basepath}#{vector_format}"
        return set_legacy_icons(command, basepath) unless File.exist?(path)

        command.large_icon = command.small_icon = path
      end

      # Private

      def self.set_legacy_icons(command, basepath)
        icon = "#{basepath}.png"
        small_icon = "#{basepath}_small.png"
        command.large_icon = icon
        command.small_icon = File.exist?(small_icon) ? small_icon : icon
      end
      private_class_method :set_legacy_icons
    end
  end
end
