$(document).ready(function(){
  var a = "#{@show_book_details.book_price[:crossword_price]}"
  $("#search-ajax").on("click",
    function(event) {
    	$(".ajax-progress").show();   
    	document.getElementById("main_div").className = "fadeout"; 
	});
  $("a.category_link").on("click",
    function(event) {
      $("a.category_link").css("font-weight","normal");
      $(this).css("font-weight","bold");
      $(".categor_label").text("Bestselling In" + " " + $(this).text() + " " + "Category" );
    });

  var search_data = $("#search_data").attr('value').split(',');

  $("#search").focus(function(){
    $(this).autocomplete({
      source: search_data
    });
  });
});