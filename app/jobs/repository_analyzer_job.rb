# frozen_string_literal: true

class RepositoryAnalyzerJob < ApplicationJob
  queue_as :default

  def perform(check, user_id)
    user = User.find(user_id)
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
    notify_user(check, user)
  end

  private

  def analyze_repository(client, check, download_path)
    if check.repository.language == 'javascript'
      eslintrc_path = Rails.root.join('.eslintrc.yml')
      cmd = "npx eslint #{download_path} --no-eslintrc --config #{eslintrc_path} -f json"
      stdout, exit_status = Open3.popen3(cmd) do |_stdin, inner_stdout, _stderr, wait_thr|
        [inner_stdout.read, wait_thr.value]
      end
    elsif check.repository.language == 'ruby'
      rubocop_conf_path = Rails.root.join('.rubocop_ext.yml')
      cmd = "rubocop #{download_path} -c #{rubocop_conf_path} --format json"
      stdout, exit_status = Open3.popen3(cmd) do |_stdin, inner_stdout, _stderr, wait_thr|
        [inner_stdout.read, wait_thr.value]
      end
    end
    data = JSON.parse(stdout)
    passed = exit_status.success?
    commit_id = client.commits(check.repository[:full_name]).first.sha[0, 7]
    parse_and_update_check_data(check, data, commit_id, passed, download_path)
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

  def notify_user(check, user)
    if check.error_count.positive?
      CheckMailer.with(user:, repository: check.repository[:full_name]).check_fail_notification.deliver_now
      check.repository.update!(last_check: false)
    else
      check.repository.update!(last_check: true)
    end
    check.finish!
  end

  def parse_and_update_check_data(check, data, commit_id, passed, download_path)
    formatter_class_name = "#{check.repository.language.capitalize}Formatter"
    formatter_class = formatter_class_name.safe_constantize
    formatted_data, total_error_count = formatter_class.format_data(data, download_path)
    check.update!(data: formatted_data, error_count: total_error_count, commit_id:, passed:)
  end

  def prepare_download_path(repo_full_name)
    timestamp = Time.zone.now.strftime('%Y%m%d%H%M')
    Rails.root.join('tmp/downloads/', "#{repo_full_name}_#{timestamp}")
  end
end
