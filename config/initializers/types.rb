# frozen_string_literal: true

class CountingNumberType < ActiveRecord::Type::BigInteger
  def cast(value)
    [value.to_i, 0].max
  end
end

ActiveRecord::Type.register(:counting_number, CountingNumberType)
