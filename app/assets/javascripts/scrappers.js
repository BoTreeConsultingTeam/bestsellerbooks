$(document).ready(function(){
  var a = "#{@show_book_details.book_price[:crossword_price]}"
  $("#search-ajax").on("click",
    function(event) {
    	$(".ajax-progress").show();   
    	document.getElementById("main_div").className = "fadeout"; 
	
	});
  
 });