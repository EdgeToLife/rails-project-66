class RepositoryAnalyzerJob < ApplicationJob
  queue_as :default

  def perform(check, user_id)
    user = User.find(user_id)

    # initialize octokit client
    client = Octokit::Client.new access_token: user.token, auto_paginate: true

    # get repo info
    repo_full_name = check.repository[:full_name]
    repo_info = client.repository(repo_full_name)

    # update base repo info
    check.repository.name = repo_info.name
    check.repository.language = repo_info.language.downcase
    check.repository.git_url = repo_info.git_url
    check.repository.ssh_url = repo_info.ssh_url
    check.repository.save!

    # get and update repo last commit id
    last_commit_sha = client.commits(repo_full_name).first.sha
    last_commit_id = last_commit_sha[0, 7]
    check.commit_id = last_commit_id

    # prepare tmp folder to download repository
    timestamp = Time.now.strftime('%Y%m%d%H%M')
    download_path = Rails.root.join('tmp/downloads/', "#{repo_full_name}_#{timestamp}")
    FileUtils.mkdir_p(download_path)

    # get repo file list
    contents = client.contents(repo_full_name)

    # download repository to local temporary folder
    download_contents(client, repo_full_name, '', download_path)

    # start linter
    if check.repository.language == 'javascript'
      eslintrc_path = Rails.root.join('.eslintrc.yml')
      stdout, exit_status = Open3.popen3("npx eslint #{download_path} --no-eslintrc --config #{eslintrc_path} -f json") do |_stdin, stdout, _stderr, wait_thr|
        [stdout.read, wait_thr.value]
      end
    elsif check.repository.language == 'ruby'
      stdout, exit_status = Open3.popen3("rubocop #{download_path} --format json") do |_stdin, stdout, _stderr, wait_thr|
        [stdout.read, wait_thr.value]
      end
    end

    # set the check status
    check.check_successful = exit_status == 0

    # remove tmp folder with downloaded repository
    FileUtils.rm_rf(download_path)

    # parse linter output
    data = JSON.parse(stdout)

    # format linter output
    formatter_class_name = "#{check.repository.language.capitalize}Formatter"
    formatter_class = formatter_class_name.safe_constantize
    formatted_data, total_error_count = formatter_class.format_data(data)

    # update check data
    check.data = formatted_data
    check.error_count = total_error_count

    if check.save
      check.complete!
      if check.error_count > 0
        CheckMailer.with(user: user, repository: repo_full_name).check_fail_notification.deliver_now
        check.repository.state = false
      else
        check.repository.state = true
      end
    else
      check.fail!
      check.repository.state = false
      CheckMailer.with(user: user, repository: repo_full_name).check_fail_notification.deliver_now
    end
    check.repository.save!
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
    check.fail!
  end

  private

  def download_contents(client, repository, path, download_path)
    contents = client.contents(repository, path: path)

    contents.each do |file|
      file_path = File.join(download_path, file.name)

      if file.type == 'file'
        content = client.contents(repository, path: file.path)
        File.write(file_path, Base64.decode64(content.content).force_encoding(Encoding::UTF_8))
        puts file_path
      elsif file.type == 'dir'
        FileUtils.mkdir_p(file_path)
        download_contents(client, repository, file.path, file_path)
      end
    end
  end
end
