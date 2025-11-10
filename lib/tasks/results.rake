# frozen_string_literal: true

namespace :results do
  desc "Link Results back to a Person object"
  task link: :environment do
    $stdin.set_encoding("UTF-8", invalid: :replace, undef: :replace)

    Result.not_linked.each do |unlinked_result|
      puts "#{unlinked_result.name} came #{unlinked_result.position} in #{unlinked_result.race.name}"
      unless (p = Person.match(unlinked_result.name))
        puts "No matching person found, create one? y/n (y)"
        answer = $stdin.gets.chomp
        next if answer.downcase == "n"

        puts "What's their firstname?"
        firstname = $stdin.gets.chomp

        puts "What's their surname?"
        surname = $stdin.gets.chomp

        p = Person.create!(firstname:, surname:)

      end
      unlinked_result.person = p
      unlinked_result.save
      puts "Linked #{p.fullname}"
    end
  end
end
