# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Convert snake_case keys in .jbuilder files to camelCase
Jbuilder.key_format camelize: :lower
