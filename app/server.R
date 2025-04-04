LD <- c("FS-OC", "FS-WC", "FS-CT", "FS-QR", "HIST-Req", "GV-Req", "LD-PHYS_SCI", "LD-BIO_SCI", "LD-ARTS", "LD-HUM", "LD-SBS", "LD-ES")  # lower division GE
UD <- c("WRIT-Req", "DIV-Req", "UD-SCI", "UD-A&H", "UD-SBS") # upper division GE

server <- function(input, output, session) {
  
  # Create reactive expression to filter the combined data based on `Term` selection (for plots or tables)
  coursesData <- reactive({
    req(input$Term)
    combinedData %>% filter(Term %in% input$Term)
  })
  
  
  # When 'Term' changes, update selectInputs and slider ranges.
  observe({
    df <- coursesData()
    updateSelectInput(session, "GEreq", choices = sort(unique(df$GEreq)))
    updateSelectInput(session, "College", choices = sort(unique(df$College)))
    updateSelectInput(session, "Subject", choices = sort(unique(df$Subject)))
    
    maxAvg <- round(max(df$Avg_fill_rate, na.rm = TRUE), 2)
    #maxMed <- round(max(df$Median_fill_rate, na.rm = TRUE), 2)
    updateSliderInput(session, "rateA", max = maxAvg, value = c(0, maxAvg))
    #updateSliderInput(session, "rateB", max = maxMed, value = c(0, maxMed))
  })
  
  # Create reactive expression to filter data based on user inputs
  filteredData <- reactive({
    df <- coursesData()
    if (!is.null(input$GEreq) && length(input$GEreq) > 0) {
      df <- df %>% filter(Req_1 %in% input$GEreq | Req_2 %in% input$GEreq)
    }
    if (!is.null(input$College) && length(input$College) > 0) {
      df <- df %>% filter(College %in% input$College)
    }
    if (!is.null(input$Subject) && length(input$Subject) > 0) {
      df <- df %>% filter(Subject %in% input$Subject)
    }
    df %>% filter(Avg_fill_rate >= input$rateA[1],
                  Avg_fill_rate <= input$rateA[2])#,
                  #Median_fill_rate >= input$rateB[1],
                  #Median_fill_rate <= input$rateB[2])
  })
  
  # Coure courses, create bar chart for GE Requirement based on filtered results
  # where the heights are the number of sections
  output$gePlot <- renderPlot({
    req(input$GEreq)
    summaryData <- filteredData() %>%
      group_by(Subject) %>%
      summarise(count = sum(Crs_section_cnt, na.rm = TRUE))
    
    ggplot(summaryData, aes(x = Subject, y = count, fill = Subject)) +
      geom_bar(stat = "identity") +
      labs(title = "Count of Subjects for Selected GE Requirement(s)",
           x = "Subject", y = "Count") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size=14), legend.text = element_text(size = 14))
  })
  
  # Course Table
  output$courseTable <- DT::renderDataTable({
    DT::datatable(
      filteredData()[, c("Term", "College", "Course", "Req_1", "Req_2", "Avg_fill_rate", 
                           "GEcapsize", "Avg_cap_diff", "Avg_enrl",  #"Median_fill_rate",
                          "Crs_section_cnt")], # "Med_enrl", 
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE
    )
  })
  
  # Box Plot: Average Fill Rate by College (all data from selected Term(s))
  # output$boxPlot <- renderPlot({
  #   df <- coursesData()
  #   ggplot(df, aes(x = College, y = Avg_fill_rate, fill = Term)) +
  #     geom_boxplot() +
  #     labs(title = "Box Plot: Average Fill Rate by College & Term",
  #          x = "College", y = "Average Fill Rate") +
  #     theme_minimal() +
  #     theme(axis.text.x = element_text(angle = 45, hjust = 1, size=14))
  # })
  
  # High Fill Rate Courses Table
  output$highFillTable <- DT::renderDataTable({
    df <- filteredData() %>% filter(Avg_fill_rate > input$highFillThreshold  )
    DT::datatable(
      df[, c("Term", "College", "Course", "Req_1", "Req_2", 
             "Avg_fill_rate",   "GEcapsize", #"Median_fill_rate",
             "Avg_cap_diff", "Avg_enrl",   "Crs_section_cnt")], #"Med_enrl",
      filter = "top",
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE
    )
  })
  
  # Low Fill Rate Courses Table
  output$lowFillTable <- DT::renderDataTable({
    df <- filteredData() %>% filter(Avg_fill_rate < input$lowFillThreshold )
    DT::datatable(
      df[, c("Term", "College", "Course", "Req_1", "Req_2", 
             "Avg_fill_rate",   "GEcapsize",  #"Median_fill_rate",
             "Avg_cap_diff", "Avg_enrl",   "Crs_section_cnt")], #"Med_enrl",
      filter = "top",
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE
    )
  })
  
  # Pairwise GE Correlation Analysis for GE groups
  pairwiseResultsAll <- reactive({
    # Define GE groups
    #fs <- c("A1", "A2", "A3", "B4")         # foundational skills
    #ld <- c("AIAH", "AIGV", "B1", "B2", "C1", "C2", "DSEM", "F")  # lower division GE
    #ud <- c("GWAR", "JYDR", "UDB", "UDC", "UDD") # upper division GE
    
    analyzeGroup <- function(areas, groupName) {
      df_sub <- combinedData %>% filter(Req_1 %in% areas) %>% droplevels()
      df_summary <- df_sub %>%
        group_by(Term, Req_1) %>%
        summarise(Avg_fill_rate = mean(Avg_fill_rate, na.rm = TRUE), .groups = "drop") %>%
        pivot_wider(names_from = Req_1, values_from = Avg_fill_rate)
      
      # Exclude the Term column for the regression analysis
      ge_areas <- names(df_summary)[-1]
      regression_results <- list()
      
      for (i in 1:(length(ge_areas) - 1)) {
        for (j in (i + 1):length(ge_areas)) {
          x <- ge_areas[i]
          y <- ge_areas[j]
          model <- lm(df_summary[[y]] ~ df_summary[[x]])
          model_summary <- broom::tidy(model)
          r_squared <- summary(model)$r.squared
          r_val <- sqrt(r_squared) * sign(model_summary$estimate[2])
          
          regression_results[[paste(x, "->", y, sep = "_")]] <- data.frame(
           #GE_level = groupName,
            GE_area1 = x,
            GE_area2 = y,
            P_Value = model_summary$p.value[2],
            Correlation = r_val
          )
        }
      }
      bind_rows(regression_results)
    }
    
    ld_results <- analyzeGroup(LD, "LD")
    ud_results <- analyzeGroup(UD, "UD")
    
    # Combine and filter results
    bind_rows(ld_results, ud_results) %>%
      filter(P_Value <= 0.15) %>%
      arrange(desc(abs(Correlation))) %>%
      select(GE_area1, GE_area2, P_Value, Correlation) %>%  
      mutate_if(is.numeric, ~ round(.x, 2))
  })
  
  output$pairwiseTable <- DT::renderDataTable({
    DT::datatable(pairwiseResultsAll(), 
          filter = "top",
          options = list(pageLength = 10, autoWidth = TRUE))
  })
  
  
  ## Heatmap -- fill rate corr matrix
  output$correlationHeatmap <- renderPlot({
    # Step 1: summarize fill rates per GE area per term
    df_wide <- combinedData %>%
      filter(!is.na(Req_1)) %>%
      group_by(Term, Req_1) %>%
      summarise(Avg_fill_rate = mean(Avg_fill_rate, na.rm = TRUE), .groups = "drop") %>%
      pivot_wider(names_from = Req_1, values_from = Avg_fill_rate)
    
    # Step 2: calculate correlation matrix
    cor_mat <- cor(df_wide %>% select(-Term), use = "pairwise.complete.obs", method = "pearson")
    
    # Step 3: plot as heatmap
    melted_cor <- reshape2::melt(cor_mat)
    
    ggplot(melted_cor, aes(Var1, Var2, fill = value)) +
      geom_tile(color = "white") +
      scale_fill_gradient2(
        low = "blue", high = "red", mid = "white",
        midpoint = 0, limit = c(-1, 1), space = "Lab",
        name = "Pearson\nCorrelation"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
        axis.text.y = element_text(size = 14)
      ) +
      labs(title = "GE Area Fill Rate Correlation Matrix Across Terms",
           x = NULL, y = NULL)
  })
  #
  
  # What-If Analysis section: Calculate  average enrollment and fill rate when section count changes
  simulatedData <- reactive({
    req(input$simCourse, input$newSectionCount)
    # Use coursesData() to filter only by Term
    df <- coursesData() 
   
    # Determine the latest term among the selected terms.
    # This assumes that the Term variable sorts such that the latest term is the highest.
    latestTerm <- sort(unique(df$Term), decreasing = TRUE)[1]
    
    # Filter the data to include only the latest term and the selected course
    course <- df %>% 
      filter(Term == latestTerm, Course == input$simCourse) %>% 
      slice(1)
    if(nrow(course) == 0) {
      return(data.frame(Message = "Selected course not found in the selected Term(s)."))
    }
    
    # Total enrollment based on current data
    orig_total_enrl <- course$Avg_enrl * course$Crs_section_cnt
 
    # Use the user provided new total enrollment if provided. Otherwise, keep the original total enrollment
    total_enrl <- if (!is.na(input$newTotalEnrollment) && input$newTotalEnrollment > 0) {
      input$newTotalEnrollment
    } else {
      orig_total_enrl
    }   
    
    #total_enrl <- course$Avg_enrl * course$Crs_section_cnt
    # Calculate new average enrollment and fill rate
    new_avg_enrl <- total_enrl / input$newSectionCount
    new_fill_rate <- new_avg_enrl / course$GEcapsize
    
    data.frame(
      Term = course$Term,
      Course = course$Course,
      Total_Enrollment = orig_total_enrl,
      Total_Sections = course$Crs_section_cnt,
      Avg_Enrl = course$Avg_enrl,
      Fill_Rate = course$Avg_fill_rate,
      New_Total_Enrollment = total_enrl,
      New_Section_Count = input$newSectionCount,
      New_Avg_Enrl = round(new_avg_enrl, 2),
      New_Fill_Rate = round(new_fill_rate, 2)
    )
  })
  
  
  # Render the What-If Analysis table  
  output$simTable <- DT::renderDataTable({
    DT::datatable(simulatedData(), options = list(pageLength = 5, autoWidth = TRUE), rownames = FALSE)
  })
  
  
  # What-If Analysis section: Calculate  average enrollment and fill rate when section count changes -- GE
  simGEData <- reactive({
    req(input$simGEarea, input$newGESectionCount)
    # Use coursesData() (with parentheses) to filter only by Term
    geCourses <- coursesData() %>% 
      filter(Req_1 == input$simGEarea | Req_2 == input$simGEarea)
    
    # Determine the latest term from the selected terms
    latestTerm <- sort(unique(coursesData()$Term), decreasing = TRUE)[1]
    
    # Filter geCourses to only include data from the latest term
    geCourses <- geCourses %>% filter(Term == latestTerm)
    
    if(nrow(geCourses) == 0) return(data.frame(Message = "No courses found for this GE area."))
    
    # Original total enrollment for the GE area
    total_enrl_original <- round(sum(geCourses$Avg_enrl * geCourses$Crs_section_cnt, na.rm = TRUE))

        # Use the user-provided new total enrollment if given. Otherwise, use the original total
    total_enrl <- if(!is.na(input$newGEEnrollment) && input$newGEEnrollment > 0) {
      input$newGEEnrollment
    } else {
      total_enrl_original
    }
    
    # Original total number of sections and weighted GE capacity
    original_total_sections <- sum(geCourses$Crs_section_cnt, na.rm = TRUE)
    weighted_GE_cap <- sum(geCourses$GEcapsize * geCourses$Crs_section_cnt, na.rm = TRUE) / original_total_sections
    
    
    #total_enrl <- sum(geCourses$Avg_enrl * geCourses$Crs_section_cnt, na.rm = TRUE)
    original_avg_enrl_per_section <- total_enrl_original / original_total_sections
    original_fill_rate <- original_avg_enrl_per_section / weighted_GE_cap
    

    # new rates based on new counts
    new_total_sections <- input$newGESectionCount
    simulated_avg_enrl_per_section <- total_enrl / new_total_sections
    simulated_fill_rate <- simulated_avg_enrl_per_section / weighted_GE_cap
    
    data.frame(
      Term = paste(unique(geCourses$Term), collapse = ", "),
      GE_Area = input$simGEarea,
      Total_Sections = original_total_sections,
      Total_Enrollment = total_enrl_original,
      Avg_Enrl = round(original_avg_enrl_per_section, 2),
      Fill_Rate = round(original_fill_rate, 2),
      New_Total_Enrollment = total_enrl,
      New_Total_Sections = new_total_sections,
      New_Avg_Enrl = round(simulated_avg_enrl_per_section, 2),
      New_Fill_Rate = round(simulated_fill_rate, 2)
    )
  })
  
  output$sectionVsFillPlot <- renderPlot({
    df <- filteredData()
    
    # Aggregate to course level (in case there are multiple entries per course-term)
    course_summary <- df %>%
      group_by(Course) %>%
      summarise(
        Avg_fill_rate = mean(Avg_fill_rate, na.rm = TRUE),
        Total_sections = sum(Crs_section_cnt, na.rm = TRUE),
        .groups = "drop"
      )
    
    ggplot(course_summary, aes(x = Total_sections, y = Avg_fill_rate)) +
      geom_point(alpha = 0.7, color = "#2c7fb8", size = 3) +
      geom_text_repel(aes(label = Course), size = 4) +
      geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "darkred") +
      labs(
        x = "Number of Sections",
        y = "Average Fill Rate",
        title = "Section Count vs. Average Fill Rate by Course"
      ) +
      theme(
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12)
      )+
      theme_minimal(base_size = 14)
  })
  
  
  
  # --- Render the simulation table ---
  output$simGETable <- DT::renderDataTable({
    DT::datatable(simGEData(), options = list(pageLength = 5, autoWidth = TRUE), rownames = FALSE)
  })
  
  # Reset inputs when reset button is pressed
  observeEvent(input$resetBtn, {
    reset("resettableInputs")
  })
}
