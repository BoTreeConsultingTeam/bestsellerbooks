$(document).ready(function(){
  $("#search-ajax").on("click",
    function(event) {
      $.blockUI({ css: { 
          border: 'none', 
          padding: '15px', 
          backgroundColor: '#000', 
          '-webkit-border-radius': '10px', 
          '-moz-border-radius': '10px', 
          opacity: .5, 
          color: '#fff' 
      } }); 
	});

  $("a.category_link").on("click",
    function(event) {
      if ($(this).hasClass('disabled'))
        {
          return false;
        }
      else
        {
          $.blockUI({ css: { 
              border: 'none', 
              padding: '15px', 
              backgroundColor: '#000', 
              '-webkit-border-radius': '10px', 
              '-moz-border-radius': '10px', 
              opacity: .5, 
              color: '#fff' 
          } }); 
          $("a.category_link").css("font-weight","normal");
          $("a.category_link").removeClass('disabled');
          $(this).css("font-weight","bold");
          $(this).addClass('disabled');
          $(".categor_label").text("Bestseller - " + $(this).text());
        }
  });
  $(".refresh_book_details").on("click",
    function(event) {
      $.blockUI({ css: { 
              border: 'none', 
              padding: '15px', 
              backgroundColor: '#000', 
              '-webkit-border-radius': '10px', 
              '-moz-border-radius': '10px', 
              opacity: .5, 
              color: '#fff' 
          } }); 
    });
  $("#search-ajax").on("click",
    function(event) {
      $(".categor_label").text("Search result - " + $("#search").val());
    });

   var search_data = $("#search_data").attr('value').split(',');
  
  $("#search").focus(function(){
    $(this).autocomplete({
      source: search_data,
      minLength: 3
    });
  });
});