Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "todo_lists#index"

  resources :projects do
    resources :todo_lists, only: [ :new, :create ]
  end

  resources :todo_lists do
    collection do
      patch :reorder_pinned
    end
    member do
      patch :toggle_pin
      post :attach_files
      delete "attachments/:attachment_id", to: "todo_lists#purge_attachment", as: :attachment
    end
  end

  namespace :api do
    namespace :v1 do
      get "openapi", to: "openapi#show", as: :openapi
      get "stats", to: "stats#show"
      post "markdown/render", to: "markdown#render_text"

      resources :projects, except: %i[new edit]

      resources :todo_lists, except: %i[new edit] do
        collection do
          patch :reorder_pinned
        end
        member do
          patch :toggle_pin
          get :attachments, to: "todo_list_attachments#index"
          post :attachments, to: "todo_list_attachments#create"
          delete "attachments/:attachment_id", to: "todo_list_attachments#destroy"
        end
      end
    end
  end
end
