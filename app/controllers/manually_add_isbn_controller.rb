class ManuallyAddIsbnController < ApplicationController
  before_filter :authenticate_user!, :check_if_admin
  
  def index
  	@books_isbn = BestsellerIsbn.find_book_isbn(params[:page])
  end

  def create
  	book_isbn = BestsellerIsbn.create_book_isbn(params[:isbn], params[:book_title], params[:occurrence])
    if book_isbn.persisted?
      flash.now[:alert] = "Book already exist"
    elsif book_isbn.new_record? && !book_isbn.isbn.empty? && !book_isbn.title.empty? && !book_isbn.occurrence.nil?
      book_isbn.save
      flash.now[:notice] = "Book created"
    else
      flash.now[:alert] = "Please check book title, isbn and occurrence"
    end
    @books_isbn = BestsellerIsbn.find_book_isbn(params[:page])
  end

  def destroy
  	BestsellerIsbn.destroy_book_isbn(params[:manually_add_isbn_id])
    if params[:search] == "0"
      @books_isbn = BestsellerIsbn.find_book_isbn(params[:page])
    else
      @books_isbn = BestsellerIsbn.find_book(params[:search], params[:page])
    end
    @search = params[:search]
    flash.now[:notice] = "book deleted"
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
  
  protected
  
  def check_if_admin
    if signed_in?
      redirect_to root_path unless current_user.admin?
    end
  end
  
end