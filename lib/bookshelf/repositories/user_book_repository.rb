require_relative 'repository'

module Bookshelf
  module Repositories
    class UserBookRepository < Repository[:user_books]
        struct_namespace Bookshelf::Entities
        commands :create
    end
  end
end
