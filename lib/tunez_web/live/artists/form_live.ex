defmodule TunezWeb.Artists.FormLive do
  # ASHPHOENIX FORM INTEGRATION EXAMPLE
  # ====================================
  # This LiveView demonstrates the full AshPhoenix form lifecycle:
  # - Form generation using domain functions
  # - Real-time validation with AshPhoenix.Form.validate
  # - Form submission with AshPhoenix.Form.submit
  # 
  # This module handles both create and update operations using
  # the same form component, showcasing Ash's unified approach
  
  use TunezWeb, :live_view
  alias Tunez.Music, warn: false

  # MOUNT FOR EDIT MODE
  # ===================
  # When an ID is present, we're editing an existing artist
  def mount(%{"id" => id}, _session, socket) do
    # ASH: Fetch the existing artist using generated function
    artist = Music.get_artist_by_id!(id)
    
    # ASHPHOENIX: Generate an update form
    # Music.form_to_update_artist is NOT a standard Ash function
    # This would need to be defined in your domain's forms block:
    #   forms do
    #     form :update_artist
    #   end
    # 
    # OR you could use the standard AshPhoenix approach:
    #   form = AshPhoenix.Form.for_update(artist, :update)
    form = Music.form_to_update_artist(artist)

    socket =
      socket
      # IMPORTANT: to_form/1 converts AshPhoenix.Form to Phoenix.HTML.Form
      # This is required for Phoenix form helpers to work properly
      |> assign(:form, to_form(form))
      |> assign(:page_title, "Update Artist")

    {:ok, socket}
  end

  # MOUNT FOR CREATE MODE
  # =====================
  # No ID means we're creating a new artist
  def mount(_params, _session, socket) do
    # ASHPHOENIX: Generate a create form
    # Music.form_to_create_artist is NOT a standard Ash function
    # This would need to be defined in your domain's forms block:
    #   forms do
    #     form :create_artist
    #   end
    # 
    # OR you could use the standard AshPhoenix approach:
    #   form = AshPhoenix.Form.for_create(Tunez.Music.Artist, :create)
    form = Music.form_to_create_artist()

    socket =
      socket
      # Convert AshPhoenix.Form to Phoenix.HTML.Form
      |> assign(:form, to_form(form))
      |> assign(:page_title, "New Artist")

    {:ok, socket}
  end

  # RENDER FUNCTION
  # ===============
  # Standard Phoenix form with AshPhoenix event handlers
  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <.h1>{@page_title}</.h1>
      </.header>

      <!-- ASHPHOENIX FORM SETUP -->
      <!-- phx-change="validate" triggers real-time validation -->
      <!-- phx-submit="save" handles form submission -->
      <.simple_form
        :let={form}
        id="artist_form"
        as={:form}
        for={@form}
        phx-change="validate"
        phx-submit="save"
      >
        <!-- Form fields automatically map to Ash resource attributes -->
        <!-- These correspond to attributes defined in Tunez.Music.Artist -->
        <.input field={form[:name]} label="Name" />
        <.input field={form[:biography]} type="textarea" label="Biography" />
        <:actions>
          <.button type="primary">Save</.button>
        </:actions>
      </.simple_form>
    </Layouts.app>
    """
  end

  # ASHPHOENIX VALIDATION HANDLER
  # ==============================
  # Called on every form change for real-time validation
  def handle_event("validate", %{"form" => form_data}, socket) do
    # ASHPHOENIX: Real-time validation
    # AshPhoenix.Form.validate/2:
    # - Takes the current form and new params
    # - Runs Ash validations without hitting the database
    # - Returns an updated form with error messages
    # - Does NOT persist changes
    # 
    # This enables instant feedback for:
    # - Required fields (allow_nil?: false)
    # - Format validations (constraints)
    # - Custom validations defined in the resource
    socket = update(socket, :form, fn form -> AshPhoenix.Form.validate(form, form_data) end)

    {:noreply, socket}
  end

  # ASHPHOENIX SUBMISSION HANDLER
  # ==============================
  # Handles the final form submission
  def handle_event("save", %{"form" => form_data}, socket) do
    # ASHPHOENIX: Form submission
    # AshPhoenix.Form.submit/2:
    # - Validates the form data
    # - Executes the appropriate Ash action (create or update)
    # - Returns {:ok, resource} or {:error, form_with_errors}
    # 
    # This handles:
    # - Final validation
    # - Database constraints
    # - Business logic in Ash changes
    # - Authorization policies if configured
    case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
      {:ok, artist} ->
        # Success: Artist was created or updated
        socket =
          socket
          |> put_flash(:info, "Artist saved successfully")
          |> push_navigate(to: ~p"/artists/#{artist}")

        {:noreply, socket}

      {:error, form} ->
        # Failure: Form contains validation errors
        # The form now includes error messages for display
        socket =
          socket
          |> put_flash(:error, "Could not save artist data")
          # IMPORTANT: Convert back to Phoenix.HTML.Form with errors
          |> assign(:form, to_form(form))

        {:noreply, socket}
    end
  end
end