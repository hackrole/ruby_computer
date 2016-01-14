require "./nfa_free_move"

module Pattern
  def bracker(outer_precedence)
    if precedence < outer_precedence
      '(' + to_s + ')'
    else
      to_s
    end
  end
  def inspect
    '/#{self}/'
  end

  def matches?(string)
    to_nfa_design.accepting?(string)
  end
end

class Empty
  include Pattern

  def to_s
    ''
  end

  def precedence
    3
  end

  def to_nfa_design
    start_state = Object.new
    accept_states = [start_state]
    rulebook = NFARulebook.new([])

    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Literal < Struct.new(:character)
  include Pattern

  def to_s
    character
  end

  def precedence
    3
  end

  def to_nfa_design
    start_state = Object.new
    accept_state = Object.new
    rule = FARule.new(start_state, character,accept_state)
    rulebook = NFARulebook.new([rule])

    NFADesign.new(start_state, [accept_state], rulebook)
  end
end

class Concatenate < Struct.new(:first, :second)
  include Pattern

  def to_s
    [first, second].map { |pattern| pattern.bracker(precedence) }.join
  end

  def precedence
    1
  end

  def to_nfa_design
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design

    start_state = first_nfa_design.start_state
    accept_states = second_nfa_design.accept_states
    rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
    extra_rules = first_nfa_design.accept_states.map do |state|
      FARule.new(state, nil, second_nfa_design.start_state)
    end
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start_state, accept_states, rulebook)
  end

end

class Choose < Struct.new(:first, :second)
  include Pattern

  def to_s
    [first, second].map { | pattern| pattern.bracker(precedence) }.join('|')
  end

  def precedence
    0
  end

  def to_nfa_design
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design

    start_state = Object.new
    accept_states = first_nfa_design.accept_states + second_nfa_design.accept_states
    rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
    extra_rules = [first_nfa_design, second_nfa_design].map do |nfa_design|
      FARule.new(start_state, nil, nfa_design.start_state)
    end
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Repeat < Struct.new(:pattern)
  include Pattern

  def to_s
    pattern.bracker(precedence) + '*'
  end

  def precedence
    2
  end

  def to_nfa_design
    pattern_nfa_design = pattern.to_nfa_design

    start_state = Object.new
    accept_states = pattern_nfa_design.accept_states + [start_state]
    rules = pattern_nfa_design.rulebook.rules
    extra_rules = pattern_nfa_design.accept_states.map do |accept_state|
      FARule.new(accept_state, nil, pattern_nfa_design.start_state)
    end
    extra_rules += [FARule.new(start_state, nil, pattern_nfa_design.start_state)]
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start_state, accept_states, rulebook)
  end
end


pattern = Repeat.new(
  Choose.new(
    Concatenate.new(Literal.new('a'), Literal.new('b')),
    Literal.new('a')
  )
)

nfa_design = Empty.new.to_nfa_design
puts nfa_design.accepting?('')
puts nfa_design.accepting?('a')

nfa_design = Literal.new('a').to_nfa_design
puts nfa_design.accepting?('')
puts nfa_design.accepting?('a')
puts nfa_design.accepting?('b')

puts Empty.new.matches?('a')
puts Literal.new('a').matches?('a')

pattern = Concatenate.new(Literal.new('a'), Literal.new('b'))
puts pattern
puts pattern.matches?('a')
puts pattern.matches?('ab')
puts pattern.matches?('abc')

pattern = Concatenate.new(
  Literal.new('a'),
  Concatenate.new(Literal.new('b'), Literal.new('c'))
)
puts pattern
puts pattern.matches?('a')
puts pattern.matches?('ab')
puts pattern.matches?('abc')

pattern = Choose.new(Literal.new('a'), Literal.new('b'))
puts pattern
puts pattern.matches?('a')
puts pattern.matches?('b')
puts pattern.matches?('c')

pattern = Repeat.new(Literal.new('a'))
puts pattern
puts pattern.matches?('')
puts pattern.matches?('a')
puts pattern.matches?('aaaa')
puts pattern.matches?('b')

pattern = Repeat.new(
  Concatenate.new(
    Literal.new('a'),
    Choose.new(Empty.new, Literal.new('b'))
  )
)
puts pattern
puts pattern.matches?('')
puts pattern.matches?('a')
puts pattern.matches?('ab')
puts pattern.matches?('aba')
puts pattern.matches?('abab')
puts pattern.matches?('abaab')
puts pattern.matches?('abba')
