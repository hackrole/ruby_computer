class Number
  def to_ruby
    "-> e { #{value.inspect} }"
  end
end


class Boolean
  def to_ruby
    "-> e { #{value.inspect} }"
  end
end

puts Number.new(5).to_ruby
puts Boolean.new(false).to_ruby

proc = eval(Number.new(5).to_ruby)
proc.call({})
proc = eval(Boolean.new(false).to_ruby)
proc.call({})

class Variable
  def to_ruby
    "-> e { e[#{name.inspect}] }"
  end
end

expression = Variable.new(:x)
puts expression.to_ruby
proc = eval(expression.to_ruby)
proc.call({x: 7})


class Add
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end
end

class Multiply
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end
end

class LessThan
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end
end

puts Add.new(Variable.new(:x), Number.new(1)).to_ruby
puts LessThan.new(Add.new(Variable.new(:x), Number.new(1)), Number.new(3)).to_ruby

environment = {x: 3}
proc = eval(Add.new(Variable.new(:x), Number.new(1)).to_ruby)
puts proc.call(environment)

proc = eval(
  LessThan.new(Add.new(Variable.new(:x), Number.new(1)), Number.new(3)).to_ruby
)
puts proc.call(environment)


class Assign
  def to_ruby
    "-> e { e.merge({#{name.inspect} => (#{expression.to_ruby}).call(e) }) }"
  end
end

statement = Assign.new(:y, Add.new(Variable.new(:x), Number.new(1)))
puts statement
puts statement.to_ruby
proc = eval(statement.to_ruby)
puts proc.call({x: 3})

class DoNothing
  def to_ruby
    "-> e { e }"
  end
end

class If
  def to_ruby
    " -> e { if (#{evaluate.toruby}).call(e) }" +
      " then (#{consequence.to_ruby}).call(e)" +
      " else (#{alternative.to_ruby}).call(e)" + 
      " end }"
  end
end

class Sequence
  def to_ruby
    " -> e { (#{condition.to_ruby}).call((#{first.to_ruby}).call(e)) }"
  end
end

class While
  def to_ruby
    " -> e {" +
      " while (#{condition.to_ruby}).call(e); e = (#{body.to_ruby}).call(e); end;" +
      " e" +
      " }"
  end
end

statement = While.new(
  LessThan.new(Variable.new(:x), Number.new(5)),
  Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
)
puts statement
puts statement.to_ruby
proc = eval(statement.to_ruby)
puts proc
puts proc.call({x: 1})
