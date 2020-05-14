Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS_URL"] || "redis://localhost:6379",
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS_URL"] || "redis://localhost:6379",
  }
end

unless %w(test development).include?(Rails.env)
  Sidekiq::Cron::Job.create(
    name: "Cache Analytics data - at 3AM Sydney time",
    cron: "0 3 * * *",
    class: "DailyAnalyticsJob",
  )
end
