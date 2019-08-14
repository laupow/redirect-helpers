# frozen_string_literal: true

require 'uri'

# Turn tab-separated values to web server redirect rules
#
# Example standard input:
#   FROM                      TO
#   http://www.example.com    http://www.example.com/newpage
#
# Usage:
#   cat my_spreadsheet.tsv | ruby TSVtoConfig.rb
#
module TSVtoConfig
  module_function

  def print_httpd_rules(tsv_lines)
    rows = []
    tsv_lines.each do |line|
      rows.push(line.split(/\t/).reject { |v| v.strip == '' })
    end

    if rows.empty?
      STDERR.puts 'No valid input detected. Exiting.'
      return
    end

    # remove empties & sort by From URL desc
    rows.reject!(&:empty?).sort_by!(&:first).reverse!

    rows.each do |row|
      uris = validate_uris(row)
      puts to_httpd_config(uris) if uris
    end
  end

  # Validates from/to URIs
  # returns a hash on valid input, nil if input invalid
  def validate_uris(row)
    return nil if row.empty?

    begin
      from = URI(row[0])
      to = URI(row[1])
    rescue URI::InvalidURIError
    rescue ArgumentError
      # STDERR.puts "STDERR skipping invalid - #{row.inspect}"
    end

    return nil if to.nil?
    return nil if to.class == URI::Generic

    { from: from, to: to }
  end

  # Turn the uri hash into server config
  # For Apache HTTP Server
  def to_httpd_config(uri_hash)
    httpd_rules = ''

    if uri_hash[:from].query
      httpd_rules += "RewriteCond %{QUERY_STRING} #{uri_hash[:from].query}\n"
    end

    from_path = uri_hash[:from].path.gsub(%r{/$}, '')

    httpd_rules += <<~CONFIG
      RewriteRule "^#{from_path}/?$"\t"#{uri_hash[:to]}"\t[L,NC,NE,R=301,QSD]
    CONFIG

    httpd_rules
  end
end


if $PROGRAM_NAME == __FILE__
  TSVtoConfig::print_httpd_rules(STDIN)
end
