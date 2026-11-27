# frozen_string_literal: true

class ResultComponent < ViewComponent::Base
  include Pundit::Authorization

  attr_reader :result

  def initialize(result:, user:)
    @result = result
    @user = user
  end

  def name
    if render_link?
      link_to result.name, person_path(result.person)
    else
      result.name
    end
  end

  def edit_name
    return unless render_edit_link?

    link_to edit_admin_result_path(result) do
      helpers.inline_svg_tag "pencil.svg"
    end
  end

  def render_link?
    @render_link ||= result.person && policy(result).view_person?
  end

  def render_edit_link?
    @render_edit_link ||= result.castlebarac? && policy([:admin, result]).edit?
  end

  private

  # Who Pundit checks the policies for
  def pundit_user
    @user
  end
end
