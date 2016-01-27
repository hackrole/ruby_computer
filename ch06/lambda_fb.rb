# ================== the ruby define
# define num
def one(proc, x)
  proc[x]
end

def two(proc, x)
  proc[proc[x]]
end

def three(proc, x)
  proc[proc[proc[x]]]
end

def zero(prox, x)
  x
end

# proc => nums
def to_integer(proc)
  proc[-> n{ n + 1 }][0]
end

# define boolean
def true(x, y)
x
end

def false(x, y)
  y
end

def to_boolean(proc)
  # old version
  # proc[true][false]
  IF[proc][true][false]
end

def if(proc, x, y)
  prox[x][y]
end

def zero?(proc)
  proc[-> x {FALSE}][TRUE]
end

# increment and decrement
def slide(pair)
  [pair.last, pair.last + 1]
end

# less-than/mod
def mod(m, n)
  IF[IS_LESS_OR_EQUAL[n][m]][
    mod(SUB[m][n], n)
  ][m]
end

def less_or_equal?(m, n)
  IS_ZERO[SUB[m][n]]
end

# list
def to_array(proc)
  array = []

  until to_boolean[IS_EMPTY[proc]]
    array.push(FIRST[proc])
    proc = REST[proc]
  end

  array
end

def range(m, n)
  if m <= n
    range(m + 1, n).unshift(m)
  else
    []
  end
end


# ================== the lambda define
# define num
ZERO = -> p { -> x { x } }
ONE = -> p { -> x { p[x] } }
TWO = -> p { -> x { p[p[x]] } }
THREE = -> p { -> x { p[p[p[x]]] } }
FIVE = -> p { -> x { p[p[p[p[p[x]]]]] } }
# XXX use what above to define 15/100

# define boolean
TRUE = -> x { -> y { x } }
FALSE = -> x { -> y { y } }
IF = -> b { -> x { -> y { b[x][y] } } }
# simple
# IF = -> b { b }
IS_ZERO = -> n { n[-> x { FALSE }][TRUE] }

# pair
PAIR = -> x { -> y { -> f { f[x][y] } } }
LEFT = -> p { p[ -> x { -> y { x } } ] }
RIGHT = -> p { p[ -> x { -> y { y } } ] }

# increment
INCREMENT = -> n { -> p { -> x { p[n[n][x]] } } }
# decrement
SLIDE = -> p { PAIR[RIGHT[p]][INCREMENT[RIGHT[p]]] }
DECREMENT = -> n { LEFT[n[SLIDE][PAIR[ZERO][ZERO]]] }

# add/sub/multi/power
ADD = -> m { -> n { n[INCREMENT][m] } }
SUB = -> m { -> n { n[DECREMENT][m] }}
MULTIPLY = -> m { -> n { n[ADD[m][ZERO]] } }
POWER = -> m { -> n { n[MULTIPLY[m]][ONE] } }

# is less than
IS_LESS_OR_EQUAL = -> m { -> n { IS_ZERO[SUB[m][n]] } }

# mod
MOD = -> m { -> n { IF[IS_LESS_OR_EQUAL][n][m][ -> x {MOD[SUB[m][n]][n][x] }][m] } }

# y组合子, 定义递归
Y = -> f { -> x { f[x[x]] }[-> x { f[x[x]] }] }
Z = -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[-> y { x[x][y] }] }] }

# new mod use Y组合子。不依赖赋值特性.
MOD = Z[-> f { -> m { -> n {
  IF[IS_LESS_OR_EQUAL[n][m]][
    -> x {
      f[SUB[m][n]][n][x]
    }
  ][m]
} } }]

# list
EMPTY = PAIR[TRUE][TRUE]
UNSHIFT = -> l { -> x {
  PAIR[FALSE][PAIR[x][l]]
} }
IS_EMPTY = LEFT
FIRST = -> l { LEFT[RIGHT[l]] }
REST = -> l { RIGHT[RIGHT[l]] }

RANGE = Z[-> f {
  -> m { -> n {
    IF[IS_LESS_OR_EQUAL[m][n]][
      -> x {
        UNSHIFT[f[INCREMENT[m]][n]][m][x]
      }
    ][
      EMPTY
    ]
  } }
}]

# this would print
if __FILE__ == $0
  puts to_integer(ZERO)
  puts to_integer(THREE)

  success = :true
  puts send(success, 'happy', 'sad')
  puts to_boolean(TRUE)
  puts to_boolean(FALSE)
  puts IF[TRUE]['happy']['sad']
  puts IF[FALSE]['happy']['sad']

  puts to_boolean(IS_ZERO[ZERO])
  puts to_boolean(IS_ZERO[THREE])

  my_pair = PAIR[THREE][TWO]
  puts my_pair
  puts to_integer(LEFT[my_pair])
  puts to_integer(RIGHT[my_pair])

  puts slide([3, 4]).inspect
  puts slide([8, 9]).inspect
  puts slide([-1, 0]).inspect
  puts slide(slide([-1, 0])).inspect
  puts slide(slide(slide([-1, 0]))).inspect
  puts slide([0, 0]).inspect
  puts slide(slide([0, 0])).inspect

  puts to_integer(DECREMENT[TWO])
  puts to_integer(DECREMENT[ONE])

  puts to_integer(SUB[FIVE][THREE])

  puts to_boolean(IS_LESS_OR_EQUAL[ONE][TWO])
  puts to_boolean(IS_LESS_OR_EQUAL[TWO][TWO])
  puts to_boolean(IS_LESS_OR_EQUAL[THREE][TWO])

  puts to_integer(MOD[THREE][TWO])

  puts to_integer(MOD[THREE][TWO])

  my_range = RANGE[ONE][THREE]
  puts my_range
  puts to_array(my_range).map { |p| to_integer(p) }
end
