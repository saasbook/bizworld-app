class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :name
      t.integer :age
      t.string :gender
      t.string :ethnicity

      t.timestamps
    end
  end
end