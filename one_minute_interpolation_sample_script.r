

#Sample script for how to load time series data and perform 1-minute interpolation.

#Functions------------

#First I have a script to load the raw data into memory, and fix the date format:

load_timeseries_data <- function(directory_path,file_name, date_format, date_time_column_label = 'time'){
  
  #read the excel file
  
  if (grepl(".csv", file_name)){
    output <- read.csv(paste(directory_path,"/",file_name, sep = "")) #
    
  }else if (grepl(".xlsx", file_name)){
    output <- read.xlsx(paste(directory_path,"/",file_name, sep = ""))
  }
  
  #fix the date format...
  
  output[[date_time_column_label]] <- as.POSIXlt(strptime(output[[date_time_column_label]], format = date_format, tz = "GMT"))
  
  #remove all of the rows where date_time is not defined:
  
  output <- output[is.na(output[[date_time_column_label]])==FALSE,]
  
  return(output)
}


#Then I have a script to do a 1-minute interpolation of the data

one_minute_interp <- function(input_matrix, date_time_column_label = 'time'){
  
  start_time <- input_matrix[[date_time_column_label]][1]
  end_time <- input_matrix[[date_time_column_label]][length(input_matrix[[date_time_column_label]])]
  
  max_time <- end_time
  
  #make a time sequence of interval 1 minute starting at the start time:
  
  time_seq <- seq(start_time,max_time,by=60)
  
  #initialize the output matrix:
  
  output <- c()
  
  #create a list of the datasets that I want to interpolate:
  
  datasets_to_interpolate <- colnames(input_matrix)[colnames(input_matrix)!= date_time_column_label]
  
  #interpolate the first dataset
  
  #print("interpolating the first dataset...")
  
  first_interpolation <- approx(x=input_matrix[[date_time_column_label]], y=input_matrix[,datasets_to_interpolate[1]],
                                xout=time_seq)
  
  #print("first dataset interpolated")
  
  #add the "date" field to the output matrix:
  
  #print("adding the time vector to the output...")
  output[[date_time_column_label]] <- first_interpolation$x
  #print("done.")
  
  #convert input and output to a dataframe (necessary for next step)
  
  output <- as.data.frame(output)
  input_matrix <- as.data.frame(input_matrix)
  
  #interpolate each dataset in the list, and append to the output:
  for(entry in datasets_to_interpolate){
    if (length(na.omit(input_matrix[,entry]))>1){ #assuming there is more than one non-NA entry...
      interpolated_dataset <- approx(x=input_matrix[[date_time_column_label]], y=input_matrix[,entry],
                                     xout=time_seq)
      output[,entry] <- interpolated_dataset$y
    }
  }
  return(output)
}

#Example with sample data--------------

# First set the directory path where the files are found and 
# the format for the dates (in the date_time field)

base_directory <- '~/Desktop/one_minute_interp'

#Check to make sure the date/time format matches what is in the csv sheet

data_date_format <- "%d/%m/%Y %H:%M:%S"

fitzroy_wet_season_filename <- 'fitzroy_survey_raw_data.csv'


fitzroy_survey_wet_season<- load_timeseries_data(directory_path = base_directory,
                                      file_name = fitzroy_wet_season_filename,
                                      date_format = data_date_format, 
                                      date_time_column_label = 'time')

fitzroy_survey_wet_season_minute_interp <- one_minute_interp(input_matrix = fitzroy_survey_wet_season,
                                                             date_time_column_label = 'time')

#plot the data to see if it works...

plot(fitzroy_survey_wet_season$time[1:500], 
     fitzroy_survey_wet_season$N2O.corr[1:500],main = 'Fitzroy Raw and minute-interpolated data', col = "gray")

points(fitzroy_survey_wet_season_minute_interp$time[1:500], 
       fitzroy_survey_wet_season_minute_interp$N2O.corr[1:500], 'b')


#write the output as a csv file

write.csv(fitzroy_survey_wet_season_minute_interp, 
          paste(base_directory,"/","fitzroy_survey_wet_minute_interp.csv", sep = ""))

