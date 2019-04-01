var NewsApps = NewsApps || {};
NewsApps.RulesEditor = NewsApps.RulesEditor || {};

NewsApps.RulesEditor.setupIframe = function(iframe){
    var contents = iframe.contents();

    contents.find('body')
            .attr('oncontextmenu', 'return false;');

    contents.find('body a')
            .on('click', function(e) { 
              e.preventDefault(); 
              e.stopPropagation();
            });
};
