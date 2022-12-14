defmodule TicTacToeWeb.Router do
  alias TicTacToeWeb.PlayerNameController
  alias TicTacToeWeb.RequirePlayerName

  use TicTacToeWeb, :router

  import TicTacToeWeb.SessionUtils, only: [maybe_create_user_session: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TicTacToeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :maybe_create_user_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_player_name do
    plug RequirePlayerName
  end

  scope "/" do
    pipe_through :browser
    post "/", PlayerNameController, :save_player_name
  end

  scope "/", TicTacToeWeb do
    pipe_through :browser

    live "/", PageLive.Root, :root

    pipe_through :require_player_name

    live "/game/:game_id", PageLive.Game, :game
  end

  # Other scopes may use custom stacks.
  # scope "/api", TicTacToeWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TicTacToeWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
