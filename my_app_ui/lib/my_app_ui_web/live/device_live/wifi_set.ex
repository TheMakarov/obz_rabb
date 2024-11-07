defmodule MyAppUiWeb.DeviceLive.WifiSet do
  use Phoenix.Component

  def is_selected_action?(is_selected) do
    if is_selected, do: %{"style" => "walo"}, else: %{"style" => "display: none"}
  end

  def comp(assigns) do
    ~H"""
    <div <section id="wifi" class="tab-content" {is_selected_action?(@is_selected)}>
      <h2>Available Wi-Fi Networks</h2>
      <button
        class="bg-black text-white px-3 py-1 rounded transition-colors duration-300"
        phx-click="refresh_wifis"
        { if @refreshed , do: %{"disabled"=>true}, else: %{"lha7bs"=>false} }
      >
        refresh
      </button>
      <table>
        <thead>
          <tr>
            <th>SSID</th>
            <th>Signal Strength</th>
            <th>Channel</th>
            <th>Flags</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <%= for network <- @networks do %>
            <tr>
              <td><%= network.ssid %></td>
              <td><%= network.signal_dbm %> dBm</td>
              <td><%= network.channel %> </td>
              <td>
                <ul>
                  <%= for flag <- network.flags do %>
                    <li><%= flag %></li>
                  <% end %>
                </ul>
              </td>
              <td>
                <div class="actions">
                  <button class="bg-black text-white px-3 py-1 rounded transition-colors duration-300" phx-click="connect" phx-value-ssid={network.ssid}>Connect</button>
                </div>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>

      <%= if @modal_open do %>
        <div id="modal" class="modal">
          <div
            id="info-modal"
            class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50"
          >
            <span class="close" phx-click="hide_modal">&times;</span>
            <h2>Connect to <%= @current_network %></h2>
            <form phx-submit="submit" phx-change="validate">
              <label for="ssid">SSID:</label>
              <input
                type="text"
                id="ssid"
                name="form[ssid]"
                value={@form["ssid"] || @current_network}
                readonly
              />

              <label for="password">Password:</label>
              <input type="password" id="password" name="form[password]" value={@form["password"]} />

              <label for="security">Security Type:</label>
              <select id="security" name="form[security]">
                <option
                  value="WPA2"
                  { if @form["security"] == "WPA2", do: %{"selected" => true}, else: %{"something" => true}}
                >
                  WPA2
                </option>
                <option
                  value="WEP"
                  { if @form["security"] == "WEP", do: %{"selected" => true}, else: %{"something" => true}}
                >
                  WEP
                </option>
                <option
                  value="Open"
                  { if @form["security"] == "Open", do:  %{"selected" => true}, else: %{"something" => true}}
                >
                  Open
                </option>
              </select>

              <label for="ip_address">IP Address:</label>
              <input type="text" id="ip_address" name="form[ip_address]" value={@form["ip_address"]} />

              <label for="gateway">Gateway:</label>
              <input type="text" id="gateway" name="form[gateway]" value={@form["gateway"]} />

              <label for="subnet_mask">Subnet Mask:</label>
              <input
                type="text"
                id="subnet_mask"
                name="form[subnet_mask]"
                value={@form["subnet_mask"]}
              />

              <label for="dns_servers">DNS Servers (comma separated):</label>
              <input
                type="text"
                id="dns_servers"
                name="form[dns_servers]"
                value={@form["dns_servers"]}
              />

              <button type="submit">Connect</button>
            </form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
