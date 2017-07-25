# For relationships that must be confirmed by two or more parties.
#
# To include this Concern, define a `confirmers` class instance variable that
# lists all members of this relationship:
#
# include Confirmable
# cattr_reader :confirmers, instance_reader: false do [:admin, :member] end
module Confirmable
  extend ActiveSupport::Concern

  def confirmed?
    confirmers.none? { |role| self.send("pending_#{role}_conf?") }
  end

  def confirm!(pending: :none)
    pending =* pending                             # coerce `pending` to Array
    pend, conf = confirmers.partition { |role| pending.include?(role) }
                   .map { |list| list.map { |k| "pending_#{k}_conf".to_sym } }
    update_attributes(Hash[conf.product([false]) + pend.product([true])])
  end

  private

    def confirmers
      self.class.confirmers
    end
end
