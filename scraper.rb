#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'
require 'wikidata_ids_decorator'

require_relative 'lib/remove_notes'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  decorator RemoveNotes
  decorator WikidataIdsDecorator::Links

  field :members do
    member_cells.xpath('.//a').map { |a| fragment(a => MemberItem).to_h }
  end

  private

  def member_table
    noko.xpath('//table[.//th[contains(.,"Klub Parlamentarny")]]')
  end

  def member_cells
    member_table.xpath('.//td[.//li]')
  end
end

class MemberItem < Scraped::HTML
  field :id do
    noko.attr('wikidata')
  end

  field :name do
    noko.text
  end

  field :klub do
    noko.xpath('.//preceding::th').last.text.tidy
  end
end

url = 'https://pl.wikipedia.org/wiki/Pos%C5%82owie_na_Sejm_Rzeczypospolitej_Polskiej_VIII_kadencji'
Scraped::Scraper.new(url => MembersPage).store(:members)
