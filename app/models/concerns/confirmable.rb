# For relationships that must be confirmed by two or more parties.
#
# By default, this module uses its including Class’s associated models as the
# confirming parties. To override this default, expose a class instance
# variable attr_reader named `confirmers` that lists the confirming parties:
#
# include Confirmable
# cattr_reader :confirmers, instance_reader: false do [:admin, :member] end
module Confirmable
  extend ActiveSupport::Concern

  def confirmed?
    confirmers.none? { |confirmer| self.send("pending_#{confirmer}_conf?") }
  end

  def confirm!(pending: :none)
    pending =* pending                             # coerce `pending` to Array
    pend, conf = confirmers.partition { |confirmer| pending.include?(confirmer) }
                   .map { |list| list.map { |k| "pending_#{k}_conf".to_sym } }
    update(Hash[conf.product([false]) + pend.product([true])])
  end

  module ClassMethods
    def confirmers
      reflect_on_all_associations.map(&:name).compact
    end
  end

  private

    def confirmers
      self.class.confirmers
    end
end
