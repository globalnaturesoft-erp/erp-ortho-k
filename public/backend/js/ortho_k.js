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
    getNotification();
    // setInterval(function() {getNotification();}, 10000);

    // Stock importing action
    $(document).on('click', '.stock-importing-button', function(e) {
        e.preventDefault();

        $('.stock-importing-form').submit();
    });

    //
    checkSchecks();
    $(document).on('change', '[name="numbers[]"], [name="letters[]"], [name="diameters[]"]', function() {
        checkSchecks();
    });
});
