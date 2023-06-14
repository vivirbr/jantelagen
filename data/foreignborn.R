library(tidyverse)
library(gganimate)
library(RColorBrewer)


source("jantelagen/data/api-query.R") #returns the px_data_frame
print(px_data_comments)
unique(px_data_frame$sex)

to_remove_birth <- c("All birth countries","Sweden")
to_remove_region <- c(unique(px_data_frame$region)[grep("county",unique(px_data_frame$region))])


#--------------- Country --------------#

number_by_country <- px_data_frame %>% 
                     filter(!region %in% to_remove_region) %>%                      
                     filter(!`region of birth` %in% to_remove_birth) %>%
                     filter(sex!="total") %>%
                     group_by(`region of birth`, year) %>% 
                     summarize(population=sum(Population,na.rm=T)) %>%
                     rename(country=`region of birth`)
      
ranked_data <- number_by_country %>%
                     group_by(year) %>%
                     mutate(ranks = order(order(population, decreasing=TRUE)))

formatted <- ranked_data %>%
                    mutate( population_rel = population/population[ranks==1],
                            population_lbl = paste0(" ",population)) %>%
                    group_by(year) %>% 
                    filter(ranks <=15) %>%
                    ungroup()

region <- data.frame(country=unique(formatted$country),
                     region=c("Asia","Europe (except EU and Nordic)","South America","Asia","Nordic","Africa","Nordic","EU except Nordic","Asia","Asia",
                              "Asia","Asia","Nordic","-","EU except Nordic","Africa","Asia","Asia","Africa","EU except Nordic","North America","Europe (except EU and Nordic)"))

formatted_region <- merge(formatted,region,by="country",all.x=T)

formatted_region %>% filter(year==2021) %>% group_by(region) %>% summarize(sum(population))


# palette
# pal <- colorRampPalette(brewer.pal(8, "Dark2"))(9)
pal <- c("#E66101","#80CDC1","#5E3C99","#0571B0","#D01C8B","#018571","#BABABA","#B2ABD2")

staticplot = ggplot(formatted_region, aes(ranks, group = country, fill = as.factor(region))) +
             geom_tile(aes(y = population/2, height = population, width = 0.9), alpha = 0.8, color = NA) +
             geom_text(aes(y = 0, label = paste(country, " ")), vjust = 0.2, hjust = 1, color="black") + # country name in black
             geom_text(aes(y=population,label = population_lbl, hjust=0)) +
             coord_flip(clip = "off", expand = FALSE) +
             scale_y_continuous(labels = scales::comma) +
             scale_x_reverse() +
             scale_fill_manual(values = pal)+
             guides(color = FALSE, fill = FALSE) +
             theme(axis.line=element_blank(),
                   axis.text.x=element_blank(),
                   axis.text.y=element_blank(),
                   axis.ticks=element_blank(),
                   axis.title.x=element_blank(),
                   axis.title.y=element_blank(),
                   legend.position="none",
                   panel.background=element_blank(),
                   panel.border=element_blank(),
                   panel.grid.major=element_blank(),
                   panel.grid.minor=element_blank(),
                   panel.grid.major.x = element_line( size=.1, color="grey" ),
                   panel.grid.minor.x = element_line( size=.1, color="grey" ),
                   plot.title=element_text(size=25, hjust=0, face="bold", colour="black", vjust=1),
                   plot.caption =element_text(size=10, hjust=1, face="italic", color="black"),
                   plot.background=element_blank(),
                   plot.margin = margin(4,6, 4, 6, "cm"))



anim = staticplot + transition_states(year, transition_length = 5, state_length = 1) +
       view_follow(fixed_x = TRUE)  +
       labs(title = 'Foreignborn population in Sweden : {closest_state}',
            caption  = "Total number of people | Data Source: SCB Statistics Sweden")

animate(anim, 500, fps = 20,  width = 1000, height = 800, 
        renderer = ffmpeg_renderer()) -> for_mp4

anim_save("foreignborn.mp4", animation = for_mp4 )

