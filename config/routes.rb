BcmsKcfinder::Engine.routes.draw do
  get "browse" => "browse#index"
  get "browse/init" => "browse#init"
  get "browse/thumb" => "browse#thumb"
  post "browse/download" => "browse#download"
  post "browse/chDir" => "browse#change_dir"
  post "browse/upload" => "browse#upload"
  match "browse/:command" => "browse#command"
end
