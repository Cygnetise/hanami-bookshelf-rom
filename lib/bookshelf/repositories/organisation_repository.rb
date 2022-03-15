require_relative 'repository'

module Bookshelf
  module Repositories
    class OrganisationRepository < Repository[:organisations]
        struct_namespace Bookshelf::Entities
        commands :create
    end
  end
end
