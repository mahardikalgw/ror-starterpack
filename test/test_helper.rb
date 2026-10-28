ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "inertia_rails/minitest"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Single worker deliberately. Vite's test config has autoBuild enabled, so each
    # worker builds assets on first use; with N workers they race on
    # public/vite-test/.vite/manifest.json and a loser reads an empty file, raising
    # "unexpected end of input at line 1 column 1" from vite_typescript_tag. That made
    # roughly one run in six fail for reasons unrelated to the tests. Running one worker
    # removes the race; restore parallelism only after pre-building assets once and
    # setting test.autoBuild to false.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Deterministic builders for aggregates and auth live in test/support/.
    Dir[Rails.root.join("test/support/**/*.rb")].each { |file| require file }
    include DashboardData
  end
end
