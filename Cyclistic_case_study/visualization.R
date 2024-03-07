# Installing all packages needed
install.packages("dplyr")
install.packages("tidyverse")
install.packages("tibble")
install.packages("ggplot2")
install.packages("readr")
install.packages("chron")
install.packages("lubridate")

# Loading all packages needed
library(readr)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(tibble)
library(chron)
library(lubridate)

# Importing the dataset
all_in_one <- read_csv("C:/Users/ASSIM/Desktop/Projects/Google Data Analysis Certificate/Case study/Case A1/data_csv/all_in_one.csv", 
                       col_types = cols(ride_length = col_time(format = "%H:%M:%S"), 
                                        day_of_week = col_number()))

# Change data types of some columns
all_in_one$ride_id<-as.factor(all_in_one$ride_id)
all_in_one$rideable_type<-as.factor(all_in_one$rideable_type)
all_in_one$start_station_name	<-as.factor(all_in_one$start_station_name	)
all_in_one$end_station_name	<-as.factor(all_in_one$end_station_name	)
all_in_one$member_casual	<-as.factor(all_in_one$member_casual)
all_in_one$started_at	<-as.POSIXct(all_in_one$started_at,format="%m/%d/%Y %H:%M:%S")
all_in_one$ended_at	<-as.POSIXct(all_in_one$ended_at,format="%m/%d/%Y %H:%M:%S")

# Viewing the data
View(all_in_one)
head(all_in_one)
summary(all_in_one)

# First we'll add a months column
months <- format(all_in_one$started_at, "%m")
all_in_one$month_of_ride <- months

# Add a start_hour column by extracting the hour from the started_at column
all_in_one <- all_in_one %>%
  mutate(start_hour = strstr <- hour(all_in_one$started_at))
unique(all_in_one$start_hour)


# A bar chart that shows the difference between casual and member riders
ggplot(data = all_in_one, mapping = aes(x=member_casual)) + geom_bar(fill="#003f5c", width = 0.5)+
  scale_y_continuous(labels = scales::label_comma(), limits = c(0,5000000))+
  labs(x='Rider type',y='Number of trips',
       title = "Difference between casual and member riders",
       subtitle = "In number of trips",
       caption = "Figure 1: Number of trips for Members and Casuals")+
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))
  
# A bar chart that shows the difference between casual and member riders in ride time
ggplot(data = all_in_one, mapping = aes(x=member_casual, y= ride_length)) +
  geom_bar(fun = "mean", stat = "summary", fill="#003f5c", width = 0.5)+
  labs(x='Rider type',y='Average time of a trip',
       title = "Difference between casual and member riders",
       subtitle = "In average time of trips",
       caption = "Figure 2: Average time of trips for Members and Casuals")+
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))  
  
# Saving the plot as png file
ggsave("Comparing rideable_type.png")

# To add more depth to it, we'll add rideable_type as part of the bar
ggplot(data = all_in_one) + geom_bar(mapping = aes(x=member_casual, fill = rideable_type)) +
  scale_y_continuous(labels = scales::label_comma(), limits = c(0,5000000))+
  labs(x='Rider type',y='Number of trips',
       title = "Difference between casual and member riders",
       subtitle = "Comparing rideable type",
       caption = "Figure 3: Compare rideable type for Members and Casuals")+
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.line = element_line(colour = "black"))+
  guides(fill=guide_legend(title="Riderable type"))+
  scale_fill_discrete(breaks =c("classic_bike", "docked_bike", "electric_bike"), labels=c("Classic bike", "Docked bike", "Electric bike"))

# Percentage of number of rides per day_of_week (Pie chart)
ggplot(all_in_one, aes(x = factor(1), fill = factor(day_of_week))) + geom_bar(width = 1,color="white")+
  coord_polar(theta = "y")+
  theme_void() +
  labs(title = "Number of rides per day of week", fill = "Day of week",
       subtitle = "Both members and casuals",
       caption = "Figure 4: Percentage of number of rides per day of week")+
  theme(plot.title = element_text(hjust = 0.5),plot.subtitle = element_text(hjust = 0.5))+
  scale_fill_discrete("Day of week",breaks=c("1","2","3","4","5","6","7"),labels=c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))

# Save the day_of_week column in a new table
counted_data <- all_in_one$day_of_week |>
  table() |>
  as.data.frame()


# Percentage of number of rides per day_of_week (Lines & Points)
ggplot(counted_data,aes(x=Var1,y=Freq))+
  geom_line(group=1)+
  geom_point(size = 2, color = "darkblue")+
  scale_linetype(name='Tree',breaks=1:5)+
  scale_shape(name='Tree',breaks=1:5)+
  scale_y_continuous(limits = c(0,1000000))+
  labs(x='Count',y='Number of rides',
       title='Number of rides per day of week',
       subtitle='Both members and casuals',
       caption = "Figure 5: Percentage of number of rides per day of week")+
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.line = element_line(colour = "black"))+
  scale_x_discrete("Day of week",breaks=c("1","2","3","4","5","6","7"),labels=c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))

