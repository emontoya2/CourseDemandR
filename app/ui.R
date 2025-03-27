
ui <- fluidPage(
  useShinyjs(),
  titlePanel("A Data-Driven Tool for General Education Enrollment: Statistical Analysis & Scenario Planning"),
  tabsetPanel(
    ##
    tabPanel("Overview",
             sidebarLayout(
               sidebarPanel(
                 div(id = "resettableInputs",
                     selectInput("Term", "Select Term(s):", 
                                 choices = unique(combinedData$Term), 
                                 selected = unique(combinedData$Term)[length(unique(combinedData$Term))], 
                                 multiple = TRUE),
                     selectInput("GEreq", "Select GE Requirement:", 
                                 choices = NULL,  
                                 selected = NULL, multiple = TRUE),
                     selectInput("College", "Select College:", 
                                 choices = NULL,  
                                 selected = NULL, multiple = TRUE),
                     selectInput("Subject", "Select Subject:", 
                                 choices = NULL,  
                                 selected = NULL, multiple = TRUE),
                     sliderInput("rateA", "Average fill rate:", 
                                 min = 0, max = 1,  
                                 value = c(0, 1), step = 0.01)#,
                     #sliderInput("rateB", "Median fill rate:", 
                    #             min = 0, max = 1,  
                    #             value = c(0, 1), step = 0.01)
                 ),
                 actionButton("resetBtn", "Reset App"),
                 width = 2  # Makes the sidebar narrower
               ),
               mainPanel(
                 conditionalPanel(
                   condition = "input.GEreq != null && input.GEreq.length > 0",
                   h3("GE Requirement Summary"),
                   plotOutput("gePlot")
                 ),
                 h3("GE Courses"),
                 DT::dataTableOutput("courseTable")
               )
             )
    ) ,
    ##
    tabPanel("High Fill Rate Courses",
             fluidPage(
               numericInput("highFillThreshold", "Fill Rate Threshold:", 
                            value = 0.90, min = 0, max = 1, step = 0.01),
               h3("Courses with Average Rate > the threshold"), #or Median Fill Rate
               DT::dataTableOutput("highFillTable")
             )
    ) ,
    ##
    tabPanel("Low Fill Rate Courses",
             fluidPage(
               numericInput("lowFillThreshold", "Fill Rate Threshold:", 
                            value = 0.25, min = 0, max = 1, step = 0.01),
               h3("Courses with Average Rate < the threshold"), #or Median Fill
               DT::dataTableOutput("lowFillTable")
             )
    ) ,
    ##
    #tabPanel("Box Plot",
    #         fluidPage(
    #           h3("Box Plot: Average Fill Rate by College"),
    #           plotOutput("boxPlot")
    #         )
    #),
    ##
    tabPanel("Pairwise Correlation by GE Area",
             fluidPage(
               h3("Pairwise GE Correlation Analysis for Foundational Skills, Lower-Division GE, and Upper-Division GE -- across all Terms"),
               DT::dataTableOutput("pairwiseTable")
             )
    ) ,
    ##
    tabPanel("GE Area Correlation Heatmap",
             fluidPage(
               h3("Correlation of GE Area Fill Rates Across Terms"),
               plotOutput("correlationHeatmap", height = "700px")
             )
    ),
    ##
    tabPanel("Number of Sections Per Course: A What-If Analysis",
             fluidPage(
               # Single row for inputs arranged horizontally:
               fluidRow(
                 column(4,
                        selectInput("simCourse", "Select Course for What-If Analysis:", 
                             choices = sort(unique(combinedData$Course)))
                 ),
                 column(4,
                        numericInput("newSectionCount", "New Section Count:", 
                              value = 10, min = 1, step = 1)
                 ),
                 column(4,
                        numericInput("newTotalEnrollment", "New Total Enrollment (optional):", 
                              value = NA, min = 1, step = 1)
                 )
               ),
               # Add vertical space between the input row and the output row:
               fluidRow(
                 column(12, tags$br(), tags$br())
               ),
               fluidRow(
                 column(12,
                 h3("What-If Analysis Results"),
                 DT::dataTableOutput("simTable")
                 )
               )
               )
             )  ,
    ##
    tabPanel("Number of Sections Per GE Area: A What-If Analysis",
             fluidPage(
               # Single row for inputs arranged horizontally:
               fluidRow(
                 column(4,
                        selectInput("simGEarea", "Select GE Area for What-If Analysis:",
                                    choices = sort(unique(c(combinedData$Req_1, combinedData$Req_2))),
                                    selected = NULL)
                 ),
                 column(4,
                        numericInput("newGESectionCount", "New Total Section Count for GE Area:", 
                                     value = 10, min = 1, step = 1)
                 ),
                 column(4,
                        numericInput("newGEEnrollment", "New Total Enrollment (optional):", 
                                     value = NA, min = 1, step = 1)
                 )
               ),
               # Add vertical space between the input row and the output row:
               fluidRow(
                 column(12, tags$br(), tags$br())
               ),
               # Output row:
               fluidRow(
                 column(12,
                        h3("What-If Analysis Results"),
                        DT::dataTableOutput("simGETable")
                 )
               )
             )
    ) ,
    ##
    tabPanel("Section Count vs. Fill Rate",
             fluidPage(
               h3("Relationship Between Number of Sections and Fill Rate"),
               plotOutput("sectionVsFillPlot", height = "500px")
             )
    ),
    ##
    tabPanel("Variable Definitions",
             h3("Definitions of variables displayed in the Shiny app"),
             tags$ul(
               tags$li(strong("Term:"), " Semester Term."),
               tags$li(strong("College:"), "The college within the institution."),
               tags$li(strong("Course:"), "Subject and catalog number."),
               tags$li(strong("Req_1:"), "GE requirement fulfilled by the course."),
               tags$li(strong("Req_2:"), "Second GE requirement fulfilled by the course."),
               tags$li(strong("Avg_fill_rate:"), "The ratio of average enrollment to the course capacity based on GE course caps."),
               #tags$li(strong("Median_fill_rate:"), "The ratio of median enrollment to the course capacity based on GE course caps."),
               tags$li(strong("GEcapsize:"), "GE course caps."),
               tags$li(strong("Avg_cap_diff:"), "The average difference between GE course caps and department-set course caps."),
               tags$li(strong("Avg_enrl:"), "The average enrollment across all sections of the course."),
               #tags$li(strong("Med_enrl:"), "The median enrollment across all sections of the course."),
               tags$li(strong("Crs_section_cnt:"), "The total number of sections offered for the course.")
             )
    )
  )
)