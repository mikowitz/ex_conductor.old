defmodule ExConductorWeb.PageLiveTest do
  use ExConductorWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExConductor.AccountsFixtures

  # test "disconnected and connected render", %{conn: conn} do
  #   {:ok, page_live, disconnected_html} = live(conn, "/")

  #   assert disconnected_html =~ "Log in to join the ensemble"
  # end

  describe "not logged in" do
    test "cannot join the ensemble", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      refute has_element?(view, join_button())
      refute has_element?(view, change_button())
      assert html =~ ~r/Log in.*to join the ensemble/
    end
  end

  describe "logged in" do
    setup :register_and_log_in_user

    test "first sees the form to join the ensemble", %{conn: conn} do
      {:ok, view, _} = live(conn, "/")

      assert has_element?(view, join_button())
      refute has_element?(view, change_button())
    end

    test "can join the ensemble", %{conn: conn} do
      {:ok, view, _} = live(conn, "/")

      html =
        view
        |> form("#join-ensemble", instrument: "violin")
        |> render_submit()

      refute has_element?(view, join_button())
      assert has_element?(view, change_button())

      assert html =~ ~r/You are playing.*violin/
    end
  end

  describe "multiple users" do
    test "both can see when an instrument is selected", %{conn: conn} do
      user1 = AccountsFixtures.user_fixture()
      user2 = AccountsFixtures.user_fixture()

      {:ok, view1, _} = conn |> log_in_user(user1) |> live("/")
      {:ok, view2, _} = conn |> log_in_user(user2) |> live("/")

      view1
      |> form("#join-ensemble", instrument: "violin")
      |> render_submit()

      refute has_element?(view1, join_button())
      assert has_element?(view2, join_button())

      assert render(view1) =~ ~r/You are playing.*violin/
      assert render(view2) =~ "violin"

      view2
      |> form("#join-ensemble", instrument: "cello")
      |> render_submit()

      refute has_element?(view1, join_button())
      refute has_element?(view2, join_button())

      assert render(view2) =~ ~r/You are playing.*cello/
      assert render(view2) =~ "cello"
    end

    test "naming", %{conn: conn} do
      user1 = AccountsFixtures.user_fixture()
      user2 = AccountsFixtures.user_fixture()

      {:ok, view1, _} = conn |> log_in_user(user1) |> live("/")
      {:ok, view2, _} = conn |> log_in_user(user2) |> live("/")

      join(view1, "violin")
      join(view2, "violin")

      assert render(view1) =~ ~r/You are playing.*violin 1/
      assert render(view2) =~ ~r/You are playing.*violin 2/
    end
  end

  def join(view, instrument) do
    view
    |> form("#join-ensemble", instrument: instrument)
    |> render_submit()
  end

  def join_button do
    "form#join-ensemble button"
  end

  def change_button do
    "button#change-instrument"
  end
end
