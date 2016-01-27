# Create environments if they don't exist yet
BenchEnv <- new.env()
ExEnv <- new.env(parent = BenchEnv)

ExEnv$PROFILES <- data.frame(runId = character(0), 
                             systemId = character(0), 
                             file = character(0), 
                             process = character(0), 
                             start = numeric(0), 
                             end = numeric(0), 
                             duration = numeric(0), 
                             stringsAsFactors = F)

ExEnv$BENCHMARKS <- data.frame(runId = character(0),
                               systemId = character(0),
                               file = character(0),
                               time = numeric(0),
                               stringsAsFactors = F)

ExEnv$META <- data.frame(systemId = character(0), 
                         systemAttribute = character(0), 
                         attributeValue = character(0),
                         stringsAsFactors = F)

ExEnv$WARNINGS <- data.frame(runId = character(0), 
                             file = character(0), 
                             lineOfDirectCall = integer(0), 
                             stringsAsFactors = F)
