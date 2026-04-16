require 'net/http'
require 'json'
require 'uri'

module Helpers
  def self.number_to_human(value)
    n = value.to_f
    return "0" if n <= 0

    [
      [1_000_000_000, "B"],
      [1_000_000, "M"],
      [1_000, "K"]
    ].each do |base, suffix|
      if n >= base
        scaled = n / base
        text = scaled >= 100 ? scaled.round.to_s : format("%.1f", scaled).sub(/\.0$/, "")
        return "#{text}#{suffix}"
      end
    end

    n.round.to_i.to_s
  end
end

module Jekyll
  class InspireHEPCitationsTag < Liquid::Tag
    Citations = { }

    def initialize(tag_name, params, tokens)
      super
      @recid = params.strip
    end

    def render(context)
      recid = context[@recid.strip]
      api_url = "https://inspirehep.net/api/literature/?fields=citation_count&q=recid:#{recid}"

      begin
        # If the citation count has already been fetched, return it
        if InspireHEPCitationsTag::Citations[recid]
          return InspireHEPCitationsTag::Citations[recid]
        end

        # Fetch the citation count from the API
        uri = URI(api_url)
        response = Net::HTTP.get(uri)
        data = JSON.parse(response)

        # # Log the response for debugging
        # puts "API Response: #{data.inspect}"

        # Extract citation count from the JSON data
        citation_count = data["hits"]["hits"][0]["metadata"]["citation_count"].to_i

        # Format the citation count for readability
        citation_count = Helpers.number_to_human(citation_count)

      rescue Exception => e
        # Handle any errors that may occur during fetching
        citation_count = "N/A"

        # Print the error message including the exception class and message
        puts "Error fetching citation count for #{recid}: #{e.class} - #{e.message}"
      end

      InspireHEPCitationsTag::Citations[recid] = citation_count
      return "#{citation_count}"
    end
  end
end

Liquid::Template.register_tag('inspirehep_citations', Jekyll::InspireHEPCitationsTag)
