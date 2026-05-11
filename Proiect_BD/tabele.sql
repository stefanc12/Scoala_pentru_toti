
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_platforma';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

BEGIN
   FOR cur_rec IN (SELECT table_name FROM user_tables WHERE table_name IN ('CONSULTATII', 'REZULTATE_TESTE', 'CURSURI_SALVATE', 'TESTE', 'EXERCITII', 'LECTII', 'CURSURI', 'UTILIZATORI', 'DOMENII')) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || cur_rec.table_name || ' CASCADE CONSTRAINTS';
   END LOOP;
END;
/


CREATE SEQUENCE seq_platforma START WITH 1 INCREMENT BY 1 NOCACHE;



CREATE TABLE DOMENII (
    ID_Domeniu INT PRIMARY KEY,
    Nume VARCHAR2(100) NOT NULL,
    Descriere VARCHAR2(500)
);

CREATE TABLE UTILIZATORI (
    ID_Utilizator INT PRIMARY KEY,
    Nume VARCHAR2(100) NOT NULL,
    Prenume VARCHAR2(100) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    HashParola VARCHAR2(255) NOT NULL,
    Rol VARCHAR2(20) CHECK (Rol IN ('Student', 'Profesor')),
    CreatLa DATE DEFAULT SYSDATE
);

CREATE TABLE CURSURI (
    ID_Curs INT PRIMARY KEY,
    ID_Domeniu INT NOT NULL,
    Titlu VARCHAR2(150) NOT NULL,
    Descriere VARCHAR2(500),
    CONSTRAINT fk_curs_domeniu FOREIGN KEY (ID_Domeniu) REFERENCES DOMENII(ID_Domeniu)
);

CREATE TABLE LECTII (
    ID_Lectie INT PRIMARY KEY,
    ID_Curs INT NOT NULL,
    Titlu VARCHAR2(150) NOT NULL,
    Continut CLOB,
    CONSTRAINT fk_lectie_curs FOREIGN KEY (ID_Curs) REFERENCES CURSURI(ID_Curs)
);

CREATE TABLE EXERCITII (
    ID_Exercitiu INT PRIMARY KEY,
    ID_Lectie INT NOT NULL,
    Continut CLOB,
    NivelDificultate VARCHAR2(20) CHECK (NivelDificultate IN ('Ușor', 'Mediu', 'Greu')),
    Solutie CLOB,
    CONSTRAINT fk_exercitiu_lectie FOREIGN KEY (ID_Lectie) REFERENCES LECTII(ID_Lectie)
);

CREATE TABLE TESTE (
    ID_Test INT PRIMARY KEY,
    ID_Curs INT NOT NULL,
    Titlu VARCHAR2(150) NOT NULL,
    TipTest VARCHAR2(50) CHECK (TipTest IN ('Capitol', 'Bacalaureat', 'Admitere')),
    CONSTRAINT fk_test_curs FOREIGN KEY (ID_Curs) REFERENCES CURSURI(ID_Curs)
);

CREATE TABLE CURSURI_SALVATE (
    ID_Salvare INT PRIMARY KEY,
    ID_Utilizator INT NOT NULL,
    ID_Curs INT NOT NULL,
    SalvatLa DATE DEFAULT SYSDATE,
    CONSTRAINT fk_salvare_user FOREIGN KEY (ID_Utilizator) REFERENCES UTILIZATORI(ID_Utilizator),
    CONSTRAINT fk_salvare_curs FOREIGN KEY (ID_Curs) REFERENCES CURSURI(ID_Curs)
);

CREATE TABLE REZULTATE_TESTE (
    ID_Rezultat INT PRIMARY KEY,
    ID_Utilizator INT NOT NULL,
    ID_Test INT NOT NULL,
    ScorFinal NUMBER(5,2) CHECK (ScorFinal >= 0 AND ScorFinal <= 100),
    TrimisLa DATE DEFAULT SYSDATE,
    CONSTRAINT fk_rezultat_user FOREIGN KEY (ID_Utilizator) REFERENCES UTILIZATORI(ID_Utilizator),
    CONSTRAINT fk_rezultat_test FOREIGN KEY (ID_Test) REFERENCES TESTE(ID_Test)
);

CREATE TABLE CONSULTATII (
    ID_Consultatie INT PRIMARY KEY,
    ID_Student INT NOT NULL,
    ID_Profesor INT NOT NULL,
    DataProgramata TIMESTAMP,
    Pret NUMBER(6,2),
    Status VARCHAR2(20) CHECK (Status IN ('InAsteptare', 'Finalizata')),
    CONSTRAINT fk_cons_student FOREIGN KEY (ID_Student) REFERENCES UTILIZATORI(ID_Utilizator),
    CONSTRAINT fk_cons_profesor FOREIGN KEY (ID_Profesor) REFERENCES UTILIZATORI(ID_Utilizator)
);




INSERT INTO DOMENII VALUES (seq_platforma.NEXTVAL, 'Matematică', 'Cursuri de algebră, geometrie și analiză matematică.');
INSERT INTO DOMENII VALUES (seq_platforma.NEXTVAL, 'Informatică', 'Algoritmi, structuri de date și programare.');
INSERT INTO DOMENII VALUES (seq_platforma.NEXTVAL, 'Fizică', 'Mecanică, termodinamică și electricitate.');
INSERT INTO DOMENII VALUES (seq_platforma.NEXTVAL, 'Limba Română', 'Gramatică și literatură română pentru examene.');
INSERT INTO DOMENII VALUES (seq_platforma.NEXTVAL, 'Istorie', 'Istoria românilor și istorie universală.');

