# Copyright 2013, Trimble Navigation Limited

# This software is provided as an example of using the Ruby interface
# to SketchUp.

# Permission to use, copy, modify, and distribute this software for 
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.

# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# Initializer for Solar North Extension.

require 'sketchup.rb'
require 'extensions.rb'
require 'langhandler.rb'

module Sketchup::SolarNorth

# Put translation object where the extension can find it.
$sn_strings = LanguageHandler.new("solarnorth.strings")

# Load the extension.
sn_extension = SketchupExtension.new($sn_strings.GetString(
  "Solar North Toolbar"), "su_solarnorth/solarnorth_loader.rb")

sn_extension.description = $sn_strings.GetString(
  "Provides a toolbar for displaying and " +
  "altering solar north in the model. Useful for customized shadow " +
  "studies.")
sn_extension.version = "1.2.0"
sn_extension.creator = "SketchUp"
sn_extension.copyright = "2016, Trimble Inc."

# Register the extension with Sketchup.
Sketchup.register_extension sn_extension, true

end # module Sketchup::SolarNorth
