RSpec.describe Web::Controllers::Books::Index do
  Factory.define(:user, struct_namespace: Bookshelf::Entities) do |f|
    f.name 'Bob'
    f.created_at Time.now.utc
    f.updated_at Time.now.utc
  end

  Factory.define(:user_book, struct_namespace: Bookshelf::Entities) do |f|
    f.sequence(:user_id) { |n| n }
    f.sequence(:book_id) { |n| n }
    f.created_at Time.now.utc
    f.updated_at Time.now.utc

    f.trait :with_foobar do |t|
      f.association(:user)
    end
  end


  Factory.define(:book, struct_namespace: Bookshelf::Entities) do |f|
    f.title 'TDD'
    f.author "Kent Beck"
    f.created_at Time.now.utc
    f.updated_at Time.now.utc

    f.trait :with_users do |t|
      #f.association(:user_books, :with_foobar, count: 1)
      f.association(:users, count: 1)
    end
  end

  before do
    user = Factory[:user, name: 'Bob']
    book = Factory[:book, title: 'Bob', author: 'foo']
    user_book = Factory[:user_book, user_id: user.id, book_id: book.id]

    book_repo = Bookshelf::Repositories::BookRepository.new
    books_with_users = book_repo.books.combine(:users).first.users

    book2 = Factory.structs[:book, :with_users]
  end


  let!(:user) { Factory.structs[:user, name: 'Bob'] }
  let!(:book) { Factory.structs[:book, title: 'TDD', author: "Kent Beck"] }

  let(:action) { described_class.new }
  let(:params) { Hash[] }
  let(:repository) { Bookshelf::Repositories[:Book] }

  after do
    repository.clear
  end

  it "is successful" do
    response = action.call(params)
    expect(response[0]).to eq(200)
  end

  it "exposes all books" do
    action.call(params)
    expect(action.exposures[:books]).to eq([book])
  end
end
