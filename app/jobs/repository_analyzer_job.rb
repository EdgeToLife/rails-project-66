# frozen_string_literal: true

class RepositoryAnalyzerJob < ApplicationJob
  queue_as :default

  def perform(check, user_id)
    user = User.find(user_id)
    octo_client = Octokit::Client.new(access_token: user.token, auto_paginate: true)

    update_repository_info(check, octo_client)
    download_and_analyze_repository(check, octo_client)
    notify_user(check, user)
  rescue StandardError => e
    Rails.logger.debug { "An error occurred: #{e.message}" }
    check.fail!
  end

  private

  def analyze_repository(check, download_path)
    if check.repository.language == 'javascript'
      eslintrc_path = Rails.root.join('.eslintrc.yml')
      cmd = "npx eslint #{download_path} --no-eslintrc --config #{eslintrc_path} -f json"
      stdout, exit_status = Open3.popen3(cmd) do |_stdin, inner_stdout, _stderr, wait_thr|
        [inner_stdout.read, wait_thr.value]
      end
    elsif check.repository.language == 'ruby'
      rubocop_conf_path = Rails.root.join('.rubocop_ext.yml')
      cmd = "rubocop #{download_path} -c #{rubocop_conf_path} --format json"
      puts "*******CMD*******\n#{cmd}"
      stdout, exit_status = Open3.popen3(cmd) do |_stdin, inner_stdout, _stderr, wait_thr|
        [inner_stdout.read, wait_thr.value]
      end
    end
    puts "*******STDOUT*********\n#{stdout}"
    data = JSON.parse(stdout)
    check.update!(check_successful: exit_status.success?)
    parse_and_update_check_data(check, data)
  end

  def download_and_analyze_repository(check, octo_client)
    download_path = prepare_download_path(check.repository[:full_name])
    FileUtils.mkdir_p(download_path)
    download_repository(octo_client, check.repository[:full_name], '', download_path)
    analyze_repository(check, download_path)
  ensure
    FileUtils.rm_rf(download_path)
  end

  def download_repository(octo_client, repository, path, download_path)
    repository_contents = octo_client.contents(repository, path: path)

    repository_contents.each do |file|
      file_path = File.join(download_path, file.name)

      if file.type == 'file'
        repository_content = octo_client.contents(repository, path: file.path)
        File.write(file_path, Base64.decode64(repository_content.content).force_encoding(Encoding::UTF_8))
        Rails.logger.debug file_path
      elsif file.type == 'dir'
        FileUtils.mkdir_p(file_path)
        download_repository(octo_client, repository, file.path, file_path)
      end
    end
  end

  def notify_user(check, user)
    if check.error_count.positive?
      CheckMailer.with(user: user, repository: check.repository[:full_name]).check_fail_notification.deliver_now
      check.repository.update!(state: false)
    else
      check.repository.update!(state: true)
    end
    check.complete!
  end

  def parse_and_update_check_data(check, data)
    formatter_class_name = "#{check.repository.language.capitalize}Formatter"
    formatter_class = formatter_class_name.safe_constantize
    formatted_data, total_error_count = formatter_class.format_data(data)
    check.update!(data: formatted_data, error_count: total_error_count)
  end

  def prepare_download_path(repo_full_name)
    timestamp = Time.zone.now.strftime('%Y%m%d%H%M')
    Rails.root.join('tmp/downloads/', "#{repo_full_name}_#{timestamp}")
  end

  def update_repository_info(check, octo_client)
    repo_full_name = check.repository[:full_name]
    repo_info = octo_client.repository(repo_full_name)

    check.repository.update!(
      name: repo_info.name,
      language: repo_info.language.downcase,
      git_url: repo_info.git_url,
      ssh_url: repo_info.ssh_url
    )

    check.update!(commit_id: octo_client.commits(repo_full_name).first.sha[0, 7])
  end
end
