# -*- coding: utf-8 -*-
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
end
