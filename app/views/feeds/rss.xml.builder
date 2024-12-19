# frozen_string_literal: true

xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "Castlebar Athletic Club"
    xml.description "News from the club"
    xml.link href: rss_url, rel: "self"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.content.to_s, type: "html"
        xml.pubDate post.created_at.xmlschema
        xml.link post_url post
        xml.guid post_url post
      end
    end
  end
end
