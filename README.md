Font-Free OCR
===========

This project was an attempt to implement a Font-Free OCR algorithm in MATLAB. It is loosely based on work by Kae & Learned-Miller(1). Modifications were made in an attempt to simplify the algorithm, language model, and to reduce computation time. It was completed as a final project for CS 670 (Graduate Computer Vision) at The University of Massachusetts at Amherst.

The algorithm takes as input an image of words stacked one word per line and returns a string representing the text in the image. It does this by comparing characters to each other, making sets of matched characters, and comparing the cardinality of each set to the expected letter frequency. In plain English, this means that the program assumes that the largest set of matched characters is the set containing every "E", the second largest contains every "A", and so on.

In short, this project is an attempt to use Mutual Information (useful for image alignment) and a very basic model of the English Language to transcribe text. 

decodeText.m -> decodeText(words) - This is the entry point of the program.  You don't need to provide an argument. If you run without making any changes to the source, it will produce a pretty decent translation of the text, but this is using a modified English character distribution. To use the "true" distribution (that is to say, the letter frequency gathered from a very large sample of modern texts), comment out line 125 of decodeText.m, and uncomment lines 118-124. You will observe that the output is much worse.

mutualInformationBetweenCharacters.m - this is the real heart of the algorithm. It takes 2 13x17 images (with 0 or 1 as pixel values) and produces a number representing the amount of mutual information between those images. Basically, it computes a 2x2 joint distribution where each box represents the number of times each pixel value combination appears in both images. So if a given pixel in both images is black, the box representing (0,0) is incremented by 1. If one is black and the other is white, the box (0,1) is incremented. At the end, there is a call to mutInfo(table) which computes the actual mutual information. The long and short of this is that mutual information is high when images are similar or reveal a lot about each other.

In general, accuracy is hugely dependent on the amount of text to transcribe (more is better) as well as the font choice (fonts with many similar characters may present issues).

The big lesson here is that letter frequency is not a particularly strong language model. The project is presented AS-IS (With lots of hard-coded constants representing image size, character width, etc), in the hope that someone may find it interesting or useful. The algorithm could be improved dramatically through the use of bigrams or other rudimentary language model enhancement. There is also a fair amount of difficult to improve MATLAB code (namely, big for loops)

There are some restrictions on the current input:
-The algorithm can only process monospace fonts (This could be relaxed using connected component analysis, splitting with vertical lines betwen characters, etc)
-The algorithm can only process English text of sufficient length such that the character frequency matches English


(1)
Kae, Andrew, and Erik Learned­Miller. Learning on the Fly: Font­Free Approaches to Difficult
OCR Problems. Dept. of Computer Science, n.d. Web. 2 Dec. 2013.
<http://vis­www.cs.umass.edu/papers/kae_miller_ICDAR_09.pdf>.
