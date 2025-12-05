const fs = require('fs');
const packageJson = require('./package.json');

// Pfad zur pubspec.yaml
const pubspecPath = './pubspec.yaml';

// Datei lesen
let pubspec = fs.readFileSync(pubspecPath, 'utf8');

// Die Version aus der package.json holen (die wurde von npm version gerade erhöht)
const newVersion = packageJson.version;

// In der pubspec.yaml die Zeile "version: x.x.x" suchen und ersetzen
// WICHTIG: Wir hängen "+1" an, da Flutter für Android/iOS immer eine Build-Number braucht.
// Wenn du die Build-Number auch hochzählen willst, müsste das Skript komplexer sein.
// Hier setzen wir sie statisch auf den neuen Patch.
const updatedPubspec = pubspec.replace(/^version: .*/m, `version: ${newVersion}+1`);

// Datei speichern
fs.writeFileSync(pubspecPath, updatedPubspec);

console.log(`✅ pubspec.yaml wurde auf Version ${newVersion} aktualisiert.`);