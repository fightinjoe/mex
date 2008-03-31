// Finds the most recent photo in Flickr and embeds it in the page
function load_flickr_photo() {
  // var url = 'http://api.flickr.com/services/feeds/photos_public.gne?id=70203521@N00&amp;lang=en-us&amp;format=rss_200';
  var url = '/flickr.rss'
  $.get(url, {}, function(xml,stat) {
    //photo = $(xml).find('entry link[@type="image/jpeg"]')[0].href;
    regexp = /http:\/\/farm\d.static.flickr.com\/\d+\/\d+_[\da-f]*_m.jpg/
    photo  = $(xml).find('entry content').eq(0).text().match(regexp)[0];
    $('#pic').html('<img src="' + photo + '" />');
  })
}