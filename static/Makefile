#DAT = 440Hz.png 440Hz_st.png
#DAT = glas/galliard.png glas/galliard_st.png
# sox $< -n trim 0 5 spectrogram -t $(@:%.png=%) -o $@

IMG = demo1.png demo2.png

all: $(IMG)

.PHONY: v
v: $(IMG)
	chafa $^

demo1.png: ../sf_ampl.png
	cp $< $@

demo2.png: ../sf_spekter_x.png ../sf_spekter_y.png ../sf_spektrogram_x.png ../sf_spektrogram_y.png
	magick montage -verbose $^ -mode concatenate -tile 2x2 $@
