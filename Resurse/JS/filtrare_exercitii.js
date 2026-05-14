document.addEventListener("DOMContentLoaded", () => {
    const btnAplica = document.getElementById("btn-aplica-filtre");
    const btnReset = document.getElementById("btn-reset-filtre");
    const inputCautare = document.getElementById("cautare-text");
    

    const listaExercitii = document.querySelectorAll(".exercitiu-item");


    function aplicaFiltre() {

        const textCautat = inputCautare.value.toLowerCase().trim();


        const checkboxuriBifate = document.querySelectorAll(".btn-check:checked");

        const dificultatiSelectate = Array.from(checkboxuriBifate).map(cb => cb.value);


        listaExercitii.forEach(exercitiu => {

            const cerintaText = exercitiu.querySelector(".cerinta-text").innerText.toLowerCase();
            const dificultateExercitiu = exercitiu.getAttribute("data-dificultate");


            const treceTestText = cerintaText.includes(textCautat);


            const treceTestDificultate = dificultatiSelectate.length === 0 || dificultatiSelectate.includes(dificultateExercitiu);


            if (treceTestText && treceTestDificultate) {
                exercitiu.style.display = "block"; 
            } else {
                exercitiu.style.display = "none";
            }
        });
    }

    function reseteazaFiltre() {

        inputCautare.value = "";
        

        document.querySelectorAll(".btn-check").forEach(cb => cb.checked = false);
        

        listaExercitii.forEach(exercitiu => {
            exercitiu.style.display = "block";
        });
    }
    if(btnAplica) btnAplica.addEventListener("click", aplicaFiltre);
    if(btnReset) btnReset.addEventListener("click", reseteazaFiltre);
});