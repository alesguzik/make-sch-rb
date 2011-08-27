#!/usr/bin/env ruby
(433..446).each do |i|
  system(
    "./make-sch.rb #{i};
    pdflatex #{i}.tex;
    pdflatex #{i}.tex;
    pdflatex #{i}.tex;
    rm #{i}.aux;
    rm #{i}.log"
  )
end
