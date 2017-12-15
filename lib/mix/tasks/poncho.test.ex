defmodule Mix.Tasks.Poncho.Test do
  use Mix.Task

  @shortdoc "Tests all mix projects in the current directory."
  @preferred_cli_env :test
  @moduledoc """
  Tests all mix projects in the current directory, e. g., when run from a root
  directory of a poncho project, it tests the whole project.

  The tested projects are loaded, examined, and sorted, so that the testing
  starts from the leaves of the dependency tree, moving back to the DAG root,
  which is -- in case of a nerves project -- a firmware module. This prevents
  repeated project building (in :prod and :test env), loading, and polluting VM
  runtime.
  """

  def run(args) do
    {:ok, ls} = File.ls()

    ls
    |> Enum.filter(&File.dir?/1)
    |> Enum.filter(&mixproject?/1)
    |> Enum.map(&to_dep/1)
    |> Enum.map(&to_loaded/1)
    |> Mix.Dep.Converger.topological_sort
    |> Enum.map(&(do_test(&1, args)))
  end

  defp mixproject?(dir) do
    File.regular?("#{dir}/#{mixfile()}")
  end

  defp to_dep(dir) do

    path = Path.expand(dir)
    build = Path.join(path, "_build")

    %Mix.Dep{
      scm: Mix.SCM.Path,
      app: String.to_atom(dir),
      manager: :mix,
      status: {:ok, nil},
      opts: [
        path: path,
        dest: path,
        build: build,
        env: Mix.env(),
      ]
    }
  end

  defp to_loaded(%Mix.Dep{} = dep) do
    dep = Mix.Dep.Loader.load(dep, nil)
    ddeps = Enum.filter(dep.deps, fn dep ->
      Mix.Dep.available?(dep)
    end)

    %{dep | deps: ddeps}
  end

  defp do_test(%Mix.Dep{app: app}, args) do
    Mix.shell.info("==> #{app}")
    Mix.Project.in_project(app, Atom.to_string(app), fn _module ->
      Mix.Task.run("test", args)
    end)
  end

  defp mixfile(), do: System.get_env("MIX_EXS") || "mix.exs"
end
