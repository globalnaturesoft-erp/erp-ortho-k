$(function(){

"use strict";

/* ------------------------------ */
/* ANIMATIONS
/* ------------------------------ */

function setAnimationTime(selector, time) {
	setTimeout(function(){
		$('.' + selector + '').addClass('uk-active');
	},time);
}

function setAnimations(){
	$('.title, .social').addClass('uk-active');
	setAnimationTime('counter_days', 150);
	setAnimationTime('counter_hours', 250);
	setAnimationTime('counter_minutes', 350);
	setAnimationTime('counter_seconds', 450);
	setAnimationTime('subtitile_wrapper', 500);
	setAnimationTime('counter_button', 650);
}

function removeAnimations(){
	$('.title, .counter_days, .counter_hours, .counter_minutes, .counter_seconds, .social, .subtitile_wrapper, .counter_button').removeClass('uk-active');
}

/* ------------------------------ */
/* POPUP
/* ------------------------------ */

$(document).on('click', '.header_nav_list_item_link, .counter_button_message, .counter_button_subscribe', function(e) {
    e.preventDefault();
	var $this = $(this),
		popup_wrapper = $('.popup_wrapper'),
		$popup;
	$('.header_nav_wrapper').removeClass('uk-active');
	if ($this.hasClass('link_home')) {
		removePopup();
	} else {
		if ($this.hasClass('link_subscribe') || $this.hasClass('counter_button_subscribe')) {
			$popup = $('.popup_link_subscribe');
		} else if ($this.hasClass('link_features')) {
			$popup = $('.popup_link_features');
		} else if ($this.hasClass('link_projects')) {
			$popup = $('.popup_link_projects');
		} else if ($this.hasClass('link_contacts') || $this.hasClass('counter_button_message')) {
			$popup = $('.popup_link_contacts');
		} else if ($this.hasClass('link_location')) {
			$popup = $('.popup_link_location');
		} else if ($this.hasClass('link_about')) {
			$popup = $('.popup_link_about');
		}
		if (!(popup_wrapper.hasClass('uk-active'))) {
			popup_wrapper.addClass('uk-active');
			setTimeout(function(){
				popup_wrapper.addClass('visible');
			},100);
			removeAnimations();
		}
		if ($this.hasClass('uk-active')) {
			return false;
		} else {
			$('.popup').hide();
			$('.animated').removeClass('uk-active');
			$popup.show();
			setTimeout(function(){
				$popup.find('.animated').addClass('uk-active');
			},100);
		}
		$('.header_nav_list_item_link').removeClass('uk-active');
		if ($this.hasClass('header_nav_list_item_link')) {
			$this.addClass('uk-active');
		} else if ($this.hasClass('counter_button_subscribe')) {
			$('.link_subscribe').addClass('uk-active');
		} else if ($this.hasClass('counter_button_message')) {
			$('.link_contacts').addClass('uk-active');
		}
	}
});

function removePopup(){
	$('.popup').hide();
	$('.animated, .header_nav_list_item_link').removeClass('uk-active');
	$('.popup_wrapper').removeClass('uk-active visible');
	$('.link_home').addClass('uk-active');
	setAnimations();
}

/* ------------------------------ */
/* NAV
/* ------------------------------ */

$(document).on('click', '.header_navbar_mobile', function() {
	$('.header_nav_wrapper').toggleClass('uk-active');
});

/* ------------------------------ */
/* SPINNER
/* ------------------------------ */

(function removeSpinner(){
	setTimeout(function(){
		$('.spinner').animate({opacity: 0}, 500, function() {
			$(this).remove();
		});
		setAnimations();
	},2500);
})();

/* ------------------------------ */
/* REMOVE MOBILE VIDEO
/* ------------------------------ */

(function removeMobileVideo(){
	if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
		$('.video_wrapper').remove();
	}
})();

/* ------------------------------ */
/* COUNTDOWN
/* ------------------------------ */

(function setTime(){
	var today = new Date(),
		dd = today.getDate(),
		mm = today.getMonth()+1, //January is 0!
		countdown_month,
		yyyy = today.getFullYear(),
		countdown_date;
	if (dd < 10) {
		dd = '0' + dd;
	}
	countdown_month = parseInt(mm) + 3;
	if (countdown_month > 12) {
		countdown_month = countdown_month - 12
	}
	if (countdown_month < 10) {
		countdown_month = '0' + countdown_month;
	}
	countdown_date = yyyy+'/'+countdown_month+'/'+dd;
	$('.js_countdown').countdown(countdown_date, function(e) {
		$('.js_days').html(e.strftime('%D'));
		$('.js_hours').html(e.strftime('%H'));
		$('.js_minutes').html(e.strftime('%M'));
		$('.js_seconds').html(e.strftime('%S'));
	});
})();

/* ------------------------------ */
/* GALLERY IMAGES
/* ------------------------------ */

(function resizeGalleryImages() {
	$('.gallery_block').each(function() {
		$(this).css({
			'background-image': 'url(' + $(this).attr("href") + ')',
			'background-repeat': 'no-repeat',
			'background-position': 'center center',
			'background-size': 'cover'
		})
	})
})();

/* ------------------------------ */
/* EFFECTS
/* ------------------------------ */

(function setEffect() {
	var html = $('html'),
		body = $('body');
	if( !(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) ) {
		if (html.hasClass('water_effect')) {
			html.ripples({
                resolution: 512,
                dropRadius: 20,
                perturbance: 0.04,
            });
		} else if (html.hasClass('particles_effect')) {
			particlesBlockInsert();
		} else if (html.hasClass('rainy_effect')) {
			rainyBlockInsert();
		}
	}
	function rainyBlockInsert() {
		body.addClass('rainy_page')
			.append('<img id="rainy_background" alt="rainy" src="">');
		function run() {
			var image = document.getElementById('rainy_background');
			image.onload = function() {
				var engine = new RainyDay({
					image: this
				});
				engine.rain([ [1, 2, 4000] ]);
				engine.rain([ [3, 3, 0.88], [5, 5, 0.9], [6, 2, 1] ], 100);
			};
			image.crossOrigin = 'anonymous';
			image.src = 'images/photo_1.jpg';
		}
		run();
	}
	function particlesBlockInsert() {
		body.append('<div id="particles_block"></div>');
		particlesJS('particles_block',
		  {
			"particles": {
			  "number": {
				"value": 80,
				"density": {
				  "enable": true,
				  "value_area": 800
				}
			  },
			  "color": {
				"value": "#ffffff"
			  },
			  "shape": {
				"type": "circle",
				"stroke": {
				  "width": 0,
				  "color": "#000000"
				},
				"polygon": {
				  "nb_sides": 5
				},
				"image": {
				  "src": "img/github.svg",
				  "width": 100,
				  "height": 100
				}
			  },
			  "opacity": {
				"value": 0.5,
				"random": false,
				"anim": {
				  "enable": false,
				  "speed": 1,
				  "opacity_min": 0.1,
				  "sync": false
				}
			  },
			  "size": {
				"value": 5,
				"random": true,
				"anim": {
				  "enable": false,
				  "speed": 40,
				  "size_min": 0.1,
				  "sync": false
				}
			  },
			  "line_linked": {
				"enable": true,
				"distance": 150,
				"color": "#ffffff",
				"opacity": 0.4,
				"width": 1
			  },
			  "move": {
				"enable": true,
				"speed": 6,
				"direction": "none",
				"random": false,
				"straight": false,
				"out_mode": "out",
				"attract": {
				  "enable": false,
				  "rotateX": 600,
				  "rotateY": 1200
				}
			  }
			},
			"interactivity": {
			  "detect_on": "canvas",
			  "events": {
				"onhover": {
				  "enable": true,
				  "mode": "repulse"
				},
				"onclick": {
				  "enable": true,
				  "mode": "push"
				},
				"resize": true
			  },
			  "modes": {
				"grab": {
				  "distance": 400,
				  "line_linked": {
					"opacity": 1
				  }
				},
				"bubble": {
				  "distance": 400,
				  "size": 40,
				  "duration": 2,
				  "opacity": 8,
				  "speed": 3
				},
				"repulse": {
				  "distance": 200
				},
				"push": {
				  "particles_nb": 4
				},
				"remove": {
				  "particles_nb": 2
				}
			  }
			},
			"retina_detect": true,
			"config_demo": {
			  "hide_card": false,
			  "background_color": "#555555",
			  "background_image": "",
			  "background_position": "50% 50%",
			  "background_repeat": "no-repeat",
			  "background_size": "cover"
			}
		  }

		)
	}
})();

/* ------------------------------ */
/* FORM SUBMIT HINTS
/* ------------------------------ */

function removeFormElements(current_form) {
	current_form.find('input, textarea, button').remove();
}

/* ------------------------------ */
/* MAILCHIMP SUBSCRIBE FORM
/* ------------------------------ */

$('#mailchimp').ajaxChimp({
    callback: mailchimpCallback,
    url: "http://google.us3.list-manage.com/subscribe/post?u=54cac12d99d1b2a0c0e0177b4&amp;id=d5469b7ba3" // Replace this with your own mailchimp post URL. Don't remove the "". Just paste the url inside "". 
});

function mailchimpCallback(resp) {
    if (resp.result === 'success') {
		removeFormElements($('#mailchimp'));
		$('#mailchimp .success').fadeIn(1000);
		$('#mailchimp .success_response').html(resp.msg).fadeIn(1000);
        $('#mailchimp .error').fadeOut(0);
        $('#mailchimp .error_response').fadeOut(0);
    } else if (resp.result === 'error') {
		$('#mailchimp .error').fadeIn(1000);
        $('#mailchimp .error_response').html(resp.msg).fadeIn(1000);
    }  
}

/* ------------------------------ */
/* SUBSCRIBE FORM
/* ------------------------------ */

$(document).on('submit', '#subscribe', function(e) {
    e.preventDefault();
	var email = $('#subscriber_email').val(),
		dataString = 'email=' + email;

	function isValidEmail(emailAddress) {
		var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
		return pattern.test(emailAddress);
	};

	if (isValidEmail(email)) {
		$.ajax({
			type: "POST",
			url: "php/subscribe.php",
			data: dataString,
			success: function(resp) {
				removeFormElements($('#subscribe'));
				$('#subscribe .success').fadeIn(1000);
				$('#subscribe .error').fadeOut(0);
			},
			error: function(resp) {
				$('#subscribe .error').fadeIn(1000);
			}
		});
	} else {
		$('#subscribe .error').fadeIn(1000);
	}

    return false;
});

/* ------------------------------ */
/* ELASTIC MESSAGE FORM
/* ------------------------------ */

$(document).on('submit', '#elastic', function(e) {
    e.preventDefault();
    var name = $('#name').val(),
		email = $('#email').val(),
		message = $('#message').val(),
		dataString = 'name=' + name + '&email=' + email + '&message=' + message;

    function isValidEmail(emailAddress) {
        var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
        return pattern.test(emailAddress);
    };

    if (isValidEmail(email) && (message.length > 1) && (name.length > 1)) {
        $.ajax({
            type: "POST",
            url: "php/sendmessage.php",
            data: dataString,
            success: function(resp) {
				removeFormElements($('#elastic'));
				$('#elastic .success').fadeIn(1000);
				$('#elastic .error').fadeOut(0);
            },
			error: function(resp) {
				$('#elastic .error').fadeIn(1000);
			}
        });
    } else {
		$('#elastic .error').fadeIn(1000);
    }

    return false;
});

/* ------------------------------ */
/* MESSAGE FORM
/* ------------------------------ */

$(document).on('submit', '#contact', function(e) {
    e.preventDefault();
    var name = $('#name').val(),
		email = $('#email').val(),
		message = $('#message').val(),
		dataString = 'name=' + name + '&email=' + email + '&message=' + message;

    function isValidEmail(emailAddress) {
        var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
        return pattern.test(emailAddress);
    };

    if (isValidEmail(email) && (message.length > 1) && (name.length > 1)) {
        $.ajax({
            type: "POST",
            url: "php/sendmail.php",
            data: dataString,
            success: function(resp) {
				removeFormElements($('#contact'));
				$('#contact .success').fadeIn(1000);
				$('#contact .error').fadeOut(0);
            },
			error: function(resp) {
				$('#contact .error').fadeIn(1000);
			}
        });
    } else {
		$('#contact .error').fadeIn(1000);
    }

    return false;
});

});