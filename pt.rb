# -*- coding: utf-8 -*-
require_relative 'course'
class PT < Course
  def initialize(day_of_week,time)
    super("Физкультура","",time)
    @day_of_week = day_of_week
  end
  def at?(day)
    day.wday == @day_of_week
  end
end
