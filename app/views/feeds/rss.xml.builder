# frozen_string_literal: true

xml.instruct!
xml.rss :version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.id root_url
  xml.title "Castlebar Athletic Club"
  xml.description "News from the club"
  xml.link href: "/rss", rel: "self"
  xml.updated @posts.first.created_at.xmlschema
  xml.language "en"

  @posts.each do |post|
    xml.entry do
      xml.id post_url(post)
      xml.title post.title
      xml.updated post.created_at.xmlschema
      xml.link post_url post
      xml.content post.content.to_s, type: "html"
    end
  end
end
