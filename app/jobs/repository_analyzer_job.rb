# frozen_string_literal: true

class RepositoryAnalyzerJob < ApplicationJob
  queue_as :default

  def perform(check)
    check.to_start!
    user = check.repository.user
    client = Octokit::Client.new(access_token: user.token, auto_paginate: true)
    repo_full_name = check.repository.full_name
    download_path = prepare_download_path(repo_full_name)
    FileUtils.mkdir_p(download_path)
    download_repository(client, repo_full_name, '', download_path)
    analyze_repository(client, check, download_path)
  rescue StandardError => e
    Rails.logger.debug { "An error occurred: #{e.message}" }
    check.fail!
  ensure
    FileUtils.rm_rf(download_path)
    if check.error_count.positive?
      notify_user(check, user)
      check.repository.update!(last_check: false)
    else
      check.repository.update!(last_check: true)
    end
    check.finish!
  end

  private

  def analyze_repository(client, check, download_path)
    cmd = make_linter_cmd(check, download_path)
    stdout, exit_status = Open3.popen3(cmd) do |_stdin, inner_stdout, _stderr, wait_thr|
      [inner_stdout.read, wait_thr.value]
    end
    passed = exit_status.success?
    commit_id = client.commits(check.repository[:full_name]).first.sha[0, 7]
    data, error_count = parse_check_data(check, stdout, download_path)
    check.update!(data:, error_count:, commit_id:, passed:)
  end

  def download_repository(client, repo_full_name, path, download_path)
    repository_contents = client.contents(repo_full_name, path:)

    repository_contents.each do |file|
      file_path = File.join(download_path, file.name)

      if file.type == 'file'
        repository_content = client.contents(repo_full_name, path: file.path)
        File.write(file_path, Base64.decode64(repository_content.content).force_encoding(Encoding::UTF_8))
        Rails.logger.debug file_path
      elsif file.type == 'dir'
        FileUtils.mkdir_p(file_path)
        download_repository(client, repo_full_name, file.path, file_path)
      end
    end
  end

  def make_linter_cmd(check, download_path)
    if check.repository.language == 'javascript'
      eslintrc_path = Rails.root.join('.eslintrc.yml')
      cmd = "npx eslint #{download_path} --no-eslintrc --config #{eslintrc_path} -f json"
    elsif check.repository.language == 'ruby'
      rubocop_conf_path = Rails.root.join('.rubocop_ext.yml')
      cmd = "rubocop #{download_path} -c #{rubocop_conf_path} --format json"
    end
  end

  def notify_user(check, user)
    CheckMailer.with(user:, repository: check.repository).check_fail_notification.deliver_now
  end

  def parse_check_data(check, stdout, download_path)
    data = JSON.parse(stdout)
    formatter_class_name = "#{check.repository.language.capitalize}Formatter"
    formatter_class = formatter_class_name.safe_constantize
    formatted_data, total_error_count = formatter_class.format_data(data, download_path)
  end

  def prepare_download_path(repo_full_name)
    timestamp = Time.zone.now.strftime('%Y%m%d%H%M')
    Rails.root.join('tmp/downloads/', "#{repo_full_name}_#{timestamp}")
  end
end
