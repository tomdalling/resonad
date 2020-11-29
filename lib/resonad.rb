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

    def deconstruct
      [:success, value]
    end

    def deconstruct_keys(_)
      { value: value }
    end

    def error
      raise NonExistentError, "Success resonads do not have errors"
    end

    private

      def __on_success(callable)
        callable.(value)
        self
      end

      def __on_failure(_)
        self
      end

      def __map(callable)
        new_value = callable.(value)
        if new_value.__id__ == value.__id__
          self
        else
          self.class.new(new_value)
        end
      end

      def __map_error(_)
        self
      end

      def __flat_map(callable)
        callable.(value)
      end

      def __flat_map_error(_)
        self
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

    def value
      raise NonExistentValue, "Failure resonads do not have values"
    end

    def deconstruct
      [:failure, error]
    end

    def deconstruct_keys(_)
      { error: error }
    end

    private

      def __map(_)
        self
      end

      def __on_success(_)
        self
      end

      def __on_failure(callable)
        callable.(error)
        self
      end

      def __map_error(callable)
        new_error = callable.(error)
        if new_error.__id__ == error.__id__
          self
        else
          self.class.new(new_error)
        end
      end

      def __flat_map(_)
        self
      end

      def __flat_map_error(callable)
        callable.(error)
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

  def map(callable=nil, &block);       __map(callable_from_args(callable, block)); end
  def map_value(callable=nil, &block); __map(callable_from_args(callable, block)); end

  def map_error(callable=nil, &block); __map_error(callable_from_args(callable, block)); end

  def flat_map(callable=nil, &block); __flat_map(callable_from_args(callable, block)); end
  def and_then(callable=nil, &block); __flat_map(callable_from_args(callable, block)); end

  def flat_map_error(callable=nil, &block); __flat_map_error(callable_from_args(callable, block)); end
  def or_else(callable=nil, &block);        __flat_map_error(callable_from_args(callable, block)); end
  def otherwise(callable=nil, &block);      __flat_map_error(callable_from_args(callable, block)); end

  def on_success(callable=nil, &block);      __on_success(callable_from_args(callable, block)); end
  def if_success(callable=nil, &block);      __on_success(callable_from_args(callable, block)); end
  def when_success(callable=nil, &block);    __on_success(callable_from_args(callable, block)); end
  def on_ok(callable=nil, &block);           __on_success(callable_from_args(callable, block)); end
  def if_ok(callable=nil, &block);           __on_success(callable_from_args(callable, block)); end
  def when_ok(callable=nil, &block);         __on_success(callable_from_args(callable, block)); end
  def on_successful(callable=nil, &block);   __on_success(callable_from_args(callable, block)); end
  def if_successful(callable=nil, &block);   __on_success(callable_from_args(callable, block)); end
  def when_successful(callable=nil, &block); __on_success(callable_from_args(callable, block)); end

  def on_failure(callable=nil, &block);   __on_failure(callable_from_args(callable, block)); end
  def if_failure(callable=nil, &block);   __on_failure(callable_from_args(callable, block)); end
  def when_failure(callable=nil, &block); __on_failure(callable_from_args(callable, block)); end
  def on_bad(callable=nil, &block);       __on_failure(callable_from_args(callable, block)); end
  def if_bad(callable=nil, &block);       __on_failure(callable_from_args(callable, block)); end
  def when_bad(callable=nil, &block);     __on_failure(callable_from_args(callable, block)); end
  def on_failed(callable=nil, &block);    __on_failure(callable_from_args(callable, block)); end
  def if_failed(callable=nil, &block);    __on_failure(callable_from_args(callable, block)); end
  def when_failed(callable=nil, &block);  __on_failure(callable_from_args(callable, block)); end

  NIL_SUCCESS = Success.new(nil)
  NIL_FAILURE = Failure.new(nil)

  private

    def __map(callable)
      raise NotImplementedError, "should be implemented in subclass"
    end

    def __flat_map(callable)
      raise NotImplementedError, "should be implemented in subclass"
    end

    def __flat_map_error(callable)
      raise NotImplementedError, "should be implemented in subclass"
    end

    def __on_success(callable)
      raise NotImplementedError, "should be implemented in subclass"
    end

    def __on_failure(callable)
      raise NotImplementedError, "should be implemented in subclass"
    end

    def callable_from_args(positional, block)
      if block
        if positional
          raise ArgumentError, "expected _either_ a callable or a block argument, but _both_ were given"
        else
          block
        end
      else
        if positional
          positional
        else
          raise ArgumentError, "expected either a callable or a block argument, but neither were given"
        end
      end
    end
end
