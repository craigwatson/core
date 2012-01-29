// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  var element = $('#calendar-navigation').jScrollPane();

  if(element) {
    var api = element.data('jsp');
    api.scrollToElement($('#selected'), true);
  }

  $('.sortable').sortable({
    delay:250,
    placeholder:'ui-state-highlight',
    curser: 'move',
    opacity: 0.8,
    update: function() {
      $.ajax({
        type: 'post',
        data: $('#delivery_list').sortable('serialize'),
        dataType: 'json',
        url: '/distributors/' +
          $('#delivery-listings').data('distributor') +
          '/deliveries/date/' +
          $('#delivery-listings').data('date') +
          '/reposition'
      })
    }
  });
  $('.sortable').disableSelection();

  $('#delivery-listings #all').change(function() {
    var checked_deliveries = $('#delivery-listings .data-listings input[type=checkbox]');

    if($(this).is(':checked')) { checked_deliveries.prop('checked', true); }
    else { checked_deliveries.prop('checked', false); }

    return false;
  });

  $('#delivery-listings #master-print').click(function () {
    var checked_deliveries = $('#delivery-listings .data-listings input[type=checkbox]:checked');

    $.each(checked_deliveries, function(i, ckbx) {
      var holder = $(ckbx).parent().parent();

      holder.addClass('packed');
      holder.removeClass('unpacked');

      holder.find('.icon-packed').show();
      holder.find('.icon-unpacked').hide();
    });

    $('#packing').submit();

    checked_deliveries.prop('checked', false);
    $('#delivery-listings #all').prop('checked', false);
  });

  $('#delivery-listings #delivered, #delivery-listings #pending').click(function() {
    var distributor_id = $('#delivery-listings').data('distributor');
    var id = $(this).attr('id');
    var checked_deliveries = $('#delivery-listings .data-listings input[type=checkbox]:checked');

    updateDeliveryStatus(id, distributor_id, checked_deliveries);

    checked_deliveries.prop('checked', false);
    $('#delivery-listings #all').prop('checked', false);

    return false;
  });

  $('#delivery-listings #missed').click(function() {
     $('#delivery-listings .flyout').toggle();
     return false;
  });

  $('#commit-missed').click(function() {
    var distributor_id = $('#delivery-listings').data('distributor');
    var checked_deliveries = $('#delivery-listings .data-listings input[type=checkbox]:checked');
    var missed_option = $('#missed-options input:radio[name=missed]:checked').val();
    var date = undefined;

    if(missed_option === 'rescheduled' || missed_option === 'repacked') {
      date = $('#date_' + missed_option).val();
    }

    updateDeliveryStatus(missed_option, distributor_id, checked_deliveries, date);

    checked_deliveries.prop('checked', false);
    $('#delivery-listings #all').prop('checked', false);
    $('#delivery-listings .flyout').toggle();

    return false;
  });
});

function updateDeliveryStatus(status, distributor_id, checked_deliveries, date) {
  var ckbx_ids = $.map(checked_deliveries, function(ckbx) { return $(ckbx).data('delivery'); });
  var data_hash = { 'deliveries': ckbx_ids, 'status': status };
  if(date) { data_hash['date'] = date; }

  $.ajax({
    type: 'POST',
    url: '/distributors/' + distributor_id + '/deliveries/update_status.json',
    dataType: 'json',
    data: $.param(data_hash)
  });

  $.each(checked_deliveries, function(i, ckbx) {
    var holder = $(ckbx).parent().parent();

    var statuses = ['pending', 'delivered', 'cancelled', 'rescheduled', 'repacked'];
    statuses.splice(statuses.indexOf(status), 1);

    holder.addClass(status);
    holder.removeClass(statuses.join(' '));

    holder.find('.icon-' + status).show();
    $.each(statuses, function(j, hide_status) {
      holder.find('.icon-' + hide_status).hide();
    });
  });
}

