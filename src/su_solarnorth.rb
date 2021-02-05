# frozen_string_literal: true

require "extensions.rb"

# SketchUp Team Extensions
module Trimble
  # Solar North Extension
  module SolarNorth
    # Correct for encoding issue in Windows.
    # https://sketchucation.com/forums/viewtopic.php?f=180&t=57017
    path = __FILE__.dup
    path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

    # Identifier for this extension.
    EXTENSION_ID = File.basename(path, ".*")

    # Root directory of this extension.
    EXTENSION_ROOT = File.join(File.dirname(path), EXTENSION_ID)

    # Extension object for this extension.
    EXTENSION = SketchupExtension.new(
        "Solar North",
        File.join(EXTENSION_ROOT, "main")
      )

    EXTENSION.creator     = "Trimble Inc, SketchUp"
    EXTENSION.description =
        "Provides a toolbar for displaying and altering solar north in the model. "\
        "Useful for customized shadow studies"
    EXTENSION.version     = "2.0.0"
    EXTENSION.copyright   = "2020, #{EXTENSION.creator}"
    Sketchup.register_extension(EXTENSION, true)
  end
end
