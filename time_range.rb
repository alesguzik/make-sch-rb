# -*- coding: utf-8 -*-
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
