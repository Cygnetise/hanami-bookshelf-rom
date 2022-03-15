module Bookshelf
  module Persistence
    module Relations
      class Organisations < ROM::Relation[:sql]
        schema(:organisations, infer: true) do
          associations do
            has_many :users
          end
        end
      end
    end
  end
end
