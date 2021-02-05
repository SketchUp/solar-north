# frozen_string_literal: true

Sketchup.require "su_solarnorth/generic_tool"
Sketchup.require "su_solarnorth/angle_helper"

module Trimble
  module SolarNorth
    # Tool for graphically selecting north direction.
    class NorthTool < GenericTool
      # Radius of compass in logical screen pixels.
      RADIUS = 70

      # Number of segments for circle preview.
      SEGMENTS = 48

      # Points making up approximate circle.
      CIRCLE_POINTS = Array.new(SEGMENTS) do |i|
        angle = Math::PI * 2 / SEGMENTS * i

        [RADIUS * Math.sin(angle), RADIUS * Math.cos(angle)]
      end

      # Identifier for tool state for placing compass.
      PLACE_STATE = 0

      # identifier for tool state for orienting compass.
      ORIENT_STATE = 1

      # @see `GenericTool`
      def self.tool_name
        "Set North"
      end

      # @see `GenericTool`
      def self.tool_description
        "Set north direction."
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def activate
        super

        @compass_position = nil
        @input_point = Sketchup::InputPoint.new
        @reference_input_point = Sketchup::InputPoint.new
        @state = PLACE_STATE

        update_status_text
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def deactivate(view)
        super

        view.invalidate
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def draw(view)
        draw_compass(view, compass_position, compass_direction) if @input_point.valid?
        view.line_width = 1
        draw_line_preview(view) if @state == ORIENT_STATE
        @input_point.draw(view) if @input_point.valid?
        view.tooltip = @input_point.tooltip
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def enableVCB?
        true
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def getExtents
        bounds = Sketchup.active_model.bounds
        bounds.add(@input_point.position) if @input_point.valid?

        if @compass_position
          radius = Sketchup.active_model.active_view
                           .pixels_to_model(RADIUS, @compass_position)
          bounds.add(@compass_position.offset([radius, radius, 0]))
          bounds.add(@compass_position.offset([-radius, -radius, 0]))
        end

        bounds
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onCancel(_reason, view)
        drop_compass
        view.invalidate
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onLButtonDown(_flags, _x, _y, view)
        @state == PLACE_STATE ? place_compass : drop_compass
        view.invalidate
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onMouseMove(_flags, x, y, view)
        @input_point.pick(view, x, y, @reference_input_point)

        if @state == ORIENT_STATE
          vector = @input_point.position - @compass_position
          angle = AngleHelper.planar_angle(Y_AXIS, vector).radians

          # Round the angle to whole degrees if the position is coming from
          # empty space. The user probably prefers 47 degrees over
          # 46.67898335356 degrees.
          # If the position is coming from geometry, chances are the user
          # wants to accurately tweak the model geo location.
          angle = angle.round if @input_point.degrees_of_freedom == 3

          Sketchup.active_model.shadow_info["NorthAngle"] = angle
          update_vcb_value
        end

        view.invalidate
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onUserText(text, view)
        angle = AngleHelper.parse_angle(text)
        view.model.shadow_info["NorthAngle"] = angle.radians
        drop_compass
        view.invalidate
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def resume(_view)
        update_status_text
      end

      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def suspend(view)
        view.invalidate
        update_status_text
      end

      private

      # Update status text and measurement label.
      def update_status_text
        # TODO: Support translations.

        Sketchup.status_text =
            if @state == PLACE_STATE
              "Select north reference point."
            else
              "Select north direction."
            end

        Sketchup.vcb_label = "Angle"
        update_vcb_value
      end

      # Update measurement bar value.
      def update_vcb_value
        angle = Sketchup.active_model.shadow_info["NorthAngle"].degrees
        Sketchup.vcb_value = AngleHelper.format_angle(angle)
      end

      # Place compass and enter orient mode.
      def place_compass
        @state = ORIENT_STATE
        @compass_position = @input_point.position
        @reference_input_point.copy!(@input_point)

        update_status_text
      end

      # Drop compass and go back to previous tool.
      def drop_compass
        # In the majority of SketchUp tools, you would reset the tool to its
        # initial state here. When you've finished drawing one rectangle, you
        # can draw a second and a third rectangle.
        #
        # Solar North tool is however an exception to the general rule.
        # You typically set the north angle once and then continue drawing
        # with your previous tool. Solar North tool also performs live updates
        # to the north angle as it is used, and you don't click until you are
        # happy with the north direction.

        # This is the code you'd use in a typical extension.
        ### @state = PLACE_STATE
        ### @reference_input_point.clear
        ### update_status_text

        Sketchup.active_model.tools.pop_tool
      end

      # Draw the compass symbol.
      #
      # @param view [Sketchup::View]
      # @param position [Geom::Point3d]
      # @param direction [Geom::vector3d]
      def draw_compass(view, position, direction)
        t12n = compass_transformation(view, position, direction)

        view.draw(GL_LINE_LOOP, CIRCLE_POINTS.map { |pt| pt.transform(t12n) })
        view.draw(GL_LINES, [[-RADIUS, 0, 0], [RADIUS, 0, 0]].map { |pt| pt.transform(t12n) })
        view.draw(GL_LINES, [[0, -RADIUS, 0], [0, 0, 0]].map { |pt| pt.transform(t12n) })
        view.line_width = 3
        view.draw(GL_LINES, [[0, RADIUS, 0], [0, 0, 0]].map { |pt| pt.transform(t12n) })
      end

      # Draw line between compass and mouse position.
      def draw_line_preview(view)
        plane = [@compass_position, Z_AXIS]
        projected = @input_point.position.project_to_plane(plane)

        # Copying visual style from Rotate tool.
        view.set_color_from_line(projected, @compass_position)
        view.line_stipple = "_"
        view.draw(GL_LINES, [@compass_position, projected])

        view.line_stipple = "-"
        view.drawing_color = "gray"
        view.draw(GL_LINES, [@input_point.position, projected])
      end

      # Get transformation from logical pixels to model space.
      #
      # @param view [Sketchup::View]
      # @param position [Geom::Point3d]
      # @param direction [Geom::Vector3d]
      #
      # @return [Geom::Transformation]
      def compass_transformation(view, position, direction)
        # Make compass always have same size on screen so the tool feels and looks
        # the same, regardless of whether we model a city or an outhouse.
        # Translate size from logical screen pixels to 3d space length units.
        scale = view.pixels_to_model(1, position)

        Geom::Transformation.new(position) *
          Geom::Transformation.axes(ORIGIN, direction.axes[0], direction) *
          Geom::Transformation.scaling(ORIGIN, scale)
      end

      # Get position to draw compass at.
      #
      # @return [Geom::Point3d]
      def compass_position
        return @compass_position if @state == ORIENT_STATE

        @input_point.position
      end

      # Get direction to draw compass with.
      #
      # @return [Geom::Vector3d]
      def compass_direction
        angle = Sketchup.active_model.shadow_info["NorthAngle"].degrees
        rotation = Geom::Transformation.rotation(ORIGIN, Z_AXIS, -angle)

        Y_AXIS.transform(rotation)
      end
    end
  end
end
