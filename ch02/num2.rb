class Number < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end
  def inspect
    "<<#{self}>>"
  end

end

class Multi < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
end

puts Add.new(
  Multi.new(Number.new(1), Number.new(2)),
  Multi.new(Number.new(3), Number.new(4))
)

puts Number.new(4)
