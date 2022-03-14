require_relative 'repository'

module Bookshelf
  module Repositories
    class UserRepository < Repository[:users]
        struct_namespace Bookshelf::Entities
        commands :create
    end
  end
end
