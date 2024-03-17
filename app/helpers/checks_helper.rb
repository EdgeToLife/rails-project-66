module ChecksHelper
  def github_commit_link(check)
    "https://github.com/#{check.repository.full_name}/commit/#{check.commit_id}"
  end
end
