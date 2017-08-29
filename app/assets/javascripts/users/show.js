$(document).on('turbolinks:load', function() {
  function resetFlash(flashHash) {
    $('#flash').empty();

    for (type in flashHash) {
      $('<div/>', { id: type, text: flashHash[type] }).appendTo('#flash');
    }
  }

  // newCompanyUI --------------------------------------------------------------
  var newCompanyUI = {};
  newCompanyUI.showButton   = $('#show_form_button');
  newCompanyUI.hideButton   = $('#hide_form_button');
  newCompanyUI.submitButton = $('#submit_form_button');
  newCompanyUI.form         = $('#add_company_form');
  newCompanyUI.toggleState  = function() {
    newCompanyUI.showButton.toggleClass('hidden');
    newCompanyUI.form.toggleClass('hidden');
  };
  newCompanyUI.resetHints   = function() {
    $(".field_with_errors").each(function(i, el) {
      var wrapper = $(el);
      wrapper.replaceWith(wrapper.contents());
    })
  };
  newCompanyUI.showHints    = function(errors) {
    for (field in errors) {
      var input = $("input[name='company[" + field + "]']");
      var label = input.prev('label');
      var messages = errors[field];
      input.wrap($('<div/>', { class: 'field_with_errors' }));
      label.append(document.createTextNode(' (' + messages.join(', ') + ')'));
    }
  }

  // Form Buttons: “Add”
  newCompanyUI.showButton.click(newCompanyUI.toggleState);

  // Form Buttons: “Cancel”
  newCompanyUI.hideButton.click(function(e) {
    newCompanyUI.toggleState();
    e.preventDefault();
  });

  // Form Buttons: “Create”
  newCompanyUI.form.on('ajax:success', function(event, data) {
    newCompanyUI.toggleState();
    $('form').trigger('reset');
    newCompanyUI.resetHints();
    resetFlash(data.flash);
    $(data.snippet).appendTo('#company_index');
    $(data.li).appendTo('#nav__companies');
  });

  newCompanyUI.form.on('ajax:error', function(event, xhr, status, error) {
    resetFlash(xhr.responseJSON.flash);
    newCompanyUI.showHints(xhr.responseJSON.errors);
  });
});
