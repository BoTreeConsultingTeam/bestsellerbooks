class ManuallyAddIsbnController < ApplicationController
  before_filter :authenticate_user!

  def new
    @book = BestsellerIsbn.new 
  end

  def index
  	@books_isbn = BestsellerIsbn.find_book_isbn(params[:page])
  end

  def create
  	book_isbn = BestsellerIsbn.create_book_isbn(params[:bestseller_isbn])
    if book_isbn.persisted?
      @book = BestsellerIsbn.new(params[:bestseller_isbn])
      flash.now[:alert] = "Book already exist"
      render :new
    elsif book_isbn.save
      flash.now[:notice] = "Book created"
    else
      @book = BestsellerIsbn.new(params[:bestseller_isbn])
      flash[:alert] = "Please check book title, isbn and occurrence"
      render :new
    end
    @books_isbn = BestsellerIsbn.find_book_isbn(params[:page])
  end

  def destroy
  	BestsellerIsbn.destroy_book_isbn(params[:manually_add_isbn_id])
    if params[:search] == "null"
      @books_isbn = BestsellerIsbn.find_book_isbn(params[:page])
    else
      @books_isbn = BestsellerIsbn.find_book(params[:search], params[:page])
    end
    @search = params[:search]
    flash.now[:notice] = "book deleted"
  end

  def edit
    @book = BestsellerIsbn.find(params[:id])
  end

  def update
    @book = BestsellerIsbn.find(params[:bestseller_isbn]["id"])
    if @book.update_attributes(params[:bestseller_isbn])
      flash.now[:notice] = "Book updated"
    else
      render :edit
      flash[:error] = "Book update fails"
    end
    @books_isbn = BestsellerIsbn.find_book_isbn(params[:page])
  end

  def search
    unless params[:search].nil?
      params[:search] = params[:search].gsub("'","''")
    end
    @books_isbn = BestsellerIsbn.find_book(params[:search], params[:page])
    @search = params[:search]
  end

  def show
    @books_isbn = BestsellerIsbn.find_book_isbn(params[:page])
  end
    
end