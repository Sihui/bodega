BODEGA.flash = {
  reset: function() {
    $('#flash').empty();
  },

  append: function(flashHash) {
    for (type in flashHash) {
      $('<div/>', { id: type, text: flashHash[type] }).appendTo('#flash');
    }
  },

  // TODO fix this
  fadeOut: function() {
    this.reset();
  },

  display: function(flashHash) {
    this.reset();
    this.append(flashHash);
    window.setTimeout(this.fadeOut.bind(this), 5000)
  }
};
