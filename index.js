const express = require('express');
const oracledb= require('oracledb');
const fs = require('fs');
const path = require('path');

const app = express();

console.log("Calea folderului (__dirname):", __dirname);
console.log("Calea fișierului (__filename):", __filename);
console.log("Folderul curent de lucru (process.cwd()):", process.cwd());


const vect_foldere = ["temp", "logs", "backup", "fisiere_uploadate"];
for (let folder of vect_foldere) {
    let caleFolder = path.join(__dirname, folder);
    if (!fs.existsSync(caleFolder)) {
        fs.mkdirSync(caleFolder);
    }
}

const dbConfig = {
    user: "system",
    password: "parola123",
    connectString: "localhost:1521/xe"
};


app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));


app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
    if (req.url.endsWith('.ejs')) {
        return afisareEroare(res, 400); 
    }
    next();
});


app.use('/resurse', (req, res, next) => {
    if (req.url.endsWith('/') || !req.url.includes('.')) {
        return afisareEroare(res, 403); 
    }
    next();
});

app.use('/resurse', express.static(path.join(__dirname, 'Resurse')));

let obGlobal = {
    obErori: null
};


app.use((req, res, next) => {

    let ipUtilizator = req.ip || req.connection.remoteAddress;


    res.locals.ip = ipUtilizator;


    let dataCurenta = new Date().toLocaleString('ro-RO'); 
    

    let mesajLog = `[${ipUtilizator}] [${dataCurenta}] ${req.method} ${req.url}\n`;
    
    let caleLog = path.join(__dirname, 'logs', 'cereri.log');
    

    fs.appendFileSync(caleLog, mesajLog);

    next(); 
});

function initErori() {
    let continut = fs.readFileSync(path.join(__dirname, 'erori.json'), 'utf8');
    obGlobal.obErori = JSON.parse(continut);
    

    let erori = obGlobal.obErori.info_erori;
    for (let eroare of erori) {

        eroare.imagine = path.posix.join(obGlobal.obErori.cale_baza, eroare.imagine);
    }
  
    obGlobal.obErori.eroare_default.imagine = path.posix.join(obGlobal.obErori.cale_baza, obGlobal.obErori.eroare_default.imagine);
}
initErori(); 


function afisareEroare(res, identificator, titlu, text, imagine) {
    let eroareDefault = obGlobal.obErori.eroare_default;

    let eroareCurenta = obGlobal.obErori.info_erori.find(e => e.identificator == identificator) || eroareDefault;


    let titluDeAfisat = titlu || eroareCurenta.titlu;
    let textDeAfisat = text || eroareCurenta.text;
    let imagineDeAfisat = imagine || eroareCurenta.imagine;

    if (eroareCurenta.status) {
        res.status(identificator || 404); 
    }
    

    res.render('pagini/eroare', {
        titlu: titluDeAfisat,
        text: textDeAfisat,
        imagine: imagineDeAfisat
    });
}


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
                afisareEroare(res, 404);
            } else {
                afisareEroare(res, 500, "Eroare Server", "Ceva a mers greșit în spate.");
            }
        } else {
            res.send(html);
        }
    });
});

app.get('/cursuri', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        
        
        const result = await connection.execute(
            `SELECT * FROM CURSURI`,
            [], // nu avem parametri de binding aici
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        res.render('pagini/cursuri', { 
            cursuri: result.rows 
        });

    } catch (err) {
        console.error("Eroare la extragerea cursurilor:", err);
        res.status(500).send("A apărut o eroare la server.");
    } finally {
        if (connection) {
            try { await connection.close(); } catch (err) { console.error(err); }
        }
    }
});

app.post('/adauga-curs', async (req, res) => {
    let connection;
    try {
        
        const titlu = req.body.titlu;
        const descriere = req.body.descriere;
        const id_domeniu = req.body.id_domeniu; 

        connection = await oracledb.getConnection(dbConfig);


        await connection.execute(
            `INSERT INTO CURSURI (ID_Curs, ID_Domeniu, Titlu, Descriere) 
             VALUES (seq_cursuri.NEXTVAL, :domeniu, :titlu, :descriere)`,
            {
                domeniu: id_domeniu,
                titlu: titlu,
                descriere: descriere
            },
            { autoCommit: true } 
        );

        console.log("Curs adăugat cu succes!");
        
        res.redirect('/cursuri');

    } catch (err) {
        console.error("Eroare la inserarea cursului:", err);
        res.status(500).send("Eroare la salvarea în baza de date.");
    } finally {
        if (connection) {
            try { await connection.close(); } catch (err) { console.error(err); }
        }
    }
});

app.use((req, res) => {
    afisareEroare(res, 404);
});


app.listen(8080, () => {
    console.log('Serverul Express a pornit cu succes pe portul 8080!');
});