module Yeah
module Web
class Display
  attr_reader :text_font, :text_size

  def initialize(options = {})
    canvas_selector = options.fetch(:canvas_selector, DEFAULT_CANVAS_SELECTOR)

    @canvas = `document.querySelectorAll(#{canvas_selector})[0]`
    @context = `#@canvas.getContext('2d')`
    self.size = options.fetch(:size, DEFAULT_DISPLAY_SIZE)
    self.text_font = Font['']
    self.text_size = DEFAULT_DISPLAY_TEXT_SIZE
    @transform = [1, 0, 0, 1, 0, 0]
    @transforms = []
  end

  def size
    V[`#@canvas.width`, `#@canvas.height`]
  end
  def size=(value)
    `#@canvas.width =  #{value.x}`
    `#@canvas.height = #{value.y}`
  end

  def width
    `#@canvas.width`
  end
  def width=(value)
    `#@canvas.width =  #{value}`
  end

  def height
    `#@canvas.height`
  end
  def height=(value)
    `#@canvas.height =  #{value}`
  end

  def fill_color
    C[`#@context.fillStyle`]
  end
  def fill_color=(color)
    `#@context.fillStyle = #{color.to_hex}`
  end

  def stroke_color
    C[`#@context.strokeStyle`]
  end
  def stroke_color=(color)
    `#@context.strokeStyle = #{color.to_hex}`
  end

  def stroke_width
    `#@context.lineWidth`
  end
  def stroke_width=(numeric)
    `#@context.lineWidth = #{numeric}`
  end

  def text_font=(font)
    @text_font = font

    font = "#{@text_size}px \"#{@text_font.path}\""
    `#@context.font = #{font}`
  end

  def text_size=(size)
    @text_size = size

    font = "#{@text_size}px \"#{@text_font.path}\""
    `#@context.font = #{font}`
  end

  def color_at(position)
    data = `#@context.getImageData(#{position.x}, #{position.y}, 1, 1).data`
    C[`data[0]`, `data[1]`, `data[2]`]
  end

  def translate(displacement)
    @transform[4] += `#{@transform[0]} * #{displacement.x} +
                      #{@transform[2]} * #{displacement.y}`
    @transform[5] += `#{@transform[1]} * #{displacement.x} +
                      #{@transform[3]} * #{displacement.y}`

    %x{
      #@context.setTransform(#{@transform[0]}, #{@transform[1]},
                             #{@transform[2]}, #{@transform[3]},
                             #{@transform[4]}, #{@transform[5]}); }
  end

  def translate_x(displacement)
    @transform[4] += `#{@transform[0]} * #{displacement} + #{@transform[2]}`
    @transform[5] += `#{@transform[1]} * #{displacement} + #{@transform[3]}`

    %x{
      #@context.setTransform(#{@transform[0]}, #{@transform[1]},
                             #{@transform[2]}, #{@transform[3]},
                             #{@transform[4]}, #{@transform[5]}); }
  end

  def translate_y(displacement)
    @transform[4] += `#{@transform[0]} + #{@transform[2]} * #{displacement}`
    @transform[5] += `#{@transform[1]} + #{@transform[3]} * #{displacement}`

    %x{
      #@context.setTransform(#{@transform[0]}, #{@transform[1]},
                             #{@transform[2]}, #{@transform[3]},
                             #{@transform[4]}, #{@transform[5]}); }
  end

  def translate_z(displacement)
  end

  def scale(multiplier)
    %x{
      #{@transform} = [#{@transform[0]} * #{multiplier.x},
                       #{@transform[1]} * #{multiplier.x},
                       #{@transform[2]} * #{multiplier.y},
                       #{@transform[3]} * #{multiplier.y},
                       #{@transform[4]}, #{@transform[5]}];

      #@context.setTransform(#{@transform[0]}, #{@transform[1]},
                             #{@transform[2]}, #{@transform[3]},
                             #{@transform[4]}, #{@transform[5]}); }
  end

  def scale_x(multiplier)
    %x{
      #{@transform} = [#{@transform[0]} * #{multiplier},
                       #{@transform[1]} * #{multiplier},
                       #{@transform[2]}, #{@transform[3]},
                       #{@transform[4]}, #{@transform[5]}];

      #@context.setTransform(#{@transform[0]}, #{@transform[1]},
                             #{@transform[2]}, #{@transform[3]},
                             #{@transform[4]}, #{@transform[5]}); }
  end

  def scale_y(multiplier)
    %x{
      #{@transform} = [#{@transform[0]}, #{@transform[1]},
                       #{@transform[2]} * #{multiplier},
                       #{@transform[3]} * #{multiplier},
                       #{@transform[4]}, #{@transform[5]}];

      #@context.setTransform(#{@transform[0]}, #{@transform[1]},
                             #{@transform[2]}, #{@transform[3]},
                             #{@transform[4]}, #{@transform[5]}); }
  end

  def scale_z(multiplier)
  end

  def rotate(radians)
    rotate_z(radians.z)
  end

  def rotate_x(radians)
  end

  def rotate_y(radians)
  end

  def rotate_z(radians)
    %x{
      var cos = Math.cos(#{radians}),
          sin = Math.sin(#{radians}),
          e0 = #{@transform[0]} * cos + #{@transform[2]} * sin,
          e1 = #{@transform[1]} * cos + #{@transform[3]} * sin,
          e2 = #{@transform[0]} * -sin + #{@transform[2]} * cos,
          e3 = #{@transform[1]} * -sin + #{@transform[3]} * cos;

      #@transform = [e0, e1, e2, e3, #{@transform[4]}, #{@transform[5]}];

      #@context.setTransform(#{@transform[0]}, #{@transform[1]},
                             #{@transform[2]}, #{@transform[3]},
                             #{@transform[4]}, #{@transform[5]}); }
  end

  def push
    @transforms.push(@transform.dup)
  end

  def pop
    @transform = @transforms.pop

    %x{
      #@context.setTransform(#{@transform[0]}, #{@transform[1]},
                             #{@transform[2]}, #{@transform[3]},
                             #{@transform[4]}, #{@transform[5]}); }
  end

  def stroke_line(start_pos, end_pos)
    %x{
      #@context.beginPath();
      #@context.moveTo(#{start_pos.x}, #{start_pos.y});
      #@context.lineTo(#{end_pos.x}, #{end_pos.y});
      #@context.closePath();
      #@context.stroke();
    }
  end

  def stroke_curve(start_pos, end_pos, control)
    %x{
      #@context.beginPath();
      #@context.moveTo(#{start_pos.x}, #{start_pos.y});
      #@context.quadraticCurveTo(#{control.x}, #{control.y},
                                 #{end_pos.x}, #{end_pos.y});
      #@context.closePath();
      #@context.stroke();
    }
  end

  def stroke_curve2(start_pos, end_pos, control1, control2)
    %x{
      #@context.beginPath();
      #@context.moveTo(#{start_pos.x}, #{start_pos.y});
      #@context.bezierCurveTo(#{control1.x}, #{control1.y},
                              #{control2.x}, #{control2.y},
                              #{end_pos.x}, #{end_pos.y});
      #@context.closePath();
      #@context.stroke();
    }
  end

  def stroke_rectangle(position, size)
    `#@context.strokeRect(#{position.x}, #{position.y}, #{size.x}, #{size.y})`
  end

  def fill_rectangle(position, size)
    `#@context.fillRect(#{position.x}, #{position.y}, #{size.x}, #{size.y})`
  end

  def stroke_ellipse(center, radius)
    %x{
      #@context.beginPath();
      #@context.save();
      #@context.beginPath();
      #@context.translate(#{center.x} - #{radius.x},
                          #{center.y} - #{radius.y});
      #@context.scale(#{radius.x}, #{radius.y});
      #@context.arc(1, 1, 1, 0, 2 * Math.PI, false);
      #@context.restore();
      #@context.stroke();
    }
  end

  def fill_ellipse(center, radius)
    %x{
      #@context.beginPath();
      #@context.save();
      #@context.beginPath();
      #@context.translate(#{center.x} - #{radius.x},
                          #{center.y} - #{radius.y});
      #@context.scale(#{radius.x}, #{radius.y});
      #@context.arc(1, 1, 1, 0, 2 * Math.PI, false);
      #@context.restore();
      #@context.fill();
    }
  end

  def clear
    `#@context.fillRect(0, 0, #{size.x}, #{size.y})`
  end

  def begin_shape
    `#@context.beginPath()`
  end

  def end_shape
    `#@context.closePath()`
  end

  def move_to(position)
    `#@context.moveTo(#{position.x}, #{position.y})`
  end

  def line_to(position)
    `#@context.lineTo(#{position.x}, #{position.y})`
  end

  def curve_to(position, control)
    `#@context.quadraticCurveTo(#{control.x}, #{control.y},
                                #{position.x}, #{position.y})`
  end

  def curve2_to(position, control1, control2)
    `#@context.bezierCurveTo(#{control1.x}, #{control1.y},
                             #{control2.x}, #{control2.y},
                             #{position.x}, #{position.y})`
  end

  def stroke_shape
    `#@context.stroke()`
  end

  def fill_shape
    `#@context.fill()`
  end

  def image(image, position)
    `#@context.drawImage(#{image.to_n}, #{position.x}, #{position.y})`
  end

  def image_cropped(image, position, crop_position, crop_size)
    %x{#@context.drawImage(#{image.to_n},
                           #{crop_position.x}, #{crop_position.y},
                           #{crop_size.x}, #{crop_size.y},
                           #{position.x}, #{position.y},
                           #{crop_size.x}, #{crop_size.y})}
  end

  def fill_text(text, position)
    `#@context.fillText(#{text}, #{position.x}, #{position.y})`
  end

  def stroke_text(text, position)
    `#@context.strokeText(#{text}, #{position.x}, #{position.y})`
  end
end
end
end
