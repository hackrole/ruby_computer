class Number < Struct.new(:value)
end

class Add < Struct.new(:left, :right)
end

class Multi < Struct.new(:left, :right)
end

puts Add.new(
  Multi.new(Number.new(1), Number.new(2)),
  Multi.new(Number.new(3), Number.new(4))
)
