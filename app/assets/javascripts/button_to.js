BODEGA.ButtonTo = function(selector) {
  this.container = $(selector);

  this.container.find('form.button_to').each(function(i, el) {
    $(el).on('ajax:success', function(e, data) {
      if (data.flash) { BODEGA.flash.display(data.flash); }

      data.rerender = [].concat(data.rerender);
      for (var i = 0; i < data.rerender.length; i++) {
        if (eval(data.rerender[i].replace) && 'with' in data.rerender[i]) {
          eval(data.rerender[i].replace).empty().append(data.rerender[i].with);
        } else if ('append' in data.rerender[i] && 'to' in data.rerender[i]) {
          eval(data.rerender[i].to).append(data.rerender[i].append);
        } else if ('remove' in data.rerender[i]) {
          eval(data.rerender[i].remove).remove();
        }
      }
    });
  });

  this.container.find('form.button_to').each(function(i, el) {
    $(el).on('ajax:error', function(e, xhr) {
      if (xhr.responseJSON.flash) {
        BODEGA.flash.display(xhr.responseJSON.flash);
      }
    });
  });
};
