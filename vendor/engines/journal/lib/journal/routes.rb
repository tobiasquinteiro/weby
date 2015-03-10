#Journal::Engine.routes.draw do
#
#  constraints(Weby::Subdomain) do
#
#    get 'admin' => 'admin/news#index'
#    namespace :admin do
#      resources :news do
#        member do
#          put :toggle, :recover
#        end
#        collection do
#          get :recycle_bin, :fronts
#        end
#      end
#    end
#
#    resources :news, only: [:show, :index]
#  end
#
#  root to: 'news#index'
#
#end
module Journal
  module Routes
    def self.load(*args)
      Proc.new do
        namespace :admin, module: 'journal/admin' do
          get :journal, to: 'news#index'
          resources :news do
            member do
              put :toggle, :recover, :share, :unshare
              get :newsletter
              post :newsletter_histories
            end
            collection do
              get :recycle_bin, :fronts
              post :sort
            end
          end
        end
        resources :news, module: :journal, path: 'n', only: [:show] do
          collection do
            post :sort
          end
        end
        get :news, to: 'journal/news#index', as: :news_index
        get '/feed' => 'journal/news#index', as: :site_feed,
            defaults: { format: 'rss', per_page: 10, page: 1 }
        resources :newsletters, module: :journal, only: [:new, :show]
      end
    end
  end
end
