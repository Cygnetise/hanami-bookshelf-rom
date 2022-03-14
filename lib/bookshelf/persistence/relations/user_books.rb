module Bookshelf
  module Persistence
    module Relations
      class UserBooks < ROM::Relation[:sql]
        schema(:user_books, infer: true) do

          associations do
            belongs_to :user
            belongs_to :book
          end
        end
      end
    end
  end
end
