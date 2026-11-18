# frozen_string_literal: true

Flipper.register(:admins) do |actor, _context|
  actor.respond_to?(:admin?) && actor.admin?
end

Flipper.register(:coaches) do |actor, _context|
  actor.respond_to?(:coach?) && actor.coach?
end

Flipper.register(:committee) do |actor, _context|
  actor.respond_to?(:committee?) && actor.committee?
end
