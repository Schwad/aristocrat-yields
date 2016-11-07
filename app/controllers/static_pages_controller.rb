class StaticPagesController < ApplicationController
  def index
    authenticate
    @quotes = Quote.order(idealness: :desc)

  end

  def data_builder_thingy


  end
end
