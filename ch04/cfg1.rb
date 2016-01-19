require './npda1'
require './lex_analyzer'


start_rule = PDARule.new(1, nil, 2, '$', ['S', '$'])
puts start_rule

symbol_rules = [
  # <startment> ::= <while> | <assign>
  PDARule.new(2, nil, 2, 'S', ['W']),
  PDARule.new(2, nil, 2, 'S', ['A']),

  # <while> ::= 'w' '(' <expression> ')' '{' <statement> '}'
  PDARule.new(2, nil, 2, 'W', ['W', '(', 'E', ')', '{', 'S', '}']),

  # <assing> ::= 'v' = <expression>
  PDARule.new(2, nil, 2, 'A', ['v', '=', 'E']),

  # <expression> ::= <less-than>
  PDARule.new(2, nil, 2, 'E', ['L']),

  # <less-than> ::= <multiply> '<' <less-than> | <multiply>
  PDARule.new(2, nil, 2, 'L', ['M', '<', 'L']),
  PDARule.new(2, nil, 2, 'L', ['M']),

  # <multiply> ::= <term> '*' <muliply> | term
  PDARule.new(2, nil, 2, 'M', ['T', '*', 'M']),
  PDARule.new(2, nil, 2, 'M', ['T']),

  # <term> ::= 'n' | 'v'
  PDARule.new(2, nil, 2, 'T', ['n']),
  PDARule.new(2, nil, 2, 'T', ['v']),
]
puts symbol_rules

token_rules = LexicalAnalyzer::GRAMMAR.map do |rule|
  PDARule.new(2, rule[:token], 2, rule[:token], [])
end
puts token_rules

stop_rules = PDARule.new(2, nil, 3, '$', ['$'])
puts stop_rules

rulebook = NPDARulebook.new([start_rule, stop_rules] + symbol_rules + token_rules)
puts rulebook

npda_design = NPDADesign.new(1, '$', [3], rulebook)
puts npda_design

token_string = LexicalAnalyzer.new('while (x < 3) { x = x * 3 }').analyze.join
puts token_string

puts npda_design.accepts?(token_string)
puts npda_design.accepts?(LexicalAnalyzer.new('while (x < 5 x = x * }').analyze.join)
