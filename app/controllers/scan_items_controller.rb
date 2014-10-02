class ScanItemsController < ApplicationController
  def incoming
    if params[:psearch]
      @items = Item.psearch(params[:psearch]).order("created_at DESC")
      @item = Item.psearch(params[:psearch]).first
      @csv_items = Item.order("id ASC")
      @product = Product.new
    else
      @items = []
      @csv_items = Item.order("id ASC")
    end
  end

  def warehouse_in
    if params[:search]
      @product = Product.search(params[:search])
    else
      @product = []
    end
  end

  def warehouse_out
  end
end
