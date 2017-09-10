BODEGA.Autocomplete = function(form, search, select) {
  search.filters = search.filters || {};

  form.find('.ui-autocomplete-input').autocomplete({
    select: select,
    source: function(req, res) {
      $.ajax({
        type:    'GET',
        url:     '/search',
        data:    { search: { model: search.model,
                             query: req.term,
                             filters: search.filters } },
        success: function(data) { res(data); },
        error:   function(data) { res([]); }
      });
    }
  });
};
