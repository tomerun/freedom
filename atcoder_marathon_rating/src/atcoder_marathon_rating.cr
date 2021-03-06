require "ecr/macros"
require "http/client"
require "json"

class Contest
  property :short_name, :ids, :mul

  def initialize(@short_name : String, @ids : Array(String), @mul : Bool)
  end
end

class Person
  property :name, :sum, :win, :top5, :top10, :count

  def initialize(@name : String)
    @sum = 0
    @win = 0
    @top5 = 0
    @top10 = 0
    @count = 0
  end

  def to_s(io)
    io << sprintf("%20s %3d %2d %2d %2d %2d", @name, @sum, @win, @top5, @top10, @count)
  end

  def css_color
    if @sum >= 500 && @top5 >= 3
      return "#ff0000" # red
    elsif @sum >= 300 && @top5 >= 1
      return "#ff8000" # orange
    elsif @sum >= 150 && @top10 >= 1
      return "#c0c000" # yellow
    elsif @sum >= 75
      return "#0000ff" # blue
    elsif @sum >= 40
      return "#00c0c0" # cyan
    elsif @sum >= 20
      return "#008000" # green
    elsif @sum >= 1
      return "#804000" # brown
    elsif @count >= 1
      return "#808080" # gray
    else
      return "#000000" # black
    end
  end
end

GP30 = [100, 75, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

CONTESTS = [
  Contest.new("ヤマト", ["kuronekoyamato-contest2019"], false),
  Contest.new("aspro3", ["asprocon3"], false),
  Contest.new("CADDi", ["caddi2019"], false),
  Contest.new("新概念3", ["hokudai-hitachi2018"], true),
  Contest.new("aspro2", ["asprocon2"], false),
  Contest.new("HTTF2019本", ["future-contest-2019-final", "future-contest-2019-final-open"], false),
  Contest.new("HTTF2019予", ["future-contest-2019-qual"], false),
  Contest.new("HTTF2018本", ["future-contest-2018-final", "future-contest-2018-final-open"], false),
  Contest.new("HTTF2018予", ["future-contest-2018-qual"], false),
  Contest.new("Weathernews", ["wn2017_1"], false),
  Contest.new("新概念2", ["hokudai-hitachi2017-2"], false),
  Contest.new("新概念1", ["hokudai-hitachi2017-1"], false),
  Contest.new("大根3", ["chokudai003"], false),
  Contest.new("大根2", ["chokudai002"], false),
  Contest.new("大根1", ["chokudai001"], false),
]

DATA_PATH = "data/"

def process_contest(contest, persons)
  ps = [] of {String, Int64}
  contest.ids.each do |contest_id|
    filename = "#{DATA_PATH}#{contest_id}.json"
    if !File.exists?(filename)
      puts "download #{contest_id}..."
      if contest.mul
        response = HTTP::Client.get("https://atcoder.jp/contests/#{contest_id}/standings/multiply_ranks/json")
      else
        response = HTTP::Client.get("https://atcoder.jp/contests/#{contest_id}/standings/json")
      end
      json = JSON.parse(response.body)
      File.write(filename, response.body)
      sleep(2)
    else
      json = JSON.parse(File.read(filename))
    end
    if contest.mul
      json["StandingsData"].as_a.each do |p|
        name = p["UserScreenName"].as_s
        score = p["TotalResult"]["Score"].as_i64
        if score > 0 && ps.all? { |p| p[0] != name }
          ps << {name, score}
        end
      end
    else
      json["StandingsData"].as_a.each do |p|
        name = p["UserScreenName"].as_s
        score = p["TotalResult"]["Score"].as_i64
        if score > 0 && ps.all? { |p| p[0] != name }
          ps << {name, -score}
        end
      end
    end
  end
  # puts "#{contest.short_name} #{ps.size}"
  prev_rank = 0
  ps.sort_by { |p| p[1] }.each_with_index do |p, i|
    rank = i > 0 && ps[i - 1][1] == p[1] ? prev_rank : i
    if !persons.has_key?(p[0])
      person = Person.new(p[0])
      persons[p[0]] = person
    else
      person = persons[p[0]]
    end
    person.sum += GP30[rank] if rank < GP30.size
    person.win += 1 if rank == 0
    person.top5 += 1 if rank < 5
    person.top10 += 1 if rank < 10
    person.count += 1
    prev_rank = rank
  end
end

def main
  Dir.mkdir(DATA_PATH) if !Dir.exists?(DATA_PATH)
  persons_hash = {} of String => Person
  CONTESTS.each do |contest|
    process_contest(contest, persons_hash)
  end
  persons = persons_hash.values.sort_by { |p| {-p.sum, -p.win, -p.top5, -p.top10, -p.count, p.name} }
  puts ECR.render("template/ranking.ecr")
  # persons.each do |p|
  #   puts p
  # end
end

main
