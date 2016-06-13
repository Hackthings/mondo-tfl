class Journey < ActiveRecord::Base
  belongs_to :user
  belongs_to :card

  scope :unmatched, -> {where(mondo_transaction_id: nil)}

  def fare
    Money.new(self[:fare], :gbp)
  end
end
