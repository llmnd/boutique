const express = require('express');
const router = express.Router();
const pool = require('../db');

// List all debts
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM debts ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Get single debt by id
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM debts WHERE id = $1', [id]);
    if (result.rowCount === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Create a debt (associate with a client)
router.post('/', async (req, res) => {
  const { client_id, amount, due_date, notes } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO debts (client_id, creditor, debtor, amount, due_date, notes) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [client_id, null, null, amount, due_date, notes]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Update a debt
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { creditor, debtor, amount, due_date, notes, paid } = req.body;
  try {
    const result = await pool.query(
      'UPDATE debts SET creditor=$1, debtor=$2, amount=$3, due_date=$4, notes=$5, paid=COALESCE($6, paid) WHERE id=$7 RETURNING *',
      [creditor, debtor, amount, due_date, notes, paid, id]
    );
    if (result.rowCount === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Delete a debt
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM debts WHERE id=$1 RETURNING *', [id]);
    if (result.rowCount === 0) return res.status(404).json({ error: 'Not found' });
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Record a payment for a debt (partial allowed). Body: { amount, paid_at (optional), notes }
router.post('/:id/pay', async (req, res) => {
  const { id } = req.params;
  const { amount, paid_at, notes } = req.body;
  try {
    const paidAt = paid_at || new Date();
    const insert = await pool.query('INSERT INTO payments (debt_id, amount, paid_at, notes) VALUES ($1, $2, $3, $4) RETURNING *', [id, amount, paidAt, notes]);

    // compute total paid
    const sumRes = await pool.query('SELECT COALESCE(SUM(amount),0) as total_paid FROM payments WHERE debt_id=$1', [id]);
    const totalPaid = parseFloat(sumRes.rows[0].total_paid || 0);

    // get original debt amount
    const debtRes = await pool.query('SELECT amount FROM debts WHERE id=$1', [id]);
    if (debtRes.rowCount === 0) return res.status(404).json({ error: 'Debt not found' });
    const origAmount = parseFloat(debtRes.rows[0].amount || 0);

    const paidFlag = totalPaid >= origAmount;
    const paidAtUpdate = paidFlag ? new Date() : null;
    await pool.query('UPDATE debts SET paid = $1, paid_at = COALESCE($2, paid_at) WHERE id=$3', [paidFlag, paidAtUpdate, id]);

    res.status(201).json({ payment: insert.rows[0], total_paid: totalPaid, remaining: (origAmount - totalPaid) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Get payments for a debt
router.get('/:id/payments', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM payments WHERE debt_id=$1 ORDER BY paid_at DESC', [id]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Get debts for a client with remaining amount
router.get('/client/:clientId', async (req, res) => {
  const { clientId } = req.params;
  try {
    const debtsRes = await pool.query('SELECT * FROM debts WHERE client_id=$1 ORDER BY id DESC', [clientId]);
    const debts = [];
    for (const d of debtsRes.rows) {
      const sumRes = await pool.query('SELECT COALESCE(SUM(amount),0) as total_paid FROM payments WHERE debt_id=$1', [d.id]);
      const totalPaid = parseFloat(sumRes.rows[0].total_paid || 0);
      debts.push({ ...d, total_paid: totalPaid, remaining: parseFloat(d.amount) - totalPaid });
    }
    res.json(debts);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Get balance summary for a user (amount owed to user, and amount user owes)
router.get('/balances/:user', async (req, res) => {
  const { user } = req.params;
  try {
    const owedToRes = await pool.query(
      "SELECT COALESCE(SUM(amount),0) AS owed_to_user FROM debts WHERE creditor=$1 AND (paid IS FALSE OR paid IS NULL)",
      [user]
    );
    const owesRes = await pool.query(
      "SELECT COALESCE(SUM(amount),0) AS owes_user FROM debts WHERE debtor=$1 AND (paid IS FALSE OR paid IS NULL)",
      [user]
    );
    res.json({ owed_to_user: owedToRes.rows[0].owed_to_user, owes_user: owesRes.rows[0].owes_user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

module.exports = router;
