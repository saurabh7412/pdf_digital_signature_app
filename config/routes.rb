Rails.application.routes.draw do
  root 'pdfs#index'
  get 'pdfs/sign'
  get 'pdfs/verify_signature'
end
