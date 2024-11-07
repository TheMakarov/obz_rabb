defmodule MyAppUiWeb.DeviceLive.TelemtryComponent do
  use Phoenix.Component

  def is_selected_action?(is_selected) do
    if is_selected, do: %{"style" => "walo"}, else: %{"style" => "display: none"}
  end

  def comp(assigns) do
    ~H"""
    <section id="telemetry" class="tab-content" {is_selected_action?(@is_selected)}>
      <h2>Telemetry Data</h2>
      <table id="telemetry-table">
        <thead>
          <tr>
            <th onclick="sortTable(0)">Metric</th>
            <th onclick="sortTable(1)">Value</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>CPU Usage</td>
            <td>
              <%= assigns.cpu_usage %> %
            </td>
          </tr>
          <tr>
            <td>CPU frequency</td>
            <td>
              <%= assigns.cpu_frequency %> Ghz
            </td>
          </tr>
          <tr>
            <td>CPU Temperature</td>
            <td>
              <%= assigns.temp %> C
            </td>
          </tr>
          <tr>
            <td>Memory Usage</td>
            <td>
              <ul>
                <li>free: <%= Float.floor(assigns.memory.free / 1024 / 1024, 3) %> GB</li>
                <li>used: <%= Float.floor(assigns.memory.used / 1024 / 1024, 3) %> GB</li>
                <li>total: <%= Float.floor(assigns.memory.total / 1024 / 1024, 3) %> GB</li>
              </ul>
            </td>
          </tr>
          <tr>
            <td>Disk Space</td>
            <td>
              <%= for disk <- @disk_usage do %>
                <ul>
                  <li>path: <%= elem(disk, 0) %></li>
                  <li>size: <%= elem(disk, 1).size %></li>
                  <li>used: <%= elem(disk, 1).used %></li>
                  <li>percent: <%= elem(disk, 1).percent %></li>
                  <li>mount_point: <%= elem(disk, 1).mount_point %></li>
                </ul>
              <% end %>
            </td>
          </tr>
          <tr>
            <td>Network Latency</td>
            <td>
              <%= assigns.network_latency %> ms
            </td>
          </tr>
          <tr>
            <td>Connected Network</td>
            <td>
              <%= assigns.network_name %>
            </td>
          </tr>
        </tbody>
      </table>
    </section>
    """
  end
end
