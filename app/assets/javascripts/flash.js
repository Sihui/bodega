BODEGA.flash = {
  reset: function() {
    $('#flash').empty();
  },

  append: function(flashHash) {
    for (type in flashHash) {
      $('<div/>', { id: type, text: flashHash[type] }).appendTo('#flash');
    }
  },

  display: function(flashHash) {
    this.reset();
    this.append(flashHash);
  },
};