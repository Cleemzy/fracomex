$(document).ready(function(){
	"use strict";
    
    // 1. Scroll To Top 
		$(window).on('scroll',function () {
			if ($(this).scrollTop() > 600) {
				$('.return-to-top').fadeIn();
			} else {
				$('.return-to-top').fadeOut();
			}
		});
		$('.return-to-top').on('click',function(){
				$('html, body').animate({
				scrollTop: 0
			}, 1500);
			return false;
		});
	
	
	// 2. owl carousel
	
		
			$('#content-mini-slide').owlCarousel({
				loop:true,
				smartSpeed: 1000,
				autoplay:true,
				dots:false,
				autoplayHoverPause:true,
				itemsDesktop:[1199,3],
				itemsDesktopSmall:[980,2],
				itemsMobile : [600,1],
				navigation:true,
				navigationText:["",""],
				pagination:true,
				responsive:{
						0:{
							items:2
						},
						415:{
							items:3
						},
						600:{
							items:3

						},
						1200:{
							items:5
						}
					}
				});
				
				
				$('.play').on('click',function(){
					owl.trigger('play.owl.autoplay',[1000])
				})
				$('.stop').on('click',function(){
					owl.trigger('stop.owl.autoplay')
				})

		
			$("#collection-carousel").owlCarousel({
				items: 1,
				autoplay: true,
				loop: true,
				dots:false,
				mouseDrag:true,
				nav:false,
				smartSpeed:1000,
				transitionStyle:"fade",
				animateIn: 'fadeIn',
				animateOut: 'fadeOutLeft'
				// navText:["<i class='fa fa-angle-left'></i>","<i class='fa fa-angle-right'></i>"]
			});


    // 3. slide animation support

        $(window).load(function(){
        	$(".slide-hero-txt h4,.slide-hero-txt h2,.slide-hero-txt p").removeClass("animated fadeInUp").css({'opacity':'0'});
            $(".slide-hero-txt button").removeClass("animated fadeInDown").css({'opacity':'0'});
        });

        $(window).load(function(){
        	$(".slide-hero-txt h4,.slide-hero-txt h2,.slide-hero-txt p").addClass("animated fadeInUp").css({'opacity':'0'});
            $(".slide-hero-txt button").addClass("animated fadeInDown").css({'opacity':'0'});
        });


	
		/*$(".cart-close").click(function(){
			$(this).parents(".single-cart-list").fadeOut();
		});*/
		

});
// 4. cart-close
jQuery(".cart-close").click(function(){
	jQuery(this).parents(".single-cart-list").fadeOut();
});
jQuery(".cart-remove").click(function(){
	jQuery(".cart-product").fadeOut();
});
