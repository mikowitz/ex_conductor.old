defmodule ExConductorWeb.PageLiveTest do
  use ExConductorWeb.ConnCase

  import Phoenix.LiveViewTest

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

  def join_button do
    "form#join-ensemble button"
  end

  def change_button do
    "button#change-instrument"
  end
end
