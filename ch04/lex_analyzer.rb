class LexicalAnalyzer < Struct.new(:string)
  GRAMMAR = [
    # if keyword
    {token: 'i', pattern: /if/},
    # else keyword
    {token: 'e', pattern: /else/},
    # while keyword
    {token: 'w', pattern: /while/},
    # do nothing
    {token: 'd', pattern: /do-nothing/},
    {token: '(', pattern: /\(/},
    {token: ')', pattern: /\)/},
    {token: '{', pattern: /\{/},
    {token: '}', pattern: /\}/},
    {token: ';', pattern: /;/},
    # equals
    {token: '=', pattern: /=/},
    # add
    {token: '+', pattern: /\+/},
    # multi
    {token: '*', pattern: /\*/},
    # less than
    {token: '<', pattern: /</},
    # number
    {token: 'n', pattern: /[0-9]+/},
    # boolean
    {token: 'b', pattern: /true|false/},
    # variable
    {token: 'v', pattern: /[a-z]+/},
  ]

  def analyze
    [].tap do |tokens|
      while more_tokens?
        tokens.push(next_token)
      end
    end
  end

  def more_tokens?
    !string.empty?
  end

  def next_token
    rule, match = rule_matching(string)
    self.string = string_after(match)
    rule[:token]
  end

  def rule_matching(string)
    matches = GRAMMAR.map { |rule| match_at_beginning(rule[:pattern], string) }
    rules_with_matches = GRAMMAR.zip(matches).reject{ |rule, match| match.nil? }
    rules_with_longest_match(rules_with_matches)
  end

  def match_at_beginning(pattern, string)
    /\A#{pattern}/.match(string)
  end

  def rules_with_longest_match(rules_with_matches)
    rules_with_matches.max_by { |rule, match| match.to_s.length }
  end

  def string_after(match)
    match.post_match.lstrip
  end
end

if __FILE__ == $0
  puts LexicalAnalyzer.new('y = x * 7').analyze
  puts LexicalAnalyzer.new('while (x < 5) { x = x*3 }').analyze
  puts LexicalAnalyzer.new('if (x < 10) { y = true; x = 0 } else { do-nothing }').analyze
end
