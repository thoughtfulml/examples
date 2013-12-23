require_relative '../spec_helper'

describe Email do
  describe 'plaintext' do
    let(:plain_file) { './test/fixtures/plain.eml' }
    let(:plaintext) { File.read(plain_file) }
    let(:plain_email) { Email.new(plain_file) }

    it 'parses and stores the plain body' do
      body = plaintext.split("\n\n")[1..-1].join("\n\n")
      plain_email.body.must_equal body
    end

    it 'parses the subject' do
      subject = plaintext.match(/^Subject: (.*)$/)[1]
      plain_email.subject.must_equal subject
    end
  end

  describe 'multipart' do
    let(:multipart_file) { './test/fixtures/multipart.eml' }
    let(:multipart) { File.read(multipart_file) }
    let(:multipart_email) { Email.new(multipart_file) }

    it 'parses and stores a concatenated body of text' do
      internal_mail = multipart_email.instance_variable_get("@mail")
      assert internal_mail.multipart?
      body = ''
      internal_mail.parts.each do |part|
        if part.content_type =~ /text\/plain/
          body += part.body.decoded
        elsif part.content_type =~ /text\/html/
          body += Nokogiri::HTML.parse(part.body.decoded).inner_text
        else
          body += ''
        end
      end

      multipart_email.body.must_equal body
    end

    it 'stores subject like all the rest' do
      subject = multipart.match(/^Subject: (.*)$/)[1]
      multipart_email.subject.must_equal subject
    end
  end

  describe 'html' do
    let(:html_file) { './test/fixtures/html.eml' }
    let(:html) { File.read(html_file) }
    let(:html_email) { Email.new(html_file) }

    it "parses and stores the html body's inner_text" do
      body = html.split("\n\n")[1..-1].join("\n\n")
      html_email.body.must_equal Nokogiri::HTML.parse(body).inner_text
    end

    it "stores subject like plaintext does as well" do
      subject = html.match(/^Subject: (.*)$/)[1]
      html_email.subject.must_equal subject
    end
  end
end