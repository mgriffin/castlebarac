# frozen_string_literal: true

# Links an account to a person, for admins. People are never linked to
# accounts by name, as anyone can type a name.
module AccountLinker
  # If the account already has a person of its own, e.g. one they made before
  # an admin linked them, it's deleted when it's unused. Otherwise nothing
  # changes and this raises ActiveRecord::RecordInvalid with the reason on the
  # person.
  def self.link!(person, user)
    person.transaction do
      person.reload
      return person if person.user_id == user.id

      own = Person.find_by(user:)
      if person.user_id
        person.errors.add(:base, :linked_to_someone_else, name: person.fullname)
      elsif own && !own.unused?
        person.errors.add(:base, :account_has_a_person, email: user.email, name: own.fullname)
      end
      raise ActiveRecord::RecordInvalid, person if person.errors.any?

      own&.destroy!
      person.update!(user:)
    end
  end
end
