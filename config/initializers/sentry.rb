Sentry.init do |config|
  config.dsn = 'https://118368ce626634fbd5d87bc72e862e19@o4506438536003584.ingest.sentry.io/4506779919187968'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.enabled_environments = %w[production staging]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end
