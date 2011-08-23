# -*- coding: utf-8 -*-

FORMATS = { #header(group),day_begin(date,courses_num),course(course),day_end(date,courses_num),footer(group)
  "txt" => {
    header:->(group){
      "-= Расписание группы #{group} =-\n"
    },
    day_begin:->(date,courses_num){
      date.strftime("%%s, %d %%s %Y\n") % [DAY_NAMES[date.wday],MONTH_NAMES[date.month]]
    },
    course:->(course){
      course.format('  | %t1 | %t2 | %(40)n | %(30)p'+"\n")
    },
    day_end:->(date,courses_num){
      ""
    },
    footer:->(group){
      ""
    }
  },
  "html" => {
    header:->(group){
template =<<EOF
<html>
  <head>
    <meta charset="utf-8"/>
    <style>
    </style>
  </head>
  <body>
    <h1>Расписание группы #{group}</h1>
    <table>
    <th>
      <tr>
        <td>С</td>
        <td>По</td>
        <td>Дисциплина</td>
        <td>База</td>
      </tr>
    </th>
    <tbody>
EOF
    },
    day_begin:->(date,courses_num){
      template =<<EOF
      <th>
        <td colspan=4>
          %s
        </td>
      </th>
EOF
      template % "#{date.strftime("%%s, %d %%s %Y") % [DAY_NAMES[date.wday],MONTH_NAMES[date.month]]}"
    },
    course:->(course){
      course.format("<tr><td> %t1 </td><td> %t2 </td><td> %(30)n </td><td> %(30)p </td></tr>\n")
    },
    day_end:->(date,courses_num){
      ""
    },
    footer:->(group){
<<EOF
    </tbody>
    </table>
  </body>
</html>

EOF
    }
  },

  "tex" => {
    header:->(group){
'%% -*- coding: utf-8 -*-
\documentclass[a4paper,10pt,notitlepage]{report}
\usepackage[utf8]{inputenc}
\usepackage{longtable}
\usepackage{geometry}
\usepackage[russian]{babel}
\geometry{left=1cm}
\geometry{right=1cm}
\geometry{top=1cm}
\geometry{bottom=1cm}

\pagestyle{empty}

\begin{document}
\begin{center}

{\Large Расписание группы \No %s}
{\footnotesize
\begin{longtable}{r|c|l|l|}

\hline \multicolumn{1}{|c|}{\textbf{Дата}} &
\multicolumn{1}{c|}{\textbf{Время}} &
\multicolumn{1}{c|}{\textbf{Дисциплина}} &
\multicolumn{1}{c|}{\textbf{База}} \\\\
\hline
\hline
\endhead

\multicolumn{4}{r|}{{\slshape Продолжение на следующей странице}} \\\\
\endfoot

\hline
\endlastfoot

' % group
    },
    day_begin:->(date,courses_num){
      (date.strftime("\\hline %%s, %d %%s %Y\n") % [DAY_NAMES[date.wday],MONTH_NAMES[date.month]]) + (courses_num == 0 ? '& \multicolumn{3}{|c|}{Странно, но занятий нет} \\\\'+"\n" : "")

    },
    course:->(course){
      course.format('  & %t1 -- %t2 & %n & %p \\\\ \cline{2-4}'+"\n")
    },
    day_end:->(date,courses_num){
      ""
    },
    footer:->(group){
'
\end{longtable}
}
\end{center}
\end{document}
'
    }
  },

}
