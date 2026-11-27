# frozen_string_literal: true

# The rich text editor for posts, events and competitions. Its JavaScript and
# styles are only loaded on pages that have one.
module RichTextEditorHelper
  def rich_text_editor(form, method)
    content_for(:editor, editor_assets("editor_rhino")) unless content_for?(:editor)

    rhino_editor(form, method)
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
