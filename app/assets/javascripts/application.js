// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
// require rails-ujs
//= require jquery-ui/widgets/autocomplete
//= require turbolinks
//= require_tree .

$(document).on('turbolinks:load', function(e) {
  // users#show ----------------------------------------------------------------
  if (window.location.pathname.match(/^\/user/)) {
    new BODEGA.FormUI('#user_overview');
    new BODEGA.FormUI('#company_overview');

    $('#pending_commitment_summary').find('form.button_to').each(function(i, el) {
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

    $('#pending_commitment_summary').find('form.button_to').on('ajax:error', function(e, xhr) {
      if (xhr.responseJSON.flash) {
        BODEGA.flash.display(xhr.responseJSON.flash);
      }
    });
  }

  // companies#show ------------------------------------------------------------
  if (window.location.pathname.match(/^\/companies\/\d/)) {
    new BODEGA.FormUI('#company_overview');
    new BODEGA.FormUI('#inventory_overview');
    new BODEGA.FormUI('.item_snippet');

    new BODEGA.FormUI('#purchasers_overview',
                      { search: { model: 'Company',
                                  filter: { as: 'new_purchaser',
                                            of: $('#company_name').text() } }
                      });

    new BODEGA.FormUI('#suppliers_overview',
                      { search: { model: 'Company',
                                  filter: { as: 'new_supplier',
                                            of: $('#company_name').text() } }
                      });

    new BODEGA.FormUI('#members_overview',
                      { search: { model: 'User',
                                  filter: { as: 'new_member',
                                            of: $('#company_name').text() } }
                      });

    $('#join_company').children('form').on('ajax:success', function(e, data) {
      if (data.flash) { BODEGA.flash.display(data.flash); }
      data.rerender = [].concat(data.rerender);

      for (var i = 0; i < data.rerender.length; i++) {
        if (eval(data.rerender[i].replace) && 'with' in data.rerender[i]) {
          eval(data.rerender[i].replace).empty().append(data.rerender[i].with);
        }
      }
    });

    $('#join_company').children('form').on('ajax:error', function(event, xhr, status, error) {
      if (xhr.responseJSON.flash) {
        BODEGA.flash.display(xhr.responseJSON.flash);
      }
    });

    $('#suppliers_pending_us, #purchasers_pending_us').find('form.button_to').each(function(i, el) {
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
  }
});
