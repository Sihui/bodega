BODEGA.Autocomplete = function(form, search, callbacks) {
  search.filters = search.filters || {};
  callbacks = callbacks || {};
  init_options = Object.assign(callbacks, {
    source: function(req, res) {
      $.ajax({
        type:    'POST',
        url:     '/search',
        data:    { search: { model: search.model,
                             query: req.term,
                             filters: search.filters } },
        success: function(data) { res(data); },
        error:   function(data) { res([]); }
      });
    }
  });


  form.find('.ui-autocomplete-input').autocomplete(init_options);
};
