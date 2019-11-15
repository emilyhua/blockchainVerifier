# Emily Hua (ewh13)
class Block
  attr_accessor :block_number, :previous_hash, :transaction_string, :timestamp_string, :current_hash

  def initialize(block_number, previous_hash, transaction_string, timestamp_string, current_hash)
    @block_number = block_number
    @previous_hash = previous_hash
    @transaction_string = transaction_string
    @timestamp_string = timestamp_string
    @current_hash = current_hash
  end
end