# Split the dataset into two tables, one of member and one for casual
counted_data_members <- dplyr::filter(all_in_one, grepl('member', member_casual))
counted_data_members <- counted_data_members$day_of_week |>
  table() |>
  as.data.frame()

counted_data_casuals <- dplyr::filter(all_in_one, grepl('casual', member_casual))
counted_data_casuals <- counted_data_casuals$day_of_week |>
  table() |>
  as.data.frame()

summary(counted_data_members) # Number of Member rows 3,630,818
summary(counted_data_casuals) # Number of Casual rows 2,043,631

# Number of rides per day of week for members
ggplot(counted_data_members,aes(x=Var1,y=Freq))+
  geom_point(size = 2, color = "darkblue")+
  geom_line(group=1)+
  scale_linetype(name='Tree',breaks=1:5)+
  scale_shape(name='Tree',breaks=1:5)+
  scale_y_continuous(limits = c(0,1000000))+
  labs(x='Count',y='Number of rides',
       title='Number of rides per day of week',
       subtitle='For members only',
       caption = "Figure 6: Number of rides per day of week for members")+
       annotate("text",size=4, color = "black", x=5, y=650000, fontface = "bold", label = "Peak")+
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.line = element_line(colour = "black"))+
  scale_x_discrete("Day of week",breaks=c("1","2","3","4","5","6","7"),labels=c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))

# Number of rides per day of week for casuals
ggplot(counted_data_casuals,aes(x=Var1,y=Freq))+
  geom_point(size = 2, color = "darkblue")+
  geom_line(group=1)+
  scale_linetype(name='Tree',breaks=1:5)+
  scale_shape(name='Tree',breaks=1:5)+
  scale_y_continuous(limits = c(0,1000000))+
  labs(x='Count',y='Number of rides',
       title='Number of rides per day of week',
       subtitle='For casuals only',
       caption = "Figure 7: Number of rides per day of week for casuals")+
  annotate("text",size=4, color = "black", x=7, y=450000, fontface = "bold", label = "Peak")+
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.line = element_line(colour = "black"))+
  scale_x_discrete("Day of week",breaks=c("1","2","3","4","5","6","7"),labels=c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))

# Number of rides per month for both Members and Casuals
ggplot(all_in_one, aes(as.numeric(month_of_ride), fill = member_casual)) +
  geom_vline(xintercept=c(6.3,9.3), linetype="dashed", color = "black")+
  geom_bar(position = position_dodge(preserve = "single")) +
  scale_x_continuous(breaks = 1:12, labels=c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")) +
  scale_y_continuous(limits = c(0,500000), labels = scales::label_comma())+
  labs(x='Month',y='Number of rides',
       title='Number of rides per month',
       subtitle='Comparison between Members and Casuals',
       caption = "Figure 8: Number of rides per month for both members and casuals")+
  annotate("text",size=4, color = "black", x=7.7, y=490000, fontface = "bold", label = "Summer months")+
  theme_light()+ 
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))+
  guides(fill=guide_legend(title="Rider type"))

#Average temperature for Chicago
avg_temp <- c(-3.2, -1.2, 4.4, 10.5, 16.6, 22.2, 24.8, 23.9, 19.9, 12.9, 5.8, -0.3)
month <- c(1,2,3,4,5,6,7,8,9,10,11,12)
data.frame(month, avg_temp) %>%
  ggplot(aes(x=month, y=avg_temp)) +
  geom_col(fill = "#003f5c") +
  scale_x_continuous(breaks = 1:12, labels=c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))+
  labs(x="Month", y="Average temperature",
       title="Average temperature for Chicago",
       subtitle = "Across all months",
       caption = "Figure 10: Average temperature for Chicago")+
  theme_light()+ 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))


#stats about each start_hour
all_in_one %>%
  group_by(start_hour) %>% 
  summarise(count = length(ride_id),
            'Percentage' = format(round((length(ride_id) / nrow(all_in_one)) * 100, 2), nsmall = 2),
            'members_percentage' = (sum(member_casual == "member") / length(ride_id)) * 100,
            'casual_percentage' = (sum(member_casual == "casual") / length(ride_id)) * 100,
            'percentage_differance' = members_percentage - casual_percentage)

#Number of trips per hour
ggplot(all_in_one,aes(start_hour, fill=member_casual)) +
  geom_bar()+
  scale_x_continuous(breaks = 0:23)+
  scale_y_continuous(labels = scales::label_comma())+
  labs(x="Hour of the day", y = "Number of trips", title="Number of trips per hour",
       subtitle = "Members vs Casuals",
       caption = "Figure 11: Number of trips per hour")+
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))+
  guides(fill=guide_legend(title="Rider type"))

