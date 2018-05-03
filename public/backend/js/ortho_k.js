function getNotification(show_alert) {
    if (typeof(show_alert) === 'undefined') {
        show_alert = false;
    }

    $.ajax({
        url: NOTIFICATION_URL,
        method: 'GET'
    }).done(function( html ) {
        var new_noti = false;
        $('<div>').html(html).find('.notification-badge-content').each(function() {
            var cl = $(this).attr('data-container');
            var badge = $(this).html();
            var msg;

            // $('.notification-badge-container.' + cl).html(badge);
            if ($('.notification-badge-container.' + cl).html() !== badge) {
                var new_badge = $('<div>').html(badge).find('.badge').html();
                var current_bagde = $('.notification-badge-container.' + cl).find('.badge').html();

                $('.notification-badge-container.' + cl).html(badge);

                if (typeof(current_bagde) === 'undefined') {
                    current_bagde = '';
                }

                //if (current_bagde.length) {
                    if ((current_bagde.trim() == '' && new_badge.trim() != '') || (new_badge != '' && current_bagde != '' && parseInt(new_badge) > parseInt(current_bagde))) {
                        if (cl == 'notification-inventory_stock_checking_orders_count') {
                            msg = 'Có đơn hàng mới cần kiểm tra';
                        }

                        if (cl == 'notification-sales_get_waiting_sales_orders') {
                            msg = 'Có đơn hàng đã được kiểm tra';
                        }

                        if (msg && show_alert) {
                            showAlert('success', msg, 'Thông báo');
                            new_noti = true;
                        }
                    }
                //}
            }
        });
        if (new_noti && show_alert) {
            var audio = new Audio('/backend/sound/nice_msg_alert.mp3');
            audio.play();
        }

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

function checkSchecks() {
    // Stock checks condistion
    $('.scheck-row').each(function() {
        var tr = $(this);
        var numbers = [];
        var letters = [];
        var diameters = [];

        tr.find('[name="numbers[]"]:checked').each(function() {
            numbers.push($(this).val());
        });

        tr.find('[name="letters[]"]:checked').each(function() {
            letters.push($(this).val());
        });

        tr.find('[name="diameters[]"]').each(function() {
            if ($(this).val() != '') {
                diameters.push($(this).val());
            }
        });

        console.log(diameters);

        // hide/show
        tr.find('.scheck-item').hide();

        tr.find('.scheck-item').each(function() {
            var item = $(this);
            var show_number = false;
            var show_letter = false;
            var show_diameter = false;

            numbers.forEach(function(number) {
                if (item.attr('data-number') == number) {
                    show_number = true;
                }
            });

            letters.forEach(function(letter) {
                if (item.attr('data-letter') == letter) {
                    show_letter = true;
                }
            });

            diameters.forEach(function(diameter) {
                if (item.attr('data-diameter') == diameter) {
                    show_diameter = true;
                }
            });
            if (diameters.length == 0) {
                show_diameter = true;
            }

            if (show_number && show_letter && show_diameter) {
                item.show();
            } else {
                item.hide();
            }
        });

    });
}

$(document).ready(function() {
    getNotification(false);
    setInterval(function() {getNotification(true);}, 30000);

    // Stock importing action
    $(document).on('click', '.custom-submit-button', function(e) {
        e.preventDefault();

        var form = $($(this).attr('data-form'));
        var action = $(this).attr('data-action');
        
        if(typeof(action) != 'undefined') {
            form.attr('action', action);
        }

        form.submit();
    });

    //
    checkSchecks();
    $(document).on('change', '[name="numbers[]"], [name="letters[]"], [name="diameters[]"]', function() {
        checkSchecks();
    });
});
