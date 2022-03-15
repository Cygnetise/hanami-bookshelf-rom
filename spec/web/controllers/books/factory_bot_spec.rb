RSpec.describe Web::Controllers::Books::Index do
  FactoryBot.define do
    factory :organisation, class: 'Bookshelf::Entities::Organisation' do
      sequence(:id) { |n| n }
      name { "TTT" }
      created_at { Time.now.utc }
      updated_at { Time.now.utc }

      initialize_with do
        p 'initialize organisation'
        Bookshelf::Repositories::OrganisationRepository.new.organisations.mapper.model.new(attributes)
      end

      to_create do |instance, evaluator|
        evaluator.p "create organisation"
        attrs = evaluator.attributes
        Bookshelf::Repositories::OrganisationRepository.new.organisations.command(:create).call(attrs)
      end
    end

    factory :user, class: 'Bookshelf::Entities::User' do
      sequence(:id) { |n| n }
      name { "John" }
      created_at { Time.now.utc }
      updated_at { Time.now.utc }
      organisation_id { organisation.id }

      transient do
        organisation { association(:organisation) }
        assocs { {} }
      end

      initialize_with do
        p 'initialize user'
        Bookshelf::Repositories::UserRepository.new.users.mapper.model.new(attributes)
      end

      to_create do |instance, evaluator|
        attrs = evaluator.attributes
        evaluator.p "create user: #{attrs}"
        Bookshelf::Repositories::UserRepository.new.users.command(:create).call(attrs)
      end

      trait :with_organisation do
        initialize_with do
          assocs[:organisation] = organisation
          attrs = attributes.merge(assocs)
          p "initialize with organisation: #{attrs}, assocs: #{assocs}"
          combine_keys = attrs.keys & Bookshelf::Repositories::UserRepository.new.users.associations.to_h.keys
          Bookshelf::Repositories::UserRepository.new.users.combine(*assocs.keys).mapper.model.new(attrs)
        end
      end

      trait :with_books do
        books { [book] }

        transient do
          book { association(:book) }
        end

        initialize_with do
          books.each do |book|
            assocs[:user_books] ||= [] << association(:user_book, book_id: book.id, user_id: attributes[:id])
            assocs[:books] ||=[] << attributes_for(:book, user_id: attributes[:id])
          end
          attrs = attributes.merge(assocs)
          # attrs = attributes.merge(books: books.map { |b| b.to_h.merge(user_id: attributes[:id]) } )
          p "initialize with books: #{attrs}, assocs: #{assocs}"
          Bookshelf::Repositories::UserRepository.new.users.combine(*assocs.keys).mapper.model.new(attrs)
        end

        to_create do |instance, evaluator|
          evaluator.p 'create with books'
          attrs = evaluator.attributes
          Bookshelf::Repositories::UserRepository.new.users.command(:create).call(attrs)
        end
      end
    end

    factory :book, class: 'Bookshelf::Entities::Book' do
      sequence(:id) { |n| n }
      title { "John" }
      author { "Kelly" }
      created_at { Time.now.utc }
      updated_at { Time.now.utc }

      initialize_with do
        p 'initialize book'
        Bookshelf::Repositories::BookRepository.new.books.mapper.model.new(attributes)
      end

      to_create do |instance, evaluator|
        evaluator.p 'create book'
        attrs = evaluator.attributes
        Bookshelf::Repositories::BookRepository.new.books.command(:create).call(attrs)
      end
    end

    factory :user_book, class: 'Bookshelf::Entities::UserBook' do
      sequence(:id) { |n| n }
      user_id { user.id }
      book_id { book.id }
      created_at { Time.now.utc }
      updated_at { Time.now.utc }

      transient do
        user { association(:user) }
        book { association(:book) }
        # user { build(:user) }
        # book { build(:book) }
      end

      initialize_with do
        p 'initialize user_book'
        Bookshelf::Repositories::UserBookRepository.new.user_books.mapper.model.new(attributes)
      end

      to_create do |instance, evaluator|
        evaluator.p 'create user_book'
        attrs = evaluator.attributes
        Bookshelf::Repositories::UserBookRepository.new.user_books.command(:create).call(attrs)
      end
    end
  end

  let(:book_repository) { Bookshelf::Repositories[:Book] }
  let(:user_book_repository) { Bookshelf::Repositories[:UserBook] }
  let(:user_repository) { Bookshelf::Repositories[:User] }
  let(:organisation_repository) { Bookshelf::Repositories[:Organisation] }

  before do
    user_book_repository.clear
    user_repository.clear
    book_repository.clear
    organisation_repository.clear
  end

  after do
    user_book_repository.clear
    user_repository.clear
    book_repository.clear
    organisation_repository.clear
  end

  context "plain user" do
    it "build" do
      build_user = FactoryBot.build(:user)
      expect(build_user).to be_a(Bookshelf::Entities::User)
    end

    it "create" do
      expect { FactoryBot.create(:user) }
        .to change { user_repository.users.count }.from(0).to(1)
        .and change { organisation_repository.organisations.count }.from(0).to(1)
      expect(user_book_repository.user_books.count).to eq(0)
      expect(user_book_repository.books.count).to eq(0)

      user = user_repository.users.combine(:books, :organisation).first
      organisation = organisation_repository.organisations.first
      expect(user).to be_a(Bookshelf::Entities::User)
      expect(user.organisation.to_h).to eq(organisation.to_h)
      expect(user.books).to be_empty
    end
  end

  context "with books" do
    it "build" do
      build_user = FactoryBot.build(:user, :with_books)
      expect(build_user).to be_a(Bookshelf::Entities::User)

      expect(build_user.organisation_id).to be_a(Integer)
      expect(build_user.books).to_not be_empty
      expect(build_user).to_not respond_to(:organisation)
      expect(build_user.books[0]).to be_a(Bookshelf::Entities::Book)
    end

    it "create" do
      expect { FactoryBot.create(:user, :with_books) }
        .to change { user_repository.users.count }.from(0).to(1)
        .and change { organisation_repository.organisations.count }.from(0).to(1)
        .and change { user_book_repository.user_books.count }.from(0).to(1)
        .and change { book_repository.books.count }.from(0).to(1)

      user = user_repository.users.combine(:books).first
      expect(user).to be_a(Bookshelf::Entities::User)

      expect(user.books).to_not be_empty

      expect(user.organisation_id).to be_a(Integer)
      expect(user).to_not respond_to(:organisation)
    end
  end

  context "with books and organisation" do
    it "build" do
      build_user = FactoryBot.build(:user, :with_books, :with_organisation)
      expect(build_user).to be_a(Bookshelf::Entities::User)

      expect(build_user.organisation_id).to be_a(Integer)
      expect(build_user.organisation).to be_a(Bookshelf::Entities::Organisation)

      expect(build_user.books).to_not be_empty
      expect(build_user.books[0]).to be_a(Bookshelf::Entities::Book)
    end

    it "create" do
      expect { FactoryBot.create(:user, :with_books) }
        .to change { user_repository.users.count }.from(0).to(1)
        .and change { organisation_repository.organisations.count }.from(0).to(1)
        .and change { user_book_repository.user_books.count }.from(0).to(1)
        .and change { book_repository.books.count }.from(0).to(1)

      user = user_repository.users.combine(:books).first
      expect(user).to be_a(Bookshelf::Entities::User)

      expect(user.books).to_not be_empty

      expect(user.organisation_id).to be_a(Integer)
      expect(user.organisation).to be_a(Bookshelf::Entities::Organisation)
    end
  end
end
