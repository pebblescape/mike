if defined?(Spring)
  # spring speeds up your dev environment, similar to zeus but build in Ruby
  #
  # gem install spring
  #
  # bundle exec spring binstub --all
  Spring.after_fork do
    Mike.after_fork
  end
  Spring::Commands::Rake.environment_matchers["spec"] = "test"
end
