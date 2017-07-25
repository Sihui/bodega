# Allows direct use of FactoryGirl class methods without `FactoryGirl.` prefix.
# per http://www.rubydoc.info/gems/factory_girl/file/GETTING_STARTED.md

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
