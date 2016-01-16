require 'treetop'
require './pattern2'

Treetop.load('pattern')

puts '======================================'
parse_tree = PatternParser.new.parse('(a(|b))*')
puts parse_tree
puts parse_tree.inspect

pattern = parse_tree.to_ast
puts pattern

puts pattern.matches?('abaab')
puts pattern.matches?('abba')
