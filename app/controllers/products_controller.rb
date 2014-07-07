class ProductsController < ApplicationController
  before_filter :find_product, :only => [:show, :activate, :location, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.where("active = ? AND location IS NULL",false)
    @all_products = Product.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
      format.pdf do
        pdf = ProductsPdf.new(@products)
        send_data pdf.render, filename: "labels_#{@products.count}.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end

  def activate
    if @product.active? && @product.location.present?
      redirect_to product_path(@product)
    else
      Product.update(@product.id, active: true)
        redirect_to location_product_path(@product)
    end
  end

  def location
    
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @item = Item.find(@product.item_id)
    @qr = RQRCode::QRCode.new("#{request.original_url}", :size => 4, :level => :l )

    respond_to do |format|
      format.html
      format.json { render json: @product }
      format.pdf do
        pdf = ProductPdf.new(@product,@item)
        send_data pdf.render, filename: "item_#{@item.reference_number}.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit

  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        format.html { redirect_to item_path(@product.item_id), notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

private
  def find_product
    @product = Product.find(params[:id])
  end
end
