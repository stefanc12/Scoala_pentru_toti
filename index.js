const express = require('express');
const oracledb= require('oracledb');
const fs = require('fs');
const path = require('path');

const session = require('express-session');

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

app.use(session({
    secret: 'secret-proiect-facultate', 
    resave: false,
    saveUninitialized: false,
    cookie: { maxAge: 1000 * 60 * 60 * 24 }
}));

app.use((req, res, next) => {
    res.locals.utilizator = req.session.utilizator || null;   
    res.locals.caleCurenta = req.path; 
    next();
});

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



app.post('/inregistrare', async (req, res) => {
    let connection;
    try {
        const { nume, prenume, email, parola, rol } = req.body;
        connection = await oracledb.getConnection(dbConfig);
        await connection.execute(
            `INSERT INTO UTILIZATORI (ID_Utilizator, Nume, Prenume, Email, HashParola, Rol) 
             VALUES (seq_platforma.NEXTVAL, :nume, :prenume, :email, :parola, :rol)`,
            { nume, prenume, email, parola, rol: rol || 'Student' },
            { autoCommit: true }
        );
        res.redirect('/cont?succes=inregistrat');
    } catch (err) {
        console.error(err);
        res.redirect('/cont?eroare=existent');
    } finally {
        if (connection) await connection.close();
    }
});

app.post('/logare', async (req, res) => {
    let connection;
    try {
        const { email, parola } = req.body;
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(
            `SELECT * FROM UTILIZATORI WHERE Email = :email AND HashParola = :parola`,
            { email, parola },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        if (result.rows.length > 0) {
            req.session.utilizator = result.rows[0];
            res.redirect('/');
        } else {
            res.redirect('/cont?eroare=date_incorecte');
        }
    } catch (err) {
        res.status(500).send("Eroare server");
    } finally {
        if (connection) await connection.close();
    }
});

app.get('/cont', async (req, res) => {
    if (!req.session.utilizator) {
        return res.render('pagini/cont');
    }

    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const userId = req.session.utilizator.ID_UTILIZATOR;


        const cursuriSalvate = await connection.execute(
            `SELECT c.TITLU, c.ID_CURS FROM CURSURI_SALVATE cs 
             JOIN CURSURI c ON cs.ID_CURS = c.ID_CURS 
             WHERE cs.ID_UTILIZATOR = :id`,
            [userId],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );


        let rezultateTeste = [];
        if (req.session.utilizator.ROL === 'Student') {
            const result = await connection.execute(
                `SELECT t.TITLU, rt.SCORFINAL, TO_CHAR(rt.TRIMISLA, 'DD-MM-YYYY') as DATA 
                 FROM REZULTATE_TESTE rt 
                 JOIN TESTE t ON rt.ID_TEST = t.ID_TEST 
                 WHERE rt.ID_UTILIZATOR = :id`,
                [userId],
                { outFormat: oracledb.OUT_FORMAT_OBJECT }
            );
            rezultateTeste = result.rows;
        }


        res.render('pagini/cont', {
            utilizator: req.session.utilizator,
            cursuriSalvate: cursuriSalvate.rows,
            rezultateTeste: rezultateTeste
        });

    } catch (err) {
        console.error("Eroare la încărcarea datelor de profil:", err);
        res.status(500).send("Eroare la baza de date.");
    } finally {
        if (connection) await connection.close();
    }
});

app.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/');
});

app.get('/cursuri', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(`SELECT * FROM CURSURI`, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.render('pagini/cursuri', { cursuri: result.rows });
    } catch (err) {
        console.error("detaliile erorii:", err);
        res.status(500).send("Eroare DB" + err.message);
    } finally {
        if (connection) await connection.close();
    }
});

app.post('/adauga-curs', async (req, res) => {
    let connection;
    try {
        const { titlu, descriere, id_domeniu } = req.body;
        connection = await oracledb.getConnection(dbConfig);
        await connection.execute(
            `INSERT INTO CURSURI (ID_Curs, ID_Domeniu, Titlu, Descriere) VALUES (seq_platforma.NEXTVAL, :domeniu, :titlu, :descriere)`,
            { domeniu: id_domeniu, titlu, descriere },
            { autoCommit: true }
        );
        res.redirect('/cursuri');
    } catch (err) {
        res.status(500).send("Eroare inserare");
    } finally {
        if (connection) await connection.close();
    }
});

app.get(['/', '/index', '/home'], (req, res) => {
    res.render('pagini/index');
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


app.use((req, res) => {
    afisareEroare(res, 404);
});


app.listen(8080, () => {
    console.log('Serverul Express a pornit cu succes pe portul 8080!');
});