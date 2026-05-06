Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # qualsevol domini
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end