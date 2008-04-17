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
    var ids = $('tr.exception').map(function(){
      return $(this).attr('id').replace(/^\w+-/, '');
    });
    
    return $('form#query-form').formSerialize() + '&ids=' + $.makeArray(ids).join(",")
//    return Form.serialize('query-form') + '&' + $$('tr.exception').collect(function(tr) { return tr.getAttribute('id').gsub(/^\w+-/, ''); }).toQueryString('ids');
  },

  toggleSibling: function( elt ) {
    elt.blur();
    $(elt).parent().next().slideToggle();
    return false;
  }
}

$(document).ready(function(){
  jQuery.each(ExceptionLogger.filters, function(context) {
    $(context + '_filter').value = '';
  });
  $('form#query-form').ajaxForm({'dataType':'script'});
});

jQuery.extend(Array.prototype, {
  toQueryString: function(name) {
    return this.collect(function(item) { return name + "[]=" + encodeURIComponent(item) }).join('&');
  }
});

$('#activity')
  .ajaxStart( function(){ $(this).fadeIn(0.25); })
  .ajaxStop(  function(){ $(this).fadeOut(0.25); });