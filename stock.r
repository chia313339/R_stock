library(rvest)
library(XML)
# catch stock code list
link = 'http://isin.twse.com.tw/isin/C_public.jsp?strMode=2'
url <- read_html(link)
tbls<-readHTMLTable(link)
