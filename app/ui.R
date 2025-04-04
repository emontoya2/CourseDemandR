
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
               bsCollapsePanel("Understanding GE Area Correlations",
                               tags$div(
                                 tags$p(
                                   strong("Positive correlatoin:"),
                                   "When two GE areas have a high positive correlation in fill rates, their enrollment patterns tend to move together. This may be due to interconnected factors such as student perceptions of both areas as enjoyable, essential, or manageable; advising practices, curricular pathways, or program structures that encourage simultaneous enrollment; degree requirements promoting concurrent course-taking; and capacity constraints (like limited course sections) that increase simultaneous demand."
                                 ),
                                 tags$p(
                                   strong("Negative correlatoin:"),
                                   "When one GE area experiences increased enrollments, while the other consistently shows decreased enrollments, it suggests an inverse relationship. This may be caused by factors such as advising practices or curricular pathways that discourage simultaneous enrollment; scheduling conflicts forcing students to choose between courses; prerequisite structures that enforce sequential enrollment; or contrasting student perceptions regarding difficulty, value, or relevance between the two GE areas."
                                 )
                               ),
                               style = "primary"
               ),
               
               
               DT::dataTableOutput("pairwiseTable")
             )
    ) ,
    ##
    tabPanel("GE Area Correlation Heatmap",
             fluidPage(
               h3("Correlation of GE Area Fill Rates -- across all Terms"),
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
               bsCollapsePanel("Trend Information",
                               tags$div(
                                 tags$p(
                                   strong("Positive trend?"),
                                   " A positive trend means that increasing the number of sections is associated with higher average fill rates. More sections coincide with higher per-section enrollment relative to capacity, suggesting strong demand."
                                 ),
                                 tags$p(
                                   strong("Negative trend?"),
                                   " A negative trend means that as the number of sections increases, the average fill rate decreases. This indicates that adding sections dilutes enrollment because the total number of students does not increase proportionally."
                                 )
                               ),
                               style = "primary"
               ),
               
               plotOutput("sectionVsFillPlot", height = "500px")
             )
    ),
    ##
    tabPanel("Variable Definitions & App Info",
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
             ),
             #
             bsCollapsePanel("Click here for more information about each tab",
                             tags$div(
                               tags$p(
                                 strong("Overview:"),
                                 "Displays a detailed table of GE course information and provides filtering inputs (e.g., Term, GE requirement, College, Subject, and fill rate range) in a sidebar. If GE requirements are selected, a bar chart summarizing subjects for the selected GE requirements is displayed."
                               ),
                               tags$p(
                                 strong("High and Low Fill Rate Courses:"),
                                 "Lets you set a fill rate threshold, and displays a table listing courses with an average fill rate above (or below if Low Fill Rate Courses tab) the threshold."
                               ),
                               tags$p(
                               strong("Pairwise Correlation by GE Area:"),
                               "Presents an analysis of pairwise correlations between GE areas by division-level grouping (Lower-Division GE and Upper-Division GE) across all terms. This tab includes an expandable section explaining what positive and negative correlations may indicate, and the results are displayed in a data table."
                               ),
                               tags$p(
                               strong("GE Area Correlation Heatmap:"),
                               "Shows a heatmap visualization of the sample correlation matrix for GE area fill rates across all terms."
                               ),
                               tags$p(
                              strong("Number of Sections Per Course: A What-If Analysis:"),
                                 "Allows you to assess changes by selecting a specific course and modifying its section count (and optionally, total enrollment). It then displays the recalculated average enrollment and fill rate based on the new section count (and, if provided, total enrollment)."
                                ),
                              tags$p(
                               strong("Number of Sections Per GE Area: A What-If Analysis:"),
                                  "Allows you to assess changes for an entire GE area by selecting the GE area and modifying the total section count (and optionally, total enrollment). It then displays the recalculated average enrollment and fill rate for the selected GE area."
                               ),
                              tags$p(
                                strong("Section Count vs. Fill Rate:"),
                                  "Visualizes the relationship between the number of sections per course and the average fill rate. A scatter plot with a regression trend line is provided, along with explanatory information about positive and negative trends."
                               )
                              ),
                             style = "primary"
                       )
             
    )
  )
)