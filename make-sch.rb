#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'date'
require 'time'
require 'yaml'
require_relative 'time_range'
require_relative 'course'
require_relative 'pt'
require_relative 'practical'
require_relative 'lecture'
require_relative 'formats'
require_relative 'output'

################################################################################

if ARGV.size == 1
  puts "usage: ./make-sch.rb [GROUP FORMAT START_YEAR Alt_time_courses]"
end

group_name = ARGV.shift || 434
format = ARGV.shift || "tex"
start_year = (ARGV.shift || 2011).to_i
alttime = (ARGV.empty? ? "1 2 6 9 12" : ARGV.join(" ")).split.map(&:to_i)

practical = Practical.load(group_name,alttime,start_year,"pz.txt")
lectures,exams = Lecture.load(group_name,start_year,"lk.txt")

first_day = Date.strptime("2011-09-01")
last_day = Date.strptime("2012-01-06")

wd = make_work_days(first_day,last_day,[[PT.new(3,[Time.strptime("18.20","%H.%M"),Time.strptime("18.20","%H.%M")])],
                                   practical,
                                   lectures
                                  ])

File.open("#{group_name}.#{format}","w").write(output(group_name,wd,FORMATS[format]))
