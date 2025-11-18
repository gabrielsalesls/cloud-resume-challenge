function get_visitors() {
    let visitas = localStorage.getItem("contador");

    if (!visitas) {
        visitas = 0;
    }

    visitas++;

    localStorage.setItem("contador", visitas);

    document.getElementById("visitors").textContent = visitas;

    console.log(visitas)

}

get_visitors();