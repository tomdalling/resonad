[![Build Status](https://travis-ci.org/tomdalling/resonad.svg?branch=master)](https://travis-ci.org/tomdalling/resonad)

# Resonad

Lightweight, functional "result" objects that can be used instead of exceptions.

Read: [Result Objects - Errors Without Exceptions](https://www.rubypigeon.com/posts/result-objects-errors-without-exceptions/)

## Typical Usage Example

Assuming each method returns a `Resonad` (Ruby 2.7 syntax):

```ruby
find_widget(widget_id)
  .and_then { update_widget(_1) }
  .on_success { logger.info("Updated #{_1}" }
  .on_failure { logger.warn("Widget update failed because #{_1}") }
```

## Success Type

A value that represents success. Wraps a `value` that can be any arbitrary
object.

```ruby
result = Resonad.Success(5)
result.success? #=> true
result.failure? #=> false
result.value #=> 5
result.error #=> raises an exception
```

## Failure Type

A value that represents a failure. Wraps an `error` that can be any arbitrary
object.

```ruby
result = Resonad.Failure(:buzz)
result.success? #=> false
result.failure? #=> true
result.value #=> raises an exception
result.error #=> :buzz
```

## Mapping

Non-destructive update for the `value` of a `Success` object. Does nothing to
`Failure` objects.

The block takes the `value` as an argument, and returns the new `value`.

```ruby
result = Resonad.Success(5)
  .map { _1 + 1 }  # 5 + 1 -> 6
  .map { _1 + 1 }  # 6 + 1 -> 7
  .map { _1 + 1 }  # 7 + 1 -> 8
result.success? #=> true
result.value #=> 8

result = Resonad.Failure(:buzz)
  .map { _1 + 1 }  # not run
  .map { _1 + 1 }  # not run
  .map { _1 + 1 }  # not run
result.success? #=> false
result.error #=> :buzz
```


## Aliases

Lots of the Resonad methods have aliases.

Personally, I can never remember if it's `success?` or `successful?` or `ok?`,
so let's just do it the Ruby way and allow all of them.

```ruby
# >>> object creation aliases (same for failure) <<<
result = Resonad.Success(5)
result = Resonad.success(5)  # lowercase, for those offended by capital letters
result = Resonad::Success[5]  # class constructor method

# >>> success aliases <<<
result.success?  #=> true
result.successful?  #=> true
result.ok?  #=> true

# >>> failure aliases <<<
result.failure?  #=> false
result.failed?  #=> false
result.bad?  #=> false

# >>> mapping aliases <<<
result.map { _1 + 1 }  #=> Success(6)
result.map_value { _1 + 1 }  #=> Success(6)

# >>> flat mapping aliases <<<
result.and_then { Resonad.Success(_1 + 1) }  #=> Success(6)
result.flat_map { Resonad.Success(_1 + 1) }  #=> Success(6)

# >>> error flat mapping aliases <<<
result.or_else { Resonad.Failure(_1 + 1) }  # not run
result.otherwise { Resonad.Failure(_1 + 1) }  # not run
result.flat_map_error { Resonad.Success(_1 + 1) }  # not run

# >>> conditional tap aliases <<<
# pattern: (on_|if_|when_)(success_alias|failure_alias)
result.on_success { puts "hi" }  # outputs "hi"
result.if_success { puts "hi" }  # outputs "hi"
result.when_success { puts "hi" }  # outputs "hi"
result.on_ok { puts "hi" }  # outputs "hi"
result.if_ok { puts "hi" }  # outputs "hi"
result.when_ok { puts "hi" }  # outputs "hi"
result.on_successful { puts "hi" }  # outputs "hi"
result.if_successful { puts "hi" }  # outputs "hi"
result.when_successful { puts "hi" }  # outputs "hi"
result.on_failure { puts "hi" }  # not run
result.if_failure { puts "hi" }  # not run
result.when_failure { puts "hi" }  # not run
result.on_bad { puts "hi" }  # not run
result.if_bad { puts "hi" }  # not run
result.when_bad { puts "hi" }  # not run
result.on_failed { puts "hi" }  # not run
result.if_failed { puts "hi" }  # not run
result.when_failed { puts "hi" }  # not run
```


## Flat Mapping (a.k.a. `and_then`)

Non-destructive update for a `Success` object. Either turns it into another
`Success` (can have a different `value`), or turns it into a `Failure`. Does
nothing to `Failure` objects.

The block takes the `value` as an argument, and returns a `Resonad` (either
`Success` or `Failure`). 

```ruby
result = Resonad.Success(5)
  .and_then { Resonad.Success(_1 + 1) }  # updates to Success(6)
  .and_then { Resonad.Failure("buzz #{_1}") }  # updates to Failure("buzz 6")
  .and_then { Resonad.Success(_1 + 1) }  # not run (because it's a failure)
  .error #=> "buzz 6"

# also has a less-friendly but more-technically-descriptive alias: `flat_map`
result.flat_map { Resonad.Success(_1 + 1) }
```

This is different to Ruby's `#then` method added in 2.6. The block for `#then`
would take a Resonad argument, regardless of whether it's `Success` or
`Failure`. The block for `#and_then` takes a _`Success` object's value_, and
only runs on `Success` objects, not `Failure` objects.


## Error Mapping

Just as `Success` objects can be chained with `#map` and `#and_then`, so can
`Failure` objects with `#map_error` and `#or_else`. This isn't used as often,
but has a few use cases such as:

```ruby
# Use Case: convert an error value into another error value
make_http_request  #=> Failure(404)
  .map_error { |status_code| "HTTP #{status_code} Error" }
  .error #=> "HTTP 404 Error"

# Use Case: recover from error, turning into Success
load_config_file  #=> Failure(:config_file_missing)
  .or_else { try_recover_from(_1) }
  .value  #=> { :setting => 'default' }

def try_recover_from(error)
  if error == :config_file_missing
    Resonad.Success({ setting: 'default' })
  else
    Resonad.Failure(error)
  end
end
```


## Conditional Tap

If you're in the middle of a long chain of methods, and you don't want to break
the chain to run some kind of side effect, you can use the `#on_success` and
`#on_failure` methods. These run an arbitrary block code, but do not affect the
result object in any way. They work like Ruby's `#tap` method, but `Failure`
objects will not run `on_success` blocks, and `Success` objects will not run
`on_failure` blocks.

```ruby
do_step_1
  .and_then { do_step_2(_1) }
  .and_then { do_step_3(_1) }
  .on_success { puts "Successful step 3 result: #{_1}" }
  .and_then { do_step_4(_1) }
  .and_then { do_step_5(_1) }
  .on_failure { puts "Uh oh! Step 5 failed: #{_1} }
  .and_then { do_step_6(_1) }
  .and_then { do_step_7(_1) }
```

There are lots of aliases for these methods. See the "Aliases" section above.

## Callable Object Arguments

Anywhere that you can use a block argument, you have the ability to
provide a callable object instead.

For example, this block argument:

```ruby
Resonad.Success(42).map { |x| x * 2 }
#=> 84
```

Could also be given as an object that implements `#call`:

```ruby
class Doubler
  def call(x)
    x * 2
  end
end

Resonad.Success(42).map(Doubler.new)
#=> 84
```

## Pattern Matching Support

If you are using Ruby 2.7 or later, you can pattern match on Resonad objects.
For example:

```ruby
case result
in { value: }  # match any Success
  puts value
in { error: :not_found } # match Failure(:not_found)
  puts "Thing not found"
in { error: String => msg } # match any Failure with a String error
  puts "Failed to fetch thing because #{msg}"
in { error: } # match any Failure
  raise "Unhandled error: #{error.inspect}"
end
```

`Resonad.Success(5)` deconstructs to:

 - Hash: `{ value: 5 }`
 - Array: `[:success, 5]`

And `Resonad.Failure('yikes')` deconstructs to:

 - Hash: `{ error: 'yikes' }`
 - Array: `[:failure, 'yikes']`


## Automatic Exception Rescuing

If no exception is raised, wraps the block's return value in `Success`. If an
exception is raised, wraps the exception object in `Failure`.

```ruby
def try_divide(top, bottom)
  Resonad.rescuing_from(ZeroDivisionError) { top / bottom }
end

yep = try_divide(6, 2)
yep.success? #=> true
yep.value #=> 3

nope = try_divide(6, 0)
nope.success? #=> false
node.error #=> #<ZeroDivisionError: ZeroDivisionError>
```


## Convenience Mixin

If you're tired of typing "Resonad." in front of everything, you can include
the `Resonad::Mixin` mixin.

```ruby
class RobotFortuneTeller
  include Resonad::Mixin

  def next_fortune
    case rand(0..100)
    when 0..70
      # title-case constructor from Resonad::Mixin
      Success("today is auspicious")
    when 71..95
      # lower-case constructor from Resonad::Mixin
      success("ill omens abound")
    else
      # direct access to classes from Resonad::Mixin
      Failure.new("MALFUNCTION")
    end
  end
end
```

Note that `Resonad::Mixin` provides private methods, and private constants, so
you can't do this:

```ruby
RobotFortuneTeller.new.Success(5)
  #=> NoMethodError: private method `Success' called for #<RobotFortuneTeller:0x00007fe7fc0ff0c8>

RobotFortuneTeller::Success
  #=> NameError: private constant Resonad::Mixin::Success referenced
```

If you want the methods/constants to be public, then use `Resonad::PublicMixin`
instead.


## Contributing

Bug reports and pull requests are welcome on GitHub at:
https://github.com/tomdalling/resonad

I'm open to PRs that make the gem more convenient, or that makes calling code
read better.

Make sure your PR has full test coverage.

