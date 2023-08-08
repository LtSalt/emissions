/** @type {import('./$types').PageLoad} */
export async function load({ fetch }) {
    const res = await fetch("src/lib/data/emissions.json");
    const emissions = await res.json();

    return { emissions }
}