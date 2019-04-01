module NewsApps
  module Core
    class RssManager

      CONTENT_MAX_LENGTH = 800

      def self.download_pages_links app
        rss = read_rss app.rss_uri
        parse_rss(rss).entries
                      .map do |rss_entry|
                        {
                          title: rss_entry.title,
                          url: rss_entry.url
                        }
                      end
      end

      def self.read_rss uri
        response = Net::HTTP.get_response(URI(uri))
        response.value
        response.body
        # raise response.class unless response.is_a?(Net::HTTPSuccess)        
      end

      def self.parse_rss xml
        Feedjira::Feed.parse(xml)
      end

      def self.extract_news_from_feed app, options = {}
        logger = options[:logger]

        xml = read_rss app.rss_uri
        app_conf = NewsApps::Core::Config.load_for_app app, logger: logger

        xml_preprocessor = lookup_xml_preprocessor app_conf if app_conf
        logger.info "XML preprocessor: #{xml_preprocessor}" if xml_preprocessor && logger
        xml = xml_preprocessor.run(xml) if xml_preprocessor

        content_provider = lookup_content_provider app_conf if app_conf
        logger.info "Content provider: #{content_provider}" if content_provider && logger

        rss_item_custom_fields_provider = lookup_rss_item_custom_fields_provider app_conf, logger if app_conf
        logger.info "RSS-item custom fields provider: #{rss_item_custom_fields_provider}" if rss_item_custom_fields_provider && logger

        append_parsed_rss_fields app_conf, logger if app_conf
        append_default_custom_rss_fields logger
        append_custom_rss_fields app_conf, logger if app_conf
        
        rss = Feedjira::Feed.parse(xml)
        rss.entries.map do |rss_entry|
          content = content_provider ? content_provider.run(rss_entry) : rss_entry.content 
          content = adopt_content content if content

          custom_rss_fields = {}

          attrs = NewsApps::Core::CustomRssFieldsDefaultProvider.run(rss_entry)
          custom_rss_fields.update attrs unless attrs.blank?

          if rss_item_custom_fields_provider
            custom_attrs = rss_item_custom_fields_provider.run(rss_entry)
            custom_rss_fields.update custom_attrs unless custom_attrs.blank?
          end

          fields = {
            url: rss_entry.url,
            author: rss_entry.author,
            published: rss_entry.published,
            title: rss_entry.title,
            summary: rss_entry.summary,
            content: content
          }

          fields[:rss_item_custom_fields] = custom_rss_fields unless custom_rss_fields.empty?
          fields
        end
      end

      def self.adopt_content content 
        _content = content.strip_tags[0...CONTENT_MAX_LENGTH]
        _content.strip!
        _content
      end

      def self.lookup_content_provider conf
        provider = conf['rss_item_content_provider']
        provider.constantize if provider
      end

      def self.lookup_xml_preprocessor conf
        provider = conf['xml_preprocessor']
        provider.constantize if provider
      end

      def self.append_parsed_rss_fields conf, logger
        fields = conf['rss_entity_tag_to_field']
        if fields
          fields.each do |f|
            logger.info "ADDING MAPPING: #{f.fetch('tag')} => #{f.fetch('field')}" if logger
            Feedjira::Feed.add_common_feed_entry_element f.fetch('tag'), as: f.fetch('field')
          end
        end
      end

      def self.lookup_rss_item_custom_fields_provider conf, logger
        section = conf['rss_item_custom_fields']
        if section
          provider = section['provider']
          provider.constantize if provider 
        end
      end

      def self.append_custom_rss_fields conf, logger
        section = conf['rss_item_custom_fields']
        if section
          fields = section['rss_entity_tag_to_field']
          if fields
            fields.each do |f|
              opts = {
                as: f.fetch('field')
              }
              
              value = f['value']
              opts[:value] = value if value.present?

              tag = f.fetch('tag')

              logger.info "ADDING CUSTOM FIELDS MAPPING for #{tag} => #{opts}" if logger
              Feedjira::Feed.add_common_feed_entry_element tag, opts
            end
          end
        end
      end

      def self.append_default_custom_rss_fields logger
        Feedjira::Feed.add_common_feed_entry_element 'comments', as: 'comments'
      end
    end
  end
end


