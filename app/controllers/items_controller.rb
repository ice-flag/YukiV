class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
    if params[:search]
      @items = Item.search(params[:search]).order("created_at DESC")
      @csv_items = Item.order("id ASC")
    elsif params[:psearch]
      @items = Item.psearch(params[:psearch]).order("created_at DESC")
      @item = Item.psearch(params[:psearch]).first
      @csv_items = Item.order("id ASC")
      @product = Product.new
    else
      @items = []
      @csv_items = Item.order("id ASC")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
      format.csv
    end
  end

  # For importing the reference list
  def import
    Item.import(params[:file])
    redirect_to items_path, notice: "Reference list updated! Lekkuuurrrr!"
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])
    @product = Product.new
    @barcode = Barby::Code39.new @item.id.to_s

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
      format.json { head :no_content }
    end
  end
end
