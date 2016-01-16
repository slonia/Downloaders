require 'nokogiri'
require 'open-uri'

class Wallpapers

  def initialize
    @count = 0
    start_download
  end

  def start_download
    begin
      @start = 'https://wallpaperscraft.com/'
      @home = '/home/berlin/Pictures/'
      @root = Nokogiri::HTML(open(@start))
      @categories = @root.at_css('.left_category').css('a').map { |link| link.content.downcase.sub(' ', '-')} - ['all']
      @prompt = "Available categories: "
      @categories.each_with_index {|cat, i| @prompt << "#{i+1})#{cat} "}
      puts @prompt
      @selected = gets
      @selected = @selected.split(/\s/).map { |i| i.to_i - 1}
      @selected_categories = @categories.values_at(*@selected)
      @size = '1920x1080'
    rescue Exception => e
      puts "Exception occured: #{e.message}"
      @count += 1
      sleep 15
      start_download if @count < 10
    end
    download
  end

  def download
    @selected_categories.each do |category|
      page_addr = @start + "catalog/#{category}/#{@size}"
      first = Nokogiri::HTML(open(page_addr))
      last_page = first.at_css('.pages').css('a').last.content.to_i
      (1..last_page).each do |page|
        page_addr += "/page#{page}" unless page == 1
        cur_page = Nokogiri::HTML(open(page_addr))
        images = cur_page.css(' .wallpaper_pre a')
        dir = @home + "#{category}/"
        Dir.mkdir(dir) unless File.directory?(dir)
        images.each do |image|
          found = image['href'].match(/_(\d+)\//)
          if found
            id = found[1]
            url = @start + "image/#{id}/#{@size}.jpg"
            filename = dir + "#{id}.jpg"
            unless File.exist?(filename)
              puts "Downloading #{url}"
              IO.copy_stream(open(url), filename)
            end
          end
        end
      end
    end
  rescue Exception => e
    puts "Exception occured: #{e.message}"
    @count += 1
    sleep 15
    download if @count < 10
  end
end

Wallpapers.new
