defmodule PhxLearnWeb.ToDoLiveTest do
  use PhxLearnWeb.ConnCase

  import Phoenix.LiveViewTest
  import PhxLearn.ToDosFixtures

  @create_attrs %{deadline: "2024-12-17T06:14:00Z", done: true, name: "some name"}
  @update_attrs %{deadline: "2024-12-18T06:14:00Z", done: false, name: "some updated name"}
  @invalid_attrs %{deadline: nil, done: false, name: nil}

  defp create_to_do(_) do
    to_do = to_do_fixture()
    %{to_do: to_do}
  end

  describe "Index" do
    setup [:create_to_do]

    test "lists all todos", %{conn: conn, to_do: to_do} do
      {:ok, _index_live, html} = live(conn, ~p"/todos")

      assert html =~ "Listing Todos"
      assert html =~ to_do.name
    end

    test "saves new to_do", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> element("a", "New To do") |> render_click() =~
               "New To do"

      assert_patch(index_live, ~p"/todos/new")

      assert index_live
             |> form("#to_do-form", to_do: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#to_do-form", to_do: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/todos")

      html = render(index_live)
      assert html =~ "To do created successfully"
      assert html =~ "some name"
    end

    test "updates to_do in listing", %{conn: conn, to_do: to_do} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> element("#todos-#{to_do.id} a", "Edit") |> render_click() =~
               "Edit To do"

      assert_patch(index_live, ~p"/todos/#{to_do}/edit")

      assert index_live
             |> form("#to_do-form", to_do: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#to_do-form", to_do: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/todos")

      html = render(index_live)
      assert html =~ "To do updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes to_do in listing", %{conn: conn, to_do: to_do} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> element("#todos-#{to_do.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#todos-#{to_do.id}")
    end
  end

  describe "Show" do
    setup [:create_to_do]

    test "displays to_do", %{conn: conn, to_do: to_do} do
      {:ok, _show_live, html} = live(conn, ~p"/todos/#{to_do}")

      assert html =~ "Show To do"
      assert html =~ to_do.name
    end

    test "updates to_do within modal", %{conn: conn, to_do: to_do} do
      {:ok, show_live, _html} = live(conn, ~p"/todos/#{to_do}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit To do"

      assert_patch(show_live, ~p"/todos/#{to_do}/show/edit")

      assert show_live
             |> form("#to_do-form", to_do: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#to_do-form", to_do: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/todos/#{to_do}")

      html = render(show_live)
      assert html =~ "To do updated successfully"
      assert html =~ "some updated name"
    end
  end
end
