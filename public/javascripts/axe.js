ExceptionLogger = {
  filters: ['exception_names', 'controller_actions', 'date_ranges'],

  setPage: function(num) {
    $('page').value = num;
    $('query-form').onsubmit();
  },
  
  setFilter: function(context, name) {
    var filterName = 'input[name=' + context + '_filter]';
    $(filterName).val( ($(filterName).val() == name) ? '' : name );

    $('#' + context + ' a').each(function(){
      this.className = (this.className == '' && this.innerHTML == name) ? 'selected' : ''
    });

    $('input[name=page]').val(1);
    $('form#query-form').ajaxSubmit({'dataType':'script'});
  },

  deleteAll: function() {
    return $.makeArray($('tr.exception').map(function(){return this.getAttribute('id').replace(/^\w+-/, '');})).join(",")
//    return Form.serialize('query-form') + '&' + $$('tr.exception').collect(function(tr) { return tr.getAttribute('id').gsub(/^\w+-/, ''); }).toQueryString('ids');
  },

  toggleSibling: function( elt ) {
    elt.blur();
    $(elt).parent().next().slideToggle();
    return false;
  }
}

//Event.observe(window, 'load', function() {
$(document).ready(function(){
  jQuery.each(ExceptionLogger.filters, function(context) {
    $(context + '_filter').value = '';
  });
});


//Object.extend(Array.prototype, {
jQuery.extend(Array.prototype, {
  toQueryString: function(name) {
    return this.collect(function(item) { return name + "[]=" + encodeURIComponent(item) }).join('&');
  }
});

//Ajax.Responders.register({
//  onCreate: function() {
//    if($('activity') && Ajax.activeRequestCount > 0) $('activity').visualEffect('appear', {duration:0.25});
//  },
//
//  onComplete: function() {
//    if($('activity') && Ajax.activeRequestCount == 0) $('activity').visualEffect('fade', {duration:0.25});
//  }
//});

$(document).ready(function(){
  $('form#query-form').ajaxForm({'dataType':'script'});
});