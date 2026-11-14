# frozen_string_literal: true

# People with the same name used to get the same slug, so only the first of
# them could be found by it. The oldest keeps the slug, so its pages don't
# move, and the others get "-2", "-3" and so on, as Person#create_slug now
# does.
class AddUniqueIndexToPeopleSlug < ActiveRecord::Migration[8.1]
  class Person < ActiveRecord::Base
    self.table_name = "people"
  end

  def up
    Person.where.not(slug: nil).group(:slug).having("COUNT(*) > 1").pluck(:slug).each do |slug|
      Person.where(slug:).order(:id).drop(1).each do |person|
        count = 2
        count += 1 while Person.exists?(slug: "#{slug}-#{count}")
        person.update!(slug: "#{slug}-#{count}")
      end
    end

    add_index :people, :slug, unique: true
  end

  def down
    remove_index :people, :slug
  end
end
