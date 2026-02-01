# frozen_string_literal: true

class FormLabelComponent < ViewComponent::Base
  def initialize(form:, field:)
    @form = form
    @field = field
  end

  erb_template <<-ERB
    <%= @form.label @field, label_value, class: css %>
  ERB

  private

  def label_value
    errors? ? field_error_message : @field.to_s.humanize
  end

  def css
    # Tailwind CSS utility classes are used
    class_names(
      "form-label",
      {
        "text-danger": errors?
      }
    )
  end

  def field_error_message
    @form.object.errors.full_messages_for(@field).first
  end

  def errors?
    @form.object.errors.full_messages_for(@field).any?
  end
end
