
require 'openssl'
require 'base64'
require 'pdf/reader'

class PdfsController < ApplicationController
  def sign
    # Load your private key
    private_key_path = Rails.root.join('config', 'private_key.pem')
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))

    # Load the PDF file to sign
    pdf_path = Rails.root.join('config', 'sample_pdf.pdf')
    pdf_content = File.binread(pdf_path)

    # Create a signature
    signature = private_key.sign(OpenSSL::Digest::SHA256.new, pdf_content)

    # Encode the signature as Base64
    signature_base64 = Base64.strict_encode64(signature)

    # Embed the signature in the PDF
    signed_pdf_content = pdf_content + "\n\nSignature: #{signature_base64}"

    # Save the signed PDF to a file
    signed_pdf_path = Rails.root.join('config', 'signed_sample.pdf')
    File.open(signed_pdf_path, 'wb') do |file|
      file.write(signed_pdf_content)
    end

    # Send the signed PDF as a response
    send_file signed_pdf_path
  end

  def verify_signature
    pdf_path = Rails.root.join('config', 'signed_sample.pdf')
    pdf_content = File.binread(pdf_path)
    signature_base64 = pdf_content.split("\n\nSignature: ").last
    signature = Base64.strict_decode64(signature_base64)

    # Load your public key
    public_key_path = Rails.root.join('config', 'public_key.pem')
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_path))

    if public_key.verify(OpenSSL::Digest::SHA256.new, signature, pdf_content.chomp(signature_base64))
      render plain: 'PDF is digitally signed.'
    else
      render plain: 'PDF is not digitally signed.'
    end
  end
end









# class PdfsController < ApplicationController
#   def sign


    #  # Load your private key
    #  private_key_path = Rails.root.join('config', 'private_key.pem')
    #  private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))

    # # Load the PDF file to sign
    # pdf_path = Rails.root.join('config', 'sample_pdf.pdf')
    # pdf_content = File.binread(pdf_path)

#     # Create a signature
#     signature = Base64.encode64(private_key.sign(OpenSSL::Digest::SHA256.new, pdf_content))

#     # Generate a new PDF with the signature
#     signed_pdf_path = Rails.root.join('config', 'signed_sample.pdf')
#     Prawn::Document.generate(signed_pdf_path) do
#       text 'Hello, world!'
#       self.signature(signature)
#     end

#     # Send the signed PDF as a response
#     send_file signed_pdf_path
#   end
# end
