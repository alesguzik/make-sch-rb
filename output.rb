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
