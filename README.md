[![Build Status](https://travis-ci.org/tomdalling/resonad.svg?branch=master)](https://travis-ci.org/tomdalling/resonad)

# Resonad

Lightweight, monadic "result" objects that can be used instead of exceptions.

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
result = Resonad.Success(5)

# success aliases
result.success?  #=> true
result.successful?  #=> true
result.ok?  #=> true

# failure aliases
result.failure?  #=> false
result.failed?  #=> false
result.bad?  #=> false

# flat mapping aliases
result.and_then { Resonad.Success(_1 + 1) }  #=> Success(6)
result.flat_map { Resonad.Success(_1 + 1) }  #=> Success(6)

# error flat mapping aliases
result.or_else { Resonad.Failure(_1 + 1) }  # not run
result.otherwise { Resonad.Failure(_1 + 1) }  # not run
result.flat_map_error { Resonad.Success(_1 + 1) }  # not run
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
class SpiceOfLife
  include Resonad::Mixin

  def call
    if rand > 0.5
      Success("ya got lucky")
    else
      Failure("NOPE")
    end
  end
end
```


## TODO

 - "map_value" alias for "map"
 - "Resonad::Success[5]" alias for "Resonad.Success(5)"
 - aliases for "on_success" and "on_failure"

