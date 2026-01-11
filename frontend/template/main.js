async function get_visitors() {
    try {
        let response = await fetch('${api_url}', {
            method: 'GET',
        });

        let data = await response.json();
        document.getElementById("visitors").textContent = data['new_count'];
    } catch (err) {
        console.error(err);
    }
}

get_visitors();
