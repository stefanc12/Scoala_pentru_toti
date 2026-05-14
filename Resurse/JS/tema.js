document.addEventListener("DOMContentLoaded", () => {
    const btnTema = document.getElementById("btn-tema");
    

    const temaSalvata = localStorage.getItem("tema");
    
    if (temaSalvata === "dark") {
        document.documentElement.setAttribute("data-theme", "dark");
    }


    if (btnTema) {
        btnTema.addEventListener("click", () => {

            const temaCurenta = document.documentElement.getAttribute("data-theme");
            
            if (temaCurenta === "dark") {

                document.documentElement.removeAttribute("data-theme");
                localStorage.setItem("tema", "light");
            } else {

                document.documentElement.setAttribute("data-theme", "dark");
                localStorage.setItem("tema", "dark");
            }
        });
    }
});