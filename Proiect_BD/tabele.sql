
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


insert into domenii values (seq_platforma.NEXTVAL, 'Matematica - nivel de liceu', 'Cursuri de algebra, geometrie și analiza matematica.');
insert into domenii values (seq_platforma.NEXTVAL, 'Informatica - nivel de liceu', 'Algoritmi elementari, structuri de date și programare procedurala.');

insert into domenii values (seq_platforma.NEXTVAL, 'Matematica - nivel de facultate', 'Cursuri de algebră liniara, analiza matematica și probabilități.');
insert into domenii values (seq_platforma.NEXTVAL, 'Informatica - nivel de facultate', 'Programare orientata pe obiecte, baze de date și inteligența artificiala.');


insert into utilizatori values (seq_platforma.NEXTVAL, 'Popescu', 'Ion', 'ion@gmail.com', 'hash1', 'Student', sysdate);
insert into utilizatori values (seq_platforma.NEXTVAL, 'Ionescu', 'Maria', 'maria@yahoo.com', 'hash2', 'Student', sysdate);
insert into utilizatori values (seq_platforma.NEXTVAL, 'Dumitru', 'Vasile', 'vasile@gmail.com', 'hash3', 'Profesor', sysdate);
insert into utilizatori values (seq_platforma.NEXTVAL, 'Stan', 'Andreea', 'andreea@gmail.com', 'hash4', 'Profesor', sysdate);
insert into utilizatori values (seq_platforma.NEXTVAL, 'Marin', 'George', 'george@gmail.com', 'hash5', 'Student', sysdate);


