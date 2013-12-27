require 'forwardable'

class Email
  extend Forwardable

  attr_reader :filepath, :category
  def_delegators :@mail, :subject, :content_type

  def initialize(filepath, category = nil)
    @filepath = filepath
    @category = category
    @mail = Mail.read(filepath)
  end

  def body
    stripped_content = simplify(@mail.content_type)
    if @mail.multipart?
      multipart_body
    elsif %w[text/plain text/html].include?(stripped_content)
      single_body(@mail.body.decoded, stripped_content)
    else
      ''
    end
  end

  def blob
    "#{body.to_s.force_encoding('UTF-8')}\n#{subject.to_s.force_encoding('UTF-8')}"
  end

  private
  def simplify(content_type)
    content_type.to_s.split(';').first
  end

  def single_body(body, content_type)
    case content_type
    when 'text/html'
      Nokogiri::HTML.parse(body).inner_text
    when 'text/plain'
      body.to_s
    else
      ''
    end
  end

  def multipart_body
    buffer = ''
    @mail.parts.each do |part|
      buffer += single_body(part.body.decoded, simplify(part.content_type)).force_encoding('UTF-8')
    end
    buffer
  end
end