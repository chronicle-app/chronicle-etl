# frozen_string_literal: true

require 'chronicle/schema'
require 'chronicle/models/base'

require_relative 'etl/registry/registry'
require_relative 'etl/authorizer'
require_relative 'etl/config'
require_relative 'etl/configurable'
require_relative 'etl/exceptions'
require_relative 'etl/extraction'
require_relative 'etl/record'
require_relative 'etl/job_definition'
require_relative 'etl/job_log'
require_relative 'etl/job_logger'
require_relative 'etl/job'
require_relative 'etl/logger'
require_relative 'etl/runner'
require_relative 'etl/secrets'
require_relative 'etl/utils/binary_attachments'
require_relative 'etl/utils/progress_bar'
require_relative 'etl/version'

require_relative 'etl/extractors/extractor'
require_relative 'etl/loaders/loader'
require_relative 'etl/transformers/transformer'

begin
  require 'pry'
rescue LoadError
  # Pry not available
end
