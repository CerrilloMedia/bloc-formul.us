$(document).on('turbolinks:load', function () {
  $("tr[data-formula-id]").click(function(e) {
    e.preventDefault();

    $("tr[data-formula-id]").removeClass("sidebar-bg");
    $(this).toggleClass("sidebar-bg");


    // parse existing data from <tr>
    $('.formula-service-type span').html($(this).data('formula-service'));
    $('#formula-formulation').text($(this).data('formulation'));
    $('.formula-card-author').html($(this).data('formula-author'));
    $('.formula-card-date').html($(this).data('formula-date'));

    // update user links if available in the User#show view
    var id = $(this).data('formula-id');

    if ($('#formula-edit').length) {
      $('#formula-edit').attr('href', '/formulas/' + id + '/edit');
      if ($(this).data('is-author')) {
            $('#formula-edit').show();
      } else {
            $('#formula-edit').hide();
      }
    };
    if ($('#formula-copy').length) {
      $('#formula-copy').attr('href', '/formulas?copy=' + id);
    };

  });

// FORMULAS#NEW
  $('#formula_client_id').on('change', function() {
  	var option = $(this).find('option:selected').val();
  	var newUser = $('.add-new-user');
  	if ( option == "") {
  		newUser.show(200);
      } else {
  		newUser.hide(100);
      }
  });

    // TOGGLE FORMULAS#INDEX
    // $("span[data-formula-id]").closest('a').click(function(e) {
    //   e.preventDefault();
    //   $(this).children('strong').toggle(300);
    // });

    // If I prefer to include server calls to get most recent formula information
    // var id = $(this).data('formula-id');
    // console.log(id);
    //
    // $.getJSON('/formulas/' + id + '.json', function(data) {
    //
    //   $('.formula-service-type span').html(data.service_type);
    //   $('#formula-formulation').html(data.formulation);
    //   $('.formula-card-author').html(data.author_name);
    //   var date = new Date(data.created_at);
    //   var date_string = ("0" + (date.getMonth() + 1)).slice(-2) + "/" + ("0" + date.getDate()).slice(-2);
    //   $('.formula-card-date').html(date_string);
    //
    // });
});
