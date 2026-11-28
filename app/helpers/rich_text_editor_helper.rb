# frozen_string_literal: true

# The rich text editor for posts, events and competitions. Its JavaScript and
# styles are only loaded on pages that have one. Lexxy is being tried out in
# place of rhino-editor for people with the lexxy flag on.
module RichTextEditorHelper
  def rich_text_editor(form, method)
    lexxy = Castlebarac.lexxy?(current_user)
    content_for(:editor, editor_assets(lexxy ? "editor_lexxy" : "editor_rhino")) unless content_for?(:editor)

    lexxy ? form.lexxy_rich_text_area(method) : rhino_editor(form, method)
  end

  private

  def editor_assets(name)
    stylesheet_link_tag(name) + javascript_include_tag(name, type: "module")
  end

  def rhino_editor(form, method)
    id = form.field_id(method)

    form.hidden_field(method, id:, value: form.object.public_send(method).try(:to_trix_html)) +
      tag.rhino_editor(input: id, data: { blob_url_template: rails_service_blob_url(":signed_id", ":filename"),
                                          direct_upload_url: rails_direct_uploads_url })
  end
end
