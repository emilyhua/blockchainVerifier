require_relative 'billcoin.rb'
require 'flamegraph'
# checks if there is an argument input
def show_usage
  puts 'Usage: ruby verifier.rb <name_of_file>'
  puts '	name_of_file = name of file to verify'
  exit 1
end

Flamegraph.generate('verifier_billcoin_optimized.html') do
  if ARGV.length != 1
    show_usage
  else
    args = ARGV[0]
    @run = Billcoin.new(args)
    @run.run(args)
  end
end
