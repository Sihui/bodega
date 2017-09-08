// Set up forms whose visibility can be toggled on/off.
//
// Usage: `new BODEGA.FormUI(selector[, options])`
//
// Required DOM structure:
//
//   master container(data-resource="[resource]")
//     rendered container(.form_rendered)
//       rendered content
//     form container(.form_container)
//       show <button>
//       <form>
//         hide <button>
//
//   * The 'Show Form' button must directly precede the form.
//   * The 'Hide Form' button must be the form's last <button> descendant.
//   * The form must be contained in a <div>.
//   * The page content for the data that the form modifies must directly
//     precede that <div>.
//   * In order for form field validation hints to work,
//     the form itself must belong to the class "[resource]_form".
//
// Required API response objects:
//
//   * `flash`: a message to be displayed on the resulting page.
//     (format: `{ [type]: [message] }`)
//   * `rerender`: new content for the page, and the selector it will replace.
//     (format: `{ replace: [object], with: [rendered_content] }` or
//     `{ append: [rendered_content], to: [object], needsListener: [boolean] }`)
//   * `errors`: messages about which form fields failed validation and why.
//     (format: provided by ActiveRecord #errors)
//
// Options:
//
//   * `search`: parameters for the /search API request (`model` and `filter`)

BODEGA.FormUI = function(selector, options) {
// Init ------------------------------------------------------------------------
  this.container = $(selector);

  if (this.container.length > 1) {
    this.container.each(function(i, el) { new BODEGA.FormUI(el); });
  } else if (this.container.length) {
    this.form     = this.container.children('.form_container').children('form');
    this.showBtn  = this.container.children('.form_container').children('button');
    this.hideBtn  = this.form.find('button').last();
    this.rendered = this.container.children('.form_rendered');
    this.resource = this.container.data().resource;

    if (this._valid()) {
      this._attachListeners();
      if (options && options.search) {
        this._initAutocomplete(options.search);
      }
    }
  }
};

BODEGA.FormUI.prototype = {
// Validator -------------------------------------------------------------------
  _valid: function() {
    return (typeof(this.form)    !== 'undefined' &&
            typeof(this.showBtn) !== 'undefined' &&
            typeof(this.hideBtn) !== 'undefined');
  },

// Listeners -------------------------------------------------------------------
  _attachListeners: function() {
    var that = this;

    this.form.addClass('hidden');

    // “Add/Edit” Button
    this.showBtn.click(function() {
      that.showBtn.addClass('hidden');
      that.form.removeClass('hidden');
      that.rendered.addClass(that.showBtn.text().match(/^edit/i) ? 'hidden' : '');
    });

    // “Cancel” Button
    this.hideBtn.click(function(e) {
      that.form.addClass('hidden');
      that.showBtn.removeClass('hidden');
      that.rendered.removeClass('hidden');
      e.preventDefault();
    });

    // “Create/Update” Button
    this.form.on('ajax:success', function(event, data) {
      // Toggle visibility
      that.form.addClass('hidden');
      that.showBtn.removeClass('hidden');
      that.rendered.removeClass('hidden');

      // Reset form field values
      if (that.resource && data.formFields) {
        for (field in data.formFields) {
          that.form.find('input[name="' + that.resource + '[' + field + ']"]')
            .attr('value', data.formFields[field]);
        }
      }
      that.form.trigger('reset');

      // Reset form field hints
      that._resetHints();

      // Display flash message
      if (data.flash) {
        BODEGA.flash.display(data.flash);
      }

      // Rerender content
      data.rerender = [].concat(data.rerender);

      for (var i = 0; i < data.rerender.length; i++) {
        if ('replace' in data.rerender[i] && 'with' in data.rerender[i]) {
          eval(data.rerender[i].replace).empty().append(data.rerender[i].with);
        } else if ('append' in data.rerender[i] && 'to' in data.rerender[i]) {
          eval(data.rerender[i].to).append(data.rerender[i].append);

          // Attach new listeners
          if (data.rerender[i].needsListeners) {
            var newForm = eval(data.rerender[i].to).children().last().get(0);
            if (! $._data(newForm, 'events')) { new BODEGA.FormUI($(newForm)); }
          }
        }
      }
    });

    this.form.on('ajax:error', function(event, xhr, status, error) {
      if (xhr.responseJSON.flash) {
        BODEGA.flash.display(xhr.responseJSON.flash);
      }
      if (that.resource && xhr.responseJSON.errors) {
        that._showHints(xhr.responseJSON.errors, that.resource);
      }
    });
  },

// Autocomplete ----------------------------------------------------------------
  _initAutocomplete: function(search) {
    var that = this;
    search.filters = (typeof(search.filters) !== 'undefined') ? search.filters : {};

    this.form.find('.ui-autocomplete-input').autocomplete({
      source: function(req, res) {
        $.ajax({
          type:    'GET',
          url:     '/search',
          data:    { search: { model: search.model,
                               query: req.term,
                               filters: search.filter } },
          success: function(data) { res(data); },
          error:   function(data) { res([]); }
        });
      },
      select: function(event, ui) {
        that.form.find('.ui-autocomplete-input').val(ui.item.name)
          .next().val(ui.item.id);
        that.form.submit();
      }
    });
  },

// Helper Methods --------------------------------------------------------------
  _showHints: function(errors, scope) {
    this._resetHints();

    for (field in errors) {
      var input = this.container.find("input[name='" + scope + "[" + field + "]']"),
          label = input.prev('label'),
          hint  = (' (' + errors[field].join(', ') + ')');

      input.wrap($('<div/>', { class: 'field_with_errors' }));
      label.append($('<span/>', { class: 'field_error_msg', text: hint }));
    }
  },

  _resetHints: function() {
    this.container.find(".field_with_errors").each(function(i, el) {
      var errorWrapper = $(el);
      errorWrapper.replaceWith(errorWrapper.contents());
    });
    this.container.find(".field_error_msg").remove();
  }
};
