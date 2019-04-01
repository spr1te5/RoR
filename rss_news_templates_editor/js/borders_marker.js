var NewsApps = NewsApps || {};
NewsApps.RulesEditor = NewsApps.RulesEditor || {};

NewsApps.RulesEditor.BordersMarker = function(options) {
  var self = this,
      borderStyle = options && options.borderStyle || '5px dotted red',
      _domEl,
      _doc,
      _window,
      onShow = options && options.onShow;

  this.init = function(doc, options) {
    _doc = doc;

    _domEl = doc.createElement('div');
    _domEl.style.position = 'absolute';    
    _domEl.style.display = 'none';
    setBorderStyle(_domEl, borderStyle);

    _domEl.addEventListener('mousedown', function(e){
      if (3 === e.which && onShow) {
        e.stopPropagation();
        var el  = _doc.elementFromPoint(e.clientX, e.clientY);
        onShow(el, e);
      }
    });

    _doc.getElementsByTagName('body')[0]
        .appendChild(_domEl);
  };

  this.highlight = function(rectEl, options) {
    var domStyle = _domEl.style,
        style = options && options.borderStyle || borderStyle,
        bounds = GuiUtils.getBoundingClientRectAbsolute(rectEl, _doc);

    var left = bounds.left,
        top = bounds.top,
        width = bounds.width,
        height = bounds.height;

    domStyle.left = left+'px';
    domStyle.top = top+'px';
    domStyle.width = width+'px';
    domStyle.height = height+'px';

    if (borderStyle)
      setBorderStyle(_domEl, style);

    this.show();
  };

  this.show = function() {
    if (!_domEl)
      return;
    _domEl.style.display = 'block';
  };

  this.hide = function() {
    if (!_domEl)
      return;
    _domEl.style.display = 'none';
  };

  function setBorderStyle(el, style) {
    el.style.borderLeft = el.style.borderRight = el.style.borderTop = el.style.borderBottom = style;
  };

  // function triggerEvent(doc, el, eventName, options) {
  //   var event;
  //   if (window.CustomEvent) {
  //     event = new CustomEvent(eventName, options);
  //   } else {
  //     event = doc.createEvent('CustomEvent');
  //     event.initCustomEvent(eventName, true, true, options);
  //   }
  //   el.dispatchEvent(event);
  // }  
};
