module Gitrob
  module Models
    class Signature < Sequel::Model
      set_allowed_columns :rule, :sha

      many_to_one :blob
      many_to_one :assessment
      many_to_one :signature

    end
  end
end
