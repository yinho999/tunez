defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table("artists")
    repo(Tunez.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
    end

    attribute(:biography, :string)

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  actions do
    defaults([:create, :read, :update, :destroy])
    default_accept([:name, :biography])
    # create :create do
    #   accept [:name, :biography]
    # end

    # read :read do
    #   primary? true
    # end

    # update :update do
    #   accept [:name, :biography]
    # end

    # destroy :destroy do
    # end
  end

  relationships do
    has_many(:albums, Tunez.Music.Album)
  end
end
