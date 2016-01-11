require 'nokogiri'
require 'open-uri'
require 'pry'

class Downloader

  def initialize
    @count = 0
    @s = 0
    start_download
  end

  def start_download
    @base = 'http://www.ctrlpaint.com'
    @start = @base + '/library/'
    @home = '/home/berlin/Video/Tutorials/CtrlPaint2'
    @root = Nokogiri::HTML(open(@start))
    @root.css('h3').each {| el| process(el); sleep(2) }
  end

  def process(el)
    return unless el.text.match(/^\d+/)
    folder = el.text
    Dir.mkdir(@home + "/#{folder}/") unless File.directory?(@home + "/#{folder}/")

    el.next_element.css('a').each do |child|
      download_link(folder, child) if @s < 1
    end
  end

  def download_link(folder, link)
    page_addr = @base + link.attr('href')
    page = Nokogiri::HTML(open(page_addr))
    video = page.css('video')
    dir = @home + "/#{folder}/"
    binding.pry
    puts video.attr('src')
    puts dir + link.text + '.mp4'
    IO.copy_stream(open(video.attr('src'), dir + link.text + '.mp4'))
    @s+=1
    sleep 2
  end
end

Downloader.new
