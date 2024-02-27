
require 'openssl'
require 'base64'
require 'pdf/reader'

class PdfsController < ApplicationController
  def sign
    # Load your private key
    private_key_path = Rails.root.join('config', 'private_key.pem')
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))

    # Load the PDF file to sign
    pdf_path = Rails.root.join('config', 'test-1.pdf')
    pdf_content = File.binread(pdf_path)

    # Create a signature
    signature = private_key.sign(OpenSSL::Digest::SHA256.new, pdf_content)

    # Encode the signature as Base64
    signature_base64 = Base64.strict_encode64(signature)

    # Embed the signature in the PDF
    signed_pdf_content = pdf_content + "\n\nSignature: #{signature_base64}"

    # Save the signed PDF to a file
    signed_pdf_path = Rails.root.join('config', 'signed_test-1.pdf')
    File.open(signed_pdf_path, 'wb') do |file|
      file.write(signed_pdf_content)
    end

    # Send the signed PDF as a response
    send_file signed_pdf_path
  end

  def verify_signature
    # Load the signed PDF file
    pdf_path = Rails.root.join('config', 'signed_test-1.pdf')
    pdf_content = File.binread(pdf_path)

    # Extract the signature from the PDF
    signature_base64 = pdf_content.split("\n\nSignature: ").last.strip

    # Decode the signature from Base64
    signature = Base64.strict_decode64(signature_base64)


    # Load your public key
    public_key_path = Rails.root.join('config', 'public_key.pem')
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_path))

    # Verify the signature using OpenSSL
    verified = public_key.verify(OpenSSL::Digest::SHA256.new, signature, pdf_content.chomp(signature_base64))

    result = {
      signature_base64: signature_base64, # Include the Base64-encoded signature in the result
      verified: verified,
      message: verified ? 'PDF is digitally signed and the signature is valid.' : 'PDF is digitally signed but the signature is invalid.'
    }

    render json: result
  rescue StandardError => e
    render plain: "Error verifying signature: #{e.message}"
  end

end



