-- This script is to be executed by https://github.com/alphagov/env-sync-and-backup
-- (private repo) as part of the data sync from production to integration.
-- It is used to remove any access limited content from Content Publisher at
-- the point of copying to integration.
-- It is kept in this repo to be tested with the application, whenever changes
-- are made it should be re-copied to the env-sync-and-backup repository.

-- Remove current status of any access limited editions
UPDATE editions
SET current = false
WHERE access_limit_id IS NOT NULL;

-- Set the live editions to current for any docs with an access limited draft
UPDATE editions
SET current = true
WHERE live = true
AND document_id IN (
  SELECT document_id
  FROM editions
  WHERE access_limit_id IS NOT NULL
);

-- Delete any access limited editions
DELETE FROM editions WHERE access_limit_id IS NOT NULL;
