CREATE TABLE BENCHMARKS (
  runId VARCHAR(18) NOT NULL,
  systemId VARCHAR(32) NOT NULL,
  file VARCHAR(64) NOT NULL,
  version VARCHAR(32) NOT NULL,
  process VARCHAR(16) NOT NULL,
  start_time DECIMAL NOT NULL,
  end_time DECIMAL NOT NULL,
  duration DECIMAL NOT NULL,
  runs INTEGER NOT NULL,
PRIMARY KEY(runId,process,end_time));

CREATE TABLE META (
  systemId VARCHAR(32),
  variable VARCHAR(32),
  value VARCHAR(32),
PRIMARY KEY(systemId,variable));
