require 'nokogiri'
require 'open-uri'
require 'zip'

class Render

  def initialize
    @count = 0
    start_download
  end

  def start_download
    @start = 'http://render.ru/download/'
    @home = '/home/berlin/Documents/Render/'
    @root = Nokogiri::HTML(open(@start))
    @root.css('.year').each do |el|
      download_year(el)
    end

  end

  def download_year(year)
    name = year.css('h2').first.text
    path = @home + name
    Dir.mkdir(path) unless File.directory?(path)
    year.css('.onemag').each do |el|
      download_num(path, el) if @count < 2
    end
  end

  def download_num(path, el)
    url = 'http://render.ru' + el.css('.download').css('a').last.attr('href')
    IO.copy_stream(open(url), path + '/1.zip')
    Zip::File.open(path+'/1.zip') do |zip_file|
      entry = zip_file.glob('*.pdf').first
      puts entry.extract(path + '/' + entry.name)
    end
    File.delete(path+'/1.zip')
    @count += 1
  end
end

Render.new
