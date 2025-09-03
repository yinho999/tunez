defmodule Tunez.Music.Artist do
  # ASH RESOURCE CONFIGURATION
  # ==========================
  # An Ash Resource represents a data entity in your system (like a database table)
  # It defines attributes, actions, relationships, and business logic for that entity
  #
  # Options explained:
  # - otp_app: Links to your application for runtime configuration
  # - domain: The Ash.Domain this resource belongs to (for organization and code interface)
  # - data_layer: How data is persisted (AshPostgres for PostgreSQL database)
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  # POSTGRES DATA LAYER CONFIGURATION
  # ==================================
  # Configures how this resource maps to your PostgreSQL database
  postgres do
    # The actual database table name
    table "artists"

    # The Ecto repo module used for database operations
    # This should match the repo configured in your application
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artist_name_gin_index", using: "GIN"
    end
  end

  # ACTIONS BLOCK
  # =============
  # Actions define how you can interact with this resource
  # They're like controller actions but at the data layer
  actions do
    # Creates standard CRUD actions with default behavior:
    # - create: Insert new artist (accepts all public attributes)
    # - read: Query artists (supports filtering, sorting, pagination)
    # - update: Modify existing artist (accepts all public attributes)
    # - destroy: Delete an artist (handles relationship constraints)
    defaults [:create, :read, :destroy]

    # Sets which attributes can be modified by default in create/update actions
    # This applies to all actions unless specifically overridden
    # Protects against mass assignment of unwanted fields
    default_accept [:name, :biography]

    # COMMENTED EXAMPLES: Manual action definitions
    # These show how you could customize each action individually
    # The defaults() call above generates similar actions automatically

    # create :create do
    #   # Explicitly list which fields can be set during creation
    #   accept [:name, :biography]
    # end

    # read :read do
    #   # primary? true marks this as the default read action
    #   # Used when no action is specified in queries
    #   primary? true
    # end

    # update :update do
    #   # Control which fields can be modified during updates
    #   accept [:name, :biography]
    # end
    update :update do
      # Disable atomic updates to allow custom change functions to run
      # Atomic updates are Ash's optimization that updates records directly in the database
      # We need this set to false because our custom logic needs to run in Elixir
      require_atomic? false

      # Specify which fields users can modify in this update action
      accept [:name, :biography]

      # Custom change function to track artist name history when name changes
      # Only run this change function when the name field is actually being changed
      change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
    end

    # destroy :destroy do
    #   # Could add soft delete logic, cascading rules, or validations here
    # end

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end
      filter expr(contains(name, ^arg(:query)))
    end
  end

  # ATTRIBUTES BLOCK
  # ================
  # Defines the data fields for this resource
  # These become columns in your database table
  attributes do
    # Creates an :id field with type Ash.Type.UUID
    # Automatically generates UUIDs for new records
    # Also marks this as the primary key
    uuid_primary_key :id

    # String attribute for the artist's name
    # The do/end block allows additional configuration
    attribute :name, :string do
      # Makes this field required (cannot be nil or omitted)
      # Database constraint: NOT NULL
      allow_nil? false
    end

    # Optional text field for artist biography
    # No block needed when using defaults (allow_nil? defaults to true)
    attribute :biography, :string

    # Previous names of the artist after rebranding or other changes
    # Array of strings, defaults to an empty array
    attribute :previous_names, {:array, :string} do
      default []
    end

    # Automatically managed timestamp fields
    # inserted_at: Set once when record is created
    # updated_at: Updated every time the record changes
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  # RELATIONSHIPS BLOCK
  # ===================
  # Defines how this resource relates to other resources
  # Creates functions for loading and managing related data
  relationships do
    # ONE-TO-MANY RELATIONSHIP: Artist -> Albums
    # -------------------------------------------
    # One artist can have many albums
    # This doesn't create a database column on the artists table
    # Instead, it expects albums table to have an artist_id foreign key
    #
    # WHAT THIS ENABLES:
    # - Ash.load(artist, :albums) to fetch related albums
    # - Music.get_artist_by_id!(id, load: [:albums]) for eager loading
    # - Cascading deletes if configured in the data layer
    # - Aggregate queries (e.g., count of albums, latest album year)
    has_many :albums, Tunez.Music.Album do
      # DEFAULT SORT ORDER
      # ------------------
      # Albums are automatically sorted by year_released in descending order
      # This means newest albums appear first when loading the relationship
      # Example: artist.albums will return [2024 album, 2023 album, 2020 album...]
      #
      # This sort applies whenever albums are loaded through this relationship:
      # - Ash.load(artist, :albums)
      # - Music.get_artist_by_id!(id, load: [:albums])
      # - In LiveView when displaying artist albums
      sort year_released: :desc
    end
  end
end
