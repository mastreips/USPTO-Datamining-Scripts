library(XML)
library(RCurl)
library(xlsx)
URL <- getURL("http://patents.reedtech.com/parbft.php")
rt <- readHTMLTable(URL, header = TRUE)
rt

url <- "http://patents.reedtech.com/parbft.php"
doc <- htmlParse(url)
links <- xpathSApply(doc, "//a/@href")
free(doc)
links
write(links, file="upto_links.txt")

#  wget --no-proxy -i upto_links_p2.txt

lines   <- readLines("ipa150917.xml")
start   <- grep('<?xml version="1.0" encoding="UTF-8"?>',lines,fixed=T)
end     <- c(start[-1]-1,length(lines))
library(XML)
get.xml <- function(i) {
  txt <- paste(lines[start[i]:end[i]],collapse="\n")
  # print(i)
  xmlTreeParse(txt,asText=T)
  # return(i)
}
docs <- lapply(1:10,get.xml) #first batch of 10
class(docs[[1]])
# [1] "XMLInternalDocument" "XMLAbstractDocument"

#xml <- xmlParse("ipa150917.xml")
#docs <- lapply(1:length(start),get.xml) #parse all docs

sapply(docs,function(doc) xmlValue(doc["//city"][[1]]))
write(docs[1], file="test_parse.xml")
docs[1]
