# frozen_string_literal: true

module Trimble
  module SolarNorth
    # Helper methods for angles.
    module AngleHelper
      # Calculate counter-clockwise angle from vector2 to vector1, as seen from normal.
      #
      # @param vector1 [Geom::Vector3d]
      # @param vector2 [Geom::Vector3d]
      # @param normal [Geom::Vector3d]
      #
      # @return [Numeric] Angle in radians between -pi and pi.
      def self.planar_angle(vector1, vector2, normal = Z_AXIS)
        Math.atan2((vector2 * vector1) % normal, vector1 % vector2)
      end

      # Format angle with correct decimal sign and precision for this model
      # and system.
      #
      # @param angle [Numeric] Angle in radians.
      #
      # @return [String]
      def self.format_angle(angle)
        positive_angle = angle % (2 * Math::PI)

        # Sketchup.format_angle uses the model's angle precision and the
        # local decimal separator (, or .).
        Sketchup.format_angle(positive_angle)
      end

      # Parse angle from text.
      #
      # @param text [String]
      #
      # @return [Numeric] Angle in radians.
      def self.parse_angle(text)
        # In continental Europe, South America and other places,
        # a comma is used as decimal sign.
        text.tr(",", ".").to_f.degrees
      end
    end
  end
end
