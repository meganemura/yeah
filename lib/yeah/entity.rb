# Game object.
class Yeah::Entity
  # @!attribute position
  #   @return [Vector] position within a game
  # @!attribute size
  #   @return [NilClass|Vector] visual size
  # @!attribute state
  #   @return [Symbol] state in game
  # @!attribute visual
  #   @return [Visual] visual representation within a game
  # @!attribute game
  #   @return [Game] game to which this belongs to
  attr_accessor :position, :state, :visual
  attr_reader :game
  attr_writer :size

  def initialize(position=V[])
    @position = position
  end

  class << self
    def define_position_helpers
      %w(x y z).each_with_index do |coord, i|
        define_method(coord) { @position[i] }
        define_method("#{coord}=") { |val| @position[i] = val }
      end
    end
  end

  def size
    @size || visual && visual.size
  end

  def game=(value)
    @game = value
    @game.entities << self unless @game.entities.include? self
  end

  # @!attribute x
  #   @return [Vector] position.x
  # @!attribute y
  #   @return [Vector] position.y
  # @!attribute z
  #   @return [Vector] position.z
  define_position_helpers

  # Update entity.
  def update
  end

  # Get visual representation from visual.
  #   @return [Surface] visual representation
  def draw
    visual.draw if visual
  end

  def pressing?(pressable)
    game.pressing? pressable
  end

  def control(attrName, input, value)
    if input.class == Array
      polarity = 0
      polarity += 1 if game.platform.pressing?(input.first)
      polarity -= 1 if game.platform.pressing?(input.last)
    else
      polarity = game.platform.pressing?(input) ? 1 : -1
    end

    self.instance_eval("#{attrName} += #{value} * #{polarity}")
  end

  # X of right edge.
  #   @return [Integer]
  def right
    return if size.nil?
    position.x + size.x
  end

  # X of left edge.
  #   @return [Integer]
  def left
    return if size.nil?
    position.x
  end

  # Y of top edge.
  #   @return [Integer]
  def top
    return if size.nil?
    position.y + size.y
  end

  # Y of bottom edge.
  #   @return [Integer]
  def bottom
    return if size.nil?
    position.y
  end

  # Coordinate of center.
  #   @return [Vector]
  def center
    return if size.nil?
    position + size / 2
  end

  def touching?(other)
    return false if !size || !other.size

    not_touching_x = left > other.right || right < other.left
    not_touching_y = bottom > other.top || top < other.bottom

    !(not_touching_x || not_touching_y)
  end
end
