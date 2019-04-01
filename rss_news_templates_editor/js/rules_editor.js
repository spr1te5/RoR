var NewsApps = NewsApps || {};
NewsApps.RulesEditor = NewsApps.RulesEditor || {};

NewsApps.RulesEditor.Editor = function(appId, rules) {
  var self = this,
      URL_ROOT = 'admin'

  this.htmlPages = ko.observableArray();
  this.selectedHtmlPage = ko.observable();
  this.lastLoadedPage = ko.observable();

  this.sourcePane = new NewsApps.RulesEditor.SourcePane(
    $('iframe.html-view'), 
    rules,
    function() { return self.settingsPane.classesStopList(); },
    function() { return self.settingsPane.classesStopPrefixesList(); },
    function() { return self.settingsPane.idStopPrefixesList(); }
  );

  this.previewPane = new NewsApps.RulesEditor.PreviewPane(
    $('iframe.preview'),
    {
      onUpdatePreview: function(){ return testCurrentRules(); },
      onSaveRules: function() { saveRules(); }
    }
  );

  this.cssFilesPane = new NewsApps.RulesEditor.CssFilesPane(rules);
  this.cssPane = new NewsApps.RulesEditor.CssPane(rules);
  this.settingsPane = new NewsApps.RulesEditor.SettingsPane(rules);

  this.selectedContentPage = ko.computed(function(){
    var last = self.lastLoadedPage();
    return last && self.selectedHtmlPage() === last;
  });

  //TODO: old version of retryAjax used.
  this.loadNewsUrls = function() {
    var url = '/'+URL_ROOT+'/news_apps/'+appId+'/rss_pages_list';
    if (typeof(retryAjax) === 'undefined') {    
      $.get(url,
            {},
            onNewsJobCreated,
            'json');
    } else {
      retryAjax(function(){
        return $.get(url,
                     {},
                     onNewsJobCreated,
                     'json');
      });
    }
  };

  function onNewsJobCreated(data) {
    pollJob(data.job_id, onPagesLinksExtracted);
  };

  function onPagesLinksExtracted(data) {
    if (data.result)
      self.htmlPages(data.result);
    else {
      self.htmlPages([]);
      alert('Не удалось получить список страниц');
    }
  };

  function pollHtmlJob(jobId) {
    pollJob(jobId, onPageHtmlExtracted);
  };

  function onPageHtmlExtracted(data) {
    setTimeout(function(){
      self.lastLoadedPage(self.selectedHtmlPage());
      self.sourcePane.load(data.result.test_page_url);
    }, 1000);
  };

  function onApplyRulesJobCreated(data) {
    pollJob(data.job_id, onTestPageCreated);
  };

  function onTestPageCreated(data) {
    self.previewPane.load(data.result.test_page_url);
  };

  $('form.pages-selector').on('ajax:success', function(_e, data){
    pollHtmlJob(data.job_id);
  });

  function collectRules(options) {
    return Array.prototype.concat.call([],
           self.sourcePane.rules(options),
           self.cssFilesPane.rules(),
           self.settingsPane.rules(),
           self.cssPane.rules());
  };

  function testCurrentRules() {
    var rules = collectRules({skipRemoved: true});
    if (0 === rules.length){
      alert('Нет правил.');
      return;
    }

    //TODO: move path mask to options.
    var url = '/'+URL_ROOT+'/news_apps/'+appId+'/preview',
        data = {
          page_url: self.lastLoadedPage(),
          rules: rules
        };
    if (typeof(retryAjax) === 'undefined') {    
      $.post(url,
             data,
             onApplyRulesJobCreated,
             'json');
    } else {
      retryAjax(function(){
        return $.post(url,
                      data,
                      onApplyRulesJobCreated,
                      'json');
      });
    }
  };

  function saveRules() {
    if (!confirm('Вы уверены ?'))
      return;
    
    var rules = collectRules();
    if (0 === rules.length){
      alert('Нет правил.');
      return;
    }
    //TODO: move url to params
    var url = '/'+URL_ROOT+'/news_apps/'+appId+'/save_rules',
        data = {
          page_url: self.lastLoadedPage(),
          rules: rules
        };
    if (typeof(retryAjax) === 'undefined') {    
      $.post(url,
             data,
             onRulesSaved,
             'json');
    } else {
      retryAjax(function(){
        return $.post(url,
                      data,
                      onRulesSaved,
                      'json');
      });
    }
  };

  function onRulesSaved(data) {
    var msg, newRules;
    switch (data.status){
      case 'success':
          msg = 'Правила сохранены';
          newRules = JSON.parse(data.rules)
          self.sourcePane.onRulesSaved(newRules);
          self.settingsPane.onRulesSaved(newRules);
          self.cssPane.onRulesSaved(newRules);
          self.cssFilesPane.onRulesSaved(newRules);
        break;
      case 'error':
        mag = data.errors;
    }
    if (msg)
      alert(msg);
  };

  ko.applyBindings(this);
};