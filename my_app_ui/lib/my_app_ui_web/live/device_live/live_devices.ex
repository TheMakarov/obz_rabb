defmodule MyAppUiWeb.DeviceLive.LiveDevice do
  use Phoenix.Component

  def is_selected_action?(is_selected) do
    if is_selected, do: %{"style" => "walo"}, else: %{"style" => "display: none"}
  end

  # def comp(assigns) do
  #   ~H"""
  #   <section id="devices" class="tab-content" {is_selected_action?(@is_selected)}>
  #     <h2>Connected Devices</h2>
  #     <%= for device <- @devices do %>
  #       <.device
  #         name={device.name}
  #         path={device.path}
  #         up_time={device.up_time}
  #         health={device.health}
  #         logs_text={device.logs_text}
  #         api_conf={device.api_conf}
  #       />
  #     <% end %>
  #   </section>
  #   """
  # end

  # def device(assigns) do
  #   ~H"""
  #   <div class="card">
  #     <h2>Device Information</h2>
  #     <div class="card-content">
  #       <div class="card-row">
  #         <span class="card-label">Name:</span>
  #         <span class="card-value"><%= @name %></span>
  #       </div>
  #       <div class="card-row">
  #         <span class="card-label">Path:</span>
  #         <span class="card-value"><%= @path %></span>
  #       </div>
  #       <div class="card-row">
  #         <span class="card-label">Up Time:</span>
  #         <span class="card-value"><%= @up_time %></span>
  #       </div>
  #       <div class="card-row">
  #         <span class="card-label">Health:</span>
  #         <span class="card-value"><%= @health %></span>
  #       </div>
  #       <div class="card-row">
  #         <span class="card-label">Logs:</span>
  #         <span class="card-value hidden">EMPTY FOR NOW</span>
  #         <span class="card-value"><%= @logs_text %></span>
  #       </div>
  #       <h3>API Configuration</h3>
  #       <div class="card-row">
  #         <span class="card-label">URL:</span>
  #         <span class="card-value"><%= @api_conf.url %></span>
  #       </div>
  #       <div class="card-row">
  #         <span class="card-label">Port:</span>
  #         <span class="card-value"><%= @api_conf.port %></span>
  #       </div>
  #     </div>
  #   </div>
  #   """
  # end

  def comp(assigns) do
    ~H"""
    <section
      id="devices"
      class="tab-content container mx-auto p-4"
      {is_selected_action?(@is_selected)}
    >
      <h1 class="text-2xl font-semibold mb-4">Connected Devices</h1>
      <div class="grid grid-cols-1 gap-4">
        <%= for device <- @devices do %>
          <div class="border rounded-lg p-4 shadow-sm hover:shadow-md transition-shadow duration-300">
            <h2 class="text-xl font-bold"><%= device.type %> - <%= device.path %></h2>
            <p class="text-gray-600">Device Node: <%= device.device_node || "N/A" %></p>
            <div class="mt-2">
              <button
                class="bg-black text-white px-3 py-1 rounded transition-colors duration-300"
                phx-click="show_info"
                phx-value-path={device.path}
              >
                Show Info
              </button>
              <button
                class="bg-black text-white px-3 py-1 rounded hover:bg-green-600 transition-colors duration-300"
                disabled="true"
              >
                Expose
              </button>
            </div>
          </div>
        <% end %>
      </div>
    </section>

    <%= if @show_info do %>
      <div
        id="info-modal"
        class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50"
      >
        <div class="bg-white rounded-lg p-6 shadow-lg">
          <h2 class="text-xl font-bold mb-4">Device Info</h2>
          <pre class="whitespace-pre-wrap devices-modal"><%= @info_content %></pre>
          <button
            class="mt-4 bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600 transition-colors duration-300"
            phx-click="close_modal"
          >
            Close
          </button>
        </div>
      </div>
    <% end %>
    """
  end
end
