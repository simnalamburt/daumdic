require 'uri'
require 'nokogiri'
require 'open-uri'

class Daumdic
  # 다음사전에 단어를 검색한 후, 한줄짜리 결과를 출력한다.
  def self.search(input)
    return if input.nil?
    return if (input = input.strip).empty?

    doc = Nokogiri::HTML(open(URI.escape("http://dic.daum.net/search.do?q=#{input}")))

    # Look for alternatives
    rel = doc.css('.link_speller').map(&:text).join(', ')
    return rel unless rel.empty?

    # Got some results
    box = doc.css('.search_box')[0]
    return if box.nil?

    word = box.css('.txt_cleansch').text
    word = box.css('.txt_searchword')[0]&.text if word.empty?
    meaning = box.css('.txt_search').map(&:text).join(', ')
    pronounce = box.css('.txt_pronounce').first&.text
    lang = box.parent.css('.tit_word').text
    if /^(.*)어사전$/.match(lang); lang = $1 end

    # Failed to parse daumdic
    return if meaning.empty?

    # Make a result message
    result = ''
    unless ['한국', '영', '일본', '한자사전'].include? lang
      result += "(#{lang})  "
    end
    if input != word
      result += "#{word}  "
    end
    unless pronounce.nil?
      result += "#{pronounce}  "
    end
    result += meaning
  end
end
