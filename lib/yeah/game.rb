# Manages levels and context.
module Yeah

class Game
  def self.resolution(*value)
    @resolution = value
  end

  def self.level(value)
    @level = value
  end

  def initialize(context = NullContext.new, data = {})
    @context = context
    @data = data

    class_resolution = self.class.instance_variable_get(:@resolution)
    self.resolution = class_resolution if class_resolution

    class_level = self.class.instance_variable_get(:@level)
    self.level = class_level || Level.new
  end

  # @return [Context]
  attr_reader :context

  def resolution
    @context.resolution
  end
  def resolution=(*value)
    @context.resolution = V[*value]
  end

  attr_accessor :data

  attr_reader :level
  def level=(value)
    if value.respond_to?(:to_sym)
      level_data = data[:levels][value]
      value = Level.new(level_data)
    end

    @level = value
    @level.game = self if level.game != self
  end

  # Start the game.
  def start
    context.each_tick do
      update
      render
      break if @stopped
    end
  end

  # Stop the game.
  def stop
    @stopped = true
  end

  protected

  def update
    level.update
  end

  def render
    context.render(level)
  end
end

end
