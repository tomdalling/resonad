module Resonad
  class NonExistantError < StandardError; end
  class NonExistantValue < StandardError; end

  def self.Success(*args)
    Success.new(*args)
  end

  def self.Failure(*args)
    Failure.new(*args)
  end

  def self.rescuing_from(*exception_classes)
    Success(yield)
  rescue Exception => e
    if exception_classes.empty?
      Failure(e) # rescue from all exceptions
    elsif exception_classes.any? { |klass| e.is_a?(klass) }
      Failure(e) # rescue from specified exception type
    else
      raise # reraise unhandled exception
    end
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
      new_value = yield(value)
      if new_value.__id__ == value.__id__
        self
      else
        self.class.new(new_value)
      end
    end

    def map_error
      self
    end

    def flat_map
      yield value
    end
    alias_method :and_then, :flat_map

    def flat_map_error
      self
    end
    alias_method :or_else, :flat_map_error
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

    def map_error
      new_error = yield(error)
      if new_error.__id__ == error.__id__
        self
      else
        self.class.new(new_error)
      end
    end

    def flat_map
      self
    end
    alias_method :and_then, :flat_map

    def flat_map_error
      yield error
    end
    alias_method :or_else, :flat_map_error
  end

end
