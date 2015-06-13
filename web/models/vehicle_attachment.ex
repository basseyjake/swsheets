defmodule EdgeBuilder.Models.VehicleAttachment do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.Vehicle

  schema "vehicle_attachments" do
    field :name, :string
    field :hard_points_required, :integer, default: 0
    field :base_modifiers, :string
    field :modifications, :string
    field :display_order, :integer, default: 0
    belongs_to :vehicle, Vehicle
  end

  def changeset(vehicle_attachments, params \\ %{}) do
    vehicle_attachments
    |> cast(params, [], ~w(vehicle_id name hard_points_required base_modifiers modifications display_order))
  end

  def is_default_changeset?(changeset) do
    default = struct(__MODULE__)

    Enum.all?([:name, :hard_points_required, :base_modifiers, :modifications], fn field ->
      Ecto.Changeset.get_field(changeset, field) == Map.fetch!(default, field)
    end)
  end
end
