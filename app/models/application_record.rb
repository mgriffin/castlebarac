# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Every change is posted to the site activity room (see SiteActivity),
  # except to these fields. Models add any of theirs that aren't worth it.
  class_attribute :site_activity_ignored_fields, default: %w[created_at updated_at]

  after_create_commit { SiteActivity.record(self, :create) }
  after_update_commit { SiteActivity.record(self, :update) }
  after_destroy_commit { SiteActivity.record(self, :destroy) }
end
