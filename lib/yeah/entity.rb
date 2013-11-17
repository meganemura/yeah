# Game object.
class Yeah::Entity
  def initialize(position=V[])
    @position = position
  end

  # @!attribute game
  #   @return [Game] game to which this belongs to
  attr_reader :game

  def game=(value)
    @game = value
    @game.entities << self unless @game.entities.include? self
  end

  # @!attribute position
  #   @return [Vector] position within a game
  attr_accessor :position

  # @!attribute size
  #   @return [NilClass|Vector] visual size
  def size
    @size || visual && visual.size || V[]
  end

  attr_writer :size

  # @!attribute state
  #   @return [Symbol] state in game
  attr_accessor :state

  # @!attribute visual
  #   @return [Visual] visual representation within a game
  attr_accessor :visual

  # X of right edge.
  #   @return [Integer]
  def right
    position.x + size.x
  end

  # X of left edge.
  #   @return [Integer]
  def left
    position.x
  end

  # Y of top edge.
  #   @return [Integer]
  def top
    position.y + size.y
  end

  # Y of bottom edge.
  #   @return [Integer]
  def bottom
    position.y
  end

  # Z of front edge.
  #   @return [Integer]
  def front
    position.z + size.z
  end

  # Z of back edge.
  #   @return [Integer]
  def back
    position.z
  end

  # Coordinate of center.
  #   @return [Vector]
  def center
    position + size / 2
  end

  # Is intersected with other entity or entity of subclass?
  #   @return [Boolean]
  def touching?(other)
    return false if other == self

    if other.is_a?(Class)
      if game
        return game.entities.select { |e| e.is_a? other }
                            .any? { |e| touching? e }
      else
        return false
      end
    end

    return false if size == V[] || other.size == V[]

    not_touching_x = left > other.right || right < other.left
    not_touching_y = bottom > other.top || top < other.bottom
    not_touching_z = back > other.front || front < other.back

    !(not_touching_x && not_touching_y && not_touching_z)
  end

  def control(attr_name, input, value)
    if input.class == Array
      polarity = 0
      polarity += 1 if game.platform.pressing?(input.first)
      polarity -= 1 if game.platform.pressing?(input.last)
    else
      polarity = game.platform.pressing?(input) ? 1 : -1
    end

    self.instance_eval("#{attr_name} += #{value} * #{polarity}")
  end

  def pressing?(pressable)
    game.pressing? pressable
  end

  # Update entity.
  def update
  end

  # Get visual representation from visual.
  #   @return [Surface] visual representation
  def draw
    visual.draw if visual
  end

  class << self
    def define_position_helpers
      %w(x y z).each_with_index do |coord, i|
        define_method(coord) { @position[i] }
        define_method("#{coord}=") { |val| @position[i] = val }
      end
    end
  end

  # @!attribute x
  #   @return [Vector] position.x
  # @!attribute y
  #   @return [Vector] position.y
  # @!attribute z
  #   @return [Vector] position.z
  define_position_helpers
end
