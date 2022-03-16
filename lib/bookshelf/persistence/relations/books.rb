module Bookshelf
  module Persistence
    module Relations
      class Books < ROM::Relation[:sql]
        schema(:books, infer: true) do
          associations do
            has_many :user_books
            has_many :users, through: :user_books
          end
        end
      end
    end
  end
end
