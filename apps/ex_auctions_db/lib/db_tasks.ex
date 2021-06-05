defmodule ExAuctionsDB.ReleaseTasks do
  @moduledoc """
  Release tasks
  """

  import Ecto.Query
  alias Ecto.Migrator

  require Logger

  @app :ex_auctions_db
  @repo ExAuctionsDB.Repo

  def db_create do
    Application.load(@app)
    db_config = Application.get_env(@app, @repo)

    if db_config[:create] do
      Logger.info("Creating database...")

      case @repo.__adapter__().storage_up(db_config) do
        :ok ->
          Logger.info("Database created")

        {:error, :already_up} ->
          Logger.info("Database already exists")

        {:error, reason} ->
          raise "Database creation failed (#{reason})"
      end
    else
      Logger.info("Creating db is not permitted in repo config, skipping...")
    end
  end

  def db_migrate do
    Application.load(@app)
    Logger.info("Running migrations for #{@app} ...")
    {:ok, _, _} = Migrator.with_repo(@repo, &Migrator.run(&1, :up, all: true))
  end
end
