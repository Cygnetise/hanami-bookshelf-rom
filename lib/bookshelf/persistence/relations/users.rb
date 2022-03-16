module Bookshelf
  module Persistence
    module Relations
      class Users < ROM::Relation[:sql]
        schema(:users, infer: true) do

          associations do
            has_many :user_books, combine_key: :user_id, foreign_key: :user_id
            has_many :books, through: :user_books, combine_key: :book_id
            belongs_to :organisation
          end
        end
      end
    end
  end
end
