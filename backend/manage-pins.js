#!/usr/bin/env node

/**
 * Utilitaire CLI pour gérer les PINs
 * Usage: node manage-pins.js <command> [arguments]
 */

const pool = require('./db');

const commands = {
  'set-pin': setPin,
  'remove-pin': removePin,
  'list-pins': listPins,
  'check-pin': checkPin,
  'help': showHelp,
};

async function setPin(args) {
  if (args.length < 2) {
    console.error('Usage: node manage-pins.js set-pin <phone> <pin>');
    console.error('  phone: Numéro de téléphone de l\'utilisateur');
    console.error('  pin: PIN à 4 chiffres (ex: 1234)');
    process.exit(1);
  }

  const [phone, pin] = args;

  if (!/^\d{4}$/.test(pin)) {
    console.error('❌ Erreur : Le PIN doit être exactement 4 chiffres');
    process.exit(1);
  }

  try {
    // Vérifier que le PIN n'est pas déjà utilisé
    const existingPin = await pool.query(
      'SELECT id, phone FROM owners WHERE pin=$1',
      [pin]
    );

    if (existingPin.rowCount > 0) {
      console.error(`❌ Erreur : Le PIN ${pin} est déjà utilisé par ${existingPin.rows[0].phone}`);
      process.exit(1);
    }

    // Vérifier que l'utilisateur existe
    const userCheck = await pool.query(
      'SELECT id, first_name, last_name FROM owners WHERE phone=$1',
      [phone]
    );

    if (userCheck.rowCount === 0) {
      console.error(`❌ Erreur : Utilisateur ${phone} non trouvé`);
      process.exit(1);
    }

    const user = userCheck.rows[0];

    // Définir le PIN
    const result = await pool.query(
      'UPDATE owners SET pin=$1, updated_at=NOW() WHERE phone=$2 RETURNING id, phone, first_name, last_name, pin',
      [pin, phone]
    );

    console.log(`✅ PIN configuré avec succès :`);
    console.log(`   Utilisateur: ${user.first_name} ${user.last_name}`);
    console.log(`   Téléphone: ${phone}`);
    console.log(`   PIN: ${pin}`);
  } catch (err) {
    console.error('❌ Erreur :', err.message);
    process.exit(1);
  }
}

async function removePin(args) {
  if (args.length < 1) {
    console.error('Usage: node manage-pins.js remove-pin <phone>');
    process.exit(1);
  }

  const [phone] = args;

  try {
    const result = await pool.query(
      'UPDATE owners SET pin=NULL, updated_at=NOW() WHERE phone=$1 RETURNING id, phone, first_name, last_name',
      [phone]
    );

    if (result.rowCount === 0) {
      console.error(`❌ Erreur : Utilisateur ${phone} non trouvé`);
      process.exit(1);
    }

    console.log(`✅ PIN supprimé pour ${phone}`);
  } catch (err) {
    console.error('❌ Erreur :', err.message);
    process.exit(1);
  }
}

async function listPins(args) {
  try {
    const result = await pool.query(
      'SELECT id, phone, first_name, last_name, pin FROM owners WHERE pin IS NOT NULL ORDER BY phone',
      []
    );

    if (result.rowCount === 0) {
      console.log('❌ Aucun utilisateur avec PIN configuré');
      return;
    }

    console.log('\n📋 Utilisateurs avec PIN configuré:\n');
    console.log('Téléphone    | PIN  | Nom');
    console.log('-------------|------|---------------------');

    result.rows.forEach(row => {
      const name = `${row.first_name || ''} ${row.last_name || ''}`.trim() || 'Sans nom';
      console.log(`${row.phone.padEnd(12)} | ${row.pin}  | ${name}`);
    });

    console.log(`\nTotal: ${result.rowCount} utilisateur(s) avec PIN\n`);
  } catch (err) {
    console.error('❌ Erreur :', err.message);
    process.exit(1);
  }
}

async function checkPin(args) {
  if (args.length < 1) {
    console.error('Usage: node manage-pins.js check-pin <pin>');
    console.error('  Vérifie si un PIN est disponible');
    process.exit(1);
  }

  const [pin] = args;

  if (!/^\d{4}$/.test(pin)) {
    console.error('❌ Erreur : Le PIN doit être exactement 4 chiffres');
    process.exit(1);
  }

  try {
    const result = await pool.query(
      'SELECT phone, first_name, last_name FROM owners WHERE pin=$1',
      [pin]
    );

    if (result.rowCount === 0) {
      console.log(`✅ Le PIN ${pin} est disponible`);
    } else {
      const user = result.rows[0];
      console.log(`❌ Le PIN ${pin} est déjà utilisé par ${user.first_name} ${user.last_name} (${user.phone})`);
    }
  } catch (err) {
    console.error('❌ Erreur :', err.message);
    process.exit(1);
  }
}

function showHelp() {
  console.log(`
╔════════════════════════════════════════════════════════════════╗
║           Gestionnaire de PIN - Boutique App                  ║
╚════════════════════════════════════════════════════════════════╝

Commandes disponibles:

  set-pin <phone> <pin>
    Configure un PIN pour un utilisateur
    Exemple: node manage-pins.js set-pin "0612345678" "1234"

  remove-pin <phone>
    Supprime le PIN d'un utilisateur
    Exemple: node manage-pins.js remove-pin "0612345678"

  list-pins
    Affiche tous les utilisateurs avec PIN configuré
    Exemple: node manage-pins.js list-pins

  check-pin <pin>
    Vérifie si un PIN est disponible
    Exemple: node manage-pins.js check-pin "1234"

  help
    Affiche cette aide
    Exemple: node manage-pins.js help

Notes:
  - Le PIN doit être exactement 4 chiffres
  - Le PIN doit être unique (pas de doublon)
  - Assurez-vous que la base de données est accessible
  `);
}

// Main
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    showHelp();
    process.exit(0);
  }

  const command = args[0];
  const commandArgs = args.slice(1);

  if (!(command in commands)) {
    console.error(`❌ Commande inconnue: ${command}`);
    console.error('Tapez: node manage-pins.js help');
    process.exit(1);
  }

  try {
    await commands[command](commandArgs);
  } finally {
    await pool.end();
  }
}

main().catch(err => {
  console.error('❌ Erreur fatale:', err);
  process.exit(1);
});
