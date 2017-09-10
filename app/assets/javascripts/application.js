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
    new BODEGA.HiddenForm('#user_overview');
    new BODEGA.HiddenForm('#company_overview');

    new BODEGA.ButtonTo('#pending_commitment_summary');
  }

  // companies#show ------------------------------------------------------------
  if (window.location.pathname.match(/^\/companies\/\d/)) {
    new BODEGA.HiddenForm('#company_overview');
    new BODEGA.HiddenForm('#inventory_overview');
    new BODEGA.HiddenForm('.item_snippet');

    new BODEGA.HiddenForm('#purchasers_overview',
                      { search: { model: 'Company',
                                  filters: { as: 'new_purchaser',
                                             of: $('#company_name').text() } }
                      });

    new BODEGA.HiddenForm('#suppliers_overview',
                      { search: { model: 'Company',
                                  filters: { as: 'new_supplier',
                                             of: $('#company_name').text() } }
                      });

    new BODEGA.HiddenForm('#members_overview',
                      { search: { model: 'User',
                                  filters: { as: 'new_member',
                                             of: $('#company_name').text() } }
                      });

    new BODEGA.ButtonTo('#join_company');
    new BODEGA.ButtonTo('#suppliers_pending_us, #purchasers_pending_us');
    new BODEGA.ButtonTo('.membership_request_form');
  }
});
