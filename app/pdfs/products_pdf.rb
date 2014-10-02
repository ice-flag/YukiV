require 'barby'
require 'barby/barcode/code_39'
require 'barby/outputter/prawn_outputter'

class ProductsPdf < Prawn::Document
  def initialize(products)
    super(top_margin: 70)
    @products = products
    label_pages

  end

  def grid_system
    define_grid(:columns => 5, :rows => 8, :gutter => 10)
  end

  # def barcode
  #   barcode = Barby::Code39.new @product.id.to_s
  #   barcode.annotate_pdf(self)
  # end

  def label_pages
    define_grid(:columns => 5, :rows => 8, :gutter => 10)
    @products.each do |product|
      grid([-1,0], [-1,1]).bounding_box do
        barcode = Barby::Code39.new product.id.to_s
        barcode.annotate_pdf(self)
      end

      grid([-0.5,4], [-0.5,4]).bounding_box do
        text "ID: #{product.id.to_s}", size: 14, :align => :right
      end

      grid([0,0], [1,4]).bounding_box do
        text "AP AUTO ONDERDELEN", :align => :center, size: 34, style: :bold
        text "De auto onderdelen discounter van Nederland", :align => :center, style: :bold, size: 24
        stroke_horizontal_rule
      end

      grid([1,0], [3,4]).bounding_box do
        text "Bedankt voor uw bestelling. Naast uitlaten leveren wij ook banden, bodyparts, lampen en overige auto toebehoren. Voor een overzicht van onze catalogus kijk op catalogus.ap-onderdelen.nl.", :align => :left, size: 24
      end

      grid([3,0], [5,4]).bounding_box do
        text "Scan de onderstaande QR code (of ga naar de website link naast de code) om uw bestelling in te zien. U kunt daar uw factuur downloaden, retour procedures vinden en product informatie bekijken.", :align => :left, size: 24
      end


      # For make + model but not present yet
      # grid([5,0], [7,0]).bounding_box do
      #   text "Product code:", :align => :left, size: 20
      #   text "Merk", :align => :left, size: 20
      #   text "Model", :align => :left, size: 20
      # end

      # grid([5,1], [7,1]).bounding_box do
      #   text "#{Item.find(product.item_id).reference_number}", :align => :left, size: 20
      #   text "", :align => :left, size: 20
      #   text "", :align => :left, size: 20
      # end

      grid([5,0], [7,1]).bounding_box do
        barcode = Barby::Code39.new product.id.to_s
        barcode.annotate_pdf(self)
        text "Product code:", :align => :center, size: 34
        move_down 15
        text "#{Item.find(product.item_id).reference_number}", :align => :center, size: 40, style: :bold
        move_down 45
        text "<u>http://order.ap-onderdelen.nl/products/#{product.id}</u>", :align => :left, size: 14, :inline_format => true
      end

      grid([5,2], [7,4]).bounding_box do
        print_qr_code("http://order.ap-onderdelen.nl/products/#{product.id}/activate")
      end

      start_new_page
    end
  end

  # The default size for QR Code modules is 1/72 in
  DEFAULT_DOTSIZE = 7

  def qr_content
    "http://yukiv.herokuapp.com/products/#{@product.id}"
  end

  def print_qr_code(content, *options)
    opt = options.extract_options!
    qr_version = 0
    level = opt[:level] || :l
    extent = opt[:extent]
    dot_size = DEFAULT_DOTSIZE
    begin
      qr_version +=1
      qr_code = RQRCode::QRCode.new(content, :size=>qr_version, :level=>level)

      dot_size = extent/(8+qr_code.modules.length) if extent
      render_qr_code(qr_code, :dot=>dot_size, :pos=>opt[:pos], :stroke=>opt[:stroke], :align=> :right)
    rescue RQRCode::QRCodeRunTimeError
      if qr_version <40
        retry
      else
        raise
      end
    end
  end

  def render_qr_code(qr_code, *options)
    opt = options.extract_options!
    dot = DEFAULT_DOTSIZE
    extent= opt[:extent] || (8+qr_code.modules.length) * dot
    stroke = (opt.has_key?(:stroke) && opt[:stroke].nil?) || opt[:stroke]
    foreground_color = opt[:foreground_color] || '000000'
    background_color = opt[:background_color] || 'FFFFFF'
    stroke_color = opt[:stroke_color] || '000000'

    pos = opt[:pos] ||[0, cursor]

    align = opt[:align]
    case(align)
    when :center
      pos[0] = (@bounding_box.right / 2) - (extent / 2) 
    when :right
      pos[0] = @bounding_box.right - extent
    when :left
      pos[0] = 0;
    end

    stroke_color stroke_color
    fill_color background_color

    bounding_box pos, :width => extent, :height => extent do |box|
      fill_color foreground_color

      if stroke
        stroke_bounds
      end

      pos_y = 4*dot +qr_code.modules.length * dot

      qr_code.modules.each_index do |row|
        pos_x = 4*dot
        dark_col = 0
        qr_code.modules.each_index do |col|
          move_to [pos_x, pos_y]
          if qr_code.dark?(row, col)
            dark_col = dark_col+1
          else
            if (dark_col>0)
              fill { rectangle([pos_x - dark_col*dot, pos_y], dot*dark_col, dot) }
              dark_col = 0
            end
          end
          pos_x = pos_x + dot
        end
        if (dark_col > 0)
          fill { rectangle([pos_x - dark_col*dot, pos_y], dot*dark_col, dot) }
        end
        pos_y = pos_y - dot
      end
    end
  end
end