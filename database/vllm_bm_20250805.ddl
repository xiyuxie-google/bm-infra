ALTER TABLE RunRecord ADD COLUMN PrefixLen INT64 DEFAULT(0);
CREATE INDEX IDX_RunRecord_PrefixLen ON RunRecord (PrefixLen);
