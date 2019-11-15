# Emily Hua (ewh13)
class Transaction
  attr_accessor :from_addr, :to_addr, :num_billcoins_sent, :transaction_string

  def initialize(from_addr, to_addr, num_billcoins_sent)
    @from_addr = from_addr
    @to_addr = to_addr
    @num_billcoins_sent = num_billcoins_sent
    @transaction_string = if to_addr.nil? && num_billcoins_sent.zero?
                            from_addr.to_s
                          else
                            "#{from_addr}>#{to_addr}(#{num_billcoins_sent})"
                          end
  end
end
