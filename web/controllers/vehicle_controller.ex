defmodule EdgeBuilder.VehicleController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Models.VehicleAttack
  alias EdgeBuilder.Models.VehicleAttachment

  plug Plug.Authentication, except: [:show]
  plug :action

  def new(conn, _params) do
    render conn, :new,
      title: "New Vehicle",
      vehicle: %Vehicle{} |> Vehicle.changeset(current_user_id(conn)),
      vehicle_attacks: [%VehicleAttack{} |> VehicleAttack.changeset],
      vehicle_attachments: [%VehicleAttachment{} |> VehicleAttachment.changeset]
  end

  def create(conn, _params) do
  end
end
