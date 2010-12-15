class BooksController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy]
  before_filter :authorize, :except => [:index, :show, :root]
  
  auto_complete_for :book, :editor
  auto_complete_for :book, :city
  auto_complete_for :book, :country
  auto_complete_for :book, :language
  auto_complete_for :book, :collection
  auto_complete_for :book, :subject
  auto_complete_for :author, :name
  auto_complete_for :tag, :title  
          
  def root    
  end
          
  def gbook
    @isbn = params[:isbn]
    @book = Book.find(params[:id]) unless params[:id].empty?
    @book.authors = [] unless @book.nil?
  end        
          
  def index
    respond_to do |format|
      format.html do 
        @books = Book.search params[:search], 
                :star => true,       # Automatic Wildcard
                :sort_mode => :extended,
                :order => "title ASC, @relevance DESC",
                :field_weights => {  # Order of relevance
                  :author => 20, 
                  :title => 10, 
                  :tag => 5, 
                  :subject => 5, 
                  :description => 1
                  }, 
                :page => params[:page], # Pagination with WillPaginate 
                :per_page => 20
               
        @books.by_title(params['title_filter']) if params['title_filter'] && !params['title_filter'].empty? 
        @books.by_author(params['author_filter']) if params['author_filter'] && !params['author_filter'].empty?
        @books.by_author(params['editor_filter']) if params['editor_filter'] && !params['editor_filter'].empty?
        @books.by_language(params['language_filter']) if params['language_filter'] && !params['language_filter'].empty?
        @books.by_collection(params['collection_filter']) if params['collection_filter'] && !params['collection_filter'].empty?
        @books.delete_if{ |x| x.pdflink.nil? || x.pdflink.empty? } if params['pdf_filter']
      end
      
      format.rss  { @books = Book.all }
    end
    
  end
  
  def show
    @book = Book.find(params[:id])
  end
  
  def new
    @book = Book.new
    @book.authors.build
  end
  
  def create
    @book = Book.new(params[:book])
    @book.tombo = Book.last_tombo + 1
    if @book.save
      flash[:notice] = "Criado com sucesso."
      redirect_to @book
    else
      render :action => 'new'
    end
  end
  
  def edit
    @book = Book.find(params[:id])
  end
  
  def update
    @book = Book.find(params[:id])
    if @book.update_attributes(params[:book])
      flash[:notice] = "Atualizado com sucesso."
      redirect_to @book
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    flash[:notice] = "Removido com sucesso."
    redirect_to books_url
  end
end
