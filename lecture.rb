# -*- coding: utf-8 -*-
require_relative 'course'
class Lecture < Course

  def self.load(group_name,start_year,file)
    lk = File.open(file).lines.map{|l| l.chomp.split("\t")}
    lk.shift
    lectures = []
    exams = []
    lk_time = nil
    lk.each do |line|
      lk_time ||= line[0]
      if line[1] and line[2]
        lectures += Lecture.parse(line[1],line[2],lk_time,start_year)
      end
      if line[3]
        exams.push [line[3],line[4] || ""]
      end
    end
    return lectures,exams
  end

  def initialize(name,place,time,date)
    super(name,place,time)
    @date = date
  end
  def at?(day)
    @date == day
  end
  def self.parse(name,dates_places,time,start_year)
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
          Date.strptime("#{m>=9 ? start_year : start_year+1}-#{m}-#{d}")
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
