class Number
  def evaluate(environment)
    self
  end
end

class Boolean
  def evaluate(environment)
    self
  end
end

class Variable
  def evaluate(environment)
    environment[name]
  end
end

class Add
  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end
end


class Multiply
  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end
end

class LessThan
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end
end


puts Number.new(23).evaluate({})
puts Variable.new(:x).evaluate({x: Number.new(23)})
puts LessThan.new(Add.new(Variable.new(:x), Number.new(2)),
                 Variable.new(:y)
                 ).evaluate({x: Number.new(2), y: Number.new(5)})

class Assign
  def evaluate(environment)
    environment.merge({name => expression.evaluate(environment)})
  end
end

class DoNothing
  def evaluate(environment)
    environment
  end
end

class If
  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      consequence.evaluate(environment)
    end
  end
end

class Sequence
  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end
end

statement = Sequence.new(
  Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
  Assign.new(:y, Add.new(Number.new(:x), Number.new(3)))
)
puts statement
puts statement.evaluate({})

class While
  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end
end

statement = While.new(
  LessThan.new(Variable.new(:x), Number.new(5)),
  Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
)
puts statement
puts statement.evaluate({x: Number.new(1)})
