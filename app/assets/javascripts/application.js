//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require materialize-sprockets
//= require easytimer
//= require loadingoverlay.min
//= require loadingoverlay_progress.min
$(document).on('turbolinks:load', function() {
  $('.button-collapse').sideNav({
      menuWidth: 300,
      edge: 'left',
      closeOnClick: true,
      draggable: true,
      onOpen: function(el) {}, // A function to be called when sideNav is opened
            onClose: function(el) {}
          }
  );
  //$('.button-collapse').sideNav('show');
});

// Filter by label function for main page filtering
$(document).on('input', '#filtertext', function(){
  //alert("changed!");
  var filter = $("#filtertext").val();
  var machines = $('.vm');
  machines.show();  
  if (filter != '') machines.not('[class*="'+filter+'"]').hide();
});