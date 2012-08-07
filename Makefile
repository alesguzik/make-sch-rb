all:
	i=433; while [[ $$i -le 446 ]] ; do \
		./make-sch.rb $$i; \
		pdflatex $$i.tex; \
		pdflatex $$i.tex; \
		pdflatex $$i.tex; \
		rm $$i.aux; \
		rm $$i.log; \
		((i = i + 1));\
	done

