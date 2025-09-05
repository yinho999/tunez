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
      reference(:artist, index?: true, on_delete: :delete)
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

  # changes do
  #   change set_attribute(:inserted_at, &DateTime.utc_now/0), on: [:create]
  #   change set_attribute(:updated_at, &DateTime.utc_now/0)
  # end

  # VALIDATIONS BLOCK
  # =================
  # Ash validations run during create/update actions
  # They provide business logic validation beyond database constraints
  # Validations run in the changeset phase before hitting the database
  validations do
    # YEAR VALIDATION
    # ---------------
    # Ensures albums have realistic release years
    validate(
      numericality(:year_released,
        # No albums before 1950 in our system
        greater_than: 1950,
        # Can't be future albums beyond next year
        less_than_or_equal_to: &__MODULE__.next_year/0
      ),
      # ASH BUILTIN: numericality validation
      # Checks numeric constraints on the field
      # CONDITIONAL VALIDATION: Only runs when conditions are met
      # present(:year_released) - only validate if the field has a value
      # This prevents validation errors on nil values
      where: [present(:year_released)],
      # CUSTOM ERROR MESSAGE: User-friendly error text
      # Overrides the default Ash validation message
      message: "must be between 1950 and next year"
    )

    # URL VALIDATION
    # --------------
    # Ensures cover images are from allowed sources with valid formats
    validate(match(:cover_image_url, ~r"^(https://|/images/).+(\.png|\.jpg)$"),
      # ASH BUILTIN: match validation
      # Uses regex pattern matching for string validation
      # CONDITIONAL VALIDATION: Only validate on changes
      # changing(:cover_image_url) - only run when this field is being modified
      # This skips validation for existing data that might not match new rules
      where: [changing(:cover_image_url)],
      # CUSTOM ERROR MESSAGE: Explains the requirement clearly
      message: "must be a valid URL starting with https:// or /images/ and end with .png or .jpg"
    )

    # VALIDATION EXECUTION ORDER:
    # 1. Attribute constraints (allow_nil?, type checking)
    # 2. Validations in the order they're defined
    # 3. Database constraints (foreign keys, unique indexes)
    #
    # VALIDATION CONTEXT:
    # - Validations have access to the entire changeset
    # - Can reference other fields for cross-field validation
    # - Can use custom validation modules for complex logic
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

  # HELPER FUNCTION FOR DYNAMIC VALIDATION
  # ========================================
  # Returns next year for validation upper bound
  # Using a function allows the validation to be dynamic over time
  def next_year, do: Date.utc_today().year + 1

  # RELATIONSHIPS BLOCK
  # ===================
  # Defines associations between resources
  relationships do
    # Many-to-one relationship: Many albums belong to one artist
    # This creates several things:
    # 1. An :artist_id attribute automatically (foreign key)
    # 2. Functions to load the related artist
    # 3. Ability to set artist during album creation
    belongs_to :artist, Tunez.Music.Artist do
      # Makes the relationship required (enforces foreign key NOT NULL)
      # Every album MUST have an artist
      # Prevents orphaned albums in the database
      allow_nil?(false)
    end
  end

  identities do
    identity(
      :unique_album_name_per_artist,
      [:name, :artist_id],
      message: "artist already has an album with this name"
    )
  end

  calculations do
    calculate(:years_ago, :integer, expr(2025 - year_released))
  end
end
