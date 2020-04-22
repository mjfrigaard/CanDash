
# set the theme for highcharter
thm <-

  highcharter::hc_theme(

    colors = c("#006400", "#59B18C", "#7FDA80"),

    chart = list(

      backgroundColor = "transparent",

      style = list(fontFamily = "Ubuntu")
    ),

    xAxis = list(

      gridLineWidth = 1

    )
)
