module Bookshelf
  module Persistence
    module Relations
      class Users < ROM::Relation[:sql]
        schema(:users, infer: true) do

          associations do
            has_many :user_books
            has_many :books, through: :user_books
            belongs_to :organisation
          end
        end
      end
    end
  end
end
