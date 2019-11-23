defmodule InkfishWeb.SubmitTest do
  use ExUnit.Case
  use Hound.Helpers

  setup _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Inkfish.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Inkfish.Repo, {:shared, self()})

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(YourApp.Repo, self())
    Hound.start_session(metadata: metadata)

    on_exit fn ->
      Hound.end_session()
    end

    :ok
  end

  def wait_for(op, timeout, waited) do
    cond do
      op.() ->
        true
      waited > timeout ->
        false
      true ->
        :timer.sleep(50)
        wait_for(op, timeout, waited + 50)
    end
  end

  def wait_for(op, timeout \\ 500) do
    wait_for(op, timeout, 0)
  end

  def wait_for_text(text, timeout \\ 500) do
    op = fn ->
      String.contains?(visible_page_text(), text)
    end
    wait_for(op, timeout)
  end

  def click_link(text) do
    assert wait_for_text(text)
    click({:link_text, text})
  end

  @tag :skip
  test "load main page" do
    navigate_to("http://localhost:4001/")
    assert page_title() =~ ~r/Inkfish/

    fill_field({:id, "login"}, "carol")
    fill_field({:id, "password"}, "test")
    click({:class, "btn-primary"})

    click_link("Data Science of Art History")
    click_link("HW01")
    click_link("New Submission")
    click_link("Clone Git Repo")

    fill_field({:id, "git-clone-input"}, "https://github.com/NatTuck/pancake.git")
    click({:id, "git-clone-btn"})

    assert wait_for_text("Done. Upload is")

    assert wait_for fn ->
      up = find_element(:id, "sub_upload_id")
      text = attribute_value(up, :value)
      String.length(text) > 0
    end

    click({:class, "btn-primary"})

    assert wait_for_text("Show Sub")
  end
end
