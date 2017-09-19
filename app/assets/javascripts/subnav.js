BODEGA.Subnav = function() {
  var tabs = $('#subnav').children('a')
  tabs.each(function(i, el) {
    $(el).click(function() {
      if ($(this).hasClass('selected')) {
        return;
      }
      $(this).parent().children('a').removeClass('selected');
      $(this).addClass('selected');
      $(this).parent().siblings('section').addClass('hidden');
      $(this).parent().siblings('section').eq(i).removeClass('hidden');
    });
  });
  
  tabs.first().click();
}
