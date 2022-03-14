RSpec.describe Web::Controllers::Books::Index do
  FactoryBot.define do


    factory :user, class: 'Bookshelf::Entities::User' do
      sequence(:id) { |n| n }
      name { "John" }
      created_at { Time.now.utc }
      updated_at { Time.now.utc }
      add_attribute(:user_books) {  [ attributes_for(:user_book, user_id: id) ] }

      trait :with_books do
        add_attribute(:books) { [attributes_for(:book)] }

        after(:build, :create) do |user, evaluator|
          strategy = evaluator.instance_variable_get(:@build_strategy).class.to_s.split("::").last.downcase
          evaluator.association(:user_book, user_id:  user.id, book_id: evaluator.books.first[:id], strategy: strategy)
        end

        initialize_with do
          attrs = attributes.merge(books: books.map { |b| b.merge(user_id: attributes[:id]) } )
          Bookshelf::Repositories::UserRepository.new.users.combine(:books).mapper.model.new(attrs)
        end

        to_create do |instance, evaluator|
        evaluator.binding.pry
          evaluator.create(:book, evaluator.books.first)
          Bookshelf::Repositories::UserRepository.new.users.combine(:books).one
        end
      end

      initialize_with do
        attrs = attributes.merge(user_books: user_books)
        Bookshelf::Repositories::UserRepository.new.users.combine(:user_books).mapper.model.new(attrs)
      end

      to_create do |instance, evaluator|
        attrs = evaluator.attributes.merge(user_books: evaluator.user_books)
        Bookshelf::Repositories::UserRepository.new.users.combine(:user_books).command(:create).call(attrs)
      end
    end

    factory :user_book, class: 'Bookshelf::Entities::UserBook' do
      sequence(:id) { |n| n }
      user_id { user.id }
      book_id { book.id }
      created_at { Time.now.utc }
      updated_at { Time.now.utc }

      transient do
        user { build(:user) }
        book { build(:book) }
      end

      initialize_with do
        Bookshelf::Repositories::UserBookRepository.new.user_books.mapper.model.new(attributes)
      end

      to_create do |instance, evaluator|
        attrs = evaluator.attributes
        evaluator.binding.pry
        Bookshelf::Repositories::UserBookRepository.new.user_books.command(:create).call(attrs)
      end
    end

    factory :book, class: 'Bookshelf::Entities::Book' do
      sequence(:id) { |n| n }
      title { "John" }
      author { "Kelly" }
      created_at { Time.now.utc }
      updated_at { Time.now.utc }
    end

    initialize_with do
      Bookshelf::Repositories::BookRepository.new.books.mapper.model.new(attributes)
    end

    to_create do |instance, evaluator|
      attrs = evaluator.attributes
      Bookshelf::Repositories::BookRepository.new.books.command(:create).call(attrs)
    end
  end

  before do
    user_book_repository.clear
    user_repository.clear
    book_repository.clear
  end

  before do
    user = FactoryBot.build(:user, :with_books)
    user = FactoryBot.create(:user, :with_books)
    binding.pry
  end

  let(:book_repository) { Bookshelf::Repositories[:Book] }
  let(:user_book_repository) { Bookshelf::Repositories[:UserBook] }
  let(:user_repository) { Bookshelf::Repositories[:User] }

  after do
    user_book_repository.clear
    user_repository.clear
    book_repository.clear
  end

  it "exposes all books" do
  end
end
