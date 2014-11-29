require 'daemons'
require "vkontakte_api"
require 'yaml'
require 'colorize'
require 'nokogiri'
require_relative 'auth'


VkontakteApi.configure do |config|
  config.log_requests  = false
  config.log_errors    = true
  config.log_responses = false
end

class Poster
  class NothingToPost < Exception; end

  def initialize
    token = VkAuth.new.token
    puts "TOKEN: #{token}"
    @vk = VkontakteApi::Client.new token
    @token = VkAuth
  end

  def main_album(gid)
    album = @vk.photos.getAlbums(owner_id: "-#{gid}").select{|a| a.title.downcase=='main'}.first
    unless album.nil?
      album
    else
      raise NothingToPost, "No main album in #{gid}"
    end
  end

  def photos(gid, aid)
    @vk.photos.get(gid: gid, aid: aid)
  end

  def post(gid, photo)
    attachment = "photo-#{gid}_#{photo.pid}"
    puts attachment.green, strip_html(photo.text)
    @vk.wall.post(owner_id: "-#{gid}", attachments: attachment, message: strip_html(photo.text), from_group: 1)
  end

  private

    def strip_html(str)
      document = Nokogiri::HTML.parse(str)
      document.css("br").each { |node| node.replace("\n") }
      document.text
    end

end
