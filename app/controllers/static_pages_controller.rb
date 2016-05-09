class StaticPagesController < ApplicationController
  def index
    @quotes = Quote.order(idealness: :desc)

  end

  def data_builder_thingy


  end
end
