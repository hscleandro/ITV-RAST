# ddPCR R package - Dean Attali 2015
# This file contains various UI helper functions for the shiny app

# Create a little question mark link that shows a help popup on hover
helpPopup <- function(content, title = NULL) {
  a(href = "#",
    class = "popover-link",
    `data-toggle` = "popover",
    `data-title` = title,
    `data-content` = content,
    `data-html` = "true",
    `data-trigger` = "hover",
    icon("question-circle")
  )
}

# Set up a button to have an animated loading indicator and a checkmark
# for better user experience
# Need to use with the corresponding `withBusyIndicator` server function
withBusyIndicator <- function(button) {
  id <- button[['attribs']][['id']]
  tagList(
    button,
    span(
      class = "btn-loading-container",
      `data-for-btn` = id,
      hidden(
        img(src = "ajax-loader-bar.gif", class = "btn-loading-indicator"),
        icon("check", class = "btn-done-indicator")
      )
    )
  )
}

# Clours to let user select from in various inputs fields
allCols <- sort(c(
  "black", "blue", "green" = "green3", "purple" = "purple3", "orange", "darkgreen",
  "pink", "red", "yellow", "brown", "gold", "gray" = "gray7", "cyan", "white"
))
allColsDefault <- c("Default", allCols)