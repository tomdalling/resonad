module Resonad
  class NonExistantError < StandardError; end
  class NonExistantValue < StandardError; end

  def self.Success(*args)
    Success.new(*args)
  end

  def self.Failure(*args)
    Failure.new(*args)
  end

  class Success
    attr_accessor :value

    def initialize(value)
      @value = value
      freeze
    end

    def success?
      true
    end

    def failure?
      false
    end

    def on_success
      yield value
      self
    end

    def on_failure
      self
    end

    def error
      raise NonExistantError, "Success resonads do not have errors"
    end

    def map
      new_value = yield(@value)
      if new_value.__id__ == @value.__id__
        self
      else
        self.class.new(new_value)
      end
    end

    def flat_map
      yield(@value)
    end
    alias_method :and_then, :flat_map
  end

  class Failure
    attr_accessor :error

    def initialize(error)
      @error = error
      freeze
    end

    def success?
      false
    end

    def failure?
      true
    end

    def on_success
      self
    end

    def on_failure
      yield error
      self
    end

    def value
      raise NonExistantValue, "Failure resonads do no have values"
    end

    def map
      self
    end

    def flat_map
      self
    end
    alias_method :and_then, :flat_map
  end

end
