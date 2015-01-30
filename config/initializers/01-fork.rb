if defined?(Spring)
  Spring.after_fork do
    Mike.after_fork
  end
end

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      Mike.after_fork
    else
      # We're in conservative spawning mode. We don't need to do anything.
    end
  end
end