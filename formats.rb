# -*- coding: utf-8 -*-

FORMATS = { #header(group),day_begin(date),course(course),day_end(date),footer(group)
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
