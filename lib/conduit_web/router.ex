defmodule ConduitWeb.Router do
  use ConduitWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :opt_auth do
    plug ConduitWeb.AuthOptPipeLine
  end

  pipeline :auth do
    plug ConduitWeb.AuthPipeLine
  end

  # 可选认证的
  scope "/api", ConduitWeb do
    pipe_through [:api, :opt_auth]

    post "/users", UserController, :create
    post "/users/login", UserController, :login

    get "/profiles/:username", ProfileController, :profile

    resources "/tags", TagController, only: [:index]

    resources "/articles", ArticleController, only: [:index, :show], param: "slug"
  end

  scope "/api", ConduitWeb do
    pipe_through [:api, :auth]

    get "/user", UserController, :current
    put "/user", UserController, :update

    post "/api/profiles/:username/follow", ProfileController, :follow
    delete "/api/profiles/:username/follow", ProfileController, :unfollow

    resources "/articles", ArticleController, only: [:create, :update, :delete], param: "slug"
  end
end
