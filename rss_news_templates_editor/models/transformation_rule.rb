module NewsApps
  module Core
    class TransformationRule < ActiveRecord::Base
      self.table_name = :news_app_news_transformation_rules

      OPERATOR_TYPE_XPATH = 'xpath'
      OPERATOR_TYPE_DOWNLOAD = 'download'
      OPERATOR_TYPE_APPEND = 'append'
      OPERATOR_TYPE_CONSTRAINTS = 'constraints'

      OPERATOR_TYPES = [
        OPERATOR_TYPE_XPATH, 
        OPERATOR_TYPE_DOWNLOAD,
        OPERATOR_TYPE_APPEND,
        OPERATOR_TYPE_CONSTRAINTS
      ].freeze

      #
      # Xpath operators 
      #
      OPERATOR_XPATH_REMOVE_NODE_BY_SELECTOR = 'remove_node_by_selector'
      OPERATOR_XPATH_REMOVE_NODE_CLICKABILITY = 'remove_node_clickability'

      #
      # download operators
      #
      OPERATOR_TYPE_FILE_DOWNLOAD_CSS = 'download_css'
      OPERATOR_TYPE_FILE_DOWNLOAD_JS = 'download_js'

      #
      # Append operators
      #
      OPERATOR_TYPE_APPEND_PLAIN_CSS = 'append_plain_css'

      # 
      # Constraints
      # 
      OPERATOR_TYPE_CONSTRAINTS_SKIP_CSS_CLASSES = 'skip_css_classes'
      OPERATOR_TYPE_CONSTRAINTS_SKIP_CSS_CLASSES_STARTED_WITH = 'skip_css_classes_started_with'
      OPERATOR_TYPE_CONSTRAINTS_SKIP_IDS_STARTED_WITH = 'skip_ids_started_with'

      OPERATORS = [
        #xpath
        OPERATOR_XPATH_REMOVE_NODE_BY_SELECTOR,
        OPERATOR_XPATH_REMOVE_NODE_CLICKABILITY,

        #append
        OPERATOR_TYPE_APPEND_PLAIN_CSS,

        #download
        OPERATOR_TYPE_FILE_DOWNLOAD_CSS,
        OPERATOR_TYPE_FILE_DOWNLOAD_JS,

        #constraints
        OPERATOR_TYPE_CONSTRAINTS_SKIP_CSS_CLASSES,
        OPERATOR_TYPE_CONSTRAINTS_SKIP_CSS_CLASSES_STARTED_WITH,
        OPERATOR_TYPE_CONSTRAINTS_SKIP_IDS_STARTED_WITH
      ].freeze

      serialize :rule, JSON

      JSON_OUT_DEFAULT_SELECTOR = [:id, :operator, :operator_type, :rule]

	    validates :news_app_id, presence: true
      validates :rule, presence: true
    	validates :operator_type, presence: true,
                                inclusion:{in: OPERATOR_TYPES}
      validates :operator, presence: true,
                           inclusion: {in: OPERATORS}
    end
  end
end
