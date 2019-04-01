var NewsApps = NewsApps || {};
NewsApps.RulesEditor = NewsApps.RulesEditor || {};

NewsApps.RulesEditor.сontextMenu = function() {
  var self = this,
      _doc,
      _domEl,
      _domItems = [],
      _items,
      _clickedEl;

  var CSS = '.context-menu {'
      + 'background-color: #f1f1f1;'
      + 'min-width: 160px;'
      + 'box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);'
      + 'z-index: 9999;'
      + 'text-align: "left";'
      + '}'
      + '.context-menu a {'
      + '    color: black;'
      + '    padding: 12px 16px;'
      + '    text-decoration: none;'
      + '    display: block;'
      + '}'
      + '.context-menu a:hover {background-color: #ddd}';

  this.init = function(doc, items) {
    _doc = doc;
    _items = items;

    _domEl = _doc.createElement('ul');
    _domEl.style.position = 'absolute';    
    _domEl.style.display = 'none';
    _domEl.classList.add('context-menu');

    fillItems(items, _doc, _domEl);

    var styleEl = _doc.createElement('style');
    styleEl.innerHTML = CSS;

    _doc.getElementsByTagName('body')[0]
        .appendChild(_domEl);
    _doc.getElementsByTagName('head')[0]
        .appendChild(styleEl);
  };

  this.show = function(x, y, clickedEl) {
    _clickedEl = clickedEl;
    var domItem;
    _items.forEach(function(item) {
      domItem = _domItems[_items.indexOf(item)]      
      domItem.style.display = item.isActive(clickedEl) ? 'block' : 'none';
    });

    var pos = GuiUtils.absolutePosition(x, y, _doc);
    _domEl.style.left = pos.left + 'px';
    _domEl.style.top = pos.top + 'px';

    _domEl.style.display = 'block';
  };

  this.hide = function() {
    if (_domEl)
      _domEl.style.display = 'none';
  };

  function fillItems(items, doc, root) {
    var wrapper;
    
    _domItems.length = 0;
    _items.forEach(function(item){
       wrapper = doc.createElement('a');
       wrapper.href = '#';
       wrapper.innerHTML = item.title;

       root.appendChild(wrapper);
       _domItems.push(wrapper);

       wrapper.addEventListener('mousedown', function(e){
         e.stopPropagation();        
         if (item.onClick)
           item.onClick(_clickedEl);
         self.hide();
       });
    });
  };
};