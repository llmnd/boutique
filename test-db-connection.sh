#!/bin/bash
# Test Neon Database Connection

echo "Testing Neon Database Connection..."
echo "DATABASE_URL: $DATABASE_URL"

# Test avec psql (si installé)
if command -v psql &> /dev/null; then
  echo "Testing with psql..."
  psql "$DATABASE_URL" -c "SELECT 1 as connection_test;"
else
  echo "psql not found. Testing with Node.js..."
  node -e "
    const { Pool } = require('pg');
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false }
    });
    
    pool.query('SELECT 1 as connection_test', (err, result) => {
      if (err) {
        console.error('❌ Connection Failed:', err.message);
        process.exit(1);
      } else {
        console.log('✅ Connection Successful!');
        console.log('Result:', result.rows);
        process.exit(0);
      }
    });
  "
fi
