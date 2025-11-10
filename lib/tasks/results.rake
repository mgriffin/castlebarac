namespace :results do
  desc "Link Results back to a Person object"
  task link: :environment do
    STDIN.set_encoding("UTF-8", invalid: :replace, undef: :replace)

    Result.not_linked.each do |unlinked_result|
      puts "#{unlinked_result.name} came #{unlinked_result.position} in #{unlinked_result.race.name}"
      if p = Person.match(unlinked_result.name)
        unlinked_result.person = p
        unlinked_result.save

        puts "Linked #{p.fullname}"
      else
        puts "No matching person found, create one? y/n (y)"
        answer = STDIN.gets.chomp
        next if answer.downcase == "n"

        puts "What's their firstname?"
        firstname = STDIN.gets.chomp

        puts "What's their surname?"
        surname = STDIN.gets.chomp

        p = Person.create!(firstname:, surname:)
        unlinked_result.person = p
        unlinked_result.save

        puts "Linked #{p.fullname}"
      end
    end
  end

end
