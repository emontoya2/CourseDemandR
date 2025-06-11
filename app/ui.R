# Define UI for application
ui <- fluidPage(
  useShinyjs(),

  # App Title
  titlePanel("A Data-Driven Tool for General Education Enrollment: Statistical Analysis & Scenario Planning"),

  # Main Tabset Panel containing all tabs
  tabsetPanel(

    # Overview Tab
    tabPanel(
      "Overview",
      sidebarLayout(
        sidebarPanel(

          # Option to upload CSV file.
          fileInput(
            inputId = "file1",
            label   = "Upload your GE data (CSV)",
            accept  = c(".csv")
          ),
          helpText("If no file is uploaded, the app will use the built-in dataset."),


          # Container for resettable input elements
           div(
            id = "resettableInputs",
            selectInput(
              inputId = "Term",
              label = "Select Term(s):",
              choices = unique(combinedData$Term),
              selected = tail(unique(combinedData$Term), 1),
              multiple = TRUE
            ),
            selectInput(
              inputId = "GEreq",
              label = "Select GE Requirement:",
              choices = NULL,
              selected = NULL,
              multiple = TRUE
            ),
            selectInput(
              inputId = "College",
              label = "Select College:",
              choices = NULL,
              selected = NULL,
              multiple = TRUE
            ),
            selectInput(
              inputId = "Subject",
              label = "Select Subject:",
              choices = NULL,
              selected = NULL,
              multiple = TRUE
            ),
            sliderInput(
              inputId = "rateA",
              label = "Average fill rate:",
              min = 0,
              max = 1,
              value = c(0, 1),
              step = 0.01
            )
          ),
          # Reset button for the app
          actionButton(inputId = "resetBtn", label = "Reset App"),
          width = 2 # Narrow sidebar for better layout
        ),
        mainPanel(
          # Show GE Requirement Summary if a GE requirement is selected
          conditionalPanel(
            condition = "input.GEreq != null && input.GEreq.length > 0",
            h3("GE Requirement Summary"),
            plotOutput(outputId = "gePlot",  height   = "250px"   # <-- you choose px, %, em, etc.
                       )
          ),
          h3("GE Courses"),
          DT::dataTableOutput(outputId = "courseTable"),
          
          tags$hr(),    # Separate the “table” from the collapsible info
          #tags$br(),
          
          # Variable Definitions (collapsible)
          bsCollapse(
            id = "collapseDefinitions",
            open = NULL,       # start collapse layout
            bsCollapsePanel(
              title = "Definitions of Variables Displayed in the App",
              tags$ul(
                tags$li(strong("Term:"), " Semester Term."),
                tags$li(strong("College:"), "The college within the institution."),
                tags$li(strong("Course:"), "Subject and catalog number."),
                tags$li(strong("Req_1:"), "GE requirement fulfilled by the course."),
                tags$li(strong("Req_2:"), "Second GE requirement fulfilled by the course."),
                tags$li(strong("Avg_fill_rate:"), "The ratio of average enrollment to the course capacity based on GE course caps."),
                tags$li(strong("GEcapsize:"), "GE course caps."),
                tags$li(strong("Avg_cap_diff:"), "The average difference between GE course caps and department-set course caps."),
                tags$li(strong("Avg_enrl:"), "The average enrollment across all sections of the course."),
                tags$li(strong("Crs_section_cnt:"), "The total number of sections offered for the course."),
                tags$li(strong("GE_course_level:"), "Course level of a GE or graduation requirement course."),
                tags$li(strong("GE_avg_fill:"), "Average fill rate of all courses in the same GE area during the same term."),
                tags$li(strong("Rel_GE_fill_rate:"), "The ratio of a given GE course's average fill rate to the average fill rate of all courses in the same GE area during the same term."),
                tags$li(strong("Note regarding Req_1 and Req_2:"), "FS-CT, FS-OC, FS-QR, and FS-WC represent foundational skills lower-division GE courses in Critical Thinking, Oral Communication, Quantitative Reasoning, and Written Communication, respectively. LD-ARTS, LD-HUM, LD-ES, LD-SBS, LD-LIFE_SCI, and LD-PHYS_SCI represent lower-division GE courses in Arts, Humanities, Ethnic Studies, Social and Behavioral Sciences, Life Sciences, and Physical Sciences, respectively. GV-Req and HIST-Req represent lower-division graduation requirements in Government and History, respectively. DIV-Req and WRIT-Req represent upper-division graduation requirements in Diversity and Writing, respectively.")
                
                ),
              style = "primary"
            )
          ),
          
          #tags$br(),  
          
          # More Information About Each Tab  (collapsible)
          bsCollapse(
            id = "collapseMoreInfo",
            open = NULL,        
            bsCollapsePanel(
              title = "More Information About Each Tab",
              tags$div(
                tags$p(
                  strong("Overview:"), " Detailed GE course information with filtering options and summary visualizations."
                ),
                tags$p(
                  strong("High and Low Fill-Rate Courses:"), " Displays courses filtered by fill rate thresholds."
                ),
                tags$p(
                  strong("Section Count vs. Fill Rate:"), " Illustrates the trend between the number of course sections and the average fill rate."
                ),
                tags$p(
                  strong("Pairwise Correlation by GE Area:"), " Analyzes and tabulates correlations between different GE areas."
                ),
                tags$p(
                  strong("GE Area Correlation Heatmap:"), " Visualizes the correlation matrix of GE area fill rates."
                ),
                tags$p(
                  strong("What-If Analysis:"), " Allows scenario planning by modifying section counts and enrollments at course and GE area levels."
                ),
                tags$p(
                  strong("Fill Rates Over Time:"), " Illustrates fill rates over time based on the selected course(s) or GE area(s)."
                )
              ),
              style = "primary"
            )
          )
        )
      )
    ),



    
    # Low Fill Rate Courses Tab
    tabPanel(
      "Low Fill Rate Courses",
      fluidPage(
        numericInput(
          inputId = "lowFillThreshold",
          label = "Fill Rate Threshold:",
          value = 0.25,
          min = 0,
          max = 1,
          step = 0.01
        ),
        h3("Courses with Average Rate below Threshold"),
        DT::dataTableOutput(outputId = "lowFillTable")
      )
    ),
    
    # High Fill Rate Courses Tab
    tabPanel(
      "High Fill Rate Courses",
      fluidPage(
        numericInput(
          inputId = "highFillThreshold",
          label = "Fill Rate Threshold:",
          value = 0.90,
          min = 0,
          max = 1,
          step = 0.01
        ),
        h3("Courses with Average Rate above Threshold"),
        DT::dataTableOutput(outputId = "highFillTable")
      )
    ),
    
    
    # fill rate tabs
    #tabPanel(
    #  "High and Low Fill-Rate Courses",
    #  fluidPage(
    #    # Low Fill-Rate Courses (appear at top)
    #    fluidRow(
    #      column(
    #        width = 12,           
    #        numericInput(
    #          inputId = "lowFillThreshold",
    #          label   = "Low Fill Rate Threshold:",
    #          value   = 0.25,
    #          min     = 0,
    #          max     = 1,
    #          step    = 0.01
    #        ),
    #        h3("Courses ≤ Threshold"),
    #        DT::dataTableOutput(outputId = "lowFillTable")
    #      )
    #    ),
    #    
    #    tags$br(),   
    #    
    #    # High Fill-Rate Courses 
    #    fluidRow(
    #      column(
    #        width = 12,          
    #        numericInput(
    #          inputId = "highFillThreshold",
    #          label   = "High Fill Rate Threshold:",
    #          value   = 0.90,
    #          min     = 0,
    #          max     = 1,
    #          step    = 0.01
    #        ),
    #        h3("Courses ≥ Threshold"),
    #        DT::dataTableOutput(outputId = "highFillTable")
    #      )
    #    )
    #  )
    #),
 
    
    # Section Count vs. Fill Rate Tab
    tabPanel(
      "Section Count vs. Fill Rate",
      fluidPage(
        h3("Relationship Between Number of Sections and Fill Rate"),
        bsCollapsePanel(
          title = "Trend Information",
          tags$div(
            tags$p(
              strong("Positive linear trend?"),
              " Increasing the number of sections may lead to higher average fill rates, suggesting strong demand."
            ),
            tags$p(
              strong("Negative linear trend?"),
              " Conversely, more sections could dilute enrollment, resulting in a lower fill rate if total enrollment doesn’t scale proportionately."
            ),
            tags$p(
              strong("Note: "),
              "Course popularity (or lack thereof) may hinge on factors other than capacity: time-of-day preferences, instructor assignments, or prerequisite structures."
            )
          ),
          style = "primary"
        ),
        plotOutput(outputId = "sectionVsFillPlot", height = "500px")
      )
    ),
    
    # Pairwise Correlation by GE Area Tab
    tabPanel(
      "Pairwise Correlation by GE Area",
      fluidPage(
        h3("Pairwise GE Correlation Analysis for Foundational Skills, Lower-Division GE, and Upper-Division GE -- across all Terms"),
        bsCollapsePanel(
          title = "Understanding GE Area Correlations",
          tags$div(
            tags$p(
              strong("Positive correlation:"),
              " When two GE areas have a high positive correlation in fill rates, their enrollment patterns tend to move together. This may be due to interconnected factors such as curriculum design, advising practices, and capacity constraints."
            ),
            tags$p(
              strong("Negative correlation:"),
              " An inverse relationship indicates that as one GE area's enrollment increases, another’s decreases—possibly due to scheduling conflicts or differences in student perceptions."
            )
          ),
          style = "primary"
        ),
        DT::dataTableOutput(outputId = "pairwiseTable")
      )
    ),

    # GE Area Correlation Heatmap Tab
    tabPanel(
      "GE Area Correlation Heatmap",
      fluidPage(
        h3("Correlation of GE Area Fill Rates -- across all Terms"),
        plotOutput(outputId = "correlationHeatmap", height = "700px")
      )
    ),

    

    # What-If Analysis: Number of Sections Per Course or by GE Area
    tabPanel(
      "What-If Analysis",
      fluidPage(
        # Course-Level What-If
        fluidRow(
          column(
            width = 4,
            selectInput(
              inputId = "simCourse",
              label   = "Select Course for What-If Analysis:",
              choices = sort(unique(combinedData$Course))
            )
          ),
          column(
            width = 4,
            numericInput(
              inputId = "newSectionCount",
              label   = "New Section Count for course:",
              value   = 10,
              min     = 1,
              step    = 1
            )
          ),
          column(
            width = 4,
            numericInput(
              inputId = "newTotalEnrollment",
              label   = "New Total Enrollment (optional):",
              value   = NA,
              min     = 1,
              step    = 1
            )
          )
        ),
        
        # Vertical spacing before results
        #fluidRow(column(12, tags$br(), tags$br())),
        
        fluidRow(
          column(
            width = 12,
            h3("Course-Level What-If Results (Most Recent Term)"),
            DT::dataTableOutput(outputId = "simTable")
          )
        ),
        
        tags$hr(),  # Separators
        tags$hr(),   
        tags$hr(),   
        
        #  GE Area-Level What-If
        fluidRow(
          column(
            width = 4,
            selectInput(
              inputId = "simGEarea",
              label   = "Select GE Area for What-If Analysis:",
              choices = sort(unique(c(combinedData$Req_1, combinedData$Req_2)))
            )
          ),
          column(
            width = 4,
            numericInput(
              inputId = "newGESectionCount",
              label   = "New Total Section Count for GE Area:",
              value   = 10,
              min     = 1,
              step    = 1
            )
          ),
          column(
            width = 4,
            numericInput(
              inputId = "newGEEnrollment",
              label   = "New Total Enrollment (optional):",
              value   = NA,
              min     = 1,
              step    = 1
            )
          )
        ),
        
        # Vertical spacing before results
        #fluidRow(column(12, tags$br(), tags$br())),
        
        fluidRow(
          column(
            width = 12,
            h3("GE Area-Level What-If Results (Most Recent Term)"),
            DT::dataTableOutput(outputId = "simGETable")
          )
        )
      )
    ),




    # Fill Rates Over Time by course(s) or GE area(s)
    tabPanel(
      "Fill Rates Over Time",
      fluidPage(

        # GE‐Area scatterplot
        fluidRow(
          column(
            width = 4,
            selectInput(
              inputId  = "timeReqs",
              label    = "Select GE Requirement(s):",
              choices  = NULL,    
              multiple = TRUE
            ),
            helpText("Pick one or more GE areas to see fill‐rate trends over time.")
          ),
          column(
            width = 8,
            plotOutput(
              outputId = "fillRateReqPlot",
              height   = "400px"
            )
          )
        ),
        
        tags$hr(),  # Separate sections
        
        # Course‐level scatterplot
        fluidRow(
          column(
            width = 4,
            selectInput(
              inputId  = "timeCourses",
              label    = "Select Course(s):",
              choices  = NULL,    
              multiple = TRUE
            ),
            helpText("Pick one or more courses to see their fill‐rate over time.")
          ),
          column(
            width = 8,
            plotOutput(
              outputId = "fillRateTimePlot",
              height   = "400px"
            )
          )
        )
      )
    ) 

 
  )
)
