library(shiny)
library(quantmod)
library(zoo)
library(xts)
library(TTR)
library(plotly)

server = function(input, output) {
  
  datasetInput <- eventReactive(input$stock_no,{
    # 設定股票代碼、回朔年份及相關設定
    stock_no = input$stock_no
    end_time = Sys.Date()
    start_time = input$end_time
    prob1 = input$prob1
    prob2 = input$prob2
    
    # 抓取股價
    stock_data = get(getSymbols(stock_no,from = start_time,to = end_time,src = "yahoo"))
    stock_data = as.data.frame(stock_data)
    stock_date = row.names(stock_data)
    stock_price = stock_data[,4]
    stock_num = seq(stock_price)
    
    # 標準差範圍低到高
    s1 = (1-prob2/100)/2
    s2 = (1-prob1/100)/2
    s3 = 1-s2
    s4 = 1-s1
    
    # 建立線性模型
    stock_reg = lm(stock_price~stock_num)
    reg_line = stock_num*stock_reg$coefficients[2]+stock_reg$coefficients[1]
    ss1 = qnorm(s1,reg_line,summary(stock_reg)$s)
    ss2 = qnorm(s2,reg_line,summary(stock_reg)$s)
    ss3 = qnorm(s3,reg_line,summary(stock_reg)$s)
    ss4 = qnorm(s4,reg_line,summary(stock_reg)$s)
    
    # 計算斜率、解釋變量、標準差
    Rsquared = summary(stock_reg)$r.squared
    Slope = stock_reg$coefficients[2]
    Sd = summary(stock_reg)$s
    
    fiveline_data = data.frame(stock_num,stock_date,stock_price,ss1,ss2,reg_line,ss3,ss4,Rsquared,Slope,Sd)
    fiveline_data
  }, ignoreNULL = FALSE)
  
  output$view <- renderTable({
    fiveline_data = datasetInput()
    df = tail(fiveline_data,1)[,c(2,3,4:11)]
    names(df) = c('最新日期','收盤價','-2倍sd','-1倍sd','預測均值','+1倍sd','+2倍sd','回歸解釋率','斜率','標準差sd')
    df
  })
  
  output$allview <- DT::renderDataTable({
    stock_no = input$stock_no
    end_time = Sys.Date()
    start_time = input$end_time
    
    # 抓取股價
    stock_data = get(getSymbols(stock_no,from = start_time,to = end_time,src = "yahoo"))
    stock_data = as.data.frame(stock_data)
    df = data.frame(row.names(stock_data),stock_data[,-6])
    names(df) = c('Date','Open','High','Low','Close','Volume')
    df = data.frame(stock_data[,-6])
    names(df) = c('Open','High','Low','Close','Volume')
    DT::datatable(df, options = list(searching = FALSE,pageLength = 100))
  })
  
  
  output$result <- renderText({
    fiveline_data = datasetInput()
    # 計算現在股價買賣點
    # position從區間計算，加總的值為上至下數的第Ｎ區塊
    now_price = tail(fiveline_data,1)
    position = findInterval(now_price[,4:8],now_price$stock_price) 
    if(sum(position)==0){
      stock_position = '股價高於歷史股價2倍標準差之外，絕對高點，建議看空。'
    }else if(sum(position)==1){
      stock_position = '股價高於歷史股價1倍標準差之外，相對高點，建議持續觀察或看空。'
    }else if(sum(position)==2){
      stock_position = '股價位於一般波動區間，且相對高點，建議持續觀察。'
    }else if(sum(position)==3){
      stock_position = '股價位於一般波動區間，且相對低點，建議持續觀察。'
    }else if(sum(position)==4){
      stock_position = '股價低於歷史股價1倍標準差之外，相對低點，建議持續觀察或看多。'
    }else{
      stock_position = '股價低於歷史股價2倍標準差之外，絕對低點，建議看多。'
    }
    print(stock_position)
  })
  
  # 输出到UI的main_plot
  output$main_plot <- renderPlotly({
    
    fiveline_data = datasetInput()
    # 繪圖畫出趨勢圖
    plot_ly(data = fiveline_data, x = ~stock_date, y = ~stock_price, type = 'scatter', mode = 'lines', name = '歷史價格') %>%
      add_trace(y = ~reg_line, name = '股價趨勢線', mode = 'lines') %>%
      add_trace(y = ~ss4, name = '高2倍標準差', mode = 'lines') %>%
      add_trace(y = ~ss3, name = '高1倍標準差', mode = 'lines') %>%
      add_trace(y = ~ss2, name = '低1倍標準差', mode = 'lines') %>% 
      add_trace(y = ~ss1, name = '低2倍標準差', mode = 'lines')
    
    
  })
  
  
}