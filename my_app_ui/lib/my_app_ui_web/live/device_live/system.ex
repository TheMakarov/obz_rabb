defmodule MyAppUiWeb.DeviceLive.System do
  use Phoenix.Component

  def is_selected_action?(is_selected) do
    if is_selected, do: %{"style" => "walo"}, else: %{"style" => "display: none"}
  end

  def comp(assigns) do
    ~H"""
    <section id="system" class="tab-content" {is_selected_action?(@is_selected)}>
      <h2>System Information</h2>
      <p>Uptime: <%= @uptime %> (s)</p>
      <p>Firmware Version: 1.0.2</p>
      <div class="ascii-art">
        <pre>
       ____  ____  ______   ____    ____ ____    _    __    ____  _   ______
    / __ \/ __ \/  _/ | / / /   / __ )  _/   | |  / /   / __ \/ | / / __ \
    / / / / /_/ // //  |/ / /   / __  |/ /     | | / /   / /_/ /  |/ / / / /
    /_/ /_/\____/___/_/|_/_/   /_/ |_/___/     | |/ /   / .___/_/|_/_/ /_/
    /_/                           |___/          |_/

    </pre>
      </div>
    </section>
    """
  end
end
