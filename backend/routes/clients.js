const express = require('express');
const router = express.Router();
const pool = require('../db');

// List clients
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM clients ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Create client
router.post('/', async (req, res) => {
  const { client_number, name, avatar_url } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO clients (client_number, name, avatar_url) VALUES ($1, $2, $3) RETURNING *',
      [client_number, name, avatar_url]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Get client
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM clients WHERE id=$1', [req.params.id]);
    if (result.rowCount === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

module.exports = router;
