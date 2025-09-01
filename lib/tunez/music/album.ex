defmodule Tunez.Music.Album do
  # ASH RESOURCE WITH POSTGRES INTEGRATION
  # =======================================
  # This resource represents an Album in your music database
  # It demonstrates relationships, foreign keys, and database indexing
  #
  # Configuration:
  # - otp_app: Application this resource belongs to (for config lookup)
  # - domain: Groups this with related resources (Tunez.Music)
  # - data_layer: AshPostgres enables PostgreSQL-specific features
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  # POSTGRES DATA LAYER CONFIGURATION
  # ==================================
  postgres do
    # Maps to the "albums" table in your PostgreSQL database
    table("albums")
    
    # Uses the configured Ecto repo for database operations
    repo(Tunez.Repo)

    # REFERENCES BLOCK
    # ----------------
    # Configures foreign key constraints and indexes at the database level
    # This is AshPostgres-specific and generates proper SQL migrations
    references do
      # Creates a foreign key reference to the artists table
      # index?: true creates a database index on artist_id column
      # 
      # Benefits of indexing foreign keys:
      # - Faster JOINs when loading albums with their artists
      # - Quicker lookups when finding all albums by a specific artist
      # - Improved performance for relationship queries
      reference(:artist, index?: true)
    end
  end

  # ATTRIBUTES BLOCK
  # ================
  # Defines the data schema for albums
  attributes do
    # Primary key field using UUID type
    # Provides better distribution than sequential IDs
    # Useful for distributed systems and prevents ID guessing
    uuid_primary_key(:id)

    # Album title - required field
    attribute :name, :string do
      # Enforces NOT NULL constraint in database
      # Validation will fail if name is nil or missing
      allow_nil?(false)
    end

    # Release year - required field
    # Using integer type for year (e.g., 1969, 2024)
    attribute :year_released, :integer do
      # Must have a value - prevents incomplete album records
      allow_nil?(false)
    end

    # Optional URL for album artwork
    # Can be nil (not all albums might have cover images)
    # Consider adding URL validation in production
    attribute(:cover_image_url, :string)

    # Automatic timestamp management
    # inserted_at: Timestamp when album was first created
    # updated_at: Timestamp of last modification
    # Ash automatically manages these - no manual updates needed
    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  # RELATIONSHIPS BLOCK
  # ===================
  # Defines associations between resources
  relationships do
    # Many-to-one relationship: Many albums belong to one artist
    # This creates several things:
    # 1. An :artist_id attribute automatically (foreign key)
    # 2. Functions to load the related artist
    # 3. Ability to set artist during album creation
    belongs_to(:artist, Tunez.Music.Artist) do
      # Makes the relationship required (enforces foreign key NOT NULL)
      # Every album MUST have an artist
      # Prevents orphaned albums in the database
      allow_nil?(false)
    end
  end

  # ACTIONS BLOCK
  # =============
  # Defines the operations that can be performed on albums
  actions do
    # Generates default read and destroy actions
    # - read: Query albums with filtering, sorting, pagination
    # - destroy: Delete an album (respects foreign key constraints)
    defaults([:read, :destroy])

    # Custom create action with specific accepted fields
    create :create do
      # Explicitly lists which fields can be set during album creation
      # Note: artist_id is included here (from the belongs_to relationship)
      # This allows setting the artist when creating an album:
      # Tunez.Music.create_album(%{
      #   name: "Abbey Road",
      #   year_released: 1969,
      #   cover_image_url: "http://...",
      #   artist_id: artist.id
      # })
      accept([:name, :year_released, :cover_image_url, :artist_id])
    end

    # Custom update action with controlled field access
    update :update do
      # Note: artist_id is NOT included - prevents changing album's artist
      # This is a business rule: albums shouldn't switch artists after creation
      # Only these fields can be modified in updates:
      accept([:name, :year_released, :cover_image_url])
    end
  end
end
