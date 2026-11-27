# frozen_string_literal: true

require "test_helper"

# Posts, events and competitions are written with rhino-editor, which is only
# loaded on pages with one.
class RichTextEditorTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @post = posts(:one)
    @post.update!(content: "<p>Training is <strong>on</strong></p><hr>")
  end

  test "has the post's content in the editor, and loads it" do
    get edit_admin_post_url(@post)

    input = css_select("input[type=hidden][name='post[content]']").first
    assert_includes input["value"], "<strong>on</strong>"
    assert_select "rhino-editor[input=?]", input["id"]
    assert_select "rhino-editor[data-direct-upload-url][data-blob-url-template]"
    assert_select "head script[src*=?]", "editor_rhino"
    assert_select "head link[href*=?]", "editor_rhino"
  end

  test "every form with rich text has the editor" do
    Flipper.enable("comp-entries")

    [new_admin_post_url, new_admin_event_url, new_admin_competition_url, new_post_url, new_event_url].each do |url|
      get url

      assert_select "rhino-editor", 1, "on #{url}"
      assert_select "head script[src*=?]", "editor_rhino", 1, "on #{url}"
    end
  end

  test "pages without a form don't load the editor" do
    [root_url, posts_url, post_url(@post)].each do |url|
      get url

      assert_select "head script[src*=?]", "editor_", false, "on #{url}"
      assert_select "head link[href*=?]", "editor_", false, "on #{url}"
    end
  end

  test "saving from the editor keeps the content" do
    content = "<p>Moved to <em>Thursday</em></p><hr>"

    patch admin_post_url(@post), params: { post: { title: @post.title, content: } }

    assert_includes @post.reload.content.body.to_html, "<em>Thursday</em>"
    assert_includes @post.content.body.to_html, "<hr>"
  end
end
