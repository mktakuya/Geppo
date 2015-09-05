require 'slop'
require 'date'
require 'yaml'
require 'open-uri'
require 'nokogiri'
require 'tilt'

class Geppo
  def run
    opts = Slop.parse do |opt|
      opt.integer '-y', '--year', 'Year', default: Date.today.year
      opt.integer '-m', '--month', 'Month', default: Date.today.month
    end

    config = YAML.load_file('./config.yml')

    entries = fetch_entries(config['url'], opts[:year], opts[:month])
    puts to_html(entries)
  end

  def fetch_entries(url, year, month)
    doc = Nokogiri::HTML(open("#{url}/archive/#{year}/#{month}"))

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
    template = Tilt.new('template.erb')
    html = template.render(self, entries: entries)
    return html
  end
end

if $0 == __FILE__
  geppo = Geppo.new
  geppo.run
end

