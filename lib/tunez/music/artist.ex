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
    table("artists")
    
    # The Ecto repo module used for database operations
    # This should match the repo configured in your application
    repo(Tunez.Repo)
  end

  # ATTRIBUTES BLOCK
  # ================
  # Defines the data fields for this resource
  # These become columns in your database table
  attributes do
    # Creates an :id field with type Ash.Type.UUID
    # Automatically generates UUIDs for new records
    # Also marks this as the primary key
    uuid_primary_key(:id)

    # String attribute for the artist's name
    # The do/end block allows additional configuration
    attribute :name, :string do
      # Makes this field required (cannot be nil or omitted)
      # Database constraint: NOT NULL
      allow_nil?(false)
    end

    # Optional text field for artist biography
    # No block needed when using defaults (allow_nil? defaults to true)
    attribute(:biography, :string)

    # Automatically managed timestamp fields
    # inserted_at: Set once when record is created
    # updated_at: Updated every time the record changes
    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
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
    defaults([:create, :read, :update, :destroy])
    
    # Sets which attributes can be modified by default in create/update actions
    # This applies to all actions unless specifically overridden
    # Protects against mass assignment of unwanted fields
    default_accept([:name, :biography])
    
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

    # destroy :destroy do
    #   # Could add soft delete logic, cascading rules, or validations here
    # end
  end

  # RELATIONSHIPS BLOCK
  # ===================
  # Defines how this resource relates to other resources
  # Creates functions for loading and managing related data
  relationships do
    # One-to-many relationship: One artist can have many albums
    # This doesn't create a database column on the artists table
    # Instead, it expects albums table to have an artist_id foreign key
    # 
    # Enables:
    # - Ash.load(artist, :albums) to fetch related albums
    # - Cascading deletes if configured
    # - Aggregate queries (e.g., count of albums)
    has_many(:albums, Tunez.Music.Album)
  end
end
