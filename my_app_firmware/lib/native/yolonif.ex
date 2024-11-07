defmodule YoloNif do
  use Rustler, otp_app: :my_app_ui, crate: "yolonif"

  # When your NIF is loaded, it will override this function.
  def start_detection do
    error()
  end

  def read_chunk(_stream) do
    error()
  end

  defp error do
    :erlang.nif_error(:nif_not_loaded)
  end
end
