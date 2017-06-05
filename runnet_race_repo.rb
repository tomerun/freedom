require 'open-uri'
require 'nokogiri'
require 'haml'

Report = Struct.new(:title, :body, :advice, :point)

def get_first_report_url(race_id)
	doc = Nokogiri::HTML(open("http://runnet.jp/report/race.do?raceId=#{race_id}"))
	doc.xpath('//div[@id="list-reports-full"]/div[1]/div[1]/p[1]/a')[0]['href']
end

def get_report(url)
	doc = Nokogiri::HTML(open("http://runnet.jp/#{url}"))
	report_elem = doc.css('#individual_report')
	title = report_elem.css('div.report-article p.title').text.strip
	body = report_elem.css('div.report-article p.comment').text.strip
	advice = report_elem.css('div.advice > p').text.strip
	point = report_elem.css('div.report-footer dl.score dd').text.strip
	report = Report.new(title, body, advice, point)
	navi = doc.css('ul.report-navi')
	prev_navi = navi.xpath('li/a[text()="< 前のレポートへ"]')
	return report, (prev_navi.size > 0 ? prev_navi[0]['href'] : nil)
end

def main(race_id)
	report_url = get_first_report_url(race_id)
	reports = []
	while report_url
		report, report_url = get_report(report_url)
		reports << report
		$stderr.write('.')
		sleep(1)
	end
	$stderr.write("\n")
	template = File.read('runnet_race_repo.haml')
	engine = Haml::Engine.new(template)
	puts engine.render(Object.new, :reports => reports)
end

main ARGV[0]
