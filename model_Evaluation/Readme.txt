Model Evaluation is based on two metrics--1.Model Level 2.Geometry Level
Input: Groundtruth csv and Prediction csv
output:A csv file with 1.chunk name 2. number of lines' mismatch 3. number of functions' mismatch 4. number of no matches 5.geometry error
Process:1.Compare the number of lines of two models first and record it
	2.Regard the first line and last line of the csv as the two solid lines
	3.Calculate two model's road width(distance between two solid lines) for normalization use
	4.Match two model's solid lines first
	5.Match dash lines by setting a threashold, if there is no lines can be matched in this threashold ,
	  then just record no match for this line
	6.For each paired line, get one of the two lines' start point and end point, then caluclate the distance 
	  of the two points to the other line, get their mean value as the error
	7.Match whether there is a function mismatch for each paired lines, if so, record it

note: 1. There maybe some empty prediction csv file, record as empty
      2.Among the 503 chunks in groundtruth category, there are 15 chunks missing a solid line in json file for some unknown reasons now(the label
	has no problem after looking into the semitool result), and these 15chunks will be abondaned
     
	