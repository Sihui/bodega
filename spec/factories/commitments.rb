FactoryGirl.define do
  factory :commitment do |f|
    user
    company
    pending_admin_conf  true
    pending_member_conf true
  end
end
