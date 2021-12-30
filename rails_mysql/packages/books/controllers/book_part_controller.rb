class BookPartController < ApplicationController
  before_action :authenticate_user, only: [:create, :update, :destroy]
  before_action :set_book
  attr_reader :book

  private

  def set_book
    @book = Book.find(params[:book_id])
  end
end
