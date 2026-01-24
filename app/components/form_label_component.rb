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
    has_errors? ? field_error_message : @field.to_s.humanize
  end

  def css
    # Tailwind CSS utility classes are used
    class_names(
      "form-label",
      {
        "text-danger": has_errors?
      }
    )
  end

  def field_error_message = @form.object.errors.full_messages_for(@field).first

  def has_errors? = @form.object.errors.full_messages_for(@field).any?
end
