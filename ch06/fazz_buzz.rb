def fb_print
  (1..100).each do |n|
    if (n % 15).zero?
      puts 'FizzBuzz'
    elsif (n % 3).zero?
      puts 'Fizz'
    elsif (n % 5).zero?
      puts 'Buzz'
    else
      puts n.to_s
    end
  end
end

def fb_return
  (1..100).each do |n|
    if (n % 15).zero?
      'FizzBuzz'
    elsif (n % 3).zero?
      'Fizz'
    elsif (n % 5).zero?
      'Buzz'
    else
      n.to_s
    end
  end
end

if __FILE__ == $0
  fb_print
  fb_return
end
