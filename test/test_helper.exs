defmodule EdgeBuilder.Test do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExSpec

      def has_error?(changeset, field, error_text) do
        Keyword.get_values(changeset.errors, field)
          |> Enum.member?(error_text)
      end
    end
  end

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(EdgeBuilder.Repo)
    :ok
  end

  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(EdgeBuilder.Repo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(EdgeBuilder.Repo, []) end
    :ok
  end
end

defmodule EdgeBuilder.ControllerTest do
  use ExUnit.CaseTemplate

  using do
    quote do
      use EdgeBuilder.Test
      use Plug.Test

      @session Plug.Session.init(
        store: :cookie,
        key: "app",
        encryption_salt: "asd",
        signing_salt: "asd"
      )

      def request(verb, path, params \\ %{}, f \\ &(&1)) do
        conn(verb, path, params)
          |> Map.put(:secret_key_base, "this is a string that is at least 64 bytes in length aaaaaaaaaaaaaaaaaaaa")
          |> Plug.Session.call(@session)
          |> fetch_session
          |> f.()
          |> put_private(:plug_skip_csrf_protection, true)
          |> EdgeBuilder.Router.call([])
      end

      def authenticated_request(user, verb, path, params \\ %{}) do
        request(verb, path, params, fn(conn) -> put_session(conn, :current_user_id, user.id) end)
      end

      def is_redirect_to?(conn, path) do
        Enum.member?(conn.resp_headers, {"Location", path}) 
      end
    end
  end
end

Enum.each(Path.wildcard("test/helpers/**/*.exs"), &Code.load_file/1)
Enum.each(Path.wildcard("test/fixtures/**/*.exs"), &Code.load_file/1)

ExUnit.start
