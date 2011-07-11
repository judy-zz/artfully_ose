module ACH
  class Transaction
    include ACH::Serialization

    attr_accessor :effective_date, :amount, :memo

    def initialize(amount, memo)
      self.amount         = "%0.2f" % (amount / 100.00)
      self.memo           = memo
      self.effective_date = DateTime.now.strftime("%m/%d/%y")
    end

    MAPPING = {
      :type           => "Transaction_Type",
      :effective_date => "Effective_Date",
      :amount         => "Amount_per_Transaction",
      :check_number   => "Check_No",
      :secc_type      => "SECCType",
      :memo           => "Memo",
      :frequency      => "Frequency",
      :count          => "Number_of_Payments"
    }.freeze

    def type;         :Credit;  end
    def frequency;    :Once;    end
    def count;        1;       end
    def check_number; nil;      end
    def secc_type;    :PPD;     end
  end
end