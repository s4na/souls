module Scaffold
  def self.scaffold_resolver_rbs
    <<~RESOLVERRBS
      class Base
      end
      class UserSearch < Base
        include SearchObject
        def self.scope: () ?{ () -> nil } -> [Hash[Symbol, untyped]]
        def self.type: (*untyped) -> String
        def self.option: (:filter, type: untyped, with: :apply_filter) -> String
                        | (:first, type: untyped, with: :apply_first) -> String
                        | (:skip, type: untyped, with: :apply_skip) -> String
        def self.description: (String) -> String
        def self.types: (*untyped) -> String
        def decode_global_key: (String value) -> Integer
        def apply_filter: (untyped scope, untyped value) -> untyped

        class UserFilter
          String: String
          Boolean: Boolean
          Integer: Integer
        end
      end
    RESOLVERRBS
  end
end
