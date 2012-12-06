class Users < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :username
      t.text :description

      t.timestamps
    end
  end
end