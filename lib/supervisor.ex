defmodule Multiplex.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_instance(session_id) do
    child_spec = Supervisor.child_spec({Multiplex, session_id}, id: session_id)
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def terminate_session(session_id) do
    DynamicSupervisor.terminate_child(__MODULE__, session_id)
  end

  def children() do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_children() do
    DynamicSupervisor.count_children(__MODULE__)
  end
end