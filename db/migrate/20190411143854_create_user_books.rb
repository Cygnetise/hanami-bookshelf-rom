ROM::SQL.migration do
  change do
    create_table :user_books do
      primary_key :id

      column :user_id, Integer, null: false
      column :book_id, Integer, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
