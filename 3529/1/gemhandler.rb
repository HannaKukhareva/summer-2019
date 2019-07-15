require 'nokogiri'
require 'json'
require 'open-uri'
require 'httparty'
require 'open_uri_redirections'
require 'yaml'
require 'octokit'

class GemHendler
  attr_reader :data_about_gem

  def initialize(github_url)
    @url = github_url
    puts "Didn't find repository on github" if @url.nil?
    @repo_addr = adress_handle
    @client = Octokit::Client.new(:login => 'gannagoodkevich', :password => 'Pusivill1999')
    user = @client.user
    user.login
    @client.auto_paginate = true
  end

  def adress_handle
    if @url.include?('https://github.com/')
      @repo_addr = @url.gsub('https://github.com/', '')
    else
      @repo_addr = @url.gsub('http://github.com/', '')
    end
  end

  def join_all_data
    @data_about_gem = {}
    find_wsf
    find_uci
    make_rate
  end

  def find_wsf
    find_watchers
    find_stars
    find_forks
  end

  def find_uci
    find_used_by
    find_contributers
    find_issues
  end

  def make_rate
    rate = @data_about_gem[:watched_by] * 0.15 + @data_about_gem[:stars] * 0.15
    rate += @data_about_gem[:forks] * 0.10
    rate += @data_about_gem[:used_by] * 0.5 + @data_about_gem[:contributers] * 0.05
    rate += @data_about_gem[:issues] * 0.05
    @data_about_gem[:rate] = rate
  end

  def find_forks
    repo = @client.repo @repo_addr
    @data_about_gem[:forks] = repo[:forks_count]
  end

  def find_stars
    repo = @client.repo @repo_addr
    @data_about_gem[:stars] = repo[:stargazers_count]
  end

  def find_watchers
    repo = @client.repo @repo_addr
    @data_about_gem[:watched_by] = repo[:subscribers_count]
  end

  def find_contributers
    contr = @client.contributors @repo_addr
    @data_about_gem[:contributers] = contr.length
  end

  def find_used_by
    url_use = @url + '/network/dependents'
    noko_obj = Nokogiri::HTML(open(url_use, allow_redirections: :safe)).css('a.btn-link.selected')
    noko_obj.each do |element|
      @data_about_gem[:used_by] = element.text[/[\d*[:punct:]]+/].tr(',', '').to_i
    end
  end

  def find_issues
    url_issue = @url + '/issues'
    noko_obj = Nokogiri::HTML(open(url_issue, allow_redirections: :safe)).css('a.btn-link.selected')
    noko_obj.each do |element|
      @data_about_gem[:issues] = element.text[/[\d*[:punct:]]+/].tr(',', '').to_i
    end
  end
end
