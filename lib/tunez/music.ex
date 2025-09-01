defmodule Tunez.Music do
  # Ash.Domain is the core module that groups related resources together
  # It provides organization, a centralized code interface, and cross-cutting concerns
  # 
  # Options:
  # - otp_app: Links this domain to your OTP application for configuration
  # - extensions: Adds additional capabilities (AshPhoenix enables Phoenix form generation)
  use Ash.Domain, otp_app: :tunez, extensions: [AshPhoenix]

  # FORMS BLOCK (AshPhoenix Extension)
  # ===================================
  # Generates Phoenix form helper functions for LiveView/HTML forms
  # Each form definition creates a form_to_* function on this domain module
  # 
  # Example: This creates Tunez.Music.form_to_create_album/1
  # Usage in LiveView: 
  #   form = Tunez.Music.form_to_create_album(artist_id: artist.id)
  #   # Returns an %AshPhoenix.Form{} struct ready for use with Phoenix form helpers
  forms do
    # form/2 arguments:
    # - First arg: name of the action (must match a defined action below)
    # - args: positional arguments the form function will accept
    #         These become required parameters for the generated function
    form(:create_album, args: [:artist_id])
  end

  # RESOURCES BLOCK
  # ===============
  # Registers resources with this domain and defines their code interface
  # This is where you declare which resources belong to this business domain
  # and create convenient functions for interacting with them
  resources do
    # Each resource block registers that resource with this domain
    # The define/2 macro creates public functions on the domain module
    resource Tunez.Music.Artist do
      # Creates: Tunez.Music.create_artist/1 and create_artist!/1
      # The ! version raises on error, non-! returns {:ok, artist} or {:error, changeset}
      # Usage: {:ok, artist} = Tunez.Music.create_artist(%{name: "Beatles", biography: "..."})
      define(:create_artist, action: :create)
      
      # Creates: Tunez.Music.read_artists/0 and read_artists!/0
      # Returns a list of all artists (respecting any filters/pagination)
      # Usage: artists = Tunez.Music.read_artists!()
      define(:read_artists, action: :read)
      
      # Creates: Tunez.Music.get_artist_by_id/1 and get_artist_by_id!/1
      # get_by: :id makes this return a single result instead of a list
      # Also adds the :id as a required argument
      # Usage: artist = Tunez.Music.get_artist_by_id!(uuid)
      define(:get_artist_by_id, action: :read, get_by: :id)
      
      # Creates: Tunez.Music.update_artist/2 and update_artist!/2
      # First arg is the artist record, second is the attributes to update
      # Usage: {:ok, updated} = Tunez.Music.update_artist(artist, %{name: "The Beatles"})
      define(:update_artist, action: :update)
      
      # Creates: Tunez.Music.destroy_artist/1 and destroy_artist!/1
      # Accepts an artist record or ID
      # Usage: :ok = Tunez.Music.destroy_artist!(artist)
      define(:destroy_artist, action: :destroy)
    end

    resource Tunez.Music.Album do
      # Creates: Tunez.Music.create_album/1 and create_album!/1
      # Note: This matches the form defined above, enabling form generation
      # Usage: {:ok, album} = Tunez.Music.create_album(%{
      #   name: "Abbey Road", 
      #   year_released: 1969, 
      #   artist_id: artist.id
      # })
      define(:create_album, action: :create)
      
      # Creates: Tunez.Music.get_album_by_id/1 and get_album_by_id!/1
      # Fetches a single album by its ID
      # Usage: album = Tunez.Music.get_album_by_id!(album_id)
      define(:get_album_by_id, action: :read, get_by: :id)
      
      # Creates: Tunez.Music.update_album/2 and update_album!/2
      # Updates an existing album's attributes
      # Usage: {:ok, updated} = Tunez.Music.update_album(album, %{year_released: 1970})
      define(:update_album, action: :update)
      
      # Creates: Tunez.Music.destroy_album/1 and destroy_album!/1
      # Deletes an album from the database
      # Usage: :ok = Tunez.Music.destroy_album!(album)
      define(:destroy_album, action: :destroy)
    end
  end
end
