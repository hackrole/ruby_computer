class Number < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    false
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def reduce(environment)
    if left.reducible?
      Add.new(left.reduce(environment), right)
    elsif right.reducible?
      Add.new(left, right.reduce(environment))
    else
      Number.new(left.value + right.value)
    end
  end
end

class Multi < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def reduce(environment)
    if left.reducible?
      Multi.new(left.reduce(environment), right)
    elsif right.reducible?
      Multi.new(left, right.reuce(environment))
    else
      Number.new(left.value * right.value)
    end
  end
end


class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    false
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<<#{self}"
  end
  def reducible?
    true
  end
  def reduce(environment)
    if left.reducible?
      LessThan.new(left.reduce(environment), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end
end

class Variable
  def reduce(environment)
    environment[name]
  end
end

class DoNothing
  def to_s
    'do-nothing'
  end
  def inspect
    "<<#{self}>>"
  end
  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def reducible?
    false
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    if expression.reducible?
      [Assign.new(name, expression.reduce(environment)), environment]
    else
      [DoNothing.new, environment.merge({name => expression})]
    end
  end
end

class Machine < Struct.new(:statement, :environment)
  def step
    self.statement, self.environment = statement.reduce(environment)
  end

  def run
    while statement.reducible?
      puts statement
      step
    end
    puts "#{statement}, #{environment}"
  end
end

old_environment = {y: Number.new(5)}
new_environment = old_environment.merge({x: Number.new(3)})
puts old_environment
puts new_environment

statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))
puts statement
environment = {x: Number.new(2)}
puts statement.reducible?
statement, environment = statement.reduce(environment)
statement, environment = statement.reduce(environment)
statement, environment = statement.reduce(environment)
puts statement.reducible?

Machine.new(
  Assign.new(:x, Add.new(Variable.new(:x), Number.new(1))),
  {x: Number.new(2)}
).run
