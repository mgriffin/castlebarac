# frozen_string_literal: true

# Two forums were tried and dropped: one of our own (forums, topics and
# messages) and the Thredded gem. Their code is only on the forum and
# thredded branches, so the tables and anything in them go.
class DropForumTables < ActiveRecord::Migration[8.1]
  # Tables that other tables point to come after them
  TABLES = %i[
    messages topics forums
    thredded_user_post_notifications thredded_messageboard_users
    thredded_categories thredded_messageboard_groups thredded_messageboard_notifications_for_followed_topics
    thredded_messageboards thredded_notifications_for_followed_topics thredded_notifications_for_private_topics
    thredded_post_moderation_records thredded_posts thredded_private_posts thredded_private_topics
    thredded_private_users thredded_topic_categories thredded_topics thredded_user_details
    thredded_user_messageboard_preferences thredded_user_preferences thredded_user_private_topic_read_states
    thredded_user_topic_follows thredded_user_topic_read_states
  ].freeze

  def up
    TABLES.each { drop_table it, if_exists: true }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
