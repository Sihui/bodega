// This is a manifest file that'll be compiled into application.js, which will
// include all the files listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or
// any plugin's vendor/assets/javascripts directory can be referenced here
// using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at
// the bottom of the compiled file. JavaScript code in this file should be
// added after the last require_* statement.
//
// Read Sprockets docs (https://github.com/rails/sprockets#sprockets-directives)
// for details about supported directives.
//
//= require jquery
//= require jquery_ujs
// require rails-ujs
//= require jquery-ui/widgets/autocomplete
//= require turbolinks
//= require_tree .

$(document).on('turbolinks:load', function(e) {
  // global --------------------------------------------------------------------
  new BODEGA.HiddenForm('#companies_search', { search: { model: 'Company' } });

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

    new BODEGA.HiddenForm('#purchasers_overview', {
      search: {
        model: 'Company',
        filters: {
          as: 'new_purchaser',
          of: $('#company_name').text()
        }
      }
    });

    new BODEGA.HiddenForm('#suppliers_overview', {
      search: {
        model: 'Company',
        filters: {
          as: 'new_supplier',
          of: $('#company_name').text()
        }
      }
    });

    new BODEGA.HiddenForm('#members_overview', {
      search: {
        model: 'User',
        filters: {
          as: 'new_member',
          of: $('#company_name').text()
        }
      }
    });

    new BODEGA.ButtonTo('#join_company');
    new BODEGA.ButtonTo('#suppliers_pending_us, #purchasers_pending_us');
    new BODEGA.ButtonTo('.membership_request_form');
  }

  // orders#new ----------------------------------------------------------------
  if (window.location.pathname.match(/^\/orders\/new/)) {
    var company_select   = $("#company_select"),
        purchaser_select = $("#purchaser_select"),
        supplier_select  = $("#supplier_select"),
        order_form       = $("#order_form"),
        item_search      = $("#item_search"),
        order_details    = $("#order_details"),
        start_over       = $("#start_over"),
        order_params     = {};

    order_form.addClass('hidden');

    purchaser_select.children('.purchaser').each(function(i, el) {
      purchaser = $(el);
      suppliers = purchaser.data().suppliers.split(',');

      purchaser.hover(function(e) {
        // highlight self
        $(this).addClass('highlight');

        // highlight valid suppliers
        supplier_select.children('.supplier').filter(function(i) {
          return (suppliers.indexOf($(this).data().id.toString(10)) >= 0);
        }).addClass('highlight');

      }, function(e) {
        // undo
        $(this).removeClass('highlight');
        supplier_select.children().removeClass('highlight');
      });

      purchaser.click(function(e) {
        // mark this selected
        purchaser_select.children().removeClass('selected');
        $(this).addClass('selected');

        // hide invalid suppliers 
        supplier_select.children('.supplier').filter(function(i) {
          return (suppliers.indexOf($(this).data().id.toString(10)) >= 0);
        }).removeClass('hidden');

        // unhide valid suppliers 
        supplier_select.children('.supplier').filter(function(i) {
          return (suppliers.indexOf($(this).data().id.toString(10)) < 0);
        }).addClass('hidden');

        // set purchaser
        order_params.purchaser = $(this).data().id;
      });
    });

    supplier_select.children('.supplier').each(function(i, el) {
      supplier = $(el);

      supplier.hover(function(e) {
        // highlight self
        $(this).addClass('highlight');
      }, function(e) {
        // undo
        $(this).removeClass('highlight');
      });

      supplier.click(function(e) {
        if ('purchaser' in order_params) {
          // toggle visiblity on selection ui, order form
          company_select.addClass('hidden');
          order_form.removeClass('hidden');

          // set supplier
          order_params.supplier = $(this).data().id;

          // Order#create
          $.ajax({
            type: 'POST',
            url: '/orders',
            data: {
              order: {
                supplier_id:  order_params.supplier,
                purchaser_id: order_params.purchaser
              }
            },
            success: function(data) {
              order_params.id = data.id;

              // reset banner text
              $('#banner > h1').text('Place order with ' + data.supplier);
              $('#banner > h2').text('for ' + data.purchaser);

              // populate forms
              item_search.attr('action', '/orders/' + data.id + '/line_items');
              order_details.attr('action', '/orders/' + order_params.id);
              start_over.parent().attr('action', '/orders/' + order_params.id);

              // initialize autocomplete on item search box
              new BODEGA.Autocomplete(item_search, {
                model: 'Item',
                filters: {
                  from: order_params.supplier,
                  for: order_params.id
                }
              }, {
                select: function(event, ui) {
                  $(this).val(ui.item.name).next().val(ui.item.id);
                  $(this).parent().submit();
                }
              });
            },
            error: function(data) {
              // TODO something about me
              console.log('failure!')
            }
          });
        } else {
          BODEGA.flash.display({ alert: 'Please choose a purchaser first!' });
        }
      });
    });

    // add listener to item search form: rerender as necessary
    item_search.on('ajax:success', function(event, data) {
      // Reset item search
      item_search.trigger('reset');

      // Display flash message
      if (data.flash) {
        BODEGA.flash.display(data.flash);
      }

      // Rerender content (prepend item to order form)
      if (data.rerender) {
        data.rerender = [].concat(data.rerender);

        for (var i = 0; i < data.rerender.length; i++) {
          if ('replace' in data.rerender[i] && 'with' in data.rerender[i]) {
            eval(data.rerender[i].replace).empty().append(data.rerender[i].with);

            // Attach new listeners
            if (data.rerender[i].needsListeners) {
              new BODEGA.ItemSummary('#item_summary');
            }
          }
        }
      }
    });

    item_search.on('ajax:error', function(event, xhr, status, error) {
      // Reset item search
      item_search.trigger('reset');

      // Display flash message
      if (xhr.responseJSON.flash) {
        BODEGA.flash.display(xhr.responseJSON.flash);
      }
    });

    // SUBMIT on this form invokes Order#destroy
    start_over.click(function(e) {
      // reset banner text
      $('#banner > h1').text('New order');
      $('#banner > h2').empty();

      // Reset item search
      item_search.trigger('reset');

      // toggle visiblity on selection ui, order form
      company_select.removeClass('hidden');
      order_form.addClass('hidden');

      // purge `order_params`
      delete order_params.supplier;
      delete order_params.purchaser;
      delete order_params.id;

      // destroy autocomplete on item search box
      item_search.find('.ui-autocomplete-input')
        .autocomplete('destroy')
        .addClass('ui-autocomplete-input');

      // reset cart
      order_form.find('tbody').empty();
    })
  }
});
