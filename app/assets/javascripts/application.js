// ---------------------- Gems ---------------------- //
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require cocoon
//= require rails.validations
//= require jQuery-File-Upload
//= require remodal
//= require turbolinks

// ---------------------- React ------------------------ //
//= require react
//= require react_ujs
//= require components

// ---------------------- Modules ---------------------- //
//= require modules/site
//= require modules/subnav_tabs
//= require modules/inline_validations
//= require modules/rangy_inputs
//= require modules/markdown_editor

// ---------------------- Pages ---------------------- //


$(document).on('ajax:error', function(xhr, status, error) {
  console.log(status.responseText);
  console.log(error);
});

$(document).on('turbolinks:load', function() {
  $('[data-remodal-id=modal]').remodal();
});
