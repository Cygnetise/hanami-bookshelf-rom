require_relative 'repository'

module Bookshelf
  module Repositories
    class BookRepository < Repository[:books]
        struct_namespace Bookshelf::Entities
        commands :create
    end
  end
end