INSERT INTO UTILIZATORI VALUES (seq_platforma.NEXTVAL, 'Popescu Ion', 'ion@email.com', 'hash1', 'Student', SYSDATE);
INSERT INTO UTILIZATORI VALUES (seq_platforma.NEXTVAL, 'Ionescu Maria', 'maria@email.com', 'hash2', 'Student', SYSDATE);
INSERT INTO UTILIZATORI VALUES (seq_platforma.NEXTVAL, 'Dumitru Vasile', 'vasile@email.com', 'hash3', 'Profesor', SYSDATE);
INSERT INTO UTILIZATORI VALUES (seq_platforma.NEXTVAL, 'Stan Andreea', 'andreea@email.com', 'hash4', 'Profesor', SYSDATE);
INSERT INTO UTILIZATORI VALUES (seq_platforma.NEXTVAL, 'Marin George', 'george@email.com', 'hash5', 'Student', SYSDATE);


INSERT INTO CURSURI VALUES (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Matematică'), 'Analiză Matematică Clasa a XI-a', 'Limite, derivate și studiul funcțiilor.');
INSERT INTO CURSURI VALUES (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Informatică'), 'Programare Orientată pe Obiecte', 'Concepte OOP în C++ și Java.');
INSERT INTO CURSURI VALUES (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Informatică'), 'Grafuri și Arbori', 'Algoritmi avansați pentru olimpiadă.');
INSERT INTO CURSURI VALUES (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Fizică'), 'Fizică Mecanică', 'Cinematică și dinamică.');
INSERT INTO CURSURI VALUES (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Limba Română'), 'Eseu Bacalaureat', 'Cum să scrii un eseu de nota 10.');


INSERT INTO LECTII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiză Matematică Clasa a XI-a'), 'Derivata unei funcții', 'Definiția derivatei și reguli de calcul.');
INSERT INTO LECTII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Programare Orientată pe Obiecte'), 'Clase și Obiecte', 'Instanțiere și constructori în OOP.');
INSERT INTO LECTII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Grafuri și Arbori'), 'Parcurgerea BFS și DFS', 'Teorie grafuri și cozi.');
INSERT INTO LECTII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Fizică Mecanică'), 'Principiile mecanicii', 'Cele 3 principii ale lui Newton.');
INSERT INTO LECTII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Eseu Bacalaureat'), 'Luceafărul - Analiză', 'Tema și viziunea despre lume.');


INSERT INTO EXERCITII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Derivata unei funcții'), 'Calculează derivata lui x^2', 'Ușor', '2x');
INSERT INTO EXERCITII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Clase și Obiecte'), 'Scrie o clasă Masina în C++', 'Mediu', 'class Masina { ... };');
INSERT INTO EXERCITII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Parcurgerea BFS și DFS'), 'Găsește drumul minim în graf', 'Greu', 'Se aplică algoritmul Dijkstra.');
INSERT INTO EXERCITII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Principiile mecanicii'), 'Află accelerația corpului', 'Mediu', 'a = F/m');
INSERT INTO EXERCITII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Luceafărul - Analiză'), 'Comentează strofa a doua', 'Mediu', 'Text argumentativ...');


INSERT INTO TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiză Matematică Clasa a XI-a'), 'Test Analiză Cap. 1', 'Capitol');
INSERT INTO TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Programare Orientată pe Obiecte'), 'Simulare Info OOP', 'Bacalaureat');
INSERT INTO TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Grafuri și Arbori'), 'Admitere UBB Info', 'Admitere');
INSERT INTO TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Fizică Mecanică'), 'Test Dinamică', 'Capitol');
INSERT INTO TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Eseu Bacalaureat'), 'Subiectul III Română', 'Bacalaureat');


INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiză Matematică Clasa a XI-a'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Fizică Mecanică'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Grafuri și Arbori'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Eseu Bacalaureat'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Programare Orientată pe Obiecte'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Fizică Mecanică'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Grafuri și Arbori'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Programare Orientată pe Obiecte'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiză Matematică Clasa a XI-a'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Eseu Bacalaureat'), SYSDATE);


INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Test Analiză Cap. 1'), 85.50, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Test Dinamică'), 92.00, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Admitere UBB Info'), 78.50, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Subiectul III Română'), 95.00, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Simulare Info OOP'), 88.00, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Test Dinamică'), 65.50, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Admitere UBB Info'), 99.00, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Simulare Info OOP'), 96.00, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Test Analiză Cap. 1'), 75.00, SYSDATE);
INSERT INTO REZULTATE_TESTE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Subiectul III Română'), 82.50, SYSDATE);


INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@email.com'), SYSTIMESTAMP + INTERVAL '1' DAY, 150.00, 'InAsteptare');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@email.com'), SYSTIMESTAMP - INTERVAL '2' DAY, 150.00, 'Finalizata');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@email.com'), SYSTIMESTAMP + INTERVAL '3' DAY, 120.00, 'InAsteptare');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@email.com'), SYSTIMESTAMP - INTERVAL '1' DAY, 120.00, 'Finalizata');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@email.com'), SYSTIMESTAMP + INTERVAL '5' DAY, 120.00, 'InAsteptare');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@email.com'), SYSTIMESTAMP + INTERVAL '2' DAY, 150.00, 'InAsteptare');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@email.com'), SYSTIMESTAMP - INTERVAL '5' DAY, 150.00, 'Finalizata');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@email.com'), SYSTIMESTAMP + INTERVAL '4' DAY, 150.00, 'InAsteptare');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@email.com'), SYSTIMESTAMP - INTERVAL '10' DAY, 120.00, 'Finalizata');
INSERT INTO CONSULTATII VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@email.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@email.com'), SYSTIMESTAMP + INTERVAL '7' DAY, 120.00, 'InAsteptare');



COMMIT;