# Create environments if they don't exist yet
.BenchEnv <- new.env()
.ExEnv <- new.env(parent = .BenchEnv)

.BenchEnv$BM <- data.frame( 
  runId = character(0), 
  systemId = character(0), 
  file = character(0), 
  version = character(0), 
  process = character(0), 
  start = numeric(0), 
  end = numeric(0), 
  duration = numeric(0), 
  runs = numeric(0),
  stringsAsFactors = FALSE
)

.BenchEnv$META <- data.frame( 
  systemId = character(0), 
  systemAttribute = character(0), 
  attributeValue = character(0),
  stringsAsFactors = FALSE
)
