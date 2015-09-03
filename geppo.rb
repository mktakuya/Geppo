require 'slop'
require 'date'
require 'open-uri'
require 'nokogiri'

class Geppo
  def run
    opts = Slop.parse do |opt|
      opt.integer '-y', '--year', 'Year', default: Date.today.year
      opt.integer '-m', '--month', 'Month', default: Date.today.month
    end

    entries = fetch_entries(opts[:year], opts[:month])
    puts to_html(entries)
  end

  private
  def fetch_entries(year, month)
    url = "http://mktakuya.hatenablog.jp/archive/#{year}/#{month}"
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

  def to_html(entries)
    html = "<h3>タイムライン</h3>\n"

    entries.reverse.each_with_index do |entry, i|
      if i == 0 || entries[i - 1][:pub_date] != entry[:pub_date]
        html += "<h4>#{entry[:pub_date].day.to_s}日（#{%w(日 月 火 水 木 金 土)[entry[:pub_date].wday]}）</h4>\n"
        html += "<ul>\n"
      end


      html += "<li>"
      html += "<a style=\"line-height: 1.5;\" href=\"#{entry[:link]}\">"
      html += "#{entry[:title]}"
      html += "</a>"
      html += "</li>\n"

      if entries[i + 1].nil? || entries[i + 1][:pub_date] != entry[:pub_date]
        html += "</ul>\n"
      end
    end

    return html
  end
end

if $0 == __FILE__
  geppo = Geppo.new
  geppo.run
end

