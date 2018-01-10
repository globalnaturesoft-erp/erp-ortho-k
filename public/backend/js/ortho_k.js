function getNotification() {
    $.ajax({
        url: NOTIFICATION_URL,
        method: 'GET'
    }).done(function( html ) {
        $('<div>').html(html).find('.notification-badge-content').each(function() {
            var cl = $(this).attr('data-container');
            var badge = $(this).html();

            $('.notification-badge-container.' + cl).html(badge);
        });

        //// Grey notification
        //$('.sub-menu .nav-item .badge').each(function() {
        //    console.log($(this).closest('li').find('.sub-menu').length);
        //    if($(this).closest('li').find('.sub-menu').length > 0) {
        //        $(this).addClass('badge-grey');
        //        $(this).removeClass('badge-danger');
        //    }
        //});
    });
}

$(document).ready(function() {
    getNotification();
    setInterval(function() {getNotification();}, 10000);
});
