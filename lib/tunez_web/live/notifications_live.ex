defmodule TunezWeb.NotificationsLive do
  # LIVEVIEW FOR NOTIFICATIONS (FUTURE ASH INTEGRATION)
  # ====================================================
  # This LiveView manages user notifications
  # Currently a stub implementation - ready for Ash integration
  # 
  # POTENTIAL ASH ENHANCEMENTS:
  # - Create a Notification resource with Ash
  # - Use Ash queries to fetch user-specific notifications
  # - Implement read/unread status with Ash actions
  # - Add real-time updates with Ash.Notifier

  use TunezWeb, :live_view

  # MOUNT CALLBACK
  # ==============
  # Initialize with empty notifications
  def mount(_params, _session, socket) do
    # TODO: Replace with Ash query
    # Example with Ash:
    # notifications = MyApp.Notifications.read_notifications!(
    #   filter: [user_id: current_user.id, read: false],
    #   sort: [inserted_at: :desc],
    #   load: [:album, album: :artist]
    # )
    notifications = []
    {:ok, assign(socket, notifications: notifications)}
  end

  # RENDER FUNCTION
  # ===============
  # Displays notification bell with dropdown
  def render(assigns) do
    ~H"""
    <div class="relative">
      <!-- NOTIFICATION BELL ICON -->
      <!-- Shows red indicator when notifications exist -->
      <div
        phx-click={toggle("#notifications")}
        phx-click-away={hide("#notifications")}
        class="p-1 mt-1 cursor-pointer relative"
      >
        <.icon name="hero-bell-alert" class="w-8 h-8 bg-gray-400" />
        <!-- Animated ping effect for new notifications -->
        <span :if={@notifications != []} class="absolute flex h-3 w-3 top-0 right-0 mt-1 mr-1.5">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-error-600 opacity-75">
          </span>
          <span class="relative inline-flex rounded-full h-3 w-3 bg-error-600"></span>
        </span>
      </div>
      
    <!-- NOTIFICATIONS DROPDOWN -->
      <div id="notifications" class="z-10 hidden absolute top-10 right-0 bg">
        <!-- Empty state -->
        <div :if={@notifications == []} class="p-2 shadow bg-white rounded-lg w-52">
          <.icon name="hero-check-circle" class="w-8 h-8 bg-green-500" />
          <span class="text-sm px-2">No new notifications!</span>
        </div>
        
    <!-- Notification list -->
        <!-- With Ash, each notification would be a resource with relationships -->
        <ul
          :if={@notifications != []}
          tabindex="0"
          class="p-2 shadow bg-white rounded-lg w-80 text-sm space-y-4"
        >
          <li :for={notification <- @notifications}>
            <!-- NOTIFICATION ITEM -->
            <!-- Links to the relevant album, dismisses on click -->
            <.link
              navigate={~p"/artists/#{notification.album.artist_id}/#album-#{notification.album_id}"}
              phx-click={
                JS.push("dismiss-notification", value: %{id: notification.id})
                |> hide("#notifications")
              }
              class="grid grid-flow-col gap-2 cursor-pointer px-3 py-1"
            >
              <p>
                <!-- Notification content with loaded relationships -->
                <!-- These would come from Ash's relationship loading -->
                The album
                <span class="font-bold">{notification.album.name}</span>
                has been added for {notification.album.artist.name}<br />
                <span class="text-xs opacity-60">{time_ago_in_words(notification.inserted_at)}</span>
              </p>
              <div class="h-16 w-16">
                <.cover_image image={notification.album.cover_image_url} />
              </div>
            </.link>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  # EVENT HANDLER FOR DISMISSING NOTIFICATIONS
  # ===========================================
  def handle_event("dismiss-notification", %{"id" => _id}, socket) do
    # TODO: Implement with Ash action
    # Example with Ash:
    # notification = MyApp.Notifications.get_notification_by_id!(id)
    # 
    # Option 1: Mark as read
    # {:ok, _} = MyApp.Notifications.mark_as_read(notification)
    # 
    # Option 2: Delete notification
    # :ok = MyApp.Notifications.destroy_notification(notification)
    # 
    # Then refresh the notifications list
    {:noreply, socket}
  end

  # POTENTIAL ASH NOTIFICATION RESOURCE
  # ====================================
  # Example of how a Notification resource might look:
  # 
  # defmodule MyApp.Notifications.Notification do
  #   use Ash.Resource, data_layer: AshPostgres.DataLayer
  #   
  #   attributes do
  #     uuid_primary_key :id
  #     attribute :type, :atom, allow_nil?: false
  #     attribute :read, :boolean, default: false
  #     attribute :data, :map  # Store notification-specific data
  #     timestamps()
  #   end
  #   
  #   relationships do
  #     belongs_to :user, MyApp.Accounts.User
  #     belongs_to :album, Tunez.Music.Album  # Optional, depending on type
  #   end
  #   
  #   actions do
  #     defaults [:read, :destroy]
  #     
  #     update :mark_as_read do
  #       change set_attribute(:read, true)
  #     end
  #     
  #     create :notify_new_album do
  #       accept [:user_id, :album_id]
  #       change set_attribute(:type, :new_album)
  #     end
  #   end
  # end
end
