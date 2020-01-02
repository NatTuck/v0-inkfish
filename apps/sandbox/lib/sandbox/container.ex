defmodule Sandbox.Container do
  alias Sandbox.Shell

  def create_image(name, conf) do
    Temp.track!

    {:ok, fd, path} = Temp.open("Dockerfile")
    IO.write(fd, conf)
    File.close(fd)

    {_, 0} = System.cmd("docker", ["build", "-f", path, "-t", name])

    Temp.cleanup
  end

  def delete_image(name) do
    Shell.run_script! """
    docker container prune -f
    docker image rm '#{name}'
    """
  end

  def run(name) do
    Temp.track!

    {:ok, fd, path} = Temp.open("env")
    IO.write(fd, "")
    File.close(fd)

    #docker run --rm '#{name}' --env-file '#{path}'

    Temp.cleanup
  end
end
