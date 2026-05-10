const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();

// --- TASK 20: Crearea folderelor necesare ---
const vect_foldere = ["temp", "logs", "backup", "fisiere_uploadate"];
for (let folder of vect_foldere) {
    let caleFolder = path.join(__dirname, folder);
    if (!fs.existsSync(caleFolder)) {
        fs.mkdirSync(caleFolder);
    }
}

// --- CONFIGURARE EJS ȘI RESURSE ---
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// AICI ERA PROBLEMA: Legăm URL-ul '/resurse' de folderul fizic 'Resurse' (cu R mare)
app.use('/resurse', express.static(path.join(__dirname, 'Resurse')));

// --- TASK 19: Gestionare favicon.ico ---
// Am modificat calea să meargă exact în folderul "ico" din poza ta
app.get('/favicon.ico', (req, res) => {
    res.sendFile(path.join(__dirname, 'Resurse', 'imagini', 'ico', 'favicon.ico'));
});

// --- TASK 8: Rutele Paginilor Principale ---
app.get(['/', '/index', '/home'], (req, res) => {
    res.render('pagini/index');
});

app.get('/cursuri', (req, res) => {
    res.render('pagini/cursuri');
});

app.get('/exercitii', (req, res) => {
    res.render('pagini/exercitii');
});

app.get('/teste', (req, res) => {
    res.render('pagini/teste');
});

app.get('/cont', (req, res) => {
    res.render('pagini/cont');
});

app.get('/:numePagina', (req, res) => {
    
    let numePagina = req.params.numePagina; 
    
    res.render('pagini/' + numePagina, function(err, html) {
        if (err) {
            if (err.message.startsWith("Failed to lookup view")) {
                res.status(404).send("Pagina nu a fost găsită! (Vom stiliza asta imediat)");
            } else {
                res.status(500).send("Eroare server!");
            }
        } else {
            res.send(html);
        }
    });
});
app.listen(8080, () => {
    console.log('Serverul Express a pornit cu succes pe portul 8080!');
});