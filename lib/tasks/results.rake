# frozen_string_literal: true

namespace :results do
  desc "Link Results back to a Person object"
  task link: :environment do
    $stdin.set_encoding("UTF-8", invalid: :replace, undef: :replace)

    linker = ResultLinker.new
    linker.link_matches.each do |result|
      puts "Linked #{result.name} in #{result.race.name} to #{result.person.fullname}"
    end

    linker.unlinked.includes(:race).find_each do |result|
      puts "#{result.name} came #{result.position} in #{result.race.name}"
      if (person = Person.match(result.name))
        result.update!(person:)
        puts "Linked #{person.fullname}"
        next
      end

      puts "No matching person found, create one? y/n (y)"
      next if $stdin.gets.to_s.chomp.casecmp?("n")

      guess = Person.split_name(result.name)
      puts "What's their firstname? (#{guess[:firstname]})"
      firstname = $stdin.gets.to_s.chomp.presence || guess[:firstname]

      puts "What's their surname? (#{guess[:surname]})"
      surname = $stdin.gets.to_s.chomp.presence || guess[:surname]

      person = ResultLinker.link_to_new_person(result, firstname:, surname:)
      puts "Linked #{person.fullname}"
    end
  end
end
