class Api::V1::BooksController < ApplicationController
  skip_before_action :authenticate_request, only: %i[index]

  # before_action :set_book, only: %i[ show edit update destroy ]
  # ALLOWED_DATA = %[title description rating].freeze

  def index
    books = Book.all
    render json: books, except: :rating
  end

  def show
    @book = Book.find(params[:id])
    render json: @book
  end

  def create
    # data = json_payload.select { |k| ALLOWED_DATA.include?(k) }
    book = Book.new(book_params)
    if book.save
      render json: book
    else
      render json: { "error": "could not create book" }
    end
  end

  def destroy
    book = Book.find(params[:id])
    if book.destroy
      json_response(true, 200, "payment status updated", {
        delete_book: book.as_json.merge(extra: "done")
      })
    else
      render json: { "success": false }

    end
  end
end

def book_params
  params.permit(:title, :description, :rating)
  # params.require(:book).permit(:title, :description, :rating)
  # params.fetch(:book, {}).permit(:title, :description, :rating)
end





