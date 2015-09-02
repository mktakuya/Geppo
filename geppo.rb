require 'open-uri'
require 'nokogiri'

class Geppo
  def run
    entries = fetch_entries
  end

  private
  def fetch_entries
    url = "http://mktakuya.hatenablog.jp/archive/2015/8"
    doc = Nokogiri::HTML(open(url))

    archive_entries = doc.search('.archive-entries').first

    entries = []
    archive_entries.search('.archive-entry').each do |archive_entry|
      entry = {}
      entry[:pub_date] = Date.parse(archive_entry.search('.date>a>time').first.attributes['datetime'].value)
      entry[:title] = archive_entry.search('.archive-entry-header>h1>a').text
      entry[:link] = archive_entry.search('.archive-entry-header>h1>a')[0].attributes["href"].value

      entries.push(entry)
    end
    return entries
  end
end

if $0 == __FILE__
  geppo = Geppo.new
  geppo.run
end

