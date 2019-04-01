var NewsApps = NewsApps || {};
NewsApps.RulesEditor = NewsApps.RulesEditor || {};

NewsApps.RulesEditor.PreviewPane = function($iframe, options) {
  this.htmlSrc = ko.observable();
  this.htmlLoaded = ko.observable(false);

  var self = this;
      onUpdatePreview = options && options.onUpdatePreview,
      onSaveRules = options && options.onSaveRules;

  this.onUpdate = function(){
    onUpdatePreview && onUpdatePreview();
  };

  this.saveRules = function() {
    onSaveRules && onSaveRules();
  };

  this.load = function(url) {
    self.htmlLoaded(false);
    self.htmlSrc(url);
  };

  $iframe.on('load', function(e){
    NewsApps.RulesEditor.setupIframe($iframe);
  });
};
