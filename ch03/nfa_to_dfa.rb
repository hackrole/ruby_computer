require 'set'
require './dfa2'

# monkey Set for better output
class Set
  def to_s
    inspect
  end
end

class FARule < Struct.new(:state, :character, :next_state)

  def applies_to?(state, character)
    self.state == state && self.character == character
  end

  def follow
    next_state
  end

  def inspect
    "<FARule #{state.inspect}--#{character}-->#{next_state.inspect}>"
  end
end

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map {|state| follow_rules_for(state, character)}.to_set
  end

  def alphabet
    rules.map(&:character).compact.uniq
  end

  def follow_rules_for(state, character)
    rules_for(state, character).map(&:follow)
  end

  def follow_free_moves(states)
    more_states = next_states(states, nil)

    if more_states.subset?(states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end

  def rules_for(state, character)
    rules.select {|rule| rule.applies_to?(state, character)}
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def accepting?
    (current_states & accept_states).any?
  end

  def current_states
    rulebook.follow_free_moves(super)
  end

  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end
end


class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepting?(string)
    to_nfa.tap {|nfa| nfa.read_string(string)}.accepting?
  end
  def to_nfa(current_states = Set[start_state])
    NFA.new(current_states, accept_states, rulebook)
  end
end


class NFASimulation < Struct.new(:nfa_design)
  def next_state(state, character)
    nfa_design.to_nfa(state).tap { |nfa|
      nfa.read_character(character)
    }.current_states
  end

  def rules_for(state)
    nfa_design.rulebook.alphabet.map do |character|
      DFARule.new(state, character, next_state(state, character))
    end
  end

  def to_dfa_design
    start_state = nfa_design.to_nfa.current_states
    states, rules = discover_states_and_rules(Set[start_state])
    accept_states = states.select { |state| nfa_design.to_nfa(state).accepting? }

    DFADesign.new(start_state, accept_states, DFARulebook.new(rules))
  end

  def discover_states_and_rules(states)
    rules = states.flat_map { |state| rules_for(state) }
    more_states = rules.map(&:follow).to_set

    if more_states.subset?(states)
      [states, rules]
    else
      discover_states_and_rules(states + more_states)
    end
  end
end


rulebook = NFARulebook.new([
  FARule.new(1, 'a', 1),
  FARule.new(1, 'a', 2),
  FARule.new(1, nil, 2),
  FARule.new(2, 'b', 3),
  FARule.new(3, 'b', 1),
  FARule.new(3, nil, 2),
])
puts rulebook

nfa_design = NFADesign.new(1, [3], rulebook)
puts nfa_design

puts nfa_design.to_nfa.current_states
puts nfa_design.to_nfa(Set[2]).current_states
puts nfa_design.to_nfa(Set[3]).current_states

nfa = nfa_design.to_nfa(Set[2, 3])
puts nfa
puts nfa.read_character('b')
puts nfa.current_states

simulation = NFASimulation.new(nfa_design)
puts simulation.next_state(Set[1, 2], 'a')
puts simulation.next_state(Set[1, 2], 'b')
puts simulation.next_state(Set[3, 2], 'b')
puts simulation.next_state(Set[1, 3, 2], 'b')
puts simulation.next_state(Set[1, 3, 2], 'a')

puts rulebook.alphabet
puts simulation.rules_for(Set[1, 2])
puts simulation.rules_for(Set[3, 2])

start_state = nfa_design.to_nfa.current_states
puts start_state
puts simulation.discover_states_and_rules(Set[start_state])

puts nfa_design.to_nfa(Set[1, 2]).accepting?
puts nfa_design.to_nfa(Set[2, 3]).accepting?

dfa_design = simulation.to_dfa_design
puts dfa_design
puts dfa_design.accepting?('aaa')
puts dfa_design.accepting?('aab')
puts dfa_design.accepting?('bbbabb')
