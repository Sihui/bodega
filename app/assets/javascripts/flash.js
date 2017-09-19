BODEGA.flash = {
  reset: function() {
    if (this.displayTimeout) {
      window.clearTimeout(this.displayTimeout);
    }

    $('#flash').empty();

    if (this.fadeTimeout) {
      window.clearTimeout(this.fadeTimeout);
    }

    $('#flash').removeClass('fadeout');
  },

  append: function(flashHash) {
    for (type in flashHash) {
      $('<p/>', { id: type, text: flashHash[type] }).appendTo('#flash');
    }
  },

  fadeOut: function() {
    this.displayTimeout = window.setTimeout(function() {
      $('#flash').addClass('fadeout');
      this.fadeTimeout = window.setTimeout(function() {
        this.reset();
        $('#flash').removeClass('fadeout');
      }.bind(this), 500)
    }.bind(this), 3000)
  },

  display: function(flashHash) {
    this.reset();
    this.append(flashHash);
    this.fadeOut();
  }
};
