defmodule Tunez.Repo do
  use AshPostgres.Repo,
    otp_app: :tunez

  @impl true
  def installed_extensions do
    # POSTGRESQL EXTENSIONS
    # =====================
    # Extensions that must be installed in the database for this application
    # The migration generator will automatically create them when running migrations
    #
    # ASH-FUNCTIONS EXTENSION
    # -----------------------
    # - Required by Ash framework for advanced query functions
    # - Enables the 'contains' function used in filters (e.g., Artist.search action)
    # - Provides additional SQL functions for complex Ash queries
    #
    # PG_TRGM EXTENSION (PostgreSQL Trigram)
    # ----------------------------------------
    # - Enables trigram-based operations for fuzzy string matching
    # - Required for GIN indexes with gin_trgm_ops operator class
    # - Powers similarity searches using % operator
    # - Supports ILIKE pattern matching optimization
    # - Used by Artist resource for fast name searches
    #
    # Documentation: https://hexdocs.pm/ash_postgres/AshPostgres.Repo.html
    ["ash-functions", "pg_trgm"]
  end

  # Don't open unnecessary transactions
  # will default to `false` in 4.0
  @impl true
  def prefer_transaction? do
    false
  end

  @impl true
  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
