#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

if ARGV.size == 1
  puts "usage: ./make-sch.rb [GROUP [START_YEAR [Alt_time_courses]]]"
end

require 'date'
require 'time'
require 'yaml'

DAY_NAMES=%w(Вс Пн Вт Ср Чт Пт Сб Вс)
MONTH_NAMES=%w(нулября января февраля марта апреля мая июня июля августа сентября октября ноября декабря)

class TimeRange
  include Comparable
  attr_reader :t1,:t2
  def initialize(t1,t2)
    @t1,@t2 = t1,t2
  end
  def <=>(other)
    if t1 != other.t1
      t1.<=>(other.t1)
    else
      t2.<=>(other.t2)
    end
  end
end

class Course
  include Comparable
  DEFAULT_FORMAT = '| %t1 | %(%H:%M:%S)t2 | %(50)n | %(50)p |'
  attr_reader :name,:place,:time
  def initialize(name,place,time)
    @name,@place,@time = name.split.join(" "),place,TimeRange.new(*time)
  end
  def <=>(other)
    @time <=> other.time
  end
  def format(format = DEFAULT_FORMAT)
    r=''
    fmt=format.chars.to_a
    subfmt = nil
    while c = fmt.shift
      unless c == "%"
        r << c
      else
        c = fmt.shift
        r << case c
             when '%' then '%'
             when '(' then
               subfmt = ""
               while((sfc = fmt.shift) != ')')
                 subfmt << sfc
               end
               fmt = ['%'] + fmt
               ""
             when 't' then
               s=@time.send("t#{fmt.shift}").strftime(subfmt || "%H:%M")
               subfmt=nil
               s
             when 'n'
               s = "%#{subfmt}s" % @name
               subfmt = nil
               s
             when 'p'
               s = "%#{subfmt}s" % @place
               subfmt = nil
               s
             else
               '!ERROR!'
             end
      end
    end
    r
  end

  # def to_s
  #   format
  # end

#  def at?(day); end
end

class PT < Course
  def initialize(day_of_week,time)
    super("Физкультура","",time)
    @day_of_week = day_of_week
  end
  def at?(day)
    day.wday == @day_of_week
  end
end

class Practical < Course
  def initialize(name,place,time,first_date,last_date)
    super(name,place,time)
    @first_date,@last_date = first_date,last_date
  end
  def at?(day)
    @first_date <= day and day <= @last_date
  end
end

class Lecture < Course
  def initialize(name,place,time,date)
    super(name,place,time)
    @date = date
  end
  def at?(day)
    @date == day
  end
  def self.from_pair(name,time,dates_places)
    lectures = []
    fields = dates_places.delete('"').split
    dates = []
    times = time.split("-").map{|t| Time.strptime(t,"%H.%M")}
    place_parts = []
    fields.each do |f|
      if m = f.match(/\D*(\d\d\.\d\d(;\d\d\.\d\d)*)/)
        dates.each do |date|
          lectures.push Lecture.new(name,place_parts.join(" "),times,date)
        end
        dates = m[1].split(";").map do |s|
          d,m = s.split(".").map(&:to_i)
          Date.strptime("#{m>=9 ? START_YEAR : START_YEAR+1}-#{m}-#{d}")
        end
        place_parts = []
      else
        place_parts.push f unless %w(- –).include?(f)
      end
    end
    dates.each do |date|
      lectures.push Lecture.new(name,place_parts.join(" "),times,date)
    end
    lectures
  end
end

pz = File.open("pz.txt")
practical = pz.gets.chomp.split("\t").zip(pz.gets.chomp.split("\t")).map{|a| "#{a[0]} #{a[1]}"}

START_YEAR = (ARGV[2] || 2011).to_i

alttime = (ARGV[3] || "1 2 6 9 12").split.map(&:to_i)

