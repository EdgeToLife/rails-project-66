# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :octokit, -> { OctokitClientStub }
    register :open3, -> { Open3Stub }
  else
    register :octokit, -> { Octokit::Client }
    register :open3, -> { Open3 }
  end
end
