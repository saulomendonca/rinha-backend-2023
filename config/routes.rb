Rails.application.routes.draw do
  resources :pessoas
  get 'contagem-pessoas' => 'contagem_pessoas#show'
end
