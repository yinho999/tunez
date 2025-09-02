defmodule Tunez.Music.Changes.UpdatePreviousNames do
  # This module is a reusable Ash Change that can be applied to any resource
  # Ash.Resource.Change provides the behavior for custom changeset transformations
  use Ash.Resource.Change

  # Implementation of the required change/3 callback from Ash.Resource.Change behavior
  # Called when this change is applied to an action (e.g., in update :update action)
  # Parameters:
  #   - changeset: The current Ash.Changeset containing both old data and new changes
  #   - _opts: Options passed to the change (not used here)
  #   - _context: The action context with metadata (not used here)
  @impl true
  def change(changeset, _opts, _context) do
    # before_action runs this code just before the database transaction
    # This ensures we have access to the latest data and changes
    # The function must return the modified changeset
    Ash.Changeset.before_action(changeset, fn changeset ->
      # Get the NEW name from user input (what the user wants to change to)
      # This uses get_attribute which retrieves the incoming change value
      new_name = Ash.Changeset.get_attribute(changeset, :name)

      # Get the CURRENT name stored in the database (before this update)
      # This uses get_data which retrieves the original database record
      previous_name = Ash.Changeset.get_data(changeset, :name)

      # Get the existing array of previous names from the database
      # This contains all the names this artist had before the current one
      previous_names = Ash.Changeset.get_data(changeset, :previous_names)

      # Build the updated previous names list:
      # 1. Add the current name (which is about to become "previous") to the front
      names =
        [previous_name | previous_names]
        # 2. Remove any duplicate names to keep the list clean
        |> Enum.uniq()
        # 3. Remove the new name if it exists in history (in case artist is reverting to an old name)
        # This prevents having the current active name also listed in previous names
        |> Enum.reject(fn name -> name == new_name end)

      # Update the previous_names attribute with the new list
      # This will be saved to the database when the changeset is applied
      Ash.Changeset.change_attribute(changeset, :previous_names, names)
    end)
  end
end

# USAGE EXAMPLE:
# This change module is used in the Artist resource like this:
#   update :update do
#     change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
#   end
#
# The `where: [changing(:name)]` condition ensures this only runs when the name actually changes
# This prevents unnecessary processing when updating other fields like biography
