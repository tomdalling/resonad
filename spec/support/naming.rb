module Naming
  AND_THEN_ALIASES = [:and_then, :flat_map]
  OR_ELSE_ALIASES = [:or_else, :otherwise, :flat_map_error]
  SUCCESS_ALIASES = [:success?, :successful?, :ok?]
  FAILURE_ALIASES = [:failure?, :failed?, :bad?]
  MAP_ALIASES = [:map, :map_value]

  ON_PREFIXES = ["on_", "if_", "when_"]
  ON_SUCCESS_SUFFIXES = SUCCESS_ALIASES.map { |m| m.to_s.chomp('?') }
  ON_FAILURE_SUFFIXES = FAILURE_ALIASES.map { |m| m.to_s.chomp('?') }
  ON_SUCCESS_ALIASES = ON_PREFIXES.product(ON_SUCCESS_SUFFIXES).map(&:join)
  ON_FAILURE_ALIASES = ON_PREFIXES.product(ON_FAILURE_SUFFIXES).map(&:join)
end
