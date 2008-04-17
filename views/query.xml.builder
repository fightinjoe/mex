xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.rss "version" => "2.0" do
  xml.channel do
    xml.title "Recent Exceptions#{%( (filtered)) if filtered?} | #{ Merb::Config[:app_name] }"
    xml.link url(:query_rss)
    xml.language "en-us"
    xml.ttl "60"

    @exceptions.page(0).each { |exc|
        str = "%s in %s @ $s" % [exc.exception_class, exc.controller_action, to_rfc822(exc.created_at) ]
      xml.item {
        xml.title str
        xml.description exc.message
        xml.pubDate to_rfc822(exc.created_at)
        xml.guid ['exceptions', exc.id.to_s].join(":"), "isPermaLink" => "false"
        xml.link absolute_url(:axe, exc)
      }
    }
  end
end
