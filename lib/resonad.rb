class Resonad
  class NonExistentError < StandardError; end
  class NonExistentValue < StandardError; end

  module Mixin
    def Success(*args)
      ::Resonad::Success.new(*args)
    end

    def Failure(*args)
      ::Resonad::Failure.new(*args)
    end
  end
  extend Mixin

  class Success < Resonad
    attr_accessor :value

    def initialize(value)
      @value = value
      freeze
    end

    def success?
      true
    end

    def on_success
      yield value
      self
    end

    def on_failure
      self
    end

    def error
      raise NonExistentError, "Success resonads do not have errors"
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

    def flat_map_error
      self
    end
  end

  class Failure < Resonad
    attr_accessor :error

    def initialize(error)
      @error = error
      freeze
    end

    def success?
      false
    end

    def on_success
      self
    end

    def on_failure
      yield error
      self
    end

    def value
      raise NonExistentValue, "Failure resonads do no have values"
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

    def flat_map_error
      yield error
    end
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

  def initialize(*args)
    raise NotImplementedError, "This is an abstract class. Use Resonad::Success or Resonad::Failure instead."
  end

  def success?
    raise NotImplementedError, "should be implemented in subclass"
  end
  def successful?; success?; end
  def ok?; success?; end

  def failure?
    not success?
  end
  def failed?; failure?; end
  def bad?; failure?; end

  def flat_map
    raise NotImplementedError, "should be implemented in subclass"
  end
  def and_then(&block); flat_map(&block); end

  def flat_map_error
    raise NotImplementedError, "should be implemented in subclass"
  end
  def or_else(&block); flat_map_error(&block); end

end
