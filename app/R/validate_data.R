# Checks that the provided data frame matches expected variable names and numeric constraints.

validate_data <- function(df){

  args <- commandArgs(trailingOnly=TRUE)
  data_file <- if (length(args)==1) args else "data/GEsampledata.csv"
  
  log_file <- file.path(dirname(data_file),
            sub("\\.csv$", "validation_log.txt", basename(data_file)))
  message("Writing validation log to: ", log_file)
  
  tryCatch({
    # Required variable/column names
    expected_names <- c(
      "Term","College","Course","Catalog","Req_1","Req_2",
      "Avg_enrl","GEcapsize","Avg_capenrl","Crs_section_cnt"
    )
    
    # Ensure no NAs in required columns
    na_cols <- expected_names[sapply(expected_names, function(col) any(is.na(df[[col]])))]
    if (length(na_cols)) {
      stop("Columns with missing values: ", paste(na_cols, collapse = ", "))
    }
    
    # Specify which columns must be numeric and ≥ 0
    num_cols <- c(
      "Avg_enrl","GEcapsize","Avg_capenrl","Crs_section_cnt"
    )
    
    # Column names check but allow extra columns
    actual_names <- intersect(names(df), expected_names)
    if (!setequal(actual_names, expected_names)) {
      stop(
        "Column names mismatch.\n",
        "Expected: ", paste(expected_names, collapse = ", "), "\n",
        "Found:    ", paste(actual_names, collapse = ", ")
      )
    }
    
    # Numeric type & non-negative checks
    for (col in num_cols) {
      #if (!col %in% actual_names) next
      
      if (!is.numeric(df[[col]])) {
        stop("Column '", col, "' must be numeric. Found: ", class(df[[col]]))
      }
      if (any(df[[col]] < 0, na.rm = TRUE)) {
        stop("Column '", col, "' contains negative values.")
      }
    }
    
    # If we reach here, validation passed
    pass_msg <- "Validation passed: structure and numeric checks OK."
    writeLines(pass_msg, con = log_file)
    message(pass_msg)
    invisible(TRUE)
    
  }, error = function(err){
    fail_msg <- paste0("Validation failed: ", err$message)
    writeLines(fail_msg, con = log_file)
    stop(fail_msg)
  })
}
