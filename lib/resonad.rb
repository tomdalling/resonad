class Resonad
  class NonExistentError < StandardError; end
  class NonExistentValue < StandardError; end

  class Success < Resonad
    attr_accessor :value

    def self.[](value = nil)
      if nil == value
        NIL_SUCCESS
      else
        new(value)
      end
    end

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

    def deconstruct
      [:success, value]
    end

    def deconstruct_keys(_)
      { value: value }
    end
  end

  class Failure < Resonad
    attr_accessor :error

    def self.[](error = nil)
      if nil == error
        NIL_FAILURE
      else
        new(error)
      end
    end

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

    def deconstruct
      [:failure, error]
    end

    def deconstruct_keys(_)
      { error: error }
    end
  end

  module PublicMixin
    Success = ::Resonad::Success
    Failure = ::Resonad::Failure

    def Success(*args); Success[*args]; end
    def success(*args); Success[*args]; end
    def Failure(*args); Failure[*args]; end
    def failure(*args); Failure[*args]; end
  end

  Mixin = PublicMixin.dup.tap do |mixin|
    mixin.module_eval do
      private(*public_instance_methods)
      private_constant(*constants)
    end
  end

  extend PublicMixin

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

  def map(&block)
    raise NotImplementedError, "should be implemented in subclass"
  end
  def map_value(&block); map(&block); end

  def flat_map
    raise NotImplementedError, "should be implemented in subclass"
  end
  def and_then(&block); flat_map(&block); end

  def flat_map_error
    raise NotImplementedError, "should be implemented in subclass"
  end
  def or_else(&block); flat_map_error(&block); end
  def otherwise(&block); flat_map_error(&block); end

  def on_success(&block)
    raise NotImplementedError, "should be implemented in subclass"
  end
  def if_success(&block); on_success(&block); end
  def when_success(&block); on_success(&block); end
  def on_ok(&block); on_success(&block); end
  def if_ok(&block); on_success(&block); end
  def when_ok(&block); on_success(&block); end
  def on_successful(&block); on_success(&block); end
  def if_successful(&block); on_success(&block); end
  def when_successful(&block); on_success(&block); end

  def on_failure(&block)
    raise NotImplementedError, "should be implemented in subclass"
  end
  def if_failure(&block); on_failure(&block); end
  def when_failure(&block); on_failure(&block); end
  def on_bad(&block); on_failure(&block); end
  def if_bad(&block); on_failure(&block); end
  def when_bad(&block); on_failure(&block); end
  def on_failed(&block); on_failure(&block); end
  def if_failed(&block); on_failure(&block); end
  def when_failed(&block); on_failure(&block); end

  NIL_SUCCESS = Success.new(nil)
  NIL_FAILURE = Failure.new(nil)
end
