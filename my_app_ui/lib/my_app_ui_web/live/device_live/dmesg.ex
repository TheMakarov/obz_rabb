defmodule MyAppUiWeb.DeviceLive.Dmesg do
  use Phoenix.Component

  def is_selected_action?(is_selected) do
    if is_selected, do: %{"style" => "walo"}, else: %{"style" => "display: none"}
  end

  def comp(assigns) do
    ~H"""
    <section
      id="dmesg"
      class="tab-content utilities"
      {is_selected_action?(@is_selected)}
      style="height: 700px;"
    >
      <h2>Dmesg</h2>
      <%= for dmesg_line <- @dmesg_stream do %>
        <p><%= dmesg_line %></p>
      <% end %>
    </section>
    """
  end
end
