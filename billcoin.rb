require_relative 'block.rb'
require_relative 'transaction.rb'
# Emily Hua (ewh13)
class Billcoin
  attr_accessor :input, :blockchain, :blocks, :balance, :transactions

  def initialize(args)
    @input = args
  end

  # checks if there is an empty file, if not then read in all of the data to verify
  def read_data(args)
    @input = args
    if File.zero?(@input)
      puts 'File is empty. Quiting.'
      exit 0
    else
      @blockchain = read_lines(@input)
      @blocks = partition(blockchain)
      @balance = Hash.new(0)
    end
  end

  # Reads the line of the file
  def read_lines(data)
    blockchain_temp = IO.readlines(data)
    blockchain_temp
  end

  # Split up the data into blocks
  def partition(data)
    result = []
    i = 0
    while i < data.count
      block_partitions = data[i].split('|')
      result[i] = Block.new(
        block_partitions[0].to_i,
        block_partitions[1],
        block_partitions[2],
        block_partitions[3],
        block_partitions[4]
      )
      i += 1
    end
    result
  end

  # Checks if there are valid transactions, if not it will exit with a message.
  def check_valid_transactions
    transactions_split = []
    i = 0
    while i < @blocks.count
      # Splits and counts how many transactions there are in a block
      transactions_split = @blocks[i].transaction_string.split(':')
      j = 0
      while j < transactions_split.count
        @transactions = []
        # Splits transaction and saves its data
        transaction_partitions = transactions_split[j].split(/>|[()]/)
        @transactions[j] = Transaction.new(
          transaction_partitions[0],
          transaction_partitions[1],
          transaction_partitions[2].to_i
        )

        unless @transactions[j].from_addr.strip.eql? 'SYSTEM'
          @balance[@transactions[j].from_addr] -= @transactions[j].num_billcoins_sent
        end

        @balance[@transactions[j].to_addr] += @transactions[j].num_billcoins_sent

        if check_valid_format(@blocks[i], @transactions[j]) == false
          puts 'BLOCKCHAIN INVALID'
          exit 0
        end

        check_from_addr_length(@blocks[i], @transactions[j])
        check_to_addr_length(@blocks[i], @transactions[j])
        check_from_addr_invalid_char(@blocks[i], @transactions[j])
        check_to_addr_invalid_char(@blocks[i], @transactions[j])

        if i == @blocks.count - 1
          if j == transactions_split.count - 1
            unless @transactions[j].from_addr.strip.eql? 'SYSTEM'
              puts "Line #{@blocks[i].block_number}: the last transaction in #{@transactions[j]
              	.transaction_string} should be from SYSTEM."
              return false
            end
          end
        end
        j += 1
      end
      if check_balances(i) == false
        puts 'BLOCKCHAIN INVALID'
        exit 0
      end
      i += 1
    end
    true
  end

  # Checks if the from_addr is no more than 6 digits
  def check_from_addr_length(block, transaction)
    if transaction.from_addr.length != 6
      puts "Line #{block.block_number}: the from address #{transaction.from_addr} is too long."
      return false
    end
    true
  end

  # Checks if the to_addr is no more than 6 digits
  def check_to_addr_length(block, transaction)
    if transaction.to_addr.length != 6
      puts "Line #{block.block_number}: the to address #{transaction.to_addr} is too long."
      return false
    end
    true
  end

  # Checks if the from_addr does not contain an invalid character
  def check_from_addr_invalid_char(block, transaction)
    unless /[0-9]|[SYSTEM]/.match?(transaction.from_addr)
      puts "Line #{block.block_number}: the from address #{transaction.from_addr} contains an invalid character."
      return false
    end
    true
  end

  # Checks if the to_addr does not contain an invalid character
  def check_to_addr_invalid_char(block, transaction)
    unless /[0-9]|[SYSTEM]/.match?(transaction.to_addr)
      puts "Line #{block.block_number}: the to address #{transaction.to_addr} contains an invalid character."
      return false
    end
    true
  end

  # Check if the format is valid or not
  def check_valid_format(block, transaction)
    if transaction.from_addr.length != 6 && transaction.to_addr.nil?
      puts "Line #{block.block_number}: Could not parse transactions list '#{transaction.transaction_string}'"
      return false
    end
    true
  end

  # Checks to ensure there is not a negative balance at the end of the transactions
  def check_balances(num)
    @balance.each do |key, value|
      if value.negative?
        puts "Line #{@blocks[num].block_number}: Invalid block, address #{key} has #{value} billcoins!"
        return false
      end
    end
    true
  end

  # Checks to ensure the timestamps are correct
  def check_timestamps(block1, block2)
    timestamp_one_string = block1.timestamp_string.split('.')
    timestamp_two_string = block2.timestamp_string.split('.')

    timestamp_one_partition = timestamp_one_string.map(&:to_i)
    timestamp_two_partition = timestamp_two_string.map(&:to_i)

    if timestamp_two_partition[0] < timestamp_one_partition[0]
      puts "Line #{block2.block_number}: Previous timestamp #{block1.timestamp_string}
      	>= new timestamp #{block2.timestamp_string}"
      return false
    end

    if timestamp_two_partition[0] == timestamp_one_partition[0]
      if timestamp_two_partition[1] <= timestamp_one_partition[1]
        puts "Line #{block2.block_number}: Previous timestamp #{block1.timestamp_string}
        	 >= new timestamp #{block2.timestamp_string}"
        return false
      end
    end
    true
  end

  # Checks if the block number is valid or not
  def check_block_number(index_num, block)
    if index_num != block.block_number
      puts "Line #{index_num}: Invalid block number #{block.block_number}, should be #{index_num}"
      return false
    end
    true
  end

  # Checks if the hash is correct
  def check_hashes(block)
    correct = hash_block(block)
    unless correct.strip.eql? block.current_hash.strip
      puts "Line #{block.block_number}: String '#{block.block_number}|#{block.previous_hash}|
      	#{block.transaction_string}|#{block.timestamp_string}'
      	 hash set to #{block.current_hash.strip}, should be #{correct}"
      return false
    end
    true
  end

  # Checks if the previous hash is correct or not
  def check_previous_hashes(block1, block2)
    unless block2.previous_hash.strip.eql? block1.current_hash.strip
      puts "Line #{block2.block_number}: Previous hash was #{block2.previous_hash.strip},
      	should be #{block1.current_hash.strip}"
      return false
    end
    true
  end

  # Checks if the first hash is 0
  def check_previous_hash_zero(block)
    unless block.previous_hash.eql? '0'
      puts "Line #{block.block_number}: Previous hash was #{block.previous_hash.strip}, should be 0"
      return false
    end
    true
  end

  # Prints the results if everything checks out correctly, must be in ascending order
  def print_result
    @balance.sort.each do |key, value|
      puts "#{key}: #{value} billcoins" if value != 0
    end
  end

  def hash_block(block)
    string_to_hash = "#{block.block_number}|#{block.previous_hash}|#{block.transaction_string}
    	|#{block.timestamp_string}".unpack('U*')
    sum = 0
    string_to_hash.each do |x|
      sum += @hash_dict[x]
    end
    sum = sum % 65_536
    sum.to_s(16)
  end

  def convert_characters
    @hash_dict = Hash.new(0)
    all_character_string = '0123456789|>().abcdefghijklmnopqrstuvwxyz:SYTEM'.unpack('U*')
    all_character_string.each do |x|
      @hash_dict[x] = ((x**3000) + (x**x) - (3**x)) * (7**x)
    end
  end

  # Runs the program
  def run(args)
    read_data(args)
    convert_characters

    if check_valid_transactions == false
      puts 'BLOCKCHAIN INVALID'
      exit 0
    end

    if @blocks.count > 1
      i = 1
      while i < @blocks.count
        if check_timestamps(@blocks[i - 1], @blocks[i]) == false
          puts 'BLOCKCHAIN INVALID'
          exit 0
        end
        if check_previous_hashes(@blocks[i - 1], @blocks[i]) == false
          puts 'BLOCKCHAIN INVALID'
          exit 0
        end
        i += 1
      end
    end
    j = 0
    while j < @blocks.count
      if check_block_number(j, @blocks[j]) == false
        puts 'BLOCKCHAIN INVALID'
        exit 0
      end

      if check_hashes(@blocks[j]) == false
        puts 'BLOCKCHAIN INVALID'
        exit 0
      end
      j += 1
    end

    if check_previous_hash_zero(@blocks[0]) == false
      puts 'BLOCKCHAIN INVALID'
      exit 0
    end
    print_result
  end
end
