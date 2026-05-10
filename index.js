const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();

const vect_foldere = ["temp", "logs", "backup", "fisiere_uploadate"];
for (let folder of vect_foldere) {
    let caleFolder = path.join(__dirname, folder);
    if (!fs.existsSync(caleFolder)) {
        fs.mkdirSync(caleFolder);
    }
}

app.set('view engine', 'ejs');
app.use('/resurse', express.static(path.join(__dirname, 'resurse')));

app.set('views', path.join(__dirname, 'views'));


app.get(['/', '/index', '/home'], (req, res) => {
    // Randăm fișierul index.ejs din folderul views/pagini
    res.render('pagini/index');
});

app.listen(8080, () => {
    console.log('Serverul Express a pornit cu succes pe portul 8080!');
});