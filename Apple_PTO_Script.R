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

lines   <- readLines("ipa150917.xml") #This is only one zip file
start   <- grep('<?xml version="1.0" encoding="UTF-8"?>',lines,fixed=T)
end     <- c(start[-1]-1,length(lines))
library(XML)
get.xml <- function(i) {
  txt <- paste(lines[start[i]:end[i]],collapse="\n")
  # print(i)
  #xmlTreeParse(txt,asText=T)
  xmlTreeParse(txt,asText=T, useInternalNodes = TRUE) #needed internal nodes to work
  # return(i)
}
docs <- lapply(1:10,get.xml) #first batch of 10
class(docs[[1]])
# [1] "XMLInternalDocument" "XMLAbstractDocument"

#xml <- xmlParse("ipa150917.xml")
#docs <- lapply(1:length(start),get.xml) #parse all docs
sapply(docs,function(doc) xmlValue(doc["//invention-title"][[1]]))

head(docs[1],1)
root <- xmlRoot(docs[[1]])
root
names(root)
child = xmlChildren(root)
names(child)
xmlValue(child[["description"]]) #This DID IT!! (for one doc)

#This did do it
names(docs)
root2 <- sapply(docs,function(doc) xmlRoot(doc))
child2 <- sapply(root2, function(roots) xmlChildren(roots))
names(child2[[1]])
xmlValue(child2[[3]][["description"]]) ## changing the value in the cell will iter through
for (i in 1:10){
  total <- xmlValue(child2[[i]][["description"]])
  write(total, file="test_desc.txt", append = TRUE)
}

#Create NLP Corpus
require(tm)
mycorpus <- Corpus(URISource("test_desc.txt"))
mycorpus <- tm_map(mycorpus, tolower)
mycorpus <- tm_map(mycorpus, removeNumbers)
myStopWords <- c(stopwords('english'), '\n', '\"', '\f')
mycorpus <- tm_map(mycorpus, removeWords, stopwords("english"))
corpus_clean <- tm_map(mycorpus, PlainTextDocument)
dtm <- DocumentTermMatrix(corpus_clean)

wordMatrix <- as.data.frame(t(as.matrix(dtm)))
wordMatrix$names <- rownames(wordMatrix) #adds row names - skip if needed

#hCluster = hclust(dist(t(wordMatrix[1:583,1:2])))
hCluster = hclust(dist(t(wordMatrix[1:583,])))

write.csv(wordMatrix, "final.table.csv")


