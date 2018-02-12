# minute-interpolate-picarro
An R script that performs a minute-interpolation of time series data from the Picarro machine. 

This works with output from Picarro cavity ring-down spectrometers (CRDS), which in my experience record data at odd intervals (one datapoint every 4 to 8 seconds or something like that). To get the data into a more usable format, it is sometimes helpful to perform an interpolation at 1-minute intervals. I wrote an R script for that.

The current process for getting Picarro data into usable format involves collecting all of the data in a '.dat' file and then copying data into a CSV before manipulation in R. 

The first step is to use the software on the Picarro itself to combine all datasets and convert them to '.dat' format. Then you have to copy the data from '.dat' into csv (I used the matlab gui data viewer to manually copy and paste data). Then run the R script on the data.

# Critical Information

It is important to make sure that the time/date field in the csv is in a format which matches the 'data_date_format' variable in the script. 

This performs a minute interpolation, not a running average - the data is not smoothed in any way.
