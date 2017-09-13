BODEGA.ItemSummary = function(selector) {
  // listener on qty fields adjusts item_total and order total
  // listener on qty buttons modifies value of qty field and adjusts totals
  // listener on delete button calls LineItem#destroy
  var form = $(selector);
  form.find('.item_qty').each(function(i, el) {
    var qty_field = $(el),
        price     = qty_field.siblings('.item_price').text().match(/^\d+/)[0];

    function total() {
      sum = 0;
      $('.item_total').each(function(i, el) {
        sum += parseInt($(el).text().match(/^\d+/)[0]);
      });
      return sum;
    }

    qty_field.children('input').change(function() {
      if (!$(this).val().match(/^\d+$/)) {
        return;
      }
      $.ajax({
        type: 'POST',
        url: $('#order_details').attr('action') + '/line_items/' + qty_field.parent().next().val(),
        data: {
          _method: 'patch',
          line_item: {
            qty: $(this).val()
          }
        },
        success: function(data) {
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
        },
        error: function() {
          // TODO something about me
          console.log('failure!')
        }
      });
    });
  });
}
