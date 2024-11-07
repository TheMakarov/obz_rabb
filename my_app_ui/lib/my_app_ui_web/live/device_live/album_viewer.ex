defmodule MyAppUiWeb.DeviceLive.AlbumViewer do
  use Phoenix.Component

  @image_dir "assets/saves"

  def comp(assigns) do
    ~H"""
    <section id="Zab" class="tab-content hidden">
      <div id="image-viewer">
        <div class="sidebar">
          <h2>Upload Image</h2>
          <form phx-submit="upload_image" enctype="multipart/form-data">
            <input type="file" name="image" />
            <button type="submit">Upload</button>
          </form>
        </div>

        <div class="images">
          <h2>Images</h2>
          <%= for image <- @images do %>
            <div class="image-thumb" phx-click="select_image" phx-value-image={image}>
              <img src={"/images/#{Path.basename(image)}"} alt="Image" />
            </div>
          <% end %>
        </div>

        <%= if @show_popup do %>
          <div id="popup" class="popup">
            <div class="popup-content">
              <span class="close" phx-click="close_popup">&times;</span>
              <img src={"/images/#{Path.basename(@selected_image)}"} alt="Image" />
              <p>Image path: <%= @selected_image %></p>
              <p>Size: <%= File.stat!(@selected_image).size %> bytes</p>
              <p>Uploaded at:  %></p>
            </div>
          </div>
        <% end %>
      </div>
    </section>

    <style>
      #image-viewer {
      display: flex;
      justify-content: space-between;
      }

      .sidebar {
      width: 20%;
      padding: 10px;
      background-color: #f4f4f4;
      }

      .images {
      width: 75%;
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      }

      .image-thumb {
      width: 100px;
      height: 100px;
      overflow: hidden;
      cursor: pointer;
      }

      .image-thumb img {
      width: 100%;
      height: auto;
      }

      .popup {
      display: block;
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 80%;
      max-width: 600px;
      background: white;
      border: 1px solid #ccc;
      z-index: 1000;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
      }

      .popup-content {
      padding: 20px;
      }

      .close {
      position: absolute;
      top: 10px;
      right: 10px;
      font-size: 20px;
      cursor: pointer;
      }
    </style>
    """
  end

  # they do nothing !
  def handle_event("select_image", %{"image" => image}, socket) do
    {:noreply, assign(socket, selected_image: image, show_popup: true)}
  end

  def handle_event("close_popup", _params, socket) do
    {:noreply, assign(socket, show_popup: false)}
  end

  def handle_event(
        "upload_image",
        %{"image" => %Plug.Upload{path: path, filename: filename}},
        socket
      ) do
    File.cp(path, Path.join(@image_dir, filename))
    {:noreply, assign(socket, images: list_images())}
  end

  defp list_images do
    @image_dir
    |> File.ls!()
    |> Enum.map(&Path.join(@image_dir, &1))
  end
end
