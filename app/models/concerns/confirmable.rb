# For relationships that must be confirmed by two or more parties.
#
# To include this Concern, expose a `roles` class instance variable that lists
# all members of this relationship:
#
# include Confirmable
# cattr_reader :roles, instance_reader: false do [:admin, :member] end
module Confirmable
  extend ActiveSupport::Concern

  def confirmed?
    roles.none? { |role| self.send("pending_#{role}_conf?") }
  end

  def confirm!(pending: :none)
    pending =* pending                             # coerce `pending` to Array
    pend, conf = roles.partition { |role| pending.include?(role) }
                   .map { |list| list.map { |k| "pending_#{k}_conf".to_sym } }
    update_attributes(Hash[conf.product([false]) + pend.product([true])])
  end

  private

    def roles
      self.class.roles
    end
end
