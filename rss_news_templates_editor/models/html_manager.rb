module NewsApps
  module Core
    class HtmlManager
      def self.download_page app, page_url, rules = nil
        html = Net::HTTP.get_response(URI(page_url))
                        .body
                        .force_encoding(Encoding::UTF_8)
        doc = Nokogiri::HTML(html)

        #files manager
        shared_dir = FilesManager.shared_app_dir app
        FileUtils.mkdir_p shared_dir

        new_local_resources_url_prefix = "#{Figaro.env.news_apps_url}/#{app.identifier}/shared"
        uri = URI(page_url)
        source_domain = uri.host

        xpathChain = XpathOperations::Chain.new 
                                           .add(XpathOperations::Nokogiri::LinksHostAppender.new(doc, source_domain))
                                           .add(XpathOperations::Nokogiri::ScriptsBodyRemover.new(doc))
                                           .add(XpathOperations::Nokogiri::StyleUrlReplacer.new(doc, source_domain))
                                           .add(XpathOperations::Nokogiri::ViewportScaleAppender.new(doc))
        css_downloads = []

        if rules
          rules.each do |r|
            processor = nil

            case r['operator_type']
            when TransformationRule::OPERATOR_TYPE_XPATH
              case r['operator']
              when TransformationRule::OPERATOR_XPATH_REMOVE_NODE_BY_SELECTOR
                processor = XpathOperations::Nokogiri::NodesRemover.new(doc, r['rule'])
              when TransformationRule::OPERATOR_XPATH_REMOVE_NODE_CLICKABILITY
                processor = XpathOperations::Nokogiri::ClickabilityDisabler.new(doc, r['rule'])
              end 
            when TransformationRule::OPERATOR_TYPE_DOWNLOAD
              case r['operator']
              when TransformationRule::OPERATOR_TYPE_FILE_DOWNLOAD_CSS
                css_downloads << r.fetch('rule')
              end
            when TransformationRule::OPERATOR_TYPE_APPEND
              case r['operator']
              when TransformationRule::OPERATOR_TYPE_APPEND_PLAIN_CSS
                processor = XpathOperations::Nokogiri::StyleAppender.new(doc, r['rule'])
              end
            end

            xpathChain.add processor if processor
          end
        end

        xpathChain.add(XpathOperations::Nokogiri::HostCssDownloader.new(doc, source_domain, new_local_resources_url_prefix, shared_dir, uri.scheme, css_downloads)) unless css_downloads.blank?

        xpathChain.run
        doc.to_html
      end

      def self.generate_preview_page app, page_url, rules = nil
        html = download_page app, page_url, rules

        test_dir = FilesManager.app_previews_dir app
        FileUtils.mkdir_p test_dir

        file_name = "#{app.identifier}_#{Time.now.to_i}.html"
        out_file = File.join test_dir, file_name
        File.open(out_file, 'w+') {|f|
          f.write html
        }

        "#{Figaro.env.news_apps_url}/previews/#{file_name}"
      end

      def self.generate_html_page app, news
        html = download_page app, news.original_uri, app.news_rules.as_json(only: TransformationRule::JSON_OUT_DEFAULT_SELECTOR)

        out_dir = FilesManager.app_news_dir app, news
        FileUtils.mkdir_p out_dir

        file_name = 'content.html'
        out_file = File.join out_dir, file_name
        File.open(out_file, 'w+') {|f|
          f.write html
        }

        nil
      end
    end
  end
end