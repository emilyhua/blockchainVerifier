require 'simplecov'

SimpleCov.start

require 'minitest/autorun'
require_relative 'billcoin.rb'
require_relative 'block.rb'
require_relative 'transaction.rb'
# This tests the billcoin file
class BillcoinTest < Minitest::Test
  def test_transaction_is_transaction
    transaction = Transaction.new 'Albert', 'Emily', 1000
    assert transaction.is_a?(Transaction)
  end

  def test_transaction_is_transaction_only_sender
    transaction = Transaction.new 'Albert', ' ', 0
    assert transaction.is_a?(Transaction)
  end

  def test_block_is_block
    block = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    assert block.is_a?(Block)
  end

  def test_check_to_addr_length_valid
    block = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    transaction = Transaction.new 'SYSTEM', '569274', 100
    testclass = Billcoin.new 'sample.txt'
    assert_equal true, testclass.check_to_addr_length(block, transaction)
  end

  def test_to_addr_length_invalid
    block = Block.new 0, '0', 'SYSTEM>56927400000000(100)', '1553184699.650330000', '288d'
    transaction = Transaction.new 'SYSTEM', '56927400000000', 100
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_to_addr_length(block, transaction)
  end

  def test_to_addr_length_invalid_negative
    block = Block.new 0, '0', '-5>56927400000000(100)', '1553184699.650330000', '288d'
    transaction = Transaction.new '-5', '56927400000000', 100
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_to_addr_length(block, transaction)
  end

  def test_from_addr_length_valid
    block = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    transaction = Transaction.new 'SYSTEM', '569274', 100
    testclass = Billcoin.new 'sample.txt'
    assert_equal true, testclass.check_from_addr_invalid_char(block, transaction)
  end

  def test_from_addr_length_invalid
    block = Block.new 0, '0', 'SYSTEMCALL>569274(100)', '1553184699.650330000', '288d'
    transaction = Transaction.new 'SYSTEMCALL', '569274', 100
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_from_addr_length(block, transaction)
  end

  def test_check_to_addr_invalid_char
    block = Block.new 0, '0', 'SYSTEM>Albert(100)', '1553184699.650330000', '288d'
    transaction = Transaction.new 'SYSTEM', 'Albert', 100
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_to_addr_invalid_char(block, transaction)
  end

  def test_to_addr_valid_char
    block = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    transaction = Transaction.new 'SYSTEM', '569274', 100
    testclass = Billcoin.new 'sample.txt'
    assert_equal true, testclass.check_to_addr_invalid_char(block, transaction)
  end

  def test_check_valid_format
    block = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    transaction = Transaction.new 'SYSTEM', '569274', 100
    testclass = Billcoin.new 'sample.txt'
    assert_equal true, testclass.check_valid_format(block, transaction)
  end

  def test_check_invalid_format
    block = Block.new 0, '0', 'SYSTEMCALL>569274()', '1553184699.650330000', '288d'
    transaction = Transaction.new 'SYSTEMCALL', nil, 0
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_valid_format(block, transaction)
  end

  def test_check_invalid_format_string
    block = Block.new 0, '0', 'hellohowareyou', '1553184699.650330000', '288d'
    transaction = Transaction.new 'hellowhowareyou', nil, 0
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_valid_format(block, transaction)
  end

  def test_check_timestamps_valid
    block1 = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    block2 = Block.new 1, '288d', '569274>735567(12):735567>561180(3):735567>
    	689881(2):SYSTEM>532260(100)', '1553184699.652449000', '92a2'
    testclass = Billcoin.new 'sample.txt'
    assert_equal true, testclass.check_timestamps(block1, block2)
  end

  def test_check_timestamps_invalid
    block1 = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184700.650330000', '288d'
    block2 = Block.new 1, '288d', '569274>735567(12):735567>561180(3):735567>
    	689881(2):SYSTEM>532260(100)', '1553184700.650330000', '92a2'
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_timestamps(block1, block2)
  end

  def test_check_timestamps_invalid_again
    block1 = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184700.650330000', '288d'
    block2 = Block.new 1, '288d', '569274>735567(12):735567>561180(3):735567>
    	689881(2):SYSTEM>532260(100)', '1553184699.650330000', '92a2'
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_timestamps(block1, block2)
  end

  def test_check_previous_hashes_valid
    block1 = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    block2 = Block.new 1, '288d', '569274>735567(12):735567>561180(3):735567>
    	689881(2):SYSTEM>532260(100)', '1553184699.652449000', '92a2'
    testclass = Billcoin.new 'sample.txt'
    assert_equal true, testclass.check_previous_hashes(block1, block2)
  end

  def test_check_previous_hashes_invalid
    block1 = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    block2 = Block.new 1, '92a2', '569274>735567(12):735567>561180(3)
    	:735567>689881(2):SYSTEM>532260(100)', '1553184699.652449000', '92a2'
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_previous_hashes(block1, block2)
  end

  def test_check_previous_hash_zero_valid
    block = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    testclass = Billcoin.new 'sample.txt'
    assert_equal true, testclass.check_previous_hash_zero(block)
  end

  def test_check_previous_hash_zero_invalid
    block = Block.new 0, '3', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    testclass = Billcoin.new 'sample.txt'
    assert_equal false, testclass.check_previous_hash_zero(block)
  end

  def test_run_valid_args
    testclass = Billcoin.new 'sample.txt'
    assert true, testclass.run('sample.txt')
  end

  def test_run_invalid_args
    testclass = Billcoin.new 'sample.txt'
    assert_raises SystemCallError do
      testclass.run('lol.txt')
    end
  end

  def test_read_data
    testclass = Billcoin.new 'sample.txt'
    assert true, testclass.read_data('sample.txt')
  end

  def test_check_block_num
    testclass = Billcoin.new 'sample.txt'
    block1 = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    assert true, testclass.check_block_number(0, block1)
  end

  def test_check_block_num_invalid
    testclass = Billcoin.new 'sample.txt'
    block1 = Block.new 0, '0', 'SYSTEM>569274(100)', '1553184699.650330000', '288d'
    assert_equal false, testclass.check_block_number(5, block1)
  end
end
