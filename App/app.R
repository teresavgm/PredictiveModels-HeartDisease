library(shiny)
library(bslib)
library(fontawesome)
library(nnet)

# Cargar modelo nnet
modelo_nnet <- readRDS("modelo_nnet_final.rds")

# Valores de escalado
escalado <- list(
  edad = c(media = 53.7, sd = 8.96),
  presion_reposo = c(media = 132, sd = 17.3),
  colesterol = c(media = 243, sd = 45.5),
  frec_max = c(media = 143, sd = 24.4),
  descenso_st = c(media = 0.92, sd = 1.04)
)

# Tema personalizado
tema_cardio <- bs_theme(
  version = 5,
  bootswatch = "cosmo",
  primary = "#c82333",
  base_font = font_google("Lato"),
  heading_font = font_google("Lato"),
  bg = "#f8f9fa",
  fg = "#212529"
)

ui <- fluidPage(
  theme = tema_cardio,
  tags$head(
    tags$style(HTML("
      h1, h4, label { color: #c82333; }
      .card-header { background-color: #c82333; color: white; font-weight: bold; }
      .card-body { background-color: #ffffff; }
      .form-group { margin-bottom: 15px; }
      hr { border-top: 1px solid #ccc; }
    "))
  ),
  
  titlePanel(div(icon("heartbeat"), "Predicción de Enfermedad Cardíaca")),
  br(),
  
  fluidRow(
    column(6,
           card(
             card_header("🧍 Datos del Usuario"),
             card_body(
               fluidRow(
                 column(6, numericInput("edad", "Edad", 50, min = 10, max = 100)),
                 column(6, selectInput("sexo", "Sexo", choices = c("Hombre", "Mujer"))),
                 column(6, selectInput("tipo_dolor_pecho", "Tipo Dolor de Pecho", choices = c("0", "1", "2", "3", "4"))),
                 column(6, numericInput("presion_reposo", "Presión en Reposo", 120)),
                 column(6, numericInput("colesterol", "Colesterol", 200)),
                 column(6, selectInput("glucosa_ayunas", "Glucosa en Ayunas >120", choices = c("NO", "SI"))),
                 column(6, selectInput("ecg_reposo", "ECG en Reposo", choices = c("0", "1", "2"))),
                 column(6, numericInput("frec_max", "Frecuencia Cardíaca Máxima", 150)),
                 column(6, selectInput("angina_ejercicio", "Angina inducida por ejercicio", choices = c("0", "1"))),
                 column(6, numericInput("descenso_st", "Descenso del ST", 1.0, step = 0.1)),
                 column(6, selectInput("pendiente_st", "Pendiente del ST", choices = c("Ascendente", "Descendente", "Plana")))
               )
             )
           )
    ),
    
    column(6,
           card(
             card_header("📊 Resultado de la Predicción"),
             card_body(
               uiOutput("resultado_prediccion"),
               br(),
               div(style = "text-align:center;",
                   actionButton("predecir", "🔍 Predecir Enfermedad", class = "btn btn-danger btn-lg")),
               tags$hr(),
               p("💡 Esta predicción se basa en un modelo de red neuronal entrenado con datos clínicos reales. 
            Los resultados son orientativos y deben ser interpretados con juicio clínico.",
                 style = "font-size: 14px; color: #555;")
             )
           )
    )
  ),
  br(), br()
)

server <- function(input, output, session) {
  
  escalar <- function(x, media, sd) {
    (x - media) / sd  
  }
  
  observeEvent(input$predecir, {
    
    datos_usuario <- data.frame(
      edad = escalar(input$edad, escalado$edad["media"], escalado$edad["sd"]),
      sexo = factor(input$sexo, levels = c("Hombre", "Mujer")),
      tipo_dolor_pecho = factor(input$tipo_dolor_pecho, levels = c("0", "1", "2", "3", "4")),
      presion_reposo = escalar(input$presion_reposo, escalado$presion_reposo["media"], escalado$presion_reposo["sd"]),
      colesterol = escalar(input$colesterol, escalado$colesterol["media"], escalado$colesterol["sd"]),
      glucosa_ayunas = factor(input$glucosa_ayunas, levels = c("NO", "SI")),
      ecg_reposo = factor(input$ecg_reposo, levels = c("0", "1", "2")),
      frec_max = escalar(input$frec_max, escalado$frec_max["media"], escalado$frec_max["sd"]),
      angina_ejercicio = factor(input$angina_ejercicio, levels = c("0", "1")),
      descenso_st = escalar(input$descenso_st, escalado$descenso_st["media"], escalado$descenso_st["sd"]),
      pendiente_st = factor(input$pendiente_st, levels = c("Ascendente", "Descendente", "Plana"))
    )
    
    # Convertir variables numéricas a matriz
    numericas <- c("edad", "presion_reposo", "colesterol", "frec_max", "descenso_st")
    for (var in numericas) {
      datos_usuario[[var]] <- as.matrix(datos_usuario[[var]])
    }
    
    # Verificar que no haya NA
    if (any(sapply(datos_usuario, function(x) any(is.na(x))))) {
      output$resultado_prediccion <- renderUI({
        HTML("<p style='color:red;'>⚠️ Por favor, completa todos los campos correctamente.</p>")
      })
      return()
    }
    
    # Asegurar el orden de las columnas
    columnas_orden <- c("edad", "sexo", "tipo_dolor_pecho", "presion_reposo", "colesterol",
                        "glucosa_ayunas", "ecg_reposo", "frec_max", "angina_ejercicio",
                        "descenso_st", "pendiente_st")
    datos_usuario <- datos_usuario[, columnas_orden]
    
    prob <- predict(modelo_nnet, newdata = datos_usuario, type = "raw")[1]
    
    resultado <- ifelse(prob >= 0.5,
                        "<span style='color:red;'><b>❌ Riesgo Alto</b> de enfermedad cardíaca.</span>",
                        "<span style='color:green;'><b>✅ Riesgo Bajo</b> de enfermedad cardíaca.</span>")
    
    output$resultado_prediccion <- renderUI({
      HTML(paste0(
        "<h4><b>Probabilidad de enfermedad:</b> ", round(prob, 4), "</h4>",
        "<p style='font-size:18px;'>", resultado, "</p>"
      ))
    })
  })
}

shinyApp(ui, server)
