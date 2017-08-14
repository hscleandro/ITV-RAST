tabPanel(
  title = "About",
  id    = "aboutTab",
  value = "aboutTab",
  name  = "aboutTab",
  class = "fade",
  icon  = icon("info-circle"),
  includeMarkdown(file.path("text", "about.md")), 
  h2("Version"),
  "version 1.0"
)
