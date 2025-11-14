defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "artists"
    repo Tunez.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :biography, :string do
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    # create :create do
    #   accept [:name, :biography]
    # end

    # read  :read do
    #   primary? true
    # end

    # update :update do
    #   accept [:name, :biography]
    # end

    # destroy :destroy do
    # end
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
