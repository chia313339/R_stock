library(shiny)
library(quantmod)
library(zoo)
library(xts)
library(TTR)
library(plotly)


ui = tagList(
  
  navbarPage(
    # theme = "cerulean",  # <--- To use a theme, uncomment this
    "股價分析模型",
    tabPanel("股價評估",
             sidebarPanel(
               h4("參數設定"),
               textInput("stock_no", label ="輸入股價代號" , value = "0050.TW"),
               dateInput('end_time',
                         label = '歷史資料觀測時間',
                         value = Sys.Date()-3.5*365.25),
               helpText("提示1：可以進行台股、外匯及加權指數預測，台股為代碼加上.TW(如:0050.TW)，外匯請在外幣代號後加上=x(如:TWD=X)，台灣加權指數為^TWII。"),
               helpText("提示2：根據股價波動週期研究，約3.5年一個循環，故歷史觀測時間預設為3.5年，研究短線者可自行調整時間。"),
               hr(),
               h4("參數微調"),
               numericInput("prob1", "1倍標準差占比，預設為常態分配68.26%", 68.26),
               numericInput("prob2", "2倍標準差占比，預設為常態分配95.44%", 95.44),
               helpText("提示：預設為常態分配，非必要調整參數，若想更加嚴謹評估價格可以調高標準差占比"),
               hr(),
               helpText("點擊按鈕開始預測！"),
               submitButton("開始預測")
               #("update", "開始預測",class = "btn-primary")
             ),
             mainPanel(
               tableOutput("view"),
               verbatimTextOutput("result"),
               helpText("公開說明：股價分析結果僅供參考，請搭配基本面一同分析找出最佳的投資策略，投資理財有賺有賠，切莫怪罪數據資料。"),
               plotlyOutput("main_plot"),
               hr(),
               #tableOutput("allview")
               DT::dataTableOutput('allview')
             )
    ),
    tabPanel("各股評估資料表",
             h1("各股股票資訊"),
             helpText("提示：可以根據欄位進行排序。"),
             hr(),
             #tableOutput("stock_df")
             DT::dataTableOutput('stock_df')
             
             ),
    tabPanel("功能暫存頁面", "功能尚未開放")
  )
)