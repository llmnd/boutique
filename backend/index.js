require('dotenv').config();
const express = require('express');
const app = express();
const cors = require('cors');
const debtsRouter = require('./routes/debts');
const clientsRouter = require('./routes/clients');
const authRouter = require('./routes/auth');
const teamRouter = require('./routes/team');
const countriesRouter = require('./routes/countries');
const pool = require('./db');
const fs = require('fs');
const path = require('path');

const port = process.env.PORT || 3000;

// CORS configuration - allow requests from all origins (or configure specific origins)
const corsOptions = {
  origin: function (origin, callback) {
    // Allow all origins to bypass CORS issues in development
    // For production, specify allowed origins: ['https://yourdomain.com']
    callback(null, true);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'x-owner', 'x-token'],
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
app.use(express.json());

// ✅ Serve static files from downloads directory
const downloadsPath = path.join(__dirname, './downloads');
if (fs.existsSync(downloadsPath)) {
  app.use('/downloads', express.static(downloadsPath));
  console.log('✅ Downloads served from:', downloadsPath);
}

app.use('/api/debts', debtsRouter);
app.use('/api/clients', clientsRouter);
app.use('/api/auth', authRouter);
app.use('/api/team', teamRouter);
app.use('/api/countries', countriesRouter);

// Endpoint for getting all additions by owner_phone (for Hive sync)
app.get('/api/debt-additions', async (req, res) => {
  const ownerPhone = req.query.owner_phone;
  if (!ownerPhone) {
    return res.status(400).json({ error: 'owner_phone required' });
  }
  
  try {
    // Get all debts for this owner
    const debtsRes = await pool.query(
      'SELECT id FROM debts WHERE creditor=$1',
      [ownerPhone]
    );

    if (debtsRes.rowCount === 0) {
      return res.json([]);
    }

    const debtIds = debtsRes.rows.map(d => d.id);
    
    // Get all additions for all these debts
    const additionsRes = await pool.query(
      `SELECT * FROM debt_additions 
       WHERE debt_id = ANY($1)
       ORDER BY added_at DESC`,
      [debtIds]
    );

    res.json(additionsRes.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Endpoint for getting all payments by owner_phone (for Hive sync)
app.get('/api/payments', async (req, res) => {
  const ownerPhone = req.query.owner_phone;
  if (!ownerPhone) {
    return res.status(400).json({ error: 'owner_phone required' });
  }
  
  try {
    // Get all debts for this owner
    const debtsRes = await pool.query(
      'SELECT id FROM debts WHERE creditor=$1',
      [ownerPhone]
    );

    if (debtsRes.rowCount === 0) {
      return res.json([]);
    }

    const debtIds = debtsRes.rows.map(d => d.id);
    
    // Get all payments for all these debts
    const paymentsRes = await pool.query(
      `SELECT * FROM payments 
       WHERE debt_id = ANY($1)
       ORDER BY paid_at DESC`,
      [debtIds]
    );

    res.json(paymentsRes.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Run migrations file (safe to run multiple times)
try {
	const mig = fs.readFileSync(path.join(__dirname, 'migrate.sql'), 'utf8');
	pool.query(mig).then(() => console.log('Migrations applied')).catch((err) => console.error('Migration error:', err));
} catch (e) {
	console.error('Could not run migrations:', e);
}

// ✅ Run all migration files from migrations/ folder
async function runMigrations() {
	try {
		const migrationsDir = path.join(__dirname, 'migrations');
		const files = fs.readdirSync(migrationsDir)
			.filter(file => file.endsWith('.sql'))
			.sort(); // Run in order
		
		for (const file of files) {
			const migrationPath = path.join(migrationsDir, file);
			const migrationSql = fs.readFileSync(migrationPath, 'utf8');
			try {
				await pool.query(migrationSql);
				console.log(`✅ Migration applied: ${file}`);
			} catch (err) {
				console.error(`❌ Migration failed (${file}):`, err.message);
				// Continue with next migration even if one fails
			}
		}
	} catch (e) {
		console.error('Could not run migration files:', e);
	}
}

runMigrations();

app.get('/', (req, res) => res.send('Boutique backend is running'));

// ✅ Diagnostic endpoint - check APK locations
app.get('/api/apk-status', (req, res) => {
  const possiblePaths = [
    path.join(__dirname, './downloads/boutique-mobile.apk'),
    path.join(__dirname, '../build/web/downloads/boutique-mobile.apk'),
  ];
  
  const status = {
    __dirname,
    checked_paths: possiblePaths,
    found_at: null,
  };
  
  for (const p of possiblePaths) {
    if (fs.existsSync(p)) {
      status.found_at = p;
      const stats = fs.statSync(p);
      status.file_size = stats.size;
      status.file_size_mb = (stats.size / 1024 / 1024).toFixed(2) + ' MB';
      break;
    }
  }
  
  res.json(status);
});

// ✅ APK Download endpoint
app.get('/api/download/apk', (req, res) => {
  try {
    const apkPath = path.join(__dirname, './downloads/boutique-mobile.apk');
    
    if (!fs.existsSync(apkPath)) {
      console.error('❌ APK not found at:', apkPath);
      return res.status(404).json({ error: 'APK not found', path: apkPath });
    }
    
    // Set proper headers for APK download
    res.setHeader('Content-Type', 'application/vnd.android.package-archive');
    res.setHeader('Content-Disposition', 'attachment; filename=boutique-mobile.apk');
    res.setHeader('Content-Length', fs.statSync(apkPath).size);
    res.setHeader('Cache-Control', 'public, max-age=86400');
    
    console.log('✅ Serving APK from:', apkPath);
    
    // Stream the file
    const fileStream = fs.createReadStream(apkPath);
    fileStream.pipe(res);
    
    fileStream.on('error', (err) => {
      console.error('❌ Error streaming APK:', err);
      if (!res.headersSent) {
        res.status(500).json({ error: 'Error downloading APK' });
      }
    });
  } catch (err) {
    console.error('❌ APK download error:', err);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

app.listen(port, () => console.log(`Server running on port ${port}`));
