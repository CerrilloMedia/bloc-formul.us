$(document).on('turbolinks:load', function () {
  $("a[data-formula]").click(function(e) {
    e.preventDefault();
    
    var id = $(this).data('formula');
    console.log(id);
    $.getJSON('/formulas/' + id + '.json', function(data) {
      
      $('.formula-service-type span').html(data.service_type);
      $('#formula-formulation').html(data.formulation);
      $('.formula-card-author').html(data.author_name);
      var date = new Date(data.created_at);
      var date_string = ("0" + (date.getMonth() + 1)).slice(-2) + "/" + ("0" + date.getDate()).slice(-2);
      $('.formula-card-date').html(date_string);
      
    });
    
  });
});