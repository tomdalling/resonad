# Resonad

Success type:

```ruby
result = Resonad.Success(5)
result.success? #=> true
result.failure? #=> false
result.value #=> 5
result.error #=> raises an exception
```

Failure type:

```ruby
result = Resonad.Failure(:buzz)
result.success? #=> false
result.failure? #=> true
result.value #=> raises an exception
result.error #=> :buzz
```

Mapping monads:

```ruby
result = Resonad.Success(5)
  .map { |i| i + 1 }
  .map { |i| i + 1 }
  .map { |i| i + 1 }
result.success? #=> true
result.value #=> 8

result = Resonad.Failure(:buzz)
  .map { |i| i + 1 }
  .map { |i| i + 1 }
  .map { |i| i + 1 }
result.success? #=> false
result.error #=> :buzz
```

Flat mapping monads (a.k.a. `and_then`):

```ruby
result = Resonad.Success(5)
  .and_then { |i| Resonad.Success(i + 1) }
  .and_then { |i| Resonad.Failure("buzz #{i}") }
  .and_then { |i| Resonad.Success(i + 1) }
  .error #=> "buzz 6"

# can also use the less-nice `flat_map` method
result
  .flat_map { |i| Resonad.Success(i + 1) }
```
