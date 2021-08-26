defmodule ExConductorWeb.ScoreGenerationTest do
  use ExConductorWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExConductor.AccountsFixtures

  setup do
    user = AccountsFixtures.user_fixture()
    admin = AccountsFixtures.admin_user_fixture()

    ExConductor.EnsembleRegistry.reset!()

    {:ok, %{user: user, admin: admin}}
  end

  describe "before any instruments have joined" do
    test "by default, no score is visible", %{user: user, conn: conn} do
      {:ok, view, _} = log_in(conn, user)

      refute score_visible?(view)
    end

    test "the admin cannot generate a score", %{admin: admin, conn: conn} do
      {:ok, admin_view, _} = log_in(conn, admin, "/admin")

      refute has_element?(admin_view, "button#generate-score")
    end
  end

  describe "after an instrument has joined" do
    test "no score is visible", %{user: user, conn: conn} do
      {:ok, view, _} = log_in(conn, user)

      join(view, "violin")

      refute has_element?(view, "img.score")
    end

    test "the admin can generate a score", %{admin: admin, user: user, conn: conn} do
      {:ok, view, _} = log_in(conn, user)
      {:ok, admin_view, _} = log_in(conn, admin, "/admin")

      join(view, "violin")

      assert has_element?(admin_view, "button#generate-score")
    end
  end

  describe "after a score has been generated" do
    test "a user cannot change instrument", %{admin: admin, user: user, conn: conn} do
      {:ok, view, _} = log_in(conn, user)
      {:ok, admin_view, _} = log_in(conn, admin, "/admin")

      join(view, "violin")

      generate_score(admin_view)

      assert score_visible?(admin_view)
      assert score_visible?(view)

      refute has_element?(view, "button#change-instrument")
    end

    test "a user can open a second window and see the score", %{
      admin: admin,
      user: user,
      conn: conn
    } do
      {:ok, view, _} = log_in(conn, user)
      {:ok, admin_view, _} = log_in(conn, admin, "/admin")

      join(view, "violin")

      generate_score(admin_view)

      {:ok, view2, _} = log_in(conn, user)

      assert score_visible?(view2)
    end
  end

  def log_in(conn, user, path \\ "/") do
    conn |> log_in_user(user) |> live(path)
  end

  def score_visible?(view) do
    has_element?(view, "img.score")
  end

  def generate_score(view) do
    view
    |> element("button#generate-score")
    |> render_click()
  end

  def join(view, instrument) do
    view
    |> form("#join-ensemble", instrument: instrument)
    |> render_submit()
  end
end
