# -*- coding: utf-8 -*-
require 'date'

DAY_NAMES=%w(Вс Пн Вт Ср Чт Пт Сб Вс)
MONTH_NAMES=%w(нулября января февраля марта апреля мая июня июля августа сентября октября ноября декабря)

def make_work_days(first_day,last_day,courses)
  day = first_day
  work_days = {}
  while(day<=last_day)
    unless day.saturday? or day.sunday?
      work_days[day] ||= []
      courses.each do |t|
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
  work_days
end

def output(group,work_days,formatters)
  s = ""
  s << formatters[:header].(group)
  work_days.each do |date,courses|
    s << formatters[:day_begin].(date,courses.size)
    courses.each do |course|
      s << formatters[:course].(course)
    end
    s << formatters[:day_end].(date,courses.size)
  end
  s << formatters[:footer].(group)
  s
end
