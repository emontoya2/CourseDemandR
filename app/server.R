server <- function(input, output, session) {
  
  # Read user file or fallback
  dataSource <- reactive({
    if (is.null(input$file1)) {
      combinedData
    } else {
      # read.csv will infer factors; adjust as needed
      read.csv(input$file1$datapath, stringsAsFactors = FALSE)
    }
  })
  
  
  # Reactive Data Subset Based on Selected Terms
  #coursesData <- reactive({
  #     req(input$Term)
  #     dataSource() %>% filter(Term %in% input$Term) %>%
  #  mutate(Subject = sub("-.*", "", Course))
  #})
  
  coursesData <- reactive({
    req(input$Term)
    dataSource() %>%                                            #  uploaded or-default data
      filter(Term %in% input$Term) %>%
      mutate(Subject = sub("-.*", "", Course))
  })
  
  
  # Update UI Inputs When 'Term' Changes
  observe({
    df <- coursesData()
    
    # Update selectInput choices dynamically
    updateSelectInput(session, "GEreq", choices = sort(unique(df$Req_1)))
    updateSelectInput(session, "College", choices = sort(unique(df$College)))
    updateSelectInput(session, "Subject", choices = sort(unique(df$Subject)))
    

    #populate simGEarea from uploaded  
    updateSelectInput(
      session, "simGEarea",
      choices = sort(unique(c(df$Req_1, df$Req_2))),
      selected = character(0)
    )
    
    # Update slider maximum for Average Fill Rate based on current data
    maxAvg <- round(max(df$Avg_fill_rate, na.rm = TRUE), 2)
    updateSliderInput(session, "rateA", max = maxAvg, value = c(0, maxAvg))

    
  })
  
  # Filter Data According to Multiple User Inputs
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
    
    df %>% filter(
      Avg_fill_rate >= input$rateA[1],
      Avg_fill_rate <= input$rateA[2]
    )
  })
  
  # GE Requirement Summary Bar Plot (by Subject)
  output$gePlot <- renderPlot({
    req(input$GEreq)
    
    summaryData <- filteredData() %>%
      group_by(Subject) %>%
      summarise(count = sum(Crs_section_cnt, na.rm = TRUE))
    
    ggplot(summaryData, aes(x = Subject, y = count, fill = Subject)) +
      geom_bar(stat = "identity") +
      labs(
        title = "Count of Subjects for Selected GE Requirement(s)",
        x = "Subject", y = "Count"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
        legend.text = element_text(size = 14)
      )
  })
  
  # GE Courses Data Table
  output$courseTable <- DT::renderDataTable({
    DT::datatable(
      filteredData()[, c(
        "Term", "College", "Course", "Req_1", "Req_2", "Avg_fill_rate", 
        "GEcapsize", "Avg_cap_diff", "Avg_enrl", "Crs_section_cnt", 
        "GE_course_level", "GE_avg_fill", "Rel_GE_fill_rate")],
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE
    )
  })
  
  # High Fill Rate Courses Table
  output$highFillTable <- DT::renderDataTable({
    df <- filteredData() %>% filter(Avg_fill_rate > input$highFillThreshold)
    DT::datatable(
      df[, c(
        "Term", "College", "Course", "Req_1", "Req_2", "Avg_fill_rate", 
        "GEcapsize", "Avg_cap_diff", "Avg_enrl", "Crs_section_cnt", "Rel_GE_fill_rate")],
      filter = "top",
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE
    )
  })
  
  # Low Fill Rate Courses Table
  output$lowFillTable <- DT::renderDataTable({
    df <- filteredData() %>% filter(Avg_fill_rate < input$lowFillThreshold)
    DT::datatable(
      df[, c(
        "Term", "College", "Course", "Req_1", "Req_2", "Avg_fill_rate", 
        "GEcapsize", "Avg_cap_diff", "Avg_enrl", "Crs_section_cnt", "Rel_GE_fill_rate")],
      filter = "top",
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE
    )
  })
  

  # Pairwise GE Correlation Analysis
  pairwiseResultsAll <- reactive({
    
     
    # Function to analyze correlations within a group of GE areas
    analyzeGroup <- function(areas, groupName) {
      df_sub <- dataSource() %>%filter(Req_1 %in% areas) %>% droplevels() ##
      
      #browser()          # debug
      
      df_summary <- df_sub %>%
        group_by(Term, Req_1) %>%
        summarise(Avg_fill_rate = mean(Avg_fill_rate, na.rm = TRUE), .groups = "drop") %>%
        pivot_wider(names_from = Req_1, values_from = Avg_fill_rate)
      
      # Exclude Term column for regression analysis
      ge_areas <- names(df_summary)[-1]
      regression_results <- list()
      
      # Loop through pairs of GE areas to compute regression-based correlation
      for (i in 1:(length(ge_areas) - 1)) {
        for (j in (i + 1):length(ge_areas)) {
          x <- ge_areas[i]
          y <- ge_areas[j]
          model <- lm(df_summary[[y]] ~ df_summary[[x]])
          model_summary <- broom::tidy(model)
          r_squared <- summary(model)$r.squared
          r_val <- sqrt(r_squared) * sign(model_summary$estimate[2])
          
          regression_results[[paste(x, "->", y, sep = "_")]] <- data.frame(
            GE_area1 = x,
            GE_area2 = y,
            P_Value = model_summary$p.value[2],
            Correlation = r_val
          )
        }
      }
      bind_rows(regression_results)
    }
    
    # Define GE areas for lower and upper divisions based on GE_course_level
    LD <- dataSource() %>% filter(GE_course_level == "LD") %>% pull(Req_1) %>% unique() ##
    UD <- dataSource() %>% filter(GE_course_level == "UD") %>% pull(Req_1) %>% unique() ##
    
    ld_results <- analyzeGroup(LD, "LD")
    ud_results <- analyzeGroup(UD, "UD")
    
    bind_rows(ld_results, ud_results) %>%
      filter(P_Value <= 0.15) %>%
      arrange(desc(abs(Correlation))) %>%
      select(GE_area1, GE_area2, P_Value, Correlation) %>%
      mutate_if(is.numeric, ~ round(.x, 2))
  })
  
  # Render the Pairwise Correlation Results Table
  output$pairwiseTable <- DT::renderDataTable({
    DT::datatable(
      pairwiseResultsAll(),
      filter = "top",
      options = list(pageLength = 10, autoWidth = TRUE)
    )
  })
  

  # GE Area Correlation Heatmap
  output$correlationHeatmap <- renderPlot({
    # Step 1: Summarize average fill rates per GE area per Term
    df_wide <- dataSource() %>%
      filter(!is.na(Req_1)) %>%
      group_by(Term, Req_1) %>%
      summarise(Avg_fill_rate = mean(Avg_fill_rate, na.rm = TRUE), .groups = "drop") %>%
      pivot_wider(names_from = Req_1, values_from = Avg_fill_rate)
    
    # Step 2: Compute correlation matrix (excluding Term column)
    cor_mat <- cor(df_wide %>% select(-Term), use = "pairwise.complete.obs", method = "pearson")
    
    # Step 3: Melt correlation matrix for plotting
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
      labs(
        title = "GE Area Fill Rate Correlation Matrix Across Terms",
        x = NULL,
        y = NULL
      )
  })
  
  # What-If Analysis: Course-Level Simulation
  simulatedData <- reactive({
    req(input$simCourse, input$newSectionCount)
    
    df <- coursesData()
    # Identify the latest term among selected terms
    latestTerm <- sort(unique(df$Term), decreasing = TRUE)[1]
    
    course <- df %>% filter(Term == latestTerm, Course == input$simCourse) %>% slice(1)
    
    if (nrow(course) == 0) {
      return(data.frame(Message = "Selected course not found in the selected Term(s)."))
    }
    
    # Compute original total enrollment (Avg_enrl * Section Count)
    orig_total_enrl <- course$Avg_enrl * course$Crs_section_cnt
    
    # Use user-provided enrollment if available; else default to original enrollment
    total_enrl <- if (!is.na(input$newTotalEnrollment) && input$newTotalEnrollment > 0) {
      input$newTotalEnrollment
    } else {
      orig_total_enrl
    }
    
    # Calculate new average enrollment and fill rate based on new section count
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
  
  # Render the Course-Level What-If Analysis Table
  output$simTable <- DT::renderDataTable({
    DT::datatable(
      simulatedData(),
      options = list(pageLength = 5, autoWidth = TRUE),
      rownames = FALSE
    )
  })
  
  # What-If Analysis: GE Area-Level Simulation
  simGEData <- reactive({
    req(input$simGEarea, input$newGESectionCount)
    
    geCourses <- coursesData() %>% 
      filter(Req_1 == input$simGEarea | Req_2 == input$simGEarea)
    
    # Determine the latest term among selected terms
    latestTerm <- sort(unique(coursesData()$Term), decreasing = TRUE)[1]
    geCourses <- geCourses %>% filter(Term == latestTerm)
    
    if (nrow(geCourses) == 0) {
      return(data.frame(Message = "No courses found for this GE area."))
    }
    
    # Calculate original total enrollment for the GE area
    total_enrl_original <- round(sum(geCourses$Avg_enrl * geCourses$Crs_section_cnt, na.rm = TRUE))
    
    total_enrl <- if (!is.na(input$newGEEnrollment) && input$newGEEnrollment > 0) {
      input$newGEEnrollment
    } else {
      total_enrl_original
    }
    
    original_total_sections <- sum(geCourses$Crs_section_cnt, na.rm = TRUE)
    weighted_GE_cap <- sum(geCourses$GEcapsize * geCourses$Crs_section_cnt, na.rm = TRUE) / original_total_sections
    
    original_avg_enrl_per_section <- total_enrl_original / original_total_sections
    original_fill_rate <- original_avg_enrl_per_section / weighted_GE_cap
    
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
  
  # Render the GE Area-Level What-If Analysis Table
  output$simGETable <- DT::renderDataTable({
    DT::datatable(
      simGEData(),
      options = list(pageLength = 5, autoWidth = TRUE),
      rownames = FALSE
    )
  })
  
  # Plot: Section Count vs. Average Fill Rate by Course
  output$sectionVsFillPlot <- renderPlot({
    df <- filteredData()
    
    # Aggregate data to course level to summarize fill rates and section counts
    course_summary <- df %>%
      group_by(Course) %>%
      summarise(
        Avg_fill_rate = mean(Avg_fill_rate, na.rm = TRUE),
        Total_sections = sum(Crs_section_cnt, na.rm = TRUE),
        .groups = "drop"
      )
    
    ggplot(course_summary, aes(x = Total_sections, y = Avg_fill_rate)) +
      geom_point(alpha = 0.7, size = 3) +
      geom_text_repel(aes(label = Course), size = 4) +
      geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "darkred") +
      labs(
        x = "Number of Sections",
        y = "Average Fill Rate",
        title = "Section Count vs. Average Fill Rate by Course"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12)
      )
  })
  
  
  
  # Populate course selector from the full dataset, not just filtered by Term
  observe({
    df_all <- dataSource()
    updateSelectInput(
      session, "timeCourses",
      choices  = sort(unique(df_all$Course)),
      selected = NULL
    )
  })

  output$fillRateTimePlot <- renderPlot({
    req(input$timeCourses)
    
    #  Pull in all terms
    df_plot <- dataSource() %>%
      filter(Course %in% input$timeCourses) %>%
      group_by(Term, Course) %>%
      summarise(
        Avg_fill_rate = mean(Avg_fill_rate, na.rm = TRUE),
        .groups       = "drop"
      ) %>%
      #  Parse out a numeric “year” and a season order (Spring = 1, Fall = 2)
      mutate(
        Year        = as.integer(paste0("20", substr(Term, 2, 3))),
        SeasonOrder = ifelse(substr(Term, 1, 1) == "S", 1, 2)
      )
    
    # Use correct time ordered levels
    term_levels <- df_plot %>%
      distinct(Term, Year, SeasonOrder) %>%
      arrange(Year, SeasonOrder) %>%
      pull(Term)
    
    df_plot$Term <- factor(df_plot$Term, levels = term_levels)
    
    # Plot with both points and connecting lines
    ggplot(df_plot, aes(x = Term, y = Avg_fill_rate,
                        color = Course, group = Course)) +
      geom_line() +                                       
      geom_point(size = 3) +
      labs(
        title = "Course Fill Rate Over Time",
        x     = "Term",
        y     = "Average Fill Rate"
      ) +
      theme_minimal() +
      theme(
        axis.text.x     = element_text(angle = 45, hjust = 1, size=12),
        axis.text.y  = element_text(size = 12),    
        legend.title    = element_blank(),
        legend.text     = element_text(size = 12)      
      )
  })
  
  
  # Populate the GE-area selector across all terms
  observe({
    df_all <- dataSource()
    updateSelectInput(
      session, "timeReqs",
      choices  = sort(unique(df_all$Req_1)),
      selected = NULL
    )
  })
  
  # create scatterplot of rate vs time
  output$fillRateReqPlot <- renderPlot({
    req(input$timeReqs)
    
    # filter full data by chosen GE areas
    df_plot <- dataSource() %>%
      filter(Req_1 %in% input$timeReqs) %>%
      group_by(Term, Req_1) %>%
      summarise(
        Avg_fill_rate = mean(Avg_fill_rate, na.rm = TRUE),
        .groups       = "drop"
      ) %>%
      # 2) extract Year & season order for true chronology
      mutate(
        Year        = as.integer(paste0("20", substr(Term, 2, 3))),
        SeasonOrder = ifelse(substr(Term, 1, 1) == "S", 1, 2)
      )
    
    # build factor levels: F22, S23, F23, S24, etc.
    term_levels <- df_plot %>%
      distinct(Term, Year, SeasonOrder) %>%
      arrange(Year, SeasonOrder) %>%   
      pull(Term)
    
    df_plot$Term <- factor(df_plot$Term, levels = term_levels)
    
    # plot with lines + points
    ggplot(df_plot, aes(
      x     = Term,
      y     = Avg_fill_rate,
      color = Req_1,
      group = Req_1
    )) +
      geom_line() +                      
      geom_point(size = 3) +
      labs(
        title = "Fill Rate Over Time by GE Requirement",
        x     = "Term",
        y     = "Average Fill Rate"
      ) +
      theme_minimal() +
      theme(
        axis.text.x     = element_text(angle = 45, hjust = 1, size=12),
        axis.text.y  = element_text(size = 12),    
        legend.title    = element_blank(),
        legend.text     = element_text(size = 12)      
      )
  })
  
  
  # Reset Inputs When Reset Button is Pressed
  observeEvent(input$resetBtn, {
    reset("resettableInputs")
  })
}