insert into cursuri values (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Matematica - nivel de liceu'), 'Analiza Matematica Clasa a XI-a', 'Limite, derivate și studiul funcțiilor.');
insert into cursuri values (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Matematica - nivel de liceu'), 'Geometrie Analitica', 'Puncte, drepte si vectori in plan');
insert into cursuri values (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Matematica - nivel de facultate'), 'Algebra Liniara', 'Vectori, matrice și sisteme liniare.');
insert into cursuri values (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Informatica - nivel de facultate'), 'Programare Orientata pe Obiecte', 'Concepte OOP în C++');
insert into cursuri values (seq_platforma.NEXTVAL, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Informatica - nivel de facultate'), 'Teoria grafurilor', 'Algoritmi avansati pentru grafuri și arbori.');
insert into cursuri values(seq_platforma.nextval, (SELECT ID_Domeniu FROM DOMENII WHERE Nume='Informatica - nivel de facultate'), 'Baze de date', 'Concepte elementare de baze de date și SQL.');


insert into lectii values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiza Matematica Clasa a XI-a'), 'Derivata unei funcții', 'Definitia derivatei și reguli de calcul.');
insert into lectii values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiza Matematica Clasa a XI-a'), 'Puncte de extrem', 'Identificarea si clasificarea punctelor de extrem ale unei funcții.');
insert into lectii values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Programare Orientata pe Obiecte'), 'Clase si Obiecte', 'Instantiere si constructori în OOP.');
insert into lectii values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Teoria grafurilor'), 'Parcurgerea BFS si DFS', 'Introducere în algoritmii de parcurgere a grafurilor folosind cozi și stive.');
insert into lectii values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Baze de date'), 'join, left join, right join', 'Concepte de baza pentru combinarea tabelelor în SQL');



insert into exercitii values (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Derivata unei funcții'), 'Calculeaza derivata lui x^2', 'Ușor', '2x');
insert into exercitii values (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Clase si Obiecte'), 'Scrie o clasa Masina în C++', 'Mediu', 'class Masina { ... };');
insert into exercitii values (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Parcurgerea BFS si DFS'), 'Gaseste drumul minim în graful dat', 'Greu', 'DFS');
insert into exercitii values (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='Puncte de extrem'), 'Gaseste punctele de extrem ale funcției f(x) = x^3 - 3x', 'Mediu', 'df/dx = 3x^2 - 3 = 0 => x = -1, 1');
insert into exercitii values (seq_platforma.NEXTVAL, (SELECT ID_Lectie FROM LECTII WHERE Titlu='join, left join, right join'), 'afisati numele studentilor care au luat punctaj maxim la concurs', 'Mediu', 'SELECT nume FROM utilizatori u JOIN rezultate_teste r ON u.id_utilizator = r.id_utilizator WHERE r.scorfinal = 100');


insert into teste values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiza Matematica Clasa a XI-a'), 'Test Analiza limite', 'Capitol');
insert into teste values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Programare Orientata pe Obiecte'), 'Examen OOP', 'Examen Facultate');
insert into teste values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Teoria grafurilor'), 'Test Teorie Grafuri', 'Examen Facultate');
insert into teste values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Baze de date'), 'Examen final Baze de date', 'Examen Facultate');
insert into teste values (seq_platforma.NEXTVAL, (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiza Matematica Clasa a XI-a'), 'Test Analiza derivate', 'Capitol');

INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@gmail.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiza Matematica Clasa a XI-a'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@gmail.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Teoria grafurilor'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@yahoo.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Programare Orientata pe Obiecte'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Teoria grafurilor'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Programare Orientata pe Obiecte'), SYSDATE);
INSERT INTO CURSURI_SALVATE VALUES (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Curs FROM CURSURI WHERE Titlu='Analiza Matematica Clasa a XI-a'), SYSDATE);

insert into rezultate_teste values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@gmail.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Test Analiza limite'), 85.50, SYSDATE);
insert into rezultate_teste values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@gmail.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Test Analiza derivate'), 76.00, SYSDATE);
insert into rezultate_teste values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Examen final Baze de date'), 60.00, SYSDATE);
insert into rezultate_teste values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Examen OOP'), 56.00, SYSDATE);
insert into rezultate_teste values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@yahoo.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Examen OOP'), 88.00, SYSDATE);
insert into rezultate_teste values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@yahoo.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Examen final Baze de date'), 92.00, SYSDATE);
insert into rezultate_teste values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Test Teorie Grafuri'), 70.00, SYSDATE);
insert into rezultate_teste values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@yahoo.com'), (SELECT ID_Test FROM TESTE WHERE Titlu='Test Teorie Grafuri'), 55.00, SYSDATE);

insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@gmail.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@gmail.com'), SYSTIMESTAMP + INTERVAL '1' DAY, 150.00, 'InAsteptare');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@gmail.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@gmail.com'), SYSTIMESTAMP - INTERVAL '2' DAY, 150.00, 'Finalizata');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='ion@gmail.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@gmail.com'), SYSTIMESTAMP + INTERVAL '3' DAY, 120.00, 'InAsteptare');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@yahoo.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@gmail.com'), SYSTIMESTAMP - INTERVAL '1' DAY, 120.00, 'Finalizata');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@yahoo.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@gmail.com'), SYSTIMESTAMP + INTERVAL '5' DAY, 120.00, 'InAsteptare');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='maria@yahoo.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@gmail.com'), SYSTIMESTAMP + INTERVAL '2' DAY, 150.00, 'InAsteptare');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@gmail.com'), SYSTIMESTAMP - INTERVAL '5' DAY, 150.00, 'Finalizata');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='vasile@gmail.com'), SYSTIMESTAMP + INTERVAL '4' DAY, 150.00, 'InAsteptare');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@gmail.com'), SYSTIMESTAMP - INTERVAL '10' DAY, 120.00, 'Finalizata');
insert into CONSULTATII values (seq_platforma.NEXTVAL, (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='george@gmail.com'), (SELECT ID_Utilizator FROM UTILIZATORI WHERE Email='andreea@gmail.com'), SYSTIMESTAMP + INTERVAL '7' DAY, 120.00, 'InAsteptare');

ALTER TABLE EXERCITII ADD (Status VARCHAR2(20) DEFAULT 'InAsteptare' CHECK (Status IN ('InAsteptare', 'Validat')));
UPDATE EXERCITII SET Status = 'Validat';
COMMIT;