require 'barby'
require 'barby/barcode/code_39'
require 'barby/outputter/prawn_outputter'

class ProductPdf < Prawn::Document
  def initialize(product, item)
    super(top_margin: 70)
    @product = product
    @item = item

    title
    print_qr_code(qr_content)
    barcode
  end

  def title
    text "#{@item.reference_number}"
  end

  def new_page
    start_new_page
  end

  # The default size for QR Code modules is 1/72 in
  DEFAULT_DOTSIZE = 5

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
      render_qr_code(qr_code, :dot=>dot_size, :pos=>opt[:pos], :stroke=>opt[:stroke], :align=>opt[:align])
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

  def barcode
    barcode = Barby::Code39.new @product.id.to_s
    barcode.annotate_pdf(self)
  end
end