time = pz.gets.match(/(\d\d\.\d\d)\-(\d\d\.\d\d)\D*(\d\d\.\d\d)\-(\d\d\.\d\d)/)[1,4]
pz_times = time.map{|s| Time.strptime s,"%H.%M"}
pz_t = []
practical.size.times do |i|
  if alttime.include?(i)
    pz_t.push pz_times[0,2]
  else
    pz_t.push pz_times[2,2]
  end
end

places = pz.gets.chomp.split("\t")

groups = []
14.times do
  groups.push pz.gets.chomp.split("\t")
end
group = groups.select{|g| g[0].include?(ARGV[1] || '434') }[0]

practical = practical.zip(pz_t,places,group)[1..-1].map do |c|
  name  = c[0]
  time  = c[1]
  place = c[2]
  dates = c[3]
  match = dates.match(/\D*(\d\d)\.(\d\d)\-(\d\d)\.(\d\d)\D*/)
  format = "%4d-%s%d-%s%d"
  if match
    d1,m1,d2,m2 = match[1,4].map(&:to_i)
    from = Date.strptime(format % [((m1>=9)?START_YEAR : START_YEAR+1),
                                   (m1<10 ? "0":""), m1,
                                   (d1<10 ? "0":""), d1])
    til  = Date.strptime(format % [((m2>=9)?START_YEAR : START_YEAR+1),
                                   (m2<10 ? "0":""), m2,
                                   (d2<10 ? "0":""), d2])
  else
    match = dates.match(/\D*(\d\d)\-(\d\d)\.(\d\d)\D*/)
    if match
      d1,d2,m = match[1,3].map(&:to_i)
      from = Date.strptime(format % [((m>=9)?START_YEAR : START_YEAR+1),
                                     (m <10 ? "0":""), m,
                                     (d1<10 ? "0":""), d1])
      til  = Date.strptime(format % [((m>=9)?START_YEAR : START_YEAR+1),
                                     (m <10 ? "0":""), m,
                                     (d2<10 ? "0":""), d2])
    end
  end
  Practical.new name, place, time, from, til
end

lk = File.open("lk.txt").lines.map{|l| l.chomp.split("\t")}
lk_header = lk.shift
lectures = []
exams = []
lk_time = nil
lk.each do |line|
  lk_time ||= line[0]
  if line[1] and line[2]
    lectures += Lecture.from_pair(line[1],lk_time,line[2])
  end
  if line[3]
    exams.push [line[3],line[4] || ""]
  end
end

first_day = Date.strptime("2011-09-01")
last_day = Date.strptime("2012-01-06")
day = first_day
work_days = {}
while(day<=last_day)
  unless day.saturday? or day.sunday?
    work_days[day] ||= []
    [[PT.new(3,[Time.strptime("18.20","%H.%M"),Time.strptime("18.20","%H.%M")])],
     practical,
     lectures
    ].each do |t|
      t.each do |c|
        if c.at? day
          work_days[day].push c
        end
        work_days[day].sort!
      end
    end
  end
  day += 1
end

formats = { #header(group),day_begin(date),course(course),day_end(date),footer(group)
  :txt => { header:->(group){
              "-= Расписание группы %s =-\n" % group
            },
            day_begin:->(date){
              "#{date.strftime("%%s, %d %%s %Y") % [DAY_NAMES[date.wday],MONTH_NAMES[date.month]]}\n"
            },
            course:->(course){
              "  #{course.format('| %t1 | %t2 | %(30)n | %(30)p')}\n"
            },
            day_end:->(date){
              ""
            },
            footer:->(group){
              "А вот и сессия.\n"
            }
  }
}

p group
def output(group,work_days,formatters)
  o = STDOUT
  o << formatters[:header].(group)
  work_days.each do |date,courses|
    o << formatters[:day_begin].(date)
    courses.each do |course|
      o << formatters[:course].(course)
    end
    o << formatters[:day_end].(date)
  end
  o << formatters[:header].(group)
end

output(group,work_days,formats[:txt])

