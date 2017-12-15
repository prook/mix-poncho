defmodule Mix.Tasks.Poncho.Test do
  use Mix.Task

  @shortdoc "Tests all mix projects in the current directory."
  @preferred_cli_env :test
  @moduledoc """
  Tests all mix projects in the current directory, e. g., when run from a root
  directory of a poncho project, it test the whole project.
  """

  def run(args) do
    unless System.get_env("MIX_ENV") || Mix.env == :test do
      Mix.raise "\"mix poncho.test\" is running on environment \"#{Mix.env}\". If you are " <>
        "running tests along another task, please set MIX_ENV explicitly"
    end

    IO.puts "implement me"
  end
end
