# -*- coding: utf-8 -*-
require_relative 'course'
class Practical < Course
  def self.load(group_name,alttime,start_year,file)
    pz = File.open(file).lines.to_a
    practical = pz.shift.chomp.split("\t").zip(pz.shift.chomp.split("\t")).map do |a|
      if a[0][-1]=='-'
        a[0][0...-1] + a[1]
      else
        a.join(" ")
      end
    end

    time = pz.shift.match(/(\d\d\.\d\d)\-(\d\d\.\d\d)\D*(\d\d\.\d\d)\-(\d\d\.\d\d)/)[1,4]
    pz_times = time.map{|s| Time.strptime s,"%H.%M"}
    pz_t = []
    practical.size.times do |i|
      if alttime.include?(i)
        pz_t.push pz_times[0,2]
      else
        pz_t.push pz_times[2,2]
      end
    end
    
    places = pz.shift.chomp.split("\t")
    groups = pz.map{|g| g.chomp.split("\t")}
    group = groups.select{|g| g[0].include?(group_name.to_s) }.first

    practical = practical.zip(pz_t,places,group)[1..-1].map do |c|
      name  = c[0]
      time  = c[1]
      place = c[2]
      dates = c[3]
      match = dates.match(/\D*(\d\d)\.(\d\d)\-(\d\d)\.(\d\d)\D*/)
      format = "%4d-%s%d-%s%d"
      if match
        d1,m1,d2,m2 = match[1,4].map(&:to_i)
        from = Date.strptime(format % [((m1>=9) ? start_year : start_year+1),
                                       (m1<10 ? "0":""), m1,
                                       (d1<10 ? "0":""), d1])
        til  = Date.strptime(format % [((m2>=9) ? start_year : start_year+1),
                                       (m2<10 ? "0":""), m2,
                                       (d2<10 ? "0":""), d2])
      else
        match = dates.match(/\D*(\d\d)\-(\d\d)\.(\d\d)\D*/)
        if match
          d1,d2,m = match[1,3].map(&:to_i)
          from = Date.strptime(format % [((m>=9) ? start_year : start_year+1),
                                         (m <10 ? "0":""), m,
                                         (d1<10 ? "0":""), d1])
          til  = Date.strptime(format % [((m>=9) ? start_year : start_year+1),
                                         (m <10 ? "0":""), m,
                                         (d2<10 ? "0":""), d2])
        end
      end
      Practical.new name, place, time, from, til
    end
  end

  def initialize(name,place,time,first_date,last_date)
    super(name,place,time)
    @first_date,@last_date = first_date,last_date
  end
  def at?(day)
    @first_date <= day and day <= @last_date
  end
end
